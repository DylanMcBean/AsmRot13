section .data
    alphabet db 'abcdefghijklmnopqrstuvwxyzABCDEFHIJKLMNOPQRSTUVWXYZ0123456789 ', 0
    tester db 'we have lift off',0 , 0xA

section .text
    global _start


_start:
    mov rax, 1
    mov rdi, 1
    mov rsi, tester
    mov rdx, 20
    syscall

    mov rax, tester
    mov rbx, 13
    mov rcx, alphabet
    call _rotEncode

    mov rax, 1
    mov rdi, 1
    mov rsi, tester
    mov rdx, 20
    syscall

    mov rax, tester
    mov rbx, 13
    mov rcx, alphabet
    call _rotDecode

    mov rax, 1
    mov rdi, 1
    mov rsi, tester
    mov rdx, 20
    syscall

    ; Exit the program
    mov rax, 60            ; syscall number for sys_exit
    xor rdi, rdi           ; exit status 0
    syscall

; input -> 
;           rax (start address of char* buffer), 
;           rbx (shift amount), 
;           rcx (mapped char* buffer)
; output -> none (change in place, char* buffer at rax)
; description: perform a rot encode on char* buffer
_rotEncode:
    mov r8, 0
    _rotELoop:
        ; step 1, locate character in mapped char*
        mov r9, 0
        _rotEFindPosition:
            mov r10b, [rax+r8]      ; check if the current char being checked_
            cmp r10b, [rcx+r9]      ;   in the input is the same as the char_
            je _rotEIncrement       ;   being checked in the mapped.
            inc r9                  ; increase the mapped index
            mov r10, [rcx+r9]       ; check if at the end of the mapped buffer
            cmp r10, 0
            je _rotEIncrementChar   ; if at end of mapped buffer, char not in mapped. exit rot
            jmp _rotEFindPosition

        _rotEIncrementChar:
            inc r8
            jmp _rotEncode

        ; step 2, add shift amount
        _rotEIncrement:
            add r9, rbx             ; add the shift amount to the index

        ; step 3, mod back around
        push rax        ; store rax as not to get lost
        xor rdx, rdx    ; reset rdx to zero
        mov rax, r9     ; move mapped index to rax
        mov r10, 62     ; move mapped size to r10 (this will be changed for length of mapped later, but 26 is placeholder)
        idiv r10        ; divid mapped index byt mapped size
        pop rax         ; retrieved rax
        mov r9, rdx     ; make mapped indedx the remainder of division
        
        ; step 4, map back
        mov r10b, [rcx+r9]   ; get new mapped index
        mov [rax+r8], r10b   ; replace current char with new mapped char

        inc r8              ; increment char index
        mov dl, [rax+r8]    ; check if at end of char* buffer
        cmp dl, 0
        jne _rotELoop       ; if not at end jump back to top
    _rotEEnd:
        ret


; input -> 
;           rax (start address of char* buffer), 
;           rbx (shift amount), 
;           rcx (mapped char* buffer)
; output -> none (change in place, char* buffer at rax)
; description: perform a rot encode on char* buffer
_rotDecode:
    mov r8, 0
    _rotDLoop:
        ; step 1, locate character in mapped char*
        mov r9, 0
        _rotDFindPosition:
            mov r10b, [rax+r8]      ; check if the current char being checked_
            cmp r10b, [rcx+r9]      ;   in the input is the same as the char_
            je _rotDIncrement       ;   being checked in the mapped.
            inc r9                  ; increase the mapped index
            mov r10, [rcx+r9]       ; check if at the end of the mapped buffer
            cmp r10, 0
            je _rotDIncrementChar   ; if at end of mapped buffer, char not in mapped. exit rot
            jmp _rotDFindPosition

        _rotDIncrementChar:
            inc r8
            jmp _rotEncode

        ; step 2, add shift amount
        _rotDIncrement:
            add r9, 62
            sub r9, rbx             ; add the shift amount to the index

        ; step 3, mod back around
        push rax        ; store rax as not to get lost
        xor rdx, rdx    ; reset rdx to zero
        mov rax, r9     ; move mapped index to rax
        mov r10, 62     ; move mapped size to r10 (this will be changed for length of mapped later, but 26 is placeholder)
        idiv r10        ; divid mapped index byt mapped size
        pop rax         ; retrieved rax
        mov r9, rdx     ; make mapped indedx the remainder of division
        
        ; step 4, map back
        mov r10b, [rcx+r9]   ; get new mapped index
        mov [rax+r8], r10b   ; replace current char with new mapped char

        inc r8              ; increment char index
        mov dl, [rax+r8]    ; check if at end of char* buffer
        cmp dl, 0
        jne _rotDLoop       ; if not at end jump back to top
    _rotDEnd:
        ret
