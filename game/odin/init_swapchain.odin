package game

import "vendor:glfw"
import vk "vendor:vulkan"

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
