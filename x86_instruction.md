# x86 instruction
参考:
- x86/x86_64 : [<<Intel® 64 and IA-32 ArchitecturesSoftware Developer’s ManualVolume 2>>的Chapter 3~5](https://www.intel.com/content/dam/www/public/us/en/documents/manuals/64-ia-32-architectures-software-developer-instruction-set-reference-manual-325383.pdf)
- [Linux 下 64 位汇编语言](https://blog.codekissyoung.com/%E8%AE%A1%E7%AE%97%E6%9C%BA%E6%9E%84%E9%80%A0%E4%B8%8E%E7%BB%84%E6%88%90/64%E4%BD%8DCPU%E6%B1%87%E7%BC%96%E8%AF%AD%E8%A8%80)

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

### div[L]
无符号除法

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
对操作数的每一位取反

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
### call
函数调用

`call ${function_name}`

### int
触发中断

### ret

### jmp
无条件跳转

JMP指令需要编译器生成目标标签(LABEL）. 标签必须唯一，并且是汇编文件内部私有，对外部不可见，除非有.globl指示. 按C语言的说法，汇编中没有修饰的标签是static的，.globl修饰的标签是extern的.

### cmp[L]
参考:
- [Intel Instruction Set (gas) # CMP](/misc/doc/Intel_Instruction_Set_gas.pdf)

`cmpq $1, %rcx` => `if 1 ? rcx`, 比较结果的处理, 即有条件跳转:
- je : 相等跳转
- jne : 不相等跳转
- jg : 第二个数大于第一个则跳转
- jge : 第二个数大于等于第一个则跳转
- jl : 第二个数小于第一个则跳转
- jle : 第二个数小于等于第一个则跳转

## 栈 statck
`PUSH rax`
`POP rax`

## 函数调用 Calling Functions

## lea
lea(load effective address, 加载有效地址)，可以将有效地址传送到指定的的寄存器. 简单说, 就是C语言中的`&`.

## mov[L]
赋值

`movq %rax, %rbx` => rbx = rax