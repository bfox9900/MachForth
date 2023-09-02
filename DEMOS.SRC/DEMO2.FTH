\ MACHFORTH DEMO #2:  different ways to assign to variables
\ Updated to MACHFORTH 2022

COMPILER
    NEW.
    HEX 2000 ORIGIN.

TARGET
VARIABLE Z
VARIABLE Y

: STANDARD 
    Y OFF 
    FFFF FOR
        Y @ Z !
        Y 1+! 
    NEXT
; \ 8.25 seconds 

: SYMBOLIC
     Y OFF
    FFFF FOR
        [ Y Z ]!    \ mem2mem move:  Y @@ Z @@ MOV,
        [ Y 1+!]
    NEXT 
; \ 2.58 seconds 

PROG: DEMO2
    DUP 
 \   STANDARD 
    SYMBOLIC  

    NEXT,          \ return to Forth
END.
