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
}]);