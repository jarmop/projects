export class MergeSort {
  copyArray(fromArray, iBegin, iEnd, toArray) {
    for (let i = iBegin; i < iEnd; i++) {
      toArray[i] = fromArray[i];
    }
  }

  merge(data, iBegin, iMiddle, iEnd, tempData) {
    let i1 = iBegin;
    let i2 = iMiddle;
    for (let i = iBegin; i < iEnd; i++) {
      if (i1 < iMiddle && (i2 >= iEnd || data[i1] <= data[i2])) {
        tempData[i] = data[i1];
        i1++;
      } else {
        tempData[i] = data[i2];
        i2++;
      }
    }
  }

  recursiveSort(data, iBegin, iEnd, tempData) {
    if (iEnd - iBegin < 2) {
      return;
    }

    let iMiddle = iBegin + Math.floor((iEnd - iBegin) / 2);
    this.recursiveSort(data, iBegin, iMiddle, tempData);
    this.recursiveSort(data, iMiddle, iEnd, tempData);
    this.merge(data, iBegin, iMiddle, iEnd, tempData);
    this.copyArray(tempData, iBegin, iEnd, data);
  }

  sort(data) {
    this.recursiveSort(data, 0, data.length, []);

    console.log(data);
  }
}