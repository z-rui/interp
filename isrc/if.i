LET A = 26

WRITE "INPUT NUMBER N:"
READ N
WRITE "INPUT N NUMBERS:"
FOR I = 1 TO N DO
        READ [A+I]
ENDFOR
FOR I = 1 TO N DO
        FOR J = 1 TO I - 1 DO
                IF [A+I] < [A+J] THEN
                        LET T = [A+I]
                        LET [A+I] = [A+J]
                        LET [A+J] = T
                ENDIF
        ENDFOR
ENDFOR
FOR I = 1 TO N DO
        WRITE [A+I]
ENDFOR
