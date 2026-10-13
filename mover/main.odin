package main

import gl "vendor:OpenGL"
import "vendor:glfw"

main :: proc() {
	window_init()
	vertices_init()
	shader_init()

	gl.Enable(gl.DEPTH_TEST)
	gl.Enable(gl.MULTISAMPLE)

	for !glfw.WindowShouldClose(window) {
		gl.ClearColor(0.1, 0.1, 0.1, 1.0)
		gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)

		vertices_draw()

		window_draw()
	}
}
