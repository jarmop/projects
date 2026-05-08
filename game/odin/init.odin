package game

import "core:slice"
import "vendor:glfw"
import vk "vendor:vulkan"

init :: proc() {
	// Load the initial Vulkan functions needed for creating the instance
	vk.load_proc_addresses_global(rawptr(glfw.GetInstanceProcAddress))

	// CREATE INSTANCE
	extensions := glfw.GetRequiredInstanceExtensions()
	create_info := vk.InstanceCreateInfo {
		sType                   = .INSTANCE_CREATE_INFO,
		pApplicationInfo        = &vk.ApplicationInfo{apiVersion = vk.API_VERSION_1_3},
		enabledExtensionCount   = u32(len(extensions)),
		ppEnabledExtensionNames = raw_data(extensions),
	}
	instance: vk.Instance
	vk.CreateInstance(&create_info, nil, &instance)

	// Load the rest of the Vulkan functions based on the instance
	vk.load_proc_addresses_instance(instance)

	// CREATE SURFACE
	glfw.CreateWindowSurface(instance, window, nil, &surface)

	// PICK PHYSICAL DEVICE
	physical_device_count: u32
	vk.EnumeratePhysicalDevices(instance, &physical_device_count, nil)
	physical_devices := make([]vk.PhysicalDevice, physical_device_count)
	vk.EnumeratePhysicalDevices(instance, &physical_device_count, raw_data(physical_devices))
	queue_family_index: u32 = 0
	physical_device = physical_devices[queue_family_index]

	// CREATE LOGICAL DEVICE
	enabled_vk_13_features := vk.PhysicalDeviceVulkan13Features {
		sType            = .PHYSICAL_DEVICE_VULKAN_1_3_FEATURES,
		synchronization2 = true,
		dynamicRendering = true,
	}
	enabled_vk_11_features := vk.PhysicalDeviceVulkan11Features {
		sType                = .PHYSICAL_DEVICE_VULKAN_1_1_FEATURES,
		pNext                = &enabled_vk_13_features,
		shaderDrawParameters = true,
	}
	enabled_vk_10_features := vk.PhysicalDeviceFeatures {
		fillModeNonSolid = true,
	}
	device_create_info := vk.DeviceCreateInfo {
		sType                   = .DEVICE_CREATE_INFO,
		pNext                   = &enabled_vk_11_features,
		queueCreateInfoCount    = 1,
		pQueueCreateInfos       = raw_data(
			[]vk.DeviceQueueCreateInfo {
				{
					sType = .DEVICE_QUEUE_CREATE_INFO,
					queueFamilyIndex = queue_family_index,
					queueCount = 1,
					pQueuePriorities = raw_data([]f32{1}),
				},
			},
		),
		enabledExtensionCount   = 1,
		ppEnabledExtensionNames = raw_data([]cstring{vk.KHR_SWAPCHAIN_EXTENSION_NAME}),
		pEnabledFeatures        = &enabled_vk_10_features,
	}
	vk.CreateDevice(physical_device, &device_create_info, nil, &device)

	// CREATE SWAPCHAIN
	create_swapchain()

	// CREATE COMMAND BUFFERS
	command_pool_create_info := vk.CommandPoolCreateInfo {
		sType            = .COMMAND_POOL_CREATE_INFO,
		flags            = {.RESET_COMMAND_BUFFER},
		queueFamilyIndex = queue_family_index,
	}
	command_pool: vk.CommandPool
	vk.CreateCommandPool(device, &command_pool_create_info, nil, &command_pool)
	command_buffer_allocate_info := vk.CommandBufferAllocateInfo {
		sType              = .COMMAND_BUFFER_ALLOCATE_INFO,
		commandPool        = command_pool,
		level              = .PRIMARY,
		commandBufferCount = MAX_FRAMES_IN_FLIGHT,
	}
	command_buffers: [MAX_FRAMES_IN_FLIGHT]vk.CommandBuffer
	vk.AllocateCommandBuffers(device, &command_buffer_allocate_info, &command_buffers[0])
	command_buffer = command_buffers[0]

	// GET DEVICE QUEUE
	vk.GetDeviceQueue(device, queue_family_index, 0, &queue)

	// CREATE SYNC OBJECTS
	semaphore_ci := vk.SemaphoreCreateInfo {
		sType = .SEMAPHORE_CREATE_INFO,
	}
	vk.CreateSemaphore(device, &semaphore_ci, nil, &image_available_semaphore)
	vk.CreateSemaphore(device, &semaphore_ci, nil, &render_finished_semaphore)
	fence_ci := vk.FenceCreateInfo {
		sType = .FENCE_CREATE_INFO,
		flags = {.SIGNALED},
	}
	vk.CreateFence(device, &fence_ci, nil, &fence)

	// CREATE UNIFORM BUFFERS
	init_uniform_buffers()

	// CREATE PIPELINE
	create_pipeline()
}
