READ X

LET R = X / 2

FOR I = 1 TO 100 DO
        LET R = (R + X/R) / 2
ENDFOR

WRITE R
