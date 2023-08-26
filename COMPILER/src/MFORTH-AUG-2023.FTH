\ MACHINE FORTH COMPILER     Dec 14, 2020  Brian Fox, Kilworth Ontario
\ This file compiles with Camel99 Forth V2.6x in DSK1. MFORTHASM in DSK2.

\ Feb 2022: DROP/DUP optimizer counts DUPs. No optimizing until DUPS>1
\ 2023  simplified FOR NEXT to use return stack for index
\ *To cross-compile a program
\  With the MACHFORTH ready type: INCLUDE <DSK2.MYPROGRAM>

\ AUG 24 2023 I went for it and now use R11 as the top of Rstack. 

NEEDS FORTH     FROM DSK1.WORDLISTS

ONLY FORTH DEFINITIONS

NEEDS LOAD-FILE FROM DSK1.LOADSAVE
NEEDS .S        FROM DSK1.TOOLS
NEEDS DEFER     FROM DSK1.DEFER
NEEDS ELAPSE    FROM DSK1.ELAPSE
NEEDS U.R       FROM DSK1.UDOTR
NEEDS MARKER    FROM DSK1.MARKER
\ NEEDS VALUE     FROM DSK1.VALUES
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

HEX

XASSEMBLER DEFINITIONS
: LIT,  ( n -- )
    XSTATE @
    IF               \ IF CROSS-compiling, emit machine code
       TOS PUSH,     \ push TOS if we need to.
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
COMPILER
\ Rename HOST FORTH version of colon/semi-colon.
\ This let's us create Assembler macros as Forth words
\ and later to define target compiler colon & semi-colon.
: ;H   POSTPONE ;  ;  IMMEDIATE

: H:   :  ;H

\ tail call optimizing semi-colon
: LOOKBACK ( -- u)  THERE 2- @ ; \ fetch previous instruction code

H: -; ( --  )
    LOOKBACK   ( addr )   \ get entry address of sub-routine
    2 CELLS +  ( addr' )  \ move past the sub-routine ENTRY instructions
   -2 CELLS TALLOT            \ erase BL @addr
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
H: NEEDS      NEEDS   ;H
H: FROM       FROM   ;H
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

\ run the program at target memory
\ **** MUST USE MACHINE CODE. Xassembler compiles to target mem! ***
HEX
CODE (RUN)  ( addr -- ) 0454 , C136 ,   NEXT,  ENDCODE \  *TOS B,

\ save binary program utility
INCLUDE DSK2.SAVEIMG
INCLUDE DSK1.DIR

COMPILER
H: SAVE       SAVE  ;H  \ bring SAVE into COMPILER wordlist too

\ MACHFORTH data field "getter"
\ returns data address of a MachForth data words above
COMPILER
H: T'   ( <name> -- addr)
          [CC] ALSO TARGETS  ' >BODY @  REL>TARG
          PREVIOUS ;H
HEX
: RUN   ( addr --)
       DUP 3000 2004 WITHIN ABORT" Can't RUN. ORG must be >2000"
       (RUN) [ FORTH ]  DROP ;

COMPILER        
\ _____________________________________________________________
\ cross-compiler directives
: (NEW)
   1000  2000  0 VFILL     \ erase VDP RAM 8K block
   CDATA 2000 FF FILL      \ fill 8K program space with FFFF
   CDATA  ORG              \ program begins after the intial branch & address
   DEAD @@ B,              \ Compile 1ST instruction. branch to bad address
  ['] TARGETS >BODY OFF    \ erase words in TARGETS wordlist
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

\ compile text into the TARGET program image. Use THERE
H: S,  ( c-addr u -- ) THERE OVER 1+ TALLOT PLACE  EVEN. ;H
H: S"  ( -- addr len)  [CHAR] " PARSE ;H

\ ______________________________________________________________
\ defines a code word in assembler or machine code

: ?RUN-TARGET    XSTATE @ 0= ABORT" Can't run TARGET word" ;

H: CODE
       CREATE
       ALSO XASSEMBLER
         !CSP
         THERE ,
         R11 RPUSH,      \ automatically add saving R11 on entry
         [ 
       DOES> ?RUN-TARGET
             @ REL>TARG @@ BL, ;H

H: ENDCODE  ( -- )
        R11 RPOP,        \ automatic R11 restore on exit
        RT,
        ?CSP
        PREVIOUS
;H

\ ______________________________________________________________
\ MachForth colon definitions
COMPILER
\ Machine Forth colon/semi-colon (creates nestable sub-routines)
H: M:
\ compile time action
          CREATE  !CSP
           THERE ,      \ remember the relocated address
           R11 RPUSH,   \ compile "enter sub-routine" code
           ]            \ turn on "cross-compiler"
 \ Runtime action: (when we invoke this word)
         DOES> ?RUN-TARGET
              @ XSTATE @ IF REL>TARG ( addr) @@ BL, THEN
;H

H: ;M     R11 RPOP,  RT,    \ compile exit sub-routine code
          POSTPONE [        \ turn off cross compiler
;H IMMEDIATE

\ _____________________________________________________________
\ data structure creation
\ These data structures are XSTATE smart. They either compile CODE
\ or just return an address or a value to the Host Forth stock

COMPILER
\ Label creator returns relocated TARGET address when executed
H: L:  CREATE   THERE REL>TARG ,
       DOES>  @  ;H

H: EQU   ( n -- <NAME>) CREATE  ,  DOES> @ ; \ just give the compiler the value

H: CONSTANT ( n -- n)  \ CONSTANT compiles code to put no. in TOS
      CREATE   ,       \ remember n
      DOES> ( pfa ) @ XSTATE @ IF  LIT, THEN  ;H

\ *****************************************************
\ >> CREATE is OVER-RIDDEN for the CROSS-COMPILER <<
H: CREATE ( -- addr)
      CREATE THERE REL>TARG ,     \ remember the target address
      DOES> ( pfa) @  XSTATE @ IF  LIT, THEN
;H

\ mforth data structure words
H: VARIABLE  ( -- addr)   CREATE     0000 T,
;H
\ ______________________________________________________________
\ Forth virtual machine setup directives
: WORKSPACE ( addr --) LWPI, ;        \ Forth workspace
: DSTACK    ( addr --) SP SWAP LI, ;  \ data stack
: RSTACK    ( addr --) RP SWAP LI, ;  \ return stack

: PROG: ( <label> -- taddr)
  CREATE !CSP
     THERE REL>TARG DUP ,  \ record program entry in this word and...
     'BOOT !               \ store relocated address in program header
      ]                    \ Turn on cross-compiler
  DOES> @
;

: REPORT
    DECIMAL
    CR ." Program Size  :" THERE CDATA - .
;

: END.
        POSTPONE [  \ turn CROSS-compiler off
        TDP @ 3FFF > ABORT" Prog > 8K"
        ?CSP
        REPORT
; IMMEDIATE

\ _________________________________________________
HOST CR .( Machine Forth Structured branching and looping )

COMPILER
\ compute signed offset & compile into the 2nd byte of any 9900 JUMP instruction
: RESOLVE ( addrofjmp byte --)  2- 2/ SWAP 1+ C! ;
: <BACK   ( addr addr' -- ) TUCK -  RESOLVE ;

: -IF    ( -- $$)   THERE 0 JOC, ;
: IF     ( -- $$)   THERE 0 JEQ, ;
: THEN   ( addr --) THERE OVER - RESOLVE ;
: ELSE   ( -- $$ )  THERE 0 JMP,  SWAP THEN ;

: BEGIN    THERE ; 
: WHILE    IF  SWAP ;
: -WHILE   -IF SWAP ;

: UNTIL   ( addr --)  THERE 0 JNE, <BACK ;
: -UNTIL  ( addr --) -IF <BACK ;
: AGAIN   ( addr --) THERE  0 JMP, <BACK ;
: REPEAT  ( addr -- ) AGAIN THEN ;

: OV.UNTIL ( addr --) THERE  0 JNO, <BACK  ; \ Used by DO/LOOP

\ ______________________________________________________________
HOST CR .( Forth Intrinics)
\ These inline code generators are the actual compiler
COMPILER
HEX
\  Moore's Machine Forth + a few extras
: DUP     TOS PUSH, ;
: DROP    TOS POP,  ; 

\ same for return stack. R11 caches the top of Return stack 
: RDUP    R11 RPUSH, ;
: RDROP   R11 RPOP, ; 

: @     ( TOSaddr -- n) *TOS TOS MOV, ;

\ added byte operations: BFox
: C@    ( TOSaddr -- c) *TOS TOS MOVB,  TOS 8 SRL, ;

: !     ( n TOSaddr --)  *SP+ *TOS MOV, DROP ;
: C!    ( c addr --) 1 (SP) *TOS MOVB,  SP INCT,  DROP ;

[CC] .( .)
: 2*    ( n -- n ) TOS TOS ADD, ;
: 2/    ( n -- n)  TOS 1 SRA, ;
: INVERT ( n -- )  TOS INV, ;  ( ANS Forth name )
: AND  ( n mask -- n) *SP INV, *SP+ TOS SZC, ; \ and stack values
: XOR   ( n n -- n)  *SP+ TOS XOR, ;   \ (option 1)
: +     ( n n -- n)  *SP+ TOS ADD, ;   \ (option 1) add on stack

\ A register per F21 instruction set
R8 CONSTANT AR 
: A       TOS PUSH,    AR    TOS MOV, ;
: @A+     TOS PUSH,    AR *+ TOS MOV, ;
: @A      TOS PUSH,    AR ** TOS MOV, ;
: !A+     TOS  AR *+ MOV,      DROP ;
: A!      TOS  AR    MOV,      DROP ;
: !A      TOS  AR ** MOV,      DROP ;
: C!A     TOS SWPB,  TOS  AR ** MOVB,  DROP ;

\ useful addition
: A+!     TOS AR ADD,   DROP ;

.( .)
\ return stack operators ........................
\ *simplified* If you want more use Assembler 
: DUP>R   RDUP  TOS R11 MOV, ;        \ BFOX addition 
: >R      DUP>R DROP ;                \ push TOS onto Rstack ie: >R ;
: R>      DUP   R11 TOS MOV,  RDROP ; \ pop rstack into TOS  ie: R> ;

: @R+     DUP   *R11+ TOS MOV, ;
: !R+     RDUP  TOS *R11+ MOV, ;

\ For/next loop uses R8 for index. Counts down only.
\ Use A register or TOS for upcounting

: I@   ( -- n)  DUP  R11 TOS MOV, ;   \  push(T) T=I


\ *change* Uses R11 as loop index 
: FOR  ( n --) >R   BEGIN ;
: NEXT ( -- )  R11 DEC,   -UNTIL  RDROP ;
: NEXT2 ( -- ) R11 DECT,  -UNTIL  RDROP ;

\ __________[ Chuck Moore Machine Forth Ends ]__________

\ /////// ANS/ISO Forth, 9900 Specific operators \\\\\\\\
: OVER  ( n1 n2 -- n1 n2 n1) TOS PUSH,  2 (SP) TOS MOV, ;
: NIP   ( n1 n2 -- n2)  SP INCT, ;

\ __[ Unique TMS9900 primitives ]__
: 1+   ( n -- n')   TOS INC, ;
: 2+   ( n -- n')   TOS INCT, ;
: 1-   ( n -- n')   TOS DEC, ;
: 2-   ( n -- n')   TOS DECT, ;
: 4*   ( n -- n')   TOS 2 SLA, ;
: 8*   ( n -- n')   TOS 3 SLA, ;

: LSHIFT ( n -- n)  TOS SWAP SLA, ;
: RSHIFT ( n -- n)  TOS SWAP SRL, ;

\ inc/dec variables with direct addressing
: 1+! ( addr -- ) *TOS  INC,  DROP ;
: 2+! ( addr -- ) *TOS INCT,  DROP ;
: 1-! ( addr -- ) *TOS  DEC,  DROP ;
: 2-! ( addr -- ) *TOS DECT,  DROP ;
: +!  ( n addr --) *SP+ *TOS ADD,  DROP ; \ 6 bytes  \ 5 # X +!

: NOP    ( -- )     0 JMP, ;
: ABS    ( n -- n') TOS ABS, ;
: NEGATE ( n --n')  TOS NEG, ;
: OR     ( w w -- w ) *SP+ TOS SOC, ;

\ Special instructions:
\ Immediate instructions and SYMBOLIC addressing need a literal number argument.
\ The compiler will try to emit code to put a literal into number into R4.
\ So we use the interpreter [ to give the number to the compiler.
\ These instructions end with ] to remind us of to preface them with [
\ Example:   [ 00F0 OR]  ( compiles  TOS 00F0 ORI, )

\ immediate mode instructions
: OR]   ( n [n] --n) ]  TOS SWAP ORI, ;
: +]    ( n [n] --)  ]  TOS SWAP AI,  ; \ (option 2) TOS + literal number
: AND]  ( n [n] --n) ]  TOS SWAP ANDI, ;    \ and TOS with literal number

\ Symbolic addressing operators
: @]    ( addr -- n)  ]  DUP ( addr) @@ TOS MOV,  ;
: !]    ( n [var] --) ]  TOS SWAP @@ MOV,  DROP  ;
: +!]   ( n [var] --) ]  TOS SWAP @@ ADD,  DROP  ;
: C!]   ( c [var] --) ]  TOS SWPB,  TOS SWAP @@ MOVB, DROP ;
: C@]   ( [var] -- c) ]  DUP  @@ TOS MOVB,  TOS 8 SRL, ;
: 1+!]  ( [var] --)   ]  @@ INC, ;
: 1-!]  ( [var] --)   ]  @@ DEC, ;

\ mem2mem symbolic store and +!

\ ** DO NOT CONFUSE WITH !]  and  +!]  ***

\  X @ Y !  is 10 instructions, 14 bytes
\ [ X  Y ]! is 1 instruction, 6 bytes
: ]!    ( addr1 addr2) SWAP @@ ROT @@ ] MOV, ; \ mem2mem store
: ]+!   ( addr1 addr2) SWAP @@ ROT @@ ] ADD, ; \ mem2mem plus-store

\ Alternative TOS to symbolic address store and +!
: ->  ( n <var> -- ) T'  TOS SWAP @@ MOV,  DROP ;
: ->+ ( n <var>-- )  T'  TOS SWAP @@ ADD,  DROP ;

\ indexed addressing uses TOS (ie: R4) as the index register

\  12 [ Q +]@
: +]@  ( i addr -- n )  (TOS) TOS  MOV, ;

\ BEEF  13 [ Q +]!
: +]!   ( n i addr -- )  *SP+ SWAP (TOS) MOV, DROP ;

\ _______________________________________________________________
\ 2 and 3 instruction words for ANS/ISO compatibility
: -     ( n n -- n') *SP+ TOS SUB, TOS NEG, ;
: UM*   ( n n -- d)  *SP  TOS MPY, R5  *SP MOV, ;
: *     ( n n -- n)  *SP+ R3 MOV,  TOS R3 MPY, ;
: ALIGNED ( n -- n)   TOS INC,  TOS -2 ANDI, ;
: AND   ( w w -- w ) *SP INV,  *SP+ TOS SZC, ;
: 2@    ( addr -- d) 2 (TOS) PUSH,   *TOS TOS MOV, ; \ fetch double integer
: EXIT  ( -- )       R11 RPOP,  RT, ;

\ _______________________________________________________________
\ hi-level Forth additions for people less pure than Chuck Moore
: NOT  ( -- )  R1 STST,  R1 2000 ANDI, ;  \ invert EQ flag status
: ON   ( variable --) *TOS SETO, DROP ;
: OFF  ( variable --) *TOS CLR,  DROP ;
: ><   ( n -- )  TOS SWPB, ;
: R@   ( -- n)  DUP   R11 TOS MOV, ;

\ CUT n characters from left side of STRING (addr,len)
: /STRING ( addr len n -- addr' len' ) TOS *SP SUB,  TOS 2 (SP) ADD,  DROP ;

\ **NOT NORMAL FORTH**
\ Only the 9900 status register is affected
\ Nothing is put on the data stack
: ?TERMINAL ( -- )  0020 @@ BL,  NOT ; \ TI-99 ROM sub-routine

: COUNT  ( Caddr -- addr len )
        TOS PUSH,        \ !!! CANT' USE DUP Need to make the copy
       *SP INC,           \ inc. past the count byte
       *TOS TOS MOVB,     \ put C@ inline to save space
        TOS 8 SRL, ;

\ Comparisons only change the carry flag
: OVER=  ( n n -- ?)  *SP+ TOS CMP, ;

: =?     ( n --n)  R5 CLR,  NE  IF,  R5 DEC, ENDIF, ;
: >?     ( n --n)  R5 CLR,  LTE IF,  R5 DEC, ENDIF, ;
: <?     ( n --n)  R5 CLR,  GTE IF,  R5 DEC, ENDIF, ;

: 0=     ( n -- n) TOS R5 MOV, R5 DEC, ;
: =      ( n1 n2 -- ?)  OVER= =? ;
\ signed comparisons
: >   ( n n2 -- n)  OVER=  >? ;  \ goto then low or eq
: <   ( n n2 -- n)  OVER=  <? ;

: OVER=] ( n lit -- n)  TOS  SWAP CI, =? ;

\ ANS Forth number compilers for the COMPILER wordlist

\ 'DP holds the address of the VARIABLE DP which is defined
\ 0 VALUE 'DP \ pointer to Machine Forth memory pointer
\ : HERE   'DP @ @ LIT, ;   \ double fetch gets variable then value
: ,     ( n --) T, ;
: C,    ( c --) TC, ;
: ALLOT ( n --) TALLOT ;

: BOUNDS ( adr len -- adr2 adr1) *SP R1 MOV,  TOS *SP ADD,  R1 TOS MOV, ;
: SWAP   ( n1 n2 -- n2 n1)       TOS R0 MOV,  *SP  TOS MOV, R0 *SP MOV, ;

\ Alias mforth compiler colon/semi-colon words into COMPILER vocabulary
\ so they look like ':' ';' by using Camel Forth's H: and ;H
\ Yes it's confusing. Welcome to Forth cross-compilers.
COMPILER
H: :   TARGET M:  ;H
H: ;   POSTPONE ;M   ;H IMMEDIATE

\ Redefine Camel99 Utility constants as MACHFORTH constants
HEX
      0 CONSTANT FALSE
     -1 CONSTANT TRUE
     20 CONSTANT BL
   8300 CONSTANT WKSP0  \ default workspace for programs

ALSO FORTH DEFINITIONS
: NEW.  (NEW)
        ['] WKSP0 CFA>NFA ['] MFORTH >BODY ! ;

HOST
HEX
 : MACHFORTH
        WARM
        INIT-WORDLISTS
        E4 7 VWTR
        PAGE ." MachForth Compiler V0.EXP 24AUG23"
        CR ."  RStack cached in R11"
        COMPILER
        NEW.
        ABORT ;

 LOCK

 INCLUDE DSK1.SAVESYS

 ' MACHFORTH SAVESYS DSK2.MACHFORTH
