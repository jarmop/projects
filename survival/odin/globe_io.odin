#+feature dynamic-literals

package survival

import "base:runtime"
import "core:fmt"
import "core:math"
import l "core:math/linalg"
import "core:math/linalg/glsl"
import gl "vendor:OpenGL"
import glfw "vendor:glfw"

Camera :: struct {
	pos:   [3]f32,
	max_z: f32,
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
	pos   = {0, 0, 3},
	max_z = 3,
	front = {0.0, 0.0, -1.0},
	right = {1.0, 0.0, 0.0},
	up    = {0.0, 1.0, 0.0},
	yaw   = -90,
	pitch = -0,
	speed = 0.25,
	fov   = 45.0,
	near  = 0.1,
	far   = 10.0,
}

globe_speed: f32 = 0.22

globe_io_mouse_right_pressed := false
globe_io_first_cursor_pos_right := true
globe_io_prev_cursor_x, globe_io_prev_cursor_y: f64

globe_io_mouse_button_callback :: proc "c" (window: glfw.WindowHandle, button, action, mods: i32) {
	context = runtime.default_context()

	if button == glfw.MOUSE_BUTTON_LEFT && action == glfw.PRESS {
		cursor_x, cursor_y := glfw.GetCursorPos(window)
		window_width, window_height := glfw.GetWindowSize(window)
		view := get_view()
		projection := get_projection()
		model := get_model()
		// is_hit, uv, ring, segment, hit := raycast(
		is_hit, uv, ring, segment, hit := pick_globe(
			f32(cursor_x),
			f32(cursor_y),
			int(window_width),
			int(window_height),
			projection,
			view,
			model,
			globe_radius,
			2 * globe_rings,
			globe_rings,
		)
		if is_hit {
			latitude := math.asin(hit.y / globe_radius)
			longitude := math.atan2(hit.z, -hit.x)

			fmt.println("**********")
			// fmt.println("tilt:", globe_tilt_angle)
			// fmt.println("spin:", globe_spin_angle)
			fmt.println("lat:", math.to_degrees(latitude))
			fmt.println("lon:", math.to_degrees(longitude))
			fmt.println("ring:", ring)
			fmt.println("segment:", segment)
			fmt.println("u:", uv.x)
			fmt.println("v:", uv.y)
		}
	} else if button == glfw.MOUSE_BUTTON_RIGHT {
		if action == glfw.PRESS {
			globe_io_mouse_right_pressed = true
		} else {
			globe_io_mouse_right_pressed = false
			globe_io_first_cursor_pos_right = true
		}
	}
}

globe_io_cursor_pos_callback :: proc "c" (window: glfw.WindowHandle, x, y: f64) {
	context = runtime.default_context()

	if globe_io_mouse_right_pressed {
		if globe_io_first_cursor_pos_right {
			globe_io_prev_cursor_x = x
			globe_io_prev_cursor_y = y
			globe_io_first_cursor_pos_right = false
		}

		globe_spin_angle += f32(x - globe_io_prev_cursor_x) * globe_speed
		globe_tilt_angle += f32(y - globe_io_prev_cursor_y) * globe_speed
		if globe_tilt_angle > globe_max_tilt_abs {
			globe_tilt_angle = globe_max_tilt_abs
		} else if globe_tilt_angle < -globe_max_tilt_abs {
			globe_tilt_angle = -globe_max_tilt_abs
		}

		globe_io_prev_cursor_x = x
		globe_io_prev_cursor_y = y
	}
}

globe_speed_map := map[f32]f32 {
	1.25 = 0.02,
	1.5  = 0.04,
	1.75 = 0.065,
	2    = 0.09,
	2.25 = 0.12,
	2.5  = 0.15,
	2.75 = 0.18,
	3    = 0.21,
}

globe_io_scroll_callback :: proc "c" (window: glfw.WindowHandle, xoffset: f64, yoffset: f64) {
	context = runtime.default_context()
	camera.pos.z = min(
		max(camera.pos.z - f32(yoffset) * camera.speed, globe_radius + camera.speed),
		camera.max_z,
	)
	globe_speed = globe_speed_map[camera.pos.z]
	// fmt.println(camera.pos.z, globe_speed)
}

get_view :: proc() -> glsl.mat4 {
	view: glsl.mat4 = 1
	view *= glsl.mat4LookAt(camera.pos, camera.pos + camera.front, camera.up)
	return view
}

get_projection :: proc() -> glsl.mat4 {
	projection: glsl.mat4 = 1
	window_width, window_height := glfw.GetWindowSize(window)
	projection *= glsl.mat4Perspective(
		glsl.radians_f32(camera.fov),
		f32(window_width) / f32(window_height),
		camera.near,
		camera.far,
	)
	return projection
}

get_model :: proc() -> glsl.mat4 {
	model: glsl.mat4 = 1
	model *= glsl.mat4Rotate({1.0, 0.0, 0.0}, glsl.radians(globe_tilt_angle))
	model *= glsl.mat4Rotate({0.0, 1.0, 0.0}, glsl.radians(globe_spin_angle))
	return model
}
