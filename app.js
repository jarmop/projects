angular.module('gateSimulator', [])
  .controller('truthTableController', function() {
    var truthTable = this;
    truthTable.values = [
      [0,0,0],
      [0,1,1]
    ];


  });

function nand(inputs) {
  var output = 0;
  inputs.some(function(input) {
    if (input == 0) {
      output = 1;
    }
  });
  return output;
}

function fillInputs(inputs, ia, limit) {
  for (var i=0; i<2; i++) {
    ia.push(i);
    if (ia.length < limit) {
      inputs = fillInputs(inputs, ia, limit);
    } else {
      inputs.push(ia.slice(0));
    }
    ia.pop();
  }
  return inputs;
}

function getTestInputs(limit) {
  var inputs = fillInputs([], [], limit);
  return inputs;
}

var inputs = getTestInputs(2);

for(var i=0; i<inputs.length; i++) {
  console.log(inputs[i]);
  console.log(nand(inputs[i]));
}

