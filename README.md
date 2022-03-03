# MachForth for TI-99

This is a Native code compiler for 9900 modeled on machine Forth by Charles Moore
with many liberties taken to accommodate the TMS9900 CPU.  

### Features
- Most Forth primitives are inlined due to the bulky sub-routine overhead of
the TMS9900. Stacks are emulated with normal registers.
- Top of stack is cached in Register 4 for a speed improvement on most words.
- PUSH/POP optimizer removes three instructions on word boundaries when possible
- Tail-call optimization is implemented with  -;  operator replacing ;
This is used manually by the programmer.
No error detection for misplacement at this time.


### Mar 3 2022
This is the first commit of a work in progress. Documentation is to follow.
