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
*********************************************************************
* 2008-12-10  DSH          Initial version                          *
* 2009-09-02  DSH RPI-1019 Test AINSERT copy front and back         *
*********************************************************************
* MAINTENANCE                                                       *
*********************************************************************
         MACRO
         TEST1
         AINSERT ' COPY TESTAI2B',FRONT
         AINSERT ' COPY TESTAI2C',BACK
         AINSERT ' COPY TESTAI2A',FRONT
         MEND
*MCALL #=     1 LV= 1 TESTAIN2 SUBENTRY 
TESTAIN2 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTAIN2'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTAIN2+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
*MCALL #=     2 LV= 1          WTO   'TESTAIN2 STARTED'
         BRAS  1,*+(WTO#0002_EOT-*+1)/2*2
         DC    AL2(WTO#0002_EOT-*,0),C'TESTAIN2 STARTED'
WTO#0002_EOT     EQU *
         SVC   35
*MEXIT #=     2 LV= 1 WTO
*MCALL #=     3 LV= 1          TEST1 
*MEXIT #=     3 LV= 1 TEST1
 COPY TESTAI2A
* TESTAI2A.CPY RECORD 1 OF 3
* TESTAI2A.CPY RECORD 2 OF 3
* TESTAI2A.CPY RECORD 3 OF 3
 COPY TESTAI2B
* TESTAI2B.CPY RECORD 1 OF 3
* TESTAI2B.CPY RECORD 2 OF 3
* TESTAI2B.CPY RECORD 3 OF 3
 COPY TESTAI2C
* TESTAI2C.CPY RECORD 1 OF 3
* TESTAI2C.CPY RECORD 2 OF 3
* TESTAI2C.CPY RECORD 3 OF 3
*MCALL #=     4 LV= 1          WTO   'TESTAIN2 ENDED'
         BRAS  1,*+(WTO#0004_EOT-*+1)/2*2
         DC    AL2(WTO#0004_EOT-*,0),C'TESTAIN2 ENDED'
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
         END 
