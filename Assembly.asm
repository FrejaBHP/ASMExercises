.686
.xmm
.model flat

.code

PUBLIC _addNumbers
_addNumbers PROC
	push    ebp                         ; Store Base Pointer value on the stack
    mov     ebp, esp                    ; Copy Stack Pointer to Base Pointer
    mov     eax, [ebp+8]                ; Copy num1 parameter to EAX. Because it takes parameters from outside the function, first parameter is grabbed from EBP+8 and not EBP-4
    mov     ecx, [ebp+12]               ; Copy num2 parameter to ECX. Because it takes parameters from outside the function, second parameter is grabbed from EBP+12 and not EBP-8
    add     eax, ecx                    ; Add num2 to num1 in the EAX register
    pop     ebp                         ; Restore Base Pointer to its previously pushed value, since nothing else was pushed in the meantime
    ret                                 ; Return sum from EAX
_addNumbers ENDP




PUBLIC _numbers
_numbers PROC
    push    ebp
    mov     ebp, esp
    mov     eax, [ebp+8]                ; Copy num1 to EAX
    mov     ebx, [ebp+12]               ; Copy num2 to EBX
    mov     ecx, [ebp+16]               ; Copy operator to use to ECX
    xor     edx, edx                    ; Zero EDX to prepare it in case of integer division
    mov     esi, [ebp+20]               ; Copy address of divRemainder to ESI

trydiv:
    cmp     ecx, 3                      ; Is operator value 3
    ;je     _cDiv                       ; No need for a jump instruction, replaced with call instead. Left here for clarity and as a reminder
    jne     trymul                      ; If operator isn't 3, jump to trymul section
    call    _cDiv                       ; If it is 3, call divide instruction
    jmp     finish                      ; Jump to end of function to skip other comparisons, aka "break"

trymul:
    cmp     ecx, 2                      ; Is operator value 2
    ;je     _cMul
    jne     trysub                      ; If operator isn't 2, jump to trysub section
    call    _cMul                       ; Else call multiply instruction
    jmp     finish                      ; Jump to end of function to skip other comparisons

trysub:
    cmp     ecx, 1                      ; Is operator value 1
    ;je     _cSub
    jne     tryadd                      ; If operator isn't 1, jump to tryadd section
    call    _cSub                       ; Else call subtraction instruction
    jmp     finish                      ; Jump to end of function to skip other comparisons

tryadd:
    cmp     ecx, 0                      ; Is operator value 0
    ;je     _cAdd
    jne     finish                      ; If operator isn't 0, jump to end and don't do anything (this shouldn't happen)
    call    _cAdd                       ; Else call addition instruction

finish:
    pop     ebp
    ret
_numbers ENDP


; Note to self: There is no reason for these functions to not be embedded within the main function
; If registers are configured differently, this can cause funny behaviour if called from elsewhere

_cAdd PROC
    add     eax, ebx                    ; add EBX to EAX
    ;leave                              ; LEAVE instruction not necessary since JMP instructions to here have been replaced with CALL. Left here for clarity and as a reminder
    ret
_cAdd ENDP


_cSub PROC
    sub     eax, ebx                    ; sub EBX from EAX
    ;leave
    ret
_cSub ENDP


_cMul PROC
    imul    eax, ebx                    ; multiply EAX by EBX
    ;leave
    ret
_cMul ENDP


_cDiv PROC
    idiv    ebx                         ; idiv divides EDX:EAX by the operand, so in this case, it divides EAX by EBX since EDX is 0. Due to int division, remainder is stored in EDX
    mov     [esi], edx                  ; Remainder in EDX is assigned to the remainder address stored in ESI
    ;leave
    ret
_cDiv ENDP




PUBLIC _getCharsInString
_getCharsInString PROC
    push    ebp
    mov     ebp, esp
    xor     ecx, ecx                    ; Zero ECX, ready it as a loop counter
    xor     edx, edx                    ; Zero EDX, ready it for storing chars, since only DL will be written to, and the remaining 3 bytes would be garbage
    mov     esi, [ebp+8]                ; Store address of char array in ESI
    mov     edi, [ebp+12]               ; Store address of int array in EDI

loopstart:
    mov     dl, [esi+ecx]               ; Store current character to look at in DL (first 8 bits of EDX). Since chars are only 8b, writing to EDX would copy 32b, aka 4 chars, at a time
    cmp     edx, 0                      ; Is this the null terminator?
    je      finish                      ; If yes, finish up

compare:
    mov     eax, edx                    ; Copies character value into EAX
    cmp     edx, 65                     ; If value is greater than 65, the character isn't a letter, so iterate to the next character
    jl      loopback
    cmp     edx, 122                    ; If value is greater than 122, it can't be a letter either, so iterate to the next character
    jg      loopback
    cmp     edx, 90                     ; If character is less than or equal to 90, jump to capital
    jle     capital
    cmp     edx, 122                    ; If character is instead less than or equal to 122, jump to noncapital
    jle     noncapital

process:
    ;imul    eax, 4                     ; Multiplies EAX by 4 to get a 32-bit/4B memory offset to match int size
    ;lea     ebx, [edi+eax]             ; Stores index address of int array in EBX
    ;inc     DWORD PTR [ebx]            ; Increments the value in index, hopefully
    inc     DWORD PTR [edi+4*eax]       ; Does all of the above, but in one instruction, and leaves EBX free

loopback:
    inc     ecx                         ; Increment loop count
    jmp     loopstart                   ; Go next

capital:
    sub     eax, 65                     ; Capital letters start at 65, so this would store A = 0, B = 1, C = 2, etc, in EAX
    jmp     process

noncapital:
    cmp     eax, 97                     ; If value is less than 97, it's not a letter, so iterate to next character
    jl      loopback                    ; This is to prevent processing the ASCII letter gap spanning 91 to 96
    sub     eax, 97                     ; Non-capital letters start at 97, so this would repeat the same pattern as for capital letters in EAX, so they're incremented together
    jmp     process

finish:
    pop     ebp
    ret
_getCharsInString ENDP




PUBLIC _bubbleSort
_bubbleSort PROC
    push    ebp
    mov     ebp, esp
    xor     ecx, ecx
    xor     edx, edx
    mov     esi, [ebp+8]                ; Store the address of the int array
    mov     edi, [ebp+12]               ; Store the length of the array - 1, to avoid say the length being 5 and trying to compare and access [5] to [4]

outerloopstart:
    cmp     edx, edi                    ; If end of array is reached in the outer loop, exit function
    jge     finish

innerloopstart:
    cmp     ecx, edi                    ; If end of array is reached in the inner loop, finish inner loop
    jge     outerloopend

compare:
    mov     eax, [esi+4*ecx]            ; Copy the value of current index (x)
    mov     ebx, [4+esi+4*ecx]          ; Copy the value of next index (y)
    cmp     eax, ebx                    ; If x <= y, skip swapping and iterate to next pair
    jle     innerloopend

swap:
    mov     [esi+4*ecx], ebx            ; Write x to &y in array
    mov     [4+esi+4*ecx], eax          ; Write y to &x in array

innerloopend:
    inc     ecx                         ; Increment inner loop counter
    jmp     innerloopstart              ; Go next

outerloopend:
    inc     edx                         ; Increment outer loop counter
    xor     ecx, ecx                    ; Reset inner loop counter
    jmp     outerloopstart              ; Go next

finish:
    pop     ebp
    ret
_bubbleSort ENDP




PUBLIC _fpA
_fpA PROC
    push    ebp
    mov     ebp, esp

    ; Normally, EBP+8 and EBP+12 would be stored in registers like EAX, but since values, and not addresses, are passed, 
    ; running FLD on EAX causes a segfault because FLD can only copy outside its own registers from dereferencing an address!
    ; In addition, since the return value is a float, it is not read from EAX either way, so using the regular registers can be skipped here

    ; A pop operation causes the ST(0) register to be marked empty and 
    ; the stack pointer (TOP) in the x87 FPU control work to be incremented by 1
    ; fx
    ; R4 = 13,44 (ST(1))
    ; R3 = 59,14 (ST(0))
    ; TOP (ST(0)) = R3, 59,14
    ; pop
    ; TOP (ST(0)) = R4, 13,44

calculateInFPU:
    fld DWORD PTR [ebp+8]               ; Pushes the first parameter onto the FP stack, ST(0) = num1
    fld DWORD PTR [ebp+12]              ; Pushes the second parameter onto the FP stack, ST(1) = num1, ST(0) = num2
    fmulp                               ; Multiplies ST(1) by ST(0), and pops ST(0) (TOP/ST(0) = R[X+1]) due to using FMULP over FMUL

    ;fstp    st(0)                      ; While this would leave the stack satisfyingly empty, it invalidates the return value because, well, it's empty. Only added for clarity

    ;fld     st(0)                      ; These two instructions would then square the number
    ;fmulp

    ;movss   xmm0, DWORD PTR [ebp+8]    ; Equivalent instructions using SSE
    ;movss   xmm1, DWORD PTR [ebp+12]   ; Since this is x86 MASM and not x86_64, the return value is ALWAYS read from ST(0), and not XMM0,
    ;mulss   xmm0, xmm1                 ; effectively rendering this block useless. This does however mean that this function will fail in a x86_64 application
                                        ; It could be made useful if the result was copied to ST(0), however

finish:
    pop     ebp
    ret
_fpA ENDP

END
