*********************************************************************
* Copyright 2006 Automated Software Tools Corporation               *
* Copyright 2013 Cat Herder Software, LLC                           *
* Copyright 2018 Joachim Bartz, Germany                             *
*                                                                   *
* This source code is part of z390 assembler/emulator package.      *
*                                                                   *
* The z390 package is distributed under GNU general public license  *
*                                                                   *
* Author - Don Higgins                                              *
*********************************************************************
* 2006-05-05 DSH         Initial version                            *
* 2006-05-05 DSH RPI-280 Test ECBLIST using 2 command processes     *
*********************************************************************
         TITLE 'TESTECB1 TEST WAIT ECBLIST USING STIMER EXIT'
*MCALL #=     1 LV= 1 TESTECB1 SUBENTRY 
TESTECB1 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTECB1'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTECB1+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
*MCALL #=     2 LV= 1          WTO   'TESTECB1 STARTED'
         BRAS  1,*+(WTO#0002_EOT-*+1)/2*2
         DC    AL2(WTO#0002_EOT-*,0),C'TESTECB1 STARTED'
WTO#0002_EOT     EQU *
         SVC   35
*MEXIT #=     2 LV= 1 WTO
*MCALL #=     3 LV= 1          STIMER REAL,SEXIT,BINTVL==F'200'
        LA    0,SEXIT       REAL EXIT
        IIHF  0,X'02010000' REAL BINTVL
        LA    1,=F'200'
        SVC   X'2F' STIMER R0B0=TYPE,R0B1=INT, R0=EXIT, R1=INTVL ARG
*MEXIT #=     3 LV= 1 STIMER
*MCALL #=     4 LV= 1          WAIT  2,ECBLIST==A(ECB1,ECB2+X'80000000'X
               )
         LA    0,2
         LA    1,=A(ECB1,ECB2+X'80000000')
         SVC   1 (R0=0,R1=A(ECB) OR (R0=NUM,R1=ECBLIST)
*MEXIT #=     4 LV= 1 WAIT
*MCALL #=     5 LV= 1          WTO   'TESTECB1 ENDED OK'
         BRAS  1,*+(WTO#0005_EOT-*+1)/2*2
         DC    AL2(WTO#0005_EOT-*,0),C'TESTECB1 ENDED OK'
WTO#0005_EOT     EQU *
         SVC   35
*MEXIT #=     5 LV= 1 WTO
*MCALL #=     6 LV= 1          SUBEXIT 
         LA    15,0
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=     6 LV= 1 SUBEXIT
SEXIT    EQU   *            STIMER EXIT ROUTINE
         USING *,15
         CLI   ECB1,X'80'   ARE WE WAITING FOR ECB1 POST
         BNE   POST2        NO GO CHECK ECB2
POST1    EQU   *
*MCALL #=     7 LV= 1          POST  ECB1,0
         LA    1,ECB1
         L     0,=A(0)
         SVC   2 POST R0=CODE, R1=A(ECB)
*MEXIT #=     7 LV= 1 POST
*MCALL #=     8 LV= 1          STIMER REAL,SEXIT,BINTVL==F'200'  RESTARX
               T STIMER AGAIN
        LA    0,SEXIT       REAL EXIT
        IIHF  0,X'02010000' REAL BINTVL
        LA    1,=F'200'
        SVC   X'2F' STIMER R0B0=TYPE,R0B1=INT, R0=EXIT, R1=INTVL ARG
*MEXIT #=     8 LV= 1 STIMER
         BR    14
POST2    EQU   *
         CLI   ECB2,X'80'   ARE WE WAITING FOR ECB2 POST
         BNE   ABORT
*MCALL #=     9 LV= 1          POST  ECB2,0
         LA    1,ECB2
         L     0,=A(0)
         SVC   2 POST R0=CODE, R1=A(ECB)
*MEXIT #=     9 LV= 1 POST
         BR    14
*MCALL #=    10 LV= 1 ABORT    WTO   'TESTECB1 SEXIT POST ERROR ABORTINX
               G'
ABORT    DS    0H
         BRAS  1,*+(WTO#0010_EOT-*+1)/2*2
         DC    AL2(WTO#0010_EOT-*,0),C'TESTECB1 SEXIT POST ERROR ABORTIX
               NG'
WTO#0010_EOT     EQU *
         SVC   35
*MEXIT #=    10 LV= 1 WTO
*MCALL #=    11 LV= 1          ABEND 111,DUMP
         LA   1,111
         OILH 1,X'8000'
         SVC  13 ABEND R1=COMP CODE AND HIGH BIT = DUMP PGM STORAGE
*MEXIT #=    11 LV= 1 ABEND
         DROP  15
ECB1     DC    F'0'
ECB2     DC    F'0'
*MCALL #=    12 LV= 1          EQUREGS 
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
*MEXIT #=    12 LV= 1 EQUREGS
         END 
