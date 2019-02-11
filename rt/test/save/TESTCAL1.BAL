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
* 2006-11-10 DSH RPI-473 Correct call macro bugs and test options   *
*********************************************************************
*MCALL #=     1 LV= 1 TESTCAL1 SUBENTRY 
TESTCAL1 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTCAL1'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTCAL1+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
*MCALL #=     2 LV= 1          WTO   'TESTCAL1 TEST LOCAL STATIC LINKEDX
                CALL WITH PARMS'
         BRAS  1,*+(WTO#0002_EOT-*+1)/2*2
         DC    AL2(WTO#0002_EOT-*,0),C'TESTCAL1 TEST LOCAL STATIC LINKEX
               D CALL WITH PARMS'
WTO#0002_EOT     EQU *
         SVC   35
*MEXIT #=     2 LV= 1 WTO
*MCALL #=     3 LV= 1          CALL  MYSUB,(PARM1),VL
*MCALL #=     4 LV= 2          ZCALL MYSUB,(PARM1),VL,ID=,LINKINST=BALRX
               ,MF=I
         CNOP  0,4
         BRAS   1,*+4+1*4
         DC     A(PARM1)
         OI     0(1),X'80'
         LRL    15,=V(MYSUB)
         BALR      14,15
*MEXIT #=     4 LV= 2 ZCALL
*MEXIT #=     3 LV= 1 CALL
*MCALL #=     5 LV= 1          CALL  MYSUB,(PARM1,PARM2),VL
*MCALL #=     6 LV= 2          ZCALL MYSUB,(PARM1,PARM2),VL,ID=,LINKINSX
               T=BALR,MF=I
         CNOP  0,4
         BRAS   1,*+4+2*4
         DC     A(PARM1,PARM2)
         OI     4(1),X'80'
         LRL    15,=V(MYSUB)
         BALR      14,15
*MEXIT #=     6 LV= 2 ZCALL
*MEXIT #=     5 LV= 1 CALL
         LA    R4,PARM2
*MCALL #=     7 LV= 1          CALL  MYSUB,(PARM1,(R4)),VL,MF=(E,LIST)
*MCALL #=     8 LV= 2          ZCALL MYSUB,(PARM1,(R4)),VL,ID=,LINKINSTX
               =BALR,MF=(E,LIST)
         CNOP  0,4
         LA     1,LIST
         LA     0,PARM1
         ST     0,0(1)
         ST     (R4),4(1)   RPI 473
         OI     8-4(1),X'80'
         LRL    15,=V(MYSUB)
         BALR      14,15
*MEXIT #=     8 LV= 2 ZCALL
*MEXIT #=     7 LV= 1 CALL
*MCALL #=     9 LV= 1          CALL  MYSUB,MF=(E,LIST)
*MCALL #=    10 LV= 2          ZCALL MYSUB,,,ID=,LINKINST=BALR,MF=(E,LIX
               ST)
         CNOP  0,4
         LA     1,LIST
         LRL    15,=V(MYSUB)
         BALR      14,15
*MEXIT #=    10 LV= 2 ZCALL
*MEXIT #=     9 LV= 1 CALL
*MCALL #=    11 LV= 1          WTO  'TESTCAL1 ENDED OK'
         BRAS  1,*+(WTO#0011_EOT-*+1)/2*2
         DC    AL2(WTO#0011_EOT-*,0),C'TESTCAL1 ENDED OK'
WTO#0011_EOT     EQU *
         SVC   35
*MEXIT #=    11 LV= 1 WTO
*MCALL #=    12 LV= 1          SUBEXIT 
         LA    15,0
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=    12 LV= 1 SUBEXIT
PARM1    DC   CL20'PARM1 MSG'
PARM2    DC   CL20'PARM2 MSG'
*MCALL #=    13 LV= 1 LIST     CALL  ,(PARM1,PARM2),VL,MF=L
*MCALL #=    14 LV= 2 LIST     ZCALL ,(PARM1,PARM2),VL,ID=,LINKINST=BALX
               R,MF=L
         CNOP  0,4
LIST     DS    0F
         DC    A(PARM1)
         DC    A(PARM2+X'80000000')
*MEXIT #=    14 LV= 2 ZCALL
*MEXIT #=    13 LV= 1 CALL
*MCALL #=    15 LV= 1 MYSUB    SUBENTRY 
MYSUB    CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'MYSUB'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING MYSUB+8,13
*MEXIT #=    15 LV= 1 SUBENTRY
         LR   R2,R1
LOOP     EQU  *
         L    R3,0(R2)
         MVC  DMSG,0(R3)
*MCALL #=    16 LV= 1          WTO  MF=(E,WTOMSG)
         LA    1,WTOMSG
         SVC   35
*MEXIT #=    16 LV= 1 WTO
         AHI  R2,4
         LTR  R3,R3
         BP   LOOP
*MCALL #=    17 LV= 1          SUBEXIT 
         LA    15,0
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=    17 LV= 1 SUBEXIT
WTOMSG   DC   AL2(WTOEND-*,0)
         DC   C'PARM='
DMSG     DC   CL20' '
WTOEND   EQU  *
*MCALL #=    18 LV= 1          EQUREGS 
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
*MEXIT #=    18 LV= 1 EQUREGS
         END 
