package game

import "base:intrinsics"
import "core:math/linalg"
import vk "vendor:vulkan"

UniformBufferObject :: struct {
	model: matrix[4, 4]f32,
	view:  matrix[4, 4]f32,
	proj:  matrix[4, 4]f32,
	color: [3]f32,
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

init_uniform_buffers :: proc(descriptor_set_layout: ^vk.DescriptorSetLayout) {
	vk.CreateDescriptorSetLayout(device, &descriptor_set_layout_ci, nil, descriptor_set_layout)
	for &o in objects {
		uniform_buffers: [MAX_FRAMES_IN_FLIGHT]vk.Buffer
		create_uniform_buffers(&uniform_buffers, &o.uniform_buffers_mapped)
		create_descriptor_sets(descriptor_set_layout, &uniform_buffers, &o.descriptor_sets)
	}
}

create_uniform_buffers :: proc(
	uniform_buffers: ^[MAX_FRAMES_IN_FLIGHT]vk.Buffer,
	uniform_buffers_mapped: ^[MAX_FRAMES_IN_FLIGHT]rawptr,
) {
	for i := 0; i < MAX_FRAMES_IN_FLIGHT; i += 1 {
		buffer: vk.Buffer

		buffer_size: vk.DeviceSize = size_of(UniformBufferObject)
		buffer_memory: vk.DeviceMemory
		create_buffer(buffer_size, {.UNIFORM_BUFFER}, &buffer, &buffer_memory)
		vk.MapMemory(device, buffer_memory, 0, buffer_size, {}, &uniform_buffers_mapped[i])
		uniform_buffers[i] = buffer
	}
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
			// color = selected_color if is_selected(i) else selected_color,
			// color = selected_color,
		}
		ubo.model = linalg.matrix4_translate(o.pos)
		intrinsics.mem_copy_non_overlapping(
			o.uniform_buffers_mapped[current_frame],
			&ubo,
			size_of(UniformBufferObject),
		)
	}
}

descriptor_pool_ci := vk.DescriptorPoolCreateInfo {
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

descriptor_buffer_info := vk.DescriptorBufferInfo {
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

create_descriptor_sets :: proc(
	descriptor_set_layout: ^vk.DescriptorSetLayout,
	uniform_buffers: ^[MAX_FRAMES_IN_FLIGHT]vk.Buffer,
	descriptor_sets: ^[MAX_FRAMES_IN_FLIGHT]vk.DescriptorSet,
) {
	vk.CreateDescriptorPool(device, &descriptor_pool_ci, nil, &descriptor_set_ai.descriptorPool)
	descriptor_set_layouts := [MAX_FRAMES_IN_FLIGHT]vk.DescriptorSetLayout{descriptor_set_layout^}
	descriptor_set_ai.pSetLayouts = raw_data(&descriptor_set_layouts)
	vk.AllocateDescriptorSets(device, &descriptor_set_ai, raw_data(descriptor_sets))
	for i := 0; i < MAX_FRAMES_IN_FLIGHT; i += 1 {
		descriptor_buffer_info.buffer = uniform_buffers[i]
		write_descriptor_set.dstSet = descriptor_sets[i]
		write_descriptor_set.pBufferInfo = &descriptor_buffer_info
		vk.UpdateDescriptorSets(device, 1, &write_descriptor_set, 0, nil)
	}
}
