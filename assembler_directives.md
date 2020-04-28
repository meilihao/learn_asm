# Assembler Directives by gas
参考:
- [Using as # 7 Assembler Directives](https://sourceware.org/binutils/docs/as/index.html) from [gnu 文档的官网](https://www.gnu.org/manual/manual.html)
- [x86 Assembly Language Reference Manual](https://docs.oracle.com/cd/E26502_01/html/E28388/eoiyg.html)
- [nasm的Assembler Directives](https://www.nasm.us/xdoc/2.14.02/html/nasmdoc6.html) from [nasm 文档官网](https://www.nasm.us/docs.php)

指令是汇编器语法的一部分，但与具体指令集无关. 所有的汇编器指令都以句号`.`(ASCII 0x2E)开头.

## `.global`
`.global xxx`表示汇编程序不应在汇编之后废弃该符号, 因为ld(连接器)需要它.

- `.global _start` : `_start`是一个特殊符号, 标识了程序的开始位置.

## `.long`
`.long expression1, expression2, ..., expressionN`

`.long` : 是`.int`的等价命令, 为每一个表达式生成一个32 bit的整数. 每个表达式必须是一个32位的值，并且必须是一个整数值. `.long`指令对section `.bss`无效.

类似的指令有:
- `.byte` : 用byte生成
- `.ascii` : 用ascii字符生成


## `.section`
将程序分为几个部分.


- `.section .data` : 数据段的开始标识. 数据段中保存了程序数据所需的所有内存空间.
- `.section .text` : 本地段的开始标识. 文本段保存程序指令.
