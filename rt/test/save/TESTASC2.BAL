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
* 2005-10-05 DSH RPI-5 - Add ASCII mode support                     *
*                        (see TESTASC2.MLC test also)               *
* 2006-03-20 DSH RPI-232 Test integer with exponent 1E3 = 1000      *
* 2006-04-05 DSH RPI-270 Test CA'...' and CE'...'  MZ390 and AZ390  *
*                        SDTS                                       *
* 2008-11-09 DSH RPI-943 Use signed to substitute signed value in   *
*                        model                                      *
*********************************************************************
*MCALL #=     1 LV= 1 TESTSDT1 RT1   MAIN
*MCALL #=     2 LV= 2 TESTSDT1 SUBENTRY 
TESTSDT1 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTSDT1'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTSDT1+8,13
*MEXIT #=     2 LV= 2 SUBENTRY
*MCALL #=     3 LV= 2          WTO   'TESTSDT1 RT1 STARTED'
         BRAS  1,*+(WTO#0003_EOT-*+1)/2*2
         DC    AL2(WTO#0003_EOT-*,0),C'TESTSDT1 RT1 STARTED'
WTO#0003_EOT     EQU *
         SVC   35
*MEXIT #=     3 LV= 2 WTO
         BRCL    15,RT1_START
RT1_ABORT DS 0H
         MVI   RT1_ABORTED,C'T'
*MCALL #=     4 LV= 2          WTO   'TESTSDT1 RT1 TESTING ABORTED'
         BRAS  1,*+(WTO#0004_EOT-*+1)/2*2
         DC    AL2(WTO#0004_EOT-*,0),C'TESTSDT1 RT1 TESTING ABORTED'
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
*MCALL #=     6 LV= 2          WTO   'TESTSDT1 RT1 ENDED OK'
         BRAS  1,*+(WTO#0006_EOT-*+1)/2*2
         DC    AL2(WTO#0006_EOT-*,0),C'TESTSDT1 RT1 ENDED OK'
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
RT1_WTO1 DC    AL2(RT1_WTO_END-*,0),C'TESTSDT1 RT1 TESTS COMPLETED = '
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
*MCALL #=     9 LV= 1          RT1   START
RT1_START DS  0H
*MEXIT #=     9 LV= 1 RT1
* TEST MZ390 SDTS
*MCALL #=    10 LV= 1          RT1 CCL,=A(1),=A(2)
         DS    0H
         CLC   =A(1),=A(2)
RT1_TEST1        BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1
         LTORG 
RT1_CCL1        DS 0H
*MEXIT #=    10 LV= 1 RT1
*MCALL #=    11 LV= 1          RT1 CCH,=A(66),=A(65)
         DS    0H
         CLC   =A(66),=A(65)
RT1_TEST2        BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH2
         LTORG 
RT1_CCH2        DS 0H
*MEXIT #=    11 LV= 1 RT1
*MCALL #=    12 LV= 1          RT1 CCE,=A(123),=A(123)
         DS    0H
         CLC   =A(123),=A(123)
RT1_TEST3        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE3
         LTORG 
RT1_CCE3        DS 0H
*MEXIT #=    12 LV= 1 RT1
*MCALL #=    13 LV= 1          RT1 CCE,=A(3),=A(3)
         DS    0H
         CLC   =A(3),=A(3)
RT1_TEST4        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE4
         LTORG 
RT1_CCE4        DS 0H
*MEXIT #=    13 LV= 1 RT1
*MCALL #=    14 LV= 1          RT1   CCH,=C'A',=C'1'   ASCII LETTERS > X
               DIGITS
         DS    0H
         CLC   =C'A',=C'1'
RT1_TEST5        BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH5
         LTORG 
RT1_CCH5        DS 0H
*MEXIT #=    14 LV= 1 RT1
*MCALL #=    15 LV= 1          RT1 CCE,=AL1(B'1000001'),=AL1(C'A')     X
                 TEST ASCII SDTS
         DS    0H
         CLC   =AL1(B'1000001'),=AL1(C'A')
RT1_TEST6        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE6
         LTORG 
RT1_CCE6        DS 0H
*MEXIT #=    15 LV= 1 RT1
*MCALL #=    16 LV= 1          RT1 CCE,=AL1(C' '),=AL1(X'20')
         DS    0H
         CLC   =AL1(C' '),=AL1(X'20')
RT1_TEST7        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE7
         LTORG 
RT1_CCE7        DS 0H
*MEXIT #=    16 LV= 1 RT1
*MCALL #=    17 LV= 1          RT1 CCE,=A(C'ABCD'),=A(X'41424344')
         DS    0H
         CLC   =A(C'ABCD'),=A(X'41424344')
RT1_TEST8        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE8
         LTORG 
RT1_CCE8        DS 0H
*MEXIT #=    17 LV= 1 RT1
*MCALL #=    18 LV= 1          RT1 CCE,=A(B'0100000101000001'),=A(C'AA'X
               )
         DS    0H
         CLC   =A(B'0100000101000001'),=A(C'AA')
RT1_TEST9        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE9
         LTORG 
RT1_CCE9        DS 0H
*MEXIT #=    18 LV= 1 RT1
*MCALL #=    19 LV= 1          RT1 CCE,=A(65),=A(65)
         DS    0H
         CLC   =A(65),=A(65)
RT1_TEST10       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE10
         LTORG 
RT1_CCE10       DS 0H
*MEXIT #=    19 LV= 1 RT1
*MCALL #=    20 LV= 1          RT1 CCE,=A(32),=A(32)
         DS    0H
         CLC   =A(32),=A(32)
RT1_TEST11       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE11
         LTORG 
RT1_CCE11       DS 0H
*MEXIT #=    20 LV= 1 RT1
*MCALL #=    21 LV= 1          RT1 CCE,=A(1094861636),=A(1094861636)
         DS    0H
         CLC   =A(1094861636),=A(1094861636)
RT1_TEST12       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE12
         LTORG 
RT1_CCE12       DS 0H
*MEXIT #=    21 LV= 1 RT1
*MCALL #=    22 LV= 1          RT1 CCE,=A(16705),=A(16705)
         DS    0H
         CLC   =A(16705),=A(16705)
RT1_TEST13       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE13
         LTORG 
RT1_CCE13       DS 0H
*MEXIT #=    22 LV= 1 RT1
*MCALL #=    23 LV= 1          RT1 CCE,=A(3221298),=A(3221298)
         DS    0H
         CLC   =A(3221298),=A(3221298)
RT1_TEST14       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE14
         LTORG 
RT1_CCE14       DS 0H
*MEXIT #=    23 LV= 1 RT1
*MCALL #=    24 LV= 1          RT1 CCE,=A(3220018),=A(3220018)
         DS    0H
         CLC   =A(3220018),=A(3220018)
RT1_TEST15       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE15
         LTORG 
RT1_CCE15       DS 0H
*MEXIT #=    24 LV= 1 RT1
*MCALL #=    25 LV= 1          RT1   CCE,=A(C'1''2'),=A(X'312732')
         DS    0H
         CLC   =A(C'1''2'),=A(X'312732')
RT1_TEST16       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE16
         LTORG 
RT1_CCE16       DS 0H
*MEXIT #=    25 LV= 1 RT1
*MCALL #=    26 LV= 1          RT1   CCE,=A(C"1""2"),=A(X'312232')
         DS    0H
         CLC   =A(C"1""2"),=A(X'312232')
RT1_TEST17       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE17
         LTORG 
RT1_CCE17       DS 0H
*MEXIT #=    26 LV= 1 RT1
* TEST CA/CE SDT'S
*MCALL #=    27 LV= 1          RT1   CCE,=AL1(49),=X'31'
         DS    0H
         CLC   =AL1(49),=X'31'
RT1_TEST18       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE18
         LTORG 
RT1_CCE18       DS 0H
*MEXIT #=    27 LV= 1 RT1
*MCALL #=    28 LV= 1          RT1   CCE,=AL1(62194),=X'F2F2'
         DS    0H
         CLC   =AL1(62194),=X'F2F2'
RT1_TEST19       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE19
         LTORG 
RT1_CCE19       DS 0H
*MEXIT #=    28 LV= 1 RT1
*MCALL #=    29 LV= 1          RT1   CCE,=AL1(3355443),=X'333333'
         DS    0H
         CLC   =AL1(3355443),=X'333333'
RT1_TEST20       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE20
         LTORG 
RT1_CCE20       DS 0H
*MEXIT #=    29 LV= 1 RT1
*MCALL #=    30 LV= 1          RT1   CCE,=AL1(-185273100),=X'F4F4F4F4'
         DS    0H
         CLC   =AL1(-185273100),=X'F4F4F4F4'
RT1_TEST21       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE21
         LTORG 
RT1_CCE21       DS 0H
*MEXIT #=    30 LV= 1 RT1
*MCALL #=    31 LV= 1          RT1   CCE,=AL1(CA'1'),=X'31'
         DS    0H
         CLC   =AL1(CA'1'),=X'31'
RT1_TEST22       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE22
         LTORG 
RT1_CCE22       DS 0H
*MEXIT #=    31 LV= 1 RT1
*MCALL #=    32 LV= 1          RT1   CCE,=AL1(CE'22'),=X'F2F2'
         DS    0H
         CLC   =AL1(CE'22'),=X'F2F2'
RT1_TEST23       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE23
         LTORG 
RT1_CCE23       DS 0H
*MEXIT #=    32 LV= 1 RT1
*MCALL #=    33 LV= 1          RT1   CCE,=AL1(ca'333'),=X'333333'
         DS    0H
         CLC   =AL1(ca'333'),=X'333333'
RT1_TEST24       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE24
         LTORG 
RT1_CCE24       DS 0H
*MEXIT #=    33 LV= 1 RT1
*MCALL #=    34 LV= 1          RT1   CCE,=AL1(ce'4444'),=X'F4F4F4F4'
         DS    0H
         CLC   =AL1(ce'4444'),=X'F4F4F4F4'
RT1_TEST25       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE25
         LTORG 
RT1_CCE25       DS 0H
*MEXIT #=    34 LV= 1 RT1
*MCALL #=    35 LV= 1          RT1 CCE,=A(256),=A(256)
         DS    0H
         CLC   =A(256),=A(256)
RT1_TEST26       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE26
         LTORG 
RT1_CCE26       DS 0H
*MEXIT #=    35 LV= 1 RT1
*MCALL #=    36 LV= 1          RT1 CCE,=A(1),=A(1)
         DS    0H
         CLC   =A(1),=A(1)
RT1_TEST27       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE27
         LTORG 
RT1_CCE27       DS 0H
*MEXIT #=    36 LV= 1 RT1
* TEST AZ390 NON-CHAR SDTS
*MCALL #=    37 LV= 1          RT1 CCL,=AL1(1),=AL1(2)
         DS    0H
         CLC   =AL1(1),=AL1(2)
RT1_TEST28       BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL28
         LTORG 
RT1_CCL28       DS 0H
*MEXIT #=    37 LV= 1 RT1
*MCALL #=    38 LV= 1          RT1 CCE,=AL1(123),=AL1(123)
         DS    0H
         CLC   =AL1(123),=AL1(123)
RT1_TEST29       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE29
         LTORG 
RT1_CCE29       DS 0H
*MEXIT #=    38 LV= 1 RT1
*MCALL #=    39 LV= 1          RT1 CCE,=AL1(B'11'),=AL1(X'3')
         DS    0H
         CLC   =AL1(B'11'),=AL1(X'3')
RT1_TEST30       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE30
         LTORG 
RT1_CCE30       DS 0H
*MEXIT #=    39 LV= 1 RT1
*MCALL #=    40 LV= 1          RT1 CCE,=A(X'100'),=A(256)
         DS    0H
         CLC   =A(X'100'),=A(256)
RT1_TEST31       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE31
         LTORG 
RT1_CCE31       DS 0H
*MEXIT #=    40 LV= 1 RT1
*MCALL #=    41 LV= 1          RT1 CCE,=F'-1',=A(X'FFFFFFFF')
         DS    0H
         CLC   =F'-1',=A(X'FFFFFFFF')
RT1_TEST32       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE32
         LTORG 
RT1_CCE32       DS 0H
*MEXIT #=    41 LV= 1 RT1
* TEST EXPONENTS IN INTS
*MCALL #=    42 LV= 1          RT1 CCE,=A(1E3),=F'1000'
         DS    0H
         CLC   =A(1E3),=F'1000'
RT1_TEST33       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE33
         LTORG 
RT1_CCE33       DS 0H
*MEXIT #=    42 LV= 1 RT1
*MCALL #=    43 LV= 1          RT1 CCE,=H'1E3',=H'1000'
         DS    0H
         CLC   =H'1E3',=H'1000'
RT1_TEST34       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE34
         LTORG 
RT1_CCE34       DS 0H
*MEXIT #=    43 LV= 1 RT1
*MCALL #=    44 LV= 1          RT1 END
         B      RT1_END
*MEXIT #=    44 LV= 1 RT1
         END 
