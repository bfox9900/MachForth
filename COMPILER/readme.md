## MachForth Compiler Source Notes Version 2.6

The source code for the MachForth target compiler is here for reference.
It is build on Camel99 Forth for the TI-99/4A computer.

The binary executable program (3 files) for TI-99 are in the folders:  
MachForth/COMPILER/bin
MachForth/TI99/DSK2/

The program called MACHFORTH is about 19.5K bytes which includes the 8K
Forth kernel consumes almost all the contiguous RAM in the TI-99.
The programs are compiled into the 8K "low RAM" memory of the TI-99.

V2.6 Notes:

NEW.  fixed bug that was detroying the MFORTH vocabulary name space

Added new syntax to force symbolic addressing. 
See demo program: HELLO3B for code example
