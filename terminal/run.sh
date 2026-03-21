#!/bin/bash

# gcc terminal.c -o terminal \
#   `pkg-config --cflags --libs gtk4` \
#   -lutil

gcc terminal.c $(pkg-config --cflags --libs gtk4) -lutil

./a.out
