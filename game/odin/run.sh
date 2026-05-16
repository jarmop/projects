#!/bin/bash

rm -f odin *.spv

slangc shaders/shader.slang -target spirv -o shaders/shader.spv

odin run src