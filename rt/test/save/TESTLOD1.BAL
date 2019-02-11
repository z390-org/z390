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
* 2005-11-16 DSH RPI-I89 Add test of link and load DSNAME and       *
*                        DDNAME options                             *
* 2006-09-11 DSH RPI-363 Change from test to rt\test directory      *
* 2007-02-07 DSH RPI-532 Correct path case for Linux                *
* 2008-10-24 DSH RPI-921 Test ERRET= EXIT option and load ZSTRMAC   *
*                        update                                     *
*********************************************************************
         TITLE 'TESTLOD1 TEST LOAD DDNAME AND DSNAME OPTIONS'
*MCALL #=     1 LV= 1 TESTLOD1 RT1  MAIN
*MCALL #=     2 LV= 2 TESTLOD1 SUBENTRY 
TESTLOD1 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTLOD1'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTLOD1+8,13
*MEXIT #=     2 LV= 2 SUBENTRY
*MCALL #=     3 LV= 2          WTO   'TESTLOD1 RT1 STARTED'
         BRAS  1,*+(WTO#0003_EOT-*+1)/2*2
         DC    AL2(WTO#0003_EOT-*,0),C'TESTLOD1 RT1 STARTED'
WTO#0003_EOT     EQU *
         SVC   35
*MEXIT #=     3 LV= 2 WTO
         BRCL    15,RT1_START
RT1_ABORT DS 0H
         MVI   RT1_ABORTED,C'T'
*MCALL #=     4 LV= 2          WTO   'TESTLOD1 RT1 TESTING ABORTED'
         BRAS  1,*+(WTO#0004_EOT-*+1)/2*2
         DC    AL2(WTO#0004_EOT-*,0),C'TESTLOD1 RT1 TESTING ABORTED'
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
*MCALL #=     6 LV= 2          WTO   'TESTLOD1 RT1 ENDED OK'
         BRAS  1,*+(WTO#0006_EOT-*+1)/2*2
         DC    AL2(WTO#0006_EOT-*,0),C'TESTLOD1 RT1 ENDED OK'
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
RT1_WTO1 DC    AL2(RT1_WTO_END-*,0),C'TESTLOD1 RT1 TESTS COMPLETED = '
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
DSNFSUB1 DC   C'rt\test\TESTSUB1.390',X'00'    NULL TERM DSNAME FILE
DSNDSUB1 DC   C'rt\test',X'00'                 NULL TERM DSNAME DIR
DSNFDEMO DC   C'"demo\DEMO.390"'            ".." FILE
DSNDDEMO DC   C'"demo"'                     ".." DIR
DSNMDEMO DC   C'"rt\test;demo"'             ".." MULT DIR LIST
PGMNAME  DC   CL8'TESTSUB1'
*MCALL #=    10 LV= 1 ABORT    WTO  'TESTLOD1 ABORTING DUE TO ERROR'
ABORT    DS    0H
         BRAS  1,*+(WTO#0010_EOT-*+1)/2*2
         DC    AL2(WTO#0010_EOT-*,0),C'TESTLOD1 ABORTING DUE TO ERROR'
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
*MCALL #=    13 LV= 1          LOAD EP=TESTSUB1
         LA    0,=CL8'TESTSUB1'
         SR    15,15 USE DEFAULT SYS390 SEARCH
         SVC   8 LOAD R0=A(NAME) R15=DDNAME/DSNAME ADDR OR 0
*MEXIT #=    13 LV= 1 LOAD
         LTR  R15,R15
         BNZ  ABORT
         LR   R15,R0
         BALR R14,R15
*MCALL #=    14 LV= 1          DELETE EP=TESTSUB1
*MCALL #=    15 LV= 2         ZDELETE DE=,EP=TESTSUB1,EPLOC=,DDNAME=,DSX
               NAME=,MF=I,RELATED=
         LA    0,=CL8'TESTSUB1'
         SR    15,15 USE DEFAULT SYS390 SEARCH
         SVC   9 DELETE R0=A(NAME) R15=DSNAME/DDNAME ADDR OR 0
*MEXIT #=    15 LV= 2 ZDELETE
*MEXIT #=    14 LV= 1 DELETE
         LTR  R15,R15
         BNZ  ABORT
         MVC  PGMNAME,=CL8'TESTSUB1'
*MCALL #=    16 LV= 1          LOAD EPLOC=PGMNAME
         LA    0,PGMNAME
         SR    15,15 USE DEFAULT SYS390 SEARCH
         SVC   8 LOAD R0=A(NAME) R15=DDNAME/DSNAME ADDR OR 0
*MEXIT #=    16 LV= 1 LOAD
         LTR  R15,R15
         BNZ  ABORT
         LR   R15,R0
         BALR R14,R15
*MCALL #=    17 LV= 1          DELETE EP=TESTSUB1
*MCALL #=    18 LV= 2         ZDELETE DE=,EP=TESTSUB1,EPLOC=,DDNAME=,DSX
               NAME=,MF=I,RELATED=
         LA    0,=CL8'TESTSUB1'
         SR    15,15 USE DEFAULT SYS390 SEARCH
         SVC   9 DELETE R0=A(NAME) R15=DSNAME/DDNAME ADDR OR 0
*MEXIT #=    18 LV= 2 ZDELETE
*MEXIT #=    17 LV= 1 DELETE
         LTR  R15,R15
         BNZ  ABORT
*MCALL #=    19 LV= 1          LOAD EP=TESTSUBX,DSNAME=DSNFSUB1  FILE NX
               AME OVERRIDES EP
         LA    0,=CL8'TESTSUBX'
         LA    15,DSNFSUB1
         SVC   8 LOAD R0=A(NAME) R15=DDNAME/DSNAME ADDR OR 0
*MEXIT #=    19 LV= 1 LOAD
         LTR  R15,R15
         BNZ  ABORT
         LR   R15,R0
         BALR R14,R15
*MCALL #=    20 LV= 1          DELETE EP=TESTSUB1
*MCALL #=    21 LV= 2         ZDELETE DE=,EP=TESTSUB1,EPLOC=,DDNAME=,DSX
               NAME=,MF=I,RELATED=
         LA    0,=CL8'TESTSUB1'
         SR    15,15 USE DEFAULT SYS390 SEARCH
         SVC   9 DELETE R0=A(NAME) R15=DSNAME/DDNAME ADDR OR 0
*MEXIT #=    21 LV= 2 ZDELETE
*MEXIT #=    20 LV= 1 DELETE
         LTR  R15,R15
         BNZ  ABORT
*MCALL #=    22 LV= 1          LOAD EP=TESTSUB1,DSNAME=DSNDSUB1  DIR
         LA    0,=CL8'TESTSUB1'
         LA    15,DSNDSUB1
         SVC   8 LOAD R0=A(NAME) R15=DDNAME/DSNAME ADDR OR 0
*MEXIT #=    22 LV= 1 LOAD
         LTR  R15,R15
         BNZ  ABORT
         LR   R15,R0
         BALR R14,R15
*MCALL #=    23 LV= 1          DELETE EP=TESTSUB1
*MCALL #=    24 LV= 2         ZDELETE DE=,EP=TESTSUB1,EPLOC=,DDNAME=,DSX
               NAME=,MF=I,RELATED=
         LA    0,=CL8'TESTSUB1'
         SR    15,15 USE DEFAULT SYS390 SEARCH
         SVC   9 DELETE R0=A(NAME) R15=DSNAME/DDNAME ADDR OR 0
*MEXIT #=    24 LV= 2 ZDELETE
*MEXIT #=    23 LV= 1 DELETE
         LTR  R15,R15
         BNZ  ABORT
*MCALL #=    25 LV= 1          LOAD EP=XXXX,DSNAME=DSNFDEMO      FILE NX
               AME OVERRIDES EP
         LA    0,=CL8'XXXX'
         LA    15,DSNFDEMO
         SVC   8 LOAD R0=A(NAME) R15=DDNAME/DSNAME ADDR OR 0
*MEXIT #=    25 LV= 1 LOAD
         LTR  R15,R15
         BNZ  ABORT
         LR   R15,R0
         BALR R14,R15
*MCALL #=    26 LV= 1          DELETE EP=DEMO
*MCALL #=    27 LV= 2         ZDELETE DE=,EP=DEMO,EPLOC=,DDNAME=,DSNAMEX
               =,MF=I,RELATED=
         LA    0,=CL8'DEMO'
         SR    15,15 USE DEFAULT SYS390 SEARCH
         SVC   9 DELETE R0=A(NAME) R15=DSNAME/DDNAME ADDR OR 0
*MEXIT #=    27 LV= 2 ZDELETE
*MEXIT #=    26 LV= 1 DELETE
         LTR  R15,R15
         BNZ  ABORT
*MCALL #=    28 LV= 1          LOAD EP=DEMO,DSNAME=DSNDDEMO      DIR
         LA    0,=CL8'DEMO'
         LA    15,DSNDDEMO
         SVC   8 LOAD R0=A(NAME) R15=DDNAME/DSNAME ADDR OR 0
*MEXIT #=    28 LV= 1 LOAD
         LTR  R15,R15
         BNZ  ABORT
         LR   R15,R0
         BALR R14,R15
*MCALL #=    29 LV= 1          DELETE EP=DEMO
*MCALL #=    30 LV= 2         ZDELETE DE=,EP=DEMO,EPLOC=,DDNAME=,DSNAMEX
               =,MF=I,RELATED=
         LA    0,=CL8'DEMO'
         SR    15,15 USE DEFAULT SYS390 SEARCH
         SVC   9 DELETE R0=A(NAME) R15=DSNAME/DDNAME ADDR OR 0
*MEXIT #=    30 LV= 2 ZDELETE
*MEXIT #=    29 LV= 1 DELETE
         LTR  R15,R15
         BNZ  ABORT
*MCALL #=    31 LV= 1          LOAD EP=DEMO,DSNAME=DSNMDEMO      MULT DX
               IR LIST (DEMO IN 2ND)
         LA    0,=CL8'DEMO'
         LA    15,DSNMDEMO
         SVC   8 LOAD R0=A(NAME) R15=DDNAME/DSNAME ADDR OR 0
*MEXIT #=    31 LV= 1 LOAD
         LTR  R15,R15
         BNZ  ABORT
         LR   R15,R0
         BALR R14,R15
*MCALL #=    32 LV= 1          DELETE EP=DEMO
*MCALL #=    33 LV= 2         ZDELETE DE=,EP=DEMO,EPLOC=,DDNAME=,DSNAMEX
               =,MF=I,RELATED=
         LA    0,=CL8'DEMO'
         SR    15,15 USE DEFAULT SYS390 SEARCH
         SVC   9 DELETE R0=A(NAME) R15=DSNAME/DDNAME ADDR OR 0
*MEXIT #=    33 LV= 2 ZDELETE
*MEXIT #=    32 LV= 1 DELETE
         LTR  R15,R15
         BNZ  ABORT
*MCALL #=    34 LV= 1          LOAD EP=XXXX,DDNAME=DDTODEMO
         LA    0,=CL8'XXXX'
         LA    15,=CL8'DDTODEMO'
         OILH  15,X'8000' DD VS DSN
         SVC   8 LOAD R0=A(NAME) R15=DDNAME/DSNAME ADDR OR 0
*MEXIT #=    34 LV= 1 LOAD
         LTR  R15,R15
         BNZ  ABORT
         LR   R15,R0
         BALR R14,R15
*MCALL #=    35 LV= 1          DELETE EP=DEMO
*MCALL #=    36 LV= 2         ZDELETE DE=,EP=DEMO,EPLOC=,DDNAME=,DSNAMEX
               =,MF=I,RELATED=
         LA    0,=CL8'DEMO'
         SR    15,15 USE DEFAULT SYS390 SEARCH
         SVC   9 DELETE R0=A(NAME) R15=DSNAME/DDNAME ADDR OR 0
*MEXIT #=    36 LV= 2 ZDELETE
*MEXIT #=    35 LV= 1 DELETE
         LTR  R15,R15
         BNZ  ABORT
* RPI 921 TEST ERRET EXIT
*MCALL #=    37 LV= 1          LOAD  EP=JUNK1,ERRET=FAIL1
         LA    0,=CL8'JUNK1'
         SR    15,15 USE DEFAULT SYS390 SEARCH
         SVC   8 LOAD R0=A(NAME) R15=DDNAME/DSNAME ADDR OR 0
         LTR   15,15
         BNZ   FAIL1
*MEXIT #=    37 LV= 1 LOAD
         B     ABORT
FAIL1    DS    0H
         LA    3,FAIL2
*MCALL #=    38 LV= 1          LOAD  EP=JUNK2,ERRET=(3)
         LA    0,=CL8'JUNK2'
         SR    15,15 USE DEFAULT SYS390 SEARCH
         SVC   8 LOAD R0=A(NAME) R15=DDNAME/DSNAME ADDR OR 0
         LTR   15,15
         BNZR  3
*MEXIT #=    38 LV= 1 LOAD
         B     ABORT
FAIL2    DS    0H
*MCALL #=    39 LV= 1          WTO  'TESTLOD1 ERRET TESTS OK'
         BRAS  1,*+(WTO#0039_EOT-*+1)/2*2
         DC    AL2(WTO#0039_EOT-*,0),C'TESTLOD1 ERRET TESTS OK'
WTO#0039_EOT     EQU *
         SVC   35
*MEXIT #=    39 LV= 1 WTO
*MCALL #=    40 LV= 1          RT1  END
         B      RT1_END
*MEXIT #=    40 LV= 1 RT1
         END 
