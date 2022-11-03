\ MACHFORTH DEMO #1B
\ On Classic99 debugger you will see R4 counting up and rolling over

\ This demo shows how to:
\  1. compile to 2000 origin
\  2. set the workspace and stacks in 16bit scratch-pad RAM
\  3. how to exit program to TI-99 title page
\  4. How to use inline Assembler with CODE ENDCODE
\  6. Demonstrate turning compiler on or off inside the code
\  5. Save a finished program that can RUN from E/A Option 5

\  *** PRESS FCTN 4 to return to title screen *** 

COMPILER
   HEX
   NEW.
   2000 ORIGIN.
   OPT-ON

TARGET
CODE BYE ( -- )  \ make a named sub-routine
      0 LIMI,          \ disable interrupts
      83C4 @@ CLR,     \ clear GPL status
      0000 @@ BLWP,    \ return to TI-99 title page
ENDCODE

PROG: DEMO1B
\ assembler setup commands must run in the interpreter
    [  HEX          \ switch off compiler for ASM and compiler directives
       0 LIMI,
       8300 WORKSPACE \ alias for 8300 LWPI,
       83BE RSTACK    \ alias for RP 8EBE LI,
       83FE DSTACK    \ alias for SP 83BE LI,  ( 20 cell data stack )
    ]                 \ turn on the compiler
       0BEEF          \ >BEEF -> DATA stack
     [ DECIMAL ]      \ change compiler radix in interpreter mode
       BEGIN
          22 - 7 *   \ do some math with literal numbers
         ?TERMINAL    \ test for Break key uses CPU status register not TOS
       UNTIL          \ So UNTIL does not need to consume a stack parameter
       DROP           \ clean up the stack
       BYE            \ Go home
END.

COMPILER SAVE DSK2.DEMO1B
