import * as React from "react";
import * as ReactDOM from "react-dom";

import {View} from './view';
import {BubbleSort} from './bubble-sort';
import {Player} from './player';
import {Dashboard} from './dashboard';
import {Statistics} from "./statistics";

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
  //     focus: [0,1],
  //     increaseComparisons: 1,
  //   },
  //   {
  //     blur: [0,1],
  //     focus: [1,2],
  //     increaseComparisons: 1
  //   },
  //   {
  //     swap: [1,2],
  //     increaseSwaps: 1
  //   },
  //   {
  //     blur: [1,2],
  //     focus: [2,3],
  //     increaseComparisons: 1
  //   }
  // ];

  let statistics = ReactDOM.render(
    <Statistics />,
    document.getElementById('statistics')
  );

  let player = new Player(film, view, statistics);

  ReactDOM.render(
    <Dashboard player={player}/>,
    document.getElementById('dashboard')
  );
}) ();


