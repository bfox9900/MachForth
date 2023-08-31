\ MFORTH DEMO1x   - Minimal Binary program creation 

\ *** USES SCRATCH-PAD (16BIT) memory for Stacks and WORKSPACE ***

COMPILER  \ names space that has compiler directives
   NEW.
   HEX A000 ORIGIN.

: NOTUNTIL 
      FFFF           \ Literal numbers compile a LI instruction to R4 
      BEGIN
        1-           \ dec # in R4 ( top of data stack cache) 
      -UNTIL         \ MACHINE FORTH's "not until" operator
      DROP          \ remove number from data stack
;
 
\ CODE WORD to return to TI-99 splash screen.  
CODE BYE
    0 LIMI,           \ disable interrupts 
     83C4 @@ CLR,     \ clear GPL status register 
     0000 @@ BLWP,    \ jump into ROM vector at address 0000
ENDCODE 

\ PROG: names the "ENTRY" routine.
\ It allows gives you a place to do inits and configuration
\ before your program runs.
PROG: DEMO1
\ PREAMBLE
\ these commands are in the Assembler and must be interpreted 
   [ 8300 WORKSPACE   
    4000 DSTACK 
    3FF0 RSTACK ]

\ PROGRAM TO RUN 
      NOTUNTIL 

\ Return to TI99 Monitor program 
      BYE
END. 

\ using PROG:  name we save the binary program to disk. 
TARGET DEMO1 SAVE DSK2.DEMO1

\ Usage from Forth command line:
\ DEMO1 RUN
