\ tiny hello world in machine Forth Demo     Nov 2 2022  Fox
\ uses SYMBOLIC addresssing syntax, compiles to 122 bytes

COMPILER             \ Use compiler wordlist (for interpreted words)
   NEW.              \ clear the memory spaces
   HEX A000 ORIGIN.

\ constants must be defined in COMPILER space
\ They don't generate code until they are used

HEX 8C02 CONSTANT VDPWA     \ Write Address port
HEX 8C00 CONSTANT VDPWD     \ Write Data port

TARGET                 \ Use TARGET wordlist (to compile code)
CREATE TXT  S" Hello World!" S,

HEX
PROG: MAIN
  [ 0 LIMI,           \ disable interrupts
    8300 WORKSPACE    \ Fast ram for registers
    83BE RSTACK       \ and return stack
    83FE DSTACK ]     \ and Data stack

    0000 [ VDPWA C!]  \ store VDP address LSB
    4000 [ VDPWA C!]  \ store VDP address MSB + "write" bit

    TXT COUNT  1- FOR  COUNT [ VDPWD C!]  NEXT DROP

    BEGIN AGAIN
END.

COMPILER SAVE DSK2.HELLO2
