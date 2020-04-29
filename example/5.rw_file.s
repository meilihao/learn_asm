# 目的: 读取一个文件并将其中的所有大写字母转成小写再输出到其他文件
# `./a.out 5.in.txt 5.out.txt`, 可用strace调试
.intel_syntax noprefix
.equ SYSEXIT, 0x3c
.equ SYSREAD, 0
.equ SYSWRITE, 1
.equ SYSOPEN, 2
.equ SYSCLOSE, 3


# 打开文件的选项见/usr/include/asm-generic/fcntl.h, 允许选项叠加
.equ O_RDONLY, 0
.equ O_CREAT_WRONLY_TRUNC, 03101

# std fd
.equ STDIN, 0
.equ STDOUT, 1
.equ STDERR, 2

# int
.equ END_OF_File, 0 # read操作的返回值, 表示已到达文件结束处
.equ NUMBER_ARGUMENTS, 2

.section .bss
.equ BUFFER_SIZE, 500
.lcomm BUFFER_DATA, BUFFER_SIZE # 运行时, BUFFER_DATA未初始化???

.section .text

# 栈位置
.equ ST_SIZE_RESERVE, 8 # 描述fd大小
.equ ST_FD_IN, -8
.equ ST_FD_OUT, -16
.equ ST_ARGC, 0 # 参数个数
.equ ST_ARGV_0, 8 # 程序名
.equ ST_ARGV_1, 16 # 输入文件名
.equ ST_ARGV_2, 24 # 输出文件名

.globl _start
_start:
mov rbp, rsp

# linux开始时, 所有指向命令行参数的指针都存储在栈中, 参数个数在[rsp], 程序名在[rsp+8], 参数在[rsp+16]及之后的存储位置, 指针指向的字符串参数以`\0`结尾.
open_files: # symbol不影响代码程序运行, 仅在程序跳转时有用
open_fd_in: # 打开文件, 会将fd结果放入rax
    mov rax, SYSOPEN
    mov rdi, QWORD PTR [rbp+ST_ARGV_1] # 获取输入文件名
    mov rsi, O_RDONLY # 打开选项
    mov rdx, 0 # 权限, 不影响实际的读操作
    syscall

store_fd_in:
    push rax # 保存输入文件的fd

open_fd_out:
    mov rax, SYSOPEN
    mov rdi, QWORD PTR [rbp+ST_ARGV_2] # 获取输出文件名
    mov rsi, O_CREAT_WRONLY_TRUNC
    mov rdx, 0666
    syscall

store_fd_out:
    push rax # 保存输出文件的fd

read_loop_begin: # 开始主逻辑
    mov rax, SYSREAD
    mov rdi, QWORD PTR [rbp+ST_FD_IN] # rbx放入fd
    mov rsi, BUFFER_DATA # rcx保存缓存区地址
    mov rdx, BUFFER_SIZE # rdx保存缓存区大小
    syscall

    mov rdi, rax
    mov rax, SYSEXIT # 退出
    syscall

    cmp rax, END_OF_File # rax保存了读取到的字符数, 负数表示错误
    jle end_loop

continue_read_loop: # 将数据内容的小写换成大写
    push BUFFER_DATA
    push rax
    call convert_to_upper
    pop rax # 重新获取大小
    add rsp, 8 # 恢复rsp

    ## 将buf写入输出文件, 返回写入的字节数, 负数为错误
    mov rdx, rax # 要写入的大小
    mov rax, SYSWRITE
    mov rdi, QWORD PTR [rbp+ST_FD_OUT] # 要写入的fd
    mov rsi, BUFFER_DATA # 缓存区位置
    syscall

    jmp read_loop_begin

end_loop:
    mov rax, SYSCLOSE # 关闭文件
    mov rdi, QWORD PTR [rbp+ST_FD_OUT] # 将要关闭的fd放入rbx
    syscall

    mov rax, SYSCLOSE
    mov rdi, QWORD PTR [rbp+ST_FD_IN]
    syscall

    mov rax, SYSEXIT # 退出
    mov rdi, 0
    syscall

# 搜索边界
.equ LOWERCASE_A, 'a'
.equ LOWERCASE_Z, 'z'
.equ UPPER_CONVERSION, 32 # 'A' - 'a', 小写-32=大写

###STACK STUFF###
.equ ST_BUFFER, 24 # 保存缓存区地址
.equ ST_BUFFER_LEN, 16 # 保存读到的长度

convert_to_upper:
push rbp
mov rbp, rsp

mov rax, QWORD PTR [rbp+ST_BUFFER] # 获取缓存区地址
mov rbx, QWORD PTR [rbp+ST_BUFFER_LEN] # 读到的长度
mov rdi, 0 # 首次开始读取的index

cmp rbx,0 # 给定的缓存区长度为0时退出
je end_convert_loop

convert_loop: # 开始循环
    mov cl, BYTE PTR [rax+rdi*1] # 获取当前字节

    cmp cl, LOWERCASE_A
    jl next_byte
    cmp cl, LOWERCASE_Z
    jg next_byte

    add cl, UPPER_CONVERSION # 小写->大写
    mov BYTE PTR [rax+ rdi*1], cl

next_byte:
    inc rdi # 下一个字节
    cmp rbx, rdi
    jne convert_loop # 不等于就继续

end_convert_loop:
mov rsp, rbp # 无返回值, 离开程序即可
pop rbp
ret
