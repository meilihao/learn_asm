section .text        ; 本节无用, 只为说明readelf输出
    mov eax,0x10
    jmp $
section file2data    ; 本节无用, 只为说明readelf输出
    file2var db 3    ; 1 byte, named file2var, initialized to 3
section file2text
    global print     ; 导出print
print:
    mov edx,[esp+8]  ; 字符串长度
    mov ecx,[esp+4]  ; 字符串首地址
    mov ebx,1        ; 文件描述符, 这里是stdout
    mov eax,4        ; sys_write
    int 0x80
    ret