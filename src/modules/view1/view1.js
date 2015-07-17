'use strict';

angular.module('myApp.view1', ['ngRoute'])

.config(['$routeProvider', function($routeProvider) {
  $routeProvider.when('/view1', {
    templateUrl: 'view1.html',
    controller: 'View1Ctrl'
  });
}])

.controller('View1Ctrl', ['$scope', 'Tax', function($scope, Tax) {
  var initialStack = {
    '0x0012FF6C': '0x004012E8',
    '0x0012FF68': '',
    '0x0012FF64': '',
    '0x0012FF60': '',
    '0x0012FF5C': '',
    '0x0012FF58': '',
  };

  var initialRegisters = {
    eax: '0x003435C0',
    ebp: '0x0012FFB8',
    esp: '0x0012FF6C',
    eip: '0x00401010'
  };

  initializeStackAndRegisters();

  function initializeStackAndRegisters() {
    jQuery.extend(true, $scope.stack = {}, initialStack);
    jQuery.extend(true, $scope.registers = {}, initialRegisters);
  }

  // $scope.codeBlock for describing multiple code lines

  $scope.code = {
    'sub:': {instruction: '', arguments: '', description: ''},
    '0x00401000': {instruction: 'push', arguments: ['ebp'], description: 'tälläainen laini'},
    '0x00401001': {instruction: 'mov', arguments: ['ebp','esp'], description: ''},
    '0x00401003': {instruction: 'mov', arguments: ['eax','0x0000BEEF'], description: ''},
    '0x00401008': {instruction: 'pop', arguments: ['ebp'], description: ''},
    '0x00401009': {instruction: 'ret', arguments: [], description: ''},
    'main:': {instruction: '', arguments: [], description: ''},
    '0x00401010': {instruction: 'push', arguments: ['ebp'], description: ''},
    '0x00401011': {instruction: 'mov', arguments: ['ebp','esp'], description: ''},
    '0x00401013': {instruction: 'call', arguments: ['sub'], description: ''},
    '0x00401018': {instruction: 'mov', arguments: ['eax','0x0000F00D'], description: ''},
    '0x0040101D': {instruction: 'pop', arguments: ['ebp'], description: ''},
    '0x0040101E': {instruction: 'ret', arguments: [], description: ''},
  };

  var procedureStart = {sub: '0x00401000'};

  var runningOrder = ['0x00401010','0x00401011','0x00401013','0x00401000','0x00401001','0x00401003','0x00401008','0x00401009','0x00401018','0x0040101D','0x0040101E'];
  var linePointer = 0;
  $scope.isActiveLine = function(address) {
    return address == runningOrder[linePointer];
  };

  $scope.forward = function() {
    if (linePointer < (runningOrder.length - 1)) {
      setLinePointer(runningOrder.indexOf($scope.registers.eip));
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

  $scope.restart = function() {
    initializeStackAndRegisters();
    setLinePointer(0);
  };

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

  function getNextInstructionAddress() {
    return runningOrder[linePointer + 1];
  }

  function setLinePointer(value) {
    linePointer = value;
    $scope.registers.eip = getNextInstructionAddress();
    runLine(linePointer);
  }

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

  function mov() {
    var target = arguments[0];
    var value = arguments[1];
    if (isRegister(value)) {
      value = $scope.registers[value];
    }
    $scope.registers[target] = value;
  }

  function call() {
    // push next instruction to stack for ret
    var procedure = arguments[0];
    $scope.registers.eip = procedureStart[procedure];
  }

  var assembler = {
    push: push,
    pop: pop,
    mov: mov,
    call: call
  };
}]);