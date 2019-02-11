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
* 2007-05-31 DSH          Initial version                           *
* 2007-05-31 DSH RPI-501  Test LITERAL-ABS expression               *
* 2007-07-20 DSH RPI-662  Test additional ITEMERR and QIDERR for    *
*                         DFHRESP                                   *
* 2007-08-25 DSH RPI-687  Test additional CICS VSAM DFHRESP codes   *
* 2007-08-25 DSH RPI-690  Correct NOTEND to NOTFND                  *
* 2007-10-30 DSH RPI-729  Add DFHRESP ILLOGIC=F'21'                 *
* 2007-12-06 DSH RPI-751  Add DFHRESP EXPIRED=F'31'                 *
* 2008-04-28 DSH RPI-841  Add DFHRESP MAPFAIL,INVMPSZ,OVERFLOW      *
* 2008-09-19 DSH RPI-905  Add DFHRESP DSIDERR=F'12'                 *
* 2008-10-27 DSH RPI-928  Add DFHRESP TERMIDER, TRANSIDERR, IOERR,  *
*                         ENDDATA, ENVDEFERR                        *
* 2008-11-18 DSH RPI-951  Add DFHRESP ENQBUSY=F'55'                 *
* 2009-06-14 DSH RPI-1057 Add DFHRESP(SUPPRESSED)=F'72' and         *
*                         END=F'83'                                 *
* 2009-09-02 DSH RPI-1079 Add DFHRESP(NOTALLOC)=F'61'               *
*********************************************************************
         TITLE 'TESTCIC1 - TEST CICS DFHRESP LITERALS'
*MCALL #=     1 LV= 1 TESTCIC1 RT1   MAIN
*MCALL #=     2 LV= 2 TESTCIC1 SUBENTRY 
TESTCIC1 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTCIC1'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTCIC1+8,13
*MEXIT #=     2 LV= 2 SUBENTRY
*MCALL #=     3 LV= 2          WTO   'TESTCIC1 RT1 STARTED'
         BRAS  1,*+(WTO#0003_EOT-*+1)/2*2
         DC    AL2(WTO#0003_EOT-*,0),C'TESTCIC1 RT1 STARTED'
WTO#0003_EOT     EQU *
         SVC   35
*MEXIT #=     3 LV= 2 WTO
         BRCL    15,RT1_START
RT1_ABORT DS 0H
         MVI   RT1_ABORTED,C'T'
*MCALL #=     4 LV= 2          WTO   'TESTCIC1 RT1 TESTING ABORTED'
         BRAS  1,*+(WTO#0004_EOT-*+1)/2*2
         DC    AL2(WTO#0004_EOT-*,0),C'TESTCIC1 RT1 TESTING ABORTED'
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
*MCALL #=     6 LV= 2          WTO   'TESTCIC1 RT1 ENDED OK'
         BRAS  1,*+(WTO#0006_EOT-*+1)/2*2
         DC    AL2(WTO#0006_EOT-*,0),C'TESTCIC1 RT1 ENDED OK'
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
RT1_WTO1 DC    AL2(RT1_WTO_END-*,0),C'TESTCIC1 RT1 TESTS COMPLETED = '
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
X        DS    F
*MCALL #=    10 LV= 1          RT1   START
RT1_START DS  0H
*MEXIT #=    10 LV= 1 RT1
         MVC   X,DFHRESP(NORMAL)
         MVC   X,DFHRESP(NORMAL)     X   TEST COMMENTS
         MVC   X,DFHRESP(ERROR)
         MVC   X,DFHRESP(TERMIDERR)     RPI-928
         MVC   X,DFHRESP(FILENOTFOUND)  RPI-687
         MVC   X,DFHRESP(DSIDERR)       RPI-905
         MVC   X,DFHRESP(NOTFND)        RPI-687 RPI-690
         MVC   X,DFHRESP(DUPREC)        RPI-687
         MVC   X,DFHRESP(DUPKEY)        RPI-687
         MVC   X,DFHRESP(INVREQ)
         MVC   X,DFHRESP(IOERR)         RPI-928
         MVC   X,DFHRESP(NOSPACE)       RPI-687
         MVC   X,DFHRESP(NOTOPEN)       RPI-687
         MVC   X,DFHRESP(ENDFILE)       RPI-687
         MVC   X,DFHRESP(LENGERR)
         MVC   X,DFHRESP(PGMIDERR)
         MVC   X,DFHRESP(TRANSIDERR)    RPI-928
         MVC   X,DFHRESP(ENDDATA)       RPI-928
         MVC   X,DFHRESP(ITEMERR)       RPI-662
         MVC   X,DFHRESP(QIDERR)        RPI-662
         MVC   X,DFHRESP(ENVDEFERR)     RPI-928
         MVC   X,DFHRESP(EXPIRED)       RPI-751
         MVC   X,DFHRESP(MAPFAIL)       RPI-841
         MVC   X,DFHRESP(INVMPSZ)       RPI-841
         MVC   X,DFHRESP(OVERFLOW)      RPI-841
         MVC   X,DFHRESP(ENQBUSY)       RPI-951
         MVC   X,DFHRESP(DISABLED)      RPI-687
         MVC   X,DFHRESP(ILLOGIC)       RPI-729
         MVC   X,DFHRESP(NOTALLOC)      RPI-1079
         MVC   X,DFHRESP(SUPPRESSED)    RPI-1057
         MVC   X,DFHRESP(END)           RPI-1057
         CLC   =F'0',DFHRESP(NORMAL)
*MCALL #=    11 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1
         LTORG 
RT1_CCE1        DS 0H
*MEXIT #=    11 LV= 1 RT1
         CLC   =F'1',DFHRESP(ERROR)
*MCALL #=    12 LV= 1          RT1   CCE
         DS    0H
RT1_TEST2        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE2
         LTORG 
RT1_CCE2        DS 0H
*MEXIT #=    12 LV= 1 RT1
         CLC   =F'11',DFHRESP(TERMIDERR)    RPI-928
*MCALL #=    13 LV= 1          RT1   CCE
         DS    0H
RT1_TEST3        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE3
         LTORG 
RT1_CCE3        DS 0H
*MEXIT #=    13 LV= 1 RT1
         CLC   =F'12',DFHRESP(FILENOTFOUND) RPI-687
*MCALL #=    14 LV= 1          RT1   CCE
         DS    0H
RT1_TEST4        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE4
         LTORG 
RT1_CCE4        DS 0H
*MEXIT #=    14 LV= 1 RT1
         CLC   =F'12',DFHRESP(DSIDERR)      RPI-905
*MCALL #=    15 LV= 1          RT1   CCE
         DS    0H
RT1_TEST5        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE5
         LTORG 
RT1_CCE5        DS 0H
*MEXIT #=    15 LV= 1 RT1
         CLC   =F'13',DFHRESP(NOTFND)       RPI-687 RPI-690
*MCALL #=    16 LV= 1          RT1   CCE
         DS    0H
RT1_TEST6        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE6
         LTORG 
RT1_CCE6        DS 0H
*MEXIT #=    16 LV= 1 RT1
         CLC   =F'14',DFHRESP(DUPREC)       RPI-687
*MCALL #=    17 LV= 1          RT1   CCE
         DS    0H
RT1_TEST7        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE7
         LTORG 
RT1_CCE7        DS 0H
*MEXIT #=    17 LV= 1 RT1
         CLC   =F'15',DFHRESP(DUPKEY)       RPI-687
*MCALL #=    18 LV= 1          RT1   CCE
         DS    0H
RT1_TEST8        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE8
         LTORG 
RT1_CCE8        DS 0H
*MEXIT #=    18 LV= 1 RT1
         CLC   =F'16',DFHRESP(INVREQ)
*MCALL #=    19 LV= 1          RT1   CCE
         DS    0H
RT1_TEST9        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE9
         LTORG 
RT1_CCE9        DS 0H
*MEXIT #=    19 LV= 1 RT1
         CLC   =F'17',DFHRESP(IOERR)        RPI-928
*MCALL #=    20 LV= 1          RT1   CCE
         DS    0H
RT1_TEST10       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE10
         LTORG 
RT1_CCE10       DS 0H
*MEXIT #=    20 LV= 1 RT1
         CLC   =F'18',DFHRESP(NOSPACE)      RPI-687
*MCALL #=    21 LV= 1          RT1   CCE
         DS    0H
RT1_TEST11       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE11
         LTORG 
RT1_CCE11       DS 0H
*MEXIT #=    21 LV= 1 RT1
         CLC   =F'19',DFHRESP(NOTOPEN)      RPI-687
*MCALL #=    22 LV= 1          RT1   CCE
         DS    0H
RT1_TEST12       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE12
         LTORG 
RT1_CCE12       DS 0H
*MEXIT #=    22 LV= 1 RT1
         CLC   =F'20',DFHRESP(ENDFILE)      RPI-687
*MCALL #=    23 LV= 1          RT1   CCE
         DS    0H
RT1_TEST13       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE13
         LTORG 
RT1_CCE13       DS 0H
*MEXIT #=    23 LV= 1 RT1
         CLC   =F'21',DFHRESP(ILLOGIC)      RPI-729
*MCALL #=    24 LV= 1          RT1   CCE
         DS    0H
RT1_TEST14       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE14
         LTORG 
RT1_CCE14       DS 0H
*MEXIT #=    24 LV= 1 RT1
         CLC   =F'22',DFHRESP(LENGERR)
*MCALL #=    25 LV= 1          RT1   CCE
         DS    0H
RT1_TEST15       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE15
         LTORG 
RT1_CCE15       DS 0H
*MEXIT #=    25 LV= 1 RT1
         CLC   =F'26',DFHRESP(ITEMERR)   RPI-662
*MCALL #=    26 LV= 1          RT1   CCE
         DS    0H
RT1_TEST16       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE16
         LTORG 
RT1_CCE16       DS 0H
*MEXIT #=    26 LV= 1 RT1
         CLC   =F'27',DFHRESP(PGMIDERR)
*MCALL #=    27 LV= 1          RT1   CCE
         DS    0H
RT1_TEST17       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE17
         LTORG 
RT1_CCE17       DS 0H
*MEXIT #=    27 LV= 1 RT1
         CLC   =F'28',DFHRESP(TRANSIDERR) RPI-928
*MCALL #=    28 LV= 1          RT1   CCE
         DS    0H
RT1_TEST18       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE18
         LTORG 
RT1_CCE18       DS 0H
*MEXIT #=    28 LV= 1 RT1
         CLC   =F'29',DFHRESP(ENDDATA)   RPI-928
*MCALL #=    29 LV= 1          RT1   CCE
         DS    0H
RT1_TEST19       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE19
         LTORG 
RT1_CCE19       DS 0H
*MEXIT #=    29 LV= 1 RT1
         CLC   =F'31',DFHRESP(EXPIRED)   RPI-751
*MCALL #=    30 LV= 1          RT1   CCE
         DS    0H
RT1_TEST20       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE20
         LTORG 
RT1_CCE20       DS 0H
*MEXIT #=    30 LV= 1 RT1
         CLC   =F'36',DFHRESP(MAPFAIL)   RPI-841
*MCALL #=    31 LV= 1          RT1   CCE
         DS    0H
RT1_TEST21       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE21
         LTORG 
RT1_CCE21       DS 0H
*MEXIT #=    31 LV= 1 RT1
         CLC   =F'38',DFHRESP(INVMPSZ)   RPI-841
*MCALL #=    32 LV= 1          RT1   CCE
         DS    0H
RT1_TEST22       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE22
         LTORG 
RT1_CCE22       DS 0H
*MEXIT #=    32 LV= 1 RT1
         CLC   =F'40',DFHRESP(OVERFLOW)  RPI-841
*MCALL #=    33 LV= 1          RT1   CCE
         DS    0H
RT1_TEST23       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE23
         LTORG 
RT1_CCE23       DS 0H
*MEXIT #=    33 LV= 1 RT1
         CLC   =F'44',DFHRESP(QIDERR)    RPI-662
*MCALL #=    34 LV= 1          RT1   CCE
         DS    0H
RT1_TEST24       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE24
         LTORG 
RT1_CCE24       DS 0H
*MEXIT #=    34 LV= 1 RT1
         CLC   =F'55',DFHRESP(ENQBUSY)   RPI-951
*MCALL #=    35 LV= 1          RT1   CCE
         DS    0H
RT1_TEST25       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE25
         LTORG 
RT1_CCE25       DS 0H
*MEXIT #=    35 LV= 1 RT1
         CLC   =F'56',DFHRESP(ENVDEFERR) RPI-928
*MCALL #=    36 LV= 1          RT1   CCE
         DS    0H
RT1_TEST26       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE26
         LTORG 
RT1_CCE26       DS 0H
*MEXIT #=    36 LV= 1 RT1
         CLC   =F'61',DFHRESP(NOTALLOC)  RPI-1079
         CLC   =F'84',DFHRESP(DISABLED)  RPI-687
*MCALL #=    37 LV= 1          RT1   CCE
         DS    0H
RT1_TEST27       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE27
         LTORG 
RT1_CCE27       DS 0H
*MEXIT #=    37 LV= 1 RT1
*MCALL #=    38 LV= 1          RT1   CCE,=F'0',DFHRESP(NORMAL)
         DS    0H
         CLC   =F'0',DFHRESP(NORMAL)
RT1_TEST28       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE28
         LTORG 
RT1_CCE28       DS 0H
*MEXIT #=    38 LV= 1 RT1
*MCALL #=    39 LV= 1          RT1   CCE,=F'1',DFHRESP(ERROR)
         DS    0H
         CLC   =F'1',DFHRESP(ERROR)
RT1_TEST29       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE29
         LTORG 
RT1_CCE29       DS 0H
*MEXIT #=    39 LV= 1 RT1
*MCALL #=    40 LV= 1          RT1   CCE,=F'11',DFHRESP(TERMIDERR)    RX
               PI-928
         DS    0H
         CLC   =F'11',DFHRESP(TERMIDERR)
RT1_TEST30       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE30
         LTORG 
RT1_CCE30       DS 0H
*MEXIT #=    40 LV= 1 RT1
*MCALL #=    41 LV= 1          RT1   CCE,=F'12',DFHRESP(FILENOTFOUND) RX
               PI-687
         DS    0H
         CLC   =F'12',DFHRESP(FILENOTFOUND)
RT1_TEST31       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE31
         LTORG 
RT1_CCE31       DS 0H
*MEXIT #=    41 LV= 1 RT1
*MCALL #=    42 LV= 1          RT1   CCE,=F'12',DFHRESP(DSIDERR)      RX
               PI-905
         DS    0H
         CLC   =F'12',DFHRESP(DSIDERR)
RT1_TEST32       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE32
         LTORG 
RT1_CCE32       DS 0H
*MEXIT #=    42 LV= 1 RT1
*MCALL #=    43 LV= 1          RT1   CCE,=F'13',DFHRESP(NOTFND)       RX
               PI-687 RPI-690
         DS    0H
         CLC   =F'13',DFHRESP(NOTFND)
RT1_TEST33       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE33
         LTORG 
RT1_CCE33       DS 0H
*MEXIT #=    43 LV= 1 RT1
*MCALL #=    44 LV= 1          RT1   CCE,=F'14',DFHRESP(DUPREC)       RX
               PI-687
         DS    0H
         CLC   =F'14',DFHRESP(DUPREC)
RT1_TEST34       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE34
         LTORG 
RT1_CCE34       DS 0H
*MEXIT #=    44 LV= 1 RT1
*MCALL #=    45 LV= 1          RT1   CCE,=F'15',DFHRESP(DUPKEY)       RX
               PI-687
         DS    0H
         CLC   =F'15',DFHRESP(DUPKEY)
RT1_TEST35       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE35
         LTORG 
RT1_CCE35       DS 0H
*MEXIT #=    45 LV= 1 RT1
*MCALL #=    46 LV= 1          RT1   CCE,=F'16',DFHRESP(INVREQ)
         DS    0H
         CLC   =F'16',DFHRESP(INVREQ)
RT1_TEST36       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE36
         LTORG 
RT1_CCE36       DS 0H
*MEXIT #=    46 LV= 1 RT1
*MCALL #=    47 LV= 1          RT1   CCE,=F'17',DFHRESP(IOERR)        RX
               PI-928
         DS    0H
         CLC   =F'17',DFHRESP(IOERR)
RT1_TEST37       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE37
         LTORG 
RT1_CCE37       DS 0H
*MEXIT #=    47 LV= 1 RT1
*MCALL #=    48 LV= 1          RT1   CCE,=F'18',DFHRESP(NOSPACE)      RX
               PI-687
         DS    0H
         CLC   =F'18',DFHRESP(NOSPACE)
RT1_TEST38       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE38
         LTORG 
RT1_CCE38       DS 0H
*MEXIT #=    48 LV= 1 RT1
*MCALL #=    49 LV= 1          RT1   CCE,=F'19',DFHRESP(NOTOPEN)      RX
               PI-687
         DS    0H
         CLC   =F'19',DFHRESP(NOTOPEN)
RT1_TEST39       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE39
         LTORG 
RT1_CCE39       DS 0H
*MEXIT #=    49 LV= 1 RT1
*MCALL #=    50 LV= 1          RT1   CCE,=F'20',DFHRESP(ENDFILE)      RX
               PI-687
         DS    0H
         CLC   =F'20',DFHRESP(ENDFILE)
RT1_TEST40       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE40
         LTORG 
RT1_CCE40       DS 0H
*MEXIT #=    50 LV= 1 RT1
*MCALL #=    51 LV= 1          RT1   CCE,=F'21',DFHRESP(ILLOGIC)      RX
               PI-729
         DS    0H
         CLC   =F'21',DFHRESP(ILLOGIC)
RT1_TEST41       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE41
         LTORG 
RT1_CCE41       DS 0H
*MEXIT #=    51 LV= 1 RT1
*MCALL #=    52 LV= 1          RT1   CCE,=F'22',DFHRESP(LENGERR)
         DS    0H
         CLC   =F'22',DFHRESP(LENGERR)
RT1_TEST42       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE42
         LTORG 
RT1_CCE42       DS 0H
*MEXIT #=    52 LV= 1 RT1
*MCALL #=    53 LV= 1          RT1   CCE,=F'26',DFHRESP(ITEMERR)      RX
               PI-662
         DS    0H
         CLC   =F'26',DFHRESP(ITEMERR)
RT1_TEST43       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE43
         LTORG 
RT1_CCE43       DS 0H
*MEXIT #=    53 LV= 1 RT1
*MCALL #=    54 LV= 1          RT1   CCE,=F'27',DFHRESP(PGMIDERR)
         DS    0H
         CLC   =F'27',DFHRESP(PGMIDERR)
RT1_TEST44       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE44
         LTORG 
RT1_CCE44       DS 0H
*MEXIT #=    54 LV= 1 RT1
*MCALL #=    55 LV= 1          RT1   CCE,=F'28',DFHRESP(TRANSIDERR)   RX
               PI-928
         DS    0H
         CLC   =F'28',DFHRESP(TRANSIDERR)
RT1_TEST45       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE45
         LTORG 
RT1_CCE45       DS 0H
*MEXIT #=    55 LV= 1 RT1
*MCALL #=    56 LV= 1          RT1   CCE,=F'29',DFHRESP(ENDDATA)      RX
               PI-928
         DS    0H
         CLC   =F'29',DFHRESP(ENDDATA)
RT1_TEST46       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE46
         LTORG 
RT1_CCE46       DS 0H
*MEXIT #=    56 LV= 1 RT1
*MCALL #=    57 LV= 1          RT1   CCE,=F'31',DFHRESP(EXPIRED)      RX
               PI-751
         DS    0H
         CLC   =F'31',DFHRESP(EXPIRED)
RT1_TEST47       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE47
         LTORG 
RT1_CCE47       DS 0H
*MEXIT #=    57 LV= 1 RT1
*MCALL #=    58 LV= 1          RT1   CCE,=F'36',DFHRESP(MAPFAIL)      RX
               PI-841
         DS    0H
         CLC   =F'36',DFHRESP(MAPFAIL)
RT1_TEST48       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE48
         LTORG 
RT1_CCE48       DS 0H
*MEXIT #=    58 LV= 1 RT1
*MCALL #=    59 LV= 1          RT1   CCE,=F'38',DFHRESP(INVMPSZ)      RX
               PI-841
         DS    0H
         CLC   =F'38',DFHRESP(INVMPSZ)
RT1_TEST49       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE49
         LTORG 
RT1_CCE49       DS 0H
*MEXIT #=    59 LV= 1 RT1
*MCALL #=    60 LV= 1          RT1   CCE,=F'40',DFHRESP(OVERFLOW)     RX
               PI-841
         DS    0H
         CLC   =F'40',DFHRESP(OVERFLOW)
RT1_TEST50       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE50
         LTORG 
RT1_CCE50       DS 0H
*MEXIT #=    60 LV= 1 RT1
*MCALL #=    61 LV= 1          RT1   CCE,=F'44',DFHRESP(QIDERR)       RX
               PI-662
         DS    0H
         CLC   =F'44',DFHRESP(QIDERR)
RT1_TEST51       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE51
         LTORG 
RT1_CCE51       DS 0H
*MEXIT #=    61 LV= 1 RT1
*MCALL #=    62 LV= 1          RT1   CCE,=F'55',DFHRESP(ENQBUSY)      RX
               PI-951
         DS    0H
         CLC   =F'55',DFHRESP(ENQBUSY)
RT1_TEST52       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE52
         LTORG 
RT1_CCE52       DS 0H
*MEXIT #=    62 LV= 1 RT1
*MCALL #=    63 LV= 1          RT1   CCE,=F'56',DFHRESP(ENVDEFERR)    RX
               PI-928
         DS    0H
         CLC   =F'56',DFHRESP(ENVDEFERR)
RT1_TEST53       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE53
         LTORG 
RT1_CCE53       DS 0H
*MEXIT #=    63 LV= 1 RT1
*MCALL #=    64 LV= 1          RT1   CCE,=F'61',DFHRESP(NOTALLOC)     RX
               PI-1079
         DS    0H
         CLC   =F'61',DFHRESP(NOTALLOC)
RT1_TEST54       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE54
         LTORG 
RT1_CCE54       DS 0H
*MEXIT #=    64 LV= 1 RT1
*MCALL #=    65 LV= 1          RT1   CCE,=F'72',DFHRESP(SUPPRESSED)   RX
               PI-1057
         DS    0H
         CLC   =F'72',DFHRESP(SUPPRESSED)
RT1_TEST55       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE55
         LTORG 
RT1_CCE55       DS 0H
*MEXIT #=    65 LV= 1 RT1
*MCALL #=    66 LV= 1          RT1   CCE,=F'83',DFHRESP(END)          RX
               PI-1057
         DS    0H
         CLC   =F'83',DFHRESP(END)
RT1_TEST56       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE56
         LTORG 
RT1_CCE56       DS 0H
*MEXIT #=    66 LV= 1 RT1
*MCALL #=    67 LV= 1          RT1   CCE,=F'84',DFHRESP(DISABLED)     RX
               PI-687
         DS    0H
         CLC   =F'84',DFHRESP(DISABLED)
RT1_TEST57       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE57
         LTORG 
RT1_CCE57       DS 0H
*MEXIT #=    67 LV= 1 RT1
*MCALL #=    68 LV= 1          RT1   END
         B      RT1_END
*MEXIT #=    68 LV= 1 RT1
         END 
