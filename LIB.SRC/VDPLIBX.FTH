\ VDPLIB.FTH library  for MACHFORTH V2022   Nov 3 2022 Fox
 
COMPILER
HEX
8800 CONSTANT VDPRD
8802 CONSTANT VDPSTS
8C00 CONSTANT VDPWD
8C02 CONSTANT VDPWA
 
\ TARGET
CODE VDPA! ( Vaddr -- Vaddr)   \ set vdp address (read mode)
       0 LIMI,
       R1 STWP,
       9 R1 () VDPWA @@ MOVB,  \ write oddddyte from TOS (ie: R4)
       TOS     VDPWA @@ MOVB,  \ MOV writes the even byte to the port address
ENDCODE
 
CODE VC@ ( addr -- c)
       ] VDPA! [
       VDPRD @@ 9 R1 () MOVB,  \ read data into odd byte of R4
ENDCODE
 
CODE VC! ( c Vaddr -- )
       TOS 4000 ORI,
       R1 STWP,                \ avoids 2 SWPB instructions
       ] VDPA! [
        TOS POP, 
       9 R1 () VDPWD @@ MOVB,  \ Odd byte R4, write to screen
       TOS POP,
ENDCODE
 
HEX
\ * VDP write to register. Kept the TI name
: VWTR   ( c reg -- )   \ Usage: 5 7 VWTR
       >< +         \ combine 2 bytes to one cell
     [ 8000 OR] VDPA! DROP
;
 
CODE VFILL ( Vaddr cnt char -- )
       TOS R5 MOV,    \ R5 = CHAR
       R5 SWPB,
      *SP+ R0 MOV,    \ R0 = CNT
      *SP+ TOS MOV,
       TOS 4000 ORI,  \ TOS = VDP write address
      ] VDPA! [ 
       TOS POP, 
       BEGIN,
         R5 VDPWD @@ MOVB,
         R0 DEC,
       EQ UNTIL,
ENDCODE
 
CODE VREAD ( Vaddr addr n --)
      TOS R0 MOV,
     *SP+ R5 MOV,  \ R5 = addr
     *SP+ TOS MOV,
     ] VDPA! [  
       TOS POP, 
      BEGIN,
        VDPRD @@  R5 *+ MOVB,
        R0 DEC,
      EQ UNTIL,
ENDCODE
 
CODE VWRITE ( addr Vaddr len -- )
     TOS R0 MOV,
    *SP+ TOS MOV,  \ TOS = Vaddr
     TOS 4000 ORI,
     ] VDPA! [ 
     TOS POP,   
     BEGIN,
       *TOS+ VDPWD @@ MOVB,
        R0 DEC,
     EQ UNTIL,
     TOS POP,
ENDCODE
 
 
 