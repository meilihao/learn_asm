.intel_syntax noprefix
.include "linux.s"
.globl error_exit
.type error_exit, @function
error_exit:
push rbp
mov rbp, rsp

push rdi
push rsi
# Write out error code
call count_chars

mov rdx, rax
mov rax, SYS_WRITE
mov rdi, STDERR
mov rsi, QWORD PTR [rsp+8]
syscall

# Write out error message
mov rdi, QWORD PTR [rsp]
call count_chars

mov rdx, rax
mov rax, SYS_WRITE
mov rdi, STDERR
mov rsi, QWORD PTR [rsp]
syscall

mov rdi, STDERR
call write_newline

# Exit
mov rsp, rbp

mov rax, SYS_EXIT
mov rdi, 1
syscall
