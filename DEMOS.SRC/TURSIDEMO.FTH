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
300 CONSTANT $300
300 CONSTANT SAT   \ sprite attribute table 
301 CONSTANT $301
380 CONSTANT CTAB 


TARGET
: SPRITE  ( char colr x y SPR# -- ) \ create a SPRITE, sp# = 0..31
           4* SAT + >R     \ compute sprite address, push to R stack
           R@     VC!      \ set screen y position
           R@ 1+  VC!      \ set screen x
           R@ 3 + VC!      \ set the sprite color
           R@ 2+  VC!      \ set the character pattern to use
           R> DROP 
;

: PAGE   0 $300 BL VFILL ;

: GRAPHICS
      0  380 0 VFILL   \ clear screen and sprite table
      0E0 DUP 83D4 C!
            1 VWTR
        0   2 VWTR      \ set VDP screen page
        0E  3 VWTR
        01  4 VWTR
        06  5 VWTR
        01  6 VWTR
      CTAB 17 10 VFILL  \ charset colors
         17 7 VWTR      \ BLACK on CYAN
      PAGE -;

DECIMAL
: TURSI    \ ~15 seconds
     GRAPHICS 
\    char clr  x  y  spr#
      42  6    0  0   0 SPRITE

  \    100
   \   FOR
  \      0    239 FOR  DUP $301 VC! 1+  NEXT DROP
   \     0    175 FOR  DUP $300 VC! 1+  NEXT DROP
              239 FOR  R@  $301 VC!  NEXT
    \         175 FOR  R@  $300 VC!  NEXT
   \   NEXT
   \   DROP
;

\ prog: names the entry address for the images
HEX
PROG: MAIN
    [ 0 LIMI,
      8300 WORKSPACE
      83E0 RSTACK
      8400 DSTACK ]

      TURSI

      BYE
END.

COMPILER 
SAVE DSK2.TURSIBENCH
