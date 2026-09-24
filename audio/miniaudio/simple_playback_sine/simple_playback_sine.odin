package simple_playback_sine

import "core:fmt"
import ma "vendor:miniaudio"

DEVICE_FORMAT :: ma.format.f32
DEVICE_CHANNELS :: 2
DEVICE_SAMPLE_RATE :: 48000

main :: proc() {

	sine_wave: ma.waveform
	device_config := ma.device_config_init(ma.device_type.playback)
	device_config.playback.format = DEVICE_FORMAT
	device_config.playback.channels = DEVICE_CHANNELS
	device_config.sampleRate = DEVICE_SAMPLE_RATE
	device_config.dataCallback = data_callback
	device_config.pUserData = &sine_wave

	device: ma.device
	result_device_init := ma.device_init(nil, &device_config, &device)
	if result_device_init != .SUCCESS {
		fmt.println("failed to open playback device")
		return
	}

	fmt.printfln("Device name: %s", device.playback.name)

	sine_wave_config := ma.waveform_config_init(
		device.playback.playback_format,
		device.playback.channels,
		device.sampleRate,
		ma.waveform_type.sine,
		0.2,
		220,
	)
	ma.waveform_init(&sine_wave_config, &sine_wave)

	result_device_start := ma.device_start(&device)
	if result_device_start != .SUCCESS {
		fmt.println("failed to start playback device")
		return
	}

	for {}
}

data_callback :: proc "c" (pDevice: ^ma.device, pOutput, pInput: rawptr, frameCount: u32) {
	pWaveform := (^ma.waveform)(pDevice.pUserData)
	if pWaveform == nil {
		return
	}

	ma.waveform_read_pcm_frames(pWaveform, pOutput, u64(frameCount), nil)
}
