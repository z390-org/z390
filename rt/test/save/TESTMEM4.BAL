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
* 2006-11-12 DSH RPI-491 Test by Melvyn Maltz for corruption on FQE *
*                        merge                                      *
* 2007-01-22 DSH RPI-542 Correct output R1=ADDR for GETMAIN         *
*********************************************************************
*MCALL #=     1 LV= 1 TESTMEM4 SUBENTRY 
TESTMEM4 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTMEM4'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTMEM4+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
*MCALL #=     2 LV= 1          WTO   'TESTMEM4 - TEST FIX FOR RPI-491 FX
               QE MERGE ERROR'
         BRAS  1,*+(WTO#0002_EOT-*+1)/2*2
         DC    AL2(WTO#0002_EOT-*,0),C'TESTMEM4 - TEST FIX FOR RPI-491 X
               FQE MERGE ERROR'
WTO#0002_EOT     EQU *
         SVC   35
*MEXIT #=     2 LV= 1 WTO
*
* TS INST FOR INTERCEPT PURPOSES ONLY
*
CYCLE1   EQU   *
         TS    BYTE
         LA    R11,50
*MCALL #=     3 LV= 1          GETMAIN R,LV=(R11)       OP2
*MCALL #=     4 LV= 2          ZOPTLR 1,R11
         LR    1,R11
*MEXIT #=     4 LV= 2 ZOPTLR
         LA    0,B'00'
         SVC   4 GMAIN R0=(X'02'=31B,X'01'=COND),R1=LEN OUT(R0=L,R1=A)
*MEXIT #=     3 LV= 1 GETMAIN
         ST    R1,SAVE1           STORE IT              RPI-542
         LR    R3,R1              SAVE ADDRESS          RPI-542
         MVI   0(R3),X'FF'        MARK 1ST BYTE
*
         LA    R11,100            GETMAIN LENGTH
*MCALL #=     5 LV= 1          GETMAIN R,LV=(R11)       OP1
*MCALL #=     6 LV= 2          ZOPTLR 1,R11
         LR    1,R11
*MEXIT #=     6 LV= 2 ZOPTLR
         LA    0,B'00'
         SVC   4 GMAIN R0=(X'02'=31B,X'01'=COND),R1=LEN OUT(R0=L,R1=A)
*MEXIT #=     5 LV= 1 GETMAIN
         ST    R1,SAVE2           STORE IT              RPI-542
         LR    R3,R1              SAVE ADDRESS          RPI-542
         MVI   0(R3),X'FF'        MARK 1ST BYTE
*
*MCALL #=     7 LV= 1          GETMAIN R,LV=128K        MAXIMUM TRANSLAX
               TE TABLE
         L    1,=A(131072)  RPI 117
         LA    0,B'00'
         SVC   4 GMAIN R0=(X'02'=31B,X'01'=COND),R1=LEN OUT(R0=L,R1=A)
*MEXIT #=     7 LV= 1 GETMAIN
         ST    R1,SAVE3           STORE IT              RPI-542
         LR    R3,R1              SAVE ADDRESS          RPI-542
         MVI   0(R3),X'FF'        MARK 1ST BYTE
*
         TS    BYTE
*
         LA    R11,50             LENGTH TO FREEMAIN
*MCALL #=     8 LV= 1          FREEMAIN LV=(R11),A=SAVE1 FREE OP2
*MCALL #=     9 LV= 2          ZOPTLR 0,R11
         LR    0,R11
*MEXIT #=     9 LV= 2 ZOPTLR
         L    1,SAVE1
         SVC   5 FREEMAIN R0=LEN, R1=ADDR
*MEXIT #=     8 LV= 1 FREEMAIN
         LA    R11,100            LENGTH TO FREEMAIN
*MCALL #=    10 LV= 1          FREEMAIN LV=(R11),A=SAVE2 FREE OP1
*MCALL #=    11 LV= 2          ZOPTLR 0,R11
         LR    0,R11
*MEXIT #=    11 LV= 2 ZOPTLR
         L    1,SAVE2
         SVC   5 FREEMAIN R0=LEN, R1=ADDR
*MEXIT #=    10 LV= 1 FREEMAIN
*MCALL #=    12 LV= 1          FREEMAIN LV=128K,A=SAVE3 FREE TRANSLATE X
               TABLE
         L    0,=A(131072)  RPI 117
         L    1,SAVE3
         SVC   5 FREEMAIN R0=LEN, R1=ADDR
*MEXIT #=    12 LV= 1 FREEMAIN
         TS    BYTE
CYCLE2   EQU   *
         TS    BYTE
         LA    R11,50
*MCALL #=    13 LV= 1          GETMAIN R,LV=(R11)       OP2
*MCALL #=    14 LV= 2          ZOPTLR 1,R11
         LR    1,R11
*MEXIT #=    14 LV= 2 ZOPTLR
         LA    0,B'00'
         SVC   4 GMAIN R0=(X'02'=31B,X'01'=COND),R1=LEN OUT(R0=L,R1=A)
*MEXIT #=    13 LV= 1 GETMAIN
         CL    R1,SAVE1           STORE IT                RPI-542
         BNE   ERROR
         LR    R3,R1              SAVE ADDRESS            RPI-542
         MVI   0(R3),X'FF'        MARK 1ST BYTE
*
         LA    R11,100            GETMAIN LENGTH
*MCALL #=    15 LV= 1          GETMAIN R,LV=(R11)       OP1
*MCALL #=    16 LV= 2          ZOPTLR 1,R11
         LR    1,R11
*MEXIT #=    16 LV= 2 ZOPTLR
         LA    0,B'00'
         SVC   4 GMAIN R0=(X'02'=31B,X'01'=COND),R1=LEN OUT(R0=L,R1=A)
*MEXIT #=    15 LV= 1 GETMAIN
         CL    R1,SAVE2           STORE IT                RPI-542
         BNE   ERROR
         LR    R3,R1              SAVE ADDRESS            RPI-542
         MVI   0(R3),X'FF'        MARK 1ST BYTE
*
*MCALL #=    17 LV= 1          GETMAIN R,LV=128K        MAXIMUM TRANSLAX
               TE TABLE
         L    1,=A(131072)  RPI 117
         LA    0,B'00'
         SVC   4 GMAIN R0=(X'02'=31B,X'01'=COND),R1=LEN OUT(R0=L,R1=A)
*MEXIT #=    17 LV= 1 GETMAIN
         CL    R1,SAVE3           STORE IT                RPI-542
         BNE   ERROR
         LR    R3,R1              SAVE ADDRESS            RPI-542
         MVI   0(R3),X'FF'        MARK 1ST BYTE
*
         TS    BYTE
*
         LA    R11,50             LENGTH TO FREEMAIN
*MCALL #=    18 LV= 1          FREEMAIN LV=(R11),A=SAVE1 FREE OP2
*MCALL #=    19 LV= 2          ZOPTLR 0,R11
         LR    0,R11
*MEXIT #=    19 LV= 2 ZOPTLR
         L    1,SAVE1
         SVC   5 FREEMAIN R0=LEN, R1=ADDR
*MEXIT #=    18 LV= 1 FREEMAIN
         LA    R11,100            LENGTH TO FREEMAIN
*MCALL #=    20 LV= 1          FREEMAIN LV=(R11),A=SAVE2 FREE OP1
*MCALL #=    21 LV= 2          ZOPTLR 0,R11
         LR    0,R11
*MEXIT #=    21 LV= 2 ZOPTLR
         L    1,SAVE2
         SVC   5 FREEMAIN R0=LEN, R1=ADDR
*MEXIT #=    20 LV= 1 FREEMAIN
*MCALL #=    22 LV= 1          FREEMAIN LV=128K,A=SAVE3 FREE TRANSLATE X
               TABLE
         L    0,=A(131072)  RPI 117
         L    1,SAVE3
         SVC   5 FREEMAIN R0=LEN, R1=ADDR
*MEXIT #=    22 LV= 1 FREEMAIN
         TS    BYTE
*
*MCALL #=    23 LV= 1          WTO   'TESTMEM4 ENDED OK'
         BRAS  1,*+(WTO#0023_EOT-*+1)/2*2
         DC    AL2(WTO#0023_EOT-*,0),C'TESTMEM4 ENDED OK'
WTO#0023_EOT     EQU *
         SVC   35
*MEXIT #=    23 LV= 1 WTO
*MCALL #=    24 LV= 1          SUBEXIT 
         LA    15,0
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=    24 LV= 1 SUBEXIT
*MCALL #=    25 LV= 1 ERROR    ABEND  111,DUMP
ERROR    DS    0H
         LA   1,111
         OILH 1,X'8000'
         SVC  13 ABEND R1=COMP CODE AND HIGH BIT = DUMP PGM STORAGE
*MEXIT #=    25 LV= 1 ABEND
*
SAVE1    DS    A
SAVE2    DS    A
SAVE3    DS    A
BYTE     DS    C
         LTORG 
*
*MCALL #=    26 LV= 1          EQUREGS REGS=GPR
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
*MEXIT #=    26 LV= 1 EQUREGS
         END 
