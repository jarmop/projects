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
// amplitude: f32 = 0.04
amplitude: f32 = 0.2
// max_amplitude: f32 = 0.2
max_amplitude: f32 = 1.0
phase: f32 = 0
playing := false

EnvelopeSegment :: struct {
	duration:   f32,
	amp_target: f32,
}

envelope_max_duration: f32 = 400

envelope_i := 0

t: time.Tick
t2: time.Tick

play_sound :: proc() {
	update_envelope()

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

envelope: [4]EnvelopeSegment

update_envelope :: proc() {
	envelope[0] = { 	// attack
		duration   = 50,
		amp_target = amplitude,
	}
	envelope[1] = { 	// decay
		duration   = 50,
		amp_target = envelope[0].amp_target * 3 / 4,
	}
	envelope[2] = { 	// sustain
		duration   = 800,
		amp_target = envelope[1].amp_target,
	}
	envelope[3] = { 	// release
		duration   = 100,
		amp_target = 0,
	}

	// envelope[0] = { 	// attack
	// 	duration   = 50,
	// 	amp_target = amplitude,
	// }
	// // envelope[1] = { 	// decay
	// // 	duration   = 50,
	// // 	amp_target = envelope[0].amp_target * 3 / 4,
	// // }
	// // envelope[2] = { 	// sustain
	// // 	duration   = 200,
	// // 	amp_target = envelope[1].amp_target,
	// // }
	// envelope[1] = { 	// release
	// 	duration   = 50,
	// 	amp_target = 0,
	// }
}

amplitude_current: f64 = 0

time_d2: f64 = 0

data_callback :: proc "c" (device: ^ma.device, output: rawptr, input: rawptr, frame_count: u32) {
	context = runtime.default_context()
	// amplitude_current: f32

	// segment := envelope[envelope_i]
	// amp_start: f32 = envelope_i == 0 ? 0 : envelope[envelope_i - 1].amp_target
	// amp_end := segment.amp_target
	// amp_diff := amp_end - amp_start

	// if playing {
	// 	d := f32(time.duration_milliseconds(time.tick_since(t)))
	// 	ep := envelope[envelope_i]
	// 	if d >= ep.duration {
	// 		amplitude_current = ep.amp_target
	// 		if envelope_i == 3 {
	// 			toggle_playback()
	// 		} else {
	// 			envelope_i += 1
	// 		}
	// 		t = time.tick_now()
	// 	} else {
	// 		prev_amp_target := envelope_i == 0 ? 0 : envelope[envelope_i - 1].amp_target
	// 		amp_diff := ep.amp_target - prev_amp_target
	// 		amplitude_current = prev_amp_target + d / ep.duration * amp_diff
	// 	}
	// }


	segment := envelope[envelope_i]
	amp_start: f32 = envelope_i == 0 ? 0 : envelope[envelope_i - 1].amp_target
	amp_end := segment.amp_target
	amp_d := amp_end - amp_start

	// time_d: f32
	// if playing {
	time_d := f32(time.duration_milliseconds(time.tick_since(t)))

	// 	if time_d >= segment.duration {
	// 		amplitude_current = f64(amp_end)
	// 		if envelope_i == len(envelope) - 1 {
	// 			toggle_playback()
	// 		} else {
	// 			envelope_i += 1
	// 		}
	// 		t = time.tick_now()
	// 	}
	// }

	// segment = envelope[envelope_i]


	// amplitude_current := amp_start + time_d / segment.duration * amp_d

	// time_d2 = time.duration_milliseconds(time.tick_since(t2))
	// t2 = time.tick_now()
	// tc := time_d2 / f64(segment.duration)

	// avg_samples_duration := f64(frame_count) / f64(sample_rate) * 1000
	ms_per_frame := 1000 / sample_rate
	amp_increment_per_ms := f64(amp_d / segment.duration)
	amp_increment_per_frame := amp_increment_per_ms / 48

	if playing {
		// fmt.println(amp_d, segment.duration)
		// fmt.println(amp_increment_per_frame)
	}

	// amp_increment := 1 / f64(frame_count) * tc * f64(amp_d)

	samples := cast([^]f32)output
	for i in 0 ..< int(frame_count) {
		if !playing {
			samples[i] = 0
			continue
		}

		// if amplitude_current >= f64(amp_end) {
		// 	if envelope_i == len(envelope) - 1 {
		// 		toggle_playback()
		// 	}
		// }

		reached_amp_target :=
			amp_increment_per_frame >= 0 ? (amplitude_current + amp_increment_per_frame) >= f64(amp_end) : (amplitude_current + amp_increment_per_frame) < f64(amp_end)

		reached_time_target := time_d >= segment.duration

		if (reached_amp_target && reached_time_target) ||
		   (amplitude_current + amp_increment_per_frame) < 0 {
			// if (amp_increment_per_frame != 0 && reached_amp_target) || reached_time_target {
			// if reached_time_target {
			if envelope_i == len(envelope) - 1 {
				fmt.println("a")
				toggle_playback()
				samples[i] = 0
				continue
			} else {
				fmt.println("b")

				envelope_i += 1
				t = time.tick_now()

				segment = envelope[envelope_i]
				amp_start = envelope_i == 0 ? 0 : envelope[envelope_i - 1].amp_target
				amp_end = segment.amp_target
				amp_d = amp_end - amp_start

				amp_increment_per_ms = f64(amp_d / segment.duration)
				amp_increment_per_frame = amp_increment_per_ms / 48

				// fmt.println(amp_increment_per_frame)
			}
		}


		amplitude_current += amp_increment_per_frame
		// fmt.println(amplitude_current)


		// amplitude_current =
		// 	amplitude_current == f64(amp_end) ? amplitude_current : amplitude_current + amp_increment

		// fmt.printfln("%.3f", amplitude_current)


		samples[i] = waveform_function_map[selected_waveform](phase) * f32(amplitude_current)

		phase += frequency / sample_rate
		if phase >= 1 {
			phase -= 1
		}
	}


	if playing {
		// fmt.println(amp_increment, amplitude_current)
		// fmt.println(time_d2)
		// fmt.println(avg_samples_duration)
		fmt.printfln("callback end: %.3f", amplitude_current)
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
		fmt.println("playing")
		envelope_i = 0
		amplitude_current = 0
		t = time.tick_now()
		t2 = time.tick_now()
	}
}
