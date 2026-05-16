package game

import vk "vendor:vulkan"

Face :: struct {
	normal:   [3]f32,
	vertices: [6][3]f32,
}

Vertex :: struct {
	pos:    [3]f32,
	normal: [3]f32,
}

Object :: struct {
	pos:                    [3]f32,
	uniform_buffers_mapped: [MAX_FRAMES_IN_FLIGHT]rawptr,
	descriptor_sets:        [MAX_FRAMES_IN_FLIGHT]vk.DescriptorSet,
}

BoundingBox :: struct {
	min: [3]f32,
	max: [3]f32,
}
