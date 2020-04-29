# PURPOSE: 查找数组中的最大值
# rax : 保存当前操作的数据
# rdi : 保存当前rax对应的index
# rbx : 保存当前已找到的max, 作为退出码返回. 因为退出码是0~255, 因此data_items中大于255的值会导致输出结果异常

.section .data
data_items:
	.long 3,67,34,222,45,75,54,34,44,33,22,11,66,0 # 最后的0表示数据结束, 不属于数据项的内容
.section .text
.globl _start
_start:# 载入第一个值, 默认它是最大值
	movq $0, %rdi
	movq data_items(, %rdi, 4), %rax  # movl 起始地址(, %索引寄存器, 字长) => addr = data_items's addr + rdi*4
	movq %rax, %rbx

start_loop:
	cmpl $0, %eax # 将判断结果写入eflags
	je loop_exit # je 相等则跳转
	incl %edi # edi++
	movl data_items(, %edi, 4), %eax
	cmpl %ebx, %eax
	jle start_loop

	movl %eax, %ebx
	jmp start_loop # 跳到循环开始处

loop_exit:
	movq $1, %rax # syscall exit
	int $0x80

