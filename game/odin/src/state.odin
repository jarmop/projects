package game

import "vendor:glfw"
import vk "vendor:vulkan"

// ENGINE STATE

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

depth_format: vk.Format
depth_image: vk.Image
depth_image_memory: vk.DeviceMemory
depth_image_view: vk.ImageView

command_pool: vk.CommandPool
command_buffer: vk.CommandBuffer

pipeline: vk.Pipeline
pipeline_layout: vk.PipelineLayout

image_available_semaphore: vk.Semaphore
render_finished_semaphore: vk.Semaphore
fence: vk.Fence
current_frame := 0

// GAME STATE

map_size :: 20.0
map_center := [3]f32{map_size / 2, 0.0, map_size / 2}

// For pipeline init
vertex_attribute_format: vk.Format = .R32G32B32_SFLOAT
// For rendering (vk.CmdBindVertexBuffers and vk.CmdDraw)
rectangle_vertex_count :: 36
instance_count :: 1
first_vertex :: 0
first_instance :: 0

buffer_size := vk.DeviceSize(rectangle_vertex_count * size_of(Vertex))

creature_vertices: [rectangle_vertex_count]Vertex
creature_vertex_buffer: vk.Buffer // contents depend on the game state

ground_vertices: [rectangle_vertex_count]Vertex
ground_vertex_buffer: vk.Buffer
