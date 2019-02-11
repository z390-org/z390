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
* 2005-11-16 DSH RPI-95  Test XCTL                                  *
* 2007-04-26 DSH RPI-598 Add additional CDE SNAPs to verify OK and  *
*                        REPEAT                                     *
*********************************************************************
         TITLE 'TESTXCL1 TEST LINK TO TESTXCL2, XCTL TO TESTXCL3'
*MCALL #=     1 LV= 1 TESTXCL1 SUBENTRY 
TESTXCL1 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTXCL1'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTXCL1+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
*MCALL #=     2 LV= 1          WTO   'TESTXCL1 STARTING'
         BRAS  1,*+(WTO#0002_EOT-*+1)/2*2
         DC    AL2(WTO#0002_EOT-*,0),C'TESTXCL1 STARTING'
WTO#0002_EOT     EQU *
         SVC   35
*MEXIT #=     2 LV= 1 WTO
*MCALL #=     3 LV= 1          SNAP  ID=11,PDATA=CDE,TEXT='TESTXCL1 VERX
               IFY TESTXCL1 CDE'
         IILL  0,11                  RPI158
         IILH 0,4096               RPI158
         LA    1,=CL60'TESTXCL1 VERIFY TESTXCL1 CDE'
         SVC   51  SNAP DUMP R0=FLAGS,ID,R1=A(TEXT),R14-15=A(LOW,HIGH)
*MEXIT #=     3 LV= 1 SNAP
*MCALL #=     4 LV= 1          WTO   'TESTXCL1 NOW LINKING TO TESTXCL2'
         BRAS  1,*+(WTO#0004_EOT-*+1)/2*2
         DC    AL2(WTO#0004_EOT-*,0),C'TESTXCL1 NOW LINKING TO TESTXCL2X
               '
WTO#0004_EOT     EQU *
         SVC   35
*MEXIT #=     4 LV= 1 WTO
*MCALL #=     5 LV= 1          LINK  EP=TESTXCL2
         LA    0,=CL8'TESTXCL2'
         SR    15,15 USE DEFAULT SYS390 SEARCH
         SVC    6 LINK R0=A(PGM) R1-PARMS R15=DDNAME/DSNAME ADDR OR 0
*MEXIT #=     5 LV= 1 LINK
*MCALL #=     6 LV= 1          WTO   'TESTXCL1 NOW BACK FROM TESTXCL4'
         BRAS  1,*+(WTO#0006_EOT-*+1)/2*2
         DC    AL2(WTO#0006_EOT-*,0),C'TESTXCL1 NOW BACK FROM TESTXCL4'
WTO#0006_EOT     EQU *
         SVC   35
*MEXIT #=     6 LV= 1 WTO
*MCALL #=     7 LV= 1          SNAP  ID=12,PDATA=CDE,TEXT='TESTXCL1 VERX
               IFY TESTXCL1+3 CDES'
         IILL  0,12                  RPI158
         IILH 0,4096               RPI158
         LA    1,=CL60'TESTXCL1 VERIFY TESTXCL1+3 CDES'
         SVC   51  SNAP DUMP R0=FLAGS,ID,R1=A(TEXT),R14-15=A(LOW,HIGH)
*MEXIT #=     7 LV= 1 SNAP
*MCALL #=     8 LV= 1          WTO   'TESTXCL1 REPEAT TEST'
         BRAS  1,*+(WTO#0008_EOT-*+1)/2*2
         DC    AL2(WTO#0008_EOT-*,0),C'TESTXCL1 REPEAT TEST'
WTO#0008_EOT     EQU *
         SVC   35
*MEXIT #=     8 LV= 1 WTO
*MCALL #=     9 LV= 1          SNAP  ID=13,PDATA=CDE,TEXT='TESTXCL1 VERX
               IFY TESTXCL1 CDE'
         IILL  0,13                  RPI158
         IILH 0,4096               RPI158
         LA    1,=CL60'TESTXCL1 VERIFY TESTXCL1 CDE'
         SVC   51  SNAP DUMP R0=FLAGS,ID,R1=A(TEXT),R14-15=A(LOW,HIGH)
*MEXIT #=     9 LV= 1 SNAP
*MCALL #=    10 LV= 1          WTO   'TESTXCL1 NOW LINKING TO TESTXCL2'
         BRAS  1,*+(WTO#0010_EOT-*+1)/2*2
         DC    AL2(WTO#0010_EOT-*,0),C'TESTXCL1 NOW LINKING TO TESTXCL2X
               '
WTO#0010_EOT     EQU *
         SVC   35
*MEXIT #=    10 LV= 1 WTO
*MCALL #=    11 LV= 1          LINK  EP=TESTXCL2
         LA    0,=CL8'TESTXCL2'
         SR    15,15 USE DEFAULT SYS390 SEARCH
         SVC    6 LINK R0=A(PGM) R1-PARMS R15=DDNAME/DSNAME ADDR OR 0
*MEXIT #=    11 LV= 1 LINK
*MCALL #=    12 LV= 1          WTO   'TESTXCL1 NOW BACK FROM TESTXCL4'
         BRAS  1,*+(WTO#0012_EOT-*+1)/2*2
         DC    AL2(WTO#0012_EOT-*,0),C'TESTXCL1 NOW BACK FROM TESTXCL4'
WTO#0012_EOT     EQU *
         SVC   35
*MEXIT #=    12 LV= 1 WTO
*MCALL #=    13 LV= 1          SNAP  ID=14,PDATA=CDE,TEXT='TESTXCL1 VERX
               IFY TESTXCL1+3 CDES'
         IILL  0,14                  RPI158
         IILH 0,4096               RPI158
         LA    1,=CL60'TESTXCL1 VERIFY TESTXCL1+3 CDES'
         SVC   51  SNAP DUMP R0=FLAGS,ID,R1=A(TEXT),R14-15=A(LOW,HIGH)
*MEXIT #=    13 LV= 1 SNAP
*MCALL #=    14 LV= 1          WTO   'TESTXCL1 NOW XCTL TO TESTXCL4'
         BRAS  1,*+(WTO#0014_EOT-*+1)/2*2
         DC    AL2(WTO#0014_EOT-*,0),C'TESTXCL1 NOW XCTL TO TESTXCL4'
WTO#0014_EOT     EQU *
         SVC   35
*MEXIT #=    14 LV= 1 WTO
         BALR  12,0         ESTABLISH TEMP BASE FOR XCTL USE
         USING *,12
         L     13,4(13)            RESTORE TESTXCL1 SAVE AREA POINTER
*MCALL #=    15 LV= 1          XCTL  (2,12),EP=TESTXCL4  RESTORE REGS,DX
               EL XCL1, TRANS XCL4
         LA    0,=CL8'TESTXCL4'
         SR    15,15 USE DEFAULT SYS390 SEARCH
*MCALL #=    16 LV= 2          RESTORE (2,12)
         LM    2,12,20+4*2(13)
*MEXIT #=    16 LV= 2 RESTORE
         SVC    7 XCTL R0=A(PGM) R1-PARMS R15=DDNAME/DSNAME ADDR OR 0
*MEXIT #=    15 LV= 1 XCTL
*        SUBEXIT
         END 
