\ -TRAILING for machine Forth
\ mixing MachForth and assembler to reduce stack shuffling 
HEX
: -TRAILING ( addr len -- addr len')
    [ *SP TOS ADD, ]   \ compute end of string. Don't destroy *SP
      1-               \ move back 1 char
    [ R1 2000 LI, ]    \ R1 = BL
      BEGIN
        [ *TOS R1 CMPB, ]
      -WHILE
          1-           \ move back 1 char
      REPEAT
   [  *SP TOS SUB, ]
      1+
;
