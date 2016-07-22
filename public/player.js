var Player = function (film, view) {
  var step = -1;

  this.forward = function () {
    if (step + 1 >= film.length) {
      console.log('The end!');
      return;
    }
    ++step;

    this.showTransition(film[step]);
  };

  this.backward = function () {
    if (step - 1 < 0) {
      console.log('The beginning!');
      return;
    }
    --step;

    this.showTransition(film[step]);
  };
  
  this.showTransition = function (currentState) {

    console.log(currentState);

    switch (currentState.action) {
      case Player.actions.FOCUS:
        view.focus(currentState.args)
    }
  }
};

Player.actions = {
  FOCUS: 0,
  SWAP: 1
};