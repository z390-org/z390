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
* 2005-09-30  DSH Initial version                                   *
*********************************************************************
*MCALL #=     1 LV= 1 TESTPRM3 SUBENTRY 
TESTPRM3 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTPRM3'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTPRM3+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
*MCALL #=     2 LV= 1          WTO   'TESTPRM3 - TEST SUBLIST PARMS ANDX
                N AND K OPERATORS'
         BRAS  1,*+(WTO#0002_EOT-*+1)/2*2
         DC    AL2(WTO#0002_EOT-*,0),C'TESTPRM3 - TEST SUBLIST PARMS ANX
               D N AND K OPERATORS'
WTO#0002_EOT     EQU *
         SVC   35
*MEXIT #=     2 LV= 1 WTO
         MACRO
&N       TEST  &P1,&S1,&S2
         MNOTE 'N=&N P1=&P1 S1=&S1 S2=&S2'
         MNOTE 'P1(S1)=&P1(&S1)'
         MNOTE 'P1(S1,S2)=&P1(&S1,&S2)'
&I       SETA  0
.LOOP    ANOP
         MNOTE 'SYSLIST(&I)=&SYSLIST(&I)'
&I       SETA  &I+1
         AIF   (&I LE 3).LOOP
         MNOTE 'SYSLIST(1,&S1)=&SYSLIST(1,&S1)'
         MNOTE 'SYSLIST(1,&S1,1)=&SYSLIST(1,&S1,1)'
         MNOTE 'SYSLIST(1,&S1,&S2)=&SYSLIST(1,&S1,&S2)'
&T       SETC  '&SYSLIST(1)'
         MNOTE 'SETC SYSLIST(1)=&T'
&T       SETC  '&SYSLIST(1,&S1)'
         MNOTE 'SETC SYSLIST(1,&S1)=&T'
&T       SETC  '&SYSLIST(1,&S1,1)'
         MNOTE 'SETC SYSLIST(1,&S1,1)=&T'
&T       SETC  '&SYSLIST(1,&S1,2)'
         MNOTE 'SETC SYSLIST(1,&S1,2)=&T'
&NP      SETA  N'&P1
         MNOTE 'N''P1=&NP'
&NP      SETA  N'&SYSLIST
         MNOTE 'N''SYSLIST=&NP'
&NP      SETA  N'&SYSLIST(2)
         MNOTE 'N''SYSLIST(2)=&NP'
         MEND
*MCALL #=     3 LV= 1 T1       TEST  (A),1,1
         MNOTE 'N=T1 P1=(A) S1=1 S2=1'
         MNOTE 'P1(S1)=A'
         MNOTE 'P1(S1,S2)=A'
         MNOTE 'SYSLIST(0)=T1'
         MNOTE 'SYSLIST(1)=(A)'
         MNOTE 'SYSLIST(2)=1'
         MNOTE 'SYSLIST(3)=1'
         MNOTE 'SYSLIST(1,1)=A'
         MNOTE 'SYSLIST(1,1,1)=A'
         MNOTE 'SYSLIST(1,1,1)=A'
         MNOTE 'SETC SYSLIST(1)=(A)'
         MNOTE 'SETC SYSLIST(1,1)=A'
         MNOTE 'SETC SYSLIST(1,1,1)=A'
         MNOTE 'SETC SYSLIST(1,1,2)='
         MNOTE 'N'P1=1'
         MNOTE 'N'SYSLIST=3'
         MNOTE 'N'SYSLIST(2)=1'
*MEXIT #=     3 LV= 1 TEST
*MCALL #=     4 LV= 1 T2       TEST  (A,B),2,1
         MNOTE 'N=T2 P1=(A,B) S1=2 S2=1'
         MNOTE 'P1(S1)=B'
         MNOTE 'P1(S1,S2)=B'
         MNOTE 'SYSLIST(0)=T2'
         MNOTE 'SYSLIST(1)=(A,B)'
         MNOTE 'SYSLIST(2)=2'
         MNOTE 'SYSLIST(3)=1'
         MNOTE 'SYSLIST(1,2)=B'
         MNOTE 'SYSLIST(1,2,1)=B'
         MNOTE 'SYSLIST(1,2,1)=B'
         MNOTE 'SETC SYSLIST(1)=(A,B)'
         MNOTE 'SETC SYSLIST(1,2)=B'
         MNOTE 'SETC SYSLIST(1,2,1)=B'
         MNOTE 'SETC SYSLIST(1,2,2)='
         MNOTE 'N'P1=2'
         MNOTE 'N'SYSLIST=3'
         MNOTE 'N'SYSLIST(2)=1'
*MEXIT #=     4 LV= 1 TEST
*MCALL #=     5 LV= 1 T3       TEST  (A,(B1,B2),C),2,2
         MNOTE 'N=T3 P1=(A,(B1,B2),C) S1=2 S2=2'
         MNOTE 'P1(S1)=(B1,B2)'
         MNOTE 'P1(S1,S2)=B2'
         MNOTE 'SYSLIST(0)=T3'
         MNOTE 'SYSLIST(1)=(A,(B1,B2),C)'
         MNOTE 'SYSLIST(2)=2'
         MNOTE 'SYSLIST(3)=2'
         MNOTE 'SYSLIST(1,2)=(B1,B2)'
         MNOTE 'SYSLIST(1,2,1)=B1'
         MNOTE 'SYSLIST(1,2,2)=B2'
         MNOTE 'SETC SYSLIST(1)=(A,(B1,B2),C)'
         MNOTE 'SETC SYSLIST(1,2)=(B1,B2)'
         MNOTE 'SETC SYSLIST(1,2,1)=B1'
         MNOTE 'SETC SYSLIST(1,2,2)=B2'
         MNOTE 'N'P1=3'
         MNOTE 'N'SYSLIST=3'
         MNOTE 'N'SYSLIST(2)=1'
*MEXIT #=     5 LV= 1 TEST
*MCALL #=     6 LV= 1          SUBEXIT 
         LA    15,0
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=     6 LV= 1 SUBEXIT
         END 
