CR .( DO/LOOP with loop index register)
 
COMPILER
\ The following words are Assembler Macros.
\ H: ;H  are just Camel99 Forth's colon/semi-colon re-named, to make macros
\ Macros use no program space until used in a program
H: UNLOOP
         R9 RPOP,         \ R9 is the "index" register
         RP INCT,         \ pop limit on R stack
;H
 
H: LOOP ( addr --)
         R9 INC,         \ increment the index Register
         THERE 0 JNO, <BACK
         UNLOOP
;H
 
H: +LOOP
        TOS R9 ADD,
           TOS POP,
        LOOP
;H
 
\ *WARNING*
\ 'I' is a name conflict with register I in XASSEMBLER vocabulary
\ Use R8 in your assembler code after this to be safe
H: I
           TOS PUSH,
        R9 TOS MOV,
    2 (RP) TOS SUB,
;H
 
H: J
           TOS PUSH,
    4 (RP) TOS MOV,   \ outer loop index is on the rstack
    6 (RP) TOS SUB,   \ index = loopindex - fudge
;H
 
\ This sub-routine setsup the RStack for DO/LOOP.
\ It's a "leaf" sub-routine so we must save R11 before calling it
L: (DO)
    [  R0 8000 LI,       \ load fudge_factor
      *SP+ R0  SUB,      \ LIMIT = fudge_factor - limit
           R0  RPUSH,    \ rpush limit
       R0  TOS ADD,      \ loop cntr = index+fudge
           R9  RPUSH,    \ save R9
       TOS R9  MOV,      \ new index -> R9
           TOS POP,     \ refill TOS
               RT, ]
 
H: DO ( limit indx -- )
        R11 PUSH,  \ save R11 on data stack. (DO) pushes onto Rstack
        (DO) @@ BL,
        R11 POP,   \ restore R11
        THERE
;H
 
