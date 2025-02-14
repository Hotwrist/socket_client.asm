/* AUTHOR: John Ebinyi Odey a.k.a Hotwrist, Redhound, Giannis
 * DESCRIPTION: This server accepts a single connection from socket_client.asm
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>

#define PORT 8080
#define BUFFER_SIZE 1024 // to hold the content of the file.txt that would be sent by socket_client.asm

int main() {
    int server_fd, new_socket;
    struct sockaddr_in address;
    int addrlen = sizeof(address);
    char buffer[BUFFER_SIZE] = {0};
    char *message = "Hello from server";

    // Create socket
    if ((server_fd = socket(AF_INET, SOCK_STREAM, 0)) == 0) 
    {
        perror("Socket failed");
        exit(EXIT_FAILURE);
    }

    // Configure server address structure
    address.sin_family = AF_INET;
    address.sin_addr.s_addr = INADDR_ANY;
    address.sin_port = htons(PORT);

    // Bind socket to port
    if (bind(server_fd, (struct sockaddr *)&address, sizeof(address)) < 0) {
        perror("Bind failed");
        exit(EXIT_FAILURE);
    }

    // Lets listen for connections
    if (listen(server_fd, 3) < 0) 
    {
        perror("Listen failed");
        exit(EXIT_FAILURE);
    }
    
    printf("Server listening on port %d...\n", PORT);

    // Accept a client connection
    if ((new_socket = accept(server_fd, (struct sockaddr *)&address, (socklen_t*)&addrlen)) < 0) 
    {
        perror("Accept failed");
        exit(EXIT_FAILURE);
    }
    printf("Client connected!\n");

    // Receive message from client
    read(new_socket, buffer, BUFFER_SIZE);
    printf("Client: %s\n", buffer);

    // Send response to client
    send(new_socket, message, strlen(message), 0);
    printf("Message sent to client\n");

    // Close sockets
    close(new_socket);
    close(server_fd);
    
    return 0;
}

