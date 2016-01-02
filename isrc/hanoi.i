{
        GLOBAL  N       NUM OF BLOCKS
                P       STACK POINTER
                A       DUMMY
        SUB     00      PRINT STEP
                01      HANOI (RECURSIVE)
}

SUB 00 {PRINT STEP}
{
        ARG     1       FROM-PLACE
                3       TO-PLACE
        RET     (NONE)
}
        LET A = [P+1] * 3 + [P+3]
        IF A =  5 THEN WRITE "A->B" ENDIF
        IF A =  6 THEN WRITE "A->C" ENDIF
        IF A =  7 THEN WRITE "B->A" ENDIF
        IF A =  9 THEN WRITE "B->C" ENDIF
        IF A = 10 THEN WRITE "C->A" ENDIF
        IF A = 11 THEN WRITE "C->B" ENDIF
ENDSUB

SUB 01 {HANOI}
{
        ARG     0       NUM OF BLOCKS IN FROM-PLACE
                1       FROM-PLACE
                2       BY-PLACE
                3       TO-PLACE
        RET     (NONE)
}
        IF [P] > 1 THEN { MOVE N-1 BLOCKS FROM FROM-PLACE BY TO-PLACE TO BY-PLACE }
                LET [P+4] = [P] - 1
                LET [P+5] = [P+1]
                LET [P+6] = [P+3]
                LET [P+7] = [P+2]
                LET P = P + 4
                CALL 01
                LET P = P - 4
        ENDIF
        CALL 00 { MOVE 1 BLOCK FROM FROM-PLACE TO TO-PLACE (NOW FROM-PLACE IS EMPTY) }
        IF [P] > 1 THEN { MOVE N-1 BLOCKS FROM BY-PLACE BY FROM-PLACE TO TO-PLACE }
                LET [P+5] = [P+2]
                LET [P+6] = [P+1]
                LET [P+7] = [P+3]
                LET P = P + 4
                CALL 01
                LET P = P - 4
        ENDIF
ENDSUB

LET P = 26
WRITE "INPUT NUMBER OF BLOCKS:" READ N
LET [P] = N
LET [P+1] = 1
LET [P+2] = 2
LET [P+3] = 3
CALL 01
