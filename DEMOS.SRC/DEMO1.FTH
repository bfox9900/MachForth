\ MFORTH DEMO #1  Use HOST Forth workspace and stacks
\ This allows using the RUN command to run DEMO1 without leaving MachForth.
\ If running on Classic99 you will see R4 counting up and rolling over.
\ Press FCTN 4 to return to MFCC
\ Compiles to 28 bytes.

\ *** USES FORTH'S WORKSPACE ***
\ * Since MachForth uses the same stack pointers as the HOST Camel99 Forth,
\   we can test our code using the same stacks which means we can return
\   to FORTH seamlessly

COMPILER  \ names space that has compiler directives
   NEW.
   HEX 2000 ORIGIN.

TARGET
PROG: DEMO1
      4             \ 4  Literal numbers compile as LI TOS,n
      BEGIN
         1+        \ inc # on top of data stack
        ?TERMINAL  \ test for Break key
      UNTIL         \ MACHINE FORTH uses native status register
      DROP          \ remove number from data stack
      NEXT,         \ Return to Forth console
END.

\ Usage from Forth command line:
\ DEMO1 RUN
