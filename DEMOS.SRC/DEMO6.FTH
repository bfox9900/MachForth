\ MFORTH DEMO #6:    Using Variables

\ Compiler Preamble
  COMPILER
  NEW.
  HEX 2000 ORIGIN.

  OPT-ON

TARGET
VARIABLE X
VARIABLE Y
VARIABLE Z

\ prog: directive sets the entry point of the program & names it.
PROG: DEMO6
      X OFF            \ set X to 0
      Y OFF            \ set Y TO 0
      Z ON             \ set Z to true (-1)

      41  X C!         \  conventional Forth. X goes onto stack
      43 [ Y #C! ]     \  compiles symbolic addressing mode: ( MOVB R4,@Y )
      44  Y  1+ C!     \ indexing memory convert to #, then to math
      BEEF Z !         \ conventional Forth syntax works
      DEAD -> Z        \ compile symbolic addressing mode. Faster & smaller

      NEXT,            \ return to Camel99 Forth
END.                   \ end tests program size, tests for stack junk
                       \ prints small report

\ DEMO6 RUN   will make it go and return to Forth
