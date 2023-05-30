#!/bin/bash
#bximage -func=create -hd=16M -imgmode="flat" -sectsize=512 -q hd.img # size<10会报`Hard disk image size out of range`
nasm -o mbr.bin mbr.s && dd if=mbr.bin of=./hd.img bs=512 count=1  conv=notrunc
nasm -o data.bin data.s && dd if=data.bin of=./hd.img bs=512 count=2 seek=1  conv=notrunc
qemu-system-i386 -hda hd.img -S -s