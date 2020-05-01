# $ as write-records.s -o write-records.o                                                                                                                   22:40:11
# $ as write-record.s -o write-record.o                                                                                                                     22:40:22
# $ ld write-records.o write-record.o -o a.out
.intel_syntax noprefix
.include "linux.s"
.include "record-def.s"

.section .data

# 我们想写入的常量数据
# 每个数据项以空字节 (0) 填充到适当的长度

# .rept用于填充每一项. .rept告诉汇编程序将
# .rept和.endr之间的段重复指定次数
# 在这个程序中, 此指令用于将多余的空白字符
# 增加到每个字符末尾以将之填满
record1:
.ascii "Fredrick\0"			# 姓
.rept 31 # 填充31个字节, 到40字节
.byte 0
.endr

.ascii "Bartlett\0"			# 名
.rept 31 # 填充到40字节
.byte 0
.endr

.ascii "4242 S Prairie\nTulsa, OK 55555\0"		# 地址
.rept 209 # 填充到240字节
.byte 0
.endr

.long 45					# 年龄

record2:
.ascii "Marilyn\0"			# 第一个名字
.rept 32 # 填充到40字节
.byte 0
.endr

.ascii "Taylor\0"			# 最后一个名字
.rept 33 # Padding to 40 bytes
.byte 0
.endr

.ascii "2224 S Johannan St\nChicago, IL 12345\0"
.rept 203 # 填充到240字节
.byte 0
.endr

.long 29

record3:
.ascii "Derrick\0"
.rept 32 # 填充到40字节
.byte 0
.endr

.ascii "McIntire\0"
.rept 31 # 填充到40字节
.byte 0
.endr

.ascii "500 W Oakland\nSan Diego, CA 54321\0"
.rept 206 # 填充到240字节
.byte 206
.endr

.long 36

# 这是我们要写入文件的文件名:
file_name:
.ascii "test.dat\0"

.globl _start
_start:
# 复制栈指针到%ebp
mov rbp, rsp

# 打开文件
mov rax, SYS_OPEN
lea rdi, file_name # 获取输入文件名
mov rsi, 0101 # 本指令表明如文件不存在则创建并打开文件用于写入
mov rdx, 0666 # 权限
syscall

# 存储文件描述符
push rax

# 写第一条记录
mov rdi, QWORD PTR [rsp]
lea rsi, record1
call write_record

# 写第二条记录
mov rdi, QWORD PTR [rsp]
lea rsi, record2
call write_record

# 写第三条记录
mov rdi, QWORD PTR [rsp]
lea rsi, record3
call write_record

# 关闭文件描述符
mov rax, SYS_CLOSE
mov rdi, QWORD PTR [rsp]
syscall

# 退出程序
mov rax, SYS_EXIT
mov rdi, 0
syscall
