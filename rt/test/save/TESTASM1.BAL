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
* 2005-10-03 DSH RPI-9   Test length operator in INS and DC         *
* 2005-11-13 DSH RPI-87  Test ORG preceded by ABS value CALC        *
* 2005-11-13 DSH RPI-90  Test single character B,C,X symbols        *
* 2006-01-13 DSH RPI-171 Test unary operators                       *
* 2006-03-16 DSH RPI-230 Test COM, RSECT, START limited support     *
* 2006-03-17 DSH RPI-228 Test CVTDCB macro OS flag indicating       *
*                        31 bit and MVS+                            *
* 2006-03-21 DSH RPI-258 Test ORG , delimiter                       *
* 2006-04-12 DSH RPI-278 Test PUSH, POP NOPRINT                     *
* 2006-04-24 DSH RPI-291 Test ENQ/DEQ macros                        *
* 2006-04-28 DSH RPI-304 Test PRINT DATA,NOPRINT                    *
* 2006-05-12 DSH RPI-313 Add unary op test and L'OP in continued    *
*                        statement test                             *
* 2006-07-03 DSH RPI-342 Test operands with L' operators            *
* 2006-07-19 DSH RPI-365 Test literal as target of L'               *
* 2006-07-19 DSH RPI-369 Test ignoring 4th and 5th EQU parameters   *
* 2006-08-27 DSH RPI-415 Correct value of EQU 5th parameter         *
* 2006-09-26 DSH RPI-465 Test using R0 for PSA type DSECT           *
* 2006-11-09 DSH RPI-489 Test B macro LAB, entry FWD reference      *
* 2006-11-12 DSH RPI-492 Test blank continuation lines              *
* 2006-11-12 DSH RPI-493 Test OPSYN with no operands and IPK with   *
*                        no comma                                   *
* 2006-11-12 DSH RPI-494 Test DS BIT LENGTH SUPPORT FOR LAST FIELD  *
* 2006-11-28 DSH RPI-501 Test literal-ABS expression                *
* 2007-08-22 DSH RPI-673 Test drop with expression 1+1 etc.         *
* 2007-11-30 DSH RPI-743 Test comment on prototype , CNOP ATTR I,   *
*                        PUNCH CMTS                                 *
* 2007-11-30 DSH RPI-745 Test AREAD skip NOPRINT, NOSTMT, SUPPORT   *
*                        CLOCKB/D                                   *
* 2008-04-23 DSH RPI-835 Test * in SETC LABEL VAR created comment   *
* 2008-10-27 DSH RPI-929 Test * in SETC LABEL VAR created comment   *
*********************************************************************
         TITLE 'TESTASM1 - MISC ASSEMBLER TESTS'
         START , RPI-230 TEST START CSECT
         USING *,R15
         PUSH  USING,NOPRINT
         POP   USING,NOPRINT
         PRINT DATA,NOPRINT
         L     R15,=A(TESTASM1)
         BR    R15
         DROP  R15
         LTORG 
*MCALL #=     1 LV= 1 TESTASM1 RT1   MAIN
*MCALL #=     2 LV= 2 TESTASM1 SUBENTRY 
TESTASM1 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTASM1'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTASM1+8,13
*MEXIT #=     2 LV= 2 SUBENTRY
*MCALL #=     3 LV= 2          WTO   'TESTASM1 RT1 STARTED'
         BRAS  1,*+(WTO#0003_EOT-*+1)/2*2
         DC    AL2(WTO#0003_EOT-*,0),C'TESTASM1 RT1 STARTED'
WTO#0003_EOT     EQU *
         SVC   35
*MEXIT #=     3 LV= 2 WTO
         BRCL    15,RT1_START
RT1_ABORT DS 0H
         MVI   RT1_ABORTED,C'T'
*MCALL #=     4 LV= 2          WTO   'TESTASM1 RT1 TESTING ABORTED'
         BRAS  1,*+(WTO#0004_EOT-*+1)/2*2
         DC    AL2(WTO#0004_EOT-*,0),C'TESTASM1 RT1 TESTING ABORTED'
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
*MCALL #=     6 LV= 2          WTO   'TESTASM1 RT1 ENDED OK'
         BRAS  1,*+(WTO#0006_EOT-*+1)/2*2
         DC    AL2(WTO#0006_EOT-*,0),C'TESTASM1 RT1 ENDED OK'
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
RT1_WTO1 DC    AL2(RT1_WTO_END-*,0),C'TESTASM1 RT1 TESTS COMPLETED = '
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
F1       DC    A(0)
F2       DC    A(L'X2)
A        DC    C'ABC'
         ORG   A
         DC    C'12'
         ORG 
         DC    C'D'
* TEST ORG AFTER ABS
RPI87    DC    C'ABCD'
ABS1     EQU   0
         ORG   RPI87+1
         DC    C'XX'
ABS2     EQU   0
         ORG 
* TEST ORG COMMA DELIMITER
         ORG    *-16   BACKUP  16
         ORG    ,      FORWARD 16 AGAIN
* TEST B,C,X SYMBOLS
B        DC    C'B'
C        DC    C'C'
X        DC    C'X'
X3       DS    0CL10
Y3       DC    CL2'12'
         DC    CL8'34567890'
TRFIELD  DC    X'F0F1F2F3F4F5F6F7F8F9FAFBFCFDFEFF'
*MCALL #=    10 LV= 1          RT1   START
RT1_START DS  0H
*MEXIT #=    10 LV= 1 RT1
* TEST ALIGNMENT OPERATOR
         CNOP  0,4
         CNOP  2,4
         CNOP  0,4
         CNOP  0,8
         CNOP  6,8
         CNOP  4,8
         CNOP  2,8
         CNOP  0,8
* TEST LENGTH OPERATOR
X2       MVC   F1(L'F2),F2
*MCALL #=    11 LV= 1          RT1   CCE,F1,=A(6)
         DS    0H
         CLC   F1,=A(6)
RT1_TEST1        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1
         LTORG 
RT1_CCE1        DS 0H
*MEXIT #=    11 LV= 1 RT1
* TEST ORG VALUE AFTER OVERLAY
         CLC   A(4),=C'12CD'
*MCALL #=    12 LV= 1          RT1   CCE
         DS    0H
RT1_TEST2        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE2
         LTORG 
RT1_CCE2        DS 0H
*MEXIT #=    12 LV= 1 RT1
* TEST ORG AFTER ABS VALUE CALC FOR RPI87
         CLC   RPI87(4),=C'AXXD'
*MCALL #=    13 LV= 1          RT1   CCE
         DS    0H
RT1_TEST3        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE3
         LTORG 
RT1_CCE3        DS 0H
*MEXIT #=    13 LV= 1 RT1
* TEST B,C,X SYMBOLS FOR RPI90
         CLI   B,C'B'
*MCALL #=    14 LV= 1          RT1   CCE
         DS    0H
RT1_TEST4        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE4
         LTORG 
RT1_CCE4        DS 0H
*MEXIT #=    14 LV= 1 RT1
         CLI   C,C'C'
*MCALL #=    15 LV= 1          RT1   CCE
         DS    0H
RT1_TEST5        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE5
         LTORG 
RT1_CCE5        DS 0H
*MEXIT #=    15 LV= 1 RT1
         CLI   X,C'X'
*MCALL #=    16 LV= 1          RT1   CCE
         DS    0H
RT1_TEST6        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE6
         LTORG 
RT1_CCE6        DS 0H
*MEXIT #=    16 LV= 1 RT1
* TEST UNARY OPERATORS
         CLC   =A(-1),=A(1-2)
*MCALL #=    17 LV= 1          RT1   CCE
         DS    0H
RT1_TEST7        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE7
         LTORG 
RT1_CCE7        DS 0H
*MEXIT #=    17 LV= 1 RT1
         CLC   =A(--1),=A(1)
*MCALL #=    18 LV= 1          RT1   CCE
         DS    0H
RT1_TEST8        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE8
         LTORG 
RT1_CCE8        DS 0H
*MEXIT #=    18 LV= 1 RT1
         CLC   =A(-1*-1),=A(1)
*MCALL #=    19 LV= 1          RT1   CCE
         DS    0H
RT1_TEST9        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE9
         LTORG 
RT1_CCE9        DS 0H
*MEXIT #=    19 LV= 1 RT1
         CLC   =A(-1*(-1+2)),=A(1-2)
*MCALL #=    20 LV= 1          RT1   CCE
         DS    0H
RT1_TEST10       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE10
         LTORG 
RT1_CCE10       DS 0H
*MEXIT #=    20 LV= 1 RT1
         CLC   =A(+1*+1),=A(1)
*MCALL #=    21 LV= 1          RT1   CCE
         DS    0H
RT1_TEST11       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE11
         LTORG 
RT1_CCE11       DS 0H
*MEXIT #=    21 LV= 1 RT1
         CLC   =A(+1*(+1+2)),=A(3)
*MCALL #=    22 LV= 1          RT1   CCE
         DS    0H
RT1_TEST12       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE12
         LTORG 
RT1_CCE12       DS 0H
*MEXIT #=    22 LV= 1 RT1
         CLC   =A(-(2-1)),=A(-1)     RPI-313
*MCALL #=    23 LV= 1          RT1   CCE
         DS    0H
RT1_TEST13       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE13
         LTORG 
RT1_CCE13       DS 0H
*MEXIT #=    23 LV= 1 RT1
* TEST L' IN OPERANDS
         MACRO
         TEST  &A,&B
         MVC   &A(1).(&A(2)),&B
         MEND
*MCALL #=    24 LV= 1          TEST  (X3+L'Y3,L'X3-L'Y3),=8C'X'
         MVC   X3+L'Y3(L'X3-L'Y3),=8C'X'
*MEXIT #=    24 LV= 1 TEST
*MCALL #=    25 LV= 1          RT1   CCE,X3,=C'12XXXXXXXX'
         DS    0H
         CLC   X3,=C'12XXXXXXXX'
RT1_TEST14       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE14
         LTORG 
RT1_CCE14       DS 0H
*MEXIT #=    25 LV= 1 RT1
         LA    L'X,2
         CL    1,=A(2)
*MCALL #=    26 LV= 1          RT1   CCE
         DS    0H
RT1_TEST15       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE15
         LTORG 
RT1_CCE15       DS 0H
*MEXIT #=    26 LV= 1 RT1
         L     R1,=A(MYCOM)
*MCALL #=    27 LV= 1          CALL  MYRSECT
*MCALL #=    28 LV= 2          ZCALL MYRSECT,,,ID=,LINKINST=BALR,MF=I
         CNOP  0,4
         LRL    15,=V(MYRSECT)
         BALR      14,15
*MEXIT #=    28 LV= 2 ZCALL
*MEXIT #=    27 LV= 1 CALL
* TEST L'=CL3'ABC'
         CLI   =AL1(3),L'=C'ABC'
*MCALL #=    29 LV= 1          RT1   CCE
         DS    0H
RT1_TEST16       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE16
         LTORG 
RT1_CCE16       DS 0H
*MEXIT #=    29 LV= 1 RT1
* TEST EQU IGNORE 4TH AND 5TH
x1       EQU   1,2,3,4,gr
         CLI   =AL1(1),X1
*MCALL #=    30 LV= 1          RT1   CCE
         DS    0H
RT1_TEST17       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE17
         LTORG 
RT1_CCE17       DS 0H
*MEXIT #=    30 LV= 1 RT1
* IGNORE ACONTROL AND ALIAS
         ACONTROL 
         ALIAS 
* TEST USING R0 FOR PSA TYPE DSECT
         USING PSA,0
         LA    1,OLDPSW
         CLC   1,=A(OLDPSW-PSA)
*MCALL #=    31 LV= 1          RT1   CCE
         DS    0H
RT1_TEST18       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE18
         LTORG 
RT1_CCE18       DS 0H
*MEXIT #=    31 LV= 1 RT1
* TEST ENTRY TO FWD REF MAC LABEL
         ENTRY TESTENT
*MCALL #=    32 LV= 1 TESTENT  WTO   'ENTRY TESTEND TEST'
TESTENT  DS    0H
         BRAS  1,*+(WTO#0032_EOT-*+1)/2*2
         DC    AL2(WTO#0032_EOT-*,0),C'ENTRY TESTEND TEST'
WTO#0032_EOT     EQU *
         SVC   35
*MEXIT #=    32 LV= 1 WTO
*MCALL #=    33 LV= 1          WTO   'TEST BLANK CONTINUATION'         X
                                     
         BRAS  1,*+(WTO#0033_EOT-*+1)/2*2
         DC    AL2(WTO#0033_EOT-*,0),C'TEST BLANK CONTINUATION'
WTO#0033_EOT     EQU *
         SVC   35
*MEXIT #=    33 LV= 1 WTO
* TEST IPK OPSYN WITH NO OPERANDS AND IPK WITH NO OPERANDS OR COMMA
         B     SKIP_IPK
_IPK     OPSYN IPK
         _IPK 
         IPK 
SKIP_IPK EQU   *
* TEST BIT LENGTH DS LAST FIELD SUPPORT
         CLC   =AL1(L'B15),=AL1(2)
*MCALL #=    34 LV= 1          RT1   CCE
         DS    0H
RT1_TEST19       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE19
         LTORG 
RT1_CCE19       DS 0H
*MEXIT #=    34 LV= 1 RT1
* TEST LITERAL = ABS EXP.
         TR    TRFIELD,=C'0123456789ABCDEF'-X'F0'
         CLC   TRFIELD,=C'0123456789ABCDEF'
*MCALL #=    35 LV= 1          RT1   CCE
         DS    0H
RT1_TEST20       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE20
         LTORG 
RT1_CCE20       DS 0H
*MEXIT #=    35 LV= 1 RT1
* TEST DROP WITH EXPRESSION
         USING *,15
         USING X4,2
         LA    1,X4
         DROP  1+1
         LA    1,X4
         USING X4,2
         DROP  1+1,15
* RPI-743 test CNOP LABEL ATTR I
CNOPLAB  CNOP  0,4
         MNOTE 'CNOP TYPE I OK'
* RPI-743 test comment on prototype after last keyword parm
*MCALL #=    36 LV= 1          TESTASM1 
         MNOTE 'TESTMAC1 WITH TESTMACX PROTOTYPE OK'
*MEXIT #=    36 LV= 1 TESTASM1
         PUNCH ' PHASE SECTEXIT,*                                      X
                                        '  *BX
* RPI-743 test PUNCH with following comments
         PUNCH ' PHASE SECTEXIT,*                                      X
                                        '  *BX
* RPI-745 test AREAD with CLOCKB and CLOCKD
         MNOTE 'CLOCKB=08122456 HH=22 MM=33 SS=44 TH=56'
         MNOTE 'CLOCKD=22334456'
* RPI-835 * IN LABEL VAR CREATES COMMENT
* THIS IS TEST FOR RPI-835  
* RPI-929 * IN LABEL VAR CREATES COMMENT REGUARDLESS OF OPCODE
* SETC COMMENT 1  
* EQU  COMMENT 2  
*
* END OF TESTS
*
*MCALL #=    37 LV= 1          WTO   'TEST1 ENDED OK'
         BRAS  1,*+(WTO#0037_EOT-*+1)/2*2
         DC    AL2(WTO#0037_EOT-*,0),C'TEST1 ENDED OK'
WTO#0037_EOT     EQU *
         SVC   35
*MEXIT #=    37 LV= 1 WTO
*MCALL #=    38 LV= 1          RT1   END
         B      RT1_END
*MEXIT #=    38 LV= 1 RT1
         LTORG 
X4       DS    X
MYCOM    COM   , RPI-230 TEST COM SECTION (NO LINKER SUPPORT YET)
MYCOM1   DC    F'123'
MYCOM2   DC    F'456'
MYRSECT  RSECT , RPI-230 TEST RSECT (NO WARNINGS YET)
         USING *,R15
         CLC   0(8,R1),=F'123,456'
         BNE   1
         L     R1,16
         USING IHACVT,R1
         CLI   CVTDCB,X'9B'  VERIFY X'80' 31 BIT AND X'13' MVS+ SUPPORT
         BNE   1
*MCALL #=    39 LV= 1          ENQ   (QN,RN)
*MEXIT #=    39 LV= 1 ENQ
*MCALL #=    40 LV= 1          DEQ   (QN,RN)
*MEXIT #=    40 LV= 1 DEQ
         BR    14
QN       DC    CL8'IEAXXXXX'
RN       DC    CL8'STEPNAME'
         LTORG 
*MCALL #=    41 LV= 1          CVTD 
IHACVT   DSECT 
         ORG    IHACVT+X'38'
CVTDATE  DS     PL4   IPL DATE SET BY IPL(TESTIPL1)
         ORG    IHACVT+X'74'
CVTDCB   DS     X     OS FLAGS X'80' = 31 BITS, X'13' = MVS+
         ORG    IHACVT+200
CVTABEND DS     A     SECONDARY CVT  (ZERO FOR NOW)
CVTUSER  DS     A     USER POINTER
CVTCDE   DS     A     ADDRESS FIRST CDE FOR Z390 RPI 1063
*MEXIT #=    41 LV= 1 CVTD
PSA      DSECT 
         ORG   PSA+X'20'
OLDPSW   DS    XL8
B15      DS    BL.015   2 BYTES
         END 
