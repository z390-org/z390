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
* Remark - Test DFP (decimal floating point)                        *
*********************************************************************
* 2006-12-09 DSH         Initial version                            *
* 2006-12-09 DSH RPI-407 Add ADTR, SDTR, MDTR, DDTR, CDTR, CSDTR    *
* 2006-12-15 DSH RPI-518 Add AXTR, SXTR, MXTR, DXTR                 *
* 2006-12-18 DSH RPI-406 Add remaining DFP instructions             *
*            KDTR,  KXTR,  CEDTR, CEXTR, CDGTR, CXGTR, CDSTR, CXSTR *
*            CDUTR, CXUTR, CGDTR, CGXTR, CUDTR, CUXTR, ESDTR, ESXTR *
*            IEDTR, IEXTR, FIDTR, FIXTR                             *
*            SRNMT, SFASR, LFAS                                     *
*            LDETR, LXDTR, LEDTR, LDXTR, QADTR, QAXTR, RRDTR, RRXTR *
*            SLDT,  SLXT   SRDT,  SRXT                              *
*            TDCDT, TDCET, TDCXT, TDGDT, TDGET, TDGXT               *
* 2006-12-29 DSH RPI-527 Add missing DFP instructions               *
*                        LPDFR, LNDFR, CPSDR, LCDFR, LDGR, LGDR     *
* 2007-01-08 DSH RPI-527 Correct CGDTR, CGXTR rounding              *
* 2007-01-10 DSH RPI-533 Correct CGDTR, CGXTR rounding              *
* 2008-01-12 DSH RPI-786 Change bias BAASED on new canonization     *
* 2008-01-13 DSH RPI-786 Use FP compares to handle equivalent DFP   *
*                        values                                     *
* 2008-01-17 DSH RPI-790 Correct test for expected bias based on    *
*                        DFP constants                              *
* 2008-01-22 DSH RPI-791 Test CGDTR and CGXTR setting CC3 if too big*
* 2008-02-27 DSH RPI-811 Test the following fixes                   *
*                        CSDTR fix for high digit 0 if negative     *
*                        SRDT/SLDT/SRXT/SLXT incorrect for EXP > 0  *
* 2008-03-13 DSH RPI-820 Test IEEE DIV,OVF,UNF exception handling   *
* 2008-06-20 DSH RPI-845 Change EPIED to IHAEPIE                    *
*********************************************************************
         MACRO
&N       CLCED &S1,&S2
&N       LE    F0,&S1
         LDETR F0,F0,0
         LE    F1,&S2
         LDETR F1,F1,0
         CDTR  F0,R1
         MEND
         MACRO
&N       CLCDD &S1,&S2
&N       LD    F0,&S1
         LD    F1,&S2
         CDTR  F0,F1
         MEND
         MACRO
&N       CLCLD &S1,&S2
&N       LX    F0,&S1
         LX    F1,&S2
         CXTR  F0,F1
         MEND
         PRINT DATA
*MCALL #=     1 LV= 1 TESTDFP1 RT1   MAIN
*MCALL #=     2 LV= 2 TESTDFP1 SUBENTRY 
TESTDFP1 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTDFP1'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTDFP1+8,13
*MEXIT #=     2 LV= 2 SUBENTRY
*MCALL #=     3 LV= 2          WTO   'TESTDFP1 RT1 STARTED'
         BRAS  1,*+(WTO#0003_EOT-*+1)/2*2
         DC    AL2(WTO#0003_EOT-*,0),C'TESTDFP1 RT1 STARTED'
WTO#0003_EOT     EQU *
         SVC   35
*MEXIT #=     3 LV= 2 WTO
         BRCL    15,RT1_START
RT1_ABORT DS 0H
         MVI   RT1_ABORTED,C'T'
*MCALL #=     4 LV= 2          WTO   'TESTDFP1 RT1 TESTING ABORTED'
         BRAS  1,*+(WTO#0004_EOT-*+1)/2*2
         DC    AL2(WTO#0004_EOT-*,0),C'TESTDFP1 RT1 TESTING ABORTED'
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
*MCALL #=     6 LV= 2          WTO   'TESTDFP1 RT1 ENDED OK'
         BRAS  1,*+(WTO#0006_EOT-*+1)/2*2
         DC    AL2(WTO#0006_EOT-*,0),C'TESTDFP1 RT1 ENDED OK'
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
RT1_WTO1 DC    AL2(RT1_WTO_END-*,0),C'TESTDFP1 RT1 TESTS COMPLETED = '
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
DD1      DC    DD'0'
ED1      DC    ED'0'
LD1      DC    LD'0'
PL16     DC    PL16'0'
WORK     DC    XL16'00'
ED_BIAS  EQU   101    S,C5,BXCF6,CCF20
DD_BIAS  EQU   398    S,C5,BXCF8,CCF50
LD_BIAS  EQU   6176   S,C5,BXDF12,CCF110
DDMIN    DC    DD'(MIN)'  RPI-820
DDMAX    DC    DD'(MAX)'  RPI-820
LDMIN    DC    LD'(MIN)'  RPI-820
LDMAX    DC    LD'(MAX)'  RPI-820
FPCREG   DC    F'0'   FPC BFP/DFP CONTROL REG WORK AREA
FPCDXC   EQU   FPCREG+2 REASON CODES FOR 0C7 DATA EXCEPTIONS
TDCPZ    EQU   X'800' TEST DFP DATA CLASS PLUS  ZERO
TDCMZ    EQU   X'400' TEST DFP DATA CLASS MINUS ZERO
TDCPSN   EQU   X'200' TEST DFP DATA CLASS PLUS  SUBNORMAL  <MIN OR >MAX
TDCMSN   EQU   X'100' TEST DFP DATA CLASS MINUS SUBNORMAL
TDCPN    EQU   X'080' TEST DFP DATA CLASS PLUS  NORMAL     IN RANGE
TDCMN    EQU   X'040' TEST DFP DATA CLASS MINUS NORMAL
TDCPI    EQU   X'020' TEST DFP DATA CLASS PLUS  INFINITY
TDCMI    EQU   X'010' TEST DFP DATA CLASS MINUS INFINITY
TDCPQ    EQU   X'008' TEST DFP DATA CLASS PLUS  QUIET NAN
TDCMQ    EQU   X'004' TEST DFP DATA CLASS MINUS QUIET NAN
TDCPSG   EQU   X'002' TEST DFP DATA CLASS PLUS  SIGNAL NAN
TDCMSG   EQU   X'001' TEST DFP DATA CLASS MINUS SIGNAL NAN
TDGPSZ   EQU   X'800' TEST DFP DATA GROUP PLUS  SAFE ZERO
TDGMSZ   EQU   X'400' TEST DFP DATA GROUP MINUS SAVE ZERO
TDGPEZ   EQU   X'200' TEST DFP DATA GROUP PLUS  EXTREME EXP ZERO
TDGMEZ   EQU   X'100' TEST DFP DATA GROUP MINUS EXTREME EXP ZERO
TDGPEF   EQU   X'080' TEST DFP DATA GROUP PLUS  EXTRENE FINITE
TDGMEF   EQU   X'040' TEST DFP DATA GROUP MINUS EXTREME FINITE
TDGPSF   EQU   X'020' TEST DFP DATA GROUP PLUS  SAFE FINITE
TDGMSF   EQU   X'010' TEST DFP DATA GROUP MINUS SAFE FINITE
TDGPDF   EQU   X'008' TEST DFP DATA GROUP PLUS  FIRST DIGIT NON EXT EXP
TDGMDF   EQU   X'004' TEST DFP DATA GROUP MINUS FIRST DIGIT NON EXT EXP
TDGPIN   EQU   X'002' TEST DFP DATA GROUP PLUS  INFINITY OR NAN
TDGMIN   EQU   X'001' TEST DFP DATA GROUP MINUS INFINITY OR NAM
*MCALL #=     9 LV= 1          EQUREGS REGS=GPR
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
*MCALL #=    10 LV= 1          EQUREGS REGS=FPR
F0     EQU 0
F1     EQU 1
F2     EQU 2
F3     EQU 3
F4     EQU 4
F5     EQU 5
F6     EQU 6
F7     EQU 7
F8     EQU 8
F9     EQU 9
F10    EQU 10
F11    EQU 11
F12    EQU 12
F13    EQU 13
F14    EQU 14
F15    EQU 15
*MEXIT #=    10 LV= 1 EQUREGS
ESPIE_EXIT DS  0H
         USING *,R15
         USING EPIE,R1
         L     R0,EPIEPARM
         ST    R0,EPIEPSW+4
         BR    R14
         DROP  R15,R1
*MCALL #=    11 LV= 1          RT1   START
RT1_START DS  0H
*MEXIT #=    11 LV= 1 RT1
* B2B9 SRNMT
         SRNMT 1 SET DFP ROUND TO ZERO
         LD    4,=DD'1.5'
         FIDTR 1,0,4,0
         LD    5,=DD'1'
         CDTR  1,5
*MCALL #=    12 LV= 1          RT1   CC0
         DS    0H
RT1_TEST1        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1
         LTORG 
RT1_CCE1        DS 0H
*MEXIT #=    12 LV= 1 RT1
         SRNMT 0 RESET TO DFP ROUND HALF EVEN
         LD    4,=DD'1.5'
         FIDTR 1,0,4,0
         LD    5,=DD'2'
         CDTR  1,5
*MCALL #=    13 LV= 1          RT1   CC0
         DS    0H
RT1_TEST2        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE2
         LTORG 
RT1_CCE2        DS 0H
*MEXIT #=    13 LV= 1 RT1
* B2BD LFAS
         STFPC FPCREG
         OI    FPCREG+3,X'10'
         LFAS  FPCREG SET DFP ROUND MODE 1 - RND TO ZERO
         LD    4,=DD'1.5'
         FIDTR 1,0,4,0
         LD    5,=DD'1'
         CDTR  1,5
*MCALL #=    14 LV= 1          RT1   CC0
         DS    0H
RT1_TEST3        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE3
         LTORG 
RT1_CCE3        DS 0H
*MEXIT #=    14 LV= 1 RT1
         NI    FPCREG+3,X'8F' RESET DFP RND TO 0 - NEAR HALF EVEN
         LFAS  FPCREG
         LD    4,=DD'1.5'
         FIDTR 1,0,4,0
         LD    5,=DD'2'
         CDTR  1,5
*MCALL #=    15 LV= 1          RT1   CC0
         DS    0H
RT1_TEST4        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE4
         LTORG 
RT1_CCE4        DS 0H
*MEXIT #=    15 LV= 1 RT1
* B370 LPDFR
         LD    2,=DD'1'
         LD    3,=DD'1'
         LPDFR 1,2
         CDTR  1,3
*MCALL #=    16 LV= 1          RT1   CC0
         DS    0H
RT1_TEST5        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE5
         LTORG 
RT1_CCE5        DS 0H
*MEXIT #=    16 LV= 1 RT1
         LD    2,=DD'-1'
         LD    3,=DD'1'
         LPDFR 1,2
         CDTR  1,3
*MCALL #=    17 LV= 1          RT1   CC0
         DS    0H
RT1_TEST6        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE6
         LTORG 
RT1_CCE6        DS 0H
*MEXIT #=    17 LV= 1 RT1
* B371 LNDFR
         LD    2,=DD'1'
         LD    3,=DD'-1'
         LNDFR 1,2
         CDTR  1,3
*MCALL #=    18 LV= 1          RT1   CC0
         DS    0H
RT1_TEST7        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE7
         LTORG 
RT1_CCE7        DS 0H
*MEXIT #=    18 LV= 1 RT1
         LD    2,=DD'-1'
         LD    3,=DD'-1'
         LNDFR 1,2
         CDTR  1,3
*MCALL #=    19 LV= 1          RT1   CC0
         DS    0H
RT1_TEST8        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE8
         LTORG 
RT1_CCE8        DS 0H
*MEXIT #=    19 LV= 1 RT1
* B372 CPSDR
         LD    2,=DD'2'
         LD    3,=DD'-3'
         LD    4,=DD'3'
         CPSDR 1,2,3
         CDTR  1,4
*MCALL #=    20 LV= 1          RT1   CC0
         DS    0H
RT1_TEST9        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE9
         LTORG 
RT1_CCE9        DS 0H
*MEXIT #=    20 LV= 1 RT1
         LD    2,=DD'-2'
         LD    3,=DD'3'
         LD    4,=DD'-3'
         CPSDR 1,2,3
         CDTR  1,4
*MCALL #=    21 LV= 1          RT1   CC0
         DS    0H
RT1_TEST10       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE10
         LTORG 
RT1_CCE10       DS 0H
*MEXIT #=    21 LV= 1 RT1
* B373 LCDFR
         LD    2,=DD'1'
         LD    3,=DD'-1'
         LCDFR 1,2
         CDTR  1,3
*MCALL #=    22 LV= 1          RT1   CC0
         DS    0H
RT1_TEST11       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE11
         LTORG 
RT1_CCE11       DS 0H
*MEXIT #=    22 LV= 1 RT1
         LD    2,=DD'-1'
         LD    3,=DD'1'
         LCDFR 1,2
         CDTR  1,3
*MCALL #=    23 LV= 1          RT1   CC0
         DS    0H
RT1_TEST12       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE12
         LTORG 
RT1_CCE12       DS 0H
*MEXIT #=    23 LV= 1 RT1
* B385 SFASR
         STFPC FPCREG
         OI    FPCREG+3,X'10'
         L     1,FPCREG
         SFASR 1 SET DFP ROUND MODE 1 - RND TO ZERO
         LD    4,=DD'1.5'
         FIDTR 1,0,4,0
         LD    5,=DD'1'
         CDTR  1,5
*MCALL #=    24 LV= 1          RT1   CC0
         DS    0H
RT1_TEST13       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE13
         LTORG 
RT1_CCE13       DS 0H
*MEXIT #=    24 LV= 1 RT1
         NI    FPCREG+3,X'8F' RESET DFP RND TO 0 - NEAR HALF EVEN
         L     1,FPCREG
         SFASR 1
         LD    4,=DD'1.5'
         FIDTR 1,0,4,0
         LD    5,=DD'2'
         CDTR  1,5
*MCALL #=    25 LV= 1          RT1   CC0
         DS    0H
RT1_TEST14       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE14
         LTORG 
RT1_CCE14       DS 0H
*MEXIT #=    25 LV= 1 RT1
* B3C1 LDGR
         LG    2,=DD'1'
         LD    3,=DD'1'
         LDGR  1,2
         CDTR  1,3
*MCALL #=    26 LV= 1          RT1   CC0
         DS    0H
RT1_TEST15       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE15
         LTORG 
RT1_CCE15       DS 0H
*MEXIT #=    26 LV= 1 RT1
         LG    2,=DD'2'
         LD    3,=DD'2'
         LDGR  1,2
         CDTR  1,3
*MCALL #=    27 LV= 1          RT1   CC0
         DS    0H
RT1_TEST16       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE16
         LTORG 
RT1_CCE16       DS 0H
*MEXIT #=    27 LV= 1 RT1
* B3CD LGDR
         LD    2,=DD'1'
         LG    3,=DD'1'
         LGDR  1,2
         CGR   1,3
*MCALL #=    28 LV= 1          RT1   CC0
         DS    0H
RT1_TEST17       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE17
         LTORG 
RT1_CCE17       DS 0H
*MEXIT #=    28 LV= 1 RT1
         LD    2,=DD'2'
         LG    3,=DD'2'
         LGDR  1,2
         CGR   1,3
*MCALL #=    29 LV= 1          RT1   CC0
         DS    0H
RT1_TEST18       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE18
         LTORG 
RT1_CCE18       DS 0H
*MEXIT #=    29 LV= 1 RT1
* B3D0 MDTR
         LD    2,=DD'30'
         LD    3,=DD'20'
         MDTR  1,2,3
         STD   1,DD1
*MCALL #=    30 LV= 1          CLCDD DD1,=DD'600'
         LD    F0,DD1
         LD    F1,=DD'600'
         CDTR  F0,F1
*MEXIT #=    30 LV= 1 CLCDD
*MCALL #=    31 LV= 1          RT1   CCE
         DS    0H
RT1_TEST19       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE19
         LTORG 
RT1_CCE19       DS 0H
*MEXIT #=    31 LV= 1 RT1
         LD    2,=DD'-30'
         LD    3,=DD'-20'
         MDTR  1,2,3
         STD   1,DD1
*MCALL #=    32 LV= 1          CLCDD DD1,=DD'600'
         LD    F0,DD1
         LD    F1,=DD'600'
         CDTR  F0,F1
*MEXIT #=    32 LV= 1 CLCDD
*MCALL #=    33 LV= 1          RT1   CCE
         DS    0H
RT1_TEST20       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE20
         LTORG 
RT1_CCE20       DS 0H
*MEXIT #=    33 LV= 1 RT1
*MCALL #=    34 LV= 1          ESPIE SET,ESPIE_EXIT,7,PARAM=MDTR1 DFP OX
               VERFLOW FPCDXC=20
        LA     15,MDTR1
        IPM    0  GET CURRENT PGM MASK
        SPM    0 TURN ON ANY MASKS REQUIRED
        L      0,=B'00000001000000000000000000000000'
        LA     1,ESPIE_EXIT
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=    34 LV= 1 ESPIE
         LD    R0,=DD'1'
         LD    R1,DDMAX
         MDTR  R0,R0,R1
*MCALL #=    35 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=    35 LV= 1 RT1
*MCALL #=    36 LV= 1 MDTR1    ESPIE RESET
MDTR1    DS    0H
        SR     15,15
        SR     1,1
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=    36 LV= 1 ESPIE
*MCALL #=    37 LV= 1          WTO  'ESPIE DFP MDTR OVERFLOW OK'
         BRAS  1,*+(WTO#0037_EOT-*+1)/2*2
         DC    AL2(WTO#0037_EOT-*,0),C'ESPIE DFP MDTR OVERFLOW OK'
WTO#0037_EOT     EQU *
         SVC   35
*MEXIT #=    37 LV= 1 WTO
* B3D1 DDTR
         LD    2,=DD'600'
         LD    3,=DD'20'
         DDTR  1,2,3
         STD   1,DD1
*MCALL #=    38 LV= 1          CLCDD DD1,=DD'30'
         LD    F0,DD1
         LD    F1,=DD'30'
         CDTR  F0,F1
*MEXIT #=    38 LV= 1 CLCDD
*MCALL #=    39 LV= 1          RT1   CCE
         DS    0H
RT1_TEST22       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE22
         LTORG 
RT1_CCE22       DS 0H
*MEXIT #=    39 LV= 1 RT1
         LD    2,=DD'10'
         LD    3,=DD'3'
         DDTR  1,2,3
         STD   1,DD1
*MCALL #=    40 LV= 1          CLCDD DD1,=DD'3.333333333333333'
         LD    F0,DD1
         LD    F1,=DD'3.333333333333333'
         CDTR  F0,F1
*MEXIT #=    40 LV= 1 CLCDD
*MCALL #=    41 LV= 1          RT1   CCE
         DS    0H
RT1_TEST23       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE23
         LTORG 
RT1_CCE23       DS 0H
*MEXIT #=    41 LV= 1 RT1
*MCALL #=    42 LV= 1          ESPIE SET,ESPIE_EXIT,7,PARAM=DDTR1 DFP DX
               IV FPCDXC=40 RPI-820
        LA     15,DDTR1
        IPM    0  GET CURRENT PGM MASK
        SPM    0 TURN ON ANY MASKS REQUIRED
        L      0,=B'00000001000000000000000000000000'
        LA     1,ESPIE_EXIT
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=    42 LV= 1 ESPIE
         LD    R4,=DD'1'
         LD    R5,=DD'0'
         DDTR  R1,R4,R5
*MCALL #=    43 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=    43 LV= 1 RT1
*MCALL #=    44 LV= 1 DDTR1    ESPIE RESET
DDTR1    DS    0H
        SR     15,15
        SR     1,1
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=    44 LV= 1 ESPIE
         STFPC FPCREG
         CLI   FPCDXC,X'40'
*MCALL #=    45 LV= 1          RT1   CCE
         DS    0H
RT1_TEST25       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE25
         LTORG 
RT1_CCE25       DS 0H
*MEXIT #=    45 LV= 1 RT1
*MCALL #=    46 LV= 1          WTO   'ESPIE DFP DDTR DIVIDE OK'
         BRAS  1,*+(WTO#0046_EOT-*+1)/2*2
         DC    AL2(WTO#0046_EOT-*,0),C'ESPIE DFP DDTR DIVIDE OK'
WTO#0046_EOT     EQU *
         SVC   35
*MEXIT #=    46 LV= 1 WTO
* B3D2 ADTR
         LD    2,=DD'1234567890123456'
         LD    3,=DD'1111111111111111'
         ADTR  1,2,3
*MCALL #=    47 LV= 1          RT1   CC2
         DS    0H
RT1_TEST26       BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH26
         LTORG 
RT1_CCH26       DS 0H
*MEXIT #=    47 LV= 1 RT1
         STD   1,DD1
*MCALL #=    48 LV= 1          CLCDD DD1,=DD'2345679001234567'
         LD    F0,DD1
         LD    F1,=DD'2345679001234567'
         CDTR  F0,F1
*MEXIT #=    48 LV= 1 CLCDD
*MCALL #=    49 LV= 1          RT1   CCE
         DS    0H
RT1_TEST27       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE27
         LTORG 
RT1_CCE27       DS 0H
*MEXIT #=    49 LV= 1 RT1
         LD    2,=DD'1'
         LD    3,=DD'2'
         ADTR  1,2,3
*MCALL #=    50 LV= 1          RT1   CC2
         DS    0H
RT1_TEST28       BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH28
         LTORG 
RT1_CCH28       DS 0H
*MEXIT #=    50 LV= 1 RT1
         STD   1,DD1
*MCALL #=    51 LV= 1          CLCDD DD1,=DD'3'
         LD    F0,DD1
         LD    F1,=DD'3'
         CDTR  F0,F1
*MEXIT #=    51 LV= 1 CLCDD
*MCALL #=    52 LV= 1          RT1   CCE
         DS    0H
RT1_TEST29       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE29
         LTORG 
RT1_CCE29       DS 0H
*MEXIT #=    52 LV= 1 RT1
         LD    2,=DD'1.1'
         LD    3,=DD'2.2'
         ADTR  1,2,3
*MCALL #=    53 LV= 1          RT1   CC2
         DS    0H
RT1_TEST30       BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH30
         LTORG 
RT1_CCH30       DS 0H
*MEXIT #=    53 LV= 1 RT1
         STD   1,DD1
*MCALL #=    54 LV= 1          CLCDD DD1,=DD'3.3'
         LD    F0,DD1
         LD    F1,=DD'3.3'
         CDTR  F0,F1
*MEXIT #=    54 LV= 1 CLCDD
*MCALL #=    55 LV= 1          RT1   CCE
         DS    0H
RT1_TEST31       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE31
         LTORG 
RT1_CCE31       DS 0H
*MEXIT #=    55 LV= 1 RT1
         LD    2,=DD'1'
         LD    3,=DD'-1'
         ADTR  1,2,3
*MCALL #=    56 LV= 1          RT1   CC0
         DS    0H
RT1_TEST32       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE32
         LTORG 
RT1_CCE32       DS 0H
*MEXIT #=    56 LV= 1 RT1
         STD   1,DD1
*MCALL #=    57 LV= 1          CLCDD DD1,=DD'0'
         LD    F0,DD1
         LD    F1,=DD'0'
         CDTR  F0,F1
*MEXIT #=    57 LV= 1 CLCDD
*MCALL #=    58 LV= 1          RT1   CCE
         DS    0H
RT1_TEST33       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE33
         LTORG 
RT1_CCE33       DS 0H
*MEXIT #=    58 LV= 1 RT1
         LD    2,=DD'1'
         LD    3,=DD'-2'
         ADTR  1,2,3
*MCALL #=    59 LV= 1          RT1   CC1
         DS    0H
RT1_TEST34       BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL34
         LTORG 
RT1_CCL34       DS 0H
*MEXIT #=    59 LV= 1 RT1
         STD   1,DD1
*MCALL #=    60 LV= 1          CLCDD DD1,=DD'-1'
         LD    F0,DD1
         LD    F1,=DD'-1'
         CDTR  F0,F1
*MEXIT #=    60 LV= 1 CLCDD
*MCALL #=    61 LV= 1          RT1   CCE
         DS    0H
RT1_TEST35       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE35
         LTORG 
RT1_CCE35       DS 0H
*MEXIT #=    61 LV= 1 RT1
*MCALL #=    62 LV= 1          ESPIE SET,ESPIE_EXIT,7,PARAM=ADTR1 DFP OX
               VERFLOW FPCDXC=20
        LA     15,ADTR1
        IPM    0  GET CURRENT PGM MASK
        SPM    0 TURN ON ANY MASKS REQUIRED
        L      0,=B'00000001000000000000000000000000'
        LA     1,ESPIE_EXIT
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=    62 LV= 1 ESPIE
         LD    R0,DDMAX
         LD    R1,DDMAX
         ADTR  R0,R0,R1
*MCALL #=    63 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=    63 LV= 1 RT1
*MCALL #=    64 LV= 1 ADTR1    ESPIE RESET
ADTR1    DS    0H
        SR     15,15
        SR     1,1
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=    64 LV= 1 ESPIE
         STFPC FPCREG
         CLI   FPCDXC,X'20'
*MCALL #=    65 LV= 1          RT1   CCE
         DS    0H
RT1_TEST37       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE37
         LTORG 
RT1_CCE37       DS 0H
*MEXIT #=    65 LV= 1 RT1
*MCALL #=    66 LV= 1          WTO   'ESPIE DFP ADTR OVERFLOW OK'
         BRAS  1,*+(WTO#0066_EOT-*+1)/2*2
         DC    AL2(WTO#0066_EOT-*,0),C'ESPIE DFP ADTR OVERFLOW OK'
WTO#0066_EOT     EQU *
         SVC   35
*MEXIT #=    66 LV= 1 WTO
* B3D3 SDTR
         LD    2,=DD'1234567890123456'
         LD    3,=DD'1111111111111111'
         SDTR  1,2,3
*MCALL #=    67 LV= 1          RT1   CC2
         DS    0H
RT1_TEST38       BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH38
         LTORG 
RT1_CCH38       DS 0H
*MEXIT #=    67 LV= 1 RT1
         STD   1,DD1
*MCALL #=    68 LV= 1          CLCDD DD1,=DD'123456779012345'
         LD    F0,DD1
         LD    F1,=DD'123456779012345'
         CDTR  F0,F1
*MEXIT #=    68 LV= 1 CLCDD
*MCALL #=    69 LV= 1          RT1   CCE
         DS    0H
RT1_TEST39       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE39
         LTORG 
RT1_CCE39       DS 0H
*MEXIT #=    69 LV= 1 RT1
         LD    2,=DD'1'
         LD    3,=DD'1'
         SDTR  1,2,3
*MCALL #=    70 LV= 1          RT1   CC0
         DS    0H
RT1_TEST40       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE40
         LTORG 
RT1_CCE40       DS 0H
*MEXIT #=    70 LV= 1 RT1
         STD   1,DD1
*MCALL #=    71 LV= 1          CLCDD DD1,=DD'0'
         LD    F0,DD1
         LD    F1,=DD'0'
         CDTR  F0,F1
*MEXIT #=    71 LV= 1 CLCDD
*MCALL #=    72 LV= 1          RT1   CCE
         DS    0H
RT1_TEST41       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE41
         LTORG 
RT1_CCE41       DS 0H
*MEXIT #=    72 LV= 1 RT1
         LD    2,=DD'0'
         LD    3,=DD'1'
         SDTR  1,2,3
*MCALL #=    73 LV= 1          RT1   CC1
         DS    0H
RT1_TEST42       BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL42
         LTORG 
RT1_CCL42       DS 0H
*MEXIT #=    73 LV= 1 RT1
         STD   1,DD1
*MCALL #=    74 LV= 1          CLCDD DD1,=DD'-1'
         LD    F0,DD1
         LD    F1,=DD'-1'
         CDTR  F0,F1
*MEXIT #=    74 LV= 1 CLCDD
*MCALL #=    75 LV= 1          RT1   CCE
         DS    0H
RT1_TEST43       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE43
         LTORG 
RT1_CCE43       DS 0H
*MEXIT #=    75 LV= 1 RT1
*MCALL #=    76 LV= 1          ESPIE SET,ESPIE_EXIT,7,PARAM=SDTR1 DFP UX
               NDERFLOW FPCDXC=10
        LA     15,SDTR1
        IPM    0  GET CURRENT PGM MASK
        SPM    0 TURN ON ANY MASKS REQUIRED
        L      0,=B'00000001000000000000000000000000'
        LA     1,ESPIE_EXIT
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=    76 LV= 1 ESPIE
         LD    R4,DDMIN
         LD    R5,DDMIN
         ADTR  R4,R4,R5
         SDTR  R4,R4,R5
*MCALL #=    77 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=    77 LV= 1 RT1
*MCALL #=    78 LV= 1 SDTR1    ESPIE RESET
SDTR1    DS    0H
        SR     15,15
        SR     1,1
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=    78 LV= 1 ESPIE
         STFPC FPCREG
         CLI   FPCDXC,X'10'
*MCALL #=    79 LV= 1          RT1   CCE
         DS    0H
RT1_TEST45       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE45
         LTORG 
RT1_CCE45       DS 0H
*MEXIT #=    79 LV= 1 RT1
*MCALL #=    80 LV= 1          WTO   'ESPIE DFP SDTR UNDERFLOW OK'
         BRAS  1,*+(WTO#0080_EOT-*+1)/2*2
         DC    AL2(WTO#0080_EOT-*,0),C'ESPIE DFP SDTR UNDERFLOW OK'
WTO#0080_EOT     EQU *
         SVC   35
*MEXIT #=    80 LV= 1 WTO
* B3D4 LDETR
         LE    4,=ED'123'
         LDETR 1,4,0
         LD    5,=DD'123'
         CDTR  1,5
*MCALL #=    81 LV= 1          RT1   CC0
         DS    0H
RT1_TEST46       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE46
         LTORG 
RT1_CCE46       DS 0H
*MEXIT #=    81 LV= 1 RT1
* B3D5 LEDTR
         LD    4,=DD'1234568.5'
         LEDTR 1,0,4,0 DEFAULT NEAREST HALF EVEN
         STE   1,ED1
*MCALL #=    82 LV= 1          CLCED ED1,=ED'1234568'
         LE    F0,ED1
         LDETR F0,F0,0
         LE    F1,=ED'1234568'
         LDETR F1,F1,0
         CDTR  F0,R1
*MEXIT #=    82 LV= 1 CLCED
*MCALL #=    83 LV= 1          RT1   CC0
         DS    0H
RT1_TEST47       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE47
         LTORG 
RT1_CCE47       DS 0H
*MEXIT #=    83 LV= 1 RT1
         LD    4,=DD'1234565.5'
         LEDTR 1,0,4,0 DEFAULT NEAREST HALF EVEN
         STE   1,ED1
*MCALL #=    84 LV= 1          CLCED ED1,=ED'1234566'
         LE    F0,ED1
         LDETR F0,F0,0
         LE    F1,=ED'1234566'
         LDETR F1,F1,0
         CDTR  F0,R1
*MEXIT #=    84 LV= 1 CLCED
*MCALL #=    85 LV= 1          RT1   CC0
         DS    0H
RT1_TEST48       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE48
         LTORG 
RT1_CCE48       DS 0H
*MEXIT #=    85 LV= 1 RT1
         LD    4,=DD'1234568.5'
         LEDTR 1,8+1,4,0 ROUND TOWARD ZERO
         STE   1,ED1
*MCALL #=    86 LV= 1          CLCED ED1,=ED'1234568'
         LE    F0,ED1
         LDETR F0,F0,0
         LE    F1,=ED'1234568'
         LDETR F1,F1,0
         CDTR  F0,R1
*MEXIT #=    86 LV= 1 CLCED
*MCALL #=    87 LV= 1          RT1   CC0
         DS    0H
RT1_TEST49       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE49
         LTORG 
RT1_CCE49       DS 0H
*MEXIT #=    87 LV= 1 RT1
         LD    4,=DD'1234567.5'
         LEDTR 1,8+1,4,0 ROUND TOWARD ZERO
         STE   1,ED1
*MCALL #=    88 LV= 1          CLCED ED1,=ED'1234567'
         LE    F0,ED1
         LDETR F0,F0,0
         LE    F1,=ED'1234567'
         LDETR F1,F1,0
         CDTR  F0,R1
*MEXIT #=    88 LV= 1 CLCED
*MCALL #=    89 LV= 1          RT1   CC0
         DS    0H
RT1_TEST50       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE50
         LTORG 
RT1_CCE50       DS 0H
*MEXIT #=    89 LV= 1 RT1
* B3D6 LTDTR
         LD    4,=DD'1'
         LTDTR 1,4
*MCALL #=    90 LV= 1          RT1   CCH
         DS    0H
RT1_TEST51       BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH51
         LTORG 
RT1_CCH51       DS 0H
*MEXIT #=    90 LV= 1 RT1
         CDTR  1,4
*MCALL #=    91 LV= 1          RT1   CC0
         DS    0H
RT1_TEST52       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE52
         LTORG 
RT1_CCE52       DS 0H
*MEXIT #=    91 LV= 1 RT1
         LD    4,=DD'0'
         LTDTR 1,4
*MCALL #=    92 LV= 1          RT1   CC0
         DS    0H
RT1_TEST53       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE53
         LTORG 
RT1_CCE53       DS 0H
*MEXIT #=    92 LV= 1 RT1
         CDTR  1,4
*MCALL #=    93 LV= 1          RT1   CC0
         DS    0H
RT1_TEST54       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE54
         LTORG 
RT1_CCE54       DS 0H
*MEXIT #=    93 LV= 1 RT1
         LD    4,=DD'-1'
         LTDTR 1,4
*MCALL #=    94 LV= 1          RT1   CC1
         DS    0H
RT1_TEST55       BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL55
         LTORG 
RT1_CCL55       DS 0H
*MEXIT #=    94 LV= 1 RT1
         CDTR  1,4
*MCALL #=    95 LV= 1          RT1   CC0
         DS    0H
RT1_TEST56       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE56
         LTORG 
RT1_CCE56       DS 0H
*MEXIT #=    95 LV= 1 RT1
* B3D7 FIDTR
         LD    4,=DD'123'
         FIDTR 1,0,4,0
         LD    5,=DD'123'
         CDTR  1,5
*MCALL #=    96 LV= 1          RT1   CC0
         DS    0H
RT1_TEST57       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE57
         LTORG 
RT1_CCE57       DS 0H
*MEXIT #=    96 LV= 1 RT1
         LD    4,=DD'1.5'
         FIDTR 1,0,4,0
         LD    5,=DD'2'
         CDTR  1,5
*MCALL #=    97 LV= 1          RT1   CC0
         DS    0H
RT1_TEST58       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE58
         LTORG 
RT1_CCE58       DS 0H
*MEXIT #=    97 LV= 1 RT1
* B3D8 MXTR
*MCALL #=    98 LV= 1          LX    4,=LD'30'
         LA    15,=LD'30'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=    98 LV= 1 LX
*MCALL #=    99 LV= 1          LX    5,=LD'20'
         LA    15,=LD'20'
         LD    5,0(15)
         LD    5+2,8(15)
*MEXIT #=    99 LV= 1 LX
         MXTR  1,4,5
*MCALL #=   100 LV= 1          STX   1,LD1
         LA    15,LD1
         STD   1,0(15)
         STD   1+2,8(15)
*MEXIT #=   100 LV= 1 STX
*MCALL #=   101 LV= 1          CLCLD LD1,=LD'600'
*MCALL #=   102 LV= 2          LX    F0,LD1
         LA    15,LD1
         LD    F0,0(15)
         LD    F0+2,8(15)
*MEXIT #=   102 LV= 2 LX
*MCALL #=   103 LV= 2          LX    F1,=LD'600'
         LA    15,=LD'600'
         LD    F1,0(15)
         LD    F1+2,8(15)
*MEXIT #=   103 LV= 2 LX
         CXTR  F0,F1
*MEXIT #=   101 LV= 1 CLCLD
*MCALL #=   104 LV= 1          RT1   CCE
         DS    0H
RT1_TEST59       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE59
         LTORG 
RT1_CCE59       DS 0H
*MEXIT #=   104 LV= 1 RT1
*MCALL #=   105 LV= 1          LX    4,=LD'-30'
         LA    15,=LD'-30'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   105 LV= 1 LX
*MCALL #=   106 LV= 1          LX    5,=LD'-20'
         LA    15,=LD'-20'
         LD    5,0(15)
         LD    5+2,8(15)
*MEXIT #=   106 LV= 1 LX
         MXTR  1,4,5
*MCALL #=   107 LV= 1          STX   1,LD1
         LA    15,LD1
         STD   1,0(15)
         STD   1+2,8(15)
*MEXIT #=   107 LV= 1 STX
*MCALL #=   108 LV= 1          CLCLD LD1,=LD'600'
*MCALL #=   109 LV= 2          LX    F0,LD1
         LA    15,LD1
         LD    F0,0(15)
         LD    F0+2,8(15)
*MEXIT #=   109 LV= 2 LX
*MCALL #=   110 LV= 2          LX    F1,=LD'600'
         LA    15,=LD'600'
         LD    F1,0(15)
         LD    F1+2,8(15)
*MEXIT #=   110 LV= 2 LX
         CXTR  F0,F1
*MEXIT #=   108 LV= 1 CLCLD
*MCALL #=   111 LV= 1          RT1   CCE
         DS    0H
RT1_TEST60       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE60
         LTORG 
RT1_CCE60       DS 0H
*MEXIT #=   111 LV= 1 RT1
*MCALL #=   112 LV= 1          ESPIE SET,ESPIE_EXIT,7,PARAM=MXTR1 DFP OX
               VERFLOW FPCDXC=20
        LA     15,MXTR1
        IPM    0  GET CURRENT PGM MASK
        SPM    0 TURN ON ANY MASKS REQUIRED
        L      0,=B'00000001000000000000000000000000'
        LA     1,ESPIE_EXIT
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   112 LV= 1 ESPIE
*MCALL #=   113 LV= 1          LX    R0,=LD'1'
         LA    15,=LD'1'
         LD    R0,0(15)
         LD    R0+2,8(15)
*MEXIT #=   113 LV= 1 LX
*MCALL #=   114 LV= 1          LX    R1,LDMAX
         LA    15,LDMAX
         LD    R1,0(15)
         LD    R1+2,8(15)
*MEXIT #=   114 LV= 1 LX
         MXTR  R0,R0,R1
*MCALL #=   115 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   115 LV= 1 RT1
*MCALL #=   116 LV= 1 MXTR1    ESPIE RESET
MXTR1    DS    0H
        SR     15,15
        SR     1,1
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   116 LV= 1 ESPIE
*MCALL #=   117 LV= 1          WTO  'ESPIE DFP MXTR OVERFLOW OK'
         BRAS  1,*+(WTO#0117_EOT-*+1)/2*2
         DC    AL2(WTO#0117_EOT-*,0),C'ESPIE DFP MXTR OVERFLOW OK'
WTO#0117_EOT     EQU *
         SVC   35
*MEXIT #=   117 LV= 1 WTO
* B3D9 DXTR
*MCALL #=   118 LV= 1          LX    4,=LD'600'
         LA    15,=LD'600'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   118 LV= 1 LX
*MCALL #=   119 LV= 1          LX    5,=LD'20'
         LA    15,=LD'20'
         LD    5,0(15)
         LD    5+2,8(15)
*MEXIT #=   119 LV= 1 LX
         DXTR  1,4,5
*MCALL #=   120 LV= 1          STX   1,LD1
         LA    15,LD1
         STD   1,0(15)
         STD   1+2,8(15)
*MEXIT #=   120 LV= 1 STX
*MCALL #=   121 LV= 1          CLCLD LD1,=LD'30'
*MCALL #=   122 LV= 2          LX    F0,LD1
         LA    15,LD1
         LD    F0,0(15)
         LD    F0+2,8(15)
*MEXIT #=   122 LV= 2 LX
*MCALL #=   123 LV= 2          LX    F1,=LD'30'
         LA    15,=LD'30'
         LD    F1,0(15)
         LD    F1+2,8(15)
*MEXIT #=   123 LV= 2 LX
         CXTR  F0,F1
*MEXIT #=   121 LV= 1 CLCLD
*MCALL #=   124 LV= 1          RT1   CCE
         DS    0H
RT1_TEST62       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE62
         LTORG 
RT1_CCE62       DS 0H
*MEXIT #=   124 LV= 1 RT1
*MCALL #=   125 LV= 1          LX    4,=LD'10'
         LA    15,=LD'10'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   125 LV= 1 LX
*MCALL #=   126 LV= 1          LX    5,=LD'3'
         LA    15,=LD'3'
         LD    5,0(15)
         LD    5+2,8(15)
*MEXIT #=   126 LV= 1 LX
         DXTR  1,4,5
*MCALL #=   127 LV= 1          STX   1,LD1
         LA    15,LD1
         STD   1,0(15)
         STD   1+2,8(15)
*MEXIT #=   127 LV= 1 STX
*MCALL #=   128 LV= 1          CLCLD LD1,=LD'3.333333333333333333333333X
               333333333'
*MCALL #=   129 LV= 2          LX    F0,LD1
         LA    15,LD1
         LD    F0,0(15)
         LD    F0+2,8(15)
*MEXIT #=   129 LV= 2 LX
*MCALL #=   130 LV= 2          LX    F1,=LD'3.3333333333333333333333333X
               33333333'
         LA    15,=LD'3.333333333333333333333333333333333'
         LD    F1,0(15)
         LD    F1+2,8(15)
*MEXIT #=   130 LV= 2 LX
         CXTR  F0,F1
*MEXIT #=   128 LV= 1 CLCLD
*MCALL #=   131 LV= 1          RT1   CCE
         DS    0H
RT1_TEST63       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE63
         LTORG 
RT1_CCE63       DS 0H
*MEXIT #=   131 LV= 1 RT1
*MCALL #=   132 LV= 1          ESPIE SET,ESPIE_EXIT,7,PARAM=DXTR1 DFP DX
               IV FPCDXC=40 RPI-820
        LA     15,DXTR1
        IPM    0  GET CURRENT PGM MASK
        SPM    0 TURN ON ANY MASKS REQUIRED
        L      0,=B'00000001000000000000000000000000'
        LA     1,ESPIE_EXIT
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   132 LV= 1 ESPIE
*MCALL #=   133 LV= 1          LX    R4,=LD'1'
         LA    15,=LD'1'
         LD    R4,0(15)
         LD    R4+2,8(15)
*MEXIT #=   133 LV= 1 LX
*MCALL #=   134 LV= 1          LX    R5,=LD'0'
         LA    15,=LD'0'
         LD    R5,0(15)
         LD    R5+2,8(15)
*MEXIT #=   134 LV= 1 LX
         DXTR  R0,R4,R5
*MCALL #=   135 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   135 LV= 1 RT1
*MCALL #=   136 LV= 1 DXTR1    ESPIE RESET
DXTR1    DS    0H
        SR     15,15
        SR     1,1
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   136 LV= 1 ESPIE
         STFPC FPCREG
         CLI   FPCDXC,X'40'
*MCALL #=   137 LV= 1          RT1   CCE
         DS    0H
RT1_TEST65       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE65
         LTORG 
RT1_CCE65       DS 0H
*MEXIT #=   137 LV= 1 RT1
*MCALL #=   138 LV= 1          WTO   'ESPIE DFP DXTR DIVIDE OK'
         BRAS  1,*+(WTO#0138_EOT-*+1)/2*2
         DC    AL2(WTO#0138_EOT-*,0),C'ESPIE DFP DXTR DIVIDE OK'
WTO#0138_EOT     EQU *
         SVC   35
*MEXIT #=   138 LV= 1 WTO
* B3DA AXTR
*MCALL #=   139 LV= 1          LX    4,=LD'1234567890123456789012345678X
               901234'
         LA    15,=LD'1234567890123456789012345678901234'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   139 LV= 1 LX
*MCALL #=   140 LV= 1          LX    5,=LD'1111111111111111111111111111X
               111111'
         LA    15,=LD'1111111111111111111111111111111111'
         LD    5,0(15)
         LD    5+2,8(15)
*MEXIT #=   140 LV= 1 LX
         AXTR  1,4,5
*MCALL #=   141 LV= 1          RT1   CC2
         DS    0H
RT1_TEST66       BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH66
         LTORG 
RT1_CCH66       DS 0H
*MEXIT #=   141 LV= 1 RT1
*MCALL #=   142 LV= 1          STX   1,LD1
         LA    15,LD1
         STD   1,0(15)
         STD   1+2,8(15)
*MEXIT #=   142 LV= 1 STX
*MCALL #=   143 LV= 1          CLCLD LD1,=LD'23456790012345679001234567X
               90012345'
*MCALL #=   144 LV= 2          LX    F0,LD1
         LA    15,LD1
         LD    F0,0(15)
         LD    F0+2,8(15)
*MEXIT #=   144 LV= 2 LX
*MCALL #=   145 LV= 2          LX    F1,=LD'234567900123456790012345679X
               0012345'
         LA    15,=LD'2345679001234567900123456790012345'
         LD    F1,0(15)
         LD    F1+2,8(15)
*MEXIT #=   145 LV= 2 LX
         CXTR  F0,F1
*MEXIT #=   143 LV= 1 CLCLD
*MCALL #=   146 LV= 1          RT1   CCE
         DS    0H
RT1_TEST67       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE67
         LTORG 
RT1_CCE67       DS 0H
*MEXIT #=   146 LV= 1 RT1
*MCALL #=   147 LV= 1          LX    4,=LD'1'
         LA    15,=LD'1'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   147 LV= 1 LX
*MCALL #=   148 LV= 1          LX    5,=LD'2'
         LA    15,=LD'2'
         LD    5,0(15)
         LD    5+2,8(15)
*MEXIT #=   148 LV= 1 LX
         AXTR  1,4,5
*MCALL #=   149 LV= 1          RT1   CC2
         DS    0H
RT1_TEST68       BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH68
         LTORG 
RT1_CCH68       DS 0H
*MEXIT #=   149 LV= 1 RT1
*MCALL #=   150 LV= 1          STX   1,LD1
         LA    15,LD1
         STD   1,0(15)
         STD   1+2,8(15)
*MEXIT #=   150 LV= 1 STX
*MCALL #=   151 LV= 1          CLCLD LD1,=LD'3'
*MCALL #=   152 LV= 2          LX    F0,LD1
         LA    15,LD1
         LD    F0,0(15)
         LD    F0+2,8(15)
*MEXIT #=   152 LV= 2 LX
*MCALL #=   153 LV= 2          LX    F1,=LD'3'
         LA    15,=LD'3'
         LD    F1,0(15)
         LD    F1+2,8(15)
*MEXIT #=   153 LV= 2 LX
         CXTR  F0,F1
*MEXIT #=   151 LV= 1 CLCLD
*MCALL #=   154 LV= 1          RT1   CCE
         DS    0H
RT1_TEST69       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE69
         LTORG 
RT1_CCE69       DS 0H
*MEXIT #=   154 LV= 1 RT1
*MCALL #=   155 LV= 1          LX    4,=LD'1.1'
         LA    15,=LD'1.1'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   155 LV= 1 LX
*MCALL #=   156 LV= 1          LX    5,=LD'2.2'
         LA    15,=LD'2.2'
         LD    5,0(15)
         LD    5+2,8(15)
*MEXIT #=   156 LV= 1 LX
         AXTR  1,4,5
*MCALL #=   157 LV= 1          RT1   CC2
         DS    0H
RT1_TEST70       BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH70
         LTORG 
RT1_CCH70       DS 0H
*MEXIT #=   157 LV= 1 RT1
*MCALL #=   158 LV= 1          STX   1,LD1
         LA    15,LD1
         STD   1,0(15)
         STD   1+2,8(15)
*MEXIT #=   158 LV= 1 STX
*MCALL #=   159 LV= 1          CLCLD LD1,=LD'3.3'
*MCALL #=   160 LV= 2          LX    F0,LD1
         LA    15,LD1
         LD    F0,0(15)
         LD    F0+2,8(15)
*MEXIT #=   160 LV= 2 LX
*MCALL #=   161 LV= 2          LX    F1,=LD'3.3'
         LA    15,=LD'3.3'
         LD    F1,0(15)
         LD    F1+2,8(15)
*MEXIT #=   161 LV= 2 LX
         CXTR  F0,F1
*MEXIT #=   159 LV= 1 CLCLD
*MCALL #=   162 LV= 1          RT1   CCE
         DS    0H
RT1_TEST71       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE71
         LTORG 
RT1_CCE71       DS 0H
*MEXIT #=   162 LV= 1 RT1
*MCALL #=   163 LV= 1          LX    4,=LD'1'
         LA    15,=LD'1'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   163 LV= 1 LX
*MCALL #=   164 LV= 1          LX    5,=LD'-1'
         LA    15,=LD'-1'
         LD    5,0(15)
         LD    5+2,8(15)
*MEXIT #=   164 LV= 1 LX
         AXTR  1,4,5
*MCALL #=   165 LV= 1          RT1   CC0
         DS    0H
RT1_TEST72       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE72
         LTORG 
RT1_CCE72       DS 0H
*MEXIT #=   165 LV= 1 RT1
*MCALL #=   166 LV= 1          STX   1,LD1
         LA    15,LD1
         STD   1,0(15)
         STD   1+2,8(15)
*MEXIT #=   166 LV= 1 STX
*MCALL #=   167 LV= 1          CLCLD LD1,=LD'0'
*MCALL #=   168 LV= 2          LX    F0,LD1
         LA    15,LD1
         LD    F0,0(15)
         LD    F0+2,8(15)
*MEXIT #=   168 LV= 2 LX
*MCALL #=   169 LV= 2          LX    F1,=LD'0'
         LA    15,=LD'0'
         LD    F1,0(15)
         LD    F1+2,8(15)
*MEXIT #=   169 LV= 2 LX
         CXTR  F0,F1
*MEXIT #=   167 LV= 1 CLCLD
*MCALL #=   170 LV= 1          RT1   CCE
         DS    0H
RT1_TEST73       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE73
         LTORG 
RT1_CCE73       DS 0H
*MEXIT #=   170 LV= 1 RT1
*MCALL #=   171 LV= 1          LX    4,=LD'1'
         LA    15,=LD'1'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   171 LV= 1 LX
*MCALL #=   172 LV= 1          LX    5,=LD'-2'
         LA    15,=LD'-2'
         LD    5,0(15)
         LD    5+2,8(15)
*MEXIT #=   172 LV= 1 LX
         AXTR  1,4,5
*MCALL #=   173 LV= 1          RT1   CC1
         DS    0H
RT1_TEST74       BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL74
         LTORG 
RT1_CCL74       DS 0H
*MEXIT #=   173 LV= 1 RT1
*MCALL #=   174 LV= 1          STX   1,LD1
         LA    15,LD1
         STD   1,0(15)
         STD   1+2,8(15)
*MEXIT #=   174 LV= 1 STX
*MCALL #=   175 LV= 1          CLCLD LD1,=LD'-1'
*MCALL #=   176 LV= 2          LX    F0,LD1
         LA    15,LD1
         LD    F0,0(15)
         LD    F0+2,8(15)
*MEXIT #=   176 LV= 2 LX
*MCALL #=   177 LV= 2          LX    F1,=LD'-1'
         LA    15,=LD'-1'
         LD    F1,0(15)
         LD    F1+2,8(15)
*MEXIT #=   177 LV= 2 LX
         CXTR  F0,F1
*MEXIT #=   175 LV= 1 CLCLD
*MCALL #=   178 LV= 1          RT1   CCE
         DS    0H
RT1_TEST75       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE75
         LTORG 
RT1_CCE75       DS 0H
*MEXIT #=   178 LV= 1 RT1
*MCALL #=   179 LV= 1          ESPIE SET,ESPIE_EXIT,7,PARAM=AXTR1 DFP OX
               VERFLOW FPCDXC=20
        LA     15,AXTR1
        IPM    0  GET CURRENT PGM MASK
        SPM    0 TURN ON ANY MASKS REQUIRED
        L      0,=B'00000001000000000000000000000000'
        LA     1,ESPIE_EXIT
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   179 LV= 1 ESPIE
*MCALL #=   180 LV= 1          LX    R0,LDMAX
         LA    15,LDMAX
         LD    R0,0(15)
         LD    R0+2,8(15)
*MEXIT #=   180 LV= 1 LX
*MCALL #=   181 LV= 1          LX    R1,LDMAX
         LA    15,LDMAX
         LD    R1,0(15)
         LD    R1+2,8(15)
*MEXIT #=   181 LV= 1 LX
         AXTR  R0,R0,R1
*MCALL #=   182 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   182 LV= 1 RT1
*MCALL #=   183 LV= 1 AXTR1    ESPIE RESET
AXTR1    DS    0H
        SR     15,15
        SR     1,1
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   183 LV= 1 ESPIE
         STFPC FPCREG
         CLI   FPCDXC,X'20'
*MCALL #=   184 LV= 1          RT1   CCE
         DS    0H
RT1_TEST77       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE77
         LTORG 
RT1_CCE77       DS 0H
*MEXIT #=   184 LV= 1 RT1
*MCALL #=   185 LV= 1          WTO   'ESPIE DFP AXTR OVERFLOW OK'
         BRAS  1,*+(WTO#0185_EOT-*+1)/2*2
         DC    AL2(WTO#0185_EOT-*,0),C'ESPIE DFP AXTR OVERFLOW OK'
WTO#0185_EOT     EQU *
         SVC   35
*MEXIT #=   185 LV= 1 WTO
* B3DB SXTR
*MCALL #=   186 LV= 1          LX    4,=LD'1234567890123456789012345678X
               901234'
         LA    15,=LD'1234567890123456789012345678901234'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   186 LV= 1 LX
*MCALL #=   187 LV= 1          LX    5,=LD'1111111111111111111111111111X
               111111'
         LA    15,=LD'1111111111111111111111111111111111'
         LD    5,0(15)
         LD    5+2,8(15)
*MEXIT #=   187 LV= 1 LX
         SXTR  1,4,5
*MCALL #=   188 LV= 1          RT1   CC2
         DS    0H
RT1_TEST78       BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH78
         LTORG 
RT1_CCH78       DS 0H
*MEXIT #=   188 LV= 1 RT1
*MCALL #=   189 LV= 1          STX   1,LD1
         LA    15,LD1
         STD   1,0(15)
         STD   1+2,8(15)
*MEXIT #=   189 LV= 1 STX
*MCALL #=   190 LV= 1          CLCLD LD1,=LD'12345677901234567790123456X
               7790123'
*MCALL #=   191 LV= 2          LX    F0,LD1
         LA    15,LD1
         LD    F0,0(15)
         LD    F0+2,8(15)
*MEXIT #=   191 LV= 2 LX
*MCALL #=   192 LV= 2          LX    F1,=LD'123456779012345677901234567X
               790123'
         LA    15,=LD'123456779012345677901234567790123'
         LD    F1,0(15)
         LD    F1+2,8(15)
*MEXIT #=   192 LV= 2 LX
         CXTR  F0,F1
*MEXIT #=   190 LV= 1 CLCLD
*MCALL #=   193 LV= 1          RT1   CCE
         DS    0H
RT1_TEST79       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE79
         LTORG 
RT1_CCE79       DS 0H
*MEXIT #=   193 LV= 1 RT1
*MCALL #=   194 LV= 1          LX    4,=LD'1'
         LA    15,=LD'1'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   194 LV= 1 LX
*MCALL #=   195 LV= 1          LX    5,=LD'1'
         LA    15,=LD'1'
         LD    5,0(15)
         LD    5+2,8(15)
*MEXIT #=   195 LV= 1 LX
         SXTR  1,4,5
*MCALL #=   196 LV= 1          RT1   CC0
         DS    0H
RT1_TEST80       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE80
         LTORG 
RT1_CCE80       DS 0H
*MEXIT #=   196 LV= 1 RT1
*MCALL #=   197 LV= 1          STX   1,LD1
         LA    15,LD1
         STD   1,0(15)
         STD   1+2,8(15)
*MEXIT #=   197 LV= 1 STX
*MCALL #=   198 LV= 1          CLCLD LD1,=LD'0'
*MCALL #=   199 LV= 2          LX    F0,LD1
         LA    15,LD1
         LD    F0,0(15)
         LD    F0+2,8(15)
*MEXIT #=   199 LV= 2 LX
*MCALL #=   200 LV= 2          LX    F1,=LD'0'
         LA    15,=LD'0'
         LD    F1,0(15)
         LD    F1+2,8(15)
*MEXIT #=   200 LV= 2 LX
         CXTR  F0,F1
*MEXIT #=   198 LV= 1 CLCLD
*MCALL #=   201 LV= 1          RT1   CCE
         DS    0H
RT1_TEST81       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE81
         LTORG 
RT1_CCE81       DS 0H
*MEXIT #=   201 LV= 1 RT1
*MCALL #=   202 LV= 1          LX    4,=LD'0'
         LA    15,=LD'0'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   202 LV= 1 LX
*MCALL #=   203 LV= 1          LX    5,=LD'1'
         LA    15,=LD'1'
         LD    5,0(15)
         LD    5+2,8(15)
*MEXIT #=   203 LV= 1 LX
         SXTR  1,4,5
*MCALL #=   204 LV= 1          RT1   CC1
         DS    0H
RT1_TEST82       BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL82
         LTORG 
RT1_CCL82       DS 0H
*MEXIT #=   204 LV= 1 RT1
*MCALL #=   205 LV= 1          STX   1,LD1
         LA    15,LD1
         STD   1,0(15)
         STD   1+2,8(15)
*MEXIT #=   205 LV= 1 STX
*MCALL #=   206 LV= 1          CLCLD LD1,=LD'-1'
*MCALL #=   207 LV= 2          LX    F0,LD1
         LA    15,LD1
         LD    F0,0(15)
         LD    F0+2,8(15)
*MEXIT #=   207 LV= 2 LX
*MCALL #=   208 LV= 2          LX    F1,=LD'-1'
         LA    15,=LD'-1'
         LD    F1,0(15)
         LD    F1+2,8(15)
*MEXIT #=   208 LV= 2 LX
         CXTR  F0,F1
*MEXIT #=   206 LV= 1 CLCLD
*MCALL #=   209 LV= 1          RT1   CCE
         DS    0H
RT1_TEST83       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE83
         LTORG 
RT1_CCE83       DS 0H
*MEXIT #=   209 LV= 1 RT1
*MCALL #=   210 LV= 1          ESPIE SET,ESPIE_EXIT,7,PARAM=SXTR1 DFP UX
               NDERFLOW FPCDXC=10
        LA     15,SXTR1
        IPM    0  GET CURRENT PGM MASK
        SPM    0 TURN ON ANY MASKS REQUIRED
        L      0,=B'00000001000000000000000000000000'
        LA     1,ESPIE_EXIT
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   210 LV= 1 ESPIE
*MCALL #=   211 LV= 1          LX    R4,LDMIN
         LA    15,LDMIN
         LD    R4,0(15)
         LD    R4+2,8(15)
*MEXIT #=   211 LV= 1 LX
*MCALL #=   212 LV= 1          LX    R5,LDMIN
         LA    15,LDMIN
         LD    R5,0(15)
         LD    R5+2,8(15)
*MEXIT #=   212 LV= 1 LX
         AXTR  R4,R4,R5
         SXTR  R4,R4,R5
*MCALL #=   213 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   213 LV= 1 RT1
*MCALL #=   214 LV= 1 SXTR1    ESPIE RESET
SXTR1    DS    0H
        SR     15,15
        SR     1,1
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   214 LV= 1 ESPIE
         STFPC FPCREG
         CLI   FPCDXC,X'10'
*MCALL #=   215 LV= 1          RT1   CCE
         DS    0H
RT1_TEST85       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE85
         LTORG 
RT1_CCE85       DS 0H
*MEXIT #=   215 LV= 1 RT1
*MCALL #=   216 LV= 1          WTO   'ESPIE DFP SXTR UNDERFLOW OK'
         BRAS  1,*+(WTO#0216_EOT-*+1)/2*2
         DC    AL2(WTO#0216_EOT-*,0),C'ESPIE DFP SXTR UNDERFLOW OK'
WTO#0216_EOT     EQU *
         SVC   35
*MEXIT #=   216 LV= 1 WTO
* B3DC LXDTR
         LD    4,=DD'123'
         LXDTR 1,4,0
*MCALL #=   217 LV= 1          LX    5,=LD'123'
         LA    15,=LD'123'
         LD    5,0(15)
         LD    5+2,8(15)
*MEXIT #=   217 LV= 1 LX
         CXTR  1,5
*MCALL #=   218 LV= 1          RT1   CC0
         DS    0H
RT1_TEST86       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE86
         LTORG 
RT1_CCE86       DS 0H
*MEXIT #=   218 LV= 1 RT1
* B3DD LDXTR
*MCALL #=   219 LV= 1          LX    4,=LD'1234567890123456.5'
         LA    15,=LD'1234567890123456.5'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   219 LV= 1 LX
         LDXTR 1,0,4,0 DEFAULT NEAREST HALF EVEN
         LD    5,=DD'1234567890123456'
         CDTR  1,5
*MCALL #=   220 LV= 1          RT1   CC0
         DS    0H
RT1_TEST87       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE87
         LTORG 
RT1_CCE87       DS 0H
*MEXIT #=   220 LV= 1 RT1
*MCALL #=   221 LV= 1          LX    4,=LD'1234567890123457.5'
         LA    15,=LD'1234567890123457.5'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   221 LV= 1 LX
         LDXTR 1,0,4,0 DEFAULT NEAREST HALF EVEN
         LD    5,=DD'1234567890123458'
         CDTR  1,5
*MCALL #=   222 LV= 1          RT1   CC0
         DS    0H
RT1_TEST88       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE88
         LTORG 
RT1_CCE88       DS 0H
*MEXIT #=   222 LV= 1 RT1
*MCALL #=   223 LV= 1          LX    4,=LD'1234567890123456.5'
         LA    15,=LD'1234567890123456.5'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   223 LV= 1 LX
         LDXTR 1,8+1,4,0 ROUND TOWARD ZERO
         LD    5,=DD'1234567890123456'
         CDTR  1,5
*MCALL #=   224 LV= 1          RT1   CC0
         DS    0H
RT1_TEST89       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE89
         LTORG 
RT1_CCE89       DS 0H
*MEXIT #=   224 LV= 1 RT1
*MCALL #=   225 LV= 1          LX    4,=LD'1234567890123457.5'
         LA    15,=LD'1234567890123457.5'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   225 LV= 1 LX
         LDXTR 1,8+1,4,0 ROUND TOWARD ZERO
         LD    5,=DD'1234567890123457'
         CDTR  1,5
*MCALL #=   226 LV= 1          RT1   CC0
         DS    0H
RT1_TEST90       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE90
         LTORG 
RT1_CCE90       DS 0H
*MEXIT #=   226 LV= 1 RT1
* B3DF FIXTR
*MCALL #=   227 LV= 1          LX    4,=LD'123'
         LA    15,=LD'123'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   227 LV= 1 LX
         FIXTR 1,0,4,0
*MCALL #=   228 LV= 1          LX    5,=LD'123'
         LA    15,=LD'123'
         LD    5,0(15)
         LD    5+2,8(15)
*MEXIT #=   228 LV= 1 LX
         CXTR  1,5
*MCALL #=   229 LV= 1          RT1   CC0
         DS    0H
RT1_TEST91       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE91
         LTORG 
RT1_CCE91       DS 0H
*MEXIT #=   229 LV= 1 RT1
*MCALL #=   230 LV= 1          LX    4,=LD'1.5'
         LA    15,=LD'1.5'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   230 LV= 1 LX
         FIXTR 1,0,4,0
*MCALL #=   231 LV= 1          LX    5,=LD'2'
         LA    15,=LD'2'
         LD    5,0(15)
         LD    5+2,8(15)
*MEXIT #=   231 LV= 1 LX
         CXTR  1,5
*MCALL #=   232 LV= 1          RT1   CC0
         DS    0H
RT1_TEST92       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE92
         LTORG 
RT1_CCE92       DS 0H
*MEXIT #=   232 LV= 1 RT1
*MCALL #=   233 LV= 1          LX    4,=LD'1.5'
         LA    15,=LD'1.5'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   233 LV= 1 LX
         FIXTR 1,0,4,0
*MCALL #=   234 LV= 1          LX    5,=LD'2'
         LA    15,=LD'2'
         LD    5,0(15)
         LD    5+2,8(15)
*MEXIT #=   234 LV= 1 LX
         CXTR  1,5
*MCALL #=   235 LV= 1          RT1   CC0
         DS    0H
RT1_TEST93       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE93
         LTORG 
RT1_CCE93       DS 0H
*MEXIT #=   235 LV= 1 RT1
* B3E0 KDTR
         LD    1,=DD'1'
         LD    2,=DD'2'
         KDTR  1,2
*MCALL #=   236 LV= 1          RT1   CC1
         DS    0H
RT1_TEST94       BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL94
         LTORG 
RT1_CCL94       DS 0H
*MEXIT #=   236 LV= 1 RT1
         LD    1,=DD'1'
         LD    2,=DD'1'
         KDTR  1,2
*MCALL #=   237 LV= 1          RT1   CC0
         DS    0H
RT1_TEST95       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE95
         LTORG 
RT1_CCE95       DS 0H
*MEXIT #=   237 LV= 1 RT1
         LD    1,=DD'2'
         LD    2,=DD'1'
         KDTR  1,2
*MCALL #=   238 LV= 1          RT1   CC2
         DS    0H
RT1_TEST96       BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH96
         LTORG 
RT1_CCH96       DS 0H
*MEXIT #=   238 LV= 1 RT1
* B3DE LTXTR
*MCALL #=   239 LV= 1          LX    4,=LD'1'
         LA    15,=LD'1'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   239 LV= 1 LX
         LTXTR 1,4
*MCALL #=   240 LV= 1          RT1   CCH
         DS    0H
RT1_TEST97       BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH97
         LTORG 
RT1_CCH97       DS 0H
*MEXIT #=   240 LV= 1 RT1
         CXTR  1,4
*MCALL #=   241 LV= 1          RT1   CC0
         DS    0H
RT1_TEST98       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE98
         LTORG 
RT1_CCE98       DS 0H
*MEXIT #=   241 LV= 1 RT1
*MCALL #=   242 LV= 1          LX    4,=LD'0'
         LA    15,=LD'0'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   242 LV= 1 LX
         LTXTR 1,4
*MCALL #=   243 LV= 1          RT1   CC0
         DS    0H
RT1_TEST99       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE99
         LTORG 
RT1_CCE99       DS 0H
*MEXIT #=   243 LV= 1 RT1
         CXTR  1,4
*MCALL #=   244 LV= 1          RT1   CC0
         DS    0H
RT1_TEST100      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE100
         LTORG 
RT1_CCE100      DS 0H
*MEXIT #=   244 LV= 1 RT1
*MCALL #=   245 LV= 1          LX    4,=LD'-1'
         LA    15,=LD'-1'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   245 LV= 1 LX
         LTXTR 1,4
*MCALL #=   246 LV= 1          RT1   CC1
         DS    0H
RT1_TEST101      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL101
         LTORG 
RT1_CCL101      DS 0H
*MEXIT #=   246 LV= 1 RT1
         CXTR  1,4
*MCALL #=   247 LV= 1          RT1   CC0
         DS    0H
RT1_TEST102      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE102
         LTORG 
RT1_CCE102      DS 0H
*MEXIT #=   247 LV= 1 RT1
* B3E1 CGDTR
         LD    4,=DD'1234567890123456'
         CGDTR 1,0,4
*MCALL #=   248 LV= 1          RT1   CCH
         DS    0H
RT1_TEST103      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH103
         LTORG 
RT1_CCH103      DS 0H
*MEXIT #=   248 LV= 1 RT1
         CLG   1,=FD'1234567890123456'
*MCALL #=   249 LV= 1          RT1   CC0
         DS    0H
RT1_TEST104      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE104
         LTORG 
RT1_CCE104      DS 0H
*MEXIT #=   249 LV= 1 RT1
         LD    4,=DD'-1234567890123456'
         CGDTR 1,0,4
*MCALL #=   250 LV= 1          RT1   CCL
         DS    0H
RT1_TEST105      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL105
         LTORG 
RT1_CCL105      DS 0H
*MEXIT #=   250 LV= 1 RT1
         CLG   1,=FD'-1234567890123456'
*MCALL #=   251 LV= 1          RT1   CC0
         DS    0H
RT1_TEST106      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE106
         LTORG 
RT1_CCE106      DS 0H
*MEXIT #=   251 LV= 1 RT1
         LD    4,=DD'0'
         CGDTR 1,0,4
*MCALL #=   252 LV= 1          RT1   CC0
         DS    0H
RT1_TEST107      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE107
         LTORG 
RT1_CCE107      DS 0H
*MEXIT #=   252 LV= 1 RT1
         CLG   1,=FD'0'
*MCALL #=   253 LV= 1          RT1   CC0
         DS    0H
RT1_TEST108      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE108
         LTORG 
RT1_CCE108      DS 0H
*MEXIT #=   253 LV= 1 RT1
         LD    4,=DD'1.5'
         CGDTR 1,0,4
*MCALL #=   254 LV= 1          RT1   CCH
         DS    0H
RT1_TEST109      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH109
         LTORG 
RT1_CCH109      DS 0H
*MEXIT #=   254 LV= 1 RT1
         CLG   1,=FD'2'
*MCALL #=   255 LV= 1          RT1   CC0
         DS    0H
RT1_TEST110      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE110
         LTORG 
RT1_CCE110      DS 0H
*MEXIT #=   255 LV= 1 RT1
         LD    1,=DD'(MAX)'  RPI-791
         CGDTR 0,0,1
*MCALL #=   256 LV= 1          RT1   CC3
         DS    0H
RT1_TEST111      BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC3111
         LTORG 
RT1_CC3111      DS 0H
*MEXIT #=   256 LV= 1 RT1
* MORE THAN HALF
         LD    4,=DD'999.99'
         CGDTR 1,8+0,4          RPI-533 NEAREST, HALF EVEN DEFAULT
*MCALL #=   257 LV= 1          RT1   CCH
         DS    0H
RT1_TEST112      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH112
         LTORG 
RT1_CCH112      DS 0H
*MEXIT #=   257 LV= 1 RT1
         CLG   1,=FD'1000'
*MCALL #=   258 LV= 1          RT1   CC0
         DS    0H
RT1_TEST113      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE113
         LTORG 
RT1_CCE113      DS 0H
*MEXIT #=   258 LV= 1 RT1
         LD    4,=DD'999.99'
         CGDTR 1,8+1,4          RPI-533 NEAREST, HALF TOWARD ZERO
*MCALL #=   259 LV= 1          RT1   CCH
         DS    0H
RT1_TEST114      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH114
         LTORG 
RT1_CCH114      DS 0H
*MEXIT #=   259 LV= 1 RT1
         CLG   1,=FD'1000'
*MCALL #=   260 LV= 1          RT1   CC0
         DS    0H
RT1_TEST115      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE115
         LTORG 
RT1_CCE115      DS 0H
*MEXIT #=   260 LV= 1 RT1
         LD    4,=DD'999.99'
         CGDTR 1,8+2,4          RPI-533 TOWARD +INFINITY
*MCALL #=   261 LV= 1          RT1   CCH
         DS    0H
RT1_TEST116      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH116
         LTORG 
RT1_CCH116      DS 0H
*MEXIT #=   261 LV= 1 RT1
         CLG   1,=FD'1000'
*MCALL #=   262 LV= 1          RT1   CC0
         DS    0H
RT1_TEST117      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE117
         LTORG 
RT1_CCE117      DS 0H
*MEXIT #=   262 LV= 1 RT1
         LD    4,=DD'999.99'
         CGDTR 1,8+3,4          RPI-533 TOWARD -INFINITY
*MCALL #=   263 LV= 1          RT1   CCH
         DS    0H
RT1_TEST118      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH118
         LTORG 
RT1_CCH118      DS 0H
*MEXIT #=   263 LV= 1 RT1
         CLG   1,=FD'999'
*MCALL #=   264 LV= 1          RT1   CC0
         DS    0H
RT1_TEST119      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE119
         LTORG 
RT1_CCE119      DS 0H
*MEXIT #=   264 LV= 1 RT1
         LD    4,=DD'999.99'
         CGDTR 1,8+4,4          RPI-533 NEAREST, HALF AWAY FROM 0
*MCALL #=   265 LV= 1          RT1   CCH
         DS    0H
RT1_TEST120      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH120
         LTORG 
RT1_CCH120      DS 0H
*MEXIT #=   265 LV= 1 RT1
         CLG   1,=FD'1000'
*MCALL #=   266 LV= 1          RT1   CC0
         DS    0H
RT1_TEST121      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE121
         LTORG 
RT1_CCE121      DS 0H
*MEXIT #=   266 LV= 1 RT1
         LD    4,=DD'999.99'
         CGDTR 1,8+5,4          RPI-533 NEAREST, HALF TOWARD 0
*MCALL #=   267 LV= 1          RT1   CCH
         DS    0H
RT1_TEST122      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH122
         LTORG 
RT1_CCH122      DS 0H
*MEXIT #=   267 LV= 1 RT1
         CLG   1,=FD'1000'
*MCALL #=   268 LV= 1          RT1   CC0
         DS    0H
RT1_TEST123      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE123
         LTORG 
RT1_CCE123      DS 0H
*MEXIT #=   268 LV= 1 RT1
         LD    4,=DD'999.99'
         CGDTR 1,8+6,4          RPI-533 AWAY FROM ZERO
*MCALL #=   269 LV= 1          RT1   CCH
         DS    0H
RT1_TEST124      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH124
         LTORG 
RT1_CCH124      DS 0H
*MEXIT #=   269 LV= 1 RT1
         CLG   1,=FD'1000'
*MCALL #=   270 LV= 1          RT1   CC0
         DS    0H
RT1_TEST125      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE125
         LTORG 
RT1_CCE125      DS 0H
*MEXIT #=   270 LV= 1 RT1
* LESS THAN HALF
         LD    4,=DD'999.11'
         CGDTR 1,8+0,4          RPI-533 NEAREST, HALF EVEN DEFAULT
*MCALL #=   271 LV= 1          RT1   CCH
         DS    0H
RT1_TEST126      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH126
         LTORG 
RT1_CCH126      DS 0H
*MEXIT #=   271 LV= 1 RT1
         CLG   1,=FD'999'
*MCALL #=   272 LV= 1          RT1   CC0
         DS    0H
RT1_TEST127      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE127
         LTORG 
RT1_CCE127      DS 0H
*MEXIT #=   272 LV= 1 RT1
         LD    4,=DD'999.11'
         CGDTR 1,8+1,4          RPI-533 NEAREST, HALF TOWARD ZERO
*MCALL #=   273 LV= 1          RT1   CCH
         DS    0H
RT1_TEST128      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH128
         LTORG 
RT1_CCH128      DS 0H
*MEXIT #=   273 LV= 1 RT1
         CLG   1,=FD'999'
*MCALL #=   274 LV= 1          RT1   CC0
         DS    0H
RT1_TEST129      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE129
         LTORG 
RT1_CCE129      DS 0H
*MEXIT #=   274 LV= 1 RT1
         LD    4,=DD'999.11'
         CGDTR 1,8+2,4          RPI-533 TOWARD +INFINITY
*MCALL #=   275 LV= 1          RT1   CCH
         DS    0H
RT1_TEST130      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH130
         LTORG 
RT1_CCH130      DS 0H
*MEXIT #=   275 LV= 1 RT1
         CLG   1,=FD'1000'
*MCALL #=   276 LV= 1          RT1   CC0
         DS    0H
RT1_TEST131      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE131
         LTORG 
RT1_CCE131      DS 0H
*MEXIT #=   276 LV= 1 RT1
         LD    4,=DD'999.11'
         CGDTR 1,8+3,4          RPI-533 TOWARD -INFINITY
*MCALL #=   277 LV= 1          RT1   CCH
         DS    0H
RT1_TEST132      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH132
         LTORG 
RT1_CCH132      DS 0H
*MEXIT #=   277 LV= 1 RT1
         CLG   1,=FD'999'
*MCALL #=   278 LV= 1          RT1   CC0
         DS    0H
RT1_TEST133      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE133
         LTORG 
RT1_CCE133      DS 0H
*MEXIT #=   278 LV= 1 RT1
         LD    4,=DD'999.11'
         CGDTR 1,8+4,4          RPI-533 NEAREST, HALF AWAY FROM 0
*MCALL #=   279 LV= 1          RT1   CCH
         DS    0H
RT1_TEST134      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH134
         LTORG 
RT1_CCH134      DS 0H
*MEXIT #=   279 LV= 1 RT1
         CLG   1,=FD'999'
*MCALL #=   280 LV= 1          RT1   CC0
         DS    0H
RT1_TEST135      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE135
         LTORG 
RT1_CCE135      DS 0H
*MEXIT #=   280 LV= 1 RT1
         LD    4,=DD'999.11'
         CGDTR 1,8+5,4          RPI-533 NEAREST, HALF TOWARD 0
*MCALL #=   281 LV= 1          RT1   CCH
         DS    0H
RT1_TEST136      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH136
         LTORG 
RT1_CCH136      DS 0H
*MEXIT #=   281 LV= 1 RT1
         CLG   1,=FD'999'
*MCALL #=   282 LV= 1          RT1   CC0
         DS    0H
RT1_TEST137      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE137
         LTORG 
RT1_CCE137      DS 0H
*MEXIT #=   282 LV= 1 RT1
         LD    4,=DD'999.11'
         CGDTR 1,8+6,4          RPI-533 AWAY FROM ZERO
*MCALL #=   283 LV= 1          RT1   CCH
         DS    0H
RT1_TEST138      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH138
         LTORG 
RT1_CCH138      DS 0H
*MEXIT #=   283 LV= 1 RT1
         CLG   1,=FD'1000'
*MCALL #=   284 LV= 1          RT1   CC0
         DS    0H
RT1_TEST139      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE139
         LTORG 
RT1_CCE139      DS 0H
*MEXIT #=   284 LV= 1 RT1
* ODD HALF
         LD    4,=DD'999.5'
         CGDTR 1,8+0,4          RPI-533 NEAREST, HALF EVEN DEFAULT
*MCALL #=   285 LV= 1          RT1   CCH
         DS    0H
RT1_TEST140      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH140
         LTORG 
RT1_CCH140      DS 0H
*MEXIT #=   285 LV= 1 RT1
         CLG   1,=FD'1000'
*MCALL #=   286 LV= 1          RT1   CC0
         DS    0H
RT1_TEST141      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE141
         LTORG 
RT1_CCE141      DS 0H
*MEXIT #=   286 LV= 1 RT1
         LD    4,=DD'999.5'
         CGDTR 1,8+1,4          RPI-533 NEAREST, HALF TOWARD ZERO
*MCALL #=   287 LV= 1          RT1   CCH
         DS    0H
RT1_TEST142      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH142
         LTORG 
RT1_CCH142      DS 0H
*MEXIT #=   287 LV= 1 RT1
         CLG   1,=FD'999'
*MCALL #=   288 LV= 1          RT1   CC0
         DS    0H
RT1_TEST143      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE143
         LTORG 
RT1_CCE143      DS 0H
*MEXIT #=   288 LV= 1 RT1
         LD    4,=DD'999.5'
         CGDTR 1,8+2,4          RPI-533 TOWARD +INFINITY
*MCALL #=   289 LV= 1          RT1   CCH
         DS    0H
RT1_TEST144      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH144
         LTORG 
RT1_CCH144      DS 0H
*MEXIT #=   289 LV= 1 RT1
         CLG   1,=FD'1000'
*MCALL #=   290 LV= 1          RT1   CC0
         DS    0H
RT1_TEST145      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE145
         LTORG 
RT1_CCE145      DS 0H
*MEXIT #=   290 LV= 1 RT1
         LD    4,=DD'999.5'
         CGDTR 1,8+3,4          RPI-533 TOWARD -INFINITY
*MCALL #=   291 LV= 1          RT1   CCH
         DS    0H
RT1_TEST146      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH146
         LTORG 
RT1_CCH146      DS 0H
*MEXIT #=   291 LV= 1 RT1
         CLG   1,=FD'999'
*MCALL #=   292 LV= 1          RT1   CC0
         DS    0H
RT1_TEST147      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE147
         LTORG 
RT1_CCE147      DS 0H
*MEXIT #=   292 LV= 1 RT1
         LD    4,=DD'999.5'
         CGDTR 1,8+4,4          RPI-533 NEAREST, HALF AWAY FROM 0
*MCALL #=   293 LV= 1          RT1   CCH
         DS    0H
RT1_TEST148      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH148
         LTORG 
RT1_CCH148      DS 0H
*MEXIT #=   293 LV= 1 RT1
         CLG   1,=FD'1000'
*MCALL #=   294 LV= 1          RT1   CC0
         DS    0H
RT1_TEST149      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE149
         LTORG 
RT1_CCE149      DS 0H
*MEXIT #=   294 LV= 1 RT1
         LD    4,=DD'999.5'
         CGDTR 1,8+5,4          RPI-533 NEAREST, HALF TOWARD 0
*MCALL #=   295 LV= 1          RT1   CCH
         DS    0H
RT1_TEST150      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH150
         LTORG 
RT1_CCH150      DS 0H
*MEXIT #=   295 LV= 1 RT1
         CLG   1,=FD'999'
*MCALL #=   296 LV= 1          RT1   CC0
         DS    0H
RT1_TEST151      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE151
         LTORG 
RT1_CCE151      DS 0H
*MEXIT #=   296 LV= 1 RT1
         LD    4,=DD'999.5'
         CGDTR 1,8+6,4          RPI-533 AWAY FROM ZERO
*MCALL #=   297 LV= 1          RT1   CCH
         DS    0H
RT1_TEST152      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH152
         LTORG 
RT1_CCH152      DS 0H
*MEXIT #=   297 LV= 1 RT1
         CLG   1,=FD'1000'
*MCALL #=   298 LV= 1          RT1   CC0
         DS    0H
RT1_TEST153      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE153
         LTORG 
RT1_CCE153      DS 0H
*MEXIT #=   298 LV= 1 RT1
* EVEN HALF
         LD    4,=DD'998.5'
         CGDTR 1,8+0,4          RPI-533 NEAREST, HALF EVEN DEFAULT
*MCALL #=   299 LV= 1          RT1   CCH
         DS    0H
RT1_TEST154      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH154
         LTORG 
RT1_CCH154      DS 0H
*MEXIT #=   299 LV= 1 RT1
         CLG   1,=FD'998'
*MCALL #=   300 LV= 1          RT1   CC0
         DS    0H
RT1_TEST155      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE155
         LTORG 
RT1_CCE155      DS 0H
*MEXIT #=   300 LV= 1 RT1
         LD    4,=DD'998.5'
         CGDTR 1,8+1,4          RPI-533 NEAREST, HALF TOWARD ZERO
*MCALL #=   301 LV= 1          RT1   CCH
         DS    0H
RT1_TEST156      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH156
         LTORG 
RT1_CCH156      DS 0H
*MEXIT #=   301 LV= 1 RT1
         CLG   1,=FD'998'
*MCALL #=   302 LV= 1          RT1   CC0
         DS    0H
RT1_TEST157      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE157
         LTORG 
RT1_CCE157      DS 0H
*MEXIT #=   302 LV= 1 RT1
         LD    4,=DD'998.5'
         CGDTR 1,8+2,4          RPI-533 TOWARD +INFINITY
*MCALL #=   303 LV= 1          RT1   CCH
         DS    0H
RT1_TEST158      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH158
         LTORG 
RT1_CCH158      DS 0H
*MEXIT #=   303 LV= 1 RT1
         CLG   1,=FD'999'
*MCALL #=   304 LV= 1          RT1   CC0
         DS    0H
RT1_TEST159      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE159
         LTORG 
RT1_CCE159      DS 0H
*MEXIT #=   304 LV= 1 RT1
         LD    4,=DD'998.5'
         CGDTR 1,8+3,4          RPI-533 TOWARD -INFINITY
*MCALL #=   305 LV= 1          RT1   CCH
         DS    0H
RT1_TEST160      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH160
         LTORG 
RT1_CCH160      DS 0H
*MEXIT #=   305 LV= 1 RT1
         CLG   1,=FD'998'
*MCALL #=   306 LV= 1          RT1   CC0
         DS    0H
RT1_TEST161      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE161
         LTORG 
RT1_CCE161      DS 0H
*MEXIT #=   306 LV= 1 RT1
         LD    4,=DD'998.5'
         CGDTR 1,8+4,4          RPI-533 NEAREST, HALF AWAY FROM 0
*MCALL #=   307 LV= 1          RT1   CCH
         DS    0H
RT1_TEST162      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH162
         LTORG 
RT1_CCH162      DS 0H
*MEXIT #=   307 LV= 1 RT1
         CLG   1,=FD'999'
*MCALL #=   308 LV= 1          RT1   CC0
         DS    0H
RT1_TEST163      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE163
         LTORG 
RT1_CCE163      DS 0H
*MEXIT #=   308 LV= 1 RT1
         LD    4,=DD'998.5'
         CGDTR 1,8+5,4          RPI-533 NEAREST, HALF TOWARD 0
*MCALL #=   309 LV= 1          RT1   CCH
         DS    0H
RT1_TEST164      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH164
         LTORG 
RT1_CCH164      DS 0H
*MEXIT #=   309 LV= 1 RT1
         CLG   1,=FD'998'
*MCALL #=   310 LV= 1          RT1   CC0
         DS    0H
RT1_TEST165      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE165
         LTORG 
RT1_CCE165      DS 0H
*MEXIT #=   310 LV= 1 RT1
         LD    4,=DD'998.5'
         CGDTR 1,8+6,4          RPI-533 AWAY FROM ZERO
*MCALL #=   311 LV= 1          RT1   CCH
         DS    0H
RT1_TEST166      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH166
         LTORG 
RT1_CCH166      DS 0H
*MEXIT #=   311 LV= 1 RT1
         CLG   1,=FD'999'
*MCALL #=   312 LV= 1          RT1   CC0
         DS    0H
RT1_TEST167      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE167
         LTORG 
RT1_CCE167      DS 0H
*MEXIT #=   312 LV= 1 RT1
* B3E2 CUDTR
         LD    1,=DD'1'
         CUDTR 0,1
         CG    0,=XL8'1'                   RPI-790
*MCALL #=   313 LV= 1          RT1   CCE
         DS    0H
RT1_TEST168      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE168
         LTORG 
RT1_CCE168      DS 0H
*MEXIT #=   313 LV= 1 RT1
         LD    1,=DD'-1'
         CUDTR 0,1
         CG    0,=XL8'1'                   RPI-790
*MCALL #=   314 LV= 1          RT1   CCE
         DS    0H
RT1_TEST169      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE169
         LTORG 
RT1_CCE169      DS 0H
*MEXIT #=   314 LV= 1 RT1
         LD    1,=DD'1234567890123456'     RPI-786
         CUDTR 0,1
         CG    0,=XL8'1234567890123456'    RPI-786
*MCALL #=   315 LV= 1          RT1   CCE
         DS    0H
RT1_TEST170      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE170
         LTORG 
RT1_CCE170      DS 0H
*MEXIT #=   315 LV= 1 RT1
* B3E3 CSDTR
         LD    1,=DD'1'
         CSDTR 0,1,0
         CG    0,=PL8'1'                   RPI-790
*MCALL #=   316 LV= 1          RT1   CCE
         DS    0H
RT1_TEST171      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE171
         LTORG 
RT1_CCE171      DS 0H
*MEXIT #=   316 LV= 1 RT1
         CSDTR 0,1,1
         CG    0,=XL8'000000000000001F'    RPI-790
*MCALL #=   317 LV= 1          RT1   CCE
         DS    0H
RT1_TEST172      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE172
         LTORG 
RT1_CCE172      DS 0H
*MEXIT #=   317 LV= 1 RT1
         LD    1,=DD'-1'
         CSDTR 0,1,0
         CG    0,=PL8'-1'                  RPI-790
*MCALL #=   318 LV= 1          RT1   CCE
         DS    0H
RT1_TEST173      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE173
         LTORG 
RT1_CCE173      DS 0H
*MEXIT #=   318 LV= 1 RT1
         CSDTR 0,1,1
         CG    0,=XL8'000000000000001D'    RPI-790
*MCALL #=   319 LV= 1          RT1   CCE
         DS    0H
RT1_TEST174      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE174
         LTORG 
RT1_CCE174      DS 0H
*MEXIT #=   319 LV= 1 RT1
         LD    1,=DD'123456789012345'
         CSDTR 0,1,0
         CG    0,=PL8'123456789012345'
*MCALL #=   320 LV= 1          RT1   CCE
         DS    0H
RT1_TEST175      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE175
         LTORG 
RT1_CCE175      DS 0H
*MEXIT #=   320 LV= 1 RT1
         LD    1,=DD'-123456789012345'
         CSDTR 0,1,0
         CG    0,=PL8'-123456789012345'
*MCALL #=   321 LV= 1          RT1   CCE
         DS    0H
RT1_TEST176      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE176
         LTORG 
RT1_CCE176      DS 0H
*MEXIT #=   321 LV= 1 RT1
* B3E4 CDTR
         LD    1,=DD'1'
         LD    2,=DD'2'
         CDTR  1,2
*MCALL #=   322 LV= 1          RT1   CC1
         DS    0H
RT1_TEST177      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL177
         LTORG 
RT1_CCL177      DS 0H
*MEXIT #=   322 LV= 1 RT1
         LD    1,=DD'1'
         LD    2,=DD'1'
         CDTR  1,2
*MCALL #=   323 LV= 1          RT1   CC0
         DS    0H
RT1_TEST178      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE178
         LTORG 
RT1_CCE178      DS 0H
*MEXIT #=   323 LV= 1 RT1
         LD    1,=DD'2'
         LD    2,=DD'1'
         CDTR  1,2
*MCALL #=   324 LV= 1          RT1   CC2
         DS    0H
RT1_TEST179      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH179
         LTORG 
RT1_CCH179      DS 0H
*MEXIT #=   324 LV= 1 RT1
* B3E5 EEDTR
         LD    2,=DD'1'
         EEDTR 1,2
         CG    1,=FD'398'                  RPI-790
*MCALL #=   325 LV= 1          RT1   CC0
         DS    0H
RT1_TEST180      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE180
         LTORG 
RT1_CCE180      DS 0H
*MEXIT #=   325 LV= 1 RT1
         LD    2,=DD'1E1'
         EEDTR 1,2
         CG    1,=FD'399'                  RPI-790
*MCALL #=   326 LV= 1          RT1   CC0
         DS    0H
RT1_TEST181      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE181
         LTORG 
RT1_CCE181      DS 0H
*MEXIT #=   326 LV= 1 RT1
         LD    2,=DD'.1'
         EEDTR 1,2
         CG    1,=FD'397'                  RPI-790
*MCALL #=   327 LV= 1          RT1   CC0
         DS    0H
RT1_TEST182      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE182
         LTORG 
RT1_CCE182      DS 0H
*MEXIT #=   327 LV= 1 RT1
* B3E7 ESDTR
         LD    4,=DD'0'
         ESDTR 1,4
         CG    1,=FD'0'                    RPI-786
*MCALL #=   328 LV= 1          RT1   CC0
         DS    0H
RT1_TEST183      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE183
         LTORG 
RT1_CCE183      DS 0H
*MEXIT #=   328 LV= 1 RT1
         LD    4,=DD'1'
         ESDTR 1,4
         CG    1,=FD'1'
*MCALL #=   329 LV= 1          RT1   CC0
         DS    0H
RT1_TEST184      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE184
         LTORG 
RT1_CCE184      DS 0H
*MEXIT #=   329 LV= 1 RT1
         LD    4,=DD'-1'
         ESDTR 1,4
         CG    1,=FD'1'
*MCALL #=   330 LV= 1          RT1   CC0
         DS    0H
RT1_TEST185      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE185
         LTORG 
RT1_CCE185      DS 0H
*MEXIT #=   330 LV= 1 RT1
         LD    4,=DD'12'
         ESDTR 1,4
         CG    1,=FD'2'
*MCALL #=   331 LV= 1          RT1   CC0
         DS    0H
RT1_TEST186      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE186
         LTORG 
RT1_CCE186      DS 0H
*MEXIT #=   331 LV= 1 RT1
         LD    4,=DD'1234567890123456'
         ESDTR 1,4
         CG    1,=FD'16'
*MCALL #=   332 LV= 1          RT1   CC0
         DS    0H
RT1_TEST187      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE187
         LTORG 
RT1_CCE187      DS 0H
*MEXIT #=   332 LV= 1 RT1
         LD    0,=DD'1000000'
         LD    0,=XL8'2238000000100000'
         ESDTR 1,0
         CG    1,=FD'7'
*MCALL #=   333 LV= 1          RT1   CC0
         DS    0H
RT1_TEST188      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE188
         LTORG 
RT1_CCE188      DS 0H
*MEXIT #=   333 LV= 1 RT1
* B3E8 KXTR
*MCALL #=   334 LV= 1          LX    4,=LD'1'
         LA    15,=LD'1'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   334 LV= 1 LX
*MCALL #=   335 LV= 1          LX    5,=LD'2'
         LA    15,=LD'2'
         LD    5,0(15)
         LD    5+2,8(15)
*MEXIT #=   335 LV= 1 LX
         KXTR  4,5
*MCALL #=   336 LV= 1          RT1   CC1
         DS    0H
RT1_TEST189      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL189
         LTORG 
RT1_CCL189      DS 0H
*MEXIT #=   336 LV= 1 RT1
*MCALL #=   337 LV= 1          LX    4,=DD'1'
         LA    15,=DD'1'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   337 LV= 1 LX
*MCALL #=   338 LV= 1          LX    5,=DD'1'
         LA    15,=DD'1'
         LD    5,0(15)
         LD    5+2,8(15)
*MEXIT #=   338 LV= 1 LX
         KXTR  4,5
*MCALL #=   339 LV= 1          RT1   CC0
         DS    0H
RT1_TEST190      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE190
         LTORG 
RT1_CCE190      DS 0H
*MEXIT #=   339 LV= 1 RT1
*MCALL #=   340 LV= 1          LX    4,=DD'2'
         LA    15,=DD'2'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   340 LV= 1 LX
*MCALL #=   341 LV= 1          LX    5,=DD'1'
         LA    15,=DD'1'
         LD    5,0(15)
         LD    5+2,8(15)
*MEXIT #=   341 LV= 1 LX
         KXTR  4,5
*MCALL #=   342 LV= 1          RT1   CC2
         DS    0H
RT1_TEST191      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH191
         LTORG 
RT1_CCH191      DS 0H
*MEXIT #=   342 LV= 1 RT1
* B3E9 CGXTR
*MCALL #=   343 LV= 1          LX    4,=LD'123456789012345678'
         LA    15,=LD'123456789012345678'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   343 LV= 1 LX
         CGXTR 1,0,4
*MCALL #=   344 LV= 1          RT1   CCH
         DS    0H
RT1_TEST192      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH192
         LTORG 
RT1_CCH192      DS 0H
*MEXIT #=   344 LV= 1 RT1
         CLG   1,=FD'123456789012345678'
*MCALL #=   345 LV= 1          RT1   CC0
         DS    0H
RT1_TEST193      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE193
         LTORG 
RT1_CCE193      DS 0H
*MEXIT #=   345 LV= 1 RT1
*MCALL #=   346 LV= 1          LX    4,=LD'-123456789012345678'
         LA    15,=LD'-123456789012345678'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   346 LV= 1 LX
         CGXTR 1,0,4
*MCALL #=   347 LV= 1          RT1   CCL
         DS    0H
RT1_TEST194      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL194
         LTORG 
RT1_CCL194      DS 0H
*MEXIT #=   347 LV= 1 RT1
         CLG   1,=FD'-123456789012345678'
*MCALL #=   348 LV= 1          RT1   CC0
         DS    0H
RT1_TEST195      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE195
         LTORG 
RT1_CCE195      DS 0H
*MEXIT #=   348 LV= 1 RT1
*MCALL #=   349 LV= 1          LX    4,=LD'0'
         LA    15,=LD'0'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   349 LV= 1 LX
         CGXTR 1,0,4
*MCALL #=   350 LV= 1          RT1   CC0
         DS    0H
RT1_TEST196      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE196
         LTORG 
RT1_CCE196      DS 0H
*MEXIT #=   350 LV= 1 RT1
         CLG   1,=FD'0'
*MCALL #=   351 LV= 1          RT1   CC0
         DS    0H
RT1_TEST197      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE197
         LTORG 
RT1_CCE197      DS 0H
*MEXIT #=   351 LV= 1 RT1
*MCALL #=   352 LV= 1          LX    4,=LD'1.5'
         LA    15,=LD'1.5'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   352 LV= 1 LX
         CGXTR 1,0,4
*MCALL #=   353 LV= 1          RT1   CCH
         DS    0H
RT1_TEST198      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH198
         LTORG 
RT1_CCH198      DS 0H
*MEXIT #=   353 LV= 1 RT1
         CLG   1,=FD'2'
*MCALL #=   354 LV= 1          RT1   CC0
         DS    0H
RT1_TEST199      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE199
         LTORG 
RT1_CCE199      DS 0H
*MEXIT #=   354 LV= 1 RT1
*MCALL #=   355 LV= 1          LX    1,=LD'(MAX)'  RPI-791
         LA    15,=LD'(MAX)'
         LD    1,0(15)
         LD    1+2,8(15)
*MEXIT #=   355 LV= 1 LX
         CGDTR 0,0,1
*MCALL #=   356 LV= 1          RT1   CC3
         DS    0H
RT1_TEST200      BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC3200
         LTORG 
RT1_CC3200      DS 0H
*MEXIT #=   356 LV= 1 RT1
* MORE THAN HALF
*MCALL #=   357 LV= 1          LX    4,=LD'999.99'
         LA    15,=LD'999.99'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   357 LV= 1 LX
         CGXTR 1,8+0,4          RPI-533 NEAREST, HALF EVEN DEFAULT
*MCALL #=   358 LV= 1          RT1   CCH
         DS    0H
RT1_TEST201      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH201
         LTORG 
RT1_CCH201      DS 0H
*MEXIT #=   358 LV= 1 RT1
         CLG   1,=FD'1000'
*MCALL #=   359 LV= 1          RT1   CC0
         DS    0H
RT1_TEST202      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE202
         LTORG 
RT1_CCE202      DS 0H
*MEXIT #=   359 LV= 1 RT1
*MCALL #=   360 LV= 1          LX    4,=LD'999.99'
         LA    15,=LD'999.99'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   360 LV= 1 LX
         CGXTR 1,8+1,4          RPI-533 NEAREST, HALF TOWARD ZERO
*MCALL #=   361 LV= 1          RT1   CCH
         DS    0H
RT1_TEST203      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH203
         LTORG 
RT1_CCH203      DS 0H
*MEXIT #=   361 LV= 1 RT1
         CLG   1,=FD'1000'
*MCALL #=   362 LV= 1          RT1   CC0
         DS    0H
RT1_TEST204      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE204
         LTORG 
RT1_CCE204      DS 0H
*MEXIT #=   362 LV= 1 RT1
*MCALL #=   363 LV= 1          LX    4,=LD'999.99'
         LA    15,=LD'999.99'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   363 LV= 1 LX
         CGXTR 1,8+2,4          RPI-533 TOWARD +INFINITY
*MCALL #=   364 LV= 1          RT1   CCH
         DS    0H
RT1_TEST205      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH205
         LTORG 
RT1_CCH205      DS 0H
*MEXIT #=   364 LV= 1 RT1
         CLG   1,=FD'1000'
*MCALL #=   365 LV= 1          RT1   CC0
         DS    0H
RT1_TEST206      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE206
         LTORG 
RT1_CCE206      DS 0H
*MEXIT #=   365 LV= 1 RT1
*MCALL #=   366 LV= 1          LX    4,=LD'999.99'
         LA    15,=LD'999.99'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   366 LV= 1 LX
         CGXTR 1,8+3,4          RPI-533 TOWARD -INFINITY
*MCALL #=   367 LV= 1          RT1   CCH
         DS    0H
RT1_TEST207      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH207
         LTORG 
RT1_CCH207      DS 0H
*MEXIT #=   367 LV= 1 RT1
         CLG   1,=FD'999'
*MCALL #=   368 LV= 1          RT1   CC0
         DS    0H
RT1_TEST208      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE208
         LTORG 
RT1_CCE208      DS 0H
*MEXIT #=   368 LV= 1 RT1
*MCALL #=   369 LV= 1          LX    4,=LD'999.99'
         LA    15,=LD'999.99'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   369 LV= 1 LX
         CGXTR 1,8+4,4          RPI-533 NEAREST, HALF AWAY FROM 0
*MCALL #=   370 LV= 1          RT1   CCH
         DS    0H
RT1_TEST209      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH209
         LTORG 
RT1_CCH209      DS 0H
*MEXIT #=   370 LV= 1 RT1
         CLG   1,=FD'1000'
*MCALL #=   371 LV= 1          RT1   CC0
         DS    0H
RT1_TEST210      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE210
         LTORG 
RT1_CCE210      DS 0H
*MEXIT #=   371 LV= 1 RT1
*MCALL #=   372 LV= 1          LX    4,=LD'999.99'
         LA    15,=LD'999.99'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   372 LV= 1 LX
         CGXTR 1,8+5,4          RPI-533 NEAREST, HALF TOWARD 0
*MCALL #=   373 LV= 1          RT1   CCH
         DS    0H
RT1_TEST211      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH211
         LTORG 
RT1_CCH211      DS 0H
*MEXIT #=   373 LV= 1 RT1
         CLG   1,=FD'1000'
*MCALL #=   374 LV= 1          RT1   CC0
         DS    0H
RT1_TEST212      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE212
         LTORG 
RT1_CCE212      DS 0H
*MEXIT #=   374 LV= 1 RT1
*MCALL #=   375 LV= 1          LX    4,=LD'999.99'
         LA    15,=LD'999.99'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   375 LV= 1 LX
         CGXTR 1,8+6,4          RPI-533 AWAY FROM ZERO
*MCALL #=   376 LV= 1          RT1   CCH
         DS    0H
RT1_TEST213      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH213
         LTORG 
RT1_CCH213      DS 0H
*MEXIT #=   376 LV= 1 RT1
         CLG   1,=FD'1000'
*MCALL #=   377 LV= 1          RT1   CC0
         DS    0H
RT1_TEST214      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE214
         LTORG 
RT1_CCE214      DS 0H
*MEXIT #=   377 LV= 1 RT1
* LESS THAN HALF
*MCALL #=   378 LV= 1          LX    4,=LD'999.11'
         LA    15,=LD'999.11'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   378 LV= 1 LX
         CGXTR 1,8+0,4          RPI-533 NEAREST, HALF EVEN DEFAULT
*MCALL #=   379 LV= 1          RT1   CCH
         DS    0H
RT1_TEST215      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH215
         LTORG 
RT1_CCH215      DS 0H
*MEXIT #=   379 LV= 1 RT1
         CLG   1,=FD'999'
*MCALL #=   380 LV= 1          RT1   CC0
         DS    0H
RT1_TEST216      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE216
         LTORG 
RT1_CCE216      DS 0H
*MEXIT #=   380 LV= 1 RT1
*MCALL #=   381 LV= 1          LX    4,=LD'999.11'
         LA    15,=LD'999.11'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   381 LV= 1 LX
         CGXTR 1,8+1,4          RPI-533 NEAREST, HALF TOWARD ZERO
*MCALL #=   382 LV= 1          RT1   CCH
         DS    0H
RT1_TEST217      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH217
         LTORG 
RT1_CCH217      DS 0H
*MEXIT #=   382 LV= 1 RT1
         CLG   1,=FD'999'
*MCALL #=   383 LV= 1          RT1   CC0
         DS    0H
RT1_TEST218      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE218
         LTORG 
RT1_CCE218      DS 0H
*MEXIT #=   383 LV= 1 RT1
*MCALL #=   384 LV= 1          LX    4,=LD'999.11'
         LA    15,=LD'999.11'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   384 LV= 1 LX
         CGXTR 1,8+2,4          RPI-533 TOWARD +INFINITY
*MCALL #=   385 LV= 1          RT1   CCH
         DS    0H
RT1_TEST219      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH219
         LTORG 
RT1_CCH219      DS 0H
*MEXIT #=   385 LV= 1 RT1
         CLG   1,=FD'1000'
*MCALL #=   386 LV= 1          RT1   CC0
         DS    0H
RT1_TEST220      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE220
         LTORG 
RT1_CCE220      DS 0H
*MEXIT #=   386 LV= 1 RT1
*MCALL #=   387 LV= 1          LX    4,=LD'999.11'
         LA    15,=LD'999.11'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   387 LV= 1 LX
         CGXTR 1,8+3,4          RPI-533 TOWARD -INFINITY
*MCALL #=   388 LV= 1          RT1   CCH
         DS    0H
RT1_TEST221      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH221
         LTORG 
RT1_CCH221      DS 0H
*MEXIT #=   388 LV= 1 RT1
         CLG   1,=FD'999'
*MCALL #=   389 LV= 1          RT1   CC0
         DS    0H
RT1_TEST222      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE222
         LTORG 
RT1_CCE222      DS 0H
*MEXIT #=   389 LV= 1 RT1
*MCALL #=   390 LV= 1          LX    4,=LD'999.11'
         LA    15,=LD'999.11'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   390 LV= 1 LX
         CGXTR 1,8+4,4          RPI-533 NEAREST, HALF AWAY FROM 0
*MCALL #=   391 LV= 1          RT1   CCH
         DS    0H
RT1_TEST223      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH223
         LTORG 
RT1_CCH223      DS 0H
*MEXIT #=   391 LV= 1 RT1
         CLG   1,=FD'999'
*MCALL #=   392 LV= 1          RT1   CC0
         DS    0H
RT1_TEST224      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE224
         LTORG 
RT1_CCE224      DS 0H
*MEXIT #=   392 LV= 1 RT1
*MCALL #=   393 LV= 1          LX    4,=LD'999.11'
         LA    15,=LD'999.11'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   393 LV= 1 LX
         CGXTR 1,8+5,4          RPI-533 NEAREST, HALF TOWARD 0
*MCALL #=   394 LV= 1          RT1   CCH
         DS    0H
RT1_TEST225      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH225
         LTORG 
RT1_CCH225      DS 0H
*MEXIT #=   394 LV= 1 RT1
         CLG   1,=FD'999'
*MCALL #=   395 LV= 1          RT1   CC0
         DS    0H
RT1_TEST226      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE226
         LTORG 
RT1_CCE226      DS 0H
*MEXIT #=   395 LV= 1 RT1
*MCALL #=   396 LV= 1          LX    4,=LD'999.11'
         LA    15,=LD'999.11'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   396 LV= 1 LX
         CGXTR 1,8+6,4          RPI-533 AWAY FROM ZERO
*MCALL #=   397 LV= 1          RT1   CCH
         DS    0H
RT1_TEST227      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH227
         LTORG 
RT1_CCH227      DS 0H
*MEXIT #=   397 LV= 1 RT1
         CLG   1,=FD'1000'
*MCALL #=   398 LV= 1          RT1   CC0
         DS    0H
RT1_TEST228      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE228
         LTORG 
RT1_CCE228      DS 0H
*MEXIT #=   398 LV= 1 RT1
* ODD HALF
*MCALL #=   399 LV= 1          LX    4,=LD'999.5'
         LA    15,=LD'999.5'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   399 LV= 1 LX
         CGXTR 1,8+0,4          RPI-533 NEAREST, HALF EVEN DEFAULT
*MCALL #=   400 LV= 1          RT1   CCH
         DS    0H
RT1_TEST229      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH229
         LTORG 
RT1_CCH229      DS 0H
*MEXIT #=   400 LV= 1 RT1
         CLG   1,=FD'1000'
*MCALL #=   401 LV= 1          RT1   CC0
         DS    0H
RT1_TEST230      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE230
         LTORG 
RT1_CCE230      DS 0H
*MEXIT #=   401 LV= 1 RT1
*MCALL #=   402 LV= 1          LX    4,=LD'999.5'
         LA    15,=LD'999.5'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   402 LV= 1 LX
         CGXTR 1,8+1,4          RPI-533 NEAREST, HALF TOWARD ZERO
*MCALL #=   403 LV= 1          RT1   CCH
         DS    0H
RT1_TEST231      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH231
         LTORG 
RT1_CCH231      DS 0H
*MEXIT #=   403 LV= 1 RT1
         CLG   1,=FD'999'
*MCALL #=   404 LV= 1          RT1   CC0
         DS    0H
RT1_TEST232      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE232
         LTORG 
RT1_CCE232      DS 0H
*MEXIT #=   404 LV= 1 RT1
*MCALL #=   405 LV= 1          LX    4,=LD'999.5'
         LA    15,=LD'999.5'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   405 LV= 1 LX
         CGXTR 1,8+2,4          RPI-533 TOWARD +INFINITY
*MCALL #=   406 LV= 1          RT1   CCH
         DS    0H
RT1_TEST233      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH233
         LTORG 
RT1_CCH233      DS 0H
*MEXIT #=   406 LV= 1 RT1
         CLG   1,=FD'1000'
*MCALL #=   407 LV= 1          RT1   CC0
         DS    0H
RT1_TEST234      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE234
         LTORG 
RT1_CCE234      DS 0H
*MEXIT #=   407 LV= 1 RT1
*MCALL #=   408 LV= 1          LX    4,=LD'999.5'
         LA    15,=LD'999.5'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   408 LV= 1 LX
         CGXTR 1,8+3,4          RPI-533 TOWARD -INFINITY
*MCALL #=   409 LV= 1          RT1   CCH
         DS    0H
RT1_TEST235      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH235
         LTORG 
RT1_CCH235      DS 0H
*MEXIT #=   409 LV= 1 RT1
         CLG   1,=FD'999'
*MCALL #=   410 LV= 1          RT1   CC0
         DS    0H
RT1_TEST236      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE236
         LTORG 
RT1_CCE236      DS 0H
*MEXIT #=   410 LV= 1 RT1
*MCALL #=   411 LV= 1          LX    4,=LD'999.5'
         LA    15,=LD'999.5'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   411 LV= 1 LX
         CGXTR 1,8+4,4          RPI-533 NEAREST, HALF AWAY FROM 0
*MCALL #=   412 LV= 1          RT1   CCH
         DS    0H
RT1_TEST237      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH237
         LTORG 
RT1_CCH237      DS 0H
*MEXIT #=   412 LV= 1 RT1
         CLG   1,=FD'1000'
*MCALL #=   413 LV= 1          RT1   CC0
         DS    0H
RT1_TEST238      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE238
         LTORG 
RT1_CCE238      DS 0H
*MEXIT #=   413 LV= 1 RT1
*MCALL #=   414 LV= 1          LX    4,=LD'999.5'
         LA    15,=LD'999.5'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   414 LV= 1 LX
         CGXTR 1,8+5,4          RPI-533 NEAREST, HALF TOWARD 0
*MCALL #=   415 LV= 1          RT1   CCH
         DS    0H
RT1_TEST239      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH239
         LTORG 
RT1_CCH239      DS 0H
*MEXIT #=   415 LV= 1 RT1
         CLG   1,=FD'999'
*MCALL #=   416 LV= 1          RT1   CC0
         DS    0H
RT1_TEST240      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE240
         LTORG 
RT1_CCE240      DS 0H
*MEXIT #=   416 LV= 1 RT1
*MCALL #=   417 LV= 1          LX    4,=LD'999.5'
         LA    15,=LD'999.5'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   417 LV= 1 LX
         CGXTR 1,8+6,4          RPI-533 AWAY FROM ZERO
*MCALL #=   418 LV= 1          RT1   CCH
         DS    0H
RT1_TEST241      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH241
         LTORG 
RT1_CCH241      DS 0H
*MEXIT #=   418 LV= 1 RT1
         CLG   1,=FD'1000'
*MCALL #=   419 LV= 1          RT1   CC0
         DS    0H
RT1_TEST242      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE242
         LTORG 
RT1_CCE242      DS 0H
*MEXIT #=   419 LV= 1 RT1
* EVEN HALF
         LD    4,=DD'998.5'
         CGDTR 1,8+0,4          RPI-533 NEAREST, HALF EVEN DEFAULT
*MCALL #=   420 LV= 1          RT1   CCH
         DS    0H
RT1_TEST243      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH243
         LTORG 
RT1_CCH243      DS 0H
*MEXIT #=   420 LV= 1 RT1
         CLG   1,=FD'998'
*MCALL #=   421 LV= 1          RT1   CC0
         DS    0H
RT1_TEST244      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE244
         LTORG 
RT1_CCE244      DS 0H
*MEXIT #=   421 LV= 1 RT1
         LD    4,=DD'998.5'
         CGDTR 1,8+1,4          RPI-533 NEAREST, HALF TOWARD ZERO
*MCALL #=   422 LV= 1          RT1   CCH
         DS    0H
RT1_TEST245      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH245
         LTORG 
RT1_CCH245      DS 0H
*MEXIT #=   422 LV= 1 RT1
         CLG   1,=FD'998'
*MCALL #=   423 LV= 1          RT1   CC0
         DS    0H
RT1_TEST246      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE246
         LTORG 
RT1_CCE246      DS 0H
*MEXIT #=   423 LV= 1 RT1
         LD    4,=DD'998.5'
         CGDTR 1,8+2,4          RPI-533 TOWARD +INFINITY
*MCALL #=   424 LV= 1          RT1   CCH
         DS    0H
RT1_TEST247      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH247
         LTORG 
RT1_CCH247      DS 0H
*MEXIT #=   424 LV= 1 RT1
         CLG   1,=FD'999'
*MCALL #=   425 LV= 1          RT1   CC0
         DS    0H
RT1_TEST248      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE248
         LTORG 
RT1_CCE248      DS 0H
*MEXIT #=   425 LV= 1 RT1
         LD    4,=DD'998.5'
         CGDTR 1,8+3,4          RPI-533 TOWARD -INFINITY
*MCALL #=   426 LV= 1          RT1   CCH
         DS    0H
RT1_TEST249      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH249
         LTORG 
RT1_CCH249      DS 0H
*MEXIT #=   426 LV= 1 RT1
         CLG   1,=FD'998'
*MCALL #=   427 LV= 1          RT1   CC0
         DS    0H
RT1_TEST250      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE250
         LTORG 
RT1_CCE250      DS 0H
*MEXIT #=   427 LV= 1 RT1
         LD    4,=DD'998.5'
         CGDTR 1,8+4,4          RPI-533 NEAREST, HALF AWAY FROM 0
*MCALL #=   428 LV= 1          RT1   CCH
         DS    0H
RT1_TEST251      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH251
         LTORG 
RT1_CCH251      DS 0H
*MEXIT #=   428 LV= 1 RT1
         CLG   1,=FD'999'
*MCALL #=   429 LV= 1          RT1   CC0
         DS    0H
RT1_TEST252      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE252
         LTORG 
RT1_CCE252      DS 0H
*MEXIT #=   429 LV= 1 RT1
         LD    4,=DD'998.5'
         CGDTR 1,8+5,4          RPI-533 NEAREST, HALF TOWARD 0
*MCALL #=   430 LV= 1          RT1   CCH
         DS    0H
RT1_TEST253      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH253
         LTORG 
RT1_CCH253      DS 0H
*MEXIT #=   430 LV= 1 RT1
         CLG   1,=FD'998'
*MCALL #=   431 LV= 1          RT1   CC0
         DS    0H
RT1_TEST254      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE254
         LTORG 
RT1_CCE254      DS 0H
*MEXIT #=   431 LV= 1 RT1
         LD    4,=DD'998.5'
         CGDTR 1,8+6,4          RPI-533 AWAY FROM ZERO
*MCALL #=   432 LV= 1          RT1   CCH
         DS    0H
RT1_TEST255      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH255
         LTORG 
RT1_CCH255      DS 0H
*MEXIT #=   432 LV= 1 RT1
         CLG   1,=FD'999'
*MCALL #=   433 LV= 1          RT1   CC0
         DS    0H
RT1_TEST256      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE256
         LTORG 
RT1_CCE256      DS 0H
*MEXIT #=   433 LV= 1 RT1
* B3EA CUXTR
*MCALL #=   434 LV= 1          LX    1,=LD'1'
         LA    15,=LD'1'
         LD    1,0(15)
         LD    1+2,8(15)
*MEXIT #=   434 LV= 1 LX
         CUXTR 0,1
         CG    0,=XL8'0'
*MCALL #=   435 LV= 1          RT1   CCE
         DS    0H
RT1_TEST257      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE257
         LTORG 
RT1_CCE257      DS 0H
*MEXIT #=   435 LV= 1 RT1
         CG    1,=XL8'1'             RPI-790
*MCALL #=   436 LV= 1          RT1   CCE
         DS    0H
RT1_TEST258      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE258
         LTORG 
RT1_CCE258      DS 0H
*MEXIT #=   436 LV= 1 RT1
*MCALL #=   437 LV= 1          LX    1,=LD'-1'
         LA    15,=LD'-1'
         LD    1,0(15)
         LD    1+2,8(15)
*MEXIT #=   437 LV= 1 LX
         CUXTR 0,1
         CG    0,=XL8'0'
*MCALL #=   438 LV= 1          RT1   CCE
         DS    0H
RT1_TEST259      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE259
         LTORG 
RT1_CCE259      DS 0H
*MEXIT #=   438 LV= 1 RT1
         CG    1,=XL8'1'             RPI-790
*MCALL #=   439 LV= 1          RT1   CCE
         DS    0H
RT1_TEST260      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE260
         LTORG 
RT1_CCE260      DS 0H
*MEXIT #=   439 LV= 1 RT1
*MCALL #=   440 LV= 1          LX    1,=LD'1234567890123456789012345678X
               901234'    RPI-788
         LA    15,=LD'1234567890123456789012345678901234'
         LD    1,0(15)
         LD    1+2,8(15)
*MEXIT #=   440 LV= 1 LX
         CUXTR 0,1
         STMG  0,1,WORK
         CLC   WORK,=XL16'34567890123456789012345678901234' RPI-788
*MCALL #=   441 LV= 1          RT1   CCE
         DS    0H
RT1_TEST261      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE261
         LTORG 
RT1_CCE261      DS 0H
*MEXIT #=   441 LV= 1 RT1
* B3EB CSXTR
*MCALL #=   442 LV= 1          LX    1,=LD'1'
         LA    15,=LD'1'
         LD    1,0(15)
         LD    1+2,8(15)
*MEXIT #=   442 LV= 1 LX
         CSXTR 0,1,0
         CG    0,=FL8'0'
*MCALL #=   443 LV= 1          RT1   CCE
         DS    0H
RT1_TEST262      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE262
         LTORG 
RT1_CCE262      DS 0H
*MEXIT #=   443 LV= 1 RT1
         CG    1,=PL8'1'                RPI-790
*MCALL #=   444 LV= 1          RT1   CCE
         DS    0H
RT1_TEST263      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE263
         LTORG 
RT1_CCE263      DS 0H
*MEXIT #=   444 LV= 1 RT1
         CSXTR 0,1,1
         CG    0,=FL8'0'
*MCALL #=   445 LV= 1          RT1   CCE
         DS    0H
RT1_TEST264      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE264
         LTORG 
RT1_CCE264      DS 0H
*MEXIT #=   445 LV= 1 RT1
         CG    1,=XL8'000000000000001F' RPI-790
*MCALL #=   446 LV= 1          RT1   CCE
         DS    0H
RT1_TEST265      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE265
         LTORG 
RT1_CCE265      DS 0H
*MEXIT #=   446 LV= 1 RT1
*MCALL #=   447 LV= 1          LX    1,=LD'-1'
         LA    15,=LD'-1'
         LD    1,0(15)
         LD    1+2,8(15)
*MEXIT #=   447 LV= 1 LX
         CSXTR 0,1,0
         CG    0,=FL8'0'
*MCALL #=   448 LV= 1          RT1   CCE
         DS    0H
RT1_TEST266      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE266
         LTORG 
RT1_CCE266      DS 0H
*MEXIT #=   448 LV= 1 RT1
         CG    1,=PL8'-1'               RPI-790
*MCALL #=   449 LV= 1          RT1   CCE
         DS    0H
RT1_TEST267      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE267
         LTORG 
RT1_CCE267      DS 0H
*MEXIT #=   449 LV= 1 RT1
         CSXTR 0,1,1
         CG    0,=FL8'0'
*MCALL #=   450 LV= 1          RT1   CCE
         DS    0H
RT1_TEST268      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE268
         LTORG 
RT1_CCE268      DS 0H
*MEXIT #=   450 LV= 1 RT1
         CG    1,=XL8'000000000000001D' RPI-790
*MCALL #=   451 LV= 1          RT1   CCE
         DS    0H
RT1_TEST269      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE269
         LTORG 
RT1_CCE269      DS 0H
*MEXIT #=   451 LV= 1 RT1
*MCALL #=   452 LV= 1          LX    1,=LD'1234567890123456789012345678X
               901234'   RPI-788
         LA    15,=LD'1234567890123456789012345678901234'
         LD    1,0(15)
         LD    1+2,8(15)
*MEXIT #=   452 LV= 1 LX
         CSXTR 0,1,0
         STMG  0,1,PL16
         CP    PL16,=PL16'4567890123456789012345678901234' RPI-788
*MCALL #=   453 LV= 1          RT1   CCE
         DS    0H
RT1_TEST270      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE270
         LTORG 
RT1_CCE270      DS 0H
*MEXIT #=   453 LV= 1 RT1
* B3ED EEXTR
*MCALL #=   454 LV= 1          LX    4,=LD'1'
         LA    15,=LD'1'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   454 LV= 1 LX
         EEXTR 1,4
         CG    1,=FD'6176'   RPI-790
*MCALL #=   455 LV= 1          RT1   CC0
         DS    0H
RT1_TEST271      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE271
         LTORG 
RT1_CCE271      DS 0H
*MEXIT #=   455 LV= 1 RT1
*MCALL #=   456 LV= 1          LX    4,=LD'1E1'
         LA    15,=LD'1E1'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   456 LV= 1 LX
         EEXTR 1,4
         CG    1,=FD'6177'   RPI-790
*MCALL #=   457 LV= 1          RT1   CC0
         DS    0H
RT1_TEST272      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE272
         LTORG 
RT1_CCE272      DS 0H
*MEXIT #=   457 LV= 1 RT1
*MCALL #=   458 LV= 1          LX    4,=LD'.1'
         LA    15,=LD'.1'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   458 LV= 1 LX
         EEXTR 1,4
         CG    1,=FD'6175'   RPI-790
*MCALL #=   459 LV= 1          RT1   CC0
         DS    0H
RT1_TEST273      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE273
         LTORG 
RT1_CCE273      DS 0H
*MEXIT #=   459 LV= 1 RT1
* B3EC CXTR
*MCALL #=   460 LV= 1          LX    4,=LD'1'
         LA    15,=LD'1'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   460 LV= 1 LX
*MCALL #=   461 LV= 1          LX    5,=LD'2'
         LA    15,=LD'2'
         LD    5,0(15)
         LD    5+2,8(15)
*MEXIT #=   461 LV= 1 LX
         CXTR  4,5
*MCALL #=   462 LV= 1          RT1   CC1
         DS    0H
RT1_TEST274      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL274
         LTORG 
RT1_CCL274      DS 0H
*MEXIT #=   462 LV= 1 RT1
*MCALL #=   463 LV= 1          LX    4,=DD'1'
         LA    15,=DD'1'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   463 LV= 1 LX
*MCALL #=   464 LV= 1          LX    5,=DD'1'
         LA    15,=DD'1'
         LD    5,0(15)
         LD    5+2,8(15)
*MEXIT #=   464 LV= 1 LX
         CXTR  4,5
*MCALL #=   465 LV= 1          RT1   CC0
         DS    0H
RT1_TEST275      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE275
         LTORG 
RT1_CCE275      DS 0H
*MEXIT #=   465 LV= 1 RT1
*MCALL #=   466 LV= 1          LX    4,=LD'2'
         LA    15,=LD'2'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   466 LV= 1 LX
*MCALL #=   467 LV= 1          LX    5,=LD'1'
         LA    15,=LD'1'
         LD    5,0(15)
         LD    5+2,8(15)
*MEXIT #=   467 LV= 1 LX
         CXTR  4,5
*MCALL #=   468 LV= 1          RT1   CC2
         DS    0H
RT1_TEST276      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH276
         LTORG 
RT1_CCH276      DS 0H
*MEXIT #=   468 LV= 1 RT1
* B3EF ESXTR
*MCALL #=   469 LV= 1          LX    4,=LD'0'
         LA    15,=LD'0'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   469 LV= 1 LX
         ESXTR 1,4
         CG    1,=FD'0'     RPI-787
*MCALL #=   470 LV= 1          RT1   CC0
         DS    0H
RT1_TEST277      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE277
         LTORG 
RT1_CCE277      DS 0H
*MEXIT #=   470 LV= 1 RT1
*MCALL #=   471 LV= 1          LX    4,=LD'1'
         LA    15,=LD'1'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   471 LV= 1 LX
         ESXTR 1,4
         CG    1,=FD'1'
*MCALL #=   472 LV= 1          RT1   CC0
         DS    0H
RT1_TEST278      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE278
         LTORG 
RT1_CCE278      DS 0H
*MEXIT #=   472 LV= 1 RT1
*MCALL #=   473 LV= 1          LX    4,=LD'-1'
         LA    15,=LD'-1'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   473 LV= 1 LX
         ESXTR 1,4
         CG    1,=FD'1'
*MCALL #=   474 LV= 1          RT1   CC0
         DS    0H
RT1_TEST279      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE279
         LTORG 
RT1_CCE279      DS 0H
*MEXIT #=   474 LV= 1 RT1
*MCALL #=   475 LV= 1          LX    4,=LD'12'
         LA    15,=LD'12'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   475 LV= 1 LX
         ESXTR 1,4
         CG    1,=FD'2'
*MCALL #=   476 LV= 1          RT1   CC0
         DS    0H
RT1_TEST280      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE280
         LTORG 
RT1_CCE280      DS 0H
*MEXIT #=   476 LV= 1 RT1
*MCALL #=   477 LV= 1          LX    4,=LD'1234567890123456789012345678X
               901234'
         LA    15,=LD'1234567890123456789012345678901234'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   477 LV= 1 LX
         ESXTR 1,4
         CG    1,=FD'34'
*MCALL #=   478 LV= 1          RT1   CC0
         DS    0H
RT1_TEST281      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE281
         LTORG 
RT1_CCE281      DS 0H
*MEXIT #=   478 LV= 1 RT1
* B3F1 CDGTR
         LG    2,=FD'1234567890123456'
         CDGTR 1,2 CVT G TO DD
         LD    4,=DD'1234567890123456'
         CDTR  1,4
*MCALL #=   479 LV= 1          RT1   CC0
         DS    0H
RT1_TEST282      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE282
         LTORG 
RT1_CCE282      DS 0H
*MEXIT #=   479 LV= 1 RT1
* B3F2 CDUTR
         LG    2,=XL8'1234567890123456'
         CDUTR 1,2
         LD    4,=DD'1234567890123456'
         CDTR  1,4
*MCALL #=   480 LV= 1          RT1   CC0
         DS    0H
RT1_TEST283      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE283
         LTORG 
RT1_CCE283      DS 0H
*MEXIT #=   480 LV= 1 RT1
* B3F3 CDSTR
         LG    2,=PL8'123456789012345'
         CDSTR 1,2
         LD    4,=DD'123456789012345'
         CDTR  1,4
*MCALL #=   481 LV= 1          RT1   CC0
         DS    0H
RT1_TEST284      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE284
         LTORG 
RT1_CCE284      DS 0H
*MEXIT #=   481 LV= 1 RT1
* B3F4 CEDTR
         LD    1,=DD'.123'
         LD    2,=DD'.123E1'
         CEDTR 1,2
*MCALL #=   482 LV= 1          RT1   CC1
         DS    0H
RT1_TEST285      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL285
         LTORG 
RT1_CCL285      DS 0H
*MEXIT #=   482 LV= 1 RT1
         LD    1,=DD'.123'
         LD    2,=DD'.123'
         CEDTR 1,2
*MCALL #=   483 LV= 1          RT1   CC0
         DS    0H
RT1_TEST286      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE286
         LTORG 
RT1_CCE286      DS 0H
*MEXIT #=   483 LV= 1 RT1
         LD    1,=DD'.123E1'
         LD    2,=DD'.123'
         CEDTR 1,2
*MCALL #=   484 LV= 1          RT1   CC2
         DS    0H
RT1_TEST287      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH287
         LTORG 
RT1_CCH287      DS 0H
*MEXIT #=   484 LV= 1 RT1
* B3F5 QADTR
         LD    4,=DD'1235E-3'
         LD    5,=DD'124E-2'
         QADTR 1,4,5,0 F1=R4 WITH EXP= -2 AND ROUND HALF EVEN
         CDTR  1,5
*MCALL #=   485 LV= 1          RT1   CCE
         DS    0H
RT1_TEST288      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE288
         LTORG 
RT1_CCE288      DS 0H
*MEXIT #=   485 LV= 1 RT1
         LD    4,=DD'1235E-3'
         LD    5,=DD'123E-2'
         QADTR 1,4,5,8+1 F1=R4 WITH EXP= -2 AND ROUND TOWARD ZERO
         CDTR  1,5
*MCALL #=   486 LV= 1          RT1   CCE
         DS    0H
RT1_TEST289      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE289
         LTORG 
RT1_CCE289      DS 0H
*MEXIT #=   486 LV= 1 RT1
* B3F6 IEDTR
         LD    4,=DD'1'
         LG    2,=AD(DD_BIAS) RPI790
         IEDTR 1,4,2
         LD    5,=DD'1'       RPI790
         CDTR  1,5
*MCALL #=   487 LV= 1          RT1   CC0
         DS    0H
RT1_TEST290      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE290
         LTORG 
RT1_CCE290      DS 0H
*MEXIT #=   487 LV= 1 RT1
         LD    4,=DD'100'
         LG    2,=AD(DD_BIAS) RPI-790
         IEDTR 1,4,2
         LD    5,=DD'100'     RPI-790
         CDTR  1,5
*MCALL #=   488 LV= 1          RT1   CC0
         DS    0H
RT1_TEST291      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE291
         LTORG 
RT1_CCE291      DS 0H
*MEXIT #=   488 LV= 1 RT1
* B3F7 LLDTR
         LD    4,=DD'1235'
         LG    2,=FD'3'
         RRDTR 1,4,2,0 ROUND HALF EVEN F4 TO 3 SIG DIGITS
         LD    5,=DD'1240'
         CDTR  1,5
*MCALL #=   489 LV= 1          RT1   CCE
         DS    0H
RT1_TEST292      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE292
         LTORG 
RT1_CCE292      DS 0H
*MEXIT #=   489 LV= 1 RT1
         LD    4,=DD'1235'
         LG    2,=FD'3'
         RRDTR 1,4,2,8+1 ROUND TOWARD 0 F4 TO 3 SIG DIGITS
         LD    5,=DD'1230'
         CDTR  1,5
*MCALL #=   490 LV= 1          RT1   CCE
         DS    0H
RT1_TEST293      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE293
         LTORG 
RT1_CCE293      DS 0H
*MEXIT #=   490 LV= 1 RT1
* B3F9 CXGTR
         LG    2,=FD'1234567890123456'
         CXGTR 1,2 CVT G TO LD
*MCALL #=   491 LV= 1          LX    4,=LD'1234567890123456'
         LA    15,=LD'1234567890123456'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   491 LV= 1 LX
         CXTR  1,4
*MCALL #=   492 LV= 1          RT1   CC0
         DS    0H
RT1_TEST294      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE294
         LTORG 
RT1_CCE294      DS 0H
*MEXIT #=   492 LV= 1 RT1
* B3FA CXUTR
         LMG    2,3,=XL16'12345678901234567890123456789012'
         CXUTR 1,2
*MCALL #=   493 LV= 1          LX    4,=LD'1234567890123456789012345678X
               9012'
         LA    15,=LD'12345678901234567890123456789012'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   493 LV= 1 LX
         CXTR  1,4
*MCALL #=   494 LV= 1          RT1   CC0
         DS    0H
RT1_TEST295      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE295
         LTORG 
RT1_CCE295      DS 0H
*MEXIT #=   494 LV= 1 RT1
* B3FB CXSTR
         LMG    2,3,=PL16'1234567890123456789012345678901'
         CXSTR 1,2
*MCALL #=   495 LV= 1          LX    4,=LD'1234567890123456789012345678X
               901'
         LA    15,=LD'1234567890123456789012345678901'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   495 LV= 1 LX
         CXTR  1,4
*MCALL #=   496 LV= 1          RT1   CC0
         DS    0H
RT1_TEST296      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE296
         LTORG 
RT1_CCE296      DS 0H
*MEXIT #=   496 LV= 1 RT1
* B3FC CEXTR
*MCALL #=   497 LV= 1          LX    4,=LD'.123'   RPI-786 FORCE -3 EXP
         LA    15,=LD'.123'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   497 LV= 1 LX
*MCALL #=   498 LV= 1          LX    5,=LD'.123E1' RPI-786 ROCE  -2 EXP
         LA    15,=LD'.123E1'
         LD    5,0(15)
         LD    5+2,8(15)
*MEXIT #=   498 LV= 1 LX
         CEXTR 4,5
*MCALL #=   499 LV= 1          RT1   CC1
         DS    0H
RT1_TEST297      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL297
         LTORG 
RT1_CCL297      DS 0H
*MEXIT #=   499 LV= 1 RT1
*MCALL #=   500 LV= 1          LX    4,=DD'.123'   RPI-786
         LA    15,=DD'.123'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   500 LV= 1 LX
*MCALL #=   501 LV= 1          LX    5,=DD'.123'   RPI-786
         LA    15,=DD'.123'
         LD    5,0(15)
         LD    5+2,8(15)
*MEXIT #=   501 LV= 1 LX
         CEXTR 4,5
*MCALL #=   502 LV= 1          RT1   CC0
         DS    0H
RT1_TEST298      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE298
         LTORG 
RT1_CCE298      DS 0H
*MEXIT #=   502 LV= 1 RT1
*MCALL #=   503 LV= 1          LX    4,=DD'.123E1' RPI-786
         LA    15,=DD'.123E1'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   503 LV= 1 LX
*MCALL #=   504 LV= 1          LX    5,=DD'.123'   RPI-786
         LA    15,=DD'.123'
         LD    5,0(15)
         LD    5+2,8(15)
*MEXIT #=   504 LV= 1 LX
         CEXTR 4,5
*MCALL #=   505 LV= 1          RT1   CC2
         DS    0H
RT1_TEST299      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH299
         LTORG 
RT1_CCH299      DS 0H
*MEXIT #=   505 LV= 1 RT1
* B3FD QAXTR
*MCALL #=   506 LV= 1          LX    4,=LD'1235E-3'
         LA    15,=LD'1235E-3'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   506 LV= 1 LX
*MCALL #=   507 LV= 1          LX    5,=LD'124E-2'
         LA    15,=LD'124E-2'
         LD    5,0(15)
         LD    5+2,8(15)
*MEXIT #=   507 LV= 1 LX
         QAXTR 1,4,5,0 F1=R4 WITH EXP= -2 ROUNDED HALF EVEN
         CXTR  1,5
*MCALL #=   508 LV= 1          RT1   CCE
         DS    0H
RT1_TEST300      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE300
         LTORG 
RT1_CCE300      DS 0H
*MEXIT #=   508 LV= 1 RT1
*MCALL #=   509 LV= 1          LX    4,=LD'1235E-3'
         LA    15,=LD'1235E-3'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   509 LV= 1 LX
*MCALL #=   510 LV= 1          LX    5,=LD'123E-2'
         LA    15,=LD'123E-2'
         LD    5,0(15)
         LD    5+2,8(15)
*MEXIT #=   510 LV= 1 LX
         QAXTR 1,4,5,8+1 F1=R4 WITH EXP -2 AND ROUNDED TOWARD ZERO
         CXTR  1,5
*MCALL #=   511 LV= 1          RT1   CCE
         DS    0H
RT1_TEST301      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE301
         LTORG 
RT1_CCE301      DS 0H
*MEXIT #=   511 LV= 1 RT1
* B3FE IEXTR
*MCALL #=   512 LV= 1          LX    4,=LD'1'
         LA    15,=LD'1'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   512 LV= 1 LX
         LG    2,=AD(LD_BIAS)  RPI-790
         IEXTR 1,4,2
*MCALL #=   513 LV= 1          LX    5,=LD'1'        RPI-790
         LA    15,=LD'1'
         LD    5,0(15)
         LD    5+2,8(15)
*MEXIT #=   513 LV= 1 LX
         CXTR  1,5
*MCALL #=   514 LV= 1          RT1   CC0
         DS    0H
RT1_TEST302      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE302
         LTORG 
RT1_CCE302      DS 0H
*MEXIT #=   514 LV= 1 RT1
*MCALL #=   515 LV= 1          LX    4,=LD'100'
         LA    15,=LD'100'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   515 LV= 1 LX
         LG    2,=AD(LD_BIAS)  RPI-790
         IEXTR 1,4,2
*MCALL #=   516 LV= 1          LX    5,=LD'100'      RPI-790
         LA    15,=LD'100'
         LD    5,0(15)
         LD    5+2,8(15)
*MEXIT #=   516 LV= 1 LX
         CXTR  1,5
*MCALL #=   517 LV= 1          RT1   CC0
         DS    0H
RT1_TEST303      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE303
         LTORG 
RT1_CCE303      DS 0H
*MEXIT #=   517 LV= 1 RT1
* B3FF RRXTR
*MCALL #=   518 LV= 1          LX    4,=LD'1235'
         LA    15,=LD'1235'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   518 LV= 1 LX
         LG    2,=FD'3'
         RRXTR 1,4,2,0 ROUND HALF EVEN F4 TO 3 SIG DIGITS
*MCALL #=   519 LV= 1          LX    5,=LD'1240'
         LA    15,=LD'1240'
         LD    5,0(15)
         LD    5+2,8(15)
*MEXIT #=   519 LV= 1 LX
         CXTR  1,5
*MCALL #=   520 LV= 1          RT1   CCE
         DS    0H
RT1_TEST304      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE304
         LTORG 
RT1_CCE304      DS 0H
*MEXIT #=   520 LV= 1 RT1
*MCALL #=   521 LV= 1          LX    4,=LD'1235'
         LA    15,=LD'1235'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   521 LV= 1 LX
         LG    2,=FD'3'
         RRXTR 1,4,2,8+1 ROUND TOWARD 0 F4 TO 3 SIG DIGITS
*MCALL #=   522 LV= 1          LX    5,=LD'1230'
         LA    15,=LD'1230'
         LD    5,0(15)
         LD    5+2,8(15)
*MEXIT #=   522 LV= 1 LX
         CXTR  1,5
*MCALL #=   523 LV= 1          RT1   CCE
         DS    0H
RT1_TEST305      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE305
         LTORG 
RT1_CCE305      DS 0H
*MEXIT #=   523 LV= 1 RT1
* ED40 SLDT
         LD    4,=DD'123'
         SLDT  1,4,3
         LD    5,=DD'123000'
         CDTR  1,5
*MCALL #=   524 LV= 1          RT1   CCE
         DS    0H
RT1_TEST306      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE306
         LTORG 
RT1_CCE306      DS 0H
*MEXIT #=   524 LV= 1 RT1
         LD    4,=DD'123E3'
         SLDT  1,4,3
         LD    5,=DD'123000E3'
         CDTR  1,5
*MCALL #=   525 LV= 1          RT1   CCE
         DS    0H
RT1_TEST307      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE307
         LTORG 
RT1_CCE307      DS 0H
*MEXIT #=   525 LV= 1 RT1
         LD    4,=DD'1234567890123456'
         SLDT  1,4,1
         LD    5,=DD'2345678901234560'
         CDTR  1,5
*MCALL #=   526 LV= 1          RT1   CCE
         DS    0H
RT1_TEST308      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE308
         LTORG 
RT1_CCE308      DS 0H
*MEXIT #=   526 LV= 1 RT1
         LD    4,=DD'1234567890123456E1'
         SLDT  1,4,1
         LD    5,=DD'2345678901234560E1'
         CDTR  1,5
*MCALL #=   527 LV= 1          RT1   CCE
         DS    0H
RT1_TEST309      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE309
         LTORG 
RT1_CCE309      DS 0H
*MEXIT #=   527 LV= 1 RT1
         LD    4,=DD'1234567890123456E-1'
         SLDT  1,4,1
         LD    5,=DD'2345678901234560E-1'
         CDTR  1,5
*MCALL #=   528 LV= 1          RT1   CCE
         DS    0H
RT1_TEST310      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE310
         LTORG 
RT1_CCE310      DS 0H
*MEXIT #=   528 LV= 1 RT1
* ED41 SRDT
         LD    4,=DD'1234'
         SRDT  1,4,2
         LD    5,=DD'12'  RPI-790
         CDTR  1,5
*MCALL #=   529 LV= 1          RT1   CCE
         DS    0H
RT1_TEST311      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE311
         LTORG 
RT1_CCE311      DS 0H
*MEXIT #=   529 LV= 1 RT1
         LD    4,=DD'1234E5'
         SRDT  1,4,2
         LD    5,=DD'12E5'  RPI-790
         CDTR  1,5
*MCALL #=   530 LV= 1          RT1   CCE
         DS    0H
RT1_TEST312      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE312
         LTORG 
RT1_CCE312      DS 0H
*MEXIT #=   530 LV= 1 RT1
* ED48 SLXT
*MCALL #=   531 LV= 1          LX    4,=LD'123'
         LA    15,=LD'123'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   531 LV= 1 LX
         SLXT  1,4,3
*MCALL #=   532 LV= 1          LX    5,=LD'123000'
         LA    15,=LD'123000'
         LD    5,0(15)
         LD    5+2,8(15)
*MEXIT #=   532 LV= 1 LX
         CXTR  1,5
*MCALL #=   533 LV= 1          RT1   CCE
         DS    0H
RT1_TEST313      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE313
         LTORG 
RT1_CCE313      DS 0H
*MEXIT #=   533 LV= 1 RT1
*MCALL #=   534 LV= 1          LX    4,=LD'123E3'
         LA    15,=LD'123E3'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   534 LV= 1 LX
         SLXT  1,4,3
*MCALL #=   535 LV= 1          LX    5,=LD'123E6'
         LA    15,=LD'123E6'
         LD    5,0(15)
         LD    5+2,8(15)
*MEXIT #=   535 LV= 1 LX
         CXTR  1,5
*MCALL #=   536 LV= 1          RT1   CCE
         DS    0H
RT1_TEST314      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE314
         LTORG 
RT1_CCE314      DS 0H
*MEXIT #=   536 LV= 1 RT1
*MCALL #=   537 LV= 1          LX    4,=LD'1234567890123456789012345678X
               901234'
         LA    15,=LD'1234567890123456789012345678901234'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   537 LV= 1 LX
         SLXT  1,4,1
*MCALL #=   538 LV= 1          LX    5,=LD'2345678901234567890123456789X
               012340'
         LA    15,=LD'2345678901234567890123456789012340'
         LD    5,0(15)
         LD    5+2,8(15)
*MEXIT #=   538 LV= 1 LX
         CXTR  1,5
*MCALL #=   539 LV= 1          RT1   CCE
         DS    0H
RT1_TEST315      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE315
         LTORG 
RT1_CCE315      DS 0H
*MEXIT #=   539 LV= 1 RT1
*MCALL #=   540 LV= 1          LX    4,=LD'1234567890123456789012345678X
               901234E1'
         LA    15,=LD'1234567890123456789012345678901234E1'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   540 LV= 1 LX
         SLXT  1,4,1
*MCALL #=   541 LV= 1          LX    5,=LD'2345678901234567890123456789X
               012340E1'
         LA    15,=LD'2345678901234567890123456789012340E1'
         LD    5,0(15)
         LD    5+2,8(15)
*MEXIT #=   541 LV= 1 LX
         CXTR  1,5
*MCALL #=   542 LV= 1          RT1   CCE
         DS    0H
RT1_TEST316      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE316
         LTORG 
RT1_CCE316      DS 0H
*MEXIT #=   542 LV= 1 RT1
*MCALL #=   543 LV= 1          LX    4,=LD'1234567890123456789012345678X
               901234E-1'
         LA    15,=LD'1234567890123456789012345678901234E-1'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   543 LV= 1 LX
         SLXT  1,4,1
*MCALL #=   544 LV= 1          LX    5,=LD'2345678901234567890123456789X
               012340E-1'
         LA    15,=LD'2345678901234567890123456789012340E-1'
         LD    5,0(15)
         LD    5+2,8(15)
*MEXIT #=   544 LV= 1 LX
         CXTR  1,5
*MCALL #=   545 LV= 1          RT1   CCE
         DS    0H
RT1_TEST317      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE317
         LTORG 
RT1_CCE317      DS 0H
*MEXIT #=   545 LV= 1 RT1
* ED49 SRXT
*MCALL #=   546 LV= 1          LX    4,=LD'1234'
         LA    15,=LD'1234'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   546 LV= 1 LX
         SRXT  1,4,2
*MCALL #=   547 LV= 1          LX    5,=LD'12' RPI-790
         LA    15,=LD'12'
         LD    5,0(15)
         LD    5+2,8(15)
*MEXIT #=   547 LV= 1 LX
         CXTR  1,5
*MCALL #=   548 LV= 1          RT1   CCE
         DS    0H
RT1_TEST318      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE318
         LTORG 
RT1_CCE318      DS 0H
*MEXIT #=   548 LV= 1 RT1
*MCALL #=   549 LV= 1          LX    4,=LD'1234E3'
         LA    15,=LD'1234E3'
         LD    4,0(15)
         LD    4+2,8(15)
*MEXIT #=   549 LV= 1 LX
         SRXT  1,4,2
*MCALL #=   550 LV= 1          LX    5,=LD'12E3' RPI-790
         LA    15,=LD'12E3'
         LD    5,0(15)
         LD    5+2,8(15)
*MEXIT #=   550 LV= 1 LX
         CXTR  1,5
*MCALL #=   551 LV= 1          RT1   CCE
         DS    0H
RT1_TEST319      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE319
         LTORG 
RT1_CCE319      DS 0H
*MEXIT #=   551 LV= 1 RT1
* ED50 TDCET
         LE    1,=ED'1'
         TDCET 1,TDCPZ
*MCALL #=   552 LV= 1          RT1   CC0
         DS    0H
RT1_TEST320      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE320
         LTORG 
RT1_CCE320      DS 0H
*MEXIT #=   552 LV= 1 RT1
         LE    1,=ED'0'
         TDCET 1,TDCPZ
*MCALL #=   553 LV= 1          RT1   CC1
         DS    0H
RT1_TEST321      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL321
         LTORG 
RT1_CCL321      DS 0H
*MEXIT #=   553 LV= 1 RT1
         LE    1,=ED'-0'
         TDCET 1,TDCMZ
*MCALL #=   554 LV= 1          RT1   CC1
         DS    0H
RT1_TEST322      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL322
         LTORG 
RT1_CCL322      DS 0H
*MEXIT #=   554 LV= 1 RT1
         LE    1,=ED'(MAX)'
         TDCET 1,TDCPN
*MCALL #=   555 LV= 1          RT1   CC1
         DS    0H
RT1_TEST323      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL323
         LTORG 
RT1_CCL323      DS 0H
*MEXIT #=   555 LV= 1 RT1
         LE    1,=ED'-(MAX)'
         TDCET 1,TDCMN
*MCALL #=   556 LV= 1          RT1   CC1
         DS    0H
RT1_TEST324      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL324
         LTORG 
RT1_CCL324      DS 0H
*MEXIT #=   556 LV= 1 RT1
         LE    1,=ED'1'
         TDCET 1,TDCPN
*MCALL #=   557 LV= 1          RT1   CC1
         DS    0H
RT1_TEST325      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL325
         LTORG 
RT1_CCL325      DS 0H
*MEXIT #=   557 LV= 1 RT1
         LE    1,=ED'-1'
         TDCET 1,TDCMN
*MCALL #=   558 LV= 1          RT1   CC1
         DS    0H
RT1_TEST326      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL326
         LTORG 
RT1_CCL326      DS 0H
*MEXIT #=   558 LV= 1 RT1
* ED51 TDGET
         LE    1,=LD'1'
         TDGET 1,TDGPSZ
*MCALL #=   559 LV= 1          RT1   CC0
         DS    0H
RT1_TEST327      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE327
         LTORG 
RT1_CCE327      DS 0H
*MEXIT #=   559 LV= 1 RT1
         LE    1,=ED'0'
         TDGET 1,TDGPSZ
*MCALL #=   560 LV= 1          RT1   CC1
         DS    0H
RT1_TEST328      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL328
         LTORG 
RT1_CCL328      DS 0H
*MEXIT #=   560 LV= 1 RT1
         LE    1,=ED'-0'
         TDGET 1,TDGMSZ
*MCALL #=   561 LV= 1          RT1   CC1
         DS    0H
RT1_TEST329      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL329
         LTORG 
RT1_CCL329      DS 0H
*MEXIT #=   561 LV= 1 RT1
         LE    1,=ED'1'
         TDGET 1,TDGPSF
*MCALL #=   562 LV= 1          RT1   CC1
         DS    0H
RT1_TEST330      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL330
         LTORG 
RT1_CCL330      DS 0H
*MEXIT #=   562 LV= 1 RT1
         LE    1,=ED'123456'
         TDGET 1,TDGPSF
*MCALL #=   563 LV= 1          RT1   CC1
         DS    0H
RT1_TEST331      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL331
         LTORG 
RT1_CCL331      DS 0H
*MEXIT #=   563 LV= 1 RT1
         LE    1,=ED'1234567'
         TDGET 1,TDGPDF
*MCALL #=   564 LV= 1          RT1   CC1
         DS    0H
RT1_TEST332      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL332
         LTORG 
RT1_CCL332      DS 0H
*MEXIT #=   564 LV= 1 RT1
         LE    1,=ED'(MAX)'
         TDGET 1,TDGPDF
*MCALL #=   565 LV= 1          RT1   CC1
         DS    0H
RT1_TEST333      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL333
         LTORG 
RT1_CCL333      DS 0H
*MEXIT #=   565 LV= 1 RT1
         LE    1,=ED'-1'
         TDGET 1,TDGMSF
*MCALL #=   566 LV= 1          RT1   CC1
         DS    0H
RT1_TEST334      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL334
         LTORG 
RT1_CCL334      DS 0H
*MEXIT #=   566 LV= 1 RT1
         LE    1,=ED'-123456'
         TDGET 1,TDGMSF
*MCALL #=   567 LV= 1          RT1   CC1
         DS    0H
RT1_TEST335      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL335
         LTORG 
RT1_CCL335      DS 0H
*MEXIT #=   567 LV= 1 RT1
         LE    1,=ED'-1234567'
         TDGET 1,TDGMDF
*MCALL #=   568 LV= 1          RT1   CC1
         DS    0H
RT1_TEST336      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL336
         LTORG 
RT1_CCL336      DS 0H
*MEXIT #=   568 LV= 1 RT1
         LE    1,=ED'-(MAX)'
         TDGET 1,TDGMDF
*MCALL #=   569 LV= 1          RT1   CC1
         DS    0H
RT1_TEST337      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL337
         LTORG 
RT1_CCL337      DS 0H
*MEXIT #=   569 LV= 1 RT1
* ED54 TDCDT
         LD    1,=DD'1'
         TDCDT 1,TDCPZ
*MCALL #=   570 LV= 1          RT1   CC0
         DS    0H
RT1_TEST338      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE338
         LTORG 
RT1_CCE338      DS 0H
*MEXIT #=   570 LV= 1 RT1
         LD    1,=DD'0'
         TDCDT 1,TDCPZ
*MCALL #=   571 LV= 1          RT1   CC1
         DS    0H
RT1_TEST339      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL339
         LTORG 
RT1_CCL339      DS 0H
*MEXIT #=   571 LV= 1 RT1
         LD    1,=DD'-0'
         TDCDT 1,TDCMZ
*MCALL #=   572 LV= 1          RT1   CC1
         DS    0H
RT1_TEST340      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL340
         LTORG 
RT1_CCL340      DS 0H
*MEXIT #=   572 LV= 1 RT1
         LD    1,=DD'(MAX)'
         TDCDT 1,TDCPN
*MCALL #=   573 LV= 1          RT1   CC1
         DS    0H
RT1_TEST341      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL341
         LTORG 
RT1_CCL341      DS 0H
*MEXIT #=   573 LV= 1 RT1
         LD    1,=DD'-(MAX)'
         TDCDT 1,TDCMN
*MCALL #=   574 LV= 1          RT1   CC1
         DS    0H
RT1_TEST342      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL342
         LTORG 
RT1_CCL342      DS 0H
*MEXIT #=   574 LV= 1 RT1
         LD    1,=DD'1'
         TDCDT 1,TDCPN
*MCALL #=   575 LV= 1          RT1   CC1
         DS    0H
RT1_TEST343      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL343
         LTORG 
RT1_CCL343      DS 0H
*MEXIT #=   575 LV= 1 RT1
         LD    1,=DD'-1'
         TDCDT 1,TDCMN
*MCALL #=   576 LV= 1          RT1   CC1
         DS    0H
RT1_TEST344      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL344
         LTORG 
RT1_CCL344      DS 0H
*MEXIT #=   576 LV= 1 RT1
* ED55 TDGDT
         LD    1,=DD'1'
         TDGDT 1,TDGPSZ
*MCALL #=   577 LV= 1          RT1   CC0
         DS    0H
RT1_TEST345      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE345
         LTORG 
RT1_CCE345      DS 0H
*MEXIT #=   577 LV= 1 RT1
         LD    1,=DD'0'
         TDGDT 1,TDGPSZ
*MCALL #=   578 LV= 1          RT1   CC1
         DS    0H
RT1_TEST346      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL346
         LTORG 
RT1_CCL346      DS 0H
*MEXIT #=   578 LV= 1 RT1
         LD    1,=DD'-0'
         TDGDT 1,TDGMSZ
*MCALL #=   579 LV= 1          RT1   CC1
         DS    0H
RT1_TEST347      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL347
         LTORG 
RT1_CCL347      DS 0H
*MEXIT #=   579 LV= 1 RT1
         LD    1,=DD'1'
         TDGDT 1,TDGPSF
*MCALL #=   580 LV= 1          RT1   CC1
         DS    0H
RT1_TEST348      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL348
         LTORG 
RT1_CCL348      DS 0H
*MEXIT #=   580 LV= 1 RT1
         LD    1,=DD'123456789012345'
         TDGDT 1,TDGPSF
*MCALL #=   581 LV= 1          RT1   CC1
         DS    0H
RT1_TEST349      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL349
         LTORG 
RT1_CCL349      DS 0H
*MEXIT #=   581 LV= 1 RT1
         LD    1,=DD'1234567890123456'
         TDGDT 1,TDGPDF
*MCALL #=   582 LV= 1          RT1   CC1
         DS    0H
RT1_TEST350      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL350
         LTORG 
RT1_CCL350      DS 0H
*MEXIT #=   582 LV= 1 RT1
         LD    1,=DD'(MAX)'
         TDGDT 1,TDGPDF
*MCALL #=   583 LV= 1          RT1   CC1
         DS    0H
RT1_TEST351      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL351
         LTORG 
RT1_CCL351      DS 0H
*MEXIT #=   583 LV= 1 RT1
         LD    1,=DD'-1'
         TDGDT 1,TDGMSF
*MCALL #=   584 LV= 1          RT1   CC1
         DS    0H
RT1_TEST352      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL352
         LTORG 
RT1_CCL352      DS 0H
*MEXIT #=   584 LV= 1 RT1
         LD    1,=DD'-123456789012345'
         TDGDT 1,TDGMSF
*MCALL #=   585 LV= 1          RT1   CC1
         DS    0H
RT1_TEST353      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL353
         LTORG 
RT1_CCL353      DS 0H
*MEXIT #=   585 LV= 1 RT1
         LD    1,=DD'-1234567890123456'
         TDGDT 1,TDGMDF
*MCALL #=   586 LV= 1          RT1   CC1
         DS    0H
RT1_TEST354      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL354
         LTORG 
RT1_CCL354      DS 0H
*MEXIT #=   586 LV= 1 RT1
         LD    1,=DD'-(MAX)'
         TDGDT 1,TDGMDF
*MCALL #=   587 LV= 1          RT1   CC1
         DS    0H
RT1_TEST355      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL355
         LTORG 
RT1_CCL355      DS 0H
*MEXIT #=   587 LV= 1 RT1
* ED58 TDCXT
*MCALL #=   588 LV= 1          LX    1,=LD'1'
         LA    15,=LD'1'
         LD    1,0(15)
         LD    1+2,8(15)
*MEXIT #=   588 LV= 1 LX
         TDCXT 1,TDCPZ
*MCALL #=   589 LV= 1          RT1   CC0
         DS    0H
RT1_TEST356      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE356
         LTORG 
RT1_CCE356      DS 0H
*MEXIT #=   589 LV= 1 RT1
*MCALL #=   590 LV= 1          LX    1,=LD'0'
         LA    15,=LD'0'
         LD    1,0(15)
         LD    1+2,8(15)
*MEXIT #=   590 LV= 1 LX
         TDCXT 1,TDCPZ
*MCALL #=   591 LV= 1          RT1   CC1
         DS    0H
RT1_TEST357      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL357
         LTORG 
RT1_CCL357      DS 0H
*MEXIT #=   591 LV= 1 RT1
*MCALL #=   592 LV= 1          LX    1,=LD'-0'
         LA    15,=LD'-0'
         LD    1,0(15)
         LD    1+2,8(15)
*MEXIT #=   592 LV= 1 LX
         TDCXT 1,TDCMZ
*MCALL #=   593 LV= 1          RT1   CC1
         DS    0H
RT1_TEST358      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL358
         LTORG 
RT1_CCL358      DS 0H
*MEXIT #=   593 LV= 1 RT1
*MCALL #=   594 LV= 1          LX    1,=LD'(MAX)'
         LA    15,=LD'(MAX)'
         LD    1,0(15)
         LD    1+2,8(15)
*MEXIT #=   594 LV= 1 LX
         TDCXT 1,TDCPN
*MCALL #=   595 LV= 1          RT1   CC1
         DS    0H
RT1_TEST359      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL359
         LTORG 
RT1_CCL359      DS 0H
*MEXIT #=   595 LV= 1 RT1
*MCALL #=   596 LV= 1          LX    1,=LD'-(MAX)'
         LA    15,=LD'-(MAX)'
         LD    1,0(15)
         LD    1+2,8(15)
*MEXIT #=   596 LV= 1 LX
         TDCXT 1,TDCMN
*MCALL #=   597 LV= 1          RT1   CC1
         DS    0H
RT1_TEST360      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL360
         LTORG 
RT1_CCL360      DS 0H
*MEXIT #=   597 LV= 1 RT1
*MCALL #=   598 LV= 1          LX    1,=LD'1'
         LA    15,=LD'1'
         LD    1,0(15)
         LD    1+2,8(15)
*MEXIT #=   598 LV= 1 LX
         TDCXT 1,TDCPN
*MCALL #=   599 LV= 1          RT1   CC1
         DS    0H
RT1_TEST361      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL361
         LTORG 
RT1_CCL361      DS 0H
*MEXIT #=   599 LV= 1 RT1
*MCALL #=   600 LV= 1          LX    1,=LD'-1'
         LA    15,=LD'-1'
         LD    1,0(15)
         LD    1+2,8(15)
*MEXIT #=   600 LV= 1 LX
         TDCXT 1,TDCMN
*MCALL #=   601 LV= 1          RT1   CC1
         DS    0H
RT1_TEST362      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL362
         LTORG 
RT1_CCL362      DS 0H
*MEXIT #=   601 LV= 1 RT1
* ED59 TDGXT
*MCALL #=   602 LV= 1          LX    1,=LD'1'
         LA    15,=LD'1'
         LD    1,0(15)
         LD    1+2,8(15)
*MEXIT #=   602 LV= 1 LX
         TDGXT 1,TDGPSZ
*MCALL #=   603 LV= 1          RT1   CC0
         DS    0H
RT1_TEST363      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE363
         LTORG 
RT1_CCE363      DS 0H
*MEXIT #=   603 LV= 1 RT1
*MCALL #=   604 LV= 1          LX    1,=LD'0'
         LA    15,=LD'0'
         LD    1,0(15)
         LD    1+2,8(15)
*MEXIT #=   604 LV= 1 LX
         TDGXT 1,TDGPSZ
*MCALL #=   605 LV= 1          RT1   CC1
         DS    0H
RT1_TEST364      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL364
         LTORG 
RT1_CCL364      DS 0H
*MEXIT #=   605 LV= 1 RT1
*MCALL #=   606 LV= 1          LX    1,=LD'-0'
         LA    15,=LD'-0'
         LD    1,0(15)
         LD    1+2,8(15)
*MEXIT #=   606 LV= 1 LX
         TDGXT 1,TDGMSZ
*MCALL #=   607 LV= 1          RT1   CC1
         DS    0H
RT1_TEST365      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL365
         LTORG 
RT1_CCL365      DS 0H
*MEXIT #=   607 LV= 1 RT1
*MCALL #=   608 LV= 1          LX    1,=LD'1'
         LA    15,=LD'1'
         LD    1,0(15)
         LD    1+2,8(15)
*MEXIT #=   608 LV= 1 LX
         TDGXT 1,TDGPSF
*MCALL #=   609 LV= 1          RT1   CC1
         DS    0H
RT1_TEST366      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL366
         LTORG 
RT1_CCL366      DS 0H
*MEXIT #=   609 LV= 1 RT1
*MCALL #=   610 LV= 1          LX    1,=LD'1234567890123456789012345678X
               90123'
         LA    15,=LD'123456789012345678901234567890123'
         LD    1,0(15)
         LD    1+2,8(15)
*MEXIT #=   610 LV= 1 LX
         TDGXT 1,TDGPSF
*MCALL #=   611 LV= 1          RT1   CC1
         DS    0H
RT1_TEST367      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL367
         LTORG 
RT1_CCL367      DS 0H
*MEXIT #=   611 LV= 1 RT1
*MCALL #=   612 LV= 1          LX    1,=LD'1234567890123456789012345678X
               901234'
         LA    15,=LD'1234567890123456789012345678901234'
         LD    1,0(15)
         LD    1+2,8(15)
*MEXIT #=   612 LV= 1 LX
         TDGXT 1,TDGPDF
*MCALL #=   613 LV= 1          RT1   CC1
         DS    0H
RT1_TEST368      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL368
         LTORG 
RT1_CCL368      DS 0H
*MEXIT #=   613 LV= 1 RT1
*MCALL #=   614 LV= 1          LX    1,=LD'(MAX)'
         LA    15,=LD'(MAX)'
         LD    1,0(15)
         LD    1+2,8(15)
*MEXIT #=   614 LV= 1 LX
         TDGXT 1,TDGPDF
*MCALL #=   615 LV= 1          RT1   CC1
         DS    0H
RT1_TEST369      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL369
         LTORG 
RT1_CCL369      DS 0H
*MEXIT #=   615 LV= 1 RT1
*MCALL #=   616 LV= 1          LX    1,=LD'-1'
         LA    15,=LD'-1'
         LD    1,0(15)
         LD    1+2,8(15)
*MEXIT #=   616 LV= 1 LX
         TDGXT 1,TDGMSF
*MCALL #=   617 LV= 1          RT1   CC1
         DS    0H
RT1_TEST370      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL370
         LTORG 
RT1_CCL370      DS 0H
*MEXIT #=   617 LV= 1 RT1
*MCALL #=   618 LV= 1          LX    1,=LD'-123456789012345678901234567X
               890123'
         LA    15,=LD'-123456789012345678901234567890123'
         LD    1,0(15)
         LD    1+2,8(15)
*MEXIT #=   618 LV= 1 LX
         TDGXT 1,TDGMSF
*MCALL #=   619 LV= 1          RT1   CC1
         DS    0H
RT1_TEST371      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL371
         LTORG 
RT1_CCL371      DS 0H
*MEXIT #=   619 LV= 1 RT1
*MCALL #=   620 LV= 1          LX    1,=LD'-123456789012345678901234567X
               8901234'
         LA    15,=LD'-1234567890123456789012345678901234'
         LD    1,0(15)
         LD    1+2,8(15)
*MEXIT #=   620 LV= 1 LX
         TDGXT 1,TDGMDF
*MCALL #=   621 LV= 1          RT1   CC1
         DS    0H
RT1_TEST372      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL372
         LTORG 
RT1_CCL372      DS 0H
*MEXIT #=   621 LV= 1 RT1
*MCALL #=   622 LV= 1          LX    1,=LD'-(MAX)'
         LA    15,=LD'-(MAX)'
         LD    1,0(15)
         LD    1+2,8(15)
*MEXIT #=   622 LV= 1 LX
         TDGXT 1,TDGMDF
*MCALL #=   623 LV= 1          RT1   CC1
         DS    0H
RT1_TEST373      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL373
         LTORG 
RT1_CCL373      DS 0H
*MEXIT #=   623 LV= 1 RT1
*
* END OF TESTS
*
*MCALL #=   624 LV= 1          RT1   END
         B      RT1_END
*MEXIT #=   624 LV= 1 RT1
*MCALL #=   625 LV= 1          IHAEPIE 
EPIE     DSECT 
EPIEEPIE DS    CL4   C'EPIE'
EPIEPARM DS    A     A(PARAM PASSED AT ESPIE OR 0)
         DS    16F   32 bit regs not used by z390 (see EPIEG64)
EPIEPSW  DS    0XL8  (OLD PSW  (EC 24/31 BIT ONLY)
EPIEEMK1 DS    X     PSW MASK
EPIEMWP1 DS    X     PSW KEY AND MWP
EPIECCPM DS    X     PSW CONDITION CODE AND PGM MASK
         DS    X     RESERVED
EPIENXT1 DS    0F    PSW 31 BIT ADDR NEXT INSTRUCTION
EPIEAMF1 DS    X     PSW ADDRESS HIGH BYTE WITH AMODE BIT
EPIEMOD1 EQU   X'80' PSW 31 BIT AMODE BIT
EPIEADD1 DS    XL3   PSW 24 BIT ADDRESSS OF NEXT INSTRUCTION
EPIEINT  DS    0XL4  PROGRAM INTERRUPTION INFO
EPIEIRSV DS    XL1   RESERVED
EPIEILC1 DS    B     INSTRUCTION LENGTH BYTE
EPIEIL1  EQU   X'06' INSTRUCTION LENGTH MASK (2, 4, 6 LENGTH)
EPIEINC1 DS    0CL2  INTERRUPTION CODE
         ORG   EPIE+X'99'
EPIEFLGS DS    XL1   EPIE OPTION FLAGS
EPIEUP64 EQU   X'40' USE 64 BIT REGS INSTEAD OF 32 BIT
         DS    XL6   RESERVED
EPIEG64   DS   0D
EPIEG6400 DS   D
EPIEG6401 DS   D
EPIEG6402 DS   D
EPIEG6403 DS   D
EPIEG6404 DS   D
EPIEG6405 DS   D
EPIEG6406 DS   D
EPIEG6407 DS   D
EPIEG6408 DS   D
EPIEG6409 DS   D
EPIEG6410 DS   D
EPIEG6411 DS   D
EPIEG6412 DS   D
EPIEG6413 DS   D
EPIEG6414 DS   D
EPIEG6415 DS   D
EPIELEN  EQU   *-EPIE
*MEXIT #=   625 LV= 1 IHAEPIE
         END 
