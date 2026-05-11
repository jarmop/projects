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
