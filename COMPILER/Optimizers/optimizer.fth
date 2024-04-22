\ optimizer.fth 

\
\ After messing around with trying to detect code patterns
\ at compile time, I realized it is simpler to do a 2nd scan.
\ We search for the bad patterns in the code and 
\ remove/replace the strings as required. 
\

HOST
NEEDS DUMP FROM DSK1.TOOLS 
INCLUDE DSK1.SEARCH 

: LEN ( addr -- c) C@ ; \ for clarity only 

HEX
\ create the problem instructions as byte-counted binary strings
CREATE DROP/DUP$    6 C,  C136 , 0646 , C584 ,  ALIGN  
\                              8 SLA  SWPB 
CREATE SWPB$        4 C,  0984 , 06C4 ,  ALIGN


: "DROP/DUP" ( -- addr len) DROP/DUP$ COUNT ;
: "SWPB"     ( -- addr len) SWPB$ COUNT ;

\ remove bytes from the data pair (addr len) 
\ returning the rest of the string
: REMOVE ( addr len bytes -- addr' len' )
    >R 
    OVER SWAP        ( -- srcaddr srcaddr len )
    R> /STRING       ( -- srcaddr dest len' )
    >R SWAP R>       ( -- dest src len' )
    MOVE 
;

: THE-PROGRAM ( -- addr size ) CDATA THERE OVER -  ;

VARIABLE #DUPS 
VARIABLE #BYTESWAPS

: TOSOPT ( -- )
    THE-PROGRAM
    #DUPS OFF 
  \  BEGIN 
        "DROP/DUP" SEARCH ( addr len ?)
    IF 
   \ WHILE 
        2DUP 3 CELLS DUP>R REMOVE    \ remove the code 
        R> NEGATE TDP +!       \ update Target data pointer 
        #DUPS 1+! 
   \ REPEAT
   THEN 
    2DROP 
;

: SWPBOPT ( -- )
    THE-PROGRAM
  \  BEGIN 
        "SWPB" SEARCH ( addr len ?)
    IF 
   \ WHILE 
        2DUP 2 CELLS DUP>R REMOVE    \ remove the code 
        R> NEGATE TDP +!       \ update Target data pointer 
   \ REPEAT
   THEN 
   2DROP 
;
