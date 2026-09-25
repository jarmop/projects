package daw

import "core:fmt"
import "core:math"
import ma "vendor:miniaudio"

sample_rate: f32 = 48000
frequency: f32 = 440
amplitude: f32 = 0.5

phase: f32 = 0

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

	for {}

	ma.device_uninit(&device)
}

data_callback :: proc "c" (device: ^ma.device, output: rawptr, input: rawptr, frame_count: u32) {
	samples := cast([^]f32)output

	for i in 0 ..< int(frame_count) {
		samples[i] = math.sin(phase * 2 * math.PI) * amplitude

		phase += frequency / sample_rate
		if phase >= 1 {
			phase -= 1
		}
	}
}
