#!/bin/bash

gcc main.c -lm $(pkg-config --cflags --libs gtk4 alsa)
./a.out
