\ Tursi's famous Sprite benchmark    Mar 5 2022   Fox
\ Added some optimization methods to get closer to GCC speed of ~5 seconds

COMPILER
   NEW.
   HEX 2000 ORIGIN.

\ We can use the Host Forth colon to make a macro
COMPILER
INCLUDE DSK2.SCREENIO
INCLUDE DSK2.GRAPHICS
INCLUDE DSK2.SPRITES
INCLUDE DSK2.MENU


OPT-ON

COMPILER
HEX
0380 CONSTANT CTAB      \ colour table VDP address

\ ## EQU does not generate code. Just returns a number for the compiler to use.
0043 EQU W$300      \ write bit set, and byte-swapped.
0143 EQU W$301      \ write bit set, and byte-swapped

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

TARGET
DECIMAL
: TURSI    \ ~15 seconds
      GRAPHICS
      42  6  0  0  0 SPRITE
      1 MAGNIFY
      100
      FOR
         0 239 FOR  DUP SP.X! 1+ NEXT DROP
         0 175 FOR  DUP SP.Y! 1+ NEXT DROP

           239  FOR  I@ SP.X!  NEXT
           175  FOR  I@ SP.Y!  NEXT
      NEXT
      DROP

      MENU
;

\ prog: names the entry address for the images
HEX
PROG: MAIN
    [ 0 LIMI,
      8300 WORKSPACE
      83CE RSTACK
      83FE DSTACK ]

      TURSI

      NEXT,
END.

COMPILER INCLUDE DSK2.SAVEIMG
SAVE DSK2.TURSI2
