# tool
## nasm
nasm是可以在windows、linux等系统下使用的汇编器, 而masm是微软专门为windows下汇编而写的，故而**推荐使用nasm或gcc的as**.

nasm注意点:
1. 它使用Intel语法
1. 区分大小写
1. 任何不被方括号[]括起来的标签或者变量名都被当作地址，访问其内容必须用[]包裹
1. `$`表示当前行被编译后的地址即当前行的偏移地址.

    `jmp $`: 表示死循环, 因为跳到当前位置后还是`jmp $`. 具体汇编解释: `jmp $`转化成机器码是EBFE，其中EB的意思是jmp short，FE是个补码数值，其实就是-2，这个jmp是相对跳转，跳转的地址就是执行完这条命令后，指令寄存器-2的地址，正好这条指令的长度就是2个字节，所以，又回到了这条指令重新执行.
1. `$$`表示一个节（section）的开始处被编译后的地址, 就是这个节的起始地址.

    一般写汇编程序的时候，使用一个section就够了，只有在写复杂程序的时候，才会用到多个section. section既可以是数据段，也可以是代码段. 所以，如果把section比喻成函数，还是不太恰当.

    `$-$$`表示本行程序距离节（section）开始处的相对距离. 如果只有一个节（section）的话，那么他就表示本行程序距离程序头的距离.

> as是GNU Binutils下的汇编器, 使用AT&T语法, 但v2.10+之后也支持intel语法.

> **[nasm的语法与gas有差异, 不兼容](https://www.ibm.com/developerworks/cn/linux/l-gas-nasm.html)**, 比如注释, 伪指令表示等, 可见[1.exit_nasm.s](/examples/1.exit_nasm_32.s)

## 获取汇编代码
```bash
# objdump -d a.out # 默认以AT&T语法输出
# objdump -d -m i386:x86-64:intel a.out # 以Intel语法输出. i386即Intel 80386, 但i386通常被用来作为对Intel（英特尔）32位微处理器的统称.
# objdump -d -M intel a.out # 也是以Intel语法输出
# gcc -S m.c # 默认以AT&T语法输出
# gcc -S -masm=intel m.c # 以Intel语法输出, `-masm`表示以哪种asm方言进行输出
```

example:
```bash
$ vim t.c
int test()
{
    int i = 0;
    i =  1 + 2;
    return i;
}

int main()
{
    test();
    return 0;
}
$ objdump -d -M intel a.out # 以Intel输出
...
0000000000001129 <test>:
    1129:   f3 0f 1e fa             endbr64 
    112d:   55                      push   rbp ; 保存当前栈的栈底
    112e:   48 89 e5                mov    rbp,rsp ; 栈底, 栈顶是同一个位置
    1131:   c7 45 fc 00 00 00 00    mov    DWORD PTR [rbp-0x4],0x0 ; 一个WORD是2B, 因此DWORD是4B, 这里是分配一个4B的空间保存i的值, 即`int i = 0`
    1138:   c7 45 fc 03 00 00 00    mov    DWORD PTR [rbp-0x4],0x3 ; i =  1 + 2
    113f:   8b 45 fc                mov    eax,DWORD PTR [rbp-0x4] ; eax保存返回值3
    1142:   5d                      pop    rbp ; `pop rbp` = `mov rbp, QWORD PTR [rsp]` + `add rsp,0x8`
    1143:   c3                      ret    ; ret =  pop rip = `mov rip, QWORD PTR [rsp]` + `add rsp,0x8`

0000000000001144 <main>: ; `0000000000001144`的长度是64 bit, 在x86_64下面，其实虚拟地址只使用了48位, 对应了256TB的地址空间, 通常已够用.
    1144:   f3 0f 1e fa             endbr64 
    1148:   55                      push   rbp
    1149:   48 89 e5                mov    rbp,rsp
    114c:   48 83 ec 10             sub    rsp,0x10
    1150:   b8 00 00 00 00          mov    eax,0x0
    1155:   e8 cf ff ff ff          call   1129 <test> ; call会将下一条指令地址115a压入栈中作为调用的返回地址, 然后跳到`func test`执行. `call 1129 <test>` = `push QWORD 115a` + `jmp 1129 <test>` = `sub rsp,0x8`(栈向低地址生长) + `mov QWORD PTR [rsp], 115a` + `jmp 1129 <test>`
    115a:   89 45 fc                mov    DWORD PTR [rbp-0x4],eax
    115d:   b8 00 00 00 00          mov    eax,0x0
    1162:   c9                      leave  
    1163:   c3                      ret    
    1164:   66 2e 0f 1f 84 00 00    nop    WORD PTR cs:[rax+rax*1+0x0]
    116b:   00 00 00 
    116e:   66 90                   xchg   ax,ax
...
$ objdump -d a.out # 以AT&T输出
...
0000000000001129 <test>:
    1129:   f3 0f 1e fa             endbr64 
    112d:   55                      push   %rbp
    112e:   48 89 e5                mov    %rsp,%rbp
    1131:   c7 45 fc 00 00 00 00    movl   $0x0,-0x4(%rbp)
    1138:   c7 45 fc 03 00 00 00    movl   $0x3,-0x4(%rbp)
    113f:   8b 45 fc                mov    -0x4(%rbp),%eax
    1142:   5d                      pop    %rbp
    1143:   c3                      retq   

0000000000001144 <main>:
    1144:   f3 0f 1e fa             endbr64 
    1148:   55                      push   %rbp
    1149:   48 89 e5                mov    %rsp,%rbp
    114c:   48 83 ec 10             sub    $0x10,%rsp
    1150:   b8 00 00 00 00          mov    $0x0,%eax
    1155:   e8 cf ff ff ff          callq  1129 <test>
    115a:   89 45 fc                mov    %eax,-0x4(%rbp)
    115d:   b8 00 00 00 00          mov    $0x0,%eax
    1162:   c9                      leaveq ; leaveq = movq %rbp, %rsp; popq %rbp
    1163:   c3                      retq   
    1164:   66 2e 0f 1f 84 00 00    nopw   %cs:0x0(%rax,%rax,1)
    116b:   00 00 00 
    116e:   66 90                   xchg   %ax,%ax
...
```