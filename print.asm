BITS 64

GLOBAL stringLen
GLOBAL printString
GLOBAL printNewLine
GLOBAL printRAXtoHex

EXTERN stringLen
EXTERN printString
EXTERN printNewLine
EXTERN printRAXtoHex

hex_xlat:       db "0123456789abcdef"

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

; 
printRAXtoHex:
    push rax
    push rdi 
    mov rdi, rax 
    push rdi
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
    pop rdi
    pop rdi
    pop rax
    ret
 
