var diagram = new Diagram();

function Element(x,y,type) {
  this.x = x;
  this.y = y;
  this.type = type;
}
var elements = [
  new Element(60, 20, 'input'),
  new Element(60, 80, 'input'),
  new Element(240, 20, 'and'),
  new Element(240, 140, 'and'),
  new Element(240, 260, 'or')
];

diagram.draw(elements);

function Diagram() {
  this.paper = Snap("#diagram");
  this.lineLength = 50;
  this.strokeWidth = 2;
  // square size
  var s = 10;
  // line length
  var l = 2*s;

  this.drawGrid = function() {
    var gridLineStroke = '#eee';
    var gridLinewidth = 2;
    for (var i = s; i < 600; i += s) {
      this.paper.line(0, i, 600, i).attr({stroke: gridLineStroke, strokeWidth: gridLinewidth});
    }
    for (var i = s; i < 600; i += s) {
      this.paper.line(i, 0, i, 600).attr({stroke: gridLineStroke, strokeWidth: gridLinewidth});
    }
  };

  this.draw = function(elements) {
    this.drawGrid();
    for (var i=0; i<elements.length; i++) {
      if (elements[i].type == 'input') {
        this.drawInput(elements[i].x, elements[i].y);
      } else {
        this.drawGate(elements[i].x, elements[i].y, elements[i].type);
      }
    }
  };

  this.drawInput = function(x, y) {
    var size = 4*s;
    this.paper.group(
      this.paper.rect(x, y, size, size)
        .attr({
          fill: "#fff",
          stroke: "#000",
          strokeWidth: this.strokeWidth
        }),
      this.drawLine(x+size, y+size/2, x+size+l, y+size/2)
    ).drag(diagram.move, diagram.start, diagram.stop);
  };

  this.drawGate = function(x, y, name) {
    var width = 6*s;
    var height = 6*s;
    this.paper.group(
      this.paper.rect(x, y, width, height)
        .attr({
          fill: "#fff",
          stroke: "#000",
          strokeWidth: this.strokeWidth
        }),
      this.paper.text(x +.5*s, y+1.5*s, name),
      this.drawLine(x-l, y+2*s, x, y+2*s),
      this.drawLine(x-l, y+4*s, x, y+4*s),
      this.drawLine(x+width, y+height/2, x+width+l, y+height/2)
    ).drag(diagram.move, diagram.start, diagram.stop);
  };

  this.drawLine = function(x1, y1, x2, y2) {
    return this.paper.line(x1, y1, x2, y2).attr({stroke: '#000', strokeWidth: this.strokeWidth});
  };

  this.drawSplit = function(x, y) {
    this.paper.circle(x, y, 5);
  };

  this.move = function(dx,dy,x,y) {
    dx = Math.round(dx / s)*s;
    dy = Math.round(dy / s)*s;
    this.attr({
      transform: this.data('origTransform') + (this.data('origTransform') ? "T" : "t") + [dx, dy]
    });
  };

  this.start = function( x, y, ev) {
    this.data('origTransform', this.transform().local );
  };

  this.stop = function() {
  };
}



