\ MACHFORTH DEMO #1C  BEGIN WHILE REPEAT  test program
\ DEMO shows colon definition placed in the "PROG: END." structure

COMPILER  \ names space that has compiler directives
   NEW.
   HEX 2000 ORIGIN.

\ 9X Faster than this equivalent Forth program
\ : DEMOWHILE
\      FFFF
\      BEGIN
\          1-
\      DUP WHILE
\      REPEAT
\      DROP
\ ;

: DEMOWHILE
    FFFF       \ counter -> DATA stack
    BEGIN
      1-       \ decrement # on top of data stack
    <> WHILE   \ DUP is not needed because
               \ WHILE does NOT consume the TOS value like standard Forth
    REPEAT
    DROP       \ remove number from data stack
;

PROG: DEMO1C
      DEMOWHILE
      
      >HOST      \ Return to Forth console
END.

\ Usage from Forth command line:
\ TARGET DEMO1C RUN
