\ MachForth number output test program     Mar 2 2022  Brian Fox

COMPILER  \ preamble to set up target image
  NEW.
  HEX 2000 ORIGIN.

INCLUDE DSK2.STDLIB

COMPILER
CREATE TITLE$  S" Signed  Un-signed" S,

OPT-ON
DECIMAL         \ compiler interprets numbers as BASE 10

TARGET
PROG: DEMO11
      PAGE
      16 BASE !  \ **set the base for TARGET code number conversion to HEX

      8 9 AT-XY  TITLE$ COUNT TYPE
      32000      \ first number in count (the compiler is still in DECIMAL )
      OPT-OFF    \ for loops don't like optimizer (bug)
      2000
      FOR
          9 10 AT-XY  DUP .  DUP U.
          1+
      NEXT

      NEXT,
END.

\ DEMO11 RUN
