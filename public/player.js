var Player = function (film, view) {
  var step = -1;

  this.forward = function () {
    if (step + 1 >= film.length) {
      console.log('The end!');
      return;
    }
    ++step;

    this.show(film[step]);
  };

  this.backward = function () {
    if (step - 1 < 0) {
      console.log('The beginning!');
      return;
    }
    --step;

    this.show(film[step]);
  };
  
  this.show = function (currentState) {

    console.log(currentState);

    view.focus(currentState.focus);

    if (currentState.swap) {
      view.swap(currentState.focus);
    }
  }
};

Player.actions = {
  FOCUS: 0,
  SWAP: 1
};