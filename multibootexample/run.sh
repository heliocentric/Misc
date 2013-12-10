#!/bin/sh
sh clean.sh
sh build.sh
sh mkimg.sh
qemu -fda floppy.img -curses
