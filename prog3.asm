        model SMALL			
        dataseg				
FVar	db ?			       
MB	db 0h, 0ffh, 11h, 55h, 10h, 5h, 0h, 0h

        codeseg			        
        startupcode			

        lea     BX, MB
                                        ; ???? ???? ???????
        cmp     BYTE PTR [BX + 7], 0    ; x7
        je      SECOND
        cmp     BYTE PTR [BX + 6], 0    ; x7 & ~x6
        jne     SECOND
        cmp     BYTE PTR [BX + 3], 0    ; x7 & ~x6 & x3
        je      SECOND
        cmp     BYTE PTR [BX + 1], 0    ; x7 & ~x6 & x3 & x1
        jne     TRUERES
SECOND:                                 ; ???? ???? ???????
        cmp     BYTE PTR [BX + 6], 0    ; x6
        je      THIRD
        cmp     BYTE PTR [BX + 4], 0    ; x6 & x4
        je      THIRD
        cmp     BYTE PTR [BX + 2], 0    ; x6 & x4 & x2
        je      THIRD
        cmp     BYTE PTR [BX + 1], 0    ; x6 & x4 & x2 & x1
        je      THIRD
        cmp     BYTE PTR [BX], 0        ; x6 & x4 & x2 & x1 & ~x0
        je      TRUERES
THIRD:                                  ; ????? ???? ???????
        cmp     BYTE PTR [BX + 7], 0    ; ~x7
        jne     FALSERES
        cmp     BYTE PTR [BX + 6], 0    ; ~x7 & x6
        je      FALSERES
        cmp     BYTE PTR [BX + 3], 0    ; ~x7 & x6 & x3
        je      FALSERES
        cmp     BYTE PTR [BX + 1], 0    ; ~x7 & x6 & x3 & x1
        je      FALSERES
TRUERES:
        mov     FVar, 1                 ; ??????? ??????
        jmp     NZ
FALSERES:
        mov     FVar, 0                 ; ??????? ????
NZ:
        exitcode 0	               
end