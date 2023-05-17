# RERADME
from https://github.com/yifengyou/os-elephant/blob/master/code/c00/page26

输出:
```bash
# ./as.sh
hello,chen!
===========================================
ELF Header:
  Magic:   7f 45 4c 46 01 01 01 00 00 00 00 00 00 00 00 00 
  Class:                             ELF32
  Data:                              2's complement, little endian
  Version:                           1 (current)
  OS/ABI:                            UNIX - System V
  ABI Version:                       0
  Type:                              EXEC (Executable file)
  Machine:                           Intel 80386
  Version:                           0x1
  Entry point address:               0x804a00c
  Start of program headers:          52 (bytes into file)
  Start of section headers:          8576 (bytes into file)
  Flags:                             0x0
  Size of this header:               52 (bytes)
  Size of program headers:           32 (bytes)
  Number of program headers:         4
  Size of section headers:           40 (bytes)
  Number of section headers:         10
  Section header string table index: 9

Section Headers:
  [Nr] Name              Type            Addr     Off    Size   ES Flg Lk Inf Al
  [ 0]                   NULL            00000000 000000 000000 00      0   0  0
  [ 1] .text             PROGBITS        08049000 001000 000007 00  AX  0   0 16
  [ 2] file1data         PROGBITS        0804a000 002000 00000c 00   A  0   0  1
  [ 3] file1text         PROGBITS        0804a00c 00200c 000018 00   A  0   0  1
  [ 4] file2data         PROGBITS        0804a024 002024 000001 00   A  0   0  1
  [ 5] file2text         PROGBITS        0804a025 002025 000015 00   A  0   0  1
  [ 6] .bss              NOBITS          0804b03c 00203c 000040 00  WA  0   0  4
  [ 7] .symtab           SYMTAB          00000000 00203c 0000b0 10      8   6  4
  [ 8] .strtab           STRTAB          00000000 0020ec 000044 00      0   0  1
  [ 9] .shstrtab         STRTAB          00000000 002130 00004e 00      0   0  1
Key to Flags:
  W (write), A (alloc), X (execute), M (merge), S (strings), I (info),
  L (link order), O (extra OS processing required), G (group), T (TLS),
  C (compressed), x (unknown), o (OS specific), E (exclude),
  D (mbind), p (processor specific)

Program Headers:
  Type           Offset   VirtAddr   PhysAddr   FileSiz MemSiz  Flg Align
  LOAD           0x000000 0x08048000 0x08048000 0x000b4 0x000b4 R   0x1000
  LOAD           0x001000 0x08049000 0x08049000 0x00007 0x00007 R E 0x1000
  LOAD           0x002000 0x0804a000 0x0804a000 0x0003a 0x0003a R   0x1000
  LOAD           0x00003c 0x0804b03c 0x0804b03c 0x00000 0x00040 RW  0x1000

 Section to Segment mapping:
  Segment Sections...
   00     
   01     .text 
   02     file1data file1text file2data file2text 
   03     .bss
```

说明:
- Section Headers: 显示可执行文件中所有的section, 也包括在两个汇编文件中用关键字 section 定义的部分
- Program Headers: segment

	Flg: R, 只读; E, 可执行; W, 可写.

	根据RW推测第4个段是1.asm的.bss, 大小也正好是0x40=64
- Section to Segment mapping: session与segment的对应关系

不管定义了多少section, 编译器最终要把属性相同的 section或者其认为可以放到一块的, 合并到一个大的segment 中, 也就是 elf 的 program header 中的项.