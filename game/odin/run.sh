#!/bin/bash

rm -f odin *.spv

slangc shader.slang -target spirv -o shader.spv

odin run .