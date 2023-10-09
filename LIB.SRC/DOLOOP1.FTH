\ DOLOOP ANS Forth conventional with counter on R stack  Oct 2023 Fox 

TARGET
\ this is a resident sub-routine 
L: (DO)  ( limit indx -- ) \ setup R stack for looping 
    [ R0 8000 LI,    \ load "fudge factor" to LIMIT
     *SP+ R0  SUB,   \ Pop limit, compute 8000h-limit "fudge factor"
      R0  TOS ADD,   \ loop ctr = index+fudge
          R0  RPUSH,
          TOS RPUSH,
          TOS POP,   \ refill TOS
              RT, ]

\ These MACROS generate inline code 
COMPILER 
H: UNLOOP 
        RP  4 AI,        \ collapse rstack frame
;H

H: LOOP ( addr --)
        *RP INC,         \ increment the index Register
        THERE 0 JNO, <BACK
        UNLOOP
;H
 
H: +LOOP
        TOS *RP ADD,
        TOS POP,
        LOOP
;H


ALSO TARGETS 
H: DO ( limit indx -- )
        R11 PUSH,  \ save R11 on data stack. (DO) uses Rstack
        (DO) @@ BL,
        R11 POP,   \ restore R11
        THERE
;H
 
COMPILER 
H: I      ( -- n)
        TOS PUSH,        
        *RP    TOS MOV, 
        2 (RP) TOS SUB,    
;H 

H: J      ( -- n)
        TOS PUSH,
        4 (RP) TOS MOV,   \ outer loop index is on the rstack
        6 (RP) TOS SUB,   \ index = loopindex - fudge
;H 

