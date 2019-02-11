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
* 2006-10-06  DSH          Initial version                          *
* 2006-09-29  DSH RPI-467  Test pseudo code for SET and AIF         *
* 2006-12-22  DSH RPI-521  Test AIF undefined label ok if not taken *
* 2008-04-20  DSH RPI-833  SETC quotes for HLASM compatibility      *
* 2011-04-07  DSH RPI-1139 Move GBLA out of loop                    *
*********************************************************************
*MCALL #=     1 LV= 1 TESTPC1  SUBENTRY 
TESTPC1  CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTPC1'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTPC1+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
*MCALL #=     2 LV= 1          WTO   'TESTPC1 - TEST PSEUOD CODE FOR SEX
               T AND AIF'
         BRAS  1,*+(WTO#0002_EOT-*+1)/2*2
         DC    AL2(WTO#0002_EOT-*,0),C'TESTPC1 - TEST PSEUOD CODE FOR SX
               ET AND AIF'
WTO#0002_EOT     EQU *
         SVC   35
*MEXIT #=     2 LV= 1 WTO
         MNOTE 'STARTING PSEUDO CODE TEST PASS 1'
* TEST SETB TRUE/FALSE SET AND AIF
         MNOTE 'AIF TRUE OK'
         MNOTE 'AIF FALSE OK'
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
*MCALL #=     3 LV= 1          TEST 
         MNOTE 'AIF NO BRANCH OK - MF=I SF=I'
*MEXIT #=     3 LV= 1 TEST
* TEST AIFB AND AGOB
* TEST ALTERNATE AIF FORMAT COMPOUND TESTS
         MNOTE 'TOK2'
* TEST COMPUTED AGO
         MNOTE '.T12'
* TEST CREATED VARIABLES
* TEST OPT CONCAT
* TEST OPT ADD
* TEST PSEUDO CODE AIF FALSE WITH BAD LABEL OK
* RETURN TO START OF LOOP
         MNOTE 'STARTING PSEUDO CODE TEST PASS 2'
* TEST SETB TRUE/FALSE SET AND AIF
         MNOTE 'AIF TRUE OK'
         MNOTE 'AIF FALSE OK'
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
*MCALL #=     4 LV= 1          TEST 
         MNOTE 'AIF NO BRANCH OK - MF=I SF=I'
*MEXIT #=     4 LV= 1 TEST
* TEST AIFB AND AGOB
* TEST ALTERNATE AIF FORMAT COMPOUND TESTS
         MNOTE 'TOK2'
* TEST COMPUTED AGO
         MNOTE '.T12'
* TEST CREATED VARIABLES
* TEST OPT CONCAT
* TEST OPT ADD
* TEST PSEUDO CODE AIF FALSE WITH BAD LABEL OK
* RETURN TO START OF LOOP
*MCALL #=     5 LV= 1          WTO   'TESTPC1 - ENDED OK'
         BRAS  1,*+(WTO#0005_EOT-*+1)/2*2
         DC    AL2(WTO#0005_EOT-*,0),C'TESTPC1 - ENDED OK'
WTO#0005_EOT     EQU *
         SVC   35
*MEXIT #=     5 LV= 1 WTO
*MCALL #=     6 LV= 1          SUBEXIT 
         LA    15,0
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=     6 LV= 1 SUBEXIT
         END 
