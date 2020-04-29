# 目的: 读取一个文件并将其中的所有大写字母转成小写再输出到其他文件
# `./a.out 5.in.txt 5.out.txt`
.intel_syntax noprefix
.equ SYSEXIT, 1
.equ SYSREAD, 3
.equ SYSWRITE, 4
.equ SYSOPEN, 5
.equ SYSCLOSE, 6

# 打开文件的选项见/usr/include/asm-generic/fcntl.h, 允许选项叠加
.equ O_RDONLY, 0
.equ O_CREAT_WRONLY_TRUNC, 03101

# std fd
.equ STDIN, 0
.equ STDOUT, 1
.equ STDERR, 2

# int
.equ LINUX_SYSCALL, 0x80 # do syscall
.equ END_OF_File, 0 # read操作的返回值, 表示已到达文件结束处
.equ NUMBER_ARGUMENTS, 2

.section .bss
.equ BUFFER_SIZE, 500
.lcomm BUFFER_DATA, BUFFER_SIZE

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

# linux开始时, 所有指向命令行参数的指针都存储在栈中, 参数个数在[rsp+16], 程序名在[rsp+24], 参数在[rsp+32]及之后的存储位置, 参数以`\0`结尾.
open_files:
open_fd_in: # 打开文件, 会将fd结果放入rax
    mov rax, SYSOPEN
    mov rbx, [rbp+ST_ARGV_1] # 获取输入文件名
    mov rcx, O_RDONLY # 打开选项
    mov rdx, 0666 # 权限
    int LINUX_SYSCALL

store_fd_in:
    sub rsp, ST_SIZE_RESERVE
    mov [rsp], rax # 保存输入文件的fd

open_fd_out:
    mov rax, SYSOPEN
    mov rbx, [rbp+ST_ARGV_2] # 获取输出文件名
    mov rcx, O_CREAT_WRONLY_TRUNC
    mov rdx, 0666
    int LINUX_SYSCALL

store_fd_out:
    sub rsp, ST_SIZE_RESERVE
    mov [rsp], rax # 保存输出文件的fd

read_loop_begin: # 开始主逻辑
    mov rax, SYSREAD
    mov rbx, [rbp+ST_FD_IN] # rbx放入fd
    mov rcx, BUFFER_DATA # rcx保存缓存区地址
    mov rdx, BUFFER_SIZE # rdx保存缓存区大小
    int LINUX_SYSCALL

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
    mov rbx, [rbp+ST_FD_OUT] # 要写入的fd
    mov rcx, BUFFER_DATA # 缓存区位置
    int LINUX_SYSCALL

    jmp read_loop_begin

end_loop:
    mov rax, SYSCLOSE # 关闭文件
    mov rbx, [rbp+ST_FD_OUT] # 将要关闭的fd放入rbx
    int LINUX_SYSCALL

    mov rax, SYSCLOSE
    mov rbx, [rbp+ST_FD_IN]
    int LINUX_SYSCALL

    mov rax, SYSEXIT # 退出
    mov rbx, 0
    int LINUX_SYSCALL

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

mov rax, [rbp+ST_BUFFER] # 获取缓存区地址
mov rbx, [rbp+ST_BUFFER_LEN] # 读到的长度
mov rdi, 0 # 首次开始读取的index

cmp rbx,0 # 给定的缓存区长度为0时退出
je end_convert_loop

convert_loop: # 开始循环
    mov cl, [rax+rdi*1] # 获取当前字节

    cmp cl, LOWERCASE_A
    jl next_byte
    cmp cl, LOWERCASE_Z
    jg next_byte

    add cl, UPPER_CONVERSION # 小写->大写
    mov [rax+ rdi*1], cl

next_byte:
    inc rdi # 下一个字节
    cmp rbx, rdi
    jne convert_loop # 不等于就继续

end_convert_loop:
mov rsp, rbp # 无返回值, 离开程序即可
pop rbp
ret
