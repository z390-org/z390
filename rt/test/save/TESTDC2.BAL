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
* 2008 11-18 DSH         Initial version                            *
* 2006-11-18 DSH RPI-417 Test bit length fields                     *
* 2008-11-10 DSH RPI-946 Test for initialization value X'F6' in DS  *
*                        fields                                     *
*********************************************************************
         PRINT DATA
*MCALL #=     1 LV= 1 TESTDC1  RT1   MAIN
*MCALL #=     2 LV= 2 TESTDC1  SUBENTRY 
TESTDC1  CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTDC1'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTDC1+8,13
*MEXIT #=     2 LV= 2 SUBENTRY
*MCALL #=     3 LV= 2          WTO   'TESTDC1 RT1 STARTED'
         BRAS  1,*+(WTO#0003_EOT-*+1)/2*2
         DC    AL2(WTO#0003_EOT-*,0),C'TESTDC1 RT1 STARTED'
WTO#0003_EOT     EQU *
         SVC   35
*MEXIT #=     3 LV= 2 WTO
         BRCL    15,RT1_START
RT1_ABORT DS 0H
         MVI   RT1_ABORTED,C'T'
*MCALL #=     4 LV= 2          WTO   'TESTDC1 RT1 TESTING ABORTED'
         BRAS  1,*+(WTO#0004_EOT-*+1)/2*2
         DC    AL2(WTO#0004_EOT-*,0),C'TESTDC1 RT1 TESTING ABORTED'
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
*MCALL #=     6 LV= 2          WTO   'TESTDC1 RT1 ENDED OK'
         BRAS  1,*+(WTO#0006_EOT-*+1)/2*2
         DC    AL2(WTO#0006_EOT-*,0),C'TESTDC1 RT1 ENDED OK'
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
RT1_WTO1 DC    AL2(RT1_WTO_END-*,0),C'TESTDC1 RT1 TESTS COMPLETED = '
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
DCZ      DC    0XL256,256X'F6' RPI 946
DATA     LOCTR 
CODE     LOCTR 
*MCALL #=     9 LV= 1          RT1   START
RT1_START DS  0H
*MEXIT #=     9 LV= 1 RT1
         MACRO
         TEST  &D=,&V=,&L=
         GBLA  &N
&N       SETA  &N+1
DATA     LOCTR
&TD      SETC  '&D'(2,K'&D-2)
&TV      SETC  '&V'(2,K'&V-2)
DCT&N    DC    &TD
DCV&N    DC    &TV
DST&N    DS    &TD
CODE     LOCTR
         RT1   CCE,DCT&N,DCV&N
         RT1   CCE,DST&N,DCZ
         RT1   CCE,=AL1(L'DCT&N),=AL1(&L)
         MEND
*MCALL #=    10 LV= 1          TEST  L=1,D=(AL.4(1)),V=(X'10')
DATA     LOCTR 
DCT1     DC    AL.4(1)
DCV1     DC    X'10'
DST1     DS    AL.4(1)
CODE     LOCTR 
*MCALL #=    11 LV= 2          RT1   CCE,DCT1,DCV1
         DS    0H
         CLC   DCT1,DCV1
RT1_TEST1        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1
         LTORG 
RT1_CCE1        DS 0H
*MEXIT #=    11 LV= 2 RT1
*MCALL #=    12 LV= 2          RT1   CCE,DST1,DCZ
         DS    0H
         CLC   DST1,DCZ
RT1_TEST2        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE2
         LTORG 
RT1_CCE2        DS 0H
*MEXIT #=    12 LV= 2 RT1
*MCALL #=    13 LV= 2          RT1   CCE,=AL1(L'DCT1),=AL1(1)
         DS    0H
         CLC   =AL1(L'DCT1),=AL1(1)
RT1_TEST3        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE3
         LTORG 
RT1_CCE3        DS 0H
*MEXIT #=    13 LV= 2 RT1
*MEXIT #=    10 LV= 1 TEST
*MCALL #=    14 LV= 1          TEST  L=1,D=(AL.4(1,2)),V=(X'12')
DATA     LOCTR 
DCT2     DC    AL.4(1,2)
DCV2     DC    X'12'
DST2     DS    AL.4(1,2)
CODE     LOCTR 
*MCALL #=    15 LV= 2          RT1   CCE,DCT2,DCV2
         DS    0H
         CLC   DCT2,DCV2
RT1_TEST4        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE4
         LTORG 
RT1_CCE4        DS 0H
*MEXIT #=    15 LV= 2 RT1
*MCALL #=    16 LV= 2          RT1   CCE,DST2,DCZ
         DS    0H
         CLC   DST2,DCZ
RT1_TEST5        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE5
         LTORG 
RT1_CCE5        DS 0H
*MEXIT #=    16 LV= 2 RT1
*MCALL #=    17 LV= 2          RT1   CCE,=AL1(L'DCT2),=AL1(1)
         DS    0H
         CLC   =AL1(L'DCT2),=AL1(1)
RT1_TEST6        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE6
         LTORG 
RT1_CCE6        DS 0H
*MEXIT #=    17 LV= 2 RT1
*MEXIT #=    14 LV= 1 TEST
*MCALL #=    18 LV= 1          TEST  L=1,D=(AL.4(1,2,3)),V=(X'1230')
DATA     LOCTR 
DCT3     DC    AL.4(1,2,3)
DCV3     DC    X'1230'
DST3     DS    AL.4(1,2,3)
CODE     LOCTR 
*MCALL #=    19 LV= 2          RT1   CCE,DCT3,DCV3
         DS    0H
         CLC   DCT3,DCV3
RT1_TEST7        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE7
         LTORG 
RT1_CCE7        DS 0H
*MEXIT #=    19 LV= 2 RT1
*MCALL #=    20 LV= 2          RT1   CCE,DST3,DCZ
         DS    0H
         CLC   DST3,DCZ
RT1_TEST8        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE8
         LTORG 
RT1_CCE8        DS 0H
*MEXIT #=    20 LV= 2 RT1
*MCALL #=    21 LV= 2          RT1   CCE,=AL1(L'DCT3),=AL1(1)
         DS    0H
         CLC   =AL1(L'DCT3),=AL1(1)
RT1_TEST9        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE9
         LTORG 
RT1_CCE9        DS 0H
*MEXIT #=    21 LV= 2 RT1
*MEXIT #=    18 LV= 1 TEST
*MCALL #=    22 LV= 1          TEST  L=2,D=(AL.12(x'123')),V=(X'1230')
DATA     LOCTR 
DCT4     DC    AL.12(x'123')
DCV4     DC    X'1230'
DST4     DS    AL.12(x'123')
CODE     LOCTR 
*MCALL #=    23 LV= 2          RT1   CCE,DCT4,DCV4
         DS    0H
         CLC   DCT4,DCV4
RT1_TEST10       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE10
         LTORG 
RT1_CCE10       DS 0H
*MEXIT #=    23 LV= 2 RT1
*MCALL #=    24 LV= 2          RT1   CCE,DST4,DCZ
         DS    0H
         CLC   DST4,DCZ
RT1_TEST11       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE11
         LTORG 
RT1_CCE11       DS 0H
*MEXIT #=    24 LV= 2 RT1
*MCALL #=    25 LV= 2          RT1   CCE,=AL1(L'DCT4),=AL1(2)
         DS    0H
         CLC   =AL1(L'DCT4),=AL1(2)
RT1_TEST12       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE12
         LTORG 
RT1_CCE12       DS 0H
*MEXIT #=    25 LV= 2 RT1
*MEXIT #=    22 LV= 1 TEST
*MCALL #=    26 LV= 1          TEST  L=1,D=(BL.4'1'),V=(X'10')
DATA     LOCTR 
DCT5     DC    BL.4'1'
DCV5     DC    X'10'
DST5     DS    BL.4'1'
CODE     LOCTR 
*MCALL #=    27 LV= 2          RT1   CCE,DCT5,DCV5
         DS    0H
         CLC   DCT5,DCV5
RT1_TEST13       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE13
         LTORG 
RT1_CCE13       DS 0H
*MEXIT #=    27 LV= 2 RT1
*MCALL #=    28 LV= 2          RT1   CCE,DST5,DCZ
         DS    0H
         CLC   DST5,DCZ
RT1_TEST14       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE14
         LTORG 
RT1_CCE14       DS 0H
*MEXIT #=    28 LV= 2 RT1
*MCALL #=    29 LV= 2          RT1   CCE,=AL1(L'DCT5),=AL1(1)
         DS    0H
         CLC   =AL1(L'DCT5),=AL1(1)
RT1_TEST15       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE15
         LTORG 
RT1_CCE15       DS 0H
*MEXIT #=    29 LV= 2 RT1
*MEXIT #=    26 LV= 1 TEST
*MCALL #=    30 LV= 1          TEST  L=1,D=(BL.4'1,10'),V=(X'12')
DATA     LOCTR 
DCT6     DC    BL.4'1,10'
DCV6     DC    X'12'
DST6     DS    BL.4'1,10'
CODE     LOCTR 
*MCALL #=    31 LV= 2          RT1   CCE,DCT6,DCV6
         DS    0H
         CLC   DCT6,DCV6
RT1_TEST16       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE16
         LTORG 
RT1_CCE16       DS 0H
*MEXIT #=    31 LV= 2 RT1
*MCALL #=    32 LV= 2          RT1   CCE,DST6,DCZ
         DS    0H
         CLC   DST6,DCZ
RT1_TEST17       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE17
         LTORG 
RT1_CCE17       DS 0H
*MEXIT #=    32 LV= 2 RT1
*MCALL #=    33 LV= 2          RT1   CCE,=AL1(L'DCT6),=AL1(1)
         DS    0H
         CLC   =AL1(L'DCT6),=AL1(1)
RT1_TEST18       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE18
         LTORG 
RT1_CCE18       DS 0H
*MEXIT #=    33 LV= 2 RT1
*MEXIT #=    30 LV= 1 TEST
*MCALL #=    34 LV= 1          TEST  L=1,D=(BL.4'1,10,11'),V=(X'1230')
DATA     LOCTR 
DCT7     DC    BL.4'1,10,11'
DCV7     DC    X'1230'
DST7     DS    BL.4'1,10,11'
CODE     LOCTR 
*MCALL #=    35 LV= 2          RT1   CCE,DCT7,DCV7
         DS    0H
         CLC   DCT7,DCV7
RT1_TEST19       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE19
         LTORG 
RT1_CCE19       DS 0H
*MEXIT #=    35 LV= 2 RT1
*MCALL #=    36 LV= 2          RT1   CCE,DST7,DCZ
         DS    0H
         CLC   DST7,DCZ
RT1_TEST20       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE20
         LTORG 
RT1_CCE20       DS 0H
*MEXIT #=    36 LV= 2 RT1
*MCALL #=    37 LV= 2          RT1   CCE,=AL1(L'DCT7),=AL1(1)
         DS    0H
         CLC   =AL1(L'DCT7),=AL1(1)
RT1_TEST21       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE21
         LTORG 
RT1_CCE21       DS 0H
*MEXIT #=    37 LV= 2 RT1
*MEXIT #=    34 LV= 1 TEST
*MCALL #=    38 LV= 1          TEST  L=2,D=(BL.12'000100100011'),V=(X'1X
               230')
DATA     LOCTR 
DCT8     DC    BL.12'000100100011'
DCV8     DC    X'1230'
DST8     DS    BL.12'000100100011'
CODE     LOCTR 
*MCALL #=    39 LV= 2          RT1   CCE,DCT8,DCV8
         DS    0H
         CLC   DCT8,DCV8
RT1_TEST22       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE22
         LTORG 
RT1_CCE22       DS 0H
*MEXIT #=    39 LV= 2 RT1
*MCALL #=    40 LV= 2          RT1   CCE,DST8,DCZ
         DS    0H
         CLC   DST8,DCZ
RT1_TEST23       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE23
         LTORG 
RT1_CCE23       DS 0H
*MEXIT #=    40 LV= 2 RT1
*MCALL #=    41 LV= 2          RT1   CCE,=AL1(L'DCT8),=AL1(2)
         DS    0H
         CLC   =AL1(L'DCT8),=AL1(2)
RT1_TEST24       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE24
         LTORG 
RT1_CCE24       DS 0H
*MEXIT #=    41 LV= 2 RT1
*MEXIT #=    38 LV= 1 TEST
*MCALL #=    42 LV= 1          TEST  L=1,D=(AL.4(1,2,3),BL.4'100,101,11X
               0'),V=(X'123456')
DATA     LOCTR 
DCT9     DC    AL.4(1,2,3),BL.4'100,101,110'
DCV9     DC    X'123456'
DST9     DS    AL.4(1,2,3),BL.4'100,101,110'
CODE     LOCTR 
*MCALL #=    43 LV= 2          RT1   CCE,DCT9,DCV9
         DS    0H
         CLC   DCT9,DCV9
RT1_TEST25       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE25
         LTORG 
RT1_CCE25       DS 0H
*MEXIT #=    43 LV= 2 RT1
*MCALL #=    44 LV= 2          RT1   CCE,DST9,DCZ
         DS    0H
         CLC   DST9,DCZ
RT1_TEST26       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE26
         LTORG 
RT1_CCE26       DS 0H
*MEXIT #=    44 LV= 2 RT1
*MCALL #=    45 LV= 2          RT1   CCE,=AL1(L'DCT9),=AL1(1)
         DS    0H
         CLC   =AL1(L'DCT9),=AL1(1)
RT1_TEST27       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE27
         LTORG 
RT1_CCE27       DS 0H
*MEXIT #=    45 LV= 2 RT1
*MEXIT #=    42 LV= 1 TEST
*MCALL #=    46 LV= 1          TEST  L=2,D=(CL.16'AB'),V=(C'AB')
DATA     LOCTR 
DCT10    DC    CL.16'AB'
DCV10    DC    C'AB'
DST10    DS    CL.16'AB'
CODE     LOCTR 
*MCALL #=    47 LV= 2          RT1   CCE,DCT10,DCV10
         DS    0H
         CLC   DCT10,DCV10
RT1_TEST28       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE28
         LTORG 
RT1_CCE28       DS 0H
*MEXIT #=    47 LV= 2 RT1
*MCALL #=    48 LV= 2          RT1   CCE,DST10,DCZ
         DS    0H
         CLC   DST10,DCZ
RT1_TEST29       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE29
         LTORG 
RT1_CCE29       DS 0H
*MEXIT #=    48 LV= 2 RT1
*MCALL #=    49 LV= 2          RT1   CCE,=AL1(L'DCT10),=AL1(2)
         DS    0H
         CLC   =AL1(L'DCT10),=AL1(2)
RT1_TEST30       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE30
         LTORG 
RT1_CCE30       DS 0H
*MEXIT #=    49 LV= 2 RT1
*MEXIT #=    46 LV= 1 TEST
*MCALL #=    50 LV= 1          TEST  L=2,D=(CL.16'A'),V=(X'C140')
DATA     LOCTR 
DCT11    DC    CL.16'A'
DCV11    DC    X'C140'
DST11    DS    CL.16'A'
CODE     LOCTR 
*MCALL #=    51 LV= 2          RT1   CCE,DCT11,DCV11
         DS    0H
         CLC   DCT11,DCV11
RT1_TEST31       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE31
         LTORG 
RT1_CCE31       DS 0H
*MEXIT #=    51 LV= 2 RT1
*MCALL #=    52 LV= 2          RT1   CCE,DST11,DCZ
         DS    0H
         CLC   DST11,DCZ
RT1_TEST32       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE32
         LTORG 
RT1_CCE32       DS 0H
*MEXIT #=    52 LV= 2 RT1
*MCALL #=    53 LV= 2          RT1   CCE,=AL1(L'DCT11),=AL1(2)
         DS    0H
         CLC   =AL1(L'DCT11),=AL1(2)
RT1_TEST33       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE33
         LTORG 
RT1_CCE33       DS 0H
*MEXIT #=    53 LV= 2 RT1
*MEXIT #=    50 LV= 1 TEST
*MCALL #=    54 LV= 1          TEST  L=2,D=(CAL.16'A'),V=(X'4120')
DATA     LOCTR 
DCT12    DC    CAL.16'A'
DCV12    DC    X'4120'
DST12    DS    CAL.16'A'
CODE     LOCTR 
*MCALL #=    55 LV= 2          RT1   CCE,DCT12,DCV12
         DS    0H
         CLC   DCT12,DCV12
RT1_TEST34       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE34
         LTORG 
RT1_CCE34       DS 0H
*MEXIT #=    55 LV= 2 RT1
*MCALL #=    56 LV= 2          RT1   CCE,DST12,DCZ
         DS    0H
         CLC   DST12,DCZ
RT1_TEST35       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE35
         LTORG 
RT1_CCE35       DS 0H
*MEXIT #=    56 LV= 2 RT1
*MCALL #=    57 LV= 2          RT1   CCE,=AL1(L'DCT12),=AL1(2)
         DS    0H
         CLC   =AL1(L'DCT12),=AL1(2)
RT1_TEST36       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE36
         LTORG 
RT1_CCE36       DS 0H
*MEXIT #=    57 LV= 2 RT1
*MEXIT #=    54 LV= 1 TEST
*MCALL #=    58 LV= 1          TEST  L=2,D=(CL.16'AB'),V=(C'AB')
DATA     LOCTR 
DCT13    DC    CL.16'AB'
DCV13    DC    C'AB'
DST13    DS    CL.16'AB'
CODE     LOCTR 
*MCALL #=    59 LV= 2          RT1   CCE,DCT13,DCV13
         DS    0H
         CLC   DCT13,DCV13
RT1_TEST37       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE37
         LTORG 
RT1_CCE37       DS 0H
*MEXIT #=    59 LV= 2 RT1
*MCALL #=    60 LV= 2          RT1   CCE,DST13,DCZ
         DS    0H
         CLC   DST13,DCZ
RT1_TEST38       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE38
         LTORG 
RT1_CCE38       DS 0H
*MEXIT #=    60 LV= 2 RT1
*MCALL #=    61 LV= 2          RT1   CCE,=AL1(L'DCT13),=AL1(2)
         DS    0H
         CLC   =AL1(L'DCT13),=AL1(2)
RT1_TEST39       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE39
         LTORG 
RT1_CCE39       DS 0H
*MEXIT #=    61 LV= 2 RT1
*MEXIT #=    58 LV= 1 TEST
*MCALL #=    62 LV= 1          TEST  L=2,D=(CL.12'AB',CL.4'1'),V=(X'C1CX
               F')
DATA     LOCTR 
DCT14    DC    CL.12'AB',CL.4'1'
DCV14    DC    X'C1CF'
DST14    DS    CL.12'AB',CL.4'1'
CODE     LOCTR 
*MCALL #=    63 LV= 2          RT1   CCE,DCT14,DCV14
         DS    0H
         CLC   DCT14,DCV14
RT1_TEST40       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE40
         LTORG 
RT1_CCE40       DS 0H
*MEXIT #=    63 LV= 2 RT1
*MCALL #=    64 LV= 2          RT1   CCE,DST14,DCZ
         DS    0H
         CLC   DST14,DCZ
RT1_TEST41       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE41
         LTORG 
RT1_CCE41       DS 0H
*MEXIT #=    64 LV= 2 RT1
*MCALL #=    65 LV= 2          RT1   CCE,=AL1(L'DCT14),=AL1(2)
         DS    0H
         CLC   =AL1(L'DCT14),=AL1(2)
RT1_TEST42       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE42
         LTORG 
RT1_CCE42       DS 0H
*MEXIT #=    65 LV= 2 RT1
*MEXIT #=    62 LV= 1 TEST
*MCALL #=    66 LV= 1          TEST  L=2,D=(DBL.16'1'),V=(X'3FF0')
DATA     LOCTR 
DCT15    DC    DBL.16'1'
DCV15    DC    X'3FF0'
DST15    DS    DBL.16'1'
CODE     LOCTR 
*MCALL #=    67 LV= 2          RT1   CCE,DCT15,DCV15
         DS    0H
         CLC   DCT15,DCV15
RT1_TEST43       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE43
         LTORG 
RT1_CCE43       DS 0H
*MEXIT #=    67 LV= 2 RT1
*MCALL #=    68 LV= 2          RT1   CCE,DST15,DCZ
         DS    0H
         CLC   DST15,DCZ
RT1_TEST44       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE44
         LTORG 
RT1_CCE44       DS 0H
*MEXIT #=    68 LV= 2 RT1
*MCALL #=    69 LV= 2          RT1   CCE,=AL1(L'DCT15),=AL1(2)
         DS    0H
         CLC   =AL1(L'DCT15),=AL1(2)
RT1_TEST45       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE45
         LTORG 
RT1_CCE45       DS 0H
*MEXIT #=    69 LV= 2 RT1
*MEXIT #=    66 LV= 1 TEST
*MCALL #=    70 LV= 1          TEST  L=2,D=(EBL.16'1'),V=(X'3F80')
DATA     LOCTR 
DCT16    DC    EBL.16'1'
DCV16    DC    X'3F80'
DST16    DS    EBL.16'1'
CODE     LOCTR 
*MCALL #=    71 LV= 2          RT1   CCE,DCT16,DCV16
         DS    0H
         CLC   DCT16,DCV16
RT1_TEST46       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE46
         LTORG 
RT1_CCE46       DS 0H
*MEXIT #=    71 LV= 2 RT1
*MCALL #=    72 LV= 2          RT1   CCE,DST16,DCZ
         DS    0H
         CLC   DST16,DCZ
RT1_TEST47       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE47
         LTORG 
RT1_CCE47       DS 0H
*MEXIT #=    72 LV= 2 RT1
*MCALL #=    73 LV= 2          RT1   CCE,=AL1(L'DCT16),=AL1(2)
         DS    0H
         CLC   =AL1(L'DCT16),=AL1(2)
RT1_TEST48       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE48
         LTORG 
RT1_CCE48       DS 0H
*MEXIT #=    73 LV= 2 RT1
*MEXIT #=    70 LV= 1 TEST
*MCALL #=    74 LV= 1          TEST  L=2,D=(LBL.16'1'),V=(X'3FFF')
DATA     LOCTR 
DCT17    DC    LBL.16'1'
DCV17    DC    X'3FFF'
DST17    DS    LBL.16'1'
CODE     LOCTR 
*MCALL #=    75 LV= 2          RT1   CCE,DCT17,DCV17
         DS    0H
         CLC   DCT17,DCV17
RT1_TEST49       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE49
         LTORG 
RT1_CCE49       DS 0H
*MEXIT #=    75 LV= 2 RT1
*MCALL #=    76 LV= 2          RT1   CCE,DST17,DCZ
         DS    0H
         CLC   DST17,DCZ
RT1_TEST50       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE50
         LTORG 
RT1_CCE50       DS 0H
*MEXIT #=    76 LV= 2 RT1
*MCALL #=    77 LV= 2          RT1   CCE,=AL1(L'DCT17),=AL1(2)
         DS    0H
         CLC   =AL1(L'DCT17),=AL1(2)
RT1_TEST51       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE51
         LTORG 
RT1_CCE51       DS 0H
*MEXIT #=    77 LV= 2 RT1
*MEXIT #=    74 LV= 1 TEST
*MCALL #=    78 LV= 1          TEST  L=1,D=(FL.4'1,2,3,4'),V=(X'1234')
DATA     LOCTR 
DCT18    DC    FL.4'1,2,3,4'
DCV18    DC    X'1234'
DST18    DS    FL.4'1,2,3,4'
CODE     LOCTR 
*MCALL #=    79 LV= 2          RT1   CCE,DCT18,DCV18
         DS    0H
         CLC   DCT18,DCV18
RT1_TEST52       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE52
         LTORG 
RT1_CCE52       DS 0H
*MEXIT #=    79 LV= 2 RT1
*MCALL #=    80 LV= 2          RT1   CCE,DST18,DCZ
         DS    0H
         CLC   DST18,DCZ
RT1_TEST53       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE53
         LTORG 
RT1_CCE53       DS 0H
*MEXIT #=    80 LV= 2 RT1
*MCALL #=    81 LV= 2          RT1   CCE,=AL1(L'DCT18),=AL1(1)
         DS    0H
         CLC   =AL1(L'DCT18),=AL1(1)
RT1_TEST54       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE54
         LTORG 
RT1_CCE54       DS 0H
*MEXIT #=    81 LV= 2 RT1
*MEXIT #=    78 LV= 1 TEST
*MCALL #=    82 LV= 1          TEST  L=1,D=(FL.4'-1,-2,-3,-4'),V=(X'FEDX
               C')
DATA     LOCTR 
DCT19    DC    FL.4'-1,-2,-3,-4'
DCV19    DC    X'FEDC'
DST19    DS    FL.4'-1,-2,-3,-4'
CODE     LOCTR 
*MCALL #=    83 LV= 2          RT1   CCE,DCT19,DCV19
         DS    0H
         CLC   DCT19,DCV19
RT1_TEST55       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE55
         LTORG 
RT1_CCE55       DS 0H
*MEXIT #=    83 LV= 2 RT1
*MCALL #=    84 LV= 2          RT1   CCE,DST19,DCZ
         DS    0H
         CLC   DST19,DCZ
RT1_TEST56       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE56
         LTORG 
RT1_CCE56       DS 0H
*MEXIT #=    84 LV= 2 RT1
*MCALL #=    85 LV= 2          RT1   CCE,=AL1(L'DCT19),=AL1(1)
         DS    0H
         CLC   =AL1(L'DCT19),=AL1(1)
RT1_TEST57       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE57
         LTORG 
RT1_CCE57       DS 0H
*MEXIT #=    85 LV= 2 RT1
*MEXIT #=    82 LV= 1 TEST
*MCALL #=    86 LV= 1          TEST  L=1,D=(HL.4'1,2,3,4'),V=(X'1234')
DATA     LOCTR 
DCT20    DC    HL.4'1,2,3,4'
DCV20    DC    X'1234'
DST20    DS    HL.4'1,2,3,4'
CODE     LOCTR 
*MCALL #=    87 LV= 2          RT1   CCE,DCT20,DCV20
         DS    0H
         CLC   DCT20,DCV20
RT1_TEST58       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE58
         LTORG 
RT1_CCE58       DS 0H
*MEXIT #=    87 LV= 2 RT1
*MCALL #=    88 LV= 2          RT1   CCE,DST20,DCZ
         DS    0H
         CLC   DST20,DCZ
RT1_TEST59       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE59
         LTORG 
RT1_CCE59       DS 0H
*MEXIT #=    88 LV= 2 RT1
*MCALL #=    89 LV= 2          RT1   CCE,=AL1(L'DCT20),=AL1(1)
         DS    0H
         CLC   =AL1(L'DCT20),=AL1(1)
RT1_TEST60       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE60
         LTORG 
RT1_CCE60       DS 0H
*MEXIT #=    89 LV= 2 RT1
*MEXIT #=    86 LV= 1 TEST
*MCALL #=    90 LV= 1          TEST  L=1,D=(HL.4'-1,-2,-3,-4'),V=(X'FEDX
               C')
DATA     LOCTR 
DCT21    DC    HL.4'-1,-2,-3,-4'
DCV21    DC    X'FEDC'
DST21    DS    HL.4'-1,-2,-3,-4'
CODE     LOCTR 
*MCALL #=    91 LV= 2          RT1   CCE,DCT21,DCV21
         DS    0H
         CLC   DCT21,DCV21
RT1_TEST61       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE61
         LTORG 
RT1_CCE61       DS 0H
*MEXIT #=    91 LV= 2 RT1
*MCALL #=    92 LV= 2          RT1   CCE,DST21,DCZ
         DS    0H
         CLC   DST21,DCZ
RT1_TEST62       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE62
         LTORG 
RT1_CCE62       DS 0H
*MEXIT #=    92 LV= 2 RT1
*MCALL #=    93 LV= 2          RT1   CCE,=AL1(L'DCT21),=AL1(1)
         DS    0H
         CLC   =AL1(L'DCT21),=AL1(1)
RT1_TEST63       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE63
         LTORG 
RT1_CCE63       DS 0H
*MEXIT #=    93 LV= 2 RT1
*MEXIT #=    90 LV= 1 TEST
*MCALL #=    94 LV= 1          TEST  L=1,D=(PL.8'1,2'),V=(X'1C2C')
DATA     LOCTR 
DCT22    DC    PL.8'1,2'
DCV22    DC    X'1C2C'
DST22    DS    PL.8'1,2'
CODE     LOCTR 
*MCALL #=    95 LV= 2          RT1   CCE,DCT22,DCV22
         DS    0H
         CLC   DCT22,DCV22
RT1_TEST64       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE64
         LTORG 
RT1_CCE64       DS 0H
*MEXIT #=    95 LV= 2 RT1
*MCALL #=    96 LV= 2          RT1   CCE,DST22,DCZ
         DS    0H
         CLC   DST22,DCZ
RT1_TEST65       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE65
         LTORG 
RT1_CCE65       DS 0H
*MEXIT #=    96 LV= 2 RT1
*MCALL #=    97 LV= 2          RT1   CCE,=AL1(L'DCT22),=AL1(1)
         DS    0H
         CLC   =AL1(L'DCT22),=AL1(1)
RT1_TEST66       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE66
         LTORG 
RT1_CCE66       DS 0H
*MEXIT #=    97 LV= 2 RT1
*MEXIT #=    94 LV= 1 TEST
*MCALL #=    98 LV= 1          TEST  L=1,D=(PL.8'-1,-2'),V=(X'1D2D')
DATA     LOCTR 
DCT23    DC    PL.8'-1,-2'
DCV23    DC    X'1D2D'
DST23    DS    PL.8'-1,-2'
CODE     LOCTR 
*MCALL #=    99 LV= 2          RT1   CCE,DCT23,DCV23
         DS    0H
         CLC   DCT23,DCV23
RT1_TEST67       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE67
         LTORG 
RT1_CCE67       DS 0H
*MEXIT #=    99 LV= 2 RT1
*MCALL #=   100 LV= 2          RT1   CCE,DST23,DCZ
         DS    0H
         CLC   DST23,DCZ
RT1_TEST68       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE68
         LTORG 
RT1_CCE68       DS 0H
*MEXIT #=   100 LV= 2 RT1
*MCALL #=   101 LV= 2          RT1   CCE,=AL1(L'DCT23),=AL1(1)
         DS    0H
         CLC   =AL1(L'DCT23),=AL1(1)
RT1_TEST69       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE69
         LTORG 
RT1_CCE69       DS 0H
*MEXIT #=   101 LV= 2 RT1
*MEXIT #=    98 LV= 1 TEST
*MCALL #=   102 LV= 1          TEST  L=1,D=(XL.8'1,2'),V=(X'0102')
DATA     LOCTR 
DCT24    DC    XL.8'1,2'
DCV24    DC    X'0102'
DST24    DS    XL.8'1,2'
CODE     LOCTR 
*MCALL #=   103 LV= 2          RT1   CCE,DCT24,DCV24
         DS    0H
         CLC   DCT24,DCV24
RT1_TEST70       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE70
         LTORG 
RT1_CCE70       DS 0H
*MEXIT #=   103 LV= 2 RT1
*MCALL #=   104 LV= 2          RT1   CCE,DST24,DCZ
         DS    0H
         CLC   DST24,DCZ
RT1_TEST71       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE71
         LTORG 
RT1_CCE71       DS 0H
*MEXIT #=   104 LV= 2 RT1
*MCALL #=   105 LV= 2          RT1   CCE,=AL1(L'DCT24),=AL1(1)
         DS    0H
         CLC   =AL1(L'DCT24),=AL1(1)
RT1_TEST72       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE72
         LTORG 
RT1_CCE72       DS 0H
*MEXIT #=   105 LV= 2 RT1
*MEXIT #=   102 LV= 1 TEST
*MCALL #=   106 LV= 1          TEST  L=1,D=(XL.8'AB,CD'),V=(X'ABCD')
DATA     LOCTR 
DCT25    DC    XL.8'AB,CD'
DCV25    DC    X'ABCD'
DST25    DS    XL.8'AB,CD'
CODE     LOCTR 
*MCALL #=   107 LV= 2          RT1   CCE,DCT25,DCV25
         DS    0H
         CLC   DCT25,DCV25
RT1_TEST73       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE73
         LTORG 
RT1_CCE73       DS 0H
*MEXIT #=   107 LV= 2 RT1
*MCALL #=   108 LV= 2          RT1   CCE,DST25,DCZ
         DS    0H
         CLC   DST25,DCZ
RT1_TEST74       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE74
         LTORG 
RT1_CCE74       DS 0H
*MEXIT #=   108 LV= 2 RT1
*MCALL #=   109 LV= 2          RT1   CCE,=AL1(L'DCT25),=AL1(1)
         DS    0H
         CLC   =AL1(L'DCT25),=AL1(1)
RT1_TEST75       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE75
         LTORG 
RT1_CCE75       DS 0H
*MEXIT #=   109 LV= 2 RT1
*MEXIT #=   106 LV= 1 TEST
*MCALL #=   110 LV= 1          TEST  L=1,D=(XL.4'A,B,C,D'),V=(X'ABCD')
DATA     LOCTR 
DCT26    DC    XL.4'A,B,C,D'
DCV26    DC    X'ABCD'
DST26    DS    XL.4'A,B,C,D'
CODE     LOCTR 
*MCALL #=   111 LV= 2          RT1   CCE,DCT26,DCV26
         DS    0H
         CLC   DCT26,DCV26
RT1_TEST76       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE76
         LTORG 
RT1_CCE76       DS 0H
*MEXIT #=   111 LV= 2 RT1
*MCALL #=   112 LV= 2          RT1   CCE,DST26,DCZ
         DS    0H
         CLC   DST26,DCZ
RT1_TEST77       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE77
         LTORG 
RT1_CCE77       DS 0H
*MEXIT #=   112 LV= 2 RT1
*MCALL #=   113 LV= 2          RT1   CCE,=AL1(L'DCT26),=AL1(1)
         DS    0H
         CLC   =AL1(L'DCT26),=AL1(1)
RT1_TEST78       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE78
         LTORG 
RT1_CCE78       DS 0H
*MEXIT #=   113 LV= 2 RT1
*MEXIT #=   110 LV= 1 TEST
*MCALL #=   114 LV= 1          TEST  L=2,D=(XL.12'ABC,DEF'),V=(X'ABCDEFX
               ')
DATA     LOCTR 
DCT27    DC    XL.12'ABC,DEF'
DCV27    DC    X'ABCDEF'
DST27    DS    XL.12'ABC,DEF'
CODE     LOCTR 
*MCALL #=   115 LV= 2          RT1   CCE,DCT27,DCV27
         DS    0H
         CLC   DCT27,DCV27
RT1_TEST79       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE79
         LTORG 
RT1_CCE79       DS 0H
*MEXIT #=   115 LV= 2 RT1
*MCALL #=   116 LV= 2          RT1   CCE,DST27,DCZ
         DS    0H
         CLC   DST27,DCZ
RT1_TEST80       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE80
         LTORG 
RT1_CCE80       DS 0H
*MEXIT #=   116 LV= 2 RT1
*MCALL #=   117 LV= 2          RT1   CCE,=AL1(L'DCT27),=AL1(2)
         DS    0H
         CLC   =AL1(L'DCT27),=AL1(2)
RT1_TEST81       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE81
         LTORG 
RT1_CCE81       DS 0H
*MEXIT #=   117 LV= 2 RT1
*MEXIT #=   114 LV= 1 TEST
*MCALL #=   118 LV= 1          RT1   END
         B      RT1_END
*MEXIT #=   118 LV= 1 RT1
         END 
