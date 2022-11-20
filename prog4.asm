        model SMALL 
        dataseg 
TEN             db 10                        ; ����⠭� 10
Ask             db 0Dh, 0Ah, '������ ��ப�: $' 
errr             db 0Dh, 0Ah, '�訡��!$'
firstNum        dw ?                         ; ��ࢮ� �᫮ � ��ப�
count           db 0                         ; ���稪 �ᥫ, ������ ��ࢮ��
NumNeg          db 0                         ; ���� ����⥫쭮��
INPSTR 		db 80, ?, 82 dup (?) 	     ; ����. ���-�� �ᥫ, 
                                             ; ��������� ���-�� �ᥫ, ��������� ��ப�
 	codeseg 
 	startupcode
BEGIN: 
        mov             AX, @DATA           ; ������� � ॣ���� AX ᬥ饭�� dataseg
        mov             ES, AX              ; ������� � ॣ���� ES ᬥ饭�� dataseg

        lea             DX, Ask             ; �뢮� ᮮ�饭��
        mov             AH, 09h 
        int             21h

        lea             DX, INPSTR          ; ���� ��ப�
        mov             AH, 0Ah             ; ���� � ����� �� ������ Enter
        int             21h                     
        
        xor             AX, AX              ; ����塞 ॣ���� AX
        xor             CX, CX              ; ����塞 ॣ���� CX
        lea             DI, [INPSTR + 2]    ; � DI - ��砫� ᥣ���� ��ப�
        mov             CL, [INPSTR + 1]    ; � CL - 䠪��᪠� ����� ��ப�
        mov             AL, ' '             ; ����塞 ॣ���� ��
        repe            scasb               ; �ய�� �஡����
        mov             AL, '-'             ; �᫨ ����� ��। �᫮�, � ��� ����⥫쭮
        dec             DI
        
        scasb
        je              FNEG                    
        jmp             AFTERM
FNEG:                                       ; ��ࢮ� �᫮ ����⥫쭮
        mov             NumNeg, 1           ; ��⠭����� 䫠� ����⥫쭮��
        mov             AL, ' '             ; �᫨ ��᫥ ����� �஡�� - �訡��
        scasb
        je              ERROR
AFTERM:
        xor             AX, AX              ; ����塞 ॣ���� AX
        dec             DI
FNEXT:
        mov             DL, [DI]            ; � DL ����頥� ᨬ��� ��ப�
        cmp             DL, 0dh             ; �᫨ ������� ���� �᫮ - ���室 �����
        je              OFN                     
        cmp             DL, ' '             ; ��᫮ �����稫��� - ��३� � �����
        je              FNDIGIT
    
        xor             DH, DH              ; ����塞 ॣ���� DH
        sub             DL, '0'             ; ��ॢ���� ���� �� ��ப� � �᫮
        cmp             DL, 10              ; �᫨ ᨬ��� �� ��� - �訡��
        ja              ERROR
        mov             BX, DX              ; ������� � BX ॣ���� DX
        mul             TEN                 ; �������� ���祭�� � AX �� 10
        add             AX, BX              ; ������塞 ���祭�� ॣ���� BX � AX
        jmp             FZEQ
FNDIGIT:                                    ; ������ �᫠ � ��६�����
        mov             firstNum, AX            
        jmp             ENDFIRST
FZEQ:
        inc             DI
        jmp            FNEXT                ; ��३� � ᫥���饩 ���
ENDFIRST:                                   ; ��ࢮ� �᫮ �����稫���
        cmp             NumNeg, 1           ; �஢�ઠ �� ���� �᫠
        je              FN                      
        jmp             OFN                 ; ��ࢮ� �᫮ ������⥫쭮
ERROR:                                      ; ��ࠡ�⪠ �訡��
        lea             DX, errr             ; �뢮� ᮮ�饭��
        mov             AH, 09h 
        int             21h
        jmp             BEGIN               ; ���室 � ��砫�
FN:
        neg             firstNum            ; ��ࢮ� �᫮ ����⥫쭮
OFN:                                        ; ��ࠡ�⪠ ��᫥����� ᨬ�����
        mov             NumNeg, 0           ; ����塞 䫠� ����⥫쭮��
        xor             AX, AX              ; ����塞 ॣ���� AX
        mov             AL, ' '             ; �ய�� �஡����
        repe            scasb                 
        je              QUIT                ; �஬� �஡���� ��祣� ��� - ���
        dec             DI
        cmp             byte ptr [DI], 0dh  ; �᫨ ����� ��ப� - ���
        je              QUIT
        mov             AL, '-'             ; �᫨ ����� ��। �᫮�, � ��� ����⥫쭮
        scasb
        je              ONEG
        jmp             AFM
ONEG:                                       ; ��᫮ ����⥫쭮
        mov             NumNeg, 1           ; ��⠭����� 䫠� ����⥫쭮��
        mov             AL, ' '             ; �᫨ ��᫥ ����� �஡�� - �訡��
        scasb
        je              ERROR
AFM:
        xor             AX, AX              ; ���㫨�� ॣ���� AX
        dec             DI
NEXT:
        mov             DL, [DI]            ; � DL ����頥� ᨬ��� ��ப�
        cmp             DL, ' '             ; ��᫮ �����稫��� - ��३� � �����
        je              OEND                  
        cmp             DL, 0dh             ; ��ப� �����稫��� - ��३� � �����
        je              OEND
    
        xor             DH, DH              ; ����塞 ॣ���� DH
        sub             DL, '0'             ; ��ॢ���� ���� �� ��ப� � �᫮
        cmp             DL, 10              ; �᫨ ᨬ��� �� ��� - �訡��
        ja              ERROR
        mov             BX, DX              ; ������� � BX ॣ���� DX
        mul             TEN                 ; �������� ���祭�� � AX �� 10
        add             AX, BX              ; ������塞 ���祭�� ॣ���� BX � AX
        jmp             ZEQ
ZEQ:
        inc             DI
        jmp             NEXT                ; ���室 � ᫥���饩 ���
OEND:                                       ; �஢�ઠ �� ���� �᫠
        cmp             NumNeg, 1           ; �஢�ઠ �� ���� �᫠
        je              NEGATIVE                      
        jmp             CHECKGR             ; ��᫮ ������⥫쭮
NEGATIVE:                                   ; ��᫮ ����⥫쭮
        neg             AX                
CHECKGR:
        cmp             firstNum, AX        ; �᫨ �᫮ ����� ��ࢮ�� - �ਡ����� ���稪
        jge             OFN
        inc             count
        jmp             OFN                 ; ���室 � ᫥���饬� ���
QUIT: 
     exitcode 0 
        end 