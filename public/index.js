// visual sort algo class, jonka perii bubble ja heap
// aja sorttaus kerran läpi ja tallenna swapit, tallennusta voi sitten ajaa edestakaisin

var config = {
  nodeSize: 32,
  gridSize: 8,
  canvasWidthGrids: 60,
  canvasHeightGrids: 8,
  strokeWidth: 3,
  showGrid: true,
  gridColor: '#ddd',
  gridColorStrong: '#aaa',
};

config.canvasWidth = config.canvasWidthGrids * config.gridSize;
config.canvasHeight = config.canvasHeightGrids * config.gridSize;

var draw = SVG('drawing').size(config.canvasWidth, config.canvasHeight);

function drawGrid() {
  var x = 0;
  var y = 0;
  for (var i = 0; i < config.canvasHeightGrids + 1; i++) {
    var color = config.gridColor;
    if (i % 4 == 0) {
      console.log(i);
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

class Node {

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
  var arrayNodes = [];

  var x1 = x * config.gridSize + config.nodeSize / 2;
  var y1 = y * config.gridSize + config.nodeSize / 2;
  var x2 = x1 + config.gridSize + config.nodeSize;
  var y2 = y1;

  // draw lines
  for (var i = 1; i < data.length; i++) {
    draw.line(x1,y1,x2,y2).stroke({width: config.strokeWidth});
    x1 = x2;
    x2 = x1 + config.gridSize + config.nodeSize;
  }

  // draw nodes
  var x1 = x * config.gridSize + config.nodeSize / 2;
  for (var i = 0; i < data.length; i++) {
    arrayNodes.push(drawNode(
      x1 - config.nodeSize / 2,
      y1 - config.nodeSize / 2,
      data[i]
    ));
    x1 += config.gridSize + config.nodeSize;
  }

  return arrayNodes;
}



function drawTree(data, treeX, treeY) {

  var levelX = [
    [21, 30],
    [9, 20],
    [3, 8],
    [0, 2]
  ];

  var levels = 4;
  var nodeAmountOnLastLevel = Math.pow(2, levels - 1);
  var i = 0;
  var x;
  var j;
  var y = treeY * config.gridSize;
  var parentCoordinates = [];
  for (var level = 0; level < 4; level++) {
    // x = treeX * config.gridSize + (Math.pow(2, levels - level) - 2) * config.gridSize;
    x = treeX * config.gridSize + levelX[level][0] * config.gridSize;
    // var nodeDistanceOnCurrentLevel = (Math.pow(2, levels - level) - 1) * 2 * config.gridSize + config.nodeSize;
    var nodeDistanceOnCurrentLevel = levelX[level][1] * config.gridSize + config.nodeSize;
    var nodeAmountOnCurrentLevel = Math.pow(2, level);
    j = 0;
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

var swapCount;

function swapNodes(node1, node2, callback) {
  console.log('swap');
  swapCount++;
  // console.log('jgf');
  var node1X = node1.x();
  node1.animate(500).x(node2.x());
  node2.animate(500).x(node1X);

}

function sort(data, dataArray, i) {
  if (i >= data.length) {
    return;
  }

  if (data[i - 1] > data[i]) {
    var temp = data[i - 1];
    data[i - 1] = data[i];
    data[i] = temp;
    swapNodes(dataArray[i - 1], dataArray[i], function () {
      sort(data, dataArray, ++i);
    });
    //   .after(sort(
    //   data, dataArray, ++i
    // ));
  } else {
    sort(
      data, dataArray, ++i
    )
  }
}

function bubbleSort(data, dataArray) {
  swapCount = 1;
  while (swapCount > 0) {
    swapCount = 0;
    sort(data, dataArray, 1);
    // console.log(swapCount);
  }
  // for (var i = 1; i < data.length; i++) {
  //   if (data[i - 1] > data[i]) {
  //     var temp = data[i - 1];
  //     data[i - 1] = data[i];
  //     data[i] = temp;
  //     swapNodes(dataArray[i - 1], dataArray[i]);
  //   }
  // }
}

if (config.showGrid) {
  drawGrid();
}

var data = [];
for (var i = 0; i < 10; i++) {
  data.push(randomInt());
}

var dataArray = drawData(data, 1, 1);
console.log(dataArray[0]);

// swapNodes(dataArray[0], dataArray[1]);

// bubbleSort(data, dataArray);

// drawTree(data, 1, 8);


var i = 1;
function bubbleSortStep() {
  // dataArray[i].fill('#555');
  if (i >= data.length) {
    i = 1;
  }
  if (data[i - 1] > data[i]) {
    var temp = data[i - 1];
    data[i - 1] = data[i];
    data[i] = temp;
    swapNodes(dataArray[i - 1], dataArray[i]);
    var temp = dataArray[i - 1];
    dataArray[i - 1] = dataArray[i];
    dataArray[i] = temp;
  }
  i++;
}

// bootstrap the demo
new Vue({
  el: 'body',
  // data: {
  //   newLabel: '',
  //   stats: stats
  // },
  methods: {
    forward: function (e) {
      bubbleSortStep();
    }
  }
});
     