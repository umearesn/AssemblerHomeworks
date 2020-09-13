format PE console

entry start

include 'win32a.inc'

section '.data' data readable writable
formatStr db '%s', 0
formatNum db '%d', 0

name rd 2


wn db 'What about writing a number? ', 0

hello db 'Your number is %s', 0

address db 10,13, 'Address of entered number is %d'

NULL = 0
section '.code' code readable executable
start:
push wn
call [printf]

push name
push formatStr
call [scanf]


push name
push hello
call [printf]

lea eax, [hello]
push eax
push address
call [printf]

call [getch]

push NULL
call [ExitProcess]

section '.idata' import data readable
library kernel, 'kernel32.dll',\
msvcrt, 'msvcrt.dll'

import kernel,\
ExitProcess, 'ExitProcess'

import msvcrt,\
printf, 'printf',\
getch, '_getch',\
scanf,'scanf'