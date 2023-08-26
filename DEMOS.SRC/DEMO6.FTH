\ MFORTH DEMO #6:    Using Variables and buffers

\ Compiler Preamble
  COMPILER
  NEW.
  HEX 2000 ORIGIN.

\  OPT-OFF

COMPILER     \ use COMPILER mode for data creation and allocation
VARIABLE X
VARIABLE Y
VARIABLE Z
CREATE BUFF   20 ALLOT

TARGET       \ use TARGET mode to generate program code
PROG: DEMO6 ( -- address)
\ prog: sets entry point of the program & names it. Returns address
      X OFF            \ set X to 0
      Y OFF            \ set Y TO 0
      Z ON             \ set Z to true (-1)

      41  X C!         \  conventional Forth syntax works fine
      43 [ Y C!]       \  compiles symbolic addressing mode: ( MOVB R4,@Y )

      44  BUFF 1+  C!  \  simple indexing into a buffer
      45  BUFF 2+  C!
      46  BUFF 3 + C!

      BEEF Z !         \ conventional Forth syntax works
      DEAD [ Z !]      \ compile symbolic addressing mode. Faster & smaller

      NEXT,            \ return to MachForth command line
END.                   \ end tests program size, tests for stack junk
                       \ prints small report

\ DEMO6 RUN   will make it go and return to Forth
