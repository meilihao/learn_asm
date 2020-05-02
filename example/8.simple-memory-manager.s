# 用于管理内存使用的程序 -- 按需分配和释放内存
# 原理: 在每个被分配的内存前有关描述该分配的元数据, 即内存分配项header: `Available标志#内存大小#实际内存位置`
# 仅作为lib使用
.intel_syntax noprefix
.section .data
# ######GLOBAL VARIABLES########
# head : heap_begin ~ current_break + Head size + allocated size
# 被管理内存的起始位置
heap_begin: # 64 bit os需8B
.long 0
.long 0
# 被管理内存的最后一个分配项的开始位置
current_break:
.long 0
.long 0

# #####STRUCTURE INFORMATION####
# 内存分配项header的空间大小
.equ HEADER_SIZE, 12
# 头中Available标志的偏移量
.equ HDR_AVAIL_OFFSET, 0
# 头中大小的偏移量
.equ HDR_SIZE_OFFSET, 4
# ##########CONSTANTS###########
.equ UNAVAILABLE, 0 # 标记已分配空间
.equ AVAILABLE, 1 # 标记已回收空间, 可被再次分配
.equ SYS_BRK, 12 # 用来扩大或者缩小进程的数据段边界，brk为新的数据段边界

.section .text

# #########FUNCTIONS############
# #allocate_init##
# PURPOSE: 初始化函数, 用于设置heap_begin和current_break位置
#
.globl allocate_init
.type allocate_init,@function
allocate_init:

# 确认可用内存的起点
mov rax, SYS_BRK
mov rdi, 0 # 0时sys_brk返回break point
syscall

inc rax # 现在才是有效的地址
mov QWORD PTR [current_break], rax
mov QWORD PTR [heap_begin], rax

ret
# ####END OF FUNCTION#######

# #allocate##
# PURPOSE: 获取一段内存, 如果在被我们管理的内存中有符合的空闲块则分配, 否则向kernel申请
# 每次检查从heap_begin开始.
.globl allocate
.type allocate,@function
allocate:
push rbp
mov rbp, rsp

push rdi # 保存所需大小

mov rax, QWORD PTR [heap_begin] # 查找起点
mov rsi, QWORD PTR [current_break] # 查找终点

alloc_loop_begin:
cmp rax, rsi
je move_break # 相同, 即没有可用空间, 否者所需大小, 需分配

cmp QWORD PTR [rax+HDR_SIZE_OFFSET], rdi  # 获取该内存项大小来比较
jl next_location

cmp DWORD PTR [rax+HDR_AVAIL_OFFSET], 1 # 检查是否以分配
je next_location

jmp allocate_here # 可用

next_location:
add rax, HEADER_SIZE
add rax, QWORD PTR [rax+HDR_SIZE_OFFSET]

jmp alloc_loop_begin # 检查下一项

allocate_here:
mov DWORD PTR [rax+HDR_AVAIL_OFFSET], UNAVAILABLE
add rax, HEADER_SIZE # 这才是我们要返回的内存地址
jmp allocate_end

move_break:
push rax # 保存当前分配项的起点位置
add rax, HEADER_SIZE # 我们开始分配的地址
add rax, rdi # brk的结束位置 = rax + 所需大小

# 移动break point
mov rdi, rax
mov rax, SYS_BRK
syscall

cmp rax, 0 # 分配失败
je error

pop rax
mov QWORD PTR [current_break], rax # 更新current_break
mov DWORD PTR [rax+HDR_AVAIL_OFFSET], UNAVAILABLE
mov rdi, QWORD PTR [rsp]
mov QWORD PTR [rax+HDR_SIZE_OFFSET], rdi # mov QWORD PTR [rax+HDR_SIZE_OFFSET], QWORD PTR [rsp], mov禁止无法直接操作内存, 必须通过寄存器中转
add rax, HEADER_SIZE # 这才是我们要返回的内存地址
jmp allocate_end

error:
mov rax, 0
jmp allocate_end

allocate_end:
mov rsp, rbp
push rbp
ret

# #######END OF FUNCTION########
# #deallocate##
# PURPOSE: 将不再使用的内存返还给memory pool, 仅需标记可用即可
#
.globl deallocate
.type deallocate,@function
deallocate:
sub rax, HEADER_SIZE
mov DWORD PTR [rax+HDR_AVAIL_OFFSET], AVAILABLE
ret
