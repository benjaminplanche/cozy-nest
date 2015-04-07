gulp = require 'gulp'
browserify = require 'browserify'
buffer = require 'vinyl-buffer'
coffee = require 'gulp-coffee'
clean = require 'gulp-clean'
mocha = require 'gulp-mocha'
rm = require 'del'
source = require 'vinyl-source-stream'

logger = require 'printit'
	date: false
	prefix: 'gulp'

const BUILDDIR = 'build/'


gulp.task 'default', ['b']
gulp.task 'b' /* build */, ['build-client', 'build-server']
gulp.task 't' /* test */, ['test-client', 'test-server']

	 
gulp.task 'build-client', () ->
	logger.options.prefix = 'gulp:build-client'
	logger.info "Start compilation..."

	# rm BUILDDIR + 'client/'

	# gulp.src 'static/**/*'
	 # .pipe gulp.dest BUILDDIR + 'client/'
	
	# bundler = browserify {
		# entries: ['./client/main.js'],
		# debug: true
	
	# bundler
	 # .transform babelify
	 # .bundle 
		# .on 'error', (err) ->
			# logger.error 'Bundle error: ' + err 
			# this.end 
		
	 # .pipe source 'main.js'
	 # .pipe buffer 
	 # .pipe gulp.dest BUILDDIR + 'client/js'
	 
	logger.error "No gulp-task defined yet."

	logger.info "Compilation succeeded."


gulp.task 'build-server', () ->
	logger.options.prefix = 'gulp:build-server'
	logger.info "Start compilation..."
	
	rm [BUILDDIR + 'server/', 'server.js']

	gulp.src 'server/**/*.coffee'
	 .pipe coffee .on 'error', logger.error
	 .pipe gulp.dest BUILDDIR + 'server/'
	
	gulp.src 'server.coffee'
	 .pipe coffee .on 'error', logger.error
	 .pipe gulp.dest BUILDDIR

	gulp.src 'package.json'
	 .pipe gulp.dest BUILDDIR

	logger.info "Compilation succeeded."



gulp.task 'test-client', () ->
	logger.options.prefix = 'gulp:test-client'
	logger.info "Start testing client..."
	
	# gulp.src ['tests/controllers/*.coffee'], read: false
	 # .pipe mocha reporter: 'spec'
	  # .on 'error', logger.error
	logger.error "No test implemented yet."

	logger.info "Testing client done."

gulp.task 'test-server', () ->
	logger.options.prefix = 'gulp:test-server'
	logger.info "Start testing server..."
	
	gulp.src ['tests/controllers/*.coffee'], read: false
	 .pipe mocha reporter: 'spec'
	  .on 'error', logger.error

	logger.info "Testing server done."


gulp.task 'w' /* watch */, ['test-client', 'test-server'], () ->
	gulp.watch ['client/**/*.js', 'static/**/*'], ['test-client']
	gulp.watch ['server/**/*.coffee', 'server.coffee', 'tests/**/*'], ['test-server']
	
# gulp.task 'w' /* watch */, ['build-client', 'build-server'], () ->
	# gulp.watch ['client/**/*.js', 'static/**/*'], ['build-client']
	# gulp.watch ['server/**/*.coffee', 'server.coffee'], ['build-server']


gulp.task 'clean', () ->
	gulp.src BUILDDIR, force: true 
	 .pipe clean
