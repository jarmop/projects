let emptyGrid = {column: 4, row: 4};
let orderOfBlocks = Array.from(new Array(15), (x,i) => i+1);
shuffle(orderOfBlocks);

/**
 * @param event
 */
function moveBlock(event) {
  let grid = {
    column: parseInt(event.target.style['grid-column']),
    row: parseInt(event.target.style['grid-row']),
  };

  if (Math.abs(emptyGrid.column - grid.column) + Math.abs(emptyGrid.row - grid.row) < 2) {
    event.target.style = 'grid-column: ' + emptyGrid.column + '; grid-row: ' + emptyGrid.row;
    emptyGrid = grid;
  }
}

/**
 * Shuffles array in place.
 * @param Array a
 */
function shuffle(a) {
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}

/**
 * @param a
 * @returns {boolean}
 */
// function inOrder(a) {
//   let isInOrder = true;
//   for (let i = 0; i < a.length - 1; i++) {
//     if (a[i] !== a[i + 1] - 1) {
//       isInOrder = false;
//     }
//   }
//
//   return isInOrder;
// }

let gameBoard = document.querySelector('.gameboard');
let row = 1;
let column = 1;
for (let i = 1; i < 16; i++) {
  let block = document.createElement('div');
  block.dataset.id = i;
  block.className = 'block';
  block.style = 'grid-column: ' + column + '; grid-row: ' + row;
  block.appendChild(document.createTextNode(orderOfBlocks[i - 1]));
  block.onclick = moveBlock;
  gameBoard.appendChild(block);
  if (i % 4 === 0) {
    row++;
    column = 1;
  } else {
    column++;
  }
}