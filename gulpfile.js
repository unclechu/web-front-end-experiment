var gulp = require('gulp');
var argv = require('yargs').argv;

var clean = require('gulp-clean');
var taskListing = require('gulp-task-listing');
var bower = require('gulp-bower');
var symlink = require('gulp-symlink');

gulp.task('help', taskListing);

var production = argv.production ? true : false;

gulp.task('bower', function () {
	return bower()
		.pipe(gulp.dest('./js/lib/'));
});

gulp.task('clean-bower', function () {
	return gulp
		.src('./js/lib/')
		.pipe(clean());
});

gulp.task('clean', [
	'clean-bower',
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

gulp.task('gulp-symlink', function () {
	return gulp
		.src('./node_modules/.bin/gulp')
		.pipe(symlink(function (file) {
			return '';
		}));
});

gulp.task('default', [
	'gulp-symlink',
	'bower',
]);
