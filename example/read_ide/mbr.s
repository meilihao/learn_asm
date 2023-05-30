; https://gitee.com/jackchengyujia/grapeos-course/blob/master/Lesson20/boot1.asm

LOADER_START_SECTOR equ 0x1
DISK_BUFFER equ 0x7e00 ;临时存放数据用的缓存区, 放到boot程序之后, 0x7e00~0x81ff

SECTION MBR vstart=0x7c00         
   mov ax,cs      
   mov ds,ax ;ds指向与cs相同的段
	 
   mov esi,LOADER_START_SECTOR	 ; 起始扇区lba地址
   mov di,DISK_BUFFER            ; 写入的地址
   ;mov cx,2			             ; 待读入的扇区数
   call rd_disk_m_16

stop:
hlt
jmp stop

rd_disk_m_16:
    ; 1: 检查disk status
    mov dx,0x1f7     ; 0x1f7=primary channel's status
.not_ready1:
    nop              ; 只是为了增加延迟
    in al,dx
    and al,0xc0      ; 0xc0=1100_0000b取bit 6~7
    cmp al,0x40      ; 检查bit 6, 设备是否就绪
    jnz .not_ready1  ;若未准备好，继续等
    ; 2: 设置要读取的扇区数
    mov dx,0x1f2         ; 0x1f2=primary channel's sector count, 见`硬盘控制器主要端口寄存器`
    mov al,2
    out dx,al            ;读取的扇区数
    ; 3: 将LBA地址存入0x1f3 ~ 0x1f6
    mov eax,esi
    ;LBA地址7~0位写入端口0x1f3
    mov dx,0x1f3      ;   0x1f3=primary channel's lba low        
    out dx,al

    ;LBA地址15~8位写入端口0x1f4
    shr eax,8         ;   eax值右移8位
    mov dx,0x1f4      ;   0x1f4=primary channel's lba mid
    out dx,al

    ;LBA地址23~16位写入端口0x1f5
    shr eax,8
    mov dx,0x1f5      ;   0x1f5=primary channel's lba high
    out dx,al

    ; 4: 设置device端口
    shr eax,8
    and al,0x0f      ; lba第24~27位, 其他bit置为0
    or al,0xe0       ; 设置7～4位为1110,表示lba模式, 并使用主盘
    mov dx,0x1f6     ; 0x1f6=primary channel's device
    out dx,al

    ; 5：向0x1f7端口写入读命令，0x20 
    mov dx,0x1f7     ; 0x1f7=primary channel's status
    mov al,0x20      ; 0x20, 读取扇区              
    out dx,al

    ; 6: 检查disk status
.not_ready2:
    nop
    in al,dx         ; 因为status 寄存器依然是 0x1f7 端口, 所以不需要再为dx 重新赋值
    and al,0x88      ;第4位为1表示硬盘控制器已准备好数据传输，第7位为1表示硬盘忙
    cmp al,0x08
    jnz .not_ready2       ;若未准备好，继续等

    ; 7：从0x1f0端口读数据. data 寄存器是 16 位，即每次 in 操作只读入 2 字节
    mov ax, cx       ; ax=读cx个扇区
    mov dx, 256
    mul dx           ; dx=dx*ax即需要操作的次数. 如果操作数是 8 位，被乘数就是 al 寄存器的值，乘积就是 16 位，位于ax寄存器; 如果操作数是 16 位，被乘数就是 ax 寄存器的值，乘积就是 32位，积的高 16 位在 dx 寄存器，积的低 16 位在 ax 寄存器.
    mov cx, ax       ; ax是操作次数. 一个扇区有512字节，每次读入2个字，共需cx*512/2次=cx*256
    mov dx, 0x1f0    ; 0x1f0=primary channel's data
.go_on_read:
    in ax,dx
    mov [di],ax      ; di初始值是DISK_BUFFER
    add di,2
    loop .go_on_read ; loop会cx-=1, 并判断cx是否为0进而继续循环还是往下走
    ret 

times 510-($-$$) db 0
db 0x55,0xaa