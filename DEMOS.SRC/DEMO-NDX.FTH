\ MFORTH DEMO using indexed addressing

COMPILER  \ names space that has compiler directives
   NEW.
   HEX 2000 ORIGIN.
   OPT-ON

TARGET
PROG: DEMONDX
     [ 3F80 WORKSPACE  \ Workspace & stacks at high end of Low RAM
       3FD0 RSTACK
       3FF0 DSTACK ]

      2000
      FOR
         I@ DUP [ A000 +]!
      NEXT

     BEGIN ?TERMINAL UNTIL

     [ 0000 @@ BLWP, ]

END.

SAVE DSK2.DEMONDX



\ 2010  0646  dect R6
\ 2012  C584  mov  R4,*R6     \ save TOS register
\ 2014  0204  li   R4,>2000   \ put 2000 into TOS register
\ 2018  0647  dect R7
\ 201A  C5C8  mov  R8,*R7     \ save I register (for/next loop )
\ 201C  C204  mov  R4,R8      \ load I register from TOS
\ 201E  C136  mov  *R6+,R4    \ refill TOS  (DROP)
\ FOR  loop start
\ 2020  0646  dect R6         \ ** no optimizer **
\ 2022  C584  mov  R4,*R6     \ save TOS  (DUP)
\ 2024  0204  li   R4,>beef   \ load TOS with BEEF
\ 2028  0646  dect R6
\ 202A  C584  mov  R4,*R6     \ push TOS
\ 202C  C108  mov  R8,R4      \ load TOS with index value
\ 202E  C936  mov  *R6+,@>a000(R4)
\ 2032  C136  mov  *R6+,R4
\ 2034  0608  dec  R8
\ 2036  18F4  joc  >2020

\ 2010  0646  dect R6
\ 2012  C584  mov  R4,*R6
\ 2014  0204  li   R4,>2000
\ 2018  0647  dect R7
\ 201A  C5C8  mov  R8,*R7
\ 201C  C204  mov  R4,R8
\ 201E  C136  mov  *R6+,R4
\ 2020  0646  dect R6
\ 2022  C584  mov  R4,*R6
\ 2024  0204  li   R4,>beef
\ 2028  0646  dect R6
\ 202A  C584  mov  R4,*R6
\ 202C  C108  mov  R8,R4
\ 202E  C936  mov  *R6+,@>a000(R4)
\ 2032  C136  mov  *R6+,R4
\ 2034  0608  dec  R8
\ 2036  18F4  joc  >2020
