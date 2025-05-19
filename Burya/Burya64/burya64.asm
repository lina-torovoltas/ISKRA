; Only works on linux!!!
; ISKRA-Burya64 ver1.0 on FASM

format ELF64 executable
entry start

segment readable writeable
    ; Initial constants for registers A–D used in the hash function
    A dw 0x0782
    B dw 0x07A9
    C dw 0x07B1
    D dw 0x05D4
    
    input_buffer rb 32 ; Buffer to store up to 32 bytes of user input
    number dq 0 ; 64-bit integer to store the parsed number from input
    data_bytes rb 8 ; Array to store byte-wise representation of the number (little-endian)
    hex_buffer rb 17 ; Output buffer for 16 hex chars + newline

segment executable
start:
    ; Read up to 32 bytes from stdin into input_buffer
    xor rax, rax
    xor rdi, rdi
    mov rsi, input_buffer
    mov rdx, 32
    syscall

    ; Clear rax and rcx for use in input processing loop
    xor rax, rax
    xor rcx, rcx

; Parse input digits into a numeric value, stop at newline, abort on invalid chars
.next_char:
    mov bl, byte [input_buffer + rcx]
    cmp bl, 10
    je  .done_input
    cmp bl, '0'
    jb  .invalid_input
    cmp bl, '9'
    ja  .invalid_input
    sub bl, '0'
    imul rax, rax, 10
    add rax, rbx
    inc rcx
    jmp .next_char

; Exit program with status code 1 (error) on invalid input
.invalid_input:
    mov rax, 60
    mov rdi, 1
    syscall

; Set pointer to byte buffer and reset index counter
.done_input:
    mov rsi, data_bytes
    xor rcx, rcx

; Convert number in RAX to bytes, store each byte in data_bytes buffer
; Loop until all bytes processed (RAX becomes zero)
; Then save byte count in RDI and clear RBX for next loop
.convert_loop:
    mov bl, al
    mov [rsi + rcx], bl
    inc rcx
    shr rax, 8
    test rax, rax
    jnz .convert_loop
    mov rdi, rcx
    xor rbx, rbx

; Main hash loop: process each byte of data_bytes to update registers A, B, C, D
; - Add current byte to A modulo 16-bit
; - Rotate bits in B by current byte (circular shift)
; - XOR current byte with C and D
; - Rotate registers A, B, C, D to mix state (A←B, B←C, C←D, D←A)
; Loop over all bytes to scramble the hash state
.loop:
    cmp rbx, rdi
    jge .done_loop
    movzx eax, byte [data_bytes + rbx]
    movzx ecx, byte [data_bytes + rbx]
    mov ax, word [A]
    add ax, cx
    and ax, 0xFFFF
    mov word [A], ax
    movzx ecx, byte [data_bytes + rbx]
    and ecx, 15
    mov dx, word [B]
    mov r8w, dx
    shl r8w, cl
    mov r9w, dx
    mov cl, 16
    sub cl, byte [data_bytes + rbx]
    and cl, 15
    shr r9w, cl
    or r8w, r9w
    and r8w, 0xFFFF
    mov word [B], r8w
    mov ax, word [C]
    xor ax, cx
    mov word [C], ax
    mov ax, word [D]
    xor ax, cx
    mov word [D], ax
    mov ax, word [A]
    mov bx, word [B]
    mov cx, word [C]
    mov dx, word [D]
    mov word [A], bx
    mov word [B], cx
    mov word [C], dx
    mov word [D], ax
    inc rbx
    jmp .loop

; Convert registers A–D to hex and store in hex_buffer
; Append newline character
; Calculate length of hex string + newline for write syscall
; Write hex hash string to stdout
.done_loop:
    mov rsi, hex_buffer
    movzx eax, word [A]
    call write_hex_word
    movzx eax, word [B]
    call write_hex_word
    movzx eax, word [C]
    call write_hex_word
    movzx eax, word [D]
    call write_hex_word
    mov byte [rsi], 10
    inc rsi
    mov rdx, rsi
    sub rdx, hex_buffer
    mov rax, 1
    mov rdi, 1
    mov rsi, hex_buffer
    syscall

    ; Exit program cleanly with status 0
    mov rax, 60
    xor rdi, rdi
    syscall

; Save registers RCX and RBX
; Set loop counter CX to 4
write_hex_word:
    push rcx
    push rbx
    mov cx, 4

; Loop: rotate AX left by 4 bits to process each hex nibble
; Extract lower 4 bits into BL
; If less than 10, it’s a digit, else a-f letter
; Convert to ASCII '0'-'9' or 'a'-'f' accordingly
.wloop:
    rol ax, 4
    mov bl, al
    and bl, 0xF
    cmp bl, 10
    jl .digit
    add bl, 'a' - 10
    jmp .store

; Convert nibble to ASCII digit '0'–'9' by adding ASCII code for '0'
.digit:
    add bl, '0'

; Stores 4 hex characters in buffer and returns
.store:
    mov [rsi], bl
    inc rsi
    loop .wloop
    pop rbx
    pop rcx
    ret
