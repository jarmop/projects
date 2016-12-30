'use strict';

var gulp = require('gulp');

var browserSync = require('browser-sync');
var reload = browserSync.reload;
gulp.task('serve', function() {
  browserSync({
    server: {
      baseDir: './dist'
    }
  });
  gulp.watch(['*.html', 'view1/*', 'view2/*', '*.css'], {cwd: 'app'}, ['build', reload]);
});

//var uglify = require('gulp-uglify');
var concat = require('gulp-concat');
/*var ngmin = require('gulp-ngmin');
var rev = require('gulp-rev');
var sourcemaps = require('gulp-sourcemaps');*/
var destFolder = 'dist';
var del = require('del');

gulp.task('styles:clean', function() {
  del(destFolder + '/lib')
});
var mainBowerFiles = require('main-bower-files');
gulp.task("bower-files", function(){
  gulp.src(mainBowerFiles('**/*.js'))
    //.pipe(concat('lib.js'))
    .pipe(gulp.dest(destFolder + '/lib'));
});

gulp.task('styles:clean', function() {
  del(destFolder + '/app.js')
});
gulp.task('scripts', function() {
  gulp.src(['src/*.js', 'src/controllers/**/*.js'])
    .pipe(concat('app.js'))
    .pipe(gulp.dest(destFolder));
});

gulp.task('styles:clean', function() {
  del(destFolder + '/app.css')
});
var sass = require('gulp-sass');
gulp.task('styles', function() {
  gulp.src('src/scss/*.scss')
    .pipe(sass().on('error', sass.logError))
    .pipe(gulp.dest(destFolder));
});

gulp.task('html:clean', function() {
  del(destFolder + '/**/*.html')
});
gulp.task('html', ['html:clean'], function() {
  gulp.src('src/*.html')
    .pipe(gulp.dest(destFolder));
  gulp.src('src/templates/*')
    .pipe(gulp.dest(destFolder + '/templates'));
});

gulp.task('clean', function () {
  del(destFolder)
});

gulp.task('build', ['bower-files', 'scripts', 'styles', 'html']);