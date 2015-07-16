'use strict';

var gulp = require('gulp');
var merge = require('merge-stream');
var runSequence = require('run-sequence');
var browserSync = require('browser-sync');
//var uglify = require('gulp-uglify');
var concat = require('gulp-concat');
/*var ngmin = require('gulp-ngmin');
 var rev = require('gulp-rev');
 var sourcemaps = require('gulp-sourcemaps');*/
var destFolder = 'dist';
var del = require('del');
var flatten = require('gulp-flatten');
var sass = require('gulp-sass');
var mainBowerFiles = require('main-bower-files');

gulp.task('serve', ['build'], function() {
  browserSync({
    server: {
      baseDir: './dist'
    }
  });
  return gulp.watch(['*.html', 'modules/view1/*', 'modules/view2/*', 'scss/*'], {cwd: 'src'}, ['build', browserSync.reload]);
});

gulp.task("bower-files", function(){
  /* Using separate del task as a dependency fails for some reason. Therefore performing build now as a callback after del. */
  var js = gulp.src(mainBowerFiles('**/*.js'))
    .pipe(concat('lib.js'))
    .pipe(gulp.dest(destFolder));
  var css = gulp.src(mainBowerFiles('**/*.css'))
    .pipe(concat('lib.css'))
    .pipe(gulp.dest(destFolder));
  return merge(js,css);
});

gulp.task('scripts:clean', function() {
  return del(destFolder + '/app.js')
});
gulp.task('scripts', ['scripts:clean'], function() {
  return gulp.src(['src/*.js', 'src/modules/**/*.js'])
    .pipe(concat('app.js'))
    .pipe(gulp.dest(destFolder));
});

gulp.task('styles:clean', function() {
  return del(destFolder + '/app.css')
});
gulp.task('styles', ['styles:clean'], function() {
  return gulp.src('src/scss/*.scss')
    .pipe(sass().on('error', sass.logError))
    .pipe(gulp.dest(destFolder));
});

gulp.task('html:clean', function() {
  return del(destFolder + '/**/*.html')
});
gulp.task('html', ['html:clean'], function() {
  var index = gulp.src('src/*.html')
    .pipe(gulp.dest(destFolder));
  var modules = gulp.src('src/modules/**/*.html')
    .pipe(flatten())
    .pipe(gulp.dest(destFolder));
  return merge(index, modules);
});

gulp.task('clean', function () {
  return del(destFolder);
});

gulp.task('build', ['clean'], function() {
  return runSequence('bower-files', 'scripts', 'styles', 'html');
});