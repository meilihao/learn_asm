.intel_syntax noprefix
.include "linux.s"
.include "record-def.s"

.section .data
file_name:
.ascii "test.dat\0"

.section .bss
.lcomm record_buffer, RECORD_SIZE

.section .text
# 主程序
.globl _start
_start:
mov rbp, rsp

# 打开文件
mov rax, SYS_OPEN
lea rdi, file_name
mov rsi, 0 # 表示只读打开
mov rdx, 0666
syscall

# 保存文件描述符
push rax

record_read_loop:
mov rdi, QWORD PTR [rsp]
lea rsi, record_buffer
call read_record # 去取一个record

# 返回读取的字节数
# 如果字节数与我们请求的字节数不同, 
# 说明已到达文件结束处或出现错误,
# 我们就要退出
cmp rax, RECORD_SIZE
jne finished_reading

# 否则, 打印"名", 但我们首先必须知道名的大小
lea rdi, RECORD_FIRSTNAME + record_buffer
push rdi # count_chars 使用了rdi
call count_chars

pop rdi
mov rsi, rdi # 缓冲开始的位置
mov rdi, 1 # stdout=1
mov rdx, rax # name length
mov rax, SYS_WRITE
syscall

mov rdi, 1 # stdout=1
call write_newline

jmp record_read_loop

finished_reading:
mov rsp, rbp

mov rax, SYS_EXIT
mov rdi, 0
syscall
