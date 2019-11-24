import React, {useEffect, useState, useCallback} from 'react';
import './App.css';

// Pixels
const CANVAS_WIDTH = 200;
const CANVAS_HEIGHT = 300;

// Meters
const OBJECT_RADIUS = 1;
const OBJECT_ORIGINAL_HEIGHT = 20;

const PIXELS_PER_METER = 10;
const FPS = 100;
const G = 9.81;

function App() {
  const [state, setState] = useState({
    height: OBJECT_ORIGINAL_HEIGHT,
    time: 0,
  });
  const [timeIsRunning, setTimeIsRunning] = useState(false);
  const tick = useCallback(() => {
    const timeIncrement = 1000 / FPS;
    setTimeout(() => {
      const newTime = state.time + timeIncrement / 1000;
      const d = G * Math.pow(newTime, 2) / 2;
      console.log('t: ' + newTime + ', d: ' + d);
      setState({
        height: Math.max(OBJECT_ORIGINAL_HEIGHT - d, 0),
        time: newTime,
      });
    }, timeIncrement);
  }, [state.time]);

  useEffect(() => {
    const canvas = document.getElementById('canvas');
    const c = canvas.getContext('2d');

    c.clearRect(0, 0, CANVAS_WIDTH, CANVAS_HEIGHT);
    c.beginPath();
    c.arc(CANVAS_WIDTH / 2, CANVAS_HEIGHT - (state.height + OBJECT_RADIUS) * PIXELS_PER_METER, OBJECT_RADIUS * PIXELS_PER_METER, 0, Math.PI * 2);
    c.fill();
    if (timeIsRunning) {
      if (state.height === 0) {
        setTimeIsRunning(false);
      } else {
        tick();
      }
    }
  }, [state.height, timeIsRunning, tick]);


  return (
      <div className="app">
        <canvas id="canvas" className="canvas" width={CANVAS_WIDTH} height={CANVAS_HEIGHT}/>
        <div>
          <button onClick={() => setTimeIsRunning(!timeIsRunning)}>{timeIsRunning ? 'Stop' : 'Drop'}</button>
          <div>
            Height: {state.height} m
          </div>
        </div>
      </div>
  );
}

export default App;
