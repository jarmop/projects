var Player = function (film, view) {
  var step = 0;
  var previousStepForward = false;

  function previousStepWasForward() {
    return previousStepForward;
  }

  function previousStepWasBackward() {
    return !previousStepForward;
  }

  this.forward = function () {
    if (previousStepWasForward()) {
      if (step + 1 >= film.length) {
        console.log('The end!');
        return;
      }
      ++step;
    }

    this.show(film[step]);

    previousStepForward = true;
  };

  this.backward = function () {
    if (previousStepWasBackward()) {
      if (step - 1 < 0) {
        console.log('The beginning!');
        return;
      }
      --step;
    }

    // swap focus and blur when going backwards
    var filmActions = Object.assign({}, film[step]);
    filmActions.focus = film[step].blur;
    filmActions.blur = film[step].focus;

    this.show(filmActions);

    previousStepForward = false;
  };
  
  this.show = function (filmActions) {
    if (filmActions.blur) {
      view.blur(filmActions.blur);
    }

    if (filmActions.focus) {
      view.focus(filmActions.focus);
    }

    if (filmActions.swap) {
        view.swap(filmActions.swap);
    }
  }
};

Player.actions = {
  FOCUS: 0,
  SWAP: 1
};