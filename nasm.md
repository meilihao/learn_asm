# nasm
## 指令
- org : 根据org指令中指定的偏移, 计算段内数据的各种偏移

	[org指令并不改变cs的值, 而是在链接时期的重定位阶段起作用, 改变符号引用的位置](https://www.cnblogs.com/yangwindsor/p/3336681.html)
- section : 节, 组织汇编代码的方式. 编译器输出代码用segment组织.

	如果没有定义section, nasm默认全部代码在一个section, 起始地址为0
- times 重复指令

	`times 510-($-$$) db 0`: 为mbr填充0
- vstart: 修饰section, 影响编译器安装地址的行为
	
	`section.<name>.start`表示本section在文件中的真实偏移量(多文件同名section如何计算start???)
- `$` : 当前行的地址

	本section存在vstart=xxx, 那么`$`就是以xxx为起始地址的地址偏移量
- `$$` : 本section的起始地址

	本section存在vstart=xxx, 那么`$$`=本section的起始地址xxx