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