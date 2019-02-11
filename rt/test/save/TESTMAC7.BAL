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
* 2006-03-17  DSH RPI-239 Test TAB vs SPACE before comments         *
*********************************************************************
*
* NOTE: THIS SOURCE MUST BE EDITED BY NOTEPAD TO KEEP TAB ON X      *
*
*********************************************************************
*MCALL #=     1 LV= 1 TESTMAC7 SUBENTRY 
TESTMAC7 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTMAC7'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTMAC7+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
*MCALL #=     2 LV= 1          WTO   'TESTMAC7 - TEST TAB VERSUS SPACE X
               USING NOTEPAD'
         BRAS  1,*+(WTO#0002_EOT-*+1)/2*2
         DC    AL2(WTO#0002_EOT-*,0),C'TESTMAC7 - TEST TAB VERSUS SPACEX
                USING NOTEPAD'
WTO#0002_EOT     EQU *
         SVC   35
*MEXIT #=     2 LV= 1 WTO
 MVI   X,C'X'    TEST TAB BEFORE MVI
         CLI X,C'X'  TEST TAB AFTER CLI
         BNE   1
*MCALL #=     3 LV= 1          WTO   'TESTMAC7 ENDED OK'
         BRAS  1,*+(WTO#0003_EOT-*+1)/2*2
         DC    AL2(WTO#0003_EOT-*,0),C'TESTMAC7 ENDED OK'
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
X DS C	TEST TAB BEFORE THIS COMMENT ********
         END 
