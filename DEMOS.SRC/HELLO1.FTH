\ tiny hello world in machine Forth Demo     Sept 23 2021  Fox
\ uses more common forth syntax, compiles to 146 bytes

COMPILER              \ Use compiler wordlist (for interpreted words)
   NEW.
   HEX A000 ORIGIN.
 
\ equates and constants must be defined in COMPILER space
\ They don't generate code until they are used
HEX
 8C02 CONSTANT VDPWA     \ Write Address port
 8C00 CONSTANT VDPWD     \ Write Data port

TARGET                 \ Use TARGET wordlist (to compile code)
CREATE TXT  S" Hello World!" S,

HEX 
PROG: MAIN
  [                   \ switch to interpreting 
    0 LIMI,           \ disable interrupts
    8300 WORKSPACE    \ Fast RAM for registers
    83E0 RSTACK       \ and return stack
    83FE DSTACK       \ and Data stack
  ]                   \ turn on compiler    

       0  VDPWA C!     \ store VDP address LSB
    4000  VDPWA C!     \ store VDP address MSB + "write" bit

    TXT COUNT  1- FOR  COUNT VDPWD C!  NEXT DROP

	  BEGIN AGAIN 
END.

COMPILER SAVE DSK2.HELLO1
