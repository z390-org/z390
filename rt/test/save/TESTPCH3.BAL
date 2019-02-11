*********************************************************************
* Copyright 2006 Automated Software Tools Corporation               *
* This source code is part of z390 assembler/emulator package       *
* The z390 package is distributed under GNU general public license  *
* Author - Don Higgins                                              *
* Date   - 08/30/06                                                 *
*********************************************************************
* 09/08/06 RPI 436 TEST COMMENTS AFTER AREAD/PUNCH PARMS
* 04/22/08 RPI 833 ADD STRING QUOTES FOR HLASM COMPATIBILITY
*********************************************************************
*MCALL #=     1 LV= 1 TESTPCH3 SUBENTRY 
TESTPCH3 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTPCH3'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTPCH3+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
*MCALL #=     2 LV= 1          WTO   'START TESTPCH3 COPY AND MERGE 2 TX
               EST FILES'
         BRAS  1,*+(WTO#0002_EOT-*+1)/2*2
         DC    AL2(WTO#0002_EOT-*,0),C'START TESTPCH3 COPY AND MERGE 2 X
               TEST FILES'
WTO#0002_EOT     EQU *
         SVC   35
*MEXIT #=     2 LV= 1 WTO
         PUNCH 'testpch3.in1 record 1',DDNAME=OT1,ID=1  TEST COMMENT 2
         PUNCH 'testpch3.in1 record 1',DDNAME=OT3,ID=2
         PUNCH 'testpch3.in1 record 2',DDNAME=OT1,ID=1  TEST COMMENT 2
         PUNCH 'testpch3.in1 record 2',DDNAME=OT3,ID=2
         PUNCH 'testpch3.in1 record 3',DDNAME=OT1,ID=1  TEST COMMENT 2
         PUNCH 'testpch3.in1 record 3',DDNAME=OT3,ID=2
         PUNCH 'testpch3.in2 record 1',DDNAME=OT2,ID=1
         PUNCH 'testpch3.in2 record 1',DDNAME=OT3,ID=2
         PUNCH 'testpch3.in2 record 2',DDNAME=OT2,ID=1
         PUNCH 'testpch3.in2 record 2',DDNAME=OT3,ID=2
         PUNCH 'testpch3.in2 record 3',DDNAME=OT2,ID=1
         PUNCH 'testpch3.in2 record 3',DDNAME=OT3,ID=2
*MCALL #=     3 LV= 1          WTO   'END TESTPCH3 OK'
         BRAS  1,*+(WTO#0003_EOT-*+1)/2*2
         DC    AL2(WTO#0003_EOT-*,0),C'END TESTPCH3 OK'
WTO#0003_EOT     EQU *
         SVC   35
*MEXIT #=     3 LV= 1 WTO
*MCALL #=     4 LV= 1          SUBEXIT 
         LA    15,0
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=     4 LV= 1 SUBEXIT
         END 
