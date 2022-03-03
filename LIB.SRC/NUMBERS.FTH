\ NUMBER OUTPUT lib for MachForth    Mar 3 2022  Brian Fox

COMPILER
\ constants declared in compiler space
  CHAR 0 CONSTANT '0'
  CHAR - CONSTANT '-'
HEX 3FFF CONSTANT #BUFF \ top end of low RAM used as digit buffer

\ REQUIRES DSK2.SCREENIO

OPT-ON
TARGET
VARIABLE BASE
VARIABLE HP

: UM/MOD ( ud u1 -- u2 u3 )  \ numerator(32bits), divisor -- rem,quot
         TOS  R0 MOV,     \ divisor->R0
         *SP+ TOS MOV,     \ POP high word into TOS
         *SP   R5 MOV,     \ MOVE low word to r5
          R0  TOS DIV,     \ perform unsigned division
          R5  *SP MOV,     \ push remainder
;

DECIMAL
\ : >DIGIT   9 >IF DROP 7 + THEN DROP '0' +  ; \ does not work ??
: >DIGIT  ( n -- c)
        [ TOS 9 CI,
          HI IF,           \ if n>9
              TOS 7 AI,    \ number is not base 10, add 7
          ENDIF,
          TOS '0' AI, ]    \ add ASCII 0 to TOS create char value
;

\ : HOLD   ( char -- )  HP DUP 1-! @ C! ;  \ 11 instructions
: HOLD  ( char -- )  \ 5 instructions
       [ HP @@ DEC,
         HP @@ R1 MOV,
         TOS SWPB,
         TOS R1 ** MOVB, ]
         DROP
;

\ [ BASE #@ ] does symbolic addressing to fetch a variable
: #      ( u -- ud2 )
      0 [ BASE #@ ] UM/MOD >R    \ compute & save high side of 32 bit int.
        [ BASE #@ ] UM/MOD SWAP  \ compute low side, swap quotient & remainder
        >DIGIT HOLD
        R>                       \ high side to TOS
;

: <#     ( --) #BUFF -> HP ;  \ TOS->symbolic store. Smaller & faster

\ '=='  is non-destructive comparison of TOS & NOS  ( C R4,*SP )
: #S     ( ud1 -- ud2)  BEGIN  #  == -UNTIL  ;
: #>     ( ud1 -- c-addr u) DROP DROP HP @ #BUFF OVER - ;
: SIGN   ( n -- ) 0 <IF  '-' HOLD  THEN DROP ;
: UD.    ( d -- ) <#  #S  #> TYPE SPACE -;
: U.     ( u -- ) 0 UD. -;
: .      ( n -- ) DUP>R ABS  0 <#  #S R@ SIGN  #> RDROP TYPE SPACE -;
