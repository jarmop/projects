import React, {useEffect, useState} from 'react';
import './App.css';

const CANVAS_WIDTH = 200;
const CANVAS_HEIGHT = 300;
const OBJECT_RADIUS = 10;
const OBJECT_ORIGINAL_Y = 90;
const TIME_INCREMENT_MS = 100;
const G = 9.81;

function App() {
  const [state, setState] = useState({
    y: OBJECT_ORIGINAL_Y,
    t: 0,
  });
  const [timeIsRunning, setTimeIsRunning] = useState(false);
  useEffect(() => {
    const canvas = document.getElementById('canvas');
    const c = canvas.getContext('2d');

    c.clearRect(0, 0, CANVAS_WIDTH, CANVAS_HEIGHT);
    c.beginPath();
    c.arc(CANVAS_WIDTH / 2, state.y, OBJECT_RADIUS, 0, Math.PI*2);
    c.fill();
    if (timeIsRunning) {
      if (state.y + OBJECT_RADIUS === CANVAS_HEIGHT) {
        setTimeIsRunning(false);
      } else {
        tick();
      }
    }
  });

  const tick = () => {
    setTimeout(() => {
      const newTime = state.t + TIME_INCREMENT_MS / 1000;
      const d = G * Math.pow(newTime, 2) / 2;
      console.log('t: ' + newTime + ', d: ' + d);
      setState({
        y: Math.min(OBJECT_ORIGINAL_Y + d, CANVAS_HEIGHT - OBJECT_RADIUS),
        t: newTime,
      });
    }, TIME_INCREMENT_MS);
  };

  return (
      <div className="app">
        <canvas id="canvas" className="canvas" width={CANVAS_WIDTH} height={CANVAS_HEIGHT}/>
        <div>
          <button onClick={() => setTimeIsRunning(!timeIsRunning)}>{timeIsRunning ? 'Stop' : 'Drop'}</button>
          <div>
            Height: {CANVAS_HEIGHT - state.y - OBJECT_RADIUS} m
          </div>
        </div>
      </div>
  );
}

export default App;
