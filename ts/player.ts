export class Player {
  film;
  view;
  statistics;
  step = 0;
  previousStepForward = false;

  static actions = {
    FOCUS: 0,
    SWAP: 1
  };

  constructor (film, view, statistics) {
    this.film = film;
    this.view = view;
    this.statistics = statistics;
  }


  previousStepWasForward() {
    return this.previousStepForward;
  }

  previousStepWasBackward() {
    return !this.previousStepForward;
  }

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

    // reverse actions when going backwards
    var filmActions = Object.assign({}, this.film[this.step]);
    filmActions.focus = this.film[this.step].blur;
    filmActions.blur = this.film[this.step].focus;
    filmActions.decreaseComparisons = this.film[this.step].increaseComparisons;
    filmActions.increaseComparisons = null;
    filmActions.decreaseSwaps = this.film[this.step].increaseSwaps;
    filmActions.increaseSwaps = null;

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

    if (filmActions.increaseComparisons) {
      this.statistics.increaseComparisons();
    }

    if (filmActions.increaseSwaps) {
      this.statistics.increaseSwaps();
    }

    if (filmActions.decreaseComparisons) {
      this.statistics.decreaseComparisons();
    }

    if (filmActions.decreaseSwaps) {
      this.statistics.decreaseSwaps();
    }

    return Promise.all(promisedActions);
  };
  
  getFilmActions() {
    return this.film[this.step];
  };
};