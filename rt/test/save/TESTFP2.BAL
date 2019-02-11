*********************************************************************
* Copyright 2000 Automated Software Tools Corporation               *
* Copyright 2013 Cat Herder Software, LLC                           *
* Copyright 2018 Joachim Bartz, Germany                             *
*                                                                   *
* This source code is part of z390 assembler/emulator package.      *
*                                                                   *
* The z390 package is distributed under GNU general public license  *
*                                                                   *
* Author - Don Higgins                                              *
*********************************************************************
* 2009-03-09 DSH          Initial version                           *
* 2009-03-09 DSH RPI-1013 Test PFPO conversion between any two FP   *
*                         types                                     *
*********************************************************************
         TITLE 'TESTFP2 - TEST PFPO CONVERT RADIX INSTRUCTION'
         PRINT DATA
*MCALL #=     1 LV= 1 TESTFP2  RT1   MAIN
*MCALL #=     2 LV= 2 TESTFP2  SUBENTRY 
TESTFP2  CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTFP2'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTFP2+8,13
*MEXIT #=     2 LV= 2 SUBENTRY
*MCALL #=     3 LV= 2          WTO   'TESTFP2 RT1 STARTED'
         BRAS  1,*+(WTO#0003_EOT-*+1)/2*2
         DC    AL2(WTO#0003_EOT-*,0),C'TESTFP2 RT1 STARTED'
WTO#0003_EOT     EQU *
         SVC   35
*MEXIT #=     3 LV= 2 WTO
         BRCL    15,RT1_START
RT1_ABORT DS 0H
         MVI   RT1_ABORTED,C'T'
*MCALL #=     4 LV= 2          WTO   'TESTFP2 RT1 TESTING ABORTED'
         BRAS  1,*+(WTO#0004_EOT-*+1)/2*2
         DC    AL2(WTO#0004_EOT-*,0),C'TESTFP2 RT1 TESTING ABORTED'
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
*MCALL #=     6 LV= 2          WTO   'TESTFP2 RT1 ENDED OK'
         BRAS  1,*+(WTO#0006_EOT-*+1)/2*2
         DC    AL2(WTO#0006_EOT-*,0),C'TESTFP2 RT1 ENDED OK'
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
RT1_WTO1 DC    AL2(RT1_WTO_END-*,0),C'TESTFP2 RT1 TESTS COMPLETED = '
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
PWORK    DS    D
PWORK16  DS    XL16
WORD     DS    F
DWORD    DS    D
DWORD2   DS    D
BYTE     DS    X
LWORK    DS    XL16
EH       EQU   0   PFPO TYPE CODES
DH       EQU   1
LH       EQU   2
EB       EQU   5
DB       EQU   6
LB       EQU   7
ED       EQU   8
DD       EQU   9
LD       EQU   10
*MCALL #=    11 LV= 1          RT1   START
RT1_START DS  0H
*MEXIT #=    11 LV= 1 RT1
         MACRO
         TESTPFPO &FP1_TYPE,&FP2_TYPE,&NUM
 AIF (NOT('&FP2_TYPE'(1,1) EQ 'E')).AIF_1_1
         LE    F4,=&FP2_TYPE'&NUM'
 AGO .AIF_1_E
.AIF_1_1 ANOP
 AIF (NOT('&FP2_TYPE'(1,1) EQ 'D')).AIF_1_2
         LD    F4,=&FP2_TYPE'&NUM'
 AGO .AIF_1_E
.AIF_1_2 ANOP
         LX    F4,=&FP2_TYPE'&NUM'
.AIF_1_E ANOP
         L     R0,=AL1(1,&FP1_TYPE,&FP2_TYPE,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO
 AIF (NOT('&FP1_TYPE'(1,1) EQ 'E')).AIF_2_1
 AIF (NOT('&FP1_TYPE'(2,1) EQ 'H')).AIF_3_1
         CE    F0,=&FP1_TYPE'&NUM'
 AGO .AIF_3_E
.AIF_3_1 ANOP
 AIF (NOT('&FP1_TYPE'(2,1) EQ 'B')).AIF_3_2
         CEB   F0,=&FP1_TYPE'&NUM'
 AGO .AIF_3_E
.AIF_3_2 ANOP
         STE   F0,WORD
         LE    F1,WORD
         LDETR F1,F1,0
         LD    F4,=DD'&NUM'
         CDTR  F1,F4
.AIF_3_E ANOP
 AGO .AIF_2_E
.AIF_2_1 ANOP
 AIF (NOT('&FP1_TYPE'(1,1) EQ 'D')).AIF_2_2
 AIF (NOT('&FP1_TYPE'(2,1) EQ 'H')).AIF_4_1
         CD    F0,=&FP1_TYPE'&NUM'
 AGO .AIF_4_E
.AIF_4_1 ANOP
 AIF (NOT('&FP1_TYPE'(2,1) EQ 'B')).AIF_4_2
         CDB   F0,=&FP1_TYPE'&NUM'
 AGO .AIF_4_E
.AIF_4_2 ANOP
         STD   F0,DWORD
         LD    F1,DWORD
         LD    F4,=&FP1_TYPE'&NUM'
         CDTR  F1,F4
.AIF_4_E ANOP
 AGO .AIF_2_E
.AIF_2_2 ANOP
         LX    F4,=&FP1_TYPE'&NUM'
 AIF (NOT('&FP1_TYPE'(2,1) EQ 'H')).AIF_5_1
         CXR   F0,F4
 AGO .AIF_5_E
.AIF_5_1 ANOP
 AIF (NOT('&FP1_TYPE'(2,1) EQ 'B')).AIF_5_2
         CXBR  F0,F4
 AGO .AIF_5_E
.AIF_5_2 ANOP
         CXTR  F0,F4
.AIF_5_E ANOP
.AIF_2_E ANOP
         RT1   CCE
         MEND
*MCALL #=    12 LV= 1          TESTPFPO EH,EH,123
         LE    F4,=EH'123'
         L     R0,=AL1(1,EH,EH,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
         CE    F0,=EH'123'
*MCALL #=    13 LV= 2          RT1   CCE
         DS    0H
RT1_TEST1        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1
         LTORG 
RT1_CCE1        DS 0H
*MEXIT #=    13 LV= 2 RT1
*MEXIT #=    12 LV= 1 TESTPFPO
*MCALL #=    14 LV= 1          TESTPFPO EH,DH,123
         LD    F4,=DH'123'
         L     R0,=AL1(1,EH,DH,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
         CE    F0,=EH'123'
*MCALL #=    15 LV= 2          RT1   CCE
         DS    0H
RT1_TEST2        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE2
         LTORG 
RT1_CCE2        DS 0H
*MEXIT #=    15 LV= 2 RT1
*MEXIT #=    14 LV= 1 TESTPFPO
*MCALL #=    16 LV= 1          TESTPFPO EH,LH,123
*MCALL #=    17 LV= 2          LX    F4,=LH'123'
         LA    15,=LH'123'
         LD    F4,0(15)
         LD    F4+2,8(15)
*MEXIT #=    17 LV= 2 LX
         L     R0,=AL1(1,EH,LH,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
         CE    F0,=EH'123'
*MCALL #=    18 LV= 2          RT1   CCE
         DS    0H
RT1_TEST3        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE3
         LTORG 
RT1_CCE3        DS 0H
*MEXIT #=    18 LV= 2 RT1
*MEXIT #=    16 LV= 1 TESTPFPO
*MCALL #=    19 LV= 1          TESTPFPO EH,EB,123
         LE    F4,=EB'123'
         L     R0,=AL1(1,EH,EB,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
         CE    F0,=EH'123'
*MCALL #=    20 LV= 2          RT1   CCE
         DS    0H
RT1_TEST4        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE4
         LTORG 
RT1_CCE4        DS 0H
*MEXIT #=    20 LV= 2 RT1
*MEXIT #=    19 LV= 1 TESTPFPO
*MCALL #=    21 LV= 1          TESTPFPO EH,DB,123
         LD    F4,=DB'123'
         L     R0,=AL1(1,EH,DB,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
         CE    F0,=EH'123'
*MCALL #=    22 LV= 2          RT1   CCE
         DS    0H
RT1_TEST5        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE5
         LTORG 
RT1_CCE5        DS 0H
*MEXIT #=    22 LV= 2 RT1
*MEXIT #=    21 LV= 1 TESTPFPO
*MCALL #=    23 LV= 1          TESTPFPO EH,LB,123
*MCALL #=    24 LV= 2          LX    F4,=LB'123'
         LA    15,=LB'123'
         LD    F4,0(15)
         LD    F4+2,8(15)
*MEXIT #=    24 LV= 2 LX
         L     R0,=AL1(1,EH,LB,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
         CE    F0,=EH'123'
*MCALL #=    25 LV= 2          RT1   CCE
         DS    0H
RT1_TEST6        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE6
         LTORG 
RT1_CCE6        DS 0H
*MEXIT #=    25 LV= 2 RT1
*MEXIT #=    23 LV= 1 TESTPFPO
*MCALL #=    26 LV= 1          TESTPFPO EH,ED,123
         LE    F4,=ED'123'
         L     R0,=AL1(1,EH,ED,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
         CE    F0,=EH'123'
*MCALL #=    27 LV= 2          RT1   CCE
         DS    0H
RT1_TEST7        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE7
         LTORG 
RT1_CCE7        DS 0H
*MEXIT #=    27 LV= 2 RT1
*MEXIT #=    26 LV= 1 TESTPFPO
*MCALL #=    28 LV= 1          TESTPFPO EH,DD,123
         LD    F4,=DD'123'
         L     R0,=AL1(1,EH,DD,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
         CE    F0,=EH'123'
*MCALL #=    29 LV= 2          RT1   CCE
         DS    0H
RT1_TEST8        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE8
         LTORG 
RT1_CCE8        DS 0H
*MEXIT #=    29 LV= 2 RT1
*MEXIT #=    28 LV= 1 TESTPFPO
*MCALL #=    30 LV= 1          TESTPFPO EH,LD,123
*MCALL #=    31 LV= 2          LX    F4,=LD'123'
         LA    15,=LD'123'
         LD    F4,0(15)
         LD    F4+2,8(15)
*MEXIT #=    31 LV= 2 LX
         L     R0,=AL1(1,EH,LD,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
         CE    F0,=EH'123'
*MCALL #=    32 LV= 2          RT1   CCE
         DS    0H
RT1_TEST9        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE9
         LTORG 
RT1_CCE9        DS 0H
*MEXIT #=    32 LV= 2 RT1
*MEXIT #=    30 LV= 1 TESTPFPO
*MCALL #=    33 LV= 1          TESTPFPO DH,EH,123
         LE    F4,=EH'123'
         L     R0,=AL1(1,DH,EH,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
         CD    F0,=DH'123'
*MCALL #=    34 LV= 2          RT1   CCE
         DS    0H
RT1_TEST10       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE10
         LTORG 
RT1_CCE10       DS 0H
*MEXIT #=    34 LV= 2 RT1
*MEXIT #=    33 LV= 1 TESTPFPO
*MCALL #=    35 LV= 1          TESTPFPO DH,DH,123
         LD    F4,=DH'123'
         L     R0,=AL1(1,DH,DH,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
         CD    F0,=DH'123'
*MCALL #=    36 LV= 2          RT1   CCE
         DS    0H
RT1_TEST11       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE11
         LTORG 
RT1_CCE11       DS 0H
*MEXIT #=    36 LV= 2 RT1
*MEXIT #=    35 LV= 1 TESTPFPO
*MCALL #=    37 LV= 1          TESTPFPO DH,LH,123
*MCALL #=    38 LV= 2          LX    F4,=LH'123'
         LA    15,=LH'123'
         LD    F4,0(15)
         LD    F4+2,8(15)
*MEXIT #=    38 LV= 2 LX
         L     R0,=AL1(1,DH,LH,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
         CD    F0,=DH'123'
*MCALL #=    39 LV= 2          RT1   CCE
         DS    0H
RT1_TEST12       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE12
         LTORG 
RT1_CCE12       DS 0H
*MEXIT #=    39 LV= 2 RT1
*MEXIT #=    37 LV= 1 TESTPFPO
*MCALL #=    40 LV= 1          TESTPFPO DH,EB,123
         LE    F4,=EB'123'
         L     R0,=AL1(1,DH,EB,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
         CD    F0,=DH'123'
*MCALL #=    41 LV= 2          RT1   CCE
         DS    0H
RT1_TEST13       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE13
         LTORG 
RT1_CCE13       DS 0H
*MEXIT #=    41 LV= 2 RT1
*MEXIT #=    40 LV= 1 TESTPFPO
*MCALL #=    42 LV= 1          TESTPFPO DH,DB,123
         LD    F4,=DB'123'
         L     R0,=AL1(1,DH,DB,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
         CD    F0,=DH'123'
*MCALL #=    43 LV= 2          RT1   CCE
         DS    0H
RT1_TEST14       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE14
         LTORG 
RT1_CCE14       DS 0H
*MEXIT #=    43 LV= 2 RT1
*MEXIT #=    42 LV= 1 TESTPFPO
*MCALL #=    44 LV= 1          TESTPFPO DH,LB,123
*MCALL #=    45 LV= 2          LX    F4,=LB'123'
         LA    15,=LB'123'
         LD    F4,0(15)
         LD    F4+2,8(15)
*MEXIT #=    45 LV= 2 LX
         L     R0,=AL1(1,DH,LB,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
         CD    F0,=DH'123'
*MCALL #=    46 LV= 2          RT1   CCE
         DS    0H
RT1_TEST15       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE15
         LTORG 
RT1_CCE15       DS 0H
*MEXIT #=    46 LV= 2 RT1
*MEXIT #=    44 LV= 1 TESTPFPO
*MCALL #=    47 LV= 1          TESTPFPO DH,ED,123
         LE    F4,=ED'123'
         L     R0,=AL1(1,DH,ED,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
         CD    F0,=DH'123'
*MCALL #=    48 LV= 2          RT1   CCE
         DS    0H
RT1_TEST16       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE16
         LTORG 
RT1_CCE16       DS 0H
*MEXIT #=    48 LV= 2 RT1
*MEXIT #=    47 LV= 1 TESTPFPO
*MCALL #=    49 LV= 1          TESTPFPO DH,DD,123
         LD    F4,=DD'123'
         L     R0,=AL1(1,DH,DD,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
         CD    F0,=DH'123'
*MCALL #=    50 LV= 2          RT1   CCE
         DS    0H
RT1_TEST17       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE17
         LTORG 
RT1_CCE17       DS 0H
*MEXIT #=    50 LV= 2 RT1
*MEXIT #=    49 LV= 1 TESTPFPO
*MCALL #=    51 LV= 1          TESTPFPO DH,LD,123
*MCALL #=    52 LV= 2          LX    F4,=LD'123'
         LA    15,=LD'123'
         LD    F4,0(15)
         LD    F4+2,8(15)
*MEXIT #=    52 LV= 2 LX
         L     R0,=AL1(1,DH,LD,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
         CD    F0,=DH'123'
*MCALL #=    53 LV= 2          RT1   CCE
         DS    0H
RT1_TEST18       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE18
         LTORG 
RT1_CCE18       DS 0H
*MEXIT #=    53 LV= 2 RT1
*MEXIT #=    51 LV= 1 TESTPFPO
*MCALL #=    54 LV= 1          TESTPFPO LH,EH,123
         LE    F4,=EH'123'
         L     R0,=AL1(1,LH,EH,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
*MCALL #=    55 LV= 2          LX    F4,=LH'123'
         LA    15,=LH'123'
         LD    F4,0(15)
         LD    F4+2,8(15)
*MEXIT #=    55 LV= 2 LX
         CXR   F0,F4
*MCALL #=    56 LV= 2          RT1   CCE
         DS    0H
RT1_TEST19       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE19
         LTORG 
RT1_CCE19       DS 0H
*MEXIT #=    56 LV= 2 RT1
*MEXIT #=    54 LV= 1 TESTPFPO
*MCALL #=    57 LV= 1          TESTPFPO LH,DH,123
         LD    F4,=DH'123'
         L     R0,=AL1(1,LH,DH,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
*MCALL #=    58 LV= 2          LX    F4,=LH'123'
         LA    15,=LH'123'
         LD    F4,0(15)
         LD    F4+2,8(15)
*MEXIT #=    58 LV= 2 LX
         CXR   F0,F4
*MCALL #=    59 LV= 2          RT1   CCE
         DS    0H
RT1_TEST20       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE20
         LTORG 
RT1_CCE20       DS 0H
*MEXIT #=    59 LV= 2 RT1
*MEXIT #=    57 LV= 1 TESTPFPO
*MCALL #=    60 LV= 1          TESTPFPO LH,LH,123
*MCALL #=    61 LV= 2          LX    F4,=LH'123'
         LA    15,=LH'123'
         LD    F4,0(15)
         LD    F4+2,8(15)
*MEXIT #=    61 LV= 2 LX
         L     R0,=AL1(1,LH,LH,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
*MCALL #=    62 LV= 2          LX    F4,=LH'123'
         LA    15,=LH'123'
         LD    F4,0(15)
         LD    F4+2,8(15)
*MEXIT #=    62 LV= 2 LX
         CXR   F0,F4
*MCALL #=    63 LV= 2          RT1   CCE
         DS    0H
RT1_TEST21       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE21
         LTORG 
RT1_CCE21       DS 0H
*MEXIT #=    63 LV= 2 RT1
*MEXIT #=    60 LV= 1 TESTPFPO
*MCALL #=    64 LV= 1          TESTPFPO LH,EB,123
         LE    F4,=EB'123'
         L     R0,=AL1(1,LH,EB,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
*MCALL #=    65 LV= 2          LX    F4,=LH'123'
         LA    15,=LH'123'
         LD    F4,0(15)
         LD    F4+2,8(15)
*MEXIT #=    65 LV= 2 LX
         CXR   F0,F4
*MCALL #=    66 LV= 2          RT1   CCE
         DS    0H
RT1_TEST22       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE22
         LTORG 
RT1_CCE22       DS 0H
*MEXIT #=    66 LV= 2 RT1
*MEXIT #=    64 LV= 1 TESTPFPO
*MCALL #=    67 LV= 1          TESTPFPO LH,DB,123
         LD    F4,=DB'123'
         L     R0,=AL1(1,LH,DB,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
*MCALL #=    68 LV= 2          LX    F4,=LH'123'
         LA    15,=LH'123'
         LD    F4,0(15)
         LD    F4+2,8(15)
*MEXIT #=    68 LV= 2 LX
         CXR   F0,F4
*MCALL #=    69 LV= 2          RT1   CCE
         DS    0H
RT1_TEST23       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE23
         LTORG 
RT1_CCE23       DS 0H
*MEXIT #=    69 LV= 2 RT1
*MEXIT #=    67 LV= 1 TESTPFPO
*MCALL #=    70 LV= 1          TESTPFPO LH,LB,123
*MCALL #=    71 LV= 2          LX    F4,=LB'123'
         LA    15,=LB'123'
         LD    F4,0(15)
         LD    F4+2,8(15)
*MEXIT #=    71 LV= 2 LX
         L     R0,=AL1(1,LH,LB,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
*MCALL #=    72 LV= 2          LX    F4,=LH'123'
         LA    15,=LH'123'
         LD    F4,0(15)
         LD    F4+2,8(15)
*MEXIT #=    72 LV= 2 LX
         CXR   F0,F4
*MCALL #=    73 LV= 2          RT1   CCE
         DS    0H
RT1_TEST24       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE24
         LTORG 
RT1_CCE24       DS 0H
*MEXIT #=    73 LV= 2 RT1
*MEXIT #=    70 LV= 1 TESTPFPO
*MCALL #=    74 LV= 1          TESTPFPO LH,ED,123
         LE    F4,=ED'123'
         L     R0,=AL1(1,LH,ED,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
*MCALL #=    75 LV= 2          LX    F4,=LH'123'
         LA    15,=LH'123'
         LD    F4,0(15)
         LD    F4+2,8(15)
*MEXIT #=    75 LV= 2 LX
         CXR   F0,F4
*MCALL #=    76 LV= 2          RT1   CCE
         DS    0H
RT1_TEST25       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE25
         LTORG 
RT1_CCE25       DS 0H
*MEXIT #=    76 LV= 2 RT1
*MEXIT #=    74 LV= 1 TESTPFPO
*MCALL #=    77 LV= 1          TESTPFPO LH,DD,123
         LD    F4,=DD'123'
         L     R0,=AL1(1,LH,DD,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
*MCALL #=    78 LV= 2          LX    F4,=LH'123'
         LA    15,=LH'123'
         LD    F4,0(15)
         LD    F4+2,8(15)
*MEXIT #=    78 LV= 2 LX
         CXR   F0,F4
*MCALL #=    79 LV= 2          RT1   CCE
         DS    0H
RT1_TEST26       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE26
         LTORG 
RT1_CCE26       DS 0H
*MEXIT #=    79 LV= 2 RT1
*MEXIT #=    77 LV= 1 TESTPFPO
*MCALL #=    80 LV= 1          TESTPFPO LH,LD,123
*MCALL #=    81 LV= 2          LX    F4,=LD'123'
         LA    15,=LD'123'
         LD    F4,0(15)
         LD    F4+2,8(15)
*MEXIT #=    81 LV= 2 LX
         L     R0,=AL1(1,LH,LD,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
*MCALL #=    82 LV= 2          LX    F4,=LH'123'
         LA    15,=LH'123'
         LD    F4,0(15)
         LD    F4+2,8(15)
*MEXIT #=    82 LV= 2 LX
         CXR   F0,F4
*MCALL #=    83 LV= 2          RT1   CCE
         DS    0H
RT1_TEST27       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE27
         LTORG 
RT1_CCE27       DS 0H
*MEXIT #=    83 LV= 2 RT1
*MEXIT #=    80 LV= 1 TESTPFPO
*MCALL #=    84 LV= 1          TESTPFPO EB,EH,123
         LE    F4,=EH'123'
         L     R0,=AL1(1,EB,EH,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
         CEB   F0,=EB'123'
*MCALL #=    85 LV= 2          RT1   CCE
         DS    0H
RT1_TEST28       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE28
         LTORG 
RT1_CCE28       DS 0H
*MEXIT #=    85 LV= 2 RT1
*MEXIT #=    84 LV= 1 TESTPFPO
*MCALL #=    86 LV= 1          TESTPFPO EB,DH,123
         LD    F4,=DH'123'
         L     R0,=AL1(1,EB,DH,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
         CEB   F0,=EB'123'
*MCALL #=    87 LV= 2          RT1   CCE
         DS    0H
RT1_TEST29       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE29
         LTORG 
RT1_CCE29       DS 0H
*MEXIT #=    87 LV= 2 RT1
*MEXIT #=    86 LV= 1 TESTPFPO
*MCALL #=    88 LV= 1          TESTPFPO EB,LH,123
*MCALL #=    89 LV= 2          LX    F4,=LH'123'
         LA    15,=LH'123'
         LD    F4,0(15)
         LD    F4+2,8(15)
*MEXIT #=    89 LV= 2 LX
         L     R0,=AL1(1,EB,LH,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
         CEB   F0,=EB'123'
*MCALL #=    90 LV= 2          RT1   CCE
         DS    0H
RT1_TEST30       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE30
         LTORG 
RT1_CCE30       DS 0H
*MEXIT #=    90 LV= 2 RT1
*MEXIT #=    88 LV= 1 TESTPFPO
*MCALL #=    91 LV= 1          TESTPFPO EB,EB,123
         LE    F4,=EB'123'
         L     R0,=AL1(1,EB,EB,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
         CEB   F0,=EB'123'
*MCALL #=    92 LV= 2          RT1   CCE
         DS    0H
RT1_TEST31       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE31
         LTORG 
RT1_CCE31       DS 0H
*MEXIT #=    92 LV= 2 RT1
*MEXIT #=    91 LV= 1 TESTPFPO
*MCALL #=    93 LV= 1          TESTPFPO EB,DB,123
         LD    F4,=DB'123'
         L     R0,=AL1(1,EB,DB,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
         CEB   F0,=EB'123'
*MCALL #=    94 LV= 2          RT1   CCE
         DS    0H
RT1_TEST32       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE32
         LTORG 
RT1_CCE32       DS 0H
*MEXIT #=    94 LV= 2 RT1
*MEXIT #=    93 LV= 1 TESTPFPO
*MCALL #=    95 LV= 1          TESTPFPO EB,LB,123
*MCALL #=    96 LV= 2          LX    F4,=LB'123'
         LA    15,=LB'123'
         LD    F4,0(15)
         LD    F4+2,8(15)
*MEXIT #=    96 LV= 2 LX
         L     R0,=AL1(1,EB,LB,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
         CEB   F0,=EB'123'
*MCALL #=    97 LV= 2          RT1   CCE
         DS    0H
RT1_TEST33       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE33
         LTORG 
RT1_CCE33       DS 0H
*MEXIT #=    97 LV= 2 RT1
*MEXIT #=    95 LV= 1 TESTPFPO
*MCALL #=    98 LV= 1          TESTPFPO EB,ED,123
         LE    F4,=ED'123'
         L     R0,=AL1(1,EB,ED,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
         CEB   F0,=EB'123'
*MCALL #=    99 LV= 2          RT1   CCE
         DS    0H
RT1_TEST34       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE34
         LTORG 
RT1_CCE34       DS 0H
*MEXIT #=    99 LV= 2 RT1
*MEXIT #=    98 LV= 1 TESTPFPO
*MCALL #=   100 LV= 1          TESTPFPO EB,DD,123
         LD    F4,=DD'123'
         L     R0,=AL1(1,EB,DD,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
         CEB   F0,=EB'123'
*MCALL #=   101 LV= 2          RT1   CCE
         DS    0H
RT1_TEST35       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE35
         LTORG 
RT1_CCE35       DS 0H
*MEXIT #=   101 LV= 2 RT1
*MEXIT #=   100 LV= 1 TESTPFPO
*MCALL #=   102 LV= 1          TESTPFPO EB,LD,123
*MCALL #=   103 LV= 2          LX    F4,=LD'123'
         LA    15,=LD'123'
         LD    F4,0(15)
         LD    F4+2,8(15)
*MEXIT #=   103 LV= 2 LX
         L     R0,=AL1(1,EB,LD,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
         CEB   F0,=EB'123'
*MCALL #=   104 LV= 2          RT1   CCE
         DS    0H
RT1_TEST36       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE36
         LTORG 
RT1_CCE36       DS 0H
*MEXIT #=   104 LV= 2 RT1
*MEXIT #=   102 LV= 1 TESTPFPO
*MCALL #=   105 LV= 1          TESTPFPO DB,EH,123
         LE    F4,=EH'123'
         L     R0,=AL1(1,DB,EH,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
         CDB   F0,=DB'123'
*MCALL #=   106 LV= 2          RT1   CCE
         DS    0H
RT1_TEST37       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE37
         LTORG 
RT1_CCE37       DS 0H
*MEXIT #=   106 LV= 2 RT1
*MEXIT #=   105 LV= 1 TESTPFPO
*MCALL #=   107 LV= 1          TESTPFPO DB,DH,123
         LD    F4,=DH'123'
         L     R0,=AL1(1,DB,DH,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
         CDB   F0,=DB'123'
*MCALL #=   108 LV= 2          RT1   CCE
         DS    0H
RT1_TEST38       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE38
         LTORG 
RT1_CCE38       DS 0H
*MEXIT #=   108 LV= 2 RT1
*MEXIT #=   107 LV= 1 TESTPFPO
*MCALL #=   109 LV= 1          TESTPFPO DB,LH,123
*MCALL #=   110 LV= 2          LX    F4,=LH'123'
         LA    15,=LH'123'
         LD    F4,0(15)
         LD    F4+2,8(15)
*MEXIT #=   110 LV= 2 LX
         L     R0,=AL1(1,DB,LH,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
         CDB   F0,=DB'123'
*MCALL #=   111 LV= 2          RT1   CCE
         DS    0H
RT1_TEST39       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE39
         LTORG 
RT1_CCE39       DS 0H
*MEXIT #=   111 LV= 2 RT1
*MEXIT #=   109 LV= 1 TESTPFPO
*MCALL #=   112 LV= 1          TESTPFPO DB,EB,123
         LE    F4,=EB'123'
         L     R0,=AL1(1,DB,EB,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
         CDB   F0,=DB'123'
*MCALL #=   113 LV= 2          RT1   CCE
         DS    0H
RT1_TEST40       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE40
         LTORG 
RT1_CCE40       DS 0H
*MEXIT #=   113 LV= 2 RT1
*MEXIT #=   112 LV= 1 TESTPFPO
*MCALL #=   114 LV= 1          TESTPFPO DB,DB,123
         LD    F4,=DB'123'
         L     R0,=AL1(1,DB,DB,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
         CDB   F0,=DB'123'
*MCALL #=   115 LV= 2          RT1   CCE
         DS    0H
RT1_TEST41       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE41
         LTORG 
RT1_CCE41       DS 0H
*MEXIT #=   115 LV= 2 RT1
*MEXIT #=   114 LV= 1 TESTPFPO
*MCALL #=   116 LV= 1          TESTPFPO DB,LB,123
*MCALL #=   117 LV= 2          LX    F4,=LB'123'
         LA    15,=LB'123'
         LD    F4,0(15)
         LD    F4+2,8(15)
*MEXIT #=   117 LV= 2 LX
         L     R0,=AL1(1,DB,LB,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
         CDB   F0,=DB'123'
*MCALL #=   118 LV= 2          RT1   CCE
         DS    0H
RT1_TEST42       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE42
         LTORG 
RT1_CCE42       DS 0H
*MEXIT #=   118 LV= 2 RT1
*MEXIT #=   116 LV= 1 TESTPFPO
*MCALL #=   119 LV= 1          TESTPFPO DB,ED,123
         LE    F4,=ED'123'
         L     R0,=AL1(1,DB,ED,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
         CDB   F0,=DB'123'
*MCALL #=   120 LV= 2          RT1   CCE
         DS    0H
RT1_TEST43       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE43
         LTORG 
RT1_CCE43       DS 0H
*MEXIT #=   120 LV= 2 RT1
*MEXIT #=   119 LV= 1 TESTPFPO
*MCALL #=   121 LV= 1          TESTPFPO DB,DD,123
         LD    F4,=DD'123'
         L     R0,=AL1(1,DB,DD,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
         CDB   F0,=DB'123'
*MCALL #=   122 LV= 2          RT1   CCE
         DS    0H
RT1_TEST44       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE44
         LTORG 
RT1_CCE44       DS 0H
*MEXIT #=   122 LV= 2 RT1
*MEXIT #=   121 LV= 1 TESTPFPO
*MCALL #=   123 LV= 1          TESTPFPO DB,LD,123
*MCALL #=   124 LV= 2          LX    F4,=LD'123'
         LA    15,=LD'123'
         LD    F4,0(15)
         LD    F4+2,8(15)
*MEXIT #=   124 LV= 2 LX
         L     R0,=AL1(1,DB,LD,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
         CDB   F0,=DB'123'
*MCALL #=   125 LV= 2          RT1   CCE
         DS    0H
RT1_TEST45       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE45
         LTORG 
RT1_CCE45       DS 0H
*MEXIT #=   125 LV= 2 RT1
*MEXIT #=   123 LV= 1 TESTPFPO
*MCALL #=   126 LV= 1          TESTPFPO LB,EH,123
         LE    F4,=EH'123'
         L     R0,=AL1(1,LB,EH,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
*MCALL #=   127 LV= 2          LX    F4,=LB'123'
         LA    15,=LB'123'
         LD    F4,0(15)
         LD    F4+2,8(15)
*MEXIT #=   127 LV= 2 LX
         CXBR  F0,F4
*MCALL #=   128 LV= 2          RT1   CCE
         DS    0H
RT1_TEST46       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE46
         LTORG 
RT1_CCE46       DS 0H
*MEXIT #=   128 LV= 2 RT1
*MEXIT #=   126 LV= 1 TESTPFPO
*MCALL #=   129 LV= 1          TESTPFPO LB,DH,123
         LD    F4,=DH'123'
         L     R0,=AL1(1,LB,DH,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
*MCALL #=   130 LV= 2          LX    F4,=LB'123'
         LA    15,=LB'123'
         LD    F4,0(15)
         LD    F4+2,8(15)
*MEXIT #=   130 LV= 2 LX
         CXBR  F0,F4
*MCALL #=   131 LV= 2          RT1   CCE
         DS    0H
RT1_TEST47       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE47
         LTORG 
RT1_CCE47       DS 0H
*MEXIT #=   131 LV= 2 RT1
*MEXIT #=   129 LV= 1 TESTPFPO
*MCALL #=   132 LV= 1          TESTPFPO LB,LH,123
*MCALL #=   133 LV= 2          LX    F4,=LH'123'
         LA    15,=LH'123'
         LD    F4,0(15)
         LD    F4+2,8(15)
*MEXIT #=   133 LV= 2 LX
         L     R0,=AL1(1,LB,LH,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
*MCALL #=   134 LV= 2          LX    F4,=LB'123'
         LA    15,=LB'123'
         LD    F4,0(15)
         LD    F4+2,8(15)
*MEXIT #=   134 LV= 2 LX
         CXBR  F0,F4
*MCALL #=   135 LV= 2          RT1   CCE
         DS    0H
RT1_TEST48       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE48
         LTORG 
RT1_CCE48       DS 0H
*MEXIT #=   135 LV= 2 RT1
*MEXIT #=   132 LV= 1 TESTPFPO
*MCALL #=   136 LV= 1          TESTPFPO LB,EB,123
         LE    F4,=EB'123'
         L     R0,=AL1(1,LB,EB,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
*MCALL #=   137 LV= 2          LX    F4,=LB'123'
         LA    15,=LB'123'
         LD    F4,0(15)
         LD    F4+2,8(15)
*MEXIT #=   137 LV= 2 LX
         CXBR  F0,F4
*MCALL #=   138 LV= 2          RT1   CCE
         DS    0H
RT1_TEST49       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE49
         LTORG 
RT1_CCE49       DS 0H
*MEXIT #=   138 LV= 2 RT1
*MEXIT #=   136 LV= 1 TESTPFPO
*MCALL #=   139 LV= 1          TESTPFPO LB,DB,123
         LD    F4,=DB'123'
         L     R0,=AL1(1,LB,DB,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
*MCALL #=   140 LV= 2          LX    F4,=LB'123'
         LA    15,=LB'123'
         LD    F4,0(15)
         LD    F4+2,8(15)
*MEXIT #=   140 LV= 2 LX
         CXBR  F0,F4
*MCALL #=   141 LV= 2          RT1   CCE
         DS    0H
RT1_TEST50       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE50
         LTORG 
RT1_CCE50       DS 0H
*MEXIT #=   141 LV= 2 RT1
*MEXIT #=   139 LV= 1 TESTPFPO
*MCALL #=   142 LV= 1          TESTPFPO LB,LB,123
*MCALL #=   143 LV= 2          LX    F4,=LB'123'
         LA    15,=LB'123'
         LD    F4,0(15)
         LD    F4+2,8(15)
*MEXIT #=   143 LV= 2 LX
         L     R0,=AL1(1,LB,LB,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
*MCALL #=   144 LV= 2          LX    F4,=LB'123'
         LA    15,=LB'123'
         LD    F4,0(15)
         LD    F4+2,8(15)
*MEXIT #=   144 LV= 2 LX
         CXBR  F0,F4
*MCALL #=   145 LV= 2          RT1   CCE
         DS    0H
RT1_TEST51       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE51
         LTORG 
RT1_CCE51       DS 0H
*MEXIT #=   145 LV= 2 RT1
*MEXIT #=   142 LV= 1 TESTPFPO
*MCALL #=   146 LV= 1          TESTPFPO LB,ED,123
         LE    F4,=ED'123'
         L     R0,=AL1(1,LB,ED,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
*MCALL #=   147 LV= 2          LX    F4,=LB'123'
         LA    15,=LB'123'
         LD    F4,0(15)
         LD    F4+2,8(15)
*MEXIT #=   147 LV= 2 LX
         CXBR  F0,F4
*MCALL #=   148 LV= 2          RT1   CCE
         DS    0H
RT1_TEST52       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE52
         LTORG 
RT1_CCE52       DS 0H
*MEXIT #=   148 LV= 2 RT1
*MEXIT #=   146 LV= 1 TESTPFPO
*MCALL #=   149 LV= 1          TESTPFPO LB,DD,123
         LD    F4,=DD'123'
         L     R0,=AL1(1,LB,DD,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
*MCALL #=   150 LV= 2          LX    F4,=LB'123'
         LA    15,=LB'123'
         LD    F4,0(15)
         LD    F4+2,8(15)
*MEXIT #=   150 LV= 2 LX
         CXBR  F0,F4
*MCALL #=   151 LV= 2          RT1   CCE
         DS    0H
RT1_TEST53       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE53
         LTORG 
RT1_CCE53       DS 0H
*MEXIT #=   151 LV= 2 RT1
*MEXIT #=   149 LV= 1 TESTPFPO
*MCALL #=   152 LV= 1          TESTPFPO LB,LD,123
*MCALL #=   153 LV= 2          LX    F4,=LD'123'
         LA    15,=LD'123'
         LD    F4,0(15)
         LD    F4+2,8(15)
*MEXIT #=   153 LV= 2 LX
         L     R0,=AL1(1,LB,LD,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
*MCALL #=   154 LV= 2          LX    F4,=LB'123'
         LA    15,=LB'123'
         LD    F4,0(15)
         LD    F4+2,8(15)
*MEXIT #=   154 LV= 2 LX
         CXBR  F0,F4
*MCALL #=   155 LV= 2          RT1   CCE
         DS    0H
RT1_TEST54       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE54
         LTORG 
RT1_CCE54       DS 0H
*MEXIT #=   155 LV= 2 RT1
*MEXIT #=   152 LV= 1 TESTPFPO
*MCALL #=   156 LV= 1          TESTPFPO ED,EH,123
         LE    F4,=EH'123'
         L     R0,=AL1(1,ED,EH,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
         STE   F0,WORD
         LE    F1,WORD
         LDETR F1,F1,0
         LD    F4,=DD'123'
         CDTR  F1,F4
*MCALL #=   157 LV= 2          RT1   CCE
         DS    0H
RT1_TEST55       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE55
         LTORG 
RT1_CCE55       DS 0H
*MEXIT #=   157 LV= 2 RT1
*MEXIT #=   156 LV= 1 TESTPFPO
*MCALL #=   158 LV= 1          TESTPFPO ED,DH,123
         LD    F4,=DH'123'
         L     R0,=AL1(1,ED,DH,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
         STE   F0,WORD
         LE    F1,WORD
         LDETR F1,F1,0
         LD    F4,=DD'123'
         CDTR  F1,F4
*MCALL #=   159 LV= 2          RT1   CCE
         DS    0H
RT1_TEST56       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE56
         LTORG 
RT1_CCE56       DS 0H
*MEXIT #=   159 LV= 2 RT1
*MEXIT #=   158 LV= 1 TESTPFPO
*MCALL #=   160 LV= 1          TESTPFPO ED,LH,123
*MCALL #=   161 LV= 2          LX    F4,=LH'123'
         LA    15,=LH'123'
         LD    F4,0(15)
         LD    F4+2,8(15)
*MEXIT #=   161 LV= 2 LX
         L     R0,=AL1(1,ED,LH,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
         STE   F0,WORD
         LE    F1,WORD
         LDETR F1,F1,0
         LD    F4,=DD'123'
         CDTR  F1,F4
*MCALL #=   162 LV= 2          RT1   CCE
         DS    0H
RT1_TEST57       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE57
         LTORG 
RT1_CCE57       DS 0H
*MEXIT #=   162 LV= 2 RT1
*MEXIT #=   160 LV= 1 TESTPFPO
*MCALL #=   163 LV= 1          TESTPFPO ED,EB,123
         LE    F4,=EB'123'
         L     R0,=AL1(1,ED,EB,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
         STE   F0,WORD
         LE    F1,WORD
         LDETR F1,F1,0
         LD    F4,=DD'123'
         CDTR  F1,F4
*MCALL #=   164 LV= 2          RT1   CCE
         DS    0H
RT1_TEST58       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE58
         LTORG 
RT1_CCE58       DS 0H
*MEXIT #=   164 LV= 2 RT1
*MEXIT #=   163 LV= 1 TESTPFPO
*MCALL #=   165 LV= 1          TESTPFPO ED,DB,123
         LD    F4,=DB'123'
         L     R0,=AL1(1,ED,DB,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
         STE   F0,WORD
         LE    F1,WORD
         LDETR F1,F1,0
         LD    F4,=DD'123'
         CDTR  F1,F4
*MCALL #=   166 LV= 2          RT1   CCE
         DS    0H
RT1_TEST59       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE59
         LTORG 
RT1_CCE59       DS 0H
*MEXIT #=   166 LV= 2 RT1
*MEXIT #=   165 LV= 1 TESTPFPO
*MCALL #=   167 LV= 1          TESTPFPO ED,LB,123
*MCALL #=   168 LV= 2          LX    F4,=LB'123'
         LA    15,=LB'123'
         LD    F4,0(15)
         LD    F4+2,8(15)
*MEXIT #=   168 LV= 2 LX
         L     R0,=AL1(1,ED,LB,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
         STE   F0,WORD
         LE    F1,WORD
         LDETR F1,F1,0
         LD    F4,=DD'123'
         CDTR  F1,F4
*MCALL #=   169 LV= 2          RT1   CCE
         DS    0H
RT1_TEST60       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE60
         LTORG 
RT1_CCE60       DS 0H
*MEXIT #=   169 LV= 2 RT1
*MEXIT #=   167 LV= 1 TESTPFPO
*MCALL #=   170 LV= 1          TESTPFPO ED,ED,123
         LE    F4,=ED'123'
         L     R0,=AL1(1,ED,ED,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
         STE   F0,WORD
         LE    F1,WORD
         LDETR F1,F1,0
         LD    F4,=DD'123'
         CDTR  F1,F4
*MCALL #=   171 LV= 2          RT1   CCE
         DS    0H
RT1_TEST61       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE61
         LTORG 
RT1_CCE61       DS 0H
*MEXIT #=   171 LV= 2 RT1
*MEXIT #=   170 LV= 1 TESTPFPO
*MCALL #=   172 LV= 1          TESTPFPO ED,DD,123
         LD    F4,=DD'123'
         L     R0,=AL1(1,ED,DD,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
         STE   F0,WORD
         LE    F1,WORD
         LDETR F1,F1,0
         LD    F4,=DD'123'
         CDTR  F1,F4
*MCALL #=   173 LV= 2          RT1   CCE
         DS    0H
RT1_TEST62       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE62
         LTORG 
RT1_CCE62       DS 0H
*MEXIT #=   173 LV= 2 RT1
*MEXIT #=   172 LV= 1 TESTPFPO
*MCALL #=   174 LV= 1          TESTPFPO ED,LD,123
*MCALL #=   175 LV= 2          LX    F4,=LD'123'
         LA    15,=LD'123'
         LD    F4,0(15)
         LD    F4+2,8(15)
*MEXIT #=   175 LV= 2 LX
         L     R0,=AL1(1,ED,LD,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
         STE   F0,WORD
         LE    F1,WORD
         LDETR F1,F1,0
         LD    F4,=DD'123'
         CDTR  F1,F4
*MCALL #=   176 LV= 2          RT1   CCE
         DS    0H
RT1_TEST63       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE63
         LTORG 
RT1_CCE63       DS 0H
*MEXIT #=   176 LV= 2 RT1
*MEXIT #=   174 LV= 1 TESTPFPO
*MCALL #=   177 LV= 1          TESTPFPO DD,EH,123
         LE    F4,=EH'123'
         L     R0,=AL1(1,DD,EH,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
         STD   F0,DWORD
         LD    F1,DWORD
         LD    F4,=DD'123'
         CDTR  F1,F4
*MCALL #=   178 LV= 2          RT1   CCE
         DS    0H
RT1_TEST64       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE64
         LTORG 
RT1_CCE64       DS 0H
*MEXIT #=   178 LV= 2 RT1
*MEXIT #=   177 LV= 1 TESTPFPO
*MCALL #=   179 LV= 1          TESTPFPO DD,DH,123
         LD    F4,=DH'123'
         L     R0,=AL1(1,DD,DH,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
         STD   F0,DWORD
         LD    F1,DWORD
         LD    F4,=DD'123'
         CDTR  F1,F4
*MCALL #=   180 LV= 2          RT1   CCE
         DS    0H
RT1_TEST65       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE65
         LTORG 
RT1_CCE65       DS 0H
*MEXIT #=   180 LV= 2 RT1
*MEXIT #=   179 LV= 1 TESTPFPO
*MCALL #=   181 LV= 1          TESTPFPO DD,LH,123
*MCALL #=   182 LV= 2          LX    F4,=LH'123'
         LA    15,=LH'123'
         LD    F4,0(15)
         LD    F4+2,8(15)
*MEXIT #=   182 LV= 2 LX
         L     R0,=AL1(1,DD,LH,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
         STD   F0,DWORD
         LD    F1,DWORD
         LD    F4,=DD'123'
         CDTR  F1,F4
*MCALL #=   183 LV= 2          RT1   CCE
         DS    0H
RT1_TEST66       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE66
         LTORG 
RT1_CCE66       DS 0H
*MEXIT #=   183 LV= 2 RT1
*MEXIT #=   181 LV= 1 TESTPFPO
*MCALL #=   184 LV= 1          TESTPFPO DD,EB,123
         LE    F4,=EB'123'
         L     R0,=AL1(1,DD,EB,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
         STD   F0,DWORD
         LD    F1,DWORD
         LD    F4,=DD'123'
         CDTR  F1,F4
*MCALL #=   185 LV= 2          RT1   CCE
         DS    0H
RT1_TEST67       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE67
         LTORG 
RT1_CCE67       DS 0H
*MEXIT #=   185 LV= 2 RT1
*MEXIT #=   184 LV= 1 TESTPFPO
*MCALL #=   186 LV= 1          TESTPFPO DD,DB,123
         LD    F4,=DB'123'
         L     R0,=AL1(1,DD,DB,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
         STD   F0,DWORD
         LD    F1,DWORD
         LD    F4,=DD'123'
         CDTR  F1,F4
*MCALL #=   187 LV= 2          RT1   CCE
         DS    0H
RT1_TEST68       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE68
         LTORG 
RT1_CCE68       DS 0H
*MEXIT #=   187 LV= 2 RT1
*MEXIT #=   186 LV= 1 TESTPFPO
*MCALL #=   188 LV= 1          TESTPFPO DD,LB,123
*MCALL #=   189 LV= 2          LX    F4,=LB'123'
         LA    15,=LB'123'
         LD    F4,0(15)
         LD    F4+2,8(15)
*MEXIT #=   189 LV= 2 LX
         L     R0,=AL1(1,DD,LB,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
         STD   F0,DWORD
         LD    F1,DWORD
         LD    F4,=DD'123'
         CDTR  F1,F4
*MCALL #=   190 LV= 2          RT1   CCE
         DS    0H
RT1_TEST69       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE69
         LTORG 
RT1_CCE69       DS 0H
*MEXIT #=   190 LV= 2 RT1
*MEXIT #=   188 LV= 1 TESTPFPO
*MCALL #=   191 LV= 1          TESTPFPO DD,ED,123
         LE    F4,=ED'123'
         L     R0,=AL1(1,DD,ED,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
         STD   F0,DWORD
         LD    F1,DWORD
         LD    F4,=DD'123'
         CDTR  F1,F4
*MCALL #=   192 LV= 2          RT1   CCE
         DS    0H
RT1_TEST70       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE70
         LTORG 
RT1_CCE70       DS 0H
*MEXIT #=   192 LV= 2 RT1
*MEXIT #=   191 LV= 1 TESTPFPO
*MCALL #=   193 LV= 1          TESTPFPO DD,DD,123
         LD    F4,=DD'123'
         L     R0,=AL1(1,DD,DD,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
         STD   F0,DWORD
         LD    F1,DWORD
         LD    F4,=DD'123'
         CDTR  F1,F4
*MCALL #=   194 LV= 2          RT1   CCE
         DS    0H
RT1_TEST71       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE71
         LTORG 
RT1_CCE71       DS 0H
*MEXIT #=   194 LV= 2 RT1
*MEXIT #=   193 LV= 1 TESTPFPO
*MCALL #=   195 LV= 1          TESTPFPO DD,LD,123
*MCALL #=   196 LV= 2          LX    F4,=LD'123'
         LA    15,=LD'123'
         LD    F4,0(15)
         LD    F4+2,8(15)
*MEXIT #=   196 LV= 2 LX
         L     R0,=AL1(1,DD,LD,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
         STD   F0,DWORD
         LD    F1,DWORD
         LD    F4,=DD'123'
         CDTR  F1,F4
*MCALL #=   197 LV= 2          RT1   CCE
         DS    0H
RT1_TEST72       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE72
         LTORG 
RT1_CCE72       DS 0H
*MEXIT #=   197 LV= 2 RT1
*MEXIT #=   195 LV= 1 TESTPFPO
*MCALL #=   198 LV= 1          TESTPFPO LD,EH,123
         LE    F4,=EH'123'
         L     R0,=AL1(1,LD,EH,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
*MCALL #=   199 LV= 2          LX    F4,=LD'123'
         LA    15,=LD'123'
         LD    F4,0(15)
         LD    F4+2,8(15)
*MEXIT #=   199 LV= 2 LX
         CXTR  F0,F4
*MCALL #=   200 LV= 2          RT1   CCE
         DS    0H
RT1_TEST73       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE73
         LTORG 
RT1_CCE73       DS 0H
*MEXIT #=   200 LV= 2 RT1
*MEXIT #=   198 LV= 1 TESTPFPO
*MCALL #=   201 LV= 1          TESTPFPO LD,DH,123
         LD    F4,=DH'123'
         L     R0,=AL1(1,LD,DH,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
*MCALL #=   202 LV= 2          LX    F4,=LD'123'
         LA    15,=LD'123'
         LD    F4,0(15)
         LD    F4+2,8(15)
*MEXIT #=   202 LV= 2 LX
         CXTR  F0,F4
*MCALL #=   203 LV= 2          RT1   CCE
         DS    0H
RT1_TEST74       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE74
         LTORG 
RT1_CCE74       DS 0H
*MEXIT #=   203 LV= 2 RT1
*MEXIT #=   201 LV= 1 TESTPFPO
*MCALL #=   204 LV= 1          TESTPFPO LD,LH,123
*MCALL #=   205 LV= 2          LX    F4,=LH'123'
         LA    15,=LH'123'
         LD    F4,0(15)
         LD    F4+2,8(15)
*MEXIT #=   205 LV= 2 LX
         L     R0,=AL1(1,LD,LH,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
*MCALL #=   206 LV= 2          LX    F4,=LD'123'
         LA    15,=LD'123'
         LD    F4,0(15)
         LD    F4+2,8(15)
*MEXIT #=   206 LV= 2 LX
         CXTR  F0,F4
*MCALL #=   207 LV= 2          RT1   CCE
         DS    0H
RT1_TEST75       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE75
         LTORG 
RT1_CCE75       DS 0H
*MEXIT #=   207 LV= 2 RT1
*MEXIT #=   204 LV= 1 TESTPFPO
*MCALL #=   208 LV= 1          TESTPFPO LD,EB,123
         LE    F4,=EB'123'
         L     R0,=AL1(1,LD,EB,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
*MCALL #=   209 LV= 2          LX    F4,=LD'123'
         LA    15,=LD'123'
         LD    F4,0(15)
         LD    F4+2,8(15)
*MEXIT #=   209 LV= 2 LX
         CXTR  F0,F4
*MCALL #=   210 LV= 2          RT1   CCE
         DS    0H
RT1_TEST76       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE76
         LTORG 
RT1_CCE76       DS 0H
*MEXIT #=   210 LV= 2 RT1
*MEXIT #=   208 LV= 1 TESTPFPO
*MCALL #=   211 LV= 1          TESTPFPO LD,DB,123
         LD    F4,=DB'123'
         L     R0,=AL1(1,LD,DB,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
*MCALL #=   212 LV= 2          LX    F4,=LD'123'
         LA    15,=LD'123'
         LD    F4,0(15)
         LD    F4+2,8(15)
*MEXIT #=   212 LV= 2 LX
         CXTR  F0,F4
*MCALL #=   213 LV= 2          RT1   CCE
         DS    0H
RT1_TEST77       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE77
         LTORG 
RT1_CCE77       DS 0H
*MEXIT #=   213 LV= 2 RT1
*MEXIT #=   211 LV= 1 TESTPFPO
*MCALL #=   214 LV= 1          TESTPFPO LD,LB,123
*MCALL #=   215 LV= 2          LX    F4,=LB'123'
         LA    15,=LB'123'
         LD    F4,0(15)
         LD    F4+2,8(15)
*MEXIT #=   215 LV= 2 LX
         L     R0,=AL1(1,LD,LB,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
*MCALL #=   216 LV= 2          LX    F4,=LD'123'
         LA    15,=LD'123'
         LD    F4,0(15)
         LD    F4+2,8(15)
*MEXIT #=   216 LV= 2 LX
         CXTR  F0,F4
*MCALL #=   217 LV= 2          RT1   CCE
         DS    0H
RT1_TEST78       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE78
         LTORG 
RT1_CCE78       DS 0H
*MEXIT #=   217 LV= 2 RT1
*MEXIT #=   214 LV= 1 TESTPFPO
*MCALL #=   218 LV= 1          TESTPFPO LD,ED,123
         LE    F4,=ED'123'
         L     R0,=AL1(1,LD,ED,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
*MCALL #=   219 LV= 2          LX    F4,=LD'123'
         LA    15,=LD'123'
         LD    F4,0(15)
         LD    F4+2,8(15)
*MEXIT #=   219 LV= 2 LX
         CXTR  F0,F4
*MCALL #=   220 LV= 2          RT1   CCE
         DS    0H
RT1_TEST79       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE79
         LTORG 
RT1_CCE79       DS 0H
*MEXIT #=   220 LV= 2 RT1
*MEXIT #=   218 LV= 1 TESTPFPO
*MCALL #=   221 LV= 1          TESTPFPO LD,DD,123
         LD    F4,=DD'123'
         L     R0,=AL1(1,LD,DD,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
*MCALL #=   222 LV= 2          LX    F4,=LD'123'
         LA    15,=LD'123'
         LD    F4,0(15)
         LD    F4+2,8(15)
*MEXIT #=   222 LV= 2 LX
         CXTR  F0,F4
*MCALL #=   223 LV= 2          RT1   CCE
         DS    0H
RT1_TEST80       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE80
         LTORG 
RT1_CCE80       DS 0H
*MEXIT #=   223 LV= 2 RT1
*MEXIT #=   221 LV= 1 TESTPFPO
*MCALL #=   224 LV= 1          TESTPFPO LD,LD,123
*MCALL #=   225 LV= 2          LX    F4,=LD'123'
         LA    15,=LD'123'
         LD    F4,0(15)
         LD    F4+2,8(15)
*MEXIT #=   225 LV= 2 LX
         L     R0,=AL1(1,LD,LD,0)
         SER   F0,F0 FORCE REG AND CACHE TO ZERO
         SER   F2,F2 FORCE REG AND CACHE TO ZERO
         PFPO 
*MCALL #=   226 LV= 2          LX    F4,=LD'123'
         LA    15,=LD'123'
         LD    F4,0(15)
         LD    F4+2,8(15)
*MEXIT #=   226 LV= 2 LX
         CXTR  F0,F4
*MCALL #=   227 LV= 2          RT1   CCE
         DS    0H
RT1_TEST81       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE81
         LTORG 
RT1_CCE81       DS 0H
*MEXIT #=   227 LV= 2 RT1
*MEXIT #=   224 LV= 1 TESTPFPO
*MCALL #=   228 LV= 1          RT1   END
         B      RT1_END
*MEXIT #=   228 LV= 1 RT1
         END 
