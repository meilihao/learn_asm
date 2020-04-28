# PURPOSE: 函数如何工作
# 计算: 2^3 + 5^2
.section .data
.section .text
.globl _start
_start:
    pushq $3 # 压入第二个参数
    pushq $2 # 压入第一个参数
    call power
    addq $16, %rsp # 释放传入的两个参数
    pushq %rax # 保存第一个数的答案

    pushq $2
    pushq $5
    call power
    addq $16, %rsp

    popq %rbx # 取出2^3的结果

    addq %rax, %rbx # 加上rax=5^2
    movq $1, %rax
    int $0x80

# rbx : 保存底数
# rcx : 保存指数
.type power @function
power:
    pushq %rbp
    movq %rsp, %rbp

    movq 16(%rbp), %rbx
    movq 24(%rbp), %rcx

    movq %rbx, %rax

    power_loop_start:
        cmpq $1, %rcx
        je end_power
        imulq %rbx, %rax
        decq %rcx # 指数递减
        jmp power_loop_start

    end_power:
        popq %rbp # 将rbp重置为上一个栈帧的rbp
        ret

