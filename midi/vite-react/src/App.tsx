import { useEffect, useState } from 'react'
import './App.css'
import {findChords} from './chords.ts'

let initialized = false;

let midi;

function App() {
  const [midiInput, setMidiInput] = useState<number[]>([]);

  function handleMIDI(event: any) {
      const [status, data1, data2] = event.data;

      const command = status & 0xF0;

      if (command === 0x90 && data2 > 0) {
        setMidiInput((midiInput) => {
          const newMidiInput = [...midiInput];
          newMidiInput[data1] = 1;
          return newMidiInput;
        });
      }
      else if (command === 0x80 || (command === 0x90 && data2 === 0)) {
        setMidiInput((midiInput) => {
          const newMidiInput = [...midiInput];
          newMidiInput[data1] = 0;
          return newMidiInput;
        });
      }
  }

  useEffect( function() {
    if (initialized) {
      return;
    }
    initialized = true;

    (async function foo() {
      midi = await navigator.requestMIDIAccess();
      for (const input of midi.inputs.values()) {
        input.onmidimessage = handleMIDI;
      }
    })();
  }, [])

  const activeNotes: number[] = [];
  midiInput.forEach(function (m, i) {
    if (m === 1) {
      activeNotes.push(i)
    }
  });
  const chord = findChords(activeNotes);
  const chordName = chord[0] ? `${chord[0].name}` : ''

  return (
    <>
      {!navigator.requestMIDIAccess && <p>
        Web MIDI API not supported
      </p>}
      <p>{chordName}</p>
    </>
  )
}


export default App
