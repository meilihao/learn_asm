# cpuid.s Sample program to extract the processor Vendor ID
# # as -o a.o call-libc.s                                                                                                            14:21:43
# # ld a.o --dynamic-linker /lib64/ld-linux-x86-64.so.2 -lc -o a.out # a.out会使用共享库, 可用`ldd ./a.out`查看. 其中-lc 选项表示需要连接libc.so库, printf 必须; --dynamic-linker /lib/ld-linux.so.2 也必须指定，否则即使连接未报错，也会在运行时出现bash: ./a.out: No such file or directory 错误
.intel_syntax noprefix
.section .data
output:
	.ascii "hello world\n\0" # **`\0`不能忘记, 否则output,output2会被分配到一起, 中间没有`\0`分隔,即output变成了output+output2, 会导致程序输出行为异常**

.section .text
.globl _start
_start:

lea rdi, output
mov rax, 0 # 表示未传入浮点数, 见[base.md#GCC的x86平台cdecl规范详解]
call printf

mov rdi, 0
call exit
