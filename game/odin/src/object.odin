package game

import vk "vendor:vulkan"

Object :: struct {
	pos:                    [3]f32,
	uniform_buffers_mapped: [MAX_FRAMES_IN_FLIGHT]rawptr,
	descriptor_sets:        [MAX_FRAMES_IN_FLIGHT]vk.DescriptorSet,
}

object1 := Object {
	pos = {0.0, 0.0, 0.0},
}

object2 := Object {
	pos = {1.0, 0.0, 0.0},
}

objects := []Object{object1, object2}

BoundingBox :: struct {
	min: [3]f32,
	max: [3]f32,
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
