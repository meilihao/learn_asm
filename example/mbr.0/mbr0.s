; https://gitee.com/jackchengyujia/grapeos-course/blob/master/Lesson16/mbr7.asm
org 0x7c00

;初始化段寄存器
mov ax,cs
mov ds,ax     ; ds指向与cs相同的段
mov ax,0xb800 ; 显示器文本模式ram的首地址
mov es,ax     ; 本程序中es专用于指向显存段

mov ah,0x07
mov al,'G'
mov [es:0],ax ; 将'G'显示在屏幕的第1行

;打印字符串："boot start"
mov si,boot_start_string
mov di,80 ;在屏幕第2行显示
call func_print_string

stop:
	hlf       ; 使cpu暂停运行， 直到有中断发生, 以降低cpu使用率
	jmp stop

;打印字符串函数
;输入参数：ds:si，di. si 表示字符串起始地址，以0为结束符; di 表示字符串在屏幕上显示的起始位置（0~1999）
;输出参数：无
func_print_string:
	mov ah,0x07 ;ah 表示字符属性 黑底白字
	shl di,1 ;乘2（屏幕上每个字符对应2个显存字节）, 从第二行开始打印
	.start_char: ;以点开头的标号为局部标号，完整形式是 func_print_string.start_char
	mov al,[si]
	cmp al,0
	jz .end_print ; 等于0跳转
	mov [es:di],ax
	inc si        ; si+=1
	add di,2      ; di+=2
	jmp .start_char
	.end_print:
	ret

boot_start_string:db "boot start",0 ; 0是字符串结尾的'\0'

times 510-($-$$) db 0
db 0x55,0xaa