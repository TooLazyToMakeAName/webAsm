BITS 64
	GLOBAL _start

%include "print.asm"
%include "dir.asm"
initHashMap:
    mov r8, -1 ; moves the fileDescriptor to the corresponding register
    mov rsi, rax ; move the file size of the fileDescriptor to rsi
    mov rdi, 0 ; sets sugested adress pointer to NULL pointer
    mov rdx, 3 ; sets PROT_READ | prot_write  prot value for the file.
    mov r10, 0x21 ; sets the flag mode to anonymusMap
    mov r9, 0  ; sets the ofsett of the file to zero
    mov rax, 9   ; sys_mmap
    syscall
    ret


;hasing fuction for strings 
;uses the djb2 hashing alorithem 
;NB! Not to be used for crypto !!!!!!
;arg(rax: pointer string in memorylocation)
;ret(rax: int hashed value)
hash:
        push rcx
        push rbx
    
        mov rcx, rax
        mov rax, 5381
    .loop:
        mov rbx, rax
        shr rax, 5
        add rax, rbx
        xor rbx, rbx 
        mov bl, [rcx]
        xor rax, rbx
        inc rcx
        test bl, bl
        jne .loop

        pop rbx
        pop rcx
        ret


astart:
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
        mov r13, rax
        mov rbx, r15
        mov r14, 0
        .innerloop:
            
            lea rax, [rbx+fileNameOffest]
            
            mov r12, rax
            call stringLen
            
            mov rdx, rax
            mov rsi, r12
            call printString
            call printNewLine
            
            mov rax, rsi
            call hash

            push rdx
            mov rdx, 0
            mov rcx, 0x10
            div rcx
            push rax
            mov rax, rdx
            call printRAXtoHex
            pop rax
            call printNewLine
            pop rdx

            xor rdi, rdi
            mov dil, [rbx+fileTypeOffset]
            push rax
            mov rax, rdi
            call printRAXtoHex 
            pop rax
            call printNewLine

            movzx r9, word [rbx+lengthOffsett]
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

    mov rbx, rax
    
    .loopFiles:
    mov rax, rbx
    call getNextFile
    test rax,rax
    je .exit
    
    add rax, 19
    mov rsi, rax
    call stringLen
    mov rdx, rax
    call printString
    call printNewLine
    jmp .loopFiles

    .exit:
    mov rax, 60
    mov rdi, 0
    syscall
