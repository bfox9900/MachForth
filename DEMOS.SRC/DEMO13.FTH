\ MachForth scroll and screen i/o Test program  Mar 4 2022  Brian Fox

\  >> demonstrates patching the MDP variable to mark end of code.
\ This is mandatory for SCROLL because it uses memory as a buffer.

COMPILER  \ preamble to set up target image
  NEW.
  HEX 2000 ORIGIN.

INCLUDE DSK2.SCREENIO

TARGET
CREATE A$  S" This is line 1. " S,
CREATE B$  S" 2nd line of text." S,

: WAIT        65535 FOR NEXT ;

: SCROLLTEST
  CR
  300 FOR
       A$ COUNT TYPE
       B$ COUNT TYPE
      NEXT ;

DECIMAL
PROG: DEMO13
      TEXT 
      0 0 AT-XY
      A$ COUNT TYPE CR
      B$ COUNT TYPE
      WAIT
      SCROLLTEST

      NEXT,   \ return to Camel99 Forth
END.

\ patch TARGET variable DP, that holds end of memory
CONCUR
