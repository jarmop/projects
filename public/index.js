/******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};

/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {

/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId])
/******/ 			return installedModules[moduleId].exports;

/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			exports: {},
/******/ 			id: moduleId,
/******/ 			loaded: false
/******/ 		};

/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);

/******/ 		// Flag the module as loaded
/******/ 		module.loaded = true;

/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}


/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;

/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;

/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";

/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(0);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ function(module, exports, __webpack_require__) {

	"use strict";
	const view_1 = __webpack_require__(1);
	const bubble_sort_1 = __webpack_require__(2);
	const player_1 = __webpack_require__(3);
	const react_view_1 = __webpack_require__(4);
	const React = __webpack_require__(5);
	const ReactDOM = __webpack_require__(6);
	// declare var Vue:any;
	(function () {
	    var view = new view_1.View();
	    var data = [];
	    for (var i = 0; i < 10; i++) {
	        data.push(randomInt());
	    }
	    view.drawArray(data);
	    var bubbleSort = new bubble_sort_1.BubbleSort();
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
	    var player = new player_1.Player(film, view);
	    initDashBoard();
	    function randomInt() {
	        return Math.floor((Math.random() * 9) + 1);
	    }
	    function initDashBoard() {
	        var enabled = true;
	        var enable = () => enabled = true;
	        var disable = () => enabled = false;
	        function updateStats() {
	            let filmActions = player.getFilmActions();
	            // vue.comparisons = filmActions.comparisons;
	            // vue.swaps = filmActions.swaps;
	        }
	        function play() {
	            return player.forward().then(() => {
	                updateStats();
	                (new Promise((resolve, reject) => {
	                    setTimeout(() => { resolve(); }, 200);
	                })).then(() => play());
	            }, () => Promise.resolve());
	        }
	        // var vue = new Vue({
	        //   el: 'body',
	        //   data: {
	        //     comparisons: 0,
	        //     swaps: 0
	        //   },
	        //   methods: {
	        //     play: function () {
	        //       play().then(() => enable(), () => enable());
	        { }
	        { }
	        { }
	        { }
	        //       if (!enabled) {
	        //         return;
	        //       }
	        //       disable();
	        //       player.forward().then(() => {
	        //         updateStats();
	        //         enable();
	        //       }, () => enable());
	        //     },
	        //     backward: function (e) {
	        //       if (!enabled) {
	        //         return;
	        //       }
	        //       disable();
	        //       player.backward().then(() => {
	        //         updateStats();
	        //         enable();
	        //       }, () => enable());
	        //     }
	        //   }
	        // });
	    }
	    function showStats() {
	    }
	    ReactDOM.render(React.createElement(react_view_1.CommentBox, {player: player}), document.getElementById('content'));
	})();


/***/ },
/* 1 */
/***/ function(module, exports) {

	"use strict";
	class View {
	    constructor() {
	        this.config = {
	            nodeSize: 32,
	            gridSize: 8,
	            canvasWidth: 0,
	            canvasHeight: 0,
	            canvasWidthGrids: 60,
	            canvasHeightGrids: 8,
	            strokeWidth: 3,
	            showGrid: false,
	            gridColor: '#ddd',
	            gridColorStrong: '#aaa',
	            paddingGrids: 1,
	            focusColor: '#5e5',
	            blurColor: '#000',
	            animationSpeed: 500
	        };
	        this.arrayNodes = [];
	        this.focusedNodes = [];
	        this.config.canvasWidth = this.config.canvasWidthGrids * this.config.gridSize;
	        this.config.canvasHeight = this.config.canvasHeightGrids * this.config.gridSize;
	        this.draw = SVG('drawing').size(this.config.canvasWidth, this.config.canvasHeight);
	        if (this.config.showGrid) {
	            this.drawGrid();
	        }
	    }
	    drawGrid() {
	        var x = 0;
	        var y = 0;
	        for (var i = 0; i < this.config.canvasHeightGrids + 1; i++) {
	            var color = this.config.gridColor;
	            if (i % 4 == 0) {
	                color = this.config.gridColorStrong;
	            }
	            this.draw.line(0, y, this.config.canvasWidth, y).stroke({ width: 1, color: color });
	            y += this.config.gridSize;
	        }
	        for (var i = 0; i < this.config.canvasWidthGrids + 1; i++) {
	            var color = this.config.gridColor;
	            if (i % 4 == 0) {
	                color = this.config.gridColorStrong;
	            }
	            this.draw.line(x, 0, x, this.config.canvasHeight).stroke({ width: 1, color: color });
	            x += this.config.gridSize;
	        }
	    }
	    drawNode(x, y, value) {
	        var border = this.draw.circle(this.config.nodeSize).attr({
	            fill: '#fff',
	            stroke: this.config.blurColor,
	            'stroke-width': this.config.strokeWidth
	        });
	        var content = this.draw.text(value.toString()).attr({
	            fill: this.config.blurColor,
	            'x': 10,
	            leading: 1.1
	        }).font({
	            size: 20,
	            weight: 'bold'
	        });
	        var group = this.draw.group();
	        group.add(border);
	        group.add(content);
	        group.x(x);
	        group.y(y);
	        return new ViewNode(border, content, group);
	    }
	    drawArray(data) {
	        var x1 = this.config.paddingGrids * this.config.gridSize + this.config.nodeSize / 2;
	        var y1 = this.config.paddingGrids * this.config.gridSize + this.config.nodeSize / 2;
	        var x2 = x1 + this.config.gridSize + this.config.nodeSize;
	        var y2 = y1;
	        // draw lines
	        for (var i = 1; i < data.length; i++) {
	            this.draw.line(x1, y1, x2, y2).stroke({ width: this.config.strokeWidth });
	            x1 = x2;
	            x2 = x1 + this.config.gridSize + this.config.nodeSize;
	        }
	        // draw nodes
	        var x1 = this.config.paddingGrids * this.config.gridSize + this.config.nodeSize / 2;
	        for (var i = 0; i < data.length; i++) {
	            this.arrayNodes.push(this.drawNode(x1 - this.config.nodeSize / 2, y1 - this.config.nodeSize / 2, data[i]));
	            x1 += this.config.gridSize + this.config.nodeSize;
	        }
	    }
	    ;
	    // function drawTree(data, treeX, treeY) {
	    //
	    //   var levelX = [
	    //     [21, 30],
	    //     [9, 20],
	    //     [3, 8],
	    //     [0, 2]
	    //   ];
	    //
	    //   var levels = 4;
	    //   var nodeAmountOnLastLevel = Math.pow(2, levels - 1);
	    //   var i = 0;
	    //   var x;
	    //   var j;
	    //   var y = treeY * this.config.gridSize;
	    //   var parentCoordinates = [];
	    //   for (var level = 0; level < 4; level++) {
	    //     // x = treeX * this.config.gridSize + (Math.pow(2, levels - level) - 2) * this.config.gridSize;
	    //     x = treeX * this.config.gridSize + levelX[level][0] * this.config.gridSize;
	    //     // var nodeDistanceOnCurrentLevel = (Math.pow(2, levels - level) - 1) * 2 * this.config.gridSize + this.config.nodeSize;
	    //     var nodeDistanceOnCurrentLevel = levelX[level][1] * this.config.gridSize + this.config.nodeSize;
	    //     var nodeAmountOnCurrentLevel = Math.pow(2, level);
	    //     j = 0;
	    //     while (j < nodeAmountOnCurrentLevel && i < data.length) {
	    //       drawNode(x, y, data[i]);
	    //       x += nodeDistanceOnCurrentLevel;
	    //       i++;
	    //       j++
	    //     }
	    //     y += this.config.gridSize + this.config.nodeSize;
	    //   }
	    // }
	    focus(indexes) {
	        for (var i = 0; i < indexes.length; i++) {
	            this.arrayNodes[indexes[i]].focus();
	        }
	        return Promise.resolve();
	    }
	    ;
	    blur(indexes) {
	        for (var i = 0; i < indexes.length; i++) {
	            this.arrayNodes[indexes[i]].blur();
	        }
	        return Promise.resolve();
	    }
	    ;
	    swap(indexes) {
	        var node1 = this.arrayNodes[indexes[0]];
	        var node2 = this.arrayNodes[indexes[1]];
	        this.arrayNodes[indexes[0]] = node2;
	        this.arrayNodes[indexes[1]] = node1;
	        var node1X = node1.x();
	        return Promise.all([
	            new Promise(function (resolve, reject) {
	                node1.animate().x(node2.x()).after(function () {
	                    resolve();
	                });
	            }),
	            new Promise(function (resolve, reject) {
	                node2.animate().x(node1X).after(function () {
	                    resolve();
	                });
	            })
	        ]);
	    }
	    ;
	}
	exports.View = View;
	;
	class ViewNode {
	    constructor(circle, content, group) {
	        this.circle = circle;
	        this.content = content;
	        this.group = group;
	    }
	    focus() {
	        this.circle.fill('#5e5');
	    }
	    ;
	    blur() {
	        this.circle.fill('#fff');
	    }
	    ;
	    x() {
	        return this.group.x();
	    }
	    ;
	    y() {
	        return this.group.y();
	    }
	    ;
	    animate() {
	        return this.group.animate(500);
	    }
	}


/***/ },
/* 2 */
/***/ function(module, exports) {

	"use strict";
	class BubbleSort {
	    constructor() {
	        this.film = [];
	    }
	    sort(data) {
	        var totalComparisonCount = 0;
	        var totalSwapCount = 0;
	        var swapCount = 1;
	        var film = [];
	        var unsortedDataLength = data.length;
	        while (swapCount > 0) {
	            swapCount = 0;
	            for (var i = 1; i < unsortedDataLength; i++) {
	                totalComparisonCount++;
	                var filmActions = {
	                    blur: previousFocus,
	                    focus: [i - 1, i],
	                    comparisons: totalComparisonCount,
	                    swaps: totalSwapCount
	                };
	                var previousFocus = filmActions.focus;
	                film.push(filmActions);
	                if (data[i - 1] > data[i]) {
	                    var temp = data[i - 1];
	                    data[i - 1] = data[i];
	                    data[i] = temp;
	                    swapCount++;
	                    totalSwapCount++;
	                    film.push({
	                        swap: filmActions.focus,
	                        comparisons: totalComparisonCount,
	                        swaps: totalSwapCount
	                    });
	                }
	            }
	            unsortedDataLength--;
	        }
	        return film;
	    }
	}
	exports.BubbleSort = BubbleSort;


/***/ },
/* 3 */
/***/ function(module, exports) {

	"use strict";
	class Player {
	    constructor(film, view) {
	        this.step = 0;
	        this.previousStepForward = false;
	        this.film = film;
	        this.view = view;
	    }
	    previousStepWasForward() {
	        return this.previousStepForward;
	    }
	    previousStepWasBackward() {
	        return !this.previousStepForward;
	    }
	    play() {
	        this.forward().then(() => {
	            (new Promise((resolve, reject) => {
	                setTimeout(() => { resolve(); }, 200);
	            })).then(() => this.play());
	        }, () => { return Promise.resolve(); });
	    }
	    ;
	    forward() {
	        if (this.previousStepWasForward()) {
	            if (this.step + 1 >= this.film.length) {
	                console.log('The end!');
	                return Promise.reject('Film is at the end');
	            }
	            ++this.step;
	        }
	        this.previousStepForward = true;
	        return this.show(this.film[this.step]);
	    }
	    ;
	    backward() {
	        if (this.previousStepWasBackward()) {
	            if (this.step - 1 < 0) {
	                console.log('The beginning!');
	                return Promise.reject('Film is at the beginning');
	            }
	            --this.step;
	        }
	        this.previousStepForward = false;
	        // swap focus and blur when going backwards
	        var filmActions = Object.assign({}, this.film[this.step]);
	        filmActions.focus = this.film[this.step].blur;
	        filmActions.blur = this.film[this.step].focus;
	        return this.show(filmActions);
	    }
	    ;
	    show(filmActions) {
	        var promisedActions = [];
	        if (filmActions.blur) {
	            promisedActions.push(this.view.blur(filmActions.blur));
	        }
	        if (filmActions.focus) {
	            promisedActions.push(this.view.focus(filmActions.focus));
	        }
	        if (filmActions.swap) {
	            promisedActions.push(this.view.swap(filmActions.swap));
	        }
	        return Promise.all(promisedActions);
	    }
	    ;
	    getFilmActions() {
	        return this.film[this.step];
	    }
	    ;
	}
	Player.actions = {
	    FOCUS: 0,
	    SWAP: 1
	};
	exports.Player = Player;
	;


/***/ },
/* 4 */
/***/ function(module, exports, __webpack_require__) {

	"use strict";
	const React = __webpack_require__(5);
	class CommentBox extends React.Component {
	    constructor(...args) {
	        super(...args);
	        this.enabled = true;
	    }
	    enable() {
	        this.enabled = true;
	    }
	    disable() {
	        this.enabled = false;
	    }
	    play() {
	        if (!this.enabled) {
	            return;
	        }
	        this.disable();
	        this.props.player.play().then(() => this.enable(), () => this.enable());
	    }
	    forward() {
	        if (!this.enabled) {
	            return;
	        }
	        this.disable();
	        this.props.player.forward().then(() => this.enable(), () => this.enable());
	    }
	    backward() {
	        if (!this.enabled) {
	            return;
	        }
	        this.disable();
	        this.props.player.backward().then(() => this.enable(), () => this.enable());
	    }
	    render() {
	        return (React.createElement("div", {className: "commentBox"}, React.createElement("button", {className: "btn btn-secondary"}, React.createElement("i", {className: "fa fa-fast-backward", "aria-hidden": "true"})), React.createElement("button", {onClick: e => this.backward(), className: "btn btn-secondary"}, React.createElement("i", {className: "fa fa-backward", "aria-hidden": "true"})), React.createElement("button", {onClick: e => this.play(), className: "btn btn-secondary"}, React.createElement("i", {className: "fa fa-play", "aria-hidden": "true"})), React.createElement("button", {onClick: e => this.forward(), className: "btn btn-secondary"}, React.createElement("i", {className: "fa fa-forward", "aria-hidden": "true"})), React.createElement("button", {className: "btn btn-secondary"}, React.createElement("i", {className: "fa fa-fast-forward", "aria-hidden": "true"}))));
	    }
	}
	exports.CommentBox = CommentBox;


/***/ },
/* 5 */
/***/ function(module, exports) {

	module.exports = React;

/***/ },
/* 6 */
/***/ function(module, exports) {

	module.exports = ReactDOM;

/***/ }
/******/ ]);