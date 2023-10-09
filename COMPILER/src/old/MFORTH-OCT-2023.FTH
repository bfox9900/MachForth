\ MACHINE FORTH COMPILER     Dec 14, 2020  Brian Fox, Kilworth Ontario
\ This file compiles with Camel99 Forth V2.6x in DSK1. MFORTHASM in DSK2.

\ Feb 2022: DROP/DUP optimizer counts DUPs. No optimizing until DUPS>1
\ 2023  simplified FOR NEXT to use return stack for index
\ *To cross-compile a program
\  With the MACHFORTH ready type: INCLUDE <DSK2.MYPROGRAM>

\ AUG 24 2023 I went for it and now use R11 as the top of Rstack cache
\ Oct 1 2023  R8 is now the for next loop counter register "i"
\             CMP word compares two values on the data stack 

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
\ VARIABLE XSTATE  \ CROSS-COMPILER state variable

HEX
XASSEMBLER DEFINITIONS

: LIT,  ( n -- )  \ If interpreting just put n on Forth stack.
    STATE @         
    IF               \ IF CROSS-compiling, emit machine code
      TOS PUSH,  
      TOS SWAP LI,   \ compile n as a literal number into R4.
    THEN  ;         

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
   -2 CELLS TALLOT        \ erase BL @addr
    ( addr')  @@ B,       \ compile a branch to the NEW sub-routine
;H IMMEDIATE 

\ Here we steal INTERPRETED Words from Forth so the Mforth COMPILER vocabulary
\ has them also, like comments etc.
\ When we invoke TARGET we are cut-off from Forth VOCABULARY.
H: \    1 PARSE 2DROP ;H IMMEDIATE
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
H: COLD       COLD  ;H


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

HEX 
: >HOST   045A T, ;  IMMEDIATE 


\ _____________________________________________________________
\  *** NEW compiler controls for CROSS-COMPILER ONLY ***
\                   >>understand this<<
\ These directives are used inside a colon definition to disable
\ compiling actions of LIT, for CONTSTANT CREATE ADDR VARIABLE
\ This allows us to use the address of the data structure rather than compiling
\ with LIT,

: [     FORTH-REPL     STATE OFF ; IMMEDIATE
: ]     MACHFORTH-REPL STATE ON ;

\ compile text into the TARGET program image. Use THERE
H: S,  ( c-addr u -- ) THERE OVER 1+ TALLOT PLACE  EVEN. ;H

H: S"  ( -- addr len)  [CHAR] " PARSE  S, ;H  IMMEDIATE 

\ ______________________________________________________________
\ defines a code word in assembler or machine code

: ?RUN-TARGET    STATE @ 0= ABORT" Can't run TARGET word" ;

H: CODE
TARGET CREATE            \ word goes into TARGETS wordlist  
         !CSP
         THERE ,
         R11 RPUSH,      \ automatically add saving R11 on entry
         POSTPONE [ 
       DOES> ?RUN-TARGET
             @ REL>TARG @@ BL, ;H

H: ENDCODE  ( -- )
        R11 RPOP,        \ automatic R11 restore on exit
        RT,
        ?CSP
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
              @ STATE @ IF REL>TARG ( addr) @@ BL, THEN
;H

H: ;M     R11 RPOP,  RT,    \ compile exit sub-routine code
          POSTPONE [        \ turn off cross compiler
;H IMMEDIATE

\ _____________________________________________________________
\ data structure creation
\ These data structures are STATE smart. They either compile CODE
\ or just return an address or a value to the Host Forth stock

COMPILER
H: EQU   ( n -- <NAME>) CREATE  COMPILER ,  DOES> @ ; \ just give the compiler the value

H: CONSTANT ( n -- n)  \ CONSTANT compiles code to put no. in TOS
   CREATE   ,       \ remember n
   DOES> ( pfa ) @  LIT,  ;H

\ LABEL CREATE and VARIABLE put their names in the TARGETS wordlist 

\ Label creator returns relocated TARGET address when executed
H: L:   CREATE    THERE REL>TARG ,    DOES>  @  ;H

H: CREATE ( -- addr) 
      CREATE  
       THERE REL>TARG ,  
      DOES> @  LIT, ;H

\ mforth data structure words
H: VARIABLE  ( -- addr) CREATE     0000 T,   ;H


\ ______________________________________________________________
\ Forth virtual machine setup directives
: WORKSPACE ( addr --) LWPI, ;        \ Forth workspace
: DSTACK    ( addr --) SP SWAP LI, ;  \ data stack
: RSTACK    ( addr --) RP SWAP LI, ;  \ return stack

: PROG: ( <label> -- taddr)
  TARGET 
  CREATE !CSP
     THERE REL>TARG DUP ,  \ record program entry in this word and...
     'BOOT !               \ store relocated address in program header
      ]                    \ Turn on cross-compiler
  DOES> @
;

: REPORT
    DECIMAL
    CR ." Program Size  :" THERE CDATA - .
    THERE 3FFE > ABORT" Prog > 8K"
;

: END.
      POSTPONE [  \ turn CROSS-compiler off
      ?CSP
      REPORT
; IMMEDIATE

\ _________________________________________________
HOST CR .( Machine Forth Structured branching and looping )

COMPILER
\ compute signed offset & compile into the 2nd byte of a 9900 JUMP instruction
: RESOLVE ( addrofjmp byte --)  2- 2/ SWAP 1+ C! ;
: <BACK   ( addr addr' -- ) TUCK -  RESOLVE ;
\ synonyms from Assembler 
: IF     IF, ;  IMMEDIATE 
: THEN   ENDIF, ; IMMEDIATE
: ELSE   ELSE, ; IMMEDIATE
: BEGIN  BEGIN, ; IMMEDIATE
: WHILE  WHILE, ; IMMEDIATE
: AGAIN  AGAIN, ; IMMEDIATE
: UNTIL  UNTIL, ; IMMEDIATE
: REPEAT REPEAT, ; IMMEDIATE

\ aliases for Assembler jump tokens 
\ This is NOT conventional Forth. 
\ These work just like the TI-fORTH Assembler but with different names 
: =      EQ ; IMMEDIATE
: <>     NE ; IMMEDIATE
: <      LTE ; IMMEDIATE
: >      GTE ; IMMEDIATE
: U>     LO ; IMMEDIATE
: U<     HI ; IMMEDIATE
: U>=    HE ; IMMEDIATE
: U<=    LE ; IMMEDIATE

\ hard comparison of TOS to zero 
: 0=     TOS 0 CI,  = ; IMMEDIATE 

\           *NOT standard MACHINE Forth*
\ TMS9900 CMP instruction for 2 items on data stack seems the best
\ way to handle this on the 9900. 2nd item is popped. TOS remains.
: CMP ( n1 n2 -- n2) *SP+ TOS CMP, ;

\ From original Machine Forth 
: -IF    ( -- $$)   THERE 0 JOC, ; IMMEDIATE
: -WHILE  POSTPONE -IF SWAP ; IMMEDIATE 
: -UNTIL  ( addr --) POSTPONE -IF <BACK ;  IMMEDIATE \ used in FOR/NEXT 

\ ______________________________________________________________
HOST CR .( Forth Intrinics)

\ I: creates words that are IMMEDIATE by default.
\ ThiS causes these code macros to run even in COMPILE mode. 
\ 
: I:  : IMMEDIATE ;


\ These inline code generators are the actual compiler
COMPILER
HEX
\  Moore's Machine Forth + a few extras
I: DUP     TOS PUSH, ;
I: DROP    TOS POP,  ; 

I: @     ( TOSaddr -- n) *TOS TOS MOV, ;

\ added byte operations: BFox
I: C@    ( TOSaddr -- c) *TOS TOS MOVB,  TOS 8 SRL, ;

I: !     ( n TOSaddr --)  *SP+ *TOS MOV, DROP ;

I: C!    ( c addr --) 
    1 (SP) *TOS MOVB,    \  26
             SP INCT,    \  10   inc. stack pointer by 2
             TOS POP,    \  22
;

[CC] .( .)
I: 2*    ( n -- n ) TOS TOS ADD, ;
I: 2/    ( n -- n)  TOS 1 SRA, ;
I: INVERT ( n -- )  TOS INV, ;  ( ANS Forth name )
I: AND  ( n mask -- n) *SP INV, *SP+ TOS SZC, ; \ and stack values
I: XOR   ( n n -- n)  *SP+ TOS XOR, ;   \ (option 1)
I: +     ( n n -- n)  *SP+ TOS ADD, ;   \ (option 1) add on stack

\ ============================================================
\ A register per F21 instruction set will use the W register

\ add alias for W register in the Assembler wordlist
ALSO XASSEMBLER DEFINITIONS
I:  A     W  ;
I: *A    *W  ;   
I: *A+   *W+ ;

PREVIOUS DEFINITIONS 
I: A       DUP    W    TOS MOV, ;
I: A!      TOS  W  MOV,  DROP ;

I: @A      DUP    W ** TOS MOV, ;
I: @A+     DUP    W *+ TOS MOV, ;

I: !A+     TOS *W+ MOV,  DROP ;
I: !A      TOS  *W MOV,  DROP ;

\ optimizers for repeated writing to and address
I: DUPC!A   ( 0c00 -- 0c00 ) TOS *W  MOVB,  ;
I: DUPC!A+  ( 0c00 -- 0c00 ) TOS *W+ MOVB, ;

I: C!A       TOS SWPB,  DUPC!A  DROP ;
I: C!A+      TOS SWPB,  DUPC!A+  DROP ;
\ useful addition
I: A+!       TOS W ADD,   DROP ;

.( .)
\ return stack operators ........................
\ same for return stack. R11 caches the top of Return stack 
I: RDUP    R11 RPUSH, ;
I: RDROP   R11 RPOP, ; 

I: DUP>R ( n -- n) RDUP  TOS R11 MOV, ; \ BFOX addition 
I: >R    ( n --)   DUP>R DROP ;         \ push TOS onto Rstack ;
I: R@    ( -- n)   DUP  R11 TOS MOV, ;  \ push(T) T=I
I: R>    ( -- n)   R@  RDROP ;          \ pop Rstack onto TOS  ;

I: @R+   ( -- n)   DUP   *R11+ TOS MOV, ;
I: !R+   ( n --)  RDUP  TOS *R11+ MOV, ;

\ get top of Rstack onto TOS non-destructive


\ *change* Uses R9 as loop index 
I: FOR  ( n --) R9 RPUSH, TOS R9 MOV, TOS POP,  BEGIN, ;
I: NEXT ( -- )  R9 DEC,   NC UNTIL,  R9 RPOP, ;
I: NEXT2 ( -- ) R9 DECT,  NC UNTIL,  R9 RPOP, ;
I: i     TOS PUSH,  R9 TOS MOV, ;

\ __________[ Chuck Moore Machine Forth Ends ]__________

\ /////// ANS/ISO Forth, 9900 Specific operators \\\\\\\\
I: OVER  ( n1 n2 -- n1 n2 n1) DUP   2 (SP) TOS MOV, ;
I: NIP   ( n1 n2 -- n2)  SP INCT, ;

\ __[ Unique TMS9900 primitives ]__
I: 1+   ( n -- n')   TOS INC, ;
I: 2+   ( n -- n')   TOS INCT, ;
I: 1-   ( n -- n')   TOS DEC, ;
I: 2-   ( n -- n')   TOS DECT, ;
I: 4*   ( n -- n')   TOS 2 SLA, ;
I: 8*   ( n -- n')   TOS 3 SLA, ;


\ inc/dec variables with direct addressing
I: 1+! ( addr -- ) *TOS  INC,  DROP ;
I: 2+! ( addr -- ) *TOS INCT,  DROP ;
I: 1-! ( addr -- ) *TOS  DEC,  DROP ;
I: 2-! ( addr -- ) *TOS DECT,  DROP ;
I: +!  ( n addr --) *SP+ *TOS ADD,  DROP ; \ 6 bytes  \ 5 X +!

I: NOP    ( -- )     0 JMP, ;
I: ABS    ( n -- n') TOS ABS, ;
I: NEGATE ( n --n')  TOS NEG, ;
I: OR     ( w w -- w ) *SP+ TOS SOC, ;

\ Special instructions:
\ 9900 "Immediate" instructions and SYMBOLIC addressing need a literal 
\ number argument.
\ The compiler will try to emit code to put a literal into number into R4.
\ So we use the interpreter [ to give the number to the compiler.
\ These instructions end with ] to remind us of to preface them with [
\ Example:   [ 00F0 OR]  ( compiles  TOS 00F0 ORI, )

\ immediate mode instructions
I: OR]   ( n [n] --n) ]  TOS SWAP ORI, ;
I: +]    ( n [n] --)  ]  TOS SWAP AI,  ; \ (option 2) TOS + literal number
I: AND]  ( n [n] --n) ]  TOS SWAP ANDI, ;    \ and TOS with literal number

\ Symbolic addressing operators
I: @]    ( addr -- n)  ]  DUP ( addr) @@ TOS MOV,  ;
I: !]    ( n [var] --) ]  TOS SWAP @@ MOV,  DROP  ;
I: +!]   ( n [var] --) ]  TOS SWAP @@ ADD,  DROP  ;
I: C!]   ( c [var] --) ]  TOS SWPB,  TOS SWAP @@ MOVB, DROP ;
I: C@]   ( [var] -- c) ]  DUP  @@ TOS MOVB,  TOS 8 SRL, ;
I: 1+!]  ( [var] --)   ]  @@ INC, ;
I: 1-!]  ( [var] --)   ]  @@ DEC, ;

\ mem2mem symbolic store and +!

\ ** DO NOT CONFUSE WITH !]  and  +!]  ***

\  X @ Y !  is 10 instructions, 14 bytes
\ [ X  Y ]! is 1 instruction, 6 bytes
I: ]!    ( addr1 addr2) SWAP @@ ROT @@ ] MOV, ; \ mem2mem store
I: ]+!   ( addr1 addr2) SWAP @@ ROT @@ ] ADD, ; \ mem2mem plus-store

\ Alternative TOS to symbolic address store and +!
I: ->  ( n <var> -- ) T'  TOS SWAP @@ MOV,  DROP ;
I: ->+ ( n <var>-- )  T'  TOS SWAP @@ ADD,  DROP ;

\ indexed addressing uses TOS (ie: R4) as the index register

\  12 [ Q +]@
I: +]@  ( i addr -- n )  (TOS) TOS  MOV, ;

\ BEEF  13 [ Q +]!
I: +]!   ( n i addr -- )  *SP+ SWAP (TOS) MOV, DROP ;

\ instructions that require numbers compiled into the code 
\ These words in conventional Forth require 10 bytes each!
I: LSHIFT] ( n -- n)  TOS SWAP SLA, ;
I: RSHIFT] ( n -- n)  TOS SWAP SRL, ;


\ _______________________________________________________________
\ 2 and 3 instruction words for ANS/ISO compatibility
I: -     ( n n -- n') *SP+ TOS SUB, TOS NEG, ;
I: UM*   ( n n -- d)  *SP  TOS MPY, R5  *SP MOV, ;
I: *     ( n n -- n)  *SP+ R3 MOV,  TOS R3 MPY, ;
I: ALIGNED ( n -- n)   TOS INC,  TOS -2 ANDI, ;
I: AND   ( w w -- w ) *SP INV,  *SP+ TOS SZC, ;
I: 2@    ( addr -- d) 2 (TOS) PUSH,   *TOS TOS MOV, ; \ fetch double integer
I: EXIT  ( -- )       R11 RPOP,  RT, ;

\ _______________________________________________________________
\ hi-level Forth additions for people less pure than Chuck Moore
I: NOT  ( -- )  R1 STST,  R1 2000 ANDI, ;  \ invert EQ flag status
I: ON   ( variable --) *TOS SETO, DROP ;
I: OFF  ( variable --) *TOS CLR,  DROP ;
I: ><   ( n -- )  TOS SWPB, ;
I: R@   ( -- n)   DUP  R11 TOS MOV, ;

\ CUT n characters from left side of STRING (addr,len)
I: /STRING ( addr len n -- addr' len' ) TOS *SP SUB,  TOS 2 (SP) ADD,  DROP ;

\ **NOT NORMAL FORTH**
\ Only the 9900 status register is affected
\ At compile time a JUMP token is left on the stack for IF or UNTIL 
I: ?TERMINAL ( -- token) 0020 @@ BL, =  ; \ TI-99 ROM sub-routine

I: COUNT  ( Caddr -- addr len )
        TOS PUSH,        \ !!! CANT' USE DUP Need to make the copy
       *SP INC,           \ inc. past the count byte
       *TOS TOS MOVB,     \ put C@ inline to save space
        TOS 8 SRL, ;


\ compare TOS to a literal number 
I: #=]  ( n lit -- n)  TOS  SWAP CI, EQ ;
I: #<>] ( n lit -- n)  TOS  SWAP CI, NE ;


\ EQUIVALENTS for conventional Forth stack comparisons.
\ These still use the status register 
I: [0>]     *SP+ TOS CMP, > ;
I: [O<]     *SP+ TOS CMP, < ;
I: [U>]     *SP+ TOS CMP, U< ;
I: [U<]     *SP+ TOS CMP, U< ;

\ ANS Forth number compilers for the COMPILER wordlist

\ 'DP holds the address of the VARIABLE DP which is defF: PROGined
\ 0 VALUE 'DP \ pointer to Machine Forth memory pointer
I: ,     ( n --) T, ;
I: C,    ( c --) TC, ;
I: ALLOT ( n --) TALLOT ;

I: BOUNDS ( adr len -- adr2 adr1) *SP R1 MOV,  TOS *SP ADD,  R1 TOS MOV, ;
I: SWAP   ( n1 n2 -- n2 n1)       TOS R0 MOV,  *SP  TOS MOV, R0 *SP MOV, ;
\ ====================[ INTRINSICS END ]======================
\ ============================================================

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
: NEW.  
    (NEW)
    ['] WKSP0 CFA>NFA ['] MFORTH >BODY ! ;

HOST
HEX
 : MACHFORTH
      WARM
      INIT-WORDLISTS
      E4 7 VWTR
      PAGE ." MachForth Compiler V2.71 4OCT23"
      COMPILER
      NEW.
      ABORT ;

 LOCK

 INCLUDE DSK1.SAVESYS

 ' MACHFORTH SAVESYS DSK2.MACHFORTH
