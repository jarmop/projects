import React, {useEffect, useState} from 'react';
import './App.css';

const CANVAS_WIDTH = 200;
const CANVAS_HEIGHT = 300;
const OBJECT_RADIUS = 10;

function App() {
  const [y, setY] = useState(100);
  useEffect(() => {
    const canvas = document.getElementById('canvas');
    const c = canvas.getContext('2d');

    c.clearRect(0, 0, CANVAS_WIDTH, CANVAS_HEIGHT);
    c.beginPath();
    c.arc(CANVAS_WIDTH / 2, y, OBJECT_RADIUS, 0, Math.PI*2);
    c.fill();
  });

  return (
      <div className="app">
        <canvas id="canvas" className="canvas" width={CANVAS_WIDTH} height={CANVAS_HEIGHT}/>
        <div>
          <button onClick={() => setY(Math.min(y + 10, CANVAS_HEIGHT - OBJECT_RADIUS))}>Move</button>
          <div>
            y: {y}
          </div>
        </div>
      </div>
  );
}

export default App;
