const gulp = require('gulp');
const gutil = require('gulp-util');
const include = require("gulp-include");
const coffeescript = require('gulp-coffeescript');
const PluginError = gulp.PluginError;
const chug = require('gulp-chug');

// get arguments with '--'
args = []
for(var i=0, argv= process.argv, len = argv.length; i < len; ++i)
	if(argv[i].startsWith('--'))
		args.push(argv[i])

/* compile gulp-file.coffee */
compileRunGulp= function(){
	return gulp.src('gulp-file.coffee')
		.pipe(coffeescript({bare: true}))
		.pipe( chug({args: args}) )
		.on('error', gutil.log)
};

// default task
gulp.task('default', compileRunGulp);