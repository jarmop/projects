export class BubbleSort {
  film = [];

  constructor() {}

  sort(data) {
    var swapCount = 1;
    var film = {
      startState: data.slice(0),
      endState: [],
      actions: []
    };

    var unsortedDataLength = data.length;
    while (swapCount > 0) {
      swapCount = 0;
      for (var i = 1; i < unsortedDataLength; i++) {
        var filmActions = {
          blur: previousFocus,
          focus: [i - 1, i],
          increaseComparisons: true,
        };
        var previousFocus = filmActions.focus;
        film.actions.push(filmActions);

        if (data[i - 1] > data[i]) {
          var temp = data[i - 1];
          data[i - 1] = data[i];
          data[i] = temp;
          swapCount++;

          film.actions.push({
            swap: filmActions.focus,
            increaseSwaps: true
          });
        }
      }
      unsortedDataLength--;
    }

    film.endState = data;

    return film;
  }
}