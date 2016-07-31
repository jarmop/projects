import * as React from "react";
import * as ReactDOM from "react-dom";

import {View} from './view';
import {BubbleSort} from './bubble-sort';
import {Player} from './player';
import {Dashboard} from './react-view';

(function () {
  function randomInt() {
    return Math.floor((Math.random() * 9) + 1)
  }

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

  ReactDOM.render(
    <Dashboard player={player}/>,
    document.getElementById('dashboard')
  );
}) ();


