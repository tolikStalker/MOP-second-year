        model SMALL			; memory model

stack	100h				; stack size: 256 bytes

        dataseg				; define data segment
A		dw -29			; define 4x 2 byte variables
B		dw 2
C		dw 37
X		dw ?			; result

        codeseg			        ; Laboratory task 1, 4th variant
START:					; beginning of program execution
        startupcode			; address of dataseg beginning

        mov		AX, A		; AX = A
        sal		AX, 3		; AX = 8A
        sub		AX, A		; AX = 7A
        mov		BX, B		; BX = B
        sal		BX, 1		; BX = 2B
        sub		AX, BX	        ; AX = 7A - 2B
        sub		AX, 100	        ; AX = 7A - 2B - 100
        sar		AX, 1		; AX = (7A - 2B - 100) / 2
        add		AX, C		; AX = (7A - 2B - 100) / 2 + C
        mov		X, AX		; X = (7A - 2B - 100) / 2 + C

QUIT:					; end of program
        exitcode 0	                ; return control to OS, return code 0dsgdfv fsf

end				        ; program end mark
