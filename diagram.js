var diagram = new Diagram();
diagram.drawGrid();
diagram.draw();

var circle = diagram.paper.rect(60,60,60,60);

var move = function(dx,dy,x,y) {
  dx = Math.round(dx / 20)*20;
  dy = Math.round(dy / 20)*20;
  this.attr({
    transform: this.data('origTransform') + (this.data('origTransform') ? "T" : "t") + [dx, dy]
  });

  console.log(this.attr('transform'));
}

var start = function( x, y, ev) {
  console.log('start');
  /*if( (typeof x == 'object') && ( x.type == 'touchstart') ) {
    x.preventDefault();
    this.data('ox', x.changedTouches[0].clientX );
    this.data('oy', x.changedTouches[0].clientY );
  }*/
  this.data('origTransform', this.transform().local );
}
var stop = function() {
  console.log('stop');
}

/*rect.touchstart( start );
rect.touchmove( move );
rect.touchend( stop );*/

circle.drag(move, start, stop )

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
    var padding = 50;

    this.drawGate(325, 10, 'Nand');
    this.drawInput(150, 35);
    this.drawGate(325, 150, 'Nand');
    this.drawInput(150, 175);
    this.drawGate(525, 80, 'Or');
  };

  this.drawInput = function(x, y) {
    var size = 2*this.padding;
    var input = this.paper.rect(x, y, size, size);
    input.attr({
      fill: "#fff",
      stroke: "#000",
      strokeWidth: this.strokeWidth
    });
    this.drawLine(x+size, y+size/2, x+size+this.lineLength, y+size/2);
  };

  this.drawGate = function(x, y, name) {
    var size = 4*this.padding;
    var nand = this.paper.rect(x, y, size, size);
    nand.attr({
      fill: "#fff",
      stroke: "#000",
      strokeWidth: this.strokeWidth
    });
    this.paper.text(x+20, y+40, name);
    this.drawLine(x-this.lineLength, y+size/4, x, y+size/4);
    this.drawLine(x-this.lineLength, y+size/4*3, x, y+size/4*3);
    this.drawLine(x+size, y+size/2, x+size+this.lineLength, y+size/2);
  };

  this.drawLine = function(x1, y1, x2, y2) {
    this.paper.line(x1, y1, x2, y2).attr({stroke: '#000', strokeWidth: this.strokeWidth});
  };

  this.drawSplit = function(x, y) {
    this.paper.circle(x, y, 5);
  };
}



