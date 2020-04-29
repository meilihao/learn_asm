# PURPOSE: 函数如何工作
# 计算: 2^3 + 5^2
.intel_syntax noprefix
.section .data
.section .text
.globl _start
_start:
    push 3 # 压入第二个参数
    push 2 # 压入第一个参数
    call power
    addq rsp, 16 # 释放传入的两个参数
    pushq rax # 保存第一个数的答案

    pushq 2
    pushq 5
    call power
    add rsp, 16

    pop rdi # 取出2^3的结果

    add rdi, rax # 加上rax=5^2
    mov rax, 0x3c
    syscall

.type power @function
power:
    push rbp
    mov rbp, rsp

    mov rbx, QWORD PTR [rbp + 16] # rbx : 保存底数
    mov rcx, QWORD PTR [rbp + 24] # rcx : 保存指数

    mov rax, rbx # rax : 保存相乘的结果

    power_loop_start:
        cmp rcx, 1 # 因为初始时rax==rbx, 因此判断指数减到1即可结束
        je end_power
        imul rax, rbx # rax*=rbx
        dec rcx # 指数递减
        jmp power_loop_start

    end_power:
        pop rbp # 将rbp重置为上一个栈帧的rbp. 因为没有修改rsp因此不用执行`mov rsp, rbp`
        ret

