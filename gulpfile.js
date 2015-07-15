'use strict';

var gulp = require('gulp');

var browserSync = require('browser-sync');
gulp.task('serve', ['build'], function() {
  browserSync({
    server: {
      baseDir: './dist'
    }
  });
  gulp.watch(['*.html', 'modules/view1/*', 'modules/view2/*', 'scss/*'], {cwd: 'src'}, ['build', browserSync.reload]);
});

//var uglify = require('gulp-uglify');
var concat = require('gulp-concat');
/*var ngmin = require('gulp-ngmin');
var rev = require('gulp-rev');
var sourcemaps = require('gulp-sourcemaps');*/
var destFolder = 'dist';
var del = require('del');

var mainBowerFiles = require('main-bower-files');
gulp.task("bower-files", function(){
  /* Using separate del task as a dependency fails for some reason. Therefore performing build now as a callback after del. */
  return del(destFolder + '/lib', function() {
    gulp.src(mainBowerFiles('**/*.js'))
      .pipe(concat('lib.js'))
      .pipe(gulp.dest(destFolder));
  });

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
var sass = require('gulp-sass');
gulp.task('styles', ['styles:clean'], function() {
  return gulp.src('src/scss/*.scss')
    .pipe(sass().on('error', sass.logError))
    .pipe(gulp.dest(destFolder));
});

var flatten = require('gulp-flatten');
gulp.task('html:clean', function() {
  return del(destFolder + '/**/*.html')
});
var merge = require('merge-stream');
gulp.task('html', ['html:clean'], function() {
  var index = gulp.src('src/*.html')
    .pipe(gulp.dest(destFolder));
  var modules = gulp.src('src/modules/**/*.html')
    .pipe(flatten())
    .pipe(gulp.dest(destFolder));
  return merge(index, modules);
});

gulp.task('clean', function () {
  del(destFolder)
});

gulp.task('build', ['bower-files', 'scripts', 'styles', 'html']);