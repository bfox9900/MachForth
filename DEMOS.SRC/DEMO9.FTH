\ MachForth DEMO9: Nested sub-routine calls with TAIL-CALL optimization

COMPILER

   NEW.
   HEX 2000 ORIGIN.
  OPT-OFF

TARGET
VARIABLE X
VARIABLE Y
VARIABLE Z

: WORD1   X ! ;  \ CANNOT use tail-call optimizer. Last word is inline code.

: WORD2   WORD1  X @  2/  Y ! ;
: WORD3   WORD2  Y @  2*  Z ! ;

\ *TRY these with regular -;  to see the difference.
: WORD4   WORD3 ;  \ CAN use tail-call optimzer because last word is a call
: WORD5   WORD4 ;
: WORD6   WORD5 ;
: WORD7   WORD6 ;
: WORD8   WORD7 ;
: WORD9   WORD8 ;
: WORD10  WORD9 ;

\ using Camel99 workspace for easy testing
[CC] HEX
TARGET
PROG: DEMO9
         FFFF FOR
           I@ WORD10   \ return stack holds the loop index
         NEXT

         NEXT,        \ go back to Forth interpreter
END.

\ ELAPSE DEMO9 RUN

\ Normal return:  43.5 secs, 220 bytes
\ Tail-call opt:  28.4 secs, 192 bytes !!!