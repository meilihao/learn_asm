# nasm
推荐除include外, 其他变量定义放在汇编源码末尾, 与指令分离, 避免将数据解析为指令, 即可增强反汇编代码的可读性.

## 指令
- bits: 指定运行模式

	操作数大小反转前缀 Ox66 和寻址方式反转前缀 Ox67, 用于临时将当前运行模式下的操作数大小和寻址方式转变成另外一种模式下的操作数大小及寻址方式.
- db: define type, 定义1B变量
- dd: define double-word, 定义双字(4B)变量
- dq: define quad-word, 定义8B变量
- dw:  define word, 定义单字(2B)变量
- equ: 等于
- `%include`: 预处理指令, 类似c的include
- org : 根据org指令中指定的偏移, 计算段内数据的各种偏移

	[org指令并不改变cs的值, 而是在链接时期的重定位阶段起作用, 改变符号引用的位置](https://www.cnblogs.com/yangwindsor/p/3336681.html)
- section : 节, 组织汇编代码的方式. 编译器输出代码用segment组织.

	如果没有定义section, nasm默认全部代码在一个section, 起始地址为0
- times 重复指令

	`times 510-($-$$) db 0`: 为mbr填充0
- vstart: 修饰section, 赋予section一个虚拟起始地址, 即它影响编译器生成地址的行为
	
	`section.<name>.start`表示本section在文件中的真实偏移量(有多文件含同名section时推测是合并成一个程序后的该section的真实偏移量, 待验证)
- `$` : 当前行的地址

	本section存在vstart=xxx, 那么`$`就是以xxx为起始地址的地址偏移量
- `$$` : 本section的起始地址

	本section存在vstart=xxx, 那么`$$`=本section的起始地址xxx