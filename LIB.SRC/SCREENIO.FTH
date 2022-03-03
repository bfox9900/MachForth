\ SCREENIO library for MachForth  Feb 2022 Brian Fox

INCLUDE DSK2.VDPLIB

COMPILER
DECIMAL
 40 CONSTANT C/L    \ chars per line
960 CONSTANT C/SCR  \ chars per screen
920 CONSTANT 23LINES

OPT-ON

TARGET
VARIABLE ROW
VARIABLE COL
VARIABLE MDP  \ you must patch this at end of program 

: MFHERE  MDP @ ;    \ points to empty memory above CODE

: AT-XY  ( col row --) ROW !  COL ! ;
: VPOS   ( -- Vaddr) ROW @ C/L *  COL @ + ;
: PAGE   ( -- ) 0 0 AT-XY  VPOS C/SCR  BL VFILL -;  \ tail call optimize

: SCROLL ( Vaddr -- Vaddr) \ full-screen buffer. wasteful but fast
        0
        DUP  C/L +  MFHERE 23LINES VREAD   \ get 2nd line
        MFHERE      OVER   23LINES VWRITE  \ write to 1st line
        DROP
        0 23 AT-XY
        VPOS C/L BL VFILL -;  \ tail call optimize

: CR    ( -- )
        COL OFF
        ROW DUP 1+! @ 24 >IF  SCROLL  THEN DROP ;

: EMIT  ( c --)
       ROW @ C/L *  COL @ +  VC!
       COL DUP 1+! @  C/L 1- >IF  CR  THEN DROP ;

: TYPE   ( addr len --) FOR  COUNT EMIT  NEXT DROP ;

: SPACE  ( -- )   BL EMIT -; \ tail call optimize
: SPACES ( n -- ) FOR  SPACE  NEXT ;
\ 656 bytes including VDPLIB
\ 674 bytes OPT-OFF