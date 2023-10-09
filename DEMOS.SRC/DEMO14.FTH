\ Machine Forth DEMO with OPTIMIZE 
COMPILER
 NEW.
 HEX 2000 ORIGIN.

TARGET
VARIABLE X
VARIABLE Y 

\ using Camel99 workspace for simplicity
PROG: DEMO14
    FFFF            \ 0 -> top of stack
    BEGIN
        ?TERMINAL   \ loops until FNCT 4 is pressed
    NOT WHILE 
        DUP  X !     \ store copy in X
        DUP  Y !    
       
        1-          \ dec TOS
    REPEAT
    DROP            \ clean the stack
    NEXT,
END.
