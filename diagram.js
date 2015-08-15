var diagram = new Diagram();
diagram.drawGrid();
diagram.draw();

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

  this.draw = function() {
    this.drawInput(60, 20);
    this.drawInput(60, 80);
    this.drawGate(240, 20, 'Nand');
    this.drawGate(240, 140, 'Nand');
    this.drawGate(240, 260, 'Or');
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
      this.drawLine(x-l, y+s, x, y+s),
      this.drawLine(x-l, y+5*s, x, y+5*s),
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



