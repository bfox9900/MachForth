\ MACHFORTH DEMO #2:  different ways to assign to variables
\ Updated to MACHFORTH 2022

COMPILER
    NEW.
    HEX 2000 ORIGIN.


VARIABLE X
VARIABLE Y

PROG: DEMO2
  \   X @ Y ! 
  \   Y @ X ! 
  \   X @ Y ! 

    NEXT,    
END.
