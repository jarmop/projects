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
      if (this.step + 1 >= this.film.actions.length) {
        console.log('The end!');
        return Promise.reject('Film is at the end');
      }
      ++this.step;
    }
    this.previousStepForward = true;

    return this.show(this.film.actions[this.step]);
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
    let originalActionSequence = this.film.actions[this.step];
    let actionSequence = Object.assign({}, originalActionSequence);
    actionSequence.focus = originalActionSequence.blur;
    actionSequence.blur = originalActionSequence.focus;
    actionSequence.decreaseComparisons = originalActionSequence.increaseComparisons;
    actionSequence.increaseComparisons = null;
    actionSequence.decreaseSwaps = originalActionSequence.increaseSwaps;
    actionSequence.increaseSwaps = null;

    return this.show(actionSequence);
  };
  
  show(actionSequence) {
    var promisedActions = [];
    if (actionSequence.blur) {
      promisedActions.push(this.view.blur(actionSequence.blur));
    }

    if (actionSequence.focus) {
      promisedActions.push(this.view.focus(actionSequence.focus));
    }

    if (actionSequence.swap) {
      promisedActions.push(this.view.swap(actionSequence.swap));
    }

    if (actionSequence.increaseComparisons) {
      this.statistics.increaseComparisons();
    }

    if (actionSequence.increaseSwaps) {
      this.statistics.increaseSwaps();
    }

    if (actionSequence.decreaseComparisons) {
      this.statistics.decreaseComparisons();
    }

    if (actionSequence.decreaseSwaps) {
      this.statistics.decreaseSwaps();
    }

    return Promise.all(promisedActions);
  }

  gotoBeginning() {
    this.step = 0;
    this.view.reDrawArray(this.film.startState);
    this.previousStepForward = false;
    this.statistics.reset();
  }

  // gotoEnd() {
  //   this.step = 0;
  //   this.view.reDrawArray(this.film.startState);
  // }
}