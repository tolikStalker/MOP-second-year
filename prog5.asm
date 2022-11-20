	model SMALL 
	dataseg 
Ask             db 0Dh, 0Ah, 'Введете два числа: $' 
errr            db 0Dh, 0Ah, 'Ошибка!$'
erLTwo          db 0Dh, 0Ah, 'Ошибка! Количество операндов меньше 2!$'
divideByZero    db 0Dh, 0Ah, 'Деление на ноль!$'
ResStr          db 0Dh, 0Ah, 'Результат деления: $'
Ten				db 10
firstNum        db 5 dup (0)                 ; Запакованное первое число
SecondNum       db 0                         ; Второе число
UfirstNum		db 10 dup (0)		     	 ; Распакованное первое число
FNumNeg         db 0	                     ; Флаг отрицательности 1 числа
SNumNeg         db 0                         ; Флаг отрицательности 2 числа
INPSTR 			db 80, ?, 82 dup (?) 	     ; Введенная строка
OUTSTR			db ' ', 10 dup(?), 0Dh, 0Ah, '$' ; Вывод
 	codeseg 
 	startupcode
BEGIN: 
	mov             AX, @DATA
	mov             ES, AX 
	
	lea             DX, Ask    
	mov             AH, 09h 
	int             21h
	
	lea             DX, INPSTR  
	mov             AH, 0Ah             
	int             21h 
; ~~~~~~~~~~~~~~~~~Ввод первого числа~~~~~~~~~~~~~~~~~ 
	xor             CX, CX             
	lea             DI, [INPSTR + 2]    
	lea             BX, firstNum
	mov             CL, [INPSTR + 1]    
	xor             DX, DX

	xor             AH, AH            
	mov             AL, ' '             
	repe            scasb              	; Пропуск пробелов
	dec             DI
	cmp             byte ptr [DI], 0dh  
	je              ERROR
	
	mov             AL, '-'             ; Проверка на минус
	scasb
	je              NEGNUM                    
	jmp             AM
NEGNUM:                                 ; Число отрицательно
	mov             FNumNeg, 1          
	inc				DI
	cmp             DI, ' '             
	je              ERROR
AM:
	dec				DI
NEXTSIGN:								; Считывание попарно
	mov             AL, [DI]            ; Первый знак
	cmp             AL, 0dh          
	je              lessTwo                     
	cmp             AL, ' '             
	je              SECOND
	
	inc				DX
	cmp             DX, 10
	jg              ERROR
	sub             AL, '0'            
	cmp             AL, 10            
	ja              ERROR
	inc             DI
	mov             AH, [DI]			; Второй знак
	cmp             AH, 0dh           
	je              lessTwo
	cmp             AH, ' '             
	je              NUMEND
	
	inc				DX		   
	cmp             DX, 10
	jg              ERROR
	sub             AH, '0'             
	cmp             AH, 10         
	ja              ERROR
	shl				AH, 4				; В запакованный BCD
	or				AL, AH
	xor				AH, AH
	xchg            BX, DI
	stosb				    
	xchg            BX, DI
	inc             DI
	jmp            	NEXTSIGN            
NUMEND:
	xor				AH, AH
	xchg            BX, DI
	stosb
	mov  	        DI, BX
	inc             DI
	jmp				SECOND
DBZ:									; Обработка деления на ноль
	lea             DX, divideByZero      
	mov             AH, 09h 
	int             21h
	jmp				BEGIN
ERROR:                                  ; Обработка ошибки
	lea             DX, errr            
	mov             AH, 09h 
	int             21h
	jmp             BEGIN               
SECOND:			; ~~~~~~~~~~~~~~~~~Ввод второго числа~~~~~~~~~~~~~~~~~ 
	xor				AH, AH
	lea             BX, SecondNum
	mov             AL, ' '             
	repe            scasb               ; Пропуск пробелов
	dec             DI
	cmp             byte ptr [DI], 0dh  
	je              lesstwo
	mov             AL, '-'            
	scasb
	je              SNEGNUM                    
	jmp             SAFTERMINUS
lessTwo:
	lea             DX, erLTwo      
	mov             AH, 09h 	    
	int             21h
	jmp             BEGIN
SNEGNUM:                                ; Второе число отрицательно
	mov             SNumNeg, 1          
	inc				DI
	cmp             DI, ' '             
	je              ERROR
SAFTERMINUS:
	dec             DI
	mov             AL, [DI]        
	sub             AL, '0'         
	cmp             AL, 10          
	ja              ERROR
	xchg			DI, BX
	stosb
	xchg			DI, BX
	inc				DI
	mov             AL, ' '             
	repe            scasb               ; Пропуск пробелов
	dec				DI
	cmp             byte ptr [DI], 0dh  
	jne             ERROR		    	; Если не конец строки - ошибка

	cmp             SecondNum, 0
	je              DBZ
; ~~~~~~~~~~~~~~~~~Распаковка первого числа~~~~~~~~~~~~~~~~~
	lea             DI, UfirstNum
	lea             SI, firstNum 
	mov				CX, DX
cycl: 
	lodsb 				    
	mov				AH, AL
	shr				AH, 4
	and				AL, 0Fh
	stosw
	cmp				CX, 1
	jg				DC
	jmp				NXT
DC:
	dec				CX
NXT:
	loop            cycl
	
	mov				AL, FNumNeg
	xor				AL, SNumNeg
	cmp				AL, 1
	je				NEGRES
	jmp				DIVIS
NEGRES:
	mov				[OUTSTR], '-'
DIVIS:
; ~~~~~~~~~~~~~~~~~Деление~~~~~~~~~~~~~~~~~
	lea     		SI, UFirstNum
	lea				DI, [OUTSTR+1]
	mov				CX, DX
	xor				BL, BL
DIVISION:	
	lodsb	
	add				AL, BL
	xor				AH, AH
	aad	
	div				SecondNum
	mov				BL, AH
	add				AL, '0'
	stosb		
	mov				AL, BL
	mul				Ten
	mov				BL, AL
	loop			DIVISION
; ~~~~~~~~~~~~~~~~~Вывод~~~~~~~~~~~~~~~~~
	lea         	DX, ResStr     
	mov         	AH, 09h 
	int         	21h
 	lea 			DX, OUTSTR 
 	mov 			AH, 09h 
	int 			21h
QUIT: 
	exitcode 0 
	end 