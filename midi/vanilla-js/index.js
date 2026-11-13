const output = document.getElementById("output");

document.getElementById("connect").onclick = async () => {
    if (!navigator.requestMIDIAccess) {
        output.textContent = "Web MIDI API not supported";
        return;
    }

    try {
        const midi = await navigator.requestMIDIAccess();

        output.textContent = "MIDI connected!\n\n";

        // List input devices
        for (const input of midi.inputs.values()) {
            output.textContent += `Input: ${input.name}\n`;

            input.onmidimessage = handleMIDI;
        }

        // List output devices
        for (const device of midi.outputs.values()) {
            output.textContent += `Output: ${device.name}\n`;
        }

        // Detect device connections/disconnections
        midi.onstatechange = (event) => {
            output.textContent +=
                `Device changed: ${event.port.name} (${event.port.state})\n`;
        };

    } catch (error) {
        output.textContent = `MIDI error: ${error.message}`;
    }
};

function handleMIDI(event) {
    const [status, data1, data2] = event.data;

    const command = status & 0xF0;
    const channel = (status & 0x0F) + 1;

    if (command === 0x90 && data2 > 0) {
        output.textContent +=
            `Note ON: ${data1}, velocity: ${data2}, channel: ${channel}\n`;
    }
    else if (command === 0x80 ||
        (command === 0x90 && data2 === 0)) {
        output.textContent +=
            `Note OFF: ${data1}, channel: ${channel}\n`;
    }
    else {
        output.textContent +=
            `MIDI: ${Array.from(event.data).join(", ")}\n`;
    }

    midiToText(data1)
}

musicKeys = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"];

function midiToText(midi) {
    octave = Math.floor(midi / 12) - 1;
    scale_i = midi % 12;

    console.log(musicKeys[scale_i], octave);
}