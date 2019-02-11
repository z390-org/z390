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
* 2006-03-13  DSH RPI-223 Support keyword parameter values of the   *
*                         form (A,B) etc.                           *
* 2006-03-20  DSH RPI-250 Test special characters within (.....)    *
*                         for keyword                               *
*********************************************************************
*MCALL #=     1 LV= 1 TESTMAC6 SUBENTRY 
TESTMAC6 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTMAC6'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTMAC6+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
*MCALL #=     2 LV= 1          WTO   'TESTMAC6 TEST RPI-223 SUPPORT OF X
               COMPLEX KEY VALUES'
         BRAS  1,*+(WTO#0002_EOT-*+1)/2*2
         DC    AL2(WTO#0002_EOT-*,0),C'TESTMAC6 TEST RPI-223 SUPPORT OFX
                COMPLEX KEY VALUES'
WTO#0002_EOT     EQU *
         SVC   35
*MEXIT #=     2 LV= 1 WTO
         MACRO
&NA      TEST  &K1=,&K2=1234,&K3=(A,B,C),&K4='A B',&K5=('A, B'),&K6=' 'X
               ,&K7=(?,?),&K8=X
         MNOTE  'K1=&K1'
         MNOTE  'K2=&K2'
         MNOTE  'K3=&K3'
         MNOTE  'K4=&K4'
         MNOTE  'K5=&K5'
         MNOTE  'K6=&K6'
         MNOTE  'K7=&K7'
         MNOTE  'K8=&K8'
         MEND
*MCALL #=     3 LV= 1          TEST 
         MNOTE 'K1='
         MNOTE 'K2=1234'
         MNOTE 'K3=(A,B,C)'
         MNOTE 'K4='A B''
         MNOTE 'K5=('A, B')'
         MNOTE 'K6=' ''
         MNOTE 'K7=(?,?)'
         MNOTE 'K8=X'
*MEXIT #=     3 LV= 1 TEST
*MCALL #=     4 LV= 1          TEST  K3=(D,E,F),K4='C D'
         MNOTE 'K1='
         MNOTE 'K2=1234'
         MNOTE 'K3=(D,E,F)'
         MNOTE 'K4='C D''
         MNOTE 'K5=('A, B')'
         MNOTE 'K6=' ''
         MNOTE 'K7=(?,?)'
         MNOTE 'K8=X'
*MEXIT #=     4 LV= 1 TEST
*MCALL #=     5 LV= 1          TEST  K3=(D,E,F),K4='C D'
         MNOTE 'K1='
         MNOTE 'K2=1234'
         MNOTE 'K3=(D,E,F)'
         MNOTE 'K4='C D''
         MNOTE 'K5=('A, B')'
         MNOTE 'K6=' ''
         MNOTE 'K7=(?,?)'
         MNOTE 'K8=X'
*MEXIT #=     5 LV= 1 TEST
*MCALL #=     6 LV= 1          TEST  K3=(?,?),K4='C D'
         MNOTE 'K1='
         MNOTE 'K2=1234'
         MNOTE 'K3=(?,?)'
         MNOTE 'K4='C D''
         MNOTE 'K5=('A, B')'
         MNOTE 'K6=' ''
         MNOTE 'K7=(?,?)'
         MNOTE 'K8=X'
*MEXIT #=     6 LV= 1 TEST
*MCALL #=     7 LV= 1          WTO   'TESTMAC6 ENDED OK'
         BRAS  1,*+(WTO#0007_EOT-*+1)/2*2
         DC    AL2(WTO#0007_EOT-*,0),C'TESTMAC6 ENDED OK'
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
