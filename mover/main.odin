package main

import "core:fmt"
import gl "vendor:OpenGL"
import "vendor:glfw"

time_prev_frame: f32
time_delta: f32

main :: proc() {
	window_init()
	shader_init()
	vertices_init()
	animation_init()
	text_init()

	gl.Enable(gl.DEPTH_TEST)
	gl.Enable(gl.MULTISAMPLE)
	gl.ClearColor(0.1, 0.1, 0.1, 1.0)

	for !glfw.WindowShouldClose(window) {
		defer free_all(context.temp_allocator)

		gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)

		time_now := f32(glfw.GetTime())
		time_delta = time_now - time_prev_frame
		time_prev_frame = time_now

		handle_camera_movement_keys()

		vertices_draw()
		animation_draw()
		text_draw()

		glfw.SwapBuffers(window)
		glfw.PollEvents()
	}
}
