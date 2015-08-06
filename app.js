function nand(in1, in2) {
  if (in1 == in2 == 0) {
    return 1;
  } else {
    return false;
  }
}

/*function not(in1) {
  return nand(in1, in1);
}*/

function and(in1, in2) {
  return nand(not(in1), not(in2));
}

function orGate(in1, in2) {

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

var inputs = getTestInputs(3);

for(var i=0; i<inputs.length; i++) {
  console.log(inputs[i]);
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

var squareWidth = 100;
var squareHeight = 100;
var padding = 50;

var diagram = [
  [],
  []
];

// First lets create our drawing surface out of existing SVG element
// If you want to create new surface just provide dimensions
var paper = Snap("#diagram");
//var s = Snap("#svg");
// Lets create big circle in the middle:
var nand = paper.rect(150, 150, 100, 100);
// By default its black, lets change its attributes
nand.attr({
  fill: "#bada55",
  stroke: "#000",
  strokeWidth: 3
});

var nand2 = paper.rect(300, 150, 100, 100);
// By default its black, lets change its attributes
nand2.attr({
  fill: "#bada55",
  stroke: "#000",
  strokeWidth: 3
});

paper.line(250, 200, 300, 200).attr({stroke: '#000', strokeWidth: 3});

paper.text(200, 200, 'NAND');
