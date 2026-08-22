package survival

import gl "vendor:OpenGL"
import glfw "vendor:glfw"

WINDOW_WIDTH: i32 = 800
WINDOW_HEIGHT: i32 = 600

main :: proc() {
	glfw.Init()

	window = glfw.CreateWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Survival", nil, nil)

	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 3)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 3)
	glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)

	glfw.MakeContextCurrent(window)

	// Load OpenGL functions
	gl.load_up_to(3, 3, glfw.gl_set_proc_address)
	gl.Viewport(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)

	init_io()

	init_world()

	// padding: [2]f32 = {4, 6}
	// font_size: f32 = 10
	// row_height: f32 = font_size + 2 * padding.y
	// col_width: f32 = 100
	// row_heights: []f32 = {row_height, row_height}
	// col_widths: []f32 = {col_width, col_width, col_width, col_width}
	// init_text(font_size)
	// init_table(
	// 	{100, 100},
	// 	row_heights,
	// 	col_widths,
	// 	padding,
	// 	font_size,
	// 	{
	// 		{"Header-1", "Header-2", "Header-3 Header-3 Header-3", "Header-4"},
	// 		{"Row-1", "Row-2", "Row-3", "Row-4"},
	// 	},
	// )

	for !glfw.WindowShouldClose(window) {
		glfw.PollEvents()

		gl.ClearColor(0.1, 0.1, 0.1, 1.0)
		gl.Clear(gl.COLOR_BUFFER_BIT)

		draw_world()
		// draw_table()

		glfw.SwapBuffers(window)
	}
}
