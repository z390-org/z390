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
* 2006-05-01 DSH         Initial version                            *
* 2006-05-01 DSH RPI-305 Test ESTAE EXIT with parameter and RESTART *
* 2006-09-18 DSH RPI-305 Test REPEAT usage                          *
* 2006-11-10 DSH RPI-475 Test ESTAE EXIT,CT,PARAM=RESTART           *
* 2007-06-10 DSH RPI-636 Require R15=4 for restart, R15=0 for       *
*                        percolate                                  *
* 2007-07-18 DSH RPI-659 Test RESTART with R15=4 and R0=RESTART PSW *
* 2008-06-22 DSH RPI-845 Change ESTAE EXIT to use R1=SDWA,          *
*                        R2=ESAEPARM                                *
*********************************************************************
         TITLE 'TESTSTA1 - TEST ESTAE'
*MCALL #=     1 LV= 1 TESTSTA1 SUBENTRY 
TESTSTA1 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTSTA1'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTSTA1+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
*MCALL #=     2 LV= 1          WTO   'TESTSTA1 TEST ESTAE STARTED'
         BRAS  1,*+(WTO#0002_EOT-*+1)/2*2
         DC    AL2(WTO#0002_EOT-*,0),C'TESTSTA1 TEST ESTAE STARTED'
WTO#0002_EOT     EQU *
         SVC   35
*MEXIT #=     2 LV= 1 WTO
*MCALL #=     3 LV= 1          ESTAE EXIT,PARAM=RESTART
        LA     0,EXIT
        LA     1,RESTART
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=     3 LV= 1 ESTAE
         DC    X'0000' CAUSE 0C1
RESTART  DS    0H
         AP    COUNT,=P'1'
         CP    COUNT,=P'1'
         BE    RESTART2
         BH    RESTART3
*MCALL #=     4 LV= 1 RESTART1 WTO   'TESTSTA1 RESTART1 SUCCESSFUL'
RESTART1 DS    0H
         BRAS  1,*+(WTO#0004_EOT-*+1)/2*2
         DC    AL2(WTO#0004_EOT-*,0),C'TESTSTA1 RESTART1 SUCCESSFUL'
WTO#0004_EOT     EQU *
         SVC   35
*MEXIT #=     4 LV= 1 WTO
         DC    X'0000' CAUSE 0C1
*MCALL #=     5 LV= 1 RESTART2 WTO   'TESTSTA1 RESTART2 SUCCESSFUL'
RESTART2 DS    0H
         BRAS  1,*+(WTO#0005_EOT-*+1)/2*2
         DC    AL2(WTO#0005_EOT-*,0),C'TESTSTA1 RESTART2 SUCCESSFUL'
WTO#0005_EOT     EQU *
         SVC   35
*MEXIT #=     5 LV= 1 WTO
*MCALL #=     6 LV= 1          ESTAE EXIT,CT,PARAM=RESTART
        LA     0,EXIT
        LA     1,RESTART
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=     6 LV= 1 ESTAE
         DC    X'0000' CAUSE 0C1
*MCALL #=     7 LV= 1 RESTART3 WTO   'TESTSTA1 RESTART3 SUCCESSFUL'
RESTART3 DS    0H
         BRAS  1,*+(WTO#0007_EOT-*+1)/2*2
         DC    AL2(WTO#0007_EOT-*,0),C'TESTSTA1 RESTART3 SUCCESSFUL'
WTO#0007_EOT     EQU *
         SVC   35
*MEXIT #=     7 LV= 1 WTO
*MCALL #=     8 LV= 1          WTO   'TESTSTA1 ENDED OK'
         BRAS  1,*+(WTO#0008_EOT-*+1)/2*2
         DC    AL2(WTO#0008_EOT-*,0),C'TESTSTA1 ENDED OK'
WTO#0008_EOT     EQU *
         SVC   35
*MEXIT #=     8 LV= 1 WTO
*MCALL #=     9 LV= 1          SUBEXIT 
         LA    15,0
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=     9 LV= 1 SUBEXIT
         LTORG 
         DROP 
EXIT     DS    0H
         USING *,R15
         USING SDWA,R1        SYSTEM DIAGNOSTIC WORK AREA
         LR    R0,R2          SET RESTART ADDRESS TO ESTAPARM ADDR
         LA    R15,4          REQUEST RESTART CURRENT TASK AT (R0)
         BR    R14
COUNT    DC    P'0'
*MCALL #=    10 LV= 1          IHASDWA 
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
*MEXIT #=    10 LV= 1 IHASDWA
*MCALL #=    11 LV= 1          EQUREGS 
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
*MEXIT #=    11 LV= 1 EQUREGS
         END 
