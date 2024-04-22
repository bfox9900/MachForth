\ MFORTH DEMO #1  Minimal program in MachForth    Aug 2023 

\ Uses  HOST Forth workspace and stacks
\ We can use the RUN command to run DEMO1 without leaving MachForth.
\ If running on Classic99 you will see R4 counting down quickly

COMPILER            \ names space that has compiler directives

   NEW.             \ init heap memory, clear TARGET vocabulary
   HEX 2000 ORIGIN.

TARGET 
PROG: DEMO1
    FFFF            \ Literal numbers go onto data stack
    BEGIN
      1-            \ dec # on top of data stack
    -UNTIL          \ MACHINE FORTH's "not until" operator
    DROP            \ remove number from data stack.
( *machine Forth does not clean the stack like standard Forth)
                 
    NEXT,           \ back to Forth
END.                \ 20 bytes versus 10 + header in Forth

\ Usage from Forth command line.  
\ We need the TARGET directive so MACHFORTH can find the word DEMO1

\ Same program in Standard Forth 
\ HEX
\ HERE
\ : DEMO1
\    FFFF            \ Literal numbers go onto data stack
\    BEGIN
\      1-            \ dec # on top of data stack
\    0= UNTIL          \ MACHINE FORTH's "not until" operator
\    DROP            \ remove number from data stack.
\ ;
HERE SWAP - DECIMAL . .( bytes)

( *machine Forth does not clean the stack like standard Forth)
               \ 20 bytes versus 28 bytes in Forth (includes header)
