\ MFORTH DEMO #5:   Using variables and constants UPDATED for Feb 2022

\ Compiler Preamble
  COMPILER
  NEW.
  HEX 2000 ORIGIN.
  OPT-ON

\ OPT-OFF 15.6 sec
\ OPT-ON  12.3 secs
\         12 bytes smaller
\         24.8% faster
\ Symbolic store:  10.81 secs
\ Symbolic +!       9.31 secs
\ ITC Forth runs equivalent program in 47.7 seconds. 5X slower

TARGET
VARIABLE X
VARIABLE Y
VARIABLE Z

PROG: DEMO5
        TRUE
        BEGIN
           1-
        WHILE
          -3  ->+ X      \ symbolic address +!
          \ X +!         \ normal Forth

           Y 1+!
           X @ Y @ + -> Z \ symbolic address store
        \   Z !           \ normal Forth
        REPEAT
        DROP


        NEXT,            \ return to Camel99 Forth
END.  \ end directive test program size, tests for stack junk

\ ELAPSE DEMO5 RUN
