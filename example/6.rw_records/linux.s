.intel_syntax noprefix
# Linux常量定义

# 系统调用号
.equ SYS_EXIT, 0x3c # 60
.equ SYS_READ, 0
.equ SYS_WRITE, 1
.equ SYS_OPEN, 2
.equ SYS_CLOSE, 3
.equ SYS_BRK, 12

# 标准文件描述符
.equ STDIN, 0
.equ STDOUT, 1
.equ STDERR, 2

# 通用状态码
.equ END_OF_FILE, 0
