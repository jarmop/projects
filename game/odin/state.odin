
package game

import "vendor:glfw"
import vk "vendor:vulkan"

MAX_FRAMES_IN_FLIGHT :: 1

window: glfw.WindowHandle
surface: vk.SurfaceKHR
physical_device: vk.PhysicalDevice
device: vk.Device
swapchain: vk.SwapchainKHR
swapchain_extent: vk.Extent2D
swapchain_image_format: vk.Format
swapchain_images: []vk.Image
swapchain_image_views: []vk.ImageView
command_buffer: vk.CommandBuffer
pipeline: vk.Pipeline
pipeline_layout: vk.PipelineLayout
queue: vk.Queue
image_available_semaphore: vk.Semaphore
render_finished_semaphore: vk.Semaphore
fence: vk.Fence
descriptor_sets: [MAX_FRAMES_IN_FLIGHT]vk.DescriptorSet
descriptor_set_layout: vk.DescriptorSetLayout

current_frame := 0
