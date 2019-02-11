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
* 2005-09-30  DSH          Initial version                          *
*********************************************************************
         PRINT NOGEN
*MCALL #=     1 LV= 1 TESTPRT1 SUBENTRY 
TESTPRT1 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTPRT1'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTPRT1+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
*MCALL #=     2 LV= 1          WTO   'TESTPRT1 TEST PUSH/POP PRINT'
         BRAS  1,*+(WTO#0002_EOT-*+1)/2*2
         DC    AL2(WTO#0002_EOT-*,0),C'TESTPRT1 TEST PUSH/POP PRINT'
WTO#0002_EOT     EQU *
         SVC   35
*MEXIT #=     2 LV= 1 WTO
         PRINT GEN
*MCALL #=     3 LV= 1          WTO   'TEST PRINT GEN'
         BRAS  1,*+(WTO#0003_EOT-*+1)/2*2
         DC    AL2(WTO#0003_EOT-*,0),C'TEST PRINT GEN'
WTO#0003_EOT     EQU *
         SVC   35
*MEXIT #=     3 LV= 1 WTO
         PUSH  PRINT
         PRINT OFF
*MCALL #=     4 LV= 1          WTO   'TEST PRINT OFF'
         BRAS  1,*+(WTO#0004_EOT-*+1)/2*2
         DC    AL2(WTO#0004_EOT-*,0),C'TEST PRINT OFF'
WTO#0004_EOT     EQU *
         SVC   35
*MEXIT #=     4 LV= 1 WTO
         PRINT ON,NOGEN
*MCALL #=     5 LV= 1          WTO   'TEST PRINT ON,NOGEN'
         BRAS  1,*+(WTO#0005_EOT-*+1)/2*2
         DC    AL2(WTO#0005_EOT-*,0),C'TEST PRINT ON,NOGEN'
WTO#0005_EOT     EQU *
         SVC   35
*MEXIT #=     5 LV= 1 WTO
         PRINT OFF
         POP   PRINT
*MCALL #=     6 LV= 1          WTO   'TEST BACK TO PRINT GEN AFTER POP'
         BRAS  1,*+(WTO#0006_EOT-*+1)/2*2
         DC    AL2(WTO#0006_EOT-*,0),C'TEST BACK TO PRINT GEN AFTER POPX
               '
WTO#0006_EOT     EQU *
         SVC   35
*MEXIT #=     6 LV= 1 WTO
*MCALL #=     7 LV= 1          WTO   'TESTPRT1 ENDED OK'
         BRAS  1,*+(WTO#0007_EOT-*+1)/2*2
         DC    AL2(WTO#0007_EOT-*,0),C'TESTPRT1 ENDED OK'
WTO#0007_EOT     EQU *
         SVC   35
*MEXIT #=     7 LV= 1 WTO
         PRINT NOGEN
*MCALL #=     8 LV= 1          SUBEXIT 
         LA    15,0
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=     8 LV= 1 SUBEXIT
DC1      DC    16AL1(*-DC1)
         PRINT DATA
DC2      DC    16AL1(*-DC2)
DS1      DS    16AL1(*-DC2)
LC1      LA    1,=16AL1(*-LC1)
LC2      LA    1,=16AL1(*-LC1)
         PRINT NODATA
DC4      DC    16AL1(*-DC2)
         END 
