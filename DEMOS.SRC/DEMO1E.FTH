\ MACHFORTH DEMO #1E   FOR NEXT loop index usage with variables

\ I is R8 renamed, used as the loop index for FOR NEXT loops
\ I@  (I fetch) pushes R8 (loop index) onto Forth data stack

COMPILER
   HEX
   NEW.
   2000 ORIGIN.
   OPT-OFF    \ V2.6 optimizer is disabled inside FOR NEXT loops
             \ you can over-ride if your code will run.

TARGET

VARIABLE X
: LOOP1
        FFFF FOR
          I@ X !      \ FOR/NEXT loop index to X
        NEXT ;

: LOOP2
     FFFF FOR
       I@ [ X !]      \ new symbolic addressing syntax TOS <address> store
     NEXT ;

: LOOP3
      FFFF FOR
        I@ -> X       \ alternate symbolic addressing syntax
      NEXT ;

: LOOP4
      FFFF FOR
        [ I X @@ MOV, ]  \ inline Assembler with I register.
      NEXT ;

\ FORTH syntax fetch and store 5 seconds
\ symbolic addressing 4 seconds
\ Inline ASM 1.5 seconds
PROG: DEMO1E

      LOOP1
      LOOP2
      LOOP3
      LOOP4

      NEXT,      \ Return to Forth
END.
