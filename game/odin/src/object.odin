package game

import "base:intrinsics"
import m "core:math/linalg"
import vk "vendor:vulkan"

path_vertex_buffer_memory: vk.DeviceMemory

init_objects :: proc() {
	for &o in creatures {
		o.target = o.pos
	}
	create_rectangle(creature_size, &creature_vertices)
	create_cpu_buffer({.VERTEX_BUFFER}, &creature_vertex_buffer, raw_data(&creature_vertices))

	// path_vertices[0] = {
	// 	pos    = [3]f32{0, 0, 0},
	// 	normal = -world_up,
	// }
	// path_vertices[1] = {
	// 	pos    = [3]f32{0, 5.0, 0},
	// 	normal = -world_up,
	// }
	create_buffer(buffer_size, {.VERTEX_BUFFER}, &path_vertex_buffer, &path_vertex_buffer_memory)
	// copy_to_memory(&path_vertex_buffer_memory, raw_data(&path_vertices))

	ground.target = ground.pos
	create_rectangle(ground_size, &ground_vertices)
	create_cpu_buffer({.VERTEX_BUFFER}, &ground_vertex_buffer, raw_data(&ground_vertices))
}

is_selected :: proc(i: int) -> bool {
	return i == selected_creature
}

update_objects :: proc() {
	// UPDATE CREATURES
	creature_color :: [3]f32{1.0, 0.6, 0.2}
	creature_color_selected :: [3]f32{0.0, 0.0, 1.0}
	path_color :: [3]f32{1.0, 1.0, 1.0}
	ground_color :: [3]f32{0.0, 0.5, 0.0}
	speed :: 1.0
	movement := speed * (time_now - time_prev_frame)
	for &c, i in creatures {
		if (c.pos != c.target) {
			d := c.target - c.pos - creature_center
			if (playing) {
				// Move creature toward the target
				if (m.length(d) <= movement) {
					c.pos = c.target - creature_center
				} else {
					c.pos += m.normalize(d) * movement
				}
			}
			// UPDATE PATH
			path_vertices[0] = {
				pos    = creature_get_center(c),
				normal = world_up,
			}
			path_vertices[1] = {
				pos    = c.target,
				normal = world_up,
			}
			copy_to_memory(&path_vertex_buffer_memory, raw_data(&path_vertices))
			update_ubo(path_color, [3]f32{0, 0, 0}, path_uniform_buffers_mapped)
		}
		update_ubo(
			creature_color_selected if is_selected(i) else creature_color,
			c.pos,
			c.uniform_buffers_mapped,
		)
	}

	// UPDATE GROUND
	update_ubo(ground_color, ground.pos, ground.uniform_buffers_mapped)
}

update_ubo :: proc(
	color: [3]f32,
	pos: [3]f32,
	uniform_buffers_handle: [MAX_FRAMES_IN_FLIGHT]rawptr,
) {
	ubo := UniformBufferObject {
		view  = get_view(),
		proj  = get_proj(),
		color = color,
	}
	ubo.model = m.matrix4_translate(pos)
	intrinsics.mem_copy_non_overlapping(
		uniform_buffers_handle[current_frame],
		&ubo,
		size_of(UniformBufferObject),
	)
}

creature_get_center :: proc(c: Object) -> [3]f32 {
	return c.pos + creature_center
}
