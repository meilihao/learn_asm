# PURPOSE: 递归函数, 求n!
.section .data
.section .text
.globl _start
.globl factorial

_start:
    pushq $4
    call factorial
    addq $8, %rsp
    movq %rax, %rbx

    movq $1, %rax
    int $0x80

.type factorial @function
factorial:
    pushq %rbp
    movq %rsp, %rbp

    movq 16(%rbp), %rax # 获取参数
    cmpq $1, %rax
    je end_factorial
    decq %rax
    pushq %rax # 保存向下一个call传递的参数
    call factorial # 此时rax保存的是下一个函数的返回值

    movq 16(%rbp),%rbx # 获取参数
    imulq %rbx, %rax

    end_factorial:
        movq %rbp, %rsp # 将rsp重置为rbp. 因为修改了rsp
        popq %rbp
        ret
    