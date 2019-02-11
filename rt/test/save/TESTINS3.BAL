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
* 2008-03-03 DSH         Initial version                            *
* 2008-03-03 DSH RPI-817 Copy from TESTINS2 and add z10 instruction *
*                        tests                                      *
* 2008-03-03 DSH RPI-817 Add z10 COMP and TRAP   B960-EC73 using    *
*                        TESTCAT macro                              *
* 2008-03-03 DSH RPI-817 Add z10 COMP and BRANCH EC64-ECFF using    *
*                        using TESTCAB macro                        *
* 2008-03-08 DSH RPI-817 Add z10 miscellaneous problem state        *
*                        instruction tests                          *
* 2008-03-15 DSH RPI-822 Correct BRC 1,*-4 to BRC 1,*-4 for         *
*                        TRTE/TRTRE                                 *
* 2008-04-22 DSH RPI-833 Add string quotes for HLASM compatibility  *
* 2008-06-09 DSH RPI-859 Changes for z10/HLASM assembly and         *
*                        execution                                  *
*          1) Change MVCOS to issue spec. execpt. for overlap (ext.)*
*          2) Change CLHHSI =H'-1',-1 TO CLHHSI =H'-1',X'FFFF'      *
*          3) Correct ALSI, ALGSI tests for sign extended I2        *
*          4) Add additional ASI and AGSI tests for neg. I2         *
*          5) Change TESTCAT for positive immed. values for HLASM   *
*             and change CGIT,CLGIT,CIT,CLFIT immed. length to 16   *
*          6) Change TESTCAB for positive immed. values for HLASM   *
* 2008-06-20 DSH RPI-845 Change EPIED to IHAEPIE                    *
*                        (Note ESPIEPSW offset change)              *
* 2008-06-21 DSH RPI-845 Change ESTAD to IHASDWA and remove         *
*                        ESTAPSW ref.                               *
*********************************************************************
* RT1 macro used to automate code generated for mainline and test   *
* PSW CC routines. The macros define new base registers for each    *
* test so they can extend for any length.                           *
*                                                                   *
* See TESTINS1 for assembly test of all POP instructions.           *
* See TESTINS2 for unit test of problem state instructions up to z9 *
* See TESTFP1  for HFP and BFP floating point instructions tests    *
* See TESTDFP1 for DFP floating point instructions                  *
*********************************************************************
         PRINT DATA
         TITLE 'TESTINS3 - UNIT TEST Z10 EZ390 PROBLEM STATE INSTR.'
*
         MACRO
         TESTCAT &OP,&TYPE,&L1,&L2
         GBLA  &CAT
&CAT     SETA  &CAT+1 COMPARE AND TRAP TEST COUNTER FOR LABELS
         AIF   ('&TYPE' EQ 'L').LVAL
.AVAL    ANOP
&VL      SETC  '-1'
&VE      SETC  '0'
&VH      SETC  '1'
         AGO   .INIT
.LVAL    ANOP
&VL      SETC  '0'
&VE      SETC  '1'
&VH      SETC  '-1'
         AIF   (&L2 GT 16).INIT
&VH      SETC  '65535'
         AIF   (&L2 GT 8).INIT
&VH      SETC  '255'
.INIT    ANOP
.R1      ANOP
         AIF   (&L1 EQ 64).R1_64
.R1_32   ANOP
         L     R5,=F'&VE'
         AGO   .OP2
.R1_64   LG    R5,=FL8'&VE'
.OP2     ANOP
         AIF   (&L2 LT 32).I2
.R2      ANOP
         AIF   (&L1 EQ 64).R2_64
.R2_32   ANOP
         L     R2,=F'&VE' R2 E
         L     R3,=F'&VH' R3 H
         L     R4,=F'&VL' R4 L
         AGO   .ROP2
.R2_64   ANOP
         LG    R2,=FL8'&VE' R2 E
         LG    R3,=FL8'&VH' R3 H
         LG    R4,=FL8'&VL' R4 L
.ROP2    ANOP
&OP2E    SETC  'R2'
&OP2H    SETC  'R3'
&OP2L    SETC  'R4'
         AGO   .TEST
.I2      ANOP
&OP2E    SETC  '&VE'
&OP2H    SETC  '&VH'
&OP2L    SETC  '&VL'
.TEST    ANOP
         ESTAE ESTAE_EXIT,PARAM=&OP.8_E&CAT
&OP.8_T&CAT &OP   R5,&OP2E,8
         RT1   ABORT
&OP.8_E&CAT ESTAE 0
         RT1   OK
         ESTAE ESTAE_EXIT,PARAM=&OP.2_E&CAT
&OP.2_T&CAT &OP   R5,&OP2L,2
         RT1   ABORT
&OP.2_E&CAT ESTAE 0
         RT1   OK
         ESTAE ESTAE_EXIT,PARAM=&OP.4_E&CAT
&OP.4_T&CAT &OP   R5,&OP2H,4
         RT1   ABORT
&OP.4_E&CAT ESTAE 0
         RT1   OK
         ESTAE ESTAE_EXIT,PARAM=&OP.E_E&CAT
&OP.E_T&CAT &OP.E   R5,&OP2E
         RT1   ABORT
&OP.E_E&CAT ESTAE 0
         RT1   OK
         ESTAE ESTAE_EXIT,PARAM=&OP.H_E&CAT
&OP.H_T&CAT &OP.H   R5,&OP2L
         RT1   ABORT
&OP.H_E&CAT ESTAE 0
         RT1   OK
         ESTAE ESTAE_EXIT,PARAM=&OP.L_E&CAT
&OP.L_T&CAT &OP.L   R5,&OP2H
         RT1   ABORT
&OP.L_E&CAT ESTAE 0
         RT1   OK
         ESTAE ESTAE_EXIT,PARAM=&OP.NE_E&CAT
&OP.NE_T&CAT &OP.NE   R5,&OP2L
         RT1   ABORT
&OP.NE_E&CAT ESTAE 0
         RT1   OK
         ESTAE ESTAE_EXIT,PARAM=&OP.NH_E&CAT
&OP.NH_T&CAT &OP.NH   R5,&OP2H
         RT1   ABORT
&OP.NH_E&CAT ESTAE 0
         RT1   OK
         ESTAE ESTAE_EXIT,PARAM=&OP.NL_E&CAT
&OP.NL_T&CAT &OP.NL   R5,&OP2L
         RT1   ABORT
&OP.NL_E&CAT ESTAE 0
         RT1   OK
         ESTAE ESTAE_EXIT,PARAM=RT1_ABORT
&OP.8_NT&CAT &OP   R5,&OP2L,8
         RT1   OK
&OP.2_NT&CAT &OP   R5,&OP2E,2
         RT1   OK
&OP.4_NT&CAT &OP   R5,&OP2E,4
         RT1   OK
&OP.E_NT&CAT &OP.E   R5,&OP2H
         RT1   OK
&OP.H_NT&CAT &OP.H   R5,&OP2H
         RT1   OK
&OP.L_NT&CAT &OP.L   R5,&OP2L
         RT1   OK
&OP.NE_NT&CAT &OP.NE   R5,&OP2E
         RT1   OK
&OP.NH_NT&CAT &OP.NH   R5,&OP2L
         RT1   OK
&OP.NL_NT&CAT &OP.NL   R5,&OP2H
         RT1   OK
         ESTAE 0
         MEND
         MACRO
         TESTCAB &OP,&TYPE,&L1,&L2
         GBLA  &CAB
&CAB     SETA  &CAB+1 COMPARE AND BRANCH TEST COUNTER
         AIF   ('&TYPE' EQ 'L').LVAL
.AVAL    ANOP
&VL      SETC  '-1'
&VE      SETC  '0'
&VH      SETC  '1'
         AGO   .INIT
.LVAL    ANOP
&VL      SETC  '0'
&VE      SETC  '1'
&VH      SETC  '-1'
         AIF   (&L2 GT 16).INIT
&VH      SETC  '65535'
         AIF   (&L2 GT 8).INIT
&VH      SETC  '255'
.INIT    ANOP
.R1      ANOP
         AIF   (&L1 EQ 64).R1_64
.R1_32   ANOP
         L     R5,=F'&VE'
         AGO   .OP2
.R1_64   LG    R5,=FL8'&VE'
.OP2     ANOP
         AIF   (&L2 LT 32).I2
.R2      ANOP
         AIF   (&L1 EQ 64).R2_64
.R2_32   ANOP
         L     R2,=F'&VE' R2 E
         L     R3,=F'&VH' R3 H
         L     R4,=F'&VL' R4 L
         AGO   .ROP2
.R2_64   ANOP
         LG    R2,=FL8'&VE' R2 E
         LG    R3,=FL8'&VH' R3 H
         LG    R4,=FL8'&VL' R4 L
.ROP2    ANOP
&OP2E    SETC  'R2'
&OP2H    SETC  'R3'
&OP2L    SETC  'R4'
         AGO   .TEST
.I2      ANOP
&OP2E    SETC  '&VE'
&OP2H    SETC  '&VH'
&OP2L    SETC  '&VL'
.TEST    ANOP
&OP.8_B&CAB &OP   R5,&OP2E,8,*+10
         RT1   ABORT
         RT1   OK
&OP.2_B&CAB &OP   R5,&OP2L,2,*+10
         RT1   ABORT
         RT1   OK
&OP.4_B&CAB &OP   R5,&OP2H,4,*+10
         RT1   ABORT
         RT1   OK
&OP.E_B&CAB &OP.E   R5,&OP2E,*+10
         RT1   ABORT
         RT1   OK
&OP.H_B&CAB &OP.H   R5,&OP2L,*+10
         RT1   ABORT
         RT1   OK
&OP.L_B&CAB &OP.L   R5,&OP2H,*+10
         RT1   ABORT
         RT1   OK
&OP.NE_B&CAB &OP.NE   R5,&OP2L,*+10
         RT1   ABORT
         RT1   OK
&OP.NH_B&CAB &OP.NH   R5,&OP2H,*+10
         RT1   ABORT
         RT1   OK
&OP.NL_B&CAB &OP.NL   R5,&OP2L,*+10
         RT1   ABORT
         RT1   OK
&OP.8_NB&CAB &OP   R5,&OP2L,8,RT1_ABORT
         RT1   OK
&OP.2_NB&CAB &OP   R5,&OP2E,2,RT1_ABORT
         RT1   OK
&OP.4_NB&CAB &OP   R5,&OP2E,4,RT1_ABORT
         RT1   OK
&OP.E_NB&CAB &OP.E   R5,&OP2H,RT1_ABORT
         RT1   OK
&OP.H_NB&CAB &OP.H   R5,&OP2H,RT1_ABORT
         RT1   OK
&OP.L_NB&CAB &OP.L   R5,&OP2L,RT1_ABORT
         RT1   OK
&OP.NE_NB&CAB &OP.NE   R5,&OP2E,RT1_ABORT
         RT1   OK
&OP.NH_NB&CAB &OP.NH   R5,&OP2L,RT1_ABORT
         RT1   OK
&OP.NL_NB&CAB &OP.NL   R5,&OP2H,RT1_ABORT
         RT1   OK
         MEND
*MCALL #=     1 LV= 1 TESTINS3 RT1   MAIN
*MCALL #=     2 LV= 2 TESTINS3 SUBENTRY 
TESTINS3 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTINS3'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTINS3+8,13
*MEXIT #=     2 LV= 2 SUBENTRY
*MCALL #=     3 LV= 2          WTO   'TESTINS3 RT1 STARTED'
         BRAS  1,*+(WTO#0003_EOT-*+1)/2*2
         DC    AL2(WTO#0003_EOT-*,0),C'TESTINS3 RT1 STARTED'
WTO#0003_EOT     EQU *
         SVC   35
*MEXIT #=     3 LV= 2 WTO
         BRCL    15,RT1_START
RT1_ABORT DS 0H
         MVI   RT1_ABORTED,C'T'
*MCALL #=     4 LV= 2          WTO   'TESTINS3 RT1 TESTING ABORTED'
         BRAS  1,*+(WTO#0004_EOT-*+1)/2*2
         DC    AL2(WTO#0004_EOT-*,0),C'TESTINS3 RT1 TESTING ABORTED'
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
*MCALL #=     6 LV= 2          WTO   'TESTINS3 RT1 ENDED OK'
         BRAS  1,*+(WTO#0006_EOT-*+1)/2*2
         DC    AL2(WTO#0006_EOT-*,0),C'TESTINS3 RT1 ENDED OK'
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
RT1_WTO1 DC    AL2(RT1_WTO_END-*,0),C'TESTINS3 RT1 TESTS COMPLETED = '
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
         USING EPIE,R1
         L     R0,EPIEPARM
         ST    R0,EPIEPSW+4
         BR    R14
         DROP  R15,R1
ESTAE_EXIT DS  0H
         USING *,R15
         USING SDWA,R1
         L     R0,SDWAPARM     USE SDWA PARM VS ESTA PARM RPI 845
         LA    R15,4   REQUEST RESTART RPI 636
         BR    R14
         DROP  R15,R1
PWORK    DS    D
PWORK16  DS    XL16
PL1      DS    PL1
WORD     DS    F
DWORD    DS    D
BYTE     DS    X
REGS     DS    XL(16*8)
EBMIN    DC    EB'1.2E-38'
FPCREG   DS    F        BFP CONTROL REG WITH MASKS AND DXC CODE
FPCDXC   EQU   FPCREG+2 REASON CODES FOR 0C7 DATA EXCEPTIONS
*********************************************************************
* TRTE TEST TABLES AND FIELDS
*********************************************************************
TRT_F1    DC    C'1234X6'  1 BYTE ARG AND 1 BYTE TAB
TRT_TAB1  DC    0D,240X'FF',10X'00',6X'FF'
TRT_F2    DC    C'123X56'  1 BYTE ARG AND 2 BYTE TABLE
TRT_TAB2  DC    0D,240XL2'FFFF',10XL2'0000',6XL2'FFFF'
TRT_F3    DC    0XL8,AL2(0,1,2,3) 2 BYTE ARG AND 1 BYTE TAB 65K
TRT_TAB3  DC    0D,AL1(0,0,X'33',0)  OMITTING REST OF 65K TABLE
TRT_F4    DC    0XL8,AL2(0,1,2,3) 2 BYTE ARG AND 1 BYTE TAB 128K
TRT_TAB4  DC    0D,AL2(0,0,X'4444',0)  OMITTING REST OF 128K TABLE
*********************************************************************
* START z10 INSTRUCTION TESTS
*********************************************************************
*MCALL #=    10 LV= 1          RT1   START
RT1_START DS  0H
*MEXIT #=    10 LV= 1 RT1
* B960 CRT R1,R2,M3 COMPARE AND TRAP
*MCALL #=    11 LV= 1          TESTCAT CRT,A,32,32
         L     R5,=F'0'
         L     R2,=F'0' R2 E
         L     R3,=F'1' R3 H
         L     R4,=F'-1' R4 L
*MCALL #=    12 LV= 2          ESTAE ESTAE_EXIT,PARAM=CRT8_E1
        LA     0,ESTAE_EXIT
        LA     1,CRT8_E1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=    12 LV= 2 ESTAE
CRT8_T1     CRT   R5,R2,8
*MCALL #=    13 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=    13 LV= 2 RT1
*MCALL #=    14 LV= 2 CRT8_E1     ESTAE 0
CRT8_E1  DS    0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=    14 LV= 2 ESTAE
*MCALL #=    15 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK2
         LTORG 
RT1_OK2        DS 0H
*MEXIT #=    15 LV= 2 RT1
*MCALL #=    16 LV= 2          ESTAE ESTAE_EXIT,PARAM=CRT2_E1
        LA     0,ESTAE_EXIT
        LA     1,CRT2_E1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=    16 LV= 2 ESTAE
CRT2_T1     CRT   R5,R4,2
*MCALL #=    17 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=    17 LV= 2 RT1
*MCALL #=    18 LV= 2 CRT2_E1     ESTAE 0
CRT2_E1  DS    0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=    18 LV= 2 ESTAE
*MCALL #=    19 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK4
         LTORG 
RT1_OK4        DS 0H
*MEXIT #=    19 LV= 2 RT1
*MCALL #=    20 LV= 2          ESTAE ESTAE_EXIT,PARAM=CRT4_E1
        LA     0,ESTAE_EXIT
        LA     1,CRT4_E1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=    20 LV= 2 ESTAE
CRT4_T1     CRT   R5,R3,4
*MCALL #=    21 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=    21 LV= 2 RT1
*MCALL #=    22 LV= 2 CRT4_E1     ESTAE 0
CRT4_E1  DS    0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=    22 LV= 2 ESTAE
*MCALL #=    23 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK6
         LTORG 
RT1_OK6        DS 0H
*MEXIT #=    23 LV= 2 RT1
*MCALL #=    24 LV= 2          ESTAE ESTAE_EXIT,PARAM=CRTE_E1
        LA     0,ESTAE_EXIT
        LA     1,CRTE_E1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=    24 LV= 2 ESTAE
CRTE_T1     CRTE    R5,R2
*MCALL #=    25 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=    25 LV= 2 RT1
*MCALL #=    26 LV= 2 CRTE_E1     ESTAE 0
CRTE_E1  DS    0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=    26 LV= 2 ESTAE
*MCALL #=    27 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK8
         LTORG 
RT1_OK8        DS 0H
*MEXIT #=    27 LV= 2 RT1
*MCALL #=    28 LV= 2          ESTAE ESTAE_EXIT,PARAM=CRTH_E1
        LA     0,ESTAE_EXIT
        LA     1,CRTH_E1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=    28 LV= 2 ESTAE
CRTH_T1     CRTH    R5,R4
*MCALL #=    29 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=    29 LV= 2 RT1
*MCALL #=    30 LV= 2 CRTH_E1     ESTAE 0
CRTH_E1  DS    0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=    30 LV= 2 ESTAE
*MCALL #=    31 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK10
         LTORG 
RT1_OK10       DS 0H
*MEXIT #=    31 LV= 2 RT1
*MCALL #=    32 LV= 2          ESTAE ESTAE_EXIT,PARAM=CRTL_E1
        LA     0,ESTAE_EXIT
        LA     1,CRTL_E1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=    32 LV= 2 ESTAE
CRTL_T1     CRTL    R5,R3
*MCALL #=    33 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=    33 LV= 2 RT1
*MCALL #=    34 LV= 2 CRTL_E1     ESTAE 0
CRTL_E1  DS    0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=    34 LV= 2 ESTAE
*MCALL #=    35 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK12
         LTORG 
RT1_OK12       DS 0H
*MEXIT #=    35 LV= 2 RT1
*MCALL #=    36 LV= 2          ESTAE ESTAE_EXIT,PARAM=CRTNE_E1
        LA     0,ESTAE_EXIT
        LA     1,CRTNE_E1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=    36 LV= 2 ESTAE
CRTNE_T1     CRTNE    R5,R4
*MCALL #=    37 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=    37 LV= 2 RT1
*MCALL #=    38 LV= 2 CRTNE_E1     ESTAE 0
CRTNE_E1 DS    0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=    38 LV= 2 ESTAE
*MCALL #=    39 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK14
         LTORG 
RT1_OK14       DS 0H
*MEXIT #=    39 LV= 2 RT1
*MCALL #=    40 LV= 2          ESTAE ESTAE_EXIT,PARAM=CRTNH_E1
        LA     0,ESTAE_EXIT
        LA     1,CRTNH_E1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=    40 LV= 2 ESTAE
CRTNH_T1     CRTNH    R5,R3
*MCALL #=    41 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=    41 LV= 2 RT1
*MCALL #=    42 LV= 2 CRTNH_E1     ESTAE 0
CRTNH_E1 DS    0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=    42 LV= 2 ESTAE
*MCALL #=    43 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK16
         LTORG 
RT1_OK16       DS 0H
*MEXIT #=    43 LV= 2 RT1
*MCALL #=    44 LV= 2          ESTAE ESTAE_EXIT,PARAM=CRTNL_E1
        LA     0,ESTAE_EXIT
        LA     1,CRTNL_E1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=    44 LV= 2 ESTAE
CRTNL_T1     CRTNL    R5,R4
*MCALL #=    45 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=    45 LV= 2 RT1
*MCALL #=    46 LV= 2 CRTNL_E1     ESTAE 0
CRTNL_E1 DS    0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=    46 LV= 2 ESTAE
*MCALL #=    47 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK18
         LTORG 
RT1_OK18       DS 0H
*MEXIT #=    47 LV= 2 RT1
*MCALL #=    48 LV= 2          ESTAE ESTAE_EXIT,PARAM=RT1_ABORT
        LA     0,ESTAE_EXIT
        LA     1,RT1_ABORT
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=    48 LV= 2 ESTAE
CRT8_NT1     CRT   R5,R4,8
*MCALL #=    49 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK19
         LTORG 
RT1_OK19       DS 0H
*MEXIT #=    49 LV= 2 RT1
CRT2_NT1     CRT   R5,R2,2
*MCALL #=    50 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK20
         LTORG 
RT1_OK20       DS 0H
*MEXIT #=    50 LV= 2 RT1
CRT4_NT1     CRT   R5,R2,4
*MCALL #=    51 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK21
         LTORG 
RT1_OK21       DS 0H
*MEXIT #=    51 LV= 2 RT1
CRTE_NT1     CRTE    R5,R3
*MCALL #=    52 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK22
         LTORG 
RT1_OK22       DS 0H
*MEXIT #=    52 LV= 2 RT1
CRTH_NT1     CRTH    R5,R3
*MCALL #=    53 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK23
         LTORG 
RT1_OK23       DS 0H
*MEXIT #=    53 LV= 2 RT1
CRTL_NT1     CRTL    R5,R4
*MCALL #=    54 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK24
         LTORG 
RT1_OK24       DS 0H
*MEXIT #=    54 LV= 2 RT1
CRTNE_NT1     CRTNE    R5,R2
*MCALL #=    55 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK25
         LTORG 
RT1_OK25       DS 0H
*MEXIT #=    55 LV= 2 RT1
CRTNH_NT1     CRTNH    R5,R4
*MCALL #=    56 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK26
         LTORG 
RT1_OK26       DS 0H
*MEXIT #=    56 LV= 2 RT1
CRTNL_NT1     CRTNL    R5,R3
*MCALL #=    57 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK27
         LTORG 
RT1_OK27       DS 0H
*MEXIT #=    57 LV= 2 RT1
*MCALL #=    58 LV= 2          ESTAE 0
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=    58 LV= 2 ESTAE
*MEXIT #=    11 LV= 1 TESTCAT
* B961 CLRT R1,R2,M3 COMPARE LOGICAL AND TRAP
*MCALL #=    59 LV= 1          TESTCAT CLRT,L,32,32
         L     R5,=F'1'
         L     R2,=F'1' R2 E
         L     R3,=F'-1' R3 H
         L     R4,=F'0' R4 L
*MCALL #=    60 LV= 2          ESTAE ESTAE_EXIT,PARAM=CLRT8_E2
        LA     0,ESTAE_EXIT
        LA     1,CLRT8_E2
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=    60 LV= 2 ESTAE
CLRT8_T2    CLRT  R5,R2,8
*MCALL #=    61 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=    61 LV= 2 RT1
*MCALL #=    62 LV= 2 CLRT8_E2    ESTAE 0
CLRT8_E2 DS    0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=    62 LV= 2 ESTAE
*MCALL #=    63 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK29
         LTORG 
RT1_OK29       DS 0H
*MEXIT #=    63 LV= 2 RT1
*MCALL #=    64 LV= 2          ESTAE ESTAE_EXIT,PARAM=CLRT2_E2
        LA     0,ESTAE_EXIT
        LA     1,CLRT2_E2
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=    64 LV= 2 ESTAE
CLRT2_T2    CLRT  R5,R4,2
*MCALL #=    65 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=    65 LV= 2 RT1
*MCALL #=    66 LV= 2 CLRT2_E2    ESTAE 0
CLRT2_E2 DS    0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=    66 LV= 2 ESTAE
*MCALL #=    67 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK31
         LTORG 
RT1_OK31       DS 0H
*MEXIT #=    67 LV= 2 RT1
*MCALL #=    68 LV= 2          ESTAE ESTAE_EXIT,PARAM=CLRT4_E2
        LA     0,ESTAE_EXIT
        LA     1,CLRT4_E2
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=    68 LV= 2 ESTAE
CLRT4_T2    CLRT  R5,R3,4
*MCALL #=    69 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=    69 LV= 2 RT1
*MCALL #=    70 LV= 2 CLRT4_E2    ESTAE 0
CLRT4_E2 DS    0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=    70 LV= 2 ESTAE
*MCALL #=    71 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK33
         LTORG 
RT1_OK33       DS 0H
*MEXIT #=    71 LV= 2 RT1
*MCALL #=    72 LV= 2          ESTAE ESTAE_EXIT,PARAM=CLRTE_E2
        LA     0,ESTAE_EXIT
        LA     1,CLRTE_E2
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=    72 LV= 2 ESTAE
CLRTE_T2    CLRTE   R5,R2
*MCALL #=    73 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=    73 LV= 2 RT1
*MCALL #=    74 LV= 2 CLRTE_E2    ESTAE 0
CLRTE_E2 DS    0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=    74 LV= 2 ESTAE
*MCALL #=    75 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK35
         LTORG 
RT1_OK35       DS 0H
*MEXIT #=    75 LV= 2 RT1
*MCALL #=    76 LV= 2          ESTAE ESTAE_EXIT,PARAM=CLRTH_E2
        LA     0,ESTAE_EXIT
        LA     1,CLRTH_E2
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=    76 LV= 2 ESTAE
CLRTH_T2    CLRTH   R5,R4
*MCALL #=    77 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=    77 LV= 2 RT1
*MCALL #=    78 LV= 2 CLRTH_E2    ESTAE 0
CLRTH_E2 DS    0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=    78 LV= 2 ESTAE
*MCALL #=    79 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK37
         LTORG 
RT1_OK37       DS 0H
*MEXIT #=    79 LV= 2 RT1
*MCALL #=    80 LV= 2          ESTAE ESTAE_EXIT,PARAM=CLRTL_E2
        LA     0,ESTAE_EXIT
        LA     1,CLRTL_E2
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=    80 LV= 2 ESTAE
CLRTL_T2    CLRTL   R5,R3
*MCALL #=    81 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=    81 LV= 2 RT1
*MCALL #=    82 LV= 2 CLRTL_E2    ESTAE 0
CLRTL_E2 DS    0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=    82 LV= 2 ESTAE
*MCALL #=    83 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK39
         LTORG 
RT1_OK39       DS 0H
*MEXIT #=    83 LV= 2 RT1
*MCALL #=    84 LV= 2          ESTAE ESTAE_EXIT,PARAM=CLRTNE_E2
        LA     0,ESTAE_EXIT
        LA     1,CLRTNE_E2
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=    84 LV= 2 ESTAE
CLRTNE_T2    CLRTNE   R5,R4
*MCALL #=    85 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=    85 LV= 2 RT1
*MCALL #=    86 LV= 2 CLRTNE_E2    ESTAE 0
CLRTNE_E2 DS   0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=    86 LV= 2 ESTAE
*MCALL #=    87 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK41
         LTORG 
RT1_OK41       DS 0H
*MEXIT #=    87 LV= 2 RT1
*MCALL #=    88 LV= 2          ESTAE ESTAE_EXIT,PARAM=CLRTNH_E2
        LA     0,ESTAE_EXIT
        LA     1,CLRTNH_E2
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=    88 LV= 2 ESTAE
CLRTNH_T2    CLRTNH   R5,R3
*MCALL #=    89 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=    89 LV= 2 RT1
*MCALL #=    90 LV= 2 CLRTNH_E2    ESTAE 0
CLRTNH_E2 DS   0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=    90 LV= 2 ESTAE
*MCALL #=    91 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK43
         LTORG 
RT1_OK43       DS 0H
*MEXIT #=    91 LV= 2 RT1
*MCALL #=    92 LV= 2          ESTAE ESTAE_EXIT,PARAM=CLRTNL_E2
        LA     0,ESTAE_EXIT
        LA     1,CLRTNL_E2
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=    92 LV= 2 ESTAE
CLRTNL_T2    CLRTNL   R5,R4
*MCALL #=    93 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=    93 LV= 2 RT1
*MCALL #=    94 LV= 2 CLRTNL_E2    ESTAE 0
CLRTNL_E2 DS   0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=    94 LV= 2 ESTAE
*MCALL #=    95 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK45
         LTORG 
RT1_OK45       DS 0H
*MEXIT #=    95 LV= 2 RT1
*MCALL #=    96 LV= 2          ESTAE ESTAE_EXIT,PARAM=RT1_ABORT
        LA     0,ESTAE_EXIT
        LA     1,RT1_ABORT
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=    96 LV= 2 ESTAE
CLRT8_NT2    CLRT  R5,R4,8
*MCALL #=    97 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK46
         LTORG 
RT1_OK46       DS 0H
*MEXIT #=    97 LV= 2 RT1
CLRT2_NT2    CLRT  R5,R2,2
*MCALL #=    98 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK47
         LTORG 
RT1_OK47       DS 0H
*MEXIT #=    98 LV= 2 RT1
CLRT4_NT2    CLRT  R5,R2,4
*MCALL #=    99 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK48
         LTORG 
RT1_OK48       DS 0H
*MEXIT #=    99 LV= 2 RT1
CLRTE_NT2    CLRTE   R5,R3
*MCALL #=   100 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK49
         LTORG 
RT1_OK49       DS 0H
*MEXIT #=   100 LV= 2 RT1
CLRTH_NT2    CLRTH   R5,R3
*MCALL #=   101 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK50
         LTORG 
RT1_OK50       DS 0H
*MEXIT #=   101 LV= 2 RT1
CLRTL_NT2    CLRTL   R5,R4
*MCALL #=   102 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK51
         LTORG 
RT1_OK51       DS 0H
*MEXIT #=   102 LV= 2 RT1
CLRTNE_NT2    CLRTNE   R5,R2
*MCALL #=   103 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK52
         LTORG 
RT1_OK52       DS 0H
*MEXIT #=   103 LV= 2 RT1
CLRTNH_NT2    CLRTNH   R5,R4
*MCALL #=   104 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK53
         LTORG 
RT1_OK53       DS 0H
*MEXIT #=   104 LV= 2 RT1
CLRTNL_NT2    CLRTNL   R5,R3
*MCALL #=   105 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK54
         LTORG 
RT1_OK54       DS 0H
*MEXIT #=   105 LV= 2 RT1
*MCALL #=   106 LV= 2          ESTAE 0
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   106 LV= 2 ESTAE
*MEXIT #=    59 LV= 1 TESTCAT
* B972 CGRT R1,R2,M3 COMPARE AND TRAP
*MCALL #=   107 LV= 1          TESTCAT CGRT,A,64,64
         LG    R5,=FL8'0'
         LG    R2,=FL8'0' R2 E
         LG    R3,=FL8'1' R3 H
         LG    R4,=FL8'-1' R4 L
*MCALL #=   108 LV= 2          ESTAE ESTAE_EXIT,PARAM=CGRT8_E3
        LA     0,ESTAE_EXIT
        LA     1,CGRT8_E3
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   108 LV= 2 ESTAE
CGRT8_T3    CGRT  R5,R2,8
*MCALL #=   109 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   109 LV= 2 RT1
*MCALL #=   110 LV= 2 CGRT8_E3    ESTAE 0
CGRT8_E3 DS    0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   110 LV= 2 ESTAE
*MCALL #=   111 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK56
         LTORG 
RT1_OK56       DS 0H
*MEXIT #=   111 LV= 2 RT1
*MCALL #=   112 LV= 2          ESTAE ESTAE_EXIT,PARAM=CGRT2_E3
        LA     0,ESTAE_EXIT
        LA     1,CGRT2_E3
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   112 LV= 2 ESTAE
CGRT2_T3    CGRT  R5,R4,2
*MCALL #=   113 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   113 LV= 2 RT1
*MCALL #=   114 LV= 2 CGRT2_E3    ESTAE 0
CGRT2_E3 DS    0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   114 LV= 2 ESTAE
*MCALL #=   115 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK58
         LTORG 
RT1_OK58       DS 0H
*MEXIT #=   115 LV= 2 RT1
*MCALL #=   116 LV= 2          ESTAE ESTAE_EXIT,PARAM=CGRT4_E3
        LA     0,ESTAE_EXIT
        LA     1,CGRT4_E3
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   116 LV= 2 ESTAE
CGRT4_T3    CGRT  R5,R3,4
*MCALL #=   117 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   117 LV= 2 RT1
*MCALL #=   118 LV= 2 CGRT4_E3    ESTAE 0
CGRT4_E3 DS    0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   118 LV= 2 ESTAE
*MCALL #=   119 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK60
         LTORG 
RT1_OK60       DS 0H
*MEXIT #=   119 LV= 2 RT1
*MCALL #=   120 LV= 2          ESTAE ESTAE_EXIT,PARAM=CGRTE_E3
        LA     0,ESTAE_EXIT
        LA     1,CGRTE_E3
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   120 LV= 2 ESTAE
CGRTE_T3    CGRTE   R5,R2
*MCALL #=   121 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   121 LV= 2 RT1
*MCALL #=   122 LV= 2 CGRTE_E3    ESTAE 0
CGRTE_E3 DS    0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   122 LV= 2 ESTAE
*MCALL #=   123 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK62
         LTORG 
RT1_OK62       DS 0H
*MEXIT #=   123 LV= 2 RT1
*MCALL #=   124 LV= 2          ESTAE ESTAE_EXIT,PARAM=CGRTH_E3
        LA     0,ESTAE_EXIT
        LA     1,CGRTH_E3
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   124 LV= 2 ESTAE
CGRTH_T3    CGRTH   R5,R4
*MCALL #=   125 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   125 LV= 2 RT1
*MCALL #=   126 LV= 2 CGRTH_E3    ESTAE 0
CGRTH_E3 DS    0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   126 LV= 2 ESTAE
*MCALL #=   127 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK64
         LTORG 
RT1_OK64       DS 0H
*MEXIT #=   127 LV= 2 RT1
*MCALL #=   128 LV= 2          ESTAE ESTAE_EXIT,PARAM=CGRTL_E3
        LA     0,ESTAE_EXIT
        LA     1,CGRTL_E3
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   128 LV= 2 ESTAE
CGRTL_T3    CGRTL   R5,R3
*MCALL #=   129 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   129 LV= 2 RT1
*MCALL #=   130 LV= 2 CGRTL_E3    ESTAE 0
CGRTL_E3 DS    0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   130 LV= 2 ESTAE
*MCALL #=   131 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK66
         LTORG 
RT1_OK66       DS 0H
*MEXIT #=   131 LV= 2 RT1
*MCALL #=   132 LV= 2          ESTAE ESTAE_EXIT,PARAM=CGRTNE_E3
        LA     0,ESTAE_EXIT
        LA     1,CGRTNE_E3
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   132 LV= 2 ESTAE
CGRTNE_T3    CGRTNE   R5,R4
*MCALL #=   133 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   133 LV= 2 RT1
*MCALL #=   134 LV= 2 CGRTNE_E3    ESTAE 0
CGRTNE_E3 DS   0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   134 LV= 2 ESTAE
*MCALL #=   135 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK68
         LTORG 
RT1_OK68       DS 0H
*MEXIT #=   135 LV= 2 RT1
*MCALL #=   136 LV= 2          ESTAE ESTAE_EXIT,PARAM=CGRTNH_E3
        LA     0,ESTAE_EXIT
        LA     1,CGRTNH_E3
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   136 LV= 2 ESTAE
CGRTNH_T3    CGRTNH   R5,R3
*MCALL #=   137 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   137 LV= 2 RT1
*MCALL #=   138 LV= 2 CGRTNH_E3    ESTAE 0
CGRTNH_E3 DS   0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   138 LV= 2 ESTAE
*MCALL #=   139 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK70
         LTORG 
RT1_OK70       DS 0H
*MEXIT #=   139 LV= 2 RT1
*MCALL #=   140 LV= 2          ESTAE ESTAE_EXIT,PARAM=CGRTNL_E3
        LA     0,ESTAE_EXIT
        LA     1,CGRTNL_E3
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   140 LV= 2 ESTAE
CGRTNL_T3    CGRTNL   R5,R4
*MCALL #=   141 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   141 LV= 2 RT1
*MCALL #=   142 LV= 2 CGRTNL_E3    ESTAE 0
CGRTNL_E3 DS   0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   142 LV= 2 ESTAE
*MCALL #=   143 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK72
         LTORG 
RT1_OK72       DS 0H
*MEXIT #=   143 LV= 2 RT1
*MCALL #=   144 LV= 2          ESTAE ESTAE_EXIT,PARAM=RT1_ABORT
        LA     0,ESTAE_EXIT
        LA     1,RT1_ABORT
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   144 LV= 2 ESTAE
CGRT8_NT3    CGRT  R5,R4,8
*MCALL #=   145 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK73
         LTORG 
RT1_OK73       DS 0H
*MEXIT #=   145 LV= 2 RT1
CGRT2_NT3    CGRT  R5,R2,2
*MCALL #=   146 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK74
         LTORG 
RT1_OK74       DS 0H
*MEXIT #=   146 LV= 2 RT1
CGRT4_NT3    CGRT  R5,R2,4
*MCALL #=   147 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK75
         LTORG 
RT1_OK75       DS 0H
*MEXIT #=   147 LV= 2 RT1
CGRTE_NT3    CGRTE   R5,R3
*MCALL #=   148 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK76
         LTORG 
RT1_OK76       DS 0H
*MEXIT #=   148 LV= 2 RT1
CGRTH_NT3    CGRTH   R5,R3
*MCALL #=   149 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK77
         LTORG 
RT1_OK77       DS 0H
*MEXIT #=   149 LV= 2 RT1
CGRTL_NT3    CGRTL   R5,R4
*MCALL #=   150 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK78
         LTORG 
RT1_OK78       DS 0H
*MEXIT #=   150 LV= 2 RT1
CGRTNE_NT3    CGRTNE   R5,R2
*MCALL #=   151 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK79
         LTORG 
RT1_OK79       DS 0H
*MEXIT #=   151 LV= 2 RT1
CGRTNH_NT3    CGRTNH   R5,R4
*MCALL #=   152 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK80
         LTORG 
RT1_OK80       DS 0H
*MEXIT #=   152 LV= 2 RT1
CGRTNL_NT3    CGRTNL   R5,R3
*MCALL #=   153 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK81
         LTORG 
RT1_OK81       DS 0H
*MEXIT #=   153 LV= 2 RT1
*MCALL #=   154 LV= 2          ESTAE 0
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   154 LV= 2 ESTAE
*MEXIT #=   107 LV= 1 TESTCAT
* B973 CLGRT R1,R2,M3 COMPARE LOG AND TRAP
*MCALL #=   155 LV= 1          TESTCAT CLGRT,L,64,64
         LG    R5,=FL8'1'
         LG    R2,=FL8'1' R2 E
         LG    R3,=FL8'-1' R3 H
         LG    R4,=FL8'0' R4 L
*MCALL #=   156 LV= 2          ESTAE ESTAE_EXIT,PARAM=CLGRT8_E4
        LA     0,ESTAE_EXIT
        LA     1,CLGRT8_E4
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   156 LV= 2 ESTAE
CLGRT8_T4   CLGRT R5,R2,8
*MCALL #=   157 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   157 LV= 2 RT1
*MCALL #=   158 LV= 2 CLGRT8_E4   ESTAE 0
CLGRT8_E4 DS   0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   158 LV= 2 ESTAE
*MCALL #=   159 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK83
         LTORG 
RT1_OK83       DS 0H
*MEXIT #=   159 LV= 2 RT1
*MCALL #=   160 LV= 2          ESTAE ESTAE_EXIT,PARAM=CLGRT2_E4
        LA     0,ESTAE_EXIT
        LA     1,CLGRT2_E4
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   160 LV= 2 ESTAE
CLGRT2_T4   CLGRT R5,R4,2
*MCALL #=   161 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   161 LV= 2 RT1
*MCALL #=   162 LV= 2 CLGRT2_E4   ESTAE 0
CLGRT2_E4 DS   0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   162 LV= 2 ESTAE
*MCALL #=   163 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK85
         LTORG 
RT1_OK85       DS 0H
*MEXIT #=   163 LV= 2 RT1
*MCALL #=   164 LV= 2          ESTAE ESTAE_EXIT,PARAM=CLGRT4_E4
        LA     0,ESTAE_EXIT
        LA     1,CLGRT4_E4
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   164 LV= 2 ESTAE
CLGRT4_T4   CLGRT R5,R3,4
*MCALL #=   165 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   165 LV= 2 RT1
*MCALL #=   166 LV= 2 CLGRT4_E4   ESTAE 0
CLGRT4_E4 DS   0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   166 LV= 2 ESTAE
*MCALL #=   167 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK87
         LTORG 
RT1_OK87       DS 0H
*MEXIT #=   167 LV= 2 RT1
*MCALL #=   168 LV= 2          ESTAE ESTAE_EXIT,PARAM=CLGRTE_E4
        LA     0,ESTAE_EXIT
        LA     1,CLGRTE_E4
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   168 LV= 2 ESTAE
CLGRTE_T4   CLGRTE  R5,R2
*MCALL #=   169 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   169 LV= 2 RT1
*MCALL #=   170 LV= 2 CLGRTE_E4   ESTAE 0
CLGRTE_E4 DS   0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   170 LV= 2 ESTAE
*MCALL #=   171 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK89
         LTORG 
RT1_OK89       DS 0H
*MEXIT #=   171 LV= 2 RT1
*MCALL #=   172 LV= 2          ESTAE ESTAE_EXIT,PARAM=CLGRTH_E4
        LA     0,ESTAE_EXIT
        LA     1,CLGRTH_E4
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   172 LV= 2 ESTAE
CLGRTH_T4   CLGRTH  R5,R4
*MCALL #=   173 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   173 LV= 2 RT1
*MCALL #=   174 LV= 2 CLGRTH_E4   ESTAE 0
CLGRTH_E4 DS   0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   174 LV= 2 ESTAE
*MCALL #=   175 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK91
         LTORG 
RT1_OK91       DS 0H
*MEXIT #=   175 LV= 2 RT1
*MCALL #=   176 LV= 2          ESTAE ESTAE_EXIT,PARAM=CLGRTL_E4
        LA     0,ESTAE_EXIT
        LA     1,CLGRTL_E4
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   176 LV= 2 ESTAE
CLGRTL_T4   CLGRTL  R5,R3
*MCALL #=   177 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   177 LV= 2 RT1
*MCALL #=   178 LV= 2 CLGRTL_E4   ESTAE 0
CLGRTL_E4 DS   0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   178 LV= 2 ESTAE
*MCALL #=   179 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK93
         LTORG 
RT1_OK93       DS 0H
*MEXIT #=   179 LV= 2 RT1
*MCALL #=   180 LV= 2          ESTAE ESTAE_EXIT,PARAM=CLGRTNE_E4
        LA     0,ESTAE_EXIT
        LA     1,CLGRTNE_E4
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   180 LV= 2 ESTAE
CLGRTNE_T4   CLGRTNE  R5,R4
*MCALL #=   181 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   181 LV= 2 RT1
*MCALL #=   182 LV= 2 CLGRTNE_E4   ESTAE 0
CLGRTNE_E4 DS  0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   182 LV= 2 ESTAE
*MCALL #=   183 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK95
         LTORG 
RT1_OK95       DS 0H
*MEXIT #=   183 LV= 2 RT1
*MCALL #=   184 LV= 2          ESTAE ESTAE_EXIT,PARAM=CLGRTNH_E4
        LA     0,ESTAE_EXIT
        LA     1,CLGRTNH_E4
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   184 LV= 2 ESTAE
CLGRTNH_T4   CLGRTNH  R5,R3
*MCALL #=   185 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   185 LV= 2 RT1
*MCALL #=   186 LV= 2 CLGRTNH_E4   ESTAE 0
CLGRTNH_E4 DS  0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   186 LV= 2 ESTAE
*MCALL #=   187 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK97
         LTORG 
RT1_OK97       DS 0H
*MEXIT #=   187 LV= 2 RT1
*MCALL #=   188 LV= 2          ESTAE ESTAE_EXIT,PARAM=CLGRTNL_E4
        LA     0,ESTAE_EXIT
        LA     1,CLGRTNL_E4
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   188 LV= 2 ESTAE
CLGRTNL_T4   CLGRTNL  R5,R4
*MCALL #=   189 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   189 LV= 2 RT1
*MCALL #=   190 LV= 2 CLGRTNL_E4   ESTAE 0
CLGRTNL_E4 DS  0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   190 LV= 2 ESTAE
*MCALL #=   191 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK99
         LTORG 
RT1_OK99       DS 0H
*MEXIT #=   191 LV= 2 RT1
*MCALL #=   192 LV= 2          ESTAE ESTAE_EXIT,PARAM=RT1_ABORT
        LA     0,ESTAE_EXIT
        LA     1,RT1_ABORT
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   192 LV= 2 ESTAE
CLGRT8_NT4   CLGRT R5,R4,8
*MCALL #=   193 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK100
         LTORG 
RT1_OK100      DS 0H
*MEXIT #=   193 LV= 2 RT1
CLGRT2_NT4   CLGRT R5,R2,2
*MCALL #=   194 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK101
         LTORG 
RT1_OK101      DS 0H
*MEXIT #=   194 LV= 2 RT1
CLGRT4_NT4   CLGRT R5,R2,4
*MCALL #=   195 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK102
         LTORG 
RT1_OK102      DS 0H
*MEXIT #=   195 LV= 2 RT1
CLGRTE_NT4   CLGRTE  R5,R3
*MCALL #=   196 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK103
         LTORG 
RT1_OK103      DS 0H
*MEXIT #=   196 LV= 2 RT1
CLGRTH_NT4   CLGRTH  R5,R3
*MCALL #=   197 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK104
         LTORG 
RT1_OK104      DS 0H
*MEXIT #=   197 LV= 2 RT1
CLGRTL_NT4   CLGRTL  R5,R4
*MCALL #=   198 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK105
         LTORG 
RT1_OK105      DS 0H
*MEXIT #=   198 LV= 2 RT1
CLGRTNE_NT4   CLGRTNE  R5,R2
*MCALL #=   199 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK106
         LTORG 
RT1_OK106      DS 0H
*MEXIT #=   199 LV= 2 RT1
CLGRTNH_NT4   CLGRTNH  R5,R4
*MCALL #=   200 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK107
         LTORG 
RT1_OK107      DS 0H
*MEXIT #=   200 LV= 2 RT1
CLGRTNL_NT4   CLGRTNL  R5,R3
*MCALL #=   201 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK108
         LTORG 
RT1_OK108      DS 0H
*MEXIT #=   201 LV= 2 RT1
*MCALL #=   202 LV= 2          ESTAE 0
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   202 LV= 2 ESTAE
*MEXIT #=   155 LV= 1 TESTCAT
* B9BF   TRTE  rpi 818
         LA    R1,TRT_TAB1
         LM    R6,R7,=A(TRT_F1,L'TRT_F1)
         TRTE  R6,R8      1 BYTE ARG AND 1 BYTE TABLE
         BRC   1,*-4      RESTART TRTE UNTIL ENDED
*MCALL #=   203 LV= 1          RT1   CC1
         DS    0H
RT1_TEST109      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL109
         LTORG 
RT1_CCL109      DS 0H
*MEXIT #=   203 LV= 1 RT1
         CL    R8,=A(X'FF')
*MCALL #=   204 LV= 1          RT1   CCE
         DS    0H
RT1_TEST110      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE110
         LTORG 
RT1_CCE110      DS 0H
*MEXIT #=   204 LV= 1 RT1
         CL    R6,=A(TRT_F1+4)
*MCALL #=   205 LV= 1          RT1   CCE
         DS    0H
RT1_TEST111      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE111
         LTORG 
RT1_CCE111      DS 0H
*MEXIT #=   205 LV= 1 RT1
         CL    R7,=A(L'TRT_F1-4)
*MCALL #=   206 LV= 1          RT1   CCE
         DS    0H
RT1_TEST112      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE112
         LTORG 
RT1_CCE112      DS 0H
*MEXIT #=   206 LV= 1 RT1
         LA    R1,TRT_TAB2
         LM    R6,R7,=A(TRT_F2,L'TRT_F2)
         TRTE  R6,R8,X'4' 1 BYTE ARG, 2 BYTE TABLE
         BRC   1,*-4      RESTART TRTE UNTIL ENDED
*MCALL #=   207 LV= 1          RT1   CC1
         DS    0H
RT1_TEST113      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL113
         LTORG 
RT1_CCL113      DS 0H
*MEXIT #=   207 LV= 1 RT1
         CL    R8,=A(X'FFFF')
*MCALL #=   208 LV= 1          RT1   CCE
         DS    0H
RT1_TEST114      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE114
         LTORG 
RT1_CCE114      DS 0H
*MEXIT #=   208 LV= 1 RT1
         CL    R6,=A(TRT_F2+3)
*MCALL #=   209 LV= 1          RT1   CCE
         DS    0H
RT1_TEST115      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE115
         LTORG 
RT1_CCE115      DS 0H
*MEXIT #=   209 LV= 1 RT1
         CL    R7,=A(L'TRT_F2-3)
*MCALL #=   210 LV= 1          RT1   CCE
         DS    0H
RT1_TEST116      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE116
         LTORG 
RT1_CCE116      DS 0H
*MEXIT #=   210 LV= 1 RT1
         LA    R1,TRT_TAB3
         LM    R6,R7,=A(TRT_F3,L'TRT_F3)
         TRTE  R6,R8,X'8' 2 BYTE ARG, 1 BYTE 65K TAB AND NO LIMIT
         BRC   1,*-4      RESTART TRTE UNTIL ENDED
*MCALL #=   211 LV= 1          RT1   CC1
         DS    0H
RT1_TEST117      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL117
         LTORG 
RT1_CCL117      DS 0H
*MEXIT #=   211 LV= 1 RT1
         CL    R8,=A(X'33')
*MCALL #=   212 LV= 1          RT1   CCE
         DS    0H
RT1_TEST118      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE118
         LTORG 
RT1_CCE118      DS 0H
*MEXIT #=   212 LV= 1 RT1
         CL    R6,=A(TRT_F3+2*2)
*MCALL #=   213 LV= 1          RT1   CCE
         DS    0H
RT1_TEST119      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE119
         LTORG 
RT1_CCE119      DS 0H
*MEXIT #=   213 LV= 1 RT1
         CL    R7,=A(L'TRT_F3-2*2)
*MCALL #=   214 LV= 1          RT1   CCE
         DS    0H
RT1_TEST120      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE120
         LTORG 
RT1_CCE120      DS 0H
*MEXIT #=   214 LV= 1 RT1
         LA    R1,TRT_TAB3
         LM    R6,R7,=A(TRT_F3,L'TRT_F3)
         MVI   TRT_F3+2*2,X'FF' SET HIGH BYTE OF 3RD ENTRY
         TRTE  R6,R8,X'A' 2 BYTE ARG, 1 BYTE 65K TAB AND LIMIT
         BRC   1,*-4      RESTART TRTE UNTIL ENDED
         MVI   TRT_F3+2*2,X'00' RESET HIGH BYTE OF 3RD ENTRY
*MCALL #=   215 LV= 1          RT1   CC0
         DS    0H
RT1_TEST121      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE121
         LTORG 
RT1_CCE121      DS 0H
*MEXIT #=   215 LV= 1 RT1
         CL    R8,=A(0)
*MCALL #=   216 LV= 1          RT1   CCE
         DS    0H
RT1_TEST122      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE122
         LTORG 
RT1_CCE122      DS 0H
*MEXIT #=   216 LV= 1 RT1
         CL    R6,=A(TRT_F3+4*2)
*MCALL #=   217 LV= 1          RT1   CCE
         DS    0H
RT1_TEST123      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE123
         LTORG 
RT1_CCE123      DS 0H
*MEXIT #=   217 LV= 1 RT1
         CL    R7,=A(L'TRT_F3-4*2)
*MCALL #=   218 LV= 1          RT1   CCE
         DS    0H
RT1_TEST124      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE124
         LTORG 
RT1_CCE124      DS 0H
*MEXIT #=   218 LV= 1 RT1
         LA    R1,TRT_TAB4
         LM    R6,R7,=A(TRT_F4,L'TRT_F4)
         TRTE  R6,R8,X'C' 2 BYTE ARG, 2 BYTE 128K TAB AND NO LIMIT
         BRC   1,*-4      RESTART TRTE UNTIL ENDED
*MCALL #=   219 LV= 1          RT1   CC1
         DS    0H
RT1_TEST125      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL125
         LTORG 
RT1_CCL125      DS 0H
*MEXIT #=   219 LV= 1 RT1
         CL    R8,=A(X'4444')
*MCALL #=   220 LV= 1          RT1   CCE
         DS    0H
RT1_TEST126      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE126
         LTORG 
RT1_CCE126      DS 0H
*MEXIT #=   220 LV= 1 RT1
         CL    R6,=A(TRT_F4+2*2)
*MCALL #=   221 LV= 1          RT1   CCE
         DS    0H
RT1_TEST127      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE127
         LTORG 
RT1_CCE127      DS 0H
*MEXIT #=   221 LV= 1 RT1
         CL    R7,=A(L'TRT_F4-2*2)
*MCALL #=   222 LV= 1          RT1   CCE
         DS    0H
RT1_TEST128      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE128
         LTORG 
RT1_CCE128      DS 0H
*MEXIT #=   222 LV= 1 RT1
         LA    R1,TRT_TAB4
         LM    R6,R7,=A(TRT_F4,L'TRT_F4)
         MVI   TRT_F4+2*2,X'FF' SET HIGH BYTE OF 3RD ENTRY
         TRTE  R6,R8,X'E' 2 BYTE ARG, 2 BYTE 128K TAB AND LIMIT
         BRC   1,*-4      RESTART TRTE UNTIL ENDED
         MVI   TRT_F4+2*2,X'00' RESET HIGH BYTE OF 3RD ENTRY
*MCALL #=   223 LV= 1          RT1   CC0
         DS    0H
RT1_TEST129      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE129
         LTORG 
RT1_CCE129      DS 0H
*MEXIT #=   223 LV= 1 RT1
         CL    R8,=A(0)
*MCALL #=   224 LV= 1          RT1   CCE
         DS    0H
RT1_TEST130      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE130
         LTORG 
RT1_CCE130      DS 0H
*MEXIT #=   224 LV= 1 RT1
         CL    R6,=A(TRT_F4+4*2)
*MCALL #=   225 LV= 1          RT1   CCE
         DS    0H
RT1_TEST131      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE131
         LTORG 
RT1_CCE131      DS 0H
*MEXIT #=   225 LV= 1 RT1
         CL    R7,=A(L'TRT_F4-4*2)
*MCALL #=   226 LV= 1          RT1   CCE
         DS    0H
RT1_TEST132      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE132
         LTORG 
RT1_CCE132      DS 0H
*MEXIT #=   226 LV= 1 RT1
* B9BD'  TRTRE RPI 818
         LA    R1,TRT_TAB1
         LM    R6,R7,=A(TRT_F1+L'TRT_F1-1,L'TRT_F1)
         TRTRE R6,R8
         BRC   1,*-4      RESTART TRTRE UNTIL ENDED
*MCALL #=   227 LV= 1          RT1   CC1
         DS    0H
RT1_TEST133      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL133
         LTORG 
RT1_CCL133      DS 0H
*MEXIT #=   227 LV= 1 RT1
         CL    R8,=A(X'FF')
*MCALL #=   228 LV= 1          RT1   CCE
         DS    0H
RT1_TEST134      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE134
         LTORG 
RT1_CCE134      DS 0H
*MEXIT #=   228 LV= 1 RT1
         CL    R6,=A(TRT_F1+L'TRT_F1-1-1)
*MCALL #=   229 LV= 1          RT1   CCE
         DS    0H
RT1_TEST135      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE135
         LTORG 
RT1_CCE135      DS 0H
*MEXIT #=   229 LV= 1 RT1
         CL    R7,=A(L'TRT_F1-1)
*MCALL #=   230 LV= 1          RT1   CCE
         DS    0H
RT1_TEST136      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE136
         LTORG 
RT1_CCE136      DS 0H
*MEXIT #=   230 LV= 1 RT1
         LA    R1,TRT_TAB2
         LM    R6,R7,=A(TRT_F2+L'TRT_F2-1,L'TRT_F2)
         TRTRE R6,R8,X'4' 1 BYTE ARG, 2 BYTE TABLE
         BRC   1,*-4      RESTART TRTRE UNTIL ENDED
*MCALL #=   231 LV= 1          RT1   CC1
         DS    0H
RT1_TEST137      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL137
         LTORG 
RT1_CCL137      DS 0H
*MEXIT #=   231 LV= 1 RT1
         CL    R8,=A(X'FFFF')
*MCALL #=   232 LV= 1          RT1   CCE
         DS    0H
RT1_TEST138      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE138
         LTORG 
RT1_CCE138      DS 0H
*MEXIT #=   232 LV= 1 RT1
         CL    R6,=A(TRT_F2+L'TRT_F2-1-2)
*MCALL #=   233 LV= 1          RT1   CCE
         DS    0H
RT1_TEST139      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE139
         LTORG 
RT1_CCE139      DS 0H
*MEXIT #=   233 LV= 1 RT1
         CL    R7,=A(L'TRT_F2-2)
*MCALL #=   234 LV= 1          RT1   CCE
         DS    0H
RT1_TEST140      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE140
         LTORG 
RT1_CCE140      DS 0H
*MEXIT #=   234 LV= 1 RT1
         LA    R1,TRT_TAB3
         LM    R6,R7,=A(TRT_F3+L'TRT_F3-2,L'TRT_F3)
         TRTRE R6,R8,X'8' 2 BYTE ARG, 1 BYTE TAB AND NO LIMIT
         BRC   1,*-4      RESTART TRTRE UNTIL ENDED
*MCALL #=   235 LV= 1          RT1   CC1
         DS    0H
RT1_TEST141      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL141
         LTORG 
RT1_CCL141      DS 0H
*MEXIT #=   235 LV= 1 RT1
         CL    R8,=A(X'33')
*MCALL #=   236 LV= 1          RT1   CCE
         DS    0H
RT1_TEST142      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE142
         LTORG 
RT1_CCE142      DS 0H
*MEXIT #=   236 LV= 1 RT1
         CL    R6,=A(TRT_F3+L'TRT_F3-2-1*2)
*MCALL #=   237 LV= 1          RT1   CCE
         DS    0H
RT1_TEST143      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE143
         LTORG 
RT1_CCE143      DS 0H
*MEXIT #=   237 LV= 1 RT1
         CL    R7,=A(L'TRT_F3-1*2)
*MCALL #=   238 LV= 1          RT1   CCE
         DS    0H
RT1_TEST144      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE144
         LTORG 
RT1_CCE144      DS 0H
*MEXIT #=   238 LV= 1 RT1
         LA    R1,TRT_TAB3
         LM    R6,R7,=A(TRT_F3+L'TRT_F3-2,L'TRT_F3)
         MVI   TRT_F3+2*2,X'FF' SET HIGH BYTE OF 3RD ENTRY
         TRTRE R6,R8,X'A' 2 BYTE ARG, 1 BYTE TAB AND LIMIT
         BRC   1,*-4      RESTART TRTRE UNTIL ENDED
         MVI   TRT_F3+2*2,X'00' RESET HIGH BYTE OF 3RD ENTRY
*MCALL #=   239 LV= 1          RT1   CC0
         DS    0H
RT1_TEST145      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE145
         LTORG 
RT1_CCE145      DS 0H
*MEXIT #=   239 LV= 1 RT1
         CL    R8,=A(0)
*MCALL #=   240 LV= 1          RT1   CCE
         DS    0H
RT1_TEST146      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE146
         LTORG 
RT1_CCE146      DS 0H
*MEXIT #=   240 LV= 1 RT1
         CL    R6,=A(TRT_F3+L'TRT_F3-2-4*2)
*MCALL #=   241 LV= 1          RT1   CCE
         DS    0H
RT1_TEST147      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE147
         LTORG 
RT1_CCE147      DS 0H
*MEXIT #=   241 LV= 1 RT1
         CL    R7,=A(L'TRT_F3-4*2)
*MCALL #=   242 LV= 1          RT1   CCE
         DS    0H
RT1_TEST148      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE148
         LTORG 
RT1_CCE148      DS 0H
*MEXIT #=   242 LV= 1 RT1
         LA    R1,TRT_TAB4
         LM    R6,R7,=A(TRT_F4+L'TRT_F4-2,L'TRT_F4)
         TRTRE R6,R8,X'C' 2 BYTE ARG, 2 BYTE 128K TAB AND NO LIMIT
         BRC   1,*-4      RESTART TRTRE UNTIL ENDED
*MCALL #=   243 LV= 1          RT1   CC1
         DS    0H
RT1_TEST149      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL149
         LTORG 
RT1_CCL149      DS 0H
*MEXIT #=   243 LV= 1 RT1
         CL    R8,=A(X'4444')
*MCALL #=   244 LV= 1          RT1   CCE
         DS    0H
RT1_TEST150      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE150
         LTORG 
RT1_CCE150      DS 0H
*MEXIT #=   244 LV= 1 RT1
         CL    R6,=A(TRT_F4+L'TRT_F4-2-1*2)
*MCALL #=   245 LV= 1          RT1   CCE
         DS    0H
RT1_TEST151      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE151
         LTORG 
RT1_CCE151      DS 0H
*MEXIT #=   245 LV= 1 RT1
         CL    R7,=A(L'TRT_F4-1*2)
*MCALL #=   246 LV= 1          RT1   CCE
         DS    0H
RT1_TEST152      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE152
         LTORG 
RT1_CCE152      DS 0H
*MEXIT #=   246 LV= 1 RT1
         LA    R1,TRT_TAB4
         LM    R6,R7,=A(TRT_F4+L'TRT_F4-2,L'TRT_F4)
         MVI   TRT_F4+2*2,X'FF' SET HIGH BYTE OF 3RD ENTRY
         TRTRE R6,R8,X'E' 2 BYTE ARG, 2 BYTE 128K TAB AND LIMIT
         BRC   1,*-4      RESTART TRTRE UNTIL ENDED
         MVI   TRT_F4+2*2,X'00' RESET HIGH BYTE OF 3RD ENTRY
*MCALL #=   247 LV= 1          RT1   CC0
         DS    0H
RT1_TEST153      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE153
         LTORG 
RT1_CCE153      DS 0H
*MEXIT #=   247 LV= 1 RT1
         CL    R8,=A(0)
*MCALL #=   248 LV= 1          RT1   CCE
         DS    0H
RT1_TEST154      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE154
         LTORG 
RT1_CCE154      DS 0H
*MEXIT #=   248 LV= 1 RT1
         CL    R6,=A(TRT_F4+L'TRT_F4-2-4*2)
*MCALL #=   249 LV= 1          RT1   CCE
         DS    0H
RT1_TEST155      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE155
         LTORG 
RT1_CCE155      DS 0H
*MEXIT #=   249 LV= 1 RT1
         CL    R7,=A(L'TRT_F4-4*2)
*MCALL #=   250 LV= 1          RT1   CCE
         DS    0H
RT1_TEST156      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE156
         LTORG 
RT1_CCE156      DS 0H
*MEXIT #=   250 LV= 1 RT1
* C20  MSGFI
         LG    R5,=FL8'20'
         MSGFI R5,30
         CLG   R5,=FL8'600'
*MCALL #=   251 LV= 1          RT1   CCE
         DS    0H
RT1_TEST157      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE157
         LTORG 
RT1_CCE157      DS 0H
*MEXIT #=   251 LV= 1 RT1
* C21  MSFI
         L     R5,=F'20'
         MSFI  R5,30
         CL    R5,=F'600'
*MCALL #=   252 LV= 1          RT1   CCE
         DS    0H
RT1_TEST158      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE158
         LTORG 
RT1_CCE158      DS 0H
*MEXIT #=   252 LV= 1 RT1
* C42  LLHRL
         LG    R5,=C'12345678'
         LLHRL R5,=H'-1'
         CL    R5,=X'0000FFFF'
*MCALL #=   253 LV= 1          RT1   CCE
         DS    0H
RT1_TEST159      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE159
         LTORG 
RT1_CCE159      DS 0H
*MEXIT #=   253 LV= 1 RT1
* C44    LGHRL
         LG    R5,=C'12345678'
         LGHRL R5,=H'-1'
         CLG   R5,=FL8'-1'
*MCALL #=   254 LV= 1          RT1   CCE
         DS    0H
RT1_TEST160      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE160
         LTORG 
RT1_CCE160      DS 0H
*MEXIT #=   254 LV= 1 RT1
* C45    LHRL
         LG    R5,=C'12345678'
         LHRL  R5,=H'-1'
         CL    R5,=F'-1'
*MCALL #=   255 LV= 1          RT1   CCE
         DS    0H
RT1_TEST161      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE161
         LTORG 
RT1_CCE161      DS 0H
*MEXIT #=   255 LV= 1 RT1
* C46    LLGHRL
         LG    R5,=C'12345678'
         LLGHRL R5,=H'-1'
         CLG   R5,=XL8'000000000000FFFF'
*MCALL #=   256 LV= 1          RT1   CCE
         DS    0H
RT1_TEST162      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE162
         LTORG 
RT1_CCE162      DS 0H
*MEXIT #=   256 LV= 1 RT1
* C47    STHRL
         LG    R5,=C'12345678'
         STHRL R5,PWORK
         CLC   PWORK(2),=C'78'
*MCALL #=   257 LV= 1          RT1   CCE
         DS    0H
RT1_TEST163      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE163
         LTORG 
RT1_CCE163      DS 0H
*MEXIT #=   257 LV= 1 RT1
* C48    LGRL
         LG    R5,=C'12345678'
         LGRL  R5,=FL8'-1'
         CLG   R5,=FL8'-1'
*MCALL #=   258 LV= 1          RT1   CCE
         DS    0H
RT1_TEST164      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE164
         LTORG 
RT1_CCE164      DS 0H
*MEXIT #=   258 LV= 1 RT1
* C4B    STGRL
         LG    R5,=C'12345678'
         STGRL R5,PWORK
         CLC   PWORK,=CL8'12345678'
*MCALL #=   259 LV= 1          RT1   CCE
         DS    0H
RT1_TEST165      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE165
         LTORG 
RT1_CCE165      DS 0H
*MEXIT #=   259 LV= 1 RT1
* C4C    LGFRL
         LG    R5,=C'12345678'
         LGFRL R5,=F'-1'
         CLG   R5,=FL8'-1'
*MCALL #=   260 LV= 1          RT1   CCE
         DS    0H
RT1_TEST166      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE166
         LTORG 
RT1_CCE166      DS 0H
*MEXIT #=   260 LV= 1 RT1
* C4D    LRL
         LG    R5,=C'12345678'
         LRL   R5,=F'-1'
         CL    R5,=F'-1'
*MCALL #=   261 LV= 1          RT1   CCE
         DS    0H
RT1_TEST167      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE167
         LTORG 
RT1_CCE167      DS 0H
*MEXIT #=   261 LV= 1 RT1
* C4E    LLGFRL
         LG    R5,=C'12345678'
         LLGFRL R5,=F'-1'
         CLG   R5,=X'00000000FFFFFFFF'
*MCALL #=   262 LV= 1          RT1   CCE
         DS    0H
RT1_TEST168      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE168
         LTORG 
RT1_CCE168      DS 0H
*MEXIT #=   262 LV= 1 RT1
* C4F    STRL
         LG    R5,=C'12345678'
         STRL  R5,PWORK
         CLC   PWORK(4),=C'5678'
*MCALL #=   263 LV= 1          RT1   CCE
         DS    0H
RT1_TEST169      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE169
         LTORG 
RT1_CCE169      DS 0H
*MEXIT #=   263 LV= 1 RT1
* C60    EXRL
         MVC   PWORK(4),=C'ABCD'
         LA    R5,3-1
         EXRL  R5,MVC3
         CLC   PWORK(4),=C'123D'
         B     *+10
MVC3     MVC   PWORK(0),=C'1234'
* C62    PFDRL (NOP ON Z390)
* C64    CGHRL
         LG    R5,=FL8'-1'
         CGHRL R5,=H'-1'
*MCALL #=   264 LV= 1          RT1   CCE
         DS    0H
RT1_TEST170      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE170
         LTORG 
RT1_CCE170      DS 0H
*MEXIT #=   264 LV= 1 RT1
         LG    R5,=FL8'-1'
         CGHRL R5,=H'1'
*MCALL #=   265 LV= 1          RT1   CCL
         DS    0H
RT1_TEST171      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL171
         LTORG 
RT1_CCL171      DS 0H
*MEXIT #=   265 LV= 1 RT1
* C65    CHRL
         LG    R5,=XL8'00000000FFFFFFFF'
         CHRL  R5,=H'-1'
*MCALL #=   266 LV= 1          RT1   CCE
         DS    0H
RT1_TEST172      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE172
         LTORG 
RT1_CCE172      DS 0H
*MEXIT #=   266 LV= 1 RT1
         LG    R5,=XL8'00000000FFFFFFFF'
         CHRL  R5,=H'1'
*MCALL #=   267 LV= 1          RT1   CCL
         DS    0H
RT1_TEST173      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL173
         LTORG 
RT1_CCL173      DS 0H
*MEXIT #=   267 LV= 1 RT1
* C66    CLGHRL
         LG     R5,=XL8'000000000000F1F2'
         CLGHRL R5,=X'F1F2'
*MCALL #=   268 LV= 1          RT1    CCE
         DS    0H
RT1_TEST174      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE174
         LTORG 
RT1_CCE174      DS 0H
*MEXIT #=   268 LV= 1 RT1
         LG     R5,=XL8'FFFFFFFFFFFFFFFF'
         CLGHRL R5,=X'FFFF'
*MCALL #=   269 LV= 1          RT1    CCH
         DS    0H
RT1_TEST175      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH175
         LTORG 
RT1_CCH175      DS 0H
*MEXIT #=   269 LV= 1 RT1
* C67    CLHRL
         LG     R5,=XL8'000000000000F1F2'
         CLHRL  R5,=X'F1F2'
*MCALL #=   270 LV= 1          RT1    CCE
         DS    0H
RT1_TEST176      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE176
         LTORG 
RT1_CCE176      DS 0H
*MEXIT #=   270 LV= 1 RT1
         LG     R5,=XL8'00000000FFFFFFFF'
         CLHRL  R5,=X'FFFF'
*MCALL #=   271 LV= 1          RT1    CCH
         DS    0H
RT1_TEST177      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH177
         LTORG 
RT1_CCH177      DS 0H
*MEXIT #=   271 LV= 1 RT1
* C68    CGRL
         LG    R5,=XL8'F1F2F3F4F5F6F7F8'
         CGRL  R5,=X'F1F2F3F4F5F6F7F8'
*MCALL #=   272 LV= 1          RT1   CCE
         DS    0H
RT1_TEST178      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE178
         LTORG 
RT1_CCE178      DS 0H
*MEXIT #=   272 LV= 1 RT1
         LG    R5,=XL8'F1F2F3F4F5F6F7F8'
         CGRL  R5,=FL8'1'
*MCALL #=   273 LV= 1          RT1   CCL
         DS    0H
RT1_TEST179      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL179
         LTORG 
RT1_CCL179      DS 0H
*MEXIT #=   273 LV= 1 RT1
* C6A    CLGRL
         LG    R5,=XL8'F1F2F3F4F5F6F7F8'
         CLGRL R5,=X'F1F2F3F4F5F6F7F8'
*MCALL #=   274 LV= 1          RT1   CCE
         DS    0H
RT1_TEST180      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE180
         LTORG 
RT1_CCE180      DS 0H
*MEXIT #=   274 LV= 1 RT1
         LG    R5,=XL8'F1F2F3F4F5F6F7F8'
         CLGRL R5,=FL8'1'
*MCALL #=   275 LV= 1          RT1   CCH
         DS    0H
RT1_TEST181      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH181
         LTORG 
RT1_CCH181      DS 0H
*MEXIT #=   275 LV= 1 RT1
* C6C    CGFRL
         LG    R5,=FL8'-1'
         CGFRL R5,=F'-1'
*MCALL #=   276 LV= 1          RT1   CCE
         DS    0H
RT1_TEST182      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE182
         LTORG 
RT1_CCE182      DS 0H
*MEXIT #=   276 LV= 1 RT1
         LG    R5,=FL8'-1'
         CGFRL R5,=F'1'
*MCALL #=   277 LV= 1          RT1   CCL
         DS    0H
RT1_TEST183      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL183
         LTORG 
RT1_CCL183      DS 0H
*MEXIT #=   277 LV= 1 RT1
* C6D    CRL
         LG    R5,=2F'0,-1'
         CRL   R5,=F'-1'
*MCALL #=   278 LV= 1          RT1   CCE
         DS    0H
RT1_TEST184      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE184
         LTORG 
RT1_CCE184      DS 0H
*MEXIT #=   278 LV= 1 RT1
         LG    R5,=2F'0,-1'
         CRL   R5,=F'1'
*MCALL #=   279 LV= 1          RT1   CCL
         DS    0H
RT1_TEST185      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL185
         LTORG 
RT1_CCL185      DS 0H
*MEXIT #=   279 LV= 1 RT1
* C6E    CLGFRL
         LG    R5,=2F'0,-1'
         CLGFRL R5,=F'-1'
*MCALL #=   280 LV= 1          RT1   CCE
         DS    0H
RT1_TEST186      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE186
         LTORG 
RT1_CCE186      DS 0H
*MEXIT #=   280 LV= 1 RT1
         LG    R5,=2F'0,-1'
         CLGFRL R5,=F'1'
*MCALL #=   281 LV= 1          RT1   CCH
         DS    0H
RT1_TEST187      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH187
         LTORG 
RT1_CCH187      DS 0H
*MEXIT #=   281 LV= 1 RT1
* C6F    CLRL
         LG    R5,=2F'0,-1'
         CLRL  R5,=F'-1'
*MCALL #=   282 LV= 1          RT1   CCE
         DS    0H
RT1_TEST188      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE188
         LTORG 
RT1_CCE188      DS 0H
*MEXIT #=   282 LV= 1 RT1
         LG    R5,=2F'0,-1'
         CLRL  R5,=F'1'
*MCALL #=   283 LV= 1          RT1   CCH
         DS    0H
RT1_TEST189      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH189
         LTORG 
RT1_CCH189      DS 0H
*MEXIT #=   283 LV= 1 RT1
* C80    MVCOS   UPDATE PRIOR RPI 606 SUPPORT FOR CC 0/3 AND 31 BIT LEN
         MVC   PWORK,=C'12345678'
         LA    R5,3        R5 = MVCOS LENGTH
         LHI   R0,0        R0 = ALL CONTROL BITS OFF
         CLI   =C'A',C'B'  SET CC NZ
         MVCOS PWORK+1,=CL3'ABC',R5
*MCALL #=   284 LV= 1          RT1   CCE
         DS    0H
RT1_TEST190      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE190
         LTORG 
RT1_CCE190      DS 0H
*MEXIT #=   284 LV= 1 RT1
         CLC   PWORK,=C'1ABC5678'
*MCALL #=   285 LV= 1          RT1   CCE
         DS    0H
RT1_TEST191      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE191
         LTORG 
RT1_CCE191      DS 0H
*MEXIT #=   285 LV= 1 RT1
*MCALL #=   286 LV= 1          GETMAIN R,LV=8000
         L    1,=A(8000)  RPI 117
         LA    0,B'00'
         SVC   4 GMAIN R0=(X'02'=31B,X'01'=COND),R1=LEN OUT(R0=L,R1=A)
*MEXIT #=   286 LV= 1 GETMAIN
         LR    R6,R1
         LHI   R7,8000     R7 = MVCOS LENGTH
         LHI   R0,0        R0 = ALL CONTROL BITS OFF
         CLI   =C'A',C'B'  SET CC NZ
         LA    R5,0
         MVCOS 0(R6),0(R5),R7  RPI 859 COPY PSA TO GETMAIN AREA
*MCALL #=   287 LV= 1          RT1   CC3
         DS    0H
RT1_TEST192      BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC3192
         LTORG 
RT1_CC3192      DS 0H
*MEXIT #=   287 LV= 1 RT1
         LR    R0,R5
         LR    R1,R7
         CLCL  R6,R0           RPI 859 COPMARE PAS TO GETMAIN AREA
*MCALL #=   288 LV= 1          RT1   CCE
         DS    0H
RT1_TEST193      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE193
         LTORG 
RT1_CCE193      DS 0H
*MEXIT #=   288 LV= 1 RT1
* E332   LTGF
         LTGF  R5,=F'-1'
*MCALL #=   289 LV= 1          RT1   CCL
         DS    0H
RT1_TEST194      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL194
         LTORG 
RT1_CCL194      DS 0H
*MEXIT #=   289 LV= 1 RT1
         CLG   R5,=FL8'-1'
*MCALL #=   290 LV= 1          RT1   CCE
         DS    0H
RT1_TEST195      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE195
         LTORG 
RT1_CCE195      DS 0H
*MEXIT #=   290 LV= 1 RT1
         LTGF  R5,=F'0'
*MCALL #=   291 LV= 1          RT1   CCE
         DS    0H
RT1_TEST196      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE196
         LTORG 
RT1_CCE196      DS 0H
*MEXIT #=   291 LV= 1 RT1
         CLG   R5,=FL8'0'
*MCALL #=   292 LV= 1          RT1   CCE
         DS    0H
RT1_TEST197      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE197
         LTORG 
RT1_CCE197      DS 0H
*MEXIT #=   292 LV= 1 RT1
         LTGF  R5,=F'1'
*MCALL #=   293 LV= 1          RT1   CCH
         DS    0H
RT1_TEST198      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH198
         LTORG 
RT1_CCH198      DS 0H
*MEXIT #=   293 LV= 1 RT1
         CLG   R5,=FL8'1'
*MCALL #=   294 LV= 1          RT1   CCE
         DS    0H
RT1_TEST199      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE199
         LTORG 
RT1_CCE199      DS 0H
*MEXIT #=   294 LV= 1 RT1
* E334   CGH
         LG    R5,=FL8'-1'
         CGH   R5,=H'-1'
*MCALL #=   295 LV= 1          RT1   CCE
         DS    0H
RT1_TEST200      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE200
         LTORG 
RT1_CCE200      DS 0H
*MEXIT #=   295 LV= 1 RT1
         LG    R5,=FL8'-1'
         CGH   R5,=H'1'
*MCALL #=   296 LV= 1          RT1   CCL
         DS    0H
RT1_TEST201      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL201
         LTORG 
RT1_CCL201      DS 0H
*MEXIT #=   296 LV= 1 RT1
* E336   PFD   PREFETCH IS A NOP
         PFD   0,0
* E35C   MFY
         LM    R6,R7,=A(0,X'10000')
         CLI   =C'A',C'B' SET CCL
         MFY   R6,=A(X'10000')
*MCALL #=   297 LV= 1          RT1   CCL
         DS    0H
RT1_TEST202      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL202
         LTORG 
RT1_CCL202      DS 0H
*MEXIT #=   297 LV= 1 RT1
         CL    R6,=A(1)
*MCALL #=   298 LV= 1          RT1   CCE
         DS    0H
RT1_TEST203      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE203
         LTORG 
RT1_CCE203      DS 0H
*MEXIT #=   298 LV= 1 RT1
         CL    R7,=A(0)
*MCALL #=   299 LV= 1          RT1   CCE
         DS    0H
RT1_TEST204      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE204
         LTORG 
RT1_CCE204      DS 0H
*MEXIT #=   299 LV= 1 RT1
* E375   LAEY
         LAEY  R5,123
         CL    R5,=A(123)
*MCALL #=   300 LV= 1          RT1   CCE
         DS    0H
RT1_TEST205      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE205
         LTORG 
RT1_CCE205      DS 0H
*MEXIT #=   300 LV= 1 RT1
* E37C   MHY
         L     R5,=A(10000)
         MHY   R5,=H'1000'
         CL    R5,=A(10000000)
*MCALL #=   301 LV= 1          RT1   CCE
         DS    0H
RT1_TEST206      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE206
         LTORG 
RT1_CCE206      DS 0H
*MEXIT #=   301 LV= 1 RT1
* E544   MVHHI
         MVC   PWORK,=C'12345678'
         MVHHI PWORK+2,C'AB'
         CLC   PWORK,=C'12AB5678'
*MCALL #=   302 LV= 1          RT1   CCE
         DS    0H
RT1_TEST207      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE207
         LTORG 
RT1_CCE207      DS 0H
*MEXIT #=   302 LV= 1 RT1
* E548   MVGHI
         MVC   PWORK,=C'12345678'
         MVGHI PWORK,-1
         CLC   PWORK,=FL8'-1'
*MCALL #=   303 LV= 1          RT1   CCE
         DS    0H
RT1_TEST208      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE208
         LTORG 
RT1_CCE208      DS 0H
*MEXIT #=   303 LV= 1 RT1
* E54C   MVHI
         MVC   PWORK,=C'12345678'
         MVHI  PWORK+2,-1
         CLC   PWORK,=X'F1F2FFFFFFFFF7F8'
*MCALL #=   304 LV= 1          RT1   CCE
         DS    0H
RT1_TEST209      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE209
         LTORG 
RT1_CCE209      DS 0H
*MEXIT #=   304 LV= 1 RT1
* E554   CHHSI
         CHHSI =H'-1',-1
*MCALL #=   305 LV= 1          RT1   CCE
         DS    0H
RT1_TEST210      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE210
         LTORG 
RT1_CCE210      DS 0H
*MEXIT #=   305 LV= 1 RT1
         CHHSI =H'1',-1
*MCALL #=   306 LV= 1          RT1   CCH
         DS    0H
RT1_TEST211      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH211
         LTORG 
RT1_CCH211      DS 0H
*MEXIT #=   306 LV= 1 RT1
* E555   CLHHSI
         CLHHSI =H'-1',-1
*MCALL #=   307 LV= 1          RT1   CCE
         DS    0H
RT1_TEST212      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE212
         LTORG 
RT1_CCE212      DS 0H
*MEXIT #=   307 LV= 1 RT1
         CLHHSI =H'1',-1
*MCALL #=   308 LV= 1          RT1   CCL
         DS    0H
RT1_TEST213      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL213
         LTORG 
RT1_CCL213      DS 0H
*MEXIT #=   308 LV= 1 RT1
* E558   CGHSI
         CGHSI =FL8'-1',-1
*MCALL #=   309 LV= 1          RT1   CCE
         DS    0H
RT1_TEST214      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE214
         LTORG 
RT1_CCE214      DS 0H
*MEXIT #=   309 LV= 1 RT1
         CGHSI =FL8'1',-1
*MCALL #=   310 LV= 1          RT1   CCH
         DS    0H
RT1_TEST215      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH215
         LTORG 
RT1_CCH215      DS 0H
*MEXIT #=   310 LV= 1 RT1
* E559   CLGHSI
         CLGHSI =FL2'0,0,0,-1',-1
*MCALL #=   311 LV= 1          RT1   CCE
         DS    0H
RT1_TEST216      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE216
         LTORG 
RT1_CCE216      DS 0H
*MEXIT #=   311 LV= 1 RT1
         CLGHSI =FL8'1',-1
*MCALL #=   312 LV= 1          RT1   CCL
         DS    0H
RT1_TEST217      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL217
         LTORG 
RT1_CCL217      DS 0H
*MEXIT #=   312 LV= 1 RT1
* E55C   CHSI
         CHSI  =F'-1',-1
*MCALL #=   313 LV= 1          RT1   CCE
         DS    0H
RT1_TEST218      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE218
         LTORG 
RT1_CCE218      DS 0H
*MEXIT #=   313 LV= 1 RT1
         CHSI  =F'1',-1
*MCALL #=   314 LV= 1          RT1   CCH
         DS    0H
RT1_TEST219      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH219
         LTORG 
RT1_CCH219      DS 0H
*MEXIT #=   314 LV= 1 RT1
* E55D   CLFHSI
         CLFHSI =FL2'0,-1',-1
*MCALL #=   315 LV= 1          RT1   CCE
         DS    0H
RT1_TEST220      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE220
         LTORG 
RT1_CCE220      DS 0H
*MEXIT #=   315 LV= 1 RT1
         CLFHSI =F'1',-1
*MCALL #=   316 LV= 1          RT1   CCL
         DS    0H
RT1_TEST221      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL221
         LTORG 
RT1_CCL221      DS 0H
*MEXIT #=   316 LV= 1 RT1
* EB4C   ECAG  EXTRACT CACHE ATTRIBUTE NOT YET
* EB6A   ASI
         MVC   WORD,=F'12'
         ASI   WORD,12
*MCALL #=   317 LV= 1          RT1   CCH
         DS    0H
RT1_TEST222      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH222
         LTORG 
RT1_CCH222      DS 0H
*MEXIT #=   317 LV= 1 RT1
         CLC   WORD,=F'24'
*MCALL #=   318 LV= 1          RT1   CCE
         DS    0H
RT1_TEST223      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE223
         LTORG 
RT1_CCE223      DS 0H
*MEXIT #=   318 LV= 1 RT1
         MVC   WORD,=F'12'
         ASI   WORD,-12
*MCALL #=   319 LV= 1          RT1   CC0
         DS    0H
RT1_TEST224      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE224
         LTORG 
RT1_CCE224      DS 0H
*MEXIT #=   319 LV= 1 RT1
         CLC   WORD,=F'0'
*MCALL #=   320 LV= 1          RT1   CCE
         DS    0H
RT1_TEST225      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE225
         LTORG 
RT1_CCE225      DS 0H
*MEXIT #=   320 LV= 1 RT1
         MVC   WORD,=F'12'   RPI 589 NEW TESTS
         ASI   WORD,-12
*MCALL #=   321 LV= 1          RT1   CC0
         DS    0H
RT1_TEST226      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE226
         LTORG 
RT1_CCE226      DS 0H
*MEXIT #=   321 LV= 1 RT1
         CLC   WORD,=F'0'
*MCALL #=   322 LV= 1          RT1   CCE
         DS    0H
RT1_TEST227      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE227
         LTORG 
RT1_CCE227      DS 0H
*MEXIT #=   322 LV= 1 RT1
         MVC   WORD,=F'12'
         ASI   WORD,-24
*MCALL #=   323 LV= 1          RT1   CC1
         DS    0H
RT1_TEST228      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL228
         LTORG 
RT1_CCL228      DS 0H
*MEXIT #=   323 LV= 1 RT1
         CLC   WORD,=F'-12'
*MCALL #=   324 LV= 1          RT1   CCE
         DS    0H
RT1_TEST229      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE229
         LTORG 
RT1_CCE229      DS 0H
*MEXIT #=   324 LV= 1 RT1
* EB6E   ALSI
         MVC   WORD,=F'12'
         ALSI  WORD,12
*MCALL #=   325 LV= 1          RT1   CC1
         DS    0H
RT1_TEST230      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL230
         LTORG 
RT1_CCL230      DS 0H
*MEXIT #=   325 LV= 1 RT1
         CLC   WORD,=F'24'
*MCALL #=   326 LV= 1          RT1   CCE
         DS    0H
RT1_TEST231      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE231
         LTORG 
RT1_CCE231      DS 0H
*MEXIT #=   326 LV= 1 RT1
         MVC   WORD,=F'3'  RPI 859 CORRECT AND ADD TESTS FOR NEG I2
         ALSI  WORD,-1
*MCALL #=   327 LV= 1          RT1   CC1 NZ,NC
         DS    0H
RT1_TEST232      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL232
         LTORG 
RT1_CCL232      DS 0H
*MEXIT #=   327 LV= 1 RT1
         CLC   WORD,=F'2'
*MCALL #=   328 LV= 1          RT1   CCE
         DS    0H
RT1_TEST233      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE233
         LTORG 
RT1_CCE233      DS 0H
*MEXIT #=   328 LV= 1 RT1
         MVC   WORD,=F'1'
         ALSI  WORD,-1
*MCALL #=   329 LV= 1          RT1   CC0  Z,NC
         DS    0H
RT1_TEST234      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE234
         LTORG 
RT1_CCE234      DS 0H
*MEXIT #=   329 LV= 1 RT1
         CLC   WORD,=F'0'
*MCALL #=   330 LV= 1          RT1   CCE
         DS    0H
RT1_TEST235      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE235
         LTORG 
RT1_CCE235      DS 0H
*MEXIT #=   330 LV= 1 RT1
         MVC   WORD,=F'1'
         ALSI  WORD,-2
*MCALL #=   331 LV= 1          RT1   CC3 NZ,B
         DS    0H
RT1_TEST236      BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC3236
         LTORG 
RT1_CC3236      DS 0H
*MEXIT #=   331 LV= 1 RT1
         CLC   WORD,=F'-1'
*MCALL #=   332 LV= 1          RT1   CCE
         DS    0H
RT1_TEST237      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE237
         LTORG 
RT1_CCE237      DS 0H
*MEXIT #=   332 LV= 1 RT1
* EB7A   AGSI
         MVC   DWORD,=FL8'12'
         AGSI  DWORD,12
*MCALL #=   333 LV= 1          RT1   CCH
         DS    0H
RT1_TEST238      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH238
         LTORG 
RT1_CCH238      DS 0H
*MEXIT #=   333 LV= 1 RT1
         CLC   DWORD,=FL8'24'
*MCALL #=   334 LV= 1          RT1   CCE
         DS    0H
RT1_TEST239      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE239
         LTORG 
RT1_CCE239      DS 0H
*MEXIT #=   334 LV= 1 RT1
         MVC   DWORD,=FL8'12'
         AGSI  DWORD,-12
*MCALL #=   335 LV= 1          RT1   CC0
         DS    0H
RT1_TEST240      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE240
         LTORG 
RT1_CCE240      DS 0H
*MEXIT #=   335 LV= 1 RT1
         CLC   DWORD,=FL8'0'
*MCALL #=   336 LV= 1          RT1   CCE
         DS    0H
RT1_TEST241      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE241
         LTORG 
RT1_CCE241      DS 0H
*MEXIT #=   336 LV= 1 RT1
* EB7E   ALGSI
         MVC   DWORD,=FL8'12'
         ALGSI DWORD,12
*MCALL #=   337 LV= 1          RT1   CC1
         DS    0H
RT1_TEST242      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL242
         LTORG 
RT1_CCL242      DS 0H
*MEXIT #=   337 LV= 1 RT1
         CLC   DWORD,=FL8'24'
*MCALL #=   338 LV= 1          RT1   CCE
         DS    0H
RT1_TEST243      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE243
         LTORG 
RT1_CCE243      DS 0H
*MEXIT #=   338 LV= 1 RT1
         MVC   DWORD,=FL8'3'  RPI 859 CORRECT AND ADD TESTS FOR NEG I2
         ALGSI DWORD,-1
*MCALL #=   339 LV= 1          RT1   CC1  NZ,NB
         DS    0H
RT1_TEST244      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL244
         LTORG 
RT1_CCL244      DS 0H
*MEXIT #=   339 LV= 1 RT1
         CLC   DWORD,=FL8'2'
*MCALL #=   340 LV= 1          RT1   CCE
         DS    0H
RT1_TEST245      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE245
         LTORG 
RT1_CCE245      DS 0H
*MEXIT #=   340 LV= 1 RT1
         MVC   DWORD,=FL8'1'
         ALGSI DWORD,-1
*MCALL #=   341 LV= 1          RT1   CC0 Z,NB
         DS    0H
RT1_TEST246      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE246
         LTORG 
RT1_CCE246      DS 0H
*MEXIT #=   341 LV= 1 RT1
         CLC   DWORD,=FL8'0'
*MCALL #=   342 LV= 1          RT1   CCE
         DS    0H
RT1_TEST247      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE247
         LTORG 
RT1_CCE247      DS 0H
*MEXIT #=   342 LV= 1 RT1
         MVC   DWORD,=FL8'1'
         ALGSI DWORD,-2
*MCALL #=   343 LV= 1          RT1   CC3  NZ,B
         DS    0H
RT1_TEST248      BAS   RT1_LINK,RT1_TEST_CC3
         USING *,RT1_LINK
         B     RT1_CC3248
         LTORG 
RT1_CC3248      DS 0H
*MEXIT #=   343 LV= 1 RT1
         CLC   DWORD,=FL8'-1'
*MCALL #=   344 LV= 1          RT1   CCE
         DS    0H
RT1_TEST249      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE249
         LTORG 
RT1_CCE249      DS 0H
*MEXIT #=   344 LV= 1 RT1
* EC54   RNSBG
         LG    R5,=C'12345678'
         LG    R6,=C'ABCDEFGC'
         RNSBG R5,R6,0,7,64-8  MOVE C TO FIRST CHAR AND AND WITH F1= A
*MCALL #=   345 LV= 1          RT1   CC1
         DS    0H
RT1_TEST250      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL250
         LTORG 
RT1_CCL250      DS 0H
*MEXIT #=   345 LV= 1 RT1
         CLG   R5,=C'A2345678'
*MCALL #=   346 LV= 1          RT1   CCE
         DS    0H
RT1_TEST251      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE251
         LTORG 
RT1_CCE251      DS 0H
*MEXIT #=   346 LV= 1 RT1
         LG    R5,=C'12345672'
         LG    R6,=C'ABCDEFGC'
         RNSBG R5,R6,32,39,24  MOVE C TO 5TH CHAR AND AND WITH F5=A
*MCALL #=   347 LV= 1          RT1   CC1
         DS    0H
RT1_TEST252      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL252
         LTORG 
RT1_CCL252      DS 0H
*MEXIT #=   347 LV= 1 RT1
         CLG   R5,=C'1234A672'
*MCALL #=   348 LV= 1          RT1   CCE
         DS    0H
RT1_TEST253      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE253
         LTORG 
RT1_CCE253      DS 0H
*MEXIT #=   348 LV= 1 RT1
         LG    R5,=C'12345672'
         LG    R6,=C'ABCDEFGC'
         RNSBG R5,R6,56,7,0  AND 21 WITH CA = BA IN LAST AND FIRST
*MCALL #=   349 LV= 1          RT1   CC1
         DS    0H
RT1_TEST254      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL254
         LTORG 
RT1_CCL254      DS 0H
*MEXIT #=   349 LV= 1 RT1
         CLG   R5,=C'A234567B'
*MCALL #=   350 LV= 1          RT1   CCE
         DS    0H
RT1_TEST255      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE255
         LTORG 
RT1_CCE255      DS 0H
*MEXIT #=   350 LV= 1 RT1
* EC54T  RNSBGT
         LG    R5,=C'12345678'
         LG    R6,=C'ABCDEFGC'
         RNSBGT R5,R6,0,7,64-8  MOVE C TO FIRST CHAR AND AND WITH F1= A
*MCALL #=   351 LV= 1          RT1   CC1
         DS    0H
RT1_TEST256      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL256
         LTORG 
RT1_CCL256      DS 0H
*MEXIT #=   351 LV= 1 RT1
         CLG   R5,=C'12345678'
*MCALL #=   352 LV= 1          RT1   CCE
         DS    0H
RT1_TEST257      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE257
         LTORG 
RT1_CCE257      DS 0H
*MEXIT #=   352 LV= 1 RT1
         LG    R5,=C'12345672'
         LG    R6,=C'ABCDEFGC'
         RNSBGT R5,R6,32,39,24  MOVE C TO 5TH CHAR AND AND WITH F5=A
*MCALL #=   353 LV= 1          RT1   CC1
         DS    0H
RT1_TEST258      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL258
         LTORG 
RT1_CCL258      DS 0H
*MEXIT #=   353 LV= 1 RT1
         CLG   R5,=C'12345672'
*MCALL #=   354 LV= 1          RT1   CCE
         DS    0H
RT1_TEST259      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE259
         LTORG 
RT1_CCE259      DS 0H
*MEXIT #=   354 LV= 1 RT1
         LG    R5,=C'12345672'
         LG    R6,=C'ABCDEFGC'
         RNSBGT R5,R6,56,7,0  AND 21 WITH CA = BA IN LAST AND FIRST
*MCALL #=   355 LV= 1          RT1   CC1
         DS    0H
RT1_TEST260      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL260
         LTORG 
RT1_CCL260      DS 0H
*MEXIT #=   355 LV= 1 RT1
         CLG   R5,=C'12345672'
*MCALL #=   356 LV= 1          RT1   CCE
         DS    0H
RT1_TEST261      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE261
         LTORG 
RT1_CCE261      DS 0H
*MEXIT #=   356 LV= 1 RT1
         LG    R5,=C'12345672'
         LG    R6,=X'00FFFFFFFFFFFF00'
         RNSBGT R5,R6,56,7,0  AND 21 WITH CA = BA IN LAST AND FIRST
*MCALL #=   357 LV= 1          RT1   CC0
         DS    0H
RT1_TEST262      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE262
         LTORG 
RT1_CCE262      DS 0H
*MEXIT #=   357 LV= 1 RT1
         CLG   R5,=C'12345672'
*MCALL #=   358 LV= 1          RT1   CCE
         DS    0H
RT1_TEST263      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE263
         LTORG 
RT1_CCE263      DS 0H
*MEXIT #=   358 LV= 1 RT1
* EC55   RISBG
         LG    R5,=C'12345678'
         LG    R6,=C'ABCDEFGC'
         RISBG R5,R6,0,7,64-8  MOVE C TO FIRST CHAR AND INSERT
*MCALL #=   359 LV= 1          RT1   CC1
         DS    0H
RT1_TEST264      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL264
         LTORG 
RT1_CCL264      DS 0H
*MEXIT #=   359 LV= 1 RT1
         CLG   R5,=C'C2345678'
*MCALL #=   360 LV= 1          RT1   CCE
         DS    0H
RT1_TEST265      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE265
         LTORG 
RT1_CCE265      DS 0H
*MEXIT #=   360 LV= 1 RT1
         LG    R5,=C'12345678'
         LG    R6,=C'ABCDEFGC'
         RISBG R5,R6,32,39,24  MOVE C TO F5 AND INSERT 0'S
*MCALL #=   361 LV= 1          RT1   CC1
         DS    0H
RT1_TEST266      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL266
         LTORG 
RT1_CCL266      DS 0H
*MEXIT #=   361 LV= 1 RT1
         CLG   R5,=C'1234C678'
*MCALL #=   362 LV= 1          RT1   CCE
         DS    0H
RT1_TEST267      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE267
         LTORG 
RT1_CCE267      DS 0H
*MEXIT #=   362 LV= 1 RT1
* EC55Z  RISBGZ
         LG    R5,=C'12345678'
         LG    R6,=C'ABCDEFGC'
         RISBGZ R5,R6,0,7,64-8  MOVE C TO FIRST CHAR AND INSERT 0'S
*MCALL #=   363 LV= 1          RT1   CC1
         DS    0H
RT1_TEST268      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL268
         LTORG 
RT1_CCL268      DS 0H
*MEXIT #=   363 LV= 1 RT1
         CLG   R5,=X'C300000000000000'
*MCALL #=   364 LV= 1          RT1   CCE
         DS    0H
RT1_TEST269      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE269
         LTORG 
RT1_CCE269      DS 0H
*MEXIT #=   364 LV= 1 RT1
         LG    R5,=C'12345678'
         LG    R6,=C'ABCDEFGC'
         RISBGZ R5,R6,32,39,24  MOVE C TO F5 AND INSERT 0'S
*MCALL #=   365 LV= 1          RT1   CC2
         DS    0H
RT1_TEST270      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH270
         LTORG 
RT1_CCH270      DS 0H
*MEXIT #=   365 LV= 1 RT1
         CLG   R5,=X'00000000C3000000'
*MCALL #=   366 LV= 1          RT1   CCE
         DS    0H
RT1_TEST271      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE271
         LTORG 
RT1_CCE271      DS 0H
*MEXIT #=   366 LV= 1 RT1
         LG    R5,=FL8'-1'
         LG    R6,=C'ABCDEFGC'
         RISBGZ R5,R6,32,39,24  MOVE C TO F5 AND INSERT 0'S
*MCALL #=   367 LV= 1          RT1   CC2
         DS    0H
RT1_TEST272      BAS   RT1_LINK,RT1_TEST_CC2
         USING *,RT1_LINK
         B     RT1_CCH272
         LTORG 
RT1_CCH272      DS 0H
*MEXIT #=   367 LV= 1 RT1
         CLG   R5,=X'00000000C3000000'
*MCALL #=   368 LV= 1          RT1   CCE
         DS    0H
RT1_TEST273      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE273
         LTORG 
RT1_CCE273      DS 0H
*MEXIT #=   368 LV= 1 RT1
         LG    R5,=FL8'-1'
         LG    R6,=X'FFFFFFFFFFFFFF00'
         RISBGZ R5,R6,32,39,24  MOVE C TO F5 AND INSERT 0'S
*MCALL #=   369 LV= 1          RT1   CC0
         DS    0H
RT1_TEST274      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE274
         LTORG 
RT1_CCE274      DS 0H
*MEXIT #=   369 LV= 1 RT1
         CLG   R5,=X'0000000000000000'
*MCALL #=   370 LV= 1          RT1   CCE
         DS    0H
RT1_TEST275      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE275
         LTORG 
RT1_CCE275      DS 0H
*MEXIT #=   370 LV= 1 RT1
* EC56   ROSBG
         LG    R5,=C'12345678'
         LG    R6,=C'ABCDEFGC'
         ROSBG R5,R6,0,7,64-8  MOVE C TO FIRST CHAR AND OR WITH F1= 3
*MCALL #=   371 LV= 1          RT1   CC1
         DS    0H
RT1_TEST276      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL276
         LTORG 
RT1_CCL276      DS 0H
*MEXIT #=   371 LV= 1 RT1
         CLG   R5,=C'32345678'
*MCALL #=   372 LV= 1          RT1   CCE
         DS    0H
RT1_TEST277      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE277
         LTORG 
RT1_CCE277      DS 0H
*MEXIT #=   372 LV= 1 RT1
         LG    R5,=C'12345672'
         LG    R6,=C'ABCDEFGC'
         ROSBG R5,R6,32,39,24  MOVE C TO 5TH CHAR AND AND WITH F5= 7
*MCALL #=   373 LV= 1          RT1   CC1
         DS    0H
RT1_TEST278      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL278
         LTORG 
RT1_CCL278      DS 0H
*MEXIT #=   373 LV= 1 RT1
         CLG   R5,=C'12347672'
*MCALL #=   374 LV= 1          RT1   CCE
         DS    0H
RT1_TEST279      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE279
         LTORG 
RT1_CCE279      DS 0H
*MEXIT #=   374 LV= 1 RT1
         LG    R5,=C'12345672'
         LG    R6,=C'ABCDEFGC'
         ROSBG R5,R6,56,7,0  AND 21 WITH CA = 31 IN LAST AND FIRST
*MCALL #=   375 LV= 1          RT1   CC1
         DS    0H
RT1_TEST280      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL280
         LTORG 
RT1_CCL280      DS 0H
*MEXIT #=   375 LV= 1 RT1
         CLG   R5,=C'12345673'
*MCALL #=   376 LV= 1          RT1   CCE
         DS    0H
RT1_TEST281      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE281
         LTORG 
RT1_CCE281      DS 0H
*MEXIT #=   376 LV= 1 RT1
* EC56T  ROSBGT
         LG    R5,=C'12345678'
         LG    R6,=C'ABCDEFGC'
         ROSBGT R5,R6,0,7,64-8  MOVE C TO FIRST CHAR AND OR WITH F1= 3
*MCALL #=   377 LV= 1          RT1   CC1
         DS    0H
RT1_TEST282      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL282
         LTORG 
RT1_CCL282      DS 0H
*MEXIT #=   377 LV= 1 RT1
         CLG   R5,=C'12345678'
*MCALL #=   378 LV= 1          RT1   CCE
         DS    0H
RT1_TEST283      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE283
         LTORG 
RT1_CCE283      DS 0H
*MEXIT #=   378 LV= 1 RT1
         LG    R5,=C'12345672'
         LG    R6,=C'ABCDEFGC'
         ROSBGT R5,R6,32,39,24  MOVE C TO 5TH CHAR AND OR WITH F5= 7
*MCALL #=   379 LV= 1          RT1   CC1
         DS    0H
RT1_TEST284      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL284
         LTORG 
RT1_CCL284      DS 0H
*MEXIT #=   379 LV= 1 RT1
         CLG   R5,=C'12345672'
*MCALL #=   380 LV= 1          RT1   CCE
         DS    0H
RT1_TEST285      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE285
         LTORG 
RT1_CCE285      DS 0H
*MEXIT #=   380 LV= 1 RT1
         LG    R5,=C'12345672'
         LG    R6,=C'ABCDEFGC'
         ROSBGT R5,R6,56,7,0  OR 21 WITH CA = 31 IN LAST AND FIRST
*MCALL #=   381 LV= 1          RT1   CC1
         DS    0H
RT1_TEST286      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL286
         LTORG 
RT1_CCL286      DS 0H
*MEXIT #=   381 LV= 1 RT1
         CLG   R5,=C'12345672'
*MCALL #=   382 LV= 1          RT1   CCE
         DS    0H
RT1_TEST287      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE287
         LTORG 
RT1_CCE287      DS 0H
*MEXIT #=   382 LV= 1 RT1
         LG    R5,=X'00FFFFFFFFFFFF00'
         LG    R6,=X'0000FFFFFFFFFFFF'
         ROSBG R5,R6,56,7,8  AND 21 WITH CA = 31 IN LAST AND FIRST
*MCALL #=   383 LV= 1          RT1   CC0
         DS    0H
RT1_TEST288      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE288
         LTORG 
RT1_CCE288      DS 0H
*MEXIT #=   383 LV= 1 RT1
         CLG   R5,=X'00FFFFFFFFFFFF00'
*MCALL #=   384 LV= 1          RT1   CCE
         DS    0H
RT1_TEST289      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE289
         LTORG 
RT1_CCE289      DS 0H
*MEXIT #=   384 LV= 1 RT1
* EC57   RXSBG
         LG    R5,=C'12345678'
         LG    R6,=C'ABCDEFGC'
         RXSBG R5,R6,0,7,64-8  MOVE C TO FIRST CHAR AND XOR WITH F1= 2
*MCALL #=   385 LV= 1          RT1   CC1
         DS    0H
RT1_TEST290      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL290
         LTORG 
RT1_CCL290      DS 0H
*MEXIT #=   385 LV= 1 RT1
         CLG   R5,=X'32F2F3F4F5F6F7F8' F1 XOR C3 = 32 ETC.
*MCALL #=   386 LV= 1          RT1   CCE
         DS    0H
RT1_TEST291      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE291
         LTORG 
RT1_CCE291      DS 0H
*MEXIT #=   386 LV= 1 RT1
         LG    R5,=C'12345672'
         LG    R6,=C'ABCDEFGC'
         RXSBG R5,R6,32,39,24  MOVE C TO 5TH CHAR AND XOR WITH F5= 6
*MCALL #=   387 LV= 1          RT1   CC1
         DS    0H
RT1_TEST292      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL292
         LTORG 
RT1_CCL292      DS 0H
*MEXIT #=   387 LV= 1 RT1
         CLG   R5,=X'F1F2F3F436F6F7F2'
*MCALL #=   388 LV= 1          RT1   CCE
         DS    0H
RT1_TEST293      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE293
         LTORG 
RT1_CCE293      DS 0H
*MEXIT #=   388 LV= 1 RT1
         LG    R5,=C'12345672'
         LG    R6,=C'ABCDEFGC'
         RXSBG R5,R6,56,7,0  XOR 21 WITH CA = 31 IN LAST AND FIRST
*MCALL #=   389 LV= 1          RT1   CC1
         DS    0H
RT1_TEST294      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL294
         LTORG 
RT1_CCL294      DS 0H
*MEXIT #=   389 LV= 1 RT1
         CLG   R5,=X'30F2F3F4F5F6F731'
*MCALL #=   390 LV= 1          RT1   CCE
         DS    0H
RT1_TEST295      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE295
         LTORG 
RT1_CCE295      DS 0H
*MEXIT #=   390 LV= 1 RT1
         LG    R5,=C'12345672'
         LG    R6,=C'1BCDEFG2'
         RXSBG R5,R6,56,7,0  XOR 21 WITH 21 = 00 IN LAST AND FIRST
*MCALL #=   391 LV= 1          RT1   CC0
         DS    0H
RT1_TEST296      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE296
         LTORG 
RT1_CCE296      DS 0H
*MEXIT #=   391 LV= 1 RT1
         CLG   R5,=X'00F2F3F4F5F6F700'
*MCALL #=   392 LV= 1          RT1   CCE
         DS    0H
RT1_TEST297      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE297
         LTORG 
RT1_CCE297      DS 0H
*MEXIT #=   392 LV= 1 RT1
* EC57T  RXSBGT
         LG    R5,=C'12345678'
         LG    R6,=C'ABCDEFGC'
         RXSBGT R5,R6,0,7,64-8  MOVE C TO FIRST CHAR AND XOR WITH F1= 2
*MCALL #=   393 LV= 1          RT1   CC1
         DS    0H
RT1_TEST298      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL298
         LTORG 
RT1_CCL298      DS 0H
*MEXIT #=   393 LV= 1 RT1
         CLG   R5,=C'12345678'
*MCALL #=   394 LV= 1          RT1   CCE
         DS    0H
RT1_TEST299      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE299
         LTORG 
RT1_CCE299      DS 0H
*MEXIT #=   394 LV= 1 RT1
         LG    R5,=C'12345672'
         LG    R6,=C'ABCDEFGC'
         RXSBGT R5,R6,32,39,24  MOVE C TO 5TH CHAR AND XOR WITH F5= 6
*MCALL #=   395 LV= 1          RT1   CC1
         DS    0H
RT1_TEST300      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL300
         LTORG 
RT1_CCL300      DS 0H
*MEXIT #=   395 LV= 1 RT1
         CLG   R5,=C'12345672'
*MCALL #=   396 LV= 1          RT1   CCE
         DS    0H
RT1_TEST301      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE301
         LTORG 
RT1_CCE301      DS 0H
*MEXIT #=   396 LV= 1 RT1
         LG    R5,=C'12345672'
         LG    R6,=C'ABCDEFGC'
         RXSBGT R5,R6,56,7,0  XOR 21 WITH CA = 31 IN LAST AND FIRST
*MCALL #=   397 LV= 1          RT1   CC1
         DS    0H
RT1_TEST302      BAS   RT1_LINK,RT1_TEST_CC1
         USING *,RT1_LINK
         B     RT1_CCL302
         LTORG 
RT1_CCL302      DS 0H
*MEXIT #=   397 LV= 1 RT1
         CLG   R5,=C'12345672'
*MCALL #=   398 LV= 1          RT1   CCE
         DS    0H
RT1_TEST303      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE303
         LTORG 
RT1_CCE303      DS 0H
*MEXIT #=   398 LV= 1 RT1
         LG    R5,=C'12345672'
         LG    R6,=C'1BCDEFG2'
         RXSBGT R5,R6,56,7,0  XOR 21 WITH 21 = 00 IN LAST AND FIRST
*MCALL #=   399 LV= 1          RT1   CC0
         DS    0H
RT1_TEST304      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE304
         LTORG 
RT1_CCE304      DS 0H
*MEXIT #=   399 LV= 1 RT1
         CLG   R5,=C'12345672'
*MCALL #=   400 LV= 1          RT1   CCE
         DS    0H
RT1_TEST305      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE305
         LTORG 
RT1_CCE305      DS 0H
*MEXIT #=   400 LV= 1 RT1
* EC64 CGRJ R1,R2,M3,I4 COMPARE R64 AND BRANCH RELATIVE
*MCALL #=   401 LV= 1          TESTCAB CGRJ,A,64,64
         LG    R5,=FL8'0'
         LG    R2,=FL8'0' R2 E
         LG    R3,=FL8'1' R3 H
         LG    R4,=FL8'-1' R4 L
CGRJ8_B1    CGRJ  R5,R2,8,*+10
*MCALL #=   402 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   402 LV= 2 RT1
*MCALL #=   403 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK307
         LTORG 
RT1_OK307      DS 0H
*MEXIT #=   403 LV= 2 RT1
CGRJ2_B1    CGRJ  R5,R4,2,*+10
*MCALL #=   404 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   404 LV= 2 RT1
*MCALL #=   405 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK309
         LTORG 
RT1_OK309      DS 0H
*MEXIT #=   405 LV= 2 RT1
CGRJ4_B1    CGRJ  R5,R3,4,*+10
*MCALL #=   406 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   406 LV= 2 RT1
*MCALL #=   407 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK311
         LTORG 
RT1_OK311      DS 0H
*MEXIT #=   407 LV= 2 RT1
CGRJE_B1    CGRJE   R5,R2,*+10
*MCALL #=   408 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   408 LV= 2 RT1
*MCALL #=   409 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK313
         LTORG 
RT1_OK313      DS 0H
*MEXIT #=   409 LV= 2 RT1
CGRJH_B1    CGRJH   R5,R4,*+10
*MCALL #=   410 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   410 LV= 2 RT1
*MCALL #=   411 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK315
         LTORG 
RT1_OK315      DS 0H
*MEXIT #=   411 LV= 2 RT1
CGRJL_B1    CGRJL   R5,R3,*+10
*MCALL #=   412 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   412 LV= 2 RT1
*MCALL #=   413 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK317
         LTORG 
RT1_OK317      DS 0H
*MEXIT #=   413 LV= 2 RT1
CGRJNE_B1    CGRJNE   R5,R4,*+10
*MCALL #=   414 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   414 LV= 2 RT1
*MCALL #=   415 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK319
         LTORG 
RT1_OK319      DS 0H
*MEXIT #=   415 LV= 2 RT1
CGRJNH_B1    CGRJNH   R5,R3,*+10
*MCALL #=   416 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   416 LV= 2 RT1
*MCALL #=   417 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK321
         LTORG 
RT1_OK321      DS 0H
*MEXIT #=   417 LV= 2 RT1
CGRJNL_B1    CGRJNL   R5,R4,*+10
*MCALL #=   418 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   418 LV= 2 RT1
*MCALL #=   419 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK323
         LTORG 
RT1_OK323      DS 0H
*MEXIT #=   419 LV= 2 RT1
CGRJ8_NB1    CGRJ  R5,R4,8,RT1_ABORT
*MCALL #=   420 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK324
         LTORG 
RT1_OK324      DS 0H
*MEXIT #=   420 LV= 2 RT1
CGRJ2_NB1    CGRJ  R5,R2,2,RT1_ABORT
*MCALL #=   421 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK325
         LTORG 
RT1_OK325      DS 0H
*MEXIT #=   421 LV= 2 RT1
CGRJ4_NB1    CGRJ  R5,R2,4,RT1_ABORT
*MCALL #=   422 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK326
         LTORG 
RT1_OK326      DS 0H
*MEXIT #=   422 LV= 2 RT1
CGRJE_NB1    CGRJE   R5,R3,RT1_ABORT
*MCALL #=   423 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK327
         LTORG 
RT1_OK327      DS 0H
*MEXIT #=   423 LV= 2 RT1
CGRJH_NB1    CGRJH   R5,R3,RT1_ABORT
*MCALL #=   424 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK328
         LTORG 
RT1_OK328      DS 0H
*MEXIT #=   424 LV= 2 RT1
CGRJL_NB1    CGRJL   R5,R4,RT1_ABORT
*MCALL #=   425 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK329
         LTORG 
RT1_OK329      DS 0H
*MEXIT #=   425 LV= 2 RT1
CGRJNE_NB1    CGRJNE   R5,R2,RT1_ABORT
*MCALL #=   426 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK330
         LTORG 
RT1_OK330      DS 0H
*MEXIT #=   426 LV= 2 RT1
CGRJNH_NB1    CGRJNH   R5,R4,RT1_ABORT
*MCALL #=   427 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK331
         LTORG 
RT1_OK331      DS 0H
*MEXIT #=   427 LV= 2 RT1
CGRJNL_NB1    CGRJNL   R5,R3,RT1_ABORT
*MCALL #=   428 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK332
         LTORG 
RT1_OK332      DS 0H
*MEXIT #=   428 LV= 2 RT1
*MEXIT #=   401 LV= 1 TESTCAB
* EC65 CLGRJ R1,R2,M3,I4 COMPARE LOGIVSL R64 AND BRANCH RELATIVE
*MCALL #=   429 LV= 1          TESTCAB CLGRJ,L,64,64
         LG    R5,=FL8'1'
         LG    R2,=FL8'1' R2 E
         LG    R3,=FL8'-1' R3 H
         LG    R4,=FL8'0' R4 L
CLGRJ8_B2   CLGRJ R5,R2,8,*+10
*MCALL #=   430 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   430 LV= 2 RT1
*MCALL #=   431 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK334
         LTORG 
RT1_OK334      DS 0H
*MEXIT #=   431 LV= 2 RT1
CLGRJ2_B2   CLGRJ R5,R4,2,*+10
*MCALL #=   432 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   432 LV= 2 RT1
*MCALL #=   433 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK336
         LTORG 
RT1_OK336      DS 0H
*MEXIT #=   433 LV= 2 RT1
CLGRJ4_B2   CLGRJ R5,R3,4,*+10
*MCALL #=   434 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   434 LV= 2 RT1
*MCALL #=   435 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK338
         LTORG 
RT1_OK338      DS 0H
*MEXIT #=   435 LV= 2 RT1
CLGRJE_B2   CLGRJE  R5,R2,*+10
*MCALL #=   436 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   436 LV= 2 RT1
*MCALL #=   437 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK340
         LTORG 
RT1_OK340      DS 0H
*MEXIT #=   437 LV= 2 RT1
CLGRJH_B2   CLGRJH  R5,R4,*+10
*MCALL #=   438 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   438 LV= 2 RT1
*MCALL #=   439 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK342
         LTORG 
RT1_OK342      DS 0H
*MEXIT #=   439 LV= 2 RT1
CLGRJL_B2   CLGRJL  R5,R3,*+10
*MCALL #=   440 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   440 LV= 2 RT1
*MCALL #=   441 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK344
         LTORG 
RT1_OK344      DS 0H
*MEXIT #=   441 LV= 2 RT1
CLGRJNE_B2   CLGRJNE  R5,R4,*+10
*MCALL #=   442 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   442 LV= 2 RT1
*MCALL #=   443 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK346
         LTORG 
RT1_OK346      DS 0H
*MEXIT #=   443 LV= 2 RT1
CLGRJNH_B2   CLGRJNH  R5,R3,*+10
*MCALL #=   444 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   444 LV= 2 RT1
*MCALL #=   445 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK348
         LTORG 
RT1_OK348      DS 0H
*MEXIT #=   445 LV= 2 RT1
CLGRJNL_B2   CLGRJNL  R5,R4,*+10
*MCALL #=   446 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   446 LV= 2 RT1
*MCALL #=   447 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK350
         LTORG 
RT1_OK350      DS 0H
*MEXIT #=   447 LV= 2 RT1
CLGRJ8_NB2   CLGRJ R5,R4,8,RT1_ABORT
*MCALL #=   448 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK351
         LTORG 
RT1_OK351      DS 0H
*MEXIT #=   448 LV= 2 RT1
CLGRJ2_NB2   CLGRJ R5,R2,2,RT1_ABORT
*MCALL #=   449 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK352
         LTORG 
RT1_OK352      DS 0H
*MEXIT #=   449 LV= 2 RT1
CLGRJ4_NB2   CLGRJ R5,R2,4,RT1_ABORT
*MCALL #=   450 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK353
         LTORG 
RT1_OK353      DS 0H
*MEXIT #=   450 LV= 2 RT1
CLGRJE_NB2   CLGRJE  R5,R3,RT1_ABORT
*MCALL #=   451 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK354
         LTORG 
RT1_OK354      DS 0H
*MEXIT #=   451 LV= 2 RT1
CLGRJH_NB2   CLGRJH  R5,R3,RT1_ABORT
*MCALL #=   452 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK355
         LTORG 
RT1_OK355      DS 0H
*MEXIT #=   452 LV= 2 RT1
CLGRJL_NB2   CLGRJL  R5,R4,RT1_ABORT
*MCALL #=   453 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK356
         LTORG 
RT1_OK356      DS 0H
*MEXIT #=   453 LV= 2 RT1
CLGRJNE_NB2   CLGRJNE  R5,R2,RT1_ABORT
*MCALL #=   454 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK357
         LTORG 
RT1_OK357      DS 0H
*MEXIT #=   454 LV= 2 RT1
CLGRJNH_NB2   CLGRJNH  R5,R4,RT1_ABORT
*MCALL #=   455 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK358
         LTORG 
RT1_OK358      DS 0H
*MEXIT #=   455 LV= 2 RT1
CLGRJNL_NB2   CLGRJNL  R5,R3,RT1_ABORT
*MCALL #=   456 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK359
         LTORG 
RT1_OK359      DS 0H
*MEXIT #=   456 LV= 2 RT1
*MEXIT #=   429 LV= 1 TESTCAB
* EC70 CGIT R1,I2,M3 COMPARE IMMEDIATE AND TRAP
*MCALL #=   457 LV= 1          TESTCAT CGIT,A,64,16  RPI 589 WAS 8
         LG    R5,=FL8'0'
*MCALL #=   458 LV= 2          ESTAE ESTAE_EXIT,PARAM=CGIT8_E5
        LA     0,ESTAE_EXIT
        LA     1,CGIT8_E5
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   458 LV= 2 ESTAE
CGIT8_T5    CGIT  R5,0,8
*MCALL #=   459 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   459 LV= 2 RT1
*MCALL #=   460 LV= 2 CGIT8_E5    ESTAE 0
CGIT8_E5 DS    0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   460 LV= 2 ESTAE
*MCALL #=   461 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK361
         LTORG 
RT1_OK361      DS 0H
*MEXIT #=   461 LV= 2 RT1
*MCALL #=   462 LV= 2          ESTAE ESTAE_EXIT,PARAM=CGIT2_E5
        LA     0,ESTAE_EXIT
        LA     1,CGIT2_E5
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   462 LV= 2 ESTAE
CGIT2_T5    CGIT  R5,-1,2
*MCALL #=   463 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   463 LV= 2 RT1
*MCALL #=   464 LV= 2 CGIT2_E5    ESTAE 0
CGIT2_E5 DS    0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   464 LV= 2 ESTAE
*MCALL #=   465 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK363
         LTORG 
RT1_OK363      DS 0H
*MEXIT #=   465 LV= 2 RT1
*MCALL #=   466 LV= 2          ESTAE ESTAE_EXIT,PARAM=CGIT4_E5
        LA     0,ESTAE_EXIT
        LA     1,CGIT4_E5
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   466 LV= 2 ESTAE
CGIT4_T5    CGIT  R5,1,4
*MCALL #=   467 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   467 LV= 2 RT1
*MCALL #=   468 LV= 2 CGIT4_E5    ESTAE 0
CGIT4_E5 DS    0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   468 LV= 2 ESTAE
*MCALL #=   469 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK365
         LTORG 
RT1_OK365      DS 0H
*MEXIT #=   469 LV= 2 RT1
*MCALL #=   470 LV= 2          ESTAE ESTAE_EXIT,PARAM=CGITE_E5
        LA     0,ESTAE_EXIT
        LA     1,CGITE_E5
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   470 LV= 2 ESTAE
CGITE_T5    CGITE   R5,0
*MCALL #=   471 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   471 LV= 2 RT1
*MCALL #=   472 LV= 2 CGITE_E5    ESTAE 0
CGITE_E5 DS    0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   472 LV= 2 ESTAE
*MCALL #=   473 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK367
         LTORG 
RT1_OK367      DS 0H
*MEXIT #=   473 LV= 2 RT1
*MCALL #=   474 LV= 2          ESTAE ESTAE_EXIT,PARAM=CGITH_E5
        LA     0,ESTAE_EXIT
        LA     1,CGITH_E5
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   474 LV= 2 ESTAE
CGITH_T5    CGITH   R5,-1
*MCALL #=   475 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   475 LV= 2 RT1
*MCALL #=   476 LV= 2 CGITH_E5    ESTAE 0
CGITH_E5 DS    0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   476 LV= 2 ESTAE
*MCALL #=   477 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK369
         LTORG 
RT1_OK369      DS 0H
*MEXIT #=   477 LV= 2 RT1
*MCALL #=   478 LV= 2          ESTAE ESTAE_EXIT,PARAM=CGITL_E5
        LA     0,ESTAE_EXIT
        LA     1,CGITL_E5
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   478 LV= 2 ESTAE
CGITL_T5    CGITL   R5,1
*MCALL #=   479 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   479 LV= 2 RT1
*MCALL #=   480 LV= 2 CGITL_E5    ESTAE 0
CGITL_E5 DS    0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   480 LV= 2 ESTAE
*MCALL #=   481 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK371
         LTORG 
RT1_OK371      DS 0H
*MEXIT #=   481 LV= 2 RT1
*MCALL #=   482 LV= 2          ESTAE ESTAE_EXIT,PARAM=CGITNE_E5
        LA     0,ESTAE_EXIT
        LA     1,CGITNE_E5
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   482 LV= 2 ESTAE
CGITNE_T5    CGITNE   R5,-1
*MCALL #=   483 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   483 LV= 2 RT1
*MCALL #=   484 LV= 2 CGITNE_E5    ESTAE 0
CGITNE_E5 DS   0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   484 LV= 2 ESTAE
*MCALL #=   485 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK373
         LTORG 
RT1_OK373      DS 0H
*MEXIT #=   485 LV= 2 RT1
*MCALL #=   486 LV= 2          ESTAE ESTAE_EXIT,PARAM=CGITNH_E5
        LA     0,ESTAE_EXIT
        LA     1,CGITNH_E5
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   486 LV= 2 ESTAE
CGITNH_T5    CGITNH   R5,1
*MCALL #=   487 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   487 LV= 2 RT1
*MCALL #=   488 LV= 2 CGITNH_E5    ESTAE 0
CGITNH_E5 DS   0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   488 LV= 2 ESTAE
*MCALL #=   489 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK375
         LTORG 
RT1_OK375      DS 0H
*MEXIT #=   489 LV= 2 RT1
*MCALL #=   490 LV= 2          ESTAE ESTAE_EXIT,PARAM=CGITNL_E5
        LA     0,ESTAE_EXIT
        LA     1,CGITNL_E5
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   490 LV= 2 ESTAE
CGITNL_T5    CGITNL   R5,-1
*MCALL #=   491 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   491 LV= 2 RT1
*MCALL #=   492 LV= 2 CGITNL_E5    ESTAE 0
CGITNL_E5 DS   0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   492 LV= 2 ESTAE
*MCALL #=   493 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK377
         LTORG 
RT1_OK377      DS 0H
*MEXIT #=   493 LV= 2 RT1
*MCALL #=   494 LV= 2          ESTAE ESTAE_EXIT,PARAM=RT1_ABORT
        LA     0,ESTAE_EXIT
        LA     1,RT1_ABORT
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   494 LV= 2 ESTAE
CGIT8_NT5    CGIT  R5,-1,8
*MCALL #=   495 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK378
         LTORG 
RT1_OK378      DS 0H
*MEXIT #=   495 LV= 2 RT1
CGIT2_NT5    CGIT  R5,0,2
*MCALL #=   496 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK379
         LTORG 
RT1_OK379      DS 0H
*MEXIT #=   496 LV= 2 RT1
CGIT4_NT5    CGIT  R5,0,4
*MCALL #=   497 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK380
         LTORG 
RT1_OK380      DS 0H
*MEXIT #=   497 LV= 2 RT1
CGITE_NT5    CGITE   R5,1
*MCALL #=   498 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK381
         LTORG 
RT1_OK381      DS 0H
*MEXIT #=   498 LV= 2 RT1
CGITH_NT5    CGITH   R5,1
*MCALL #=   499 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK382
         LTORG 
RT1_OK382      DS 0H
*MEXIT #=   499 LV= 2 RT1
CGITL_NT5    CGITL   R5,-1
*MCALL #=   500 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK383
         LTORG 
RT1_OK383      DS 0H
*MEXIT #=   500 LV= 2 RT1
CGITNE_NT5    CGITNE   R5,0
*MCALL #=   501 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK384
         LTORG 
RT1_OK384      DS 0H
*MEXIT #=   501 LV= 2 RT1
CGITNH_NT5    CGITNH   R5,-1
*MCALL #=   502 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK385
         LTORG 
RT1_OK385      DS 0H
*MEXIT #=   502 LV= 2 RT1
CGITNL_NT5    CGITNL   R5,1
*MCALL #=   503 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK386
         LTORG 
RT1_OK386      DS 0H
*MEXIT #=   503 LV= 2 RT1
*MCALL #=   504 LV= 2          ESTAE 0
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   504 LV= 2 ESTAE
*MEXIT #=   457 LV= 1 TESTCAT
* EC71 CLGIT R1,I2,M3 COMPARE LOG IMMEDIATE AND TRAP
*MCALL #=   505 LV= 1          TESTCAT CLGIT,L,64,16 RPI 589 WAS 8
         LG    R5,=FL8'1'
*MCALL #=   506 LV= 2          ESTAE ESTAE_EXIT,PARAM=CLGIT8_E6
        LA     0,ESTAE_EXIT
        LA     1,CLGIT8_E6
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   506 LV= 2 ESTAE
CLGIT8_T6   CLGIT R5,1,8
*MCALL #=   507 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   507 LV= 2 RT1
*MCALL #=   508 LV= 2 CLGIT8_E6   ESTAE 0
CLGIT8_E6 DS   0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   508 LV= 2 ESTAE
*MCALL #=   509 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK388
         LTORG 
RT1_OK388      DS 0H
*MEXIT #=   509 LV= 2 RT1
*MCALL #=   510 LV= 2          ESTAE ESTAE_EXIT,PARAM=CLGIT2_E6
        LA     0,ESTAE_EXIT
        LA     1,CLGIT2_E6
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   510 LV= 2 ESTAE
CLGIT2_T6   CLGIT R5,0,2
*MCALL #=   511 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   511 LV= 2 RT1
*MCALL #=   512 LV= 2 CLGIT2_E6   ESTAE 0
CLGIT2_E6 DS   0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   512 LV= 2 ESTAE
*MCALL #=   513 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK390
         LTORG 
RT1_OK390      DS 0H
*MEXIT #=   513 LV= 2 RT1
*MCALL #=   514 LV= 2          ESTAE ESTAE_EXIT,PARAM=CLGIT4_E6
        LA     0,ESTAE_EXIT
        LA     1,CLGIT4_E6
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   514 LV= 2 ESTAE
CLGIT4_T6   CLGIT R5,65535,4
*MCALL #=   515 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   515 LV= 2 RT1
*MCALL #=   516 LV= 2 CLGIT4_E6   ESTAE 0
CLGIT4_E6 DS   0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   516 LV= 2 ESTAE
*MCALL #=   517 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK392
         LTORG 
RT1_OK392      DS 0H
*MEXIT #=   517 LV= 2 RT1
*MCALL #=   518 LV= 2          ESTAE ESTAE_EXIT,PARAM=CLGITE_E6
        LA     0,ESTAE_EXIT
        LA     1,CLGITE_E6
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   518 LV= 2 ESTAE
CLGITE_T6   CLGITE  R5,1
*MCALL #=   519 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   519 LV= 2 RT1
*MCALL #=   520 LV= 2 CLGITE_E6   ESTAE 0
CLGITE_E6 DS   0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   520 LV= 2 ESTAE
*MCALL #=   521 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK394
         LTORG 
RT1_OK394      DS 0H
*MEXIT #=   521 LV= 2 RT1
*MCALL #=   522 LV= 2          ESTAE ESTAE_EXIT,PARAM=CLGITH_E6
        LA     0,ESTAE_EXIT
        LA     1,CLGITH_E6
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   522 LV= 2 ESTAE
CLGITH_T6   CLGITH  R5,0
*MCALL #=   523 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   523 LV= 2 RT1
*MCALL #=   524 LV= 2 CLGITH_E6   ESTAE 0
CLGITH_E6 DS   0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   524 LV= 2 ESTAE
*MCALL #=   525 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK396
         LTORG 
RT1_OK396      DS 0H
*MEXIT #=   525 LV= 2 RT1
*MCALL #=   526 LV= 2          ESTAE ESTAE_EXIT,PARAM=CLGITL_E6
        LA     0,ESTAE_EXIT
        LA     1,CLGITL_E6
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   526 LV= 2 ESTAE
CLGITL_T6   CLGITL  R5,65535
*MCALL #=   527 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   527 LV= 2 RT1
*MCALL #=   528 LV= 2 CLGITL_E6   ESTAE 0
CLGITL_E6 DS   0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   528 LV= 2 ESTAE
*MCALL #=   529 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK398
         LTORG 
RT1_OK398      DS 0H
*MEXIT #=   529 LV= 2 RT1
*MCALL #=   530 LV= 2          ESTAE ESTAE_EXIT,PARAM=CLGITNE_E6
        LA     0,ESTAE_EXIT
        LA     1,CLGITNE_E6
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   530 LV= 2 ESTAE
CLGITNE_T6   CLGITNE  R5,0
*MCALL #=   531 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   531 LV= 2 RT1
*MCALL #=   532 LV= 2 CLGITNE_E6   ESTAE 0
CLGITNE_E6 DS  0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   532 LV= 2 ESTAE
*MCALL #=   533 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK400
         LTORG 
RT1_OK400      DS 0H
*MEXIT #=   533 LV= 2 RT1
*MCALL #=   534 LV= 2          ESTAE ESTAE_EXIT,PARAM=CLGITNH_E6
        LA     0,ESTAE_EXIT
        LA     1,CLGITNH_E6
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   534 LV= 2 ESTAE
CLGITNH_T6   CLGITNH  R5,65535
*MCALL #=   535 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   535 LV= 2 RT1
*MCALL #=   536 LV= 2 CLGITNH_E6   ESTAE 0
CLGITNH_E6 DS  0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   536 LV= 2 ESTAE
*MCALL #=   537 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK402
         LTORG 
RT1_OK402      DS 0H
*MEXIT #=   537 LV= 2 RT1
*MCALL #=   538 LV= 2          ESTAE ESTAE_EXIT,PARAM=CLGITNL_E6
        LA     0,ESTAE_EXIT
        LA     1,CLGITNL_E6
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   538 LV= 2 ESTAE
CLGITNL_T6   CLGITNL  R5,0
*MCALL #=   539 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   539 LV= 2 RT1
*MCALL #=   540 LV= 2 CLGITNL_E6   ESTAE 0
CLGITNL_E6 DS  0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   540 LV= 2 ESTAE
*MCALL #=   541 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK404
         LTORG 
RT1_OK404      DS 0H
*MEXIT #=   541 LV= 2 RT1
*MCALL #=   542 LV= 2          ESTAE ESTAE_EXIT,PARAM=RT1_ABORT
        LA     0,ESTAE_EXIT
        LA     1,RT1_ABORT
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   542 LV= 2 ESTAE
CLGIT8_NT6   CLGIT R5,0,8
*MCALL #=   543 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK405
         LTORG 
RT1_OK405      DS 0H
*MEXIT #=   543 LV= 2 RT1
CLGIT2_NT6   CLGIT R5,1,2
*MCALL #=   544 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK406
         LTORG 
RT1_OK406      DS 0H
*MEXIT #=   544 LV= 2 RT1
CLGIT4_NT6   CLGIT R5,1,4
*MCALL #=   545 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK407
         LTORG 
RT1_OK407      DS 0H
*MEXIT #=   545 LV= 2 RT1
CLGITE_NT6   CLGITE  R5,65535
*MCALL #=   546 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK408
         LTORG 
RT1_OK408      DS 0H
*MEXIT #=   546 LV= 2 RT1
CLGITH_NT6   CLGITH  R5,65535
*MCALL #=   547 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK409
         LTORG 
RT1_OK409      DS 0H
*MEXIT #=   547 LV= 2 RT1
CLGITL_NT6   CLGITL  R5,0
*MCALL #=   548 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK410
         LTORG 
RT1_OK410      DS 0H
*MEXIT #=   548 LV= 2 RT1
CLGITNE_NT6   CLGITNE  R5,1
*MCALL #=   549 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK411
         LTORG 
RT1_OK411      DS 0H
*MEXIT #=   549 LV= 2 RT1
CLGITNH_NT6   CLGITNH  R5,0
*MCALL #=   550 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK412
         LTORG 
RT1_OK412      DS 0H
*MEXIT #=   550 LV= 2 RT1
CLGITNL_NT6   CLGITNL  R5,65535
*MCALL #=   551 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK413
         LTORG 
RT1_OK413      DS 0H
*MEXIT #=   551 LV= 2 RT1
*MCALL #=   552 LV= 2          ESTAE 0
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   552 LV= 2 ESTAE
*MEXIT #=   505 LV= 1 TESTCAT
* EC72 CIT R1,I2,M3 COMPARE IMMEDIATE AND TRAP
*MCALL #=   553 LV= 1          TESTCAT CIT,A,32,16   RPI 589 WAS 8
         L     R5,=F'0'
*MCALL #=   554 LV= 2          ESTAE ESTAE_EXIT,PARAM=CIT8_E7
        LA     0,ESTAE_EXIT
        LA     1,CIT8_E7
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   554 LV= 2 ESTAE
CIT8_T7     CIT   R5,0,8
*MCALL #=   555 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   555 LV= 2 RT1
*MCALL #=   556 LV= 2 CIT8_E7     ESTAE 0
CIT8_E7  DS    0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   556 LV= 2 ESTAE
*MCALL #=   557 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK415
         LTORG 
RT1_OK415      DS 0H
*MEXIT #=   557 LV= 2 RT1
*MCALL #=   558 LV= 2          ESTAE ESTAE_EXIT,PARAM=CIT2_E7
        LA     0,ESTAE_EXIT
        LA     1,CIT2_E7
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   558 LV= 2 ESTAE
CIT2_T7     CIT   R5,-1,2
*MCALL #=   559 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   559 LV= 2 RT1
*MCALL #=   560 LV= 2 CIT2_E7     ESTAE 0
CIT2_E7  DS    0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   560 LV= 2 ESTAE
*MCALL #=   561 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK417
         LTORG 
RT1_OK417      DS 0H
*MEXIT #=   561 LV= 2 RT1
*MCALL #=   562 LV= 2          ESTAE ESTAE_EXIT,PARAM=CIT4_E7
        LA     0,ESTAE_EXIT
        LA     1,CIT4_E7
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   562 LV= 2 ESTAE
CIT4_T7     CIT   R5,1,4
*MCALL #=   563 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   563 LV= 2 RT1
*MCALL #=   564 LV= 2 CIT4_E7     ESTAE 0
CIT4_E7  DS    0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   564 LV= 2 ESTAE
*MCALL #=   565 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK419
         LTORG 
RT1_OK419      DS 0H
*MEXIT #=   565 LV= 2 RT1
*MCALL #=   566 LV= 2          ESTAE ESTAE_EXIT,PARAM=CITE_E7
        LA     0,ESTAE_EXIT
        LA     1,CITE_E7
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   566 LV= 2 ESTAE
CITE_T7     CITE    R5,0
*MCALL #=   567 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   567 LV= 2 RT1
*MCALL #=   568 LV= 2 CITE_E7     ESTAE 0
CITE_E7  DS    0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   568 LV= 2 ESTAE
*MCALL #=   569 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK421
         LTORG 
RT1_OK421      DS 0H
*MEXIT #=   569 LV= 2 RT1
*MCALL #=   570 LV= 2          ESTAE ESTAE_EXIT,PARAM=CITH_E7
        LA     0,ESTAE_EXIT
        LA     1,CITH_E7
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   570 LV= 2 ESTAE
CITH_T7     CITH    R5,-1
*MCALL #=   571 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   571 LV= 2 RT1
*MCALL #=   572 LV= 2 CITH_E7     ESTAE 0
CITH_E7  DS    0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   572 LV= 2 ESTAE
*MCALL #=   573 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK423
         LTORG 
RT1_OK423      DS 0H
*MEXIT #=   573 LV= 2 RT1
*MCALL #=   574 LV= 2          ESTAE ESTAE_EXIT,PARAM=CITL_E7
        LA     0,ESTAE_EXIT
        LA     1,CITL_E7
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   574 LV= 2 ESTAE
CITL_T7     CITL    R5,1
*MCALL #=   575 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   575 LV= 2 RT1
*MCALL #=   576 LV= 2 CITL_E7     ESTAE 0
CITL_E7  DS    0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   576 LV= 2 ESTAE
*MCALL #=   577 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK425
         LTORG 
RT1_OK425      DS 0H
*MEXIT #=   577 LV= 2 RT1
*MCALL #=   578 LV= 2          ESTAE ESTAE_EXIT,PARAM=CITNE_E7
        LA     0,ESTAE_EXIT
        LA     1,CITNE_E7
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   578 LV= 2 ESTAE
CITNE_T7     CITNE    R5,-1
*MCALL #=   579 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   579 LV= 2 RT1
*MCALL #=   580 LV= 2 CITNE_E7     ESTAE 0
CITNE_E7 DS    0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   580 LV= 2 ESTAE
*MCALL #=   581 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK427
         LTORG 
RT1_OK427      DS 0H
*MEXIT #=   581 LV= 2 RT1
*MCALL #=   582 LV= 2          ESTAE ESTAE_EXIT,PARAM=CITNH_E7
        LA     0,ESTAE_EXIT
        LA     1,CITNH_E7
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   582 LV= 2 ESTAE
CITNH_T7     CITNH    R5,1
*MCALL #=   583 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   583 LV= 2 RT1
*MCALL #=   584 LV= 2 CITNH_E7     ESTAE 0
CITNH_E7 DS    0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   584 LV= 2 ESTAE
*MCALL #=   585 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK429
         LTORG 
RT1_OK429      DS 0H
*MEXIT #=   585 LV= 2 RT1
*MCALL #=   586 LV= 2          ESTAE ESTAE_EXIT,PARAM=CITNL_E7
        LA     0,ESTAE_EXIT
        LA     1,CITNL_E7
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   586 LV= 2 ESTAE
CITNL_T7     CITNL    R5,-1
*MCALL #=   587 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   587 LV= 2 RT1
*MCALL #=   588 LV= 2 CITNL_E7     ESTAE 0
CITNL_E7 DS    0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   588 LV= 2 ESTAE
*MCALL #=   589 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK431
         LTORG 
RT1_OK431      DS 0H
*MEXIT #=   589 LV= 2 RT1
*MCALL #=   590 LV= 2          ESTAE ESTAE_EXIT,PARAM=RT1_ABORT
        LA     0,ESTAE_EXIT
        LA     1,RT1_ABORT
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   590 LV= 2 ESTAE
CIT8_NT7     CIT   R5,-1,8
*MCALL #=   591 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK432
         LTORG 
RT1_OK432      DS 0H
*MEXIT #=   591 LV= 2 RT1
CIT2_NT7     CIT   R5,0,2
*MCALL #=   592 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK433
         LTORG 
RT1_OK433      DS 0H
*MEXIT #=   592 LV= 2 RT1
CIT4_NT7     CIT   R5,0,4
*MCALL #=   593 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK434
         LTORG 
RT1_OK434      DS 0H
*MEXIT #=   593 LV= 2 RT1
CITE_NT7     CITE    R5,1
*MCALL #=   594 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK435
         LTORG 
RT1_OK435      DS 0H
*MEXIT #=   594 LV= 2 RT1
CITH_NT7     CITH    R5,1
*MCALL #=   595 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK436
         LTORG 
RT1_OK436      DS 0H
*MEXIT #=   595 LV= 2 RT1
CITL_NT7     CITL    R5,-1
*MCALL #=   596 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK437
         LTORG 
RT1_OK437      DS 0H
*MEXIT #=   596 LV= 2 RT1
CITNE_NT7     CITNE    R5,0
*MCALL #=   597 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK438
         LTORG 
RT1_OK438      DS 0H
*MEXIT #=   597 LV= 2 RT1
CITNH_NT7     CITNH    R5,-1
*MCALL #=   598 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK439
         LTORG 
RT1_OK439      DS 0H
*MEXIT #=   598 LV= 2 RT1
CITNL_NT7     CITNL    R5,1
*MCALL #=   599 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK440
         LTORG 
RT1_OK440      DS 0H
*MEXIT #=   599 LV= 2 RT1
*MCALL #=   600 LV= 2          ESTAE 0
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   600 LV= 2 ESTAE
*MEXIT #=   553 LV= 1 TESTCAT
* EC73 CLFIT R1,I2,M3 COMPARE LOG IMMEDIATE AND TRAP
*MCALL #=   601 LV= 1          TESTCAT CLFIT,L,32,16 RPI 589 WAS 8
         L     R5,=F'1'
*MCALL #=   602 LV= 2          ESTAE ESTAE_EXIT,PARAM=CLFIT8_E8
        LA     0,ESTAE_EXIT
        LA     1,CLFIT8_E8
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   602 LV= 2 ESTAE
CLFIT8_T8   CLFIT R5,1,8
*MCALL #=   603 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   603 LV= 2 RT1
*MCALL #=   604 LV= 2 CLFIT8_E8   ESTAE 0
CLFIT8_E8 DS   0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   604 LV= 2 ESTAE
*MCALL #=   605 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK442
         LTORG 
RT1_OK442      DS 0H
*MEXIT #=   605 LV= 2 RT1
*MCALL #=   606 LV= 2          ESTAE ESTAE_EXIT,PARAM=CLFIT2_E8
        LA     0,ESTAE_EXIT
        LA     1,CLFIT2_E8
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   606 LV= 2 ESTAE
CLFIT2_T8   CLFIT R5,0,2
*MCALL #=   607 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   607 LV= 2 RT1
*MCALL #=   608 LV= 2 CLFIT2_E8   ESTAE 0
CLFIT2_E8 DS   0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   608 LV= 2 ESTAE
*MCALL #=   609 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK444
         LTORG 
RT1_OK444      DS 0H
*MEXIT #=   609 LV= 2 RT1
*MCALL #=   610 LV= 2          ESTAE ESTAE_EXIT,PARAM=CLFIT4_E8
        LA     0,ESTAE_EXIT
        LA     1,CLFIT4_E8
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   610 LV= 2 ESTAE
CLFIT4_T8   CLFIT R5,65535,4
*MCALL #=   611 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   611 LV= 2 RT1
*MCALL #=   612 LV= 2 CLFIT4_E8   ESTAE 0
CLFIT4_E8 DS   0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   612 LV= 2 ESTAE
*MCALL #=   613 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK446
         LTORG 
RT1_OK446      DS 0H
*MEXIT #=   613 LV= 2 RT1
*MCALL #=   614 LV= 2          ESTAE ESTAE_EXIT,PARAM=CLFITE_E8
        LA     0,ESTAE_EXIT
        LA     1,CLFITE_E8
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   614 LV= 2 ESTAE
CLFITE_T8   CLFITE  R5,1
*MCALL #=   615 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   615 LV= 2 RT1
*MCALL #=   616 LV= 2 CLFITE_E8   ESTAE 0
CLFITE_E8 DS   0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   616 LV= 2 ESTAE
*MCALL #=   617 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK448
         LTORG 
RT1_OK448      DS 0H
*MEXIT #=   617 LV= 2 RT1
*MCALL #=   618 LV= 2          ESTAE ESTAE_EXIT,PARAM=CLFITH_E8
        LA     0,ESTAE_EXIT
        LA     1,CLFITH_E8
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   618 LV= 2 ESTAE
CLFITH_T8   CLFITH  R5,0
*MCALL #=   619 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   619 LV= 2 RT1
*MCALL #=   620 LV= 2 CLFITH_E8   ESTAE 0
CLFITH_E8 DS   0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   620 LV= 2 ESTAE
*MCALL #=   621 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK450
         LTORG 
RT1_OK450      DS 0H
*MEXIT #=   621 LV= 2 RT1
*MCALL #=   622 LV= 2          ESTAE ESTAE_EXIT,PARAM=CLFITL_E8
        LA     0,ESTAE_EXIT
        LA     1,CLFITL_E8
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   622 LV= 2 ESTAE
CLFITL_T8   CLFITL  R5,65535
*MCALL #=   623 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   623 LV= 2 RT1
*MCALL #=   624 LV= 2 CLFITL_E8   ESTAE 0
CLFITL_E8 DS   0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   624 LV= 2 ESTAE
*MCALL #=   625 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK452
         LTORG 
RT1_OK452      DS 0H
*MEXIT #=   625 LV= 2 RT1
*MCALL #=   626 LV= 2          ESTAE ESTAE_EXIT,PARAM=CLFITNE_E8
        LA     0,ESTAE_EXIT
        LA     1,CLFITNE_E8
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   626 LV= 2 ESTAE
CLFITNE_T8   CLFITNE  R5,0
*MCALL #=   627 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   627 LV= 2 RT1
*MCALL #=   628 LV= 2 CLFITNE_E8   ESTAE 0
CLFITNE_E8 DS  0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   628 LV= 2 ESTAE
*MCALL #=   629 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK454
         LTORG 
RT1_OK454      DS 0H
*MEXIT #=   629 LV= 2 RT1
*MCALL #=   630 LV= 2          ESTAE ESTAE_EXIT,PARAM=CLFITNH_E8
        LA     0,ESTAE_EXIT
        LA     1,CLFITNH_E8
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   630 LV= 2 ESTAE
CLFITNH_T8   CLFITNH  R5,65535
*MCALL #=   631 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   631 LV= 2 RT1
*MCALL #=   632 LV= 2 CLFITNH_E8   ESTAE 0
CLFITNH_E8 DS  0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   632 LV= 2 ESTAE
*MCALL #=   633 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK456
         LTORG 
RT1_OK456      DS 0H
*MEXIT #=   633 LV= 2 RT1
*MCALL #=   634 LV= 2          ESTAE ESTAE_EXIT,PARAM=CLFITNL_E8
        LA     0,ESTAE_EXIT
        LA     1,CLFITNL_E8
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   634 LV= 2 ESTAE
CLFITNL_T8   CLFITNL  R5,0
*MCALL #=   635 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   635 LV= 2 RT1
*MCALL #=   636 LV= 2 CLFITNL_E8   ESTAE 0
CLFITNL_E8 DS  0H
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   636 LV= 2 ESTAE
*MCALL #=   637 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK458
         LTORG 
RT1_OK458      DS 0H
*MEXIT #=   637 LV= 2 RT1
*MCALL #=   638 LV= 2          ESTAE ESTAE_EXIT,PARAM=RT1_ABORT
        LA     0,ESTAE_EXIT
        LA     1,RT1_ABORT
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   638 LV= 2 ESTAE
CLFIT8_NT8   CLFIT R5,0,8
*MCALL #=   639 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK459
         LTORG 
RT1_OK459      DS 0H
*MEXIT #=   639 LV= 2 RT1
CLFIT2_NT8   CLFIT R5,1,2
*MCALL #=   640 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK460
         LTORG 
RT1_OK460      DS 0H
*MEXIT #=   640 LV= 2 RT1
CLFIT4_NT8   CLFIT R5,1,4
*MCALL #=   641 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK461
         LTORG 
RT1_OK461      DS 0H
*MEXIT #=   641 LV= 2 RT1
CLFITE_NT8   CLFITE  R5,65535
*MCALL #=   642 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK462
         LTORG 
RT1_OK462      DS 0H
*MEXIT #=   642 LV= 2 RT1
CLFITH_NT8   CLFITH  R5,65535
*MCALL #=   643 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK463
         LTORG 
RT1_OK463      DS 0H
*MEXIT #=   643 LV= 2 RT1
CLFITL_NT8   CLFITL  R5,0
*MCALL #=   644 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK464
         LTORG 
RT1_OK464      DS 0H
*MEXIT #=   644 LV= 2 RT1
CLFITNE_NT8   CLFITNE  R5,1
*MCALL #=   645 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK465
         LTORG 
RT1_OK465      DS 0H
*MEXIT #=   645 LV= 2 RT1
CLFITNH_NT8   CLFITNH  R5,0
*MCALL #=   646 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK466
         LTORG 
RT1_OK466      DS 0H
*MEXIT #=   646 LV= 2 RT1
CLFITNL_NT8   CLFITNL  R5,65535
*MCALL #=   647 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK467
         LTORG 
RT1_OK467      DS 0H
*MEXIT #=   647 LV= 2 RT1
*MCALL #=   648 LV= 2          ESTAE 0
        LA     0,0
        SR     1,1
        SVC    X'3C' ESTAE R0=EXIT, R0+=CT, R0-=OV,R1=PARAM OR 0
*MEXIT #=   648 LV= 2 ESTAE
*MEXIT #=   601 LV= 1 TESTCAT
* EC76 CRJ R1,R2,M3,I4 COMPARE R32 AND BRANCH RELATIVE
*MCALL #=   649 LV= 1          TESTCAB CRJ,A,32,32
         L     R5,=F'0'
         L     R2,=F'0' R2 E
         L     R3,=F'1' R3 H
         L     R4,=F'-1' R4 L
CRJ8_B3     CRJ   R5,R2,8,*+10
*MCALL #=   650 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   650 LV= 2 RT1
*MCALL #=   651 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK469
         LTORG 
RT1_OK469      DS 0H
*MEXIT #=   651 LV= 2 RT1
CRJ2_B3     CRJ   R5,R4,2,*+10
*MCALL #=   652 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   652 LV= 2 RT1
*MCALL #=   653 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK471
         LTORG 
RT1_OK471      DS 0H
*MEXIT #=   653 LV= 2 RT1
CRJ4_B3     CRJ   R5,R3,4,*+10
*MCALL #=   654 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   654 LV= 2 RT1
*MCALL #=   655 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK473
         LTORG 
RT1_OK473      DS 0H
*MEXIT #=   655 LV= 2 RT1
CRJE_B3     CRJE    R5,R2,*+10
*MCALL #=   656 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   656 LV= 2 RT1
*MCALL #=   657 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK475
         LTORG 
RT1_OK475      DS 0H
*MEXIT #=   657 LV= 2 RT1
CRJH_B3     CRJH    R5,R4,*+10
*MCALL #=   658 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   658 LV= 2 RT1
*MCALL #=   659 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK477
         LTORG 
RT1_OK477      DS 0H
*MEXIT #=   659 LV= 2 RT1
CRJL_B3     CRJL    R5,R3,*+10
*MCALL #=   660 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   660 LV= 2 RT1
*MCALL #=   661 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK479
         LTORG 
RT1_OK479      DS 0H
*MEXIT #=   661 LV= 2 RT1
CRJNE_B3     CRJNE    R5,R4,*+10
*MCALL #=   662 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   662 LV= 2 RT1
*MCALL #=   663 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK481
         LTORG 
RT1_OK481      DS 0H
*MEXIT #=   663 LV= 2 RT1
CRJNH_B3     CRJNH    R5,R3,*+10
*MCALL #=   664 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   664 LV= 2 RT1
*MCALL #=   665 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK483
         LTORG 
RT1_OK483      DS 0H
*MEXIT #=   665 LV= 2 RT1
CRJNL_B3     CRJNL    R5,R4,*+10
*MCALL #=   666 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   666 LV= 2 RT1
*MCALL #=   667 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK485
         LTORG 
RT1_OK485      DS 0H
*MEXIT #=   667 LV= 2 RT1
CRJ8_NB3     CRJ   R5,R4,8,RT1_ABORT
*MCALL #=   668 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK486
         LTORG 
RT1_OK486      DS 0H
*MEXIT #=   668 LV= 2 RT1
CRJ2_NB3     CRJ   R5,R2,2,RT1_ABORT
*MCALL #=   669 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK487
         LTORG 
RT1_OK487      DS 0H
*MEXIT #=   669 LV= 2 RT1
CRJ4_NB3     CRJ   R5,R2,4,RT1_ABORT
*MCALL #=   670 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK488
         LTORG 
RT1_OK488      DS 0H
*MEXIT #=   670 LV= 2 RT1
CRJE_NB3     CRJE    R5,R3,RT1_ABORT
*MCALL #=   671 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK489
         LTORG 
RT1_OK489      DS 0H
*MEXIT #=   671 LV= 2 RT1
CRJH_NB3     CRJH    R5,R3,RT1_ABORT
*MCALL #=   672 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK490
         LTORG 
RT1_OK490      DS 0H
*MEXIT #=   672 LV= 2 RT1
CRJL_NB3     CRJL    R5,R4,RT1_ABORT
*MCALL #=   673 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK491
         LTORG 
RT1_OK491      DS 0H
*MEXIT #=   673 LV= 2 RT1
CRJNE_NB3     CRJNE    R5,R2,RT1_ABORT
*MCALL #=   674 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK492
         LTORG 
RT1_OK492      DS 0H
*MEXIT #=   674 LV= 2 RT1
CRJNH_NB3     CRJNH    R5,R4,RT1_ABORT
*MCALL #=   675 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK493
         LTORG 
RT1_OK493      DS 0H
*MEXIT #=   675 LV= 2 RT1
CRJNL_NB3     CRJNL    R5,R3,RT1_ABORT
*MCALL #=   676 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK494
         LTORG 
RT1_OK494      DS 0H
*MEXIT #=   676 LV= 2 RT1
*MEXIT #=   649 LV= 1 TESTCAB
* EC7C CGIJ R1,I2,M3,I4 COMPARE IMMEDIATE R64 AND BRANCH RELATIVE
*MCALL #=   677 LV= 1          TESTCAB CGIJ,A,64,8
         LG    R5,=FL8'0'
CGIJ8_B4    CGIJ  R5,0,8,*+10
*MCALL #=   678 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   678 LV= 2 RT1
*MCALL #=   679 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK496
         LTORG 
RT1_OK496      DS 0H
*MEXIT #=   679 LV= 2 RT1
CGIJ2_B4    CGIJ  R5,-1,2,*+10
*MCALL #=   680 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   680 LV= 2 RT1
*MCALL #=   681 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK498
         LTORG 
RT1_OK498      DS 0H
*MEXIT #=   681 LV= 2 RT1
CGIJ4_B4    CGIJ  R5,1,4,*+10
*MCALL #=   682 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   682 LV= 2 RT1
*MCALL #=   683 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK500
         LTORG 
RT1_OK500      DS 0H
*MEXIT #=   683 LV= 2 RT1
CGIJE_B4    CGIJE   R5,0,*+10
*MCALL #=   684 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   684 LV= 2 RT1
*MCALL #=   685 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK502
         LTORG 
RT1_OK502      DS 0H
*MEXIT #=   685 LV= 2 RT1
CGIJH_B4    CGIJH   R5,-1,*+10
*MCALL #=   686 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   686 LV= 2 RT1
*MCALL #=   687 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK504
         LTORG 
RT1_OK504      DS 0H
*MEXIT #=   687 LV= 2 RT1
CGIJL_B4    CGIJL   R5,1,*+10
*MCALL #=   688 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   688 LV= 2 RT1
*MCALL #=   689 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK506
         LTORG 
RT1_OK506      DS 0H
*MEXIT #=   689 LV= 2 RT1
CGIJNE_B4    CGIJNE   R5,-1,*+10
*MCALL #=   690 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   690 LV= 2 RT1
*MCALL #=   691 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK508
         LTORG 
RT1_OK508      DS 0H
*MEXIT #=   691 LV= 2 RT1
CGIJNH_B4    CGIJNH   R5,1,*+10
*MCALL #=   692 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   692 LV= 2 RT1
*MCALL #=   693 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK510
         LTORG 
RT1_OK510      DS 0H
*MEXIT #=   693 LV= 2 RT1
CGIJNL_B4    CGIJNL   R5,-1,*+10
*MCALL #=   694 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   694 LV= 2 RT1
*MCALL #=   695 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK512
         LTORG 
RT1_OK512      DS 0H
*MEXIT #=   695 LV= 2 RT1
CGIJ8_NB4    CGIJ  R5,-1,8,RT1_ABORT
*MCALL #=   696 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK513
         LTORG 
RT1_OK513      DS 0H
*MEXIT #=   696 LV= 2 RT1
CGIJ2_NB4    CGIJ  R5,0,2,RT1_ABORT
*MCALL #=   697 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK514
         LTORG 
RT1_OK514      DS 0H
*MEXIT #=   697 LV= 2 RT1
CGIJ4_NB4    CGIJ  R5,0,4,RT1_ABORT
*MCALL #=   698 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK515
         LTORG 
RT1_OK515      DS 0H
*MEXIT #=   698 LV= 2 RT1
CGIJE_NB4    CGIJE   R5,1,RT1_ABORT
*MCALL #=   699 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK516
         LTORG 
RT1_OK516      DS 0H
*MEXIT #=   699 LV= 2 RT1
CGIJH_NB4    CGIJH   R5,1,RT1_ABORT
*MCALL #=   700 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK517
         LTORG 
RT1_OK517      DS 0H
*MEXIT #=   700 LV= 2 RT1
CGIJL_NB4    CGIJL   R5,-1,RT1_ABORT
*MCALL #=   701 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK518
         LTORG 
RT1_OK518      DS 0H
*MEXIT #=   701 LV= 2 RT1
CGIJNE_NB4    CGIJNE   R5,0,RT1_ABORT
*MCALL #=   702 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK519
         LTORG 
RT1_OK519      DS 0H
*MEXIT #=   702 LV= 2 RT1
CGIJNH_NB4    CGIJNH   R5,-1,RT1_ABORT
*MCALL #=   703 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK520
         LTORG 
RT1_OK520      DS 0H
*MEXIT #=   703 LV= 2 RT1
CGIJNL_NB4    CGIJNL   R5,1,RT1_ABORT
*MCALL #=   704 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK521
         LTORG 
RT1_OK521      DS 0H
*MEXIT #=   704 LV= 2 RT1
*MEXIT #=   677 LV= 1 TESTCAB
* EC7D CLGIJ R1,I2,M3,I4 COMPARE LOG IMMEDIATE R64 AND BRANCH RELATIVE
*MCALL #=   705 LV= 1          TESTCAB CLGIJ,L,64,8
         LG    R5,=FL8'1'
CLGIJ8_B5   CLGIJ R5,1,8,*+10
*MCALL #=   706 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   706 LV= 2 RT1
*MCALL #=   707 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK523
         LTORG 
RT1_OK523      DS 0H
*MEXIT #=   707 LV= 2 RT1
CLGIJ2_B5   CLGIJ R5,0,2,*+10
*MCALL #=   708 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   708 LV= 2 RT1
*MCALL #=   709 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK525
         LTORG 
RT1_OK525      DS 0H
*MEXIT #=   709 LV= 2 RT1
CLGIJ4_B5   CLGIJ R5,255,4,*+10
*MCALL #=   710 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   710 LV= 2 RT1
*MCALL #=   711 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK527
         LTORG 
RT1_OK527      DS 0H
*MEXIT #=   711 LV= 2 RT1
CLGIJE_B5   CLGIJE  R5,1,*+10
*MCALL #=   712 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   712 LV= 2 RT1
*MCALL #=   713 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK529
         LTORG 
RT1_OK529      DS 0H
*MEXIT #=   713 LV= 2 RT1
CLGIJH_B5   CLGIJH  R5,0,*+10
*MCALL #=   714 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   714 LV= 2 RT1
*MCALL #=   715 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK531
         LTORG 
RT1_OK531      DS 0H
*MEXIT #=   715 LV= 2 RT1
CLGIJL_B5   CLGIJL  R5,255,*+10
*MCALL #=   716 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   716 LV= 2 RT1
*MCALL #=   717 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK533
         LTORG 
RT1_OK533      DS 0H
*MEXIT #=   717 LV= 2 RT1
CLGIJNE_B5   CLGIJNE  R5,0,*+10
*MCALL #=   718 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   718 LV= 2 RT1
*MCALL #=   719 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK535
         LTORG 
RT1_OK535      DS 0H
*MEXIT #=   719 LV= 2 RT1
CLGIJNH_B5   CLGIJNH  R5,255,*+10
*MCALL #=   720 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   720 LV= 2 RT1
*MCALL #=   721 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK537
         LTORG 
RT1_OK537      DS 0H
*MEXIT #=   721 LV= 2 RT1
CLGIJNL_B5   CLGIJNL  R5,0,*+10
*MCALL #=   722 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   722 LV= 2 RT1
*MCALL #=   723 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK539
         LTORG 
RT1_OK539      DS 0H
*MEXIT #=   723 LV= 2 RT1
CLGIJ8_NB5   CLGIJ R5,0,8,RT1_ABORT
*MCALL #=   724 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK540
         LTORG 
RT1_OK540      DS 0H
*MEXIT #=   724 LV= 2 RT1
CLGIJ2_NB5   CLGIJ R5,1,2,RT1_ABORT
*MCALL #=   725 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK541
         LTORG 
RT1_OK541      DS 0H
*MEXIT #=   725 LV= 2 RT1
CLGIJ4_NB5   CLGIJ R5,1,4,RT1_ABORT
*MCALL #=   726 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK542
         LTORG 
RT1_OK542      DS 0H
*MEXIT #=   726 LV= 2 RT1
CLGIJE_NB5   CLGIJE  R5,255,RT1_ABORT
*MCALL #=   727 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK543
         LTORG 
RT1_OK543      DS 0H
*MEXIT #=   727 LV= 2 RT1
CLGIJH_NB5   CLGIJH  R5,255,RT1_ABORT
*MCALL #=   728 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK544
         LTORG 
RT1_OK544      DS 0H
*MEXIT #=   728 LV= 2 RT1
CLGIJL_NB5   CLGIJL  R5,0,RT1_ABORT
*MCALL #=   729 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK545
         LTORG 
RT1_OK545      DS 0H
*MEXIT #=   729 LV= 2 RT1
CLGIJNE_NB5   CLGIJNE  R5,1,RT1_ABORT
*MCALL #=   730 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK546
         LTORG 
RT1_OK546      DS 0H
*MEXIT #=   730 LV= 2 RT1
CLGIJNH_NB5   CLGIJNH  R5,0,RT1_ABORT
*MCALL #=   731 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK547
         LTORG 
RT1_OK547      DS 0H
*MEXIT #=   731 LV= 2 RT1
CLGIJNL_NB5   CLGIJNL  R5,255,RT1_ABORT
*MCALL #=   732 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK548
         LTORG 
RT1_OK548      DS 0H
*MEXIT #=   732 LV= 2 RT1
*MEXIT #=   705 LV= 1 TESTCAB
* EC7E CIJ R1,I2,M3,I4 COMPARE IMMEDIATE R32 AND BRANCH RELATIVE
*MCALL #=   733 LV= 1          TESTCAB CIJ,A,32,8
         L     R5,=F'0'
CIJ8_B6     CIJ   R5,0,8,*+10
*MCALL #=   734 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   734 LV= 2 RT1
*MCALL #=   735 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK550
         LTORG 
RT1_OK550      DS 0H
*MEXIT #=   735 LV= 2 RT1
CIJ2_B6     CIJ   R5,-1,2,*+10
*MCALL #=   736 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   736 LV= 2 RT1
*MCALL #=   737 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK552
         LTORG 
RT1_OK552      DS 0H
*MEXIT #=   737 LV= 2 RT1
CIJ4_B6     CIJ   R5,1,4,*+10
*MCALL #=   738 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   738 LV= 2 RT1
*MCALL #=   739 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK554
         LTORG 
RT1_OK554      DS 0H
*MEXIT #=   739 LV= 2 RT1
CIJE_B6     CIJE    R5,0,*+10
*MCALL #=   740 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   740 LV= 2 RT1
*MCALL #=   741 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK556
         LTORG 
RT1_OK556      DS 0H
*MEXIT #=   741 LV= 2 RT1
CIJH_B6     CIJH    R5,-1,*+10
*MCALL #=   742 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   742 LV= 2 RT1
*MCALL #=   743 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK558
         LTORG 
RT1_OK558      DS 0H
*MEXIT #=   743 LV= 2 RT1
CIJL_B6     CIJL    R5,1,*+10
*MCALL #=   744 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   744 LV= 2 RT1
*MCALL #=   745 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK560
         LTORG 
RT1_OK560      DS 0H
*MEXIT #=   745 LV= 2 RT1
CIJNE_B6     CIJNE    R5,-1,*+10
*MCALL #=   746 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   746 LV= 2 RT1
*MCALL #=   747 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK562
         LTORG 
RT1_OK562      DS 0H
*MEXIT #=   747 LV= 2 RT1
CIJNH_B6     CIJNH    R5,1,*+10
*MCALL #=   748 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   748 LV= 2 RT1
*MCALL #=   749 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK564
         LTORG 
RT1_OK564      DS 0H
*MEXIT #=   749 LV= 2 RT1
CIJNL_B6     CIJNL    R5,-1,*+10
*MCALL #=   750 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   750 LV= 2 RT1
*MCALL #=   751 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK566
         LTORG 
RT1_OK566      DS 0H
*MEXIT #=   751 LV= 2 RT1
CIJ8_NB6     CIJ   R5,-1,8,RT1_ABORT
*MCALL #=   752 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK567
         LTORG 
RT1_OK567      DS 0H
*MEXIT #=   752 LV= 2 RT1
CIJ2_NB6     CIJ   R5,0,2,RT1_ABORT
*MCALL #=   753 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK568
         LTORG 
RT1_OK568      DS 0H
*MEXIT #=   753 LV= 2 RT1
CIJ4_NB6     CIJ   R5,0,4,RT1_ABORT
*MCALL #=   754 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK569
         LTORG 
RT1_OK569      DS 0H
*MEXIT #=   754 LV= 2 RT1
CIJE_NB6     CIJE    R5,1,RT1_ABORT
*MCALL #=   755 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK570
         LTORG 
RT1_OK570      DS 0H
*MEXIT #=   755 LV= 2 RT1
CIJH_NB6     CIJH    R5,1,RT1_ABORT
*MCALL #=   756 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK571
         LTORG 
RT1_OK571      DS 0H
*MEXIT #=   756 LV= 2 RT1
CIJL_NB6     CIJL    R5,-1,RT1_ABORT
*MCALL #=   757 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK572
         LTORG 
RT1_OK572      DS 0H
*MEXIT #=   757 LV= 2 RT1
CIJNE_NB6     CIJNE    R5,0,RT1_ABORT
*MCALL #=   758 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK573
         LTORG 
RT1_OK573      DS 0H
*MEXIT #=   758 LV= 2 RT1
CIJNH_NB6     CIJNH    R5,-1,RT1_ABORT
*MCALL #=   759 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK574
         LTORG 
RT1_OK574      DS 0H
*MEXIT #=   759 LV= 2 RT1
CIJNL_NB6     CIJNL    R5,1,RT1_ABORT
*MCALL #=   760 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK575
         LTORG 
RT1_OK575      DS 0H
*MEXIT #=   760 LV= 2 RT1
*MEXIT #=   733 LV= 1 TESTCAB
* EC7F CLIJ R1,I2,M3,I4 COMPARE LOG IMMEDIATE R32 AND BRANCH RELATIVE
*MCALL #=   761 LV= 1          TESTCAB CLIJ,L,32,8
         L     R5,=F'1'
CLIJ8_B7    CLIJ  R5,1,8,*+10
*MCALL #=   762 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   762 LV= 2 RT1
*MCALL #=   763 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK577
         LTORG 
RT1_OK577      DS 0H
*MEXIT #=   763 LV= 2 RT1
CLIJ2_B7    CLIJ  R5,0,2,*+10
*MCALL #=   764 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   764 LV= 2 RT1
*MCALL #=   765 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK579
         LTORG 
RT1_OK579      DS 0H
*MEXIT #=   765 LV= 2 RT1
CLIJ4_B7    CLIJ  R5,255,4,*+10
*MCALL #=   766 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   766 LV= 2 RT1
*MCALL #=   767 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK581
         LTORG 
RT1_OK581      DS 0H
*MEXIT #=   767 LV= 2 RT1
CLIJE_B7    CLIJE   R5,1,*+10
*MCALL #=   768 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   768 LV= 2 RT1
*MCALL #=   769 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK583
         LTORG 
RT1_OK583      DS 0H
*MEXIT #=   769 LV= 2 RT1
CLIJH_B7    CLIJH   R5,0,*+10
*MCALL #=   770 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   770 LV= 2 RT1
*MCALL #=   771 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK585
         LTORG 
RT1_OK585      DS 0H
*MEXIT #=   771 LV= 2 RT1
CLIJL_B7    CLIJL   R5,255,*+10
*MCALL #=   772 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   772 LV= 2 RT1
*MCALL #=   773 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK587
         LTORG 
RT1_OK587      DS 0H
*MEXIT #=   773 LV= 2 RT1
CLIJNE_B7    CLIJNE   R5,0,*+10
*MCALL #=   774 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   774 LV= 2 RT1
*MCALL #=   775 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK589
         LTORG 
RT1_OK589      DS 0H
*MEXIT #=   775 LV= 2 RT1
CLIJNH_B7    CLIJNH   R5,255,*+10
*MCALL #=   776 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   776 LV= 2 RT1
*MCALL #=   777 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK591
         LTORG 
RT1_OK591      DS 0H
*MEXIT #=   777 LV= 2 RT1
CLIJNL_B7    CLIJNL   R5,0,*+10
*MCALL #=   778 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   778 LV= 2 RT1
*MCALL #=   779 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK593
         LTORG 
RT1_OK593      DS 0H
*MEXIT #=   779 LV= 2 RT1
CLIJ8_NB7    CLIJ  R5,0,8,RT1_ABORT
*MCALL #=   780 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK594
         LTORG 
RT1_OK594      DS 0H
*MEXIT #=   780 LV= 2 RT1
CLIJ2_NB7    CLIJ  R5,1,2,RT1_ABORT
*MCALL #=   781 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK595
         LTORG 
RT1_OK595      DS 0H
*MEXIT #=   781 LV= 2 RT1
CLIJ4_NB7    CLIJ  R5,1,4,RT1_ABORT
*MCALL #=   782 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK596
         LTORG 
RT1_OK596      DS 0H
*MEXIT #=   782 LV= 2 RT1
CLIJE_NB7    CLIJE   R5,255,RT1_ABORT
*MCALL #=   783 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK597
         LTORG 
RT1_OK597      DS 0H
*MEXIT #=   783 LV= 2 RT1
CLIJH_NB7    CLIJH   R5,255,RT1_ABORT
*MCALL #=   784 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK598
         LTORG 
RT1_OK598      DS 0H
*MEXIT #=   784 LV= 2 RT1
CLIJL_NB7    CLIJL   R5,0,RT1_ABORT
*MCALL #=   785 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK599
         LTORG 
RT1_OK599      DS 0H
*MEXIT #=   785 LV= 2 RT1
CLIJNE_NB7    CLIJNE   R5,1,RT1_ABORT
*MCALL #=   786 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK600
         LTORG 
RT1_OK600      DS 0H
*MEXIT #=   786 LV= 2 RT1
CLIJNH_NB7    CLIJNH   R5,0,RT1_ABORT
*MCALL #=   787 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK601
         LTORG 
RT1_OK601      DS 0H
*MEXIT #=   787 LV= 2 RT1
CLIJNL_NB7    CLIJNL   R5,255,RT1_ABORT
*MCALL #=   788 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK602
         LTORG 
RT1_OK602      DS 0H
*MEXIT #=   788 LV= 2 RT1
*MEXIT #=   761 LV= 1 TESTCAB
* ECF4 CGRB R1,R2,M3,I4 COMPARE R64 AND BRANCH
*MCALL #=   789 LV= 1          TESTCAB CGRB,A,64,64
         LG    R5,=FL8'0'
         LG    R2,=FL8'0' R2 E
         LG    R3,=FL8'1' R3 H
         LG    R4,=FL8'-1' R4 L
CGRB8_B8    CGRB  R5,R2,8,*+10
*MCALL #=   790 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   790 LV= 2 RT1
*MCALL #=   791 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK604
         LTORG 
RT1_OK604      DS 0H
*MEXIT #=   791 LV= 2 RT1
CGRB2_B8    CGRB  R5,R4,2,*+10
*MCALL #=   792 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   792 LV= 2 RT1
*MCALL #=   793 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK606
         LTORG 
RT1_OK606      DS 0H
*MEXIT #=   793 LV= 2 RT1
CGRB4_B8    CGRB  R5,R3,4,*+10
*MCALL #=   794 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   794 LV= 2 RT1
*MCALL #=   795 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK608
         LTORG 
RT1_OK608      DS 0H
*MEXIT #=   795 LV= 2 RT1
CGRBE_B8    CGRBE   R5,R2,*+10
*MCALL #=   796 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   796 LV= 2 RT1
*MCALL #=   797 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK610
         LTORG 
RT1_OK610      DS 0H
*MEXIT #=   797 LV= 2 RT1
CGRBH_B8    CGRBH   R5,R4,*+10
*MCALL #=   798 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   798 LV= 2 RT1
*MCALL #=   799 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK612
         LTORG 
RT1_OK612      DS 0H
*MEXIT #=   799 LV= 2 RT1
CGRBL_B8    CGRBL   R5,R3,*+10
*MCALL #=   800 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   800 LV= 2 RT1
*MCALL #=   801 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK614
         LTORG 
RT1_OK614      DS 0H
*MEXIT #=   801 LV= 2 RT1
CGRBNE_B8    CGRBNE   R5,R4,*+10
*MCALL #=   802 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   802 LV= 2 RT1
*MCALL #=   803 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK616
         LTORG 
RT1_OK616      DS 0H
*MEXIT #=   803 LV= 2 RT1
CGRBNH_B8    CGRBNH   R5,R3,*+10
*MCALL #=   804 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   804 LV= 2 RT1
*MCALL #=   805 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK618
         LTORG 
RT1_OK618      DS 0H
*MEXIT #=   805 LV= 2 RT1
CGRBNL_B8    CGRBNL   R5,R4,*+10
*MCALL #=   806 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   806 LV= 2 RT1
*MCALL #=   807 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK620
         LTORG 
RT1_OK620      DS 0H
*MEXIT #=   807 LV= 2 RT1
CGRB8_NB8    CGRB  R5,R4,8,RT1_ABORT
*MCALL #=   808 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK621
         LTORG 
RT1_OK621      DS 0H
*MEXIT #=   808 LV= 2 RT1
CGRB2_NB8    CGRB  R5,R2,2,RT1_ABORT
*MCALL #=   809 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK622
         LTORG 
RT1_OK622      DS 0H
*MEXIT #=   809 LV= 2 RT1
CGRB4_NB8    CGRB  R5,R2,4,RT1_ABORT
*MCALL #=   810 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK623
         LTORG 
RT1_OK623      DS 0H
*MEXIT #=   810 LV= 2 RT1
CGRBE_NB8    CGRBE   R5,R3,RT1_ABORT
*MCALL #=   811 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK624
         LTORG 
RT1_OK624      DS 0H
*MEXIT #=   811 LV= 2 RT1
CGRBH_NB8    CGRBH   R5,R3,RT1_ABORT
*MCALL #=   812 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK625
         LTORG 
RT1_OK625      DS 0H
*MEXIT #=   812 LV= 2 RT1
CGRBL_NB8    CGRBL   R5,R4,RT1_ABORT
*MCALL #=   813 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK626
         LTORG 
RT1_OK626      DS 0H
*MEXIT #=   813 LV= 2 RT1
CGRBNE_NB8    CGRBNE   R5,R2,RT1_ABORT
*MCALL #=   814 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK627
         LTORG 
RT1_OK627      DS 0H
*MEXIT #=   814 LV= 2 RT1
CGRBNH_NB8    CGRBNH   R5,R4,RT1_ABORT
*MCALL #=   815 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK628
         LTORG 
RT1_OK628      DS 0H
*MEXIT #=   815 LV= 2 RT1
CGRBNL_NB8    CGRBNL   R5,R3,RT1_ABORT
*MCALL #=   816 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK629
         LTORG 
RT1_OK629      DS 0H
*MEXIT #=   816 LV= 2 RT1
*MEXIT #=   789 LV= 1 TESTCAB
* ECF5 CLGRB R1,R2,M3,I4 COMPARE LOGIVSL R64 AND BRANCH
*MCALL #=   817 LV= 1          TESTCAB CLGRB,L,64,64
         LG    R5,=FL8'1'
         LG    R2,=FL8'1' R2 E
         LG    R3,=FL8'-1' R3 H
         LG    R4,=FL8'0' R4 L
CLGRB8_B9   CLGRB R5,R2,8,*+10
*MCALL #=   818 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   818 LV= 2 RT1
*MCALL #=   819 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK631
         LTORG 
RT1_OK631      DS 0H
*MEXIT #=   819 LV= 2 RT1
CLGRB2_B9   CLGRB R5,R4,2,*+10
*MCALL #=   820 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   820 LV= 2 RT1
*MCALL #=   821 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK633
         LTORG 
RT1_OK633      DS 0H
*MEXIT #=   821 LV= 2 RT1
CLGRB4_B9   CLGRB R5,R3,4,*+10
*MCALL #=   822 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   822 LV= 2 RT1
*MCALL #=   823 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK635
         LTORG 
RT1_OK635      DS 0H
*MEXIT #=   823 LV= 2 RT1
CLGRBE_B9   CLGRBE  R5,R2,*+10
*MCALL #=   824 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   824 LV= 2 RT1
*MCALL #=   825 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK637
         LTORG 
RT1_OK637      DS 0H
*MEXIT #=   825 LV= 2 RT1
CLGRBH_B9   CLGRBH  R5,R4,*+10
*MCALL #=   826 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   826 LV= 2 RT1
*MCALL #=   827 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK639
         LTORG 
RT1_OK639      DS 0H
*MEXIT #=   827 LV= 2 RT1
CLGRBL_B9   CLGRBL  R5,R3,*+10
*MCALL #=   828 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   828 LV= 2 RT1
*MCALL #=   829 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK641
         LTORG 
RT1_OK641      DS 0H
*MEXIT #=   829 LV= 2 RT1
CLGRBNE_B9   CLGRBNE  R5,R4,*+10
*MCALL #=   830 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   830 LV= 2 RT1
*MCALL #=   831 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK643
         LTORG 
RT1_OK643      DS 0H
*MEXIT #=   831 LV= 2 RT1
CLGRBNH_B9   CLGRBNH  R5,R3,*+10
*MCALL #=   832 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   832 LV= 2 RT1
*MCALL #=   833 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK645
         LTORG 
RT1_OK645      DS 0H
*MEXIT #=   833 LV= 2 RT1
CLGRBNL_B9   CLGRBNL  R5,R4,*+10
*MCALL #=   834 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   834 LV= 2 RT1
*MCALL #=   835 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK647
         LTORG 
RT1_OK647      DS 0H
*MEXIT #=   835 LV= 2 RT1
CLGRB8_NB9   CLGRB R5,R4,8,RT1_ABORT
*MCALL #=   836 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK648
         LTORG 
RT1_OK648      DS 0H
*MEXIT #=   836 LV= 2 RT1
CLGRB2_NB9   CLGRB R5,R2,2,RT1_ABORT
*MCALL #=   837 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK649
         LTORG 
RT1_OK649      DS 0H
*MEXIT #=   837 LV= 2 RT1
CLGRB4_NB9   CLGRB R5,R2,4,RT1_ABORT
*MCALL #=   838 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK650
         LTORG 
RT1_OK650      DS 0H
*MEXIT #=   838 LV= 2 RT1
CLGRBE_NB9   CLGRBE  R5,R3,RT1_ABORT
*MCALL #=   839 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK651
         LTORG 
RT1_OK651      DS 0H
*MEXIT #=   839 LV= 2 RT1
CLGRBH_NB9   CLGRBH  R5,R3,RT1_ABORT
*MCALL #=   840 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK652
         LTORG 
RT1_OK652      DS 0H
*MEXIT #=   840 LV= 2 RT1
CLGRBL_NB9   CLGRBL  R5,R4,RT1_ABORT
*MCALL #=   841 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK653
         LTORG 
RT1_OK653      DS 0H
*MEXIT #=   841 LV= 2 RT1
CLGRBNE_NB9   CLGRBNE  R5,R2,RT1_ABORT
*MCALL #=   842 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK654
         LTORG 
RT1_OK654      DS 0H
*MEXIT #=   842 LV= 2 RT1
CLGRBNH_NB9   CLGRBNH  R5,R4,RT1_ABORT
*MCALL #=   843 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK655
         LTORG 
RT1_OK655      DS 0H
*MEXIT #=   843 LV= 2 RT1
CLGRBNL_NB9   CLGRBNL  R5,R3,RT1_ABORT
*MCALL #=   844 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK656
         LTORG 
RT1_OK656      DS 0H
*MEXIT #=   844 LV= 2 RT1
*MEXIT #=   817 LV= 1 TESTCAB
* ECF6 CRB R1,R2,M3,I4 COMPARE R32 AND BRANCH
*MCALL #=   845 LV= 1          TESTCAB CRB,A,32,32
         L     R5,=F'0'
         L     R2,=F'0' R2 E
         L     R3,=F'1' R3 H
         L     R4,=F'-1' R4 L
CRB8_B10    CRB   R5,R2,8,*+10
*MCALL #=   846 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   846 LV= 2 RT1
*MCALL #=   847 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK658
         LTORG 
RT1_OK658      DS 0H
*MEXIT #=   847 LV= 2 RT1
CRB2_B10    CRB   R5,R4,2,*+10
*MCALL #=   848 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   848 LV= 2 RT1
*MCALL #=   849 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK660
         LTORG 
RT1_OK660      DS 0H
*MEXIT #=   849 LV= 2 RT1
CRB4_B10    CRB   R5,R3,4,*+10
*MCALL #=   850 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   850 LV= 2 RT1
*MCALL #=   851 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK662
         LTORG 
RT1_OK662      DS 0H
*MEXIT #=   851 LV= 2 RT1
CRBE_B10    CRBE    R5,R2,*+10
*MCALL #=   852 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   852 LV= 2 RT1
*MCALL #=   853 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK664
         LTORG 
RT1_OK664      DS 0H
*MEXIT #=   853 LV= 2 RT1
CRBH_B10    CRBH    R5,R4,*+10
*MCALL #=   854 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   854 LV= 2 RT1
*MCALL #=   855 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK666
         LTORG 
RT1_OK666      DS 0H
*MEXIT #=   855 LV= 2 RT1
CRBL_B10    CRBL    R5,R3,*+10
*MCALL #=   856 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   856 LV= 2 RT1
*MCALL #=   857 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK668
         LTORG 
RT1_OK668      DS 0H
*MEXIT #=   857 LV= 2 RT1
CRBNE_B10    CRBNE    R5,R4,*+10
*MCALL #=   858 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   858 LV= 2 RT1
*MCALL #=   859 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK670
         LTORG 
RT1_OK670      DS 0H
*MEXIT #=   859 LV= 2 RT1
CRBNH_B10    CRBNH    R5,R3,*+10
*MCALL #=   860 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   860 LV= 2 RT1
*MCALL #=   861 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK672
         LTORG 
RT1_OK672      DS 0H
*MEXIT #=   861 LV= 2 RT1
CRBNL_B10    CRBNL    R5,R4,*+10
*MCALL #=   862 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   862 LV= 2 RT1
*MCALL #=   863 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK674
         LTORG 
RT1_OK674      DS 0H
*MEXIT #=   863 LV= 2 RT1
CRB8_NB10    CRB   R5,R4,8,RT1_ABORT
*MCALL #=   864 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK675
         LTORG 
RT1_OK675      DS 0H
*MEXIT #=   864 LV= 2 RT1
CRB2_NB10    CRB   R5,R2,2,RT1_ABORT
*MCALL #=   865 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK676
         LTORG 
RT1_OK676      DS 0H
*MEXIT #=   865 LV= 2 RT1
CRB4_NB10    CRB   R5,R2,4,RT1_ABORT
*MCALL #=   866 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK677
         LTORG 
RT1_OK677      DS 0H
*MEXIT #=   866 LV= 2 RT1
CRBE_NB10    CRBE    R5,R3,RT1_ABORT
*MCALL #=   867 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK678
         LTORG 
RT1_OK678      DS 0H
*MEXIT #=   867 LV= 2 RT1
CRBH_NB10    CRBH    R5,R3,RT1_ABORT
*MCALL #=   868 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK679
         LTORG 
RT1_OK679      DS 0H
*MEXIT #=   868 LV= 2 RT1
CRBL_NB10    CRBL    R5,R4,RT1_ABORT
*MCALL #=   869 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK680
         LTORG 
RT1_OK680      DS 0H
*MEXIT #=   869 LV= 2 RT1
CRBNE_NB10    CRBNE    R5,R2,RT1_ABORT
*MCALL #=   870 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK681
         LTORG 
RT1_OK681      DS 0H
*MEXIT #=   870 LV= 2 RT1
CRBNH_NB10    CRBNH    R5,R4,RT1_ABORT
*MCALL #=   871 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK682
         LTORG 
RT1_OK682      DS 0H
*MEXIT #=   871 LV= 2 RT1
CRBNL_NB10    CRBNL    R5,R3,RT1_ABORT
*MCALL #=   872 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK683
         LTORG 
RT1_OK683      DS 0H
*MEXIT #=   872 LV= 2 RT1
*MEXIT #=   845 LV= 1 TESTCAB
* ECFC CGIB R1,I2,M3,I4 COMPARE IMMEDIATE R64 AND BRANCH
*MCALL #=   873 LV= 1          TESTCAB CGIB,A,64,8
         LG    R5,=FL8'0'
CGIB8_B11   CGIB  R5,0,8,*+10
*MCALL #=   874 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   874 LV= 2 RT1
*MCALL #=   875 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK685
         LTORG 
RT1_OK685      DS 0H
*MEXIT #=   875 LV= 2 RT1
CGIB2_B11   CGIB  R5,-1,2,*+10
*MCALL #=   876 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   876 LV= 2 RT1
*MCALL #=   877 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK687
         LTORG 
RT1_OK687      DS 0H
*MEXIT #=   877 LV= 2 RT1
CGIB4_B11   CGIB  R5,1,4,*+10
*MCALL #=   878 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   878 LV= 2 RT1
*MCALL #=   879 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK689
         LTORG 
RT1_OK689      DS 0H
*MEXIT #=   879 LV= 2 RT1
CGIBE_B11   CGIBE   R5,0,*+10
*MCALL #=   880 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   880 LV= 2 RT1
*MCALL #=   881 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK691
         LTORG 
RT1_OK691      DS 0H
*MEXIT #=   881 LV= 2 RT1
CGIBH_B11   CGIBH   R5,-1,*+10
*MCALL #=   882 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   882 LV= 2 RT1
*MCALL #=   883 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK693
         LTORG 
RT1_OK693      DS 0H
*MEXIT #=   883 LV= 2 RT1
CGIBL_B11   CGIBL   R5,1,*+10
*MCALL #=   884 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   884 LV= 2 RT1
*MCALL #=   885 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK695
         LTORG 
RT1_OK695      DS 0H
*MEXIT #=   885 LV= 2 RT1
CGIBNE_B11   CGIBNE   R5,-1,*+10
*MCALL #=   886 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   886 LV= 2 RT1
*MCALL #=   887 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK697
         LTORG 
RT1_OK697      DS 0H
*MEXIT #=   887 LV= 2 RT1
CGIBNH_B11   CGIBNH   R5,1,*+10
*MCALL #=   888 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   888 LV= 2 RT1
*MCALL #=   889 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK699
         LTORG 
RT1_OK699      DS 0H
*MEXIT #=   889 LV= 2 RT1
CGIBNL_B11   CGIBNL   R5,-1,*+10
*MCALL #=   890 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   890 LV= 2 RT1
*MCALL #=   891 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK701
         LTORG 
RT1_OK701      DS 0H
*MEXIT #=   891 LV= 2 RT1
CGIB8_NB11   CGIB  R5,-1,8,RT1_ABORT
*MCALL #=   892 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK702
         LTORG 
RT1_OK702      DS 0H
*MEXIT #=   892 LV= 2 RT1
CGIB2_NB11   CGIB  R5,0,2,RT1_ABORT
*MCALL #=   893 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK703
         LTORG 
RT1_OK703      DS 0H
*MEXIT #=   893 LV= 2 RT1
CGIB4_NB11   CGIB  R5,0,4,RT1_ABORT
*MCALL #=   894 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK704
         LTORG 
RT1_OK704      DS 0H
*MEXIT #=   894 LV= 2 RT1
CGIBE_NB11   CGIBE   R5,1,RT1_ABORT
*MCALL #=   895 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK705
         LTORG 
RT1_OK705      DS 0H
*MEXIT #=   895 LV= 2 RT1
CGIBH_NB11   CGIBH   R5,1,RT1_ABORT
*MCALL #=   896 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK706
         LTORG 
RT1_OK706      DS 0H
*MEXIT #=   896 LV= 2 RT1
CGIBL_NB11   CGIBL   R5,-1,RT1_ABORT
*MCALL #=   897 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK707
         LTORG 
RT1_OK707      DS 0H
*MEXIT #=   897 LV= 2 RT1
CGIBNE_NB11   CGIBNE   R5,0,RT1_ABORT
*MCALL #=   898 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK708
         LTORG 
RT1_OK708      DS 0H
*MEXIT #=   898 LV= 2 RT1
CGIBNH_NB11   CGIBNH   R5,-1,RT1_ABORT
*MCALL #=   899 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK709
         LTORG 
RT1_OK709      DS 0H
*MEXIT #=   899 LV= 2 RT1
CGIBNL_NB11   CGIBNL   R5,1,RT1_ABORT
*MCALL #=   900 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK710
         LTORG 
RT1_OK710      DS 0H
*MEXIT #=   900 LV= 2 RT1
*MEXIT #=   873 LV= 1 TESTCAB
* ECFD CLGIB R1,I2,M3,I4 COMPARE LOG IMMEDIATE R64 AND BRANCH
*MCALL #=   901 LV= 1          TESTCAB CLGIB,L,64,8
         LG    R5,=FL8'1'
CLGIB8_B12  CLGIB R5,1,8,*+10
*MCALL #=   902 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   902 LV= 2 RT1
*MCALL #=   903 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK712
         LTORG 
RT1_OK712      DS 0H
*MEXIT #=   903 LV= 2 RT1
CLGIB2_B12  CLGIB R5,0,2,*+10
*MCALL #=   904 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   904 LV= 2 RT1
*MCALL #=   905 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK714
         LTORG 
RT1_OK714      DS 0H
*MEXIT #=   905 LV= 2 RT1
CLGIB4_B12  CLGIB R5,255,4,*+10
*MCALL #=   906 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   906 LV= 2 RT1
*MCALL #=   907 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK716
         LTORG 
RT1_OK716      DS 0H
*MEXIT #=   907 LV= 2 RT1
CLGIBE_B12  CLGIBE  R5,1,*+10
*MCALL #=   908 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   908 LV= 2 RT1
*MCALL #=   909 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK718
         LTORG 
RT1_OK718      DS 0H
*MEXIT #=   909 LV= 2 RT1
CLGIBH_B12  CLGIBH  R5,0,*+10
*MCALL #=   910 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   910 LV= 2 RT1
*MCALL #=   911 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK720
         LTORG 
RT1_OK720      DS 0H
*MEXIT #=   911 LV= 2 RT1
CLGIBL_B12  CLGIBL  R5,255,*+10
*MCALL #=   912 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   912 LV= 2 RT1
*MCALL #=   913 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK722
         LTORG 
RT1_OK722      DS 0H
*MEXIT #=   913 LV= 2 RT1
CLGIBNE_B12  CLGIBNE  R5,0,*+10
*MCALL #=   914 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   914 LV= 2 RT1
*MCALL #=   915 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK724
         LTORG 
RT1_OK724      DS 0H
*MEXIT #=   915 LV= 2 RT1
CLGIBNH_B12  CLGIBNH  R5,255,*+10
*MCALL #=   916 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   916 LV= 2 RT1
*MCALL #=   917 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK726
         LTORG 
RT1_OK726      DS 0H
*MEXIT #=   917 LV= 2 RT1
CLGIBNL_B12  CLGIBNL  R5,0,*+10
*MCALL #=   918 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   918 LV= 2 RT1
*MCALL #=   919 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK728
         LTORG 
RT1_OK728      DS 0H
*MEXIT #=   919 LV= 2 RT1
CLGIB8_NB12  CLGIB R5,0,8,RT1_ABORT
*MCALL #=   920 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK729
         LTORG 
RT1_OK729      DS 0H
*MEXIT #=   920 LV= 2 RT1
CLGIB2_NB12  CLGIB R5,1,2,RT1_ABORT
*MCALL #=   921 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK730
         LTORG 
RT1_OK730      DS 0H
*MEXIT #=   921 LV= 2 RT1
CLGIB4_NB12  CLGIB R5,1,4,RT1_ABORT
*MCALL #=   922 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK731
         LTORG 
RT1_OK731      DS 0H
*MEXIT #=   922 LV= 2 RT1
CLGIBE_NB12  CLGIBE  R5,255,RT1_ABORT
*MCALL #=   923 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK732
         LTORG 
RT1_OK732      DS 0H
*MEXIT #=   923 LV= 2 RT1
CLGIBH_NB12  CLGIBH  R5,255,RT1_ABORT
*MCALL #=   924 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK733
         LTORG 
RT1_OK733      DS 0H
*MEXIT #=   924 LV= 2 RT1
CLGIBL_NB12  CLGIBL  R5,0,RT1_ABORT
*MCALL #=   925 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK734
         LTORG 
RT1_OK734      DS 0H
*MEXIT #=   925 LV= 2 RT1
CLGIBNE_NB12  CLGIBNE  R5,1,RT1_ABORT
*MCALL #=   926 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK735
         LTORG 
RT1_OK735      DS 0H
*MEXIT #=   926 LV= 2 RT1
CLGIBNH_NB12  CLGIBNH  R5,0,RT1_ABORT
*MCALL #=   927 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK736
         LTORG 
RT1_OK736      DS 0H
*MEXIT #=   927 LV= 2 RT1
CLGIBNL_NB12  CLGIBNL  R5,255,RT1_ABORT
*MCALL #=   928 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK737
         LTORG 
RT1_OK737      DS 0H
*MEXIT #=   928 LV= 2 RT1
*MEXIT #=   901 LV= 1 TESTCAB
* ECFE CIB R1,I2,M3,I4 COMPARE IMMEDIATE R32 AND BRANCH
*MCALL #=   929 LV= 1          TESTCAB CIB,A,32,8
         L     R5,=F'0'
CIB8_B13    CIB   R5,0,8,*+10
*MCALL #=   930 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   930 LV= 2 RT1
*MCALL #=   931 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK739
         LTORG 
RT1_OK739      DS 0H
*MEXIT #=   931 LV= 2 RT1
CIB2_B13    CIB   R5,-1,2,*+10
*MCALL #=   932 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   932 LV= 2 RT1
*MCALL #=   933 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK741
         LTORG 
RT1_OK741      DS 0H
*MEXIT #=   933 LV= 2 RT1
CIB4_B13    CIB   R5,1,4,*+10
*MCALL #=   934 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   934 LV= 2 RT1
*MCALL #=   935 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK743
         LTORG 
RT1_OK743      DS 0H
*MEXIT #=   935 LV= 2 RT1
CIBE_B13    CIBE    R5,0,*+10
*MCALL #=   936 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   936 LV= 2 RT1
*MCALL #=   937 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK745
         LTORG 
RT1_OK745      DS 0H
*MEXIT #=   937 LV= 2 RT1
CIBH_B13    CIBH    R5,-1,*+10
*MCALL #=   938 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   938 LV= 2 RT1
*MCALL #=   939 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK747
         LTORG 
RT1_OK747      DS 0H
*MEXIT #=   939 LV= 2 RT1
CIBL_B13    CIBL    R5,1,*+10
*MCALL #=   940 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   940 LV= 2 RT1
*MCALL #=   941 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK749
         LTORG 
RT1_OK749      DS 0H
*MEXIT #=   941 LV= 2 RT1
CIBNE_B13    CIBNE    R5,-1,*+10
*MCALL #=   942 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   942 LV= 2 RT1
*MCALL #=   943 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK751
         LTORG 
RT1_OK751      DS 0H
*MEXIT #=   943 LV= 2 RT1
CIBNH_B13    CIBNH    R5,1,*+10
*MCALL #=   944 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   944 LV= 2 RT1
*MCALL #=   945 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK753
         LTORG 
RT1_OK753      DS 0H
*MEXIT #=   945 LV= 2 RT1
CIBNL_B13    CIBNL    R5,-1,*+10
*MCALL #=   946 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   946 LV= 2 RT1
*MCALL #=   947 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK755
         LTORG 
RT1_OK755      DS 0H
*MEXIT #=   947 LV= 2 RT1
CIB8_NB13    CIB   R5,-1,8,RT1_ABORT
*MCALL #=   948 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK756
         LTORG 
RT1_OK756      DS 0H
*MEXIT #=   948 LV= 2 RT1
CIB2_NB13    CIB   R5,0,2,RT1_ABORT
*MCALL #=   949 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK757
         LTORG 
RT1_OK757      DS 0H
*MEXIT #=   949 LV= 2 RT1
CIB4_NB13    CIB   R5,0,4,RT1_ABORT
*MCALL #=   950 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK758
         LTORG 
RT1_OK758      DS 0H
*MEXIT #=   950 LV= 2 RT1
CIBE_NB13    CIBE    R5,1,RT1_ABORT
*MCALL #=   951 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK759
         LTORG 
RT1_OK759      DS 0H
*MEXIT #=   951 LV= 2 RT1
CIBH_NB13    CIBH    R5,1,RT1_ABORT
*MCALL #=   952 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK760
         LTORG 
RT1_OK760      DS 0H
*MEXIT #=   952 LV= 2 RT1
CIBL_NB13    CIBL    R5,-1,RT1_ABORT
*MCALL #=   953 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK761
         LTORG 
RT1_OK761      DS 0H
*MEXIT #=   953 LV= 2 RT1
CIBNE_NB13    CIBNE    R5,0,RT1_ABORT
*MCALL #=   954 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK762
         LTORG 
RT1_OK762      DS 0H
*MEXIT #=   954 LV= 2 RT1
CIBNH_NB13    CIBNH    R5,-1,RT1_ABORT
*MCALL #=   955 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK763
         LTORG 
RT1_OK763      DS 0H
*MEXIT #=   955 LV= 2 RT1
CIBNL_NB13    CIBNL    R5,1,RT1_ABORT
*MCALL #=   956 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK764
         LTORG 
RT1_OK764      DS 0H
*MEXIT #=   956 LV= 2 RT1
*MEXIT #=   929 LV= 1 TESTCAB
* ECFF CLIB R1,I2,M3,I4 COMPARE LOG IMMEDIATE R32 AND BRANCH
*MCALL #=   957 LV= 1          TESTCAB CLIB,L,32,8
         L     R5,=F'1'
CLIB8_B14   CLIB  R5,1,8,*+10
*MCALL #=   958 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   958 LV= 2 RT1
*MCALL #=   959 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK766
         LTORG 
RT1_OK766      DS 0H
*MEXIT #=   959 LV= 2 RT1
CLIB2_B14   CLIB  R5,0,2,*+10
*MCALL #=   960 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   960 LV= 2 RT1
*MCALL #=   961 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK768
         LTORG 
RT1_OK768      DS 0H
*MEXIT #=   961 LV= 2 RT1
CLIB4_B14   CLIB  R5,255,4,*+10
*MCALL #=   962 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   962 LV= 2 RT1
*MCALL #=   963 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK770
         LTORG 
RT1_OK770      DS 0H
*MEXIT #=   963 LV= 2 RT1
CLIBE_B14   CLIBE   R5,1,*+10
*MCALL #=   964 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   964 LV= 2 RT1
*MCALL #=   965 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK772
         LTORG 
RT1_OK772      DS 0H
*MEXIT #=   965 LV= 2 RT1
CLIBH_B14   CLIBH   R5,0,*+10
*MCALL #=   966 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   966 LV= 2 RT1
*MCALL #=   967 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK774
         LTORG 
RT1_OK774      DS 0H
*MEXIT #=   967 LV= 2 RT1
CLIBL_B14   CLIBL   R5,255,*+10
*MCALL #=   968 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   968 LV= 2 RT1
*MCALL #=   969 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK776
         LTORG 
RT1_OK776      DS 0H
*MEXIT #=   969 LV= 2 RT1
CLIBNE_B14   CLIBNE   R5,0,*+10
*MCALL #=   970 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   970 LV= 2 RT1
*MCALL #=   971 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK778
         LTORG 
RT1_OK778      DS 0H
*MEXIT #=   971 LV= 2 RT1
CLIBNH_B14   CLIBNH   R5,255,*+10
*MCALL #=   972 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   972 LV= 2 RT1
*MCALL #=   973 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK780
         LTORG 
RT1_OK780      DS 0H
*MEXIT #=   973 LV= 2 RT1
CLIBNL_B14   CLIBNL   R5,0,*+10
*MCALL #=   974 LV= 2          RT1   ABORT
         DS    0H
         B      RT1_ABORT
*MEXIT #=   974 LV= 2 RT1
*MCALL #=   975 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK782
         LTORG 
RT1_OK782      DS 0H
*MEXIT #=   975 LV= 2 RT1
CLIB8_NB14   CLIB  R5,0,8,RT1_ABORT
*MCALL #=   976 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK783
         LTORG 
RT1_OK783      DS 0H
*MEXIT #=   976 LV= 2 RT1
CLIB2_NB14   CLIB  R5,1,2,RT1_ABORT
*MCALL #=   977 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK784
         LTORG 
RT1_OK784      DS 0H
*MEXIT #=   977 LV= 2 RT1
CLIB4_NB14   CLIB  R5,1,4,RT1_ABORT
*MCALL #=   978 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK785
         LTORG 
RT1_OK785      DS 0H
*MEXIT #=   978 LV= 2 RT1
CLIBE_NB14   CLIBE   R5,255,RT1_ABORT
*MCALL #=   979 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK786
         LTORG 
RT1_OK786      DS 0H
*MEXIT #=   979 LV= 2 RT1
CLIBH_NB14   CLIBH   R5,255,RT1_ABORT
*MCALL #=   980 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK787
         LTORG 
RT1_OK787      DS 0H
*MEXIT #=   980 LV= 2 RT1
CLIBL_NB14   CLIBL   R5,0,RT1_ABORT
*MCALL #=   981 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK788
         LTORG 
RT1_OK788      DS 0H
*MEXIT #=   981 LV= 2 RT1
CLIBNE_NB14   CLIBNE   R5,1,RT1_ABORT
*MCALL #=   982 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK789
         LTORG 
RT1_OK789      DS 0H
*MEXIT #=   982 LV= 2 RT1
CLIBNH_NB14   CLIBNH   R5,0,RT1_ABORT
*MCALL #=   983 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK790
         LTORG 
RT1_OK790      DS 0H
*MEXIT #=   983 LV= 2 RT1
CLIBNL_NB14   CLIBNL   R5,255,RT1_ABORT
*MCALL #=   984 LV= 2          RT1   OK
         DS    0H
         BAS   RT1_LINK,RT1_OK
         USING *,RT1_LINK
         B     RT1_OK791
         LTORG 
RT1_OK791      DS 0H
*MEXIT #=   984 LV= 2 RT1
*MEXIT #=   957 LV= 1 TESTCAB
* END
*MCALL #=   985 LV= 1          RT1   END
         B      RT1_END
*MEXIT #=   985 LV= 1 RT1
*MCALL #=   986 LV= 1          IHAEPIE 
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
*MEXIT #=   986 LV= 1 IHAEPIE
*MCALL #=   987 LV= 1          IHASDWA 
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
*MEXIT #=   987 LV= 1 IHASDWA
         END 
