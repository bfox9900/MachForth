\ MachForth number output test program     Mar 2 2022  Brian Fox

COMPILER  \ preamble to set up target image
  NEW.
  HEX 2000 ORIGIN.

\ load dependancies
INCLUDE DSK2.SCREENIO
INCLUDE DSK2.NUMBERS

COMPILER
CREATE TITLE$  S" Signed  Un-signed" S,

OPT-OFF
DECIMAL         \ compiler interprets numbers as BASE 10

TARGET
PROG: MAIN
      PAGE
      16 BASE !  \ **set the base for TARGET code number conversion

      8 9 AT-XY  TITLE$ COUNT TYPE
      32000      \ first number in count (the compiler is still in DECIMAL )
      2000
      FOR
          9 10 AT-XY  DUP .  DUP U.
          1+
      NEXT

      NEXT,
END.

TARGET
