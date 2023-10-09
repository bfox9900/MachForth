\ TEST  drop/dup removal from a compiled program 

COMPILER 
NEW. 
HEX 2000 ORIGIN. 

TARGET
PROG: DROPDUPER
      DEAD 
      BEEF 
      DROP DUP DROP DUP DROP DUP 
      DROP DUP DROP DUP DROP DUP 
END.


