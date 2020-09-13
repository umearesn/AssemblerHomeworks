format PE64 console
entry main

include 'win64ax.inc'

section '.data' data readable writable
    A dq 1, 10   ; Массив
    Size=($-A)/9                 ; Размер массива
    fmt_out   db 'k=%llu',13,10,0 ; Формат вывода - беззнаковый
    cmd_pause db 'pause',0        ; Команда паузы

section '.text' code executable
    proc main
    xor rbx,rbx     ; Инициализация результата нулем
    mov rcx,Size    ; Загрузка размера массива
    cld             ; Направление сканирования - вперед
    mov rsi,A       ; Установка указателя на начало массива
; Цикл сканирования массива
    @@:lodsq        ; Загрузка очередного элемента
    cmp rax,10   ; Проверка на x>=10
    jge Next     ; x>=10 - идти дальше
    cmp rax,1    ; Проверка на x<=1
    jle Next     ; x<=1 - идти дальше
    inc rbx      ; Условния соблюдены - инкремент результата
    Next:loop @b ; Переход к следующему элементу

    invoke printf_s,fmt_out,rbx  ; Вывод результата
    call [getch]
    xor rax,rax
    ret
    endp

section '.idata' import data readable writeable
    library msvcrt,'msvcrt.dll'
    import  msvcrt,\
        system,'system',\
        scanf_s,'scanf_s',\
        printf_s,'printf_s', \
        getch, '_getch'