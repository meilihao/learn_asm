# cpuid.s Sample program to extract the processor Vendor ID
# ## att
# .section .data
# output:
# 	.ascii "The processor Vendor ID is 'xxxxxxxxxxxx'\n"
# .section .text
# .globl _start
# _start:
# 	movl $0, %eax
# 	cpuid
# movl $output, %edi
# movl %ebx, 28(%edi)
# movl %edx, 32(%edi)
# movl %ecx, 36(%edi)
# movl $4, %eax
# movl $1, %ebx
# movl $output, %ecx
# movl $42, %edx
# int $0x80
# movl $1, %eax
# movl $0, %ebx
# int $0x80
.intel_syntax noprefix
.section .data
output:
	.ascii "The processor Vendor ID is 'xxxxxxxxxxxx'\n"
output2:
	.ascii "The processor Vendor ID is '%s'\n"
.section .bss
.lcomm buffer, 12

.section .text
.globl _start
_start:
mov rax,0
cpuid # CPUID 	按照最初输入 EAX 寄存器的值，将处理器标识与功能信息返回给 EAX、EBX、ECX 及 EDX 寄存器
# EBX:756E6547H 'Genu'
# EDX:49656E69H 'ineI'
# ECX:6C65746EH 'ntel'
# EBX,EDX,ECX 将连成"GenuineIntel", 真正的Intel
lea rdi, output
mov DWORD PTR [rdi+28], ebx # output中单引号包裹的第一个字节的index
mov DWORD PTR [rdi+32], edx
mov DWORD PTR [rdi+36], ecx

mov rax, 1 # sys_write
mov rdi, 1 # STDOUT
lea rsi, output
mov rdx, 42
syscall

mov rax, 0x3c
mov rdi, 0
syscall
