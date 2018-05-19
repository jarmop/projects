let gameBoard = document.querySelector('.gameboard');
for (let i = 1; i < 16; i++) {
  let block = document.createElement('div');
  block.className = 'block';
  block.appendChild(document.createTextNode(i));
  gameBoard.appendChild(block);
}