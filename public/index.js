// visual sort algo class, jonka perii bubble ja heap
// aja sorttaus kerran läpi ja tallenna swapit, tallennusta voi sitten ajaa edestakaisin

(function () {
  var config = {
    nodeSize: 32,
    gridSize: 8,
    canvasWidthGrids: 60,
    canvasHeightGrids: 8,
    strokeWidth: 3,
    showGrid: true,
    gridColor: '#ddd',
    gridColorStrong: '#aaa'
  };

  function randomInt() {
    return Math.floor((Math.random() * 9) + 1)
  }

  var data = [];
  for (var i = 0; i < 10; i++) {
    data.push(randomInt());
  }

  var view = new View(config);


  var dataArray = view.drawData(data, 1, 1);
// console.log(dataArray[0]);


// swapNodes(dataArray[0], dataArray[1]);

// bubbleSort(data, dataArray);

// drawTree(data, 1, 8);

  var bubbleSort = new BubbleSort(data, dataArray);

// bootstrap the demo
  new Vue({
    el: 'body',
    // data: {
    //   newLabel: '',
    //   stats: stats
    // },
    methods: {
      forward: function (e) {
        bubbleSort.step();
      }
    }
  });
}) ();
     