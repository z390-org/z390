*********************************************************************
* Copyright 2008 Automated Software Tools Corporation               *
* Copyright 2013 Cat Herder Software, LLC                           *
* Copyright 2018 Joachim Bartz, Germany                             *
*                                                                   *
* This source code is part of z390 assembler/emulator package.      *
*                                                                   *
* The z390 package is distributed under GNU general public license  *
*                                                                   *
* Author - Don Higgins                                              *
*********************************************************************
* 2008-12-10  DSH         Initial version                           *
* 2008-12-10  DSH RPI-956 Initial test for AINSERT for AREAD/SOURCE *
*********************************************************************
         MACRO
         TEST1
         AINSERT 'RECORD 2 &SYSTIME',FRONT
         AINSERT 'RECORD 3 &SYSTIME',BACK
         AINSERT 'RECORD 1 &SYSTIME',FRONT
&REC     AREAD
         MNOTE 'AREAD AINSERT 1 = &REC'
&REC     AREAD
         MNOTE 'AREAD AINSERT 2 = &REC'
&REC     AREAD
         MNOTE 'AREAD AINSERT 3 = &REC'
         MEND
         MACRO
         TEST2
         AINSERT ' MNOTE ''SOURCE AINSERT 1''',BACK
         AINSERT ' MNOTE ''SOURCE AINSERT 2''',BACK
         AINSERT ' MNOTE ''SOURCE AINSERT 3''',BACK
         AINSERT ' MACRO',BACK
         AINSERT ' TEST3',BACK
         AINSERT ' MNOTE ''HELLO FROM TEST3 INSERTED MACRO''',BACK
         AINSERT ' MEND',BACK
         AINSERT ' MACRO',BACK
         AINSERT ' TEST4 &&P1, 3456789012345678901234567890123456789012X
               3456789012345678901X',BACK  NOTE ADD 1 MORE FOR &&
         AINSERT '               &&K1=''K1V'', 789012345678901234567890X
               123456789012345678901X',BACK NOTE ADD 3 FOR &&,'',''
         AINSERT '               &&K2=''K2V''',BACK
         AINSERT ' MNOTE ''TEST4 K1=&&K1 K2=&&K2''',BACK
         AINSERT '&&I SETA 5',BACK
         AINSERT '.LOOP ANOP',BACK
         AINSERT ' MNOTE ''TEST4 I=&&I''',BACK
         AINSERT '&&I SETA &&I-1',BACK
         AINSERT ' AIF (&&I GT 0).LOOP',BACK
         AINSERT ' MEND',BACK
         MEND
*MCALL #=     1 LV= 1 TESTAIN1 SUBENTRY 
TESTAIN1 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTAIN1'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTAIN1+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
*MCALL #=     2 LV= 1          WTO   'TEST1 STARTED'
         BRAS  1,*+(WTO#0002_EOT-*+1)/2*2
         DC    AL2(WTO#0002_EOT-*,0),C'TEST1 STARTED'
WTO#0002_EOT     EQU *
         SVC   35
*MEXIT #=     2 LV= 1 WTO
*MCALL #=     3 LV= 1          TEST1 
         MNOTE 'AREAD AINSERT 1 = RECORD 1 22.33                       X
                                                          '
         MNOTE 'AREAD AINSERT 2 = RECORD 2 22.33                       X
                                                          '
         MNOTE 'AREAD AINSERT 3 = RECORD 3 22.33                       X
                                                          '
*MEXIT #=     3 LV= 1 TEST1
*MCALL #=     4 LV= 1          TEST2 
*MEXIT #=     4 LV= 1 TEST2
         MNOTE 'SOURCE AINSERT 1'
         MNOTE 'SOURCE AINSERT 2'
         MNOTE 'SOURCE AINSERT 3'
 MACRO
 TEST3
 MNOTE 'HELLO FROM TEST3 INSERTED MACRO'
 MEND
 MACRO
 TEST4 &P1,&K1='K1V',&K2='K2V'
 MNOTE 'TEST4 K1=&K1 K2=&K2'
&I SETA 5
.LOOP ANOP
 MNOTE 'TEST4 I=&I'
&I SETA &I-1
 AIF (&I GT 0).LOOP
 MEND
*MCALL #=     5 LV= 1          TEST3 
         MNOTE 'HELLO FROM TEST3 INSERTED MACRO'
*MEXIT #=     5 LV= 1 TEST3
*MCALL #=     6 LV= 1          TEST4 
         MNOTE 'TEST4 K1='K1V' K2='K2V''
         MNOTE 'TEST4 I=5'
         MNOTE 'TEST4 I=4'
         MNOTE 'TEST4 I=3'
         MNOTE 'TEST4 I=2'
         MNOTE 'TEST4 I=1'
*MEXIT #=     6 LV= 1 TEST4
*MCALL #=     7 LV= 1          WTO   'TEST1 ENDED'
         BRAS  1,*+(WTO#0007_EOT-*+1)/2*2
         DC    AL2(WTO#0007_EOT-*,0),C'TEST1 ENDED'
WTO#0007_EOT     EQU *
         SVC   35
*MEXIT #=     7 LV= 1 WTO
*MCALL #=     8 LV= 1          SUBEXIT 
         LA    15,0
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=     8 LV= 1 SUBEXIT
         END 
