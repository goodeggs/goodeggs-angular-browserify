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
  src: a file to bundle
  bundleName: the filename of the created bundle
  dest: the folder the compiled assets go in
  watch: whether or not to use watchify?
###
exports.run = (options, cb) ->
  options.bundleName ?= 'app.js'

  options.watch ?= gutil.env.watch
  bundleQueue = 0

  gulp.src(options.src, read: false).on 'data', (entrypoint) ->
    bundleQueue++
    bundleOptions = JSON.parse JSON.stringify options
    delete options.src
    bundleOptions.entrypoint = entrypoint
    browserifyThis(bundleOptions).on 'end', ->
      cb() if --bundleQueue is 0

  return # don't return the stream above

browserifyThis = ({entrypoint, dest, bundleName, watch}) ->
  args = Object.create(watch and watchify.args or {})
  args.debug = true # sourcemaps
  args.extensions = ['.coffee', '.jade']

  b = browserify entrypoint.path, args
  b.transform {global: true}, coffeeify
  b.transform {global: true}, ngAnnotatify
  b.transform {global: true}, jadeify
  b.transform {global: true}, (file) -> insertGlobals(file, always: false) # detectGlobals

  bundle = ->
    done = bundleLogger entrypoint
    b.bundle()
      # Report compile errors
      .on('error', gutil.log.bind(gutil))
      # Use vinyl-source-stream to make the
      # stream gulp compatible. Specify the
      # desired output filename here.
      .pipe(source(entrypoint.relative))
      .pipe(rename(bundleName))
      # Specify the output destination
      .pipe(gulp.dest(dest))
      .on('end', done)

  if watch
    # Wrap with watchify and rebundle on changes
    b = watchify(b)
    b.on 'update', bundle

  bundle()

bundleLogger = (entrypoint) ->
  startedAt = Date.now()
  gutil.log "Starting '#{gutil.colors.cyan("browserify #{entrypoint.relative}")}'..."
  return ->
    duration = Date.now() - startedAt
    gutil.log "Finished '#{gutil.colors.cyan("browserify #{entrypoint.relative}")}' after #{gutil.colors.magenta("#{duration} ms")}"
