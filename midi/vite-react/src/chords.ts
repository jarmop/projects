/**
 * @param notes Unique note ids in order from lowest to highest 
 */
export function getChordName(notes: number[]) {

}

const NOTE_NAMES = [
    "C", "C#", "D", "D#", "E", "F",
    "F#", "G", "G#", "A", "A#", "B"
];

const CHORDS = [
    { name: "",       intervals: [0, 4, 7] },
    { name: "m",      intervals: [0, 3, 7] },
    { name: "dim",    intervals: [0, 3, 6] },
    { name: "aug",    intervals: [0, 4, 8] },
    { name: "sus2",   intervals: [0, 2, 7] },
    { name: "sus4",   intervals: [0, 5, 7] },

    { name: "maj7",   intervals: [0, 4, 7, 11] },
    { name: "7",      intervals: [0, 4, 7, 10] },
    { name: "m7",     intervals: [0, 3, 7, 10] },
    { name: "mMaj7",  intervals: [0, 3, 7, 11] },
    { name: "dim7",   intervals: [0, 3, 6, 9] },
    { name: "m7b5",   intervals: [0, 3, 6, 10] },
    { name: "6",      intervals: [0, 4, 7, 9] },
    { name: "m6",     intervals: [0, 3, 7, 9] },

    { name: "add9",   intervals: [0, 2, 4, 7] },
    { name: "9",      intervals: [0, 2, 4, 7, 10] },
    { name: "maj9",   intervals: [0, 2, 4, 7, 11] },
    { name: "m9",     intervals: [0, 2, 3, 7, 10] }
];

type Chord = {
    name: string,
    root: string,
    quality: string,
    bass: string,
}

export function findChords(notes: number[]) {
    // Remove duplicate MIDI notes.
    notes = [...new Set(notes)];

    if (notes.length < 2) return [];

    // Sort pitch classes and remove duplicate octaves.
    const pitchClasses = [...new Set(
        notes.map(n => ((n % 12) + 12) % 12)
    )].sort((a, b) => a - b);

    const bass = Math.min(...notes) % 12;
    const bassName = NOTE_NAMES[bass]

    const results = [];

    // Try all 12 possible roots.
    for (let root = 0; root < 12; root++) {

        // Calculate intervals relative to this root.
        const intervals = pitchClasses
            .map(n => (n - root + 12) % 12)
            .sort((a, b) => a - b);

        // Compare against known chord structures.
        for (const chord of CHORDS) {

            if (intervals.length !== chord.intervals.length)
                continue;

            const matches = intervals.every(
                (n, i) => n === chord.intervals[i]
            );

            if (!matches) continue;

            let name = NOTE_NAMES[root] + chord.name;

            // Include inversion / bass note.
            if (bass !== root) {
                name += "/" + NOTE_NAMES[bass];
            }

            results.push({
                name,
                root: NOTE_NAMES[root],
                quality: chord.name,
                bass: NOTE_NAMES[bass]
            });
        }
    }

    // Prefer interpretations where the bass is the root.
    results.sort((a: Chord, b: Chord) =>
        (b.root === bassName ? 1 : 0) -
        (a.root === bassName ? 1 : 0)
    );

    return results;
}

// // Examples
// console.log(findChords([60, 64, 67]));
// // C

// console.log(findChords([64, 67, 72]));
// // C/E

// console.log(findChords([60, 63, 67]));
// // Cm

// console.log(findChords([60, 64, 67, 71]));
// // Cmaj7
