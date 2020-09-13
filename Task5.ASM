format PE console

entry start

include 'win32a.inc'

section '.data' data readable writable
formatStr db '%s', 0
formatNum db '%d', 0

name rd 2
bd rd 1

wn db 'What is your name? ', 0
bdtext db 'When were you born? ', 0
info db '%s was born in %d.', 0

NULL = 0
section '.code' code readable executable
start:
push wn
call [printf]

push name
push formatStr
call [scanf]

push bdtext
call [printf]

push bd
push formatNum
call [scanf]

push [bd]
push name
push info
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