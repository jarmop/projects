var diagram = new Diagram();

function Input(x, y) {
  this.x = x;
  this.y = y;
  this.type = 'input';
}
function Gate(x, y, type, inputs) {
  this.x = x;
  this.y = y;
  this.type = type;
  this.inputs = inputs;
}
function getGate(x, y, type, inputs) {
  return new Gate(x, y, type, inputs);
}
function Line(points) {
  this.points = points;
}
var elements = {
  inputs: [
    //new Input(60, 60),
    //new Input(60, 120)
  ],
  gates: [
    new Gate(240, 60, 'and',[new Input(60, 60)]),
    new Gate(240, 200, 'and',[new Input(60, 120)]),
    new Gate(240, 320, 'or',[new Input(60, 180)])
  ],
  lines: [
    //[120, 80, 220, 80],
  ],
};

diagram.draw(elements);

function Diagram() {
  this.paper = Snap("#diagram");
  this.lineLength = 50;
  this.strokeWidth = 2;
  // square size
  var s = 10;
  // line length
  var l = 2*s;

  this.drawGateObject = function(gate) {
    this.drawGate(gate.x, gate.y,gate.type);
    for (var i=0; i<gate.inputs.length; i++) {
      if (gate.inputs[i].type = 'input') {
        this.drawInput(gate.inputs[i].x, gate.inputs[i].y);
      } else {
        this.drawGateObject(gate.inputs[i]);
      }
    }
  }

  this.draw = function(elements) {
    this.drawGrid();
    for (var i=0; i<elements.gates.length; i++) {
      this.drawGateObject(elements.gates[i]);
    }
    for (var i=0; i<elements.lines.length; i++) {
      this.drawPolyline(elements.lines[i]);
    }
  };

  this.drawGrid = function() {
    var gridLineStroke = '#eee';
    var gridLinewidth = 2;
    for (var i = 3*s; i < 600; i += s) {
      if (i % 100 == 0) {
        this.paper.text(0, i+s/4, i/s).attr({'font-size':12});
      }
      this.paper.line(2*s, i, 600, i).attr({stroke: gridLineStroke, strokeWidth: gridLinewidth});
    }
    for (var i = 3*s; i < 600; i += s) {
      if (i % 100 == 0) {
        this.paper.text(i-s/4, s, i/s).attr({'font-size':12});
      }
      this.paper.line(i, 2*s, i, 600).attr({stroke: gridLineStroke, strokeWidth: gridLinewidth});
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

  this.drawPolyline = function(points) {
    return this.paper.polyline(points).attr({stroke: '#000', strokeWidth: this.strokeWidth});
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



