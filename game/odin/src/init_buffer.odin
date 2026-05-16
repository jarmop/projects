package game

// import "core:fmt"
import "core:os"
import vk "vendor:vulkan"

create_buffer :: proc(
	buffer_size: vk.DeviceSize,
	usage_flags: vk.BufferUsageFlags,
	buffer: ^vk.Buffer,
	buffer_memory: ^vk.DeviceMemory,
) {
	// CREATE BUFFER
	buffer_ci := vk.BufferCreateInfo {
		sType       = .BUFFER_CREATE_INFO,
		size        = buffer_size,
		usage       = usage_flags,
		sharingMode = .EXCLUSIVE,
	}
	vk.CreateBuffer(device, &buffer_ci, nil, buffer)

	// ALLOCATE MEMORY
	buffer_memory_requirements: vk.MemoryRequirements
	vk.GetBufferMemoryRequirements(device, buffer^, &buffer_memory_requirements)
	// fmt.printfln("buffer memory type requirement: %b", buffer_memory_requirements.memoryTypeBits)
	memory_allocate_info := vk.MemoryAllocateInfo {
		sType           = .MEMORY_ALLOCATE_INFO,
		allocationSize  = buffer_memory_requirements.size,
		// Points to a memory type in the physical device's memory types array
		memoryTypeIndex = find_physical_device_memory_type_index(
			buffer_memory_requirements.memoryTypeBits,
			vk.MemoryPropertyFlags{.HOST_VISIBLE, .HOST_COHERENT},
		),
	}
	vk.AllocateMemory(device, &memory_allocate_info, nil, buffer_memory)

	// BIND THE MEMORY TO THE BUFFER
	vk.BindBufferMemory(device, buffer^, buffer_memory^, 0)
}

find_physical_device_memory_type_index :: proc(
	suitable_memory_types: u32,
	wanted_properties: vk.MemoryPropertyFlags,
) -> u32 {
	pd_memory_properties: vk.PhysicalDeviceMemoryProperties
	vk.GetPhysicalDeviceMemoryProperties(physical_device, &pd_memory_properties)
	pd_memory_type_count := pd_memory_properties.memoryTypeCount
	pd_memory_types := pd_memory_properties.memoryTypes

	for i := u32(0); i < pd_memory_type_count; i += 1 {
		// Continue if the type is not suitable.
		// Apparently the physical device memory types are sorted so that
		// the indices match the buffer's memory type requirement bits
		if suitable_memory_types & (1 << i) == 0 {continue}

		pd_memory_type := pd_memory_types[i]
		// return the index if the memory type's properties match the wanted properties
		if (pd_memory_type.propertyFlags & wanted_properties) == wanted_properties {
			return i
		}
	}
	os.exit(1)
}
