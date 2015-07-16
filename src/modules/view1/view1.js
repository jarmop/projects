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

  $scope.code = [
    {code: 'sub:', description: ''},
    {code: '00401000  push      ebp', description: 'tälläainen laini', instruction: push, argument: 'ebp'},
    {code: '00401001  mov       ebp,esp', description: ''},
    {code: '00401003  mov       eax,0BEEFh', description: ''},
    {code: '00401008  pop       ebp', description: ''},
    {code: '00401009  ret', description: ''},
    {code: 'main:', description: ''},
    {code: '00401010  push      ebp', description: '', instruction: push, argument: 'ebp'},
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

  function push(value) {
    decrementESP();
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
    if (isRegister(line.argument)) {
      line.argument = $scope.registers[line.argument];
    }
    line.instruction(line.argument);
  }

  function setLinePointer(value) {
    linePointer = value;
    runLine(linePointer);
  }
}]);