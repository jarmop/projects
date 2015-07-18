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

  // linked list, each line points to next instruction... eip?
  $scope.code = {
    'sub:': {instruction: '', arguments: '', description: ''},
    '0x00401000': {instruction: 'push', arguments: ['ebp'], description: 'tälläainen laini', nextInstruction: '0x00401001'},
    '0x00401001': {instruction: 'mov', arguments: ['ebp','esp'], description: '', nextInstruction: '0x00401003'},
    '0x00401003': {instruction: 'mov', arguments: ['eax','0x0000BEEF'], description: '', nextInstruction: '0x00401008'},
    '0x00401008': {instruction: 'pop', arguments: ['ebp'], description: '', nextInstruction: '0x00401009'},
    '0x00401009': {instruction: 'ret', arguments: [], description: ''},
    'main:': {instruction: '', arguments: [], description: ''},
    '0x00401010': {instruction: 'push', arguments: ['ebp'], description: '', nextInstruction: '0x00401011'},
    '0x00401011': {instruction: 'mov', arguments: ['ebp','esp'], description: '', nextInstruction: '0x00401013'},
    '0x00401013': {instruction: 'call', arguments: ['sub'], description: '', nextInstruction: '0x00401018'},
    '0x00401018': {instruction: 'mov', arguments: ['eax','0x0000F00D'], description: '', nextInstruction: '0x0040101D'},
    '0x0040101D': {instruction: 'pop', arguments: ['ebp'], description: '', nextInstruction: '0x0040101E'},
    '0x0040101E': {instruction: 'ret', arguments: [], description: ''},
  };

  var procedureStart = {sub: '0x00401000'};
  var currentLine = '';

  $scope.isActiveLine = function(address) {
    return address == currentLine;
  };

  $scope.forward = function() {
    runNextLine();
  };

  $scope.backward = function() {
    // TODO
  };

  $scope.setActive = function(linePointer) {
    currentLine = linePointer;
  };

  $scope.restart = function() {
    initializeStackAndRegisters();
    $scope.forward();
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

  function runNextLine() {
    currentLine = $scope.registers.eip;
    var line = $scope.code[currentLine];
    $scope.registers.eip = line.nextInstruction;
    assembler[line.instruction].apply(this, line.arguments);
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