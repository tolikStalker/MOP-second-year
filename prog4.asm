        model SMALL 
        dataseg 
TEN             db 10                        ; Константа 10
Ask             db 0Dh, 0Ah, 'Введите строку: $' 
errr             db 0Dh, 0Ah, 'Ошибка!$'
firstNum        dw ?                         ; Первое число в строке
count           db 0                         ; Счетчик чисел, больших первого
NumNeg          db 0                         ; Флаг отрицательности
INPSTR 		db 80, ?, 82 dup (?) 	     ; Макс. кол-во чисел, 
                                             ; введенное кол-во чисел, введенная строка
 	codeseg 
 	startupcode
BEGIN: 
        mov             AX, @DATA           ; Записать в регистр AX смещение dataseg
        mov             ES, AX              ; Записать в регистр ES смещение dataseg

        lea             DX, Ask             ; Вывод сообщения
        mov             AH, 09h 
        int             21h

        lea             DX, INPSTR          ; Ввод строки
        mov             AH, 0Ah             ; Ввод в буффер до клавиши Enter
        int             21h                     
        
        xor             AX, AX              ; Обнуляем регистр AX
        xor             CX, CX              ; Обнуляем регистр CX
        lea             DI, [INPSTR + 2]    ; В DI - начало сегмента строки
        mov             CL, [INPSTR + 1]    ; В CL - фактическая длина строки
        mov             AL, ' '             ; Обнуляем регистр АХ
        repe            scasb               ; Пропуск пробелов
        mov             AL, '-'             ; Если минус перед числом, то оно оприцательно
        dec             DI
        
        scasb
        je              FNEG                    
        jmp             AFTERM
FNEG:                                       ; Первое число отрицательно
        mov             NumNeg, 1           ; Установить флаг отрицательности
        mov             AL, ' '             ; Если после минуса пробел - ошибка
        scasb
        je              ERROR
AFTERM:
        xor             AX, AX              ; Обнуляем регистр AX
        dec             DI
FNEXT:
        mov             DL, [DI]            ; В DL помещаем символ строки
        cmp             DL, 0dh             ; Если введено одно число - переход далее
        je              OFN                     
        cmp             DL, ' '             ; Число закончилось - перейти к записи
        je              FNDIGIT
    
        xor             DH, DH              ; Обнуляем регистр DH
        sub             DL, '0'             ; Переводим цифру из строки в число
        cmp             DL, 10              ; Если символ не цифра - ошибка
        ja              ERROR
        mov             BX, DX              ; Записать в BX регистр DX
        mul             TEN                 ; Умножаем значение в AX на 10
        add             AX, BX              ; Добавляем значение регистра BX в AX
        jmp             FZEQ
FNDIGIT:                                    ; Запись числа в переменную
        mov             firstNum, AX            
        jmp             ENDFIRST
FZEQ:
        inc             DI
        jmp            FNEXT                ; Перейти к следующей цифре
ENDFIRST:                                   ; Первое число закончилось
        cmp             NumNeg, 1           ; Проверка на знак числа
        je              FN                      
        jmp             OFN                 ; Первое число положительно
ERROR:                                      ; Обработка ошибки
        lea             DX, errr             ; Вывод сообщения
        mov             AH, 09h 
        int             21h
        jmp             BEGIN               ; Переход в начало
FN:
        neg             firstNum            ; Первое число отрицательно
OFN:                                        ; Обработка последующих символов
        mov             NumNeg, 0           ; Обнуляем флаг отрицательности
        xor             AX, AX              ; Обнуляем регистр AX
        mov             AL, ' '             ; Пропуск пробелов
        repe            scasb                 
        je              QUIT                ; Кроме пробелов ничего нет - выйти
        dec             DI
        cmp             byte ptr [DI], 0dh  ; Если конец строки - выйти
        je              QUIT
        mov             AL, '-'             ; Если минус перед числом, то оно оприцательно
        scasb
        je              ONEG
        jmp             AFM
ONEG:                                       ; Число отрицательно
        mov             NumNeg, 1           ; Установить флаг отрицательности
        mov             AL, ' '             ; Если после минуса пробел - ошибка
        scasb
        je              ERROR
AFM:
        xor             AX, AX              ; Обнулить регистр AX
        dec             DI
NEXT:
        mov             DL, [DI]            ; В DL помещаем символ строки
        cmp             DL, ' '             ; Число закончилось - перейти к записи
        je              OEND                  
        cmp             DL, 0dh             ; Строка закончилось - перейти к записи
        je              OEND
    
        xor             DH, DH              ; Обнуляем регистр DH
        sub             DL, '0'             ; Переводим цифру из строки в число
        cmp             DL, 10              ; Если символ не цифра - ошибка
        ja              ERROR
        mov             BX, DX              ; Записать в BX регистр DX
        mul             TEN                 ; Умножаем значение в AX на 10
        add             AX, BX              ; Добавляем значение регистра BX в AX
        jmp             ZEQ
ZEQ:
        inc             DI
        jmp             NEXT                ; Переход к следующей цифре
OEND:                                       ; Проверка на знак числа
        cmp             NumNeg, 1           ; Проверка на знак числа
        je              NEGATIVE                      
        jmp             CHECKGR             ; Число положительно
NEGATIVE:                                   ; Число отрицательно
        neg             AX                
CHECKGR:
        cmp             firstNum, AX        ; Если число больше первого - прибавить счетчик
        jge             OFN
        inc             count
        jmp             OFN                 ; Переход к следующему числу
QUIT: 
     exitcode 0 
        end 