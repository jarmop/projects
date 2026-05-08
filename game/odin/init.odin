package game

import "core:slice"
import "vendor:glfw"
import vk "vendor:vulkan"

SHADER :: #load("shader.spv")

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

	// CREATE PIPELINE
	create_pipeline()
}

create_swapchain :: proc() {
	surface_caps: vk.SurfaceCapabilitiesKHR
	vk.GetPhysicalDeviceSurfaceCapabilitiesKHR(physical_device, surface, &surface_caps)
	swapchain_extent = choose_surface_extent(surface_caps)

	format_count: u32
	vk.GetPhysicalDeviceSurfaceFormatsKHR(physical_device, surface, &format_count, nil)
	formats := make([]vk.SurfaceFormatKHR, format_count)
	vk.GetPhysicalDeviceSurfaceFormatsKHR(
		physical_device,
		surface,
		&format_count,
		raw_data(formats),
	)
	format := formats[0]
	swapchain_image_format = format.format

	swapchain_create_info := vk.SwapchainCreateInfoKHR {
		sType            = .SWAPCHAIN_CREATE_INFO_KHR,
		surface          = surface,
		minImageCount    = surface_caps.minImageCount + 1,
		imageFormat      = swapchain_image_format,
		imageColorSpace  = format.colorSpace,
		imageExtent      = swapchain_extent,
		imageArrayLayers = 1,
		imageUsage       = {.COLOR_ATTACHMENT},
		imageSharingMode = .EXCLUSIVE,
		preTransform     = surface_caps.currentTransform,
		compositeAlpha   = {.OPAQUE},
		presentMode      = .FIFO,
		clipped          = true,
	}
	vk.CreateSwapchainKHR(device, &swapchain_create_info, nil, &swapchain)

	swapchain_image_count: u32
	vk.GetSwapchainImagesKHR(device, swapchain, &swapchain_image_count, nil)
	swapchain_images = make([]vk.Image, swapchain_image_count)
	vk.GetSwapchainImagesKHR(device, swapchain, &swapchain_image_count, raw_data(swapchain_images))

	swapchain_image_views = make([]vk.ImageView, swapchain_image_count)
	for image, i in swapchain_images {
		image_view_create_info := vk.ImageViewCreateInfo {
			sType = .IMAGE_VIEW_CREATE_INFO,
			image = swapchain_images[i],
			viewType = .D2,
			format = format.format,
			subresourceRange = {aspectMask = {.COLOR}, levelCount = 1, layerCount = 1},
		}
		vk.CreateImageView(device, &image_view_create_info, nil, &swapchain_image_views[i])
	}

}

choose_surface_extent :: proc(caps: vk.SurfaceCapabilitiesKHR) -> vk.Extent2D {
	if (caps.currentExtent.width != max(u32)) {
		return caps.currentExtent
	}

	width, height := glfw.GetFramebufferSize(window)
	return (vk.Extent2D {
				width = clamp(u32(width), caps.minImageExtent.width, caps.maxImageExtent.width),
				height = clamp(
					u32(height),
					caps.minImageExtent.height,
					caps.maxImageExtent.height,
				),
			})
}

create_pipeline :: proc() {
	rendering_create_info := vk.PipelineRenderingCreateInfo {
		sType                   = .PIPELINE_RENDERING_CREATE_INFO,
		colorAttachmentCount    = 1,
		pColorAttachmentFormats = &swapchain_image_format,
	}

	shader_module := create_shader_module(SHADER)

	layout: vk.PipelineLayout
	vk.CreatePipelineLayout(
		device,
		&vk.PipelineLayoutCreateInfo{sType = .PIPELINE_LAYOUT_CREATE_INFO},
		nil,
		&layout,
	)

	pipeline_create_info := vk.GraphicsPipelineCreateInfo {
		sType               = .GRAPHICS_PIPELINE_CREATE_INFO,
		pNext               = &rendering_create_info,
		stageCount          = 2,
		pStages             = raw_data(
			[]vk.PipelineShaderStageCreateInfo {
				{
					sType = .PIPELINE_SHADER_STAGE_CREATE_INFO,
					stage = {.VERTEX},
					module = shader_module,
					pName = "vertMain",
				},
				{
					sType = .PIPELINE_SHADER_STAGE_CREATE_INFO,
					stage = {.FRAGMENT},
					module = shader_module,
					pName = "fragMain",
				},
			},
		),
		pVertexInputState   = &vk.PipelineVertexInputStateCreateInfo {
			sType = .PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO,
		},
		pInputAssemblyState = &vk.PipelineInputAssemblyStateCreateInfo {
			sType = .PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO,
			topology = .TRIANGLE_LIST,
		},
		pViewportState      = &vk.PipelineViewportStateCreateInfo {
			sType = .PIPELINE_VIEWPORT_STATE_CREATE_INFO,
			viewportCount = 1,
			scissorCount = 1,
		},
		pRasterizationState = &vk.PipelineRasterizationStateCreateInfo {
			sType       = .PIPELINE_RASTERIZATION_STATE_CREATE_INFO,
			// polygonMode = .FILL,
			polygonMode = .LINE,
			lineWidth   = 1.0,
		},
		pMultisampleState   = &vk.PipelineMultisampleStateCreateInfo {
			sType = .PIPELINE_MULTISAMPLE_STATE_CREATE_INFO,
			rasterizationSamples = {._1},
		},
		pColorBlendState    = &vk.PipelineColorBlendStateCreateInfo {
			sType = .PIPELINE_COLOR_BLEND_STATE_CREATE_INFO,
			attachmentCount = 1,
			pAttachments = &vk.PipelineColorBlendAttachmentState {
				colorWriteMask = {.R, .G, .B, .A},
			},
		},
		pDynamicState       = &vk.PipelineDynamicStateCreateInfo {
			sType = .PIPELINE_DYNAMIC_STATE_CREATE_INFO,
			dynamicStateCount = 2,
			pDynamicStates = raw_data([]vk.DynamicState{.VIEWPORT, .SCISSOR}),
		},
		layout              = layout,
	}
	vk.CreateGraphicsPipelines(device, 0, 1, &pipeline_create_info, nil, &pipeline)
}

create_shader_module :: proc(code: []byte) -> (module: vk.ShaderModule) {
	as_u32 := slice.reinterpret([]u32, code)

	create_info := vk.ShaderModuleCreateInfo {
		sType    = .SHADER_MODULE_CREATE_INFO,
		codeSize = len(code),
		pCode    = raw_data(as_u32),
	}
	vk.CreateShaderModule(device, &create_info, nil, &module)
	return
}
