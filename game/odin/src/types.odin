package game

import tt "vendor:stb/truetype"
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

Creature :: struct {
	pos:                         [3]f32,
	target:                      [3]f32,
	uniform_buffers_mapped:      [MAX_FRAMES_IN_FLIGHT]rawptr,
	descriptor_sets:             [MAX_FRAMES_IN_FLIGHT]vk.DescriptorSet,
	path_uniform_buffers_mapped: [MAX_FRAMES_IN_FLIGHT]rawptr,
	path_descriptor_sets:        [MAX_FRAMES_IN_FLIGHT]vk.DescriptorSet,
	path_vertex_buffer:          vk.Buffer,
	path_memory_handle:          rawptr,
}

BoundingBox :: struct {
	min: [3]f32,
	max: [3]f32,
}

UniformBufferObject :: struct {
	model: matrix[4, 4]f32,
	view:  matrix[4, 4]f32,
	proj:  matrix[4, 4]f32,
	color: [3]f32,
}
