var browserSync = require('browser-sync').create();

browserSync.init({
  server: {
    baseDir: "./app",
    middleware: [
      require('connect-history-api-fallback')({ index: '/index.html' })
    ]
  },
  files: ['./app/*']
});