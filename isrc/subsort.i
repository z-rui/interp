SUB 01 {SORT [A+1]..[A+N] }
        FOR I = 1 TO N DO
                FOR J = 1 TO I - 1 DO
                        IF [A+I] < [A+J] THEN
                                LET T = [A+I] LET [A+I] = [A+J] LET [A+J] = T
                        ENDIF
                ENDFOR
        ENDFOR
ENDSUB

SUB 02 { READ [A+1]..[A+N] }
        FOR I = 1 TO N DO READ[A+I] ENDFOR
ENDSUB

SUB 03 { WRITE [A+1]..[A+N] }
        FOR I = 1 TO N DO WRITE[A+I] ENDFOR
ENDSUB

LET A = 26
READ N
CALL 02 { READ }
CALL 01 { SORT }
CALL 03 { WRITE }
