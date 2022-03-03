\ MFORTH DEMO #1D  DOWN counting FOR/NEXT with incrementing TOS

COMPILER
   HEX
   NEW.
   2000 ORIGIN.
   OPT-ON

TARGET
PROG: DEMO1D      ( 1.2 seconds run time )
       0          \ Put zero on the data stack
       FFFF       \ loop limit goes to TOS register
       FOR        \ FOR consumes it's argument from TOS, brings 0 to TOS
          1+      \ inc on top of stack
       NEXT

       NEXT,      \ Return to Forth
END.

\ DEMO1D RUN
