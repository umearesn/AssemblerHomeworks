; ������� 3 (���������� ������ ���������, ��� 192)
;         ����������� ���������, �������� ������ - �������� �� ���� �������� ����� �������
;         �������� (����� ������ ��������� ������� ��� �����).
format PE console

entry Start

        include 'win32a.inc'

section '.data' data readable writable

        ; �������� �����
        array rw 5

        ; ���������� ������ ��������
        num1 du 0
        num2 du 0
        divider du 1

        ; ��������� ����������� ������ �������� - 0, ���� ������� ��������, �������� �� ����������
        coprime dw 1

        ; ������������� �������� ������
        temp dd ?
        temp2 dd ?

        ; �������� �������� ecx ��� ������
        innerCycle dd 1
        ecxStorage dd ?

        ; �������� ��������� �����
        espStorage dd ?
        coprimeEspStorage dd ?
        innerEspStorage dd ?

        ; ���� �����
        numIn db 'Enter positive number %d: ', 0
        elemOutputUshort db 'Elem [%d] = %hu', 10, 0
        ushort db '%hu', 0
        failureMessage db 'Entered number is equivalent to 0!', 10, 0

        ; ����� ���������� � �����
        arrayInfoString db 'Entered %d elements:', 10, 0


        ; ��������� ������ ���������
        notCoprime db 'Numbers are not coprime: two elements are %hu and %hu; common divider = %hu!', 10, 0
        successStr db 'Every pair of numbers is coprime!', 10, 0

        ; ����������� �������� �������� ������� �� ��������������� �����
        upperLimit du ?

        NULL = 0

section '.code' code readable executable

        ; ������������ ����� ������� � ����������
        ArrayInput:
                mov [espStorage], esp
                mov ebx, array          ; ebx = &array
                mov ecx, 5

                getVecLoop:
                        mov [temp], ebx
                        mov [ecxStorage], ecx

                        ; ������� ������� ��������� ��������
                        mov eax, 5
                        sub eax, [ecxStorage]
                        mov [temp2], eax

                elemInput:
                        push [temp2]
                        push numIn
                        call [printf]

                        ; ���� ��������
                        push ebx
                        push ushort
                        call [scanf]

                        ; �������� �� ��������������� ���������� ����� - ���� ������������, ������ ���������
                        cmp dword [ebx], 0
                        jg correctInput

                failedInput:
                        push failureMessage
                        call [printf]
                        jmp elemInput

                correctInput:
                        mov ecx, [ecxStorage]

                        ; ������� � ���������� ��������
                        mov ebx, [temp]
                        add ebx, 2
                        loop getVecLoop

                inputEnd:
                        mov esp, [espStorage]
                        ret

        ; ������������ ������ ��������� ����� �������
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

                        ; ������� ������� ���������� ��������
                        mov eax, 5
                        sub eax, [ecxStorage]
                        mov [temp2], eax

                        ; ����� ��������
                        push word [ebx]
                        push [temp2]
                        push elemOutputUshort
                        call [printf]

                        ; ������� � ���������� ��������
                        mov ebx, [temp]
                        add ebx, 2

                        mov ecx, [ecxStorage]
                        loop printLoop

                outputEnd:
                        mov esp, [espStorage]
                        ret

        ; ������������, ������������� ��������� �������� ������� �� �����
        DefineUpperDividerLimit:
                xor ebx, ebx
                xor eax, eax

                mov bx, [num1]
                mov ax, [num2]
                cmp bx, ax
                ja num2Limit

                ; ���� [num1] ������ ��� ����� [num2], �� � upperLimit ������������ [num1]
                xor ebx, ebx
                mov bx, [num1]
                jmp limitFinish

                num2Limit:
                        ; ���� [num2] ������ [num1], �� � upperLimit ������������ [num2]
                        xor ebx, ebx
                        mov bx, [num2]

                limitFinish:
                        mov [upperLimit], bx
                        ;mov esp, [eaxDebug]
                        ret


        ; ������������, �����������, �������� �� ��� ����� ������� ��������
        TwoIfCoprime:
                mov [coprimeEspStorage], esp
                mov [divider], 1

                        ; ������ ����������� ��������
                        call DefineUpperDividerLimit

                dividerLoop:
                        inc [divider]

                        ; ���� ������������� �������� ������ ����������� ���������� �������� ������ �������� -
                        ; ����� ������� ������
                        xor ebx, ebx
                        mov bx, [divider]
                        cmp bx, [upperLimit]
                        ja dividerExit

                        xor eax, eax
                        xor edx, edx

                        mov ax, [num1]
                        div [divider]

                        ; ���� ������ ����� �� ������� �� �������� - ��������� � ���������� ��������
                        cmp dx, 0
                        jg dividerLoop

                        xor eax, eax
                        xor edx, edx

                        mov ax, [num2]
                        div [divider]

                        ;  ���� ������ ����� ������� �� ��������, �� �� ������ - ��������� � ���������� ��������
                        cmp dx, 0
                        jg dividerLoop

                        ; ����� ���������� � [coprime], ��� ������� ���� �� ������� ������� �����
                        mov [coprime], 0

                        ; ������� ���������� �� ���� ���� � �������
                        push dword [divider]
                        push dword [num2]
                        push dword [num1]
                        push notCoprime
                        call [printf]

                        jmp dividerExit

                dividerExit:
                        mov esp, [coprimeEspStorage]
                        ret

        ; ������������, �����������, ���� �� ����� ����� ���� �� ������� ������� (������� ����)
        CoprimeCheck:
                mov [espStorage], esp

                mov ebx, array    ; ebx = &array
                mov [temp], ebx

                ; ����������� �� ��������� � 0 �� 4 - ��������� ���������� �������� � ecx
                mov ecx, 4
                mov [ecxStorage], ecx

                goPrimeCheck:
                        ; ��������� � num1 ������ ��������������� �������
                        mov ebx, [temp]
                        mov dx, [ebx]
                        mov [num1], dx

                        ; ��������� ebx - ������ �� ��������� �� ��������� ������� �������
                        add ebx, 2
                        mov [temp], ebx
                        mov [temp2], ebx

                        ; ��������� �������� ecx ��� �������� �����
                        mov [ecxStorage], ecx

                        ; ��������� ���������� ���� - ������� �� ���������� ����� [num1] ��������
                        ; �������, ��� ����������� ����� ecx ��������: ���� � ecx ����� �, �� ����������� 5 - x ��������� (������ ������� �������������)
                        ; ������, ��������� x ���������, ������� ���� ��������� � ���� � ��������
                        call InnerLoop

                        ; ���� � InnerLoop �� ������� ���� �� ������� ������� �����, �� ���������� ���� - ��������� � ��������� num1
                        mov ecx, [ecxStorage]
                        loop goPrimeCheck

                fiveCoprimeCheckFinish:

                          mov esp, [espStorage]
                          ret

         ; ������������, �����������, ���� �� ����� ����� ���� �� ������� ������� (���������� ����)
        InnerLoop:
                mov [innerEspStorage], esp

                ; ��������� �������� ecx ��� ����������� �����
                mov [innerCycle], ecx

                inner:

                        ; ��������� � num2 ������ ��������������� �������
                        mov ebx, [temp2]
                        mov dx, [ebx]
                        mov [num2], dx

                        ; ��������, �������� �� ��� ������� ��������
                        call TwoIfCoprime

                        ; ���� �������� 0 - ������� ���� �� ������� �������, ��������� ������ ���������
                        cmp [coprime], 0
                        je fiveCoprimeCheckFinish

                        ; ��������� � ���������� ���������������� ��������, ����� ��� � num2
                        mov ebx, [temp2]
                        add ebx, 2

                        mov [temp2], ebx
                        mov dx, [ebx]
                        mov [num2], dx

                        ; ����������, ���� �� ��������� ��� num2, ��� �� ��������������� � ���� � ������� num1 (������������ �� ������� �����)
                        loop inner

                ; ���� ������� �� ������� ���� �� �������, ������������ �� ������� ����
                mov esp, [innerEspStorage]
                ret

        Start:

                ; ������� ������
                call ArrayInput

                ; ������ ������
                call ArrayOutput

                ; ���������, ���� �� ����� 5 ����� ���� �� ������� �������
                call CoprimeCheck

                ; ���� [coprime] = 0, �� ���� �� ������� ������� ������� => ���� ��������, ��������� ������
                cmp [coprime], 0
                je finish

                ; ����� ������� ���������, ��� ��� ����� ������� ������� ������
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