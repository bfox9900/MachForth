\ MFORTH DEMO1D,  DOWN counting FOR/NEXT loop with incrementing TOS

\ * In Classi99 debuggger you see R11 (top of return stack ) decrementing 

COMPILER
   HEX
   NEW.
   2000 ORIGIN.

PROG: DEMO1D      ( 1.2 seconds run time )
       0          \ Put zero on the data stack
       FFFF       \ loop limit goes to TOS register
       FOR        \ FOR consumes it's argument from TOS, brings 0 to TOS
          1+      \ inc on top of stack
       NEXT       \ decrement the I register (R8) and jump back

       NEXT,      \ Return to Forth
END.

\ TARGET DEMO1D RUN
