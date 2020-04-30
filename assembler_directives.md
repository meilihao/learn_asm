# Assembler Directives by gas
参考:
- [Using as # 7 Assembler Directives](https://sourceware.org/binutils/docs/as/index.html) from [gnu 文档的官网](https://www.gnu.org/manual/manual.html)
- [x86 Assembly Language Reference Manual](https://docs.oracle.com/cd/E26502_01/html/E28388/eoiyg.html)
- [nasm的Assembler Directives](https://www.nasm.us/xdoc/2.14.02/html/nasmdoc6.html) from [nasm 文档官网](https://www.nasm.us/docs.php)

指令是汇编器语法的一部分，但与具体指令集无关. 所有的汇编器指令都以句号`.`(ASCII 0x2E)开头.

> nm命令可查看程序的符号信息.

## `.comm`
`.comm ${symbol}, ${length}`

声明为未初始化的全局(通用)内存区域, 放入`.bss`段.

相当于全局的未初始化变量 或者static 全局未初始化变量

## `.lcomm`
`.lcomm ${symbol}, ${length}`, 放入`.bss`段.

声明为未初始化的local(本地)内存区域.

相当于局部的static 未初始化变量

> `l`是`local`

## `.equ`
`.equ ${symbol}, ${value}`

让其左边的标识符可代表右边的表达式, 并不会给标识符分配内存. 标识符不能重名, 也不能重新定义. 类似于c的`#define ...`

`.equ BaseOfStack, 0x7c00`

## `.global`
`.global xxx`表示汇编程序不应在汇编之后废弃该符号即该符号能够被外部程序访问, 比如ld(连接器)可能需要它.

- `.global _start` : `_start`是一个特殊符号, 标识了程序的开始位置.

## `.long`
`.long expression1, expression2, ..., expressionN`

`.long` : 是`.int`的等价命令, 为每一个表达式生成一个32 bit的整数. 每个表达式必须是一个32位的值，并且必须是一个整数值. `.long`指令对section `.bss`无效.

类似的指令有:
- `.byte` : 用byte生成
- `.ascii` : 用ascii字符生成


## `.section`
将程序分为几个部分.

- `.section .bss` : `.bss`段的开始标识. 它存储了**未初始化的全局变量或者是默认初始化为0的全局变量**, 且不占空间, 属于静态内存分配.

    仅在程序运行时，才会给`.bss`段里面的变量分配内存空间.
- `.section .data` : 数据段的开始标识. 它存储了已初始化的全局变量，但初始化为0的全局变量出于编译优化的策略还是被保存在`.bss`中, 属于静态内存分配.
- `.section .rel.text`: 针对`.text`段的重定位表，还有rel.data(针对data段的重定位表).
- `.section .rodata` : 该段也叫常量区(只读)，用于存放常量数据, 比如字符串常量, 全局const变量和#define定义的常量.

    特殊:
    1. 部分立即数会直接存放在`.text`中
    1. 对于字符串常量，编译器会去掉重复的常量，让程序的每个字符串常量只有一份
    1. `.rodata`是在多个进程间是共享的，这可以提高空间利用率
- `.section .strtab`: 存储变量名，函数名等. 例如, `char* szPath="/root"`, `void func()`的变量名szPath和函数名func就存储在`.strtab`段.
- `.section .shstrtab`: bss,text,data等段名存储在这里.
- `.section .text` : 本地段的开始标识. 文本段保存程序指令.

> bss是Block Started by Symbol

> static 声明的变量，无论它是全局变量还是在函数之中，只要是没有赋初值都存放在.bss段，如果赋了初值，则把它放在.data段.

## `.type`
`.type name,@type` : 将符号name的type属性设为type, 其中type可以是function或object.

`.type`会告诉ld将符号name作为function或object.
