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

; rax = pointer to key C string (zero byte terminated)
; rbx = value (value or memory pointer)
; rcx = hashmap 
; rdx = size
; reurn rax = 0 is good else bad  
insertInToHashmap:
    push r9

    call hash

    mov r9, rdx
    xor rdx, rdx
    div r9
    push rdx

    mov rax, 0x10
    mul rdx
    
    add rax, rcx
    mov rdx, [rax]
    test rdx, rdx
    je .end

    pop rdx
    mov [rax], rdx
    add rax, 0x8
    mov [rax], rbx
    mov rax, 0xFFFFFFFFFFFFFFFF 
   
    .end
    inc rdx
    mov rax, rdx

    pop r9 

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
