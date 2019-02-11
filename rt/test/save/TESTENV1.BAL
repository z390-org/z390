***********************************************************************
* Copyright 2013 Cat Herder Software, LLC                           *
* Copyright 2018 Joachim Bartz, Germany                             *
*                                                                   *
* This source code is part of z390 assembler/emulator package.      *
*                                                                   *
* The z390 package is distributed under GNU general public license  *
*                                                                   *
* Author - Don Higgins                                              *
*********************************************************************
* 2007-07-12 DSH         Initial version                            *
* 2007-07-12 DSH RPI-413 Test GETENV and SETENV                     *
*********************************************************************
         TITLE 'TESTENV1 - TEST ENVIRONMENT VARIABLE GET/SET'
*MCALL #=     1 LV= 1 TESTENV1 SUBENTRY 
TESTENV1 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTENV1'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTENV1+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
*MCALL #=     2 LV= 1          WTO   'TESTENV1 START GETENV TEST'
         BRAS  1,*+(WTO#0002_EOT-*+1)/2*2
         DC    AL2(WTO#0002_EOT-*,0),C'TESTENV1 START GETENV TEST'
WTO#0002_EOT     EQU *
         SVC   35
*MEXIT #=     2 LV= 1 WTO
*MCALL #=     3 LV= 1          GETENV MYENV
         LA    1,MYENV
         LA   0,1
         SVC  40 EXTRACT GETENV R0=1, R1=A(NAME) OUTPUT R2=A(VALUE)
*MEXIT #=     3 LV= 1 GETENV
         LR    4,2   Save the environment value we got
         LA    5,256(4)
*MCALL #=     4 LV= 1          SNAP  ID=1,TEXT='ENV.VAR. VALUE',STORAGEX
               =((4),(5))
*MCALL #=     5 LV= 2          ZOPTLR 14,4
         LR    14,4
*MEXIT #=     5 LV= 2 ZOPTLR
*MCALL #=     6 LV= 2          ZOPTLR 15,5
         LR    15,5
*MEXIT #=     6 LV= 2 ZOPTLR
         IILL  0,1                  RPI158
         IILH 0,64512               RPI158
         LA    1,=CL60'ENV.VAR. VALUE'
         SVC   51  SNAP DUMP R0=FLAGS,ID,R1=A(TEXT),R14-15=A(LOW,HIGH)
*MEXIT #=     4 LV= 1 SNAP
*MCALL #=     7 LV= 1          WTO   'TESTENV1 ENDED OK'
         BRAS  1,*+(WTO#0007_EOT-*+1)/2*2
         DC    AL2(WTO#0007_EOT-*,0),C'TESTENV1 ENDED OK'
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
MYENV    DC    C'PSModulePath',X'00'
         END 
