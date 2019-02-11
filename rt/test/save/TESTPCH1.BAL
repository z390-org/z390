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
* 2005-09-30  DSH Initial version                                   *
* 2008-04-22  DSH RPI-833 Add string quotes for HLASM compatibility *
*********************************************************************
         MACRO
         TEST1
&TEXT    AREAD
         WTO  '&TEXT'
         MEND
*MCALL #=     1 LV= 1 TESTPCH1 SUBENTRY 
TESTPCH1 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTPCH1'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTPCH1+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
*MCALL #=     2 LV= 1          WTO   'START TESTPCH1 AREAD AND PUNCH USX
               ING DEFAULT PCH'
         BRAS  1,*+(WTO#0002_EOT-*+1)/2*2
         DC    AL2(WTO#0002_EOT-*,0),C'START TESTPCH1 AREAD AND PUNCH UX
               SING DEFAULT PCH'
WTO#0002_EOT     EQU *
         SVC   35
*MEXIT #=     2 LV= 1 WTO
*MCALL #=     3 LV= 1          TEST1 
*MCALL #=     4 LV= 2          WTO  'TEST1 RECORD 1                    X
                                                             '
         BRAS  1,*+(WTO#0004_EOT-*+1)/2*2
         DC    AL2(WTO#0004_EOT-*,0),C'TEST1 RECORD 1                  X
                                                               '
WTO#0004_EOT     EQU *
         SVC   35
*MEXIT #=     4 LV= 2 WTO
*MEXIT #=     3 LV= 1 TEST1
*MCALL #=     5 LV= 1          TEST1 
*MCALL #=     6 LV= 2          WTO  'TEST1 RECORD 2                    X
                                                             '
         BRAS  1,*+(WTO#0006_EOT-*+1)/2*2
         DC    AL2(WTO#0006_EOT-*,0),C'TEST1 RECORD 2                  X
                                                               '
WTO#0006_EOT     EQU *
         SVC   35
*MEXIT #=     6 LV= 2 WTO
*MEXIT #=     5 LV= 1 TEST1
         MACRO
         TEST2
.LOOP    ANOP
&TEXT    AREAD
         AIF   ('&TEXT'(1,17) EQ 'TEST2 END OF DATA').ENDLOOP
         WTO   '&TEXT'
         AGO   .LOOP
.ENDLOOP ANOP
         MEND
*MCALL #=     7 LV= 1          TEST2 
*MCALL #=     8 LV= 2          WTO   'TEST2 RECORD 1                   X
                                                              '
         BRAS  1,*+(WTO#0008_EOT-*+1)/2*2
         DC    AL2(WTO#0008_EOT-*,0),C'TEST2 RECORD 1                  X
                                                               '
WTO#0008_EOT     EQU *
         SVC   35
*MEXIT #=     8 LV= 2 WTO
*MCALL #=     9 LV= 2          WTO   'TEST2 RECORD 2                   X
                                                              '
         BRAS  1,*+(WTO#0009_EOT-*+1)/2*2
         DC    AL2(WTO#0009_EOT-*,0),C'TEST2 RECORD 2                  X
                                                               '
WTO#0009_EOT     EQU *
         SVC   35
*MEXIT #=     9 LV= 2 WTO
*MCALL #=    10 LV= 2          WTO   'TEST2 RECORD 3                   X
                                                              '
         BRAS  1,*+(WTO#0010_EOT-*+1)/2*2
         DC    AL2(WTO#0010_EOT-*,0),C'TEST2 RECORD 3                  X
                                                               '
WTO#0010_EOT     EQU *
         SVC   35
*MEXIT #=    10 LV= 2 WTO
*MEXIT #=     7 LV= 1 TEST2
*MCALL #=    11 LV= 1          WTO   'END   AREAD TEXT'
         BRAS  1,*+(WTO#0011_EOT-*+1)/2*2
         DC    AL2(WTO#0011_EOT-*,0),C'END   AREAD TEXT'
WTO#0011_EOT     EQU *
         SVC   35
*MEXIT #=    11 LV= 1 WTO
*MCALL #=    12 LV= 1          WTO   'START PUNCH TEST'
         BRAS  1,*+(WTO#0012_EOT-*+1)/2*2
         DC    AL2(WTO#0012_EOT-*,0),C'START PUNCH TEST'
WTO#0012_EOT     EQU *
         SVC   35
*MEXIT #=    12 LV= 1 WTO
         PUNCH 'TEST3 RECORD 1                                         X
                                        '
         PUNCH 'TEST3 RECORD 2                                         X
                                        '
         PUNCH 'TEST4 RECORD 1                                         X
                                        '
*MCALL #=    13 LV= 1          WTO   'END TESTPCH1 OK'
         BRAS  1,*+(WTO#0013_EOT-*+1)/2*2
         DC    AL2(WTO#0013_EOT-*,0),C'END TESTPCH1 OK'
WTO#0013_EOT     EQU *
         SVC   35
*MEXIT #=    13 LV= 1 WTO
*MCALL #=    14 LV= 1          SUBEXIT 
         LA    15,0
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=    14 LV= 1 SUBEXIT
         END 
