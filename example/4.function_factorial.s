# PURPOSE: 递归函数, 求n!
.intel_syntax noprefix
.section .data
.section .text
.globl _start
.globl factorial

_start:
    push 4
    call factorial
    add rsp, 8 # 撤销栈帧
    mov rbx, rax

    mov rax, 1
    int 0x80

.type factorial @function
factorial:
    push rbp
    mov rbp, rsp

    mov rax, [rbp+16] # 获取参数
    cmp rax, 1
    je end_factorial
    dec rax
    push rax # 保存向下一个call传递的参数
    call factorial # 此时rax保存的是下一个函数的返回值

    mov rbx, [rbp+16] # 获取参数
    imul rax, rbx

    end_factorial:
        mov rsp, rbp # 将rsp重置为rbp. 因为修改了rsp
        pop rbp
        ret
    