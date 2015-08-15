var diagram = new Diagram();
diagram.drawGrid();
diagram.draw();

function Diagram() {
  this.paper = Snap("#diagram");
  this.lineLength = 50;
  this.strokeWidth = 2;
  this.padding = 20;

  this.drawGrid = function() {
    var gridLineStroke = '#ddd';
    var gridLinewidth = 2;
    for (var i = this.padding; i < 600; i += this.padding) {
      this.paper.line(0, i, 600, i).attr({stroke: gridLineStroke, strokeWidth: gridLinewidth});
    }
    for (var i = this.padding; i < 600; i += this.padding) {
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
    var size = 2*this.padding;
    this.paper.group(
      this.paper.rect(x, y, size, size)
        .attr({
          fill: "#fff",
          stroke: "#000",
          strokeWidth: this.strokeWidth
        }),
      this.drawLine(x+size, y+size/2, x+size+this.lineLength, y+size/2)
    ).drag(diagram.move, diagram.start, diagram.stop);
  };

  this.drawGate = function(x, y, name) {
    var size = 4*this.padding;
    this.paper.group(
      this.paper.rect(x, y, size, size)
        .attr({
          fill: "#fff",
          stroke: "#000",
          strokeWidth: this.strokeWidth
        }),
      this.paper.text(x+20, y+40, name),
      this.drawLine(x-this.lineLength, y+size/4, x, y+size/4),
      this.drawLine(x-this.lineLength, y+size/4*3, x, y+size/4*3),
      this.drawLine(x+size, y+size/2, x+size+this.lineLength, y+size/2)
    ).drag(diagram.move, diagram.start, diagram.stop);
  };

  this.drawLine = function(x1, y1, x2, y2) {
    return this.paper.line(x1, y1, x2, y2).attr({stroke: '#000', strokeWidth: this.strokeWidth});
  };

  this.drawSplit = function(x, y) {
    this.paper.circle(x, y, 5);
  };

  this.move = function(dx,dy,x,y) {
    dx = Math.round(dx / 20)*20;
    dy = Math.round(dy / 20)*20;
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



