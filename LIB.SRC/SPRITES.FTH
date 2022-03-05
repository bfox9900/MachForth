\ SPRITES.FTH for Machine Forth            BFox Feb 2022

HOST NEEDS GRAPHICS FROM DSK2.GRAPHICS

COMPILER
HEX
300 CONSTANT SDT

TARGET
\ run DELALL before using sprites
: DELALL  ( -- )
          1  6  VWTR          \ vdp reg 6 = 1, puts ]PDT @ $800
          SDT  80  20 VFILL   \ init the sprite desc. table
          SPR# OFF ;          \ #sprites=0

: MAGNIFY  ( mag-factor -- )
        83D4 C@  0FC AND +  DUP 1 VWTR  83D4 C! ;

: SPRITE0  ( char colr x y -- ) \ create a SPRITE, sp# = 0..31
           300  VC!     \ set screen position
           301  VC!
           303  VC!      \ set the sprite color
           302  VC!      \ set the character pattern to use
;

: SPRITE  ( char colr x y SPR# -- ) \ create a SPRITE, sp# = 0..31
           4* SDT + >R     \ compute sprite address, push to R stack
           R@     VC!      \ set screen y position
           R@ 1+  VC!      \ set screen x
           R@ 3 + VC!      \ set the sprite color
           R@ 2+  VC!      \ set the character pattern to use
           RDROP
;
