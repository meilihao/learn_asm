# 让stdout换行
.intel_syntax noprefix
.include "linux.s"
.globl write_newline
.type write_newline, @function
.section .data
newline:
.ascii "\n"
.section .text
write_newline:
push rbp
mov rbp, rsp

# 直接使用传入的rdi, rsi即可
mov rax, SYS_WRITE
lea rsi, newline
mov rdx, 1
syscall

pop rbp
ret
