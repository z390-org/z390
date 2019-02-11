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
* 2005-09-30 DSH          Initial version                           *
* 2005-10-05 DSH RPI-5    Make ASCII mode aware using X'A0' high    *
*                         bit ASCII space                           *
* 2005-10-17              Add CLST, CUSE, and SRST string instruct. *
* 2005-10-22 DSH RPI-44   Fix TM to set CC3 if OR'D byte = mask vs  *
*                         memory                                    *
* 2005-10-23 DSH RPI-43   Fix ED and EDMK significance 1 digit early*
* 2005-10-26 DSH RPI-49   Fix D test to use register pair like DR   *
*                         already does                              *
* 2005-11-02 DSH RPI-69   Remove ED/EDMK mask changes for ASCII not *
*                         needed                                    *
* 2005-11-03 DSH RPI-65   Add test for BALR, BASR, BASSM with R1=R2 *
* 2005-11-07 DSH RPI-73   Add tests for C!..! and hex mask, PKA,    *
*                         UNPKA                                     *
* 2005-11-11 DSH RPI-73   Update UNPK tests for ASCII mode support  *
* 2005-11-11 DSH RPI-82   Add tests for MVC with overlap AT +1 and  *
*                         +2                                        *
* 2005-11-20 DSH RPI-106  Update tests for SPM, IPM, NR, OR, XR,    *
*                         and PC/PR                                 *
* 2005-11-23 DSH RPI-109  Add PD tests for optimized PD using       *
*                         INT vs BIGINT                             *
* 2005-12-08 DSH RPI-120  Add SRP test of explicit BDDD2            *
* 2006-01-07 DSH RPI-158  Clear remaining bits in LLIHH LLIHL LLILH *
*                         LLILL                                     *
* 2006-01-08 DSH RPI-160  Correct LLGT which was loading from loc+4 *
* 2006-01-11 DSH RPI-166  Test SRAG 1,2,3(4) and TMY 1(2),3 using   *
*                         base register                             *
* 2006-01-15 DSH RPI-173  Add LRV, STPQ, and LPQ                    *
* 2006-01-15 DSH RPI-174  Correct ALC?? and SLB?? CC0 carry errors  *
* 2006-02-04 DSH RPI-185  Add missing extended branc and z9 opcodes *
* 2006-02-08 DSH RPI-185  Add z9 instructions(see TESTFP1 for FP    *
*                         instructions)                             *
*                         PTFF, STCKF (fix STCK to be unique), STFLE*
*                         LGBR, LGBR, LGHR, LBR, LHR, FLOGR         *
*                         LLGCR, LLGHR, LLCR, LLHR, LGFI, XIHF, XILF*
*                         IIHF, IILF, NIHF, NILF, OIHF, OILF        *
*                         LLIHF, LLILF, SLGFI, SLFI                 *
*                         AGFI, AFI, ALGFI, ALFI, CGFI, CFI, CLGFI, *
*                         CLFI   LTG, LT, LLC, LLH                  *
* 2006-02-10 DSH RPI-199  Add extended branch BRCL instructions     *
* 2006-04-01              Add 32 * 32 = 64 bit test of MR           *
* 2006-04-05              Add 32 * 32 = 64 bit test of MR and       *
*                         verify R1 ignored                         *
* 2006-04-07              Add 32 * 32 = 64 bit test of MLR and ML   *
* 2006-04-23 DSH RPI-295  Add additional tests for ICM and OIHL     *
* 2006-04-28 DSH RPI-303  Add additional tests for ICM to set high  *
*                         if possible                               *
* 2006-05-02 DSH RPI-305  Use new ESPIE and ESTAE control blocks    *
* 2006-07-20 DSH RPI-376  Test ALR CC=1 when high bit turned on and *
*                         no carry                                  *
* 2006-07-24 DSH RPI-383  Correct tests for MLG and MLGR to use R1+1*
*                         S2/R2                                     *
* 2006-08-06 DSH RPI-398  Correct tests for D and DR to include     *
*                         64 bits                                   *
* 2006-09-08 DSH RPI-441  Add test for MVST move string and update  *
*                         TP tests                                  *
* 2006-09-19 DSH RPI-454  Add test for TRE, TROO, TROT, TRTO, TRTT  *
* 2006-11-10 DSH RPI-476  Add CC test for MVST ALONG with speedup   *
* 2007-03-18 DSH RPI-580  Correct test char for TR??                *
* 2007-05-07 DSH RPI-606  Add MVCOS tests                           *
* 2007-06-10 DSH RPI-636  Set ESTAE required exit RC=4 for restart  *
*                         request                                   *
* 2008-02-27 DSH RPI-815  Correct support for negative index        *
*                         register 24/31                            *
* 2008-03-12 DSH RPI-820  Test fix to prevent S0C5 on negative SRP  *
*                         b2 register                               *
* 2008-03-15 DSH RPI-823  Correct test for MVCIN using right most   *
*                         source address                            *
* 2008-03-28 DSH RPI-828  Test clearing high bit in AMODE31 for     *
*                         TRT/EDMK                                  *
* 2008-03-28 DSH RPI-831  Test SLR, SLGR, SLGFR, SL, SLY, SLG, SLGF *
*                         for CC1 when borrow for two values with   *
*                         high bit on.                              *
* 2008-06-07 DSH RPI-844  Corrections for compatibility with z9,    *
*                         z10 tests                                 *
*          1) Align TROO, TROT, TRTO, TRTT table to dword else 0C4  *
*          2) TMHH, TMHL, TMLH, TMLL set CC1 high sel bit 0 else cc2*
*          3) Force AMODE31 with SAM31 for TRT test on z9/z10       *
*          4) Correct tests for TMY mixed                           *
*          5) Recode LMD test using DC vs literals for HLASM compat.*
*          6) Issue S0C7 ABEND for X'3' PD sign unless option ASCII *
*          7) Align registers on 16 byte boundary to eliminate      *
*             HLASM warning                                         *
* 2008-06-09 DSH RPI-859  Move MVCOS updated test to TESTINS3       *
*                         removing overlap                          *
*                         Set R0 to 7 for STFLE store facilities.   *
* 2008-06-17 DSH RPI-845  Change EPIED to IHAEPIE                   *
*                         (Note ESPIEPSW offset change)             *
* 2008-06-21 DSH RPI-845  Change ESTAD to IHASDWA and remove        *
*                         ESTAPSW ref.                              *
* 2008-07-05 DSH RPI-875  Correct test for CLIY bug introduced by   *
*                         RPI-859                                   *
* 2008-07-08 DSH RPI-875  Add missing test for ALY, LTGF, CGH, MFY, *
*                         MHY, ASI, ALSI, AGSI, ALGSI               *
* 2008-07-23 DSH RPI-879  Test SLR, SLGR, SLGFR, SL, SLY, SLG, SLGF *
*                         for CC3 NZ,NB when both signs NEG and     *
*                         S1 > S2                                   *
* 2009-04-20 DSH RPI-1026 Add test for ESTA, EREG, EREGG            *
* 2009-06-15 DSH RPI-1055 Add CPYA, SAR, and EAR support for AR     *
*                         registers                                 *
* 2010-02-25 DSH RPI-1111 Correct PR to only restore 2-14 (was 1-14)*
* 2010-12-18 DSH RPI-1125 Fix ALSI and ALGSI to set borrow on       *
*                         negative add                              *
* 2012-04-02 DSH RPI-1200 Test LRVGR and LRVR with same registers   *
*********************************************************************
* This program includes unit tests of each instruction added to     *
* ez390.java J2SE 390 emulator.                                     *
*                                                                   *
* RT1 macro used to automate code generated for mainline and        *
* test PSW CC routines. The macros define new base registers for    *
* each test so they can extend for any length.                      *
*                                                                   *
* See TESTFP1 for HFP and BFP floating point instructions tests.    *
*********************************************************************
         TITLE 'TESTINS2 - UNIT TEST EACH EZ390 INSTRUCTION SUPPORTED'
*MCALL #=     1 LV= 1 TESTINS2 RT1   MAIN
*MCALL #=     2 LV= 2 TESTINS2 SUBENTRY 
TESTINS2 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTINS2'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTINS2+8,13
*MEXIT #=     2 LV= 2 SUBENTRY
*MCALL #=     3 LV= 2          WTO   'TESTINS2 RT1 STARTED'
         BRAS  1,*+(WTO#0003_EOT-*+1)/2*2
         DC    AL2(WTO#0003_EOT-*,0),C'TESTINS2 RT1 STARTED'
WTO#0003_EOT     EQU *
         SVC   35
*MEXIT #=     3 LV= 2 WTO
         BRCL    15,RT1_START
RT1_ABORT DS 0H
         MVI   RT1_ABORTED,C'T'
*MCALL #=     4 LV= 2          WTO   'TESTINS2 RT1 TESTING ABORTED'
         BRAS  1,*+(WTO#0004_EOT-*+1)/2*2
         DC    AL2(WTO#0004_EOT-*,0),C'TESTINS2 RT1 TESTING ABORTED'
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
*MCALL #=     6 LV= 2          WTO   'TESTINS2 RT1 ENDED OK'
         BRAS  1,*+(WTO#0006_EOT-*+1)/2*2
         DC    AL2(WTO#0006_EOT-*,0),C'TESTINS2 RT1 ENDED OK'
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
RT1_WTO1 DC    AL2(RT1_WTO_END-*,0),C'TESTINS2 RT1 TESTS COMPLETED = '
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
ESPIE_EXIT DS  0H
         USING *,R15
         USING EPIE,R1         RPI-845 NEW DSECT NAME
         L     R0,EPIEPARM
         ST    R0,EPIEPSW+4
         BR    R14
         DROP  R15,R1
ESTAE_EXIT DS  0H
         USING *,R15
         USING SDWA,R1
         L     R0,SDWAPARM     RPI-845 USE SDWA PARM VS ESTAD
         LA    R15,4   REQUEST RESTART RPI-636
         BR    R14
         DROP  R15,R1
LMD1     DC    0D,X'01234567',X'01234567' RPI-844
LMD2     DC    0D,X'89ABCDEF',X'89ABCDEF' RPI-844
         CNOP  8,16      RPI-844 PREVENT STPQ WARNING MESSAGE
PWORK    DS    D
PWORK16  DS    XL16
DWORD    DS    D
PL1      DS    PL1
WORD     DS    F
BYTE     DS    X
         CNOP  0,16      RPI-844 PREVENT CDS WARNING MESSAGE
REGS     DS    XL(16*8)
EBMIN    DC    EB'1.2E-38'
FPCREG   DS    F        BFP CONTROL REG WITH MASKS AND DXC CODE
FPCDXC   EQU   FPCREG+2 REASON CODES FOR 0C7 DATA EXCEPTIONS
SVC35    DC    AL2(SVC35END-*,0),C'TEST SVC 35 OK'
SVC35END EQU   *
ESTACC   DC    X'00'
ESTAPSW  DC    2F'0'
EREGSAVE DC    XL8'00'
EREGGSAV DC    XL16'00'
KEY      DC    C'EFE'
PAD      DC    C' '
STRING1  DC    C'CABCBFDEFEAB'
STRING2  DC    C'ACBABBCEFEAB'
STRING3  DC    C'1234',X'00'
STRING4  DC    C'ABCD',X'EE'
NEGMASK  DC    C! !,X'202020',C!-   ! BI-MODAL EBCDIC MASK
TREEOD   EQU   X'EE' TRE EOD TEST BYTE
TRETAB   DC    240X'FF',C!ABCD!,12X'FF' TRE TRANS TAB 0123 > ABCD
TREF1    DC    C!0123!
TREV1    DC    C!ABCD!
TREF2    DC    X'F0F1EEF3'  EOD IN 3RD BYTE
TREV2    DC    X'C1C2EEF3'
TROOEOD  EQU   X'C3' TROO EOD TEST BYTE RPI-580
* RPI-844 ALIGN TROOTAB, TROTTAB, TRTTTAB TO DOUBLE WORK
TROOTAB  DC    0D,240X'FF',C!ABCD!,12X'FF' TROO TRANS TAB 0123 > ABCD
TROOF1   DC    C!9999!
TROOF1V1 DC    X'C1C2C3C4'  RESULT WITH NO TESTING FOR 4 BYTES
TROOF1V2 DC    X'C1C2F9F9'  RESULT WITH TESTING STOP ON 3RD BYTE
TROOF2   DC    X'F0F1F2F3'
TROTEOD  EQU   X'C3C3' TROO EOD TEST BYTE RPI-580
TROTTAB  DC    0D,240X'FFFF',C!AABBCCDD!,12X'FFFF' (F0 * 2 > C1C1) ETC
TROTF1   DC    C!99999999!
TROTF1V1 DC    X'C1C1C2C2C3C3C4C4'  RESULT WITH NO TESTING FOR 4 BYTES
TROTF1V2 DC    X'C1C1C2C2F9F9F9F9'  RESULT WITH STOP ON 3RD BYTE
TROTF2   DC    X'F0F1F2F3'
TRTOEOD  EQU   X'C3' TROO EOD TEST BYTES RPI-580
TRTOTAB  DC    0D,128X'FFFF',C!ABCD! (X'0100' > C'A' ETC
TRTOF1   DC    C!9999!
TRTOF1V1 DC    C!ABCD!  RESULT WITH NO TESTING FOR 4 BYTES
TRTOF1V2 DC    C!AB99!  RESULT WITH STOP ON 3RD BYTE
TRTOF2   DC    X'0100010101020103'
TRTTEOD  EQU   X'C3C3' TROO EOD TEST BYTES RPI-580
TRTTTAB  DC    0D,256X'FFFF',C!AABBCCDD! (X'0100' > C'AA' ETC
TRTTF1   DC    C!99999999!
TRTTF1V1 DC    C!AABBCCDD!  RESULT WITH NO TESTING
TRTTF1V2 DC    C!AABB9999!  RESULT WITH STOP ON 3RD ENTRY
TRTTF2   DC    X'0100010101020103'  EOD IN 3RD ENTRY
* START TESTS
*MCALL #=    10 LV= 1          RT1   START
RT1_START DS  0H
*MEXIT #=    10 LV= 1 RT1
* 0101 PR
         LA    0,1
         LA    1,1
         LMG   2,3,=A(111,222,333,444)
         LA    14,1
         LA    15,1
         PC    PR1
PCRET1   EQU   *
         CHI   0,2
*MCALL #=    11 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1
         LTORG 
RT1_CCE1        DS 0H
*MEXIT #=    11 LV= 1 RT1
         CHI   1,2  RPI-1111 WAS 1 VS 2
*MCALL #=    12 LV= 1          RT1   CCE
         DS    0H
RT1_TEST2        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE2
         LTORG 
RT1_CCE2        DS 0H
*MEXIT #=    12 LV= 1 RT1
         CHI   14,1
*MCALL #=    13 LV= 1          RT1   CCE
         DS    0H
RT1_TEST3        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE3
         LTORG 
RT1_CCE3        DS 0H
*MEXIT #=    13 LV= 1 RT1
         CHI   15,2
*MCALL #=    14 LV= 1          RT1   CCE
         DS    0H
RT1_TEST4        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE4
         LTORG 
RT1_CCE4        DS 0H
*MEXIT #=    14 LV= 1 RT1
         B     PR2
*MCALL #=    15 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=    15 LV= 1 RT1
PR1      EQU   *
         BALR  2,0
         USING *,2
*MCALL #=    16 LV= 1          WTO   'PR1 SUB CALLED'
         BRAS  1,*+(WTO#0016_EOT-*+1)/2*2
         DC    AL2(WTO#0016_EOT-*,0),C'PR1 SUB CALLED'
WTO#0016_EOT     EQU *
         SVC   35
*MEXIT #=    16 LV= 1 WTO
         LA    2,2  REQUEST PSW                    RPI-1026
         ESTA  0,2  EXTRACT RETURN PSW INTO R0-R1  RPI-1026
         MVI   ESTACC,0
         JZ    *+8
         MVI   ESTACC,1
         STM   0,1,ESTAPSW
         SGR   2,2
         SGR   3,3
         EREG  2,3
         STM   2,3,EREGSAVE
         SGR   2,2
         SGR   3,3
         EREGG 2,3
         STMG  2,3,EREGGSAV
         LA    0,2
         LA    1,2
         LA    14,2
         LA    15,2
         PR 
         DROP  2
PR2      EQU   *
         CLI   ESTACC,1 PC TYPE
*MCALL #=    17 LV= 1          RT1   CCE
         DS    0H
RT1_TEST6        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE6
         LTORG 
RT1_CCE6        DS 0H
*MEXIT #=    17 LV= 1 RT1
         CLC   ESTAPSW,=AL8(PCRET1)
*MCALL #=    18 LV= 1          RT1   CCE           RPI-1026
         DS    0H
RT1_TEST7        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE7
         LTORG 
RT1_CCE7        DS 0H
*MEXIT #=    18 LV= 1 RT1
         CLC   EREGSAVE,=A(222,444)
*MCALL #=    19 LV= 1          RT1   CCE
         DS    0H
RT1_TEST8        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE8
         LTORG 
RT1_CCE8        DS 0H
*MEXIT #=    19 LV= 1 RT1
         CLC   EREGGSAV,=A(111,222,333,444)
*MCALL #=    20 LV= 1          RT1   CCE
         DS    0H
RT1_TEST9        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE9
         LTORG 
RT1_CCE9        DS 0H
*MEXIT #=    20 LV= 1 RT1
* 010C SAM24
         SAM24 
         L     1,=A(X'FFFFFF')
         LA    1,1(1)
         CL    1,=A(0)
*MCALL #=    21 LV= 1          RT1   CCE
         DS    0H
RT1_TEST10       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE10
         LTORG 
RT1_CCE10       DS 0H
*MEXIT #=    21 LV= 1 RT1
* 010D SAM31
         SAM31 
         L     1,=A(X'FFFFFF')
         LA    1,1(1)
         CL    1,=A(X'01000000')
*MCALL #=    22 LV= 1          RT1   CCE
         DS    0H
RT1_TEST11       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE11
         LTORG 
RT1_CCE11       DS 0H
*MEXIT #=    22 LV= 1 RT1
* 04   SPM
         L     R0,=X'3F000000'
         SPM   R0
*MCALL #=    23 LV= 1          RT1   CC3
         DS    0H
RT1_TEST12       BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC312
         LTORG 
RT1_CC312       DS 0H
*MEXIT #=    23 LV= 1 RT1
         SR    R0,R0
         AHI   R0,1
         IPM   R0
         CLM   R0,8,=X'2F'
*MCALL #=    24 LV= 1          RT1   CCE
         DS    0H
RT1_TEST13       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE13
         LTORG 
RT1_CCE13       DS 0H
*MEXIT #=    24 LV= 1 RT1
* 05   BALR
         BALR  R1,0
BALR1    EQU   *
         NILH  R1,X'7FFF'
         ST    R1,WORD
*MCALL #=    25 LV= 1          RT1   CCE,WORD,=A(BALR1)
         DS    0H
         CLC   WORD,=A(BALR1)
RT1_TEST14       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE14
         LTORG 
RT1_CCE14       DS 0H
*MEXIT #=    25 LV= 1 RT1
         LA    R2,BALR3
         BALR  R1,R2
BALR2    EQU   *
*MCALL #=    26 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=    26 LV= 1 RT1
BALR3    EQU   *
         NILH  R1,X'7FFF'
         ST    R1,WORD
*MCALL #=    27 LV= 1          RT1   CCE,WORD,=A(BALR2)
         DS    0H
         CLC   WORD,=A(BALR2)
RT1_TEST16       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE16
         LTORG 
RT1_CCE16       DS 0H
*MEXIT #=    27 LV= 1 RT1
         LA    R1,*+6
         BALR  R1,R1
         CLM   R1,7,=AL3(*)
*MCALL #=    28 LV= 1          RT1   CCE
         DS    0H
RT1_TEST17       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE17
         LTORG 
RT1_CCE17       DS 0H
*MEXIT #=    28 LV= 1 RT1
* 06   BCTR
         LA    R1,2
         BCTR  R1,0
         CL    R1,=F'1'
*MCALL #=    29 LV= 1          RT1   CCE
         DS    0H
RT1_TEST18       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE18
         LTORG 
RT1_CCE18       DS 0H
*MEXIT #=    29 LV= 1 RT1
* 07   BCR
         LA    R3,BCRERR
         B     BCROK
*MCALL #=    30 LV= 1 BCRERR   RT1   ABORT
BCRERR   DS    0H
         B      RT1_ABORT
*MEXIT #=    30 LV= 1 RT1
BCROK    EQU   *
         NOPR  R3
         CLI   =X'1',1
         BNER  R3
         CLI   =X'1',2
         BNLR  R3
         BER   R3
         CLI   =X'2',1
         BNHR  R3
         BER   R3
* 0A   SVC
         LA    R1,SVC35
         SVC   35
* 0B   BSM
         LA    R0,0
         BSM   R0,R0
         CL    R0,=F'0'
*MCALL #=    31 LV= 1          RT1   CCE
         DS    0H
RT1_TEST20       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE20
         LTORG 
RT1_CCE20       DS 0H
*MEXIT #=    31 LV= 1 RT1
         LA    R1,0
         BSM   R1,R0
         CL    R1,=X'80000000'
*MCALL #=    32 LV= 1          RT1   CCE
         DS    0H
RT1_TEST21       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE21
         LTORG 
RT1_CCE21       DS 0H
*MEXIT #=    32 LV= 1 RT1
         LA    R2,BSM1
         BSM   R1,R2           SWITCH TO AMODE24
*MCALL #=    33 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=    33 LV= 1 RT1
BSM1     EQU   *
         CL    R1,=X'80000000' VERIFY WAS AMODE31
*MCALL #=    34 LV= 1          RT1   CCE
         DS    0H
RT1_TEST23       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE23
         LTORG 
RT1_CCE23       DS 0H
*MEXIT #=    34 LV= 1 RT1
         LA    R1,0
         BSM   R1,R0
         CL    R1,=X'00000000' VERIFY NOW AMODE24
*MCALL #=    35 LV= 1          RT1   CCE
         DS    0H
RT1_TEST24       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE24
         LTORG 
RT1_CCE24       DS 0H
*MEXIT #=    35 LV= 1 RT1
         LA    R2,BSM2
         OILH  R2,X'8000'
         BSM   R1,R2           SWITCH TO AMODE31
*MCALL #=    36 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=    36 LV= 1 RT1
BSM2     EQU   *
         CL    R1,=X'00000000' VERIFY WAS AMODE24
*MCALL #=    37 LV= 1          RT1   CCE
         DS    0H
RT1_TEST26       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE26
         LTORG 
RT1_CCE26       DS 0H
*MEXIT #=    37 LV= 1 RT1
         LA    R1,0
         BSM   R1,R0
         CL    R1,=X'80000000' VERIFY NOW AMODE31
*MCALL #=    38 LV= 1          RT1   CCE
         DS    0H
RT1_TEST27       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE27
         LTORG 
RT1_CCE27       DS 0H
*MEXIT #=    38 LV= 1 RT1
* 0C   BASSM
         BASSM R1,0
BASSM1   EQU   *
         NILH  R1,X'7FFF'
         ST    R1,WORD
*MCALL #=    39 LV= 1          RT1   CCE,WORD,=A(BASSM1)
         DS    0H
         CLC   WORD,=A(BASSM1)
RT1_TEST28       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE28
         LTORG 
RT1_CCE28       DS 0H
*MEXIT #=    39 LV= 1 RT1
         LA    R2,BASSM3
         BASSM R1,R2      SWITCH TO AMODE24
BASSM2    EQU   *
*MCALL #=    40 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=    40 LV= 1 RT1
BASSM3    EQU   *
         ST    R1,WORD
*MCALL #=    41 LV= 1          RT1   CCE,WORD,=A(BASSM2+X'80000000') VEX
               R WAS AMODE31 BEFORE
         DS    0H
         CLC   WORD,=A(BASSM2+X'80000000')
RT1_TEST30       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE30
         LTORG 
RT1_CCE30       DS 0H
*MEXIT #=    41 LV= 1 RT1
         L     R2,=A(BASSM5+X'80000000')
         BASSM R1,R2   SWITCH BACK TO AMODE31
BASSM4   EQU   *
*MCALL #=    42 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=    42 LV= 1 RT1
BASSM5   EQU   *
         CL    R1,=A(BASSM4)
*MCALL #=    43 LV= 1          RT1   CCE
         DS    0H
RT1_TEST32       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE32
         LTORG 
RT1_CCE32       DS 0H
*MEXIT #=    43 LV= 1 RT1
         L     R1,=X'00FFFFFF'
         LA    R1,1(R1)
         CL    R1,=X'01000000'
*MCALL #=    44 LV= 1          RT1   CCE
         DS    0H
RT1_TEST33       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE33
         LTORG 
RT1_CCE33       DS 0H
*MEXIT #=    44 LV= 1 RT1
         LA    R1,*+10
         OILH  R1,X'8000'
         BASSM R1,R1
         CLM   R1,7,=AL3(*)
*MCALL #=    45 LV= 1          RT1   CCE
         DS    0H
RT1_TEST34       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE34
         LTORG 
RT1_CCE34       DS 0H
*MEXIT #=    45 LV= 1 RT1
* 0D   BASR
         BASR  R1,0
BASR1    EQU   *
         NILH  R1,X'7FFF'
         ST    R1,WORD
*MCALL #=    46 LV= 1          RT1   CCE,WORD,=A(BASR1)
         DS    0H
         CLC   WORD,=A(BASR1)
RT1_TEST35       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE35
         LTORG 
RT1_CCE35       DS 0H
*MEXIT #=    46 LV= 1 RT1
         LA    R2,BASR3
         BASR  R1,R2
BASR2    EQU   *
*MCALL #=    47 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=    47 LV= 1 RT1
BASR3    EQU   *
         NILH  R1,X'7FFF'
         ST    R1,WORD
*MCALL #=    48 LV= 1          RT1   CCE,WORD,=A(BASR2)
         DS    0H
         CLC   WORD,=A(BASR2)
RT1_TEST37       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE37
         LTORG 
RT1_CCE37       DS 0H
*MEXIT #=    48 LV= 1 RT1
         LA    R1,*+6
         BASR  R1,R1
         CLM   R1,7,=AL3(*)
*MCALL #=    49 LV= 1          RT1   CCE
         DS    0H
RT1_TEST38       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE38
         LTORG 
RT1_CCE38       DS 0H
*MEXIT #=    49 LV= 1 RT1
* 0E   MVCL
         MVC   WORD,=C'1234'
         MVC   PWORK(4),=C'ABCD'
         LM    R0,R1,=A(WORD,4)
         LM    R2,R3,=A(PWORK,4)
         MVCL  R0,R2
*MCALL #=    50 LV= 1          RT1   CCE
         DS    0H
RT1_TEST39       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE39
         LTORG 
RT1_CCE39       DS 0H
*MEXIT #=    50 LV= 1 RT1
         CLC   WORD,=C'ABCD'
*MCALL #=    51 LV= 1          RT1   CCE
         DS    0H
RT1_TEST40       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE40
         LTORG 
RT1_CCE40       DS 0H
*MEXIT #=    51 LV= 1 RT1
         CL    R0,=A(WORD+4)
*MCALL #=    52 LV= 1          RT1   CCE
         DS    0H
RT1_TEST41       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE41
         LTORG 
RT1_CCE41       DS 0H
*MEXIT #=    52 LV= 1 RT1
         CL    R1,=A(0)
*MCALL #=    53 LV= 1          RT1   CCE
         DS    0H
RT1_TEST42       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE42
         LTORG 
RT1_CCE42       DS 0H
*MEXIT #=    53 LV= 1 RT1
         CL    R2,=A(PWORK+4)
*MCALL #=    54 LV= 1          RT1   CCE
         DS    0H
RT1_TEST43       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE43
         LTORG 
RT1_CCE43       DS 0H
*MEXIT #=    54 LV= 1 RT1
         CL    R3,=A(0)
*MCALL #=    55 LV= 1          RT1   CCE
         DS    0H
RT1_TEST44       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE44
         LTORG 
RT1_CCE44       DS 0H
*MEXIT #=    55 LV= 1 RT1
         MVC   WORD,=C'1234'
         MVC   PWORK(4),=C'ABXX'
         LM    R0,R1,=A(WORD,4)
         LM    R2,R3,=A(PWORK,2)
         ICM   R3,8,=C' '
         MVCL  R0,R2
*MCALL #=    56 LV= 1          RT1   CCH
         DS    0H
RT1_TEST45       BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH45
         LTORG 
RT1_CCH45       DS 0H
*MEXIT #=    56 LV= 1 RT1
         CL    R0,=A(WORD+4)
*MCALL #=    57 LV= 1          RT1   CCE
         DS    0H
RT1_TEST46       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE46
         LTORG 
RT1_CCE46       DS 0H
*MEXIT #=    57 LV= 1 RT1
         CL    R1,=A(0)
*MCALL #=    58 LV= 1          RT1   CCE
         DS    0H
RT1_TEST47       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE47
         LTORG 
RT1_CCE47       DS 0H
*MEXIT #=    58 LV= 1 RT1
         CL    R2,=A(PWORK+2)
*MCALL #=    59 LV= 1          RT1   CCE
         DS    0H
RT1_TEST48       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE48
         LTORG 
RT1_CCE48       DS 0H
*MEXIT #=    59 LV= 1 RT1
         CLM   R3,8,=C' '
         CLM   R3,7,=AL3(0)
*MCALL #=    60 LV= 1          RT1   CCE
         DS    0H
RT1_TEST49       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE49
         LTORG 
RT1_CCE49       DS 0H
*MEXIT #=    60 LV= 1 RT1
         CLC   WORD,=C'AB  '
*MCALL #=    61 LV= 1          RT1   CCE
         DS    0H
RT1_TEST50       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE50
         LTORG 
RT1_CCE50       DS 0H
*MEXIT #=    61 LV= 1 RT1
         MVC   WORD,=C'1234'
         MVC   PWORK(4),=C'ABCX'
         LM    R0,R1,=A(WORD,3)
         LM    R2,R3,=A(PWORK,4)
         ICM   R3,8,=C' '
         MVCL  R0,R2
*MCALL #=    62 LV= 1          RT1   CCL
         DS    0H
RT1_TEST51       BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL51
         LTORG 
RT1_CCL51       DS 0H
*MEXIT #=    62 LV= 1 RT1
         CL    R0,=A(WORD+3)
*MCALL #=    63 LV= 1          RT1   CCE
         DS    0H
RT1_TEST52       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE52
         LTORG 
RT1_CCE52       DS 0H
*MEXIT #=    63 LV= 1 RT1
         CL    R1,=A(0)
*MCALL #=    64 LV= 1          RT1   CCE
         DS    0H
RT1_TEST53       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE53
         LTORG 
RT1_CCE53       DS 0H
*MEXIT #=    64 LV= 1 RT1
         CL    R2,=A(PWORK+3)
*MCALL #=    65 LV= 1          RT1   CCE
         DS    0H
RT1_TEST54       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE54
         LTORG 
RT1_CCE54       DS 0H
*MEXIT #=    65 LV= 1 RT1
         CLM   R3,8,=C' '
         CLM   R3,7,=AL3(1)
*MCALL #=    66 LV= 1          RT1   CCE
         DS    0H
RT1_TEST55       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE55
         LTORG 
RT1_CCE55       DS 0H
*MEXIT #=    66 LV= 1 RT1
         CLC   WORD,=C'ABC4'
*MCALL #=    67 LV= 1          RT1   CCE
         DS    0H
RT1_TEST56       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE56
         LTORG 
RT1_CCE56       DS 0H
*MEXIT #=    67 LV= 1 RT1
* 0F   CLCL
         MVC   WORD,=C'ABCD'
         MVC   PWORK(4),=C'ABCD'
         LM    R0,R1,=A(WORD,4)
         LM    R2,R3,=A(PWORK,4)
         CLCL  R0,R2
*MCALL #=    68 LV= 1          RT1   CCE
         DS    0H
RT1_TEST57       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE57
         LTORG 
RT1_CCE57       DS 0H
*MEXIT #=    68 LV= 1 RT1
         CL    R0,=A(WORD+4)
*MCALL #=    69 LV= 1          RT1   CCE
         DS    0H
RT1_TEST58       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE58
         LTORG 
RT1_CCE58       DS 0H
*MEXIT #=    69 LV= 1 RT1
         CL    R1,=A(0)
*MCALL #=    70 LV= 1          RT1   CCE
         DS    0H
RT1_TEST59       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE59
         LTORG 
RT1_CCE59       DS 0H
*MEXIT #=    70 LV= 1 RT1
         CL    R2,=A(PWORK+4)
*MCALL #=    71 LV= 1          RT1   CCE
         DS    0H
RT1_TEST60       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE60
         LTORG 
RT1_CCE60       DS 0H
*MEXIT #=    71 LV= 1 RT1
         CL    R3,=A(0)
*MCALL #=    72 LV= 1          RT1   CCE
         DS    0H
RT1_TEST61       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE61
         LTORG 
RT1_CCE61       DS 0H
*MEXIT #=    72 LV= 1 RT1
         MVC   WORD,=C'AB  '
         MVC   PWORK(4),=C'ABXX'
         LM    R0,R1,=A(WORD,4)
         LM    R2,R3,=A(PWORK,2)
         ICM   R3,8,=C' '
         CLCL  R0,R2
*MCALL #=    73 LV= 1          RT1   CCE
         DS    0H
RT1_TEST62       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE62
         LTORG 
RT1_CCE62       DS 0H
*MEXIT #=    73 LV= 1 RT1
         CL    R0,=A(WORD+4)
*MCALL #=    74 LV= 1          RT1   CCE
         DS    0H
RT1_TEST63       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE63
         LTORG 
RT1_CCE63       DS 0H
*MEXIT #=    74 LV= 1 RT1
         CL    R1,=A(0)
*MCALL #=    75 LV= 1          RT1   CCE
         DS    0H
RT1_TEST64       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE64
         LTORG 
RT1_CCE64       DS 0H
*MEXIT #=    75 LV= 1 RT1
         CL    R2,=A(PWORK+2)
*MCALL #=    76 LV= 1          RT1   CCE
         DS    0H
RT1_TEST65       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE65
         LTORG 
RT1_CCE65       DS 0H
*MEXIT #=    76 LV= 1 RT1
         CLM   R3,8,=C' '
         CLM   R3,7,=AL3(0)
*MCALL #=    77 LV= 1          RT1   CCE
         DS    0H
RT1_TEST66       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE66
         LTORG 
RT1_CCE66       DS 0H
*MEXIT #=    77 LV= 1 RT1
         MVC   WORD,=C'ABC4'
         MVC   PWORK(4),=C'ABC '
         LM    R0,R1,=A(WORD,3)
         LM    R2,R3,=A(PWORK,4)
         ICM   R3,8,=C' '
         CLCL  R0,R2
*MCALL #=    78 LV= 1          RT1   CCE
         DS    0H
RT1_TEST67       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE67
         LTORG 
RT1_CCE67       DS 0H
*MEXIT #=    78 LV= 1 RT1
         CL    R0,=A(WORD+3)
*MCALL #=    79 LV= 1          RT1   CCE
         DS    0H
RT1_TEST68       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE68
         LTORG 
RT1_CCE68       DS 0H
*MEXIT #=    79 LV= 1 RT1
         CL    R1,=A(0)
*MCALL #=    80 LV= 1          RT1   CCE
         DS    0H
RT1_TEST69       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE69
         LTORG 
RT1_CCE69       DS 0H
*MEXIT #=    80 LV= 1 RT1
         CL    R2,=A(PWORK+4)
*MCALL #=    81 LV= 1          RT1   CCE
         DS    0H
RT1_TEST70       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE70
         LTORG 
RT1_CCE70       DS 0H
*MEXIT #=    81 LV= 1 RT1
         CLM   R3,8,=C' '
         CLM   R3,7,=AL3(0)
*MCALL #=    82 LV= 1          RT1   CCE
         DS    0H
RT1_TEST71       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE71
         LTORG 
RT1_CCE71       DS 0H
*MEXIT #=    82 LV= 1 RT1
         MVC   WORD,=C'AB  '
         MVC   PWORK(4),=C'ACXX'
         LM    R0,R1,=A(WORD,4)
         LM    R2,R3,=A(PWORK,2)
         ICM   R3,8,=C' '
         CLCL  R0,R2
*MCALL #=    83 LV= 1          RT1   CCL
         DS    0H
RT1_TEST72       BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL72
         LTORG 
RT1_CCL72       DS 0H
*MEXIT #=    83 LV= 1 RT1
         CL    R0,=A(WORD+1)
*MCALL #=    84 LV= 1          RT1   CCE
         DS    0H
RT1_TEST73       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE73
         LTORG 
RT1_CCE73       DS 0H
*MEXIT #=    84 LV= 1 RT1
         CL    R1,=A(3)
*MCALL #=    85 LV= 1          RT1   CCE
         DS    0H
RT1_TEST74       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE74
         LTORG 
RT1_CCE74       DS 0H
*MEXIT #=    85 LV= 1 RT1
         CL    R2,=A(PWORK+1)
*MCALL #=    86 LV= 1          RT1   CCE
         DS    0H
RT1_TEST75       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE75
         LTORG 
RT1_CCE75       DS 0H
*MEXIT #=    86 LV= 1 RT1
         CLM   R3,8,=C' '
         CLM   R3,7,=AL3(1)
*MCALL #=    87 LV= 1          RT1   CCE
         DS    0H
RT1_TEST76       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE76
         LTORG 
RT1_CCE76       DS 0H
*MEXIT #=    87 LV= 1 RT1
         MVC   WORD,=C'AB C'
         MVC   PWORK(4),=C'ABXX'
         LM    R0,R1,=A(WORD,4)
         LM    R2,R3,=A(PWORK,2)
         ICM   R3,8,=C' '
         CLCL  R0,R2
*MCALL #=    88 LV= 1          RT1   CCH
         DS    0H
RT1_TEST77       BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH77
         LTORG 
RT1_CCH77       DS 0H
*MEXIT #=    88 LV= 1 RT1
         CL    R0,=A(WORD+3)
*MCALL #=    89 LV= 1          RT1   CCE
         DS    0H
RT1_TEST78       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE78
         LTORG 
RT1_CCE78       DS 0H
*MEXIT #=    89 LV= 1 RT1
         CL    R1,=A(1)
*MCALL #=    90 LV= 1          RT1   CCE
         DS    0H
RT1_TEST79       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE79
         LTORG 
RT1_CCE79       DS 0H
*MEXIT #=    90 LV= 1 RT1
         CL    R2,=A(PWORK+2)
*MCALL #=    91 LV= 1          RT1   CCE
         DS    0H
RT1_TEST80       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE80
         LTORG 
RT1_CCE80       DS 0H
*MEXIT #=    91 LV= 1 RT1
         CLM   R3,8,=C' '
         CLM   R3,7,=AL3(0)
*MCALL #=    92 LV= 1          RT1   CCE
         DS    0H
RT1_TEST81       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE81
         LTORG 
RT1_CCE81       DS 0H
*MEXIT #=    92 LV= 1 RT1
* 10   LPR
         L     R1,=F'-1'
         LPR   R0,R1
*MCALL #=    93 LV= 1          RT1   CCH
         DS    0H
RT1_TEST82       BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH82
         LTORG 
RT1_CCH82       DS 0H
*MEXIT #=    93 LV= 1 RT1
         CL    R0,=F'1'
*MCALL #=    94 LV= 1          RT1   CCE
         DS    0H
RT1_TEST83       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE83
         LTORG 
RT1_CCE83       DS 0H
*MEXIT #=    94 LV= 1 RT1
         L     R1,=X'80000000'
         LPR   R0,R1
*MCALL #=    95 LV= 1          RT1   CC3
         DS    0H
RT1_TEST84       BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC384
         LTORG 
RT1_CC384       DS 0H
*MEXIT #=    95 LV= 1 RT1
* 11   LNR
         L     R1,=F'1'
         LNR   R0,R1
*MCALL #=    96 LV= 1          RT1   CCL
         DS    0H
RT1_TEST85       BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL85
         LTORG 
RT1_CCL85       DS 0H
*MEXIT #=    96 LV= 1 RT1
         CL    R0,=F'-1'
*MCALL #=    97 LV= 1          RT1   CCE
         DS    0H
RT1_TEST86       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE86
         LTORG 
RT1_CCE86       DS 0H
*MEXIT #=    97 LV= 1 RT1
* 12   LTR
         L     R1,=F'1'
         LTR   R0,R1
*MCALL #=    98 LV= 1          RT1   CCH
         DS    0H
RT1_TEST87       BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH87
         LTORG 
RT1_CCH87       DS 0H
*MEXIT #=    98 LV= 1 RT1
         L     R1,=F'-1'
         LTR   R0,R1
*MCALL #=    99 LV= 1          RT1   CCL
         DS    0H
RT1_TEST88       BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL88
         LTORG 
RT1_CCL88       DS 0H
*MEXIT #=    99 LV= 1 RT1
         L     R1,=F'0'
         LTR   R0,R1
*MCALL #=   100 LV= 1          RT1   CCE
         DS    0H
RT1_TEST89       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE89
         LTORG 
RT1_CCE89       DS 0H
*MEXIT #=   100 LV= 1 RT1
* 13   LCR
         L     R1,=F'1'
         LCR   R0,R1
*MCALL #=   101 LV= 1          RT1   CCL
         DS    0H
RT1_TEST90       BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL90
         LTORG 
RT1_CCL90       DS 0H
*MEXIT #=   101 LV= 1 RT1
         CL    R0,=F'-1'
*MCALL #=   102 LV= 1          RT1   CCE
         DS    0H
RT1_TEST91       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE91
         LTORG 
RT1_CCE91       DS 0H
*MEXIT #=   102 LV= 1 RT1
         L     R1,=F'-1'
         LCR   R0,R1
*MCALL #=   103 LV= 1          RT1   CCH
         DS    0H
RT1_TEST92       BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH92
         LTORG 
RT1_CCH92       DS 0H
*MEXIT #=   103 LV= 1 RT1
         CL    R0,=F'1'
*MCALL #=   104 LV= 1          RT1   CCE
         DS    0H
RT1_TEST93       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE93
         LTORG 
RT1_CCE93       DS 0H
*MEXIT #=   104 LV= 1 RT1
         L     R1,=X'80000000'
         LCR   R0,R1
*MCALL #=   105 LV= 1          RT1   CC3
         DS    0H
RT1_TEST94       BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC394
         LTORG 
RT1_CC394       DS 0H
*MEXIT #=   105 LV= 1 RT1
* 15   CLR
         LA    R1,1
         LA    R2,1
         CLR   R1,R2
*MCALL #=   106 LV= 1          RT1   CCE
         DS    0H
RT1_TEST95       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE95
         LTORG 
RT1_CCE95       DS 0H
*MEXIT #=   106 LV= 1 RT1
         LA    R1,0
         L     R2,=F'1'
         CLR   R1,R2
*MCALL #=   107 LV= 1          RT1   CCL
         DS    0H
RT1_TEST96       BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL96
         LTORG 
RT1_CCL96       DS 0H
*MEXIT #=   107 LV= 1 RT1
         LA    R1,2
         L     R2,=F'1'
         CLR   R1,R2
*MCALL #=   108 LV= 1          RT1   CCH
         DS    0H
RT1_TEST97       BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH97
         LTORG 
RT1_CCH97       DS 0H
*MEXIT #=   108 LV= 1 RT1
         L     R1,=F'-1'
         L     R2,=F'1'
         CLR   R1,R2
*MCALL #=   109 LV= 1          RT1   CCH
         DS    0H
RT1_TEST98       BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH98
         LTORG 
RT1_CCH98       DS 0H
*MEXIT #=   109 LV= 1 RT1
         L     R1,=F'1'
         L     R2,=F'-1'
         CLR   R1,R2
*MCALL #=   110 LV= 1          RT1   CCL
         DS    0H
RT1_TEST99       BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL99
         LTORG 
RT1_CCL99       DS 0H
*MEXIT #=   110 LV= 1 RT1
* 14   NR
         LA    R0,X'F0'
         LA    R1,X'0F'
         NR    R0,R1
*MCALL #=   111 LV= 1          RT1   CC0
         DS    0H
RT1_TEST100      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE100
         LTORG 
RT1_CCE100      DS 0H
*MEXIT #=   111 LV= 1 RT1
         LTR   R0,R0
*MCALL #=   112 LV= 1          RT1   CC0
         DS    0H
RT1_TEST101      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE101
         LTORG 
RT1_CCE101      DS 0H
*MEXIT #=   112 LV= 1 RT1
         LA    R0,3
         LA    R1,2
         NR    R0,R1
*MCALL #=   113 LV= 1          RT1   CC1
         DS    0H
RT1_TEST102      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL102
         LTORG 
RT1_CCL102      DS 0H
*MEXIT #=   113 LV= 1 RT1
         CLM   R0,15,=F'2'
*MCALL #=   114 LV= 1          RT1   CCE
         DS    0H
RT1_TEST103      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE103
         LTORG 
RT1_CCE103      DS 0H
*MEXIT #=   114 LV= 1 RT1
* 16   OR
         LA    R0,0
         LA    R1,0
         OR    R0,R1
*MCALL #=   115 LV= 1          RT1   CC0
         DS    0H
RT1_TEST104      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE104
         LTORG 
RT1_CCE104      DS 0H
*MEXIT #=   115 LV= 1 RT1
         LTR   R0,R0
*MCALL #=   116 LV= 1          RT1   CC0
         DS    0H
RT1_TEST105      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE105
         LTORG 
RT1_CCE105      DS 0H
*MEXIT #=   116 LV= 1 RT1
         LA    R0,1
         LA    R1,2
         OR    R0,R1
*MCALL #=   117 LV= 1          RT1   CC1
         DS    0H
RT1_TEST106      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL106
         LTORG 
RT1_CCL106      DS 0H
*MEXIT #=   117 LV= 1 RT1
         CLM   R0,15,=F'3'
*MCALL #=   118 LV= 1          RT1   CCE
         DS    0H
RT1_TEST107      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE107
         LTORG 
RT1_CCE107      DS 0H
*MEXIT #=   118 LV= 1 RT1
* 17   XR
         LA    R0,X'FF'
         LA    R1,X'FF'
         XR    R0,R1
*MCALL #=   119 LV= 1          RT1   CC0
         DS    0H
RT1_TEST108      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE108
         LTORG 
RT1_CCE108      DS 0H
*MEXIT #=   119 LV= 1 RT1
         LTR   R0,R0
*MCALL #=   120 LV= 1          RT1   CC0
         DS    0H
RT1_TEST109      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE109
         LTORG 
RT1_CCE109      DS 0H
*MEXIT #=   120 LV= 1 RT1
         LA    R0,3
         LA    R1,2
         XR    R0,R1
*MCALL #=   121 LV= 1          RT1   CC1
         DS    0H
RT1_TEST110      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL110
         LTORG 
RT1_CCL110      DS 0H
*MEXIT #=   121 LV= 1 RT1
         CLM   R0,15,=F'1'
*MCALL #=   122 LV= 1          RT1   CCE
         DS    0H
RT1_TEST111      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE111
         LTORG 
RT1_CCE111      DS 0H
*MEXIT #=   122 LV= 1 RT1
* 18   LR
         LA    R0,1
         LA    R1,2
         LR    R1,R0
         STC   R1,BYTE
         CLI   BYTE,1
*MCALL #=   123 LV= 1          RT1   CCE
         DS    0H
RT1_TEST112      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE112
         LTORG 
RT1_CCE112      DS 0H
*MEXIT #=   123 LV= 1 RT1
* 19   CR
         LA    R0,1
         LA    R1,1
         CR    R0,R1
*MCALL #=   124 LV= 1          RT1   CCE
         DS    0H
RT1_TEST113      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE113
         LTORG 
RT1_CCE113      DS 0H
*MEXIT #=   124 LV= 1 RT1
         LA    R0,1
         LA    R1,2
         CR    R0,R1
*MCALL #=   125 LV= 1          RT1   CCL
         DS    0H
RT1_TEST114      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL114
         LTORG 
RT1_CCL114      DS 0H
*MEXIT #=   125 LV= 1 RT1
         LA    R0,2
         LA    R1,1
         CR    R0,R1
*MCALL #=   126 LV= 1          RT1   CCH
         DS    0H
RT1_TEST115      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH115
         LTORG 
RT1_CCH115      DS 0H
*MEXIT #=   126 LV= 1 RT1
* 1A   AR
         LA    R0,1
         LA    R1,2
         AR    R0,R1
*MCALL #=   127 LV= 1          RT1   CCH
         DS    0H
RT1_TEST116      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH116
         LTORG 
RT1_CCH116      DS 0H
*MEXIT #=   127 LV= 1 RT1
         CL    R0,=F'3'
*MCALL #=   128 LV= 1          RT1   CCE
         DS    0H
RT1_TEST117      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE117
         LTORG 
RT1_CCE117      DS 0H
*MEXIT #=   128 LV= 1 RT1
*MCALL #=   129 LV= 1          ESPIE SET,ESPIE_EXIT,8,PARAM=AR1
        LA     15,AR1
        IPM    0  GET CURRENT PGM MASK
        OILH   0,2048
        SPM    0 TURN ON ANY MASKS REQUIRED
        L      0,=B'00000000100000000000000000000000'
        LA     1,ESPIE_EXIT
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   129 LV= 1 ESPIE
         L     R0,=X'7FFFFFFF'
         LA    R1,1
         AR    R0,R1
*MCALL #=   130 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   130 LV= 1 RT1
*MCALL #=   131 LV= 1 AR1      ESPIE RESET
AR1      DS    0H
        SR     15,15
        SR     1,1
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   131 LV= 1 ESPIE
*MCALL #=   132 LV= 1          WTO   'ESPIE FOR FIXED POINT OVERFLOW OKX
               '
         BRAS  1,*+(WTO#0132_EOT-*+1)/2*2
         DC    AL2(WTO#0132_EOT-*,0),C'ESPIE FOR FIXED POINT OVERFLOW OX
               K'
WTO#0132_EOT     EQU *
         SVC   35
*MEXIT #=   132 LV= 1 WTO
*MCALL #=   133 LV= 1          ESTAE ESTAE_EXIT,PARAM=AR2
        LA     0,ESTAE_EXIT
        LA     1,AR2
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   133 LV= 1 ESTAE
         L     R0,=X'80000000'
         L     R1,=F'-1'
         AR    R0,R1
*MCALL #=   134 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   134 LV= 1 RT1
*MCALL #=   135 LV= 1 AR2      ESTAE 0
AR2      DS    0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   135 LV= 1 ESTAE
*MCALL #=   136 LV= 1          WTO   'ESTAE FOR FIXED POINT OVERFLOW OKX
               '
         BRAS  1,*+(WTO#0136_EOT-*+1)/2*2
         DC    AL2(WTO#0136_EOT-*,0),C'ESTAE FOR FIXED POINT OVERFLOW OX
               K'
WTO#0136_EOT     EQU *
         SVC   35
*MEXIT #=   136 LV= 1 WTO
* 1B   SR
         LA    R0,1
         LA    R1,2
         SR    R0,R1
*MCALL #=   137 LV= 1          RT1   CCL
         DS    0H
RT1_TEST120      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL120
         LTORG 
RT1_CCL120      DS 0H
*MEXIT #=   137 LV= 1 RT1
         CL    R0,=F'-1'
*MCALL #=   138 LV= 1          RT1   CCE
         DS    0H
RT1_TEST121      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE121
         LTORG 
RT1_CCE121      DS 0H
*MEXIT #=   138 LV= 1 RT1
*MCALL #=   139 LV= 1          ESPIE SET,ESPIE_EXIT,8,PARAM=SR1
        LA     15,SR1
        IPM    0  GET CURRENT PGM MASK
        OILH   0,2048
        SPM    0 TURN ON ANY MASKS REQUIRED
        L      0,=B'00000000100000000000000000000000'
        LA     1,ESPIE_EXIT
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   139 LV= 1 ESPIE
         L     R0,=X'7FFFFFFF'
         L     R1,=F'-1'
         SR    R0,R1
*MCALL #=   140 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   140 LV= 1 RT1
*MCALL #=   141 LV= 1 SR1      ESPIE RESET
SR1      DS    0H
        SR     15,15
        SR     1,1
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   141 LV= 1 ESPIE
*MCALL #=   142 LV= 1          ESTAE ESTAE_EXIT,PARAM=SR2
        LA     0,ESTAE_EXIT
        LA     1,SR2
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   142 LV= 1 ESTAE
         L     R0,=X'80000000'
         L     R1,=F'1'
         SR    R0,R1
*MCALL #=   143 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   143 LV= 1 RT1
*MCALL #=   144 LV= 1 SR2      ESTAE 0
SR2      DS    0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   144 LV= 1 ESTAE
* 1C   MR
         LA    R0,1        RPI-272
         LA    R1,2
         LA    R2,5
         MR    R0,R2
         CL    R0,=F'0'
*MCALL #=   145 LV= 1          RT1   CCE
         DS    0H
RT1_TEST124      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE124
         LTORG 
RT1_CCE124      DS 0H
*MEXIT #=   145 LV= 1 RT1
         CL    R1,=F'10'
*MCALL #=   146 LV= 1          RT1   CCE
         DS    0H
RT1_TEST125      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE125
         LTORG 
RT1_CCE125      DS 0H
*MEXIT #=   146 LV= 1 RT1
         LA    R14,2
         LA    R15,3
         MR    R14,R14
         CL    R14,=F'0'  RPI-272
*MCALL #=   147 LV= 1          RT1   CCE
         DS    0H
RT1_TEST126      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE126
         LTORG 
RT1_CCE126      DS 0H
*MEXIT #=   147 LV= 1 RT1
         CL    R15,=F'6'
*MCALL #=   148 LV= 1          RT1   CCE
         DS    0H
RT1_TEST127      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE127
         LTORG 
RT1_CCE127      DS 0H
*MEXIT #=   148 LV= 1 RT1
* 1D   DR
         LA    R0,0
         LA    R1,13
         LA    R2,4
         DR    R0,R2
         CL    R0,=F'1'
*MCALL #=   149 LV= 1          RT1   CCE
         DS    0H
RT1_TEST128      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE128
         LTORG 
RT1_CCE128      DS 0H
*MEXIT #=   149 LV= 1 RT1
         CL    R1,=F'3'
*MCALL #=   150 LV= 1          RT1   CCE
         DS    0H
RT1_TEST129      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE129
         LTORG 
RT1_CCE129      DS 0H
*MEXIT #=   150 LV= 1 RT1
         LM    R0,R1,=FL8'1E17'
         L     R3,=F'1E9'
         DR    R0,R3
         CL    R0,=F'0'
*MCALL #=   151 LV= 1          RT1   CCE
         DS    0H
RT1_TEST130      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE130
         LTORG 
RT1_CCE130      DS 0H
*MEXIT #=   151 LV= 1 RT1
         CL    R1,=F'1E8'
*MCALL #=   152 LV= 1          RT1   CCE
         DS    0H
RT1_TEST131      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE131
         LTORG 
RT1_CCE131      DS 0H
*MEXIT #=   152 LV= 1 RT1
         LM    R0,R1,=FL8'-1E17'
         L     R3,=F'1E9'
         DR    R0,R3
         CL    R0,=F'0'
*MCALL #=   153 LV= 1          RT1   CCE
         DS    0H
RT1_TEST132      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE132
         LTORG 
RT1_CCE132      DS 0H
*MEXIT #=   153 LV= 1 RT1
         CL    R1,=F'-1E8'
*MCALL #=   154 LV= 1          RT1   CCE
         DS    0H
RT1_TEST133      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE133
         LTORG 
RT1_CCE133      DS 0H
*MEXIT #=   154 LV= 1 RT1
         LM    R0,R1,=FL8'1E17'
         L     R3,=F'-1E9'
         DR    R0,R3
         CL    R0,=F'0'
*MCALL #=   155 LV= 1          RT1   CCE
         DS    0H
RT1_TEST134      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE134
         LTORG 
RT1_CCE134      DS 0H
*MEXIT #=   155 LV= 1 RT1
         CL    R1,=F'-1E8'
*MCALL #=   156 LV= 1          RT1   CCE
         DS    0H
RT1_TEST135      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE135
         LTORG 
RT1_CCE135      DS 0H
*MEXIT #=   156 LV= 1 RT1
         LM    R0,R1,=F'1,3'
         L     R3,=F'4'
         DR    R0,R3
         CL    R0,=F'3'
*MCALL #=   157 LV= 1          RT1   CCE
         DS    0H
RT1_TEST136      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE136
         LTORG 
RT1_CCE136      DS 0H
*MEXIT #=   157 LV= 1 RT1
         CL    R1,=FS30'1'
*MCALL #=   158 LV= 1          RT1   CCE
         DS    0H
RT1_TEST137      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE137
         LTORG 
RT1_CCE137      DS 0H
*MEXIT #=   158 LV= 1 RT1
         LM    R0,R1,=F'1,3'
         L     R3,=F'-4'
         DR    R0,R3
         CL    R0,=F'3'
*MCALL #=   159 LV= 1          RT1   CCE
         DS    0H
RT1_TEST138      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE138
         LTORG 
RT1_CCE138      DS 0H
*MEXIT #=   159 LV= 1 RT1
         CL    R1,=FS30'-1'
*MCALL #=   160 LV= 1          RT1   CCE
         DS    0H
RT1_TEST139      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE139
         LTORG 
RT1_CCE139      DS 0H
*MEXIT #=   160 LV= 1 RT1
*MCALL #=   161 LV= 1          ESPIE SET,ESPIE_EXIT,9,PARAM=DR1
        LA     15,DR1
        IPM    0  GET CURRENT PGM MASK
        SPM    0 TURN ON ANY MASKS REQUIRED
        L      0,=B'00000000010000000000000000000000'
        LA     1,ESPIE_EXIT
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   161 LV= 1 ESPIE
         LA    R2,0
         DR    R0,R2
*MCALL #=   162 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   162 LV= 1 RT1
*MCALL #=   163 LV= 1 DR1      ESPIE RESET
DR1      DS    0H
        SR     15,15
        SR     1,1
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   163 LV= 1 ESPIE
*MCALL #=   164 LV= 1          WTO   'ESPIE FOR FIXED POINT DIVIDE OK'
         BRAS  1,*+(WTO#0164_EOT-*+1)/2*2
         DC    AL2(WTO#0164_EOT-*,0),C'ESPIE FOR FIXED POINT DIVIDE OK'
WTO#0164_EOT     EQU *
         SVC   35
*MEXIT #=   164 LV= 1 WTO
* 1E   ALR
         L     R0,=F'3'
         L     R2,=F'2'
         ALR   R0,R2
*MCALL #=   165 LV= 1          RT1   CC1        NZ,NC
         DS    0H
RT1_TEST141      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL141
         LTORG 
RT1_CCL141      DS 0H
*MEXIT #=   165 LV= 1 RT1
         CL    R0,=F'5'
*MCALL #=   166 LV= 1          RT1   CCE
         DS    0H
RT1_TEST142      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE142
         LTORG 
RT1_CCE142      DS 0H
*MEXIT #=   166 LV= 1 RT1
         L     R0,=X'80000000'
         L     R2,=X'00000001'
         ALR   R0,R2
*MCALL #=   167 LV= 1          RT1   CC1        NZ,NC
         DS    0H
RT1_TEST143      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL143
         LTORG 
RT1_CCL143      DS 0H
*MEXIT #=   167 LV= 1 RT1
         L     R0,=X'40000000'
         L     R2,=X'40000001'
         ALR   R0,R2
*MCALL #=   168 LV= 1          RT1   CC1        NZ,NC  RPI-376
         DS    0H
RT1_TEST144      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL144
         LTORG 
RT1_CCL144      DS 0H
*MEXIT #=   168 LV= 1 RT1
         CL    R0,=X'80000001'
*MCALL #=   169 LV= 1          RT1   CCE
         DS    0H
RT1_TEST145      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE145
         LTORG 
RT1_CCE145      DS 0H
*MEXIT #=   169 LV= 1 RT1
         L     R0,=X'FFFFFFFF'
         L     R2,=X'00000001'
         ALR   R0,R2
*MCALL #=   170 LV= 1          RT1   CC2        Z,C
         DS    0H
RT1_TEST146      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH146
         LTORG 
RT1_CCH146      DS 0H
*MEXIT #=   170 LV= 1 RT1
         CL    R0,=X'00000000'
*MCALL #=   171 LV= 1          RT1   CCE
         DS    0H
RT1_TEST147      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE147
         LTORG 
RT1_CCE147      DS 0H
*MEXIT #=   171 LV= 1 RT1
         L     R0,=X'FFFFFFFF'
         L     R2,=X'00000002'
         ALR   R0,R2
*MCALL #=   172 LV= 1          RT1   CC3        NZ,C
         DS    0H
RT1_TEST148      BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC3148
         LTORG 
RT1_CC3148      DS 0H
*MEXIT #=   172 LV= 1 RT1
         CL    R0,=X'00000001'
*MCALL #=   173 LV= 1          RT1   CCE
         DS    0H
RT1_TEST149      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE149
         LTORG 
RT1_CCE149      DS 0H
*MEXIT #=   173 LV= 1 RT1
         L     R0,=X'00000000'
         L     R2,=X'00000000'
         ALR   R0,R2
*MCALL #=   174 LV= 1          RT1   CC0        Z,NC
         DS    0H
RT1_TEST150      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE150
         LTORG 
RT1_CCE150      DS 0H
*MEXIT #=   174 LV= 1 RT1
         CL    R0,=X'00000000'
*MCALL #=   175 LV= 1          RT1   CCE
         DS    0H
RT1_TEST151      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE151
         LTORG 
RT1_CCE151      DS 0H
*MEXIT #=   175 LV= 1 RT1
* 1F   SLR
         L     R0,=X'FFFFFFFF'  RPI-879
         L     R2,=X'80000000'  RPI-879
         SLR   R0,R2            RPI-879
*MCALL #=   176 LV= 1          RT1   CC3        NZ,NB RPI-879
         DS    0H
RT1_TEST152      BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC3152
         LTORG 
RT1_CC3152      DS 0H
*MEXIT #=   176 LV= 1 RT1
         CL    R0,=X'7FFFFFFF'  RPI-879
*MCALL #=   177 LV= 1          RT1   CCE              RPI-879
         DS    0H
RT1_TEST153      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE153
         LTORG 
RT1_CCE153      DS 0H
*MEXIT #=   177 LV= 1 RT1
         L     R0,=X'80000000'  RPI-831
         L     R2,=X'A0000000'
         SLR   R0,R2
*MCALL #=   178 LV= 1          RT1   CC1        NZ,B
         DS    0H
RT1_TEST154      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL154
         LTORG 
RT1_CCL154      DS 0H
*MEXIT #=   178 LV= 1 RT1
         CL    R0,=X'E0000000'
*MCALL #=   179 LV= 1          RT1   CCE
         DS    0H
RT1_TEST155      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE155
         LTORG 
RT1_CCE155      DS 0H
*MEXIT #=   179 LV= 1 RT1
         L     R0,=F'3'
         L     R2,=F'2'
         SLR   R0,R2
*MCALL #=   180 LV= 1          RT1   CC3        NZ,NB
         DS    0H
RT1_TEST156      BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC3156
         LTORG 
RT1_CC3156      DS 0H
*MEXIT #=   180 LV= 1 RT1
         CL    R0,=F'1'
*MCALL #=   181 LV= 1          RT1   CCE
         DS    0H
RT1_TEST157      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE157
         LTORG 
RT1_CCE157      DS 0H
*MEXIT #=   181 LV= 1 RT1
         L     R0,=X'80000000'
         L     R2,=X'00000001'
         SLR   R0,R2
*MCALL #=   182 LV= 1          RT1   CC3        NZ,NB
         DS    0H
RT1_TEST158      BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC3158
         LTORG 
RT1_CC3158      DS 0H
*MEXIT #=   182 LV= 1 RT1
         CL    R0,=X'7FFFFFFF'
*MCALL #=   183 LV= 1          RT1   CCE
         DS    0H
RT1_TEST159      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE159
         LTORG 
RT1_CCE159      DS 0H
*MEXIT #=   183 LV= 1 RT1
         L     R0,=X'00000000'
         L     R2,=X'00000001'
         SLR   R0,R2
*MCALL #=   184 LV= 1          RT1   CC1        NZ,B
         DS    0H
RT1_TEST160      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL160
         LTORG 
RT1_CCL160      DS 0H
*MEXIT #=   184 LV= 1 RT1
         CL    R0,=X'FFFFFFFF'
*MCALL #=   185 LV= 1          RT1   CCE
         DS    0H
RT1_TEST161      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE161
         LTORG 
RT1_CCE161      DS 0H
*MEXIT #=   185 LV= 1 RT1
         L     R0,=X'00000001'
         L     R2,=X'00000001'
         SLR   R0,R2
*MCALL #=   186 LV= 1          RT1   CC2        Z,NB
         DS    0H
RT1_TEST162      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH162
         LTORG 
RT1_CCH162      DS 0H
*MEXIT #=   186 LV= 1 RT1
         CL    R0,=X'00000000'
*MCALL #=   187 LV= 1          RT1   CCE
         DS    0H
RT1_TEST163      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE163
         LTORG 
RT1_CCE163      DS 0H
*MEXIT #=   187 LV= 1 RT1
         L     R0,=X'00000000'
         L     R2,=X'00000002'
         SLR   R0,R2
*MCALL #=   188 LV= 1          RT1   CC1        NZ,B
         DS    0H
RT1_TEST164      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL164
         LTORG 
RT1_CCL164      DS 0H
*MEXIT #=   188 LV= 1 RT1
         CL    R0,=X'FFFFFFFE'
*MCALL #=   189 LV= 1          RT1   CCE
         DS    0H
RT1_TEST165      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE165
         LTORG 
RT1_CCE165      DS 0H
*MEXIT #=   189 LV= 1 RT1
* 40   STH
         L     R0,=F'1'
         STH   R0,WORD
         CLC   WORD(2),=H'1'
*MCALL #=   190 LV= 1          RT1   CCE
         DS    0H
RT1_TEST166      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE166
         LTORG 
RT1_CCE166      DS 0H
*MEXIT #=   190 LV= 1 RT1
         L     R0,=F'-1'
         STH   R0,WORD
         CLC   WORD(2),=H'-1'
*MCALL #=   191 LV= 1          RT1   CCE
         DS    0H
RT1_TEST167      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE167
         LTORG 
RT1_CCE167      DS 0H
*MEXIT #=   191 LV= 1 RT1
* 41   LA
         LA    R1,*+4
         CL    R1,=A(*)
*MCALL #=   192 LV= 1          RT1   CCE
         DS    0H
RT1_TEST168      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE168
         LTORG 
RT1_CCE168      DS 0H
*MEXIT #=   192 LV= 1 RT1
* 42   STC
         LA    R0,X'FF'
         STC   R0,BYTE
         CLI   BYTE,X'FF'
*MCALL #=   193 LV= 1          RT1   CCE
         DS    0H
RT1_TEST169      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE169
         LTORG 
RT1_CCE169      DS 0H
*MEXIT #=   193 LV= 1 RT1
* 43   IC
         SR    R0,R0
         IC    R0,=C'A'
         CL    R0,=A(C'A')
*MCALL #=   194 LV= 1          RT1   CCE
         DS    0H
RT1_TEST170      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE170
         LTORG 
RT1_CCE170      DS 0H
*MEXIT #=   194 LV= 1 RT1
         LA    R1,=C'AB'
         L     R2,=F'-1'
         IC    R0,1(R1)
         CLM   R0,1,=C'B'
*MCALL #=   195 LV= 1          RT1   CCE
         DS    0H
RT1_TEST171      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE171
         LTORG 
RT1_CCE171      DS 0H
*MEXIT #=   195 LV= 1 RT1
         IC    R0,1(R1,R2)      RPI-815 INDEX BY -1
         CLM   R0,1,=C'A'
*MCALL #=   196 LV= 1          RT1   CCE
         DS    0H
RT1_TEST172      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE172
         LTORG 
RT1_CCE172      DS 0H
*MEXIT #=   196 LV= 1 RT1
* 44   EX
         MVI   BYTE,C'A'
         EX    0,EX1
         B     EX2
EX1      MVI   BYTE,C'B'
EX2      CLI   BYTE,C'B'
*MCALL #=   197 LV= 1          RT1   CCE
         DS    0H
RT1_TEST173      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE173
         LTORG 
RT1_CCE173      DS 0H
*MEXIT #=   197 LV= 1 RT1
         MVI   BYTE,C'A'
         LA    1,C'B'
         EX    1,EX3
         B     EX4
EX3      MVI   BYTE,C'B'
EX4      CLI   BYTE,C'B'
*MCALL #=   198 LV= 1          RT1   CCE
         DS    0H
RT1_TEST174      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE174
         LTORG 
RT1_CCE174      DS 0H
*MEXIT #=   198 LV= 1 RT1
         EX    0,EX5
*MCALL #=   199 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   199 LV= 1 RT1
EX5      B     EX6
EX6      EQU   *
         LA    2,EX8
         EX    0,EX9
         B     EX10
*MCALL #=   200 LV= 1 EX7      WTO   'EX BAL RTN ENTERED'
EX7      DS    0H
         BRAS  1,*+(WTO#0200_EOT-*+1)/2*2
         DC    AL2(WTO#0200_EOT-*,0),C'EX BAL RTN ENTERED'
WTO#0200_EOT     EQU *
         SVC   35
*MEXIT #=   200 LV= 1 WTO
         BR    2
*MCALL #=   201 LV= 1 EX8      RT1   ABORT
EX8      DS    0H
         B      RT1_ABORT
*MEXIT #=   201 LV= 1 RT1
EX9      BAL   2,EX7
*MCALL #=   202 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   202 LV= 1 RT1
EX10     EQU   *
* 45   BAL
BAL1     BAL   R1,BAL2
*MCALL #=   203 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   203 LV= 1 RT1
BAL2     EQU   *
         NILH  R1,X'7FFF'
         CL    R1,=A(BAL1+4)
*MCALL #=   204 LV= 1          RT1   CCE
         DS    0H
RT1_TEST179      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE179
         LTORG 
RT1_CCE179      DS 0H
*MEXIT #=   204 LV= 1 RT1
* 46   BCT
         LA    R1,10
         SR    R2,R2
BCT1     LA    R2,1(R2)
         BCT   R1,BCT1
         CL    R1,=F'0'
*MCALL #=   205 LV= 1          RT1   CCE
         DS    0H
RT1_TEST180      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE180
         LTORG 
RT1_CCE180      DS 0H
*MEXIT #=   205 LV= 1 RT1
         CL    R2,=F'10'
*MCALL #=   206 LV= 1          RT1   CCE
         DS    0H
RT1_TEST181      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE181
         LTORG 
RT1_CCE181      DS 0H
*MEXIT #=   206 LV= 1 RT1
* 47   BC
         NOP   BCERR
         CLI   =X'1',1
         BNE   BCERR
*MCALL #=   207 LV= 1          RT1   CCE
         DS    0H
RT1_TEST182      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE182
         LTORG 
RT1_CCE182      DS 0H
*MEXIT #=   207 LV= 1 RT1
         CLI   =X'1',2
         BNL   BCERR
         BE    BCERR
*MCALL #=   208 LV= 1          RT1   CCL
         DS    0H
RT1_TEST183      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL183
         LTORG 
RT1_CCL183      DS 0H
*MEXIT #=   208 LV= 1 RT1
         CLI   =X'2',1
         BNH   BCERR
         BE    BCERR
*MCALL #=   209 LV= 1          RT1   CCH
         DS    0H
RT1_TEST184      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH184
         LTORG 
RT1_CCH184      DS 0H
*MEXIT #=   209 LV= 1 RT1
         B     BCOK
*MCALL #=   210 LV= 1 BCERR    RT1   ABORT
BCERR    DS    0H
         B      RT1_ABORT
*MEXIT #=   210 LV= 1 RT1
BCOK     EQU   *
* 48   LH
         LH    R0,=H'-2'
         CL    R0,=F'-2'
*MCALL #=   211 LV= 1          RT1   CCE
         DS    0H
RT1_TEST186      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE186
         LTORG 
RT1_CCE186      DS 0H
*MEXIT #=   211 LV= 1 RT1
* 49   CH
         LH    R0,=H'1'
         CH    R0,=H'1'
*MCALL #=   212 LV= 1          RT1   CCE
         DS    0H
RT1_TEST187      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE187
         LTORG 
RT1_CCE187      DS 0H
*MEXIT #=   212 LV= 1 RT1
         LH    R0,=H'-1'
         CH    R0,=H'1'
*MCALL #=   213 LV= 1          RT1   CCL
         DS    0H
RT1_TEST188      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL188
         LTORG 
RT1_CCL188      DS 0H
*MEXIT #=   213 LV= 1 RT1
         LH    R0,=H'1'
         CH    R0,=H'-1'
*MCALL #=   214 LV= 1          RT1   CCH
         DS    0H
RT1_TEST189      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH189
         LTORG 
RT1_CCH189      DS 0H
*MEXIT #=   214 LV= 1 RT1
* 4A   AH
         LH    R0,=H'1'
         AH    R0,=H'3'
*MCALL #=   215 LV= 1          RT1   CCH
         DS    0H
RT1_TEST190      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH190
         LTORG 
RT1_CCH190      DS 0H
*MEXIT #=   215 LV= 1 RT1
         CH    R0,=H'4'
*MCALL #=   216 LV= 1          RT1   CCE
         DS    0H
RT1_TEST191      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE191
         LTORG 
RT1_CCE191      DS 0H
*MEXIT #=   216 LV= 1 RT1
* 4B   SH
         LH    R0,=H'1'
         SH    R0,=H'3'
*MCALL #=   217 LV= 1          RT1   CCL
         DS    0H
RT1_TEST192      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL192
         LTORG 
RT1_CCL192      DS 0H
*MEXIT #=   217 LV= 1 RT1
         CH    R0,=H'-2'
*MCALL #=   218 LV= 1          RT1   CCE
         DS    0H
RT1_TEST193      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE193
         LTORG 
RT1_CCE193      DS 0H
*MEXIT #=   218 LV= 1 RT1
* 4C   MH
         LH    R0,=H'2'
         MH    R0,=H'3'
         CH    R0,=H'6'
*MCALL #=   219 LV= 1          RT1   CCE
         DS    0H
RT1_TEST194      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE194
         LTORG 
RT1_CCE194      DS 0H
*MEXIT #=   219 LV= 1 RT1
* 4D   BAS
BAS1     BAS   R1,BAS2
*MCALL #=   220 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   220 LV= 1 RT1
BAS2     EQU   *
         NILH  R1,X'7FFF'
         CL    R1,=A(BAS1+4)
*MCALL #=   221 LV= 1          RT1   CCE
         DS    0H
RT1_TEST196      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE196
         LTORG 
RT1_CCE196      DS 0H
*MEXIT #=   221 LV= 1 RT1
* 4E   CVD
         LA    R1,123
         CVD   R1,PWORK
*MCALL #=   222 LV= 1          RT1   CCE,PWORK,=PL8'123'
         DS    0H
         CLC   PWORK,=PL8'123'
RT1_TEST197      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE197
         LTORG 
RT1_CCE197      DS 0H
*MEXIT #=   222 LV= 1 RT1
* 4F   CVB
         CVB   R0,=PL8'2147483647'
         CVD   R0,PWORK
         CP  PWORK,=P'2147483647'
*MCALL #=   223 LV= 1          RT1 CCE
         DS    0H
RT1_TEST198      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE198
         LTORG 
RT1_CCE198      DS 0H
*MEXIT #=   223 LV= 1 RT1
* 50   ST
         LA    R1,1234
         ST    R1,WORD
*MCALL #=   224 LV= 1          RT1   CCE,WORD,=F'1234'
         DS    0H
         CLC   WORD,=F'1234'
RT1_TEST199      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE199
         LTORG 
RT1_CCE199      DS 0H
*MEXIT #=   224 LV= 1 RT1
* 54   N
         L     R0,=X'12345678'
         N     R0,=X'1335577F'
*MCALL #=   225 LV= 1          RT1   CCL
         DS    0H
RT1_TEST200      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL200
         LTORG 
RT1_CCL200      DS 0H
*MEXIT #=   225 LV= 1 RT1
         CL    R0,=X'12345678'
*MCALL #=   226 LV= 1          RT1   CCE
         DS    0H
RT1_TEST201      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE201
         LTORG 
RT1_CCE201      DS 0H
*MEXIT #=   226 LV= 1 RT1
* 55   CL
         LA    R1,1
         CL    R1,=F'1'
*MCALL #=   227 LV= 1          RT1   CCE
         DS    0H
RT1_TEST202      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE202
         LTORG 
RT1_CCE202      DS 0H
*MEXIT #=   227 LV= 1 RT1
         LA    R1,0
         CL    R1,=F'1'
*MCALL #=   228 LV= 1          RT1   CCL
         DS    0H
RT1_TEST203      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL203
         LTORG 
RT1_CCL203      DS 0H
*MEXIT #=   228 LV= 1 RT1
         LA    R1,2
         CL    R1,=F'1'
*MCALL #=   229 LV= 1          RT1   CCH
         DS    0H
RT1_TEST204      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH204
         LTORG 
RT1_CCH204      DS 0H
*MEXIT #=   229 LV= 1 RT1
         L     R1,=F'-1'
         CL    R1,=F'1'
*MCALL #=   230 LV= 1          RT1   CCH
         DS    0H
RT1_TEST205      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH205
         LTORG 
RT1_CCH205      DS 0H
*MEXIT #=   230 LV= 1 RT1
         L     R1,=F'1'
         CL    R1,=F'-1'
*MCALL #=   231 LV= 1          RT1   CCL
         DS    0H
RT1_TEST206      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL206
         LTORG 
RT1_CCL206      DS 0H
*MEXIT #=   231 LV= 1 RT1
* 56   O
         L     R0,=X'12345678'
         O     R0,=X'11315177'
*MCALL #=   232 LV= 1          RT1   CCL
         DS    0H
RT1_TEST207      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL207
         LTORG 
RT1_CCL207      DS 0H
*MEXIT #=   232 LV= 1 RT1
         CL    R0,=X'1335577F'
*MCALL #=   233 LV= 1          RT1   CCE
         DS    0H
RT1_TEST208      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE208
         LTORG 
RT1_CCE208      DS 0H
*MEXIT #=   233 LV= 1 RT1
* 57   X
         L     R0,=X'12345678'
         X     R0,=X'11315177'
*MCALL #=   234 LV= 1          RT1   CCL
         DS    0H
RT1_TEST209      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL209
         LTORG 
RT1_CCL209      DS 0H
*MEXIT #=   234 LV= 1 RT1
         CL    R0,=X'0305070F'
*MCALL #=   235 LV= 1          RT1   CCE
         DS    0H
RT1_TEST210      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE210
         LTORG 
RT1_CCE210      DS 0H
*MEXIT #=   235 LV= 1 RT1
* 58   L
         L     R1,=F'12345'
         CL    R1,=A(12345)
*MCALL #=   236 LV= 1          RT1   CCE
         DS    0H
RT1_TEST211      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE211
         LTORG 
RT1_CCE211      DS 0H
*MEXIT #=   236 LV= 1 RT1
* 59   C
         LA    R1,1
         C     R1,=F'1'
*MCALL #=   237 LV= 1          RT1   CCE
         DS    0H
RT1_TEST212      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE212
         LTORG 
RT1_CCE212      DS 0H
*MEXIT #=   237 LV= 1 RT1
         LA    R1,0
         C     R1,=F'1'
*MCALL #=   238 LV= 1          RT1   CCL
         DS    0H
RT1_TEST213      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL213
         LTORG 
RT1_CCL213      DS 0H
*MEXIT #=   238 LV= 1 RT1
         LA    R1,2
         C     R1,=F'1'
*MCALL #=   239 LV= 1          RT1   CCH
         DS    0H
RT1_TEST214      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH214
         LTORG 
RT1_CCH214      DS 0H
*MEXIT #=   239 LV= 1 RT1
         L     R1,=F'-1'
         C     R1,=F'1'
*MCALL #=   240 LV= 1          RT1   CCL
         DS    0H
RT1_TEST215      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL215
         LTORG 
RT1_CCL215      DS 0H
*MEXIT #=   240 LV= 1 RT1
         L     R1,=F'1'
         C     R1,=F'-1'
*MCALL #=   241 LV= 1          RT1   CCH
         DS    0H
RT1_TEST216      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH216
         LTORG 
RT1_CCH216      DS 0H
*MEXIT #=   241 LV= 1 RT1
* 5A   A
         L     R0,=F'1'
         A     R0,=F'3'
*MCALL #=   242 LV= 1          RT1   CCH
         DS    0H
RT1_TEST217      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH217
         LTORG 
RT1_CCH217      DS 0H
*MEXIT #=   242 LV= 1 RT1
         C     R0,=F'4'
*MCALL #=   243 LV= 1          RT1   CCE
         DS    0H
RT1_TEST218      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE218
         LTORG 
RT1_CCE218      DS 0H
*MEXIT #=   243 LV= 1 RT1
* 5B   S
         L     R0,=F'1'
         S     R0,=F'3'
*MCALL #=   244 LV= 1          RT1   CCL
         DS    0H
RT1_TEST219      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL219
         LTORG 
RT1_CCL219      DS 0H
*MEXIT #=   244 LV= 1 RT1
         C     R0,=F'-2'
*MCALL #=   245 LV= 1          RT1   CCE
         DS    0H
RT1_TEST220      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE220
         LTORG 
RT1_CCE220      DS 0H
*MEXIT #=   245 LV= 1 RT1
* 5C   M
         L     R0,=C'JUNK'
         L     R1,=F'2'
         M     R0,=F'3'
         C     R0,=F'0'
*MCALL #=   246 LV= 1          RT1   CCE
         DS    0H
RT1_TEST221      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE221
         LTORG 
RT1_CCE221      DS 0H
*MEXIT #=   246 LV= 1 RT1
         C     R1,=F'6'
*MCALL #=   247 LV= 1          RT1   CCE
         DS    0H
RT1_TEST222      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE222
         LTORG 
RT1_CCE222      DS 0H
*MEXIT #=   247 LV= 1 RT1
* 5D   D
         LM    R0,R1,=F'0,100'
         D     R0,=F'33'
         CL    R0,=F'1'
*MCALL #=   248 LV= 1          RT1   CCE
         DS    0H
RT1_TEST223      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE223
         LTORG 
RT1_CCE223      DS 0H
*MEXIT #=   248 LV= 1 RT1
         CL    R1,=F'3'
*MCALL #=   249 LV= 1          RT1   CCE
         DS    0H
RT1_TEST224      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE224
         LTORG 
RT1_CCE224      DS 0H
*MEXIT #=   249 LV= 1 RT1
         LM    R0,R1,=FL8'1E17'
         D     R0,=F'1E9'
         CL    R0,=F'0'
*MCALL #=   250 LV= 1          RT1   CCE
         DS    0H
RT1_TEST225      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE225
         LTORG 
RT1_CCE225      DS 0H
*MEXIT #=   250 LV= 1 RT1
         CL    R1,=F'1E8'
*MCALL #=   251 LV= 1          RT1   CCE
         DS    0H
RT1_TEST226      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE226
         LTORG 
RT1_CCE226      DS 0H
*MEXIT #=   251 LV= 1 RT1
         LM    R0,R1,=FL8'-1E17'
         D     R0,=F'1E9'
         CL    R0,=F'0'
*MCALL #=   252 LV= 1          RT1   CCE
         DS    0H
RT1_TEST227      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE227
         LTORG 
RT1_CCE227      DS 0H
*MEXIT #=   252 LV= 1 RT1
         CL    R1,=F'-1E8'
*MCALL #=   253 LV= 1          RT1   CCE
         DS    0H
RT1_TEST228      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE228
         LTORG 
RT1_CCE228      DS 0H
*MEXIT #=   253 LV= 1 RT1
         LM    R0,R1,=FL8'1E17'
         D     R0,=F'-1E9'
         CL    R0,=F'0'
*MCALL #=   254 LV= 1          RT1   CCE
         DS    0H
RT1_TEST229      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE229
         LTORG 
RT1_CCE229      DS 0H
*MEXIT #=   254 LV= 1 RT1
         CL    R1,=F'-1E8'
*MCALL #=   255 LV= 1          RT1   CCE
         DS    0H
RT1_TEST230      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE230
         LTORG 
RT1_CCE230      DS 0H
*MEXIT #=   255 LV= 1 RT1
         LM    R0,R1,=F'1,3'
         D     R0,=F'4'
         CL    R0,=F'3'
*MCALL #=   256 LV= 1          RT1   CCE
         DS    0H
RT1_TEST231      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE231
         LTORG 
RT1_CCE231      DS 0H
*MEXIT #=   256 LV= 1 RT1
         CL    R1,=FS30'1'
*MCALL #=   257 LV= 1          RT1   CCE
         DS    0H
RT1_TEST232      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE232
         LTORG 
RT1_CCE232      DS 0H
*MEXIT #=   257 LV= 1 RT1
         LM    R0,R1,=F'1,3'
         D     R0,=F'-4'
         CL    R0,=F'3'
*MCALL #=   258 LV= 1          RT1   CCE
         DS    0H
RT1_TEST233      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE233
         LTORG 
RT1_CCE233      DS 0H
*MEXIT #=   258 LV= 1 RT1
         CL    R1,=FS30'-1'
*MCALL #=   259 LV= 1          RT1   CCE
         DS    0H
RT1_TEST234      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE234
         LTORG 
RT1_CCE234      DS 0H
*MEXIT #=   259 LV= 1 RT1
* 5E   AL
         L     R0,=F'3'
         AL    R0,=F'2'
*MCALL #=   260 LV= 1          RT1   CC1        NZ,NC
         DS    0H
RT1_TEST235      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL235
         LTORG 
RT1_CCL235      DS 0H
*MEXIT #=   260 LV= 1 RT1
         CL    R0,=F'5'
*MCALL #=   261 LV= 1          RT1   CCE
         DS    0H
RT1_TEST236      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE236
         LTORG 
RT1_CCE236      DS 0H
*MEXIT #=   261 LV= 1 RT1
         L     R0,=X'80000000'
         AL    R0,=X'00000001'
*MCALL #=   262 LV= 1          RT1   CC1        NZ,NC
         DS    0H
RT1_TEST237      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL237
         LTORG 
RT1_CCL237      DS 0H
*MEXIT #=   262 LV= 1 RT1
         CL    R0,=X'80000001'
*MCALL #=   263 LV= 1          RT1   CCE
         DS    0H
RT1_TEST238      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE238
         LTORG 
RT1_CCE238      DS 0H
*MEXIT #=   263 LV= 1 RT1
         L     R0,=X'FFFFFFFF'
         AL    R0,=X'00000001'
*MCALL #=   264 LV= 1          RT1   CC2        Z,C
         DS    0H
RT1_TEST239      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH239
         LTORG 
RT1_CCH239      DS 0H
*MEXIT #=   264 LV= 1 RT1
         CL    R0,=X'00000000'
*MCALL #=   265 LV= 1          RT1   CCE
         DS    0H
RT1_TEST240      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE240
         LTORG 
RT1_CCE240      DS 0H
*MEXIT #=   265 LV= 1 RT1
         L     R0,=X'FFFFFFFF'
         AL    R0,=X'00000002'
*MCALL #=   266 LV= 1          RT1   CC3        NZ,C
         DS    0H
RT1_TEST241      BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC3241
         LTORG 
RT1_CC3241      DS 0H
*MEXIT #=   266 LV= 1 RT1
         CL    R0,=X'00000001'
*MCALL #=   267 LV= 1          RT1   CCE
         DS    0H
RT1_TEST242      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE242
         LTORG 
RT1_CCE242      DS 0H
*MEXIT #=   267 LV= 1 RT1
         L     R0,=X'FFFFFFFF'  RPI-376
         AL    R0,=X'FFFFFFFF'
*MCALL #=   268 LV= 1          RT1   CC3        NZ,C
         DS    0H
RT1_TEST243      BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC3243
         LTORG 
RT1_CC3243      DS 0H
*MEXIT #=   268 LV= 1 RT1
         CL    R0,=X'FFFFFFFE'
*MCALL #=   269 LV= 1          RT1   CCE
         DS    0H
RT1_TEST244      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE244
         LTORG 
RT1_CCE244      DS 0H
*MEXIT #=   269 LV= 1 RT1
         L     R0,=X'00000000'
         AL    R0,=X'00000000'
*MCALL #=   270 LV= 1          RT1   CC0        Z,NC
         DS    0H
RT1_TEST245      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE245
         LTORG 
RT1_CCE245      DS 0H
*MEXIT #=   270 LV= 1 RT1
         CL    R0,=X'00000000'
*MCALL #=   271 LV= 1          RT1   CCE
         DS    0H
RT1_TEST246      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE246
         LTORG 
RT1_CCE246      DS 0H
*MEXIT #=   271 LV= 1 RT1
* 5F   SL
         L     R0,=X'FFFFFFFF'  RPI-879
         SL    R0,=X'80000000'  RPI-879
*MCALL #=   272 LV= 1          RT1   CC3        NZ,NB RPI-879
         DS    0H
RT1_TEST247      BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC3247
         LTORG 
RT1_CC3247      DS 0H
*MEXIT #=   272 LV= 1 RT1
         CL    R0,=X'7FFFFFFF'  RPI-879
*MCALL #=   273 LV= 1          RT1   CCE              RPI-879
         DS    0H
RT1_TEST248      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE248
         LTORG 
RT1_CCE248      DS 0H
*MEXIT #=   273 LV= 1 RT1
         L     R0,=X'80000000'  RPI-831
         SL    R0,=X'A0000000'
*MCALL #=   274 LV= 1          RT1   CC1        NZ,B
         DS    0H
RT1_TEST249      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL249
         LTORG 
RT1_CCL249      DS 0H
*MEXIT #=   274 LV= 1 RT1
         CL    R0,=X'E0000000'
*MCALL #=   275 LV= 1          RT1   CCE
         DS    0H
RT1_TEST250      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE250
         LTORG 
RT1_CCE250      DS 0H
*MEXIT #=   275 LV= 1 RT1
         L     R0,=F'3'
         SL    R0,=F'2'
*MCALL #=   276 LV= 1          RT1   CC3        NZ,NB
         DS    0H
RT1_TEST251      BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC3251
         LTORG 
RT1_CC3251      DS 0H
*MEXIT #=   276 LV= 1 RT1
         CL    R0,=F'1'
*MCALL #=   277 LV= 1          RT1   CCE
         DS    0H
RT1_TEST252      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE252
         LTORG 
RT1_CCE252      DS 0H
*MEXIT #=   277 LV= 1 RT1
         L     R0,=X'80000000'
         SL    R0,=X'00000001'
*MCALL #=   278 LV= 1          RT1   CC3        NZ,NB
         DS    0H
RT1_TEST253      BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC3253
         LTORG 
RT1_CC3253      DS 0H
*MEXIT #=   278 LV= 1 RT1
         CL    R0,=X'7FFFFFFF'
*MCALL #=   279 LV= 1          RT1   CCE
         DS    0H
RT1_TEST254      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE254
         LTORG 
RT1_CCE254      DS 0H
*MEXIT #=   279 LV= 1 RT1
         L     R0,=X'00000000'
         SL    R0,=X'00000001'
*MCALL #=   280 LV= 1          RT1   CC1        NZ,B
         DS    0H
RT1_TEST255      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL255
         LTORG 
RT1_CCL255      DS 0H
*MEXIT #=   280 LV= 1 RT1
         CL    R0,=X'FFFFFFFF'
*MCALL #=   281 LV= 1          RT1   CCE
         DS    0H
RT1_TEST256      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE256
         LTORG 
RT1_CCE256      DS 0H
*MEXIT #=   281 LV= 1 RT1
         L     R0,=X'00000001'
         SL    R0,=X'00000001'
*MCALL #=   282 LV= 1          RT1   CC2        Z,NB
         DS    0H
RT1_TEST257      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH257
         LTORG 
RT1_CCH257      DS 0H
*MEXIT #=   282 LV= 1 RT1
         CL    R0,=X'00000000'
*MCALL #=   283 LV= 1          RT1   CCE
         DS    0H
RT1_TEST258      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE258
         LTORG 
RT1_CCE258      DS 0H
*MEXIT #=   283 LV= 1 RT1
         L     R0,=X'00000000'
         SL    R0,=X'00000002'
*MCALL #=   284 LV= 1          RT1   CC1        NZ,B
         DS    0H
RT1_TEST259      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL259
         LTORG 
RT1_CCL259      DS 0H
*MEXIT #=   284 LV= 1 RT1
         CL    R0,=X'FFFFFFFE'
*MCALL #=   285 LV= 1          RT1   CCE
         DS    0H
RT1_TEST260      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE260
         LTORG 
RT1_CCE260      DS 0H
*MEXIT #=   285 LV= 1 RT1
* 71   MS
         L     R0,=F'2'
         MS    R0,=F'3'
         C     R0,=F'6'
*MCALL #=   286 LV= 1          RT1   CCE
         DS    0H
RT1_TEST261      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE261
         LTORG 
RT1_CCE261      DS 0H
*MEXIT #=   286 LV= 1 RT1
* 84   BRXH
         LM    R1,R3,=A(2,-1,0)
         BRXH  R1,R2,BRXH2
*MCALL #=   287 LV= 1 BRXH1    RT1   ABORT
BRXH1    DS    0H
         B      RT1_ABORT
*MEXIT #=   287 LV= 1 RT1
BRXH2    EQU   *
         CL    R1,=A(1)
*MCALL #=   288 LV= 1          RT1   CCE
         DS    0H
RT1_TEST263      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE263
         LTORG 
RT1_CCE263      DS 0H
*MEXIT #=   288 LV= 1 RT1
         BRXH  R1,R2,BRXH1
         CL    R1,=A(0)
*MCALL #=   289 LV= 1          RT1   CCE
         DS    0H
RT1_TEST264      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE264
         LTORG 
RT1_CCE264      DS 0H
*MEXIT #=   289 LV= 1 RT1
         LM    R1,R3,=A(2,-10,-1)
         BRXH  R1,R3,BRXH3
*MCALL #=   290 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   290 LV= 1 RT1
BRXH3    EQU   *
         CL    R1,=A(1)
*MCALL #=   291 LV= 1          RT1   CCE
         DS    0H
RT1_TEST266      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE266
         LTORG 
RT1_CCE266      DS 0H
*MEXIT #=   291 LV= 1 RT1
         BRXH  R1,R3,BRXH4
*MCALL #=   292 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   292 LV= 1 RT1
BRXH4    EQU   *
         CL    R1,=A(0)
*MCALL #=   293 LV= 1          RT1   CCE
         DS    0H
RT1_TEST268      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE268
         LTORG 
RT1_CCE268      DS 0H
*MEXIT #=   293 LV= 1 RT1
         BRXH  R1,R3,BRXH1
         CL    R1,=F'-1'
*MCALL #=   294 LV= 1          RT1   CCE
         DS    0H
RT1_TEST269      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE269
         LTORG 
RT1_CCE269      DS 0H
*MEXIT #=   294 LV= 1 RT1
* 85   BRXLE
         LM    R1,R3,=A(1,1,2)
         BRXLE R1,R2,BRXLE2
*MCALL #=   295 LV= 1 BRXLE1   RT1   ABORT
BRXLE1   DS    0H
         B      RT1_ABORT
*MEXIT #=   295 LV= 1 RT1
BRXLE2   EQU   *
         CL    R1,=A(2)
*MCALL #=   296 LV= 1          RT1   CCE
         DS    0H
RT1_TEST271      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE271
         LTORG 
RT1_CCE271      DS 0H
*MEXIT #=   296 LV= 1 RT1
         BRXLE R1,R2,BRXLE1
         CL    R1,=A(3)
*MCALL #=   297 LV= 1          RT1   CCE
         DS    0H
RT1_TEST272      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE272
         LTORG 
RT1_CCE272      DS 0H
*MEXIT #=   297 LV= 1 RT1
         LM    R1,R3,=A(0,-10,1)
         BRXLE R1,R3,BRXLE3
*MCALL #=   298 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   298 LV= 1 RT1
BRXLE3   EQU   *
         CL    R1,=A(1)
*MCALL #=   299 LV= 1          RT1   CCE
         DS    0H
RT1_TEST274      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE274
         LTORG 
RT1_CCE274      DS 0H
*MEXIT #=   299 LV= 1 RT1
         BRXLE R1,R3,BRXLE1
         CL    R1,=F'2'
*MCALL #=   300 LV= 1          RT1   CCE
         DS    0H
RT1_TEST275      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE275
         LTORG 
RT1_CCE275      DS 0H
*MEXIT #=   300 LV= 1 RT1
* 86   BXH
         LM    R1,R3,=A(2,-1,0)
         BXH   R1,R2,BXH2
         B     RT1_ABORT
BXH2     EQU   *
         CL    R1,=A(1)
*MCALL #=   301 LV= 1          RT1   CCE
         DS    0H
RT1_TEST276      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE276
         LTORG 
RT1_CCE276      DS 0H
*MEXIT #=   301 LV= 1 RT1
         BXH   R1,R2,RT1_ABORT
         CL    R1,=A(0)
*MCALL #=   302 LV= 1          RT1   CCE
         DS    0H
RT1_TEST277      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE277
         LTORG 
RT1_CCE277      DS 0H
*MEXIT #=   302 LV= 1 RT1
         LM    R1,R3,=A(2,-10,-1)
         BXH   R1,R3,BXH3
         B     RT1_ABORT
BXH3     EQU   *
         CL    R1,=A(1)
*MCALL #=   303 LV= 1          RT1   CCE
         DS    0H
RT1_TEST278      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE278
         LTORG 
RT1_CCE278      DS 0H
*MEXIT #=   303 LV= 1 RT1
         BXH   R1,R3,BXH4
         B     RT1_ABORT
BXH4     EQU   *
         CL    R1,=A(0)
*MCALL #=   304 LV= 1          RT1   CCE
         DS    0H
RT1_TEST279      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE279
         LTORG 
RT1_CCE279      DS 0H
*MEXIT #=   304 LV= 1 RT1
         BXH   R1,R3,RT1_ABORT
         CL    R1,=F'-1'
*MCALL #=   305 LV= 1          RT1   CCE
         DS    0H
RT1_TEST280      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE280
         LTORG 
RT1_CCE280      DS 0H
*MEXIT #=   305 LV= 1 RT1
* 87   BXLE
         LM    R1,R3,=A(1,1,2)
         BXLE  R1,R2,BXLE2
         B     RT1_ABORT
BXLE2    EQU   *
         CL    R1,=A(2)
*MCALL #=   306 LV= 1          RT1   CCE
         DS    0H
RT1_TEST281      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE281
         LTORG 
RT1_CCE281      DS 0H
*MEXIT #=   306 LV= 1 RT1
         BXLE  R1,R2,RT1_ABORT
         CL    R1,=A(3)
*MCALL #=   307 LV= 1          RT1   CCE
         DS    0H
RT1_TEST282      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE282
         LTORG 
RT1_CCE282      DS 0H
*MEXIT #=   307 LV= 1 RT1
         LM    R1,R3,=A(0,-10,1)
         BXLE  R1,R3,BXLE3
*MCALL #=   308 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   308 LV= 1 RT1
BXLE3    EQU   *
         CL    R1,=A(1)
*MCALL #=   309 LV= 1          RT1   CCE
         DS    0H
RT1_TEST284      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE284
         LTORG 
RT1_CCE284      DS 0H
*MEXIT #=   309 LV= 1 RT1
         BXLE  R1,R3,RT1_ABORT
         CL    R1,=F'2'
*MCALL #=   310 LV= 1          RT1   CCE
         DS    0H
RT1_TEST285      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE285
         LTORG 
RT1_CCE285      DS 0H
*MEXIT #=   310 LV= 1 RT1
* 88   SRL
         LA    R0,2
         SRL   R0,1
         CL    R0,=F'1'
*MCALL #=   311 LV= 1          RT1   CCE
         DS    0H
RT1_TEST286      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE286
         LTORG 
RT1_CCE286      DS 0H
*MEXIT #=   311 LV= 1 RT1
         LA    R0,0
         SRL   R0,1
         CL    R0,=F'0'
*MCALL #=   312 LV= 1          RT1   CCE
         DS    0H
RT1_TEST287      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE287
         LTORG 
RT1_CCE287      DS 0H
*MEXIT #=   312 LV= 1 RT1
         L     R0,=F'-2'
         SRL   R0,1
         CL    R0,=X'7FFFFFFF'
*MCALL #=   313 LV= 1          RT1   CCE
         DS    0H
RT1_TEST288      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE288
         LTORG 
RT1_CCE288      DS 0H
*MEXIT #=   313 LV= 1 RT1
         L     R0,=X'C0000000'
         SRL   R0,1
         CL    R0,=X'60000000'
*MCALL #=   314 LV= 1          RT1   CCE
         DS    0H
RT1_TEST289      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE289
         LTORG 
RT1_CCE289      DS 0H
*MEXIT #=   314 LV= 1 RT1
         L     R0,=X'A0000000'
         SRL   R0,1
         CL    R0,=X'50000000'
*MCALL #=   315 LV= 1          RT1   CCE
         DS    0H
RT1_TEST290      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE290
         LTORG 
RT1_CCE290      DS 0H
*MEXIT #=   315 LV= 1 RT1
* 89   SLL
         LA    R0,1
         SLL   R0,1
         CL    R0,=F'2'
*MCALL #=   316 LV= 1          RT1   CCE
         DS    0H
RT1_TEST291      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE291
         LTORG 
RT1_CCE291      DS 0H
*MEXIT #=   316 LV= 1 RT1
         LA    R0,0
         SLL   R0,1
         CL    R0,=F'0'
*MCALL #=   317 LV= 1          RT1   CCE
         DS    0H
RT1_TEST292      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE292
         LTORG 
RT1_CCE292      DS 0H
*MEXIT #=   317 LV= 1 RT1
         L     R0,=F'-1'
         SLL   R0,1
         CL    R0,=F'-2'
*MCALL #=   318 LV= 1          RT1   CCE
         DS    0H
RT1_TEST293      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE293
         LTORG 
RT1_CCE293      DS 0H
*MEXIT #=   318 LV= 1 RT1
         L     R0,=X'60000000'
         SLL   R0,1
         CL    R0,=X'C0000000'
*MCALL #=   319 LV= 1          RT1   CCE
         DS    0H
RT1_TEST294      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE294
         LTORG 
RT1_CCE294      DS 0H
*MEXIT #=   319 LV= 1 RT1
         L     R0,=X'A0000000'
         SLL   R0,1
         CL    R0,=X'40000000'
*MCALL #=   320 LV= 1          RT1   CCE
         DS    0H
RT1_TEST295      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE295
         LTORG 
RT1_CCE295      DS 0H
*MEXIT #=   320 LV= 1 RT1
* 8A   SRA
         LA    R0,2
         SRA   R0,1
*MCALL #=   321 LV= 1          RT1   CC2
         DS    0H
RT1_TEST296      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH296
         LTORG 
RT1_CCH296      DS 0H
*MEXIT #=   321 LV= 1 RT1
         CL    R0,=F'1'
*MCALL #=   322 LV= 1          RT1   CCE
         DS    0H
RT1_TEST297      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE297
         LTORG 
RT1_CCE297      DS 0H
*MEXIT #=   322 LV= 1 RT1
         LA    R0,0
         SRA   R0,1
*MCALL #=   323 LV= 1          RT1   CC0
         DS    0H
RT1_TEST298      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE298
         LTORG 
RT1_CCE298      DS 0H
*MEXIT #=   323 LV= 1 RT1
         CL    R0,=F'0'
*MCALL #=   324 LV= 1          RT1   CCE
         DS    0H
RT1_TEST299      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE299
         LTORG 
RT1_CCE299      DS 0H
*MEXIT #=   324 LV= 1 RT1
         L     R0,=F'-2'
         SRA   R0,1
*MCALL #=   325 LV= 1          RT1   CC1
         DS    0H
RT1_TEST300      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL300
         LTORG 
RT1_CCL300      DS 0H
*MEXIT #=   325 LV= 1 RT1
         CL    R0,=F'-1'
*MCALL #=   326 LV= 1          RT1   CCE
         DS    0H
RT1_TEST301      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE301
         LTORG 
RT1_CCE301      DS 0H
*MEXIT #=   326 LV= 1 RT1
         L     R0,=X'C0000000'
         SRA   R0,1
*MCALL #=   327 LV= 1          RT1   CC1
         DS    0H
RT1_TEST302      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL302
         LTORG 
RT1_CCL302      DS 0H
*MEXIT #=   327 LV= 1 RT1
         CL    R0,=X'E0000000'
*MCALL #=   328 LV= 1          RT1   CCE
         DS    0H
RT1_TEST303      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE303
         LTORG 
RT1_CCE303      DS 0H
*MEXIT #=   328 LV= 1 RT1
* 8B   SLA
         LA    R0,1
         SLA   R0,1
*MCALL #=   329 LV= 1          RT1   CC2
         DS    0H
RT1_TEST304      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH304
         LTORG 
RT1_CCH304      DS 0H
*MEXIT #=   329 LV= 1 RT1
         CL    R0,=F'2'
*MCALL #=   330 LV= 1          RT1   CCE
         DS    0H
RT1_TEST305      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE305
         LTORG 
RT1_CCE305      DS 0H
*MEXIT #=   330 LV= 1 RT1
         LA    R0,0
         SLA   R0,1
*MCALL #=   331 LV= 1          RT1   CC0
         DS    0H
RT1_TEST306      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE306
         LTORG 
RT1_CCE306      DS 0H
*MEXIT #=   331 LV= 1 RT1
         CL    R0,=F'0'
*MCALL #=   332 LV= 1          RT1   CCE
         DS    0H
RT1_TEST307      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE307
         LTORG 
RT1_CCE307      DS 0H
*MEXIT #=   332 LV= 1 RT1
         L     R0,=F'-1'
         SLA   R0,1
*MCALL #=   333 LV= 1          RT1   CC1
         DS    0H
RT1_TEST308      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL308
         LTORG 
RT1_CCL308      DS 0H
*MEXIT #=   333 LV= 1 RT1
         CL    R0,=F'-2'
*MCALL #=   334 LV= 1          RT1   CCE
         DS    0H
RT1_TEST309      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE309
         LTORG 
RT1_CCE309      DS 0H
*MEXIT #=   334 LV= 1 RT1
         L     R0,=X'60000000'
         SLA   R0,1
*MCALL #=   335 LV= 1          RT1   CC3
         DS    0H
RT1_TEST310      BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC3310
         LTORG 
RT1_CC3310      DS 0H
*MEXIT #=   335 LV= 1 RT1
         CL    R0,=X'40000000'
*MCALL #=   336 LV= 1          RT1   CCE
         DS    0H
RT1_TEST311      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE311
         LTORG 
RT1_CCE311      DS 0H
*MEXIT #=   336 LV= 1 RT1
         L     R0,=X'A0000000'
         SLA   R0,1
*MCALL #=   337 LV= 1          RT1   CC3
         DS    0H
RT1_TEST312      BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC3312
         LTORG 
RT1_CC3312      DS 0H
*MEXIT #=   337 LV= 1 RT1
         CL    R0,=X'C0000000'
*MCALL #=   338 LV= 1          RT1   CCE
         DS    0H
RT1_TEST313      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE313
         LTORG 
RT1_CCE313      DS 0H
*MEXIT #=   338 LV= 1 RT1
* 8C   SRDL
         LM    R0,R1,=F'0,2'
         SRDL  R0,1
         CL    R0,=F'0'
*MCALL #=   339 LV= 1          RT1   CCE
         DS    0H
RT1_TEST314      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE314
         LTORG 
RT1_CCE314      DS 0H
*MEXIT #=   339 LV= 1 RT1
         CL    R1,=F'1'
*MCALL #=   340 LV= 1          RT1   CCE
         DS    0H
RT1_TEST315      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE315
         LTORG 
RT1_CCE315      DS 0H
*MEXIT #=   340 LV= 1 RT1
         LM    R0,R1,=F'0,0'
         SRDL  R0,1
         CL    R0,=F'0'
*MCALL #=   341 LV= 1          RT1   CCE
         DS    0H
RT1_TEST316      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE316
         LTORG 
RT1_CCE316      DS 0H
*MEXIT #=   341 LV= 1 RT1
         CL    R1,=F'0'
*MCALL #=   342 LV= 1          RT1   CCE
         DS    0H
RT1_TEST317      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE317
         LTORG 
RT1_CCE317      DS 0H
*MEXIT #=   342 LV= 1 RT1
         LM    R0,R1,=F'-1,-2'
         SRDL  R0,1
         CL    R0,=X'7FFFFFFF'
*MCALL #=   343 LV= 1          RT1   CCE
         DS    0H
RT1_TEST318      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE318
         LTORG 
RT1_CCE318      DS 0H
*MEXIT #=   343 LV= 1 RT1
         CL    R1,=F'-1'
*MCALL #=   344 LV= 1          RT1   CCE
         DS    0H
RT1_TEST319      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE319
         LTORG 
RT1_CCE319      DS 0H
*MEXIT #=   344 LV= 1 RT1
         LM    R0,R1,=XL4'C0000000,0'
         SRDL  R0,1
         CL    R0,=X'60000000'
*MCALL #=   345 LV= 1          RT1   CCE
         DS    0H
RT1_TEST320      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE320
         LTORG 
RT1_CCE320      DS 0H
*MEXIT #=   345 LV= 1 RT1
         CL    R1,=F'0'
*MCALL #=   346 LV= 1          RT1   CCE
         DS    0H
RT1_TEST321      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE321
         LTORG 
RT1_CCE321      DS 0H
*MEXIT #=   346 LV= 1 RT1
         LM    R0,R1,=XL4'A0000000,0'
         SRDL  R0,1
         CL    R0,=X'50000000'
*MCALL #=   347 LV= 1          RT1   CCE
         DS    0H
RT1_TEST322      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE322
         LTORG 
RT1_CCE322      DS 0H
*MEXIT #=   347 LV= 1 RT1
         CL    R1,=F'0'
*MCALL #=   348 LV= 1          RT1   CCE
         DS    0H
RT1_TEST323      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE323
         LTORG 
RT1_CCE323      DS 0H
*MEXIT #=   348 LV= 1 RT1
* 8D   SLDL
         LM    R0,R1,=F'0,1'
         SLDL  R0,1
         CL    R0,=F'0'
*MCALL #=   349 LV= 1          RT1   CCE
         DS    0H
RT1_TEST324      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE324
         LTORG 
RT1_CCE324      DS 0H
*MEXIT #=   349 LV= 1 RT1
         CL    R1,=F'2'
*MCALL #=   350 LV= 1          RT1   CCE
         DS    0H
RT1_TEST325      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE325
         LTORG 
RT1_CCE325      DS 0H
*MEXIT #=   350 LV= 1 RT1
         LM    R0,R1,=F'0,0'
         SLDL  R0,1
         CL    R0,=F'0'
*MCALL #=   351 LV= 1          RT1   CCE
         DS    0H
RT1_TEST326      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE326
         LTORG 
RT1_CCE326      DS 0H
*MEXIT #=   351 LV= 1 RT1
         CL    R1,=F'0'
*MCALL #=   352 LV= 1          RT1   CCE
         DS    0H
RT1_TEST327      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE327
         LTORG 
RT1_CCE327      DS 0H
*MEXIT #=   352 LV= 1 RT1
         LM    R0,R1,=F'-1,-1'
         SLDL  R0,1
         CL    R0,=F'-1'
*MCALL #=   353 LV= 1          RT1   CCE
         DS    0H
RT1_TEST328      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE328
         LTORG 
RT1_CCE328      DS 0H
*MEXIT #=   353 LV= 1 RT1
         CL    R1,=F'-2'
*MCALL #=   354 LV= 1          RT1   CCE
         DS    0H
RT1_TEST329      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE329
         LTORG 
RT1_CCE329      DS 0H
*MEXIT #=   354 LV= 1 RT1
         LM    R0,R1,=XL4'60000000,0'
         SLDL  R0,1
         CL    R0,=X'C0000000'
*MCALL #=   355 LV= 1          RT1   CCE
         DS    0H
RT1_TEST330      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE330
         LTORG 
RT1_CCE330      DS 0H
*MEXIT #=   355 LV= 1 RT1
         CL    R1,=F'0'
*MCALL #=   356 LV= 1          RT1   CCE
         DS    0H
RT1_TEST331      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE331
         LTORG 
RT1_CCE331      DS 0H
*MEXIT #=   356 LV= 1 RT1
         LM    R0,R1,=XL4'A0000000,0'
         SLDL  R0,1
         CL    R0,=X'40000000'
*MCALL #=   357 LV= 1          RT1   CCE
         DS    0H
RT1_TEST332      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE332
         LTORG 
RT1_CCE332      DS 0H
*MEXIT #=   357 LV= 1 RT1
         CL    R1,=F'0'
*MCALL #=   358 LV= 1          RT1   CCE
         DS    0H
RT1_TEST333      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE333
         LTORG 
RT1_CCE333      DS 0H
*MEXIT #=   358 LV= 1 RT1
* 8E   SRDA
         LM    R0,R1,=F'0,2'
         SRDA  R0,1
*MCALL #=   359 LV= 1          RT1   CC2
         DS    0H
RT1_TEST334      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH334
         LTORG 
RT1_CCH334      DS 0H
*MEXIT #=   359 LV= 1 RT1
         CL    R0,=F'0'
*MCALL #=   360 LV= 1          RT1   CCE
         DS    0H
RT1_TEST335      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE335
         LTORG 
RT1_CCE335      DS 0H
*MEXIT #=   360 LV= 1 RT1
         CL    R1,=F'1'
*MCALL #=   361 LV= 1          RT1   CCE
         DS    0H
RT1_TEST336      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE336
         LTORG 
RT1_CCE336      DS 0H
*MEXIT #=   361 LV= 1 RT1
         LM    R0,R1,=F'0,0'
         SRDA  R0,1
*MCALL #=   362 LV= 1          RT1   CC0
         DS    0H
RT1_TEST337      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE337
         LTORG 
RT1_CCE337      DS 0H
*MEXIT #=   362 LV= 1 RT1
         CL    R0,=F'0'
*MCALL #=   363 LV= 1          RT1   CCE
         DS    0H
RT1_TEST338      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE338
         LTORG 
RT1_CCE338      DS 0H
*MEXIT #=   363 LV= 1 RT1
         CL    R1,=F'0'
*MCALL #=   364 LV= 1          RT1   CCE
         DS    0H
RT1_TEST339      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE339
         LTORG 
RT1_CCE339      DS 0H
*MEXIT #=   364 LV= 1 RT1
         LM    R0,R1,=F'-1,-2'
         SRDA  R0,1
*MCALL #=   365 LV= 1          RT1   CC1
         DS    0H
RT1_TEST340      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL340
         LTORG 
RT1_CCL340      DS 0H
*MEXIT #=   365 LV= 1 RT1
         CL    R0,=F'-1'
*MCALL #=   366 LV= 1          RT1   CCE
         DS    0H
RT1_TEST341      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE341
         LTORG 
RT1_CCE341      DS 0H
*MEXIT #=   366 LV= 1 RT1
         CL    R1,=F'-1'
*MCALL #=   367 LV= 1          RT1   CCE
         DS    0H
RT1_TEST342      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE342
         LTORG 
RT1_CCE342      DS 0H
*MEXIT #=   367 LV= 1 RT1
         LM    R0,R1,=XL4'C0000000,0'
         SRDA  R0,1
*MCALL #=   368 LV= 1          RT1   CCL
         DS    0H
RT1_TEST343      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL343
         LTORG 
RT1_CCL343      DS 0H
*MEXIT #=   368 LV= 1 RT1
         CL    R0,=X'E0000000'
*MCALL #=   369 LV= 1          RT1   CCE
         DS    0H
RT1_TEST344      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE344
         LTORG 
RT1_CCE344      DS 0H
*MEXIT #=   369 LV= 1 RT1
         CL    R1,=F'0'
*MCALL #=   370 LV= 1          RT1   CCE
         DS    0H
RT1_TEST345      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE345
         LTORG 
RT1_CCE345      DS 0H
*MEXIT #=   370 LV= 1 RT1
* 8F   SLDA
         LM    R0,R1,=F'0,1'
         SLDA  R0,1
*MCALL #=   371 LV= 1          RT1   CC2
         DS    0H
RT1_TEST346      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH346
         LTORG 
RT1_CCH346      DS 0H
*MEXIT #=   371 LV= 1 RT1
         CL    R0,=F'0'
*MCALL #=   372 LV= 1          RT1   CCE
         DS    0H
RT1_TEST347      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE347
         LTORG 
RT1_CCE347      DS 0H
*MEXIT #=   372 LV= 1 RT1
         CL    R1,=F'2'
*MCALL #=   373 LV= 1          RT1   CCE
         DS    0H
RT1_TEST348      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE348
         LTORG 
RT1_CCE348      DS 0H
*MEXIT #=   373 LV= 1 RT1
         LM    R0,R1,=F'0,0'
         SLDA  R0,1
*MCALL #=   374 LV= 1          RT1   CC0
         DS    0H
RT1_TEST349      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE349
         LTORG 
RT1_CCE349      DS 0H
*MEXIT #=   374 LV= 1 RT1
         CL    R0,=F'0'
*MCALL #=   375 LV= 1          RT1   CCE
         DS    0H
RT1_TEST350      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE350
         LTORG 
RT1_CCE350      DS 0H
*MEXIT #=   375 LV= 1 RT1
         CL    R1,=F'0'
*MCALL #=   376 LV= 1          RT1   CCE
         DS    0H
RT1_TEST351      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE351
         LTORG 
RT1_CCE351      DS 0H
*MEXIT #=   376 LV= 1 RT1
         LM    R0,R1,=F'-1,-1'
         SLDA  R0,1
*MCALL #=   377 LV= 1          RT1   CC1
         DS    0H
RT1_TEST352      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL352
         LTORG 
RT1_CCL352      DS 0H
*MEXIT #=   377 LV= 1 RT1
         CL    R0,=F'-1'
*MCALL #=   378 LV= 1          RT1   CCE
         DS    0H
RT1_TEST353      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE353
         LTORG 
RT1_CCE353      DS 0H
*MEXIT #=   378 LV= 1 RT1
         CL    R1,=F'-2'
*MCALL #=   379 LV= 1          RT1   CCE
         DS    0H
RT1_TEST354      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE354
         LTORG 
RT1_CCE354      DS 0H
*MEXIT #=   379 LV= 1 RT1
         LM    R0,R1,=XL4'60000000,0'
         SLDA  R0,1
*MCALL #=   380 LV= 1          RT1   CC3
         DS    0H
RT1_TEST355      BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC3355
         LTORG 
RT1_CC3355      DS 0H
*MEXIT #=   380 LV= 1 RT1
         CL    R0,=X'40000000'
*MCALL #=   381 LV= 1          RT1   CCE
         DS    0H
RT1_TEST356      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE356
         LTORG 
RT1_CCE356      DS 0H
*MEXIT #=   381 LV= 1 RT1
         CL    R1,=F'0'
*MCALL #=   382 LV= 1          RT1   CCE
         DS    0H
RT1_TEST357      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE357
         LTORG 
RT1_CCE357      DS 0H
*MEXIT #=   382 LV= 1 RT1
         LM    R0,R1,=XL4'A0000000,0'
         SLDA  R0,1
*MCALL #=   383 LV= 1          RT1   CC3
         DS    0H
RT1_TEST358      BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC3358
         LTORG 
RT1_CC3358      DS 0H
*MEXIT #=   383 LV= 1 RT1
         CL    R0,=X'C0000000'
*MCALL #=   384 LV= 1          RT1   CCE
         DS    0H
RT1_TEST359      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE359
         LTORG 
RT1_CCE359      DS 0H
*MEXIT #=   384 LV= 1 RT1
         CL    R1,=F'0'
*MCALL #=   385 LV= 1          RT1   CCE
         DS    0H
RT1_TEST360      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE360
         LTORG 
RT1_CCE360      DS 0H
*MEXIT #=   385 LV= 1 RT1
* 90   STM
         LA    R1,1
         LA    R2,2
         STM   R1,R2,PWORK
*MCALL #=   386 LV= 1          RT1   CCE,PWORK,=A(1,2)
         DS    0H
         CLC   PWORK,=A(1,2)
RT1_TEST361      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE361
         LTORG 
RT1_CCE361      DS 0H
*MEXIT #=   386 LV= 1 RT1
* 91   TM
         TM    =X'00',X'00'
*MCALL #=   387 LV= 1          RT1   CC0
         DS    0H
RT1_TEST362      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE362
         LTORG 
RT1_CCE362      DS 0H
*MEXIT #=   387 LV= 1 RT1
         TM    =X'FF',X'00'
*MCALL #=   388 LV= 1          RT1   CC0
         DS    0H
RT1_TEST363      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE363
         LTORG 
RT1_CCE363      DS 0H
*MEXIT #=   388 LV= 1 RT1
         TM    =X'00',X'FF'
*MCALL #=   389 LV= 1          RT1   CC0
         DS    0H
RT1_TEST364      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE364
         LTORG 
RT1_CCE364      DS 0H
*MEXIT #=   389 LV= 1 RT1
         TM    =X'FF',X'F0'
*MCALL #=   390 LV= 1          RT1   CC3
         DS    0H
RT1_TEST365      BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC3365
         LTORG 
RT1_CC3365      DS 0H
*MEXIT #=   390 LV= 1 RT1
         TM    =X'FF',X'FF'
*MCALL #=   391 LV= 1          RT1   CC3
         DS    0H
RT1_TEST366      BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC3366
         LTORG 
RT1_CC3366      DS 0H
*MEXIT #=   391 LV= 1 RT1
         TM    =X'F0',X'FF'
*MCALL #=   392 LV= 1          RT1   CC1
         DS    0H
RT1_TEST367      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL367
         LTORG 
RT1_CCL367      DS 0H
*MEXIT #=   392 LV= 1 RT1
* 92   MVI
         MVI   BYTE,C'A'
         CLI   BYTE,C'A'
*MCALL #=   393 LV= 1          RT1   CCE,BYTE,=C'A'
         DS    0H
         CLC   BYTE,=C'A'
RT1_TEST368      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE368
         LTORG 
RT1_CCE368      DS 0H
*MEXIT #=   393 LV= 1 RT1
* 93   TS
         MVI   BYTE,X'FF'
         TS    BYTE
*MCALL #=   394 LV= 1          RT1   CC1
         DS    0H
RT1_TEST369      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL369
         LTORG 
RT1_CCL369      DS 0H
*MEXIT #=   394 LV= 1 RT1
         MVI   BYTE,X'7F'
         TS    BYTE
*MCALL #=   395 LV= 1          RT1   CC0
         DS    0H
RT1_TEST370      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE370
         LTORG 
RT1_CCE370      DS 0H
*MEXIT #=   395 LV= 1 RT1
* 94   NI
         MVI   BYTE,X'32'
         NI    BYTE,X'23'
*MCALL #=   396 LV= 1          RT1   CCL
         DS    0H
RT1_TEST371      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL371
         LTORG 
RT1_CCL371      DS 0H
*MEXIT #=   396 LV= 1 RT1
         CLI   BYTE,X'22'
*MCALL #=   397 LV= 1          RT1   CCE
         DS    0H
RT1_TEST372      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE372
         LTORG 
RT1_CCE372      DS 0H
*MEXIT #=   397 LV= 1 RT1
* 95   CLI
         MVI   BYTE,C'B'
         CLI   BYTE,C'B'
*MCALL #=   398 LV= 1          RT1   CCE,BYTE,=C'B'
         DS    0H
         CLC   BYTE,=C'B'
RT1_TEST373      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE373
         LTORG 
RT1_CCE373      DS 0H
*MEXIT #=   398 LV= 1 RT1
         MVI   BYTE,C'A'
         CLI   BYTE,C'B'
*MCALL #=   399 LV= 1          RT1   CCL,BYTE,=C'B'
         DS    0H
         CLC   BYTE,=C'B'
RT1_TEST374      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL374
         LTORG 
RT1_CCL374      DS 0H
*MEXIT #=   399 LV= 1 RT1
         MVI   BYTE,C'C'
         CLI   BYTE,C'B'
*MCALL #=   400 LV= 1          RT1   CCH,BYTE,=C'B'
         DS    0H
         CLC   BYTE,=C'B'
RT1_TEST375      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH375
         LTORG 
RT1_CCH375      DS 0H
*MEXIT #=   400 LV= 1 RT1
* 96   OI
         MVI   BYTE,X'32'
         OI    BYTE,X'23'
*MCALL #=   401 LV= 1          RT1   CCL
         DS    0H
RT1_TEST376      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL376
         LTORG 
RT1_CCL376      DS 0H
*MEXIT #=   401 LV= 1 RT1
         CLI   BYTE,X'33'
*MCALL #=   402 LV= 1          RT1   CCE
         DS    0H
RT1_TEST377      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE377
         LTORG 
RT1_CCE377      DS 0H
*MEXIT #=   402 LV= 1 RT1
* 97   XI
         MVI   BYTE,X'32'
         XI    BYTE,X'23'
*MCALL #=   403 LV= 1          RT1   CCL
         DS    0H
RT1_TEST378      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL378
         LTORG 
RT1_CCL378      DS 0H
*MEXIT #=   403 LV= 1 RT1
         CLI   BYTE,X'11'
*MCALL #=   404 LV= 1          RT1   CCE
         DS    0H
RT1_TEST379      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE379
         LTORG 
RT1_CCE379      DS 0H
*MEXIT #=   404 LV= 1 RT1
* 98   LM
         LM    R15,R0,=A(123,456)
         STM   R15,R0,PWORK
*MCALL #=   405 LV= 1          RT1   CCE,PWORK,=A(123,456)
         DS    0H
         CLC   PWORK,=A(123,456)
RT1_TEST380      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE380
         LTORG 
RT1_CCE380      DS 0H
*MEXIT #=   405 LV= 1 RT1
* A50  IIHH
         ICMH  R1,15,=X'12345678'
         STG   R1,PWORK
         CLC   PWORK(4),=X'12345678'
*MCALL #=   406 LV= 1          RT1   CCE
         DS    0H
RT1_TEST381      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE381
         LTORG 
RT1_CCE381      DS 0H
*MEXIT #=   406 LV= 1 RT1
         IIHH  R1,X'1030'
         STG   R1,PWORK
         CLC   PWORK(4),=X'10305678'
*MCALL #=   407 LV= 1          RT1   CCE
         DS    0H
RT1_TEST382      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE382
         LTORG 
RT1_CCE382      DS 0H
*MEXIT #=   407 LV= 1 RT1
         CLMH  R1,15,=X'10305678'
*MCALL #=   408 LV= 1          RT1   CCE
         DS    0H
RT1_TEST383      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE383
         LTORG 
RT1_CCE383      DS 0H
*MEXIT #=   408 LV= 1 RT1
* A51  IIHL
         ICMH  R1,15,=X'12345678'
         IIHL  R1,X'5070'
         CLMH  R1,15,=X'12345070'
*MCALL #=   409 LV= 1          RT1   CCE
         DS    0H
RT1_TEST384      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE384
         LTORG 
RT1_CCE384      DS 0H
*MEXIT #=   409 LV= 1 RT1
* A52  IILH
         L     R1,=X'12345678'
         IILH  R1,X'1030'
         CLM   R1,15,=X'10305678'
*MCALL #=   410 LV= 1          RT1   CCE
         DS    0H
RT1_TEST385      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE385
         LTORG 
RT1_CCE385      DS 0H
*MEXIT #=   410 LV= 1 RT1
* A53  IILL
         L     R1,=X'12345678'
         IILL  R1,X'5070'
         CLM   R1,15,=X'12345070'
*MCALL #=   411 LV= 1          RT1   CCE
         DS    0H
RT1_TEST386      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE386
         LTORG 
RT1_CCE386      DS 0H
*MEXIT #=   411 LV= 1 RT1
* A54  NIHH
         ICMH  R1,15,=X'12345678'
         SR    R0,R0
         NIHH  R1,X'1030'
*MCALL #=   412 LV= 1          RT1   CCL
         DS    0H
RT1_TEST387      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL387
         LTORG 
RT1_CCL387      DS 0H
*MEXIT #=   412 LV= 1 RT1
         STG   R1,PWORK
         CLC   PWORK(4),=X'10305678'
*MCALL #=   413 LV= 1          RT1   CCE
         DS    0H
RT1_TEST388      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE388
         LTORG 
RT1_CCE388      DS 0H
*MEXIT #=   413 LV= 1 RT1
         CLMH  R1,15,=X'10305678'
*MCALL #=   414 LV= 1          RT1   CCE
         DS    0H
RT1_TEST389      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE389
         LTORG 
RT1_CCE389      DS 0H
*MEXIT #=   414 LV= 1 RT1
* A55  NIHL
         ICMH  R1,15,=X'12345678'
         SR    R0,R0
         NIHL  R1,X'5070'
*MCALL #=   415 LV= 1          RT1   CCL
         DS    0H
RT1_TEST390      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL390
         LTORG 
RT1_CCL390      DS 0H
*MEXIT #=   415 LV= 1 RT1
         CLMH  R1,15,=X'12345070'
*MCALL #=   416 LV= 1          RT1   CCE
         DS    0H
RT1_TEST391      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE391
         LTORG 
RT1_CCE391      DS 0H
*MEXIT #=   416 LV= 1 RT1
* A56  NILH
         L     R1,=X'12345678'
         NILH  R1,X'1030'
*MCALL #=   417 LV= 1          RT1   CCL
         DS    0H
RT1_TEST392      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL392
         LTORG 
RT1_CCL392      DS 0H
*MEXIT #=   417 LV= 1 RT1
         CLM   R1,15,=X'10305678'
*MCALL #=   418 LV= 1          RT1   CCE
         DS    0H
RT1_TEST393      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE393
         LTORG 
RT1_CCE393      DS 0H
*MEXIT #=   418 LV= 1 RT1
* A57  NILL
         L     R1,=X'12345678'
         NILL  R1,X'5070'
*MCALL #=   419 LV= 1          RT1   CCL
         DS    0H
RT1_TEST394      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL394
         LTORG 
RT1_CCL394      DS 0H
*MEXIT #=   419 LV= 1 RT1
         CLM   R1,15,=X'12345070'
*MCALL #=   420 LV= 1          RT1   CCE
         DS    0H
RT1_TEST395      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE395
         LTORG 
RT1_CCE395      DS 0H
*MEXIT #=   420 LV= 1 RT1
* A58  OIHH
         ICMH  R1,15,=X'12345678'
         SR    R0,R0
         OIHH  R1,X'1111'
*MCALL #=   421 LV= 1          RT1   CCL
         DS    0H
RT1_TEST396      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL396
         LTORG 
RT1_CCL396      DS 0H
*MEXIT #=   421 LV= 1 RT1
         CLMH  R1,15,=X'13355678'
*MCALL #=   422 LV= 1          RT1   CCE
         DS    0H
RT1_TEST397      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE397
         LTORG 
RT1_CCE397      DS 0H
*MEXIT #=   422 LV= 1 RT1
* A59  OIHL
         ICMH  R1,15,=X'12345678'
         SR    R0,R0
         OIHL  R1,X'1111'
*MCALL #=   423 LV= 1          RT1   CCL
         DS    0H
RT1_TEST398      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL398
         LTORG 
RT1_CCL398      DS 0H
*MEXIT #=   423 LV= 1 RT1
         CLMH  R1,15,=X'12345779'
*MCALL #=   424 LV= 1          RT1   CCE
         DS    0H
RT1_TEST399      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE399
         LTORG 
RT1_CCE399      DS 0H
*MEXIT #=   424 LV= 1 RT1
* A5A  OILH
         L     R1,=X'12345678'
         SR    R0,R0
         OILH  R1,X'1111'
*MCALL #=   425 LV= 1          RT1   CCL
         DS    0H
RT1_TEST400      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL400
         LTORG 
RT1_CCL400      DS 0H
*MEXIT #=   425 LV= 1 RT1
         CLM   R1,15,=X'13355678'
*MCALL #=   426 LV= 1          RT1   CCE
         DS    0H
RT1_TEST401      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE401
         LTORG 
RT1_CCE401      DS 0H
*MEXIT #=   426 LV= 1 RT1
* A5B  OILL
         L     R1,=X'12345678'
         SR    R0,R0
         OILL  R1,X'1111'
*MCALL #=   427 LV= 1          RT1   CCL
         DS    0H
RT1_TEST402      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL402
         LTORG 
RT1_CCL402      DS 0H
*MEXIT #=   427 LV= 1 RT1
         CLM   R1,15,=X'12345779'
*MCALL #=   428 LV= 1          RT1   CCE
         DS    0H
RT1_TEST403      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE403
         LTORG 
RT1_CCE403      DS 0H
*MEXIT #=   428 LV= 1 RT1
* A5C  LLIHH
         LG    R0,=X'FFFFFFFFFFFFFFFF'
         LLIHH R0,X'CCCC'
         CLG   R0,=X'CCCC000000000000'
* A5D  LLIHL
         LG    R0,=X'FFFFFFFFFFFFFFFF'
         LLIHL R0,X'DDDD'
         CLG   R0,=X'0000DDDD00000000'
* A5E  LLILH
         LG    R0,=X'FFFFFFFFFFFFFFFF'
         LLILH R0,X'EEEE'
         CLG   R0,=X'00000000EEEE0000'
* A5F  LLILL
         LG    R0,=X'FFFFFFFFFFFFFFFF'
         LLILL R0,X'EEEE'
         CLG   R0,=X'000000000000EEEE'
* A70  TMLH / TMH
         IILH  R0,X'0000'
         TMLH  R0,X'0000'
*MCALL #=   429 LV= 1          RT1   CC0
         DS    0H
RT1_TEST404      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE404
         LTORG 
RT1_CCE404      DS 0H
*MEXIT #=   429 LV= 1 RT1
         IILH  R0,X'FFFF'
         TMLH  R0,X'0000'
*MCALL #=   430 LV= 1          RT1   CC0
         DS    0H
RT1_TEST405      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE405
         LTORG 
RT1_CCE405      DS 0H
*MEXIT #=   430 LV= 1 RT1
         IILH  R0,X'0000'
         TMLH  R0,X'FFFF'
*MCALL #=   431 LV= 1          RT1   CC0
         DS    0H
RT1_TEST406      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE406
         LTORG 
RT1_CCE406      DS 0H
*MEXIT #=   431 LV= 1 RT1
         IILH  R0,X'FFFF'
         TMLH  R0,X'FFFF'
*MCALL #=   432 LV= 1          RT1   CC3
         DS    0H
RT1_TEST407      BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC3407
         LTORG 
RT1_CC3407      DS 0H
*MEXIT #=   432 LV= 1 RT1
         IILH  R0,X'BFFF'  RPI-844
         TMLH  R0,X'FF00'
*MCALL #=   433 LV= 1          RT1   CC2
         DS    0H
RT1_TEST408      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH408
         LTORG 
RT1_CCH408      DS 0H
*MEXIT #=   433 LV= 1 RT1
         IILH  R0,X'7FFF'
         TMLH  R0,X'FF00'
*MCALL #=   434 LV= 1          RT1   CC1
         DS    0H
RT1_TEST409      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL409
         LTORG 
RT1_CCL409      DS 0H
*MEXIT #=   434 LV= 1 RT1
         IILH  R0,X'F9FF'  RPI-844
         TMLH  R0,X'0F00'
*MCALL #=   435 LV= 1          RT1   CC2
         DS    0H
RT1_TEST410      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH410
         LTORG 
RT1_CCH410      DS 0H
*MEXIT #=   435 LV= 1 RT1
         IILH  R0,X'F3FF'
         TMLH  R0,X'0F00'
*MCALL #=   436 LV= 1          RT1   CC1
         DS    0H
RT1_TEST411      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL411
         LTORG 
RT1_CCL411      DS 0H
*MEXIT #=   436 LV= 1 RT1
* A71  TMLL / TML
         IILL  R0,X'0000'
         TMLL  R0,X'0000'
*MCALL #=   437 LV= 1          RT1   CC0
         DS    0H
RT1_TEST412      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE412
         LTORG 
RT1_CCE412      DS 0H
*MEXIT #=   437 LV= 1 RT1
         IILL  R0,X'FFFF'
         TMLL  R0,X'0000'
*MCALL #=   438 LV= 1          RT1   CC0
         DS    0H
RT1_TEST413      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE413
         LTORG 
RT1_CCE413      DS 0H
*MEXIT #=   438 LV= 1 RT1
         IILL  R0,X'0000'
         TMLL  R0,X'FFFF'
*MCALL #=   439 LV= 1          RT1   CC0
         DS    0H
RT1_TEST414      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE414
         LTORG 
RT1_CCE414      DS 0H
*MEXIT #=   439 LV= 1 RT1
         IILL  R0,X'FFFF'
         TMLL  R0,X'FFFF'
*MCALL #=   440 LV= 1          RT1   CC3
         DS    0H
RT1_TEST415      BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC3415
         LTORG 
RT1_CC3415      DS 0H
*MEXIT #=   440 LV= 1 RT1
         IILL  R0,X'BFFF'  RPI-844
         TMLL  R0,X'FF00'
*MCALL #=   441 LV= 1          RT1   CC2
         DS    0H
RT1_TEST416      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH416
         LTORG 
RT1_CCH416      DS 0H
*MEXIT #=   441 LV= 1 RT1
         IILL  R0,X'7FFF'
         TMLL  R0,X'FF00'
*MCALL #=   442 LV= 1          RT1   CC1
         DS    0H
RT1_TEST417      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL417
         LTORG 
RT1_CCL417      DS 0H
*MEXIT #=   442 LV= 1 RT1
         IILL  R0,X'F9FF'  RPI-844
         TMLL  R0,X'0F00'
*MCALL #=   443 LV= 1          RT1   CC2
         DS    0H
RT1_TEST418      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH418
         LTORG 
RT1_CCH418      DS 0H
*MEXIT #=   443 LV= 1 RT1
         IILL  R0,X'F3FF'
         TMLL  R0,X'0F00'
*MCALL #=   444 LV= 1          RT1   CC1
         DS    0H
RT1_TEST419      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL419
         LTORG 
RT1_CCL419      DS 0H
*MEXIT #=   444 LV= 1 RT1
* A72  TMHH
         IIHH  R0,X'0000'
         TMHH  R0,X'0000'
*MCALL #=   445 LV= 1          RT1   CC0
         DS    0H
RT1_TEST420      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE420
         LTORG 
RT1_CCE420      DS 0H
*MEXIT #=   445 LV= 1 RT1
         IIHH  R0,X'FFFF'
         TMHH  R0,X'0000'
*MCALL #=   446 LV= 1          RT1   CC0
         DS    0H
RT1_TEST421      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE421
         LTORG 
RT1_CCE421      DS 0H
*MEXIT #=   446 LV= 1 RT1
         IIHH  R0,X'0000'
         TMHH  R0,X'FFFF'
*MCALL #=   447 LV= 1          RT1   CC0
         DS    0H
RT1_TEST422      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE422
         LTORG 
RT1_CCE422      DS 0H
*MEXIT #=   447 LV= 1 RT1
         IIHH  R0,X'FFFF'
         TMHH  R0,X'FFFF'
*MCALL #=   448 LV= 1          RT1   CC3
         DS    0H
RT1_TEST423      BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC3423
         LTORG 
RT1_CC3423      DS 0H
*MEXIT #=   448 LV= 1 RT1
         IIHH  R0,X'BFFF'  RPI-844
         TMHH  R0,X'FF00'
*MCALL #=   449 LV= 1          RT1   CC2
         DS    0H
RT1_TEST424      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH424
         LTORG 
RT1_CCH424      DS 0H
*MEXIT #=   449 LV= 1 RT1
         IIHH  R0,X'7FFF'
         TMHH  R0,X'FF00'
*MCALL #=   450 LV= 1          RT1   CC1
         DS    0H
RT1_TEST425      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL425
         LTORG 
RT1_CCL425      DS 0H
*MEXIT #=   450 LV= 1 RT1
         IIHH  R0,X'F9FF'  RPI-844
         TMHH  R0,X'0F00'
*MCALL #=   451 LV= 1          RT1   CC2
         DS    0H
RT1_TEST426      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH426
         LTORG 
RT1_CCH426      DS 0H
*MEXIT #=   451 LV= 1 RT1
         IIHH  R0,X'F3FF'
         TMHH  R0,X'0F00'
*MCALL #=   452 LV= 1          RT1   CC1
         DS    0H
RT1_TEST427      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL427
         LTORG 
RT1_CCL427      DS 0H
*MEXIT #=   452 LV= 1 RT1
* A73  TMHL
         IIHL  R0,X'0000'
         TMHL  R0,X'0000'
*MCALL #=   453 LV= 1          RT1   CC0
         DS    0H
RT1_TEST428      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE428
         LTORG 
RT1_CCE428      DS 0H
*MEXIT #=   453 LV= 1 RT1
         IIHL  R0,X'FFFF'
         TMHL  R0,X'0000'
*MCALL #=   454 LV= 1          RT1   CC0
         DS    0H
RT1_TEST429      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE429
         LTORG 
RT1_CCE429      DS 0H
*MEXIT #=   454 LV= 1 RT1
         IIHL  R0,X'0000'
         TMHL  R0,X'FFFF'
*MCALL #=   455 LV= 1          RT1   CC0
         DS    0H
RT1_TEST430      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE430
         LTORG 
RT1_CCE430      DS 0H
*MEXIT #=   455 LV= 1 RT1
         IIHL  R0,X'FFFF'
         TMHL  R0,X'FFFF'
*MCALL #=   456 LV= 1          RT1   CC3
         DS    0H
RT1_TEST431      BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC3431
         LTORG 
RT1_CC3431      DS 0H
*MEXIT #=   456 LV= 1 RT1
         IIHL  R0,X'BFFF'  RPI-844
         TMHL  R0,X'FF00'
*MCALL #=   457 LV= 1          RT1   CC2
         DS    0H
RT1_TEST432      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH432
         LTORG 
RT1_CCH432      DS 0H
*MEXIT #=   457 LV= 1 RT1
         IIHL  R0,X'7FFF'
         TMHL  R0,X'FF00'
*MCALL #=   458 LV= 1          RT1   CC1
         DS    0H
RT1_TEST433      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL433
         LTORG 
RT1_CCL433      DS 0H
*MEXIT #=   458 LV= 1 RT1
         IIHL  R0,X'F9FF'  RPI-844
         TMHL  R0,X'0F00'
*MCALL #=   459 LV= 1          RT1   CC2
         DS    0H
RT1_TEST434      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH434
         LTORG 
RT1_CCH434      DS 0H
*MEXIT #=   459 LV= 1 RT1
         IIHL  R0,X'F3FF'
         TMHL  R0,X'0F00'
*MCALL #=   460 LV= 1          RT1   CC1
         DS    0H
RT1_TEST435      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL435
         LTORG 
RT1_CCL435      DS 0H
*MEXIT #=   460 LV= 1 RT1
* A74  BRC
         J     BRCOK
*MCALL #=   461 LV= 1 BRCERR   RT1   ABORT
BRCERR   DS    0H
         B      RT1_ABORT
*MEXIT #=   461 LV= 1 RT1
BRCOK    EQU   *
         JNOP  BRCERR
         CLI   =X'1',1
         JNE   BRCERR
*MCALL #=   462 LV= 1          RT1   CCE
         DS    0H
RT1_TEST437      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE437
         LTORG 
RT1_CCE437      DS 0H
*MEXIT #=   462 LV= 1 RT1
         CLI   =X'1',2
         JNL   BRCERR
         JE    BRCERR
*MCALL #=   463 LV= 1          RT1   CCL
         DS    0H
RT1_TEST438      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL438
         LTORG 
RT1_CCL438      DS 0H
*MEXIT #=   463 LV= 1 RT1
         CLI   =X'2',1
         JNH   BRCERR
         JE    BRCERR
*MCALL #=   464 LV= 1          RT1   CCH
         DS    0H
RT1_TEST439      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH439
         LTORG 
RT1_CCH439      DS 0H
*MEXIT #=   464 LV= 1 RT1
* A75  BRAS
BRAS1    BRAS  R1,BRAS2
*MCALL #=   465 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   465 LV= 1 RT1
BRAS2    EQU   *
         NILH  R1,X'7FFF'
         CL    R1,=A(BRAS1+4)
*MCALL #=   466 LV= 1          RT1   CCE
         DS    0H
RT1_TEST441      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE441
         LTORG 
RT1_CCE441      DS 0H
*MEXIT #=   466 LV= 1 RT1
* A76  BRCT
         LA    R1,10
         SR    R2,R2
BRCT1    LA    R2,1(R2)
         BRCT  R1,BRCT1
         CL    R1,=F'0'
*MCALL #=   467 LV= 1          RT1   CCE
         DS    0H
RT1_TEST442      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE442
         LTORG 
RT1_CCE442      DS 0H
*MEXIT #=   467 LV= 1 RT1
         CL    R2,=F'10'
*MCALL #=   468 LV= 1          RT1   CCE
         DS    0H
RT1_TEST443      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE443
         LTORG 
RT1_CCE443      DS 0H
*MEXIT #=   468 LV= 1 RT1
* A77  BRCTG
         LG    R1,=FL8'10'
         SR    R2,R2
BRCTG1   LA    R2,1(R2)
         BRCTG R1,BRCTG1
         CLG   R1,=FL8'0'
*MCALL #=   469 LV= 1          RT1   CCE
         DS    0H
RT1_TEST444      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE444
         LTORG 
RT1_CCE444      DS 0H
*MEXIT #=   469 LV= 1 RT1
         CL    R2,=F'10'
*MCALL #=   470 LV= 1          RT1   CCE
         DS    0H
RT1_TEST445      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE445
         LTORG 
RT1_CCE445      DS 0H
*MEXIT #=   470 LV= 1 RT1
* A78  LHI
         LHI   R0,1
         CL    R0,=F'1'
*MCALL #=   471 LV= 1          RT1   CCE
         DS    0H
RT1_TEST446      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE446
         LTORG 
RT1_CCE446      DS 0H
*MEXIT #=   471 LV= 1 RT1
         LHI   R0,-2
         CL    R0,=F'-2'
*MCALL #=   472 LV= 1          RT1   CCE
         DS    0H
RT1_TEST447      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE447
         LTORG 
RT1_CCE447      DS 0H
*MEXIT #=   472 LV= 1 RT1
* A79  LGHI
         LGHI  R0,1
         CLG   R0,=FL8'1'
*MCALL #=   473 LV= 1          RT1   CCE
         DS    0H
RT1_TEST448      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE448
         LTORG 
RT1_CCE448      DS 0H
*MEXIT #=   473 LV= 1 RT1
         LGHI  R0,-2
         CLG   R0,=FL8'-2'
*MCALL #=   474 LV= 1          RT1   CCE
         DS    0H
RT1_TEST449      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE449
         LTORG 
RT1_CCE449      DS 0H
*MEXIT #=   474 LV= 1 RT1
* A7A  AHI
         LA    R0,1
         AHI   R0,2
         CL    R0,=F'3'
*MCALL #=   475 LV= 1          RT1   CCE
         DS    0H
RT1_TEST450      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE450
         LTORG 
RT1_CCE450      DS 0H
*MEXIT #=   475 LV= 1 RT1
* A7B  AGHI
         LG    R0,=FL8'1'
         AGHI  R0,2
         CLG   R0,=FL8'3'
*MCALL #=   476 LV= 1          RT1   CCE
         DS    0H
RT1_TEST451      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE451
         LTORG 
RT1_CCE451      DS 0H
*MEXIT #=   476 LV= 1 RT1
* A7C  MHI
         LH    R0,=H'2'
         MHI   R0,3
         CH    R0,=H'6'
*MCALL #=   477 LV= 1          RT1   CCE
         DS    0H
RT1_TEST452      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE452
         LTORG 
RT1_CCE452      DS 0H
*MEXIT #=   477 LV= 1 RT1
* A7D  MGHI
         LG    R0,=FL8'2'
         MGHI  R0,3
         CH    R0,=H'6'
*MCALL #=   478 LV= 1          RT1   CCE
         DS    0H
RT1_TEST453      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE453
         LTORG 
RT1_CCE453      DS 0H
*MEXIT #=   478 LV= 1 RT1
* A7E  CHI
         LA    R1,1
         CHI   R1,1
*MCALL #=   479 LV= 1          RT1   CCE
         DS    0H
RT1_TEST454      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE454
         LTORG 
RT1_CCE454      DS 0H
*MEXIT #=   479 LV= 1 RT1
         LA    R1,0
         CHI   R1,1
*MCALL #=   480 LV= 1          RT1   CCL
         DS    0H
RT1_TEST455      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL455
         LTORG 
RT1_CCL455      DS 0H
*MEXIT #=   480 LV= 1 RT1
         LA    R1,2
         CHI   R1,1
*MCALL #=   481 LV= 1          RT1   CCH
         DS    0H
RT1_TEST456      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH456
         LTORG 
RT1_CCH456      DS 0H
*MEXIT #=   481 LV= 1 RT1
         L     R1,=F'-1'
         CHI   R1,1
*MCALL #=   482 LV= 1          RT1   CCL
         DS    0H
RT1_TEST457      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL457
         LTORG 
RT1_CCL457      DS 0H
*MEXIT #=   482 LV= 1 RT1
         L     R1,=F'1'
         CHI   R1,-1
*MCALL #=   483 LV= 1          RT1   CCH
         DS    0H
RT1_TEST458      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH458
         LTORG 
RT1_CCH458      DS 0H
*MEXIT #=   483 LV= 1 RT1
* A7F  CGHI
         LG    R1,=FL8'1'
         CGHI  R1,1
*MCALL #=   484 LV= 1          RT1   CCE
         DS    0H
RT1_TEST459      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE459
         LTORG 
RT1_CCE459      DS 0H
*MEXIT #=   484 LV= 1 RT1
         LG    R1,=FL8'0'
         CGHI  R1,1
*MCALL #=   485 LV= 1          RT1   CCL
         DS    0H
RT1_TEST460      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL460
         LTORG 
RT1_CCL460      DS 0H
*MEXIT #=   485 LV= 1 RT1
         LG    R1,=FL8'2'
         CGHI  R1,1
*MCALL #=   486 LV= 1          RT1   CCH
         DS    0H
RT1_TEST461      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH461
         LTORG 
RT1_CCH461      DS 0H
*MEXIT #=   486 LV= 1 RT1
         LG    R1,=FL8'-1'
         CGHI  R1,1
*MCALL #=   487 LV= 1          RT1   CCL
         DS    0H
RT1_TEST462      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL462
         LTORG 
RT1_CCL462      DS 0H
*MEXIT #=   487 LV= 1 RT1
         LG    R1,=FL8'1'
         CGHI  R1,-1
*MCALL #=   488 LV= 1          RT1   CCH
         DS    0H
RT1_TEST463      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH463
         LTORG 
RT1_CCH463      DS 0H
*MEXIT #=   488 LV= 1 RT1
* A8   MVCLE
         MVC   WORD,=C'1234'
         MVC   PWORK(4),=C'ABCD'
         LM    R0,R1,=A(WORD,4)
         LM    R2,R3,=A(PWORK,4)
         MVCLE R0,R2,0
         JO    *-4                    RPI-844
*MCALL #=   489 LV= 1          RT1   CCE
         DS    0H
RT1_TEST464      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE464
         LTORG 
RT1_CCE464      DS 0H
*MEXIT #=   489 LV= 1 RT1
         CLC   WORD,=C'ABCD'
*MCALL #=   490 LV= 1          RT1   CCE
         DS    0H
RT1_TEST465      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE465
         LTORG 
RT1_CCE465      DS 0H
*MEXIT #=   490 LV= 1 RT1
         CL    R0,=A(WORD+4)
*MCALL #=   491 LV= 1          RT1   CCE
         DS    0H
RT1_TEST466      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE466
         LTORG 
RT1_CCE466      DS 0H
*MEXIT #=   491 LV= 1 RT1
         CL    R1,=A(0)
*MCALL #=   492 LV= 1          RT1   CCE
         DS    0H
RT1_TEST467      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE467
         LTORG 
RT1_CCE467      DS 0H
*MEXIT #=   492 LV= 1 RT1
         CL    R2,=A(PWORK+4)
*MCALL #=   493 LV= 1          RT1   CCE
         DS    0H
RT1_TEST468      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE468
         LTORG 
RT1_CCE468      DS 0H
*MEXIT #=   493 LV= 1 RT1
         CL    R3,=A(0)
*MCALL #=   494 LV= 1          RT1   CCE
         DS    0H
RT1_TEST469      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE469
         LTORG 
RT1_CCE469      DS 0H
*MEXIT #=   494 LV= 1 RT1
         MVC   WORD,=C'1234'
         MVC   PWORK(4),=C'ABXX'
         LM    R0,R1,=A(WORD,4)
         LM    R2,R3,=A(PWORK,2)
         MVCLE R0,R2,C' '
         JO    *-4                    RPI-844
*MCALL #=   495 LV= 1          RT1   CCH
         DS    0H
RT1_TEST470      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH470
         LTORG 
RT1_CCH470      DS 0H
*MEXIT #=   495 LV= 1 RT1
         CL    R0,=A(WORD+4)
*MCALL #=   496 LV= 1          RT1   CCE
         DS    0H
RT1_TEST471      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE471
         LTORG 
RT1_CCE471      DS 0H
*MEXIT #=   496 LV= 1 RT1
         CL    R1,=A(0)
*MCALL #=   497 LV= 1          RT1   CCE
         DS    0H
RT1_TEST472      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE472
         LTORG 
RT1_CCE472      DS 0H
*MEXIT #=   497 LV= 1 RT1
         CL    R2,=A(PWORK+2)
*MCALL #=   498 LV= 1          RT1   CCE
         DS    0H
RT1_TEST473      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE473
         LTORG 
RT1_CCE473      DS 0H
*MEXIT #=   498 LV= 1 RT1
         CL    R3,=A(0)
*MCALL #=   499 LV= 1          RT1   CCE
         DS    0H
RT1_TEST474      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE474
         LTORG 
RT1_CCE474      DS 0H
*MEXIT #=   499 LV= 1 RT1
         CLC   WORD,=C'AB  '
*MCALL #=   500 LV= 1          RT1   CCE
         DS    0H
RT1_TEST475      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE475
         LTORG 
RT1_CCE475      DS 0H
*MEXIT #=   500 LV= 1 RT1
         MVC   WORD,=C'1234'
         MVC   PWORK(4),=C'ABCX'
         LM    R0,R1,=A(WORD,3)
         LM    R2,R3,=A(PWORK,4)
         MVCLE R0,R2,0
         JO    *-4                    RPI-844
*MCALL #=   501 LV= 1          RT1   CCL
         DS    0H
RT1_TEST476      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL476
         LTORG 
RT1_CCL476      DS 0H
*MEXIT #=   501 LV= 1 RT1
         CL    R0,=A(WORD+3)
*MCALL #=   502 LV= 1          RT1   CCE
         DS    0H
RT1_TEST477      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE477
         LTORG 
RT1_CCE477      DS 0H
*MEXIT #=   502 LV= 1 RT1
         CL    R1,=A(0)
*MCALL #=   503 LV= 1          RT1   CCE
         DS    0H
RT1_TEST478      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE478
         LTORG 
RT1_CCE478      DS 0H
*MEXIT #=   503 LV= 1 RT1
         CL    R2,=A(PWORK+3)
*MCALL #=   504 LV= 1          RT1   CCE
         DS    0H
RT1_TEST479      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE479
         LTORG 
RT1_CCE479      DS 0H
*MEXIT #=   504 LV= 1 RT1
         CL    R3,=A(1)
*MCALL #=   505 LV= 1          RT1   CCE
         DS    0H
RT1_TEST480      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE480
         LTORG 
RT1_CCE480      DS 0H
*MEXIT #=   505 LV= 1 RT1
         CLC   WORD,=C'ABC4'
*MCALL #=   506 LV= 1          RT1   CCE
         DS    0H
RT1_TEST481      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE481
         LTORG 
RT1_CCE481      DS 0H
*MEXIT #=   506 LV= 1 RT1
* A9   CLCLE
         MVC   WORD,=C'ABCD'
         MVC   PWORK(4),=C'ABCD'
         LM    R0,R1,=A(WORD,4)
         LM    R2,R3,=A(PWORK,4)
         CLCLE R0,R2,0
         JO    *-4                    RPI-844
*MCALL #=   507 LV= 1          RT1   CCE
         DS    0H
RT1_TEST482      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE482
         LTORG 
RT1_CCE482      DS 0H
*MEXIT #=   507 LV= 1 RT1
         CL    R0,=A(WORD+4)
*MCALL #=   508 LV= 1          RT1   CCE
         DS    0H
RT1_TEST483      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE483
         LTORG 
RT1_CCE483      DS 0H
*MEXIT #=   508 LV= 1 RT1
         CL    R1,=A(0)
*MCALL #=   509 LV= 1          RT1   CCE
         DS    0H
RT1_TEST484      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE484
         LTORG 
RT1_CCE484      DS 0H
*MEXIT #=   509 LV= 1 RT1
         CL    R2,=A(PWORK+4)
*MCALL #=   510 LV= 1          RT1   CCE
         DS    0H
RT1_TEST485      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE485
         LTORG 
RT1_CCE485      DS 0H
*MEXIT #=   510 LV= 1 RT1
         CL    R3,=A(0)
*MCALL #=   511 LV= 1          RT1   CCE
         DS    0H
RT1_TEST486      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE486
         LTORG 
RT1_CCE486      DS 0H
*MEXIT #=   511 LV= 1 RT1
         MVC   WORD,=C'AB  '
         MVC   PWORK(4),=C'ABXX'
         LM    R0,R1,=A(WORD,4)
         LM    R2,R3,=A(PWORK,2)
         CLCLE R0,R2,C' '
         JO    *-4                    RPI-844
*MCALL #=   512 LV= 1          RT1   CCE
         DS    0H
RT1_TEST487      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE487
         LTORG 
RT1_CCE487      DS 0H
*MEXIT #=   512 LV= 1 RT1
         CL    R0,=A(WORD+4)
*MCALL #=   513 LV= 1          RT1   CCE
         DS    0H
RT1_TEST488      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE488
         LTORG 
RT1_CCE488      DS 0H
*MEXIT #=   513 LV= 1 RT1
         CL    R1,=A(0)
*MCALL #=   514 LV= 1          RT1   CCE
         DS    0H
RT1_TEST489      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE489
         LTORG 
RT1_CCE489      DS 0H
*MEXIT #=   514 LV= 1 RT1
         CL    R2,=A(PWORK+2)
*MCALL #=   515 LV= 1          RT1   CCE
         DS    0H
RT1_TEST490      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE490
         LTORG 
RT1_CCE490      DS 0H
*MEXIT #=   515 LV= 1 RT1
         CL    R3,=A(0)
*MCALL #=   516 LV= 1          RT1   CCE
         DS    0H
RT1_TEST491      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE491
         LTORG 
RT1_CCE491      DS 0H
*MEXIT #=   516 LV= 1 RT1
         MVC   WORD,=C'ABC4'
         MVC   PWORK(4),=C'ABC '
         LM    R0,R1,=A(WORD,3)
         LM    R2,R3,=A(PWORK,4)
         CLCLE R0,R2,C' '
         JO    *-4                    RPI-844
*MCALL #=   517 LV= 1          RT1   CCE
         DS    0H
RT1_TEST492      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE492
         LTORG 
RT1_CCE492      DS 0H
*MEXIT #=   517 LV= 1 RT1
         CL    R0,=A(WORD+3)
*MCALL #=   518 LV= 1          RT1   CCE
         DS    0H
RT1_TEST493      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE493
         LTORG 
RT1_CCE493      DS 0H
*MEXIT #=   518 LV= 1 RT1
         CL    R1,=A(0)
*MCALL #=   519 LV= 1          RT1   CCE
         DS    0H
RT1_TEST494      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE494
         LTORG 
RT1_CCE494      DS 0H
*MEXIT #=   519 LV= 1 RT1
         CL    R2,=A(PWORK+4)
*MCALL #=   520 LV= 1          RT1   CCE
         DS    0H
RT1_TEST495      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE495
         LTORG 
RT1_CCE495      DS 0H
*MEXIT #=   520 LV= 1 RT1
         CL    R3,=A(0)
*MCALL #=   521 LV= 1          RT1   CCE
         DS    0H
RT1_TEST496      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE496
         LTORG 
RT1_CCE496      DS 0H
*MEXIT #=   521 LV= 1 RT1
         MVC   WORD,=C'AB  '
         MVC   PWORK(4),=C'ACXX'
         LM    R0,R1,=A(WORD,4)
         LM    R2,R3,=A(PWORK,2)
         CLCLE R0,R2,C' '
         JO    *-4                    RPI-844
*MCALL #=   522 LV= 1          RT1   CCL
         DS    0H
RT1_TEST497      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL497
         LTORG 
RT1_CCL497      DS 0H
*MEXIT #=   522 LV= 1 RT1
         CL    R0,=A(WORD+1)
*MCALL #=   523 LV= 1          RT1   CCE
         DS    0H
RT1_TEST498      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE498
         LTORG 
RT1_CCE498      DS 0H
*MEXIT #=   523 LV= 1 RT1
         CL    R1,=A(3)
*MCALL #=   524 LV= 1          RT1   CCE
         DS    0H
RT1_TEST499      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE499
         LTORG 
RT1_CCE499      DS 0H
*MEXIT #=   524 LV= 1 RT1
         CL    R2,=A(PWORK+1)
*MCALL #=   525 LV= 1          RT1   CCE
         DS    0H
RT1_TEST500      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE500
         LTORG 
RT1_CCE500      DS 0H
*MEXIT #=   525 LV= 1 RT1
         CL    R3,=A(1)
*MCALL #=   526 LV= 1          RT1   CCE
         DS    0H
RT1_TEST501      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE501
         LTORG 
RT1_CCE501      DS 0H
*MEXIT #=   526 LV= 1 RT1
         MVC   WORD,=C'AB C'
         MVC   PWORK(4),=C'ABXX'
         LM    R0,R1,=A(WORD,4)
         LM    R2,R3,=A(PWORK,2)
         CLCLE R0,R2,C' '
         JO    *-4                    RPI-844
*MCALL #=   527 LV= 1          RT1   CCH
         DS    0H
RT1_TEST502      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH502
         LTORG 
RT1_CCH502      DS 0H
*MEXIT #=   527 LV= 1 RT1
         CL    R0,=A(WORD+3)
*MCALL #=   528 LV= 1          RT1   CCE
         DS    0H
RT1_TEST503      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE503
         LTORG 
RT1_CCE503      DS 0H
*MEXIT #=   528 LV= 1 RT1
         CL    R1,=A(1)
*MCALL #=   529 LV= 1          RT1   CCE
         DS    0H
RT1_TEST504      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE504
         LTORG 
RT1_CCE504      DS 0H
*MEXIT #=   529 LV= 1 RT1
         CL    R2,=A(PWORK+2)
*MCALL #=   530 LV= 1          RT1   CCE
         DS    0H
RT1_TEST505      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE505
         LTORG 
RT1_CCE505      DS 0H
*MEXIT #=   530 LV= 1 RT1
         CL    R3,=A(0)
*MCALL #=   531 LV= 1          RT1   CCE
         DS    0H
RT1_TEST506      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE506
         LTORG 
RT1_CCE506      DS 0H
*MEXIT #=   531 LV= 1 RT1
* B202 STIDP
         STIDP PWORK
         CLC   PWORK,=XL8'390' VERIFY CPU ID
*MCALL #=   532 LV= 1          RT1   CCE
         DS    0H
RT1_TEST507      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE507
         LTORG 
RT1_CCE507      DS 0H
*MEXIT #=   532 LV= 1 RT1
* B205 STCK
         STCK  PWORK  STORES J2SE MILLISECONDS FROM JAN 1, 1970
         LG    R0,PWORK
         STCK  PWORK
         CLG   R0,PWORK
*MCALL #=   533 LV= 1          RT1   CCL        VERIFY UNIQUE
         DS    0H
RT1_TEST508      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL508
         LTORG 
RT1_CCL508      DS 0H
*MEXIT #=   533 LV= 1 RT1
* B218 PC
         PC    PC1
         B     PC2
*MCALL #=   534 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   534 LV= 1 RT1
*MCALL #=   535 LV= 1 PC1      WTO   'PC1 SUB CALLED'
PC1      DS    0H
         BRAS  1,*+(WTO#0535_EOT-*+1)/2*2
         DC    AL2(WTO#0535_EOT-*,0),C'PC1 SUB CALLED'
WTO#0535_EOT     EQU *
         SVC   35
*MEXIT #=   535 LV= 1 WTO
         PR 
PC2      EQU   *
* B222 IPM
         SR    0,0
         IPM   0
         CLM   0,8,=B'00001111' 00CCFPES CC=00 MASK=1111 FX,PD,EX,SG
*MCALL #=   536 LV= 1          RT1   CCE
         DS    0H
RT1_TEST510      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE510
         LTORG 
RT1_CCE510      DS 0H
*MEXIT #=   536 LV= 1 RT1
         AHI   0,1
         IPM   0
         CLM   0,8,=B'00101111' 00CCFPES CC=10 MASK=1111 FX,PD,EX,SG
*MCALL #=   537 LV= 1          RT1   CCE
         DS    0H
RT1_TEST511      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE511
         LTORG 
RT1_CCE511      DS 0H
*MEXIT #=   537 LV= 1 RT1
* B240 BAKR
         LA    R0,1
         LA    R1,BAKR2
         LA    R2,BAKR1
         BAKR  R1,R2
*MCALL #=   538 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   538 LV= 1 RT1
*MCALL #=   539 LV= 1 BAKR1    WTO   'BAKR1 SUB CALLED'
BAKR1    DS    0H
         BRAS  1,*+(WTO#0539_EOT-*+1)/2*2
         DC    AL2(WTO#0539_EOT-*,0),C'BAKR1 SUB CALLED'
WTO#0539_EOT     EQU *
         SVC   35
*MEXIT #=   539 LV= 1 WTO
         LA    2,2  REQUEST PSW                    RPI-1026
         ESTA  0,2  EXTRACT RETURN PSW INTO R0-R1  RPI-1026
         MVI   ESTACC,0
         JZ    *+8
         MVI   ESTACC,1
         STM   0,1,ESTAPSW
         PR 
BAKR2    EQU   *
         CLI   ESTACC,0 BAKR TYPE
*MCALL #=   540 LV= 1          RT1   CCE
         DS    0H
RT1_TEST513      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE513
         LTORG 
RT1_CCE513      DS 0H
*MEXIT #=   540 LV= 1 RT1
         CLC   ESTAPSW,=AL8(BAKR2)
*MCALL #=   541 LV= 1          RT1   CCE           RPI-1026
         DS    0H
RT1_TEST514      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE514
         LTORG 
RT1_CCE514      DS 0H
*MEXIT #=   541 LV= 1 RT1
         BAKR  0,R2
BAKR3    EQU   *
         CLI   ESTACC,0 BAKR TYPE
*MCALL #=   542 LV= 1          RT1   CCE
         DS    0H
RT1_TEST515      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE515
         LTORG 
RT1_CCE515      DS 0H
*MEXIT #=   542 LV= 1 RT1
         CLC   ESTAPSW,=AL8(BALR3)
*MCALL #=   543 LV= 1          RT1   CCE           RPI-1026
         DS    0H
RT1_TEST516      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE516
         LTORG 
RT1_CCE516      DS 0H
*MEXIT #=   543 LV= 1 RT1
* B249 EREG    R1,R2 RESTORE 32 BIT REGISTERS SEE PC/BAKR
* B24A ESTA    R1,R1 (SEE PC AND BAKR TESTS WITH ESTA,EREG,EREGG
* B24D CPYA    AR1,AR2  COPY    ACCESS REGISTER RPI-1055
* B24E SAR     AR1,AR2  SET     ACCESS REGISTER RPI-1055
* B24F EAR     AR1,AR2  EXTRACT ACCESS REGISTER RPI-1055
         LA    1,123
         SAR   0,1      SET     ACCESS REGISTER AR0 FROM R1
         CPYA  1,0      COPY    ACCESS REGISTER AR1 FROM AR0
         EAR   2,1      EXTRACT ACCESS REGISTER AR1 TO   R2
         CLR   1,2
*MCALL #=   544 LV= 1          RT1   CCE
         DS    0H
RT1_TEST517      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE517
         LTORG 
RT1_CCE517      DS 0H
*MEXIT #=   544 LV= 1 RT1
* B252 MSR
         L     R0,=F'2'
         L     R2,=F'3'
         MSR   R0,R2
         C     R0,=F'6'
*MCALL #=   545 LV= 1          RT1   CCE
         DS    0H
RT1_TEST518      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE518
         LTORG 
RT1_CCE518      DS 0H
*MEXIT #=   545 LV= 1 RT1
* B255 MVST
         LM    R0,R2,=A(X'EE',STRING3,STRING4)
         MVST  R1,R2
*MCALL #=   546 LV= 1          RT1   CC1
         DS    0H
RT1_TEST519      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL519
         LTORG 
RT1_CCL519      DS 0H
*MEXIT #=   546 LV= 1 RT1
         CLC   STRING3,STRING4
*MCALL #=   547 LV= 1          RT1   CCE
         DS    0H
RT1_TEST520      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE520
         LTORG 
RT1_CCE520      DS 0H
*MEXIT #=   547 LV= 1 RT1
         CL    R1,=A(STRING3+L'STRING4)
*MCALL #=   548 LV= 1          RT1   CCE
         DS    0H
RT1_TEST521      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE521
         LTORG 
RT1_CCE521      DS 0H
*MEXIT #=   548 LV= 1 RT1
         CLI   0(R1),X'EE'
*MCALL #=   549 LV= 1          RT1   CCE
         DS    0H
RT1_TEST522      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE522
         LTORG 
RT1_CCE522      DS 0H
*MEXIT #=   549 LV= 1 RT1
* B257 CUSE
         LA    R0,L'KEY
         LA    R1,PAD
         LM    R2,R5,=A(STRING1,L'STRING1,STRING2,L'STRING2)
         CUSE  2,4
         JO    *-4
*MCALL #=   550 LV= 1          RT1   CCE,0(L'KEY,R2),KEY
         DS    0H
         CLC   0(L'KEY,R2),KEY
RT1_TEST523      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE523
         LTORG 
RT1_CCE523      DS 0H
*MEXIT #=   550 LV= 1 RT1
*MCALL #=   551 LV= 1          RT1   CCE,0(L'KEY,R4),KEY
         DS    0H
         CLC   0(L'KEY,R4),KEY
RT1_TEST524      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE524
         LTORG 
RT1_CCE524      DS 0H
*MEXIT #=   551 LV= 1 RT1
         CL    R3,=A(L'STRING1-7)
*MCALL #=   552 LV= 1          RT1   CCE
         DS    0H
RT1_TEST525      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE525
         LTORG 
RT1_CCE525      DS 0H
*MEXIT #=   552 LV= 1 RT1
         CL    R5,=A(L'STRING2-7)
*MCALL #=   553 LV= 1          RT1   CCE
         DS    0H
RT1_TEST526      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE526
         LTORG 
RT1_CCE526      DS 0H
*MEXIT #=   553 LV= 1 RT1
* B25D CLST
         LA    R0,C'X'
         LA    R1,=C'ABCX'
         LA    R2,=C'ABCX'
         CLST  R1,R2
         JO    *-4
*MCALL #=   554 LV= 1          RT1   CCE
         DS    0H
RT1_TEST527      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE527
         LTORG 
RT1_CCE527      DS 0H
*MEXIT #=   554 LV= 1 RT1
         LA    R1,=C'ABAX'
         LA    R2,=C'ABCX'
         CLST  R1,R2
         JO    *-4
*MCALL #=   555 LV= 1          RT1   CC1
         DS    0H
RT1_TEST528      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL528
         LTORG 
RT1_CCL528      DS 0H
*MEXIT #=   555 LV= 1 RT1
         CLI   0(R1),C'A'
*MCALL #=   556 LV= 1          RT1   CCE
         DS    0H
RT1_TEST529      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE529
         LTORG 
RT1_CCE529      DS 0H
*MEXIT #=   556 LV= 1 RT1
         CLI   0(R2),C'C'
*MCALL #=   557 LV= 1          RT1   CCE
         DS    0H
RT1_TEST530      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE530
         LTORG 
RT1_CCE530      DS 0H
*MEXIT #=   557 LV= 1 RT1
         LA    R1,=C'ABDX'
         LA    R2,=C'ABCX'
         CLST  R1,R2
         JO    *-4
*MCALL #=   558 LV= 1          RT1   CC2
         DS    0H
RT1_TEST531      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH531
         LTORG 
RT1_CCH531      DS 0H
*MEXIT #=   558 LV= 1 RT1
         CLI   0(R1),C'D'
*MCALL #=   559 LV= 1          RT1   CCE
         DS    0H
RT1_TEST532      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE532
         LTORG 
RT1_CCE532      DS 0H
*MEXIT #=   559 LV= 1 RT1
         CLI   0(R2),C'C'
*MCALL #=   560 LV= 1          RT1   CCE
         DS    0H
RT1_TEST533      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE533
         LTORG 
RT1_CCE533      DS 0H
*MEXIT #=   560 LV= 1 RT1
* B25E SRST
         LA    R0,C'B'
         LA    R2,=C'ABC'
         LA    R1,3(R2)
         SRST  R1,R2
*MCALL #=   561 LV= 1          RT1   CC1
         DS    0H
RT1_TEST534      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL534
         LTORG 
RT1_CCL534      DS 0H
*MEXIT #=   561 LV= 1 RT1
         CLI   0(R1),C'B'
*MCALL #=   562 LV= 1          RT1   CCE
         DS    0H
RT1_TEST535      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE535
         LTORG 
RT1_CCE535      DS 0H
*MEXIT #=   562 LV= 1 RT1
         LA    R0,C'X'
         LA    R2,=C'ABC'
         LA    R1,3(R2)
         SRST  R1,R2
*MCALL #=   563 LV= 1          RT1   CC2
         DS    0H
RT1_TEST536      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH536
         LTORG 
RT1_CCH536      DS 0H
*MEXIT #=   563 LV= 1 RT1
* B27C STCKF
         STCKF PWORK
*MCALL #=   564 LV= 1          RT1   CC0
         DS    0H
RT1_TEST537      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE537
         LTORG 
RT1_CCE537      DS 0H
*MEXIT #=   564 LV= 1 RT1
* B29D LFPC
         STFPC FPCREG
         CLI   FPCREG,X'70' VERIFY MASK FOR BFP DIV, OVF, UNF ONLY
*MCALL #=   565 LV= 1          RT1   CCE
         DS    0H
RT1_TEST538      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE538
         LTORG 
RT1_CCE538      DS 0H
*MEXIT #=   565 LV= 1 RT1
         OI    FPCREG,X'08' TURN ON BFP SIGNIFICANCE MASK IN FPC REG
         LFPC  FPCREG       RELOAD FPC
*MCALL #=   566 LV= 1          ESPIE SET,ESPIE_EXIT,7,PARAM=SEBR1  BFP X
               SIG FPCDXC=08
        LA     15,SEBR1
        IPM    0  GET CURRENT PGM MASK
        SPM    0 TURN ON ANY MASKS REQUIRED
        L      0,=B'00000001000000000000000000000000'
        LA     1,ESPIE_EXIT
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   566 LV= 1 ESPIE
         LE    R0,EBMIN
         LE    R1,EBMIN
         SEBR  R0,R1
*MCALL #=   567 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   567 LV= 1 RT1
*MCALL #=   568 LV= 1 SEBR1    ESPIE RESET
SEBR1    DS    0H
        SR     15,15
        SR     1,1
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   568 LV= 1 ESPIE
         STFPC FPCREG
         CLI   FPCDXC,X'08' VERIFY DXC
*MCALL #=   569 LV= 1          RT1   CCE
         DS    0H
RT1_TEST540      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE540
         LTORG 
RT1_CCE540      DS 0H
*MEXIT #=   569 LV= 1 RT1
*MCALL #=   570 LV= 1          WTO   'ESPIE BFP EB SIGNIFICANCE OK'
         BRAS  1,*+(WTO#0570_EOT-*+1)/2*2
         DC    AL2(WTO#0570_EOT-*,0),C'ESPIE BFP EB SIGNIFICANCE OK'
WTO#0570_EOT     EQU *
         SVC   35
*MEXIT #=   570 LV= 1 WTO
         XI    FPCREG,X'08' TURN IT BACK OFF
         LFPC  FPCREG
         STFPC FPCREG
         CLI   FPCREG,X'70' VERIFY MASK FOR BFP DIV, OVF, UNF ONLY
*MCALL #=   571 LV= 1          RT1   CCE
         DS    0H
RT1_TEST541      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE541
         LTORG 
RT1_CCE541      DS 0H
*MEXIT #=   571 LV= 1 RT1
* B2A5 TRE
         LA    R0,TREEOD
         LM    R2,R4,=A(TREF1,L'TREF1,TRETAB)
         TRE   R2,R4
*MCALL #=   572 LV= 1          RT1   CC0
         DS    0H
RT1_TEST542      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE542
         LTORG 
RT1_CCE542      DS 0H
*MEXIT #=   572 LV= 1 RT1
         CL    R2,=A(TREF1+L'TREF1)
*MCALL #=   573 LV= 1          RT1   CCE
         DS    0H
RT1_TEST543      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE543
         LTORG 
RT1_CCE543      DS 0H
*MEXIT #=   573 LV= 1 RT1
         LTR   R3,R3
*MCALL #=   574 LV= 1          RT1   CCE
         DS    0H
RT1_TEST544      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE544
         LTORG 
RT1_CCE544      DS 0H
*MEXIT #=   574 LV= 1 RT1
         CLC   TREF1,TREV1
*MCALL #=   575 LV= 1          RT1   CCE
         DS    0H
RT1_TEST545      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE545
         LTORG 
RT1_CCE545      DS 0H
*MEXIT #=   575 LV= 1 RT1
         LM    R2,R4,=A(TREF2,L'TREF2,TRETAB)
         TRE   R2,R4
*MCALL #=   576 LV= 1          RT1   CC1
         DS    0H
RT1_TEST546      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL546
         LTORG 
RT1_CCL546      DS 0H
*MEXIT #=   576 LV= 1 RT1
         CL    R2,=A(TREF2+2)   TREF2 HAS EOD X'FF' IN 3RD BYTE
*MCALL #=   577 LV= 1          RT1   CCE
         DS    0H
RT1_TEST547      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE547
         LTORG 
RT1_CCE547      DS 0H
*MEXIT #=   577 LV= 1 RT1
         CL    R3,=A(L'TREF2-2)
*MCALL #=   578 LV= 1          RT1   CCE
         DS    0H
RT1_TEST548      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE548
         LTORG 
RT1_CCE548      DS 0H
*MEXIT #=   578 LV= 1 RT1
         CLC   TREF2,TREV2
*MCALL #=   579 LV= 1          RT1   CCE
         DS    0H
RT1_TEST549      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE549
         LTORG 
RT1_CCE549      DS 0H
*MEXIT #=   579 LV= 1 RT1
* B2B0 STFLE Z9 STORE FACILITIES BIT LIST EXTENDED
         LA    R0,7    RPI-859 LENGTH OF FACILITY BIT FIELD - 1
         STFLE PWORK
         CLC   PWORK(8),=X'E1000DC000000000'
*MCALL #=   580 LV= 1          RT1   CCE          VERIFY ZOS FACILITIESX
                INSTALLED AND ACTIVE
         DS    0H
RT1_TEST550      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE550
         LTORG 
RT1_CCE550      DS 0H
*MEXIT #=   580 LV= 1 RT1
* B384 LFPC
* B38C EFPC
         EFPC  R0
         CLM   R0,8,=X'70'  VERIFY MASK FOR BFP DIV, OVF, UNF ONLY
*MCALL #=   581 LV= 1          RT1   CCE
         DS    0H
RT1_TEST551      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE551
         LTORG 
RT1_CCE551      DS 0H
*MEXIT #=   581 LV= 1 RT1
         OILH  R0,X'0800'   TURN ON BFP SIGNIFICANCE MASK IN FPC REG
         SFPC  R0           RELOAD FPC
*MCALL #=   582 LV= 1          ESPIE SET,ESPIE_EXIT,7,PARAM=SEBR2  BFP X
               SIG FPCDXC=08
        LA     15,SEBR2
        IPM    0  GET CURRENT PGM MASK
        SPM    0 TURN ON ANY MASKS REQUIRED
        L      0,=B'00000001000000000000000000000000'
        LA     1,ESPIE_EXIT
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   582 LV= 1 ESPIE
         LE    R0,EBMIN
         LE    R1,EBMIN
         SEBR  R0,R1
*MCALL #=   583 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   583 LV= 1 RT1
*MCALL #=   584 LV= 1 SEBR2    ESPIE RESET
SEBR2    DS    0H
        SR     15,15
        SR     1,1
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   584 LV= 1 ESPIE
         EFPC  R0
         CLM   R0,2,=X'08' VERIFY FPCDXC CODE
*MCALL #=   585 LV= 1          RT1   CCE
         DS    0H
RT1_TEST553      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE553
         LTORG 
RT1_CCE553      DS 0H
*MEXIT #=   585 LV= 1 RT1
         NILH  R0,X'F7FF'  TURN BFP SIG MASK BACK OFF
         SFPC  R0
         EFPC  R0
         CLM   R0,8,=X'70' VERIFY MASK FOR BFP DIV, OVF, UNF ONLY
*MCALL #=   586 LV= 1          RT1   CCE
         DS    0H
RT1_TEST554      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE554
         LTORG 
RT1_CCE554      DS 0H
*MEXIT #=   586 LV= 1 RT1
* B900 LPGR
         LG    R1,=FL8'-1'
         LPGR  R0,R1
*MCALL #=   587 LV= 1          RT1   CCH
         DS    0H
RT1_TEST555      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH555
         LTORG 
RT1_CCH555      DS 0H
*MEXIT #=   587 LV= 1 RT1
         CLG   R0,=FL8'1'
*MCALL #=   588 LV= 1          RT1   CCE
         DS    0H
RT1_TEST556      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE556
         LTORG 
RT1_CCE556      DS 0H
*MEXIT #=   588 LV= 1 RT1
         LG    R1,=X'8000000000000000'
         LPGR  R0,R1
*MCALL #=   589 LV= 1          RT1   CC3
         DS    0H
RT1_TEST557      BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC3557
         LTORG 
RT1_CC3557      DS 0H
*MEXIT #=   589 LV= 1 RT1
* B901 LNGR
         LG    R1,=FL8'1'
         LNGR  R0,R1
*MCALL #=   590 LV= 1          RT1   CCL
         DS    0H
RT1_TEST558      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL558
         LTORG 
RT1_CCL558      DS 0H
*MEXIT #=   590 LV= 1 RT1
         CLG   R0,=FL8'-1'
*MCALL #=   591 LV= 1          RT1   CCE
         DS    0H
RT1_TEST559      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE559
         LTORG 
RT1_CCE559      DS 0H
*MEXIT #=   591 LV= 1 RT1
* B902 LTGR
         LG    R1,=FL8'1'
         LTGR  R0,R1
*MCALL #=   592 LV= 1          RT1   CCH
         DS    0H
RT1_TEST560      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH560
         LTORG 
RT1_CCH560      DS 0H
*MEXIT #=   592 LV= 1 RT1
         LG    R1,=FL8'-1'
         LTGR  R0,R1
*MCALL #=   593 LV= 1          RT1   CCL
         DS    0H
RT1_TEST561      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL561
         LTORG 
RT1_CCL561      DS 0H
*MEXIT #=   593 LV= 1 RT1
         LG    R1,=FL8'0'
         LTGR  R0,R1
*MCALL #=   594 LV= 1          RT1   CCE
         DS    0H
RT1_TEST562      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE562
         LTORG 
RT1_CCE562      DS 0H
*MEXIT #=   594 LV= 1 RT1
* B903 LCGR
         LG    R1,=FL8'1'
         LCGR  R0,R1
*MCALL #=   595 LV= 1          RT1   CCL
         DS    0H
RT1_TEST563      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL563
         LTORG 
RT1_CCL563      DS 0H
*MEXIT #=   595 LV= 1 RT1
         CLG   R0,=FL8'-1'
*MCALL #=   596 LV= 1          RT1   CCE
         DS    0H
RT1_TEST564      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE564
         LTORG 
RT1_CCE564      DS 0H
*MEXIT #=   596 LV= 1 RT1
         LG    R1,=FL8'-1'
         LCGR  R0,R1
*MCALL #=   597 LV= 1          RT1   CCH
         DS    0H
RT1_TEST565      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH565
         LTORG 
RT1_CCH565      DS 0H
*MEXIT #=   597 LV= 1 RT1
         CLG   R0,=FL8'1'
*MCALL #=   598 LV= 1          RT1   CCE
         DS    0H
RT1_TEST566      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE566
         LTORG 
RT1_CCE566      DS 0H
*MEXIT #=   598 LV= 1 RT1
         LG    R1,=X'8000000000000000'
         LCGR  R0,R1
*MCALL #=   599 LV= 1          RT1   CC3
         DS    0H
RT1_TEST567      BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC3567
         LTORG 
RT1_CC3567      DS 0H
*MEXIT #=   599 LV= 1 RT1
* B906 LGBR Z9 LOAD BYTE
         LA    R1,X'FF'
         SGR   R0,R0
         LGBR  R0,R1
         CLG   R0,=FL8'-1'
*MCALL #=   600 LV= 1          RT1   CCE
         DS    0H
RT1_TEST568      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE568
         LTORG 
RT1_CCE568      DS 0H
*MEXIT #=   600 LV= 1 RT1
* B907 LGHR Z9 LOAD HALFWORD
         ICM   R1,3,=X'FFFF'
         SGR   R0,R0
         LGHR  R0,R1
         CLG   R0,=FL8'-1'
*MCALL #=   601 LV= 1          RT1   CCE
         DS    0H
RT1_TEST569      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE569
         LTORG 
RT1_CCE569      DS 0H
*MEXIT #=   601 LV= 1 RT1
* B908 AGR
         LG    R0,=FL8'1'
         LG    R1,=FL8'3'
         AGR   R0,R1
*MCALL #=   602 LV= 1          RT1   CCH
         DS    0H
RT1_TEST570      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH570
         LTORG 
RT1_CCH570      DS 0H
*MEXIT #=   602 LV= 1 RT1
         CG    R0,=FL8'4'
*MCALL #=   603 LV= 1          RT1   CCE
         DS    0H
RT1_TEST571      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE571
         LTORG 
RT1_CCE571      DS 0H
*MEXIT #=   603 LV= 1 RT1
*MCALL #=   604 LV= 1          ESPIE SET,ESPIE_EXIT,8,PARAM=AGR1
        LA     15,AGR1
        IPM    0  GET CURRENT PGM MASK
        OILH   0,2048
        SPM    0 TURN ON ANY MASKS REQUIRED
        L      0,=B'00000000100000000000000000000000'
        LA     1,ESPIE_EXIT
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   604 LV= 1 ESPIE
         LG     R0,=X'7FFFFFFFFFFFFFFF'
         LG    R1,=FL8'1'
         AGR   R0,R1
*MCALL #=   605 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   605 LV= 1 RT1
*MCALL #=   606 LV= 1 AGR1     ESPIE RESET
AGR1     DS    0H
        SR     15,15
        SR     1,1
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   606 LV= 1 ESPIE
*MCALL #=   607 LV= 1          ESTAE ESTAE_EXIT,PARAM=AGR2
        LA     0,ESTAE_EXIT
        LA     1,AGR2
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   607 LV= 1 ESTAE
         LG    R0,=X'8000000000000000'
         LG    R1,=FL8'-1'
         AGR   R0,R1
*MCALL #=   608 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   608 LV= 1 RT1
*MCALL #=   609 LV= 1 AGR2     ESTAE 0
AGR2     DS    0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   609 LV= 1 ESTAE
* B909 SGR
         LG    R0,=FL8'1'
         LG    R1,=FL8'3'
         SGR   R0,R1
*MCALL #=   610 LV= 1          RT1   CCL
         DS    0H
RT1_TEST574      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL574
         LTORG 
RT1_CCL574      DS 0H
*MEXIT #=   610 LV= 1 RT1
         CG    R0,=FL8'-2'
*MCALL #=   611 LV= 1          RT1   CCE
         DS    0H
RT1_TEST575      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE575
         LTORG 
RT1_CCE575      DS 0H
*MEXIT #=   611 LV= 1 RT1
*MCALL #=   612 LV= 1          ESPIE SET,ESPIE_EXIT,8,PARAM=SGR1
        LA     15,SGR1
        IPM    0  GET CURRENT PGM MASK
        OILH   0,2048
        SPM    0 TURN ON ANY MASKS REQUIRED
        L      0,=B'00000000100000000000000000000000'
        LA     1,ESPIE_EXIT
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   612 LV= 1 ESPIE
         LG     R0,=X'7FFFFFFFFFFFFFFF'
         LG    R1,=FL8'-1'
         SGR   R0,R1
*MCALL #=   613 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   613 LV= 1 RT1
*MCALL #=   614 LV= 1 SGR1     ESPIE RESET
SGR1     DS    0H
        SR     15,15
        SR     1,1
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=   614 LV= 1 ESPIE
*MCALL #=   615 LV= 1          ESTAE ESTAE_EXIT,PARAM=SGR2
        LA     0,ESTAE_EXIT
        LA     1,SGR2
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   615 LV= 1 ESTAE
         LG    R0,=X'8000000000000000'
         LG    R1,=FL8'1'
         SGR   R0,R1
*MCALL #=   616 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   616 LV= 1 RT1
*MCALL #=   617 LV= 1 SGR2     ESTAE 0
SGR2     DS    0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   617 LV= 1 ESTAE
* B90A ALGR
         LG    R0,=FL8'3'
         LG    R2,=FL8'2'
         ALGR  R0,R2
*MCALL #=   618 LV= 1          RT1   CC1        NZ,NC
         DS    0H
RT1_TEST578      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL578
         LTORG 
RT1_CCL578      DS 0H
*MEXIT #=   618 LV= 1 RT1
         CLG   R0,=FL8'5'
*MCALL #=   619 LV= 1          RT1   CCE
         DS    0H
RT1_TEST579      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE579
         LTORG 
RT1_CCE579      DS 0H
*MEXIT #=   619 LV= 1 RT1
         LG    R0,=X'8000000000000000'
         LG    R2,=X'0000000000000001'
         ALGR  R0,R2
*MCALL #=   620 LV= 1          RT1   CC1        NZ,NC
         DS    0H
RT1_TEST580      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL580
         LTORG 
RT1_CCL580      DS 0H
*MEXIT #=   620 LV= 1 RT1
         CLG   R0,=X'8000000000000001'
*MCALL #=   621 LV= 1          RT1   CCE
         DS    0H
RT1_TEST581      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE581
         LTORG 
RT1_CCE581      DS 0H
*MEXIT #=   621 LV= 1 RT1
         LG    R0,=X'FFFFFFFFFFFFFFFF'
         LG    R2,=X'0000000000000001'
         ALGR  R0,R2
*MCALL #=   622 LV= 1          RT1   CC2        Z,C
         DS    0H
RT1_TEST582      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH582
         LTORG 
RT1_CCH582      DS 0H
*MEXIT #=   622 LV= 1 RT1
         CLG   R0,=X'0000000000000000'
*MCALL #=   623 LV= 1          RT1   CCE
         DS    0H
RT1_TEST583      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE583
         LTORG 
RT1_CCE583      DS 0H
*MEXIT #=   623 LV= 1 RT1
         LG    R0,=X'FFFFFFFFFFFFFFFF'
         LG    R2,=X'0000000000000002'
         ALGR  R0,R2
*MCALL #=   624 LV= 1          RT1   CC3        NZ,C
         DS    0H
RT1_TEST584      BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC3584
         LTORG 
RT1_CC3584      DS 0H
*MEXIT #=   624 LV= 1 RT1
         CLG   R0,=X'0000000000000001'
*MCALL #=   625 LV= 1          RT1   CCE
         DS    0H
RT1_TEST585      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE585
         LTORG 
RT1_CCE585      DS 0H
*MEXIT #=   625 LV= 1 RT1
         LG    R0,=X'0000000000000000'
         LG    R2,=X'0000000000000000'
         ALGR  R0,R2
*MCALL #=   626 LV= 1          RT1   CC0        Z,NC
         DS    0H
RT1_TEST586      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE586
         LTORG 
RT1_CCE586      DS 0H
*MEXIT #=   626 LV= 1 RT1
         CLG   R0,=X'0000000000000000'
*MCALL #=   627 LV= 1          RT1   CCE
         DS    0H
RT1_TEST587      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE587
         LTORG 
RT1_CCE587      DS 0H
*MEXIT #=   627 LV= 1 RT1
* B90B SLGR
         LG    R0,=X'FFFFFFFFFFFFFFFF'  RPI-879
         LG    R2,=X'8000000000000000'  RPI-879
         SLGR  R0,R2                    RPI-879
*MCALL #=   628 LV= 1          RT1   CC3        NZ,NB         RPI-879
         DS    0H
RT1_TEST588      BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC3588
         LTORG 
RT1_CC3588      DS 0H
*MEXIT #=   628 LV= 1 RT1
         CLG   R0,=X'7FFFFFFFFFFFFFFF'  RPI-879
*MCALL #=   629 LV= 1          RT1   CCE                      RPI-879
         DS    0H
RT1_TEST589      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE589
         LTORG 
RT1_CCE589      DS 0H
*MEXIT #=   629 LV= 1 RT1
         LG    R0,=X'8000000000000000'  RPI-831
         LG    R2,=X'A000000000000000'  RPI-831
         SLGR  R0,R2                    RPI-831
*MCALL #=   630 LV= 1          RT1   CC1        NZ,B          RPI-831
         DS    0H
RT1_TEST590      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL590
         LTORG 
RT1_CCL590      DS 0H
*MEXIT #=   630 LV= 1 RT1
         CLG   R0,=X'E000000000000000'  RPI-831
*MCALL #=   631 LV= 1          RT1   CCE                      RPI-831
         DS    0H
RT1_TEST591      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE591
         LTORG 
RT1_CCE591      DS 0H
*MEXIT #=   631 LV= 1 RT1
         LG    R0,=FL8'3'
         LG    R2,=FL8'2'
         SLGR  R0,R2
*MCALL #=   632 LV= 1          RT1   CC3        NZ,NB
         DS    0H
RT1_TEST592      BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC3592
         LTORG 
RT1_CC3592      DS 0H
*MEXIT #=   632 LV= 1 RT1
         CLG   R0,=FL8'1'
*MCALL #=   633 LV= 1          RT1   CCE
         DS    0H
RT1_TEST593      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE593
         LTORG 
RT1_CCE593      DS 0H
*MEXIT #=   633 LV= 1 RT1
         LG    R0,=X'8000000000000000'
         LG    R2,=X'0000000000000001'
         SLGR  R0,R2
*MCALL #=   634 LV= 1          RT1   CC3        NZ,NB
         DS    0H
RT1_TEST594      BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC3594
         LTORG 
RT1_CC3594      DS 0H
*MEXIT #=   634 LV= 1 RT1
         CLG   R0,=X'7FFFFFFFFFFFFFFF'
*MCALL #=   635 LV= 1          RT1   CCE
         DS    0H
RT1_TEST595      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE595
         LTORG 
RT1_CCE595      DS 0H
*MEXIT #=   635 LV= 1 RT1
         LG    R0,=X'0000000000000000'
         LG    R2,=X'0000000000000001'
         SLGR  R0,R2
*MCALL #=   636 LV= 1          RT1   CC1        NZ,B
         DS    0H
RT1_TEST596      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL596
         LTORG 
RT1_CCL596      DS 0H
*MEXIT #=   636 LV= 1 RT1
         CLG   R0,=X'FFFFFFFFFFFFFFFF'
*MCALL #=   637 LV= 1          RT1   CCE
         DS    0H
RT1_TEST597      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE597
         LTORG 
RT1_CCE597      DS 0H
*MEXIT #=   637 LV= 1 RT1
         LG    R0,=X'0000000000000001'
         LG    R2,=X'0000000000000001'
         SLGR  R0,R2
*MCALL #=   638 LV= 1          RT1   CC2        Z,NB
         DS    0H
RT1_TEST598      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH598
         LTORG 
RT1_CCH598      DS 0H
*MEXIT #=   638 LV= 1 RT1
         CLG   R0,=X'0000000000000000'
*MCALL #=   639 LV= 1          RT1   CCE
         DS    0H
RT1_TEST599      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE599
         LTORG 
RT1_CCE599      DS 0H
*MEXIT #=   639 LV= 1 RT1
         LG    R0,=X'0000000000000000'
         LG    R2,=X'0000000000000002'
         SLGR  R0,R2
*MCALL #=   640 LV= 1          RT1   CC1        NZ,B
         DS    0H
RT1_TEST600      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL600
         LTORG 
RT1_CCL600      DS 0H
*MEXIT #=   640 LV= 1 RT1
         CLG   R0,=X'FFFFFFFFFFFFFFFE'
*MCALL #=   641 LV= 1          RT1   CCE
         DS    0H
RT1_TEST601      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE601
         LTORG 
RT1_CCE601      DS 0H
*MEXIT #=   641 LV= 1 RT1
* B90C MSGR
         LG    R0,=FL8'2'
         LG    R2,=FL8'3'
         MSGR  R0,R2
         CG    R0,=FL8'6'
*MCALL #=   642 LV= 1          RT1   CCE
         DS    0H
RT1_TEST602      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE602
         LTORG 
RT1_CCE602      DS 0H
*MEXIT #=   642 LV= 1 RT1
* B90D DSGR
         LG    R1,=FL8'13'
         LG    R2,=FL8'4'
         DSGR  R0,R2
         CLG   R0,=FL8'1'
*MCALL #=   643 LV= 1          RT1   CCE
         DS    0H
RT1_TEST603      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE603
         LTORG 
RT1_CCE603      DS 0H
*MEXIT #=   643 LV= 1 RT1
         CLG   R1,=FL8'3'
*MCALL #=   644 LV= 1          RT1   CCE
         DS    0H
RT1_TEST604      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE604
         LTORG 
RT1_CCE604      DS 0H
*MEXIT #=   644 LV= 1 RT1
* B90E EREGG   R1,R2 RESTORE 64 BIT REGISTERS SEE PC/BAKR
* B91F LRVGR
         LG    R1,=X'0123456789ABCDEF'
         LRVGR R0,R1
         CLG   R0,=X'EFCDAB8967452301'
*MCALL #=   645 LV= 1          RT1   CCE
         DS    0H
RT1_TEST605      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE605
         LTORG 
RT1_CCE605      DS 0H
*MEXIT #=   645 LV= 1 RT1
         LG    1,=X'1122334455667788'
         LRVGR 1,1  RPI-1200
         CG    1,=X'8877665544332211'
*MCALL #=   646 LV= 1          RT1   CCE
         DS    0H
RT1_TEST606      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE606
         LTORG 
RT1_CCE606      DS 0H
*MEXIT #=   646 LV= 1 RT1
* B910 LPGFR
         L     R1,=F'-1'
         LPGFR R0,R1
*MCALL #=   647 LV= 1          RT1   CCH
         DS    0H
RT1_TEST607      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH607
         LTORG 
RT1_CCH607      DS 0H
*MEXIT #=   647 LV= 1 RT1
         CLG   R0,=FL8'1'
*MCALL #=   648 LV= 1          RT1   CCE
         DS    0H
RT1_TEST608      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE608
         LTORG 
RT1_CCE608      DS 0H
*MEXIT #=   648 LV= 1 RT1
         L     R1,=X'80000000'
         LPGFR R0,R1
*MCALL #=   649 LV= 1          RT1   CCH
         DS    0H
RT1_TEST609      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH609
         LTORG 
RT1_CCH609      DS 0H
*MEXIT #=   649 LV= 1 RT1
         CLG   R0,=X'0000000080000000'
*MCALL #=   650 LV= 1          RT1   CCE
         DS    0H
RT1_TEST610      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE610
         LTORG 
RT1_CCE610      DS 0H
*MEXIT #=   650 LV= 1 RT1
* B911 LNGFR
         L     R1,=F'1'
         LNGFR R0,R1
*MCALL #=   651 LV= 1          RT1   CCL
         DS    0H
RT1_TEST611      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL611
         LTORG 
RT1_CCL611      DS 0H
*MEXIT #=   651 LV= 1 RT1
         CLG   R0,=FL8'-1'
*MCALL #=   652 LV= 1          RT1   CCE
         DS    0H
RT1_TEST612      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE612
         LTORG 
RT1_CCE612      DS 0H
*MEXIT #=   652 LV= 1 RT1
* B912 LTGFR
         L     R1,=F'1'
         LTGFR  R0,R1
*MCALL #=   653 LV= 1          RT1   CCH
         DS    0H
RT1_TEST613      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH613
         LTORG 
RT1_CCH613      DS 0H
*MEXIT #=   653 LV= 1 RT1
         L     R1,=F'-1'
         LTGFR R0,R1
*MCALL #=   654 LV= 1          RT1   CCL
         DS    0H
RT1_TEST614      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL614
         LTORG 
RT1_CCL614      DS 0H
*MEXIT #=   654 LV= 1 RT1
         L     R1,=F'0'
         LTGFR R0,R1
*MCALL #=   655 LV= 1          RT1   CCE
         DS    0H
RT1_TEST615      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE615
         LTORG 
RT1_CCE615      DS 0H
*MEXIT #=   655 LV= 1 RT1
* B913 LCGFR
         L     R1,=F'1'
         LCGFR R0,R1
*MCALL #=   656 LV= 1          RT1   CCL
         DS    0H
RT1_TEST616      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL616
         LTORG 
RT1_CCL616      DS 0H
*MEXIT #=   656 LV= 1 RT1
         CLG   R0,=FL8'-1'
*MCALL #=   657 LV= 1          RT1   CCE
         DS    0H
RT1_TEST617      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE617
         LTORG 
RT1_CCE617      DS 0H
*MEXIT #=   657 LV= 1 RT1
         L     R1,=F'-1'
         LCGFR R0,R1
*MCALL #=   658 LV= 1          RT1   CCH
         DS    0H
RT1_TEST618      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH618
         LTORG 
RT1_CCH618      DS 0H
*MEXIT #=   658 LV= 1 RT1
         CLG   R0,=FL8'1'
*MCALL #=   659 LV= 1          RT1   CCE
         DS    0H
RT1_TEST619      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE619
         LTORG 
RT1_CCE619      DS 0H
*MEXIT #=   659 LV= 1 RT1
         L     R1,=X'80000000'
         LCGFR R0,R1
*MCALL #=   660 LV= 1          RT1   CCH
         DS    0H
RT1_TEST620      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH620
         LTORG 
RT1_CCH620      DS 0H
*MEXIT #=   660 LV= 1 RT1
         CLG   R0,=X'0000000080000000'
*MCALL #=   661 LV= 1          RT1   CCE
         DS    0H
RT1_TEST621      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE621
         LTORG 
RT1_CCE621      DS 0H
*MEXIT #=   661 LV= 1 RT1
* B914 LGFR
         L     R1,=F'-1'
         LGFR  R0,R1
         CLG   R0,=FL8'-1'
*MCALL #=   662 LV= 1          RT1   CCE
         DS    0H
RT1_TEST622      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE622
         LTORG 
RT1_CCE622      DS 0H
*MEXIT #=   662 LV= 1 RT1
         L     R1,=X'80000000'
         LGFR  R0,R1
         CLG   R0,=X'FFFFFFFF80000000'
*MCALL #=   663 LV= 1          RT1   CCE
         DS    0H
RT1_TEST623      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE623
         LTORG 
RT1_CCE623      DS 0H
*MEXIT #=   663 LV= 1 RT1
* B916 LLGFR
         L     R1,=F'-1'
         LLGFR R0,R1
         CLG   R0,=A(0,-1)
*MCALL #=   664 LV= 1          RT1   CCE
         DS    0H
RT1_TEST624      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE624
         LTORG 
RT1_CCE624      DS 0H
*MEXIT #=   664 LV= 1 RT1
* B917 LLGTR
         LG    R1,=FL8'-1'
         LLGTR R0,R1
         CLG   R0,=A(0,X'7FFFFFFF')
*MCALL #=   665 LV= 1          RT1   CCE
         DS    0H
RT1_TEST625      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE625
         LTORG 
RT1_CCE625      DS 0H
*MEXIT #=   665 LV= 1 RT1
* B918 AGFR
         LG    R0,=FL8'1'
         L     R1,=F'3'
         AGFR  R0,R1
*MCALL #=   666 LV= 1          RT1   CCH
         DS    0H
RT1_TEST626      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH626
         LTORG 
RT1_CCH626      DS 0H
*MEXIT #=   666 LV= 1 RT1
         CG    R0,=FL8'4'
*MCALL #=   667 LV= 1          RT1   CCE
         DS    0H
RT1_TEST627      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE627
         LTORG 
RT1_CCE627      DS 0H
*MEXIT #=   667 LV= 1 RT1
* B919 SGFR
         LG    R0,=FL8'1'
         L     R1,=F'3'
         SGFR  R0,R1
*MCALL #=   668 LV= 1          RT1   CCL
         DS    0H
RT1_TEST628      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL628
         LTORG 
RT1_CCL628      DS 0H
*MEXIT #=   668 LV= 1 RT1
         CG    R0,=FL8'-2'
*MCALL #=   669 LV= 1          RT1   CCE
         DS    0H
RT1_TEST629      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE629
         LTORG 
RT1_CCE629      DS 0H
*MEXIT #=   669 LV= 1 RT1
* B91A ALGFR
         LG    R0,=FL8'3'
         L     R2,=F'2'
         ALGFR  R0,R2
*MCALL #=   670 LV= 1          RT1   CC1        NZ,NC
         DS    0H
RT1_TEST630      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL630
         LTORG 
RT1_CCL630      DS 0H
*MEXIT #=   670 LV= 1 RT1
         CLG   R0,=FL8'5'
*MCALL #=   671 LV= 1          RT1   CCE
         DS    0H
RT1_TEST631      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE631
         LTORG 
RT1_CCE631      DS 0H
*MEXIT #=   671 LV= 1 RT1
         LG    R0,=X'8000000000000000'
         L    R2,=X'00000001'
         ALGFR  R0,R2
*MCALL #=   672 LV= 1          RT1   CC1        NZ,NC
         DS    0H
RT1_TEST632      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL632
         LTORG 
RT1_CCL632      DS 0H
*MEXIT #=   672 LV= 1 RT1
         CLG   R0,=X'8000000000000001'
*MCALL #=   673 LV= 1          RT1   CCE
         DS    0H
RT1_TEST633      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE633
         LTORG 
RT1_CCE633      DS 0H
*MEXIT #=   673 LV= 1 RT1
         LG    R0,=X'FFFFFFFFFFFFFFFF'
         L     R2,=X'00000001'
         ALGFR  R0,R2
*MCALL #=   674 LV= 1          RT1   CC2        Z,C
         DS    0H
RT1_TEST634      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH634
         LTORG 
RT1_CCH634      DS 0H
*MEXIT #=   674 LV= 1 RT1
         CLG   R0,=X'0000000000000000'
*MCALL #=   675 LV= 1          RT1   CCE
         DS    0H
RT1_TEST635      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE635
         LTORG 
RT1_CCE635      DS 0H
*MEXIT #=   675 LV= 1 RT1
         LG    R0,=X'FFFFFFFFFFFFFFFF'
         L     R2,=X'00000002'
         ALGFR  R0,R2
*MCALL #=   676 LV= 1          RT1   CC3        NZ,C
         DS    0H
RT1_TEST636      BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC3636
         LTORG 
RT1_CC3636      DS 0H
*MEXIT #=   676 LV= 1 RT1
         CLG   R0,=X'0000000000000001'
*MCALL #=   677 LV= 1          RT1   CCE
         DS    0H
RT1_TEST637      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE637
         LTORG 
RT1_CCE637      DS 0H
*MEXIT #=   677 LV= 1 RT1
         LG    R0,=X'0000000000000000'
         L     R2,=X'00000000'
         ALGFR  R0,R2
*MCALL #=   678 LV= 1          RT1   CC0        Z,NC
         DS    0H
RT1_TEST638      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE638
         LTORG 
RT1_CCE638      DS 0H
*MEXIT #=   678 LV= 1 RT1
         CLG   R0,=X'0000000000000000'
*MCALL #=   679 LV= 1          RT1   CCE
         DS    0H
RT1_TEST639      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE639
         LTORG 
RT1_CCE639      DS 0H
*MEXIT #=   679 LV= 1 RT1
* B91B SLGFR
         LG    R0,=X'FFFFFFFFFFFFFFFF'  RPI-879
         L     R2,=X'80000000'          RPI-879
         SLGFR R0,R2                    RPI-879
*MCALL #=   680 LV= 1          RT1   CC3        NZ,NB         RPI-879
         DS    0H
RT1_TEST640      BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC3640
         LTORG 
RT1_CC3640      DS 0H
*MEXIT #=   680 LV= 1 RT1
         CLG   R0,=X'FFFFFFFF7FFFFFFF'  RPI-879
*MCALL #=   681 LV= 1          RT1   CCE                      RPI-879
         DS    0H
RT1_TEST641      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE641
         LTORG 
RT1_CCE641      DS 0H
*MEXIT #=   681 LV= 1 RT1
         LG    R0,=FL8'3'
         L     R2,=F'2'
         SLGFR  R0,R2
*MCALL #=   682 LV= 1          RT1   CC3        NZ,NB
         DS    0H
RT1_TEST642      BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC3642
         LTORG 
RT1_CC3642      DS 0H
*MEXIT #=   682 LV= 1 RT1
         CLG   R0,=FL8'1'
*MCALL #=   683 LV= 1          RT1   CCE
         DS    0H
RT1_TEST643      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE643
         LTORG 
RT1_CCE643      DS 0H
*MEXIT #=   683 LV= 1 RT1
         LG    R0,=X'8000000000000000'
         L     R2,=X'00000001'
         SLGFR  R0,R2
*MCALL #=   684 LV= 1          RT1   CC3        NZ,NB
         DS    0H
RT1_TEST644      BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC3644
         LTORG 
RT1_CC3644      DS 0H
*MEXIT #=   684 LV= 1 RT1
         CLG   R0,=X'7FFFFFFFFFFFFFFF'
*MCALL #=   685 LV= 1          RT1   CCE
         DS    0H
RT1_TEST645      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE645
         LTORG 
RT1_CCE645      DS 0H
*MEXIT #=   685 LV= 1 RT1
         LG    R0,=X'0000000000000000'
         L     R2,=X'00000001'
         SLGFR  R0,R2
*MCALL #=   686 LV= 1          RT1   CC1        NZ,B
         DS    0H
RT1_TEST646      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL646
         LTORG 
RT1_CCL646      DS 0H
*MEXIT #=   686 LV= 1 RT1
         CLG   R0,=X'FFFFFFFFFFFFFFFF'
*MCALL #=   687 LV= 1          RT1   CCE
         DS    0H
RT1_TEST647      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE647
         LTORG 
RT1_CCE647      DS 0H
*MEXIT #=   687 LV= 1 RT1
         LG    R0,=X'0000000000000001'
         L     R2,=X'00000001'
         SLGFR  R0,R2
*MCALL #=   688 LV= 1          RT1   CC2        Z,NB
         DS    0H
RT1_TEST648      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH648
         LTORG 
RT1_CCH648      DS 0H
*MEXIT #=   688 LV= 1 RT1
         CLG   R0,=X'0000000000000000'
*MCALL #=   689 LV= 1          RT1   CCE
         DS    0H
RT1_TEST649      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE649
         LTORG 
RT1_CCE649      DS 0H
*MEXIT #=   689 LV= 1 RT1
         LG    R0,=X'0000000000000000'
         L     R2,=X'00000002'
         SLGFR  R0,R2
*MCALL #=   690 LV= 1          RT1   CC1        NZ,B
         DS    0H
RT1_TEST650      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL650
         LTORG 
RT1_CCL650      DS 0H
*MEXIT #=   690 LV= 1 RT1
         CLG   R0,=X'FFFFFFFFFFFFFFFE'
*MCALL #=   691 LV= 1          RT1   CCE
         DS    0H
RT1_TEST651      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE651
         LTORG 
RT1_CCE651      DS 0H
*MEXIT #=   691 LV= 1 RT1
* B91C MSGFR
         LG    R0,=FL8'2'
         L     R2,=F'3'
         MSGFR R0,R2
         CG    R0,=FL8'6'
*MCALL #=   692 LV= 1          RT1   CCE
         DS    0H
RT1_TEST652      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE652
         LTORG 
RT1_CCE652      DS 0H
*MEXIT #=   692 LV= 1 RT1
* B91D DSGFR
         LG    R1,=FL8'13'
         L     R2,=F'4'
         DSGFR R0,R2
         CLG   R0,=FL8'1'
*MCALL #=   693 LV= 1          RT1   CCE
         DS    0H
RT1_TEST653      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE653
         LTORG 
RT1_CCE653      DS 0H
*MEXIT #=   693 LV= 1 RT1
         CLG   R1,=FL8'3'
*MCALL #=   694 LV= 1          RT1   CCE
         DS    0H
RT1_TEST654      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE654
         LTORG 
RT1_CCE654      DS 0H
*MEXIT #=   694 LV= 1 RT1
* B91F LRVR
         L     R1,=X'12345678'
         LRVR  R0,R1
         CL    R0,=X'78563412'
*MCALL #=   695 LV= 1          RT1   CCE
         DS    0H
RT1_TEST655      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE655
         LTORG 
RT1_CCE655      DS 0H
*MEXIT #=   695 LV= 1 RT1
         L     1,=X'11223344'
         LRVR  1,1  RPI-1200
         C     1,=X'44332211'
*MCALL #=   696 LV= 1          RT1   CCE
         DS    0H
RT1_TEST656      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE656
         LTORG 
RT1_CCE656      DS 0H
*MEXIT #=   696 LV= 1 RT1
* B920 CGR
         LG    R0,=FL8'1'
         LG    R1,=FL8'1'
         CGR   R0,R1
*MCALL #=   697 LV= 1          RT1   CCE
         DS    0H
RT1_TEST657      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE657
         LTORG 
RT1_CCE657      DS 0H
*MEXIT #=   697 LV= 1 RT1
         LG    R0,=FL8'-1'
         LG    R1,=FL8'1'
         CGR   R0,R1
*MCALL #=   698 LV= 1          RT1   CCL
         DS    0H
RT1_TEST658      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL658
         LTORG 
RT1_CCL658      DS 0H
*MEXIT #=   698 LV= 1 RT1
         LG    R0,=FL8'1'
         LG    R1,=FL8'-1'
         CGR   R0,R1
*MCALL #=   699 LV= 1          RT1   CCH
         DS    0H
RT1_TEST659      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH659
         LTORG 
RT1_CCH659      DS 0H
*MEXIT #=   699 LV= 1 RT1
* B921 CLGR
         LG    R1,=C'ABCDEFGH'
         LG    R2,=C'ABCDEFGH'
         CLGR  R1,R2
*MCALL #=   700 LV= 1          RT1   CCE
         DS    0H
RT1_TEST660      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE660
         LTORG 
RT1_CCE660      DS 0H
*MEXIT #=   700 LV= 1 RT1
         LG    R1,=C'ABCDEFGI'
         LG    R2,=C'ABCDEFGH'
         CLGR  R1,R2
*MCALL #=   701 LV= 1          RT1   CCH
         DS    0H
RT1_TEST661      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH661
         LTORG 
RT1_CCH661      DS 0H
*MEXIT #=   701 LV= 1 RT1
         LG    R1,=C'ABCCEFGH'
         LG    R2,=C'ABCDEFGH'
         CLGR  R1,R2
*MCALL #=   702 LV= 1          RT1   CCL
         DS    0H
RT1_TEST662      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL662
         LTORG 
RT1_CCL662      DS 0H
*MEXIT #=   702 LV= 1 RT1
* B926 LBR Z9 LOAD BYTE
         LA    R1,X'FF'
         SGR   R0,R0
         LBR   R0,R1
         CL    R0,=F'-1'
*MCALL #=   703 LV= 1          RT1   CCE
         DS    0H
RT1_TEST663      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE663
         LTORG 
RT1_CCE663      DS 0H
*MEXIT #=   703 LV= 1 RT1
* B927 LHR Z9 LOAD HALFWORD
         ICM   R1,3,=X'FFFF'
         SGR   R0,R0
         LHR   R0,R1
         CL    R0,=F'-1'
*MCALL #=   704 LV= 1          RT1   CCE
         DS    0H
RT1_TEST664      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE664
         LTORG 
RT1_CCE664      DS 0H
*MEXIT #=   704 LV= 1 RT1
* B930 CGFR
         LG    R0,=FL8'1'
         L     R1,=F'1'
         CGFR  R0,R1
*MCALL #=   705 LV= 1          RT1   CCE
         DS    0H
RT1_TEST665      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE665
         LTORG 
RT1_CCE665      DS 0H
*MEXIT #=   705 LV= 1 RT1
         LG    R0,=FL8'-1'
         L     R1,=F'1'
         CGFR  R0,R1
*MCALL #=   706 LV= 1          RT1   CCL
         DS    0H
RT1_TEST666      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL666
         LTORG 
RT1_CCL666      DS 0H
*MEXIT #=   706 LV= 1 RT1
         LG    R0,=FL8'1'
         L     R1,=F'-1'
         CGFR  R0,R1
*MCALL #=   707 LV= 1          RT1   CCH
         DS    0H
RT1_TEST667      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH667
         LTORG 
RT1_CCH667      DS 0H
*MEXIT #=   707 LV= 1 RT1
* B931 CLGFR
         LG    R0,=FL8'1'
         L     R1,=F'1'
         CLGFR  R0,R1
*MCALL #=   708 LV= 1          RT1   CCE
         DS    0H
RT1_TEST668      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE668
         LTORG 
RT1_CCE668      DS 0H
*MEXIT #=   708 LV= 1 RT1
         LG    R0,=FL8'-1'
         L     R1,=F'1'
         CLGFR  R0,R1
*MCALL #=   709 LV= 1          RT1   CCH
         DS    0H
RT1_TEST669      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH669
         LTORG 
RT1_CCH669      DS 0H
*MEXIT #=   709 LV= 1 RT1
         LG    R0,=FL8'1'
         L     R1,=F'-1'
         CLGFR  R0,R1
*MCALL #=   710 LV= 1          RT1   CCL
         DS    0H
RT1_TEST670      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL670
         LTORG 
RT1_CCL670      DS 0H
*MEXIT #=   710 LV= 1 RT1
* B946 BCTGR
         LG    R1,=FL8'2'
         BCTR  R1,0
         CLG   R1,=FL8'1'
*MCALL #=   711 LV= 1          RT1   CCE
         DS    0H
RT1_TEST671      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE671
         LTORG 
RT1_CCE671      DS 0H
*MEXIT #=   711 LV= 1 RT1
* B980 NGR
         LG    R0,=FL8'3'
         LG    R1,=FL8'2'
         NGR   R0,R1
*MCALL #=   712 LV= 1          RT1   CCL
         DS    0H
RT1_TEST672      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL672
         LTORG 
RT1_CCL672      DS 0H
*MEXIT #=   712 LV= 1 RT1
         CLG   R0,=FL8'2'
*MCALL #=   713 LV= 1          RT1   CCE
         DS    0H
RT1_TEST673      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE673
         LTORG 
RT1_CCE673      DS 0H
*MEXIT #=   713 LV= 1 RT1
* B981 OGR
         LG    R0,=FL8'1'
         LG    R1,=FL8'2'
         OGR   R0,R1
*MCALL #=   714 LV= 1          RT1   CCL
         DS    0H
RT1_TEST674      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL674
         LTORG 
RT1_CCL674      DS 0H
*MEXIT #=   714 LV= 1 RT1
         CLG   R0,=FL8'3'
*MCALL #=   715 LV= 1          RT1   CCE
         DS    0H
RT1_TEST675      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE675
         LTORG 
RT1_CCE675      DS 0H
*MEXIT #=   715 LV= 1 RT1
* B982 XGR
         LG    R0,=FL8'3'
         LG    R1,=FL8'2'
         XGR   R0,R1
*MCALL #=   716 LV= 1          RT1   CCL
         DS    0H
RT1_TEST676      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL676
         LTORG 
RT1_CCL676      DS 0H
*MEXIT #=   716 LV= 1 RT1
         CLG   R0,=FL8'1'
*MCALL #=   717 LV= 1          RT1   CCE
         DS    0H
RT1_TEST677      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE677
         LTORG 
RT1_CCE677      DS 0H
*MEXIT #=   717 LV= 1 RT1
* B983 FLOGR Z9 FIND LEFTMOST ONE
         LG    R2,=X'8000000000000000'
         FLOGR R0,R2
*MCALL #=   718 LV= 1          RT1   CC2
         DS    0H
RT1_TEST678      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH678
         LTORG 
RT1_CCH678      DS 0H
*MEXIT #=   718 LV= 1 RT1
         CLG   R0,=XL8'0'
*MCALL #=   719 LV= 1          RT1   CCE
         DS    0H
RT1_TEST679      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE679
         LTORG 
RT1_CCE679      DS 0H
*MEXIT #=   719 LV= 1 RT1
         CLG   R1,=FL8'0'
*MCALL #=   720 LV= 1          RT1   CCE
         DS    0H
RT1_TEST680      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE680
         LTORG 
RT1_CCE680      DS 0H
*MEXIT #=   720 LV= 1 RT1
         LG    R2,=FL8'0'
         FLOGR R0,R2
*MCALL #=   721 LV= 1          RT1   CC0
         DS    0H
RT1_TEST681      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE681
         LTORG 
RT1_CCE681      DS 0H
*MEXIT #=   721 LV= 1 RT1
         CLG   R0,=FL8'64'
*MCALL #=   722 LV= 1          RT1   CCE
         DS    0H
RT1_TEST682      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE682
         LTORG 
RT1_CCE682      DS 0H
*MEXIT #=   722 LV= 1 RT1
         CLG   R1,=FL8'0'
*MCALL #=   723 LV= 1          RT1   CCE
         DS    0H
RT1_TEST683      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE683
         LTORG 
RT1_CCE683      DS 0H
*MEXIT #=   723 LV= 1 RT1
         LG    R2,=FL8'1'
         FLOGR R0,R2
*MCALL #=   724 LV= 1          RT1   CC2
         DS    0H
RT1_TEST684      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH684
         LTORG 
RT1_CCH684      DS 0H
*MEXIT #=   724 LV= 1 RT1
         CLG   R0,=FL8'63'
*MCALL #=   725 LV= 1          RT1   CCE
         DS    0H
RT1_TEST685      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE685
         LTORG 
RT1_CCE685      DS 0H
*MEXIT #=   725 LV= 1 RT1
         CLG   R1,=FL8'0'
*MCALL #=   726 LV= 1          RT1   CCE
         DS    0H
RT1_TEST686      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE686
         LTORG 
RT1_CCE686      DS 0H
*MEXIT #=   726 LV= 1 RT1
         LG    R2,=FL8'3'
         FLOGR R0,R2
*MCALL #=   727 LV= 1          RT1   CC2
         DS    0H
RT1_TEST687      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH687
         LTORG 
RT1_CCH687      DS 0H
*MEXIT #=   727 LV= 1 RT1
         CLG   R0,=FL8'62'
*MCALL #=   728 LV= 1          RT1   CCE
         DS    0H
RT1_TEST688      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE688
         LTORG 
RT1_CCE688      DS 0H
*MEXIT #=   728 LV= 1 RT1
         CLG   R1,=FL8'1'
*MCALL #=   729 LV= 1          RT1   CCE
         DS    0H
RT1_TEST689      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE689
         LTORG 
RT1_CCE689      DS 0H
*MEXIT #=   729 LV= 1 RT1
* B984 LLGCR Z9 LOAD LOGICAL CHARACTER
         LA    R1,X'FF'
         SGR   R0,R0
         LLGCR R0,R1
         CLG   R0,=AD(X'FF')
*MCALL #=   730 LV= 1          RT1   CCE
         DS    0H
RT1_TEST690      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE690
         LTORG 
RT1_CCE690      DS 0H
*MEXIT #=   730 LV= 1 RT1
* B907 LLGHR Z9 LOAD LOGICAL HALFWORD
         ICM   R1,3,=X'FFFF'
         SGR   R0,R0
         LLGHR R0,R1
         CLG   R0,=AD(X'FFFF')
*MCALL #=   731 LV= 1          RT1   CCE
         DS    0H
RT1_TEST691      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE691
         LTORG 
RT1_CCE691      DS 0H
*MEXIT #=   731 LV= 1 RT1
* B986 MLGR
         LG    R1,=FL8'3'
         LG    R2,=FL8'2'
         MLGR  R0,R2
         CLG   R0,=FL8'0'
*MCALL #=   732 LV= 1          RT1   CCE
         DS    0H
RT1_TEST692      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE692
         LTORG 
RT1_CCE692      DS 0H
*MEXIT #=   732 LV= 1 RT1
         CLG   R1,=FL8'6'
*MCALL #=   733 LV= 1          RT1   CCE
         DS    0H
RT1_TEST693      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE693
         LTORG 
RT1_CCE693      DS 0H
*MEXIT #=   733 LV= 1 RT1
         LG     R1,=X'8000000000000000'
         LG     R2,=X'8000000000000000'
         MLGR  R0,R2
         CLG   R0,=X'4000000000000000'
*MCALL #=   734 LV= 1          RT1   CCE
         DS    0H
RT1_TEST694      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE694
         LTORG 
RT1_CCE694      DS 0H
*MEXIT #=   734 LV= 1 RT1
         CLG   R1,=X'0000000000000000'
*MCALL #=   735 LV= 1          RT1   CCE
         DS    0H
RT1_TEST695      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE695
         LTORG 
RT1_CCE695      DS 0H
*MEXIT #=   735 LV= 1 RT1
* B987 DLGR
         LG    R0,=FL8'0'
         LG    R1,=FL8'13'
         LG    R2,=FL8'4'
         DLGR  R0,R2
         CLG   R0,=FL8'1'
*MCALL #=   736 LV= 1          RT1   CCE
         DS    0H
RT1_TEST696      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE696
         LTORG 
RT1_CCE696      DS 0H
*MEXIT #=   736 LV= 1 RT1
         CLG   R1,=FL8'3'
*MCALL #=   737 LV= 1          RT1   CCE
         DS    0H
RT1_TEST697      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE697
         LTORG 
RT1_CCE697      DS 0H
*MEXIT #=   737 LV= 1 RT1
         LG    R0,=X'4000000000000000'
         LG    R1,=FL8'2'
         LG    R2,=X'8000000000000000'
         DLGR  R0,R2
         CLG   R0,=FL8'2'
*MCALL #=   738 LV= 1          RT1   CCE
         DS    0H
RT1_TEST698      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE698
         LTORG 
RT1_CCE698      DS 0H
*MEXIT #=   738 LV= 1 RT1
         CLG   R1,=X'8000000000000000'
*MCALL #=   739 LV= 1          RT1   CCE
         DS    0H
RT1_TEST699      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE699
         LTORG 
RT1_CCE699      DS 0H
*MEXIT #=   739 LV= 1 RT1
* B988 ALCGR
         L     R0,=X'FFFFFFFF'
         L     R2,=X'00000001'
         ALR   R0,R2      Z,C
         LG    R0,=FL8'3'
         LG    R2,=FL8'2'
         ALCGR R0,R2
*MCALL #=   740 LV= 1          RT1   CC1        NZ,NC
         DS    0H
RT1_TEST700      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL700
         LTORG 
RT1_CCL700      DS 0H
*MEXIT #=   740 LV= 1 RT1
         CLG   R0,=FL8'6'
*MCALL #=   741 LV= 1          RT1   CCE
         DS    0H
RT1_TEST701      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE701
         LTORG 
RT1_CCE701      DS 0H
*MEXIT #=   741 LV= 1 RT1
         L     R0,=X'FFFFFFFF'
         L     R2,=X'00000002'
         ALR   R0,R2      NZ,C
         LG    R0,=X'8000000000000000'
         LG    R2,=X'0000000000000001'
         ALCGR R0,R2
*MCALL #=   742 LV= 1          RT1   CC1        NZ,NC
         DS    0H
RT1_TEST702      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL702
         LTORG 
RT1_CCL702      DS 0H
*MEXIT #=   742 LV= 1 RT1
         CLG   R0,=X'8000000000000002'
*MCALL #=   743 LV= 1          RT1   CCE
         DS    0H
RT1_TEST703      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE703
         LTORG 
RT1_CCE703      DS 0H
*MEXIT #=   743 LV= 1 RT1
         L     R0,=F'3'
         AL    R0,=F'2'   NZ,NC
         LG    R0,=X'FFFFFFFFFFFFFFFF'
         LG    R2,=X'0000000000000001'
         ALCGR R0,R2
*MCALL #=   744 LV= 1          RT1   CC2        Z,C
         DS    0H
RT1_TEST704      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH704
         LTORG 
RT1_CCH704      DS 0H
*MEXIT #=   744 LV= 1 RT1
         CLG   R0,=X'0000000000000000'
*MCALL #=   745 LV= 1          RT1   CCE
         DS    0H
RT1_TEST705      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE705
         LTORG 
RT1_CCE705      DS 0H
*MEXIT #=   745 LV= 1 RT1
         L     R0,=F'3'
         AL    R0,=F'2'   NZ,NC
         LG    R0,=X'0000000000000000'
         LG    R2,=X'0000000000000000'
         ALCGR R0,R2      Z,NC
*MCALL #=   746 LV= 1          RT1   CC0        Z,NC
         DS    0H
RT1_TEST706      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE706
         LTORG 
RT1_CCE706      DS 0H
*MEXIT #=   746 LV= 1 RT1
         L     R0,=F'3'
         AL    R0,=F'2'   NZ,NC
         LG    R0,=X'FFFFFFFFFFFFFFFF'
         LG    R2,=X'0000000000000002'
         ALCGR R0,R2
*MCALL #=   747 LV= 1          RT1   CC3        NZ,C
         DS    0H
RT1_TEST707      BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC3707
         LTORG 
RT1_CC3707      DS 0H
*MEXIT #=   747 LV= 1 RT1
         CLG   R0,=X'0000000000000001'
*MCALL #=   748 LV= 1          RT1   CCE
         DS    0H
RT1_TEST708      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE708
         LTORG 
RT1_CCE708      DS 0H
*MEXIT #=   748 LV= 1 RT1
         L     R0,=F'3'
         AL    R0,=F'2'   NZ,NC
         LG    R0,=X'0000000000000000'
         LG    R2,=X'0000000000000000'
         ALCGR R0,R2
*MCALL #=   749 LV= 1          RT1   CC0        Z,NC
         DS    0H
RT1_TEST709      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE709
         LTORG 
RT1_CCE709      DS 0H
*MEXIT #=   749 LV= 1 RT1
         CLG   R0,=X'0000000000000000'
*MCALL #=   750 LV= 1          RT1   CCE
         DS    0H
RT1_TEST710      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE710
         LTORG 
RT1_CCE710      DS 0H
*MEXIT #=   750 LV= 1 RT1
         LG    R0,=FL8'-1'
         ALG   R0,=FL8'2'          CC3 NZ,C
         LG    R1,=FL8'1'
         ALCGR R0,R1
*MCALL #=   751 LV= 1          RT1   CC1
         DS    0H
RT1_TEST711      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL711
         LTORG 
RT1_CCL711      DS 0H
*MEXIT #=   751 LV= 1 RT1
         CLG   R0,=FL8'3'
*MCALL #=   752 LV= 1          RT1   CCE
         DS    0H
RT1_TEST712      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE712
         LTORG 
RT1_CCE712      DS 0H
*MEXIT #=   752 LV= 1 RT1
         SGR   R0,R0              FORCE CC0 Z,NC
         LG    R1,=FL8'1'
         ALCGR R0,R1              RPI174 TEST < CC0
*MCALL #=   753 LV= 1          RT1   CC1
         DS    0H
RT1_TEST713      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL713
         LTORG 
RT1_CCL713      DS 0H
*MEXIT #=   753 LV= 1 RT1
         CLG   R0,=FL8'1'
*MCALL #=   754 LV= 1          RT1   CCE
         DS    0H
RT1_TEST714      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE714
         LTORG 
RT1_CCE714      DS 0H
*MEXIT #=   754 LV= 1 RT1
         SGR   R0,R0              FORCE CC0 Z,NC
         LG    R0,=FL8'-1'
         LG    R1,=FL8'-1'
         ALCGR R0,R1
*MCALL #=   755 LV= 1          RT1   CC3                RPI-376
         DS    0H
RT1_TEST715      BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC3715
         LTORG 
RT1_CC3715      DS 0H
*MEXIT #=   755 LV= 1 RT1
         CLG   R0,=FL8'-2'
*MCALL #=   756 LV= 1          RT1   CCE
         DS    0H
RT1_TEST716      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE716
         LTORG 
RT1_CCE716      DS 0H
*MEXIT #=   756 LV= 1 RT1
* B989 SLBGR
         CLI   =C'A',C'B' CC1= NZ,B
         LG    R0,=FL8'4'
         LG    R2,=FL8'2'
         SLBGR R0,R2
*MCALL #=   757 LV= 1          RT1   CC3        NZ,NB
         DS    0H
RT1_TEST717      BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC3717
         LTORG 
RT1_CC3717      DS 0H
*MEXIT #=   757 LV= 1 RT1
         CLG   R0,=FL8'1'
*MCALL #=   758 LV= 1          RT1   CCE
         DS    0H
RT1_TEST718      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE718
         LTORG 
RT1_CCE718      DS 0H
*MEXIT #=   758 LV= 1 RT1
         CLI   =C'A',C'B' CC1= NZ,B
         LG    R0,=X'8000000000000000'
         LG    R2,=X'0000000000000001'
         SLBGR R0,R2
*MCALL #=   759 LV= 1          RT1   CC3        NZ,NB
         DS    0H
RT1_TEST719      BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC3719
         LTORG 
RT1_CC3719      DS 0H
*MEXIT #=   759 LV= 1 RT1
         CLG   R0,=X'7FFFFFFFFFFFFFFE'
*MCALL #=   760 LV= 1          RT1   CCE
         DS    0H
RT1_TEST720      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE720
         LTORG 
RT1_CCE720      DS 0H
*MEXIT #=   760 LV= 1 RT1
         CLI   =C'A',C'B' CC1= NZ,B
         LG    R0,=X'0000000000000000'
         LG    R2,=X'0000000000000001'
         SLBGR R0,R2
*MCALL #=   761 LV= 1          RT1   CC1        NZ,B
         DS    0H
RT1_TEST721      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL721
         LTORG 
RT1_CCL721      DS 0H
*MEXIT #=   761 LV= 1 RT1
         CLG   R0,=X'FFFFFFFFFFFFFFFE'
*MCALL #=   762 LV= 1          RT1   CCE
         DS    0H
RT1_TEST722      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE722
         LTORG 
RT1_CCE722      DS 0H
*MEXIT #=   762 LV= 1 RT1
         CLI   =C'B',C'A' CC2= Z,NB
         LG    R0,=X'0000000000000001'
         LG    R2,=X'0000000000000001'
         SLBGR  R0,R2
*MCALL #=   763 LV= 1          RT1   CC2        Z,NB
         DS    0H
RT1_TEST723      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH723
         LTORG 
RT1_CCH723      DS 0H
*MEXIT #=   763 LV= 1 RT1
         CLG   R0,=X'0000000000000000'
*MCALL #=   764 LV= 1          RT1   CCE
         DS    0H
RT1_TEST724      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE724
         LTORG 
RT1_CCE724      DS 0H
*MEXIT #=   764 LV= 1 RT1
         CLI   =C'B',C'A' CC2= Z,NB
         LG    R0,=X'0000000000000000'
         LG    R2,=X'0000000000000002'
         SLBGR R0,R2
*MCALL #=   765 LV= 1          RT1   CC1        NZ,B
         DS    0H
RT1_TEST725      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL725
         LTORG 
RT1_CCL725      DS 0H
*MEXIT #=   765 LV= 1 RT1
         CLG   R0,=X'FFFFFFFFFFFFFFFE'
*MCALL #=   766 LV= 1          RT1   CCE
         DS    0H
RT1_TEST726      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE726
         LTORG 
RT1_CCE726      DS 0H
*MEXIT #=   766 LV= 1 RT1
         LG    R0,=FL8'2'
         LG    R2,=FL8'1'
         SLGR  R0,R2               CC3 NZ,NB
         SLBGR R0,R2               RPI174 TEST < CC3 NZ,NB
*MCALL #=   767 LV= 1          RT1   CC2                 CC2 Z,NB
         DS    0H
RT1_TEST727      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH727
         LTORG 
RT1_CCH727      DS 0H
*MEXIT #=   767 LV= 1 RT1
         CLG   R0,=FL8'0'
*MCALL #=   768 LV= 1          RT1   CCE
         DS    0H
RT1_TEST728      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE728
         LTORG 
RT1_CCE728      DS 0H
*MEXIT #=   768 LV= 1 RT1
         SGR   R0,R0               FORCE CC0 = Z,B
         LG    R1,=FL8'-1'
         SLBGR R0,R1               RPI174 TEST > CC0 Z,B
         LG    R1,=FL8'1'
         SLBGR R0,R1               RPI174 TEST < CC0 Z,B
*MCALL #=   769 LV= 1          RT1   CC1                 NZ,B
         DS    0H
RT1_TEST729      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL729
         LTORG 
RT1_CCL729      DS 0H
*MEXIT #=   769 LV= 1 RT1
         CLG   R0,=FL8'-2'
*MCALL #=   770 LV= 1          RT1   CCE
         DS    0H
RT1_TEST730      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE730
         LTORG 
RT1_CCE730      DS 0H
*MEXIT #=   770 LV= 1 RT1
* B990 TRTT
         L     R0,=A(TRTTEOD) TWO BYTE END OF DATA RPI-580
         LA    R1,TRTTTAB
         LM    R2,R4,=A(TRTTF1,L'TRTTF2,TRTTF2)
         TRTT  R2,R4,1 NO TEST BYTES
*MCALL #=   771 LV= 1          RT1   CC0
         DS    0H
RT1_TEST731      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE731
         LTORG 
RT1_CCE731      DS 0H
*MEXIT #=   771 LV= 1 RT1
         CL    R2,=A(TRTTF1+L'TRTTF2)
*MCALL #=   772 LV= 1          RT1   CC0
         DS    0H
RT1_TEST732      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE732
         LTORG 
RT1_CCE732      DS 0H
*MEXIT #=   772 LV= 1 RT1
         LTR   R3,R3
*MCALL #=   773 LV= 1          RT1   CC0
         DS    0H
RT1_TEST733      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE733
         LTORG 
RT1_CCE733      DS 0H
*MEXIT #=   773 LV= 1 RT1
         CL    R4,=A(TRTTF2+L'TRTTF2)
*MCALL #=   774 LV= 1          RT1   CC0
         DS    0H
RT1_TEST734      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE734
         LTORG 
RT1_CCE734      DS 0H
*MEXIT #=   774 LV= 1 RT1
         CLC   TRTTF1,TRTTF1V1
*MCALL #=   775 LV= 1          RT1   CCE
         DS    0H
RT1_TEST735      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE735
         LTORG 
RT1_CCE735      DS 0H
*MEXIT #=   775 LV= 1 RT1
         MVC   TRTTF1,=C!99999999!
         L     R0,=A(TRTTEOD) TWO BYTE END OF DATA RPI-580
         LA    R1,TRTTTAB
         LM    R2,R4,=A(TRTTF1,L'TRTTF2,TRTTF2)
         TRTT  R2,R4,0 TEST BYTES
*MCALL #=   776 LV= 1          RT1   CC1
         DS    0H
RT1_TEST736      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL736
         LTORG 
RT1_CCL736      DS 0H
*MEXIT #=   776 LV= 1 RT1
         CL    R2,=A(TRTTF1+4)
*MCALL #=   777 LV= 1          RT1   CC0
         DS    0H
RT1_TEST737      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE737
         LTORG 
RT1_CCE737      DS 0H
*MEXIT #=   777 LV= 1 RT1
         CL    R3,=A(L'TRTTF2-4)
*MCALL #=   778 LV= 1          RT1   CC0
         DS    0H
RT1_TEST738      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE738
         LTORG 
RT1_CCE738      DS 0H
*MEXIT #=   778 LV= 1 RT1
         CL    R4,=A(TRTTF2+4)
*MCALL #=   779 LV= 1          RT1   CC0
         DS    0H
RT1_TEST739      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE739
         LTORG 
RT1_CCE739      DS 0H
*MEXIT #=   779 LV= 1 RT1
         CLC   TRTTF1,TRTTF1V2
*MCALL #=   780 LV= 1          RT1   CCE
         DS    0H
RT1_TEST740      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE740
         LTORG 
RT1_CCE740      DS 0H
*MEXIT #=   780 LV= 1 RT1
* B991 TRTO
         L     R0,=A(TRTOEOD) TWO BYTE END OF DATA RPI-580
         LA    R1,TRTOTAB
         LM    R2,R4,=A(TRTOF1,L'TRTOF2,TRTOF2)
         TRTO  R2,R4,1 NO TEST BYTES
*MCALL #=   781 LV= 1          RT1   CC0
         DS    0H
RT1_TEST741      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE741
         LTORG 
RT1_CCE741      DS 0H
*MEXIT #=   781 LV= 1 RT1
         CL    R2,=A(TRTOF1+L'TRTOF2/2)
*MCALL #=   782 LV= 1          RT1   CC0
         DS    0H
RT1_TEST742      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE742
         LTORG 
RT1_CCE742      DS 0H
*MEXIT #=   782 LV= 1 RT1
         LTR   R3,R3
*MCALL #=   783 LV= 1          RT1   CC0
         DS    0H
RT1_TEST743      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE743
         LTORG 
RT1_CCE743      DS 0H
*MEXIT #=   783 LV= 1 RT1
         CL    R4,=A(TRTOF2+L'TRTOF2)
*MCALL #=   784 LV= 1          RT1   CC0
         DS    0H
RT1_TEST744      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE744
         LTORG 
RT1_CCE744      DS 0H
*MEXIT #=   784 LV= 1 RT1
         CLC   TRTOF1,TRTOF1V1
*MCALL #=   785 LV= 1          RT1   CCE
         DS    0H
RT1_TEST745      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE745
         LTORG 
RT1_CCE745      DS 0H
*MEXIT #=   785 LV= 1 RT1
         MVC   TRTOF1,=C!9999!
         L     R0,=A(TRTOEOD) TWO BYTE END OF DATA RPI-580
         LA    R1,TRTOTAB
         LM    R2,R4,=A(TRTOF1,L'TRTOF2,TRTOF2)
         TRTO  R2,R4,0 TEST BYTES
*MCALL #=   786 LV= 1          RT1   CC1
         DS    0H
RT1_TEST746      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL746
         LTORG 
RT1_CCL746      DS 0H
*MEXIT #=   786 LV= 1 RT1
         CL    R2,=A(TRTOF1+2)
*MCALL #=   787 LV= 1          RT1   CC0
         DS    0H
RT1_TEST747      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE747
         LTORG 
RT1_CCE747      DS 0H
*MEXIT #=   787 LV= 1 RT1
         CL    R3,=A(L'TRTOF2-4)
*MCALL #=   788 LV= 1          RT1   CC0
         DS    0H
RT1_TEST748      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE748
         LTORG 
RT1_CCE748      DS 0H
*MEXIT #=   788 LV= 1 RT1
         CL    R4,=A(TRTOF2+4)
*MCALL #=   789 LV= 1          RT1   CC0
         DS    0H
RT1_TEST749      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE749
         LTORG 
RT1_CCE749      DS 0H
*MEXIT #=   789 LV= 1 RT1
         CLC   TRTOF1,TRTOF1V2
*MCALL #=   790 LV= 1          RT1   CCE
         DS    0H
RT1_TEST750      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE750
         LTORG 
RT1_CCE750      DS 0H
*MEXIT #=   790 LV= 1 RT1
* B992 TROT
         L     R0,=A(TROTEOD) ONE BYTE END OF DATA RPI-580
         LA    R1,TROTTAB
         LM    R2,R4,=A(TROTF1,L'TROTF2,TROTF2)
         TROT  R2,R4,1 NO TEST BYTES
*MCALL #=   791 LV= 1          RT1   CC0
         DS    0H
RT1_TEST751      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE751
         LTORG 
RT1_CCE751      DS 0H
*MEXIT #=   791 LV= 1 RT1
         CL    R2,=A(TROTF1+2*L'TROTF2)
*MCALL #=   792 LV= 1          RT1   CC0
         DS    0H
RT1_TEST752      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE752
         LTORG 
RT1_CCE752      DS 0H
*MEXIT #=   792 LV= 1 RT1
         LTR   R3,R3
*MCALL #=   793 LV= 1          RT1   CC0
         DS    0H
RT1_TEST753      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE753
         LTORG 
RT1_CCE753      DS 0H
*MEXIT #=   793 LV= 1 RT1
         CL    R4,=A(TROTF2+L'TROTF2)
*MCALL #=   794 LV= 1          RT1   CC0
         DS    0H
RT1_TEST754      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE754
         LTORG 
RT1_CCE754      DS 0H
*MEXIT #=   794 LV= 1 RT1
         CLC   TROTF1,TROTF1V1
*MCALL #=   795 LV= 1          RT1   CCE
         DS    0H
RT1_TEST755      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE755
         LTORG 
RT1_CCE755      DS 0H
*MEXIT #=   795 LV= 1 RT1
         MVC   TROTF1,=C!99999999!
         L     R0,=A(TROTEOD) ONE BYTE END OF DATA RPI-580
         LA    R1,TROTTAB
         LM    R2,R4,=A(TROTF1,L'TROTF2,TROTF2)
         TROT  R2,R4,0 TEST BYTES
*MCALL #=   796 LV= 1          RT1   CC1
         DS    0H
RT1_TEST756      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL756
         LTORG 
RT1_CCL756      DS 0H
*MEXIT #=   796 LV= 1 RT1
         CL    R2,=A(TROTF1+4)
*MCALL #=   797 LV= 1          RT1   CC0
         DS    0H
RT1_TEST757      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE757
         LTORG 
RT1_CCE757      DS 0H
*MEXIT #=   797 LV= 1 RT1
         CL    R3,=A(L'TROTF2-2)
*MCALL #=   798 LV= 1          RT1   CC0
         DS    0H
RT1_TEST758      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE758
         LTORG 
RT1_CCE758      DS 0H
*MEXIT #=   798 LV= 1 RT1
         CL    R4,=A(TROTF2+2)
*MCALL #=   799 LV= 1          RT1   CC0
         DS    0H
RT1_TEST759      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE759
         LTORG 
RT1_CCE759      DS 0H
*MEXIT #=   799 LV= 1 RT1
         CLC   TROTF1,TROTF1V2
*MCALL #=   800 LV= 1          RT1   CCE
         DS    0H
RT1_TEST760      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE760
         LTORG 
RT1_CCE760      DS 0H
*MEXIT #=   800 LV= 1 RT1
* B993 TROO
         L     R0,=A(TROOEOD) ONE BYTE END OF DATA RPI-580
         LA    R1,TROOTAB
         LM    R2,R4,=A(TROOF1,L'TROOF2,TROOF2)
         TROO  R2,R4,1 NO TEST BYTES
*MCALL #=   801 LV= 1          RT1   CC0
         DS    0H
RT1_TEST761      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE761
         LTORG 
RT1_CCE761      DS 0H
*MEXIT #=   801 LV= 1 RT1
         CL    R2,=A(TROOF1+L'TROOF2)
*MCALL #=   802 LV= 1          RT1   CC0
         DS    0H
RT1_TEST762      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE762
         LTORG 
RT1_CCE762      DS 0H
*MEXIT #=   802 LV= 1 RT1
         LTR   R3,R3
*MCALL #=   803 LV= 1          RT1   CC0
         DS    0H
RT1_TEST763      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE763
         LTORG 
RT1_CCE763      DS 0H
*MEXIT #=   803 LV= 1 RT1
         CL    R4,=A(TROOF2+L'TROOF2)
*MCALL #=   804 LV= 1          RT1   CC0
         DS    0H
RT1_TEST764      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE764
         LTORG 
RT1_CCE764      DS 0H
*MEXIT #=   804 LV= 1 RT1
         CLC   TROOF1,TROOF1V1
*MCALL #=   805 LV= 1          RT1   CCE
         DS    0H
RT1_TEST765      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE765
         LTORG 
RT1_CCE765      DS 0H
*MEXIT #=   805 LV= 1 RT1
         MVC   TROOF1,=C!9999!
         L     R0,=A(TROOEOD) ONE BYTE END OF DATA RPI-580
         LA    R1,TROOTAB
         LM    R2,R4,=A(TROOF1,L'TROOF2,TROOF2)
         TROO  R2,R4,0 TEST BYTES
*MCALL #=   806 LV= 1          RT1   CC1
         DS    0H
RT1_TEST766      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL766
         LTORG 
RT1_CCL766      DS 0H
*MEXIT #=   806 LV= 1 RT1
         CL    R2,=A(TROOF1+2)
*MCALL #=   807 LV= 1          RT1   CC0
         DS    0H
RT1_TEST767      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE767
         LTORG 
RT1_CCE767      DS 0H
*MEXIT #=   807 LV= 1 RT1
         CL    R3,=A(L'TROOF2-2)
*MCALL #=   808 LV= 1          RT1   CC0
         DS    0H
RT1_TEST768      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE768
         LTORG 
RT1_CCE768      DS 0H
*MEXIT #=   808 LV= 1 RT1
         CL    R4,=A(TROOF2+2)
*MCALL #=   809 LV= 1          RT1   CC0
         DS    0H
RT1_TEST769      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE769
         LTORG 
RT1_CCE769      DS 0H
*MEXIT #=   809 LV= 1 RT1
         CLC   TROOF1,TROOF1V2
*MCALL #=   810 LV= 1          RT1   CCE
         DS    0H
RT1_TEST770      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE770
         LTORG 
RT1_CCE770      DS 0H
*MEXIT #=   810 LV= 1 RT1
* B994 LLCR Z9 LOAD LOGICAL CHARACTER
         LA    R1,X'FF'
         SGR   R0,R0
         LLCR  R0,R1
         CL    R0,=A(X'FF')
*MCALL #=   811 LV= 1          RT1   CCE
         DS    0H
RT1_TEST771      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE771
         LTORG 
RT1_CCE771      DS 0H
*MEXIT #=   811 LV= 1 RT1
* B995 LLHR Z9 LOAD LOGICAL HALFWORD
         ICM   R1,3,=X'FFFF'
         SGR   R0,R0
         LLHR  R0,R1
         CL    R0,=A(X'FFFF')
*MCALL #=   812 LV= 1          RT1   CCE
         DS    0H
RT1_TEST772      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE772
         LTORG 
RT1_CCE772      DS 0H
*MEXIT #=   812 LV= 1 RT1
* B996 MLR
         L     R0,=F'-1' JUNK
         L     R1,=F'3'
         L     R2,=F'2'
         MLR   R0,R2
         CL    R0,=F'0'
*MCALL #=   813 LV= 1          RT1   CCE
         DS    0H
RT1_TEST773      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE773
         LTORG 
RT1_CCE773      DS 0H
*MEXIT #=   813 LV= 1 RT1
         CL    R1,=F'6'
*MCALL #=   814 LV= 1          RT1   CCE
         DS    0H
RT1_TEST774      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE774
         LTORG 
RT1_CCE774      DS 0H
*MEXIT #=   814 LV= 1 RT1
         L     R1,=X'80000000'
         L     R2,=X'80000000'
         L     R0,=F'-1' JUNK
         MLR   R0,R2
         CL    R0,=X'40000000'
*MCALL #=   815 LV= 1          RT1   CCE
         DS    0H
RT1_TEST775      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE775
         LTORG 
RT1_CCE775      DS 0H
*MEXIT #=   815 LV= 1 RT1
         CL    R1,=X'00000000'
*MCALL #=   816 LV= 1          RT1   CCE
         DS    0H
RT1_TEST776      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE776
         LTORG 
RT1_CCE776      DS 0H
*MEXIT #=   816 LV= 1 RT1
* B997 DLR
         L     R0,=F'0'
         L     R1,=F'13'
         L     R2,=F'4'
         DLR   R0,R2
         CL    R0,=F'1'
*MCALL #=   817 LV= 1          RT1   CCE
         DS    0H
RT1_TEST777      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE777
         LTORG 
RT1_CCE777      DS 0H
*MEXIT #=   817 LV= 1 RT1
         CL    R1,=F'3'
*MCALL #=   818 LV= 1          RT1   CCE
         DS    0H
RT1_TEST778      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE778
         LTORG 
RT1_CCE778      DS 0H
*MEXIT #=   818 LV= 1 RT1
         L     R0,=X'40000000'
         L     R1,=F'2'
         L     R2,=X'80000000'
         DLR   R0,R2
         CL    R0,=F'2'
*MCALL #=   819 LV= 1          RT1   CCE
         DS    0H
RT1_TEST779      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE779
         LTORG 
RT1_CCE779      DS 0H
*MEXIT #=   819 LV= 1 RT1
         CL    R1,=X'80000000'
*MCALL #=   820 LV= 1          RT1   CCE
         DS    0H
RT1_TEST780      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE780
         LTORG 
RT1_CCE780      DS 0H
*MEXIT #=   820 LV= 1 RT1
* B998 ALCR
         L     R0,=X'FFFFFFFF'
         L     R2,=X'00000001'
         ALR   R0,R2      Z,C
         L     R0,=F'3'
         L     R2,=F'2'
         ALCR  R0,R2
*MCALL #=   821 LV= 1          RT1   CC1        NZ,NC
         DS    0H
RT1_TEST781      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL781
         LTORG 
RT1_CCL781      DS 0H
*MEXIT #=   821 LV= 1 RT1
         CL    R0,=F'6'
*MCALL #=   822 LV= 1          RT1   CCE
         DS    0H
RT1_TEST782      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE782
         LTORG 
RT1_CCE782      DS 0H
*MEXIT #=   822 LV= 1 RT1
         L     R0,=X'FFFFFFFF'
         L     R2,=X'00000002'
         ALR   R0,R2      NZ,C
         L     R0,=X'80000000'
         L     R2,=X'00000001'
         ALCR  R0,R2
*MCALL #=   823 LV= 1          RT1   CC1        NZ,NC
         DS    0H
RT1_TEST783      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL783
         LTORG 
RT1_CCL783      DS 0H
*MEXIT #=   823 LV= 1 RT1
         CL    R0,=X'80000002'
*MCALL #=   824 LV= 1          RT1   CCE
         DS    0H
RT1_TEST784      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE784
         LTORG 
RT1_CCE784      DS 0H
*MEXIT #=   824 LV= 1 RT1
         L     R0,=F'3'
         AL    R0,=F'2'   NZ,NC
         L     R0,=X'FFFFFFFF'
         L     R2,=X'00000001'
         ALCR  R0,R2
*MCALL #=   825 LV= 1          RT1   CC2        Z,C
         DS    0H
RT1_TEST785      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH785
         LTORG 
RT1_CCH785      DS 0H
*MEXIT #=   825 LV= 1 RT1
         CL    R0,=X'00000000'
*MCALL #=   826 LV= 1          RT1   CCE
         DS    0H
RT1_TEST786      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE786
         LTORG 
RT1_CCE786      DS 0H
*MEXIT #=   826 LV= 1 RT1
         L     R0,=F'3'
         AL    R0,=F'2'   NZ,NC
         L     R0,=X'00000000'
         L     R2,=X'00000000'
         ALCR  R0,R2      Z,NC
*MCALL #=   827 LV= 1          RT1   CC0        Z,NC
         DS    0H
RT1_TEST787      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE787
         LTORG 
RT1_CCE787      DS 0H
*MEXIT #=   827 LV= 1 RT1
         L     R0,=F'3'
         AL    R0,=F'2'   NZ,NC
         L     R0,=X'FFFFFFFF'
         L     R2,=X'00000002'
         ALCR  R0,R2
*MCALL #=   828 LV= 1          RT1   CC3        NZ,C
         DS    0H
RT1_TEST788      BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC3788
         LTORG 
RT1_CC3788      DS 0H
*MEXIT #=   828 LV= 1 RT1
         CL    R0,=X'00000001'
*MCALL #=   829 LV= 1          RT1   CCE
         DS    0H
RT1_TEST789      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE789
         LTORG 
RT1_CCE789      DS 0H
*MEXIT #=   829 LV= 1 RT1
         SR    R0,R0
         L     R0,=X'FFFFFFFF'
         L     R2,=X'FFFFFFFF'
         ALCR  R0,R2
*MCALL #=   830 LV= 1          RT1   CC3        NZ,C    RPI-376
         DS    0H
RT1_TEST790      BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC3790
         LTORG 
RT1_CC3790      DS 0H
*MEXIT #=   830 LV= 1 RT1
         CL    R0,=X'FFFFFFFE'
*MCALL #=   831 LV= 1          RT1   CCE
         DS    0H
RT1_TEST791      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE791
         LTORG 
RT1_CCE791      DS 0H
*MEXIT #=   831 LV= 1 RT1
         L     R0,=F'3'
         AL    R0,=F'2'   NZ,NC
         L     R0,=X'00000000'
         L     R2,=X'00000000'
         ALCR  R0,R2
*MCALL #=   832 LV= 1          RT1   CC0        Z,NC
         DS    0H
RT1_TEST792      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE792
         LTORG 
RT1_CCE792      DS 0H
*MEXIT #=   832 LV= 1 RT1
         CL    R0,=X'00000000'
*MCALL #=   833 LV= 1          RT1   CCE
         DS    0H
RT1_TEST793      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE793
         LTORG 
RT1_CCE793      DS 0H
*MEXIT #=   833 LV= 1 RT1
         L     R0,=X'FFFFFFFF'
         L     R2,=X'00000002'
         ALR   R0,R2    CC3 NZ,C
         L     R1,=F'1'
         ALCR  R0,R1               RPI174 TEST < CC3
*MCALL #=   834 LV= 1          RT1   CC1
         DS    0H
RT1_TEST794      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL794
         LTORG 
RT1_CCL794      DS 0H
*MEXIT #=   834 LV= 1 RT1
         CL    R0,=X'00000003'
*MCALL #=   835 LV= 1          RT1   CC0
         DS    0H
RT1_TEST795      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE795
         LTORG 
RT1_CCE795      DS 0H
*MEXIT #=   835 LV= 1 RT1
         SR    R0,R0               FORCE CC0 Z,NC
         L     R1,=F'1'
         ALCR  R0,R1               RPI174 TEST < CC0
*MCALL #=   836 LV= 1          RT1   CC1                 NZ,NC
         DS    0H
RT1_TEST796      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL796
         LTORG 
RT1_CCL796      DS 0H
*MEXIT #=   836 LV= 1 RT1
         CL    R0,=F'1'
*MCALL #=   837 LV= 1          RT1   CCE
         DS    0H
RT1_TEST797      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE797
         LTORG 
RT1_CCE797      DS 0H
*MEXIT #=   837 LV= 1 RT1
* B999 SLBR
         CLI   =C'A',C'B'  CC1 = NZ,B
         L     R0,=F'4'
         L     R2,=F'2'
         SLBR  R0,R2
*MCALL #=   838 LV= 1          RT1   CC3        NZ,NB
         DS    0H
RT1_TEST798      BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC3798
         LTORG 
RT1_CC3798      DS 0H
*MEXIT #=   838 LV= 1 RT1
         CL    R0,=F'1'
*MCALL #=   839 LV= 1          RT1   CCE
         DS    0H
RT1_TEST799      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE799
         LTORG 
RT1_CCE799      DS 0H
*MEXIT #=   839 LV= 1 RT1
         CLI   =C'A',C'B'  CC1 = NZ,B
         L     R0,=X'80000000'
         L     R2,=X'00000001'
         SLBR  R0,R2
*MCALL #=   840 LV= 1          RT1   CC3        NZ,NB
         DS    0H
RT1_TEST800      BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC3800
         LTORG 
RT1_CC3800      DS 0H
*MEXIT #=   840 LV= 1 RT1
         CL    R0,=X'7FFFFFFE'
*MCALL #=   841 LV= 1          RT1   CCE
         DS    0H
RT1_TEST801      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE801
         LTORG 
RT1_CCE801      DS 0H
*MEXIT #=   841 LV= 1 RT1
         CLI   =C'A',C'B'  CC1 = NZ,B
         L     R0,=X'00000000'
         L     R2,=X'00000001'
         SLBR  R0,R2
*MCALL #=   842 LV= 1          RT1   CC1        NZ,B
         DS    0H
RT1_TEST802      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL802
         LTORG 
RT1_CCL802      DS 0H
*MEXIT #=   842 LV= 1 RT1
         CL    R0,=X'FFFFFFFE'
*MCALL #=   843 LV= 1          RT1   CCE
         DS    0H
RT1_TEST803      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE803
         LTORG 
RT1_CCE803      DS 0H
*MEXIT #=   843 LV= 1 RT1
         CLI   =C'B',C'A'  CC2 = Z,NB
         L     R0,=X'00000001'
         L     R2,=X'00000001'
         SLBR  R0,R2
*MCALL #=   844 LV= 1          RT1   CC2        Z,NB
         DS    0H
RT1_TEST804      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH804
         LTORG 
RT1_CCH804      DS 0H
*MEXIT #=   844 LV= 1 RT1
         CL    R0,=X'00000000'
*MCALL #=   845 LV= 1          RT1   CCE
         DS    0H
RT1_TEST805      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE805
         LTORG 
RT1_CCE805      DS 0H
*MEXIT #=   845 LV= 1 RT1
         CLI   =C'B',C'A'  CC2 = Z,NB
         L     R0,=X'00000000'
         L     R2,=X'00000002'
         SLBR  R0,R2
*MCALL #=   846 LV= 1          RT1   CC1        NZ,B
         DS    0H
RT1_TEST806      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL806
         LTORG 
RT1_CCL806      DS 0H
*MEXIT #=   846 LV= 1 RT1
         CL    R0,=X'FFFFFFFE'
*MCALL #=   847 LV= 1          RT1   CCE
         DS    0H
RT1_TEST807      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE807
         LTORG 
RT1_CCE807      DS 0H
*MEXIT #=   847 LV= 1 RT1
         L     R0,=F'2'
         L     R2,=F'1'
         SLR   R0,R2               CC3 NZ,NB
         SLBR  R0,R2               RPI174 TEST < CC3
*MCALL #=   848 LV= 1          RT1   CC2
         DS    0H
RT1_TEST808      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH808
         LTORG 
RT1_CCH808      DS 0H
*MEXIT #=   848 LV= 1 RT1
         CL    R0,=X'00000000'
*MCALL #=   849 LV= 1          RT1   CC0
         DS    0H
RT1_TEST809      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE809
         LTORG 
RT1_CCE809      DS 0H
*MEXIT #=   849 LV= 1 RT1
         SR    R0,R0               FORCE CC0 = Z,B
         L     R0,=F'0'
         L     R2,=F'-1'
         SLBR  R0,R2               RPI174 TEST > CC0 Z,B
         L     R1,=F'1'
         SLBR  R0,R1               RPI174 TEST < CC0 Z,B
*MCALL #=   850 LV= 1          RT1   CC1                 NZ,B
         DS    0H
RT1_TEST810      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL810
         LTORG 
RT1_CCL810      DS 0H
*MEXIT #=   850 LV= 1 RT1
         CL    R0,=F'-2'
*MCALL #=   851 LV= 1          RT1   CCE
         DS    0H
RT1_TEST811      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE811
         LTORG 
RT1_CCE811      DS 0H
*MEXIT #=   851 LV= 1 RT1
* BA   CS
         LM    R1,R2,=A(1,2)
         MVC   WORD,=A(3)
         CS    R1,R2,WORD
*MCALL #=   852 LV= 1          RT1   CC1
         DS    0H
RT1_TEST812      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL812
         LTORG 
RT1_CCL812      DS 0H
*MEXIT #=   852 LV= 1 RT1
         CL    R1,=A(3)
*MCALL #=   853 LV= 1          RT1   CCE
         DS    0H
RT1_TEST813      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE813
         LTORG 
RT1_CCE813      DS 0H
*MEXIT #=   853 LV= 1 RT1
         CLC   WORD,=A(3)
*MCALL #=   854 LV= 1          RT1   CCE
         DS    0H
RT1_TEST814      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE814
         LTORG 
RT1_CCE814      DS 0H
*MEXIT #=   854 LV= 1 RT1
         LM    R1,R2,=A(4,5)
         MVC   WORD,=A(4)
         CS    R1,R2,WORD
*MCALL #=   855 LV= 1          RT1   CC0
         DS    0H
RT1_TEST815      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE815
         LTORG 
RT1_CCE815      DS 0H
*MEXIT #=   855 LV= 1 RT1
         CL    R1,=A(4)
*MCALL #=   856 LV= 1          RT1   CCE
         DS    0H
RT1_TEST816      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE816
         LTORG 
RT1_CCE816      DS 0H
*MEXIT #=   856 LV= 1 RT1
         CLC   WORD,=A(5)
*MCALL #=   857 LV= 1          RT1   CCE
         DS    0H
RT1_TEST817      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE817
         LTORG 
RT1_CCE817      DS 0H
*MEXIT #=   857 LV= 1 RT1
* BB   CDS
         LM    R0,R3,=A(1,2,3,4)
         MVC   REGS(8),=A(5,6)
         CDS   R0,R2,REGS
*MCALL #=   858 LV= 1          RT1   CC1
         DS    0H
RT1_TEST818      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL818
         LTORG 
RT1_CCL818      DS 0H
*MEXIT #=   858 LV= 1 RT1
         CL    R0,=A(5)
*MCALL #=   859 LV= 1          RT1   CCE
         DS    0H
RT1_TEST819      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE819
         LTORG 
RT1_CCE819      DS 0H
*MEXIT #=   859 LV= 1 RT1
         CL    R1,=A(6)
*MCALL #=   860 LV= 1          RT1   CCE
         DS    0H
RT1_TEST820      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE820
         LTORG 
RT1_CCE820      DS 0H
*MEXIT #=   860 LV= 1 RT1
         CLC   REGS(8),=A(5,6)
*MCALL #=   861 LV= 1          RT1   CCE
         DS    0H
RT1_TEST821      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE821
         LTORG 
RT1_CCE821      DS 0H
*MEXIT #=   861 LV= 1 RT1
         LM    R0,R3,=A(1,2,3,4)
         MVC   REGS(8),=A(1,2)
         CDS   R0,R2,REGS
*MCALL #=   862 LV= 1          RT1   CC0
         DS    0H
RT1_TEST822      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE822
         LTORG 
RT1_CCE822      DS 0H
*MEXIT #=   862 LV= 1 RT1
         CL    R0,=A(1)
*MCALL #=   863 LV= 1          RT1   CCE
         DS    0H
RT1_TEST823      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE823
         LTORG 
RT1_CCE823      DS 0H
*MEXIT #=   863 LV= 1 RT1
         CL    R1,=A(2)
*MCALL #=   864 LV= 1          RT1   CCE
         DS    0H
RT1_TEST824      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE824
         LTORG 
RT1_CCE824      DS 0H
*MEXIT #=   864 LV= 1 RT1
         CLC   REGS(8),=A(3,4)
*MCALL #=   865 LV= 1          RT1   CCE
         DS    0H
RT1_TEST825      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE825
         LTORG 
RT1_CCE825      DS 0H
*MEXIT #=   865 LV= 1 RT1
* BD   CLM
         L     R1,=C'ABCD'
         CLM   R1,9,=C'AD'
*MCALL #=   866 LV= 1          RT1   CCE
         DS    0H
RT1_TEST826      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE826
         LTORG 
RT1_CCE826      DS 0H
*MEXIT #=   866 LV= 1 RT1
         L     R1,=C'ABCD'
         CLM   R1,9,=C'AC'
*MCALL #=   867 LV= 1          RT1   CCH
         DS    0H
RT1_TEST827      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH827
         LTORG 
RT1_CCH827      DS 0H
*MEXIT #=   867 LV= 1 RT1
         L     R1,=C'ABCD'
         CLM   R1,9,=C'AE'
*MCALL #=   868 LV= 1          RT1   CCL
         DS    0H
RT1_TEST828      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL828
         LTORG 
RT1_CCL828      DS 0H
*MEXIT #=   868 LV= 1 RT1
* BE   STCM
         L     R1,=C'4567'
         STCM  R1,15,WORD
         CLC   WORD,=C'4567'
*MCALL #=   869 LV= 1          RT1   CCE
         DS    0H
RT1_TEST829      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE829
         LTORG 
RT1_CCE829      DS 0H
*MEXIT #=   869 LV= 1 RT1
         L     R1,=C'4567'
         STCM  R1,9,WORD
         CLC   WORD(2),=C'47'
*MCALL #=   870 LV= 1          RT1   CCE
         DS    0H
RT1_TEST830      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE830
         LTORG 
RT1_CCE830      DS 0H
*MEXIT #=   870 LV= 1 RT1
* BF   ICM
         L     R1,=X'F1F2F3F4'
         ICM   R1,9,=X'CACD'
*MCALL #=   871 LV= 1          RT1   CCL
         DS    0H
RT1_TEST831      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL831
         LTORG 
RT1_CCL831      DS 0H
*MEXIT #=   871 LV= 1 RT1
         CL    R1,=X'CAF2F3CD'
*MCALL #=   872 LV= 1          RT1   CCE
         DS    0H
RT1_TEST832      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE832
         LTORG 
RT1_CCE832      DS 0H
*MEXIT #=   872 LV= 1 RT1
         ICM   R1,9,=X'0000'
*MCALL #=   873 LV= 1          RT1   CCE
         DS    0H
RT1_TEST833      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE833
         LTORG 
RT1_CCE833      DS 0H
*MEXIT #=   873 LV= 1 RT1
         CL    R1,=X'00F2F300'
*MCALL #=   874 LV= 1          RT1   CCE
         DS    0H
RT1_TEST834      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE834
         LTORG 
RT1_CCE834      DS 0H
*MEXIT #=   874 LV= 1 RT1
         ICM   R1,15,=X'12345678'
*MCALL #=   875 LV= 1          RT1   CCH                 RPI-295 TEST
         DS    0H
RT1_TEST835      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH835
         LTORG 
RT1_CCH835      DS 0H
*MEXIT #=   875 LV= 1 RT1
         CL    R1,=X'12345678'
*MCALL #=   876 LV= 1          RT1   CCE
         DS    0H
RT1_TEST836      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE836
         LTORG 
RT1_CCE836      DS 0H
*MEXIT #=   876 LV= 1 RT1
         ICM   R1,3,=X'FFFF'
*MCALL #=   877 LV= 1          RT1   CCL                 RPI-295 TEST
         DS    0H
RT1_TEST837      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL837
         LTORG 
RT1_CCL837      DS 0H
*MEXIT #=   877 LV= 1 RT1
         CL    R1,=X'1234FFFF'
*MCALL #=   878 LV= 1          RT1   CCE
         DS    0H
RT1_TEST838      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE838
         LTORG 
RT1_CCE838      DS 0H
*MEXIT #=   878 LV= 1 RT1
         ICM   R1,15,=X'FFFFFFFF'  RPI-303 TESTS
*MCALL #=   879 LV= 1          RT1   CCL
         DS    0H
RT1_TEST839      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL839
         LTORG 
RT1_CCL839      DS 0H
*MEXIT #=   879 LV= 1 RT1
         ICM   R1,15,=X'00FFFFFF'
*MCALL #=   880 LV= 1          RT1   CCH
         DS    0H
RT1_TEST840      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH840
         LTORG 
RT1_CCH840      DS 0H
*MEXIT #=   880 LV= 1 RT1
         ICM   R1,15,=X'7FFFFFFF'
*MCALL #=   881 LV= 1          RT1   CCH
         DS    0H
RT1_TEST841      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH841
         LTORG 
RT1_CCH841      DS 0H
*MEXIT #=   881 LV= 1 RT1
         ICM   R1,15,=X'00000000'
*MCALL #=   882 LV= 1          RT1   CCE
         DS    0H
RT1_TEST842      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE842
         LTORG 
RT1_CCE842      DS 0H
*MEXIT #=   882 LV= 1 RT1
         ICM   R1,0,=X'FFFFFFFF'
*MCALL #=   883 LV= 1          RT1   CCE
         DS    0H
RT1_TEST843      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE843
         LTORG 
RT1_CCE843      DS 0H
*MEXIT #=   883 LV= 1 RT1
         ICM   R1,7,=X'FFFFFF'
*MCALL #=   884 LV= 1          RT1   CCL
         DS    0H
RT1_TEST844      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL844
         LTORG 
RT1_CCL844      DS 0H
*MEXIT #=   884 LV= 1 RT1
         ICM   R1,7,=X'00FFFF'
*MCALL #=   885 LV= 1          RT1   CCH
         DS    0H
RT1_TEST845      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH845
         LTORG 
RT1_CCH845      DS 0H
*MEXIT #=   885 LV= 1 RT1
         ICM   R1,7,=X'7FFFFF'
*MCALL #=   886 LV= 1          RT1   CCH
         DS    0H
RT1_TEST846      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH846
         LTORG 
RT1_CCH846      DS 0H
*MEXIT #=   886 LV= 1 RT1
         ICM   R1,7,=X'000000'
*MCALL #=   887 LV= 1          RT1   CCE
         DS    0H
RT1_TEST847      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE847
         LTORG 
RT1_CCE847      DS 0H
*MEXIT #=   887 LV= 1 RT1
         ICM   R1,3,=X'FFFF'
*MCALL #=   888 LV= 1          RT1   CCL
         DS    0H
RT1_TEST848      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL848
         LTORG 
RT1_CCL848      DS 0H
*MEXIT #=   888 LV= 1 RT1
         ICM   R1,3,=X'00FF'
*MCALL #=   889 LV= 1          RT1   CCH
         DS    0H
RT1_TEST849      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH849
         LTORG 
RT1_CCH849      DS 0H
*MEXIT #=   889 LV= 1 RT1
         ICM   R1,3,=X'7FFF'
*MCALL #=   890 LV= 1          RT1   CCH
         DS    0H
RT1_TEST850      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH850
         LTORG 
RT1_CCH850      DS 0H
*MEXIT #=   890 LV= 1 RT1
         ICM   R1,3,=X'0000'
*MCALL #=   891 LV= 1          RT1   CCE
         DS    0H
RT1_TEST851      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE851
         LTORG 
RT1_CCE851      DS 0H
*MEXIT #=   891 LV= 1 RT1
         ICM   R1,1,=X'FF'
*MCALL #=   892 LV= 1          RT1   CCL
         DS    0H
RT1_TEST852      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL852
         LTORG 
RT1_CCL852      DS 0H
*MEXIT #=   892 LV= 1 RT1
         ICM   R1,1,=X'01'
*MCALL #=   893 LV= 1          RT1   CCH
         DS    0H
RT1_TEST853      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH853
         LTORG 
RT1_CCH853      DS 0H
*MEXIT #=   893 LV= 1 RT1
         ICM   R1,1,=X'7F'
*MCALL #=   894 LV= 1          RT1   CCH
         DS    0H
RT1_TEST854      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH854
         LTORG 
RT1_CCH854      DS 0H
*MEXIT #=   894 LV= 1 RT1
         ICM   R1,1,=X'00'
*MCALL #=   895 LV= 1          RT1   CCE
         DS    0H
RT1_TEST855      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE855
         LTORG 
RT1_CCE855      DS 0H
*MEXIT #=   895 LV= 1 RT1
* C00  LARL
         LARL  R1,*+6     RPI-844 WAS LARL R1,3
         CL    R1,=A(*)
*MCALL #=   896 LV= 1          RT1   CCE
         DS    0H
RT1_TEST856      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE856
         LTORG 
RT1_CCE856      DS 0H
*MEXIT #=   896 LV= 1 RT1
         LARL  R1,LARL1
LARL1    CL    R1,=A(LARL1)
* C01  LGFI
         SGR   R0,R0
         LGFI  R0,-1
         CG    R0,=FL8'-1'
*MCALL #=   897 LV= 1          RT1   CCE
         DS    0H
RT1_TEST857      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE857
         LTORG 
RT1_CCE857      DS 0H
*MEXIT #=   897 LV= 1 RT1
         SGR   R3,R3
         LGFI  R3,-1
         CG    R3,=FL8'-1'
*MCALL #=   898 LV= 1          RT1   CCE
         DS    0H
RT1_TEST858      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE858
         LTORG 
RT1_CCE858      DS 0H
*MEXIT #=   898 LV= 1 RT1
* C04  BRCL
         BRCL  15,BRCLOK
*MCALL #=   899 LV= 1 BRCLERR  RT1   ABORT
BRCLERR  DS    0H
         B      RT1_ABORT
*MEXIT #=   899 LV= 1 RT1
BRCLOK   EQU   *
         BRCL  0,BRCLERR
         JLNOP BRCLERR     RPI199
         BRUL  *+6         RPI199
         JLU   *+6         RPI199
         CLI   =X'1',1
         BRCL  7,BRCLERR
         BROL  BRCLERR     RPI199
         JLO   BRCLERR     RPI199
         BRHL  BRCLERR     RPI199
         JLH   BRCLERR     RPI199
         BRLL  BRCLERR     RPI199
         BRML  BRCLERR     RPI199
         JLL   BRCLERR     RPI199
         JLM   BRCLERR     RPI199
         BRNEL BRCLERR     RPI199
         BRNZL BRCLERR     RPI199
         JLNE  BRCLERR     RPI199
         JLNZ  BRCLERR     RPI199
         BRNOL *+6         RPI199
         JLNO  *+6         RPI199
*MCALL #=   900 LV= 1          RT1   CCE
         DS    0H
RT1_TEST860      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE860
         LTORG 
RT1_CCE860      DS 0H
*MEXIT #=   900 LV= 1 RT1
         CLI   =X'1',2
         BRCL  11,BRCLERR
         BRPL  BRCLERR     RPI199
         JLP   BRCLERR     RPI199
         BRNLL BRCLERR     RPI199
         BRNML BRCLERR     RPI199
         JLNL  BRCLERR     RPI199
         JLNM  BRCLERR     RPI199
*MCALL #=   901 LV= 1          RT1   CCL
         DS    0H
RT1_TEST861      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL861
         LTORG 
RT1_CCL861      DS 0H
*MEXIT #=   901 LV= 1 RT1
         CLI   =X'2',1
         BRCL  13,BRCLERR
         BREL  BRCLERR     RPI199
         BRZL  BRCLERR     RPI199
         JLE   BRCLERR     RPI199
         JLZ   BRCLERR     RPI199
         BRNHL BRCLERR     RPI199
         BRNPL BRCLERR     RPI199
         JLNH  BRCLERR     RPI199
         JLNP  BRCLERR     RPI199
*MCALL #=   902 LV= 1          RT1   CCH
         DS    0H
RT1_TEST862      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH862
         LTORG 
RT1_CCH862      DS 0H
*MEXIT #=   902 LV= 1 RT1
* C05  BRASL
BRASL1   BRASL R1,BRASL2
*MCALL #=   903 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   903 LV= 1 RT1
BRASL2   EQU   *
         NILH  R1,X'7FFF'
         CL    R1,=A(BRASL1+6)
*MCALL #=   904 LV= 1          RT1   CCE
         DS    0H
RT1_TEST864      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE864
         LTORG 
RT1_CCE864      DS 0H
*MEXIT #=   904 LV= 1 RT1
* C06  XIHF
         LG    R0,=X'0102030405060708'
         XIHF  R0,X'F1F0F0F0'
         CG    R0,=X'F0F2F3F405060708'
*MCALL #=   905 LV= 1          RT1   CCE
         DS    0H
RT1_TEST865      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE865
         LTORG 
RT1_CCE865      DS 0H
*MEXIT #=   905 LV= 1 RT1
* C07  XILF
         LG    R0,=X'0102030405060708'
         XILF  R0,X'F1F0F0F0'
         CG    R0,=X'01020304F4F6F7F8'
*MCALL #=   906 LV= 1          RT1   CCE
         DS    0H
RT1_TEST866      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE866
         LTORG 
RT1_CCE866      DS 0H
*MEXIT #=   906 LV= 1 RT1
* C08  IIHF
         LG    R0,=X'0102030405060708'
         IIHF  R0,X'F1F0F0F0'
         CG    R0,=X'F1F0F0F005060708'
*MCALL #=   907 LV= 1          RT1   CCE
         DS    0H
RT1_TEST867      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE867
         LTORG 
RT1_CCE867      DS 0H
*MEXIT #=   907 LV= 1 RT1
* C09  IILF
         LG    R0,=X'0102030405060708'
         IILF  R0,X'F1F0F0F0'
         CG    R0,=X'01020304F1F0F0F0'
*MCALL #=   908 LV= 1          RT1   CCE
         DS    0H
RT1_TEST868      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE868
         LTORG 
RT1_CCE868      DS 0H
*MEXIT #=   908 LV= 1 RT1
* C0A  NIHF
         LG    R0,=X'0102030405060708'
         NIHF  R0,X'F1F0F0F0'
         CG    R0,=X'0100000005060708'
*MCALL #=   909 LV= 1          RT1   CCE
         DS    0H
RT1_TEST869      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE869
         LTORG 
RT1_CCE869      DS 0H
*MEXIT #=   909 LV= 1 RT1
* C0B  NILF
         LG    R0,=X'0102030405060708'
         NILF  R0,X'F1F0F0F0'
         CG    R0,=X'0102030401000000'
*MCALL #=   910 LV= 1          RT1   CCE
         DS    0H
RT1_TEST870      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE870
         LTORG 
RT1_CCE870      DS 0H
*MEXIT #=   910 LV= 1 RT1
* C0C  OIHF
         LG    R0,=X'0102030405060708'
         OIHF  R0,X'F1F0F0F0'
         CG    R0,=X'F1F2F3F405060708'
*MCALL #=   911 LV= 1          RT1   CCE
         DS    0H
RT1_TEST871      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE871
         LTORG 
RT1_CCE871      DS 0H
*MEXIT #=   911 LV= 1 RT1
* C0D  OILF
         LG    R0,=X'0102030405060708'
         OILF  R0,X'F1F0F0F0'
         CG    R0,=X'01020304F5F6F7F8'
*MCALL #=   912 LV= 1          RT1   CCE
         DS    0H
RT1_TEST872      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE872
         LTORG 
RT1_CCE872      DS 0H
*MEXIT #=   912 LV= 1 RT1
* C0E  LLIHF
         LG    R0,=X'0102030405060708'
         LLIHF R0,X'F1F0F0F0'
         CG    R0,=X'F1F0F0F000000000'
*MCALL #=   913 LV= 1          RT1   CCE
         DS    0H
RT1_TEST873      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE873
         LTORG 
RT1_CCE873      DS 0H
*MEXIT #=   913 LV= 1 RT1
* C0F  LLILF
         LG    R0,=X'0102030405060708'
         LLILF R0,X'F1F0F0F0'
         CG    R0,=X'00000000F1F0F0F0'
*MCALL #=   914 LV= 1          RT1   CCE
         DS    0H
RT1_TEST874      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE874
         LTORG 
RT1_CCE874      DS 0H
*MEXIT #=   914 LV= 1 RT1
* C24  SLGFI
         LG    R0,=FL8'3'
         SLGFI R0,2
*MCALL #=   915 LV= 1          RT1   CC3        NZ,NB
         DS    0H
RT1_TEST875      BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC3875
         LTORG 
RT1_CC3875      DS 0H
*MEXIT #=   915 LV= 1 RT1
         CLG   R0,=FL8'1'
*MCALL #=   916 LV= 1          RT1   CCE
         DS    0H
RT1_TEST876      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE876
         LTORG 
RT1_CCE876      DS 0H
*MEXIT #=   916 LV= 1 RT1
         LG    R0,=X'8000000000000000'
         SLGFI R0,X'00000001'
*MCALL #=   917 LV= 1          RT1   CC3        NZ,NB
         DS    0H
RT1_TEST877      BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC3877
         LTORG 
RT1_CC3877      DS 0H
*MEXIT #=   917 LV= 1 RT1
         CLG   R0,=X'7FFFFFFFFFFFFFFF'
*MCALL #=   918 LV= 1          RT1   CCE
         DS    0H
RT1_TEST878      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE878
         LTORG 
RT1_CCE878      DS 0H
*MEXIT #=   918 LV= 1 RT1
         LG    R0,=X'0000000000000000'
         SLGFI R0,X'00000001'
*MCALL #=   919 LV= 1          RT1   CC1        NZ,B
         DS    0H
RT1_TEST879      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL879
         LTORG 
RT1_CCL879      DS 0H
*MEXIT #=   919 LV= 1 RT1
         CLG   R0,=X'FFFFFFFFFFFFFFFF'
*MCALL #=   920 LV= 1          RT1   CCE
         DS    0H
RT1_TEST880      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE880
         LTORG 
RT1_CCE880      DS 0H
*MEXIT #=   920 LV= 1 RT1
         LG    R0,=X'0000000000000001'
         SLG   R0,=X'0000000000000001'
*MCALL #=   921 LV= 1          RT1   CC2        Z,NB
         DS    0H
RT1_TEST881      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH881
         LTORG 
RT1_CCH881      DS 0H
*MEXIT #=   921 LV= 1 RT1
         CLG   R0,=X'0000000000000000'
*MCALL #=   922 LV= 1          RT1   CCE
         DS    0H
RT1_TEST882      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE882
         LTORG 
RT1_CCE882      DS 0H
*MEXIT #=   922 LV= 1 RT1
         LG    R0,=X'0000000000000000'
         SLGFI R0,X'00000002'
*MCALL #=   923 LV= 1          RT1   CC1        NZ,B
         DS    0H
RT1_TEST883      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL883
         LTORG 
RT1_CCL883      DS 0H
*MEXIT #=   923 LV= 1 RT1
         CLG   R0,=X'FFFFFFFFFFFFFFFE'
*MCALL #=   924 LV= 1          RT1   CCE
         DS    0H
RT1_TEST884      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE884
         LTORG 
RT1_CCE884      DS 0H
*MEXIT #=   924 LV= 1 RT1
         LG    R3,=FL8'3'
         SLGFI R3,2
*MCALL #=   925 LV= 1          RT1   CC3        NZ,NB
         DS    0H
RT1_TEST885      BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC3885
         LTORG 
RT1_CC3885      DS 0H
*MEXIT #=   925 LV= 1 RT1
         CLG   R3,=FL8'1'
*MCALL #=   926 LV= 1          RT1   CCE
         DS    0H
RT1_TEST886      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE886
         LTORG 
RT1_CCE886      DS 0H
*MEXIT #=   926 LV= 1 RT1
* C25  SLFI
         L     R0,=F'3'
         SLFI  R0,2
*MCALL #=   927 LV= 1          RT1   CC3        NZ,NB
         DS    0H
RT1_TEST887      BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC3887
         LTORG 
RT1_CC3887      DS 0H
*MEXIT #=   927 LV= 1 RT1
         CL    R0,=F'1'
*MCALL #=   928 LV= 1          RT1   CCE
         DS    0H
RT1_TEST888      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE888
         LTORG 
RT1_CCE888      DS 0H
*MEXIT #=   928 LV= 1 RT1
         L     R0,=X'80000000'
         SLFI  R0,X'00000001'
*MCALL #=   929 LV= 1          RT1   CC3        NZ,NB
         DS    0H
RT1_TEST889      BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC3889
         LTORG 
RT1_CC3889      DS 0H
*MEXIT #=   929 LV= 1 RT1
         CL    R0,=X'7FFFFFFF'
*MCALL #=   930 LV= 1          RT1   CCE
         DS    0H
RT1_TEST890      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE890
         LTORG 
RT1_CCE890      DS 0H
*MEXIT #=   930 LV= 1 RT1
         L     R0,=X'00000000'
         SLFI  R0,X'00000001'
*MCALL #=   931 LV= 1          RT1   CC1        NZ,B
         DS    0H
RT1_TEST891      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL891
         LTORG 
RT1_CCL891      DS 0H
*MEXIT #=   931 LV= 1 RT1
         CL    R0,=X'FFFFFFFF'
*MCALL #=   932 LV= 1          RT1   CCE
         DS    0H
RT1_TEST892      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE892
         LTORG 
RT1_CCE892      DS 0H
*MEXIT #=   932 LV= 1 RT1
         L     R0,=X'00000001'
         SLFI  R0,X'00000001'
*MCALL #=   933 LV= 1          RT1   CC2        Z,NB
         DS    0H
RT1_TEST893      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH893
         LTORG 
RT1_CCH893      DS 0H
*MEXIT #=   933 LV= 1 RT1
         CL    R0,=X'00000000'
*MCALL #=   934 LV= 1          RT1   CCE
         DS    0H
RT1_TEST894      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE894
         LTORG 
RT1_CCE894      DS 0H
*MEXIT #=   934 LV= 1 RT1
         L     R0,=X'00000000'
         SLFI  R0,X'00000002'
*MCALL #=   935 LV= 1          RT1   CC1        NZ,B
         DS    0H
RT1_TEST895      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL895
         LTORG 
RT1_CCL895      DS 0H
*MEXIT #=   935 LV= 1 RT1
         CL    R0,=X'FFFFFFFE'
*MCALL #=   936 LV= 1          RT1   CCE
         DS    0H
RT1_TEST896      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE896
         LTORG 
RT1_CCE896      DS 0H
*MEXIT #=   936 LV= 1 RT1
* C28  AGFI
         LG    R0,=X'0102030405060708'
         AGFI  R0,X'01010101'
*MCALL #=   937 LV= 1          RT1   CCH
         DS    0H
RT1_TEST897      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH897
         LTORG 
RT1_CCH897      DS 0H
*MEXIT #=   937 LV= 1 RT1
         CLG   R0,=X'0102030406070809'
*MCALL #=   938 LV= 1          RT1   CCE
         DS    0H
RT1_TEST898      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE898
         LTORG 
RT1_CCE898      DS 0H
*MEXIT #=   938 LV= 1 RT1
         LG    R0,=FL8'1'
         AGFI  R0,-2
*MCALL #=   939 LV= 1          RT1   CCL
         DS    0H
RT1_TEST899      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL899
         LTORG 
RT1_CCL899      DS 0H
*MEXIT #=   939 LV= 1 RT1
         CLG   R0,=FL8'-1'
*MCALL #=   940 LV= 1          RT1   CCE
         DS    0H
RT1_TEST900      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE900
         LTORG 
RT1_CCE900      DS 0H
*MEXIT #=   940 LV= 1 RT1
* C29  AFI
         L     R0,=X'01020304'
         AFI   R0,X'01010101'
*MCALL #=   941 LV= 1          RT1   CCH
         DS    0H
RT1_TEST901      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH901
         LTORG 
RT1_CCH901      DS 0H
*MEXIT #=   941 LV= 1 RT1
         CL    R0,=X'02030405'
*MCALL #=   942 LV= 1          RT1   CCE
         DS    0H
RT1_TEST902      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE902
         LTORG 
RT1_CCE902      DS 0H
*MEXIT #=   942 LV= 1 RT1
         L     R0,=F'1'
         AFI   R0,-2
*MCALL #=   943 LV= 1          RT1   CCL
         DS    0H
RT1_TEST903      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL903
         LTORG 
RT1_CCL903      DS 0H
*MEXIT #=   943 LV= 1 RT1
         CL    R0,=F'-1'
*MCALL #=   944 LV= 1          RT1   CCE
         DS    0H
RT1_TEST904      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE904
         LTORG 
RT1_CCE904      DS 0H
*MEXIT #=   944 LV= 1 RT1
* C2A  ALGFI
         LG    R0,=X'0102030405060708'
         ALGFI R0,X'F1F1F1F1'
*MCALL #=   945 LV= 1          RT1   CC1
         DS    0H
RT1_TEST905      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL905
         LTORG 
RT1_CCL905      DS 0H
*MEXIT #=   945 LV= 1 RT1
         CLG   R0,=X'01020304F6F7F8F9'
*MCALL #=   946 LV= 1          RT1   CCE
         DS    0H
RT1_TEST906      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE906
         LTORG 
RT1_CCE906      DS 0H
*MEXIT #=   946 LV= 1 RT1
* C2B  ALFI
         L     R0,=X'01020304'
         ALFI  R0,X'F1F1F1F1'
*MCALL #=   947 LV= 1          RT1   CC1
         DS    0H
RT1_TEST907      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL907
         LTORG 
RT1_CCL907      DS 0H
*MEXIT #=   947 LV= 1 RT1
         CL    R0,=X'F2F3F4F5'
*MCALL #=   948 LV= 1          RT1   CCE
         DS    0H
RT1_TEST908      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE908
         LTORG 
RT1_CCE908      DS 0H
*MEXIT #=   948 LV= 1 RT1
* C2C  CGFI
         LG    R0,=FL8'-123456'
         CGFI  R0,-123456
*MCALL #=   949 LV= 1          RT1   CCE
         DS    0H
RT1_TEST909      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE909
         LTORG 
RT1_CCE909      DS 0H
*MEXIT #=   949 LV= 1 RT1
* C2D  CFI
         L     R0,=F'-123456'
         CFI   R0,-123456
*MCALL #=   950 LV= 1          RT1   CCE
         DS    0H
RT1_TEST910      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE910
         LTORG 
RT1_CCE910      DS 0H
*MEXIT #=   950 LV= 1 RT1
* C2E  CLGFI
         LG    R0,=X'00000000FFFFFFFF'
         CLGFI R0,X'FFFFFFFF'
*MCALL #=   951 LV= 1          RT1   CCE
         DS    0H
RT1_TEST911      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE911
         LTORG 
RT1_CCE911      DS 0H
*MEXIT #=   951 LV= 1 RT1
* C2F  CLFI
         L     R0,=X'FFFFFFFF'
         CLFI  R0,X'FFFFFFFF'
*MCALL #=   952 LV= 1          RT1   CCE
         DS    0H
RT1_TEST912      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE912
         LTORG 
RT1_CCE912      DS 0H
*MEXIT #=   952 LV= 1 RT1
* D0   TRTR
         MVC   WORD,=AL1(3,2,1,0)
         LA    R1,0
         LA    R2,0
         TRTR  WORD+3,=C'ABCD'
*MCALL #=   953 LV= 1          RT1   CC1
         DS    0H
RT1_TEST913      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL913
         LTORG 
RT1_CCL913      DS 0H
*MEXIT #=   953 LV= 1 RT1
         CL    R1,=A(WORD+3)
*MCALL #=   954 LV= 1          RT1   CCE
         DS    0H
RT1_TEST914      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE914
         LTORG 
RT1_CCE914      DS 0H
*MEXIT #=   954 LV= 1 RT1
         CL    R2,=A(C'A')
*MCALL #=   955 LV= 1          RT1   CCE
         DS    0H
RT1_TEST915      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE915
         LTORG 
RT1_CCE915      DS 0H
*MEXIT #=   955 LV= 1 RT1
         MVC   WORD,=AL1(3,2,1,0)
         LA    R1,0
         LA    R2,0
         TRTR  WORD+3,=AL1(0,X'FF',0,0)
*MCALL #=   956 LV= 1          RT1   CC1
         DS    0H
RT1_TEST916      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL916
         LTORG 
RT1_CCL916      DS 0H
*MEXIT #=   956 LV= 1 RT1
         CL    R1,=A(WORD+2)
*MCALL #=   957 LV= 1          RT1   CCE
         DS    0H
RT1_TEST917      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE917
         LTORG 
RT1_CCE917      DS 0H
*MEXIT #=   957 LV= 1 RT1
         CL    R2,=A(X'FF')
*MCALL #=   958 LV= 1          RT1   CCE
         DS    0H
RT1_TEST918      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE918
         LTORG 
RT1_CCE918      DS 0H
*MEXIT #=   958 LV= 1 RT1
         MVC   WORD,=AL1(3,2,1,0)
         LA    R1,0
         LA    R2,0
         TRTR  WORD+3,=AL1(0,0,0,X'FF')
*MCALL #=   959 LV= 1          RT1   CC2
         DS    0H
RT1_TEST919      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH919
         LTORG 
RT1_CCH919      DS 0H
*MEXIT #=   959 LV= 1 RT1
         CL    R1,=A(WORD)
*MCALL #=   960 LV= 1          RT1   CCE
         DS    0H
RT1_TEST920      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE920
         LTORG 
RT1_CCE920      DS 0H
*MEXIT #=   960 LV= 1 RT1
         CL    R2,=A(X'FF')
*MCALL #=   961 LV= 1          RT1   CCE
         DS    0H
RT1_TEST921      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE921
         LTORG 
RT1_CCE921      DS 0H
*MEXIT #=   961 LV= 1 RT1
* D1   MVN
         MVC   BYTE,=C'A'
         MVN   BYTE,=C'2'
         CLI   BYTE,C'B'
*MCALL #=   962 LV= 1          RT1   CCE
         DS    0H
RT1_TEST922      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE922
         LTORG 
RT1_CCE922      DS 0H
*MEXIT #=   962 LV= 1 RT1
         MVC   PWORK,=C'ABCDEFGH'
         MVN   PWORK,=C'23456789'
         CLC   PWORK,=C'BCDEFGHI'
*MCALL #=   963 LV= 1          RT1   CCE
         DS    0H
RT1_TEST923      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE923
         LTORG 
RT1_CCE923      DS 0H
*MEXIT #=   963 LV= 1 RT1
* D2   MVC
         MVC   BYTE,=X'EE'
         CLI   BYTE,X'EE'
*MCALL #=   964 LV= 1          RT1   CCE
         DS    0H
RT1_TEST924      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE924
         LTORG 
RT1_CCE924      DS 0H
*MEXIT #=   964 LV= 1 RT1
         MVC   PWORK,=F'1,2'
         CLC   PWORK,=A(1,2)
*MCALL #=   965 LV= 1          RT1   CCE
         DS    0H
RT1_TEST925      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE925
         LTORG 
RT1_CCE925      DS 0H
*MEXIT #=   965 LV= 1 RT1
         MVC   PWORK,=8X'FF'
         CLC   PWORK,=8X'FF'
*MCALL #=   966 LV= 1          RT1   CCE
         DS    0H
RT1_TEST926      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE926
         LTORG 
RT1_CCE926      DS 0H
*MEXIT #=   966 LV= 1 RT1
         MVI   PWORK,X'EE'
         MVC   PWORK+1(7),PWORK  FILL WITH 1 BYTE
         CLC   PWORK,=8X'EE'
*MCALL #=   967 LV= 1          RT1   CCE
         DS    0H
RT1_TEST927      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE927
         LTORG 
RT1_CCE927      DS 0H
*MEXIT #=   967 LV= 1 RT1
         MVC   PWORK(2),=X'ABCD'
         MVC   PWORK+2(6),PWORK  FILL WITH 2 BYTES
         CLC   PWORK,=4X'ABCD'
*MCALL #=   968 LV= 1          RT1   CCE
         DS    0H
RT1_TEST928      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE928
         LTORG 
RT1_CCE928      DS 0H
*MEXIT #=   968 LV= 1 RT1
* D3   MVZ
         MVC   BYTE,=C'A'
         MVZ   BYTE,=C'2'
         CLI   BYTE,C'1'
*MCALL #=   969 LV= 1          RT1   CCE
         DS    0H
RT1_TEST929      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE929
         LTORG 
RT1_CCE929      DS 0H
*MEXIT #=   969 LV= 1 RT1
         MVC   PWORK,=C'ABCDEFGH'
         MVZ   PWORK,=C'23456789'
         CLC   PWORK,=C'12345678'
*MCALL #=   970 LV= 1          RT1   CCE
         DS    0H
RT1_TEST930      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE930
         LTORG 
RT1_CCE930      DS 0H
*MEXIT #=   970 LV= 1 RT1
* D4   NC
         MVC   PWORK,=X'0123456789ABCDEF'
         NC    PWORK,=X'0133557789ABCDFF'
*MCALL #=   971 LV= 1          RT1   CCL
         DS    0H
RT1_TEST931      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL931
         LTORG 
RT1_CCL931      DS 0H
*MEXIT #=   971 LV= 1 RT1
         CLC   PWORK,=X'0123456789ABCDEF'
*MCALL #=   972 LV= 1          RT1   CCE
         DS    0H
RT1_TEST932      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE932
         LTORG 
RT1_CCE932      DS 0H
*MEXIT #=   972 LV= 1 RT1
* D5   CLC
         MVC   PWORK,=F'1,2'
         CLC   PWORK,=A(1,2)
*MCALL #=   973 LV= 1          RT1   CCE
         DS    0H
RT1_TEST933      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE933
         LTORG 
RT1_CCE933      DS 0H
*MEXIT #=   973 LV= 1 RT1
         MVC   PWORK,=F'1,2'
         CLC   PWORK,=A(1,3)
*MCALL #=   974 LV= 1          RT1   CCL
         DS    0H
RT1_TEST934      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL934
         LTORG 
RT1_CCL934      DS 0H
*MEXIT #=   974 LV= 1 RT1
         MVC   PWORK,=F'1,2'
         CLC   PWORK,=A(1,1)
*MCALL #=   975 LV= 1          RT1   CCH
         DS    0H
RT1_TEST935      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH935
         LTORG 
RT1_CCH935      DS 0H
*MEXIT #=   975 LV= 1 RT1
* D6   OC
         MVC   PWORK,=X'123456789ABCDEF'
         OC    PWORK,=X'113151779ABCDFF'
*MCALL #=   976 LV= 1          RT1   CCL
         DS    0H
RT1_TEST936      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL936
         LTORG 
RT1_CCL936      DS 0H
*MEXIT #=   976 LV= 1 RT1
         CLC   PWORK,=X'1335577F9ABCDFF'
*MCALL #=   977 LV= 1          RT1   CCE
         DS    0H
RT1_TEST937      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE937
         LTORG 
RT1_CCE937      DS 0H
*MEXIT #=   977 LV= 1 RT1
* D7   XC
         MVC   PWORK,=X'123456789ABCDE8'
         XC    PWORK,=X'113151779ABCDE7'
*MCALL #=   978 LV= 1          RT1   CCL
         DS    0H
RT1_TEST938      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL938
         LTORG 
RT1_CCL938      DS 0H
*MEXIT #=   978 LV= 1 RT1
         CLC   PWORK,=X'0305070F000000F'
*MCALL #=   979 LV= 1          RT1   CCE
         DS    0H
RT1_TEST939      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE939
         LTORG 
RT1_CCE939      DS 0H
*MEXIT #=   979 LV= 1 RT1
* DC   TR
         MVC   WORD,=AL1(3,2,1,0)
         TR    WORD,=C'ABCD'
         CLC   WORD,=C'DCBA'
*MCALL #=   980 LV= 1          RT1   CCE
         DS    0H
RT1_TEST940      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE940
         LTORG 
RT1_CCE940      DS 0H
*MEXIT #=   980 LV= 1 RT1
* DD   TRT
         SAM31 ,                   RPI-844 FORCE AMODE31 FOR Z9/Z10
         MVC   WORD,=AL1(3,2,1,0)
         LHI   R1,-1               RPI-828
         LA    R2,0
         TRT   WORD,=C'ABCD'
*MCALL #=   981 LV= 1          RT1   CC1
         DS    0H
RT1_TEST941      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL941
         LTORG 
RT1_CCL941      DS 0H
*MEXIT #=   981 LV= 1 RT1
         CL    R1,=A(WORD)
*MCALL #=   982 LV= 1          RT1   CCE
         DS    0H
RT1_TEST942      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE942
         LTORG 
RT1_CCE942      DS 0H
*MEXIT #=   982 LV= 1 RT1
         CL    R2,=A(C'D')
*MCALL #=   983 LV= 1          RT1   CCE
         DS    0H
RT1_TEST943      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE943
         LTORG 
RT1_CCE943      DS 0H
*MEXIT #=   983 LV= 1 RT1
         MVC   WORD,=AL1(3,2,1,0)
         LHI   R1,-1               RPI-828
         LA    R2,0
         TRT   WORD,=AL1(0,X'FF',0,0)
*MCALL #=   984 LV= 1          RT1   CC1
         DS    0H
RT1_TEST944      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL944
         LTORG 
RT1_CCL944      DS 0H
*MEXIT #=   984 LV= 1 RT1
         CL    R1,=A(WORD+2)
*MCALL #=   985 LV= 1          RT1   CCE
         DS    0H
RT1_TEST945      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE945
         LTORG 
RT1_CCE945      DS 0H
*MEXIT #=   985 LV= 1 RT1
         CL    R2,=A(X'FF')
*MCALL #=   986 LV= 1          RT1   CCE
         DS    0H
RT1_TEST946      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE946
         LTORG 
RT1_CCE946      DS 0H
*MEXIT #=   986 LV= 1 RT1
         MVC   WORD,=AL1(3,2,1,0)
         LHI   R1,-1               RPI-828
         LA    R2,0
         TRT   WORD,=AL1(X'FF',0,0,0)
*MCALL #=   987 LV= 1          RT1   CC2
         DS    0H
RT1_TEST947      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH947
         LTORG 
RT1_CCH947      DS 0H
*MEXIT #=   987 LV= 1 RT1
         CL    R1,=A(WORD+3)
*MCALL #=   988 LV= 1          RT1   CCE
         DS    0H
RT1_TEST948      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE948
         LTORG 
RT1_CCE948      DS 0H
*MEXIT #=   988 LV= 1 RT1
         CL    R2,=A(X'FF')
*MCALL #=   989 LV= 1          RT1   CCE
         DS    0H
RT1_TEST949      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE949
         LTORG 
RT1_CCE949      DS 0H
*MEXIT #=   989 LV= 1 RT1
* DE   ED
         MVC   WORD,=X'40202020'
         ED    WORD,=P'123'
*MCALL #=   990 LV= 1          RT1   CCH
         DS    0H
RT1_TEST950      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH950
         LTORG 
RT1_CCH950      DS 0H
*MEXIT #=   990 LV= 1 RT1
         CLC   WORD,=C' 123'
*MCALL #=   991 LV= 1          RT1   CCE
         DS    0H
RT1_TEST951      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE951
         LTORG 
RT1_CCE951      DS 0H
*MEXIT #=   991 LV= 1 RT1
         MVC   WORD,=X'40202020'
         ED    WORD,=PL2'0'
*MCALL #=   992 LV= 1          RT1   CCE
         DS    0H
RT1_TEST952      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE952
         LTORG 
RT1_CCE952      DS 0H
*MEXIT #=   992 LV= 1 RT1
         CLC   WORD,=C'    '
*MCALL #=   993 LV= 1          RT1   CCE
         DS    0H
RT1_TEST953      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE953
         LTORG 
RT1_CCE953      DS 0H
*MEXIT #=   993 LV= 1 RT1
         MVC   WORD,=X'40202020'
         ED    WORD,=PL2'-1'
*MCALL #=   994 LV= 1          RT1   CCL
         DS    0H
RT1_TEST954      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL954
         LTORG 
RT1_CCL954      DS 0H
*MEXIT #=   994 LV= 1 RT1
         CLC   WORD,=C'   1'
*MCALL #=   995 LV= 1          RT1   CCE
         DS    0H
RT1_TEST955      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE955
         LTORG 
RT1_CCE955      DS 0H
*MEXIT #=   995 LV= 1 RT1
         MVC   WORD,=X'40202021'
         ED    WORD,=PL2'0'
*MCALL #=   996 LV= 1          RT1   CCE
         DS    0H
RT1_TEST956      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE956
         LTORG 
RT1_CCE956      DS 0H
*MEXIT #=   996 LV= 1 RT1
         CLC   WORD,=C'    '
*MCALL #=   997 LV= 1          RT1   CCE
         DS    0H
RT1_TEST957      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE957
         LTORG 
RT1_CCE957      DS 0H
*MEXIT #=   997 LV= 1 RT1
         MVC   WORD,=X'40202120'
         ED    WORD,=PL2'0'
*MCALL #=   998 LV= 1          RT1   CCE
         DS    0H
RT1_TEST958      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE958
         LTORG 
RT1_CCE958      DS 0H
*MEXIT #=   998 LV= 1 RT1
         CLC   WORD,=C'   0'
*MCALL #=   999 LV= 1          RT1   CCE
         DS    0H
RT1_TEST959      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE959
         LTORG 
RT1_CCE959      DS 0H
*MEXIT #=   999 LV= 1 RT1
         MVC   PWORK,NEGMASK BIMODAL EBCDIC MASK
         ED    PWORK,=P'123'
         CLC   PWORK,=CL8' 123'
*MCALL #=  1000 LV= 1          RT1   CCE
         DS    0H
RT1_TEST960      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE960
         LTORG 
RT1_CCE960      DS 0H
*MEXIT #=  1000 LV= 1 RT1
         MVC   PWORK,NEGMASK BIMODAL EBCDIC MASK
         ED    PWORK,=P'-123'
         CLC   PWORK+4(4),=C'-   '
*MCALL #=  1001 LV= 1          RT1   CCE
         DS    0H
RT1_TEST961      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE961
         LTORG 
RT1_CCE961      DS 0H
*MEXIT #=  1001 LV= 1 RT1
         CLC   PWORK,=CL8' 123-'
*MCALL #=  1002 LV= 1          RT1   CCE
         DS    0H
RT1_TEST962      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE962
         LTORG 
RT1_CCE962      DS 0H
*MEXIT #=  1002 LV= 1 RT1
* DF   EDMK
         LHI   R1,-1                 RPI-828
         MVC   WORD,=X'40202020'
         LHI   R1,-1                 RPI-828
         EDMK  WORD,=P'123'
         BCTR  R1,0
         MVI   0(R1),C'$'
         CLC   WORD,=C'$123'
* E302 LTG
         LTG   R0,=FL8'1'
*MCALL #=  1003 LV= 1          RT1   CCH
         DS    0H
RT1_TEST963      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH963
         LTORG 
RT1_CCH963      DS 0H
*MEXIT #=  1003 LV= 1 RT1
         LTG   R0,=FL8'-1'
*MCALL #=  1004 LV= 1          RT1   CCL
         DS    0H
RT1_TEST964      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL964
         LTORG 
RT1_CCL964      DS 0H
*MEXIT #=  1004 LV= 1 RT1
         LTG   R0,=FL8'0'
*MCALL #=  1005 LV= 1          RT1   CCE
         DS    0H
RT1_TEST965      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE965
         LTORG 
RT1_CCE965      DS 0H
*MEXIT #=  1005 LV= 1 RT1
* E304 LG
         LG    R0,=FL8'-1'
         STG   R0,PWORK
         CLC   PWORK,=X'FFFFFFFFFFFFFFFF'
* E306 CVBY
         CVBY  R0,=PL8'2147483647'
         CVDY  R0,PWORK
         CP  PWORK,=P'2147483647'
*MCALL #=  1006 LV= 1          RT1 CCE
         DS    0H
RT1_TEST966      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE966
         LTORG 
RT1_CCE966      DS 0H
*MEXIT #=  1006 LV= 1 RT1
* E308 AG
         LG    R0,=FL8'1'
         AG    R0,=FL8'3'
*MCALL #=  1007 LV= 1          RT1   CCH
         DS    0H
RT1_TEST967      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH967
         LTORG 
RT1_CCH967      DS 0H
*MEXIT #=  1007 LV= 1 RT1
         CG    R0,=FL8'4'
*MCALL #=  1008 LV= 1          RT1   CCE
         DS    0H
RT1_TEST968      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE968
         LTORG 
RT1_CCE968      DS 0H
*MEXIT #=  1008 LV= 1 RT1
* E309 SG
         LG    R0,=FL8'1'
         SG    R0,=FL8'3'
*MCALL #=  1009 LV= 1          RT1   CCL
         DS    0H
RT1_TEST969      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL969
         LTORG 
RT1_CCL969      DS 0H
*MEXIT #=  1009 LV= 1 RT1
         CG    R0,=FL8'-2'
*MCALL #=  1010 LV= 1          RT1   CCE
         DS    0H
RT1_TEST970      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE970
         LTORG 
RT1_CCE970      DS 0H
*MEXIT #=  1010 LV= 1 RT1
* E30A ALG
         LG    R0,=FL8'3'
         ALG   R0,=FL8'2'
*MCALL #=  1011 LV= 1          RT1   CC1        NZ,NC
         DS    0H
RT1_TEST971      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL971
         LTORG 
RT1_CCL971      DS 0H
*MEXIT #=  1011 LV= 1 RT1
         CLG   R0,=FL8'5'
*MCALL #=  1012 LV= 1          RT1   CCE
         DS    0H
RT1_TEST972      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE972
         LTORG 
RT1_CCE972      DS 0H
*MEXIT #=  1012 LV= 1 RT1
         LG    R0,=X'8000000000000000'
         ALG   R0,=X'0000000000000001'
*MCALL #=  1013 LV= 1          RT1   CC1        NZ,NC
         DS    0H
RT1_TEST973      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL973
         LTORG 
RT1_CCL973      DS 0H
*MEXIT #=  1013 LV= 1 RT1
         CLG   R0,=X'8000000000000001'
*MCALL #=  1014 LV= 1          RT1   CCE
         DS    0H
RT1_TEST974      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE974
         LTORG 
RT1_CCE974      DS 0H
*MEXIT #=  1014 LV= 1 RT1
         LG    R0,=X'FFFFFFFFFFFFFFFF'
         ALG   R0,=X'0000000000000001'
*MCALL #=  1015 LV= 1          RT1   CC2        Z,C
         DS    0H
RT1_TEST975      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH975
         LTORG 
RT1_CCH975      DS 0H
*MEXIT #=  1015 LV= 1 RT1
         CLG   R0,=X'0000000000000000'
*MCALL #=  1016 LV= 1          RT1   CCE
         DS    0H
RT1_TEST976      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE976
         LTORG 
RT1_CCE976      DS 0H
*MEXIT #=  1016 LV= 1 RT1
         LG    R0,=X'FFFFFFFFFFFFFFFF'
         ALG   R0,=X'0000000000000002'
*MCALL #=  1017 LV= 1          RT1   CC3        NZ,C
         DS    0H
RT1_TEST977      BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC3977
         LTORG 
RT1_CC3977      DS 0H
*MEXIT #=  1017 LV= 1 RT1
         CLG   R0,=X'0000000000000001'
*MCALL #=  1018 LV= 1          RT1   CCE
         DS    0H
RT1_TEST978      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE978
         LTORG 
RT1_CCE978      DS 0H
*MEXIT #=  1018 LV= 1 RT1
         LG    R0,=X'0000000000000000'
         ALG   R0,=X'0000000000000000'
*MCALL #=  1019 LV= 1          RT1   CC0        Z,NC
         DS    0H
RT1_TEST979      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE979
         LTORG 
RT1_CCE979      DS 0H
*MEXIT #=  1019 LV= 1 RT1
         CLG   R0,=X'0000000000000000'
*MCALL #=  1020 LV= 1          RT1   CCE
         DS    0H
RT1_TEST980      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE980
         LTORG 
RT1_CCE980      DS 0H
*MEXIT #=  1020 LV= 1 RT1
* E30B SLG
         LG    R0,=X'FFFFFFFFFFFFFFFF'  RPI-879
         SLG   R0,=X'8000000000000000'  RPI-879
*MCALL #=  1021 LV= 1          RT1   CC3        NZ,NB         RPI-879
         DS    0H
RT1_TEST981      BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC3981
         LTORG 
RT1_CC3981      DS 0H
*MEXIT #=  1021 LV= 1 RT1
         CLG   R0,=X'7FFFFFFFFFFFFFFF'  RPI-879
*MCALL #=  1022 LV= 1          RT1   CCE                      RPI-879
         DS    0H
RT1_TEST982      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE982
         LTORG 
RT1_CCE982      DS 0H
*MEXIT #=  1022 LV= 1 RT1
         LG    R0,=X'8000000000000000'  RPI-831
         SLG   R0,=X'A000000000000000'
*MCALL #=  1023 LV= 1          RT1   CC1        NZ,B
         DS    0H
RT1_TEST983      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL983
         LTORG 
RT1_CCL983      DS 0H
*MEXIT #=  1023 LV= 1 RT1
         CLG   R0,=X'E000000000000000'
*MCALL #=  1024 LV= 1          RT1   CCE
         DS    0H
RT1_TEST984      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE984
         LTORG 
RT1_CCE984      DS 0H
*MEXIT #=  1024 LV= 1 RT1
         LG    R0,=FL8'3'
         SLG   R0,=FL8'2'
*MCALL #=  1025 LV= 1          RT1   CC3        NZ,NB
         DS    0H
RT1_TEST985      BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC3985
         LTORG 
RT1_CC3985      DS 0H
*MEXIT #=  1025 LV= 1 RT1
         CLG   R0,=FL8'1'
*MCALL #=  1026 LV= 1          RT1   CCE
         DS    0H
RT1_TEST986      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE986
         LTORG 
RT1_CCE986      DS 0H
*MEXIT #=  1026 LV= 1 RT1
         LG    R0,=X'8000000000000000'
         SLG   R0,=X'0000000000000001'
*MCALL #=  1027 LV= 1          RT1   CC3        NZ,NB
         DS    0H
RT1_TEST987      BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC3987
         LTORG 
RT1_CC3987      DS 0H
*MEXIT #=  1027 LV= 1 RT1
         CLG   R0,=X'7FFFFFFFFFFFFFFF'
*MCALL #=  1028 LV= 1          RT1   CCE
         DS    0H
RT1_TEST988      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE988
         LTORG 
RT1_CCE988      DS 0H
*MEXIT #=  1028 LV= 1 RT1
         LG    R0,=X'0000000000000000'
         SLG   R0,=X'0000000000000001'
*MCALL #=  1029 LV= 1          RT1   CC1        NZ,B
         DS    0H
RT1_TEST989      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL989
         LTORG 
RT1_CCL989      DS 0H
*MEXIT #=  1029 LV= 1 RT1
         CLG   R0,=X'FFFFFFFFFFFFFFFF'
*MCALL #=  1030 LV= 1          RT1   CCE
         DS    0H
RT1_TEST990      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE990
         LTORG 
RT1_CCE990      DS 0H
*MEXIT #=  1030 LV= 1 RT1
         LG    R0,=X'0000000000000001'
         SLG   R0,=X'0000000000000001'
*MCALL #=  1031 LV= 1          RT1   CC2        Z,NB
         DS    0H
RT1_TEST991      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH991
         LTORG 
RT1_CCH991      DS 0H
*MEXIT #=  1031 LV= 1 RT1
         CLG   R0,=X'0000000000000000'
*MCALL #=  1032 LV= 1          RT1   CCE
         DS    0H
RT1_TEST992      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE992
         LTORG 
RT1_CCE992      DS 0H
*MEXIT #=  1032 LV= 1 RT1
         LG    R0,=X'0000000000000000'
         SLG   R0,=X'0000000000000002'
*MCALL #=  1033 LV= 1          RT1   CC1        NZ,B
         DS    0H
RT1_TEST993      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL993
         LTORG 
RT1_CCL993      DS 0H
*MEXIT #=  1033 LV= 1 RT1
         CLG   R0,=X'FFFFFFFFFFFFFFFE'
*MCALL #=  1034 LV= 1          RT1   CCE
         DS    0H
RT1_TEST994      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE994
         LTORG 
RT1_CCE994      DS 0H
*MEXIT #=  1034 LV= 1 RT1
* E30C MSG
         LG    R0,=FL8'2'
         MSG   R0,=FL8'3'
         CG    R0,=FL8'6'
*MCALL #=  1035 LV= 1          RT1   CCE
         DS    0H
RT1_TEST995      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE995
         LTORG 
RT1_CCE995      DS 0H
*MEXIT #=  1035 LV= 1 RT1
* E30D DSG
         LG    R1,=FL8'13'
         DSG   R0,=FL8'4'
         CLG   R0,=FL8'1'
*MCALL #=  1036 LV= 1          RT1   CCE
         DS    0H
RT1_TEST996      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE996
         LTORG 
RT1_CCE996      DS 0H
*MEXIT #=  1036 LV= 1 RT1
         CLG   R1,=FL8'3'
*MCALL #=  1037 LV= 1          RT1   CCE
         DS    0H
RT1_TEST997      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE997
         LTORG 
RT1_CCE997      DS 0H
*MEXIT #=  1037 LV= 1 RT1
* E30E CVBG
         CVBG  R0,=PL16'800'
         CH    R0,=H'800'
*MCALL #=  1038 LV= 1          RT1   CCE
         DS    0H
RT1_TEST998      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE998
         LTORG 
RT1_CCE998      DS 0H
*MEXIT #=  1038 LV= 1 RT1
         CVDG  R0,PWORK16
         CP  PWORK16,=P'800'
*MCALL #=  1039 LV= 1          RT1 CCE
         DS    0H
RT1_TEST999      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE999
         LTORG 
RT1_CCE999      DS 0H
*MEXIT #=  1039 LV= 1 RT1
         CVBG  R0,=PL16'9223372036854775807'
         CVDG  R0,PWORK16
         CP  PWORK16,=P'9223372036854775807'
*MCALL #=  1040 LV= 1          RT1 CCE
         DS    0H
RT1_TEST1000     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1000
         LTORG 
RT1_CCE1000     DS 0H
*MEXIT #=  1040 LV= 1 RT1
* E30F LRVG
         LRVG  R1,=X'0123456789ABCDEF'
         CLG   R1,=X'EFCDAB8967452301'
*MCALL #=  1041 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1001     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1001
         LTORG 
RT1_CCE1001     DS 0H
*MEXIT #=  1041 LV= 1 RT1
* E312 LT
         LT    R0,=F'1'
*MCALL #=  1042 LV= 1          RT1   CCH
         DS    0H
RT1_TEST1002     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1002
         LTORG 
RT1_CCH1002     DS 0H
*MEXIT #=  1042 LV= 1 RT1
         LT    R0,=F'-1'
*MCALL #=  1043 LV= 1          RT1   CCL
         DS    0H
RT1_TEST1003     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1003
         LTORG 
RT1_CCL1003     DS 0H
*MEXIT #=  1043 LV= 1 RT1
         LT    R0,=F'0'
*MCALL #=  1044 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1004     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1004
         LTORG 
RT1_CCE1004     DS 0H
*MEXIT #=  1044 LV= 1 RT1
* E314 LGF
         LGF    R0,=F'-1'
         STG   R0,PWORK
         CLC   PWORK,=X'FFFFFFFFFFFFFFFF'
* E315 LGH
         LGH    R0,=H'-1'
         STG   R0,PWORK
         CLC   PWORK,=X'FFFFFFFFFFFFFFFF'
* E316 LLGF
         LLGF  R0,=F'-1'
         CLG   R0,=A(0,-1)
*MCALL #=  1045 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1005     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1005
         LTORG 
RT1_CCE1005     DS 0H
*MEXIT #=  1045 LV= 1 RT1
* E317 LLGT
         LLGT  R0,=F'-1'               RPI-160
         CLG   R0,=A(0,X'7FFFFFFF')
*MCALL #=  1046 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1006     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1006
         LTORG 
RT1_CCE1006     DS 0H
*MEXIT #=  1046 LV= 1 RT1
* E31A ALGF
         LG    R0,=FL8'3'
         ALGF  R0,=F'2'
*MCALL #=  1047 LV= 1          RT1   CC1        NZ,NC
         DS    0H
RT1_TEST1007     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1007
         LTORG 
RT1_CCL1007     DS 0H
*MEXIT #=  1047 LV= 1 RT1
         CLG   R0,=FL8'5'
*MCALL #=  1048 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1008     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1008
         LTORG 
RT1_CCE1008     DS 0H
*MEXIT #=  1048 LV= 1 RT1
         LG    R0,=X'8000000000000000'
         ALGF  R0,=X'00000001'
*MCALL #=  1049 LV= 1          RT1   CC1        NZ,NC
         DS    0H
RT1_TEST1009     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1009
         LTORG 
RT1_CCL1009     DS 0H
*MEXIT #=  1049 LV= 1 RT1
         CLG   R0,=X'8000000000000001'
*MCALL #=  1050 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1010     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1010
         LTORG 
RT1_CCE1010     DS 0H
*MEXIT #=  1050 LV= 1 RT1
         LG    R0,=X'FFFFFFFFFFFFFFFF'
         ALGF  R0,=X'00000001'
*MCALL #=  1051 LV= 1          RT1   CC2        Z,C
         DS    0H
RT1_TEST1011     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1011
         LTORG 
RT1_CCH1011     DS 0H
*MEXIT #=  1051 LV= 1 RT1
         CLG   R0,=X'0000000000000000'
*MCALL #=  1052 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1012     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1012
         LTORG 
RT1_CCE1012     DS 0H
*MEXIT #=  1052 LV= 1 RT1
         LG    R0,=X'FFFFFFFFFFFFFFFF'
         ALGF  R0,=X'00000002'
*MCALL #=  1053 LV= 1          RT1   CC3        NZ,C
         DS    0H
RT1_TEST1013     BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC31013
         LTORG 
RT1_CC31013     DS 0H
*MEXIT #=  1053 LV= 1 RT1
         CLG   R0,=X'0000000000000001'
*MCALL #=  1054 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1014     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1014
         LTORG 
RT1_CCE1014     DS 0H
*MEXIT #=  1054 LV= 1 RT1
         LG    R0,=X'0000000000000000'
         ALGF  R0,=X'00000000'
*MCALL #=  1055 LV= 1          RT1   CC0        Z,NC
         DS    0H
RT1_TEST1015     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1015
         LTORG 
RT1_CCE1015     DS 0H
*MEXIT #=  1055 LV= 1 RT1
         CLG   R0,=X'0000000000000000'
*MCALL #=  1056 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1016     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1016
         LTORG 
RT1_CCE1016     DS 0H
*MEXIT #=  1056 LV= 1 RT1
* E31B SLGF
         LG    R0,=X'FFFFFFFFFFFFFFFF'  RPI-879
         SLGF  R0,=X'80000000'          RPI-879
*MCALL #=  1057 LV= 1          RT1   CC3        NZ,NB         RPI-879
         DS    0H
RT1_TEST1017     BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC31017
         LTORG 
RT1_CC31017     DS 0H
*MEXIT #=  1057 LV= 1 RT1
         CLG   R0,=X'FFFFFFFF7FFFFFFF'  RPI-879
*MCALL #=  1058 LV= 1          RT1   CCE                      RPI-879
         DS    0H
RT1_TEST1018     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1018
         LTORG 
RT1_CCE1018     DS 0H
*MEXIT #=  1058 LV= 1 RT1
         LG    R0,=FL8'3'
         SLGF  R0,=F'2'
*MCALL #=  1059 LV= 1          RT1   CC3        NZ,NB
         DS    0H
RT1_TEST1019     BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC31019
         LTORG 
RT1_CC31019     DS 0H
*MEXIT #=  1059 LV= 1 RT1
         CLG   R0,=FL8'1'
*MCALL #=  1060 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1020     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1020
         LTORG 
RT1_CCE1020     DS 0H
*MEXIT #=  1060 LV= 1 RT1
         LG    R0,=X'8000000000000000'
         SLGF  R0,=X'00000001'
*MCALL #=  1061 LV= 1          RT1   CC3        NZ,NB
         DS    0H
RT1_TEST1021     BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC31021
         LTORG 
RT1_CC31021     DS 0H
*MEXIT #=  1061 LV= 1 RT1
         CLG   R0,=X'7FFFFFFFFFFFFFFF'
*MCALL #=  1062 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1022     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1022
         LTORG 
RT1_CCE1022     DS 0H
*MEXIT #=  1062 LV= 1 RT1
         LG    R0,=X'0000000000000000'
         SLGF  R0,=X'00000001'
*MCALL #=  1063 LV= 1          RT1   CC1        NZ,B
         DS    0H
RT1_TEST1023     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1023
         LTORG 
RT1_CCL1023     DS 0H
*MEXIT #=  1063 LV= 1 RT1
         CLG   R0,=X'FFFFFFFFFFFFFFFF'
*MCALL #=  1064 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1024     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1024
         LTORG 
RT1_CCE1024     DS 0H
*MEXIT #=  1064 LV= 1 RT1
         LG    R0,=X'0000000000000001'
         SLG   R0,=X'0000000000000001'
*MCALL #=  1065 LV= 1          RT1   CC2        Z,NB
         DS    0H
RT1_TEST1025     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1025
         LTORG 
RT1_CCH1025     DS 0H
*MEXIT #=  1065 LV= 1 RT1
         CLG   R0,=X'0000000000000000'
*MCALL #=  1066 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1026     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1026
         LTORG 
RT1_CCE1026     DS 0H
*MEXIT #=  1066 LV= 1 RT1
         LG    R0,=X'0000000000000000'
         SLGF  R0,=X'00000002'
*MCALL #=  1067 LV= 1          RT1   CC1        NZ,B
         DS    0H
RT1_TEST1027     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1027
         LTORG 
RT1_CCL1027     DS 0H
*MEXIT #=  1067 LV= 1 RT1
         CLG   R0,=X'FFFFFFFFFFFFFFFE'
*MCALL #=  1068 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1028     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1028
         LTORG 
RT1_CCE1028     DS 0H
*MEXIT #=  1068 LV= 1 RT1
* E318 AGF
         LG    R0,=FL8'1'
         AGF   R0,=F'3'
*MCALL #=  1069 LV= 1          RT1   CCH
         DS    0H
RT1_TEST1029     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1029
         LTORG 
RT1_CCH1029     DS 0H
*MEXIT #=  1069 LV= 1 RT1
         CG    R0,=FL8'4'
*MCALL #=  1070 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1030     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1030
         LTORG 
RT1_CCE1030     DS 0H
*MEXIT #=  1070 LV= 1 RT1
* E319 SGF
         LG    R0,=FL8'1'
         SGF   R0,=F'3'
*MCALL #=  1071 LV= 1          RT1   CCL
         DS    0H
RT1_TEST1031     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1031
         LTORG 
RT1_CCL1031     DS 0H
*MEXIT #=  1071 LV= 1 RT1
         CG    R0,=FL8'-2'
*MCALL #=  1072 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1032     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1032
         LTORG 
RT1_CCE1032     DS 0H
*MEXIT #=  1072 LV= 1 RT1
* E31C MSGF
         LG    R0,=FL8'2'
         MSGF  R0,=F'3'
         CG    R0,=FL8'6'
*MCALL #=  1073 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1033     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1033
         LTORG 
RT1_CCE1033     DS 0H
*MEXIT #=  1073 LV= 1 RT1
* E31D DSGF
         LG    R1,=FL8'13'
         DSGF  R0,=F'3'
         CG    R0,=FL8'1'
*MCALL #=  1074 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1034     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1034
         LTORG 
RT1_CCE1034     DS 0H
*MEXIT #=  1074 LV= 1 RT1
         CG    R1,=FL8'4'
*MCALL #=  1075 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1035     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1035
         LTORG 
RT1_CCE1035     DS 0H
*MEXIT #=  1075 LV= 1 RT1
* E31E LRV                     RPI173
         SR    R0,R0
         LRV   R0,=X'01020304'
         CL    R0,=A(X'04030201')
*MCALL #=  1076 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1036     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1036
         LTORG 
RT1_CCE1036     DS 0H
*MEXIT #=  1076 LV= 1 RT1
* E31F LRVH
         SR    R0,R0
         LRVH  R0,=X'0102'
         CL    R0,=A(X'0201')
*MCALL #=  1077 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1037     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1037
         LTORG 
RT1_CCE1037     DS 0H
*MEXIT #=  1077 LV= 1 RT1
* E320 CG
         LG    R1,=FL8'1'
         CG    R1,=FL8'1'
*MCALL #=  1078 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1038     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1038
         LTORG 
RT1_CCE1038     DS 0H
*MEXIT #=  1078 LV= 1 RT1
         LG    R1,=FL8'-1'
         CG    R1,=FL8'1'
*MCALL #=  1079 LV= 1          RT1   CCL
         DS    0H
RT1_TEST1039     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1039
         LTORG 
RT1_CCL1039     DS 0H
*MEXIT #=  1079 LV= 1 RT1
         LG    R1,=FL8'1'
         CG    R1,=FL8'-1'
*MCALL #=  1080 LV= 1          RT1   CCH
         DS    0H
RT1_TEST1040     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1040
         LTORG 
RT1_CCH1040     DS 0H
*MEXIT #=  1080 LV= 1 RT1
* E321 CLG
         LG    R1,=C'ABCDEFGH'
         CLG   R1,=C'ABCDEFGH'
*MCALL #=  1081 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1041     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1041
         LTORG 
RT1_CCE1041     DS 0H
*MEXIT #=  1081 LV= 1 RT1
         LG    R1,=C'ABCDEFGI'
         CLG   R1,=C'ABCDEFGH'
*MCALL #=  1082 LV= 1          RT1   CCH
         DS    0H
RT1_TEST1042     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1042
         LTORG 
RT1_CCH1042     DS 0H
*MEXIT #=  1082 LV= 1 RT1
         LG    R1,=C'ABCDEFGH'
         CLG   R1,=C'ABCDFFGH'
*MCALL #=  1083 LV= 1          RT1   CCL
         DS    0H
RT1_TEST1043     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1043
         LTORG 
RT1_CCL1043     DS 0H
*MEXIT #=  1083 LV= 1 RT1
* E324 STG
         LG    R0,=X'0123456789ABCDEF'
         STG   R0,PWORK
         CLC   PWORK,=X'0123456789ABCDEF'
* E326 CVDY
         CVBY  R0,=PL8'2147483647'
         CVDY  R0,PWORK
         CP  PWORK,=P'2147483647'
*MCALL #=  1084 LV= 1          RT1 CCE
         DS    0H
RT1_TEST1044     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1044
         LTORG 
RT1_CCE1044     DS 0H
*MEXIT #=  1084 LV= 1 RT1
* E32E CVDG
         CVBG  R0,=PL16'9223372036854775807'
         CVDG  R0,PWORK16
         CP  PWORK16,=P'9223372036854775807'
*MCALL #=  1085 LV= 1          RT1 CCE
         DS    0H
RT1_TEST1045     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1045
         LTORG 
RT1_CCE1045     DS 0H
*MEXIT #=  1085 LV= 1 RT1
* E32F STRVG
         LG    R1,=X'0123456789ABCDEF'
         STRVG R1,PWORK
         CLC   PWORK,=X'EFCDAB8967452301'
*MCALL #=  1086 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1046     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1046
         LTORG 
RT1_CCE1046     DS 0H
*MEXIT #=  1086 LV= 1 RT1
* E330 CGF
         LG    R1,=FL8'1'
         CGF   R1,=F'1'
*MCALL #=  1087 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1047     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1047
         LTORG 
RT1_CCE1047     DS 0H
*MEXIT #=  1087 LV= 1 RT1
         LG    R1,=FL8'-1'
         CGF   R1,=F'1'
*MCALL #=  1088 LV= 1          RT1   CCL
         DS    0H
RT1_TEST1048     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1048
         LTORG 
RT1_CCL1048     DS 0H
*MEXIT #=  1088 LV= 1 RT1
         LG    R1,=FL8'1'
         CGF   R1,=F'-1'
*MCALL #=  1089 LV= 1          RT1   CCH
         DS    0H
RT1_TEST1049     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1049
         LTORG 
RT1_CCH1049     DS 0H
*MEXIT #=  1089 LV= 1 RT1
* E331 CLGF
         LG    R1,=XL8'FFFFFFFF'
         CLGF  R1,=X'FFFFFFFF'
*MCALL #=  1090 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1050     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1050
         LTORG 
RT1_CCE1050     DS 0H
*MEXIT #=  1090 LV= 1 RT1
         LG    R1,=XL8'80000001'
         CLGF  R1,=X'80000000'
*MCALL #=  1091 LV= 1          RT1   CCH
         DS    0H
RT1_TEST1051     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1051
         LTORG 
RT1_CCH1051     DS 0H
*MEXIT #=  1091 LV= 1 RT1
         LG    R1,=XL8'80000001'
         CLG   R1,=X'80000002'
*MCALL #=  1092 LV= 1          RT1   CCL
         DS    0H
RT1_TEST1052     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1052
         LTORG 
RT1_CCL1052     DS 0H
*MEXIT #=  1092 LV= 1 RT1
* E334 CGH                    RPI-875
         LG    R1,=FL8'1'
         CGH   R1,=H'1'
*MCALL #=  1093 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1053     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1053
         LTORG 
RT1_CCE1053     DS 0H
*MEXIT #=  1093 LV= 1 RT1
         LG    R1,=FL8'-1'
         CGH   R1,=H'1'
*MCALL #=  1094 LV= 1          RT1   CCL
         DS    0H
RT1_TEST1054     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1054
         LTORG 
RT1_CCL1054     DS 0H
*MEXIT #=  1094 LV= 1 RT1
         LG    R1,=FL8'1'
         CGH   R1,=H'-1'
*MCALL #=  1095 LV= 1          RT1   CCH
         DS    0H
RT1_TEST1055     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1055
         LTORG 
RT1_CCH1055     DS 0H
*MEXIT #=  1095 LV= 1 RT1
* E33E STRV
         L     R1,=X'01234567'
         STRV  R1,PWORK
         CLC   PWORK(4),=X'67452301'
*MCALL #=  1096 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1056     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1056
         LTORG 
RT1_CCE1056     DS 0H
*MEXIT #=  1096 LV= 1 RT1
* E332 LTGF              RPI-875
         LTGF  R0,=f'1'
*MCALL #=  1097 LV= 1          RT1   CCH
         DS    0H
RT1_TEST1057     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1057
         LTORG 
RT1_CCH1057     DS 0H
*MEXIT #=  1097 LV= 1 RT1
         LTGF  R0,=f'-1'
*MCALL #=  1098 LV= 1          RT1   CCL
         DS    0H
RT1_TEST1058     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1058
         LTORG 
RT1_CCL1058     DS 0H
*MEXIT #=  1098 LV= 1 RT1
         LTGF  R0,=f'0'
*MCALL #=  1099 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1059     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1059
         LTORG 
RT1_CCE1059     DS 0H
*MEXIT #=  1099 LV= 1 RT1
* E33F STRVH
         L     R1,=X'01234567'
         STRVH R1,PWORK
         CLC   PWORK(2),=X'6745'
*MCALL #=  1100 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1060     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1060
         LTORG 
RT1_CCE1060     DS 0H
*MEXIT #=  1100 LV= 1 RT1
* E346 BCTG
         LG    R1,=FL8'10'
         SR    R2,R2
BCTG1    LA    R2,1(R2)
         BCTG  R1,BCTG1
         CLG   R1,=FL8'0'
*MCALL #=  1101 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1061     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1061
         LTORG 
RT1_CCE1061     DS 0H
*MEXIT #=  1101 LV= 1 RT1
         CL    R2,=F'10'
*MCALL #=  1102 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1062     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1062
         LTORG 
RT1_CCE1062     DS 0H
*MEXIT #=  1102 LV= 1 RT1
* E350 STY
         LA    R1,1234
         STY    R1,WORD
*MCALL #=  1103 LV= 1          RT1   CCE,WORD,=F'1234'
         DS    0H
         CLC   WORD,=F'1234'
RT1_TEST1063     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1063
         LTORG 
RT1_CCE1063     DS 0H
*MEXIT #=  1103 LV= 1 RT1
* E351 MSY
         L     R0,=F'2'
         MSY   R0,=F'3'
         C     R0,=F'6'
*MCALL #=  1104 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1064     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1064
         LTORG 
RT1_CCE1064     DS 0H
*MEXIT #=  1104 LV= 1 RT1
* E354 NY
         L     R0,=X'12345678'
         NY    R0,=X'1335577F'
*MCALL #=  1105 LV= 1          RT1   CCL
         DS    0H
RT1_TEST1065     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1065
         LTORG 
RT1_CCL1065     DS 0H
*MEXIT #=  1105 LV= 1 RT1
         CL    R0,=X'12345678'
*MCALL #=  1106 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1066     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1066
         LTORG 
RT1_CCE1066     DS 0H
*MEXIT #=  1106 LV= 1 RT1
* E355 CLY
         LA    R1,1
         CLY   R1,=F'1'
*MCALL #=  1107 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1067     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1067
         LTORG 
RT1_CCE1067     DS 0H
*MEXIT #=  1107 LV= 1 RT1
         LA    R1,0
         CLY   R1,=F'1'
*MCALL #=  1108 LV= 1          RT1   CCL
         DS    0H
RT1_TEST1068     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1068
         LTORG 
RT1_CCL1068     DS 0H
*MEXIT #=  1108 LV= 1 RT1
         LA    R1,2
         CLY   R1,=F'1'
*MCALL #=  1109 LV= 1          RT1   CCH
         DS    0H
RT1_TEST1069     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1069
         LTORG 
RT1_CCH1069     DS 0H
*MEXIT #=  1109 LV= 1 RT1
         L     R1,=F'-1'
         CLY   R1,=F'1'
*MCALL #=  1110 LV= 1          RT1   CCH
         DS    0H
RT1_TEST1070     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1070
         LTORG 
RT1_CCH1070     DS 0H
*MEXIT #=  1110 LV= 1 RT1
         L     R1,=F'1'
         CLY   R1,=F'-1'
*MCALL #=  1111 LV= 1          RT1   CCL
         DS    0H
RT1_TEST1071     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1071
         LTORG 
RT1_CCL1071     DS 0H
*MEXIT #=  1111 LV= 1 RT1
* E356 OY
         L     R0,=X'12345678'
         OY    R0,=X'11315177'
*MCALL #=  1112 LV= 1          RT1   CCL
         DS    0H
RT1_TEST1072     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1072
         LTORG 
RT1_CCL1072     DS 0H
*MEXIT #=  1112 LV= 1 RT1
         CL    R0,=X'1335577F'
*MCALL #=  1113 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1073     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1073
         LTORG 
RT1_CCE1073     DS 0H
*MEXIT #=  1113 LV= 1 RT1
* E357 XY
         L     R0,=X'12345678'
         XY    R0,=X'11315177'
*MCALL #=  1114 LV= 1          RT1   CCL
         DS    0H
RT1_TEST1074     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1074
         LTORG 
RT1_CCL1074     DS 0H
*MEXIT #=  1114 LV= 1 RT1
         CL    R0,=X'0305070F'
*MCALL #=  1115 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1075     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1075
         LTORG 
RT1_CCE1075     DS 0H
*MEXIT #=  1115 LV= 1 RT1
* E358 LY
         LY    R1,=F'12345'
         CL    R1,=A(12345)
*MCALL #=  1116 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1076     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1076
         LTORG 
RT1_CCE1076     DS 0H
*MEXIT #=  1116 LV= 1 RT1
* E359 CY
         LA    R1,1
         CY    R1,=F'1'
*MCALL #=  1117 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1077     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1077
         LTORG 
RT1_CCE1077     DS 0H
*MEXIT #=  1117 LV= 1 RT1
         LA    R1,0
         CY    R1,=F'1'
*MCALL #=  1118 LV= 1          RT1   CCL
         DS    0H
RT1_TEST1078     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1078
         LTORG 
RT1_CCL1078     DS 0H
*MEXIT #=  1118 LV= 1 RT1
         LA    R1,2
         CY    R1,=F'1'
*MCALL #=  1119 LV= 1          RT1   CCH
         DS    0H
RT1_TEST1079     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1079
         LTORG 
RT1_CCH1079     DS 0H
*MEXIT #=  1119 LV= 1 RT1
         L     R1,=F'-1'
         CY    R1,=F'1'
*MCALL #=  1120 LV= 1          RT1   CCL
         DS    0H
RT1_TEST1080     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1080
         LTORG 
RT1_CCL1080     DS 0H
*MEXIT #=  1120 LV= 1 RT1
         L     R1,=F'1'
         CY    R1,=F'-1'
*MCALL #=  1121 LV= 1          RT1   CCH
         DS    0H
RT1_TEST1081     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1081
         LTORG 
RT1_CCH1081     DS 0H
*MEXIT #=  1121 LV= 1 RT1
* E35A AY
         L     R0,=F'1'
         AY    R0,=F'3'
*MCALL #=  1122 LV= 1          RT1   CCH
         DS    0H
RT1_TEST1082     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1082
         LTORG 
RT1_CCH1082     DS 0H
*MEXIT #=  1122 LV= 1 RT1
         C     R0,=F'4'
*MCALL #=  1123 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1083     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1083
         LTORG 
RT1_CCE1083     DS 0H
*MEXIT #=  1123 LV= 1 RT1
* E35B SY
         L     R0,=F'1'
         SY    R0,=F'3'
*MCALL #=  1124 LV= 1          RT1   CCL
         DS    0H
RT1_TEST1084     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1084
         LTORG 
RT1_CCL1084     DS 0H
*MEXIT #=  1124 LV= 1 RT1
         C     R0,=F'-2'
*MCALL #=  1125 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1085     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1085
         LTORG 
RT1_CCE1085     DS 0H
*MEXIT #=  1125 LV= 1 RT1
* E35C MFY                   RPI-875
         L     R0,=C'JUNK'
         L     R1,=F'2'
         MFY   R0,=F'3'
         C     R0,=F'0'
*MCALL #=  1126 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1086     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1086
         LTORG 
RT1_CCE1086     DS 0H
*MEXIT #=  1126 LV= 1 RT1
         C     R1,=F'6'
*MCALL #=  1127 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1087     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1087
         LTORG 
RT1_CCE1087     DS 0H
*MEXIT #=  1127 LV= 1 RT1
* E35E ALY                        RPI-875
         L     R0,=F'3'
         ALY   R0,=F'2'
*MCALL #=  1128 LV= 1          RT1   CC1        NZ,NC
         DS    0H
RT1_TEST1088     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1088
         LTORG 
RT1_CCL1088     DS 0H
*MEXIT #=  1128 LV= 1 RT1
         CL    R0,=F'5'
*MCALL #=  1129 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1089     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1089
         LTORG 
RT1_CCE1089     DS 0H
*MEXIT #=  1129 LV= 1 RT1
         L     R0,=X'80000000'
         ALY   R0,=X'00000001'
*MCALL #=  1130 LV= 1          RT1   CC1        NZ,NC
         DS    0H
RT1_TEST1090     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1090
         LTORG 
RT1_CCL1090     DS 0H
*MEXIT #=  1130 LV= 1 RT1
         CL    R0,=X'80000001'
*MCALL #=  1131 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1091     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1091
         LTORG 
RT1_CCE1091     DS 0H
*MEXIT #=  1131 LV= 1 RT1
         L     R0,=X'FFFFFFFF'
         ALY   R0,=X'00000001'
*MCALL #=  1132 LV= 1          RT1   CC2        Z,C
         DS    0H
RT1_TEST1092     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1092
         LTORG 
RT1_CCH1092     DS 0H
*MEXIT #=  1132 LV= 1 RT1
         CL    R0,=X'00000000'
*MCALL #=  1133 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1093     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1093
         LTORG 
RT1_CCE1093     DS 0H
*MEXIT #=  1133 LV= 1 RT1
         L     R0,=X'FFFFFFFF'
         ALY   R0,=X'00000002'
*MCALL #=  1134 LV= 1          RT1   CC3        NZ,C
         DS    0H
RT1_TEST1094     BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC31094
         LTORG 
RT1_CC31094     DS 0H
*MEXIT #=  1134 LV= 1 RT1
         CL    R0,=X'00000001'
*MCALL #=  1135 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1095     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1095
         LTORG 
RT1_CCE1095     DS 0H
*MEXIT #=  1135 LV= 1 RT1
         L     R0,=X'FFFFFFFF'  RPI-376
         ALY   R0,=X'FFFFFFFF'
*MCALL #=  1136 LV= 1          RT1   CC3        NZ,C
         DS    0H
RT1_TEST1096     BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC31096
         LTORG 
RT1_CC31096     DS 0H
*MEXIT #=  1136 LV= 1 RT1
         CL    R0,=X'FFFFFFFE'
*MCALL #=  1137 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1097     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1097
         LTORG 
RT1_CCE1097     DS 0H
*MEXIT #=  1137 LV= 1 RT1
         L     R0,=X'00000000'
         ALY   R0,=X'00000000'
*MCALL #=  1138 LV= 1          RT1   CC0        Z,NC
         DS    0H
RT1_TEST1098     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1098
         LTORG 
RT1_CCE1098     DS 0H
*MEXIT #=  1138 LV= 1 RT1
         CL    R0,=X'00000000'
*MCALL #=  1139 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1099     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1099
         LTORG 
RT1_CCE1099     DS 0H
*MEXIT #=  1139 LV= 1 RT1
* E35F SLY
         L     R0,=X'FFFFFFFF'  RPI-879
         SLY   R0,=X'80000000'  RPI-879
*MCALL #=  1140 LV= 1          RT1   CC3        NZ,NB RPI-879
         DS    0H
RT1_TEST1100     BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC31100
         LTORG 
RT1_CC31100     DS 0H
*MEXIT #=  1140 LV= 1 RT1
         CL    R0,=X'7FFFFFFF'  RPI-879
*MCALL #=  1141 LV= 1          RT1   CCE              RPI-879
         DS    0H
RT1_TEST1101     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1101
         LTORG 
RT1_CCE1101     DS 0H
*MEXIT #=  1141 LV= 1 RT1
         L     R0,=X'80000000'  RPI-831
         SLY    R0,=X'A0000000'
*MCALL #=  1142 LV= 1          RT1   CC1        NZ,B
         DS    0H
RT1_TEST1102     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1102
         LTORG 
RT1_CCL1102     DS 0H
*MEXIT #=  1142 LV= 1 RT1
         CL    R0,=X'E0000000'
*MCALL #=  1143 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1103     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1103
         LTORG 
RT1_CCE1103     DS 0H
*MEXIT #=  1143 LV= 1 RT1
         L     R0,=F'3'
         SLY   R0,=F'2'
*MCALL #=  1144 LV= 1          RT1   CC3        NZ,NB
         DS    0H
RT1_TEST1104     BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC31104
         LTORG 
RT1_CC31104     DS 0H
*MEXIT #=  1144 LV= 1 RT1
         CL    R0,=F'1'
*MCALL #=  1145 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1105     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1105
         LTORG 
RT1_CCE1105     DS 0H
*MEXIT #=  1145 LV= 1 RT1
         L     R0,=X'80000000'
         SLY   R0,=X'00000001'
*MCALL #=  1146 LV= 1          RT1   CC3        NZ,NB
         DS    0H
RT1_TEST1106     BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC31106
         LTORG 
RT1_CC31106     DS 0H
*MEXIT #=  1146 LV= 1 RT1
         CL    R0,=X'7FFFFFFF'
*MCALL #=  1147 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1107     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1107
         LTORG 
RT1_CCE1107     DS 0H
*MEXIT #=  1147 LV= 1 RT1
         L     R0,=X'00000000'
         SLY   R0,=X'00000001'
*MCALL #=  1148 LV= 1          RT1   CC1        NZ,B
         DS    0H
RT1_TEST1108     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1108
         LTORG 
RT1_CCL1108     DS 0H
*MEXIT #=  1148 LV= 1 RT1
         CL    R0,=X'FFFFFFFF'
*MCALL #=  1149 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1109     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1109
         LTORG 
RT1_CCE1109     DS 0H
*MEXIT #=  1149 LV= 1 RT1
         L     R0,=X'00000001'
         SLY   R0,=X'00000001'
*MCALL #=  1150 LV= 1          RT1   CC2        Z,NB
         DS    0H
RT1_TEST1110     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1110
         LTORG 
RT1_CCH1110     DS 0H
*MEXIT #=  1150 LV= 1 RT1
         CL    R0,=X'00000000'
*MCALL #=  1151 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1111     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1111
         LTORG 
RT1_CCE1111     DS 0H
*MEXIT #=  1151 LV= 1 RT1
         L     R0,=X'00000000'
         SLY   R0,=X'00000002'
*MCALL #=  1152 LV= 1          RT1   CC1        NZ,B
         DS    0H
RT1_TEST1112     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1112
         LTORG 
RT1_CCL1112     DS 0H
*MEXIT #=  1152 LV= 1 RT1
         CL    R0,=X'FFFFFFFE'
*MCALL #=  1153 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1113     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1113
         LTORG 
RT1_CCE1113     DS 0H
*MEXIT #=  1153 LV= 1 RT1
* E370 STHY
         L     R0,=F'1'
         STHY  R0,WORD
         CLC   WORD(2),=H'1'
*MCALL #=  1154 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1114     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1114
         LTORG 
RT1_CCE1114     DS 0H
*MEXIT #=  1154 LV= 1 RT1
         L     R0,=F'-1'
         STHY  R0,WORD
         CLC   WORD(2),=H'-1'
*MCALL #=  1155 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1115     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1115
         LTORG 
RT1_CCE1115     DS 0H
*MEXIT #=  1155 LV= 1 RT1
* E371 LAY
         LAY   R1,*+6
         CL    R1,=A(*)
*MCALL #=  1156 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1116     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1116
         LTORG 
RT1_CCE1116     DS 0H
*MEXIT #=  1156 LV= 1 RT1
* E372 STCY
         LA    R0,X'FF'
         STCY  R0,BYTE
         CLI   BYTE,X'FF'
*MCALL #=  1157 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1117     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1117
         LTORG 
RT1_CCE1117     DS 0H
*MEXIT #=  1157 LV= 1 RT1
* E373 ICY
         SR    R0,R0
         ICY   R0,=C'A'
         CL    R0,=A(C'A')
*MCALL #=  1158 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1118     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1118
         LTORG 
RT1_CCE1118     DS 0H
*MEXIT #=  1158 LV= 1 RT1
* E376 LB
         LB    R0,=FL1'1'
         CL    R0,=F'1'
*MCALL #=  1159 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1119     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1119
         LTORG 
RT1_CCE1119     DS 0H
*MEXIT #=  1159 LV= 1 RT1
         LB    R0,=FL1'-1'
         CL    R0,=F'-1'
*MCALL #=  1160 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1120     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1120
         LTORG 
RT1_CCE1120     DS 0H
*MEXIT #=  1160 LV= 1 RT1
* E377 LGB
         LGB   R0,=FL1'1'
         CLG   R0,=FL8'1'
*MCALL #=  1161 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1121     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1121
         LTORG 
RT1_CCE1121     DS 0H
*MEXIT #=  1161 LV= 1 RT1
         LGB   R0,=FL1'-1'
         CLG   R0,=FL8'-1'
*MCALL #=  1162 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1122     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1122
         LTORG 
RT1_CCE1122     DS 0H
*MEXIT #=  1162 LV= 1 RT1
* E378 LHY
         LHY   R0,=H'-2'
         CL    R0,=F'-2'
*MCALL #=  1163 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1123     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1123
         LTORG 
RT1_CCE1123     DS 0H
*MEXIT #=  1163 LV= 1 RT1
* E379 CHY
         LH    R0,=H'1'
         CHY   R0,=H'1'
*MCALL #=  1164 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1124     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1124
         LTORG 
RT1_CCE1124     DS 0H
*MEXIT #=  1164 LV= 1 RT1
         LH    R0,=H'-1'
         CHY   R0,=H'1'
*MCALL #=  1165 LV= 1          RT1   CCL
         DS    0H
RT1_TEST1125     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1125
         LTORG 
RT1_CCL1125     DS 0H
*MEXIT #=  1165 LV= 1 RT1
         LH    R0,=H'1'
         CHY   R0,=H'-1'
*MCALL #=  1166 LV= 1          RT1   CCH
         DS    0H
RT1_TEST1126     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1126
         LTORG 
RT1_CCH1126     DS 0H
*MEXIT #=  1166 LV= 1 RT1
* E37A AHY
         LH    R0,=H'1'
         AHY   R0,=H'3'
*MCALL #=  1167 LV= 1          RT1   CCH
         DS    0H
RT1_TEST1127     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1127
         LTORG 
RT1_CCH1127     DS 0H
*MEXIT #=  1167 LV= 1 RT1
         CH    R0,=H'4'
*MCALL #=  1168 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1128     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1128
         LTORG 
RT1_CCE1128     DS 0H
*MEXIT #=  1168 LV= 1 RT1
* E37B SHY
         LH    R0,=H'1'
         SHY   R0,=H'3'
*MCALL #=  1169 LV= 1          RT1   CCL
         DS    0H
RT1_TEST1129     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1129
         LTORG 
RT1_CCL1129     DS 0H
*MEXIT #=  1169 LV= 1 RT1
         CH    R0,=H'-2'
*MCALL #=  1170 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1130     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1130
         LTORG 
RT1_CCE1130     DS 0H
*MEXIT #=  1170 LV= 1 RT1
* E37C MHY                 RPI-875
         LH    R0,=H'2'
         MHY   R0,=H'3'
         CH    R0,=H'6'
*MCALL #=  1171 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1131     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1131
         LTORG 
RT1_CCE1131     DS 0H
*MEXIT #=  1171 LV= 1 RT1
* E380 NG
         LG    R0,=X'0123456789ABCDEF'
         NG    R0,=X'0133557789ABCDFF'
*MCALL #=  1172 LV= 1          RT1   CCL
         DS    0H
RT1_TEST1132     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1132
         LTORG 
RT1_CCL1132     DS 0H
*MEXIT #=  1172 LV= 1 RT1
         CLG   R0,=X'0123456789ABCDEF'
*MCALL #=  1173 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1133     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1133
         LTORG 
RT1_CCE1133     DS 0H
*MEXIT #=  1173 LV= 1 RT1
* E381 OG
         LG    R0,=X'123456789ABCDEF'
         OG    R0,=X'113151779ABCDFF'
*MCALL #=  1174 LV= 1          RT1   CCL
         DS    0H
RT1_TEST1134     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1134
         LTORG 
RT1_CCL1134     DS 0H
*MEXIT #=  1174 LV= 1 RT1
         CLG   R0,=X'1335577F9ABCDFF'
*MCALL #=  1175 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1135     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1135
         LTORG 
RT1_CCE1135     DS 0H
*MEXIT #=  1175 LV= 1 RT1
* E382 XG
         LG    R0,=X'123456789ABCDE8'
         XG    R0,=X'113151779ABCDE7'
*MCALL #=  1176 LV= 1          RT1   CCL
         DS    0H
RT1_TEST1136     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1136
         LTORG 
RT1_CCL1136     DS 0H
*MEXIT #=  1176 LV= 1 RT1
         CLG   R0,=X'0305070F000000F'
*MCALL #=  1177 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1137     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1137
         LTORG 
RT1_CCE1137     DS 0H
*MEXIT #=  1177 LV= 1 RT1
* E386 MLG
         LG    R1,=FL8'3'
         MLG   R0,=FL8'2'
         CLG   R0,=FL8'0'
*MCALL #=  1178 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1138     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1138
         LTORG 
RT1_CCE1138     DS 0H
*MEXIT #=  1178 LV= 1 RT1
         CLG   R1,=FL8'6'
*MCALL #=  1179 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1139     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1139
         LTORG 
RT1_CCE1139     DS 0H
*MEXIT #=  1179 LV= 1 RT1
         LG     R1,=X'8000000000000000'
         MLG    R0,=X'8000000000000000'
         CLG   R0,=X'4000000000000000'
*MCALL #=  1180 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1140     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1140
         LTORG 
RT1_CCE1140     DS 0H
*MEXIT #=  1180 LV= 1 RT1
         CLG   R1,=X'0000000000000000'
*MCALL #=  1181 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1141     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1141
         LTORG 
RT1_CCE1141     DS 0H
*MEXIT #=  1181 LV= 1 RT1
* E387 DLG
         LG    R0,=FL8'0'
         LG    R1,=FL8'13'
         DLG   R0,=FL8'4'
         CLG   R0,=FL8'1'
*MCALL #=  1182 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1142     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1142
         LTORG 
RT1_CCE1142     DS 0H
*MEXIT #=  1182 LV= 1 RT1
         CLG   R1,=FL8'3'
*MCALL #=  1183 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1143     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1143
         LTORG 
RT1_CCE1143     DS 0H
*MEXIT #=  1183 LV= 1 RT1
         LG    R0,=X'4000000000000000'
         LG    R1,=FL8'2'
         DLG   R0,=X'8000000000000000'
         CLG   R0,=FL8'2'
*MCALL #=  1184 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1144     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1144
         LTORG 
RT1_CCE1144     DS 0H
*MEXIT #=  1184 LV= 1 RT1
         CLG   R1,=X'8000000000000000'
*MCALL #=  1185 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1145     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1145
         LTORG 
RT1_CCE1145     DS 0H
*MEXIT #=  1185 LV= 1 RT1
* E388 ALCG
         L     R0,=X'FFFFFFFF'
         L     R2,=X'00000001'
         ALR   R0,R2      Z,C
         LG    R0,=FL8'3'
         ALCG  R0,=FL8'2'
*MCALL #=  1186 LV= 1          RT1   CC1        NZ,NC
         DS    0H
RT1_TEST1146     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1146
         LTORG 
RT1_CCL1146     DS 0H
*MEXIT #=  1186 LV= 1 RT1
         CLG   R0,=FL8'6'
*MCALL #=  1187 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1147     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1147
         LTORG 
RT1_CCE1147     DS 0H
*MEXIT #=  1187 LV= 1 RT1
         L     R0,=X'FFFFFFFF'
         L     R2,=X'00000002'
         ALR   R0,R2      NZ,C
         LG    R0,=X'8000000000000000'
         ALCG  R0,=X'0000000000000001'
*MCALL #=  1188 LV= 1          RT1   CC1        NZ,NC
         DS    0H
RT1_TEST1148     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1148
         LTORG 
RT1_CCL1148     DS 0H
*MEXIT #=  1188 LV= 1 RT1
         CLG   R0,=X'8000000000000002'
*MCALL #=  1189 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1149     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1149
         LTORG 
RT1_CCE1149     DS 0H
*MEXIT #=  1189 LV= 1 RT1
         L     R0,=F'3'
         AL    R0,=F'2'   NZ,NC
         LG    R0,=X'FFFFFFFFFFFFFFFF'
         ALCG  R0,=X'0000000000000001'
*MCALL #=  1190 LV= 1          RT1   CC2        Z,C
         DS    0H
RT1_TEST1150     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1150
         LTORG 
RT1_CCH1150     DS 0H
*MEXIT #=  1190 LV= 1 RT1
         CLG   R0,=X'0000000000000000'
*MCALL #=  1191 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1151     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1151
         LTORG 
RT1_CCE1151     DS 0H
*MEXIT #=  1191 LV= 1 RT1
         L     R0,=F'3'
         AL    R0,=F'2'   NZ,NC
         LG    R0,=X'0000000000000000'
         ALCG  R0,=X'0000000000000000'
*MCALL #=  1192 LV= 1          RT1   CC0        Z,NC
         DS    0H
RT1_TEST1152     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1152
         LTORG 
RT1_CCE1152     DS 0H
*MEXIT #=  1192 LV= 1 RT1
         L     R0,=F'3'
         AL    R0,=F'2'   NZ,NC
         LG    R0,=X'FFFFFFFFFFFFFFFF'
         ALCG  R0,=X'0000000000000002'
*MCALL #=  1193 LV= 1          RT1   CC3        NZ,C
         DS    0H
RT1_TEST1153     BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC31153
         LTORG 
RT1_CC31153     DS 0H
*MEXIT #=  1193 LV= 1 RT1
         CLG   R0,=X'0000000000000001'
*MCALL #=  1194 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1154     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1154
         LTORG 
RT1_CCE1154     DS 0H
*MEXIT #=  1194 LV= 1 RT1
         L     R0,=F'3'
         AL    R0,=F'2'   NZ,NC
         LG    R0,=X'FFFFFFFFFFFFFFFF'
         ALCG  R0,=X'FFFFFFFFFFFFFFFF'
*MCALL #=  1195 LV= 1          RT1   CC3        NZ,C
         DS    0H
RT1_TEST1155     BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC31155
         LTORG 
RT1_CC31155     DS 0H
*MEXIT #=  1195 LV= 1 RT1
         CLG   R0,=X'FFFFFFFFFFFFFFFE'
*MCALL #=  1196 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1156     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1156
         LTORG 
RT1_CCE1156     DS 0H
*MEXIT #=  1196 LV= 1 RT1
         L     R0,=F'3'
         AL    R0,=F'2'   NZ,NC
         LG    R0,=X'0000000000000000'
         ALCG  R0,=X'0000000000000000'
*MCALL #=  1197 LV= 1          RT1   CC0        Z,NC
         DS    0H
RT1_TEST1157     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1157
         LTORG 
RT1_CCE1157     DS 0H
*MEXIT #=  1197 LV= 1 RT1
         CLG   R0,=X'0000000000000000'
*MCALL #=  1198 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1158     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1158
         LTORG 
RT1_CCE1158     DS 0H
*MEXIT #=  1198 LV= 1 RT1
         LG    R0,=FL8'-1'
         ALG   R0,=FL8'2'          CC3 NZ,C
         ALCG  R0,=FL8'1'
*MCALL #=  1199 LV= 1          RT1   CC1
         DS    0H
RT1_TEST1159     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1159
         LTORG 
RT1_CCL1159     DS 0H
*MEXIT #=  1199 LV= 1 RT1
         CLG   R0,=FL8'3'
*MCALL #=  1200 LV= 1          RT1   CC0
         DS    0H
RT1_TEST1160     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1160
         LTORG 
RT1_CCE1160     DS 0H
*MEXIT #=  1200 LV= 1 RT1
         SGR   R0,R0               FORCE CC0 Z,NC
         ALCG  R0,=FL8'1'          RPI174 TEST < CC0
*MCALL #=  1201 LV= 1          RT1   CC1                 NZ,NC
         DS    0H
RT1_TEST1161     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1161
         LTORG 
RT1_CCL1161     DS 0H
*MEXIT #=  1201 LV= 1 RT1
         CLG   R0,=FL8'1'
*MCALL #=  1202 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1162     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1162
         LTORG 
RT1_CCE1162     DS 0H
*MEXIT #=  1202 LV= 1 RT1
* E389 SLBG
         CLI   =C'A',C'B' CC1= NZ,B
         LG    R0,=FL8'4'
         SLBG  R0,=FL8'2'
*MCALL #=  1203 LV= 1          RT1   CC3        NZ,NB
         DS    0H
RT1_TEST1163     BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC31163
         LTORG 
RT1_CC31163     DS 0H
*MEXIT #=  1203 LV= 1 RT1
         CLG   R0,=FL8'1'
*MCALL #=  1204 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1164     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1164
         LTORG 
RT1_CCE1164     DS 0H
*MEXIT #=  1204 LV= 1 RT1
         CLI   =C'A',C'B' CC1= NZ,B
         LG    R0,=X'8000000000000000'
         SLBG  R0,=X'0000000000000001'
*MCALL #=  1205 LV= 1          RT1   CC3        NZ,NB
         DS    0H
RT1_TEST1165     BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC31165
         LTORG 
RT1_CC31165     DS 0H
*MEXIT #=  1205 LV= 1 RT1
         CLG   R0,=X'7FFFFFFFFFFFFFFE'
*MCALL #=  1206 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1166     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1166
         LTORG 
RT1_CCE1166     DS 0H
*MEXIT #=  1206 LV= 1 RT1
         CLI   =C'A',C'B' CC1= NZ,B
         LG    R0,=X'0000000000000000'
         SLBG  R0,=X'0000000000000001'
*MCALL #=  1207 LV= 1          RT1   CC1        NZ,B
         DS    0H
RT1_TEST1167     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1167
         LTORG 
RT1_CCL1167     DS 0H
*MEXIT #=  1207 LV= 1 RT1
         CLG   R0,=X'FFFFFFFFFFFFFFFE'
*MCALL #=  1208 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1168     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1168
         LTORG 
RT1_CCE1168     DS 0H
*MEXIT #=  1208 LV= 1 RT1
         CLI   =C'B',C'A' CC2= Z,NB
         LG    R0,=X'0000000000000001'
         SLBG  R0,=X'0000000000000001'
*MCALL #=  1209 LV= 1          RT1   CC2        Z,NB
         DS    0H
RT1_TEST1169     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1169
         LTORG 
RT1_CCH1169     DS 0H
*MEXIT #=  1209 LV= 1 RT1
         CLG   R0,=X'0000000000000000'
*MCALL #=  1210 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1170     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1170
         LTORG 
RT1_CCE1170     DS 0H
*MEXIT #=  1210 LV= 1 RT1
         CLI   =C'A',C'B' CC1= NZ,B
         LG    R0,=X'0000000000000000'
         SLBG  R0,=X'0000000000000002'
*MCALL #=  1211 LV= 1          RT1   CC1        NZ,B
         DS    0H
RT1_TEST1171     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1171
         LTORG 
RT1_CCL1171     DS 0H
*MEXIT #=  1211 LV= 1 RT1
         CLG   R0,=X'FFFFFFFFFFFFFFFD'
*MCALL #=  1212 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1172     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1172
         LTORG 
RT1_CCE1172     DS 0H
*MEXIT #=  1212 LV= 1 RT1
         LG    R0,=FL8'2'
         LG    R2,=FL8'1'
         SLGR  R0,R2               CC3 NZ,NB
         SLBG  R0,=FL8'1'          RPI174 TEST < CC3 NZ,NB
*MCALL #=  1213 LV= 1          RT1   CC2                 CC2 Z,NB
         DS    0H
RT1_TEST1173     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1173
         LTORG 
RT1_CCH1173     DS 0H
*MEXIT #=  1213 LV= 1 RT1
         CLG   R0,=FL8'0'
*MCALL #=  1214 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1174     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1174
         LTORG 
RT1_CCE1174     DS 0H
*MEXIT #=  1214 LV= 1 RT1
         SGR   R0,R0               FORCE CC0 = Z,B
         SLBG  R0,=FL8'-1'         RPI174 TEST > CC0 Z,B
         SLBG  R0,=FL8'1'          RPI174 TEST < CC0 Z,B
*MCALL #=  1215 LV= 1          RT1   CC1                 NZ,B
         DS    0H
RT1_TEST1175     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1175
         LTORG 
RT1_CCL1175     DS 0H
*MEXIT #=  1215 LV= 1 RT1
         CLG   R0,=FL8'-2'
*MCALL #=  1216 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1176     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1176
         LTORG 
RT1_CCE1176     DS 0H
*MEXIT #=  1216 LV= 1 RT1
* E38E STPQ                 RPI173
         MVC   PWORK16,=16C' '
         LMG   R0,R1,=X'00112233445566778899AABBCCDDEEFF'
         STPQ  R0,PWORK16
*MCALL #=  1217 LV= 1          RT1   CCE,PWORK16,=X'0011223344556677889X
               9AABBCCDDEEFF'
         DS    0H
         CLC   PWORK16,=X'00112233445566778899AABBCCDDEEFF'
RT1_TEST1177     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1177
         LTORG 
RT1_CCE1177     DS 0H
*MEXIT #=  1217 LV= 1 RT1
* E38F LPQ                  RPI173
         MVC   PWORK16,=X'00112233445566778899AABBCCDDEEFF'
         SGR   R0,R0
         SGR   R1,R1
         LPQ   R0,PWORK16
         CG    R0,=X'0011223344556677'
*MCALL #=  1218 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1178     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1178
         LTORG 
RT1_CCE1178     DS 0H
*MEXIT #=  1218 LV= 1 RT1
         CG    R1,=X'8899AABBCCDDEEFF'
*MCALL #=  1219 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1179     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1179
         LTORG 
RT1_CCE1179     DS 0H
*MEXIT #=  1219 LV= 1 RT1
* E390 LLGC
         LLGC  R0,=X'FF'
         CLG   R0,=FL8'255'
*MCALL #=  1220 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1180     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1180
         LTORG 
RT1_CCE1180     DS 0H
*MEXIT #=  1220 LV= 1 RT1
* E391 LLGH
         LLGH  R0,=X'FFFF'
         CLG   R0,=XL8'000000FFFF'
*MCALL #=  1221 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1181     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1181
         LTORG 
RT1_CCE1181     DS 0H
*MEXIT #=  1221 LV= 1 RT1
* E394 LLC  Z9 LOAD LOGICAL CHARACTER
         L     R0,=F'-2'
         LLC   R0,=X'FF'
         CL    R0,=A(X'FF')
*MCALL #=  1222 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1182     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1182
         LTORG 
RT1_CCE1182     DS 0H
*MEXIT #=  1222 LV= 1 RT1
* E395 LLH  Z9 LOAD LOGICAL HALFWORD
         L     R0,=F'-2'
         LLH   R0,=X'FFFF'
         CL    R0,=A(X'FFFF')
*MCALL #=  1223 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1183     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1183
         LTORG 
RT1_CCE1183     DS 0H
*MEXIT #=  1223 LV= 1 RT1
* E396 ML
         L     R0,=F'-1' JUNK
         L     R1,=F'3'
         ML    R0,=F'2'
         CL    R0,=F'0'
*MCALL #=  1224 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1184     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1184
         LTORG 
RT1_CCE1184     DS 0H
*MEXIT #=  1224 LV= 1 RT1
         CL    R1,=F'6'
*MCALL #=  1225 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1185     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1185
         LTORG 
RT1_CCE1185     DS 0H
*MEXIT #=  1225 LV= 1 RT1
         L     R0,=F'-1' JUNK
         L     R1,=X'80000000'
         ML    R0,=X'80000000'
         CL    R0,=X'40000000'
*MCALL #=  1226 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1186     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1186
         LTORG 
RT1_CCE1186     DS 0H
*MEXIT #=  1226 LV= 1 RT1
         CL    R1,=X'00000000'
*MCALL #=  1227 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1187     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1187
         LTORG 
RT1_CCE1187     DS 0H
*MEXIT #=  1227 LV= 1 RT1
* E397 DL
         L     R0,=F'0'
         L     R1,=F'13'
         DL    R0,=F'4'
         CL    R0,=F'1'
*MCALL #=  1228 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1188     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1188
         LTORG 
RT1_CCE1188     DS 0H
*MEXIT #=  1228 LV= 1 RT1
         CL    R1,=F'3'
*MCALL #=  1229 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1189     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1189
         LTORG 
RT1_CCE1189     DS 0H
*MEXIT #=  1229 LV= 1 RT1
         L     R0,=X'40000000'
         L     R1,=F'2'
         DL    R0,=X'80000000'
         CL    R0,=F'2'
*MCALL #=  1230 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1190     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1190
         LTORG 
RT1_CCE1190     DS 0H
*MEXIT #=  1230 LV= 1 RT1
         CL    R1,=X'80000000'
*MCALL #=  1231 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1191     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1191
         LTORG 
RT1_CCE1191     DS 0H
*MEXIT #=  1231 LV= 1 RT1
* E398 ALC
         CLI   =C'B',C'A' CC2 = Z,C
         L     R0,=F'3'
         ALC   R0,=F'2'
*MCALL #=  1232 LV= 1          RT1   CC1        NZ,NC
         DS    0H
RT1_TEST1192     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1192
         LTORG 
RT1_CCL1192     DS 0H
*MEXIT #=  1232 LV= 1 RT1
         CL    R0,=F'6'
*MCALL #=  1233 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1193     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1193
         LTORG 
RT1_CCE1193     DS 0H
*MEXIT #=  1233 LV= 1 RT1
         CLI   =C'B',C'A' CC2 = Z,C
         L     R0,=X'80000000'
         ALC   R0,=X'00000001'
*MCALL #=  1234 LV= 1          RT1   CC1        NZ,NC
         DS    0H
RT1_TEST1194     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1194
         LTORG 
RT1_CCL1194     DS 0H
*MEXIT #=  1234 LV= 1 RT1
         CL    R0,=X'80000002'
*MCALL #=  1235 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1195     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1195
         LTORG 
RT1_CCE1195     DS 0H
*MEXIT #=  1235 LV= 1 RT1
         CLI   =C'A',C'B' CC1 = NZ,NC
         L     R0,=X'FFFFFFFF'
         ALC   R0,=X'00000001'
*MCALL #=  1236 LV= 1          RT1   CC2        Z,C
         DS    0H
RT1_TEST1196     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1196
         LTORG 
RT1_CCH1196     DS 0H
*MEXIT #=  1236 LV= 1 RT1
         CL    R0,=X'00000000'
*MCALL #=  1237 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1197     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1197
         LTORG 
RT1_CCE1197     DS 0H
*MEXIT #=  1237 LV= 1 RT1
         CLI   =C'A',C'B' CC1 = NZ,NC
         L     R0,=X'FFFFFFFF'
         ALC   R0,=X'00000002'
*MCALL #=  1238 LV= 1          RT1   CC3        NZ,C
         DS    0H
RT1_TEST1198     BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC31198
         LTORG 
RT1_CC31198     DS 0H
*MEXIT #=  1238 LV= 1 RT1
         CL    R0,=X'00000001'
*MCALL #=  1239 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1199     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1199
         LTORG 
RT1_CCE1199     DS 0H
*MEXIT #=  1239 LV= 1 RT1
         CLI   =C'A',C'B' CC1 = NZ,NC
         L     R0,=X'00000000'
         ALC   R0,=X'00000000'
*MCALL #=  1240 LV= 1          RT1   CC0        Z,NC
         DS    0H
RT1_TEST1200     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1200
         LTORG 
RT1_CCE1200     DS 0H
*MEXIT #=  1240 LV= 1 RT1
         CL    R0,=X'00000000'
*MCALL #=  1241 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1201     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1201
         LTORG 
RT1_CCE1201     DS 0H
*MEXIT #=  1241 LV= 1 RT1
         L     R0,=X'FFFFFFFF'
         AL    R0,=X'00000002'     CC3 NZ,C
         ALC   R0,=X'00000001'     RPI174 TEST < CC3
*MCALL #=  1242 LV= 1          RT1   CC1
         DS    0H
RT1_TEST1202     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1202
         LTORG 
RT1_CCL1202     DS 0H
*MEXIT #=  1242 LV= 1 RT1
         CL    R0,=X'00000003'
*MCALL #=  1243 LV= 1          RT1   CC0
         DS    0H
RT1_TEST1203     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1203
         LTORG 
RT1_CCE1203     DS 0H
*MEXIT #=  1243 LV= 1 RT1
         SR    R0,R0               FORCE CC0 Z,NC
         L     R0,=X'FFFFFFFF'
         ALC   R0,=X'FFFFFFFF'
*MCALL #=  1244 LV= 1          RT1   CC3                 RPI-376
         DS    0H
RT1_TEST1204     BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC31204
         LTORG 
RT1_CC31204     DS 0H
*MEXIT #=  1244 LV= 1 RT1
         CL    R0,=X'FFFFFFFE'
*MCALL #=  1245 LV= 1          RT1   CC0
         DS    0H
RT1_TEST1205     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1205
         LTORG 
RT1_CCE1205     DS 0H
*MEXIT #=  1245 LV= 1 RT1
         SR    R0,R0               FORCE CC0 Z,NC
         ALC   R0,=F'1'            RPI174 TEST < CC0
*MCALL #=  1246 LV= 1          RT1   CC1
         DS    0H
RT1_TEST1206     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1206
         LTORG 
RT1_CCL1206     DS 0H
*MEXIT #=  1246 LV= 1 RT1
         CL    R0,=F'1'
*MCALL #=  1247 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1207     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1207
         LTORG 
RT1_CCE1207     DS 0H
*MEXIT #=  1247 LV= 1 RT1
* E399 SLB
         CLI   =C'A',C'B' CC1= NZ,B
         L     R0,=F'4'
         SLB   R0,=F'2'
*MCALL #=  1248 LV= 1          RT1   CC3        NZ,NB
         DS    0H
RT1_TEST1208     BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC31208
         LTORG 
RT1_CC31208     DS 0H
*MEXIT #=  1248 LV= 1 RT1
         CL    R0,=F'1'
*MCALL #=  1249 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1209     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1209
         LTORG 
RT1_CCE1209     DS 0H
*MEXIT #=  1249 LV= 1 RT1
         CLI   =C'A',C'B' CC1= NZ,B
         L     R0,=X'80000000'
         SLB   R0,=X'00000001'
*MCALL #=  1250 LV= 1          RT1   CC3        NZ,NB
         DS    0H
RT1_TEST1210     BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC31210
         LTORG 
RT1_CC31210     DS 0H
*MEXIT #=  1250 LV= 1 RT1
         CL    R0,=X'7FFFFFFE'
*MCALL #=  1251 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1211     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1211
         LTORG 
RT1_CCE1211     DS 0H
*MEXIT #=  1251 LV= 1 RT1
         CLI   =C'A',C'B' CC1= NZ,B
         L     R0,=X'00000000'
         SLB   R0,=X'00000001'
*MCALL #=  1252 LV= 1          RT1   CC1        NZ,B
         DS    0H
RT1_TEST1212     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1212
         LTORG 
RT1_CCL1212     DS 0H
*MEXIT #=  1252 LV= 1 RT1
         CL    R0,=X'FFFFFFFE'
*MCALL #=  1253 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1213     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1213
         LTORG 
RT1_CCE1213     DS 0H
*MEXIT #=  1253 LV= 1 RT1
         CLI   =C'B',C'A' CC2= Z,NB
         L     R0,=X'00000001'
         SLB   R0,=X'00000001'
*MCALL #=  1254 LV= 1          RT1   CC2        Z,NB
         DS    0H
RT1_TEST1214     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1214
         LTORG 
RT1_CCH1214     DS 0H
*MEXIT #=  1254 LV= 1 RT1
         CL    R0,=X'00000000'
*MCALL #=  1255 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1215     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1215
         LTORG 
RT1_CCE1215     DS 0H
*MEXIT #=  1255 LV= 1 RT1
         CLI   =C'A',C'B' CC1= NZ,B
         L     R0,=X'00000000'
         SLB    R0,=X'00000002'
*MCALL #=  1256 LV= 1          RT1   CC1        NZ,B
         DS    0H
RT1_TEST1216     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1216
         LTORG 
RT1_CCL1216     DS 0H
*MEXIT #=  1256 LV= 1 RT1
         CL    R0,=X'FFFFFFFD'
*MCALL #=  1257 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1217     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1217
         LTORG 
RT1_CCE1217     DS 0H
*MEXIT #=  1257 LV= 1 RT1
         L     R0,=F'2'
         L     R2,=F'1'
         SLR   R0,R2               CC3 NZ,NB
         SLB   R0,=F'1'            RPI174 TEST < CC3 NZ,NB
*MCALL #=  1258 LV= 1          RT1   CC2                 CC2 Z,NB
         DS    0H
RT1_TEST1218     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1218
         LTORG 
RT1_CCH1218     DS 0H
*MEXIT #=  1258 LV= 1 RT1
         CL    R0,=F'0'
*MCALL #=  1259 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1219     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1219
         LTORG 
RT1_CCE1219     DS 0H
*MEXIT #=  1259 LV= 1 RT1
         SR    R0,R0               FORCE CC0 = Z,B
         SLB   R0,=F'-1'           RPI174 TEST > CC0 Z,B
         SLB   R0,=F'1'            RPI174 TEST < CC0 Z,B
*MCALL #=  1260 LV= 1          RT1   CC1                 NZ,B
         DS    0H
RT1_TEST1220     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1220
         LTORG 
RT1_CCL1220     DS 0H
*MEXIT #=  1260 LV= 1 RT1
         CL    R0,=F'-2'
*MCALL #=  1261 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1221     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1221
         LTORG 
RT1_CCE1221     DS 0H
*MEXIT #=  1261 LV= 1 RT1
* E8   MVCIN
         MVCIN BYTE,=X'EE'
         CLI   BYTE,X'EE'
*MCALL #=  1262 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1222     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1222
         LTORG 
RT1_CCE1222     DS 0H
*MEXIT #=  1262 LV= 1 RT1
         MVCIN PWORK,=C'ABCDEFGH'+7
         CLC   PWORK,=C'HGFEDCBA'
*MCALL #=  1263 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1223     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1223
         LTORG 
RT1_CCE1223     DS 0H
*MEXIT #=  1263 LV= 1 RT1
* E9   PKA
         PKA   PWORK16,=C"123"
         CLC   PWORK16,=XL16'123C'
*MCALL #=  1264 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1224     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1224
         LTORG 
RT1_CCE1224     DS 0H
*MEXIT #=  1264 LV= 1 RT1
         PKA   PWORK16,=C"1234567890123456789012345678901"
         CLC   PWORK16,=X'1234567890123456789012345678901C'
*MCALL #=  1265 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1225     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1225
         LTORG 
RT1_CCE1225     DS 0H
*MEXIT #=  1265 LV= 1 RT1
* EA   UNPKA
         UNPKA PWORK(4),=PL16'1234'
*MCALL #=  1266 LV= 1          RT1   CC0
         DS    0H
RT1_TEST1226     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1226
         LTORG 
RT1_CCE1226     DS 0H
*MEXIT #=  1266 LV= 1 RT1
         CLC   PWORK(4),=C"1234"
*MCALL #=  1267 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1227     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1227
         LTORG 
RT1_CCE1227     DS 0H
*MEXIT #=  1267 LV= 1 RT1
         UNPKA PWORK(3),=XL16'123F'
*MCALL #=  1268 LV= 1          RT1   CC0
         DS    0H
RT1_TEST1228     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1228
         LTORG 
RT1_CCE1228     DS 0H
*MEXIT #=  1268 LV= 1 RT1
         CLC   PWORK(3),=C"123"
*MCALL #=  1269 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1229     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1229
         LTORG 
RT1_CCE1229     DS 0H
*MEXIT #=  1269 LV= 1 RT1
         UNPKA PWORK(3),=PL16'123'
*MCALL #=  1270 LV= 1          RT1   CC0
         DS    0H
RT1_TEST1230     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1230
         LTORG 
RT1_CCE1230     DS 0H
*MEXIT #=  1270 LV= 1 RT1
         CLC   PWORK(3),=C"123"
*MCALL #=  1271 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1231     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1231
         LTORG 
RT1_CCE1231     DS 0H
*MEXIT #=  1271 LV= 1 RT1
         UNPKA PWORK(3),=PL16'-123'
*MCALL #=  1272 LV= 1          RT1   CC1
         DS    0H
RT1_TEST1232     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1232
         LTORG 
RT1_CCL1232     DS 0H
*MEXIT #=  1272 LV= 1 RT1
         CLC   PWORK(3),=C"123" ALWAYS POSITIVE SIGN
*MCALL #=  1273 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1233     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1233
         LTORG 
RT1_CCE1233     DS 0H
*MEXIT #=  1273 LV= 1 RT1
         UNPKA PWORK(3),=XL16'1234'
*MCALL #=  1274 LV= 1          RT1   CC3
         DS    0H
RT1_TEST1234     BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC31234
         LTORG 
RT1_CC31234     DS 0H
*MEXIT #=  1274 LV= 1 RT1
* EB04 LMG
         LMG   R15,R0,=AD(123,456)
         CLG   R15,=AD(123)
*MCALL #=  1275 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1235     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1235
         LTORG 
RT1_CCE1235     DS 0H
*MEXIT #=  1275 LV= 1 RT1
         CLG   R0,=AD(456)
*MCALL #=  1276 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1236     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1236
         LTORG 
RT1_CCE1236     DS 0H
*MEXIT #=  1276 LV= 1 RT1
* EB0A SRAG
         LG    R1,=FL8'2'
         SRAG  R0,R1,1
*MCALL #=  1277 LV= 1          RT1   CC2
         DS    0H
RT1_TEST1237     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1237
         LTORG 
RT1_CCH1237     DS 0H
*MEXIT #=  1277 LV= 1 RT1
         CLG   R0,=FL8'1'
*MCALL #=  1278 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1238     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1238
         LTORG 
RT1_CCE1238     DS 0H
*MEXIT #=  1278 LV= 1 RT1
         LG    R1,=FL8'0'
         SRAG  R0,R1,1
*MCALL #=  1279 LV= 1          RT1   CC0
         DS    0H
RT1_TEST1239     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1239
         LTORG 
RT1_CCE1239     DS 0H
*MEXIT #=  1279 LV= 1 RT1
         CLG   R0,=FL8'0'
*MCALL #=  1280 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1240     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1240
         LTORG 
RT1_CCE1240     DS 0H
*MEXIT #=  1280 LV= 1 RT1
         LG    R1,=FL8'-2'
         SRAG  R0,R1,1
*MCALL #=  1281 LV= 1          RT1   CC1
         DS    0H
RT1_TEST1241     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1241
         LTORG 
RT1_CCL1241     DS 0H
*MEXIT #=  1281 LV= 1 RT1
         CLG   R0,=FL8'-1'
*MCALL #=  1282 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1242     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1242
         LTORG 
RT1_CCE1242     DS 0H
*MEXIT #=  1282 LV= 1 RT1
         LG    R1,=XL8'C000000000000000'
         SRAG  R0,R1,1
*MCALL #=  1283 LV= 1          RT1   CCL
         DS    0H
RT1_TEST1243     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1243
         LTORG 
RT1_CCL1243     DS 0H
*MEXIT #=  1283 LV= 1 RT1
         CLG   R0,=X'E000000000000000'
*MCALL #=  1284 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1244     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1244
         LTORG 
RT1_CCE1244     DS 0H
*MEXIT #=  1284 LV= 1 RT1
         LG    R1,=XL8'C000000000000000'
         LA    2,1
         SRAG  R0,R1,0(2)
*MCALL #=  1285 LV= 1          RT1   CCL
         DS    0H
RT1_TEST1245     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1245
         LTORG 
RT1_CCL1245     DS 0H
*MEXIT #=  1285 LV= 1 RT1
         CLG   R0,=X'E000000000000000'
*MCALL #=  1286 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1246     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1246
         LTORG 
RT1_CCE1246     DS 0H
*MEXIT #=  1286 LV= 1 RT1
* EB0B SLAG
         LG    R1,=FL8'1'
         SLAG  R0,R1,1
*MCALL #=  1287 LV= 1          RT1   CC2
         DS    0H
RT1_TEST1247     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1247
         LTORG 
RT1_CCH1247     DS 0H
*MEXIT #=  1287 LV= 1 RT1
         CLG   R0,=FL8'2'
*MCALL #=  1288 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1248     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1248
         LTORG 
RT1_CCE1248     DS 0H
*MEXIT #=  1288 LV= 1 RT1
         LG    R1,=FL8'0'
         SLAG  R0,R1,1
*MCALL #=  1289 LV= 1          RT1   CC0
         DS    0H
RT1_TEST1249     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1249
         LTORG 
RT1_CCE1249     DS 0H
*MEXIT #=  1289 LV= 1 RT1
         CLG   R0,=FL8'0'
*MCALL #=  1290 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1250     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1250
         LTORG 
RT1_CCE1250     DS 0H
*MEXIT #=  1290 LV= 1 RT1
         LG    R1,=FL8'-1'
         SLAG  R0,R1,1
*MCALL #=  1291 LV= 1          RT1   CC1
         DS    0H
RT1_TEST1251     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1251
         LTORG 
RT1_CCL1251     DS 0H
*MEXIT #=  1291 LV= 1 RT1
         CLG   R0,=FL8'-2'
*MCALL #=  1292 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1252     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1252
         LTORG 
RT1_CCE1252     DS 0H
*MEXIT #=  1292 LV= 1 RT1
         LG    R1,=XL8'6000000000000000'
         SLAG  R0,R1,1
*MCALL #=  1293 LV= 1          RT1   CC3
         DS    0H
RT1_TEST1253     BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC31253
         LTORG 
RT1_CC31253     DS 0H
*MEXIT #=  1293 LV= 1 RT1
         CLG   R0,=X'4000000000000000'
*MCALL #=  1294 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1254     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1254
         LTORG 
RT1_CCE1254     DS 0H
*MEXIT #=  1294 LV= 1 RT1
         LG    R1,=XL8'A000000000000000'
         SLAG  R0,R1,1
*MCALL #=  1295 LV= 1          RT1   CC3
         DS    0H
RT1_TEST1255     BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC31255
         LTORG 
RT1_CC31255     DS 0H
*MEXIT #=  1295 LV= 1 RT1
         CLG   R0,=X'C000000000000000'
*MCALL #=  1296 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1256     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1256
         LTORG 
RT1_CCE1256     DS 0H
*MEXIT #=  1296 LV= 1 RT1
* EB0C SRLG
         LG    R1,=FL8'2'
         SRLG  R0,R1,1
         CLG   R0,=FL8'1'
*MCALL #=  1297 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1257     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1257
         LTORG 
RT1_CCE1257     DS 0H
*MEXIT #=  1297 LV= 1 RT1
         LG    R1,=FL8'0'
         SRLG  R0,R1,1
         CLG   R0,=FL8'0'
*MCALL #=  1298 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1258     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1258
         LTORG 
RT1_CCE1258     DS 0H
*MEXIT #=  1298 LV= 1 RT1
         LG    R1,=FL8'-2'
         SRLG  R0,R1,1
         CLG   R0,=X'7FFFFFFFFFFFFFFF'
*MCALL #=  1299 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1259     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1259
         LTORG 
RT1_CCE1259     DS 0H
*MEXIT #=  1299 LV= 1 RT1
         LG    R1,=XL8'C000000000000000'
         SRLG  R0,R1,1
         CLG   R0,=X'6000000000000000'
*MCALL #=  1300 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1260     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1260
         LTORG 
RT1_CCE1260     DS 0H
*MEXIT #=  1300 LV= 1 RT1
* EB0D SLLG
         LG    R1,=FL8'1'
         SLLG  R0,R1,1
         CLG   R0,=FL8'2'
*MCALL #=  1301 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1261     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1261
         LTORG 
RT1_CCE1261     DS 0H
*MEXIT #=  1301 LV= 1 RT1
         LG    R1,=FL8'0'
         SLLG  R0,R1,1
         CLG   R0,=FL8'0'
*MCALL #=  1302 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1262     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1262
         LTORG 
RT1_CCE1262     DS 0H
*MEXIT #=  1302 LV= 1 RT1
         LG    R1,=FL8'-1'
         SLLG  R0,R1,1
         CLG   R0,=FL8'-2'
*MCALL #=  1303 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1263     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1263
         LTORG 
RT1_CCE1263     DS 0H
*MEXIT #=  1303 LV= 1 RT1
         LG    R1,=XL8'6000000000000000'
         SLLG  R0,R1,1
         CLG   R0,=X'C000000000000000'
*MCALL #=  1304 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1264     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1264
         LTORG 
RT1_CCE1264     DS 0H
*MEXIT #=  1304 LV= 1 RT1
         LG    R1,=XL8'A000000000000000'
         SLLG  R0,R1,1
         CLG   R0,=X'4000000000000000'
*MCALL #=  1305 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1265     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1265
         LTORG 
RT1_CCE1265     DS 0H
*MEXIT #=  1305 LV= 1 RT1
* EB14 CSY
         LM    R1,R2,=A(1,2)
         MVC   WORD,=A(3)
         CSY   R1,R2,WORD
*MCALL #=  1306 LV= 1          RT1   CC1
         DS    0H
RT1_TEST1266     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1266
         LTORG 
RT1_CCL1266     DS 0H
*MEXIT #=  1306 LV= 1 RT1
         CL    R1,=A(3)
*MCALL #=  1307 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1267     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1267
         LTORG 
RT1_CCE1267     DS 0H
*MEXIT #=  1307 LV= 1 RT1
         CLC   WORD,=A(3)
*MCALL #=  1308 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1268     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1268
         LTORG 
RT1_CCE1268     DS 0H
*MEXIT #=  1308 LV= 1 RT1
         LM    R1,R2,=A(4,5)
         MVC   WORD,=A(4)
         CSY   R1,R2,WORD
*MCALL #=  1309 LV= 1          RT1   CC0
         DS    0H
RT1_TEST1269     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1269
         LTORG 
RT1_CCE1269     DS 0H
*MEXIT #=  1309 LV= 1 RT1
         CL    R1,=A(4)
*MCALL #=  1310 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1270     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1270
         LTORG 
RT1_CCE1270     DS 0H
*MEXIT #=  1310 LV= 1 RT1
         CLC   WORD,=A(5)
*MCALL #=  1311 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1271     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1271
         LTORG 
RT1_CCE1271     DS 0H
*MEXIT #=  1311 LV= 1 RT1
* EB1C RLLG
         LG    R1,=FL8'1'
         RLLG  R0,R1,1
         CLG   R0,=FL8'2'
*MCALL #=  1312 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1272     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1272
         LTORG 
RT1_CCE1272     DS 0H
*MEXIT #=  1312 LV= 1 RT1
         LG    R1,=X'0123456789ABCDEF'
         RLLG  R0,R1,12
         CLG   R0,=X'3456789ABCDEF012'
*MCALL #=  1313 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1273     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1273
         LTORG 
RT1_CCE1273     DS 0H
*MEXIT #=  1313 LV= 1 RT1
* EB1D RLL
         L     R1,=F'1'
         RLL   R0,R1,3
         CL    R0,=F'8'
         L     R1,=X'12345678'
         RLL   R0,R1,12
         CL    R0,=X'45677123'
         L     R1,=X'ABCD1234'
         RLL   R0,R1,16
         CL    R0,=X'1234ABCD'
* EB20 CLMH
         LG    R0,=X'1234567800000000'
         CLMH  R0,15,=X'1234567800000000'
*MCALL #=  1314 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1274     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1274
         LTORG 
RT1_CCE1274     DS 0H
*MEXIT #=  1314 LV= 1 RT1
         CLMH  R0,15,=X'1234567900000000'
*MCALL #=  1315 LV= 1          RT1   CCL
         DS    0H
RT1_TEST1275     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1275
         LTORG 
RT1_CCL1275     DS 0H
*MEXIT #=  1315 LV= 1 RT1
         CLMH  R0,15,=X'1234567700000000'
*MCALL #=  1316 LV= 1          RT1   CCH
         DS    0H
RT1_TEST1276     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1276
         LTORG 
RT1_CCH1276     DS 0H
*MEXIT #=  1316 LV= 1 RT1
* EB21 CLMY
         L     R1,=C'ABCD'
         CLMY  R1,9,=C'AD'
*MCALL #=  1317 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1277     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1277
         LTORG 
RT1_CCE1277     DS 0H
*MEXIT #=  1317 LV= 1 RT1
         L     R1,=C'ABCD'
         CLMY  R1,9,=C'AC'
*MCALL #=  1318 LV= 1          RT1   CCH
         DS    0H
RT1_TEST1278     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1278
         LTORG 
RT1_CCH1278     DS 0H
*MEXIT #=  1318 LV= 1 RT1
         L     R1,=C'ABCD'
         CLMY  R1,9,=C'AE'
*MCALL #=  1319 LV= 1          RT1   CCL
         DS    0H
RT1_TEST1279     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1279
         LTORG 
RT1_CCL1279     DS 0H
*MEXIT #=  1319 LV= 1 RT1
* EB24 STMG
         LMG   R14,R15,=FL8'1,-1'
         STMG  R14,R15,REGS
*MCALL #=  1320 LV= 1          RT1   CCE,REGS(16),=FL8'1,-1'
         DS    0H
         CLC   REGS(16),=FL8'1,-1'
RT1_TEST1280     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1280
         LTORG 
RT1_CCE1280     DS 0H
*MEXIT #=  1320 LV= 1 RT1
* EB26 STMH
         LG    R15,=AL4(1,2)
         LG    R0,=AL4(3,4)
         STMH  R15,R0,PWORK
*MCALL #=  1321 LV= 1          RT1   CCE,PWORK,=A(1,3)
         DS    0H
         CLC   PWORK,=A(1,3)
RT1_TEST1281     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1281
         LTORG 
RT1_CCE1281     DS 0H
*MEXIT #=  1321 LV= 1 RT1
* EB2C STCMH
         ICMH  R1,15,=C'4567'
         STCMH R1,15,WORD
         CLC   WORD,=C'4567'
*MCALL #=  1322 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1282     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1282
         LTORG 
RT1_CCE1282     DS 0H
*MEXIT #=  1322 LV= 1 RT1
         ICMH  R1,15,=C'4567'
         STCMH R1,9,WORD
         CLC   WORD(2),=C'47'
*MCALL #=  1323 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1283     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1283
         LTORG 
RT1_CCE1283     DS 0H
*MEXIT #=  1323 LV= 1 RT1
* EB2D STCMY
         ICM   R1,15,=C'4567'
         STCMY R1,15,WORD
         CLC   WORD,=C'4567'
*MCALL #=  1324 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1284     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1284
         LTORG 
RT1_CCE1284     DS 0H
*MEXIT #=  1324 LV= 1 RT1
         ICM   R1,15,=C'4567'
         STCMY R1,9,WORD
         CLC   WORD(2),=C'47'
*MCALL #=  1325 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1285     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1285
         LTORG 
RT1_CCE1285     DS 0H
*MEXIT #=  1325 LV= 1 RT1
* EB30 CSG
         LMG   R1,R2,=AD(1,2)
         MVC   PWORK,=AD(3)
         CSG   R1,R2,PWORK
*MCALL #=  1326 LV= 1          RT1   CC1
         DS    0H
RT1_TEST1286     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1286
         LTORG 
RT1_CCL1286     DS 0H
*MEXIT #=  1326 LV= 1 RT1
         CLG   R1,=AD(3)
*MCALL #=  1327 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1287     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1287
         LTORG 
RT1_CCE1287     DS 0H
*MEXIT #=  1327 LV= 1 RT1
         CLC   PWORK,=AD(3)
*MCALL #=  1328 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1288     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1288
         LTORG 
RT1_CCE1288     DS 0H
*MEXIT #=  1328 LV= 1 RT1
         LMG   R1,R2,=AD(4,5)
         MVC   PWORK,=AD(4)
         CSG   R1,R2,PWORK
*MCALL #=  1329 LV= 1          RT1   CC0
         DS    0H
RT1_TEST1289     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1289
         LTORG 
RT1_CCE1289     DS 0H
*MEXIT #=  1329 LV= 1 RT1
         CLG   R1,=AD(4)
*MCALL #=  1330 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1290     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1290
         LTORG 
RT1_CCE1290     DS 0H
*MEXIT #=  1330 LV= 1 RT1
         CLC   PWORK,=AD(5)
*MCALL #=  1331 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1291     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1291
         LTORG 
RT1_CCE1291     DS 0H
*MEXIT #=  1331 LV= 1 RT1
* BB31 CDSY
         LM    R0,R3,=A(1,2,3,4)
         MVC   REGS(8),=A(5,6)
         CDSY  R0,R2,REGS
*MCALL #=  1332 LV= 1          RT1   CC1
         DS    0H
RT1_TEST1292     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1292
         LTORG 
RT1_CCL1292     DS 0H
*MEXIT #=  1332 LV= 1 RT1
         CL    R0,=A(5)
*MCALL #=  1333 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1293     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1293
         LTORG 
RT1_CCE1293     DS 0H
*MEXIT #=  1333 LV= 1 RT1
         CL    R1,=A(6)
*MCALL #=  1334 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1294     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1294
         LTORG 
RT1_CCE1294     DS 0H
*MEXIT #=  1334 LV= 1 RT1
         CLC   REGS(8),=A(5,6)
*MCALL #=  1335 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1295     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1295
         LTORG 
RT1_CCE1295     DS 0H
*MEXIT #=  1335 LV= 1 RT1
         LM    R0,R3,=A(1,2,3,4)
         MVC   REGS(8),=A(1,2)
         CDSY  R0,R2,REGS
*MCALL #=  1336 LV= 1          RT1   CC0
         DS    0H
RT1_TEST1296     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1296
         LTORG 
RT1_CCE1296     DS 0H
*MEXIT #=  1336 LV= 1 RT1
         CL    R0,=A(1)
*MCALL #=  1337 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1297     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1297
         LTORG 
RT1_CCE1297     DS 0H
*MEXIT #=  1337 LV= 1 RT1
         CL    R1,=A(2)
*MCALL #=  1338 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1298     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1298
         LTORG 
RT1_CCE1298     DS 0H
*MEXIT #=  1338 LV= 1 RT1
         CLC   REGS(8),=A(3,4)
*MCALL #=  1339 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1299     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1299
         LTORG 
RT1_CCE1299     DS 0H
*MEXIT #=  1339 LV= 1 RT1
* EB3E CDSG
         LMG   R0,R3,=AD(1,2,3,4)
         MVC   REGS(16),=AD(5,6)
         CDSG  R0,R2,REGS
*MCALL #=  1340 LV= 1          RT1   CC1
         DS    0H
RT1_TEST1300     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1300
         LTORG 
RT1_CCL1300     DS 0H
*MEXIT #=  1340 LV= 1 RT1
         CLG   R0,=AD(5)
*MCALL #=  1341 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1301     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1301
         LTORG 
RT1_CCE1301     DS 0H
*MEXIT #=  1341 LV= 1 RT1
         CLG   R1,=AD(6)
*MCALL #=  1342 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1302     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1302
         LTORG 
RT1_CCE1302     DS 0H
*MEXIT #=  1342 LV= 1 RT1
         CLC   REGS(16),=AD(5,6)
*MCALL #=  1343 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1303     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1303
         LTORG 
RT1_CCE1303     DS 0H
*MEXIT #=  1343 LV= 1 RT1
         LMG   R0,R3,=AD(1,2,3,4)
         MVC   REGS,=AD(1,2)
         CDSG  R0,R2,REGS
*MCALL #=  1344 LV= 1          RT1   CC0
         DS    0H
RT1_TEST1304     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1304
         LTORG 
RT1_CCE1304     DS 0H
*MEXIT #=  1344 LV= 1 RT1
         CLG   R0,=AD(1)
*MCALL #=  1345 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1305     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1305
         LTORG 
RT1_CCE1305     DS 0H
*MEXIT #=  1345 LV= 1 RT1
         CLG   R1,=AD(2)
*MCALL #=  1346 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1306     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1306
         LTORG 
RT1_CCE1306     DS 0H
*MEXIT #=  1346 LV= 1 RT1
         CLC   REGS(16),=AD(3,4)
*MCALL #=  1347 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1307     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1307
         LTORG 
RT1_CCE1307     DS 0H
*MEXIT #=  1347 LV= 1 RT1
* EB44 BXHG
         LMG   R1,R3,=AD(2,-1,0)
         BXHG  R1,R2,BXHG2
         B     RT1_ABORT
BXHG2    EQU   *
         CLG   R1,=AD(1)
*MCALL #=  1348 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1308     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1308
         LTORG 
RT1_CCE1308     DS 0H
*MEXIT #=  1348 LV= 1 RT1
         BXHG  R1,R2,RT1_ABORT
         CLG   R1,=AD(0)
*MCALL #=  1349 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1309     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1309
         LTORG 
RT1_CCE1309     DS 0H
*MEXIT #=  1349 LV= 1 RT1
         LMG   R1,R3,=AD(2,-10,-1)
         BXHG  R1,R3,BXHG3
         B     RT1_ABORT
BXHG3    EQU   *
         CLG   R1,=AD(1)
*MCALL #=  1350 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1310     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1310
         LTORG 
RT1_CCE1310     DS 0H
*MEXIT #=  1350 LV= 1 RT1
         BXHG  R1,R3,BXHG4
         B     RT1_ABORT
BXHG4    EQU   *
         CLG   R1,=AD(0)
*MCALL #=  1351 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1311     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1311
         LTORG 
RT1_CCE1311     DS 0H
*MEXIT #=  1351 LV= 1 RT1
         BXHG  R1,R3,RT1_ABORT
         CLG   R1,=FL8'-1'
*MCALL #=  1352 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1312     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1312
         LTORG 
RT1_CCE1312     DS 0H
*MEXIT #=  1352 LV= 1 RT1
* EB45 BXLEG
         LMG   R1,R3,=AD(1,1,2)
         BXLEG R1,R2,BXLEG2
         B     RT1_ABORT
BXLEG2   EQU   *
         CLG   R1,=AD(2)
*MCALL #=  1353 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1313     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1313
         LTORG 
RT1_CCE1313     DS 0H
*MEXIT #=  1353 LV= 1 RT1
         BXLEG R1,R2,RT1_ABORT
         CLG   R1,=AD(3)
*MCALL #=  1354 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1314     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1314
         LTORG 
RT1_CCE1314     DS 0H
*MEXIT #=  1354 LV= 1 RT1
         LMG   R1,R3,=AD(0,-10,1)
         BXLEG R1,R3,BXLEG3
         B     RT1_ABORT
BXLEG3   EQU   *
         CLG   R1,=AD(1)
*MCALL #=  1355 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1315     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1315
         LTORG 
RT1_CCE1315     DS 0H
*MEXIT #=  1355 LV= 1 RT1
         BXLEG R1,R3,RT1_ABORT
         CLG   R1,=FL8'2'
*MCALL #=  1356 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1316     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1316
         LTORG 
RT1_CCE1316     DS 0H
*MEXIT #=  1356 LV= 1 RT1
* EB51 TMY
         TMY   =X'00',X'00'
*MCALL #=  1357 LV= 1          RT1   CC0
         DS    0H
RT1_TEST1317     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1317
         LTORG 
RT1_CCE1317     DS 0H
*MEXIT #=  1357 LV= 1 RT1
         TMY   =X'FF',X'00'
*MCALL #=  1358 LV= 1          RT1   CC0
         DS    0H
RT1_TEST1318     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1318
         LTORG 
RT1_CCE1318     DS 0H
*MEXIT #=  1358 LV= 1 RT1
         TMY   =X'00',X'FF'
*MCALL #=  1359 LV= 1          RT1   CC0
         DS    0H
RT1_TEST1319     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1319
         LTORG 
RT1_CCE1319     DS 0H
*MEXIT #=  1359 LV= 1 RT1
         TMY   =X'FF',X'FF'
*MCALL #=  1360 LV= 1          RT1   CC3
         DS    0H
RT1_TEST1320     BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC31320
         LTORG 
RT1_CC31320     DS 0H
*MEXIT #=  1360 LV= 1 RT1
         TMY   =X'FF',X'F0'
*MCALL #=  1361 LV= 1          RT1   CC3             RPI-844
         DS    0H
RT1_TEST1321     BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC31321
         LTORG 
RT1_CC31321     DS 0H
*MEXIT #=  1361 LV= 1 RT1
         LA    2,=X'FF'
         TMY   0(2),X'FF'
*MCALL #=  1362 LV= 1          RT1   CC3
         DS    0H
RT1_TEST1322     BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC31322
         LTORG 
RT1_CC31322     DS 0H
*MEXIT #=  1362 LV= 1 RT1
         LA    2,=X'00'
         TMY   0(2),X'00'
*MCALL #=  1363 LV= 1          RT1   CC0
         DS    0H
RT1_TEST1323     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1323
         LTORG 
RT1_CCE1323     DS 0H
*MEXIT #=  1363 LV= 1 RT1
         TMY   =X'CF',X'F0'    RPI-844
*MCALL #=  1364 LV= 1          RT1   CC1             RPI-844
         DS    0H
RT1_TEST1324     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1324
         LTORG 
RT1_CCL1324     DS 0H
*MEXIT #=  1364 LV= 1 RT1
         TMY   =X'F3',X'0F'    RPI-844
*MCALL #=  1365 LV= 1          RT1   CC1             RPI-844
         DS    0H
RT1_TEST1325     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1325
         LTORG 
RT1_CCL1325     DS 0H
*MEXIT #=  1365 LV= 1 RT1
* EB52 MVIY
         MVIY  BYTE,C'A'
         CLI   BYTE,C'A'
*MCALL #=  1366 LV= 1          RT1   CCE,BYTE,=C'A'
         DS    0H
         CLC   BYTE,=C'A'
RT1_TEST1326     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1326
         LTORG 
RT1_CCE1326     DS 0H
*MEXIT #=  1366 LV= 1 RT1
* EB54 NIY
         MVI   BYTE,X'32'
         NIY   BYTE,X'23'
*MCALL #=  1367 LV= 1          RT1   CCL
         DS    0H
RT1_TEST1327     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1327
         LTORG 
RT1_CCL1327     DS 0H
*MEXIT #=  1367 LV= 1 RT1
         CLI   BYTE,X'22'
*MCALL #=  1368 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1328     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1328
         LTORG 
RT1_CCE1328     DS 0H
*MEXIT #=  1368 LV= 1 RT1
* EB55 CLIY
         MVI   BYTE,C'B'
         CLIY  BYTE,C'B'
*MCALL #=  1369 LV= 1          RT1   CCE         RPI-875
         DS    0H
RT1_TEST1329     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1329
         LTORG 
RT1_CCE1329     DS 0H
*MEXIT #=  1369 LV= 1 RT1
         MVI   BYTE,C'A'
         CLIY  BYTE,C'B'
*MCALL #=  1370 LV= 1          RT1   CCL         RPI-875
         DS    0H
RT1_TEST1330     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1330
         LTORG 
RT1_CCL1330     DS 0H
*MEXIT #=  1370 LV= 1 RT1
         MVI   BYTE,C'C'
         CLIY  BYTE,C'B'
*MCALL #=  1371 LV= 1          RT1   CCH         RPI-875
         DS    0H
RT1_TEST1331     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1331
         LTORG 
RT1_CCH1331     DS 0H
*MEXIT #=  1371 LV= 1 RT1
         MVI   BYTE,X'01'
         CLIY  BYTE,X'81'
*MCALL #=  1372 LV= 1          RT1   CCL         RPI-875
         DS    0H
RT1_TEST1332     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1332
         LTORG 
RT1_CCL1332     DS 0H
*MEXIT #=  1372 LV= 1 RT1
         MVI   BYTE,X'81'
         CLIY  BYTE,X'01'
*MCALL #=  1373 LV= 1          RT1   CCH         RPI-875
         DS    0H
RT1_TEST1333     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1333
         LTORG 
RT1_CCH1333     DS 0H
*MEXIT #=  1373 LV= 1 RT1
* EB56 OIY
         MVI   BYTE,X'32'
         OIY   BYTE,X'23'
*MCALL #=  1374 LV= 1          RT1   CCL
         DS    0H
RT1_TEST1334     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1334
         LTORG 
RT1_CCL1334     DS 0H
*MEXIT #=  1374 LV= 1 RT1
         CLI   BYTE,X'33'
*MCALL #=  1375 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1335     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1335
         LTORG 
RT1_CCE1335     DS 0H
*MEXIT #=  1375 LV= 1 RT1
* EB57 XIY
         MVI   BYTE,X'32'
         XIY   BYTE,X'23'
*MCALL #=  1376 LV= 1          RT1   CCL
         DS    0H
RT1_TEST1336     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1336
         LTORG 
RT1_CCL1336     DS 0H
*MEXIT #=  1376 LV= 1 RT1
         CLI   BYTE,X'11'
*MCALL #=  1377 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1337     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1337
         LTORG 
RT1_CCE1337     DS 0H
*MEXIT #=  1377 LV= 1 RT1
* EB6A ASI                 RPI-875
         MVC   WORD,=F'2'
         ASI   WORD,3
*MCALL #=  1378 LV= 1          RT1   CCH
         DS    0H
RT1_TEST1338     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1338
         LTORG 
RT1_CCH1338     DS 0H
*MEXIT #=  1378 LV= 1 RT1
         CLC   WORD,=F'5'
*MCALL #=  1379 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1339     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1339
         LTORG 
RT1_CCE1339     DS 0H
*MEXIT #=  1379 LV= 1 RT1
         MVC   WORD,=F'1'
         ASI   WORD,-2
*MCALL #=  1380 LV= 1          RT1   CCL
         DS    0H
RT1_TEST1340     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1340
         LTORG 
RT1_CCL1340     DS 0H
*MEXIT #=  1380 LV= 1 RT1
         CLC   WORD,=F'-1'
*MCALL #=  1381 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1341     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1341
         LTORG 
RT1_CCE1341     DS 0H
*MEXIT #=  1381 LV= 1 RT1
* EB6E ALSI                RPI-875
         MVC   WORD,=F'3'
         ALSI  WORD,2
*MCALL #=  1382 LV= 1          RT1   CC1        NZ,NC
         DS    0H
RT1_TEST1342     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1342
         LTORG 
RT1_CCL1342     DS 0H
*MEXIT #=  1382 LV= 1 RT1
         CLC   WORD,=F'5'
*MCALL #=  1383 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1343     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1343
         LTORG 
RT1_CCE1343     DS 0H
*MEXIT #=  1383 LV= 1 RT1
         MVC   WORD,=X'80000000'
         ALSI  WORD,1
*MCALL #=  1384 LV= 1          RT1   CC1        NZ,NC
         DS    0H
RT1_TEST1344     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1344
         LTORG 
RT1_CCL1344     DS 0H
*MEXIT #=  1384 LV= 1 RT1
         CLC   WORD,=X'80000001'
*MCALL #=  1385 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1345     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1345
         LTORG 
RT1_CCE1345     DS 0H
*MEXIT #=  1385 LV= 1 RT1
         MVC   WORD,=X'FFFFFFFF'
         ALSI  WORD,1
*MCALL #=  1386 LV= 1          RT1   CC2        Z,C
         DS    0H
RT1_TEST1346     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1346
         LTORG 
RT1_CCH1346     DS 0H
*MEXIT #=  1386 LV= 1 RT1
         CLC   WORD,=X'00000000'
*MCALL #=  1387 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1347     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1347
         LTORG 
RT1_CCE1347     DS 0H
*MEXIT #=  1387 LV= 1 RT1
         MVC   WORD,=X'FFFFFFFF'
         ALSI  WORD,2
*MCALL #=  1388 LV= 1          RT1   CC3        NZ,C
         DS    0H
RT1_TEST1348     BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC31348
         LTORG 
RT1_CC31348     DS 0H
*MEXIT #=  1388 LV= 1 RT1
         CLC   WORD,=X'00000001'
*MCALL #=  1389 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1349     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1349
         LTORG 
RT1_CCE1349     DS 0H
*MEXIT #=  1389 LV= 1 RT1
         MVC   WORD,=X'FFFFFFFF'
         ALSI  WORD,-1
*MCALL #=  1390 LV= 1          RT1   CC1       NZ,NC    RPI-1125 FIX ALX
               SI, ALGSI
         DS    0H
RT1_TEST1350     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1350
         LTORG 
RT1_CCL1350     DS 0H
*MEXIT #=  1390 LV= 1 RT1
         CLC   WORD,=X'FFFFFFFE'
*MCALL #=  1391 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1351     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1351
         LTORG 
RT1_CCE1351     DS 0H
*MEXIT #=  1391 LV= 1 RT1
         MVC   WORD,=X'00000000'
         ALSI  WORD,0
*MCALL #=  1392 LV= 1          RT1   CC0        Z,NC
         DS    0H
RT1_TEST1352     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1352
         LTORG 
RT1_CCE1352     DS 0H
*MEXIT #=  1392 LV= 1 RT1
         CLC   WORD,=X'00000000'
*MCALL #=  1393 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1353     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1353
         LTORG 
RT1_CCE1353     DS 0H
*MEXIT #=  1393 LV= 1 RT1
         MVC   WORD,=X'80000000'
         ALSI  WORD,-1
*MCALL #=  1394 LV= 1          RT1   CC1       NZ,NB    RPI-1125 FIX ALX
               SI, ALGSI
         DS    0H
RT1_TEST1354     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1354
         LTORG 
RT1_CCL1354     DS 0H
*MEXIT #=  1394 LV= 1 RT1
         CLC   WORD,=X'7FFFFFFF'
*MCALL #=  1395 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1355     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1355
         LTORG 
RT1_CCE1355     DS 0H
*MEXIT #=  1395 LV= 1 RT1
         MVC   WORD,=F'0'
         ALSI  WORD,-1
*MCALL #=  1396 LV= 1          RT1   CC3        NZ,B RPI-1125 FIX ALSI,X
                ALGSI
         DS    0H
RT1_TEST1356     BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC31356
         LTORG 
RT1_CC31356     DS 0H
*MEXIT #=  1396 LV= 1 RT1
         CLC   WORD,=F'-1'
*MCALL #=  1397 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1357     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1357
         LTORG 
RT1_CCE1357     DS 0H
*MEXIT #=  1397 LV= 1 RT1
* EB7A AGSI                RPI-875
         MVC   DWORD,=FL8'2'
         AGSI  DWORD,3
*MCALL #=  1398 LV= 1          RT1   CCH
         DS    0H
RT1_TEST1358     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1358
         LTORG 
RT1_CCH1358     DS 0H
*MEXIT #=  1398 LV= 1 RT1
         CLC   DWORD,=FL8'5'
*MCALL #=  1399 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1359     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1359
         LTORG 
RT1_CCE1359     DS 0H
*MEXIT #=  1399 LV= 1 RT1
         MVC   DWORD,=FL8'1'
         AGSI  DWORD,-2
*MCALL #=  1400 LV= 1          RT1   CCL
         DS    0H
RT1_TEST1360     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1360
         LTORG 
RT1_CCL1360     DS 0H
*MEXIT #=  1400 LV= 1 RT1
         CLC   DWORD,=FL8'-1'
*MCALL #=  1401 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1361     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1361
         LTORG 
RT1_CCE1361     DS 0H
*MEXIT #=  1401 LV= 1 RT1
* EB7E ALGSI               RPI-875
         MVC   DWORD,=FL8'3'
         ALGSI DWORD,2
*MCALL #=  1402 LV= 1          RT1   CC1        NZ,NC
         DS    0H
RT1_TEST1362     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1362
         LTORG 
RT1_CCL1362     DS 0H
*MEXIT #=  1402 LV= 1 RT1
         CLC   DWORD,=FL8'5'
*MCALL #=  1403 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1363     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1363
         LTORG 
RT1_CCE1363     DS 0H
*MEXIT #=  1403 LV= 1 RT1
         MVC   DWORD,=X'8000000000000000'
         ALGSI DWORD,1
*MCALL #=  1404 LV= 1          RT1   CC1        NZ,NC
         DS    0H
RT1_TEST1364     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1364
         LTORG 
RT1_CCL1364     DS 0H
*MEXIT #=  1404 LV= 1 RT1
         CLC   DWORD,=X'8000000000000001'
*MCALL #=  1405 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1365     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1365
         LTORG 
RT1_CCE1365     DS 0H
*MEXIT #=  1405 LV= 1 RT1
         MVC   DWORD,=FL8'-1'
         ALGSI DWORD,1
*MCALL #=  1406 LV= 1          RT1   CC2        Z,C
         DS    0H
RT1_TEST1366     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1366
         LTORG 
RT1_CCH1366     DS 0H
*MEXIT #=  1406 LV= 1 RT1
         CLC   DWORD,=FL8'0'
*MCALL #=  1407 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1367     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1367
         LTORG 
RT1_CCE1367     DS 0H
*MEXIT #=  1407 LV= 1 RT1
         MVC   DWORD,=FL8'-1'
         ALGSI DWORD,2
*MCALL #=  1408 LV= 1          RT1   CC3        NZ,C
         DS    0H
RT1_TEST1368     BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC31368
         LTORG 
RT1_CC31368     DS 0H
*MEXIT #=  1408 LV= 1 RT1
         CLC   DWORD,=FL8'1'
*MCALL #=  1409 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1369     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1369
         LTORG 
RT1_CCE1369     DS 0H
*MEXIT #=  1409 LV= 1 RT1
         MVC   DWORD,=FL8'-1'
         ALGSI DWORD,-1
*MCALL #=  1410 LV= 1          RT1   CC1        NZ,NC RPI-1125 FIX ALSIX
               , ALGSI
         DS    0H
RT1_TEST1370     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1370
         LTORG 
RT1_CCL1370     DS 0H
*MEXIT #=  1410 LV= 1 RT1
         CLC   DWORD,=FL8'-2'
*MCALL #=  1411 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1371     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1371
         LTORG 
RT1_CCE1371     DS 0H
*MEXIT #=  1411 LV= 1 RT1
         MVC   DWORD,=FL8'0'
         ALGSI DWORD,0
*MCALL #=  1412 LV= 1          RT1   CC0        Z,NC
         DS    0H
RT1_TEST1372     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1372
         LTORG 
RT1_CCE1372     DS 0H
*MEXIT #=  1412 LV= 1 RT1
         CLC   DWORD,=FL8'0'
*MCALL #=  1413 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1373     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1373
         LTORG 
RT1_CCE1373     DS 0H
*MEXIT #=  1413 LV= 1 RT1
         MVC   DWORD,=X'8000000000000000'
         ALGSI DWORD,-1
*MCALL #=  1414 LV= 1          RT1   CC1       NZ,NB     RPI-1125 FIX AX
               LSI,ALGSI
         DS    0H
RT1_TEST1374     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1374
         LTORG 
RT1_CCL1374     DS 0H
*MEXIT #=  1414 LV= 1 RT1
         CLC   DWORD,=X'7FFFFFFFFFFFFFFF'
*MCALL #=  1415 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1375     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1375
         LTORG 
RT1_CCE1375     DS 0H
*MEXIT #=  1415 LV= 1 RT1
         MVC   DWORD,=FL8'0'
         ALGSI DWORD,-1
*MCALL #=  1416 LV= 1          RT1   CC3        NZ,B RPI-1125 FIX ALSI,X
                ALGSI
         DS    0H
RT1_TEST1376     BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC31376
         LTORG 
RT1_CC31376     DS 0H
*MEXIT #=  1416 LV= 1 RT1
         CLC   DWORD,=FL8'-1'
*MCALL #=  1417 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1377     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1377
         LTORG 
RT1_CCE1377     DS 0H
*MEXIT #=  1417 LV= 1 RT1
* EB80 ICMH
         SGR   R0,R0
         ICMH  R0,15,=X'12345678'
*MCALL #=  1418 LV= 1          RT1   CCH                  RPI-295 FIX
         DS    0H
RT1_TEST1378     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1378
         LTORG 
RT1_CCH1378     DS 0H
*MEXIT #=  1418 LV= 1 RT1
         CLMH  R0,15,=X'12345678'
*MCALL #=  1419 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1379     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1379
         LTORG 
RT1_CCE1379     DS 0H
*MEXIT #=  1419 LV= 1 RT1
         ICMH  R0,15,=X'00000000'
*MCALL #=  1420 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1380     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1380
         LTORG 
RT1_CCE1380     DS 0H
*MEXIT #=  1420 LV= 1 RT1
         CLMH  R0,15,=X'00000000'
*MCALL #=  1421 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1381     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1381
         LTORG 
RT1_CCE1381     DS 0H
*MEXIT #=  1421 LV= 1 RT1
         ICMH  R0,3,=X'FFFF'
*MCALL #=  1422 LV= 1          RT1   CCL                  RPI-295 TEST
         DS    0H
RT1_TEST1382     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1382
         LTORG 
RT1_CCL1382     DS 0H
*MEXIT #=  1422 LV= 1 RT1
* EB81 ICMY
         L     R1,=X'F1F2F3F4'
         ICMY  R1,9,=X'CACD'
*MCALL #=  1423 LV= 1          RT1   CCL
         DS    0H
RT1_TEST1383     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1383
         LTORG 
RT1_CCL1383     DS 0H
*MEXIT #=  1423 LV= 1 RT1
         CL    R1,=X'CAF2F3CD'
*MCALL #=  1424 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1384     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1384
         LTORG 
RT1_CCE1384     DS 0H
*MEXIT #=  1424 LV= 1 RT1
         ICMY  R1,9,=X'0000'
*MCALL #=  1425 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1385     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1385
         LTORG 
RT1_CCE1385     DS 0H
*MEXIT #=  1425 LV= 1 RT1
         CL    R1,=X'00F2F300'
*MCALL #=  1426 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1386     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1386
         LTORG 
RT1_CCE1386     DS 0H
*MEXIT #=  1426 LV= 1 RT1
         ICMY  R0,3,=X'FFFF'
*MCALL #=  1427 LV= 1          RT1   CCL                  RPI-295 TEST
         DS    0H
RT1_TEST1387     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1387
         LTORG 
RT1_CCL1387     DS 0H
*MEXIT #=  1427 LV= 1 RT1
* EB90 STMY
         LA    R1,1
         LA    R2,2
         STMY  R1,R2,PWORK
*MCALL #=  1428 LV= 1          RT1   CCE,PWORK,=A(1,2)
         DS    0H
         CLC   PWORK,=A(1,2)
RT1_TEST1388     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1388
         LTORG 
RT1_CCE1388     DS 0H
*MEXIT #=  1428 LV= 1 RT1
* EB96 LMH
         LMH   R15,R0,=A(123,456)
         STMH  R15,R0,PWORK
*MCALL #=  1429 LV= 1          RT1   CCE,PWORK,=A(123,456)
         DS    0H
         CLC   PWORK,=A(123,456)
RT1_TEST1389     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1389
         LTORG 
RT1_CCE1389     DS 0H
*MEXIT #=  1429 LV= 1 RT1
* EB98 LMY
         LMY   R15,R0,=A(123,456)
         STM   R15,R0,PWORK
*MCALL #=  1430 LV= 1          RT1   CCE,PWORK,=A(123,456)
         DS    0H
         CLC   PWORK,=A(123,456)
RT1_TEST1390     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1390
         LTORG 
RT1_CCE1390     DS 0H
*MEXIT #=  1430 LV= 1 RT1
* EBC0 TP
         TP    =X'1C'   CC0 - OK
*MCALL #=  1431 LV= 1          RT1   CC0
         DS    0H
RT1_TEST1391     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1391
         LTORG 
RT1_CCE1391     DS 0H
*MEXIT #=  1431 LV= 1 RT1
         TP    =X'1F'   CC0 - OK
*MCALL #=  1432 LV= 1          RT1   CC0
         DS    0H
RT1_TEST1392     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1392
         LTORG 
RT1_CCE1392     DS 0H
*MEXIT #=  1432 LV= 1 RT1
         TP    =X'10'   CC1 - BAD SIGN
*MCALL #=  1433 LV= 1          RT1   CC1
         DS    0H
RT1_TEST1393     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1393
         LTORG 
RT1_CCL1393     DS 0H
*MEXIT #=  1433 LV= 1 RT1
         TP    =X'FC'   CC2 - BAD DIGIT
*MCALL #=  1434 LV= 1          RT1   CC2
         DS    0H
RT1_TEST1394     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1394
         LTORG 
RT1_CCH1394     DS 0H
*MEXIT #=  1434 LV= 1 RT1
         TP    =X'FFF0' CC3 - BAD DIGIT AND SIGN
*MCALL #=  1435 LV= 1          RT1   CC3
         DS    0H
RT1_TEST1395     BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC31395
         LTORG 
RT1_CC31395     DS 0H
*MEXIT #=  1435 LV= 1 RT1
* 1-16 CC0 OK
         TP    =PL1'1'  1-8 > LONG
*MCALL #=  1436 LV= 1          RT1   CC0
         DS    0H
RT1_TEST1396     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1396
         LTORG 
RT1_CCE1396     DS 0H
*MEXIT #=  1436 LV= 1 RT1
         TP    =PL2'1'
*MCALL #=  1437 LV= 1          RT1   CC0
         DS    0H
RT1_TEST1397     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1397
         LTORG 
RT1_CCE1397     DS 0H
*MEXIT #=  1437 LV= 1 RT1
         TP    =PL3'1'
*MCALL #=  1438 LV= 1          RT1   CC0
         DS    0H
RT1_TEST1398     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1398
         LTORG 
RT1_CCE1398     DS 0H
*MEXIT #=  1438 LV= 1 RT1
         TP    =PL4'1'
*MCALL #=  1439 LV= 1          RT1   CC0
         DS    0H
RT1_TEST1399     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1399
         LTORG 
RT1_CCE1399     DS 0H
*MEXIT #=  1439 LV= 1 RT1
         TP    =PL5'1'
*MCALL #=  1440 LV= 1          RT1   CC0
         DS    0H
RT1_TEST1400     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1400
         LTORG 
RT1_CCE1400     DS 0H
*MEXIT #=  1440 LV= 1 RT1
         TP    =PL6'1'
*MCALL #=  1441 LV= 1          RT1   CC0
         DS    0H
RT1_TEST1401     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1401
         LTORG 
RT1_CCE1401     DS 0H
*MEXIT #=  1441 LV= 1 RT1
         TP    =PL7'1'
*MCALL #=  1442 LV= 1          RT1   CC0
         DS    0H
RT1_TEST1402     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1402
         LTORG 
RT1_CCE1402     DS 0H
*MEXIT #=  1442 LV= 1 RT1
         TP    =PL8'1'
*MCALL #=  1443 LV= 1          RT1   CC0
         DS    0H
RT1_TEST1403     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1403
         LTORG 
RT1_CCE1403     DS 0H
*MEXIT #=  1443 LV= 1 RT1
         TP    =PL9'1'  9-16 > BIG DECIMAL
*MCALL #=  1444 LV= 1          RT1   CC0
         DS    0H
RT1_TEST1404     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1404
         LTORG 
RT1_CCE1404     DS 0H
*MEXIT #=  1444 LV= 1 RT1
         TP    =PL10'1'
*MCALL #=  1445 LV= 1          RT1   CC0
         DS    0H
RT1_TEST1405     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1405
         LTORG 
RT1_CCE1405     DS 0H
*MEXIT #=  1445 LV= 1 RT1
         TP    =PL11'1'
*MCALL #=  1446 LV= 1          RT1   CC0
         DS    0H
RT1_TEST1406     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1406
         LTORG 
RT1_CCE1406     DS 0H
*MEXIT #=  1446 LV= 1 RT1
         TP    =PL11'1'
*MCALL #=  1447 LV= 1          RT1   CC0
         DS    0H
RT1_TEST1407     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1407
         LTORG 
RT1_CCE1407     DS 0H
*MEXIT #=  1447 LV= 1 RT1
         TP    =PL12'1'
*MCALL #=  1448 LV= 1          RT1   CC0
         DS    0H
RT1_TEST1408     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1408
         LTORG 
RT1_CCE1408     DS 0H
*MEXIT #=  1448 LV= 1 RT1
         TP    =PL13'1'
*MCALL #=  1449 LV= 1          RT1   CC0
         DS    0H
RT1_TEST1409     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1409
         LTORG 
RT1_CCE1409     DS 0H
*MEXIT #=  1449 LV= 1 RT1
         TP    =PL14'1'
*MCALL #=  1450 LV= 1          RT1   CC0
         DS    0H
RT1_TEST1410     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1410
         LTORG 
RT1_CCE1410     DS 0H
*MEXIT #=  1450 LV= 1 RT1
         TP    =PL15'1'
*MCALL #=  1451 LV= 1          RT1   CC0
         DS    0H
RT1_TEST1411     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1411
         LTORG 
RT1_CCE1411     DS 0H
*MEXIT #=  1451 LV= 1 RT1
         TP    =PL16'1'
*MCALL #=  1452 LV= 1          RT1   CC0
         DS    0H
RT1_TEST1412     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1412
         LTORG 
RT1_CCE1412     DS 0H
*MEXIT #=  1452 LV= 1 RT1
* 1-16 CC1 BAD SIGNS
         TP    =XL1'1'  1-8 > LONG
*MCALL #=  1453 LV= 1          RT1   CC1
         DS    0H
RT1_TEST1413     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1413
         LTORG 
RT1_CCL1413     DS 0H
*MEXIT #=  1453 LV= 1 RT1
         TP    =XL2'1'
*MCALL #=  1454 LV= 1          RT1   CC1
         DS    0H
RT1_TEST1414     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1414
         LTORG 
RT1_CCL1414     DS 0H
*MEXIT #=  1454 LV= 1 RT1
         TP    =XL3'1'
*MCALL #=  1455 LV= 1          RT1   CC1
         DS    0H
RT1_TEST1415     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1415
         LTORG 
RT1_CCL1415     DS 0H
*MEXIT #=  1455 LV= 1 RT1
         TP    =XL4'1'
*MCALL #=  1456 LV= 1          RT1   CC1
         DS    0H
RT1_TEST1416     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1416
         LTORG 
RT1_CCL1416     DS 0H
*MEXIT #=  1456 LV= 1 RT1
         TP    =XL5'1'
*MCALL #=  1457 LV= 1          RT1   CC1
         DS    0H
RT1_TEST1417     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1417
         LTORG 
RT1_CCL1417     DS 0H
*MEXIT #=  1457 LV= 1 RT1
         TP    =XL6'1'
*MCALL #=  1458 LV= 1          RT1   CC1
         DS    0H
RT1_TEST1418     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1418
         LTORG 
RT1_CCL1418     DS 0H
*MEXIT #=  1458 LV= 1 RT1
         TP    =XL7'1'
*MCALL #=  1459 LV= 1          RT1   CC1
         DS    0H
RT1_TEST1419     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1419
         LTORG 
RT1_CCL1419     DS 0H
*MEXIT #=  1459 LV= 1 RT1
         TP    =XL8'1'
*MCALL #=  1460 LV= 1          RT1   CC1
         DS    0H
RT1_TEST1420     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1420
         LTORG 
RT1_CCL1420     DS 0H
*MEXIT #=  1460 LV= 1 RT1
         TP    =XL9'1'  9-16 > BIG DECIMAL
*MCALL #=  1461 LV= 1          RT1   CC1
         DS    0H
RT1_TEST1421     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1421
         LTORG 
RT1_CCL1421     DS 0H
*MEXIT #=  1461 LV= 1 RT1
         TP    =XL10'1'
*MCALL #=  1462 LV= 1          RT1   CC1
         DS    0H
RT1_TEST1422     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1422
         LTORG 
RT1_CCL1422     DS 0H
*MEXIT #=  1462 LV= 1 RT1
         TP    =XL11'1'
*MCALL #=  1463 LV= 1          RT1   CC1
         DS    0H
RT1_TEST1423     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1423
         LTORG 
RT1_CCL1423     DS 0H
*MEXIT #=  1463 LV= 1 RT1
         TP    =XL11'1'
*MCALL #=  1464 LV= 1          RT1   CC1
         DS    0H
RT1_TEST1424     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1424
         LTORG 
RT1_CCL1424     DS 0H
*MEXIT #=  1464 LV= 1 RT1
         TP    =XL12'1'
*MCALL #=  1465 LV= 1          RT1   CC1
         DS    0H
RT1_TEST1425     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1425
         LTORG 
RT1_CCL1425     DS 0H
*MEXIT #=  1465 LV= 1 RT1
         TP    =XL13'1'
*MCALL #=  1466 LV= 1          RT1   CC1
         DS    0H
RT1_TEST1426     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1426
         LTORG 
RT1_CCL1426     DS 0H
*MEXIT #=  1466 LV= 1 RT1
         TP    =XL14'1'
*MCALL #=  1467 LV= 1          RT1   CC1
         DS    0H
RT1_TEST1427     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1427
         LTORG 
RT1_CCL1427     DS 0H
*MEXIT #=  1467 LV= 1 RT1
         TP    =XL15'1'
*MCALL #=  1468 LV= 1          RT1   CC1
         DS    0H
RT1_TEST1428     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1428
         LTORG 
RT1_CCL1428     DS 0H
*MEXIT #=  1468 LV= 1 RT1
         TP    =XL16'1'
*MCALL #=  1469 LV= 1          RT1   CC1
         DS    0H
RT1_TEST1429     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1429
         LTORG 
RT1_CCL1429     DS 0H
*MEXIT #=  1469 LV= 1 RT1
* 1-16 CC2 BAD DIGIT
         TP    =XL1'AC'  1-8 > LONG
*MCALL #=  1470 LV= 1          RT1   CC2
         DS    0H
RT1_TEST1430     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1430
         LTORG 
RT1_CCH1430     DS 0H
*MEXIT #=  1470 LV= 1 RT1
         TP    =XL2'AC'
*MCALL #=  1471 LV= 1          RT1   CC2
         DS    0H
RT1_TEST1431     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1431
         LTORG 
RT1_CCH1431     DS 0H
*MEXIT #=  1471 LV= 1 RT1
         TP    =XL3'AC'
*MCALL #=  1472 LV= 1          RT1   CC2
         DS    0H
RT1_TEST1432     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1432
         LTORG 
RT1_CCH1432     DS 0H
*MEXIT #=  1472 LV= 1 RT1
         TP    =XL4'AC'
*MCALL #=  1473 LV= 1          RT1   CC2
         DS    0H
RT1_TEST1433     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1433
         LTORG 
RT1_CCH1433     DS 0H
*MEXIT #=  1473 LV= 1 RT1
         TP    =XL5'AC'
*MCALL #=  1474 LV= 1          RT1   CC2
         DS    0H
RT1_TEST1434     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1434
         LTORG 
RT1_CCH1434     DS 0H
*MEXIT #=  1474 LV= 1 RT1
         TP    =XL6'AC'
*MCALL #=  1475 LV= 1          RT1   CC2
         DS    0H
RT1_TEST1435     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1435
         LTORG 
RT1_CCH1435     DS 0H
*MEXIT #=  1475 LV= 1 RT1
         TP    =XL7'AC'
*MCALL #=  1476 LV= 1          RT1   CC2
         DS    0H
RT1_TEST1436     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1436
         LTORG 
RT1_CCH1436     DS 0H
*MEXIT #=  1476 LV= 1 RT1
         TP    =XL8'AC'
*MCALL #=  1477 LV= 1          RT1   CC2
         DS    0H
RT1_TEST1437     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1437
         LTORG 
RT1_CCH1437     DS 0H
*MEXIT #=  1477 LV= 1 RT1
         TP    =XL9'AC'  9-16 > BIG DECIMAL
*MCALL #=  1478 LV= 1          RT1   CC2
         DS    0H
RT1_TEST1438     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1438
         LTORG 
RT1_CCH1438     DS 0H
*MEXIT #=  1478 LV= 1 RT1
         TP    =XL10'AC'
*MCALL #=  1479 LV= 1          RT1   CC2
         DS    0H
RT1_TEST1439     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1439
         LTORG 
RT1_CCH1439     DS 0H
*MEXIT #=  1479 LV= 1 RT1
         TP    =XL11'AC'
*MCALL #=  1480 LV= 1          RT1   CC2
         DS    0H
RT1_TEST1440     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1440
         LTORG 
RT1_CCH1440     DS 0H
*MEXIT #=  1480 LV= 1 RT1
         TP    =XL11'AC'
*MCALL #=  1481 LV= 1          RT1   CC2
         DS    0H
RT1_TEST1441     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1441
         LTORG 
RT1_CCH1441     DS 0H
*MEXIT #=  1481 LV= 1 RT1
         TP    =XL12'AC'
*MCALL #=  1482 LV= 1          RT1   CC2
         DS    0H
RT1_TEST1442     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1442
         LTORG 
RT1_CCH1442     DS 0H
*MEXIT #=  1482 LV= 1 RT1
         TP    =XL13'AC'
*MCALL #=  1483 LV= 1          RT1   CC2
         DS    0H
RT1_TEST1443     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1443
         LTORG 
RT1_CCH1443     DS 0H
*MEXIT #=  1483 LV= 1 RT1
         TP    =XL14'AC'
*MCALL #=  1484 LV= 1          RT1   CC2
         DS    0H
RT1_TEST1444     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1444
         LTORG 
RT1_CCH1444     DS 0H
*MEXIT #=  1484 LV= 1 RT1
         TP    =XL15'AC'
*MCALL #=  1485 LV= 1          RT1   CC2
         DS    0H
RT1_TEST1445     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1445
         LTORG 
RT1_CCH1445     DS 0H
*MEXIT #=  1485 LV= 1 RT1
         TP    =XL16'AC'
*MCALL #=  1486 LV= 1          RT1   CC2
         DS    0H
RT1_TEST1446     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1446
         LTORG 
RT1_CCH1446     DS 0H
*MEXIT #=  1486 LV= 1 RT1
* 1-16 CC3 BAD DIGIT AND SIGN
         TP    =XL1'A1'  1-8 > LONG
*MCALL #=  1487 LV= 1          RT1   CC3
         DS    0H
RT1_TEST1447     BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC31447
         LTORG 
RT1_CC31447     DS 0H
*MEXIT #=  1487 LV= 1 RT1
         TP    =XL2'A1'
*MCALL #=  1488 LV= 1          RT1   CC3
         DS    0H
RT1_TEST1448     BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC31448
         LTORG 
RT1_CC31448     DS 0H
*MEXIT #=  1488 LV= 1 RT1
         TP    =XL3'A1'
*MCALL #=  1489 LV= 1          RT1   CC3
         DS    0H
RT1_TEST1449     BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC31449
         LTORG 
RT1_CC31449     DS 0H
*MEXIT #=  1489 LV= 1 RT1
         TP    =XL4'A1'
*MCALL #=  1490 LV= 1          RT1   CC3
         DS    0H
RT1_TEST1450     BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC31450
         LTORG 
RT1_CC31450     DS 0H
*MEXIT #=  1490 LV= 1 RT1
         TP    =XL5'A1'
*MCALL #=  1491 LV= 1          RT1   CC3
         DS    0H
RT1_TEST1451     BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC31451
         LTORG 
RT1_CC31451     DS 0H
*MEXIT #=  1491 LV= 1 RT1
         TP    =XL6'A1'
*MCALL #=  1492 LV= 1          RT1   CC3
         DS    0H
RT1_TEST1452     BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC31452
         LTORG 
RT1_CC31452     DS 0H
*MEXIT #=  1492 LV= 1 RT1
         TP    =XL7'A1'
*MCALL #=  1493 LV= 1          RT1   CC3
         DS    0H
RT1_TEST1453     BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC31453
         LTORG 
RT1_CC31453     DS 0H
*MEXIT #=  1493 LV= 1 RT1
         TP    =XL8'A1'
*MCALL #=  1494 LV= 1          RT1   CC3
         DS    0H
RT1_TEST1454     BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC31454
         LTORG 
RT1_CC31454     DS 0H
*MEXIT #=  1494 LV= 1 RT1
         TP    =XL9'A1'  9-16 > BIG DECIMAL
*MCALL #=  1495 LV= 1          RT1   CC3
         DS    0H
RT1_TEST1455     BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC31455
         LTORG 
RT1_CC31455     DS 0H
*MEXIT #=  1495 LV= 1 RT1
         TP    =XL10'A1'
*MCALL #=  1496 LV= 1          RT1   CC3
         DS    0H
RT1_TEST1456     BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC31456
         LTORG 
RT1_CC31456     DS 0H
*MEXIT #=  1496 LV= 1 RT1
         TP    =XL11'A1'
*MCALL #=  1497 LV= 1          RT1   CC3
         DS    0H
RT1_TEST1457     BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC31457
         LTORG 
RT1_CC31457     DS 0H
*MEXIT #=  1497 LV= 1 RT1
         TP    =XL11'A1'
*MCALL #=  1498 LV= 1          RT1   CC3
         DS    0H
RT1_TEST1458     BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC31458
         LTORG 
RT1_CC31458     DS 0H
*MEXIT #=  1498 LV= 1 RT1
         TP    =XL12'A1'
*MCALL #=  1499 LV= 1          RT1   CC3
         DS    0H
RT1_TEST1459     BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC31459
         LTORG 
RT1_CC31459     DS 0H
*MEXIT #=  1499 LV= 1 RT1
         TP    =XL13'A1'
*MCALL #=  1500 LV= 1          RT1   CC3
         DS    0H
RT1_TEST1460     BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC31460
         LTORG 
RT1_CC31460     DS 0H
*MEXIT #=  1500 LV= 1 RT1
         TP    =XL14'A1'
*MCALL #=  1501 LV= 1          RT1   CC3
         DS    0H
RT1_TEST1461     BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC31461
         LTORG 
RT1_CC31461     DS 0H
*MEXIT #=  1501 LV= 1 RT1
         TP    =XL15'A1'
*MCALL #=  1502 LV= 1          RT1   CC3
         DS    0H
RT1_TEST1462     BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC31462
         LTORG 
RT1_CC31462     DS 0H
*MEXIT #=  1502 LV= 1 RT1
         TP    =XL16'A1'
*MCALL #=  1503 LV= 1          RT1   CC3
         DS    0H
RT1_TEST1463     BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC31463
         LTORG 
RT1_CC31463     DS 0H
*MEXIT #=  1503 LV= 1 RT1
* EC44 BRXHG
         LMG   R1,R3,=AD(2,-1,0)
         BRXHG R1,R2,BRXHG2
*MCALL #=  1504 LV= 1 BRXHG1   RT1   ABORT
BRXHG1   DS    0H
         B      RT1_ABORT
*MEXIT #=  1504 LV= 1 RT1
BRXHG2   EQU   *
         CLG   R1,=AD(1)
*MCALL #=  1505 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1465     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1465
         LTORG 
RT1_CCE1465     DS 0H
*MEXIT #=  1505 LV= 1 RT1
         BRXHG R1,R2,BRXHG1
         CLG   R1,=AD(0)
*MCALL #=  1506 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1466     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1466
         LTORG 
RT1_CCE1466     DS 0H
*MEXIT #=  1506 LV= 1 RT1
         LMG   R1,R3,=AD(2,-10,-1)
         BRXHG R1,R3,BRXHG3
*MCALL #=  1507 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=  1507 LV= 1 RT1
BRXHG3   EQU   *
         CLG   R1,=AD(1)
*MCALL #=  1508 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1468     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1468
         LTORG 
RT1_CCE1468     DS 0H
*MEXIT #=  1508 LV= 1 RT1
         BRXHG R1,R3,BRXHG4
*MCALL #=  1509 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=  1509 LV= 1 RT1
BRXHG4   EQU   *
         CLG   R1,=AD(0)
*MCALL #=  1510 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1470     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1470
         LTORG 
RT1_CCE1470     DS 0H
*MEXIT #=  1510 LV= 1 RT1
         BRXHG R1,R3,BRXHG1
         CLG   R1,=FL8'-1'
*MCALL #=  1511 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1471     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1471
         LTORG 
RT1_CCE1471     DS 0H
*MEXIT #=  1511 LV= 1 RT1
* EC45 BRXLG
         LMG   R1,R3,=AD(1,1,2)
         BRXLG R1,R2,BRXLG2
*MCALL #=  1512 LV= 1 BRXLG1   RT1   ABORT
BRXLG1   DS    0H
         B      RT1_ABORT
*MEXIT #=  1512 LV= 1 RT1
BRXLG2   EQU   *
         CLG   R1,=AD(2)
*MCALL #=  1513 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1473     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1473
         LTORG 
RT1_CCE1473     DS 0H
*MEXIT #=  1513 LV= 1 RT1
         BRXLG R1,R2,BRXLG1
         CLG   R1,=AD(3)
*MCALL #=  1514 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1474     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1474
         LTORG 
RT1_CCE1474     DS 0H
*MEXIT #=  1514 LV= 1 RT1
         LMG   R1,R3,=AD(0,-10,1)
         BRXLG R1,R3,BRXLG3
*MCALL #=  1515 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=  1515 LV= 1 RT1
BRXLG3   EQU   *
         CLG   R1,=AD(1)
*MCALL #=  1516 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1476     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1476
         LTORG 
RT1_CCE1476     DS 0H
*MEXIT #=  1516 LV= 1 RT1
         BRXLG R1,R3,BRXLG1
         CLG   R1,=FL8'2'
*MCALL #=  1517 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1477     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1477
         LTORG 
RT1_CCE1477     DS 0H
*MEXIT #=  1517 LV= 1 RT1
* EF   LMD
         LMD   R15,R0,LMD1,LMD2           RPI-844
         CLG   R15,=X'0123456789ABCDEF'
*MCALL #=  1518 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1478     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1478
         LTORG 
RT1_CCE1478     DS 0H
*MEXIT #=  1518 LV= 1 RT1
         CLG   R0,=X'0123456789ABCDEF'
*MCALL #=  1519 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1479     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1479
         LTORG 
RT1_CCE1479     DS 0H
*MEXIT #=  1519 LV= 1 RT1
* F0   SRP
         ZAP   PWORK,=P'123'
         SRP   PWORK,1,0
*MCALL #=  1520 LV= 1          RT1   CCH
         DS    0H
RT1_TEST1480     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1480
         LTORG 
RT1_CCH1480     DS 0H
*MEXIT #=  1520 LV= 1 RT1
         CP    PWORK+5(3),=P'1230'
*MCALL #=  1521 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1481     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1481
         LTORG 
RT1_CCE1481     DS 0H
*MEXIT #=  1521 LV= 1 RT1
         ZAP   PWORK,=P'123'
*MCALL #=  1522 LV= 1          RT1   CCH
         DS    0H
RT1_TEST1482     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1482
         LTORG 
RT1_CCH1482     DS 0H
*MEXIT #=  1522 LV= 1 RT1
         LA    R3,1
         SRP   PWORK,0(R3),0
         CP    PWORK+5(3),=P'1230'
*MCALL #=  1523 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1483     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1483
         LTORG 
RT1_CCE1483     DS 0H
*MEXIT #=  1523 LV= 1 RT1
         ZAP   PWORK,=P'12350'
         SRP   PWORK,64-2,5
*MCALL #=  1524 LV= 1          RT1   CCH
         DS    0H
RT1_TEST1484     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1484
         LTORG 
RT1_CCH1484     DS 0H
*MEXIT #=  1524 LV= 1 RT1
         CP    PWORK+5(3),=P'124'
*MCALL #=  1525 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1485     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1485
         LTORG 
RT1_CCE1485     DS 0H
*MEXIT #=  1525 LV= 1 RT1
         ZAP   PWORK,=P'12349'
         SRP   PWORK,64-2,5
*MCALL #=  1526 LV= 1          RT1   CCH
         DS    0H
RT1_TEST1486     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1486
         LTORG 
RT1_CCH1486     DS 0H
*MEXIT #=  1526 LV= 1 RT1
         CP    PWORK+5(3),=P'123'
*MCALL #=  1527 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1487     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1487
         LTORG 
RT1_CCE1487     DS 0H
*MEXIT #=  1527 LV= 1 RT1
         ZAP   PWORK,=P'12350'
         LHI   R1,-2               RPI-820 TEST NEG REG
         SRP   PWORK,0(R1),5       RPI-820
*MCALL #=  1528 LV= 1          RT1   CCH
         DS    0H
RT1_TEST1488     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1488
         LTORG 
RT1_CCH1488     DS 0H
*MEXIT #=  1528 LV= 1 RT1
         CP    PWORK+5(3),=P'124'
*MCALL #=  1529 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1489     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1489
         LTORG 
RT1_CCE1489     DS 0H
*MEXIT #=  1529 LV= 1 RT1
         ZAP   PWORK,=P'12349'
         LHI   R1,-2               RPI-820 TEST NEG REG
         SRP   PWORK,0(R1),5       RPI-820
*MCALL #=  1530 LV= 1          RT1   CCH
         DS    0H
RT1_TEST1490     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1490
         LTORG 
RT1_CCH1490     DS 0H
*MEXIT #=  1530 LV= 1 RT1
         CP    PWORK+5(3),=P'123'
*MCALL #=  1531 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1491     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1491
         LTORG 
RT1_CCE1491     DS 0H
*MEXIT #=  1531 LV= 1 RT1
*MCALL #=  1532 LV= 1          ESPIE SET,ESPIE_EXIT,7,PARAM=SRP1
        LA     15,SRP1
        IPM    0  GET CURRENT PGM MASK
        SPM    0 TURN ON ANY MASKS REQUIRED
        L      0,=B'00000001000000000000000000000000'
        LA     1,ESPIE_EXIT
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=  1532 LV= 1 ESPIE
         ZAP   PWORK,=X'40'
*MCALL #=  1533 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=  1533 LV= 1 RT1
*MCALL #=  1534 LV= 1 SRP1     ESPIE RESET
SRP1     DS    0H
        SR     15,15
        SR     1,1
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=  1534 LV= 1 ESPIE
         STFPC FPCREG
         CLI   FPCDXC,X'00' PD DATA EXCEPTION
*MCALL #=  1535 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1493     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1493
         LTORG 
RT1_CCE1493     DS 0H
*MEXIT #=  1535 LV= 1 RT1
*MCALL #=  1536 LV= 1          WTO   'ESPIE PD DATA EXCEPTION OK'
         BRAS  1,*+(WTO#1536_EOT-*+1)/2*2
         DC    AL2(WTO#1536_EOT-*,0),C'ESPIE PD DATA EXCEPTION OK'
WTO#1536_EOT     EQU *
         SVC   35
*MEXIT #=  1536 LV= 1 WTO
* F1   MVO
         ZAP   PWORK,=P'-1'
         MVO   PWORK,=X'1234'
         CP    PWORK+5(3),=P'-1234'
*MCALL #=  1537 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1494     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1494
         LTORG 
RT1_CCE1494     DS 0H
*MEXIT #=  1537 LV= 1 RT1
         ZAP   PWORK,=P'1'
         MVO   PWORK,=X'123'
         CP    PWORK+5(3),=P'123'
*MCALL #=  1538 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1495     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1495
         LTORG 
RT1_CCE1495     DS 0H
*MEXIT #=  1538 LV= 1 RT1
* F2   PACK
         PACK  PWORK,=X'F1F2F3'
         CLC   PWORK+6(2),=X'123F'
*MCALL #=  1539 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1496     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1496
         LTORG 
RT1_CCE1496     DS 0H
*MEXIT #=  1539 LV= 1 RT1
         CP    PWORK+6(2),=P'123'
*MCALL #=  1540 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1497     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1497
         LTORG 
RT1_CCE1497     DS 0H
*MEXIT #=  1540 LV= 1 RT1
         PACK  PWORK,=X'F1F2C3'
         CLC   PWORK+6(2),=X'123C'
*MCALL #=  1541 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1498     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1498
         LTORG 
RT1_CCE1498     DS 0H
*MEXIT #=  1541 LV= 1 RT1
         CP    PWORK+6(2),=P'123'
*MCALL #=  1542 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1499     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1499
         LTORG 
RT1_CCE1499     DS 0H
*MEXIT #=  1542 LV= 1 RT1
         PACK  PWORK,=X'F1F2D3'
         CLC   PWORK+6(2),=X'123D'
*MCALL #=  1543 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1500     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1500
         LTORG 
RT1_CCE1500     DS 0H
*MEXIT #=  1543 LV= 1 RT1
         CP    PWORK+6(2),=P'-123'
*MCALL #=  1544 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1501     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1501
         LTORG 
RT1_CCE1501     DS 0H
*MEXIT #=  1544 LV= 1 RT1
         PACK  PWORK,=X'3132F3'    RPI-844 (3>F 3 CAUSED 0C7)
         CP    PWORK+6(2),=X'123F'
*MCALL #=  1545 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1502     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1502
         LTORG 
RT1_CCE1502     DS 0H
*MEXIT #=  1545 LV= 1 RT1
         CP    PWORK+6(2),=P'123'
*MCALL #=  1546 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1503     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1503
         LTORG 
RT1_CCE1503     DS 0H
*MEXIT #=  1546 LV= 1 RT1
         PACK  PWORK,=X'3132B3'
         CLC   PWORK+6(2),=X'123B'
*MCALL #=  1547 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1504     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1504
         LTORG 
RT1_CCE1504     DS 0H
*MEXIT #=  1547 LV= 1 RT1
         CP    PWORK+6(2),=P'-123'
*MCALL #=  1548 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1505     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1505
         LTORG 
RT1_CCE1505     DS 0H
*MEXIT #=  1548 LV= 1 RT1
* F3   UNPK
         UNPK  PWORK(4),=P'1234'
         CLC   PWORK(3),=C'123'
*MCALL #=  1549 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1506     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1506
         LTORG 
RT1_CCE1506     DS 0H
*MEXIT #=  1549 LV= 1 RT1
         CLI   PWORK+3,X'C4'
*MCALL #=  1550 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1507     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1507
         LTORG 
RT1_CCE1507     DS 0H
*MEXIT #=  1550 LV= 1 RT1
         UNPK  PWORK(3),=X'123F'
         CLC   PWORK(2),=C'12'
*MCALL #=  1551 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1508     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1508
         LTORG 
RT1_CCE1508     DS 0H
*MEXIT #=  1551 LV= 1 RT1
         CLI   PWORK+2,X'F3'
*MCALL #=  1552 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1509     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1509
         LTORG 
RT1_CCE1509     DS 0H
*MEXIT #=  1552 LV= 1 RT1
         UNPK  PWORK(3),=P'123'
         CLC   PWORK(2),=C'12'
*MCALL #=  1553 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1510     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1510
         LTORG 
RT1_CCE1510     DS 0H
*MEXIT #=  1553 LV= 1 RT1
         CLI   PWORK+2,X'C3'
*MCALL #=  1554 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1511     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1511
         LTORG 
RT1_CCE1511     DS 0H
*MEXIT #=  1554 LV= 1 RT1
         UNPK  PWORK(3),=P'-123'
         CLC   PWORK(2),=C'12'
*MCALL #=  1555 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1512     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1512
         LTORG 
RT1_CCE1512     DS 0H
*MEXIT #=  1555 LV= 1 RT1
         CLI   PWORK+2,X'D3'
*MCALL #=  1556 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1513     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1513
         LTORG 
RT1_CCE1513     DS 0H
*MEXIT #=  1556 LV= 1 RT1
         UNPK  PWORK(4),=X'012343'
         CLC   PWORK(3),=C'123'
*MCALL #=  1557 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1514     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1514
         LTORG 
RT1_CCE1514     DS 0H
*MEXIT #=  1557 LV= 1 RT1
         CLI   PWORK+3,X'34'
*MCALL #=  1558 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1515     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1515
         LTORG 
RT1_CCE1515     DS 0H
*MEXIT #=  1558 LV= 1 RT1
         UNPK  PWORK(3),=X'123B'
         CLC   PWORK(2),=C'12'
*MCALL #=  1559 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1516     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1516
         LTORG 
RT1_CCE1516     DS 0H
*MEXIT #=  1559 LV= 1 RT1
         CLI   PWORK+2,X'B3'
*MCALL #=  1560 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1517     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1517
         LTORG 
RT1_CCE1517     DS 0H
*MEXIT #=  1560 LV= 1 RT1
* F8   ZAP
         ZAP   PWORK,=P'0'
*MCALL #=  1561 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1518     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1518
         LTORG 
RT1_CCE1518     DS 0H
*MEXIT #=  1561 LV= 1 RT1
         CLC   PWORK,=A(0,X'C')
*MCALL #=  1562 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1519     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1519
         LTORG 
RT1_CCE1519     DS 0H
*MEXIT #=  1562 LV= 1 RT1
         ZAP   PWORK,=P'1'
*MCALL #=  1563 LV= 1          RT1   CCH
         DS    0H
RT1_TEST1520     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1520
         LTORG 
RT1_CCH1520     DS 0H
*MEXIT #=  1563 LV= 1 RT1
         ZAP   PWORK,=P'-1'
*MCALL #=  1564 LV= 1          RT1   CCL
         DS    0H
RT1_TEST1521     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1521
         LTORG 
RT1_CCL1521     DS 0H
*MEXIT #=  1564 LV= 1 RT1
*MCALL #=  1565 LV= 1          ESPIE SET,ESPIE_EXIT,7,PARAM=ZAP1
        LA     15,ZAP1
        IPM    0  GET CURRENT PGM MASK
        SPM    0 TURN ON ANY MASKS REQUIRED
        L      0,=B'00000001000000000000000000000000'
        LA     1,ESPIE_EXIT
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=  1565 LV= 1 ESPIE
         ZAP   PWORK,=X'00'
*MCALL #=  1566 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=  1566 LV= 1 RT1
*MCALL #=  1567 LV= 1 ZAP1     ESPIE RESET
ZAP1     DS    0H
        SR     15,15
        SR     1,1
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=  1567 LV= 1 ESPIE
*MCALL #=  1568 LV= 1          WTO   'ESPIE FOR PACKED DATA EXCEPTION OX
               K'
         BRAS  1,*+(WTO#1568_EOT-*+1)/2*2
         DC    AL2(WTO#1568_EOT-*,0),C'ESPIE FOR PACKED DATA EXCEPTION X
               OK'
WTO#1568_EOT     EQU *
         SVC   35
*MEXIT #=  1568 LV= 1 WTO
* F9   CP
         CP    =P'1',=P'1'
*MCALL #=  1569 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1523     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1523
         LTORG 
RT1_CCE1523     DS 0H
*MEXIT #=  1569 LV= 1 RT1
         CP    =P'1',=P'2'
*MCALL #=  1570 LV= 1          RT1   CCL
         DS    0H
RT1_TEST1524     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1524
         LTORG 
RT1_CCL1524     DS 0H
*MEXIT #=  1570 LV= 1 RT1
         CP    =P'3',=P'2'
*MCALL #=  1571 LV= 1          RT1   CCH
         DS    0H
RT1_TEST1525     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1525
         LTORG 
RT1_CCH1525     DS 0H
*MEXIT #=  1571 LV= 1 RT1
         CP    =P'-2',=P'1'
*MCALL #=  1572 LV= 1          RT1   CCL
         DS    0H
RT1_TEST1526     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1526
         LTORG 
RT1_CCL1526     DS 0H
*MEXIT #=  1572 LV= 1 RT1
         CP    =P'3',=P'-1'
*MCALL #=  1573 LV= 1          RT1   CCH
         DS    0H
RT1_TEST1527     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1527
         LTORG 
RT1_CCH1527     DS 0H
*MEXIT #=  1573 LV= 1 RT1
* FA   AP
         ZAP   PWORK,=P'0'
         AP    PWORK,=P'1'
*MCALL #=  1574 LV= 1          RT1   CCH
         DS    0H
RT1_TEST1528     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1528
         LTORG 
RT1_CCH1528     DS 0H
*MEXIT #=  1574 LV= 1 RT1
         CLC   PWORK,=A(0,X'1C')
*MCALL #=  1575 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1529     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1529
         LTORG 
RT1_CCE1529     DS 0H
*MEXIT #=  1575 LV= 1 RT1
         AP    PWORK,=P'-2'
*MCALL #=  1576 LV= 1          RT1   CCL
         DS    0H
RT1_TEST1530     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1530
         LTORG 
RT1_CCL1530     DS 0H
*MEXIT #=  1576 LV= 1 RT1
         CLC   PWORK,=A(0,X'1D')
*MCALL #=  1577 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1531     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1531
         LTORG 
RT1_CCE1531     DS 0H
*MEXIT #=  1577 LV= 1 RT1
         ZAP   PL1,=P'1'
         AP    PL1,=P'-1'
         CP    PL1,=P'0'
*MCALL #=  1578 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1532     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1532
         LTORG 
RT1_CCE1532     DS 0H
*MEXIT #=  1578 LV= 1 RT1
         ZAP   PWORK16,=PL16'1234567890123456789012345678901'
         AP    PWORK16,=PL16'0000000001000000000100000000011'
         CP    PWORK16,=PL16'1234567891123456789112345678912'
*MCALL #=  1579 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1533     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1533
         LTORG 
RT1_CCE1533     DS 0H
*MEXIT #=  1579 LV= 1 RT1
         ZAP   PWORK,=X'999999999999999C'
*MCALL #=  1580 LV= 1          ESPIE SET,ESPIE_EXIT,10,PARAM=AP1
        LA     15,AP1
        IPM    0  GET CURRENT PGM MASK
        OILH   0,1024
        SPM    0 TURN ON ANY MASKS REQUIRED
        L      0,=B'00000000001000000000000000000000'
        LA     1,ESPIE_EXIT
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=  1580 LV= 1 ESPIE
         AP    PWORK,=P'1'
*MCALL #=  1581 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=  1581 LV= 1 RT1
*MCALL #=  1582 LV= 1 AP1      ESPIE RESET
AP1      DS    0H
        SR     15,15
        SR     1,1
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=  1582 LV= 1 ESPIE
*MCALL #=  1583 LV= 1          WTO   'ESPIE FOR PACKED OVERFLOW OK'
         BRAS  1,*+(WTO#1583_EOT-*+1)/2*2
         DC    AL2(WTO#1583_EOT-*,0),C'ESPIE FOR PACKED OVERFLOW OK'
WTO#1583_EOT     EQU *
         SVC   35
*MEXIT #=  1583 LV= 1 WTO
* FB   SP
         ZAP   PWORK,=P'0'
         SP    PWORK,=P'1'
*MCALL #=  1584 LV= 1          RT1   CCL
         DS    0H
RT1_TEST1535     BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL1535
         LTORG 
RT1_CCL1535     DS 0H
*MEXIT #=  1584 LV= 1 RT1
         CLC   PWORK,=A(0,X'1D')
*MCALL #=  1585 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1536     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1536
         LTORG 
RT1_CCE1536     DS 0H
*MEXIT #=  1585 LV= 1 RT1
         SP    PWORK,=P'-2'
*MCALL #=  1586 LV= 1          RT1   CCH
         DS    0H
RT1_TEST1537     BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH1537
         LTORG 
RT1_CCH1537     DS 0H
*MEXIT #=  1586 LV= 1 RT1
         CLC   PWORK,=A(0,X'1C')
*MCALL #=  1587 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1538     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1538
         LTORG 
RT1_CCE1538     DS 0H
*MEXIT #=  1587 LV= 1 RT1
         ZAP   PWORK,=X'999999999999999D'
*MCALL #=  1588 LV= 1          ESPIE SET,ESPIE_EXIT,10,PARAM=SP1
        LA     15,SP1
        IPM    0  GET CURRENT PGM MASK
        OILH   0,1024
        SPM    0 TURN ON ANY MASKS REQUIRED
        L      0,=B'00000000001000000000000000000000'
        LA     1,ESPIE_EXIT
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=  1588 LV= 1 ESPIE
         SP    PWORK,=P'1'
*MCALL #=  1589 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=  1589 LV= 1 RT1
*MCALL #=  1590 LV= 1 SP1      ESPIE RESET
SP1      DS    0H
        SR     15,15
        SR     1,1
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=  1590 LV= 1 ESPIE
* FC   MP
         ZAP   PWORK,=P'2'
         MP    PWORK,=P'123412341234'
         CP    PWORK,=P'246824682468'
*MCALL #=  1591 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1540     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1540
         LTORG 
RT1_CCE1540     DS 0H
*MEXIT #=  1591 LV= 1 RT1
         ZAP   PWORK,=P'-2'
         MP    PWORK,=P'123412341234'
         CP    PWORK,=P'-246824682468'
*MCALL #=  1592 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1541     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1541
         LTORG 
RT1_CCE1541     DS 0H
*MEXIT #=  1592 LV= 1 RT1
* FD   DP
         ZAP   PWORK,=P'100'
         DP    PWORK,=PL2'33'
         CP    PWORK(6),=P'3'
*MCALL #=  1593 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1542     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1542
         LTORG 
RT1_CCE1542     DS 0H
*MEXIT #=  1593 LV= 1 RT1
         CP    PWORK+6(2),=P'1'
*MCALL #=  1594 LV= 1          RT1   CCE
         DS    0H
RT1_TEST1543     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1543
         LTORG 
RT1_CCE1543     DS 0H
*MEXIT #=  1594 LV= 1 RT1
*MCALL #=  1595 LV= 1          ESPIE SET,ESPIE_EXIT,11,PARAM=DP1
        LA     15,DP1
        IPM    0  GET CURRENT PGM MASK
        SPM    0 TURN ON ANY MASKS REQUIRED
        L      0,=B'00000000000100000000000000000000'
        LA     1,ESPIE_EXIT
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=  1595 LV= 1 ESPIE
         ZAP   PWORK,=P'1'
         DP    PWORK,=P'0'
*MCALL #=  1596 LV= 1          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=  1596 LV= 1 RT1
*MCALL #=  1597 LV= 1 DP1      ESPIE RESET
DP1      DS    0H
        SR     15,15
        SR     1,1
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=  1597 LV= 1 ESPIE
*MCALL #=  1598 LV= 1          WTO   'ESPIE FOR PACKED DIVIDE OK'
         BRAS  1,*+(WTO#1598_EOT-*+1)/2*2
         DC    AL2(WTO#1598_EOT-*,0),C'ESPIE FOR PACKED DIVIDE OK'
WTO#1598_EOT     EQU *
         SVC   35
*MEXIT #=  1598 LV= 1 WTO
* END
*MCALL #=  1599 LV= 1          RT1   END
         B      RT1_END
*MEXIT #=  1599 LV= 1 RT1
*MCALL #=  1600 LV= 1          IHAEPIE 
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
*MEXIT #=  1600 LV= 1 IHAEPIE
*MCALL #=  1601 LV= 1          IHASDWA 
SDWA     DSECT 
SDWAPARM DS    A    ESTAE PARM ADDRESS
SDWAABSS DS    0BL4 COMPLETION CODE
SDWACMPF DS    B    COMPLETION CODE FLAGS
SDWACMPC DS    BL3  COMPLETION CODE (FIRST 12 BITS SYS,LAST 12 USER)
         ORG   SDWA+X'68'
SDWAEC1  DS    XL8  EXTENDED CONTROL PSW AT ERROR
         ORG   SDWA+X'170'
SDWAXPAD DS    A    ADDR OF POINTERS EXTENSION SDWAPTRS
SDWAPTRS DSECT 
         ORG   SDWAPTRS+X'18'
SDWAXEME DS    A    ADDR OF 64 BIT REGISTER INFO
SDWARC4  DSECT 
SDWAG64  DS    16XL8 16 - 64 BIT GPRS AT ERROR
*MEXIT #=  1601 LV= 1 IHASDWA
         END 
