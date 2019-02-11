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
* 2007-04-26 DSH RPI-598 Add additional CDE SNAPs to verify OK      *
*********************************************************************
         TITLE 'TESTXCL2 TEST TESTXCL2 XCTL TO TESTXCL3'
*MCALL #=     1 LV= 1 TESTXCL2 SUBENTRY 
TESTXCL2 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTXCL2'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTXCL2+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
*MCALL #=     2 LV= 1          WTO   'TESTXCL2 ENTERED'
         BRAS  1,*+(WTO#0002_EOT-*+1)/2*2
         DC    AL2(WTO#0002_EOT-*,0),C'TESTXCL2 ENTERED'
WTO#0002_EOT     EQU *
         SVC   35
*MEXIT #=     2 LV= 1 WTO
*MCALL #=     3 LV= 1          SNAP  ID=21,PDATA=CDE,TEXT='TESTXCL2 VERX
               IFY TESTXCL1+2 CDES'
         IILL  0,21                  RPI158
         IILH 0,4096               RPI158
         LA    1,=CL60'TESTXCL2 VERIFY TESTXCL1+2 CDES'
         SVC   51  SNAP DUMP R0=FLAGS,ID,R1=A(TEXT),R14-15=A(LOW,HIGH)
*MEXIT #=     3 LV= 1 SNAP
*MCALL #=     4 LV= 1          GETMAIN R,LV=256
         L    1,=A(256)  RPI 117
         LA    0,B'00'
         SVC   4 GMAIN R0=(X'02'=31B,X'01'=COND),R1=LEN OUT(R0=L,R1=A)
*MEXIT #=     4 LV= 1 GETMAIN
         XC    0(256,1),0(1) CLEAR IT
         LA    2,256(1)
*MCALL #=     5 LV= 1          SNAP  ID=22,PDATA=CDE,STORAGE=((1),(2)),X
               TEXT='TESTXCL2 AREA'
*MCALL #=     6 LV= 2          ZOPTLR 14,1
         LR    14,1
*MEXIT #=     6 LV= 2 ZOPTLR
*MCALL #=     7 LV= 2          ZOPTLR 15,2
         LR    15,2
*MEXIT #=     7 LV= 2 ZOPTLR
         IILL  0,22                  RPI158
         IILH 0,36864               RPI158
         LA    1,=CL60'TESTXCL2 AREA'
         SVC   51  SNAP DUMP R0=FLAGS,ID,R1=A(TEXT),R14-15=A(LOW,HIGH)
*MEXIT #=     5 LV= 1 SNAP
*MCALL #=     8 LV= 1          WTO   'TESTXCL2 NOW XCTL TO TESTXCL3'
         BRAS  1,*+(WTO#0008_EOT-*+1)/2*2
         DC    AL2(WTO#0008_EOT-*,0),C'TESTXCL2 NOW XCTL TO TESTXCL3'
WTO#0008_EOT     EQU *
         SVC   35
*MEXIT #=     8 LV= 1 WTO
         BALR  12,0         ESTABLISH TEMP BASE FOR XCTL USE
         USING *,12
         L     13,4(13)            RESTORE TESTXCL1 SAVE AREA POINTER
*MCALL #=     9 LV= 1          XCTL  (2,12),EP=TESTXCL3  RESTORE REGS,DX
               EL XCL2, TRANS XCL3
         LA    0,=CL8'TESTXCL3'
         SR    15,15 USE DEFAULT SYS390 SEARCH
*MCALL #=    10 LV= 2          RESTORE (2,12)
         LM    2,12,20+4*2(13)
*MEXIT #=    10 LV= 2 RESTORE
         SVC    7 XCTL R0=A(PGM) R1-PARMS R15=DDNAME/DSNAME ADDR OR 0
*MEXIT #=     9 LV= 1 XCTL
         END 
