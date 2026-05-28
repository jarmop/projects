package game

import "core:fmt"
import gl "vendor:OpenGL"
import glfw "vendor:glfw"

main :: proc() {
	fmt.println("Initializing")

	glfw.Init()

	fmt.println("Initialized GLFW")

	window = glfw.CreateWindow(INITIAL_WINDOW_WIDTH, INITIAL_WINDOW_HEIGHT, "Odin Game", nil, nil)

	fmt.println("Initialized window")

	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 3)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 3)
	glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)
	glfw.MakeContextCurrent(window)
	gl.load_up_to(3, 3, glfw.gl_set_proc_address)
	gl.Viewport(0, 0, INITIAL_WINDOW_WIDTH, INITIAL_WINDOW_HEIGHT)

	fmt.println("Initialized OpenGL")

	init_io()
	fmt.println("Initialized IO")

	init_scene()
	fmt.println("Initialized scene")

	init_ui()
	fmt.println("Initialized UI\n")

	for !glfw.WindowShouldClose(window) {
		glfw.PollEvents()
		time_now = f32(glfw.GetTime())
		time_delta = time_now - time_prev_frame
		handle_camera_movement_keys()
		update_scene()
		time_prev_frame = time_now

		gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)

		draw_scene()
		draw_ui()

		glfw.SwapBuffers(window)

		update_framerate()
	}
}

frame_rate_timer: f32 = 0
frame_counter := 0
frame_rate := 60
update_framerate :: proc() {
	frame_counter += 1
	frame_rate_timer += time_delta
	if (frame_rate_timer > 1) {
		frame_rate = frame_counter
		frame_counter = 0
		frame_rate_timer = 0
	}
}
