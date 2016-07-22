var BubbleSort = function (data, dataArray) {
  var i = 1;
  this.step = function() {
    // dataArray[i].fill('#555');
    if (i >= data.length) {
      i = 1;
    }
    if (data[i - 1] > data[i]) {
      var temp = data[i - 1];
      data[i - 1] = data[i];
      data[i] = temp;
      this.swapNodes(dataArray[i - 1], dataArray[i]);
      var temp = dataArray[i - 1];
      dataArray[i - 1] = dataArray[i];
      dataArray[i] = temp;
    }
    i++;
  };

  var swapCount;
  this.swapNodes = function(node1, node2) {
    console.log('swap');
    swapCount++;
    // console.log('jgf');
    var node1X = node1.x();
    node1.animate(500).x(node2.x());
    node2.animate(500).x(node1X);

  };

  // function sort(data, dataArray, i) {
//   if (i >= data.length) {
//     return;
//   }
//
//   if (data[i - 1] > data[i]) {
//     var temp = data[i - 1];
//     data[i - 1] = data[i];
//     data[i] = temp;
//     swapNodes(dataArray[i - 1], dataArray[i], function () {
//       sort(data, dataArray, ++i);
//     });
//     //   .after(sort(
//     //   data, dataArray, ++i
//     // ));
//   } else {
//     sort(
//       data, dataArray, ++i
//     )
//   }
// }
};