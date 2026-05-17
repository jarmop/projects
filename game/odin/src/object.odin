package game

import "base:intrinsics"
import m "core:math/linalg"
import vk "vendor:vulkan"

creatures := []Object{{pos = map_center + {-5.0, 0.0, 0.0}}, {pos = map_center + {5.0, 0.0, 0.0}}}

ground := Object {
	pos = {0.0, -0.5, 0.0},
}

creature_size := [3]f32{0.5, 0.5, 0.5}
ground_size := [3]f32{map_size, 0.5, map_size}

init_objects :: proc() {
	for &o in creatures {
		o.target = o.pos
	}
	create_rectangle(creature_size, &creature_vertices)
	create_cpu_buffer({.VERTEX_BUFFER}, &creature_vertex_buffer, raw_data(&creature_vertices))

	ground.target = ground.pos
	create_rectangle(ground_size, &ground_vertices)
	create_cpu_buffer({.VERTEX_BUFFER}, &ground_vertex_buffer, raw_data(&ground_vertices))
}

selected_creature := -1

is_selected :: proc(i: int) -> bool {
	return i == selected_creature
}

update_objects :: proc() {
	// UPDATE CREATURES
	creature_color :: [3]f32{1.0, 0.6, 0.2}
	creature_color_selected :: [3]f32{0.0, 0.0, 1.0}
	speed :: 1.0
	movement := speed * (time_now - time_prev_frame)
	for &o, i in creatures {
		if (o.pos != o.target) {
			d := o.target - o.pos
			if (m.length(d) <= movement) {
				o.pos = o.target
			} else {
				o.pos += m.normalize(d) * movement
			}
		}
		update_ubo(
			creature_color_selected if is_selected(i) else creature_color,
			o.pos,
			o.uniform_buffers_mapped,
		)
	}

	// UPDATE GROUND
	update_ubo([3]f32{0.0, 0.5, 0.0}, ground.pos, ground.uniform_buffers_mapped)
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
