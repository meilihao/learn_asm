# FAQ
## 指令操作位数
att: mov/movb(8 bit), movw(16 bit), movl(32 bit), movq(64 bit) 
intel: QWORD/DWORD/WORD/Byte/Bit => 64/32/16/8/1 bit

## mov eax, DWORD PTR [...]对rax的影响
参考:
- [汇编-x86_64寄存器rax / eax / ax / al覆盖全部寄存器内容](https://www.itranslater.com/qa/details/2326145479089849344)

```x86asm
.intel_syntax noprefix
.section .data
data_items:
	.long 3, 12
.section .text

.equ origin_rax, 0x00FFFFFFFFFFFFFF

.globl _start
_start:
    mov rbx, 0 # 默认会重置rax, 通过exit code判断
    mov rax, origin_rax
    mov eax, DWORD PTR [data_items]
    cmp rax, 3 # if rax <=3 -> jle
    jle end_le
    mov rbx, 1

    end_le:
    mov rax, 1 # syscall exit
    int 0x80
// output: 0, 即将rax的高32b重置了.
```

结论:
```x86asm
# 对于所有32位的系统都是这样：

mov  eax, 0x11112222 ; eax = 0x11112222
mov  ax, 0x3333      ; eax = 0x11113333 (works, only low 16 bits changed)
mov  al, 0x44        ; eax = 0x11113344 (works, only low 8 bits changed)
mov  ah, 0x55        ; eax = 0x11115544 (works, only high 8 bits changed)
xor  ah, ah          ; eax = 0x11110044 (works, only high 8 bits cleared)
mov  eax, 0x11112222 ; eax = 0x11112222
xor  al, al          ; eax = 0x11112200 (works, only low 8 bits cleared)
mov  eax, 0x11112222 ; eax = 0x11112222
xor  ax, ax          ; eax = 0x11110000 (works, only low 16 bits cleared)

# 但是，一旦涉及到64位内容，事情似乎就变得很尴尬：

mov  rax, 0x1111222233334444 ;           rax = 0x1111222233334444
mov  eax, 0x55556666         ; actual:   rax = 0x0000000055556666 # rax的高32bit被重置了, 这是因为[对无序执行的额外依赖性不同导致](https://riptutorial.com/zh-CN/x86/example/6975/64%E4%BD%8D%E5%AF%84%E5%AD%98%E5%99%A8)
                             ; expected: rax = 0x1111222255556666
                             ; upper 32 bits seem to be lost!
mov  rax, 0x1111222233334444 ;           rax = 0x1111222233334444
mov  ax, 0x7777              ;           rax = 0x1111222233337777 (works!)
mov  rax, 0x1111222233334444 ;           rax = 0x1111222233334444
xor  eax, eax                ; actual:   rax = 0x0000000000000000
                             ; expected: rax = 0x1111222200000000
                             ; again, it wiped whole register
```

## 如何调试as生存的程序
```bash
gdb -q t.elf 
Reading symbols from t.elf...
(No debugging symbols found in t.elf)
(gdb) b *_start # by symbol
Breakpoint 1 at 0x401000
(gdb) b *0x0000000000401011 # by memory addr
Breakpoint 3 at 0x401011
(gdb) r # run
Starting program: /home/chen/test/t.elf 

Breakpoint 1, 0x0000000000401000 in _start ()
(gdb) disas # 反编译
Dump of assembler code for function _start:
=> 0x0000000000401000 <+0>:	mov    $0x0,%rbx
   0x0000000000401007 <+7>:	movabs $0xffffffffffffff,%rax
   0x0000000000401011 <+17>:	mov    0x402000,%eax
   0x0000000000401018 <+24>:	cmp    $0x3,%rax
   0x000000000040101c <+28>:	jg     0x40101e <end_g>
End of assembler dump.
(gdb) si # 仅执行一条指令

Breakpoint 2, 0x0000000000401007 in _start ()
(gdb) disas
Dump of assembler code for function _start:
   0x0000000000401000 <+0>:	mov    $0x0,%rbx
=> 0x0000000000401007 <+7>:	movabs $0xffffffffffffff,%rax
   0x0000000000401011 <+17>:	mov    0x402000,%eax
   0x0000000000401018 <+24>:	cmp    $0x3,%rax
   0x000000000040101c <+28>:	jg     0x40101e <end_g>
End of assembler dump.
(gdb) p /x $rax # 以16进制查看rax
$1 = 0x0
(gdb) si

Breakpoint 3, 0x0000000000401011 in _start ()
(gdb) p /x $rax
$2 = 0xffffffffffffff
```

### invalid instruction suffix for `push' on x86_64
在64位系统和32位系统的as命令对于某些汇编指令的处理支持不一样造成的，所以在文本开头加上`.code32`

### end of file not at end of a line; newline inserted
最后一行之前不是汇编代码, 比如
```x86sam
...
BS_FileSysType:	.ascii 'FAT12   '

```

改为汇编代码即可, 比如追加一个symbol.

#### loader.s:19: 错误：junk at end of line, first unrecognized character is `7'
```x86asm
BS_OEMName: .ascii 'MINEboot'
```

gas中`.ascii`的值应该使用`"`包裹

### `byte ptr [sp]' is not a valid base/index expression
[SP can't be used as a base or index register in the 16-bit addressing modes](https://stackoverflow.com/questions/34345583/invalid-base-index-expressions)

### 机器语言, 汇编, 高级语言的关系
汇编与机器语言一一对应.

高级语言通过编译可得到汇编/机器语言, 但汇编/机器语言几乎不可能还原成高级语言. 因为:
```c
struct Date {
   int year;
   int month;
   int day;
}

// 下面两句语句的汇编代码完全相同
Date d = {1,2,3};
int arr[] = {1,2,3};
```

> ida之类反编译工具还原的是伪代码

### if ... else if ... else/switch性能
相关命令:
```bash
# gcc -g t.c
# objdump -S -d -M x86-64 a.out
# --- 或使用llvm
# clang-10 -gdwarf t.c
# objdump -S -d -M x86-64 a.out
```

if/else:
```c
void testif() {
    int n = 4;

    if (n==1) {
        printf("n is 1");
    }else if (n==2){
        printf("n is 2");
    }else if (n==3){
        printf("n is 3");
    }else if (n==4){
        printf("n is 4");
    }else if (n==5){
        printf("n is 5");
    }else{
        printf("n is other");
    }
}

void testswitch() {
    int n = 4;

    switch (n) {
        case 1:
            printf("n is 1");
            break;
        case 2:
            printf("n is 2");
            break;
        case 3:
            printf("n is 3");
            break;
        case 4:
            printf("n is 4");
            break;
        case 5:
            printf("n is 5");
            break;
        default:
            printf("n is other");
            break;
    }
}
```

汇编:
```x86asm
0000000000401122 <testif>:
#include<stdio.h>

void testif() {
  401122:	55                   	push   rbp
  401123:	48 89 e5             	mov    rbp,rsp
  401126:	48 83 ec 10          	sub    rsp,0x10
    int n = 4;
  40112a:	c7 45 fc 04 00 00 00 	mov    DWORD PTR [rbp-0x4],0x4

    if (n==1) {
  401131:	83 7d fc 01          	cmp    DWORD PTR [rbp-0x4],0x1
  401135:	75 11                	jne    401148 <testif+0x26> # 不等时跳到下一个`else if`或`else`, 否则继续执行
        printf("n is 1");
  401137:	bf 08 20 40 00       	mov    edi,0x402008
  40113c:	b8 00 00 00 00       	mov    eax,0x0
  401141:	e8 ea fe ff ff       	call   401030 <printf@plt>
    }else if (n==5){ # ???, 使用llvm-10时, 这里显示正常
        printf("n is 5");
    }else{
        printf("n is other");
    }
}
  401146:	eb 6b                	jmp    4011b3 <testif+0x91> # 跳出if/else
    }else if (n==2){
  401148:	83 7d fc 02          	cmp    DWORD PTR [rbp-0x4],0x2
  40114c:	75 11                	jne    40115f <testif+0x3d>
        printf("n is 2");
  40114e:	bf 0f 20 40 00       	mov    edi,0x40200f
  401153:	b8 00 00 00 00       	mov    eax,0x0
  401158:	e8 d3 fe ff ff       	call   401030 <printf@plt>
}
  40115d:	eb 54                	jmp    4011b3 <testif+0x91>
    }else if (n==3){
  40115f:	83 7d fc 03          	cmp    DWORD PTR [rbp-0x4],0x3
  401163:	75 11                	jne    401176 <testif+0x54>
        printf("n is 3");
  401165:	bf 16 20 40 00       	mov    edi,0x402016
  40116a:	b8 00 00 00 00       	mov    eax,0x0
  40116f:	e8 bc fe ff ff       	call   401030 <printf@plt>
}
  401174:	eb 3d                	jmp    4011b3 <testif+0x91>
    }else if (n==4){
  401176:	83 7d fc 04          	cmp    DWORD PTR [rbp-0x4],0x4
  40117a:	75 11                	jne    40118d <testif+0x6b>
        printf("n is 4");
  40117c:	bf 1d 20 40 00       	mov    edi,0x40201d
  401181:	b8 00 00 00 00       	mov    eax,0x0
  401186:	e8 a5 fe ff ff       	call   401030 <printf@plt>
}
  40118b:	eb 26                	jmp    4011b3 <testif+0x91>
    }else if (n==5){
  40118d:	83 7d fc 05          	cmp    DWORD PTR [rbp-0x4],0x5
  401191:	75 11                	jne    4011a4 <testif+0x82>
        printf("n is 5");
  401193:	bf 24 20 40 00       	mov    edi,0x402024
  401198:	b8 00 00 00 00       	mov    eax,0x0
  40119d:	e8 8e fe ff ff       	call   401030 <printf@plt>
}
  4011a2:	eb 0f                	jmp    4011b3 <testif+0x91>
        printf("n is other");
  4011a4:	bf 2b 20 40 00       	mov    edi,0x40202b
  4011a9:	b8 00 00 00 00       	mov    eax,0x0
  4011ae:	e8 7d fe ff ff       	call   401030 <printf@plt>
}
  4011b3:	90                   	nop
  4011b4:	c9                   	leave  
  4011b5:	c3                   	ret    

00000000004011b6 <testswitch>:

void testswitch() {
  4011b6:	55                   	push   rbp
  4011b7:	48 89 e5             	mov    rbp,rsp
  4011ba:	48 83 ec 10          	sub    rsp,0x10
    int n = 4;
  4011be:	c7 45 fc 04 00 00 00 	mov    DWORD PTR [rbp-0x4],0x4

    switch (n) {
  4011c5:	83 7d fc 05          	cmp    DWORD PTR [rbp-0x4],0x5
  4011c9:	77 62                	ja     40122d <testswitch+0x77> # if n>5 jump to default
  4011cb:	8b 45 fc             	mov    eax,DWORD PTR [rbp-0x4]
  4011ce:	48 8b 04 c5 38 20 40 	mov    rax,QWORD PTR [rax*8+0x402038] # 0x402038开始放的是switch的jump table
  4011d5:	00 
  4011d6:	ff e0                	jmp    rax
        case 1:
            printf("n is 1");
  4011d8:	bf 08 20 40 00       	mov    edi,0x402008
  4011dd:	b8 00 00 00 00       	mov    eax,0x0
  4011e2:	e8 49 fe ff ff       	call   401030 <printf@plt>
            break;
  4011e7:	eb 54                	jmp    40123d <testswitch+0x87> # 跳出switch
        case 2:
            printf("n is 2");
  4011e9:	bf 0f 20 40 00       	mov    edi,0x40200f
  4011ee:	b8 00 00 00 00       	mov    eax,0x0
  4011f3:	e8 38 fe ff ff       	call   401030 <printf@plt>
            break;
  4011f8:	eb 43                	jmp    40123d <testswitch+0x87>
        case 3:
            printf("n is 3");
  4011fa:	bf 16 20 40 00       	mov    edi,0x402016
  4011ff:	b8 00 00 00 00       	mov    eax,0x0
  401204:	e8 27 fe ff ff       	call   401030 <printf@plt>
            break;
  401209:	eb 32                	jmp    40123d <testswitch+0x87>
        case 4:
            printf("n is 4");
  40120b:	bf 1d 20 40 00       	mov    edi,0x40201d
  401210:	b8 00 00 00 00       	mov    eax,0x0
  401215:	e8 16 fe ff ff       	call   401030 <printf@plt>
            break;
  40121a:	eb 21                	jmp    40123d <testswitch+0x87>
        case 5:
            printf("n is 5");
  40121c:	bf 24 20 40 00       	mov    edi,0x402024
  401221:	b8 00 00 00 00       	mov    eax,0x0
  401226:	e8 05 fe ff ff       	call   401030 <printf@plt>
            break;
  40122b:	eb 10                	jmp    40123d <testswitch+0x87>
        default:
            printf("n is other");
  40122d:	bf 2b 20 40 00       	mov    edi,0x40202b
  401232:	b8 00 00 00 00       	mov    eax,0x0
  401237:	e8 f4 fd ff ff       	call   401030 <printf@plt>
            break;
  40123c:	90                   	nop
    }
}
  40123d:	90                   	nop
  40123e:	c9                   	leave  
  40123f:	c3                   	ret
```


结论:
1. if/else判断次数越多, 执行的汇编数量越多, 效率越差. 因此建议**将经常匹配到的条件写在前面**.
1. switch选择分支较多时所执行的汇编数量是恒定的, 因为此时选择分支使用的是相同的逻辑. 
1. switch分支较少时, 编译器会做优化, 具体优化策略由编译器决定; 而if/else不会.