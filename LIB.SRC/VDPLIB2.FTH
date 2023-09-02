\ VDPLIB.FTH library  for MACHFORTH V2023  Update Sep 1 2023  Fox
\ re-write using as much machine Forth as possible
\ ~274 bytes

COMPILER
HEX
8800 CONSTANT VDPRD
8802 CONSTANT VDPSTS
8C00 CONSTANT VDPWD
8C02 CONSTANT VDPWA

TARGET
CODE VDPADR! ( Vaddr -- Vaddr)  \ set vdp address **returns the address!! 
      R1 STWP,
      0 LIMI,
      9 R1 () VDPWA @@ MOVB,  \ write oddddyte from TOS (ie: R4)
      TOS     VDPWA @@ MOVB,  \ MOV writes the even byte to the port address
ENDCODE

: VC@    ( addr -- c)
    VDPADR!  
    [ 
      TOS CLR,
      VDPRD @@ 9 R1 () MOVB,  \ read data into odd byte of R4
    ] 
;

: VC! ( c Vaddr -- )
    [ 4000 OR]               \ TOS ORI, instruction used 
      VDPADR!  
      DROP                      \ c -> TOS 
    [ 9 R1 () VDPWD @@ MOVB, ]  \ Odd byte R4, write to screen
    DROP                       \ refill TOS
;

HEX
\ * VDP write to register. Kept the TI name
: VWTR   ( c reg -- )   \ Usage: 5 7 VWTR
    >< +         \ combine 2 bytes to one cell
    [ 8000 OR] VDPADR!
;

: VFILL ( Vaddr cnt char -- )
    >< >R           \ swap TOS bytes & save CHAR
    SWAP 
    VDPADR!        
    VDPWD A!        \ VDP write port -> A register  
    R>              ( -- char cnt)
    FOR             ( -- char)
      DUPC!A       \ TOS *A MOVB, 
    NEXT 
    DROP 
;

: VREAD ( Vaddr addr n --)
    >R                     \ Move len into R11 (loop index)
    A!       
    VDPADR! DROP
    BEGIN   ( R> FOR) 
      [ VDPRD @@  *A+ MOVB, ]
    NEXT
    DROP
;

: VWRITE ( addr Vaddr len -- )
    >R                    \ Move len into R11 (loop index)
    [ 4000 OR]            \ set write bit in Vaddr
    VDPADR! DROP          \ set VDP write address
    VDPWD A!              \ store VDP write data port in A register
    DROP 
    BEGIN  ( R> FOR ) 
      [ *TOS+ *A  MOVB, ]
    NEXT
    DROP
;
