; Вариант 3 (Ахметьянов Арслан Рашидович, БПИ 192)
;         Разработать программу, решающую вопрос - являются ли пять заданных чисел взаимно
;         простыми (числа задать машинными словами без знака).
format PE console

entry Start

        include 'win32a.inc'

section '.data' data readable writable

        ; Хранение чисел
        array rw 5

        ; Нахождение общего делителя
        num1 du 0
        num2 du 0
        divider du 1

        ; Результат обнаружения общего делителя - 0, если нашелся делитель, отличный от единичного
        coprime dw 1

        ; Промежуточное хранение данных
        temp dd ?
        temp2 dd ?

        ; Хранение значения ecx для циклов
        innerCycle dd 1
        ecxStorage dd ?

        ; Хранение состояния стека
        espStorage dd ?
        coprimeEspStorage dd ?
        innerEspStorage dd ?

        ; Ввод чисел
        numIn db 'Enter positive number %d: ', 0
        elemOutputUshort db 'Elem [%d] = %hu', 10, 0
        ushort db '%hu', 0
        failureMessage db 'Entered number is equivalent to 0!', 10, 0

        ; Вывод информации о вводе
        arrayInfoString db 'Entered %d elements:', 10, 0


        ; Результат работы программы
        notCoprime db 'Numbers are not coprime: two elements are %hu and %hu; common divider = %hu!', 10, 0
        successStr db 'Every pair of numbers is coprime!', 10, 0

        ; Ограничения значения делителя меньшим из рассматриваемых чисел
        upperLimit du ?

        NULL = 0

section '.code' code readable executable

        ; Подпрограмма ввода массива с клавиатуры
        ArrayInput:
                mov [espStorage], esp
                mov ebx, array          ; ebx = &array
                mov ecx, 5

                getVecLoop:
                        mov [temp], ebx
                        mov [ecxStorage], ecx

                        ; Подсчет индекса вводимого элемента
                        mov eax, 5
                        sub eax, [ecxStorage]
                        mov [temp2], eax

                elemInput:
                        push [temp2]
                        push numIn
                        call [printf]

                        ; Ввод элемента
                        push ebx
                        push ushort
                        call [scanf]

                        ; Проверка на положительность введенного числа - если положительно, читаем следующее
                        cmp dword [ebx], 0
                        jg correctInput

                failedInput:
                        push failureMessage
                        call [printf]
                        jmp elemInput

                correctInput:
                        mov ecx, [ecxStorage]

                        ; Переход к следующему элементу
                        mov ebx, [temp]
                        add ebx, 2
                        loop getVecLoop

                inputEnd:
                        mov esp, [espStorage]
                        ret

        ; Подпрограмма вывода введенных чисел массива
        ArrayOutput:
                mov [espStorage], esp

                push 5
                push arrayInfoString
                call [printf]

                mov ecx, 5
                mov ebx, array ;ebx = &array
                printLoop:

                        mov [temp], ebx
                        mov [ecxStorage], ecx

                        ; Подсчет индекса выводимого элемента
                        mov eax, 5
                        sub eax, [ecxStorage]
                        mov [temp2], eax

                        ; Вывод элемента
                        push word [ebx]
                        push [temp2]
                        push elemOutputUshort
                        call [printf]

                        ; Переход к следующему элементу
                        mov ebx, [temp]
                        add ebx, 2

                        mov ecx, [ecxStorage]
                        loop printLoop

                outputEnd:
                        mov esp, [espStorage]
                        ret

        ; Подпрограмма, ограничиващая возможный делитель меньшим из чисел
        DefineUpperDividerLimit:
                xor ebx, ebx
                xor eax, eax

                mov bx, [num1]
                mov ax, [num2]
                cmp bx, ax
                ja num2Limit

                ; Если [num1] меньше или равен [num2], то в upperLimit записывается [num1]
                xor ebx, ebx
                mov bx, [num1]
                jmp limitFinish

                num2Limit:
                        ; Если [num2] меньше [num1], то в upperLimit записывается [num2]
                        xor ebx, ebx
                        mov bx, [num2]

                limitFinish:
                        mov [upperLimit], bx
                        ;mov esp, [eaxDebug]
                        ret


        ; Подпрограмма, проверяющая, являются ли два числа взаимно простыми
        TwoIfCoprime:
                mov [coprimeEspStorage], esp
                mov [divider], 1

                        ; Расчет ограничения делителя
                        call DefineUpperDividerLimit

                dividerLoop:
                        inc [divider]

                        ; Если потенциальный делитель больше максимально возможного значения общего делителя -
                        ; числа взаимно просты
                        xor ebx, ebx
                        mov bx, [divider]
                        cmp bx, [upperLimit]
                        ja dividerExit

                        xor eax, eax
                        xor edx, edx

                        mov ax, [num1]
                        div [divider]

                        ; Если первое число не делится на делитель - переходим к следующему делителю
                        cmp dx, 0
                        jg dividerLoop

                        xor eax, eax
                        xor edx, edx

                        mov ax, [num2]
                        div [divider]

                        ;  Если первое число делится на делитель, но не второе - переходим к следующему делителю
                        cmp dx, 0
                        jg dividerLoop

                        ; Иначе записываем в [coprime], что нашлась пара не взаимно простых чисел
                        mov [coprime], 0

                        ; Выводим информацию об этой паре и выходим
                        push dword [divider]
                        push dword [num2]
                        push dword [num1]
                        push notCoprime
                        call [printf]

                        jmp dividerExit

                dividerExit:
                        mov esp, [coprimeEspStorage]
                        ret

        ; Подпрограмма, проверяющая, есть ли среди чисел пара не взаимно простых (внешний цикл)
        CoprimeCheck:
                mov [espStorage], esp

                mov ebx, array    ; ebx = &array
                mov [temp], ebx

                ; Итерируемся по элементам с 0 по 4 - сохраняем количество итераций в ecx
                mov ecx, 4
                mov [ecxStorage], ecx

                goPrimeCheck:
                        ; Сохраняем в num1 первый рассматриваемый элемент
                        mov ebx, [temp]
                        mov dx, [ebx]
                        mov [num1], dx

                        ; Переводим ebx - теперь он указывает на следующий элемент массива
                        add ebx, 2
                        mov [temp], ebx
                        mov [temp2], ebx

                        ; Сохраняем значение ecx для внешнего цикла
                        mov [ecxStorage], ecx

                        ; Запускаем внутренний цикл - начиная со следующего после [num1] элемента
                        ; Заметим, что потребуется ровно ecx итераций: если в ecx лежит х, то рассмотрено 5 - x элементов (считая текущий рассмотренным)
                        ; Значит, останется x элементов, которые нуно поставить в пару к текущему
                        call InnerLoop

                        ; Если в InnerLoop не нашлось пары не взаимно простых чисел, то продолжаем цикл - переходим к следющему num1
                        mov ecx, [ecxStorage]
                        loop goPrimeCheck

                fiveCoprimeCheckFinish:

                          mov esp, [espStorage]
                          ret

         ; Подпрограмма, проверяющая, есть ли среди чисел пара не взаимно простых (внутренний цикл)
        InnerLoop:
                mov [innerEspStorage], esp

                ; Сохраняем значение ecx для внутреннего цикла
                mov [innerCycle], ecx

                inner:

                        ; Сохраняем в num2 второй рассматриваемый элемент
                        mov ebx, [temp2]
                        mov dx, [ebx]
                        mov [num2], dx

                        ; Проверям, являются ли они взаимно простыми
                        call TwoIfCoprime

                        ; Если значение 0 - нашлась пара не взаимно простых, завершаем работу программы
                        cmp [coprime], 0
                        je fiveCoprimeCheckFinish

                        ; Переходим к следующему рассматриваемому элементу, пишем его в num2
                        mov ebx, [temp2]
                        add ebx, 2

                        mov [temp2], ebx
                        mov dx, [ebx]
                        mov [num2], dx

                        ; Продолжаем, пока не переберем все num2, что не рассматривались в паре с текущим num1 (зафиксирован во внешнем цикле)
                        loop inner

                ; Если взаимно не простая пара не нашлась, возвращаемся во внешний цикт
                mov esp, [innerEspStorage]
                ret

        Start:

                ; Считали массив
                call ArrayInput

                ; Вывели массив
                call ArrayOutput

                ; Проверили, есть ли среди 5 чисел пара не взаимно простых
                call CoprimeCheck

                ; Если [coprime] = 0, то пара не взаимно простых нашлась => была выведена, завершаем работу
                cmp [coprime], 0
                je finish

                ; Иначе выводим сообщение, что все числа попарно взаимно просты
                successFinish:
                        push successStr
                        call [printf]

                finish:

                        call [getch]

                        push NULL
                        call [ExitProcess]

section '.import' import data readable

        library kernel, 'kernel32.dll',\
                msvcrt, 'msvcrt.dll'

        import kernel,\
               ExitProcess, 'ExitProcess'

        import msvcrt,\
               printf, 'printf',\
               scanf, 'scanf',\
               getch, '_getch'