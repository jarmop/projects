package game

import "base:intrinsics"
// import "core:fmt"
import vk "vendor:vulkan"

create_vertex_buffer :: proc() {
	// vertices := [6]Vertex {
	vertices := []Vertex {
		{pos = {0.0, 0.0, 0.0}},
		{pos = {0.5, 0.0, 0.0}},
		{pos = {0.5, 0.0, 0.5}},
		{pos = {0.5, 0.0, 0.5}},
		{pos = {0.0, 0.0, 0.5}},
		{pos = {0.0, 0.0, 0.0}},
	}
	// fmt.println("foo", len(vertices) * size_of(Vertex))
	// fmt.println("bar", size_of(vertices))

	// CREATE STAGED BUFFER
	// create_staged_buffer(vertices, {.VERTEX_BUFFER}, &vertex_buffer)

	// CREATE REGULAR BUFFER
	buffer_size := vk.DeviceSize(len(vertices) * size_of(Vertex))
	buffer_memory: vk.DeviceMemory
	create_buffer(buffer_size, {.VERTEX_BUFFER}, &vertex_buffer, &buffer_memory)
	temp_data: rawptr
	vk.MapMemory(device, buffer_memory, 0, buffer_size, {}, &temp_data)
	intrinsics.mem_copy(temp_data, raw_data(vertices), buffer_size)
	vk.UnmapMemory(device, buffer_memory)
}

create_staged_buffer :: proc(
	vertices: []Vertex,
	usage_flags: vk.BufferUsageFlags,
	buffer: ^vk.Buffer,
) {
	// STAGING BUFFER (in CPU accessible memory)
	buffer_staging: vk.Buffer

	buffer_size := vk.DeviceSize(len(vertices) * size_of(Vertex))
	buffer_memory_staging: vk.DeviceMemory
	create_buffer(buffer_size, {.TRANSFER_SRC}, &buffer_staging, &buffer_memory_staging)
	temp_data: rawptr
	vk.MapMemory(device, buffer_memory_staging, 0, buffer_size, {}, &temp_data)
	intrinsics.mem_copy(temp_data, raw_data(vertices), buffer_size)
	vk.UnmapMemory(device, buffer_memory_staging)

	// FINAL BUFFER (in GPU accessible memory)
	buffer_memory: vk.DeviceMemory
	create_buffer(buffer_size, usage_flags + {.TRANSFER_DST}, buffer, &buffer_memory)

	copy_buffer(buffer_size, buffer_staging, vertex_buffer)
}

copy_buffer :: proc(buffer_size: vk.DeviceSize, src_buffer: vk.Buffer, dst_buffer: vk.Buffer) {
	// cb: vk.CommandBuffer
	// create_command_buffer(&cb)
	// vk.BeginCommandBuffer(cb, &vk.CommandBufferBeginInfo{sType = .COMMAND_BUFFER_BEGIN_INFO})
	// vk.EndCommandBuffer(cb)
	vk.BeginCommandBuffer(
		command_buffer,
		&vk.CommandBufferBeginInfo{sType = .COMMAND_BUFFER_BEGIN_INFO},
	)
	region := vk.BufferCopy {
		srcOffset = 0,
		dstOffset = 0,
		size      = buffer_size,
	}
	vk.CmdCopyBuffer(command_buffer, src_buffer, dst_buffer, 1, &region)
	vk.EndCommandBuffer(command_buffer)
	submit_info := vk.SubmitInfo {
		sType              = .SUBMIT_INFO,
		commandBufferCount = 1,
		pCommandBuffers    = &command_buffer,
	}
	vk.QueueSubmit(queue, 1, &submit_info, {})
	vk.QueueWaitIdle(queue)
}

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
