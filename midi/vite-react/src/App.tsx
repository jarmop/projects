import { useEffect, useState } from 'react'
import './App.css'
import {midiToText} from './midi.ts'

let initialized = false;

let midi;

function App() {
  const [midiInput, setMidiInput] = useState();

  async function onClick() {
    // console.log(midiToText(60));

  }

  function handleMIDI(event: any) {
      const [status, data1, data2] = event.data;

      const command = status & 0xF0;
      const channel = (status & 0x0F) + 1;

      if (command === 0x90 && data2 > 0) {
          console.log(`Note ON: ${data1}, velocity: ${data2}, channel: ${channel}\n`);
      }
      else if (command === 0x80 ||
          (command === 0x90 && data2 === 0)) {
          console.log(`Note OFF: ${data1}, channel: ${channel}\n`);
      }
      else {
          console.log(`MIDI: ${Array.from(event.data).join(", ")}\n`);
      }

      midiToText(data1)
  }

  useEffect( function() {
    if (initialized) {
      return;
    }
    initialized = true;

    async function foo() {
      midi = await navigator.requestMIDIAccess();

      for (const input of midi.inputs.values()) {
        console.log(input.name)
        input.onmidimessage = handleMIDI;
      }
    }

    foo();
  }, [])

  return (
    <>
    <button type='button' onClick={onClick}>Connect MIDI</button>
    {!navigator.requestMIDIAccess && <p>
      Web MIDI API not supported
      </p>}
    </>
  )
}


export default App
