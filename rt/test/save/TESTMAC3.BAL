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
* 2005-12-30  DSH RPI-49  Test redefine of instruction via inline   *
*                         macro                                     *
* 2006-01-22  DSH RPI-178 Test macro defining local overriding      *
*                         global                                    *
* 2006-01-22  DSH RPI-179 Test macro expanding arrays               *
*********************************************************************
*MCALL #=     1 LV= 1 TESTMAC3 SUBENTRY 
TESTMAC3 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTMAC3'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTMAC3+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
*MCALL #=     2 LV= 1          WTO   'TESTMAC3 - TEST REDEFINE INSTRUCTX
               ION VIA INLINE MACRO'
         BRAS  1,*+(WTO#0002_EOT-*+1)/2*2
         DC    AL2(WTO#0002_EOT-*,0),C'TESTMAC3 - TEST REDEFINE INSTRUCX
               TION VIA INLINE MACRO'
WTO#0002_EOT     EQU *
         SVC   35
*MEXIT #=     2 LV= 1 WTO
* TEST REDEFINE OF B AS BRC
         MACRO
&N       B     &P1
&N       BRC   15,&P1
         MEND
*MCALL #=     3 LV= 1 A        B     B
A        BRC   15,B
*MEXIT #=     3 LV= 1 B
*MCALL #=     4 LV= 1 B        B     *+4
B        BRC   15,*+4
*MEXIT #=     4 LV= 1 B
* TEST REDEFINE OF GLOBAL AS LOCAL FOR NEW MACRO
         MACRO
         DEFG1
         GBLC  &X
&X       SETC  'GLOBAL'
         MNOTE 'DEFG1 X=&X'
         MEND
*MCALL #=     5 LV= 1          DEFG1 
         MNOTE 'DEFG1 X=GLOBAL'
*MEXIT #=     5 LV= 1 DEFG1
         MACRO
         DEFL1
         LCLC  &X
&X       SETC  'LOCAL'
         MNOTE 'DEFL1 X=&X'
         MEND
*MCALL #=     6 LV= 1          DEFL1 
         MNOTE 'DEFL1 X=LOCAL'
*MEXIT #=     6 LV= 1 DEFL1
         MACRO
         DEFG2
         GBLC  &X
         MNOTE 'DEFG2 X=&X'
         MEND
*MCALL #=     7 LV= 1          DEFG2 
         MNOTE 'DEFG2 X=GLOBAL'
*MEXIT #=     7 LV= 1 DEFG2
* TEST MACRO ARRAY EXPANSION
         MNOTE 'A AND B EXPANSION OK'
*MCALL #=     8 LV= 1          WTO   'TESTMAC3 ENDED OK'
         BRAS  1,*+(WTO#0008_EOT-*+1)/2*2
         DC    AL2(WTO#0008_EOT-*,0),C'TESTMAC3 ENDED OK'
WTO#0008_EOT     EQU *
         SVC   35
*MEXIT #=     8 LV= 1 WTO
*MCALL #=     9 LV= 1          SUBEXIT 
         LA    15,0
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=     9 LV= 1 SUBEXIT
         END 
