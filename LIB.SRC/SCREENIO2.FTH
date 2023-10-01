\ MACHFORTH SCREENIO library   Nov 6 2022 Brian Fox
\ Updated Aug 26 2023
 
TARGET NEEDS VWTR  FROM DSK2.VDPLIB2
 
[CC] DECIMAL
 
 
TARGET
VARIABLE ROW
VARIABLE COL
VARIABLE C/L    \ chars per line
VARIABLE C/SCR  \ chars per screen
VARIABLE VPG    \ VDP page
VARIABLE MEM    \ pointer to end of program memory
VARIABLE VMODE
 
: HERE   [ MEM @] ;  \ points to empty memory above program
 
: AT-XY  ( col row --) [ ROW !]   [ COL !] ;
 
: VPOS   ( -- Vaddr) [ ROW @] [ C/L @] *   [ COL @] + ;
 
: PAGE   ( -- ) 0 0 AT-XY  VPOS [ C/SCR @]  BL VFILL -;  \ tail call optimize
 
[CC] DECIMAL
 
\ TARGET  not needed in Version Aug 2023
: SCROLL ( Vaddr -- Vaddr)
      VPG @  DUP>R
      [ C/L @] +  HERE    [ C/SCR @]  [ C/L @]  - VREAD \ get 2nd line & below
      HERE R>  [ C/SCR @] [ C/L @] - VWRITE  \ write to 1st line
      0 23 AT-XY
      VPOS  [ C/L @] BL VFILL -; \ tail call
 
: CR    ( -- )
        COL OFF
        ROW DUP 1+! @ 23 > 
        IF SCROLL THEN DROP ;
 
: EMIT  ( c --)
        COL DUP 1+! @ [ C/L @] > 
        IF CR THEN DROP    \ needs DROP for IF
        VPOS VC! -; \ tail call
 
: SPACE ( -- ) BL EMIT -; \ tail call
 
: TYPE   ( addr len --) 1- FOR  COUNT EMIT  NEXT DROP ;
 
: SPACES ( n -- ) 1- FOR  SPACE  NEXT ;
 
\ FAST type, no protection!!
\ : VTYPE  ( addr len --) DUP>R  VPOS SWAP VWRITE  R> [ COL +!] ;
 
[CC] HEX
: SCREEN  ( n -- )  7 VWTR -;
: OUTPUT  ( n -- )  2 VWTR -;
 
: TEXT  ( -- )
         0F0 DUP 1 VWTR  [ 83D4 C!]
          0 OUTPUT
         17 SCREEN
         28 [ C/L !]
        3C0 [ C/SCR !]
          2 [ VMODE !]   \ 2=ID for 40 column "TEXT" mode
         PAGE -;
 
: GRAPHICS
         0  380 0 VFILL   \ clear screen and sprite table
         0E0 DUP 83D4 C!
             1 VWTR
             0  OUTPUT       \ set VDP screen page
         0E  3  VWTR
         01  4  VWTR
         06  5  VWTR
         01  6  VWTR
        380 13 10 VFILL   \ colortab/charset colors
            17 SCREEN     \ BLACK on CYAN
          20 -> C/L
         300 -> C/SCR
           1 -> VMODE
         PAGE -;
 
 \ =================================
\ *COMPILER DIRECTIVE to set MEM variable. MUST be used at end of program
 
COMPILER ALSO TARGETS ALSO FORTH
 
\ set program mem variable to compiler
H: CONCUR. ( -- ) THERE REL>TARG MEM T! ;H
\ =================================
 
COMPILER
 
