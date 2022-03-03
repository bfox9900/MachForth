\ Machine Forth DEMO 6A: Use ?TERMINAL, a fast keyscan for BREAK key

COMPILER
 NEW.
 HEX 2000 ORIGIN.

TARGET
VARIABLE X

\ using Camel99 workspace for simplicity
PROG: DEMO6A


      FFFF         \ 0 -> top of stack
      BEGIN
        DUP X !     \ store copy in X
         1-         \ dec TOS
        ?TERMINAL   \ loops until FNCT 4 is pressed
      UNTIL
      DROP          \ clean the stack
      BYE

      NEXT,
END.
