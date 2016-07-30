export class Player {
  film;
  view;
  step = 0;
  previousStepForward = false;

  static actions = {
    FOCUS: 0,
    SWAP: 1
  };

  constructor (film, view) {
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
    this.forward().then(
      () => {
        (new Promise((resolve, reject) => {
          setTimeout(() => {resolve()}, 200);
        })).then(() => this.play());
      },
      () => {return Promise.resolve()}
    );
  };

  forward() : Promise<any> {
    if (this.previousStepWasForward()) {
      if (this.step + 1 >= this.film.length) {
        console.log('The end!');
        return Promise.reject('Film is at the end');
      }
      ++this.step;
    }
    this.previousStepForward = true;

    return this.show(this.film[this.step]);
  };

  backward() : Promise<any> {
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
  };
  
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
  };
  
  getFilmActions() {
    return this.film[this.step];
  };
};