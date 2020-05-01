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

## `.rept`/`.endr`
重复`.rept`,`.endr`间的指令n次.

```x86asm
.ascii "2224 S Johannan St\nChicago, IL 12345\0"
.rept 203 # 填充到240字节
.byte 0
.endr
```

## `.section`
将程序分为几个部分, 具体见[elf的可重定位文件](https://github.com/meilihao/programming-interface/blob/master/compile/elf.md).

## `.type`
`.type name,@type` : 将符号name的type属性设为type, 其中type可以是function或object.

`.type`会告诉ld将符号name作为function或object.
