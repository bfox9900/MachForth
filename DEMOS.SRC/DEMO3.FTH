\ MFORTH DEMO #3:   Use different workspace, return to Forth workspace

\ ************************************************************
\ * For finished programs you MUST always setup a WORKSPACE, *
\ * a DSTACK and an RSTACK .                                 *
\ ************************************************************

\ Compiler Preamble
  COMPILER
  NEW.
  HEX 2000 ORIGIN. \ Programs that return to Forth must run in LOW RAM

HEX
TARGET
PROG: DEMO3
     [ 3F80 WORKSPACE  \ Workspace & stacks at high end of Low RAM
       3FD0 RSTACK
       3FF0 DSTACK ]
       FFFF
       BEGIN
       1-
       WHILE        \ * MachForth WHILE does not consume parameter
          DUP>R     \ push copy of counter onto RSTACK
          RDROP     \ throw it away
       REPEAT
       DROP
     [ 8300 WORKSPACE ]  \ restore FORTH workspace
       NEXT,            \ return to Camel99 Forth
END.
COMPILER
CR .( Type DEMO3 RUN. Program returns to Forth)
TARGET
