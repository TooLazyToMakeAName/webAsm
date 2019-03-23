section .data

; gives the length of a sockaddr_in struct
sockaddr_inLen:  db 0x10 

; The c struct for sockaddr_in with values initalised
; AF_IP thing
; port = 32600
; The sinaddrr is a struckt with only member being s_addr with adress 0.0.0.0
; sin_zero is simply 8 bytes of 0x00

sockaddr_in: 
	sin_family: db 0x02, 0x00 ; short
	sin_port:   db 0x7f, 0x58 ; unsigned short
	sin_addr:   		  ; struct in_addr 
		s_addr: db 0x00, 0x00, 0x00, 0x00
	sin_zero: db 0x00, 0x00, 0x00, 0x00, 0x00 , 0x00, 0x00, 0x00 ; char[8]

; hello test string and length. 

hello: db "hello woåld",10
helloLen: equ $-hello


global _start
section .text
_start:
	
	;Setting up stack and stack allocations.
	mov rbp, rsp
	sub rsp, 0x14

	; sys_socket
	; creats a socket,  Args:  family AF_INE in rdi, type SOCK_STREAM in  rsi, protocoll in  rdx
	xor rdi, rdi
	xor rsi, rsi
	xor rax, rax
	mov rdi , 0x2 ; AF_INET
	mov rsi, 0x1  ; SOCK_STREAM 
	xor rdx, rdx  ; Protocol 
	mov rax, 41
	syscall
	push rax ; saving two copys of the socket file discriptor to the stack
	push rax
	
	; Does a syscall so socket can be used impdelty after close so there is no time out.
	; setsocetopt FileDescriptor, SOL_SOCKET, SO_REUSEADDR OPTION(value to set) SIZEOF(OPTION)
	mov edi, eax ; socket file descriptor
	mov eax, 0x1
	mov [rbp-0x10], eax
	lea r10, [rbp-0x10] ; moves the option value to the stack (true)
	mov r8d, 0x04       ; the size of the optine (int)
	mov edx, 0x02	    ; SO_RESUSEADDR
	mov esi, 0x01       ; SOL_SOCKET
	mov eax, 54	    ; sys_setsocketopt sys table value 
	syscall

	; Binds the socket to a port 
	; sys_bind FileDescriptor, struct sockaddr_in, Size of (sockaddr_in)
	xor rdi, rdi
	pop rdi  ; fileDescriptor
	mov rsi, sockaddr_in ; the struct
	xor rdx, rdx
	xor rax, rax
	mov rdx, 0x10 ; Size of the struct 16 byte
	mov rax, 49   ; sys_bind 
	syscall
	
	; Lisen call makes the socket ready for acepting tcp connections
	; sys_listen FileDescriptorNumber of hanging connections allowed
	; Note! the file descriptor remains unchanged from last call
	xor rax, rax
	xor rsi, rsi
	mov rax, 50 	; sys_listen 
	mov rsi, 0x5    ; Number of connection the socket allows to be qued.
	syscall

	; accept sys call, accepts comunication with a client
	; sys_accept FileDescriptor, struct sockaddr*, size of (struct sockadrrs)
	; Note! the file descriptor remains unchanged from last call
	mov rsi, rbp  ; 16 byte stack variable. Accept leavs a struct on the stack
	mov rdx, sockaddr_inLen  ; Pointer to size of the struct (16 bytes/0x10)
	mov rax, 43    ; sys_accept
	syscall

	; Printes hello messege to the tcp client socket connection
	; sys_write FileDescriptor, bytes to write, sizeOf(bytes), 
	mov rdi, rax  ; the client socket from last sys call is moved for rax to rdi.
	mov rax, 1     ; sys_write
	mov rsi, hello    ; Bytes
	mov rdx, helloLen ; SizeOf(Bytes)
	syscall

        ;closes the client socket
	; sys_close filDescriptor
	; NB ! same file discriptor as above used.
	mov eax, 3 ; sys_write
	syscall
	
	;closes host/bind socket
	; sys_close fileDescriptor
	mov eax, 3 ; sys_write
	pop rdi    ; pops saved fileDescriptor of bind socet of the stack
	syscall

	; terminates the program
	;sys_exit
	xor rax, rax
	xor rdi, rdi
	mov rax, 60 ; sys_exit
	mov rdi, 0x0 ; exit code
	syscall
