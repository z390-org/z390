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
* 2007-05-14  DSH RPI-604 Test option BS2000 system variables       *
*********************************************************************
*MCALL #=     1 LV= 1 TESTSYS2 SUBENTRY 
TESTSYS2 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTSYS2'
         DC    CL8'010205002'
         DC    CL8'223344'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTSYS2+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
*MCALL #=     2 LV= 1          WTO   'TESTSYS2 STARTED'
         BRAS  1,*+(WTO#0002_EOT-*+1)/2*2
         DC    AL2(WTO#0002_EOT-*,0),C'TESTSYS2 STARTED'
WTO#0002_EOT     EQU *
         SVC   35
*MEXIT #=     2 LV= 1 WTO
         MNOTE 'SYSTEM=1507'
         MNOTE 'SYSMOD=24'
         MNOTE 'SYSTIME=223344'
         MNOTE 'SYSDATE=010205002'
         MNOTE 'SYSVERM=VER   '
         MNOTE 'SYSVERS=VER   '
         MACRO
         TEST
         MNOTE 'SYSTSEC=&SYSTSEC'
         MEND
*MCALL #=     3 LV= 1          TEST 
         MNOTE 'SYSTSEC=CSECT'
*MEXIT #=     3 LV= 1 TEST
TESTD    DSECT 
*MCALL #=     4 LV= 1          TEST 
         MNOTE 'SYSTSEC=DSECT'
*MEXIT #=     4 LV= 1 TEST
TESTDLOC LOCTR 
*MCALL #=     5 LV= 1          TEST 
         MNOTE 'SYSTSEC=DSECT'
*MEXIT #=     5 LV= 1 TEST
TESTSYS2 CSECT 
*MCALL #=     6 LV= 1          TEST 
         MNOTE 'SYSTSEC=CSECT'
*MEXIT #=     6 LV= 1 TEST
*MCALL #=     7 LV= 1          GPARMOD 31
*MEXIT #=     7 LV= 1 GPARMOD
         MNOTE 'SYSMOD=31'
*MCALL #=     8 LV= 1          GPARMOD 24
*MEXIT #=     8 LV= 1 GPARMOD
         MNOTE 'SYSMOD=24'
*MCALL #=     9 LV= 1          WTO   'TESTSYS2 ENDED OK'
         BRAS  1,*+(WTO#0009_EOT-*+1)/2*2
         DC    AL2(WTO#0009_EOT-*,0),C'TESTSYS2 ENDED OK'
WTO#0009_EOT     EQU *
         SVC   35
*MEXIT #=     9 LV= 1 WTO
*MCALL #=    10 LV= 1          SUBEXIT 
         LA    15,0
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=    10 LV= 1 SUBEXIT
         END 
