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
* 2006-08-03 DSH         Initial version                            *
* 2008-06-20 DSH RPI-845 Change EPIED to IHAEPIE                    *
*********************************************************************
         MACRO
         TEST &P
         LA   R0,1
         ZAP  PWORK,=P'0'
         CVB  R0,&P
         CVD  R0,PWORK
         CP   PWORK,&P
         RT1  CCE
         ZAP  PWORK,=P'0'
         CVBY R0,&P
         CVDY R0,PWORK
         CP   PWORK,&P
         RT1  CCE
         MEND
*MCALL #=     1 LV= 1 TESTCVB1 RT1  MAIN
*MCALL #=     2 LV= 2 TESTCVB1 SUBENTRY 
TESTCVB1 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTCVB1'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTCVB1+8,13
*MEXIT #=     2 LV= 2 SUBENTRY
*MCALL #=     3 LV= 2          WTO   'TESTCVB1 RT1 STARTED'
         BRAS  1,*+(WTO#0003_EOT-*+1)/2*2
         DC    AL2(WTO#0003_EOT-*,0),C'TESTCVB1 RT1 STARTED'
WTO#0003_EOT     EQU *
         SVC   35
*MEXIT #=     3 LV= 2 WTO
         BRCL    15,RT1_START
RT1_ABORT DS 0H
         MVI   RT1_ABORTED,C'T'
*MCALL #=     4 LV= 2          WTO   'TESTCVB1 RT1 TESTING ABORTED'
         BRAS  1,*+(WTO#0004_EOT-*+1)/2*2
         DC    AL2(WTO#0004_EOT-*,0),C'TESTCVB1 RT1 TESTING ABORTED'
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
*MCALL #=     6 LV= 2          WTO   'TESTCVB1 RT1 ENDED OK'
         BRAS  1,*+(WTO#0006_EOT-*+1)/2*2
         DC    AL2(WTO#0006_EOT-*,0),C'TESTCVB1 RT1 ENDED OK'
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
RT1_WTO1 DC    AL2(RT1_WTO_END-*,0),C'TESTCVB1 RT1 TESTS COMPLETED = '
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
PWORK    DC   PL8'0'
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
*MCALL #=    10 LV= 1          RT1  START
RT1_START DS  0H
*MEXIT #=    10 LV= 1 RT1
*MCALL #=    11 LV= 1          TEST =PL8'0'
         LA   R0,1
         ZAP  PWORK,=P'0'
         CVB  R0,=PL8'0'
         CVD  R0,PWORK
         CP   PWORK,=PL8'0'
*MCALL #=    12 LV= 2          RT1  CCE
         DS    0H
RT1_TEST1        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1
         LTORG 
RT1_CCE1        DS 0H
*MEXIT #=    12 LV= 2 RT1
         ZAP  PWORK,=P'0'
         CVBY R0,=PL8'0'
         CVDY R0,PWORK
         CP   PWORK,=PL8'0'
*MCALL #=    13 LV= 2          RT1  CCE
         DS    0H
RT1_TEST2        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE2
         LTORG 
RT1_CCE2        DS 0H
*MEXIT #=    13 LV= 2 RT1
*MEXIT #=    11 LV= 1 TEST
*MCALL #=    14 LV= 1          TEST =PL8'1'
         LA   R0,1
         ZAP  PWORK,=P'0'
         CVB  R0,=PL8'1'
         CVD  R0,PWORK
         CP   PWORK,=PL8'1'
*MCALL #=    15 LV= 2          RT1  CCE
         DS    0H
RT1_TEST3        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE3
         LTORG 
RT1_CCE3        DS 0H
*MEXIT #=    15 LV= 2 RT1
         ZAP  PWORK,=P'0'
         CVBY R0,=PL8'1'
         CVDY R0,PWORK
         CP   PWORK,=PL8'1'
*MCALL #=    16 LV= 2          RT1  CCE
         DS    0H
RT1_TEST4        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE4
         LTORG 
RT1_CCE4        DS 0H
*MEXIT #=    16 LV= 2 RT1
*MEXIT #=    14 LV= 1 TEST
*MCALL #=    17 LV= 1          TEST =PL8'12'
         LA   R0,1
         ZAP  PWORK,=P'0'
         CVB  R0,=PL8'12'
         CVD  R0,PWORK
         CP   PWORK,=PL8'12'
*MCALL #=    18 LV= 2          RT1  CCE
         DS    0H
RT1_TEST5        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE5
         LTORG 
RT1_CCE5        DS 0H
*MEXIT #=    18 LV= 2 RT1
         ZAP  PWORK,=P'0'
         CVBY R0,=PL8'12'
         CVDY R0,PWORK
         CP   PWORK,=PL8'12'
*MCALL #=    19 LV= 2          RT1  CCE
         DS    0H
RT1_TEST6        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE6
         LTORG 
RT1_CCE6        DS 0H
*MEXIT #=    19 LV= 2 RT1
*MEXIT #=    17 LV= 1 TEST
*MCALL #=    20 LV= 1          TEST =PL8'123'
         LA   R0,1
         ZAP  PWORK,=P'0'
         CVB  R0,=PL8'123'
         CVD  R0,PWORK
         CP   PWORK,=PL8'123'
*MCALL #=    21 LV= 2          RT1  CCE
         DS    0H
RT1_TEST7        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE7
         LTORG 
RT1_CCE7        DS 0H
*MEXIT #=    21 LV= 2 RT1
         ZAP  PWORK,=P'0'
         CVBY R0,=PL8'123'
         CVDY R0,PWORK
         CP   PWORK,=PL8'123'
*MCALL #=    22 LV= 2          RT1  CCE
         DS    0H
RT1_TEST8        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE8
         LTORG 
RT1_CCE8        DS 0H
*MEXIT #=    22 LV= 2 RT1
*MEXIT #=    20 LV= 1 TEST
*MCALL #=    23 LV= 1          TEST =PL8'1234'
         LA   R0,1
         ZAP  PWORK,=P'0'
         CVB  R0,=PL8'1234'
         CVD  R0,PWORK
         CP   PWORK,=PL8'1234'
*MCALL #=    24 LV= 2          RT1  CCE
         DS    0H
RT1_TEST9        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE9
         LTORG 
RT1_CCE9        DS 0H
*MEXIT #=    24 LV= 2 RT1
         ZAP  PWORK,=P'0'
         CVBY R0,=PL8'1234'
         CVDY R0,PWORK
         CP   PWORK,=PL8'1234'
*MCALL #=    25 LV= 2          RT1  CCE
         DS    0H
RT1_TEST10       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE10
         LTORG 
RT1_CCE10       DS 0H
*MEXIT #=    25 LV= 2 RT1
*MEXIT #=    23 LV= 1 TEST
*MCALL #=    26 LV= 1          TEST =PL8'12345'
         LA   R0,1
         ZAP  PWORK,=P'0'
         CVB  R0,=PL8'12345'
         CVD  R0,PWORK
         CP   PWORK,=PL8'12345'
*MCALL #=    27 LV= 2          RT1  CCE
         DS    0H
RT1_TEST11       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE11
         LTORG 
RT1_CCE11       DS 0H
*MEXIT #=    27 LV= 2 RT1
         ZAP  PWORK,=P'0'
         CVBY R0,=PL8'12345'
         CVDY R0,PWORK
         CP   PWORK,=PL8'12345'
*MCALL #=    28 LV= 2          RT1  CCE
         DS    0H
RT1_TEST12       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE12
         LTORG 
RT1_CCE12       DS 0H
*MEXIT #=    28 LV= 2 RT1
*MEXIT #=    26 LV= 1 TEST
*MCALL #=    29 LV= 1          TEST =PL8'123456'
         LA   R0,1
         ZAP  PWORK,=P'0'
         CVB  R0,=PL8'123456'
         CVD  R0,PWORK
         CP   PWORK,=PL8'123456'
*MCALL #=    30 LV= 2          RT1  CCE
         DS    0H
RT1_TEST13       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE13
         LTORG 
RT1_CCE13       DS 0H
*MEXIT #=    30 LV= 2 RT1
         ZAP  PWORK,=P'0'
         CVBY R0,=PL8'123456'
         CVDY R0,PWORK
         CP   PWORK,=PL8'123456'
*MCALL #=    31 LV= 2          RT1  CCE
         DS    0H
RT1_TEST14       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE14
         LTORG 
RT1_CCE14       DS 0H
*MEXIT #=    31 LV= 2 RT1
*MEXIT #=    29 LV= 1 TEST
*MCALL #=    32 LV= 1          TEST =PL8'1234567'
         LA   R0,1
         ZAP  PWORK,=P'0'
         CVB  R0,=PL8'1234567'
         CVD  R0,PWORK
         CP   PWORK,=PL8'1234567'
*MCALL #=    33 LV= 2          RT1  CCE
         DS    0H
RT1_TEST15       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE15
         LTORG 
RT1_CCE15       DS 0H
*MEXIT #=    33 LV= 2 RT1
         ZAP  PWORK,=P'0'
         CVBY R0,=PL8'1234567'
         CVDY R0,PWORK
         CP   PWORK,=PL8'1234567'
*MCALL #=    34 LV= 2          RT1  CCE
         DS    0H
RT1_TEST16       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE16
         LTORG 
RT1_CCE16       DS 0H
*MEXIT #=    34 LV= 2 RT1
*MEXIT #=    32 LV= 1 TEST
*MCALL #=    35 LV= 1          TEST =PL8'12345678'
         LA   R0,1
         ZAP  PWORK,=P'0'
         CVB  R0,=PL8'12345678'
         CVD  R0,PWORK
         CP   PWORK,=PL8'12345678'
*MCALL #=    36 LV= 2          RT1  CCE
         DS    0H
RT1_TEST17       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE17
         LTORG 
RT1_CCE17       DS 0H
*MEXIT #=    36 LV= 2 RT1
         ZAP  PWORK,=P'0'
         CVBY R0,=PL8'12345678'
         CVDY R0,PWORK
         CP   PWORK,=PL8'12345678'
*MCALL #=    37 LV= 2          RT1  CCE
         DS    0H
RT1_TEST18       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE18
         LTORG 
RT1_CCE18       DS 0H
*MEXIT #=    37 LV= 2 RT1
*MEXIT #=    35 LV= 1 TEST
*MCALL #=    38 LV= 1          TEST =PL8'123456789'
         LA   R0,1
         ZAP  PWORK,=P'0'
         CVB  R0,=PL8'123456789'
         CVD  R0,PWORK
         CP   PWORK,=PL8'123456789'
*MCALL #=    39 LV= 2          RT1  CCE
         DS    0H
RT1_TEST19       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE19
         LTORG 
RT1_CCE19       DS 0H
*MEXIT #=    39 LV= 2 RT1
         ZAP  PWORK,=P'0'
         CVBY R0,=PL8'123456789'
         CVDY R0,PWORK
         CP   PWORK,=PL8'123456789'
*MCALL #=    40 LV= 2          RT1  CCE
         DS    0H
RT1_TEST20       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE20
         LTORG 
RT1_CCE20       DS 0H
*MEXIT #=    40 LV= 2 RT1
*MEXIT #=    38 LV= 1 TEST
*MCALL #=    41 LV= 1          TEST =PL8'500000000'
         LA   R0,1
         ZAP  PWORK,=P'0'
         CVB  R0,=PL8'500000000'
         CVD  R0,PWORK
         CP   PWORK,=PL8'500000000'
*MCALL #=    42 LV= 2          RT1  CCE
         DS    0H
RT1_TEST21       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE21
         LTORG 
RT1_CCE21       DS 0H
*MEXIT #=    42 LV= 2 RT1
         ZAP  PWORK,=P'0'
         CVBY R0,=PL8'500000000'
         CVDY R0,PWORK
         CP   PWORK,=PL8'500000000'
*MCALL #=    43 LV= 2          RT1  CCE
         DS    0H
RT1_TEST22       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE22
         LTORG 
RT1_CCE22       DS 0H
*MEXIT #=    43 LV= 2 RT1
*MEXIT #=    41 LV= 1 TEST
*MCALL #=    44 LV= 1          TEST =PL8'1234567890'
         LA   R0,1
         ZAP  PWORK,=P'0'
         CVB  R0,=PL8'1234567890'
         CVD  R0,PWORK
         CP   PWORK,=PL8'1234567890'
*MCALL #=    45 LV= 2          RT1  CCE
         DS    0H
RT1_TEST23       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE23
         LTORG 
RT1_CCE23       DS 0H
*MEXIT #=    45 LV= 2 RT1
         ZAP  PWORK,=P'0'
         CVBY R0,=PL8'1234567890'
         CVDY R0,PWORK
         CP   PWORK,=PL8'1234567890'
*MCALL #=    46 LV= 2          RT1  CCE
         DS    0H
RT1_TEST24       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE24
         LTORG 
RT1_CCE24       DS 0H
*MEXIT #=    46 LV= 2 RT1
*MEXIT #=    44 LV= 1 TEST
*MCALL #=    47 LV= 1          TEST =PL8'1000000000'
         LA   R0,1
         ZAP  PWORK,=P'0'
         CVB  R0,=PL8'1000000000'
         CVD  R0,PWORK
         CP   PWORK,=PL8'1000000000'
*MCALL #=    48 LV= 2          RT1  CCE
         DS    0H
RT1_TEST25       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE25
         LTORG 
RT1_CCE25       DS 0H
*MEXIT #=    48 LV= 2 RT1
         ZAP  PWORK,=P'0'
         CVBY R0,=PL8'1000000000'
         CVDY R0,PWORK
         CP   PWORK,=PL8'1000000000'
*MCALL #=    49 LV= 2          RT1  CCE
         DS    0H
RT1_TEST26       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE26
         LTORG 
RT1_CCE26       DS 0H
*MEXIT #=    49 LV= 2 RT1
*MEXIT #=    47 LV= 1 TEST
*MCALL #=    50 LV= 1          TEST =PL8'2000000000'
         LA   R0,1
         ZAP  PWORK,=P'0'
         CVB  R0,=PL8'2000000000'
         CVD  R0,PWORK
         CP   PWORK,=PL8'2000000000'
*MCALL #=    51 LV= 2          RT1  CCE
         DS    0H
RT1_TEST27       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE27
         LTORG 
RT1_CCE27       DS 0H
*MEXIT #=    51 LV= 2 RT1
         ZAP  PWORK,=P'0'
         CVBY R0,=PL8'2000000000'
         CVDY R0,PWORK
         CP   PWORK,=PL8'2000000000'
*MCALL #=    52 LV= 2          RT1  CCE
         DS    0H
RT1_TEST28       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE28
         LTORG 
RT1_CCE28       DS 0H
*MEXIT #=    52 LV= 2 RT1
*MEXIT #=    50 LV= 1 TEST
*MCALL #=    53 LV= 1          TEST =PL8'2147483647'
         LA   R0,1
         ZAP  PWORK,=P'0'
         CVB  R0,=PL8'2147483647'
         CVD  R0,PWORK
         CP   PWORK,=PL8'2147483647'
*MCALL #=    54 LV= 2          RT1  CCE
         DS    0H
RT1_TEST29       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE29
         LTORG 
RT1_CCE29       DS 0H
*MEXIT #=    54 LV= 2 RT1
         ZAP  PWORK,=P'0'
         CVBY R0,=PL8'2147483647'
         CVDY R0,PWORK
         CP   PWORK,=PL8'2147483647'
*MCALL #=    55 LV= 2          RT1  CCE
         DS    0H
RT1_TEST30       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE30
         LTORG 
RT1_CCE30       DS 0H
*MEXIT #=    55 LV= 2 RT1
*MEXIT #=    53 LV= 1 TEST
*MCALL #=    56 LV= 1          TEST =PL8'-0'
         LA   R0,1
         ZAP  PWORK,=P'0'
         CVB  R0,=PL8'-0'
         CVD  R0,PWORK
         CP   PWORK,=PL8'-0'
*MCALL #=    57 LV= 2          RT1  CCE
         DS    0H
RT1_TEST31       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE31
         LTORG 
RT1_CCE31       DS 0H
*MEXIT #=    57 LV= 2 RT1
         ZAP  PWORK,=P'0'
         CVBY R0,=PL8'-0'
         CVDY R0,PWORK
         CP   PWORK,=PL8'-0'
*MCALL #=    58 LV= 2          RT1  CCE
         DS    0H
RT1_TEST32       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE32
         LTORG 
RT1_CCE32       DS 0H
*MEXIT #=    58 LV= 2 RT1
*MEXIT #=    56 LV= 1 TEST
*MCALL #=    59 LV= 1          TEST =PL8'-1'
         LA   R0,1
         ZAP  PWORK,=P'0'
         CVB  R0,=PL8'-1'
         CVD  R0,PWORK
         CP   PWORK,=PL8'-1'
*MCALL #=    60 LV= 2          RT1  CCE
         DS    0H
RT1_TEST33       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE33
         LTORG 
RT1_CCE33       DS 0H
*MEXIT #=    60 LV= 2 RT1
         ZAP  PWORK,=P'0'
         CVBY R0,=PL8'-1'
         CVDY R0,PWORK
         CP   PWORK,=PL8'-1'
*MCALL #=    61 LV= 2          RT1  CCE
         DS    0H
RT1_TEST34       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE34
         LTORG 
RT1_CCE34       DS 0H
*MEXIT #=    61 LV= 2 RT1
*MEXIT #=    59 LV= 1 TEST
*MCALL #=    62 LV= 1          TEST =PL8'-12'
         LA   R0,1
         ZAP  PWORK,=P'0'
         CVB  R0,=PL8'-12'
         CVD  R0,PWORK
         CP   PWORK,=PL8'-12'
*MCALL #=    63 LV= 2          RT1  CCE
         DS    0H
RT1_TEST35       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE35
         LTORG 
RT1_CCE35       DS 0H
*MEXIT #=    63 LV= 2 RT1
         ZAP  PWORK,=P'0'
         CVBY R0,=PL8'-12'
         CVDY R0,PWORK
         CP   PWORK,=PL8'-12'
*MCALL #=    64 LV= 2          RT1  CCE
         DS    0H
RT1_TEST36       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE36
         LTORG 
RT1_CCE36       DS 0H
*MEXIT #=    64 LV= 2 RT1
*MEXIT #=    62 LV= 1 TEST
*MCALL #=    65 LV= 1          TEST =PL8'-123'
         LA   R0,1
         ZAP  PWORK,=P'0'
         CVB  R0,=PL8'-123'
         CVD  R0,PWORK
         CP   PWORK,=PL8'-123'
*MCALL #=    66 LV= 2          RT1  CCE
         DS    0H
RT1_TEST37       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE37
         LTORG 
RT1_CCE37       DS 0H
*MEXIT #=    66 LV= 2 RT1
         ZAP  PWORK,=P'0'
         CVBY R0,=PL8'-123'
         CVDY R0,PWORK
         CP   PWORK,=PL8'-123'
*MCALL #=    67 LV= 2          RT1  CCE
         DS    0H
RT1_TEST38       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE38
         LTORG 
RT1_CCE38       DS 0H
*MEXIT #=    67 LV= 2 RT1
*MEXIT #=    65 LV= 1 TEST
*MCALL #=    68 LV= 1          TEST =PL8'-1234'
         LA   R0,1
         ZAP  PWORK,=P'0'
         CVB  R0,=PL8'-1234'
         CVD  R0,PWORK
         CP   PWORK,=PL8'-1234'
*MCALL #=    69 LV= 2          RT1  CCE
         DS    0H
RT1_TEST39       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE39
         LTORG 
RT1_CCE39       DS 0H
*MEXIT #=    69 LV= 2 RT1
         ZAP  PWORK,=P'0'
         CVBY R0,=PL8'-1234'
         CVDY R0,PWORK
         CP   PWORK,=PL8'-1234'
*MCALL #=    70 LV= 2          RT1  CCE
         DS    0H
RT1_TEST40       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE40
         LTORG 
RT1_CCE40       DS 0H
*MEXIT #=    70 LV= 2 RT1
*MEXIT #=    68 LV= 1 TEST
*MCALL #=    71 LV= 1          TEST =PL8'-12345'
         LA   R0,1
         ZAP  PWORK,=P'0'
         CVB  R0,=PL8'-12345'
         CVD  R0,PWORK
         CP   PWORK,=PL8'-12345'
*MCALL #=    72 LV= 2          RT1  CCE
         DS    0H
RT1_TEST41       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE41
         LTORG 
RT1_CCE41       DS 0H
*MEXIT #=    72 LV= 2 RT1
         ZAP  PWORK,=P'0'
         CVBY R0,=PL8'-12345'
         CVDY R0,PWORK
         CP   PWORK,=PL8'-12345'
*MCALL #=    73 LV= 2          RT1  CCE
         DS    0H
RT1_TEST42       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE42
         LTORG 
RT1_CCE42       DS 0H
*MEXIT #=    73 LV= 2 RT1
*MEXIT #=    71 LV= 1 TEST
*MCALL #=    74 LV= 1          TEST =PL8'-123456'
         LA   R0,1
         ZAP  PWORK,=P'0'
         CVB  R0,=PL8'-123456'
         CVD  R0,PWORK
         CP   PWORK,=PL8'-123456'
*MCALL #=    75 LV= 2          RT1  CCE
         DS    0H
RT1_TEST43       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE43
         LTORG 
RT1_CCE43       DS 0H
*MEXIT #=    75 LV= 2 RT1
         ZAP  PWORK,=P'0'
         CVBY R0,=PL8'-123456'
         CVDY R0,PWORK
         CP   PWORK,=PL8'-123456'
*MCALL #=    76 LV= 2          RT1  CCE
         DS    0H
RT1_TEST44       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE44
         LTORG 
RT1_CCE44       DS 0H
*MEXIT #=    76 LV= 2 RT1
*MEXIT #=    74 LV= 1 TEST
*MCALL #=    77 LV= 1          TEST =PL8'-1234567'
         LA   R0,1
         ZAP  PWORK,=P'0'
         CVB  R0,=PL8'-1234567'
         CVD  R0,PWORK
         CP   PWORK,=PL8'-1234567'
*MCALL #=    78 LV= 2          RT1  CCE
         DS    0H
RT1_TEST45       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE45
         LTORG 
RT1_CCE45       DS 0H
*MEXIT #=    78 LV= 2 RT1
         ZAP  PWORK,=P'0'
         CVBY R0,=PL8'-1234567'
         CVDY R0,PWORK
         CP   PWORK,=PL8'-1234567'
*MCALL #=    79 LV= 2          RT1  CCE
         DS    0H
RT1_TEST46       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE46
         LTORG 
RT1_CCE46       DS 0H
*MEXIT #=    79 LV= 2 RT1
*MEXIT #=    77 LV= 1 TEST
*MCALL #=    80 LV= 1          TEST =PL8'-12345678'
         LA   R0,1
         ZAP  PWORK,=P'0'
         CVB  R0,=PL8'-12345678'
         CVD  R0,PWORK
         CP   PWORK,=PL8'-12345678'
*MCALL #=    81 LV= 2          RT1  CCE
         DS    0H
RT1_TEST47       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE47
         LTORG 
RT1_CCE47       DS 0H
*MEXIT #=    81 LV= 2 RT1
         ZAP  PWORK,=P'0'
         CVBY R0,=PL8'-12345678'
         CVDY R0,PWORK
         CP   PWORK,=PL8'-12345678'
*MCALL #=    82 LV= 2          RT1  CCE
         DS    0H
RT1_TEST48       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE48
         LTORG 
RT1_CCE48       DS 0H
*MEXIT #=    82 LV= 2 RT1
*MEXIT #=    80 LV= 1 TEST
*MCALL #=    83 LV= 1          TEST =PL8'-123456789'
         LA   R0,1
         ZAP  PWORK,=P'0'
         CVB  R0,=PL8'-123456789'
         CVD  R0,PWORK
         CP   PWORK,=PL8'-123456789'
*MCALL #=    84 LV= 2          RT1  CCE
         DS    0H
RT1_TEST49       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE49
         LTORG 
RT1_CCE49       DS 0H
*MEXIT #=    84 LV= 2 RT1
         ZAP  PWORK,=P'0'
         CVBY R0,=PL8'-123456789'
         CVDY R0,PWORK
         CP   PWORK,=PL8'-123456789'
*MCALL #=    85 LV= 2          RT1  CCE
         DS    0H
RT1_TEST50       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE50
         LTORG 
RT1_CCE50       DS 0H
*MEXIT #=    85 LV= 2 RT1
*MEXIT #=    83 LV= 1 TEST
*MCALL #=    86 LV= 1          TEST =PL8'-500000000'
         LA   R0,1
         ZAP  PWORK,=P'0'
         CVB  R0,=PL8'-500000000'
         CVD  R0,PWORK
         CP   PWORK,=PL8'-500000000'
*MCALL #=    87 LV= 2          RT1  CCE
         DS    0H
RT1_TEST51       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE51
         LTORG 
RT1_CCE51       DS 0H
*MEXIT #=    87 LV= 2 RT1
         ZAP  PWORK,=P'0'
         CVBY R0,=PL8'-500000000'
         CVDY R0,PWORK
         CP   PWORK,=PL8'-500000000'
*MCALL #=    88 LV= 2          RT1  CCE
         DS    0H
RT1_TEST52       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE52
         LTORG 
RT1_CCE52       DS 0H
*MEXIT #=    88 LV= 2 RT1
*MEXIT #=    86 LV= 1 TEST
*MCALL #=    89 LV= 1          TEST =PL8'-1234567890'
         LA   R0,1
         ZAP  PWORK,=P'0'
         CVB  R0,=PL8'-1234567890'
         CVD  R0,PWORK
         CP   PWORK,=PL8'-1234567890'
*MCALL #=    90 LV= 2          RT1  CCE
         DS    0H
RT1_TEST53       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE53
         LTORG 
RT1_CCE53       DS 0H
*MEXIT #=    90 LV= 2 RT1
         ZAP  PWORK,=P'0'
         CVBY R0,=PL8'-1234567890'
         CVDY R0,PWORK
         CP   PWORK,=PL8'-1234567890'
*MCALL #=    91 LV= 2          RT1  CCE
         DS    0H
RT1_TEST54       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE54
         LTORG 
RT1_CCE54       DS 0H
*MEXIT #=    91 LV= 2 RT1
*MEXIT #=    89 LV= 1 TEST
*MCALL #=    92 LV= 1          TEST =PL8'-1000000000'
         LA   R0,1
         ZAP  PWORK,=P'0'
         CVB  R0,=PL8'-1000000000'
         CVD  R0,PWORK
         CP   PWORK,=PL8'-1000000000'
*MCALL #=    93 LV= 2          RT1  CCE
         DS    0H
RT1_TEST55       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE55
         LTORG 
RT1_CCE55       DS 0H
*MEXIT #=    93 LV= 2 RT1
         ZAP  PWORK,=P'0'
         CVBY R0,=PL8'-1000000000'
         CVDY R0,PWORK
         CP   PWORK,=PL8'-1000000000'
*MCALL #=    94 LV= 2          RT1  CCE
         DS    0H
RT1_TEST56       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE56
         LTORG 
RT1_CCE56       DS 0H
*MEXIT #=    94 LV= 2 RT1
*MEXIT #=    92 LV= 1 TEST
*MCALL #=    95 LV= 1          TEST =PL8'-2000000000'
         LA   R0,1
         ZAP  PWORK,=P'0'
         CVB  R0,=PL8'-2000000000'
         CVD  R0,PWORK
         CP   PWORK,=PL8'-2000000000'
*MCALL #=    96 LV= 2          RT1  CCE
         DS    0H
RT1_TEST57       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE57
         LTORG 
RT1_CCE57       DS 0H
*MEXIT #=    96 LV= 2 RT1
         ZAP  PWORK,=P'0'
         CVBY R0,=PL8'-2000000000'
         CVDY R0,PWORK
         CP   PWORK,=PL8'-2000000000'
*MCALL #=    97 LV= 2          RT1  CCE
         DS    0H
RT1_TEST58       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE58
         LTORG 
RT1_CCE58       DS 0H
*MEXIT #=    97 LV= 2 RT1
*MEXIT #=    95 LV= 1 TEST
*MCALL #=    98 LV= 1          TEST =PL8'-2147483647'
         LA   R0,1
         ZAP  PWORK,=P'0'
         CVB  R0,=PL8'-2147483647'
         CVD  R0,PWORK
         CP   PWORK,=PL8'-2147483647'
*MCALL #=    99 LV= 2          RT1  CCE
         DS    0H
RT1_TEST59       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE59
         LTORG 
RT1_CCE59       DS 0H
*MEXIT #=    99 LV= 2 RT1
         ZAP  PWORK,=P'0'
         CVBY R0,=PL8'-2147483647'
         CVDY R0,PWORK
         CP   PWORK,=PL8'-2147483647'
*MCALL #=   100 LV= 2          RT1  CCE
         DS    0H
RT1_TEST60       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE60
         LTORG 
RT1_CCE60       DS 0H
*MEXIT #=   100 LV= 2 RT1
*MEXIT #=    98 LV= 1 TEST
*MCALL #=   101 LV= 1          TEST =PL8'-2147483648'
         LA   R0,1
         ZAP  PWORK,=P'0'
         CVB  R0,=PL8'-2147483648'
         CVD  R0,PWORK
         CP   PWORK,=PL8'-2147483648'
*MCALL #=   102 LV= 2          RT1  CCE
         DS    0H
RT1_TEST61       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE61
         LTORG 
RT1_CCE61       DS 0H
*MEXIT #=   102 LV= 2 RT1
         ZAP  PWORK,=P'0'
         CVBY R0,=PL8'-2147483648'
         CVDY R0,PWORK
         CP   PWORK,=PL8'-2147483648'
*MCALL #=   103 LV= 2          RT1  CCE
         DS    0H
RT1_TEST62       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE62
         LTORG 
RT1_CCE62       DS 0H
*MEXIT #=   103 LV= 2 RT1
*MEXIT #=   101 LV= 1 TEST
*MCALL #=   104 LV= 1          ESPIE SET,ESPIE_EXIT,9,PARAM=SPI1
        LA     15,SPI1
        IPM    0  GET CURRENT PGM MASK
        SPM    0 TURN ON ANY MASKS REQUIRED
        L      0,=B'00000000010000000000000000000000'
        LA     1,ESPIE_EXIT
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   104 LV= 1 ESPIE
*MCALL #=   105 LV= 1          TEST =PL8'2147483648'
         LA   R0,1
         ZAP  PWORK,=P'0'
         CVB  R0,=PL8'2147483648'
         CVD  R0,PWORK
         CP   PWORK,=PL8'2147483648'
*MCALL #=   106 LV= 2          RT1  CCE
         DS    0H
RT1_TEST63       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE63
         LTORG 
RT1_CCE63       DS 0H
*MEXIT #=   106 LV= 2 RT1
         ZAP  PWORK,=P'0'
         CVBY R0,=PL8'2147483648'
         CVDY R0,PWORK
         CP   PWORK,=PL8'2147483648'
*MCALL #=   107 LV= 2          RT1  CCE
         DS    0H
RT1_TEST64       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE64
         LTORG 
RT1_CCE64       DS 0H
*MEXIT #=   107 LV= 2 RT1
*MEXIT #=   105 LV= 1 TEST
*MCALL #=   108 LV= 1          ABEND 101
         LA   1,101
         SVC  13 ABEND R1=COMP CODE AND HIGH BIT = DUMP PGM STORAGE
*MEXIT #=   108 LV= 1 ABEND
*MCALL #=   109 LV= 1 SPI1     ESPIE RESET
SPI1     DS    0H
        SR     15,15
        SR     1,1
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   109 LV= 1 ESPIE
         BASR  R11,0
         USING *,R11
*MCALL #=   110 LV= 1          ESPIE SET,ESPIE_EXIT,9,PARAM=SPI2
        LA     15,SPI2
        IPM    0  GET CURRENT PGM MASK
        SPM    0 TURN ON ANY MASKS REQUIRED
        L      0,=B'00000000010000000000000000000000'
        LA     1,ESPIE_EXIT
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   110 LV= 1 ESPIE
*MCALL #=   111 LV= 1          TEST =PL8'-2147483649'
         LA   R0,1
         ZAP  PWORK,=P'0'
         CVB  R0,=PL8'-2147483649'
         CVD  R0,PWORK
         CP   PWORK,=PL8'-2147483649'
*MCALL #=   112 LV= 2          RT1  CCE
         DS    0H
RT1_TEST65       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE65
         LTORG 
RT1_CCE65       DS 0H
*MEXIT #=   112 LV= 2 RT1
         ZAP  PWORK,=P'0'
         CVBY R0,=PL8'-2147483649'
         CVDY R0,PWORK
         CP   PWORK,=PL8'-2147483649'
*MCALL #=   113 LV= 2          RT1  CCE
         DS    0H
RT1_TEST66       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE66
         LTORG 
RT1_CCE66       DS 0H
*MEXIT #=   113 LV= 2 RT1
*MEXIT #=   111 LV= 1 TEST
*MCALL #=   114 LV= 1          ABEND 102
         LA   1,102
         SVC  13 ABEND R1=COMP CODE AND HIGH BIT = DUMP PGM STORAGE
*MEXIT #=   114 LV= 1 ABEND
*MCALL #=   115 LV= 1 SPI2     ESPIE RESET
SPI2     DS    0H
        SR     15,15
        SR     1,1
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   115 LV= 1 ESPIE
         BASR  R11,0
         USING *,R11
*MCALL #=   116 LV= 1          ESPIE SET,ESPIE_EXIT,9,PARAM=SPI3
        LA     15,SPI3
        IPM    0  GET CURRENT PGM MASK
        SPM    0 TURN ON ANY MASKS REQUIRED
        L      0,=B'00000000010000000000000000000000'
        LA     1,ESPIE_EXIT
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   116 LV= 1 ESPIE
*MCALL #=   117 LV= 1          TEST =PL8'123456789012345'
         LA   R0,1
         ZAP  PWORK,=P'0'
         CVB  R0,=PL8'123456789012345'
         CVD  R0,PWORK
         CP   PWORK,=PL8'123456789012345'
*MCALL #=   118 LV= 2          RT1  CCE
         DS    0H
RT1_TEST67       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE67
         LTORG 
RT1_CCE67       DS 0H
*MEXIT #=   118 LV= 2 RT1
         ZAP  PWORK,=P'0'
         CVBY R0,=PL8'123456789012345'
         CVDY R0,PWORK
         CP   PWORK,=PL8'123456789012345'
*MCALL #=   119 LV= 2          RT1  CCE
         DS    0H
RT1_TEST68       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE68
         LTORG 
RT1_CCE68       DS 0H
*MEXIT #=   119 LV= 2 RT1
*MEXIT #=   117 LV= 1 TEST
*MCALL #=   120 LV= 1          ABEND 103
         LA   1,103
         SVC  13 ABEND R1=COMP CODE AND HIGH BIT = DUMP PGM STORAGE
*MEXIT #=   120 LV= 1 ABEND
*MCALL #=   121 LV= 1 SPI3     ESPIE RESET
SPI3     DS    0H
        SR     15,15
        SR     1,1
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   121 LV= 1 ESPIE
         BASR  R11,0
         USING *,R11
*MCALL #=   122 LV= 1          ESPIE SET,ESPIE_EXIT,9,PARAM=SPI4
        LA     15,SPI4
        IPM    0  GET CURRENT PGM MASK
        SPM    0 TURN ON ANY MASKS REQUIRED
        L      0,=B'00000000010000000000000000000000'
        LA     1,ESPIE_EXIT
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   122 LV= 1 ESPIE
*MCALL #=   123 LV= 1          TEST =PL8'-123456789012345'
         LA   R0,1
         ZAP  PWORK,=P'0'
         CVB  R0,=PL8'-123456789012345'
         CVD  R0,PWORK
         CP   PWORK,=PL8'-123456789012345'
*MCALL #=   124 LV= 2          RT1  CCE
         DS    0H
RT1_TEST69       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE69
         LTORG 
RT1_CCE69       DS 0H
*MEXIT #=   124 LV= 2 RT1
         ZAP  PWORK,=P'0'
         CVBY R0,=PL8'-123456789012345'
         CVDY R0,PWORK
         CP   PWORK,=PL8'-123456789012345'
*MCALL #=   125 LV= 2          RT1  CCE
         DS    0H
RT1_TEST70       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE70
         LTORG 
RT1_CCE70       DS 0H
*MEXIT #=   125 LV= 2 RT1
*MEXIT #=   123 LV= 1 TEST
*MCALL #=   126 LV= 1          ABEND 104
         LA   1,104
         SVC  13 ABEND R1=COMP CODE AND HIGH BIT = DUMP PGM STORAGE
*MEXIT #=   126 LV= 1 ABEND
*MCALL #=   127 LV= 1 SPI4     ESPIE RESET
SPI4     DS    0H
        SR     15,15
        SR     1,1
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   127 LV= 1 ESPIE
         BASR  R11,0
         USING *,R11
*MCALL #=   128 LV= 1          RT1  END
         B      RT1_END
*MEXIT #=   128 LV= 1 RT1
ESPIE_EXIT DS  0H
         USING *,R15
         USING EPIE,R1
         L     R0,EPIEPARM
         ST    R0,EPIEPSW+4
         BR    R14
         DROP  R15,R1
*MCALL #=   129 LV= 1          IHAEPIE 
EPIE     DSECT 
EPIEEPIE DS    CL4   C'EPIE'
EPIEPARM DS    A     A(PARAM PASSED AT ESPIE OR 0)
         DS    16F   32 bit regs not used by z390 (see EPIEG64)
EPIEPSW  DS    0XL8  (OLD PSW  (EC 24/31 BIT ONLY)
EPIEEMK1 DS    X     PSW MASK
EPIEMWP1 DS    X     PSW KEY AND MWP
EPIECCPM DS    X     PSW CONDITION CODE AND PGM MASK
         DS    X     RESERVED
EPIENXT1 DS    0F    PSW 31 BIT ADDR NEXT INSTRUCTION
EPIEAMF1 DS    X     PSW ADDRESS HIGH BYTE WITH AMODE BIT
EPIEMOD1 EQU   X'80' PSW 31 BIT AMODE BIT
EPIEADD1 DS    XL3   PSW 24 BIT ADDRESSS OF NEXT INSTRUCTION
EPIEINT  DS    0XL4  PROGRAM INTERRUPTION INFO
EPIEIRSV DS    XL1   RESERVED
EPIEILC1 DS    B     INSTRUCTION LENGTH BYTE
EPIEIL1  EQU   X'06' INSTRUCTION LENGTH MASK (2, 4, 6 LENGTH)
EPIEINC1 DS    0CL2  INTERRUPTION CODE
         ORG   EPIE+X'99'
EPIEFLGS DS    XL1   EPIE OPTION FLAGS
EPIEUP64 EQU   X'40' USE 64 BIT REGS INSTEAD OF 32 BIT
         DS    XL6   RESERVED
EPIEG64   DS   0D
EPIEG6400 DS   D
EPIEG6401 DS   D
EPIEG6402 DS   D
EPIEG6403 DS   D
EPIEG6404 DS   D
EPIEG6405 DS   D
EPIEG6406 DS   D
EPIEG6407 DS   D
EPIEG6408 DS   D
EPIEG6409 DS   D
EPIEG6410 DS   D
EPIEG6411 DS   D
EPIEG6412 DS   D
EPIEG6413 DS   D
EPIEG6414 DS   D
EPIEG6415 DS   D
EPIELEN  EQU   *-EPIE
*MEXIT #=   129 LV= 1 IHAEPIE
         END 
