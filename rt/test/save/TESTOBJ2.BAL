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
* 2005-09-30  DSH          Initial version                          *
*********************************************************************
* Note: This program has 32MB CSECT requiring OBJHEX and MEM(49)    *
*       options the default binary OBJ format is limited to 24 bit  *
*       16MB CSECTS.                                                *
*       The default MEM(1) only allows loading 1MB 390 load modules *
*********************************************************************
*MCALL #=     1 LV= 1 TESTOBJ2 SUBENTRY                   CST/SD TYPE EX
               SD
TESTOBJ2 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTOBJ2'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTOBJ2+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
*MCALL #=     2 LV= 1          WTO 'TESTOBJ2 TEST OBJHEX SUPPORT FOR 32X
               MB SINGLE CSECT'
         BRAS  1,*+(WTO#0002_EOT-*+1)/2*2
         DC    AL2(WTO#0002_EOT-*,0),C'TESTOBJ2 TEST OBJHEX SUPPORT FORX
                32MB SINGLE CSECT'
WTO#0002_EOT     EQU *
         SVC   35
*MEXIT #=     2 LV= 1 WTO
*MCALL #=     3 LV= 1          CALL TESTSUB1              EXT/ER TYPE EX
               SD
*MCALL #=     4 LV= 2          ZCALL TESTSUB1,,,ID=,LINKINST=BALR,MF=I
         CNOP  0,4
         LRL    15,=V(TESTSUB1)
         BALR      14,15
*MEXIT #=     4 LV= 2 ZCALL
*MEXIT #=     3 LV= 1 CALL
         WXTRN TESTSUB2             WXT/WX TYPE ESD
         L    15,=A(TESTSUB2)
         BALR 14,15
         ENTRY MYSUB                ENT/LD TYPE ESD
         L    15,=A(MYSUB)
         BALR 14,15
*MCALL #=     5 LV= 1          WTO  'TESTOBJ2 ENDED OK'
         BRAS  1,*+(WTO#0005_EOT-*+1)/2*2
         DC    AL2(WTO#0005_EOT-*,0),C'TESTOBJ2 ENDED OK'
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
         LTORG 
         ORG  TESTOBJ2+X'2000000' FORCE MYSUB TO ENTRY + 32MB
MYSUB    EQU  *
*MCALL #=     7 LV= 1          WTO  'HELLO FROM MYSUB AT 32MB FROM ENTRX
               Y'
         BRAS  1,*+(WTO#0007_EOT-*+1)/2*2
         DC    AL2(WTO#0007_EOT-*,0),C'HELLO FROM MYSUB AT 32MB FROM ENX
               TRY'
WTO#0007_EOT     EQU *
         SVC   35
*MEXIT #=     7 LV= 1 WTO
         BR   14
         END 
