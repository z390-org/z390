*********************************************************************
* Copyright 2007 Automated Software Tools Corporation               *
* Copyright 2013 Cat Herder Software, LLC                           *
* Copyright 2018 Joachim Bartz, Germany                             *
*                                                                   *
* This source code is part of z390 assembler/emulator package.      *
*                                                                   *
* The z390 package is distributed under GNU general public license  *
*                                                                   *
* Author - Don Higgins                                              *
*********************************************************************
* 2007-11-30  DSH         Initial version                           *
* 2007-11-30  DSH RPI-742 Test nested @FILE options using command   *
*                         RT1 RT\TEST\TESTOPT1 @TESTOPT1            *
*                         See options in TESTOPT1.OPT, TESTOPTA.OPT,*
*                         TESTOPTB.OPT                              *
* 2008-07-21  DSH RPI-877 Test nested @FILE options with all options*
*********************************************************************
*MCALL #=     1 LV= 1 TESTOPT1 SUBENTRY 
TESTOPT1 CSECT  
         STM    14,12,12(13)
         BAL    15,104(15)
         DC     18F'0'
         DC     CL8'TESTOPT1'
         DC     CL8'010205002'
         DC     CL8'223344'
         ST     15,8(13)
         ST     13,4(15)
         LR     13,15
         USING  TESTOPT1+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
*MCALL #=     2 LV= 1          WTO   'TESTOPT1 TEST NESTED @FILE OPTIONX
               S'
         BRAS   1,*+(WTO#0002_EOT-*+1)/2*2
         DC     AL2(WTO#0002_EOT-*,0),C'TESTOPT1 TEST NESTED @FILE OPTIX
               ONS'
WTO#0002_EOT EQU *
         SVC    35
*MEXIT #=     2 LV= 1 WTO
*MCALL #=     3 LV= 1          SUBEXIT 
         LA     15,0
         L      13,4(,13)
         L      14,12(,13)
         LM     2,12,28(13)
         BR     14
*MEXIT #=     3 LV= 1 SUBEXIT
         END    
