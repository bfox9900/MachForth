\ MACHFORTH DEMO #1B
\ On Classic99 debugger you will see R4 counting up and rolling over

\ This demo shows how to:
\  1. compile to 2000 origin
\  2. set NEW workspace and stacks in 16bit scratch-pad RAM
\  3. how to exit program to TI-99 title PAGE
\  4. save a finished program that can RUN from E/A Option 5
\  *PRESS FCTN 4 to return to title screen

COMPILER
   HEX
   NEW.
   2000 ORIGIN.
   OPT-ON
TARGET
: BYE ( -- )              \ make a sub-routine
      [ 0 LIMI,           \ use inline assembler
        83C4 @@ CLR,
        0000 @@ BLWP, ]
;

PROG: DEMO1B
\ assembler setup commands must run in the interpreter
    [  HEX          \ switch off compiler for ASM and compiler directives
       0 LIMI,
       8320 WORKSPACE
       8328 DSTACK  \ SP points to R4
       4000 RSTACK
    ]               \ turn on the compiler
       0BEEF        \ >BEEF -> DATA stack
     [ DECIMAL ]    \ change radix in interpreter mode
       BEGIN
          22 - 7 *   \ do some math with literal numbers
         ?TERMINAL  \ test for Break key
       UNTIL        \ MACHFORTH UNTIL does not consume the stack parameter
       DROP         \ clean up the stack
       BYE          \ Go home
END.

COMPILER
SAVE DSK2.DEMO1B
