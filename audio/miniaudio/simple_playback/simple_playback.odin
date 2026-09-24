package simple_playback

import "core:fmt"
import ma "vendor:miniaudio"

wav_filename: cstring = "bass_c2.wav"

main :: proc() {

	decoder: ma.decoder
	result_decoder_init := ma.decoder_init_file(wav_filename, nil, &decoder)
	if result_decoder_init != .SUCCESS {
		fmt.println("failed to load file")
		return
	}

	device_config := ma.device_config_init(ma.device_type.playback)
	device_config.playback.format = decoder.outputFormat
	device_config.playback.channels = decoder.outputChannels
	device_config.sampleRate = decoder.outputSampleRate
	device_config.dataCallback = data_callback
	device_config.pUserData = &decoder

	device: ma.device
	result_device_init := ma.device_init(nil, &device_config, &device)
	if result_device_init != .SUCCESS {
		fmt.println("failed to open playback device")
		return
	}

	result_device_start := ma.device_start(&device)
	if result_device_start != .SUCCESS {
		fmt.println("failed to start playback device")
		return
	}

	for {}
}

data_callback :: proc "c" (pDevice: ^ma.device, pOutput, pInput: rawptr, frameCount: u32) {
	pDecoder := (^ma.decoder)(pDevice.pUserData)
	if pDecoder == nil {
		return
	}

	ma.decoder_read_pcm_frames(pDecoder, pOutput, u64(frameCount), nil)
}
