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

var mainBowerFiles = require('main-bower-files');
gulp.task("bower-files", function(){
  gulp.src(mainBowerFiles('**/*.js'))
    //.pipe(concat('lib.js'))
    .pipe(gulp.dest(destFolder + '/lib'));
});

gulp.task('scripts', function() {
  gulp.src(['src/*.js', 'src/controllers/**/*.js'])
    .pipe(concat('app.js'))
    .pipe(gulp.dest(destFolder));
});

var sass = require('gulp-sass');
gulp.task('styles', function() {
  gulp.src('src/scss/*.scss')
    .pipe(sass().on('error', sass.logError))
    .pipe(gulp.dest(destFolder));
});

gulp.task('html', function() {
  gulp.src('src/*.html')
    .pipe(gulp.dest(destFolder));
  gulp.src('src/templates/*')
    .pipe(gulp.dest(destFolder + '/templates'));
});

var del = require('del');
gulp.task('clean', function () {
  del('dist')
});

gulp.task('build', ['clean', 'bower-files', 'scripts', 'styles', 'html']);