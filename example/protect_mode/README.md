# README
ref:
- [9.9.1 Switching to Protected Mode](https://www.intel.sg/content/dam/www/public/us/en/documents/manuals/64-ia-32-architectures-software-developer-vol-3a-part-1-manual.pdf)

## example
- run.sh: 第一版loader, 有问题, 见FAQ的"`qemu-system-i386/qemu-system-x86_64 -hda hd.img`启动后, 没停在显示出`P`的界面, 而是屏幕内容来回跳动, 最终停在一个界面上"
- run1.sh: 来自网络, 用于对比发现loader.s的问题
- run2.sh: 修正`times 60 dq 0` + `cli`后的run.sh

	也会出现run.sh问题, 概率比run.sh小, 家里小米笔记本不容易出现, 但公司小主机上容易出现. 又在公司小主机上连试20把, 都正常, 真是诡异.

	将所有变量定义移到文件末尾, 变成loader_ok.s, 连续执行run_ok.sh 20次, 问题未出现.
- run_mem.sh: 带探测内存大小的loader, 有问题

	用修正后的loader2.s+探测内存大小的代码, 结果出现run.sh问题, qemu-system-i386会突然退出, 挺频繁的.

	通过`qemu-system-i386 -hda hd.img -d cpu_reset,int -no-reboot -S -s -monitor tcp::4444,server,nowait`+`gdb -ex 'set tdesc filename ./target.xml' -ex 'set disassembly-flavor intel' -ex 'set disassemble-next-line on' -ex 'target remote :1234' -ex 'c'`分析日志. 有时qemu-system-i386没输出异常, 突然就退出了; 有时会打印很多`check_exception old: 0xffffffff new 0x6`但退出, 对比这两种日志, 就是第二种多了很多的`check_exception old: 0xffffffff new 0x6`, 其他日志都一样. 对比第一种日志和loader_mem_ok.s的日志, 完全一样.

	将所有变量定义移到文件末尾, 变成loader_mem_ok.s, 连续执行run_mem_ok.sh 20次, 问题未出现.

## FAQ
### `qemu-system-i386/qemu-system-x86_64 -hda hd.img`启动后, 没停在显示出`P`的界面, 而是屏幕内容来回跳动, 最终停在一个界面上
ref:
- [GGOS 诞生记](https://blog.gzti.me/posts/2022/2430028/index.html)

首先, 直接调试(`qemu-system-i386 -hda c.img -d cpu_reset,int -no-reboot`)运行run.sh, qemu-system-i386容易直接退出, 打印`...\nTriple fault`

在laoder.s 91行添加`jmp $`进行调试, 发现很诡异的现象, 会出现三种显示效果:
- 正常, 小概率

	[](misc/2023-05-26_14-14-42.png)
- 异常1, 小概率

	[](misc/2023-05-26_14-14-06.png)
- 异常1, 小概率

	[](misc/2023-05-26_14-15-37.png)

此时如果将92行上方的`INT 0x10    功能号:0x13    功能描述:打印字符串`代码去掉, 界面会稳定停在一个界面. 再将`jmp $`删除, hd.img启动后界面还是会跳动.

执行run1.sh, 界面会稳定停在一个界面.

使用bochs调试发现:
```
> show all
> c
...
00082415545: switched from 'real mode' to 'protected mode'
(0).[82472611] [0x000000000b1d] 0008:0000000000000b1d (unk. ctxt): jmp .-2  (0x00000b1d)     ; ebfe
Next at t=82472612
(0) [0x0000fffffff0] f000:fff0 (unk. ctxt): jmpf 0xf000:e05b          ; ea5be000f0
```

问题出现在82472611~82472612之间, 查看bochs log:
```
...
00082472611e[CPU0  ] interrupt(): gate descriptor is not valid sys seg (vector=0x08)
00082472611e[CPU0  ] interrupt(): gate descriptor is not valid sys seg (vector=0x0d)
00082472611e[CPU0  ] interrupt(): gate descriptor is not valid sys seg (vector=0x08)
00082472611i[CPU0  ] CPU is in protected mode (active)
00082472611i[CPU0  ] CS.mode = 32 bit
00082472611i[CPU0  ] SS.mode = 16 bit
00082472611i[CPU0  ] EFER   = 0x00000000
00082472611i[CPU0  ] | EAX=00000011  EBX=00001100  ECX=00000000  EDX=000001f0
00082472611i[CPU0  ] | ESP=00007c00  EBP=00000000  ESI=00000002  EDI=00000004
00082472611i[CPU0  ] | IOPL=0 id vip vif ac vm RF nt of df IF tf sf zf af PF cf
00082472611i[CPU0  ] | SEG sltr(index|ti|rpl)     base    limit G D
00082472611i[CPU0  ] |  CS:0008( 0001| 0|  0) 00000000 ffffffff 1 1
00082472611i[CPU0  ] |  DS:0000( 0004| 0|  0) 00000000 0000ffff 0 0
00082472611i[CPU0  ] |  SS:0000( 0004| 0|  0) 00000000 0000ffff 0 0
00082472611i[CPU0  ] |  ES:0000( 0004| 0|  0) 00000000 0000ffff 0 0
00082472611i[CPU0  ] |  FS:0000( 0004| 0|  0) 00000000 0000ffff 0 0
00082472611i[CPU0  ] |  GS:b800( 0004| 0|  0) 000b8000 0000ffff 0 0
00082472611i[CPU0  ] | EIP=00000b1d (00000b1d)
00082472611i[CPU0  ] | CR0=0x00000011 CR2=0x00000000
00082472611i[CPU0  ] | CR3=0x00000000 CR4=0x00000000
00082472611e[CPU0  ] exception(): 3rd (13) exception with no resolution, shutdown status is 00h, resetting
00082472611i[SYS   ] bx_pc_system_c::Reset(HARDWARE) called
00082472611i[CPU0  ] cpu hardware reset ; cpu重置了
00082472611i[APIC0 ] allocate APIC id=0 (MMIO enabled) to 0x0000fee00000
00082472611i[CPU0  ] CPU[0] is the bootstrap processor
00082472611i[CPU0  ] CPUID[0x00000000]: 00000005 68747541 444d4163 69746e65
...
```
00082472611e没看懂, 按字面意思是有异常无法处理`exception with no resolution`而出发了cpu重置. 根据google, 怀疑是切换保护模式后没有idt, 导致无法处理中断引起的.

在16位实模式下的中断由BIOS处理，进入保护模式后，中断将交给中断描述符表IDT里规定的函数处理，在刚进入保护模式时IDTR寄存器的初始值为0，一旦发生中断（例如BIOS的时钟中断）就将导致CPU发生异常，所以需要首先屏蔽中断

在lgdt前(因为lgdt前有用int)添加[`cli`](https://mp.weixin.qq.com/s/VGhpbZaeyVwq3Ghs2E6eEw), qemu-system-i386还是存在该问题.

理论上关了中断, qemu-system-i386 cpu应该不会重置才对.

逐步调整loader.s和loader1.s对比发现:
1. 注释`times 60 dq 0`
1. `lgdt`前加`cli`

经上述两个步骤调整loader.s后得到loader2.s, 执行run2.sh, 概率变小, **怀疑是lgdt加载空selector(非第一个是0)导致异常**, 预计[qemu源码](https://github.com/qemu/qemu/blob/ac84b57b4d74606f7f83667a0606deef32b2049d/target/i386/tcg/translate.c#L6017)(这里仅是一个可能的代码位置)里有答案.

用上述调整后的loader2.s开发run_mem.sh, 发现还是会出现cpu reset, 将所有变量定义移到文件末尾形成run_mem_ok.sh, 问题消失, 因为bochs无法复现, qemu-system-i386无法调试而放弃排查.

### 如何使用sata盘
ref:
- [How to emulate a SATA disk drive in QEMU](https://stackoverflow.com/questions/48351096/how-to-emulate-a-sata-disk-drive-in-qemu)
- [QEMU/Options](https://wiki.gentoo.org/wiki/QEMU/Options#Hard_drive)

```bash
# qemu-system-i386 -M q35 -drive id=disk,file=c.img,if=none -device ahci,id=ahci -device ide-hd,drive=disk,bus=ahci.0
```

有资料说`When using i386 or x86_64 with Q35 machine type(-M q35), disk has been AHCI by default.`

暂无法验证模拟sata是否已成功.

### gdb调试
```bash
# qemu-system-i386 -hda hd.img -d cpu_reset,int -no-reboot -S -s -monitor tcp::4444,server,nowait
# gdb -ex 'set tdesc filename ./target.xml' \
    -ex 'set disassembly-flavor intel' \
    -ex 'set disassemble-next-line on' \
    -ex 'target remote :1234' \
    -ex 'break *0x900' \
    -ex 'c' \
    -ex 'disassemble 0x900,0xbf0'
```