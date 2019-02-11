*********************************************************************
* Copyright 2009 Automated Software Tools Corporation               *
* Copyright 2013 Cat Herder Software, LLC                           *
* Copyright 2018 Joachim Bartz, Germany                             *
*                                                                   *
* This source code is part of z390 assembler/emulator package.      *
*                                                                   *
* The z390 package is distributed under GNU general public license  *
*                                                                   *
* Author - Don Higgins                                              *
*********************************************************************
* 2009-09-16  DSH          Initial version                          *
* 2009-09-16  DSH RPI-1083 Test AINSERT complex macro and copy      *
*                          sequence                                 *
*********************************************************************
* MAINTENANCE                                                       *
*********************************************************************
         MACRO
         STACK
         AINSERT 'L1 GEN',BACK
         AINSERT 'L2 GEN',BACK
         AINSERT 'L3 GEN',BACK
         MEND
         MACRO
&LAB     GEN  &TYPE
         MNOTE '&LAB GEN &TYPE STARTED'
         GBLB &(COPY_&LAB)
 AIF (NOT(NOT &(COPY_&LAB))).AIF_1_1
              MNOTE 'GEN INSERTING &LAB GEN'
              AINSERT '&LAB GEN',FRONT
              MNOTE 'GEN INSERTING COPY &LAB'
              AINSERT ' COPY &LAB',FRONT
&(COPY_&LAB) SETB 1
 AGO .AIF_1_E
.AIF_1_1 ANOP
              MNOTE 'GEN PUNCH &LAB'
.AIF_1_E ANOP
         MNOTE '&LAB GEN &TYPE ENDED'
         MEND
*MCALL #=     1 LV= 1 TESTAIN3 SUBENTRY 
TESTAIN3 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTAIN3'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTAIN3+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
*MCALL #=     2 LV= 1          WTO  'TESTAIN3 STARTED'
         BRAS  1,*+(WTO#0002_EOT-*+1)/2*2
         DC    AL2(WTO#0002_EOT-*,0),C'TESTAIN3 STARTED'
WTO#0002_EOT     EQU *
         SVC   35
*MEXIT #=     2 LV= 1 WTO
*MCALL #=     3 LV= 1          STACK 
*MEXIT #=     3 LV= 1 STACK
*MCALL #=     4 LV= 1 L1 GEN 
         MNOTE 'L1 GEN  STARTED'
         MNOTE 'GEN INSERTING L1 GEN'
         MNOTE 'GEN INSERTING COPY L1'
         MNOTE 'L1 GEN  ENDED'
*MEXIT #=     4 LV= 1 GEN
 COPY L1
         MNOTE 'L1 COPY 1 OF 3'
         MNOTE 'L1 COPY 2 OF 3'
         MNOTE 'L1 COPY 3 OF 3'
*MCALL #=     5 LV= 1 L1 GEN 
         MNOTE 'L1 GEN  STARTED'
         MNOTE 'GEN PUNCH L1'
         MNOTE 'L1 GEN  ENDED'
*MEXIT #=     5 LV= 1 GEN
*MCALL #=     6 LV= 1 L2 GEN 
         MNOTE 'L2 GEN  STARTED'
         MNOTE 'GEN INSERTING L2 GEN'
         MNOTE 'GEN INSERTING COPY L2'
         MNOTE 'L2 GEN  ENDED'
*MEXIT #=     6 LV= 1 GEN
 COPY L2
         MNOTE 'L2 COPY 1 OF 3'
         MNOTE 'L2 COPY 2 OF 3'
         MNOTE 'L2 COPY 3 OF 3'
*MCALL #=     7 LV= 1 L2 GEN 
         MNOTE 'L2 GEN  STARTED'
         MNOTE 'GEN PUNCH L2'
         MNOTE 'L2 GEN  ENDED'
*MEXIT #=     7 LV= 1 GEN
*MCALL #=     8 LV= 1 L3 GEN 
         MNOTE 'L3 GEN  STARTED'
         MNOTE 'GEN INSERTING L3 GEN'
         MNOTE 'GEN INSERTING COPY L3'
         MNOTE 'L3 GEN  ENDED'
*MEXIT #=     8 LV= 1 GEN
 COPY L3
         MNOTE 'L3 COPY 1 OF 3'
         MNOTE 'L3 COPY 2 OF 3'
         MNOTE 'L3 COPY 3 OF 3'
*MCALL #=     9 LV= 1 L3 GEN 
         MNOTE 'L3 GEN  STARTED'
         MNOTE 'GEN PUNCH L3'
         MNOTE 'L3 GEN  ENDED'
*MEXIT #=     9 LV= 1 GEN
*MCALL #=    10 LV= 1          WTO   'TESTAIN3 ENDED'
         BRAS  1,*+(WTO#0010_EOT-*+1)/2*2
         DC    AL2(WTO#0010_EOT-*,0),C'TESTAIN3 ENDED'
WTO#0010_EOT     EQU *
         SVC   35
*MEXIT #=    10 LV= 1 WTO
*MCALL #=    11 LV= 1          SUBEXIT 
         LA    15,0
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=    11 LV= 1 SUBEXIT
         END 
