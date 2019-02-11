*********************************************************************
* Copyright 2012 Automated Software Tools Corporation               *
* Copyright 2013 Cat Herder Software, LLC                           *
* Copyright 2018 Joachim Bartz, Germany                             *
*                                                                   *
* This source code is part of z390 assembler/emulator package.      *
*                                                                   *
* The z390 package is distributed under GNU general public license  *
*                                                                   *
* Author - Don Higgins                                              *
*********************************************************************
* 2012-03-08 DSH         Initial version                            *
*********************************************************************
      TITLE 'TESTLNK4 TEST ENTRY AT TEST3 VIA END TEST3'
*MCALL #=     1 LV= 1 TEST1 SUBENTRY 
TEST1    CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TEST1'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TEST1+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
*MCALL #=     2 LV= 1       WTO      'TEST1 ENTERED'
         BRAS  1,*+(WTO#0002_EOT-*+1)/2*2
         DC    AL2(WTO#0002_EOT-*,0),C'TEST1 ENTERED'
WTO#0002_EOT     EQU *
         SVC   35
*MEXIT #=     2 LV= 1 WTO
*MCALL #=     3 LV= 1       SUBEXIT 
         LA    15,0
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=     3 LV= 1 SUBEXIT
*MCALL #=     4 LV= 1 TEST2 SUBENTRY 
TEST2    CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TEST2'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TEST2+8,13
*MEXIT #=     4 LV= 1 SUBENTRY
*MCALL #=     5 LV= 1       WTO      'TEST2 ENTERED'
         BRAS  1,*+(WTO#0005_EOT-*+1)/2*2
         DC    AL2(WTO#0005_EOT-*,0),C'TEST2 ENTERED'
WTO#0005_EOT     EQU *
         SVC   35
*MEXIT #=     5 LV= 1 WTO
*MCALL #=     6 LV= 1       SUBEXIT 
         LA    15,0
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=     6 LV= 1 SUBEXIT
TEST3 BALR 12,0
      USING *,12
*MCALL #=     7 LV= 1       WTO      'TEST3 ENTERED'
         BRAS  1,*+(WTO#0007_EOT-*+1)/2*2
         DC    AL2(WTO#0007_EOT-*,0),C'TEST3 ENTERED'
WTO#0007_EOT     EQU *
         SVC   35
*MEXIT #=     7 LV= 1 WTO
      SR  15,15
      BR  14
      END TEST3
