var Player = function (film, view) {
  var step = -1;

  // this.play = function (film) {
  //   for (var step = 0; step < film.length(); step++) {
  //     this.show(film[step]);
  //   }
  // };

  this.forward = function () {
    var previousState = step;
    var currentState = ++step;
    if (step >= film.length) {
      console.log('The end!');
      return;
    }

    this.showTransition(film[previousState], film[currentState]);
  };

  this.backward = function () {
    var previousState = step;
    var currentState = --step;
    if (step < 0) {
      console.log('In the beginning!');
      return;
    }

    this.showTransition(film[previousState], film[currentState]);
  };
  
  this.showTransition = function (previousState, currentState) {
    // console.log(previousState);
    // console.log(currentState);

    if (previousState) {
      for (var i = 0; i < previousState.focus.length; i++) {
        view.blur(previousState.focus[i]);
      }
    }
    for (var i = 0; i < currentState.focus.length; i++) {
      view.focus(currentState.focus[i]);
    }
    // switch (step.action) {
    //   case this.actions.SWAP:
    //     view.swap(step.action.args[0], step.action.args[1])
    // }
  }
};

Player.actions = {
  SWAP: 0
};