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
* 2007-04-14  DSH RPI-590 Correct BDDD offsets to both be less than *
*                         X'100'                                    *
*********************************************************************
*MCALL #=     1 LV= 1 TESTUSE2 SUBENTRY 
TESTUSE2 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTUSE2'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTUSE2+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
*MCALL #=     2 LV= 1          WTO   'TESTUSE2 TEST PUSH/POP USING'
         BRAS  1,*+(WTO#0002_EOT-*+1)/2*2
         DC    AL2(WTO#0002_EOT-*,0),C'TESTUSE2 TEST PUSH/POP USING'
WTO#0002_EOT     EQU *
         SVC   35
*MEXIT #=     2 LV= 1 WTO
         CLC   =S(TESTUSE2+8),=X'D000'
         BNE   ERR
         PUSH  USING    SAVE USING 13
         DROP  ,        DROP ALL
         BALR  12,0
         USING *,12     NEW USING 12
LA12X    LA    11,LA12X
         CLI   LA12X+2,X'C0'
         BNE   ERR
         POP   USING   RESTORE USING 13
LA12X2   LA    11,LA12X
         CLI   LA12X2+2,X'D0'
         BNE   ERR
*MCALL #=     3 LV= 1          WTO   'TESTUSE2 ENDED OK'
         BRAS  1,*+(WTO#0003_EOT-*+1)/2*2
         DC    AL2(WTO#0003_EOT-*,0),C'TESTUSE2 ENDED OK'
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
*MCALL #=     5 LV= 1 ERR      WTO   'TESTUSE2 ERROR ABORTING'
ERR      DS    0H
         BRAS  1,*+(WTO#0005_EOT-*+1)/2*2
         DC    AL2(WTO#0005_EOT-*,0),C'TESTUSE2 ERROR ABORTING'
WTO#0005_EOT     EQU *
         SVC   35
*MEXIT #=     5 LV= 1 WTO
*MCALL #=     6 LV= 1          SUBEXIT RC=16
         LA    15,16
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=     6 LV= 1 SUBEXIT
X        DC    C'X'
         END 
