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
* 2005-11-02 DSH RPI-60  Add multiple logical operator tests for    *
*                        AND OR NOT                                 *
* 2006-04-07 DSH RPI-274 Add test for                               *
*                        AIF ('A' EQ 'B' AND ('C' EQ 'D')).ERR      *
* 2006-05-13 DSH RPI-314 Add AIFB and AGOB alias tests              *
* 2006-05-14 DSH RPI-315 Add AIF alternate format and computed ago  *
* 2008-01-31 DSH RPI-803 Test repeated execution of AGO             *
* 2008-04-22 DSH RPI-833 Add string quotes for HLASM compatibility  *
*********************************************************************
*MCALL #=     1 LV= 1 TESTMAC2 SUBENTRY 
TESTMAC2 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTMAC2'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTMAC2+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
*MCALL #=     2 LV= 1          WTO   'TESTMAC2 - TEST CONDITIONAL COMPAX
               RES'
         BRAS  1,*+(WTO#0002_EOT-*+1)/2*2
         DC    AL2(WTO#0002_EOT-*,0),C'TESTMAC2 - TEST CONDITIONAL COMPX
               ARES'
WTO#0002_EOT     EQU *
         SVC   35
*MEXIT #=     2 LV= 1 WTO
         MACRO
&N       TEST  &P1
         MNOTE 'N=&N P1=&P1'
         AIF   ('&N' NE '&P1').SKIP
         MNOTE '&N EQ &P1'
         MEXIT
.SKIP    ANOP
         MNOTE '&N NE &P1'
         MEND
*MCALL #=     3 LV= 1 A        TEST  P1
         MNOTE 'N=A P1=P1'
         MNOTE 'A NE P1'
*MEXIT #=     3 LV= 1 TEST
*MCALL #=     4 LV= 1 B        TEST  P2
         MNOTE 'N=B P1=P2'
         MNOTE 'B NE P2'
*MEXIT #=     4 LV= 1 TEST
*MCALL #=     5 LV= 1 XYZ      TEST  XYZ
         MNOTE 'N=XYZ P1=XYZ'
         MNOTE 'XYZ EQ XYZ'
*MEXIT #=     5 LV= 1 TEST
         MNOTE 'OK1'
         MNOTE 'OK2'
         MNOTE 'OK3'
* TEST AGO AND AIF LABELS WITHOUT ANOP
*MCALL #=     6 LV= 1          WTO   'TESTEND I=0'
         BRAS  1,*+(WTO#0006_EOT-*+1)/2*2
         DC    AL2(WTO#0006_EOT-*,0),C'TESTEND I=0'
WTO#0006_EOT     EQU *
         SVC   35
*MEXIT #=     6 LV= 1 WTO
* TEST COMPLEX AIF
         MACRO
         TEST  &MF=I,&SF=I
         AIF   ('&MF' EQ 'L' OR('&SF' EQ 'L' AND '&MF(1)' EQ 'E')).ERR
         MNOTE 'AIF NO BRANCH OK - MF=&MF SF=&SF'
         AGO   .SKPERR
.ERR     MNOTE 12,'AIF BRANCDED TO ERR'
         SUBEXIT RC=12
.SKPERR   ANOP
         MEND
*MCALL #=     7 LV= 1          TEST 
         MNOTE 'AIF NO BRANCH OK - MF=I SF=I'
*MEXIT #=     7 LV= 1 TEST
* TEST AIFB AND AGOB
* TEST ALTERNATE AIF FORMAT COMPOUND TESTS
         MNOTE 'TOK2'
* TEST COMPUTED AGO
         MNOTE 'AGO NO BRANCH'
         MNOTE '.T11'
         MNOTE '.T12'
         MNOTE '.T13'
         MNOTE 'AGO NO BRANCH'
*MCALL #=     8 LV= 1          WTO   'TESTMAC2 ENDED OK'
         BRAS  1,*+(WTO#0008_EOT-*+1)/2*2
         DC    AL2(WTO#0008_EOT-*,0),C'TESTMAC2 ENDED OK'
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
