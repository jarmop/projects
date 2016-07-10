var config = {
  nodeHeight: 30,
  strokeWidth: 3,
  nodeDistance: 10
};

var draw = SVG('drawing').size(600, 600);

function drawNode(x, y, value) {
  var circle = draw.circle(config.nodeHeight).attr({
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
  var x1 = node1.x() + config.nodeHeight / 2;
  var y1 = node1.y() + config.nodeHeight / 2;
  var x2 = node2.x() + config.nodeHeight / 2;
  var y2 = node2.y() + config.nodeHeight / 2;
  draw.line(x1,y1,x2,y2).stroke({width: config.strokeWidth});
}

function drawData(data) {
  var x1 = 10 + config.nodeHeight / 2;
  var y1 = 10 + config.nodeHeight / 2;
  var x2 = x1 + config.nodeDistance + config.nodeHeight;
  var y2 = y1;
  for (var i = 1; i < data.length; i++) {
    draw.line(x1,y1,x2,y2).stroke({width: config.strokeWidth});
    drawNode(
      x1 - config.nodeHeight / 2,
      y1 - config.nodeHeight / 2,
      data[i - 1]
    );
    x1 = x2;
    x2 = x1 + config.nodeDistance + config.nodeHeight;
  }
  drawNode(
    x1 - config.nodeHeight / 2,
    y1 - config.nodeHeight / 2,
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