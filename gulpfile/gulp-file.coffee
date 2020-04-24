###*
 * Compile code
###
gulp			= require 'gulp'
GulpHeader		= require 'gulp-header'
# gutil			= require 'gulp-util'
# minify		= require 'gulp-minify'
include			= require "gulp-include"
uglify			= require('gulp-terser')
Rename			= require "gulp-rename"
GulpCoffeescript= require 'gulp-coffeescript'
# Coffeescript	= require 'coffeescript'
Babel			= require 'gulp-babel'
# GulpEjs			= require 'gulp-ejs'
GfwCompiler		= require 'gridfw-compiler'

isProd= <%= isProd %>
#=include _schema.coffee
settings=
	SCHEMA:			SCHEMA
	SCHEMA_ATTR:	SCHEMA_ATTR


compileCoffee= ->
	gulp.src ['assets/browser.coffee', 'assets/node.coffee'], nodir: yes
		.pipe include hardFail: true
		.pipe GfwCompiler.template(settings).on 'error', GfwCompiler.logError
		.pipe GulpCoffeescript(bare: true).on 'error', GfwCompiler.logError
		<% if(isProd){ %>
		.pipe Babel
			presets: ['babel-preset-env']
			plugins: [
				['transform-runtime',{
					helpers: no
					polyfill: no
					regenerator: no
				}]
				'transform-async-to-generator'
			]
		.pipe uglify {compress: {toplevel: no, keep_infinity: on, warnings: on} }
		<% } %>
		.pipe GulpHeader('\ufeff')
		.pipe gulp.dest 'build'
		.on 'error', GfwCompiler.logError

compileTests= ->
	gulp.src 'assets-test/**/[^_]*.coffee', nodir: yes
		.pipe include hardFail: true
		.pipe GfwCompiler.template(settings).on 'error', GfwCompiler.logError
		.pipe GulpCoffeescript(bare: true).on 'error', GfwCompiler.logError
		.pipe GulpHeader('\ufeff')
		.pipe gulp.dest 'test-build/'
		.on 'error', GfwCompiler.logError

watch= (cb)->
	unless isProd
		gulp.watch 'assets/**/*.coffee', compileCoffee
		gulp.watch 'assets-test/**/*.coffee', compileTests
	do cb
	return

gulp.task 'default', gulp.series compileCoffee, compileTests, watch