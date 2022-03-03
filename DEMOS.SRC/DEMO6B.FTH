\ Machine Forth DEMO6B   DO LOOP test

COMPILER
 NEW.
 HEX 2000 ORIGIN.

TARGET
: (DO) ( limit indx -- )       \ sub-routine because this is big 18 bytes
             R0  8000 LI,      \ load "fudge factor" to LIMIT
            *SP+ R0  SUB,      \ Pop limit, compute 8000h-limit "fudge factor"
             R0  TOS ADD,      \ loop ctr = index+fudge
             R0 RPUSH,
             TOS RPUSH,
             TOS DPOP,          \ refill TOS
;

: DO   (DO)  THERE ;

H: UNLOOP    RP 4 AI, ;H

H: LOOP ( addr --)
        *RP INC,            \ increment the index number
( addr) THERE 0 JOC, <BACK  \ compute, compile the jump
        UNLOOP              \ clean the return stack 2 items
        TOS DPOP,            \ ?? not sure what's going here
;H

H: +LOOP   TOS *RP ADD,  TOS DPOP,  LOOP ;H
H: I       TOS DPUSH,  *RP TOS MOV,  2 (RP) TOS SUB,  ;H

TARGET
VARIABLE X
PROG: DEMO6B
      FFFF 0
      DO
        I  X !     \ store loop index in X
      LOOP

      NEXT,        \ return to host FORTH
END.
