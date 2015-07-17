'use strict';

angular.module('myApp.view1', ['ngRoute'])

.config(['$routeProvider', function($routeProvider) {
  $routeProvider.when('/view1', {
    templateUrl: 'view1.html',
    controller: 'View1Ctrl'
  });
}])

.controller('View1Ctrl', ['$scope', 'Tax', function($scope, Tax) {
  $scope.stack = {
    '0x0012FF6C': '0x004012E8',
    '0x0012FF68': '',
    '0x0012FF64': '',
    '0x0012FF60': '',
    '0x0012FF5C': '',
    '0x0012FF58': '',
  };

  $scope.registers = {
    eax: '0x003435C0',
    ebp: '0x0012FFB8',
    esp: '0x0012FF6C'
  };

  // $scope.codeBlock for describing multiple code lines

  $scope.code = [
    {address: 'sub:', instruction: '', arguments: '', description: ''},
    {address: '00401000', instruction: 'push', arguments: ['ebp'], description: 'tälläainen laini'},
    {address: '00401001', instruction: 'mov', arguments: ['ebp','esp'], description: ''},
    {address: '00401003', instruction: 'mov', arguments: ['eax','0BEEFh'], description: ''},
    {address: '00401008', instruction: 'pop', arguments: ['ebp'], description: ''},
    {address: '00401009', instruction: 'ret', arguments: [], description: ''},
    {address: 'main:', instruction: '', arguments: [], description: ''},
    {address: '00401010', instruction: 'push', arguments: ['ebp'], description: ''},
    {address: '00401011', instruction: 'mov', arguments: ['ebp','esp'], description: ''},
    {address: '00401013', instruction: 'call', arguments: ['sub'], description: ''},
    {address: '00401018', instruction: 'mov', arguments: ['eax','0F00Dh'], description: ''},
    {address: '0040101D', instruction: 'pop', arguments: ['ebp'], description: ''},
    {address: '0040101E', instruction: 'ret', arguments: [], description: ''},
  ];

  var runningOrder = [7,8,9,1,2,3,4,5,10,11,12];
  var linePointer = 0;
  $scope.isActiveLine = function(lineKey) {
    return lineKey == runningOrder[linePointer];
  };

  $scope.forward = function() {
    if (linePointer < (runningOrder.length - 1)) {
      setLinePointer(linePointer + 1);
    }
  };

  $scope.backward = function() {
    if (linePointer > 0) {
      setLinePointer(linePointer - 1);
    }
  };

  $scope.setActive = function(lineKey) {
    setLinePointer(runningOrder.indexOf(lineKey));
  };

  $scope.goToStart = function() {
    setLinePointer(0);
  };

  function push() {
    decrementESP();
    var value = arguments[0];
    if (isRegister(value)) {
      value = $scope.registers[value];
    }
    $scope.stack[$scope.registers.esp] = value;
  }

  function pop(register) {
    if (register !== undefined) {
      register.value = $scope.stack[$scope.registers.esp];
    }
    incrementESP()
  }

  function decrementESP() {
    $scope.registers.esp = '0x00' + (parseInt($scope.registers.esp, 16) - 4).toString(16).toUpperCase();
  }

  function incrementESP() {
    $scope.registers.esp = '0x00' + (parseInt($scope.registers.esp, 16) + 4).toString(16).toUpperCase();
  }

  function isRegister(value) {
    return value in $scope.registers;
  }

  function runLine(linePointer) {
    var line = $scope.code[runningOrder[linePointer]];
    assembler[line.instruction].apply(this, line.arguments);
  }

  function setLinePointer(value) {
    linePointer = value;
    runLine(linePointer);
  }

  var assembler = {
    push: push,
    pop: pop
  };
}]);