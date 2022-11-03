\ tiny hello world in machine Forth Demo     Nov 2 2022  Fox
\ uses VDPLIB to make PAGE that clears the screen

COMPILER             \ Use compiler wordlist (for interpreted words)
   NEW.              \ clear the memory spaces
   HEX A000 ORIGIN.
   OPT-ON

   INCLUDE DSK2.VDPLIB

\ constants must be defined in COMPILER space
\ They don't generate code until they are used
COMPILER
HEX 8C02 CONSTANT VDPWA     \ Write Address port
HEX 8C00 CONSTANT VDPWD     \ Write Data port

TARGET                 \ Use TARGET wordlist (to compile code)
CREATE TXT  S" Hello World!" S,

: PAGE  0 300 BL VFILL ; \ E/A cartridge wakes up in 32 col. mode so >300 bytes

OPT-ON
HEX
PROG: MAIN
  [ 0 LIMI,           \ disable interrupts
    8300 WORKSPACE    \ Fast ram for registers
    83BE RSTACK       \ and return stack
    83FE DSTACK ]     \ and Data stack

   PAGE
    80 [ 4000 OR] VDPA!  \ set screen address to write to
    TXT COUNT  1- FOR  COUNT [ VDPWD C!]  NEXT DROP

    BEGIN AGAIN       \ loop forever
END.

COMPILER SAVE DSK2.HELLO6
