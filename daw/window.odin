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

left_mouse_pressed := false
left_mouse_first_press := true
xpos_prev: f64 = 0
slider_drag := false

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
	glfw.SetMouseButtonCallback(window, mouse_button_callback)
	glfw.SetCursorPosCallback(window, cursor_pos_callback)
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
		update_waveform_vertices()
		update_text_vertices()
	}
}

mouse_button_callback :: proc "c" (window: glfw.WindowHandle, button, action, mods: i32) {
	context = runtime.default_context()

	if button == glfw.MOUSE_BUTTON_LEFT {
		if action == glfw.PRESS {
			left_mouse_pressed = true
			if cursor_within_slider_handle() {
				slider_drag = true
			}
		} else {
			left_mouse_pressed = false
			left_mouse_first_press = true
			slider_drag = false
		}
	}
}

cursor_pos_callback :: proc "c" (window: glfw.WindowHandle, xpos, ypos: f64) {
	context = runtime.default_context()

	if left_mouse_pressed && slider_drag && cursor_within_slider_bar() {
		if left_mouse_first_press {
			xpos_prev = xpos
			left_mouse_first_press = false
		}

		x_diff := xpos - xpos_prev
		xpos_prev = xpos

		new_frequency := frequency + (f32(x_diff) / slider.bar_width * max_frequency)
		frequency = min(max_frequency, max(0, new_frequency))

		update_text_vertices()
		update_slider_vertices()
	}
}

cursor_within_slider_handle :: proc() -> bool {
	x64, y64 := glfw.GetCursorPos(window)
	x := f32(x64)
	y := f32(y64)
	handle_x := frequency / max_frequency * slider.bar_width - slider.handle_size / 2
	handle_y := (-slider.handle_size + slider.bar_height) / 2
	handle_pos := slider.pos + {handle_x, handle_y}
	// fmt.println(handle_pos)
	return(
		x >= handle_pos.x &&
		x <= handle_pos.x + slider.handle_size &&
		y >= handle_pos.y &&
		y <= handle_pos.y + slider.handle_size \
	)
}

cursor_within_slider_bar :: proc() -> bool {
	x64, y64 := glfw.GetCursorPos(window)
	x := f32(x64)
	y := f32(y64)
	return x >= slider.pos.x && x <= slider.pos.x + slider.bar_width
}
