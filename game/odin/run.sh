#!/bin/bash

rm -f odin *.spv

slangc shaders/shader.slang -target spirv -o shaders/shader.spv
slangc shaders/text_shader.slang -target spirv -o shaders/text_shader.spv

odin run src