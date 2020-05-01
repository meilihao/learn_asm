# 目的: 对字符进行计算, 直到遇到空字符 
#  		(如果你用过C语言, 就会发现这与strlen函数的功能相同)
# 
# 输入: 字符串地址
#
# 输出: 将计数值返回到%rax
#
#
.intel_syntax noprefix
.type count_chars, @function
.globl count_chars

count_chars:
push rbp
mov rbp, rsp

# 计数器从0开始
mov rcx, 0

count_loop_begin:
# 获取当前字符
mov al, BYTE PTR [rdi]
# 是否为空字符?
cmp al, 0
# 若为空字符则结束
je count_loop_end
# 否则, 递增计数器和指针
inc rcx
inc rdi
# 返回循环起始地址
jmp count_loop_begin

count_loop_end:
# 结束循环, 将计数值移入%rax并返回
mov rax, rcx

mov rsp, rbp
pop rbp
ret
