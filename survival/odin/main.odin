package survival

import gl "vendor:OpenGL"
import glfw "vendor:glfw"

WINDOW_WIDTH :: 1280
WINDOW_HEIGHT :: 720

main :: proc() {
	glfw.Init()

	window = glfw.CreateWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Odin OpenGL Text", nil, nil)

	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 3)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 3)
	glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)

	glfw.MakeContextCurrent(window)

	// Load OpenGL functions
	gl.load_up_to(3, 3, glfw.gl_set_proc_address)

	init_io()


	// init_world()

	padding: [2]f32 = {4, 7}
	font_size: f32 = 12
	row_height: f32 = font_size + 2 * padding.y
	col_width: f32 = 100
	row_heights: []f32 = {row_height, row_height}
	col_widths: []f32 = {col_width, col_width, col_width, col_width}
	stb_pixel_height := 1.5 * font_size

	init_text(stb_pixel_height)

	init_table(
		{100, 100},
		row_heights,
		col_widths,
		padding,
		font_size,
		{{"Hheader-1", "header-2", "header-3", "header-4"}, {"row-1", "row-2", "row-3", "row-4"}},
	)

	for !glfw.WindowShouldClose(window) {
		glfw.PollEvents()

		gl.Viewport(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)

		gl.ClearColor(0.1, 0.1, 0.1, 1.0)
		gl.Clear(gl.COLOR_BUFFER_BIT)

		// draw_world()
		draw_table()

		glfw.SwapBuffers(window)
	}
}
