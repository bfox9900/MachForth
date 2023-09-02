\ tiny hello world in machine Forth Demo     Nov 2 2022  Fox
\ Demonstrates sub-routines VDPWRITE, XY>VDP AT-XY, TYPE 

COMPILER             \ Use compiler wordlist (for interpreted words)
   NEW.              \ clear the memory spaces
   HEX A000 ORIGIN.


\ constants must be defined in COMPILER space
\ They don't generate code until they are used
COMPILER
HEX 8C02 CONSTANT VDPWA     \ Write Address port
HEX 8C00 CONSTANT VDPWD     \ Write Data port

TARGET                 \ Use TARGET wordlist (to compile code)
CREATE MSG1  S" Hello World!" S,

\ set the VDP address in write mode 
: VDPWRITE ( Vaddr --) 
    [ 0 LIMI,  
      4000 OR] 
      DUP [ VDPWA C!] 
      >< [ VDPWA C!] ;

\ convert xy to VDP address
: XY>VDP  ( col row -- Vaddr ) [ 5 LSHIFT]  + ;

: AT-XY ( col row -- ) XY>VDP VDPWRITE ;
: TYPE  ( addr len  -- ) COUNT  1- FOR  COUNT [ VDPWD C!]  NEXT DROP ;

HEX
PROG: MAIN
  [ 0 LIMI,           \ disable interrupts
    8300 WORKSPACE    \ Fast ram for registers
    83BE RSTACK       \ and return stack
    83FE DSTACK       \ and Data stack
  DECIMAL ]
  
    10 0 AT-XY  MSG1 TYPE 
    15 15 AT-XY MSG1 TYPE 

    BEGIN AGAIN       \ loop forever
END.

COMPILER SAVE DSK2.HELLO3
