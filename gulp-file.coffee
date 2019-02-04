gulp			= require 'gulp'
gutil			= require 'gulp-util'
# minify		= require 'gulp-minify'
include			= require "gulp-include"
# rename			= require "gulp-rename"
coffeescript	= require 'gulp-coffeescript'
pug				= require 'gulp-pug'
# through 		= require 'through2'
# path			= require 'path'
# PKG				= require './package.json'

GfwCompiler		= require '../compiler'

# check arguments
SUPPORTED_MODES = ['node', 'browser']
settings = gutil.env
# throw new Error '"--mode=node" or "--mode=browser" argument is required' unless settings.mode
# throw new Error "Unsupported mode: #{settings.mode}, supported are #{SUPPORTED_MODES.join ','}." unless settings.mode in SUPPORTED_MODES

# dest file name
# if settings.mode is 'node'
# 	destFileName = PKG.main.split('/')[1]
# else
# 	destFileName = "grid-model-browser.js"

# compile js (background, popup, ...)
compileCoffee = ->
	# gulp.src ["assets/node.coffee", 'assets/browser.coffee']
	gulp.src ["assets/browser.coffee"]
		.pipe include hardFail: true
		.pipe gulp.dest "build"
		.pipe GfwCompiler.template(settings).on 'error', GfwCompiler.logError
		
		.pipe coffeescript(bare: true).on 'error', GfwCompiler.logError
		.pipe gulp.dest "build"
		.on 'error', GfwCompiler.logError

compileTests = ->
	gulp.src "test-assets/**/*.coffee"
		.pipe include hardFail: true
		# .pipe GfwCompiler.template settings
		# .pipe gulp.dest "test-build"
		
		.pipe coffeescript(bare: true).on 'error', GfwCompiler.logError
		.pipe gulp.dest "test-build"
		.on 'error', GfwCompiler.logError
compileTestPug= ->
	gulp.src "test-assets/**/*.pug"
		.pipe pug()
		.pipe gulp.dest "test-build"
		.on 'error', GfwCompiler.logError

# compile
watch = ->
	gulp.watch 'assets/**/*.coffee', compileCoffee
	gulp.watch 'test-assets/**/*.coffee', compileTests
	gulp.watch 'test-assets/**/*.pug', compileTestPug
	return

# create default task
gulp.task 'default', gulp.series ( gulp.parallel compileCoffee, compileTests, compileTestPug ), watch

