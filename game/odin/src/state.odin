package game

import "vendor:glfw"
import vk "vendor:vulkan"

// ----------- ENGINE STATE --------------

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
swapchain_image_format: vk.Format

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


// ------------ GAME STATE ---------------

playing := false

map_size :: 20.0
map_center := [3]f32{map_size / 2, 0.0, map_size / 2}

// For rendering (vk.CmdBindVertexBuffers and vk.CmdDraw)
rectangle_vertex_count :: 36
instance_count :: 1
first_vertex :: 0
first_instance :: 0

buffer_size := vk.DeviceSize(rectangle_vertex_count * size_of(Vertex))

creatures := []Creature {
	{pos = map_center + {-5.0, 0.0, 0.0}},
	{pos = map_center + {5.0, 0.0, 0.0}},
}
creature_size :: [3]f32{0.5, 0.5, 0.5}
creature_center :: [3]f32{(creature_size.x / 2), 0, (creature_size.z / 2)}
creature_vertices: [rectangle_vertex_count]Vertex
creature_vertex_buffer: vk.Buffer
selected_creature := -1

path_vertex_count :: 2
path_vertex_buffer_size :: vk.DeviceSize(path_vertex_count * size_of(Vertex))

ground := Object {
	pos = {0.0, -0.5, 0.0},
}
ground_size := [3]f32{map_size, 0.5, map_size}
ground_vertices: [rectangle_vertex_count]Vertex
ground_vertex_buffer: vk.Buffer
