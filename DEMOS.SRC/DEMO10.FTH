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

\ load libraries in compiler space
 INCLUDE DSK2.VDPLIB
 INCLUDE DSK2.BYE 

COMPILER   ( constants must be declared in COMPILER )
DECIMAL
 40  CONSTANT C/L    \ chars per line
 32  CONSTANT BL     \ space character (blank)
768  CONSTANT C/SCR  \ chars per screen

 \ User program begins
TARGET
: WAIT   TRUE FOR NEXT ;

\ these words end with a function call so we can tail-call optimize with -;
\ Saves 3 BYTES per usage :-)
: PAGE       ( -- )       0 C/SCR  BL VFILL ;
: FILLSCREEN ( c -- )  >R 0 C/SCR  R> VFILL ;
: TYPE       ( addr n Vaddr--) SWAP VWRITE ; \ write to screen address

CREATE TITLE   S" VDPLIB Test Program" S,
CREATE MSG S" Press function 4 to exit" S, 

HEX
PROG: DEMO10
  [ 
    8300 WORKSPACE 
    3FFE DSTACK 
    3EFE RSTACK   
  ]
        PAGE
        17 7 VWTR  \ black on cyan
        TITLE COUNT 0 TYPE  WAIT
        PAGE
        41 0 VC!  42 1 VC!  43 2 VC!  WAIT  \ write ABC
        0 VC@  85 VC!  WAIT   \ read A, copy to screen address HEX 85
        5 FOR 
          20 
          5E FOR  
              DUP FILLSCREEN 
              1+ 
          NEXT 
          DROP 
        NEXT 
        MSG COUNT 40 TYPE 

        BEGIN ?TERMINAL UNTIL        
        BYE 
END.

COMPILER SAVE DSK2.DEMO10 
