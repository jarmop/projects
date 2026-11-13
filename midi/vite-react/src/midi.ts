const noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"];

export function midiToText(midi: number) {
    const octave = Math.floor(midi / 12) - 1;
    const scale_i = midi % 12;

    console.log(noteNames[scale_i], octave);
}