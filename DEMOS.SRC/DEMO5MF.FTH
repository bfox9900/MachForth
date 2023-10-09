\ MachFORTH DEMO #5:   Using variables and constants

\ Compiler             Time      Bytes   
\ ------------         ---------  ----- 
\ Camel99 Forth         47.70     100  (including headers)
\ MachForth             15.56      94

\ Compiler Preamble
  COMPILER
  NEW.
  HEX 2000 ORIGIN.

TARGET 

VARIABLE X
VARIABLE Y
VARIABLE Z

FFFF CONSTANT LOOPS

PROG: DEMO5
        LOOPS
        BEGIN
           1-
        <> WHILE   \ no need to DUP TOS in machine Forth. 
                   \ MUST use comparator
           -3 X +!
            Y 1+!
            X @ Y @  +  Z !
        REPEAT
        DROP

        NEXT,            \ return to Camel99 Forth
END.

\ ELAPSE DEMO5 RUN
