# PURPOSE: 退出并向linux kernel返回一个状态码
# IN: none
# OUT: returns a status code, 能用`echo $?`读取
.intel_syntax noprefix
.section .data
.section .text
.globl _start
_start:
mov rax, 0x3c # 设置用于退出程序的syscall number, 这里指`exit`
mov rdi, 0 # 设在返回给kernel的退出码, `syscall exit`要求在rbx上设置退出码
syscall # int表示中断. 唤醒kernel, 以运行退出命令


# ```bash
# $ as --64 1.exit.s -o exit.o # 汇编
# $ ld exit.o -o exit # # 链接
# $ ./exit
# $ echo $?
# 0
# ```
