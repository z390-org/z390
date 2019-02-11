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
* 2005-11-02 DSH RPI-68  Add CLOCK=STCK, CLOCK=STCKE, CLOCK=JAVA    *
*                        extensions                                 *
* 2007-02-07 DSH RPI-532 Shorten STCKF clock compare to 16 bits     *
*********************************************************************
         TITLE 'TESTTIM1 REGRSSION TEST TIME MACRO FUNCTIONS'
*
* Note: This regression test requires ez390 be run with NOTIMING
*       option in order for time stamp to be forced to
*       22:33:44:567 2005.002
*
*MCALL #=     1 LV= 1 TESTIM1  RT1   MAIN
*MCALL #=     2 LV= 2 TESTIM1  SUBENTRY 
TESTIM1  CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTIM1'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTIM1+8,13
*MEXIT #=     2 LV= 2 SUBENTRY
*MCALL #=     3 LV= 2          WTO   'TESTIM1 RT1 STARTED'
         BRAS  1,*+(WTO#0003_EOT-*+1)/2*2
         DC    AL2(WTO#0003_EOT-*,0),C'TESTIM1 RT1 STARTED'
WTO#0003_EOT     EQU *
         SVC   35
*MEXIT #=     3 LV= 2 WTO
         BRCL    15,RT1_START
RT1_ABORT DS 0H
         MVI   RT1_ABORTED,C'T'
*MCALL #=     4 LV= 2          WTO   'TESTIM1 RT1 TESTING ABORTED'
         BRAS  1,*+(WTO#0004_EOT-*+1)/2*2
         DC    AL2(WTO#0004_EOT-*,0),C'TESTIM1 RT1 TESTING ABORTED'
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
*MCALL #=     6 LV= 2          WTO   'TESTIM1 RT1 ENDED OK'
         BRAS  1,*+(WTO#0006_EOT-*+1)/2*2
         DC    AL2(WTO#0006_EOT-*,0),C'TESTIM1 RT1 ENDED OK'
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
RT1_WTO1 DC    AL2(RT1_WTO_END-*,0),C'TESTIM1 RT1 TESTS COMPLETED = '
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
PWORK    DC    XL8'FF'
WORK8    DC    XL8'FF'
WORK16   DC    XL16'FF'
CLOCK    DC    XL16'00'
IBM_INC  DC    XL8'0000020250EB7B80'  MICROSECONDS FROM 1900 TO 1970
WTOMSG1  DC    0F'0',AL2(MSG1END-*,0)
         DC    C' TIME ='
TIMEDATE DC    X'402120',C':',X'2020',C':',X'2020',C':',X'2020'
         DC    C'  DATE = '
         DC    X'20202020',C'.',X'202020'
MSG1END  EQU   *
*
* TIME CONSTANTS WHEN RUNNING EZ390 WITH OPTION NOTIMING
*
SVC_DATE   EQU X'0105002F'                DATE CCYYDDDF
SYS_DATE   EQU X'02005002'                DATE 0YYYYDDD
TOD_DEC    EQU X'22334456'                TOD  HHMMSSTH
TOD_BIN    EQU ((22*60+33)*60+44)*100+56  TOD  0.01 SEC
TOD_MIC    DC  XL8'00'                    TOD  MIC
TOD_TU     DC  F'0'                       TOD  26.04166 MIC UNITS
TOD_STCK   DC  XL8'00'                    TOD  BIT 51   MIC
TOD_STCKE  DC  XL16'00'                   TOD  BIT 59   MIC
*MCALL #=    10 LV= 1          RT1   START
RT1_START DS  0H
*MEXIT #=    10 LV= 1 RT1
*
* INITIALIZE CALCULATED TOD CONSTANTS USING NOTIMING DEFAULT TIME
*
         LG    R3,=AL8(TOD_BIN)
         MSGF  R3,=A(10)           R3 = MILLISECONDS
         AG    R3,=FL8'7'
         MSGF  R3,=F'1000'         R3 = MICROSECONDS
         STG   R3,TOD_MIC        SET TOD IN MICROSECONDS
         MSGF  R3,=F'100000'       R3 =  MIC SCALED UP FOR INT DIV
         DSGF  R2,=F'2604166'      DIV MICS BY 26.04166
         ST    R3,TOD_TU         SET TOD IN TIMER UNITS
         LG    R3,TOD_MIC
         SLLG  R2,R3,(63-51)          MAKE BIT 51 MICROSECONDS
         STG   R2,TOD_STCK       SET TOD IN STCK CLOCK UNITS
         LG    R3,TOD_MIC        SET TOD IN TIMER UNITS
         SLLG  R2,R3,(63-59)          MAKE BIT 59 MICROSECONDS
         STG   R2,TOD_STCKE      SET TOD IN STCK CLOCK UNITS
* SVC DEC
*MCALL #=    11 LV= 1          TIME  DEC
         LA    0,0   DEC  R0 = HEX HHMMSSTH
         SVC   11 TIME AND DATE
*MEXIT #=    11 LV= 1 TIME
         STM   R0,R1,PWORK
*MCALL #=    12 LV= 1          RT1   CCE,PWORK(4),=A(TOD_DEC)
         DS    0H
         CLC   PWORK(4),=A(TOD_DEC)
RT1_TEST1        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1
         LTORG 
RT1_CCE1        DS 0H
*MEXIT #=    12 LV= 1 RT1
*MCALL #=    13 LV= 1          RT1   CCE,PWORK+4(4),=A(SVC_DATE)
         DS    0H
         CLC   PWORK+4(4),=A(SVC_DATE)
RT1_TEST2        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE2
         LTORG 
RT1_CCE2        DS 0H
*MEXIT #=    13 LV= 1 RT1
         MVI   PWORK+4,X'20'  CHANGE CC TO 20
         ED    TIMEDATE(MSG1END-TIMEDATE),PWORK
*MCALL #=    14 LV= 1          WTO   MF=(E,WTOMSG1)
         LA    1,WTOMSG1
         SVC   35
*MEXIT #=    14 LV= 1 WTO
* SVC BIN
*MCALL #=    15 LV= 1          TIME  BIN
         LA    0,1   BIN  R0 = 0.01 SECONDS
         SVC   11 TIME AND DATE
*MEXIT #=    15 LV= 1 TIME
         STM   R0,R1,PWORK
*MCALL #=    16 LV= 1          RT1   CCE,PWORK(4),=A(TOD_BIN)
         DS    0H
         CLC   PWORK(4),=A(TOD_BIN)
RT1_TEST3        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE3
         LTORG 
RT1_CCE3        DS 0H
*MEXIT #=    16 LV= 1 RT1
*MCALL #=    17 LV= 1          RT1   CCE,PWORK+4(4),=A(SVC_DATE)
         DS    0H
         CLC   PWORK+4(4),=A(SVC_DATE)
RT1_TEST4        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE4
         LTORG 
RT1_CCE4        DS 0H
*MEXIT #=    17 LV= 1 RT1
* SVC TU
*MCALL #=    18 LV= 1          TIME  TU
         LA    0,2   TU   R0 = 26.04166 MIC UNITS
         SVC   11 TIME AND DATE
*MEXIT #=    18 LV= 1 TIME
         STM   R0,R1,PWORK
*MCALL #=    19 LV= 1          RT1   CCE,PWORK(4),TOD_TU
         DS    0H
         CLC   PWORK(4),TOD_TU
RT1_TEST5        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE5
         LTORG 
RT1_CCE5        DS 0H
*MEXIT #=    19 LV= 1 RT1
*MCALL #=    20 LV= 1          RT1   CCE,PWORK+4(4),=A(SVC_DATE)
         DS    0H
         CLC   PWORK+4(4),=A(SVC_DATE)
RT1_TEST6        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE6
         LTORG 
RT1_CCE6        DS 0H
*MEXIT #=    20 LV= 1 RT1
* SVC MIC
*MCALL #=    21 LV= 1          TIME  MIC,WORK8
         LA    0,3   MIC  0(8,R1) = DOUBLE WORD MICROSECONDS
         LA    1,WORK8
         SVC   11 TIME AND DATE
*MEXIT #=    21 LV= 1 TIME
         LG    R2,WORK8
         LG    R3,TOD_MIC
         STM   R0,R1,PWORK
*MCALL #=    22 LV= 1          RT1   CCE,WORK8,TOD_MIC
         DS    0H
         CLC   WORK8,TOD_MIC
RT1_TEST7        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE7
         LTORG 
RT1_CCE7        DS 0H
*MEXIT #=    22 LV= 1 RT1
*MCALL #=    23 LV= 1          RT1   CCE,PWORK+4(4),=A(SVC_DATE)
         DS    0H
         CLC   PWORK+4(4),=A(SVC_DATE)
RT1_TEST8        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE8
         LTORG 
RT1_CCE8        DS 0H
*MEXIT #=    23 LV= 1 RT1
* SVC STCK
*MCALL #=    24 LV= 1          TIME  STCK,WORK8
         LA    0,4   STCK 0(8,R1) = TOD DOUBLE WORD (BIT 51=MIC)
         LA    1,WORK8
         SVC   11 TIME AND DATE
*MEXIT #=    24 LV= 1 TIME
         STM   R0,R1,PWORK
*MCALL #=    25 LV= 1          RT1   CCE,WORK8,TOD_STCK
         DS    0H
         CLC   WORK8,TOD_STCK
RT1_TEST9        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE9
         LTORG 
RT1_CCE9        DS 0H
*MEXIT #=    25 LV= 1 RT1
*MCALL #=    26 LV= 1          RT1   CCE,PWORK+4(4),=A(SVC_DATE)
         DS    0H
         CLC   PWORK+4(4),=A(SVC_DATE)
RT1_TEST10       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE10
         LTORG 
RT1_CCE10       DS 0H
*MEXIT #=    26 LV= 1 RT1
* SYS DEC
*MCALL #=    27 LV= 1          TIME  DEC,WORK16,LINKAGE=SYSTEM
         LA    0,10   DEC   0(4,R1) = HHMMSSTH
         LA    1,WORK16
         IILH  0,1      8(4,R1) = HEX 0YYYYDDD
         SVC   11 TIME AND DATE
*MEXIT #=    27 LV= 1 TIME
*MCALL #=    28 LV= 1          RT1   CCE,WORK16(4),=A(TOD_DEC)
         DS    0H
         CLC   WORK16(4),=A(TOD_DEC)
RT1_TEST11       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE11
         LTORG 
RT1_CCE11       DS 0H
*MEXIT #=    28 LV= 1 RT1
*MCALL #=    29 LV= 1          RT1   CCE,WORK16+8(4),=A(SYS_DATE)
         DS    0H
         CLC   WORK16+8(4),=A(SYS_DATE)
RT1_TEST12       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE12
         LTORG 
RT1_CCE12       DS 0H
*MEXIT #=    29 LV= 1 RT1
* SYS BIN
*MCALL #=    30 LV= 1          TIME  BIN,WORK16,LINKAGE=SYSTEM
         LA    0,11   BIN   0(4,R1) = 0.01 SECONDS
         LA    1,WORK16
         IILH  0,1      8(4,R1) = HEX 0YYYYDDD
         SVC   11 TIME AND DATE
*MEXIT #=    30 LV= 1 TIME
*MCALL #=    31 LV= 1          RT1   CCE,WORK16(4),=A(TOD_BIN)
         DS    0H
         CLC   WORK16(4),=A(TOD_BIN)
RT1_TEST13       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE13
         LTORG 
RT1_CCE13       DS 0H
*MEXIT #=    31 LV= 1 RT1
*MCALL #=    32 LV= 1          RT1   CCE,WORK16+8(4),=A(SYS_DATE)
         DS    0H
         CLC   WORK16+8(4),=A(SYS_DATE)
RT1_TEST14       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE14
         LTORG 
RT1_CCE14       DS 0H
*MEXIT #=    32 LV= 1 RT1
* SYS MIC
*MCALL #=    33 LV= 1          TIME  MIC,WORK16,LINKAGE=SYSTEM
         LA    0,13  MIC    0(8,R1) = MICROSECONDS
         LA    1,WORK16
         IILH  0,1      8(4,R1) = HEX 0YYYYDDD
         SVC   11 TIME AND DATE
*MEXIT #=    33 LV= 1 TIME
*MCALL #=    34 LV= 1          RT1   CCE,WORK16(8),TOD_MIC
         DS    0H
         CLC   WORK16(8),TOD_MIC
RT1_TEST15       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE15
         LTORG 
RT1_CCE15       DS 0H
*MEXIT #=    34 LV= 1 RT1
*MCALL #=    35 LV= 1          RT1   CCE,WORK16+8(4),=A(SYS_DATE)
         DS    0H
         CLC   WORK16+8(4),=A(SYS_DATE)
RT1_TEST16       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE16
         LTORG 
RT1_CCE16       DS 0H
*MEXIT #=    35 LV= 1 RT1
* SYS STCK
*MCALL #=    36 LV= 1          TIME  STCK,WORK16,LINKAGE=SYSTEM
         LA    0,14   STCK  0(8,R1) = CLOCK (BIT 51 = MIC)
         LA    1,WORK16
         IILH  0,1      8(4,R1) = HEX 0YYYYDDD
         SVC   11 TIME AND DATE
*MEXIT #=    36 LV= 1 TIME
*MCALL #=    37 LV= 1          RT1   CCE,WORK16(8),TOD_STCK
         DS    0H
         CLC   WORK16(8),TOD_STCK
RT1_TEST17       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE17
         LTORG 
RT1_CCE17       DS 0H
*MEXIT #=    37 LV= 1 RT1
*MCALL #=    38 LV= 1          RT1   CCE,WORK16+8(4),=A(SYS_DATE)
         DS    0H
         CLC   WORK16+8(4),=A(SYS_DATE)
RT1_TEST18       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE18
         LTORG 
RT1_CCE18       DS 0H
*MEXIT #=    38 LV= 1 RT1
* SYS STCKE
*MCALL #=    39 LV= 1          TIME  STCKE,WORK16,LINKAGE=SYSTEM
         LA    0,15   SKCKE 0(16,R1) = ECLOCK (BIT 59 = MIC)
         LA    1,WORK16
         SVC   11 TIME AND DATE
*MEXIT #=    39 LV= 1 TIME
*MCALL #=    40 LV= 1          RT1   CCE,WORK16,TOD_STCKE
         DS    0H
         CLC   WORK16,TOD_STCKE
RT1_TEST19       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE19
         LTORG 
RT1_CCE19       DS 0H
*MEXIT #=    40 LV= 1 RT1
* SYS ALTERNATE DATE TYPES
*MCALL #=    41 LV= 1          TIME  DEC,WORK16,LINKAGE=SYSTEM,DATETYPEX
               =YYYYDDD
         LA    0,10   DEC   0(4,R1) = HHMMSSTH
         LA    1,WORK16
         IILH  0,1      8(4,R1) = HEX 0YYYYDDD
         SVC   11 TIME AND DATE
*MEXIT #=    41 LV= 1 TIME
*MCALL #=    42 LV= 1          RT1   CCE,WORK16+8(4),=A(SYS_DATE)
         DS    0H
         CLC   WORK16+8(4),=A(SYS_DATE)
RT1_TEST20       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE20
         LTORG 
RT1_CCE20       DS 0H
*MEXIT #=    42 LV= 1 RT1
*MCALL #=    43 LV= 1          TIME  DEC,WORK16,LINKAGE=SYSTEM,DATETYPEX
               =MMDDYYYY
         LA    0,10   DEC   0(4,R1) = HHMMSSTH
         LA    1,WORK16
         IILH  0,2      8(4,R1) = HEX MMDDYYYY
         SVC   11 TIME AND DATE
*MEXIT #=    43 LV= 1 TIME
*MCALL #=    44 LV= 1          RT1   CCE,WORK16+8(4),=X'01022005'
         DS    0H
         CLC   WORK16+8(4),=X'01022005'
RT1_TEST21       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE21
         LTORG 
RT1_CCE21       DS 0H
*MEXIT #=    44 LV= 1 RT1
*MCALL #=    45 LV= 1          TIME  DEC,WORK16,LINKAGE=SYSTEM,DATETYPEX
               =DDMMYYYY
         LA    0,10   DEC   0(4,R1) = HHMMSSTH
         LA    1,WORK16
         IILH  0,3      8(4,R1) = HEX DDMMYYYY
         SVC   11 TIME AND DATE
*MEXIT #=    45 LV= 1 TIME
*MCALL #=    46 LV= 1          RT1   CCE,WORK16+8(4),=X'02012005'
         DS    0H
         CLC   WORK16+8(4),=X'02012005'
RT1_TEST22       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE22
         LTORG 
RT1_CCE22       DS 0H
*MEXIT #=    46 LV= 1 RT1
*MCALL #=    47 LV= 1          TIME  DEC,WORK16,LINKAGE=SYSTEM,DATETYPEX
               =YYYYMMDD
         LA    0,10   DEC   0(4,R1) = HHMMSSTH
         LA    1,WORK16
         IILH  0,4      8(4,R1) = HEX YYYYMMDD
         SVC   11 TIME AND DATE
*MEXIT #=    47 LV= 1 TIME
*MCALL #=    48 LV= 1          RT1   CCE,WORK16+8(4),=X'20050102'
         DS    0H
         CLC   WORK16+8(4),=X'20050102'
RT1_TEST23       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE23
         LTORG 
RT1_CCE23       DS 0H
*MEXIT #=    48 LV= 1 RT1
* CLOCK=STCK   DOUBLE WORD WITH BIT 51 = MICROSECONDS FROM 1900
*MCALL #=    49 LV= 1          TIME  CLOCK,WORK16,CLOCKTYPE=STCK
         LA    0,5 CLOCK STCK - DOUBLE WORD BIT 51 MICS FROM 1900
         LA    1,WORK16
         SVC   11 TIME AND DATE
*MEXIT #=    49 LV= 1 TIME
         STCKF CLOCK
*MCALL #=    50 LV= 1          RT1   CCE,WORK16(2),CLOCK
         DS    0H
         CLC   WORK16(2),CLOCK
RT1_TEST24       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE24
         LTORG 
RT1_CCE24       DS 0H
*MEXIT #=    50 LV= 1 RT1
* CLOCK=STCKE  2 DOUBLE WORDS WITH BIT 59 = MICROSECONDS FROM 1900
*MCALL #=    51 LV= 1          TIME  CLOCK,WORK16,CLOCKTYPE=STCKE
         LA    0,6 CLOCK STCKE - 2 DOUBLE WORDS BIT 59 MICS FROM 1900
         LA    1,WORK16
         SVC   11 TIME AND DATE
*MEXIT #=    51 LV= 1 TIME
         STCKE CLOCK
*MCALL #=    52 LV= 1          RT1   CCE,WORK16(2),CLOCK
         DS    0H
         CLC   WORK16(2),CLOCK
RT1_TEST25       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE25
         LTORG 
RT1_CCE25       DS 0H
*MEXIT #=    52 LV= 1 RT1
* CLOCK=JAVA   DOUBLE WORD WITH BIT 63 = MICROSECONDS FROM 1970
*MCALL #=    53 LV= 1          TIME  CLOCK,WORK16,CLOCKTYPE=JAVA
         LA    0,7 CLOCK JAVA - DOUBLE WORD BIT 63 MILL-SEC FROM 1970
         LA    1,WORK16
         SVC   11 TIME AND DATE
*MEXIT #=    53 LV= 1 TIME
         LG    R0,WORK16
         AG    R0,IBM_INC   CVT JAVA TO IBM EPOCH
         MSGF  R0,=F'1000'
         SLLG  R0,R0,(63-51)
         STG   R0,WORK16
         STCKF CLOCK
*MCALL #=    54 LV= 1          RT1   CCE,WORK16(2),CLOCK
         DS    0H
         CLC   WORK16(2),CLOCK
RT1_TEST26       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE26
         LTORG 
RT1_CCE26       DS 0H
*MEXIT #=    54 LV= 1 RT1
*MCALL #=    55 LV= 1          WTO   'TESTTIM1 ENDED OK'
         BRAS  1,*+(WTO#0055_EOT-*+1)/2*2
         DC    AL2(WTO#0055_EOT-*,0),C'TESTTIM1 ENDED OK'
WTO#0055_EOT     EQU *
         SVC   35
*MEXIT #=    55 LV= 1 WTO
*MCALL #=    56 LV= 1          RT1   END
         B      RT1_END
*MEXIT #=    56 LV= 1 RT1
         END 
