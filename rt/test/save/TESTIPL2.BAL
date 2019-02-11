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
* 2006-04-10 DSH RPI-276 Test display of IPL date set by            *
*                        IPL(TESTIPL1)                              *
*********************************************************************
         TITLE 'TESTIPL2 - TEST DISPLAY OF CVTDATE SET BY TESTIPL1'
*MCALL #=     1 LV= 1 TESTIPL2 SUBENTRY 
TESTIPL2 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTIPL2'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTIPL2+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
*MCALL #=     2 LV= 1          WTO   'TESTIPL2 STARTING TO DISPLAY CVTDX
               ATE IPL DATE'
         BRAS  1,*+(WTO#0002_EOT-*+1)/2*2
         DC    AL2(WTO#0002_EOT-*,0),C'TESTIPL2 STARTING TO DISPLAY CVTX
               DATE IPL DATE'
WTO#0002_EOT     EQU *
         SVC   35
*MEXIT #=     2 LV= 1 WTO
         L     R1,16
         USING IHACVT,R1
         CLI   CVTDATE,X'01'        VERIFY CENTURY CODE IS X'01'
         BNE   ABORT
         UNPK  YYDDD,CVTDATE+1(3)
         OI    YYDDD+5,C'0'
*MCALL #=     3 LV= 1          WTO   MF=(E,WTODATE)
         LA    1,WTODATE
         SVC   35
*MEXIT #=     3 LV= 1 WTO
*MCALL #=     4 LV= 1          WTO   'TESTIPL2 ENDED OK'
         BRAS  1,*+(WTO#0004_EOT-*+1)/2*2
         DC    AL2(WTO#0004_EOT-*,0),C'TESTIPL2 ENDED OK'
WTO#0004_EOT     EQU *
         SVC   35
*MEXIT #=     4 LV= 1 WTO
*MCALL #=     5 LV= 1          SUBEXIT 
         LA    15,0
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=     5 LV= 1 SUBEXIT
*MCALL #=     6 LV= 1 ABORT    WTO   'TESTIPL2 ABORTING DUE TO INVALID X
               CVTDATE'
ABORT    DS    0H
         BRAS  1,*+(WTO#0006_EOT-*+1)/2*2
         DC    AL2(WTO#0006_EOT-*,0),C'TESTIPL2 ABORTING DUE TO INVALIDX
                CVTDATE'
WTO#0006_EOT     EQU *
         SVC   35
*MEXIT #=     6 LV= 1 WTO
*MCALL #=     7 LV= 1          ABEND  111,DUMP
         LA   1,111
         OILH 1,X'8000'
         SVC  13 ABEND R1=COMP CODE AND HIGH BIT = DUMP PGM STORAGE
*MEXIT #=     7 LV= 1 ABEND
*MCALL #=     8 LV= 1          EQUREGS 
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
*MEXIT #=     8 LV= 1 EQUREGS
WTODATE  DC    AL2(WTOEND-*,0),C'TESTIPL2 IPL DATE = '
CC       DC    CL2'20'
YYDDD    DS    CL5'YYDDD'
WTOEND   EQU   *
*MCALL #=     9 LV= 1          CVTD 
IHACVT   DSECT 
         ORG    IHACVT+X'38'
CVTDATE  DS     PL4   IPL DATE SET BY IPL(TESTIPL1)
         ORG    IHACVT+X'74'
CVTDCB   DS     X     OS FLAGS X'80' = 31 BITS, X'13' = MVS+
         ORG    IHACVT+200
CVTABEND DS     A     SECONDARY CVT  (ZERO FOR NOW)
CVTUSER  DS     A     USER POINTER
CVTCDE   DS     A     ADDRESS FIRST CDE FOR Z390 RPI 1063
*MEXIT #=     9 LV= 1 CVTD
         END 
