; Вариант 3 (Ахметьянов Арслан Рашидович, БПИ 192)
; Разработать программу, которая вводит одномерный массив A[N], формирует из элементов массива A новый массив B по правилам, указанным в таблице, и выводит его. Память под массивы может выделяться как статически, так и динамически по выбору разработчика.
; Разбить решение задачи на функции следующим образом:
;  1. Ввод и вывод массивов оформить как подпрограммы.
;  2. Выполнение задания по варианту оформить как процедуру
;  3. Организовать вывод как исходного, так и сформированного массивов
; Указанные процедуры могут использовать данные напрямую (имитация процедур без параметров). Имитация работы с параметрами также допустима.
; ВАРИАНТ 3: массив сумм соседних элементов A: ({A[0] + A[1], A[1] + A[2], ...}).
format PE console

entry Start

        include 'win32a.inc'

section '.data' data readable writable


        N dd ?
        newN dd ?
        tmp dd ?
        array rd 100
        newArray rd 100
        counter dd 0

        elemNum db 'Enter number of elements: ', 0
        incorSize db 'Incorrect size of vector = %d; should be in [1, 100].', 10, 0
        emptyResult db 'Empty result: [] - default array was too small.', 10, 0
        oldArrayString db 'Original array consists of %d elements:', 10, 0
        resultString db 'Resulting array consists of %d elements:', 10, 0
        numIn db 'Enter element number %d: ', 0
        elemOutput db 'Elem [%d] = %d', 10, 0
        digitFormat db '%d', 0

        NULL = 0

section '.code' code readable executable

        ; Подпрограмма ввода массива с клавиатуры
        ArrayInput:
                push elemNum
                call [printf]
                add esp, 4 ;stack upd

                push N
                push digitFormat
                call [scanf]
                add esp, 8 ;stack upd

                ; Проверка на положительную длину массива
                mov eax, [N]
                mov [newN], eax
                cmp eax, 0
                jle sizeFailure

                ; Проверка на положительную длину массива <= 100
                cmp eax, 100
                jle getVector

                ; fail size
                sizeFailure:
                        push [N]
                        push incorSize
                        call [printf]

                        call [getch]

                        push NULL
                        call [ExitProcess]

                getVector:
                        xor ecx, ecx            ; ecx = 0
                        mov ebx, array          ; ebx = &vec
                getVecLoop:

                        ; Проверка количества введенных элементов
                        mov [tmp], ebx
                        cmp ecx, [N]
                        jge inputEnd

                        mov [counter], ecx
                        push ecx
                        push numIn
                        call [printf]
                        add esp, 8

                        ; Ввод элемента
                        push ebx
                        push digitFormat
                        call [scanf]
                        add esp, 8

                        mov ecx, [counter]
                        inc ecx
                        mov ebx, [tmp]
                        add ebx, 4
                        jmp getVecLoop

                inputEnd:
                        ret

        ; Подпрограмма вывода исходного массива
        OldArrayOutput:
                push [N]
                push oldArrayString
                call [printf]
                add esp, 8

                xor ebx, ebx
                mov eax, array ;eax = &array
                myOldPrintLoop:

                        mov [tmp], eax
                        mov [counter], ebx

                        push dword [eax]
                        push ebx
                        push elemOutput
                        call [printf]

                        pop ecx
                        pop ecx
                        pop ecx

                        mov ebx, [counter]
                        inc ebx
                        mov eax, [tmp]
                        add eax, 4

                        cmp ebx, [N]
                        jl myOldPrintLoop

                        ret

        ; Подпрограмма вывода нового массива
        ArrayOutput:
                push [newN]
                push resultString
                call [printf]
                add esp, 8

                xor ebx, ebx
                mov eax, newArray ;eax = &array
                myPrintLoop:

                        mov [tmp], eax
                        mov [counter], ebx

                        push dword [eax]
                        push ebx
                        push elemOutput
                        call [printf]

                        pop ecx
                        pop ecx
                        pop ecx

                        mov ebx, [counter]
                        inc ebx
                        mov eax, [tmp]
                        add eax, 4

                        cmp ebx, [newN]
                        jl myPrintLoop

                        ret

        ; Подпрограмма создания массива, требуемого в задаче
        SumsArray:
             xor esi, esi
             mov eax, array ;eax = &array
             mov ebx, newArray

             ;mov newN, N
             add [newN], -1

             mov ecx, [newN]
             cmp ecx, 1
             jge prepareArray

             ; Если не существует пары соседних элементов - то есть исходный масив длины 1
             push emptyResult
             call [printf]
             call [getch]

             push NULL
             call [ExitProcess]

             prepareArray:
                        mov ecx, array
                        add ecx, 4

             vecModify:

                        xor edx, edx

                        mov [counter], esi
                        cmp esi, [N]
                        jge vecExit

                        add edx, [eax]
                        add edx, [ecx]
                        mov [ebx], edx

                        add ebx, 4
                        add eax, 4
                        add ecx, 4

                        mov esi, [counter]
                        inc esi
                        jmp vecModify
                vecExit:
                        ret

        Start:

                call ArrayInput

                call OldArrayOutput

                call SumsArray

                call ArrayOutput

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
