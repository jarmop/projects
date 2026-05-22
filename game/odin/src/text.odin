#+feature dynamic-literals
package game

import "base:intrinsics"
import "core:os"
import tt "vendor:stb/truetype"
import vk "vendor:vulkan"

TextVertex :: struct {
	pos:   [2]f32,
	uv:    [2]f32,
	color: [4]f32,
}

Glyph_Count :: 96

Font :: struct {
	atlas_width:    i32,
	atlas_height:   i32,
	atlas_pixels:   []u8,
	baked_chars:    [Glyph_Count]tt.bakedchar,
	image:          vk.Image,
	image_view:     vk.ImageView,
	sampler:        vk.Sampler,
	descriptor_set: vk.DescriptorSet,
}

text_buffer: vk.Buffer
// text_uniform_buffers_mapped: [MAX_FRAMES_IN_FLIGHT]rawptr
// text_descriptor_sets: [MAX_FRAMES_IN_FLIGHT]vk.DescriptorSet

ttf_path :: "/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf"
pixel_height :: 14
font := Font {
	// image = text_image,
	// image_view = text_image_view,
	// sampler = text_sampler,
	// descriptor_set = text
}

text_memory_handle: rawptr

init_text :: proc() {
	text_image_format: vk.Format : .R8_UNORM
	text_vertex_count :: 65536
	text_buffer_size :: vk.DeviceSize(text_vertex_count * size_of(TextVertex))

	// text_image: vk.Image
	text_image_memory: vk.DeviceMemory
	// text_image_view: vk.ImageView
	// text_sampler: vk.Sampler
	text_descriptor_set_layout: vk.DescriptorSetLayout
	text_buffer_memory: vk.DeviceMemory
	descriptor_pool: vk.DescriptorPool

	load_font()

	image_create_info := vk.ImageCreateInfo {
		sType = .IMAGE_CREATE_INFO,
		imageType = .D2,
		format = text_image_format,
		extent = vk.Extent3D {
			// width = swapchain_extent.width,
			width  = u32(font.atlas_width),
			// height = swapchain_extent.height,
			height = u32(font.atlas_height),
			depth  = 1,
		},
		mipLevels = 1,
		arrayLayers = 1,
		samples = {._1},
		// tiling = .OPTIMAL,
		usage = {.TRANSFER_DST, .SAMPLED},
		// sharingMode = .EXCLUSIVE,
		initialLayout = .UNDEFINED,
		// initialLayout = .SHADER_READ_ONLY_OPTIMAL,
	}
	vk.CreateImage(device, &image_create_info, nil, &font.image)
	image_memory_requirements: vk.MemoryRequirements
	vk.GetImageMemoryRequirements(device, font.image, &image_memory_requirements)
	image_memory_allocate_info := vk.MemoryAllocateInfo {
		sType           = .MEMORY_ALLOCATE_INFO,
		allocationSize  = image_memory_requirements.size,
		memoryTypeIndex = find_physical_device_memory_type_index(
			image_memory_requirements.memoryTypeBits,
			{.DEVICE_LOCAL},
		),
	}
	vk.AllocateMemory(device, &image_memory_allocate_info, nil, &text_image_memory)
	vk.BindImageMemory(device, font.image, text_image_memory, 0)

	image_view_create_info := vk.ImageViewCreateInfo {
		sType = .IMAGE_VIEW_CREATE_INFO,
		image = font.image,
		viewType = .D2,
		format = text_image_format,
		subresourceRange = {
			aspectMask = {.COLOR},
			// baseMipLevel = 0,
			levelCount = 1,
			// baseArrayLayer = 0,
			layerCount = 1,
		},
	}
	vk.CreateImageView(device, &image_view_create_info, nil, &font.image_view)

	sampler_create_info := vk.SamplerCreateInfo {
		sType        = .SAMPLER_CREATE_INFO,
		minFilter    = .LINEAR,
		magFilter    = .LINEAR,
		mipmapMode   = .LINEAR,
		addressModeU = .CLAMP_TO_EDGE,
		addressModeV = .CLAMP_TO_EDGE,
		addressModeW = .CLAMP_TO_EDGE,
	}
	vk.CreateSampler(device, &sampler_create_info, nil, &font.sampler)

	descriptor_set_layout_bindings := []vk.DescriptorSetLayoutBinding {
		{
			binding = 0,
			descriptorType = .SAMPLED_IMAGE,
			descriptorCount = 1,
			stageFlags = {.FRAGMENT},
		},
		{binding = 1, descriptorType = .SAMPLER, descriptorCount = 1, stageFlags = {.FRAGMENT}},
	}
	descriptor_set_layout_ci := vk.DescriptorSetLayoutCreateInfo {
		sType        = .DESCRIPTOR_SET_LAYOUT_CREATE_INFO,
		bindingCount = u32(len(descriptor_set_layout_bindings)),
		pBindings    = raw_data(descriptor_set_layout_bindings),
	}
	vk.CreateDescriptorSetLayout(
		device,
		&descriptor_set_layout_ci,
		nil,
		&text_descriptor_set_layout,
	)

	descriptor_pool_sizes := []vk.DescriptorPoolSize {
		{
			type            = .SAMPLED_IMAGE,
			descriptorCount = 1,
			// descriptorCount = MAX_FRAMES_IN_FLIGHT,
		},
		{
			type            = .SAMPLER,
			descriptorCount = 1,
			// descriptorCount = MAX_FRAMES_IN_FLIGHT,
		},
	}
	descriptor_pool_ci := vk.DescriptorPoolCreateInfo {
		sType         = .DESCRIPTOR_POOL_CREATE_INFO,
		flags         = {.FREE_DESCRIPTOR_SET},
		maxSets       = 1,
		// maxSets       = MAX_FRAMES_IN_FLIGHT,
		poolSizeCount = u32(len(descriptor_pool_sizes)),
		pPoolSizes    = raw_data(descriptor_pool_sizes),
	}
	vk.CreateDescriptorPool(device, &descriptor_pool_ci, nil, &descriptor_pool)

	descriptor_set_ai := vk.DescriptorSetAllocateInfo {
		sType              = .DESCRIPTOR_SET_ALLOCATE_INFO,
		descriptorPool     = descriptor_pool,
		descriptorSetCount = 1,
		pSetLayouts        = &text_descriptor_set_layout,
	}
	vk.AllocateDescriptorSets(device, &descriptor_set_ai, &font.descriptor_set)

	image_info := vk.DescriptorImageInfo {
		imageView   = font.image_view,
		imageLayout = .SHADER_READ_ONLY_OPTIMAL,
	}
	write_image := vk.WriteDescriptorSet {
		sType           = .WRITE_DESCRIPTOR_SET,
		dstSet          = font.descriptor_set,
		dstBinding      = 0,
		// dstArrayElement = 0,
		descriptorCount = 1,
		descriptorType  = .SAMPLED_IMAGE,
		pImageInfo      = &image_info,
	}
	sampler_info := vk.DescriptorImageInfo {
		sampler = font.sampler,
	}
	write_sampler := vk.WriteDescriptorSet {
		sType           = .WRITE_DESCRIPTOR_SET,
		dstSet          = font.descriptor_set,
		dstBinding      = 1,
		descriptorCount = 1,
		descriptorType  = .SAMPLER,
		pImageInfo      = &sampler_info,
	}
	writes := [?]vk.WriteDescriptorSet{write_image, write_sampler}

	vk.UpdateDescriptorSets(device, len(writes), &writes[0], 0, nil)

	text_staging_buffer_size := vk.DeviceSize(len(font.atlas_pixels))
	text_staging_buffer: vk.Buffer
	text_staging_memory: vk.DeviceMemory
	create_buffer(
		text_staging_buffer_size,
		// {.TRANSFER_SRC, .VERTEX_BUFFER},
		{.TRANSFER_SRC},
		&text_staging_buffer,
		&text_staging_memory,
	)
	text_staging_memory_handle: rawptr
	vk.MapMemory(
		device,
		text_staging_memory,
		0,
		text_staging_buffer_size,
		{},
		&text_staging_memory_handle,
	)
	intrinsics.mem_copy(
		text_staging_memory_handle,
		raw_data(font.atlas_pixels),
		len(font.atlas_pixels),
	)
	vk.UnmapMemory(device, text_staging_memory)

	create_buffer(
		text_buffer_size,
		// {.TRANSFER_DST, .VERTEX_BUFFER},
		{.VERTEX_BUFFER},
		&text_buffer,
		&text_buffer_memory,
	)
	vk.MapMemory(device, text_buffer_memory, 0, text_buffer_size, {}, &text_memory_handle)

	text_region := vk.BufferImageCopy {
		bufferOffset = 0,
		bufferRowLength = 0,
		bufferImageHeight = 0,
		imageSubresource = {
			aspectMask = {.COLOR},
			mipLevel = 0,
			baseArrayLayer = 0,
			layerCount = 1,
		},
		// What should the width and height be?
		imageExtent = {width = u32(font.atlas_width), height = u32(font.atlas_height), depth = 1},
	}

	vk.BeginCommandBuffer(
		command_buffer,
		&vk.CommandBufferBeginInfo{sType = .COMMAND_BUFFER_BEGIN_INFO},
	)
	text_image_memory_barrier := vk.ImageMemoryBarrier2 {
		sType = .IMAGE_MEMORY_BARRIER_2,
		// srcStageMask = {.COLOR_ATTACHMENT_OUTPUT},
		srcStageMask = {},
		srcAccessMask = {},
		// dstStageMask = {.COLOR_ATTACHMENT_OUTPUT},
		dstStageMask = {.COPY},
		// dstAccessMask = {.COLOR_ATTACHMENT_WRITE},
		dstAccessMask = {.TRANSFER_WRITE},
		oldLayout = .UNDEFINED,
		newLayout = .TRANSFER_DST_OPTIMAL,
		// srcQueueFamilyIndex = vk.QUEUE_FAMILY_IGNORED,
		// dstQueueFamilyIndex = vk.QUEUE_FAMILY_IGNORED,
		image = font.image,
		subresourceRange = {aspectMask = {.COLOR}, levelCount = 1, layerCount = 1},
	}
	text_dependency_info := vk.DependencyInfo {
		sType                   = .DEPENDENCY_INFO,
		imageMemoryBarrierCount = 1,
		pImageMemoryBarriers    = &text_image_memory_barrier,
	}
	vk.CmdPipelineBarrier2(command_buffer, &text_dependency_info)
	vk.CmdCopyBufferToImage(
		command_buffer,
		text_staging_buffer,
		font.image,
		.TRANSFER_DST_OPTIMAL,
		1,
		&text_region,
	)
	text_image_memory_barrier.srcStageMask = {.COPY}
	text_image_memory_barrier.srcAccessMask = {.TRANSFER_WRITE}
	text_image_memory_barrier.dstStageMask = {.FRAGMENT_SHADER}
	text_image_memory_barrier.dstAccessMask = {.SHADER_READ}
	text_image_memory_barrier.oldLayout = .TRANSFER_DST_OPTIMAL
	text_image_memory_barrier.newLayout = .SHADER_READ_ONLY_OPTIMAL
	vk.CmdPipelineBarrier2(command_buffer, &text_dependency_info)
	vk.EndCommandBuffer(command_buffer)
	submit_info := vk.SubmitInfo {
		sType              = .SUBMIT_INFO,
		commandBufferCount = 1,
		pCommandBuffers    = &command_buffer,
	}
	vk.QueueSubmit(queue, 1, &submit_info, {})
	vk.QueueWaitIdle(queue)

	create_text_pipeline(&text_descriptor_set_layout)
}


dynamic_vertices: [dynamic]TextVertex

update_text :: proc() {
	clear(&dynamic_vertices)

	append_text(
		&dynamic_vertices,
		&font,
		// "A A A A AA AAA",
		"A E I O U Y",
		50,
		100,
		f32(swapchain_extent.width),
		// f32(font.atlas_width),
		f32(swapchain_extent.height),
		// f32(font.atlas_height),
	)

	intrinsics.mem_copy(
		text_memory_handle,
		raw_data(dynamic_vertices),
		len(dynamic_vertices) * size_of(TextVertex),
	)
}

append_text :: proc(
	vertices: ^[dynamic]TextVertex,
	font: ^Font,
	text: string,
	start_x, start_y: f32,
	screen_w, screen_h: f32,
) {
	x := start_x
	y := start_y

	for chr in text {
		if chr < 32 || chr >= 128 {
			continue
		}

		q: tt.aligned_quad

		tt.GetBakedQuad(
			&font.baked_chars[0],
			font.atlas_width,
			font.atlas_height,
			i32(chr - 32),
			&x,
			&y,
			&q,
			true,
			// false,
		)

		// Convert screen coords -> Vulkan NDC
		x0 := (q.x0 / screen_w) * 2.0 - 1.0
		y0 := (q.y0 / screen_h) * 2.0 - 1.0
		x1 := (q.x1 / screen_w) * 2.0 - 1.0
		y1 := (q.y1 / screen_h) * 2.0 - 1.0

		// Apparently no need to flip Y for Vulkan after all
		// y0 = -y0
		// y1 = -y1

		color := [4]f32{1, 1, 1, 1}

		v0 := TextVertex {
			pos   = {x0, y0},
			uv    = {q.s0, q.t0},
			color = color,
		}
		v1 := TextVertex {
			pos   = {x1, y0},
			uv    = {q.s1, q.t0},
			color = color,
		}
		v2 := TextVertex {
			pos   = {x1, y1},
			uv    = {q.s1, q.t1},
			color = color,
		}
		v3 := TextVertex {
			pos   = {x0, y1},
			uv    = {q.s0, q.t1},
			color = color,
		}

		append(vertices, v0, v1, v2, v0, v2, v3)
	}
}


load_font :: proc() {
	ttf_data, err := os.read_entire_file_from_path(ttf_path, context.allocator)
	assert(err == nil)

	atlas_w: i32 = 512
	atlas_h: i32 = 512

	pixels := make([]u8, atlas_w * atlas_h)

	tt.BakeFontBitmap(
		raw_data(ttf_data),
		0,
		pixel_height,
		raw_data(pixels),
		atlas_w,
		atlas_h,
		32, // first char
		Glyph_Count,
		&font.baked_chars[0],
	)

	font.atlas_width = atlas_w
	font.atlas_height = atlas_h
	font.atlas_pixels = pixels
}
