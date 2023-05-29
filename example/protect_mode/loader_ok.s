  ; from https://github.com/yifengyou/os-elephant/blob/master/code/c04/a/boot/loader.S
   section loader vstart=LOADER_BASE_ADDR

;打印字符，"2 LOADER"说明loader已经成功加载
; 输出背景色绿色，前景色红色，并且跳动的字符串"1 MBR"
mov byte [gs:160],'2'
mov byte [gs:161],0xA4     ; A表示绿色背景闪烁，4表示前景色为红色

mov byte [gs:162],' '
mov byte [gs:163],0xA4

mov byte [gs:164],'L'
mov byte [gs:165],0xA4   

mov byte [gs:166],'O'
mov byte [gs:167],0xA4

mov byte [gs:168],'A'
mov byte [gs:169],0xA4

mov byte [gs:170],'D'
mov byte [gs:171],0xA4

mov byte [gs:172],'E'
mov byte [gs:173],0xA4

mov byte [gs:174],'R'
mov byte [gs:175],0xA4




;------------------------------------------------------------
;INT 0x10    功能号:0x13    功能描述:打印字符串
;------------------------------------------------------------
;输入:
;AH 子功能号=13H
;BH = 页码
;BL = 属性(若AL=00H或01H)
;CX＝字符串长度
;(DH、DL)＝坐标(行、列)
;ES:BP＝字符串地址 
;AL＝显示输出方式
;   0——字符串中只含显示字符，其显示属性在BL中。显示后，光标位置不变
;   1——字符串中只含显示字符，其显示属性在BL中。显示后，光标位置改变
;   2——字符串中含显示字符和显示属性。显示后，光标位置不变
;   3——字符串中含显示字符和显示属性。显示后，光标位置改变
;无返回值
   mov	 sp, LOADER_BASE_ADDR
   mov	 bp, loadermsg           ; ES:BP = 字符串地址
   mov	 cx, 17			 ; CX = 字符串长度
   mov	 ax, 0x1301		 ; AH = 13,  AL = 01h
   mov	 bx, 0x00A4		 ; 页号为0(BH = 0) 蓝底粉红字(BL = 1fh). 这里换成0xA4, 因为1fh不明显
   mov	 dx, 0x1800		 ; 0x18=24, 即屏幕最后一行
   int	 0x10                    ; 10h 号中断

;----------------------------------------   准备进入保护模式   ------------------------------------------
									;1 打开A20
									;2 加载gdt
									;3 将cr0的pe位置1


   ;-----------------  打开A20  ----------------
   in al,0x92
   or al,0000_0010B    ; 打开 A20Gate 的方式: 将端口 Ox92 的第 1 位置 1 即可
   out 0x92,al

   ;-----------------  加载GDT  ----------------
   cli
   lgdt [gdt_ptr]


   ;-----------------  cr0第0位置1  ----------------
   mov eax, cr0
   or eax, 0x00000001
   mov cr0, eax
   ; 下面开始进入16位保护模式
   jmp  SELECTOR_CODE:p_mode_start	     ; 刷新流水线，避免分支预测的影响,这种cpu优化策略，最怕jmp跳转，
					     ; 这将导致之前做的预测失效，从而起到了刷新的作用。
                    ; jmp后没有指定dword原因, 虽然已进入保护模式但是处于16位保护模式, 因为SELECTOR_CODE还未载入cpu, 当前段描述符缓冲寄存器中的 D 位是0, 因此操作数是 16 位, 故可省略dword

[bits 32]
p_mode_start:
   mov ax, SELECTOR_DATA
   mov ds, ax
   mov es, ax
   mov ss, ax
   mov esp,LOADER_STACK_TOP
   mov ax, SELECTOR_VIDEO
   mov gs, ax

   mov byte [gs:320], 'P' ; 320, 错开其他打印信息

   jmp $

%include "boot.inc"
LOADER_STACK_TOP equ LOADER_BASE_ADDR; LOADER_STACK_TOP用于loader 在保护模式下的栈
;构建gdt及其内部的描述符
   GDT_BASE:   dd    0x00000000 ; GDT_BASEgdt的起始地址, 第 0 个段描述符没用.
          dd    0x00000000

   CODE_DESC:  dd    0x0000FFFF ; 代码段描述符. seg_limit=0xFFFFF*4k=4G
          dd    DESC_CODE_HIGH4

   DATA_STACK_DESC:  dd    0x0000FFFF ; 数据和栈段描述符
           dd    DESC_DATA_HIGH4

   VIDEO_DESC: dd    0x80000007         ; 显存段描述符 limit=(0xbffff-0xb8000)/4k=0x7
          dd    DESC_VIDEO_HIGH4  ; 此时dpl已改为0 
   GDT_SIZE   equ   $ - GDT_BASE ; 应该在times后, 原始loader.S应该是错误的, 因为gdt不连续了
   GDT_LIMIT   equ   GDT_SIZE -  1
   SELECTOR_CODE equ (0x0001<<3) + TI_GDT + RPL0         ; 相当于(CODE_DESC - GDT_BASE)/8 + TI_GDT + RPL0. `<<3`是因为`TI_GDT + RPL0`
   SELECTOR_DATA equ (0x0002<<3) + TI_GDT + RPL0    ; 同上
   SELECTOR_VIDEO equ (0x0003<<3) + TI_GDT + RPL0   ; 同上 

   ;以下是定义gdt的指针，前2字节是gdt界限，后4字节是gdt起始地址

   gdt_ptr  dw  GDT_LIMIT 
       dd  GDT_BASE
   loadermsg db '2 loader in real.'