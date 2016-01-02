SUB 01 { SQRT }
        { INPUT N
          USES  I, R
          RET   R }
        LET R = N / 2
        FOR I = 1 TO 100 DO
                LET R = (R + N / R) / 2
        ENDFOR
ENDSUB

FOR N = 1 TO 100 DO
        { PRINT SQRT TABLE FOR 1..100 }
        CALL 01
        WRITE R
ENDFOR
