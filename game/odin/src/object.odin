package game

import vk "vendor:vulkan"

objects := []Object{{pos = map_center - {5.0, 0.0, 0.0}}, {pos = map_center + {5.0, 0.0, 0.0}}}

ground_object := Object {
	pos = {0.0, -0.5, 0.0},
}

init_objects :: proc() {
	create_creature(&vertex_buffer)
	create_ground()
}

get_bb :: proc(o: Object) -> BoundingBox {
	v2 := o.pos + vertices[0].pos

	bb := BoundingBox {
		min = v2,
		max = v2,
	}

	for v in vertices[1:] {
		v2 = o.pos + v.pos
		for val, i in v2 {
			bb.min[i] = min(val, bb.min[i])
			bb.max[i] = max(val, bb.max[i])
		}

	}

	return bb
}
