section .bss                      ; 本节无用, 只为说明readelf输出
    resb 2*32                     ; [RESB](https://www.tortall.net/projects/yasm/manual/html/nasm-pseudop.html), 声明未初始化的存储空间, 这里是64B
section file1data                 ; 自定义的数据段, 未使用"传统"的.data
    strHello db "hello,chen!",0Ah ; 字符串. [db](https://www.tortall.net/projects/yasm/manual/html/nasm-pseudop.html), db即单位为B, 用于声明输出文件中的初始化数据, 这里即"hello,chen!\n". 0AH(ASCII码：换行符)
    STRLEN equ $-strHello         ; 字符串长度. 所在行地址-strHello所在行的开始地址
section file1text                 ; 自定义的代码段, 未使用"传统"的.text
    extern print                  ; 声明该函数在其他文件中
    global _start                 ; 连接器把_start作为程序入口
_start:
    push STRLEN
    push strHello
    call print

    mov ebx,0 ; 返回码
    mov eax,1 ; sys_exit的系统调用号
    int 0x80 ; 触发系统调用