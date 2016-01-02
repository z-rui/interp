FOR I = 2 TO 47 DO
  FOR J = I TO 47 DO
    FOR K = J TO 47 DO
      IF (I+J+K=49) AND (I*I + J*J + K*K = 1155) THEN
        WRITE "======ONE SOLUTION======"
        WRITE I WRITE J WRITE K
      ENDIF
    ENDFOR
  ENDFOR
ENDFOR
