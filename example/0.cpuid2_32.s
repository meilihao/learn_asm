# cpuid2.s View the CPUID Vendor ID string using C library calls
# as -o a.o cpuid2_32.s
# ld --dynamic-linker /lib/ld-Linux.so.2 -lc -o a.out a.o # 预计要32位库:lib32-glibc, 未验证
.code32
.section .data
output:
	.asciz "The processor Vendor ID is '%s'\n\0"

.section .bss
.lcomm buffer, 12

.section .text
.globl _start
_start:
	movl $0, %eax
	cpuid
	movl $buffer, %edi
	movl %ebx, (%edi)
	movl %edx, 4(%edi)
	movl %ecx, 8(%edi)
	pushl $buffer
	pushl $output
	call printf
	addl $8, %esp
	pushl $0
	call exit
