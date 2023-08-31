\ MACHFORTH DEMO #1E   FOR NEXT loop index usage with variables

\ R11 us used as the loop index for FOR NEXT loops
\ R@  (R fetch) pushes R11 onto Forth data stack

COMPILER
   HEX
   NEW.
   2000 ORIGIN.

VARIABLE X

: LOOP1
        FFFF FOR
          R@ X !      \ FOR/NEXT loop index to X
        NEXT ;

: LOOP2
     FFFF FOR
       R@ [ X !]      \ new symbolic addressing syntax TOS <address> store
     NEXT ;

: LOOP3
      FFFF FOR
        R@ -> X       \ alternate symbolic addressing syntax
      NEXT ;

: LOOP4
      FFFF FOR
        [ R11 X @@ MOV, ]  \ inline Assembler with R11 register 
                           \ R11 is the TOP of return stack cache
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
