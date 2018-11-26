gulp			= require 'gulp'
gutil			= require 'gulp-util'
# minify		= require 'gulp-minify'
include			= require "gulp-include"
rename			= require "gulp-rename"
coffeescript	= require 'gulp-coffeescript'
PluginError		= gulp.PluginError
cliTable		= require 'cli-table'
template		= require 'gulp-template'
pug				= require 'gulp-pug'
through 		= require 'through2'
path			= require 'path'
PKG				= require './package.json'

# check arguments
SUPPORTED_MODES = ['node', 'browser']
settings = gutil.env
throw new Error '"--mode=node" or "--mode=browser" argument is required' unless settings.mode
throw new Error "Unsupported mode: #{settings.mode}, supported are #{SUPPORTED_MODES.join ','}." unless settings.mode in SUPPORTED_MODES

# dest file name
if settings.mode is 'node'
	destFileName = PKG.main.split('/')[1]
else
	destFileName = "grid-model-nav-#{PKG.version}.js"

# compile js (background, popup, ...)
compileCoffee = ->
	gulp.src "assets/index.coffee"
		.pipe include hardFail: true
		.pipe template settings
		.pipe gulp.dest "build"
		
		.pipe coffeescript(bare: true).on 'error', errorHandler
		.pipe rename destFileName
		.pipe gulp.dest "build"
		.on 'error', errorHandler

compileTests = ->
	gulp.src "test-assets/*.coffee"
		.pipe include hardFail: true
		# .pipe template settings
		# .pipe gulp.dest "test-build"
		
		.pipe coffeescript(bare: true).on 'error', errorHandler
		.pipe gulp.dest "test-build"
		.on 'error', errorHandler

# compile
watch = ->
	gulp.watch 'assets/**/*.coffee', compileCoffee
	gulp.watch 'test-assets/**/*.coffee', compileTests
	return

# error handler
errorHandler= (err)->
	# get error line
	expr = /:(\d+):(\d+):/.exec err.stack
	if expr
		line = parseInt expr[1]
		col = parseInt expr[2]
		code = err.code?.split("\n")[line-3 ... line + 3].join("\n")
	else
		code = line = col = '??'
	# Render
	table = new cliTable()
	table.push {Name: err.name},
		{Filename: err.filename},
		{Message: err.message},
		{Line: line},
		{Col: col}
	console.error table.toString()
	console.log '\x1b[31mStack:'
	console.error '\x1b[0m┌─────────────────────────────────────────────────────────────────────────────────────────┐'
	console.error '\x1b[34m', err.stack
	console.log '\x1b[0m└─────────────────────────────────────────────────────────────────────────────────────────┘'
	console.log '\x1b[31mCode:'
	console.error '\x1b[0m┌─────────────────────────────────────────────────────────────────────────────────────────┐'
	console.error '\x1b[34m', code
	console.log '\x1b[0m└─────────────────────────────────────────────────────────────────────────────────────────┘'
	return

# create default task
gulp.task 'default', gulp.series compileCoffee, compileTests, watch

