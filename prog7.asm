	model small 
	.486
stack 100h 
	.data 
enterA 		db 0Ah, 0Dh, 'Введите a: $' 
string		db 20, ?, 20 dup (?)
enterB 		db 0Ah, 0Dh, 'Введите b: $' 
enterE 		db 0Ah, 0Dh, 'Введите e: $'
aGreaterB 	db 0Ah, 0Dh, 'a должно быть меньше b!$' 
eqSign		db 0Ah, 0Dh, 'Функция не меняет знак на [a, b]$'
varA		dd ?
midAB		dd ?
varB		dd ?
varE		dd ?
leftF		dd ?
rightF		dd ?
eight		dd 8.0
forthyTwo	dd 42.0
two			dd 2.0
rsl 		db 0Ah, 0Dh, 'Корень уравнения: '
resStr		db 20 dup (?)
ext 		db 0Ah, 0Dh, 'Выход - Esc, продолжить - любая другая клавиша...$'
	.code 
 	startupcode 
 	finit 
_begin: 
 	lea 		dx, enterA
 	jmp 		_wrtk 
_err:
	lea 		dx, aGreaterB 
 	mov 		ah, 09h 
 	int 		21h 
	jmp			_begin
_eqS:
	lea 		dx, eqSign 
 	mov 		ah, 09h 
 	int 		21h 
	jmp			_begin
_wrtk: 
	mov 		ah, 09h 
 	int 		21h 
 	lea 		dx, string
 	mov 		ah, 0ah 
 	int 		21h 
	push 		offset varA 
 	push 		offset string + 2
 	call 		StrToDouble 
 	add 		sp, 2 
 	lea 		dx, enterB 
 	mov 		ah, 09h 
 	int 		21h 
	lea			dx, string
 	mov 		ah, 0ah 
 	int 		21h 
 	push 		offset varB 
 	push 		offset string + 2
 	call 		StrToDouble 
 	add 		sp, 2 
	FLD			varA	; проверка, что а < b
	FCOMP		varB
	FSTSW		ax
	SAHF
	jae			_err
	lea 		dx, enterE
 	mov 		ah, 09h 
 	int 		21h 
	lea			dx, string
 	mov 		ah, 0ah 
 	int 		21h 
	push 		offset varE
 	push 		offset string + 2 
 	call 		StrToDouble 
 	add 		sp, 2 
;code
	fld			varA
	fld			varA
	fld			varA
	fld			varA
	fld			varA
	fld			varA
	call		CalcFunc
	fstp		leftF
	fld			varB
	fld			varB
	fld			varB
	fld			varB
	fld			varB
	fld			varB
	call		CalcFunc
	fstp		rightF
	cmp			leftF, 0
	je			funcLFound
	cmp			rightF, 0
	je			funcRFound
	mov			ah, byte ptr [leftF + 3]
	xor			ah, byte ptr [rightF + 3]
	test		ah, 80h
	je			_eqS
_lp:
	fld			varB
	fld			varA
	fsubp		st(1)
	fcom		varE
	FSTSW		ax
	sahf
	jb			_midF
	fld			two
	fdiv
	fld			varA
	faddp
	fst			midAB
	fld			varA
	fld			varA
	fld			varA
	fld			varA
	fld			varA
	fld			varA
	call		CalcFunc
	fstp		leftF
	fld			midAB
	fld			midAB
	fld			midAB
	fld			midAB
	fld			midAB
	fld			midAB
	call		CalcFunc
	fstp		rightF
	mov			ah, byte ptr [leftF + 3]
	xor			ah, byte ptr [rightF + 3]
	test		ah, 80h
	je			_eq
	fstp		varB
	jmp			_lp
_eq:
	fstp		varA
	jmp			_lp
_midF: 
	push 		offset resStr
 	push 		offset midAB
	jmp			_write
funcRFound:
	push 		offset resStr
 	push 		offset varB
	jmp			_write
funcLFound:
	push 		offset resStr
 	push 		offset varA
_write:
 	call 		DoubleToStr 
 	add 		sp, 2 
 	lea 		dx, rsl 
	mov 		ah, 09h 
 	int 		21h 
 	lea 		dx, ext 
 	mov 		ah, 09h 
 	int 		21h 
 	mov 		ah, 08h 
 	int 		21h 
 	cmp 		al, 27 
 	jnz 		_begin
 	exitcode 0 

CalcFunc proc near
arg @@vr:dword
	fmul 		
	fxch		st(3)
	fmul
	fmul
	fld			eight
	fmulp		st(2)
	faddp		st(1), st
	faddp		st(1), st
	fld			forthyTwo
	fsubp		st(1)
	ret
CalcFunc endp

DoubleToStr proc near 
 	push 		bp 
	mov 		bp, sp 
 	sub 		sp, 4 			
	push 		ax bx dx cx di 
	pushf 
	fnstcw 		[bp-4] 			
	fnstcw 		[bp-2] 
 	and 		word ptr [bp - 2], 1111001111111111b
 	or 			word ptr [bp - 2], 0000110000000000b
 	fldcw 		[bp - 2] 		
	mov 		bx, [bp + 4] 
 	fld 		dword ptr[bx] 
	ftst 
 	fstsw 		ax 
 	and 		ah, 1 
 	cmp 		ah, 1 
 	jne 		@@NBE 
 	mov 		bx, [bp + 6] 
 	mov 		byte ptr[bx], '-' 
 	inc 		word ptr[bp + 6] 
@@NBE: 
	fabs 
 	fst 		st(1) 
 	fst 		st(2) 
 	frndint 
 	fsub 		st(2), st(0) 
 	mov 		word ptr[bp - 2], 10 
 	fild 		word ptr[bp - 2] 
 	fxch 		st(1) 
 	xor 		cx, cx 
@@BG: 
	fprem 
 	fist 		word ptr [bp - 2] 
 	push 		word ptr [bp - 2] 
 	fxch 		st(2) 
 	fdiv 		st(0), st(1) 
 	frndint 
 	fst 		st(2) 
 	inc 		cx 
 	ftst 				
 	fstsw 		ax 		
 	sahf 				
 	jnz 		@@BG 	
 	mov 		ax, cx 
 	mov 		bx, [bp + 6] 
@@BFG: 
	pop 		dx 
 	add 		dx, '0' 
 	mov 		byte ptr[bx], dl 
 	inc 		bx 
 	loop 		@@BFG 
 	fxch 		st(3) 
 	fst 		st(2) 
 	ftst 
 	fstsw 		ax 
 	sahf 
 	jz 			@@CNE 
 	mov 		byte ptr[bx], '.' 
 	mov 		cx, 16 
@@BFR: 
	fmul 		st(0), st(1) 
 	fst 		st(2) 
 	frndint 
 	fsub 		st(2), st(0) 
 	fist 		word ptr [bp - 2] 
 	fxch 		st(2) 
 	mov 		ax, [bp - 2] 
 	add 		ax, '0' 
 	inc 		bx 
 	mov 		byte ptr[bx], al 
 	loop 		@@BFR 
@@NIL: 
	cmp 		byte ptr[bx], '0' 
 	jne 		@@CNR 
 	dec 		bx 
 	jmp 		@@NIL 
@@CNR: 
	inc 		bx 
@@CNE: 
	mov 		byte ptr[bx], '$' 
 	fstp 		st(0) 
 	fstp 		st(0) 
 	fstp 		st(0) 
	fstp 		st(0) 
 	fldcw 		[bp - 4] 
	popf 
 	pop 		di cx dx bx ax 
 	add 		sp, 4 
 	pop 		bp 
 	ret 
DoubleToStr endp

StrToDouble proc near 
 	push 		bp 
 	mov 		bp, sp 
	sub 		sp, 2
	push 		ax bx dx cx di 
	pushf 
	mov 		word ptr[bp - 2], 10 	
	fild 		word ptr[bp - 2] 	
	fldz 								
	mov 		di, 0 
	mov 		bx, [bp + 4] 
	cmp 		byte ptr[bx], '-' 
	jne 		@@BPN 
	inc 		bx 
	mov 		di, 1 
@@BPN: 
	movsx 		ax, byte ptr [bx] 
 	cmp 		ax, '.' 
 	je 			@@PNT1 
 	cmp 		ax, 0dh 
 	jne 		@@CNT 
 	fxch 		st(1) 
 	fstp 		st(0) 
 	jmp 		@@REN 
@@CNT: 	
	sub 		ax, '0' 
	mov 		word ptr[bp - 2], ax 
 	fmul 		st(0), st(1) 
 	fiadd 		word ptr[bp - 2] 
	inc 		bx 
 	jmp 		@@BPN 
@@PNT1: 
 	xor 		cx, cx 
@@BEG: 
	inc 		bx 
 	movsx 		ax, byte ptr [bx] 
 	cmp 		ax, 0dh 
 	je 			@@END 
 	loop 		@@BEG 
@@END: 
	dec 		bx 
 	fxch 		st(1) 
 	fldz 
@@APN: 
	movsx 		ax, [bx] 
 	cmp 		ax, '.' 
 	je 			@@PNT2 
 	sub 		ax, '0' 
 	mov 		word ptr[bp - 2], ax 
 	fiadd 		word ptr[bp - 2] 
 	fdiv 		st(0), st(1) 
 	dec 		bx 
 	jmp 		@@APN 
@@PNT2: 
 	fxch 		st(1)
 	fstp 		st(0) 
 	faddp 		st(1) 
@@REN: 
 	cmp 		di, 1 
 	jne 		@@CYK 
 	fchs 
@@CYK: 
	mov 		bx, [bp + 6] 
 	fstp 		dword ptr [bx] 
	popf 
 	pop 		di cx dx bx ax 
 	add 		sp, 2 
 	pop 		bp 
 	ret 
StrToDouble endp 
	end