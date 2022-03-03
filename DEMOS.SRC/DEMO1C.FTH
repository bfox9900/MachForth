\ MACHFORTH DEMO #1C  BEGIN WHILE REPEAT  test program

\ 9X Faster than this Forth program
\ : DEMO1
\      FFFF
\      BEGIN
\          1-
\      DUP WHILE
\      REPEAT
\      DROP
\ ;

COMPILER  \ names space that has compiler directives
   NEW.
   HEX 2000 ORIGIN.

TARGET    \ Makes code compile to TARGET memory
PROG: DEMO1C
      FFFF          \ counter -> DATA stack
      BEGIN
        1-          \ decrement # on top of data stack
      WHILE         \ WHILE does NOT consume the TOS value
      REPEAT
      DROP          \ remove number from data stack

      NEXT,         \ Return to Forth console
END.

\ Usage from Forth command line:
\ DEMO1C RUN
