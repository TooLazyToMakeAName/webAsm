BITS 64
	GLOBAL _start

hex_xlat:       db "0123456789abcdef"

lengthOffsett equ 16
fileNameOffest equ 19
bufferSize equ 0xb40
fileTypeOffset equ 18


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

; Called with RDI is the register to convert and
; 
register_to_hex:
    push rcx
    push rdx
    push rsi

    sub rsp, 0x10
    mov rsi, rsp
    xor     eax,eax
    mov     ecx, 16             ; looper
    lea     rdx, [rel hex_xlat]  ; position-independent code can't index a static array directly

ALIGN 16
.loop:
    rol     rdi, 4              ; dil now has high bit nibble
    mov     al, dil             ; capture low nibble
    and     al, 0x0f
    mov     al, byte [rdx+rax]  ; look up the ASCII encoding for the hex digit
                                 ; rax is an 'index' with range 0x0 - 0xf.
                                 ; The upper bytes of rax are still zero from xor
    mov     byte [rsi], al      ; store in print buffer
    inc     rsi                 ; position next pointer
    dec     ecx
    jnz    .loop

.exit:
    mov rdx,0x10 
    mov rsi, rsp
    mov rdi, 1 ; stdout
    mov rax, 1; sys_wirte
	syscall
    
    add rsp, 0x010
    pop rsi
    pop rdx
    pop rcx

    ret
 
 getdents64: ;(fd,esp,0x3210)
    mov rsi, r15
    mov rdi, r8
	mov rax, 217 	
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


actualrStart:
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
            mov rdi, rdx
            
            call register_to_hex
            call printNewLine
            pop rdx

            xor rdi, rdi
            mov dil, [rbx+fileTypeOffset]
            call register_to_hex
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
    mov rax,100 
    call initHashMap
    mov rdi, rax
    .notyet: ; This is a label
    neg rdi 
    jl .notyet
    call register_to_hex
    call printNewLine
    mov rdi, 0
	mov rax, 60
	syscall

