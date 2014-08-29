/**
 * @author Viacheslav Lotsmanov
 * @license GNU/GPLv3 by Free Software Foundation
 */

var gulp = require('gulp');
var argv = require('yargs').argv;

var clean = require('gulp-clean');
var taskListing = require('gulp-task-listing');
var bower = require('gulp-bower');
var symlink = require('gulp-symlink');
var sass = require('gulp-sass');
var rename = require('gulp-rename');
var gulpif = require('gulp-if');
var minCSS = require('gulp-minify-css');
var browserify = require('gulp-browserify');
var uglify = require('gulp-uglify');
var jshint = require('gulp-jshint');
var stylish = require('jshint-stylish');

gulp.task('help', taskListing);

var production = argv.production ? true : false;

// bower {{{1

gulp.task('bower', function () {
	return bower();
});

// bower }}}1

// css {{{1

gulp.task('clean-css', function () {
	return gulp
		.src('./css/build/')
		.pipe(clean());
});

gulp.task('css', ['clean-css'], function () {
	return gulp
		.src('./css/src/main.scss')
		.pipe(sass())
		.pipe(gulpif(production, minCSS()))
		.pipe(rename('build.css'))
		.pipe(gulp.dest('./css/build/'));
});

// css }}}1

// js {{{1

gulp.task('clean-js', function () {
	return gulp
		.src('./js/build/')
		.pipe(clean());
});

gulp.task('jshint', function () {
	return gulp
		.src('./js/src/**/*.js')
		.pipe(jshint({
			"browser": true,
			"node": true,
			"undef": true,
			"indent": 1,
			"sub": false,
			"unused": true,
			"predef": [ "define" ]
		}))
		.pipe(jshint.reporter(stylish));
});

gulp.task('js', ['clean-js', 'bower', 'jshint'], function () {
	return gulp
		.src('./js/src/main.js')
		.pipe(browserify({
			shim: {
				jquery: {
					path: './bower_components/jquery/dist/jquery',
					exports: '',
				},
			},
			debug: !production,
		}))
		.pipe(gulpif(production, uglify({
			preserveComments: 'some',
		})))
		.pipe(rename('build.js'))
		.pipe(gulp.dest('./js/build/'));
});

// js }}}1

// clean {{{1

gulp.task('clean', [
	'clean-css',
	'clean-js',
]);

gulp.task('distclean', ['clean'], function () {
	return gulp
		.src([
			'./bower_components',
			'./node_modules',
			'./gulp',
		])
		.pipe(clean());
});

// clean }}}1

// deploy {{{1

gulp.task('gulp-symlink', function () {
	return gulp
		.src('./node_modules/.bin/gulp')
		.pipe(symlink(function (file) {
			return '';
		}));
});

// deploy }}}1

gulp.task('default', [
	'gulp-symlink',
	'css',
	'js',
]);
