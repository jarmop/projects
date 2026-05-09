package game

import "base:intrinsics"
import "core:math/linalg"
import "core:os"
// import "vendor:glfw"
import vk "vendor:vulkan"

UniformBufferObject :: struct {
	model: matrix[4, 4]f32,
	view:  matrix[4, 4]f32,
	proj:  matrix[4, 4]f32,
}

descriptor_set_layout_ci := vk.DescriptorSetLayoutCreateInfo {
	sType        = .DESCRIPTOR_SET_LAYOUT_CREATE_INFO,
	bindingCount = 1,
	pBindings    = &vk.DescriptorSetLayoutBinding {
		binding = 0,
		descriptorType = .UNIFORM_BUFFER,
		descriptorCount = 1,
		stageFlags = {.VERTEX},
	},
}

init_uniform_buffers :: proc() {
	uniform_buffers: [MAX_FRAMES_IN_FLIGHT]vk.Buffer
	create_uniform_buffers(&uniform_buffers)
	vk.CreateDescriptorSetLayout(device, &descriptor_set_layout_ci, nil, &descriptor_set_layout)
	create_descriptor_sets(&uniform_buffers)
}

uniform_buffers_mapped: [MAX_FRAMES_IN_FLIGHT]rawptr

create_uniform_buffers :: proc(uniform_buffers: ^[MAX_FRAMES_IN_FLIGHT]vk.Buffer) {
	for i := 0; i < MAX_FRAMES_IN_FLIGHT; i += 1 {
		buffer_size: vk.DeviceSize = size_of(UniformBufferObject)
		buffer: vk.Buffer
		buffer_memory: vk.DeviceMemory
		create_buffer(buffer_size, {.UNIFORM_BUFFER}, &buffer, &buffer_memory)
		uniform_buffers[i] = buffer
		vk.MapMemory(device, buffer_memory, 0, buffer_size, {}, &uniform_buffers_mapped[i])
	}
}

pool_ci := vk.DescriptorPoolCreateInfo {
	sType         = .DESCRIPTOR_POOL_CREATE_INFO,
	flags         = {.FREE_DESCRIPTOR_SET},
	maxSets       = MAX_FRAMES_IN_FLIGHT,
	poolSizeCount = 1,
	pPoolSizes    = &vk.DescriptorPoolSize {
		type = .UNIFORM_BUFFER,
		descriptorCount = MAX_FRAMES_IN_FLIGHT,
	},
}

descriptor_set_ai := vk.DescriptorSetAllocateInfo {
	sType              = .DESCRIPTOR_SET_ALLOCATE_INFO,
	descriptorSetCount = MAX_FRAMES_IN_FLIGHT,
}

desc_buf_info := vk.DescriptorBufferInfo {
	offset = 0,
	range  = size_of(UniformBufferObject),
}

write_descriptor_set := vk.WriteDescriptorSet {
	sType           = .WRITE_DESCRIPTOR_SET,
	dstBinding      = 0,
	dstArrayElement = 0,
	descriptorCount = 1,
	descriptorType  = .UNIFORM_BUFFER,
}

create_descriptor_sets :: proc(uniform_buffers: ^[MAX_FRAMES_IN_FLIGHT]vk.Buffer) {
	vk.CreateDescriptorPool(device, &pool_ci, nil, &descriptor_set_ai.descriptorPool)
	descriptor_set_layouts := [MAX_FRAMES_IN_FLIGHT]vk.DescriptorSetLayout{descriptor_set_layout}
	descriptor_set_ai.pSetLayouts = raw_data(&descriptor_set_layouts)
	vk.AllocateDescriptorSets(device, &descriptor_set_ai, raw_data(&descriptor_sets))
	for i := 0; i < MAX_FRAMES_IN_FLIGHT; i += 1 {
		desc_buf_info.buffer = uniform_buffers[i]
		write_descriptor_set.dstSet = descriptor_sets[i]
		write_descriptor_set.pBufferInfo = &desc_buf_info
		vk.UpdateDescriptorSets(device, 1, &write_descriptor_set, 0, nil)
	}
}

update_uniform_buffer :: proc() {
	ubo: UniformBufferObject
	ubo.model = linalg.MATRIX4F32_IDENTITY
	camera_pos_front: [3]f32
	ubo.view = linalg.matrix4_look_at_f32(camera.pos, camera.pos + camera.front, world_up)
	ubo.proj = linalg.matrix4_perspective_f32(
		linalg.to_radians(camera.fov),
		f32(swapchain_extent.width) / f32(swapchain_extent.height),
		0.1,
		100.0,
	)
	intrinsics.mem_copy_non_overlapping(
		uniform_buffers_mapped[current_frame],
		&ubo,
		size_of(UniformBufferObject),
	)
}
