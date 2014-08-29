/**
 * @author Viacheslav Lotsmanov
 * @license GNU/GPLv3 by Free Software Foundation
 */

require! {
	gulp
	argv: 'yargs' .argv

	clean: 'gulp-clean'
	tasks: 'gulp-task-listing'
	bower: 'gulp-bower'
	symlink: 'gulp-symlink'
	sass: 'gulp-sass'
	rename: 'gulp-rename'
	gulpif: 'gulp-if'
	minCSS: 'gulp-minify-css'
	browserify: 'gulp-browserify'
	uglify: 'gulp-uglify'
	jshint: 'gulp-jshint'
	stylish: 'jshint-stylish'
	jade: 'gulp-jade'
	livescript: 'gulp-livescript'
}

gulp.task 'help' tasks

production = argv.production?

gulp.task 'bower' -> bower()

# css {{{1

gulp.task 'clean-css' ->
	gulp
		.src './css/build/'
		.pipe clean()

gulp.task 'css' ['clean-css'] ->
	gulp
		.src './css/src/main.scss'
		.pipe sass()
		.pipe gulpif production, minCSS()
		.pipe rename 'build.css'
		.pipe gulp.dest './css/build/'

gulp.task 'watch-css' ['css'] ->
	gulp.watch [
		'./css/src/**/*.scss'
		'./css/src/**/*.css'
	], ['css']

# css }}}1

# js {{{1

gulp.task 'clean-js' ->
	gulp
		.src './js/build/'
		.pipe clean()

gulp.task 'jshint' ->
	gulp
		.src [
			'./gulpfile.ls'
			'./js/src/**/*.ls'
			'./js/src/**/*.js'
		]
		.pipe gulpif /\.ls$/, livescript()
		.pipe jshint {
			browser: true
			node: true
			undef: true
			indent: 1
			sub: false
			unused: true
			eqnull: true
			predef: [ 'define' ]
		}
		.pipe jshint.reporter stylish

gulp.task 'js-dare' ['clean-js'] ->
	gulp
		.src './js/src/main.ls' read: false
		.pipe browserify {
			transform: ['liveify']
			extensions: ['.ls']
			shim:
				jquery:
					path: './bower_components/jquery/dist/jquery.js'
					exports: ''
				underscore:
					path: './bower_components/underscore/underscore.js'
					exports: ''
				backbone:
					path: './bower_components/backbone/backbone.js'
					exports: ''
			debug: !production
		}
		.pipe gulpif production, uglify preserveComments: 'some'
		.pipe rename 'build.js'
		.pipe gulp.dest './js/build/'

gulp.task 'js-fast' ['jshint' 'js-dare']
gulp.task 'js' ['bower' 'js-fast']

gulp.task 'js-watch' ['js'] ->
	gulp.watch [
		'./js/src/**/*.ls'
		'./js/src/**/*.js'
	], ['js-fast']

gulp.task 'js-watch-dare' ['js'] ->
	gulp.watch [
		'./js/src/**/*.ls'
		'./js/src/**/*.js'
	], ['js-dare']

# js }}}1

# jade {{{1

gulp.task 'clean-jade' ->
	gulp
		.src './*.html'
		.pipe clean()

gulp.task 'jade' ['clean-jade'] ->
	gulp
		.src './jade/*.jade'
		.pipe jade {
			locals:
				pageTitle: 'Backbone project'
		}
		.pipe gulp.dest './'

gulp.task 'jade-watch' ['jade'] ->
	gulp.watch './jade/*.jade', ['jade']

# jade }}}1

# clean {{{1

gulp.task 'clean' [
	'clean-css'
	'clean-js'
	'clean-jade'
]

gulp.task 'distclean' ['clean'] ->
	gulp
		.src [
			'./bower_components'
			'./node_modules'
			'./gulp'
		]
		.pipe clean()

# clean }}}1

# deploy {{{1

gulp.task 'gulp-symlink' ->
	gulp
		.src './node_modules/.bin/gulp'
		.pipe symlink -> ''

# deploy }}}1

#gulp.task 'watch' [
	#'watch-css'
	#'watch-js'
	#'watch-jade'
#]

gulp.task 'default' [
	'gulp-symlink'
	'css'
	'js'
	'jade'
]
