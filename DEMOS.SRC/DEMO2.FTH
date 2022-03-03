\ MACHFORTH DEMO #2:  different ways to assign to variables
\ Updated to MACHFORTH 2022

COMPILER
    NEW.
    HEX 2000 ORIGIN.
\    OPT-OFF    \ 9.93 secs
    OPT-ON    \ 9.93 secs, 12 bytes smaller

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


\ symbolic decrement,  memory to memory transfer
         FFFF -> Y  \ load Y as loop counter
         BEGIN
              [ Y Z '! ]  \ generates:  Y @@ Z @@ MOV,
              Y  1-!      \ decrement symbol
         -UNTIL
         NEXT,         \ return to Forth
END.
