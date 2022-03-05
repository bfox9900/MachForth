\ Tursi's famous Sprite benchmark    Mar 5 2022   Fox

COMPILER
   NEW.
   HEX 2000 ORIGIN.

\ We can use the Host Forth colon to make a macro
COMPILER
INCLUDE DSK2.VDPLIB
INCLUDE DSK2.BYE

COMPILER
HEX
0380 CONSTANT CTAB      \ colour table VDP address
0300 CONSTANT $300
0301 CONSTANT $301

\ A few screen variables
TARGET
VARIABLE C/L
VARIABLE C/SCR
VARIABLE VMODE

OPT-OFF
HEX
: GRAPHICS
         0  CTAB 0 VFILL
         0E0 DUP 83D4 C! 1 VWTR
          0    2  VWTR    \ set VDP screen page
         0E    3  VWTR
         01    4  VWTR
         06    5  VWTR
         01    6  VWTR
         CTAB 10  10  VFILL  \ charset colors
         27    7  VWTR         \ screen color
         20  -> C/L
         300 -> C/SCR
         1 -> VMODE
         0 300 20  VFILL  -;

HEX
: MAGNIFY  ( mag-factor -- )
        83D4 C@  0FC AND +  DUP 1 VWTR  83D4 C! ;

: SPRITE0  ( char colr x y -- ) \ create a SPRITE, sp# = 0..31
           300  VC!      \ set Y position
           301  VC!      \ set X position
           303  VC!      \ set the sprite color
           302  VC!      \ set the character pattern to use
;

: VPUTC ( c Vaddr -- ) \ optimized VC!
      [ TOS 4000 ORI,
        R2  VDPWA LI,
        TOS SWPB,
        TOS R2 ** MOVB,
        TOS SWPB,
        TOS R2 ** MOVB,
        TOS DPOP,
        TOS SWPB, TOS VDPWD @@ MOVB,
        TOS DPOP, ]
;

TARGET
DECIMAL
: TURSI    \ ~15 seconds
      GRAPHICS
      42  6  0  0 SPRITE0
      1 MAGNIFY
      100
      FOR
        0    239 FOR  DUP $301 VPUTC 1+  NEXT DROP
        0    175 FOR  DUP $300 VPUTC 1+  NEXT DROP

        239  FOR  I@  $301 VPUTC  NEXT
        175  FOR  I@  $300 VPUTC  NEXT
      NEXT
      DROP

      BEGIN
        ?TERMINAL
      UNTIL  \ wait for FCNT 4
      BYE
;

\ prog: names the entry address for the images
HEX
PROG: MAIN
    [ 0 LIMI,
      8300 WORKSPACE
      83CE RSTACK
      83FE DSTACK ]

      TURSI
END.
\ 15 seconds
COMPILER INCLUDE DSK2.SAVEIMG
SAVE DSK2.TURSIBENCH
