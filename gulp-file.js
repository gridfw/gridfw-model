var GfwCompiler, coffeescript, compileBrowser, compileNode, compileTestPug, compileTests, gulp, gutil, include, isProd, pug, rename, settings, uglify, watch;

gulp = require('gulp');

gutil = require('gulp-util');

// minify		= require 'gulp-minify'
include = require("gulp-include");

rename = require("gulp-rename");

coffeescript = require('gulp-coffeescript');

uglify = require('gulp-uglify-es').default;

pug = require('gulp-pug');

// through 		= require 'through2'
// path			= require 'path'
// PKG				= require './package.json'
GfwCompiler = require('gridfw-compiler');

// settings
isProd = true;

settings = {
  isProd: isProd
};

// check arguments
// SUPPORTED_MODES = ['node', 'browser']
// settings = gutil.env
// throw new Error '"--mode=node" or "--mode=browser" argument is required' unless settings.mode
// throw new Error "Unsupported mode: #{settings.mode}, supported are #{SUPPORTED_MODES.join ','}." unless settings.mode in SUPPORTED_MODES

// dest file name
// if settings.mode is 'node'
// 	destFileName = PKG.main.split('/')[1]
// else
// 	destFileName = "grid-model-browser.js"
compileBrowser = function() {
  return gulp.src(["assets/browser.coffee"]).pipe(include({
    hardFail: true
  })).pipe(GfwCompiler.template({
    isNode: false,
    ...settings
  }).on('error', GfwCompiler.logError)).pipe(coffeescript({
    bare: false
  }).on('error', GfwCompiler.logError)).pipe(rename('browser-model.js')).pipe(uglify({
    compress: {
      toplevel: false,
      keep_infinity: true,
      warnings: true
    }
  })).pipe(gulp.dest("build")).on('error', GfwCompiler.logError);
};

compileNode = function() {
  return gulp.src(["assets/node.coffee"]).pipe(include({
    hardFail: true
  })).pipe(GfwCompiler.template({
    isNode: true,
    ...settings
  }).on('error', GfwCompiler.logError)).pipe(coffeescript({
    bare: true
  }).on('error', GfwCompiler.logError)).pipe(uglify({
    module: true,
    compress: {
      toplevel: true,
      module: true,
      keep_infinity: true,
      warnings: true
    }
  })).pipe(gulp.dest("build")).on('error', GfwCompiler.logError);
};

compileTests = function() {
  return gulp.src("test-assets/**/*.coffee").pipe(include({
    hardFail: true
  // .pipe GfwCompiler.template settings
  // .pipe gulp.dest "test-build"
  })).pipe(coffeescript({
    bare: true
  }).on('error', GfwCompiler.logError)).pipe(gulp.dest("test-build")).on('error', GfwCompiler.logError);
};

compileTestPug = function() {
  return gulp.src("test-assets/**/*.pug").pipe(pug()).pipe(gulp.dest("test-build")).on('error', GfwCompiler.logError);
};

// compile
watch = function(cb) {
  if (!isProd) {
    gulp.watch('assets/**/*.coffee', gulp.parallel(compileBrowser, compileNode));
    gulp.watch('test-assets/**/*.coffee', compileTests);
    gulp.watch('test-assets/**/*.pug', compileTestPug);
  }
  cb();
};

// create default task
gulp.task('default', gulp.series(gulp.parallel(compileBrowser, compileNode, compileTests, compileTestPug), watch));
