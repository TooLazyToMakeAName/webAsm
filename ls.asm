BITS 64
	GLOBAL _start

lengthOffsett equ 16
fileNameOffest equ 19

stringLen:
    mov rcx, 0x0
    lea rbx, [rax]
    counterLoop:
        inc rbx
        inc rcx
        mov al, [rbx]
        test al, al
        jnz counterLoop
    dec rcx
    mov rax, rcx
    ret


printString:
    mov rdi, 1 ; stdout
    mov eax, 1; sys_wirte
	syscall
    ret

 getdents64: ;(fd,esp,0x3210)
    mov rsi, r11
    mov rdi, r8
	mov rax, 217 	
	syscall
    ret



_start:
	xor rax, rax
	push rax
	push  byte '.'

	; sys_open(".", 0, 0)
	mov al, 2      
	mov rdi, rsp   
	xor rsi, rsi 
	xor rdx, rdx 
	syscall	

    mov r8, rax
	mov rdx, 0x120 
    mov rbp, rsp
	sub rsp, rdx
    mov r11, rsp 
    
    readFiles:
	    mov rdx, 0x120 
        call getdents64
        cmp rax, 0
        jle endReadFiles
        mov r13, rax
        xor r14, r14
        mov rbx, rsp
        .innerloop: 
            movzx r9, word [rbx+lengthOffsett]
            lea rax, [rbx+fileNameOffest]
            mov r12, rax
            push rbx
            call stringLen
            pop rbx
            mov rdx, rax
            inc rdx
            mov rsi, r12
            call printString
            lea rbx, [rbx+r9]
            add r14, r9
            cmp r14, r13
            jne .innerloop
            jmp readFiles
    endReadFiles:
    mov rdi, 0
	xor rax, rax
	mov al, 60
	syscall

