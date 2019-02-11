 COPY TESTPRO1
*MCALL #=     1 LV= 1          TESTPROS 
         MNOTE 'MZ390 TESTPROS MACRO STARTED 01/02/05 22.33 TESTPRO1'
*MEXIT #=     1 LV= 1 TESTPROS
         MACRO
         END
         TESTPROT
         MEND
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
* 2006-04-10  DSH         Initial version                           *
* 2006-04-10  DSH RPI-276 Test option profile to insert COPY        *
*                         statement                                 *
*********************************************************************
         TITLE 'TESTPRO1 - TEST PROFILE(TESTPRO1.CPY) INIT/TERM MACS'
*MCALL #=     2 LV= 1 TESTPRO1 SUBENTRY 
TESTPRO1 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTPRO1'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTPRO1+8,13
*MEXIT #=     2 LV= 1 SUBENTRY
*MCALL #=     3 LV= 1          WTO   'TESTPRO1 TEST PROFILE(TESTPRO1.CPX
               Y)'
         BRAS  1,*+(WTO#0003_EOT-*+1)/2*2
         DC    AL2(WTO#0003_EOT-*,0),C'TESTPRO1 TEST PROFILE(TESTPRO1.CX
               PY)'
WTO#0003_EOT     EQU *
         SVC   35
*MEXIT #=     3 LV= 1 WTO
*MCALL #=     4 LV= 1          WTO   '  1.  EXECUTE MACRO TESTPROS.MAC X
               AT START'
         BRAS  1,*+(WTO#0004_EOT-*+1)/2*2
         DC    AL2(WTO#0004_EOT-*,0),C'  1.  EXECUTE MACRO TESTPROS.MACX
                AT START'
WTO#0004_EOT     EQU *
         SVC   35
*MEXIT #=     4 LV= 1 WTO
*MCALL #=     5 LV= 1          WTO   '  2.  EXECUTE MACRO TESTPOST.MAC X
               AT TERMINATION'
         BRAS  1,*+(WTO#0005_EOT-*+1)/2*2
         DC    AL2(WTO#0005_EOT-*,0),C'  2.  EXECUTE MACRO TESTPOST.MACX
                AT TERMINATION'
WTO#0005_EOT     EQU *
         SVC   35
*MEXIT #=     5 LV= 1 WTO
*MCALL #=     6 LV= 1          WTO   'TESTPRO1 ENDED OK'
         BRAS  1,*+(WTO#0006_EOT-*+1)/2*2
         DC    AL2(WTO#0006_EOT-*,0),C'TESTPRO1 ENDED OK'
WTO#0006_EOT     EQU *
         SVC   35
*MEXIT #=     6 LV= 1 WTO
*MCALL #=     7 LV= 1          SUBEXIT 
         LA    15,0
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=     7 LV= 1 SUBEXIT
*MCALL #=     8 LV= 1          END 
*MCALL #=     9 LV= 2          TESTPROT 
         MNOTE 'MZ390 TESTPROT MACRO ENDED  01/02/05 22.33 TESTPRO1'
*MEXIT #=     9 LV= 2 TESTPROT
*MEXIT #=     8 LV= 1 END
         MNOTE 4,'Missing END statement.'
