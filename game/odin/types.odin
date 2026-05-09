package game

import vk "vendor:vulkan"

vertex_attribute_count: u32 = 1
vertex_attribute_format: vk.Format = .R32G32B32_SFLOAT
Vertex :: struct {
	pos: [3]f32,
}
