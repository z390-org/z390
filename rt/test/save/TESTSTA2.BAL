*********************************************************************
* Copyright 2007 Automated Software Tools Corporation               *
* Copyright 2013 Cat Herder Software, LLC                           *
* Copyright 2018 Joachim Bartz, Germany                             *
*                                                                   *
* This source code is part of z390 assembler/emulator package.      *
*                                                                   *
* The z390 package is distributed under GNU general public license  *
*                                                                   *
* Author - Don Higgins                                              *
*********************************************************************
* 2007-06-10 DSH         Initial version                            *
* 2007-06-10 DSH RPI-636 Test R15=0 for percolate and cancel links  *
* 2007-07-18 DSH RPI-659 Test RESTART EXIT with R15=4 and R0=NEW    *
*                        RESTART PSW                                *
* 2008-06-22 DSH RPI-845 Change ESTAE EXIT to use R1=SDWA,          *
*                        R2=ESAEPARM                                *
*********************************************************************
         TITLE 'TESTSTA2 - TEST ESTAE EXIT RESTART AND PERCOLATE'
*MCALL #=     1 LV= 1 TESTSTA2 SUBENTRY 
TESTSTA2 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTSTA2'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTSTA2+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
*MCALL #=     2 LV= 1          WTO   'TESTSTA2 TEST ESTAE EXIT RESTART X
               AND PERCOLATE'
         BRAS  1,*+(WTO#0002_EOT-*+1)/2*2
         DC    AL2(WTO#0002_EOT-*,0),C'TESTSTA2 TEST ESTAE EXIT RESTARTX
                AND PERCOLATE'
WTO#0002_EOT     EQU *
         SVC   35
*MEXIT #=     2 LV= 1 WTO
*MCALL #=     3 LV= 1          WTO   'TESTSTA2 SET  ESTAE EXIT FOR PEROX
               COLATE FROM TESTSTA3'
         BRAS  1,*+(WTO#0003_EOT-*+1)/2*2
         DC    AL2(WTO#0003_EOT-*,0),C'TESTSTA2 SET  ESTAE EXIT FOR PERX
               OCOLATE FROM TESTSTA3'
WTO#0003_EOT     EQU *
         SVC   35
*MEXIT #=     3 LV= 1 WTO
*MCALL #=     4 LV= 1          ESTAE EXIT,PARAM=RESTART
        LA     0,EXIT
        LA     1,RESTART
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=     4 LV= 1 ESTAE
*MCALL #=     5 LV= 1          WTO   'TESTSTA2 LINK TO TESTSTA3'
         BRAS  1,*+(WTO#0005_EOT-*+1)/2*2
         DC    AL2(WTO#0005_EOT-*,0),C'TESTSTA2 LINK TO TESTSTA3'
WTO#0005_EOT     EQU *
         SVC   35
*MEXIT #=     5 LV= 1 WTO
*MCALL #=     6 LV= 1          LINK  EP=TESTSTA3
         LA    0,=CL8'TESTSTA3'
         SR    15,15 USE DEFAULT SYS390 SEARCH
         SVC    6 LINK R0=A(PGM) R1-PARMS R15=DDNAME/DSNAME ADDR OR 0
*MEXIT #=     6 LV= 1 LINK
*MCALL #=     7 LV= 1          WTO   'TESTSTA2 RETURN FROM TESTSTA3 SHOX
               ULD NOT OCCUR'
         BRAS  1,*+(WTO#0007_EOT-*+1)/2*2
         DC    AL2(WTO#0007_EOT-*,0),C'TESTSTA2 RETURN FROM TESTSTA3 SHX
               OULD NOT OCCUR'
WTO#0007_EOT     EQU *
         SVC   35
*MEXIT #=     7 LV= 1 WTO
*MCALL #=     8 LV= 1          ABEND 111,DUMP
         LA   1,111
         OILH 1,X'8000'
         SVC  13 ABEND R1=COMP CODE AND HIGH BIT = DUMP PGM STORAGE
*MEXIT #=     8 LV= 1 ABEND
RESTART  EQU   *
         BALR  R1,0              SET RESTART ADDRESSABILITY
         USING *,R1
         L     R13,=A(TESTSTA2+8) RELOAD TESTSTA2 BASE AND SAVE AREA
         DROP  R1
*MCALL #=     9 LV= 1          WTO   'TESTSTA2 RESTARTED AFTER TESTSTA3X
                ABEND'
         BRAS  1,*+(WTO#0009_EOT-*+1)/2*2
         DC    AL2(WTO#0009_EOT-*,0),C'TESTSTA2 RESTARTED AFTER TESTSTAX
               3 ABEND'
WTO#0009_EOT     EQU *
         SVC   35
*MEXIT #=     9 LV= 1 WTO
*MCALL #=    10 LV= 1          WTO   'TESTSTA2 ENDING OK'
         BRAS  1,*+(WTO#0010_EOT-*+1)/2*2
         DC    AL2(WTO#0010_EOT-*,0),C'TESTSTA2 ENDING OK'
WTO#0010_EOT     EQU *
         SVC   35
*MEXIT #=    10 LV= 1 WTO
*MCALL #=    11 LV= 1          SUBEXIT 
         LA    15,0
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=    11 LV= 1 SUBEXIT
         LTORG 
         DROP 
EXIT     DS    0H
*
* ENTERED VIA PERCOLATE FROM TESTSTA3 EXIT
* AFTER REMOVING TESTSTA3 FROM LINK STACK
*
         USING *,R15
         USING SDWA,R1
*MCALL #=    12 LV= 1          WTO   'TESTSTA2 ESTAE EXIT REQUESTING REX
               START'
         BRAS  1,*+(WTO#0012_EOT-*+1)/2*2
         DC    AL2(WTO#0012_EOT-*,0),C'TESTSTA2 ESTAE EXIT REQUESTING RX
               ESTART'
WTO#0012_EOT     EQU *
         SVC   35
*MEXIT #=    12 LV= 1 WTO
         LR    R0,R2          REQUEST RESTART TASK AR ESAEPARM ADDR
         LA    R15,4          REQUEST RESTART CURRENT TASK AT (R0)
         BR    R14
*MCALL #=    13 LV= 1          IHASDWA 
SDWA     DSECT 
SDWAPARM DS    A    ESTAE PARM ADDRESS
SDWAABSS DS    0BL4 COMPLETION CODE
SDWACMPF DS    B    COMPLETION CODE FLAGS
SDWACMPC DS    BL3  COMPLETION CODE (FIRST 12 BITS SYS,LAST 12 USER)
         ORG   SDWA+X'68'
SDWAEC1  DS    XL8  EXTENDED CONTROL PSW AT ERROR
         ORG   SDWA+X'170'
SDWAXPAD DS    A    ADDR OF POINTERS EXTENSION SDWAPTRS
SDWAPTRS DSECT 
         ORG   SDWAPTRS+X'18'
SDWAXEME DS    A    ADDR OF 64 BIT REGISTER INFO
SDWARC4  DSECT 
SDWAG64  DS    16XL8 16 - 64 BIT GPRS AT ERROR
*MEXIT #=    13 LV= 1 IHASDWA
*MCALL #=    14 LV= 1          EQUREGS 
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
*MEXIT #=    14 LV= 1 EQUREGS
         END 
