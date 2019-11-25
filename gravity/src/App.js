import React, {useEffect, useState, useCallback} from 'react';
import './App.css';

const CANVAS_WIDTH_PX = 400;

// Meters
const CANVAS_WIDTH = 2;
const CANVAS_HEIGHT = 3;
const OBJECT_ORIGINAL_HEIGHT = 1.5;
const OBJECT_RADIUS = 0.1;

const OBJECT_MASS = 1;
// const OBJECT_ORIGINAL_HEIGHT = 0;
// const BUMP_FORCE = 10000;

const PIXELS_PER_METER = CANVAS_WIDTH_PX / CANVAS_WIDTH;
const FPS = 100;
const G = 9.81;

// 1/6 OF KINETIC ENERGY IS CONVERTED INTO HEAT
const EFFICIENCY = 5/6;

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

const kineticEnergy = (m, v) => m * Math.pow(v, 2) / 2;
const speed = (a, t) => a * t;
const distance = (a, t) => a * Math.pow(t, 2) / 2;

function App() {
  const initialState = {
    height: OBJECT_ORIGINAL_HEIGHT,
    time: 0,
    startSpeed: 0,
    startHeight: OBJECT_ORIGINAL_HEIGHT,
  };
  const [state, setState] = useState(initialState);
  const [timeIsRunning, setTimeIsRunning] = useState(false);
  const tick = useCallback(() => {
    const timeIncrement = 1000 / FPS;
    setTimeout(() => {
      const newTime = state.time + timeIncrement / 1000;
      const heightChange = state.startSpeed * newTime + distance(-G, newTime);
      const currentSpeed = state.startSpeed + speed(-G, newTime);
      console.log(state.startSpeed);
      console.log('time: ' + newTime);
      console.log('heightChange: ' + heightChange);
      console.log('currentSpeed: ' + currentSpeed);
      console.log('kineticEnergy: ' + kineticEnergy(OBJECT_MASS, currentSpeed));
      const newHeight = Math.max(state.startHeight + heightChange, 0);

      const newState = {
        ...state,
        height: newHeight,
        time: newHeight === 0 ? 0 : newTime,
        startSpeed: newHeight === 0 ? EFFICIENCY*-currentSpeed : state.startSpeed,
        startHeight: newHeight === 0 ? 0 : state.startHeight,
      };
      console.log(newState);
      console.log('********');
      setState(newState);
    }, timeIncrement);
  }, [state]);

  useEffect(() => {
    drawScreen(document.getElementById('canvas'), state.height, OBJECT_RADIUS);

    if (timeIsRunning) {
      // if (state.height === 0) {
      //   setTimeIsRunning(false);
      // } else {
        tick();
      // }
    }
  }, [state.height, timeIsRunning, tick]);

  const reset = () => {
    setState(initialState)
  };

  return (
      <div className="app">
        <canvas id="canvas" className="canvas" width={metersToPixels(CANVAS_WIDTH)} height={metersToPixels(CANVAS_HEIGHT)}/>
        <div>
          {/*{state.height === 0*/}
          {/*    ?*/}
          {/*    <button onClick={reset}>Reset</button>*/}
          {/*    :*/}
          {/*    <button onClick={() => setTimeIsRunning(!timeIsRunning)}>{timeIsRunning ? 'Stop' : 'Play'}</button>*/}
          {/*}*/}
          <button onClick={() => setTimeIsRunning(!timeIsRunning)}>{timeIsRunning ? 'Stop' : 'Play'}</button>

          <div>
            Height: {state.height.toFixed(2)} m
          </div>
        </div>
      </div>
  );
}

export default App;
