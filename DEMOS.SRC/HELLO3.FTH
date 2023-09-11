\ tiny hello world in machine Forth Demo     Nov 2 2022  Fox
\ Demonstrates sub-routines VDPWRITE, XY>VDP AT-XY, TYPE 

COMPILER             \ Use compiler wordlist (for interpreted words)
   NEW.              \ clear the memory spaces
   HEX A000 ORIGIN.

\ constants are defined in COMPILER space
\ They don't generate code until they are used
COMPILER
HEX 8C02 CONSTANT VDPWA     \ Write Address port
HEX 8C00 CONSTANT VDPWD     \ Write Data port

TARGET    \ TARGET wordlist is the program name space
CREATE MSG1  S" Hello World!" S,
CREATE MSG2  S" Put text anywhere." S,

\ set the VDP address in write mode 
: VDPWRITE ( Vaddr --) 
    [ 0 LIMI, ]         \ we can inline assembler 
    [ 4000 OR]          \ compile the ORI instruction 
    DUP [ VDPWA C!]     \ this not optimal but still pretty fast 
    ><  [ VDPWA C!] ;

: XY>VDP ( col row -- Vaddr ) [ 5 LSHIFT] + ; \ (32 *  +) xy to VDP address
: AT-XY  ( col row -- ) XY>VDP VDPWRITE ;     
: TYPE   ( addr len -- ) 1- FOR  COUNT [ VDPWD C!]  NEXT DROP ;

CODE BYE   0000 @@ BLWP,  ENDCODE 

HEX
PROG: MAIN
\ Setup Forth virtual machine
  [ 0 LIMI,           \ disable interrupts
    8300 WORKSPACE    \ Fast ram for registers
    83F0 RSTACK       \ and return stack
    8400 DSTACK       \ and Data stack
  ] 

  [ DECIMAL ]
    10 0 AT-XY  MSG1 COUNT TYPE 
    5 15 AT-XY  MSG2 COUNT TYPE 
     
   65535 FOR  R@ DROP R@ DROP  NEXT \ delay

  BYE
END.



COMPILER 
\ TOSOPT REPORT #DUPS ? 

SAVE DSK2.HELLO3
