*********************************************************************
* Copyright 2006 Automated Software Tools Corporation               *
* Copyright 2013 Cat Herder Software, LLC                           *
* Copyright 2018 Joachim Bartz, Germany                             *
*                                                                   *
* This source code is part of z390 assembler/emulator package.      *
*                                                                   *
* The z390 package is distributed under GNU general public license  *
*                                                                   *
* Author - Don Higgins                                              *
*********************************************************************
* 2006-07-10 DSH         Initial version                            *
* 2006-11-10 DSH RPI-477 Add ASCII support to CTD and CFD,          *
*                        use IN=,OUT=                               *
* 2006-11-29 DSH RPI-507 Add IN=REG support in addition to          *
*                        IN=(REG ADDR)                              *
* 2006-12-03 DSH RPI-513 Add RC tests and fix display field         *
*                        length = 45                                *
*********************************************************************
*MCALL #=     1 LV= 1 TESTCTD1 SUBENTRY 
TESTCTD1 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTCTD1'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTCTD1+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
*MCALL #=     2 LV= 1          WTO   'TEST CTD CONVERT TO DISPLAY MACROX
                AND SVC 170 SERVICE'
         BRAS  1,*+(WTO#0002_EOT-*+1)/2*2
         DC    AL2(WTO#0002_EOT-*,0),C'TEST CTD CONVERT TO DISPLAY MACRX
               O AND SVC 170 SERVICE'
WTO#0002_EOT     EQU *
         SVC   35
*MEXIT #=     2 LV= 1 WTO
*MCALL #=     3 LV= 1          WTO   'USING IN=RX FIELDS'
         BRAS  1,*+(WTO#0003_EOT-*+1)/2*2
         DC    AL2(WTO#0003_EOT-*,0),C'USING IN=RX FIELDS'
WTO#0003_EOT     EQU *
         SVC   35
*MEXIT #=     3 LV= 1 WTO
         MVC   DTYPE,=CL20'128 BIT INTEGER'
*MCALL #=     4 LV= 1          CTD   CTD_INT128,IN=INT128,OUT=D45
CTD_INT128 EQU 1 CONVERT 128 BIT INT TO 45 BYTE EBCDIC DECIMAL
CTD_EH   EQU   2 CONVERT HFP SHORT EH TO 45 BYTE EBCDIC N.N( 6)+ENNNN
CTD_EB   EQU   3 CONVERT BFP SHORT EB TO 45 BYTE EBCDIC N.N( 7)+ENNNN
CTD_DH   EQU   4 CONVERT HFP LONG  DH TO 45 BYTE EBCDIC N.N(14)+ENNNN
CTD_DB   EQU   5 CONVERT BFP LONG  DB TO 45 BYTE EBCDIC N.N(15)+ENNNN
CTD_LH   EQU   6 CONVERT HFP EXT.  LH TO 45 BYTE EBCDIC N.N(34)+ENNNN
CTD_LB   EQU   7 CONVERT BFP EXT.  LB TO 45 BYTE EBCDIC N.N(34)+ENNNN
CTD_DD   EQU   8 CONVERT DFP LONG  DD TO 45 BYTE EBCDIC N.N(16)+ENNNN
CTD_ED   EQU   9 CONVERT DFP SHORT ED TO 45 BYTE EBCDIC N.N( 7)+ENNNN
CTD_LD   EQU  10 CONVERT DFP EXT.  LD TO 45 BYTE EBCDIC N.N(34)+ENNNN
         LA    1,=A(CTD_INT128,INT128,D45)
         SVC   170 CTD R1=A(TYPE,IN,OUT)
*MEXIT #=     4 LV= 1 CTD
         LTR   R15,R15
         BNZ   ABORT
*MCALL #=     5 LV= 1          WTO   MF=(E,WTOMSG)
         LA    1,WTOMSG
         SVC   35
*MEXIT #=     5 LV= 1 WTO
         SQE   F0,EH_2
         STE   F0,EH_SQRT2
*MCALL #=     6 LV= 1          CTD   CTD_EH,IN=EH_SQRT2,OUT=D45
         LA    1,=A(CTD_EH,EH_SQRT2,D45)
         SVC   170 CTD R1=A(TYPE,IN,OUT)
*MEXIT #=     6 LV= 1 CTD
         LTR   R15,R15
         BNZ   ABORT
         MVC   DTYPE,=CL20'EH SQRT 2'
*MCALL #=     7 LV= 1          WTO   MF=(E,WTOMSG)
         LA    1,WTOMSG
         SVC   35
*MEXIT #=     7 LV= 1 WTO
         SQEB  F0,EB_2
         STE   F0,EB_SQRT2
*MCALL #=     8 LV= 1          CTD   CTD_EB,IN=EB_SQRT2,OUT=D45
         LA    1,=A(CTD_EB,EB_SQRT2,D45)
         SVC   170 CTD R1=A(TYPE,IN,OUT)
*MEXIT #=     8 LV= 1 CTD
         LTR   R15,R15
         BNZ   ABORT
         MVC   DTYPE,=CL20'EB SQRT 2'
*MCALL #=     9 LV= 1          WTO   MF=(E,WTOMSG)
         LA    1,WTOMSG
         SVC   35
*MEXIT #=     9 LV= 1 WTO
         SQD   F0,DH_2
         STD   F0,DH_SQRT2
*MCALL #=    10 LV= 1          CTD   CTD_DH,IN=DH_SQRT2,OUT=D45
         LA    1,=A(CTD_DH,DH_SQRT2,D45)
         SVC   170 CTD R1=A(TYPE,IN,OUT)
*MEXIT #=    10 LV= 1 CTD
         LTR   R15,R15
         BNZ   ABORT
         MVC   DTYPE,=CL20'DH SQRT 2'
*MCALL #=    11 LV= 1          WTO   MF=(E,WTOMSG)
         LA    1,WTOMSG
         SVC   35
*MEXIT #=    11 LV= 1 WTO
         SQDB  F0,DB_2
         STD   F0,DB_SQRT2
*MCALL #=    12 LV= 1          CTD   CTD_DB,IN=DB_SQRT2,OUT=D45
         LA    1,=A(CTD_DB,DB_SQRT2,D45)
         SVC   170 CTD R1=A(TYPE,IN,OUT)
*MEXIT #=    12 LV= 1 CTD
         LTR   R15,R15
         BNZ   ABORT
         MVC   DTYPE,=CL20'DB SQRT 2'
*MCALL #=    13 LV= 1          WTO   MF=(E,WTOMSG)
         LA    1,WTOMSG
         SVC   35
*MEXIT #=    13 LV= 1 WTO
         LD    F1,LH_2
         LD    F3,LH_2+8
         SQXR  F0,F1
         STD   F0,LH_SQRT2
         STD   F2,LH_SQRT2+8
*MCALL #=    14 LV= 1          CTD   CTD_LH,IN=LH_SQRT2,OUT=D45
         LA    1,=A(CTD_LH,LH_SQRT2,D45)
         SVC   170 CTD R1=A(TYPE,IN,OUT)
*MEXIT #=    14 LV= 1 CTD
         LTR   R15,R15
         BNZ   ABORT
         MVC   DTYPE,=CL20'LH SQRT 2'
*MCALL #=    15 LV= 1          WTO   MF=(E,WTOMSG)
         LA    1,WTOMSG
         SVC   35
*MEXIT #=    15 LV= 1 WTO
         LD    F1,LB_2
         LD    F3,LB_2+8
         SQXBR F0,F1
         STD   F0,LB_SQRT2
         STD   F2,LB_SQRT2+8
*MCALL #=    16 LV= 1          CTD   CTD_LB,IN=LB_SQRT2,OUT=D45
         LA    1,=A(CTD_LB,LB_SQRT2,D45)
         SVC   170 CTD R1=A(TYPE,IN,OUT)
*MEXIT #=    16 LV= 1 CTD
         LTR   R15,R15
         BNZ   ABORT
         MVC   DTYPE,=CL20'LB SQRT 2'
*MCALL #=    17 LV= 1          WTO   MF=(E,WTOMSG)
         LA    1,WTOMSG
         SVC   35
*MEXIT #=    17 LV= 1 WTO
*MCALL #=    18 LV= 1          WTO   'USING IN=(REG) ADDR RX FIELDS'
         BRAS  1,*+(WTO#0018_EOT-*+1)/2*2
         DC    AL2(WTO#0018_EOT-*,0),C'USING IN=(REG) ADDR RX FIELDS'
WTO#0018_EOT     EQU *
         SVC   35
*MEXIT #=    18 LV= 1 WTO
         MVC   DTYPE,=CL20'128 BIT INTEGER'
         LA    R2,INT128
         LA    R4,D45
*MCALL #=    19 LV= 1          CTD   CTD_INT128,IN=(R2),OUT=(R4)
         LA    1,=A(CTD_INT128,(R2),(R4))
         ST    R2,4(1)
         ST    R4,8(1)
         SVC   170 CTD R1=A(TYPE,IN,OUT)
*MEXIT #=    19 LV= 1 CTD
         LTR   R15,R15
         BNZ   ABORT
*MCALL #=    20 LV= 1          WTO   MF=(E,WTOMSG)
         LA    1,WTOMSG
         SVC   35
*MEXIT #=    20 LV= 1 WTO
         SQE   F0,EH_2
         STE   F0,EH_SQRT2
         LA    R2,EH_SQRT2
*MCALL #=    21 LV= 1          CTD   CTD_EH,IN=(R2),OUT=(R4)
         LA    1,=A(CTD_EH,(R2),(R4))
         ST    R2,4(1)
         ST    R4,8(1)
         SVC   170 CTD R1=A(TYPE,IN,OUT)
*MEXIT #=    21 LV= 1 CTD
         LTR   R15,R15
         BNZ   ABORT
         MVC   DTYPE,=CL20'EH SQRT 2'
*MCALL #=    22 LV= 1          WTO   MF=(E,WTOMSG)
         LA    1,WTOMSG
         SVC   35
*MEXIT #=    22 LV= 1 WTO
         SQEB  F0,EB_2
         STE   F0,EB_SQRT2
         LA    R2,EB_SQRT2
*MCALL #=    23 LV= 1          CTD   CTD_EB,IN=(R2),OUT=(R4)
         LA    1,=A(CTD_EB,(R2),(R4))
         ST    R2,4(1)
         ST    R4,8(1)
         SVC   170 CTD R1=A(TYPE,IN,OUT)
*MEXIT #=    23 LV= 1 CTD
         LTR   R15,R15
         BNZ   ABORT
         MVC   DTYPE,=CL20'EB SQRT 2'
*MCALL #=    24 LV= 1          WTO   MF=(E,WTOMSG)
         LA    1,WTOMSG
         SVC   35
*MEXIT #=    24 LV= 1 WTO
         SQD   F0,DH_2
         STD   F0,DH_SQRT2
         LA    R2,DH_SQRT2
*MCALL #=    25 LV= 1          CTD   CTD_DH,IN=(R2),OUT=(R4)
         LA    1,=A(CTD_DH,(R2),(R4))
         ST    R2,4(1)
         ST    R4,8(1)
         SVC   170 CTD R1=A(TYPE,IN,OUT)
*MEXIT #=    25 LV= 1 CTD
         LTR   R15,R15
         BNZ   ABORT
         MVC   DTYPE,=CL20'DH SQRT 2'
*MCALL #=    26 LV= 1          WTO   MF=(E,WTOMSG)
         LA    1,WTOMSG
         SVC   35
*MEXIT #=    26 LV= 1 WTO
         SQDB  F0,DB_2
         STD   F0,DB_SQRT2
         LA    R2,DB_SQRT2
*MCALL #=    27 LV= 1          CTD   CTD_DB,IN=(R2),OUT=(R4)
         LA    1,=A(CTD_DB,(R2),(R4))
         ST    R2,4(1)
         ST    R4,8(1)
         SVC   170 CTD R1=A(TYPE,IN,OUT)
*MEXIT #=    27 LV= 1 CTD
         LTR   R15,R15
         BNZ   ABORT
         MVC   DTYPE,=CL20'DB SQRT 2'
*MCALL #=    28 LV= 1          WTO   MF=(E,WTOMSG)
         LA    1,WTOMSG
         SVC   35
*MEXIT #=    28 LV= 1 WTO
         LD    F1,LH_2
         LD    F3,LH_2+8
         SQXR  F0,F1
         STD   F0,LH_SQRT2
         STD   F2,LH_SQRT2+8
         LA    R2,LH_SQRT2
*MCALL #=    29 LV= 1          CTD   CTD_LH,IN=(R2),OUT=(R4)
         LA    1,=A(CTD_LH,(R2),(R4))
         ST    R2,4(1)
         ST    R4,8(1)
         SVC   170 CTD R1=A(TYPE,IN,OUT)
*MEXIT #=    29 LV= 1 CTD
         LTR   R15,R15
         BNZ   ABORT
         MVC   DTYPE,=CL20'LH SQRT 2'
*MCALL #=    30 LV= 1          WTO   MF=(E,WTOMSG)
         LA    1,WTOMSG
         SVC   35
*MEXIT #=    30 LV= 1 WTO
         LD    F1,LB_2
         LD    F3,LB_2+8
         SQXBR F0,F1
         STD   F0,LB_SQRT2
         STD   F2,LB_SQRT2+8
         LA    R2,LB_SQRT2
*MCALL #=    31 LV= 1          CTD   CTD_LB,IN=(R2),OUT=(R4)
         LA    1,=A(CTD_LB,(R2),(R4))
         ST    R2,4(1)
         ST    R4,8(1)
         SVC   170 CTD R1=A(TYPE,IN,OUT)
*MEXIT #=    31 LV= 1 CTD
         LTR   R15,R15
         BNZ   ABORT
         MVC   DTYPE,=CL20'LB SQRT 2'
*MCALL #=    32 LV= 1          WTO   MF=(E,WTOMSG)
         LA    1,WTOMSG
         SVC   35
*MEXIT #=    32 LV= 1 WTO
*MCALL #=    33 LV= 1          WTO   'USING IN=REG GPR/FPR REG VALUE'
         BRAS  1,*+(WTO#0033_EOT-*+1)/2*2
         DC    AL2(WTO#0033_EOT-*,0),C'USING IN=REG GPR/FPR REG VALUE'
WTO#0033_EOT     EQU *
         SVC   35
*MEXIT #=    33 LV= 1 WTO
         MVC   DTYPE,=CL20'128 BIT INTEGER'
         LMG   R2,R3,INT128
         LA    R4,D45
*MCALL #=    34 LV= 1          CTD   CTD_INT128,IN=R2,OUT=(R4)
         LA    1,=A(CTD_INT128,R2,(R4))
         ST    R4,8(1)
         SVC   170 CTD R1=A(TYPE,IN,OUT)
*MEXIT #=    34 LV= 1 CTD
         LTR   R15,R15
         BNZ   ABORT
*MCALL #=    35 LV= 1          WTO   MF=(E,WTOMSG)
         LA    1,WTOMSG
         SVC   35
*MEXIT #=    35 LV= 1 WTO
         SQE   F1,EH_2
*MCALL #=    36 LV= 1          CTD   CTD_EH,IN=F1,OUT=(R4)
         LA    1,=A(CTD_EH,F1,(R4))
         ST    R4,8(1)
         SVC   170 CTD R1=A(TYPE,IN,OUT)
*MEXIT #=    36 LV= 1 CTD
         LTR   R15,R15
         BNZ   ABORT
         MVC   DTYPE,=CL20'EH SQRT 2'
*MCALL #=    37 LV= 1          WTO   MF=(E,WTOMSG)
         LA    1,WTOMSG
         SVC   35
*MEXIT #=    37 LV= 1 WTO
         SQEB  F1,EB_2
*MCALL #=    38 LV= 1          CTD   CTD_EB,IN=F1,OUT=(R4)
         LA    1,=A(CTD_EB,F1,(R4))
         ST    R4,8(1)
         SVC   170 CTD R1=A(TYPE,IN,OUT)
*MEXIT #=    38 LV= 1 CTD
         LTR   R15,R15
         BNZ   ABORT
         MVC   DTYPE,=CL20'EB SQRT 2'
*MCALL #=    39 LV= 1          WTO   MF=(E,WTOMSG)
         LA    1,WTOMSG
         SVC   35
*MEXIT #=    39 LV= 1 WTO
         SQD   F1,DH_2
*MCALL #=    40 LV= 1          CTD   CTD_DH,IN=F1,OUT=(R4)
         LA    1,=A(CTD_DH,F1,(R4))
         ST    R4,8(1)
         SVC   170 CTD R1=A(TYPE,IN,OUT)
*MEXIT #=    40 LV= 1 CTD
         LTR   R15,R15
         BNZ   ABORT
         MVC   DTYPE,=CL20'DH SQRT 2'
*MCALL #=    41 LV= 1          WTO   MF=(E,WTOMSG)
         LA    1,WTOMSG
         SVC   35
*MEXIT #=    41 LV= 1 WTO
         SQDB  F1,DB_2
*MCALL #=    42 LV= 1          CTD   CTD_DB,IN=F1,OUT=(R4)
         LA    1,=A(CTD_DB,F1,(R4))
         ST    R4,8(1)
         SVC   170 CTD R1=A(TYPE,IN,OUT)
*MEXIT #=    42 LV= 1 CTD
         LTR   R15,R15
         BNZ   ABORT
         MVC   DTYPE,=CL20'DB SQRT 2'
*MCALL #=    43 LV= 1          WTO   MF=(E,WTOMSG)
         LA    1,WTOMSG
         SVC   35
*MEXIT #=    43 LV= 1 WTO
         LD    F1,LH_2
         LD    F3,LH_2+8
         SQXR  F1,F1
*MCALL #=    44 LV= 1          CTD   CTD_LH,IN=F1,OUT=(R4)
         LA    1,=A(CTD_LH,F1,(R4))
         ST    R4,8(1)
         SVC   170 CTD R1=A(TYPE,IN,OUT)
*MEXIT #=    44 LV= 1 CTD
         LTR   R15,R15
         BNZ   ABORT
         MVC   DTYPE,=CL20'LH SQRT 2'
*MCALL #=    45 LV= 1          WTO   MF=(E,WTOMSG)
         LA    1,WTOMSG
         SVC   35
*MEXIT #=    45 LV= 1 WTO
         LD    F1,LB_2
         LD    F3,LB_2+8
         SQXBR F1,F1
*MCALL #=    46 LV= 1          CTD   CTD_LB,IN=F1,OUT=(R4)
         LA    1,=A(CTD_LB,F1,(R4))
         ST    R4,8(1)
         SVC   170 CTD R1=A(TYPE,IN,OUT)
*MEXIT #=    46 LV= 1 CTD
         LTR   R15,R15
         BNZ   ABORT
         MVC   DTYPE,=CL20'LB SQRT 2'
*MCALL #=    47 LV= 1          WTO   MF=(E,WTOMSG)
         LA    1,WTOMSG
         SVC   35
*MEXIT #=    47 LV= 1 WTO
*MCALL #=    48 LV= 1          WTO   'TESTCTD1 ENDED OK'
         BRAS  1,*+(WTO#0048_EOT-*+1)/2*2
         DC    AL2(WTO#0048_EOT-*,0),C'TESTCTD1 ENDED OK'
WTO#0048_EOT     EQU *
         SVC   35
*MEXIT #=    48 LV= 1 WTO
*MCALL #=    49 LV= 1          SUBEXIT 
         LA    15,0
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=    49 LV= 1 SUBEXIT
*MCALL #=    50 LV= 1 ABORT    ABEND 111
ABORT    DS    0H
         LA   1,111
         SVC  13 ABEND R1=COMP CODE AND HIGH BIT = DUMP PGM STORAGE
*MEXIT #=    50 LV= 1 ABEND
INT128   DC    0XL16,X'80',15X'00'
EH_2     DC    EH'2'
EB_2     DC    EB'2'
DH_2     DC    DH'2'
DB_2     DC    DB'2'
LH_2     DC    LH'2'
LB_2     DC    LB'2'
EH_SQRT2 DC    EH'0'
EB_SQRT2 DC    EB'0'
DH_SQRT2 DC    DH'0'
DB_SQRT2 DC    DB'0'
LH_SQRT2 DC    LH'0'
LB_SQRT2 DC    LB'0'
WTOMSG   DC    AL2(WTOEND-*,0)       WTO MESSAGE LENGTH AND FLAGS
DTYPE    DC    CL20' ',C' = '        DISPLAY DESCRIPTIONS
D45      DC    CL45' '               DISPLAY VALUE
WTOEND   EQU   *
         LTORG                       FORCE LITERALS IN POWERS CSECT
*MCALL #=    51 LV= 1          EQUREGS REGS=GPR
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
*MEXIT #=    51 LV= 1 EQUREGS
*MCALL #=    52 LV= 1          EQUREGS REGS=FPR
F0     EQU 0
F1     EQU 1
F2     EQU 2
F3     EQU 3
F4     EQU 4
F5     EQU 5
F6     EQU 6
F7     EQU 7
F8     EQU 8
F9     EQU 9
F10    EQU 10
F11    EQU 11
F12    EQU 12
F13    EQU 13
F14    EQU 14
F15    EQU 15
*MEXIT #=    52 LV= 1 EQUREGS
         END 
