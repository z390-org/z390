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
* 2005-09-30 DSH         Initial version                            *
* 2005-11-20 DSH RPI-106 Correct mask alignment for SPM             *
* 2006-02-08 DSH RPI-185 Add MAYR, MYR, MAY, MY                     *
* 2006-03-15 DSH RPI-229 Correct extended FP register pair usage    *
* 2006-05-02 DSH RPI-305 Update ESPIE exit support                  *
* 2006-05-02 DSH RPI-298 Add tests for MAYLR, MYLR, MAYHR, MYHR,    *
*                        MAYL, MYL, MAYH, MYH                       *
* 2006-07-03 DSH RPI-325 Add tests for KEB,KDB errors on exact zero *
* 2006-07-03 DSH RPI-326 Add tests for TCEB, TCDB, and TCXB         *
* 2006-07-04 DSH RPI-333 Add tests SRNM and FIEBR, FIDBR, and FIXBR *
* 2006-08-02 DSH RPI-367 Add LB min value required to trap for KXBR *
* 2006-12-16 DSH RPI-518 Correct invalid pair fetch for FIXBR       *
* 2008-03-19 DSH RPI-819 Correct CFEBR, CFDBR, AND CFXBR to use     *
*                        CL vs CG                                   *
* 2008-03-20 DSH RPI-824 Test flush of LB/LD/LH when changing BD2   *
*                        register                                   *
* 2008-04-06 DSH RPI-834 Correct MSE?? and MSD?? to subtract from   *
*                        product and correct TCEB, TCDB, AND TCXB   *
*                        minus -0 tests                             *
* 2008-05-16 DSH RPI-821 Add test for HI/LOW DH/LH nibble precision *
*                        and adjust LBMAX for testing new limits    *
* 2008-05-29 DSH RPI-767 Add tests for AW,SW,AWR,SWR unnormalized   *
*                        Add tests for AU,SU,AUR,SUR unnormalized   *
* 2008-06-20 DSH RPI-845 Change EPIED to IHAEPIE                    *
*********************************************************************
* This program includes unit tests of each HFP and BFP instructions *
* added to ez390.java J2SE 390 emulator.                            *
* RT1 macro used to automate code generated for mainline and test   *
* PSW CC routines. The macros define new base registers for each    *
* test so they can extend for any length.                           *
*                                                                   *
* See TESTINS2 for other instruction tests                          *
*********************************************************************
         TITLE 'TESTFP1 - UNIT TEST HFP AND BFP FLOATING PT INSTR'
         PRINT DATA
         MACRO
&N       LX    &R1,&S2   LOAD  LH/LB
         LA    15,&S2
         LD    &R1,0(15)
         LD    &R1+2,8(15)  RPI 229
         MEND
         MACRO
&N       STX   &R1,&S2   STORE LH/LB
         LA    15,&S2
         STD   &R1,0(15)
         STD   &R1+2,8(15)  RPI 229
         MEND
*MCALL #=     1 LV= 1 TESTFP1  RT1   MAIN
*MCALL #=     2 LV= 2 TESTFP1  SUBENTRY 
TESTFP1  CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTFP1'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTFP1+8,13
*MEXIT #=     2 LV= 2 SUBENTRY
*MCALL #=     3 LV= 2          WTO   'TESTFP1 RT1 STARTED'
         BRAS  1,*+(WTO#0003_EOT-*+1)/2*2
         DC    AL2(WTO#0003_EOT-*,0),C'TESTFP1 RT1 STARTED'
WTO#0003_EOT     EQU *
         SVC   35
*MEXIT #=     3 LV= 2 WTO
         BRCL    15,RT1_START
RT1_ABORT DS 0H
         MVI   RT1_ABORTED,C'T'
*MCALL #=     4 LV= 2          WTO   'TESTFP1 RT1 TESTING ABORTED'
         BRAS  1,*+(WTO#0004_EOT-*+1)/2*2
         DC    AL2(WTO#0004_EOT-*,0),C'TESTFP1 RT1 TESTING ABORTED'
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
*MCALL #=     6 LV= 2          WTO   'TESTFP1 RT1 ENDED OK'
         BRAS  1,*+(WTO#0006_EOT-*+1)/2*2
         DC    AL2(WTO#0006_EOT-*,0),C'TESTFP1 RT1 ENDED OK'
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
RT1_WTO1 DC    AL2(RT1_WTO_END-*,0),C'TESTFP1 RT1 TESTS COMPLETED = '
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
*MCALL #=     9 LV= 1          EQUREGS 
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
ESPIE_EXIT DS  0H
         USING *,R15
         USING EPIE,R1
         L     R0,EPIEPARM
         ST    R0,EPIEPSW+4
         BR    R14
         DROP  R15,R1
FPCREG   DS    F
FPCDXC   EQU   FPCREG+2 REASON CODES FOR 0C7 DATA EXCEPTIONS
PWORK    DS    D
PWORK16  DS    XL16
WORD     DS    F
DWORD    DS    D
DWORD2   DS    D
BYTE     DS    X
LWORK    DS    XL16
EBMIN    DC    EB'1.2E-38'    SEE POP BFP 19-5 (MATCH EZ390 VALUES)
EBMAX    DC    EB'3.4E+38'
DBMIN    DC    DB'2.2E-308'
DBMAX    DC    DB'1.79E+308'  (1.8 too big for double?)
LBMIN    DC    LB'3.3E-4932'  RPI 396 WAS 3.4
LBMAX    DC    LB'1.3E+4932'  RPI 821 WAS 1.2
EHMIN    DC    EH'5.4E-79'    SEE POP HFP 18-4
EHMAX    DC    EH'7.2E+75'
DHMIN    DC    DH'5.4E-79'
DHMAX    DC    DH'7.2E+75'
LHMIN    DC    LH'5.4E-79'
LHMAX    DC    LH'7.2E+75'
TDCPZ    EQU   X'800' TEST FP DATA CLASS PLUS  ZERO
TDCMZ    EQU   X'400' TEST FP DATA CLASS MINUS ZERO
TDCPN    EQU   X'200' TEST FP DATA CLASS PLUS  NORMALIZED
TDCMN    EQU   X'100' TEST FP DATA CLASS MINUS NORMALIZED
TDCPD    EQU   X'080' TEST FP DATA CLASS PLUS  DENORMALIZED
TDCMD    EQU   X'040' TEST FP DATA CLASS MINUS DENORMALIZED
TDCPI    EQU   X'020' TEST FP DATA CLASS PLUS  INFINITY
TDCMI    EQU   X'010' TEST FP DATA CLASS MINUS INFINITY
TDCPQ    EQU   X'008' TEST FP DATA CLASS PLUS  QUIET NAN
TDCMQ    EQU   X'004' TEST FP DATA CLASS MINUS QUIET NAN
TDCPS    EQU   X'002' TEST FP DATA CLASS PLUS  SIGNAL NAN
TDCMS    EQU   X'001' TEST FP DATA CLASS MINUS SIGNAL NAN
*MCALL #=    11 LV= 1          RT1   START
RT1_START DS  0H
*MEXIT #=    11 LV= 1 RT1
*MCALL #=    12 LV= 1          RT1   CCE,=DB'0',=X'0000000000000000'
         DS    0H
         CLC   =DB'0',=X'0000000000000000'
RT1_TEST1        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1
         LTORG 
RT1_CCE1        DS 0H
*MEXIT #=    12 LV= 1 RT1
*MCALL #=    13 LV= 1          RT1   CCE,=DB'1',=X'3FF0000000000000'
         DS    0H
         CLC   =DB'1',=X'3FF0000000000000'
RT1_TEST2        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE2
         LTORG 
RT1_CCE2        DS 0H
*MEXIT #=    13 LV= 1 RT1
*MCALL #=    14 LV= 1          RT1   CCE,=DB'10',=X'4024000000000000'
         DS    0H
         CLC   =DB'10',=X'4024000000000000'
RT1_TEST3        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE3
         LTORG 
RT1_CCE3        DS 0H
*MEXIT #=    14 LV= 1 RT1
*MCALL #=    15 LV= 1          RT1   CCE,=DB'-1',=X'BFF0000000000000'
         DS    0H
         CLC   =DB'-1',=X'BFF0000000000000'
RT1_TEST4        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE4
         LTORG 
RT1_CCE4        DS 0H
*MEXIT #=    15 LV= 1 RT1
*MCALL #=    16 LV= 1          RT1   CCE,=DB'-10',=X'C024000000000000'
         DS    0H
         CLC   =DB'-10',=X'C024000000000000'
RT1_TEST5        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE5
         LTORG 
RT1_CCE5        DS 0H
*MEXIT #=    16 LV= 1 RT1
*MCALL #=    17 LV= 1          RT1   CCE,=DB'3E-1',=X'3FD3333333333333'
         DS    0H
         CLC   =DB'3E-1',=X'3FD3333333333333'
RT1_TEST6        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE6
         LTORG 
RT1_CCE6        DS 0H
*MEXIT #=    17 LV= 1 RT1
*MCALL #=    18 LV= 1          RT1   CCE,=DH'0',=X'0000000000000000'
         DS    0H
         CLC   =DH'0',=X'0000000000000000'
RT1_TEST7        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE7
         LTORG 
RT1_CCE7        DS 0H
*MEXIT #=    18 LV= 1 RT1
*MCALL #=    19 LV= 1          RT1   CCE,=DH'1',=X'4110000000000000'
         DS    0H
         CLC   =DH'1',=X'4110000000000000'
RT1_TEST8        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE8
         LTORG 
RT1_CCE8        DS 0H
*MEXIT #=    19 LV= 1 RT1
*MCALL #=    20 LV= 1          RT1   CCE,=DH'10',=X'41A0000000000000'
         DS    0H
         CLC   =DH'10',=X'41A0000000000000'
RT1_TEST9        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE9
         LTORG 
RT1_CCE9        DS 0H
*MEXIT #=    20 LV= 1 RT1
*MCALL #=    21 LV= 1          RT1   CCE,=DH'-1',=X'C110000000000000'
         DS    0H
         CLC   =DH'-1',=X'C110000000000000'
RT1_TEST10       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE10
         LTORG 
RT1_CCE10       DS 0H
*MEXIT #=    21 LV= 1 RT1
*MCALL #=    22 LV= 1          RT1   CCE,=DH'-10',=X'C1A0000000000000'
         DS    0H
         CLC   =DH'-10',=X'C1A0000000000000'
RT1_TEST11       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE11
         LTORG 
RT1_CCE11       DS 0H
*MEXIT #=    22 LV= 1 RT1
*MCALL #=    23 LV= 1          RT1   CCE,=DH'3E-1',=X'404CCCCCCCCCCCCD'
         DS    0H
         CLC   =DH'3E-1',=X'404CCCCCCCCCCCCD'
RT1_TEST12       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE12
         LTORG 
RT1_CCE12       DS 0H
*MEXIT #=    23 LV= 1 RT1
*MCALL #=    24 LV= 1          RT1   CCE,=EB'0',=X'00000000'
         DS    0H
         CLC   =EB'0',=X'00000000'
RT1_TEST13       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE13
         LTORG 
RT1_CCE13       DS 0H
*MEXIT #=    24 LV= 1 RT1
*MCALL #=    25 LV= 1          RT1   CCE,=EB'1',=X'3F800000'
         DS    0H
         CLC   =EB'1',=X'3F800000'
RT1_TEST14       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE14
         LTORG 
RT1_CCE14       DS 0H
*MEXIT #=    25 LV= 1 RT1
*MCALL #=    26 LV= 1          RT1   CCE,=EB'10',=X'41200000'
         DS    0H
         CLC   =EB'10',=X'41200000'
RT1_TEST15       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE15
         LTORG 
RT1_CCE15       DS 0H
*MEXIT #=    26 LV= 1 RT1
*MCALL #=    27 LV= 1          RT1   CCE,=EB'-1',=X'BF800000'
         DS    0H
         CLC   =EB'-1',=X'BF800000'
RT1_TEST16       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE16
         LTORG 
RT1_CCE16       DS 0H
*MEXIT #=    27 LV= 1 RT1
*MCALL #=    28 LV= 1          RT1   CCE,=EB'-10',=X'C1200000'
         DS    0H
         CLC   =EB'-10',=X'C1200000'
RT1_TEST17       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE17
         LTORG 
RT1_CCE17       DS 0H
*MEXIT #=    28 LV= 1 RT1
*MCALL #=    29 LV= 1          RT1   CCE,=EH'0',=X'00000000'
         DS    0H
         CLC   =EH'0',=X'00000000'
RT1_TEST18       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE18
         LTORG 
RT1_CCE18       DS 0H
*MEXIT #=    29 LV= 1 RT1
*MCALL #=    30 LV= 1          RT1   CCE,=EH'1',=X'41100000'
         DS    0H
         CLC   =EH'1',=X'41100000'
RT1_TEST19       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE19
         LTORG 
RT1_CCE19       DS 0H
*MEXIT #=    30 LV= 1 RT1
*MCALL #=    31 LV= 1          RT1   CCE,=EH'10',=X'41A00000'
         DS    0H
         CLC   =EH'10',=X'41A00000'
RT1_TEST20       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE20
         LTORG 
RT1_CCE20       DS 0H
*MEXIT #=    31 LV= 1 RT1
*MCALL #=    32 LV= 1          RT1   CCE,=EH'-1',=X'C1100000'
         DS    0H
         CLC   =EH'-1',=X'C1100000'
RT1_TEST21       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE21
         LTORG 
RT1_CCE21       DS 0H
*MEXIT #=    32 LV= 1 RT1
*MCALL #=    33 LV= 1          RT1   CCE,=EH'-10',=X'C1A00000'
         DS    0H
         CLC   =EH'-10',=X'C1A00000'
RT1_TEST22       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE22
         LTORG 
RT1_CCE22       DS 0H
*MEXIT #=    33 LV= 1 RT1
*MCALL #=    34 LV= 1          RT1   CCE,=LB'0',=X'00000000000000000000X
               000000000000'
         DS    0H
         CLC   =LB'0',=X'00000000000000000000000000000000'
RT1_TEST23       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE23
         LTORG 
RT1_CCE23       DS 0H
*MEXIT #=    34 LV= 1 RT1
*MCALL #=    35 LV= 1          RT1   CCE,=LB'1',=X'3FFF0000000000000000X
               000000000000'
         DS    0H
         CLC   =LB'1',=X'3FFF0000000000000000000000000000'
RT1_TEST24       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE24
         LTORG 
RT1_CCE24       DS 0H
*MEXIT #=    35 LV= 1 RT1
*MCALL #=    36 LV= 1          RT1   CCE,=LB'10',=X'4002400000000000000X
               0000000000000'
         DS    0H
         CLC   =LB'10',=X'40024000000000000000000000000000'
RT1_TEST25       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE25
         LTORG 
RT1_CCE25       DS 0H
*MEXIT #=    36 LV= 1 RT1
*MCALL #=    37 LV= 1          RT1   CCE,=LB'-1',=X'BFFF000000000000000X
               0000000000000'
         DS    0H
         CLC   =LB'-1',=X'BFFF0000000000000000000000000000'
RT1_TEST26       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE26
         LTORG 
RT1_CCE26       DS 0H
*MEXIT #=    37 LV= 1 RT1
*MCALL #=    38 LV= 1          RT1   CCE,=LB'-10',=X'C00240000000000000X
               00000000000000'
         DS    0H
         CLC   =LB'-10',=X'C0024000000000000000000000000000'
RT1_TEST27       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE27
         LTORG 
RT1_CCE27       DS 0H
*MEXIT #=    38 LV= 1 RT1
*MCALL #=    39 LV= 1          RT1   CCE,=LH'0',=X'00000000000000000000X
               000000000000'
         DS    0H
         CLC   =LH'0',=X'00000000000000000000000000000000'
RT1_TEST28       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE28
         LTORG 
RT1_CCE28       DS 0H
*MEXIT #=    39 LV= 1 RT1
*MCALL #=    40 LV= 1          RT1   CCE,=LH'1',=X'41100000000000003300X
               000000000000'
         DS    0H
         CLC   =LH'1',=X'41100000000000003300000000000000'
RT1_TEST29       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE29
         LTORG 
RT1_CCE29       DS 0H
*MEXIT #=    40 LV= 1 RT1
*MCALL #=    41 LV= 1          RT1   CCE,=LH'10',=X'41A0000000000000330X
               0000000000000'
         DS    0H
         CLC   =LH'10',=X'41A00000000000003300000000000000'
RT1_TEST30       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE30
         LTORG 
RT1_CCE30       DS 0H
*MEXIT #=    41 LV= 1 RT1
*MCALL #=    42 LV= 1          RT1   CCE,=LH'-1',=X'C110000000000000B30X
               0000000000000'
         DS    0H
         CLC   =LH'-1',=X'C110000000000000B300000000000000'
RT1_TEST31       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE31
         LTORG 
RT1_CCE31       DS 0H
*MEXIT #=    42 LV= 1 RT1
*MCALL #=    43 LV= 1          RT1   CCE,=LH'-10',=X'C1A0000000000000B3X
               00000000000000'
         DS    0H
         CLC   =LH'-10',=X'C1A0000000000000B300000000000000'
RT1_TEST32       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE32
         LTORG 
RT1_CCE32       DS 0H
*MEXIT #=    43 LV= 1 RT1
*MCALL #=    44 LV= 1          RT1   CCE,=LH'3E-1',=X'404CCCCCCCCCCCCC3X
               2CCCCCCCCCCCCCD'
         DS    0H
         CLC   =LH'3E-1',=X'404CCCCCCCCCCCCC32CCCCCCCCCCCCCD'
RT1_TEST33       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE33
         LTORG 
RT1_CCE33       DS 0H
*MEXIT #=    44 LV= 1 RT1
* 20   LPDR
         LD    R1,=DH'-1'
         LD    R2,=DH'1'
         LPDR  R0,R1
*MCALL #=    45 LV= 1          RT1   CCH
         DS    0H
RT1_TEST34       BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH34
         LTORG 
RT1_CCH34       DS 0H
*MEXIT #=    45 LV= 1 RT1
         CDR   R0,R2
*MCALL #=    46 LV= 1          RT1   CCE
         DS    0H
RT1_TEST35       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE35
         LTORG 
RT1_CCE35       DS 0H
*MEXIT #=    46 LV= 1 RT1
         LD    R1,=DH'0'
         LD    R2,=DH'0'
         LPDR  R0,R1
*MCALL #=    47 LV= 1          RT1   CCE
         DS    0H
RT1_TEST36       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE36
         LTORG 
RT1_CCE36       DS 0H
*MEXIT #=    47 LV= 1 RT1
         CDR   R0,R2
*MCALL #=    48 LV= 1          RT1   CCE
         DS    0H
RT1_TEST37       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE37
         LTORG 
RT1_CCE37       DS 0H
*MEXIT #=    48 LV= 1 RT1
         LD    1,=X'4E00000000000001' RPI 820 TEST UNNORMALIZED INPUT
         LD    0,=X'4110000000000000'
         CDR   0,1
*MCALL #=    49 LV= 1          RT1   CCE
         DS    0H
RT1_TEST38       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE38
         LTORG 
RT1_CCE38       DS 0H
*MEXIT #=    49 LV= 1 RT1
* 21   LNDR
         LD    R1,=DH'1'
         LD    R2,=DH'-1'
         LNDR  R0,R1
*MCALL #=    50 LV= 1          RT1   CCL
         DS    0H
RT1_TEST39       BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL39
         LTORG 
RT1_CCL39       DS 0H
*MEXIT #=    50 LV= 1 RT1
         CDR   R0,R2
*MCALL #=    51 LV= 1          RT1   CCE
         DS    0H
RT1_TEST40       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE40
         LTORG 
RT1_CCE40       DS 0H
*MEXIT #=    51 LV= 1 RT1
         LD    R1,=DH'0'
         LD    R2,=DH'0'
         LNDR  R0,R1
*MCALL #=    52 LV= 1          RT1   CCE
         DS    0H
RT1_TEST41       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE41
         LTORG 
RT1_CCE41       DS 0H
*MEXIT #=    52 LV= 1 RT1
         CDR   R0,R2
*MCALL #=    53 LV= 1          RT1   CCE
         DS    0H
RT1_TEST42       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE42
         LTORG 
RT1_CCE42       DS 0H
*MEXIT #=    53 LV= 1 RT1
* 22   LTDR
         LD    R1,=DH'1'
         LD    R2,=DH'1'
         LTDR  R0,R1
*MCALL #=    54 LV= 1          RT1   CCH
         DS    0H
RT1_TEST43       BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH43
         LTORG 
RT1_CCH43       DS 0H
*MEXIT #=    54 LV= 1 RT1
         CDR   R0,R2
*MCALL #=    55 LV= 1          RT1   CCE
         DS    0H
RT1_TEST44       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE44
         LTORG 
RT1_CCE44       DS 0H
*MEXIT #=    55 LV= 1 RT1
         LD    R1,=DH'0'
         LD    R2,=DH'0'
         LTDR  R0,R1
*MCALL #=    56 LV= 1          RT1   CCE
         DS    0H
RT1_TEST45       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE45
         LTORG 
RT1_CCE45       DS 0H
*MEXIT #=    56 LV= 1 RT1
         CDR   R0,R2
*MCALL #=    57 LV= 1          RT1   CCE
         DS    0H
RT1_TEST46       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE46
         LTORG 
RT1_CCE46       DS 0H
*MEXIT #=    57 LV= 1 RT1
         LD    R1,=DH'-1'
         LD    R2,=DH'-1'
         LTDR  R0,R1
*MCALL #=    58 LV= 1          RT1   CCL
         DS    0H
RT1_TEST47       BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL47
         LTORG 
RT1_CCL47       DS 0H
*MEXIT #=    58 LV= 1 RT1
         CDR   R0,R2
*MCALL #=    59 LV= 1          RT1   CCE
         DS    0H
RT1_TEST48       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE48
         LTORG 
RT1_CCE48       DS 0H
*MEXIT #=    59 LV= 1 RT1
* 23   LCDR
         LD    R1,=DH'-1'
         LD    R2,=DH'1'
         LCDR  R0,R1
*MCALL #=    60 LV= 1          RT1   CCH
         DS    0H
RT1_TEST49       BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH49
         LTORG 
RT1_CCH49       DS 0H
*MEXIT #=    60 LV= 1 RT1
         CDR   R0,R2
*MCALL #=    61 LV= 1          RT1   CCE
         DS    0H
RT1_TEST50       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE50
         LTORG 
RT1_CCE50       DS 0H
*MEXIT #=    61 LV= 1 RT1
         LD    R1,=DH'0'
         LD    R2,=DH'0'
         LCDR  R0,R1
*MCALL #=    62 LV= 1          RT1   CCE
         DS    0H
RT1_TEST51       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE51
         LTORG 
RT1_CCE51       DS 0H
*MEXIT #=    62 LV= 1 RT1
         CDR   R0,R2
*MCALL #=    63 LV= 1          RT1   CCE
         DS    0H
RT1_TEST52       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE52
         LTORG 
RT1_CCE52       DS 0H
*MEXIT #=    63 LV= 1 RT1
         LD    R1,=DH'1'
         LD    R2,=DH'-1'
         LCDR  R0,R1
*MCALL #=    64 LV= 1          RT1   CCL
         DS    0H
RT1_TEST53       BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL53
         LTORG 
RT1_CCL53       DS 0H
*MEXIT #=    64 LV= 1 RT1
         CDR   R0,R2
*MCALL #=    65 LV= 1          RT1   CCE
         DS    0H
RT1_TEST54       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE54
         LTORG 
RT1_CCE54       DS 0H
*MEXIT #=    65 LV= 1 RT1
* 24   HDR
         LD    R1,=DH'2'
         LD    R2,=DH'1'
         HDR   R0,R1
         CDR   R0,R2
*MCALL #=    66 LV= 1          RT1   CCE
         DS    0H
RT1_TEST55       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE55
         LTORG 
RT1_CCE55       DS 0H
*MEXIT #=    66 LV= 1 RT1
         LD    R1,=DH'0'
         LD    R2,=DH'0'
         HDR   R0,R1
         CDR   R0,R2
*MCALL #=    67 LV= 1          RT1   CCE
         DS    0H
RT1_TEST56       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE56
         LTORG 
RT1_CCE56       DS 0H
*MEXIT #=    67 LV= 1 RT1
         LD    R1,=DH'-2'
         LD    R2,=DH'-1'
         HDR   R0,R1
         CDR   R0,R2
*MCALL #=    68 LV= 1          RT1   CCE
         DS    0H
RT1_TEST57       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE57
         LTORG 
RT1_CCE57       DS 0H
*MEXIT #=    68 LV= 1 RT1
* 25   LDXR
*MCALL #=    69 LV= 1          LX    R1,=LH'123'
         LA    15,=LH'123'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=    69 LV= 1 LX
         LDXR  R0,R1
         CD    R0,=DH'123'
*MCALL #=    70 LV= 1          RT1   CCE
         DS    0H
RT1_TEST58       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE58
         LTORG 
RT1_CCE58       DS 0H
*MEXIT #=    70 LV= 1 RT1
* 26   MXR
*MCALL #=    71 LV= 1          LX    R0,=LH'20'
         LA    15,=LH'20'
         LD    R0,0(15)
         LD    R0+2,8(15)  RPI 229
*MEXIT #=    71 LV= 1 LX
*MCALL #=    72 LV= 1          LX    R1,=LH'30'
         LA    15,=LH'30'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=    72 LV= 1 LX
*MCALL #=    73 LV= 1          LX    R4,=LH'600'
         LA    15,=LH'600'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=    73 LV= 1 LX
         MXR   R0,R1
         CXR   R0,R4
*MCALL #=    74 LV= 1          RT1   CCE
         DS    0H
RT1_TEST59       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE59
         LTORG 
RT1_CCE59       DS 0H
*MEXIT #=    74 LV= 1 RT1
*MCALL #=    75 LV= 1          LX    R0,=LH'10'
         LA    15,=LH'10'
         LD    R0,0(15)
         LD    R0+2,8(15)  RPI 229
*MEXIT #=    75 LV= 1 LX
*MCALL #=    76 LV= 1          LX    R1,=LH'-20'
         LA    15,=LH'-20'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=    76 LV= 1 LX
*MCALL #=    77 LV= 1          LX    R4,=LH'-200'
         LA    15,=LH'-200'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=    77 LV= 1 LX
         MXR   R0,R1
         CXR   R0,R4
*MCALL #=    78 LV= 1          RT1   CCE
         DS    0H
RT1_TEST60       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE60
         LTORG 
RT1_CCE60       DS 0H
*MEXIT #=    78 LV= 1 RT1
*MCALL #=    79 LV= 1          LX    R0,=LH'-0.5'
         LA    15,=LH'-0.5'
         LD    R0,0(15)
         LD    R0+2,8(15)  RPI 229
*MEXIT #=    79 LV= 1 LX
*MCALL #=    80 LV= 1          LX    R1,=LH'-0.5'
         LA    15,=LH'-0.5'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=    80 LV= 1 LX
*MCALL #=    81 LV= 1          LX    R4,=LH'.25'
         LA    15,=LH'.25'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=    81 LV= 1 LX
         MXR   R0,R1
         CXR   R0,R4
*MCALL #=    82 LV= 1          RT1   CCE
         DS    0H
RT1_TEST61       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE61
         LTORG 
RT1_CCE61       DS 0H
*MEXIT #=    82 LV= 1 RT1
* 27   MXDR
         LD    R0,=DH'20'
         LD    R1,=DH'30'
*MCALL #=    83 LV= 1          LX    R4,=LH'600'
         LA    15,=LH'600'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=    83 LV= 1 LX
         MXDR  R0,R1
         CXR   R0,R4
*MCALL #=    84 LV= 1          RT1   CCE
         DS    0H
RT1_TEST62       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE62
         LTORG 
RT1_CCE62       DS 0H
*MEXIT #=    84 LV= 1 RT1
         LD    R0,=DH'10'
         LD    R1,=DH'-20'
*MCALL #=    85 LV= 1          LX    R4,=LH'-200'
         LA    15,=LH'-200'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=    85 LV= 1 LX
         MXDR  R0,R1
         CXR   R0,R4
*MCALL #=    86 LV= 1          RT1   CCE
         DS    0H
RT1_TEST63       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE63
         LTORG 
RT1_CCE63       DS 0H
*MEXIT #=    86 LV= 1 RT1
         LD    R0,=DH'-0.5'
         LD    R1,=DH'-0.5'
*MCALL #=    87 LV= 1          LX    R4,=LH'.25'
         LA    15,=LH'.25'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=    87 LV= 1 LX
         MXDR  R0,R1
         CXR   R0,R4
*MCALL #=    88 LV= 1          RT1   CCE
         DS    0H
RT1_TEST64       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE64
         LTORG 
RT1_CCE64       DS 0H
*MEXIT #=    88 LV= 1 RT1
* 28   LDR
         LD    R1,=DH'123'
         LDR   R0,R1
         CD    R0,=DH'123'
*MCALL #=    89 LV= 1          RT1   CCE
         DS    0H
RT1_TEST65       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE65
         LTORG 
RT1_CCE65       DS 0H
*MEXIT #=    89 LV= 1 RT1
* 29   CDR
         LD    R0,=DH'1'
         LD    R1,=DH'-2'
         CDR   R0,R1
*MCALL #=    90 LV= 1          RT1   CCH
         DS    0H
RT1_TEST66       BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH66
         LTORG 
RT1_CCH66       DS 0H
*MEXIT #=    90 LV= 1 RT1
         LD    R0,=DH'2'
         LD    R1,=DH'2'
         CDR   R0,R1
*MCALL #=    91 LV= 1          RT1   CCE
         DS    0H
RT1_TEST67       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE67
         LTORG 
RT1_CCE67       DS 0H
*MEXIT #=    91 LV= 1 RT1
         LD    R0,=DH'-2'
         LD    R1,=DH'4'
         CDR   R0,R1
*MCALL #=    92 LV= 1          RT1   CCL
         DS    0H
RT1_TEST68       BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL68
         LTORG 
RT1_CCL68       DS 0H
*MEXIT #=    92 LV= 1 RT1
* 2A   ADR
         LD    R0,=DH'3'
         LD    R1,=DH'2'
         ADR   R0,R1
*MCALL #=    93 LV= 1          RT1   CCH
         DS    0H
RT1_TEST69       BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH69
         LTORG 
RT1_CCH69       DS 0H
*MEXIT #=    93 LV= 1 RT1
         CD    R0,=DH'5'
*MCALL #=    94 LV= 1          RT1   CCE
         DS    0H
RT1_TEST70       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE70
         LTORG 
RT1_CCE70       DS 0H
*MEXIT #=    94 LV= 1 RT1
         LD    R0,=DH'1'
         LD    R1,=DH'-2'
         ADR   R0,R1
*MCALL #=    95 LV= 1          RT1   CCL
         DS    0H
RT1_TEST71       BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL71
         LTORG 
RT1_CCL71       DS 0H
*MEXIT #=    95 LV= 1 RT1
         CD    R0,=DH'-1'
*MCALL #=    96 LV= 1          RT1   CCE
         DS    0H
RT1_TEST72       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE72
         LTORG 
RT1_CCE72       DS 0H
*MEXIT #=    96 LV= 1 RT1
         LD    R0,=DH'1'
         LD    R1,=DH'-1'
         ADR   R0,R1
*MCALL #=    97 LV= 1          RT1   CCE
         DS    0H
RT1_TEST73       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE73
         LTORG 
RT1_CCE73       DS 0H
*MEXIT #=    97 LV= 1 RT1
         CD    R0,=DH'0'
*MCALL #=    98 LV= 1          RT1   CCE
         DS    0H
RT1_TEST74       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE74
         LTORG 
RT1_CCE74       DS 0H
*MEXIT #=    98 LV= 1 RT1
* 2B   SDR
         LD    R0,=DH'3'
         LD    R1,=DH'2'
         SDR   R0,R1
*MCALL #=    99 LV= 1          RT1   CCH
         DS    0H
RT1_TEST75       BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH75
         LTORG 
RT1_CCH75       DS 0H
*MEXIT #=    99 LV= 1 RT1
         CD    R0,=DH'1'
*MCALL #=   100 LV= 1          RT1   CCE
         DS    0H
RT1_TEST76       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE76
         LTORG 
RT1_CCE76       DS 0H
*MEXIT #=   100 LV= 1 RT1
         LD    R0,=DH'1'
         LD    R1,=DH'2'
         SDR   R0,R1
*MCALL #=   101 LV= 1          RT1   CCL
         DS    0H
RT1_TEST77       BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL77
         LTORG 
RT1_CCL77       DS 0H
*MEXIT #=   101 LV= 1 RT1
         CD    R0,=DH'-1'
*MCALL #=   102 LV= 1          RT1   CCE
         DS    0H
RT1_TEST78       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE78
         LTORG 
RT1_CCE78       DS 0H
*MEXIT #=   102 LV= 1 RT1
         LD    R0,=DH'1'
         LD    R1,=DH'1'
         SDR   R0,R1
*MCALL #=   103 LV= 1          RT1   CCE
         DS    0H
RT1_TEST79       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE79
         LTORG 
RT1_CCE79       DS 0H
*MEXIT #=   103 LV= 1 RT1
         CD    R0,=DH'0'
*MCALL #=   104 LV= 1          RT1   CCE
         DS    0H
RT1_TEST80       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE80
         LTORG 
RT1_CCE80       DS 0H
*MEXIT #=   104 LV= 1 RT1
* 2C   MDR
         LD    R0,=DH'2'
         LD    R1,=DH'3'
         MDR   R0,R1
         CD    R0,=DH'6'
*MCALL #=   105 LV= 1          RT1   CCE
         DS    0H
RT1_TEST81       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE81
         LTORG 
RT1_CCE81       DS 0H
*MEXIT #=   105 LV= 1 RT1
*MCALL #=   106 LV= 1          ESPIE SET,ESPIE_EXIT,12,PARAM=MDR1 HFP OX
               VERFLOW
        LA     15,MDR1
        IPM    0  GET CURRENT PGM MASK
        SPM    0 TURN ON ANY MASKS REQUIRED
        L      0,=B'00000000000010000000000000000000'
        LA     1,ESPIE_EXIT
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   106 LV= 1 ESPIE
         LD    R0,DHMAX
         LD    R1,=DH'2'  RPI 821 MAKE RESULT LARGER THAN DHMAX
         MDR   R0,R1
*MCALL #=   107 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   107 LV= 1 RT1
*MCALL #=   108 LV= 1 MDR1     ESPIE RESET
MDR1     DS    0H
        SR     15,15
        SR     1,1
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   108 LV= 1 ESPIE
* 2D   DDR
         LD    R0,=DH'3'
         LD    R1,=DH'2'
         DDR   R0,R1
         CD    R0,=DH'1.5'
*MCALL #=   109 LV= 1          RT1   CCE
         DS    0H
RT1_TEST83       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE83
         LTORG 
RT1_CCE83       DS 0H
*MEXIT #=   109 LV= 1 RT1
*MCALL #=   110 LV= 1          ESPIE SET,ESPIE_EXIT,15,PARAM=DDR1 HFP DX
               IVIDE
        LA     15,DDR1
        IPM    0  GET CURRENT PGM MASK
        SPM    0 TURN ON ANY MASKS REQUIRED
        L      0,=B'00000000000000010000000000000000'
        LA     1,ESPIE_EXIT
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   110 LV= 1 ESPIE
         LD    R0,=DH'1'
         LD    R1,=DH'0'
         DDR   R0,R1
*MCALL #=   111 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   111 LV= 1 RT1
*MCALL #=   112 LV= 1 DDR1     ESPIE RESET
DDR1     DS    0H
        SR     15,15
        SR     1,1
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   112 LV= 1 ESPIE
* 2E   AWR
         LD    R0,=DH'3'
         LD    R1,=DH'2'
         AWR   R0,R1
*MCALL #=   113 LV= 1          RT1   CCH
         DS    0H
RT1_TEST85       BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH85
         LTORG 
RT1_CCH85       DS 0H
*MEXIT #=   113 LV= 1 RT1
         CD    R0,=DH'5'
*MCALL #=   114 LV= 1          RT1   CCE
         DS    0H
RT1_TEST86       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE86
         LTORG 
RT1_CCE86       DS 0H
*MEXIT #=   114 LV= 1 RT1
         LD    R0,=DH'1'
         LD    R1,=DH'-2'
         AWR   R0,R1
*MCALL #=   115 LV= 1          RT1   CCL
         DS    0H
RT1_TEST87       BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL87
         LTORG 
RT1_CCL87       DS 0H
*MEXIT #=   115 LV= 1 RT1
         CD    R0,=DH'-1'
*MCALL #=   116 LV= 1          RT1   CCE
         DS    0H
RT1_TEST88       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE88
         LTORG 
RT1_CCE88       DS 0H
*MEXIT #=   116 LV= 1 RT1
         LD    R0,=DH'1'
         LD    R1,=DH'-1'
         AWR   R0,R1
*MCALL #=   117 LV= 1          RT1   CCE
         DS    0H
RT1_TEST89       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE89
         LTORG 
RT1_CCE89       DS 0H
*MEXIT #=   117 LV= 1 RT1
         CD    R0,=DH'0'
*MCALL #=   118 LV= 1          RT1   CCE
         DS    0H
RT1_TEST90       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE90
         LTORG 
RT1_CCE90       DS 0H
*MEXIT #=   118 LV= 1 RT1
         LD    F0,=DH'1'
         LD    F1,=X'4E00000000000000'
         AWR   F0,R1
         STD   F0,DWORD
         CLC   DWORD,=X'4E00000000000001'
*MCALL #=   119 LV= 1          RT1   CCE
         DS    0H
RT1_TEST91       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE91
         LTORG 
RT1_CCE91       DS 0H
*MEXIT #=   119 LV= 1 RT1
* 2F   SWR
         LD    R0,=DH'3'
         LD    R1,=DH'2'
         SWR   R0,R1
*MCALL #=   120 LV= 1          RT1   CCH
         DS    0H
RT1_TEST92       BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH92
         LTORG 
RT1_CCH92       DS 0H
*MEXIT #=   120 LV= 1 RT1
         CD    R0,=DH'1'
*MCALL #=   121 LV= 1          RT1   CCE
         DS    0H
RT1_TEST93       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE93
         LTORG 
RT1_CCE93       DS 0H
*MEXIT #=   121 LV= 1 RT1
         LD    R0,=DH'1'
         LD    R1,=DH'2'
         SWR   R0,R1
*MCALL #=   122 LV= 1          RT1   CCL
         DS    0H
RT1_TEST94       BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL94
         LTORG 
RT1_CCL94       DS 0H
*MEXIT #=   122 LV= 1 RT1
         CD    R0,=DH'-1'
*MCALL #=   123 LV= 1          RT1   CCE
         DS    0H
RT1_TEST95       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE95
         LTORG 
RT1_CCE95       DS 0H
*MEXIT #=   123 LV= 1 RT1
         LD    R0,=DH'1'
         LD    R1,=DH'1'
         SWR   R0,R1
*MCALL #=   124 LV= 1          RT1   CCE
         DS    0H
RT1_TEST96       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE96
         LTORG 
RT1_CCE96       DS 0H
*MEXIT #=   124 LV= 1 RT1
         CD    R0,=DH'0'
*MCALL #=   125 LV= 1          RT1   CCE
         DS    0H
RT1_TEST97       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE97
         LTORG 
RT1_CCE97       DS 0H
*MEXIT #=   125 LV= 1 RT1
         LD    F0,=DH'1'
         LD    F1,=X'4E00000000000000'
         SWR   F0,R1
         STD   F0,DWORD
         CLC   DWORD,=X'4E00000000000001'
*MCALL #=   126 LV= 1          RT1   CCE
         DS    0H
RT1_TEST98       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE98
         LTORG 
RT1_CCE98       DS 0H
*MEXIT #=   126 LV= 1 RT1
* 30   LPER
         LE    R1,=EH'-1'
         LE    R2,=EH'1'
         LPER  R0,R1
*MCALL #=   127 LV= 1          RT1   CCH
         DS    0H
RT1_TEST99       BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH99
         LTORG 
RT1_CCH99       DS 0H
*MEXIT #=   127 LV= 1 RT1
         CER   R0,R2
*MCALL #=   128 LV= 1          RT1   CCE
         DS    0H
RT1_TEST100      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE100
         LTORG 
RT1_CCE100      DS 0H
*MEXIT #=   128 LV= 1 RT1
         LE    R1,=EH'0'
         LE    R2,=EH'0'
         LPER  R0,R1
*MCALL #=   129 LV= 1          RT1   CCE
         DS    0H
RT1_TEST101      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE101
         LTORG 
RT1_CCE101      DS 0H
*MEXIT #=   129 LV= 1 RT1
         CER   R0,R2
*MCALL #=   130 LV= 1          RT1   CCE
         DS    0H
RT1_TEST102      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE102
         LTORG 
RT1_CCE102      DS 0H
*MEXIT #=   130 LV= 1 RT1
* 31   LNER
         LE    R1,=EH'1'
         LE    R2,=EH'-1'
         LNER  R0,R1
*MCALL #=   131 LV= 1          RT1   CCL
         DS    0H
RT1_TEST103      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL103
         LTORG 
RT1_CCL103      DS 0H
*MEXIT #=   131 LV= 1 RT1
         CER   R0,R2
*MCALL #=   132 LV= 1          RT1   CCE
         DS    0H
RT1_TEST104      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE104
         LTORG 
RT1_CCE104      DS 0H
*MEXIT #=   132 LV= 1 RT1
         LE    R1,=EH'0'
         LE    R2,=EH'0'
         LNER  R0,R1
*MCALL #=   133 LV= 1          RT1   CCE
         DS    0H
RT1_TEST105      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE105
         LTORG 
RT1_CCE105      DS 0H
*MEXIT #=   133 LV= 1 RT1
         CER   R0,R2
*MCALL #=   134 LV= 1          RT1   CCE
         DS    0H
RT1_TEST106      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE106
         LTORG 
RT1_CCE106      DS 0H
*MEXIT #=   134 LV= 1 RT1
* 32   LTER
         LE    R1,=EH'1'
         LE    R2,=EH'1'
         LTER  R0,R1
*MCALL #=   135 LV= 1          RT1   CCH
         DS    0H
RT1_TEST107      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH107
         LTORG 
RT1_CCH107      DS 0H
*MEXIT #=   135 LV= 1 RT1
         CER   R0,R2
*MCALL #=   136 LV= 1          RT1   CCE
         DS    0H
RT1_TEST108      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE108
         LTORG 
RT1_CCE108      DS 0H
*MEXIT #=   136 LV= 1 RT1
         LE    R1,=EH'0'
         LE    R2,=EH'0'
         LTER  R0,R1
*MCALL #=   137 LV= 1          RT1   CCE
         DS    0H
RT1_TEST109      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE109
         LTORG 
RT1_CCE109      DS 0H
*MEXIT #=   137 LV= 1 RT1
         CER   R0,R2
*MCALL #=   138 LV= 1          RT1   CCE
         DS    0H
RT1_TEST110      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE110
         LTORG 
RT1_CCE110      DS 0H
*MEXIT #=   138 LV= 1 RT1
         LE    R1,=EH'-1'
         LE    R2,=EH'-1'
         LTER  R0,R1
*MCALL #=   139 LV= 1          RT1   CCL
         DS    0H
RT1_TEST111      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL111
         LTORG 
RT1_CCL111      DS 0H
*MEXIT #=   139 LV= 1 RT1
         CER   R0,R2
*MCALL #=   140 LV= 1          RT1   CCE
         DS    0H
RT1_TEST112      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE112
         LTORG 
RT1_CCE112      DS 0H
*MEXIT #=   140 LV= 1 RT1
* 33   LCER
         LE    R1,=EH'-1'
         LE    R2,=EH'1'
         LCER  R0,R1
*MCALL #=   141 LV= 1          RT1   CCH
         DS    0H
RT1_TEST113      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH113
         LTORG 
RT1_CCH113      DS 0H
*MEXIT #=   141 LV= 1 RT1
         CER   R0,R2
*MCALL #=   142 LV= 1          RT1   CCE
         DS    0H
RT1_TEST114      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE114
         LTORG 
RT1_CCE114      DS 0H
*MEXIT #=   142 LV= 1 RT1
         LE    R1,=EH'0'
         LE    R2,=EH'0'
         LCER  R0,R1
*MCALL #=   143 LV= 1          RT1   CCE
         DS    0H
RT1_TEST115      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE115
         LTORG 
RT1_CCE115      DS 0H
*MEXIT #=   143 LV= 1 RT1
         CER   R0,R2
*MCALL #=   144 LV= 1          RT1   CCE
         DS    0H
RT1_TEST116      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE116
         LTORG 
RT1_CCE116      DS 0H
*MEXIT #=   144 LV= 1 RT1
         LE    R1,=EH'1'
         LE    R2,=EH'-1'
         LCER  R0,R1
*MCALL #=   145 LV= 1          RT1   CCL
         DS    0H
RT1_TEST117      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL117
         LTORG 
RT1_CCL117      DS 0H
*MEXIT #=   145 LV= 1 RT1
         CER   R0,R2
*MCALL #=   146 LV= 1          RT1   CCE
         DS    0H
RT1_TEST118      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE118
         LTORG 
RT1_CCE118      DS 0H
*MEXIT #=   146 LV= 1 RT1
* 34   HER
         LE    R1,=EH'2'
         LE    R2,=EH'1'
         HER   R0,R1
         CER   R0,R2
*MCALL #=   147 LV= 1          RT1   CCE
         DS    0H
RT1_TEST119      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE119
         LTORG 
RT1_CCE119      DS 0H
*MEXIT #=   147 LV= 1 RT1
         LE    R1,=EH'0'
         LE    R2,=EH'0'
         HER   R0,R1
         CER   R0,R2
*MCALL #=   148 LV= 1          RT1   CCE
         DS    0H
RT1_TEST120      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE120
         LTORG 
RT1_CCE120      DS 0H
*MEXIT #=   148 LV= 1 RT1
         LE    R1,=EH'-2'
         LE    R2,=EH'-1'
         HER   R0,R1
         CER   R0,R2
*MCALL #=   149 LV= 1          RT1   CCE
         DS    0H
RT1_TEST121      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE121
         LTORG 
RT1_CCE121      DS 0H
*MEXIT #=   149 LV= 1 RT1
* 35   LEDR
         LD    R1,=DH'123'
         LEDR  R0,R1
         CE    R0,=EH'123'
*MCALL #=   150 LV= 1          RT1   CCE
         DS    0H
RT1_TEST122      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE122
         LTORG 
RT1_CCE122      DS 0H
*MEXIT #=   150 LV= 1 RT1
* 36   AXR
*MCALL #=   151 LV= 1          LX    R0,=LH'1'
         LA    15,=LH'1'
         LD    R0,0(15)
         LD    R0+2,8(15)  RPI 229
*MEXIT #=   151 LV= 1 LX
*MCALL #=   152 LV= 1          LX    R1,=LH'2'
         LA    15,=LH'2'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   152 LV= 1 LX
*MCALL #=   153 LV= 1          LX    R4,=LH'3'
         LA    15,=LH'3'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   153 LV= 1 LX
         AXR   R0,R1
*MCALL #=   154 LV= 1          RT1   CCH
         DS    0H
RT1_TEST123      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH123
         LTORG 
RT1_CCH123      DS 0H
*MEXIT #=   154 LV= 1 RT1
         CXR   R0,R4
*MCALL #=   155 LV= 1          RT1   CCE
         DS    0H
RT1_TEST124      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE124
         LTORG 
RT1_CCE124      DS 0H
*MEXIT #=   155 LV= 1 RT1
*MCALL #=   156 LV= 1          LX    R0,=LH'1'
         LA    15,=LH'1'
         LD    R0,0(15)
         LD    R0+2,8(15)  RPI 229
*MEXIT #=   156 LV= 1 LX
*MCALL #=   157 LV= 1          LX    R1,=LH'-2'
         LA    15,=LH'-2'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   157 LV= 1 LX
*MCALL #=   158 LV= 1          LX    R4,=LH'-1'
         LA    15,=LH'-1'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   158 LV= 1 LX
         AXR   R0,R1
*MCALL #=   159 LV= 1          RT1   CCL
         DS    0H
RT1_TEST125      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL125
         LTORG 
RT1_CCL125      DS 0H
*MEXIT #=   159 LV= 1 RT1
         CXR   R0,R4
*MCALL #=   160 LV= 1          RT1   CCE
         DS    0H
RT1_TEST126      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE126
         LTORG 
RT1_CCE126      DS 0H
*MEXIT #=   160 LV= 1 RT1
*MCALL #=   161 LV= 1          LX    R0,=LH'-1'
         LA    15,=LH'-1'
         LD    R0,0(15)
         LD    R0+2,8(15)  RPI 229
*MEXIT #=   161 LV= 1 LX
*MCALL #=   162 LV= 1          LX    R1,=LH'1'
         LA    15,=LH'1'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   162 LV= 1 LX
*MCALL #=   163 LV= 1          LX    R4,=LH'0'
         LA    15,=LH'0'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   163 LV= 1 LX
         AXR   R0,R1
*MCALL #=   164 LV= 1          RT1   CCE
         DS    0H
RT1_TEST127      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE127
         LTORG 
RT1_CCE127      DS 0H
*MEXIT #=   164 LV= 1 RT1
         CXR   R0,R4
*MCALL #=   165 LV= 1          RT1   CCE
         DS    0H
RT1_TEST128      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE128
         LTORG 
RT1_CCE128      DS 0H
*MEXIT #=   165 LV= 1 RT1
*MCALL #=   166 LV= 1          LX    R0,=LH'3'   RPI 824 TEST START
         LA    15,=LH'3'
         LD    R0,0(15)
         LD    R0+2,8(15)  RPI 229
*MEXIT #=   166 LV= 1 LX
         AXR   R0,R0          R0,R2 = PAIR = LH'6'
         SDR   2,2            R2    = DH'0' FLUSHING R1,R2 FIRST
         LD    R1,=DH'6'
         CDR   R0,R1
*MCALL #=   167 LV= 1          RT1   CCE         RPI 824 VERIFY R0 HAS X
               FIRST HALF OF LH'6'
         DS    0H
RT1_TEST129      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE129
         LTORG 
RT1_CCE129      DS 0H
*MEXIT #=   167 LV= 1 RT1
*MCALL #=   168 LV= 1          LX    0,=X'4E000000000000000000000000000X
               001' RPI 821 TEST LH
         LA    15,=X'4E000000000000000000000000000001'
         LD    0,0(15)
         LD    0+2,8(15)  RPI 229
*MEXIT #=   168 LV= 1 LX
*MCALL #=   169 LV= 1          LX    1,=X'4E800000000000000000000000000X
               000' HFP PRECISION
         LA    15,=X'4E800000000000000000000000000000'
         LD    1,0(15)
         LD    1+2,8(15)  RPI 229
*MEXIT #=   169 LV= 1 LX
         AXR   0,1
*MCALL #=   170 LV= 1          STX   0,LWORK
         LA    15,LWORK
         STD   0,0(15)
         STD   0+2,8(15)  RPI 229
*MEXIT #=   170 LV= 1 STX
*MCALL #=   171 LV= 1          RT1   CCE,LWORK,=X'4E8000000000000040000X
               00000000001'
         DS    0H
         CLC   LWORK,=X'4E800000000000004000000000000001'
RT1_TEST130      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE130
         LTORG 
RT1_CCE130      DS 0H
*MEXIT #=   171 LV= 1 RT1
* 37   SXR
*MCALL #=   172 LV= 1          LX    R0,=LH'1'
         LA    15,=LH'1'
         LD    R0,0(15)
         LD    R0+2,8(15)  RPI 229
*MEXIT #=   172 LV= 1 LX
*MCALL #=   173 LV= 1          LX    R1,=LH'-2'
         LA    15,=LH'-2'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   173 LV= 1 LX
*MCALL #=   174 LV= 1          LX    R4,=LH'3'
         LA    15,=LH'3'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   174 LV= 1 LX
         SXR   R0,R1
*MCALL #=   175 LV= 1          RT1   CCH
         DS    0H
RT1_TEST131      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH131
         LTORG 
RT1_CCH131      DS 0H
*MEXIT #=   175 LV= 1 RT1
         CXR   R0,R4
*MCALL #=   176 LV= 1          RT1   CCE
         DS    0H
RT1_TEST132      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE132
         LTORG 
RT1_CCE132      DS 0H
*MEXIT #=   176 LV= 1 RT1
*MCALL #=   177 LV= 1          LX    R0,=LH'1'
         LA    15,=LH'1'
         LD    R0,0(15)
         LD    R0+2,8(15)  RPI 229
*MEXIT #=   177 LV= 1 LX
*MCALL #=   178 LV= 1          LX    R1,=LH'2'
         LA    15,=LH'2'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   178 LV= 1 LX
*MCALL #=   179 LV= 1          LX    R4,=LH'-1'
         LA    15,=LH'-1'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   179 LV= 1 LX
         SXR   R0,R1
*MCALL #=   180 LV= 1          RT1   CCL
         DS    0H
RT1_TEST133      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL133
         LTORG 
RT1_CCL133      DS 0H
*MEXIT #=   180 LV= 1 RT1
         CXR   R0,R4
*MCALL #=   181 LV= 1          RT1   CCE
         DS    0H
RT1_TEST134      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE134
         LTORG 
RT1_CCE134      DS 0H
*MEXIT #=   181 LV= 1 RT1
*MCALL #=   182 LV= 1          LX    R0,=LH'1'
         LA    15,=LH'1'
         LD    R0,0(15)
         LD    R0+2,8(15)  RPI 229
*MEXIT #=   182 LV= 1 LX
*MCALL #=   183 LV= 1          LX    R1,=LH'1'
         LA    15,=LH'1'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   183 LV= 1 LX
*MCALL #=   184 LV= 1          LX    R4,=LH'0'
         LA    15,=LH'0'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   184 LV= 1 LX
         SXR   R0,R1
*MCALL #=   185 LV= 1          RT1   CCE
         DS    0H
RT1_TEST135      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE135
         LTORG 
RT1_CCE135      DS 0H
*MEXIT #=   185 LV= 1 RT1
         CXR   R0,R4
*MCALL #=   186 LV= 1          RT1   CCE
         DS    0H
RT1_TEST136      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE136
         LTORG 
RT1_CCE136      DS 0H
*MEXIT #=   186 LV= 1 RT1
* 38   LER
         LE    R1,=EH'123'
         LER   R0,R1
         CE    R0,=EH'123'
*MCALL #=   187 LV= 1          RT1   CCE
         DS    0H
RT1_TEST137      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE137
         LTORG 
RT1_CCE137      DS 0H
*MEXIT #=   187 LV= 1 RT1
* 39   CER
         LE    R0,=EH'1'
         LE    R1,=EH'-2'
         CER   R0,R1
*MCALL #=   188 LV= 1          RT1   CCH
         DS    0H
RT1_TEST138      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH138
         LTORG 
RT1_CCH138      DS 0H
*MEXIT #=   188 LV= 1 RT1
         LE    R0,=EH'2'
         LE    R1,=EH'2'
         CER   R0,R1
*MCALL #=   189 LV= 1          RT1   CCE
         DS    0H
RT1_TEST139      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE139
         LTORG 
RT1_CCE139      DS 0H
*MEXIT #=   189 LV= 1 RT1
         LE    R0,=EH'-2'
         LE    R1,=EH'4'
         CER   R0,R1
*MCALL #=   190 LV= 1          RT1   CCL
         DS    0H
RT1_TEST140      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL140
         LTORG 
RT1_CCL140      DS 0H
*MEXIT #=   190 LV= 1 RT1
* 3A   AER
         LE    R0,=EH'3'
         LE    R1,=EH'2'
         AER   R0,R1
*MCALL #=   191 LV= 1          RT1   CCH
         DS    0H
RT1_TEST141      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH141
         LTORG 
RT1_CCH141      DS 0H
*MEXIT #=   191 LV= 1 RT1
         CE    R0,=EH'5'
*MCALL #=   192 LV= 1          RT1   CCE
         DS    0H
RT1_TEST142      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE142
         LTORG 
RT1_CCE142      DS 0H
*MEXIT #=   192 LV= 1 RT1
         LE    R0,=EH'1'
         LE    R1,=EH'-2'
         AER   R0,R1
*MCALL #=   193 LV= 1          RT1   CCL
         DS    0H
RT1_TEST143      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL143
         LTORG 
RT1_CCL143      DS 0H
*MEXIT #=   193 LV= 1 RT1
         CE    R0,=EH'-1'
*MCALL #=   194 LV= 1          RT1   CCE
         DS    0H
RT1_TEST144      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE144
         LTORG 
RT1_CCE144      DS 0H
*MEXIT #=   194 LV= 1 RT1
         LE    R0,=EH'1'
         LE    R1,=EH'-1'
         AER   R0,R1
*MCALL #=   195 LV= 1          RT1   CCE
         DS    0H
RT1_TEST145      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE145
         LTORG 
RT1_CCE145      DS 0H
*MEXIT #=   195 LV= 1 RT1
         CE    R0,=EH'0'
*MCALL #=   196 LV= 1          RT1   CCE
         DS    0H
RT1_TEST146      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE146
         LTORG 
RT1_CCE146      DS 0H
*MEXIT #=   196 LV= 1 RT1
* 3B   SER
         LE    R0,=EH'3'
         LE    R1,=EH'2'
         SER   R0,R1
*MCALL #=   197 LV= 1          RT1   CCH
         DS    0H
RT1_TEST147      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH147
         LTORG 
RT1_CCH147      DS 0H
*MEXIT #=   197 LV= 1 RT1
         CE    R0,=EH'1'
*MCALL #=   198 LV= 1          RT1   CCE
         DS    0H
RT1_TEST148      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE148
         LTORG 
RT1_CCE148      DS 0H
*MEXIT #=   198 LV= 1 RT1
         LE    R0,=EH'1'
         LE    R1,=EH'2'
         SER   R0,R1
*MCALL #=   199 LV= 1          RT1   CCL
         DS    0H
RT1_TEST149      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL149
         LTORG 
RT1_CCL149      DS 0H
*MEXIT #=   199 LV= 1 RT1
         CE    R0,=EH'-1'
*MCALL #=   200 LV= 1          RT1   CCE
         DS    0H
RT1_TEST150      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE150
         LTORG 
RT1_CCE150      DS 0H
*MEXIT #=   200 LV= 1 RT1
         LE    R0,=EH'1'
         LE    R1,=EH'1'
         SER   R0,R1
*MCALL #=   201 LV= 1          RT1   CCE
         DS    0H
RT1_TEST151      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE151
         LTORG 
RT1_CCE151      DS 0H
*MEXIT #=   201 LV= 1 RT1
         CE    R0,=EH'0'
*MCALL #=   202 LV= 1          RT1   CCE
         DS    0H
RT1_TEST152      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE152
         LTORG 
RT1_CCE152      DS 0H
*MEXIT #=   202 LV= 1 RT1
* 3C   MDER
         LE    R0,=EH'2'
         LE    R1,=EH'3'
         MDER  R0,R1
         CD    R0,=DH'6'
*MCALL #=   203 LV= 1          RT1   CCE
         DS    0H
RT1_TEST153      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE153
         LTORG 
RT1_CCE153      DS 0H
*MEXIT #=   203 LV= 1 RT1
* 3D   DER
         LE    R0,=EH'3'
         LE    R1,=EH'2'
         DER   R0,R1
         CE    R0,=EH'1.5'
*MCALL #=   204 LV= 1          RT1   CCE
         DS    0H
RT1_TEST154      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE154
         LTORG 
RT1_CCE154      DS 0H
*MEXIT #=   204 LV= 1 RT1
*MCALL #=   205 LV= 1          ESPIE SET,ESPIE_EXIT,15,PARAM=DER1 HFP DX
               IVIDE
        LA     15,DER1
        IPM    0  GET CURRENT PGM MASK
        SPM    0 TURN ON ANY MASKS REQUIRED
        L      0,=B'00000000000000010000000000000000'
        LA     1,ESPIE_EXIT
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   205 LV= 1 ESPIE
         LE    R0,=EH'1'
         LE    R1,=EH'0'
         DER   R0,R1
*MCALL #=   206 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   206 LV= 1 RT1
*MCALL #=   207 LV= 1 DER1     ESPIE RESET
DER1     DS    0H
        SR     15,15
        SR     1,1
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   207 LV= 1 ESPIE
* 3E   AUR
         LE    R0,=EH'3'
         LE    R1,=EH'2'
         AUR   R0,R1
*MCALL #=   208 LV= 1          RT1   CCH
         DS    0H
RT1_TEST156      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH156
         LTORG 
RT1_CCH156      DS 0H
*MEXIT #=   208 LV= 1 RT1
         CE    R0,=EH'5'
*MCALL #=   209 LV= 1          RT1   CCE
         DS    0H
RT1_TEST157      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE157
         LTORG 
RT1_CCE157      DS 0H
*MEXIT #=   209 LV= 1 RT1
         LE    R0,=EH'1'
         LE    R1,=EH'-2'
         AUR   R0,R1
*MCALL #=   210 LV= 1          RT1   CCL
         DS    0H
RT1_TEST158      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL158
         LTORG 
RT1_CCL158      DS 0H
*MEXIT #=   210 LV= 1 RT1
         CE    R0,=EH'-1'
*MCALL #=   211 LV= 1          RT1   CCE
         DS    0H
RT1_TEST159      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE159
         LTORG 
RT1_CCE159      DS 0H
*MEXIT #=   211 LV= 1 RT1
         LE    R0,=EH'1'
         LE    R1,=EH'-1'
         AUR   R0,R1
*MCALL #=   212 LV= 1          RT1   CCE
         DS    0H
RT1_TEST160      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE160
         LTORG 
RT1_CCE160      DS 0H
*MEXIT #=   212 LV= 1 RT1
         CE    R0,=EH'0'
*MCALL #=   213 LV= 1          RT1   CCE
         DS    0H
RT1_TEST161      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE161
         LTORG 
RT1_CCE161      DS 0H
*MEXIT #=   213 LV= 1 RT1
         LE    F0,=EH'1'
         LE    F1,=X'46000000'
         AUR   F0,F1
         STD   F0,WORD
         CLC   WORD,=X'46000001'
*MCALL #=   214 LV= 1          RT1   CCE
         DS    0H
RT1_TEST162      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE162
         LTORG 
RT1_CCE162      DS 0H
*MEXIT #=   214 LV= 1 RT1
* 3F   SUR
         LE    R0,=EH'3'
         LE    R1,=EH'2'
         SUR   R0,R1
*MCALL #=   215 LV= 1          RT1   CCH
         DS    0H
RT1_TEST163      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH163
         LTORG 
RT1_CCH163      DS 0H
*MEXIT #=   215 LV= 1 RT1
         CE    R0,=EH'1'
*MCALL #=   216 LV= 1          RT1   CCE
         DS    0H
RT1_TEST164      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE164
         LTORG 
RT1_CCE164      DS 0H
*MEXIT #=   216 LV= 1 RT1
         LE    R0,=EH'1'
         LE    R1,=EH'2'
         SUR   R0,R1
*MCALL #=   217 LV= 1          RT1   CCL
         DS    0H
RT1_TEST165      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL165
         LTORG 
RT1_CCL165      DS 0H
*MEXIT #=   217 LV= 1 RT1
         CE    R0,=EH'-1'
*MCALL #=   218 LV= 1          RT1   CCE
         DS    0H
RT1_TEST166      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE166
         LTORG 
RT1_CCE166      DS 0H
*MEXIT #=   218 LV= 1 RT1
         LE    R0,=EH'1'
         LE    R1,=EH'1'
         SUR   R0,R1
*MCALL #=   219 LV= 1          RT1   CCE
         DS    0H
RT1_TEST167      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE167
         LTORG 
RT1_CCE167      DS 0H
*MEXIT #=   219 LV= 1 RT1
         CE    R0,=EH'0'
*MCALL #=   220 LV= 1          RT1   CCE
         DS    0H
RT1_TEST168      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE168
         LTORG 
RT1_CCE168      DS 0H
*MEXIT #=   220 LV= 1 RT1
         LE    F0,=EH'1'
         LE    F1,=X'46000000'
         AUR   F0,F1
         STD   F0,WORD
         CLC   WORD,=X'46000001'
*MCALL #=   221 LV= 1          RT1   CCE
         DS    0H
RT1_TEST169      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE169
         LTORG 
RT1_CCE169      DS 0H
*MEXIT #=   221 LV= 1 RT1
* 60   STD
         LD    R0,=DH'1'
         STD   R0,DWORD
         CLC   DWORD,=X'4110000000000000'
*MCALL #=   222 LV= 1          RT1   CCE
         DS    0H
RT1_TEST170      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE170
         LTORG 
RT1_CCE170      DS 0H
*MEXIT #=   222 LV= 1 RT1
* 67   MXD
         LD    R0,=DH'2'
         MXD   R0,=DH'3'
*MCALL #=   223 LV= 1          LX    R1,=LH'6'
         LA    15,=LH'6'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   223 LV= 1 LX
         CXR   R0,R1
*MCALL #=   224 LV= 1          RT1   CCE
         DS    0H
RT1_TEST171      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE171
         LTORG 
RT1_CCE171      DS 0H
*MEXIT #=   224 LV= 1 RT1
* 68   LD
         LD    R0,=DH'1'
         AD    R0,=DH'1'
*MCALL #=   225 LV= 1          RT1   CCH
         DS    0H
RT1_TEST172      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH172
         LTORG 
RT1_CCH172      DS 0H
*MEXIT #=   225 LV= 1 RT1
         STD   R0,DWORD
         CLC   DWORD,=X'4120000000000000'
*MCALL #=   226 LV= 1          RT1   CCE
         DS    0H
RT1_TEST173      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE173
         LTORG 
RT1_CCE173      DS 0H
*MEXIT #=   226 LV= 1 RT1
* 69   CD
         LD    R0,=DH'1'
         CD    R0,=X'4110000000000000'
*MCALL #=   227 LV= 1          RT1   CCE
         DS    0H
RT1_TEST174      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE174
         LTORG 
RT1_CCE174      DS 0H
*MEXIT #=   227 LV= 1 RT1
         LD    R0,=DH'-1'
         CD    R0,=DH'0'
*MCALL #=   228 LV= 1          RT1   CCL
         DS    0H
RT1_TEST175      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL175
         LTORG 
RT1_CCL175      DS 0H
*MEXIT #=   228 LV= 1 RT1
         LD    R0,=DH'1'
         CD    R0,=DH'0'
*MCALL #=   229 LV= 1          RT1   CCH
         DS    0H
RT1_TEST176      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH176
         LTORG 
RT1_CCH176      DS 0H
*MEXIT #=   229 LV= 1 RT1
* 6A   AD
         LD    R0,=DH'3'
         AD    R0,=DH'2'
*MCALL #=   230 LV= 1          RT1   CCH
         DS    0H
RT1_TEST177      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH177
         LTORG 
RT1_CCH177      DS 0H
*MEXIT #=   230 LV= 1 RT1
         CD    R0,=DH'5'
*MCALL #=   231 LV= 1          RT1   CCE
         DS    0H
RT1_TEST178      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE178
         LTORG 
RT1_CCE178      DS 0H
*MEXIT #=   231 LV= 1 RT1
         LD    R0,=DH'1'
         AD    R0,=DH'-2'
*MCALL #=   232 LV= 1          RT1   CCL
         DS    0H
RT1_TEST179      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL179
         LTORG 
RT1_CCL179      DS 0H
*MEXIT #=   232 LV= 1 RT1
         CD    R0,=DH'-1'
*MCALL #=   233 LV= 1          RT1   CCE
         DS    0H
RT1_TEST180      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE180
         LTORG 
RT1_CCE180      DS 0H
*MEXIT #=   233 LV= 1 RT1
         LD    R0,=DH'1'
         AD    R0,=DH'-1'
*MCALL #=   234 LV= 1          RT1   CCE
         DS    0H
RT1_TEST181      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE181
         LTORG 
RT1_CCE181      DS 0H
*MEXIT #=   234 LV= 1 RT1
         CD    R0,=DH'0'
*MCALL #=   235 LV= 1          RT1   CCE
         DS    0H
RT1_TEST182      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE182
         LTORG 
RT1_CCE182      DS 0H
*MEXIT #=   235 LV= 1 RT1
         LD    0,=X'4E00000000000001' RPI 821 TEST 56 BIT PRECISION
         AD    0,=X'4E80000000000000' HFP WITH UNIT AS LAST DIGIT
         STD   0,DWORD
*MCALL #=   236 LV= 1          RT1   CCE,DWORD,=X'4E80000000000001'
         DS    0H
         CLC   DWORD,=X'4E80000000000001'
RT1_TEST183      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE183
         LTORG 
RT1_CCE183      DS 0H
*MEXIT #=   236 LV= 1 RT1
* 6B   SD
         LD    R0,=DH'3'
         SD    R0,=DH'2'
*MCALL #=   237 LV= 1          RT1   CCH
         DS    0H
RT1_TEST184      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH184
         LTORG 
RT1_CCH184      DS 0H
*MEXIT #=   237 LV= 1 RT1
         CD    R0,=DH'1'
*MCALL #=   238 LV= 1          RT1   CCE
         DS    0H
RT1_TEST185      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE185
         LTORG 
RT1_CCE185      DS 0H
*MEXIT #=   238 LV= 1 RT1
         LD    R0,=DH'1'
         SD    R0,=DH'2'
*MCALL #=   239 LV= 1          RT1   CCL
         DS    0H
RT1_TEST186      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL186
         LTORG 
RT1_CCL186      DS 0H
*MEXIT #=   239 LV= 1 RT1
         CD    R0,=DH'-1'
*MCALL #=   240 LV= 1          RT1   CCE
         DS    0H
RT1_TEST187      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE187
         LTORG 
RT1_CCE187      DS 0H
*MEXIT #=   240 LV= 1 RT1
         LD    R0,=DH'1'
         SD    R0,=DH'1'
*MCALL #=   241 LV= 1          RT1   CCE
         DS    0H
RT1_TEST188      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE188
         LTORG 
RT1_CCE188      DS 0H
*MEXIT #=   241 LV= 1 RT1
         CD    R0,=DH'0'
*MCALL #=   242 LV= 1          RT1   CCE
         DS    0H
RT1_TEST189      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE189
         LTORG 
RT1_CCE189      DS 0H
*MEXIT #=   242 LV= 1 RT1
* 6C   MD
         LD    R0,=DH'2'
         MD    R0,=DH'3'
         CD    R0,=DH'6'
*MCALL #=   243 LV= 1          RT1   CCE
         DS    0H
RT1_TEST190      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE190
         LTORG 
RT1_CCE190      DS 0H
*MEXIT #=   243 LV= 1 RT1
* 6D   DD
         LD    R0,=DH'3'
         DD    R0,=DH'2'
         CD    R0,=DH'1.5'
*MCALL #=   244 LV= 1          RT1   CCE
         DS    0H
RT1_TEST191      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE191
         LTORG 
RT1_CCE191      DS 0H
*MEXIT #=   244 LV= 1 RT1
*MCALL #=   245 LV= 1          ESPIE SET,ESPIE_EXIT,15,PARAM=DD1 HFP DIX
               VIDE
        LA     15,DD1
        IPM    0  GET CURRENT PGM MASK
        SPM    0 TURN ON ANY MASKS REQUIRED
        L      0,=B'00000000000000010000000000000000'
        LA     1,ESPIE_EXIT
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   245 LV= 1 ESPIE
         LD    R0,=DH'1'
         DD    R0,=DH'0'
*MCALL #=   246 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   246 LV= 1 RT1
*MCALL #=   247 LV= 1 DD1      ESPIE RESET
DD1      DS    0H
        SR     15,15
        SR     1,1
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   247 LV= 1 ESPIE
* 6E   AW
         LD    R0,=DH'3'
         AW    R0,=DH'2'
*MCALL #=   248 LV= 1          RT1   CCH
         DS    0H
RT1_TEST193      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH193
         LTORG 
RT1_CCH193      DS 0H
*MEXIT #=   248 LV= 1 RT1
         CD    R0,=DH'5'
*MCALL #=   249 LV= 1          RT1   CCE
         DS    0H
RT1_TEST194      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE194
         LTORG 
RT1_CCE194      DS 0H
*MEXIT #=   249 LV= 1 RT1
         LD    R0,=DH'1'
         AW    R0,=DH'-2'
*MCALL #=   250 LV= 1          RT1   CCL
         DS    0H
RT1_TEST195      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL195
         LTORG 
RT1_CCL195      DS 0H
*MEXIT #=   250 LV= 1 RT1
         CD    R0,=DH'-1'
*MCALL #=   251 LV= 1          RT1   CCE
         DS    0H
RT1_TEST196      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE196
         LTORG 
RT1_CCE196      DS 0H
*MEXIT #=   251 LV= 1 RT1
         LD    R0,=DH'1'
         AW    R0,=DH'-1'
*MCALL #=   252 LV= 1          RT1   CCE
         DS    0H
RT1_TEST197      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE197
         LTORG 
RT1_CCE197      DS 0H
*MEXIT #=   252 LV= 1 RT1
         CD    R0,=DH'0'
*MCALL #=   253 LV= 1          RT1   CCE
         DS    0H
RT1_TEST198      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE198
         LTORG 
RT1_CCE198      DS 0H
*MEXIT #=   253 LV= 1 RT1
         LD    F0,=DH'1'
         AW    F0,=X'4E00000000000000'
         STD   F0,DWORD
         CLC   DWORD,=X'4E00000000000001'
*MCALL #=   254 LV= 1          RT1   CCE
         DS    0H
RT1_TEST199      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE199
         LTORG 
RT1_CCE199      DS 0H
*MEXIT #=   254 LV= 1 RT1
* 6F   SW
         LD    R0,=DH'3'
         SW    R0,=DH'2'
*MCALL #=   255 LV= 1          RT1   CCH
         DS    0H
RT1_TEST200      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH200
         LTORG 
RT1_CCH200      DS 0H
*MEXIT #=   255 LV= 1 RT1
         CD    R0,=DH'1'
*MCALL #=   256 LV= 1          RT1   CCE
         DS    0H
RT1_TEST201      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE201
         LTORG 
RT1_CCE201      DS 0H
*MEXIT #=   256 LV= 1 RT1
         LD    R0,=DH'1'
         SW    R0,=DH'2'
*MCALL #=   257 LV= 1          RT1   CCL
         DS    0H
RT1_TEST202      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL202
         LTORG 
RT1_CCL202      DS 0H
*MEXIT #=   257 LV= 1 RT1
         CD    R0,=DH'-1'
*MCALL #=   258 LV= 1          RT1   CCE
         DS    0H
RT1_TEST203      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE203
         LTORG 
RT1_CCE203      DS 0H
*MEXIT #=   258 LV= 1 RT1
         LD    R0,=DH'1'
         SW    R0,=DH'1'
*MCALL #=   259 LV= 1          RT1   CCE
         DS    0H
RT1_TEST204      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE204
         LTORG 
RT1_CCE204      DS 0H
*MEXIT #=   259 LV= 1 RT1
         CD    R0,=DH'0'
*MCALL #=   260 LV= 1          RT1   CCE
         DS    0H
RT1_TEST205      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE205
         LTORG 
RT1_CCE205      DS 0H
*MEXIT #=   260 LV= 1 RT1
         LD    F0,=DH'1'
         SW    F0,=X'4E00000000000000'
         STD   F0,DWORD
         CLC   DWORD,=X'4E00000000000001'
*MCALL #=   261 LV= 1          RT1   CCE
         DS    0H
RT1_TEST206      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE206
         LTORG 
RT1_CCE206      DS 0H
*MEXIT #=   261 LV= 1 RT1
* 70   STE
         LE    R0,=EH'1'
         STE   R0,WORD
         CLC   WORD,=X'41100000'
*MCALL #=   262 LV= 1          RT1   CCE
         DS    0H
RT1_TEST207      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE207
         LTORG 
RT1_CCE207      DS 0H
*MEXIT #=   262 LV= 1 RT1
* 78   LE
         LE    R0,=EH'1'
         AE    R0,=EH'1'
*MCALL #=   263 LV= 1          RT1   CCH
         DS    0H
RT1_TEST208      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH208
         LTORG 
RT1_CCH208      DS 0H
*MEXIT #=   263 LV= 1 RT1
         STE   R0,WORD
         CLC   WORD,=X'41200000'
*MCALL #=   264 LV= 1          RT1   CCE
         DS    0H
RT1_TEST209      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE209
         LTORG 
RT1_CCE209      DS 0H
*MEXIT #=   264 LV= 1 RT1
* 79   CE
         LE    R0,=EH'1'
         CE    R0,=X'41100000'
*MCALL #=   265 LV= 1          RT1   CCE
         DS    0H
RT1_TEST210      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE210
         LTORG 
RT1_CCE210      DS 0H
*MEXIT #=   265 LV= 1 RT1
         LE    R0,=EH'-1'
         CE    R0,=EH'0'
*MCALL #=   266 LV= 1          RT1   CCL
         DS    0H
RT1_TEST211      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL211
         LTORG 
RT1_CCL211      DS 0H
*MEXIT #=   266 LV= 1 RT1
         LE    R0,=EH'1'
         CE    R0,=EH'0'
*MCALL #=   267 LV= 1          RT1   CCH
         DS    0H
RT1_TEST212      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH212
         LTORG 
RT1_CCH212      DS 0H
*MEXIT #=   267 LV= 1 RT1
* 7A   AE
         LE    R0,=EH'3'
         AE    R0,=EH'2'
*MCALL #=   268 LV= 1          RT1   CCH
         DS    0H
RT1_TEST213      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH213
         LTORG 
RT1_CCH213      DS 0H
*MEXIT #=   268 LV= 1 RT1
         CE    R0,=EH'5'
*MCALL #=   269 LV= 1          RT1   CCE
         DS    0H
RT1_TEST214      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE214
         LTORG 
RT1_CCE214      DS 0H
*MEXIT #=   269 LV= 1 RT1
         LE    R0,=EH'1'
         AE    R0,=EH'-2'
*MCALL #=   270 LV= 1          RT1   CCL
         DS    0H
RT1_TEST215      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL215
         LTORG 
RT1_CCL215      DS 0H
*MEXIT #=   270 LV= 1 RT1
         CE    R0,=EH'-1'
*MCALL #=   271 LV= 1          RT1   CCE
         DS    0H
RT1_TEST216      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE216
         LTORG 
RT1_CCE216      DS 0H
*MEXIT #=   271 LV= 1 RT1
         LE    R0,=EH'1'
         AE    R0,=EH'-1'
*MCALL #=   272 LV= 1          RT1   CCE
         DS    0H
RT1_TEST217      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE217
         LTORG 
RT1_CCE217      DS 0H
*MEXIT #=   272 LV= 1 RT1
         CE    R0,=EH'0'
*MCALL #=   273 LV= 1          RT1   CCE
         DS    0H
RT1_TEST218      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE218
         LTORG 
RT1_CCE218      DS 0H
*MEXIT #=   273 LV= 1 RT1
*MCALL #=   274 LV= 1          ESPIE SET,ESPIE_EXIT,12,PARAM=AE1 HFP OVX
               ERFLOW
        LA     15,AE1
        IPM    0  GET CURRENT PGM MASK
        SPM    0 TURN ON ANY MASKS REQUIRED
        L      0,=B'00000000000010000000000000000000'
        LA     1,ESPIE_EXIT
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   274 LV= 1 ESPIE
         LE    R0,EHMAX
         AE    R0,EHMAX
*MCALL #=   275 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   275 LV= 1 RT1
*MCALL #=   276 LV= 1 AE1      ESPIE RESET
AE1      DS    0H
        SR     15,15
        SR     1,1
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   276 LV= 1 ESPIE
*MCALL #=   277 LV= 1          WTO   'ESPIE HFP OVERFLOW OK'
         BRAS  1,*+(WTO#0277_EOT-*+1)/2*2
         DC    AL2(WTO#0277_EOT-*,0),C'ESPIE HFP OVERFLOW OK'
WTO#0277_EOT     EQU *
         SVC   35
*MEXIT #=   277 LV= 1 WTO
* 7B   SE
         LE    R0,=EH'3'
         SE    R0,=EH'2'
*MCALL #=   278 LV= 1          RT1   CCH
         DS    0H
RT1_TEST220      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH220
         LTORG 
RT1_CCH220      DS 0H
*MEXIT #=   278 LV= 1 RT1
         CE    R0,=EH'1'
*MCALL #=   279 LV= 1          RT1   CCE
         DS    0H
RT1_TEST221      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE221
         LTORG 
RT1_CCE221      DS 0H
*MEXIT #=   279 LV= 1 RT1
         LE    R0,=EH'1'
         SE    R0,=EH'2'
*MCALL #=   280 LV= 1          RT1   CCL
         DS    0H
RT1_TEST222      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL222
         LTORG 
RT1_CCL222      DS 0H
*MEXIT #=   280 LV= 1 RT1
         CE    R0,=EH'-1'
*MCALL #=   281 LV= 1          RT1   CCE
         DS    0H
RT1_TEST223      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE223
         LTORG 
RT1_CCE223      DS 0H
*MEXIT #=   281 LV= 1 RT1
         LE    R0,=EH'1'
         SE    R0,=EH'1'
*MCALL #=   282 LV= 1          RT1   CCE
         DS    0H
RT1_TEST224      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE224
         LTORG 
RT1_CCE224      DS 0H
*MEXIT #=   282 LV= 1 RT1
         CE    R0,=EH'0'
*MCALL #=   283 LV= 1          RT1   CCE
         DS    0H
RT1_TEST225      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE225
         LTORG 
RT1_CCE225      DS 0H
*MEXIT #=   283 LV= 1 RT1
*MCALL #=   284 LV= 1          ESPIE SET,ESPIE_EXIT,13,PARAM=SE1 HFP UNX
               DERFLOW
        LA     15,SE1
        IPM    0  GET CURRENT PGM MASK
        OILH   0,512
        SPM    0 TURN ON ANY MASKS REQUIRED
        L      0,=B'00000000000001000000000000000000'
        LA     1,ESPIE_EXIT
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   284 LV= 1 ESPIE
         LE    R0,EHMIN
         AE    R0,EHMIN
         SE    R0,EHMIN
*MCALL #=   285 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   285 LV= 1 RT1
*MCALL #=   286 LV= 1 SE1      ESPIE RESET
SE1      DS    0H
        SR     15,15
        SR     1,1
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   286 LV= 1 ESPIE
*MCALL #=   287 LV= 1          WTO   'ESPIE HFP UNDERFLOW OK'
         BRAS  1,*+(WTO#0287_EOT-*+1)/2*2
         DC    AL2(WTO#0287_EOT-*,0),C'ESPIE HFP UNDERFLOW OK'
WTO#0287_EOT     EQU *
         SVC   35
*MEXIT #=   287 LV= 1 WTO
*MCALL #=   288 LV= 1          ESPIE SET,ESPIE_EXIT,14,PARAM=SE2 HFP MAX
               NTISSA SIG.
        LA     15,SE2
        IPM    0  GET CURRENT PGM MASK
        OILH   0,256
        SPM    0 TURN ON ANY MASKS REQUIRED
        L      0,=B'00000000000000100000000000000000'
        LA     1,ESPIE_EXIT
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   288 LV= 1 ESPIE
         LE    R0,EHMIN
         SE    R0,EHMIN
*MCALL #=   289 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   289 LV= 1 RT1
*MCALL #=   290 LV= 1 SE2      ESPIE RESET
SE2      DS    0H
        SR     15,15
        SR     1,1
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   290 LV= 1 ESPIE
*MCALL #=   291 LV= 1          WTO   'ESPIE HFP SIGNIFICANCE OK'
         BRAS  1,*+(WTO#0291_EOT-*+1)/2*2
         DC    AL2(WTO#0291_EOT-*,0),C'ESPIE HFP SIGNIFICANCE OK'
WTO#0291_EOT     EQU *
         SVC   35
*MEXIT #=   291 LV= 1 WTO
         IPM   0
         NILH  0,X'0E00'
         SPM   0  TURN OFF HFP SIG. MASK BIT AGAIN
* 7C   MDE
         LE    R0,=EH'2'
         MDE   R0,=EH'3'
         STD   R0,DWORD
         CLC   DWORD,=DH'6'
*MCALL #=   292 LV= 1          RT1   CCE
         DS    0H
RT1_TEST228      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE228
         LTORG 
RT1_CCE228      DS 0H
*MEXIT #=   292 LV= 1 RT1
* 7D   DE
         LE    R0,=EH'3'
         DE    R0,=EH'2'
         STE   R0,WORD
         CLC   WORD,=EH'1.5'
*MCALL #=   293 LV= 1          RT1   CCE
         DS    0H
RT1_TEST229      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE229
         LTORG 
RT1_CCE229      DS 0H
*MEXIT #=   293 LV= 1 RT1
*MCALL #=   294 LV= 1          ESPIE SET,ESPIE_EXIT,15,PARAM=DE1 HFP DIX
               VIDE
        LA     15,DE1
        IPM    0  GET CURRENT PGM MASK
        SPM    0 TURN ON ANY MASKS REQUIRED
        L      0,=B'00000000000000010000000000000000'
        LA     1,ESPIE_EXIT
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   294 LV= 1 ESPIE
         LE    R0,=EH'1'
         DE    R0,=EH'0'
*MCALL #=   295 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   295 LV= 1 RT1
*MCALL #=   296 LV= 1 DE1      ESPIE RESET
DE1      DS    0H
        SR     15,15
        SR     1,1
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   296 LV= 1 ESPIE
*MCALL #=   297 LV= 1          WTO   'ESPIE HFP DIVIDE OK'
         BRAS  1,*+(WTO#0297_EOT-*+1)/2*2
         DC    AL2(WTO#0297_EOT-*,0),C'ESPIE HFP DIVIDE OK'
WTO#0297_EOT     EQU *
         SVC   35
*MEXIT #=   297 LV= 1 WTO
* 7E   AU
         LE    R0,=EH'3'
         AU    R0,=EH'2'
*MCALL #=   298 LV= 1          RT1   CCH
         DS    0H
RT1_TEST231      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH231
         LTORG 
RT1_CCH231      DS 0H
*MEXIT #=   298 LV= 1 RT1
         CE    R0,=EH'5'
*MCALL #=   299 LV= 1          RT1   CCE
         DS    0H
RT1_TEST232      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE232
         LTORG 
RT1_CCE232      DS 0H
*MEXIT #=   299 LV= 1 RT1
         LE    R0,=EH'1'
         AU    R0,=EH'-2'
*MCALL #=   300 LV= 1          RT1   CCL
         DS    0H
RT1_TEST233      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL233
         LTORG 
RT1_CCL233      DS 0H
*MEXIT #=   300 LV= 1 RT1
         CE    R0,=EH'-1'
*MCALL #=   301 LV= 1          RT1   CCE
         DS    0H
RT1_TEST234      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE234
         LTORG 
RT1_CCE234      DS 0H
*MEXIT #=   301 LV= 1 RT1
         LE    R0,=EH'1'
         AU    R0,=EH'-1'
*MCALL #=   302 LV= 1          RT1   CCE
         DS    0H
RT1_TEST235      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE235
         LTORG 
RT1_CCE235      DS 0H
*MEXIT #=   302 LV= 1 RT1
         CE    R0,=EH'0'
*MCALL #=   303 LV= 1          RT1   CCE
         DS    0H
RT1_TEST236      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE236
         LTORG 
RT1_CCE236      DS 0H
*MEXIT #=   303 LV= 1 RT1
         LE    F0,=EH'1'
         AU    F0,=X'46000000'
         STD   F0,WORD
         CLC   WORD,=X'46000001'
*MCALL #=   304 LV= 1          RT1   CCE
         DS    0H
RT1_TEST237      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE237
         LTORG 
RT1_CCE237      DS 0H
*MEXIT #=   304 LV= 1 RT1
* 7F   SU
         LE    R0,=EH'3'
         SU    R0,=EH'2'
*MCALL #=   305 LV= 1          RT1   CCH
         DS    0H
RT1_TEST238      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH238
         LTORG 
RT1_CCH238      DS 0H
*MEXIT #=   305 LV= 1 RT1
         CE    R0,=EH'1'
*MCALL #=   306 LV= 1          RT1   CCE
         DS    0H
RT1_TEST239      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE239
         LTORG 
RT1_CCE239      DS 0H
*MEXIT #=   306 LV= 1 RT1
         LE    R0,=EH'1'
         SU    R0,=EH'2'
*MCALL #=   307 LV= 1          RT1   CCL
         DS    0H
RT1_TEST240      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL240
         LTORG 
RT1_CCL240      DS 0H
*MEXIT #=   307 LV= 1 RT1
         CE    R0,=EH'-1'
*MCALL #=   308 LV= 1          RT1   CCE
         DS    0H
RT1_TEST241      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE241
         LTORG 
RT1_CCE241      DS 0H
*MEXIT #=   308 LV= 1 RT1
         LE    R0,=EH'1'
         SU    R0,=EH'1'
*MCALL #=   309 LV= 1          RT1   CCE
         DS    0H
RT1_TEST242      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE242
         LTORG 
RT1_CCE242      DS 0H
*MEXIT #=   309 LV= 1 RT1
         CE    R0,=EH'0'
*MCALL #=   310 LV= 1          RT1   CCE
         DS    0H
RT1_TEST243      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE243
         LTORG 
RT1_CCE243      DS 0H
*MEXIT #=   310 LV= 1 RT1
         LE    F0,=EH'1'
         SU    F0,=X'46000000'
         STD   F0,WORD
         CLC   WORD,=X'46000001'
*MCALL #=   311 LV= 1          RT1   CCE
         DS    0H
RT1_TEST244      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE244
         LTORG 
RT1_CCE244      DS 0H
*MEXIT #=   311 LV= 1 RT1
* B22D DXR
*MCALL #=   312 LV= 1          LX    R0,=LH'6'
         LA    15,=LH'6'
         LD    R0,0(15)
         LD    R0+2,8(15)  RPI 229
*MEXIT #=   312 LV= 1 LX
*MCALL #=   313 LV= 1          LX    R1,=LH'2'
         LA    15,=LH'2'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   313 LV= 1 LX
*MCALL #=   314 LV= 1          LX    R4,=LH'3'
         LA    15,=LH'3'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   314 LV= 1 LX
         DXR   R0,R1
         CXR   R0,R4
*MCALL #=   315 LV= 1          RT1   CCE
         DS    0H
RT1_TEST245      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE245
         LTORG 
RT1_CCE245      DS 0H
*MEXIT #=   315 LV= 1 RT1
*MCALL #=   316 LV= 1          LX    R0,=LH'1'
         LA    15,=LH'1'
         LD    R0,0(15)
         LD    R0+2,8(15)  RPI 229
*MEXIT #=   316 LV= 1 LX
*MCALL #=   317 LV= 1          LX    R1,=LH'-2'
         LA    15,=LH'-2'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   317 LV= 1 LX
*MCALL #=   318 LV= 1          LX    R4,=LH'-0.5'
         LA    15,=LH'-0.5'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   318 LV= 1 LX
         DXR   R0,R1
         CXR   R0,R4
*MCALL #=   319 LV= 1          RT1   CCE
         DS    0H
RT1_TEST246      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE246
         LTORG 
RT1_CCE246      DS 0H
*MEXIT #=   319 LV= 1 RT1
*MCALL #=   320 LV= 1          LX    R0,=LH'-1'
         LA    15,=LH'-1'
         LD    R0,0(15)
         LD    R0+2,8(15)  RPI 229
*MEXIT #=   320 LV= 1 LX
*MCALL #=   321 LV= 1          LX    R1,=LH'-0.5'
         LA    15,=LH'-0.5'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   321 LV= 1 LX
*MCALL #=   322 LV= 1          LX    R4,=LH'2'
         LA    15,=LH'2'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   322 LV= 1 LX
         DXR   R0,R1
         CXR   R0,R4
*MCALL #=   323 LV= 1          RT1   CCE
         DS    0H
RT1_TEST247      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE247
         LTORG 
RT1_CCE247      DS 0H
*MEXIT #=   323 LV= 1 RT1
*MCALL #=   324 LV= 1          ESPIE SET,ESPIE_EXIT,15,PARAM=DXR1 HFP DX
               IVIDE
        LA     15,DXR1
        IPM    0  GET CURRENT PGM MASK
        SPM    0 TURN ON ANY MASKS REQUIRED
        L      0,=B'00000000000000010000000000000000'
        LA     1,ESPIE_EXIT
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   324 LV= 1 ESPIE
*MCALL #=   325 LV= 1          LX    R0,=LH'1'
         LA    15,=LH'1'
         LD    R0,0(15)
         LD    R0+2,8(15)  RPI 229
*MEXIT #=   325 LV= 1 LX
*MCALL #=   326 LV= 1          LX    R1,=LH'0'
         LA    15,=LH'0'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   326 LV= 1 LX
         DXR   R0,R1
*MCALL #=   327 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   327 LV= 1 RT1
*MCALL #=   328 LV= 1 DXR1     ESPIE RESET
DXR1     DS    0H
        SR     15,15
        SR     1,1
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   328 LV= 1 ESPIE
* B244 SQDR
         LD    R1,=DH'4'
         SQDR  R0,R1
         CD    R0,=DH'2'
*MCALL #=   329 LV= 1          RT1   CCE
         DS    0H
RT1_TEST249      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE249
         LTORG 
RT1_CCE249      DS 0H
*MEXIT #=   329 LV= 1 RT1
* B245 SQER
         LE    R1,=EH'4'
         SQER  R0,R1
         CE    R0,=EH'2'
*MCALL #=   330 LV= 1          RT1   CCE
         DS    0H
RT1_TEST250      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE250
         LTORG 
RT1_CCE250      DS 0H
*MEXIT #=   330 LV= 1 RT1
* B299 SRNM
         SRNM  0  DEFAULT ROUND TO NEAREST WITH HALF EVEN
         LE    R1,=EB'2.5'
         FIEBR R0,0,R1
         CEB   R0,=EB'2'
*MCALL #=   331 LV= 1          RT1   CCE
         DS    0H
RT1_TEST251      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE251
         LTORG 
RT1_CCE251      DS 0H
*MEXIT #=   331 LV= 1 RT1
         LE    R1,=EB'3.5'
         FIEBR R0,0,R1
         CEB   R0,=EB'4'
*MCALL #=   332 LV= 1          RT1   CCE
         DS    0H
RT1_TEST252      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE252
         LTORG 
RT1_CCE252      DS 0H
*MEXIT #=   332 LV= 1 RT1
         SRNM  1  ROUND TOWARD ZERO
         LE    R1,=EB'2.5'
         FIEBR R0,0,R1
         CEB   R0,=EB'2'
*MCALL #=   333 LV= 1          RT1   CCE
         DS    0H
RT1_TEST253      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE253
         LTORG 
RT1_CCE253      DS 0H
*MEXIT #=   333 LV= 1 RT1
         LE    R1,=EB'3.5'
         FIEBR R0,0,R1
         CEB   R0,=EB'3'
*MCALL #=   334 LV= 1          RT1   CCE
         DS    0H
RT1_TEST254      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE254
         LTORG 
RT1_CCE254      DS 0H
*MEXIT #=   334 LV= 1 RT1
         SRNM  2  ROUND TOWARD PLUS INFINITY
         LE    R1,=EB'2.5'
         FIEBR R0,0,R1
         CEB   R0,=EB'3'
*MCALL #=   335 LV= 1          RT1   CCE
         DS    0H
RT1_TEST255      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE255
         LTORG 
RT1_CCE255      DS 0H
*MEXIT #=   335 LV= 1 RT1
         LE    R1,=EB'3.5'
         FIEBR R0,0,R1
         CEB   R0,=EB'4'
*MCALL #=   336 LV= 1          RT1   CCE
         DS    0H
RT1_TEST256      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE256
         LTORG 
RT1_CCE256      DS 0H
*MEXIT #=   336 LV= 1 RT1
         SRNM  3  ROUND TOWARD NEG  INFINITY
         LE    R1,=EB'2.5'
         FIEBR R0,0,R1
         CEB   R0,=EB'2'
*MCALL #=   337 LV= 1          RT1   CCE
         DS    0H
RT1_TEST257      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE257
         LTORG 
RT1_CCE257      DS 0H
*MEXIT #=   337 LV= 1 RT1
         LE    R1,=EB'3.5'
         FIEBR R0,0,R1
         CEB   R0,=EB'3'
*MCALL #=   338 LV= 1          RT1   CCE
         DS    0H
RT1_TEST258      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE258
         LTORG 
RT1_CCE258      DS 0H
*MEXIT #=   338 LV= 1 RT1
         SRNM  0  DEFAULT ROUND TO NEAREST WITH HALF EVEN RESET
         LE    R1,=EB'2.5'
         FIEBR R0,0,R1
         CEB   R0,=EB'2'
*MCALL #=   339 LV= 1          RT1   CCE
         DS    0H
RT1_TEST259      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE259
         LTORG 
RT1_CCE259      DS 0H
*MEXIT #=   339 LV= 1 RT1
         LE    R1,=EB'3.5'
         FIEBR R0,0,R1
         CEB   R0,=EB'4'
*MCALL #=   340 LV= 1          RT1   CCE
         DS    0H
RT1_TEST260      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE260
         LTORG 
RT1_CCE260      DS 0H
*MEXIT #=   340 LV= 1 RT1
* B300 LPEBR
         LE    R1,=EB'-1'
         LE    R2,=EB'1'
         LPEBR R0,R1
*MCALL #=   341 LV= 1          RT1   CCH
         DS    0H
RT1_TEST261      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH261
         LTORG 
RT1_CCH261      DS 0H
*MEXIT #=   341 LV= 1 RT1
         CEBR  R0,R2
*MCALL #=   342 LV= 1          RT1   CCE
         DS    0H
RT1_TEST262      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE262
         LTORG 
RT1_CCE262      DS 0H
*MEXIT #=   342 LV= 1 RT1
         LE    R1,=EB'0'
         LE    R2,=EB'0'
         LPEBR R0,R1
*MCALL #=   343 LV= 1          RT1   CCE
         DS    0H
RT1_TEST263      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE263
         LTORG 
RT1_CCE263      DS 0H
*MEXIT #=   343 LV= 1 RT1
         CEBR  R0,R2
*MCALL #=   344 LV= 1          RT1   CCE
         DS    0H
RT1_TEST264      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE264
         LTORG 
RT1_CCE264      DS 0H
*MEXIT #=   344 LV= 1 RT1
* B301 LNEBR
         LE    R1,=EB'1'
         LE    R2,=EB'-1'
         LNEBR R0,R1
*MCALL #=   345 LV= 1          RT1   CCL
         DS    0H
RT1_TEST265      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL265
         LTORG 
RT1_CCL265      DS 0H
*MEXIT #=   345 LV= 1 RT1
         CEBR  R0,R2
*MCALL #=   346 LV= 1          RT1   CCE
         DS    0H
RT1_TEST266      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE266
         LTORG 
RT1_CCE266      DS 0H
*MEXIT #=   346 LV= 1 RT1
         LE    R1,=EB'0'
         LE    R2,=EB'0'
         LNEBR R0,R1
*MCALL #=   347 LV= 1          RT1   CCE
         DS    0H
RT1_TEST267      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE267
         LTORG 
RT1_CCE267      DS 0H
*MEXIT #=   347 LV= 1 RT1
         CEBR  R0,R2
*MCALL #=   348 LV= 1          RT1   CCE
         DS    0H
RT1_TEST268      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE268
         LTORG 
RT1_CCE268      DS 0H
*MEXIT #=   348 LV= 1 RT1
* B302 LTEBR
         LE    R1,=EB'1'
         LE    R2,=EB'1'
         LTEBR R0,R1
*MCALL #=   349 LV= 1          RT1   CCH
         DS    0H
RT1_TEST269      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH269
         LTORG 
RT1_CCH269      DS 0H
*MEXIT #=   349 LV= 1 RT1
         CEBR  R0,R2
*MCALL #=   350 LV= 1          RT1   CCE
         DS    0H
RT1_TEST270      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE270
         LTORG 
RT1_CCE270      DS 0H
*MEXIT #=   350 LV= 1 RT1
         LE    R1,=EB'0'
         LE    R2,=EB'0'
         LTEBR R0,R1
*MCALL #=   351 LV= 1          RT1   CCE
         DS    0H
RT1_TEST271      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE271
         LTORG 
RT1_CCE271      DS 0H
*MEXIT #=   351 LV= 1 RT1
         CEBR  R0,R2
*MCALL #=   352 LV= 1          RT1   CCE
         DS    0H
RT1_TEST272      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE272
         LTORG 
RT1_CCE272      DS 0H
*MEXIT #=   352 LV= 1 RT1
         LE    R1,=EB'-1'
         LE    R2,=EB'-1'
         LTEBR R0,R1
*MCALL #=   353 LV= 1          RT1   CCL
         DS    0H
RT1_TEST273      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL273
         LTORG 
RT1_CCL273      DS 0H
*MEXIT #=   353 LV= 1 RT1
         CEBR  R0,R2
*MCALL #=   354 LV= 1          RT1   CCE
         DS    0H
RT1_TEST274      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE274
         LTORG 
RT1_CCE274      DS 0H
*MEXIT #=   354 LV= 1 RT1
* B303 LCEBR
         LE    R1,=EB'-1'
         LE    R2,=EB'1'
         LCEBR R0,R1
*MCALL #=   355 LV= 1          RT1   CCH
         DS    0H
RT1_TEST275      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH275
         LTORG 
RT1_CCH275      DS 0H
*MEXIT #=   355 LV= 1 RT1
         CEBR  R0,R2
*MCALL #=   356 LV= 1          RT1   CCE
         DS    0H
RT1_TEST276      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE276
         LTORG 
RT1_CCE276      DS 0H
*MEXIT #=   356 LV= 1 RT1
         LE    R1,=EB'0'
         LE    R2,=EB'0'
         LCEBR R0,R1
*MCALL #=   357 LV= 1          RT1   CCE
         DS    0H
RT1_TEST277      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE277
         LTORG 
RT1_CCE277      DS 0H
*MEXIT #=   357 LV= 1 RT1
         CEBR  R0,R2
*MCALL #=   358 LV= 1          RT1   CCE
         DS    0H
RT1_TEST278      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE278
         LTORG 
RT1_CCE278      DS 0H
*MEXIT #=   358 LV= 1 RT1
         LE    R1,=EB'1'
         LE    R2,=EB'-1'
         LCEBR R0,R1
*MCALL #=   359 LV= 1          RT1   CCL
         DS    0H
RT1_TEST279      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL279
         LTORG 
RT1_CCL279      DS 0H
*MEXIT #=   359 LV= 1 RT1
         CEBR  R0,R2
*MCALL #=   360 LV= 1          RT1   CCE
         DS    0H
RT1_TEST280      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE280
         LTORG 
RT1_CCE280      DS 0H
*MEXIT #=   360 LV= 1 RT1
* B304 LDEBR
         LE    R1,=EB'1'
         LE    R1,=EB'1'
         LE    R0,=EB'0'
         LE    R0,=EB'0'
         LDEBR R0,R1
         CDB   R0,=DB'1'
*MCALL #=   361 LV= 1          RT1   CCE
         DS    0H
RT1_TEST281      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE281
         LTORG 
RT1_CCE281      DS 0H
*MEXIT #=   361 LV= 1 RT1
* B305 LXDBR
*MCALL #=   362 LV= 1          LX    R0,=LB'0'
         LA    15,=LB'0'
         LD    R0,0(15)
         LD    R0+2,8(15)  RPI 229
*MEXIT #=   362 LV= 1 LX
         LD    R1,=DB'1'
         LXDBR R0,R1
*MCALL #=   363 LV= 1          LX    R4,=LB'1'
         LA    15,=LB'1'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   363 LV= 1 LX
         CXBR  R0,R4
*MCALL #=   364 LV= 1          RT1   CCE
         DS    0H
RT1_TEST282      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE282
         LTORG 
RT1_CCE282      DS 0H
*MEXIT #=   364 LV= 1 RT1
* B306 LXEBR
*MCALL #=   365 LV= 1          LX    R0,=LB'0'
         LA    15,=LB'0'
         LD    R0,0(15)
         LD    R0+2,8(15)  RPI 229
*MEXIT #=   365 LV= 1 LX
         LE    R1,=EB'1'
         LXEBR R0,R1
*MCALL #=   366 LV= 1          LX    R4,=LB'1'
         LA    15,=LB'1'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   366 LV= 1 LX
         CXBR  R0,R4
*MCALL #=   367 LV= 1          RT1   CCE
         DS    0H
RT1_TEST283      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE283
         LTORG 
RT1_CCE283      DS 0H
*MEXIT #=   367 LV= 1 RT1
* B307 MXDBR
         LD    R0,=DB'20'
         LD    R1,=DB'30'
*MCALL #=   368 LV= 1          LX    R4,=LB'600'
         LA    15,=LB'600'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   368 LV= 1 LX
         MXDBR R0,R1
         CXBR  R0,R4
*MCALL #=   369 LV= 1          RT1   CCE
         DS    0H
RT1_TEST284      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE284
         LTORG 
RT1_CCE284      DS 0H
*MEXIT #=   369 LV= 1 RT1
         LD    R0,=DB'10'
         LD    R1,=DB'-20'
*MCALL #=   370 LV= 1          LX    R4,=LB'-200'
         LA    15,=LB'-200'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   370 LV= 1 LX
         MXDBR R0,R1
         CXBR  R0,R4
*MCALL #=   371 LV= 1          RT1   CCE
         DS    0H
RT1_TEST285      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE285
         LTORG 
RT1_CCE285      DS 0H
*MEXIT #=   371 LV= 1 RT1
         LD    R0,=DB'-0.5'
         LD    R1,=DB'-0.5'
*MCALL #=   372 LV= 1          LX    R4,=LB'.25'
         LA    15,=LB'.25'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   372 LV= 1 LX
         MXDBR R0,R1
         CXBR  R0,R4
*MCALL #=   373 LV= 1          RT1   CCE
         DS    0H
RT1_TEST286      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE286
         LTORG 
RT1_CCE286      DS 0H
*MEXIT #=   373 LV= 1 RT1
* B308 KEBR
         LE    R0,=EB'-1'
         LE    R1,=EB'1'
         KEBR  R0,R1
*MCALL #=   374 LV= 1          RT1   CCL
         DS    0H
RT1_TEST287      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL287
         LTORG 
RT1_CCL287      DS 0H
*MEXIT #=   374 LV= 1 RT1
         LE    R0,=EB'1'
         LE    R1,=EB'1'
         KEBR  R0,R1
*MCALL #=   375 LV= 1          RT1   CCE
         DS    0H
RT1_TEST288      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE288
         LTORG 
RT1_CCE288      DS 0H
*MEXIT #=   375 LV= 1 RT1
         LE    R0,=EB'0'  RPI 325
         LE    R1,=EB'0'
         KEBR  R0,R1
*MCALL #=   376 LV= 1          RT1   CCE
         DS    0H
RT1_TEST289      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE289
         LTORG 
RT1_CCE289      DS 0H
*MEXIT #=   376 LV= 1 RT1
         LE    R0,=EB'1'
         LE    R1,=EB'-1'
         KEBR  R0,R1
*MCALL #=   377 LV= 1          RT1   CCH
         DS    0H
RT1_TEST290      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH290
         LTORG 
RT1_CCH290      DS 0H
*MEXIT #=   377 LV= 1 RT1
*MCALL #=   378 LV= 1          ESPIE SET,ESPIE_EXIT,7,PARAM=KEBR1 BFP OX
               VERFLOW FPCDXC=20
        LA     15,KEBR1
        IPM    0  GET CURRENT PGM MASK
        SPM    0 TURN ON ANY MASKS REQUIRED
        L      0,=B'00000001000000000000000000000000'
        LA     1,ESPIE_EXIT
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   378 LV= 1 ESPIE
         LE    R0,=EB'1'
         LE    R1,EBMAX
         KEBR  R0,R1
*MCALL #=   379 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   379 LV= 1 RT1
*MCALL #=   380 LV= 1 KEBR1    ESPIE RESET
KEBR1    DS    0H
        SR     15,15
        SR     1,1
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   380 LV= 1 ESPIE
         STFPC FPCREG
         CLI   FPCDXC,X'20'
*MCALL #=   381 LV= 1          RT1   CCE
         DS    0H
RT1_TEST292      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE292
         LTORG 
RT1_CCE292      DS 0H
*MEXIT #=   381 LV= 1 RT1
*MCALL #=   382 LV= 1          ESPIE SET,ESPIE_EXIT,7,PARAM=KEBR2 BFP UX
               NDERFLOW FPCDXC=10
        LA     15,KEBR2
        IPM    0  GET CURRENT PGM MASK
        SPM    0 TURN ON ANY MASKS REQUIRED
        L      0,=B'00000001000000000000000000000000'
        LA     1,ESPIE_EXIT
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   382 LV= 1 ESPIE
         LE    R0,EBMIN
         LE    R1,=EB'1'
         KEBR  R0,R1
*MCALL #=   383 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   383 LV= 1 RT1
*MCALL #=   384 LV= 1 KEBR2    ESPIE RESET
KEBR2    DS    0H
        SR     15,15
        SR     1,1
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   384 LV= 1 ESPIE
         STFPC FPCREG
         CLI   FPCDXC,X'10'
*MCALL #=   385 LV= 1          RT1   CCE
         DS    0H
RT1_TEST294      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE294
         LTORG 
RT1_CCE294      DS 0H
*MEXIT #=   385 LV= 1 RT1
* B309 CEBR
         LE    R0,=EB'-1'
         LE    R1,=EB'1'
         CEBR  R0,R1
*MCALL #=   386 LV= 1          RT1   CCL
         DS    0H
RT1_TEST295      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL295
         LTORG 
RT1_CCL295      DS 0H
*MEXIT #=   386 LV= 1 RT1
         LE    R0,=EB'1'
         LE    R1,=EB'1'
         CEBR  R0,R1
*MCALL #=   387 LV= 1          RT1   CCE
         DS    0H
RT1_TEST296      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE296
         LTORG 
RT1_CCE296      DS 0H
*MEXIT #=   387 LV= 1 RT1
         LE    R0,=EB'1'
         LE    R1,=EB'-1'
         CEBR  R0,R1
*MCALL #=   388 LV= 1          RT1   CCH
         DS    0H
RT1_TEST297      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH297
         LTORG 
RT1_CCH297      DS 0H
*MEXIT #=   388 LV= 1 RT1
* B30A AEBR
         LE    R0,=EB'3'
         LE    R2,=EB'2'
         AEBR  R0,R2
*MCALL #=   389 LV= 1          RT1   CCH
         DS    0H
RT1_TEST298      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH298
         LTORG 
RT1_CCH298      DS 0H
*MEXIT #=   389 LV= 1 RT1
         CEB   R0,=EB'5'
*MCALL #=   390 LV= 1          RT1   CCE
         DS    0H
RT1_TEST299      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE299
         LTORG 
RT1_CCE299      DS 0H
*MEXIT #=   390 LV= 1 RT1
         LE    R0,=EB'1'
         LE    R2,=EB'-2'
         AEBR  R0,R2
*MCALL #=   391 LV= 1          RT1   CCL
         DS    0H
RT1_TEST300      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL300
         LTORG 
RT1_CCL300      DS 0H
*MEXIT #=   391 LV= 1 RT1
         CEB   R0,=EB'-1'
*MCALL #=   392 LV= 1          RT1   CCE
         DS    0H
RT1_TEST301      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE301
         LTORG 
RT1_CCE301      DS 0H
*MEXIT #=   392 LV= 1 RT1
         LE    R0,=EB'1'
         LE    R2,=EB'-1'
         AEBR  R0,R2
*MCALL #=   393 LV= 1          RT1   CCE
         DS    0H
RT1_TEST302      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE302
         LTORG 
RT1_CCE302      DS 0H
*MEXIT #=   393 LV= 1 RT1
         CEB   R0,=EB'0'
*MCALL #=   394 LV= 1          RT1   CCE
         DS    0H
RT1_TEST303      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE303
         LTORG 
RT1_CCE303      DS 0H
*MEXIT #=   394 LV= 1 RT1
*MCALL #=   395 LV= 1          ESPIE SET,ESPIE_EXIT,7,PARAM=AEBR1 BFP OX
               VERFLOW FPCDXC=20
        LA     15,AEBR1
        IPM    0  GET CURRENT PGM MASK
        SPM    0 TURN ON ANY MASKS REQUIRED
        L      0,=B'00000001000000000000000000000000'
        LA     1,ESPIE_EXIT
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   395 LV= 1 ESPIE
         LE    R0,EBMAX
         LE    R1,EBMAX
         AEBR  R0,R1
*MCALL #=   396 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   396 LV= 1 RT1
*MCALL #=   397 LV= 1 AEBR1    ESPIE RESET
AEBR1    DS    0H
        SR     15,15
        SR     1,1
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   397 LV= 1 ESPIE
         STFPC FPCREG
         CLI   FPCDXC,X'20'
*MCALL #=   398 LV= 1          RT1   CCE
         DS    0H
RT1_TEST305      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE305
         LTORG 
RT1_CCE305      DS 0H
*MEXIT #=   398 LV= 1 RT1
*MCALL #=   399 LV= 1          WTO   'ESPIE BFP EB OVERFLOW OK'
         BRAS  1,*+(WTO#0399_EOT-*+1)/2*2
         DC    AL2(WTO#0399_EOT-*,0),C'ESPIE BFP EB OVERFLOW OK'
WTO#0399_EOT     EQU *
         SVC   35
*MEXIT #=   399 LV= 1 WTO
* B30B SEBR
         LE    R0,=EB'3'
         LE    R2,=EB'2'
         SEBR  R0,R2
*MCALL #=   400 LV= 1          RT1   CCH
         DS    0H
RT1_TEST306      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH306
         LTORG 
RT1_CCH306      DS 0H
*MEXIT #=   400 LV= 1 RT1
         CEB   R0,=EB'1'
*MCALL #=   401 LV= 1          RT1   CCE
         DS    0H
RT1_TEST307      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE307
         LTORG 
RT1_CCE307      DS 0H
*MEXIT #=   401 LV= 1 RT1
         LE    R0,=EB'1'
         LE    R2,=EB'2'
         SEBR  R0,R2
*MCALL #=   402 LV= 1          RT1   CCL
         DS    0H
RT1_TEST308      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL308
         LTORG 
RT1_CCL308      DS 0H
*MEXIT #=   402 LV= 1 RT1
         CEB   R0,=EB'-1'
*MCALL #=   403 LV= 1          RT1   CCE
         DS    0H
RT1_TEST309      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE309
         LTORG 
RT1_CCE309      DS 0H
*MEXIT #=   403 LV= 1 RT1
         LE    R0,=EB'1'
         LE    R2,=EB'1'
         SEBR  R0,R2
*MCALL #=   404 LV= 1          RT1   CCE
         DS    0H
RT1_TEST310      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE310
         LTORG 
RT1_CCE310      DS 0H
*MEXIT #=   404 LV= 1 RT1
         CEB   R0,=EB'0'
*MCALL #=   405 LV= 1          RT1   CCE
         DS    0H
RT1_TEST311      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE311
         LTORG 
RT1_CCE311      DS 0H
*MEXIT #=   405 LV= 1 RT1
*MCALL #=   406 LV= 1          ESPIE SET,ESPIE_EXIT,7,PARAM=SEBR1 BFP UX
               NDERFLOW FPCDXC=10
        LA     15,SEBR1
        IPM    0  GET CURRENT PGM MASK
        SPM    0 TURN ON ANY MASKS REQUIRED
        L      0,=B'00000001000000000000000000000000'
        LA     1,ESPIE_EXIT
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   406 LV= 1 ESPIE
         LE    R0,EBMIN
         LE    R1,EBMIN
         AEBR  R0,R1
         SEBR  R0,R1
*MCALL #=   407 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   407 LV= 1 RT1
*MCALL #=   408 LV= 1 SEBR1    ESPIE RESET
SEBR1    DS    0H
        SR     15,15
        SR     1,1
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   408 LV= 1 ESPIE
         STFPC FPCREG
         CLI   FPCDXC,X'10'
*MCALL #=   409 LV= 1          RT1   CCE
         DS    0H
RT1_TEST313      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE313
         LTORG 
RT1_CCE313      DS 0H
*MEXIT #=   409 LV= 1 RT1
*MCALL #=   410 LV= 1          WTO   'ESPIE BFP EB UNDERFLOW OK'
         BRAS  1,*+(WTO#0410_EOT-*+1)/2*2
         DC    AL2(WTO#0410_EOT-*,0),C'ESPIE BFP EB UNDERFLOW OK'
WTO#0410_EOT     EQU *
         SVC   35
*MEXIT #=   410 LV= 1 WTO
         STFPC FPCREG
         OI    FPCREG,X'08' TURN ON BFP SIGNIFICANCE MASK IN FPC REG
         LFPC  FPCREG
*MCALL #=   411 LV= 1          ESPIE SET,ESPIE_EXIT,7,PARAM=SEBR2 BFP SX
               IG FPCDXC=08
        LA     15,SEBR2
        IPM    0  GET CURRENT PGM MASK
        SPM    0 TURN ON ANY MASKS REQUIRED
        L      0,=B'00000001000000000000000000000000'
        LA     1,ESPIE_EXIT
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   411 LV= 1 ESPIE
         LE    R0,EBMIN
         LE    R1,EBMIN
         SEBR  R0,R1
*MCALL #=   412 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   412 LV= 1 RT1
*MCALL #=   413 LV= 1 SEBR2    ESPIE RESET
SEBR2    DS    0H
        SR     15,15
        SR     1,1
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   413 LV= 1 ESPIE
         STFPC FPCREG
         CLI   FPCDXC,X'08'
*MCALL #=   414 LV= 1          RT1   CCE
         DS    0H
RT1_TEST315      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE315
         LTORG 
RT1_CCE315      DS 0H
*MEXIT #=   414 LV= 1 RT1
*MCALL #=   415 LV= 1          WTO   'ESPIE BFP EB SIGNIFICANCE OK'
         BRAS  1,*+(WTO#0415_EOT-*+1)/2*2
         DC    AL2(WTO#0415_EOT-*,0),C'ESPIE BFP EB SIGNIFICANCE OK'
WTO#0415_EOT     EQU *
         SVC   35
*MEXIT #=   415 LV= 1 WTO
         XI    FPCREG,X'08' TURN IT BACK OFF
         LFPC  FPCREG
* B30C MDEBR
         LE    R0,=EB'2'
         LE    R2,=EB'3'
         MDEBR R0,R2
         CDB   R0,=DB'6'
*MCALL #=   416 LV= 1          RT1   CCE
         DS    0H
RT1_TEST316      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE316
         LTORG 
RT1_CCE316      DS 0H
*MEXIT #=   416 LV= 1 RT1
* B30D DEBR
         LE    R0,=EB'3'
         LE    R2,=EB'2'
         DEBR  R0,R2
         CEB   R0,=EB'1.5'
*MCALL #=   417 LV= 1          RT1   CCE
         DS    0H
RT1_TEST317      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE317
         LTORG 
RT1_CCE317      DS 0H
*MEXIT #=   417 LV= 1 RT1
*MCALL #=   418 LV= 1          ESPIE SET,ESPIE_EXIT,7,PARAM=DEBR1 BFP DX
               IVIDE FPCDXC=40
        LA     15,DEBR1
        IPM    0  GET CURRENT PGM MASK
        SPM    0 TURN ON ANY MASKS REQUIRED
        L      0,=B'00000001000000000000000000000000'
        LA     1,ESPIE_EXIT
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   418 LV= 1 ESPIE
         LE    R0,=EB'1'
         LE    R2,=EB'0'
         DEBR  R0,R2
*MCALL #=   419 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   419 LV= 1 RT1
*MCALL #=   420 LV= 1 DEBR1    ESPIE RESET
DEBR1    DS    0H
        SR     15,15
        SR     1,1
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   420 LV= 1 ESPIE
         STFPC FPCREG
         CLI   FPCDXC,X'40'
*MCALL #=   421 LV= 1          RT1   CCE
         DS    0H
RT1_TEST319      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE319
         LTORG 
RT1_CCE319      DS 0H
*MEXIT #=   421 LV= 1 RT1
*MCALL #=   422 LV= 1          WTO   'ESPIE BFP EB DIVIDE OK'
         BRAS  1,*+(WTO#0422_EOT-*+1)/2*2
         DC    AL2(WTO#0422_EOT-*,0),C'ESPIE BFP EB DIVIDE OK'
WTO#0422_EOT     EQU *
         SVC   35
*MEXIT #=   422 LV= 1 WTO
* B30E MAEBR
         LE    R1,=EB'1'
         LE    R3,=EB'2'
         LE    R2,=EB'3'
         MAEBR R1,R3,R2
         CEB   R1,=EB'7'
*MCALL #=   423 LV= 1          RT1   CCE
         DS    0H
RT1_TEST320      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE320
         LTORG 
RT1_CCE320      DS 0H
*MEXIT #=   423 LV= 1 RT1
* B30F MSEBR
         LE    R0,=EB'1'
         LE    R1,=EB'2'
         LE    R2,=EB'3'
         MSEBR R0,R1,R2
         CEB   R0,=EB'5' RPI 834
*MCALL #=   424 LV= 1          RT1   CCE
         DS    0H
RT1_TEST321      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE321
         LTORG 
RT1_CCE321      DS 0H
*MEXIT #=   424 LV= 1 RT1
* B310 LPDBR
         LD    R1,=DB'-1'
         LD    R2,=DB'1'
         LPDBR R0,R1
*MCALL #=   425 LV= 1          RT1   CCH
         DS    0H
RT1_TEST322      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH322
         LTORG 
RT1_CCH322      DS 0H
*MEXIT #=   425 LV= 1 RT1
         CDBR  R0,R2
*MCALL #=   426 LV= 1          RT1   CCE
         DS    0H
RT1_TEST323      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE323
         LTORG 
RT1_CCE323      DS 0H
*MEXIT #=   426 LV= 1 RT1
         LD    R1,=DB'0'
         LD    R2,=DB'0'
         LPDBR R0,R1
*MCALL #=   427 LV= 1          RT1   CCE
         DS    0H
RT1_TEST324      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE324
         LTORG 
RT1_CCE324      DS 0H
*MEXIT #=   427 LV= 1 RT1
         CDBR  R0,R2
*MCALL #=   428 LV= 1          RT1   CCE
         DS    0H
RT1_TEST325      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE325
         LTORG 
RT1_CCE325      DS 0H
*MEXIT #=   428 LV= 1 RT1
* B311 LNDBR
         LD    R1,=DB'1'
         LD    R2,=DB'-1'
         LNDBR R0,R1
*MCALL #=   429 LV= 1          RT1   CCL
         DS    0H
RT1_TEST326      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL326
         LTORG 
RT1_CCL326      DS 0H
*MEXIT #=   429 LV= 1 RT1
         CDBR  R0,R2
*MCALL #=   430 LV= 1          RT1   CCE
         DS    0H
RT1_TEST327      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE327
         LTORG 
RT1_CCE327      DS 0H
*MEXIT #=   430 LV= 1 RT1
         LD    R1,=DB'0'
         LD    R2,=DB'0'
         LNDBR R0,R1
*MCALL #=   431 LV= 1          RT1   CCE
         DS    0H
RT1_TEST328      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE328
         LTORG 
RT1_CCE328      DS 0H
*MEXIT #=   431 LV= 1 RT1
         CDBR  R0,R2
*MCALL #=   432 LV= 1          RT1   CCE
         DS    0H
RT1_TEST329      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE329
         LTORG 
RT1_CCE329      DS 0H
*MEXIT #=   432 LV= 1 RT1
* B312 LTDBR
         LD    R1,=DB'1'
         LD    R2,=DB'1'
         LTDBR R0,R1
*MCALL #=   433 LV= 1          RT1   CCH
         DS    0H
RT1_TEST330      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH330
         LTORG 
RT1_CCH330      DS 0H
*MEXIT #=   433 LV= 1 RT1
         CDBR  R0,R2
*MCALL #=   434 LV= 1          RT1   CCE
         DS    0H
RT1_TEST331      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE331
         LTORG 
RT1_CCE331      DS 0H
*MEXIT #=   434 LV= 1 RT1
         LD    R1,=DB'0'
         LD    R2,=DB'0'
         LTDBR R0,R1
*MCALL #=   435 LV= 1          RT1   CCE
         DS    0H
RT1_TEST332      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE332
         LTORG 
RT1_CCE332      DS 0H
*MEXIT #=   435 LV= 1 RT1
         CDBR  R0,R2
*MCALL #=   436 LV= 1          RT1   CCE
         DS    0H
RT1_TEST333      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE333
         LTORG 
RT1_CCE333      DS 0H
*MEXIT #=   436 LV= 1 RT1
         LD    R1,=DB'-1'
         LD    R2,=DB'-1'
         LTDBR R0,R1
*MCALL #=   437 LV= 1          RT1   CCL
         DS    0H
RT1_TEST334      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL334
         LTORG 
RT1_CCL334      DS 0H
*MEXIT #=   437 LV= 1 RT1
         CDBR  R0,R2
*MCALL #=   438 LV= 1          RT1   CCE
         DS    0H
RT1_TEST335      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE335
         LTORG 
RT1_CCE335      DS 0H
*MEXIT #=   438 LV= 1 RT1
* B313 LCDBR
         LD    R1,=DB'-1'
         LD    R2,=DB'1'
         LCDBR R0,R1
*MCALL #=   439 LV= 1          RT1   CCH
         DS    0H
RT1_TEST336      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH336
         LTORG 
RT1_CCH336      DS 0H
*MEXIT #=   439 LV= 1 RT1
         CDBR  R0,R2
*MCALL #=   440 LV= 1          RT1   CCE
         DS    0H
RT1_TEST337      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE337
         LTORG 
RT1_CCE337      DS 0H
*MEXIT #=   440 LV= 1 RT1
         LD    R1,=DB'0'
         LD    R2,=DB'0'
         LCDBR R0,R1
*MCALL #=   441 LV= 1          RT1   CCE
         DS    0H
RT1_TEST338      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE338
         LTORG 
RT1_CCE338      DS 0H
*MEXIT #=   441 LV= 1 RT1
         CDBR  R0,R2
*MCALL #=   442 LV= 1          RT1   CCE
         DS    0H
RT1_TEST339      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE339
         LTORG 
RT1_CCE339      DS 0H
*MEXIT #=   442 LV= 1 RT1
         LD    R1,=DB'1'
         LD    R2,=DB'-1'
         LCDBR R0,R1
*MCALL #=   443 LV= 1          RT1   CCL
         DS    0H
RT1_TEST340      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL340
         LTORG 
RT1_CCL340      DS 0H
*MEXIT #=   443 LV= 1 RT1
         CDBR  R0,R2
*MCALL #=   444 LV= 1          RT1   CCE
         DS    0H
RT1_TEST341      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE341
         LTORG 
RT1_CCE341      DS 0H
*MEXIT #=   444 LV= 1 RT1
* B214 SQDBR
         LD    R1,=DB'4'
         SQDBR R0,R1
         CDB   R0,=DB'2'
*MCALL #=   445 LV= 1          RT1   CCE
         DS    0H
RT1_TEST342      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE342
         LTORG 
RT1_CCE342      DS 0H
*MEXIT #=   445 LV= 1 RT1
* B215 SQEBR
         LE    R1,=EB'4'
         SQEBR R0,R1
         CEB   R0,=EB'2'
*MCALL #=   446 LV= 1          RT1   CCE
         DS    0H
RT1_TEST343      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE343
         LTORG 
RT1_CCE343      DS 0H
*MEXIT #=   446 LV= 1 RT1
* B316 SQXBR
*MCALL #=   447 LV= 1          LX    R1,=LB'4'
         LA    15,=LB'4'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   447 LV= 1 LX
         SQXBR R0,R1
*MCALL #=   448 LV= 1          LX    R4,=LB'2'
         LA    15,=LB'2'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   448 LV= 1 LX
         CXBR  R0,R4
*MCALL #=   449 LV= 1          RT1   CCE
         DS    0H
RT1_TEST344      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE344
         LTORG 
RT1_CCE344      DS 0H
*MEXIT #=   449 LV= 1 RT1
*MCALL #=   450 LV= 1          LX    R1,=LB'2'
         LA    15,=LB'2'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   450 LV= 1 LX
         SQXBR R0,R1
         MXBR  R0,R0
         SXBR  R0,R1
         LPXBR R0,R0
*MCALL #=   451 LV= 1          LX    R4,=LB'1E-33' RPI 821 WAS 1E-34 DSX
               HX
         LA    15,=LB'1E-33'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   451 LV= 1 LX
         CXBR  R0,R4
*MCALL #=   452 LV= 1          RT1   CCL
         DS    0H
RT1_TEST345      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL345
         LTORG 
RT1_CCL345      DS 0H
*MEXIT #=   452 LV= 1 RT1
* B317 MEEBR
         LE    R0,=EB'2'
         LE    R1,=EB'3'
         MEEBR R0,R1
         CEB   R0,=EB'6'
*MCALL #=   453 LV= 1          RT1   CCE
         DS    0H
RT1_TEST346      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE346
         LTORG 
RT1_CCE346      DS 0H
*MEXIT #=   453 LV= 1 RT1
* B318 KDBR
         LD    R0,=DB'-1'
         LD    R1,=DB'1'
         KDBR  R0,R1
*MCALL #=   454 LV= 1          RT1   CCL
         DS    0H
RT1_TEST347      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL347
         LTORG 
RT1_CCL347      DS 0H
*MEXIT #=   454 LV= 1 RT1
         LD    R0,=DB'1'
         LD    R1,=DB'1'
         KDBR  R0,R1
*MCALL #=   455 LV= 1          RT1   CCE
         DS    0H
RT1_TEST348      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE348
         LTORG 
RT1_CCE348      DS 0H
*MEXIT #=   455 LV= 1 RT1
         LD    R0,=DB'0'  RPI 325
         LD    R1,=DB'0'
         KDBR  R0,R1
*MCALL #=   456 LV= 1          RT1   CCE
         DS    0H
RT1_TEST349      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE349
         LTORG 
RT1_CCE349      DS 0H
*MEXIT #=   456 LV= 1 RT1
         LD    R0,=DB'1'
         LD    R1,=DB'-1'
         KDBR  R0,R1
*MCALL #=   457 LV= 1          RT1   CCH
         DS    0H
RT1_TEST350      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH350
         LTORG 
RT1_CCH350      DS 0H
*MEXIT #=   457 LV= 1 RT1
*MCALL #=   458 LV= 1          ESPIE SET,ESPIE_EXIT,7,PARAM=KDBR1 BFP OX
               VERFLOW FPCDXC=20
        LA     15,KDBR1
        IPM    0  GET CURRENT PGM MASK
        SPM    0 TURN ON ANY MASKS REQUIRED
        L      0,=B'00000001000000000000000000000000'
        LA     1,ESPIE_EXIT
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   458 LV= 1 ESPIE
         LD    R0,=DB'1'
         LD    R1,DBMAX
         KDBR  R0,R1
*MCALL #=   459 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   459 LV= 1 RT1
*MCALL #=   460 LV= 1 KDBR1    ESPIE RESET
KDBR1    DS    0H
        SR     15,15
        SR     1,1
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   460 LV= 1 ESPIE
         STFPC FPCREG
         CLI   FPCDXC,X'20'
*MCALL #=   461 LV= 1          RT1   CCE
         DS    0H
RT1_TEST352      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE352
         LTORG 
RT1_CCE352      DS 0H
*MEXIT #=   461 LV= 1 RT1
*MCALL #=   462 LV= 1          ESPIE SET,ESPIE_EXIT,7,PARAM=KDBR2 BFP UX
               DERFLOW FPCDXC=10
        LA     15,KDBR2
        IPM    0  GET CURRENT PGM MASK
        SPM    0 TURN ON ANY MASKS REQUIRED
        L      0,=B'00000001000000000000000000000000'
        LA     1,ESPIE_EXIT
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   462 LV= 1 ESPIE
         LD    R0,DBMIN
         LD    R1,=DB'1'
         KDBR  R0,R1
*MCALL #=   463 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   463 LV= 1 RT1
*MCALL #=   464 LV= 1 KDBR2    ESPIE RESET
KDBR2    DS    0H
        SR     15,15
        SR     1,1
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   464 LV= 1 ESPIE
         STFPC FPCREG
         CLI   FPCDXC,X'10'
*MCALL #=   465 LV= 1          RT1   CCE
         DS    0H
RT1_TEST354      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE354
         LTORG 
RT1_CCE354      DS 0H
*MEXIT #=   465 LV= 1 RT1
* B319 CDBR
         LD    R0,=DB'-1'
         LD    R1,=DB'1'
         CDBR  R0,R1
*MCALL #=   466 LV= 1          RT1   CCL
         DS    0H
RT1_TEST355      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL355
         LTORG 
RT1_CCL355      DS 0H
*MEXIT #=   466 LV= 1 RT1
         LD    R0,=DB'1'
         LD    R1,=DB'1'
         CDBR  R0,R1
*MCALL #=   467 LV= 1          RT1   CCE
         DS    0H
RT1_TEST356      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE356
         LTORG 
RT1_CCE356      DS 0H
*MEXIT #=   467 LV= 1 RT1
         LD    R0,=DB'1'
         LD    R1,=DB'-1'
         CDBR  R0,R1
*MCALL #=   468 LV= 1          RT1   CCH
         DS    0H
RT1_TEST357      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH357
         LTORG 
RT1_CCH357      DS 0H
*MEXIT #=   468 LV= 1 RT1
* B31A ADBR
         LD    R0,=DB'3'
         LD    R2,=DB'2'
         ADBR  R0,R2
*MCALL #=   469 LV= 1          RT1   CCH
         DS    0H
RT1_TEST358      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH358
         LTORG 
RT1_CCH358      DS 0H
*MEXIT #=   469 LV= 1 RT1
         CDB   R0,=DB'5'
*MCALL #=   470 LV= 1          RT1   CCE
         DS    0H
RT1_TEST359      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE359
         LTORG 
RT1_CCE359      DS 0H
*MEXIT #=   470 LV= 1 RT1
         LD    R0,=DB'1'
         LD    R2,=DB'-2'
         ADBR  R0,R2
*MCALL #=   471 LV= 1          RT1   CCL
         DS    0H
RT1_TEST360      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL360
         LTORG 
RT1_CCL360      DS 0H
*MEXIT #=   471 LV= 1 RT1
         CDB   R0,=DB'-1'
*MCALL #=   472 LV= 1          RT1   CCE
         DS    0H
RT1_TEST361      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE361
         LTORG 
RT1_CCE361      DS 0H
*MEXIT #=   472 LV= 1 RT1
         LD    R0,=DB'1'
         LD    R2,=DB'-1'
         ADBR  R0,R2
*MCALL #=   473 LV= 1          RT1   CCE
         DS    0H
RT1_TEST362      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE362
         LTORG 
RT1_CCE362      DS 0H
*MEXIT #=   473 LV= 1 RT1
         CDB   R0,=DB'0'
*MCALL #=   474 LV= 1          RT1   CCE
         DS    0H
RT1_TEST363      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE363
         LTORG 
RT1_CCE363      DS 0H
*MEXIT #=   474 LV= 1 RT1
*MCALL #=   475 LV= 1          ESPIE SET,ESPIE_EXIT,7,PARAM=ADBR1 BFP OX
               VERFLOW FPCDXC=20
        LA     15,ADBR1
        IPM    0  GET CURRENT PGM MASK
        SPM    0 TURN ON ANY MASKS REQUIRED
        L      0,=B'00000001000000000000000000000000'
        LA     1,ESPIE_EXIT
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   475 LV= 1 ESPIE
         LD    R0,DBMAX
         LD    R1,DBMAX
         ADBR  R0,R1
*MCALL #=   476 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   476 LV= 1 RT1
*MCALL #=   477 LV= 1 ADBR1    ESPIE RESET
ADBR1    DS    0H
        SR     15,15
        SR     1,1
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   477 LV= 1 ESPIE
         STFPC FPCREG
         CLI   FPCDXC,X'20'
*MCALL #=   478 LV= 1          RT1   CCE
         DS    0H
RT1_TEST365      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE365
         LTORG 
RT1_CCE365      DS 0H
*MEXIT #=   478 LV= 1 RT1
*MCALL #=   479 LV= 1          WTO   'ESPIE BFP DB OVERFLOW OK'
         BRAS  1,*+(WTO#0479_EOT-*+1)/2*2
         DC    AL2(WTO#0479_EOT-*,0),C'ESPIE BFP DB OVERFLOW OK'
WTO#0479_EOT     EQU *
         SVC   35
*MEXIT #=   479 LV= 1 WTO
* B31B SDBR
         LD    R0,=DB'3'
         LD    R2,=DB'2'
         SDBR  R0,R2
*MCALL #=   480 LV= 1          RT1   CCH
         DS    0H
RT1_TEST366      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH366
         LTORG 
RT1_CCH366      DS 0H
*MEXIT #=   480 LV= 1 RT1
         CDB   R0,=DB'1'
*MCALL #=   481 LV= 1          RT1   CCE
         DS    0H
RT1_TEST367      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE367
         LTORG 
RT1_CCE367      DS 0H
*MEXIT #=   481 LV= 1 RT1
         LD    R0,=DB'1'
         LD    R2,=DB'2'
         SDBR  R0,R2
*MCALL #=   482 LV= 1          RT1   CCL
         DS    0H
RT1_TEST368      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL368
         LTORG 
RT1_CCL368      DS 0H
*MEXIT #=   482 LV= 1 RT1
         CDB   R0,=DB'-1'
*MCALL #=   483 LV= 1          RT1   CCE
         DS    0H
RT1_TEST369      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE369
         LTORG 
RT1_CCE369      DS 0H
*MEXIT #=   483 LV= 1 RT1
         LD    R0,=DB'1'
         LD    R2,=DB'1'
         SDBR  R0,R2
*MCALL #=   484 LV= 1          RT1   CCE
         DS    0H
RT1_TEST370      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE370
         LTORG 
RT1_CCE370      DS 0H
*MEXIT #=   484 LV= 1 RT1
         CDB   R0,=DB'0'
*MCALL #=   485 LV= 1          RT1   CCE
         DS    0H
RT1_TEST371      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE371
         LTORG 
RT1_CCE371      DS 0H
*MEXIT #=   485 LV= 1 RT1
*MCALL #=   486 LV= 1          ESPIE SET,ESPIE_EXIT,7,PARAM=SDBR1 BFP UX
               NDERFLOW FPCDXC=10
        LA     15,SDBR1
        IPM    0  GET CURRENT PGM MASK
        SPM    0 TURN ON ANY MASKS REQUIRED
        L      0,=B'00000001000000000000000000000000'
        LA     1,ESPIE_EXIT
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   486 LV= 1 ESPIE
         LD    R0,DBMIN
         LD    R1,DBMIN
         ADBR  R0,R1
         SDBR  R0,R1
*MCALL #=   487 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   487 LV= 1 RT1
*MCALL #=   488 LV= 1 SDBR1    ESPIE RESET
SDBR1    DS    0H
        SR     15,15
        SR     1,1
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   488 LV= 1 ESPIE
         STFPC FPCREG
         CLI   FPCDXC,X'10'
*MCALL #=   489 LV= 1          RT1   CCE
         DS    0H
RT1_TEST373      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE373
         LTORG 
RT1_CCE373      DS 0H
*MEXIT #=   489 LV= 1 RT1
*MCALL #=   490 LV= 1          WTO   'ESPIE BFP DB UNDERFLOW OK'
         BRAS  1,*+(WTO#0490_EOT-*+1)/2*2
         DC    AL2(WTO#0490_EOT-*,0),C'ESPIE BFP DB UNDERFLOW OK'
WTO#0490_EOT     EQU *
         SVC   35
*MEXIT #=   490 LV= 1 WTO
         STFPC FPCREG
         OI    FPCREG,X'08' TURN ON BFP SIGNIFICANCE MASK IN FPC REG
         LFPC  FPCREG
*MCALL #=   491 LV= 1          ESPIE SET,ESPIE_EXIT,7,PARAM=SDBR2 BFP SX
               IG FPCDXC=08
        LA     15,SDBR2
        IPM    0  GET CURRENT PGM MASK
        SPM    0 TURN ON ANY MASKS REQUIRED
        L      0,=B'00000001000000000000000000000000'
        LA     1,ESPIE_EXIT
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   491 LV= 1 ESPIE
         LD    R0,DBMIN
         LD    R1,DBMIN
         SDBR  R0,R1
*MCALL #=   492 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   492 LV= 1 RT1
*MCALL #=   493 LV= 1 SDBR2    ESPIE RESET
SDBR2    DS    0H
        SR     15,15
        SR     1,1
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   493 LV= 1 ESPIE
         STFPC FPCREG
         CLI   FPCDXC,X'08'
*MCALL #=   494 LV= 1          RT1   CCE
         DS    0H
RT1_TEST375      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE375
         LTORG 
RT1_CCE375      DS 0H
*MEXIT #=   494 LV= 1 RT1
*MCALL #=   495 LV= 1          WTO   'ESPIE BFP DB SIGNIFICANCE OK'
         BRAS  1,*+(WTO#0495_EOT-*+1)/2*2
         DC    AL2(WTO#0495_EOT-*,0),C'ESPIE BFP DB SIGNIFICANCE OK'
WTO#0495_EOT     EQU *
         SVC   35
*MEXIT #=   495 LV= 1 WTO
         XI    FPCREG,X'08' TURN IT BACK OFF
         LFPC  FPCREG
* B31C MDBR
         LD    R0,=DB'2'
         LD    R2,=DB'3'
         MDBR  R0,R2
         CDB   R0,=DB'6'
*MCALL #=   496 LV= 1          RT1   CCE
         DS    0H
RT1_TEST376      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE376
         LTORG 
RT1_CCE376      DS 0H
*MEXIT #=   496 LV= 1 RT1
* B31D DDBR
         LD    R0,=DB'3'
         LD    R2,=DB'2'
         DDBR  R0,R2
         CDB   R0,=DB'1.5'
*MCALL #=   497 LV= 1          RT1   CCE
         DS    0H
RT1_TEST377      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE377
         LTORG 
RT1_CCE377      DS 0H
*MEXIT #=   497 LV= 1 RT1
*MCALL #=   498 LV= 1          ESPIE SET,ESPIE_EXIT,7,PARAM=DDBR1 BFP DX
               IVIDE FPCDXC=40
        LA     15,DDBR1
        IPM    0  GET CURRENT PGM MASK
        SPM    0 TURN ON ANY MASKS REQUIRED
        L      0,=B'00000001000000000000000000000000'
        LA     1,ESPIE_EXIT
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   498 LV= 1 ESPIE
         LD    R0,=DB'1'
         LD    R2,=DB'0'
         DDBR  R0,R2
*MCALL #=   499 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   499 LV= 1 RT1
*MCALL #=   500 LV= 1 DDBR1    ESPIE RESET
DDBR1    DS    0H
        SR     15,15
        SR     1,1
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   500 LV= 1 ESPIE
         STFPC FPCREG
         CLI   FPCDXC,X'40'
*MCALL #=   501 LV= 1          RT1   CCE
         DS    0H
RT1_TEST379      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE379
         LTORG 
RT1_CCE379      DS 0H
*MEXIT #=   501 LV= 1 RT1
*MCALL #=   502 LV= 1          WTO   'ESPIE BFP DB DIVIDE OK'
         BRAS  1,*+(WTO#0502_EOT-*+1)/2*2
         DC    AL2(WTO#0502_EOT-*,0),C'ESPIE BFP DB DIVIDE OK'
WTO#0502_EOT     EQU *
         SVC   35
*MEXIT #=   502 LV= 1 WTO
* B31E MADBR
         LD    R0,=DB'1'
         LD    R1,=DB'2'
         LD    R2,=DB'3'
         MADBR R0,R1,R2
         CDB   R0,=DB'7'
*MCALL #=   503 LV= 1          RT1   CCE
         DS    0H
RT1_TEST380      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE380
         LTORG 
RT1_CCE380      DS 0H
*MEXIT #=   503 LV= 1 RT1
* B31F MSDBR
         LD    R0,=DB'1'
         LD    R1,=DB'2'
         LD    R2,=DB'3'
         MSDBR R0,R1,R2
         CDB   R0,=DB'5'  RPI 834
*MCALL #=   504 LV= 1          RT1   CCE
         DS    0H
RT1_TEST381      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE381
         LTORG 
RT1_CCE381      DS 0H
*MEXIT #=   504 LV= 1 RT1
* B324 LDER
         LE    R1,=EH'1'
         LE    R0,=EH'0'
         LDER  R0,R1
         CD    R0,=DH'1'
*MCALL #=   505 LV= 1          RT1   CCE
         DS    0H
RT1_TEST382      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE382
         LTORG 
RT1_CCE382      DS 0H
*MEXIT #=   505 LV= 1 RT1
* B325 LXDR
         LD    R1,=DH'1'
         LXDR  R0,R1
*MCALL #=   506 LV= 1          LX    R4,=LH'1'
         LA    15,=LH'1'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   506 LV= 1 LX
         CXR   R0,R4
*MCALL #=   507 LV= 1          RT1   CCE
         DS    0H
RT1_TEST383      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE383
         LTORG 
RT1_CCE383      DS 0H
*MEXIT #=   507 LV= 1 RT1
* B326 LXER
         LE    R1,=EH'123'
         LXER  R0,R1
*MCALL #=   508 LV= 1          LX    R4,=LH'123'
         LA    15,=LH'123'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   508 LV= 1 LX
         CXR   R0,R4
*MCALL #=   509 LV= 1          RT1   CCE
         DS    0H
RT1_TEST384      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE384
         LTORG 
RT1_CCE384      DS 0H
*MEXIT #=   509 LV= 1 RT1
* B32E MAER
         LE    R0,=EH'1'
         LE    R1,=EH'2'
         LE    R2,=EH'3'
         MAER  R0,R1,R2
         CE    R0,=EH'7'
*MCALL #=   510 LV= 1          RT1   CCE
         DS    0H
RT1_TEST385      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE385
         LTORG 
RT1_CCE385      DS 0H
*MEXIT #=   510 LV= 1 RT1
* B32F MSER
         LE    R0,=EH'1'
         LE    R1,=EH'2'
         LE    R2,=EH'3'
         MSER  R0,R1,R2
         CE    R0,=EH'5' RPI 834
*MCALL #=   511 LV= 1          RT1   CCE
         DS    0H
RT1_TEST386      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE386
         LTORG 
RT1_CCE386      DS 0H
*MEXIT #=   511 LV= 1 RT1
* B336 SQXR
*MCALL #=   512 LV= 1          LX    R1,=LH'4'
         LA    15,=LH'4'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   512 LV= 1 LX
         SQXR  R0,R1
*MCALL #=   513 LV= 1          LX    R4,=LH'2'
         LA    15,=LH'2'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   513 LV= 1 LX
         CXR   R0,R4
*MCALL #=   514 LV= 1          RT1   CCE
         DS    0H
RT1_TEST387      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE387
         LTORG 
RT1_CCE387      DS 0H
*MEXIT #=   514 LV= 1 RT1
*MCALL #=   515 LV= 1          LX    R1,=LH'2'
         LA    15,=LH'2'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   515 LV= 1 LX
         SQXR  R0,R1
         MXR   R0,R0
         SXR   R0,R1
         LPXR  R0,R0
*MCALL #=   516 LV= 1          LX    R4,=LH'1E-34'
         LA    15,=LH'1E-34'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   516 LV= 1 LX
         CXR   R0,R4
*MCALL #=   517 LV= 1          RT1   CCL
         DS    0H
RT1_TEST388      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL388
         LTORG 
RT1_CCL388      DS 0H
*MEXIT #=   517 LV= 1 RT1
* B337 MEER
         LE    R0,=EH'2'
         LE    R1,=EH'3'
         MEER  R0,R1
         CE    R0,=EH'6'
*MCALL #=   518 LV= 1          RT1   CCE
         DS    0H
RT1_TEST389      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE389
         LTORG 
RT1_CCE389      DS 0H
*MEXIT #=   518 LV= 1 RT1
* B338 MAYLR Z9 MULTIPLY AND ADD L > E
         LD    R0,=X'4E0000000000000A'
         LD    R5,=X'4E00000000000002'
         LD    R6,=X'4E00000000000003'
         MAYLR R0,R5,R6    RPI 767 FIX TEST
         CD    R0,=D'16'
*MCALL #=   519 LV= 1          RT1   CCE
         DS    0H
RT1_TEST390      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE390
         LTORG 
RT1_CCE390      DS 0H
*MEXIT #=   519 LV= 1 RT1
* B339 MYLR Z9 MULTIPLY L > E
         LD    R2,=X'4E00000000000002'
         LD    R3,=X'4E00000000000003'
         MYLR  R0,R2,R3
         CD    R0,=X'4E00000000000006'  RPI 767 FIX TEST
*MCALL #=   520 LV= 1          RT1   CCE
         DS    0H
RT1_TEST391      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE391
         LTORG 
RT1_CCE391      DS 0H
*MEXIT #=   520 LV= 1 RT1
* B33A MAYR Z9 MULTIPLY AND ADD L > E
*MCALL #=   521 LV= 1          LX    R0,=L'10'
         LA    15,=L'10'
         LD    R0,0(15)
         LD    R0+2,8(15)  RPI 229
*MEXIT #=   521 LV= 1 LX
         LD    R5,=D'2'   RPI 767
         LD    R6,=D'3'   RPI 767
         MAYR  R0,R5,R6   RPI 767 FIX TEST BUG
*MCALL #=   522 LV= 1          LX    R4,=LH'16'
         LA    15,=LH'16'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   522 LV= 1 LX
         CXR   R0,R4
*MCALL #=   523 LV= 1          RT1   CCE
         DS    0H
RT1_TEST392      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE392
         LTORG 
RT1_CCE392      DS 0H
*MEXIT #=   523 LV= 1 RT1
* B33B MYR Z9 MULTIPLY L > E
         LD    R2,=D'2'
         LD    R3,=D'3'
         MYR   R0,R2,R3
*MCALL #=   524 LV= 1          LX    R4,=LH'6'
         LA    15,=LH'6'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   524 LV= 1 LX
         CXR   R0,R4
*MCALL #=   525 LV= 1          RT1   CCE
         DS    0H
RT1_TEST393      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE393
         LTORG 
RT1_CCE393      DS 0H
*MEXIT #=   525 LV= 1 RT1
* B33C MAYHR Z9 MULTIPLY AND ADD L > E
         LD    R0,=D'10'
         LD    R5,=D'2'
         LD    R6,=D'3'
         MAYHR R0,R5,R6    RPI 767 FIX TEST
         CD    R0,=D'16'
*MCALL #=   526 LV= 1          RT1   CCE
         DS    0H
RT1_TEST394      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE394
         LTORG 
RT1_CCE394      DS 0H
*MEXIT #=   526 LV= 1 RT1
* B33D MYLR Z9 MULTIPLY L > E
         LD    R2,=D'2'
         LD    R3,=D'3'
         MYHR  R0,R2,R3
         CD    R0,=DH'6' RPI 767 FIX TEST
*MCALL #=   527 LV= 1          RT1   CCE
         DS    0H
RT1_TEST395      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE395
         LTORG 
RT1_CCE395      DS 0H
*MEXIT #=   527 LV= 1 RT1
* B33E MADR
         LD    R0,=DH'1'
         LD    R1,=DH'2'
         LD    R2,=DH'3'
         MADR  R0,R1,R2
         CD    R0,=DH'7'
*MCALL #=   528 LV= 1          RT1   CCE
         DS    0H
RT1_TEST396      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE396
         LTORG 
RT1_CCE396      DS 0H
*MEXIT #=   528 LV= 1 RT1
* B33F MSDR
         LD    R0,=DH'1'
         LD    R1,=DH'2'
         LD    R2,=DH'3'
         MSDR  R0,R1,R2
         CD    R0,=DH'5'  RPI 834
*MCALL #=   529 LV= 1          RT1   CCE
         DS    0H
RT1_TEST397      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE397
         LTORG 
RT1_CCE397      DS 0H
*MEXIT #=   529 LV= 1 RT1
* B340 LPXBR
*MCALL #=   530 LV= 1          LX    R1,=LB'-1'
         LA    15,=LB'-1'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   530 LV= 1 LX
*MCALL #=   531 LV= 1          LX    R4,=LB'1'
         LA    15,=LB'1'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   531 LV= 1 LX
         LPXBR R0,R1
*MCALL #=   532 LV= 1          RT1   CCH
         DS    0H
RT1_TEST398      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH398
         LTORG 
RT1_CCH398      DS 0H
*MEXIT #=   532 LV= 1 RT1
         CXBR  R0,R4
*MCALL #=   533 LV= 1          RT1   CCE
         DS    0H
RT1_TEST399      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE399
         LTORG 
RT1_CCE399      DS 0H
*MEXIT #=   533 LV= 1 RT1
*MCALL #=   534 LV= 1          LX    R1,=LB'0'
         LA    15,=LB'0'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   534 LV= 1 LX
*MCALL #=   535 LV= 1          LX    R4,=LB'0'
         LA    15,=LB'0'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   535 LV= 1 LX
         LPXBR R0,R1
*MCALL #=   536 LV= 1          RT1   CCE
         DS    0H
RT1_TEST400      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE400
         LTORG 
RT1_CCE400      DS 0H
*MEXIT #=   536 LV= 1 RT1
         CXBR  R0,R4
*MCALL #=   537 LV= 1          RT1   CCE
         DS    0H
RT1_TEST401      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE401
         LTORG 
RT1_CCE401      DS 0H
*MEXIT #=   537 LV= 1 RT1
* B341 LNXBR
*MCALL #=   538 LV= 1          LX    R1,=LB'1'
         LA    15,=LB'1'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   538 LV= 1 LX
*MCALL #=   539 LV= 1          LX    R4,=LB'-1'
         LA    15,=LB'-1'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   539 LV= 1 LX
         LNXBR R0,R1
*MCALL #=   540 LV= 1          RT1   CCL
         DS    0H
RT1_TEST402      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL402
         LTORG 
RT1_CCL402      DS 0H
*MEXIT #=   540 LV= 1 RT1
         CXBR  R0,R4
*MCALL #=   541 LV= 1          RT1   CCE
         DS    0H
RT1_TEST403      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE403
         LTORG 
RT1_CCE403      DS 0H
*MEXIT #=   541 LV= 1 RT1
*MCALL #=   542 LV= 1          LX    R1,=LB'0'
         LA    15,=LB'0'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   542 LV= 1 LX
*MCALL #=   543 LV= 1          LX    R4,=LB'0'
         LA    15,=LB'0'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   543 LV= 1 LX
         LNXBR R0,R1
*MCALL #=   544 LV= 1          RT1   CCE
         DS    0H
RT1_TEST404      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE404
         LTORG 
RT1_CCE404      DS 0H
*MEXIT #=   544 LV= 1 RT1
         CXBR  R0,R4
*MCALL #=   545 LV= 1          RT1   CCE
         DS    0H
RT1_TEST405      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE405
         LTORG 
RT1_CCE405      DS 0H
*MEXIT #=   545 LV= 1 RT1
* B342 LTXBR
*MCALL #=   546 LV= 1          LX    R1,=LB'1'
         LA    15,=LB'1'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   546 LV= 1 LX
*MCALL #=   547 LV= 1          LX    R4,=LB'1'
         LA    15,=LB'1'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   547 LV= 1 LX
         LTXBR R0,R1
*MCALL #=   548 LV= 1          RT1   CCH
         DS    0H
RT1_TEST406      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH406
         LTORG 
RT1_CCH406      DS 0H
*MEXIT #=   548 LV= 1 RT1
         CXBR  R0,R4
*MCALL #=   549 LV= 1          RT1   CCE
         DS    0H
RT1_TEST407      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE407
         LTORG 
RT1_CCE407      DS 0H
*MEXIT #=   549 LV= 1 RT1
*MCALL #=   550 LV= 1          LX    R1,=LB'0'
         LA    15,=LB'0'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   550 LV= 1 LX
*MCALL #=   551 LV= 1          LX    R4,=LB'0'
         LA    15,=LB'0'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   551 LV= 1 LX
         LTXBR R0,R1
*MCALL #=   552 LV= 1          RT1   CCE
         DS    0H
RT1_TEST408      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE408
         LTORG 
RT1_CCE408      DS 0H
*MEXIT #=   552 LV= 1 RT1
         CXBR  R0,R4
*MCALL #=   553 LV= 1          RT1   CCE
         DS    0H
RT1_TEST409      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE409
         LTORG 
RT1_CCE409      DS 0H
*MEXIT #=   553 LV= 1 RT1
*MCALL #=   554 LV= 1          LX    R1,=LB'-1'
         LA    15,=LB'-1'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   554 LV= 1 LX
*MCALL #=   555 LV= 1          LX    R4,=LB'-1'
         LA    15,=LB'-1'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   555 LV= 1 LX
         LTXBR R0,R1
*MCALL #=   556 LV= 1          RT1   CCL
         DS    0H
RT1_TEST410      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL410
         LTORG 
RT1_CCL410      DS 0H
*MEXIT #=   556 LV= 1 RT1
         CXBR  R0,R4
*MCALL #=   557 LV= 1          RT1   CCE
         DS    0H
RT1_TEST411      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE411
         LTORG 
RT1_CCE411      DS 0H
*MEXIT #=   557 LV= 1 RT1
* B343 LCXBR
*MCALL #=   558 LV= 1          LX    R1,=LB'-1'
         LA    15,=LB'-1'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   558 LV= 1 LX
*MCALL #=   559 LV= 1          LX    R4,=LB'1'
         LA    15,=LB'1'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   559 LV= 1 LX
         LCXBR R0,R1
*MCALL #=   560 LV= 1          RT1   CCH
         DS    0H
RT1_TEST412      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH412
         LTORG 
RT1_CCH412      DS 0H
*MEXIT #=   560 LV= 1 RT1
         CXBR  R0,R4
*MCALL #=   561 LV= 1          RT1   CCE
         DS    0H
RT1_TEST413      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE413
         LTORG 
RT1_CCE413      DS 0H
*MEXIT #=   561 LV= 1 RT1
*MCALL #=   562 LV= 1          LX    R1,=LB'0'
         LA    15,=LB'0'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   562 LV= 1 LX
*MCALL #=   563 LV= 1          LX    R4,=LB'0'
         LA    15,=LB'0'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   563 LV= 1 LX
         LCXBR R0,R1
*MCALL #=   564 LV= 1          RT1   CCE
         DS    0H
RT1_TEST414      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE414
         LTORG 
RT1_CCE414      DS 0H
*MEXIT #=   564 LV= 1 RT1
         CXBR  R0,R4
*MCALL #=   565 LV= 1          RT1   CCE
         DS    0H
RT1_TEST415      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE415
         LTORG 
RT1_CCE415      DS 0H
*MEXIT #=   565 LV= 1 RT1
*MCALL #=   566 LV= 1          LX    R1,=LB'1'
         LA    15,=LB'1'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   566 LV= 1 LX
*MCALL #=   567 LV= 1          LX    R4,=LB'-1'
         LA    15,=LB'-1'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   567 LV= 1 LX
         LCXBR R0,R1
*MCALL #=   568 LV= 1          RT1   CCL
         DS    0H
RT1_TEST416      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL416
         LTORG 
RT1_CCL416      DS 0H
*MEXIT #=   568 LV= 1 RT1
         CXBR  R0,R4
*MCALL #=   569 LV= 1          RT1   CCE
         DS    0H
RT1_TEST417      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE417
         LTORG 
RT1_CCE417      DS 0H
*MEXIT #=   569 LV= 1 RT1
* B344 LEDBR
         LD    R1,=DB'123'
         LEDBR R0,R1
         CEB   R0,=EB'123'
*MCALL #=   570 LV= 1          RT1   CCE
         DS    0H
RT1_TEST418      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE418
         LTORG 
RT1_CCE418      DS 0H
*MEXIT #=   570 LV= 1 RT1
* B345 LDXBR
*MCALL #=   571 LV= 1          LX    R1,=LB'123'
         LA    15,=LB'123'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   571 LV= 1 LX
         LDXBR R0,R1
         CDB   R0,=DB'123'
*MCALL #=   572 LV= 1          RT1   CCE
         DS    0H
RT1_TEST419      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE419
         LTORG 
RT1_CCE419      DS 0H
*MEXIT #=   572 LV= 1 RT1
* B346 LEXBR
*MCALL #=   573 LV= 1          LX    R1,=LB'123'
         LA    15,=LB'123'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   573 LV= 1 LX
         LEXBR R0,R1
         CEB   R0,=EB'123'
*MCALL #=   574 LV= 1          RT1   CCE
         DS    0H
RT1_TEST420      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE420
         LTORG 
RT1_CCE420      DS 0H
*MEXIT #=   574 LV= 1 RT1
* B347 FIXBR
*MCALL #=   575 LV= 1          LX    R0,=LB'1.1' RPI 518 WAS R2
         LA    15,=LB'1.1'
         LD    R0,0(15)
         LD    R0+2,8(15)  RPI 229
*MEXIT #=   575 LV= 1 LX
         FIXBR R1,0,R0
*MCALL #=   576 LV= 1          LX    R4,=LB'1.0'
         LA    15,=LB'1.0'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   576 LV= 1 LX
         CXBR  R1,R4
*MCALL #=   577 LV= 1          RT1   CCE
         DS    0H
RT1_TEST421      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE421
         LTORG 
RT1_CCE421      DS 0H
*MEXIT #=   577 LV= 1 RT1
*MCALL #=   578 LV= 1          LX    R0,=LB'1.5' RPI 518 WAS R2
         LA    15,=LB'1.5'
         LD    R0,0(15)
         LD    R0+2,8(15)  RPI 229
*MEXIT #=   578 LV= 1 LX
         FIXBR R1,0,R0
*MCALL #=   579 LV= 1          LX    R4,=LB'2.0'
         LA    15,=LB'2.0'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   579 LV= 1 LX
         CXBR  R1,R4
*MCALL #=   580 LV= 1          RT1   CCE
         DS    0H
RT1_TEST422      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE422
         LTORG 
RT1_CCE422      DS 0H
*MEXIT #=   580 LV= 1 RT1
*MCALL #=   581 LV= 1          LX    R0,=LB'2.5' RPI 518 WAS R2
         LA    15,=LB'2.5'
         LD    R0,0(15)
         LD    R0+2,8(15)  RPI 229
*MEXIT #=   581 LV= 1 LX
         FIXBR R1,0,R0
*MCALL #=   582 LV= 1          LX    R4,=LB'2.0'
         LA    15,=LB'2.0'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   582 LV= 1 LX
         CXBR  R1,R4
*MCALL #=   583 LV= 1          RT1   CCE
         DS    0H
RT1_TEST423      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE423
         LTORG 
RT1_CCE423      DS 0H
*MEXIT #=   583 LV= 1 RT1
*MCALL #=   584 LV= 1          LX    R0,=LB'-1.5' RPI 518 WAS R2
         LA    15,=LB'-1.5'
         LD    R0,0(15)
         LD    R0+2,8(15)  RPI 229
*MEXIT #=   584 LV= 1 LX
         FIXBR R1,0,R0
*MCALL #=   585 LV= 1          LX    R4,=LB'-2.0'
         LA    15,=LB'-2.0'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   585 LV= 1 LX
         CXBR  R1,R4
*MCALL #=   586 LV= 1          RT1   CCE
         DS    0H
RT1_TEST424      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE424
         LTORG 
RT1_CCE424      DS 0H
*MEXIT #=   586 LV= 1 RT1
*MCALL #=   587 LV= 1          LX    R0,=LB'-2.5' RPI 518 WAS R2
         LA    15,=LB'-2.5'
         LD    R0,0(15)
         LD    R0+2,8(15)  RPI 229
*MEXIT #=   587 LV= 1 LX
         FIXBR R1,0,R0
*MCALL #=   588 LV= 1          LX    R4,=LB'-2.0'
         LA    15,=LB'-2.0'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   588 LV= 1 LX
         CXBR  R1,R4
*MCALL #=   589 LV= 1          RT1   CCE
         DS    0H
RT1_TEST425      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE425
         LTORG 
RT1_CCE425      DS 0H
*MEXIT #=   589 LV= 1 RT1
* B348 KXBR
*MCALL #=   590 LV= 1          LX    R0,=LB'-1'
         LA    15,=LB'-1'
         LD    R0,0(15)
         LD    R0+2,8(15)  RPI 229
*MEXIT #=   590 LV= 1 LX
*MCALL #=   591 LV= 1          LX    R1,=LB'1'
         LA    15,=LB'1'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   591 LV= 1 LX
         KXBR  R0,R1
*MCALL #=   592 LV= 1          RT1   CCL
         DS    0H
RT1_TEST426      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL426
         LTORG 
RT1_CCL426      DS 0H
*MEXIT #=   592 LV= 1 RT1
*MCALL #=   593 LV= 1          LX    R0,=LB'1'
         LA    15,=LB'1'
         LD    R0,0(15)
         LD    R0+2,8(15)  RPI 229
*MEXIT #=   593 LV= 1 LX
*MCALL #=   594 LV= 1          LX    R1,=LB'1'
         LA    15,=LB'1'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   594 LV= 1 LX
         KXBR  R0,R1
*MCALL #=   595 LV= 1          RT1   CCE
         DS    0H
RT1_TEST427      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE427
         LTORG 
RT1_CCE427      DS 0H
*MEXIT #=   595 LV= 1 RT1
*MCALL #=   596 LV= 1          LX    R0,=LB'1'
         LA    15,=LB'1'
         LD    R0,0(15)
         LD    R0+2,8(15)  RPI 229
*MEXIT #=   596 LV= 1 LX
*MCALL #=   597 LV= 1          LX    R1,=LB'-1'
         LA    15,=LB'-1'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   597 LV= 1 LX
         KXBR  R0,R1
*MCALL #=   598 LV= 1          RT1   CCH
         DS    0H
RT1_TEST428      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH428
         LTORG 
RT1_CCH428      DS 0H
*MEXIT #=   598 LV= 1 RT1
*MCALL #=   599 LV= 1          ESPIE SET,ESPIE_EXIT,7,PARAM=KXBR1 BFP OX
               VERFLOW FPCDXC=20
        LA     15,KXBR1
        IPM    0  GET CURRENT PGM MASK
        SPM    0 TURN ON ANY MASKS REQUIRED
        L      0,=B'00000001000000000000000000000000'
        LA     1,ESPIE_EXIT
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   599 LV= 1 ESPIE
*MCALL #=   600 LV= 1          LX    R0,=LB'1'
         LA    15,=LB'1'
         LD    R0,0(15)
         LD    R0+2,8(15)  RPI 229
*MEXIT #=   600 LV= 1 LX
*MCALL #=   601 LV= 1          LX    R1,LBMAX
         LA    15,LBMAX
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   601 LV= 1 LX
         KXBR  R0,R1
*MCALL #=   602 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   602 LV= 1 RT1
*MCALL #=   603 LV= 1 KXBR1    ESPIE RESET
KXBR1    DS    0H
        SR     15,15
        SR     1,1
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   603 LV= 1 ESPIE
         STFPC FPCREG
         CLI   FPCDXC,X'20'
*MCALL #=   604 LV= 1          RT1   CCE
         DS    0H
RT1_TEST430      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE430
         LTORG 
RT1_CCE430      DS 0H
*MEXIT #=   604 LV= 1 RT1
*MCALL #=   605 LV= 1          ESPIE SET,ESPIE_EXIT,7,PARAM=KXBR2 BFP UX
               NDERFLOW FPCDXC=10
        LA     15,KXBR2
        IPM    0  GET CURRENT PGM MASK
        SPM    0 TURN ON ANY MASKS REQUIRED
        L      0,=B'00000001000000000000000000000000'
        LA     1,ESPIE_EXIT
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   605 LV= 1 ESPIE
*MCALL #=   606 LV= 1          LX    R0,LBMIN
         LA    15,LBMIN
         LD    R0,0(15)
         LD    R0+2,8(15)  RPI 229
*MEXIT #=   606 LV= 1 LX
*MCALL #=   607 LV= 1          LX    R1,=LB'1'
         LA    15,=LB'1'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   607 LV= 1 LX
         KXBR  R0,R1
*MCALL #=   608 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   608 LV= 1 RT1
*MCALL #=   609 LV= 1 KXBR2    ESPIE RESET
KXBR2    DS    0H
        SR     15,15
        SR     1,1
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   609 LV= 1 ESPIE
         STFPC FPCREG
         CLI   FPCDXC,X'10'
*MCALL #=   610 LV= 1          RT1   CCE
         DS    0H
RT1_TEST432      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE432
         LTORG 
RT1_CCE432      DS 0H
*MEXIT #=   610 LV= 1 RT1
* B349 CXBR
*MCALL #=   611 LV= 1          LX    R0,=LB'-1'
         LA    15,=LB'-1'
         LD    R0,0(15)
         LD    R0+2,8(15)  RPI 229
*MEXIT #=   611 LV= 1 LX
*MCALL #=   612 LV= 1          LX    R1,=LB'1'
         LA    15,=LB'1'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   612 LV= 1 LX
         CXBR  R0,R1
*MCALL #=   613 LV= 1          RT1   CCL
         DS    0H
RT1_TEST433      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL433
         LTORG 
RT1_CCL433      DS 0H
*MEXIT #=   613 LV= 1 RT1
*MCALL #=   614 LV= 1          LX    R0,=LB'1'
         LA    15,=LB'1'
         LD    R0,0(15)
         LD    R0+2,8(15)  RPI 229
*MEXIT #=   614 LV= 1 LX
*MCALL #=   615 LV= 1          LX    R1,=LB'1'
         LA    15,=LB'1'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   615 LV= 1 LX
         CXBR  R0,R1
*MCALL #=   616 LV= 1          RT1   CCE
         DS    0H
RT1_TEST434      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE434
         LTORG 
RT1_CCE434      DS 0H
*MEXIT #=   616 LV= 1 RT1
*MCALL #=   617 LV= 1          LX    R0,=LB'1'
         LA    15,=LB'1'
         LD    R0,0(15)
         LD    R0+2,8(15)  RPI 229
*MEXIT #=   617 LV= 1 LX
*MCALL #=   618 LV= 1          LX    R1,=LB'-1'
         LA    15,=LB'-1'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   618 LV= 1 LX
         CXBR  R0,R1
*MCALL #=   619 LV= 1          RT1   CCH
         DS    0H
RT1_TEST435      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH435
         LTORG 
RT1_CCH435      DS 0H
*MEXIT #=   619 LV= 1 RT1
* B34A AXBR
*MCALL #=   620 LV= 1          LX    R0,=LB'3'
         LA    15,=LB'3'
         LD    R0,0(15)
         LD    R0+2,8(15)  RPI 229
*MEXIT #=   620 LV= 1 LX
*MCALL #=   621 LV= 1          LX    R1,=LB'2'
         LA    15,=LB'2'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   621 LV= 1 LX
         AXBR  R0,R1
*MCALL #=   622 LV= 1          RT1   CCH
         DS    0H
RT1_TEST436      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH436
         LTORG 
RT1_CCH436      DS 0H
*MEXIT #=   622 LV= 1 RT1
*MCALL #=   623 LV= 1          LX    R1,=LB'5'
         LA    15,=LB'5'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   623 LV= 1 LX
         CXBR  R0,R1
*MCALL #=   624 LV= 1          RT1   CCE
         DS    0H
RT1_TEST437      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE437
         LTORG 
RT1_CCE437      DS 0H
*MEXIT #=   624 LV= 1 RT1
*MCALL #=   625 LV= 1          LX    R0,=LB'1'
         LA    15,=LB'1'
         LD    R0,0(15)
         LD    R0+2,8(15)  RPI 229
*MEXIT #=   625 LV= 1 LX
*MCALL #=   626 LV= 1          LX    R1,=LB'-2'
         LA    15,=LB'-2'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   626 LV= 1 LX
         AXBR  R0,R1
*MCALL #=   627 LV= 1          RT1   CCL
         DS    0H
RT1_TEST438      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL438
         LTORG 
RT1_CCL438      DS 0H
*MEXIT #=   627 LV= 1 RT1
*MCALL #=   628 LV= 1          LX    R1,=LB'-1'
         LA    15,=LB'-1'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   628 LV= 1 LX
         CXBR  R0,R1
*MCALL #=   629 LV= 1          RT1   CCE
         DS    0H
RT1_TEST439      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE439
         LTORG 
RT1_CCE439      DS 0H
*MEXIT #=   629 LV= 1 RT1
*MCALL #=   630 LV= 1          LX    R0,=LB'1'
         LA    15,=LB'1'
         LD    R0,0(15)
         LD    R0+2,8(15)  RPI 229
*MEXIT #=   630 LV= 1 LX
*MCALL #=   631 LV= 1          LX    R1,=LB'-1'
         LA    15,=LB'-1'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   631 LV= 1 LX
         AXBR  R0,R1
*MCALL #=   632 LV= 1          RT1   CCE
         DS    0H
RT1_TEST440      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE440
         LTORG 
RT1_CCE440      DS 0H
*MEXIT #=   632 LV= 1 RT1
*MCALL #=   633 LV= 1          LX    R1,=LB'0'
         LA    15,=LB'0'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   633 LV= 1 LX
         CXBR  R0,R1
*MCALL #=   634 LV= 1          RT1   CCE
         DS    0H
RT1_TEST441      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE441
         LTORG 
RT1_CCE441      DS 0H
*MEXIT #=   634 LV= 1 RT1
*MCALL #=   635 LV= 1          ESPIE SET,ESPIE_EXIT,7,PARAM=AXBR1 BFP OX
               VERFLOW FPCDXC=20
        LA     15,AXBR1
        IPM    0  GET CURRENT PGM MASK
        SPM    0 TURN ON ANY MASKS REQUIRED
        L      0,=B'00000001000000000000000000000000'
        LA     1,ESPIE_EXIT
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   635 LV= 1 ESPIE
*MCALL #=   636 LV= 1          LX    R0,LBMAX
         LA    15,LBMAX
         LD    R0,0(15)
         LD    R0+2,8(15)  RPI 229
*MEXIT #=   636 LV= 1 LX
*MCALL #=   637 LV= 1          LX    R1,LBMAX
         LA    15,LBMAX
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   637 LV= 1 LX
         AXBR  R0,R1
*MCALL #=   638 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   638 LV= 1 RT1
*MCALL #=   639 LV= 1 AXBR1    ESPIE RESET
AXBR1    DS    0H
        SR     15,15
        SR     1,1
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   639 LV= 1 ESPIE
         STFPC FPCREG
         CLI   FPCDXC,X'20'
*MCALL #=   640 LV= 1          RT1   CCE
         DS    0H
RT1_TEST443      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE443
         LTORG 
RT1_CCE443      DS 0H
*MEXIT #=   640 LV= 1 RT1
*MCALL #=   641 LV= 1          WTO   'ESPIE BFP LB OVERFLOW OK'
         BRAS  1,*+(WTO#0641_EOT-*+1)/2*2
         DC    AL2(WTO#0641_EOT-*,0),C'ESPIE BFP LB OVERFLOW OK'
WTO#0641_EOT     EQU *
         SVC   35
*MEXIT #=   641 LV= 1 WTO
* B34B SXBR
*MCALL #=   642 LV= 1          LX    R0,=LB'3'
         LA    15,=LB'3'
         LD    R0,0(15)
         LD    R0+2,8(15)  RPI 229
*MEXIT #=   642 LV= 1 LX
*MCALL #=   643 LV= 1          LX    R1,=LB'2'
         LA    15,=LB'2'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   643 LV= 1 LX
         SXBR  R0,R1
*MCALL #=   644 LV= 1          RT1   CCH
         DS    0H
RT1_TEST444      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH444
         LTORG 
RT1_CCH444      DS 0H
*MEXIT #=   644 LV= 1 RT1
*MCALL #=   645 LV= 1          LX    R1,=LB'1'
         LA    15,=LB'1'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   645 LV= 1 LX
         CXBR  R0,R1
*MCALL #=   646 LV= 1          RT1   CCE
         DS    0H
RT1_TEST445      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE445
         LTORG 
RT1_CCE445      DS 0H
*MEXIT #=   646 LV= 1 RT1
*MCALL #=   647 LV= 1          LX    R0,=LB'1'
         LA    15,=LB'1'
         LD    R0,0(15)
         LD    R0+2,8(15)  RPI 229
*MEXIT #=   647 LV= 1 LX
*MCALL #=   648 LV= 1          LX    R1,=LB'2'
         LA    15,=LB'2'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   648 LV= 1 LX
         SXBR  R0,R1
*MCALL #=   649 LV= 1          RT1   CCL
         DS    0H
RT1_TEST446      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL446
         LTORG 
RT1_CCL446      DS 0H
*MEXIT #=   649 LV= 1 RT1
*MCALL #=   650 LV= 1          LX    R1,=LB'-1'
         LA    15,=LB'-1'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   650 LV= 1 LX
         CXBR  R0,R1
*MCALL #=   651 LV= 1          RT1   CCE
         DS    0H
RT1_TEST447      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE447
         LTORG 
RT1_CCE447      DS 0H
*MEXIT #=   651 LV= 1 RT1
*MCALL #=   652 LV= 1          LX    R0,=LB'1'
         LA    15,=LB'1'
         LD    R0,0(15)
         LD    R0+2,8(15)  RPI 229
*MEXIT #=   652 LV= 1 LX
*MCALL #=   653 LV= 1          LX    R1,=LB'1'
         LA    15,=LB'1'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   653 LV= 1 LX
         SXBR  R0,R1
*MCALL #=   654 LV= 1          RT1   CCE
         DS    0H
RT1_TEST448      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE448
         LTORG 
RT1_CCE448      DS 0H
*MEXIT #=   654 LV= 1 RT1
*MCALL #=   655 LV= 1          LX    R1,=LB'0'
         LA    15,=LB'0'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   655 LV= 1 LX
         CXBR  R0,R1
*MCALL #=   656 LV= 1          RT1   CCE
         DS    0H
RT1_TEST449      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE449
         LTORG 
RT1_CCE449      DS 0H
*MEXIT #=   656 LV= 1 RT1
*MCALL #=   657 LV= 1          ESPIE SET,ESPIE_EXIT,7,PARAM=SXBR1 BFP UX
               NDERFLOW FPCDXC=10
        LA     15,SXBR1
        IPM    0  GET CURRENT PGM MASK
        SPM    0 TURN ON ANY MASKS REQUIRED
        L      0,=B'00000001000000000000000000000000'
        LA     1,ESPIE_EXIT
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   657 LV= 1 ESPIE
*MCALL #=   658 LV= 1          LX    R0,LBMIN
         LA    15,LBMIN
         LD    R0,0(15)
         LD    R0+2,8(15)  RPI 229
*MEXIT #=   658 LV= 1 LX
*MCALL #=   659 LV= 1          LX    R1,LBMIN
         LA    15,LBMIN
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   659 LV= 1 LX
         AXBR  R0,R1
         SXBR  R0,R1
*MCALL #=   660 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   660 LV= 1 RT1
*MCALL #=   661 LV= 1 SXBR1    ESPIE RESET
SXBR1    DS    0H
        SR     15,15
        SR     1,1
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   661 LV= 1 ESPIE
         STFPC FPCREG
         CLI   FPCDXC,X'10'
*MCALL #=   662 LV= 1          RT1   CCE
         DS    0H
RT1_TEST451      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE451
         LTORG 
RT1_CCE451      DS 0H
*MEXIT #=   662 LV= 1 RT1
*MCALL #=   663 LV= 1          WTO   'ESPIE BFP LB UNDERFLOW OK'
         BRAS  1,*+(WTO#0663_EOT-*+1)/2*2
         DC    AL2(WTO#0663_EOT-*,0),C'ESPIE BFP LB UNDERFLOW OK'
WTO#0663_EOT     EQU *
         SVC   35
*MEXIT #=   663 LV= 1 WTO
         STFPC FPCREG
         OI    FPCREG,X'08' TURN ON BFP SIGNIFICANCE MASK IN FPC REG
         LFPC  FPCREG
*MCALL #=   664 LV= 1          ESPIE SET,ESPIE_EXIT,7,PARAM=SXBR2 BFP SX
               IG FPCDXC=08
        LA     15,SXBR2
        IPM    0  GET CURRENT PGM MASK
        SPM    0 TURN ON ANY MASKS REQUIRED
        L      0,=B'00000001000000000000000000000000'
        LA     1,ESPIE_EXIT
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   664 LV= 1 ESPIE
*MCALL #=   665 LV= 1          LX    R0,LBMIN
         LA    15,LBMIN
         LD    R0,0(15)
         LD    R0+2,8(15)  RPI 229
*MEXIT #=   665 LV= 1 LX
*MCALL #=   666 LV= 1          LX    R1,LBMIN
         LA    15,LBMIN
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   666 LV= 1 LX
         SXBR  R0,R1
*MCALL #=   667 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   667 LV= 1 RT1
*MCALL #=   668 LV= 1 SXBR2    ESPIE RESET
SXBR2    DS    0H
        SR     15,15
        SR     1,1
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   668 LV= 1 ESPIE
         STFPC FPCREG
         CLI   FPCDXC,X'08'
*MCALL #=   669 LV= 1          RT1   CCE
         DS    0H
RT1_TEST453      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE453
         LTORG 
RT1_CCE453      DS 0H
*MEXIT #=   669 LV= 1 RT1
*MCALL #=   670 LV= 1          WTO   'ESPIE BFP LB SIGNIFICANCE OK'
         BRAS  1,*+(WTO#0670_EOT-*+1)/2*2
         DC    AL2(WTO#0670_EOT-*,0),C'ESPIE BFP LB SIGNIFICANCE OK'
WTO#0670_EOT     EQU *
         SVC   35
*MEXIT #=   670 LV= 1 WTO
         XI    FPCREG,X'08' TURN IT BACK OFF
         LFPC  FPCREG
* B34C MXBR
*MCALL #=   671 LV= 1          LX    R0,=LB'2'
         LA    15,=LB'2'
         LD    R0,0(15)
         LD    R0+2,8(15)  RPI 229
*MEXIT #=   671 LV= 1 LX
*MCALL #=   672 LV= 1          LX    R1,=LB'3'
         LA    15,=LB'3'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   672 LV= 1 LX
         MXBR  R0,R1
*MCALL #=   673 LV= 1          LX    R1,=LB'6'
         LA    15,=LB'6'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   673 LV= 1 LX
         CXBR  R0,R1
*MCALL #=   674 LV= 1          RT1   CCE
         DS    0H
RT1_TEST454      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE454
         LTORG 
RT1_CCE454      DS 0H
*MEXIT #=   674 LV= 1 RT1
* B34D DXBR
*MCALL #=   675 LV= 1          LX    R0,=LB'3'
         LA    15,=LB'3'
         LD    R0,0(15)
         LD    R0+2,8(15)  RPI 229
*MEXIT #=   675 LV= 1 LX
*MCALL #=   676 LV= 1          LX    R1,=LB'2'
         LA    15,=LB'2'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   676 LV= 1 LX
         DXBR  R0,R1
*MCALL #=   677 LV= 1          LX    R1,=LB'1.5'
         LA    15,=LB'1.5'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   677 LV= 1 LX
         CXBR  R0,R1
*MCALL #=   678 LV= 1          RT1   CCE
         DS    0H
RT1_TEST455      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE455
         LTORG 
RT1_CCE455      DS 0H
*MEXIT #=   678 LV= 1 RT1
*MCALL #=   679 LV= 1          ESPIE SET,ESPIE_EXIT,7,PARAM=DXBR1 BFP DX
               IVIDE FPCDXC=40
        LA     15,DXBR1
        IPM    0  GET CURRENT PGM MASK
        SPM    0 TURN ON ANY MASKS REQUIRED
        L      0,=B'00000001000000000000000000000000'
        LA     1,ESPIE_EXIT
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   679 LV= 1 ESPIE
*MCALL #=   680 LV= 1          LX    R0,=LB'1'
         LA    15,=LB'1'
         LD    R0,0(15)
         LD    R0+2,8(15)  RPI 229
*MEXIT #=   680 LV= 1 LX
*MCALL #=   681 LV= 1          LX    R1,=LB'0'
         LA    15,=LB'0'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   681 LV= 1 LX
         DXBR  R0,R1
*MCALL #=   682 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   682 LV= 1 RT1
*MCALL #=   683 LV= 1 DXBR1    ESPIE RESET
DXBR1    DS    0H
        SR     15,15
        SR     1,1
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   683 LV= 1 ESPIE
         STFPC FPCREG
         CLI   FPCDXC,X'40'
*MCALL #=   684 LV= 1          RT1   CCE
         DS    0H
RT1_TEST457      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE457
         LTORG 
RT1_CCE457      DS 0H
*MEXIT #=   684 LV= 1 RT1
*MCALL #=   685 LV= 1          WTO   'ESPIE BFP LB DIVIDE OK'
         BRAS  1,*+(WTO#0685_EOT-*+1)/2*2
         DC    AL2(WTO#0685_EOT-*,0),C'ESPIE BFP LB DIVIDE OK'
WTO#0685_EOT     EQU *
         SVC   35
*MEXIT #=   685 LV= 1 WTO
* B350 TBEDR
         LD    R1,=DH'123'
         TBEDR R0,0,R1
         CEB   R0,=EB'123'
*MCALL #=   686 LV= 1          RT1   CCE
         DS    0H
RT1_TEST458      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE458
         LTORG 
RT1_CCE458      DS 0H
*MEXIT #=   686 LV= 1 RT1
* B351 TBDR
         LD    R1,=DH'123'
         TBDR  R0,0,R1
         CDB   R0,=DB'123'
*MCALL #=   687 LV= 1          RT1   CCE
         DS    0H
RT1_TEST459      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE459
         LTORG 
RT1_CCE459      DS 0H
*MEXIT #=   687 LV= 1 RT1
* B353 DIEBR
         LE    R1,=EB'7'
         LE    R2,=EB'2'
         DIEBR R1,R3,R2,0
*MCALL #=   688 LV= 1          RT1   CCE
         DS    0H
RT1_TEST460      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE460
         LTORG 
RT1_CCE460      DS 0H
*MEXIT #=   688 LV= 1 RT1
         CEB   R1,=EB'1'
*MCALL #=   689 LV= 1          RT1   CCE
         DS    0H
RT1_TEST461      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE461
         LTORG 
RT1_CCE461      DS 0H
*MEXIT #=   689 LV= 1 RT1
         CEB   R3,=EB'3'
*MCALL #=   690 LV= 1          RT1   CCE
         DS    0H
RT1_TEST462      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE462
         LTORG 
RT1_CCE462      DS 0H
*MEXIT #=   690 LV= 1 RT1
* B357 FIEBR
         LE    R2,=EB'1.1'
         FIEBR R1,0,R2
         CEB   R1,=EB'1.0'
*MCALL #=   691 LV= 1          RT1   CCE
         DS    0H
RT1_TEST463      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE463
         LTORG 
RT1_CCE463      DS 0H
*MEXIT #=   691 LV= 1 RT1
         LE    R2,=EB'1.5'
         FIEBR R1,0,R2
         CEB   R1,=EB'2.0'
*MCALL #=   692 LV= 1          RT1   CCE
         DS    0H
RT1_TEST464      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE464
         LTORG 
RT1_CCE464      DS 0H
*MEXIT #=   692 LV= 1 RT1
         LE    R2,=EB'2.5'
         FIEBR R1,0,R2
         CEB   R1,=EB'2.0'
*MCALL #=   693 LV= 1          RT1   CCE
         DS    0H
RT1_TEST465      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE465
         LTORG 
RT1_CCE465      DS 0H
*MEXIT #=   693 LV= 1 RT1
         LE    R2,=EB'-1.5'
         FIEBR R1,0,R2
         CEB   R1,=EB'-2.0'
*MCALL #=   694 LV= 1          RT1   CCE
         DS    0H
RT1_TEST466      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE466
         LTORG 
RT1_CCE466      DS 0H
*MEXIT #=   694 LV= 1 RT1
         LE    R2,=EB'-2.5'
         FIEBR R1,0,R2
         CEB   R1,=EB'-2.0'
*MCALL #=   695 LV= 1          RT1   CCE
         DS    0H
RT1_TEST467      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE467
         LTORG 
RT1_CCE467      DS 0H
*MEXIT #=   695 LV= 1 RT1
* B358 THDER
         LD    R1,=EB'123'
         THDER R0,R1
         CD    R0,=DH'123'
*MCALL #=   696 LV= 1          RT1   CCE
         DS    0H
RT1_TEST468      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE468
         LTORG 
RT1_CCE468      DS 0H
*MEXIT #=   696 LV= 1 RT1
* B359 THDR
         LD    R1,=DB'123'
         THDR  R0,R1
         CD    R0,=DH'123'
*MCALL #=   697 LV= 1          RT1   CCE
         DS    0H
RT1_TEST469      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE469
         LTORG 
RT1_CCE469      DS 0H
*MEXIT #=   697 LV= 1 RT1
* B35B DIDBR
         LD    R1,=DB'7'
         LD    R2,=DB'2'
         DIDBR R1,R3,R2,0
*MCALL #=   698 LV= 1          RT1   CCE
         DS    0H
RT1_TEST470      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE470
         LTORG 
RT1_CCE470      DS 0H
*MEXIT #=   698 LV= 1 RT1
         CDB   R1,=DB'1'
*MCALL #=   699 LV= 1          RT1   CCE
         DS    0H
RT1_TEST471      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE471
         LTORG 
RT1_CCE471      DS 0H
*MEXIT #=   699 LV= 1 RT1
         CDB   R3,=DB'3'
*MCALL #=   700 LV= 1          RT1   CCE
         DS    0H
RT1_TEST472      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE472
         LTORG 
RT1_CCE472      DS 0H
*MEXIT #=   700 LV= 1 RT1
* B35F FIDBR
         LD    R2,=DB'1.1'
         FIDBR R1,0,R2
         CDB   R1,=DB'1.0'
*MCALL #=   701 LV= 1          RT1   CCE
         DS    0H
RT1_TEST473      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE473
         LTORG 
RT1_CCE473      DS 0H
*MEXIT #=   701 LV= 1 RT1
         LD    R2,=DB'1.5'
         FIDBR R1,0,R2
         CDB   R1,=DB'2.0'
*MCALL #=   702 LV= 1          RT1   CCE
         DS    0H
RT1_TEST474      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE474
         LTORG 
RT1_CCE474      DS 0H
*MEXIT #=   702 LV= 1 RT1
         LD    R2,=DB'2.5'
         FIDBR R1,0,R2
         CDB   R1,=DB'2.0'
*MCALL #=   703 LV= 1          RT1   CCE
         DS    0H
RT1_TEST475      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE475
         LTORG 
RT1_CCE475      DS 0H
*MEXIT #=   703 LV= 1 RT1
         LD    R2,=DB'-1.5'
         FIDBR R1,0,R2
         CDB   R1,=DB'-2.0'
*MCALL #=   704 LV= 1          RT1   CCE
         DS    0H
RT1_TEST476      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE476
         LTORG 
RT1_CCE476      DS 0H
*MEXIT #=   704 LV= 1 RT1
         LD    R2,=DB'-2.5'
         FIDBR R1,0,R2
         CDB   R1,=DB'-2.0'
*MCALL #=   705 LV= 1          RT1   CCE
         DS    0H
RT1_TEST477      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE477
         LTORG 
RT1_CCE477      DS 0H
*MEXIT #=   705 LV= 1 RT1
* B360 LPXR
*MCALL #=   706 LV= 1          LX    R1,=LH'-1'
         LA    15,=LH'-1'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   706 LV= 1 LX
*MCALL #=   707 LV= 1          LX    R4,=LH'1'
         LA    15,=LH'1'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   707 LV= 1 LX
         LPXR  R0,R1
*MCALL #=   708 LV= 1          RT1   CCH
         DS    0H
RT1_TEST478      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH478
         LTORG 
RT1_CCH478      DS 0H
*MEXIT #=   708 LV= 1 RT1
         CXR   R0,R4
*MCALL #=   709 LV= 1          RT1   CCE
         DS    0H
RT1_TEST479      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE479
         LTORG 
RT1_CCE479      DS 0H
*MEXIT #=   709 LV= 1 RT1
*MCALL #=   710 LV= 1          LX    R1,=LH'0'
         LA    15,=LH'0'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   710 LV= 1 LX
*MCALL #=   711 LV= 1          LX    R4,=LH'0'
         LA    15,=LH'0'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   711 LV= 1 LX
         LPXR  R0,R1
*MCALL #=   712 LV= 1          RT1   CCE
         DS    0H
RT1_TEST480      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE480
         LTORG 
RT1_CCE480      DS 0H
*MEXIT #=   712 LV= 1 RT1
         CXR   R0,R4
*MCALL #=   713 LV= 1          RT1   CCE
         DS    0H
RT1_TEST481      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE481
         LTORG 
RT1_CCE481      DS 0H
*MEXIT #=   713 LV= 1 RT1
* B361 LNXR
*MCALL #=   714 LV= 1          LX    R1,=LH'1'
         LA    15,=LH'1'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   714 LV= 1 LX
*MCALL #=   715 LV= 1          LX    R4,=LH'-1'
         LA    15,=LH'-1'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   715 LV= 1 LX
         LNXR  R0,R1
*MCALL #=   716 LV= 1          RT1   CCL
         DS    0H
RT1_TEST482      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL482
         LTORG 
RT1_CCL482      DS 0H
*MEXIT #=   716 LV= 1 RT1
         CXR   R0,R4
*MCALL #=   717 LV= 1          RT1   CCE
         DS    0H
RT1_TEST483      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE483
         LTORG 
RT1_CCE483      DS 0H
*MEXIT #=   717 LV= 1 RT1
*MCALL #=   718 LV= 1          LX    R1,=LH'0'
         LA    15,=LH'0'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   718 LV= 1 LX
*MCALL #=   719 LV= 1          LX    R4,=LH'0'
         LA    15,=LH'0'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   719 LV= 1 LX
         LNXR  R0,R1
*MCALL #=   720 LV= 1          RT1   CCE
         DS    0H
RT1_TEST484      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE484
         LTORG 
RT1_CCE484      DS 0H
*MEXIT #=   720 LV= 1 RT1
         CXR   R0,R4
*MCALL #=   721 LV= 1          RT1   CCE
         DS    0H
RT1_TEST485      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE485
         LTORG 
RT1_CCE485      DS 0H
*MEXIT #=   721 LV= 1 RT1
* B362 LTXR
*MCALL #=   722 LV= 1          LX    R1,=LH'1'
         LA    15,=LH'1'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   722 LV= 1 LX
*MCALL #=   723 LV= 1          LX    R4,=LH'1'
         LA    15,=LH'1'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   723 LV= 1 LX
         LTXR  R0,R1
*MCALL #=   724 LV= 1          RT1   CCH
         DS    0H
RT1_TEST486      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH486
         LTORG 
RT1_CCH486      DS 0H
*MEXIT #=   724 LV= 1 RT1
         CXR   R0,R4
*MCALL #=   725 LV= 1          RT1   CCE
         DS    0H
RT1_TEST487      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE487
         LTORG 
RT1_CCE487      DS 0H
*MEXIT #=   725 LV= 1 RT1
*MCALL #=   726 LV= 1          LX    R1,=LH'0'
         LA    15,=LH'0'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   726 LV= 1 LX
*MCALL #=   727 LV= 1          LX    R4,=LH'0'
         LA    15,=LH'0'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   727 LV= 1 LX
         LTXR  R0,R1
*MCALL #=   728 LV= 1          RT1   CCE
         DS    0H
RT1_TEST488      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE488
         LTORG 
RT1_CCE488      DS 0H
*MEXIT #=   728 LV= 1 RT1
         CXR   R0,R4
*MCALL #=   729 LV= 1          RT1   CCE
         DS    0H
RT1_TEST489      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE489
         LTORG 
RT1_CCE489      DS 0H
*MEXIT #=   729 LV= 1 RT1
*MCALL #=   730 LV= 1          LX    R1,=LH'-1'
         LA    15,=LH'-1'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   730 LV= 1 LX
*MCALL #=   731 LV= 1          LX    R4,=LH'-1'
         LA    15,=LH'-1'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   731 LV= 1 LX
         LTXR  R0,R1
*MCALL #=   732 LV= 1          RT1   CCL
         DS    0H
RT1_TEST490      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL490
         LTORG 
RT1_CCL490      DS 0H
*MEXIT #=   732 LV= 1 RT1
         CXR   R0,R4
*MCALL #=   733 LV= 1          RT1   CCE
         DS    0H
RT1_TEST491      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE491
         LTORG 
RT1_CCE491      DS 0H
*MEXIT #=   733 LV= 1 RT1
* B363 LCXR
*MCALL #=   734 LV= 1          LX    R1,=LH'-1'
         LA    15,=LH'-1'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   734 LV= 1 LX
*MCALL #=   735 LV= 1          LX    R4,=LH'1'
         LA    15,=LH'1'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   735 LV= 1 LX
         LCXR  R0,R1
*MCALL #=   736 LV= 1          RT1   CCH
         DS    0H
RT1_TEST492      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH492
         LTORG 
RT1_CCH492      DS 0H
*MEXIT #=   736 LV= 1 RT1
         CXR   R0,R4
*MCALL #=   737 LV= 1          RT1   CCE
         DS    0H
RT1_TEST493      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE493
         LTORG 
RT1_CCE493      DS 0H
*MEXIT #=   737 LV= 1 RT1
*MCALL #=   738 LV= 1          LX    R1,=LH'0'
         LA    15,=LH'0'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   738 LV= 1 LX
*MCALL #=   739 LV= 1          LX    R4,=LH'0'
         LA    15,=LH'0'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   739 LV= 1 LX
         LCXR  R0,R1
*MCALL #=   740 LV= 1          RT1   CCE
         DS    0H
RT1_TEST494      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE494
         LTORG 
RT1_CCE494      DS 0H
*MEXIT #=   740 LV= 1 RT1
         CXR   R0,R4
*MCALL #=   741 LV= 1          RT1   CCE
         DS    0H
RT1_TEST495      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE495
         LTORG 
RT1_CCE495      DS 0H
*MEXIT #=   741 LV= 1 RT1
*MCALL #=   742 LV= 1          LX    R1,=LH'1'
         LA    15,=LH'1'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   742 LV= 1 LX
*MCALL #=   743 LV= 1          LX    R4,=LH'-1'
         LA    15,=LH'-1'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   743 LV= 1 LX
         LCXR  R0,R1
*MCALL #=   744 LV= 1          RT1   CCL
         DS    0H
RT1_TEST496      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL496
         LTORG 
RT1_CCL496      DS 0H
*MEXIT #=   744 LV= 1 RT1
         CXR   R0,R4
*MCALL #=   745 LV= 1          RT1   CCE
         DS    0H
RT1_TEST497      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE497
         LTORG 
RT1_CCE497      DS 0H
*MEXIT #=   745 LV= 1 RT1
* B365 LXR
*MCALL #=   746 LV= 1          LX    R1,=LH'123'
         LA    15,=LH'123'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   746 LV= 1 LX
         LXR   R0,R1
         CXR   R0,R1
*MCALL #=   747 LV= 1          RT1   CCE
         DS    0H
RT1_TEST498      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE498
         LTORG 
RT1_CCE498      DS 0H
*MEXIT #=   747 LV= 1 RT1
* B366 LEXR
*MCALL #=   748 LV= 1          LX    R1,=LH'123'
         LA    15,=LH'123'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   748 LV= 1 LX
         LEXR  R0,R1
         CE    R0,=EH'123'
*MCALL #=   749 LV= 1          RT1   CCE
         DS    0H
RT1_TEST499      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE499
         LTORG 
RT1_CCE499      DS 0H
*MEXIT #=   749 LV= 1 RT1
* B367 FIXR
*MCALL #=   750 LV= 1          LX    R1,=LH'1.5'
         LA    15,=LH'1.5'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   750 LV= 1 LX
         FIXR  R0,R1
*MCALL #=   751 LV= 1          LX    R4,=LH'1.0'
         LA    15,=LH'1.0'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   751 LV= 1 LX
         CXR   R0,R4
*MCALL #=   752 LV= 1          RT1   CCE
         DS    0H
RT1_TEST500      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE500
         LTORG 
RT1_CCE500      DS 0H
*MEXIT #=   752 LV= 1 RT1
* B369 CXR
*MCALL #=   753 LV= 1          LX    R0,=LH'1'
         LA    15,=LH'1'
         LD    R0,0(15)
         LD    R0+2,8(15)  RPI 229
*MEXIT #=   753 LV= 1 LX
*MCALL #=   754 LV= 1          STX   R0,LWORK
         LA    15,LWORK
         STD   R0,0(15)
         STD   R0+2,8(15)  RPI 229
*MEXIT #=   754 LV= 1 STX
         CLC   LWORK,=X'41100000000000003300000000000000'
*MCALL #=   755 LV= 1          RT1   CCE
         DS    0H
RT1_TEST501      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE501
         LTORG 
RT1_CCE501      DS 0H
*MEXIT #=   755 LV= 1 RT1
*MCALL #=   756 LV= 1          LX    R1,=X'4110000000000000330000000000X
               0000'
         LA    15,=X'41100000000000003300000000000000'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   756 LV= 1 LX
         CXR   R0,R1
*MCALL #=   757 LV= 1          RT1   CCE
         DS    0H
RT1_TEST502      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE502
         LTORG 
RT1_CCE502      DS 0H
*MEXIT #=   757 LV= 1 RT1
*MCALL #=   758 LV= 1          LX    R0,=LH'1'
         LA    15,=LH'1'
         LD    R0,0(15)
         LD    R0+2,8(15)  RPI 229
*MEXIT #=   758 LV= 1 LX
*MCALL #=   759 LV= 1          LX    R1,=LH'2'
         LA    15,=LH'2'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   759 LV= 1 LX
         CXR   R0,R1
*MCALL #=   760 LV= 1          RT1   CCL
         DS    0H
RT1_TEST503      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL503
         LTORG 
RT1_CCL503      DS 0H
*MEXIT #=   760 LV= 1 RT1
*MCALL #=   761 LV= 1          LX    R0,=LH'2'
         LA    15,=LH'2'
         LD    R0,0(15)
         LD    R0+2,8(15)  RPI 229
*MEXIT #=   761 LV= 1 LX
*MCALL #=   762 LV= 1          LX    R1,=LH'1'
         LA    15,=LH'1'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   762 LV= 1 LX
         CXR   R0,R1
*MCALL #=   763 LV= 1          RT1   CCH
         DS    0H
RT1_TEST504      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH504
         LTORG 
RT1_CCH504      DS 0H
*MEXIT #=   763 LV= 1 RT1
* B374 LZER
         LE    R1,=EH'1'
         LZER  R1
         CE    R1,=EH'0'
*MCALL #=   764 LV= 1          RT1   CCE
         DS    0H
RT1_TEST505      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE505
         LTORG 
RT1_CCE505      DS 0H
*MEXIT #=   764 LV= 1 RT1
* B375 LZDR
         LD    R1,=DH'1'
         LZDR  R1
         CD    R1,=DH'0'
*MCALL #=   765 LV= 1          RT1   CCE
         DS    0H
RT1_TEST506      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE506
         LTORG 
RT1_CCE506      DS 0H
*MEXIT #=   765 LV= 1 RT1
* B376 LZXR
*MCALL #=   766 LV= 1          LX    R0,=LH'1'
         LA    15,=LH'1'
         LD    R0,0(15)
         LD    R0+2,8(15)  RPI 229
*MEXIT #=   766 LV= 1 LX
         LZXR  R0
*MCALL #=   767 LV= 1          LX    R4,=LH'0'
         LA    15,=LH'0'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   767 LV= 1 LX
         CXR   R0,R4
*MCALL #=   768 LV= 1          RT1   CCE
         DS    0H
RT1_TEST507      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE507
         LTORG 
RT1_CCE507      DS 0H
*MEXIT #=   768 LV= 1 RT1
* B377 FIER
         LE    R2,=EH'1.5'
         FIER  R1,R2
         CE    R1,=EH'1.0'
*MCALL #=   769 LV= 1          RT1   CCE
         DS    0H
RT1_TEST508      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE508
         LTORG 
RT1_CCE508      DS 0H
*MEXIT #=   769 LV= 1 RT1
* B37F FIDR
         LD    R2,=DH'1.5'
         FIDR  R1,R2
         CD    R1,=DH'1.0'
*MCALL #=   770 LV= 1          RT1   CCE
         DS    0H
RT1_TEST509      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE509
         LTORG 
RT1_CCE509      DS 0H
*MEXIT #=   770 LV= 1 RT1
* B394 CEFBR
         L     R2,=F'123'
         CEFBR R0,R2
         CEB   R0,=EB'123'
*MCALL #=   771 LV= 1          RT1   CCE
         DS    0H
RT1_TEST510      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE510
         LTORG 
RT1_CCE510      DS 0H
*MEXIT #=   771 LV= 1 RT1
* B395 CDFBR
         L     R2,=F'123'
         CDFBR R0,R2
         CDB   R0,=DB'123'
*MCALL #=   772 LV= 1          RT1   CCE
         DS    0H
RT1_TEST511      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE511
         LTORG 
RT1_CCE511      DS 0H
*MEXIT #=   772 LV= 1 RT1
* B396 CXFBR
         L     R2,=F'123'
         CXFBR R0,R2
*MCALL #=   773 LV= 1          LX    R4,=LB'123'
         LA    15,=LB'123'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   773 LV= 1 LX
         CXBR  R0,R4
*MCALL #=   774 LV= 1          RT1   CCE
         DS    0H
RT1_TEST512      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE512
         LTORG 
RT1_CCE512      DS 0H
*MEXIT #=   774 LV= 1 RT1
* B398 CFEBR
         LE    R2,=EB'123'
         CFEBR R0,0,R2
         C     R0,=F'123'
*MCALL #=   775 LV= 1          RT1   CCE
         DS    0H
RT1_TEST513      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE513
         LTORG 
RT1_CCE513      DS 0H
*MEXIT #=   775 LV= 1 RT1
* B399 CFDBR
         LD    R2,=DB'123'
         CFDBR R0,0,R2
         C     R0,=F'123'
*MCALL #=   776 LV= 1          RT1   CCE
         DS    0H
RT1_TEST514      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE514
         LTORG 
RT1_CCE514      DS 0H
*MEXIT #=   776 LV= 1 RT1
* B39A CFXBR
*MCALL #=   777 LV= 1          LX    R1,=LB'123'
         LA    15,=LB'123'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   777 LV= 1 LX
         CFXBR R0,0,R1
         C     R0,=F'123'
*MCALL #=   778 LV= 1          RT1   CCE
         DS    0H
RT1_TEST515      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE515
         LTORG 
RT1_CCE515      DS 0H
*MEXIT #=   778 LV= 1 RT1
* B3A4 CEGBR
         LG    R2,=FL8'123'
         CEGBR R0,R2
         CEB   R0,=EB'123'
*MCALL #=   779 LV= 1          RT1   CCE
         DS    0H
RT1_TEST516      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE516
         LTORG 
RT1_CCE516      DS 0H
*MEXIT #=   779 LV= 1 RT1
* B3A5 CDGBR
         LG    R2,=FL8'123'
         CDGBR R0,R2
         CDB   R0,=DB'123'
*MCALL #=   780 LV= 1          RT1   CCE
         DS    0H
RT1_TEST517      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE517
         LTORG 
RT1_CCE517      DS 0H
*MEXIT #=   780 LV= 1 RT1
* B3A4 CXGBR
         LG    R2,=FL8'123'
         CXGBR R0,R2
*MCALL #=   781 LV= 1          LX    R4,=LB'123'
         LA    15,=LB'123'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   781 LV= 1 LX
         CXBR  R0,R4
*MCALL #=   782 LV= 1          RT1   CCE
         DS    0H
RT1_TEST518      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE518
         LTORG 
RT1_CCE518      DS 0H
*MEXIT #=   782 LV= 1 RT1
* B3A8 CGEBR
         LE    R2,=EB'123'
         CFEBR R0,0,R2
         CL    R0,=F'123'    RPI 819 WAS CG IN ERROR (CAUGHT BY F4'S)
*MCALL #=   783 LV= 1          RT1   CCE
         DS    0H
RT1_TEST519      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE519
         LTORG 
RT1_CCE519      DS 0H
*MEXIT #=   783 LV= 1 RT1
* B3A9 CGDBR
         LD    R2,=DB'123'
         CGDBR R0,0,R2
         CL    R0,=F'123'    RPI 819 WAS CG IN ERROR (CAUGHT BY F4'S)
*MCALL #=   784 LV= 1          RT1   CCE
         DS    0H
RT1_TEST520      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE520
         LTORG 
RT1_CCE520      DS 0H
*MEXIT #=   784 LV= 1 RT1
* B3AA CGXBR
*MCALL #=   785 LV= 1          LX    R1,=LB'123'
         LA    15,=LB'123'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   785 LV= 1 LX
         CGXBR R0,0,R1
         CL    R0,=F'123'    RPI 819 WAS CG IN ERROR (CAUGHT BY F4'S)
*MCALL #=   786 LV= 1          RT1   CCE
         DS    0H
RT1_TEST521      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE521
         LTORG 
RT1_CCE521      DS 0H
*MEXIT #=   786 LV= 1 RT1
* B3B4 CEFR
         L     R2,=F'123'
         CEFR  R0,R2
         CE    R0,=EH'123'
*MCALL #=   787 LV= 1          RT1   CCE
         DS    0H
RT1_TEST522      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE522
         LTORG 
RT1_CCE522      DS 0H
*MEXIT #=   787 LV= 1 RT1
* B3B5 CDFR
         L     R2,=F'123'
         CDFR  R0,R2
         CD    R0,=DH'123'
*MCALL #=   788 LV= 1          RT1   CCE
         DS    0H
RT1_TEST523      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE523
         LTORG 
RT1_CCE523      DS 0H
*MEXIT #=   788 LV= 1 RT1
* B3B6 CXFR
         L     R2,=F'123'
         CXFR  R0,R2
*MCALL #=   789 LV= 1          LX    R4,=LH'123'
         LA    15,=LH'123'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   789 LV= 1 LX
         CXR   R0,R4
*MCALL #=   790 LV= 1          RT1   CCE
         DS    0H
RT1_TEST524      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE524
         LTORG 
RT1_CCE524      DS 0H
*MEXIT #=   790 LV= 1 RT1
* B3B8 CFER
         LE    R2,=EH'123'
         CFER  R0,0,R2
         C     R0,=F'123'
*MCALL #=   791 LV= 1          RT1   CCE
         DS    0H
RT1_TEST525      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE525
         LTORG 
RT1_CCE525      DS 0H
*MEXIT #=   791 LV= 1 RT1
* B3B9 CFDR
         LD    R2,=DH'123'
         CFDR  R0,0,R2
         C     R0,=F'123'
*MCALL #=   792 LV= 1          RT1   CCE
         DS    0H
RT1_TEST526      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE526
         LTORG 
RT1_CCE526      DS 0H
*MEXIT #=   792 LV= 1 RT1
* B3BA CFXR
*MCALL #=   793 LV= 1          LX    R1,=LH'123'
         LA    15,=LH'123'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   793 LV= 1 LX
         CFXR  R0,0,R1
         C     R0,=F'123'
*MCALL #=   794 LV= 1          RT1   CCE
         DS    0H
RT1_TEST527      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE527
         LTORG 
RT1_CCE527      DS 0H
*MEXIT #=   794 LV= 1 RT1
* B3C4 CEGR
         LG    R2,=FL8'123'
         CEGR  R0,R2
         CE    R0,=EH'123'
*MCALL #=   795 LV= 1          RT1   CCE
         DS    0H
RT1_TEST528      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE528
         LTORG 
RT1_CCE528      DS 0H
*MEXIT #=   795 LV= 1 RT1
* B3C5 CDGR
         LG    R2,=FL8'123'
         CDGR  R0,R2
         CD    R0,=DH'123'
*MCALL #=   796 LV= 1          RT1   CCE
         DS    0H
RT1_TEST529      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE529
         LTORG 
RT1_CCE529      DS 0H
*MEXIT #=   796 LV= 1 RT1
* B3C6 CXGR
         LG    R2,=FL8'123'
         CXGR  R0,R2
*MCALL #=   797 LV= 1          LX    R4,=LH'123'
         LA    15,=LH'123'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   797 LV= 1 LX
         CXR   R0,R4
*MCALL #=   798 LV= 1          RT1   CCE
         DS    0H
RT1_TEST530      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE530
         LTORG 
RT1_CCE530      DS 0H
*MEXIT #=   798 LV= 1 RT1
* B3C8 CGER
         LE    R2,=EH'123'
         CFER  R0,0,R2
         CG    R0,=FL8'123'
*MCALL #=   799 LV= 1          RT1   CCE
         DS    0H
RT1_TEST531      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE531
         LTORG 
RT1_CCE531      DS 0H
*MEXIT #=   799 LV= 1 RT1
* B3C9 CGDR
         LD    R2,=DH'123'
         CGDR  R0,0,R2
         CG    R0,=FL8'123'
*MCALL #=   800 LV= 1          RT1   CCE
         DS    0H
RT1_TEST532      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE532
         LTORG 
RT1_CCE532      DS 0H
*MEXIT #=   800 LV= 1 RT1
* B3CA CGXR
*MCALL #=   801 LV= 1          LX    R1,=LH'123'
         LA    15,=LH'123'
         LD    R1,0(15)
         LD    R1+2,8(15)  RPI 229
*MEXIT #=   801 LV= 1 LX
         CGXR  R0,0,R1
         CG    R0,=FL8'123'
*MCALL #=   802 LV= 1          RT1   CCE
         DS    0H
RT1_TEST533      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE533
         LTORG 
RT1_CCE533      DS 0H
*MEXIT #=   802 LV= 1 RT1
* ED04 LDEB
         LDEB  R0,=EB'1'
         CDB   R0,=DB'1'
*MCALL #=   803 LV= 1          RT1   CCE
         DS    0H
RT1_TEST534      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE534
         LTORG 
RT1_CCE534      DS 0H
*MEXIT #=   803 LV= 1 RT1
* ED05 LXDB
         LXDB  R0,=DB'1'
*MCALL #=   804 LV= 1          LX    R4,=LB'1'
         LA    15,=LB'1'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   804 LV= 1 LX
         CXBR  R0,R4
*MCALL #=   805 LV= 1          RT1   CCE
         DS    0H
RT1_TEST535      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE535
         LTORG 
RT1_CCE535      DS 0H
*MEXIT #=   805 LV= 1 RT1
* ED06 LXEB
         LXEB  R0,=EB'1'
*MCALL #=   806 LV= 1          LX    R4,=LB'1'
         LA    15,=LB'1'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   806 LV= 1 LX
         CXBR  R0,R4
*MCALL #=   807 LV= 1          RT1   CCE
         DS    0H
RT1_TEST536      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE536
         LTORG 
RT1_CCE536      DS 0H
*MEXIT #=   807 LV= 1 RT1
* ED07 MXDB
         LD    R0,=DB'20'
         MXDB  R0,=DB'30'
*MCALL #=   808 LV= 1          LX    R4,=LB'600'
         LA    15,=LB'600'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   808 LV= 1 LX
         CXBR  R0,R4
*MCALL #=   809 LV= 1          RT1   CCE
         DS    0H
RT1_TEST537      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE537
         LTORG 
RT1_CCE537      DS 0H
*MEXIT #=   809 LV= 1 RT1
         LD    R0,=DB'10'
         MXDB  R0,=DB'-20'
*MCALL #=   810 LV= 1          LX    R4,=LB'-200'
         LA    15,=LB'-200'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   810 LV= 1 LX
         CXBR  R0,R4
*MCALL #=   811 LV= 1          RT1   CCE
         DS    0H
RT1_TEST538      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE538
         LTORG 
RT1_CCE538      DS 0H
*MEXIT #=   811 LV= 1 RT1
         LD    R0,=DB'-0.5'
         MXDB  R0,=DB'-0.5'
*MCALL #=   812 LV= 1          LX    R4,=LB'.25'
         LA    15,=LB'.25'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   812 LV= 1 LX
         CXBR  R0,R4
*MCALL #=   813 LV= 1          RT1   CCE
         DS    0H
RT1_TEST539      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE539
         LTORG 
RT1_CCE539      DS 0H
*MEXIT #=   813 LV= 1 RT1
* ED08 KEB
         LE    R0,=EB'-1'
         KEB   R0,=EB'1'
*MCALL #=   814 LV= 1          RT1   CCL
         DS    0H
RT1_TEST540      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL540
         LTORG 
RT1_CCL540      DS 0H
*MEXIT #=   814 LV= 1 RT1
         LE    R0,=EB'1'
         KEB   R0,=EB'1'
*MCALL #=   815 LV= 1          RT1   CCE
         DS    0H
RT1_TEST541      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE541
         LTORG 
RT1_CCE541      DS 0H
*MEXIT #=   815 LV= 1 RT1
         LE    R0,=EB'0' RPI 325
         KEB   R0,=EB'0'
*MCALL #=   816 LV= 1          RT1   CCE
         DS    0H
RT1_TEST542      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE542
         LTORG 
RT1_CCE542      DS 0H
*MEXIT #=   816 LV= 1 RT1
         LE    R0,=EB'1'
         KEB   R0,=EB'-1'
*MCALL #=   817 LV= 1          RT1   CCH
         DS    0H
RT1_TEST543      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH543
         LTORG 
RT1_CCH543      DS 0H
*MEXIT #=   817 LV= 1 RT1
*MCALL #=   818 LV= 1          ESPIE SET,ESPIE_EXIT,7,PARAM=KEB1 BFP OVX
               ERFLOW FPCDXC=20
        LA     15,KEB1
        IPM    0  GET CURRENT PGM MASK
        SPM    0 TURN ON ANY MASKS REQUIRED
        L      0,=B'00000001000000000000000000000000'
        LA     1,ESPIE_EXIT
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   818 LV= 1 ESPIE
         LE    R0,=EB'1'
         KEB   R0,EBMAX
*MCALL #=   819 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   819 LV= 1 RT1
*MCALL #=   820 LV= 1 KEB1     ESPIE RESET
KEB1     DS    0H
        SR     15,15
        SR     1,1
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   820 LV= 1 ESPIE
         STFPC FPCREG
         CLI   FPCDXC,X'20'
*MCALL #=   821 LV= 1          RT1   CCE
         DS    0H
RT1_TEST545      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE545
         LTORG 
RT1_CCE545      DS 0H
*MEXIT #=   821 LV= 1 RT1
*MCALL #=   822 LV= 1          ESPIE SET,ESPIE_EXIT,7,PARAM=KEB2 BFP UNX
               DERFLOW FPCDXC=10
        LA     15,KEB2
        IPM    0  GET CURRENT PGM MASK
        SPM    0 TURN ON ANY MASKS REQUIRED
        L      0,=B'00000001000000000000000000000000'
        LA     1,ESPIE_EXIT
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   822 LV= 1 ESPIE
         LE    R0,EBMIN
         KEB   R0,=EB'1'
*MCALL #=   823 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   823 LV= 1 RT1
*MCALL #=   824 LV= 1 KEB2     ESPIE RESET
KEB2     DS    0H
        SR     15,15
        SR     1,1
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   824 LV= 1 ESPIE
         STFPC FPCREG
         CLI   FPCDXC,X'10'
*MCALL #=   825 LV= 1          RT1   CCE
         DS    0H
RT1_TEST547      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE547
         LTORG 
RT1_CCE547      DS 0H
*MEXIT #=   825 LV= 1 RT1
* ED09 CEB
         LE    R0,=EB'1'
         CEB   R0,=X'3F800000'
*MCALL #=   826 LV= 1          RT1   CCE
         DS    0H
RT1_TEST548      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE548
         LTORG 
RT1_CCE548      DS 0H
*MEXIT #=   826 LV= 1 RT1
         LE    R0,=EB'-1'
         CEB   R0,=EB'0'
*MCALL #=   827 LV= 1          RT1   CCL
         DS    0H
RT1_TEST549      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL549
         LTORG 
RT1_CCL549      DS 0H
*MEXIT #=   827 LV= 1 RT1
         LE    R0,=EB'1'
         CEB   R0,=EB'0'
*MCALL #=   828 LV= 1          RT1   CCH
         DS    0H
RT1_TEST550      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH550
         LTORG 
RT1_CCH550      DS 0H
*MEXIT #=   828 LV= 1 RT1
* ED0A AEB
         LE    R0,=EB'3'
         AEB   R0,=EB'2'
*MCALL #=   829 LV= 1          RT1   CCH
         DS    0H
RT1_TEST551      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH551
         LTORG 
RT1_CCH551      DS 0H
*MEXIT #=   829 LV= 1 RT1
         CEB   R0,=EB'5'
*MCALL #=   830 LV= 1          RT1   CCE
         DS    0H
RT1_TEST552      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE552
         LTORG 
RT1_CCE552      DS 0H
*MEXIT #=   830 LV= 1 RT1
         LE    R0,=EB'1'
         AEB   R0,=EB'-2'
*MCALL #=   831 LV= 1          RT1   CCL
         DS    0H
RT1_TEST553      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL553
         LTORG 
RT1_CCL553      DS 0H
*MEXIT #=   831 LV= 1 RT1
         CEB   R0,=EB'-1'
*MCALL #=   832 LV= 1          RT1   CCE
         DS    0H
RT1_TEST554      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE554
         LTORG 
RT1_CCE554      DS 0H
*MEXIT #=   832 LV= 1 RT1
         LE    R0,=EB'1'
         AEB   R0,=EB'-1'
*MCALL #=   833 LV= 1          RT1   CCE
         DS    0H
RT1_TEST555      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE555
         LTORG 
RT1_CCE555      DS 0H
*MEXIT #=   833 LV= 1 RT1
         CEB   R0,=EB'0'
*MCALL #=   834 LV= 1          RT1   CCE
         DS    0H
RT1_TEST556      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE556
         LTORG 
RT1_CCE556      DS 0H
*MEXIT #=   834 LV= 1 RT1
* ED0B SEB
         LE    R0,=EB'3'
         SEB   R0,=EB'2'
*MCALL #=   835 LV= 1          RT1   CCH
         DS    0H
RT1_TEST557      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH557
         LTORG 
RT1_CCH557      DS 0H
*MEXIT #=   835 LV= 1 RT1
         CEB   R0,=EB'1'
*MCALL #=   836 LV= 1          RT1   CCE
         DS    0H
RT1_TEST558      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE558
         LTORG 
RT1_CCE558      DS 0H
*MEXIT #=   836 LV= 1 RT1
         LE    R0,=EB'1'
         SEB   R0,=EB'2'
*MCALL #=   837 LV= 1          RT1   CCL
         DS    0H
RT1_TEST559      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL559
         LTORG 
RT1_CCL559      DS 0H
*MEXIT #=   837 LV= 1 RT1
         CEB   R0,=EB'-1'
*MCALL #=   838 LV= 1          RT1   CCE
         DS    0H
RT1_TEST560      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE560
         LTORG 
RT1_CCE560      DS 0H
*MEXIT #=   838 LV= 1 RT1
         LE    R0,=EB'1'
         SEB   R0,=EB'1'
*MCALL #=   839 LV= 1          RT1   CCE
         DS    0H
RT1_TEST561      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE561
         LTORG 
RT1_CCE561      DS 0H
*MEXIT #=   839 LV= 1 RT1
         CEB   R0,=EB'0'
*MCALL #=   840 LV= 1          RT1   CCE
         DS    0H
RT1_TEST562      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE562
         LTORG 
RT1_CCE562      DS 0H
*MEXIT #=   840 LV= 1 RT1
* ED0C MDEB
         LE    R0,=EB'2'
         MDEB  R0,=EB'3'
         CDB   R0,=DB'6'
*MCALL #=   841 LV= 1          RT1   CCE
         DS    0H
RT1_TEST563      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE563
         LTORG 
RT1_CCE563      DS 0H
*MEXIT #=   841 LV= 1 RT1
* ED0D DEB
         LE    R0,=EB'3'
         DEB   R0,=EB'2'
         CEB   R0,=EB'1.5'
*MCALL #=   842 LV= 1          RT1   CCE
         DS    0H
RT1_TEST564      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE564
         LTORG 
RT1_CCE564      DS 0H
*MEXIT #=   842 LV= 1 RT1
*MCALL #=   843 LV= 1          ESPIE SET,ESPIE_EXIT,7,PARAM=DEB1 BFP DIX
               VIDE FPCDXC=40
        LA     15,DEB1
        IPM    0  GET CURRENT PGM MASK
        SPM    0 TURN ON ANY MASKS REQUIRED
        L      0,=B'00000001000000000000000000000000'
        LA     1,ESPIE_EXIT
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   843 LV= 1 ESPIE
         LE    R0,=EB'1'
         DEB   R0,=EB'0'
*MCALL #=   844 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   844 LV= 1 RT1
*MCALL #=   845 LV= 1 DEB1     ESPIE RESET
DEB1     DS    0H
        SR     15,15
        SR     1,1
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   845 LV= 1 ESPIE
         STFPC FPCREG
         CLI   FPCDXC,X'40'
*MCALL #=   846 LV= 1          RT1   CCE
         DS    0H
RT1_TEST566      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE566
         LTORG 
RT1_CCE566      DS 0H
*MEXIT #=   846 LV= 1 RT1
* ED0E MAEB
         LE    R1,=EB'1'
         LE    R3,=EB'3'
         MAEB  R1,R3,=EB'2'
         CEB   R1,=EB'7'
*MCALL #=   847 LV= 1          RT1   CCE
         DS    0H
RT1_TEST567      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE567
         LTORG 
RT1_CCE567      DS 0H
*MEXIT #=   847 LV= 1 RT1
* ED0F MSEB
         LE    R0,=EB'1'
         LE    R1,=EB'2'
         MSEB  R0,R1,=EB'3'
         CEB   R0,=EB'5' RPI 834
*MCALL #=   848 LV= 1          RT1   CCE
         DS    0H
RT1_TEST568      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE568
         LTORG 
RT1_CCE568      DS 0H
*MEXIT #=   848 LV= 1 RT1
* ED10 TCEB
         LE    R0,=EB'0'
         TCEB  R0,TDCPZ
*MCALL #=   849 LV= 1          RT1   CC1
         DS    0H
RT1_TEST569      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL569
         LTORG 
RT1_CCL569      DS 0H
*MEXIT #=   849 LV= 1 RT1
         LE    R0,=EB'-0'  RPI 834
         TCEB  R0,TDCMZ
*MCALL #=   850 LV= 1          RT1   CC1
         DS    0H
RT1_TEST570      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL570
         LTORG 
RT1_CCL570      DS 0H
*MEXIT #=   850 LV= 1 RT1
         LE    R0,=EB'1'
         TCEB  R0,TDCPN
*MCALL #=   851 LV= 1          RT1   CC1
         DS    0H
RT1_TEST571      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL571
         LTORG 
RT1_CCL571      DS 0H
*MEXIT #=   851 LV= 1 RT1
         TCEB  R0,TDCMN
*MCALL #=   852 LV= 1          RT1   CC0
         DS    0H
RT1_TEST572      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE572
         LTORG 
RT1_CCE572      DS 0H
*MEXIT #=   852 LV= 1 RT1
         LE    R0,=EB'-1'
         TCEB  R0,TDCPN
*MCALL #=   853 LV= 1          RT1   CC0
         DS    0H
RT1_TEST573      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE573
         LTORG 
RT1_CCE573      DS 0H
*MEXIT #=   853 LV= 1 RT1
         TCEB  R0,TDCMN
*MCALL #=   854 LV= 1          RT1   CC1
         DS    0H
RT1_TEST574      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL574
         LTORG 
RT1_CCL574      DS 0H
*MEXIT #=   854 LV= 1 RT1
* ED11 TCDB
         LD    R0,=DB'0'
         TCDB  R0,TDCPZ
*MCALL #=   855 LV= 1          RT1   CC1
         DS    0H
RT1_TEST575      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL575
         LTORG 
RT1_CCL575      DS 0H
*MEXIT #=   855 LV= 1 RT1
         LD    R0,=DB'-0'  RPI 834
         TCDB  R0,TDCMZ
*MCALL #=   856 LV= 1          RT1   CC1
         DS    0H
RT1_TEST576      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL576
         LTORG 
RT1_CCL576      DS 0H
*MEXIT #=   856 LV= 1 RT1
         LD    R0,=DB'1'
         TCDB  R0,TDCPN
*MCALL #=   857 LV= 1          RT1   CC1
         DS    0H
RT1_TEST577      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL577
         LTORG 
RT1_CCL577      DS 0H
*MEXIT #=   857 LV= 1 RT1
         TCDB  R0,TDCMN
*MCALL #=   858 LV= 1          RT1   CC0
         DS    0H
RT1_TEST578      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE578
         LTORG 
RT1_CCE578      DS 0H
*MEXIT #=   858 LV= 1 RT1
         LD    R0,=DB'-1'
         TCDB  R0,TDCPN
*MCALL #=   859 LV= 1          RT1   CC0
         DS    0H
RT1_TEST579      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE579
         LTORG 
RT1_CCE579      DS 0H
*MEXIT #=   859 LV= 1 RT1
         TCDB  R0,TDCMN
*MCALL #=   860 LV= 1          RT1   CC1
         DS    0H
RT1_TEST580      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL580
         LTORG 
RT1_CCL580      DS 0H
*MEXIT #=   860 LV= 1 RT1
* ED12 TCXB
*MCALL #=   861 LV= 1          LX    R0,=LB'0'
         LA    15,=LB'0'
         LD    R0,0(15)
         LD    R0+2,8(15)  RPI 229
*MEXIT #=   861 LV= 1 LX
         TCXB  R0,TDCPZ
*MCALL #=   862 LV= 1          RT1   CC1
         DS    0H
RT1_TEST581      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL581
         LTORG 
RT1_CCL581      DS 0H
*MEXIT #=   862 LV= 1 RT1
*MCALL #=   863 LV= 1          LX    R0,=LB'-0' RPI 834
         LA    15,=LB'-0'
         LD    R0,0(15)
         LD    R0+2,8(15)  RPI 229
*MEXIT #=   863 LV= 1 LX
         TCXB  R0,TDCMZ
*MCALL #=   864 LV= 1          RT1   CC1
         DS    0H
RT1_TEST582      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL582
         LTORG 
RT1_CCL582      DS 0H
*MEXIT #=   864 LV= 1 RT1
*MCALL #=   865 LV= 1          LX    R0,=LB'1'
         LA    15,=LB'1'
         LD    R0,0(15)
         LD    R0+2,8(15)  RPI 229
*MEXIT #=   865 LV= 1 LX
         TCXB  R0,TDCPN
*MCALL #=   866 LV= 1          RT1   CC1
         DS    0H
RT1_TEST583      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL583
         LTORG 
RT1_CCL583      DS 0H
*MEXIT #=   866 LV= 1 RT1
         TCXB  R0,TDCMN
*MCALL #=   867 LV= 1          RT1   CC0
         DS    0H
RT1_TEST584      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE584
         LTORG 
RT1_CCE584      DS 0H
*MEXIT #=   867 LV= 1 RT1
*MCALL #=   868 LV= 1          LX    R0,=LB'-1'
         LA    15,=LB'-1'
         LD    R0,0(15)
         LD    R0+2,8(15)  RPI 229
*MEXIT #=   868 LV= 1 LX
         TCXB  R0,TDCPN
*MCALL #=   869 LV= 1          RT1   CC0
         DS    0H
RT1_TEST585      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE585
         LTORG 
RT1_CCE585      DS 0H
*MEXIT #=   869 LV= 1 RT1
         TCXB  R0,TDCMN
*MCALL #=   870 LV= 1          RT1   CC1
         DS    0H
RT1_TEST586      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL586
         LTORG 
RT1_CCL586      DS 0H
*MEXIT #=   870 LV= 1 RT1
* ED14 SQEB
         SQEB  R0,=EB'4'
         CEB   R0,=EB'2'
*MCALL #=   871 LV= 1          RT1   CCE
         DS    0H
RT1_TEST587      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE587
         LTORG 
RT1_CCE587      DS 0H
*MEXIT #=   871 LV= 1 RT1
* ED15 SQDB
         SQDB  R0,=DB'4'
         CDB   R0,=DB'2'
*MCALL #=   872 LV= 1          RT1   CCE
         DS    0H
RT1_TEST588      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE588
         LTORG 
RT1_CCE588      DS 0H
*MEXIT #=   872 LV= 1 RT1
* ED17 MEEB
         LE    R0,=EB'2'
         MEEB  R0,=EB'3'
         CEB   R0,=EB'6'
*MCALL #=   873 LV= 1          RT1   CCE
         DS    0H
RT1_TEST589      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE589
         LTORG 
RT1_CCE589      DS 0H
*MEXIT #=   873 LV= 1 RT1
* ED18 KDB
         LD    R0,=DB'-1'
         KDB   R0,=DB'1'
*MCALL #=   874 LV= 1          RT1   CCL
         DS    0H
RT1_TEST590      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL590
         LTORG 
RT1_CCL590      DS 0H
*MEXIT #=   874 LV= 1 RT1
         LD    R0,=DB'1'
         KDB   R0,=DB'1'
*MCALL #=   875 LV= 1          RT1   CCE
         DS    0H
RT1_TEST591      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE591
         LTORG 
RT1_CCE591      DS 0H
*MEXIT #=   875 LV= 1 RT1
         LD    R0,=DB'0'  RPI 325
         KDB   R0,=DB'0'
*MCALL #=   876 LV= 1          RT1   CCE
         DS    0H
RT1_TEST592      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE592
         LTORG 
RT1_CCE592      DS 0H
*MEXIT #=   876 LV= 1 RT1
         LD    R0,=DB'1'
         KDB   R0,=DB'-1'
*MCALL #=   877 LV= 1          RT1   CCH
         DS    0H
RT1_TEST593      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH593
         LTORG 
RT1_CCH593      DS 0H
*MEXIT #=   877 LV= 1 RT1
*MCALL #=   878 LV= 1          ESPIE SET,ESPIE_EXIT,7,PARAM=KDB1 BFP OVX
               ERFLOW FPCDXC=20
        LA     15,KDB1
        IPM    0  GET CURRENT PGM MASK
        SPM    0 TURN ON ANY MASKS REQUIRED
        L      0,=B'00000001000000000000000000000000'
        LA     1,ESPIE_EXIT
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   878 LV= 1 ESPIE
         LD    R0,=DB'1'
         KDB   R0,DBMAX
*MCALL #=   879 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   879 LV= 1 RT1
*MCALL #=   880 LV= 1 KDB1     ESPIE RESET
KDB1     DS    0H
        SR     15,15
        SR     1,1
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   880 LV= 1 ESPIE
         STFPC FPCREG
         CLI   FPCDXC,X'20'
*MCALL #=   881 LV= 1          RT1   CCE
         DS    0H
RT1_TEST595      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE595
         LTORG 
RT1_CCE595      DS 0H
*MEXIT #=   881 LV= 1 RT1
*MCALL #=   882 LV= 1          ESPIE SET,ESPIE_EXIT,7,PARAM=KDB2 BFP UNX
               DERFLOW FPCDXC=10
        LA     15,KDB2
        IPM    0  GET CURRENT PGM MASK
        SPM    0 TURN ON ANY MASKS REQUIRED
        L      0,=B'00000001000000000000000000000000'
        LA     1,ESPIE_EXIT
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   882 LV= 1 ESPIE
         LD    R0,DBMIN
         KDB   R0,=DB'1'
*MCALL #=   883 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   883 LV= 1 RT1
*MCALL #=   884 LV= 1 KDB2     ESPIE RESET
KDB2     DS    0H
        SR     15,15
        SR     1,1
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   884 LV= 1 ESPIE
         STFPC FPCREG
         CLI   FPCDXC,X'10'
*MCALL #=   885 LV= 1          RT1   CCE
         DS    0H
RT1_TEST597      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE597
         LTORG 
RT1_CCE597      DS 0H
*MEXIT #=   885 LV= 1 RT1
* ED19 CDB
         LD    R0,=DB'1'
         CDB   R0,=X'3FF0000000000000'
*MCALL #=   886 LV= 1          RT1   CCE
         DS    0H
RT1_TEST598      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE598
         LTORG 
RT1_CCE598      DS 0H
*MEXIT #=   886 LV= 1 RT1
         LD    R0,=DB'-1'
         CDB   R0,=DB'0'
*MCALL #=   887 LV= 1          RT1   CCL
         DS    0H
RT1_TEST599      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL599
         LTORG 
RT1_CCL599      DS 0H
*MEXIT #=   887 LV= 1 RT1
         LD    R0,=DB'1'
         CDB   R0,=DB'0'
*MCALL #=   888 LV= 1          RT1   CCH
         DS    0H
RT1_TEST600      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH600
         LTORG 
RT1_CCH600      DS 0H
*MEXIT #=   888 LV= 1 RT1
* ED1A ADB
         LD    R0,=DB'3'
         ADB   R0,=DB'2'
*MCALL #=   889 LV= 1          RT1   CCH
         DS    0H
RT1_TEST601      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH601
         LTORG 
RT1_CCH601      DS 0H
*MEXIT #=   889 LV= 1 RT1
         CDB   R0,=DB'5'
*MCALL #=   890 LV= 1          RT1   CCE
         DS    0H
RT1_TEST602      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE602
         LTORG 
RT1_CCE602      DS 0H
*MEXIT #=   890 LV= 1 RT1
         LD    R0,=DB'1'
         ADB   R0,=DB'-2'
*MCALL #=   891 LV= 1          RT1   CCL
         DS    0H
RT1_TEST603      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL603
         LTORG 
RT1_CCL603      DS 0H
*MEXIT #=   891 LV= 1 RT1
         CDB   R0,=DB'-1'
*MCALL #=   892 LV= 1          RT1   CCE
         DS    0H
RT1_TEST604      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE604
         LTORG 
RT1_CCE604      DS 0H
*MEXIT #=   892 LV= 1 RT1
         LD    R0,=DB'1'
         ADB   R0,=DB'-1'
*MCALL #=   893 LV= 1          RT1   CCE
         DS    0H
RT1_TEST605      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE605
         LTORG 
RT1_CCE605      DS 0H
*MEXIT #=   893 LV= 1 RT1
         CDB   R0,=DB'0'
*MCALL #=   894 LV= 1          RT1   CCE
         DS    0H
RT1_TEST606      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE606
         LTORG 
RT1_CCE606      DS 0H
*MEXIT #=   894 LV= 1 RT1
* ED1B SDB
         LD    R0,=DB'3'
         SDB   R0,=DB'2'
*MCALL #=   895 LV= 1          RT1   CCH
         DS    0H
RT1_TEST607      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH607
         LTORG 
RT1_CCH607      DS 0H
*MEXIT #=   895 LV= 1 RT1
         CDB   R0,=DB'1'
*MCALL #=   896 LV= 1          RT1   CCE
         DS    0H
RT1_TEST608      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE608
         LTORG 
RT1_CCE608      DS 0H
*MEXIT #=   896 LV= 1 RT1
         LD    R0,=DB'1'
         SDB   R0,=DB'2'
*MCALL #=   897 LV= 1          RT1   CCL
         DS    0H
RT1_TEST609      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL609
         LTORG 
RT1_CCL609      DS 0H
*MEXIT #=   897 LV= 1 RT1
         CDB   R0,=DB'-1'
*MCALL #=   898 LV= 1          RT1   CCE
         DS    0H
RT1_TEST610      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE610
         LTORG 
RT1_CCE610      DS 0H
*MEXIT #=   898 LV= 1 RT1
         LD    R0,=DB'1'
         SDB   R0,=DB'1'
*MCALL #=   899 LV= 1          RT1   CCE
         DS    0H
RT1_TEST611      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE611
         LTORG 
RT1_CCE611      DS 0H
*MEXIT #=   899 LV= 1 RT1
         CDB   R0,=DB'0'
*MCALL #=   900 LV= 1          RT1   CCE
         DS    0H
RT1_TEST612      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE612
         LTORG 
RT1_CCE612      DS 0H
*MEXIT #=   900 LV= 1 RT1
* ED1C MDB
         LD    R0,=DB'2'
         MDB   R0,=DB'3'
         CDB   R0,=DB'6'
*MCALL #=   901 LV= 1          RT1   CCE
         DS    0H
RT1_TEST613      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE613
         LTORG 
RT1_CCE613      DS 0H
*MEXIT #=   901 LV= 1 RT1
* ED1D DDB
         LD    R0,=DB'3'
         DDB   R0,=DB'2'
         CDB   R0,=DB'1.5'
*MCALL #=   902 LV= 1          RT1   CCE
         DS    0H
RT1_TEST614      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE614
         LTORG 
RT1_CCE614      DS 0H
*MEXIT #=   902 LV= 1 RT1
* ED1E MADB
         LD    R0,=DB'1'
         LD    R1,=DB'2'
         MADB  R0,R1,=DB'3'
         CDB   R0,=DB'7'
*MCALL #=   903 LV= 1          RT1   CCE
         DS    0H
RT1_TEST615      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE615
         LTORG 
RT1_CCE615      DS 0H
*MEXIT #=   903 LV= 1 RT1
* ED1F MSDB
         LD    R0,=DB'1'
         LD    R1,=DB'2'
         MSDB  R0,R1,=DB'3'
         CDB   R0,=DB'5'  RPI 834
*MCALL #=   904 LV= 1          RT1   CCE
         DS    0H
RT1_TEST616      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE616
         LTORG 
RT1_CCE616      DS 0H
*MEXIT #=   904 LV= 1 RT1
* ED24 LDE
         LDE   R0,=EH'123'
         CD    R0,=DH'123'
*MCALL #=   905 LV= 1          RT1   CCE
         DS    0H
RT1_TEST617      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE617
         LTORG 
RT1_CCE617      DS 0H
*MEXIT #=   905 LV= 1 RT1
* ED25 LXD
         LXD   R0,=DH'123'
*MCALL #=   906 LV= 1          LX    R4,=LH'123'
         LA    15,=LH'123'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   906 LV= 1 LX
         CXR   R0,R4
*MCALL #=   907 LV= 1          RT1   CCE
         DS    0H
RT1_TEST618      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE618
         LTORG 
RT1_CCE618      DS 0H
*MEXIT #=   907 LV= 1 RT1
* ED26 LXE
         LXE   R0,=EH'123'
*MCALL #=   908 LV= 1          LX    R4,=LH'123'
         LA    15,=LH'123'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   908 LV= 1 LX
         CXR   R0,R4
*MCALL #=   909 LV= 1          RT1   CCE
         DS    0H
RT1_TEST619      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE619
         LTORG 
RT1_CCE619      DS 0H
*MEXIT #=   909 LV= 1 RT1
* ED2E MAE
         LE    R0,=EH'1'
         LE    R1,=EH'2'
         MAE   R0,R1,=EH'3'
         CE    R0,=EH'7'
*MCALL #=   910 LV= 1          RT1   CCE
         DS    0H
RT1_TEST620      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE620
         LTORG 
RT1_CCE620      DS 0H
*MEXIT #=   910 LV= 1 RT1
* ED2F MSE
         LE    R0,=EH'1'
         LE    R1,=EH'2'
         MSE   R0,R1,=EH'3'
         CE    R0,=EH'5'  RPI 834
*MCALL #=   911 LV= 1          RT1   CCE
         DS    0H
RT1_TEST621      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE621
         LTORG 
RT1_CCE621      DS 0H
*MEXIT #=   911 LV= 1 RT1
* ED34 SQE
         SQE   R0,=EH'4'
         CE    R0,=EH'2'
*MCALL #=   912 LV= 1          RT1   CCE
         DS    0H
RT1_TEST622      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE622
         LTORG 
RT1_CCE622      DS 0H
*MEXIT #=   912 LV= 1 RT1
* ED35 SQD
         SQD   R0,=DH'4'
         CD    R0,=DH'2'
*MCALL #=   913 LV= 1          RT1   CCE
         DS    0H
RT1_TEST623      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE623
         LTORG 
RT1_CCE623      DS 0H
*MEXIT #=   913 LV= 1 RT1
* ED37 MEE
         LE    R0,=EH'2'
         MEE   R0,=EH'3'
         CE    R0,=EH'6'
*MCALL #=   914 LV= 1          RT1   CCE
         DS    0H
RT1_TEST624      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE624
         LTORG 
RT1_CCE624      DS 0H
*MEXIT #=   914 LV= 1 RT1
* ED38 MAYL Z9 MULTIPLY AND ADD L > E
         LD    R0,=X'4E0000000000000A'
         LD    R5,=X'4E00000000000002'
         MAYL  R0,R5,=X'4E00000000000003'
         CD    R0,=D'16'
*MCALL #=   915 LV= 1          RT1   CCE
         DS    0H
RT1_TEST625      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE625
         LTORG 
RT1_CCE625      DS 0H
*MEXIT #=   915 LV= 1 RT1
* ED39 MYL Z9 MULTIPLY L > E
         LD    R2,=X'4E00000000000002'
         MYL   R0,R2,=X'4E00000000000003'
         CD    R0,=X'4E00000000000006'    RPI 767 FIX TEST
*MCALL #=   916 LV= 1          RT1   CCE
         DS    0H
RT1_TEST626      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE626
         LTORG 
RT1_CCE626      DS 0H
*MEXIT #=   916 LV= 1 RT1
* ED3A MAY Z9 MULTIPLY AND ADD L > E
*MCALL #=   917 LV= 1          LX    R0,=L'10'
         LA    15,=L'10'
         LD    R0,0(15)
         LD    R0+2,8(15)  RPI 229
*MEXIT #=   917 LV= 1 LX
         LD    R1,=D'3'
         MAY   R0,R1,=D'2'
*MCALL #=   918 LV= 1          LX    R4,=LH'16'
         LA    15,=LH'16'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   918 LV= 1 LX
         CXR   R0,R4
*MCALL #=   919 LV= 1          RT1   CCE
         DS    0H
RT1_TEST627      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE627
         LTORG 
RT1_CCE627      DS 0H
*MEXIT #=   919 LV= 1 RT1
* ED3B MY Z9 MULTIPLY L > E
         LD    R1,=D'3'
         MY    R0,R1,=D'2'
*MCALL #=   920 LV= 1          LX    R4,=LH'6'
         LA    15,=LH'6'
         LD    R4,0(15)
         LD    R4+2,8(15)  RPI 229
*MEXIT #=   920 LV= 1 LX
         CXR   R0,R4
*MCALL #=   921 LV= 1          RT1   CCE
         DS    0H
RT1_TEST628      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE628
         LTORG 
RT1_CCE628      DS 0H
*MEXIT #=   921 LV= 1 RT1
* ED3C MAYH Z9 MULTIPLY AND ADD L > E
         LD    R0,=D'10'
         LD    R5,=D'2'
         MAYH  R0,R5,=D'3'    RPI 767 FIX TEST
         CD    R0,=D'16'
*MCALL #=   922 LV= 1          RT1   CCE
         DS    0H
RT1_TEST629      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE629
         LTORG 
RT1_CCE629      DS 0H
*MEXIT #=   922 LV= 1 RT1
* ED3D MYH Z9 MULTIPLY L > E
         LD    R1,=D'3'
         MYH   R0,R1,=D'2'
         CD    R0,=DH'6'  RPI 767 FIX TEST
*MCALL #=   923 LV= 1          RT1   CCE
         DS    0H
RT1_TEST630      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE630
         LTORG 
RT1_CCE630      DS 0H
*MEXIT #=   923 LV= 1 RT1
* ED3E MAD
         LD    R0,=DH'1'
         LD    R1,=DH'2'
         MAD   R0,R1,=DH'3'
         CD    R0,=DH'7'
*MCALL #=   924 LV= 1          RT1   CCE
         DS    0H
RT1_TEST631      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE631
         LTORG 
RT1_CCE631      DS 0H
*MEXIT #=   924 LV= 1 RT1
* ED3F MSD
         LD    R0,=DH'1'
         LD    R1,=DH'2'
         MSD   R0,R1,=DH'3'
         CD    R0,=DH'5'  RPI 834
*MCALL #=   925 LV= 1          RT1   CCE
         DS    0H
RT1_TEST632      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE632
         LTORG 
RT1_CCE632      DS 0H
*MEXIT #=   925 LV= 1 RT1
* ED64 LEY
         LEY   R0,=EH'1'
         AE    R0,=EH'1'
*MCALL #=   926 LV= 1          RT1   CCH
         DS    0H
RT1_TEST633      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH633
         LTORG 
RT1_CCH633      DS 0H
*MEXIT #=   926 LV= 1 RT1
         STE   R0,WORD
         CLC   WORD,=X'41200000'
*MCALL #=   927 LV= 1          RT1   CCE
         DS    0H
RT1_TEST634      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE634
         LTORG 
RT1_CCE634      DS 0H
*MEXIT #=   927 LV= 1 RT1
* ED65 LDY
         LDY   R0,=DH'1'
         AD    R0,=DH'1'
*MCALL #=   928 LV= 1          RT1   CCH
         DS    0H
RT1_TEST635      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH635
         LTORG 
RT1_CCH635      DS 0H
*MEXIT #=   928 LV= 1 RT1
         STD   R0,DWORD
         CLC   DWORD,=X'4120000000000000'
*MCALL #=   929 LV= 1          RT1   CCE
         DS    0H
RT1_TEST636      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE636
         LTORG 
RT1_CCE636      DS 0H
*MEXIT #=   929 LV= 1 RT1
* ED66 STEY
         LE    R0,=EH'1'
         STEY  R0,WORD
         CLC   WORD,=X'41100000'
*MCALL #=   930 LV= 1          RT1   CCE
         DS    0H
RT1_TEST637      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE637
         LTORG 
RT1_CCE637      DS 0H
*MEXIT #=   930 LV= 1 RT1
* ED67 STDY
         LD    R0,=DH'1'
         CDR   R0,R1
         STDY  R0,DWORD
         CLC   DWORD,=X'4110000000000000'
*MCALL #=   931 LV= 1          RT1   CCE
         DS    0H
RT1_TEST638      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE638
         LTORG 
RT1_CCE638      DS 0H
*MEXIT #=   931 LV= 1 RT1
*MCALL #=   932 LV= 1          RT1   END
         B      RT1_END
*MEXIT #=   932 LV= 1 RT1
*MCALL #=   933 LV= 1          IHAEPIE 
EPIE     DSECT 
EPIEEPIE DS    CL4   C'EPIE'
EPIEPARM DS    A     A(PARAM PASSED AT ESPIE OR 0)
         DS    16F   32 bit regs not used by z390 (see EPIEG64)
EPIEPSW  DS    0XL8  (OLD PSW  (EC 24/31 BIT ONLY)
EPIEEMK1 DS    X     PSW MASK
EPIEMWP1 DS    X     PSW KEY AND MWP
EPIECCPM DS    X     PSW CONDITION CODE AND PGM MASK
         DS    X     RESERVED
EPIENXT1 DS    0F    PSW 31 BIT ADDR NEXT INSTRUCTION
EPIEAMF1 DS    X     PSW ADDRESS HIGH BYTE WITH AMODE BIT
EPIEMOD1 EQU   X'80' PSW 31 BIT AMODE BIT
EPIEADD1 DS    XL3   PSW 24 BIT ADDRESSS OF NEXT INSTRUCTION
EPIEINT  DS    0XL4  PROGRAM INTERRUPTION INFO
EPIEIRSV DS    XL1   RESERVED
EPIEILC1 DS    B     INSTRUCTION LENGTH BYTE
EPIEIL1  EQU   X'06' INSTRUCTION LENGTH MASK (2, 4, 6 LENGTH)
EPIEINC1 DS    0CL2  INTERRUPTION CODE
         ORG   EPIE+X'99'
EPIEFLGS DS    XL1   EPIE OPTION FLAGS
EPIEUP64 EQU   X'40' USE 64 BIT REGS INSTEAD OF 32 BIT
         DS    XL6   RESERVED
EPIEG64   DS   0D
EPIEG6400 DS   D
EPIEG6401 DS   D
EPIEG6402 DS   D
EPIEG6403 DS   D
EPIEG6404 DS   D
EPIEG6405 DS   D
EPIEG6406 DS   D
EPIEG6407 DS   D
EPIEG6408 DS   D
EPIEG6409 DS   D
EPIEG6410 DS   D
EPIEG6411 DS   D
EPIEG6412 DS   D
EPIEG6413 DS   D
EPIEG6414 DS   D
EPIEG6415 DS   D
EPIELEN  EQU   *-EPIE
*MEXIT #=   933 LV= 1 IHAEPIE
         END 
