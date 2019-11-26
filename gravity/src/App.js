import React, {useEffect, useState, useCallback} from 'react';
import './App.css';
import Screen from './Screen';

// Meters
const OBJECT_ORIGINAL_HEIGHT = 1.5;

// const OBJECT_MASS = 1;
// const OBJECT_ORIGINAL_HEIGHT = 0;
// const BUMP_FORCE = 10000;

const FPS = 1000;
const G = 9.81;

// 1/6 OF KINETIC ENERGY IS CONVERTED INTO HEAT
const EFFICIENCY = 5/6;

const ANIMATION_SPEED = 4;

// const kineticEnergy = (m, v) => m * Math.pow(v, 2) / 2;
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
    const virtualTimeIncrement = ANIMATION_SPEED * timeIncrement;
    setTimeout(() => {
      const newTime = state.time + virtualTimeIncrement / 1000;
      const heightChange = state.startSpeed * newTime + distance(-G, newTime);
      const currentSpeed = state.startSpeed + speed(-G, newTime);
      // console.log(state.startSpeed);
      // console.log('time: ' + newTime);
      // console.log('heightChange: ' + heightChange);
      // console.log('currentSpeed: ' + currentSpeed);
      // console.log('kineticEnergy: ' + kineticEnergy(OBJECT_MASS, currentSpeed));
      const newHeight = Math.max(state.startHeight + heightChange, 0);

      const newState = {
        ...state,
        height: newHeight,
        time: newHeight === 0 ? 0 : newTime,
        startSpeed: newHeight === 0 ? Math.abs(currentSpeed) < 0.3 ? 0 : (EFFICIENCY*-currentSpeed) : state.startSpeed,
        startHeight: newHeight === 0 ? 0 : state.startHeight,
      };
      // console.log(newState);
      // console.log('********');
      setState(newState);
    }, timeIncrement);
  }, [state]);

  /**
   * @type {function(): boolean}
   */
  const isDead = useCallback(() => {
    return state.height === 0 && state.startSpeed === 0
  }, [state]);

  useEffect(() => {
    if (timeIsRunning) {
      if (isDead()) {
        setTimeIsRunning(false);
      } else {
        tick();
      }
    }
  }, [state, timeIsRunning, tick, isDead]);

  const reset = () => {
    setState(initialState)
  };

  return (
      <div className="app">
        <Screen objectHeight={state.height}/>
        <div>
          {!isDead() &&
            <button onClick={() => setTimeIsRunning(!timeIsRunning)}>{timeIsRunning ? 'Stop' : 'Play'}</button>
          }
          {(state.time > 0 || isDead()) &&
            <button onClick={reset}>Reset</button>
          }
          <div>
            Height: {state.height.toFixed(2)} m
          </div>
        </div>
      </div>
  );
}

export default App;
