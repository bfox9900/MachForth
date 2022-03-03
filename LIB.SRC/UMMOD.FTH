\ UMMOD.FTH

: UM/MOD ( ud u1 -- u2 u3 ) \ numerator(32bits), divisor -- rem,quot
              TOS  R0 MOV,     \ divisor->R0
             *SP+ TOS MOV,     \ POP high word into TOS
             *SP   R5 MOV,     \ MOVE low word to r5
              R0  TOS DIV,     \ perform unsigned division
              R5  *SP MOV,     \ push remainder
;
