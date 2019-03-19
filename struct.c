/* A simple server in the internet domain using TCP
   The port number is passed as an argument */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h> 
#include <sys/socket.h>
#include <netinet/in.h>
#include <libnet.h>


int main(int argc, char *argv[])
{
     unsigned short port = htons(32500);
     struct sockaddr_in myaddr;
     myaddr.sin_family = 2;
     myaddr.sin_port = htons(8080);
     inet_aton("127.0.0.1", &myaddr.sin_addr.s_addr);
     memset(&myaddr.sin_zero, 'A', 8);
     memset(&myaddr.sin_zero, 'B', 1);
     return 0; 
}
