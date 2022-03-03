\ MFORTH DEMO #7  VDP Library & SCREENIO test

COMPILER
   NEW.
   HEX 2000 ORIGIN.
   OPT-OFF

INCLUDE DSK2.VDPLIB
\ INCLUDE DSK2.SCREENIO

COMPILER
HEX
3F00 CONSTANT SCROLLBUFF
DECIMAL
32 CONSTANT BL   \ constants must be declared in compiler space

HEX
\ Declare the VDP variables
TARGET
    VARIABLE DP     \ *DP MUST BE SET TO TDP BEFORE SAVING PROGRAM*

    VARIABLE HP
    VARIABLE BASE
    VARIABLE C/L
    VARIABLE VROW
    VARIABLE VCOL
    VARIABLE C/SCR
    VARIABLE VPG
    VARIABLE VMODE


: PAGE  ( -- )  0  C/SCR @  BL VFILL  VROW OFF  VCOL OFF  ;

: AT-XY  ( col row --) VROW !  VCOL ! ;

[CC] HEX .( .)
TARGET
\ ** MUST USE TEXT TO INIT THE VDP VARIABLES FIRST **
: TEXT    ( -- )
         0F0 DUP 83D4 C!  1 VWTR
         0   2  VWTR    \ set VDP screen page
         VPG  OFF
         17  7  VWTR   \ FG & BG color
         28  C/L !
         3C0  C/SCR !
         2 VMODE !     \ 2=ID for 40 column "TEXT" mode
         PAGE
;

[CC] DECIMAL .( .) [TC]

: HERE   DP @ ;
: ALLOT  DP +! ;

\ : VPOS   ( -- Vaddr) \ smaller in ALC
\        DUP
\        ' VROW @@ R3 MOV,
\        ' C/L @@ TOS MOV,
\          TOS R3 MPY,
\        ' VCOL @@ TOS ADD,
\ ;
: >VPOS  ( col row -- Vaddr ) C/L @ * + ;
: VPOS   ( -- Vaddr )  VCOL @ VROW @ >VPOS ;
: VPUT  ( c --) VPOS VC!  VCOL 1+! ;

: SCROLL ( -- )  \ works in Graphics or Text mode
      VCOL OFF  1 VROW !
      22 FOR
            VPOS SCROLLBUFF C/L @ VREAD
            VROW 1-!
            SCROLLBUFF VPOS C/L @ VWRITE
            VROW 2+!
      NEXT
      0 23 AT-XY             \ cursor to last line
      VPOS C/L @  BL VFILL   \ erase last line
;

[CC] .( .) [TC]
: CR     ( -- ) ( tested)
         VCOL OFF VROW 1+!
         [ VROW @@ R5 MOV,    \ avoid stack keeps it cleaner
          R5  23  CI, ]       \ 23 is the last VROW on screen
        -IF SCROLL  THEN ;


TARGET
PROG: DEMO7
    TEXT
    BEGIN
       0 17 AT-XY
        65 VPUT   66 VPUT  67 VPUT
        SCROLL SCROLL SCROLL
       ?TERMINAL
    UNTIL

    NEXT,
END.


[CC] THERE  TARGET PFA' DP  HOST !  \ hell of an incantation to init DP

HOST
CR .( type DEMO7 RUN )
CR .( HOLD BREAK in BLACK screen)
CR .( to return to Forth)
TARGET
