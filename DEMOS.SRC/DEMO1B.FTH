\ MACHFORTH DEMO #1B  Minimum stand-alone binary program  
\ On Classic99 debugger you will see R4 counting up and rolling over

\ This demo shows how to:
\  1. Compile to hex 2000 origin
\  2. Set the workspace and stacks in 16bit scratch-pad RAM
\  3. Write a callable CODE word that exits the program 
\  4. Use inline Assembler with CODE ENDCODE
\  6. Demonstrate turning compiler on/off inside the code
\  5. Save a finished program that can RUN from E/A Option 5

COMPILER            \ names space that has compiler directives

   NEW.             \ init heap memory, clear TARGET vocabulary
   HEX 2000 ORIGIN.

\ code word that returns to TI-99 splash page 
CODE BYE
   0 LIMI,
   83C4 @@ CLR,
   0000 @@ BLWP, 
ENDCODE 

( this loop completes in ~500mS)
PROG: DEMO1
   [ ( switch to interpret mode, because these are assembler macros )
      8300 WORKSPACE  \ place registers in 16 bit RAM 
      8400 DSTACK     \ set data stack in 16 bit RAM 
      83F0 RSTACK     \ set return stack in 16 bit RAM   
   ] ( switch back to compile mode )  

   FFFF            \ Literal numbers go onto data stack
   BEGIN
     1-            \ dec # on top of data stack
   -UNTIL          \ MACHINE FORTH's "not until" operator
   DROP            \ remove number from data stack.
   BYE             \ goto ti99 ROM monitor
END. 

SAVE DSK2.DEMO1B
