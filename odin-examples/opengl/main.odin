package main

import "core:math/linalg/glsl"
import gl "vendor:OpenGL"
import "vendor:glfw"

main :: proc() {
	window_init()
	vertices_init()
	texture_init()
	shader_init()

	gl.Enable(gl.DEPTH_TEST)

	for !glfw.WindowShouldClose(window) {
		gl.ClearColor(0.2, 0.2, 0.2, 1.0)
		gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)

		vertices_draw()

		window_draw()
	}

	gl.DeleteVertexArrays(1, &VAO)
	gl.DeleteBuffers(1, &VBO)
	gl.DeleteProgram(shaderProgram)

	glfw.Terminate()
}
