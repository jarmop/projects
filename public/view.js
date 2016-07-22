var View = function () {
  var config = {
    nodeSize: 32,
    gridSize: 8,
    canvasWidthGrids: 60,
    canvasHeightGrids: 8,
    strokeWidth: 3,
    showGrid: false,
    gridColor: '#ddd',
    gridColorStrong: '#aaa',
    paddingGrids: 1,
    focusColor: '#595',
    blurColor: '#000',
    animationSpeed: 500
  };

  config.canvasWidth = config.canvasWidthGrids * config.gridSize;
  config.canvasHeight = config.canvasHeightGrids * config.gridSize;

  var draw = SVG('drawing').size(config.canvasWidth, config.canvasHeight);
  var arrayNodes = [];
  var focusedNodes = [];

  if (config.showGrid) {
    drawGrid();
  }

  function drawGrid() {
    var x = 0;
    var y = 0;
    for (var i = 0; i < config.canvasHeightGrids + 1; i++) {
      var color = config.gridColor;
      if (i % 4 == 0) {
        color = config.gridColorStrong;
      }
      draw.line(0, y, config.canvasWidth, y).stroke({width: 1, color: color});
      y += config.gridSize;
    }

    for (var i = 0; i < config.canvasWidthGrids + 1; i++) {
      var color = config.gridColor;
      if (i % 4 == 0) {
        color = config.gridColorStrong;
      }
      draw.line(x, 0, x, config.canvasHeight).stroke({width: 1, color: color});
      x += config.gridSize;
    }
  }

  function drawNode(x, y, value) {
    var border = draw.circle(config.nodeSize).attr({
      fill: '#fff',
      stroke: config.blurColor,
      'stroke-width': config.strokeWidth
    });
    var content = draw.text(value.toString()).attr({
      fill: config.blurColor,
      'x': 10,
      leading: 1.1
    }).font({
      size: 20,
      weight: 'bold'
    });

    var group = draw.group();
    group.add(border);
    group.add(content);
    group.x(x);
    group.y(y);

    return new Node(border, content, group);
  }

  // function drawLink(node1, node2) {
  //   console.log(node1.x());
  //   var x1 = node1.x() + config.nodeSize / 2;
  //   var y1 = node1.y() + config.nodeSize / 2;
  //   var x2 = node2.x() + config.nodeSize / 2;
  //   var y2 = node2.y() + config.nodeSize / 2;
  //   draw.line(x1,y1,x2,y2).stroke({width: config.strokeWidth});
  // }

  this.drawArray = function (data) {
    var x1 = config.paddingGrids * config.gridSize + config.nodeSize / 2;
    var y1 = config.paddingGrids * config.gridSize + config.nodeSize / 2;
    var x2 = x1 + config.gridSize + config.nodeSize;
    var y2 = y1;

    // draw lines
    for (var i = 1; i < data.length; i++) {
      draw.line(x1,y1,x2,y2).stroke({width: config.strokeWidth});
      x1 = x2;
      x2 = x1 + config.gridSize + config.nodeSize;
    }

    // draw nodes
    var x1 = config.paddingGrids * config.gridSize + config.nodeSize / 2;
    for (var i = 0; i < data.length; i++) {
      arrayNodes.push(drawNode(
        x1 - config.nodeSize / 2,
        y1 - config.nodeSize / 2,
        data[i]
      ));
      x1 += config.gridSize + config.nodeSize;
    }

    return arrayNodes;
  };

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
  //   var y = treeY * config.gridSize;
  //   var parentCoordinates = [];
  //   for (var level = 0; level < 4; level++) {
  //     // x = treeX * config.gridSize + (Math.pow(2, levels - level) - 2) * config.gridSize;
  //     x = treeX * config.gridSize + levelX[level][0] * config.gridSize;
  //     // var nodeDistanceOnCurrentLevel = (Math.pow(2, levels - level) - 1) * 2 * config.gridSize + config.nodeSize;
  //     var nodeDistanceOnCurrentLevel = levelX[level][1] * config.gridSize + config.nodeSize;
  //     var nodeAmountOnCurrentLevel = Math.pow(2, level);
  //     j = 0;
  //     while (j < nodeAmountOnCurrentLevel && i < data.length) {
  //       drawNode(x, y, data[i]);
  //       x += nodeDistanceOnCurrentLevel;
  //       i++;
  //       j++
  //     }
  //     y += config.gridSize + config.nodeSize;
  //   }
  // }

  this.focus = function (indexes) {
    // first blur previously focused nodes
    for (var i = 0; i < focusedNodes.length; i++) {
      arrayNodes[focusedNodes[i]].blur();
    }

    focusedNodes = indexes;
    for (var i = 0; i < focusedNodes.length; i++) {
      arrayNodes[focusedNodes[i]].focus();
    }
  };

  this.swap = function (indexes) {
    var node1 = arrayNodes[indexes[0]];
    var node2 = arrayNodes[indexes[1]];

    var node1X = node1.x();
    node1.animate().x(node2.x());
    node2.animate().x(node1X);

    arrayNodes[indexes[0]] = node2;
    arrayNodes[indexes[1]] = node1;
  };

  var Node = function (circle, content, group) {
    // console.log(circle);
    var circle = circle;
    var content = content;
    var group = group;

    this.focus = function () {
      // console.log(circle);
      circle.stroke(config.focusColor);
      content.fill(config.focusColor);
    };

    this.blur = function () {
      // console.log(circle);
      circle.stroke(config.blurColor);
      content.fill(config.blurColor);
    };

    this.x = function () {
      return group.x();
    };

    this.y = function () {
      return group.y();
    };

    this.animate = function () {
      return group.animate(config.animationSpeed);
    }
  };
};