const gulp = require('gulp');
const gutil = require('gulp-util');
const include = require("gulp-include");
const coffeescript = require('gulp-coffeescript');
const PluginError = gulp.PluginError;
const Through2= require('through2');
const {exec}= require('child_process');
// const chug = require('gulp-chug');

// get arguments with '--'
args = [];
for(var i=0, argv= process.argv, len = argv.length; i < len; ++i){
	if(argv[i].startsWith('--'));
		args.push(argv[i]);
}


// is Prod: 
var isProd= false;
for(var i=0, len=args.length; i<len; i++){
	if(args[i] === '--prod'){
		isProd= true;
		break;
	}
}

// compiler
const GfwCompiler = require('gridfw-compiler');

// run gulp
function runGulp(){
	console.info('>> Exec compiled Gulpfile:');
	var ps= exec('gulp --gulpfile=gulp-file.js');
	ps.stdout.on('data', function(data){console.log(data.trim())});
	ps.stderr.on('data', function(data){console.error('ERROR>> ', data.trim())});
	ps.on('error', function(err){ console.error('ERR>> ', err); });
	ps.on('close', function(){ console.log('>> Closed.') });
	return ps
}

/* compile gulp-file.coffee */
compileRunGulp= function(){
	return gulp.src('gulpfile/gulp-file.coffee')
		.pipe( include({hardFail: true}) )
		.pipe( GfwCompiler.template({isProd}).on('error', GfwCompiler.logError) )
		.pipe( coffeescript({bare: true}) )
		.pipe( gulp.dest('./') )
		// .pipe( chug({args: args}) )
		.on('error', GfwCompiler.logError);
};

// default task
gulp.task('default', gulp.series(compileRunGulp, runGulp));