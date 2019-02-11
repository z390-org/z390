*********************************************************************
* Copyright 2008 Automated Software Tools Corporation               *
* Copyright 2013 Cat Herder Software, LLC                           *
* Copyright 2018 Joachim Bartz, Germany                             *
*                                                                   *
* This source code is part of z390 assembler/emulator package.      *
*                                                                   *
* The z390 package is distributed under GNU general public license  *
*                                                                   *
* Author - Don Higgins                                              *
* Remark - Tests for z196 mainframe problem state instructions      *
*********************************************************************
* 2010-08-06 DSH          Initial version                           *
* 2010-08-06 DSH RPI-1125 Copy from TESTINS3 and added z196         *
*                         instruction tests                         *
* 2010-10-22 DSH RPI-1125 Add RC test for POPCNT, FIEBRA (see       *
*                         FIEBR TESTFB1)                            *
* 2010-11-10 DSH RPI-1125 Add FIXBRA, FIDBRA                        *
* 2010-11-11 DSH RPI-1125 Add KDXBRA,LEXBRA,CEFBRA,CDFBRA,CXFBRA    *
* 2010-11-23 DSH RPI-1125 B394-B39A                                 *
* 2010-11-24 DSH RPI-1125 BE9C-BEA2 CLFEBR - CXLGBR                 *
* 2010-11-29 DSH RPI-1125 Add B3A4-B3AE CEGBRA, CGEBRA, CLGEBR      *
* 2010-12-01 DSH RPI-1125 Add B3D0-B3DB MDTRA-SXTRA                 *
* 2010-12-02 DSH RPI-1125 Add B3E1-BEF9 CGDTRA-CXGTRA               *
* 2010-12-03 DSH RPI-1125 Add B928-B92D PCKMO KMOTR                 *
* 2010-12-04 DSH RPI-1125 Add B941-B95B CFDTR - CXLFTR, fix MDTRA   *
*                         DFP/BFP RND                               *
* 2010-12-06 DSH RPI-1125 Add B9C8-B9CB AHHHR-SLHHHR                *
* 2010-12-08 DSH RPI-1125 Add B9CD-B9DF CHHR-CLHHLR                 *
* 2010-12-09 DSH RPI-1125 Add B9E2-B9FB LOCGR-SLRK                  *
* 2010-12-09 DSH RPI-1125 Add C84-C85 LPD-LPDG                      *
* 2010-12-11 DSH RPI-1125 Add CC6-CCF BRCTH - CLIH                  *
* 2010-12-18 DSH RPI-1125 Add E3C0-E3CF LBH - CLHF                  *
* 2010-12-19 DSH RPI-1125 Add EBDC-EBFA SRAK - LAAL                 *
* 2011-05-18 DSH RPI-1164 ADD Extended opcodes for RNSBG, RXSBG,    *
*                         ROSBG, and RISBH/LG                       *
*********************************************************************
         MACRO
&N       CLCDD &S1,&S2
&N       LD    F0,&S1
         LD    F1,&S2
         CDTR  F0,F1
         MEND
         MACRO
&N       CLCLD &S1,&S2
&N       LX    F0,&S1
         LX    F1,&S2
         CXTR  F0,F1
         MEND
         PRINT DATA
         TITLE 'TESTINS3 - UNIT TEST Z196 EZ390 PROBLEM STATE INSTR.'
*********************************************************************
* RT1 macro used to automate code generated for mainline and test   *
* PSW CC routines. The macros define new base registers for each    *
* test so they can extend for any length.                           *
*                                                                   *
* See TESTINS1 for assembly test of all POP instructions.           *
* See TESTINS2 for unit test of problem state instructions up to z9 *
* See TESTINS3 for unit test of problem state z10 instructions      *
* See TESTFP1  for HFP and BFP floating point instructions tests    *
* See TESTDFP1 for DFP floating point instructions                  *
*********************************************************************
*MCALL #=     1 LV= 1 TESTINS3 RT1   MAIN
*MCALL #=     2 LV= 2 TESTINS3 SUBENTRY 
TESTINS3 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTINS3'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTINS3+8,13
*MEXIT #=     2 LV= 2 SUBENTRY
*MCALL #=     3 LV= 2          WTO   'TESTINS3 RT1 STARTED'
         BRAS  1,*+(WTO#0003_EOT-*+1)/2*2
         DC    AL2(WTO#0003_EOT-*,0),C'TESTINS3 RT1 STARTED'
WTO#0003_EOT     EQU *
         SVC   35
*MEXIT #=     3 LV= 2 WTO
         BRCL    15,RT1_START
RT1_ABORT DS 0H
         MVI   RT1_ABORTED,C'T'
*MCALL #=     4 LV= 2          WTO   'TESTINS3 RT1 TESTING ABORTED'
         BRAS  1,*+(WTO#0004_EOT-*+1)/2*2
         DC    AL2(WTO#0004_EOT-*,0),C'TESTINS3 RT1 TESTING ABORTED'
WTO#0004_EOT     EQU *
         SVC   35
*MEXIT #=     4 LV= 2 WTO
RT1_END  DS    0H
         MVC   RT1_DTOT,=X'402020202020'
         ED    RT1_DTOT,RT1_TOT
*MCALL #=     5 LV= 2          WTO   MF=(E,RT1_WTO1)
         LA    1,RT1_WTO1
         SVC   35
*MEXIT #=     5 LV= 2 WTO
         CLI   RT1_ABORTED,C'T'
         BE    RT1_DUMP
*MCALL #=     6 LV= 2          WTO   'TESTINS3 RT1 ENDED OK'
         BRAS  1,*+(WTO#0006_EOT-*+1)/2*2
         DC    AL2(WTO#0006_EOT-*,0),C'TESTINS3 RT1 ENDED OK'
WTO#0006_EOT     EQU *
         SVC   35
*MEXIT #=     6 LV= 2 WTO
*MCALL #=     7 LV= 2          SUBEXIT 
         LA    15,0
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=     7 LV= 2 SUBEXIT
RT1_DUMP DS    0H
*MCALL #=     8 LV= 2          ABEND 101
         LA   1,101
         SVC  13 ABEND R1=COMP CODE AND HIGH BIT = DUMP PGM STORAGE
*MEXIT #=     8 LV= 2 ABEND
RT1_LINK EQU   11
RT1_DATA EQU   *
RT1_TOT  DC    PL3'0' TOTAL RT1 TESTS COMPLETED
RT1_ONE  DC    P'1'
RT1_WTO1 DC    AL2(RT1_WTO_END-*,0),C'TESTINS3 RT1 TESTS COMPLETED = '
RT1_DTOT DC    CL6' ZZZZZ'
RT1_WTO_END EQU *
RT1_ABORTED DC C'F'
         LTORG 
RT1_TEST_CC0  DS    0H
         BNE   RT1_ABORT
RT1_OK   DS    0H
         AP    RT1_TOT,RT1_ONE
         BR    RT1_LINK
RT1_TEST_CC1  DS    0H
         BNL   RT1_ABORT
         AP    RT1_TOT,RT1_ONE
         BR    RT1_LINK
RT1_TEST_CC2  DS    0H
         BNH   RT1_ABORT
         AP    RT1_TOT,RT1_ONE
         BR    RT1_LINK
RT1_TEST_CC3  DS    0H
         BNO   RT1_ABORT
         AP    RT1_TOT,RT1_ONE
         BR    RT1_LINK
RT1_TEST_CCGE  DS    0H
         BL    RT1_ABORT
         AP    RT1_TOT,RT1_ONE
         BR    RT1_LINK
RT1_TEST_CCLE  DS    0H
         BH    RT1_ABORT
         AP    RT1_TOT,RT1_ONE
         BR    RT1_LINK
*MEXIT #=     1 LV= 1 RT1
*MCALL #=     9 LV= 1          EQUREGS REGS=GPR
R0     EQU 0
R1     EQU 1
R2     EQU 2
R3     EQU 3
R4     EQU 4
R5     EQU 5
R6     EQU 6
R7     EQU 7
R8     EQU 8
R9     EQU 9
R10    EQU 10
R11    EQU 11
R12    EQU 12
R13    EQU 13
R14    EQU 14
R15    EQU 15
*MEXIT #=     9 LV= 1 EQUREGS
*MCALL #=    10 LV= 1          EQUREGS REGS=FPR
F0     EQU 0
F1     EQU 1
F2     EQU 2
F3     EQU 3
F4     EQU 4
F5     EQU 5
F6     EQU 6
F7     EQU 7
F8     EQU 8
F9     EQU 9
F10    EQU 10
F11    EQU 11
F12    EQU 12
F13    EQU 13
F14    EQU 14
F15    EQU 15
*MEXIT #=    10 LV= 1 EQUREGS
DD1      DC    DD'0'
LD1      DC    LD'0'
PWORK    DS    D
WORD     DS    F
DWORD    DS    D
BYTE     DS    X
NIBCNT   DC    AL1(00,01,01,02,01,02,02,03,01,02,02,03,02,03,03,04)
*********************************************************************
* START z196 INSTRUCTION TESTS
*********************************************************************
*MCALL #=    11 LV= 1          RT1   START
RT1_START DS  0H
*MEXIT #=    11 LV= 1 RT1
* B2B8 SRNMB   S
         SRNMB 0  ROUND TO NEAREST WITH HALF EVEN
         LE    R1,=EB'2.5'
         FIEBR R0,0,R1
         CEB   R0,=EB'2'
*MCALL #=    12 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1
         LTORG 
RT1_CCE1        DS 0H
*MEXIT #=    12 LV= 1 RT1
         LE    R1,=EB'3.5'
         FIEBR R0,0,R1
         CEB   R0,=EB'4'
*MCALL #=    13 LV= 1          RT1   CCE
         DS    0H
RT1_TEST2        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE2
         LTORG 
RT1_CCE2        DS 0H
*MEXIT #=    13 LV= 1 RT1
         SRNMB  1  ROUND TOWARD ZERO
         LE    R1,=EB'2.5'
         FIEBR R0,0,R1
         CEB   R0,=EB'2'
*MCALL #=    14 LV= 1          RT1   CCE
         DS    0H
RT1_TEST3        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE3
         LTORG 
RT1_CCE3        DS 0H
*MEXIT #=    14 LV= 1 RT1
         LE    R1,=EB'3.5'
         FIEBR R0,0,R1
         CEB   R0,=EB'3'
*MCALL #=    15 LV= 1          RT1   CCE
         DS    0H
RT1_TEST4        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE4
         LTORG 
RT1_CCE4        DS 0H
*MEXIT #=    15 LV= 1 RT1
         SRNMB 2  ROUND TOWARD PLUS INFINITY
         LE    R1,=EB'2.5'
         FIEBR R0,0,R1
         CEB   R0,=EB'3'
*MCALL #=    16 LV= 1          RT1   CCE
         DS    0H
RT1_TEST5        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE5
         LTORG 
RT1_CCE5        DS 0H
*MEXIT #=    16 LV= 1 RT1
         LE    R1,=EB'3.5'
         FIEBR R0,0,R1
         CEB   R0,=EB'4'
*MCALL #=    17 LV= 1          RT1   CCE
         DS    0H
RT1_TEST6        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE6
         LTORG 
RT1_CCE6        DS 0H
*MEXIT #=    17 LV= 1 RT1
         SRNMB 3  ROUND TOWARD NEG  INFINITY
         LE    R1,=EB'2.5'
         FIEBR R0,0,R1
         CEB   R0,=EB'2'
*MCALL #=    18 LV= 1          RT1   CCE
         DS    0H
RT1_TEST7        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE7
         LTORG 
RT1_CCE7        DS 0H
*MEXIT #=    18 LV= 1 RT1
         LE    R1,=EB'3.5'
         FIEBR R0,0,R1
         CEB   R0,=EB'3'
*MCALL #=    19 LV= 1          RT1   CCE
         DS    0H
RT1_TEST8        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE8
         LTORG 
RT1_CCE8        DS 0H
*MEXIT #=    19 LV= 1 RT1
         SRNM  0  DEFAULT ROUND TO NEAREST WITH HALF EVEN RESET
         LE    R1,=EB'2.5'
         FIEBR R0,0,R1
         CEB   R0,=EB'2'
*MCALL #=    20 LV= 1          RT1   CCE
         DS    0H
RT1_TEST9        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE9
         LTORG 
RT1_CCE9        DS 0H
*MEXIT #=    20 LV= 1 RT1
         LE    R1,=EB'3.5'
         FIEBR R0,0,R1
         CEB   R0,=EB'4'
*MCALL #=    21 LV= 1          RT1   CCE
         DS    0H
RT1_TEST10       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE10
         LTORG 
RT1_CCE10       DS 0H
*MEXIT #=    21 LV= 1 RT1
* B344 LEDBRA  R1,M3,R2,M4
         LD    R1,=DB'123'
         LEDBRA R0,1,R1,0
         CEB   R0,=EB'123'
*MCALL #=    22 LV= 1          RT1   CCE
         DS    0H
RT1_TEST11       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE11
         LTORG 
RT1_CCE11       DS 0H
*MEXIT #=    22 LV= 1 RT1
* B345 LDXBRA  R1,M3,R2,M4
*MCALL #=    23 LV= 1          LX    R1,=LB'123'
         LA    15,=LB'123'
         LD    R1,0(15)
         LD    R1+2,8(15)
*MEXIT #=    23 LV= 1 LX
         LDXBRA R0,1,R1,0
         CDB   R0,=DB'123'
*MCALL #=    24 LV= 1          RT1   CCE
         DS    0H
RT1_TEST12       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE12
         LTORG 
RT1_CCE12       DS 0H
*MEXIT #=    24 LV= 1 RT1
* B346 LEXBRA  R1,M3,R2,M4
*MCALL #=    25 LV= 1          LX    R1,=LB'123'
         LA    15,=LB'123'
         LD    R1,0(15)
         LD    R1+2,8(15)
*MEXIT #=    25 LV= 1 LX
         LEXBRA R0,1,R1,0
         CEB   R0,=EB'123'
*MCALL #=    26 LV= 1          RT1   CCE
         DS    0H
RT1_TEST13       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE13
         LTORG 
RT1_CCE13       DS 0H
*MEXIT #=    26 LV= 1 RT1
* B347 FIXBRA  R1,M3,R2,M4 (SEE TESTFP1 SRNM FOR FIXBR TEST)
         SRNM  0  DEFAULT ROUND TO NEAREST WITH HALF EVEN
*MCALL #=    27 LV= 1          LX    R0,=LB'1.1' RPI-518 WAS R2
         LA    15,=LB'1.1'
         LD    R0,0(15)
         LD    R0+2,8(15)
*MEXIT #=    27 LV= 1 LX
         FIXBRA R1,0,R0,0
*MCALL #=    28 LV= 1          LX    R4,=LB'1.0'
         LA    15,=LB'1.0'
         LD    R4,0(15)
         LD    R4+2,8(15)
*MEXIT #=    28 LV= 1 LX
         CXBR  R1,R4
*MCALL #=    29 LV= 1          RT1   CCE
         DS    0H
RT1_TEST14       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE14
         LTORG 
RT1_CCE14       DS 0H
*MEXIT #=    29 LV= 1 RT1
*MCALL #=    30 LV= 1          LX    R0,=LB'1.5' RPI-518 WAS R2
         LA    15,=LB'1.5'
         LD    R0,0(15)
         LD    R0+2,8(15)
*MEXIT #=    30 LV= 1 LX
         FIXBRA R1,0,R0,0
*MCALL #=    31 LV= 1          LX    R4,=LB'2.0'
         LA    15,=LB'2.0'
         LD    R4,0(15)
         LD    R4+2,8(15)
*MEXIT #=    31 LV= 1 LX
         CXBR  R1,R4
*MCALL #=    32 LV= 1          RT1   CCE
         DS    0H
RT1_TEST15       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE15
         LTORG 
RT1_CCE15       DS 0H
*MEXIT #=    32 LV= 1 RT1
*MCALL #=    33 LV= 1          LX    R0,=LB'2.5' RPI-518 WAS R2
         LA    15,=LB'2.5'
         LD    R0,0(15)
         LD    R0+2,8(15)
*MEXIT #=    33 LV= 1 LX
         FIXBRA R1,0,R0,0
*MCALL #=    34 LV= 1          LX    R4,=LB'2.0'
         LA    15,=LB'2.0'
         LD    R4,0(15)
         LD    R4+2,8(15)
*MEXIT #=    34 LV= 1 LX
         CXBR  R1,R4
*MCALL #=    35 LV= 1          RT1   CCE
         DS    0H
RT1_TEST16       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE16
         LTORG 
RT1_CCE16       DS 0H
*MEXIT #=    35 LV= 1 RT1
*MCALL #=    36 LV= 1          LX    R0,=LB'-1.5' RPI-518 WAS R2
         LA    15,=LB'-1.5'
         LD    R0,0(15)
         LD    R0+2,8(15)
*MEXIT #=    36 LV= 1 LX
         FIXBRA R1,0,R0,0
*MCALL #=    37 LV= 1          LX    R4,=LB'-2.0'
         LA    15,=LB'-2.0'
         LD    R4,0(15)
         LD    R4+2,8(15)
*MEXIT #=    37 LV= 1 LX
         CXBR  R1,R4
*MCALL #=    38 LV= 1          RT1   CCE
         DS    0H
RT1_TEST17       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE17
         LTORG 
RT1_CCE17       DS 0H
*MEXIT #=    38 LV= 1 RT1
*MCALL #=    39 LV= 1          LX    R0,=LB'-2.5' RPI-518 WAS R2
         LA    15,=LB'-2.5'
         LD    R0,0(15)
         LD    R0+2,8(15)
*MEXIT #=    39 LV= 1 LX
         FIXBRA R1,0,R0,0
*MCALL #=    40 LV= 1          LX    R4,=LB'-2.0'
         LA    15,=LB'-2.0'
         LD    R4,0(15)
         LD    R4+2,8(15)
*MEXIT #=    40 LV= 1 LX
         CXBR  R1,R4
*MCALL #=    41 LV= 1          RT1   CCE
         DS    0H
RT1_TEST18       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE18
         LTORG 
RT1_CCE18       DS 0H
*MEXIT #=    41 LV= 1 RT1
* B357 FIEBRA  R1,M3,R2,M4 (SEE TESTFP1 SRNM FOR FIEBR TEST)
            SRNM  0  DEFAULT ROUND TO NEAREST WITH HALF EVEN
               LE    R1,=EB'2.5'
               FIEBRA R0,0,R1,0
               CEB   R0,=EB'2'
*MCALL #=    42 LV= 1                RT1   CCE
         DS    0H
RT1_TEST19       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE19
         LTORG 
RT1_CCE19       DS 0H
*MEXIT #=    42 LV= 1 RT1
               LE    R1,=EB'3.5'
               FIEBRA R0,0,R1,0
               CEB   R0,=EB'4'
*MCALL #=    43 LV= 1                RT1   CCE
         DS    0H
RT1_TEST20       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE20
         LTORG 
RT1_CCE20       DS 0H
*MEXIT #=    43 LV= 1 RT1
               SRNM  1  ROUND TOWARD ZERO
               LE    R1,=EB'2.5'
               FIEBRA R0,0,R1,0
               CEB   R0,=EB'2'
*MCALL #=    44 LV= 1                RT1   CCE
         DS    0H
RT1_TEST21       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE21
         LTORG 
RT1_CCE21       DS 0H
*MEXIT #=    44 LV= 1 RT1
               LE    R1,=EB'3.5'
               FIEBRA R0,0,R1,0
               CEB   R0,=EB'3'
*MCALL #=    45 LV= 1                RT1   CCE
         DS    0H
RT1_TEST22       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE22
         LTORG 
RT1_CCE22       DS 0H
*MEXIT #=    45 LV= 1 RT1
               SRNM  2  ROUND TOWARD PLUS INFINITY
               LE    R1,=EB'2.5'
               FIEBRA R0,0,R1,0
               CEB   R0,=EB'3'
*MCALL #=    46 LV= 1                RT1   CCE
         DS    0H
RT1_TEST23       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE23
         LTORG 
RT1_CCE23       DS 0H
*MEXIT #=    46 LV= 1 RT1
               LE    R1,=EB'3.5'
               FIEBRA R0,0,R1,0
               CEB   R0,=EB'4'
*MCALL #=    47 LV= 1                RT1   CCE
         DS    0H
RT1_TEST24       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE24
         LTORG 
RT1_CCE24       DS 0H
*MEXIT #=    47 LV= 1 RT1
               SRNM  3  ROUND TOWARD NEG  INFINITY
               LE    R1,=EB'2.5'
               FIEBRA R0,0,R1,0
               CEB   R0,=EB'2'
*MCALL #=    48 LV= 1                RT1   CCE
         DS    0H
RT1_TEST25       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE25
         LTORG 
RT1_CCE25       DS 0H
*MEXIT #=    48 LV= 1 RT1
               LE    R1,=EB'3.5'
               FIEBRA R0,0,R1,0
               CEB   R0,=EB'3'
*MCALL #=    49 LV= 1                RT1   CCE
         DS    0H
RT1_TEST26       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE26
         LTORG 
RT1_CCE26       DS 0H
*MEXIT #=    49 LV= 1 RT1
               SRNM  0  DEFAULT ROUND TO NEAREST WITH HALF EVEN RESET
               LE    R1,=EB'2.5'
               FIEBRA R0,0,R1,0
               CEB   R0,=EB'2'
*MCALL #=    50 LV= 1                RT1   CCE
         DS    0H
RT1_TEST27       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE27
         LTORG 
RT1_CCE27       DS 0H
*MEXIT #=    50 LV= 1 RT1
               LE    R1,=EB'3.5'
               FIEBRA R0,0,R1,0
               CEB   R0,=EB'4'
*MCALL #=    51 LV= 1          RT1   CCE
         DS    0H
RT1_TEST28       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE28
         LTORG 
RT1_CCE28       DS 0H
*MEXIT #=    51 LV= 1 RT1
* B35F FIDBRA
         LD    R2,=DB'1.1'
         FIDBRA R1,0,R2,0
         CDB   R1,=DB'1.0'
*MCALL #=    52 LV= 1          RT1   CCE
         DS    0H
RT1_TEST29       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE29
         LTORG 
RT1_CCE29       DS 0H
*MEXIT #=    52 LV= 1 RT1
         LD    R2,=DB'1.5'
         FIDBRA R1,0,R2,0
         CDB   R1,=DB'2.0'
*MCALL #=    53 LV= 1          RT1   CCE
         DS    0H
RT1_TEST30       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE30
         LTORG 
RT1_CCE30       DS 0H
*MEXIT #=    53 LV= 1 RT1
         LD    R2,=DB'2.5'
         FIDBRA R1,0,R2,0
         CDB   R1,=DB'2.0'
*MCALL #=    54 LV= 1          RT1   CCE
         DS    0H
RT1_TEST31       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE31
         LTORG 
RT1_CCE31       DS 0H
*MEXIT #=    54 LV= 1 RT1
         LD    R2,=DB'-1.5'
         FIDBRA R1,0,R2,0
         CDB   R1,=DB'-2.0'
*MCALL #=    55 LV= 1          RT1   CCE
         DS    0H
RT1_TEST32       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE32
         LTORG 
RT1_CCE32       DS 0H
*MEXIT #=    55 LV= 1 RT1
         LD    R2,=DB'-2.5'
         FIDBRA R1,0,R2,0
         CDB   R1,=DB'-2.0'
*MCALL #=    56 LV= 1          RT1   CCE
         DS    0H
RT1_TEST33       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE33
         LTORG 
RT1_CCE33       DS 0H
*MEXIT #=    56 LV= 1 RT1
* B390 CELFBR R1,M3,R2,M4
         LG    R2,=XL8'00000000FFFFFE00'
         CELFBR R1,0,R2,0
         CGEBR  R0,0,R1
         CLM    R0,14,=X'FFFFFE'
*MCALL #=    57 LV= 1          RT1    CCE
         DS    0H
RT1_TEST34       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE34
         LTORG 
RT1_CCE34       DS 0H
*MEXIT #=    57 LV= 1 RT1
* B391 CDLFBR R1,M3,R2,M4
          LG    R2,=XL8'00000000FFFFFFFF'
          CDLFBR R1,0,R2,0
          CGDBR  R0,0,R1
          CLGR   R0,R2
*MCALL #=    58 LV= 1          RT1    CCE
         DS    0H
RT1_TEST35       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE35
         LTORG 
RT1_CCE35       DS 0H
*MEXIT #=    58 LV= 1 RT1
* B392 CXLFBR R1,M3,R2,M4
          LG    R2,=XL8'00000000FFFFFFFF'
          CXLFBR R0,0,R2,0
          CGXBR  R1,0,R0
          CLGR   R1,R2
*MCALL #=    59 LV= 1          RT1    CCE
         DS    0H
RT1_TEST36       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE36
         LTORG 
RT1_CCE36       DS 0H
*MEXIT #=    59 LV= 1 RT1
* B394 CEFBRA  R1,M3,R2,M4
         LG    R2,=XL8'00000000FFFFFFFF'
         CEFBRA R1,0,R2,0
         CGEBR  R0,0,R1
         CLR    R0,R2
*MCALL #=    60 LV= 1          RT1    CCE
         DS    0H
RT1_TEST37       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE37
         LTORG 
RT1_CCE37       DS 0H
*MEXIT #=    60 LV= 1 RT1
* B395 CDFBRA R1,M3,R2,M4
          LG    R2,=XL8'FFFFFFFFFFFFFFFF'
          CDFBRA R1,0,R2,0
          CGDBR  R0,0,R1
          CLGR   R0,R2
*MCALL #=    61 LV= 1          RT1    CCE
         DS    0H
RT1_TEST38       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE38
         LTORG 
RT1_CCE38       DS 0H
*MEXIT #=    61 LV= 1 RT1
* B396 CXFBRA R1,M3,R2,M4
          LG    R2,=XL8'FFFFFFFFFFFFFFFF'
          CXFBRA R0,0,R2,0
          CGXBR  R1,0,R0
          CLGR   R1,R2
*MCALL #=    62 LV= 1          RT1    CCE
         DS    0H
RT1_TEST39       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE39
         LTORG 
RT1_CCE39       DS 0H
*MEXIT #=    62 LV= 1 RT1
* B398 CFEBRA
         LE    R2,=EB'123'
         CFEBRA R0,0,R2,0
         C     R0,=F'123'
*MCALL #=    63 LV= 1          RT1   CCE
         DS    0H
RT1_TEST40       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE40
         LTORG 
RT1_CCE40       DS 0H
*MEXIT #=    63 LV= 1 RT1
* B399 CFDBRA
         LD    R2,=DB'123'
         CFDBRA R0,0,R2,0
         C     R0,=F'123'
*MCALL #=    64 LV= 1          RT1   CCE
         DS    0H
RT1_TEST41       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE41
         LTORG 
RT1_CCE41       DS 0H
*MEXIT #=    64 LV= 1 RT1
* B39A CFXBRA
*MCALL #=    65 LV= 1          LX    R1,=LB'123'
         LA    15,=LB'123'
         LD    R1,0(15)
         LD    R1+2,8(15)
*MEXIT #=    65 LV= 1 LX
         CFXBRA R0,0,R1,0
         C     R0,=F'123'
*MCALL #=    66 LV= 1          RT1   CCE
         DS    0H
RT1_TEST42       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE42
         LTORG 
RT1_CCE42       DS 0H
*MEXIT #=    66 LV= 1 RT1
* B39C CLFEBR
         LE    R2,=EB'-123'
         CLFEBR R0,0,R2,0
*MCALL #=    67 LV= 1          RT1   CCL
         DS    0H
RT1_TEST43       BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL43
         LTORG 
RT1_CCL43       DS 0H
*MEXIT #=    67 LV= 1 RT1
         C     R0,=F'123'
*MCALL #=    68 LV= 1          RT1   CCE
         DS    0H
RT1_TEST44       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE44
         LTORG 
RT1_CCE44       DS 0H
*MEXIT #=    68 LV= 1 RT1
* B39D CLFDBR
         LD    R2,=DB'-123'
         CLFDBR R0,0,R2,0
*MCALL #=    69 LV= 1          RT1   CCL
         DS    0H
RT1_TEST45       BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL45
         LTORG 
RT1_CCL45       DS 0H
*MEXIT #=    69 LV= 1 RT1
         C     R0,=F'123'
*MCALL #=    70 LV= 1          RT1   CCE
         DS    0H
RT1_TEST46       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE46
         LTORG 
RT1_CCE46       DS 0H
*MEXIT #=    70 LV= 1 RT1
* B39C CLFXBR
*MCALL #=    71 LV= 1          LX    R1,=LB'-123'
         LA    15,=LB'-123'
         LD    R1,0(15)
         LD    R1+2,8(15)
*MEXIT #=    71 LV= 1 LX
         CLFXBR R0,0,R1,0
*MCALL #=    72 LV= 1          RT1   CCL
         DS    0H
RT1_TEST47       BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL47
         LTORG 
RT1_CCL47       DS 0H
*MEXIT #=    72 LV= 1 RT1
         C     R0,=F'123'
*MCALL #=    73 LV= 1          RT1   CCE
         DS    0H
RT1_TEST48       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE48
         LTORG 
RT1_CCE48       DS 0H
*MEXIT #=    73 LV= 1 RT1
* B3A0 CELGBR R1,M3,R2,M4
         LG    R2,=XL8'FFFFFC0000000000'
         CELGBR R1,0,R2,0
         CLGEBR R0,0,R1,0
*MCALL #=    74 LV= 1          RT1    CCH
         DS    0H
RT1_TEST49       BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH49
         LTORG 
RT1_CCH49       DS 0H
*MEXIT #=    74 LV= 1 RT1
         CLMH   R0,X'E',=X'FFFFFC'
*MCALL #=    75 LV= 1          RT1    CCE
         DS    0H
RT1_TEST50       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE50
         LTORG 
RT1_CCE50       DS 0H
*MEXIT #=    75 LV= 1 RT1
* B3A1 CDLGBR R1,M3,R2,M4
          LG    R2,=XL8'8000000000000000'
          CDLGBR R1,0,R2,0
          CLGDBR R0,0,R1,0
*MCALL #=    76 LV= 1           RT1    CCH
         DS    0H
RT1_TEST51       BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH51
         LTORG 
RT1_CCH51       DS 0H
*MEXIT #=    76 LV= 1 RT1
          CLMH   R0,15,=X'80000000'
*MCALL #=    77 LV= 1           RT1    CCE
         DS    0H
RT1_TEST52       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE52
         LTORG 
RT1_CCE52       DS 0H
*MEXIT #=    77 LV= 1 RT1
* B3A2 CXLGBR R1,M3,R2,M4
          LG    R2,=XL8'8000000000000000'
          CXLGBR R0,0,R2,0
          CLGXBR  R1,0,R0,0
*MCALL #=    78 LV= 1           RT1    CCH
         DS    0H
RT1_TEST53       BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH53
         LTORG 
RT1_CCH53       DS 0H
*MEXIT #=    78 LV= 1 RT1
          CLGR   R1,R2
*MCALL #=    79 LV= 1          RT1    CCE
         DS    0H
RT1_TEST54       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE54
         LTORG 
RT1_CCE54       DS 0H
*MEXIT #=    79 LV= 1 RT1
* B3A4 CEGBRA  R1,M3,R2,M4
         LG    R2,=FL8'-1'
         CEGBRA R1,0,R2,0
         CGEBR  R0,0,R1
         CLGR   R0,R2
*MCALL #=    80 LV= 1          RT1    CCE
         DS    0H
RT1_TEST55       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE55
         LTORG 
RT1_CCE55       DS 0H
*MEXIT #=    80 LV= 1 RT1
* B3A5 CDGBRA R1,M3,R2,M4
          LG    R2,=FL8'-1'
          CDGBRA R1,0,R2,0
          CGDBR  R0,0,R1
          CLGR   R0,R2
*MCALL #=    81 LV= 1          RT1    CCE
         DS    0H
RT1_TEST56       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE56
         LTORG 
RT1_CCE56       DS 0H
*MEXIT #=    81 LV= 1 RT1
* B3A6 CXGBRA R1,M3,R2,M4
          LG    R2,=FL8'-1'
          CXGBRA R0,0,R2,0
          CGXBR  R1,0,R0
          CLGR   R1,R2
*MCALL #=    82 LV= 1          RT1    CCE
         DS    0H
RT1_TEST57       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE57
         LTORG 
RT1_CCE57       DS 0H
*MEXIT #=    82 LV= 1 RT1
* B3A8 CGEBRA
         LE    R2,=EB'123'
         CGEBRA R0,0,R2,0
         C     R0,=F'123'
*MCALL #=    83 LV= 1          RT1   CCE
         DS    0H
RT1_TEST58       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE58
         LTORG 
RT1_CCE58       DS 0H
*MEXIT #=    83 LV= 1 RT1
* B3A9 CGDBRA
         LD    R2,=DB'123'
         CGDBRA R0,0,R2,0
         C     R0,=F'123'
*MCALL #=    84 LV= 1          RT1   CCE
         DS    0H
RT1_TEST59       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE59
         LTORG 
RT1_CCE59       DS 0H
*MEXIT #=    84 LV= 1 RT1
* B3AA CGXBRA
*MCALL #=    85 LV= 1          LX    R1,=LB'123'
         LA    15,=LB'123'
         LD    R1,0(15)
         LD    R1+2,8(15)
*MEXIT #=    85 LV= 1 LX
         CGXBRA R0,0,R1,0
         C     R0,=F'123'
*MCALL #=    86 LV= 1          RT1   CCE
         DS    0H
RT1_TEST60       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE60
         LTORG 
RT1_CCE60       DS 0H
*MEXIT #=    86 LV= 1 RT1
* B3AC CLGEBR
         LE    R2,=EB'-123'
         CLGEBR R0,0,R2,0
*MCALL #=    87 LV= 1          RT1   CCL
         DS    0H
RT1_TEST61       BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL61
         LTORG 
RT1_CCL61       DS 0H
*MEXIT #=    87 LV= 1 RT1
         CG     R0,=FL8'123'
*MCALL #=    88 LV= 1          RT1   CCE
         DS    0H
RT1_TEST62       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE62
         LTORG 
RT1_CCE62       DS 0H
*MEXIT #=    88 LV= 1 RT1
* B3AD CLGDBR
         LD    R2,=DB'-123'
         CLGDBR R0,0,R2,0
*MCALL #=    89 LV= 1          RT1   CCL
         DS    0H
RT1_TEST63       BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL63
         LTORG 
RT1_CCL63       DS 0H
*MEXIT #=    89 LV= 1 RT1
         CG     R0,=FL8'123'
*MCALL #=    90 LV= 1          RT1   CCE
         DS    0H
RT1_TEST64       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE64
         LTORG 
RT1_CCE64       DS 0H
*MEXIT #=    90 LV= 1 RT1
* B3AC CLGXBR
*MCALL #=    91 LV= 1          LX    R1,=LB'-123'
         LA    15,=LB'-123'
         LD    R1,0(15)
         LD    R1+2,8(15)
*MEXIT #=    91 LV= 1 LX
         CLGXBR R0,0,R1,0
*MCALL #=    92 LV= 1          RT1   CCL
         DS    0H
RT1_TEST65       BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL65
         LTORG 
RT1_CCL65       DS 0H
*MEXIT #=    92 LV= 1 RT1
         CG    R0,=FL8'123'
*MCALL #=    93 LV= 1          RT1   CCE
         DS    0H
RT1_TEST66       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE66
         LTORG 
RT1_CCE66       DS 0H
*MEXIT #=    93 LV= 1 RT1
* B3D0 MDTRA
         LD    2,=DD'30'
         LD    3,=DD'20'
         MDTRA 1,2,3,0
         STD   1,DD1
*MCALL #=    94 LV= 1          CLCDD DD1,=DD'600'
         LD    F0,DD1
         LD    F1,=DD'600'
         CDTR  F0,F1
*MEXIT #=    94 LV= 1 CLCDD
*MCALL #=    95 LV= 1          RT1   CCE
         DS    0H
RT1_TEST67       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE67
         LTORG 
RT1_CCE67       DS 0H
*MEXIT #=    95 LV= 1 RT1
* B3D1 DDTRA
         LD    2,=DD'600'
         LD    3,=DD'20'
         DDTRA 1,2,3,0
         STD   1,DD1
*MCALL #=    96 LV= 1          CLCDD DD1,=DD'30'
         LD    F0,DD1
         LD    F1,=DD'30'
         CDTR  F0,F1
*MEXIT #=    96 LV= 1 CLCDD
*MCALL #=    97 LV= 1          RT1   CCE
         DS    0H
RT1_TEST68       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE68
         LTORG 
RT1_CCE68       DS 0H
*MEXIT #=    97 LV= 1 RT1
* B3D2 ADTRA
         LD    2,=DD'1234567890123456'
         LD    3,=DD'1111111111111111'
         ADTRA 1,2,3,0
*MCALL #=    98 LV= 1          RT1   CC2
         DS    0H
RT1_TEST69       BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH69
         LTORG 
RT1_CCH69       DS 0H
*MEXIT #=    98 LV= 1 RT1
         STD   1,DD1
*MCALL #=    99 LV= 1          CLCDD DD1,=DD'2345679001234567'
         LD    F0,DD1
         LD    F1,=DD'2345679001234567'
         CDTR  F0,F1
*MEXIT #=    99 LV= 1 CLCDD
*MCALL #=   100 LV= 1          RT1   CCE
         DS    0H
RT1_TEST70       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE70
         LTORG 
RT1_CCE70       DS 0H
*MEXIT #=   100 LV= 1 RT1
* B3D3 SDTRA
         LD    2,=DD'1234567890123456'
         LD    3,=DD'1111111111111111'
         SDTRA 1,2,3,0
*MCALL #=   101 LV= 1          RT1   CC2
         DS    0H
RT1_TEST71       BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH71
         LTORG 
RT1_CCH71       DS 0H
*MEXIT #=   101 LV= 1 RT1
         STD   1,DD1
*MCALL #=   102 LV= 1          CLCDD DD1,=DD'123456779012345'
         LD    F0,DD1
         LD    F1,=DD'123456779012345'
         CDTR  F0,F1
*MEXIT #=   102 LV= 1 CLCDD
*MCALL #=   103 LV= 1          RT1   CCE
         DS    0H
RT1_TEST72       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE72
         LTORG 
RT1_CCE72       DS 0H
*MEXIT #=   103 LV= 1 RT1
* B3D8 MXTRA
*MCALL #=   104 LV= 1          LX    4,=LD'30'
         LA    15,=LD'30'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   104 LV= 1 LX
*MCALL #=   105 LV= 1          LX    5,=LD'20'
         LA    15,=LD'20'
         LD    5,0(15)
         LD    5+2,8(15)
*MEXIT #=   105 LV= 1 LX
         MXTRA 1,4,5,0
*MCALL #=   106 LV= 1          STX   1,LD1
         LA    15,LD1
         STD   1,0(15)
         STD   1+2,8(15)
*MEXIT #=   106 LV= 1 STX
*MCALL #=   107 LV= 1          CLCLD LD1,=LD'600'
*MCALL #=   108 LV= 2          LX    F0,LD1
         LA    15,LD1
         LD    F0,0(15)
         LD    F0+2,8(15)
*MEXIT #=   108 LV= 2 LX
*MCALL #=   109 LV= 2          LX    F1,=LD'600'
         LA    15,=LD'600'
         LD    F1,0(15)
         LD    F1+2,8(15)
*MEXIT #=   109 LV= 2 LX
         CXTR  F0,F1
*MEXIT #=   107 LV= 1 CLCLD
*MCALL #=   110 LV= 1          RT1   CCE
         DS    0H
RT1_TEST73       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE73
         LTORG 
RT1_CCE73       DS 0H
*MEXIT #=   110 LV= 1 RT1
* B3D9 DXTRA
*MCALL #=   111 LV= 1          LX    4,=LD'600'
         LA    15,=LD'600'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   111 LV= 1 LX
*MCALL #=   112 LV= 1          LX    5,=LD'20'
         LA    15,=LD'20'
         LD    5,0(15)
         LD    5+2,8(15)
*MEXIT #=   112 LV= 1 LX
         DXTRA 1,4,5,0
*MCALL #=   113 LV= 1          STX   1,LD1
         LA    15,LD1
         STD   1,0(15)
         STD   1+2,8(15)
*MEXIT #=   113 LV= 1 STX
*MCALL #=   114 LV= 1          CLCLD LD1,=LD'30'
*MCALL #=   115 LV= 2          LX    F0,LD1
         LA    15,LD1
         LD    F0,0(15)
         LD    F0+2,8(15)
*MEXIT #=   115 LV= 2 LX
*MCALL #=   116 LV= 2          LX    F1,=LD'30'
         LA    15,=LD'30'
         LD    F1,0(15)
         LD    F1+2,8(15)
*MEXIT #=   116 LV= 2 LX
         CXTR  F0,F1
*MEXIT #=   114 LV= 1 CLCLD
*MCALL #=   117 LV= 1          RT1   CCE
         DS    0H
RT1_TEST74       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE74
         LTORG 
RT1_CCE74       DS 0H
*MEXIT #=   117 LV= 1 RT1
* B3DA AXTRA
*MCALL #=   118 LV= 1          LX    4,=LD'1234567890123456789012345678X
               901234'
         LA    15,=LD'1234567890123456789012345678901234'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   118 LV= 1 LX
*MCALL #=   119 LV= 1          LX    5,=LD'1111111111111111111111111111X
               111111'
         LA    15,=LD'1111111111111111111111111111111111'
         LD    5,0(15)
         LD    5+2,8(15)
*MEXIT #=   119 LV= 1 LX
         AXTRA 1,4,5,0
*MCALL #=   120 LV= 1          RT1   CC2
         DS    0H
RT1_TEST75       BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH75
         LTORG 
RT1_CCH75       DS 0H
*MEXIT #=   120 LV= 1 RT1
*MCALL #=   121 LV= 1          STX   1,LD1
         LA    15,LD1
         STD   1,0(15)
         STD   1+2,8(15)
*MEXIT #=   121 LV= 1 STX
*MCALL #=   122 LV= 1          CLCLD LD1,=LD'23456790012345679001234567X
               90012345'
*MCALL #=   123 LV= 2          LX    F0,LD1
         LA    15,LD1
         LD    F0,0(15)
         LD    F0+2,8(15)
*MEXIT #=   123 LV= 2 LX
*MCALL #=   124 LV= 2          LX    F1,=LD'234567900123456790012345679X
               0012345'
         LA    15,=LD'2345679001234567900123456790012345'
         LD    F1,0(15)
         LD    F1+2,8(15)
*MEXIT #=   124 LV= 2 LX
         CXTR  F0,F1
*MEXIT #=   122 LV= 1 CLCLD
*MCALL #=   125 LV= 1          RT1   CCE
         DS    0H
RT1_TEST76       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE76
         LTORG 
RT1_CCE76       DS 0H
*MEXIT #=   125 LV= 1 RT1
* B3DB SXTRA
*MCALL #=   126 LV= 1          LX    4,=LD'1234567890123456789012345678X
               901234'
         LA    15,=LD'1234567890123456789012345678901234'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   126 LV= 1 LX
*MCALL #=   127 LV= 1          LX    5,=LD'1111111111111111111111111111X
               111111'
         LA    15,=LD'1111111111111111111111111111111111'
         LD    5,0(15)
         LD    5+2,8(15)
*MEXIT #=   127 LV= 1 LX
         SXTRA 1,4,5,0
*MCALL #=   128 LV= 1          RT1   CC2
         DS    0H
RT1_TEST77       BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH77
         LTORG 
RT1_CCH77       DS 0H
*MEXIT #=   128 LV= 1 RT1
*MCALL #=   129 LV= 1          STX   1,LD1
         LA    15,LD1
         STD   1,0(15)
         STD   1+2,8(15)
*MEXIT #=   129 LV= 1 STX
*MCALL #=   130 LV= 1          CLCLD LD1,=LD'12345677901234567790123456X
               7790123'
*MCALL #=   131 LV= 2          LX    F0,LD1
         LA    15,LD1
         LD    F0,0(15)
         LD    F0+2,8(15)
*MEXIT #=   131 LV= 2 LX
*MCALL #=   132 LV= 2          LX    F1,=LD'123456779012345677901234567X
               790123'
         LA    15,=LD'123456779012345677901234567790123'
         LD    F1,0(15)
         LD    F1+2,8(15)
*MEXIT #=   132 LV= 2 LX
         CXTR  F0,F1
*MEXIT #=   130 LV= 1 CLCLD
*MCALL #=   133 LV= 1          RT1   CCE
         DS    0H
RT1_TEST78       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE78
         LTORG 
RT1_CCE78       DS 0H
*MEXIT #=   133 LV= 1 RT1
* B3E1 CGDTRA
         LD    4,=DD'1234567890123456'
         CGDTRA 1,0,4,0
*MCALL #=   134 LV= 1          RT1   CCH
         DS    0H
RT1_TEST79       BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH79
         LTORG 
RT1_CCH79       DS 0H
*MEXIT #=   134 LV= 1 RT1
         CLG   1,=FD'1234567890123456'
*MCALL #=   135 LV= 1          RT1   CC0
         DS    0H
RT1_TEST80       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE80
         LTORG 
RT1_CCE80       DS 0H
*MEXIT #=   135 LV= 1 RT1
* B3E9 CGXTRA
*MCALL #=   136 LV= 1          LX    4,=LD'123456789012345678'
         LA    15,=LD'123456789012345678'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   136 LV= 1 LX
         CGXTRA 1,0,4,0
*MCALL #=   137 LV= 1          RT1   CCH
         DS    0H
RT1_TEST81       BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH81
         LTORG 
RT1_CCH81       DS 0H
*MEXIT #=   137 LV= 1 RT1
         CLG   1,=FD'123456789012345678'
*MCALL #=   138 LV= 1          RT1   CC0
         DS    0H
RT1_TEST82       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE82
         LTORG 
RT1_CCE82       DS 0H
*MEXIT #=   138 LV= 1 RT1
* B3F1 CDGTRA
         LG    2,=FD'1234567890123456'
         CDGTRA 1,0,2,0 CVT G TO DD
         LD    4,=DD'1234567890123456'
         CDTR  1,4
*MCALL #=   139 LV= 1          RT1   CC0
         DS    0H
RT1_TEST83       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE83
         LTORG 
RT1_CCE83       DS 0H
*MEXIT #=   139 LV= 1 RT1
* B3F9 CXGTRA
         LG    2,=FD'1234567890123456'
         CXGTRA 1,0,2,0 CVT G TO LD
*MCALL #=   140 LV= 1          LX    4,=LD'1234567890123456'
         LA    15,=LD'1234567890123456'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   140 LV= 1 LX
         CXTR  1,4
*MCALL #=   141 LV= 1          RT1   CC0
         DS    0H
RT1_TEST84       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE84
         LTORG 
RT1_CCE84       DS 0H
*MEXIT #=   141 LV= 1 RT1
* B941 CFDTR  R1,M3,R2,M4
         LD   R2,=DD'-123'
         CFDTR R1,0,R2,0
         CHI   R1,-123
*MCALL #=   142 LV= 1          RT1   CCE
         DS    0H
RT1_TEST85       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE85
         LTORG 
RT1_CCE85       DS 0H
*MEXIT #=   142 LV= 1 RT1
* B942 CLGDTR  R1,M3,R2,M4
         LD   R2,=DD'-123'
         CLGDTR R1,0,R2,0
*MCALL #=   143 LV= 1          RT1   CCL
         DS    0H
RT1_TEST86       BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL86
         LTORG 
RT1_CCL86       DS 0H
*MEXIT #=   143 LV= 1 RT1
         CG    R1,=FL8'123'
*MCALL #=   144 LV= 1          RT1   CCE
         DS    0H
RT1_TEST87       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE87
         LTORG 
RT1_CCE87       DS 0H
*MEXIT #=   144 LV= 1 RT1
* B943 CLFDTR  R1,M3,R2,M4
         LD     R2,=DD'-123'
         CLFDTR R1,0,R2,0
*MCALL #=   145 LV= 1          RT1    CCL
         DS    0H
RT1_TEST88       BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL88
         LTORG 
RT1_CCL88       DS 0H
*MEXIT #=   145 LV= 1 RT1
         C      R1,=F'123'
*MCALL #=   146 LV= 1          RT1    CCE
         DS    0H
RT1_TEST89       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE89
         LTORG 
RT1_CCE89       DS 0H
*MEXIT #=   146 LV= 1 RT1
* B949 CFXTR   R1,M3,R2,M4
*MCALL #=   147 LV= 1          LX    R1,=LD'-123'
         LA    15,=LD'-123'
         LD    R1,0(15)
         LD    R1+2,8(15)
*MEXIT #=   147 LV= 1 LX
         CFXTR R0,0,R1,0
         C     R0,=F'-123'
*MCALL #=   148 LV= 1          RT1   CCE
         DS    0H
RT1_TEST90       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE90
         LTORG 
RT1_CCE90       DS 0H
*MEXIT #=   148 LV= 1 RT1
* B94A CLGXTR   R1,M3,R2,M4
*MCALL #=   149 LV= 1          LX    R1,=LD'-123'
         LA    15,=LD'-123'
         LD    R1,0(15)
         LD    R1+2,8(15)
*MEXIT #=   149 LV= 1 LX
         CLGXTR R0,0,R1,0
*MCALL #=   150 LV= 1          RT1   CCL
         DS    0H
RT1_TEST91       BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL91
         LTORG 
RT1_CCL91       DS 0H
*MEXIT #=   150 LV= 1 RT1
         CG    R0,=FL8'123'
*MCALL #=   151 LV= 1          RT1   CCE
         DS    0H
RT1_TEST92       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE92
         LTORG 
RT1_CCE92       DS 0H
*MEXIT #=   151 LV= 1 RT1
* B94B CLFXTR   R1,M3,R2,M4
*MCALL #=   152 LV= 1          LX    R1,=LD'-123'
         LA    15,=LD'-123'
         LD    R1,0(15)
         LD    R1+2,8(15)
*MEXIT #=   152 LV= 1 LX
         CLFXTR R0,0,R1,0
*MCALL #=   153 LV= 1          RT1   CCL
         DS    0H
RT1_TEST93       BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL93
         LTORG 
RT1_CCL93       DS 0H
*MEXIT #=   153 LV= 1 RT1
         C     R0,=F'123'
*MCALL #=   154 LV= 1          RT1   CCE
         DS    0H
RT1_TEST94       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE94
         LTORG 
RT1_CCE94       DS 0H
*MEXIT #=   154 LV= 1 RT1
* B951 CDFTR   R1,M3,R2,M4
         L     R1,=F'-123'
         CDFTR R0,0,R1,0
         LD    R4,=DD'-123'
         CDTR  R0,R4
*MCALL #=   155 LV= 1          RT1   CCE
         DS    0H
RT1_TEST95       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE95
         LTORG 
RT1_CCE95       DS 0H
*MEXIT #=   155 LV= 1 RT1
* B952 CDLGTR   R1,M3,R2,M4
         LG     R1,=FL8'12345'
         CDLGTR R0,0,R1,0
         LD     R4,=DD'12345'
         CDTR   R0,R4
*MCALL #=   156 LV= 1          RT1    CCE
         DS    0H
RT1_TEST96       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE96
         LTORG 
RT1_CCE96       DS 0H
*MEXIT #=   156 LV= 1 RT1
* B953 CDLFTR   R1,M3,R2,M4
         L      R1,=F'123'
         CDLFTR R0,0,R1,0
         LD     R4,=DD'123'
         CDTR   R0,R4
*MCALL #=   157 LV= 1          RT1    CCE
         DS    0H
RT1_TEST97       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE97
         LTORG 
RT1_CCE97       DS 0H
*MEXIT #=   157 LV= 1 RT1
* B959 CXFTR   R1,M3,R2,M4
         L     R1,=F'-123'
         CXFTR R0,0,R1,0
*MCALL #=   158 LV= 1          LX    R4,=LD'-123'
         LA    15,=LD'-123'
         LD    R4,0(15)
         LD    R4+2,8(15)
*MEXIT #=   158 LV= 1 LX
         CXTR  R0,R4
*MCALL #=   159 LV= 1          RT1   CCE
         DS    0H
RT1_TEST98       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE98
         LTORG 
RT1_CCE98       DS 0H
*MEXIT #=   159 LV= 1 RT1
* B95A CXLGTR   R1,M3,R2,M4
         LG     R1,=FL8'12345'
         CXLGTR R0,0,R1,0
*MCALL #=   160 LV= 1          LX     R4,=LD'12345'
         LA    15,=LD'12345'
         LD    R4,0(15)
         LD    R4+2,8(15)
*MEXIT #=   160 LV= 1 LX
         CXTR   R0,R4
*MCALL #=   161 LV= 1          RT1    CCE
         DS    0H
RT1_TEST99       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE99
         LTORG 
RT1_CCE99       DS 0H
*MEXIT #=   161 LV= 1 RT1
* B95B CXLFTR   R1,M3,R2,M4
         L      R1,=F'123'
         CXLFTR R0,0,R1,0
*MCALL #=   162 LV= 1          LX     R4,=LD'123'
         LA    15,=LD'123'
         LD    R4,0(15)
         LD    R4+2,8(15)
*MEXIT #=   162 LV= 1 LX
         CXTR   R0,R4
*MCALL #=   163 LV= 1          RT1    CCE
         DS    0H
RT1_TEST100      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE100
         LTORG 
RT1_CCE100      DS 0H
*MEXIT #=   163 LV= 1 RT1
* B9C8 AHHHR    R1,R2,R3
         LG     R1,=X'0000000000000000'
         LG     R2,=X'0000000200000000'
         LG     R3,=X'0000000300000000'
         AHHHR  R1,R2,R3
*MCALL #=   164 LV= 1          RT1    CCH
         DS    0H
RT1_TEST101      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH101
         LTORG 
RT1_CCH101      DS 0H
*MEXIT #=   164 LV= 1 RT1
         CLG    R1,=X'0000000500000000'
*MCALL #=   165 LV= 1          RT1    CCE
         DS    0H
RT1_TEST102      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE102
         LTORG 
RT1_CCE102      DS 0H
*MEXIT #=   165 LV= 1 RT1
* B9C9 SHHHR    R1,R2,R3
         LG     R1,=X'0000000000000000'
         LG     R2,=X'0000000200000000'
         LG     R3,=X'0000000300000000'
         SHHHR  R1,R2,R3
*MCALL #=   166 LV= 1          RT1    CCL
         DS    0H
RT1_TEST103      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL103
         LTORG 
RT1_CCL103      DS 0H
*MEXIT #=   166 LV= 1 RT1
         CLG    R1,=X'FFFFFFFF00000000'
*MCALL #=   167 LV= 1          RT1    CCE
         DS    0H
RT1_TEST104      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE104
         LTORG 
RT1_CCE104      DS 0H
*MEXIT #=   167 LV= 1 RT1
* B9CA ALHHHR    R1,R2,R3
         LG     R1,=X'0000000000000000'
         LG     R2,=X'0000000200000000'
         LG     R3,=X'0000000300000000'
         ALHHHR  R1,R2,R3
*MCALL #=   168 LV= 1          RT1    CC1 NZ NC
         DS    0H
RT1_TEST105      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL105
         LTORG 
RT1_CCL105      DS 0H
*MEXIT #=   168 LV= 1 RT1
         CLG    R1,=X'0000000500000000'
*MCALL #=   169 LV= 1          RT1    CCE
         DS    0H
RT1_TEST106      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE106
         LTORG 
RT1_CCE106      DS 0H
*MEXIT #=   169 LV= 1 RT1
* B9CB SLHHHR    R1,R2,R3
         LG     R1,=X'0000000000000000'
         LG     R2,=X'0000000200000000'
         LG     R3,=X'0000000300000000'
         SHHHR  R1,R2,R3
*MCALL #=   170 LV= 1          RT1    CC1 NZ B
         DS    0H
RT1_TEST107      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL107
         LTORG 
RT1_CCL107      DS 0H
*MEXIT #=   170 LV= 1 RT1
         CLG    R1,=X'FFFFFFFF00000000'
*MCALL #=   171 LV= 1          RT1    CCE
         DS    0H
RT1_TEST108      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE108
         LTORG 
RT1_CCE108      DS 0H
*MEXIT #=   171 LV= 1 RT1
* B9CD CHHR     R1,R2
         LG     R1,=X'0000000300000000'
         LG     R2,=X'0000000300000000'
         CHHR   R1,R2
*MCALL #=   172 LV= 1          RT1    CCE
         DS    0H
RT1_TEST109      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE109
         LTORG 
RT1_CCE109      DS 0H
*MEXIT #=   172 LV= 1 RT1
* B9CF CLHHR    R1,R2
         LG     R1,=X'0000000300000000'
         LG     R2,=X'0000000300000000'
         CLHHR  R1,R2
*MCALL #=   173 LV= 1          RT1    CCE
         DS    0H
RT1_TEST110      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE110
         LTORG 
RT1_CCE110      DS 0H
*MEXIT #=   173 LV= 1 RT1
* B9D8 AHHLR    R1,R2,R3
         LG     R1,=X'0000000000000000'
         LG     R2,=X'0000000200000000'
         LG     R3,=X'0000000000000003'
         AHHLR  R1,R2,R3
*MCALL #=   174 LV= 1          RT1    CCH
         DS    0H
RT1_TEST111      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH111
         LTORG 
RT1_CCH111      DS 0H
*MEXIT #=   174 LV= 1 RT1
         CLG    R1,=X'0000000500000000'
*MCALL #=   175 LV= 1          RT1    CCE
         DS    0H
RT1_TEST112      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE112
         LTORG 
RT1_CCE112      DS 0H
*MEXIT #=   175 LV= 1 RT1
* B9D9 SHHLR    R1,R2,R3
         LG     R1,=X'0000000000000000'
         LG     R2,=X'0000000200000000'
         LG     R3,=X'0000000000000003'
         SHHLR  R1,R2,R3
*MCALL #=   176 LV= 1          RT1    CCL
         DS    0H
RT1_TEST113      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL113
         LTORG 
RT1_CCL113      DS 0H
*MEXIT #=   176 LV= 1 RT1
         CLG    R1,=X'FFFFFFFF00000000'
*MCALL #=   177 LV= 1          RT1    CCE
         DS    0H
RT1_TEST114      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE114
         LTORG 
RT1_CCE114      DS 0H
*MEXIT #=   177 LV= 1 RT1
* B9DA ALHHLR    R1,R2,R3
         LG     R1,=X'0000000000000000'
         LG     R2,=X'0000000200000000'
         LG     R3,=X'0000000000000003'
         ALHHLR  R1,R2,R3
*MCALL #=   178 LV= 1          RT1    CC1 NZ NC
         DS    0H
RT1_TEST115      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL115
         LTORG 
RT1_CCL115      DS 0H
*MEXIT #=   178 LV= 1 RT1
         CLG    R1,=X'0000000500000000'
*MCALL #=   179 LV= 1          RT1    CCE
         DS    0H
RT1_TEST116      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE116
         LTORG 
RT1_CCE116      DS 0H
*MEXIT #=   179 LV= 1 RT1
* B9DB SLHHLR    R1,R2,R3
         LG     R1,=X'0000000000000000'
         LG     R2,=X'0000000200000000'
         LG     R3,=X'0000000000000003'
         SHHLR  R1,R2,R3
*MCALL #=   180 LV= 1          RT1    CC1 NZ B
         DS    0H
RT1_TEST117      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL117
         LTORG 
RT1_CCL117      DS 0H
*MEXIT #=   180 LV= 1 RT1
         CLG    R1,=X'FFFFFFFF00000000'
*MCALL #=   181 LV= 1          RT1    CCE
         DS    0H
RT1_TEST118      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE118
         LTORG 
RT1_CCE118      DS 0H
*MEXIT #=   181 LV= 1 RT1
* B9DD CHLR     R1,R2
         LG     R1,=X'0000000300000000'
         LG     R2,=X'0000000000000003'
         CHLR   R1,R2
*MCALL #=   182 LV= 1          RT1    CCE
         DS    0H
RT1_TEST119      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE119
         LTORG 
RT1_CCE119      DS 0H
*MEXIT #=   182 LV= 1 RT1
* B9DF CLHLR    R1,R2
         LG     R1,=X'0000000300000000'
         LG     R2,=X'0000000000000003'
         CLHLR  R1,R2
*MCALL #=   183 LV= 1          RT1    CCE
         DS    0H
RT1_TEST120      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE120
         LTORG 
RT1_CCE120      DS 0H
*MEXIT #=   183 LV= 1 RT1
* B9E1 POPCNT R1,R2 SET 8 BYTE BIT COUNTS FROM R2 IN R1
         LG    R2,=XL8'0000000000000100'
         LG    R3,=XL8'0101010101010101'
POPCNT_LOOP EQU *
         LRL   R11,=A(POPCNT_LOOP)  RESET BASE SET BY RT1
         USING POPCNT_LOOP,R11
         LGR   R5,R2
         BCTR  R5,0           R5 = 0-255 IN LOW BYTE
         LGR   R1,R5
         MSGR  R1,R3          R1 = 0-255 IN ALL 8 BYTES
         POPCNT R0,R1         R0 = TOTAL BITS FOR EACH BYTE
         MSGR  R0,R3          R0 = TOTAL BITS FOR ALL 8 IN HIGH BYTE
         SRLG  R1,R0,56+3     R1 = TOTAL BITS / 8 IN LOW BYTE
         LR    R6,R5
         SRL   R6,4
         SR    R4,R4
         IC    R4,NIBCNT(R6)
         N     R5,=X'0000000F'
         IC    R5,NIBCNT(R5)
         AR    R4,R5
         CLR   R1,R4
*MCALL #=   184 LV= 1          RT1   CCE            COMPARE CALC WITH TX
               ABLE
         DS    0H
RT1_TEST121      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE121
         LTORG 
RT1_CCE121      DS 0H
*MEXIT #=   184 LV= 1 RT1
         BRCT  R2,POPCNT_LOOP
         LG    R2,=FL8'0'
         POPCNT R1,R2
*MCALL #=   185 LV= 1          RT1   CCE
         DS    0H
RT1_TEST122      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE122
         LTORG 
RT1_CCE122      DS 0H
*MEXIT #=   185 LV= 1 RT1
         LG    R2,=FL8'-1'
         POPCNT R1,R2
*MCALL #=   186 LV= 1          RT1   CCH
         DS    0H
RT1_TEST123      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH123
         LTORG 
RT1_CCH123      DS 0H
*MEXIT #=   186 LV= 1 RT1
* B9E2 LOGCR R1,R2,M3
         LG     R1,=FL8'-1'
         SGR    R0,R0
         LOCGR  R0,R1,8
         CGR    R0,R1
*MCALL #=   187 LV= 1          RT1    CCE
         DS    0H
RT1_TEST124      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE124
         LTORG 
RT1_CCE124      DS 0H
*MEXIT #=   187 LV= 1 RT1
         LG     R1,=FL8'-1'
         SGR    R0,R0
         LOCGR  R0,R1,4
         CG     R0,=FL8'0'
*MCALL #=   188 LV= 1          RT1    CCE
         DS    0H
RT1_TEST125      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE125
         LTORG 
RT1_CCE125      DS 0H
*MEXIT #=   188 LV= 1 RT1
* B9E4 NGRK R1,R2,R3
         LG     R1,=X'0000000000000000'
         LG     R2,=X'FF000000000000FF'
         LG     R3,=X'03FF00000000FF03'
         NGRK   R1,R2,R3
*MCALL #=   189 LV= 1          RT1    CC1
         DS    0H
RT1_TEST126      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL126
         LTORG 
RT1_CCL126      DS 0H
*MEXIT #=   189 LV= 1 RT1
         CLG    R1,=X'0300000000000003'
*MCALL #=   190 LV= 1          RT1    CCE
         DS    0H
RT1_TEST127      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE127
         LTORG 
RT1_CCE127      DS 0H
*MEXIT #=   190 LV= 1 RT1
* B9E6 OGRK R1,R2,R3
         LG     R1,=X'0000000000000000'
         LG     R2,=X'FF000000000000FF'
         LG     R3,=X'03FF00000000FF03'
         OGRK   R1,R2,R3
*MCALL #=   191 LV= 1          RT1    CC1
         DS    0H
RT1_TEST128      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL128
         LTORG 
RT1_CCL128      DS 0H
*MEXIT #=   191 LV= 1 RT1
         CLG    R1,=X'FFFF00000000FFFF'
*MCALL #=   192 LV= 1          RT1    CCE
         DS    0H
RT1_TEST129      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE129
         LTORG 
RT1_CCE129      DS 0H
*MEXIT #=   192 LV= 1 RT1
* B9E7 XGRK R1,R2,R3
         LG     R1,=X'0000000000000000'
         LG     R2,=X'FF000000000000FF'
         LG     R3,=X'03FF00000000FF03'
         XGRK   R1,R2,R3
*MCALL #=   193 LV= 1          RT1    CC1
         DS    0H
RT1_TEST130      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL130
         LTORG 
RT1_CCL130      DS 0H
*MEXIT #=   193 LV= 1 RT1
         CLG    R1,=X'FCFF00000000FFFC'
*MCALL #=   194 LV= 1          RT1    CCE
         DS    0H
RT1_TEST131      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE131
         LTORG 
RT1_CCE131      DS 0H
*MEXIT #=   194 LV= 1 RT1
* B9E8 AGRK     R1,R2,R3
         LG     R1,=X'0000000000000000'
         LG     R2,=X'0000000000000002'
         LG     R3,=X'0000000000000003'
         AGRK   R1,R2,R3
*MCALL #=   195 LV= 1          RT1    CCH
         DS    0H
RT1_TEST132      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH132
         LTORG 
RT1_CCH132      DS 0H
*MEXIT #=   195 LV= 1 RT1
         CLG    R1,=X'0000000000000005'
*MCALL #=   196 LV= 1          RT1    CCE
         DS    0H
RT1_TEST133      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE133
         LTORG 
RT1_CCE133      DS 0H
*MEXIT #=   196 LV= 1 RT1
* B9E9 SGRK     R1,R2,R3
         LG     R1,=X'0000000000000000'
         LG     R2,=X'0000000000000002'
         LG     R3,=X'0000000000000003'
         SGRK   R1,R2,R3
*MCALL #=   197 LV= 1          RT1    CCL
         DS    0H
RT1_TEST134      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL134
         LTORG 
RT1_CCL134      DS 0H
*MEXIT #=   197 LV= 1 RT1
         CLG    R1,=X'FFFFFFFFFFFFFFFF'
*MCALL #=   198 LV= 1          RT1    CCE
         DS    0H
RT1_TEST135      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE135
         LTORG 
RT1_CCE135      DS 0H
*MEXIT #=   198 LV= 1 RT1
* B9EA ALGRK     R1,R2,R3
         LG     R1,=X'0000000000000000'
         LG     R2,=X'0000000000000002'
         LG     R3,=X'0000000000000003'
         ALGRK   R1,R2,R3
*MCALL #=   199 LV= 1          RT1    CC1 NZ NC
         DS    0H
RT1_TEST136      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL136
         LTORG 
RT1_CCL136      DS 0H
*MEXIT #=   199 LV= 1 RT1
         CLG    R1,=X'0000000000000005'
*MCALL #=   200 LV= 1          RT1    CCE
         DS    0H
RT1_TEST137      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE137
         LTORG 
RT1_CCE137      DS 0H
*MEXIT #=   200 LV= 1 RT1
* B9EB SLGRK     R1,R2,R3
         LG     R1,=X'0000000000000000'
         LG     R2,=X'0000000000000002'
         LG     R3,=X'0000000000000003'
         SLGRK  R1,R2,R3
*MCALL #=   201 LV= 1          RT1    CC1 NZ B
         DS    0H
RT1_TEST138      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL138
         LTORG 
RT1_CCL138      DS 0H
*MEXIT #=   201 LV= 1 RT1
         CLG    R1,=X'FFFFFFFFFFFFFFFF'
*MCALL #=   202 LV= 1          RT1    CCE
         DS    0H
RT1_TEST139      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE139
         LTORG 
RT1_CCE139      DS 0H
*MEXIT #=   202 LV= 1 RT1
* B9F2 LOGR R1,R2,M3
         L      R1,=F'-1'
         SR     R0,R0
         LOCR   R0,R1,8
         CR     R0,R1
*MCALL #=   203 LV= 1          RT1    CCE
         DS    0H
RT1_TEST140      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE140
         LTORG 
RT1_CCE140      DS 0H
*MEXIT #=   203 LV= 1 RT1
         L      R1,=FL8'-1'
         SR     R0,R0
         LOCR   R0,R1,4
         C      R0,=F'0'
*MCALL #=   204 LV= 1          RT1    CCE
         DS    0H
RT1_TEST141      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE141
         LTORG 
RT1_CCE141      DS 0H
*MEXIT #=   204 LV= 1 RT1
* B9F4 NRK R1,R2,R3
         L      R1,=X'00000000'
         L      R2,=X'FF0000FF'
         L      R3,=X'03FFFF03'
         NRK   R1,R2,R3
*MCALL #=   205 LV= 1          RT1    CC1
         DS    0H
RT1_TEST142      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL142
         LTORG 
RT1_CCL142      DS 0H
*MEXIT #=   205 LV= 1 RT1
         CL     R1,=X'03000003'
*MCALL #=   206 LV= 1          RT1    CCE
         DS    0H
RT1_TEST143      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE143
         LTORG 
RT1_CCE143      DS 0H
*MEXIT #=   206 LV= 1 RT1
* B9F6 ORK R1,R2,R3
         L      R1,=X'00000000'
         L      R2,=X'FF0000FF'
         L      R3,=X'03FFFF03'
         ORK   R1,R2,R3
*MCALL #=   207 LV= 1          RT1    CC1
         DS    0H
RT1_TEST144      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL144
         LTORG 
RT1_CCL144      DS 0H
*MEXIT #=   207 LV= 1 RT1
         CL    R1,=X'FFFFFFFF'
*MCALL #=   208 LV= 1          RT1    CCE
         DS    0H
RT1_TEST145      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE145
         LTORG 
RT1_CCE145      DS 0H
*MEXIT #=   208 LV= 1 RT1
* B9F7 XRK R1,R2,R3
         L      R1,=X'00000000'
         L      R2,=X'FF0000FF'
         L      R3,=X'03FFFF03'
         XRK   R1,R2,R3
*MCALL #=   209 LV= 1          RT1    CC1
         DS    0H
RT1_TEST146      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL146
         LTORG 
RT1_CCL146      DS 0H
*MEXIT #=   209 LV= 1 RT1
         CL     R1,=X'FCFFFFFC'
*MCALL #=   210 LV= 1          RT1    CCE
         DS    0H
RT1_TEST147      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE147
         LTORG 
RT1_CCE147      DS 0H
*MEXIT #=   210 LV= 1 RT1
* B9F8 ARK     R1,R2,R3
         L      R1,=X'00000000'
         L      R2,=X'00000002'
         L      R3,=X'00000003'
         ARK    R1,R2,R3
*MCALL #=   211 LV= 1          RT1    CCH
         DS    0H
RT1_TEST148      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH148
         LTORG 
RT1_CCH148      DS 0H
*MEXIT #=   211 LV= 1 RT1
         CL     R1,=X'00000005'
*MCALL #=   212 LV= 1          RT1    CCE
         DS    0H
RT1_TEST149      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE149
         LTORG 
RT1_CCE149      DS 0H
*MEXIT #=   212 LV= 1 RT1
* B9F9 SRK      R1,R2,R3
         L      R1,=X'00000000'
         L      R2,=X'00000002'
         L      R3,=X'00000003'
         SRK    R1,R2,R3
*MCALL #=   213 LV= 1          RT1    CCL
         DS    0H
RT1_TEST150      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL150
         LTORG 
RT1_CCL150      DS 0H
*MEXIT #=   213 LV= 1 RT1
         CL     R1,=X'FFFFFFFF'
*MCALL #=   214 LV= 1          RT1    CCE
         DS    0H
RT1_TEST151      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE151
         LTORG 
RT1_CCE151      DS 0H
*MEXIT #=   214 LV= 1 RT1
* B9FA ALRK     R1,R2,R3
         L      R1,=X'00000000'
         L      R2,=X'00000002'
         L      R3,=X'00000003'
         ALRK   R1,R2,R3
*MCALL #=   215 LV= 1          RT1    CC1 NZ NC
         DS    0H
RT1_TEST152      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL152
         LTORG 
RT1_CCL152      DS 0H
*MEXIT #=   215 LV= 1 RT1
         CL     R1,=X'00000005'
*MCALL #=   216 LV= 1          RT1    CCE
         DS    0H
RT1_TEST153      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE153
         LTORG 
RT1_CCE153      DS 0H
*MEXIT #=   216 LV= 1 RT1
* B9FB SLRK     R1,R2,R3
         L      R1,=X'00000000'
         L      R2,=X'00000002'
         L      R3,=X'00000003'
         SLRK   R1,R2,R3
*MCALL #=   217 LV= 1          RT1    CC1 NZ B
         DS    0H
RT1_TEST154      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL154
         LTORG 
RT1_CCL154      DS 0H
*MEXIT #=   217 LV= 1 RT1
         CL     R1,=X'FFFFFFFF'
*MCALL #=   218 LV= 1          RT1    CCE
         DS    0H
RT1_TEST155      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE155
         LTORG 
RT1_CCE155      DS 0H
*MEXIT #=   218 LV= 1 RT1
* C84 LPD       R3,S1,S2
         LPD    R0,=F'123',=F'456'
         CL     R0,=F'123'
*MCALL #=   219 LV= 1          RT1    CCE
         DS    0H
RT1_TEST156      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE156
         LTORG 
RT1_CCE156      DS 0H
*MEXIT #=   219 LV= 1 RT1
         CL     R1,=F'456'
*MCALL #=   220 LV= 1          RT1    CCE
         DS    0H
RT1_TEST157      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE157
         LTORG 
RT1_CCE157      DS 0H
*MEXIT #=   220 LV= 1 RT1
* C85 LPDG      R3,S1,S2
         LPDG   R0,=FL8'-123',=FL8'-456'
         CLG    R0,=FL8'-123'
*MCALL #=   221 LV= 1          RT1    CCE
         DS    0H
RT1_TEST158      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE158
         LTORG 
RT1_CCE158      DS 0H
*MEXIT #=   221 LV= 1 RT1
         CLG    R1,=FL8'-456'
*MCALL #=   222 LV= 1          RT1    CCE
         DS    0H
RT1_TEST159      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE159
         LTORG 
RT1_CCE159      DS 0H
*MEXIT #=   222 LV= 1 RT1
* CC6 BRCTH
         LA     R1,2
         BRCTH  R1,CC6_ABORT
         BRCTH  R1,CC6_SKIP
CC6_ABORT EQU   *
         DC     X'0000'
CC6_SKIP EQU    *
* CC8 AIH
         SGR   R1,R1
         AIH   R1,123
*MCALL #=   223 LV= 1          RT1   CCH
         DS    0H
RT1_TEST160      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH160
         LTORG 
RT1_CCH160      DS 0H
*MEXIT #=   223 LV= 1 RT1
         CLG   R1,=F'1,0'
* CCA ALSIH
         SGR   R1,R1
         ALSIH R1,123
*MCALL #=   224 LV= 1          RT1   CC1
         DS    0H
RT1_TEST161      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL161
         LTORG 
RT1_CCL161      DS 0H
*MEXIT #=   224 LV= 1 RT1
         CLG   R1,=F'123,0'
*MCALL #=   225 LV= 1          RT1   CCE
         DS    0H
RT1_TEST162      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE162
         LTORG 
RT1_CCE162      DS 0H
*MEXIT #=   225 LV= 1 RT1
         SGR   R1,R1
         ALSIH R1,123
         ALSIH R1,-1
*MCALL #=   226 LV= 1          RT1   CC1
         DS    0H
RT1_TEST163      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL163
         LTORG 
RT1_CCL163      DS 0H
*MEXIT #=   226 LV= 1 RT1
         CLG   R1,=F'122,0'
*MCALL #=   227 LV= 1          RT1   CCE
         DS    0H
RT1_TEST164      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE164
         LTORG 
RT1_CCE164      DS 0H
*MEXIT #=   227 LV= 1 RT1
         LG    R1,=X'8000000000000000'
         ALSIH R1,-1
*MCALL #=   228 LV= 1          RT1   CC1     NZ,NB
         DS    0H
RT1_TEST165      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL165
         LTORG 
RT1_CCL165      DS 0H
*MEXIT #=   228 LV= 1 RT1
         CLG   R1,=X'7FFFFFFF00000000'
*MCALL #=   229 LV= 1          RT1   CCE
         DS    0H
RT1_TEST166      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE166
         LTORG 
RT1_CCE166      DS 0H
*MEXIT #=   229 LV= 1 RT1
         LG    R1,=X'8000000000000000'
         ALSIH R1,-1
*MCALL #=   230 LV= 1          RT1   CC1     NZ,NB
         DS    0H
RT1_TEST167      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL167
         LTORG 
RT1_CCL167      DS 0H
*MEXIT #=   230 LV= 1 RT1
         CLG   R1,=X'7FFFFFFF00000000'
         LG    R1,=X'0000000000000000'
         ALSIH R1,-1
*MCALL #=   231 LV= 1          RT1   CC3     NZ,B
         DS    0H
RT1_TEST168      BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC3168
         LTORG 
RT1_CC3168      DS 0H
*MEXIT #=   231 LV= 1 RT1
         CLG   R1,=X'FFFFFFFF00000000'
*MCALL #=   232 LV= 1          RT1   CCE
         DS    0H
RT1_TEST169      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE169
         LTORG 
RT1_CCE169      DS 0H
*MEXIT #=   232 LV= 1 RT1
* CCB ALSIHN
         SGR   R1,R1
         ALSIHN R1,123
*MCALL #=   233 LV= 1          RT1   CC0
         DS    0H
RT1_TEST170      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE170
         LTORG 
RT1_CCE170      DS 0H
*MEXIT #=   233 LV= 1 RT1
         CLG   R1,=F'123,0'
*MCALL #=   234 LV= 1          RT1   CCE
         DS    0H
RT1_TEST171      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE171
         LTORG 
RT1_CCE171      DS 0H
*MEXIT #=   234 LV= 1 RT1
         LG    R1,=X'0000000000000000'
         SGR   R0,R0   SET CC0
         ALSIHN R1,-1
*MCALL #=   235 LV= 1          RT1   CC0     NO CC CHANGE
         DS    0H
RT1_TEST172      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE172
         LTORG 
RT1_CCE172      DS 0H
*MEXIT #=   235 LV= 1 RT1
         CLG   R1,=X'FFFFFFFF00000000'
*MCALL #=   236 LV= 1          RT1   CCE
         DS    0H
RT1_TEST173      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE173
         LTORG 
RT1_CCE173      DS 0H
*MEXIT #=   236 LV= 1 RT1
* CCD CIH
         LG    R1,=F'123,0'
         CIH   R1,123
*MCALL #=   237 LV= 1          RT1   CCE
         DS    0H
RT1_TEST174      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE174
         LTORG 
RT1_CCE174      DS 0H
*MEXIT #=   237 LV= 1 RT1
* CCF CLIH
         LG    R1,=F'123,0'
         CLIH  R1,123
*MCALL #=   238 LV= 1          RT1   CCE
         DS    0H
RT1_TEST175      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE175
         LTORG 
RT1_CCE175      DS 0H
*MEXIT #=   238 LV= 1 RT1
* E3C0 LBH
         SGR   R1,R1
         LBH   R1,=X'84'
         CLG   R1,=X'FFFFFF8400000000'
*MCALL #=   239 LV= 1          RT1   CCE
         DS    0H
RT1_TEST176      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE176
         LTORG 
RT1_CCE176      DS 0H
*MEXIT #=   239 LV= 1 RT1
* E3C2 LLCH
         LG    R1,=FL8'-1'
         LLCH  R1,=X'84'
         CLG   R1,=X'00000084FFFFFFFF'
*MCALL #=   240 LV= 1          RT1   CCE
         DS    0H
RT1_TEST177      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE177
         LTORG 
RT1_CCE177      DS 0H
*MEXIT #=   240 LV= 1 RT1
* E3C3 STCH
         MVI   BYTE,0
         STCH  R1,BYTE
         CLI   BYTE,X'84'
*MCALL #=   241 LV= 1          RT1   CCE
         DS    0H
RT1_TEST178      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE178
         LTORG 
RT1_CCE178      DS 0H
*MEXIT #=   241 LV= 1 RT1
* E3C4 LHH
         SGR   R1,R1
         LHH   R1,=X'8421'
         CLG   R1,=X'FFFF842100000000'
*MCALL #=   242 LV= 1          RT1   CCE
         DS    0H
RT1_TEST179      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE179
         LTORG 
RT1_CCE179      DS 0H
*MEXIT #=   242 LV= 1 RT1
* E3C6 LLHH
         SGR   R1,R1
         LLHH  R1,=X'8421'
         CLG   R1,=X'0000842100000000'
*MCALL #=   243 LV= 1          RT1   CCE
         DS    0H
RT1_TEST180      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE180
         LTORG 
RT1_CCE180      DS 0H
*MEXIT #=   243 LV= 1 RT1
* E3C7 STHH
         MVHI  WORD,0
         STHH  R1,WORD
         CLC   WORD(2),=X'8421'
*MCALL #=   244 LV= 1          RT1   CCE
         DS    0H
RT1_TEST181      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE181
         LTORG 
RT1_CCE181      DS 0H
*MEXIT #=   244 LV= 1 RT1
* E3CA LFH
         SGR   R1,R1
         LFH   R1,=F'-1'
         CLG   R1,=X'FFFFFFFF00000000'
*MCALL #=   245 LV= 1          RT1   CCE
         DS    0H
RT1_TEST182      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE182
         LTORG 
RT1_CCE182      DS 0H
*MEXIT #=   245 LV= 1 RT1
* E3CB STFH
         MVC   WORD,=F'0'
         STFH  R1,WORD
         CLC   WORD(4),=F'-1'
*MCALL #=   246 LV= 1          RT1   CCE
         DS    0H
RT1_TEST183      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE183
         LTORG 
RT1_CCE183      DS 0H
*MEXIT #=   246 LV= 1 RT1
* E3CD CHF
         LG    R1,=X'1234567800000000'
         CHF   R1,=X'12345678'
*MCALL #=   247 LV= 1          RT1   CCE
         DS    0H
RT1_TEST184      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE184
         LTORG 
RT1_CCE184      DS 0H
*MEXIT #=   247 LV= 1 RT1
         CHF   R1,=X'12345679'
*MCALL #=   248 LV= 1          RT1   CCL
         DS    0H
RT1_TEST185      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL185
         LTORG 
RT1_CCL185      DS 0H
*MEXIT #=   248 LV= 1 RT1
         CHF   R1,=X'12345677'
*MCALL #=   249 LV= 1          RT1   CCH
         DS    0H
RT1_TEST186      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH186
         LTORG 
RT1_CCH186      DS 0H
*MEXIT #=   249 LV= 1 RT1
* E3CF CLHF
         LG    R1,=X'1234567800000000'
         CLHF  R1,=X'12345678'
*MCALL #=   250 LV= 1          RT1   CCE
         DS    0H
RT1_TEST187      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE187
         LTORG 
RT1_CCE187      DS 0H
*MEXIT #=   250 LV= 1 RT1
         CLHF  R1,=X'12345679'
*MCALL #=   251 LV= 1          RT1   CCL
         DS    0H
RT1_TEST188      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL188
         LTORG 
RT1_CCL188      DS 0H
*MEXIT #=   251 LV= 1 RT1
         CLHF  R1,=X'12345677'
*MCALL #=   252 LV= 1          RT1   CCH
         DS    0H
RT1_TEST189      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH189
         LTORG 
RT1_CCH189      DS 0H
*MEXIT #=   252 LV= 1 RT1
* EBDC SRAK
         L     R1,=F'-8'
         SRAK  R0,R1,2
*MCALL #=   253 LV= 1          RT1   CCL
         DS    0H
RT1_TEST190      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL190
         LTORG 
RT1_CCL190      DS 0H
*MEXIT #=   253 LV= 1 RT1
         C     R0,=F'-2'
*MCALL #=   254 LV= 1          RT1   CCE
         DS    0H
RT1_TEST191      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE191
         LTORG 
RT1_CCE191      DS 0H
*MEXIT #=   254 LV= 1 RT1
* EBDD SLAK
         L     R1,=F'-8'
         SLAK  R0,R1,2
*MCALL #=   255 LV= 1          RT1   CCL
         DS    0H
RT1_TEST192      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL192
         LTORG 
RT1_CCL192      DS 0H
*MEXIT #=   255 LV= 1 RT1
         C     R0,=F'-32'
*MCALL #=   256 LV= 1          RT1   CCE
         DS    0H
RT1_TEST193      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE193
         LTORG 
RT1_CCE193      DS 0H
*MEXIT #=   256 LV= 1 RT1
* EBDE SRLK
         SR    R0,R0
         L     R1,=F'-1'
         SRLK  R0,R1,31
*MCALL #=   257 LV= 1          RT1   CCE
         DS    0H
RT1_TEST194      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE194
         LTORG 
RT1_CCE194      DS 0H
*MEXIT #=   257 LV= 1 RT1
         C     R0,=F'1'
*MCALL #=   258 LV= 1          RT1   CCE
         DS    0H
RT1_TEST195      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE195
         LTORG 
RT1_CCE195      DS 0H
*MEXIT #=   258 LV= 1 RT1
* EBDF SLLK
         SR    R0,R0
         L     R1,=X'80000001'
         SLLK  R0,R1,2
*MCALL #=   259 LV= 1          RT1   CCE
         DS    0H
RT1_TEST196      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE196
         LTORG 
RT1_CCE196      DS 0H
*MEXIT #=   259 LV= 1 RT1
         C     R0,=F'4'
*MCALL #=   260 LV= 1          RT1   CCE
         DS    0H
RT1_TEST197      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE197
         LTORG 
RT1_CCE197      DS 0H
*MEXIT #=   260 LV= 1 RT1
* EBE2 LOCG
         SGR   R0,R0
         LOCG  R0,=X'0123456789ABCDEF',7
         CG    R0,=X'0000000000000000'
*MCALL #=   261 LV= 1          RT1   CCE
         DS    0H
RT1_TEST198      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE198
         LTORG 
RT1_CCE198      DS 0H
*MEXIT #=   261 LV= 1 RT1
         SGR   R0,R0
         LOCG  R0,=X'0123456789ABCDEF',8
         CG    R0,=X'0123456789ABCDEF'
*MCALL #=   262 LV= 1          RT1   CCE
         DS    0H
RT1_TEST199      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE199
         LTORG 
RT1_CCE199      DS 0H
*MEXIT #=   262 LV= 1 RT1
* EBE3 STOCG
         SGR  R0,R0
         MVC  DWORD,=FL8'-1'
         STOCG R0,DWORD,7
         CLC  DWORD,=FL8'-1'
*MCALL #=   263 LV= 1          RT1  CCE
         DS    0H
RT1_TEST200      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE200
         LTORG 
RT1_CCE200      DS 0H
*MEXIT #=   263 LV= 1 RT1
         SGR  R0,R0
         MVC  DWORD,=FL8'-1'
         STOCG R0,DWORD,8
         CLC  DWORD,=FL8'0'
*MCALL #=   264 LV= 1          RT1  CCE
         DS    0H
RT1_TEST201      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE201
         LTORG 
RT1_CCE201      DS 0H
*MEXIT #=   264 LV= 1 RT1
* EBE4 LANG
         MVC  DWORD,=FL8'3'
         SGR  R0,R0
         LG   R1,=FL8'5'
         LANG R0,R1,DWORD
*MCALL #=   265 LV= 1          RT1  CC1
         DS    0H
RT1_TEST202      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL202
         LTORG 
RT1_CCL202      DS 0H
*MEXIT #=   265 LV= 1 RT1
         CLC  DWORD,=FL8'1'
*MCALL #=   266 LV= 1          RT1  CCE
         DS    0H
RT1_TEST203      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE203
         LTORG 
RT1_CCE203      DS 0H
*MEXIT #=   266 LV= 1 RT1
         CG   R0,=FL8'3'
*MCALL #=   267 LV= 1          RT1  CCE
         DS    0H
RT1_TEST204      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE204
         LTORG 
RT1_CCE204      DS 0H
*MEXIT #=   267 LV= 1 RT1
* EBE6 LAOG
         MVC  DWORD,=FL8'3'
         SGR  R0,R0
         LG   R1,=FL8'5'
         LAOG R0,R1,DWORD
*MCALL #=   268 LV= 1          RT1  CC1
         DS    0H
RT1_TEST205      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL205
         LTORG 
RT1_CCL205      DS 0H
*MEXIT #=   268 LV= 1 RT1
         CLC  DWORD,=FL8'7'
*MCALL #=   269 LV= 1          RT1  CCE
         DS    0H
RT1_TEST206      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE206
         LTORG 
RT1_CCE206      DS 0H
*MEXIT #=   269 LV= 1 RT1
         CG   R0,=FL8'3'
*MCALL #=   270 LV= 1          RT1  CCE
         DS    0H
RT1_TEST207      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE207
         LTORG 
RT1_CCE207      DS 0H
*MEXIT #=   270 LV= 1 RT1
* EBE7 LAXG
         MVC  DWORD,=FL8'3'
         SGR  R0,R0
         LG   R1,=FL8'5'
         LAXG R0,R1,DWORD
*MCALL #=   271 LV= 1          RT1  CC1
         DS    0H
RT1_TEST208      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL208
         LTORG 
RT1_CCL208      DS 0H
*MEXIT #=   271 LV= 1 RT1
         CLC  DWORD,=FL8'6'
*MCALL #=   272 LV= 1          RT1  CCE
         DS    0H
RT1_TEST209      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE209
         LTORG 
RT1_CCE209      DS 0H
*MEXIT #=   272 LV= 1 RT1
         CG   R0,=FL8'3'
*MCALL #=   273 LV= 1          RT1  CCE
         DS    0H
RT1_TEST210      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE210
         LTORG 
RT1_CCE210      DS 0H
*MEXIT #=   273 LV= 1 RT1
* EBE8 LAAG
         MVC  DWORD,=FL8'3'
         SGR  R0,R0
         LG   R1,=FL8'5'
         LAAG R0,R1,DWORD
*MCALL #=   274 LV= 1          RT1  CCH
         DS    0H
RT1_TEST211      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH211
         LTORG 
RT1_CCH211      DS 0H
*MEXIT #=   274 LV= 1 RT1
         CLC  DWORD,=FL8'8'
*MCALL #=   275 LV= 1          RT1  CCE
         DS    0H
RT1_TEST212      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE212
         LTORG 
RT1_CCE212      DS 0H
*MEXIT #=   275 LV= 1 RT1
         CG   R0,=FL8'3'
*MCALL #=   276 LV= 1          RT1  CCE
         DS    0H
RT1_TEST213      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE213
         LTORG 
RT1_CCE213      DS 0H
*MEXIT #=   276 LV= 1 RT1
* EBEA LAALG
         MVC  DWORD,=FL8'3'
         SGR  R0,R0
         LG   R1,=FL8'5'
         LAALG R0,R1,DWORD
*MCALL #=   277 LV= 1          RT1  CC1   NZ,NC
         DS    0H
RT1_TEST214      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL214
         LTORG 
RT1_CCL214      DS 0H
*MEXIT #=   277 LV= 1 RT1
         CLC  DWORD,=FL8'8'
*MCALL #=   278 LV= 1          RT1  CCE
         DS    0H
RT1_TEST215      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE215
         LTORG 
RT1_CCE215      DS 0H
*MEXIT #=   278 LV= 1 RT1
         CG   R0,=FL8'3'
*MCALL #=   279 LV= 1          RT1  CCE
         DS    0H
RT1_TEST216      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE216
         LTORG 
RT1_CCE216      DS 0H
*MEXIT #=   279 LV= 1 RT1
* EBF2 LOC
         SR   R0,R0
         LOC  R0,=X'01234567',7
         C    R0,=X'00000000'
*MCALL #=   280 LV= 1          RT1  CCE
         DS    0H
RT1_TEST217      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE217
         LTORG 
RT1_CCE217      DS 0H
*MEXIT #=   280 LV= 1 RT1
         SR   R0,R0
         LOC  R0,=X'01234567',8
         C    R0,=X'01234567'
*MCALL #=   281 LV= 1          RT1  CCE
         DS    0H
RT1_TEST218      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE218
         LTORG 
RT1_CCE218      DS 0H
*MEXIT #=   281 LV= 1 RT1
* EBF3 STOC
         SR   R0,R0
         MVC  WORD,=F'-1'
         STOC R0,WORD,7
         CLC  WORD,=F'-1'
*MCALL #=   282 LV= 1          RT1  CCE
         DS    0H
RT1_TEST219      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE219
         LTORG 
RT1_CCE219      DS 0H
*MEXIT #=   282 LV= 1 RT1
         SR   R0,R0
         MVC  WORD,=F'-1'
         STOC R0,WORD,8
         CLC  WORD,=F'0'
*MCALL #=   283 LV= 1          RT1  CCE
         DS    0H
RT1_TEST220      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE220
         LTORG 
RT1_CCE220      DS 0H
*MEXIT #=   283 LV= 1 RT1
* EBF4 LAN
         MVC  WORD,=F'3'
         SR   R0,R0
         L    R1,=F'5'
         LAN  R0,R1,WORD
*MCALL #=   284 LV= 1          RT1  CC1
         DS    0H
RT1_TEST221      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL221
         LTORG 
RT1_CCL221      DS 0H
*MEXIT #=   284 LV= 1 RT1
         CLC  WORD,=F'1'
*MCALL #=   285 LV= 1          RT1  CCE
         DS    0H
RT1_TEST222      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE222
         LTORG 
RT1_CCE222      DS 0H
*MEXIT #=   285 LV= 1 RT1
         C    R0,=F'3'
*MCALL #=   286 LV= 1          RT1  CCE
         DS    0H
RT1_TEST223      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE223
         LTORG 
RT1_CCE223      DS 0H
*MEXIT #=   286 LV= 1 RT1
* EBF6 LAO
         MVC  WORD,=F'3'
         SR   R0,R0
         L    R1,=F'5'
         LAO  R0,R1,WORD
*MCALL #=   287 LV= 1          RT1  CC1
         DS    0H
RT1_TEST224      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL224
         LTORG 
RT1_CCL224      DS 0H
*MEXIT #=   287 LV= 1 RT1
         CLC  WORD,=F'7'
*MCALL #=   288 LV= 1          RT1  CCE
         DS    0H
RT1_TEST225      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE225
         LTORG 
RT1_CCE225      DS 0H
*MEXIT #=   288 LV= 1 RT1
         C    R0,=F'3'
*MCALL #=   289 LV= 1          RT1  CCE
         DS    0H
RT1_TEST226      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE226
         LTORG 
RT1_CCE226      DS 0H
*MEXIT #=   289 LV= 1 RT1
* EBF7 LAX
         MVC  WORD,=F'3'
         SR   R0,R0
         L    R1,=F'5'
         LAX  R0,R1,WORD
*MCALL #=   290 LV= 1          RT1  CC1
         DS    0H
RT1_TEST227      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL227
         LTORG 
RT1_CCL227      DS 0H
*MEXIT #=   290 LV= 1 RT1
         CLC  WORD,=F'6'
*MCALL #=   291 LV= 1          RT1  CCE
         DS    0H
RT1_TEST228      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE228
         LTORG 
RT1_CCE228      DS 0H
*MEXIT #=   291 LV= 1 RT1
         C    R0,=F'3'
*MCALL #=   292 LV= 1          RT1  CCE
         DS    0H
RT1_TEST229      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE229
         LTORG 
RT1_CCE229      DS 0H
*MEXIT #=   292 LV= 1 RT1
* EBF8 LAA
         MVC  WORD,=F'3'
         SR   R0,R0
         L    R1,=F'5'
         LAA  R0,R1,WORD
*MCALL #=   293 LV= 1          RT1  CCH
         DS    0H
RT1_TEST230      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH230
         LTORG 
RT1_CCH230      DS 0H
*MEXIT #=   293 LV= 1 RT1
         CLC  WORD,=F'8'
*MCALL #=   294 LV= 1          RT1  CCE
         DS    0H
RT1_TEST231      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE231
         LTORG 
RT1_CCE231      DS 0H
*MEXIT #=   294 LV= 1 RT1
         C    R0,=F'3'
*MCALL #=   295 LV= 1          RT1  CCE
         DS    0H
RT1_TEST232      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE232
         LTORG 
RT1_CCE232      DS 0H
*MEXIT #=   295 LV= 1 RT1
* EBF8 LAA
         MVC  WORD,=F'3'
         SR   R0,R0
         L    R1,=F'5'
         LAAL R0,R1,WORD
*MCALL #=   296 LV= 1          RT1  CC1  NZ,NC
         DS    0H
RT1_TEST233      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL233
         LTORG 
RT1_CCL233      DS 0H
*MEXIT #=   296 LV= 1 RT1
         CLC  WORD,=F'8'
*MCALL #=   297 LV= 1          RT1  CCE
         DS    0H
RT1_TEST234      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE234
         LTORG 
RT1_CCE234      DS 0H
*MEXIT #=   297 LV= 1 RT1
         C    R0,=F'3'
*MCALL #=   298 LV= 1          RT1  CCE
         DS    0H
RT1_TEST235      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE235
         LTORG 
RT1_CCE235      DS 0H
*MEXIT #=   298 LV= 1 RT1
* EC51 RISBLG
         LG    R5,=C'12345678'
         LG    R6,=C'9ABCDEFG'
         RISBLG R5,R6,0,7,32-8  MOVE G TO FIRST CHAR IN LOW 32
         CG    R5,=C'1234G678'
*MCALL #=   299 LV= 1          RT1   CCE
         DS    0H
RT1_TEST236      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE236
         LTORG 
RT1_CCE236      DS 0H
*MEXIT #=   299 LV= 1 RT1
         LG    R5,=C'12345678'
         LG    R6,=C'9ABCDEFG'
         RISBLG R5,R6,24,31,8  MOVE 9 TO G
         CG    R5,=C'12345679'
*MCALL #=   300 LV= 1          RT1   CCE
         DS    0H
RT1_TEST237      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE237
         LTORG 
RT1_CCE237      DS 0H
*MEXIT #=   300 LV= 1 RT1
         LG    R1,=X'0123456789ABCDEF'
         LG    R2,=X'FEDCBA9876543210'
         RISBLGZ R1,R2,0,31,32
         CLG   R1,=X'01234567FEDCBA98'
*MCALL #=   301 LV= 1          RT1   CCE
         DS    0H
RT1_TEST238      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE238
         LTORG 
RT1_CCE238      DS 0H
*MEXIT #=   301 LV= 1 RT1
         LG    R1,=X'0123456789ABCDEF'
         LG    R2,=X'FEDCBA9876543210'
         LLHFR R1,R2    RPI-1164
         CLG   R1,=X'01234567FEDCBA98'
*MCALL #=   302 LV= 1          RT1   CCE
         DS    0H
RT1_TEST239      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE239
         LTORG 
RT1_CCE239      DS 0H
*MEXIT #=   302 LV= 1 RT1
         LG    R1,=X'0123456789ABCDEF'
         LG    R2,=X'FEDCBA9876543210'
         RISBLGZ R1,R2,16,31,32
         CLG   R1,=X'012345670000BA98'
*MCALL #=   303 LV= 1          RT1   CCE
         DS    0H
RT1_TEST240      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE240
         LTORG 
RT1_CCE240      DS 0H
*MEXIT #=   303 LV= 1 RT1
         LG    R1,=X'0123456789ABCDEF'
         LG    R2,=X'FEDCBA9876543210'
         LLHLHR R1,R2    RPI-1164
         CLG   R1,=X'012345670000BA98'
*MCALL #=   304 LV= 1          RT1   CCE
         DS    0H
RT1_TEST241      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE241
         LTORG 
RT1_CCE241      DS 0H
*MEXIT #=   304 LV= 1 RT1
         LG    R1,=X'0123456789ABCDEF'
         LG    R2,=X'FEDCBA9876543210'
         RISBLGZ R1,R2,24,31,32
         CLG   R1,=X'0123456700000098'
*MCALL #=   305 LV= 1          RT1   CCE
         DS    0H
RT1_TEST242      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE242
         LTORG 
RT1_CCE242      DS 0H
*MEXIT #=   305 LV= 1 RT1
         LG    R1,=X'0123456789ABCDEF'
         LG    R2,=X'FEDCBA9876543210'
         LLCLHR R1,R2    RPI-1164
         CLG   R1,=X'0123456700000098'
*MCALL #=   306 LV= 1          RT1   CCE
         DS    0H
RT1_TEST243      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE243
         LTORG 
RT1_CCE243      DS 0H
*MEXIT #=   306 LV= 1 RT1
* EC54 RNSBG
         LG    R1,=X'FF0000FFFF0000FF'
         LG    R2,=X'9999999988888888'
         RNSBG R1,R2,0,31
         CLG   R1,=X'99000099FF0000FF'
*MCALL #=   307 LV= 1          RT1   CCE
         DS    0H
RT1_TEST244      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE244
         LTORG 
RT1_CCE244      DS 0H
*MEXIT #=   307 LV= 1 RT1
         LG    R1,=X'FF0000FFFF0000FF'
         LG    R2,=X'9999999988888888'
         NHHR  R1,R2     RPI-1164
         CLG   R1,=X'99000099FF0000FF'
*MCALL #=   308 LV= 1          RT1   CCE
         DS    0H
RT1_TEST245      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE245
         LTORG 
RT1_CCE245      DS 0H
*MEXIT #=   308 LV= 1 RT1
         LG    R1,=X'FF0000FFFF0000FF'
         LG    R2,=X'9999999988888888'
         RNSBG R1,R2,0,31,32
         CLG   R1,=X'88000088FF0000FF'
*MCALL #=   309 LV= 1          RT1   CCE
         DS    0H
RT1_TEST246      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE246
         LTORG 
RT1_CCE246      DS 0H
*MEXIT #=   309 LV= 1 RT1
         LG    R1,=X'FF0000FFFF0000FF'
         LG    R2,=X'9999999988888888'
         NHLR  R1,R2     RPI-1164
         CLG   R1,=X'88000088FF0000FF'
*MCALL #=   310 LV= 1          RT1   CCE
         DS    0H
RT1_TEST247      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE247
         LTORG 
RT1_CCE247      DS 0H
*MEXIT #=   310 LV= 1 RT1
         LG    R1,=X'FF0000FFFF0000FF'
         LG    R2,=X'9999999988888888'
         RNSBG R1,R2,32,63,32
         CLG   R1,=X'FF0000FF99000099'
*MCALL #=   311 LV= 1          RT1   CCE
         DS    0H
RT1_TEST248      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE248
         LTORG 
RT1_CCE248      DS 0H
*MEXIT #=   311 LV= 1 RT1
         LG    R1,=X'FF0000FFFF0000FF'
         LG    R2,=X'9999999988888888'
         NLHR  R1,R2     RPI-1164
         CLG   R1,=X'FF0000FF99000099'
*MCALL #=   312 LV= 1          RT1   CCE
         DS    0H
RT1_TEST249      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE249
         LTORG 
RT1_CCE249      DS 0H
*MEXIT #=   312 LV= 1 RT1
* EC56 ROSBG
         LG    R1,=X'FF0000FFFF0000FF'
         LG    R2,=X'9999999988888888'
         ROSBG R1,R2,0,31
         CLG   R1,=X'FF9999FFFF0000FF'
*MCALL #=   313 LV= 1          RT1   CCE
         DS    0H
RT1_TEST250      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE250
         LTORG 
RT1_CCE250      DS 0H
*MEXIT #=   313 LV= 1 RT1
         LG    R1,=X'FF0000FFFF0000FF'
         LG    R2,=X'9999999988888888'
         OHHR  R1,R2     RPI-1164
         CLG   R1,=X'FF9999FFFF0000FF'
*MCALL #=   314 LV= 1          RT1   CCE
         DS    0H
RT1_TEST251      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE251
         LTORG 
RT1_CCE251      DS 0H
*MEXIT #=   314 LV= 1 RT1
         LG    R1,=X'FF0000FFFF0000FF'
         LG    R2,=X'9999999988888888'
         ROSBG R1,R2,0,31,32
         CLG   R1,=X'FF8888FFFF0000FF'
*MCALL #=   315 LV= 1          RT1   CCE
         DS    0H
RT1_TEST252      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE252
         LTORG 
RT1_CCE252      DS 0H
*MEXIT #=   315 LV= 1 RT1
         LG    R1,=X'FF0000FFFF0000FF'
         LG    R2,=X'9999999988888888'
         OHLR  R1,R2     RPI-1164
         CLG   R1,=X'FF8888FFFF0000FF'
*MCALL #=   316 LV= 1          RT1   CCE
         DS    0H
RT1_TEST253      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE253
         LTORG 
RT1_CCE253      DS 0H
*MEXIT #=   316 LV= 1 RT1
         LG    R1,=X'FF0000FFFF0000FF'
         LG    R2,=X'9999999988888888'
         ROSBG R1,R2,32,63,32
         CLG   R1,=X'FF0000FFFF9999FF'
*MCALL #=   317 LV= 1          RT1   CCE
         DS    0H
RT1_TEST254      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE254
         LTORG 
RT1_CCE254      DS 0H
*MEXIT #=   317 LV= 1 RT1
         LG    R1,=X'FF0000FFFF0000FF'
         LG    R2,=X'9999999988888888'
         OLHR  R1,R2     RPI-1164
         CLG   R1,=X'FF0000FFFF9999FF'
*MCALL #=   318 LV= 1          RT1   CCE
         DS    0H
RT1_TEST255      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE255
         LTORG 
RT1_CCE255      DS 0H
*MEXIT #=   318 LV= 1 RT1
* EC57 RXSBG
         LG    R1,=X'FF0000FFFF0000FF'
         LG    R2,=X'9999999988888888'
         RXSBG R1,R2,0,31
         CLG   R1,=X'66999966FF0000FF'
*MCALL #=   319 LV= 1          RT1   CCE
         DS    0H
RT1_TEST256      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE256
         LTORG 
RT1_CCE256      DS 0H
*MEXIT #=   319 LV= 1 RT1
         LG    R1,=X'FF0000FFFF0000FF'
         LG    R2,=X'9999999988888888'
         XHHR  R1,R2     RPI-1164
         CLG   R1,=X'66999966FF0000FF'
*MCALL #=   320 LV= 1          RT1   CCE
         DS    0H
RT1_TEST257      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE257
         LTORG 
RT1_CCE257      DS 0H
*MEXIT #=   320 LV= 1 RT1
         LG    R1,=X'FF0000FFFF0000FF'
         LG    R2,=X'9999999988888888'
         RXSBG R1,R2,0,31,32
         CLG   R1,=X'77888877FF0000FF'
*MCALL #=   321 LV= 1          RT1   CCE
         DS    0H
RT1_TEST258      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE258
         LTORG 
RT1_CCE258      DS 0H
*MEXIT #=   321 LV= 1 RT1
         LG    R1,=X'FF0000FFFF0000FF'
         LG    R2,=X'9999999988888888'
         XHLR  R1,R2     RPI-1164
         CLG   R1,=X'77888877FF0000FF'
*MCALL #=   322 LV= 1          RT1   CCE
         DS    0H
RT1_TEST259      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE259
         LTORG 
RT1_CCE259      DS 0H
*MEXIT #=   322 LV= 1 RT1
         LG    R1,=X'FF0000FFFF0000FF'
         LG    R2,=X'9999999988888888'
         RXSBG R1,R2,32,63,32
         CLG   R1,=X'FF0000FF66999966'
*MCALL #=   323 LV= 1          RT1   CCE
         DS    0H
RT1_TEST260      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE260
         LTORG 
RT1_CCE260      DS 0H
*MEXIT #=   323 LV= 1 RT1
         LG    R1,=X'FF0000FFFF0000FF'
         LG    R2,=X'9999999988888888'
         XLHR  R1,R2     RPI-1164
         CLG   R1,=X'FF0000FF66999966'
*MCALL #=   324 LV= 1          RT1   CCE
         DS    0H
RT1_TEST261      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE261
         LTORG 
RT1_CCE261      DS 0H
*MEXIT #=   324 LV= 1 RT1
* EC5D RISBHG
         LG    R5,=C'12345678'
         LG    R6,=C'9ABCDEFG'
         RISBHG R5,R6,0,7,64-8  MOVE G TO FIRST CHAR IN HIGH 32
         CLG   R5,=C'G2345678'
*MCALL #=   325 LV= 1          RT1   CCE
         DS    0H
RT1_TEST262      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE262
         LTORG 
RT1_CCE262      DS 0H
*MEXIT #=   325 LV= 1 RT1
         LG    R5,=C'12345678'
         LG    R6,=C'9ABCDEFG'
         RISBHG R5,R6,24,31,40  MOVE 9 TO 4
         CG    R5,=C'12395678'
*MCALL #=   326 LV= 1          RT1   CCE
         DS    0H
RT1_TEST263      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE263
         LTORG 
RT1_CCE263      DS 0H
*MEXIT #=   326 LV= 1 RT1
         LG    R1,=X'0123456789ABCDEF'
         LG    R2,=X'FEDCBA9876543210'
         RISBHGZ R1,R2,0,31
         CLG   R1,=X'FEDCBA9889ABCDEF'
*MCALL #=   327 LV= 1          RT1   CCE
         DS    0H
RT1_TEST264      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE264
         LTORG 
RT1_CCE264      DS 0H
*MEXIT #=   327 LV= 1 RT1
         LG    R1,=X'0123456789ABCDEF'
         LG    R2,=X'FEDCBA9876543210'
         LHHR  R1,R2    RPI-1164
         CLG   R1,=X'FEDCBA9889ABCDEF'
*MCALL #=   328 LV= 1          RT1   CCE
         DS    0H
RT1_TEST265      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE265
         LTORG 
RT1_CCE265      DS 0H
*MEXIT #=   328 LV= 1 RT1
         LG    R1,=X'0123456789ABCDEF'
         LG    R2,=X'FEDCBA9876543210'
         RISBHGZ R1,R2,0,31,32
         CLG   R1,=X'7654321089ABCDEF'
*MCALL #=   329 LV= 1          RT1   CCE
         DS    0H
RT1_TEST266      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE266
         LTORG 
RT1_CCE266      DS 0H
*MEXIT #=   329 LV= 1 RT1
         LG    R1,=X'0123456789ABCDEF'
         LG    R2,=X'FEDCBA9876543210'
         LHLR  R1,R2    RPI-1164
         CLG    R1,=X'7654321089ABCDEF'
*MCALL #=   330 LV= 1          RT1   CCE
         DS    0H
RT1_TEST267      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE267
         LTORG 
RT1_CCE267      DS 0H
*MEXIT #=   330 LV= 1 RT1
         LG    R1,=X'0123456789ABCDEF'
         LG    R2,=X'FEDCBA9876543210'
         RISBHGZ R1,R2,16,31
         CLG   R1,=X'0000BA9889ABCDEF'
*MCALL #=   331 LV= 1          RT1   CCE
         DS    0H
RT1_TEST268      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE268
         LTORG 
RT1_CCE268      DS 0H
*MEXIT #=   331 LV= 1 RT1
         LG    R1,=X'0123456789ABCDEF'
         LG    R2,=X'FEDCBA9876543210'
         LLHHHR  R1,R2    RPI-1164
         CLG   R1,=X'0000BA9889ABCDEF'
*MCALL #=   332 LV= 1          RT1   CCE
         DS    0H
RT1_TEST269      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE269
         LTORG 
RT1_CCE269      DS 0H
*MEXIT #=   332 LV= 1 RT1
         LG    R1,=X'0123456789ABCDEF'
         LG    R2,=X'FEDCBA9876543210'
         RISBHGZ R1,R2,16,31,32
         CLG   R1,=X'0000321089ABCDEF'
*MCALL #=   333 LV= 1          RT1   CCE
         DS    0H
RT1_TEST270      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE270
         LTORG 
RT1_CCE270      DS 0H
*MEXIT #=   333 LV= 1 RT1
         LG    R1,=X'0123456789ABCDEF'
         LG    R2,=X'FEDCBA9876543210'
         LLHHLR R1,R2    RPI-1164
         CLG   R1,=X'0000321089ABCDEF'
*MCALL #=   334 LV= 1          RT1   CCE
         DS    0H
RT1_TEST271      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE271
         LTORG 
RT1_CCE271      DS 0H
*MEXIT #=   334 LV= 1 RT1
         LG    R1,=X'0123456789ABCDEF'
         LG    R2,=X'FEDCBA9876543210'
         RISBHGZ R1,R2,24,31
         CLG   R1,=X'0000009889ABCDEF'
*MCALL #=   335 LV= 1          RT1   CCE
         DS    0H
RT1_TEST272      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE272
         LTORG 
RT1_CCE272      DS 0H
*MEXIT #=   335 LV= 1 RT1
         LG    R1,=X'0123456789ABCDEF'
         LG    R2,=X'FEDCBA9876543210'
         LLCHHR R1,R2    RPI-1164
         CLG   R1,=X'0000009889ABCDEF'
*MCALL #=   336 LV= 1          RT1   CCE
         DS    0H
RT1_TEST273      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE273
         LTORG 
RT1_CCE273      DS 0H
*MEXIT #=   336 LV= 1 RT1
         LG    R1,=X'0123456789ABCDEF'
         LG    R2,=X'FEDCBA9876543210'
         RISBHGZ R1,R2,24,31,32
         CLG   R1,=X'0000001089ABCDEF'
*MCALL #=   337 LV= 1          RT1   CCE
         DS    0H
RT1_TEST274      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE274
         LTORG 
RT1_CCE274      DS 0H
*MEXIT #=   337 LV= 1 RT1
         LG    R1,=X'0123456789ABCDEF'
         LG    R2,=X'FEDCBA9876543210'
         LLCHLR R1,R2    RPI-1164
         CLG   R1,=X'0000001089ABCDEF'
*MCALL #=   338 LV= 1          RT1   CCE
         DS    0H
RT1_TEST275      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE275
         LTORG 
RT1_CCE275      DS 0H
*MEXIT #=   338 LV= 1 RT1
* ECD8 AHIK
         SR    R0,R0
         L     R1,=F'123'
         AHIK  R0,R1,123
*MCALL #=   339 LV= 1          RT1   CCH
         DS    0H
RT1_TEST276      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH276
         LTORG 
RT1_CCH276      DS 0H
*MEXIT #=   339 LV= 1 RT1
         CL    R0,=F'246'
*MCALL #=   340 LV= 1          RT1   CCE
         DS    0H
RT1_TEST277      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE277
         LTORG 
RT1_CCE277      DS 0H
*MEXIT #=   340 LV= 1 RT1
* ECD9 AGHIK
         SGR    R0,R0
         LG     R1,=FL8'123'
         AGHIK R0,R1,123
*MCALL #=   341 LV= 1          RT1   CCH
         DS    0H
RT1_TEST278      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH278
         LTORG 
RT1_CCH278      DS 0H
*MEXIT #=   341 LV= 1 RT1
         CG    R0,=FL8'246'
*MCALL #=   342 LV= 1          RT1   CCE
         DS    0H
RT1_TEST279      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE279
         LTORG 
RT1_CCE279      DS 0H
*MEXIT #=   342 LV= 1 RT1
* ECDA ALHSIK
         SR     R0,R0
         L      R1,=F'123'
         ALHSIK R0,R1,123
*MCALL #=   343 LV= 1          RT1   CC1  NZ,NC
         DS    0H
RT1_TEST280      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL280
         LTORG 
RT1_CCL280      DS 0H
*MEXIT #=   343 LV= 1 RT1
         C     R0,=F'246'
*MCALL #=   344 LV= 1          RT1   CCE
         DS    0H
RT1_TEST281      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE281
         LTORG 
RT1_CCE281      DS 0H
*MEXIT #=   344 LV= 1 RT1
* ECDB ALGHSIK
         SGR    R0,R0
         LG     R1,=FL8'123'
         ALGHSIK R0,R1,123
*MCALL #=   345 LV= 1          RT1   CC1  NZ,NC
         DS    0H
RT1_TEST282      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL282
         LTORG 
RT1_CCL282      DS 0H
*MEXIT #=   345 LV= 1 RT1
         CG    R0,=FL8'246'
*MCALL #=   346 LV= 1          RT1   CCE
         DS    0H
RT1_TEST283      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE283
         LTORG 
RT1_CCE283      DS 0H
*MEXIT #=   346 LV= 1 RT1
* END
*MCALL #=   347 LV= 1          RT1   END
         B      RT1_END
*MEXIT #=   347 LV= 1 RT1
         END 
