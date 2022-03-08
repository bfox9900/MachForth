\ Tursi's famous Sprite benchmark    Mar 5 2022   Fox

COMPILER
   NEW.
   HEX 2000 ORIGIN.

\ We can use the Host Forth colon to make a macro
COMPILER
INCLUDE DSK2.SCREENIO
INCLUDE DSK2.GRAPHICS
INCLUDE DSK2.SPRITES
INCLUDE DSK2.BYE

COMPILER
HEX
300 CONSTANT $300
301 CONSTANT $301

OPT-OFF
TARGET
DECIMAL
: TURSI    \ ~15 seconds
      GRAPHICS
\    char clr  x  y  spr#
      42  6    0  0   0 SPRITE
      1 MAGNIFY

      100
      FOR
        0    239 FOR  DUP $301 VC! 1+  NEXT DROP
        0    175 FOR  DUP $300 VC! 1+  NEXT DROP

             239 FOR  I@  $301 VC!  NEXT
             175 FOR  I@  $300 VC!  NEXT
      NEXT
      DROP
;

\ prog: names the entry address for the images
HEX
PROG: MAIN
    [ 0 LIMI,
      8300 WORKSPACE
      83CE RSTACK
      83FE DSTACK ]

      TURSI
      BYE
END.

COMPILER INCLUDE DSK2.SAVEIMG
SAVE DSK2.TURSIBENCH
