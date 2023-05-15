# base
汇编程序由三个不同的元素组成：
- 伪指令（Directives） 

    以点号开始，用来指示对编译器，连接器，调试器有用的结构信息, 指示本身不是汇编指令.例如，`.file` 只是记录原始源文件名. `.data`表示数据段(section)的开始地址, 而 `.text`表示实际程序代码的起始. `.string`表示数据段中的字符串常量. `.globl main`指明标签main是一个可以在其它模块的代码中被访问的全局符号等等.
- 标签（symbol/Labels） 

    以冒号结尾，用来把标签名和标签出现的位置关联起来. 例如，标签`.LC0:`表示紧接着的字符串的名称是`.LC0`. 标签`main:`表示main函数的开始. 按照惯例， 以点号开始的标签都是编译器生成的临时局部标签，其它标签则是用户可见的函数和全局变量名称.

- 指令（Instructions）

    实际的汇编代码, 一般都会缩进，以便和伪指令及symbol区分开来

    汇编指令=操作码 + 操作数.

    操作数分3种:
    - 立即数 : 即常量
    - 寄存器数 : 表示某个寄存器中保存的值
    - 寄存器引用 : 根据计算出的有效地址来访问存储器的某个位置

    数据传输指令(data transfer instruction): 在存储器和寄存器间移动数据的命令.

## 语法
### AT&T汇编和Intel汇编差异
linux kernel, gcc, objdump默认使用AT&T格式的汇编, 也叫GAS格式(Gnu ASembler GNU汇编器)；microsoft工具和intel的文档使用intel格式的汇编, [两者区别](http://timothyqiu.com/archives/difference-between-att-and-intel-asm-syntax/):
1. 书写: AT&T 汇编格式要求关键字必须小写; Intel则必须大写
1. 寄存器命名: 在 AT&T 汇编格式中要加上 '%' 作为前缀；Intel则不加
1. 源/目的操作数顺序: AT&T 语法先写源操作数，再写目标操作数；Intel则相反. 快速记忆: 记目标操作数在哪个位置即可.
1. 常数/立即数: AT&T 语法要在常数前加 `$`; Intel则不加
1. 操作数长度标识: AT&T 语法将操作数的大小表示在指令的后缀中（b、w、l, 分别是1,2,4字节）；Intel 语法将操作数的大小表示在操作数的前缀中（BYTE PTR、WORD PTR、DWORD PTR）
1. 内存寻址方式: AT&T 语法总体上是section:offset(base, index, width)的格式; Intel 语法总体上是section:[INDEX * WIDTH + BASE + OFFSET]的格式

    section用于指定段寄存器. 但由于 Linux 工作在保护模式下，用的是 32/48 位线性地址，所以在计算地址时不用考虑段基址和偏移量, 因此`addr= OFFSET + base + index * WIDTH`
1. jump和call: 远跳转指令, 远调用指令, 远返回的操作码，在 AT&T 汇编格式中为 "ljump", "lcall",`lret`; 而在 Intel 汇编格式中则为 "jmp far", "call far", `ret`

    AT&T:

        lcall $section:$offset
        ljmp $section:$offset
        lret

    Intel:

        CALL FAR SECTION:OFFSET ; 目标地址由段地址和段内偏移组成
        JMP FAR SECTION:OFFSET ; 同上
        RET

> AT&T在变量标识符前加`$`表示引用其地址

### 符号/标签
用来标记程序或数据的位置, 表示它将在汇编或链接过程中被指定内容替换. 引用该符号时就是引用其地址(汇编器在汇编时会用地址取代它).

格式:
```x86asm
<xxx>:
	...
```

`xxx`是一个符号, 后跟一个`:`和它定义的内容. 这种写法多用于跳转.

### 汇编指令/伪指令
在汇编代码中, 任何以`.`开头的指令都不会被直接编译成机器指令, 这些指令是针对汇编器的指令, 与机器指令集无关, 因此也被成为汇编指令(assembler directives)或为伪指令(pseudo-operations).

具体汇编指令见[这里](assembler_directives.md).

# 数据格式
字节(Byte) : 8bit
字(words) : 16bit
双字(double words) : 32bit
四字(quad words) : 64bit

# 寄存器
一些寄存器只有特殊指令可访问, 比如`rip`, `rflags`.

在x86 32bit os上, 寄存器用前缀`e`标识, x86_64 64bit os上用前缀`r`标识.

寄存器=通用寄存器 + 控制寄存器 + 段寄存器，　部分特殊寄存器未包含在该公式中．

通用寄存器=数据寄存器 + 指针寄存器 + 变址寄存器.

## 16 bit
数据寄存器
- AX (Accumulator) : 累加寄存器
- BX (Base) : 基地址寄存器
- CX (Count) : 计数器寄存器
- DX (Data) : 数据寄存器

指针寄存器
- SP(Stack Pointer) : 栈指针寄存器
- BP(Base Pointer) : 基指针寄存器

变址寄存器
- SI : (Source Index) : 源变地寄存器
- DI : (Destination Index) : 目的变址寄存器

控制寄存器
- IP (Instruction Pointer) : 指令指针寄存器
- FLAG : 标志寄存器

段寄存器
- CS (Code Segment) : 代码段寄存器
- DS (Data Segment) : 数据段寄存器
- SS (Stack Segment) : 堆栈段寄存器
- ES (Extra Segment) : 附加段寄存器

数据寄存器可当做两个独立的8bit寄存器使用, 分别用${X}H/${X}L表示, 其他寄存器不可拆分.

## 32 bit
数据寄存器
- EAX (Accumulator) : 累加寄存器
- EBX (Base) : 基地址寄存器
- ECX (Count) : 计数器寄存器
- EDX (Data) : 数据寄存器

指针寄存器
- ESP(Stack Pointer) : 栈指针寄存器
- EBP(Base Pointer) : 基指针寄存器

变址寄存器
- ESI : (Source Index) : 源变地寄存器
- EDI : (Destination Index) : 目的变址寄存器

控制寄存器
- EIP (Instruction Pointer) : 指令指针寄存器
- EFLAG : 标志寄存器

段寄存器
- CS (Code Segment) : 代码段寄存器
- DS (Data Segment) : 数据段寄存器
- SS (Stack Segment) : 堆栈段寄存器
- ES (Extra Segment) : 附加段寄存器
- FS : 附加段寄存器
- GS : 附加段寄存器

数据寄存器可当做两个独立的8bit寄存器或一个16bit寄存器使用, 分别用${X}H/${X}L和${X}X表示.

在32bit cpu中, 32bit数据寄存器不仅可以传送数据, 暂存数据保存算术逻辑运算结果, 还可以作为指针寄存器, 因此这些32bit寄存器更具通用性.

经常使用的是CS和SS. 比如指令都存储在代码段, 在定位一个指令时, 使用CS:EIP来指明它的内存地址, 此时EIP表示CS段的段内相对偏移地址.

小程序只有一个代码段, 所有的EIP前的CS值都相同, 但也有特例. 比如一般程序都会使用到多个标准库, 此时程序就会有多个代码段, CS:EIP总结:
1. 顺序执行, 总是执行地址连续的下一条指令.
1. 跳转/分支: cs:eip的值会根据程序需要被修改
1. call: 将当前cs:eip值(即下一条指令地址)压入栈顶, 新cs:eip值指向被调用函数的入口地址
1. ret: 从栈顶弹出原有的cs:eip值, 放入cs:eip中

对32bit x86 cpu通过堆栈来传递参数的方法是从右往左依次压栈, 并用eax保存返回值.

## 64bit
数据寄存器
- RAX (Accumulator) : 累加寄存器
- RBX (Base) : 基地址寄存器
- RCX (Count) : 计数器寄存器
- RDX (Data) : 数据寄存器
- R8-R15

指针寄存器
- RSP(Stack Pointer) : 栈指针寄存器,  存放指向当前栈帧的栈顶的指针
- RBP(Base Pointer) : 基指针寄存器, 用于访问函数的参数和局部变量的固定参照物, 是当前栈帧的`常量`.

变址寄存器
- RSI : (Source Index) : 源变地寄存器
- RDI : (Destination Index) : 目的变址寄存器

控制寄存器
- RIP (Instruction Pointer) : 指令指针寄存器, 保存下一条指令的地址
- RFLAG : 标志寄存器

段寄存器
- CS (Code Segment) : 代码段寄存器
- DS (Data Segment) : 数据段寄存器
- SS (Stack Segment) : 堆栈段寄存器
- ES (Extra Segment) : 附加段寄存器
- FS : 附加段寄存器
- GS : 附加段寄存器

## 寻址
参考:
- [16 bit/单片机寻址共七种](https://cloud.tencent.com/developer/article/1592148)
- [32 bit寻址](https://cloud.tencent.com/developer/article/1592148)
- [x86/x64体系探索及编程#2.4]

> 在用16位寄存器来访问存储单元时，只能使用基地址寄存器(BX和BP)和变址寄存器(SI和DI)来作为地址偏移量的一部分，但在用32/64位寄存器寻址时，不存在上述限制，所有32位寄存器(EAX、EBX、ECX、EDX、ESI、EDI、EBP和ESP)都可以是地址偏移量的一个组成部分.

> 基址寄存器是EBP或ESP时，默认的段寄存器是SS，否则，默认的段寄存器是DS

> i/o端口寻址 : x86/x64实现了独立的64K I/O地址空间(0x0000~0xFFFF), in和out指令可访问这个i/o地址, 是cpu与外部接口进行通信的工具, 许多设备的底层驱动依赖in/out指令. 同时设备还可使用memory i/o(i/o内存映射)方式映射到物理地址空间, 比如vga设备的buffer就被这样处理了.

> 从CPU的角度来看，访问设备只有内存映射I/O(Memory-mapped I/O)和端口I/O(Port I/O)两种，要么像内存一样访问，要么用一种专用的指令访问.


![32位地址偏移量进行寻址的有效地址计算公式](/misc/img/wwo4wjpgd1.gif)

速度(快-> 慢): 立即寻址 -> 寄存器寻址 -> 直接寻址 -> 间接寻址 -> 索引寻址

> x64新增rip寄存器其保存当前指令的下一条指令的地址(rip+disp32, 范围是rip±2G)，而x86的数据寻址只有绝对寻址.
> rip寻址易于构建pic(position-independent code, 不依赖于位置的代码)代码.

### 实模式与保护模式的来历
ref:
- [进入32位保护模式](http://note.isliberty.me/article/81)

最早期的8086 CPU只有一种工作方式, 那就是实模式, 而且数据总线为16位, 地址总线为20位, 实模式下所有寄存器都是16位. 而从80286开始就有了部分保护模式, 从80386开始完全实现了保护模式与实模式的转化, 此时CPU数据总线和地址总线均为32位, 而且寄存器都是32位. 但80386以及现在的奔腾，酷睿等等CPU为了向前兼容都保留了实模式, 现代操作系统在刚加电时首先运行在实模式下, 然后再切换到保护模式下运行.

8086: 最大寻址能力: 2^20=1M; 段最大大小: 2^16=64k, 但不一定就是64KB.

### 段描述表寄存器
分:
- 全局性段描述表寄存器GDTR（Global Descriptor Table Register ）

    gdtr是一个48位的寄存器，高32位用来存放段描述符地址，低16位用来存放段描述符的界限.
- 局部性段描述表寄存器LDTR（Local Descriptor Table Register ）

保护模式下访问内存地址还是需要通过段寄存器来进行, 不过此时段寄存器的内容由以前的段地址变成了段选择子. 所谓的段选择子最主要的就是要访问的段在GDTR表中的序号.

段选择子(2B)的字段含义:
- 15-3 : 2^13=8192, 又因为TI, 因此存在`8192*2=16384`个段描述符. 可从全局或局部描述符表项中选择一个描述符

    GDTR是存放全局段描述符的表, 全局段描述符包括但不限于：操作系统内核的代码段和数据段的描述符、局部描述符表的段描述符（LDT也是段，只不过是系统段）、任务状态段TSS的段描述符、一些门的描述符.
    LDTT是存放局部段描述符的表, 局部段描述符就是任务私有部分的段的描述符.

    GDT和LDT也是内存段, 因为它们用于系统管理, 故称为系统的段或者系统段.

    GDT是唯一的，整个系统中只有一个，所以只需要用GDTR寄存器存放其线性基地址和段界限即可；但LDT不同，每个任务一个，所以，为了追踪它们，处理器要求在GDT中安装每个LDT的描述符。当要使用这些LDT时，可以用它们的选择子来访问GDT，将LDT描述符加载到LDTR寄存器。
- 2: TI, 选择使用哪一种段描述表寄存器, 0用GDTR, 1用LDTR
- 1-0 : RPL表示请求特权级, 00最高, 11最低

    80386中**四个特权级别，0级最高，3级最低**. 每一条指令都有其适用级别, **通常用户程序都是3级，一般程序的运行级别由代码段的局部描述项DPL字段决定，这是由0级状态下的的内核设定的**. 当**改变一个寄存器内容时，CPU对权限进行检查，确保该程序的执行权限和段寄存器所制定要求的权限RPL所要访问的内存的权限DPL**

段内偏移地址为32位值, 所以一个段最大可达4GB, 这样`16384*4GB＝64TB`, 这就是所谓的64TB最大寻址能力，也即逻辑地址. 但32位的地址总线能寻址的线性地址空间和物理地址空间都是2^32=4GB, 因此最多只能使用4G, 实际略小于4G, 因为有一些物理地址有特殊用途, 比如用于内存映射.

段描述符表项(8B)的字段含义:
```c
// 内存布局:
//                high 32 bits:
//                31             24 23 22 21 20 19     16 15  14  13 12        7             0
//                +----------------+--+--+--+--+--------+--+----+--+--------+----------------+
//                | base 24~31     |G |DB|L |A |seg16~19|P |DPL |S |  TYPE  |   base 16~23   | 
//                +----------------+--+--+--+--+--------+--+----+--+--------+----------------+
//
//                low 32 bits:
//                31                                 16 15                                   0
//                +------------------------------------+-------------------------------------+
//                |            base 0~15               |            seg 0~15                 |
//                +------------------------------------+-------------------------------------+
// 等价的伪代码:
typedef struct
{
 unsigned  int  base24_31:8;        /*基地址的高8位 */
 unsigned  int  g:1;                /* granularity，表段的长度单位，0表示字节，1表示 4KB */
 unsigned  int  d_b:1;              /* default operation size ，存取方式，0表示16位，1表示32位 */
 unsigned  int  unused:1;           /*固定设置成0 */
 unsigned  int  avl:1;              /* avalaible，可供系统软件使用*/
 unsigned  int  seg_limit_16_19:4;  /* 段长度的高4位 */
 unsigned  int  p:1;                /* segment present，为0时表示该段不在内存中*/
 unsigned  int  dpl:2;              /* Descriptor privilege level，访问本段所需的权限 */
 unsigned  int  s:1;                /* 描述项类型，0表示系统，1表示代码或数据 */
 unsigned  int  type:4;             /* 段的类型，与S标志位一起使用*/ [当S=0时，TYPE域规定](https://xem.github.io/minix86/manual/intel-x86-and-64-manual-vol3/o_fe12b1e2a880e0ce-102.html), [当S=1时，TYPE域规定](https://xem.github.io/minix86/manual/intel-x86-and-64-manual-vol3/o_fe12b1e2a880e0ce-100.html)
 unsigned  int  base_0_23:24;       /* 基地址的低24位 */
 unsigned  int  seg_limit_0_15:16;  /* 段长度的低16位 */
};
```

### 64-bit寻址
> 64-bit模式下, 除FS,GS段可以使用非0值的base外, 其余的ES, CS, DS, SS段的base均强制为0.

Intel:
- 立即寻址 : `mov rax, 1` => rax = 1
- 寄存器寻址 : `mov rax, rbx`, 寄存器间
- 直接寻址 : `mov rax, [1]`, 将地址1开始的内容(8B)放入rax => rax=*(int64*)0x1
- 间接寻址 : `mov rbx, [rax]`, 从寄存器指定的地址加载值 =>  rax=*(int64*)rax

    - RIP相对寻址 : `mov rax, [rip]`
- 变址寻址 : `mov rdx, [rbx+4]` => rdx = *(int64*)(rbx+4)
- 索引寻址 : `mov rax, QWORD PTR [rcx*1 + BASE + string_start]`, addr = `[INDEX * WIDTH + BASE + OFFSET]`

AT&T:
- 立即寻址 : `movq $1, %rax`, 用`$`表示立即寻址, 没有`$`时表示直接寻址
- 寄存器寻址 : `movq %rbx, %rax`
- 直接寻址 : `movq 1, %rax`, 将地址1开始的内容(8B)放入rax.
- 间接寻址 : `movq (%rax), %rbx`, 从寄存器指定的地址加载值

    - RIP相对寻址 : `mov 0x0(%rip),%rax`
- 变址寻址 : `movq 4(%rbx), %rdx` => rdx = *(int64*)(rbx+4)
- 索引寻址 : `movq string_start(, %ecx, 1), %eax` => `offset(base, index, width)`, addr = `base + %索引寄存器*比例因子 + offset`

pushq %rax= `subq $8, %rsp` + `movq %rax, (%rsp)`, 使用subq是因为栈是向下增长的.
popq %rax= `movq (%rsp), %rax` + `addq $8, %rsp`
call 0x12345 = `pushq %rip` + `movq 0x123456, %rip`, 实际call由硬件一次性完成(处于安全考虑rip无法直接使用和修改), 仅是逻辑步骤上可拆分成这两个步骤.
ret = popq %rip, 同上由硬件一次性完成, 仅是逻辑步骤相同.

enter和leave可以理解为宏指令, leave用于撤销函数堆栈; enter用于建立一个空函数堆栈:
- leave = `movq %rbp, %rsp` + `popq %rbp`
- enter = `pushq %rbp` + `movq %rsp, %rbp` 

> rip不能被程序直接修改, 只能通过专用指令(call, ret, jmp)间接修改.

> x64使用48bit的virtual address, 高16是符号扩展, 它们要么全是1, 或全是0, 这种形式的地址被称为canonical地址, 符号扩展的其他形式都是不合法的. linux上刚好内核空间和用户空间各一半, 均是126T.

### 16 bit/单片机寻址
- 立即寻址方式
- 寄存器寻址方式

    指令中可以引用的寄存器及其符号名称如下：
    - 8位寄存器有：AH、AL、BH、BL、CH、CL、DH和DL等
    - 16位寄存器有：AX、BX、CX、DX、SI、DI、SP、BP和段寄存器等
    - 32位寄存器有：EAX、EBX、ECX、EDX、ESI、EDI、ESP和EBP等
- 直接寻址方式
- 寄存器间接寻址

    ![寄存器间接寻址](/misc/img/ckhut33a5v.gif)

    在不使用段超越前缀的情况下，有下列规定：
    1. 若有效地址用SI、DI和BX等之一来指定，则其缺省的段寄存器为DS
　　1. 若有效地址用BP来指定，则其缺省的段寄存器为SS(即：堆栈段)

    `MOV BX,[DI]`，在执行时，(DS)=1000H，(DI)=2345H, 推导过程:
    1. addr=(DS)*16+DI=1000H*16+2345H=12345H
    因此`MOV BX,[DI]`=`MOV BX, [12345H]`
- 寄存器相对寻址

    ![寄存器相对寻址](/misc/img/a3aqwpergc.gif)

    在不使用段超越前缀的情况下，有下列规定：
    1. 若有效地址用SI、DI和BX等之一来指定，则其缺省的段寄存器为DS；
    1. 若有效地址用BP来指定，则其缺省的段寄存器为SS。

　　指令中给出的8位/16位偏移量用补码表示. 在计算有效地址时，如果偏移量是8位，则进行符号扩展成16位. 当所得的有效地址超过0FFFFH，则取其64K的模.

    `MOV BX, [SI+100H]`，在执行它时，(DS)=1000H，(SI)=2345H, 推导过程:
    1. EA(源操作数的有效地址)=(SI)+100H=2345H+100H=2445H
    1. add=(DS)*16+EA=1000H*16+2445H=12445H
    因此`MOV BX, [SI+100H]`=`mov bx, [12445H]`
- 基址加变址寻址/相对基址加变址寻址

    ![基址加变址寻址](/misc/img/wbe73enxd1.gif)
    ![相对基址加变址寻址](/misc/img/506vlj2mx0.gif)

    > 区别: 相对基址加变址寻址有偏移量, 指令中给出的8位/16位偏移量用补码表示. 在计算有效地址时，如果偏移量是8位，则进行符号扩展成16位. 当所得的有效地址超过0FFFFH，则取其64K的模.

    在不使用段超越前缀的情况下，规定：如果有效地址中含有BP，则其缺省的段寄存器为SS；否则，其缺省的段寄存器为DS.
    
    `MOV AX, [BX+SI+200H]`，在执行时，(DS)=10000H，(BX)=2100H，(SI)=0010H, 推导过程:
    1. EA(源操作数的有效地址)=(BX)+(SI)+200H=2100H+0010H+200H=2310H
    1. addr=(DS)*16+EA=10000H*16+2310H=12310H // BX=>选择DS
    因此`MOV AX, [BX+SI+200H]`=`MOV AX, [12310H]`

### 内存地址形式
- logical addr(逻辑地址): 无论在实模式或是保护模式下, 段内偏移地址又称为有效地址, 也称为逻辑地址. 这是程序员可
见的地址, 最终会被cpu转为linear address.

    逻辑地址分为两个部分: segment, offset. offset就是段内的effective address(有效地址).
    segment是显示或隐式的. 逻辑地址在real mode下会经常使用到, 保护模式下在使用far pointer进行控制权的切换时也会用到.
    
    最终的地址是由段基址和段内偏移地址组合而成的. 由于段基址已经有默认的值, 要么是在实模式下的默认段寄存器中, 要么是在保护模式下的默认段选择子寄存器指向的段描述符中, 所以只要给出段内偏移地址就行了. 即实模式下由`段基地址+段内偏移`组成;保护模式下由`段选择符+段内偏移`组成.
- linear address(线性地址), 是cpu通过分段（Segment）机制后形成的地址空间. 线性地址在实模式和非分页的保护模式下就是物理地址.

    real mode : linner addr = segment <<4 + offset = segment_base + offset.
    64-bit : linear addr = offset // base强制为0.

    在保护模式下, `段基址＋段内偏移地址`称为线性地址, 不过, 此时的段基址已经不再是真正的地址了, 而是一个称为选择子的东西.  它本质是个索引, 类似于数组下标, 通过这个索引便能在 GDT 中找到相应的段描述符, 在该描述符中记录了该段的起始、大小等信息, 这样便得到了段基址. 若没有开启地址分页功能, 此线性地址就被当作物理地址来用, 可直接访问内存;  若开启了分页功能, 此线性地址又多了一个名字, 就是虚拟地址. 虚拟地址要经过 CPU MCU转换成具体的物理地址, 这样 CPU才能将其送上地址总线去访问内存.
- physical address(物理地址)

    物理地址就是物理内存真正的地址. 不管在什么模式下, 不管什么虚拟地址、线性地址, CPU 最终都要以物理地址去访问内存.

    linear address在分页机制下, 需经处理器分页映射转换为最终的物理地址.

    物理地址分:
    - 内存地址空间
    - i/o地址空间

    物理内存地址空间将容纳所有物理设备, 包括vga, rom, dram, pci, apic等, 这些设备以memory i/o的内存映射形式存在.



> 页机制和段机制有一定程度的功能重复，但Intel公司为了向下兼容等目标，使得这两者一直共存.

三种地址的关系如下：
- 分段机制启动、分页机制未启动：逻辑地址--->段机制处理--->线性地址=物理地址
- 分段机制和分页机制都启动：逻辑地址--->段机制处理--->线性地址--->页机制处理--->物理地址

## 中断
中断会中断正常的流程, 把控制权从应用程序转给kernel的中断处理程序.

## 函数调用约定
在 gcc c语言中约定, 栈是实现函数的局部变量, 参数和返回地址的关键因素.

> C语言的调用约定也被称为ABI, 即应用程序二进制接口.

函数调用过程:
1. 在执行函数前, 会将函数参数按逆序压入栈中, 然后执行call 指令. call指令会做两件事: 1. 将下一条指令的地址即返回地址压入栈中, 然后将rip指向被调函数.

1. 被调函数通过`push rbp`保存当前的基址寄存器. 再用`mov rbp, rsp`, 即可用相对于rbp的固定索引来访问函数参数. 对当前栈帧而言rbp是常量. 之后开始执行被调函数的代码.

> 栈帧包含一个函数中使用过的所有栈变量, 包括参数, 局部变量和返回地址.

> 栈变量称为局部变量的原因: 当函数返回后, 栈帧已不存在.

1. 当被调函数执行完毕后, 会做三件事:
	1. 将函数返回值放入rax
	1. 将栈恢复到调用函数时的状态(移除当前栈帧, `mov rsp, rbp`(重置rsp(即丢弃当前栈帧), 经`pop rbp`和ret后变成上一个栈帧的栈顶) + `pop rbp`将rbp重置为上一个栈帧的rbp)
	1. 将控制权还给调用函数, 这通过ret指令实现: 将栈顶值弹出, 并将rip置为该值

> 调用函数时需要假设, 当前的所有寄存器的内容都会被覆盖(除了rbp, 因为其由被调函数在函数开始时保存), 因此需要注意现场保护.

### 具体函数调用约定
- stdcall

    1. 在进行函数调用的时候，函数的参数是从右向左依次放入栈中的

    如`int function（int first，int second）`, 这个函数的参数入栈顺序，首先是参数second，然后是参数first.

    2. 函数的栈平衡操作是由被调用函数执行的，使用的指令是 retn X，它可在函数返回时从栈中弹出X个字节. 例如上面的function函数，当我们把function的函数参数压入栈中后，当function函数执行完毕后，由function函数负责将传递给它的参数first和second从栈中弹出来.

    3. 编译时, 编译器会在函数名的前面用下划线修饰，在函数名的后面由`@+入栈字节数`来修饰. 如上面的function函数，会被编译器转换为_function@8.

- cdecl

    1. 在进行函数调用的时候，和stdcall一样，函数的参数是从右向左依次放入栈中的.

    2. 函数的栈平衡操作是由调用函数执行的，这点是与stdcall不同之处. stdcall使用retn X平衡栈，cdecl则使用leave、pop、向上移动栈指针等方法来平衡栈.

    3. 每个函数调用者都包含有清空栈的代码，所以编译产生的可执行文件会比调用stdcall约定产生的文件大.

    **cdecl是GCC的默认调用约定. 但是，GCC在x64位系统环境下，却使用寄存器作为函数调用的参数**, 按照从左向右的顺序依次将前六个整型参数放在寄存器RDI, RSI, RDX, RCX, R8和R9上，同时XMM0到XMM7用来保存浮点变量，而用RAX保存返回值，且由调用者负责平衡栈.

- fastcall

    1. 函数参数尽可能使用通用寄存器rcx, rdx来传递前两个int类型的参数或较小的参数, 其余参数按照从右向左的顺序入栈.

    2. 函数的栈平衡操作是由被调用函数负责.

还有很多调用规则，如：thiscall、naked call、pascal等

![调用栈](/misc/img/compile/20200112171557752.png)
参考: [汇编指令push,mov,call,pop,leave,ret建立与释放栈的过程](https://blog.csdn.net/liu_if_else/article/details/72794199)

#### [GCC的x86平台cdecl规范详解](http://blog.bytemem.com/post/linux-kernel-function-call-convention)
cdecl属于Caller clean-up类规范. 在调用子程序（callee）时，x87浮点寄存器ST0-ST7必须是空的，在退出子程序时，ST1-ST7必须是空的，如果没有浮点返回值，ST0也必须是空的. 从gcc 4.5开始，函数栈的地址必是16-byte对齐的，在此之前只要求4-byte对齐.

寄存器现场的保存：

    x86-32: 寄存器EAX, ECX, EDX由调用者自己保存（caller-saved），子程序可以改变这些寄存器的值而不用恢复，其他寄存器是callee-saved.
    x86-64: 寄存器RBX, RBP, 和 R12–R15 由子程序保存和恢复，其他寄存器由调用者自己保存.

函数返回值：

    x86-32: 如果是整数存放在EAX寄存器, 如果是浮点数存放在x87协处理器的ST0寄存器.
    x86-64: 64位返回值存放在RAX寄存器，128为返回值保存在RAX和RDX寄存器. 浮点返回值保存在XMM0和XMM1寄存器.

其函数参数传递方式在x86-32和x86-64上是不同的：

    x86-32: 所有函数参数都通过函数栈传递，并且参数入栈顺序是Right-to-Left，即最后一个参数先入栈，第一个参数最后入栈.
    x86-64: 由于AMD64架构提供了更多的可用寄存器，编译器充分利用寄存器来传递参数. 函数的前六个整数参数依次用寄存器RDI, RSI, RDX, RCX, R8, R9 (R10 is used as a static chain pointer in case of nested functions)传递，比如只有一个参数时，用RDI传递参数；如果参数是浮点数，则依次用寄存器XMM0, XMM1, XMM2, XMM3, XMM4, XMM5, XMM6 and XMM7传递. 额外的参数仍然通过函数栈传递. **对于可变参数的函数，实际浮点类型的参数的个数需保存在RAX寄存器**.

### 参数传递方式

函数参数的传递方式无外乎两种: 一种是通过寄存器传递，另一种是通过内存传递. 这两种传递方式在通常情况下都能满足开发需求, 因此它并不会被特别关注. 但是, 在写操作系统时有许多要求苛刻的场景，这使得我们不得不掌握这两种参数传递方式.

- 寄存器传递

    寄存器传递就是通过寄存器来传递函数的参数, 优点是执行速度快，编译后生成的代码量少. 但只有少部分调用约定默认是通过寄存器传递参数，绝大部分编译器是需要特殊指定使用寄存器传递参数的.

    在X86体系结构的linux kernel中，syscall一般会使用寄存器传递. 因为应用程序和kernel的空间是隔离的. 如果想从应用层把参数传递到内核层的话，最方便快捷的方法是通过寄存器传递参数，否则只能大费周章才能把数据传递过去.

- 内存传递

    内存传递参数很好理解，在大多数情况下参数传递都是通过压栈的形式实现的, 比如go的函数调用.

    在X86体系结构下的Linux内核中，中断或异常的处理会使用内存传递参数. 因为，在中断产生后，到中断处理的上半部，中间的过渡代码是用汇编实现的. 汇编跳转到C语言的过程中，C语言函数是使用栈来传递参数的，为了无缝衔接，汇编就需要把参数压入栈中，然后再跳转到C语言实现的中断处理函数中执行.

    > linux 2.6开始逐渐改用寄存器传递.

以上这些都是在X86体系结构下的参数传递方式. 而**在X64体系结构下，大部分编译器都使用的是寄存器传递参数**, 一般规则为， 当参数少于等于6个时, 参数从左到右放入寄存器: rdi, rsi, rdx, rcx, r8, r9, 当参数为 7 个及以上时， 前 6 个与前面一样， 但后面的依次从 "右向左" 放入栈中, 可以写一些c代码验证.

#### 命令行参数/环境变量传递
压栈(栈中存放的是指向具体字符串的指针), 以64-bit平台举例:
0x0     <------- 表示env结束
envp[M] <------ [rsp + (N+1)*8 +(M+1)*8]
.............
.............
envp[1] <------ [rsp + (N+1)*8 +24]
envp[0] <------ [rsp + (N+1)*8 +16]
0x0     <------ 压入一个全0的值, 用于区分环境变量和命令行参数
argv[N] <------ [rsp + (N+1)*8]
.............
.............
argv[1] <------  [rsp+16]
argv[0] <------  [rsp+8]
argc    <------  [rsp]  // 参数个数

验证:
```bash
gdb -q a.out                                                                                                                                                                                 22:31:13
Reading symbols from a.out...(no debugging symbols found)...done.
(gdb) set environment a=1 # 每次仅运行设置一个
(gdb) set environment b=2
(gdb) set args 5.int.txt 5.out.txt # 运行设置多个
(gdb) b *_start
Breakpoint 1 at 0x4000b0
(gdb) r
Starting program: /home/chen/git/learn_asm/example/a.out 5.int.txt 5.out.txt

Breakpoint 1, 0x00000000004000b0 in _start ()
(gdb) p /x $rsp
$1 = 0x7fffffffdee0
(gdb) x /100xg 0x7fffffffdee0
0x7fffffffdee0: 0x0000000000000003      0x00007fffffffe223 # 3 表示argc
0x7fffffffdef0: 0x00007fffffffe24a      0x00007fffffffe254
0x7fffffffdf00: 0x0000000000000000      0x00007fffffffe25e
0x7fffffffdf10: 0x00007fffffffe286      0x00007fffffffe29c
0x7fffffffdf20: 0x00007fffffffe2b0      0x00007fffffffe312
0x7fffffffdf30: 0x00007fffffffe329      0x00007fffffffe334
0x7fffffffdf40: 0x00007fffffffe36b      0x00007fffffffe37d
0x7fffffffdf50: 0x00007fffffffe3bc      0x00007fffffffe3e0
0x7fffffffdf60: 0x00007fffffffe40c      0x00007fffffffe425
0x7fffffffdf70: 0x00007fffffffe43a      0x00007fffffffe46e
0x7fffffffdf80: 0x00007fffffffe482      0x00007fffffffe492
0x7fffffffdf90: 0x00007fffffffe4be      0x00007fffffffe4cf
0x7fffffffdfa0: 0x00007fffffffe4de      0x00007fffffffe508
0x7fffffffdfb0: 0x00007fffffffe515      0x00007fffffffead1
0x7fffffffdfc0: 0x00007fffffffeae0      0x00007fffffffeb12
0x7fffffffdfd0: 0x00007fffffffeb2a      0x00007fffffffeb4c
0x7fffffffdfe0: 0x00007fffffffeb71      0x00007fffffffed42
0x7fffffffdff0: 0x00007fffffffed6b      0x00007fffffffed90
0x7fffffffe000: 0x00007fffffffeda4      0x00007fffffffedb9
0x7fffffffe010: 0x00007fffffffedcc      0x00007fffffffede0
0x7fffffffe020: 0x00007fffffffede8      0x00007fffffffee11
0x7fffffffe030: 0x00007fffffffee25      0x00007fffffffee39
0x7fffffffe040: 0x00007fffffffee55      0x00007fffffffee5f
0x7fffffffe050: 0x00007fffffffee81      0x00007fffffffee9c
0x7fffffffe060: 0x00007fffffffeecc      0x00007fffffffeeeb
0x7fffffffe070: 0x00007fffffffeefa      0x00007fffffffef2e
0x7fffffffe080: 0x00007fffffffef49      0x00007fffffffef5a
0x7fffffffe090: 0x00007fffffffef94      0x00007fffffffefa9
0x7fffffffe0a0: 0x00007fffffffefb4      0x00007fffffffefc9
0x7fffffffe0b0: 0x00007fffffffefcd      0x0000000000000000 # 再次遇到0x0表示env结束
0x7fffffffe0c0: 0x0000000000000021      0x00007ffff7ffd000
0x7fffffffe0d0: 0x0000000000000010      0x00000000bfebfbff
...
(gdb) x /s 0x00007fffffffe223
0x7fffffffe223: "/home/chen/git/learn_asm/example/a.out" # 程序路径
(gdb) p (char*)0x00007fffffffe223
0x7fffffffe223: "/home/chen/git/learn_asm/example/a.out"
(gdb) x /s 0x00007fffffffe24a
0x7fffffffe24a: "5.int.txt"
(gdb) x /s 0x00007fffffffe254
0x7fffffffe254: "5.out.txt"
(gdb) x /s 0x00007fffffffe25e
0x7fffffffe25e: "CHROME_DESKTOP=code-url-handler.desktop"
(gdb) x /s 0x00007fffffffefc9
0x7fffffffefc9: "a=1"
(gdb) x /s 0x00007fffffffefcd
0x7fffffffefcd: "b=2" # 后添加的env先入栈
```

## gnu c 内嵌汇编
在操作某些特殊的CPU寄存器，操作主板上的某些IO端口或者对性能极为苛刻的场景下, 必须使用c内嵌汇编来满足需求.

```c
#define nop()         __asm__ __volatile__ ("nop    \n\t") // nop(空操作)函数的实现
```

`__asm__`是GNU C定义的关键字asm的宏定义`（#define __asm__ asm）`，用来声明一个内嵌汇编表达式. 所以任何一个内嵌汇编表达式都以它开头, 如果要编写符合ANSI C标准的代码（即与ANSI C兼容），那就建议使用关键字`__asm__`.

`__volatile__`是gcc关键字volatile的宏定义, 用于告诉编译器这段代码不能被优化，需保持原样. 因为如果经过编译器优化，这段汇编可能被修改导致无法达到预期的执行效果. 如果要编写符合ANSI C标准的代码（即与ANSI C兼容），那就建议使用关键字`__volatile`__`.


一般而言，C语言里嵌入汇编代码片段都要比纯汇编语言写的代码复杂得多. 因为需确定寄存器的分配情况、与C代码融合等细节问题. 为了这个目的，必须要对所用的汇编语言做更多的扩充，增加对汇编语言的明确指示.

C语言里的内嵌汇编代码可分为四部分，以“：”号进行分隔，其一般形式为：`指令部分:输出部分:输入部分:损坏部分`. 如果将内嵌汇编表达式比作函数, 指令部分是函数中的代码, 输入部分是用于向函数传入的参数, 输出部分是函数的返回值:

- 指令部分

    汇编语言的语句本身，其格式与在汇编语言程序中使用的格式基本相同，但也有不同之处。指令部分是内嵌汇编的必须项，而其它各部分则视具体情况而定，如果不需要的话是可以忽略的，所以在最简单的情况下就与常规的汇编语句基本相同.

    指令部分的编写规则：
    - 当指令列表里面有多条指令时，可以全部写在一对双引号中，也可将汇编代码放在多对双引号中. 如果是将所有指令写在一对双引号中，那么，相邻两条指令之间必须用分号`;`或换行符（\n）隔开，如果使用换行符（\n），通常\n后面还要跟一个\t.
    - 如果将指令放在多对双引号中，除了最后一对双引号之外，前面的所有双引号里的最后一条指令后面都要有一个分号（;）或（\n）或（\n\t）
    - 在汇编代码引用寄存器时就必须在寄存器名前面再加上一个"%". 

- 输出部分

    紧接在指令部分后面的就是`输出部分`，用来指定当前内嵌汇编语句的输出信息, 格式为：`["输出操作约束"（输出表达式）, ...]`, 输出操作约束与输出表达式需成对出现:

    - 括号内的输出表达式主要负责保存指令部分的执行结果. 通常情况下, 输出表达式是一个变量.
    - 双引号内的部分是输出操作约束, 也可简称`输出约束`. 在输出表达式内需要用（=）或（+）来进行修饰. 等号（=）与加号（+）是有区别的：等号（=）表示当前表达式是一个纯粹的输出操作，而加号（+）则表示当前表达式不仅仅是一个输出操作，还是一个输入操作；不管是等号（=）还是加号（+）, 它们都只能用在输出部分, 不能出现在输入部分, 而且是可读写的.

- 输入部分

    记录指令部分的输入信息, 格式为：`"输入操作约束"（输入表达式）[, ...]`, 输入操作约束与输入表达式也需成对出现. 输入表达式中的操作约束不允许指定等号（=）和加号（+）约束，因此输入部分是只读的.

- 损坏部分

    有的时候，当想通知GNU C 指令部分执行时可能会对某些寄存器或内存进行修改, 且这些修改并未在输出部分或输入部分出现过，希望GNU C在编译时能够将这一点考虑进去. 此时就可以在损坏部分声明这些寄存器或内存, 格式是`"损坏描述"[, ...]`.

    - 寄存器修改通知

    这种情况一般发生在寄存器出现在指令部分中，但又不是输入/输出操作表达式所指定的，更不是编译器为r或g约束选择的寄存器. 如果该寄存器被指令部分所修改, 则需在损坏部分加以描述, 比如：`__asm__("movl %0,%%ecx"::"a"(__tmp):"cx");`, 这段内嵌汇编语句中，%ecx出现在指令列表中，并且被指令修改了，但是却未被任何输入/输出操作表达式所记录, 所以必须要在损坏部分加以描述`cx`, 确保一旦编译器发现后续代码还要使用它时, 会在指令部分执行时做好保存与恢复的工作, 否则可能导致程序异常.

    注意：如果在输入/输出操作表达式中指定寄存器；或为一些输入/输出操作表达式使用q,r,g约束让编译器指派寄存器时, 编译器对这些寄存器的状态是非常清楚的，它知道这些寄存器是被修改的，根本不需要在损坏部分声明它们；但除此之外，编译器对剩下的寄存器中哪些会被当前内嵌汇编语句所修改却一无所知, 此时需要记录.

    - 内存修改通知

    除了寄存器的内容会被修改之外，内存的数据同样也会被修改. 如果一个内嵌汇编语句的指令部分修改了内存，或者在此内嵌汇编表达式中出现过，此时内存数据可能发生改变，并且被该内存未用`m`约束的情况下，需要在损坏部分使用字符串`memory`向编译器声明该变化.

    如果损坏部分已使用`memory`对内存加以约束, 那么编译器会保证在指令部分执行后, 会重新向寄存器装载已引用过的内存空间, 而非寄存器中的副本, 以防止内存与副本中的数据不一致.

    - 标志寄存器修改通知

    当一个内嵌汇编中包含影响标志寄存器r|eflags的指令时，必须在损坏部分中使用`cc`来向编译器声明该修改.

### 操作约束
每个输入/输出表达式都必须指定自身的操作约束. 操作约束的类型有：寄存器约束、内存约束、立即数约束. 在输出表达中, 还有限定寄存器操作的修饰符.

- 寄存器约束

    限定了表达式的载体是一个寄存器, 它可以明确指派或`模糊指派再由编译器自行分配`. 此时可使用寄存器全名也可用缩写, 比如:
    ```x86asm
    __asm__ __volatile__("movl %0,%%cr0"::"eax"(cr0)); # 推荐全名
    __asm__ __volatile__("movl %0,%%cr0"::"a"(cr0)); # 如果指定的是寄存器的缩写名称，那边编译器会根据指令部分的代码来决定实际宽度.
    ```

    常用的寄存器约束的缩写:
    - r ：任何输入/输出型的寄存器
    - q ：从rax, rbx, rcx, rdx中指派一个寄存器
    - g ：使用寄存器或内存空间
    - m : 内存空间
    - a : 使用rax/eax/ax/al寄存器
    - b : 使用rbx/ebx/bx/bl寄存器
    - c : 使用rcx/ecx/cx/cl寄存器
    - b : 使用rdx/edx/dx/dl寄存器
    - D : 使用rdi/edi/di寄存器
    - S : 使用rsi/esi/si寄存器
    - f : 使用浮点寄存器
    - i : 使用一个整数类型的立即数
    - F : 使用一个浮点类型的立即数

- 内存约束

    限定了表达式的载体是一个内存空间, 使用约束名`m`表示. 例如：
    ```x86asm
    __asm__ __volatile__ ("sgdt %0":"=m"(__gdt_addr)::);  
    __asm__ __volatile__ ("lgdt %0"::"m"(__gdt_addr));
    ```

- 立即数约束

    只能用于输入部分即立即数在表达式中只能作为右值使用, 限定了表达式的载体是一个数值, 使用约束名`i`表示整数类型, 用`F`表示浮点类型. 如果不想借助于任何寄存器或内存，则可以使用立即数约束. 比如:
    ```x86asm
    __asm__ __volatile__("movl %0,%%ebx"::"i"(50));  
    ```

- 修饰符

    只能用于输出部分, 除了等号（=）和加号（+）外, 还有`&`. `&`只能写在约束部分的第二个字符的位置上即（=）或（+）之后, 它强制编译器为输入操作数与输出操作数分配不同的寄存器, 否则可能会导致输入和输出数据混乱.

    只有在输入约束中使用过模糊约束(使用q,r,g等约束缩写)时, 在输出约束中使用`&`才有意义. 即如果所有输入操作表达式都明确指派了寄存器, 那么输出约束再使用`&`就没意义了.

#### 序号占位符
序号占位符是输入/输出操作约束的数值映射, 每个内嵌汇编表达式中最多只有10个输入/输出操作表达式，这些操作表达式按照他们被列出来的顺序，依次被赋予编号0至9. 如果指令部分想引用序号占位符, 必须使用`%`前缀加以修饰. 指令部分为了区分序号占位符和寄存器, 会特意使用`%%`修饰寄存器. 在编译时, 编译器会将每个序号占位符所代表的表达式替换到相应的寄存器或内存中.

指令部分在引用序号占位符时, 可根据需要指定操作位宽或指定操作的字节位置. 比如在`%`与序号占位符之间插入一个`b`表示操作最低字节，或插入一个`h`表示操作次低字节.

### example
```c
#include <stdio.h>

int main()
{
    /* val1+val2=val3 */
    unsigned int val1 = 1;
    unsigned int val2 = 2;
    unsigned int val3 = 0;
    printf("val1:%d,val2:%d,val3:%d\n", val1, val2, val3);
    asm volatile(
        "movl $0,%%eax\n\t"      /* clear %eax to 0 */
        "addl %1,%%eax\n\t"      /* %eax += val1 */
        "addl %2,%%eax\n\t"      /* %eax += val2 */
        "movl %%eax,%0\n\t"      /* val2 = %eax */ // %数字表示后面输出部分、输入部分、破坏性描述部分的编号. 按照这几部分里变量的出现顺序从0开始编号，具体来说%0表示变量val3，%1表示变量val1，%2表示变量val2
        : "=m" (val3)            /* output =m mean only write output memory variable */ // 输出部分
        : "c" (val1), "d" (val2) /* input c or d mean %ecx/%edx */ // 输入部分, c表示ecx寄存器，d表示edx寄存器
    );
    printf("val1:%d+val2:%d=val3:%d\n", val1, val2, val3);

    return 0;
}
```