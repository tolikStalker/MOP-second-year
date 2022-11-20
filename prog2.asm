        model SMALL			

stack	100h				

        dataseg				
COUNT	dw ?			       
MASS	dw 9, 10, 12, 14, 16, 18, 13, 20, 19, 17
M_SIZE  dw 10

        codeseg			        

        startupcode			

        lea             BX, MASS
        mov             CX, M_SIZE
        mov             AX, 0
BEG:    
        cmp             [BX], 10h
        jle             NO
        inc             AX
NO:
        add             BX, 2
        loop            BEG
        mov             COUNT, AX


QUIT:					
        exitcode 0	               

end			
