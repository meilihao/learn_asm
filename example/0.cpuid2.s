# cpuid.s Sample program to extract the processor Vendor ID
# # as -o a.o cpuid2.s                                                                                                            14:21:43
# # ld a.o --dynamic-linker /lib64/ld-linux-x86-64.so.2 -lc -o a.out # 其中-lc 选项表示需要连接libc.so库, printf 必须; --dynamic-linker /lib/ld-linux.so.2 也必须指定，否则即使连接未报错，也会在运行时出现bash: ./a.out: No such file or directory 错误
.intel_syntax noprefix
.section .data
output:
	.ascii "The processor Vendor ID is '%s'\n\0" # **`\0`不能忘记, 否则output,output2会被分配到一起, 中间没有`\0`分隔,即output变成了output+output2, 会导致程序输出行为异常**
output2:
	.ascii "test\0"
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
lea rdi, buffer
mov DWORD PTR [rdi], ebx # output中单引号包裹的第一个字节的index
mov DWORD PTR [rdi+4], edx
mov DWORD PTR [rdi+8], ecx

lea rsi, buffer # 在x64环境下，参数传递方式跟在x86下不同，前者用的是多用寄存器，后者用的是压栈.
lea rdi, output
mov rax, 0 # 表示未传入浮点数, 见[base.md#GCC的x86平台cdecl规范详解]
call printf

lea rsi, output2
lea rdi, output
mov rax, 0
call printf

mov rdi, 0
call exit
