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
* 2006-04-12 DSH RPI-244 Test BLDL support                          *
* 2006-05-07 DSH RPI-311 Correct BLDL entry len to exclude len      *
*                        field and correct names to be in alpha     *
*                        sequence else RC=8                         *
*********************************************************************
         TITLE 'TESTBLD1 TEST BLDL SUPPORT'
*MCALL #=     1 LV= 1 TESTBLD1 RT1  MAIN
*MCALL #=     2 LV= 2 TESTBLD1 SUBENTRY 
TESTBLD1 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTBLD1'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTBLD1+8,13
*MEXIT #=     2 LV= 2 SUBENTRY
*MCALL #=     3 LV= 2          WTO   'TESTBLD1 RT1 STARTED'
         BRAS  1,*+(WTO#0003_EOT-*+1)/2*2
         DC    AL2(WTO#0003_EOT-*,0),C'TESTBLD1 RT1 STARTED'
WTO#0003_EOT     EQU *
         SVC   35
*MEXIT #=     3 LV= 2 WTO
         BRCL    15,RT1_START
RT1_ABORT DS 0H
         MVI   RT1_ABORTED,C'T'
*MCALL #=     4 LV= 2          WTO   'TESTBLD1 RT1 TESTING ABORTED'
         BRAS  1,*+(WTO#0004_EOT-*+1)/2*2
         DC    AL2(WTO#0004_EOT-*,0),C'TESTBLD1 RT1 TESTING ABORTED'
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
*MCALL #=     6 LV= 2          WTO   'TESTBLD1 RT1 ENDED OK'
         BRAS  1,*+(WTO#0006_EOT-*+1)/2*2
         DC    AL2(WTO#0006_EOT-*,0),C'TESTBLD1 RT1 ENDED OK'
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
RT1_WTO1 DC    AL2(RT1_WTO_END-*,0),C'TESTBLD1 RT1 TESTS COMPLETED = '
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
BLDL     DC   H'4' COUNT OF 4 BLDL LIST ENTRIES
BLDLE1   DC   H'14',C'DEMO    ',XL6'00' NAME,TTRKZC  R=1 Z=1 IN DEMO\
BLDLE2   DC   H'14',C'JUNK    ',XL6'00' NAME,TTRKZC  R=0 NOT FOUND
BLDLE3   DC   H'14',C'TESTBLD1',XL6'00' NAME,TTRKZC  R=1 Z=1 IN MEMORY
BLDLE4   DC   H'14',C'TESTSUB1',XL6'00' NAME,TTRKZC  R=1 Z=0 IN TEST\
*MCALL #=    10 LV= 1 ABORT    WTO  'TESTBLD1 ABORTING DUE TO ERROR'
ABORT    DS    0H
         BRAS  1,*+(WTO#0010_EOT-*+1)/2*2
         DC    AL2(WTO#0010_EOT-*,0),C'TESTBLD1 ABORTING DUE TO ERROR'
WTO#0010_EOT     EQU *
         SVC   35
*MEXIT #=    10 LV= 1 WTO
*MCALL #=    11 LV= 1          ABEND 111,DUMP
         LA   1,111
         OILH 1,X'8000'
         SVC  13 ABEND R1=COMP CODE AND HIGH BIT = DUMP PGM STORAGE
*MEXIT #=    11 LV= 1 ABEND
*MCALL #=    12 LV= 1          RT1  START
RT1_START DS  0H
*MEXIT #=    12 LV= 1 RT1
*MCALL #=    13 LV= 1          BLDL 0,BLDL
         LA    1,BLDL
         SVC   X'12' BLDL R1=BLDL LIST LL(LL,NAME,TTR,KZC,USER),(...)
*MEXIT #=    13 LV= 1 BLDL
         CL   R15,=F'4'     1 OR MORE NOT FOUND
*MCALL #=    14 LV= 1          RT1  CCE
         DS    0H
RT1_TEST1        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1
         LTORG 
RT1_CCE1        DS 0H
*MEXIT #=    14 LV= 1 RT1
         CLI  BLDLE1+2+10,1 DEMO     R=1 FOUND
*MCALL #=    15 LV= 1          RT1  CCE
         DS    0H
RT1_TEST2        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE2
         LTORG 
RT1_CCE2        DS 0H
*MEXIT #=    15 LV= 1 RT1
         CLI  BLDLE1+2+12,0 DEMO     Z=0 FOUND IN SYS390 DIR DEMO\
*MCALL #=    16 LV= 1          RT1  CCE
         DS    0H
RT1_TEST3        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE3
         LTORG 
RT1_CCE3        DS 0H
*MEXIT #=    16 LV= 1 RT1
         CLI  BLDLE2+2+10,0 JUNK     R=0 NOT FOUND
*MCALL #=    17 LV= 1          RT1  CCE
         DS    0H
RT1_TEST4        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE4
         LTORG 
RT1_CCE4        DS 0H
*MEXIT #=    17 LV= 1 RT1
         CLI  BLDLE3+2+10,1 TESTBLD1 R=1 FOUND
*MCALL #=    18 LV= 1          RT1  CCE
         DS    0H
RT1_TEST5        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE5
         LTORG 
RT1_CCE5        DS 0H
*MEXIT #=    18 LV= 1 RT1
         CLI  BLDLE3+2+12,1 TESTBLD1 Z=1 FOUND IN MEMORY
*MCALL #=    19 LV= 1          RT1  CCE
         DS    0H
RT1_TEST6        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE6
         LTORG 
RT1_CCE6        DS 0H
*MEXIT #=    19 LV= 1 RT1
         CLI  BLDLE4+2+10,1 TESTSUB1 R=1 FOUND
*MCALL #=    20 LV= 1          RT1  CCE
         DS    0H
RT1_TEST7        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE7
         LTORG 
RT1_CCE7        DS 0H
*MEXIT #=    20 LV= 1 RT1
         CLI  BLDLE4+2+12,0 TESTSUB1 Z=0 FOUND IN SYS390 DIR TEST\
*MCALL #=    21 LV= 1          RT1  CCE
         DS    0H
RT1_TEST8        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE8
         LTORG 
RT1_CCE8        DS 0H
*MEXIT #=    21 LV= 1 RT1
*MCALL #=    22 LV= 1          LOAD DE=BLDLE4 LOAD TESTSUB1
         LA    0,BLDLE4
         AHI   0,2
         SR    15,15 USE DEFAULT SYS390 SEARCH
         SVC   8 LOAD R0=A(NAME) R15=DDNAME/DSNAME ADDR OR 0
*MEXIT #=    22 LV= 1 LOAD
         LTR  R15,R15
         BNZ  ABORT
         LR   R15,R0      CALL TESTSUB1
         BALR R14,R15
*MCALL #=    23 LV= 1          DELETE DE=BLDLE4 DELETE TESTSUB1
*MCALL #=    24 LV= 2         ZDELETE DE=BLDLE4,EP=,EPLOC=,DDNAME=,DSNAX
               ME=,MF=I,RELATED=
         LA    0,BLDLE4
         AHI   0,2
         SR    15,15 USE DEFAULT SYS390 SEARCH
         SVC   9 DELETE R0=A(NAME) R15=DSNAME/DDNAME ADDR OR 0
*MEXIT #=    24 LV= 2 ZDELETE
*MEXIT #=    23 LV= 1 DELETE
         LTR  R15,R15
         BNZ  ABORT
*MCALL #=    25 LV= 1          LOAD DE=BLDLE1   LOAD DEMO
         LA    0,BLDLE1
         AHI   0,2
         SR    15,15 USE DEFAULT SYS390 SEARCH
         SVC   8 LOAD R0=A(NAME) R15=DDNAME/DSNAME ADDR OR 0
*MEXIT #=    25 LV= 1 LOAD
         LTR  R15,R15
         BNZ  ABORT
         LR   R15,R0      CALL DEMO
         BALR R14,R15
*MCALL #=    26 LV= 1          DELETE DE=BLDLE1 DELETE DEMO
*MCALL #=    27 LV= 2         ZDELETE DE=BLDLE1,EP=,EPLOC=,DDNAME=,DSNAX
               ME=,MF=I,RELATED=
         LA    0,BLDLE1
         AHI   0,2
         SR    15,15 USE DEFAULT SYS390 SEARCH
         SVC   9 DELETE R0=A(NAME) R15=DSNAME/DDNAME ADDR OR 0
*MEXIT #=    27 LV= 2 ZDELETE
*MEXIT #=    26 LV= 1 DELETE
         LTR  R15,R15
         BNZ  ABORT
         MVC  BLDL,=H'1' CHANGE COUNT TO 1 FOR BLDL AND VER DEMO
*MCALL #=    28 LV= 1          BLDL 0,BLDL
         LA    1,BLDL
         SVC   X'12' BLDL R1=BLDL LIST LL(LL,NAME,TTR,KZC,USER),(...)
*MEXIT #=    28 LV= 1 BLDL
         CL   R15,=F'0'     ALL ENTRIES FOUND
*MCALL #=    29 LV= 1          RT1  CCE
         DS    0H
RT1_TEST9        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE9
         LTORG 
RT1_CCE9        DS 0H
*MEXIT #=    29 LV= 1 RT1
         CLI  BLDLE1+2+10,1 DEMO     R=1 FOUND
*MCALL #=    30 LV= 1          RT1  CCE
         DS    0H
RT1_TEST10       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE10
         LTORG 
RT1_CCE10       DS 0H
*MEXIT #=    30 LV= 1 RT1
         CLI  BLDLE1+2+12,0 DEMO     Z=0 FOUND IN SYS390 DIR DEMO\
*MCALL #=    31 LV= 1          RT1  CCE
         DS    0H
RT1_TEST11       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE11
         LTORG 
RT1_CCE11       DS 0H
*MEXIT #=    31 LV= 1 RT1
*MCALL #=    32 LV= 1          RT1  END
         B      RT1_END
*MEXIT #=    32 LV= 1 RT1
         END 
