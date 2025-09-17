\ tiny hello world in machine Forth Demo     Nov 2 2022  Fox
\ Demonstrates sub-routines for screen I/O 
\ WMODE, XY>VDP AT-XY, BYE, EMIT+ PAGE TYPE 

COMPILER             \ Use compiler wordlist (for interpreted words)
   NEW.              \ clear the memory spaces
   HEX A000 ORIGIN.


COMPILER 
8C02 CONSTANT VDPWA     \ Write Address port
8C00 CONSTANT VDPWD     \ Write Data port
  20 CONSTANT BL        \ space char. (blank)

CREATE MSG1  S" Hello World!" S,
CREATE MSG2  S" Put text anywhere." S,
VARIABLE OUT    \ track the screen address 

TARGET 
\ set the VDP address in write mode 
: WMODE ( Vaddr --) 
\    [ 0 LIMI, ]        \ we can inline assembler 
    [ 4000 OR]          \ compile the ORI instruction 
    DUP [ VDPWA C!]     \ this not optimal but still pretty fast 
    ><  [ VDPWA C!] ;

\ (32 * +) xy to VDP address
: XY>VDP ( col row -- Vaddr ) [ 5 LSHIFT] +  ; 

: AT-XY  ( col row -- ) XY>VDP DUP OUT !  WMODE ; 

\ Native sub-routines created with colon

\ write CHAR, auto-incr. VDP address, drop char  
: EMIT+  ( char -- )  VDPWD C!  OUT 1+! ;

\ type string to screen, no scrolling.
: TYPE   ( addr len -- ) 1- FOR  COUNT  EMIT+  NEXT DROP ;

\ simple version 
\ : PAGE   0 0 AT-XY  300 FOR   21 EMIT+  NEXT ;

\ faster version 
: PAGE   
  0 0 AT-XY             \ set screen x,y
  OUT @ A!              \ get the y value into A register
  300 FOR  
      BL C!A+           \ TOS SWPB, TOS *AR+ MOVB,  
  NEXT  
  DROP ;

CODE BYE   0000 @@ BLWP,  ENDCODE 

HEX
PROG: MAIN
\ Setup Forth virtual machine
  [                   \ interpret mode
    0 LIMI,           \ disable interrupts
    8300 WORKSPACE    \ Fast ram for registers
    83F0 RSTACK       \ and return stack
    8400 DSTACK       \ and Data stack
  ]                   \ turn on compiler 

  [ DECIMAL ]         \ use interpreter to change radix  
    PAGE 
    10 0 AT-XY  MSG1 COUNT TYPE 
    5 15 AT-XY  MSG2 COUNT TYPE 
  \ With BYE we can exit safely when without resetting   
   BEGIN  ?TERMINAL UNTIL
   BYE
END.

COMPILER 
SAVE DSK2.HELLO3
