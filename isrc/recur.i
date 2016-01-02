SUB 01
        IF N < 10 THEN
                CALL 02
        ENDIF
ENDSUB

SUB 02
        WRITE N
        LET N = N + 1
        CALL 01
ENDSUB

LET N = 1
CALL 01
