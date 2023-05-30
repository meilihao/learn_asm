README

## test
```bash
# ./run.sh
# gdb -ex 'set tdesc filename ../protect_mode/target.xml' \
      -ex 'target remote :1234' \
      -ex 'x /1024bx 0x7e00' \
      -ex 'c'
...
Continuing.
^C
Program received signal SIGINT, Interrupt.
0x00007c14 in ?? ()
=> 0x00007c14:	eb fd	jmp    0x7c13
(gdb) x /1024bx 0x7e00
```

或

```bash
# qemu monitor
(qemu) xp /512bx 0x7e00
```

或
```
# bochs -f bochsrc
<bochs:1> b 0x7c00
<bochs:2> c
(0) Breakpoint 1, 0x0000000000007c00 in ?? ()
Next at t=16453042
(0) [0x000000007c00] 0000:7c00 (unk. ctxt): mov ax, cs                ; 8cc8
<bochs:3> xp /1024bx 0x7e00
<bochs:4> c
^CNext at t=379441891
(0) [0x0000000fd416] f000:d416 (unk. ctxt): pop word ptr ds:[eax]     ; 678f00
<bochs:3> xp /1024bx 0x7e00
```

经验证:
- bochs 正常
- qemu-system-i386

	- 没用`-S -s`+gdb: qemu monitor验证, 正常
	- `-S -s`+gdb: gdb和qemu monitor都显示错误, 读入的两个扇区间隔了好多个0