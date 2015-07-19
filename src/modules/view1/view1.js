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
    activeRegisters = [];
    activeStacks = [];
  }

  // $scope.codeBlock for describing multiple code lines

  // linked list, each line points to next instruction... eip?
  $scope.code = {
    'sub:': {instruction: '', arguments: ''},
    '0x00401000': {instruction: 'push', arguments: ['ebp'], nextInstruction: '0x00401001'},
    '0x00401001': {instruction: 'mov', arguments: ['ebp','esp'], nextInstruction: '0x00401003'},
    '0x00401003': {instruction: 'mov', arguments: ['eax','0x0000BEEF'], nextInstruction: '0x00401008'},
    '0x00401008': {instruction: 'pop', arguments: ['ebp'], nextInstruction: '0x00401009'},
    '0x00401009': {instruction: 'ret', arguments: []},
    'main:': {instruction: '', arguments: []},
    '0x00401010': {instruction: 'push', arguments: ['ebp'], nextInstruction: '0x00401011'},
    '0x00401011': {instruction: 'mov', arguments: ['ebp','esp'], nextInstruction: '0x00401013'},
    '0x00401013': {instruction: 'call', arguments: ['sub'], nextInstruction: '0x00401018'},
    '0x00401018': {instruction: 'mov', arguments: ['eax','0x0000F00D'], nextInstruction: '0x0040101D'},
    '0x0040101D': {instruction: 'pop', arguments: ['ebp'], nextInstruction: '0x0040101E'},
    '0x0040101E': {instruction: 'ret', arguments: []},
  };

  var procedureStart = {sub: '0x00401000'};
  var currentLinePointer = '';

  var activeRegisters = [];
  $scope.isActiveRegister = function(name) {
    return activeRegisters.indexOf(name) !== -1;
  };

  var activeStacks = [];
  $scope.isActiveStack = function(address) {
    return activeStacks.indexOf(address) !== -1;
  };

  $scope.isActiveLine = function(address) {
    return address == currentLinePointer;
  };

  $scope.forward = function() {
    runNextLine();
  };

  $scope.backward = function() {
    // TODO
  };

  $scope.setActive = function(linePointer) {
    currentLinePointer = linePointer;
  };

  $scope.rewind = function() {
    initializeStackAndRegisters();
    currentLinePointer = '';
  };

  var description = '';
  $scope.getDescription = function() {
    return description
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
    description = '';
    currentLinePointer = $scope.registers.eip;
    var line = $scope.code[currentLinePointer];
    if (line === undefined) { return false; }
    $scope.registers.eip = line.nextInstruction;
    activeRegisters = ['eip'];
    activeStacks = [];
    assembler[line.instruction].apply(this, line.arguments);
    description += 'EIP points to next instruction.';
  }

  function push() {
    decrementESP();
    var value = arguments[0];
    var valueDescription = value;
    if (isRegister(value)) {
      var register = value;
      value = $scope.registers[register];
      activeRegisters.push(register);
      valueDescription = 'value from ' + register.toUpperCase() + ' register (' + value + ')';
    }
    $scope.stack[$scope.registers.esp] = value;
    activeStacks.push($scope.registers.esp);
    activeRegisters.push('esp');
    description += 'Push ' + valueDescription + ' on the stack. ESP register now points to this value. ';
  }

  function pop(register) {
    if (register !== undefined) {
      $scope.registers[register] = $scope.stack[$scope.registers.esp];
      activeRegisters.push(register);
      description += 'Copy value from top of the stack into ' + register.toUpperCase() + ' register. ';
    }
    activeRegisters.push('esp');
    activeStacks.push($scope.registers.esp);
    incrementESP();
    activeStacks.push($scope.registers.esp);
    description += 'Point top of the stack (ESP) to previous value. '
  }

  function mov() {
    var target = arguments[0];
    var value = arguments[1];
    var valueDescription = value;
    if (isRegister(value)) {
      var register = value;
      value = $scope.registers[register];
      activeRegisters.push(register);
      valueDescription = 'value from ' + register.toUpperCase() + ' register (' + value + ')';
    }
    description += 'Copy ' + valueDescription + ' into ' + target.toUpperCase() + ' register. ';
    $scope.registers[target] = value;
    activeRegisters.push(target);
  }

  function call() {
    push($scope.registers.eip);
    var procedure = arguments[0];
    $scope.registers.eip = procedureStart[procedure];
  }

  function ret() {
    pop('eip');
  }

  var assembler = {
    push: push,
    pop: pop,
    mov: mov,
    call: call,
    ret: ret
  };
}]);