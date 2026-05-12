package game

import vk "vendor:vulkan"

record_commands :: proc(image_index: u32) {
	vk.BeginCommandBuffer(
		command_buffer,
		&vk.CommandBufferBeginInfo{sType = .COMMAND_BUFFER_BEGIN_INFO},
	)

	vk.CmdBindPipeline(command_buffer, .GRAPHICS, pipeline)
	// If you don't want to flip the projection,
	// Y can be inverted also by flipping the viewport like this:
	// 		Viewport y: 0 --> swapchain.extent.height
	// 		viewport height: swapchain.extent.height --> -swapchain.extent.height
	viewport := vk.Viewport {
		// y        = f32(swapchain_extent.height),
		y        = 0,
		width    = f32(swapchain_extent.width),
		// height   = -f32(swapchain_extent.height),
		height   = f32(swapchain_extent.height),
		maxDepth = 1.0,
	}
	vk.CmdSetViewport(command_buffer, 0, 1, raw_data([]vk.Viewport{viewport}))
	scissor := vk.Rect2D {
		offset = {0, 0},
		extent = swapchain_extent,
	}
	vk.CmdSetScissor(command_buffer, 0, 1, raw_data([]vk.Rect2D{scissor}))

	vertex_offset: vk.DeviceSize = 0
	vk.CmdBindVertexBuffers(
		command_buffer,
		first_instance,
		instance_count,
		&vertex_buffer,
		&vertex_offset,
	)

	image_memory_barrier := vk.ImageMemoryBarrier2 {
		sType = .IMAGE_MEMORY_BARRIER_2,
		srcStageMask = {.COLOR_ATTACHMENT_OUTPUT},
		dstStageMask = {.COLOR_ATTACHMENT_OUTPUT},
		dstAccessMask = {.COLOR_ATTACHMENT_WRITE},
		oldLayout = .UNDEFINED,
		newLayout = .ATTACHMENT_OPTIMAL_KHR,
		srcQueueFamilyIndex = vk.QUEUE_FAMILY_IGNORED,
		dstQueueFamilyIndex = vk.QUEUE_FAMILY_IGNORED,
		image = swapchain_images[image_index],
		subresourceRange = {aspectMask = {.COLOR}, levelCount = 1, layerCount = 1},
	}
	dependency_info := vk.DependencyInfo {
		sType                   = .DEPENDENCY_INFO,
		imageMemoryBarrierCount = 1,
		pImageMemoryBarriers    = &image_memory_barrier,
	}
	vk.CmdPipelineBarrier2(command_buffer, &dependency_info)

	rendering_info := vk.RenderingInfo {
		sType = .RENDERING_INFO,
		renderArea = {extent = swapchain_extent},
		layerCount = 1,
		colorAttachmentCount = 1,
		pColorAttachments = &vk.RenderingAttachmentInfo {
			sType = .RENDERING_ATTACHMENT_INFO,
			imageView = swapchain_image_views[image_index],
			imageLayout = .ATTACHMENT_OPTIMAL_KHR,
			loadOp = .CLEAR,
			clearValue = vk.ClearValue{color = {float32 = {0.0, 0.0, 0.0, 1.0}}},
		},
	}
	vk.CmdBeginRendering(command_buffer, &rendering_info)

	for &o, i in objects {
		vk.CmdBindDescriptorSets(
			command_buffer,
			.GRAPHICS,
			pipeline_layout,
			0, // first set
			1, // descriptor set count
			&o.descriptor_sets[current_frame],
			0, // dynamic offset count
			nil, // dynamic offsets
		)
		vk.CmdDraw(command_buffer, vertex_count, instance_count, first_vertex, first_instance)
	}

	vk.CmdEndRendering(command_buffer)

	image_memory_barrier.oldLayout = .ATTACHMENT_OPTIMAL_KHR
	image_memory_barrier.newLayout = .PRESENT_SRC_KHR
	vk.CmdPipelineBarrier2(command_buffer, &dependency_info)

	vk.EndCommandBuffer(command_buffer)
}
