var config = {
  nodeSize: 30,
  gridSize: 15,
  canvasWidthGrids: 40,
  canvasHeightGrids: 40,
  strokeWidth: 3,
  nodeDistance: 10,
  treeNodeDistanceX: 10,
  showGrid: true
};

config.canvasWidth = config.canvasWidthGrids * config.gridSize;
config.canvasHeight = config.canvasHeightGrids * config.gridSize;

var draw = SVG('drawing').size(config.canvasWidth, config.canvasHeight);

function drawGrid() {
  var x = 0;
  var y = config.gridSize;
  for (var i = 0; i < config.canvasHeightGrids; i++) {
    draw.line(0, y, config.canvasWidth, y).stroke({width: 1, color: '#aaa'});
    y += config.gridSize;
  }

  x = config.gridSize;
  for (var i = 0; i < config.canvasWidthGrids; i++) {
    draw.line(x, 0, x, config.canvasHeight).stroke({width: 1, color: '#aaa'});
    x += config.gridSize;
  }
}

function drawNode(x, y, value) {
  var circle = draw.circle(config.nodeSize).attr({
    fill: '#fff',
    stroke: '#000',
    'stroke-width': config.strokeWidth
  });
  var text = draw.text(value.toString()).attr({
    fill: "#000",
    'x': 10,
    leading: 1.1
  }).font({
    size: 20,
    weight: 'bold'
  });

  var node = draw.group();
  node.add(circle);
  node.add(text);
  node.x(x);
  node.y(y);

  return node;
}

function drawLink(node1, node2) {
  console.log(node1.x());
  var x1 = node1.x() + config.nodeSize / 2;
  var y1 = node1.y() + config.nodeSize / 2;
  var x2 = node2.x() + config.nodeSize / 2;
  var y2 = node2.y() + config.nodeSize / 2;
  draw.line(x1,y1,x2,y2).stroke({width: config.strokeWidth});
}

function drawData(data, x, y) {
  var x1 = x * config.gridSize + config.nodeSize / 2;
  var y1 = y * config.gridSize + config.nodeSize / 2;
  var x2 = x1 + config.nodeDistance + config.nodeSize;
  var y2 = y1;
  for (var i = 1; i < data.length; i++) {
    draw.line(x1,y1,x2,y2).stroke({width: config.strokeWidth});
    drawNode(
      x1 - config.nodeSize / 2,
      y1 - config.nodeSize / 2,
      data[i - 1]
    );
    x1 = x2;
    x2 = x1 + config.nodeDistance + config.nodeSize;
  }
  drawNode(
    x1 - config.nodeSize / 2,
    y1 - config.nodeSize / 2,
    data[i - 1]
  );
}

function drawTree(data, treeX, y) {
  var levels = 4;
  var nodeAmountOnLastLevel = Math.pow(2, levels - 1);
  var i = 0;
  var x;
  var j;
  y = y * config.gridSize;
  for (var level = 0; level < 4; level++) {
    x = (Math.pow(2, levels - level) - 2) * config.gridSize;
    // console.log(x);
    var nodeDistanceOnCurrentLevel = (Math.pow(2, levels - level) - 1) * 2 * config.gridSize + config.nodeSize;
    console.log(nodeDistanceOnCurrentLevel);
    // x = treeX * config.gridSize + x;
    j = 0;
    var nodeAmountOnCurrentLevel = Math.pow(2, level);
    while (j < nodeAmountOnCurrentLevel && i < data.length) {
      drawNode(x, y, data[i]);
      x += nodeDistanceOnCurrentLevel;
      i++;
      j++
    }
    y += config.gridSize + config.nodeSize;
  }
}

function randomInt() {
  return Math.floor((Math.random() * 9) + 1)
}

if (config.showGrid) {
  drawGrid();
}

var data = [];
for (var i = 0; i < 10; i++) {
  data.push(randomInt());
}

drawData(data, 1, 1);

drawTree(data, 1, 4);