\ MACHFORTH DEMO #2:  different ways to assign to variables
\ Updated to MACHFORTH 2022

COMPILER
    NEW.
    HEX 2000 ORIGIN.
\    OPT-OFF
    OPT-ON

TARGET
VARIABLE Q
VARIABLE Z
VARIABLE Y

PROG: DEMO2
\ conventional Forth syntax
         FFFF
         BEGIN
            DUP Q !
            1-
         -UNTIL        \ loop until tos=0
         DROP          \ in machforth, UNTIL does not consume the TOS

\ symbolic addressing (register to memory)
         FFFF
         BEGIN
            DUP -> Z   \ tos to Z
            1-
         -UNTIL        \ loop until tos=0
         DROP          \ in machforth, UNTIL does not consume the TOS


\ *
\ * NOTE: Optimizer breaks some loop exit conditions by removing instructions
\ *
OPT-OFF
\ symbolic decrement,  memory to memory transfer
         FFFF -> Y  \ load Y as loop counter
         BEGIN
              Y  1-!      \ decrement symbol
              [ Y Z '! ]  \ generates:  Y @@ Z @@ MOV,
         -UNTIL
         NEXT,            \ return to Forth
END.
