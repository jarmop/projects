import { useEffect, useRef, useState } from "react";
import "./App.css";

const maxFrequency = 200;
const maxAmplitude = 100;

const dpr = window.devicePixelRatio;
const w = 500 * dpr;
const h = 100 * dpr;

const audioCtx = new AudioContext();
let osc = audioCtx.createOscillator();
osc.type = "sine";
osc.frequency.value = 94;

const analyser = audioCtx.createAnalyser();
analyser.fftSize = 1024;
analyser.smoothingTimeConstant = 0.8;

const bufferLength = analyser.frequencyBinCount;
const dataArray = new Uint8Array(bufferLength);

const gain = audioCtx.createGain();
gain.gain.value = 0.5;

let canvasCtx: CanvasRenderingContext2D;

// draw an oscilloscope of the current oscillator
function draw() {
  // console.log("draw");
  analyser.getByteTimeDomainData(dataArray);
  // console.log(dataArray[0]);

  canvasCtx.fillStyle = "white";
  canvasCtx.fillRect(0, 0, w, h);

  canvasCtx.lineWidth = 4.0;
  canvasCtx.strokeStyle = "black";
  canvasCtx.beginPath();

  const sliceWidth = (w * 1.0) / bufferLength;
  let x = 0;

  for (let i = 0; i < bufferLength; i++) {
    const v = dataArray[i] / 128.0;
    const y = (v * h) / 2;
    if (i === 0) {
      canvasCtx.moveTo(x, y);
    } else {
      canvasCtx.lineTo(x, y);
    }
    x += sliceWidth;
  }

  canvasCtx.lineTo(w, h / 2);
  canvasCtx.stroke();

  requestAnimationFrame(draw);
}

function App() {
  const [type, setType] = useState<OscillatorType>(osc.type);
  const [frequency, setFrequency] = useState(osc.frequency.value);
  const [amplitude, setAmplitude] = useState(gain.gain.value * 100);
  const [playing, setPlaying] = useState(false);
  const canvasElRef = useRef<HTMLCanvasElement>(null);

  function handleTypeChange(e: React.ChangeEvent<HTMLSelectElement>) {
    const newType = e.currentTarget.value as OscillatorType;
    osc.type = newType;
    setType(newType);
  }

  function handleFrequencyChange(
    e: React.ChangeEvent<HTMLInputElement>,
  ) {
    let newFrequency = parseInt(e.currentTarget.value);
    if (newFrequency > maxFrequency) {
      newFrequency = maxFrequency;
    }
    setFrequency(newFrequency);
    console.log(newFrequency);
    if (isNaN(newFrequency)) {
      return;
    }
    osc.frequency.value = newFrequency;
  }

  function handleAmplitudeChange(
    e: React.ChangeEvent<HTMLInputElement>,
  ) {
    let newAmplitude = parseInt(e.currentTarget.value);
    if (newAmplitude > maxAmplitude) {
      newAmplitude = maxAmplitude;
    }
    setAmplitude(newAmplitude);
    console.log(newAmplitude);
    if (isNaN(newAmplitude)) {
      return;
    }
    gain.gain.value = newAmplitude / 100;
  }

  function play() {
    if (playing) {
      osc.stop();
    } else {
      osc = audioCtx.createOscillator();
      osc.type = type;
      osc.frequency.setValueAtTime(frequency, audioCtx.currentTime);
      osc.connect(gain).connect(analyser).connect(audioCtx.destination);
      osc.start();
    }
    setPlaying(!playing);
  }

  useEffect(() => {
    if (canvasElRef.current) {
      const canvasEl = canvasElRef.current;
      canvasEl.width = w;
      canvasEl.height = h;
      const canvasCtxOrNull = canvasEl.getContext("2d");
      if (canvasCtxOrNull !== null) {
        canvasCtx = canvasCtxOrNull;
        draw();
      }
    }
  }, []);

  return (
    <div>
      <button data-playing="init" id="play-button" onClick={play}>
        {playing ? "Stop" : "Play"}
      </button>
      <div
        style={{
          display: "flex",
        }}
      >
        <div className="controls">
          <div>
            Waveform shape &nbsp;
            <select
              id="type-select"
              onChange={handleTypeChange}
              value={type}
            >
              <option>sine</option>
              <option>square</option>
              <option>triangle</option>
              <option>sawtooth</option>
            </select>
          </div>
          <div>
            Frequency &nbsp;
            <input
              type="number"
              min={0}
              max={maxFrequency}
              value={frequency}
              onChange={handleFrequencyChange}
              style={{ width: "50px" }}
            />
          </div>
          <div>
            Amplitude &nbsp;
            <input
              type="number"
              min={0}
              max={maxAmplitude}
              value={amplitude}
              onChange={handleAmplitudeChange}
              style={{ width: "50px" }}
            />
          </div>
        </div>
        <canvas ref={canvasElRef}></canvas>
      </div>
    </div>
  );
}

export default App;
