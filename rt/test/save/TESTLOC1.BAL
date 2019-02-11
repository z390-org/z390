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
* 2006-04-28 DSH         Initial version                            *
* 2006-04-28 DSH RPI-301 Test multiple LOCTRS and USING             *
*********************************************************************
         TITLE 'TESTLOC1 - TEST MULIPLE LOCTRS'
*MCALL #=     1 LV= 1 TESTLOC1 SUBENTRY 
TESTLOC1 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTLOC1'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTLOC1+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
INS      LOCTR 
*MCALL #=     2 LV= 1          WTO   'TESTLOC1 STARTED'
         BRAS  1,*+(WTO#0002_EOT-*+1)/2*2
         DC    AL2(WTO#0002_EOT-*,0),C'TESTLOC1 STARTED'
WTO#0002_EOT     EQU *
         SVC   35
*MEXIT #=     2 LV= 1 WTO
DATA     LOCTR 
X        DS    X
INS      LOCTR 
         LA    1,X
         CL    1,=A(X)
         BNE   1
*MCALL #=     3 LV= 1          WTO   'TESTLOC1 ENDED OK'
         BRAS  1,*+(WTO#0003_EOT-*+1)/2*2
         DC    AL2(WTO#0003_EOT-*,0),C'TESTLOC1 ENDED OK'
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
         END 
