; PURPOSE: 退出并向linux kernel返回一个状态码
; IN: none
; OUT: returns a status code, 能用`echo $?`读取
section .data
section .text
global _start
_start:
mov rax, 1 ; 设置用于退出程序的syscall number, 这里指`exit`
mov rbx, 0 ; 设在返回给kernel的退出码, `syscall exit`要求在rbx上设置退出码
int 0x80 ; int表示中断. 唤醒kernel, 以运行退出命令

; ```bash
; $ nasm -f elf64 1.exit_nasm.s -o exit.o ; 汇编
; $ ld exit.o -o exit ; 链接
; $ ./exit
; $ echo $?
; 0
; ```
