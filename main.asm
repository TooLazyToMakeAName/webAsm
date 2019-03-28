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

httpHeader: db "HTTP/1.x 200 OK",10,10
httpHeaderLen: equ $-httpHeader

indexFileName: db "index.html",0x0
indexFileDescriptor: dd 0x0
indexFileMap: dq 0x0
indexFileSize: dq 0x0

global _start
section .text

breakpoint:
    ret

; openFile from path with the sys_open call
; ASUMES Flags and MODE
; args(eax:char*)
; ret (eax:int fileDesciptor)
; FUCKS ! rax, rdi, rsi, rdx

openFile:
    mov rdi, rax           ; gives path to file
    xor rsi, rsi        ; set READOLNLY value 0x0
    xor rdx, rdx        ; set mode to 0 (nothing)
    mov rax, 2
    syscall
    ret




; getFileSize of fileDescriptor in bytes
; args (eax:int FileDescriptor)
; ret  (eax:int byteSize)
; FUCKS ! rsi, rdi, rax,

; struct stat {  144 bytes
;     dev_t     st_dev;     /* ID of device containing file     8  bytes //offsett 0
;     ino_t     st_ino;     /* inode number */                  8  bytes //offsett 8
;     mode_t    st_mode;    /* protection */                    4  bytes //offsett 16
;     nlink_t   st_nlink;   /* number of hard links */          8  bytes //offsett 20
;     uid_t     st_uid;     /* user ID of owner */              4  bytes //offsett 28
;     gid_t     st_gid;     /* group ID of owner */             4  bytes //offsett 32
;     dev_t     st_rdev;    /* device ID (if special file)      8  bytes //offsett 36
;     off_t     st_size;    /* total size, in bytes */          8  bytes //offsett 44
;     blksize_t st_blksize; /* blocksize for file system I/O    8  bytes //offsett 52
;     blkcnt_t  st_blocks;  /* number of 512B blocks allocated  8  bytes //offsett 60
;     time_t    st_atime;   /* time of last access */           16 bytes //offsett 68
;     time_t    st_mtime;   /* time of last modification */     16 bytes //offsett 84
;     time_t    st_ctime;   /* time of last status change */    16 bytes //offsett 100
; };  total 144 its all lies there is some more padding.

getFileSize:
    push rbp
    mov rbp, rsp ; save old stack pointer
    sub rsp, 144 ; 116 desimal bytes.
    ; sys_fstat
    ; rax = num, rdi = fileDescriptor, rsi = pointer to stat struct
    mov rsi, rsp
    mov rdi, rax ; moves fileDescriptor for syscall
    mov rax, 5   ; sys_fstat
    syscall
    mov rax, rsp
    add rax, 0x38
    mov rax, [rax]
    mov rsp, rbp
    pop rbp
    ret

; mmap
; maps a file to memory
; args(eax;int fileDescriptor)
; ret (eax:pointer addres of the file)
; FUCKS ! rax, rdi, rsi, rdx, r10, r8, r9
memoryMapFile:
    mov r8, rax ; moves the fileDescriptor to the corresponding register
    call getFileSize ; returns fileSize in rax
    mov rsi, rax ; move the file size of the fileDescriptor to rsi
    xor rdi, rdi ; sets sugested adress pointer to NULL pointer
    mov rdx, 0x1 ; sets PROT_READ prot value for the file.
    mov r10, 0x2 ; sets the flag mode to PRIVATE_MAP
    mov r9, 0x0  ; sets the ofsett of the file to zero
    mov rax, 9   ; sys_mmap
    syscall
    ret


; string length
; arg(rax:pointer memoryloaction)
; ret(rax: int Lenth of tring in bytes)
stringLen:
    mov rcx, 0x0
    lea rbx, [rax-1]
    counterLoop:
        inc rbx
        inc rcx
        mov al, [rbx]
        test al, al
        jnz counterLoop
    dec rcx
    mov rax, rcx
    ret

makeSocket:
	
	;Setting up stack and stack allocations.
	mov rbp, rsp
	sub rsp, 0x14

	; sys_socket
	; creats a socket,  Args:  family AF_INE in rdi, type SOCK_STREAM in  rsi, protocol in  rdx
	xor rdi, rdi
	xor rsi, rsi
	xor rax, rax
	mov rdi , 0x2 ; AF_INET
	mov rsi, 0x1  ; SOCK_STREAM 
	xor rdx, rdx  ; Protocol 
	mov rax, 41
	syscall
	push rax ; saving two copys of the socket file discriptor to the stack
	push rax
	
	; Does a syscall so socket can be used impdelty after close so there is no time out.
	; setsocetopt FileDescriptor, SOL_SOCKET, SO_REUSEADDR OPTION(value to set) SIZEOF(OPTION)
	mov edi, eax ; socket file descriptor
	mov eax, 0x1
	mov [rbp-0x10], eax
	lea r10, [rbp-0x10] ; moves the option value to the stack (true)
	mov r8d, 0x04       ; the size of the optine (int)
	mov edx, 0x02	    ; SO_RESUSEADDR
	mov esi, 0x01       ; SOL_SOCKET
	mov eax, 54	    ; sys_setsocketopt sys table value 
	syscall

	; Binds the socket to a port 
	; sys_bind FileDescriptor, struct sockaddr_in, Size of (sockaddr_in)
	xor rdi, rdi
	pop rdi  ; fileDescriptor
	mov rsi, sockaddr_in ; the struct
	xor rdx, rdx
	xor rax, rax
	mov rdx, 0x10 ; Size of the struct 16 byte
	mov rax, 49   ; sys_bind 
	syscall
	
	; Lisen call makes the socket ready for acepting tcp connections
	; sys_listen FileDescriptorNumber of hanging connections allowed
	; Note! the file descriptor remains unchanged from last call
	xor rax, rax
	xor rsi, rsi
	mov rax, 50 	; sys_listen 
	mov rsi, 0x5    ; Number of connection the socket allows to be qued.
	syscall

	; accept sys call, accepts comunication with a client
	; sys_accept FileDescriptor, struct sockaddr*, size of (struct sockadrrs)
	; Note! the file descriptor remains unchanged from last call
	mov rsi, rbp  ; 16 byte stack variable. Accept leavs a struct on the stack
	mov rdx, sockaddr_inLen  ; Pointer to size of the struct (16 bytes/0x10)
	mov rax, 43    ; sys_accept
	syscall

	; Printes hello messege to the tcp client socket connection
	; sys_write FileDescriptor, bytes to write, sizeOf(bytes), 
	mov rdi, rax  ; the client socket from last sys call is moved for rax to rdi.
	mov rax, 1     ; sys_write
	mov rsi, httpHeader
	mov rdx, httpHeaderLen
	syscall
	mov rax, 1
	mov rsi, [indexFileMap]  ; Bytes
	mov rdx, [indexFileSize] ; SizeOf(Bytes)
	syscall

    ;closes the client socket
	; sys_close filDescriptor
	; NB ! same file discriptor as above used.
	mov eax, 3 ; sys_write
	syscall
	
	;closes host/bind socket
	; sys_close fileDescriptor
	mov eax, 3 ; sys_write
	pop rdi    ; pops saved fileDescriptor of bind socet of the stack
	syscall

	; terminates the program
	;sys_exit
	xor rax, rax
	xor rdi, rdi
	mov rax, 60 ; sys_exit
	mov rdi, 0x0 ; exit code
	syscall


_start:
        mov  rax, indexFileName
        call openFile
        call memoryMapFile
        mov [indexFileMap], rax
	call stringLen
	mov [indexFileSize], rax
        call makeSocket 
