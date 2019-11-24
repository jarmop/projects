import React, {useEffect, useState, useCallback} from 'react';
import './App.css';

const CANVAS_WIDTH_PX = 400;

// Meters
const CANVAS_WIDTH = 20;
const CANVAS_HEIGHT = 30;
const OBJECT_RADIUS = 1;
const OBJECT_ORIGINAL_HEIGHT = 20;

const PIXELS_PER_METER = CANVAS_WIDTH_PX / CANVAS_WIDTH;
const FPS = 100;
const G = 9.81;

const metersToPixels = (meters) => meters * PIXELS_PER_METER;

const drawScreen = (canvas, objectHeight, objectRadius) => {
  objectHeight = metersToPixels(objectHeight);
  objectRadius = metersToPixels(objectRadius);
  const c = canvas.getContext('2d');
  c.clearRect(0, 0, canvas.width, canvas.height);
  c.beginPath();
  c.arc(canvas.width / 2, canvas.height - objectHeight - objectRadius, objectRadius, 0, Math.PI * 2);
  c.fill();
};

function App() {
  const initialState = {
    height: OBJECT_ORIGINAL_HEIGHT,
    time: 0,
  };
  const [state, setState] = useState(initialState);
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
    drawScreen(document.getElementById('canvas'), state.height, OBJECT_RADIUS);

    if (timeIsRunning) {
      if (state.height === 0) {
        setTimeIsRunning(false);
      } else {
        tick();
      }
    }
  }, [state.height, timeIsRunning, tick]);

  const reset = () => {
    setState(initialState)
  };

  return (
      <div className="app">
        <canvas id="canvas" className="canvas" width={metersToPixels(CANVAS_WIDTH)} height={metersToPixels(CANVAS_HEIGHT)}/>
        <div>
          {state.height === 0
              ?
              <button onClick={reset}>Reset</button>
              :
              <button onClick={() => setTimeIsRunning(!timeIsRunning)}>{timeIsRunning ? 'Stop' : 'Drop'}</button>
          }
          <div>
            Height: {state.height.toFixed(2)} m
          </div>
        </div>
      </div>
  );
}

export default App;
