package game

import "vendor:glfw"
import vk "vendor:vulkan"

queue_family_index :: 0

init :: proc() {
	// Load the initial Vulkan functions needed for creating the instance
	vk.load_proc_addresses_global(rawptr(glfw.GetInstanceProcAddress))

	instance: vk.Instance
	create_instance(&instance)

	// Load the rest of the Vulkan functions based on the instance
	vk.load_proc_addresses_instance(instance)

	glfw.CreateWindowSurface(instance, window, nil, &surface)

	pick_physical_device(instance)

	create_logical_device()

	swapchain_image_format := create_swapchain()

	create_command_buffers()

	create_sync_objects()

	descriptor_set_layout: vk.DescriptorSetLayout
	init_uniform_buffers(&descriptor_set_layout)

	init_objects()

	create_depth_resources()

	create_pipeline(&swapchain_image_format, &descriptor_set_layout)
}

create_instance :: proc(instance: ^vk.Instance) {
	extensions := glfw.GetRequiredInstanceExtensions()
	create_info := vk.InstanceCreateInfo {
		sType                   = .INSTANCE_CREATE_INFO,
		pApplicationInfo        = &vk.ApplicationInfo{apiVersion = vk.API_VERSION_1_3},
		enabledExtensionCount   = u32(len(extensions)),
		ppEnabledExtensionNames = raw_data(extensions),
	}
	vk.CreateInstance(&create_info, nil, instance)
}

pick_physical_device :: proc(instance: vk.Instance) {
	physical_device_count: u32
	vk.EnumeratePhysicalDevices(instance, &physical_device_count, nil)
	physical_devices := make([]vk.PhysicalDevice, physical_device_count)
	vk.EnumeratePhysicalDevices(instance, &physical_device_count, raw_data(physical_devices))
	physical_device = physical_devices[queue_family_index]
}

create_logical_device :: proc() {
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
	vk.GetDeviceQueue(device, queue_family_index, 0, &queue)
}

create_command_buffers :: proc() {
	command_pool_create_info := vk.CommandPoolCreateInfo {
		sType            = .COMMAND_POOL_CREATE_INFO,
		flags            = {.RESET_COMMAND_BUFFER},
		queueFamilyIndex = queue_family_index,
	}
	vk.CreateCommandPool(device, &command_pool_create_info, nil, &command_pool)
	command_buffer_allocate_info := vk.CommandBufferAllocateInfo {
		sType              = .COMMAND_BUFFER_ALLOCATE_INFO,
		commandPool        = command_pool,
		level              = .PRIMARY,
		commandBufferCount = MAX_FRAMES_IN_FLIGHT,
	}
	command_buffers: [MAX_FRAMES_IN_FLIGHT]vk.CommandBuffer
	vk.AllocateCommandBuffers(
		device,
		&command_buffer_allocate_info,
		&command_buffers[current_frame],
	)
	command_buffer = command_buffers[current_frame]
}

create_sync_objects :: proc() {
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
}

create_depth_resources :: proc() {
	depth_format = find_depth_format()

	// CREATE IMAGE
	image_create_info := vk.ImageCreateInfo {
		sType = .IMAGE_CREATE_INFO,
		imageType = .D2,
		format = depth_format,
		extent = vk.Extent3D {
			width = swapchain_extent.width,
			height = swapchain_extent.height,
			depth = 1,
		},
		mipLevels = 1,
		arrayLayers = 1,
		samples = {._1},
		tiling = .OPTIMAL,
		usage = {.DEPTH_STENCIL_ATTACHMENT},
		sharingMode = .EXCLUSIVE,
		initialLayout = .UNDEFINED,
	}
	vk.CreateImage(device, &image_create_info, nil, &depth_image)
	image_memory_requirements: vk.MemoryRequirements
	vk.GetImageMemoryRequirements(device, depth_image, &image_memory_requirements)
	memory_allocate_info := vk.MemoryAllocateInfo {
		sType           = .MEMORY_ALLOCATE_INFO,
		allocationSize  = image_memory_requirements.size,
		memoryTypeIndex = find_physical_device_memory_type_index(
			image_memory_requirements.memoryTypeBits,
			{.DEVICE_LOCAL},
		),
	}
	depth_image_memory: vk.DeviceMemory
	vk.AllocateMemory(device, &memory_allocate_info, nil, &depth_image_memory)
	vk.BindImageMemory(device, depth_image, depth_image_memory, 0)

	// CREATE IMAGE VIEW
	image_view_create_info := vk.ImageViewCreateInfo {
		sType = .IMAGE_VIEW_CREATE_INFO,
		image = depth_image,
		viewType = .D2,
		format = depth_format,
		subresourceRange = {
			aspectMask = {.DEPTH},
			baseMipLevel = 0,
			levelCount = 1,
			baseArrayLayer = 0,
			layerCount = 1,
		},
	}
	vk.CreateImageView(device, &image_view_create_info, nil, &depth_image_view)
}

find_depth_format :: proc() -> vk.Format {
	candidates := []vk.Format{.D32_SFLOAT, .D32_SFLOAT_S8_UINT, .D24_UNORM_S8_UINT}
	requiredFeatures: vk.FormatFeatureFlags = {.DEPTH_STENCIL_ATTACHMENT}
	format := candidates[0]
	for f in candidates {
		props: vk.FormatProperties
		vk.GetPhysicalDeviceFormatProperties(physical_device, f, &props)
		if ((props.optimalTilingFeatures & requiredFeatures) == requiredFeatures) {
			format = f
			break
		}
	}

	return format
}
