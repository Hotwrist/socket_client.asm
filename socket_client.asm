; AUTHOR: John Ebinyi Odey a.k.a Hotwrist, Redhound, Giannis
; DESCRIPTION: This is an Intel x64 Assembly program that creates a socket connection
;		and connects to a running C server program. After a successful connection,
;		it reads the content of a file in its current directory, file.txt, and then
;		sends the content of this file to the server.

BITS 64

section .data
    ip_address db '127.0.0.1', 0       ; IP address of the server
    port dw 0x901F                     ; Port 8080 in little endian (0x901F)
    filename db 'file.txt', 0          ; File name to send (file.txt)

section .bss
    sockfd resq 1                      ; Socket file descriptor
    addr resb 16                       ; sockaddr_in structure (16 bytes for IPv4)
    buffer resb 1024                   ; Buffer to store file content

section .text
    global _start

_start:
    ; Create socket (AF_INET, SOCK_STREAM, IPPROTO_IP)
    mov rdi, 2                         ; AF_INET
    mov rsi, 1                         ; SOCK_STREAM
    mov rdx, 0                         ; IPPROTO_IP
    mov rax, 41                        ; socket syscall number (sys_socket)
    syscall

    mov [sockfd], rax                  ; Save socket file descriptor

    ; Set up sockaddr_in structure
    ; AF_INET (2), Port (8080), IP (127.0.0.1)
    mov byte [addr], 2                 ; AF_INET (2)
    mov word [addr+2], 0x1F90           ; Port 8080 (little-endian)
    mov dword [addr+4], 0x0100007F      ; IP address 127.0.0.1 in little-endian

    ; Connect to the server
    mov rdi, [sockfd]                  ; Socket file descriptor
    mov rsi, addr                      ; sockaddr_in structure
    mov rdx, 16                         ; Size of sockaddr_in structure
    mov rax, 42                         ; sys_connect syscall number
    syscall

    ; Open the file "file.txt" (O_RDONLY)
    mov rdi, filename                  ; File name
    mov rsi, 0                          ; O_RDONLY flag (0)
    mov rax, 2                          ; sys_open syscall number
    syscall
    mov rbx, rax                       ; Save the file descriptor

    ; Read the content of the file into the buffer
    mov rdi, rbx                       ; File descriptor
    mov rsi, buffer                    ; Buffer to store data
    mov rdx, 1024                       ; Number of bytes to read
    mov rax, 0                          ; sys_read syscall number
    syscall

    ; Check if read was successful (rax will be the number of bytes read)
    test rax, rax                       ; Check if bytes were read
    jz .done                            ; If no bytes were read, skip to done

    ; Send the content of the file to the server
    mov rdi, [sockfd]                  ; Socket file descriptor
    mov rsi, buffer                    ; Buffer with file content
    mov rdx, rax                       ; Number of bytes read
    mov rax, 44                         ; sys_send syscall number
    syscall

.done:
    ; Close the file
    mov rdi, rbx                       ; File descriptor
    mov rax, 3                          ; sys_close syscall number
    syscall

    ; Exit the program
    mov rax, 60                         ; sys_exit syscall number
    xor rdi, rdi                        ; Exit status 0
    syscall

