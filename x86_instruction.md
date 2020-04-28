# x86 instruction
参考:
- x86/x86_64 : [<<Intel® 64 and IA-32 ArchitecturesSoftware Developer’s ManualVolume 2>>的Chapter 3~5](https://www.intel.com/content/dam/www/public/us/en/documents/manuals/64-ia-32-architectures-software-developer-instruction-set-reference-manual-325383.pdf)

## comp
参考:
- [Intel Instruction Set (gas) # CMP](https://www.cs.umb.edu/~cheungr/cs341/Instructions.pdf)

比较结果的处理, 即有条件跳转:
- je : 相等跳转
- jg : 第二个数大于第一个则跳转
- jge : 第二个数大于等于第一个则跳转
- jl : 第二个数小于第一个则跳转
- jle : 第二个数小于等于第一个则跳转

## jmp
无条件跳转