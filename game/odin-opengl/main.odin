package game

import gl "vendor:OpenGL"
import glfw "vendor:glfw"

main :: proc() {
	glfw.Init()
	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 3)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 3)
	glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)
	window = glfw.CreateWindow(INITIAL_WINDOW_WIDTH, INITIAL_WINDOW_HEIGHT, "Odin Game", nil, nil)
	glfw.MakeContextCurrent(window)

	gl.load_up_to(3, 3, glfw.gl_set_proc_address)
	gl.Viewport(0, 0, INITIAL_WINDOW_WIDTH, INITIAL_WINDOW_HEIGHT)

	init_io()
	init_scene()
	init_ui()

	for !glfw.WindowShouldClose(window) {
		glfw.PollEvents()
		time_now = f32(glfw.GetTime())
		game_time_delta = game_time_speed * (time_now - time_prev_frame)
		if playing {
			game_time += game_time_delta
		}
		handle_camera_movement_keys()
		update_scene()
		time_prev_frame = time_now

		gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)

		draw_scene()
		draw_ui()

		glfw.SwapBuffers(window)
	}
}
