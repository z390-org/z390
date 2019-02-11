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
* 2005-11-13 DSH RPI-I89 Add test of link and load DSNAME and       *
*                        DDNAME options                             *
* 2006-09-11 DSH RPI-362 Change from test to rt\test directory      *
* 2007-02-07 DSH RPI-532 Correct path case for Linux                *
*********************************************************************
         TITLE 'TESTLNK1 TEST LINK, LOAD, AND DELETE'
*MCALL #=     1 LV= 1 TESTLNK1 RT1  MAIN
*MCALL #=     2 LV= 2 TESTLNK1 SUBENTRY 
TESTLNK1 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTLNK1'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTLNK1+8,13
*MEXIT #=     2 LV= 2 SUBENTRY
*MCALL #=     3 LV= 2          WTO   'TESTLNK1 RT1 STARTED'
         BRAS  1,*+(WTO#0003_EOT-*+1)/2*2
         DC    AL2(WTO#0003_EOT-*,0),C'TESTLNK1 RT1 STARTED'
WTO#0003_EOT     EQU *
         SVC   35
*MEXIT #=     3 LV= 2 WTO
         BRCL    15,RT1_START
RT1_ABORT DS 0H
         MVI   RT1_ABORTED,C'T'
*MCALL #=     4 LV= 2          WTO   'TESTLNK1 RT1 TESTING ABORTED'
         BRAS  1,*+(WTO#0004_EOT-*+1)/2*2
         DC    AL2(WTO#0004_EOT-*,0),C'TESTLNK1 RT1 TESTING ABORTED'
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
*MCALL #=     6 LV= 2          WTO   'TESTLNK1 RT1 ENDED OK'
         BRAS  1,*+(WTO#0006_EOT-*+1)/2*2
         DC    AL2(WTO#0006_EOT-*,0),C'TESTLNK1 RT1 ENDED OK'
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
RT1_WTO1 DC    AL2(RT1_WTO_END-*,0),C'TESTLNK1 RT1 TESTS COMPLETED = '
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
DSNMDEMO DC   C'"rt\test;demo"'                     ".." MULT DIR LIST
*MCALL #=    10 LV= 1          RT1  START
RT1_START DS  0H
*MEXIT #=    10 LV= 1 RT1
*MCALL #=    11 LV= 1          LINK EP=TESTSUB1 EXEC IN AMODE31 PER LZ3X
               90 AMODE31 DEFAULT
         LA    0,=CL8'TESTSUB1'
         SR    15,15 USE DEFAULT SYS390 SEARCH
         SVC    6 LINK R0=A(PGM) R1-PARMS R15=DDNAME/DSNAME ADDR OR 0
*MEXIT #=    11 LV= 1 LINK
*MCALL #=    12 LV= 1          LOAD EP=TESTSUB1  USE=1
         LA    0,=CL8'TESTSUB1'
         SR    15,15 USE DEFAULT SYS390 SEARCH
         SVC   8 LOAD R0=A(NAME) R15=DDNAME/DSNAME ADDR OR 0
*MEXIT #=    12 LV= 1 LOAD
         LR   R3,R0
         LR   R15,R0
         BALR R14,R15
*MCALL #=    13 LV= 1          LOAD EP=TESTSUB1  USE=2
         LA    0,=CL8'TESTSUB1'
         SR    15,15 USE DEFAULT SYS390 SEARCH
         SVC   8 LOAD R0=A(NAME) R15=DDNAME/DSNAME ADDR OR 0
*MEXIT #=    13 LV= 1 LOAD
         LR   R4,R0
         LR   R15,R3
         BALR R14,R15
         CLR  R3,R4
*MCALL #=    14 LV= 1          RT1  CCE
         DS    0H
RT1_TEST1        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1
         LTORG 
RT1_CCE1        DS 0H
*MEXIT #=    14 LV= 1 RT1
*MCALL #=    15 LV= 1          DELETE EP=TESTSUB1 USE-1
*MCALL #=    16 LV= 2         ZDELETE DE=,EP=TESTSUB1,EPLOC=,DDNAME=,DSX
               NAME=,MF=I,RELATED=
         LA    0,=CL8'TESTSUB1'
         SR    15,15 USE DEFAULT SYS390 SEARCH
         SVC   9 DELETE R0=A(NAME) R15=DSNAME/DDNAME ADDR OR 0
*MEXIT #=    16 LV= 2 ZDELETE
*MEXIT #=    15 LV= 1 DELETE
*MCALL #=    17 LV= 1          DELETE EP=TESTSUB1 USE-0 CAUSES PHY DELEX
               TE
*MCALL #=    18 LV= 2         ZDELETE DE=,EP=TESTSUB1,EPLOC=,DDNAME=,DSX
               NAME=,MF=I,RELATED=
         LA    0,=CL8'TESTSUB1'
         SR    15,15 USE DEFAULT SYS390 SEARCH
         SVC   9 DELETE R0=A(NAME) R15=DSNAME/DDNAME ADDR OR 0
*MEXIT #=    18 LV= 2 ZDELETE
*MEXIT #=    17 LV= 1 DELETE
*MCALL #=    19 LV= 1          LOAD EP=TESTSUB4 REPLACE OLD ADDR WITH DX
               IFF MOD
         LA    0,=CL8'TESTSUB4'
         SR    15,15 USE DEFAULT SYS390 SEARCH
         SVC   8 LOAD R0=A(NAME) R15=DDNAME/DSNAME ADDR OR 0
*MEXIT #=    19 LV= 1 LOAD
         LR   R15,R0
         BALR R14,R15 EXEC IN CALLER AMODE31
*MCALL #=    20 LV= 1          LOAD EP=TESTSUB1 RELOAD AT DIFF ADDR
         LA    0,=CL8'TESTSUB1'
         SR    15,15 USE DEFAULT SYS390 SEARCH
         SVC   8 LOAD R0=A(NAME) R15=DDNAME/DSNAME ADDR OR 0
*MEXIT #=    20 LV= 1 LOAD
         LR   R4,R0
         LR   R15,R0
         BALR R14,R15
         CLR  R3,R4
*MCALL #=    21 LV= 1          RT1  CCH
         DS    0H
RT1_TEST2        BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH2
         LTORG 
RT1_CCH2        DS 0H
*MEXIT #=    21 LV= 1 RT1
*MCALL #=    22 LV= 1          LINK EP=TESTSUB4 EXEC IN AMODE24 PER LZ3X
               90 AMODE24 OPTION
         LA    0,=CL8'TESTSUB4'
         SR    15,15 USE DEFAULT SYS390 SEARCH
         SVC    6 LINK R0=A(PGM) R1-PARMS R15=DDNAME/DSNAME ADDR OR 0
*MEXIT #=    22 LV= 1 LINK
*MCALL #=    23 LV= 1          LINK EP=TESTSUB4 AGAIN AND RETURN TO CALX
               LER AMODE31
         LA    0,=CL8'TESTSUB4'
         SR    15,15 USE DEFAULT SYS390 SEARCH
         SVC    6 LINK R0=A(PGM) R1-PARMS R15=DDNAME/DSNAME ADDR OR 0
*MEXIT #=    23 LV= 1 LINK
*MCALL #=    24 LV= 1          LINK EP=TESTSUBX,DSNAME=DSNFSUB1  FILE NX
               AME OVERRIDES EP
         LA    0,=CL8'TESTSUBX'
         LA    15,DSNFSUB1
         SVC    6 LINK R0=A(PGM) R1-PARMS R15=DDNAME/DSNAME ADDR OR 0
*MEXIT #=    24 LV= 1 LINK
*MCALL #=    25 LV= 1          LINK EP=TESTSUB1,DSNAME=DSNDSUB1  DIR
         LA    0,=CL8'TESTSUB1'
         LA    15,DSNDSUB1
         SVC    6 LINK R0=A(PGM) R1-PARMS R15=DDNAME/DSNAME ADDR OR 0
*MEXIT #=    25 LV= 1 LINK
*MCALL #=    26 LV= 1          LINK EP=XXXX,DSNAME=DSNFDEMO      FILE NX
               AME OVERRIDES EP
         LA    0,=CL8'XXXX'
         LA    15,DSNFDEMO
         SVC    6 LINK R0=A(PGM) R1-PARMS R15=DDNAME/DSNAME ADDR OR 0
*MEXIT #=    26 LV= 1 LINK
*MCALL #=    27 LV= 1          LINK EP=DEMO,DSNAME=DSNDDEMO      DIR
         LA    0,=CL8'DEMO'
         LA    15,DSNDDEMO
         SVC    6 LINK R0=A(PGM) R1-PARMS R15=DDNAME/DSNAME ADDR OR 0
*MEXIT #=    27 LV= 1 LINK
*MCALL #=    28 LV= 1          LINK EP=DEMO,DSNAME=DSNMDEMO      MULT DX
               IR LIST (DEMO IN 2ND)
         LA    0,=CL8'DEMO'
         LA    15,DSNMDEMO
         SVC    6 LINK R0=A(PGM) R1-PARMS R15=DDNAME/DSNAME ADDR OR 0
*MEXIT #=    28 LV= 1 LINK
*MCALL #=    29 LV= 1          LINK EP=XXXX,DDNAME=DDTODEMO
         LA    0,=CL8'XXXX'
         LA    15,=CL8'DDTODEMO'
         OILH  15,X'8000' DD VS DSN
         SVC    6 LINK R0=A(PGM) R1-PARMS R15=DDNAME/DSNAME ADDR OR 0
*MEXIT #=    29 LV= 1 LINK
*MCALL #=    30 LV= 1          RT1  END
         B      RT1_END
*MEXIT #=    30 LV= 1 RT1
         END 
