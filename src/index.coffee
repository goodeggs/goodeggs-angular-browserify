gulp = require 'gulp'
path = require 'path'
coffeeify = require 'coffeeify'
ngAnnotatify = require 'ng-annotatify'
jadeify = require 'goodeggs-jadeify'
browserify = require 'browserify'
watchify = require 'watchify'
gutil = require 'gulp-util'
source = require 'vinyl-source-stream'
glob = require 'glob'
rename = require 'gulp-rename'
insertGlobals = require 'insert-module-globals'

###
@argument options:
  src (required): the file to use as a handle for gulp vinyl streams
  entrypoint (boolean, default true): whether or not to treat `src` as an entrypoint in the resulting bundle
  bundleName: the filename of the created bundle
  dest: the folder the compiled assets go in
  watch: whether or not to use watchify?
  externalModules: modules to not include in the bundle even if they are required
  exposeModules: modules to expose to the global scope so they can be required by other bundles
###
exports.run = (options, cb) ->
  options.entrypoint ?= true
  options.bundleName ?= if options.entrypoint then 'app.js' else 'externals.js'
  options.watch ?= if options.entrypoint then gutil.env.watch else false
  bundleQueue = 0

  gulp.src(options.src, read: false).on 'data', (src) ->
    bundleQueue++
    bundleOptions = JSON.parse JSON.stringify options
    delete options.src
    bundleOptions.entries = src.path if options.entrypoint
    bundleOptions.relative = src.relative
    browserifyThis(bundleOptions).on 'end', ->
      cb() if --bundleQueue is 0

  return # don't return the stream above

browserifyThis = ({relative, entries, dest, bundleName, watch, externalModules, exposeModules}) ->
  args = Object.create(watch and watchify.args or {})
  args.debug = true # sourcemaps
  args.extensions = ['.coffee', '.jade']

  b = browserify args
  b.transform {global: true}, coffeeify
  b.transform {global: true}, ngAnnotatify
  b.transform {global: true}, jadeify
  b.transform {global: true}, (file) -> insertGlobals(file, always: false) # detectGlobals

  b.add entries if entries
  b.external externalModules if externalModules
  b.require exposeModules if exposeModules

  bundle = ->
    done = bundleLogger bundleName
    b.bundle()
      # Report compile errors
      .on('error', gutil.log.bind(gutil))
      # Use vinyl-source-stream to make the
      # stream gulp compatible. Specify the
      # desired output filename here.
      .pipe(source(relative))
      .pipe(rename(bundleName))
      # Specify the output destination
      .pipe(gulp.dest(dest))
      .on('end', done)

  if watch
    # Wrap with watchify and rebundle on changes
    b = watchify(b)
    b.on 'update', bundle

  bundle()

bundleLogger = (name) ->
  startedAt = Date.now()
  taskName = gutil.colors.cyan("browserify #{name}")
  gutil.log "Starting '#{taskName}'..."
  return ->
    duration = Date.now() - startedAt
    gutil.log "Finished '#{taskName}' after #{gutil.colors.magenta("#{duration} ms")}"
