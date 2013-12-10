#!/bin/sh
rm floppy.img
cp grub-0.97-i386-pc.ext2fs floppy.img
sudo mdconfig -af floppy.img
sudo mount -t ext2fs /dev/md0 /mnt/
sudo cp miniKernel /mnt/
sudo umount /mnt
sudo mdconfig -d -u 0
