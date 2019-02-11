* MZ390E error 101     (1/117)117 missing copy  = TESTERR1
* MZ390E error 111     (1/174)174 OPEN CODE duplicate .LAB1 at 172
*********************************************************************
* Copyright 2005 Automated Software Tools Corporation               *
* Copyright 2013 Cat Herder Software, LLC                           *
* Copyright 2018 Joachim Bartz, Germany                             *
*                                                                   *
* This source code is part of z390 assembler/emulator package.      *
*                                                                   *
* The z390 package is distributed under GNU general public license  *
*                                                                   *
* Author - Don Higgins                                              *
*********************************************************************
* 2005-09-30  DSH         Initial version                           *
* 2005-11-10  DSH RPI-80  Add duplicate and missing macro label     *
*                         errors                                    *
* 2005-12-08  DSH RPI-119 Add test for subscript on multiple values *
* 2006-01-28  DSH RPI-192 Test single quote and single &            *
* 2006-05-14  DSH RPI-314 Test compound AIF and computed AGO        *
*                         missing LAB                               *
* 2007-03-09  DSH RPI-565 Test invalid use of &SYSLIST without      *
*                         SUBSCRIPT                                 *
* 2007-05-07  DSH RPI-609 Test invalid string conversion in SETB    *
*                         expression                                *
* 2007-07-06  DSH RPI-645 Test invalid substring subscript 0        *
* 2007-11-30  DSH RPI-744 Test error on any non-printable ASCII     *
*                         characters                                *
* 2008-04-23  DSH RPI-836 Test error on SETC expression with        *
*                         undefined symbol and SETC array without   *
*                         subscript reference                       *
* 2008-07-31  DSH RPI-886 Test dequote error if quotes unbalanced   *
* 2008-08-18  DSH RPI-901 Move test of open code undef AGO tests to *
*                         TESTERR8.MLC/TESTERR9.MLC                 *
* 2008-11-07  DSH RPI-938 Test MNOTE syntax and all but 8,'?' on    *
*                         SYSTERM *
* 2009-06-15  DSH RPI-108 Test MNOTE syntax and all but 8,'?' on    *
*                         SYSTERM *
*********************************************************************
         TITLE 'TESTERR1 TEST MZ390 ERRORS'
TESTERR1 CSECT 
         USING *,15
* INVALID USE OF ' VS '' QUOTE AND & VS && AMPERSAND
* MZ390E error 286       (1/43)43 strings not allowed in SETA
* MZ390E error  37       (1/44)44 invalid expression variable - &
* MZ390E error  24       (1/45)45 Undefined macro variable - &X
* MZ390E error  37       (1/46)46 invalid expression variable - &
         MNOTE 'AMP=&' OK
         LA    1,=C'&&' OK
         DC    C'&&' OK
* MZ390E error  38       (1/51)51 expression parsing error - prev op ='X
                next op =~
* INVALID MULT VALUES BEYOND LIMIT
* INVALID MACRO EXPRESSIONS
* MZ390E error 205       (1/67)67 stack count < 2 = 1
* MZ390E error  35       (1/70)70 expression parsing error - total stacX
               k values=2  total ops=0
* MZ390E error  38       (1/73)73 expression parsing error - prev op ='X
                next op =~
* MZ390E error  38       (1/74)74 expression parsing error - prev op =,X
                next op =~
* MZ390E error 153       (1/76)76 lcla subscript < 1 = &A(0)
* MZ390E error 155       (1/80)80 lclb subscript < 1 = &B(0)
* MZ390E error 157       (1/84)84 lclc subscript < 1 = &C(0)
* MZ390E error 289       (1/87)87 duplicate allocation - &GA
* MZ390E error 154       (1/88)88 gbla subscript < 1 = &GA(0)
* MZ390E error 289       (1/91)91 duplicate allocation - &GB
* MZ390E error 156       (1/92)92 gblb subscript < 1 = &GB(0)
* MZ390E error 289       (1/95)95 duplicate allocation - &GC
* MZ390E error 158       (1/96)96 gblc subscript < 1 = &GC(0)
* INVALID SYSLIST SUBSCRIPT
         MACRO
         TEST1
         MNOTE 'P1=&SYSLIST(-1)'       ERROR
         MNOTE 'P1(1)=&SYSLIST(1)'     OK
         MNOTE 'P1(1,2)=&SYSLIST(1,2)' OK
         MNOTE 'P1(1,2)=&SYSLIST(1,0)' ERROR
         MEND
*MCALL #=     1 LV= 1          TEST1 (A,
* MZ390E error 276     (1/102)102 syslist negative subscript - -1
         MNOTE 'P1=(-1)'       ERROR
         MNOTE 'P1(1)=(A,'     OK
         MNOTE 'P1(1,2)=' OK
* MZ390E error  85     (1/105)105 invalid sublist index - 0
         MNOTE 'P1(1,2)=(1,0)' ERROR
*MEXIT #=     1 LV= 1 TEST1
         MACRO
&N       TEST2 &P1,&K1=
&N       SETA  1
&P1      SETB  1
&K1      SETC  'X'
         MNOTE 'N=&N P1=&P1 K1=&K1'
         MEND
*MCALL #=     2 LV= 1 A        TEST2 B,K1=C
* MZ390E error 104     (1/110)110 set/parm variable conflict - &N
* MZ390E error 104     (1/111)111 set/parm variable conflict - &P1
* MZ390E error 104     (1/112)112 set/parm variable conflict - &K1
         MNOTE 'N=A P1=B K1=C'
*MEXIT #=     2 LV= 1 TEST2
* VALID COPY STATEMENT ON NEXT LINE IN TESTERR1.MLC
         COPY  TESTERR1
* MZ390E error 266     (1/117)117 missing copy = TESTERR1
* TEST INVALID USE OF &SYSLIST
* MZ390E error 227     (1/119)119 missing quotes for SETC operand
         MACRO
         TEST  &A,&B,&C
&SLX     SETA  &SYSLIST             ERR ASM AND MAC
&SLY     SETB  &SYSLIST             ERR ASM AND MAC
&SLZ     SETC  &SYSLIST             ERR ASM AND MAC
         MNOTE 'SYSLIST=&SYSLIST'   ERR ASM AND MAC
         MNOTE 'UNDEF=&UNDEF'       ERR IF MAC ELSE OK
         MEND
*MCALL #=     3 LV= 1          TEST  A,B,C
* MZ390E error 208     (1/122)122 Invalid SYSLIST string reference
* MZ390E error 208     (1/123)123 Invalid SYSLIST string reference
* MZ390E error 227     (1/124)124 missing quotes for SETC operand
* MZ390E error 208     (1/125)125 Invalid SYSLIST string reference
         MNOTE 'SYSLIST='   ERR ASM AND MAC
* MZ390E error  24     (1/126)126 Undefined macro variable - &UNDEF
* MZ390E error 288     (1/126)126 Undefined set variable = &UNDEF'     X
                 ERR IF MAC ELSE OK
         MNOTE 'UNDEF='       ERR IF MAC ELSE OK
*MEXIT #=     3 LV= 1 TEST
* ADD INVALID  SETB STRING CONV
* MZ390E error 216     (1/130)130 invalid string in SETB expression
* ADD TEST INVALID SUBSTRING SUBSCRIPT 0
* MZ390E error 217     (1/132)132 invalid substring - offset=0 len=0
* RPI 744 test non-ascii character string error    (not reported)
         DC   C'eÉ'  MULTI-KEY VALUES 101 AND 201  (see TESTERRA)
* RPI 836 REPORT UNDEFINE SYMBOL AND SET ARRAY WITHOUT SUBSC.
* MZ390E error 229     (1/138)138 subscript required for &A836
* MZ390E error 230     (1/139)139 subscript required for &A836
* MZ390E error 190     (1/140)140 Ordinary symbol reference requires ASX
               M option - COUNT
* RPI 886 UNBALANCED DEQUOTE STRING
* 07/31/08 RPI 886 - TEST DEQUOTE ERROR IF QUOTES UNBALANCED
* MZ390E error 283     (1/144)144 Function character argument missing qX
               uotes
* MZ390E error 283     (1/146)146 Function character argument missing qX
               uotes
* RPI 938 MNOTE TESTS
         MNOTE 'TEST 1'       OK NO LVL, NO COMMA
         MNOTE 'TEST 2'(1,4)  ERR TEXT NOT IN '..' 1 OF 4 see MZ390 errX
               or
* MZ390E error 261     (1/149)149 MNOTE/PUNCH text must be in single quX
               otes'TEST 2'(1,4)  ERR TEXT NOT IN '..' 1 OF 4
         MNOTE 'TEST 2'(1,4)  ERR TEXT NOT IN '..' 1 OF 4
         MNOTE 'TEST 3'      OK COMMA
         MNOTE *,'TEST 4'     OK NOT ON SYSTERM
         MNOTE 4,'TEST 5'     OK
         MNOTE -1,'TEST 6'    ERR LVL < 0          2 OF 4 see MZ390 errX
               or
* MZ390E error 260     (1/153)153 MNOTE invalid level (0 - 255) - -1,'TX
               EST 6'    ERR LVL < 0          2 OF 4
         MNOTE 256,'TEST 7'   ERR LVL > 255        3 OF 4 see MZ390 errX
               or
* MZ390E error 260     (1/154)154 MNOTE invalid level (0 - 255) - 256,'X
               TEST 7'   ERR LVL > 255        3 OF 4
         MNOTE 1              ERR MISSING LVL,TEXT 4 OR 4 see MZ390 errX
               or
* MZ390E error 262     (1/155)155 MNOTE/PUNCH invalid 'text' - 1       X
                      ERR MISSING LVL,TEXT 4 OR 4
         MNOTE 1,              ERR MISSING LVL,TEXT 4 OR 4
**********************************************************
* ADD DUPLICATE AND MISSING MACRO ERRORS IN OPEN CODE
*
* THIS MUST BE LAST TEST WITH FAILING AGO IN OPEN CODE
* (The warning no issued for CHKMAC(0) required with NOASM)
* (See TESTERRA using ASM and CHKMAC(2) for warnings)
**********************************************************
         MACRO
         TESTLAB
.LAB1    ANOP
.LAB2    ANOP
.LAB1    ANOP
* MZ390E error 111     (1/168)168 TESTLAB duplicate .LAB1 at 166
         AGO    .UNDEFINED1
         AIF    (1 EQ 1).UNDEFINED2
         MEND
* MZ390E abort 16 file=1 line=175 OPEN CODE undefined .UNDEFINED1
* MZ390I total mnote warnings = 2
* MZ390I total mnote errors   = 0
* MZ390I max   mnote level    = 4
* MZ390I total mz390 errors   = 46
