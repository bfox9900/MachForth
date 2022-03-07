\ MachForth Return to E/A5 menu screen
\ works best if you are in GRAPHICS mode

TARGET
: MENU
     [ R0 CLR,
       R0 837C @@ MOV,
       83E0 LWPI,
       0070 @@ B, ]
;
