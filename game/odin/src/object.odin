package game

import "base:intrinsics"
import m "core:math/linalg"
import vk "vendor:vulkan"

objects := []Object{{pos = map_center + {-5.0, 0.0, 0.0}}, {pos = map_center + {5.0, 0.0, 0.0}}}

ground_object := Object {
	pos = {0.0, -0.5, 0.0},
}

creature_size := [3]f32{0.5, 0.5, 0.5}
ground_size := [3]f32{map_size, 0.5, map_size}

init_objects :: proc() {
	for &o in objects {
		o.target = o.pos
	}
	create_rectangle(creature_size, &vertices)
	create_cpu_buffer({.VERTEX_BUFFER}, &vertex_buffer, raw_data(&vertices))

	ground_object.target = ground_object.pos
	create_rectangle(ground_size, &ground_vertices)
	create_cpu_buffer({.VERTEX_BUFFER}, &ground_vertex_buffer, raw_data(&ground_vertices))
}

selected_object := -1

is_selected :: proc(i: int) -> bool {
	return i == selected_object
}

selected_color :: [3]f32{0.0, 0.0, 1.0}

update_uniform_buffer :: proc() {
	view := get_view()
	proj := get_proj()

	for o, i in objects {
		ubo := UniformBufferObject {
			view  = view,
			proj  = proj,
			color = selected_color if is_selected(i) else [3]f32{1.0, 0.6, 0.2},
		}
		ubo.model = m.matrix4_translate(o.pos)
		intrinsics.mem_copy_non_overlapping(
			o.uniform_buffers_mapped[current_frame],
			&ubo,
			size_of(UniformBufferObject),
		)
	}

	ubo := UniformBufferObject {
		view  = view,
		proj  = proj,
		color = [3]f32{0.0, 0.5, 0.0},
	}
	ubo.model = m.matrix4_translate(ground_object.pos)
	intrinsics.mem_copy_non_overlapping(
		ground_object.uniform_buffers_mapped[current_frame],
		&ubo,
		size_of(UniformBufferObject),
	)
}

update_creatures :: proc() {
	speed: f32 = 1.0
	movement := speed * (time_now - time_prev_frame)
	for &o, i in objects {
		if (o.pos != o.target) {
			d := o.target - o.pos
			if (m.length(d) <= movement) {
				o.pos = o.target
			} else {
				o.pos += m.normalize(d) * movement
			}

		}
	}
}
