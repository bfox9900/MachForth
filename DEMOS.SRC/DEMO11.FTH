\ MachForth number output test program     Mar 2 2022  Brian Fox

COMPILER  \ preamble to set up target image
  NEW.
  HEX 2000 ORIGIN.

INCLUDE DSK2.STDLIB

TARGET
CREATE TITLE$  S" Signed  Un-signed" S,

DECIMAL          \ compiler interprets numbers as BASE 10

PROG: DEMO11
      TEXT 
      16 BASE !  \ **set the base for TARGET code number conversion to HEX

      8 9 AT-XY  TITLE$ COUNT TYPE
      8 10 AT-XY  1234 .     1234 U. 
 \     32000      \ first number in count (the compiler is still in DECIMAL )
 \     2000
 \     FOR
 \         9 10 AT-XY  DUP .  DUP U.
 \         1+
 \     NEXT

      NEXT,
END.

\ DEMO11 RUN
