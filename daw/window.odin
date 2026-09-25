#+feature dynamic-literals

package daw

import "base:runtime"
import "core:fmt"
import gl "vendor:OpenGL"
import glfw "vendor:glfw"

WINDOW_WIDTH :: 800
WINDOW_HEIGHT :: 600

window: glfw.WindowHandle

waveform_key_map := map[i32]Waveform {
	glfw.KEY_1 = .Sine,
	glfw.KEY_2 = .Square,
	glfw.KEY_3 = .Triangle,
	glfw.KEY_4 = .Sawtooth,
}

window_init :: proc() {
	glfw.Init()
	window = glfw.CreateWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "DAW", nil, nil)

	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 3)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 3)
	glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)

	glfw.MakeContextCurrent(window)

	gl.load_up_to(3, 3, glfw.gl_set_proc_address)
	// gl.Viewport(0, 0, INITIAL_WINDOW_WIDTH, INITIAL_WINDOW_HEIGHT)

	glfw.SetKeyCallback(window, key_callback)
}

key_callback :: proc "c" (window: glfw.WindowHandle, key, scancode, action, mode: i32) {
	context = runtime.default_context()

	if action != glfw.PRESS {
		return
	}

	if key == glfw.KEY_ESCAPE {
		glfw.SetWindowShouldClose(window, true)
	} else if key in waveform_key_map {
		selected_waveform = waveform_key_map[key]
		update_vertices()
	}
}
