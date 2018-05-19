let emptyGrid = {column: 4, row: 4};

const moveBlock = (event) => {
  let grid = {
    column: parseInt(event.target.style['grid-column']),
    row: parseInt(event.target.style['grid-row']),
  };

  if (Math.abs(emptyGrid.column - grid.column) + Math.abs(emptyGrid.row - grid.row) < 2) {
    event.target.style = 'grid-column: ' + emptyGrid.column + '; grid-row: ' + emptyGrid.row;
    emptyGrid = grid;
  }
};

let gameBoard = document.querySelector('.gameboard');
let row = 1;
let column = 1;
for (let i = 1; i < 16; i++) {
  let block = document.createElement('div');
  block.dataset.id = i;
  block.className = 'block';
  block.style = 'grid-column: ' + column + '; grid-row: ' + row;
  block.appendChild(document.createTextNode(i));
  block.onclick = moveBlock;
  gameBoard.appendChild(block);
  if (i % 4 === 0) {
    row++;
    column = 1;
  } else {
    column++;
  }
}