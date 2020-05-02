# learn asm
参考:
- <<深入理解程序设计使用Linux汇编语言>>
- [Linux Assembly Tutorial Step-by-Step Guide](https://montcs.bloomu.edu/Information/LowLevel/Assembly/assembly-tutorial.html)
- [Assembly Programming Tutorial for nasm with intel format](https://www.tutorialspoint.com/assembly_programming/index.htm)

os: linux x86_64

## asm语法
参考:
- [在GAS、GCC中使用Intel格式汇编代码](https://tkxb.wordpress.com/2018/02/22/%E5%9C%A8gas%E3%80%81gcc%E4%B8%AD%E4%BD%BF%E7%94%A8intel%E6%A0%BC%E5%BC%8F%E6%B1%87%E7%BC%96%E4%BB%A3%E7%A0%81/)

x86有两个流行的汇编方言版本：Intel/Microsoft和AT＆T/Linux.
AT&T语法是一种相当老的语法，由GAS和一些老式汇编器使用；NASM使用Intel语法，大多数汇编器都支持intel语法, 比如TASM和MASM. 但GAS的现代版本(from v2.10+)已支持`.intel_syntax`指令，即允许在GAS 中使用Intel语法.

我使用英特尔语法的部分原因还有它将目的地放在左边，而源操作数放在右边，与RISC-V，ARM-32和MIPS-32的操作数顺序一致.

使用intel语法的相关改变:
- gas : 开头加`.intel_syntax noprefix ;不需要寄存器的前缀%`
- gcc : `gcc -masm=intel test.c -o test` // `-masm = intel`用于编译包含Intel语法内联汇编的源文件
- objdump : `objdump -M intel -d program_name`, // 我通常使用更详细的`objdump -M x86-64,intel,intel-mnemonic,intel64 -d program_name`
- 内联汇编: 参考[这里](https://tkxb.wordpress.com/2018/02/22/%E5%9C%A8gas%E3%80%81gcc%E4%B8%AD%E4%BD%BF%E7%94%A8intel%E6%A0%BC%E5%BC%8F%E6%B1%87%E7%BC%96%E4%BB%A3%E7%A0%81/)

> 具体`AT&T汇编和Intel汇编差异`见[这里](/base.md).

## 指令集
- x86/x86_64 : [<<Intel® 64 and IA-32 ArchitecturesSoftware Developer’s ManualVolume 2>>的Chapter 3~5](https://www.intel.com/content/dam/www/public/us/en/documents/manuals/64-ia-32-architectures-software-developer-instruction-set-reference-manual-325383.pdf)

## 64 bit汇编
参考:
- [linux x64 汇编.md](https://github.com/Byzero512/blog_data/blob/master/linux%20x64%20%E6%B1%87%E7%BC%96.md)

1. 用户模式的系统调用依次传递的寄存器为: rdi,rsi,rdx,rcx,r8和r9
1. 内核接口的系统调用一次传递的寄存器为: rdi,rsi,rdx,r10,r8和r9. 注意这里和用户模式的系统调用只有第4个寄存器不同，其他都相同
1. 系统调用通过syscall指令进入，不像32位下的汇编使用的是int 0x80指令；
1. 系统调用号放在rax寄存器里
1. 系统调用限制最多6个参数
1. 系统调用的返回结果，也就是syscall指令的返回放在rax寄存器中
1. 只有整形值和内存型的值可以传递给内核

### Linux 32位系统调用和64位系统调用的区别
参考:
- [Linux 系统调用权威指南(2016)](http://arthurchiao.art/blog/system-call-definitive-guide-zh/) 翻译自[The Definitive Guide to Linux System Calls](https://blog.packagecloud.io/eng/2016/04/05/the-definitive-guide-to-linux-system-calls/)

- 系统调用号(syscall)不同

    参考:
    - [syscalls on x86](https://syscalls.kernelgrok.com/) @ `/arch/x86/syscalls/syscall_32.tbl`
    - [syscalls on x86_64](https://filippo.io/linux-syscall-table/)或[Linux System Call Table for x86 64带寄存器使用说明](http://blog.rchapman.org/posts/Linux_System_Call_Table_for_x86_64/) @ `arch/x86/syscalls/syscall_64.tbl`

    比如:
    - x84 sys_init(0x01) : eax = 0x01, ebx = int error_code
    - x86_64 sys_init(0x3c) : rax = 0x3c, rdi = int error_code

    **手写汇编代码来发起系统调用并不是一个好主意. 其中一个重要原因是，glibc 中有 一些额外代码在系统调用之前或之后执行（而自己写的汇编代码没有做这些类似的工作）**. 同时内核的 ABI 可能会有不兼容更新. 而内核和 libc 实现通常（可能）会为每个系统自动选择最快的系统调用方式, 以避免出问题.

    比如使用 exit 系统调用: 事实上可以用 atexit函数向 exit 注册 回调函数，在它退出的时候就会执行. 这些函数是从 glibc 里调用的，而不是内核. 因此，如果自己写的汇编代码调用 exit，那注册的回调函数就不会被执行，因为这种方 式绕过了 glibc.

    **然而，徒手写汇编来调系统调用是一次很好的学习方式.**
- 调用方法不同
    
    在32位下用int 0x80中断(是软中断, 对应中断函数是ia32_syscall@`arch/x86/ia32/ia32entry.S`)进行系统调用，而64位下需要用syscall指令进行系统调用

    在x86_64上使用`int 0x80`会导致发生segfault(原因: 变量地址是64bit, 用0x80号中断调用时仅用到32bit地址, 高32bit丢失, 导致内存访问时地址越界). `syscall`可参考[这里](https://stackoverflow.com/questions/12806584/what-is-better-int-0x80-or-syscall-in-32-bit-code-on-linux).

    调用error说明(保存在rax中):
    - /usr/include/asm-generic/errno-base.h
    - /usr/include/asm-generic/errno.h
- 传参方式不同(即ABI)

    32位程序，我们将系统调用号传入eax，调用参数压栈传递，系统调用返回值写入eax寄存器; 而64位程序，系统调用号传入rax，而各个参数按照rdi,rsi,rdx,rcx, r8, r9的顺序写入寄存器，系统调用返回值写入rax.

    见example的`cpuid*.s`的例子.

## risc-v资料收集
- [RISC-V嵌入式开发入门篇2：RISC-V汇编语言程序设计（上）](https://mp.weixin.qq.com/s/jyI-SSm_5Gg-KQyjKsIj5Q)
- [硬件软件接口 (RISC-V) Chapter 2](https://blog.csdn.net/weixin_41531090/article/details/87627866)

## 相关书单
- - <<深入理解程序设计使用Linux汇编语言>> : 不推荐, 内容是32-bit汇编