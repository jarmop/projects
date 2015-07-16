'use strict';

angular.module('myApp.view1', ['ngRoute'])

.config(['$routeProvider', function($routeProvider) {
  $routeProvider.when('/view1', {
    templateUrl: 'view1.html',
    controller: 'View1Ctrl'
  });
}])

.controller('View1Ctrl', ['$scope', 'Tax', function($scope, Tax) {
  $scope.stack = [
    {address: '0x0012FF6C', value: '0x004012E8'},
    {address: '0x0012FF68', value: '0x0012FFB8'}
  ];

  $scope.code = [
    {code: 'sub:', description: ''},
    {code: '00401000  push      ebp', description: 'tälläainen laini'},
    {code: '00401001  mov       ebp,esp', description: ''},
    {code: '00401003  mov       eax,0BEEFh', description: ''},
    {code: '00401008  pop       ebp', description: ''},
    {code: '00401009  ret', description: ''},
    {code: 'main:', description: ''},
    {code: '00401010  push      ebp', description: ''},
    {code: '00401011  mov       ebp,esp', description: ''},
    {code: '00401013  call      sub (401000h)', description: ''},
    {code: '00401018  mov       eax,0F00Dh', description: ''},
    {code: '0040101D  pop       ebp', description: ''},
    {code: '0040101E  ret', description: ''}
  ];

  var runningOrder = [7,8,9,1,2,3,4,5,10,11,12];
  var linePointer = 0;
  $scope.isActiveLine = function(lineKey) {
    return lineKey == runningOrder[linePointer];
  };

  $scope.forward = function() {
    if (linePointer < (runningOrder.length - 1)) {
      linePointer++;
    }
  };

  $scope.backward = function() {
    if (linePointer > 0) {
      linePointer--;
    }
  };

  $scope.setActive = function(lineKey) {
    linePointer = runningOrder.indexOf(lineKey);
  };

  $scope.goToStart = function() {
    linePointer = 0;
  };
}]);