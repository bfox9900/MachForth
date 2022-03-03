\ MACHFORTH GRAPHICS MODE Library               Mar 3 2022  Brian Fox

 \ ** not integrated with SCREEN I/O  yet**

VARIABLE C/L
VARIABLE C/SCR
VARIABLE VMODE

HEX
: GRAPHICS
         0 # 380 #  0 # VFILL
         0E0 # DUP 83D4 #C!  1 # VWTR
         0 #  2 # VWTR    \ set VDP screen page
         0E # 3 # VWTR
         01 # 4 # VWTR
         06 # 5 # VWTR
         01 # 6 # VWTR
         380 # 10 # 10 # VFILL  \ charset colors
         17 # 7 # VWTR          \ screen color
         20 # C/L !
         300 # C/SCR !
         1 # VMODE !
         0 300 20 VFILL        \ clear screen
-;
