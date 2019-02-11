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
* 2006-04-26  DSH Initial version                                   *
* 2006-04-26  DSH RPI-293 Test EXEC SQL INCLUDE SUPPORT             *
*********************************************************************
*
* mz390 parses space delimited EXEC SQL/CICS/DLI statements into
* exec macro call statements with comma delimited parameters
*
* 1. EXEC SQL INCLUDE member - invokes call to macro named member
*
*********************************************************************
         TITLE 'TESTSQL1 - TEST EXEC SQL INCLUDE SUPPORT'
*MCALL #=     1 LV= 1 TESTSQL1 SUBENTRY 
TESTSQL1 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTSQL1'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTSQL1+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
*MCALL #=     2 LV= 1          WTO   'TESTSQL1 - TEST EXEC SQL INCLUDE X
               TESTSQL1'
         BRAS  1,*+(WTO#0002_EOT-*+1)/2*2
         DC    AL2(WTO#0002_EOT-*,0),C'TESTSQL1 - TEST EXEC SQL INCLUDEX
                TESTSQL1'
WTO#0002_EOT     EQU *
         SVC   35
*MEXIT #=     2 LV= 1 WTO
*MCALL #=     3 LV= 1  EXEC SQL,INCLUDE,TESTSQL1
*MCALL #=     4 LV= 2          SQL_INCLUDE           TESTSQL1
*MCALL #=     5 LV= 3          TESTSQL1 
*MCALL #=     6 LV= 4          WTO 'TESTSQL1 INCLUDED CODE FROM TESTSQLX
               1.MAC'
         BRAS  1,*+(WTO#0006_EOT-*+1)/2*2
         DC    AL2(WTO#0006_EOT-*,0),C'TESTSQL1 INCLUDED CODE FROM TESTX
               SQL1.MAC'
WTO#0006_EOT     EQU *
         SVC   35
*MEXIT #=     6 LV= 4 WTO
*MEXIT #=     5 LV= 3 TESTSQL1
*MEXIT #=     4 LV= 2 SQL_INCLUDE
*MEXIT #=     3 LV= 1 EXEC
*MCALL #=     7 LV= 1          WTO   'TESTSQL1 ENDED OK'
         BRAS  1,*+(WTO#0007_EOT-*+1)/2*2
         DC    AL2(WTO#0007_EOT-*,0),C'TESTSQL1 ENDED OK'
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
         END 
