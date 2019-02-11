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
* 2005-11-19 DSH RPI-102 Test new non-390 file loading              *
*                        DDNAME/DSNAME option                       *
* 2005-11-25 DSH RPI-111 Test loading same file twice and deleting  *
*                        twice                                      *
* 2005-02-07 DSH RPI-532 Correct path case for Linux                *
*********************************************************************
         TITLE 'TESTLOD2 TEST LOAD DDNAME AND DSNAME OPTIONS'
*MCALL #=     1 LV= 1 TESTLOD2 RT1  MAIN
*MCALL #=     2 LV= 2 TESTLOD2 SUBENTRY 
TESTLOD2 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTLOD2'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTLOD2+8,13
*MEXIT #=     2 LV= 2 SUBENTRY
*MCALL #=     3 LV= 2          WTO   'TESTLOD2 RT1 STARTED'
         BRAS  1,*+(WTO#0003_EOT-*+1)/2*2
         DC    AL2(WTO#0003_EOT-*,0),C'TESTLOD2 RT1 STARTED'
WTO#0003_EOT     EQU *
         SVC   35
*MEXIT #=     3 LV= 2 WTO
         BRCL    15,RT1_START
RT1_ABORT DS 0H
         MVI   RT1_ABORTED,C'T'
*MCALL #=     4 LV= 2          WTO   'TESTLOD2 RT1 TESTING ABORTED'
         BRAS  1,*+(WTO#0004_EOT-*+1)/2*2
         DC    AL2(WTO#0004_EOT-*,0),C'TESTLOD2 RT1 TESTING ABORTED'
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
*MCALL #=     6 LV= 2          WTO   'TESTLOD2 RT1 ENDED OK'
         BRAS  1,*+(WTO#0006_EOT-*+1)/2*2
         DC    AL2(WTO#0006_EOT-*,0),C'TESTLOD2 RT1 ENDED OK'
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
RT1_WTO1 DC    AL2(RT1_WTO_END-*,0),C'TESTLOD2 RT1 TESTS COMPLETED = '
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
DSNFILE1 DC   C'rt\test\TESTLOD2.TF2',X'00'
DSNFILE2 DC   C'rt\test\TESTLOD2.TF3',X'00'
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
*MCALL #=    13 LV= 1          LOAD DSNAME=DSNFILE1
         SR    0,0
         LA    15,DSNFILE1
         SVC   8 LOAD R0=A(NAME) R15=DDNAME/DSNAME ADDR OR 0
*MEXIT #=    13 LV= 1 LOAD
         LTR  R15,R15
         BNZ  ABORT
         LR   R2,R0
         LR   R3,R1
         LA   R6,0(R2,R3)
*MCALL #=    14 LV= 1          SNAP STORAGE=((R2),(R6)),TEXT='SNAP FILEX
                1'
*MCALL #=    15 LV= 2          ZOPTLR 14,R2
         LR    14,R2
*MEXIT #=    15 LV= 2 ZOPTLR
*MCALL #=    16 LV= 2          ZOPTLR 15,R6
         LR    15,R6
*MEXIT #=    16 LV= 2 ZOPTLR
         IILL  0,0                  RPI158
         IILH 0,64512               RPI158
         LA    1,=CL60'SNAP FILE 1'
         SVC   51  SNAP DUMP R0=FLAGS,ID,R1=A(TEXT),R14-15=A(LOW,HIGH)
*MEXIT #=    14 LV= 1 SNAP
*MCALL #=    17 LV= 1          LOAD DSNAME=DSNFILE2
         SR    0,0
         LA    15,DSNFILE2
         SVC   8 LOAD R0=A(NAME) R15=DDNAME/DSNAME ADDR OR 0
*MEXIT #=    17 LV= 1 LOAD
         LTR  R15,R15
         BNZ  ABORT
*MCALL #=    18 LV= 1          LOAD DSNAME=DSNFILE2 LOAD IT AGAIN TO GEX
               T USE COUNT 2
         SR    0,0
         LA    15,DSNFILE2
         SVC   8 LOAD R0=A(NAME) R15=DDNAME/DSNAME ADDR OR 0
*MEXIT #=    18 LV= 1 LOAD
         LTR  R15,R15
         BNZ  ABORT
         LR   R4,R0
         LR   R5,R1
         LR   R5,R1
         LA   R6,0(R4,R5)
*MCALL #=    19 LV= 1          SNAP STORAGE=((R4),(R6)),TEXT='SNAP FILEX
                2'
*MCALL #=    20 LV= 2          ZOPTLR 14,R4
         LR    14,R4
*MEXIT #=    20 LV= 2 ZOPTLR
*MCALL #=    21 LV= 2          ZOPTLR 15,R6
         LR    15,R6
*MEXIT #=    21 LV= 2 ZOPTLR
         IILL  0,0                  RPI158
         IILH 0,64512               RPI158
         LA    1,=CL60'SNAP FILE 2'
         SVC   51  SNAP DUMP R0=FLAGS,ID,R1=A(TEXT),R14-15=A(LOW,HIGH)
*MEXIT #=    19 LV= 1 SNAP
         CLCL R2,R4    COMPARE FILE1 TO FILE2
*MCALL #=    22 LV= 1          RT1  CCE      VERIFY FILES EQUAL
         DS    0H
RT1_TEST1        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1
         LTORG 
RT1_CCE1        DS 0H
*MEXIT #=    22 LV= 1 RT1
*MCALL #=    23 LV= 1          SNAP TEXT='CDES BEFORE DELETES',PDATA=CDX
               E
         IILL  0,0                  RPI158
         IILH 0,4096               RPI158
         LA    1,=CL60'CDES BEFORE DELETES'
         SVC   51  SNAP DUMP R0=FLAGS,ID,R1=A(TEXT),R14-15=A(LOW,HIGH)
*MEXIT #=    23 LV= 1 SNAP
*MCALL #=    24 LV= 1          DELETE DSNAME=DSNFILE1
*MCALL #=    25 LV= 2         ZDELETE DE=,EP=,EPLOC=,DDNAME=,DSNAME=DSNX
               FILE1,MF=I,RELATED=
         SR    0,0
         LA    15,DSNFILE1
         SVC   9 DELETE R0=A(NAME) R15=DSNAME/DDNAME ADDR OR 0
*MEXIT #=    25 LV= 2 ZDELETE
*MEXIT #=    24 LV= 1 DELETE
         LTR  R15,R15
         BNZ  ABORT
*MCALL #=    26 LV= 1          DELETE DSNAME=DSNFILE2  DELETE ONCE TO GX
               ET USE COUNT 1
*MCALL #=    27 LV= 2         ZDELETE DE=,EP=,EPLOC=,DDNAME=,DSNAME=DSNX
               FILE2,MF=I,RELATED=
         SR    0,0
         LA    15,DSNFILE2
         SVC   9 DELETE R0=A(NAME) R15=DSNAME/DDNAME ADDR OR 0
*MEXIT #=    27 LV= 2 ZDELETE
*MEXIT #=    26 LV= 1 DELETE
         LTR  R15,R15
         BNZ  ABORT
*MCALL #=    28 LV= 1          DELETE DSNAME=DSNFILE2  DELETE AGAIN TO X
               REALLY DELETE
*MCALL #=    29 LV= 2         ZDELETE DE=,EP=,EPLOC=,DDNAME=,DSNAME=DSNX
               FILE2,MF=I,RELATED=
         SR    0,0
         LA    15,DSNFILE2
         SVC   9 DELETE R0=A(NAME) R15=DSNAME/DDNAME ADDR OR 0
*MEXIT #=    29 LV= 2 ZDELETE
*MEXIT #=    28 LV= 1 DELETE
         LTR  R15,R15
         BNZ  ABORT
*MCALL #=    30 LV= 1          SNAP TEXT='CDES AFTER DELETES',PDATA=CDE
         IILL  0,0                  RPI158
         IILH 0,4096               RPI158
         LA    1,=CL60'CDES AFTER DELETES'
         SVC   51  SNAP DUMP R0=FLAGS,ID,R1=A(TEXT),R14-15=A(LOW,HIGH)
*MEXIT #=    30 LV= 1 SNAP
*MCALL #=    31 LV= 1          RT1  END
         B      RT1_END
*MEXIT #=    31 LV= 1 RT1
         END 
