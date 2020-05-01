.intel_syntax noprefix
.include "linux.s"
.include "record-def.s"
# 目的: 本函数将一条记录写入给定文件描述符
# 
# 输入: 文件描述符和缓冲区
#
# 输出: 本函数产生状态码
# 
# 栈局部变量
.section .text
.globl write_record
.type write_record, @function
write_record:
push rbp
mov rbp, rsp

# 直接使用传入的rdi, rsi即可
mov rax, SYS_WRITE
mov rdx, RECORD_SIZE
syscall

mov rsp, rbp
pop rbp
ret
