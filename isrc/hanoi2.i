{
        GLOBAL  N       NUM OF BLOCKS
                A       FROM-PLACE
                B       BY-PLACE
                C       TO-PLACE
                D       DUMMY
        SUB     00      PRINT STEP
                01      HANOI (RECURSIVE)
                02      SWAP BY-PLACE AND TO-PLACE
                03      SWAP FROM-PLACE AND BY-PLACE
}

SUB 00 {PRINT STEP}
        LET D = A * 3 + C
        IF D = 1 THEN WRITE "A->B" ENDIF
        IF D = 2 THEN WRITE "A->C" ENDIF
        IF D = 3 THEN WRITE "B->A" ENDIF
        IF D = 5 THEN WRITE "B->C" ENDIF
        IF D = 6 THEN WRITE "C->A" ENDIF
        IF D = 7 THEN WRITE "C->B" ENDIF
ENDSUB

SUB 01 {HANOI}
        IF N > 0 THEN
                { MOVE N-1 BLOCKS FROM FROM-PLACE BY TO-PLACE TO BY-PLACE }
                LET N = N - 1
                CALL 02 { A B C -> A C B }
                CALL 01
                CALL 02
                { MOVE 1 BLOCK FROM FROM-PLACE TO TO-PLACE (NOW FROM-PLACE IS EMPTY) }
                CALL 00
                { MOVE N-1 BLOCKS FROM BY-PLACE BY FROM-PLACE TO TO-PLACE }
                CALL 03 { A B C -> B A C }
                CALL 01
                CALL 03
                LET N = N + 1
        ENDIF
ENDSUB

SUB 02
        LET D = B
        LET B = C
        LET C = D
ENDSUB

SUB 03
        LET D = A
        LET A = B
        LET B = D
ENDSUB

WRITE "INPUT NUMBER OF BLOCKS:" READ N
LET A = 0
LET B = 1
LET C = 2
CALL 01
