*********************************************************************
* Copyright 2006 Automated Software Tools Corporation               *
* Copyright 2013 Cat Herder Software, LLC                           *
* Copyright 2018 Joachim Bartz, Germany                             *
*                                                                   *
* This source code is part of z390 assembler/emulator package.      *
*                                                                   *
* The z390 package is distributed under GNU general public license  *
*                                                                   *
* Note: Needs extra macro file rt\test\TESTSYN2.MAC                 *
*                                                                   *
* Author - Don Higgins                                              *
*********************************************************************
* 2006-04-30  DSH         Initial version                           *
* 2006-04-30  DSH RPI-306 Test OPSYN for MACRO VS OPCODE            *
* 2007-03-06  DSH RPI-352 Test OPSYN redefine of MAC OP             *
* 2006-08-07  DSH RPI-403 Test OPCODE used before first and after   *
*                         last restore                              *
*********************************************************************
*MCALL #=     1 LV= 1 TESTSYN2 SUBENTRY 
TESTSYN2 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTSYN2'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTSYN2+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
*MCALL #=     2 LV= 1          WTO   'TESTSYN2 STARTED'
         BRAS  1,*+(WTO#0002_EOT-*+1)/2*2
         DC    AL2(WTO#0002_EOT-*,0),C'TESTSYN2 STARTED'
WTO#0002_EOT     EQU *
         SVC   35
*MEXIT #=     2 LV= 1 WTO
         B     SKIPDC
         DC    C'DC BEFORE FIRST OPSYN'
SKIPDC   DS    0H
         PUSH  PRINT
_PUSH    OPSYN PUSH
PUSH     OPSYN TESTSYN2  * Using extra macro file here
*MCALL #=     3 LV= 1          PUSH  123
*MCALL #=     4 LV= 2          WTO      'WTO FROM TESTSYN2 WITH P1=123'
         BRAS  1,*+(WTO#0004_EOT-*+1)/2*2
         DC    AL2(WTO#0004_EOT-*,0),C'WTO FROM TESTSYN2 WITH P1=123'
WTO#0004_EOT     EQU *
         SVC   35
*MEXIT #=     4 LV= 2 WTO
*MEXIT #=     3 LV= 1 TESTSYN2
TESTSYNX OPSYN TESTSYN2
*MCALL #=     5 LV= 1          TESTSYNX ABC
*MCALL #=     6 LV= 2          WTO      'WTO FROM TESTSYN2 WITH P1=ABC'
         BRAS  1,*+(WTO#0006_EOT-*+1)/2*2
         DC    AL2(WTO#0006_EOT-*,0),C'WTO FROM TESTSYN2 WITH P1=ABC'
WTO#0006_EOT     EQU *
         SVC   35
*MEXIT #=     6 LV= 2 WTO
*MEXIT #=     5 LV= 1 TESTSYN2
*MCALL #=     7 LV= 1          WTO   'TESTSYN2 ENDED'
         BRAS  1,*+(WTO#0007_EOT-*+1)/2*2
         DC    AL2(WTO#0007_EOT-*,0),C'TESTSYN2 ENDED'
WTO#0007_EOT     EQU *
         SVC   35
*MEXIT #=     7 LV= 1 WTO
*MCALL #=     8 LV= 1          SUBEXIT 
         LA    15,0
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=     8 LV= 1 SUBEXIT
* TEST DC AFTER
DCX      OPSYN DC
DC       OPSYN MNOTE
         MNOTE 'DC MNOTE'
DC       OPSYN DCX
         DC    C'DC AFTER OPSYN RESTORE'
         END 
