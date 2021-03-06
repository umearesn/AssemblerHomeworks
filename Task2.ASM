format PE64 console
entry main

include 'win64ax.inc'

section '.data' data readable writable
    A dq 1, 10   ; ������
    Size=($-A)/9                 ; ������ �������
    fmt_out   db 'k=%llu',13,10,0 ; ������ ������ - �����������
    cmd_pause db 'pause',0        ; ������� �����

section '.text' code executable
    proc main
    xor rbx,rbx     ; ������������� ���������� �����
    mov rcx,Size    ; �������� ������� �������
    cld             ; ����������� ������������ - ������
    mov rsi,A       ; ��������� ��������� �� ������ �������
; ���� ������������ �������
    @@:lodsq        ; �������� ���������� ��������
    cmp rax,10   ; �������� �� x>=10
    jge Next     ; x>=10 - ���� ������
    cmp rax,1    ; �������� �� x<=1
    jle Next     ; x<=1 - ���� ������
    inc rbx      ; �������� ��������� - ��������� ����������
    Next:loop @b ; ������� � ���������� ��������

    invoke printf_s,fmt_out,rbx  ; ����� ����������
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