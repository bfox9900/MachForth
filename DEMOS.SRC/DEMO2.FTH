\ MACHFORTH DEMO #2:  different ways to assign to variables
\ Updated to MACHFORTH 2022

COMPILER
    NEW.
    HEX 2000 ORIGIN.
\ *
\ * NOTE: Optimizer breaks some loop exit conditions by removing instructions
\ *
    OPT-ON

TARGET
VARIABLE Z
VARIABLE Y

PROG: DEMO2
\ STANDARD SYNTAX  10 seconds
         FFFF Y !
         BEGIN
             Y @ Z !
             -1 Y +!
         -UNTIL

\   201C  0646  dect R6                     (14)
\   201E  C584  mov  R4,*R6                 (30)
\   2020  0204  li   R4,>2006               (20)
\   2024  C114  mov  *R4,R4                 (26)
\   2026  0646  dect R6                     (14)
\   2028  C584  mov  R4,*R6                 (30)
\   202A  0204  li   R4,>2004               (20)
\   202E  C536  mov  *R6+,*R4               (42)
\   2030  C136  mov  *R6+,R4                (30)
\   2032  0646  dect R6
\   2034  C584  mov  R4,*R6
\   2036  0204  li   R4,>ffff
\   203A  0646  dect R6
\   203C  C584  mov  R4,*R6
\   203E  0204  li   R4,>2006
\   2042  A536  a    *R6+,*R4
\   2044  C136  mov  *R6+,R4
\   2046  18EA  joc  >201c

\ SYMBOLIC ADDRESSING: store to variable, memory to memory transfer, decrment
\  3 seconds
         FFFF [ Y !]    \ TOS load to Y
         BEGIN
            [ Y Z ]!    \ mem2mem move:  Y @@ Z @@ MOV,
            [ Y  1-!]
         -UNTIL
         NEXT,          \ return to Forth
END.
\   2056  C820  mov  @>2006,@>2004          (54)
\   205C  0620  dec  @>2006                 (34)
\   2060  18FA  joc  >2056                  (14)
