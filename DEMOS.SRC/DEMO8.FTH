\ Machine Forth DEMO 6A: Use ?TERMINAL to escape while loop 
COMPILER
 NEW.
 HEX 2000 ORIGIN.

TARGET
VARIABLE X

\ using Camel99 workspace for simplicity
PROG: DEMO8
    FFFF            \ 0 -> top of stack
    BEGIN
        ?TERMINAL   \ loops until FNCT 4 is pressed
    NOT WHILE 
        DUP X !     \ store copy in X
        1-          \ dec TOS
    REPEAT
    DROP            \ clean the stack
    NEXT,
END.
