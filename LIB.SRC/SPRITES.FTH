\ SPRITES.FTH for Machine Forth            BFox Feb 2022

TARGET
\ run DELALL before using sprites
: DELALL  ( -- )
          1  6  VWTR          \ vdp reg 6 = 1, puts ]PDT @ $800
          SDT  80  20 VFILL   \ init the 128 byte sprite desc. table
          SPR# OFF ;          \ #sprites=0

: MAGNIFY  ( mag-factor -- )
        83D4 C@  0FC AND +  DUP 1 VWTR  83D4 C! ;

: SPRITE  ( char colr x y SPR# -- ) \ create a SPRITE, sp# = 0..31
           4* SDT + >R     \ compute sprite address, push to R stack
           R@     VC!      \ set screen y position
           R@ 1+  VC!      \ set screen x
           R@ 3 + VC!      \ set the sprite color
           R@ 2+  VC!      \ set the character pattern to use
           RDROP
;

: SP.X! ( byte -- )
      [ R0        0143 LI,      \ set address of sprite0 X coordinate
        R0  VDPWA @@ MOVB,    \ write byte of address to VDP chip
        R0           SWPB,
        R0  VDPWA @@ MOVB,    \ write 2nd byte of address to VDP chip
                 TOS SWPB,
        TOS VDPWD @@ MOVB,
        TOS DPOP, ]
;

: SP.Y! ( byte -- )
      [ R0  0043 LI,      \ set address of sprite0 X coordinate
        R0  VDPWA @@ MOVB,    \ write byte of address to VDP chip
        R0           SWPB,
        R0  VDPWA @@ MOVB,    \ write 2nd byte of address to VDP chip
                 TOS SWPB,
        TOS VDPWD @@ MOVB,
        TOS DPOP, ]
;
