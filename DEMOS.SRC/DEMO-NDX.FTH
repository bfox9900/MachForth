\ MFORTH DEMO using indexed addressing

\ *** USES FORTH'S WORKSPACE ***
\ * Since MachForth uses the same stack pointers as the HOST Camel99 Forth,
\   we can test our code using the same stacks which means we can return
\   to FORTH seamlessly

COMPILER  \ names space that has compiler directives
   NEW.
   HEX 2000 ORIGIN.

TARGET

CREATE X   80 ALLOT
CREATE Y   80 ALLOT

: FILL
      80 FOR
         I@  DUP [ X +]!
      NEXT
;

PROG: DEMONDX

      FILL

      NEXT,         \ Return to Forth console
END.

\ Usage from Forth command line:
\ DEMONDX RUN
