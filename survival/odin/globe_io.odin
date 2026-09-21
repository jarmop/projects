#+feature dynamic-literals

package survival

import "base:runtime"
import "core:fmt"
import "core:math"
import l "core:math/linalg"
import "core:math/linalg/glsl"
import "core:strconv/decimal"
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

globe_tilt_angle: f32 = 65 // -90 - 90
globe_spin_angle: f32 = -115 // -180 - 180

globe_max_tilt_abs: f32 : 90

zoom_levels :: 8
zoom_level_at_start :: 2
camera_zoom_positions := [zoom_levels]f32{0.05, 0.1, 0.25, 0.5, 0.75, 1, 1.25, 1.75}
globe_speeds := [zoom_levels]f32{0.004, 0.008, 0.02, 0.04, 0.065, 0.09, 0.12, 0.18}
globe_speed: f32 = globe_speeds[zoom_level_at_start]

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

globe_io_prev_cursor_x, globe_io_prev_cursor_y: f64

edit_mode := false

brush_max := 30
brush := 0
brush_type := TERRAIN_TYPE.PLAIN
mask_ocean := false

globe_io_init :: proc() {
	if edit_mode {
		glfw.SetInputMode(window, glfw.CURSOR, glfw.CURSOR_HIDDEN)
	}
}

paint :: proc(terrain_type: TERRAIN_TYPE, just_brush := false) {
	cursor_x, cursor_y := glfw.GetCursorPos(window)
	window_width, window_height := glfw.GetWindowSize(window)
	view := get_view()
	projection := get_projection()
	model := get_model()
	is_hit, uv, ring, segment, hit := pick_globe(
		f32(cursor_x),
		f32(cursor_y),
		int(window_width),
		int(window_height),
		projection,
		view,
		model,
		globe_land_radius,
		globe_land_segments,
		globe_land_rings,
	)
	if is_hit {
		// fmt.println("**********")

		land_segments_backup := make(map[int]TERRAIN_TYPE)
		defer delete(land_segments_backup)

		for y in -brush ..= brush {
			r := ring + y
			if r < 0 || r >= globe_land_rings {
				continue
			}
			tile_width := tile_width_per_ring[r]

			brush_at_y := int(math.sqrt(f32(brush * brush - y * y)))

			start_segment := (segment - brush_at_y)
			if start_segment < 0 {
				start_segment += globe_land_segments
			}

			start_segment = start_segment / tile_width * tile_width
			brush_width := max(
				int(math.round(f32(2 * brush_at_y + 1) / f32(tile_width))) * tile_width,
				1,
			)
			end_segment := start_segment + brush_width

			for x := start_segment; x < end_segment; x += 1 {
				s := x
				if s < 0 {
					s += globe_land_segments
				} else if s >= globe_land_segments {
					s -= globe_land_segments
				}

				s_index_on_ring := s
				s_index := r * globe_land_segments + s_index_on_ring

				if (mask_ocean && land_segments[s_index] == TERRAIN_TYPE.OCEAN) {
					if s_index not_in land_segments_backup {
						land_segments_backup[s_index] = land_segments[s_index]
					}
					land_segments[s_index] = TERRAIN_TYPE.MASK
				} else {
					if just_brush && s_index not_in land_segments_backup {
						land_segments_backup[s_index] = land_segments[s_index]
					}
					land_segments[s_index] = terrain_type
				}
			}
		}

		globe_update_land_indices()

		// Erase brush
		for index, terrain_type in land_segments_backup {
			land_segments[index] = terrain_type
		}

		// fmt.println("tilt:", globe_tilt_angle)
		// fmt.println("spin:", globe_spin_angle)
		// latitude := math.asin(hit.y / globe_radius)
		// longitude := math.atan2(hit.z, -hit.x)
		// fmt.println("lat:", math.to_degrees(latitude))
		// fmt.println("lon:", math.to_degrees(longitude))
		// fmt.println("ring:", ring)
		// fmt.println("segment:", segment)
		// fmt.println("u:", uv.x)
		// fmt.println("v:", uv.y)
	}
}

paint_brush :: proc() {
	paint(brush_type, true)
}

print_coordinates :: proc() {
	cursor_x, cursor_y := glfw.GetCursorPos(window)
	window_width, window_height := glfw.GetWindowSize(window)
	view := get_view()
	projection := get_projection()
	model := get_model()
	is_hit, uv, ring, segment, hit := pick_globe(
		f32(cursor_x),
		f32(cursor_y),
		int(window_width),
		int(window_height),
		projection,
		view,
		model,
		globe_land_radius,
		globe_land_segments,
		globe_land_rings,
	)
	// fmt.println("tilt:", globe_tilt_angle)
	// fmt.println("spin:", globe_spin_angle)
	latitude := math.asin(hit.y / globe_radius)
	longitude := math.atan2(hit.z, -hit.x)
	// fmt.println("lat:", math.to_degrees(latitude))
	// fmt.println("lon:", math.to_degrees(longitude))
	fmt.printfln("lat: %.1f, lon: %.1f", math.to_degrees(latitude), math.to_degrees(longitude))
	// fmt.println("ring:", ring)
	// fmt.println("segment:", segment)
	// fmt.println("u:", uv.x)
	// fmt.println("v:", uv.y)
}

globe_io_mouse_button_callback :: proc "c" (window: glfw.WindowHandle, button, action, mods: i32) {
	context = runtime.default_context()

	if button == glfw.MOUSE_BUTTON_LEFT {
		if action == glfw.PRESS {
			globe_io_mouse_left_pressed = true
			print_coordinates()
		} else {
			globe_io_mouse_left_pressed = false
		}
	} else if button == glfw.MOUSE_BUTTON_RIGHT {
		if action == glfw.PRESS {
			globe_io_mouse_right_pressed = true
		} else {
			globe_io_mouse_right_pressed = false
			globe_io_first_cursor_pos_right = true
		}
	}

	if edit_mode && action == glfw.PRESS {
		if button == glfw.MOUSE_BUTTON_LEFT {
			paint(brush_type)
		} else if button == glfw.MOUSE_BUTTON_RIGHT {
			// erase
			paint(TERRAIN_TYPE.OCEAN)
		}
	}
}

rotate_globe :: proc(window: glfw.WindowHandle, x, y: f64) {
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
}

globe_io_cursor_pos_callback :: proc "c" (window: glfw.WindowHandle, x, y: f64) {
	context = runtime.default_context()

	if edit_mode {
		if globe_io_mouse_left_pressed {
			paint(brush_type)
		} else if globe_io_mouse_right_pressed {
			// erase
			paint(TERRAIN_TYPE.OCEAN)
		} else {
			// show cursor
			paint_brush()
		}
	} else if globe_io_mouse_right_pressed {
		rotate_globe(window, x, y)
	}
}

adjust_brush_size :: proc(yoffset: f64) {
	new_brush := yoffset < 0 ? brush + 1 : brush - 1
	if new_brush < 0 || new_brush >= brush_max {
		return
	}
	brush = new_brush
	paint_brush()
}

adjust_zoom_level :: proc(yoffset: f64) {
	new_zoom := yoffset < 0 ? camera.zoom + 1 : camera.zoom - 1
	if new_zoom < 0 || new_zoom >= zoom_levels {
		return
	}

	camera.zoom = new_zoom
	camera.pos.z = globe_radius + camera_zoom_positions[camera.zoom]
	globe_speed = globe_speeds[camera.zoom]
}

globe_io_scroll_callback :: proc "c" (window: glfw.WindowHandle, xoffset: f64, yoffset: f64) {
	context = runtime.default_context()

	if edit_mode {
		adjust_brush_size(yoffset)
	} else {
		adjust_zoom_level(yoffset)
	}
}

terrain_key_map := map[i32]TERRAIN_TYPE {
	glfw.KEY_1 = .FOREST,
	glfw.KEY_2 = .PLAIN,
	glfw.KEY_3 = .MOUNTAIN,
	glfw.KEY_4 = .SAND,
	glfw.KEY_5 = .HILL_PLAIN,
	glfw.KEY_6 = .HILL_FOREST,
	glfw.KEY_7 = .HILL_SAND,
}

globe_io_key_callback :: proc "c" (window: glfw.WindowHandle, key, scancode, action, mode: i32) {
	context = runtime.default_context()

	if action != glfw.PRESS {
		return
	}

	if key == glfw.KEY_E {
		edit_mode = !edit_mode
		if edit_mode {
			paint_brush()
			glfw.SetInputMode(window, glfw.CURSOR, glfw.CURSOR_HIDDEN)
		} else {
			// erase brush
			globe_update_land_indices()
			glfw.SetInputMode(window, glfw.CURSOR, glfw.CURSOR_NORMAL)
		}
	} else if edit_mode {
		if key == glfw.KEY_S {
			save_land()
		} else if key == glfw.KEY_M {
			mask_ocean = !mask_ocean
			paint_brush()
		} else if key in terrain_key_map {
			brush_type = terrain_key_map[key]
			paint_brush()
		}
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
