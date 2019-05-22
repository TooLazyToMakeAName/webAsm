BITS 64

section .data

bufferSize equ 0xb40 ; double length of a maxed sized dent.
lengthOffsett equ 16
fileNameOffest equ 19
fileTypeOffset equ 18

nextDent dq 0x0
dentsByteSize dq 0x0
section .bss
dirent64Buff resb bufferSize

section .text
; takes a file descriptor and filles the dirent64Buff with dirents. 
; arg rax = fileDescriptor
; return rax = bytes written.
getdents64: 
    push rdi
    push rsi
    push rdx
    push rcx
    
    mov rdi, rax ;arg filedescriptor
    mov rsi, dirent64Buff ; offset to writeTo
    mov rdx,  bufferSize 
    mov rax, 217
    syscall
   
    pop rcx
    pop rdx
    pop rsi
    pop rdi

    ret

getNextFile:
   push rbx
   mov rbx, [nextDent]
   cmp [dentsByteSize], rbx
   jnz .dentHandler
   
   call getdents64
   mov [dentsByteSize], rax
   xor rbx, rbx 
   mov [nextDent],rbx
   test rax, rax
   je .end

   .dentHandler: ; rbx = nextDent
   lea rax, [rbx + dirent64Buff]
   add rax, lengthOffsett
   mov ax, [rax]
   movzx rax, ax
   add [nextDent], rax
   lea rax, [rbx+dirent64Buff]

   .end:
   pop rbx
   ret
