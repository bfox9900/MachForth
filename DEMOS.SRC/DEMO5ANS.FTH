\ ANS Forth verion of DEMO5 for speed comparison

VARIABLE X
VARIABLE Y
VARIABLE Z

\ create 1 as a constant. It puts itself on the stack
  01 CONSTANT 1
FFFF CONSTANT LOOPS

: DEMO5
        LOOPS
        BEGIN
           1-
        DUP WHILE
          -3 X +!
           Y 1+!
           X @ Y @  +  Z !
        REPEAT
        DROP
;
