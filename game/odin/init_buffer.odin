package game

import "core:os"
import vk "vendor:vulkan"

create_buffer :: proc(
	buffer_size: vk.DeviceSize,
	usage_flags: vk.BufferUsageFlags,
	buffer: ^vk.Buffer,
	buffer_memory: ^vk.DeviceMemory,
) {
	buffer_ci := vk.BufferCreateInfo {
		sType       = .BUFFER_CREATE_INFO,
		size        = buffer_size,
		usage       = usage_flags,
		sharingMode = .EXCLUSIVE,
	}
	vk.CreateBuffer(device, &buffer_ci, nil, buffer)
	mem_requirements: vk.MemoryRequirements
	vk.GetBufferMemoryRequirements(device, buffer^, &mem_requirements)
	alloc_info := vk.MemoryAllocateInfo {
		sType           = .MEMORY_ALLOCATE_INFO,
		allocationSize  = mem_requirements.size,
		memoryTypeIndex = find_memory_type(mem_requirements.memoryTypeBits),
	}
	vk.AllocateMemory(device, &alloc_info, nil, buffer_memory)
	vk.BindBufferMemory(device, buffer^, buffer_memory^, 0)
}

find_memory_type :: proc(type_filter: u32) -> u32 {
	mem_properties: vk.PhysicalDeviceMemoryProperties
	mem_prop_flags := vk.MemoryPropertyFlags{.HOST_VISIBLE, .HOST_COHERENT}

	vk.GetPhysicalDeviceMemoryProperties(physical_device, &mem_properties)
	for i := u32(0); i < mem_properties.memoryTypeCount; i += 1 {
		a := type_filter & (1 << i)
		b := (mem_properties.memoryTypes[i].propertyFlags & mem_prop_flags) == mem_prop_flags
		if a != 0 && b {
			return i
		}
	}
	os.exit(1)
}
