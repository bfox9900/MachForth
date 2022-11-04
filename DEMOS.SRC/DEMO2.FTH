\ MACHFORTH DEMO #2:  different ways to assign to variables
\ Updated to MACHFORTH 2022

COMPILER
    NEW.
    HEX 2000 ORIGIN.
\ *
\ * NOTE: Optimizer breaks some loop exit conditions by removing instructions
\ *
    OPT-OFF

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

\ SYMBOLIC ADDRESSING: store to variable, memory to memory transfer, decrment
\  3 seconds
         FFFF [ Y !]    \ TOS load to Y 
         BEGIN
            [ Y Z ]!    \ mem2mem move:  Y @@ Z @@ MOV,
            [ Y  1-!]
         -UNTIL
         NEXT,          \ return to Forth
END.
