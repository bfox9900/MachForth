\ MACHFORTH DEMO #1B
\ On Classic99 debugger you will see R4 counting up and rolling over

\ This demo shows how to:
\  1. compile to 2000 origin
\  2. set the workspace and stacks in 16bit scratch-pad RAM
\  3. how to exit program to TI-99 title PAGE
\  4. How to use inline Assembler
\  5. save a finished program that can RUN from E/A Option 5

\  *PRESS FCTN 4 to return to title screen

COMPILER
   HEX
   NEW.
   2000 ORIGIN.
   OPT-ON

TARGET
: BYE ( -- )  \ make a named sub-routine
    [ 0 LIMI,           \ use '[' to code inline Assembler
      83C4 @@ CLR,
      0000 @@ BLWP, ]   \ end ALC with ']'
;

PROG: DEMO1B
\ assembler setup commands must run in the interpreter
    [  HEX          \ switch off compiler for ASM and compiler directives
       0 LIMI,
       8300 WORKSPACE \ alias for 8300 LWPI,
       83BE RSTACK    \ alias for RP 8EBE LI,
       83FE DSTACK    \ alias for SP 83BE LI,  ( 20 cell data stack )
    ]                 \ turn on the compiler
       0BEEF          \ >BEEF -> DATA stack
     [ DECIMAL ]      \ must change radix in interpreter mode
       BEGIN
          22 - 7 *   \ do some math with literal numbers
         ?TERMINAL    \ test for Break key uses CPU status register not TOS
       UNTIL          \ So UNTIL does not need to consume a stack parameter
       DROP           \ clean up the stack
       BYE            \ Go home
END.

COMPILER INCLUDE DSK2.SAVEIMG
SAVE DSK2.DEMO1B
