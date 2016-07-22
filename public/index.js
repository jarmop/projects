(function () {
  var view = new View();

  var data = [];
  for (var i = 0; i < 10; i++) {
    data.push(randomInt());
  }
  var dataArray = view.drawArray(data);

  // var bubbleSort = new BubbleSort(data, dataArray);
  // var film = bubbleSort.sort(data);

  var film = [
    {
      focus: [0,1]
    },
    {
      focus: [1,2],
      swap: true
    },
    {
      focus: [2,3]
    }
  ];
  
  var player = new Player(film, view);

  initDashBoard();  

  function randomInt() {
    return Math.floor((Math.random() * 9) + 1)
  }

  function initDashBoard() {
    new Vue({
      el: 'body',
      methods: {
        forward: function (e) {
          player.forward();
        },
        backward: function (e) {
          player.backward();
        }
      }
    });
  }
}) ();
     