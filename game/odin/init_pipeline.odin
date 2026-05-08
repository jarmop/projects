package game

import "core:slice"
import vk "vendor:vulkan"

SHADER :: #load("shaders/shader.spv")

create_pipeline :: proc() {
	rendering_create_info := vk.PipelineRenderingCreateInfo {
		sType                   = .PIPELINE_RENDERING_CREATE_INFO,
		colorAttachmentCount    = 1,
		pColorAttachmentFormats = &swapchain_image_format,
	}

	shader_module := create_shader_module(SHADER)

	vk.CreatePipelineLayout(
		device,
		&vk.PipelineLayoutCreateInfo {
			sType = .PIPELINE_LAYOUT_CREATE_INFO,
			setLayoutCount = 1,
			pushConstantRangeCount = 0,
			pPushConstantRanges = nil,
			pSetLayouts = &descriptor_set_layout,
		},
		nil,
		&pipeline_layout,
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
		layout              = pipeline_layout,
	}
	vk.CreateGraphicsPipelines(device, 0, 1, &pipeline_create_info, nil, &pipeline)

	vk.DestroyShaderModule(device, shader_module, nil)
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
