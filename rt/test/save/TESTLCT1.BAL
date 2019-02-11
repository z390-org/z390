*********************************************************************
* Copyright 2007 Automated Software Tools Corporation               *
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
* 2007-03-09  DSH RPI-564 Add regression test for RLD im LOCTR      *
*                         section                                   *
*********************************************************************
*MCALL #=     1 LV= 1 TESTLCT1 SUBENTRY 
TESTLCT1 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTLCT1'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTLCT1+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
*MCALL #=     2 LV= 1          WTO   'TESTLCT1 TEST LOCTR SUPPORT'
         BRAS  1,*+(WTO#0002_EOT-*+1)/2*2
         DC    AL2(WTO#0002_EOT-*,0),C'TESTLCT1 TEST LOCTR SUPPORT'
WTO#0002_EOT     EQU *
         SVC   35
*MEXIT #=     2 LV= 1 WTO
         L     R2,=A(C2)
         USING C2,R2
         CLC   C2(4),=C'1234'
         BNE   1
         LA    1,C2B3
         CL    1,C2RLD  RPI 564
         BNE   1
*MCALL #=     3 LV= 1          WTO   'TESTLCT1 ENDED OK'
         BRAS  1,*+(WTO#0003_EOT-*+1)/2*2
         DC    AL2(WTO#0003_EOT-*,0),C'TESTLCT1 ENDED OK'
WTO#0003_EOT     EQU *
         SVC   35
*MEXIT #=     3 LV= 1 WTO
*MCALL #=     4 LV= 1          SUBEXIT 
         LA    15,0
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=     4 LV= 1 SUBEXIT
*MCALL #=     5 LV= 1          EQUREGS 
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
*MEXIT #=     5 LV= 1 EQUREGS
C2       CSECT 
C2B1     DC    C'1'
C2L1     LOCTR 
C2L2     LOCTR 
C2L3     LOCTR 
C2B4     DC    C'4'
C2L2     LOCTR 
C2B3     DC    C'3'
C2L1     LOCTR 
C2B2     DC    C'2'
C2B4     LOCTR 
C2RLD    DC    A(C2B3) VERIFY THIS RLD IS CORRECT AFTER LOADING
         END 
