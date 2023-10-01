# MachForth for TI-99

This is a Native code compiler for 9900 modeled on machine Forth by Charles Moore with many liberties taken to accommodate the TMS9900 CPU.  

### Features
- Most Forth primitives are inlined due to the bulky sub-routine overhead of
the TMS9900. Stacks are emulated with normal registers.
- Top of stack is cached in Register 4 for a speed improvement on most words.
- Tail-call optimization is implemented with  -;  operator replacing ;
This is used manually by the programmer.
No error detection for misplacement at this time.


### Mar 3 2022
This is the first commit of a work in progress. Documentation is to follow.

### Nov 3 2022 V2.6
Fixed NEW. directive bug
Added CODE ENDCODE to make ASM words look like regular Forth Assembler
Added new syntax to force symbolic addressing mode for fetching and storing.
This lets the programmer improve size and speed significantly over pure
stack operations.

### Oct 1 2023
- R11 is now the top of return stack cache register 
- R8  is the for next loop index register. 
    'i' is used to get the loop index in your programs 
