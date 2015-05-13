exports.registerGulpTask = ({src, dest}, gulp) ->

  gulp.task 'assets:browserify', (cb) ->
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

    devMode = !gutil.env.prod
    bundleQueue = 0

    browserifyThis = (entrypoint) ->
      bundleQueue++

      args = Object.create(devMode and watchify.args or {})
      args.debug = true # sourcemaps
      args.extensions = ['.coffee', '.jade']

      b = browserify entrypoint.path, args
      b.transform {global: true}, coffeeify
      b.transform {global: true}, ngAnnotatify
      b.transform {global: true}, jadeify
      b.transform {global: true}, (file) -> insertGlobals(file, always: false) # detectGlobals

      initialCbGate = ->
        cb() if --bundleQueue is 0

      bundleLogger = (entrypoint) ->
        startedAt = Date.now()
        gutil.log "Starting '#{gutil.colors.cyan("browserify #{entrypoint.relative}")}'..."
        return ->
          duration = Date.now() - startedAt
          gutil.log "Finished '#{gutil.colors.cyan("browserify #{entrypoint.relative}")}' after #{gutil.colors.magenta("#{duration} ms")}"

      bundle = ->
        done = bundleLogger entrypoint
        b.bundle()
          # Report compile errors
          .on('error', gutil.log.bind(gutil))
          # Use vinyl-source-stream to make the
          # stream gulp compatible. Specify the
          # desired output filename here.
          .pipe(source(entrypoint.relative))
          .pipe(rename('app.js'))
          # Specify the output destination
          .pipe(gulp.dest(dest))
          .on('end', done)
          .on('end', initialCbGate)

      if devMode
        # Wrap with watchify and rebundle on changes
        b = watchify(b)
        b.on 'update', bundle

      bundle()

    gulp.src(src, read: false).on 'data', browserifyThis

    return # don't return the stream above
