(function () {
  var view = new View();

  var data = [];
  for (var i = 0; i < 10; i++) {
    data.push(randomInt());
  }
  view.drawArray(data);



  var bubbleSort = new BubbleSort();
  var film = bubbleSort.sort(data);

  // var film = [
  //   {
  //     focus: [0,1]
  //   },
  //   {
  //     blur: [0,1],
  //     focus: [1,2]
  //   },
  //   {
  //     swap: [1,2]
  //   },
  //   {
  //     blur: [1,2],
  //     focus: [2,3]
  //   }
  // ];
  
  var player = new Player(film, view);

  initDashBoard();  

  function randomInt() {
    return Math.floor((Math.random() * 9) + 1)
  }

  function initDashBoard() {
    new Vue({
      el: 'body',
      data: {
        enabled: true
      },
      methods: {
        play: function () {
          player.play();
        },
        forward: function (e) {
          if (!this.enabled) {
            return;
          }
          this.enabled = false;
          player.forward().then(() => this.enabled = true);
        },
        backward: function (e) {
          if (!this.enabled) {
            return;
          }
          this.enabled = false;
          player.backward().then(() => this.enabled = true);
        }
      }
    });
  }
}) ();
     