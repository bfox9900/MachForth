\ DEMO11.FTH   minimal hello world in machine Forth  Mar 4 2022 Brian Fox
\ Compile and save to EA5 binary program


COMPILER
   NEW.
   HEX 2000 ORIGIN.
   OPT-OFF \ 160 BYTES
   OPT-ON  \ 148 BYTES 

COMPILER
\ EQU & CONSTANTS must be declared in compiler space
HEX
8C02 CONSTANT VDPWA   \ Write Address port (absolute address so use EQU)
8C00 CONSTANT VDPWD   \ Write Data port

\ define the string can in compiler space also
CREATE TXT  S" Hello World!" S,

TARGET                 \ code for the target binary program
HEX
PROG: MAIN
\ Assembler instructions and directives must be interpreted
  [  0 LIMI,
    8300 WORKSPACE
    83BE RSTACK
    83FE DSTACK
  ]               \ turn on the compiler
     0  VDPWA C!  \ character store VDP address LSB
    40  VDPWA C!  \ character store VDP address MSB + "write" bit
    TXT COUNT
    1- FOR
       COUNT VDPWD C!          \ write byte to VDP write port
  \   [ *TOS+ VDPWD @@ MOVB, ]  \ faster inline ASM version
    NEXT
    DROP

	  BEGIN ?TERMINAL UNTIL

\ Return to Home screen
   [ 0000 @@ BLWP, ]
END.

COMPILER INCLUDE DSK2.SAVEIMG  \ needed to save binary programs
SAVE DSK2.HELLO12
