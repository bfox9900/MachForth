\ MFORTH DEMO #3:   Use separate workspace, add a sub-routine
\ return to Forth

\ ************************************************************
\ * For finished programs you MUST always setup a WORKSPACE, *
\ * a DSTACK and an RSTACK .                                 *
\ ************************************************************
\ Compiler Preamble
  COMPILER
  NEW.
  HEX 2000 ORIGIN. \ Programs that return to Forth must run at 2000

TARGET
: MYSUB
       FFFF #
       BEGIN
       1- WHILE   \ * MForth WHILE does not consume parameter
          DUP>R   \ push counter onto RSTACK
          RDROP   \ throw it away
       REPEAT
       DROP
;

\ PROG: section is now only for system setup and calling our program
PROG: DEMO4
        3F80 WORKSPACE  \ Workspace & stacks at high end of Low RAM
        3FD0 RSTACK
        3FF0 DSTACK

        MYSUB

       8300 WORKSPACE   \ restore FORTH workspace
       NEXT,            \ return to Camel99 Forth
END.
