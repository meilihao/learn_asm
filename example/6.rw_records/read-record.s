.intel_syntax noprefix
.include "record-def.s"
.include "linux.s"

# 目的: 此函数从文件描述符读取一条记录
# 
# 输入: 文件描述及缓冲区
# 
# 输出: 本函数将数据写入缓冲区
# 		并返回状态码
#

# 栈局部变量
.section .text
.globl read_record
.type read_record, @function
read_record:
push rbp
mov rbp, rsp

# 直接使用传入的rdi, rsi即可
mov rax, SYS_READ
mov rdx, RECORD_SIZE
syscall

mov rsp, rbp
pop rbp
ret
