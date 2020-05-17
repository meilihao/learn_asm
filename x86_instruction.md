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
1. 源操作数8bit, x*al = ax
1. 源操作数16bit, x*ax = da:ax
1. 源操作数32bit, x*eax = xdx:xax


### div[L]
无符号除法

一般格式为：div reg或div 内存单元，reg和内存单元存放的是除数，除数可分为8位和16为2种.
被除数：默认放在AX或DX:AX，
    - 除数为8位，被除数则为16位，默认在AX中存放
    - 除数 为16位，被除数则为32位，在DX:AX中存放，DX存放高16位，AX存放低16位。

结果：如果除数为8位，则AL存储除法操作的商，AH存储除法操作的余数；如果除数为16位，则AX存储除法操作的商，DX存储除法操作的余数

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
函数调用

`call ${function_name}`

### int
触发中断

### ret

### jmp
无条件跳转

JMP指令需要编译器生成目标标签(LABEL）. 标签必须唯一，并且是汇编文件内部私有，对外部不可见，除非有.globl指示. 按C语言的说法，汇编中没有修饰的标签是static的，.globl修饰的标签是extern的.

- jc : 如果进位位被置位则跳转
- jnc : 如果进位位没有置位则跳转

### cmp[L]
参考:
- [Intel Instruction Set (gas) # CMP](/misc/doc/Intel_Instruction_Set_gas.pdf)

`cmpq $1, %rcx` => `if 1 ? rcx`, 比较结果的处理, 即有条件跳转:
- je : 相等跳转

    JE,JZ是完全相同的东西，只是不同的名称: 当ZF（`零`标志）等于1 时的条件跳转
- jne : 不相等跳转
- jg : 第二个数大于第一个则跳转
- jge : 第二个数大于等于第一个则跳转
- jl : 第二个数小于第一个则跳转
- jle : 第二个数小于等于第一个则跳转
- ja (jump above) : 大于则跳转 

### repe
repe是一个串操作前缀，它重复串操作指令，每重复一次ECX的值就减一.

### cmpsb
cmpsb是字符串比较指令，把ds:si/esi指向的数据与es:di/edi指向的数一个一个的进行比较. 每比较一次si, di会递增一次

## 栈 statck
`PUSH rax`
`POP rax`

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