package game

import "base:intrinsics"
import "core:os"
import vk "vendor:vulkan"

create_cpu_buffer :: proc(usage_flags: vk.BufferUsageFlags, buffer: ^vk.Buffer, data: rawptr) {
	// CREATE BUFFER WITH MEMORY
	buffer_memory: vk.DeviceMemory
	create_buffer(buffer_size, usage_flags, buffer, &buffer_memory)

	// COPY VERTICES INTO THE BUFFER MEMORY
	memory_handle: rawptr
	vk.MapMemory(device, buffer_memory, 0, buffer_size, {}, &memory_handle)
	intrinsics.mem_copy(memory_handle, data, buffer_size)
	vk.UnmapMemory(device, buffer_memory)
}

// For gpu buffer creation

// create_gpu_buffer :: proc(usage_flags: vk.BufferUsageFlags, buffer: ^vk.Buffer) {
// 	buffer_staging: vk.Buffer
// 	create_cpu_buffer({.TRANSFER_SRC}, &buffer_staging)
// 	buffer_memory: vk.DeviceMemory
// 	create_buffer(buffer_size, usage_flags + {.TRANSFER_DST}, buffer, &buffer_memory)
// 	copy_buffer(buffer_size, buffer_staging, buffer^)
// }

// copy_buffer :: proc(buffer_size: vk.DeviceSize, src_buffer: vk.Buffer, dst_buffer: vk.Buffer) {
// 	// cb: vk.CommandBuffer
// 	// create_command_buffer(&cb)
// 	vk.BeginCommandBuffer(
// 		command_buffer,
// 		&vk.CommandBufferBeginInfo{sType = .COMMAND_BUFFER_BEGIN_INFO},
// 	)
// 	region := vk.BufferCopy {
// 		srcOffset = 0,
// 		dstOffset = 0,
// 		size      = buffer_size,
// 	}
// 	vk.CmdCopyBuffer(command_buffer, src_buffer, dst_buffer, 1, &region)
// 	vk.EndCommandBuffer(command_buffer)
// 	submit_info := vk.SubmitInfo {
// 		sType              = .SUBMIT_INFO,
// 		commandBufferCount = 1,
// 		pCommandBuffers    = &command_buffer,
// 	}
// 	vk.QueueSubmit(queue, 1, &submit_info, {})
// 	vk.QueueWaitIdle(queue)
// }

// create_command_buffer :: proc(cb: ^vk.CommandBuffer) {
// 	command_pool_create_info := vk.CommandPoolCreateInfo {
// 		sType            = .COMMAND_POOL_CREATE_INFO,
// 		flags            = {.RESET_COMMAND_BUFFER},
// 		queueFamilyIndex = queue_family_index,
// 	}
// 	command_pool2: vk.CommandPool
// 	vk.CreateCommandPool(device, &command_pool_create_info, nil, &command_pool2)
// 	command_buffer_allocate_info := vk.CommandBufferAllocateInfo {
// 		sType              = .COMMAND_BUFFER_ALLOCATE_INFO,
// 		commandPool        = command_pool2,
// 		level              = .PRIMARY,
// 		commandBufferCount = 1,
// 	}
// 	vk.AllocateCommandBuffers(device, &command_buffer_allocate_info, cb)
// }

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
