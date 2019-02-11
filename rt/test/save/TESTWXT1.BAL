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
* 2005-09-30 DSH         Initial version                            *
*********************************************************************
*MCALL #=     1 LV= 1 TESTWXT1 SUBENTRY 
TESTWXT1 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTWXT1'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTWXT1+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
*MCALL #=     2 LV= 1          WTO 'TESTWXT1 TEST WXTRN STATIC LINK'
         BRAS  1,*+(WTO#0002_EOT-*+1)/2*2
         DC    AL2(WTO#0002_EOT-*,0),C'TESTWXT1 TEST WXTRN STATIC LINK'
WTO#0002_EOT     EQU *
         SVC   35
*MEXIT #=     2 LV= 1 WTO
         L    15,=V(TESTSUB1)  FORCE LOADING OF TESTSUB1
         LTR  15,15
         BZ   ERR              VERIFY FIRST EXTRN FOUND
         BALR 14,15
         WXTRN TESTSUB2
         L    15,=A(TESTSUB2)
         LTR  15,15
         BZ   ERR             VERIFY SECOND WXTRN FOUND IN TESTSUB1
         BALR 14,15
         WXTRN TESTSUB3
         L    15,=A(TESTSUB3)
         LTR  15,15
         BZ   ERR             VERIFY THIRD WXTRN FOUND IN TESTSUB1
         BALR 14,15
         WXTRN TESTSUBX
         L    15,=A(TESTSUBX)
         LTR  15,15
         BNZ  ERR             VERIFY LAST WXTRN NOT FOUND
*MCALL #=     3 LV= 1          WTO  'TESTWXT1 ENDED OK'
         BRAS  1,*+(WTO#0003_EOT-*+1)/2*2
         DC    AL2(WTO#0003_EOT-*,0),C'TESTWXT1 ENDED OK'
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
*MCALL #=     5 LV= 1 ERR      WTO  'TESTWXT1 ERROR ABORTING'
ERR      DS    0H
         BRAS  1,*+(WTO#0005_EOT-*+1)/2*2
         DC    AL2(WTO#0005_EOT-*,0),C'TESTWXT1 ERROR ABORTING'
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
         END 
