import {View} from './view';
import {BubbleSort} from './bubble-sort';
import {Player} from './player';

declare var Vue:any;

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
    var enabled = true;
    var enable = () => enabled = true;
    var disable = () => enabled = false;

    function updateStats() {
      let filmActions = player.getFilmActions();
      vue.comparisons = filmActions.comparisons;
      vue.swaps = filmActions.swaps;
    }

    function play() {
      return player.forward().then(
        () => {
          updateStats();
          (new Promise((resolve, reject) => {
            setTimeout(() => {resolve()}, 200);
          })).then(() => play());
        },
        () => Promise.resolve()
      );
    }

    var vue = new Vue({
      el: 'body',
      data: {
        comparisons: 0,
        swaps: 0
      },
      methods: {
        play: function () {
          play().then(() => enable(), () => enable());
        },
        forward: function (e) {
          if (!enabled) {
            return;
          }
          disable();
          player.forward().then(() => {
            updateStats();
            enable();
          }, () => enable());
        },
        backward: function (e) {
          if (!enabled) {
            return;
          }
          disable();
          player.backward().then(() => {
            updateStats();
            enable();
          }, () => enable());
        }
      }
    });
  }

  function showStats() {

  }
}) ();
     