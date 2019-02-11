*********************************************************************
* Copyright 2005 Automated Software Tools Corporation               *
* Copyright 2013 Cat Herder Software, LLC                           *
* Copyright 2018 Joachim Bartz, Germany                             *
*                                                                   *
* This source code is part of z390 assembler/emulator package.      *
*                                                                   *
* Note: Needs extra macro file rt\test\TESTPRM2.MAC                 *
*                                                                   *
* The z390 package is distributed under GNU general public license  *
*                                                                   *
* Author - Don Higgins                                              *
*********************************************************************
* 2005-09-30  DSH Initial version                                   *
*********************************************************************
*MCALL #=     1 LV= 1 TESTPRM2 SUBENTRY 
TESTPRM2 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTPRM2'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTPRM2+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
*MCALL #=     2 LV= 1          WTO   'TESTPRM2 - TEST POSITIONAL AND KEX
               YWORD PARMS'
         BRAS  1,*+(WTO#0002_EOT-*+1)/2*2
         DC    AL2(WTO#0002_EOT-*,0),C'TESTPRM2 - TEST POSITIONAL AND KX
               EYWORD PARMS'
WTO#0002_EOT     EQU *
         SVC   35
*MEXIT #=     2 LV= 1 WTO
*MCALL #=     3 LV= 1 POS0     TESTPRM2 'POS1',KEY1=c'KEY1',C'POS2',,''X
               'POS4''',KEY2=' KEY2,',KEY3=KEY3
         MNOTE ' POS0 = POS0'
         MNOTE ' POS1 = 'POS1''
         MNOTE ' POS2 = C'POS2''
         MNOTE ' POS3 = '
         MNOTE ' POS4 = '''POS4''''
         MNOTE ' KEY1 = c'KEY1''
         MNOTE ' KEY2 = ' KEY2,''
         MNOTE ' KEY3 = KEY3'
         MNOTE ' KEY4 = DEFKEY4'
*MEXIT #=     3 LV= 1 TESTPRM2
*MCALL #=     4 LV= 1          SUBEXIT 
         LA    15,0
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=     4 LV= 1 SUBEXIT
         END 
