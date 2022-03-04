\ MachForth DEMO10     VDP Library functions test

\ VDPLIB words
\ ------------
\  VDPA!  ( Vaddr -- )   \ set vdp address (read mode)
\  VC@    ( Vaddr -- c)
\  VC!    ( c Vaddr --)
\  VWTR   ( c reg -- )   \ VDP write to register
\  VFILL  ( Vaddr cnt char -- )
\  VREAD  ( Vaddr addr n --)
\  VWRITE ( addr Vaddr len -- )


COMPILER  \ preamble to set up target image
  NEW.
  HEX 2000 ORIGIN.
  OPT-ON

\ load libraries in compiler space
 INCLUDE DSK2.VDPLIB

COMPILER   ( constants must be declared in COMPILER )
DECIMAL
 40  CONSTANT C/L    \ chars per line
 32  CONSTANT BL     \ space character (blank)
960  CONSTANT C/SCR  \ chars per screen

 \ User program begins
TARGET
: WAIT   TRUE FOR NEXT ;

\ these words end with a function call so we can tail-call optimize with -;
\ Saves 3 BYTES per usage :-)
: PAGE       ( -- )       0 C/SCR  BL VFILL -;
: FILLSCREEN ( c -- )  >R 0 C/SCR  R> VFILL -;
: TYPE       ( addr n --) 0 SWAP VWRITE -; \ write to top of screen only

CREATE TITLE   S" VDPLIB Test Program" S,

HEX
PROG: DEMO10
        PAGE
        17 7 VWTR  \ black on cyan
        TITLE COUNT TYPE  WAIT
        PAGE
        41 0 VC!  42 1 VC!  43 2 VC!  WAIT  \ write BC
        0 VC@  85 VC!  WAIT   \ read A, copy to screen address HEX 85

        41 FILLSCREEN
         WAIT
        42 FILLSCREEN
        WAIT
        43 FILLSCREEN
        WAIT
        OPT-OFF  \ optimizer breaks this loop code 
        5F FOR   BL I@ + FILLSCREEN   NEXT
        E1 7 VWTR     \ gray on black
        NEXT,         \ return to Camel99 Forth
END.

\ DEMO10 RUN
