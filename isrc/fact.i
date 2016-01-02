SUB 01
        IF [P] = 0 THEN
                LET [P] = 1
        ELSE
                LET [P+1] = [P] - 1
                LET P = P + 1
                CALL 01
                LET P = P - 1
                LET [P] = [P] * [P+1]
        ENDIF
ENDSUB

LET P = 40
WRITE "INPUT NUMBER N:"
READ [P]
CALL 01
WRITE "N! ="
WRITE [P]
