\ MACHFORTH DEMO #1E   FOR NEXT loop index usage with variables

\ I is R8 renamed, used as the loop index for FOR NEXT loops
\ I@  (I fetch) pushes R8 (loop index) onto Forth data stack

COMPILER
   HEX
   NEW.
   2000 ORIGIN.
   OPT-OFF

TARGET

VARIABLE X

\ FORTH fetch and store 5 seconds
\ ASM   using 9900 mem2mem  1.5 seconds
PROG: DEMO1E
        FFFF
        FOR
          I@  X !        \ loop index -> X
          I@ -> X        \ symbolic addressing of X
        [ I X @@ MOV, ]  \ I register to symbolic is fastest & smallest
        NEXT

      NEXT,      \ Return to Forth
END.
