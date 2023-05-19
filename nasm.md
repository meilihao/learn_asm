# nasm
## 指令
- org : 根据org指令中指定的偏移, 计算段内数据的各种偏移

	[org指令并不改变cs的值, 而是在链接时期的重定位阶段起作用, 改变符号引用的位置](https://www.cnblogs.com/yangwindsor/p/3336681.html)