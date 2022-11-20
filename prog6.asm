	locals __
	model SMALL 
stack		100h
	dataseg 
MESS1		db 0dh, 0ah, '������ ��ப�:', 0dh, 0ah, '$' 
MAXSTRSIZE	db 18			; ���ᨬ���� ࠧ��� ��ப�
CURSTRSIZE	db ?			; ����騩 ࠧ��� ��ப�
INPSTR		db 18 dup (?)
ALLSIZE		db 20			; ����� ࠧ��� ��ப�
srt			db '�����஢���� ��ப�: ', 0dh, 0ah
buf			db 1000 dup (?), '$'
 	codeseg 
 	startupcode
	mov         AX, @DATA
	mov         ES, AX 
	mov         DS, AX 
	xor			BX, BX			; ���稪 ��ப
MLOOP:
	lea 		DX, MESS1 
 	mov 		AH, 09h 
	int 		21h 			; �ਣ��襭�� � ����� ��ப�
	
	lea 		DX, MAXSTRSIZE 
 	mov 		AH, 0Ah
 	int 		21h 			; ���� ��ப�
	xor			AH, AH
 	cmp 		[CURSTRSIZE], 0	; ��ப� �����? 
	je 			LLL0			; �� - �뢮�
	xor			CH, CH
	mov			CL, CURSTRSIZE
	mov			AL, ALLSIZE
	mul			BX
	lea			DX, [buf]
	add			DX, AX
	mov			DI, DX
	lea			SI, [INPSTR]
	call		StrSwap			; ������ ��ப� � �����
	inc			BX
	lea			DI, [buf]
	mov			AL, ALLSIZE
	mul			BX
	add			DI, AX
	dec			DI
	mov			BYTE ptr [DI], 0ah
	dec			DI
	mov			BYTE ptr [DI], 0dh
	cmp			BX, 1			; ������� ���� ��ப�
	je			MLOOP
	mov			CX, BX
	dec			CX
	xor			AH, AH
compare:						; ���� �� �������� ��ப
	mov			DX, CX
	push		CX
	mov			AL, ALLSIZE
	mul			DX
	lea			SI, [buf]
	add			SI, AX
	mov			DX, CX
	dec			DX
	mov			CL, MAXSTRSIZE
	mov			AL, ALLSIZE
	mul			DX
	lea			DI, [buf]
	add			DI, AX
	push		DI
	push		SI
	call		StrCompare 
	pop			SI				
	pop			DI
	cmp			AX, 0			; ��ப� �� ��������
	je			ClStack
	mov			CL, MAXSTRSIZE
	call		StrSwap			; ����஢��
	pop			CX
	loop		compare
	jmp			MLOOP
ClStack:
	pop			CX
	jmp			MLOOP
LLL0:
	lea 		DX, srt 
 	mov 		AH, 09h 
	int 		21h 
	exitcode 0 
	 
; ����ணࠬ�� �ࠢ����� ���� ��ப
StrCompare proc near 
	repe		cmpsb
	dec			DI
	dec			SI
	cmpsb
	jl			__change
	cmpsb
	je			__endProg
	dec			DI
	cmp			DI, '$'
	je			__change
	jmp			__endProg
__change:
	mov			AX, 1
	ret
__endProg:
	mov			AX, 0
	ret 
StrCompare endp

; ����ணࠬ�� ���������� ���祭�� ���� ��ப
StrSwap proc near 
__lp:
	mov 		AH, BYTE ptr [DI]
	mov			AL, BYTE ptr [SI]
	stosb	
	mov 		BYTE ptr [SI], AH
	inc			SI
	loop 		__lp
	ret
StrSwap endp
	end 