import { useEffect, useState } from 'react'
import './App.css'
import {midiToText} from './midi.ts'
import {findChords} from './chords.ts'

let initialized = false;

let midi;

function App() {
  const [midiInput, setMidiInput] = useState<number[]>([]);

  function handleMIDI(event: any) {
      const [status, data1, data2] = event.data;

      const command = status & 0xF0;
      // const channel = (status & 0x0F) + 1;

      // console.log(midiInput)

      // const newMidiInput = [...midiInput];

      if (command === 0x90 && data2 > 0) {
          // console.log(`Note ON: ${data1}, velocity: ${data2}, channel: ${channel}\n`);
          // newMidiInput[data1] = 1;
          setMidiInput((midiInput) => {
            // console.log(midiInput)
            
            const newMidiInput = [...midiInput];
            newMidiInput[data1] = 1;

            return newMidiInput;
          });
      }
      else if (command === 0x80 ||
          (command === 0x90 && data2 === 0)) {
          // console.log(`Note OFF: ${data1}, channel: ${channel}\n`);
          // newMidiInput[data1] = 0;

          setMidiInput((midiInput) => {
            // console.log(midiInput)
            
            const newMidiInput = [...midiInput];
            newMidiInput[data1] = 0;

            return newMidiInput;
          });
        }
      else {
          // console.log(`MIDI: ${Array.from(event.data).join(", ")}\n`);
      }

      // console.log(newMidiInput)

      midiToText(data1);

      // setMidiInput(newMidiInput);
      // setMidiInput(() => {
      //   return []
      // });
  }

  useEffect( function() {
    if (initialized) {
      return;
    }
    initialized = true;

    async function foo() {
      midi = await navigator.requestMIDIAccess();

      for (const input of midi.inputs.values()) {
        // console.log(input.name)
        input.onmidimessage = handleMIDI;
      }
    }

    foo();

    // findChords([1,5,8]);
  }, [])

  const activeNotes: number[] = [];
  midiInput.forEach(function (m, i) {
    if (m === 1) {
      activeNotes.push(i)
    }
  });
  const chord = findChords(activeNotes);

  console.log(midiInput);
  console.log(activeNotes);
  console.log(chord[0]);

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
