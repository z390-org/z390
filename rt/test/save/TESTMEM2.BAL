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
* 2006-01-09 DSH RPI-162 Test extensions LV=NNNK and LV=NNNM        *
* 2007-01-22 DSH RPI-542 Correct GETMAIN output R1=ADDR             *
* 2007-12-17 DSH RPI-758 Fix CLCL which was wrong and failed with   *
*                        0C6                                        *
*********************************************************************
         TITLE 'TESTMEM2 TEST GETMAIN EXTENSIONS'
*MCALL #=     1 LV= 1 TESTMEM2 RT1   MAIN
*MCALL #=     2 LV= 2 TESTMEM2 SUBENTRY 
TESTMEM2 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTMEM2'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTMEM2+8,13
*MEXIT #=     2 LV= 2 SUBENTRY
*MCALL #=     3 LV= 2          WTO   'TESTMEM2 RT1 STARTED'
         BRAS  1,*+(WTO#0003_EOT-*+1)/2*2
         DC    AL2(WTO#0003_EOT-*,0),C'TESTMEM2 RT1 STARTED'
WTO#0003_EOT     EQU *
         SVC   35
*MEXIT #=     3 LV= 2 WTO
         BRCL    15,RT1_START
RT1_ABORT DS 0H
         MVI   RT1_ABORTED,C'T'
*MCALL #=     4 LV= 2          WTO   'TESTMEM2 RT1 TESTING ABORTED'
         BRAS  1,*+(WTO#0004_EOT-*+1)/2*2
         DC    AL2(WTO#0004_EOT-*,0),C'TESTMEM2 RT1 TESTING ABORTED'
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
*MCALL #=     6 LV= 2          WTO   'TESTMEM2 RT1 ENDED OK'
         BRAS  1,*+(WTO#0006_EOT-*+1)/2*2
         DC    AL2(WTO#0006_EOT-*,0),C'TESTMEM2 RT1 ENDED OK'
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
RT1_WTO1 DC    AL2(RT1_WTO_END-*,0),C'TESTMEM2 RT1 TESTS COMPLETED = '
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
*MCALL #=    10 LV= 1          RT1   START
RT1_START DS  0H
*MEXIT #=    10 LV= 1 RT1
*MCALL #=    11 LV= 1          GETMAIN R,LV=1K     GET 1K
         L    1,=A(1024)  RPI 117
         LA    0,B'00'
         SVC   4 GMAIN R0=(X'02'=31B,X'01'=COND),R1=LEN OUT(R0=L,R1=A)
*MEXIT #=    11 LV= 1 GETMAIN
         LTR   R15,R15
*MCALL #=    12 LV= 1          RT1   CCE                 VERIFY R15 = 0
         DS    0H
RT1_TEST1        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1
         LTORG 
RT1_CCE1        DS 0H
*MEXIT #=    12 LV= 1 RT1
         LR    R2,R1                                RPI-542
         LR    R4,R2
         L     R5,=A(1024)
         SR    R0,R0
         L     R1,=X'EE000000'
         MVCL  R4,R0               FILL 1K WITH X'EE'
         LR    R4,R2
         L     R5,=A(1024)
         CLCL  R4,R0               VERIFY FILL  RPI-758
*MCALL #=    13 LV= 1          RT1   CCE
         DS    0H
RT1_TEST2        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE2
         LTORG 
RT1_CCE2        DS 0H
*MEXIT #=    13 LV= 1 RT1
*MCALL #=    14 LV= 1          GETMAIN R,LV=1M     GET 1M
         L    1,=A(1048576)  RPI 117
         LA    0,B'00'
         SVC   4 GMAIN R0=(X'02'=31B,X'01'=COND),R1=LEN OUT(R0=L,R1=A)
*MEXIT #=    14 LV= 1 GETMAIN
         LTR   R15,R15
*MCALL #=    15 LV= 1          RT1   CCE                 VERIFY R15 = 0
         DS    0H
RT1_TEST3        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE3
         LTORG 
RT1_CCE3        DS 0H
*MEXIT #=    15 LV= 1 RT1
         LR    R2,R1                              RPI-542
         LR    R4,R2
         L     R5,=A(1024*1024)
         SR    R0,R0
         L     R1,=X'EE000000'
         MVCL  R4,R0               FILL 1M WITH X'EE'
         LR    R4,R2
         L     R5,=A(1024*1024)
         CLCL  R4,R0               VERIFY FILL   RPI-758
*MCALL #=    16 LV= 1          RT1   CCE
         DS    0H
RT1_TEST4        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE4
         LTORG 
RT1_CCE4        DS 0H
*MEXIT #=    16 LV= 1 RT1
*MCALL #=    17 LV= 1          RT1   END
         B      RT1_END
*MEXIT #=    17 LV= 1 RT1
         END 
