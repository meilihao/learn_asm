.intel_syntax noprefix
.include "linux.s"
.include "record-def.s"
.section .data
input_file_name:
.ascii "test.dat\0"

output_file_name:
.ascii "testout.dat\0"

.section .bss
.lcomm record_buffer, RECORD_SIZE

.section .text
.globl _start
_start:
# 复制栈指针并为局部变量分配空间
mov rbp, rsp

# 打开文件
mov rax, SYS_OPEN
lea rdi, input_file_name
mov rsi, 0 # 表示只读打开
mov rdx, 0666
syscall

# 返回值检查
cmp rax, 0
jg continue_processing

# Send the error
.section .data
no_open_file_code:
.ascii "0001: \0"
no_open_file_msg:
.ascii "Can’t Open Input File\0"
.section .text

lea rdi, no_open_file_code
lea rsi, no_open_file_msg
call error_exit

continue_processing:
push rax

mov rax, SYS_OPEN
lea rdi, output_file_name
mov rsi, 0101
mov rdx, 0666
syscall
push rax

loop_begin:
mov rdi, QWORD PTR [rsp+8]
lea rsi, record_buffer
call read_record # 去取一个record

# 返回读取的字节数
# 如果字节数与我们请求的字节数不同
# 说明已到达文件结束处或出现错误,
# 我们就要退出
cmp rax, RECORD_SIZE
jne loop_end

# 递增年龄
mov eax, DWORD PTR [record_buffer + RECORD_AGE]
inc eax
mov DWORD PTR [record_buffer + RECORD_AGE], eax

# 写记录
mov rdi, QWORD PTR [rsp]
lea rsi, record_buffer
call write_record

jmp loop_begin

loop_end:
# 关闭文件描述符
mov rax, SYS_CLOSE
mov rdi, QWORD PTR [rsp-8]
syscall

# 关闭文件描述符
mov rax, SYS_CLOSE
mov rdi, QWORD PTR [rsp]
syscall

mov rsp, rbp

mov rax, SYS_EXIT
mov rdi, 0
syscall
