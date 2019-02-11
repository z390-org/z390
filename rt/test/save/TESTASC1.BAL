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
* NOTE: This program is bi-modal supporting EBCDIC and ASCII mode   *
*       This program is copied to testasc1 to test using ascii      *
*********************************************************************
* 2005-09-30 DSH          Initial version                           *
* 2005-10-02 DSH RPI-2    Add tests for multilpe dupicate DC's      *
* 2005-10-04 DSH RPI-  5  Add ASCII support                         *
*                         (see TESTASC1.MLC test also)              *
* 2005-10-20 DSH RPI- 34  Full ASCII and EBCDIC translation test    *
* 2006-01-06 DSH RPI-157  Correct operand errors caught by this fix *
* 2006-01-06 DSH RPI-192  Test && and '' in SETC, SDT, and models   *
* 2006-04-02 DSH RPI-265  Test alignment within DS/DC fields        *
* 2006-04-05 DSH RPI-270  Test DS/DC CA/CE/AD/FD/VD                 *
*                         (see TESTSDT1.MLC CA/CE)                  *
* 2006-07-19 DSH RPI-371  Support spaces within X'...' data fields  *
* 2006-07-19 DSH RPI-373  Align L type 16 byte fields to multiple   *
*                         of 8 vs 16                                *
* 2006-07-19 DSH RPI-367  Support floating point (MIN) and (MAX)    *
*                         constants                                 *
* 2006-07-19 DSH RPI-368  Support S scale factor for F, H, EH, DH,  *
*                         and LH                                    *
* 2006-08-03 DSH RPI-388  Test fix dup count for E, D, F and FD     *
* 2006-09-21 DSH RPI-458  Test DC S(rel and off(base)) constants    *
* 2006-12-09 DSH RPI-407  Test DC DD, ED, and LD (min) and (max)    *
*                         constants                                 *
* 2007-01-19 DSH RPI-538  Test duplication factors for P and all    *
*                         types                                     *
* 2007-03-01 DSH RPI-555  Test LQ quad word hex                     *
* 2007-03-16 DSH RPI-578  Test corrected M3 complex multiple S type *
* 2007-04-01 DSH RPI-567  Add CCW, CCW0, and CCW1 tests             *
* 2008-01-10 DSH RPI-777  Add decimal and scale for P/Z, add sign   *
*                         for Z                                     *
* 2008-04-22 DSH RPI-833  Add string quotes for HLASM compatibility *
* 2008-04-24 DSH RPI-840  Test spaces ignored in P and Z data fields*
* 2008-08-09 DSH RPI-893  Test SY LONG DISP, F'Unn', H'Unn'         *
* 2008-11-10 DSH RPI-946  Change DS to DC for initialization to     *
*                         zeros                                     *
* 2009-06-30 DSH RPI-1044 Change VDX DC VD(VDX) to use TESTSUB1.OBJ *
* 2010-01-09 DSH RPI-1101 AFHY overflow with no errors              *
* 2011-01-25 DSH RPI-1139 C2X argument in quotes for NOALLOW        *
*********************************************************************
         PRINT DATA
*MCALL #=     1 LV= 1 TESTDC1  RT1   MAIN
*MCALL #=     2 LV= 2 TESTDC1  SUBENTRY 
TESTDC1  CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTDC1'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTDC1+8,13
*MEXIT #=     2 LV= 2 SUBENTRY
*MCALL #=     3 LV= 2          WTO   'TESTDC1 RT1 STARTED'
         BRAS  1,*+(WTO#0003_EOT-*+1)/2*2
         DC    AL2(WTO#0003_EOT-*,0),C'TESTDC1 RT1 STARTED'
WTO#0003_EOT     EQU *
         SVC   35
*MEXIT #=     3 LV= 2 WTO
         BRCL    15,RT1_START
RT1_ABORT DS 0H
         MVI   RT1_ABORTED,C'T'
*MCALL #=     4 LV= 2          WTO   'TESTDC1 RT1 TESTING ABORTED'
         BRAS  1,*+(WTO#0004_EOT-*+1)/2*2
         DC    AL2(WTO#0004_EOT-*,0),C'TESTDC1 RT1 TESTING ABORTED'
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
*MCALL #=     6 LV= 2          WTO   'TESTDC1 RT1 ENDED OK'
         BRAS  1,*+(WTO#0006_EOT-*+1)/2*2
         DC    AL2(WTO#0006_EOT-*,0),C'TESTDC1 RT1 ENDED OK'
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
RT1_WTO1 DC    AL2(RT1_WTO_END-*,0),C'TESTDC1 RT1 TESTS COMPLETED = '
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
M1       DC    AL1(1),B'10',C'3',FL1'4',HL1'5',P'6',X'7',Z'8',X'FF'
V1E      DC    X'0102F304056C07C8FF' RPI-777
V1A      DC    X'01023304056C07C8FF' RPI-777
M2       DC    L'1',D'1',E'1',X'FF'
V2       DC    X'41100000000000003300000000000000'
         DC    X'4110000000000000'
         DC    X'41100000',X'FF'
M3       DC    S(1),S(2),S(M3),S(1(2)),X'FF'
V3       DC    X'00010002',AL2(X'D000'+(M3-TESTDC1-8)),X'2001',X'FF'
M4       DC    V(TESTDC1),2V(TESTDC1),X'FF'
V4       DC    3A(TESTDC1),X'FF'
         DS    0F
V5       DC    X'AA',0H,X'BBCC' FORCE 1 ALIGNMENT BYTE WITHIN DC
L1       DC    L'1'
         DC    XL8'00'
L2       DC    L'2'
TE       DC    2E'0'
TD       DC    2D'0'
TL       DC    2L'0'
TFD      DC    2FD'0'
TF       DC    2F'0'
TFE      EQU   *
         DS    0D              RPI-1073 REQUIRED IF USING NOALIGN
TES      DC    0E,2F'0'    2E  RPI-946
TDS      DC    0D,2FL8'0'  2D  RPI-946
TLS      DC    0L,2FL16'0' 2L  RPI-946
TFDS     DC    0FD,2FL8'0' 2FD RPI-946
TFS      DC    0F,2F'0'    2F  RPI-946
TFSE     EQU   *
CCW      CCW   OP,DATA,FLAGS,LEN
CCWV     DC    AL1(OP),AL3(DATA),AL1(FLAGS,0),AL2(LEN)
CCW0     CCW0  OP,DATA,FLAGS,LEN
CCW0V    DC    AL1(OP),AL3(DATA),AL1(FLAGS,0),AL2(LEN)
CCW1     CCW1  OP,DATA,FLAGS,LEN
CCW1V    DC    AL1(OP),AL1(FLAGS),AL2(LEN),A(DATA)
DATA     DC    D'0'
OP       EQU   X'12'
FLAGS    EQU   X'34'
LEN      EQU   X'5678'
*MCALL #=     9 LV= 1          RT1   START
RT1_START DS  0H
*MEXIT #=     9 LV= 1 RT1
* verify ds/dc alignment between fields
*MCALL #=    10 LV= 1          RT1   CCE,V5,=X'AA00BBCC'
         DS    0H
         CLC   V5,=X'AA00BBCC'
RT1_TEST1        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1
         LTORG 
RT1_CCE1        DS 0H
*MEXIT #=    10 LV= 1 RT1
* test spaces in x'...'
*MCALL #=    11 LV= 1          RT1   CCE,=X'1234',=X'12 34'
         DS    0H
         CLC   =X'1234',=X'12 34'
RT1_TEST2        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE2
         LTORG 
RT1_CCE2        DS 0H
*MEXIT #=    11 LV= 1 RT1
* test L align to mult. 8
*MCALL #=    12 LV= 1          RT1   CCE,=A(L2-L1),=A(24)
         DS    0H
         CLC   =A(L2-L1),=A(24)
RT1_TEST3        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE3
         LTORG 
RT1_CCE3        DS 0H
*MEXIT #=    12 LV= 1 RT1
* test scale factor for FHEDL
*MCALL #=    13 LV= 1          RT1   CCE,=FS24'1',=X'01000000'
         DS    0H
         CLC   =FS24'1',=X'01000000'
RT1_TEST4        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE4
         LTORG 
RT1_CCE4        DS 0H
*MEXIT #=    13 LV= 1 RT1
*MCALL #=    14 LV= 1          RT1   CCE,=HS12'1',=X'1000'
         DS    0H
         CLC   =HS12'1',=X'1000'
RT1_TEST5        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE5
         LTORG 
RT1_CCE5        DS 0H
*MEXIT #=    14 LV= 1 RT1
*MCALL #=    15 LV= 1          RT1   CCE,=ES2'1',=X'43100000'
         DS    0H
         CLC   =ES2'1',=X'43100000'
RT1_TEST6        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE6
         LTORG 
RT1_CCE6        DS 0H
*MEXIT #=    15 LV= 1 RT1
*MCALL #=    16 LV= 1          RT1   CCE,=DS2'1',=X'4310000000000000'
         DS    0H
         CLC   =DS2'1',=X'4310000000000000'
RT1_TEST7        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE7
         LTORG 
RT1_CCE7        DS 0H
*MEXIT #=    16 LV= 1 RT1
*MCALL #=    17 LV= 1          RT1   CCE,=LS2'1',=X'4310000000000000350X
               0000000000000'
         DS    0H
         CLC   =LS2'1',=X'43100000000000003500000000000000'
RT1_TEST8        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE8
         LTORG 
RT1_CCE8        DS 0H
*MEXIT #=    17 LV= 1 RT1
* test (MIN) and (MAX) constants
*MCALL #=    18 LV= 1          RT1   CCE,=DB'(MIN)',=X'0010000000000000X
               '
         DS    0H
         CLC   =DB'(MIN)',=X'0010000000000000'
RT1_TEST9        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE9
         LTORG 
RT1_CCE9        DS 0H
*MEXIT #=    18 LV= 1 RT1
*MCALL #=    19 LV= 1          RT1   CCE,=DD'(MIN)',=X'0000000000000001X
               '
         DS    0H
         CLC   =DD'(MIN)',=X'0000000000000001'
RT1_TEST10       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE10
         LTORG 
RT1_CCE10       DS 0H
*MEXIT #=    19 LV= 1 RT1
*MCALL #=    20 LV= 1          RT1   CCE,=DH'(MIN)',=X'0110000000000000X
               '
         DS    0H
         CLC   =DH'(MIN)',=X'0110000000000000'
RT1_TEST11       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE11
         LTORG 
RT1_CCE11       DS 0H
*MEXIT #=    20 LV= 1 RT1
*MCALL #=    21 LV= 1          RT1   CCE,=EB'(MIN)',=X'00800000'
         DS    0H
         CLC   =EB'(MIN)',=X'00800000'
RT1_TEST12       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE12
         LTORG 
RT1_CCE12       DS 0H
*MEXIT #=    21 LV= 1 RT1
*MCALL #=    22 LV= 1          RT1   CCE,=ED'(MIN)',=X'00000001'
         DS    0H
         CLC   =ED'(MIN)',=X'00000001'
RT1_TEST13       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE13
         LTORG 
RT1_CCE13       DS 0H
*MEXIT #=    22 LV= 1 RT1
*MCALL #=    23 LV= 1          RT1   CCE,=EH'(MIN)',=X'01100000'
         DS    0H
         CLC   =EH'(MIN)',=X'01100000'
RT1_TEST14       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE14
         LTORG 
RT1_CCE14       DS 0H
*MEXIT #=    23 LV= 1 RT1
*MCALL #=    24 LV= 1          RT1   CCE,=LB'(MIN)',=X'0001000000000000X
               0000000000000000'
         DS    0H
         CLC   =LB'(MIN)',=X'00010000000000000000000000000000'
RT1_TEST15       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE15
         LTORG 
RT1_CCE15       DS 0H
*MEXIT #=    24 LV= 1 RT1
*MCALL #=    25 LV= 1          RT1   CCE,=LD'(MIN)',=X'0000000000000000X
               0000000000000001'
         DS    0H
         CLC   =LD'(MIN)',=X'00000000000000000000000000000001'
RT1_TEST16       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE16
         LTORG 
RT1_CCE16       DS 0H
*MEXIT #=    25 LV= 1 RT1
*MCALL #=    26 LV= 1          RT1   CCE,=LH'(MIN)',=X'0110000000000000X
               7200000000000000'
         DS    0H
         CLC   =LH'(MIN)',=X'01100000000000007200000000000000'
RT1_TEST17       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE17
         LTORG 
RT1_CCE17       DS 0H
*MEXIT #=    26 LV= 1 RT1
*MCALL #=    27 LV= 1          RT1   CCE,=DB'(MAX)',=X'7FEFFFFFFFFFFFFFX
               '
         DS    0H
         CLC   =DB'(MAX)',=X'7FEFFFFFFFFFFFFF'
RT1_TEST18       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE18
         LTORG 
RT1_CCE18       DS 0H
*MEXIT #=    27 LV= 1 RT1
*MCALL #=    28 LV= 1          RT1   CCE,=DD'(MAX)',=X'77FCFF3FCFF3FCFFX
               '
         DS    0H
         CLC   =DD'(MAX)',=X'77FCFF3FCFF3FCFF'
RT1_TEST19       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE19
         LTORG 
RT1_CCE19       DS 0H
*MEXIT #=    28 LV= 1 RT1
*MCALL #=    29 LV= 1          RT1   CCE,=DH'(MAX)',=X'7FFFFFFFFFFFFFFFX
               '
         DS    0H
         CLC   =DH'(MAX)',=X'7FFFFFFFFFFFFFFF'
RT1_TEST20       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE20
         LTORG 
RT1_CCE20       DS 0H
*MEXIT #=    29 LV= 1 RT1
*MCALL #=    30 LV= 1          RT1   CCE,=EB'(MAX)',=X'7F7FFFFF'
         DS    0H
         CLC   =EB'(MAX)',=X'7F7FFFFF'
RT1_TEST21       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE21
         LTORG 
RT1_CCE21       DS 0H
*MEXIT #=    30 LV= 1 RT1
*MCALL #=    31 LV= 1          RT1   CCE,=ED'(MAX)',=X'77F3FCFF'
         DS    0H
         CLC   =ED'(MAX)',=X'77F3FCFF'
RT1_TEST22       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE22
         LTORG 
RT1_CCE22       DS 0H
*MEXIT #=    31 LV= 1 RT1
*MCALL #=    32 LV= 1          RT1   CCE,=EH'(MAX)',=X'7FFFFFFF'
         DS    0H
         CLC   =EH'(MAX)',=X'7FFFFFFF'
RT1_TEST23       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE23
         LTORG 
RT1_CCE23       DS 0H
*MEXIT #=    32 LV= 1 RT1
*MCALL #=    33 LV= 1          RT1   CCE,=LH'(MAX)',=X'7FFFFFFFFFFFFFFFX
               71FFFFFFFFFFFFFF'
         DS    0H
         CLC   =LH'(MAX)',=X'7FFFFFFFFFFFFFFF71FFFFFFFFFFFFFF'
RT1_TEST24       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE24
         LTORG 
RT1_CCE24       DS 0H
*MEXIT #=    33 LV= 1 RT1
*MCALL #=    34 LV= 1          RT1   CCE,=LD'(MAX)',=X'77FFCFF3FCFF3FCFX
               F3FCFF3FCFF3FCFF'
         DS    0H
         CLC   =LD'(MAX)',=X'77FFCFF3FCFF3FCFF3FCFF3FCFF3FCFF'
RT1_TEST25       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE25
         LTORG 
RT1_CCE25       DS 0H
*MEXIT #=    34 LV= 1 RT1
*MCALL #=    35 LV= 1          RT1   CCE,=LB'(MAX)',=X'7FFEFFFFFFFFFFFFX
               FFFFFFFFFFFFFFFF'
         DS    0H
         CLC   =LB'(MAX)',=X'7FFEFFFFFFFFFFFFFFFFFFFFFFFFFFFF'
RT1_TEST26       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE26
         LTORG 
RT1_CCE26       DS 0H
*MEXIT #=    35 LV= 1 RT1
* verify dc field continuations
*MCALL #=    36 LV= 1          RT1   CCE,M1,V1A,9
         DS    0H
         LA    1,M1
         LA    2,V1A
         CLC   0(9,1),0(2)
RT1_TEST27       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE27
         LTORG 
RT1_CCE27       DS 0H
*MEXIT #=    36 LV= 1 RT1
*MCALL #=    37 LV= 1          RT1   CCE,M2,V2,29
         DS    0H
         LA    1,M2
         LA    2,V2
         CLC   0(29,1),0(2)
RT1_TEST28       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE28
         LTORG 
RT1_CCE28       DS 0H
*MEXIT #=    37 LV= 1 RT1
*MCALL #=    38 LV= 1          RT1   CCE,M3,V3,9
         DS    0H
         LA    1,M3
         LA    2,V3
         CLC   0(9,1),0(2)
RT1_TEST29       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE29
         LTORG 
RT1_CCE29       DS 0H
*MEXIT #=    38 LV= 1 RT1
*MCALL #=    39 LV= 1          RT1   CCE,M4,V4,13
         DS    0H
         LA    1,M4
         LA    2,V4
         CLC   0(13,1),0(2)
RT1_TEST30       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE30
         LTORG 
RT1_CCE30       DS 0H
*MEXIT #=    39 LV= 1 RT1
* single dup default and explicit length tests
*MCALL #=    40 LV= 1          RT1   CCE,=A(-1),=X'FFFFFFFF'
         DS    0H
         CLC   =A(-1),=X'FFFFFFFF'
RT1_TEST31       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE31
         LTORG 
RT1_CCE31       DS 0H
*MEXIT #=    40 LV= 1 RT1
*MCALL #=    41 LV= 1          RT1   CCE,=A(-1,0,1),=XL4'FFFFFFFF,0,1',X
               12
         DS    0H
         LA    1,=A(-1,0,1)
         LA    2,=XL4'FFFFFFFF,0,1'
         CLC   0(12,1),0(2)
RT1_TEST32       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE32
         LTORG 
RT1_CCE32       DS 0H
*MEXIT #=    41 LV= 1 RT1
*MCALL #=    42 LV= 1          RT1   CCE,=AL1(-1,0,1),=X'FF0001',3
         DS    0H
         LA    1,=AL1(-1,0,1)
         LA    2,=X'FF0001'
         CLC   0(3,1),0(2)
RT1_TEST33       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE33
         LTORG 
RT1_CCE33       DS 0H
*MEXIT #=    42 LV= 1 RT1
*MCALL #=    43 LV= 1          RT1   CCE,=B'11',=X'3'
         DS    0H
         CLC   =B'11',=X'3'
RT1_TEST34       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE34
         LTORG 
RT1_CCE34       DS 0H
*MEXIT #=    43 LV= 1 RT1
*MCALL #=    44 LV= 1          RT1   CCE,=B'1,11,111',=X'1,3,7',3
         DS    0H
         LA    1,=B'1,11,111'
         LA    2,=X'1,3,7'
         CLC   0(3,1),0(2)
RT1_TEST35       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE35
         LTORG 
RT1_CCE35       DS 0H
*MEXIT #=    44 LV= 1 RT1
*MCALL #=    45 LV= 1          RT1   CCE,=BL2'1,10,11',=X'000100020003'X
               ,6
         DS    0H
         LA    1,=BL2'1,10,11'
         LA    2,=X'000100020003'
         CLC   0(6,1),0(2)
RT1_TEST36       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE36
         LTORG 
RT1_CCE36       DS 0H
*MEXIT #=    45 LV= 1 RT1
*MCALL #=    46 LV= 1          RT1   CCE,=B'1,10,101',=X'1,2,5',3
         DS    0H
         LA    1,=B'1,10,101'
         LA    2,=X'1,2,5'
         CLC   0(3,1),0(2)
RT1_TEST37       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE37
         LTORG 
RT1_CCE37       DS 0H
*MEXIT #=    46 LV= 1 RT1
*MCALL #=    47 LV= 1          RT1   CCE,=BL2'1,10,101',=XL2'1,2,5',6
         DS    0H
         LA    1,=BL2'1,10,101'
         LA    2,=XL2'1,2,5'
         CLC   0(6,1),0(2)
RT1_TEST38       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE38
         LTORG 
RT1_CCE38       DS 0H
*MEXIT #=    47 LV= 1 RT1
*MCALL #=    48 LV= 1          RT1   CCE,=B'11110000,1111000111110010',X
               =X'F0F1F2',3
         DS    0H
         LA    1,=B'11110000,1111000111110010'
         LA    2,=X'F0F1F2'
         CLC   0(3,1),0(2)
RT1_TEST39       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE39
         LTORG 
RT1_CCE39       DS 0H
*MEXIT #=    48 LV= 1 RT1
*MCALL #=    49 LV= 1          RT1   CCE,=C'1',=X'31'
         DS    0H
         CLC   =C'1',=X'31'
RT1_TEST40       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE40
         LTORG 
RT1_CCE40       DS 0H
*MEXIT #=    49 LV= 1 RT1
*MCALL #=    50 LV= 1          RT1   CCE,=C'ABC',=X'414243'
         DS    0H
         CLC   =C'ABC',=X'414243'
RT1_TEST41       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE41
         LTORG 
RT1_CCE41       DS 0H
*MEXIT #=    50 LV= 1 RT1
*MCALL #=    51 LV= 1          RT1   CCE,=CL3'A',=X'412020'
         DS    0H
         CLC   =CL3'A',=X'412020'
RT1_TEST42       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE42
         LTORG 
RT1_CCE42       DS 0H
*MEXIT #=    51 LV= 1 RT1
*MCALL #=    52 LV= 1          RT1   CCE,=Z'123',=X'3132C3' RPI-777
         DS    0H
         CLC   =Z'123',=X'3132C3'
RT1_TEST43       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE43
         LTORG 
RT1_CCE43       DS 0H
*MEXIT #=    52 LV= 1 RT1
*MCALL #=    53 LV= 1          RT1   CCE,=C'1''2',=X'312732'
         DS    0H
         CLC   =C'1''2',=X'312732'
RT1_TEST44       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE44
         LTORG 
RT1_CCE44       DS 0H
*MEXIT #=    53 LV= 1 RT1
*MCALL #=    54 LV= 1          RT1   CCE,=C"1""2",=X'312232'
         DS    0H
         CLC   =C"1""2",=X'312232'
RT1_TEST45       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE45
         LTORG 
RT1_CCE45       DS 0H
*MEXIT #=    54 LV= 1 RT1
*MCALL #=    55 LV= 1          RT1   CCE,=C!1!!2!,=X'F15AF2'
         DS    0H
         CLC   =C!1!!2!,=X'F15AF2'
RT1_TEST46       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE46
         LTORG 
RT1_CCE46       DS 0H
*MEXIT #=    55 LV= 1 RT1
*MCALL #=    56 LV= 1          RT1   CCE,=D'1',=X'4110000000000000'
         DS    0H
         CLC   =D'1',=X'4110000000000000'
RT1_TEST47       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE47
         LTORG 
RT1_CCE47       DS 0H
*MEXIT #=    56 LV= 1 RT1
*MCALL #=    57 LV= 1          RT1   CCE,=E'1',=X'41100000'
         DS    0H
         CLC   =E'1',=X'41100000'
RT1_TEST48       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE48
         LTORG 
RT1_CCE48       DS 0H
*MEXIT #=    57 LV= 1 RT1
*MCALL #=    58 LV= 1          RT1   CCE,=F'1',=X'00000001'
         DS    0H
         CLC   =F'1',=X'00000001'
RT1_TEST49       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE49
         LTORG 
RT1_CCE49       DS 0H
*MEXIT #=    58 LV= 1 RT1
*MCALL #=    59 LV= 1          RT1   CCE,=FL1'1',=X'01'
         DS    0H
         CLC   =FL1'1',=X'01'
RT1_TEST50       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE50
         LTORG 
RT1_CCE50       DS 0H
*MEXIT #=    59 LV= 1 RT1
*MCALL #=    60 LV= 1          RT1   CCE,=FL1'1,-1,3',=X'01FF03',3
         DS    0H
         LA    1,=FL1'1,-1,3'
         LA    2,=X'01FF03'
         CLC   0(3,1),0(2)
RT1_TEST51       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE51
         LTORG 
RT1_CCE51       DS 0H
*MEXIT #=    60 LV= 1 RT1
*MCALL #=    61 LV= 1          RT1   CCE,=H'1',=X'0001'
         DS    0H
         CLC   =H'1',=X'0001'
RT1_TEST52       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE52
         LTORG 
RT1_CCE52       DS 0H
*MEXIT #=    61 LV= 1 RT1
*MCALL #=    62 LV= 1          RT1   CCE,=HL1'1',=X'01'
         DS    0H
         CLC   =HL1'1',=X'01'
RT1_TEST53       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE53
         LTORG 
RT1_CCE53       DS 0H
*MEXIT #=    62 LV= 1 RT1
*MCALL #=    63 LV= 1          RT1   CCE,=HL1'1,-1,3',=X'01FF03',3
         DS    0H
         LA    1,=HL1'1,-1,3'
         LA    2,=X'01FF03'
         CLC   0(3,1),0(2)
RT1_TEST54       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE54
         LTORG 
RT1_CCE54       DS 0H
*MEXIT #=    63 LV= 1 RT1
*MCALL #=    64 LV= 1          RT1   CCE,=L'1',=X'411000000000000033000X
               00000000000'
         DS    0H
         CLC   =L'1',=X'41100000000000003300000000000000'
RT1_TEST55       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE55
         LTORG 
RT1_CCE55       DS 0H
*MEXIT #=    64 LV= 1 RT1
*MCALL #=    65 LV= 1          RT1   CCE,=P'1',=X'1C'
         DS    0H
         CLC   =P'1',=X'1C'
RT1_TEST56       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE56
         LTORG 
RT1_CCE56       DS 0H
*MEXIT #=    65 LV= 1 RT1
*MCALL #=    66 LV= 1          RT1   CCE,=P'1.5',=X'015C'
         DS    0H
         CLC   =P'1.5',=X'015C'
RT1_TEST57       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE57
         LTORG 
RT1_CCE57       DS 0H
*MEXIT #=    66 LV= 1 RT1
*MCALL #=    67 LV= 1          RT1   CCE,=P'-1.5',=X'015D'
         DS    0H
         CLC   =P'-1.5',=X'015D'
RT1_TEST58       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE58
         LTORG 
RT1_CCE58       DS 0H
*MEXIT #=    67 LV= 1 RT1
*MCALL #=    68 LV= 1          RT1   CCE,=PL2'1,-1,12',=X'001C001D012C'X
               ,6
         DS    0H
         LA    1,=PL2'1,-1,12'
         LA    2,=X'001C001D012C'
         CLC   0(6,1),0(2)
RT1_TEST59       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE59
         LTORG 
RT1_CCE59       DS 0H
*MEXIT #=    68 LV= 1 RT1
*MCALL #=    69 LV= 1          RT1   CCE,=P'12,1234',=X'012C01234C',5
         DS    0H
         LA    1,=P'12,1234'
         LA    2,=X'012C01234C'
         CLC   0(5,1),0(2)
RT1_TEST60       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE60
         LTORG 
RT1_CCE60       DS 0H
*MEXIT #=    69 LV= 1 RT1
*MCALL #=    70 LV= 1          RT1   CCE,=X'1,1',=X'0101',2
         DS    0H
         LA    1,=X'1,1'
         LA    2,=X'0101'
         CLC   0(2,1),0(2)
RT1_TEST61       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE61
         LTORG 
RT1_CCE61       DS 0H
*MEXIT #=    70 LV= 1 RT1
*MCALL #=    71 LV= 1          RT1   CCE,=XL2'1,1',=X'00010001',4
         DS    0H
         LA    1,=XL2'1,1'
         LA    2,=X'00010001'
         CLC   0(4,1),0(2)
RT1_TEST62       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE62
         LTORG 
RT1_CCE62       DS 0H
*MEXIT #=    71 LV= 1 RT1
* multiple dup tests
*MCALL #=    72 LV= 1          RT1   CCE,=2A(-1),=2X'FFFFFFFF',8
         DS    0H
         LA    1,=2A(-1)
         LA    2,=2X'FFFFFFFF'
         CLC   0(8,1),0(2)
RT1_TEST63       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE63
         LTORG 
RT1_CCE63       DS 0H
*MEXIT #=    72 LV= 1 RT1
*MCALL #=    73 LV= 1          RT1   CCE,=2A(-1,0,1),=2XL4'FFFFFFFF,0,1X
               ',24
         DS    0H
         LA    1,=2A(-1,0,1)
         LA    2,=2XL4'FFFFFFFF,0,1'
         CLC   0(24,1),0(2)
RT1_TEST64       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE64
         LTORG 
RT1_CCE64       DS 0H
*MEXIT #=    73 LV= 1 RT1
*MCALL #=    74 LV= 1          RT1   CCE,=2AL1(-1,0,1),=2X'FF0001',6
         DS    0H
         LA    1,=2AL1(-1,0,1)
         LA    2,=2X'FF0001'
         CLC   0(6,1),0(2)
RT1_TEST65       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE65
         LTORG 
RT1_CCE65       DS 0H
*MEXIT #=    74 LV= 1 RT1
*MCALL #=    75 LV= 1          RT1   CCE,=2B'11',=2X'3',2
         DS    0H
         LA    1,=2B'11'
         LA    2,=2X'3'
         CLC   0(2,1),0(2)
RT1_TEST66       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE66
         LTORG 
RT1_CCE66       DS 0H
*MEXIT #=    75 LV= 1 RT1
*MCALL #=    76 LV= 1          RT1   CCE,=2B'1,11,111',=2X'1,3,7',6
         DS    0H
         LA    1,=2B'1,11,111'
         LA    2,=2X'1,3,7'
         CLC   0(6,1),0(2)
RT1_TEST67       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE67
         LTORG 
RT1_CCE67       DS 0H
*MEXIT #=    76 LV= 1 RT1
*MCALL #=    77 LV= 1          RT1   CCE,=2BL2'1,10,11',=2X'00010002000X
               3',12
         DS    0H
         LA    1,=2BL2'1,10,11'
         LA    2,=2X'000100020003'
         CLC   0(12,1),0(2)
RT1_TEST68       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE68
         LTORG 
RT1_CCE68       DS 0H
*MEXIT #=    77 LV= 1 RT1
*MCALL #=    78 LV= 1          RT1   CCE,=2B'1,10,101',=2X'1,2,5',6
         DS    0H
         LA    1,=2B'1,10,101'
         LA    2,=2X'1,2,5'
         CLC   0(6,1),0(2)
RT1_TEST69       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE69
         LTORG 
RT1_CCE69       DS 0H
*MEXIT #=    78 LV= 1 RT1
*MCALL #=    79 LV= 1          RT1   CCE,=2BL2'1,10,101',=2XL2'1,2,5',1X
               2
         DS    0H
         LA    1,=2BL2'1,10,101'
         LA    2,=2XL2'1,2,5'
         CLC   0(12,1),0(2)
RT1_TEST70       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE70
         LTORG 
RT1_CCE70       DS 0H
*MEXIT #=    79 LV= 1 RT1
*MCALL #=    80 LV= 1          RT1   CCE,=2B'11110000,1111000111110010'X
               ,=2X'F0F1F2',6
         DS    0H
         LA    1,=2B'11110000,1111000111110010'
         LA    2,=2X'F0F1F2'
         CLC   0(6,1),0(2)
RT1_TEST71       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE71
         LTORG 
RT1_CCE71       DS 0H
*MEXIT #=    80 LV= 1 RT1
*MCALL #=    81 LV= 1          RT1   CCE,=2C'1',=2X'31',2
         DS    0H
         LA    1,=2C'1'
         LA    2,=2X'31'
         CLC   0(2,1),0(2)
RT1_TEST72       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE72
         LTORG 
RT1_CCE72       DS 0H
*MEXIT #=    81 LV= 1 RT1
*MCALL #=    82 LV= 1          RT1   CCE,=2C'ABC',=2X'414243',6
         DS    0H
         LA    1,=2C'ABC'
         LA    2,=2X'414243'
         CLC   0(6,1),0(2)
RT1_TEST73       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE73
         LTORG 
RT1_CCE73       DS 0H
*MEXIT #=    82 LV= 1 RT1
*MCALL #=    83 LV= 1          RT1   CCE,=2CL3'A',=2X'412020',6
         DS    0H
         LA    1,=2CL3'A'
         LA    2,=2X'412020'
         CLC   0(6,1),0(2)
RT1_TEST74       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE74
         LTORG 
RT1_CCE74       DS 0H
*MEXIT #=    83 LV= 1 RT1
*MCALL #=    84 LV= 1          RT1   CCE,=2Z'123',=2X'3132C3',6  RPI-77X
               7
         DS    0H
         LA    1,=2Z'123'
         LA    2,=2X'3132C3'
         CLC   0(6,1),0(2)
RT1_TEST75       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE75
         LTORG 
RT1_CCE75       DS 0H
*MEXIT #=    84 LV= 1 RT1
*MCALL #=    85 LV= 1          RT1   CCE,=2C"1""2",=2X'312232',6
         DS    0H
         LA    1,=2C"1""2"
         LA    2,=2X'312232'
         CLC   0(6,1),0(2)
RT1_TEST76       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE76
         LTORG 
RT1_CCE76       DS 0H
*MEXIT #=    85 LV= 1 RT1
*MCALL #=    86 LV= 1          RT1   CCE,=2D'1',=2X'4110000000000000',1X
               6
         DS    0H
         LA    1,=2D'1'
         LA    2,=2X'4110000000000000'
         CLC   0(16,1),0(2)
RT1_TEST77       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE77
         LTORG 
RT1_CCE77       DS 0H
*MEXIT #=    86 LV= 1 RT1
*MCALL #=    87 LV= 1          RT1   CCE,=2E'1',=2X'41100000',8
         DS    0H
         LA    1,=2E'1'
         LA    2,=2X'41100000'
         CLC   0(8,1),0(2)
RT1_TEST78       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE78
         LTORG 
RT1_CCE78       DS 0H
*MEXIT #=    87 LV= 1 RT1
*MCALL #=    88 LV= 1          RT1   CCE,=2F'1',=2X'00000001',8
         DS    0H
         LA    1,=2F'1'
         LA    2,=2X'00000001'
         CLC   0(8,1),0(2)
RT1_TEST79       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE79
         LTORG 
RT1_CCE79       DS 0H
*MEXIT #=    88 LV= 1 RT1
*MCALL #=    89 LV= 1          RT1   CCE,=2FL1'1',=2X'01',2
         DS    0H
         LA    1,=2FL1'1'
         LA    2,=2X'01'
         CLC   0(2,1),0(2)
RT1_TEST80       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE80
         LTORG 
RT1_CCE80       DS 0H
*MEXIT #=    89 LV= 1 RT1
*MCALL #=    90 LV= 1          RT1   CCE,=2FL1'1,-1,3',=2X'01FF03',6
         DS    0H
         LA    1,=2FL1'1,-1,3'
         LA    2,=2X'01FF03'
         CLC   0(6,1),0(2)
RT1_TEST81       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE81
         LTORG 
RT1_CCE81       DS 0H
*MEXIT #=    90 LV= 1 RT1
*MCALL #=    91 LV= 1          RT1   CCE,=2H'1',=2X'0001',4
         DS    0H
         LA    1,=2H'1'
         LA    2,=2X'0001'
         CLC   0(4,1),0(2)
RT1_TEST82       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE82
         LTORG 
RT1_CCE82       DS 0H
*MEXIT #=    91 LV= 1 RT1
*MCALL #=    92 LV= 1          RT1   CCE,=2HL1'1',=2X'01',2
         DS    0H
         LA    1,=2HL1'1'
         LA    2,=2X'01'
         CLC   0(2,1),0(2)
RT1_TEST83       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE83
         LTORG 
RT1_CCE83       DS 0H
*MEXIT #=    92 LV= 1 RT1
*MCALL #=    93 LV= 1          RT1   CCE,=2HL1'1,-1,3',=2X'01FF03',6
         DS    0H
         LA    1,=2HL1'1,-1,3'
         LA    2,=2X'01FF03'
         CLC   0(6,1),0(2)
RT1_TEST84       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE84
         LTORG 
RT1_CCE84       DS 0H
*MEXIT #=    93 LV= 1 RT1
*MCALL #=    94 LV= 1          RT1   CCE,=2L'1',=2X'4110000000000000330X
               0000000000000',32
         DS    0H
         LA    1,=2L'1'
         LA    2,=2X'41100000000000003300000000000000'
         CLC   0(32,1),0(2)
RT1_TEST85       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE85
         LTORG 
RT1_CCE85       DS 0H
*MEXIT #=    94 LV= 1 RT1
*MCALL #=    95 LV= 1          RT1   CCE,=2P'1',=2X'1C',2
         DS    0H
         LA    1,=2P'1'
         LA    2,=2X'1C'
         CLC   0(2,1),0(2)
RT1_TEST86       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE86
         LTORG 
RT1_CCE86       DS 0H
*MEXIT #=    95 LV= 1 RT1
*MCALL #=    96 LV= 1          RT1   CCE,=2PL2'1,-1,12',=2X'001C001D012X
               C',12
         DS    0H
         LA    1,=2PL2'1,-1,12'
         LA    2,=2X'001C001D012C'
         CLC   0(12,1),0(2)
RT1_TEST87       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE87
         LTORG 
RT1_CCE87       DS 0H
*MEXIT #=    96 LV= 1 RT1
*MCALL #=    97 LV= 1          RT1   CCE,=2P'12,1234',=2X'012C01234C',1X
               0
         DS    0H
         LA    1,=2P'12,1234'
         LA    2,=2X'012C01234C'
         CLC   0(10,1),0(2)
RT1_TEST88       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE88
         LTORG 
RT1_CCE88       DS 0H
*MEXIT #=    97 LV= 1 RT1
*MCALL #=    98 LV= 1          RT1   CCE,=2X'1,1',=2X'0101',4
         DS    0H
         LA    1,=2X'1,1'
         LA    2,=2X'0101'
         CLC   0(4,1),0(2)
RT1_TEST89       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE89
         LTORG 
RT1_CCE89       DS 0H
*MEXIT #=    98 LV= 1 RT1
*MCALL #=    99 LV= 1          RT1   CCE,=2XL2'1,1',=2X'00010001',8
         DS    0H
         LA    1,=2XL2'1,1'
         LA    2,=2X'00010001'
         CLC   0(8,1),0(2)
RT1_TEST90       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE90
         LTORG 
RT1_CCE90       DS 0H
*MEXIT #=    99 LV= 1 RT1
* test translation tables
         CLC   =C'ABCDEFGHI',=X'414243444546474849'
*MCALL #=   100 LV= 1          RT1   CCE
         DS    0H
RT1_TEST91       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE91
         LTORG 
RT1_CCE91       DS 0H
*MEXIT #=   100 LV= 1 RT1
         CLC   =C'JKLMNOPQR',=X'4A4B4C4D4E4F505152'
*MCALL #=   101 LV= 1          RT1   CCE
         DS    0H
RT1_TEST92       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE92
         LTORG 
RT1_CCE92       DS 0H
*MEXIT #=   101 LV= 1 RT1
         CLC   =C'STUVWXYZ',=X'535455565758595A5B'
*MCALL #=   102 LV= 1          RT1   CCE
         DS    0H
RT1_TEST93       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE93
         LTORG 
RT1_CCE93       DS 0H
*MEXIT #=   102 LV= 1 RT1
         CLC   =C'abcdefghi',=X'616263646566676869'
*MCALL #=   103 LV= 1          RT1   CCE
         DS    0H
RT1_TEST94       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE94
         LTORG 
RT1_CCE94       DS 0H
*MEXIT #=   103 LV= 1 RT1
         CLC   =C'jklmnopqr',=X'6A6B6C6D6E6F707172'
*MCALL #=   104 LV= 1          RT1   CCE
         DS    0H
RT1_TEST95       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE95
         LTORG 
RT1_CCE95       DS 0H
*MEXIT #=   104 LV= 1 RT1
         CLC   =C'stuvwxyz',=X'737475767778797A7B'
*MCALL #=   105 LV= 1          RT1   CCE
         DS    0H
RT1_TEST96       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE96
         LTORG 
RT1_CCE96       DS 0H
*MEXIT #=   105 LV= 1 RT1
         CLC   =C'0123456789',=X'30313233343536373839'
*MCALL #=   106 LV= 1          RT1   CCE
         DS    0H
RT1_TEST97       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE97
         LTORG 
RT1_CCE97       DS 0H
*MEXIT #=   106 LV= 1 RT1
* ASCII special characters
         CLC =X'20',=C' '
*MCALL #=   107 LV= 1          RT1   CCE
         DS    0H
RT1_TEST98       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE98
         LTORG 
RT1_CCE98       DS 0H
*MEXIT #=   107 LV= 1 RT1
         CLC =X'3C282B7C',=C'<(+|'
*MCALL #=   108 LV= 1          RT1   CCE
         DS    0H
RT1_TEST99       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE99
         LTORG 
RT1_CCE99       DS 0H
*MEXIT #=   108 LV= 1 RT1
         CLC =X'26',=C'&&'
*MCALL #=   109 LV= 1          RT1   CCE
         DS    0H
RT1_TEST100      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE100
         LTORG 
RT1_CCE100      DS 0H
*MEXIT #=   109 LV= 1 RT1
         CLC =X'21242A293B5E',=C'!$*);^'
*MCALL #=   110 LV= 1          RT1   CCE
         DS    0H
RT1_TEST101      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE101
         LTORG 
RT1_CCE101      DS 0H
*MEXIT #=   110 LV= 1 RT1
         CLC =X'2D2F',=C'-/'
*MCALL #=   111 LV= 1          RT1   CCE
         DS    0H
RT1_TEST102      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE102
         LTORG 
RT1_CCE102      DS 0H
*MEXIT #=   111 LV= 1 RT1
         CLC =X'2C255F3E3F',=C',%_>?'
*MCALL #=   112 LV= 1          RT1   CCE
         DS    0H
RT1_TEST103      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE103
         LTORG 
RT1_CCE103      DS 0H
*MEXIT #=   112 LV= 1 RT1
         CLC =X'603A2340273D22',=C'`:#@''="'
*MCALL #=   113 LV= 1          RT1   CCE
         DS    0H
RT1_TEST104      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE104
         LTORG 
RT1_CCE104      DS 0H
*MEXIT #=   113 LV= 1 RT1
         CLC =X'7B',=C'{'
*MCALL #=   114 LV= 1          RT1   CCE
         DS    0H
RT1_TEST105      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE105
         LTORG 
RT1_CCE105      DS 0H
*MEXIT #=   114 LV= 1 RT1
         CLC =X'7D',=C'}'
*MCALL #=   115 LV= 1          RT1   CCE
         DS    0H
RT1_TEST106      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE106
         LTORG 
RT1_CCE106      DS 0H
*MEXIT #=   115 LV= 1 RT1
         CLC =X'7E5B',=C'~['
*MCALL #=   116 LV= 1          RT1   CCE
         DS    0H
RT1_TEST107      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE107
         LTORG 
RT1_CCE107      DS 0H
*MEXIT #=   116 LV= 1 RT1
         CLC =X'5D',=C']'
*MCALL #=   117 LV= 1          RT1   CCE
         DS    0H
RT1_TEST108      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE108
         LTORG 
RT1_CCE108      DS 0H
*MEXIT #=   117 LV= 1 RT1
* test && and '' in comments (this), setc, sdt, and models
         CLC   =C'&&',=X'26'
*MCALL #=   118 LV= 1          RT1   CCE
         DS    0H
RT1_TEST109      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE109
         LTORG 
RT1_CCE109      DS 0H
*MEXIT #=   118 LV= 1 RT1
         CLC   =C'&&',=X'26'
*MCALL #=   119 LV= 1          RT1   CCE
         DS    0H
RT1_TEST110      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE110
         LTORG 
RT1_CCE110      DS 0H
*MEXIT #=   119 LV= 1 RT1
         CLI   =C'&&',C'&&'
*MCALL #=   120 LV= 1          RT1   CCE
         DS    0H
RT1_TEST111      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE111
         LTORG 
RT1_CCE111      DS 0H
*MEXIT #=   120 LV= 1 RT1
         CLI   =C'&&',C"&&"
*MCALL #=   121 LV= 1          RT1   CCE
         DS    0H
RT1_TEST112      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE112
         LTORG 
RT1_CCE112      DS 0H
*MEXIT #=   121 LV= 1 RT1
         CLC   =C'''',=X'27'
*MCALL #=   122 LV= 1          RT1   CCE
         DS    0H
RT1_TEST113      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE113
         LTORG 
RT1_CCE113      DS 0H
*MEXIT #=   122 LV= 1 RT1
         CLC   =C'''',=X'27'
*MCALL #=   123 LV= 1          RT1   CCE
         DS    0H
RT1_TEST114      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE114
         LTORG 
RT1_CCE114      DS 0H
*MEXIT #=   123 LV= 1 RT1
         CLI   =C'''',C''''
*MCALL #=   124 LV= 1          RT1   CCE
         DS    0H
RT1_TEST115      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE115
         LTORG 
RT1_CCE115      DS 0H
*MEXIT #=   124 LV= 1 RT1
         CLI   =C'''',C"''"
*MCALL #=   125 LV= 1          RT1   CCE
         DS    0H
RT1_TEST116      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE116
         LTORG 
RT1_CCE116      DS 0H
*MEXIT #=   125 LV= 1 RT1
         CLI   =C'!',C"!"
*MCALL #=   126 LV= 1          RT1   CCE
         DS    0H
RT1_TEST117      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE117
         LTORG 
RT1_CCE117      DS 0H
*MEXIT #=   126 LV= 1 RT1
         CLI   =C'"',C""""
*MCALL #=   127 LV= 1          RT1   CCE
         DS    0H
RT1_TEST118      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE118
         LTORG 
RT1_CCE118      DS 0H
*MEXIT #=   127 LV= 1 RT1
* TEST CA/CE/AD/FD/VD
*MCALL #=   128 LV= 1          RT1   CCE,=CA'1',=X'31'
         DS    0H
         CLC   =CA'1',=X'31'
RT1_TEST119      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE119
         LTORG 
RT1_CCE119      DS 0H
*MEXIT #=   128 LV= 1 RT1
*MCALL #=   129 LV= 1          RT1   CCE,=CE'1',=X'F1'
         DS    0H
         CLC   =CE'1',=X'F1'
RT1_TEST120      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE120
         LTORG 
RT1_CCE120      DS 0H
*MEXIT #=   129 LV= 1 RT1
*MCALL #=   130 LV= 1          RT1   CCE,=ca'1',=X'31'
         DS    0H
         CLC   =ca'1',=X'31'
RT1_TEST121      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE121
         LTORG 
RT1_CCE121      DS 0H
*MEXIT #=   130 LV= 1 RT1
*MCALL #=   131 LV= 1          RT1   CCE,=ce'1',=X'F1'
         DS    0H
         CLC   =ce'1',=X'F1'
RT1_TEST122      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE122
         LTORG 
RT1_CCE122      DS 0H
*MEXIT #=   131 LV= 1 RT1
*MCALL #=   132 LV= 1          RT1   CCE,=AD(123),=FL8'123'
         DS    0H
         CLC   =AD(123),=FL8'123'
RT1_TEST123      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE123
         LTORG 
RT1_CCE123      DS 0H
*MEXIT #=   132 LV= 1 RT1
*MCALL #=   133 LV= 1          RT1   CCE,=FD'123',=FL8'123'
         DS    0H
         CLC   =FD'123',=FL8'123'
RT1_TEST124      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE124
         LTORG 
RT1_CCE124      DS 0H
*MEXIT #=   133 LV= 1 RT1
*MCALL #=   134 LV= 1 CVTTOHEX RT1   CCH,=VD(CVTTOHEX),=AL8(CVTTOHEX) RX
               PI-1044 DIFF ADDR
CVTTOHEX DS    0H
         CLC   =VD(CVTTOHEX),=AL8(CVTTOHEX)
RT1_TEST125      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH125
         LTORG 
RT1_CCH125      DS 0H
*MEXIT #=   134 LV= 1 RT1
*MCALL #=   135 LV= 1          RT1   CCE,=2C'1',=2X'31',2
         DS    0H
         LA    1,=2C'1'
         LA    2,=2X'31'
         CLC   0(2,1),0(2)
RT1_TEST126      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE126
         LTORG 
RT1_CCE126      DS 0H
*MEXIT #=   135 LV= 1 RT1
*MCALL #=   136 LV= 1          RT1   CCE,=2Z'1',=2X'C1',2  RPI-777
         DS    0H
         LA    1,=2Z'1'
         LA    2,=2X'C1'
         CLC   0(2,1),0(2)
RT1_TEST127      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE127
         LTORG 
RT1_CCE127      DS 0H
*MEXIT #=   136 LV= 1 RT1
* TEST 2E,2D,2L, AND 2FD
*MCALL #=   137 LV= 1          RT1   CCE,=XL8'00',TE
         DS    0H
         CLC   =XL8'00',TE
RT1_TEST128      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE128
         LTORG 
RT1_CCE128      DS 0H
*MEXIT #=   137 LV= 1 RT1
*MCALL #=   138 LV= 1          RT1   CCE,=XL16'00',TD
         DS    0H
         CLC   =XL16'00',TD
RT1_TEST129      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE129
         LTORG 
RT1_CCE129      DS 0H
*MEXIT #=   138 LV= 1 RT1
*MCALL #=   139 LV= 1          RT1   CCE,=XL32'00',TL
         DS    0H
         CLC   =XL32'00',TL
RT1_TEST130      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE130
         LTORG 
RT1_CCE130      DS 0H
*MEXIT #=   139 LV= 1 RT1
*MCALL #=   140 LV= 1          RT1   CCE,=XL16'00',TFD
         DS    0H
         CLC   =XL16'00',TFD
RT1_TEST131      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE131
         LTORG 
RT1_CCE131      DS 0H
*MEXIT #=   140 LV= 1 RT1
*MCALL #=   141 LV= 1          RT1   CCE,=XL8'00',TF
         DS    0H
         CLC   =XL8'00',TF
RT1_TEST132      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE132
         LTORG 
RT1_CCE132      DS 0H
*MEXIT #=   141 LV= 1 RT1
*MCALL #=   142 LV= 1          RT1   CCE,=A(TD-TE),=F'8'
         DS    0H
         CLC   =A(TD-TE),=F'8'
RT1_TEST133      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE133
         LTORG 
RT1_CCE133      DS 0H
*MEXIT #=   142 LV= 1 RT1
*MCALL #=   143 LV= 1          RT1   CCE,=A(TL-TD),=F'16'
         DS    0H
         CLC   =A(TL-TD),=F'16'
RT1_TEST134      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE134
         LTORG 
RT1_CCE134      DS 0H
*MEXIT #=   143 LV= 1 RT1
*MCALL #=   144 LV= 1          RT1   CCE,=A(TFD-TL),=F'32'
         DS    0H
         CLC   =A(TFD-TL),=F'32'
RT1_TEST135      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE135
         LTORG 
RT1_CCE135      DS 0H
*MEXIT #=   144 LV= 1 RT1
*MCALL #=   145 LV= 1          RT1   CCE,=A(TF-TFD),=F'16'
         DS    0H
         CLC   =A(TF-TFD),=F'16'
RT1_TEST136      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE136
         LTORG 
RT1_CCE136      DS 0H
*MEXIT #=   145 LV= 1 RT1
*MCALL #=   146 LV= 1          RT1   CCE,=A(TFE-TF),=F'8'
         DS    0H
         CLC   =A(TFE-TF),=F'8'
RT1_TEST137      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE137
         LTORG 
RT1_CCE137      DS 0H
*MEXIT #=   146 LV= 1 RT1
*MCALL #=   147 LV= 1          RT1   CCE,=XL8'00',TES
         DS    0H
         CLC   =XL8'00',TES
RT1_TEST138      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE138
         LTORG 
RT1_CCE138      DS 0H
*MEXIT #=   147 LV= 1 RT1
*MCALL #=   148 LV= 1          RT1   CCE,=XL16'00',TDS
         DS    0H
         CLC   =XL16'00',TDS
RT1_TEST139      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE139
         LTORG 
RT1_CCE139      DS 0H
*MEXIT #=   148 LV= 1 RT1
*MCALL #=   149 LV= 1          RT1   CCE,=XL32'00',TLS
         DS    0H
         CLC   =XL32'00',TLS
RT1_TEST140      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE140
         LTORG 
RT1_CCE140      DS 0H
*MEXIT #=   149 LV= 1 RT1
*MCALL #=   150 LV= 1          RT1   CCE,=XL16'00',TFDS
         DS    0H
         CLC   =XL16'00',TFDS
RT1_TEST141      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE141
         LTORG 
RT1_CCE141      DS 0H
*MEXIT #=   150 LV= 1 RT1
*MCALL #=   151 LV= 1          RT1   CCE,=XL8'00',TFS
         DS    0H
         CLC   =XL8'00',TFS
RT1_TEST142      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE142
         LTORG 
RT1_CCE142      DS 0H
*MEXIT #=   151 LV= 1 RT1
*MCALL #=   152 LV= 1          RT1   CCE,=A(TDS-TES),=F'8'
         DS    0H
         CLC   =A(TDS-TES),=F'8'
RT1_TEST143      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE143
         LTORG 
RT1_CCE143      DS 0H
*MEXIT #=   152 LV= 1 RT1
*MCALL #=   153 LV= 1          RT1   CCE,=A(TLS-TDS),=F'16'
         DS    0H
         CLC   =A(TLS-TDS),=F'16'
RT1_TEST144      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE144
         LTORG 
RT1_CCE144      DS 0H
*MEXIT #=   153 LV= 1 RT1
*MCALL #=   154 LV= 1          RT1   CCE,=A(TFDS-TLS),=F'32'
         DS    0H
         CLC   =A(TFDS-TLS),=F'32'
RT1_TEST145      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE145
         LTORG 
RT1_CCE145      DS 0H
*MEXIT #=   154 LV= 1 RT1
*MCALL #=   155 LV= 1          RT1   CCE,=A(TFS-TFDS),=F'16'
         DS    0H
         CLC   =A(TFS-TFDS),=F'16'
RT1_TEST146      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE146
         LTORG 
RT1_CCE146      DS 0H
*MEXIT #=   155 LV= 1 RT1
*MCALL #=   156 LV= 1          RT1   CCE,=A(TFSE-TFS),=F'8'
         DS    0H
         CLC   =A(TFSE-TFS),=F'8'
RT1_TEST147      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE147
         LTORG 
RT1_CCE147      DS 0H
*MEXIT #=   156 LV= 1 RT1
* TEST ALL DUP FACTORS
*MCALL #=   157 LV= 1          RT1   CCE,=2A(1),=2XL4'1',8
         DS    0H
         LA    1,=2A(1)
         LA    2,=2XL4'1'
         CLC   0(8,1),0(2)
RT1_TEST148      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE148
         LTORG 
RT1_CCE148      DS 0H
*MEXIT #=   157 LV= 1 RT1
*MCALL #=   158 LV= 1          RT1   CCE,=2D'0',=16X'00',16
         DS    0H
         LA    1,=2D'0'
         LA    2,=16X'00'
         CLC   0(16,1),0(2)
RT1_TEST149      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE149
         LTORG 
RT1_CCE149      DS 0H
*MEXIT #=   158 LV= 1 RT1
*MCALL #=   159 LV= 1          RT1   CCE,=2E'0',=8X'00',8
         DS    0H
         LA    1,=2E'0'
         LA    2,=8X'00'
         CLC   0(8,1),0(2)
RT1_TEST150      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE150
         LTORG 
RT1_CCE150      DS 0H
*MEXIT #=   159 LV= 1 RT1
*MCALL #=   160 LV= 1          RT1   CCE,=2F'1',=2XL4'1',8
         DS    0H
         LA    1,=2F'1'
         LA    2,=2XL4'1'
         CLC   0(8,1),0(2)
RT1_TEST151      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE151
         LTORG 
RT1_CCE151      DS 0H
*MEXIT #=   160 LV= 1 RT1
*MCALL #=   161 LV= 1          RT1   CCE,=2H'1',=2XL2'1',4
         DS    0H
         LA    1,=2H'1'
         LA    2,=2XL2'1'
         CLC   0(4,1),0(2)
RT1_TEST152      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE152
         LTORG 
RT1_CCE152      DS 0H
*MEXIT #=   161 LV= 1 RT1
*MCALL #=   162 LV= 1          RT1   CCE,=2L'0',=32X'00',32
         DS    0H
         LA    1,=2L'0'
         LA    2,=32X'00'
         CLC   0(32,1),0(2)
RT1_TEST153      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE153
         LTORG 
RT1_CCE153      DS 0H
*MEXIT #=   162 LV= 1 RT1
*MCALL #=   163 LV= 1          RT1   CCE,=2PL3'0',=6X'00000C00000C',6
         DS    0H
         LA    1,=2PL3'0'
         LA    2,=6X'00000C00000C'
         CLC   0(6,1),0(2)
RT1_TEST154      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE154
         LTORG 
RT1_CCE154      DS 0H
*MEXIT #=   163 LV= 1 RT1
*MCALL #=   164 LV= 1          RT1   CCE,=2S(1),=2XL2'1',4
         DS    0H
         LA    1,=2S(1)
         LA    2,=2XL2'1'
         CLC   0(4,1),0(2)
RT1_TEST155      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE155
         LTORG 
RT1_CCE155      DS 0H
*MEXIT #=   164 LV= 1 RT1
* TEST LQ HEX QUAD WORD
*MCALL #=   165 LV= 1          RT1   CCE,=LQ'1',=L'1',16
         DS    0H
         LA    1,=LQ'1'
         LA    2,=L'1'
         CLC   0(16,1),0(2)
RT1_TEST156      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE156
         LTORG 
RT1_CCE156      DS 0H
*MEXIT #=   165 LV= 1 RT1
* TEST CCW, CCW0, AND CCW1
*MCALL #=   166 LV= 1          RT1   CCE,CCW,CCWV,8
         DS    0H
         LA    1,CCW
         LA    2,CCWV
         CLC   0(8,1),0(2)
RT1_TEST157      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE157
         LTORG 
RT1_CCE157      DS 0H
*MEXIT #=   166 LV= 1 RT1
*MCALL #=   167 LV= 1          RT1   CCE,CCW0,CCW0V,8
         DS    0H
         LA    1,CCW0
         LA    2,CCW0V
         CLC   0(8,1),0(2)
RT1_TEST158      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE158
         LTORG 
RT1_CCE158      DS 0H
*MEXIT #=   167 LV= 1 RT1
*MCALL #=   168 LV= 1          RT1   CCE,CCW1,CCW1V,8
         DS    0H
         LA    1,CCW1
         LA    2,CCW1V
         CLC   0(8,1),0(2)
RT1_TEST159      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE159
         LTORG 
RT1_CCE159      DS 0H
*MEXIT #=   168 LV= 1 RT1
* TEST IGNORE SPACES IN P AND Z DATA FIELDS RPI-840
*MCALL #=   169 LV= 1          RT1   CCE,=P'1',=P' 1'
         DS    0H
         CLC   =P'1',=P' 1'
RT1_TEST160      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE160
         LTORG 
RT1_CCE160      DS 0H
*MEXIT #=   169 LV= 1 RT1
*MCALL #=   170 LV= 1          RT1   CCE,=P'1',=P'1 '
         DS    0H
         CLC   =P'1',=P'1 '
RT1_TEST161      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE161
         LTORG 
RT1_CCE161      DS 0H
*MEXIT #=   170 LV= 1 RT1
*MCALL #=   171 LV= 1          RT1   CCE,=P'1',=P' 1 '
         DS    0H
         CLC   =P'1',=P' 1 '
RT1_TEST162      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE162
         LTORG 
RT1_CCE162      DS 0H
*MEXIT #=   171 LV= 1 RT1
*MCALL #=   172 LV= 1          RT1   CCE,=Z'1',=Z' 1'
         DS    0H
         CLC   =Z'1',=Z' 1'
RT1_TEST163      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE163
         LTORG 
RT1_CCE163      DS 0H
*MEXIT #=   172 LV= 1 RT1
*MCALL #=   173 LV= 1          RT1   CCE,=Z'1',=Z'1 '
         DS    0H
         CLC   =Z'1',=Z'1 '
RT1_TEST164      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE164
         LTORG 
RT1_CCE164      DS 0H
*MEXIT #=   173 LV= 1 RT1
*MCALL #=   174 LV= 1          RT1   CCE,=Z'1',=Z' 1 '
         DS    0H
         CLC   =Z'1',=Z' 1 '
RT1_TEST165      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE165
         LTORG 
RT1_CCE165      DS 0H
*MEXIT #=   174 LV= 1 RT1
* TEST SY RPI-893
*MCALL #=   175 LV= 1          RT1   CCE,=SY(TESTDC1+8+4096),=SY(X'1000X
               '(13))
         DS    0H
         CLC   =SY(TESTDC1+8+4096),=SY(X'1000'(13))
RT1_TEST166      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE166
         LTORG 
RT1_CCE166      DS 0H
*MEXIT #=   175 LV= 1 RT1
*MCALL #=   176 LV= 1          RT1   CCE,=F'U4294967295',=X'FFFFFFFF'
         DS    0H
         CLC   =F'U4294967295',=X'FFFFFFFF'
RT1_TEST167      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE167
         LTORG 
RT1_CCE167      DS 0H
*MEXIT #=   176 LV= 1 RT1
*MCALL #=   177 LV= 1          RT1   CCE,=H'U65535',=X'FFFF'
         DS    0H
         CLC   =H'U65535',=X'FFFF'
RT1_TEST168      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE168
         LTORG 
RT1_CCE168      DS 0H
*MEXIT #=   177 LV= 1 RT1
* TEST AFHY OVERFLOW RPI-1101 OVERFLOW WITH NO ERRORS
*MCALL #=   178 LV= 1          RT1   CCE,=H'32767',=X'7FFF'
         DS    0H
         CLC   =H'32767',=X'7FFF'
RT1_TEST169      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE169
         LTORG 
RT1_CCE169      DS 0H
*MEXIT #=   178 LV= 1 RT1
*MCALL #=   179 LV= 1          RT1   CCE,=H'32768',=X'8000'
         DS    0H
         CLC   =H'32768',=X'8000'
RT1_TEST170      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE170
         LTORG 
RT1_CCE170      DS 0H
*MEXIT #=   179 LV= 1 RT1
*MCALL #=   180 LV= 1          RT1   CCE,=H'32769',=X'8001'
         DS    0H
         CLC   =H'32769',=X'8001'
RT1_TEST171      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE171
         LTORG 
RT1_CCE171      DS 0H
*MEXIT #=   180 LV= 1 RT1
*MCALL #=   181 LV= 1          RT1   CCE,=F'2147483647',=X'7FFFFFFF'
         DS    0H
         CLC   =F'2147483647',=X'7FFFFFFF'
RT1_TEST172      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE172
         LTORG 
RT1_CCE172      DS 0H
*MEXIT #=   181 LV= 1 RT1
*MCALL #=   182 LV= 1          RT1   CCE,=F'2147483648',=X'80000000'
         DS    0H
         CLC   =F'2147483648',=X'80000000'
RT1_TEST173      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE173
         LTORG 
RT1_CCE173      DS 0H
*MEXIT #=   182 LV= 1 RT1
*MCALL #=   183 LV= 1          RT1   CCE,=F'2147483649',=X'80000001'
         DS    0H
         CLC   =F'2147483649',=X'80000001'
RT1_TEST174      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE174
         LTORG 
RT1_CCE174      DS 0H
*MEXIT #=   183 LV= 1 RT1
*MCALL #=   184 LV= 1          RT1   CCE,=Y(32767),=X'7FFF'
         DS    0H
         CLC   =Y(32767),=X'7FFF'
RT1_TEST175      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE175
         LTORG 
RT1_CCE175      DS 0H
*MEXIT #=   184 LV= 1 RT1
*MCALL #=   185 LV= 1          RT1   CCE,=Y(32768),=X'8000'
         DS    0H
         CLC   =Y(32768),=X'8000'
RT1_TEST176      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE176
         LTORG 
RT1_CCE176      DS 0H
*MEXIT #=   185 LV= 1 RT1
*MCALL #=   186 LV= 1          RT1   CCE,=Y(32769),=X'8001'
         DS    0H
         CLC   =Y(32769),=X'8001'
RT1_TEST177      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE177
         LTORG 
RT1_CCE177      DS 0H
*MEXIT #=   186 LV= 1 RT1
*MCALL #=   187 LV= 1          RT1   CCE,=A(2147483647),=X'7FFFFFFF'
         DS    0H
         CLC   =A(2147483647),=X'7FFFFFFF'
RT1_TEST178      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE178
         LTORG 
RT1_CCE178      DS 0H
*MEXIT #=   187 LV= 1 RT1
*MCALL #=   188 LV= 1          RT1   CCE,=A(2147483648),=X'80000000'
         DS    0H
         CLC   =A(2147483648),=X'80000000'
RT1_TEST179      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE179
         LTORG 
RT1_CCE179      DS 0H
*MEXIT #=   188 LV= 1 RT1
*MCALL #=   189 LV= 1          RT1   CCE,=A(2147483649),=X'80000001'
         DS    0H
         CLC   =A(2147483649),=X'80000001'
RT1_TEST180      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE180
         LTORG 
RT1_CCE180      DS 0H
*MEXIT #=   189 LV= 1 RT1
*MCALL #=   190 LV= 1          RT1   CCE,=A(2147483647),=X'7FFFFFFF'
         DS    0H
         CLC   =A(2147483647),=X'7FFFFFFF'
RT1_TEST181      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE181
         LTORG 
RT1_CCE181      DS 0H
*MEXIT #=   190 LV= 1 RT1
*MCALL #=   191 LV= 1          RT1   CCE,=C'7FFFFFFF',=C'7FFFFFFF'
         DS    0H
         CLC   =C'7FFFFFFF',=C'7FFFFFFF'
RT1_TEST182      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE182
         LTORG 
RT1_CCE182      DS 0H
*MEXIT #=   191 LV= 1 RT1
*MCALL #=   192 LV= 1          RT1   CCE,=A(2147483648),=X'80000000'   X
                  TEST SETA OVERFLOW
         DS    0H
         CLC   =A(2147483648),=X'80000000'
RT1_TEST183      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE183
         LTORG 
RT1_CCE183      DS 0H
*MEXIT #=   192 LV= 1 RT1
*MCALL #=   193 LV= 1          RT1   CCE,=C'80000000',=C'80000000'
         DS    0H
         CLC   =C'80000000',=C'80000000'
RT1_TEST184      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE184
         LTORG 
RT1_CCE184      DS 0H
*MEXIT #=   193 LV= 1 RT1
*MCALL #=   194 LV= 1          RT1   CCE,=A(2147483649),=X'80000001'
         DS    0H
         CLC   =A(2147483649),=X'80000001'
RT1_TEST185      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE185
         LTORG 
RT1_CCE185      DS 0H
*MEXIT #=   194 LV= 1 RT1
*MCALL #=   195 LV= 1          RT1   CCE,=C'80000001',=C'80000001'
         DS    0H
         CLC   =C'80000001',=C'80000001'
RT1_TEST186      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE186
         LTORG 
RT1_CCE186      DS 0H
*MEXIT #=   195 LV= 1 RT1
*MCALL #=   196 LV= 1          RT1   CCE,=A(0),=A(0)              TEST X
               SETA DIVIDE BY 0
         DS    0H
         CLC   =A(0),=A(0)
RT1_TEST187      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE187
         LTORG 
RT1_CCE187      DS 0H
*MEXIT #=   196 LV= 1 RT1
*MCALL #=   197 LV= 1          RT1   CCE,=C'3132333435',=C'3132333435'
         DS    0H
         CLC   =C'3132333435',=C'3132333435'
RT1_TEST188      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE188
         LTORG 
RT1_CCE188      DS 0H
*MEXIT #=   197 LV= 1 RT1
*MCALL #=   198 LV= 1          RT1   END
         B      RT1_END
*MEXIT #=   198 LV= 1 RT1
         END 
