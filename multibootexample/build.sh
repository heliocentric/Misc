#!/bin/sh
nasm -f elf start.asm
gcc -m32 -ffreestanding -fno-builtin -nostdlib -nostartfiles -c kernel.c
gcc -m32 -Xlinker -T -Xlinker ldscript -ffreestanding -fno-builtin -nostdlib -nostartfiles -s start.o kernel.o -o miniKernel
