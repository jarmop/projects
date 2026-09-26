#+feature dynamic-literals

package daw

import "core:fmt"
import "core:math"
import "core:os"
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
amplitude: f32 = 0.1
phase: f32 = 0
max_frequency: f32 = 440

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

data_callback :: proc "c" (device: ^ma.device, output: rawptr, input: rawptr, frame_count: u32) {
	samples := cast([^]f32)output

	for i in 0 ..< int(frame_count) {
		samples[i] = waveform_function_map[selected_waveform](phase) * amplitude

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
