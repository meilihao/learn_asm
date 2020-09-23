#include <stdio.h>
#include <time.h> 

void printTime(time_t tt) {
	struct tm *t;

	t = localtime(&tt); 
	printf("time:%d:%d:%d:%d:%d:%d:\n",t->tm_year+1900,t->tm_mon+1,t->tm_mday,t->tm_hour, t->tm_min,t->tm_sec);
}

int main() {   
	time_t tt; //int型数值
	printTime(time(NULL));

	tt = 0;

	// Method 1: pass a pointer to a time_t (long long) to return time in
    // sys_time = syscall(201, *long long)
	time_t *input = &tt;
	printf("%p\n", input);
	asm volatile(
		"movq $201,%%rax\n\t"// 使用%rax传递系统调用号201
		"movq %0,%%rdi\n\t"// 系统调用传递第一个参数使用rdi寄存器
		"syscall\n\t" // 触发系统调用
		:"=m"(input)
		);
	printTime(tt);
	
	//  Method 2: pass zero as the time_t parameter. sys_time returns
    //  value in rax .
    //  sys_time = syscall(201, *long long = 0)
	tt = 0;
	asm volatile(
		"movq $201,%%rax\n\t"
		"xorq %%rdi,%%rdi\n\t"
		"syscall\n\t"
		"movq %%rax,%0;\n\t"
		:"=m"(tt)
		);
	printTime(tt);

	tt = 0;
	asm volatile(
		"movq $201,%%rax\n\t"
		"xorq %%rdi,%%rdi\n\t"
		"syscall\n\t"
		:"=a"(tt) // 直接将返回值rax内容赋值给tt, 比上面简洁
		);
	printTime(tt);

	return 1; 
}