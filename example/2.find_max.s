# PURPOSE: 查找数组中的最大值
# eax : 保存当前操作的数据
# rsi : 保存当前rax对应的index
# edi : 保存当前已找到的max, 作为退出码返回. 因为退出码是0~255, 因此data_items中大于255的值会导致输出结果异常
.intel_syntax noprefix
.section .data
data_items:
	.long 3,67,34,222,45,75,54,34,44,33,22,11,66,0 # `.long` => int32, 最后的0表示数据结束, 不属于数据项的内容.
.section .text
.globl _start
_start:# 载入第一个值, 默认它是最大值
	mov rsi, 0
	mov eax, DWORD PTR [rsi*4 + data_items]  # mov addr = rsi*4 + data_items's addr, DWORD PTR指定的长度必须与目的寄存器的位宽一致, 否则无法汇编.
	mov edi, eax

start_loop:
	cmp eax, 0 # 将判断结果写入eflags
	je loop_exit # je 相等则跳转
	inc rsi # rsi++
	mov eax, DWORD PTR [rsi*4 + data_items]
	cmp eax, edi
	jle start_loop

	mov edi, eax
	jmp start_loop # 跳到循环开始处

loop_exit:
	mov rax, 0x3c # syscall exit
	syscall

