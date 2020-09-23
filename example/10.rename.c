#include <stdio.h>

void rename_normal(){
	int ret;
	char *oldname="h.c";
	char *newname="n.c";

	ret=rename(oldname, newname);
	if(ret==0){
		printf("rename successfully\n");
	}else{
		printf("rename faild\n");
	}
}

void rename_asm(){
	int ret;
	char *oldname="n.c";
	char *newname="h1.c";

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
	rename_asm();

	return 0;
}