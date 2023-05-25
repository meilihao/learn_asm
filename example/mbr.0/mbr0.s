org 0x7c00
mov ax,0xb800 ; 显示器文本模式ram的首地址
mov es,ax

mov ah,0x07
mov al,'G'
mov [es:0],ax ; 将'G'显示在屏幕的第二行

stop:
	hlf
	jmp stop

times 510-($-$$) db 0
db 0x55,0xaa