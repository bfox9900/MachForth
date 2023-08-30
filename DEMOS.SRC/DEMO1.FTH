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
: NOTUNTIL 
      FFFF            \ 4  Literal numbers compile as LI TOS,n
      BEGIN
        1-        \ dec # on top of data stack
      -UNTIL         \ MACHINE FORTH's "not until" operator
      DROP          \ remove number from data stack
;

: REGUNTIL 
      FFFF           \ 4  Literal numbers compile as LI TOS,n
      BEGIN
        1-           \ dec # on top of data stack
      = UNTIL        \ UNTIL must use a comparison operator 
                     \ loop until STATUS REGISTER EQ flag is set  
      DROP           \ remove number from data stack
;

: TOSUNTIL  
      FFFF           \ 4  Literal numbers compile as LI TOS,n
      BEGIN
        1-           \ dec # on top of data stack
      0= UNTIL       \ UNTIL must use a comparison operator 
                     \ loop until TOS = 0 
      DROP           \ remove number from data stack
;


PROG: DEMO1

      NOTUNTIL 
      REGUNTIL 
      TOSUNTIL 

      NEXT,         \ Return to Forth console
END.

\ Usage from Forth command line:
\ DEMO1 RUN
