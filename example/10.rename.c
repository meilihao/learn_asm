#include <stdio.h>
#include <unistd.h>
#include <sys/syscall.h>


void rename_normal(){
	int ret;
	char *oldname="h0.c";
	char *newname="h1.c";

	ret=rename(oldname, newname);
	if(ret==0){
		printf("rename successfully\n");
	}else{
		printf("rename faild\n");
	}
}

void rename_syscall(){
	int ret;
	char oldname[]="h1.c";
	char newname[]="h2.c";

	ret=syscall(SYS_rename,oldname, newname); // syscall from unistd.h; SYS_rename from "sys/syscall.h"
	if(ret==0){
		printf("rename successfully\n");
	}else{
		printf("rename faild\n");
	}
}


void rename_asm(){
	int ret;
	char *oldname="h2.c";
	char *newname="h3.c";

	asm volatile(
		"movq $82,%%rax\n\t"
		"movq %1,%%rdi\n\t"
		"movq %2,%%rsi\n\t"
		"syscall\n\t"
		:"=a"(ret)
		:"b"(oldname),"c"(newname)
		);

	if(ret==0){
		printf("rename successfully\n");
	}else{
		printf("rename faild\n");
	}
}

int main()
{
	rename_normal();
	rename_syscall();
	rename_asm();

	return 0;
}