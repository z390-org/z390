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
* 2006-07-19 DSH         Initial version                            *
* 2006-11-10 DSH RPI-477 Add ASCII support to CTD and CFD,          *
*                        use IN=,OUPT=                              *
* 2006-11-29 DSH RPI-507 Support IN=REG in addition to IN=(REG ADDR)*
* 2006-12-02 DSH RPI-511 Support floating point format for INT128   *
*                        input                                      *
* 2006-12-03 DSH RPI-513 Add RC test                                *
* 2006-12-11 DSH RPI-514 Add DFP DD, ED, and LD tests               *
* 2008-01-14 DSH RPI-786 Use DFP COMP to handle diff canonizations  *
* 2008-04-22 DSH RPI-833 Add string quotes for HLASM compatibility  *
*********************************************************************
         PRINT DATA
*MCALL #=     1 LV= 1 TESTCTD1 RT1   MAIN
*MCALL #=     2 LV= 2 TESTCTD1 SUBENTRY 
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
*MEXIT #=     2 LV= 2 SUBENTRY
*MCALL #=     3 LV= 2          WTO   'TESTCTD1 RT1 STARTED'
         BRAS  1,*+(WTO#0003_EOT-*+1)/2*2
         DC    AL2(WTO#0003_EOT-*,0),C'TESTCTD1 RT1 STARTED'
WTO#0003_EOT     EQU *
         SVC   35
*MEXIT #=     3 LV= 2 WTO
         BRCL    15,RT1_START
RT1_ABORT DS 0H
         MVI   RT1_ABORTED,C'T'
*MCALL #=     4 LV= 2          WTO   'TESTCTD1 RT1 TESTING ABORTED'
         BRAS  1,*+(WTO#0004_EOT-*+1)/2*2
         DC    AL2(WTO#0004_EOT-*,0),C'TESTCTD1 RT1 TESTING ABORTED'
WTO#0004_EOT     EQU *
         SVC   35
*MEXIT #=     4 LV= 2 WTO
RT1_END  DS    0H
         MVC   RT1_DTOT,=X'402020202020'
         ED    RT1_DTOT,RT1_TOT
*MCALL #=     5 LV= 2          WTO   MF=(E,RT1_WTO1)
         LA    1,RT1_WTO1
         SVC   35
*MEXIT #=     5 LV= 2 WTO
         CLI   RT1_ABORTED,C'T'
         BE    RT1_DUMP
*MCALL #=     6 LV= 2          WTO   'TESTCTD1 RT1 ENDED OK'
         BRAS  1,*+(WTO#0006_EOT-*+1)/2*2
         DC    AL2(WTO#0006_EOT-*,0),C'TESTCTD1 RT1 ENDED OK'
WTO#0006_EOT     EQU *
         SVC   35
*MEXIT #=     6 LV= 2 WTO
*MCALL #=     7 LV= 2          SUBEXIT 
         LA    15,0
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=     7 LV= 2 SUBEXIT
RT1_DUMP DS    0H
*MCALL #=     8 LV= 2          ABEND 101
         LA   1,101
         SVC  13 ABEND R1=COMP CODE AND HIGH BIT = DUMP PGM STORAGE
*MEXIT #=     8 LV= 2 ABEND
RT1_LINK EQU   11
RT1_DATA EQU   *
RT1_TOT  DC    PL3'0' TOTAL RT1 TESTS COMPLETED
RT1_ONE  DC    P'1'
RT1_WTO1 DC    AL2(RT1_WTO_END-*,0),C'TESTCTD1 RT1 TESTS COMPLETED = '
RT1_DTOT DC    CL6' ZZZZZ'
RT1_WTO_END EQU *
RT1_ABORTED DC C'F'
         LTORG 
RT1_TEST_CC0  DS    0H
         BNE   RT1_ABORT
RT1_OK   DS    0H
         AP    RT1_TOT,RT1_ONE
         BR    RT1_LINK
RT1_TEST_CC1  DS    0H
         BNL   RT1_ABORT
         AP    RT1_TOT,RT1_ONE
         BR    RT1_LINK
RT1_TEST_CC2  DS    0H
         BNH   RT1_ABORT
         AP    RT1_TOT,RT1_ONE
         BR    RT1_LINK
RT1_TEST_CC3  DS    0H
         BNO   RT1_ABORT
         AP    RT1_TOT,RT1_ONE
         BR    RT1_LINK
RT1_TEST_CCGE  DS    0H
         BL    RT1_ABORT
         AP    RT1_TOT,RT1_ONE
         BR    RT1_LINK
RT1_TEST_CCLE  DS    0H
         BH    RT1_ABORT
         AP    RT1_TOT,RT1_ONE
         BR    RT1_LINK
*MEXIT #=     1 LV= 1 RT1
WORK     DC    XL16'00' INT128,E,D,L WORK AREA
DECIMAL  DC    CL45' '  DECIMAL WORK AREA
*MCALL #=     9 LV= 1          EQUREGS 
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
*MEXIT #=     9 LV= 1 EQUREGS
*MCALL #=    10 LV= 1 ABORT    ABEND 111
ABORT    DS    0H
         LA   1,111
         SVC  13 ABEND R1=COMP CODE AND HIGH BIT = DUMP PGM STORAGE
*MEXIT #=    10 LV= 1 ABEND
         MACRO
         TEST  &TYPE,&IN,&VER
         BALR  R10,0                             RPI-786
         USING *,R10                             RPI-786
         MVC   DECIMAL,&IN
* TEST CFD OUT=RX
         CFD   CFD_&TYPE,OUT=WORK,IN=DECIMAL
         LTR   R15,R15
         BNZ   ABORT
         LX    R4,WORK
         TESTC &TYPE,&VER
* TEST CFD OUT=(REG)
         LA    R2,WORK
         CFD   CFD_&TYPE,OUT=(R2),IN=DECIMAL
         LTR   R15,R15
         BNZ   ABORT
         LX    R4,WORK
         TESTC &TYPE,&VER
* TEST CFD OUT-REG (VALUE 0-15)
         CFD   CFD_&TYPE,OUT=R4,IN=DECIMAL
         LTR   R15,R15
         BNZ   ABORT
         TESTC &TYPE,&VER
         MEND
         MACRO
         TESTC &TYPE,&VAL
         AIF   ('&TYPE' EQ 'ED').ED_COMP
         AIF   ('&TYPE' EQ 'DD').DD_COMP
         AIF   ('&TYPE' EQ 'LD').LD_COMP
         AGO   .CLC_COMP
.ED_COMP ANOP
         LE    R0,&VAL
         LDETR R0,R0,0
         LDETR R4,R4,0
         CDTR  R0,R4
         AGO   .END_COMP
.DD_COMP ANOP
         LD    R0,&VAL
         CDTR  R0,R4
         AGO   .END_COMP
.LD_COMP ANOP
         LX    R0,&VAL
         CXTR  R0,R4
         AGO   .END_COMP
.CLC_COMP ANOP
         STX   R4,WORK
         LA    R1,L'&VAL
         BCTR  R1,0
         EX    R1,*+4+4
         B     *+4+6
         CLC   WORK(0),&VAL  VERIFY CTD CONSTANT WITH CFD RESULT
.END_COMP ANOP
         RT1   CCE
         MEND
*MCALL #=    11 LV= 1          RT1   START
RT1_START DS  0H
*MEXIT #=    11 LV= 1 RT1
*MCALL #=    12 LV= 1          WTO   'TEST CFD CONVERT FROM DISPLAY MACX
               RO/SVC 171 SERVICE'
         BRAS  1,*+(WTO#0012_EOT-*+1)/2*2
         DC    AL2(WTO#0012_EOT-*,0),C'TEST CFD CONVERT FROM DISPLAY MAX
               CRO/SVC 171 SERVICE'
WTO#0012_EOT     EQU *
         SVC   35
*MEXIT #=    12 LV= 1 WTO
*MCALL #=    13 LV= 1          TEST  INT128,=CL45'2',=FL16'2'
         BALR  R10,0                             RPI-786
         USING *,R10                             RPI-786
         MVC   DECIMAL,=CL45'2'
* TEST CFD OUT=RX
*MCALL #=    14 LV= 2          CFD   CFD_INT128,OUT=WORK,IN=DECIMAL
         DS    0H
CFD_INT128 EQU 21 CONVERT TO 128 BIT INT FROM 45 BYTE SN(39)
CFD_EH   EQU   22 CONVERT TO HFP SHORT EH FROM 45 BYTE SN.N(7)+ENNNN
CFD_EB   EQU   23 CONVERT TO BFP SHORT EB FROM 45 BYTE SN.N(7)+ENNNN
CFD_DH   EQU   24 CONVERT TO HFP LONG  DH FROM 45 BYTE SN.N(14)+ENNNN
CFD_DB   EQU   25 CONVERT TO BFP LONG  DB FROM 45 BYTE SN.N(14)+ENNNN
CFD_LH   EQU   26 CONVERT TO HFP EXT.  LH FROM 45 BYTE SN.N(34)+ENNNN
CFD_LB   EQU   27 CONVERT TO BFP EXT.  LB FROM 45 BYTE SN.N(34)+ENNNN
CFD_DD   EQU   28 CONVERT TO DFP LONG  DD FROM 45 BYTE SN.N(16)+ENNNN
CFD_ED   EQU   29 CONVERT TO DFP SHORT ED FROM 45 BYTE SN.N( 7)+ENNNN
CFD_LD   EQU   30 CONVERT TO DFP EXT.  LD FROM 45 BYTE SN.N(34)+ENNNN
         LA    1,=A(CFD_INT128,WORK,DECIMAL)
         SVC   171 CFD Z390 SVC R1=A(TYPE,OUT,IN)
*MEXIT #=    14 LV= 2 CFD
         LTR   R15,R15
         BNZ   ABORT
*MCALL #=    15 LV= 2          LX    R4,WORK
         LA    15,WORK
         LD    R4,0(15)
         LD    R4+2,8(15)
*MEXIT #=    15 LV= 2 LX
*MCALL #=    16 LV= 2          TESTC INT128,=FL16'2'
*MCALL #=    17 LV= 3          STX   R4,WORK
         LA    15,WORK
         STD   R4,0(15)
         STD   R4+2,8(15)
*MEXIT #=    17 LV= 3 STX
         LA    R1,L'=FL16'2'
         BCTR  R1,0
         EX    R1,*+4+4
         B     *+4+6
         CLC   WORK(0),=FL16'2'  VERIFY CTD CONSTANT WITH CFD RESULT
*MCALL #=    18 LV= 3          RT1   CCE
         DS    0H
RT1_TEST1        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1
         LTORG 
RT1_CCE1        DS 0H
*MEXIT #=    18 LV= 3 RT1
*MEXIT #=    16 LV= 2 TESTC
* TEST CFD OUT=(REG)
         LA    R2,WORK
*MCALL #=    19 LV= 2          CFD   CFD_INT128,OUT=(R2),IN=DECIMAL
         DS    0H
         LA    1,=A(CFD_INT128,(R2),DECIMAL)
         ST    R2,4(1)                 RPI 507
         SVC   171 CFD Z390 SVC R1=A(TYPE,OUT,IN)
*MEXIT #=    19 LV= 2 CFD
         LTR   R15,R15
         BNZ   ABORT
*MCALL #=    20 LV= 2          LX    R4,WORK
         LA    15,WORK
         LD    R4,0(15)
         LD    R4+2,8(15)
*MEXIT #=    20 LV= 2 LX
*MCALL #=    21 LV= 2          TESTC INT128,=FL16'2'
*MCALL #=    22 LV= 3          STX   R4,WORK
         LA    15,WORK
         STD   R4,0(15)
         STD   R4+2,8(15)
*MEXIT #=    22 LV= 3 STX
         LA    R1,L'=FL16'2'
         BCTR  R1,0
         EX    R1,*+4+4
         B     *+4+6
         CLC   WORK(0),=FL16'2'  VERIFY CTD CONSTANT WITH CFD RESULT
*MCALL #=    23 LV= 3          RT1   CCE
         DS    0H
RT1_TEST2        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE2
         LTORG 
RT1_CCE2        DS 0H
*MEXIT #=    23 LV= 3 RT1
*MEXIT #=    21 LV= 2 TESTC
* TEST CFD OUT-REG (VALUE 0-15)
*MCALL #=    24 LV= 2          CFD   CFD_INT128,OUT=R4,IN=DECIMAL
         DS    0H
         LA    1,=A(CFD_INT128,R4,DECIMAL)
         SVC   171 CFD Z390 SVC R1=A(TYPE,OUT,IN)
*MEXIT #=    24 LV= 2 CFD
         LTR   R15,R15
         BNZ   ABORT
*MCALL #=    25 LV= 2          TESTC INT128,=FL16'2'
*MCALL #=    26 LV= 3          STX   R4,WORK
         LA    15,WORK
         STD   R4,0(15)
         STD   R4+2,8(15)
*MEXIT #=    26 LV= 3 STX
         LA    R1,L'=FL16'2'
         BCTR  R1,0
         EX    R1,*+4+4
         B     *+4+6
         CLC   WORK(0),=FL16'2'  VERIFY CTD CONSTANT WITH CFD RESULT
*MCALL #=    27 LV= 3          RT1   CCE
         DS    0H
RT1_TEST3        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE3
         LTORG 
RT1_CCE3        DS 0H
*MEXIT #=    27 LV= 3 RT1
*MEXIT #=    25 LV= 2 TESTC
*MEXIT #=    13 LV= 1 TEST
*MCALL #=    28 LV= 1          TEST  INT128,=CL45'123E2',=FL16'12300'
         BALR  R10,0                             RPI-786
         USING *,R10                             RPI-786
         MVC   DECIMAL,=CL45'123E2'
* TEST CFD OUT=RX
*MCALL #=    29 LV= 2          CFD   CFD_INT128,OUT=WORK,IN=DECIMAL
         DS    0H
         LA    1,=A(CFD_INT128,WORK,DECIMAL)
         SVC   171 CFD Z390 SVC R1=A(TYPE,OUT,IN)
*MEXIT #=    29 LV= 2 CFD
         LTR   R15,R15
         BNZ   ABORT
*MCALL #=    30 LV= 2          LX    R4,WORK
         LA    15,WORK
         LD    R4,0(15)
         LD    R4+2,8(15)
*MEXIT #=    30 LV= 2 LX
*MCALL #=    31 LV= 2          TESTC INT128,=FL16'12300'
*MCALL #=    32 LV= 3          STX   R4,WORK
         LA    15,WORK
         STD   R4,0(15)
         STD   R4+2,8(15)
*MEXIT #=    32 LV= 3 STX
         LA    R1,L'=FL16'12300'
         BCTR  R1,0
         EX    R1,*+4+4
         B     *+4+6
         CLC   WORK(0),=FL16'12300'  VERIFY CTD CONSTANT WITH CFD RESULX
               T
*MCALL #=    33 LV= 3          RT1   CCE
         DS    0H
RT1_TEST4        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE4
         LTORG 
RT1_CCE4        DS 0H
*MEXIT #=    33 LV= 3 RT1
*MEXIT #=    31 LV= 2 TESTC
* TEST CFD OUT=(REG)
         LA    R2,WORK
*MCALL #=    34 LV= 2          CFD   CFD_INT128,OUT=(R2),IN=DECIMAL
         DS    0H
         LA    1,=A(CFD_INT128,(R2),DECIMAL)
         ST    R2,4(1)                 RPI 507
         SVC   171 CFD Z390 SVC R1=A(TYPE,OUT,IN)
*MEXIT #=    34 LV= 2 CFD
         LTR   R15,R15
         BNZ   ABORT
*MCALL #=    35 LV= 2          LX    R4,WORK
         LA    15,WORK
         LD    R4,0(15)
         LD    R4+2,8(15)
*MEXIT #=    35 LV= 2 LX
*MCALL #=    36 LV= 2          TESTC INT128,=FL16'12300'
*MCALL #=    37 LV= 3          STX   R4,WORK
         LA    15,WORK
         STD   R4,0(15)
         STD   R4+2,8(15)
*MEXIT #=    37 LV= 3 STX
         LA    R1,L'=FL16'12300'
         BCTR  R1,0
         EX    R1,*+4+4
         B     *+4+6
         CLC   WORK(0),=FL16'12300'  VERIFY CTD CONSTANT WITH CFD RESULX
               T
*MCALL #=    38 LV= 3          RT1   CCE
         DS    0H
RT1_TEST5        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE5
         LTORG 
RT1_CCE5        DS 0H
*MEXIT #=    38 LV= 3 RT1
*MEXIT #=    36 LV= 2 TESTC
* TEST CFD OUT-REG (VALUE 0-15)
*MCALL #=    39 LV= 2          CFD   CFD_INT128,OUT=R4,IN=DECIMAL
         DS    0H
         LA    1,=A(CFD_INT128,R4,DECIMAL)
         SVC   171 CFD Z390 SVC R1=A(TYPE,OUT,IN)
*MEXIT #=    39 LV= 2 CFD
         LTR   R15,R15
         BNZ   ABORT
*MCALL #=    40 LV= 2          TESTC INT128,=FL16'12300'
*MCALL #=    41 LV= 3          STX   R4,WORK
         LA    15,WORK
         STD   R4,0(15)
         STD   R4+2,8(15)
*MEXIT #=    41 LV= 3 STX
         LA    R1,L'=FL16'12300'
         BCTR  R1,0
         EX    R1,*+4+4
         B     *+4+6
         CLC   WORK(0),=FL16'12300'  VERIFY CTD CONSTANT WITH CFD RESULX
               T
*MCALL #=    42 LV= 3          RT1   CCE
         DS    0H
RT1_TEST6        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE6
         LTORG 
RT1_CCE6        DS 0H
*MEXIT #=    42 LV= 3 RT1
*MEXIT #=    40 LV= 2 TESTC
*MEXIT #=    28 LV= 1 TEST
*MCALL #=    43 LV= 1          TEST  INT128,=CL45'123.5',=FL16'123'
         BALR  R10,0                             RPI-786
         USING *,R10                             RPI-786
         MVC   DECIMAL,=CL45'123.5'
* TEST CFD OUT=RX
*MCALL #=    44 LV= 2          CFD   CFD_INT128,OUT=WORK,IN=DECIMAL
         DS    0H
         LA    1,=A(CFD_INT128,WORK,DECIMAL)
         SVC   171 CFD Z390 SVC R1=A(TYPE,OUT,IN)
*MEXIT #=    44 LV= 2 CFD
         LTR   R15,R15
         BNZ   ABORT
*MCALL #=    45 LV= 2          LX    R4,WORK
         LA    15,WORK
         LD    R4,0(15)
         LD    R4+2,8(15)
*MEXIT #=    45 LV= 2 LX
*MCALL #=    46 LV= 2          TESTC INT128,=FL16'123'
*MCALL #=    47 LV= 3          STX   R4,WORK
         LA    15,WORK
         STD   R4,0(15)
         STD   R4+2,8(15)
*MEXIT #=    47 LV= 3 STX
         LA    R1,L'=FL16'123'
         BCTR  R1,0
         EX    R1,*+4+4
         B     *+4+6
         CLC   WORK(0),=FL16'123'  VERIFY CTD CONSTANT WITH CFD RESULT
*MCALL #=    48 LV= 3          RT1   CCE
         DS    0H
RT1_TEST7        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE7
         LTORG 
RT1_CCE7        DS 0H
*MEXIT #=    48 LV= 3 RT1
*MEXIT #=    46 LV= 2 TESTC
* TEST CFD OUT=(REG)
         LA    R2,WORK
*MCALL #=    49 LV= 2          CFD   CFD_INT128,OUT=(R2),IN=DECIMAL
         DS    0H
         LA    1,=A(CFD_INT128,(R2),DECIMAL)
         ST    R2,4(1)                 RPI 507
         SVC   171 CFD Z390 SVC R1=A(TYPE,OUT,IN)
*MEXIT #=    49 LV= 2 CFD
         LTR   R15,R15
         BNZ   ABORT
*MCALL #=    50 LV= 2          LX    R4,WORK
         LA    15,WORK
         LD    R4,0(15)
         LD    R4+2,8(15)
*MEXIT #=    50 LV= 2 LX
*MCALL #=    51 LV= 2          TESTC INT128,=FL16'123'
*MCALL #=    52 LV= 3          STX   R4,WORK
         LA    15,WORK
         STD   R4,0(15)
         STD   R4+2,8(15)
*MEXIT #=    52 LV= 3 STX
         LA    R1,L'=FL16'123'
         BCTR  R1,0
         EX    R1,*+4+4
         B     *+4+6
         CLC   WORK(0),=FL16'123'  VERIFY CTD CONSTANT WITH CFD RESULT
*MCALL #=    53 LV= 3          RT1   CCE
         DS    0H
RT1_TEST8        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE8
         LTORG 
RT1_CCE8        DS 0H
*MEXIT #=    53 LV= 3 RT1
*MEXIT #=    51 LV= 2 TESTC
* TEST CFD OUT-REG (VALUE 0-15)
*MCALL #=    54 LV= 2          CFD   CFD_INT128,OUT=R4,IN=DECIMAL
         DS    0H
         LA    1,=A(CFD_INT128,R4,DECIMAL)
         SVC   171 CFD Z390 SVC R1=A(TYPE,OUT,IN)
*MEXIT #=    54 LV= 2 CFD
         LTR   R15,R15
         BNZ   ABORT
*MCALL #=    55 LV= 2          TESTC INT128,=FL16'123'
*MCALL #=    56 LV= 3          STX   R4,WORK
         LA    15,WORK
         STD   R4,0(15)
         STD   R4+2,8(15)
*MEXIT #=    56 LV= 3 STX
         LA    R1,L'=FL16'123'
         BCTR  R1,0
         EX    R1,*+4+4
         B     *+4+6
         CLC   WORK(0),=FL16'123'  VERIFY CTD CONSTANT WITH CFD RESULT
*MCALL #=    57 LV= 3          RT1   CCE
         DS    0H
RT1_TEST9        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE9
         LTORG 
RT1_CCE9        DS 0H
*MEXIT #=    57 LV= 3 RT1
*MEXIT #=    55 LV= 2 TESTC
*MEXIT #=    43 LV= 1 TEST
*MCALL #=    58 LV= 1          TEST  EH,=CL45'2',=EH'2'
         BALR  R10,0                             RPI-786
         USING *,R10                             RPI-786
         MVC   DECIMAL,=CL45'2'
* TEST CFD OUT=RX
*MCALL #=    59 LV= 2          CFD   CFD_EH,OUT=WORK,IN=DECIMAL
         DS    0H
         LA    1,=A(CFD_EH,WORK,DECIMAL)
         SVC   171 CFD Z390 SVC R1=A(TYPE,OUT,IN)
*MEXIT #=    59 LV= 2 CFD
         LTR   R15,R15
         BNZ   ABORT
*MCALL #=    60 LV= 2          LX    R4,WORK
         LA    15,WORK
         LD    R4,0(15)
         LD    R4+2,8(15)
*MEXIT #=    60 LV= 2 LX
*MCALL #=    61 LV= 2          TESTC EH,=EH'2'
*MCALL #=    62 LV= 3          STX   R4,WORK
         LA    15,WORK
         STD   R4,0(15)
         STD   R4+2,8(15)
*MEXIT #=    62 LV= 3 STX
         LA    R1,L'=EH'2'
         BCTR  R1,0
         EX    R1,*+4+4
         B     *+4+6
         CLC   WORK(0),=EH'2'  VERIFY CTD CONSTANT WITH CFD RESULT
*MCALL #=    63 LV= 3          RT1   CCE
         DS    0H
RT1_TEST10       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE10
         LTORG 
RT1_CCE10       DS 0H
*MEXIT #=    63 LV= 3 RT1
*MEXIT #=    61 LV= 2 TESTC
* TEST CFD OUT=(REG)
         LA    R2,WORK
*MCALL #=    64 LV= 2          CFD   CFD_EH,OUT=(R2),IN=DECIMAL
         DS    0H
         LA    1,=A(CFD_EH,(R2),DECIMAL)
         ST    R2,4(1)                 RPI 507
         SVC   171 CFD Z390 SVC R1=A(TYPE,OUT,IN)
*MEXIT #=    64 LV= 2 CFD
         LTR   R15,R15
         BNZ   ABORT
*MCALL #=    65 LV= 2          LX    R4,WORK
         LA    15,WORK
         LD    R4,0(15)
         LD    R4+2,8(15)
*MEXIT #=    65 LV= 2 LX
*MCALL #=    66 LV= 2          TESTC EH,=EH'2'
*MCALL #=    67 LV= 3          STX   R4,WORK
         LA    15,WORK
         STD   R4,0(15)
         STD   R4+2,8(15)
*MEXIT #=    67 LV= 3 STX
         LA    R1,L'=EH'2'
         BCTR  R1,0
         EX    R1,*+4+4
         B     *+4+6
         CLC   WORK(0),=EH'2'  VERIFY CTD CONSTANT WITH CFD RESULT
*MCALL #=    68 LV= 3          RT1   CCE
         DS    0H
RT1_TEST11       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE11
         LTORG 
RT1_CCE11       DS 0H
*MEXIT #=    68 LV= 3 RT1
*MEXIT #=    66 LV= 2 TESTC
* TEST CFD OUT-REG (VALUE 0-15)
*MCALL #=    69 LV= 2          CFD   CFD_EH,OUT=R4,IN=DECIMAL
         DS    0H
         LA    1,=A(CFD_EH,R4,DECIMAL)
         SVC   171 CFD Z390 SVC R1=A(TYPE,OUT,IN)
*MEXIT #=    69 LV= 2 CFD
         LTR   R15,R15
         BNZ   ABORT
*MCALL #=    70 LV= 2          TESTC EH,=EH'2'
*MCALL #=    71 LV= 3          STX   R4,WORK
         LA    15,WORK
         STD   R4,0(15)
         STD   R4+2,8(15)
*MEXIT #=    71 LV= 3 STX
         LA    R1,L'=EH'2'
         BCTR  R1,0
         EX    R1,*+4+4
         B     *+4+6
         CLC   WORK(0),=EH'2'  VERIFY CTD CONSTANT WITH CFD RESULT
*MCALL #=    72 LV= 3          RT1   CCE
         DS    0H
RT1_TEST12       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE12
         LTORG 
RT1_CCE12       DS 0H
*MEXIT #=    72 LV= 3 RT1
*MEXIT #=    70 LV= 2 TESTC
*MEXIT #=    58 LV= 1 TEST
*MCALL #=    73 LV= 1          TEST  EB,=CL45'2',=EB'2'
         BALR  R10,0                             RPI-786
         USING *,R10                             RPI-786
         MVC   DECIMAL,=CL45'2'
* TEST CFD OUT=RX
*MCALL #=    74 LV= 2          CFD   CFD_EB,OUT=WORK,IN=DECIMAL
         DS    0H
         LA    1,=A(CFD_EB,WORK,DECIMAL)
         SVC   171 CFD Z390 SVC R1=A(TYPE,OUT,IN)
*MEXIT #=    74 LV= 2 CFD
         LTR   R15,R15
         BNZ   ABORT
*MCALL #=    75 LV= 2          LX    R4,WORK
         LA    15,WORK
         LD    R4,0(15)
         LD    R4+2,8(15)
*MEXIT #=    75 LV= 2 LX
*MCALL #=    76 LV= 2          TESTC EB,=EB'2'
*MCALL #=    77 LV= 3          STX   R4,WORK
         LA    15,WORK
         STD   R4,0(15)
         STD   R4+2,8(15)
*MEXIT #=    77 LV= 3 STX
         LA    R1,L'=EB'2'
         BCTR  R1,0
         EX    R1,*+4+4
         B     *+4+6
         CLC   WORK(0),=EB'2'  VERIFY CTD CONSTANT WITH CFD RESULT
*MCALL #=    78 LV= 3          RT1   CCE
         DS    0H
RT1_TEST13       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE13
         LTORG 
RT1_CCE13       DS 0H
*MEXIT #=    78 LV= 3 RT1
*MEXIT #=    76 LV= 2 TESTC
* TEST CFD OUT=(REG)
         LA    R2,WORK
*MCALL #=    79 LV= 2          CFD   CFD_EB,OUT=(R2),IN=DECIMAL
         DS    0H
         LA    1,=A(CFD_EB,(R2),DECIMAL)
         ST    R2,4(1)                 RPI 507
         SVC   171 CFD Z390 SVC R1=A(TYPE,OUT,IN)
*MEXIT #=    79 LV= 2 CFD
         LTR   R15,R15
         BNZ   ABORT
*MCALL #=    80 LV= 2          LX    R4,WORK
         LA    15,WORK
         LD    R4,0(15)
         LD    R4+2,8(15)
*MEXIT #=    80 LV= 2 LX
*MCALL #=    81 LV= 2          TESTC EB,=EB'2'
*MCALL #=    82 LV= 3          STX   R4,WORK
         LA    15,WORK
         STD   R4,0(15)
         STD   R4+2,8(15)
*MEXIT #=    82 LV= 3 STX
         LA    R1,L'=EB'2'
         BCTR  R1,0
         EX    R1,*+4+4
         B     *+4+6
         CLC   WORK(0),=EB'2'  VERIFY CTD CONSTANT WITH CFD RESULT
*MCALL #=    83 LV= 3          RT1   CCE
         DS    0H
RT1_TEST14       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE14
         LTORG 
RT1_CCE14       DS 0H
*MEXIT #=    83 LV= 3 RT1
*MEXIT #=    81 LV= 2 TESTC
* TEST CFD OUT-REG (VALUE 0-15)
*MCALL #=    84 LV= 2          CFD   CFD_EB,OUT=R4,IN=DECIMAL
         DS    0H
         LA    1,=A(CFD_EB,R4,DECIMAL)
         SVC   171 CFD Z390 SVC R1=A(TYPE,OUT,IN)
*MEXIT #=    84 LV= 2 CFD
         LTR   R15,R15
         BNZ   ABORT
*MCALL #=    85 LV= 2          TESTC EB,=EB'2'
*MCALL #=    86 LV= 3          STX   R4,WORK
         LA    15,WORK
         STD   R4,0(15)
         STD   R4+2,8(15)
*MEXIT #=    86 LV= 3 STX
         LA    R1,L'=EB'2'
         BCTR  R1,0
         EX    R1,*+4+4
         B     *+4+6
         CLC   WORK(0),=EB'2'  VERIFY CTD CONSTANT WITH CFD RESULT
*MCALL #=    87 LV= 3          RT1   CCE
         DS    0H
RT1_TEST15       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE15
         LTORG 
RT1_CCE15       DS 0H
*MEXIT #=    87 LV= 3 RT1
*MEXIT #=    85 LV= 2 TESTC
*MEXIT #=    73 LV= 1 TEST
*MCALL #=    88 LV= 1          TEST  DH,=CL45'2',=DH'2'
         BALR  R10,0                             RPI-786
         USING *,R10                             RPI-786
         MVC   DECIMAL,=CL45'2'
* TEST CFD OUT=RX
*MCALL #=    89 LV= 2          CFD   CFD_DH,OUT=WORK,IN=DECIMAL
         DS    0H
         LA    1,=A(CFD_DH,WORK,DECIMAL)
         SVC   171 CFD Z390 SVC R1=A(TYPE,OUT,IN)
*MEXIT #=    89 LV= 2 CFD
         LTR   R15,R15
         BNZ   ABORT
*MCALL #=    90 LV= 2          LX    R4,WORK
         LA    15,WORK
         LD    R4,0(15)
         LD    R4+2,8(15)
*MEXIT #=    90 LV= 2 LX
*MCALL #=    91 LV= 2          TESTC DH,=DH'2'
*MCALL #=    92 LV= 3          STX   R4,WORK
         LA    15,WORK
         STD   R4,0(15)
         STD   R4+2,8(15)
*MEXIT #=    92 LV= 3 STX
         LA    R1,L'=DH'2'
         BCTR  R1,0
         EX    R1,*+4+4
         B     *+4+6
         CLC   WORK(0),=DH'2'  VERIFY CTD CONSTANT WITH CFD RESULT
*MCALL #=    93 LV= 3          RT1   CCE
         DS    0H
RT1_TEST16       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE16
         LTORG 
RT1_CCE16       DS 0H
*MEXIT #=    93 LV= 3 RT1
*MEXIT #=    91 LV= 2 TESTC
* TEST CFD OUT=(REG)
         LA    R2,WORK
*MCALL #=    94 LV= 2          CFD   CFD_DH,OUT=(R2),IN=DECIMAL
         DS    0H
         LA    1,=A(CFD_DH,(R2),DECIMAL)
         ST    R2,4(1)                 RPI 507
         SVC   171 CFD Z390 SVC R1=A(TYPE,OUT,IN)
*MEXIT #=    94 LV= 2 CFD
         LTR   R15,R15
         BNZ   ABORT
*MCALL #=    95 LV= 2          LX    R4,WORK
         LA    15,WORK
         LD    R4,0(15)
         LD    R4+2,8(15)
*MEXIT #=    95 LV= 2 LX
*MCALL #=    96 LV= 2          TESTC DH,=DH'2'
*MCALL #=    97 LV= 3          STX   R4,WORK
         LA    15,WORK
         STD   R4,0(15)
         STD   R4+2,8(15)
*MEXIT #=    97 LV= 3 STX
         LA    R1,L'=DH'2'
         BCTR  R1,0
         EX    R1,*+4+4
         B     *+4+6
         CLC   WORK(0),=DH'2'  VERIFY CTD CONSTANT WITH CFD RESULT
*MCALL #=    98 LV= 3          RT1   CCE
         DS    0H
RT1_TEST17       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE17
         LTORG 
RT1_CCE17       DS 0H
*MEXIT #=    98 LV= 3 RT1
*MEXIT #=    96 LV= 2 TESTC
* TEST CFD OUT-REG (VALUE 0-15)
*MCALL #=    99 LV= 2          CFD   CFD_DH,OUT=R4,IN=DECIMAL
         DS    0H
         LA    1,=A(CFD_DH,R4,DECIMAL)
         SVC   171 CFD Z390 SVC R1=A(TYPE,OUT,IN)
*MEXIT #=    99 LV= 2 CFD
         LTR   R15,R15
         BNZ   ABORT
*MCALL #=   100 LV= 2          TESTC DH,=DH'2'
*MCALL #=   101 LV= 3          STX   R4,WORK
         LA    15,WORK
         STD   R4,0(15)
         STD   R4+2,8(15)
*MEXIT #=   101 LV= 3 STX
         LA    R1,L'=DH'2'
         BCTR  R1,0
         EX    R1,*+4+4
         B     *+4+6
         CLC   WORK(0),=DH'2'  VERIFY CTD CONSTANT WITH CFD RESULT
*MCALL #=   102 LV= 3          RT1   CCE
         DS    0H
RT1_TEST18       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE18
         LTORG 
RT1_CCE18       DS 0H
*MEXIT #=   102 LV= 3 RT1
*MEXIT #=   100 LV= 2 TESTC
*MEXIT #=    88 LV= 1 TEST
*MCALL #=   103 LV= 1          TEST  DB,=CL45'2',=DB'2'
         BALR  R10,0                             RPI-786
         USING *,R10                             RPI-786
         MVC   DECIMAL,=CL45'2'
* TEST CFD OUT=RX
*MCALL #=   104 LV= 2          CFD   CFD_DB,OUT=WORK,IN=DECIMAL
         DS    0H
         LA    1,=A(CFD_DB,WORK,DECIMAL)
         SVC   171 CFD Z390 SVC R1=A(TYPE,OUT,IN)
*MEXIT #=   104 LV= 2 CFD
         LTR   R15,R15
         BNZ   ABORT
*MCALL #=   105 LV= 2          LX    R4,WORK
         LA    15,WORK
         LD    R4,0(15)
         LD    R4+2,8(15)
*MEXIT #=   105 LV= 2 LX
*MCALL #=   106 LV= 2          TESTC DB,=DB'2'
*MCALL #=   107 LV= 3          STX   R4,WORK
         LA    15,WORK
         STD   R4,0(15)
         STD   R4+2,8(15)
*MEXIT #=   107 LV= 3 STX
         LA    R1,L'=DB'2'
         BCTR  R1,0
         EX    R1,*+4+4
         B     *+4+6
         CLC   WORK(0),=DB'2'  VERIFY CTD CONSTANT WITH CFD RESULT
*MCALL #=   108 LV= 3          RT1   CCE
         DS    0H
RT1_TEST19       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE19
         LTORG 
RT1_CCE19       DS 0H
*MEXIT #=   108 LV= 3 RT1
*MEXIT #=   106 LV= 2 TESTC
* TEST CFD OUT=(REG)
         LA    R2,WORK
*MCALL #=   109 LV= 2          CFD   CFD_DB,OUT=(R2),IN=DECIMAL
         DS    0H
         LA    1,=A(CFD_DB,(R2),DECIMAL)
         ST    R2,4(1)                 RPI 507
         SVC   171 CFD Z390 SVC R1=A(TYPE,OUT,IN)
*MEXIT #=   109 LV= 2 CFD
         LTR   R15,R15
         BNZ   ABORT
*MCALL #=   110 LV= 2          LX    R4,WORK
         LA    15,WORK
         LD    R4,0(15)
         LD    R4+2,8(15)
*MEXIT #=   110 LV= 2 LX
*MCALL #=   111 LV= 2          TESTC DB,=DB'2'
*MCALL #=   112 LV= 3          STX   R4,WORK
         LA    15,WORK
         STD   R4,0(15)
         STD   R4+2,8(15)
*MEXIT #=   112 LV= 3 STX
         LA    R1,L'=DB'2'
         BCTR  R1,0
         EX    R1,*+4+4
         B     *+4+6
         CLC   WORK(0),=DB'2'  VERIFY CTD CONSTANT WITH CFD RESULT
*MCALL #=   113 LV= 3          RT1   CCE
         DS    0H
RT1_TEST20       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE20
         LTORG 
RT1_CCE20       DS 0H
*MEXIT #=   113 LV= 3 RT1
*MEXIT #=   111 LV= 2 TESTC
* TEST CFD OUT-REG (VALUE 0-15)
*MCALL #=   114 LV= 2          CFD   CFD_DB,OUT=R4,IN=DECIMAL
         DS    0H
         LA    1,=A(CFD_DB,R4,DECIMAL)
         SVC   171 CFD Z390 SVC R1=A(TYPE,OUT,IN)
*MEXIT #=   114 LV= 2 CFD
         LTR   R15,R15
         BNZ   ABORT
*MCALL #=   115 LV= 2          TESTC DB,=DB'2'
*MCALL #=   116 LV= 3          STX   R4,WORK
         LA    15,WORK
         STD   R4,0(15)
         STD   R4+2,8(15)
*MEXIT #=   116 LV= 3 STX
         LA    R1,L'=DB'2'
         BCTR  R1,0
         EX    R1,*+4+4
         B     *+4+6
         CLC   WORK(0),=DB'2'  VERIFY CTD CONSTANT WITH CFD RESULT
*MCALL #=   117 LV= 3          RT1   CCE
         DS    0H
RT1_TEST21       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE21
         LTORG 
RT1_CCE21       DS 0H
*MEXIT #=   117 LV= 3 RT1
*MEXIT #=   115 LV= 2 TESTC
*MEXIT #=   103 LV= 1 TEST
*MCALL #=   118 LV= 1          TEST  LH,=CL45'2',=LH'2'
         BALR  R10,0                             RPI-786
         USING *,R10                             RPI-786
         MVC   DECIMAL,=CL45'2'
* TEST CFD OUT=RX
*MCALL #=   119 LV= 2          CFD   CFD_LH,OUT=WORK,IN=DECIMAL
         DS    0H
         LA    1,=A(CFD_LH,WORK,DECIMAL)
         SVC   171 CFD Z390 SVC R1=A(TYPE,OUT,IN)
*MEXIT #=   119 LV= 2 CFD
         LTR   R15,R15
         BNZ   ABORT
*MCALL #=   120 LV= 2          LX    R4,WORK
         LA    15,WORK
         LD    R4,0(15)
         LD    R4+2,8(15)
*MEXIT #=   120 LV= 2 LX
*MCALL #=   121 LV= 2          TESTC LH,=LH'2'
*MCALL #=   122 LV= 3          STX   R4,WORK
         LA    15,WORK
         STD   R4,0(15)
         STD   R4+2,8(15)
*MEXIT #=   122 LV= 3 STX
         LA    R1,L'=LH'2'
         BCTR  R1,0
         EX    R1,*+4+4
         B     *+4+6
         CLC   WORK(0),=LH'2'  VERIFY CTD CONSTANT WITH CFD RESULT
*MCALL #=   123 LV= 3          RT1   CCE
         DS    0H
RT1_TEST22       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE22
         LTORG 
RT1_CCE22       DS 0H
*MEXIT #=   123 LV= 3 RT1
*MEXIT #=   121 LV= 2 TESTC
* TEST CFD OUT=(REG)
         LA    R2,WORK
*MCALL #=   124 LV= 2          CFD   CFD_LH,OUT=(R2),IN=DECIMAL
         DS    0H
         LA    1,=A(CFD_LH,(R2),DECIMAL)
         ST    R2,4(1)                 RPI 507
         SVC   171 CFD Z390 SVC R1=A(TYPE,OUT,IN)
*MEXIT #=   124 LV= 2 CFD
         LTR   R15,R15
         BNZ   ABORT
*MCALL #=   125 LV= 2          LX    R4,WORK
         LA    15,WORK
         LD    R4,0(15)
         LD    R4+2,8(15)
*MEXIT #=   125 LV= 2 LX
*MCALL #=   126 LV= 2          TESTC LH,=LH'2'
*MCALL #=   127 LV= 3          STX   R4,WORK
         LA    15,WORK
         STD   R4,0(15)
         STD   R4+2,8(15)
*MEXIT #=   127 LV= 3 STX
         LA    R1,L'=LH'2'
         BCTR  R1,0
         EX    R1,*+4+4
         B     *+4+6
         CLC   WORK(0),=LH'2'  VERIFY CTD CONSTANT WITH CFD RESULT
*MCALL #=   128 LV= 3          RT1   CCE
         DS    0H
RT1_TEST23       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE23
         LTORG 
RT1_CCE23       DS 0H
*MEXIT #=   128 LV= 3 RT1
*MEXIT #=   126 LV= 2 TESTC
* TEST CFD OUT-REG (VALUE 0-15)
*MCALL #=   129 LV= 2          CFD   CFD_LH,OUT=R4,IN=DECIMAL
         DS    0H
         LA    1,=A(CFD_LH,R4,DECIMAL)
         SVC   171 CFD Z390 SVC R1=A(TYPE,OUT,IN)
*MEXIT #=   129 LV= 2 CFD
         LTR   R15,R15
         BNZ   ABORT
*MCALL #=   130 LV= 2          TESTC LH,=LH'2'
*MCALL #=   131 LV= 3          STX   R4,WORK
         LA    15,WORK
         STD   R4,0(15)
         STD   R4+2,8(15)
*MEXIT #=   131 LV= 3 STX
         LA    R1,L'=LH'2'
         BCTR  R1,0
         EX    R1,*+4+4
         B     *+4+6
         CLC   WORK(0),=LH'2'  VERIFY CTD CONSTANT WITH CFD RESULT
*MCALL #=   132 LV= 3          RT1   CCE
         DS    0H
RT1_TEST24       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE24
         LTORG 
RT1_CCE24       DS 0H
*MEXIT #=   132 LV= 3 RT1
*MEXIT #=   130 LV= 2 TESTC
*MEXIT #=   118 LV= 1 TEST
*MCALL #=   133 LV= 1          TEST  LB,=CL45'2',=LB'2'
         BALR  R10,0                             RPI-786
         USING *,R10                             RPI-786
         MVC   DECIMAL,=CL45'2'
* TEST CFD OUT=RX
*MCALL #=   134 LV= 2          CFD   CFD_LB,OUT=WORK,IN=DECIMAL
         DS    0H
         LA    1,=A(CFD_LB,WORK,DECIMAL)
         SVC   171 CFD Z390 SVC R1=A(TYPE,OUT,IN)
*MEXIT #=   134 LV= 2 CFD
         LTR   R15,R15
         BNZ   ABORT
*MCALL #=   135 LV= 2          LX    R4,WORK
         LA    15,WORK
         LD    R4,0(15)
         LD    R4+2,8(15)
*MEXIT #=   135 LV= 2 LX
*MCALL #=   136 LV= 2          TESTC LB,=LB'2'
*MCALL #=   137 LV= 3          STX   R4,WORK
         LA    15,WORK
         STD   R4,0(15)
         STD   R4+2,8(15)
*MEXIT #=   137 LV= 3 STX
         LA    R1,L'=LB'2'
         BCTR  R1,0
         EX    R1,*+4+4
         B     *+4+6
         CLC   WORK(0),=LB'2'  VERIFY CTD CONSTANT WITH CFD RESULT
*MCALL #=   138 LV= 3          RT1   CCE
         DS    0H
RT1_TEST25       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE25
         LTORG 
RT1_CCE25       DS 0H
*MEXIT #=   138 LV= 3 RT1
*MEXIT #=   136 LV= 2 TESTC
* TEST CFD OUT=(REG)
         LA    R2,WORK
*MCALL #=   139 LV= 2          CFD   CFD_LB,OUT=(R2),IN=DECIMAL
         DS    0H
         LA    1,=A(CFD_LB,(R2),DECIMAL)
         ST    R2,4(1)                 RPI 507
         SVC   171 CFD Z390 SVC R1=A(TYPE,OUT,IN)
*MEXIT #=   139 LV= 2 CFD
         LTR   R15,R15
         BNZ   ABORT
*MCALL #=   140 LV= 2          LX    R4,WORK
         LA    15,WORK
         LD    R4,0(15)
         LD    R4+2,8(15)
*MEXIT #=   140 LV= 2 LX
*MCALL #=   141 LV= 2          TESTC LB,=LB'2'
*MCALL #=   142 LV= 3          STX   R4,WORK
         LA    15,WORK
         STD   R4,0(15)
         STD   R4+2,8(15)
*MEXIT #=   142 LV= 3 STX
         LA    R1,L'=LB'2'
         BCTR  R1,0
         EX    R1,*+4+4
         B     *+4+6
         CLC   WORK(0),=LB'2'  VERIFY CTD CONSTANT WITH CFD RESULT
*MCALL #=   143 LV= 3          RT1   CCE
         DS    0H
RT1_TEST26       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE26
         LTORG 
RT1_CCE26       DS 0H
*MEXIT #=   143 LV= 3 RT1
*MEXIT #=   141 LV= 2 TESTC
* TEST CFD OUT-REG (VALUE 0-15)
*MCALL #=   144 LV= 2          CFD   CFD_LB,OUT=R4,IN=DECIMAL
         DS    0H
         LA    1,=A(CFD_LB,R4,DECIMAL)
         SVC   171 CFD Z390 SVC R1=A(TYPE,OUT,IN)
*MEXIT #=   144 LV= 2 CFD
         LTR   R15,R15
         BNZ   ABORT
*MCALL #=   145 LV= 2          TESTC LB,=LB'2'
*MCALL #=   146 LV= 3          STX   R4,WORK
         LA    15,WORK
         STD   R4,0(15)
         STD   R4+2,8(15)
*MEXIT #=   146 LV= 3 STX
         LA    R1,L'=LB'2'
         BCTR  R1,0
         EX    R1,*+4+4
         B     *+4+6
         CLC   WORK(0),=LB'2'  VERIFY CTD CONSTANT WITH CFD RESULT
*MCALL #=   147 LV= 3          RT1   CCE
         DS    0H
RT1_TEST27       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE27
         LTORG 
RT1_CCE27       DS 0H
*MEXIT #=   147 LV= 3 RT1
*MEXIT #=   145 LV= 2 TESTC
*MEXIT #=   133 LV= 1 TEST
*MCALL #=   148 LV= 1          TEST  DD,=CL45'2',=DD'2'
         BALR  R10,0                             RPI-786
         USING *,R10                             RPI-786
         MVC   DECIMAL,=CL45'2'
* TEST CFD OUT=RX
*MCALL #=   149 LV= 2          CFD   CFD_DD,OUT=WORK,IN=DECIMAL
         DS    0H
         LA    1,=A(CFD_DD,WORK,DECIMAL)
         SVC   171 CFD Z390 SVC R1=A(TYPE,OUT,IN)
*MEXIT #=   149 LV= 2 CFD
         LTR   R15,R15
         BNZ   ABORT
*MCALL #=   150 LV= 2          LX    R4,WORK
         LA    15,WORK
         LD    R4,0(15)
         LD    R4+2,8(15)
*MEXIT #=   150 LV= 2 LX
*MCALL #=   151 LV= 2          TESTC DD,=DD'2'
         LD    R0,=DD'2'
         CDTR  R0,R4
*MCALL #=   152 LV= 3          RT1   CCE
         DS    0H
RT1_TEST28       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE28
         LTORG 
RT1_CCE28       DS 0H
*MEXIT #=   152 LV= 3 RT1
*MEXIT #=   151 LV= 2 TESTC
* TEST CFD OUT=(REG)
         LA    R2,WORK
*MCALL #=   153 LV= 2          CFD   CFD_DD,OUT=(R2),IN=DECIMAL
         DS    0H
         LA    1,=A(CFD_DD,(R2),DECIMAL)
         ST    R2,4(1)                 RPI 507
         SVC   171 CFD Z390 SVC R1=A(TYPE,OUT,IN)
*MEXIT #=   153 LV= 2 CFD
         LTR   R15,R15
         BNZ   ABORT
*MCALL #=   154 LV= 2          LX    R4,WORK
         LA    15,WORK
         LD    R4,0(15)
         LD    R4+2,8(15)
*MEXIT #=   154 LV= 2 LX
*MCALL #=   155 LV= 2          TESTC DD,=DD'2'
         LD    R0,=DD'2'
         CDTR  R0,R4
*MCALL #=   156 LV= 3          RT1   CCE
         DS    0H
RT1_TEST29       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE29
         LTORG 
RT1_CCE29       DS 0H
*MEXIT #=   156 LV= 3 RT1
*MEXIT #=   155 LV= 2 TESTC
* TEST CFD OUT-REG (VALUE 0-15)
*MCALL #=   157 LV= 2          CFD   CFD_DD,OUT=R4,IN=DECIMAL
         DS    0H
         LA    1,=A(CFD_DD,R4,DECIMAL)
         SVC   171 CFD Z390 SVC R1=A(TYPE,OUT,IN)
*MEXIT #=   157 LV= 2 CFD
         LTR   R15,R15
         BNZ   ABORT
*MCALL #=   158 LV= 2          TESTC DD,=DD'2'
         LD    R0,=DD'2'
         CDTR  R0,R4
*MCALL #=   159 LV= 3          RT1   CCE
         DS    0H
RT1_TEST30       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE30
         LTORG 
RT1_CCE30       DS 0H
*MEXIT #=   159 LV= 3 RT1
*MEXIT #=   158 LV= 2 TESTC
*MEXIT #=   148 LV= 1 TEST
*MCALL #=   160 LV= 1          TEST  ED,=CL45'2',=ED'2'
         BALR  R10,0                             RPI-786
         USING *,R10                             RPI-786
         MVC   DECIMAL,=CL45'2'
* TEST CFD OUT=RX
*MCALL #=   161 LV= 2          CFD   CFD_ED,OUT=WORK,IN=DECIMAL
         DS    0H
         LA    1,=A(CFD_ED,WORK,DECIMAL)
         SVC   171 CFD Z390 SVC R1=A(TYPE,OUT,IN)
*MEXIT #=   161 LV= 2 CFD
         LTR   R15,R15
         BNZ   ABORT
*MCALL #=   162 LV= 2          LX    R4,WORK
         LA    15,WORK
         LD    R4,0(15)
         LD    R4+2,8(15)
*MEXIT #=   162 LV= 2 LX
*MCALL #=   163 LV= 2          TESTC ED,=ED'2'
         LE    R0,=ED'2'
         LDETR R0,R0,0
         LDETR R4,R4,0
         CDTR  R0,R4
*MCALL #=   164 LV= 3          RT1   CCE
         DS    0H
RT1_TEST31       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE31
         LTORG 
RT1_CCE31       DS 0H
*MEXIT #=   164 LV= 3 RT1
*MEXIT #=   163 LV= 2 TESTC
* TEST CFD OUT=(REG)
         LA    R2,WORK
*MCALL #=   165 LV= 2          CFD   CFD_ED,OUT=(R2),IN=DECIMAL
         DS    0H
         LA    1,=A(CFD_ED,(R2),DECIMAL)
         ST    R2,4(1)                 RPI 507
         SVC   171 CFD Z390 SVC R1=A(TYPE,OUT,IN)
*MEXIT #=   165 LV= 2 CFD
         LTR   R15,R15
         BNZ   ABORT
*MCALL #=   166 LV= 2          LX    R4,WORK
         LA    15,WORK
         LD    R4,0(15)
         LD    R4+2,8(15)
*MEXIT #=   166 LV= 2 LX
*MCALL #=   167 LV= 2          TESTC ED,=ED'2'
         LE    R0,=ED'2'
         LDETR R0,R0,0
         LDETR R4,R4,0
         CDTR  R0,R4
*MCALL #=   168 LV= 3          RT1   CCE
         DS    0H
RT1_TEST32       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE32
         LTORG 
RT1_CCE32       DS 0H
*MEXIT #=   168 LV= 3 RT1
*MEXIT #=   167 LV= 2 TESTC
* TEST CFD OUT-REG (VALUE 0-15)
*MCALL #=   169 LV= 2          CFD   CFD_ED,OUT=R4,IN=DECIMAL
         DS    0H
         LA    1,=A(CFD_ED,R4,DECIMAL)
         SVC   171 CFD Z390 SVC R1=A(TYPE,OUT,IN)
*MEXIT #=   169 LV= 2 CFD
         LTR   R15,R15
         BNZ   ABORT
*MCALL #=   170 LV= 2          TESTC ED,=ED'2'
         LE    R0,=ED'2'
         LDETR R0,R0,0
         LDETR R4,R4,0
         CDTR  R0,R4
*MCALL #=   171 LV= 3          RT1   CCE
         DS    0H
RT1_TEST33       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE33
         LTORG 
RT1_CCE33       DS 0H
*MEXIT #=   171 LV= 3 RT1
*MEXIT #=   170 LV= 2 TESTC
*MEXIT #=   160 LV= 1 TEST
*MCALL #=   172 LV= 1          TEST  LD,=CL45'2',=LD'2'
         BALR  R10,0                             RPI-786
         USING *,R10                             RPI-786
         MVC   DECIMAL,=CL45'2'
* TEST CFD OUT=RX
*MCALL #=   173 LV= 2          CFD   CFD_LD,OUT=WORK,IN=DECIMAL
         DS    0H
         LA    1,=A(CFD_LD,WORK,DECIMAL)
         SVC   171 CFD Z390 SVC R1=A(TYPE,OUT,IN)
*MEXIT #=   173 LV= 2 CFD
         LTR   R15,R15
         BNZ   ABORT
*MCALL #=   174 LV= 2          LX    R4,WORK
         LA    15,WORK
         LD    R4,0(15)
         LD    R4+2,8(15)
*MEXIT #=   174 LV= 2 LX
*MCALL #=   175 LV= 2          TESTC LD,=LD'2'
*MCALL #=   176 LV= 3          LX    R0,=LD'2'
         LA    15,=LD'2'
         LD    R0,0(15)
         LD    R0+2,8(15)
*MEXIT #=   176 LV= 3 LX
         CXTR  R0,R4
*MCALL #=   177 LV= 3          RT1   CCE
         DS    0H
RT1_TEST34       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE34
         LTORG 
RT1_CCE34       DS 0H
*MEXIT #=   177 LV= 3 RT1
*MEXIT #=   175 LV= 2 TESTC
* TEST CFD OUT=(REG)
         LA    R2,WORK
*MCALL #=   178 LV= 2          CFD   CFD_LD,OUT=(R2),IN=DECIMAL
         DS    0H
         LA    1,=A(CFD_LD,(R2),DECIMAL)
         ST    R2,4(1)                 RPI 507
         SVC   171 CFD Z390 SVC R1=A(TYPE,OUT,IN)
*MEXIT #=   178 LV= 2 CFD
         LTR   R15,R15
         BNZ   ABORT
*MCALL #=   179 LV= 2          LX    R4,WORK
         LA    15,WORK
         LD    R4,0(15)
         LD    R4+2,8(15)
*MEXIT #=   179 LV= 2 LX
*MCALL #=   180 LV= 2          TESTC LD,=LD'2'
*MCALL #=   181 LV= 3          LX    R0,=LD'2'
         LA    15,=LD'2'
         LD    R0,0(15)
         LD    R0+2,8(15)
*MEXIT #=   181 LV= 3 LX
         CXTR  R0,R4
*MCALL #=   182 LV= 3          RT1   CCE
         DS    0H
RT1_TEST35       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE35
         LTORG 
RT1_CCE35       DS 0H
*MEXIT #=   182 LV= 3 RT1
*MEXIT #=   180 LV= 2 TESTC
* TEST CFD OUT-REG (VALUE 0-15)
*MCALL #=   183 LV= 2          CFD   CFD_LD,OUT=R4,IN=DECIMAL
         DS    0H
         LA    1,=A(CFD_LD,R4,DECIMAL)
         SVC   171 CFD Z390 SVC R1=A(TYPE,OUT,IN)
*MEXIT #=   183 LV= 2 CFD
         LTR   R15,R15
         BNZ   ABORT
*MCALL #=   184 LV= 2          TESTC LD,=LD'2'
*MCALL #=   185 LV= 3          LX    R0,=LD'2'
         LA    15,=LD'2'
         LD    R0,0(15)
         LD    R0+2,8(15)
*MEXIT #=   185 LV= 3 LX
         CXTR  R0,R4
*MCALL #=   186 LV= 3          RT1   CCE
         DS    0H
RT1_TEST36       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE36
         LTORG 
RT1_CCE36       DS 0H
*MEXIT #=   186 LV= 3 RT1
*MEXIT #=   184 LV= 2 TESTC
*MEXIT #=   172 LV= 1 TEST
*MCALL #=   187 LV= 1          RT1   END
         B      RT1_END
*MEXIT #=   187 LV= 1 RT1
*MCALL #=   188 LV= 1          EQUREGS REGS=FPR
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
*MEXIT #=   188 LV= 1 EQUREGS
         END 
