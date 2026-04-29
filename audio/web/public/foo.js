const typeSelect = document.getElementById("type-select");
const frequencyControl = document.getElementById("freq-range");
const playButton = document.getElementById("play-button");

const audioCtx = new AudioContext();
const osc = new OscillatorNode(audioCtx, {
  type: typeSelect.value,
  frequency: frequencyControl.valueAsNumber,
});
// Rather than creating a new oscillator for every start and stop
// which you would do in an audio application, we are just going
// to mute/un-mute for demo purposes - this means we need a gain node
const gain = new GainNode(audioCtx);
const analyser = new AnalyserNode(audioCtx, {
  fftSize: 1024,
  smoothingTimeConstant: 0.8,
});
osc.connect(gain).connect(analyser).connect(audioCtx.destination);

typeSelect.addEventListener("change", () => {
  osc.type = typeSelect.value;
});

frequencyControl.addEventListener("input", () => {
  osc.frequency.value = frequencyControl.valueAsNumber;
});

playButton.addEventListener("click", () => {
  if (audioCtx.state === "suspended") {
    audioCtx.resume();
  }

  if (playButton.dataset.playing === "init") {
    osc.start(audioCtx.currentTime);
    playButton.dataset.playing = "true";
    playButton.innerText = "Pause";
  } else if (playButton.dataset.playing === "false") {
    gain.gain.linearRampToValueAtTime(1, audioCtx.currentTime + 0.2);
    playButton.dataset.playing = "true";
    playButton.innerText = "Pause";
  } else if (playButton.dataset.playing === "true") {
    gain.gain.linearRampToValueAtTime(0.0001, audioCtx.currentTime + 0.2);
    playButton.dataset.playing = "false";
    playButton.innerText = "Play";
  }
});
const dpr = window.devicePixelRatio;
const w = 500 * dpr;
const h = 300 * dpr;
const canvasEl = document.getElementById("wave-graph");
canvasEl.width = w;
canvasEl.height = h;
const canvasCtx = canvasEl.getContext("2d");

const bufferLength = analyser.frequencyBinCount;
const dataArray = new Uint8Array(bufferLength);
analyser.getByteTimeDomainData(dataArray);

// draw an oscilloscope of the current oscillator
function draw() {
  analyser.getByteTimeDomainData(dataArray);
//   console.log(dataArray[0]);

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

draw();
