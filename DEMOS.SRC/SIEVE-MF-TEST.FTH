\ BYTE MAGAZINE SIEVE in MACHFORTH 

COMPILER 
NEW. 

HEX A000 ORIGIN. 

INCLUDE DSK2.BYE 

TARGET
DECIMAL
 8192 CONSTANT SIZE

HEX 2000 CONSTANT FLAGS  \ using Low RAM for array  
    0101 CONSTANT FILLER 

: FILLFLAGS
  FLAGS 
  SIZE 
  FOR
     1 OVER C!
     1+ 
  NEXT 
  DROP
;

CODE I     DUP W TOS MOV, ENDCODE 
CODE I++   W INC,  ENDCODE 

: DO-PRIME
   FILLFLAGS 
   FLAGS OFF  \ reset 1st two bytes 
   0 A!       \ use "A" register as loop index 
   0          ( counter )
   SIZE FOR 
     FLAGS I + C@
     <> IF  
           I 2*  3 +  DUP I +
        BEGIN
          DUP SIZE CMP <
        WHILE
           0 OVER FLAGS + C!
           OVER +
        REPEAT
        DROP DROP
        1+
     THEN  
     I++
   NEXT
;



PROG: SIEVE
 [ 
   8300 WORKSPACE 
   FFF0 DSTACK 
   FD00 RSTACK
  ]
 
   DO-PRIME 
   BEGIN ?TERMINAL UNTIL 

   BYE 
END.    

SAVE DSK2.SIEVETEST

