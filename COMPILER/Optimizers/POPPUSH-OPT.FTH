\ poppush optimizer
\ This idea failed because the logic is not correct for all
\ cases. More work needed.

C136 CONSTANT 'DROP'   \ 9900 machine code for DROP (*SP+ R4 MOV,)
VARIABLE DROPS         \ count when DROP, is executed
VARIABLE #OPTS         \ # of optimizations made
VARIABLE #DUPS         \ # of DUPS made

: DUP,     ( n -- n n)  TOS DPUSH, #DUPS 1+! ;  \ normal dup
: DROP,    TOS DPOP,  DROPS 1+! ; \ count each drop

: LOOKBACK ( -- u)  THERE 2- @ ; \ fetch previous instruction code

: OPT-DUP, ( n -- n ?n)
  #DUPS @ 2 <  ( this is PFM )
  IF  \ not enough DUPS were done so we must do one
     DUP,
  ELSE
      LOOKBACK 'DROP' =     \ look back for DROP
      IF
         -2 TALLOT          \ move target dictionary ie: erase DROP
         #OPTS 1+!
      ELSE
          DUP,
      THEN
  THEN
;

DEFER SMARTDUP,     ' DUP, IS SMARTDUP,   \ default is unoptimized
