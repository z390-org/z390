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
* 2005-09-30  DSH         Initial version                           *
* 2006-02-24  DSH RPI-213 Test macro labels on MEND and END         *
*********************************************************************
*MCALL #=     1 LV= 1 TESTMAC4 SUBENTRY 
TESTMAC4 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTMAC4'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTMAC4+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
*MCALL #=     2 LV= 1          WTO   'TESTMAC4 START TEST UPPER/LOWER LX
               ABEL ON MEND/END'
         BRAS  1,*+(WTO#0002_EOT-*+1)/2*2
         DC    AL2(WTO#0002_EOT-*,0),C'TESTMAC4 START TEST UPPER/LOWER X
               LABEL ON MEND/END'
WTO#0002_EOT     EQU *
         SVC   35
*MEXIT #=     2 LV= 1 WTO
*MCALL #=     3 LV= 1          SUBEXIT 
         LA    15,0
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=     3 LV= 1 SUBEXIT
         macro
         test
tm1      ds   x
         ago  .TM1
tm1      ds   x       gen dup error if ago fails
.tm1     anop
TM2      ds   x
         ago  .tm2
TM2      ds   x       gen dup error if ago fails
.TM2     MEND
*MCALL #=     4 LV= 1          TEST 
tm1      DS   x
TM2      DS   x
*MEXIT #=     4 LV= 1 TEST
         MNOTE 'test start'
         END 
