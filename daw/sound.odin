#+feature dynamic-literals

package daw

import "base:runtime"
import "core:fmt"
import "core:math"
import "core:os"
import "core:time"
import ma "vendor:miniaudio"

Waveform :: enum {
	Sine,
	Square,
	Triangle,
	Sawtooth,
}

WaveformFunc :: proc "c" (phase: f32) -> f32

waveform_function_map := map[Waveform]WaveformFunc {
	.Sine     = get_sine_sample,
	.Square   = get_square_sample,
	.Triangle = get_triangle_sample,
	.Sawtooth = get_sawtooth_sample,
}

selected_waveform: Waveform = .Sine

sample_rate: f32 = 48000
frequency: f32 = 94
max_frequency: f32 = 440
amplitude: f32 = 0.04
max_amplitude: f32 = 0.2
phase: f32 = 0
playing := false

play_sound :: proc() {
	config := ma.device_config_init(ma.device_type.playback)

	config.playback.format = ma.format.f32
	config.playback.channels = 1
	config.sampleRate = u32(sample_rate)
	config.dataCallback = data_callback

	device: ma.device

	result := ma.device_init(nil, &config, &device)
	if result != .SUCCESS {
		fmt.println("Failed to initialize audio device")
		return
	}

	result = ma.device_start(&device)
	if result != .SUCCESS {
		fmt.println("Failed to start audio device")
		ma.device_uninit(&device)
		return
	}

	buf: [256]byte
	os.read(os.stdin, buf[:])

	ma.device_uninit(&device)
}

sample_length: f64 = 400
t: time.Tick

attack: f64 = 50
// attack_target is 1
decay: f64 = 50
// decay target is the sustain amplitude
sustain: f64 = 200

release: f64 = 100
// release target is 0

attack_amplitude := amplitude
sustain_amplitude := attack_amplitude * 3 / 4
decay_amplitude := attack_amplitude - sustain_amplitude
release_amplitude := sustain_amplitude

attacking := false
decaying := false
releasing := false
sustaining := false

data_callback :: proc "c" (device: ^ma.device, output: rawptr, input: rawptr, frame_count: u32) {
	context = runtime.default_context()
	amplitude_current: f32
	if playing {
		d := time.duration_milliseconds(time.tick_since(t))
		if attacking {
			if d >= attack {
				amplitude_current = attack_amplitude
				attacking = false
				decaying = true
				t = time.tick_now()
				// fmt.println("decay")
			} else {
				amplitude_current = f32(d / attack) * attack_amplitude
			}
		} else if decaying {
			if d >= decay {
				amplitude_current = sustain_amplitude
				decaying = false
				sustaining = true
				t = time.tick_now()
				// fmt.println("sustain")
			} else {
				amplitude_current = attack_amplitude - f32(d / decay) * decay_amplitude
			}
		} else if sustaining {
			if d >= sustain {
				sustaining = false
				releasing = true
				t = time.tick_now()
				// fmt.println("release")
			}
			amplitude_current = sustain_amplitude
		} else if releasing {
			if d >= release {
				amplitude_current = 0
				releasing = false
				ui_toggle_playback()
			} else {
				amplitude_current = sustain_amplitude - f32(d / release) * release_amplitude
			}
		}

		// ui_toggle_playback()
	}

	samples := cast([^]f32)output

	for i in 0 ..< int(frame_count) {
		if !playing {
			samples[i] = 0
			continue
		}

		samples[i] = waveform_function_map[selected_waveform](phase) * amplitude_current

		phase += frequency / sample_rate
		if phase >= 1 {
			phase -= 1
		}
	}
}

get_sine_sample :: proc "c" (phase: f32) -> f32 {
	return math.sin(phase * 2 * math.PI)
}

get_square_sample :: proc "c" (phase: f32) -> f32 {
	return phase < 0.5 ? 1 : -1
}

get_triangle_sample :: proc "c" (phase: f32) -> f32 {
	return 2 / math.PI * math.asin(get_sine_sample(phase))
}

get_sawtooth_sample :: proc "c" (phase: f32) -> f32 {
	return phase * 2 - 1
}

toggle_playback :: proc() {
	playing = !playing
	if playing {
		attacking = true
		t = time.tick_now()
		// fmt.println("attack")
	}
}
