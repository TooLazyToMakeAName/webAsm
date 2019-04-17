BITS 64
	GLOBAL _start

lengthOffsett equ 16
fileNameOffest equ 19
bufferSize equ 0xb40
stringLen:
    push rcx
    push rbx
    mov rcx, 0x0
    lea rbx, [rax]
    counterLoop:
        inc rbx
        inc rcx
        mov al, [rbx]
        test al, al
        jnz counterLoop
    mov rax, rcx
    pop rbx
    pop rcx
    ret


printString:
    mov rdi, 1 ; stdout
    mov rax, 1; sys_wirte
	syscall
    ret

printNewLine:
    push rax
    push rdi
    push rsi
    push rdx
    
    mov rdx,1 
    mov al, 0xa
    dec rsp
    mov [rsp], al
    mov rsi, rsp
    mov rdi, 1 ; stdout
    mov rax, 1; sys_wirte
	syscall
   
    inc rsp
    pop rdx
    pop rsi
    pop rdi
    pop rax
    
    ret


 getdents64: ;(fd,esp,0x3210)
    mov rsi, r15
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
	mov rdx, bufferSize 
    mov rbp, rsp
	sub rsp, rdx
    mov r15, rsp 
    
    readFiles:
	    mov rdx, bufferSize 
        call getdents64
        test rax, rax
        jz endReadFiles
        mov rcx, rax
        mov rbx, rsp
        mov r14, 0
        .innerloop: 
            lea rax, [rbx+fileNameOffest]
            mov r12, rax
            push rcx
            call stringLen
            mov rdx, rax
            mov rsi, r12
            call printString
            call printNewLine
            pop rcx
            movzx r9, word [rbx+lengthOffsett]
            lea rbx, [rbx+r9]
            add r14, r9
            cmp r14, rcx
            jne .innerloop
            jmp readFiles
    endReadFiles:

    mov rdi, 0
	xor rax, rax
	mov al, 60
	syscall

