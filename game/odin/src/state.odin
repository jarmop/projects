package game

import "vendor:glfw"
import vk "vendor:vulkan"

MAX_FRAMES_IN_FLIGHT :: 1

window: glfw.WindowHandle
surface: vk.SurfaceKHR
physical_device: vk.PhysicalDevice
device: vk.Device
queue: vk.Queue
swapchain: vk.SwapchainKHR
swapchain_extent: vk.Extent2D
swapchain_images: []vk.Image
swapchain_image_views: []vk.ImageView
command_pool: vk.CommandPool
command_buffer: vk.CommandBuffer
pipeline: vk.Pipeline
pipeline_layout: vk.PipelineLayout
image_available_semaphore: vk.Semaphore
render_finished_semaphore: vk.Semaphore
fence: vk.Fence
vertex_buffer: vk.Buffer
depth_format: vk.Format
depth_image: vk.Image
depth_image_view: vk.ImageView

current_frame := 0
