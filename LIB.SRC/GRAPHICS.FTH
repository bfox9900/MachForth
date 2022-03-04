\ MACHFORTH GRAPHICS MODE Library               Mar 3 2022  Brian Fox
HEX
: SCREEN   ( c --) 7  VWTR -;

: GRAPHICS
         0  380 0 VFILL   \ clear screen and sprite table
         0E0 DUP 83D4 C!
             1 VWTR
         0   2  VWTR      \ set VDP screen page
         0E  3  VWTR
         01  4  VWTR
         06  5  VWTR
         01  6  VWTR
         380 10 10 VFILL  \ charset colors
             17 SCREEN    \ BLACK on CYAN
         20  C/L !
         300 C/SCR !
         1 VMODE !
         PAGE 
;
