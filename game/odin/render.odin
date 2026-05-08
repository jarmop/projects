package game

import vk "vendor:vulkan"

record_commands :: proc(image_index: u32) {
	command_buffer_begin_info := vk.CommandBufferBeginInfo {
		sType = .COMMAND_BUFFER_BEGIN_INFO,
	}
	vk.BeginCommandBuffer(command_buffer, &command_buffer_begin_info)

	vk.CmdBindPipeline(command_buffer, .GRAPHICS, pipeline)
	vk.CmdSetViewport(
		command_buffer,
		0,
		1,
		raw_data(
			[]vk.Viewport {
				{
					y = f32(swapchain_extent.height),
					width = f32(swapchain_extent.width),
					height = -f32(swapchain_extent.height),
					maxDepth = 1.0,
				},
			},
		),
	)
	vk.CmdSetScissor(
		command_buffer,
		0,
		1,
		raw_data([]vk.Rect2D{{offset = {0, 0}, extent = swapchain_extent}}),
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

	clear_value := vk.ClearValue {
		color = {float32 = {0.0, 0.0, 0.0, 1.0}},
	}
	color_attachment_info := vk.RenderingAttachmentInfo {
		sType       = .RENDERING_ATTACHMENT_INFO,
		imageView   = swapchain_image_views[image_index],
		imageLayout = .ATTACHMENT_OPTIMAL_KHR,
		loadOp      = .CLEAR,
		clearValue  = clear_value,
	}
	rendering_info := vk.RenderingInfo {
		sType = .RENDERING_INFO,
		renderArea = {extent = swapchain_extent},
		layerCount = 1,
		colorAttachmentCount = 1,
		pColorAttachments = &color_attachment_info,
	}
	vk.CmdBeginRendering(command_buffer, &rendering_info)
	vk.CmdDraw(command_buffer, 6, 1, 0, 0)
	vk.CmdEndRendering(command_buffer)

	image_memory_barrier.oldLayout = .ATTACHMENT_OPTIMAL_KHR
	image_memory_barrier.newLayout = .PRESENT_SRC_KHR
	vk.CmdPipelineBarrier2(command_buffer, &dependency_info)

	vk.EndCommandBuffer(command_buffer)
}
