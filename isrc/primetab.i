FOR N = 2 TO 100 DO
        IF N % 2 = 0 THEN
                LET P = 0
        ELSE
                LET P = 1
        ENDIF
        LET I = 3
        WHILE (NOT (I * I > N)) AND (P = 1) DO
                IF N % I = 0 THEN
                        LET P = 0
                ENDIF
                LET I = I + 2
        ENDWHILE
        IF P = 1 THEN
                WRITE N
        ENDIF
ENDFOR
