\ BYTE MAGAZINE SIEVE in MACHFORTH 
COMPILER
   NEW.
   HEX 2000 ORIGIN.

INCLUDE DSK2.DOLOOP 
INCLUDE DSK2.SCREENIO
INCLUDE DSK2.NUMBERS 

DECIMAL
 8190 CONSTANT SIZE
 0101 CONSTANT FILLER 

VARIABLE FLAGS  SIZE ALLOT  
FLAGS OFF

: FILLW ( n len addr -- ) 
\ reversed params works better in MF
      A!        \ put address in A register 
      FOR 
        DUP !A  \ store TOS in *A 
      NEXT 
      DROP 
;

: DO-PRIME
   FILLER SIZE FLAGS FILLW  ( set array )
   0        ( counter )
   SIZE 0
   DO
     FLAGS I + C@
     <> IF I 2*  3 +  DUP I +
        BEGIN
          DUP SIZE CMP <
        WHILE
           0 OVER FLAGS + C!
           OVER +
        REPEAT
        DROP DROP
        1+
     THEN
   LOOP
;


PROG: SIEVE
 [ HEX
   8300 WORKSPACE 
   8400 DSTACK 
   83E0 RSTACK
  ]
   DOPRIME 

   NEXT, 
END.    



