# example
0. cpuid.s : 获取cpu vendor信息
1. exit.s : 退出并向linux kernel返回一个状态码
2. find_max.s : 寻找数组中的最大值
3. function_work.s : 函数如何工作
4. function_factorial.s : 递归函数, 求n!
5. rw_file.s : 读取一个文件并将其中的所有大写字母转成小写再输出到其他文件
6. rw_records : 读写简单记录
7. call-libc.s : 链接libc
8. simple-memory-manager.s : 一个简单的内存管理器

> 文件后缀是att的是AT&T语法, 没有则默认是Intel语法, 32表示是针对x83 32位系统的汇编. example初始时使用了AT&T语法, 以后仅提供Intel语法, 且仅针对x86_64. att语法版本可用`objdump -d program_name`获取.
> cpuid2_*.s : 说明32/64 bit ABI差异.