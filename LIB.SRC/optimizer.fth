\ optimizer.fth  for MachForth 

\ Stack machine primitives can create overhead by needlessly
\ DROPing then DUPing the top of stack.
\ This program scans for the troublesome code sequence 
\ and removes the 6 byte sequence whereever it is found. 

HOST 

HEX 2000 CONSTANT CODEIMAGE 

\ search for u in memory block (addr,len)
\ return the new address and len or 0 if not found. 
: SCANW (  addr len u -- addr' len'|0)
        >R     \ remember char
        BEGIN 
          DUP
        WHILE ( len<>0)
          OVER @ R@ <>
        WHILE ( R@ <> u)
           2 /STRING  \ advance to next cell address
        REPEAT
        THEN
        R> DROP     \ 32 bytes
;

: D=   ( d d -- ?) ROT = -ROT = AND ;

: 2CONSTANT  CREATE SWAP  ,  ,  DOES> 2@ ;

HEX
     C136 CONSTANT 'DROP'
0646 C584 2CONSTANT 'DUP'

: FINDDROP  ( addr len -- addr' len' ?)
    'DROP' SCANW  DUP 0> ;

: DROP/DUP? ( addr len -- addr' len' ?)
    FINDDROP >R
    OVER  CELL+ 2@ 'DUP' D=
    R> AND ;

\ EXTRACT moves the binary program in memory
\ to remove the DROP/DUP sequence
: EXTRACT ( addr size -- )     
  >R                       \ save the size 
  DUP  3 CELLS +           \ compute new src address  
  SWAP                     \ addr is the dst address    
  R>                       \ compute new dst address
  ( src dst size ) MOVE    \ move the code 
  3 CELLS NEGATE TDP +!    \ adjust target program end pointer 
;

: PROGRAM  ( -- addr len ) CODEIMAGE TDP @ OVER - ;

: OPTIMIZE
    BEGIN
      PROGRAM DROP/DUP?
    WHILE 
      EXTRACT 
    REPEAT 
;

ALSO COMPILER DEFINITIONS 
: OPTIMIZE   OPTIMIZE ;

COMPILER 
