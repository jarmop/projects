//var inputs = [];
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


function nand(inputs) {
  var output = 0;
  inputs.some(function(input) {
    if (input == 0) {
      output = 1;
    }
  });
  return output;
}

var not = {
  in: 'in',
  out: 'out',
  nand: {
    in: ['in', 'in'],
    out: 'out'
  }
};

function Gate(name, minInputs, maxInputs) {
  this.in = 0;
  this.out = 0;
  this.getValue = function(inputs) {
    return this.out;
  }
  this.getAmountOfInputs = function() {
    return inputs;
  }
}

var not = new Gate('not', 1, 1);
inputs = [];
for (var i=0; i < not.getAmountOfInputs(); i++) {
  inputs[i] = [0,1];
}

output = [];
for(input in inputs) {
  for(inp in input) {

  }
  output.push({
    input: input,
    output: not.getValue(input)
  });

  not.getValue(input);
}


var out = not.getValue(0);

function out(input) {
  this.input = input;
  this.getValue = function() {
    this.input.getValue();
  }
}

var not = [
  {
    type: 'input',
    name: 'in1',
    targets: ['nand1', 'nand1']
  },
  {
    type: 'nand',
    name: 'nand1',
    inputs: ['in1', 'in1']
  }
];



