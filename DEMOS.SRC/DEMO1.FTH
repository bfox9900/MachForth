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
   HEX A000 ORIGIN.

TARGET
: NOTUNTIL 
      FFFF            \ 4  Literal numbers compile as LI TOS,n
      BEGIN
        1-        \ dec # on top of data stack
      -UNTIL         \ MACHINE FORTH's "not until" operator
      DROP          \ remove number from data stack
;
 
: BYE
  [  0 LIMI,
     83C4 @@ CLR,
     0000 @@ BLWP, ]
;

PROG: DEMO1
   [ 8300 WORKSPACE 
    4000 DSTACK 
    3FF0 RSTACK ]

      NOTUNTIL 
      REGUNTIL 
      TOSUNTIL 

      BYE
END. 

DEMO1 SAVE DSK2.DEMO1

\ Usage from Forth command line:
\ DEMO1 RUN
