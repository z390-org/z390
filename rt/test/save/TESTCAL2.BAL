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
* 2005-09-30 DSH          Initial version                           *
* 2006-06-16 DSH RPI-322  Add test for call MF=L                    *
* 2009-06-30 DSH RPI-1044 Make MYENT an entry replacing V(MYENT)    *
*********************************************************************
*MCALL #=     1 LV= 1 TESTCAL2 SUBENTRY 
TESTCAL2 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTCAL2'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTCAL2+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
*MCALL #=     2 LV= 1          WTO 'TESTCAL2 TEST STATIC LINK CALLS WITX
               H EXTRN AND ENTRY'
         BRAS  1,*+(WTO#0002_EOT-*+1)/2*2
         DC    AL2(WTO#0002_EOT-*,0),C'TESTCAL2 TEST STATIC LINK CALLS X
               WITH EXTRN AND ENTRY'
WTO#0002_EOT     EQU *
         SVC   35
*MEXIT #=     2 LV= 1 WTO
*MCALL #=     3 LV= 1          CALL MYSUB,(PARM1),VL         TEST CVT EX
               XTRN TO CSECT
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
*MCALL #=     5 LV= 1          CALL MYENT,(PARM1,PARM2),VL   TEST CVT EX
               XTRN TO LOCAL LABEL
*MCALL #=     6 LV= 2          ZCALL MYENT,(PARM1,PARM2),VL,ID=,LINKINSX
               T=BALR,MF=I
         CNOP  0,4
         BRAS   1,*+4+2*4
         DC     A(PARM1,PARM2)
         OI     4(1),X'80'
         LRL    15,=V(MYENT)
         BALR      14,15
*MEXIT #=     6 LV= 2 ZCALL
*MEXIT #=     5 LV= 1 CALL
         LA   R1,MYLIST
*MCALL #=     7 LV= 1          CALL MYENT
*MCALL #=     8 LV= 2          ZCALL MYENT,,,ID=,LINKINST=BALR,MF=I
         CNOP  0,4
         LRL    15,=V(MYENT)
         BALR      14,15
*MEXIT #=     8 LV= 2 ZCALL
*MEXIT #=     7 LV= 1 CALL
*MCALL #=     9 LV= 1          WTO  'TESTCAL2 ENDED OK'
         BRAS  1,*+(WTO#0009_EOT-*+1)/2*2
         DC    AL2(WTO#0009_EOT-*,0),C'TESTCAL2 ENDED OK'
WTO#0009_EOT     EQU *
         SVC   35
*MEXIT #=     9 LV= 1 WTO
*MCALL #=    10 LV= 1          SUBEXIT 
         LA    15,0
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=    10 LV= 1 SUBEXIT
*MCALL #=    11 LV= 1 MYLIST   CALL ,(PARM1,PARM2),VL,MF=L
*MCALL #=    12 LV= 2 MYLIST   ZCALL ,(PARM1,PARM2),VL,ID=,LINKINST=BALX
               R,MF=L
         CNOP  0,4
MYLIST   DS    0F
         DC    A(PARM1)
         DC    A(PARM2+X'80000000')
*MEXIT #=    12 LV= 2 ZCALL
*MEXIT #=    11 LV= 1 CALL
PARM1    DC   CL20'PARM1 MSG'
PARM2    DC   CL20'PARM2 MSG'
*MCALL #=    13 LV= 1 MYSUB    SUBENTRY 
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
*MEXIT #=    13 LV= 1 SUBENTRY
MYENT    EQU  MYSUB
         ENTRY MYENT  RPI-1044
         LR   R2,R1
LOOP     EQU  *
         L    R3,0(R2)
         MVC  DMSG,0(R3)
*MCALL #=    14 LV= 1          WTO  MF=(E,WTOMSG)
         LA    1,WTOMSG
         SVC   35
*MEXIT #=    14 LV= 1 WTO
         AHI  R2,4
         LTR  R3,R3
         BP   LOOP
*MCALL #=    15 LV= 1          SUBEXIT 
         LA    15,0
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=    15 LV= 1 SUBEXIT
WTOMSG   DC   AL2(WTOEND-*,0)
         DC   C'PARM='
DMSG     DC   CL20' '
WTOEND   EQU  *
*MCALL #=    16 LV= 1          EQUREGS 
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
*MEXIT #=    16 LV= 1 EQUREGS
         END 
