module.exports = function(config){
  config.set({

    basePath : '../../',

    files : [
      'dist/lib.js',
      'src/bower_components/angular-mocks/angular-mocks.js',
      'dist/app.js',
      'tests/unit-tests/view*.js'
    ],

    autoWatch : true,

    frameworks: ['jasmine'],

    browsers : ['Chrome'],

    plugins : [
            'karma-chrome-launcher',
            'karma-firefox-launcher',
            'karma-jasmine',
            'karma-junit-reporter'
            ],

    junitReporter : {
      outputFile: 'test_out/unit.xml',
      suite: 'unit'
    }

  });
};
