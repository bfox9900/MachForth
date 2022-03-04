\ VDPLIB.FTH library  for MACHFORTH V2022   Feb 15 2022 Fox
\ 208 bytes
COMPILER
HEX
8800 CONSTANT VDPRD
8802 CONSTANT VDPSTS
8C00 CONSTANT VDPWD
8C02 CONSTANT VDPWA

TARGET
: VDPA! ( Vaddr -- )   \ set vdp address (read mode)
        [ 0 LIMI,
        TOS SWPB,
        TOS VDPWA @@ MOVB,
        TOS SWPB,
        TOS VDPWA @@ MOVB,
        TOS DPOP, ]
;

: VC@    ( addr -- c)
        [ 0 LIMI,
        TOS SWPB,
        TOS VDPWA @@ MOVB,
        TOS SWPB,
        TOS VDPWA @@ MOVB,
        VDPRD @@ TOS MOVB,
        TOS SWPB,
        2 LIMI, ]  ;

: VC! ( c Vaddr -- )
      [ TOS 4000 ORI,
        0 LIMI,
        TOS SWPB,
        TOS VDPWA @@ MOVB,
        TOS SWPB,
        TOS VDPWA @@ MOVB,
        TOS DPOP,
        TOS SWPB, TOS VDPWD @@ MOVB,
        2 LIMI,
        TOS DPOP, ]
;

HEX
\ * VDP write to register. Kept the TI name
: VWTR   ( c reg -- )   \ Usage: 5 7 VWTR
           >< +         \ combine 2 bytes to one cell
          [ 8000 ] #OR VDPA!
          [ 2 LIMI, ] ;

: VFILL ( Vaddr cnt char -- )
        [ TOS SWPB,
          TOS R1 MOV,    \ R1 = CHAR
          *SP+ R0 MOV,   \ R0 = CNT
          *SP+ TOS MOV,
          TOS 4000 ORI, ] \ TOS = VDP write address
          VDPA!          \ TOS is refilled
        [ BEGIN
            R1 VDPWD @@ MOVB,
            R0 DEC,
          -UNTIL
          2 LIMI, ]
;

: VREAD ( Vaddr addr n --)
         [ TOS R0 MOV,
           *SP+ R1 MOV,  \ r1 = addr
           *SP+ TOS MOV,
         ]
           VDPA!         \ TOS is refilled after this call
         [ BEGIN
             VDPRD @@  R1 *+ MOVB,
             R0 DEC,
          -UNTIL
           2 LIMI,
         ]
;

: VWRITE ( addr Vaddr len -- )
        [ TOS R0 MOV,
         *SP+ TOS MOV,    \ TOS = Vaddr
          TOS 4000 ORI, ]
          VDPA!           \ TOS = addr (sub-routine does a DROP)
        [ BEGIN
           *TOS+ VDPWD @@ MOVB,
            R0 DEC,
         -UNTIL
         2 LIMI,
         TOS DPOP,
        ]

;
