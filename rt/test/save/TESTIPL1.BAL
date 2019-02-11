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
* 2006-04-10 DSH RPI-276 Test ez390 option IPL(TESTIPL1) to set     *
*                        CVTDATE                                    *
*********************************************************************
         TITLE 'TESTIPL1 - IPL TEST PGM TO SET CVTDATE'
*MCALL #=     1 LV= 1 TESTIPL1 SUBENTRY 
TESTIPL1 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTIPL1'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTIPL1+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
*MCALL #=     2 LV= 1          WTO   'TESTIPL1 IPL STARTING'
         BRAS  1,*+(WTO#0002_EOT-*+1)/2*2
         DC    AL2(WTO#0002_EOT-*,0),C'TESTIPL1 IPL STARTING'
WTO#0002_EOT     EQU *
         SVC   35
*MEXIT #=     2 LV= 1 WTO
         L     R4,16
         USING IHACVT,R4
*MCALL #=     3 LV= 1          TIME  DEC
         LA    0,0   DEC  R0 = HEX HHMMSSTH
         SVC   11 TIME AND DATE
*MEXIT #=     3 LV= 1 TIME
         ST    R1,CVTDATE
*MCALL #=     4 LV= 1          WTO   'TESTIPL1 IPL COMPLETE'
         BRAS  1,*+(WTO#0004_EOT-*+1)/2*2
         DC    AL2(WTO#0004_EOT-*,0),C'TESTIPL1 IPL COMPLETE'
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
*MCALL #=     6 LV= 1          EQUREGS 
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
*MEXIT #=     6 LV= 1 EQUREGS
*MCALL #=     7 LV= 1          CVTD 
IHACVT   DSECT 
         ORG    IHACVT+X'38'
CVTDATE  DS     PL4   IPL DATE SET BY IPL(TESTIPL1)
         ORG    IHACVT+X'74'
CVTDCB   DS     X     OS FLAGS X'80' = 31 BITS, X'13' = MVS+
         ORG    IHACVT+200
CVTABEND DS     A     SECONDARY CVT  (ZERO FOR NOW)
CVTUSER  DS     A     USER POINTER
CVTCDE   DS     A     ADDRESS FIRST CDE FOR Z390 RPI 1063
*MEXIT #=     7 LV= 1 CVTD
         END 
