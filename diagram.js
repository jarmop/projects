var diagram = new Diagram();
diagram.draw();

function Diagram() {
  this.paper = Snap("#diagram");
  this.lineLength = 30;

  this.draw = function() {
    var squareWidth = 100;
    var squareHeight = 100;
    var padding = 50;

    this.drawGate(300, 150, 'Nand');
    this.drawInput(150, 175);

    this.drawLine(200+this.lineLength, 200, 300-this.lineLength, 175);
    this.drawLine(200+this.lineLength, 200, 300-this.lineLength, 225);
  };

  this.drawInput = function(x, y) {
    var width = 50;
    var height = 50;
    var input = this.paper.rect(x, y, width, height);
    input.attr({
      fill: "#fff",
      stroke: "#000",
      strokeWidth: 3
    });
    this.drawLine(x+width, y+width/2, x+width+this.lineLength, y+width/2);
  }

  this.drawGate = function(x, y, name) {
    var width = 100;
    var height = 100;
    var nand = this.paper.rect(x, y, width, height);
    nand.attr({
      fill: "#fff",
      stroke: "#000",
      strokeWidth: 3
    });
    this.paper.text(x+20, y+40, name);
    this.drawLine(x-this.lineLength, y+height/4, x, y+height/4);
    this.drawLine(x-this.lineLength, y+height/4*3, x, y+height/4*3);
    this.drawLine(x+width, y+height/2, x+width+this.lineLength, y+height/2);
  };

  this.drawLine = function(x1, y1, x2, y2) {
    this.paper.line(x1, y1, x2, y2).attr({stroke: '#000', strokeWidth: 3});
  }
}



