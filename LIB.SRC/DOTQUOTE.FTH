\ DOT-QUOTE test program 

COMPILER 
NEW.
HEX 2000 ORIGIN.

INCLUDE DSK2.SCREENIO 

COMPILER 
H: POSTPONE   T'  POSTPONE @@  POSTPONE BL, ;   IMMEDIATE 


TARGET
: (S")    ( -- c-addr u) R>  COUNT  OVER OVER + ALIGNED >R ;


H: ." 
  S"  S,  
;H  IMMEDIATE 

DECIMAL 
PROG: GO
    TEXT
    0 0 AT-XY 
    (S")  ." This won't work!"  TYPE 
      
    NEXT,
END. 

CONCUR 

