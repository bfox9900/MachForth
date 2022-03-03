\ MFORTH DEMO #3:   Use separate workspace, return to Forth

\ ************************************************************
\ * For finished programs you MUST always setup a WORKSPACE, *
\ * a DSTACK and an RSTACK .                                 *
\ ************************************************************

\ Compiler Preamble
  COMPILER
  NEW.
  HEX 2000 ORIGIN. \ Programs that return to Forth must run at 2000
  INCLUDE DSK1.BYE
HEX
TARGET
PROG: DEMO3
       3F80 WORKSPACE  \ Workspace & stacks at high end of Low RAM
       3FD0 RSTACK
       3FF0 DSTACK
       FFFF #
       BEGIN
       1- WHILE     \ * MForth WHILE does not consume parameter
          DUP>R     \ optimized: push counter onto RSTACK
          RDROP     \ optimized: throw it away
       REPEAT
       DROP
       8300 WORKSPACE   \ restore FORTH workspace
       NEXT,            \ return to Camel99 Forth
END.
CR .( Type RUN. Program returns to Forth)
