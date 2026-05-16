package game

import "core:slice"
import vk "vendor:vulkan"

SHADER :: #load("../shaders/shader.spv")

create_pipeline :: proc(
	swapchain_image_format: ^vk.Format,
	descriptor_set_layout: ^vk.DescriptorSetLayout,
) {
	// STATIC INFO
	pipeline_create_info := vk.GraphicsPipelineCreateInfo {
		sType               = .GRAPHICS_PIPELINE_CREATE_INFO,
		// Describe the information we are sending to shaders about vertices
		pVertexInputState   = &vk.PipelineVertexInputStateCreateInfo {
			sType                           = .PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO,
			// Describe the layout of the list of vertices
			vertexBindingDescriptionCount   = 1,
			pVertexBindingDescriptions      = raw_data(
				[]vk.VertexInputBindingDescription {
					// The list is divided into Vertex sized chunks,
					// and hence the input rate is one vertex
					{binding = 0, stride = size_of(Vertex), inputRate = .VERTEX},
				},
			),
			// Describe the attributes we send for for each vertex
			vertexAttributeDescriptionCount = 2,
			pVertexAttributeDescriptions    = raw_data(
				[]vk.VertexInputAttributeDescription {
					{
						location = 0,
						binding = 0,
						format = vertex_attribute_format,
						offset = u32(offset_of(Vertex, pos)),
					},
					{
						location = 1,
						binding = 0,
						format = vertex_attribute_format,
						offset = u32(offset_of(Vertex, normal)),
					},
				},
			),
		},
		// We are drawing triangles
		pInputAssemblyState = &vk.PipelineInputAssemblyStateCreateInfo {
			sType = .PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO,
			topology = .TRIANGLE_LIST,
		},
		// One viewport and one scissor
		pViewportState      = &vk.PipelineViewportStateCreateInfo {
			sType = .PIPELINE_VIEWPORT_STATE_CREATE_INFO,
			viewportCount = 1,
			scissorCount = 1,
		},
		// Describe how the polygons are rasterized,
		// e.g. fill each polygon with a color, or only draw the outline
		pRasterizationState = &vk.PipelineRasterizationStateCreateInfo {
			sType       = .PIPELINE_RASTERIZATION_STATE_CREATE_INFO,
			polygonMode = .FILL,
			// polygonMode = .LINE,
			lineWidth   = 1.0,
		},
		// Something related to antialiasing
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
		// Tell that we are setting viewport and scissor dynamically on every frame
		pDynamicState       = &vk.PipelineDynamicStateCreateInfo {
			sType = .PIPELINE_DYNAMIC_STATE_CREATE_INFO,
			dynamicStateCount = 2,
			pDynamicStates = raw_data([]vk.DynamicState{.VIEWPORT, .SCISSOR}),
		},
		// Depth testing
		pDepthStencilState  = &vk.PipelineDepthStencilStateCreateInfo {
			sType = .PIPELINE_DEPTH_STENCIL_STATE_CREATE_INFO,
			depthTestEnable = true,
			depthWriteEnable = true,
			depthCompareOp = .LESS_OR_EQUAL,
		},
	}

	// INFO BASED ON SWAPCHAIN
	pipeline_create_info.pNext = &vk.PipelineRenderingCreateInfo {
		sType = .PIPELINE_RENDERING_CREATE_INFO,
		colorAttachmentCount = 1,
		pColorAttachmentFormats = swapchain_image_format,
		depthAttachmentFormat = depth_format,
	}

	// INFO BASED ON SHADERS
	shader_module := create_shader_module(SHADER)
	defer vk.DestroyShaderModule(device, shader_module, nil)
	pipeline_create_info.stageCount = 2
	pipeline_create_info.pStages = raw_data(
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
	)

	// INFO BASED ON DESCRIPTORS
	vk.CreatePipelineLayout(
		device,
		&vk.PipelineLayoutCreateInfo {
			sType = .PIPELINE_LAYOUT_CREATE_INFO,
			setLayoutCount = 1,
			pushConstantRangeCount = 0,
			pPushConstantRanges = nil,
			pSetLayouts = descriptor_set_layout,
		},
		nil,
		&pipeline_layout,
	)
	pipeline_create_info.layout = pipeline_layout

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
