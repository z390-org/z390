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
* 2006-03-28  DSH RPI-266 Create TESTMAC8.MLC and TESTMAC8.MAC test *
*                         inlines                                   *
* 2006-04-09  DSH RPI-274 Test .EXIT on nested MENDS/END            *
*********************************************************************
*MCALL #=     1 LV= 1 TESTMAC8 SUBENTRY 
TESTMAC8 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTMAC8'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTMAC8+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
*MCALL #=     2 LV= 1          WTO   'TESTMAC8 - TEST INLINE MACROS WITX
               HIN MACROS'
         BRAS  1,*+(WTO#0002_EOT-*+1)/2*2
         DC    AL2(WTO#0002_EOT-*,0),C'TESTMAC8 - TEST INLINE MACROS WIX
               THIN MACROS'
WTO#0002_EOT     EQU *
         SVC   35
*MEXIT #=     2 LV= 1 WTO
         MACRO
&L       ILM1  &P,&K=
.LOOP    ANOP
&A       SETA  &A+1
         AIF   (&A LT 3).LOOP
         MNOTE 'ILM1 L=&L P=&P K=&K A=&A'
         MACRO
&L       ILM2  &P,&K=
.LOOP    ANOP
&A       SETA  &A+1
         AIF   (&A LT 3).LOOP
         MNOTE 'ILM2 L=&L P=&P K=&K A=&A'
         MNOTE 'TEST .EXIT FOR ILM2'
         AGO   .EXIT
.EXIT    MEND
L2       ILM2  P2,K=K2
         MNOTE 'TEST .EXIT FOR ILM1'
         AGO   .EXIT
.EXIT    MEND
*MCALL #=     3 LV= 1 L1       ILM1  P1,K=K1
         MNOTE 'ILM1 L=L1 P=P1 K=K1 A=3'
         MACRO
&L       ILM2  &P,&K=
.LOOP    ANOP
&A       SETA  &A+1
         AIF   (&A LT 3).LOOP
         MNOTE 'ILM2 L=&L P=&P K=&K A=&A'
         MNOTE 'TEST .EXIT FOR ILM2'
         AGO   .EXIT
.EXIT    MEND
*MCALL #=     4 LV= 2 L2       ILM2  P2,K=K2
         MNOTE 'ILM2 L=L2 P=P2 K=K2 A=3'
         MNOTE 'TEST .EXIT FOR ILM2'
*MEXIT #=     4 LV= 2 ILM2
         MNOTE 'TEST .EXIT FOR ILM1'
*MEXIT #=     3 LV= 1 ILM1
*MCALL #=     5 LV= 1 L3       TESTMAC8 P3,K=K3 TEST EXTERNAL MACRO WITX
               H INLINE MACROS
         MNOTE 'TESTMAC8 L=L3 P=P3 K=K3 A=3'
         MACRO
&L       ILM4  &P,&K=
.LOOP    ANOP
&A       SETA  &A+1
         AIF   (&A LT 3).LOOP
         MNOTE 'ILM4 L=&L P=&P K=&K A=&A'
         MACRO
&L       ILM5  &P,&K=
.LOOP    ANOP
&A       SETA  &A+1
         AIF   (&A LT 3).LOOP
         MNOTE 'ILM5 L=&L P=&P K=&K A=&A'
         MNOTE 'TEST .EXIT FOR TESTMAC8 ILM5'
         AGO   .EXIT
.EXIT    MEND
L5       ILM5  P5,K=K5
         MNOTE 'TEST .EXIT FOR TESTMAC8 ILM4'
         AGO   .EXIT
.EXIT    MEND
*MCALL #=     6 LV= 2 L4       ILM4  P4,K=K4
         MNOTE 'ILM4 L=L4 P=P4 K=K4 A=3'
         MACRO
&L       ILM5  &P,&K=
.LOOP    ANOP
&A       SETA  &A+1
         AIF   (&A LT 3).LOOP
         MNOTE 'ILM5 L=&L P=&P K=&K A=&A'
         MNOTE 'TEST .EXIT FOR TESTMAC8 ILM5'
         AGO   .EXIT
.EXIT    MEND
*MCALL #=     7 LV= 3 L5       ILM5  P5,K=K5
         MNOTE 'ILM5 L=L5 P=P5 K=K5 A=3'
         MNOTE 'TEST .EXIT FOR TESTMAC8 ILM5'
*MEXIT #=     7 LV= 3 ILM5
         MNOTE 'TEST .EXIT FOR TESTMAC8 ILM4'
*MEXIT #=     6 LV= 2 ILM4
         MNOTE 'TEST .EXIT FOR TESTMAC8 MACRO'
*MEXIT #=     5 LV= 1 TESTMAC8
*MCALL #=     8 LV= 1          WTO   'TESTMAC8 ENDED OK'
         BRAS  1,*+(WTO#0008_EOT-*+1)/2*2
         DC    AL2(WTO#0008_EOT-*,0),C'TESTMAC8 ENDED OK'
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
         MNOTE 'TEST .EXIT FOR MLC ON END'
         END 
