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

	mov rbp, rsp
	sub rsp, 0x14

	; creats a socket,  Args:  family in rdi, type in  rsi, protocoll in  rdx
	xor rdi, rdi
	xor rsi, rsi
	xor rax, rax
	mov rdi , 0x2
	mov rsi, 0x1
	xor rdx, rdx
	mov rax, 41
	syscall
	push rax
	push rax
	
	mov edi, eax
	mov eax, 0x1
	mov [rbp-0x10], eax
	lea r10, [rbp-0x10]
	mov r8d, 0x04
	mov edx, 0x02
	mov esi, 0x01
	mov eax, 54 
	syscall


	xor rdi, rdi
	pop rdi
	mov rsi, sockaddr_in
	xor rdx, rdx
	xor rax, rax
	mov rdx, 0x10
	mov rax, 49
	syscall
	xor rax, rax
	xor rsi, rsi
	mov rax, 50
	mov rsi, 0x5
	syscall
	mov rsi, rbp
	mov rdx, sockaddr_inLen
	mov rax, 43
	syscall
	mov rdi, rax
	mov rax, 1
	mov rsi, hello
	mov rdx, helloLen
	syscall
	mov eax, 3
	syscall
	mov eax, 3
	pop rdi
	syscall
	xor rax, rax
	xor rdi, rdi
	mov rax, 60
	mov rdi, 0x0
	syscall
