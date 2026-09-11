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
	min_z: f32,
	max_z: f32,
	front: [3]f32,
	right: [3]f32,
	up:    [3]f32,
	yaw:   f32,
	pitch: f32,
	fov:   f32,
	near:  f32,
	far:   f32,
	zoom:  int,
}

globe_spin_angle: f32 = 0
globe_tilt_angle: f32 = 0
globe_max_tilt_abs: f32 : 90

zoom_levels :: 8
zoom_level_at_start :: 7
camera_zoom_positions := [zoom_levels]f32{0.05, 0.1, 0.25, 0.5, 0.75, 1, 1.25, 1.75}
globe_speeds := [zoom_levels]f32{0.004, 0.008, 0.02, 0.04, 0.065, 0.09, 0.12, 0.18}
globe_speed: f32 = globe_speeds[zoom_level_at_start]

// camera_zoom_positions := [zoom_levels]f32{0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2}
// globe_speeds := [zoom_levels]f32{0.02, 0.04, 0.065, 0.09, 0.12, 0.15, 0.18, 0.21}

camera := Camera {
	pos   = {0, 0, globe_radius + camera_zoom_positions[zoom_level_at_start]},
	min_z = 0.25,
	max_z = 3,
	front = {0.0, 0.0, -1.0},
	right = {1.0, 0.0, 0.0},
	up    = {0.0, 1.0, 0.0},
	yaw   = -90,
	pitch = -0,
	fov   = 45.0,
	near  = 0.001,
	far   = globe_radius + camera_zoom_positions[zoom_levels - 1],
	zoom  = zoom_level_at_start,
}

globe_io_mouse_left_pressed := false

globe_io_mouse_right_pressed := false
globe_io_first_cursor_pos_right := true

edit_mode := false

globe_io_prev_cursor_x, globe_io_prev_cursor_y: f64

brush := 30

paint :: proc(terrain_type: TERRAIN_TYPE) {
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
		// globe_radius,
		// 2 * globe_grid_rings,
		// globe_grid_rings,
		globe_land_radius,
		globe_land_segments,
		globe_land_rings,
	)
	if is_hit {
		for y in -brush ..= brush {
			r := ring + y
			if r < 0 || r >= globe_land_rings {
				continue
			}
			tile_width := tile_width_per_ring[r]
			for x in -brush ..= brush {
				if math.sqrt(f32(y * y + x * x)) > f32(brush) {
					continue
				}
				s := segment + x
				if s < 0 {
					s += globe_land_segments
				} else if s >= globe_land_segments {
					s -= globe_land_segments
				}

				tile_index := r * globe_land_segments + s / tile_width
				land_segments[tile_index] = int(terrain_type)
			}
		}

		delete(globe_land_mesh.indices)
		globe_land_mesh.indices = globe_generate_land_indices()

		gl.BindVertexArray(globe_land_vao)

		gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, globe_land_ebo)
		gl.BufferData(
			gl.ELEMENT_ARRAY_BUFFER,
			len(globe_land_mesh.indices) * size_of(u32),
			raw_data(globe_land_mesh.indices),
			gl.STATIC_DRAW,
		)

		latitude := math.asin(hit.y / globe_radius)
		longitude := math.atan2(hit.z, -hit.x)

		// fmt.println("**********")
		// fmt.println("tilt:", globe_tilt_angle)
		// fmt.println("spin:", globe_spin_angle)
		// fmt.println("lat:", math.to_degrees(latitude))
		// fmt.println("lon:", math.to_degrees(longitude))
		// fmt.println("ring:", ring)
		// fmt.println("segment:", segment)
		// fmt.println("u:", uv.x)
		// fmt.println("v:", uv.y)
	}
}

globe_io_mouse_button_callback :: proc "c" (window: glfw.WindowHandle, button, action, mods: i32) {
	context = runtime.default_context()

	if button == glfw.MOUSE_BUTTON_LEFT {
		if action == glfw.PRESS {
			globe_io_mouse_left_pressed = true
			paint(TERRAIN_TYPE.FOREST)
		} else {
			globe_io_mouse_left_pressed = false
		}

	} else if button == glfw.MOUSE_BUTTON_RIGHT {
		if action == glfw.PRESS {
			globe_io_mouse_right_pressed = true
			if edit_mode {
				paint(TERRAIN_TYPE.OCEAN)
			}
		} else {
			globe_io_mouse_right_pressed = false
			globe_io_first_cursor_pos_right = true
		}
	}
}

globe_io_cursor_pos_callback :: proc "c" (window: glfw.WindowHandle, x, y: f64) {
	context = runtime.default_context()

	if globe_io_mouse_right_pressed {
		if edit_mode {
			paint(TERRAIN_TYPE.OCEAN)
			return
		}

		if globe_io_first_cursor_pos_right {
			globe_io_prev_cursor_x = x
			globe_io_prev_cursor_y = y
			globe_io_first_cursor_pos_right = false
		}

		window_width, window_height := glfw.GetWindowSize(window)
		relative_window_height := f32(600) / f32(window_height)
		// fmt.println(relative_window_height)
		globe_speed_y := globe_speed * relative_window_height
		globe_speed_x := globe_speed_y
		z_rad_ratio := camera.pos.z / globe_radius
		// fmt.println(camera.zoom, z_rad_ratio)
		if z_rad_ratio <= 1.25 {
			theta := globe_tilt_angle / 180 * math.PI
			globe_speed_x = globe_speed_x / math.cos(theta)
		}
		globe_spin_angle += f32(x - globe_io_prev_cursor_x) * globe_speed_x
		globe_tilt_angle += f32(y - globe_io_prev_cursor_y) * globe_speed_y
		if globe_tilt_angle > globe_max_tilt_abs {
			globe_tilt_angle = globe_max_tilt_abs
		} else if globe_tilt_angle < -globe_max_tilt_abs {
			globe_tilt_angle = -globe_max_tilt_abs
		}

		globe_io_prev_cursor_x = x
		globe_io_prev_cursor_y = y
	} else if globe_io_mouse_left_pressed {
		paint(TERRAIN_TYPE.FOREST)
	}
}


globe_io_scroll_callback :: proc "c" (window: glfw.WindowHandle, xoffset: f64, yoffset: f64) {
	context = runtime.default_context()

	new_zoom := yoffset < 0 ? camera.zoom + 1 : camera.zoom - 1
	if new_zoom < 0 || new_zoom >= zoom_levels {
		return
	}

	camera.zoom = new_zoom
	camera.pos.z = globe_radius + camera_zoom_positions[camera.zoom]
	globe_speed = globe_speeds[camera.zoom]
}

globe_io_key_callback :: proc "c" (window: glfw.WindowHandle, key, scancode, action, mode: i32) {
	if key == glfw.KEY_E && action == glfw.PRESS {
		edit_mode = !edit_mode
	}
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
