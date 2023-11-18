\ This is an excercise to explore replacing stack operations Nov 9 2023 
\ with registers or memory operations


\ ** DUP ** 
\  After DUP two args exist  TOS and *SP 
\ In many situation we could remove DUP in our code by simply
\ referencing *SP directly or referencing TOS twice. 

\  Consider   DUP >R  
\  This need 5 instructions
\        SP DECT,
\   TOS *SP MOV,    \ push TOS 
\        RP DECT,    
\   TOS *RP MOV,    \ rpush tos 
\   *SP+ TOS MOV,   \ pop tos 

\ When in fact all we need is:
\         RP DECT, 
\    TOS *RP MOV, 

\ Using stack diagrams to inform the compiler 

\ Examples 
: ! ( n addr -- ) \ empty stack output sets flag to add TOS POP, (refill)

: + ( n1 n2 -- n) \ output n means we DO NOT refill TOS register  
    
\ Given 
  : n)  REFILL ON ;
  : )   REFILL OFF ;
   
  : ?REFILL     REFILL @ IF  TOS POP,   THEN ;
  : DUPLICATE   DUPPED @ IF  TOS PUSH,  THEN ;

CREATE <NOS>  8 ALLOT 
CREATE <3RD>  8 ALLOT 

: NOS=  1 PARSE  <NOS> PLACE ;

\ NOS is text macro. <NOS> contents are changed by the compiler 
: NOS   <NOS> COUNT EVALUATE ;

: +  ( n n -- n)  NOS TOS ADD, ;

: OVER  NOS= *SP ;

\ Compiler definitions become:
: DROP       ?REFILL ;
: DUP        DUPLICATE       ?REFILL ; 
  
: >R  ( n -- )  TOS RPUSH,   ?REFILL ; 









