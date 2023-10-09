\ numbers.fth  MachForth number printing lib
COMPILER
\ constants declared in compiler space
\  CHAR 0 EQU '0'
  CHAR - CONSTANT '-'
HEX 3FFF CONSTANT #BUFF \ top end of low RAM used as digit buffer

TARGET
INCLUDE DSK2.UMMOD

VARIABLE BASE
VARIABLE HP

DECIMAL
: >DIGIT  ( n -- c)
      [ TOS 9 CI,
        HI IF,
            TOS 7 AI,
        ENDIF,
        TOS 30 AI, ]
;

TARGET
\ : HOLD   ( char -- )  HP DUP 1-! @ C! ;  \ 11 instructions
: HOLD  ( char -- )  \ 5 instructions
       [ HP @@ DEC,
         HP @@ R1 MOV,
         TOS SWPB,
         TOS R1 ** MOVB, ]
         DROP
;

\ [ BASE #@ ] does symbolic addressing to fetch variable faster
: #      ( u -- ud2 )
      0 [ BASE @] UM/MOD >R    \ compute & save high side of 32 bit int.
        [ BASE @] UM/MOD SWAP  \ compute low side, swap quotient & remainder
        >DIGIT HOLD
        R>                     \ high side to TOS
;

: <#     ( --) #BUFF -> HP ;
: #S     ( ud1 -- ud2)  BEGIN  #  [ *SP TOS CMP, ] = UNTIL ;
: #>     ( ud1 -- c-addr u) DROP DROP HP @ #BUFF OVER - ;
: SIGN   ( n -- ) 0 < IF  '-' HOLD  THEN DROP ;
: UD.    ( d -- ) <#  #S  #> TYPE SPACE -;
: U.     ( u -- ) 0 UD. -;
: .      ( n -- ) DUP>R ABS  0 <#  #S  R> SIGN  #> TYPE SPACE -;
