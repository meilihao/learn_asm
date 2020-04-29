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

## risc-v资料收集
- [RISC-V嵌入式开发入门篇2：RISC-V汇编语言程序设计（上）](https://mp.weixin.qq.com/s/jyI-SSm_5Gg-KQyjKsIj5Q)
- [硬件软件接口 (RISC-V) Chapter 2](https://blog.csdn.net/weixin_41531090/article/details/87627866)