\ Tursi's benchmark in simple machine Forth        2022  Brian Fox

COMPILER
H: IMMEDIATE   IMMEDIATE ;H

   NEW.
   HEX A000 ORIGIN.

\ constants take no space in the program unless used.
380 CONSTANT CTAB      \ colour table VDP address
800 CONSTANT PDT       \ "pattern descriptor table" VDP address
300 CONSTANT $300      \ sprite0 Y position
301 CONSTANT $301      \ sprite0 X position


OPT-ON
INCLUDE DSK2.VDPLIB
INCLUDE DSK2.GRAPHICS
INCLUDE DSK2.BYE

TARGET
HEX
: MAGNIFY  ( mag-factor -- )
        83D4 C@  0FC AND +  DUP 1 VWTR  83D4 C! ;

: SPRITE0  ( char colr x y -- ) \ setup SPRITE #0
           300 VC!      \ set Y position
           301 VC!      \ set X position
           303 VC!      \ set the sprite color
           302 VC!      \ set the character pattern to use
;

TARGET
CODE 0SP.X! ( c -- )
       R1 STWP,                \ avoids 2 SWPB instructions
       R2 4301 LI,
       0 LIMI,
       5 R1 () W ** MOVB,  \ write odd byte from R2
       R2      W ** MOVB,  \ write even byte
       9 R1 () VDPWD @@ MOVB,  \ Odd byte R4, write to screen
       TOS DPOP,
ENDCODE

CODE 0SP.Y! ( c -- )
       R1 STWP,                \ avoids 2 SWPB instructions
       R2 4300 LI,
       0 LIMI,
       5 R1 () W ** MOVB,  \ write odd byte from R2
       R2      W ** MOVB,  \ write even byte
       9 R1 () VDPWD @@ MOVB,  \ Odd byte R4, write to screen
       TOS DPOP,
ENDCODE

TARGET
PROG: TURSI
\ setup Forth machine in scratchpad RAM
  [ 8300 WORKSPACE
    83BE RSTACK
    83FE DSTACK ]

\ benchmark begins here
DECIMAL
      GRAPHICS
      42 4 0 0 SPRITE0
      1 MAGNIFY
      VDPWA A!
      100 FOR
        \ using TOS for up counting
        0   239 FOR DUP 0SP.X! 1+   NEXT DROP
        0   175 FOR DUP 0SP.Y! 1+   NEXT DROP
        \ for/next index is a down-counter
            239 FOR  R@ 0SP.X!      NEXT
            175 FOR  R@ 0SP.Y!      NEXT
      NEXT
      BYE
END.

COMPILER SAVE DSK2.TURSI
