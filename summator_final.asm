; first number
lea si, enter_first_number
push si
push 0x1
push 0x14
call PRINT_STRING
add sp, 0x6


lea di, number_one
push 0x14
push 0x1
push 0x10
push di
call GET_INPUT_NUMBER
add sp, 0x8
lea si, number_one_len
mov [si], ax

; ax returned from GET_INPUT_NUMBER - len of number
lea si, number_one
push ax
push si
push si
call CONVERT_TO_PC_REPRESENTATION
add sp, 0x6
 

; second number 
lea si, enter_second_number
push si
push 0x2
push 0x19
call PRINT_STRING
add sp, 0x6


lea di, number_two
push 0x19
push 0x2
push 0x10
push di
call GET_INPUT_NUMBER
add sp, 0x8
lea si, number_two_len
mov [si], al


; ax returned from GET_INPUT_NUMBER - len of number
; but ah is trash
lea si, number_two
push ax
push si
push si
call CONVERT_TO_PC_REPRESENTATION
add sp, 0x6


; if first entered number < second -> SWAP them
lea si, number_one_len
mov al, [si]
xor ah, ah
push ax

lea si, number_two_len
mov al, [si]
xor ah, ah
push ax

lea si, number_one
push si
lea si, number_two
push si 
call SWAP_NUMBERS
add sp, 0x8

; CALCULATE - advance hex summator
; do number_one + number_two.
; number_one > number_two(MUST BE)

lea si, number_one_len
mov al, [si]
lea si, number_two_len


; push *ptr of the last result element
lea si, result
mov ax, si
lea si, number_one_len
mov bx, [si]
add ax, bx
push ax


; push *ptr of the last number_two element 
lea si, number_two
mov ax, si
lea si, number_two_len
mov bx, [si]
add ax, bx
dec ax
push ax

; push *ptr of the last number_one element
lea si, number_one
mov ax, si
lea si, number_one_len
mov bx, [si]
add ax, bx
dec ax
push ax

; push len(number_two)
lea si, number_two_len
mov ax, [si]
push ax

; push len(number_one)
lea si, number_one_len
mov ax, [si]
push ax
call ADVANCE_HEX_EDITOR


; CONVERT_TO_HUMAN_REPRESENTATION 
;    mov si, [bp+4]
;    mov di, [bp+6]
;    mov cx, [bp+8]
lea si, number_one_len
mov ax, [si]
inc ax
push ax
lea si, result
push si
push si
call CONVERT_TO_HUMAN_REPRESENTATION
add sp, 0x6




lea si, result
push si
push 0x3
lea si, number_one_len
mov ax, [si]
inc ax
push ax
call PRINT_STRING
jmp THE_END




GET_INPUT_NUMBER:
    ; [bp+10] = len of string that was printed before called that func
    ; [bp+8]  = row. Need for PRINT CHAR
    ; [bp+6]  = max len of number
    ; [bp+4]  = char *ptr
    ; [bp-2]  = counter/column. Need for PRINT CHAR
    ; [bp-4]  = cx

    push bp
    mov bp, sp
    
    ; need to decrease sp, becase interrupt uses stack, and will rewrite our local variables :9(
    sub sp, 0x4
    
    cld
    mov cx, word ptr [bp+6]
    mov di, word ptr [bp+4]
    mov word ptr [bp-2], 0x0
    
    GET_INPUT_NUMBER_LOOP:
        ; read key
        mov ah, 0x0
        int 0x16
    
        ; if key == '\n' -> go out
        cmp al, 0xD
        je ENTER_PRESSED
        
        stosb
        
        push ax
        mov ax, word ptr [bp+8]
        push ax
        mov ax, word ptr [bp-2]
        add ax, word ptr [bp+10]
        push ax
        mov word ptr [bp-4], cx
        call PRINT_CHAR
        
        add sp, 0x6
        mov cx, word ptr [bp-4]
        
        inc word ptr [bp-2]
        loop GET_INPUT_NUMBER_LOOP
        
    
    ENTER_PRESSED:
        mov al, byte ptr [bp-2]
        xor ah, ah
        mov sp, bp
        pop bp
        ret



PRINT_CHAR:
    ; [bp+8]  = char *ptr
    ; [bp+6]  = row
    ; [bp+4]  = column
 
    push bp
    mov bp, sp
    
    ; set cursor position
    mov ah, 0x2
    mov dh, byte ptr [bp+6]
    mov dl, byte ptr [bp+4]
    int 0x10
    
    
    ; print symbol
    mov cx, 0x1
    mov al, byte ptr [bp+8]
    mov ah, 0xA
    int 0x10
    
    pop bp
    ret



PRINT_STRING:
    ; [bp+8] = char *ptr
    ; [bp+6] = row
    ; [bp+4] = string len
    ; [bp-2] = column

    push bp
    mov bp, sp
    
    ; need to decrease sp, becase interrupt uses stack, and will rewrite our local variables :9(
    sub sp, 0x2
    
    cld
    mov si, [bp+8]
    mov cx, word ptr [bp+4]
    mov word ptr [bp-2], 0x0
    
    
    PRINT_STRING_LOOP:
        ; set cursor position
        mov ah, 0x2
        mov dh, byte ptr [bp+6]
        mov dl, byte ptr [bp-2]
        int 0x10
        add byte ptr [bp-2], 0x1
        
        ; load symbol
        mov word ptr [bp+4], cx
        lodsb
        
        ; print symbol
        mov cx, 0x1
        mov ah, 0xA
        int 0x10
        
        mov cx, word ptr [bp+4]
        loop PRINT_STRING_LOOP

    mov sp, bp
    pop bp
    ret



    
CONVERT_TO_HUMAN_REPRESENTATION:
    push bp
    mov bp, sp
    
    cld
    mov si, [bp+4]
    mov di, [bp+6]
    mov cx, [bp+8]    
    
    
    CONVERT_TO_HUMAN_REPRESENTATION_LOOP:
        lodsb
        jmp IN_DIGIT_PC_RANGE
        DO_DIGIT_HUMAN_TRANFORM:
            add al, 0x30
            jmp CALCULATE_2
        
        DO_ABCDEF_HUMAN_TRANSFORM:
            add al, 0x37
        
        CALCULATE_2:
            stosb
            loop CONVERT_TO_HUMAN_REPRESENTATION_LOOP
            
            mov sp, bp
            pop bp
            ret

        IN_DIGIT_PC_RANGE:
            test al, al
            jge SECOND_DIGIT_HUMAN_CONDITION
            jmp DO_ABCDEF_HUMAN_TRANSFORM
            
            SECOND_DIGIT_HUMAN_CONDITION:
                cmp al, 0x9
                jle DO_DIGIT_HUMAN_TRANFORM
                jmp DO_ABCDEF_HUMAN_TRANSFORM
 
    
     mov sp, bp
     pop bp
     ret
    
    
        

CONVERT_TO_PC_REPRESENTATION:
    push bp
    mov bp, sp
    
    cld
    mov si, [bp+4]
    mov di, [bp+6]
    mov cx, [bp+8]
    
    CONVERT_TO_PC_REPRESENTATION_LOOP:
    
    
        lodsb ; if al > 0x29 && al < 3A then al = al - 0x30
                ; else if al > 40 && al < 47 then al = al - 0x37
                ; else invalid iput
                
        jmp IN_DIGIT_RANGE
        DO_DIGIT_TRANSFORM:
            sub al, 0x30
            jmp CALCULATE
            
            
        DO_ABCDEF_TRANSFORM:
            sub al, 0x37
        
        CALCULATE:
        
            stosb
            loop CONVERT_TO_PC_REPRESENTATION_LOOP
            
            mov sp, bp
            pop bp
            ret
   
            
        IN_DIGIT_RANGE:
            cmp al, 0x30
            jge SECOND_DIGIT_CONDITION
            jmp IN_ABCDEF_RANGE
            
            SECOND_DIGIT_CONDITION:
                cmp al, 0x39
                jle DO_DIGIT_TRANSFORM
                jmp IN_ABCDEF_RANGE
                
        
        IN_ABCDEF_RANGE:
            cmp al, 0x40
            jge SECOND_ABCDEF_CONDITION
            call INVALID_INPUT
            jmp THE_END
            
            SECOND_ABCDEF_CONDITION:
                cmp al, 0x47
                jle DO_ABCDEF_TRANSFORM
                call INVALID_INPUT
                jmp THE_END
            
             
INVALID_INPUT:
    push bp
    mov bp, sp

    lea si, invalid_entered_number
    push si
    push 0x3
    push 0x1A
    call PRINT_STRING
    add sp, 0x6
    
    mov sp, bp
    pop bp
    ret


ADVANCE_HEX_EDITOR:
    push bp
    mov bp, sp
    
    sub sp, 0x6
    
    ; number_one > number_two. For correct work algorithm
    ; [bp+4]  = len(number_one)
    ; [bp+6]  = len(number_two)
    ; [bp+8]  = number_one *ptr to current element
    ; [bp+10] = number_two *ptr to current element
    ; [bp+12] = result array *ptr to current element
    
    ; [bp-2]  = carry flag
    ; [bp-4]  = number_one[i]
    ; [bp-6]  = len(number_one) - len(number_two). See man for understand
    std
    mov word ptr [bp-2], 0x0
    
    mov ax, word ptr [bp+4]
    mov word ptr [bp-6], ax
    mov ax, word ptr [bp+6]
    sub word ptr [bp-6], ax
    
    mov cx, [bp+4]
    mov si, [bp+8]
    mov di, [bp+12]
    
    L2: 
        lodsb
        mov word ptr [bp-4], ax

        cmp cx, word ptr [bp-6]; if cx > [bp-6]
        jle END_OF_NUMBER_TWO
        
        mov word ptr [bp+8], si
        mov si, [bp+10]
        lodsb
        mov word ptr [bp+10], si
        mov si, word ptr [bp+8] 
        
        ; if number_one[i] + number_two[i] + carry_flag < 10 then WITHOUT_CARRY
        add ax, word ptr [bp-4]
        add ax, word ptr [bp-2]
        cmp ax, 0x10
        jl WITHOUT_CARRY
        
        WITH_CARRY:                
            sub ax, 0x10
            stosb
            mov word ptr [bp-2], 0x1
            loop L2
            jmp AFTER_LAST_DIGIT
        
        
        WITHOUT_CARRY:
            stosb
            mov word ptr [bp-2], 0x0     
            loop L2
            jmp AFTER_LAST_DIGIT
        
        
        END_OF_NUMBER_TWO:
            add ax, word ptr [bp-2]
            cmp ax, 0x10
            jl WITHOUT_CARRY
            jmp WITH_CARRY
            
        AFTER_LAST_DIGIT:
            mov ax, word ptr [bp-2]
            stosb
            
            mov sp, bp
            pop bp
            ret
            
                
    

SWAP_NUMBERS:
    ; [bp+4]  = number_two
    ; [bp+6]  = number_one
    ; [bp+8]  = len(number_two)
    ; [bp+10] = len(number_one)
    push bp
    mov bp, sp
    
    mov al, byte ptr [bp+10]
    cmp al, byte ptr [bp+8]
    jge WITHOUT_SWAP
    
    mov ax, word ptr [bp+6]
    mov bx, word ptr [bp+4]
    mov word ptr [bp+4], ax
    mov word ptr [bp+6], bx
    
    
    WITHOUT_SWAP:
        mov sp, bp
        pop bp
        ret

THE_END:
    nop
    nop
    nop


enter_first_number db 'Enter a hex number: '  ; len = 0x14
enter_second_number db 'Enter second hex number: ' ; len = 0x19
invalid_entered_number db 'Invalid entered number :90' ; len = 0x1A

number_one db 0x10 dup(0)
number_one_len dw 0x0

number_two db 0x10 dup(0)
number_two_len dw 0x0

result db 0x10 dup(0)
result_len dw 0x0