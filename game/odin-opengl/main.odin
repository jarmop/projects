package game

import "core:fmt"
import "core:os"
import gl "vendor:OpenGL"
import glfw "vendor:glfw"

WINDOW_WIDTH :: 800
WINDOW_HEIGHT :: 600

main :: proc() {
	glfw.Init()
	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 3)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 3)
	glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)
	window := glfw.CreateWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Odin Game", nil, nil)
	glfw.MakeContextCurrent(window)

	gl.load_up_to(3, 3, glfw.gl_set_proc_address)
	gl.Viewport(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)

	glfw.SetKeyCallback(window, key_callback)
	glfw.SetFramebufferSizeCallback(window, framebuffer_size_callback)

	init_text()

	vertices := [?]f32 {
		0.5,
		-0.5,
		0.0,
		1.0,
		0.0,
		0.0,
		-0.5,
		-0.5,
		0.0,
		0.0,
		1.0,
		0.0,
		0.0,
		0.5,
		0.0,
		0.0,
		0.0,
		1.0,
	}

	// The shader loading they create can be replaced with just this
	shaderProgram, loaded_ok := gl.load_shaders_file(
		"./shaders/triangle.vs",
		"./shaders/triangle.fs",
	)
	if !loaded_ok {
		fmt.println("Shader not ok")
		os.exit(-1)
	}

	VBO, VAO: u32
	gl.GenVertexArrays(1, &VAO)
	gl.GenBuffers(1, &VBO)

	gl.BindVertexArray(VAO)

	gl.BindBuffer(gl.ARRAY_BUFFER, VBO)
	gl.BufferData(gl.ARRAY_BUFFER, size_of(vertices), raw_data(&vertices), gl.STATIC_DRAW)

	gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 6 * size_of(f32), 0)
	gl.EnableVertexAttribArray(0)

	gl.VertexAttribPointer(1, 3, gl.FLOAT, gl.FALSE, 6 * size_of(f32), 3 * size_of(f32))
	gl.EnableVertexAttribArray(1)

	for !glfw.WindowShouldClose(window) {
		glfw.PollEvents()

		gl.ClearColor(0.0, 0.0, 0.0, 1.0)
		gl.Clear(gl.COLOR_BUFFER_BIT)

		gl.UseProgram(shaderProgram)
		gl.BindVertexArray(VAO)
		gl.DrawArrays(gl.TRIANGLES, 0, 3)

		draw_text("Hello from stb_truetype", 50, 100)

		glfw.SwapBuffers(window)
	}
}
