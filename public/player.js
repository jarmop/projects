var Player = function (film, view) {
  var step = 0;
  var previousStepForward = false;

  function previousStepWasForward() {
    return previousStepForward;
  }

  function previousStepWasBackward() {
    return !previousStepForward;
  }

  this.play = function () {
    this.forward().then(
      () => this.play(),
      () => {return Promise.resolve()}
    );
  };

  this.forward = function () {
    if (previousStepWasForward()) {
      if (step + 1 >= film.length) {
        console.log('The end!');
        return Promise.reject();
      }
      ++step;
    }
    previousStepForward = true;

    return this.show(film[step]);
  };

  this.backward = function () {
    if (previousStepWasBackward()) {
      if (step - 1 < 0) {
        console.log('The beginning!');
        return Promise.resolve();
      }
      --step;
    }
    previousStepForward = false;

    // swap focus and blur when going backwards
    var filmActions = Object.assign({}, film[step]);
    filmActions.focus = film[step].blur;
    filmActions.blur = film[step].focus;

    return this.show(filmActions);
  };
  
  this.show = function (filmActions) {
    var promisedActions = [];
    if (filmActions.blur) {
      promisedActions.push(view.blur(filmActions.blur));
    }

    if (filmActions.focus) {
      promisedActions.push(view.focus(filmActions.focus));
    }

    if (filmActions.swap) {
      promisedActions.push(view.swap(filmActions.swap));
    }

    return Promise.all(promisedActions);
  }
};

Player.actions = {
  FOCUS: 0,
  SWAP: 1
};