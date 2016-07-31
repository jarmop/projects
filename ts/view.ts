declare var SVG:any;

export class View {
  config = {
    nodeSize: 32,
    gridSize: 8,
    canvasWidth: 0,
    canvasHeight: 0,
    canvasWidthGrids: 60,
    canvasHeightGrids: 8,
    strokeWidth: 3,
    showGrid: false,
    gridColor: '#ddd',
    gridColorStrong: '#aaa',
    paddingGrids: 1,
    focusColor: '#5e5',
    blurColor: '#000',
    animationSpeed: 500
  };

  draw;
  arrayNodes = [];

  constructor() {
    this.config.canvasWidth = this.config.canvasWidthGrids * this.config.gridSize;
    this.config.canvasHeight = this.config.canvasHeightGrids * this.config.gridSize;
    this.draw = SVG('drawing').size(this.config.canvasWidth, this.config.canvasHeight);
    if (this.config.showGrid) {
      this.drawGrid();
    }
  }

  drawGrid() {
    var x = 0;
    var y = 0;
    for (var i = 0; i < this.config.canvasHeightGrids + 1; i++) {
      var color = this.config.gridColor;
      if (i % 4 == 0) {
        color = this.config.gridColorStrong;
      }
      this.draw.line(0, y, this.config.canvasWidth, y).stroke({width: 1, color: color});
      y += this.config.gridSize;
    }

    for (var i = 0; i < this.config.canvasWidthGrids + 1; i++) {
      var color = this.config.gridColor;
      if (i % 4 == 0) {
        color = this.config.gridColorStrong;
      }
      this.draw.line(x, 0, x, this.config.canvasHeight).stroke({width: 1, color: color});
      x += this.config.gridSize;
    }
  }

  drawNode(x, y, value) {
    var border = this.draw.circle(this.config.nodeSize).attr({
      fill: '#fff',
      stroke: this.config.blurColor,
      'stroke-width': this.config.strokeWidth
    });
    var content = this.draw.text(value.toString()).attr({
      fill: this.config.blurColor,
      'x': 10,
      leading: 1.1
    }).font({
      size: 20,
      weight: 'bold'
    });

    var group = this.draw.group();
    group.add(border);
    group.add(content);
    group.x(x);
    group.y(y);

    return new ViewNode(border, content, group);
  }

  drawArray(data) {
    var x1 = this.config.paddingGrids * this.config.gridSize + this.config.nodeSize / 2;
    var y1 = this.config.paddingGrids * this.config.gridSize + this.config.nodeSize / 2;
    var x2 = x1 + this.config.gridSize + this.config.nodeSize;
    var y2 = y1;

    // draw lines
    for (var i = 1; i < data.length; i++) {
      this.draw.line(x1,y1,x2,y2).stroke({width: this.config.strokeWidth});
      x1 = x2;
      x2 = x1 + this.config.gridSize + this.config.nodeSize;
    }

    // draw nodes
    var x1 = this.config.paddingGrids * this.config.gridSize + this.config.nodeSize / 2;
    for (var i = 0; i < data.length; i++) {
      this.arrayNodes.push(this.drawNode(
        x1 - this.config.nodeSize / 2,
        y1 - this.config.nodeSize / 2,
        data[i]
      ));
      x1 += this.config.gridSize + this.config.nodeSize;
    }
  }

  // function drawTree(data, treeX, treeY) {
  //
  //   var levelX = [
  //     [21, 30],
  //     [9, 20],
  //     [3, 8],
  //     [0, 2]
  //   ];
  //
  //   var levels = 4;
  //   var nodeAmountOnLastLevel = Math.pow(2, levels - 1);
  //   var i = 0;
  //   var x;
  //   var j;
  //   var y = treeY * this.config.gridSize;
  //   var parentCoordinates = [];
  //   for (var level = 0; level < 4; level++) {
  //     // x = treeX * this.config.gridSize + (Math.pow(2, levels - level) - 2) * this.config.gridSize;
  //     x = treeX * this.config.gridSize + levelX[level][0] * this.config.gridSize;
  //     // var nodeDistanceOnCurrentLevel = (Math.pow(2, levels - level) - 1) * 2 * this.config.gridSize + this.config.nodeSize;
  //     var nodeDistanceOnCurrentLevel = levelX[level][1] * this.config.gridSize + this.config.nodeSize;
  //     var nodeAmountOnCurrentLevel = Math.pow(2, level);
  //     j = 0;
  //     while (j < nodeAmountOnCurrentLevel && i < data.length) {
  //       drawNode(x, y, data[i]);
  //       x += nodeDistanceOnCurrentLevel;
  //       i++;
  //       j++
  //     }
  //     y += this.config.gridSize + this.config.nodeSize;
  //   }
  // }

  focus(indexes) : Promise<void> {
    for (var i = 0; i < indexes.length; i++) {
      this.arrayNodes[indexes[i]].focus();
    }
    return Promise.resolve();
  }

  blur(indexes) : Promise<void> {
    for (var i = 0; i < indexes.length; i++) {
      this.arrayNodes[indexes[i]].blur();
    }
    return Promise.resolve();
  }

  swap(indexes) {
    var node1 = this.arrayNodes[indexes[0]];
    var node2 = this.arrayNodes[indexes[1]];

    this.arrayNodes[indexes[0]] = node2;
    this.arrayNodes[indexes[1]] = node1;

    var node1X = node1.x();
    return Promise.all([
      new Promise(function (resolve, reject) {
        node1.animate().x(node2.x()).after(function () {
          resolve();
        });
      }),
      new Promise(function (resolve, reject) {
        node2.animate().x(node1X).after(function () {
          resolve();
        });
      })
    ]);
  }

  reDrawArray(data) {
    let i = 0;
    for (let node of this.arrayNodes) {
      node.content.text(data[i].toString());
      node.blur();
      i++;
    }
  }
}

class ViewNode {
  circle;
  content;
  group;

  constructor(circle, content, group) {
    this.circle = circle;
    this.content = content;
    this.group = group;
  }

  focus () {
    this.circle.fill('#5e5');
  };

  blur() {
    this.circle.fill('#fff');
  };

  x() {
    return this.group.x();
  };

  y() {
    return this.group.y();
  };

  animate() {
    return this.group.animate(500);
  }
}