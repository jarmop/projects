var Player = function () {
  this.actions = {
    SWAP: 0
  };
  var step = 0;

  this.setFilm = function(film) {
    this.film = film;
  };

  // this.play = function (film) {
  //   for (var step = 0; step < film.length(); step++) {
  //     this.show(film[step]);
  //   }
  // };

  this.forward = function () {
    var previousStep = step;
    var nextStep = ++step;
    if (step >= film.length) {
      alert('The end!');
      return;
    }

    this.showTransition(film[previousStep, nextStep]);
  };

  this.showTransition = function (previousState, currentState) {
    screen.setFocus(currentState.focus);
    switch (step.action) {
      case this.actions.SWAP:
        screen.swap(step.action.args[0], step.action.args[1])
    }
  }
};

var player = new Player();

var film = [
  {
    focus: 0
  },
  {
    focus: 1,
    action: {
      method: player.actions.SWAP,
      args: [1,2]
    }
  }
];