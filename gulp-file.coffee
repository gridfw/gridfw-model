gulp			= require 'gulp'
gutil			= require 'gulp-util'
# minify		= require 'gulp-minify'
include			= require "gulp-include"
# rename			= require "gulp-rename"
coffeescript	= require 'gulp-coffeescript'
uglify			= require('gulp-uglify-es').default
pug				= require 'gulp-pug'
# through 		= require 'through2'
# path			= require 'path'
# PKG				= require './package.json'

GfwCompiler		= require '../compiler'

# settings
isProd= gutil.env.hasOwnProperty('prod')
settings=
	isProd: isProd


# check arguments
# SUPPORTED_MODES = ['node', 'browser']
# settings = gutil.env
# throw new Error '"--mode=node" or "--mode=browser" argument is required' unless settings.mode
# throw new Error "Unsupported mode: #{settings.mode}, supported are #{SUPPORTED_MODES.join ','}." unless settings.mode in SUPPORTED_MODES

# dest file name
# if settings.mode is 'node'
# 	destFileName = PKG.main.split('/')[1]
# else
# 	destFileName = "grid-model-browser.js"

# compile js (background, popup, ...)
compileCoffee = (target) ->
	->
		# glp= gulp.src ["assets/node.coffee", 'assets/browser.coffee']
		glp= gulp.src ["assets/#{target}.coffee"]
			.pipe include hardFail: true
			.pipe GfwCompiler.template({isNode: target is 'node' ,settings...}).on 'error', GfwCompiler.logError
			# .pipe gulp.dest "build"
			
			.pipe coffeescript(bare: target is 'node').on 'error', GfwCompiler.logError

		# if is prod
		if settings.isProd
			if target is 'browser'
				glp = glp.pipe uglify
					toplevel: no
					compress:
						keep_infinity: on # chrome performance issue
						warnings: on
			else
				glp = glp.pipe uglify
					module: on
					compress:
						toplevel: true
						module: true
						keep_infinity: on # chrome performance issue
						warnings: on

		glp.pipe gulp.dest "build"
			.on 'error', GfwCompiler.logError
compileBrowser= compileCoffee 'browser'
compileNode= compileCoffee 'node'

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
watch = (cb)->
	unless isProd
		gulp.watch 'assets/**/*.coffee', gulp.parallel compileBrowser, compileNode
		gulp.watch 'test-assets/**/*.coffee', compileTests
		gulp.watch 'test-assets/**/*.pug', compileTestPug
	cb()
	return

# create default task
gulp.task 'default', gulp.series ( gulp.parallel compileBrowser, compileNode, compileTests, compileTestPug ), watch

