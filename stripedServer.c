/* A simple server in the internet domain using TCP
   The port number is passed as an argument */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h> 
#include <sys/socket.h>
#include <netinet/in.h>

int main(int argc, char *argv[])
{
     int sockfd;
     struct sockaddr_in serv_addr;
     sockfd = socket(AF_INET, SOCK_STREAM, 0);
     memset((char *) &serv_addr, 0, sizeof(serv_addr));
     serv_addr.sin_family = AF_INET;
     serv_addr.sin_addr.s_addr = INADDR_ANY;
     serv_addr.sin_port = htons(8080);
     bind(sockfd, (struct sockaddr *) &serv_addr, sizeof(serv_addr));
     listen(sockfd,5);
     return 0; 
}