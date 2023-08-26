\ MachFORTH DEMO #5:   Using variables and constants

\ Compiler Preamble
  COMPILER
  NEW.
  HEX 2000 ORIGIN.

\ declare a constant in COMPILER space.
-3 CONSTANT K

\ Operators                OPT-ON    Bytes   OPT-OFF  Bytes
\ ------------            ---------  ----- |  -------  -----
\ Normal   ! and +!      12.30 secs    82  |   15.56    94
\ Symbolic -> and ->+     9.31 secs    70  |   12.56    82

\ Camel99 Forth          47.70 secs

TARGET
VARIABLE X
VARIABLE Y
VARIABLE Z

PROG: DEMO5
        TRUE             \ put -1 (>FFFF) on data stack
        BEGIN
           1-
        WHILE
           K ->+ X        \ add K to symbolic address
          \ K X +!          ( normal Forth syntax)

           Y 1+!
           X @ Y @ + -> Z \ symbolic address store
          \ X @ Y @ +  Z ! ( normal Forth syntax)
        REPEAT
        DROP


        NEXT,            \ return to Camel99 Forth
END.

\ ELAPSE DEMO5 RUN
