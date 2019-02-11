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
* 2008-04-22  DSH RPI-833 Add string quotes for HLASM compatibility *
*********************************************************************
*MCALL #=     1 LV= 1 TESTSET3 SUBENTRY 
TESTSET3 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTSET3'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTSET3+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
*MCALL #=     2 LV= 1          WTO   'TESTSET3 - TEST CREATED SET VARIAX
               BLES'
         BRAS  1,*+(WTO#0002_EOT-*+1)/2*2
         DC    AL2(WTO#0002_EOT-*,0),C'TESTSET3 - TEST CREATED SET VARIX
               ABLES'
WTO#0002_EOT     EQU *
         SVC   35
*MEXIT #=     2 LV= 1 WTO
         MNOTE 'SA1=1'
         MNOTE 'SA1=2'
         MNOTE 'SA2X=1'
         MNOTE 'A(1)=1 A(2)=2'
         MNOTE 'B(1)=1 B(2)=2'
         MNOTE 'SB1=1'
         MNOTE 'SB1=0'
         MNOTE 'SB0X=1'
         MNOTE 'C(1)=0 C(2)=1'
         MNOTE 'D(1)=0 D(2)=1'
         MNOTE 'SC1=1'
         MNOTE 'SC1=2'
         MNOTE 'SC2X=1'
         MNOTE 'T1(1)=A T2(2)=AB'
         MNOTE 'TEXT=ZXABCZ'
*MCALL #=     3 LV= 1          WTO   'TESTSET3 ENDED OK'
         BRAS  1,*+(WTO#0003_EOT-*+1)/2*2
         DC    AL2(WTO#0003_EOT-*,0),C'TESTSET3 ENDED OK'
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
         END 
