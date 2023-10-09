\ ANS Forth verion of DEMO5 for speed comparison
HERE
HEX
VARIABLE X
VARIABLE Y
VARIABLE Z

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
HERE SWAP - DECIMAL . 