package engine

import "core:fmt"
import ma "vendor:miniaudio"

main :: proc() {

	engine: ma.engine
	result_init := ma.engine_init(nil, &engine)
	if result_init != .SUCCESS {
		fmt.println("init fail")
	}
	defer ma.engine_uninit(&engine)

	result_play_sound := ma.engine_play_sound(&engine, "bass_c2.wav", nil)
	if result_play_sound != .SUCCESS {
		fmt.println("play fail")
	}

	for {}
}
