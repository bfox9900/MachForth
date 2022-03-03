CR .( DO/LOOP with loop index register)

COMPILER
\ The following words are compiler directives
\ they take no program space until used in a program
H: UNLOOP
         R8 RPOP,         \ R8 is the loop counter register
         RP INCT,  ;H

H: LOOP ( addr --)
         R8 INC,          \ increment the index Register
         OV.UNTIL         \ compile JUMP back until over-flow
         UNLOOP
;H

H: +LOOP
        TOS R8 ADD,
           TOS DPOP,
        LOOP
;H

\ *WARNING*
\ 'I' is a name conflict with register I in XASSEMBLER vocabulary
\ Use R8 in your assembler code after this to be safe
H: I
           TOS DPUSH,
        R8 TOS MOV,
    2 (RP) TOS SUB,
;H

\ This word compiles the DO/LOOP setup sub-routine
\ simple leaf sub-routine saves space when building the do/loop
L: (DO)
    [  R0 8000 LI,       \ load "fudge factor"
      *SP+  R0 SUB,      \ LIMIT, compute 8000h-limit "fudge factor"
       R0  TOS ADD,      \ loop ctr = index+fudge
           R0  RPUSH,    \ rpush limit
           R8  RPUSH,    \ rpush old index in R8
       TOS R8  MOV,      \ new index -> R8
           TOS DPOP,     \ refill TOS
               RT, ]

H: DO ( limit indx -- )
        R11 DPUSH,  \ save R11 on data stack. (DO) pushes onto Rstack
    (DO) @@ BL,
        R11 DPOP,   \ restore R11
        POSTPONE BEGIN
;H
