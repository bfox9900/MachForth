\ MACHFORTH DEMO  DO/LOOP libary 

COMPILER            \ names space that has compiler directives

   NEW.             \ init heap memory, clear TARGET vocabulary
   HEX 2000 ORIGIN.

INCLUDE DSK2.DOLOOP

TARGET
VARIABLE X 
VARIABLE Y

PROG: TESTDOLOOP
\  [ 
\   HEX 
\      8300 WORKSPACE 
\      8400 DSTACK    
\      83E0 RSTACK   
\  ]   

   100 0 
   DO
      100 0
      DO 
         I X ! 
         J Y ! 
      LOOP 
   LOOP
   NEXT,         \ goto ti99 ROM monitor
END. 

\ SAVE DSK2.TESTDOLOOP
