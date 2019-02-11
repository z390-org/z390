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
* 2006-01-12 DSH RPI-151 Test new user option for first level SVC   *
*                        handler                                    *
*********************************************************************
*MCALL #=     1 LV= 1 TESTSVC1 SUBENTRY 
TESTSVC1 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTSVC1'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTSVC1+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
         LA    R1,MY_SVC_HANDLER
         ST    R1,SVC_NEW+4       SET NEW SVC PSW ADDR
         MVI   SVC_NEW,X'FF'      SET NEW SVC PSW MASK TO ENABLE
         LA    R1,WTOMSG1         SET R1 T0 WTO MSG 1
         SVC   201                ISSUE USER SVC 201 FOR HANDLER
         LA    R1,WTOMSG2         SET R1 TO WTO MSG 2
         SVC   201                ISSUE USER SVC 201 FOR HANDLER
*MCALL #=     2 LV= 1          SUBEXIT 
         LA    15,0
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=     2 LV= 1 SUBEXIT
*MCALL #=     3 LV= 1 WTOMSG1  WTO   'HELLO FROM SVC 201 MSG 1',MF=L
WTOMSG1  DS    0H
         DC    AL2(WTO#0003_EOT-*,0),C'HELLO FROM SVC 201 MSG 1'
WTO#0003_EOT     EQU *
*MEXIT #=     3 LV= 1 WTO
*MCALL #=     4 LV= 1 WTOMSG2  WTO   'HELLO FROM SVC 201 MSG 2',MF=L
WTOMSG2  DS    0H
         DC    AL2(WTO#0004_EOT-*,0),C'HELLO FROM SVC 201 MSG 2'
WTO#0004_EOT     EQU *
*MEXIT #=     4 LV= 1 WTO
MY_SVC_HANDLER DS 0H
         DROP 
         MVI   SVC_NEW,X'00' TURN OFF SVC HANDLER TO ISSUE NATIVE SVC
         CLI   SVC_OLD+3,201
         JNE   MY_SVC_HANDLER_CHK3
         SVC   35
         J     MY_SVC_HANDLER_EXIT
MY_SVC_HANDLER_CHK3  CLI   SVC_OLD+3,3
         JNE   MY_SVC_HANDLER_ERROR
         SVC   3        EXITING PGM VIA NATIVE SVC 3
MY_SVC_HANDLER_ERROR EQU *
*MCALL #=     5 LV= 1          WTO   'UNKNOWN SVC - ABORTING'
         BRAS  1,*+(WTO#0005_EOT-*+1)/2*2
         DC    AL2(WTO#0005_EOT-*,0),C'UNKNOWN SVC - ABORTING'
WTO#0005_EOT     EQU *
         SVC   35
*MEXIT #=     5 LV= 1 WTO
*MCALL #=     6 LV= 1          ABEND 111,DUMP
         LA   1,111
         OILH 1,X'8000'
         SVC  13 ABEND R1=COMP CODE AND HIGH BIT = DUMP PGM STORAGE
*MEXIT #=     6 LV= 1 ABEND
MY_SVC_HANDLER_EXIT EQU *
         MVI   SVC_NEW,X'FF' TURN OFF SVC HANDLER BACK ON
         LPSW  SVC_OLD
*MCALL #=     7 LV= 1          EQUREGS 
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
*MEXIT #=     7 LV= 1 EQUREGS
SVC_OLD  EQU   X'20'
SVC_NEW  EQU   X'60'
         END 
