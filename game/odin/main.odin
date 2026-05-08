package game

import "vendor:glfw"
import vk "vendor:vulkan"

main :: proc() {
	glfw.Init()
	glfw.WindowHint(glfw.CLIENT_API, glfw.NO_API)
	window = glfw.CreateWindow(800, 600, "Game", nil, nil)
	glfw.SetKeyCallback(window, key_callback)

	init()

	for !glfw.WindowShouldClose(window) {
		glfw.PollEvents()

		update_uniform_buffer()

		vk.WaitForFences(device, 1, &fence, true, max(u64))
		vk.ResetFences(device, 1, &fence)

		image_index: u32
		vk.AcquireNextImageKHR(
			device,
			swapchain,
			max(u64),
			image_available_semaphore,
			0,
			&image_index,
		)

		record_commands(image_index)

		vk.QueueWaitIdle(queue)

		submit_info := vk.SubmitInfo {
			sType                = .SUBMIT_INFO,
			waitSemaphoreCount   = 1,
			pWaitSemaphores      = &image_available_semaphore,
			pWaitDstStageMask    = &vk.PipelineStageFlags{.COLOR_ATTACHMENT_OUTPUT},
			commandBufferCount   = 1,
			pCommandBuffers      = &command_buffer,
			signalSemaphoreCount = 1,
			pSignalSemaphores    = &render_finished_semaphore,
		}
		vk.QueueSubmit(queue, 1, &submit_info, fence)

		present_info := vk.PresentInfoKHR {
			sType              = .PRESENT_INFO_KHR,
			waitSemaphoreCount = 1,
			pWaitSemaphores    = &render_finished_semaphore,
			swapchainCount     = 1,
			pSwapchains        = &swapchain,
			pImageIndices      = &image_index,
		}
		vk.QueuePresentKHR(queue, &present_info)
	}
}
