var BubbleSort = function () {
  film = [];

  this.sort = function(data) {
    var totalComparisonCount = 0;
    var totalSwapCount = 0;
    var swapCount = 1;
    var film = [];

    var unsortedDataLength = data.length;
    while (swapCount > 0) {
      swapCount = 0;
      for (var i = 1; i < unsortedDataLength; i++) {
        totalComparisonCount++;
        var filmActions = {
          blur: previousFocus,
          focus: [i - 1, i],
          comparisons: totalComparisonCount,
          swaps: totalSwapCount
        };
        var previousFocus = filmActions.focus;
        film.push(filmActions);

        if (data[i - 1] > data[i]) {
          var temp = data[i - 1];
          data[i - 1] = data[i];
          data[i] = temp;
          swapCount++;
          totalSwapCount++;

          film.push({
            swap: filmActions.focus,
            comparisons: totalComparisonCount,
            swaps: totalSwapCount
          });
        }
      }
      unsortedDataLength--;
    }

    return film;
  };
};