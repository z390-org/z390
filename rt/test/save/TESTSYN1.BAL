*********************************************************************
* Copyright 2005 Automated Software Tools Corporation               *
* This source code is part of z390 assembler/emulator package       *
* The z390 package is distributed under GNU general public license  *
* Author - Don Higgins                                              *
* Date   - 09/30/05                                                 *
*********************************************************************
* 2006-04-07 RPI-274 Test variable substitution on OPSYN            *
*********************************************************************
*MCALL #=     1 LV= 1 TESTSYN1 SUBENTRY 
TESTSYN1 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTSYN1'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTSYN1+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
*MCALL #=     2 LV= 1          WTO   'TESTSYN1 STARTED'
         BRAS  1,*+(WTO#0002_EOT-*+1)/2*2
         DC    AL2(WTO#0002_EOT-*,0),C'TESTSYN1 STARTED'
WTO#0002_EOT     EQU *
         SVC   35
*MEXIT #=     2 LV= 1 WTO
* REPLACE LR X'18' WITH SR X'1B'
LR       LR    1,2
LR       OPSYN SR
SR       LR    1,2
         CLI   LR,X'18'
         BNE   ERR
         CLI   SR,X'1B'
         BNE   ERR
* CREATE NEW OPCODE SUBR = SR
SUBR     OPSYN SR
SUBR     SUBR  1,2
         CLI   SUBR,X'1B'
         BNE   ERR
         MACRO
         NEWOP &OLD,&NEW
&NEW     OPSYN &OLD
&OLD     OPSYN ,
         MEND
*MCALL #=     3 LV= 1          NEWOP AR,ADDREG
ADDREG     OPSYN AR
AR     OPSYN ,
*MEXIT #=     3 LV= 1 NEWOP
         ADDREG 1,2
         LR     3,4
*MCALL #=     4 LV= 1          WTO   'TESTSYN1 ENDED OK'
         BRAS  1,*+(WTO#0004_EOT-*+1)/2*2
         DC    AL2(WTO#0004_EOT-*,0),C'TESTSYN1 ENDED OK'
WTO#0004_EOT     EQU *
         SVC   35
*MEXIT #=     4 LV= 1 WTO
*MCALL #=     5 LV= 1          SUBEXIT 
         LA    15,0
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=     5 LV= 1 SUBEXIT
*MCALL #=     6 LV= 1 ERR      ABEND 111,DUMP
ERR      DS    0H
         LA   1,111
         OILH 1,X'8000'
         SVC  13 ABEND R1=COMP CODE AND HIGH BIT = DUMP PGM STORAGE
*MEXIT #=     6 LV= 1 ABEND
         END 
