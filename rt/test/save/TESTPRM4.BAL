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
* 2006-02-08 DSH RPI-198 Test PARM(...) using SYSPARM(...) to       *
*                        compare                                    *
* 2006-04-07 DSH RPI-582 Correct LR to L to fetch address of        *
*                        parameter                                  *
* 2008-04-22 DSH RPI-833 Add string quotes for HLASM compatibility  *
*********************************************************************
*MCALL #=     1 LV= 1 TESTPRM4 SUBENTRY 
TESTPRM4 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTPRM4'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTPRM4+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
         L     R4,0(R1)  SAVE PARM ADDR RPI 582
*MCALL #=     2 LV= 1          WTO   'TESTPRM4 TEST PARM(a, b) MAPPED TX
               O JCL EXEC PARM=a, b'
         BRAS  1,*+(WTO#0002_EOT-*+1)/2*2
         DC    AL2(WTO#0002_EOT-*,0),C'TESTPRM4 TEST PARM(a, b) MAPPED X
               TO JCL EXEC PARM=a, b'
WTO#0002_EOT     EQU *
         SVC   35
*MEXIT #=     2 LV= 1 WTO
         CLC   0(2,R4),=H'4'
         BNE   1
         CLC   2(4,R4),=C'a, b'
         BNE   1
*MCALL #=     3 LV= 1          WTO   'TESTPRM4 ENDED OK'
         BRAS  1,*+(WTO#0003_EOT-*+1)/2*2
         DC    AL2(WTO#0003_EOT-*,0),C'TESTPRM4 ENDED OK'
WTO#0003_EOT     EQU *
         SVC   35
*MEXIT #=     3 LV= 1 WTO
*MCALL #=     4 LV= 1          SUBEXIT 
         LA    15,0
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=     4 LV= 1 SUBEXIT
*MCALL #=     5 LV= 1          EQUREGS 
R0     EQU 0
R1     EQU 1
R2     EQU 2
R3     EQU 3
R4     EQU 4
R5     EQU 5
R6     EQU 6
R7     EQU 7
R8     EQU 8
R9     EQU 9
R10    EQU 10
R11    EQU 11
R12    EQU 12
R13    EQU 13
R14    EQU 14
R15    EQU 15
*MEXIT #=     5 LV= 1 EQUREGS
         END 
