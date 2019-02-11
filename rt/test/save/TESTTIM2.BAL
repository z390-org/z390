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
* 2006-03-03 DSH RPI-209 Test STIMER WAIT                           *
* 2006-04-22 DSH RPI-279 Add STIMER REAL,EXIT and TTIMER tests      *
* 2006-08-06 DSH RPI-396 Increase time to 8 seconds to allow        *
*                        2 seconds CPU time                         *
* 2006-09-19 DSH RPI-452 TTIMER cancel requires TU or MIC,ADDR      *
* 2006-09-22 DSH RPI-461 Use CCGE/CCLE for interval tests to        *
*                        prevent intermittent failures dependung on *
*                        system load                                *
*********************************************************************
         TITLE 'TESTTIM1 REGRSSION TEST STIMER, TIMIER FUNCTIONS'
*MCALL #=     1 LV= 1 TESTIM2  RT1   MAIN
*MCALL #=     2 LV= 2 TESTIM2  SUBENTRY 
TESTIM2  CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTIM2'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTIM2+8,13
*MEXIT #=     2 LV= 2 SUBENTRY
*MCALL #=     3 LV= 2          WTO   'TESTIM2 RT1 STARTED'
         BRAS  1,*+(WTO#0003_EOT-*+1)/2*2
         DC    AL2(WTO#0003_EOT-*,0),C'TESTIM2 RT1 STARTED'
WTO#0003_EOT     EQU *
         SVC   35
*MEXIT #=     3 LV= 2 WTO
         BRCL    15,RT1_START
RT1_ABORT DS 0H
         MVI   RT1_ABORTED,C'T'
*MCALL #=     4 LV= 2          WTO   'TESTIM2 RT1 TESTING ABORTED'
         BRAS  1,*+(WTO#0004_EOT-*+1)/2*2
         DC    AL2(WTO#0004_EOT-*,0),C'TESTIM2 RT1 TESTING ABORTED'
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
*MCALL #=     6 LV= 2          WTO   'TESTIM2 RT1 ENDED OK'
         BRAS  1,*+(WTO#0006_EOT-*+1)/2*2
         DC    AL2(WTO#0006_EOT-*,0),C'TESTIM2 RT1 ENDED OK'
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
RT1_WTO1 DC    AL2(RT1_WTO_END-*,0),C'TESTIM2 RT1 TESTS COMPLETED = '
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
BINTVL   DC    F'200'           200 * 0.01
DINTVL   DC    PL8'200'         HHMMSSTH
MICVL    DC    FL8'2000000'     2   * 1000000
TUINTVL  DC    F'0'             2000000 / 26.04166
STARTED  DC    FL8'0'
ENDED    DC    FL8'0'
MICS_REMAINING DS D             MICS REMAINING IN STIMER INTERVAL
MICS_SAVE      DS D
SEXIT    EQU   *         STIMER EXIT ROUTINE
         USING *,15
*MCALL #=     9 LV= 1          POST  ECB,0 POST ECB WITH X'40000000'
         LA    1,ECB
         L     0,=A(0)
         SVC   2 POST R0=CODE, R1=A(ECB)
*MEXIT #=     9 LV= 1 POST
         BR    14
         DROP  15
ECB      DC    F'0'
*MCALL #=    10 LV= 1          EQUREGS 
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
*MEXIT #=    10 LV= 1 EQUREGS
*MCALL #=    11 LV= 1          RT1   START
RT1_START DS  0H
*MEXIT #=    11 LV= 1 RT1
* STIMER WAIT TEST
*MCALL #=    12 LV= 1          WTO    'TEST STIMER WAIT 2 SEC BINTVL'
         BRAS  1,*+(WTO#0012_EOT-*+1)/2*2
         DC    AL2(WTO#0012_EOT-*,0),C'TEST STIMER WAIT 2 SEC BINTVL'
WTO#0012_EOT     EQU *
         SVC   35
*MEXIT #=    12 LV= 1 WTO
*MCALL #=    13 LV= 1          TIME   NS,STARTED
         LA    0,8 NANOSECONDS - DOUBLE WORD BIT 63 NANO-SEC COUNTER
         LA    1,STARTED
         SVC   11 TIME AND DATE
*MEXIT #=    13 LV= 1 TIME
*MCALL #=    14 LV= 1          STIMER WAIT,BINTVL=BINTVL
        IIHF  0,X'01010000' WAIT BINTVL
        LA    1,BINTVL
        SVC   X'2F' STIMER R0B0=TYPE,R0B1=INT, R0=EXIT, R1=INTVL ARG
*MEXIT #=    14 LV= 1 STIMER
*MCALL #=    15 LV= 1          TIME   NS,ENDED
         LA    0,8 NANOSECONDS - DOUBLE WORD BIT 63 NANO-SEC COUNTER
         LA    1,ENDED
         SVC   11 TIME AND DATE
*MEXIT #=    15 LV= 1 TIME
         LG     R3,ENDED
         SG     R3,STARTED
         DSG    R2,=FL8'1000000'
         CLG    R3,=FL8'1500'
*MCALL #=    16 LV= 1          RT1    CCH
         DS    0H
RT1_TEST1        BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1
         LTORG 
RT1_CCH1        DS 0H
*MEXIT #=    16 LV= 1 RT1
         CLG    R3,=FL8'15000' ALLOW 15 SEC
*MCALL #=    17 LV= 1          RT1    CCL
         DS    0H
RT1_TEST2        BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL2
         LTORG 
RT1_CCL2        DS 0H
*MEXIT #=    17 LV= 1 RT1
*MCALL #=    18 LV= 1          WTO    'TEST STIMER WAIT 2 SEC DINTVL'
         BRAS  1,*+(WTO#0018_EOT-*+1)/2*2
         DC    AL2(WTO#0018_EOT-*,0),C'TEST STIMER WAIT 2 SEC DINTVL'
WTO#0018_EOT     EQU *
         SVC   35
*MEXIT #=    18 LV= 1 WTO
*MCALL #=    19 LV= 1          TIME   NS,STARTED
         LA    0,8 NANOSECONDS - DOUBLE WORD BIT 63 NANO-SEC COUNTER
         LA    1,STARTED
         SVC   11 TIME AND DATE
*MEXIT #=    19 LV= 1 TIME
*MCALL #=    20 LV= 1          STIMER WAIT,DINTVL=DINTVL
        IIHF  0,X'01020000' WAIT DINTVL
        LA    1,DINTVL
        SVC   X'2F' STIMER R0B0=TYPE,R0B1=INT, R0=EXIT, R1=INTVL ARG
*MEXIT #=    20 LV= 1 STIMER
*MCALL #=    21 LV= 1          TIME   NS,ENDED
         LA    0,8 NANOSECONDS - DOUBLE WORD BIT 63 NANO-SEC COUNTER
         LA    1,ENDED
         SVC   11 TIME AND DATE
*MEXIT #=    21 LV= 1 TIME
         LG     R3,ENDED
         SG     R3,STARTED
         DSG    R2,=FL8'1000000'
         CLG    R3,=FL8'1500'
*MCALL #=    22 LV= 1          RT1    CCH
         DS    0H
RT1_TEST3        BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH3
         LTORG 
RT1_CCH3        DS 0H
*MEXIT #=    22 LV= 1 RT1
         CLG    R3,=FL8'15000' ALLOW 15 SEC
*MCALL #=    23 LV= 1          RT1    CCL
         DS    0H
RT1_TEST4        BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL4
         LTORG 
RT1_CCL4        DS 0H
*MEXIT #=    23 LV= 1 RT1
*MCALL #=    24 LV= 1          WTO    'TEST STIMER WAIT 2 SEC MICVL'
         BRAS  1,*+(WTO#0024_EOT-*+1)/2*2
         DC    AL2(WTO#0024_EOT-*,0),C'TEST STIMER WAIT 2 SEC MICVL'
WTO#0024_EOT     EQU *
         SVC   35
*MEXIT #=    24 LV= 1 WTO
*MCALL #=    25 LV= 1          TIME   NS,STARTED
         LA    0,8 NANOSECONDS - DOUBLE WORD BIT 63 NANO-SEC COUNTER
         LA    1,STARTED
         SVC   11 TIME AND DATE
*MEXIT #=    25 LV= 1 TIME
*MCALL #=    26 LV= 1          STIMER WAIT,MICVL=MICVL
        IIHF  0,X'01030000' WAIT MICVL
        LA    1,MICVL
        SVC   X'2F' STIMER R0B0=TYPE,R0B1=INT, R0=EXIT, R1=INTVL ARG
*MEXIT #=    26 LV= 1 STIMER
*MCALL #=    27 LV= 1          TIME   NS,ENDED
         LA    0,8 NANOSECONDS - DOUBLE WORD BIT 63 NANO-SEC COUNTER
         LA    1,ENDED
         SVC   11 TIME AND DATE
*MEXIT #=    27 LV= 1 TIME
         LG     R3,ENDED
         SG     R3,STARTED
         DSG    R2,=FL8'1000000'
         CLG    R3,=FL8'1500'
*MCALL #=    28 LV= 1          RT1    CCH
         DS    0H
RT1_TEST5        BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH5
         LTORG 
RT1_CCH5        DS 0H
*MEXIT #=    28 LV= 1 RT1
         CLG    R3,=FL8'15000' ALLOW 15 SEC
*MCALL #=    29 LV= 1          RT1    CCL
         DS    0H
RT1_TEST6        BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL6
         LTORG 
RT1_CCL6        DS 0H
*MEXIT #=    29 LV= 1 RT1
         LG     R1,=FL8'2000000' R0 = 2 SEC IN MICROSECONDS
         MSG    R1,=FL8'100000'  SCALE UP 5 DECIMAL PLACES
         DSG    R0,=FL8'2604166'  DIVIDE BY TIMER UNITS WITH 5 DEC
         ST     R1,TUINTVL        R0=REMAINDER, R1=QUOTENT
*MCALL #=    30 LV= 1          WTO    'TEST STIMER WAIT 2 SEC TUINTVL'
         BRAS  1,*+(WTO#0030_EOT-*+1)/2*2
         DC    AL2(WTO#0030_EOT-*,0),C'TEST STIMER WAIT 2 SEC TUINTVL'
WTO#0030_EOT     EQU *
         SVC   35
*MEXIT #=    30 LV= 1 WTO
*MCALL #=    31 LV= 1          TIME   NS,STARTED
         LA    0,8 NANOSECONDS - DOUBLE WORD BIT 63 NANO-SEC COUNTER
         LA    1,STARTED
         SVC   11 TIME AND DATE
*MEXIT #=    31 LV= 1 TIME
*MCALL #=    32 LV= 1          STIMER WAIT,TUINTVL=TUINTVL
        IIHF  0,X'01040000' WAIT TUINTVL
        LA    1,TUINTVL
        SVC   X'2F' STIMER R0B0=TYPE,R0B1=INT, R0=EXIT, R1=INTVL ARG
*MEXIT #=    32 LV= 1 STIMER
*MCALL #=    33 LV= 1          TIME   NS,ENDED
         LA    0,8 NANOSECONDS - DOUBLE WORD BIT 63 NANO-SEC COUNTER
         LA    1,ENDED
         SVC   11 TIME AND DATE
*MEXIT #=    33 LV= 1 TIME
         LG     R3,ENDED
         SG     R3,STARTED
         DSG    R2,=FL8'1000000'
         CLG    R3,=FL8'1500'
*MCALL #=    34 LV= 1          RT1    CCH
         DS    0H
RT1_TEST7        BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH7
         LTORG 
RT1_CCH7        DS 0H
*MEXIT #=    34 LV= 1 RT1
         CLG    R3,=FL8'15000' ALLOW 15 SEC
*MCALL #=    35 LV= 1          RT1    CCL
         DS    0H
RT1_TEST8        BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL8
         LTORG 
RT1_CCL8        DS 0H
*MEXIT #=    35 LV= 1 RT1
* STIMER REAL,EXIT TEST USING WAIT AND POST
*MCALL #=    36 LV= 1          TIME   NS,STARTED
         LA    0,8 NANOSECONDS - DOUBLE WORD BIT 63 NANO-SEC COUNTER
         LA    1,STARTED
         SVC   11 TIME AND DATE
*MEXIT #=    36 LV= 1 TIME
         MVC    ECB,=X'00000000' CLEAR ECB WAITING
*MCALL #=    37 LV= 1          STIMER REAL,SEXIT,BINTVL==F'200' EXIT TOX
                SEXIT IN 2 SEC
        LA    0,SEXIT       REAL EXIT
        IIHF  0,X'02010000' REAL BINTVL
        LA    1,=F'200'
        SVC   X'2F' STIMER R0B0=TYPE,R0B1=INT, R0=EXIT, R1=INTVL ARG
*MEXIT #=    37 LV= 1 STIMER
*MCALL #=    38 LV= 1          WTO    'STIMER REAL INTERVAL SET FOR WAIX
               T AND POST TEST'
         BRAS  1,*+(WTO#0038_EOT-*+1)/2*2
         DC    AL2(WTO#0038_EOT-*,0),C'STIMER REAL INTERVAL SET FOR WAIX
               T AND POST TEST'
WTO#0038_EOT     EQU *
         SVC   35
*MEXIT #=    38 LV= 1 WTO
*MCALL #=    39 LV= 1          WAIT   ECB=ECB    WAIT FOR STIMER EXIT TX
               O POST ECB
         SR    0,0
         LA    1,ECB
         SVC   1 (R0=0,R1=A(ECB) OR (R0=NUM,R1=ECBLIST)
*MEXIT #=    39 LV= 1 WAIT
*MCALL #=    40 LV= 1          TIME   NS,ENDED
         LA    0,8 NANOSECONDS - DOUBLE WORD BIT 63 NANO-SEC COUNTER
         LA    1,ENDED
         SVC   11 TIME AND DATE
*MEXIT #=    40 LV= 1 TIME
         LG     R3,ENDED
         SG     R3,STARTED
         DSG    R2,=FL8'1000000'
         CLG    R3,=FL8'1500'
*MCALL #=    41 LV= 1          RT1    CCH
         DS    0H
RT1_TEST9        BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH9
         LTORG 
RT1_CCH9        DS 0H
*MEXIT #=    41 LV= 1 RT1
         CLG    R3,=FL8'15000' ALLOW 15 SECONDS TO GET 2 SEC CPU
*MCALL #=    42 LV= 1          RT1    CCL
         DS    0H
RT1_TEST10       BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL10
         LTORG 
RT1_CCL10       DS 0H
*MEXIT #=    42 LV= 1 RT1
* STIMER REAL,EXIT TEST USING WAIT AND CPU LOOP
         MVC    ECB,=X'00000000' CLEAR ECB WAITING
*MCALL #=    43 LV= 1          TIME   NS,STARTED
         LA    0,8 NANOSECONDS - DOUBLE WORD BIT 63 NANO-SEC COUNTER
         LA    1,STARTED
         SVC   11 TIME AND DATE
*MEXIT #=    43 LV= 1 TIME
*MCALL #=    44 LV= 1          STIMER REAL,SEXIT,BINTVL==F'200' EXIT TOX
                SEXIT IN 2 SEC
        LA    0,SEXIT       REAL EXIT
        IIHF  0,X'02010000' REAL BINTVL
        LA    1,=F'200'
        SVC   X'2F' STIMER R0B0=TYPE,R0B1=INT, R0=EXIT, R1=INTVL ARG
*MEXIT #=    44 LV= 1 STIMER
*MCALL #=    45 LV= 1          WTO    'STIMER REAL INTERVAL SET FOR CPUX
                LOOP TEST'
         BRAS  1,*+(WTO#0045_EOT-*+1)/2*2
         DC    AL2(WTO#0045_EOT-*,0),C'STIMER REAL INTERVAL SET FOR CPUX
                LOOP TEST'
WTO#0045_EOT     EQU *
         SVC   35
*MEXIT #=    45 LV= 1 WTO
LOOP     CLI    ECB,X'40' LOOP UNTIL STIMER EXIT POSTS ECB
         BNE    LOOP
*MCALL #=    46 LV= 1          TIME   NS,ENDED
         LA    0,8 NANOSECONDS - DOUBLE WORD BIT 63 NANO-SEC COUNTER
         LA    1,ENDED
         SVC   11 TIME AND DATE
*MEXIT #=    46 LV= 1 TIME
         LG     R3,ENDED
         SG     R3,STARTED
         DSG    R2,=FL8'1000000'
         CLG    R3,=FL8'1500'
*MCALL #=    47 LV= 1          RT1    CCH
         DS    0H
RT1_TEST11       BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH11
         LTORG 
RT1_CCH11       DS 0H
*MEXIT #=    47 LV= 1 RT1
         CLG    R3,=FL8'15000' ALLOW 15 SEC
*MCALL #=    48 LV= 1          RT1    CCL
         DS    0H
RT1_TEST12       BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL12
         LTORG 
RT1_CCL12       DS 0H
*MEXIT #=    48 LV= 1 RT1
* STIMER REAL,EXIT TEST TIMER TU AND MIC
         MVC    ECB,=X'00000000' CLEAR ECB WAITING
*MCALL #=    49 LV= 1          TIME   NS,STARTED
         LA    0,8 NANOSECONDS - DOUBLE WORD BIT 63 NANO-SEC COUNTER
         LA    1,STARTED
         SVC   11 TIME AND DATE
*MEXIT #=    49 LV= 1 TIME
*MCALL #=    50 LV= 1          STIMER REAL,SEXIT,BINTVL==F'200' EXIT TOX
                SEXIT IN 2 SEC
        LA    0,SEXIT       REAL EXIT
        IIHF  0,X'02010000' REAL BINTVL
        LA    1,=F'200'
        SVC   X'2F' STIMER R0B0=TYPE,R0B1=INT, R0=EXIT, R1=INTVL ARG
*MEXIT #=    50 LV= 1 STIMER
*MCALL #=    51 LV= 1          TTIMER ,TU
         LA    0,B'00' NO CANCEL, TU
         SVC   X'2E' TTIMER (R0 BIT0=MIC BIT1=CAN, R1=A(MIC ADDR)
*MEXIT #=    51 LV= 1 TTIMER
         LTR    R15,R15
*MCALL #=    52 LV= 1          RT1    CCE
         DS    0H
RT1_TEST13       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE13
         LTORG 
RT1_CCE13       DS 0H
*MEXIT #=    52 LV= 1 RT1
         LR     R3,R0
*MCALL #=    53 LV= 1          WTO    'STIMER REAL INTERVAL SET FOR TTIX
               MER ,TU TEST'
         BRAS  1,*+(WTO#0053_EOT-*+1)/2*2
         DC    AL2(WTO#0053_EOT-*,0),C'STIMER REAL INTERVAL SET FOR TTIX
               MER ,TU TEST'
WTO#0053_EOT     EQU *
         SVC   35
*MEXIT #=    53 LV= 1 WTO
*MCALL #=    54 LV= 1          STIMER WAIT,TUINTVL==F'50'
        IIHF  0,X'01040000' WAIT TUINTVL
        LA    1,=F'50'
        SVC   X'2F' STIMER R0B0=TYPE,R0B1=INT, R0=EXIT, R1=INTVL ARG
*MEXIT #=    54 LV= 1 STIMER
*MCALL #=    55 LV= 1          TTIMER ,TU
         LA    0,B'00' NO CANCEL, TU
         SVC   X'2E' TTIMER (R0 BIT0=MIC BIT1=CAN, R1=A(MIC ADDR)
*MEXIT #=    55 LV= 1 TTIMER
         LTR    R15,R15
*MCALL #=    56 LV= 1          RT1    CCE
         DS    0H
RT1_TEST14       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE14
         LTORG 
RT1_CCE14       DS 0H
*MEXIT #=    56 LV= 1 RT1
         CLR    R0,R3
*MCALL #=    57 LV= 1          RT1    CCLE  RPI 461
         DS    0H
RT1_TEST15       BAS   RT1_LINK,RT1_TEST_CCLE
         USING *,RT1_LINK
         B     RT1_CCLE15
         LTORG 
RT1_CCLE15       DS 0H
*MEXIT #=    57 LV= 1 RT1
*MCALL #=    58 LV= 1          TTIMER ,MIC,MICS_REMAINING
         LA    0,B'01' NO CANCEL, MIC
         LA    1,MICS_REMAINING
         SVC   X'2E' TTIMER (R0 BIT0=MIC BIT1=CAN, R1=A(MIC ADDR)
*MEXIT #=    58 LV= 1 TTIMER
         LTR    R15,R15
*MCALL #=    59 LV= 1          RT1    CCE
         DS    0H
RT1_TEST16       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE16
         LTORG 
RT1_CCE16       DS 0H
*MEXIT #=    59 LV= 1 RT1
         MVC    MICS_SAVE,MICS_REMAINING
*MCALL #=    60 LV= 1          WTO    'STIMER REAL INTERVAL SET FOR TTIX
               MER ,MIC,ADDR'
         BRAS  1,*+(WTO#0060_EOT-*+1)/2*2
         DC    AL2(WTO#0060_EOT-*,0),C'STIMER REAL INTERVAL SET FOR TTIX
               MER ,MIC,ADDR'
WTO#0060_EOT     EQU *
         SVC   35
*MEXIT #=    60 LV= 1 WTO
*MCALL #=    61 LV= 1          STIMER WAIT,TUINTVL==F'50'
        IIHF  0,X'01040000' WAIT TUINTVL
        LA    1,=F'50'
        SVC   X'2F' STIMER R0B0=TYPE,R0B1=INT, R0=EXIT, R1=INTVL ARG
*MEXIT #=    61 LV= 1 STIMER
*MCALL #=    62 LV= 1          TTIMER ,MIC,MICS_REMAINING
         LA    0,B'01' NO CANCEL, MIC
         LA    1,MICS_REMAINING
         SVC   X'2E' TTIMER (R0 BIT0=MIC BIT1=CAN, R1=A(MIC ADDR)
*MEXIT #=    62 LV= 1 TTIMER
         LTR    R15,R15
*MCALL #=    63 LV= 1          RT1    CCE
         DS    0H
RT1_TEST17       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE17
         LTORG 
RT1_CCE17       DS 0H
*MEXIT #=    63 LV= 1 RT1
         CLC    MICS_REMAINING,MICS_SAVE
*MCALL #=    64 LV= 1          RT1    CCLE       RPI 461
         DS    0H
RT1_TEST18       BAS   RT1_LINK,RT1_TEST_CCLE
         USING *,RT1_LINK
         B     RT1_CCLE18
         LTORG 
RT1_CCLE18       DS 0H
*MEXIT #=    64 LV= 1 RT1
*MCALL #=    65 LV= 1          WAIT   ECB=ECB    WAIT FOR STIMER EXIT TX
               O POST ECB
         SR    0,0
         LA    1,ECB
         SVC   1 (R0=0,R1=A(ECB) OR (R0=NUM,R1=ECBLIST)
*MEXIT #=    65 LV= 1 WAIT
*MCALL #=    66 LV= 1          TIME   NS,ENDED
         LA    0,8 NANOSECONDS - DOUBLE WORD BIT 63 NANO-SEC COUNTER
         LA    1,ENDED
         SVC   11 TIME AND DATE
*MEXIT #=    66 LV= 1 TIME
         LG     R3,ENDED
         SG     R3,STARTED
         DSG    R2,=FL8'1000000'
         CLG    R3,=FL8'1500'
*MCALL #=    67 LV= 1          RT1    CCH
         DS    0H
RT1_TEST19       BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH19
         LTORG 
RT1_CCH19       DS 0H
*MEXIT #=    67 LV= 1 RT1
         CLG    R3,=FL8'15000' ALLOW 15 SECONDS TO GET 2 SEC CPU
*MCALL #=    68 LV= 1          RT1    CCL
         DS    0H
RT1_TEST20       BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL20
         LTORG 
RT1_CCL20       DS 0H
*MEXIT #=    68 LV= 1 RT1
* STIMER REAL,EXIT TEST STIMER AND TTIMER CANCEL
         MVC    ECB,=X'00000000' CLEAR ECB WAITING
*MCALL #=    69 LV= 1          TIME   NS,STARTED
         LA    0,8 NANOSECONDS - DOUBLE WORD BIT 63 NANO-SEC COUNTER
         LA    1,STARTED
         SVC   11 TIME AND DATE
*MEXIT #=    69 LV= 1 TIME
*MCALL #=    70 LV= 1          STIMER REAL,SEXIT,BINTVL==F'200' EXIT TOX
                SEXIT IN 2 SEC
        LA    0,SEXIT       REAL EXIT
        IIHF  0,X'02010000' REAL BINTVL
        LA    1,=F'200'
        SVC   X'2F' STIMER R0B0=TYPE,R0B1=INT, R0=EXIT, R1=INTVL ARG
*MEXIT #=    70 LV= 1 STIMER
*MCALL #=    71 LV= 1          WTO    'STIMER REAL INTERVAL SET AND THEX
               N CANCELLED'
         BRAS  1,*+(WTO#0071_EOT-*+1)/2*2
         DC    AL2(WTO#0071_EOT-*,0),C'STIMER REAL INTERVAL SET AND THEX
               N CANCELLED'
WTO#0071_EOT     EQU *
         SVC   35
*MEXIT #=    71 LV= 1 WTO
*MCALL #=    72 LV= 1          STIMER WAIT,TUINTVL==F'50'
        IIHF  0,X'01040000' WAIT TUINTVL
        LA    1,=F'50'
        SVC   X'2F' STIMER R0B0=TYPE,R0B1=INT, R0=EXIT, R1=INTVL ARG
*MEXIT #=    72 LV= 1 STIMER
*MCALL #=    73 LV= 1          TTIMER CANCEL,TU
         LA    0,B'10' CANCEL, TU
         SVC   X'2E' TTIMER (R0 BIT0=MIC BIT1=CAN, R1=A(MIC ADDR)
*MEXIT #=    73 LV= 1 TTIMER
*MCALL #=    74 LV= 1          TIME   NS,ENDED
         LA    0,8 NANOSECONDS - DOUBLE WORD BIT 63 NANO-SEC COUNTER
         LA    1,ENDED
         SVC   11 TIME AND DATE
*MEXIT #=    74 LV= 1 TIME
         LG     R3,ENDED
         SG     R3,STARTED
         DSG    R2,=FL8'1000000'
         CLG    R3,=FL8'1500'
*MCALL #=    75 LV= 1          RT1    CCL
         DS    0H
RT1_TEST21       BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL21
         LTORG 
RT1_CCL21       DS 0H
*MEXIT #=    75 LV= 1 RT1
*MCALL #=    76 LV= 1          WTO   'TESTTIM2 ENDED OK'
         BRAS  1,*+(WTO#0076_EOT-*+1)/2*2
         DC    AL2(WTO#0076_EOT-*,0),C'TESTTIM2 ENDED OK'
WTO#0076_EOT     EQU *
         SVC   35
*MEXIT #=    76 LV= 1 WTO
*MCALL #=    77 LV= 1          RT1   END
         B      RT1_END
*MEXIT #=    77 LV= 1 RT1
         END 
