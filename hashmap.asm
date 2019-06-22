BITS 64
	GLOBAL _start

%include "print.asm"
%include "dir.asm"

section .text

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

modulo:

    push rdx
    xor rdx, rdx
    div rbx
    mov rax, rdx
    pop rdx
    
    ret


; rax = pointer to key C string (zero byte terminated)
; rbx = hashmap 
; rcx = size
; reurn rax 

getFromHashMap:
    call hash

    push rbx

    mov rbx, rcx
    call modulo

    pop rbx

    ; NOTE rax is now hasmap index as we have goten a offset and dont need the string anymore!!!

    lea rax, [rax*8]
    add rax, rcx
    mov rax, [rax]

    ret



; rax = pointer to key C string (zero byte terminated)
; rbx = value (value or memory pointer)
; rcx = hashmap 
; rdx = size
; reurn rax = 0 is good else bad  
insertInToHashmap:
    call hash

    push rbx

    mov rbx, rdx
    call modulo

    pop rbx

    ; NOTE rax is now hasmap index as we have goten a offset and dont need the string anymore!!!

    lea rax, [rax*8]
    add rax, rcx
    mov rdx, [rax]
    test rdx, rdx
    jne .end

    mov [rax], rbx
    mov rax, 0

    ret
   
    .end:
    inc rdx
    mov rax, rdx
    ret


br:
    ret

_start:
    mov rax, 5*8
    call initHashMap
    mov r15, rax ; r15 is hashmap buffer. 
    xor rax, rax
	push rax
	push  byte '.'

	; sys_open(".", 0, 0)
	mov al, 2      
	mov rdi, rsp   
	xor rsi, rsi 
	xor rdx, rdx 
	syscall	

    mov r12, rax ; use r12 as file descriptor buffer.
    
    .loopFiles:
    mov rax, r12
    call getNextFile
    test rax,rax ; reruns 0 if no bytes could be read!
    jz .exit
    
    add rax, 19    ; offset to get the file name ; 
    push rax
    mov rsi, rax   ; stringLen take argument in rsi
    call stringLen
    mov rdx, rax   ; prints moves the string to print to rdx so syscall can be done directy.
    call printString  
    call printNewLine ; adds a new lineA
    pop rax
    mov rcx, r15
    mov rbx, 0x0123456789abcdef
    mov rdx, 5
    call insertInToHashmap
    call br

    jmp .loopFiles

    .exit:
    mov rax, 60
    mov rdi, 0
    syscall
