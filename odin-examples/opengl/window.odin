package main

import "base:runtime"
import "core:fmt"
import "core:math"
import l "core:math/linalg"
import "core:math/linalg/glsl"
import "core:os"
import gl "vendor:OpenGL"
import "vendor:glfw"

SCR_WIDTH :: 800
SCR_HEIGHT :: 600

mouse_sensitivity :: 0.1

Camera :: struct {
	pos:   [3]f32,
	front: [3]f32,
	right: [3]f32,
	up:    [3]f32,
	yaw:   f32,
	pitch: f32,
	speed: f32,
	fov:   f32,
	near:  f32,
	far:   f32,
}

camera := Camera {
	pos   = {8, 8, 8},
	front = {0, 0, -1},
	right = {1, 0, 0},
	up    = {0, 1, 0},
	yaw   = -135,
	pitch = -30,
	speed = 2.5,
	fov   = 45,
	near  = 0.1,
	far   = 100,
}

prev_cursor_x: f32 = 800 / 2
prev_cursor_y: f32 = 600 / 2
// fov: f32 = 45

delta_time: f32 = 0
last_frame: f32 = 0

window: glfw.WindowHandle

mouse_right_pressed := false
first_cursor_pos := true

window_init :: proc() {
	glfw.Init()
	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 3)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 3)
	glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)

	window = glfw.CreateWindow(SCR_WIDTH, SCR_HEIGHT, "LearnOpenGL", nil, nil)
	if window == nil {
		fmt.println("Failed to create GLFW window")
		glfw.Terminate()
		os.exit(-1)
	}
	glfw.MakeContextCurrent(window)

	gl.load_up_to(3, 3, glfw.gl_set_proc_address)

	gl.Viewport(0, 0, SCR_WIDTH, SCR_HEIGHT)

	glfw.SetFramebufferSizeCallback(window, framebuffer_size_callback)
	glfw.SetCursorPosCallback(window, cursor_pos_callback)
	glfw.SetMouseButtonCallback(window, mouse_button_callback)
	glfw.SetScrollCallback(window, scroll_callback)
	glfw.SetKeyCallback(window, key_callback)

	update_camera()
}

window_draw :: proc() {
	glfw.SwapBuffers(window)
	glfw.PollEvents()

	current_frame := f32(glfw.GetTime())
	delta_time = current_frame - last_frame
	last_frame = current_frame

	handle_camera_movement_keys()
}

key_callback :: proc "c" (window: glfw.WindowHandle, key, scancode, action, mode: i32) {
	if glfw.GetKey(window, glfw.KEY_ESCAPE) == glfw.PRESS {
		glfw.SetWindowShouldClose(window, true)
	}
}

framebuffer_size_callback :: proc "c" (window: glfw.WindowHandle, width: i32, height: i32) {
	gl.Viewport(0, 0, width, height)
}

cursor_pos_callback :: proc "c" (window: glfw.WindowHandle, xf64: f64, yf64: f64) {
	context = runtime.default_context()

	if !mouse_right_pressed {
		return
	}

	x := f32(xf64)
	y := f32(yf64)

	if first_cursor_pos {
		prev_cursor_x = x
		prev_cursor_y = y
		first_cursor_pos = false
	}

	camera.yaw += f32((x - prev_cursor_x) * mouse_sensitivity)
	if (camera.yaw > 180) {
		camera.yaw -= 360
	} else if (camera.yaw < -180) {
		camera.yaw += 360
	}
	camera.pitch -= f32((y - prev_cursor_y) * mouse_sensitivity)
	prev_cursor_x = x
	prev_cursor_y = y

	if camera.pitch > 89.0 {
		camera.pitch = 89.0
	} else if camera.pitch < -89.0 {
		camera.pitch = -89.0
	}

	update_camera()
}

mouse_button_callback :: proc "c" (window: glfw.WindowHandle, button, action, mods: i32) {
	if button == glfw.MOUSE_BUTTON_RIGHT {
		if action == glfw.PRESS {
			mouse_right_pressed = true
			glfw.SetInputMode(window, glfw.CURSOR, glfw.CURSOR_DISABLED)
		} else {
			mouse_right_pressed = false
			first_cursor_pos = true
			glfw.SetInputMode(window, glfw.CURSOR, glfw.CURSOR_NORMAL)
		}
	}
}

scroll_callback := proc "c" (window: glfw.WindowHandle, xoffset: f64, yoffset: f64) {
	camera.fov -= f32(yoffset)
	if camera.fov < 1 {
		camera.fov = 1
	}
	if camera.fov > 45 {
		camera.fov = 45
	}
}

handle_camera_movement_keys :: proc() {
	// camera_d := camera.speed * (time_now - time_prev_frame)
	camera_d := delta_time * camera.speed

	// WASD
	if glfw.GetKey(window, glfw.KEY_W) == glfw.PRESS {
		camera.pos += camera.front * camera_d
	}
	if glfw.GetKey(window, glfw.KEY_S) == glfw.PRESS {
		camera.pos -= camera.front * camera_d
	}
	if glfw.GetKey(window, glfw.KEY_A) == glfw.PRESS {
		camera.pos -= camera.right * camera_d
	}
	if glfw.GetKey(window, glfw.KEY_D) == glfw.PRESS {
		camera.pos += camera.right * camera_d
	}

	// Elevation
	if glfw.GetKey(window, glfw.KEY_E) == glfw.PRESS {
		camera.pos += camera.up * camera_d
	}
	if glfw.GetKey(window, glfw.KEY_C) == glfw.PRESS {
		camera.pos -= camera.up * camera_d
	}
}

update_camera :: proc() {
	camera.front[0] = l.cos(l.to_radians(camera.yaw)) * l.cos(l.to_radians(camera.pitch))
	camera.front[1] = l.sin(l.to_radians(camera.pitch))
	camera.front[2] = l.sin(l.to_radians(camera.yaw)) * l.cos(l.to_radians(camera.pitch))
	camera.front = l.normalize(camera.front)
	camera.right = l.cross(camera.front, camera.up)
	camera.right = l.normalize(camera.right)
}
