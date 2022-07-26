\ MACHINE FORTH COMPILER     Dec 14, 2020  Brian Fox, Kilworth Ontario
\ This file compiles with Camel99 Forth V2.6x in DSK1. MFORTHASM in DSK2.

\ Feb 2022: DROP/DUP optimizer counts DUPs. No optimizing until DUPS>1

\ *To cross-compile a program
\  With the MACHFORTH ready type: INCLUDE <DSK2.MYPROGRAM>

NEEDS FORTH     FROM DSK1.WORDLISTS

ONLY FORTH DEFINITIONS

NEEDS LOAD-FILE FROM DSK1.LOADSAVE
NEEDS .S        FROM DSK1.TOOLS
NEEDS DEFER     FROM DSK1.DEFER
NEEDS ELAPSE    FROM DSK1.ELAPSE
NEEDS U.R       FROM DSK1.UDOTR
NEEDS MARKER    FROM DSK1.MARKER
NEEDS ORG       FROM DSK2.MFORTHASM

\ _________________________________________________
CR .( CROSS-COMPILER Name Spaces)

ONLY FORTH DEFINITIONS ALSO XASSEMBLER
VOCABULARY MFORTH     \ for mforth compiler words
VOCABULARY TARGETS   \ for words in the compiled program

\ *NEW* STATE smart lit, compiles or interprets.
\ This allows VARIABLES and CONSTANTS to be used in Assembler code
\ without using tick.
VARIABLE XSTATE  \ CROSS-COMPILER state variable

\ __________________[ pop/push optimizer ]____________________
\ Keeping the top of stack (TOS) in register means that everytime we need
\ a new value in the TOS we must push the current value in the TOS register.
\ This is functionally a DUP instruction.
\ This also means that at the end of many Forth words there is a DROP
\ to refill the TOS register. This is one 9900 instruction. (>C136)
\ This optimizer scheem uses this instruction as a cue that TOS register
\ is free to use and therefore the entire DROP/DUP code can be omitted.

HEX
C136 CONSTANT 'DROP'   \ 9900 machine code for DROP (*SP+ R4 MOV,)
VARIABLE DROPS         \ count when DROP, is executed
VARIABLE #OPTS         \ # of optimizations made
VARIABLE #DUPS         \ # of DUPS made

: DUP,     ( n -- n n)  TOS DPUSH, #DUPS 1+! ;  \ normal dup
: DROP,    TOS DPOP,  DROPS 1+! ; \ count each drop

: LOOKBACK ( -- u)  THERE 2- @ ; \ fetch previous instruction code

: OPT-DUP, ( n -- n ?n)
  #DUPS @ 2 <  ( this is PFM )
  IF  \ not enough DUPS were done so we must do one
     DUP,
  ELSE
      LOOKBACK 'DROP' =     \ look back for DROP
      IF
         -2 TALLOT          \ move target dictionary ie: erase DROP
         #OPTS 1+!
      ELSE
          DUP,
      THEN
  THEN
;

DEFER SMARTDUP,     ' DUP, IS SMARTDUP,   \ default is unoptimized

XASSEMBLER DEFINITIONS
: LIT,  ( n -- )
    XSTATE @
    IF               \ IF CROSS-compiling, emit machine code
       SMARTDUP,     \ push TOS if we need to.
       TOS SWAP LI,  \ compile n as a literal number into R4.
    THEN  ;          \ If interpreting just put n on Forth stack .

ONLY FORTH DEFINITIONS ALSO XASSEMBLER
: <MFINTERP> ( c-addr u -- ) \ machforth compiler interpret loop
         'SOURCE 2!  >IN OFF
          BEGIN
              BL WORD DUP C@ ( -- addr len)
          WHILE
              FIND ?DUP
              IF ( it's a word)
                   1+ STATE @ 0= OR
                   IF   EXECUTE
                   ELSE COMPILE,
                   THEN
              ELSE ( it's a number)
                   COUNT NUMBER? ?ERR
                   LIT,  ( This is the only real difference )
              THEN
              DEPTH 0< ABORT" MF: Compiler stack underflow"
          REPEAT
          DROP ;

\ vector the two different interpretors
: FORTH-REPL        ['] <INTERP>   'IV ! ; IMMEDIATE
: MACHFORTH-REPL    ['] <MFINTERP> 'IV ! ; IMMEDIATE

\ These words set the search order and
\ make sure the correct interpret loop is active.
: HOST
      ONLY FORTH DEFINITIONS
      POSTPONE FORTH-REPL  ;   \ 'IV  is interpeter vector variable

: COMPILER
      ONLY FORTH ALSO XASSEMBLER
      POSTPONE FORTH-REPL
      ALSO MFORTH DEFINITIONS ;

: TARGET
      ONLY XASSEMBLER ALSO MFORTH
      POSTPONE MACHFORTH-REPL
      ALSO TARGETS DEFINITIONS ;

\ _______________________________________________
\ SWAP BYTE optimizer
: ?SWPB,  ( n -- n)
         LOOKBACK 0984 =   \ look back for "SRL R4,8"
         IF -2 TALLOT      \ remove SRL
         ELSE  TOS SWPB,   \ we need SWPB
         THEN
;

\ _______________________________________________
COMPILER
\ Rename HOST FORTH version of colon/semi-colon.
\ This let's us create Assembler macros as Forth words
\ and later to define target compiler colon & semi-colon.
: ;H    POSTPONE ;  ;  IMMEDIATE

\ *We must override REPL selection so Forth macros work correctly
: H:   POSTPONE FORTH-REPL  :  ;H

\ tail call optimizing semi-colon
H: -; ( --  )
    LOOKBACK   ( addr )   \ get entry address of sub-routine
    2 CELLS +  ( addr' )  \ move past the sub-routine ENTRY instructions
    -04 TALLOT            \ erase BL @addr
    ( addr')  @@ B,       \ compile a branch to the NEW sub-routine
;H

\ Here we steal INTERPRETED Words from Forth so the Mforth COMPILER vocabulary
\ has them also, like comments etc.
\ When we invoke TARGET we are cut-off from Forth VOCABULARY.
H: \    1 PARSE 2DROP ; IMMEDIATE
H: (    POSTPONE (  ;H  IMMEDIATE  ( borrowed from Forth )
H: .(   POSTPONE .(     ;H IMMEDIATE
H: CR   CR    ;H
H: COMPILER   COMPILER  ;H
H: HOST       HOST      ;H
H: TARGET     TARGET    ;H
H: [HC]       HOST   ;H  IMMEDIATE
H: [TC]       TARGET ;H  IMMEDIATE
H: [CC]       COMPILER ;H IMMEDIATE
H: >R         >R ;H
H: R>         R> ;H
H: CR         CR ;H
H: HEX        HEX ;H
H: DECIMAL    DECIMAL ;H
H: SWAP       SWAP ;H
H: THERE      THERE ;H
H: INCLUDE    INCLUDE ;H
H: WORDS      WORDS  ;H
H: ELAPSE     ELAPSE ;H  \ make available in MFORTH vocabulary.
H: .S         .S    ;H
H: CLS        PAGE  ;H   \ don't conflict with compiler PAGE

\ COMPILER  COLON is the just the Host forth's colon
H: ;     POSTPONE ;  ;H  IMMEDIATE
H: :     :  ;H

\ Cross-compiler variables and constants
HOST HEX
VARIABLE LORG     2000 LORG !   \ LORG is TI-99 load address

       2000 CONSTANT CDATA  \ CODE compiles to this buffer
CDATA CELL+ CONSTANT 'BOOT  \ holds program boot address

\ compute diff. between actual load-address and image buffer
: OFFSET   ( -- n)  LORG @ CDATA -  ;
: REL>TARG  ( relocated -- target)  OFFSET - ;

\ MACHFORTH data field "getter"
\ returns data address of a MachForth data words above
\   >>> MUST BE PUT HERE. IT USES FORTH'S @ OPERATOR <<<
: T'   ( <name> -- addr) ' >BODY @ REL>TARG ;

\ run the program at target memory
\ **** MUST USE MACHINE CODE. Xassembler compiles to target mem! ***
CODE (RUN)  ( addr -- ) 0454 , C136 ,  NEXT,  ENDCODE \  *TOS B,

COMPILER
: RUN   ( addr --)
       DUP 3000 2004 WITHIN ABORT" Can't RUN. ORG must be >2000"
       (RUN)  DROP ;

\ cross-compiler directives
: NEW.
   1000  2000  0 VFILL     \ erase VDP RAM 8K block
   CDATA 2000 FF FILL      \ fill 8K program space with FFFF
   CDATA  ORG              \ program begins after the intial branch & address
   DEAD @@ B,              \ Compile 1ST instruction. branch to bad address
  ['] TARGETS >BODY OFF    \ erase words in TARGETS wordlist
   DROPS OFF   #OPTS OFF
   #DUPS  OFF
;

: ORIGIN. ( addr ) DUP 2000 U< ABORT" ORG < HEX 2000"  LORG ! ;

: EVEN.   TDP @ ALIGNED TDP ! ;

\ target image fetch and store take relocated addresses and convert them
: T!      ( n relocated -- ) REL>TARG ! ;
: T@      ( relocated -- n)  REL>TARG @ ;

\ _____________________________________________________________
\  *** NEW compiler controls for CROSS-COMPILER ONLY ***
\                   >>understand this<<
\ These directives are used inside a colon definition to disable
\ compiling actions of LIT, for CONTSTANT CREATE ADDR VARIABLE
\ This allows us to use the address of the data structure rather than compiling
\ with LIT,

: [     FORTH-REPL     XSTATE OFF ; IMMEDIATE
: ]     MACHFORTH-REPL XSTATE ON ;
\ _____________________________________________________________
\ data structure creation
COMPILER
\ Label creator returns relocated TARGET address when executed
H: L:  CREATE   THERE REL>TARG ,
       DOES>  @  ;H

H: EQU   ( n -- <NAME>) CREATE  ,  DOES> @ ; \ just give the compiler the value

H: CONSTANT ( n -- n)  \ CONSTANT compiles code to put no. in TOS
      CREATE   ,       \ remember n
      DOES> ( pfa )
           @  LIT, ;H  \ compile n as a literal no.

H: ADDRESS ( n -- n)   \ Special kind of constant goes into AR
      CREATE   ,
      DOES> ( pfa ) @ AR SWAP LI,  ;H

\ *IDEA*  make a TAG variable with coded values for data types.
H: CREATE ( -- addr)
        CREATE THERE ,     \ remember the target address
        DOES> @  REL>TARG  LIT,   ;H   \ pushes address onto stack

\ mforth data structure words
H: VARIABLE  ( -- addr)
             CREATE
             0000 T, ;H

\ compile text into the TARGET program image. Use THERE
: S, ( c-addr u -- ) THERE OVER 1+ TALLOT PLACE  EVEN. ;
: S"  ( -- addr len)  [CHAR] " PARSE ;

\ ______________________________________________________________
\ colon definitions
COMPILER
\ Machine Forth colon/semi-colon (creates nestable sub-routines)
: M:
\ compile time action
          CREATE  !CSP
           THERE ,      \ remember the relocated address
           R11 RPUSH,   \ compile "enter sub-routine" code
           ]            \ turn on "cross-compiler"
 \ Runtime action: (when we invoke this word)
         DOES> @  REL>TARG ( addr) @@ BL, ; \ compile BL to address

: ;M      R11 RPOP,  RT,    \ compile exit sub-routine code
          [                 \ turn off cross compiler
;

\ ______________________________________________________________
\ Forth virtual machine setup directives
: WORKSPACE ( addr --) LWPI, ;       \ Forth workspace
: DSTACK    ( addr --) SP SWAP LI, ; \ data stack
: RSTACK    ( addr --) RP SWAP LI, ; \ return stack

: PROG: ( <label> -- taddr)
  CREATE !CSP
     THERE REL>TARG DUP ,  \ record program entry in this word and...
     'BOOT !               \ store relocated address in program header
     #DUPS OFF
      ]                    \ Turn on cross-compiler
  DOES> @
;

: REPORT
    DECIMAL
    CR ." Program Size  :" THERE CDATA - .
    CR ." Optimizations :" #OPTS ?
;

: END.
        [                  \ turn CROSS-compiler off
        TDP @ 3FFF > ABORT" Prog > 8K"
        ?CSP
        REPORT
;

\ _________________________________________________
HOST CR .( Machine Forth Structured branching and looping )

COMPILER
\ compute signed offset & compile into the 2nd byte of any 9900 JUMP instruction
: RESOLVE ( addrofjmp byte --)  2- 2/ SWAP 1+ C! ;
: <BACK   ( addr addr' -- ) TUCK -  RESOLVE ;

: -IF    ( -- $$)   THERE 0 JNC, ;
: IF     ( -- $$)   THERE 0 JNE, ;
: NC.IF  ( -- $$)   THERE 0 JOC, ;  \ GOTO then if Carry=True
: THEN   ( addr --) THERE OVER - RESOLVE ;
: ELSE   ( -- $$ )  THERE 0 JMP,  SWAP THEN ;

: BEGIN    THERE ;  IMMEDIATE
: WHILE    -IF SWAP ;
: -WHILE   IF SWAP ;
: UNTIL   ( addr --) THERE  0 JEQ, <BACK ;
: -UNTIL  ( addr --) THERE  0 JNE, <BACK ;
: AGAIN   ( addr --) THERE  0 JMP, <BACK ;
: REPEAT  ( addr -- ) AGAIN THEN ;

: OV.UNTIL  ( addr --) THERE  0 JNO, <BACK  ; \ Used by DO/LOOP
: NC.UNTIL  ( addr --) THERE  0 JOC, <BACK ; \ jump back until FALSE

\ ______________________________________________________________
HOST CR .( Forth Intrinics)
\ These inline code generators are in the actual compiler
COMPILER
HEX
\  Moore's Machine Forth + a few extras
: DROP  ( n -- )  DROP, ;
: DUP             SMARTDUP, ;

: OPT-OFF   ['] DUP,     IS SMARTDUP, ;
: OPT-ON    ['] OPT-DUP, IS SMARTDUP, ;

: #     ( n -- ) SMARTDUP,  TOS SWAP LI, ;
: #@    ( addr -- n)   SMARTDUP, ( addr) @@ TOS MOV, ;
: @     ( TOSaddr -- n) *TOS TOS MOV, ;
\ : [@]   ( ndx addr)     (TOS) TOS MOV, ;

\ added byte operations: BFox
: #C@   ( addr -- c)   DUP  @@ TOS MOVB,  TOS 8 SRL, ;
: C@    ( TOSaddr -- c) *TOS TOS MOVB,  TOS 8 SRL, ;

: (!)   ( n variable -- ) TOS SWAP  @@ MOV, ; \  n DUP addr !
: #!    ( n variable -- ) (!)  DROP ; \ 6 bytes
: !     ( n TOSaddr --)  *SP+ *TOS MOV, DROP ;

: (C!)  ( c addr --) TOS SWPB,  TOS SWAP @@ MOVB, ; \ c DUP addr  C!
: #C!   ( c addr --) (C!)  DROP ;
: C!    ( c addr --) 1 (SP) *TOS MOVB,  SP INCT,  DROP ;

[CC] .( .)
: 2*    ( n -- n ) TOS TOS ADD, ;
: 2/    ( n -- n)  TOS 1 SRA, ;
: INVERT ( n -- )  TOS INV, ;  ( ANS Forth name )
: AND  ( n mask -- n) *SP INV, *SP+ TOS SZC, ; \ and stack values
: #AND  ( n n -- n ) TOS SWAP ANDI, ;  \ and TOS with literal number
: XOR   ( n n -- n)  *SP+ TOS XOR, ;   \ (option 1)
: +     ( n n -- n)  *SP+ TOS ADD, ;   \ (option 1) add on stack
: #+    ( n n -- )    TOS SWAP AI, DROP ;  \ (option 2) TOS + literal number

\ Naming convention for A register has been changed so it
\ uses the features of the TMS9900 CPU. It's dumb not to.

\ These Forth conventions are kept: @ means fetch and ! means store.
\ '*' suffix indicates the source register (A I or R) are indirect
\ memory access.
\ The A register can also be post-incremented after fetching natively
\ We have added indexed addressing as well with (A)@

\ @-A Dpush(T) A=A-cell T=[A]
\ !-A A=A-cell [A]=T Dpop(T)

: A@    ( -- n)  SMARTDUP,   AR  TOS MOV, ;
: A@+   ( -- n)  SMARTDUP,   AR  TOS MOV, AR INC, ;
: *A@   ( -- n)  SMARTDUP,  *AR  TOS MOV, ;  \ Dpush(T) T=*A
: *A@+  ( -- n)  SMARTDUP,  *AR+ TOS MOV, ;  \ Dpush(T) T=*A  A=A+cell
: (A)@  ( u --)  SMARTDUP,  (AR) TOS MOV, ;  \ Dpush(T) T=u@(A)

: #A!   ( addr --)  AR SWAP LI, ; \ load A with literal number BF addition
: A!    ( addr -- ) TOS  AR  MOV, DROP ;  \ A!   A=T  Dpop(T)
: *A!   ( n {addr}) TOS *AR  MOV, DROP ;  \ !A  [A]=T Dpop(T)
: *A!+  ( n {addr}) TOS *AR+ MOV, DROP ;  \ !A+ [A]=T A=A+cell Dpop(T)
: (A)!  ( n --)     TOS  SWAP (AR) MOV, DROP ;

\ More optimal 9900 instructions for A register BFox
: A+!   ( n -- )  TOS AR ADD,  DROP ;
: A1+!  ( -- )    AR INC, ;
: A2+!  ( -- )    AR INCT, ;
: A1-!  ( -- )    AR DEC, ;
: A2-!  ( -- )    AR DECT, ;

\ added byte operations. BFox
: *AC@   ( -- 0c00) SMARTDUP,  *AR  TOS MOVB, TOS 8 SRL, ;
: *AC@+  ( -- 0c00) SMARTDUP,  *AR+ TOS MOVB, TOS 8 SRL, ;
: *AC!   ( 0c00 --)  1 (TOS) *AR MOVB,  DROP ;
: *AC!+  ( 0c00 --)  1 (TOS) *AR+ MOVB, DROP ;

\ TOS to A TRANSFER instructions
\ TOS incrementing  to fixed address
: *TOS+->*AC!  ( addr -- addr') *TOS+ *AR MOVB,  ; \ byte transfer
: *TOS+->*A!   ( addr -- addr') *TOS+ *AR MOV,  ;  \ cell transfer

\ both incrementing
: *TOS+->*AC!+  ( addr -- addr') *TOS+ *AR+ MOVB,  ; \ byte transfer
: *TOS+->*A!+   ( addr -- addr') *TOS+ *AR+ MOV,  ;  \ cell transfer

\ TOS fixed source to A incrementing
: *TOS->*AC!+  ( addr -- addr') *TOS *AR+ MOVB,  ; \ byte transfer
: *TOS->*A!+   ( addr -- addr') *TOS *AR+ MOV,  ;  \ cell transfer


.( .)
\ return stack operators ........................
\ Names changed to better reflect 9900 Assembler
\ * Indicates indirect addressing mode
\ @ means fetch to TOS register
\ ! means store TOS register to Return stack
: R@    ( -- n )  SMARTDUP, *RP TOS MOV, ;  \ G*Dpush(T) T=[R] C
\ post incrementing
: R@+   ( -- n )  R@  *RP INCT, ;   \ G*  Dpush(T) T=[R] R=R+cell
\ pre decrementing
: -R@   ( -- n )  R@  *RP DECT, ;   \ G*  Dpush(T) R=R-cell T=[R]

: R!   ( n -- )  TOS *RP MOV,  DROP ;   \  *R->T  DROP(T)
\ post incrementing
: R!+  ( n -- )  R!   *RP INCT, ;      \ !R+ [R]=T R=R+cell Dpop(T)
\ pre decrementing
: -R!  ( n -- )  *RP DECT, R!   ;      \ R=R-cell [R]=T Dpop(T)

\ Single instructions on 9900. No brainer optimizing
: RDROP ( -- )    RP INCT, ;
: DUP>R ( n -- n) TOS RPUSH,  ;

: >R    ( n -- )  DUP>R  DROP ;              \ G*  Rpush(R) R=T Dpop(T)
: R>    ( -- n)   SMARTDUP, *RP+ TOS MOV, ;  \ G*  Dpush(T) T=R Rpop(R)

\ For/next loop uses return stack for index. Counts down only.
\ Use A register for other indices.
: I@   ( -- n)  SMARTDUP, I TOS MOV, ;   \ I@ Dpush(T) T=I
: I!   ( n --)  TOS I MOV, DROP ;   \ I=T  Dpop(T)
: I+!  ( n --)  TOS I ADD, DROP ;   \ BFox word
: I1-! ( -- )   I DEC, ;

\ now we can define the FOR NEXT LOOP
: FOR  ( n --)  I RPUSH,   I!  POSTPONE BEGIN ;
: NEXT ( -- )   I1-!  NC.UNTIL  I RPOP, ;

\ __________[ Chuck Moore Machine Forth Ends ]__________

\ /////// ANS/ISO Forth, 9900 Specific operators \\\\\\\\
: OVER  ( n1 n2 -- n1 n2 n1) TOS DPUSH,  2 (SP) TOS MOV, ;
: NIP   ( n1 n2 -- n2)  SP INCT, ;

\ __[ Unique TMS9900 primitives ]__
: 1+   ( n -- n')   TOS INC, ;
: 2+   ( n -- n')   TOS INCT, ;
: 1-   ( n -- n')   TOS DEC, ;
: 2-   ( n -- n')   TOS DECT, ;
: 4*   ( n -- n')   TOS 2 SLA, ;
: 8*   ( n -- n')   TOS 3 SLA, ;

\ TOS to symbolic address store and +!
: ->  ( n <var> -- ) T'   (!)  DROP  ;
: ->+ ( n <var>-- )  T'  TOS SWAP  @@ ADD,  DROP ;

\ mem2mem symbolic store and +!
\ X @ Y !  is 10 instructions, 14 bytes
\ [ X  Y ] '!  is 1 instruction, 6 bytes. WINNER!
: '!    ( addr1 addr2) SWAP @@ ROT @@ MOV, ; \ mem2mem store
: '+!   ( addr1 addr2) SWAP @@ ROT @@ ADD, ; \ mem2mem plus-store

: LSHIFT ( n -- n)  TOS SWAP SLA, ;
: RSHIFT ( n -- n)  TOS SWAP SRL, ;

\ inc/dec variables with direct addressing
: 1+! ( addr -- ) *TOS  INC,  DROP ;
: 2+! ( addr -- ) *TOS INCT,  DROP ;
: 1-! ( addr -- ) *TOS  DEC,  DROP ;
: 2-! ( addr -- ) *TOS DECT,  DROP ;
: +!  ( n addr --) *SP+ *TOS ADD,  DROP ; \ 6 bytes  \ 5 # X +!
: #+! ( n [addr] -- )  TOS SWAP @@ ADD,  DROP ;

: NOP    ( -- )     0 JMP, ;
: ABS    ( n -- n') TOS ABS, ;
: NEGATE ( n --n')  TOS NEG, ;
: OR     ( w w -- w ) *SP+ TOS SOC, ;
: #OR    ( -- )    TOS SWAP ORI, ;

\ 2 and 3 instruction words for ANS/ISO compatibility
: -     ( n n -- n') *SP+ TOS SUB, TOS NEG, ;
: UM*   ( n n -- d)  *SP  TOS MPY, R5  *SP MOV, ;
: *     ( n n -- n)  *SP+ R3 MOV,  TOS R3 MPY, ;
: ALIGNED ( n -- n)   TOS INC,  TOS -2 ANDI, ;
: AND   ( w w -- w ) *SP INV,  *SP+ TOS SZC, ;
: 2@    ( addr -- d) 2 (TOS) DPUSH,   *TOS TOS MOV, ; \ fetch double integer
: EXIT  ( -- )       R11 RPOP,  RT, ;

\ _______________________________________________________________
\ hi-level Forth additions for people less pure than Chuck Moore
: NOT  ( -- )  R1 STST,  R1 2000 ANDI, ;  \ invert EQ flag status
: ON   ( variable --) *TOS SETO, DROP ;
: OFF  ( variable --) *TOS CLR,  DROP ;
: ><   ( n -- )  TOS SWPB, ;

: BOUNDS ( adr len -- adr2 adr1) *SP R1 MOV, TOS *SP ADD, R1 TOS MOV, ;
: SWAP   ( n1 n2 -- n2 n1)      TOS R0 MOV,  *SP  TOS MOV,  R0 *SP MOV, ;

\ CUT n characters from left side of STRING (addr,len)
: /STRING ( addr len n -- addr' len' ) TOS *SP SUB,  TOS 2 (SP) ADD,  DROP ;

\ **NOT NORMAL FORTH**
\ Only the 9900 status register is affected
\ Nothing is put on the data stack
: ?TERMINAL ( -- )  0020 @@ BL,  NOT ; \ TI-99 ROM sub-routine

: COUNT  ( Caddr -- addr len )
        DUP,              \ !!! CANT' USE SMARTDUP, Need to make the copy
       *SP INC,           \ inc. past the count byte
       *TOS TOS MOVB,     \ put C@ inline to save space
        TOS 8 SRL, ;

\ Comparisons
: =      *SP+ TOS  CMP, ;
: 0=     TOS   0   CI, ;
: ==     *SP  TOS  CMP, ;

\ signed comparisons
: >IF   ( n n -- $$)  =  THERE 0 JLT, ; \ goto then low or eq
: <IF   ( n n -- $$)  =  THERE 0 JGT, ;

\ ANS Forth number compilers for the COMPILER wordlist
: ,      T, ;
: C,    TC, ;
: ALLOT  ( n --) TALLOT ;
\ : HERE   SMARTDUP, TOS THERE LI, ;

\ Last definitions make the TARGET compiler.
\ Alias mforth compiler colon/semi-colon words into COMPILER vocabulary
\ so they look like ':' ';' by using Camel Forth's H: and ;H
\ Yes it's confusing. Welcome to Forth cross-compilers.
COMPILER
H: :    M:  ;H
H: ;   ;M   ;H

\ improved utility constants 6 BYTES vs 8 for LIT,
\ H: FALSE   SMARTDUP, TOS CLR, ;H
\ H: TRUE    SMARTDUP, TOS SETO, ;H
\ H: 0       SMARTDUP, TOS CLR, ;H

\ Redefine Camel99 Utility constants as MACHFORTH constants
        0 CONSTANT FALSE
        0 CONSTANT 0
       -1 CONSTANT TRUE
        1 CONSTANT 1
       20 CONSTANT BL

HOST
HEX
 : COLD
        WARM
        E1 7 VWTR
        CR ." Machine Forth Compiler V2.3  BFox"
        INIT-WORDLISTS
        COMPILER
        CR ORDER
        ABORT ;

 LOCK

 INCLUDE DSK1.SAVESYS

 ' COLD SAVESYS DSK2.MACHTEST
