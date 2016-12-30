export class BubbleSort {
  film;
  previousFocus;

  sort(data) {
    var swapCount = 1;
    this.film = {
      startState: data.slice(0),
      endState: {
        data: [],
        comparisons: 0,
        swaps: 0
      },
      actions: []
    };

    var unsortedDataLength = data.length;
    while (swapCount > 0) {
      swapCount = 0;
      for (var i = 1; i < unsortedDataLength; i++) {
        this.recordComparison(i - 1, i);

        if (data[i - 1] > data[i]) {
          var temp = data[i - 1];
          data[i - 1] = data[i];
          data[i] = temp;
          swapCount++;

          this.recordSwap(i - 1, i);
        }
      }
      unsortedDataLength--;
    }

    this.film.endState.data = data;

    return this.film;
  }

  recordComparison(index1, index2) {
    var filmActions = {
      blur: this.previousFocus,
      focus: [index1, index2],
      increaseComparisons: true,
    };
    this.film.endState.comparisons++;
    this.previousFocus = filmActions.focus;
    this.film.actions.push(filmActions);
  }

  recordSwap(index1, index2) {
    this.film.actions.push({
      swap: [index1, index2],
      increaseSwaps: true
    });
    this.film.endState.swaps++;
  }
}