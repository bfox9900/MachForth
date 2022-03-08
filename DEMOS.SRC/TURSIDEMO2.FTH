\ Tursi's famous Sprite benchmark    Mar 5 2022   Fox
\ Optimized VC! takes instructions out of inner loop

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
4300 CONSTANT $300
4301 CONSTANT $301

OPT-OFF
TARGET
DECIMAL
: TURSI    \ ~10 seconds
      GRAPHICS
\    char clr  x  y  spr#
      42  6    0  0   0 SPRITE
      1 MAGNIFY
     [ 0 LIMI, ]
      100
      FOR
        0  239 FOR
           DUP $301 \ VC!
         [ TOS SWPB,
           TOS VDPWA @@ MOVB,
           TOS SWPB,
           TOS VDPWA @@ MOVB,
           TOS DPOP,
           TOS SWPB, TOS VDPWD @@ MOVB,
           TOS DPOP, ]
           1+
        NEXT
        DROP
        0
        175 FOR
               DUP $300 \ VC!
             [ TOS SWPB,
               TOS VDPWA @@ MOVB,
               TOS SWPB,
               TOS VDPWA @@ MOVB,
               TOS DPOP,
               TOS SWPB, TOS VDPWD @@ MOVB,
               TOS DPOP, ]
               1+
         NEXT
         DROP

         239  FOR
                I@  $301 \ VC!
             [ TOS SWPB,
               TOS VDPWA @@ MOVB,
               TOS SWPB,
               TOS VDPWA @@ MOVB,
               TOS DPOP,
               TOS SWPB, TOS VDPWD @@ MOVB,
               TOS DPOP, ]
         NEXT

         175  FOR
               I@  $300 \ VC!
             [ TOS SWPB,
               TOS VDPWA @@ MOVB,
               TOS SWPB,
               TOS VDPWA @@ MOVB,
               TOS DPOP,
               TOS SWPB, TOS VDPWD @@ MOVB,
               TOS DPOP, ]
         NEXT
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
SAVE DSK2.TURSI2
