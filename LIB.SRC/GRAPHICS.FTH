\ MACHFORTH GRAPHICS MODE Library               Mar 3 2022  Brian Fox

COMPILER
HEX
0380 CONSTANT CTAB      \ colour table VDP address

TARGET
 VARIABLE C/L
 VARIABLE C/SCR
 VARIABLE VMODE

HEX
: SCREEN   ( c --)  7 VWTR -;

: TEXT   ( -- )
    0 DUP 0 VWTR  \ TEXT MODE no external video 0
       83D4 C!
       00 2 VWTR  \ Text screen address         2
       F0 1 VWTR  \ 16k mem, interrupts on      1
       01 3 VWTR  \ Pattern table at $800       4
       00 4 VWTR  \ no color table              3
       00 5 VWTR  \ Sprite Att. table           5
       00 6 VWTR  \ Sprite Patt. table          6
       E1 SCREEN  \ GRAY on BLACK               7
       40 -> C/L
      3C0 -> C/SCR
        2 -> VMODE
       PAGE -;

: GRAPHICS
         0  380 0 VFILL   \ clear screen and sprite table
         0E0 DUP 83D4 C!
             1 VWTR
         0   2  VWTR      \ set VDP screen page
         0E  3  VWTR
         01  4  VWTR
         06  5  VWTR
         01  6  VWTR
        CTAB 13 10 VFILL  \ charset colors
             17 SCREEN    \ BLACK on CYAN
          20 -> C/L
         300 -> C/SCR
           1 -> VMODE
         PAGE -;
