var config = {
  nodeSize: 30,
  strokeWidth: 3,
  nodeDistance: 10,
  treeNodeDistanceX: 10
};

var draw = SVG('drawing').size(600, 600);

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

function drawData(data) {
  var x1 = 10 + config.nodeSize / 2;
  var y1 = 10 + config.nodeSize / 2;
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

function randomInt() {
  return Math.floor((Math.random() * 9) + 1)
}

var data = [];
for (var i = 0; i < 10; i++) {
  data.push(randomInt());
}

drawData(data);

function drawTree(data) {
  var levels = 4;
  var nodeAmountOnLastLevel = Math.pow(2, levels - 1);
  var width = nodeAmountOnLastLevel * config.nodeSize + (nodeAmountOnLastLevel - 1) * config.treeNodeDistanceX;
  console.log(width);
  var i = 0;
  var x;
  var j;
  var y = 50;
  for (var level = 0; level < 4; level++) {
    var wut = Math.pow(2, levels - level - 1);
    x = (config.nodeDistance * wut + config.nodeSize * wut) / 2;
    console.log(x);
    var dist = (config.nodeDistance * wut + config.nodeSize * wut);
    j = 0;
    while (j < Math.pow(2, level) && i < data.length) {
      drawNode(x, y, data[i]);
      // x += config.treeNodeDistanceX + config.nodeSize;
      x += dist;
      i++;
      j++
    }
    y += config.nodeDistance + config.nodeSize;
  }
}

drawTree(data);