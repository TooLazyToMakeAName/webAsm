section .data
sockaddr_in:
	sin_family: db 0x02, 0x00 ; short
	sin_port:   db 0x1f, 0x90 ; unsigned short
	sin_addr:   		  ; struct in_addr 
		s_addr: db 0x7f, 0x00, 0x00, 0x01
	sin_zero: db 0x00, 0x00, 0x00, 0x00, 0x00 , 0x00, 0x00, 0x00 ; char[8]

global _start
section .text
_start:
	xor rdi, rdi
	xor rsi, rsi
	xor rax, rax
	mov rdi , 0x2
	mov rsi, 0x1
	xor rdx, rdx
	mov rax, 41
	syscall
	push rax
	xor rdi, rdi
	mov rdi, rax
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
	pop rdi
	syscall
	hang:
		nop
		nop
		jmp hang

;	xor rax, rax
;	mov rax, 34
	syscall
	xor rax, rax
	xor rdi, rdi
	mov rax, 60
	mov rdi, 0x0
	syscall
