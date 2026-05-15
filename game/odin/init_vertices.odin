package game

import "base:intrinsics"
import vk "vendor:vulkan"

Face :: struct {
	normal:   [3]f32,
	vertices: [6][3]f32,
}

faces := []Face {
	// top and bottom (XZ)
	{
		normal = {0.0, 1.0, 0.0},
		vertices = {
			{0.0, 0.0, 0.0},
			{0.5, 0.0, 0.0},
			{0.5, 0.0, 0.5},
			{0.5, 0.0, 0.5},
			{0.0, 0.0, 0.5},
			{0.0, 0.0, 0.0},
		},
	},
	// Front and back (XY)
	{
		normal = {0.0, 0.0, 1.0},
		vertices = {
			{0.0, 0.0, 0.0},
			{0.5, 0.0, 0.0},
			{0.5, 0.5, 0.0},
			{0.5, 0.5, 0.0},
			{0.0, 0.5, 0.0},
			{0.0, 0.0, 0.0},
		},
	},
	// left and right (YZ)
	{
		normal = {1.0, 0.0, 0.0},
		vertices = {
			{0.0, 0.0, 0.0},
			{0.0, 0.5, 0.0},
			{0.0, 0.5, 0.5},
			{0.0, 0.5, 0.5},
			{0.0, 0.0, 0.5},
			{0.0, 0.0, 0.0},
		},
	},
}

Vertex :: struct {
	pos:    [3]f32,
	normal: [3]f32,
}
vertices: [36]Vertex
// vertices := []Vertex {
// 	// Rectangle 1
// 	// {pos = {0.0, 0.5, 0.0}},
// 	// {pos = {0.25, 0.6, -0.5}},
// 	// {pos = {0.5, 0.0, 0.5}},
// 	// {pos = {0.5, 0.0, 0.5}},
// 	// {pos = {-0.3, 0.2, 0.3}},
// 	// {pos = {0.0, 0.5, 0.0}},
// 	// Rectangle 2
// 	{pos = {0.0, 0.0, 0.0}},
// 	{pos = {0.5, 0.0, 0.0}},
// 	{pos = {0.5, 0.0, 0.5}},
// 	{pos = {0.5, 0.0, 0.5}},
// 	{pos = {0.0, 0.0, 0.5}},
// 	{pos = {0.0, 0.0, 0.0}},
// 	// Rectangle 2
// 	{pos = {0.0, 0.0, 0.0}},
// 	{pos = {0.5, 0.0, 0.0}},
// 	{pos = {0.5, 0.5, 0.0}},
// 	{pos = {0.5, 0.5, 0.0}},
// 	{pos = {0.0, 0.5, 0.0}},
// 	{pos = {0.0, 0.0, 0.0}},
// }
// For pipeline init
vertex_attribute_format: vk.Format = .R32G32B32_SFLOAT
// For rendering (vk.CmdBindVertexBuffers and vk.CmdDraw)
vertex_count := u32(len(vertices))
instance_count :: 1
first_vertex :: 0
first_instance :: 0

buffer_size := vk.DeviceSize(vertex_count * size_of(Vertex))

create_vertex_buffer :: proc() {
	// for i in 0 ..= 5 {
	// 	vertices[i].normal = {0.0, 1.0, 0.0}
	// }
	// for i in 6 ..= 11 {
	// 	vertices[i].normal = {0.0, 0.0, 1.0}
	// }
	i := 0
	for f, fi in faces {
		for j in 0 ..= 5 {
			vertices[i].normal = -f.normal
			vertices[i].pos = f.vertices[j]
			i += 1
		}
		for j in 0 ..= 5 {
			vertices[i].normal = f.normal
			vertices[i].pos = f.vertices[j] + (0.5 * f.normal)
			i += 1
		}
	}
	create_cpu_buffer({.VERTEX_BUFFER}, &vertex_buffer)
	// create_gpu_buffer({.VERTEX_BUFFER}, &vertex_buffer)
}

create_cpu_buffer :: proc(usage_flags: vk.BufferUsageFlags, buffer: ^vk.Buffer) {
	// CREATE BUFFER WITH MEMORY
	buffer_memory: vk.DeviceMemory
	create_buffer(buffer_size, usage_flags, buffer, &buffer_memory)

	// COPY VERTICES INTO THE BUFFER MEMORY
	memory_handle: rawptr
	vk.MapMemory(device, buffer_memory, 0, buffer_size, {}, &memory_handle)
	intrinsics.mem_copy(memory_handle, raw_data(&vertices), buffer_size)
	vk.UnmapMemory(device, buffer_memory)
}

/* For gpu buffer creation

create_gpu_buffer :: proc(usage_flags: vk.BufferUsageFlags, buffer: ^vk.Buffer) {
	buffer_staging: vk.Buffer
	create_cpu_buffer({.TRANSFER_SRC}, &buffer_staging)
	buffer_memory: vk.DeviceMemory
	create_buffer(buffer_size, usage_flags + {.TRANSFER_DST}, buffer, &buffer_memory)
	copy_buffer(buffer_size, buffer_staging, buffer^)
}

copy_buffer :: proc(buffer_size: vk.DeviceSize, src_buffer: vk.Buffer, dst_buffer: vk.Buffer) {
	// cb: vk.CommandBuffer
	// create_command_buffer(&cb)
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

*/
