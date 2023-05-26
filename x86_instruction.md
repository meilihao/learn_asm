# x86 instruction
参考:
- x86/x86_64 : [<<Intel® 64 and IA-32 ArchitecturesSoftware Developer’s ManualVolume 2>>的Chapter 3~5](https://www.intel.com/content/dam/www/public/us/en/documents/manuals/64-ia-32-architectures-software-developer-instruction-set-reference-manual-325383.pdf)
- [Linux 下 64 位汇编语言](https://blog.codekissyoung.com/%E8%AE%A1%E7%AE%97%E6%9C%BA%E6%9E%84%E9%80%A0%E4%B8%8E%E7%BB%84%E6%88%90/64%E4%BD%8DCPU%E6%B1%87%E7%BC%96%E8%AF%AD%E8%A8%80)
- [x86/x64体系探索及编程#2.5]
- [Linux 下 64 位汇编语言 for <<深入理解计算机系统>>](https://blog.codekissyoung.com/%E8%AE%A1%E7%AE%97%E6%9C%BA%E6%9E%84%E9%80%A0%E4%B8%8E%E7%BB%84%E6%88%90/64%E4%BD%8DCPU%E6%B1%87%E7%BC%96%E8%AF%AD%E8%A8%80)
- [x86汇编指令集大全（带注释）](https://blog.csdn.net/bjbz_cxy/article/details/79467688)

## 基本算术
编译器会用到四个基本算术计算指令: 加ADD, 减SUB,乘 IMUL 和 除IDIV.

### add[L]
相加

`addq $16, %rsp` => rsp+=16

### imul[L]
有符号相乘

`imull %rbx, %rax` => rax*=rbx

### mul[L]
无符号相乘
1. 源操作数8bit, `x*al`, 结果是16位, 存入ax
1. 源操作数16bit, `x*ax`, 结果是32位, 存入eax
1. 源操作数32bit, `x*eax`, 结果是64位, 存入edx:eax, 其中 edx 是积的高 32 位， eax是积的低 32 位


### div[L]
无符号除法

一般格式为：div reg或div 内存单元，reg和内存单元存放的是除数，除数可分为8, 16, 32位.
被除数:
- 除数为8位，被除数则为16位, 在AX中存放, 商在寄存器 al, 余数在寄存器ah
- 除数为16位，被除数则为32位，被除数的高 16 位则位于寄存器 dx，被除数的低 16 位则位于寄存器 ax, 商在寄存器ax, 余数在寄存器 dx
- 除数是 32 位, 被除数就是 64 位, 被除数的高 32 位则位于寄存器 edx, 被除数的低 32 位则位于寄存器 eax, 商在寄存器 eax, 余数在寄存器 edx

`div %rbx, %rax` => rax/=rbx

### idiv[L]
有符号除法

`idiv %rbx, %rax` => rax/=rbx

### dec[L]
递减

`decq %rcx`, rcx--

### inc[L]
递增

`incl %rdi` => rdi++

### neg[L]
二进制求补码

## 逻辑计算
### and
`and rax, 1`, rax&=1

### not
对操作数的每一位取反, 但不影响rflags.

### or
或运算

### xor
`xor rax, rax` <=> `mov  rax, 0` , 此时用xor更快

### xor
异或

## 移位
### shr
`shr rax, ${n}`, 逻辑右移(不保留符号), n是移动次数

### shl
`shl rax, ${n}`, 逻辑左移(不保留符号), n是移动次数

### sar
`sar rax, ${n}`, 算术右移(保留符号), n是移动次数

### sal
`sal rax, ${n}`, 算术左移(保留符号), n是移动次数

## 流控制: 比较和跳转
参考:
- [汇编语言转移指令规则汇总](https://blog.csdn.net/trochiluses/article/details/19355425)

### call
函数调用, 是一条近址**相对位移**调用指令(Call near, relative, displacement relative to next instruction, 即同代码段调用). 未链接时, 后面紧跟调用指令的下一条指令的偏移量. 在没有重定位前相对偏移量是0xFFFFFFFC(小端, 是常量-4的补码形式); 链接后反汇编显示call <0x具体地址>(反汇编指令实际用的是还是相对偏移, 只是ndisasm帮忙处理成绝对地址了).

`call ${function_name}`

16 位实模式相对近调用:
```asm
$ cat 1call.s
call near near_proc
jmp $
addr dd 4
near_proc:
    mov ax,0x1234
    ret
$ ndisasm 1call.bin
00000000  E80600            call 0x9 ; E8=call操作码, 操作数=0x0006(小端), 6+3(本指令长度)=9
00000003  EBFE              jmp short 0x3 ; 0xfe=-2, 即跳转到本指令, 效果=死循环
00000005  0400              add al,0x0
00000007  0000              add [bx+si],al
00000009  B83412            mov ax,0x1234
0000000C  C3                ret
```

16 位实模式间接绝对近调用, 支持寄存器和内存寻址:
```asm
$ cat  2call.s
section call_test vstart=0x900
mov word [addr], near_proc
call [addr]
mov ax, near_proc
call ax
jmp $
addr dd 4 ; 定义变量addr
near_proc:
    mov ax,0x1234
    ret
$ ndisasm 2call.bin -o 0x900
00000900  C70611091509      mov word [0x911],0x915
00000906  FF161109          call [0x911]
0000090A  B81509            mov ax,0x915 ; near_proc绝对地址
0000090D  FFD0              call ax
0000090F  EBFE              jmp short 0x90f
00000911  0400              add al,0x0
00000913  0000              add [bx+si],al
00000915  B83412            mov ax,0x1234
00000918  C3                ret
```

16 位实模式直接绝对远调用, 格式`call [far] 段基址(立即数):段内偏移地址(立即数)`(因为指定了段基址, 此时far可以不加):
```asm
$ cat 3call.s
section call_test vstart=0x900
call 0:far_proc
jmp $
far_proc :
    mov ax,0x1234
    retf
$ ndisasm 3call.bin -o 0x900
00000900  9A07090000        call 0x0:0x907
00000905  EBFE              jmp short 0x905
00000907  B83412            mov ax,0x1234
0000090A  CB                retf
```

16 位实模式间接绝对远调用, 不支持寄存器寻址, 仅支持寄存器寻址, 且far不能省略, 否则无法与`间接绝对近调用`区分开:
```asm
$ cat 4call.s
section call_test vstart=0x900
call far [addr]
jmp $
addr dw far_proc, 0 ; 0是段基址
far_proc:
    mov ax,0x1234
    retf
$ ndisasm 4call.bin -o 0x900
00000900  FF1E0609          call far [0x906] ; 低2B, 段内偏移地址; 高2B, 段基址, 这里段基址是0, 即`call far [0:0x906]`
00000904  EBFE              jmp short 0x904
00000906  0A09              or cl,[bx+di]
00000908  0000              add [bx+si],al
0000090A  B83412            mov ax,0x1234
0000090D  CB                retf
```

> 在 8086 处理器中, 有两个指令用于改变程序流程, 一个是 jmp, 另一个是 call,  它们的区别是 jmp属于一去不回头地去执行新的代码, 比如bios将执行权交给mbr.

### nop
空操作

### int
触发中断

### ret/retf
- ret: 近返回, 与call配合使用. 从栈顶（即[SS: Sp]）弹出 2 字节的内容来替换 ip 寄存器
- retf(ret far): 远返回, 与call far配合使用. 从栈顶弹出 4 字节的内容来替换 ip 寄存器和cs寄存器, 跨段访问时使用.

### jmp
无条件跳转

> jmp会清空流水线

JMP指令需要编译器生成目标标签(LABEL）. 标签必须唯一，并且是汇编文件内部私有，对外部不可见，除非有.globl指示. 按C语言的说法，汇编中没有修饰的标签是static的，.globl修饰的标签是extern的.

- jc : 如果进位位被置位则跳转
- jnc : 如果进位位没有置位则跳转

16 位实模式相对短转移:
```asm
$ cat 1jmp.s
section call_test vstart=0x900
jmp short start ; short省略时会由nasm自行判断
times 4 db 0    ; 将4改为128, 会报错: `error: short jump is out of range`, 此时用near可突破`-128~127`
start :
    mov ax, 0x1234
    jmp $
$ ndisasm 1jmp.bin -o 0x900
00000900  EB04              jmp short 0x906 ; 0x04+2(本指令长度)=6
00000902  0000              add [bx+si],al
00000904  0000              add [bx+si],al
00000906  B83412            mov ax,0x1234
00000909  EBFE              jmp short 0x909 ; 0xfe=-2
```

> 短转移是只在段内转移, 不需要跨段.

> short是指明让 nasm 编译器将 jmp 编译为相对短转移的形式, 如果条件不满足 short 的要求，即操作数大小不满足`-128~127`的范围, 则会编译失败

16 位实模式相对近转移(jmp near), 与16 位实模式相对短转移相比, 操作数范围(2B, -32768~32767)更大了, 这里就不重复举例了.

16 位实模式间接绝对近转移, 操作数使用了寄存器或内存寻址:
```asm
section call_test vstart=0x900
mov ax, start
jmp near ax
times 128 db 0
start:
    mov ax, 0x1234
    jmp $
```

```asm
section call_test vstart=0x900
mov word [addr], start
jmp near [addr]
times 128 db 0
addr dw 0
start ·
    mov ax, 0x1234
    jmp $
```

16 位实模式直接绝对远转移:
```asm
section call_test vstart=0x900
jmp 0 : start
times 128 db 0
start:
    mov ax, 0x1234
    jmp $
```

16 位实模式间接绝对远转移:
```asm
section call_test vstart=0x900
jmp far [addr]; [ds:addr], 在ds:addr处获取跳转地址
times 128 db 0
addr dw start, 0
start :
    mov ax, 0x1234
    jmp $
```

### cmp[L]
参考:
- [Intel Instruction Set (gas) # CMP](/misc/doc/Intel_Instruction_Set_gas.pdf)

`cmpq $1, %rcx` => `if 1 ? rcx`, 比较结果的处理, 即有条件跳转:
|转移指令|条 件|意 义|英文助记|
|jz/je|ZF=1| 相减结果等于 0／相等时转移| Jump if Zero/Equal|
|jnz/jne| ZF=O |不等于 0/不相等时转移 |Jump if Not Zero/ Not Equal|
|js| SF=1| 负数时转移 |Jump if Sign|
|jns| SF=0| 正数时转移| Jump if Not Sign|
|jo| OF=1| 溢出时转移 |Jump if Overflow|
|jno |OF=0| 未溢出时转移| Jump ifNot Overflow|
|jp/jpe| PF=1| 低字节中有偶数个 1 时转移| Jump if Parity/Parity Even|
|jnp/jpo| PF=0| 低字节中有奇数个 1 时转移| Jump if Not Parity/Parity Odd|
|jbe/jna| CF＝1或 ZF=1| 小于等于／不大于时转移| Jump if Below or Eqqual/Not Above|
|jnbe/ja| CF=ZF=O| 不小于等于／大于时转移| Jump if Not Below or Equal/Above|
|jc/jb/jnae| CF=1 |进位／小于/不大于等于时转移 |Jump if Carry/Below/Not Above Equal|
|jnc/jnb/jae| CF=0| 未进位／不小子／大于等于时转移 |Jump if Not Carry/Not Below/Above Equal|
|jl/jnge |SF!=OF| 小子／不大于等于时转移| Jump Less/Not Great Equal|
|jnl/jge| SF=OF| 不小于／大于等于时转移| Jump if Not Less/Great Equal|
|jle/jng| ZF!=OF 或 ZF=1| 小于等于／不大于| Jump if Less or Equal/Not Great|
|jnle/jg |SF=OF 且 ZF=0| 不小于等于／大于时转移| Jump Not Less Equal/Great|
|jcxz| cx 寄存器值=0|cx 寄存器值为 0 时转移 |Jump if register cx's vaJue is Zero|

这些转移指令是由意义明确的字符拼成的:
- a : above
- b : below
- c : carry
- e : equal
- g : great
- j : jmp
- l : less
- n : not
- o : overflow
- p : parity

### loop
Loop指令执行流程:
1. 将cx寄存器的值 - 1, cx = cx - 1
2. 判断cx的值

    - 如果不为零 就执行标号处的代码, 然后执行步骤1
    - 如果为零, 执行Loop后面的代码

    Loop的实现其实就是判断cx > 0 然后jump到标号所在地址

作者：那时J花开
链接：https://www.jianshu.com/p/7eaf4a8374d2
来源：简书
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。

### repe
repe是一个串操作前缀，它重复串操作指令，每重复一次ECX的值就减一.

### cmpsb
cmpsb是字符串比较指令，把ds:si/esi指向的数据与es:di/edi指向的数一个一个的进行比较. 每比较一次si, di会递增一次

## 栈 statck
`PUSH rax`
`POP rax`

在实模式环境下：
- 当压入 8 位立即数时，由于实模式下默认操作数是 16 位, CPU 会将其扩展为 16 位后再将其入栈, sp-2
- 当压入 16 位立即数时, CPU 会将其直接入栈, sp-2
- 当压入 32 位立即数时, CPU 会将其直接入栈, sp-4

在保护模式下:
- 当压入 8 位立即数时, 由于保护模式下默认操作数是 32 位, CPU 将其扩展为 32 位后入栈, esp-4
- 当压入 1 6 位立即数时, CPU 直接压入 2 宇节, esp-2
- 当压入 32 位立即数时, CPU 直接压入 4 字节, esp-4

## 函数调用 Calling Functions

## lea
lea(load effective address, 加载有效地址)，可以将有效地址传送到指定的的寄存器. 简单说, 就是C语言中的`&`.

## 传送数据指令
### mov[L]
赋值

`movq %rax, %rbx` => rbx = rax

从较小的源传送到较大的目的地时，有两种类型的指令: 零拓展MOVZ 与 符号拓展MOVS.

### `xchg`
xchg是两个寄存器，寄存器和内存变量之间内容的交换指令.

## SIMD
SIMD单指令流多数据流(SingleInstruction Multiple Data,SIMD)是一种采用一个控制器来控制多个处理器，同时对一组数据（又称`数据向量`）中的每一个分别执行相同的操作从而实现空间上的并行性的技术.

AVX(Advanced Vector Extensions) 是Intel的SSE延伸架构.
FMA是Intel的AVX扩充指令集，如名称上熔合乘法累积（Fused Multiply Accumulate）的意思一样.

## IO 接口
ref:
- <<操作系统真象还原>> 3.5.3 硬盘控制器端口

in 用于从端口中读取数据, 源操作数（端口号）必须是dx/立即数(0~255), 目的操作数是用al/ax.

out 指令用于往端口中写数据, 其目的操作数是端口号/立即数(0~255), 源操作数是al/ax. 其一般形式是：
1. out dx, al
1. out dx, ax
1. out 立即数, al
1. out 立即数, ax

in/out中, dx 只做端口号之用, 无论其是源操作数或目的操作数. 立即数只能是0~255. 操作数用al/ax时, 取决于 dx/立即数 端口指代的寄存器是 8还16 位宽度.

主板一般会提供两个ide插槽, 其插槽称为通道, IDEO 叫作 Primary 通道， IDE1, 叫作 Secondary 通道. 每个通道可以挂两块硬盘, 一个是主盘（ Master），一个是从盘（ Slave ）.

ide磁盘读取步骤:
1. 读取status, 如果该端口bit7=0 && bit6=1, 进入下一步, 否则循环当前步骤
1. 向sector count 寄存器中写入待操作的扇区数
1. 往该通道上的三个 LBA 寄存器写入扇区起始地址的低 24 位
1. 往 device 寄存器中写入 LBA 地址的 24～27 位，并置第 6 位为 1 ，使其为 LBA 模式，置第 4位为0，选择操作的硬盘（ 0, master 硬盘; 1,slave 硬盘）
1. 向command 寄存器写入操作命令0x20
1. 读取status, 如果该端口bit7=0 && bit3=1, 进入下一步, 否则循环当前步骤
1. 从data寄存器读取数据, 如果读取一个扇区, 则需要循环读取256次

ide磁盘写步骤:
1. 读取status, 如果该端口bit7=0 && bit6=1, 进入下一步, 否则循环当前步骤
1. 向sector count 寄存器中写入待操作的扇区数
1. 往该通道上的三个 LBA 寄存器写入扇区起始地址的低 24 位
1. 往 device 寄存器中写入 LBA 地址的 24～27 位，并置第 6 位为 1 ，使其为 LBA 模式, 置第 4位为0，选择操作的硬盘（ 0, master 硬盘; 1, slave 硬盘）
1. 向command 寄存器写入操作命令0x30
1. 读取status, 如果该端口bit7=0 && bit3=1, 进入下一步, 否则循环当前步骤
1. 向data寄存器写入数据, 如果写入一个扇区, 则需要循环写入256次


## sysenter和sysexit指令
使用中断进行任务切换时，会有一系列的特权级别校验、上下文寄存器压栈等操作。本来这个作为普通的中断来说是可以忍受的，因为系统中的外部中断没有那么频繁。但是当中断用来进行内核态和用户态切换，大量使用后，带来的性能问题逐渐明显。

所以英特尔专门设计量sysenter和sysexit 这两个指令来实现内核态和用户态的切换。这两个指令没有中断的校验和压栈动作，性能要好得多。（校验和压栈的操作已经用其他设计来替代了）