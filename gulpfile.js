const gulp = require('gulp');
const gutil = require('gulp-util');
const include = require("gulp-include");
const coffeescript = require('gulp-coffeescript');
const PluginError = gulp.PluginError;
const chug = require('gulp-chug');
const {exec} = require('child_process');
const Through2= require('through2');

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
const GfwCompiler = require(isProd ? 'gridfw-compiler' : '../compiler');

/* compile gulp-file.coffee */
compileRunGulp= function(){
	return gulp.src('gulp-file.coffee')
		.pipe( include({hardFail: true}) )
		.pipe( GfwCompiler.template({isProd}).on('error', GfwCompiler.logError) )
		.pipe( coffeescript({bare: true}) )
		.pipe( gulp.dest('./') )
		.pipe(Through2.obj(function(file, enc, cb){
			if(file.isBuffer()){
				console.info('>> Exec compiled Gulpfile:');
				var ps= exec('gulp --gulpfile=gulp-file.js');
				ps.stdout.on('data', function(data){console.log(data.trim())});
				ps.stderr.on('data', function(data){console.error('ERROR>> ', data.trim())});
				ps.on('error', function(err){ cb(err); });
				ps.on('close', function(){ cb(null); });
			}
			else
				cb(null);
		}))
		// .pipe( chug({args: args}) )
		.on('error', gutil.log);
		// .on('error', GfwCompiler.logError);
};

// default task
gulp.task('default', compileRunGulp);