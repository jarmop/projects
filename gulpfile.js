'use strict';

var gulp = require('gulp');

var sass = require('gulp-sass');
gulp.task('sass', function () {
  gulp.src('./app/scss/*.scss')
    .pipe(sass().on('error', sass.logError))
    .pipe(gulp.dest('./app/css'));
});
gulp.task('sass:watch', function () {
  gulp.watch('./app/scss/*.scss', ['sass']);
});

var browserSync = require('browser-sync');
var reload = browserSync.reload;
gulp.task('serve', function() {
  browserSync({
    server: {
      baseDir: 'app'
    }
  });
  gulp.watch(['*.html', 'view1/*', 'view2/*', 'scss/*'], {cwd: 'app'}, reload);
});
