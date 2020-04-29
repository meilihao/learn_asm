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
mov  eax, 0x55556666         ; actual:   rax = 0x0000000055556666 # rax的高32bit被重置了
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