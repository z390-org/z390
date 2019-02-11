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
* 2005-09-30  DSH          Initial version                          *
* 2005-10-03  DSH RPI-3    Test RS/RX with comma for omitted index  *
*                          registers                                *
* 2005-11-08  DSH RPI-73   Change PKA to support length byte        *
*                          from S2                                  *
* 2006-01-09  DSH RPI-161  Allow D(,B) in RXY instruction.          *
*                          Not fixed by RPI-3                       *
* 2006-02-02  DSH RPI-185  Add newZ9 opcodes (AFI, AGFI, ETC.)      *
* 2006-02-10  DSH RPI-199  Add extended BRCL branch opcodes,        *
*                          fix JXLEG                                *
* 2006-02-18  DSH RPI-206  Correct RRF1, RRF2, RRF3 types           *
* 2006-04-12  DSH RPI-277  Correct tests for 13 opcodes with no     *
*                          parameters (see NOPARMS)                 *
* 2006-04-25  DSH RPI-296  Correct CSCH, RSCH, SCHM, and XSCH       *
*                          (no parameters)                          *
* 2006-04-28  DSH RPI-298  Correct MY and MYH opcodes               *
* 2006-09-18  DSH RPI-454  Add RE2 RRE format for TROO, TROT, TRTO, *
*                          TRTT R,R,M                               *
* 2006-12-05  DSH RPI-407  Add DFP opcodes                          *
* 2006-12-19  DSH RPI-406  Correct RRF2 type for CGXTR, CGDTR,      *
*                          IEDTR, IEXTR                             *
* 2006-12-20  DSH RPI-406  Add LFAS, SRNMT, SFASR instructions      *
* 2006-12-27  DSH RPI-527  Add CPSDR, LCDFR, LDGR, LGDR, LNDFR,     *
*                          LPDFR                                    *
* 2008-02-28  DSH RPI-812  Add ASSIST instructions                  *
*                          RXAS - XDECO, XDECI, XHEXI, XHEXO        *
*                                 R1,XBD2 CVT to/from DEC/HEX       *
*                          RXSS - XDUMP default area if no operands *
*                          RXSS - XDUMP S1,L2 dump XBD1(BD2) record *
*                                 area                              *
*                          RXSS - XLIMD S1,L2 set XDUMP default     *
*                                 record area XBD1(BD2)             *
*                          RXSS - XGET, XPUT, XREAD, XPNCH, XPRNT   *
*                                 XBD1(BD2) from/to DDNAME=OP       *
* 2008-03-02  DSH RPI-817  Add Z10 opcodes CRT, CGRT, CIT, CGIT     *
* 2008-03-03  DSH RPI-817  Add Z10 opcodes COMP/BRANCH EC64 - ECFF  *
*                          RIE/RRS                                  *
* 2008-03-08  DSH RPI-817  Add Z10 opcodes 59 from B9A2-EC57        *
* 2008-03-19  DSH RPI-819  Clear R3 to remove F4's before using as  *
*                          test base                                *
* 2008-04-22  DSH RPI-833  Add string quotes for HLASM compatibility*
* 2009-03-09  DSH RPI-1013 Add PFPO, ECTG, and CSST per POP V7      *
*                          specifications                           *
* 2010-08-06  DSH RPI-1125 Add POPCNT documented in SHARE           *
*                          Presentation. 08/04/10                   *
* 2010-10-09  DSH RPI-1125 Add LEDBR?, LDXBR?, LEXBR?               *
* 2010-10-20  DSH RPI-1125 Add FIEBR?, FIDBR?, FIXBR?, SRNMB        *
* 2010-11-24  DSH RPI-1125 B39C-B3A2 CLFEBR - CXLGBR                *
* 2010-11-28  DSH RPI-1125 Add B3A4-B3AE CEGBRA, CGEBRA, CLGEBR     *
* 2010-12-02  DSH RPI-1125 Add B3E1-BEF9 CGDTRA-CXGTRA              *
* 2010-12-03  DSH RPI-1125 Add B928-B92D PCKMO KMOTR                *
* 2010-12-04  DSH RPI-1125 Add B941-B95B CFDTR - CXLFTR,            *
*                          fix MDTRA DFP/BFP RND                    *
* 2010-12-06  DSH RPI-1125 Add B9AE-B9CB RRBM-SLHHHR                *
* 2010-12-08  DSH RPI-1125 Add B9CD-B9DF CHHR-CLHHLR                *
* 2010-12-09  DSH RPI-1125 Add B9E2-B9FB LOCGR-SLRK                 *
* 2010-12-09  DSH RPI-1125 Add C84-C85 LPD-LPDG                     *
* 2010-12-11  DSH RPI-1125 Add CC6-CCF BRCTH - CLIH                 *
* 2010-12-18  DSH RPI-1125 Add E3C0-E3CF LBH - CLHF                 *
* 2010-12-19  DSH RPI-1125 Add EBDC-EBFA SRAK - LAAL                *
* 2010-12-21  DSH RPI-1125 Add EC51-ECDB RISBLG - ALGSIK            *
* 2011-01-30  DSH RPI-1152 Correct ECTG/CSST C81/C82 opcode         *
* 2011-03-16  DSH RPI-1139 Correct substring test beyond end of     *
*                          string                                   *
* 2011-05-17  DSH RPI-1164 Add Z196 extended opcodes EC51-EC5D,     *
*                          correct Z support                        *
*********************************************************************
* This program generates assembled instructions and compares the    *
* generated code to expected code for each instruction type and     *
* test operands specified.                                          *
*                                                                   *
* RT1 macro used to automate code generated for mainline and test   *
* PSW CC routines. The macros define new base register for each     *
* test so they can extend for any length.                           *
*                                                                   *
* See TESTINS2 for instruction execution unit tests.                *
*********************************************************************
         TITLE 'TESTINS1 - VERIFY ASSEMBLY OF EACH INSTRUCTION'
*MCALL #=     1 LV= 1 TESTINS1 RT1   MAIN
*MCALL #=     2 LV= 2 TESTINS1 SUBENTRY 
TESTINS1 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTINS1'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTINS1+8,13
*MEXIT #=     2 LV= 2 SUBENTRY
*MCALL #=     3 LV= 2          WTO   'TESTINS1 RT1 STARTED'
         BRAS  1,*+(WTO#0003_EOT-*+1)/2*2
         DC    AL2(WTO#0003_EOT-*,0),C'TESTINS1 RT1 STARTED'
WTO#0003_EOT     EQU *
         SVC   35
*MEXIT #=     3 LV= 2 WTO
         BRCL    15,RT1_START
RT1_ABORT DS 0H
         MVI   RT1_ABORTED,C'T'
*MCALL #=     4 LV= 2          WTO   'TESTINS1 RT1 TESTING ABORTED'
         BRAS  1,*+(WTO#0004_EOT-*+1)/2*2
         DC    AL2(WTO#0004_EOT-*,0),C'TESTINS1 RT1 TESTING ABORTED'
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
*MCALL #=     6 LV= 2          WTO   'TESTINS1 RT1 ENDED OK'
         BRAS  1,*+(WTO#0006_EOT-*+1)/2*2
         DC    AL2(WTO#0006_EOT-*,0),C'TESTINS1 RT1 ENDED OK'
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
RT1_WTO1 DC    AL2(RT1_WTO_END-*,0),C'TESTINS1 RT1 TESTS COMPLETED = '
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
* OPERAND CONSTANTS
R1       EQU  1
R2       EQU  2
R3       EQU  3
X4       EQU  4
M3       EQU  3       RPI-817
M4       EQU  4
M5       EQU  5
I2       EQU  -1      RPI-817
I3       EQU  X'33'   RPI-817
I4       EQU  X'44'   RPI-817
I5       EQU  X'55'   RPI-817
PL1      EQU  6+1
PL2      EQU  7+1
LL       EQU  256
S1       EQU  TESTINS1+9  D001
S2       EQU  TESTINS1+10 D002
S4       EQU  TESTINS1+12 D004
II       EQU  X'FF'
R11      EQU  11
R12      EQU  12
*
* ZOSOP INLINE MACRO TO GENERATE Z/ARCHITECTURE INSTRUCTION
* REGRESSION TESTS FOR THE ASSEMBLER.
*
         MACRO
         ZOSOP &HEXOP,&DESC,&OP,&TYPE,&NOP=F
         GBLA  &N
&N       SETA  &N+1
&OP1     SETC '&OP'(2,K'&OP-2)
         JAS   R11,VER&N
         USING *,R11
         AIF ('&TYPE'(2,4) EQ 'RIE2').RIE2 CIT    RPI-817
         AIF ('&TYPE'(2,4) EQ 'RIE3').RIE3 CITE   RPI-817
         AIF ('&TYPE'(2,4) EQ 'RIE4').RIE4 CGIJ   RPI-817
         AIF ('&TYPE'(2,4) EQ 'RIE5').RIE5 CGIJE  RPI-817
         AIF ('&TYPE'(2,4) EQ 'RIE6').RIE6 CGRB   RPI-817
         AIF ('&TYPE'(2,4) EQ 'RIE7').RIE7 CGRBE  RPI-817
         AIF ('&TYPE'(2,4) EQ 'RIE8').RIE8 RNSBG  RPI-817
         AIF ('&TYPE'(2,4) EQ 'RIE9').RIE9 AHIK   RPI-1125
         AIF ('&TYPE'(2,4) EQ 'RRF1').RRF1
         AIF ('&TYPE'(2,4) EQ 'RRF2').RRF2
         AIF ('&TYPE'(2,4) EQ 'RRF3').RRF3
         AIF ('&TYPE'(2,4) EQ 'RRF4').RRF4 CSDTR DFP RPI-407
         AIF ('&TYPE'(2,4) EQ 'RRF5').RRF5 CRT    RPI-817
         AIF ('&TYPE'(2,4) EQ 'RRF6').RRF6 CRTE   RPI-817
         AIF ('&TYPE'(2,4) EQ 'RRF7').RRF7 FIEBR? RPI-1125
         AIF ('&TYPE'(2,4) EQ 'RRR2').RRR2 MDTRA  RPI-1125
         AIF ('&TYPE'(2,4) EQ 'RRS1').RRS1 CGRB   RPI-817
         AIF ('&TYPE'(2,4) EQ 'RRS2').RRS2 CGRBE  RPI-817
         AIF ('&TYPE'(2,4) EQ 'RRS3').RRS3 CGIB   RPI-817
         AIF ('&TYPE'(2,4) EQ 'RRS4').RRS4 CGIBE  RPI-817
         AIF ('&TYPE'(2,4) EQ 'RSY2').RSY2 STOCG  RPI-1125
         AIF ('&TYPE'(2,4) EQ 'RXAS').RX   ASSIST RPI-812
         AIF ('&TYPE'(2,4) EQ 'RXSS').RXSS ASSIST RPI-812
         AIF ('&TYPE'(2,4) EQ 'SSF2').SSF2 LPD/LPDG RPI-1125
         AIF ('&TYPE'(2,3) EQ 'BCX').BCX
         AIF ('&TYPE'(2,3) EQ 'BRC').BRC
         AIF ('&TYPE'(2,3) EQ 'BRX').BRX
         AIF ('&TYPE'(2,3) EQ 'RIE').RIE
         AIF ('&TYPE'(2,3) EQ 'RIL').RIL
         AIF ('&TYPE'(2,3) EQ 'RR1').RR1  spm rr  r2=0
         AIF ('&TYPE'(2,3) EQ 'RR2').RR2  ipm rre r2=0
         AIF ('&TYPE'(2,3) EQ 'RRE').RRE
         AIF ('&TYPE'(2,3) EQ 'RE2').RE2
         AIF ('&TYPE'(2,3) EQ 'RE3').RE3  RPI-1125 LEDBR?
         AIF ('&TYPE'(2,3) EQ 'RE4').RE4  RPI-1125 PCKMO
         AIF ('&TYPE'(2,3) EQ 'RS2').RS2  shifts 88-8f r3=0
         AIF ('&TYPE'(2,3) EQ 'RSI').RSI
         AIF ('&TYPE'(2,3) EQ 'RSL').RSL
         AIF ('&TYPE'(2,3) EQ 'RSY').RSY
         AIF ('&TYPE'(2,3) EQ 'RXE').RXE
         AIF ('&TYPE'(2,3) EQ 'RXF').RXF
         AIF ('&TYPE'(2,3) EQ 'RXY').RXY
         AIF ('&TYPE'(2,3) EQ 'SIL').SIL
         AIF ('&TYPE'(2,3) EQ 'SIY').SIY
         AIF ('&TYPE'(2,3) EQ 'SS2').SS2
         AIF ('&TYPE'(2,3) EQ 'SS3').SS3
         AIF ('&TYPE'(2,3) EQ 'SS4').SS4
         AIF ('&TYPE'(2,3) EQ 'SS5').SS5
         AIF ('&TYPE'(2,3) EQ 'SS6').SS6
         AIF ('&TYPE'(2,3) EQ 'SSE').SSE
         AIF ('&TYPE'(2,3) EQ 'SSF').SSF
         AIF ('&TYPE'(2,3) EQ 'BLX').BLX
         AIF ('&TYPE'(2,3) EQ 'RRR').RRR
         AIF ('&TYPE'(2,2) EQ 'DM').DM
         AIF ('&TYPE'(2,2) EQ 'RI').RI
         AIF ('&TYPE'(2,2) EQ 'RR').RR
         AIF ('&TYPE'(2,2) EQ 'RS').RS
         AIF ('&TYPE'(2,2) EQ 'RX').RX
         AIF ('&TYPE'(2,2) EQ 'SI').SI
         AIF ('&TYPE'(2,2) EQ 'SS').SS
         AIF ('&TYPE'(2,1) EQ 'E').E
         AIF ('&TYPE'(2,1) EQ 'I').I
         AIF ('&TYPE'(2,1) EQ 'S').S
         MNOTE 8,'UNDEFINED TYPE = &TYPE'
         MEXIT
.VER     ANOP
HEX&N    DC    X'&CODE'
NUM&N    DC    P'&N'
VER&N    RT1   CCE,INS&N,HEX&N
         MEXIT
.BCX     ANOP
INS&N    &OP1  S2(X4)
&CODE    SETC  '&HEXOP'(2,3).'4D002'
         AGO   .VER
.BRC     ANOP
INS&N    &OP1 *-2
&CODE    SETC  '&HEXOP'(2,2).'&HEXOP'(5,1).'&HEXOP'(4,1).'FFFF'
         AGO   .VER
.BRX     ANOP
INS&N    &OP1 R1
&CODE    SETC  '&HEXOP'(2,3).'1'
         AGO   .VER
.DM      ANOP
INS&N    &OP1
&CODE    SETC  '&HEXOP'(2,2).'000000'
         AGO   .VER
.E       ANOP
INS&N    &OP1  , NOP
&CODE    SETC  '&HEXOP'(2,4)
         AGO   .VER
.I       ANOP
INS&N    &OP1  II
&CODE    SETC  '&HEXOP'(2,2).'FF'
         AGO   .VER
.RI      ANOP
INS&N    &OP1 R1,*-2
&CODE    SETC  '&HEXOP'(2,2).'1'.'&HEXOP'(4,1).'FFFF'
         AGO   .VER
.RIE     ANOP
INS&N    &OP1 R1,R3,*-2
&CODE    SETC  '&HEXOP'(2,2).'13FFFF00'.'&HEXOP'(4,2)
         AGO   .VER
.RIE2    ANOP                        RPI-817 CIT,CGIT
INS&N    &OP1 R1,I2,M3
&CODE    SETC  '&HEXOP'(2,2).'10FFFF30'.'&HEXOP'(4,2)
         AGO   .VER
.RIE3    ANOP                        RPI-817 CITE,CGITE
INS&N    &OP1 R1,I2
&CODE    SETC  '&HEXOP'(2,2).'10FFFF'.'&HEXOP'(6,1).'0'.'&HEXOP'(4,2)
         AGO   .VER
.RIE4    ANOP                        RPI-817 CGIJ  OO13FFFFFFOO
INS&N    &OP1 R1,I2,M3,*-2
&CODE    SETC  '&HEXOP'(2,2).'13FFFFFF'.'&HEXOP'(4,2)
         AGO   .VER
.RIE5    ANOP                        RPI-817 CGIJE OO13FFFFFFOO
INS&N    &OP1 R1,I2,*-2
&CODE    SETC  '&HEXOP'(2,2).'1'.'&HEXOP'(6,1).'FFFFFF'.'&HEXOP'(4,2)
         AGO   .VER
.RIE6    ANOP                        RPI-817 CGIJ  OO13FFFFFFOO
INS&N    &OP1 R1,R2,M3,*-2
&CODE    SETC  '&HEXOP'(2,2).'12FFFF30'.'&HEXOP'(4,2)
         AGO   .VER
.RIE7    ANOP                        RPI-817 CGIJE OO13FFFFFFOO
INS&N    &OP1 R1,R2,*-2
&CODE    SETC  '&HEXOP'(2,2).'12FFFF'.'&HEXOP'(6,1).'0'.'&HEXOP'(4,2)
         AGO   .VER
.RIE8    ANOP                        RPI-817 RNSBG OO12334455OO
         AIF   (K'&HEXOP LT 6).RIE8_NOT$
         AIF   ('&HEXOP'(6,1) NE '$').RIE8_NOT$
&TR3     SETA  D2A('&HEXOP'(7,2))
&TR4     SETA  D2A('&HEXOP'(9,2))
         AIF   ('&OP1'(1,1) NE 'L').RIE8_SKIPZ
&TR4     SETA  &TR4+X'80'
.RIE8_SKIPZ ANOP
&TR5     SETA  D2A('&HEXOP'(11,2))
&XR3     SETC  A2X(&TR3)
&XR4     SETC  A2X(&TR4)
&XR5     SETC  A2X(&TR5)
INS&N    &OP1 R1,R2
&CODE    SETC  '&HEXOP'(2,2).'12'.'&XR3'(7,2).'&XR4'(7,2).'&XR5'(7,2).'X
               &HEXOP'(4,2)
         AGO   .VER
.RIE8_NOT$ ANOP
INS&N    &OP1  R1,R2,I3,I4,I5
         AIF   ('&OP1'(K'&OP1,1) EQ 'T').RIE8T   RPI-1139 RPI-1164
         AIF   ('&OP1'(K'&OP1,1) EQ 'Z').RIE8Z   RPI-1139 RPI-1164
&CODE    SETC  '&HEXOP'(2,2).'12334455'.'&HEXOP'(4,2)
         AGO   .VER
.RIE8T   ANOP
&CODE    SETC  '&HEXOP'(2,2).'12B34455'.'&HEXOP'(4,2)  I3 TEST BIT ON
         AGO   .VER
.RIE8Z   ANOP
&CODE    SETC  '&HEXOP'(2,2).'1233C455'.'&HEXOP'(4,2)  I4 ZERO BIT ON
         AGO   .VER
.RIE9    ANOP            RPI-1125 AHIK/AGHIK oo13iiii00oo
INS&N    &OP1 R1,R3,I2
&CODE    SETC  '&HEXOP'(2,2).'13FFFF00'.'&HEXOP'(4,2)
         AGO   .VER
.RIL     ANOP
INS&N    &OP1 M5,*-2
&CODE    SETC  '&HEXOP'(2,2).'5'.'&HEXOP'(4,1).'FFFFFFFF'
         AGO   .VER
.RR      ANOP
INS&N    &OP1 R1,R2
&CODE    SETC  '&HEXOP'(2,2).'12'
         AGO   .VER
.RR1     ANOP
INS&N    &OP1 R1
&CODE    SETC  '&HEXOP'(2,2).'10'
         AGO   .VER
.RRE     ANOP
         AIF  ('&NOP' EQ 'T').RRENOP
INS&N    &OP1 R1,R2
&CODE    SETC  '&HEXOP'(2,4).'0012'
         AGO   .VER
.RRENOP  ANOP
INS&N    &OP1  , NOP
&CODE    SETC  '&HEXOP'(2,4).'0000'
         AGO   .VER
.RE2     ANOP  TROO,TROT,TRTO,TRTT RPI-454
INS&N    &OP1 R1,R2,M4
&CODE    SETC  '&HEXOP'(2,4).'4012'
         AGO   .VER
.RE3     ANOP
&OP1B    SETC  '&OP1'(1,K'&OP1-1)
INS&N    &OP1B R1,R2
&CODE    SETC  '&HEXOP'(2,4).'0012'
HEX&N    DC    X'&CODE'
&OP1A    SETC  '&OP1'(1,K'&OP1-1).'A'
INSA&N   &OP1A R1,M3,R2,M4
&CODE    SETC  '&HEXOP'(2,4).'3412'
HEXA&N   DC    X'&CODE'
VER&N    RT1   CCE,INS&N,HEX&N
         L     R1,=A(INSA&N)
         USING INSA&N,R1
         RT1   CCE,INSA&N,HEXA&N
         MEXIT
.RE4     ANOP  PCKMO RPI-1125
INS&N    &OP1
&CODE    SETC  '&HEXOP'(2,4).'0000'
         AGO   .VER
VERA&N   DS     0H

.RR2     ANOP
INS&N    &OP1 R1
&CODE    SETC  '&HEXOP'(2,4).'0010'
         AGO   .VER
.RRF1    ANOP              MA?R, MS?R, MY?T B3OO WITH OO < 40
INS&N    &OP1 R1,R3,R2
&CODE    SETC  '&HEXOP'(2,4).'1032' RPI-206
         AGO   .VER
.RRF2    ANOP              CG?R, CF?R. FI?R, IDTE, TB?R
INS&N    &OP1 R1,R3,R2
&CODE    SETC  '&HEXOP'(2,4).'3012' RPI-206
         AGO   .VER
.RRF3    ANOP
INS&N    &OP1 R1,R3,R2,M4
&CODE    SETC  '&HEXOP'(2,4).'3412'
         AGO   .VER
.RRF4    ANOP              CG?R, CF?R. FI?R, IDTE, TB?R
INS&N    &OP1 R1,R2,m4
&CODE    SETC  '&HEXOP'(2,4).'0412' RPI-206
         AGO   .VER
.RRF5    ANOP              CRT,CGRT RPI-817
INS&N    &OP1 R1,R2,M3
&CODE    SETC  '&HEXOP'(2,4).'3012'
         AGO   .VER
.RRF6    ANOP              CRTE,CGRTE RPI-817
INS&N    &OP1 R1,R2
&CODE    SETC  '&HEXOP'(2,5).'012'
         AGO   .VER
.RRF7    ANOP              FIEBR?, FIDBR?, FIXBR? RPI-1125
&OP1B    SETC  '&OP1'(1,K'&OP1-1)
INS&N    &OP1B R1,M3,R2
&CODE    SETC  '&HEXOP'(2,4).'3012'
HEX&N    DC    X'&CODE'
&OP1A    SETC  '&OP1'(1,K'&OP1-1).'A'
INSA&N   &OP1A R1,M3,R2,M4
&CODE    SETC  '&HEXOP'(2,4).'3412'
HEXA&N   DC    X'&CODE'
VER&N    RT1   CCE,INS&N,HEX&N
         L     R1,=A(INSA&N)
         USING INSA&N,R1
         RT1   CCE,INSA&N,HEXA&N
         MEXIT
.RRS1    ANOP                        RPI-817 CGRB  OO12BDDD30OO
INS&N    &OP1 R1,R2,M3,S4
&CODE    SETC  '&HEXOP'(2,2).'12D00430'.'&HEXOP'(4,2)
         AGO   .VER
.RRS2    ANOP                        RPI-817 CGRBE OO12BDDD30OO
INS&N    &OP1 R1,R2,S4
&CODE    SETC  '&HEXOP'(2,2).'12D004'.'&HEXOP'(6,1).'0'.'&HEXOP'(4,2)
         AGO   .VER
.RRS3    ANOP                        RPI-817 CGIB OO13444422OO
INS&N    &OP1 R1,I2,M3,S4
&CODE    SETC  '&HEXOP'(2,2).'13D004FF'.'&HEXOP'(4,2)
         AGO   .VER
.RRS4    ANOP                        RPI-817 CGIBE OO13444422OO
INS&N    &OP1 R1,I2,S4
&CODE    SETC  '&HEXOP'(2,2).'1'.'&HEXOP'(6,1).'D004FF'.'&HEXOP'(4,2)
         AGO   .VER
.RS2     ANOP
INS&N    &OP1 R1,S2
&CODE    SETC  '&HEXOP'(2,2).'10D002'
         AGO   .VER
.RSI     ANOP
INS&N    &OP1 R1,R2,*-2
&CODE    SETC  '&HEXOP'(2,2).'12FFFF'
         AGO   .VER
.RS      ANOP
INS&N    &OP1 R1,R3,S2
&CODE    SETC  '&HEXOP'(2,2).'13D002'
         AGO   .VER
.RSL     ANOP
INS&N    &OP1 S2(PL2)
&CODE    SETC  '&HEXOP'(2,2).'70D00200'.'&HEXOP'(4,2)
         AGO   .VER
.RSY     ANOP
INS&N    &OP1 R1,R3,S2
&CODE    SETC  '&HEXOP'(2,2).'13D00200'.'&HEXOP'(4,2)
         AGO   .VER
.RSY2    ANOP
INS&N    &OP1 R1,S2,M3
&CODE    SETC  '&HEXOP'(2,2).'13D00200'.'&HEXOP'(4,2)
         AGO   .VER
.RX      ANOP
INS&N    &OP1 R1,S2(X4)
&CODE    SETC  '&HEXOP'(2,2).'14D002'
         AGO   .VER
.RXE     ANOP
INS&N    &OP1 R1,S2(X4)
&CODE    SETC  '&HEXOP'(2,2).'14D00200'.'&HEXOP'(4,2)
         AGO   .VER
.RXF     ANOP
INS&N    &OP1 R1,R3,S2(X4)
&CODE    SETC  '&HEXOP'(2,2).'34D00210'.'&HEXOP'(4,2)
         AGO   .VER
.RXSS    ANOP
INS&N    &OP1 S2(X4),S1
&CODE    SETC  '&HEXOP'(2,3).'4D002D001'
         AGO   .VER
.RXY     ANOP
INS&N    &OP1 R1,S2(X4)
&CODE    SETC  '&HEXOP'(2,2).'14D00200'.'&HEXOP'(4,2)
         AGO   .VER
.S       ANOP
         AIF   ('&NOP' EQ 'T').SNOP
INS&N    &OP1  S1
&CODE    SETC  '&HEXOP'(2,4).'D001'
         AGO   .VER
.SNOP    ANOP
INS&N    &OP1  , NOP
&CODE    SETC  '&HEXOP'(2,4).'0000'
         AGO   .VER
.SI      ANOP
INS&N    &OP1 S1,II
&CODE    SETC  '&HEXOP'(2,2).'FFD001'
         AGO   .VER
.SIL     ANOP
INS&N    &OP1 S1,II
&CODE    SETC  '&HEXOP'(2,4).'D00100FF'
         AGO   .VER
.SIY     ANOP
INS&N    &OP1 S1,II
&CODE    SETC  '&HEXOP'(2,2).'FFD00100'.'&HEXOP'(4,2)
         AGO   .VER
.SS      ANOP
INS&N    &OP1 S1(LL),S2
&CODE    SETC  '&HEXOP'(2,2).'FFD001D002'
         AGO   .VER
.SS2     ANOP
INS&N    &OP1 S1(PL1),S2(PL2)
&CODE    SETC  '&HEXOP'(2,2).'67D001D002'
         AGO   .VER
.SS3     ANOP
INS&N    &OP1 R1,S2,R3,S4
&CODE    SETC  '&HEXOP'(2,2).'13D002D004'
         AGO   .VER
.SS4     ANOP
INS&N    &OP1 R1,R3,S2,S4
&CODE    SETC  '&HEXOP'(2,2).'13D002D004'
         AGO   .VER
.SS5     ANOP
INS&N    &OP1 S1(PL1),S2,R3
&CODE    SETC  '&HEXOP'(2,2).'63D001D002'
         AGO   .VER
.SSE     ANOP
INS&N    &OP1 S1,S2
&CODE    SETC  '&HEXOP'(2,4).'D001D002'
         AGO   .VER
.SSF     ANOP
INS&N    &OP1 S1,S2,R3
&CODE    SETC  '&HEXOP'(2,2).'3'.'&HEXOP'(4,1).'D001D002' RPI-1152
         AGO   .VER
.SSF2    ANOP
INS&N    &OP1 R3,S1,S2
&CODE    SETC  '&HEXOP'(2,2).'3'.'&HEXOP'(4,1).'D001D002'
         AGO   .VER
.SS6    ANOP
INS&N    &OP1 S1,S2(32)
&CODE    SETC  '&HEXOP'(2,2).'1FD001D002'
         AGO   .VER
.BLX     ANOP
INS&N    &OP1 *-2
&CODE    SETC  '&HEXOP'(2,4).'FFFFFFFF'
         AGO   .VER
.RRR     ANOP              ADTR
INS&N    &OP1 R1,R2,R3
&CODE    SETC  '&HEXOP'(2,4).'3012' RPI-407
         AGO   .VER
.RRR2   ANOP
&OP1B    SETC  '&OP1'(1,K'&OP1-1)
INS&N    &OP1B R1,R2,R3
&CODE    SETC  '&HEXOP'(2,4).'3012'
HEX&N    DC    X'&CODE'
&OP1A    SETC  '&OP1'(1,K'&OP1-1).'A'
INSA&N   &OP1A R1,R2,R3,M4
&CODE    SETC  '&HEXOP'(2,4).'3412'
HEXA&N   DC    X'&CODE'
VER&N    RT1   CCE,INS&N,HEX&N
         L     R1,=A(INSA&N)
         USING INSA&N,R1
         RT1   CCE,INSA&N,HEXA&N
         MEXIT
         MEND
*
* START TESTS USING ZOSOP MACRO WHICH GENERATES
* TEST DATA AND REGRESSION TEST MACRO CALLS
*
*MCALL #=     9 LV= 1  RT1   START
RT1_START DS  0H
*MEXIT #=     9 LV= 1 RT1
*MCALL #=    10 LV= 1  ZOSOP '0101','PROGRAM RETURN ','PR ','E L ',NOP=X
               T RPI-277
         JAS   R11,VER1
         USING *,R11
INS1     PR    , NOP
HEX1     DC    X'0101'
NUM1     DC    P'1'
*MCALL #=    11 LV= 2 VER1     RT1   CCE,INS1,HEX1
VER1     DS    0H
         CLC   INS1,HEX1
RT1_TEST1        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1
         LTORG 
RT1_CCE1        DS 0H
*MEXIT #=    11 LV= 2 RT1
*MEXIT #=    10 LV= 1 ZOSOP
*MCALL #=    12 LV= 1  ZOSOP '0102','UPDATE TREE ','UPT ','E C ',NOP=T X
               RPI-277
         JAS   R11,VER2
         USING *,R11
INS2     UPT   , NOP
HEX2     DC    X'0102'
NUM2     DC    P'2'
*MCALL #=    13 LV= 2 VER2     RT1   CCE,INS2,HEX2
VER2     DS    0H
         CLC   INS2,HEX2
RT1_TEST2        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE2
         LTORG 
RT1_CCE2        DS 0H
*MEXIT #=    13 LV= 2 RT1
*MEXIT #=    12 LV= 1 ZOSOP
*MCALL #=    14 LV= 1  ZOSOP '0104','PERFORM TIMING FACILITY FUNCTION',X
               'PTFF','E',Z9,NOP=T
         JAS   R11,VER3
         USING *,R11
INS3     PTFF  , NOP
HEX3     DC    X'0104'
NUM3     DC    P'3'
*MCALL #=    15 LV= 2 VER3     RT1   CCE,INS3,HEX3
VER3     DS    0H
         CLC   INS3,HEX3
RT1_TEST3        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE3
         LTORG 
RT1_CCE3        DS 0H
*MEXIT #=    15 LV= 2 RT1
*MEXIT #=    14 LV= 1 ZOSOP
*MCALL #=    16 LV= 1  ZOSOP '0107','SET CLOCK PROGRAMMABLE FIELD ','SCX
               KPF','E ',NOP=T
         JAS   R11,VER4
         USING *,R11
INS4     SCKPF , NOP
HEX4     DC    X'0107'
NUM4     DC    P'4'
*MCALL #=    17 LV= 2 VER4     RT1   CCE,INS4,HEX4
VER4     DS    0H
         CLC   INS4,HEX4
RT1_TEST4        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE4
         LTORG 
RT1_CCE4        DS 0H
*MEXIT #=    17 LV= 2 RT1
*MEXIT #=    16 LV= 1 ZOSOP
*MCALL #=    18 LV= 1  ZOSOP '010A','PERFORM FP CONVERSION','PFPO','E PX
               F',NOP=T     RPI-1013
         JAS   R11,VER5
         USING *,R11
INS5     PFPO  , NOP
HEX5     DC    X'010A'
NUM5     DC    P'5'
*MCALL #=    19 LV= 2 VER5     RT1   CCE,INS5,HEX5
VER5     DS    0H
         CLC   INS5,HEX5
RT1_TEST5        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE5
         LTORG 
RT1_CCE5        DS 0H
*MEXIT #=    19 LV= 2 RT1
*MEXIT #=    18 LV= 1 ZOSOP
*MCALL #=    20 LV= 1  ZOSOP '010B','TEST ADDRESSING MODE ','TAM ','E CX
                N3',NOP=T
         JAS   R11,VER6
         USING *,R11
INS6     TAM   , NOP
HEX6     DC    X'010B'
NUM6     DC    P'6'
*MCALL #=    21 LV= 2 VER6     RT1   CCE,INS6,HEX6
VER6     DS    0H
         CLC   INS6,HEX6
RT1_TEST6        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE6
         LTORG 
RT1_CCE6        DS 0H
*MEXIT #=    21 LV= 2 RT1
*MEXIT #=    20 LV= 1 ZOSOP
*MCALL #=    22 LV= 1  ZOSOP '010C','SET ADDRESSING MODE (24) ','SAM24'X
               ,'E N3',NOP=T
         JAS   R11,VER7
         USING *,R11
INS7     SAM24 , NOP
HEX7     DC    X'010C'
NUM7     DC    P'7'
*MCALL #=    23 LV= 2 VER7     RT1   CCE,INS7,HEX7
VER7     DS    0H
         CLC   INS7,HEX7
RT1_TEST7        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE7
         LTORG 
RT1_CCE7        DS 0H
*MEXIT #=    23 LV= 2 RT1
*MEXIT #=    22 LV= 1 ZOSOP
*MCALL #=    24 LV= 1  ZOSOP '010D','SET ADDRESSING MODE (31) ','SAM31'X
               ,'E N3',NOP=T
         JAS   R11,VER8
         USING *,R11
INS8     SAM31 , NOP
HEX8     DC    X'010D'
NUM8     DC    P'8'
*MCALL #=    25 LV= 2 VER8     RT1   CCE,INS8,HEX8
VER8     DS    0H
         CLC   INS8,HEX8
RT1_TEST8        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE8
         LTORG 
RT1_CCE8        DS 0H
*MEXIT #=    25 LV= 2 RT1
*MEXIT #=    24 LV= 1 ZOSOP
*MCALL #=    26 LV= 1  ZOSOP '010E','SET ADDRESSING MODE (64) ','SAM64'X
               ,'E N ',NOP=T
         JAS   R11,VER9
         USING *,R11
INS9     SAM64 , NOP
HEX9     DC    X'010E'
NUM9     DC    P'9'
*MCALL #=    27 LV= 2 VER9     RT1   CCE,INS9,HEX9
VER9     DS    0H
         CLC   INS9,HEX9
RT1_TEST9        BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE9
         LTORG 
RT1_CCE9        DS 0H
*MEXIT #=    27 LV= 2 RT1
*MEXIT #=    26 LV= 1 ZOSOP
*MCALL #=    28 LV= 1  ZOSOP '01FF','TRAP ','TRAP2','E ',NOP=T
         JAS   R11,VER10
         USING *,R11
INS10    TRAP2 , NOP
HEX10    DC    X'01FF'
NUM10    DC    P'10'
*MCALL #=    29 LV= 2 VER10    RT1   CCE,INS10,HEX10
VER10    DS    0H
         CLC   INS10,HEX10
RT1_TEST10       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE10
         LTORG 
RT1_CCE10       DS 0H
*MEXIT #=    29 LV= 2 RT1
*MEXIT #=    28 LV= 1 ZOSOP
*MCALL #=    30 LV= 1  ZOSOP '04 ','SET PROGRAM MASK ','SPM ','RR1 L '
         JAS   R11,VER11
         USING *,R11
INS11    SPM  R1
HEX11    DC    X'0410'
NUM11    DC    P'11'
*MCALL #=    31 LV= 2 VER11    RT1   CCE,INS11,HEX11
VER11    DS    0H
         CLC   INS11,HEX11
RT1_TEST11       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE11
         LTORG 
RT1_CCE11       DS 0H
*MEXIT #=    31 LV= 2 RT1
*MEXIT #=    30 LV= 1 ZOSOP
*MCALL #=    32 LV= 1  ZOSOP '05 ','BRANCH AND LINK ','BALR ','RR '
         JAS   R11,VER12
         USING *,R11
INS12    BALR  R1,R2
HEX12    DC    X'0512'
NUM12    DC    P'12'
*MCALL #=    33 LV= 2 VER12    RT1   CCE,INS12,HEX12
VER12    DS    0H
         CLC   INS12,HEX12
RT1_TEST12       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE12
         LTORG 
RT1_CCE12       DS 0H
*MEXIT #=    33 LV= 2 RT1
*MEXIT #=    32 LV= 1 ZOSOP
*MCALL #=    34 LV= 1  ZOSOP '06 ','BRANCH ON COUNT (32) ','BCTR ','RR X
               '
         JAS   R11,VER13
         USING *,R11
INS13    BCTR  R1,R2
HEX13    DC    X'0612'
NUM13    DC    P'13'
*MCALL #=    35 LV= 2 VER13    RT1   CCE,INS13,HEX13
VER13    DS    0H
         CLC   INS13,HEX13
RT1_TEST13       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE13
         LTORG 
RT1_CCE13       DS 0H
*MEXIT #=    35 LV= 2 RT1
*MEXIT #=    34 LV= 1 ZOSOP
*MCALL #=    36 LV= 1  ZOSOP '07 ','BRANCH ON CONDITION ','BCR ','RR '
         JAS   R11,VER14
         USING *,R11
INS14    BCR  R1,R2
HEX14    DC    X'0712'
NUM14    DC    P'14'
*MCALL #=    37 LV= 2 VER14    RT1   CCE,INS14,HEX14
VER14    DS    0H
         CLC   INS14,HEX14
RT1_TEST14       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE14
         LTORG 
RT1_CCE14       DS 0H
*MEXIT #=    37 LV= 2 RT1
*MEXIT #=    36 LV= 1 ZOSOP
*MCALL #=    38 LV= 1  ZOSOP '07F','EXTENDED BRANCH','BR','BRX'
         JAS   R11,VER15
         USING *,R11
INS15    BR   R1
HEX15    DC    X'07F1'
NUM15    DC    P'15'
*MCALL #=    39 LV= 2 VER15    RT1   CCE,INS15,HEX15
VER15    DS    0H
         CLC   INS15,HEX15
RT1_TEST15       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE15
         LTORG 
RT1_CCE15       DS 0H
*MEXIT #=    39 LV= 2 RT1
*MEXIT #=    38 LV= 1 ZOSOP
*MCALL #=    40 LV= 1  ZOSOP '070','EXTENDED BRANCH','NOPR','BRX'
         JAS   R11,VER16
         USING *,R11
INS16    NOPR R1
HEX16    DC    X'0701'
NUM16    DC    P'16'
*MCALL #=    41 LV= 2 VER16    RT1   CCE,INS16,HEX16
VER16    DS    0H
         CLC   INS16,HEX16
RT1_TEST16       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE16
         LTORG 
RT1_CCE16       DS 0H
*MEXIT #=    41 LV= 2 RT1
*MEXIT #=    40 LV= 1 ZOSOP
*MCALL #=    42 LV= 1  ZOSOP '072','EXTENDED BRANCH','BHR','BRX'
         JAS   R11,VER17
         USING *,R11
INS17    BHR  R1
HEX17    DC    X'0721'
NUM17    DC    P'17'
*MCALL #=    43 LV= 2 VER17    RT1   CCE,INS17,HEX17
VER17    DS    0H
         CLC   INS17,HEX17
RT1_TEST17       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE17
         LTORG 
RT1_CCE17       DS 0H
*MEXIT #=    43 LV= 2 RT1
*MEXIT #=    42 LV= 1 ZOSOP
*MCALL #=    44 LV= 1  ZOSOP '074','EXTENDED BRANCH','BLR','BRX'
         JAS   R11,VER18
         USING *,R11
INS18    BLR  R1
HEX18    DC    X'0741'
NUM18    DC    P'18'
*MCALL #=    45 LV= 2 VER18    RT1   CCE,INS18,HEX18
VER18    DS    0H
         CLC   INS18,HEX18
RT1_TEST18       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE18
         LTORG 
RT1_CCE18       DS 0H
*MEXIT #=    45 LV= 2 RT1
*MEXIT #=    44 LV= 1 ZOSOP
*MCALL #=    46 LV= 1  ZOSOP '078','EXTENDED BRANCH','BER','BRX'
         JAS   R11,VER19
         USING *,R11
INS19    BER  R1
HEX19    DC    X'0781'
NUM19    DC    P'19'
*MCALL #=    47 LV= 2 VER19    RT1   CCE,INS19,HEX19
VER19    DS    0H
         CLC   INS19,HEX19
RT1_TEST19       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE19
         LTORG 
RT1_CCE19       DS 0H
*MEXIT #=    47 LV= 2 RT1
*MEXIT #=    46 LV= 1 ZOSOP
*MCALL #=    48 LV= 1  ZOSOP '07D','EXTENDED BRANCH','BNHR','BRX'
         JAS   R11,VER20
         USING *,R11
INS20    BNHR R1
HEX20    DC    X'07D1'
NUM20    DC    P'20'
*MCALL #=    49 LV= 2 VER20    RT1   CCE,INS20,HEX20
VER20    DS    0H
         CLC   INS20,HEX20
RT1_TEST20       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE20
         LTORG 
RT1_CCE20       DS 0H
*MEXIT #=    49 LV= 2 RT1
*MEXIT #=    48 LV= 1 ZOSOP
*MCALL #=    50 LV= 1  ZOSOP '07B','EXTENDED BRANCH','BNLR','BRX'
         JAS   R11,VER21
         USING *,R11
INS21    BNLR R1
HEX21    DC    X'07B1'
NUM21    DC    P'21'
*MCALL #=    51 LV= 2 VER21    RT1   CCE,INS21,HEX21
VER21    DS    0H
         CLC   INS21,HEX21
RT1_TEST21       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE21
         LTORG 
RT1_CCE21       DS 0H
*MEXIT #=    51 LV= 2 RT1
*MEXIT #=    50 LV= 1 ZOSOP
*MCALL #=    52 LV= 1  ZOSOP '077','EXTENDED BRANCH','BNER','BRX'
         JAS   R11,VER22
         USING *,R11
INS22    BNER R1
HEX22    DC    X'0771'
NUM22    DC    P'22'
*MCALL #=    53 LV= 2 VER22    RT1   CCE,INS22,HEX22
VER22    DS    0H
         CLC   INS22,HEX22
RT1_TEST22       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE22
         LTORG 
RT1_CCE22       DS 0H
*MEXIT #=    53 LV= 2 RT1
*MEXIT #=    52 LV= 1 ZOSOP
*MCALL #=    54 LV= 1  ZOSOP '072','EXTENDED BRANCH','BPR','BRX'
         JAS   R11,VER23
         USING *,R11
INS23    BPR  R1
HEX23    DC    X'0721'
NUM23    DC    P'23'
*MCALL #=    55 LV= 2 VER23    RT1   CCE,INS23,HEX23
VER23    DS    0H
         CLC   INS23,HEX23
RT1_TEST23       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE23
         LTORG 
RT1_CCE23       DS 0H
*MEXIT #=    55 LV= 2 RT1
*MEXIT #=    54 LV= 1 ZOSOP
*MCALL #=    56 LV= 1  ZOSOP '071','EXTENDED BRANCH','BOR','BRX'
         JAS   R11,VER24
         USING *,R11
INS24    BOR  R1
HEX24    DC    X'0711'
NUM24    DC    P'24'
*MCALL #=    57 LV= 2 VER24    RT1   CCE,INS24,HEX24
VER24    DS    0H
         CLC   INS24,HEX24
RT1_TEST24       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE24
         LTORG 
RT1_CCE24       DS 0H
*MEXIT #=    57 LV= 2 RT1
*MEXIT #=    56 LV= 1 ZOSOP
*MCALL #=    58 LV= 1  ZOSOP '074','EXTENDED BRANCH','BMR','BRX'
         JAS   R11,VER25
         USING *,R11
INS25    BMR  R1
HEX25    DC    X'0741'
NUM25    DC    P'25'
*MCALL #=    59 LV= 2 VER25    RT1   CCE,INS25,HEX25
VER25    DS    0H
         CLC   INS25,HEX25
RT1_TEST25       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE25
         LTORG 
RT1_CCE25       DS 0H
*MEXIT #=    59 LV= 2 RT1
*MEXIT #=    58 LV= 1 ZOSOP
*MCALL #=    60 LV= 1  ZOSOP '078','EXTENDED BRANCH','BZR','BRX'
         JAS   R11,VER26
         USING *,R11
INS26    BZR  R1
HEX26    DC    X'0781'
NUM26    DC    P'26'
*MCALL #=    61 LV= 2 VER26    RT1   CCE,INS26,HEX26
VER26    DS    0H
         CLC   INS26,HEX26
RT1_TEST26       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE26
         LTORG 
RT1_CCE26       DS 0H
*MEXIT #=    61 LV= 2 RT1
*MEXIT #=    60 LV= 1 ZOSOP
*MCALL #=    62 LV= 1  ZOSOP '07D','EXTENDED BRANCH','BNPR','BRX'
         JAS   R11,VER27
         USING *,R11
INS27    BNPR R1
HEX27    DC    X'07D1'
NUM27    DC    P'27'
*MCALL #=    63 LV= 2 VER27    RT1   CCE,INS27,HEX27
VER27    DS    0H
         CLC   INS27,HEX27
RT1_TEST27       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE27
         LTORG 
RT1_CCE27       DS 0H
*MEXIT #=    63 LV= 2 RT1
*MEXIT #=    62 LV= 1 ZOSOP
*MCALL #=    64 LV= 1  ZOSOP '07B','EXTENDED BRANCH','BNMR','BRX'
         JAS   R11,VER28
         USING *,R11
INS28    BNMR R1
HEX28    DC    X'07B1'
NUM28    DC    P'28'
*MCALL #=    65 LV= 2 VER28    RT1   CCE,INS28,HEX28
VER28    DS    0H
         CLC   INS28,HEX28
RT1_TEST28       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE28
         LTORG 
RT1_CCE28       DS 0H
*MEXIT #=    65 LV= 2 RT1
*MEXIT #=    64 LV= 1 ZOSOP
*MCALL #=    66 LV= 1  ZOSOP '077','EXTENDED BRANCH','BNZR','BRX'
         JAS   R11,VER29
         USING *,R11
INS29    BNZR R1
HEX29    DC    X'0771'
NUM29    DC    P'29'
*MCALL #=    67 LV= 2 VER29    RT1   CCE,INS29,HEX29
VER29    DS    0H
         CLC   INS29,HEX29
RT1_TEST29       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE29
         LTORG 
RT1_CCE29       DS 0H
*MEXIT #=    67 LV= 2 RT1
*MEXIT #=    66 LV= 1 ZOSOP
*MCALL #=    68 LV= 1  ZOSOP '07E','EXTENDED BRANCH','BNOR','BRX'
         JAS   R11,VER30
         USING *,R11
INS30    BNOR R1
HEX30    DC    X'07E1'
NUM30    DC    P'30'
*MCALL #=    69 LV= 2 VER30    RT1   CCE,INS30,HEX30
VER30    DS    0H
         CLC   INS30,HEX30
RT1_TEST30       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE30
         LTORG 
RT1_CCE30       DS 0H
*MEXIT #=    69 LV= 2 RT1
*MEXIT #=    68 LV= 1 ZOSOP
*MCALL #=    70 LV= 1  ZOSOP '0A ','SUPERVISOR CALL ','SVC ','I '
         JAS   R11,VER31
         USING *,R11
INS31    SVC   II
HEX31    DC    X'0AFF'
NUM31    DC    P'31'
*MCALL #=    71 LV= 2 VER31    RT1   CCE,INS31,HEX31
VER31    DS    0H
         CLC   INS31,HEX31
RT1_TEST31       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE31
         LTORG 
RT1_CCE31       DS 0H
*MEXIT #=    71 LV= 2 RT1
*MEXIT #=    70 LV= 1 ZOSOP
*MCALL #=    72 LV= 1  ZOSOP '0B ','BRANCH AND SET MODE ','BSM ','RR '
         JAS   R11,VER32
         USING *,R11
INS32    BSM  R1,R2
HEX32    DC    X'0B12'
NUM32    DC    P'32'
*MCALL #=    73 LV= 2 VER32    RT1   CCE,INS32,HEX32
VER32    DS    0H
         CLC   INS32,HEX32
RT1_TEST32       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE32
         LTORG 
RT1_CCE32       DS 0H
*MEXIT #=    73 LV= 2 RT1
*MEXIT #=    72 LV= 1 ZOSOP
*MCALL #=    74 LV= 1  ZOSOP '0C ','BRANCH AND SAVE AND SET MODE ','BASX
               SM','RR '
         JAS   R11,VER33
         USING *,R11
INS33    BASSM R1,R2
HEX33    DC    X'0C12'
NUM33    DC    P'33'
*MCALL #=    75 LV= 2 VER33    RT1   CCE,INS33,HEX33
VER33    DS    0H
         CLC   INS33,HEX33
RT1_TEST33       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE33
         LTORG 
RT1_CCE33       DS 0H
*MEXIT #=    75 LV= 2 RT1
*MEXIT #=    74 LV= 1 ZOSOP
*MCALL #=    76 LV= 1  ZOSOP '0D ','BRANCH AND SAVE ','BASR ','RR '
         JAS   R11,VER34
         USING *,R11
INS34    BASR  R1,R2
HEX34    DC    X'0D12'
NUM34    DC    P'34'
*MCALL #=    77 LV= 2 VER34    RT1   CCE,INS34,HEX34
VER34    DS    0H
         CLC   INS34,HEX34
RT1_TEST34       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE34
         LTORG 
RT1_CCE34       DS 0H
*MEXIT #=    77 LV= 2 RT1
*MEXIT #=    76 LV= 1 ZOSOP
*MCALL #=    78 LV= 1  ZOSOP '0E ','MOVE LONG ','MVCL ','RR C '
         JAS   R11,VER35
         USING *,R11
INS35    MVCL  R1,R2
HEX35    DC    X'0E12'
NUM35    DC    P'35'
*MCALL #=    79 LV= 2 VER35    RT1   CCE,INS35,HEX35
VER35    DS    0H
         CLC   INS35,HEX35
RT1_TEST35       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE35
         LTORG 
RT1_CCE35       DS 0H
*MEXIT #=    79 LV= 2 RT1
*MEXIT #=    78 LV= 1 ZOSOP
*MCALL #=    80 LV= 1  ZOSOP '0F ','COMPARE LOGICAL LONG ','CLCL ','RR X
               C '
         JAS   R11,VER36
         USING *,R11
INS36    CLCL  R1,R2
HEX36    DC    X'0F12'
NUM36    DC    P'36'
*MCALL #=    81 LV= 2 VER36    RT1   CCE,INS36,HEX36
VER36    DS    0H
         CLC   INS36,HEX36
RT1_TEST36       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE36
         LTORG 
RT1_CCE36       DS 0H
*MEXIT #=    81 LV= 2 RT1
*MEXIT #=    80 LV= 1 ZOSOP
*MCALL #=    82 LV= 1  ZOSOP '10 ','LOAD POSITIVE (32) ','LPR ','RR C '
         JAS   R11,VER37
         USING *,R11
INS37    LPR  R1,R2
HEX37    DC    X'1012'
NUM37    DC    P'37'
*MCALL #=    83 LV= 2 VER37    RT1   CCE,INS37,HEX37
VER37    DS    0H
         CLC   INS37,HEX37
RT1_TEST37       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE37
         LTORG 
RT1_CCE37       DS 0H
*MEXIT #=    83 LV= 2 RT1
*MEXIT #=    82 LV= 1 ZOSOP
*MCALL #=    84 LV= 1  ZOSOP '11 ','LOAD NEGATIVE (32) ','LNR ','RR C '
         JAS   R11,VER38
         USING *,R11
INS38    LNR  R1,R2
HEX38    DC    X'1112'
NUM38    DC    P'38'
*MCALL #=    85 LV= 2 VER38    RT1   CCE,INS38,HEX38
VER38    DS    0H
         CLC   INS38,HEX38
RT1_TEST38       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE38
         LTORG 
RT1_CCE38       DS 0H
*MEXIT #=    85 LV= 2 RT1
*MEXIT #=    84 LV= 1 ZOSOP
*MCALL #=    86 LV= 1  ZOSOP '12 ','LOAD AND TEST (32) ','LTR ','RR C '
         JAS   R11,VER39
         USING *,R11
INS39    LTR  R1,R2
HEX39    DC    X'1212'
NUM39    DC    P'39'
*MCALL #=    87 LV= 2 VER39    RT1   CCE,INS39,HEX39
VER39    DS    0H
         CLC   INS39,HEX39
RT1_TEST39       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE39
         LTORG 
RT1_CCE39       DS 0H
*MEXIT #=    87 LV= 2 RT1
*MEXIT #=    86 LV= 1 ZOSOP
*MCALL #=    88 LV= 1  ZOSOP '13 ','LOAD COMPLEMENT (32) ','LCR ','RR CX
                '
         JAS   R11,VER40
         USING *,R11
INS40    LCR  R1,R2
HEX40    DC    X'1312'
NUM40    DC    P'40'
*MCALL #=    89 LV= 2 VER40    RT1   CCE,INS40,HEX40
VER40    DS    0H
         CLC   INS40,HEX40
RT1_TEST40       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE40
         LTORG 
RT1_CCE40       DS 0H
*MEXIT #=    89 LV= 2 RT1
*MEXIT #=    88 LV= 1 ZOSOP
*MCALL #=    90 LV= 1  ZOSOP '14 ','AND (32) ','NR ','RR C '
         JAS   R11,VER41
         USING *,R11
INS41    NR   R1,R2
HEX41    DC    X'1412'
NUM41    DC    P'41'
*MCALL #=    91 LV= 2 VER41    RT1   CCE,INS41,HEX41
VER41    DS    0H
         CLC   INS41,HEX41
RT1_TEST41       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE41
         LTORG 
RT1_CCE41       DS 0H
*MEXIT #=    91 LV= 2 RT1
*MEXIT #=    90 LV= 1 ZOSOP
*MCALL #=    92 LV= 1  ZOSOP '15 ','COMPARE LOGICAL (32) ','CLR ','RR CX
                '
         JAS   R11,VER42
         USING *,R11
INS42    CLR  R1,R2
HEX42    DC    X'1512'
NUM42    DC    P'42'
*MCALL #=    93 LV= 2 VER42    RT1   CCE,INS42,HEX42
VER42    DS    0H
         CLC   INS42,HEX42
RT1_TEST42       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE42
         LTORG 
RT1_CCE42       DS 0H
*MEXIT #=    93 LV= 2 RT1
*MEXIT #=    92 LV= 1 ZOSOP
*MCALL #=    94 LV= 1  ZOSOP '16 ','OR (32) ','OR ','RR C '
         JAS   R11,VER43
         USING *,R11
INS43    OR   R1,R2
HEX43    DC    X'1612'
NUM43    DC    P'43'
*MCALL #=    95 LV= 2 VER43    RT1   CCE,INS43,HEX43
VER43    DS    0H
         CLC   INS43,HEX43
RT1_TEST43       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE43
         LTORG 
RT1_CCE43       DS 0H
*MEXIT #=    95 LV= 2 RT1
*MEXIT #=    94 LV= 1 ZOSOP
*MCALL #=    96 LV= 1  ZOSOP '17 ','EXCLUSIVE OR (32) ','XR ','RR C '
         JAS   R11,VER44
         USING *,R11
INS44    XR   R1,R2
HEX44    DC    X'1712'
NUM44    DC    P'44'
*MCALL #=    97 LV= 2 VER44    RT1   CCE,INS44,HEX44
VER44    DS    0H
         CLC   INS44,HEX44
RT1_TEST44       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE44
         LTORG 
RT1_CCE44       DS 0H
*MEXIT #=    97 LV= 2 RT1
*MEXIT #=    96 LV= 1 ZOSOP
*MCALL #=    98 LV= 1  ZOSOP '18 ','LOAD (32) ','LR ','RR '
         JAS   R11,VER45
         USING *,R11
INS45    LR   R1,R2
HEX45    DC    X'1812'
NUM45    DC    P'45'
*MCALL #=    99 LV= 2 VER45    RT1   CCE,INS45,HEX45
VER45    DS    0H
         CLC   INS45,HEX45
RT1_TEST45       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE45
         LTORG 
RT1_CCE45       DS 0H
*MEXIT #=    99 LV= 2 RT1
*MEXIT #=    98 LV= 1 ZOSOP
*MCALL #=   100 LV= 1  ZOSOP '19 ','COMPARE (32) ','CR ','RR C '
         JAS   R11,VER46
         USING *,R11
INS46    CR   R1,R2
HEX46    DC    X'1912'
NUM46    DC    P'46'
*MCALL #=   101 LV= 2 VER46    RT1   CCE,INS46,HEX46
VER46    DS    0H
         CLC   INS46,HEX46
RT1_TEST46       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE46
         LTORG 
RT1_CCE46       DS 0H
*MEXIT #=   101 LV= 2 RT1
*MEXIT #=   100 LV= 1 ZOSOP
*MCALL #=   102 LV= 1  ZOSOP '1A ','ADD (32) ','AR ','RR C '
         JAS   R11,VER47
         USING *,R11
INS47    AR   R1,R2
HEX47    DC    X'1A12'
NUM47    DC    P'47'
*MCALL #=   103 LV= 2 VER47    RT1   CCE,INS47,HEX47
VER47    DS    0H
         CLC   INS47,HEX47
RT1_TEST47       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE47
         LTORG 
RT1_CCE47       DS 0H
*MEXIT #=   103 LV= 2 RT1
*MEXIT #=   102 LV= 1 ZOSOP
*MCALL #=   104 LV= 1  ZOSOP '1B ','SUBTRACT (32) ','SR ','RR C '
         JAS   R11,VER48
         USING *,R11
INS48    SR   R1,R2
HEX48    DC    X'1B12'
NUM48    DC    P'48'
*MCALL #=   105 LV= 2 VER48    RT1   CCE,INS48,HEX48
VER48    DS    0H
         CLC   INS48,HEX48
RT1_TEST48       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE48
         LTORG 
RT1_CCE48       DS 0H
*MEXIT #=   105 LV= 2 RT1
*MEXIT #=   104 LV= 1 ZOSOP
*MCALL #=   106 LV= 1  ZOSOP '1C ','MULTIPLY (64<32) ','MR ','RR '
         JAS   R11,VER49
         USING *,R11
INS49    MR   R1,R2
HEX49    DC    X'1C12'
NUM49    DC    P'49'
*MCALL #=   107 LV= 2 VER49    RT1   CCE,INS49,HEX49
VER49    DS    0H
         CLC   INS49,HEX49
RT1_TEST49       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE49
         LTORG 
RT1_CCE49       DS 0H
*MEXIT #=   107 LV= 2 RT1
*MEXIT #=   106 LV= 1 ZOSOP
*MCALL #=   108 LV= 1  ZOSOP '1D ','DIVIDE (32<64) ','DR ','RR '
         JAS   R11,VER50
         USING *,R11
INS50    DR   R1,R2
HEX50    DC    X'1D12'
NUM50    DC    P'50'
*MCALL #=   109 LV= 2 VER50    RT1   CCE,INS50,HEX50
VER50    DS    0H
         CLC   INS50,HEX50
RT1_TEST50       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE50
         LTORG 
RT1_CCE50       DS 0H
*MEXIT #=   109 LV= 2 RT1
*MEXIT #=   108 LV= 1 ZOSOP
*MCALL #=   110 LV= 1  ZOSOP '1E ','ADD LOGICAL (32) ','ALR ','RR C '
         JAS   R11,VER51
         USING *,R11
INS51    ALR  R1,R2
HEX51    DC    X'1E12'
NUM51    DC    P'51'
*MCALL #=   111 LV= 2 VER51    RT1   CCE,INS51,HEX51
VER51    DS    0H
         CLC   INS51,HEX51
RT1_TEST51       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE51
         LTORG 
RT1_CCE51       DS 0H
*MEXIT #=   111 LV= 2 RT1
*MEXIT #=   110 LV= 1 ZOSOP
*MCALL #=   112 LV= 1  ZOSOP '1F ','SUBTRACT LOGICAL (32) ','SLR ','RR X
               C '
         JAS   R11,VER52
         USING *,R11
INS52    SLR  R1,R2
HEX52    DC    X'1F12'
NUM52    DC    P'52'
*MCALL #=   113 LV= 2 VER52    RT1   CCE,INS52,HEX52
VER52    DS    0H
         CLC   INS52,HEX52
RT1_TEST52       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE52
         LTORG 
RT1_CCE52       DS 0H
*MEXIT #=   113 LV= 2 RT1
*MEXIT #=   112 LV= 1 ZOSOP
*MCALL #=   114 LV= 1  ZOSOP '20 ','LOAD POSITIVE (long HFP) ','LPDR ',X
               'RR C '
         JAS   R11,VER53
         USING *,R11
INS53    LPDR  R1,R2
HEX53    DC    X'2012'
NUM53    DC    P'53'
*MCALL #=   115 LV= 2 VER53    RT1   CCE,INS53,HEX53
VER53    DS    0H
         CLC   INS53,HEX53
RT1_TEST53       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE53
         LTORG 
RT1_CCE53       DS 0H
*MEXIT #=   115 LV= 2 RT1
*MEXIT #=   114 LV= 1 ZOSOP
*MCALL #=   116 LV= 1  ZOSOP '21 ','LOAD NEGATIVE (long HFP) ','LNDR ',X
               'RR C '
         JAS   R11,VER54
         USING *,R11
INS54    LNDR  R1,R2
HEX54    DC    X'2112'
NUM54    DC    P'54'
*MCALL #=   117 LV= 2 VER54    RT1   CCE,INS54,HEX54
VER54    DS    0H
         CLC   INS54,HEX54
RT1_TEST54       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE54
         LTORG 
RT1_CCE54       DS 0H
*MEXIT #=   117 LV= 2 RT1
*MEXIT #=   116 LV= 1 ZOSOP
*MCALL #=   118 LV= 1  ZOSOP '22 ','LOAD AND TEST (long HFP) ','LTDR ',X
               'RR C '
         JAS   R11,VER55
         USING *,R11
INS55    LTDR  R1,R2
HEX55    DC    X'2212'
NUM55    DC    P'55'
*MCALL #=   119 LV= 2 VER55    RT1   CCE,INS55,HEX55
VER55    DS    0H
         CLC   INS55,HEX55
RT1_TEST55       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE55
         LTORG 
RT1_CCE55       DS 0H
*MEXIT #=   119 LV= 2 RT1
*MEXIT #=   118 LV= 1 ZOSOP
*MCALL #=   120 LV= 1  ZOSOP '23 ','LOAD COMPLEMENT (long HFP) ','LCDR X
               ','RR C '
         JAS   R11,VER56
         USING *,R11
INS56    LCDR  R1,R2
HEX56    DC    X'2312'
NUM56    DC    P'56'
*MCALL #=   121 LV= 2 VER56    RT1   CCE,INS56,HEX56
VER56    DS    0H
         CLC   INS56,HEX56
RT1_TEST56       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE56
         LTORG 
RT1_CCE56       DS 0H
*MEXIT #=   121 LV= 2 RT1
*MEXIT #=   120 LV= 1 ZOSOP
*MCALL #=   122 LV= 1  ZOSOP '24 ','HALVE (long HFP) ','HDR ','RR '
         JAS   R11,VER57
         USING *,R11
INS57    HDR  R1,R2
HEX57    DC    X'2412'
NUM57    DC    P'57'
*MCALL #=   123 LV= 2 VER57    RT1   CCE,INS57,HEX57
VER57    DS    0H
         CLC   INS57,HEX57
RT1_TEST57       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE57
         LTORG 
RT1_CCE57       DS 0H
*MEXIT #=   123 LV= 2 RT1
*MEXIT #=   122 LV= 1 ZOSOP
*MCALL #=   124 LV= 1  ZOSOP '25 ','LOAD ROUNDED (extended to long HFP)X
                ','LDXR ','RR '
         JAS   R11,VER58
         USING *,R11
INS58    LDXR  R1,R2
HEX58    DC    X'2512'
NUM58    DC    P'58'
*MCALL #=   125 LV= 2 VER58    RT1   CCE,INS58,HEX58
VER58    DS    0H
         CLC   INS58,HEX58
RT1_TEST58       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE58
         LTORG 
RT1_CCE58       DS 0H
*MEXIT #=   125 LV= 2 RT1
*MEXIT #=   124 LV= 1 ZOSOP
*MCALL #=   126 LV= 1  ZOSOP '25 ','LOAD ROUNDED (extended to long HFP)X
                ','LRDR ','RR '
         JAS   R11,VER59
         USING *,R11
INS59    LRDR  R1,R2
HEX59    DC    X'2512'
NUM59    DC    P'59'
*MCALL #=   127 LV= 2 VER59    RT1   CCE,INS59,HEX59
VER59    DS    0H
         CLC   INS59,HEX59
RT1_TEST59       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE59
         LTORG 
RT1_CCE59       DS 0H
*MEXIT #=   127 LV= 2 RT1
*MEXIT #=   126 LV= 1 ZOSOP
*MCALL #=   128 LV= 1  ZOSOP '26 ','MULTIPLY (extended HFP) ','MXR ','RX
               R '
         JAS   R11,VER60
         USING *,R11
INS60    MXR  R1,R2
HEX60    DC    X'2612'
NUM60    DC    P'60'
*MCALL #=   129 LV= 2 VER60    RT1   CCE,INS60,HEX60
VER60    DS    0H
         CLC   INS60,HEX60
RT1_TEST60       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE60
         LTORG 
RT1_CCE60       DS 0H
*MEXIT #=   129 LV= 2 RT1
*MEXIT #=   128 LV= 1 ZOSOP
*MCALL #=   130 LV= 1  ZOSOP '27 ','MULTIPLY (long to extended HFP) ','X
               MXDR ','RR '
         JAS   R11,VER61
         USING *,R11
INS61    MXDR  R1,R2
HEX61    DC    X'2712'
NUM61    DC    P'61'
*MCALL #=   131 LV= 2 VER61    RT1   CCE,INS61,HEX61
VER61    DS    0H
         CLC   INS61,HEX61
RT1_TEST61       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE61
         LTORG 
RT1_CCE61       DS 0H
*MEXIT #=   131 LV= 2 RT1
*MEXIT #=   130 LV= 1 ZOSOP
*MCALL #=   132 LV= 1  ZOSOP '28 ','LOAD (long) ','LDR ','RR '
         JAS   R11,VER62
         USING *,R11
INS62    LDR  R1,R2
HEX62    DC    X'2812'
NUM62    DC    P'62'
*MCALL #=   133 LV= 2 VER62    RT1   CCE,INS62,HEX62
VER62    DS    0H
         CLC   INS62,HEX62
RT1_TEST62       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE62
         LTORG 
RT1_CCE62       DS 0H
*MEXIT #=   133 LV= 2 RT1
*MEXIT #=   132 LV= 1 ZOSOP
*MCALL #=   134 LV= 1  ZOSOP '29 ','COMPARE (long HFP) ','CDR ','RR C '
         JAS   R11,VER63
         USING *,R11
INS63    CDR  R1,R2
HEX63    DC    X'2912'
NUM63    DC    P'63'
*MCALL #=   135 LV= 2 VER63    RT1   CCE,INS63,HEX63
VER63    DS    0H
         CLC   INS63,HEX63
RT1_TEST63       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE63
         LTORG 
RT1_CCE63       DS 0H
*MEXIT #=   135 LV= 2 RT1
*MEXIT #=   134 LV= 1 ZOSOP
*MCALL #=   136 LV= 1  ZOSOP '2A ','ADD NORMALIZED (long HFP) ','ADR ',X
               'RR C '
         JAS   R11,VER64
         USING *,R11
INS64    ADR  R1,R2
HEX64    DC    X'2A12'
NUM64    DC    P'64'
*MCALL #=   137 LV= 2 VER64    RT1   CCE,INS64,HEX64
VER64    DS    0H
         CLC   INS64,HEX64
RT1_TEST64       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE64
         LTORG 
RT1_CCE64       DS 0H
*MEXIT #=   137 LV= 2 RT1
*MEXIT #=   136 LV= 1 ZOSOP
*MCALL #=   138 LV= 1  ZOSOP '2B ','SUBTRACT NORMALIZED (long HFP) ','SX
               DR ','RR C '
         JAS   R11,VER65
         USING *,R11
INS65    SDR  R1,R2
HEX65    DC    X'2B12'
NUM65    DC    P'65'
*MCALL #=   139 LV= 2 VER65    RT1   CCE,INS65,HEX65
VER65    DS    0H
         CLC   INS65,HEX65
RT1_TEST65       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE65
         LTORG 
RT1_CCE65       DS 0H
*MEXIT #=   139 LV= 2 RT1
*MEXIT #=   138 LV= 1 ZOSOP
*MCALL #=   140 LV= 1  ZOSOP '2C ','MULTIPLY (long HFP) ','MDR ','RR '
         JAS   R11,VER66
         USING *,R11
INS66    MDR  R1,R2
HEX66    DC    X'2C12'
NUM66    DC    P'66'
*MCALL #=   141 LV= 2 VER66    RT1   CCE,INS66,HEX66
VER66    DS    0H
         CLC   INS66,HEX66
RT1_TEST66       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE66
         LTORG 
RT1_CCE66       DS 0H
*MEXIT #=   141 LV= 2 RT1
*MEXIT #=   140 LV= 1 ZOSOP
*MCALL #=   142 LV= 1  ZOSOP '2D ','DIVIDE (long HFP) ','DDR ','RR '
         JAS   R11,VER67
         USING *,R11
INS67    DDR  R1,R2
HEX67    DC    X'2D12'
NUM67    DC    P'67'
*MCALL #=   143 LV= 2 VER67    RT1   CCE,INS67,HEX67
VER67    DS    0H
         CLC   INS67,HEX67
RT1_TEST67       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE67
         LTORG 
RT1_CCE67       DS 0H
*MEXIT #=   143 LV= 2 RT1
*MEXIT #=   142 LV= 1 ZOSOP
*MCALL #=   144 LV= 1  ZOSOP '2E ','ADD UNNORMALIZED (long HFP) ','AWR X
               ','RR C '
         JAS   R11,VER68
         USING *,R11
INS68    AWR  R1,R2
HEX68    DC    X'2E12'
NUM68    DC    P'68'
*MCALL #=   145 LV= 2 VER68    RT1   CCE,INS68,HEX68
VER68    DS    0H
         CLC   INS68,HEX68
RT1_TEST68       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE68
         LTORG 
RT1_CCE68       DS 0H
*MEXIT #=   145 LV= 2 RT1
*MEXIT #=   144 LV= 1 ZOSOP
*MCALL #=   146 LV= 1  ZOSOP '2F ','SUBTRACT UNNORMALIZED (long HFP) ',X
               'SWR ','RR C '
         JAS   R11,VER69
         USING *,R11
INS69    SWR  R1,R2
HEX69    DC    X'2F12'
NUM69    DC    P'69'
*MCALL #=   147 LV= 2 VER69    RT1   CCE,INS69,HEX69
VER69    DS    0H
         CLC   INS69,HEX69
RT1_TEST69       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE69
         LTORG 
RT1_CCE69       DS 0H
*MEXIT #=   147 LV= 2 RT1
*MEXIT #=   146 LV= 1 ZOSOP
*MCALL #=   148 LV= 1  ZOSOP '30 ','LOAD POSITIVE (short HFP) ','LPER 'X
               ,'RR C '
         JAS   R11,VER70
         USING *,R11
INS70    LPER  R1,R2
HEX70    DC    X'3012'
NUM70    DC    P'70'
*MCALL #=   149 LV= 2 VER70    RT1   CCE,INS70,HEX70
VER70    DS    0H
         CLC   INS70,HEX70
RT1_TEST70       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE70
         LTORG 
RT1_CCE70       DS 0H
*MEXIT #=   149 LV= 2 RT1
*MEXIT #=   148 LV= 1 ZOSOP
*MCALL #=   150 LV= 1  ZOSOP '31 ','LOAD NEGATIVE (short HFP) ','LNER 'X
               ,'RR C '
         JAS   R11,VER71
         USING *,R11
INS71    LNER  R1,R2
HEX71    DC    X'3112'
NUM71    DC    P'71'
*MCALL #=   151 LV= 2 VER71    RT1   CCE,INS71,HEX71
VER71    DS    0H
         CLC   INS71,HEX71
RT1_TEST71       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE71
         LTORG 
RT1_CCE71       DS 0H
*MEXIT #=   151 LV= 2 RT1
*MEXIT #=   150 LV= 1 ZOSOP
*MCALL #=   152 LV= 1  ZOSOP '32 ','LOAD AND TEST (short HFP) ','LTER 'X
               ,'RR C '
         JAS   R11,VER72
         USING *,R11
INS72    LTER  R1,R2
HEX72    DC    X'3212'
NUM72    DC    P'72'
*MCALL #=   153 LV= 2 VER72    RT1   CCE,INS72,HEX72
VER72    DS    0H
         CLC   INS72,HEX72
RT1_TEST72       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE72
         LTORG 
RT1_CCE72       DS 0H
*MEXIT #=   153 LV= 2 RT1
*MEXIT #=   152 LV= 1 ZOSOP
*MCALL #=   154 LV= 1  ZOSOP '33 ','LOAD COMPLEMENT (short HFP) ','LCERX
                ','RR C '
         JAS   R11,VER73
         USING *,R11
INS73    LCER  R1,R2
HEX73    DC    X'3312'
NUM73    DC    P'73'
*MCALL #=   155 LV= 2 VER73    RT1   CCE,INS73,HEX73
VER73    DS    0H
         CLC   INS73,HEX73
RT1_TEST73       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE73
         LTORG 
RT1_CCE73       DS 0H
*MEXIT #=   155 LV= 2 RT1
*MEXIT #=   154 LV= 1 ZOSOP
*MCALL #=   156 LV= 1  ZOSOP '34 ','HALVE (short HFP) ','HER ','RR '
         JAS   R11,VER74
         USING *,R11
INS74    HER  R1,R2
HEX74    DC    X'3412'
NUM74    DC    P'74'
*MCALL #=   157 LV= 2 VER74    RT1   CCE,INS74,HEX74
VER74    DS    0H
         CLC   INS74,HEX74
RT1_TEST74       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE74
         LTORG 
RT1_CCE74       DS 0H
*MEXIT #=   157 LV= 2 RT1
*MEXIT #=   156 LV= 1 ZOSOP
*MCALL #=   158 LV= 1  ZOSOP '35 ','LOAD ROUNDED (long to short HFP) ',X
               'LEDR ','RR '
         JAS   R11,VER75
         USING *,R11
INS75    LEDR  R1,R2
HEX75    DC    X'3512'
NUM75    DC    P'75'
*MCALL #=   159 LV= 2 VER75    RT1   CCE,INS75,HEX75
VER75    DS    0H
         CLC   INS75,HEX75
RT1_TEST75       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE75
         LTORG 
RT1_CCE75       DS 0H
*MEXIT #=   159 LV= 2 RT1
*MEXIT #=   158 LV= 1 ZOSOP
*MCALL #=   160 LV= 1  ZOSOP '35 ','LOAD ROUNDED (long to short HFP) ',X
               'LRER ','RR '
         JAS   R11,VER76
         USING *,R11
INS76    LRER  R1,R2
HEX76    DC    X'3512'
NUM76    DC    P'76'
*MCALL #=   161 LV= 2 VER76    RT1   CCE,INS76,HEX76
VER76    DS    0H
         CLC   INS76,HEX76
RT1_TEST76       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE76
         LTORG 
RT1_CCE76       DS 0H
*MEXIT #=   161 LV= 2 RT1
*MEXIT #=   160 LV= 1 ZOSOP
*MCALL #=   162 LV= 1  ZOSOP '36 ','ADD NORMALIZED (extended HFP) ','AXX
               R ','RR C '
         JAS   R11,VER77
         USING *,R11
INS77    AXR  R1,R2
HEX77    DC    X'3612'
NUM77    DC    P'77'
*MCALL #=   163 LV= 2 VER77    RT1   CCE,INS77,HEX77
VER77    DS    0H
         CLC   INS77,HEX77
RT1_TEST77       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE77
         LTORG 
RT1_CCE77       DS 0H
*MEXIT #=   163 LV= 2 RT1
*MEXIT #=   162 LV= 1 ZOSOP
*MCALL #=   164 LV= 1  ZOSOP '37 ','SUBTRACT NORMALIZED (extended HFP) X
               ','SXR ','RR C '
         JAS   R11,VER78
         USING *,R11
INS78    SXR  R1,R2
HEX78    DC    X'3712'
NUM78    DC    P'78'
*MCALL #=   165 LV= 2 VER78    RT1   CCE,INS78,HEX78
VER78    DS    0H
         CLC   INS78,HEX78
RT1_TEST78       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE78
         LTORG 
RT1_CCE78       DS 0H
*MEXIT #=   165 LV= 2 RT1
*MEXIT #=   164 LV= 1 ZOSOP
*MCALL #=   166 LV= 1  ZOSOP '38 ','LOAD (short) ','LER ','RR '
         JAS   R11,VER79
         USING *,R11
INS79    LER  R1,R2
HEX79    DC    X'3812'
NUM79    DC    P'79'
*MCALL #=   167 LV= 2 VER79    RT1   CCE,INS79,HEX79
VER79    DS    0H
         CLC   INS79,HEX79
RT1_TEST79       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE79
         LTORG 
RT1_CCE79       DS 0H
*MEXIT #=   167 LV= 2 RT1
*MEXIT #=   166 LV= 1 ZOSOP
*MCALL #=   168 LV= 1  ZOSOP '39 ','COMPARE (short HFP) ','CER ','RR C X
               '
         JAS   R11,VER80
         USING *,R11
INS80    CER  R1,R2
HEX80    DC    X'3912'
NUM80    DC    P'80'
*MCALL #=   169 LV= 2 VER80    RT1   CCE,INS80,HEX80
VER80    DS    0H
         CLC   INS80,HEX80
RT1_TEST80       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE80
         LTORG 
RT1_CCE80       DS 0H
*MEXIT #=   169 LV= 2 RT1
*MEXIT #=   168 LV= 1 ZOSOP
*MCALL #=   170 LV= 1  ZOSOP '3A ','ADD NORMALIZED (short HFP) ','AER 'X
               ,'RR C '
         JAS   R11,VER81
         USING *,R11
INS81    AER  R1,R2
HEX81    DC    X'3A12'
NUM81    DC    P'81'
*MCALL #=   171 LV= 2 VER81    RT1   CCE,INS81,HEX81
VER81    DS    0H
         CLC   INS81,HEX81
RT1_TEST81       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE81
         LTORG 
RT1_CCE81       DS 0H
*MEXIT #=   171 LV= 2 RT1
*MEXIT #=   170 LV= 1 ZOSOP
*MCALL #=   172 LV= 1  ZOSOP '3B ','SUBTRACT NORMALIZED (short HFP) ','X
               SER ','RR C '
         JAS   R11,VER82
         USING *,R11
INS82    SER  R1,R2
HEX82    DC    X'3B12'
NUM82    DC    P'82'
*MCALL #=   173 LV= 2 VER82    RT1   CCE,INS82,HEX82
VER82    DS    0H
         CLC   INS82,HEX82
RT1_TEST82       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE82
         LTORG 
RT1_CCE82       DS 0H
*MEXIT #=   173 LV= 2 RT1
*MEXIT #=   172 LV= 1 ZOSOP
*MCALL #=   174 LV= 1  ZOSOP '3C ','MULTIPLY (short to long HFP) ','MDEX
               R ','RR '
         JAS   R11,VER83
         USING *,R11
INS83    MDER  R1,R2
HEX83    DC    X'3C12'
NUM83    DC    P'83'
*MCALL #=   175 LV= 2 VER83    RT1   CCE,INS83,HEX83
VER83    DS    0H
         CLC   INS83,HEX83
RT1_TEST83       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE83
         LTORG 
RT1_CCE83       DS 0H
*MEXIT #=   175 LV= 2 RT1
*MEXIT #=   174 LV= 1 ZOSOP
*MCALL #=   176 LV= 1  ZOSOP '3C ','MULTIPLY (short to long HFP) ','MERX
                ','RR '
         JAS   R11,VER84
         USING *,R11
INS84    MER  R1,R2
HEX84    DC    X'3C12'
NUM84    DC    P'84'
*MCALL #=   177 LV= 2 VER84    RT1   CCE,INS84,HEX84
VER84    DS    0H
         CLC   INS84,HEX84
RT1_TEST84       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE84
         LTORG 
RT1_CCE84       DS 0H
*MEXIT #=   177 LV= 2 RT1
*MEXIT #=   176 LV= 1 ZOSOP
*MCALL #=   178 LV= 1  ZOSOP '3D ','DIVIDE (short HFP) ','DER ','RR '
         JAS   R11,VER85
         USING *,R11
INS85    DER  R1,R2
HEX85    DC    X'3D12'
NUM85    DC    P'85'
*MCALL #=   179 LV= 2 VER85    RT1   CCE,INS85,HEX85
VER85    DS    0H
         CLC   INS85,HEX85
RT1_TEST85       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE85
         LTORG 
RT1_CCE85       DS 0H
*MEXIT #=   179 LV= 2 RT1
*MEXIT #=   178 LV= 1 ZOSOP
*MCALL #=   180 LV= 1  ZOSOP '3E ','ADD UNNORMALIZED (short HFP) ','AURX
                ','RR C '
         JAS   R11,VER86
         USING *,R11
INS86    AUR  R1,R2
HEX86    DC    X'3E12'
NUM86    DC    P'86'
*MCALL #=   181 LV= 2 VER86    RT1   CCE,INS86,HEX86
VER86    DS    0H
         CLC   INS86,HEX86
RT1_TEST86       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE86
         LTORG 
RT1_CCE86       DS 0H
*MEXIT #=   181 LV= 2 RT1
*MEXIT #=   180 LV= 1 ZOSOP
*MCALL #=   182 LV= 1  ZOSOP '3F ','SUBTRACT UNNORMALIZED (short HFP) 'X
               ,'SUR ','RR C '
         JAS   R11,VER87
         USING *,R11
INS87    SUR  R1,R2
HEX87    DC    X'3F12'
NUM87    DC    P'87'
*MCALL #=   183 LV= 2 VER87    RT1   CCE,INS87,HEX87
VER87    DS    0H
         CLC   INS87,HEX87
RT1_TEST87       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE87
         LTORG 
RT1_CCE87       DS 0H
*MEXIT #=   183 LV= 2 RT1
*MEXIT #=   182 LV= 1 ZOSOP
*MCALL #=   184 LV= 1  ZOSOP '40 ','STORE HALFWORD ','STH ','RX '
         JAS   R11,VER88
         USING *,R11
INS88    STH  R1,S2(X4)
HEX88    DC    X'4014D002'
NUM88    DC    P'88'
*MCALL #=   185 LV= 2 VER88    RT1   CCE,INS88,HEX88
VER88    DS    0H
         CLC   INS88,HEX88
RT1_TEST88       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE88
         LTORG 
RT1_CCE88       DS 0H
*MEXIT #=   185 LV= 2 RT1
*MEXIT #=   184 LV= 1 ZOSOP
*MCALL #=   186 LV= 1  ZOSOP '41 ','LOAD ADDRESS ','LA ','RX '
         JAS   R11,VER89
         USING *,R11
INS89    LA   R1,S2(X4)
HEX89    DC    X'4114D002'
NUM89    DC    P'89'
*MCALL #=   187 LV= 2 VER89    RT1   CCE,INS89,HEX89
VER89    DS    0H
         CLC   INS89,HEX89
RT1_TEST89       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE89
         LTORG 
RT1_CCE89       DS 0H
*MEXIT #=   187 LV= 2 RT1
*MEXIT #=   186 LV= 1 ZOSOP
*MCALL #=   188 LV= 1  ZOSOP '42 ','STORE CHARACTER ','STC ','RX '
         JAS   R11,VER90
         USING *,R11
INS90    STC  R1,S2(X4)
HEX90    DC    X'4214D002'
NUM90    DC    P'90'
*MCALL #=   189 LV= 2 VER90    RT1   CCE,INS90,HEX90
VER90    DS    0H
         CLC   INS90,HEX90
RT1_TEST90       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE90
         LTORG 
RT1_CCE90       DS 0H
*MEXIT #=   189 LV= 2 RT1
*MEXIT #=   188 LV= 1 ZOSOP
*MCALL #=   190 LV= 1  ZOSOP '43 ','INSERT CHARACTER ','IC ','RX '
         JAS   R11,VER91
         USING *,R11
INS91    IC   R1,S2(X4)
HEX91    DC    X'4314D002'
NUM91    DC    P'91'
*MCALL #=   191 LV= 2 VER91    RT1   CCE,INS91,HEX91
VER91    DS    0H
         CLC   INS91,HEX91
RT1_TEST91       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE91
         LTORG 
RT1_CCE91       DS 0H
*MEXIT #=   191 LV= 2 RT1
*MEXIT #=   190 LV= 1 ZOSOP
*MCALL #=   192 LV= 1  ZOSOP '44 ','EXECUTE ','EX ','RX '
         JAS   R11,VER92
         USING *,R11
INS92    EX   R1,S2(X4)
HEX92    DC    X'4414D002'
NUM92    DC    P'92'
*MCALL #=   193 LV= 2 VER92    RT1   CCE,INS92,HEX92
VER92    DS    0H
         CLC   INS92,HEX92
RT1_TEST92       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE92
         LTORG 
RT1_CCE92       DS 0H
*MEXIT #=   193 LV= 2 RT1
*MEXIT #=   192 LV= 1 ZOSOP
*MCALL #=   194 LV= 1  ZOSOP '45 ','BRANCH AND LINK ','BAL ','RX '
         JAS   R11,VER93
         USING *,R11
INS93    BAL  R1,S2(X4)
HEX93    DC    X'4514D002'
NUM93    DC    P'93'
*MCALL #=   195 LV= 2 VER93    RT1   CCE,INS93,HEX93
VER93    DS    0H
         CLC   INS93,HEX93
RT1_TEST93       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE93
         LTORG 
RT1_CCE93       DS 0H
*MEXIT #=   195 LV= 2 RT1
*MEXIT #=   194 LV= 1 ZOSOP
*MCALL #=   196 LV= 1  ZOSOP '46 ','BRANCH ON COUNT (32) ','BCT ','RX '
         JAS   R11,VER94
         USING *,R11
INS94    BCT  R1,S2(X4)
HEX94    DC    X'4614D002'
NUM94    DC    P'94'
*MCALL #=   197 LV= 2 VER94    RT1   CCE,INS94,HEX94
VER94    DS    0H
         CLC   INS94,HEX94
RT1_TEST94       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE94
         LTORG 
RT1_CCE94       DS 0H
*MEXIT #=   197 LV= 2 RT1
*MEXIT #=   196 LV= 1 ZOSOP
*MCALL #=   198 LV= 1  ZOSOP '47 ','BRANCH ON CONDITION ','BC ','RX '
         JAS   R11,VER95
         USING *,R11
INS95    BC   R1,S2(X4)
HEX95    DC    X'4714D002'
NUM95    DC    P'95'
*MCALL #=   199 LV= 2 VER95    RT1   CCE,INS95,HEX95
VER95    DS    0H
         CLC   INS95,HEX95
RT1_TEST95       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE95
         LTORG 
RT1_CCE95       DS 0H
*MEXIT #=   199 LV= 2 RT1
*MEXIT #=   198 LV= 1 ZOSOP
*MCALL #=   200 LV= 1  ZOSOP '47F','EXTENDED BRANCH','B','BCX'
         JAS   R11,VER96
         USING *,R11
INS96    B     S2(X4)
HEX96    DC    X'47F4D002'
NUM96    DC    P'96'
*MCALL #=   201 LV= 2 VER96    RT1   CCE,INS96,HEX96
VER96    DS    0H
         CLC   INS96,HEX96
RT1_TEST96       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE96
         LTORG 
RT1_CCE96       DS 0H
*MEXIT #=   201 LV= 2 RT1
*MEXIT #=   200 LV= 1 ZOSOP
*MCALL #=   202 LV= 1  ZOSOP '470','EXTENDED BRANCH','NOP','BCX'
         JAS   R11,VER97
         USING *,R11
INS97    NOP   S2(X4)
HEX97    DC    X'4704D002'
NUM97    DC    P'97'
*MCALL #=   203 LV= 2 VER97    RT1   CCE,INS97,HEX97
VER97    DS    0H
         CLC   INS97,HEX97
RT1_TEST97       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE97
         LTORG 
RT1_CCE97       DS 0H
*MEXIT #=   203 LV= 2 RT1
*MEXIT #=   202 LV= 1 ZOSOP
*MCALL #=   204 LV= 1  ZOSOP '472','EXTENDED BRANCH','BH','BCX'
         JAS   R11,VER98
         USING *,R11
INS98    BH    S2(X4)
HEX98    DC    X'4724D002'
NUM98    DC    P'98'
*MCALL #=   205 LV= 2 VER98    RT1   CCE,INS98,HEX98
VER98    DS    0H
         CLC   INS98,HEX98
RT1_TEST98       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE98
         LTORG 
RT1_CCE98       DS 0H
*MEXIT #=   205 LV= 2 RT1
*MEXIT #=   204 LV= 1 ZOSOP
*MCALL #=   206 LV= 1  ZOSOP '474','EXTENDED BRANCH','BL','BCX'
         JAS   R11,VER99
         USING *,R11
INS99    BL    S2(X4)
HEX99    DC    X'4744D002'
NUM99    DC    P'99'
*MCALL #=   207 LV= 2 VER99    RT1   CCE,INS99,HEX99
VER99    DS    0H
         CLC   INS99,HEX99
RT1_TEST99       BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE99
         LTORG 
RT1_CCE99       DS 0H
*MEXIT #=   207 LV= 2 RT1
*MEXIT #=   206 LV= 1 ZOSOP
*MCALL #=   208 LV= 1  ZOSOP '478','EXTENDED BRANCH','BE','BCX'
         JAS   R11,VER100
         USING *,R11
INS100   BE    S2(X4)
HEX100   DC    X'4784D002'
NUM100   DC    P'100'
*MCALL #=   209 LV= 2 VER100   RT1   CCE,INS100,HEX100
VER100   DS    0H
         CLC   INS100,HEX100
RT1_TEST100      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE100
         LTORG 
RT1_CCE100      DS 0H
*MEXIT #=   209 LV= 2 RT1
*MEXIT #=   208 LV= 1 ZOSOP
*MCALL #=   210 LV= 1  ZOSOP '47D','EXTENDED BRANCH','BNH','BCX'
         JAS   R11,VER101
         USING *,R11
INS101   BNH   S2(X4)
HEX101   DC    X'47D4D002'
NUM101   DC    P'101'
*MCALL #=   211 LV= 2 VER101   RT1   CCE,INS101,HEX101
VER101   DS    0H
         CLC   INS101,HEX101
RT1_TEST101      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE101
         LTORG 
RT1_CCE101      DS 0H
*MEXIT #=   211 LV= 2 RT1
*MEXIT #=   210 LV= 1 ZOSOP
*MCALL #=   212 LV= 1  ZOSOP '47B','EXTENDED BRANCH','BNL','BCX'
         JAS   R11,VER102
         USING *,R11
INS102   BNL   S2(X4)
HEX102   DC    X'47B4D002'
NUM102   DC    P'102'
*MCALL #=   213 LV= 2 VER102   RT1   CCE,INS102,HEX102
VER102   DS    0H
         CLC   INS102,HEX102
RT1_TEST102      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE102
         LTORG 
RT1_CCE102      DS 0H
*MEXIT #=   213 LV= 2 RT1
*MEXIT #=   212 LV= 1 ZOSOP
*MCALL #=   214 LV= 1  ZOSOP '477','EXTENDED BRANCH','BNE','BCX'
         JAS   R11,VER103
         USING *,R11
INS103   BNE   S2(X4)
HEX103   DC    X'4774D002'
NUM103   DC    P'103'
*MCALL #=   215 LV= 2 VER103   RT1   CCE,INS103,HEX103
VER103   DS    0H
         CLC   INS103,HEX103
RT1_TEST103      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE103
         LTORG 
RT1_CCE103      DS 0H
*MEXIT #=   215 LV= 2 RT1
*MEXIT #=   214 LV= 1 ZOSOP
*MCALL #=   216 LV= 1  ZOSOP '472','EXTENDED BRANCH','BP','BCX'
         JAS   R11,VER104
         USING *,R11
INS104   BP    S2(X4)
HEX104   DC    X'4724D002'
NUM104   DC    P'104'
*MCALL #=   217 LV= 2 VER104   RT1   CCE,INS104,HEX104
VER104   DS    0H
         CLC   INS104,HEX104
RT1_TEST104      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE104
         LTORG 
RT1_CCE104      DS 0H
*MEXIT #=   217 LV= 2 RT1
*MEXIT #=   216 LV= 1 ZOSOP
*MCALL #=   218 LV= 1  ZOSOP '471','EXTENDED BRANCH','BO','BCX'
         JAS   R11,VER105
         USING *,R11
INS105   BO    S2(X4)
HEX105   DC    X'4714D002'
NUM105   DC    P'105'
*MCALL #=   219 LV= 2 VER105   RT1   CCE,INS105,HEX105
VER105   DS    0H
         CLC   INS105,HEX105
RT1_TEST105      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE105
         LTORG 
RT1_CCE105      DS 0H
*MEXIT #=   219 LV= 2 RT1
*MEXIT #=   218 LV= 1 ZOSOP
*MCALL #=   220 LV= 1  ZOSOP '474','EXTENDED BRANCH','BM','BCX'
         JAS   R11,VER106
         USING *,R11
INS106   BM    S2(X4)
HEX106   DC    X'4744D002'
NUM106   DC    P'106'
*MCALL #=   221 LV= 2 VER106   RT1   CCE,INS106,HEX106
VER106   DS    0H
         CLC   INS106,HEX106
RT1_TEST106      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE106
         LTORG 
RT1_CCE106      DS 0H
*MEXIT #=   221 LV= 2 RT1
*MEXIT #=   220 LV= 1 ZOSOP
*MCALL #=   222 LV= 1  ZOSOP '478','EXTENDED BRANCH','BZ','BCX'
         JAS   R11,VER107
         USING *,R11
INS107   BZ    S2(X4)
HEX107   DC    X'4784D002'
NUM107   DC    P'107'
*MCALL #=   223 LV= 2 VER107   RT1   CCE,INS107,HEX107
VER107   DS    0H
         CLC   INS107,HEX107
RT1_TEST107      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE107
         LTORG 
RT1_CCE107      DS 0H
*MEXIT #=   223 LV= 2 RT1
*MEXIT #=   222 LV= 1 ZOSOP
*MCALL #=   224 LV= 1  ZOSOP '47D','EXTENDED BRANCH','BNP','BCX'
         JAS   R11,VER108
         USING *,R11
INS108   BNP   S2(X4)
HEX108   DC    X'47D4D002'
NUM108   DC    P'108'
*MCALL #=   225 LV= 2 VER108   RT1   CCE,INS108,HEX108
VER108   DS    0H
         CLC   INS108,HEX108
RT1_TEST108      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE108
         LTORG 
RT1_CCE108      DS 0H
*MEXIT #=   225 LV= 2 RT1
*MEXIT #=   224 LV= 1 ZOSOP
*MCALL #=   226 LV= 1  ZOSOP '47B','EXTENDED BRANCH','BNM','BCX'
         JAS   R11,VER109
         USING *,R11
INS109   BNM   S2(X4)
HEX109   DC    X'47B4D002'
NUM109   DC    P'109'
*MCALL #=   227 LV= 2 VER109   RT1   CCE,INS109,HEX109
VER109   DS    0H
         CLC   INS109,HEX109
RT1_TEST109      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE109
         LTORG 
RT1_CCE109      DS 0H
*MEXIT #=   227 LV= 2 RT1
*MEXIT #=   226 LV= 1 ZOSOP
*MCALL #=   228 LV= 1  ZOSOP '477','EXTENDED BRANCH','BNZ','BCX'
         JAS   R11,VER110
         USING *,R11
INS110   BNZ   S2(X4)
HEX110   DC    X'4774D002'
NUM110   DC    P'110'
*MCALL #=   229 LV= 2 VER110   RT1   CCE,INS110,HEX110
VER110   DS    0H
         CLC   INS110,HEX110
RT1_TEST110      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE110
         LTORG 
RT1_CCE110      DS 0H
*MEXIT #=   229 LV= 2 RT1
*MEXIT #=   228 LV= 1 ZOSOP
*MCALL #=   230 LV= 1  ZOSOP '47E','EXTENDED BRANCH','BNO','BCX'
         JAS   R11,VER111
         USING *,R11
INS111   BNO   S2(X4)
HEX111   DC    X'47E4D002'
NUM111   DC    P'111'
*MCALL #=   231 LV= 2 VER111   RT1   CCE,INS111,HEX111
VER111   DS    0H
         CLC   INS111,HEX111
RT1_TEST111      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE111
         LTORG 
RT1_CCE111      DS 0H
*MEXIT #=   231 LV= 2 RT1
*MEXIT #=   230 LV= 1 ZOSOP
*MCALL #=   232 LV= 1  ZOSOP '48 ','LOAD HALFWORD (32) ','LH ','RX '
         JAS   R11,VER112
         USING *,R11
INS112   LH   R1,S2(X4)
HEX112   DC    X'4814D002'
NUM112   DC    P'112'
*MCALL #=   233 LV= 2 VER112   RT1   CCE,INS112,HEX112
VER112   DS    0H
         CLC   INS112,HEX112
RT1_TEST112      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE112
         LTORG 
RT1_CCE112      DS 0H
*MEXIT #=   233 LV= 2 RT1
*MEXIT #=   232 LV= 1 ZOSOP
*MCALL #=   234 LV= 1  ZOSOP '49 ','COMPARE HALFWORD ','CH ','RX C '
         JAS   R11,VER113
         USING *,R11
INS113   CH   R1,S2(X4)
HEX113   DC    X'4914D002'
NUM113   DC    P'113'
*MCALL #=   235 LV= 2 VER113   RT1   CCE,INS113,HEX113
VER113   DS    0H
         CLC   INS113,HEX113
RT1_TEST113      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE113
         LTORG 
RT1_CCE113      DS 0H
*MEXIT #=   235 LV= 2 RT1
*MEXIT #=   234 LV= 1 ZOSOP
*MCALL #=   236 LV= 1  ZOSOP '4A ','ADD HALFWORD ','AH ','RX C '
         JAS   R11,VER114
         USING *,R11
INS114   AH   R1,S2(X4)
HEX114   DC    X'4A14D002'
NUM114   DC    P'114'
*MCALL #=   237 LV= 2 VER114   RT1   CCE,INS114,HEX114
VER114   DS    0H
         CLC   INS114,HEX114
RT1_TEST114      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE114
         LTORG 
RT1_CCE114      DS 0H
*MEXIT #=   237 LV= 2 RT1
*MEXIT #=   236 LV= 1 ZOSOP
*MCALL #=   238 LV= 1  ZOSOP '4B ','SUBTRACT HALFWORD ','SH ','RX C '
         JAS   R11,VER115
         USING *,R11
INS115   SH   R1,S2(X4)
HEX115   DC    X'4B14D002'
NUM115   DC    P'115'
*MCALL #=   239 LV= 2 VER115   RT1   CCE,INS115,HEX115
VER115   DS    0H
         CLC   INS115,HEX115
RT1_TEST115      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE115
         LTORG 
RT1_CCE115      DS 0H
*MEXIT #=   239 LV= 2 RT1
*MEXIT #=   238 LV= 1 ZOSOP
*MCALL #=   240 LV= 1  ZOSOP '4C ','MULTIPLY HALFWORD (32) ','MH ','RX X
               '
         JAS   R11,VER116
         USING *,R11
INS116   MH   R1,S2(X4)
HEX116   DC    X'4C14D002'
NUM116   DC    P'116'
*MCALL #=   241 LV= 2 VER116   RT1   CCE,INS116,HEX116
VER116   DS    0H
         CLC   INS116,HEX116
RT1_TEST116      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE116
         LTORG 
RT1_CCE116      DS 0H
*MEXIT #=   241 LV= 2 RT1
*MEXIT #=   240 LV= 1 ZOSOP
*MCALL #=   242 LV= 1  ZOSOP '4D ','BRANCH AND SAVE ','BAS ','RX '
         JAS   R11,VER117
         USING *,R11
INS117   BAS  R1,S2(X4)
HEX117   DC    X'4D14D002'
NUM117   DC    P'117'
*MCALL #=   243 LV= 2 VER117   RT1   CCE,INS117,HEX117
VER117   DS    0H
         CLC   INS117,HEX117
RT1_TEST117      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE117
         LTORG 
RT1_CCE117      DS 0H
*MEXIT #=   243 LV= 2 RT1
*MEXIT #=   242 LV= 1 ZOSOP
*MCALL #=   244 LV= 1  ZOSOP '4E ','CONVERT TO DECIMAL (32) ','CVD ','RX
               X '
         JAS   R11,VER118
         USING *,R11
INS118   CVD  R1,S2(X4)
HEX118   DC    X'4E14D002'
NUM118   DC    P'118'
*MCALL #=   245 LV= 2 VER118   RT1   CCE,INS118,HEX118
VER118   DS    0H
         CLC   INS118,HEX118
RT1_TEST118      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE118
         LTORG 
RT1_CCE118      DS 0H
*MEXIT #=   245 LV= 2 RT1
*MEXIT #=   244 LV= 1 ZOSOP
*MCALL #=   246 LV= 1  ZOSOP '4F ','CONVERT TO BINARY (32) ','CVB ','RXX
                '
         JAS   R11,VER119
         USING *,R11
INS119   CVB  R1,S2(X4)
HEX119   DC    X'4F14D002'
NUM119   DC    P'119'
*MCALL #=   247 LV= 2 VER119   RT1   CCE,INS119,HEX119
VER119   DS    0H
         CLC   INS119,HEX119
RT1_TEST119      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE119
         LTORG 
RT1_CCE119      DS 0H
*MEXIT #=   247 LV= 2 RT1
*MEXIT #=   246 LV= 1 ZOSOP
*MCALL #=   248 LV= 1  ZOSOP '50 ','STORE (32) ','ST ','RX '
         JAS   R11,VER120
         USING *,R11
INS120   ST   R1,S2(X4)
HEX120   DC    X'5014D002'
NUM120   DC    P'120'
*MCALL #=   249 LV= 2 VER120   RT1   CCE,INS120,HEX120
VER120   DS    0H
         CLC   INS120,HEX120
RT1_TEST120      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE120
         LTORG 
RT1_CCE120      DS 0H
*MEXIT #=   249 LV= 2 RT1
*MEXIT #=   248 LV= 1 ZOSOP
*MCALL #=   250 LV= 1  ZOSOP '51 ','LOAD ADDRESS EXTENDED ','LAE ','RX X
               '
         JAS   R11,VER121
         USING *,R11
INS121   LAE  R1,S2(X4)
HEX121   DC    X'5114D002'
NUM121   DC    P'121'
*MCALL #=   251 LV= 2 VER121   RT1   CCE,INS121,HEX121
VER121   DS    0H
         CLC   INS121,HEX121
RT1_TEST121      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE121
         LTORG 
RT1_CCE121      DS 0H
*MEXIT #=   251 LV= 2 RT1
*MEXIT #=   250 LV= 1 ZOSOP
*MCALL #=   252 LV= 1  ZOSOP '52 ','ASSIST DECIMAL OUTPUT ','XDECO','RXX
               AS ' RPI-812
         JAS   R11,VER122
         USING *,R11
INS122   XDECO R1,S2(X4)
HEX122   DC    X'5214D002'
NUM122   DC    P'122'
*MCALL #=   253 LV= 2 VER122   RT1   CCE,INS122,HEX122
VER122   DS    0H
         CLC   INS122,HEX122
RT1_TEST122      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE122
         LTORG 
RT1_CCE122      DS 0H
*MEXIT #=   253 LV= 2 RT1
*MEXIT #=   252 LV= 1 ZOSOP
*MCALL #=   254 LV= 1  ZOSOP '53 ','ASSIST DECIMAL INPUT  ','XDECI','RXX
               AS ' RPI-812
         JAS   R11,VER123
         USING *,R11
INS123   XDECI R1,S2(X4)
HEX123   DC    X'5314D002'
NUM123   DC    P'123'
*MCALL #=   255 LV= 2 VER123   RT1   CCE,INS123,HEX123
VER123   DS    0H
         CLC   INS123,HEX123
RT1_TEST123      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE123
         LTORG 
RT1_CCE123      DS 0H
*MEXIT #=   255 LV= 2 RT1
*MEXIT #=   254 LV= 1 ZOSOP
*MCALL #=   256 LV= 1  ZOSOP '54 ','AND (32) ','N ','RX C '
         JAS   R11,VER124
         USING *,R11
INS124   N    R1,S2(X4)
HEX124   DC    X'5414D002'
NUM124   DC    P'124'
*MCALL #=   257 LV= 2 VER124   RT1   CCE,INS124,HEX124
VER124   DS    0H
         CLC   INS124,HEX124
RT1_TEST124      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE124
         LTORG 
RT1_CCE124      DS 0H
*MEXIT #=   257 LV= 2 RT1
*MEXIT #=   256 LV= 1 ZOSOP
*MCALL #=   258 LV= 1  ZOSOP '55 ','COMPARE LOGICAL (32) ','CL ','RX C X
               '
         JAS   R11,VER125
         USING *,R11
INS125   CL   R1,S2(X4)
HEX125   DC    X'5514D002'
NUM125   DC    P'125'
*MCALL #=   259 LV= 2 VER125   RT1   CCE,INS125,HEX125
VER125   DS    0H
         CLC   INS125,HEX125
RT1_TEST125      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE125
         LTORG 
RT1_CCE125      DS 0H
*MEXIT #=   259 LV= 2 RT1
*MEXIT #=   258 LV= 1 ZOSOP
*MCALL #=   260 LV= 1  ZOSOP '56 ','OR (32) ','O ','RX C '
         JAS   R11,VER126
         USING *,R11
INS126   O    R1,S2(X4)
HEX126   DC    X'5614D002'
NUM126   DC    P'126'
*MCALL #=   261 LV= 2 VER126   RT1   CCE,INS126,HEX126
VER126   DS    0H
         CLC   INS126,HEX126
RT1_TEST126      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE126
         LTORG 
RT1_CCE126      DS 0H
*MEXIT #=   261 LV= 2 RT1
*MEXIT #=   260 LV= 1 ZOSOP
*MCALL #=   262 LV= 1  ZOSOP '57 ','EXCLUSIVE OR (32) ','X ','RX C '
         JAS   R11,VER127
         USING *,R11
INS127   X    R1,S2(X4)
HEX127   DC    X'5714D002'
NUM127   DC    P'127'
*MCALL #=   263 LV= 2 VER127   RT1   CCE,INS127,HEX127
VER127   DS    0H
         CLC   INS127,HEX127
RT1_TEST127      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE127
         LTORG 
RT1_CCE127      DS 0H
*MEXIT #=   263 LV= 2 RT1
*MEXIT #=   262 LV= 1 ZOSOP
*MCALL #=   264 LV= 1  ZOSOP '58 ','LOAD (32) ','L ','RX '
         JAS   R11,VER128
         USING *,R11
INS128   L    R1,S2(X4)
HEX128   DC    X'5814D002'
NUM128   DC    P'128'
*MCALL #=   265 LV= 2 VER128   RT1   CCE,INS128,HEX128
VER128   DS    0H
         CLC   INS128,HEX128
RT1_TEST128      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE128
         LTORG 
RT1_CCE128      DS 0H
*MEXIT #=   265 LV= 2 RT1
*MEXIT #=   264 LV= 1 ZOSOP
*MCALL #=   266 LV= 1  ZOSOP '59 ','COMPARE (32) ','C ','RX C '
         JAS   R11,VER129
         USING *,R11
INS129   C    R1,S2(X4)
HEX129   DC    X'5914D002'
NUM129   DC    P'129'
*MCALL #=   267 LV= 2 VER129   RT1   CCE,INS129,HEX129
VER129   DS    0H
         CLC   INS129,HEX129
RT1_TEST129      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE129
         LTORG 
RT1_CCE129      DS 0H
*MEXIT #=   267 LV= 2 RT1
*MEXIT #=   266 LV= 1 ZOSOP
*MCALL #=   268 LV= 1  ZOSOP '5A ','ADD (32) ','A ','RX C '
         JAS   R11,VER130
         USING *,R11
INS130   A    R1,S2(X4)
HEX130   DC    X'5A14D002'
NUM130   DC    P'130'
*MCALL #=   269 LV= 2 VER130   RT1   CCE,INS130,HEX130
VER130   DS    0H
         CLC   INS130,HEX130
RT1_TEST130      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE130
         LTORG 
RT1_CCE130      DS 0H
*MEXIT #=   269 LV= 2 RT1
*MEXIT #=   268 LV= 1 ZOSOP
*MCALL #=   270 LV= 1  ZOSOP '5B ','SUBTRACT (32) ','S ','RX C '
         JAS   R11,VER131
         USING *,R11
INS131   S    R1,S2(X4)
HEX131   DC    X'5B14D002'
NUM131   DC    P'131'
*MCALL #=   271 LV= 2 VER131   RT1   CCE,INS131,HEX131
VER131   DS    0H
         CLC   INS131,HEX131
RT1_TEST131      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE131
         LTORG 
RT1_CCE131      DS 0H
*MEXIT #=   271 LV= 2 RT1
*MEXIT #=   270 LV= 1 ZOSOP
*MCALL #=   272 LV= 1  ZOSOP '5C ','MULTIPLY (64<32) ','M ','RX '
         JAS   R11,VER132
         USING *,R11
INS132   M    R1,S2(X4)
HEX132   DC    X'5C14D002'
NUM132   DC    P'132'
*MCALL #=   273 LV= 2 VER132   RT1   CCE,INS132,HEX132
VER132   DS    0H
         CLC   INS132,HEX132
RT1_TEST132      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE132
         LTORG 
RT1_CCE132      DS 0H
*MEXIT #=   273 LV= 2 RT1
*MEXIT #=   272 LV= 1 ZOSOP
*MCALL #=   274 LV= 1  ZOSOP '5D ','DIVIDE (32<64) ','D ','RX '
         JAS   R11,VER133
         USING *,R11
INS133   D    R1,S2(X4)
HEX133   DC    X'5D14D002'
NUM133   DC    P'133'
*MCALL #=   275 LV= 2 VER133   RT1   CCE,INS133,HEX133
VER133   DS    0H
         CLC   INS133,HEX133
RT1_TEST133      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE133
         LTORG 
RT1_CCE133      DS 0H
*MEXIT #=   275 LV= 2 RT1
*MEXIT #=   274 LV= 1 ZOSOP
*MCALL #=   276 LV= 1  ZOSOP '5E ','ADD LOGICAL (32) ','AL ','RX C '
         JAS   R11,VER134
         USING *,R11
INS134   AL   R1,S2(X4)
HEX134   DC    X'5E14D002'
NUM134   DC    P'134'
*MCALL #=   277 LV= 2 VER134   RT1   CCE,INS134,HEX134
VER134   DS    0H
         CLC   INS134,HEX134
RT1_TEST134      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE134
         LTORG 
RT1_CCE134      DS 0H
*MEXIT #=   277 LV= 2 RT1
*MEXIT #=   276 LV= 1 ZOSOP
*MCALL #=   278 LV= 1  ZOSOP '5F ','SUBTRACT LOGICAL (32) ','SL ','RX CX
                '
         JAS   R11,VER135
         USING *,R11
INS135   SL   R1,S2(X4)
HEX135   DC    X'5F14D002'
NUM135   DC    P'135'
*MCALL #=   279 LV= 2 VER135   RT1   CCE,INS135,HEX135
VER135   DS    0H
         CLC   INS135,HEX135
RT1_TEST135      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE135
         LTORG 
RT1_CCE135      DS 0H
*MEXIT #=   279 LV= 2 RT1
*MEXIT #=   278 LV= 1 ZOSOP
*MCALL #=   280 LV= 1  ZOSOP '60 ','STORE (long) ','STD ','RX '
         JAS   R11,VER136
         USING *,R11
INS136   STD  R1,S2(X4)
HEX136   DC    X'6014D002'
NUM136   DC    P'136'
*MCALL #=   281 LV= 2 VER136   RT1   CCE,INS136,HEX136
VER136   DS    0H
         CLC   INS136,HEX136
RT1_TEST136      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE136
         LTORG 
RT1_CCE136      DS 0H
*MEXIT #=   281 LV= 2 RT1
*MEXIT #=   280 LV= 1 ZOSOP
*MCALL #=   282 LV= 1  ZOSOP '61 ','ASSIST HEX INPUT  ','XHEXI','RXAS 'X
                RPI-812
         JAS   R11,VER137
         USING *,R11
INS137   XHEXI R1,S2(X4)
HEX137   DC    X'6114D002'
NUM137   DC    P'137'
*MCALL #=   283 LV= 2 VER137   RT1   CCE,INS137,HEX137
VER137   DS    0H
         CLC   INS137,HEX137
RT1_TEST137      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE137
         LTORG 
RT1_CCE137      DS 0H
*MEXIT #=   283 LV= 2 RT1
*MEXIT #=   282 LV= 1 ZOSOP
*MCALL #=   284 LV= 1  ZOSOP '62 ','ASSIST HEX OUTPUT ','XHEXO','RXAS 'X
                RPI-812
         JAS   R11,VER138
         USING *,R11
INS138   XHEXO R1,S2(X4)
HEX138   DC    X'6214D002'
NUM138   DC    P'138'
*MCALL #=   285 LV= 2 VER138   RT1   CCE,INS138,HEX138
VER138   DS    0H
         CLC   INS138,HEX138
RT1_TEST138      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE138
         LTORG 
RT1_CCE138      DS 0H
*MEXIT #=   285 LV= 2 RT1
*MEXIT #=   284 LV= 1 ZOSOP
*MCALL #=   286 LV= 1  ZOSOP '67 ','MULTIPLY (long to extended HFP) ','X
               MXD ','RX '
         JAS   R11,VER139
         USING *,R11
INS139   MXD  R1,S2(X4)
HEX139   DC    X'6714D002'
NUM139   DC    P'139'
*MCALL #=   287 LV= 2 VER139   RT1   CCE,INS139,HEX139
VER139   DS    0H
         CLC   INS139,HEX139
RT1_TEST139      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE139
         LTORG 
RT1_CCE139      DS 0H
*MEXIT #=   287 LV= 2 RT1
*MEXIT #=   286 LV= 1 ZOSOP
*MCALL #=   288 LV= 1  ZOSOP '68 ','LOAD (long) ','LD ','RX '
         JAS   R11,VER140
         USING *,R11
INS140   LD   R1,S2(X4)
HEX140   DC    X'6814D002'
NUM140   DC    P'140'
*MCALL #=   289 LV= 2 VER140   RT1   CCE,INS140,HEX140
VER140   DS    0H
         CLC   INS140,HEX140
RT1_TEST140      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE140
         LTORG 
RT1_CCE140      DS 0H
*MEXIT #=   289 LV= 2 RT1
*MEXIT #=   288 LV= 1 ZOSOP
*MCALL #=   290 LV= 1  ZOSOP '69 ','COMPARE (long HFP) ','CD ','RX C '
         JAS   R11,VER141
         USING *,R11
INS141   CD   R1,S2(X4)
HEX141   DC    X'6914D002'
NUM141   DC    P'141'
*MCALL #=   291 LV= 2 VER141   RT1   CCE,INS141,HEX141
VER141   DS    0H
         CLC   INS141,HEX141
RT1_TEST141      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE141
         LTORG 
RT1_CCE141      DS 0H
*MEXIT #=   291 LV= 2 RT1
*MEXIT #=   290 LV= 1 ZOSOP
*MCALL #=   292 LV= 1  ZOSOP '6A ','ADD NORMALIZED (long HFP) ','AD ','X
               RX C '
         JAS   R11,VER142
         USING *,R11
INS142   AD   R1,S2(X4)
HEX142   DC    X'6A14D002'
NUM142   DC    P'142'
*MCALL #=   293 LV= 2 VER142   RT1   CCE,INS142,HEX142
VER142   DS    0H
         CLC   INS142,HEX142
RT1_TEST142      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE142
         LTORG 
RT1_CCE142      DS 0H
*MEXIT #=   293 LV= 2 RT1
*MEXIT #=   292 LV= 1 ZOSOP
*MCALL #=   294 LV= 1  ZOSOP '6B ','SUBTRACT NORMALIZED (long HFP) ','SX
               D ','RX C '
         JAS   R11,VER143
         USING *,R11
INS143   SD   R1,S2(X4)
HEX143   DC    X'6B14D002'
NUM143   DC    P'143'
*MCALL #=   295 LV= 2 VER143   RT1   CCE,INS143,HEX143
VER143   DS    0H
         CLC   INS143,HEX143
RT1_TEST143      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE143
         LTORG 
RT1_CCE143      DS 0H
*MEXIT #=   295 LV= 2 RT1
*MEXIT #=   294 LV= 1 ZOSOP
*MCALL #=   296 LV= 1  ZOSOP '6C ','MULTIPLY (long HFP) ','MD ','RX '
         JAS   R11,VER144
         USING *,R11
INS144   MD   R1,S2(X4)
HEX144   DC    X'6C14D002'
NUM144   DC    P'144'
*MCALL #=   297 LV= 2 VER144   RT1   CCE,INS144,HEX144
VER144   DS    0H
         CLC   INS144,HEX144
RT1_TEST144      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE144
         LTORG 
RT1_CCE144      DS 0H
*MEXIT #=   297 LV= 2 RT1
*MEXIT #=   296 LV= 1 ZOSOP
*MCALL #=   298 LV= 1  ZOSOP '6D ','DIVIDE (long HFP) ','DD ','RX '
         JAS   R11,VER145
         USING *,R11
INS145   DD   R1,S2(X4)
HEX145   DC    X'6D14D002'
NUM145   DC    P'145'
*MCALL #=   299 LV= 2 VER145   RT1   CCE,INS145,HEX145
VER145   DS    0H
         CLC   INS145,HEX145
RT1_TEST145      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE145
         LTORG 
RT1_CCE145      DS 0H
*MEXIT #=   299 LV= 2 RT1
*MEXIT #=   298 LV= 1 ZOSOP
*MCALL #=   300 LV= 1  ZOSOP '6E ','ADD UNNORMALIZED (long HFP) ','AW 'X
               ,'RX C '
         JAS   R11,VER146
         USING *,R11
INS146   AW   R1,S2(X4)
HEX146   DC    X'6E14D002'
NUM146   DC    P'146'
*MCALL #=   301 LV= 2 VER146   RT1   CCE,INS146,HEX146
VER146   DS    0H
         CLC   INS146,HEX146
RT1_TEST146      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE146
         LTORG 
RT1_CCE146      DS 0H
*MEXIT #=   301 LV= 2 RT1
*MEXIT #=   300 LV= 1 ZOSOP
*MCALL #=   302 LV= 1  ZOSOP '6F ','SUBTRACT UNNORMALIZED (long HFP) ',X
               'SW ','RX C '
         JAS   R11,VER147
         USING *,R11
INS147   SW   R1,S2(X4)
HEX147   DC    X'6F14D002'
NUM147   DC    P'147'
*MCALL #=   303 LV= 2 VER147   RT1   CCE,INS147,HEX147
VER147   DS    0H
         CLC   INS147,HEX147
RT1_TEST147      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE147
         LTORG 
RT1_CCE147      DS 0H
*MEXIT #=   303 LV= 2 RT1
*MEXIT #=   302 LV= 1 ZOSOP
*MCALL #=   304 LV= 1  ZOSOP '70 ','STORE (short) ','STE ','RX '
         JAS   R11,VER148
         USING *,R11
INS148   STE  R1,S2(X4)
HEX148   DC    X'7014D002'
NUM148   DC    P'148'
*MCALL #=   305 LV= 2 VER148   RT1   CCE,INS148,HEX148
VER148   DS    0H
         CLC   INS148,HEX148
RT1_TEST148      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE148
         LTORG 
RT1_CCE148      DS 0H
*MEXIT #=   305 LV= 2 RT1
*MEXIT #=   304 LV= 1 ZOSOP
*MCALL #=   306 LV= 1  ZOSOP '71 ','MULTIPLY SINGLE (32) ','MS ','RX '
         JAS   R11,VER149
         USING *,R11
INS149   MS   R1,S2(X4)
HEX149   DC    X'7114D002'
NUM149   DC    P'149'
*MCALL #=   307 LV= 2 VER149   RT1   CCE,INS149,HEX149
VER149   DS    0H
         CLC   INS149,HEX149
RT1_TEST149      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE149
         LTORG 
RT1_CCE149      DS 0H
*MEXIT #=   307 LV= 2 RT1
*MEXIT #=   306 LV= 1 ZOSOP
*MCALL #=   308 LV= 1  ZOSOP '78 ','LOAD (short) ','LE ','RX '
         JAS   R11,VER150
         USING *,R11
INS150   LE   R1,S2(X4)
HEX150   DC    X'7814D002'
NUM150   DC    P'150'
*MCALL #=   309 LV= 2 VER150   RT1   CCE,INS150,HEX150
VER150   DS    0H
         CLC   INS150,HEX150
RT1_TEST150      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE150
         LTORG 
RT1_CCE150      DS 0H
*MEXIT #=   309 LV= 2 RT1
*MEXIT #=   308 LV= 1 ZOSOP
*MCALL #=   310 LV= 1  ZOSOP '79 ','COMPARE (short HFP) ','CE ','RX C '
         JAS   R11,VER151
         USING *,R11
INS151   CE   R1,S2(X4)
HEX151   DC    X'7914D002'
NUM151   DC    P'151'
*MCALL #=   311 LV= 2 VER151   RT1   CCE,INS151,HEX151
VER151   DS    0H
         CLC   INS151,HEX151
RT1_TEST151      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE151
         LTORG 
RT1_CCE151      DS 0H
*MEXIT #=   311 LV= 2 RT1
*MEXIT #=   310 LV= 1 ZOSOP
*MCALL #=   312 LV= 1  ZOSOP '7A ','ADD NORMALIZED (short HFP) ','AE ',X
               'RX C '
         JAS   R11,VER152
         USING *,R11
INS152   AE   R1,S2(X4)
HEX152   DC    X'7A14D002'
NUM152   DC    P'152'
*MCALL #=   313 LV= 2 VER152   RT1   CCE,INS152,HEX152
VER152   DS    0H
         CLC   INS152,HEX152
RT1_TEST152      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE152
         LTORG 
RT1_CCE152      DS 0H
*MEXIT #=   313 LV= 2 RT1
*MEXIT #=   312 LV= 1 ZOSOP
*MCALL #=   314 LV= 1  ZOSOP '7B ','SUBTRACT NORMALIZED (short HFP) ','X
               SE ','RX C '
         JAS   R11,VER153
         USING *,R11
INS153   SE   R1,S2(X4)
HEX153   DC    X'7B14D002'
NUM153   DC    P'153'
*MCALL #=   315 LV= 2 VER153   RT1   CCE,INS153,HEX153
VER153   DS    0H
         CLC   INS153,HEX153
RT1_TEST153      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE153
         LTORG 
RT1_CCE153      DS 0H
*MEXIT #=   315 LV= 2 RT1
*MEXIT #=   314 LV= 1 ZOSOP
*MCALL #=   316 LV= 1  ZOSOP '7C ','MULTIPLY (short to long HFP) ','MDEX
                ','RX '
         JAS   R11,VER154
         USING *,R11
INS154   MDE  R1,S2(X4)
HEX154   DC    X'7C14D002'
NUM154   DC    P'154'
*MCALL #=   317 LV= 2 VER154   RT1   CCE,INS154,HEX154
VER154   DS    0H
         CLC   INS154,HEX154
RT1_TEST154      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE154
         LTORG 
RT1_CCE154      DS 0H
*MEXIT #=   317 LV= 2 RT1
*MEXIT #=   316 LV= 1 ZOSOP
*MCALL #=   318 LV= 1  ZOSOP '7C ','MULTIPLY (short to long HFP) ','ME X
               ','RX '
         JAS   R11,VER155
         USING *,R11
INS155   ME   R1,S2(X4)
HEX155   DC    X'7C14D002'
NUM155   DC    P'155'
*MCALL #=   319 LV= 2 VER155   RT1   CCE,INS155,HEX155
VER155   DS    0H
         CLC   INS155,HEX155
RT1_TEST155      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE155
         LTORG 
RT1_CCE155      DS 0H
*MEXIT #=   319 LV= 2 RT1
*MEXIT #=   318 LV= 1 ZOSOP
*MCALL #=   320 LV= 1  ZOSOP '7D ','DIVIDE (short HFP) ','DE ','RX '
         JAS   R11,VER156
         USING *,R11
INS156   DE   R1,S2(X4)
HEX156   DC    X'7D14D002'
NUM156   DC    P'156'
*MCALL #=   321 LV= 2 VER156   RT1   CCE,INS156,HEX156
VER156   DS    0H
         CLC   INS156,HEX156
RT1_TEST156      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE156
         LTORG 
RT1_CCE156      DS 0H
*MEXIT #=   321 LV= 2 RT1
*MEXIT #=   320 LV= 1 ZOSOP
*MCALL #=   322 LV= 1  ZOSOP '7E ','ADD UNNORMALIZED (short HFP) ','AU X
               ','RX C '
         JAS   R11,VER157
         USING *,R11
INS157   AU   R1,S2(X4)
HEX157   DC    X'7E14D002'
NUM157   DC    P'157'
*MCALL #=   323 LV= 2 VER157   RT1   CCE,INS157,HEX157
VER157   DS    0H
         CLC   INS157,HEX157
RT1_TEST157      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE157
         LTORG 
RT1_CCE157      DS 0H
*MEXIT #=   323 LV= 2 RT1
*MEXIT #=   322 LV= 1 ZOSOP
*MCALL #=   324 LV= 1  ZOSOP '7F ','SUBTRACT UNNORMALIZED (short HFP) 'X
               ,'SU ','RX C '
         JAS   R11,VER158
         USING *,R11
INS158   SU   R1,S2(X4)
HEX158   DC    X'7F14D002'
NUM158   DC    P'158'
*MCALL #=   325 LV= 2 VER158   RT1   CCE,INS158,HEX158
VER158   DS    0H
         CLC   INS158,HEX158
RT1_TEST158      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE158
         LTORG 
RT1_CCE158      DS 0H
*MEXIT #=   325 LV= 2 RT1
*MEXIT #=   324 LV= 1 ZOSOP
*MCALL #=   326 LV= 1  ZOSOP '8000','SET SYSTEM MASK ','SSM ','S '
         JAS   R11,VER159
         USING *,R11
INS159   SSM   S1
HEX159   DC    X'8000D001'
NUM159   DC    P'159'
*MCALL #=   327 LV= 2 VER159   RT1   CCE,INS159,HEX159
VER159   DS    0H
         CLC   INS159,HEX159
RT1_TEST159      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE159
         LTORG 
RT1_CCE159      DS 0H
*MEXIT #=   327 LV= 2 RT1
*MEXIT #=   326 LV= 1 ZOSOP
*MCALL #=   328 LV= 1  ZOSOP '8200','LOAD PSW ','LPSW ','S L '
         JAS   R11,VER160
         USING *,R11
INS160   LPSW  S1
HEX160   DC    X'8200D001'
NUM160   DC    P'160'
*MCALL #=   329 LV= 2 VER160   RT1   CCE,INS160,HEX160
VER160   DS    0H
         CLC   INS160,HEX160
RT1_TEST160      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE160
         LTORG 
RT1_CCE160      DS 0H
*MEXIT #=   329 LV= 2 RT1
*MEXIT #=   328 LV= 1 ZOSOP
*MCALL #=   330 LV= 1  ZOSOP '83 ','DIAGNOSE ','DIAGNOSE','DM'
         JAS   R11,VER161
         USING *,R11
INS161   DIAGNOSE 
HEX161   DC    X'83000000'
NUM161   DC    P'161'
*MCALL #=   331 LV= 2 VER161   RT1   CCE,INS161,HEX161
VER161   DS    0H
         CLC   INS161,HEX161
RT1_TEST161      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE161
         LTORG 
RT1_CCE161      DS 0H
*MEXIT #=   331 LV= 2 RT1
*MEXIT #=   330 LV= 1 ZOSOP
*MCALL #=   332 LV= 1  ZOSOP '84 ','BRANCH RELATIVE ON INDEX HIGH (32) X
               ','BRXH ','RSI '
         JAS   R11,VER162
         USING *,R11
INS162   BRXH  R1,R2,*-2
HEX162   DC    X'8412FFFF'
NUM162   DC    P'162'
*MCALL #=   333 LV= 2 VER162   RT1   CCE,INS162,HEX162
VER162   DS    0H
         CLC   INS162,HEX162
RT1_TEST162      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE162
         LTORG 
RT1_CCE162      DS 0H
*MEXIT #=   333 LV= 2 RT1
*MEXIT #=   332 LV= 1 ZOSOP
*MCALL #=   334 LV= 1  ZOSOP '84','RELATIVE BRANCH','JXH','RSI'
         JAS   R11,VER163
         USING *,R11
INS163   JXH  R1,R2,*-2
HEX163   DC    X'8412FFFF'
NUM163   DC    P'163'
*MCALL #=   335 LV= 2 VER163   RT1   CCE,INS163,HEX163
VER163   DS    0H
         CLC   INS163,HEX163
RT1_TEST163      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE163
         LTORG 
RT1_CCE163      DS 0H
*MEXIT #=   335 LV= 2 RT1
*MEXIT #=   334 LV= 1 ZOSOP
*MCALL #=   336 LV= 1  ZOSOP '85 ','BRANCH RELATIVE ON INDEX L OR E (32X
               )','BRXLE','RSI '
         JAS   R11,VER164
         USING *,R11
INS164   BRXLE R1,R2,*-2
HEX164   DC    X'8512FFFF'
NUM164   DC    P'164'
*MCALL #=   337 LV= 2 VER164   RT1   CCE,INS164,HEX164
VER164   DS    0H
         CLC   INS164,HEX164
RT1_TEST164      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE164
         LTORG 
RT1_CCE164      DS 0H
*MEXIT #=   337 LV= 2 RT1
*MEXIT #=   336 LV= 1 ZOSOP
*MCALL #=   338 LV= 1  ZOSOP '85','RELATIVE BRANCH','JXLE','RSI'
         JAS   R11,VER165
         USING *,R11
INS165   JXLE R1,R2,*-2
HEX165   DC    X'8512FFFF'
NUM165   DC    P'165'
*MCALL #=   339 LV= 2 VER165   RT1   CCE,INS165,HEX165
VER165   DS    0H
         CLC   INS165,HEX165
RT1_TEST165      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE165
         LTORG 
RT1_CCE165      DS 0H
*MEXIT #=   339 LV= 2 RT1
*MEXIT #=   338 LV= 1 ZOSOP
*MCALL #=   340 LV= 1  ZOSOP '86 ','BRANCH ON INDEX HIGH (32) ','BXH ',X
               'RS '
         JAS   R11,VER166
         USING *,R11
INS166   BXH  R1,R3,S2
HEX166   DC    X'8613D002'
NUM166   DC    P'166'
*MCALL #=   341 LV= 2 VER166   RT1   CCE,INS166,HEX166
VER166   DS    0H
         CLC   INS166,HEX166
RT1_TEST166      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE166
         LTORG 
RT1_CCE166      DS 0H
*MEXIT #=   341 LV= 2 RT1
*MEXIT #=   340 LV= 1 ZOSOP
*MCALL #=   342 LV= 1  ZOSOP '87 ','BRANCH ON INDEX LOW OR EQUAL (32) 'X
               ,'BXLE ','RS '
         JAS   R11,VER167
         USING *,R11
INS167   BXLE  R1,R3,S2
HEX167   DC    X'8713D002'
NUM167   DC    P'167'
*MCALL #=   343 LV= 2 VER167   RT1   CCE,INS167,HEX167
VER167   DS    0H
         CLC   INS167,HEX167
RT1_TEST167      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE167
         LTORG 
RT1_CCE167      DS 0H
*MEXIT #=   343 LV= 2 RT1
*MEXIT #=   342 LV= 1 ZOSOP
*MCALL #=   344 LV= 1  ZOSOP '88 ','SHIFT RIGHT SINGLE LOGICAL (32) ','X
               SRL ','RS2 '
         JAS   R11,VER168
         USING *,R11
INS168   SRL  R1,S2
HEX168   DC    X'8810D002'
NUM168   DC    P'168'
*MCALL #=   345 LV= 2 VER168   RT1   CCE,INS168,HEX168
VER168   DS    0H
         CLC   INS168,HEX168
RT1_TEST168      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE168
         LTORG 
RT1_CCE168      DS 0H
*MEXIT #=   345 LV= 2 RT1
*MEXIT #=   344 LV= 1 ZOSOP
*MCALL #=   346 LV= 1  ZOSOP '89 ','SHIFT LEFT SINGLE LOGICAL (32) ','SX
               LL ','RS2 '
         JAS   R11,VER169
         USING *,R11
INS169   SLL  R1,S2
HEX169   DC    X'8910D002'
NUM169   DC    P'169'
*MCALL #=   347 LV= 2 VER169   RT1   CCE,INS169,HEX169
VER169   DS    0H
         CLC   INS169,HEX169
RT1_TEST169      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE169
         LTORG 
RT1_CCE169      DS 0H
*MEXIT #=   347 LV= 2 RT1
*MEXIT #=   346 LV= 1 ZOSOP
*MCALL #=   348 LV= 1  ZOSOP '8A ','SHIFT RIGHT SINGLE (32) ','SRA ','RX
               S2 C '
         JAS   R11,VER170
         USING *,R11
INS170   SRA  R1,S2
HEX170   DC    X'8A10D002'
NUM170   DC    P'170'
*MCALL #=   349 LV= 2 VER170   RT1   CCE,INS170,HEX170
VER170   DS    0H
         CLC   INS170,HEX170
RT1_TEST170      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE170
         LTORG 
RT1_CCE170      DS 0H
*MEXIT #=   349 LV= 2 RT1
*MEXIT #=   348 LV= 1 ZOSOP
*MCALL #=   350 LV= 1  ZOSOP '8B ','SHIFT LEFT SINGLE (32) ','SLA ','RSX
               2 C '
         JAS   R11,VER171
         USING *,R11
INS171   SLA  R1,S2
HEX171   DC    X'8B10D002'
NUM171   DC    P'171'
*MCALL #=   351 LV= 2 VER171   RT1   CCE,INS171,HEX171
VER171   DS    0H
         CLC   INS171,HEX171
RT1_TEST171      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE171
         LTORG 
RT1_CCE171      DS 0H
*MEXIT #=   351 LV= 2 RT1
*MEXIT #=   350 LV= 1 ZOSOP
*MCALL #=   352 LV= 1  ZOSOP '8C ','SHIFT RIGHT DOUBLE LOGICAL ','SRDL X
               ','RS2 '
         JAS   R11,VER172
         USING *,R11
INS172   SRDL  R1,S2
HEX172   DC    X'8C10D002'
NUM172   DC    P'172'
*MCALL #=   353 LV= 2 VER172   RT1   CCE,INS172,HEX172
VER172   DS    0H
         CLC   INS172,HEX172
RT1_TEST172      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE172
         LTORG 
RT1_CCE172      DS 0H
*MEXIT #=   353 LV= 2 RT1
*MEXIT #=   352 LV= 1 ZOSOP
*MCALL #=   354 LV= 1  ZOSOP '8D ','SHIFT LEFT DOUBLE LOGICAL ','SLDL 'X
               ,'RS2 '
         JAS   R11,VER173
         USING *,R11
INS173   SLDL  R1,S2
HEX173   DC    X'8D10D002'
NUM173   DC    P'173'
*MCALL #=   355 LV= 2 VER173   RT1   CCE,INS173,HEX173
VER173   DS    0H
         CLC   INS173,HEX173
RT1_TEST173      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE173
         LTORG 
RT1_CCE173      DS 0H
*MEXIT #=   355 LV= 2 RT1
*MEXIT #=   354 LV= 1 ZOSOP
*MCALL #=   356 LV= 1  ZOSOP '8E ','SHIFT RIGHT DOUBLE ','SRDA ','RS2 CX
                '
         JAS   R11,VER174
         USING *,R11
INS174   SRDA  R1,S2
HEX174   DC    X'8E10D002'
NUM174   DC    P'174'
*MCALL #=   357 LV= 2 VER174   RT1   CCE,INS174,HEX174
VER174   DS    0H
         CLC   INS174,HEX174
RT1_TEST174      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE174
         LTORG 
RT1_CCE174      DS 0H
*MEXIT #=   357 LV= 2 RT1
*MEXIT #=   356 LV= 1 ZOSOP
*MCALL #=   358 LV= 1  ZOSOP '8F ','SHIFT LEFT DOUBLE ','SLDA ','RS2 C X
               '
         JAS   R11,VER175
         USING *,R11
INS175   SLDA  R1,S2
HEX175   DC    X'8F10D002'
NUM175   DC    P'175'
*MCALL #=   359 LV= 2 VER175   RT1   CCE,INS175,HEX175
VER175   DS    0H
         CLC   INS175,HEX175
RT1_TEST175      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE175
         LTORG 
RT1_CCE175      DS 0H
*MEXIT #=   359 LV= 2 RT1
*MEXIT #=   358 LV= 1 ZOSOP
*MCALL #=   360 LV= 1  ZOSOP '90 ','STORE MULTIPLE (32) ','STM ','RS '
         JAS   R11,VER176
         USING *,R11
INS176   STM  R1,R3,S2
HEX176   DC    X'9013D002'
NUM176   DC    P'176'
*MCALL #=   361 LV= 2 VER176   RT1   CCE,INS176,HEX176
VER176   DS    0H
         CLC   INS176,HEX176
RT1_TEST176      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE176
         LTORG 
RT1_CCE176      DS 0H
*MEXIT #=   361 LV= 2 RT1
*MEXIT #=   360 LV= 1 ZOSOP
*MCALL #=   362 LV= 1  ZOSOP '91 ','TEST UNDER MASK ','TM ','SI C '
         JAS   R11,VER177
         USING *,R11
INS177   TM   S1,II
HEX177   DC    X'91FFD001'
NUM177   DC    P'177'
*MCALL #=   363 LV= 2 VER177   RT1   CCE,INS177,HEX177
VER177   DS    0H
         CLC   INS177,HEX177
RT1_TEST177      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE177
         LTORG 
RT1_CCE177      DS 0H
*MEXIT #=   363 LV= 2 RT1
*MEXIT #=   362 LV= 1 ZOSOP
*MCALL #=   364 LV= 1  ZOSOP '92 ','MOVE (immediate) ','MVI ','SI '
         JAS   R11,VER178
         USING *,R11
INS178   MVI  S1,II
HEX178   DC    X'92FFD001'
NUM178   DC    P'178'
*MCALL #=   365 LV= 2 VER178   RT1   CCE,INS178,HEX178
VER178   DS    0H
         CLC   INS178,HEX178
RT1_TEST178      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE178
         LTORG 
RT1_CCE178      DS 0H
*MEXIT #=   365 LV= 2 RT1
*MEXIT #=   364 LV= 1 ZOSOP
*MCALL #=   366 LV= 1  ZOSOP '9300','TEST AND SET ','TS ','S C '
         JAS   R11,VER179
         USING *,R11
INS179   TS    S1
HEX179   DC    X'9300D001'
NUM179   DC    P'179'
*MCALL #=   367 LV= 2 VER179   RT1   CCE,INS179,HEX179
VER179   DS    0H
         CLC   INS179,HEX179
RT1_TEST179      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE179
         LTORG 
RT1_CCE179      DS 0H
*MEXIT #=   367 LV= 2 RT1
*MEXIT #=   366 LV= 1 ZOSOP
*MCALL #=   368 LV= 1  ZOSOP '94 ','AND (immediate) ','NI ','SI C '
         JAS   R11,VER180
         USING *,R11
INS180   NI   S1,II
HEX180   DC    X'94FFD001'
NUM180   DC    P'180'
*MCALL #=   369 LV= 2 VER180   RT1   CCE,INS180,HEX180
VER180   DS    0H
         CLC   INS180,HEX180
RT1_TEST180      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE180
         LTORG 
RT1_CCE180      DS 0H
*MEXIT #=   369 LV= 2 RT1
*MEXIT #=   368 LV= 1 ZOSOP
*MCALL #=   370 LV= 1  ZOSOP '95 ','COMPARE LOGICAL (immediate) ','CLI X
               ','SI C '
         JAS   R11,VER181
         USING *,R11
INS181   CLI  S1,II
HEX181   DC    X'95FFD001'
NUM181   DC    P'181'
*MCALL #=   371 LV= 2 VER181   RT1   CCE,INS181,HEX181
VER181   DS    0H
         CLC   INS181,HEX181
RT1_TEST181      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE181
         LTORG 
RT1_CCE181      DS 0H
*MEXIT #=   371 LV= 2 RT1
*MEXIT #=   370 LV= 1 ZOSOP
*MCALL #=   372 LV= 1  ZOSOP '96 ','OR (immediate) ','OI ','SI C '
         JAS   R11,VER182
         USING *,R11
INS182   OI   S1,II
HEX182   DC    X'96FFD001'
NUM182   DC    P'182'
*MCALL #=   373 LV= 2 VER182   RT1   CCE,INS182,HEX182
VER182   DS    0H
         CLC   INS182,HEX182
RT1_TEST182      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE182
         LTORG 
RT1_CCE182      DS 0H
*MEXIT #=   373 LV= 2 RT1
*MEXIT #=   372 LV= 1 ZOSOP
*MCALL #=   374 LV= 1  ZOSOP '97 ','EXCLUSIVE OR (immediate) ','XI ','SX
               I C '
         JAS   R11,VER183
         USING *,R11
INS183   XI   S1,II
HEX183   DC    X'97FFD001'
NUM183   DC    P'183'
*MCALL #=   375 LV= 2 VER183   RT1   CCE,INS183,HEX183
VER183   DS    0H
         CLC   INS183,HEX183
RT1_TEST183      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE183
         LTORG 
RT1_CCE183      DS 0H
*MEXIT #=   375 LV= 2 RT1
*MEXIT #=   374 LV= 1 ZOSOP
*MCALL #=   376 LV= 1  ZOSOP '98 ','LOAD MULTIPLE (32) ','LM ','RS '
         JAS   R11,VER184
         USING *,R11
INS184   LM   R1,R3,S2
HEX184   DC    X'9813D002'
NUM184   DC    P'184'
*MCALL #=   377 LV= 2 VER184   RT1   CCE,INS184,HEX184
VER184   DS    0H
         CLC   INS184,HEX184
RT1_TEST184      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE184
         LTORG 
RT1_CCE184      DS 0H
*MEXIT #=   377 LV= 2 RT1
*MEXIT #=   376 LV= 1 ZOSOP
*MCALL #=   378 LV= 1  ZOSOP '99 ','TRACE (32) ','TRACE','RS '
         JAS   R11,VER185
         USING *,R11
INS185   TRACE R1,R3,S2
HEX185   DC    X'9913D002'
NUM185   DC    P'185'
*MCALL #=   379 LV= 2 VER185   RT1   CCE,INS185,HEX185
VER185   DS    0H
         CLC   INS185,HEX185
RT1_TEST185      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE185
         LTORG 
RT1_CCE185      DS 0H
*MEXIT #=   379 LV= 2 RT1
*MEXIT #=   378 LV= 1 ZOSOP
*MCALL #=   380 LV= 1  ZOSOP '9A ','LOAD ACCESS MULTIPLE ','LAM ','RS '
         JAS   R11,VER186
         USING *,R11
INS186   LAM  R1,R3,S2
HEX186   DC    X'9A13D002'
NUM186   DC    P'186'
*MCALL #=   381 LV= 2 VER186   RT1   CCE,INS186,HEX186
VER186   DS    0H
         CLC   INS186,HEX186
RT1_TEST186      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE186
         LTORG 
RT1_CCE186      DS 0H
*MEXIT #=   381 LV= 2 RT1
*MEXIT #=   380 LV= 1 ZOSOP
*MCALL #=   382 LV= 1  ZOSOP '9B ','STORE ACCESS MULTIPLE ','STAM ','RSX
                '
         JAS   R11,VER187
         USING *,R11
INS187   STAM  R1,R3,S2
HEX187   DC    X'9B13D002'
NUM187   DC    P'187'
*MCALL #=   383 LV= 2 VER187   RT1   CCE,INS187,HEX187
VER187   DS    0H
         CLC   INS187,HEX187
RT1_TEST187      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE187
         LTORG 
RT1_CCE187      DS 0H
*MEXIT #=   383 LV= 2 RT1
*MEXIT #=   382 LV= 1 ZOSOP
*MCALL #=   384 LV= 1  ZOSOP 'A50 ','INSERT IMMEDIATE (high high) ','IIX
               HH ','RI N '
         JAS   R11,VER188
         USING *,R11
INS188   IIHH  R1,*-2
HEX188   DC    X'A510FFFF'
NUM188   DC    P'188'
*MCALL #=   385 LV= 2 VER188   RT1   CCE,INS188,HEX188
VER188   DS    0H
         CLC   INS188,HEX188
RT1_TEST188      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE188
         LTORG 
RT1_CCE188      DS 0H
*MEXIT #=   385 LV= 2 RT1
*MEXIT #=   384 LV= 1 ZOSOP
*MCALL #=   386 LV= 1  ZOSOP 'A51 ','INSERT IMMEDIATE (high low) ','IIHX
               L ','RI N '
         JAS   R11,VER189
         USING *,R11
INS189   IIHL  R1,*-2
HEX189   DC    X'A511FFFF'
NUM189   DC    P'189'
*MCALL #=   387 LV= 2 VER189   RT1   CCE,INS189,HEX189
VER189   DS    0H
         CLC   INS189,HEX189
RT1_TEST189      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE189
         LTORG 
RT1_CCE189      DS 0H
*MEXIT #=   387 LV= 2 RT1
*MEXIT #=   386 LV= 1 ZOSOP
*MCALL #=   388 LV= 1  ZOSOP 'A52 ','INSERT IMMEDIATE (low high) ','IILX
               H ','RI N '
         JAS   R11,VER190
         USING *,R11
INS190   IILH  R1,*-2
HEX190   DC    X'A512FFFF'
NUM190   DC    P'190'
*MCALL #=   389 LV= 2 VER190   RT1   CCE,INS190,HEX190
VER190   DS    0H
         CLC   INS190,HEX190
RT1_TEST190      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE190
         LTORG 
RT1_CCE190      DS 0H
*MEXIT #=   389 LV= 2 RT1
*MEXIT #=   388 LV= 1 ZOSOP
*MCALL #=   390 LV= 1  ZOSOP 'A53 ','INSERT IMMEDIATE (low low) ','IILLX
                ','RI N '
         JAS   R11,VER191
         USING *,R11
INS191   IILL  R1,*-2
HEX191   DC    X'A513FFFF'
NUM191   DC    P'191'
*MCALL #=   391 LV= 2 VER191   RT1   CCE,INS191,HEX191
VER191   DS    0H
         CLC   INS191,HEX191
RT1_TEST191      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE191
         LTORG 
RT1_CCE191      DS 0H
*MEXIT #=   391 LV= 2 RT1
*MEXIT #=   390 LV= 1 ZOSOP
*MCALL #=   392 LV= 1  ZOSOP 'A54 ','AND IMMEDIATE (high high) ','NIHH X
               ','RI C N '
         JAS   R11,VER192
         USING *,R11
INS192   NIHH  R1,*-2
HEX192   DC    X'A514FFFF'
NUM192   DC    P'192'
*MCALL #=   393 LV= 2 VER192   RT1   CCE,INS192,HEX192
VER192   DS    0H
         CLC   INS192,HEX192
RT1_TEST192      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE192
         LTORG 
RT1_CCE192      DS 0H
*MEXIT #=   393 LV= 2 RT1
*MEXIT #=   392 LV= 1 ZOSOP
*MCALL #=   394 LV= 1  ZOSOP 'A55 ','AND IMMEDIATE (high low) ','NIHL 'X
               ,'RI C N '
         JAS   R11,VER193
         USING *,R11
INS193   NIHL  R1,*-2
HEX193   DC    X'A515FFFF'
NUM193   DC    P'193'
*MCALL #=   395 LV= 2 VER193   RT1   CCE,INS193,HEX193
VER193   DS    0H
         CLC   INS193,HEX193
RT1_TEST193      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE193
         LTORG 
RT1_CCE193      DS 0H
*MEXIT #=   395 LV= 2 RT1
*MEXIT #=   394 LV= 1 ZOSOP
*MCALL #=   396 LV= 1  ZOSOP 'A56 ','AND IMMEDIATE (low high) ','NILH 'X
               ,'RI C N '
         JAS   R11,VER194
         USING *,R11
INS194   NILH  R1,*-2
HEX194   DC    X'A516FFFF'
NUM194   DC    P'194'
*MCALL #=   397 LV= 2 VER194   RT1   CCE,INS194,HEX194
VER194   DS    0H
         CLC   INS194,HEX194
RT1_TEST194      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE194
         LTORG 
RT1_CCE194      DS 0H
*MEXIT #=   397 LV= 2 RT1
*MEXIT #=   396 LV= 1 ZOSOP
*MCALL #=   398 LV= 1  ZOSOP 'A57 ','AND IMMEDIATE (low low) ','NILL ',X
               'RI C N '
         JAS   R11,VER195
         USING *,R11
INS195   NILL  R1,*-2
HEX195   DC    X'A517FFFF'
NUM195   DC    P'195'
*MCALL #=   399 LV= 2 VER195   RT1   CCE,INS195,HEX195
VER195   DS    0H
         CLC   INS195,HEX195
RT1_TEST195      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE195
         LTORG 
RT1_CCE195      DS 0H
*MEXIT #=   399 LV= 2 RT1
*MEXIT #=   398 LV= 1 ZOSOP
*MCALL #=   400 LV= 1  ZOSOP 'A58 ','OR IMMEDIATE (high high) ','OIHH 'X
               ,'RI C N '
         JAS   R11,VER196
         USING *,R11
INS196   OIHH  R1,*-2
HEX196   DC    X'A518FFFF'
NUM196   DC    P'196'
*MCALL #=   401 LV= 2 VER196   RT1   CCE,INS196,HEX196
VER196   DS    0H
         CLC   INS196,HEX196
RT1_TEST196      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE196
         LTORG 
RT1_CCE196      DS 0H
*MEXIT #=   401 LV= 2 RT1
*MEXIT #=   400 LV= 1 ZOSOP
*MCALL #=   402 LV= 1  ZOSOP 'A59 ','OR IMMEDIATE (high low) ','OIHL ',X
               'RI C N '
         JAS   R11,VER197
         USING *,R11
INS197   OIHL  R1,*-2
HEX197   DC    X'A519FFFF'
NUM197   DC    P'197'
*MCALL #=   403 LV= 2 VER197   RT1   CCE,INS197,HEX197
VER197   DS    0H
         CLC   INS197,HEX197
RT1_TEST197      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE197
         LTORG 
RT1_CCE197      DS 0H
*MEXIT #=   403 LV= 2 RT1
*MEXIT #=   402 LV= 1 ZOSOP
*MCALL #=   404 LV= 1  ZOSOP 'A5A ','OR IMMEDIATE (low high) ','OILH ',X
               'RI C N '
         JAS   R11,VER198
         USING *,R11
INS198   OILH  R1,*-2
HEX198   DC    X'A51AFFFF'
NUM198   DC    P'198'
*MCALL #=   405 LV= 2 VER198   RT1   CCE,INS198,HEX198
VER198   DS    0H
         CLC   INS198,HEX198
RT1_TEST198      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE198
         LTORG 
RT1_CCE198      DS 0H
*MEXIT #=   405 LV= 2 RT1
*MEXIT #=   404 LV= 1 ZOSOP
*MCALL #=   406 LV= 1  ZOSOP 'A5B ','OR IMMEDIATE (low low) ','OILL ','X
               RI C N '
         JAS   R11,VER199
         USING *,R11
INS199   OILL  R1,*-2
HEX199   DC    X'A51BFFFF'
NUM199   DC    P'199'
*MCALL #=   407 LV= 2 VER199   RT1   CCE,INS199,HEX199
VER199   DS    0H
         CLC   INS199,HEX199
RT1_TEST199      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE199
         LTORG 
RT1_CCE199      DS 0H
*MEXIT #=   407 LV= 2 RT1
*MEXIT #=   406 LV= 1 ZOSOP
*MCALL #=   408 LV= 1  ZOSOP 'A5C ','LOAD LOGICAL IMMEDIATE (high high)X
                ','LLIHH','RI N '
         JAS   R11,VER200
         USING *,R11
INS200   LLIHH R1,*-2
HEX200   DC    X'A51CFFFF'
NUM200   DC    P'200'
*MCALL #=   409 LV= 2 VER200   RT1   CCE,INS200,HEX200
VER200   DS    0H
         CLC   INS200,HEX200
RT1_TEST200      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE200
         LTORG 
RT1_CCE200      DS 0H
*MEXIT #=   409 LV= 2 RT1
*MEXIT #=   408 LV= 1 ZOSOP
*MCALL #=   410 LV= 1  ZOSOP 'A5D ','LOAD LOGICAL IMMEDIATE (high low) X
               ','LLIHL','RI N '
         JAS   R11,VER201
         USING *,R11
INS201   LLIHL R1,*-2
HEX201   DC    X'A51DFFFF'
NUM201   DC    P'201'
*MCALL #=   411 LV= 2 VER201   RT1   CCE,INS201,HEX201
VER201   DS    0H
         CLC   INS201,HEX201
RT1_TEST201      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE201
         LTORG 
RT1_CCE201      DS 0H
*MEXIT #=   411 LV= 2 RT1
*MEXIT #=   410 LV= 1 ZOSOP
*MCALL #=   412 LV= 1  ZOSOP 'A5E ','LOAD LOGICAL IMMEDIATE (low high) X
               ','LLILH','RI N '
         JAS   R11,VER202
         USING *,R11
INS202   LLILH R1,*-2
HEX202   DC    X'A51EFFFF'
NUM202   DC    P'202'
*MCALL #=   413 LV= 2 VER202   RT1   CCE,INS202,HEX202
VER202   DS    0H
         CLC   INS202,HEX202
RT1_TEST202      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE202
         LTORG 
RT1_CCE202      DS 0H
*MEXIT #=   413 LV= 2 RT1
*MEXIT #=   412 LV= 1 ZOSOP
*MCALL #=   414 LV= 1  ZOSOP 'A5F ','LOAD LOGICAL IMMEDIATE (low low) 'X
               ,'LLILL','RI N '
         JAS   R11,VER203
         USING *,R11
INS203   LLILL R1,*-2
HEX203   DC    X'A51FFFFF'
NUM203   DC    P'203'
*MCALL #=   415 LV= 2 VER203   RT1   CCE,INS203,HEX203
VER203   DS    0H
         CLC   INS203,HEX203
RT1_TEST203      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE203
         LTORG 
RT1_CCE203      DS 0H
*MEXIT #=   415 LV= 2 RT1
*MEXIT #=   414 LV= 1 ZOSOP
*MCALL #=   416 LV= 1  ZOSOP 'A70 ','TEST UNDER MASK (low high) ','TMLHX
                ','RI C N '
         JAS   R11,VER204
         USING *,R11
INS204   TMLH  R1,*-2
HEX204   DC    X'A710FFFF'
NUM204   DC    P'204'
*MCALL #=   417 LV= 2 VER204   RT1   CCE,INS204,HEX204
VER204   DS    0H
         CLC   INS204,HEX204
RT1_TEST204      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE204
         LTORG 
RT1_CCE204      DS 0H
*MEXIT #=   417 LV= 2 RT1
*MEXIT #=   416 LV= 1 ZOSOP
*MCALL #=   418 LV= 1  ZOSOP 'A70 ','TEST UNDER MASK HIGH ','TMH ','RI X
               C '
         JAS   R11,VER205
         USING *,R11
INS205   TMH  R1,*-2
HEX205   DC    X'A710FFFF'
NUM205   DC    P'205'
*MCALL #=   419 LV= 2 VER205   RT1   CCE,INS205,HEX205
VER205   DS    0H
         CLC   INS205,HEX205
RT1_TEST205      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE205
         LTORG 
RT1_CCE205      DS 0H
*MEXIT #=   419 LV= 2 RT1
*MEXIT #=   418 LV= 1 ZOSOP
*MCALL #=   420 LV= 1  ZOSOP 'A71 ','TEST UNDER MASK (low low) ','TMLL X
               ','RI C N '
         JAS   R11,VER206
         USING *,R11
INS206   TMLL  R1,*-2
HEX206   DC    X'A711FFFF'
NUM206   DC    P'206'
*MCALL #=   421 LV= 2 VER206   RT1   CCE,INS206,HEX206
VER206   DS    0H
         CLC   INS206,HEX206
RT1_TEST206      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE206
         LTORG 
RT1_CCE206      DS 0H
*MEXIT #=   421 LV= 2 RT1
*MEXIT #=   420 LV= 1 ZOSOP
*MCALL #=   422 LV= 1  ZOSOP 'A71 ','TEST UNDER MASK LOW ','TML ','RI CX
                '
         JAS   R11,VER207
         USING *,R11
INS207   TML  R1,*-2
HEX207   DC    X'A711FFFF'
NUM207   DC    P'207'
*MCALL #=   423 LV= 2 VER207   RT1   CCE,INS207,HEX207
VER207   DS    0H
         CLC   INS207,HEX207
RT1_TEST207      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE207
         LTORG 
RT1_CCE207      DS 0H
*MEXIT #=   423 LV= 2 RT1
*MEXIT #=   422 LV= 1 ZOSOP
*MCALL #=   424 LV= 1  ZOSOP 'A72 ','TEST UNDER MASK (high high) ','TMHX
               H ','RI C N '
         JAS   R11,VER208
         USING *,R11
INS208   TMHH  R1,*-2
HEX208   DC    X'A712FFFF'
NUM208   DC    P'208'
*MCALL #=   425 LV= 2 VER208   RT1   CCE,INS208,HEX208
VER208   DS    0H
         CLC   INS208,HEX208
RT1_TEST208      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE208
         LTORG 
RT1_CCE208      DS 0H
*MEXIT #=   425 LV= 2 RT1
*MEXIT #=   424 LV= 1 ZOSOP
*MCALL #=   426 LV= 1  ZOSOP 'A73 ','TEST UNDER MASK (high low) ','TMHLX
                ','RI C N '
         JAS   R11,VER209
         USING *,R11
INS209   TMHL  R1,*-2
HEX209   DC    X'A713FFFF'
NUM209   DC    P'209'
*MCALL #=   427 LV= 2 VER209   RT1   CCE,INS209,HEX209
VER209   DS    0H
         CLC   INS209,HEX209
RT1_TEST209      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE209
         LTORG 
RT1_CCE209      DS 0H
*MEXIT #=   427 LV= 2 RT1
*MEXIT #=   426 LV= 1 ZOSOP
*MCALL #=   428 LV= 1  ZOSOP 'A74','BRANCH RELATIVE ON CONDITION ','BRCX
                ','RI '
         JAS   R11,VER210
         USING *,R11
INS210   BRC  R1,*-2
HEX210   DC    X'A714FFFF'
NUM210   DC    P'210'
*MCALL #=   429 LV= 2 VER210   RT1   CCE,INS210,HEX210
VER210   DS    0H
         CLC   INS210,HEX210
RT1_TEST210      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE210
         LTORG 
RT1_CCE210      DS 0H
*MEXIT #=   429 LV= 2 RT1
*MEXIT #=   428 LV= 1 ZOSOP
*MCALL #=   430 LV= 1  ZOSOP 'A74F','RELATIVE BRANCH','J','BRC'
         JAS   R11,VER211
         USING *,R11
INS211   J    *-2
HEX211   DC    X'A7F4FFFF'
NUM211   DC    P'211'
*MCALL #=   431 LV= 2 VER211   RT1   CCE,INS211,HEX211
VER211   DS    0H
         CLC   INS211,HEX211
RT1_TEST211      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE211
         LTORG 
RT1_CCE211      DS 0H
*MEXIT #=   431 LV= 2 RT1
*MEXIT #=   430 LV= 1 ZOSOP
*MCALL #=   432 LV= 1  ZOSOP 'A740','RELATIVE BRANCH','JNOP','BRC'
         JAS   R11,VER212
         USING *,R11
INS212   JNOP *-2
HEX212   DC    X'A704FFFF'
NUM212   DC    P'212'
*MCALL #=   433 LV= 2 VER212   RT1   CCE,INS212,HEX212
VER212   DS    0H
         CLC   INS212,HEX212
RT1_TEST212      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE212
         LTORG 
RT1_CCE212      DS 0H
*MEXIT #=   433 LV= 2 RT1
*MEXIT #=   432 LV= 1 ZOSOP
*MCALL #=   434 LV= 1  ZOSOP 'A74F','RELATIVE BRANCH','BRU','BRC'
         JAS   R11,VER213
         USING *,R11
INS213   BRU  *-2
HEX213   DC    X'A7F4FFFF'
NUM213   DC    P'213'
*MCALL #=   435 LV= 2 VER213   RT1   CCE,INS213,HEX213
VER213   DS    0H
         CLC   INS213,HEX213
RT1_TEST213      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE213
         LTORG 
RT1_CCE213      DS 0H
*MEXIT #=   435 LV= 2 RT1
*MEXIT #=   434 LV= 1 ZOSOP
*MCALL #=   436 LV= 1  ZOSOP 'A742','RELATIVE BRANCH','BRH','BRC'
         JAS   R11,VER214
         USING *,R11
INS214   BRH  *-2
HEX214   DC    X'A724FFFF'
NUM214   DC    P'214'
*MCALL #=   437 LV= 2 VER214   RT1   CCE,INS214,HEX214
VER214   DS    0H
         CLC   INS214,HEX214
RT1_TEST214      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE214
         LTORG 
RT1_CCE214      DS 0H
*MEXIT #=   437 LV= 2 RT1
*MEXIT #=   436 LV= 1 ZOSOP
*MCALL #=   438 LV= 1  ZOSOP 'A744','RELATIVE BRANCH','BRL','BRC'
         JAS   R11,VER215
         USING *,R11
INS215   BRL  *-2
HEX215   DC    X'A744FFFF'
NUM215   DC    P'215'
*MCALL #=   439 LV= 2 VER215   RT1   CCE,INS215,HEX215
VER215   DS    0H
         CLC   INS215,HEX215
RT1_TEST215      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE215
         LTORG 
RT1_CCE215      DS 0H
*MEXIT #=   439 LV= 2 RT1
*MEXIT #=   438 LV= 1 ZOSOP
*MCALL #=   440 LV= 1  ZOSOP 'A748','RELATIVE BRANCH','BRE','BRC'
         JAS   R11,VER216
         USING *,R11
INS216   BRE  *-2
HEX216   DC    X'A784FFFF'
NUM216   DC    P'216'
*MCALL #=   441 LV= 2 VER216   RT1   CCE,INS216,HEX216
VER216   DS    0H
         CLC   INS216,HEX216
RT1_TEST216      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE216
         LTORG 
RT1_CCE216      DS 0H
*MEXIT #=   441 LV= 2 RT1
*MEXIT #=   440 LV= 1 ZOSOP
*MCALL #=   442 LV= 1  ZOSOP 'A74D','RELATIVE BRANCH','BRNH','BRC'
         JAS   R11,VER217
         USING *,R11
INS217   BRNH *-2
HEX217   DC    X'A7D4FFFF'
NUM217   DC    P'217'
*MCALL #=   443 LV= 2 VER217   RT1   CCE,INS217,HEX217
VER217   DS    0H
         CLC   INS217,HEX217
RT1_TEST217      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE217
         LTORG 
RT1_CCE217      DS 0H
*MEXIT #=   443 LV= 2 RT1
*MEXIT #=   442 LV= 1 ZOSOP
*MCALL #=   444 LV= 1  ZOSOP 'A74B','RELATIVE BRANCH','BRNL','BRC'
         JAS   R11,VER218
         USING *,R11
INS218   BRNL *-2
HEX218   DC    X'A7B4FFFF'
NUM218   DC    P'218'
*MCALL #=   445 LV= 2 VER218   RT1   CCE,INS218,HEX218
VER218   DS    0H
         CLC   INS218,HEX218
RT1_TEST218      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE218
         LTORG 
RT1_CCE218      DS 0H
*MEXIT #=   445 LV= 2 RT1
*MEXIT #=   444 LV= 1 ZOSOP
*MCALL #=   446 LV= 1  ZOSOP 'A747','RELATIVE BRANCH','BRNE','BRC'
         JAS   R11,VER219
         USING *,R11
INS219   BRNE *-2
HEX219   DC    X'A774FFFF'
NUM219   DC    P'219'
*MCALL #=   447 LV= 2 VER219   RT1   CCE,INS219,HEX219
VER219   DS    0H
         CLC   INS219,HEX219
RT1_TEST219      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE219
         LTORG 
RT1_CCE219      DS 0H
*MEXIT #=   447 LV= 2 RT1
*MEXIT #=   446 LV= 1 ZOSOP
*MCALL #=   448 LV= 1  ZOSOP 'A742','RELATIVE BRANCH','BRP','BRC'
         JAS   R11,VER220
         USING *,R11
INS220   BRP  *-2
HEX220   DC    X'A724FFFF'
NUM220   DC    P'220'
*MCALL #=   449 LV= 2 VER220   RT1   CCE,INS220,HEX220
VER220   DS    0H
         CLC   INS220,HEX220
RT1_TEST220      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE220
         LTORG 
RT1_CCE220      DS 0H
*MEXIT #=   449 LV= 2 RT1
*MEXIT #=   448 LV= 1 ZOSOP
*MCALL #=   450 LV= 1  ZOSOP 'A744','RELATIVE BRANCH','BRM','BRC'
         JAS   R11,VER221
         USING *,R11
INS221   BRM  *-2
HEX221   DC    X'A744FFFF'
NUM221   DC    P'221'
*MCALL #=   451 LV= 2 VER221   RT1   CCE,INS221,HEX221
VER221   DS    0H
         CLC   INS221,HEX221
RT1_TEST221      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE221
         LTORG 
RT1_CCE221      DS 0H
*MEXIT #=   451 LV= 2 RT1
*MEXIT #=   450 LV= 1 ZOSOP
*MCALL #=   452 LV= 1  ZOSOP 'A748','RELATIVE BRANCH','BRZ','BRC'
         JAS   R11,VER222
         USING *,R11
INS222   BRZ  *-2
HEX222   DC    X'A784FFFF'
NUM222   DC    P'222'
*MCALL #=   453 LV= 2 VER222   RT1   CCE,INS222,HEX222
VER222   DS    0H
         CLC   INS222,HEX222
RT1_TEST222      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE222
         LTORG 
RT1_CCE222      DS 0H
*MEXIT #=   453 LV= 2 RT1
*MEXIT #=   452 LV= 1 ZOSOP
*MCALL #=   454 LV= 1  ZOSOP 'A741','RELATIVE BRANCH','BRO','BRC'
         JAS   R11,VER223
         USING *,R11
INS223   BRO  *-2
HEX223   DC    X'A714FFFF'
NUM223   DC    P'223'
*MCALL #=   455 LV= 2 VER223   RT1   CCE,INS223,HEX223
VER223   DS    0H
         CLC   INS223,HEX223
RT1_TEST223      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE223
         LTORG 
RT1_CCE223      DS 0H
*MEXIT #=   455 LV= 2 RT1
*MEXIT #=   454 LV= 1 ZOSOP
*MCALL #=   456 LV= 1  ZOSOP 'A74D','RELATIVE BRANCH','BRNP','BRC'
         JAS   R11,VER224
         USING *,R11
INS224   BRNP *-2
HEX224   DC    X'A7D4FFFF'
NUM224   DC    P'224'
*MCALL #=   457 LV= 2 VER224   RT1   CCE,INS224,HEX224
VER224   DS    0H
         CLC   INS224,HEX224
RT1_TEST224      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE224
         LTORG 
RT1_CCE224      DS 0H
*MEXIT #=   457 LV= 2 RT1
*MEXIT #=   456 LV= 1 ZOSOP
*MCALL #=   458 LV= 1  ZOSOP 'A74B','RELATIVE BRANCH','BRNM','BRC'
         JAS   R11,VER225
         USING *,R11
INS225   BRNM *-2
HEX225   DC    X'A7B4FFFF'
NUM225   DC    P'225'
*MCALL #=   459 LV= 2 VER225   RT1   CCE,INS225,HEX225
VER225   DS    0H
         CLC   INS225,HEX225
RT1_TEST225      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE225
         LTORG 
RT1_CCE225      DS 0H
*MEXIT #=   459 LV= 2 RT1
*MEXIT #=   458 LV= 1 ZOSOP
*MCALL #=   460 LV= 1  ZOSOP 'A747','RELATIVE BRANCH','BRNZ','BRC'
         JAS   R11,VER226
         USING *,R11
INS226   BRNZ *-2
HEX226   DC    X'A774FFFF'
NUM226   DC    P'226'
*MCALL #=   461 LV= 2 VER226   RT1   CCE,INS226,HEX226
VER226   DS    0H
         CLC   INS226,HEX226
RT1_TEST226      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE226
         LTORG 
RT1_CCE226      DS 0H
*MEXIT #=   461 LV= 2 RT1
*MEXIT #=   460 LV= 1 ZOSOP
*MCALL #=   462 LV= 1  ZOSOP 'A74E','RELATIVE BRANCH','BRNO','BRC'
         JAS   R11,VER227
         USING *,R11
INS227   BRNO *-2
HEX227   DC    X'A7E4FFFF'
NUM227   DC    P'227'
*MCALL #=   463 LV= 2 VER227   RT1   CCE,INS227,HEX227
VER227   DS    0H
         CLC   INS227,HEX227
RT1_TEST227      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE227
         LTORG 
RT1_CCE227      DS 0H
*MEXIT #=   463 LV= 2 RT1
*MEXIT #=   462 LV= 1 ZOSOP
*MCALL #=   464 LV= 1  ZOSOP 'A742','RELATIVE BRANCH','JH','BRC'
         JAS   R11,VER228
         USING *,R11
INS228   JH   *-2
HEX228   DC    X'A724FFFF'
NUM228   DC    P'228'
*MCALL #=   465 LV= 2 VER228   RT1   CCE,INS228,HEX228
VER228   DS    0H
         CLC   INS228,HEX228
RT1_TEST228      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE228
         LTORG 
RT1_CCE228      DS 0H
*MEXIT #=   465 LV= 2 RT1
*MEXIT #=   464 LV= 1 ZOSOP
*MCALL #=   466 LV= 1  ZOSOP 'A744','RELATIVE BRANCH','JL','BRC'
         JAS   R11,VER229
         USING *,R11
INS229   JL   *-2
HEX229   DC    X'A744FFFF'
NUM229   DC    P'229'
*MCALL #=   467 LV= 2 VER229   RT1   CCE,INS229,HEX229
VER229   DS    0H
         CLC   INS229,HEX229
RT1_TEST229      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE229
         LTORG 
RT1_CCE229      DS 0H
*MEXIT #=   467 LV= 2 RT1
*MEXIT #=   466 LV= 1 ZOSOP
*MCALL #=   468 LV= 1  ZOSOP 'A748','RELATIVE BRANCH','JE','BRC'
         JAS   R11,VER230
         USING *,R11
INS230   JE   *-2
HEX230   DC    X'A784FFFF'
NUM230   DC    P'230'
*MCALL #=   469 LV= 2 VER230   RT1   CCE,INS230,HEX230
VER230   DS    0H
         CLC   INS230,HEX230
RT1_TEST230      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE230
         LTORG 
RT1_CCE230      DS 0H
*MEXIT #=   469 LV= 2 RT1
*MEXIT #=   468 LV= 1 ZOSOP
*MCALL #=   470 LV= 1  ZOSOP 'A74D','RELATIVE BRANCH','JNH','BRC'
         JAS   R11,VER231
         USING *,R11
INS231   JNH  *-2
HEX231   DC    X'A7D4FFFF'
NUM231   DC    P'231'
*MCALL #=   471 LV= 2 VER231   RT1   CCE,INS231,HEX231
VER231   DS    0H
         CLC   INS231,HEX231
RT1_TEST231      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE231
         LTORG 
RT1_CCE231      DS 0H
*MEXIT #=   471 LV= 2 RT1
*MEXIT #=   470 LV= 1 ZOSOP
*MCALL #=   472 LV= 1  ZOSOP 'A74B','RELATIVE BRANCH','JNL','BRC'
         JAS   R11,VER232
         USING *,R11
INS232   JNL  *-2
HEX232   DC    X'A7B4FFFF'
NUM232   DC    P'232'
*MCALL #=   473 LV= 2 VER232   RT1   CCE,INS232,HEX232
VER232   DS    0H
         CLC   INS232,HEX232
RT1_TEST232      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE232
         LTORG 
RT1_CCE232      DS 0H
*MEXIT #=   473 LV= 2 RT1
*MEXIT #=   472 LV= 1 ZOSOP
*MCALL #=   474 LV= 1  ZOSOP 'A747','RELATIVE BRANCH','JNE','BRC'
         JAS   R11,VER233
         USING *,R11
INS233   JNE  *-2
HEX233   DC    X'A774FFFF'
NUM233   DC    P'233'
*MCALL #=   475 LV= 2 VER233   RT1   CCE,INS233,HEX233
VER233   DS    0H
         CLC   INS233,HEX233
RT1_TEST233      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE233
         LTORG 
RT1_CCE233      DS 0H
*MEXIT #=   475 LV= 2 RT1
*MEXIT #=   474 LV= 1 ZOSOP
*MCALL #=   476 LV= 1  ZOSOP 'A742','RELATIVE BRANCH','JP','BRC'
         JAS   R11,VER234
         USING *,R11
INS234   JP   *-2
HEX234   DC    X'A724FFFF'
NUM234   DC    P'234'
*MCALL #=   477 LV= 2 VER234   RT1   CCE,INS234,HEX234
VER234   DS    0H
         CLC   INS234,HEX234
RT1_TEST234      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE234
         LTORG 
RT1_CCE234      DS 0H
*MEXIT #=   477 LV= 2 RT1
*MEXIT #=   476 LV= 1 ZOSOP
*MCALL #=   478 LV= 1  ZOSOP 'A744','RELATIVE BRANCH','JM','BRC'
         JAS   R11,VER235
         USING *,R11
INS235   JM   *-2
HEX235   DC    X'A744FFFF'
NUM235   DC    P'235'
*MCALL #=   479 LV= 2 VER235   RT1   CCE,INS235,HEX235
VER235   DS    0H
         CLC   INS235,HEX235
RT1_TEST235      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE235
         LTORG 
RT1_CCE235      DS 0H
*MEXIT #=   479 LV= 2 RT1
*MEXIT #=   478 LV= 1 ZOSOP
*MCALL #=   480 LV= 1  ZOSOP 'A748','RELATIVE BRANCH','JZ','BRC'
         JAS   R11,VER236
         USING *,R11
INS236   JZ   *-2
HEX236   DC    X'A784FFFF'
NUM236   DC    P'236'
*MCALL #=   481 LV= 2 VER236   RT1   CCE,INS236,HEX236
VER236   DS    0H
         CLC   INS236,HEX236
RT1_TEST236      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE236
         LTORG 
RT1_CCE236      DS 0H
*MEXIT #=   481 LV= 2 RT1
*MEXIT #=   480 LV= 1 ZOSOP
*MCALL #=   482 LV= 1  ZOSOP 'A741','RELATIVE BRANCH','JO','BRC'
         JAS   R11,VER237
         USING *,R11
INS237   JO   *-2
HEX237   DC    X'A714FFFF'
NUM237   DC    P'237'
*MCALL #=   483 LV= 2 VER237   RT1   CCE,INS237,HEX237
VER237   DS    0H
         CLC   INS237,HEX237
RT1_TEST237      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE237
         LTORG 
RT1_CCE237      DS 0H
*MEXIT #=   483 LV= 2 RT1
*MEXIT #=   482 LV= 1 ZOSOP
*MCALL #=   484 LV= 1  ZOSOP 'A74D','RELATIVE BRANCH','JNP','BRC'
         JAS   R11,VER238
         USING *,R11
INS238   JNP  *-2
HEX238   DC    X'A7D4FFFF'
NUM238   DC    P'238'
*MCALL #=   485 LV= 2 VER238   RT1   CCE,INS238,HEX238
VER238   DS    0H
         CLC   INS238,HEX238
RT1_TEST238      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE238
         LTORG 
RT1_CCE238      DS 0H
*MEXIT #=   485 LV= 2 RT1
*MEXIT #=   484 LV= 1 ZOSOP
*MCALL #=   486 LV= 1  ZOSOP 'A74B','RELATIVE BRANCH','JNM','BRC'
         JAS   R11,VER239
         USING *,R11
INS239   JNM  *-2
HEX239   DC    X'A7B4FFFF'
NUM239   DC    P'239'
*MCALL #=   487 LV= 2 VER239   RT1   CCE,INS239,HEX239
VER239   DS    0H
         CLC   INS239,HEX239
RT1_TEST239      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE239
         LTORG 
RT1_CCE239      DS 0H
*MEXIT #=   487 LV= 2 RT1
*MEXIT #=   486 LV= 1 ZOSOP
*MCALL #=   488 LV= 1  ZOSOP 'A747','RELATIVE BRANCH','JNZ','BRC'
         JAS   R11,VER240
         USING *,R11
INS240   JNZ  *-2
HEX240   DC    X'A774FFFF'
NUM240   DC    P'240'
*MCALL #=   489 LV= 2 VER240   RT1   CCE,INS240,HEX240
VER240   DS    0H
         CLC   INS240,HEX240
RT1_TEST240      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE240
         LTORG 
RT1_CCE240      DS 0H
*MEXIT #=   489 LV= 2 RT1
*MEXIT #=   488 LV= 1 ZOSOP
*MCALL #=   490 LV= 1  ZOSOP 'A74E','RELATIVE BRANCH','JNO','BRC'
         JAS   R11,VER241
         USING *,R11
INS241   JNO  *-2
HEX241   DC    X'A7E4FFFF'
NUM241   DC    P'241'
*MCALL #=   491 LV= 2 VER241   RT1   CCE,INS241,HEX241
VER241   DS    0H
         CLC   INS241,HEX241
RT1_TEST241      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE241
         LTORG 
RT1_CCE241      DS 0H
*MEXIT #=   491 LV= 2 RT1
*MEXIT #=   490 LV= 1 ZOSOP
*MCALL #=   492 LV= 1  ZOSOP 'A75 ','BRANCH RELATIVE AND SAVE ','BRAS 'X
               ,'RI '
         JAS   R11,VER242
         USING *,R11
INS242   BRAS  R1,*-2
HEX242   DC    X'A715FFFF'
NUM242   DC    P'242'
*MCALL #=   493 LV= 2 VER242   RT1   CCE,INS242,HEX242
VER242   DS    0H
         CLC   INS242,HEX242
RT1_TEST242      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE242
         LTORG 
RT1_CCE242      DS 0H
*MEXIT #=   493 LV= 2 RT1
*MEXIT #=   492 LV= 1 ZOSOP
*MCALL #=   494 LV= 1  ZOSOP 'A75','RELATIVE BRANCH AND SAVE','JAS','RIX
               '
         JAS   R11,VER243
         USING *,R11
INS243   JAS  R1,*-2
HEX243   DC    X'A715FFFF'
NUM243   DC    P'243'
*MCALL #=   495 LV= 2 VER243   RT1   CCE,INS243,HEX243
VER243   DS    0H
         CLC   INS243,HEX243
RT1_TEST243      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE243
         LTORG 
RT1_CCE243      DS 0H
*MEXIT #=   495 LV= 2 RT1
*MEXIT #=   494 LV= 1 ZOSOP
*MCALL #=   496 LV= 1  ZOSOP 'A76 ','BRANCH RELATIVE ON COUNT (32) ','BX
               RCT ','RI '
         JAS   R11,VER244
         USING *,R11
INS244   BRCT  R1,*-2
HEX244   DC    X'A716FFFF'
NUM244   DC    P'244'
*MCALL #=   497 LV= 2 VER244   RT1   CCE,INS244,HEX244
VER244   DS    0H
         CLC   INS244,HEX244
RT1_TEST244      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE244
         LTORG 
RT1_CCE244      DS 0H
*MEXIT #=   497 LV= 2 RT1
*MEXIT #=   496 LV= 1 ZOSOP
*MCALL #=   498 LV= 1  ZOSOP 'A76','RELATIVE BRANCH','JCT','RI'
         JAS   R11,VER245
         USING *,R11
INS245   JCT  R1,*-2
HEX245   DC    X'A716FFFF'
NUM245   DC    P'245'
*MCALL #=   499 LV= 2 VER245   RT1   CCE,INS245,HEX245
VER245   DS    0H
         CLC   INS245,HEX245
RT1_TEST245      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE245
         LTORG 
RT1_CCE245      DS 0H
*MEXIT #=   499 LV= 2 RT1
*MEXIT #=   498 LV= 1 ZOSOP
*MCALL #=   500 LV= 1  ZOSOP 'A77 ','BRANCH RELATIVE ON COUNT (64) ','BX
               RCTG','RI N '
         JAS   R11,VER246
         USING *,R11
INS246   BRCTG R1,*-2
HEX246   DC    X'A717FFFF'
NUM246   DC    P'246'
*MCALL #=   501 LV= 2 VER246   RT1   CCE,INS246,HEX246
VER246   DS    0H
         CLC   INS246,HEX246
RT1_TEST246      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE246
         LTORG 
RT1_CCE246      DS 0H
*MEXIT #=   501 LV= 2 RT1
*MEXIT #=   500 LV= 1 ZOSOP
*MCALL #=   502 LV= 1  ZOSOP 'A77','RELATIVE BRANCH','JCTG','RI'
         JAS   R11,VER247
         USING *,R11
INS247   JCTG R1,*-2
HEX247   DC    X'A717FFFF'
NUM247   DC    P'247'
*MCALL #=   503 LV= 2 VER247   RT1   CCE,INS247,HEX247
VER247   DS    0H
         CLC   INS247,HEX247
RT1_TEST247      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE247
         LTORG 
RT1_CCE247      DS 0H
*MEXIT #=   503 LV= 2 RT1
*MEXIT #=   502 LV= 1 ZOSOP
*MCALL #=   504 LV= 1  ZOSOP 'A78 ','LOAD HALFWORD IMMEDIATE (32) ','LHX
               I ','RI '
         JAS   R11,VER248
         USING *,R11
INS248   LHI  R1,*-2
HEX248   DC    X'A718FFFF'
NUM248   DC    P'248'
*MCALL #=   505 LV= 2 VER248   RT1   CCE,INS248,HEX248
VER248   DS    0H
         CLC   INS248,HEX248
RT1_TEST248      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE248
         LTORG 
RT1_CCE248      DS 0H
*MEXIT #=   505 LV= 2 RT1
*MEXIT #=   504 LV= 1 ZOSOP
*MCALL #=   506 LV= 1  ZOSOP 'A79 ','LOAD HALFWORD IMMEDIATE (64) ','LGX
               HI ','RI N '
         JAS   R11,VER249
         USING *,R11
INS249   LGHI  R1,*-2
HEX249   DC    X'A719FFFF'
NUM249   DC    P'249'
*MCALL #=   507 LV= 2 VER249   RT1   CCE,INS249,HEX249
VER249   DS    0H
         CLC   INS249,HEX249
RT1_TEST249      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE249
         LTORG 
RT1_CCE249      DS 0H
*MEXIT #=   507 LV= 2 RT1
*MEXIT #=   506 LV= 1 ZOSOP
*MCALL #=   508 LV= 1  ZOSOP 'A7A ','ADD HALFWORD IMMEDIATE (32) ','AHIX
                ','RI C '
         JAS   R11,VER250
         USING *,R11
INS250   AHI  R1,*-2
HEX250   DC    X'A71AFFFF'
NUM250   DC    P'250'
*MCALL #=   509 LV= 2 VER250   RT1   CCE,INS250,HEX250
VER250   DS    0H
         CLC   INS250,HEX250
RT1_TEST250      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE250
         LTORG 
RT1_CCE250      DS 0H
*MEXIT #=   509 LV= 2 RT1
*MEXIT #=   508 LV= 1 ZOSOP
*MCALL #=   510 LV= 1  ZOSOP 'A7B ','ADD HALFWORD IMMEDIATE (64) ','AGHX
               I ','RI C N '
         JAS   R11,VER251
         USING *,R11
INS251   AGHI  R1,*-2
HEX251   DC    X'A71BFFFF'
NUM251   DC    P'251'
*MCALL #=   511 LV= 2 VER251   RT1   CCE,INS251,HEX251
VER251   DS    0H
         CLC   INS251,HEX251
RT1_TEST251      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE251
         LTORG 
RT1_CCE251      DS 0H
*MEXIT #=   511 LV= 2 RT1
*MEXIT #=   510 LV= 1 ZOSOP
*MCALL #=   512 LV= 1  ZOSOP 'A7C ','MULTIPLY HALFWORD IMMEDIATE (32) 'X
               ,'MHI ','RI '
         JAS   R11,VER252
         USING *,R11
INS252   MHI  R1,*-2
HEX252   DC    X'A71CFFFF'
NUM252   DC    P'252'
*MCALL #=   513 LV= 2 VER252   RT1   CCE,INS252,HEX252
VER252   DS    0H
         CLC   INS252,HEX252
RT1_TEST252      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE252
         LTORG 
RT1_CCE252      DS 0H
*MEXIT #=   513 LV= 2 RT1
*MEXIT #=   512 LV= 1 ZOSOP
*MCALL #=   514 LV= 1  ZOSOP 'A7D ','MULTIPLY HALFWORD IMMEDIATE (64) 'X
               ,'MGHI ','RI N '
         JAS   R11,VER253
         USING *,R11
INS253   MGHI  R1,*-2
HEX253   DC    X'A71DFFFF'
NUM253   DC    P'253'
*MCALL #=   515 LV= 2 VER253   RT1   CCE,INS253,HEX253
VER253   DS    0H
         CLC   INS253,HEX253
RT1_TEST253      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE253
         LTORG 
RT1_CCE253      DS 0H
*MEXIT #=   515 LV= 2 RT1
*MEXIT #=   514 LV= 1 ZOSOP
*MCALL #=   516 LV= 1  ZOSOP 'A7E ','COMPARE HALFWORD IMMEDIATE (32) ',X
               'CHI ','RI C '
         JAS   R11,VER254
         USING *,R11
INS254   CHI  R1,*-2
HEX254   DC    X'A71EFFFF'
NUM254   DC    P'254'
*MCALL #=   517 LV= 2 VER254   RT1   CCE,INS254,HEX254
VER254   DS    0H
         CLC   INS254,HEX254
RT1_TEST254      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE254
         LTORG 
RT1_CCE254      DS 0H
*MEXIT #=   517 LV= 2 RT1
*MEXIT #=   516 LV= 1 ZOSOP
*MCALL #=   518 LV= 1  ZOSOP 'A7F ','COMPARE HALFWORD IMMEDIATE (64) ',X
               'CGHI ','RI C N '
         JAS   R11,VER255
         USING *,R11
INS255   CGHI  R1,*-2
HEX255   DC    X'A71FFFFF'
NUM255   DC    P'255'
*MCALL #=   519 LV= 2 VER255   RT1   CCE,INS255,HEX255
VER255   DS    0H
         CLC   INS255,HEX255
RT1_TEST255      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE255
         LTORG 
RT1_CCE255      DS 0H
*MEXIT #=   519 LV= 2 RT1
*MEXIT #=   518 LV= 1 ZOSOP
*MCALL #=   520 LV= 1  ZOSOP 'A8 ','MOVE LONG EXTENDED ','MVCLE','RS C X
               '
         JAS   R11,VER256
         USING *,R11
INS256   MVCLE R1,R3,S2
HEX256   DC    X'A813D002'
NUM256   DC    P'256'
*MCALL #=   521 LV= 2 VER256   RT1   CCE,INS256,HEX256
VER256   DS    0H
         CLC   INS256,HEX256
RT1_TEST256      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE256
         LTORG 
RT1_CCE256      DS 0H
*MEXIT #=   521 LV= 2 RT1
*MEXIT #=   520 LV= 1 ZOSOP
*MCALL #=   522 LV= 1  ZOSOP 'A9 ','COMPARE LOGICAL LONG EXTENDED ','CLX
               CLE','RS C '
         JAS   R11,VER257
         USING *,R11
INS257   CLCLE R1,R3,S2
HEX257   DC    X'A913D002'
NUM257   DC    P'257'
*MCALL #=   523 LV= 2 VER257   RT1   CCE,INS257,HEX257
VER257   DS    0H
         CLC   INS257,HEX257
RT1_TEST257      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE257
         LTORG 
RT1_CCE257      DS 0H
*MEXIT #=   523 LV= 2 RT1
*MEXIT #=   522 LV= 1 ZOSOP
*MCALL #=   524 LV= 1  ZOSOP 'AC ','STORE THEN AND SYSTEM MASK ','STNSMX
               ','SI '
         JAS   R11,VER258
         USING *,R11
INS258   STNSM S1,II
HEX258   DC    X'ACFFD001'
NUM258   DC    P'258'
*MCALL #=   525 LV= 2 VER258   RT1   CCE,INS258,HEX258
VER258   DS    0H
         CLC   INS258,HEX258
RT1_TEST258      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE258
         LTORG 
RT1_CCE258      DS 0H
*MEXIT #=   525 LV= 2 RT1
*MEXIT #=   524 LV= 1 ZOSOP
*MCALL #=   526 LV= 1  ZOSOP 'AD ','STORE THEN OR SYSTEM MASK ','STOSM'X
               ,'SI '
         JAS   R11,VER259
         USING *,R11
INS259   STOSM S1,II
HEX259   DC    X'ADFFD001'
NUM259   DC    P'259'
*MCALL #=   527 LV= 2 VER259   RT1   CCE,INS259,HEX259
VER259   DS    0H
         CLC   INS259,HEX259
RT1_TEST259      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE259
         LTORG 
RT1_CCE259      DS 0H
*MEXIT #=   527 LV= 2 RT1
*MEXIT #=   526 LV= 1 ZOSOP
*MCALL #=   528 LV= 1  ZOSOP 'AE ','SIGNAL PROCESSOR ','SIGP ','RS C '
         JAS   R11,VER260
         USING *,R11
INS260   SIGP  R1,R3,S2
HEX260   DC    X'AE13D002'
NUM260   DC    P'260'
*MCALL #=   529 LV= 2 VER260   RT1   CCE,INS260,HEX260
VER260   DS    0H
         CLC   INS260,HEX260
RT1_TEST260      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE260
         LTORG 
RT1_CCE260      DS 0H
*MEXIT #=   529 LV= 2 RT1
*MEXIT #=   528 LV= 1 ZOSOP
*MCALL #=   530 LV= 1  ZOSOP 'AF ','MONITOR CALL ','MC ','SI '
         JAS   R11,VER261
         USING *,R11
INS261   MC   S1,II
HEX261   DC    X'AFFFD001'
NUM261   DC    P'261'
*MCALL #=   531 LV= 2 VER261   RT1   CCE,INS261,HEX261
VER261   DS    0H
         CLC   INS261,HEX261
RT1_TEST261      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE261
         LTORG 
RT1_CCE261      DS 0H
*MEXIT #=   531 LV= 2 RT1
*MEXIT #=   530 LV= 1 ZOSOP
*MCALL #=   532 LV= 1  ZOSOP 'B1 ','LOAD REAL ADDRESS (32) ','LRA ','RXX
                C '
         JAS   R11,VER262
         USING *,R11
INS262   LRA  R1,S2(X4)
HEX262   DC    X'B114D002'
NUM262   DC    P'262'
*MCALL #=   533 LV= 2 VER262   RT1   CCE,INS262,HEX262
VER262   DS    0H
         CLC   INS262,HEX262
RT1_TEST262      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE262
         LTORG 
RT1_CCE262      DS 0H
*MEXIT #=   533 LV= 2 RT1
*MEXIT #=   532 LV= 1 ZOSOP
*MCALL #=   534 LV= 1  ZOSOP 'B202','STORE CPU ID ','STIDP','S '
         JAS   R11,VER263
         USING *,R11
INS263   STIDP S1
HEX263   DC    X'B202D001'
NUM263   DC    P'263'
*MCALL #=   535 LV= 2 VER263   RT1   CCE,INS263,HEX263
VER263   DS    0H
         CLC   INS263,HEX263
RT1_TEST263      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE263
         LTORG 
RT1_CCE263      DS 0H
*MEXIT #=   535 LV= 2 RT1
*MEXIT #=   534 LV= 1 ZOSOP
*MCALL #=   536 LV= 1  ZOSOP 'B204','SET CLOCK ','SCK ','S C '
         JAS   R11,VER264
         USING *,R11
INS264   SCK   S1
HEX264   DC    X'B204D001'
NUM264   DC    P'264'
*MCALL #=   537 LV= 2 VER264   RT1   CCE,INS264,HEX264
VER264   DS    0H
         CLC   INS264,HEX264
RT1_TEST264      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE264
         LTORG 
RT1_CCE264      DS 0H
*MEXIT #=   537 LV= 2 RT1
*MEXIT #=   536 LV= 1 ZOSOP
*MCALL #=   538 LV= 1  ZOSOP 'B205','STORE CLOCK ','STCK ','S C '
         JAS   R11,VER265
         USING *,R11
INS265   STCK  S1
HEX265   DC    X'B205D001'
NUM265   DC    P'265'
*MCALL #=   539 LV= 2 VER265   RT1   CCE,INS265,HEX265
VER265   DS    0H
         CLC   INS265,HEX265
RT1_TEST265      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE265
         LTORG 
RT1_CCE265      DS 0H
*MEXIT #=   539 LV= 2 RT1
*MEXIT #=   538 LV= 1 ZOSOP
*MCALL #=   540 LV= 1  ZOSOP 'B206','SET CLOCK COMPARATOR ','SCKC ','S X
               '
         JAS   R11,VER266
         USING *,R11
INS266   SCKC  S1
HEX266   DC    X'B206D001'
NUM266   DC    P'266'
*MCALL #=   541 LV= 2 VER266   RT1   CCE,INS266,HEX266
VER266   DS    0H
         CLC   INS266,HEX266
RT1_TEST266      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE266
         LTORG 
RT1_CCE266      DS 0H
*MEXIT #=   541 LV= 2 RT1
*MEXIT #=   540 LV= 1 ZOSOP
*MCALL #=   542 LV= 1  ZOSOP 'B207','STORE CLOCK COMPARATOR ','STCKC','X
               S '
         JAS   R11,VER267
         USING *,R11
INS267   STCKC S1
HEX267   DC    X'B207D001'
NUM267   DC    P'267'
*MCALL #=   543 LV= 2 VER267   RT1   CCE,INS267,HEX267
VER267   DS    0H
         CLC   INS267,HEX267
RT1_TEST267      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE267
         LTORG 
RT1_CCE267      DS 0H
*MEXIT #=   543 LV= 2 RT1
*MEXIT #=   542 LV= 1 ZOSOP
*MCALL #=   544 LV= 1  ZOSOP 'B208','SET CPU TIMER ','SPT ','S '
         JAS   R11,VER268
         USING *,R11
INS268   SPT   S1
HEX268   DC    X'B208D001'
NUM268   DC    P'268'
*MCALL #=   545 LV= 2 VER268   RT1   CCE,INS268,HEX268
VER268   DS    0H
         CLC   INS268,HEX268
RT1_TEST268      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE268
         LTORG 
RT1_CCE268      DS 0H
*MEXIT #=   545 LV= 2 RT1
*MEXIT #=   544 LV= 1 ZOSOP
*MCALL #=   546 LV= 1  ZOSOP 'B209','STORE CPU TIMER ','STPT ','S '
         JAS   R11,VER269
         USING *,R11
INS269   STPT  S1
HEX269   DC    X'B209D001'
NUM269   DC    P'269'
*MCALL #=   547 LV= 2 VER269   RT1   CCE,INS269,HEX269
VER269   DS    0H
         CLC   INS269,HEX269
RT1_TEST269      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE269
         LTORG 
RT1_CCE269      DS 0H
*MEXIT #=   547 LV= 2 RT1
*MEXIT #=   546 LV= 1 ZOSOP
*MCALL #=   548 LV= 1  ZOSOP 'B20A','SET PSW KEY FROM ADDRESS ','SPKA 'X
               ,'S '
         JAS   R11,VER270
         USING *,R11
INS270   SPKA  S1
HEX270   DC    X'B20AD001'
NUM270   DC    P'270'
*MCALL #=   549 LV= 2 VER270   RT1   CCE,INS270,HEX270
VER270   DS    0H
         CLC   INS270,HEX270
RT1_TEST270      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE270
         LTORG 
RT1_CCE270      DS 0H
*MEXIT #=   549 LV= 2 RT1
*MEXIT #=   548 LV= 1 ZOSOP
*MCALL #=   550 LV= 1  ZOSOP 'B20B','INSERT PSW KEY ','IPK ','S ',NOP=TX
                RPI-277
         JAS   R11,VER271
         USING *,R11
INS271   IPK   , NOP
HEX271   DC    X'B20B0000'
NUM271   DC    P'271'
*MCALL #=   551 LV= 2 VER271   RT1   CCE,INS271,HEX271
VER271   DS    0H
         CLC   INS271,HEX271
RT1_TEST271      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE271
         LTORG 
RT1_CCE271      DS 0H
*MEXIT #=   551 LV= 2 RT1
*MEXIT #=   550 LV= 1 ZOSOP
*MCALL #=   552 LV= 1  ZOSOP 'B20D','PURGE TLB ','PTLB ','S ',NOP=T RPIX
               -277
         JAS   R11,VER272
         USING *,R11
INS272   PTLB  , NOP
HEX272   DC    X'B20D0000'
NUM272   DC    P'272'
*MCALL #=   553 LV= 2 VER272   RT1   CCE,INS272,HEX272
VER272   DS    0H
         CLC   INS272,HEX272
RT1_TEST272      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE272
         LTORG 
RT1_CCE272      DS 0H
*MEXIT #=   553 LV= 2 RT1
*MEXIT #=   552 LV= 1 ZOSOP
*MCALL #=   554 LV= 1  ZOSOP 'B210','SET PREFIX ','SPX ','S '
         JAS   R11,VER273
         USING *,R11
INS273   SPX   S1
HEX273   DC    X'B210D001'
NUM273   DC    P'273'
*MCALL #=   555 LV= 2 VER273   RT1   CCE,INS273,HEX273
VER273   DS    0H
         CLC   INS273,HEX273
RT1_TEST273      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE273
         LTORG 
RT1_CCE273      DS 0H
*MEXIT #=   555 LV= 2 RT1
*MEXIT #=   554 LV= 1 ZOSOP
*MCALL #=   556 LV= 1  ZOSOP 'B211','STORE PREFIX ','STPX ','S '
         JAS   R11,VER274
         USING *,R11
INS274   STPX  S1
HEX274   DC    X'B211D001'
NUM274   DC    P'274'
*MCALL #=   557 LV= 2 VER274   RT1   CCE,INS274,HEX274
VER274   DS    0H
         CLC   INS274,HEX274
RT1_TEST274      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE274
         LTORG 
RT1_CCE274      DS 0H
*MEXIT #=   557 LV= 2 RT1
*MEXIT #=   556 LV= 1 ZOSOP
*MCALL #=   558 LV= 1  ZOSOP 'B212','STORE CPU ADDRESS ','STAP ','S '
         JAS   R11,VER275
         USING *,R11
INS275   STAP  S1
HEX275   DC    X'B212D001'
NUM275   DC    P'275'
*MCALL #=   559 LV= 2 VER275   RT1   CCE,INS275,HEX275
VER275   DS    0H
         CLC   INS275,HEX275
RT1_TEST275      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE275
         LTORG 
RT1_CCE275      DS 0H
*MEXIT #=   559 LV= 2 RT1
*MEXIT #=   558 LV= 1 ZOSOP
*MCALL #=   560 LV= 1  ZOSOP 'B218','PROGRAM CALL ','PC ','S '
         JAS   R11,VER276
         USING *,R11
INS276   PC    S1
HEX276   DC    X'B218D001'
NUM276   DC    P'276'
*MCALL #=   561 LV= 2 VER276   RT1   CCE,INS276,HEX276
VER276   DS    0H
         CLC   INS276,HEX276
RT1_TEST276      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE276
         LTORG 
RT1_CCE276      DS 0H
*MEXIT #=   561 LV= 2 RT1
*MEXIT #=   560 LV= 1 ZOSOP
*MCALL #=   562 LV= 1  ZOSOP 'B219','SET ADDRESS SPACE CONTROL ','SAC 'X
               ,'S '
         JAS   R11,VER277
         USING *,R11
INS277   SAC   S1
HEX277   DC    X'B219D001'
NUM277   DC    P'277'
*MCALL #=   563 LV= 2 VER277   RT1   CCE,INS277,HEX277
VER277   DS    0H
         CLC   INS277,HEX277
RT1_TEST277      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE277
         LTORG 
RT1_CCE277      DS 0H
*MEXIT #=   563 LV= 2 RT1
*MEXIT #=   562 LV= 1 ZOSOP
*MCALL #=   564 LV= 1  ZOSOP 'B21A','COMPARE AND FORM CODEWORD ','CFC 'X
               ,'S C '
         JAS   R11,VER278
         USING *,R11
INS278   CFC   S1
HEX278   DC    X'B21AD001'
NUM278   DC    P'278'
*MCALL #=   565 LV= 2 VER278   RT1   CCE,INS278,HEX278
VER278   DS    0H
         CLC   INS278,HEX278
RT1_TEST278      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE278
         LTORG 
RT1_CCE278      DS 0H
*MEXIT #=   565 LV= 2 RT1
*MEXIT #=   564 LV= 1 ZOSOP
*MCALL #=   566 LV= 1  ZOSOP 'B221','INVALIDATE PAGE TABLE ENTRY ','IPTX
               E ','RRE '
         JAS   R11,VER279
         USING *,R11
INS279   IPTE  R1,R2
HEX279   DC    X'B2210012'
NUM279   DC    P'279'
*MCALL #=   567 LV= 2 VER279   RT1   CCE,INS279,HEX279
VER279   DS    0H
         CLC   INS279,HEX279
RT1_TEST279      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE279
         LTORG 
RT1_CCE279      DS 0H
*MEXIT #=   567 LV= 2 RT1
*MEXIT #=   566 LV= 1 ZOSOP
*MCALL #=   568 LV= 1  ZOSOP 'B222','INSERT PROGRAM MASK ','IPM ','RR2 X
               '
         JAS   R11,VER280
         USING *,R11
INS280   IPM  R1
HEX280   DC    X'B2220010'
NUM280   DC    P'280'
*MCALL #=   569 LV= 2 VER280   RT1   CCE,INS280,HEX280
VER280   DS    0H
         CLC   INS280,HEX280
RT1_TEST280      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE280
         LTORG 
RT1_CCE280      DS 0H
*MEXIT #=   569 LV= 2 RT1
*MEXIT #=   568 LV= 1 ZOSOP
*MCALL #=   570 LV= 1  ZOSOP 'B223','INSERT VIRTUAL STORAGE KEY ','IVSKX
                ','RRE '
         JAS   R11,VER281
         USING *,R11
INS281   IVSK  R1,R2
HEX281   DC    X'B2230012'
NUM281   DC    P'281'
*MCALL #=   571 LV= 2 VER281   RT1   CCE,INS281,HEX281
VER281   DS    0H
         CLC   INS281,HEX281
RT1_TEST281      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE281
         LTORG 
RT1_CCE281      DS 0H
*MEXIT #=   571 LV= 2 RT1
*MEXIT #=   570 LV= 1 ZOSOP
*MCALL #=   572 LV= 1  ZOSOP 'B224','INSERT ADDRESS SPACE CONTROL ','IAX
               C ','RRE C '
         JAS   R11,VER282
         USING *,R11
INS282   IAC  R1,R2
HEX282   DC    X'B2240012'
NUM282   DC    P'282'
*MCALL #=   573 LV= 2 VER282   RT1   CCE,INS282,HEX282
VER282   DS    0H
         CLC   INS282,HEX282
RT1_TEST282      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE282
         LTORG 
RT1_CCE282      DS 0H
*MEXIT #=   573 LV= 2 RT1
*MEXIT #=   572 LV= 1 ZOSOP
*MCALL #=   574 LV= 1  ZOSOP 'B225','SET SECONDARY ASN ','SSAR ','RRE '
         JAS   R11,VER283
         USING *,R11
INS283   SSAR  R1,R2
HEX283   DC    X'B2250012'
NUM283   DC    P'283'
*MCALL #=   575 LV= 2 VER283   RT1   CCE,INS283,HEX283
VER283   DS    0H
         CLC   INS283,HEX283
RT1_TEST283      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE283
         LTORG 
RT1_CCE283      DS 0H
*MEXIT #=   575 LV= 2 RT1
*MEXIT #=   574 LV= 1 ZOSOP
*MCALL #=   576 LV= 1  ZOSOP 'B226','EXTRACT PRIMARY ASN ','EPAR ','RREX
                '
         JAS   R11,VER284
         USING *,R11
INS284   EPAR  R1,R2
HEX284   DC    X'B2260012'
NUM284   DC    P'284'
*MCALL #=   577 LV= 2 VER284   RT1   CCE,INS284,HEX284
VER284   DS    0H
         CLC   INS284,HEX284
RT1_TEST284      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE284
         LTORG 
RT1_CCE284      DS 0H
*MEXIT #=   577 LV= 2 RT1
*MEXIT #=   576 LV= 1 ZOSOP
*MCALL #=   578 LV= 1  ZOSOP 'B227','EXTRACT SECONDARY ASN ','ESAR ','RX
               RE '
         JAS   R11,VER285
         USING *,R11
INS285   ESAR  R1,R2
HEX285   DC    X'B2270012'
NUM285   DC    P'285'
*MCALL #=   579 LV= 2 VER285   RT1   CCE,INS285,HEX285
VER285   DS    0H
         CLC   INS285,HEX285
RT1_TEST285      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE285
         LTORG 
RT1_CCE285      DS 0H
*MEXIT #=   579 LV= 2 RT1
*MEXIT #=   578 LV= 1 ZOSOP
*MCALL #=   580 LV= 1  ZOSOP 'B228','PROGRAM TRANSFER ','PT ','RRE '
         JAS   R11,VER286
         USING *,R11
INS286   PT   R1,R2
HEX286   DC    X'B2280012'
NUM286   DC    P'286'
*MCALL #=   581 LV= 2 VER286   RT1   CCE,INS286,HEX286
VER286   DS    0H
         CLC   INS286,HEX286
RT1_TEST286      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE286
         LTORG 
RT1_CCE286      DS 0H
*MEXIT #=   581 LV= 2 RT1
*MEXIT #=   580 LV= 1 ZOSOP
*MCALL #=   582 LV= 1  ZOSOP 'B229','INSERT STORAGE KEY EXTENDED ','ISKX
               E ','RRE '
         JAS   R11,VER287
         USING *,R11
INS287   ISKE  R1,R2
HEX287   DC    X'B2290012'
NUM287   DC    P'287'
*MCALL #=   583 LV= 2 VER287   RT1   CCE,INS287,HEX287
VER287   DS    0H
         CLC   INS287,HEX287
RT1_TEST287      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE287
         LTORG 
RT1_CCE287      DS 0H
*MEXIT #=   583 LV= 2 RT1
*MEXIT #=   582 LV= 1 ZOSOP
*MCALL #=   584 LV= 1  ZOSOP 'B22A','RESET REFERENCE BIT EXTENDED ','RRX
               BE ','RRE C '
         JAS   R11,VER288
         USING *,R11
INS288   RRBE  R1,R2
HEX288   DC    X'B22A0012'
NUM288   DC    P'288'
*MCALL #=   585 LV= 2 VER288   RT1   CCE,INS288,HEX288
VER288   DS    0H
         CLC   INS288,HEX288
RT1_TEST288      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE288
         LTORG 
RT1_CCE288      DS 0H
*MEXIT #=   585 LV= 2 RT1
*MEXIT #=   584 LV= 1 ZOSOP
*MCALL #=   586 LV= 1  ZOSOP 'B22B','SET STORAGE KEY EXTENDED ','SSKE 'X
               ,'RRE '
         JAS   R11,VER289
         USING *,R11
INS289   SSKE  R1,R2
HEX289   DC    X'B22B0012'
NUM289   DC    P'289'
*MCALL #=   587 LV= 2 VER289   RT1   CCE,INS289,HEX289
VER289   DS    0H
         CLC   INS289,HEX289
RT1_TEST289      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE289
         LTORG 
RT1_CCE289      DS 0H
*MEXIT #=   587 LV= 2 RT1
*MEXIT #=   586 LV= 1 ZOSOP
*MCALL #=   588 LV= 1  ZOSOP 'B22C','TEST BLOCK ','TB ','RRE C '
         JAS   R11,VER290
         USING *,R11
INS290   TB   R1,R2
HEX290   DC    X'B22C0012'
NUM290   DC    P'290'
*MCALL #=   589 LV= 2 VER290   RT1   CCE,INS290,HEX290
VER290   DS    0H
         CLC   INS290,HEX290
RT1_TEST290      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE290
         LTORG 
RT1_CCE290      DS 0H
*MEXIT #=   589 LV= 2 RT1
*MEXIT #=   588 LV= 1 ZOSOP
*MCALL #=   590 LV= 1  ZOSOP 'B22D','DIVIDE (extended HFP) ','DXR ','RRX
               E '
         JAS   R11,VER291
         USING *,R11
INS291   DXR  R1,R2
HEX291   DC    X'B22D0012'
NUM291   DC    P'291'
*MCALL #=   591 LV= 2 VER291   RT1   CCE,INS291,HEX291
VER291   DS    0H
         CLC   INS291,HEX291
RT1_TEST291      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE291
         LTORG 
RT1_CCE291      DS 0H
*MEXIT #=   591 LV= 2 RT1
*MEXIT #=   590 LV= 1 ZOSOP
*MCALL #=   592 LV= 1  ZOSOP 'B22E','PAGE IN ','PGIN ','RRE C ES'
         JAS   R11,VER292
         USING *,R11
INS292   PGIN  R1,R2
HEX292   DC    X'B22E0012'
NUM292   DC    P'292'
*MCALL #=   593 LV= 2 VER292   RT1   CCE,INS292,HEX292
VER292   DS    0H
         CLC   INS292,HEX292
RT1_TEST292      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE292
         LTORG 
RT1_CCE292      DS 0H
*MEXIT #=   593 LV= 2 RT1
*MEXIT #=   592 LV= 1 ZOSOP
*MCALL #=   594 LV= 1  ZOSOP 'B22F','PAGE OUT ','PGOUT','RRE C ES'
         JAS   R11,VER293
         USING *,R11
INS293   PGOUT R1,R2
HEX293   DC    X'B22F0012'
NUM293   DC    P'293'
*MCALL #=   595 LV= 2 VER293   RT1   CCE,INS293,HEX293
VER293   DS    0H
         CLC   INS293,HEX293
RT1_TEST293      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE293
         LTORG 
RT1_CCE293      DS 0H
*MEXIT #=   595 LV= 2 RT1
*MEXIT #=   594 LV= 1 ZOSOP
*MCALL #=   596 LV= 1  ZOSOP 'B230','CLEAR SUBCHANNEL ','CSCH ','S C ',X
               NOP=T
         JAS   R11,VER294
         USING *,R11
INS294   CSCH  , NOP
HEX294   DC    X'B2300000'
NUM294   DC    P'294'
*MCALL #=   597 LV= 2 VER294   RT1   CCE,INS294,HEX294
VER294   DS    0H
         CLC   INS294,HEX294
RT1_TEST294      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE294
         LTORG 
RT1_CCE294      DS 0H
*MEXIT #=   597 LV= 2 RT1
*MEXIT #=   596 LV= 1 ZOSOP
*MCALL #=   598 LV= 1  ZOSOP 'B231','HALT SUBCHANNEL ','HSCH ','S C '
         JAS   R11,VER295
         USING *,R11
INS295   HSCH  S1
HEX295   DC    X'B231D001'
NUM295   DC    P'295'
*MCALL #=   599 LV= 2 VER295   RT1   CCE,INS295,HEX295
VER295   DS    0H
         CLC   INS295,HEX295
RT1_TEST295      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE295
         LTORG 
RT1_CCE295      DS 0H
*MEXIT #=   599 LV= 2 RT1
*MEXIT #=   598 LV= 1 ZOSOP
*MCALL #=   600 LV= 1  ZOSOP 'B232','MODIFY SUBCHANNEL ','MSCH ','S C '
         JAS   R11,VER296
         USING *,R11
INS296   MSCH  S1
HEX296   DC    X'B232D001'
NUM296   DC    P'296'
*MCALL #=   601 LV= 2 VER296   RT1   CCE,INS296,HEX296
VER296   DS    0H
         CLC   INS296,HEX296
RT1_TEST296      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE296
         LTORG 
RT1_CCE296      DS 0H
*MEXIT #=   601 LV= 2 RT1
*MEXIT #=   600 LV= 1 ZOSOP
*MCALL #=   602 LV= 1  ZOSOP 'B233','START SUBCHANNEL ','SSCH ','S C '
         JAS   R11,VER297
         USING *,R11
INS297   SSCH  S1
HEX297   DC    X'B233D001'
NUM297   DC    P'297'
*MCALL #=   603 LV= 2 VER297   RT1   CCE,INS297,HEX297
VER297   DS    0H
         CLC   INS297,HEX297
RT1_TEST297      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE297
         LTORG 
RT1_CCE297      DS 0H
*MEXIT #=   603 LV= 2 RT1
*MEXIT #=   602 LV= 1 ZOSOP
*MCALL #=   604 LV= 1  ZOSOP 'B234','STORE SUBCHANNEL ','STSCH','S C '
         JAS   R11,VER298
         USING *,R11
INS298   STSCH S1
HEX298   DC    X'B234D001'
NUM298   DC    P'298'
*MCALL #=   605 LV= 2 VER298   RT1   CCE,INS298,HEX298
VER298   DS    0H
         CLC   INS298,HEX298
RT1_TEST298      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE298
         LTORG 
RT1_CCE298      DS 0H
*MEXIT #=   605 LV= 2 RT1
*MEXIT #=   604 LV= 1 ZOSOP
*MCALL #=   606 LV= 1  ZOSOP 'B235','TEST SUBCHANNEL ','TSCH ','S C '
         JAS   R11,VER299
         USING *,R11
INS299   TSCH  S1
HEX299   DC    X'B235D001'
NUM299   DC    P'299'
*MCALL #=   607 LV= 2 VER299   RT1   CCE,INS299,HEX299
VER299   DS    0H
         CLC   INS299,HEX299
RT1_TEST299      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE299
         LTORG 
RT1_CCE299      DS 0H
*MEXIT #=   607 LV= 2 RT1
*MEXIT #=   606 LV= 1 ZOSOP
*MCALL #=   608 LV= 1  ZOSOP 'B236','TEST PENDING INTERRUPTION ','TPI 'X
               ,'S C '
         JAS   R11,VER300
         USING *,R11
INS300   TPI   S1
HEX300   DC    X'B236D001'
NUM300   DC    P'300'
*MCALL #=   609 LV= 2 VER300   RT1   CCE,INS300,HEX300
VER300   DS    0H
         CLC   INS300,HEX300
RT1_TEST300      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE300
         LTORG 
RT1_CCE300      DS 0H
*MEXIT #=   609 LV= 2 RT1
*MEXIT #=   608 LV= 1 ZOSOP
*MCALL #=   610 LV= 1  ZOSOP 'B237','SET ADDRESS LIMIT ','SAL ','S ',NOX
               P=T RPI-277
         JAS   R11,VER301
         USING *,R11
INS301   SAL   , NOP
HEX301   DC    X'B2370000'
NUM301   DC    P'301'
*MCALL #=   611 LV= 2 VER301   RT1   CCE,INS301,HEX301
VER301   DS    0H
         CLC   INS301,HEX301
RT1_TEST301      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE301
         LTORG 
RT1_CCE301      DS 0H
*MEXIT #=   611 LV= 2 RT1
*MEXIT #=   610 LV= 1 ZOSOP
*MCALL #=   612 LV= 1  ZOSOP 'B238','RESUME SUBCHANNEL ','RSCH ','S C 'X
               ,NOP=T
         JAS   R11,VER302
         USING *,R11
INS302   RSCH  , NOP
HEX302   DC    X'B2380000'
NUM302   DC    P'302'
*MCALL #=   613 LV= 2 VER302   RT1   CCE,INS302,HEX302
VER302   DS    0H
         CLC   INS302,HEX302
RT1_TEST302      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE302
         LTORG 
RT1_CCE302      DS 0H
*MEXIT #=   613 LV= 2 RT1
*MEXIT #=   612 LV= 1 ZOSOP
*MCALL #=   614 LV= 1  ZOSOP 'B239','STORE CHANNEL REPORT WORD ','STCRWX
               ','S C '
         JAS   R11,VER303
         USING *,R11
INS303   STCRW S1
HEX303   DC    X'B239D001'
NUM303   DC    P'303'
*MCALL #=   615 LV= 2 VER303   RT1   CCE,INS303,HEX303
VER303   DS    0H
         CLC   INS303,HEX303
RT1_TEST303      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE303
         LTORG 
RT1_CCE303      DS 0H
*MEXIT #=   615 LV= 2 RT1
*MEXIT #=   614 LV= 1 ZOSOP
*MCALL #=   616 LV= 1  ZOSOP 'B23A','STORE CHANNEL PATH STATUS ','STCPSX
               ','S '
         JAS   R11,VER304
         USING *,R11
INS304   STCPS S1
HEX304   DC    X'B23AD001'
NUM304   DC    P'304'
*MCALL #=   617 LV= 2 VER304   RT1   CCE,INS304,HEX304
VER304   DS    0H
         CLC   INS304,HEX304
RT1_TEST304      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE304
         LTORG 
RT1_CCE304      DS 0H
*MEXIT #=   617 LV= 2 RT1
*MEXIT #=   616 LV= 1 ZOSOP
*MCALL #=   618 LV= 1  ZOSOP 'B23B','RESET CHANNEL PATH ','RCHP ','S C X
               '
         JAS   R11,VER305
         USING *,R11
INS305   RCHP  S1
HEX305   DC    X'B23BD001'
NUM305   DC    P'305'
*MCALL #=   619 LV= 2 VER305   RT1   CCE,INS305,HEX305
VER305   DS    0H
         CLC   INS305,HEX305
RT1_TEST305      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE305
         LTORG 
RT1_CCE305      DS 0H
*MEXIT #=   619 LV= 2 RT1
*MEXIT #=   618 LV= 1 ZOSOP
*MCALL #=   620 LV= 1  ZOSOP 'B23C','SET CHANNEL MONITOR ','SCHM ','S 'X
               ,NOP=T
         JAS   R11,VER306
         USING *,R11
INS306   SCHM  , NOP
HEX306   DC    X'B23C0000'
NUM306   DC    P'306'
*MCALL #=   621 LV= 2 VER306   RT1   CCE,INS306,HEX306
VER306   DS    0H
         CLC   INS306,HEX306
RT1_TEST306      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE306
         LTORG 
RT1_CCE306      DS 0H
*MEXIT #=   621 LV= 2 RT1
*MEXIT #=   620 LV= 1 ZOSOP
*MCALL #=   622 LV= 1  ZOSOP 'B240','BRANCH AND STACK ','BAKR ','RRE '
         JAS   R11,VER307
         USING *,R11
INS307   BAKR  R1,R2
HEX307   DC    X'B2400012'
NUM307   DC    P'307'
*MCALL #=   623 LV= 2 VER307   RT1   CCE,INS307,HEX307
VER307   DS    0H
         CLC   INS307,HEX307
RT1_TEST307      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE307
         LTORG 
RT1_CCE307      DS 0H
*MEXIT #=   623 LV= 2 RT1
*MEXIT #=   622 LV= 1 ZOSOP
*MCALL #=   624 LV= 1  ZOSOP 'B241','CHECKSUM ','CKSM ','RRE C '
         JAS   R11,VER308
         USING *,R11
INS308   CKSM  R1,R2
HEX308   DC    X'B2410012'
NUM308   DC    P'308'
*MCALL #=   625 LV= 2 VER308   RT1   CCE,INS308,HEX308
VER308   DS    0H
         CLC   INS308,HEX308
RT1_TEST308      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE308
         LTORG 
RT1_CCE308      DS 0H
*MEXIT #=   625 LV= 2 RT1
*MEXIT #=   624 LV= 1 ZOSOP
*MCALL #=   626 LV= 1  ZOSOP 'B244','SQUARE ROOT (long HFP) ','SQDR ','X
               RRE '
         JAS   R11,VER309
         USING *,R11
INS309   SQDR  R1,R2
HEX309   DC    X'B2440012'
NUM309   DC    P'309'
*MCALL #=   627 LV= 2 VER309   RT1   CCE,INS309,HEX309
VER309   DS    0H
         CLC   INS309,HEX309
RT1_TEST309      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE309
         LTORG 
RT1_CCE309      DS 0H
*MEXIT #=   627 LV= 2 RT1
*MEXIT #=   626 LV= 1 ZOSOP
*MCALL #=   628 LV= 1  ZOSOP 'B245','SQUARE ROOT (short HFP) ','SQER ',X
               'RRE '
         JAS   R11,VER310
         USING *,R11
INS310   SQER  R1,R2
HEX310   DC    X'B2450012'
NUM310   DC    P'310'
*MCALL #=   629 LV= 2 VER310   RT1   CCE,INS310,HEX310
VER310   DS    0H
         CLC   INS310,HEX310
RT1_TEST310      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE310
         LTORG 
RT1_CCE310      DS 0H
*MEXIT #=   629 LV= 2 RT1
*MEXIT #=   628 LV= 1 ZOSOP
*MCALL #=   630 LV= 1  ZOSOP 'B246','STORE USING REAL ADDRESS (32) ','SX
               TURA','RRE '
         JAS   R11,VER311
         USING *,R11
INS311   STURA R1,R2
HEX311   DC    X'B2460012'
NUM311   DC    P'311'
*MCALL #=   631 LV= 2 VER311   RT1   CCE,INS311,HEX311
VER311   DS    0H
         CLC   INS311,HEX311
RT1_TEST311      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE311
         LTORG 
RT1_CCE311      DS 0H
*MEXIT #=   631 LV= 2 RT1
*MEXIT #=   630 LV= 1 ZOSOP
*MCALL #=   632 LV= 1  ZOSOP 'B247','MODIFY STACKED STATE ','MSTA ','RRX
               E '
         JAS   R11,VER312
         USING *,R11
INS312   MSTA  R1,R2
HEX312   DC    X'B2470012'
NUM312   DC    P'312'
*MCALL #=   633 LV= 2 VER312   RT1   CCE,INS312,HEX312
VER312   DS    0H
         CLC   INS312,HEX312
RT1_TEST312      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE312
         LTORG 
RT1_CCE312      DS 0H
*MEXIT #=   633 LV= 2 RT1
*MEXIT #=   632 LV= 1 ZOSOP
*MCALL #=   634 LV= 1  ZOSOP 'B248','PURGE ALB ','PALB ','RRE ',NOP=T RX
               PI-277
         JAS   R11,VER313
         USING *,R11
INS313   PALB  , NOP
HEX313   DC    X'B2480000'
NUM313   DC    P'313'
*MCALL #=   635 LV= 2 VER313   RT1   CCE,INS313,HEX313
VER313   DS    0H
         CLC   INS313,HEX313
RT1_TEST313      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE313
         LTORG 
RT1_CCE313      DS 0H
*MEXIT #=   635 LV= 2 RT1
*MEXIT #=   634 LV= 1 ZOSOP
*MCALL #=   636 LV= 1  ZOSOP 'B249','EXTRACT STACKED REGISTERS (32) ','X
               EREG ','RRE '
         JAS   R11,VER314
         USING *,R11
INS314   EREG  R1,R2
HEX314   DC    X'B2490012'
NUM314   DC    P'314'
*MCALL #=   637 LV= 2 VER314   RT1   CCE,INS314,HEX314
VER314   DS    0H
         CLC   INS314,HEX314
RT1_TEST314      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE314
         LTORG 
RT1_CCE314      DS 0H
*MEXIT #=   637 LV= 2 RT1
*MEXIT #=   636 LV= 1 ZOSOP
*MCALL #=   638 LV= 1  ZOSOP 'B24A','EXTRACT STACKED STATE ','ESTA ','RX
               RE C '
         JAS   R11,VER315
         USING *,R11
INS315   ESTA  R1,R2
HEX315   DC    X'B24A0012'
NUM315   DC    P'315'
*MCALL #=   639 LV= 2 VER315   RT1   CCE,INS315,HEX315
VER315   DS    0H
         CLC   INS315,HEX315
RT1_TEST315      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE315
         LTORG 
RT1_CCE315      DS 0H
*MEXIT #=   639 LV= 2 RT1
*MEXIT #=   638 LV= 1 ZOSOP
*MCALL #=   640 LV= 1  ZOSOP 'B24B','LOAD USING REAL ADDRESS (32) ','LUX
               RA ','RRE '
         JAS   R11,VER316
         USING *,R11
INS316   LURA  R1,R2
HEX316   DC    X'B24B0012'
NUM316   DC    P'316'
*MCALL #=   641 LV= 2 VER316   RT1   CCE,INS316,HEX316
VER316   DS    0H
         CLC   INS316,HEX316
RT1_TEST316      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE316
         LTORG 
RT1_CCE316      DS 0H
*MEXIT #=   641 LV= 2 RT1
*MEXIT #=   640 LV= 1 ZOSOP
*MCALL #=   642 LV= 1  ZOSOP 'B24C','TEST ACCESS ','TAR ','RRE C '
         JAS   R11,VER317
         USING *,R11
INS317   TAR  R1,R2
HEX317   DC    X'B24C0012'
NUM317   DC    P'317'
*MCALL #=   643 LV= 2 VER317   RT1   CCE,INS317,HEX317
VER317   DS    0H
         CLC   INS317,HEX317
RT1_TEST317      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE317
         LTORG 
RT1_CCE317      DS 0H
*MEXIT #=   643 LV= 2 RT1
*MEXIT #=   642 LV= 1 ZOSOP
*MCALL #=   644 LV= 1  ZOSOP 'B24D','COPY ACCESS ','CPYA ','RRE '
         JAS   R11,VER318
         USING *,R11
INS318   CPYA  R1,R2
HEX318   DC    X'B24D0012'
NUM318   DC    P'318'
*MCALL #=   645 LV= 2 VER318   RT1   CCE,INS318,HEX318
VER318   DS    0H
         CLC   INS318,HEX318
RT1_TEST318      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE318
         LTORG 
RT1_CCE318      DS 0H
*MEXIT #=   645 LV= 2 RT1
*MEXIT #=   644 LV= 1 ZOSOP
*MCALL #=   646 LV= 1  ZOSOP 'B24E','SET ACCESS ','SAR ','RRE '
         JAS   R11,VER319
         USING *,R11
INS319   SAR  R1,R2
HEX319   DC    X'B24E0012'
NUM319   DC    P'319'
*MCALL #=   647 LV= 2 VER319   RT1   CCE,INS319,HEX319
VER319   DS    0H
         CLC   INS319,HEX319
RT1_TEST319      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE319
         LTORG 
RT1_CCE319      DS 0H
*MEXIT #=   647 LV= 2 RT1
*MEXIT #=   646 LV= 1 ZOSOP
*MCALL #=   648 LV= 1  ZOSOP 'B24F','EXTRACT ACCESS ','EAR ','RRE '
         JAS   R11,VER320
         USING *,R11
INS320   EAR  R1,R2
HEX320   DC    X'B24F0012'
NUM320   DC    P'320'
*MCALL #=   649 LV= 2 VER320   RT1   CCE,INS320,HEX320
VER320   DS    0H
         CLC   INS320,HEX320
RT1_TEST320      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE320
         LTORG 
RT1_CCE320      DS 0H
*MEXIT #=   649 LV= 2 RT1
*MEXIT #=   648 LV= 1 ZOSOP
*MCALL #=   650 LV= 1  ZOSOP 'B250','COMPARE AND SWAP AND PURGE ','CSP X
               ','RRE C '
         JAS   R11,VER321
         USING *,R11
INS321   CSP  R1,R2
HEX321   DC    X'B2500012'
NUM321   DC    P'321'
*MCALL #=   651 LV= 2 VER321   RT1   CCE,INS321,HEX321
VER321   DS    0H
         CLC   INS321,HEX321
RT1_TEST321      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE321
         LTORG 
RT1_CCE321      DS 0H
*MEXIT #=   651 LV= 2 RT1
*MEXIT #=   650 LV= 1 ZOSOP
*MCALL #=   652 LV= 1  ZOSOP 'B252','MULTIPLY SINGLE (32) ','MSR ','RREX
                '
         JAS   R11,VER322
         USING *,R11
INS322   MSR  R1,R2
HEX322   DC    X'B2520012'
NUM322   DC    P'322'
*MCALL #=   653 LV= 2 VER322   RT1   CCE,INS322,HEX322
VER322   DS    0H
         CLC   INS322,HEX322
RT1_TEST322      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE322
         LTORG 
RT1_CCE322      DS 0H
*MEXIT #=   653 LV= 2 RT1
*MEXIT #=   652 LV= 1 ZOSOP
*MCALL #=   654 LV= 1  ZOSOP 'B254','MOVE PAGE ','MVPG ','RRE C '
         JAS   R11,VER323
         USING *,R11
INS323   MVPG  R1,R2
HEX323   DC    X'B2540012'
NUM323   DC    P'323'
*MCALL #=   655 LV= 2 VER323   RT1   CCE,INS323,HEX323
VER323   DS    0H
         CLC   INS323,HEX323
RT1_TEST323      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE323
         LTORG 
RT1_CCE323      DS 0H
*MEXIT #=   655 LV= 2 RT1
*MEXIT #=   654 LV= 1 ZOSOP
*MCALL #=   656 LV= 1  ZOSOP 'B255','MOVE STRING ','MVST ','RRE C '
         JAS   R11,VER324
         USING *,R11
INS324   MVST  R1,R2
HEX324   DC    X'B2550012'
NUM324   DC    P'324'
*MCALL #=   657 LV= 2 VER324   RT1   CCE,INS324,HEX324
VER324   DS    0H
         CLC   INS324,HEX324
RT1_TEST324      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE324
         LTORG 
RT1_CCE324      DS 0H
*MEXIT #=   657 LV= 2 RT1
*MEXIT #=   656 LV= 1 ZOSOP
*MCALL #=   658 LV= 1  ZOSOP 'B257','COMPARE UNTIL SUBSTRING EQUAL ','CX
               USE ','RRE C '
         JAS   R11,VER325
         USING *,R11
INS325   CUSE  R1,R2
HEX325   DC    X'B2570012'
NUM325   DC    P'325'
*MCALL #=   659 LV= 2 VER325   RT1   CCE,INS325,HEX325
VER325   DS    0H
         CLC   INS325,HEX325
RT1_TEST325      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE325
         LTORG 
RT1_CCE325      DS 0H
*MEXIT #=   659 LV= 2 RT1
*MEXIT #=   658 LV= 1 ZOSOP
*MCALL #=   660 LV= 1  ZOSOP 'B258','BRANCH IN SUBSPACE GROUP ','BSG ',X
               'RRE '
         JAS   R11,VER326
         USING *,R11
INS326   BSG  R1,R2
HEX326   DC    X'B2580012'
NUM326   DC    P'326'
*MCALL #=   661 LV= 2 VER326   RT1   CCE,INS326,HEX326
VER326   DS    0H
         CLC   INS326,HEX326
RT1_TEST326      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE326
         LTORG 
RT1_CCE326      DS 0H
*MEXIT #=   661 LV= 2 RT1
*MEXIT #=   660 LV= 1 ZOSOP
*MCALL #=   662 LV= 1  ZOSOP 'B25A','BRANCH AND SET AUTHORITY ','BSA ',X
               'RRE '
         JAS   R11,VER327
         USING *,R11
INS327   BSA  R1,R2
HEX327   DC    X'B25A0012'
NUM327   DC    P'327'
*MCALL #=   663 LV= 2 VER327   RT1   CCE,INS327,HEX327
VER327   DS    0H
         CLC   INS327,HEX327
RT1_TEST327      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE327
         LTORG 
RT1_CCE327      DS 0H
*MEXIT #=   663 LV= 2 RT1
*MEXIT #=   662 LV= 1 ZOSOP
*MCALL #=   664 LV= 1  ZOSOP 'B25D','COMPARE LOGICAL STRING ','CLST ','X
               RRE C '
         JAS   R11,VER328
         USING *,R11
INS328   CLST  R1,R2
HEX328   DC    X'B25D0012'
NUM328   DC    P'328'
*MCALL #=   665 LV= 2 VER328   RT1   CCE,INS328,HEX328
VER328   DS    0H
         CLC   INS328,HEX328
RT1_TEST328      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE328
         LTORG 
RT1_CCE328      DS 0H
*MEXIT #=   665 LV= 2 RT1
*MEXIT #=   664 LV= 1 ZOSOP
*MCALL #=   666 LV= 1  ZOSOP 'B25E','SEARCH STRING ','SRST ','RRE C '
         JAS   R11,VER329
         USING *,R11
INS329   SRST  R1,R2
HEX329   DC    X'B25E0012'
NUM329   DC    P'329'
*MCALL #=   667 LV= 2 VER329   RT1   CCE,INS329,HEX329
VER329   DS    0H
         CLC   INS329,HEX329
RT1_TEST329      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE329
         LTORG 
RT1_CCE329      DS 0H
*MEXIT #=   667 LV= 2 RT1
*MEXIT #=   666 LV= 1 ZOSOP
*MCALL #=   668 LV= 1  ZOSOP 'B263','COMPRESSION CALL ','CMPSC','RRE C X
               '
         JAS   R11,VER330
         USING *,R11
INS330   CMPSC R1,R2
HEX330   DC    X'B2630012'
NUM330   DC    P'330'
*MCALL #=   669 LV= 2 VER330   RT1   CCE,INS330,HEX330
VER330   DS    0H
         CLC   INS330,HEX330
RT1_TEST330      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE330
         LTORG 
RT1_CCE330      DS 0H
*MEXIT #=   669 LV= 2 RT1
*MEXIT #=   668 LV= 1 ZOSOP
*MCALL #=   670 LV= 1  ZOSOP 'B276','CANCEL SUBCHANNEL ','XSCH ','S C 'X
               ,NOP=T
         JAS   R11,VER331
         USING *,R11
INS331   XSCH  , NOP
HEX331   DC    X'B2760000'
NUM331   DC    P'331'
*MCALL #=   671 LV= 2 VER331   RT1   CCE,INS331,HEX331
VER331   DS    0H
         CLC   INS331,HEX331
RT1_TEST331      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE331
         LTORG 
RT1_CCE331      DS 0H
*MEXIT #=   671 LV= 2 RT1
*MEXIT #=   670 LV= 1 ZOSOP
*MCALL #=   672 LV= 1  ZOSOP 'B277','RESUME PROGRAM ','RP ','S L '
         JAS   R11,VER332
         USING *,R11
INS332   RP    S1
HEX332   DC    X'B277D001'
NUM332   DC    P'332'
*MCALL #=   673 LV= 2 VER332   RT1   CCE,INS332,HEX332
VER332   DS    0H
         CLC   INS332,HEX332
RT1_TEST332      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE332
         LTORG 
RT1_CCE332      DS 0H
*MEXIT #=   673 LV= 2 RT1
*MEXIT #=   672 LV= 1 ZOSOP
*MCALL #=   674 LV= 1  ZOSOP 'B278','STORE CLOCK EXTENDED ','STCKE','S X
               C '
         JAS   R11,VER333
         USING *,R11
INS333   STCKE S1
HEX333   DC    X'B278D001'
NUM333   DC    P'333'
*MCALL #=   675 LV= 2 VER333   RT1   CCE,INS333,HEX333
VER333   DS    0H
         CLC   INS333,HEX333
RT1_TEST333      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE333
         LTORG 
RT1_CCE333      DS 0H
*MEXIT #=   675 LV= 2 RT1
*MEXIT #=   674 LV= 1 ZOSOP
*MCALL #=   676 LV= 1  ZOSOP 'B279','SET ADDRESS SPACE CONTROL FAST ','X
               SACF ','S '
         JAS   R11,VER334
         USING *,R11
INS334   SACF  S1
HEX334   DC    X'B279D001'
NUM334   DC    P'334'
*MCALL #=   677 LV= 2 VER334   RT1   CCE,INS334,HEX334
VER334   DS    0H
         CLC   INS334,HEX334
RT1_TEST334      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE334
         LTORG 
RT1_CCE334      DS 0H
*MEXIT #=   677 LV= 2 RT1
*MEXIT #=   676 LV= 1 ZOSOP
*MCALL #=   678 LV= 1  ZOSOP 'B27C','STORE CLOCK FAST','STCKF','S',Z9
         JAS   R11,VER335
         USING *,R11
INS335   STCKF S1
HEX335   DC    X'B27CD001'
NUM335   DC    P'335'
*MCALL #=   679 LV= 2 VER335   RT1   CCE,INS335,HEX335
VER335   DS    0H
         CLC   INS335,HEX335
RT1_TEST335      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE335
         LTORG 
RT1_CCE335      DS 0H
*MEXIT #=   679 LV= 2 RT1
*MEXIT #=   678 LV= 1 ZOSOP
*MCALL #=   680 LV= 1  ZOSOP 'B27D','STORE SYSTEM INFORMATION ','STSI 'X
               ,'S C '
         JAS   R11,VER336
         USING *,R11
INS336   STSI  S1
HEX336   DC    X'B27DD001'
NUM336   DC    P'336'
*MCALL #=   681 LV= 2 VER336   RT1   CCE,INS336,HEX336
VER336   DS    0H
         CLC   INS336,HEX336
RT1_TEST336      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE336
         LTORG 
RT1_CCE336      DS 0H
*MEXIT #=   681 LV= 2 RT1
*MEXIT #=   680 LV= 1 ZOSOP
*MCALL #=   682 LV= 1  ZOSOP 'B299','SET ROUNDING MODE ','SRNM ','S '
         JAS   R11,VER337
         USING *,R11
INS337   SRNM  S1
HEX337   DC    X'B299D001'
NUM337   DC    P'337'
*MCALL #=   683 LV= 2 VER337   RT1   CCE,INS337,HEX337
VER337   DS    0H
         CLC   INS337,HEX337
RT1_TEST337      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE337
         LTORG 
RT1_CCE337      DS 0H
*MEXIT #=   683 LV= 2 RT1
*MEXIT #=   682 LV= 1 ZOSOP
*MCALL #=   684 LV= 1  ZOSOP 'B29C','STORE FPC ','STFPC','S '
         JAS   R11,VER338
         USING *,R11
INS338   STFPC S1
HEX338   DC    X'B29CD001'
NUM338   DC    P'338'
*MCALL #=   685 LV= 2 VER338   RT1   CCE,INS338,HEX338
VER338   DS    0H
         CLC   INS338,HEX338
RT1_TEST338      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE338
         LTORG 
RT1_CCE338      DS 0H
*MEXIT #=   685 LV= 2 RT1
*MEXIT #=   684 LV= 1 ZOSOP
*MCALL #=   686 LV= 1  ZOSOP 'B29D','LOAD FPC ','LFPC ','S '
         JAS   R11,VER339
         USING *,R11
INS339   LFPC  S1
HEX339   DC    X'B29DD001'
NUM339   DC    P'339'
*MCALL #=   687 LV= 2 VER339   RT1   CCE,INS339,HEX339
VER339   DS    0H
         CLC   INS339,HEX339
RT1_TEST339      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE339
         LTORG 
RT1_CCE339      DS 0H
*MEXIT #=   687 LV= 2 RT1
*MEXIT #=   686 LV= 1 ZOSOP
*MCALL #=   688 LV= 1  ZOSOP 'B2A5','TRANSLATE EXTENDED ','TRE ','RRE CX
                '
         JAS   R11,VER340
         USING *,R11
INS340   TRE  R1,R2
HEX340   DC    X'B2A50012'
NUM340   DC    P'340'
*MCALL #=   689 LV= 2 VER340   RT1   CCE,INS340,HEX340
VER340   DS    0H
         CLC   INS340,HEX340
RT1_TEST340      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE340
         LTORG 
RT1_CCE340      DS 0H
*MEXIT #=   689 LV= 2 RT1
*MEXIT #=   688 LV= 1 ZOSOP
*MCALL #=   690 LV= 1  ZOSOP 'B2A6','CONVERT UNICODE TO UTF-8 ','CUUTF'X
               ,'RRE C '
         JAS   R11,VER341
         USING *,R11
INS341   CUUTF R1,R2
HEX341   DC    X'B2A60012'
NUM341   DC    P'341'
*MCALL #=   691 LV= 2 VER341   RT1   CCE,INS341,HEX341
VER341   DS    0H
         CLC   INS341,HEX341
RT1_TEST341      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE341
         LTORG 
RT1_CCE341      DS 0H
*MEXIT #=   691 LV= 2 RT1
*MEXIT #=   690 LV= 1 ZOSOP
*MCALL #=   692 LV= 1  ZOSOP 'B2A6','CONVERT UTF-16 TO UTF-8 ','CU21 ',X
               'RRE C E3'
         JAS   R11,VER342
         USING *,R11
INS342   CU21  R1,R2
HEX342   DC    X'B2A60012'
NUM342   DC    P'342'
*MCALL #=   693 LV= 2 VER342   RT1   CCE,INS342,HEX342
VER342   DS    0H
         CLC   INS342,HEX342
RT1_TEST342      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE342
         LTORG 
RT1_CCE342      DS 0H
*MEXIT #=   693 LV= 2 RT1
*MEXIT #=   692 LV= 1 ZOSOP
*MCALL #=   694 LV= 1  ZOSOP 'B2A7','CONVERT UTF-8 TO UNICODE ','CUTFU'X
               ,'RRE C '
         JAS   R11,VER343
         USING *,R11
INS343   CUTFU R1,R2
HEX343   DC    X'B2A70012'
NUM343   DC    P'343'
*MCALL #=   695 LV= 2 VER343   RT1   CCE,INS343,HEX343
VER343   DS    0H
         CLC   INS343,HEX343
RT1_TEST343      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE343
         LTORG 
RT1_CCE343      DS 0H
*MEXIT #=   695 LV= 2 RT1
*MEXIT #=   694 LV= 1 ZOSOP
*MCALL #=   696 LV= 1  ZOSOP 'B2A7','CONVERT UTF-8 TO UTF-16 ','CU12 ',X
               'RRE C E3'
         JAS   R11,VER344
         USING *,R11
INS344   CU12  R1,R2
HEX344   DC    X'B2A70012'
NUM344   DC    P'344'
*MCALL #=   697 LV= 2 VER344   RT1   CCE,INS344,HEX344
VER344   DS    0H
         CLC   INS344,HEX344
RT1_TEST344      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE344
         LTORG 
RT1_CCE344      DS 0H
*MEXIT #=   697 LV= 2 RT1
*MEXIT #=   696 LV= 1 ZOSOP
*MCALL #=   698 LV= 1  ZOSOP 'B2B0','STORE FACILITY LIST EXTENDED','STFX
               LE','S',Z9
         JAS   R11,VER345
         USING *,R11
INS345   STFLE S1
HEX345   DC    X'B2B0D001'
NUM345   DC    P'345'
*MCALL #=   699 LV= 2 VER345   RT1   CCE,INS345,HEX345
VER345   DS    0H
         CLC   INS345,HEX345
RT1_TEST345      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE345
         LTORG 
RT1_CCE345      DS 0H
*MEXIT #=   699 LV= 2 RT1
*MEXIT #=   698 LV= 1 ZOSOP
*MCALL #=   700 LV= 1  ZOSOP 'B2B1','STORE FACILITY LIST ','STFL ','S NX
               3'
         JAS   R11,VER346
         USING *,R11
INS346   STFL  S1
HEX346   DC    X'B2B1D001'
NUM346   DC    P'346'
*MCALL #=   701 LV= 2 VER346   RT1   CCE,INS346,HEX346
VER346   DS    0H
         CLC   INS346,HEX346
RT1_TEST346      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE346
         LTORG 
RT1_CCE346      DS 0H
*MEXIT #=   701 LV= 2 RT1
*MEXIT #=   700 LV= 1 ZOSOP
*MCALL #=   702 LV= 1  ZOSOP 'B2B2','LOAD PSW EXTENDED ','LPSWE','S L NX
                '
         JAS   R11,VER347
         USING *,R11
INS347   LPSWE S1
HEX347   DC    X'B2B2D001'
NUM347   DC    P'347'
*MCALL #=   703 LV= 2 VER347   RT1   CCE,INS347,HEX347
VER347   DS    0H
         CLC   INS347,HEX347
RT1_TEST347      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE347
         LTORG 
RT1_CCE347      DS 0H
*MEXIT #=   703 LV= 2 RT1
*MEXIT #=   702 LV= 1 ZOSOP
*MCALL #=   704 LV= 1  ZOSOP 'B2B8','SET BFP ROUNDING MODE (3 bit)','SRX
               NMB','S'  RPI-1125 Z196
         JAS   R11,VER348
         USING *,R11
INS348   SRNMB S1
HEX348   DC    X'B2B8D001'
NUM348   DC    P'348'
*MCALL #=   705 LV= 2 VER348   RT1   CCE,INS348,HEX348
VER348   DS    0H
         CLC   INS348,HEX348
RT1_TEST348      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE348
         LTORG 
RT1_CCE348      DS 0H
*MEXIT #=   705 LV= 2 RT1
*MEXIT #=   704 LV= 1 ZOSOP
*MCALL #=   706 LV= 1  ZOSOP 'B2B9','SET DFP ROUNDING MODE','SRNMT','S'X
                DFP 55
         JAS   R11,VER349
         USING *,R11
INS349   SRNMT S1
HEX349   DC    X'B2B9D001'
NUM349   DC    P'349'
*MCALL #=   707 LV= 2 VER349   RT1   CCE,INS349,HEX349
VER349   DS    0H
         CLC   INS349,HEX349
RT1_TEST349      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE349
         LTORG 
RT1_CCE349      DS 0H
*MEXIT #=   707 LV= 2 RT1
*MEXIT #=   706 LV= 1 ZOSOP
*MCALL #=   708 LV= 1  ZOSOP 'B2BD','LOAD FPC AND SIGNAL','LFAS','S'   X
                DFP 56
         JAS   R11,VER350
         USING *,R11
INS350   LFAS  S1
HEX350   DC    X'B2BDD001'
NUM350   DC    P'350'
*MCALL #=   709 LV= 2 VER350   RT1   CCE,INS350,HEX350
VER350   DS    0H
         CLC   INS350,HEX350
RT1_TEST350      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE350
         LTORG 
RT1_CCE350      DS 0H
*MEXIT #=   709 LV= 2 RT1
*MEXIT #=   708 LV= 1 ZOSOP
*MCALL #=   710 LV= 1  ZOSOP 'B2FF','TRAP ','TRAP4','S '
         JAS   R11,VER351
         USING *,R11
INS351   TRAP4 S1
HEX351   DC    X'B2FFD001'
NUM351   DC    P'351'
*MCALL #=   711 LV= 2 VER351   RT1   CCE,INS351,HEX351
VER351   DS    0H
         CLC   INS351,HEX351
RT1_TEST351      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE351
         LTORG 
RT1_CCE351      DS 0H
*MEXIT #=   711 LV= 2 RT1
*MEXIT #=   710 LV= 1 ZOSOP
*MCALL #=   712 LV= 1  ZOSOP 'B300','LOAD POSITIVE (short BFP) ','LPEBRX
               ','RRE C '
         JAS   R11,VER352
         USING *,R11
INS352   LPEBR R1,R2
HEX352   DC    X'B3000012'
NUM352   DC    P'352'
*MCALL #=   713 LV= 2 VER352   RT1   CCE,INS352,HEX352
VER352   DS    0H
         CLC   INS352,HEX352
RT1_TEST352      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE352
         LTORG 
RT1_CCE352      DS 0H
*MEXIT #=   713 LV= 2 RT1
*MEXIT #=   712 LV= 1 ZOSOP
*MCALL #=   714 LV= 1  ZOSOP 'B301','LOAD NEGATIVE (short BFP) ','LNEBRX
               ','RRE C '
         JAS   R11,VER353
         USING *,R11
INS353   LNEBR R1,R2
HEX353   DC    X'B3010012'
NUM353   DC    P'353'
*MCALL #=   715 LV= 2 VER353   RT1   CCE,INS353,HEX353
VER353   DS    0H
         CLC   INS353,HEX353
RT1_TEST353      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE353
         LTORG 
RT1_CCE353      DS 0H
*MEXIT #=   715 LV= 2 RT1
*MEXIT #=   714 LV= 1 ZOSOP
*MCALL #=   716 LV= 1  ZOSOP 'B302','LOAD AND TEST (short BFP) ','LTEBRX
               ','RRE C '
         JAS   R11,VER354
         USING *,R11
INS354   LTEBR R1,R2
HEX354   DC    X'B3020012'
NUM354   DC    P'354'
*MCALL #=   717 LV= 2 VER354   RT1   CCE,INS354,HEX354
VER354   DS    0H
         CLC   INS354,HEX354
RT1_TEST354      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE354
         LTORG 
RT1_CCE354      DS 0H
*MEXIT #=   717 LV= 2 RT1
*MEXIT #=   716 LV= 1 ZOSOP
*MCALL #=   718 LV= 1  ZOSOP 'B303','LOAD COMPLEMENT (short BFP) ','LCEX
               BR','RRE C '
         JAS   R11,VER355
         USING *,R11
INS355   LCEBR R1,R2
HEX355   DC    X'B3030012'
NUM355   DC    P'355'
*MCALL #=   719 LV= 2 VER355   RT1   CCE,INS355,HEX355
VER355   DS    0H
         CLC   INS355,HEX355
RT1_TEST355      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE355
         LTORG 
RT1_CCE355      DS 0H
*MEXIT #=   719 LV= 2 RT1
*MEXIT #=   718 LV= 1 ZOSOP
*MCALL #=   720 LV= 1  ZOSOP 'B304','LOAD LENGTHENED (short to long BFPX
               ) ','LDEBR','RRE '
         JAS   R11,VER356
         USING *,R11
INS356   LDEBR R1,R2
HEX356   DC    X'B3040012'
NUM356   DC    P'356'
*MCALL #=   721 LV= 2 VER356   RT1   CCE,INS356,HEX356
VER356   DS    0H
         CLC   INS356,HEX356
RT1_TEST356      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE356
         LTORG 
RT1_CCE356      DS 0H
*MEXIT #=   721 LV= 2 RT1
*MEXIT #=   720 LV= 1 ZOSOP
*MCALL #=   722 LV= 1  ZOSOP 'B305','LOAD LENGTHENED (long to ext. BFP)X
                ','LXDBR','RRE '
         JAS   R11,VER357
         USING *,R11
INS357   LXDBR R1,R2
HEX357   DC    X'B3050012'
NUM357   DC    P'357'
*MCALL #=   723 LV= 2 VER357   RT1   CCE,INS357,HEX357
VER357   DS    0H
         CLC   INS357,HEX357
RT1_TEST357      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE357
         LTORG 
RT1_CCE357      DS 0H
*MEXIT #=   723 LV= 2 RT1
*MEXIT #=   722 LV= 1 ZOSOP
*MCALL #=   724 LV= 1  ZOSOP 'B306','LOAD LENGTHENED (short to ext. BFPX
               ) ','LXEBR','RRE '
         JAS   R11,VER358
         USING *,R11
INS358   LXEBR R1,R2
HEX358   DC    X'B3060012'
NUM358   DC    P'358'
*MCALL #=   725 LV= 2 VER358   RT1   CCE,INS358,HEX358
VER358   DS    0H
         CLC   INS358,HEX358
RT1_TEST358      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE358
         LTORG 
RT1_CCE358      DS 0H
*MEXIT #=   725 LV= 2 RT1
*MEXIT #=   724 LV= 1 ZOSOP
*MCALL #=   726 LV= 1  ZOSOP 'B307','MULTIPLY (long to extended BFP) ',X
               'MXDBR','RRE '
         JAS   R11,VER359
         USING *,R11
INS359   MXDBR R1,R2
HEX359   DC    X'B3070012'
NUM359   DC    P'359'
*MCALL #=   727 LV= 2 VER359   RT1   CCE,INS359,HEX359
VER359   DS    0H
         CLC   INS359,HEX359
RT1_TEST359      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE359
         LTORG 
RT1_CCE359      DS 0H
*MEXIT #=   727 LV= 2 RT1
*MEXIT #=   726 LV= 1 ZOSOP
*MCALL #=   728 LV= 1  ZOSOP 'B308','COMPARE AND SIGNAL (short BFP) ','X
               KEBR ','RRE C '
         JAS   R11,VER360
         USING *,R11
INS360   KEBR  R1,R2
HEX360   DC    X'B3080012'
NUM360   DC    P'360'
*MCALL #=   729 LV= 2 VER360   RT1   CCE,INS360,HEX360
VER360   DS    0H
         CLC   INS360,HEX360
RT1_TEST360      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE360
         LTORG 
RT1_CCE360      DS 0H
*MEXIT #=   729 LV= 2 RT1
*MEXIT #=   728 LV= 1 ZOSOP
*MCALL #=   730 LV= 1  ZOSOP 'B309','COMPARE (short BFP) ','CEBR ','RREX
                C '
         JAS   R11,VER361
         USING *,R11
INS361   CEBR  R1,R2
HEX361   DC    X'B3090012'
NUM361   DC    P'361'
*MCALL #=   731 LV= 2 VER361   RT1   CCE,INS361,HEX361
VER361   DS    0H
         CLC   INS361,HEX361
RT1_TEST361      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE361
         LTORG 
RT1_CCE361      DS 0H
*MEXIT #=   731 LV= 2 RT1
*MEXIT #=   730 LV= 1 ZOSOP
*MCALL #=   732 LV= 1  ZOSOP 'B30A','ADD (short BFP) ','AEBR ','RRE C '
         JAS   R11,VER362
         USING *,R11
INS362   AEBR  R1,R2
HEX362   DC    X'B30A0012'
NUM362   DC    P'362'
*MCALL #=   733 LV= 2 VER362   RT1   CCE,INS362,HEX362
VER362   DS    0H
         CLC   INS362,HEX362
RT1_TEST362      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE362
         LTORG 
RT1_CCE362      DS 0H
*MEXIT #=   733 LV= 2 RT1
*MEXIT #=   732 LV= 1 ZOSOP
*MCALL #=   734 LV= 1  ZOSOP 'B30B','SUBTRACT (short BFP) ','SEBR ','RRX
               E C '
         JAS   R11,VER363
         USING *,R11
INS363   SEBR  R1,R2
HEX363   DC    X'B30B0012'
NUM363   DC    P'363'
*MCALL #=   735 LV= 2 VER363   RT1   CCE,INS363,HEX363
VER363   DS    0H
         CLC   INS363,HEX363
RT1_TEST363      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE363
         LTORG 
RT1_CCE363      DS 0H
*MEXIT #=   735 LV= 2 RT1
*MEXIT #=   734 LV= 1 ZOSOP
*MCALL #=   736 LV= 1  ZOSOP 'B30C','MULTIPLY (short to long BFP) ','MDX
               EBR','RRE '
         JAS   R11,VER364
         USING *,R11
INS364   MDEBR R1,R2
HEX364   DC    X'B30C0012'
NUM364   DC    P'364'
*MCALL #=   737 LV= 2 VER364   RT1   CCE,INS364,HEX364
VER364   DS    0H
         CLC   INS364,HEX364
RT1_TEST364      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE364
         LTORG 
RT1_CCE364      DS 0H
*MEXIT #=   737 LV= 2 RT1
*MEXIT #=   736 LV= 1 ZOSOP
*MCALL #=   738 LV= 1  ZOSOP 'B30D','DIVIDE (short BFP) ','DEBR ','RRE X
               '
         JAS   R11,VER365
         USING *,R11
INS365   DEBR  R1,R2
HEX365   DC    X'B30D0012'
NUM365   DC    P'365'
*MCALL #=   739 LV= 2 VER365   RT1   CCE,INS365,HEX365
VER365   DS    0H
         CLC   INS365,HEX365
RT1_TEST365      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE365
         LTORG 
RT1_CCE365      DS 0H
*MEXIT #=   739 LV= 2 RT1
*MEXIT #=   738 LV= 1 ZOSOP
*MCALL #=   740 LV= 1  ZOSOP 'B30E','MULTIPLY AND ADD (short BFP) ','MAX
               EBR','RRF1'
         JAS   R11,VER366
         USING *,R11
INS366   MAEBR R1,R3,R2
HEX366   DC    X'B30E1032'
NUM366   DC    P'366'
*MCALL #=   741 LV= 2 VER366   RT1   CCE,INS366,HEX366
VER366   DS    0H
         CLC   INS366,HEX366
RT1_TEST366      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE366
         LTORG 
RT1_CCE366      DS 0H
*MEXIT #=   741 LV= 2 RT1
*MEXIT #=   740 LV= 1 ZOSOP
*MCALL #=   742 LV= 1  ZOSOP 'B30F','MULTIPLY AND SUBTRACT (short BFP) X
               ','MSEBR','RRF1'
         JAS   R11,VER367
         USING *,R11
INS367   MSEBR R1,R3,R2
HEX367   DC    X'B30F1032'
NUM367   DC    P'367'
*MCALL #=   743 LV= 2 VER367   RT1   CCE,INS367,HEX367
VER367   DS    0H
         CLC   INS367,HEX367
RT1_TEST367      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE367
         LTORG 
RT1_CCE367      DS 0H
*MEXIT #=   743 LV= 2 RT1
*MEXIT #=   742 LV= 1 ZOSOP
*MCALL #=   744 LV= 1  ZOSOP 'B310','LOAD POSITIVE (long BFP) ','LPDBR'X
               ,'RRE C '
         JAS   R11,VER368
         USING *,R11
INS368   LPDBR R1,R2
HEX368   DC    X'B3100012'
NUM368   DC    P'368'
*MCALL #=   745 LV= 2 VER368   RT1   CCE,INS368,HEX368
VER368   DS    0H
         CLC   INS368,HEX368
RT1_TEST368      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE368
         LTORG 
RT1_CCE368      DS 0H
*MEXIT #=   745 LV= 2 RT1
*MEXIT #=   744 LV= 1 ZOSOP
*MCALL #=   746 LV= 1  ZOSOP 'B311','LOAD NEGATIVE (long BFP) ','LNDBR'X
               ,'RRE C '
         JAS   R11,VER369
         USING *,R11
INS369   LNDBR R1,R2
HEX369   DC    X'B3110012'
NUM369   DC    P'369'
*MCALL #=   747 LV= 2 VER369   RT1   CCE,INS369,HEX369
VER369   DS    0H
         CLC   INS369,HEX369
RT1_TEST369      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE369
         LTORG 
RT1_CCE369      DS 0H
*MEXIT #=   747 LV= 2 RT1
*MEXIT #=   746 LV= 1 ZOSOP
*MCALL #=   748 LV= 1  ZOSOP 'B312','LOAD AND TEST (long BFP) ','LTDBR'X
               ,'RRE C '
         JAS   R11,VER370
         USING *,R11
INS370   LTDBR R1,R2
HEX370   DC    X'B3120012'
NUM370   DC    P'370'
*MCALL #=   749 LV= 2 VER370   RT1   CCE,INS370,HEX370
VER370   DS    0H
         CLC   INS370,HEX370
RT1_TEST370      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE370
         LTORG 
RT1_CCE370      DS 0H
*MEXIT #=   749 LV= 2 RT1
*MEXIT #=   748 LV= 1 ZOSOP
*MCALL #=   750 LV= 1  ZOSOP 'B313','LOAD COMPLEMENT (long BFP) ','LCDBX
               R','RRE C '
         JAS   R11,VER371
         USING *,R11
INS371   LCDBR R1,R2
HEX371   DC    X'B3130012'
NUM371   DC    P'371'
*MCALL #=   751 LV= 2 VER371   RT1   CCE,INS371,HEX371
VER371   DS    0H
         CLC   INS371,HEX371
RT1_TEST371      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE371
         LTORG 
RT1_CCE371      DS 0H
*MEXIT #=   751 LV= 2 RT1
*MEXIT #=   750 LV= 1 ZOSOP
*MCALL #=   752 LV= 1  ZOSOP 'B314','SQUARE ROOT (short BFP) ','SQEBR',X
               'RRE '
         JAS   R11,VER372
         USING *,R11
INS372   SQEBR R1,R2
HEX372   DC    X'B3140012'
NUM372   DC    P'372'
*MCALL #=   753 LV= 2 VER372   RT1   CCE,INS372,HEX372
VER372   DS    0H
         CLC   INS372,HEX372
RT1_TEST372      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE372
         LTORG 
RT1_CCE372      DS 0H
*MEXIT #=   753 LV= 2 RT1
*MEXIT #=   752 LV= 1 ZOSOP
*MCALL #=   754 LV= 1  ZOSOP 'B315','SQUARE ROOT (long BFP) ','SQDBR','X
               RRE '
         JAS   R11,VER373
         USING *,R11
INS373   SQDBR R1,R2
HEX373   DC    X'B3150012'
NUM373   DC    P'373'
*MCALL #=   755 LV= 2 VER373   RT1   CCE,INS373,HEX373
VER373   DS    0H
         CLC   INS373,HEX373
RT1_TEST373      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE373
         LTORG 
RT1_CCE373      DS 0H
*MEXIT #=   755 LV= 2 RT1
*MEXIT #=   754 LV= 1 ZOSOP
*MCALL #=   756 LV= 1  ZOSOP 'B316','SQUARE ROOT (extended BFP) ','SQXBX
               R','RRE '
         JAS   R11,VER374
         USING *,R11
INS374   SQXBR R1,R2
HEX374   DC    X'B3160012'
NUM374   DC    P'374'
*MCALL #=   757 LV= 2 VER374   RT1   CCE,INS374,HEX374
VER374   DS    0H
         CLC   INS374,HEX374
RT1_TEST374      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE374
         LTORG 
RT1_CCE374      DS 0H
*MEXIT #=   757 LV= 2 RT1
*MEXIT #=   756 LV= 1 ZOSOP
*MCALL #=   758 LV= 1  ZOSOP 'B317','MULTIPLY (short BFP) ','MEEBR','RRX
               E '
         JAS   R11,VER375
         USING *,R11
INS375   MEEBR R1,R2
HEX375   DC    X'B3170012'
NUM375   DC    P'375'
*MCALL #=   759 LV= 2 VER375   RT1   CCE,INS375,HEX375
VER375   DS    0H
         CLC   INS375,HEX375
RT1_TEST375      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE375
         LTORG 
RT1_CCE375      DS 0H
*MEXIT #=   759 LV= 2 RT1
*MEXIT #=   758 LV= 1 ZOSOP
*MCALL #=   760 LV= 1  ZOSOP 'B318','COMPARE AND SIGNAL (long BFP) ','KX
               DBR ','RRE C '
         JAS   R11,VER376
         USING *,R11
INS376   KDBR  R1,R2
HEX376   DC    X'B3180012'
NUM376   DC    P'376'
*MCALL #=   761 LV= 2 VER376   RT1   CCE,INS376,HEX376
VER376   DS    0H
         CLC   INS376,HEX376
RT1_TEST376      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE376
         LTORG 
RT1_CCE376      DS 0H
*MEXIT #=   761 LV= 2 RT1
*MEXIT #=   760 LV= 1 ZOSOP
*MCALL #=   762 LV= 1  ZOSOP 'B319','COMPARE (long BFP) ','CDBR ','RRE X
               C '
         JAS   R11,VER377
         USING *,R11
INS377   CDBR  R1,R2
HEX377   DC    X'B3190012'
NUM377   DC    P'377'
*MCALL #=   763 LV= 2 VER377   RT1   CCE,INS377,HEX377
VER377   DS    0H
         CLC   INS377,HEX377
RT1_TEST377      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE377
         LTORG 
RT1_CCE377      DS 0H
*MEXIT #=   763 LV= 2 RT1
*MEXIT #=   762 LV= 1 ZOSOP
*MCALL #=   764 LV= 1  ZOSOP 'B31A','ADD (long BFP) ','ADBR ','RRE C '
         JAS   R11,VER378
         USING *,R11
INS378   ADBR  R1,R2
HEX378   DC    X'B31A0012'
NUM378   DC    P'378'
*MCALL #=   765 LV= 2 VER378   RT1   CCE,INS378,HEX378
VER378   DS    0H
         CLC   INS378,HEX378
RT1_TEST378      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE378
         LTORG 
RT1_CCE378      DS 0H
*MEXIT #=   765 LV= 2 RT1
*MEXIT #=   764 LV= 1 ZOSOP
*MCALL #=   766 LV= 1  ZOSOP 'B31B','SUBTRACT (long BFP) ','SDBR ','RREX
                C '
         JAS   R11,VER379
         USING *,R11
INS379   SDBR  R1,R2
HEX379   DC    X'B31B0012'
NUM379   DC    P'379'
*MCALL #=   767 LV= 2 VER379   RT1   CCE,INS379,HEX379
VER379   DS    0H
         CLC   INS379,HEX379
RT1_TEST379      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE379
         LTORG 
RT1_CCE379      DS 0H
*MEXIT #=   767 LV= 2 RT1
*MEXIT #=   766 LV= 1 ZOSOP
*MCALL #=   768 LV= 1  ZOSOP 'B31C','MULTIPLY (long BFP) ','MDBR ','RREX
                '
         JAS   R11,VER380
         USING *,R11
INS380   MDBR  R1,R2
HEX380   DC    X'B31C0012'
NUM380   DC    P'380'
*MCALL #=   769 LV= 2 VER380   RT1   CCE,INS380,HEX380
VER380   DS    0H
         CLC   INS380,HEX380
RT1_TEST380      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE380
         LTORG 
RT1_CCE380      DS 0H
*MEXIT #=   769 LV= 2 RT1
*MEXIT #=   768 LV= 1 ZOSOP
*MCALL #=   770 LV= 1  ZOSOP 'B31D','DIVIDE (long BFP) ','DDBR ','RRE '
         JAS   R11,VER381
         USING *,R11
INS381   DDBR  R1,R2
HEX381   DC    X'B31D0012'
NUM381   DC    P'381'
*MCALL #=   771 LV= 2 VER381   RT1   CCE,INS381,HEX381
VER381   DS    0H
         CLC   INS381,HEX381
RT1_TEST381      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE381
         LTORG 
RT1_CCE381      DS 0H
*MEXIT #=   771 LV= 2 RT1
*MEXIT #=   770 LV= 1 ZOSOP
*MCALL #=   772 LV= 1  ZOSOP 'B31E','MULTIPLY AND ADD (long BFP) ','MADX
               BR','RRF1'
         JAS   R11,VER382
         USING *,R11
INS382   MADBR R1,R3,R2
HEX382   DC    X'B31E1032'
NUM382   DC    P'382'
*MCALL #=   773 LV= 2 VER382   RT1   CCE,INS382,HEX382
VER382   DS    0H
         CLC   INS382,HEX382
RT1_TEST382      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE382
         LTORG 
RT1_CCE382      DS 0H
*MEXIT #=   773 LV= 2 RT1
*MEXIT #=   772 LV= 1 ZOSOP
*MCALL #=   774 LV= 1  ZOSOP 'B31F','MULTIPLY AND SUBTRACT (long BFP) 'X
               ,'MSDBR','RRF1'
         JAS   R11,VER383
         USING *,R11
INS383   MSDBR R1,R3,R2
HEX383   DC    X'B31F1032'
NUM383   DC    P'383'
*MCALL #=   775 LV= 2 VER383   RT1   CCE,INS383,HEX383
VER383   DS    0H
         CLC   INS383,HEX383
RT1_TEST383      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE383
         LTORG 
RT1_CCE383      DS 0H
*MEXIT #=   775 LV= 2 RT1
*MEXIT #=   774 LV= 1 ZOSOP
*MCALL #=   776 LV= 1  ZOSOP 'B324','LOAD LENGTHENED (short to long HFPX
               ) ','LDER ','RRE '
         JAS   R11,VER384
         USING *,R11
INS384   LDER  R1,R2
HEX384   DC    X'B3240012'
NUM384   DC    P'384'
*MCALL #=   777 LV= 2 VER384   RT1   CCE,INS384,HEX384
VER384   DS    0H
         CLC   INS384,HEX384
RT1_TEST384      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE384
         LTORG 
RT1_CCE384      DS 0H
*MEXIT #=   777 LV= 2 RT1
*MEXIT #=   776 LV= 1 ZOSOP
*MCALL #=   778 LV= 1  ZOSOP 'B325','LOAD LENGTHENED (long to ext. HFP)X
                ','LXDR ','RRE '
         JAS   R11,VER385
         USING *,R11
INS385   LXDR  R1,R2
HEX385   DC    X'B3250012'
NUM385   DC    P'385'
*MCALL #=   779 LV= 2 VER385   RT1   CCE,INS385,HEX385
VER385   DS    0H
         CLC   INS385,HEX385
RT1_TEST385      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE385
         LTORG 
RT1_CCE385      DS 0H
*MEXIT #=   779 LV= 2 RT1
*MEXIT #=   778 LV= 1 ZOSOP
*MCALL #=   780 LV= 1  ZOSOP 'B326','LOAD LENGTHENED (short to ext. HFPX
               ) ','LXER ','RRE '
         JAS   R11,VER386
         USING *,R11
INS386   LXER  R1,R2
HEX386   DC    X'B3260012'
NUM386   DC    P'386'
*MCALL #=   781 LV= 2 VER386   RT1   CCE,INS386,HEX386
VER386   DS    0H
         CLC   INS386,HEX386
RT1_TEST386      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE386
         LTORG 
RT1_CCE386      DS 0H
*MEXIT #=   781 LV= 2 RT1
*MEXIT #=   780 LV= 1 ZOSOP
*MCALL #=   782 LV= 1  ZOSOP 'B32E','MULTIPLY AND ADD (short HFP) ','MAX
               ER ','RRF1 HM'
         JAS   R11,VER387
         USING *,R11
INS387   MAER  R1,R3,R2
HEX387   DC    X'B32E1032'
NUM387   DC    P'387'
*MCALL #=   783 LV= 2 VER387   RT1   CCE,INS387,HEX387
VER387   DS    0H
         CLC   INS387,HEX387
RT1_TEST387      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE387
         LTORG 
RT1_CCE387      DS 0H
*MEXIT #=   783 LV= 2 RT1
*MEXIT #=   782 LV= 1 ZOSOP
*MCALL #=   784 LV= 1  ZOSOP 'B32F','MULTIPLY AND SUBTRACT (short HFP) X
               ','MSER ','RRF1 HM'
         JAS   R11,VER388
         USING *,R11
INS388   MSER  R1,R3,R2
HEX388   DC    X'B32F1032'
NUM388   DC    P'388'
*MCALL #=   785 LV= 2 VER388   RT1   CCE,INS388,HEX388
VER388   DS    0H
         CLC   INS388,HEX388
RT1_TEST388      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE388
         LTORG 
RT1_CCE388      DS 0H
*MEXIT #=   785 LV= 2 RT1
*MEXIT #=   784 LV= 1 ZOSOP
*MCALL #=   786 LV= 1  ZOSOP 'B336','SQUARE ROOT (extended HFP) ','SQXRX
                ','RRE '
         JAS   R11,VER389
         USING *,R11
INS389   SQXR  R1,R2
HEX389   DC    X'B3360012'
NUM389   DC    P'389'
*MCALL #=   787 LV= 2 VER389   RT1   CCE,INS389,HEX389
VER389   DS    0H
         CLC   INS389,HEX389
RT1_TEST389      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE389
         LTORG 
RT1_CCE389      DS 0H
*MEXIT #=   787 LV= 2 RT1
*MEXIT #=   786 LV= 1 ZOSOP
*MCALL #=   788 LV= 1  ZOSOP 'B337','MULTIPLY (short HFP) ','MEER ','RRX
               E '
         JAS   R11,VER390
         USING *,R11
INS390   MEER  R1,R2
HEX390   DC    X'B3370012'
NUM390   DC    P'390'
*MCALL #=   789 LV= 2 VER390   RT1   CCE,INS390,HEX390
VER390   DS    0H
         CLC   INS390,HEX390
RT1_TEST390      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE390
         LTORG 
RT1_CCE390      DS 0H
*MEXIT #=   789 LV= 2 RT1
*MEXIT #=   788 LV= 1 ZOSOP
*MCALL #=   790 LV= 1  ZOSOP 'B338','MULTIPLY AND ADD U (L > X low  HFPX
               )','MAYLR','RRF1',Z9
         JAS   R11,VER391
         USING *,R11
INS391   MAYLR R1,R3,R2
HEX391   DC    X'B3381032'
NUM391   DC    P'391'
*MCALL #=   791 LV= 2 VER391   RT1   CCE,INS391,HEX391
VER391   DS    0H
         CLC   INS391,HEX391
RT1_TEST391      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE391
         LTORG 
RT1_CCE391      DS 0H
*MEXIT #=   791 LV= 2 RT1
*MEXIT #=   790 LV= 1 ZOSOP
*MCALL #=   792 LV= 1  ZOSOP 'B339','MULTIPLY U (L > X low  HFP)','MYLRX
               ','RRF1',Z9
         JAS   R11,VER392
         USING *,R11
INS392   MYLR R1,R3,R2
HEX392   DC    X'B3391032'
NUM392   DC    P'392'
*MCALL #=   793 LV= 2 VER392   RT1   CCE,INS392,HEX392
VER392   DS    0H
         CLC   INS392,HEX392
RT1_TEST392      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE392
         LTORG 
RT1_CCE392      DS 0H
*MEXIT #=   793 LV= 2 RT1
*MEXIT #=   792 LV= 1 ZOSOP
*MCALL #=   794 LV= 1  ZOSOP 'B33A','MULTIPLY AND ADD U (long  HFP)','MX
               AYR','RRF1',Z9
         JAS   R11,VER393
         USING *,R11
INS393   MAYR R1,R3,R2
HEX393   DC    X'B33A1032'
NUM393   DC    P'393'
*MCALL #=   795 LV= 2 VER393   RT1   CCE,INS393,HEX393
VER393   DS    0H
         CLC   INS393,HEX393
RT1_TEST393      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE393
         LTORG 
RT1_CCE393      DS 0H
*MEXIT #=   795 LV= 2 RT1
*MEXIT #=   794 LV= 1 ZOSOP
*MCALL #=   796 LV= 1  ZOSOP 'B33B','MULTIPLY U (long HFP)','MYR','RRF1X
               ',Z9
         JAS   R11,VER394
         USING *,R11
INS394   MYR  R1,R3,R2
HEX394   DC    X'B33B1032'
NUM394   DC    P'394'
*MCALL #=   797 LV= 2 VER394   RT1   CCE,INS394,HEX394
VER394   DS    0H
         CLC   INS394,HEX394
RT1_TEST394      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE394
         LTORG 
RT1_CCE394      DS 0H
*MEXIT #=   797 LV= 2 RT1
*MEXIT #=   796 LV= 1 ZOSOP
*MCALL #=   798 LV= 1  ZOSOP 'B33C','MULTIPLY AND ADD U (L > X high HFPX
               )','MAYHR','RRF1',Z9
         JAS   R11,VER395
         USING *,R11
INS395   MAYHR R1,R3,R2
HEX395   DC    X'B33C1032'
NUM395   DC    P'395'
*MCALL #=   799 LV= 2 VER395   RT1   CCE,INS395,HEX395
VER395   DS    0H
         CLC   INS395,HEX395
RT1_TEST395      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE395
         LTORG 
RT1_CCE395      DS 0H
*MEXIT #=   799 LV= 2 RT1
*MEXIT #=   798 LV= 1 ZOSOP
*MCALL #=   800 LV= 1  ZOSOP 'B33D','MULTIPLY U (L > X high HFP)','MYHRX
               ','RRF1',Z9
         JAS   R11,VER396
         USING *,R11
INS396   MYHR R1,R3,R2
HEX396   DC    X'B33D1032'
NUM396   DC    P'396'
*MCALL #=   801 LV= 2 VER396   RT1   CCE,INS396,HEX396
VER396   DS    0H
         CLC   INS396,HEX396
RT1_TEST396      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE396
         LTORG 
RT1_CCE396      DS 0H
*MEXIT #=   801 LV= 2 RT1
*MEXIT #=   800 LV= 1 ZOSOP
*MCALL #=   802 LV= 1  ZOSOP 'B33E','MULTIPLY AND ADD (long HFP) ','MADX
               R ','RRF1 HM'
         JAS   R11,VER397
         USING *,R11
INS397   MADR  R1,R3,R2
HEX397   DC    X'B33E1032'
NUM397   DC    P'397'
*MCALL #=   803 LV= 2 VER397   RT1   CCE,INS397,HEX397
VER397   DS    0H
         CLC   INS397,HEX397
RT1_TEST397      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE397
         LTORG 
RT1_CCE397      DS 0H
*MEXIT #=   803 LV= 2 RT1
*MEXIT #=   802 LV= 1 ZOSOP
*MCALL #=   804 LV= 1  ZOSOP 'B33F','MULTIPLY AND SUBTRACT (long HFP) 'X
               ,'MSDR ','RRF1 HM'
         JAS   R11,VER398
         USING *,R11
INS398   MSDR  R1,R3,R2
HEX398   DC    X'B33F1032'
NUM398   DC    P'398'
*MCALL #=   805 LV= 2 VER398   RT1   CCE,INS398,HEX398
VER398   DS    0H
         CLC   INS398,HEX398
RT1_TEST398      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE398
         LTORG 
RT1_CCE398      DS 0H
*MEXIT #=   805 LV= 2 RT1
*MEXIT #=   804 LV= 1 ZOSOP
*MCALL #=   806 LV= 1  ZOSOP 'B340','LOAD POSITIVE (extended BFP) ','LPX
               XBR','RRE C '
         JAS   R11,VER399
         USING *,R11
INS399   LPXBR R1,R2
HEX399   DC    X'B3400012'
NUM399   DC    P'399'
*MCALL #=   807 LV= 2 VER399   RT1   CCE,INS399,HEX399
VER399   DS    0H
         CLC   INS399,HEX399
RT1_TEST399      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE399
         LTORG 
RT1_CCE399      DS 0H
*MEXIT #=   807 LV= 2 RT1
*MEXIT #=   806 LV= 1 ZOSOP
*MCALL #=   808 LV= 1  ZOSOP 'B341','LOAD NEGATIVE (extended BFP) ','LNX
               XBR','RRE C '
         JAS   R11,VER400
         USING *,R11
INS400   LNXBR R1,R2
HEX400   DC    X'B3410012'
NUM400   DC    P'400'
*MCALL #=   809 LV= 2 VER400   RT1   CCE,INS400,HEX400
VER400   DS    0H
         CLC   INS400,HEX400
RT1_TEST400      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE400
         LTORG 
RT1_CCE400      DS 0H
*MEXIT #=   809 LV= 2 RT1
*MEXIT #=   808 LV= 1 ZOSOP
*MCALL #=   810 LV= 1  ZOSOP 'B342','LOAD AND TEST (extended BFP) ','LTX
               XBR','RRE C '
         JAS   R11,VER401
         USING *,R11
INS401   LTXBR R1,R2
HEX401   DC    X'B3420012'
NUM401   DC    P'401'
*MCALL #=   811 LV= 2 VER401   RT1   CCE,INS401,HEX401
VER401   DS    0H
         CLC   INS401,HEX401
RT1_TEST401      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE401
         LTORG 
RT1_CCE401      DS 0H
*MEXIT #=   811 LV= 2 RT1
*MEXIT #=   810 LV= 1 ZOSOP
*MCALL #=   812 LV= 1  ZOSOP 'B343','LOAD COMPLEMENT (extended BFP) ','X
               LCXBR','RRE C '
         JAS   R11,VER402
         USING *,R11
INS402   LCXBR R1,R2
HEX402   DC    X'B3430012'
NUM402   DC    P'402'
*MCALL #=   813 LV= 2 VER402   RT1   CCE,INS402,HEX402
VER402   DS    0H
         CLC   INS402,HEX402
RT1_TEST402      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE402
         LTORG 
RT1_CCE402      DS 0H
*MEXIT #=   813 LV= 2 RT1
*MEXIT #=   812 LV= 1 ZOSOP
*MCALL #=   814 LV= 1  ZOSOP 'B344','LOAD ROUNDED (long to short BFP) 'X
               ,'LEDBR?','RE3 '      RPI-1125
         JAS   R11,VER403
         USING *,R11
INS403   LEDBR R1,R2
HEX403   DC    X'B3440012'
INSA403  LEDBRA R1,M3,R2,M4
HEXA403  DC    X'B3443412'
*MCALL #=   815 LV= 2 VER403   RT1   CCE,INS403,HEX403
VER403   DS    0H
         CLC   INS403,HEX403
RT1_TEST403      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE403
         LTORG 
RT1_CCE403      DS 0H
*MEXIT #=   815 LV= 2 RT1
         L     R1,=A(INSA403)
         USING INSA403,R1
*MCALL #=   816 LV= 2          RT1   CCE,INSA403,HEXA403
         DS    0H
         CLC   INSA403,HEXA403
RT1_TEST404      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE404
         LTORG 
RT1_CCE404      DS 0H
*MEXIT #=   816 LV= 2 RT1
*MEXIT #=   814 LV= 1 ZOSOP
*MCALL #=   817 LV= 1  ZOSOP 'B345','LOAD ROUNDED (extended to long BFPX
               ) ','LDXBR?','RE3 '   RPI-1125
         JAS   R11,VER404
         USING *,R11
INS404   LDXBR R1,R2
HEX404   DC    X'B3450012'
INSA404  LDXBRA R1,M3,R2,M4
HEXA404  DC    X'B3453412'
*MCALL #=   818 LV= 2 VER404   RT1   CCE,INS404,HEX404
VER404   DS    0H
         CLC   INS404,HEX404
RT1_TEST405      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE405
         LTORG 
RT1_CCE405      DS 0H
*MEXIT #=   818 LV= 2 RT1
         L     R1,=A(INSA404)
         USING INSA404,R1
*MCALL #=   819 LV= 2          RT1   CCE,INSA404,HEXA404
         DS    0H
         CLC   INSA404,HEXA404
RT1_TEST406      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE406
         LTORG 
RT1_CCE406      DS 0H
*MEXIT #=   819 LV= 2 RT1
*MEXIT #=   817 LV= 1 ZOSOP
*MCALL #=   820 LV= 1  ZOSOP 'B346','LOAD ROUNDED (extended to short BFX
               P)','LEXBR?','RE3 '   RPI-1125
         JAS   R11,VER405
         USING *,R11
INS405   LEXBR R1,R2
HEX405   DC    X'B3460012'
INSA405  LEXBRA R1,M3,R2,M4
HEXA405  DC    X'B3463412'
*MCALL #=   821 LV= 2 VER405   RT1   CCE,INS405,HEX405
VER405   DS    0H
         CLC   INS405,HEX405
RT1_TEST407      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE407
         LTORG 
RT1_CCE407      DS 0H
*MEXIT #=   821 LV= 2 RT1
         L     R1,=A(INSA405)
         USING INSA405,R1
*MCALL #=   822 LV= 2          RT1   CCE,INSA405,HEXA405
         DS    0H
         CLC   INSA405,HEXA405
RT1_TEST408      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE408
         LTORG 
RT1_CCE408      DS 0H
*MEXIT #=   822 LV= 2 RT1
*MEXIT #=   820 LV= 1 ZOSOP
*MCALL #=   823 LV= 1  ZOSOP 'B347','LOAD FP INTEGER (extended BFP) ','X
               FIXBR?','RRF7'        RPI-1125
         JAS   R11,VER406
         USING *,R11
INS406   FIXBR R1,M3,R2
HEX406   DC    X'B3473012'
INSA406  FIXBRA R1,M3,R2,M4
HEXA406  DC    X'B3473412'
*MCALL #=   824 LV= 2 VER406   RT1   CCE,INS406,HEX406
VER406   DS    0H
         CLC   INS406,HEX406
RT1_TEST409      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE409
         LTORG 
RT1_CCE409      DS 0H
*MEXIT #=   824 LV= 2 RT1
         L     R1,=A(INSA406)
         USING INSA406,R1
*MCALL #=   825 LV= 2          RT1   CCE,INSA406,HEXA406
         DS    0H
         CLC   INSA406,HEXA406
RT1_TEST410      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE410
         LTORG 
RT1_CCE410      DS 0H
*MEXIT #=   825 LV= 2 RT1
*MEXIT #=   823 LV= 1 ZOSOP
*MCALL #=   826 LV= 1  ZOSOP 'B348','COMPARE AND SIGNAL (extended BFP) X
               ','KXBR ','RRE C '
         JAS   R11,VER407
         USING *,R11
INS407   KXBR  R1,R2
HEX407   DC    X'B3480012'
NUM407   DC    P'407'
*MCALL #=   827 LV= 2 VER407   RT1   CCE,INS407,HEX407
VER407   DS    0H
         CLC   INS407,HEX407
RT1_TEST411      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE411
         LTORG 
RT1_CCE411      DS 0H
*MEXIT #=   827 LV= 2 RT1
*MEXIT #=   826 LV= 1 ZOSOP
*MCALL #=   828 LV= 1  ZOSOP 'B349','COMPARE (extended BFP) ','CXBR ','X
               RRE C '
         JAS   R11,VER408
         USING *,R11
INS408   CXBR  R1,R2
HEX408   DC    X'B3490012'
NUM408   DC    P'408'
*MCALL #=   829 LV= 2 VER408   RT1   CCE,INS408,HEX408
VER408   DS    0H
         CLC   INS408,HEX408
RT1_TEST412      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE412
         LTORG 
RT1_CCE412      DS 0H
*MEXIT #=   829 LV= 2 RT1
*MEXIT #=   828 LV= 1 ZOSOP
*MCALL #=   830 LV= 1  ZOSOP 'B34A','ADD (extended BFP) ','AXBR ','RRE X
               C '
         JAS   R11,VER409
         USING *,R11
INS409   AXBR  R1,R2
HEX409   DC    X'B34A0012'
NUM409   DC    P'409'
*MCALL #=   831 LV= 2 VER409   RT1   CCE,INS409,HEX409
VER409   DS    0H
         CLC   INS409,HEX409
RT1_TEST413      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE413
         LTORG 
RT1_CCE413      DS 0H
*MEXIT #=   831 LV= 2 RT1
*MEXIT #=   830 LV= 1 ZOSOP
*MCALL #=   832 LV= 1  ZOSOP 'B34B','SUBTRACT (extended BFP) ','SXBR ',X
               'RRE C '
         JAS   R11,VER410
         USING *,R11
INS410   SXBR  R1,R2
HEX410   DC    X'B34B0012'
NUM410   DC    P'410'
*MCALL #=   833 LV= 2 VER410   RT1   CCE,INS410,HEX410
VER410   DS    0H
         CLC   INS410,HEX410
RT1_TEST414      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE414
         LTORG 
RT1_CCE414      DS 0H
*MEXIT #=   833 LV= 2 RT1
*MEXIT #=   832 LV= 1 ZOSOP
*MCALL #=   834 LV= 1  ZOSOP 'B34C','MULTIPLY (extended BFP) ','MXBR ',X
               'RRE '
         JAS   R11,VER411
         USING *,R11
INS411   MXBR  R1,R2
HEX411   DC    X'B34C0012'
NUM411   DC    P'411'
*MCALL #=   835 LV= 2 VER411   RT1   CCE,INS411,HEX411
VER411   DS    0H
         CLC   INS411,HEX411
RT1_TEST415      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE415
         LTORG 
RT1_CCE415      DS 0H
*MEXIT #=   835 LV= 2 RT1
*MEXIT #=   834 LV= 1 ZOSOP
*MCALL #=   836 LV= 1  ZOSOP 'B34D','DIVIDE (extended BFP) ','DXBR ','RX
               RE '
         JAS   R11,VER412
         USING *,R11
INS412   DXBR  R1,R2
HEX412   DC    X'B34D0012'
NUM412   DC    P'412'
*MCALL #=   837 LV= 2 VER412   RT1   CCE,INS412,HEX412
VER412   DS    0H
         CLC   INS412,HEX412
RT1_TEST416      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE416
         LTORG 
RT1_CCE416      DS 0H
*MEXIT #=   837 LV= 2 RT1
*MEXIT #=   836 LV= 1 ZOSOP
*MCALL #=   838 LV= 1  ZOSOP 'B350','CONVERT HFP TO BFP (long to short)X
                ','TBEDR','RRF2 C '
         JAS   R11,VER413
         USING *,R11
INS413   TBEDR R1,R3,R2
HEX413   DC    X'B3503012'
NUM413   DC    P'413'
*MCALL #=   839 LV= 2 VER413   RT1   CCE,INS413,HEX413
VER413   DS    0H
         CLC   INS413,HEX413
RT1_TEST417      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE417
         LTORG 
RT1_CCE417      DS 0H
*MEXIT #=   839 LV= 2 RT1
*MEXIT #=   838 LV= 1 ZOSOP
*MCALL #=   840 LV= 1  ZOSOP 'B351','CONVERT HFP TO BFP (long) ','TBDR X
               ','RRF2 C '
         JAS   R11,VER414
         USING *,R11
INS414   TBDR  R1,R3,R2
HEX414   DC    X'B3513012'
NUM414   DC    P'414'
*MCALL #=   841 LV= 2 VER414   RT1   CCE,INS414,HEX414
VER414   DS    0H
         CLC   INS414,HEX414
RT1_TEST418      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE418
         LTORG 
RT1_CCE418      DS 0H
*MEXIT #=   841 LV= 2 RT1
*MEXIT #=   840 LV= 1 ZOSOP
*MCALL #=   842 LV= 1  ZOSOP 'B353','DIVIDE TO INTEGER (short BFP) ','DX
               IEBR','RRF3 C '
         JAS   R11,VER415
         USING *,R11
INS415   DIEBR R1,R3,R2,M4
HEX415   DC    X'B3533412'
NUM415   DC    P'415'
*MCALL #=   843 LV= 2 VER415   RT1   CCE,INS415,HEX415
VER415   DS    0H
         CLC   INS415,HEX415
RT1_TEST419      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE419
         LTORG 
RT1_CCE419      DS 0H
*MEXIT #=   843 LV= 2 RT1
*MEXIT #=   842 LV= 1 ZOSOP
*MCALL #=   844 LV= 1  ZOSOP 'B357','LOAD FP INTEGER (short BFP) ','FIEX
               BR?','RRF7 ' RPI-1125
         JAS   R11,VER416
         USING *,R11
INS416   FIEBR R1,M3,R2
HEX416   DC    X'B3573012'
INSA416  FIEBRA R1,M3,R2,M4
HEXA416  DC    X'B3573412'
*MCALL #=   845 LV= 2 VER416   RT1   CCE,INS416,HEX416
VER416   DS    0H
         CLC   INS416,HEX416
RT1_TEST420      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE420
         LTORG 
RT1_CCE420      DS 0H
*MEXIT #=   845 LV= 2 RT1
         L     R1,=A(INSA416)
         USING INSA416,R1
*MCALL #=   846 LV= 2          RT1   CCE,INSA416,HEXA416
         DS    0H
         CLC   INSA416,HEXA416
RT1_TEST421      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE421
         LTORG 
RT1_CCE421      DS 0H
*MEXIT #=   846 LV= 2 RT1
*MEXIT #=   844 LV= 1 ZOSOP
*MCALL #=   847 LV= 1  ZOSOP 'B358','CONVERT BFP TO HFP (short to long)X
                ','THDER','RRE C '
         JAS   R11,VER417
         USING *,R11
INS417   THDER R1,R2
HEX417   DC    X'B3580012'
NUM417   DC    P'417'
*MCALL #=   848 LV= 2 VER417   RT1   CCE,INS417,HEX417
VER417   DS    0H
         CLC   INS417,HEX417
RT1_TEST422      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE422
         LTORG 
RT1_CCE422      DS 0H
*MEXIT #=   848 LV= 2 RT1
*MEXIT #=   847 LV= 1 ZOSOP
*MCALL #=   849 LV= 1  ZOSOP 'B359','CONVERT BFP TO HFP (long) ','THDR X
               ','RRE C '
         JAS   R11,VER418
         USING *,R11
INS418   THDR  R1,R2
HEX418   DC    X'B3590012'
NUM418   DC    P'418'
*MCALL #=   850 LV= 2 VER418   RT1   CCE,INS418,HEX418
VER418   DS    0H
         CLC   INS418,HEX418
RT1_TEST423      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE423
         LTORG 
RT1_CCE423      DS 0H
*MEXIT #=   850 LV= 2 RT1
*MEXIT #=   849 LV= 1 ZOSOP
*MCALL #=   851 LV= 1  ZOSOP 'B35B','DIVIDE TO INTEGER (long BFP) ','DIX
               DBR','RRF3 C '
         JAS   R11,VER419
         USING *,R11
INS419   DIDBR R1,R3,R2,M4
HEX419   DC    X'B35B3412'
NUM419   DC    P'419'
*MCALL #=   852 LV= 2 VER419   RT1   CCE,INS419,HEX419
VER419   DS    0H
         CLC   INS419,HEX419
RT1_TEST424      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE424
         LTORG 
RT1_CCE424      DS 0H
*MEXIT #=   852 LV= 2 RT1
*MEXIT #=   851 LV= 1 ZOSOP
*MCALL #=   853 LV= 1  ZOSOP 'B35F','LOAD FP INTEGER (long BFP) ','FIDBX
               R?','RRF7 ' RPI-1125
         JAS   R11,VER420
         USING *,R11
INS420   FIDBR R1,M3,R2
HEX420   DC    X'B35F3012'
INSA420  FIDBRA R1,M3,R2,M4
HEXA420  DC    X'B35F3412'
*MCALL #=   854 LV= 2 VER420   RT1   CCE,INS420,HEX420
VER420   DS    0H
         CLC   INS420,HEX420
RT1_TEST425      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE425
         LTORG 
RT1_CCE425      DS 0H
*MEXIT #=   854 LV= 2 RT1
         L     R1,=A(INSA420)
         USING INSA420,R1
*MCALL #=   855 LV= 2          RT1   CCE,INSA420,HEXA420
         DS    0H
         CLC   INSA420,HEXA420
RT1_TEST426      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE426
         LTORG 
RT1_CCE426      DS 0H
*MEXIT #=   855 LV= 2 RT1
*MEXIT #=   853 LV= 1 ZOSOP
*MCALL #=   856 LV= 1  ZOSOP 'B360','LOAD POSITIVE (extended HFP) ','LPX
               XR ','RRE C '
         JAS   R11,VER421
         USING *,R11
INS421   LPXR  R1,R2
HEX421   DC    X'B3600012'
NUM421   DC    P'421'
*MCALL #=   857 LV= 2 VER421   RT1   CCE,INS421,HEX421
VER421   DS    0H
         CLC   INS421,HEX421
RT1_TEST427      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE427
         LTORG 
RT1_CCE427      DS 0H
*MEXIT #=   857 LV= 2 RT1
*MEXIT #=   856 LV= 1 ZOSOP
*MCALL #=   858 LV= 1  ZOSOP 'B361','LOAD NEGATIVE (extended HFP) ','LNX
               XR ','RRE C '
         JAS   R11,VER422
         USING *,R11
INS422   LNXR  R1,R2
HEX422   DC    X'B3610012'
NUM422   DC    P'422'
*MCALL #=   859 LV= 2 VER422   RT1   CCE,INS422,HEX422
VER422   DS    0H
         CLC   INS422,HEX422
RT1_TEST428      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE428
         LTORG 
RT1_CCE428      DS 0H
*MEXIT #=   859 LV= 2 RT1
*MEXIT #=   858 LV= 1 ZOSOP
*MCALL #=   860 LV= 1  ZOSOP 'B362','LOAD AND TEST (extended HFP) ','LTX
               XR ','RRE C '
         JAS   R11,VER423
         USING *,R11
INS423   LTXR  R1,R2
HEX423   DC    X'B3620012'
NUM423   DC    P'423'
*MCALL #=   861 LV= 2 VER423   RT1   CCE,INS423,HEX423
VER423   DS    0H
         CLC   INS423,HEX423
RT1_TEST429      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE429
         LTORG 
RT1_CCE429      DS 0H
*MEXIT #=   861 LV= 2 RT1
*MEXIT #=   860 LV= 1 ZOSOP
*MCALL #=   862 LV= 1  ZOSOP 'B363','LOAD COMPLEMENT (extended HFP) ','X
               LCXR ','RRE C '
         JAS   R11,VER424
         USING *,R11
INS424   LCXR  R1,R2
HEX424   DC    X'B3630012'
NUM424   DC    P'424'
*MCALL #=   863 LV= 2 VER424   RT1   CCE,INS424,HEX424
VER424   DS    0H
         CLC   INS424,HEX424
RT1_TEST430      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE430
         LTORG 
RT1_CCE430      DS 0H
*MEXIT #=   863 LV= 2 RT1
*MEXIT #=   862 LV= 1 ZOSOP
*MCALL #=   864 LV= 1  ZOSOP 'B365','LOAD (extended) ','LXR ','RRE '
         JAS   R11,VER425
         USING *,R11
INS425   LXR  R1,R2
HEX425   DC    X'B3650012'
NUM425   DC    P'425'
*MCALL #=   865 LV= 2 VER425   RT1   CCE,INS425,HEX425
VER425   DS    0H
         CLC   INS425,HEX425
RT1_TEST431      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE431
         LTORG 
RT1_CCE431      DS 0H
*MEXIT #=   865 LV= 2 RT1
*MEXIT #=   864 LV= 1 ZOSOP
*MCALL #=   866 LV= 1  ZOSOP 'B366','LOAD ROUNDED (extended to short HFX
               P)','LEXR ','RRE '
         JAS   R11,VER426
         USING *,R11
INS426   LEXR  R1,R2
HEX426   DC    X'B3660012'
NUM426   DC    P'426'
*MCALL #=   867 LV= 2 VER426   RT1   CCE,INS426,HEX426
VER426   DS    0H
         CLC   INS426,HEX426
RT1_TEST432      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE432
         LTORG 
RT1_CCE432      DS 0H
*MEXIT #=   867 LV= 2 RT1
*MEXIT #=   866 LV= 1 ZOSOP
*MCALL #=   868 LV= 1  ZOSOP 'B367','LOAD FP INTEGER (extended HFP) ','X
               FIXR ','RRE '
         JAS   R11,VER427
         USING *,R11
INS427   FIXR  R1,R2
HEX427   DC    X'B3670012'
NUM427   DC    P'427'
*MCALL #=   869 LV= 2 VER427   RT1   CCE,INS427,HEX427
VER427   DS    0H
         CLC   INS427,HEX427
RT1_TEST433      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE433
         LTORG 
RT1_CCE433      DS 0H
*MEXIT #=   869 LV= 2 RT1
*MEXIT #=   868 LV= 1 ZOSOP
*MCALL #=   870 LV= 1  ZOSOP 'B369','COMPARE (extended HFP) ','CXR ','RX
               RE C '
         JAS   R11,VER428
         USING *,R11
INS428   CXR  R1,R2
HEX428   DC    X'B3690012'
NUM428   DC    P'428'
*MCALL #=   871 LV= 2 VER428   RT1   CCE,INS428,HEX428
VER428   DS    0H
         CLC   INS428,HEX428
RT1_TEST434      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE434
         LTORG 
RT1_CCE434      DS 0H
*MEXIT #=   871 LV= 2 RT1
*MEXIT #=   870 LV= 1 ZOSOP
*MCALL #=   872 LV= 1  ZOSOP 'B370','LOAD POSITIVE (long DFP) ','LPDFR'X
               ,'RRE ' DFP
         JAS   R11,VER429
         USING *,R11
INS429   LPDFR R1,R2
HEX429   DC    X'B3700012'
NUM429   DC    P'429'
*MCALL #=   873 LV= 2 VER429   RT1   CCE,INS429,HEX429
VER429   DS    0H
         CLC   INS429,HEX429
RT1_TEST435      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE435
         LTORG 
RT1_CCE435      DS 0H
*MEXIT #=   873 LV= 2 RT1
*MEXIT #=   872 LV= 1 ZOSOP
*MCALL #=   874 LV= 1  ZOSOP 'B371','LOAD NEGATIVE (long DFP) ','LNDFR'X
               ,'RRE ' DFP
         JAS   R11,VER430
         USING *,R11
INS430   LNDFR R1,R2
HEX430   DC    X'B3710012'
NUM430   DC    P'430'
*MCALL #=   875 LV= 2 VER430   RT1   CCE,INS430,HEX430
VER430   DS    0H
         CLC   INS430,HEX430
RT1_TEST436      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE436
         LTORG 
RT1_CCE436      DS 0H
*MEXIT #=   875 LV= 2 RT1
*MEXIT #=   874 LV= 1 ZOSOP
*MCALL #=   876 LV= 1  ZOSOP 'B372','LOAD POSITIVE (long DFP) ','CPSDR'X
               ,'RRF2' DFP
         JAS   R11,VER431
         USING *,R11
INS431   CPSDR R1,R3,R2
HEX431   DC    X'B3723012'
NUM431   DC    P'431'
*MCALL #=   877 LV= 2 VER431   RT1   CCE,INS431,HEX431
VER431   DS    0H
         CLC   INS431,HEX431
RT1_TEST437      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE437
         LTORG 
RT1_CCE437      DS 0H
*MEXIT #=   877 LV= 2 RT1
*MEXIT #=   876 LV= 1 ZOSOP
*MCALL #=   878 LV= 1  ZOSOP 'B373','LOAD COMPLIMENT (long DFP) ','LCDFX
               R','RRE ' DFP
         JAS   R11,VER432
         USING *,R11
INS432   LCDFR R1,R2
HEX432   DC    X'B3730012'
NUM432   DC    P'432'
*MCALL #=   879 LV= 2 VER432   RT1   CCE,INS432,HEX432
VER432   DS    0H
         CLC   INS432,HEX432
RT1_TEST438      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE438
         LTORG 
RT1_CCE438      DS 0H
*MEXIT #=   879 LV= 2 RT1
*MEXIT #=   878 LV= 1 ZOSOP
*MCALL #=   880 LV= 1  ZOSOP 'B374','LOAD ZERO (short) ','LZER ','RRE '
         JAS   R11,VER433
         USING *,R11
INS433   LZER  R1,R2
HEX433   DC    X'B3740012'
NUM433   DC    P'433'
*MCALL #=   881 LV= 2 VER433   RT1   CCE,INS433,HEX433
VER433   DS    0H
         CLC   INS433,HEX433
RT1_TEST439      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE439
         LTORG 
RT1_CCE439      DS 0H
*MEXIT #=   881 LV= 2 RT1
*MEXIT #=   880 LV= 1 ZOSOP
*MCALL #=   882 LV= 1  ZOSOP 'B375','LOAD ZERO (long) ','LZDR ','RRE '
         JAS   R11,VER434
         USING *,R11
INS434   LZDR  R1,R2
HEX434   DC    X'B3750012'
NUM434   DC    P'434'
*MCALL #=   883 LV= 2 VER434   RT1   CCE,INS434,HEX434
VER434   DS    0H
         CLC   INS434,HEX434
RT1_TEST440      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE440
         LTORG 
RT1_CCE440      DS 0H
*MEXIT #=   883 LV= 2 RT1
*MEXIT #=   882 LV= 1 ZOSOP
*MCALL #=   884 LV= 1  ZOSOP 'B376','LOAD ZERO (extended) ','LZXR ','RRX
               E '
         JAS   R11,VER435
         USING *,R11
INS435   LZXR  R1,R2
HEX435   DC    X'B3760012'
NUM435   DC    P'435'
*MCALL #=   885 LV= 2 VER435   RT1   CCE,INS435,HEX435
VER435   DS    0H
         CLC   INS435,HEX435
RT1_TEST441      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE441
         LTORG 
RT1_CCE441      DS 0H
*MEXIT #=   885 LV= 2 RT1
*MEXIT #=   884 LV= 1 ZOSOP
*MCALL #=   886 LV= 1  ZOSOP 'B377','LOAD FP INTEGER (short HFP) ','FIEX
               R ','RRE '
         JAS   R11,VER436
         USING *,R11
INS436   FIER  R1,R2
HEX436   DC    X'B3770012'
NUM436   DC    P'436'
*MCALL #=   887 LV= 2 VER436   RT1   CCE,INS436,HEX436
VER436   DS    0H
         CLC   INS436,HEX436
RT1_TEST442      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE442
         LTORG 
RT1_CCE442      DS 0H
*MEXIT #=   887 LV= 2 RT1
*MEXIT #=   886 LV= 1 ZOSOP
*MCALL #=   888 LV= 1  ZOSOP 'B37F','LOAD FP INTEGER (long HFP) ','FIDRX
                ','RRE '
         JAS   R11,VER437
         USING *,R11
INS437   FIDR  R1,R2
HEX437   DC    X'B37F0012'
NUM437   DC    P'437'
*MCALL #=   889 LV= 2 VER437   RT1   CCE,INS437,HEX437
VER437   DS    0H
         CLC   INS437,HEX437
RT1_TEST443      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE443
         LTORG 
RT1_CCE443      DS 0H
*MEXIT #=   889 LV= 2 RT1
*MEXIT #=   888 LV= 1 ZOSOP
*MCALL #=   890 LV= 1  ZOSOP 'B384','SET FPC ','SFPC ','RR2 '
         JAS   R11,VER438
         USING *,R11
INS438   SFPC  R1
HEX438   DC    X'B3840010'
NUM438   DC    P'438'
*MCALL #=   891 LV= 2 VER438   RT1   CCE,INS438,HEX438
VER438   DS    0H
         CLC   INS438,HEX438
RT1_TEST444      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE444
         LTORG 
RT1_CCE444      DS 0H
*MEXIT #=   891 LV= 2 RT1
*MEXIT #=   890 LV= 1 ZOSOP
*MCALL #=   892 LV= 1  ZOSOP 'B385','SET FPC AND SIGNAL','SFASR ','RR2 X
               ' DFP 57
         JAS   R11,VER439
         USING *,R11
INS439   SFASR  R1
HEX439   DC    X'B3850010'
NUM439   DC    P'439'
*MCALL #=   893 LV= 2 VER439   RT1   CCE,INS439,HEX439
VER439   DS    0H
         CLC   INS439,HEX439
RT1_TEST445      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE445
         LTORG 
RT1_CCE445      DS 0H
*MEXIT #=   893 LV= 2 RT1
*MEXIT #=   892 LV= 1 ZOSOP
*MCALL #=   894 LV= 1  ZOSOP 'B38C','EXTRACT FPC ','EFPC ','RR2 '
         JAS   R11,VER440
         USING *,R11
INS440   EFPC  R1
HEX440   DC    X'B38C0010'
NUM440   DC    P'440'
*MCALL #=   895 LV= 2 VER440   RT1   CCE,INS440,HEX440
VER440   DS    0H
         CLC   INS440,HEX440
RT1_TEST446      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE446
         LTORG 
RT1_CCE446      DS 0H
*MEXIT #=   895 LV= 2 RT1
*MEXIT #=   894 LV= 1 ZOSOP
*MCALL #=   896 LV= 1  ZOSOP 'B390','CONVERT FROM LOGICAL (32 to short X
               BFP)','CELFBR','RRF3'   RPI-1125 Z196
         JAS   R11,VER441
         USING *,R11
INS441   CELFBR R1,R3,R2,M4
HEX441   DC    X'B3903412'
NUM441   DC    P'441'
*MCALL #=   897 LV= 2 VER441   RT1   CCE,INS441,HEX441
VER441   DS    0H
         CLC   INS441,HEX441
RT1_TEST447      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE447
         LTORG 
RT1_CCE447      DS 0H
*MEXIT #=   897 LV= 2 RT1
*MEXIT #=   896 LV= 1 ZOSOP
*MCALL #=   898 LV= 1  ZOSOP 'B391','CONVERT FROM LOGICAL (32 to long BX
               FP)','CDLFBR','RRF3'   RPI-1125 Z196
         JAS   R11,VER442
         USING *,R11
INS442   CDLFBR R1,R3,R2,M4
HEX442   DC    X'B3913412'
NUM442   DC    P'442'
*MCALL #=   899 LV= 2 VER442   RT1   CCE,INS442,HEX442
VER442   DS    0H
         CLC   INS442,HEX442
RT1_TEST448      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE448
         LTORG 
RT1_CCE448      DS 0H
*MEXIT #=   899 LV= 2 RT1
*MEXIT #=   898 LV= 1 ZOSOP
*MCALL #=   900 LV= 1  ZOSOP 'B392','CONVERT FROM LOGICAL (32 to extendX
               ed BFP)','CXLFBR','RRF3'  RPI-1125 Z196
         JAS   R11,VER443
         USING *,R11
INS443   CXLFBR R1,R3,R2,M4
HEX443   DC    X'B3923412'
NUM443   DC    P'443'
*MCALL #=   901 LV= 2 VER443   RT1   CCE,INS443,HEX443
VER443   DS    0H
         CLC   INS443,HEX443
RT1_TEST449      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE449
         LTORG 
RT1_CCE449      DS 0H
*MEXIT #=   901 LV= 2 RT1
*MEXIT #=   900 LV= 1 ZOSOP
*MCALL #=   902 LV= 1  ZOSOP 'B394','CONVERT FROM FIXED (32 to short BFX
               P)','CEFBR?','RE3 '   RPI-1125 Z196
         JAS   R11,VER444
         USING *,R11
INS444   CEFBR R1,R2
HEX444   DC    X'B3940012'
INSA444  CEFBRA R1,M3,R2,M4
HEXA444  DC    X'B3943412'
*MCALL #=   903 LV= 2 VER444   RT1   CCE,INS444,HEX444
VER444   DS    0H
         CLC   INS444,HEX444
RT1_TEST450      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE450
         LTORG 
RT1_CCE450      DS 0H
*MEXIT #=   903 LV= 2 RT1
         L     R1,=A(INSA444)
         USING INSA444,R1
*MCALL #=   904 LV= 2          RT1   CCE,INSA444,HEXA444
         DS    0H
         CLC   INSA444,HEXA444
RT1_TEST451      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE451
         LTORG 
RT1_CCE451      DS 0H
*MEXIT #=   904 LV= 2 RT1
*MEXIT #=   902 LV= 1 ZOSOP
*MCALL #=   905 LV= 1  ZOSOP 'B395','CONVERT FROM FIXED (32 to long BFPX
               ) ','CDFBR?','RE3 '   RPI-1125 Z196
         JAS   R11,VER445
         USING *,R11
INS445   CDFBR R1,R2
HEX445   DC    X'B3950012'
INSA445  CDFBRA R1,M3,R2,M4
HEXA445  DC    X'B3953412'
*MCALL #=   906 LV= 2 VER445   RT1   CCE,INS445,HEX445
VER445   DS    0H
         CLC   INS445,HEX445
RT1_TEST452      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE452
         LTORG 
RT1_CCE452      DS 0H
*MEXIT #=   906 LV= 2 RT1
         L     R1,=A(INSA445)
         USING INSA445,R1
*MCALL #=   907 LV= 2          RT1   CCE,INSA445,HEXA445
         DS    0H
         CLC   INSA445,HEXA445
RT1_TEST453      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE453
         LTORG 
RT1_CCE453      DS 0H
*MEXIT #=   907 LV= 2 RT1
*MEXIT #=   905 LV= 1 ZOSOP
*MCALL #=   908 LV= 1  ZOSOP 'B396','CONVERT FROM FIXED (32 to ext. BFPX
               ) ','CXFBR?','RE3 '   RPI-1125 Z196
         JAS   R11,VER446
         USING *,R11
INS446   CXFBR R1,R2
HEX446   DC    X'B3960012'
INSA446  CXFBRA R1,M3,R2,M4
HEXA446  DC    X'B3963412'
*MCALL #=   909 LV= 2 VER446   RT1   CCE,INS446,HEX446
VER446   DS    0H
         CLC   INS446,HEX446
RT1_TEST454      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE454
         LTORG 
RT1_CCE454      DS 0H
*MEXIT #=   909 LV= 2 RT1
         L     R1,=A(INSA446)
         USING INSA446,R1
*MCALL #=   910 LV= 2          RT1   CCE,INSA446,HEXA446
         DS    0H
         CLC   INSA446,HEXA446
RT1_TEST455      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE455
         LTORG 
RT1_CCE455      DS 0H
*MEXIT #=   910 LV= 2 RT1
*MEXIT #=   908 LV= 1 ZOSOP
*MCALL #=   911 LV= 1  ZOSOP 'B398','CONVERT TO FIXED (short BFP to 32)X
                ','CFEBR?','RRF7 C ' RPI-1125 Z196
         JAS   R11,VER447
         USING *,R11
INS447   CFEBR R1,M3,R2
HEX447   DC    X'B3983012'
INSA447  CFEBRA R1,M3,R2,M4
HEXA447  DC    X'B3983412'
*MCALL #=   912 LV= 2 VER447   RT1   CCE,INS447,HEX447
VER447   DS    0H
         CLC   INS447,HEX447
RT1_TEST456      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE456
         LTORG 
RT1_CCE456      DS 0H
*MEXIT #=   912 LV= 2 RT1
         L     R1,=A(INSA447)
         USING INSA447,R1
*MCALL #=   913 LV= 2          RT1   CCE,INSA447,HEXA447
         DS    0H
         CLC   INSA447,HEXA447
RT1_TEST457      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE457
         LTORG 
RT1_CCE457      DS 0H
*MEXIT #=   913 LV= 2 RT1
*MEXIT #=   911 LV= 1 ZOSOP
*MCALL #=   914 LV= 1  ZOSOP 'B399','CONVERT TO FIXED (long BFP to 32) X
               ','CFDBR?','RRF7 C '  RPI-1125 Z196
         JAS   R11,VER448
         USING *,R11
INS448   CFDBR R1,M3,R2
HEX448   DC    X'B3993012'
INSA448  CFDBRA R1,M3,R2,M4
HEXA448  DC    X'B3993412'
*MCALL #=   915 LV= 2 VER448   RT1   CCE,INS448,HEX448
VER448   DS    0H
         CLC   INS448,HEX448
RT1_TEST458      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE458
         LTORG 
RT1_CCE458      DS 0H
*MEXIT #=   915 LV= 2 RT1
         L     R1,=A(INSA448)
         USING INSA448,R1
*MCALL #=   916 LV= 2          RT1   CCE,INSA448,HEXA448
         DS    0H
         CLC   INSA448,HEXA448
RT1_TEST459      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE459
         LTORG 
RT1_CCE459      DS 0H
*MEXIT #=   916 LV= 2 RT1
*MEXIT #=   914 LV= 1 ZOSOP
*MCALL #=   917 LV= 1  ZOSOP 'B39A','CONVERT TO FIXED (ext. BFP to 32) X
               ','CFXBR?','RRF7 C '  RPI-1125 Z196
         JAS   R11,VER449
         USING *,R11
INS449   CFXBR R1,M3,R2
HEX449   DC    X'B39A3012'
INSA449  CFXBRA R1,M3,R2,M4
HEXA449  DC    X'B39A3412'
*MCALL #=   918 LV= 2 VER449   RT1   CCE,INS449,HEX449
VER449   DS    0H
         CLC   INS449,HEX449
RT1_TEST460      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE460
         LTORG 
RT1_CCE460      DS 0H
*MEXIT #=   918 LV= 2 RT1
         L     R1,=A(INSA449)
         USING INSA449,R1
*MCALL #=   919 LV= 2          RT1   CCE,INSA449,HEXA449
         DS    0H
         CLC   INSA449,HEXA449
RT1_TEST461      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE461
         LTORG 
RT1_CCE461      DS 0H
*MEXIT #=   919 LV= 2 RT1
*MEXIT #=   917 LV= 1 ZOSOP
*MCALL #=   920 LV= 1  ZOSOP 'B39C','CONVERT TO LOGICAL (short BFP to 3X
               2)','CLFEBR','RRF3 '  RPI-1125 Z196
         JAS   R11,VER450
         USING *,R11
INS450   CLFEBR R1,R3,R2,M4
HEX450   DC    X'B39C3412'
NUM450   DC    P'450'
*MCALL #=   921 LV= 2 VER450   RT1   CCE,INS450,HEX450
VER450   DS    0H
         CLC   INS450,HEX450
RT1_TEST462      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE462
         LTORG 
RT1_CCE462      DS 0H
*MEXIT #=   921 LV= 2 RT1
*MEXIT #=   920 LV= 1 ZOSOP
*MCALL #=   922 LV= 1  ZOSOP 'B39D','CONVERT TO LOGICAL (long BFP to 32X
               )','CLFDBR','RRF3 '  RPI 1125 Z196
         JAS   R11,VER451
         USING *,R11
INS451   CLFDBR R1,R3,R2,M4
HEX451   DC    X'B39D3412'
NUM451   DC    P'451'
*MCALL #=   923 LV= 2 VER451   RT1   CCE,INS451,HEX451
VER451   DS    0H
         CLC   INS451,HEX451
RT1_TEST463      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE463
         LTORG 
RT1_CCE463      DS 0H
*MEXIT #=   923 LV= 2 RT1
*MEXIT #=   922 LV= 1 ZOSOP
*MCALL #=   924 LV= 1  ZOSOP 'B39E','CONVERT TO LOGICAL (extended BFP tX
               o 32)','CLFXBR','RRF3 '  RPI-1125 Z196
         JAS   R11,VER452
         USING *,R11
INS452   CLFXBR R1,R3,R2,M4
HEX452   DC    X'B39E3412'
NUM452   DC    P'452'
*MCALL #=   925 LV= 2 VER452   RT1   CCE,INS452,HEX452
VER452   DS    0H
         CLC   INS452,HEX452
RT1_TEST464      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE464
         LTORG 
RT1_CCE464      DS 0H
*MEXIT #=   925 LV= 2 RT1
*MEXIT #=   924 LV= 1 ZOSOP
*MCALL #=   926 LV= 1  ZOSOP 'B3A0','CONVERT FROM LOGICAL (64 to short X
               BFP)','CELGBR','RRF3 '  RPI-1125 Z196
         JAS   R11,VER453
         USING *,R11
INS453   CELGBR R1,R3,R2,M4
HEX453   DC    X'B3A03412'
NUM453   DC    P'453'
*MCALL #=   927 LV= 2 VER453   RT1   CCE,INS453,HEX453
VER453   DS    0H
         CLC   INS453,HEX453
RT1_TEST465      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE465
         LTORG 
RT1_CCE465      DS 0H
*MEXIT #=   927 LV= 2 RT1
*MEXIT #=   926 LV= 1 ZOSOP
*MCALL #=   928 LV= 1  ZOSOP 'B3A1','CONVERT FROM LOGICAL (64 to long BX
               FP)','CDLGBR','RRF3 '  RPI-1125 Z196
         JAS   R11,VER454
         USING *,R11
INS454   CDLGBR R1,R3,R2,M4
HEX454   DC    X'B3A13412'
NUM454   DC    P'454'
*MCALL #=   929 LV= 2 VER454   RT1   CCE,INS454,HEX454
VER454   DS    0H
         CLC   INS454,HEX454
RT1_TEST466      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE466
         LTORG 
RT1_CCE466      DS 0H
*MEXIT #=   929 LV= 2 RT1
*MEXIT #=   928 LV= 1 ZOSOP
*MCALL #=   930 LV= 1  ZOSOP 'B3A2','CONVERT FROM LOGICAL (64 to extendX
               ed BFP)','CXLGBR','RRF3 '  RPI-1125 Z196
         JAS   R11,VER455
         USING *,R11
INS455   CXLGBR R1,R3,R2,M4
HEX455   DC    X'B3A23412'
NUM455   DC    P'455'
*MCALL #=   931 LV= 2 VER455   RT1   CCE,INS455,HEX455
VER455   DS    0H
         CLC   INS455,HEX455
RT1_TEST467      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE467
         LTORG 
RT1_CCE467      DS 0H
*MEXIT #=   931 LV= 2 RT1
*MEXIT #=   930 LV= 1 ZOSOP
*MCALL #=   932 LV= 1  ZOSOP 'B3A4','CONVERT FROM FIXED (64 to short BFX
               P)','CEGBR?','RE3 N '
         JAS   R11,VER456
         USING *,R11
INS456   CEGBR R1,R2
HEX456   DC    X'B3A40012'
INSA456  CEGBRA R1,M3,R2,M4
HEXA456  DC    X'B3A43412'
*MCALL #=   933 LV= 2 VER456   RT1   CCE,INS456,HEX456
VER456   DS    0H
         CLC   INS456,HEX456
RT1_TEST468      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE468
         LTORG 
RT1_CCE468      DS 0H
*MEXIT #=   933 LV= 2 RT1
         L     R1,=A(INSA456)
         USING INSA456,R1
*MCALL #=   934 LV= 2          RT1   CCE,INSA456,HEXA456
         DS    0H
         CLC   INSA456,HEXA456
RT1_TEST469      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE469
         LTORG 
RT1_CCE469      DS 0H
*MEXIT #=   934 LV= 2 RT1
*MEXIT #=   932 LV= 1 ZOSOP
*MCALL #=   935 LV= 1  ZOSOP 'B3A5','CONVERT FROM FIXED (64 to long BFPX
               ) ','CDGBR?','RE3 N '
         JAS   R11,VER457
         USING *,R11
INS457   CDGBR R1,R2
HEX457   DC    X'B3A50012'
INSA457  CDGBRA R1,M3,R2,M4
HEXA457  DC    X'B3A53412'
*MCALL #=   936 LV= 2 VER457   RT1   CCE,INS457,HEX457
VER457   DS    0H
         CLC   INS457,HEX457
RT1_TEST470      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE470
         LTORG 
RT1_CCE470      DS 0H
*MEXIT #=   936 LV= 2 RT1
         L     R1,=A(INSA457)
         USING INSA457,R1
*MCALL #=   937 LV= 2          RT1   CCE,INSA457,HEXA457
         DS    0H
         CLC   INSA457,HEXA457
RT1_TEST471      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE471
         LTORG 
RT1_CCE471      DS 0H
*MEXIT #=   937 LV= 2 RT1
*MEXIT #=   935 LV= 1 ZOSOP
*MCALL #=   938 LV= 1  ZOSOP 'B3A6','CONVERT FROM FIXED (64 to ext. BFPX
               ) ','CXGBR?','RE3 N '
         JAS   R11,VER458
         USING *,R11
INS458   CXGBR R1,R2
HEX458   DC    X'B3A60012'
INSA458  CXGBRA R1,M3,R2,M4
HEXA458  DC    X'B3A63412'
*MCALL #=   939 LV= 2 VER458   RT1   CCE,INS458,HEX458
VER458   DS    0H
         CLC   INS458,HEX458
RT1_TEST472      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE472
         LTORG 
RT1_CCE472      DS 0H
*MEXIT #=   939 LV= 2 RT1
         L     R1,=A(INSA458)
         USING INSA458,R1
*MCALL #=   940 LV= 2          RT1   CCE,INSA458,HEXA458
         DS    0H
         CLC   INSA458,HEXA458
RT1_TEST473      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE473
         LTORG 
RT1_CCE473      DS 0H
*MEXIT #=   940 LV= 2 RT1
*MEXIT #=   938 LV= 1 ZOSOP
*MCALL #=   941 LV= 1  ZOSOP 'B3A8','CONVERT TO FIXED (short BFP to 64)X
                ','CGEBR?','RRF7 C N'
         JAS   R11,VER459
         USING *,R11
INS459   CGEBR R1,M3,R2
HEX459   DC    X'B3A83012'
INSA459  CGEBRA R1,M3,R2,M4
HEXA459  DC    X'B3A83412'
*MCALL #=   942 LV= 2 VER459   RT1   CCE,INS459,HEX459
VER459   DS    0H
         CLC   INS459,HEX459
RT1_TEST474      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE474
         LTORG 
RT1_CCE474      DS 0H
*MEXIT #=   942 LV= 2 RT1
         L     R1,=A(INSA459)
         USING INSA459,R1
*MCALL #=   943 LV= 2          RT1   CCE,INSA459,HEXA459
         DS    0H
         CLC   INSA459,HEXA459
RT1_TEST475      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE475
         LTORG 
RT1_CCE475      DS 0H
*MEXIT #=   943 LV= 2 RT1
*MEXIT #=   941 LV= 1 ZOSOP
*MCALL #=   944 LV= 1  ZOSOP 'B3A9','CONVERT TO FIXED (long BFP to 64) X
               ','CGDBR?','RRF7 C N '
         JAS   R11,VER460
         USING *,R11
INS460   CGDBR R1,M3,R2
HEX460   DC    X'B3A93012'
INSA460  CGDBRA R1,M3,R2,M4
HEXA460  DC    X'B3A93412'
*MCALL #=   945 LV= 2 VER460   RT1   CCE,INS460,HEX460
VER460   DS    0H
         CLC   INS460,HEX460
RT1_TEST476      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE476
         LTORG 
RT1_CCE476      DS 0H
*MEXIT #=   945 LV= 2 RT1
         L     R1,=A(INSA460)
         USING INSA460,R1
*MCALL #=   946 LV= 2          RT1   CCE,INSA460,HEXA460
         DS    0H
         CLC   INSA460,HEXA460
RT1_TEST477      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE477
         LTORG 
RT1_CCE477      DS 0H
*MEXIT #=   946 LV= 2 RT1
*MEXIT #=   944 LV= 1 ZOSOP
*MCALL #=   947 LV= 1  ZOSOP 'B3AA','CONVERT TO FIXED (ext. BFP to 64) X
               ','CGXBR?','RRF7 C N '
         JAS   R11,VER461
         USING *,R11
INS461   CGXBR R1,M3,R2
HEX461   DC    X'B3AA3012'
INSA461  CGXBRA R1,M3,R2,M4
HEXA461  DC    X'B3AA3412'
*MCALL #=   948 LV= 2 VER461   RT1   CCE,INS461,HEX461
VER461   DS    0H
         CLC   INS461,HEX461
RT1_TEST478      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE478
         LTORG 
RT1_CCE478      DS 0H
*MEXIT #=   948 LV= 2 RT1
         L     R1,=A(INSA461)
         USING INSA461,R1
*MCALL #=   949 LV= 2          RT1   CCE,INSA461,HEXA461
         DS    0H
         CLC   INSA461,HEXA461
RT1_TEST479      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE479
         LTORG 
RT1_CCE479      DS 0H
*MEXIT #=   949 LV= 2 RT1
*MEXIT #=   947 LV= 1 ZOSOP
*MCALL #=   950 LV= 1  ZOSOP 'B3AC','CONVERT TO LOGICAL (short BFP to 6X
               4)','CLGEBR','RRF3 '  RPI-1125 Z196
         JAS   R11,VER462
         USING *,R11
INS462   CLGEBR R1,R3,R2,M4
HEX462   DC    X'B3AC3412'
NUM462   DC    P'462'
*MCALL #=   951 LV= 2 VER462   RT1   CCE,INS462,HEX462
VER462   DS    0H
         CLC   INS462,HEX462
RT1_TEST480      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE480
         LTORG 
RT1_CCE480      DS 0H
*MEXIT #=   951 LV= 2 RT1
*MEXIT #=   950 LV= 1 ZOSOP
*MCALL #=   952 LV= 1  ZOSOP 'B3AD','CONVERT TO LOGICAL (long BFP to 64X
               )','CLGDBR','RRF3 '  RPI 1125 Z196
         JAS   R11,VER463
         USING *,R11
INS463   CLGDBR R1,R3,R2,M4
HEX463   DC    X'B3AD3412'
NUM463   DC    P'463'
*MCALL #=   953 LV= 2 VER463   RT1   CCE,INS463,HEX463
VER463   DS    0H
         CLC   INS463,HEX463
RT1_TEST481      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE481
         LTORG 
RT1_CCE481      DS 0H
*MEXIT #=   953 LV= 2 RT1
*MEXIT #=   952 LV= 1 ZOSOP
*MCALL #=   954 LV= 1  ZOSOP 'B3AE','CONVERT TO LOGICAL (extended BFP tX
               o 64)','CLGXBR','RRF3 '  RPI-1125 Z196
         JAS   R11,VER464
         USING *,R11
INS464   CLGXBR R1,R3,R2,M4
HEX464   DC    X'B3AE3412'
NUM464   DC    P'464'
*MCALL #=   955 LV= 2 VER464   RT1   CCE,INS464,HEX464
VER464   DS    0H
         CLC   INS464,HEX464
RT1_TEST482      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE482
         LTORG 
RT1_CCE482      DS 0H
*MEXIT #=   955 LV= 2 RT1
*MEXIT #=   954 LV= 1 ZOSOP
*MCALL #=   956 LV= 1  ZOSOP 'B3B4','CONVERT FROM FIXED (32 to short HFX
               P)','CEFR ','RRE '
         JAS   R11,VER465
         USING *,R11
INS465   CEFR  R1,R2
HEX465   DC    X'B3B40012'
NUM465   DC    P'465'
*MCALL #=   957 LV= 2 VER465   RT1   CCE,INS465,HEX465
VER465   DS    0H
         CLC   INS465,HEX465
RT1_TEST483      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE483
         LTORG 
RT1_CCE483      DS 0H
*MEXIT #=   957 LV= 2 RT1
*MEXIT #=   956 LV= 1 ZOSOP
*MCALL #=   958 LV= 1  ZOSOP 'B3B5','CONVERT FROM FIXED (32 to long HFPX
               ) ','CDFR ','RRE '
         JAS   R11,VER466
         USING *,R11
INS466   CDFR  R1,R2
HEX466   DC    X'B3B50012'
NUM466   DC    P'466'
*MCALL #=   959 LV= 2 VER466   RT1   CCE,INS466,HEX466
VER466   DS    0H
         CLC   INS466,HEX466
RT1_TEST484      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE484
         LTORG 
RT1_CCE484      DS 0H
*MEXIT #=   959 LV= 2 RT1
*MEXIT #=   958 LV= 1 ZOSOP
*MCALL #=   960 LV= 1  ZOSOP 'B3B6','CONVERT FROM FIXED (32 to ext. HFPX
               ) ','CXFR ','RRE '
         JAS   R11,VER467
         USING *,R11
INS467   CXFR  R1,R2
HEX467   DC    X'B3B60012'
NUM467   DC    P'467'
*MCALL #=   961 LV= 2 VER467   RT1   CCE,INS467,HEX467
VER467   DS    0H
         CLC   INS467,HEX467
RT1_TEST485      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE485
         LTORG 
RT1_CCE485      DS 0H
*MEXIT #=   961 LV= 2 RT1
*MEXIT #=   960 LV= 1 ZOSOP
*MCALL #=   962 LV= 1  ZOSOP 'B3B8','CONVERT TO FIXED (short HFP to 32)X
                ','CFER ','RRF2 C '
         JAS   R11,VER468
         USING *,R11
INS468   CFER  R1,R3,R2
HEX468   DC    X'B3B83012'
NUM468   DC    P'468'
*MCALL #=   963 LV= 2 VER468   RT1   CCE,INS468,HEX468
VER468   DS    0H
         CLC   INS468,HEX468
RT1_TEST486      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE486
         LTORG 
RT1_CCE486      DS 0H
*MEXIT #=   963 LV= 2 RT1
*MEXIT #=   962 LV= 1 ZOSOP
*MCALL #=   964 LV= 1  ZOSOP 'B3B9','CONVERT TO FIXED (long HFP to 32) X
               ','CFDR ','RRF2 C '
         JAS   R11,VER469
         USING *,R11
INS469   CFDR  R1,R3,R2
HEX469   DC    X'B3B93012'
NUM469   DC    P'469'
*MCALL #=   965 LV= 2 VER469   RT1   CCE,INS469,HEX469
VER469   DS    0H
         CLC   INS469,HEX469
RT1_TEST487      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE487
         LTORG 
RT1_CCE487      DS 0H
*MEXIT #=   965 LV= 2 RT1
*MEXIT #=   964 LV= 1 ZOSOP
*MCALL #=   966 LV= 1  ZOSOP 'B3BA','CONVERT TO FIXED (ext. HFP to 32) X
               ','CFXR ','RRF2 C '
         JAS   R11,VER470
         USING *,R11
INS470   CFXR  R1,R3,R2
HEX470   DC    X'B3BA3012'
NUM470   DC    P'470'
*MCALL #=   967 LV= 2 VER470   RT1   CCE,INS470,HEX470
VER470   DS    0H
         CLC   INS470,HEX470
RT1_TEST488      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE488
         LTORG 
RT1_CCE488      DS 0H
*MEXIT #=   967 LV= 2 RT1
*MEXIT #=   966 LV= 1 ZOSOP
*MCALL #=   968 LV= 1  ZOSOP 'B3C1','LOAD FP FROM GP (long DFP) ','LDGRX
               ','RRE ' DFP
         JAS   R11,VER471
         USING *,R11
INS471   LDGR R1,R2
HEX471   DC    X'B3C10012'
NUM471   DC    P'471'
*MCALL #=   969 LV= 2 VER471   RT1   CCE,INS471,HEX471
VER471   DS    0H
         CLC   INS471,HEX471
RT1_TEST489      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE489
         LTORG 
RT1_CCE489      DS 0H
*MEXIT #=   969 LV= 2 RT1
*MEXIT #=   968 LV= 1 ZOSOP
*MCALL #=   970 LV= 1  ZOSOP 'B3C4','CONVERT FROM FIXED (64 to short HFX
               P)','CEGR ','RRE N '
         JAS   R11,VER472
         USING *,R11
INS472   CEGR  R1,R2
HEX472   DC    X'B3C40012'
NUM472   DC    P'472'
*MCALL #=   971 LV= 2 VER472   RT1   CCE,INS472,HEX472
VER472   DS    0H
         CLC   INS472,HEX472
RT1_TEST490      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE490
         LTORG 
RT1_CCE490      DS 0H
*MEXIT #=   971 LV= 2 RT1
*MEXIT #=   970 LV= 1 ZOSOP
*MCALL #=   972 LV= 1  ZOSOP 'B3C5','CONVERT FROM FIXED (64 to long HFPX
               ) ','CDGR ','RRE N '
         JAS   R11,VER473
         USING *,R11
INS473   CDGR  R1,R2
HEX473   DC    X'B3C50012'
NUM473   DC    P'473'
*MCALL #=   973 LV= 2 VER473   RT1   CCE,INS473,HEX473
VER473   DS    0H
         CLC   INS473,HEX473
RT1_TEST491      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE491
         LTORG 
RT1_CCE491      DS 0H
*MEXIT #=   973 LV= 2 RT1
*MEXIT #=   972 LV= 1 ZOSOP
*MCALL #=   974 LV= 1  ZOSOP 'B3C6','CONVERT FROM FIXED (64 to ext. HFPX
               ) ','CXGR ','RRE N '
         JAS   R11,VER474
         USING *,R11
INS474   CXGR  R1,R2
HEX474   DC    X'B3C60012'
NUM474   DC    P'474'
*MCALL #=   975 LV= 2 VER474   RT1   CCE,INS474,HEX474
VER474   DS    0H
         CLC   INS474,HEX474
RT1_TEST492      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE492
         LTORG 
RT1_CCE492      DS 0H
*MEXIT #=   975 LV= 2 RT1
*MEXIT #=   974 LV= 1 ZOSOP
*MCALL #=   976 LV= 1  ZOSOP 'B3C8','CONVERT TO FIXED (short HFP to 64)X
                ','CGER ','RRF2 C N '
         JAS   R11,VER475
         USING *,R11
INS475   CGER  R1,R3,R2
HEX475   DC    X'B3C83012'
NUM475   DC    P'475'
*MCALL #=   977 LV= 2 VER475   RT1   CCE,INS475,HEX475
VER475   DS    0H
         CLC   INS475,HEX475
RT1_TEST493      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE493
         LTORG 
RT1_CCE493      DS 0H
*MEXIT #=   977 LV= 2 RT1
*MEXIT #=   976 LV= 1 ZOSOP
*MCALL #=   978 LV= 1  ZOSOP 'B3C9','CONVERT TO FIXED (long HFP to 64) X
               ','CGDR ','RRF2 C N '
         JAS   R11,VER476
         USING *,R11
INS476   CGDR  R1,R3,R2
HEX476   DC    X'B3C93012'
NUM476   DC    P'476'
*MCALL #=   979 LV= 2 VER476   RT1   CCE,INS476,HEX476
VER476   DS    0H
         CLC   INS476,HEX476
RT1_TEST494      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE494
         LTORG 
RT1_CCE494      DS 0H
*MEXIT #=   979 LV= 2 RT1
*MEXIT #=   978 LV= 1 ZOSOP
*MCALL #=   980 LV= 1  ZOSOP 'B3CA','CONVERT TO FIXED (ext. HFP to 64) X
               ','CGXR ','RRF2 C N '
         JAS   R11,VER477
         USING *,R11
INS477   CGXR  R1,R3,R2
HEX477   DC    X'B3CA3012'
NUM477   DC    P'477'
*MCALL #=   981 LV= 2 VER477   RT1   CCE,INS477,HEX477
VER477   DS    0H
         CLC   INS477,HEX477
RT1_TEST495      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE495
         LTORG 
RT1_CCE495      DS 0H
*MEXIT #=   981 LV= 2 RT1
*MEXIT #=   980 LV= 1 ZOSOP
*MCALL #=   982 LV= 1  ZOSOP 'B3CD','LOAD GP FROM FP (long DFP) ','LGDRX
               ','RRE ' DFP
         JAS   R11,VER478
         USING *,R11
INS478   LGDR R1,R2
HEX478   DC    X'B3CD0012'
NUM478   DC    P'478'
*MCALL #=   983 LV= 2 VER478   RT1   CCE,INS478,HEX478
VER478   DS    0H
         CLC   INS478,HEX478
RT1_TEST496      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE496
         LTORG 
RT1_CCE496      DS 0H
*MEXIT #=   983 LV= 2 RT1
*MEXIT #=   982 LV= 1 ZOSOP
*MCALL #=   984 LV= 1  ZOSOP 'B3D0','MULTIPLY (DDFP)','MDTR?','RRR2 ' DX
               FP  RPI-1125
         JAS   R11,VER479
         USING *,R11
INS479   MDTR  R1,R2,R3
HEX479   DC    X'B3D03012'
INSA479  MDTRA R1,R2,R3,M4
HEXA479  DC    X'B3D03412'
*MCALL #=   985 LV= 2 VER479   RT1   CCE,INS479,HEX479
VER479   DS    0H
         CLC   INS479,HEX479
RT1_TEST497      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE497
         LTORG 
RT1_CCE497      DS 0H
*MEXIT #=   985 LV= 2 RT1
         L     R1,=A(INSA479)
         USING INSA479,R1
*MCALL #=   986 LV= 2          RT1   CCE,INSA479,HEXA479
         DS    0H
         CLC   INSA479,HEXA479
RT1_TEST498      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE498
         LTORG 
RT1_CCE498      DS 0H
*MEXIT #=   986 LV= 2 RT1
*MEXIT #=   984 LV= 1 ZOSOP
*MCALL #=   987 LV= 1  ZOSOP 'B3D1','DIVIDE (DDFP)','DDTR?','RRR2 ' DFPX
                    RPI-1125
         JAS   R11,VER480
         USING *,R11
INS480   DDTR  R1,R2,R3
HEX480   DC    X'B3D13012'
INSA480  DDTRA R1,R2,R3,M4
HEXA480  DC    X'B3D13412'
*MCALL #=   988 LV= 2 VER480   RT1   CCE,INS480,HEX480
VER480   DS    0H
         CLC   INS480,HEX480
RT1_TEST499      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE499
         LTORG 
RT1_CCE499      DS 0H
*MEXIT #=   988 LV= 2 RT1
         L     R1,=A(INSA480)
         USING INSA480,R1
*MCALL #=   989 LV= 2          RT1   CCE,INSA480,HEXA480
         DS    0H
         CLC   INSA480,HEXA480
RT1_TEST500      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE500
         LTORG 
RT1_CCE500      DS 0H
*MEXIT #=   989 LV= 2 RT1
*MEXIT #=   987 LV= 1 ZOSOP
*MCALL #=   990 LV= 1  ZOSOP 'B3D2','ADD (DDFP)','ADTR?','RRR2 ' DFP   X
                   RPI-1125
         JAS   R11,VER481
         USING *,R11
INS481   ADTR  R1,R2,R3
HEX481   DC    X'B3D23012'
INSA481  ADTRA R1,R2,R3,M4
HEXA481  DC    X'B3D23412'
*MCALL #=   991 LV= 2 VER481   RT1   CCE,INS481,HEX481
VER481   DS    0H
         CLC   INS481,HEX481
RT1_TEST501      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE501
         LTORG 
RT1_CCE501      DS 0H
*MEXIT #=   991 LV= 2 RT1
         L     R1,=A(INSA481)
         USING INSA481,R1
*MCALL #=   992 LV= 2          RT1   CCE,INSA481,HEXA481
         DS    0H
         CLC   INSA481,HEXA481
RT1_TEST502      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE502
         LTORG 
RT1_CCE502      DS 0H
*MEXIT #=   992 LV= 2 RT1
*MEXIT #=   990 LV= 1 ZOSOP
*MCALL #=   993 LV= 1  ZOSOP 'B3D3','SUBTRACT (DDFP)','SDTR?','RRR2 ' DX
               FP  RPI-1125
         JAS   R11,VER482
         USING *,R11
INS482   SDTR  R1,R2,R3
HEX482   DC    X'B3D33012'
INSA482  SDTRA R1,R2,R3,M4
HEXA482  DC    X'B3D33412'
*MCALL #=   994 LV= 2 VER482   RT1   CCE,INS482,HEX482
VER482   DS    0H
         CLC   INS482,HEX482
RT1_TEST503      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE503
         LTORG 
RT1_CCE503      DS 0H
*MEXIT #=   994 LV= 2 RT1
         L     R1,=A(INSA482)
         USING INSA482,R1
*MCALL #=   995 LV= 2          RT1   CCE,INSA482,HEXA482
         DS    0H
         CLC   INSA482,HEXA482
RT1_TEST504      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE504
         LTORG 
RT1_CCE504      DS 0H
*MEXIT #=   995 LV= 2 RT1
*MEXIT #=   993 LV= 1 ZOSOP
*MCALL #=   996 LV= 1  ZOSOP 'B3D4','LOAD LENGTHENED (short>DDFP)','LDEX
               TR','RRF4' DFP
         JAS   R11,VER483
         USING *,R11
INS483   LDETR R1,R2,m4
HEX483   DC    X'B3D40412'
NUM483   DC    P'483'
*MCALL #=   997 LV= 2 VER483   RT1   CCE,INS483,HEX483
VER483   DS    0H
         CLC   INS483,HEX483
RT1_TEST505      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE505
         LTORG 
RT1_CCE505      DS 0H
*MEXIT #=   997 LV= 2 RT1
*MEXIT #=   996 LV= 1 ZOSOP
*MCALL #=   998 LV= 1  ZOSOP 'B3D5','LOAD ROUNDED (DDFP>EDFP)','LEDTR',X
               'RRF3' DFP
         JAS   R11,VER484
         USING *,R11
INS484   LEDTR R1,R3,R2,M4
HEX484   DC    X'B3D53412'
NUM484   DC    P'484'
*MCALL #=   999 LV= 2 VER484   RT1   CCE,INS484,HEX484
VER484   DS    0H
         CLC   INS484,HEX484
RT1_TEST506      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE506
         LTORG 
RT1_CCE506      DS 0H
*MEXIT #=   999 LV= 2 RT1
*MEXIT #=   998 LV= 1 ZOSOP
*MCALL #=  1000 LV= 1  ZOSOP 'B3D6','LOAD AND TEST (DDFP)','LTDTR','RREX
               ' DFP
         JAS   R11,VER485
         USING *,R11
INS485   LTDTR R1,R2
HEX485   DC    X'B3D60012'
NUM485   DC    P'485'
*MCALL #=  1001 LV= 2 VER485   RT1   CCE,INS485,HEX485
VER485   DS    0H
         CLC   INS485,HEX485
RT1_TEST507      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE507
         LTORG 
RT1_CCE507      DS 0H
*MEXIT #=  1001 LV= 2 RT1
*MEXIT #=  1000 LV= 1 ZOSOP
*MCALL #=  1002 LV= 1  ZOSOP 'B3D7','LOAD FP INTEGER (DDFP)','FIDTR','RX
               RF3' DFP
         JAS   R11,VER486
         USING *,R11
INS486   FIDTR R1,R3,R2,M4
HEX486   DC    X'B3D73412'
NUM486   DC    P'486'
*MCALL #=  1003 LV= 2 VER486   RT1   CCE,INS486,HEX486
VER486   DS    0H
         CLC   INS486,HEX486
RT1_TEST508      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE508
         LTORG 
RT1_CCE508      DS 0H
*MEXIT #=  1003 LV= 2 RT1
*MEXIT #=  1002 LV= 1 ZOSOP
*MCALL #=  1004 LV= 1  ZOSOP 'B3D8','MULTIPLY (LDFP)','MXTR?','RRR2 ' DX
               FP  RPI-1125
         JAS   R11,VER487
         USING *,R11
INS487   MXTR  R1,R2,R3
HEX487   DC    X'B3D83012'
INSA487  MXTRA R1,R2,R3,M4
HEXA487  DC    X'B3D83412'
*MCALL #=  1005 LV= 2 VER487   RT1   CCE,INS487,HEX487
VER487   DS    0H
         CLC   INS487,HEX487
RT1_TEST509      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE509
         LTORG 
RT1_CCE509      DS 0H
*MEXIT #=  1005 LV= 2 RT1
         L     R1,=A(INSA487)
         USING INSA487,R1
*MCALL #=  1006 LV= 2          RT1   CCE,INSA487,HEXA487
         DS    0H
         CLC   INSA487,HEXA487
RT1_TEST510      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE510
         LTORG 
RT1_CCE510      DS 0H
*MEXIT #=  1006 LV= 2 RT1
*MEXIT #=  1004 LV= 1 ZOSOP
*MCALL #=  1007 LV= 1  ZOSOP 'B3D9','DIVIDE (LDFP)','DXTR?','RRR2 ' DFPX
                   RPI-1125
         JAS   R11,VER488
         USING *,R11
INS488   DXTR  R1,R2,R3
HEX488   DC    X'B3D93012'
INSA488  DXTRA R1,R2,R3,M4
HEXA488  DC    X'B3D93412'
*MCALL #=  1008 LV= 2 VER488   RT1   CCE,INS488,HEX488
VER488   DS    0H
         CLC   INS488,HEX488
RT1_TEST511      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE511
         LTORG 
RT1_CCE511      DS 0H
*MEXIT #=  1008 LV= 2 RT1
         L     R1,=A(INSA488)
         USING INSA488,R1
*MCALL #=  1009 LV= 2          RT1   CCE,INSA488,HEXA488
         DS    0H
         CLC   INSA488,HEXA488
RT1_TEST512      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE512
         LTORG 
RT1_CCE512      DS 0H
*MEXIT #=  1009 LV= 2 RT1
*MEXIT #=  1007 LV= 1 ZOSOP
*MCALL #=  1010 LV= 1  ZOSOP 'B3DA','ADD (LDFP)','AXTR?','RRR2 ' DFP   X
                   RPI-1125
         JAS   R11,VER489
         USING *,R11
INS489   AXTR  R1,R2,R3
HEX489   DC    X'B3DA3012'
INSA489  AXTRA R1,R2,R3,M4
HEXA489  DC    X'B3DA3412'
*MCALL #=  1011 LV= 2 VER489   RT1   CCE,INS489,HEX489
VER489   DS    0H
         CLC   INS489,HEX489
RT1_TEST513      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE513
         LTORG 
RT1_CCE513      DS 0H
*MEXIT #=  1011 LV= 2 RT1
         L     R1,=A(INSA489)
         USING INSA489,R1
*MCALL #=  1012 LV= 2          RT1   CCE,INSA489,HEXA489
         DS    0H
         CLC   INSA489,HEXA489
RT1_TEST514      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE514
         LTORG 
RT1_CCE514      DS 0H
*MEXIT #=  1012 LV= 2 RT1
*MEXIT #=  1010 LV= 1 ZOSOP
*MCALL #=  1013 LV= 1  ZOSOP 'B3DB','SUBTRACT (LDFP)','SXTR?','RRR2 ' DX
               FP  RPI-1125
         JAS   R11,VER490
         USING *,R11
INS490   SXTR  R1,R2,R3
HEX490   DC    X'B3DB3012'
INSA490  SXTRA R1,R2,R3,M4
HEXA490  DC    X'B3DB3412'
*MCALL #=  1014 LV= 2 VER490   RT1   CCE,INS490,HEX490
VER490   DS    0H
         CLC   INS490,HEX490
RT1_TEST515      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE515
         LTORG 
RT1_CCE515      DS 0H
*MEXIT #=  1014 LV= 2 RT1
         L     R1,=A(INSA490)
         USING INSA490,R1
*MCALL #=  1015 LV= 2          RT1   CCE,INSA490,HEXA490
         DS    0H
         CLC   INSA490,HEXA490
RT1_TEST516      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE516
         LTORG 
RT1_CCE516      DS 0H
*MEXIT #=  1015 LV= 2 RT1
*MEXIT #=  1013 LV= 1 ZOSOP
*MCALL #=  1016 LV= 1  ZOSOP 'B3DC','LOAD LENGTHENED (long>LDFP)','LXDTX
               R','RRF4' DFP
         JAS   R11,VER491
         USING *,R11
INS491   LXDTR R1,R2,m4
HEX491   DC    X'B3DC0412'
NUM491   DC    P'491'
*MCALL #=  1017 LV= 2 VER491   RT1   CCE,INS491,HEX491
VER491   DS    0H
         CLC   INS491,HEX491
RT1_TEST517      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE517
         LTORG 
RT1_CCE517      DS 0H
*MEXIT #=  1017 LV= 2 RT1
*MEXIT #=  1016 LV= 1 ZOSOP
*MCALL #=  1018 LV= 1  ZOSOP 'B3DD','LOAD ROUNDED (LDFP>DDFP)','LDXTR',X
               'RRF3' DFP
         JAS   R11,VER492
         USING *,R11
INS492   LDXTR R1,R3,R2,M4
HEX492   DC    X'B3DD3412'
NUM492   DC    P'492'
*MCALL #=  1019 LV= 2 VER492   RT1   CCE,INS492,HEX492
VER492   DS    0H
         CLC   INS492,HEX492
RT1_TEST518      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE518
         LTORG 
RT1_CCE518      DS 0H
*MEXIT #=  1019 LV= 2 RT1
*MEXIT #=  1018 LV= 1 ZOSOP
*MCALL #=  1020 LV= 1  ZOSOP 'B3DE','LOAD AND TEST (LDFP)','LTXTR','RREX
               ' DFP
         JAS   R11,VER493
         USING *,R11
INS493   LTXTR R1,R2
HEX493   DC    X'B3DE0012'
NUM493   DC    P'493'
*MCALL #=  1021 LV= 2 VER493   RT1   CCE,INS493,HEX493
VER493   DS    0H
         CLC   INS493,HEX493
RT1_TEST519      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE519
         LTORG 
RT1_CCE519      DS 0H
*MEXIT #=  1021 LV= 2 RT1
*MEXIT #=  1020 LV= 1 ZOSOP
*MCALL #=  1022 LV= 1  ZOSOP 'B3DF','LOAD FP INTEGER (LDFP)','FIXTR','RX
               RF3' DFP
         JAS   R11,VER494
         USING *,R11
INS494   FIXTR R1,R3,R2,M4
HEX494   DC    X'B3DF3412'
NUM494   DC    P'494'
*MCALL #=  1023 LV= 2 VER494   RT1   CCE,INS494,HEX494
VER494   DS    0H
         CLC   INS494,HEX494
RT1_TEST520      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE520
         LTORG 
RT1_CCE520      DS 0H
*MEXIT #=  1023 LV= 2 RT1
*MEXIT #=  1022 LV= 1 ZOSOP
*MCALL #=  1024 LV= 1  ZOSOP 'B3E0','COMPARE AND SIGNAL (DDFP)','KDTR',X
               'RRE' DFP
         JAS   R11,VER495
         USING *,R11
INS495   KDTR R1,R2
HEX495   DC    X'B3E00012'
NUM495   DC    P'495'
*MCALL #=  1025 LV= 2 VER495   RT1   CCE,INS495,HEX495
VER495   DS    0H
         CLC   INS495,HEX495
RT1_TEST521      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE521
         LTORG 
RT1_CCE521      DS 0H
*MEXIT #=  1025 LV= 2 RT1
*MEXIT #=  1024 LV= 1 ZOSOP
*MCALL #=  1026 LV= 1  ZOSOP 'B3E1','CONVERT>FIXED (DDFP>64)','CGDTR?',X
               'RRF7' DFP RPI-1125
         JAS   R11,VER496
         USING *,R11
INS496   CGDTR R1,M3,R2
HEX496   DC    X'B3E13012'
INSA496  CGDTRA R1,M3,R2,M4
HEXA496  DC    X'B3E13412'
*MCALL #=  1027 LV= 2 VER496   RT1   CCE,INS496,HEX496
VER496   DS    0H
         CLC   INS496,HEX496
RT1_TEST522      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE522
         LTORG 
RT1_CCE522      DS 0H
*MEXIT #=  1027 LV= 2 RT1
         L     R1,=A(INSA496)
         USING INSA496,R1
*MCALL #=  1028 LV= 2          RT1   CCE,INSA496,HEXA496
         DS    0H
         CLC   INSA496,HEXA496
RT1_TEST523      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE523
         LTORG 
RT1_CCE523      DS 0H
*MEXIT #=  1028 LV= 2 RT1
*MEXIT #=  1026 LV= 1 ZOSOP
*MCALL #=  1029 LV= 1  ZOSOP 'B3E2','CONVERT>UNSIGNED BCD (DDFP>64)','CX
               UDTR','RRE' DFP
         JAS   R11,VER497
         USING *,R11
INS497   CUDTR R1,R2
HEX497   DC    X'B3E20012'
NUM497   DC    P'497'
*MCALL #=  1030 LV= 2 VER497   RT1   CCE,INS497,HEX497
VER497   DS    0H
         CLC   INS497,HEX497
RT1_TEST524      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE524
         LTORG 
RT1_CCE524      DS 0H
*MEXIT #=  1030 LV= 2 RT1
*MEXIT #=  1029 LV= 1 ZOSOP
*MCALL #=  1031 LV= 1  ZOSOP 'B3E3','CONVERT>SIGNED BCD (DDFP>64)','CSDX
               TR','RRF4' DFP
         JAS   R11,VER498
         USING *,R11
INS498   CSDTR R1,R2,m4
HEX498   DC    X'B3E30412'
NUM498   DC    P'498'
*MCALL #=  1032 LV= 2 VER498   RT1   CCE,INS498,HEX498
VER498   DS    0H
         CLC   INS498,HEX498
RT1_TEST525      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE525
         LTORG 
RT1_CCE525      DS 0H
*MEXIT #=  1032 LV= 2 RT1
*MEXIT #=  1031 LV= 1 ZOSOP
*MCALL #=  1033 LV= 1  ZOSOP 'B3E4','COMPARE (DDFP)','CDTR','RRE' DFP
         JAS   R11,VER499
         USING *,R11
INS499   CDTR R1,R2
HEX499   DC    X'B3E40012'
NUM499   DC    P'499'
*MCALL #=  1034 LV= 2 VER499   RT1   CCE,INS499,HEX499
VER499   DS    0H
         CLC   INS499,HEX499
RT1_TEST526      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE526
         LTORG 
RT1_CCE526      DS 0H
*MEXIT #=  1034 LV= 2 RT1
*MEXIT #=  1033 LV= 1 ZOSOP
*MCALL #=  1035 LV= 1  ZOSOP 'B3E5','EXTRACT BIASED EXPONENT (DDFP>64)'X
               ,'EEDTR','RRE' DFP
         JAS   R11,VER500
         USING *,R11
INS500   EEDTR R1,R2
HEX500   DC    X'B3E50012'
NUM500   DC    P'500'
*MCALL #=  1036 LV= 2 VER500   RT1   CCE,INS500,HEX500
VER500   DS    0H
         CLC   INS500,HEX500
RT1_TEST527      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE527
         LTORG 
RT1_CCE527      DS 0H
*MEXIT #=  1036 LV= 2 RT1
*MEXIT #=  1035 LV= 1 ZOSOP
*MCALL #=  1037 LV= 1  ZOSOP 'B3E7','EXTRACT SIGNIFICANCE (DDFP)','ESDTX
               R','RRE' DFP
         JAS   R11,VER501
         USING *,R11
INS501   ESDTR R1,R2
HEX501   DC    X'B3E70012'
NUM501   DC    P'501'
*MCALL #=  1038 LV= 2 VER501   RT1   CCE,INS501,HEX501
VER501   DS    0H
         CLC   INS501,HEX501
RT1_TEST528      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE528
         LTORG 
RT1_CCE528      DS 0H
*MEXIT #=  1038 LV= 2 RT1
*MEXIT #=  1037 LV= 1 ZOSOP
*MCALL #=  1039 LV= 1  ZOSOP 'B3E8','COMPARE AND SIGNAL (LDFP)','KXTR',X
               'RRE' DFP
         JAS   R11,VER502
         USING *,R11
INS502   KXTR R1,R2
HEX502   DC    X'B3E80012'
NUM502   DC    P'502'
*MCALL #=  1040 LV= 2 VER502   RT1   CCE,INS502,HEX502
VER502   DS    0H
         CLC   INS502,HEX502
RT1_TEST529      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE529
         LTORG 
RT1_CCE529      DS 0H
*MEXIT #=  1040 LV= 2 RT1
*MEXIT #=  1039 LV= 1 ZOSOP
*MCALL #=  1041 LV= 1  ZOSOP 'B3E9','CONVERT>FIXED (LDFP>64)','CGXTR?',X
               'RRF7' DFP RPI-1125
         JAS   R11,VER503
         USING *,R11
INS503   CGXTR R1,M3,R2
HEX503   DC    X'B3E93012'
INSA503  CGXTRA R1,M3,R2,M4
HEXA503  DC    X'B3E93412'
*MCALL #=  1042 LV= 2 VER503   RT1   CCE,INS503,HEX503
VER503   DS    0H
         CLC   INS503,HEX503
RT1_TEST530      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE530
         LTORG 
RT1_CCE530      DS 0H
*MEXIT #=  1042 LV= 2 RT1
         L     R1,=A(INSA503)
         USING INSA503,R1
*MCALL #=  1043 LV= 2          RT1   CCE,INSA503,HEXA503
         DS    0H
         CLC   INSA503,HEXA503
RT1_TEST531      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE531
         LTORG 
RT1_CCE531      DS 0H
*MEXIT #=  1043 LV= 2 RT1
*MEXIT #=  1041 LV= 1 ZOSOP
*MCALL #=  1044 LV= 1  ZOSOP 'B3EA','CONVERT>UNSIGNED BCD (LDFP>128)','X
               CUXTR','RRE' DFP
         JAS   R11,VER504
         USING *,R11
INS504   CUXTR R1,R2
HEX504   DC    X'B3EA0012'
NUM504   DC    P'504'
*MCALL #=  1045 LV= 2 VER504   RT1   CCE,INS504,HEX504
VER504   DS    0H
         CLC   INS504,HEX504
RT1_TEST532      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE532
         LTORG 
RT1_CCE532      DS 0H
*MEXIT #=  1045 LV= 2 RT1
*MEXIT #=  1044 LV= 1 ZOSOP
*MCALL #=  1046 LV= 1  ZOSOP 'B3EB','CONVERT>SIGNED BCD (LDFP>128)','CSX
               XTR','RRF4' DFP
         JAS   R11,VER505
         USING *,R11
INS505   CSXTR R1,R2,m4
HEX505   DC    X'B3EB0412'
NUM505   DC    P'505'
*MCALL #=  1047 LV= 2 VER505   RT1   CCE,INS505,HEX505
VER505   DS    0H
         CLC   INS505,HEX505
RT1_TEST533      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE533
         LTORG 
RT1_CCE533      DS 0H
*MEXIT #=  1047 LV= 2 RT1
*MEXIT #=  1046 LV= 1 ZOSOP
*MCALL #=  1048 LV= 1  ZOSOP 'B3EC','COMPARE (LDFP)','CXTR','RRE' DFP
         JAS   R11,VER506
         USING *,R11
INS506   CXTR R1,R2
HEX506   DC    X'B3EC0012'
NUM506   DC    P'506'
*MCALL #=  1049 LV= 2 VER506   RT1   CCE,INS506,HEX506
VER506   DS    0H
         CLC   INS506,HEX506
RT1_TEST534      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE534
         LTORG 
RT1_CCE534      DS 0H
*MEXIT #=  1049 LV= 2 RT1
*MEXIT #=  1048 LV= 1 ZOSOP
*MCALL #=  1050 LV= 1  ZOSOP 'B3ED','EXTRACT BIASED EXPONENT (LDFP>64)'X
               ,'EEXTR','RRE' DFP
         JAS   R11,VER507
         USING *,R11
INS507   EEXTR R1,R2
HEX507   DC    X'B3ED0012'
NUM507   DC    P'507'
*MCALL #=  1051 LV= 2 VER507   RT1   CCE,INS507,HEX507
VER507   DS    0H
         CLC   INS507,HEX507
RT1_TEST535      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE535
         LTORG 
RT1_CCE535      DS 0H
*MEXIT #=  1051 LV= 2 RT1
*MEXIT #=  1050 LV= 1 ZOSOP
*MCALL #=  1052 LV= 1  ZOSOP 'B3EF','EXTRACT SIGNIFICANCE (LDFP)','ESXTX
               R','RRE' DFP
         JAS   R11,VER508
         USING *,R11
INS508   ESXTR R1,R2
HEX508   DC    X'B3EF0012'
NUM508   DC    P'508'
*MCALL #=  1053 LV= 2 VER508   RT1   CCE,INS508,HEX508
VER508   DS    0H
         CLC   INS508,HEX508
RT1_TEST536      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE536
         LTORG 
RT1_CCE536      DS 0H
*MEXIT #=  1053 LV= 2 RT1
*MEXIT #=  1052 LV= 1 ZOSOP
*MCALL #=  1054 LV= 1  ZOSOP 'B3F1','CONVERT FROM FIXED (64>DDFP)','CDGX
               TR?','RE3' DFP        RPI-1125
         JAS   R11,VER509
         USING *,R11
INS509   CDGTR R1,R2
HEX509   DC    X'B3F10012'
INSA509  CDGTRA R1,M3,R2,M4
HEXA509  DC    X'B3F13412'
*MCALL #=  1055 LV= 2 VER509   RT1   CCE,INS509,HEX509
VER509   DS    0H
         CLC   INS509,HEX509
RT1_TEST537      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE537
         LTORG 
RT1_CCE537      DS 0H
*MEXIT #=  1055 LV= 2 RT1
         L     R1,=A(INSA509)
         USING INSA509,R1
*MCALL #=  1056 LV= 2          RT1   CCE,INSA509,HEXA509
         DS    0H
         CLC   INSA509,HEXA509
RT1_TEST538      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE538
         LTORG 
RT1_CCE538      DS 0H
*MEXIT #=  1056 LV= 2 RT1
*MEXIT #=  1054 LV= 1 ZOSOP
*MCALL #=  1057 LV= 1  ZOSOP 'B3F2','CONVERT FROM UNSIGNED BCD (64>DDFPX
               )','CDUTR','RRE' DFP
         JAS   R11,VER510
         USING *,R11
INS510   CDUTR R1,R2
HEX510   DC    X'B3F20012'
NUM510   DC    P'510'
*MCALL #=  1058 LV= 2 VER510   RT1   CCE,INS510,HEX510
VER510   DS    0H
         CLC   INS510,HEX510
RT1_TEST539      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE539
         LTORG 
RT1_CCE539      DS 0H
*MEXIT #=  1058 LV= 2 RT1
*MEXIT #=  1057 LV= 1 ZOSOP
*MCALL #=  1059 LV= 1  ZOSOP 'B3F3','CONVERT FROM SIGNED BCD (64>DDFP)'X
               ,'CDSTR','RRE' DFP
         JAS   R11,VER511
         USING *,R11
INS511   CDSTR R1,R2
HEX511   DC    X'B3F30012'
NUM511   DC    P'511'
*MCALL #=  1060 LV= 2 VER511   RT1   CCE,INS511,HEX511
VER511   DS    0H
         CLC   INS511,HEX511
RT1_TEST540      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE540
         LTORG 
RT1_CCE540      DS 0H
*MEXIT #=  1060 LV= 2 RT1
*MEXIT #=  1059 LV= 1 ZOSOP
*MCALL #=  1061 LV= 1  ZOSOP 'B3F4','COMPARE EXPONENT (DDFP)','CEDTR','X
               RRE' DFP
         JAS   R11,VER512
         USING *,R11
INS512   CEDTR R1,R2
HEX512   DC    X'B3F40012'
NUM512   DC    P'512'
*MCALL #=  1062 LV= 2 VER512   RT1   CCE,INS512,HEX512
VER512   DS    0H
         CLC   INS512,HEX512
RT1_TEST541      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE541
         LTORG 
RT1_CCE541      DS 0H
*MEXIT #=  1062 LV= 2 RT1
*MEXIT #=  1061 LV= 1 ZOSOP
*MCALL #=  1063 LV= 1  ZOSOP 'B3F5','QUANTIZE (DDFP)','QADTR','RRF3' DFX
               P
         JAS   R11,VER513
         USING *,R11
INS513   QADTR R1,R3,R2,M4
HEX513   DC    X'B3F53412'
NUM513   DC    P'513'
*MCALL #=  1064 LV= 2 VER513   RT1   CCE,INS513,HEX513
VER513   DS    0H
         CLC   INS513,HEX513
RT1_TEST542      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE542
         LTORG 
RT1_CCE542      DS 0H
*MEXIT #=  1064 LV= 2 RT1
*MEXIT #=  1063 LV= 1 ZOSOP
*MCALL #=  1065 LV= 1  ZOSOP 'B3F6','INSERT BIASED EXPONENT (64>DDFP)',X
               'IEDTR','RRF2' DFP
         JAS   R11,VER514
         USING *,R11
INS514   IEDTR R1,R3,R2
HEX514   DC    X'B3F63012'
NUM514   DC    P'514'
*MCALL #=  1066 LV= 2 VER514   RT1   CCE,INS514,HEX514
VER514   DS    0H
         CLC   INS514,HEX514
RT1_TEST543      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE543
         LTORG 
RT1_CCE543      DS 0H
*MEXIT #=  1066 LV= 2 RT1
*MEXIT #=  1065 LV= 1 ZOSOP
*MCALL #=  1067 LV= 1  ZOSOP 'B3F7','REROUND (DDFP)','RRDTR','RRF3' DFP
         JAS   R11,VER515
         USING *,R11
INS515   RRDTR R1,R3,R2,M4
HEX515   DC    X'B3F73412'
NUM515   DC    P'515'
*MCALL #=  1068 LV= 2 VER515   RT1   CCE,INS515,HEX515
VER515   DS    0H
         CLC   INS515,HEX515
RT1_TEST544      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE544
         LTORG 
RT1_CCE544      DS 0H
*MEXIT #=  1068 LV= 2 RT1
*MEXIT #=  1067 LV= 1 ZOSOP
*MCALL #=  1069 LV= 1  ZOSOP 'B3F9','CONVERT FROM FIXED (64>LDFP)','CXGX
               TR?','RE3' DFP        RPI-1125
         JAS   R11,VER516
         USING *,R11
INS516   CXGTR R1,R2
HEX516   DC    X'B3F90012'
INSA516  CXGTRA R1,M3,R2,M4
HEXA516  DC    X'B3F93412'
*MCALL #=  1070 LV= 2 VER516   RT1   CCE,INS516,HEX516
VER516   DS    0H
         CLC   INS516,HEX516
RT1_TEST545      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE545
         LTORG 
RT1_CCE545      DS 0H
*MEXIT #=  1070 LV= 2 RT1
         L     R1,=A(INSA516)
         USING INSA516,R1
*MCALL #=  1071 LV= 2          RT1   CCE,INSA516,HEXA516
         DS    0H
         CLC   INSA516,HEXA516
RT1_TEST546      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE546
         LTORG 
RT1_CCE546      DS 0H
*MEXIT #=  1071 LV= 2 RT1
*MEXIT #=  1069 LV= 1 ZOSOP
*MCALL #=  1072 LV= 1  ZOSOP 'B3FA','CONVERT FROM UNSIGNED BCD (128>LDFX
               P)','CXUTR','RRE' DFP
         JAS   R11,VER517
         USING *,R11
INS517   CXUTR R1,R2
HEX517   DC    X'B3FA0012'
NUM517   DC    P'517'
*MCALL #=  1073 LV= 2 VER517   RT1   CCE,INS517,HEX517
VER517   DS    0H
         CLC   INS517,HEX517
RT1_TEST547      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE547
         LTORG 
RT1_CCE547      DS 0H
*MEXIT #=  1073 LV= 2 RT1
*MEXIT #=  1072 LV= 1 ZOSOP
*MCALL #=  1074 LV= 1  ZOSOP 'B3FB','CONVERT FROM SIGNED BCD (128>LDFP)X
               ','CXSTR','RRE' DFP
         JAS   R11,VER518
         USING *,R11
INS518   CXSTR R1,R2
HEX518   DC    X'B3FB0012'
NUM518   DC    P'518'
*MCALL #=  1075 LV= 2 VER518   RT1   CCE,INS518,HEX518
VER518   DS    0H
         CLC   INS518,HEX518
RT1_TEST548      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE548
         LTORG 
RT1_CCE548      DS 0H
*MEXIT #=  1075 LV= 2 RT1
*MEXIT #=  1074 LV= 1 ZOSOP
*MCALL #=  1076 LV= 1  ZOSOP 'B3FC','COMPARE EXPONENT (LDFP)','CEXTR','X
               RRE' DFP
         JAS   R11,VER519
         USING *,R11
INS519   CEXTR R1,R2
HEX519   DC    X'B3FC0012'
NUM519   DC    P'519'
*MCALL #=  1077 LV= 2 VER519   RT1   CCE,INS519,HEX519
VER519   DS    0H
         CLC   INS519,HEX519
RT1_TEST549      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE549
         LTORG 
RT1_CCE549      DS 0H
*MEXIT #=  1077 LV= 2 RT1
*MEXIT #=  1076 LV= 1 ZOSOP
*MCALL #=  1078 LV= 1  ZOSOP 'B3FD','QUANTIZE (LDFP)','QAXTR','RRF3' DFX
               P
         JAS   R11,VER520
         USING *,R11
INS520   QAXTR R1,R3,R2,M4
HEX520   DC    X'B3FD3412'
NUM520   DC    P'520'
*MCALL #=  1079 LV= 2 VER520   RT1   CCE,INS520,HEX520
VER520   DS    0H
         CLC   INS520,HEX520
RT1_TEST550      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE550
         LTORG 
RT1_CCE550      DS 0H
*MEXIT #=  1079 LV= 2 RT1
*MEXIT #=  1078 LV= 1 ZOSOP
*MCALL #=  1080 LV= 1  ZOSOP 'B3FE','INSERT BIASED EXPONENT (64>LDFP)',X
               'IEXTR','RRF2' DFP
         JAS   R11,VER521
         USING *,R11
INS521   IEXTR R1,R3,R2
HEX521   DC    X'B3FE3012'
NUM521   DC    P'521'
*MCALL #=  1081 LV= 2 VER521   RT1   CCE,INS521,HEX521
VER521   DS    0H
         CLC   INS521,HEX521
RT1_TEST551      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE551
         LTORG 
RT1_CCE551      DS 0H
*MEXIT #=  1081 LV= 2 RT1
*MEXIT #=  1080 LV= 1 ZOSOP
*MCALL #=  1082 LV= 1  ZOSOP 'B3FF','REROUND (LDFP)','RRXTR','RRF3' DFP
         JAS   R11,VER522
         USING *,R11
INS522   RRXTR R1,R3,R2,M4
HEX522   DC    X'B3FF3412'
NUM522   DC    P'522'
*MCALL #=  1083 LV= 2 VER522   RT1   CCE,INS522,HEX522
VER522   DS    0H
         CLC   INS522,HEX522
RT1_TEST552      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE552
         LTORG 
RT1_CCE552      DS 0H
*MEXIT #=  1083 LV= 2 RT1
*MEXIT #=  1082 LV= 1 ZOSOP
*MCALL #=  1084 LV= 1  ZOSOP 'B6 ','STORE CONTROL (32) ','STCTL','RS '
         JAS   R11,VER523
         USING *,R11
INS523   STCTL R1,R3,S2
HEX523   DC    X'B613D002'
NUM523   DC    P'523'
*MCALL #=  1085 LV= 2 VER523   RT1   CCE,INS523,HEX523
VER523   DS    0H
         CLC   INS523,HEX523
RT1_TEST553      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE553
         LTORG 
RT1_CCE553      DS 0H
*MEXIT #=  1085 LV= 2 RT1
*MEXIT #=  1084 LV= 1 ZOSOP
*MCALL #=  1086 LV= 1  ZOSOP 'B7 ','LOAD CONTROL (32) ','LCTL ','RS '
         JAS   R11,VER524
         USING *,R11
INS524   LCTL  R1,R3,S2
HEX524   DC    X'B713D002'
NUM524   DC    P'524'
*MCALL #=  1087 LV= 2 VER524   RT1   CCE,INS524,HEX524
VER524   DS    0H
         CLC   INS524,HEX524
RT1_TEST554      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE554
         LTORG 
RT1_CCE554      DS 0H
*MEXIT #=  1087 LV= 2 RT1
*MEXIT #=  1086 LV= 1 ZOSOP
*MCALL #=  1088 LV= 1  ZOSOP 'B900','LOAD POSITIVE (64) ','LPGR ','RRE X
               C N '
         JAS   R11,VER525
         USING *,R11
INS525   LPGR  R1,R2
HEX525   DC    X'B9000012'
NUM525   DC    P'525'
*MCALL #=  1089 LV= 2 VER525   RT1   CCE,INS525,HEX525
VER525   DS    0H
         CLC   INS525,HEX525
RT1_TEST555      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE555
         LTORG 
RT1_CCE555      DS 0H
*MEXIT #=  1089 LV= 2 RT1
*MEXIT #=  1088 LV= 1 ZOSOP
*MCALL #=  1090 LV= 1  ZOSOP 'B901','LOAD NEGATIVE (64) ','LNGR ','RRE X
               C N '
         JAS   R11,VER526
         USING *,R11
INS526   LNGR  R1,R2
HEX526   DC    X'B9010012'
NUM526   DC    P'526'
*MCALL #=  1091 LV= 2 VER526   RT1   CCE,INS526,HEX526
VER526   DS    0H
         CLC   INS526,HEX526
RT1_TEST556      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE556
         LTORG 
RT1_CCE556      DS 0H
*MEXIT #=  1091 LV= 2 RT1
*MEXIT #=  1090 LV= 1 ZOSOP
*MCALL #=  1092 LV= 1  ZOSOP 'B902','LOAD AND TEST (64) ','LTGR ','RRE X
               C N '
         JAS   R11,VER527
         USING *,R11
INS527   LTGR  R1,R2
HEX527   DC    X'B9020012'
NUM527   DC    P'527'
*MCALL #=  1093 LV= 2 VER527   RT1   CCE,INS527,HEX527
VER527   DS    0H
         CLC   INS527,HEX527
RT1_TEST557      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE557
         LTORG 
RT1_CCE557      DS 0H
*MEXIT #=  1093 LV= 2 RT1
*MEXIT #=  1092 LV= 1 ZOSOP
*MCALL #=  1094 LV= 1  ZOSOP 'B903','LOAD COMPLEMENT (64) ','LCGR ','RRX
               E C N '
         JAS   R11,VER528
         USING *,R11
INS528   LCGR  R1,R2
HEX528   DC    X'B9030012'
NUM528   DC    P'528'
*MCALL #=  1095 LV= 2 VER528   RT1   CCE,INS528,HEX528
VER528   DS    0H
         CLC   INS528,HEX528
RT1_TEST558      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE558
         LTORG 
RT1_CCE558      DS 0H
*MEXIT #=  1095 LV= 2 RT1
*MEXIT #=  1094 LV= 1 ZOSOP
*MCALL #=  1096 LV= 1  ZOSOP 'B904','LOAD (64) ','LGR ','RRE N '
         JAS   R11,VER529
         USING *,R11
INS529   LGR  R1,R2
HEX529   DC    X'B9040012'
NUM529   DC    P'529'
*MCALL #=  1097 LV= 2 VER529   RT1   CCE,INS529,HEX529
VER529   DS    0H
         CLC   INS529,HEX529
RT1_TEST559      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE559
         LTORG 
RT1_CCE559      DS 0H
*MEXIT #=  1097 LV= 2 RT1
*MEXIT #=  1096 LV= 1 ZOSOP
*MCALL #=  1098 LV= 1  ZOSOP 'B905','LOAD USING REAL ADDRESS (64) ','LUX
               RAG','RRE N '
         JAS   R11,VER530
         USING *,R11
INS530   LURAG R1,R2
HEX530   DC    X'B9050012'
NUM530   DC    P'530'
*MCALL #=  1099 LV= 2 VER530   RT1   CCE,INS530,HEX530
VER530   DS    0H
         CLC   INS530,HEX530
RT1_TEST560      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE560
         LTORG 
RT1_CCE560      DS 0H
*MEXIT #=  1099 LV= 2 RT1
*MEXIT #=  1098 LV= 1 ZOSOP
*MCALL #=  1100 LV= 1  ZOSOP 'B906','LOAD BYTE','LGBR','RRE',Z9
         JAS   R11,VER531
         USING *,R11
INS531   LGBR R1,R2
HEX531   DC    X'B9060012'
NUM531   DC    P'531'
*MCALL #=  1101 LV= 2 VER531   RT1   CCE,INS531,HEX531
VER531   DS    0H
         CLC   INS531,HEX531
RT1_TEST561      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE561
         LTORG 
RT1_CCE561      DS 0H
*MEXIT #=  1101 LV= 2 RT1
*MEXIT #=  1100 LV= 1 ZOSOP
*MCALL #=  1102 LV= 1  ZOSOP 'B907','LOAD HALFWORD','LGHR','RRE',Z9
         JAS   R11,VER532
         USING *,R11
INS532   LGHR R1,R2
HEX532   DC    X'B9070012'
NUM532   DC    P'532'
*MCALL #=  1103 LV= 2 VER532   RT1   CCE,INS532,HEX532
VER532   DS    0H
         CLC   INS532,HEX532
RT1_TEST562      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE562
         LTORG 
RT1_CCE562      DS 0H
*MEXIT #=  1103 LV= 2 RT1
*MEXIT #=  1102 LV= 1 ZOSOP
*MCALL #=  1104 LV= 1  ZOSOP 'B908','ADD (64) ','AGR ','RRE C N '
         JAS   R11,VER533
         USING *,R11
INS533   AGR  R1,R2
HEX533   DC    X'B9080012'
NUM533   DC    P'533'
*MCALL #=  1105 LV= 2 VER533   RT1   CCE,INS533,HEX533
VER533   DS    0H
         CLC   INS533,HEX533
RT1_TEST563      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE563
         LTORG 
RT1_CCE563      DS 0H
*MEXIT #=  1105 LV= 2 RT1
*MEXIT #=  1104 LV= 1 ZOSOP
*MCALL #=  1106 LV= 1  ZOSOP 'B909','SUBTRACT (64) ','SGR ','RRE C N '
         JAS   R11,VER534
         USING *,R11
INS534   SGR  R1,R2
HEX534   DC    X'B9090012'
NUM534   DC    P'534'
*MCALL #=  1107 LV= 2 VER534   RT1   CCE,INS534,HEX534
VER534   DS    0H
         CLC   INS534,HEX534
RT1_TEST564      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE564
         LTORG 
RT1_CCE564      DS 0H
*MEXIT #=  1107 LV= 2 RT1
*MEXIT #=  1106 LV= 1 ZOSOP
*MCALL #=  1108 LV= 1  ZOSOP 'B90A','ADD LOGICAL (64) ','ALGR ','RRE C X
               N '
         JAS   R11,VER535
         USING *,R11
INS535   ALGR  R1,R2
HEX535   DC    X'B90A0012'
NUM535   DC    P'535'
*MCALL #=  1109 LV= 2 VER535   RT1   CCE,INS535,HEX535
VER535   DS    0H
         CLC   INS535,HEX535
RT1_TEST565      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE565
         LTORG 
RT1_CCE565      DS 0H
*MEXIT #=  1109 LV= 2 RT1
*MEXIT #=  1108 LV= 1 ZOSOP
*MCALL #=  1110 LV= 1  ZOSOP 'B90B','SUBTRACT LOGICAL (64) ','SLGR ','RX
               RE C N '
         JAS   R11,VER536
         USING *,R11
INS536   SLGR  R1,R2
HEX536   DC    X'B90B0012'
NUM536   DC    P'536'
*MCALL #=  1111 LV= 2 VER536   RT1   CCE,INS536,HEX536
VER536   DS    0H
         CLC   INS536,HEX536
RT1_TEST566      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE566
         LTORG 
RT1_CCE566      DS 0H
*MEXIT #=  1111 LV= 2 RT1
*MEXIT #=  1110 LV= 1 ZOSOP
*MCALL #=  1112 LV= 1  ZOSOP 'B90C','MULTIPLY SINGLE (64) ','MSGR ','RRX
               E N '
         JAS   R11,VER537
         USING *,R11
INS537   MSGR  R1,R2
HEX537   DC    X'B90C0012'
NUM537   DC    P'537'
*MCALL #=  1113 LV= 2 VER537   RT1   CCE,INS537,HEX537
VER537   DS    0H
         CLC   INS537,HEX537
RT1_TEST567      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE567
         LTORG 
RT1_CCE567      DS 0H
*MEXIT #=  1113 LV= 2 RT1
*MEXIT #=  1112 LV= 1 ZOSOP
*MCALL #=  1114 LV= 1  ZOSOP 'B90D','DIVIDE SINGLE (64) ','DSGR ','RRE X
               N '
         JAS   R11,VER538
         USING *,R11
INS538   DSGR  R1,R2
HEX538   DC    X'B90D0012'
NUM538   DC    P'538'
*MCALL #=  1115 LV= 2 VER538   RT1   CCE,INS538,HEX538
VER538   DS    0H
         CLC   INS538,HEX538
RT1_TEST568      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE568
         LTORG 
RT1_CCE568      DS 0H
*MEXIT #=  1115 LV= 2 RT1
*MEXIT #=  1114 LV= 1 ZOSOP
*MCALL #=  1116 LV= 1  ZOSOP 'B90E','EXTRACT STACKED REGISTERS (64) ','X
               EREGG','RRE N '
         JAS   R11,VER539
         USING *,R11
INS539   EREGG R1,R2
HEX539   DC    X'B90E0012'
NUM539   DC    P'539'
*MCALL #=  1117 LV= 2 VER539   RT1   CCE,INS539,HEX539
VER539   DS    0H
         CLC   INS539,HEX539
RT1_TEST569      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE569
         LTORG 
RT1_CCE569      DS 0H
*MEXIT #=  1117 LV= 2 RT1
*MEXIT #=  1116 LV= 1 ZOSOP
*MCALL #=  1118 LV= 1  ZOSOP 'B90F','LOAD REVERSED (64) ','LRVGR','RRE X
               N '
         JAS   R11,VER540
         USING *,R11
INS540   LRVGR R1,R2
HEX540   DC    X'B90F0012'
NUM540   DC    P'540'
*MCALL #=  1119 LV= 2 VER540   RT1   CCE,INS540,HEX540
VER540   DS    0H
         CLC   INS540,HEX540
RT1_TEST570      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE570
         LTORG 
RT1_CCE570      DS 0H
*MEXIT #=  1119 LV= 2 RT1
*MEXIT #=  1118 LV= 1 ZOSOP
*MCALL #=  1120 LV= 1  ZOSOP 'B910','LOAD POSITIVE (64<32) ','LPGFR','RX
               RE C N '
         JAS   R11,VER541
         USING *,R11
INS541   LPGFR R1,R2
HEX541   DC    X'B9100012'
NUM541   DC    P'541'
*MCALL #=  1121 LV= 2 VER541   RT1   CCE,INS541,HEX541
VER541   DS    0H
         CLC   INS541,HEX541
RT1_TEST571      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE571
         LTORG 
RT1_CCE571      DS 0H
*MEXIT #=  1121 LV= 2 RT1
*MEXIT #=  1120 LV= 1 ZOSOP
*MCALL #=  1122 LV= 1  ZOSOP 'B911','LOAD NEGATIVE (64<32) ','LNGFR','RX
               RE C N '
         JAS   R11,VER542
         USING *,R11
INS542   LNGFR R1,R2
HEX542   DC    X'B9110012'
NUM542   DC    P'542'
*MCALL #=  1123 LV= 2 VER542   RT1   CCE,INS542,HEX542
VER542   DS    0H
         CLC   INS542,HEX542
RT1_TEST572      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE572
         LTORG 
RT1_CCE572      DS 0H
*MEXIT #=  1123 LV= 2 RT1
*MEXIT #=  1122 LV= 1 ZOSOP
*MCALL #=  1124 LV= 1  ZOSOP 'B912','LOAD AND TEST (64<32) ','LTGFR','RX
               RE C N '
         JAS   R11,VER543
         USING *,R11
INS543   LTGFR R1,R2
HEX543   DC    X'B9120012'
NUM543   DC    P'543'
*MCALL #=  1125 LV= 2 VER543   RT1   CCE,INS543,HEX543
VER543   DS    0H
         CLC   INS543,HEX543
RT1_TEST573      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE573
         LTORG 
RT1_CCE573      DS 0H
*MEXIT #=  1125 LV= 2 RT1
*MEXIT #=  1124 LV= 1 ZOSOP
*MCALL #=  1126 LV= 1  ZOSOP 'B913','LOAD COMPLEMENT (64<32) ','LCGFR',X
               'RRE C N '
         JAS   R11,VER544
         USING *,R11
INS544   LCGFR R1,R2
HEX544   DC    X'B9130012'
NUM544   DC    P'544'
*MCALL #=  1127 LV= 2 VER544   RT1   CCE,INS544,HEX544
VER544   DS    0H
         CLC   INS544,HEX544
RT1_TEST574      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE574
         LTORG 
RT1_CCE574      DS 0H
*MEXIT #=  1127 LV= 2 RT1
*MEXIT #=  1126 LV= 1 ZOSOP
*MCALL #=  1128 LV= 1  ZOSOP 'B914','LOAD (64<32) ','LGFR ','RRE N '
         JAS   R11,VER545
         USING *,R11
INS545   LGFR  R1,R2
HEX545   DC    X'B9140012'
NUM545   DC    P'545'
*MCALL #=  1129 LV= 2 VER545   RT1   CCE,INS545,HEX545
VER545   DS    0H
         CLC   INS545,HEX545
RT1_TEST575      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE575
         LTORG 
RT1_CCE575      DS 0H
*MEXIT #=  1129 LV= 2 RT1
*MEXIT #=  1128 LV= 1 ZOSOP
*MCALL #=  1130 LV= 1  ZOSOP 'B916','LOAD LOGICAL (64<32) ','LLGFR','RRX
               E N '
         JAS   R11,VER546
         USING *,R11
INS546   LLGFR R1,R2
HEX546   DC    X'B9160012'
NUM546   DC    P'546'
*MCALL #=  1131 LV= 2 VER546   RT1   CCE,INS546,HEX546
VER546   DS    0H
         CLC   INS546,HEX546
RT1_TEST576      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE576
         LTORG 
RT1_CCE576      DS 0H
*MEXIT #=  1131 LV= 2 RT1
*MEXIT #=  1130 LV= 1 ZOSOP
*MCALL #=  1132 LV= 1  ZOSOP 'B917','LOAD LOGICAL THIRTY ONE BITS ','LLX
               GTR','RRE N '
         JAS   R11,VER547
         USING *,R11
INS547   LLGTR R1,R2
HEX547   DC    X'B9170012'
NUM547   DC    P'547'
*MCALL #=  1133 LV= 2 VER547   RT1   CCE,INS547,HEX547
VER547   DS    0H
         CLC   INS547,HEX547
RT1_TEST577      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE577
         LTORG 
RT1_CCE577      DS 0H
*MEXIT #=  1133 LV= 2 RT1
*MEXIT #=  1132 LV= 1 ZOSOP
*MCALL #=  1134 LV= 1  ZOSOP 'B918','ADD (64<32) ','AGFR ','RRE C N '
         JAS   R11,VER548
         USING *,R11
INS548   AGFR  R1,R2
HEX548   DC    X'B9180012'
NUM548   DC    P'548'
*MCALL #=  1135 LV= 2 VER548   RT1   CCE,INS548,HEX548
VER548   DS    0H
         CLC   INS548,HEX548
RT1_TEST578      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE578
         LTORG 
RT1_CCE578      DS 0H
*MEXIT #=  1135 LV= 2 RT1
*MEXIT #=  1134 LV= 1 ZOSOP
*MCALL #=  1136 LV= 1  ZOSOP 'B919','SUBTRACT (64<32) ','SGFR ','RRE C X
               N '
         JAS   R11,VER549
         USING *,R11
INS549   SGFR  R1,R2
HEX549   DC    X'B9190012'
NUM549   DC    P'549'
*MCALL #=  1137 LV= 2 VER549   RT1   CCE,INS549,HEX549
VER549   DS    0H
         CLC   INS549,HEX549
RT1_TEST579      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE579
         LTORG 
RT1_CCE579      DS 0H
*MEXIT #=  1137 LV= 2 RT1
*MEXIT #=  1136 LV= 1 ZOSOP
*MCALL #=  1138 LV= 1  ZOSOP 'B91A','ADD LOGICAL (64<32) ','ALGFR','RREX
                C N '
         JAS   R11,VER550
         USING *,R11
INS550   ALGFR R1,R2
HEX550   DC    X'B91A0012'
NUM550   DC    P'550'
*MCALL #=  1139 LV= 2 VER550   RT1   CCE,INS550,HEX550
VER550   DS    0H
         CLC   INS550,HEX550
RT1_TEST580      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE580
         LTORG 
RT1_CCE580      DS 0H
*MEXIT #=  1139 LV= 2 RT1
*MEXIT #=  1138 LV= 1 ZOSOP
*MCALL #=  1140 LV= 1  ZOSOP 'B91B','SUBTRACT LOGICAL (64<32) ','SLGFR'X
               ,'RRE C N '
         JAS   R11,VER551
         USING *,R11
INS551   SLGFR R1,R2
HEX551   DC    X'B91B0012'
NUM551   DC    P'551'
*MCALL #=  1141 LV= 2 VER551   RT1   CCE,INS551,HEX551
VER551   DS    0H
         CLC   INS551,HEX551
RT1_TEST581      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE581
         LTORG 
RT1_CCE581      DS 0H
*MEXIT #=  1141 LV= 2 RT1
*MEXIT #=  1140 LV= 1 ZOSOP
*MCALL #=  1142 LV= 1  ZOSOP 'B91C','MULTIPLY SINGLE (64<32) ','MSGFR',X
               'RRE N '
         JAS   R11,VER552
         USING *,R11
INS552   MSGFR R1,R2
HEX552   DC    X'B91C0012'
NUM552   DC    P'552'
*MCALL #=  1143 LV= 2 VER552   RT1   CCE,INS552,HEX552
VER552   DS    0H
         CLC   INS552,HEX552
RT1_TEST582      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE582
         LTORG 
RT1_CCE582      DS 0H
*MEXIT #=  1143 LV= 2 RT1
*MEXIT #=  1142 LV= 1 ZOSOP
*MCALL #=  1144 LV= 1  ZOSOP 'B91D','DIVIDE SINGLE (64<32) ','DSGFR','RX
               RE N '
         JAS   R11,VER553
         USING *,R11
INS553   DSGFR R1,R2
HEX553   DC    X'B91D0012'
NUM553   DC    P'553'
*MCALL #=  1145 LV= 2 VER553   RT1   CCE,INS553,HEX553
VER553   DS    0H
         CLC   INS553,HEX553
RT1_TEST583      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE583
         LTORG 
RT1_CCE583      DS 0H
*MEXIT #=  1145 LV= 2 RT1
*MEXIT #=  1144 LV= 1 ZOSOP
*MCALL #=  1146 LV= 1  ZOSOP 'B91E','COMPUTE MESSAGE AUTHENTICATION CODX
               E ','KMAC ','RRE C MS'
         JAS   R11,VER554
         USING *,R11
INS554   KMAC  R1,R2
HEX554   DC    X'B91E0012'
NUM554   DC    P'554'
*MCALL #=  1147 LV= 2 VER554   RT1   CCE,INS554,HEX554
VER554   DS    0H
         CLC   INS554,HEX554
RT1_TEST584      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE584
         LTORG 
RT1_CCE584      DS 0H
*MEXIT #=  1147 LV= 2 RT1
*MEXIT #=  1146 LV= 1 ZOSOP
*MCALL #=  1148 LV= 1  ZOSOP 'B91F','LOAD REVERSED (32) ','LRVR ','RRE X
               N3'
         JAS   R11,VER555
         USING *,R11
INS555   LRVR  R1,R2
HEX555   DC    X'B91F0012'
NUM555   DC    P'555'
*MCALL #=  1149 LV= 2 VER555   RT1   CCE,INS555,HEX555
VER555   DS    0H
         CLC   INS555,HEX555
RT1_TEST585      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE585
         LTORG 
RT1_CCE585      DS 0H
*MEXIT #=  1149 LV= 2 RT1
*MEXIT #=  1148 LV= 1 ZOSOP
*MCALL #=  1150 LV= 1  ZOSOP 'B920','COMPARE (64) ','CGR ','RRE C N '
         JAS   R11,VER556
         USING *,R11
INS556   CGR  R1,R2
HEX556   DC    X'B9200012'
NUM556   DC    P'556'
*MCALL #=  1151 LV= 2 VER556   RT1   CCE,INS556,HEX556
VER556   DS    0H
         CLC   INS556,HEX556
RT1_TEST586      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE586
         LTORG 
RT1_CCE586      DS 0H
*MEXIT #=  1151 LV= 2 RT1
*MEXIT #=  1150 LV= 1 ZOSOP
*MCALL #=  1152 LV= 1  ZOSOP 'B921','COMPARE LOGICAL (64) ','CLGR ','RRX
               E C N '
         JAS   R11,VER557
         USING *,R11
INS557   CLGR  R1,R2
HEX557   DC    X'B9210012'
NUM557   DC    P'557'
*MCALL #=  1153 LV= 2 VER557   RT1   CCE,INS557,HEX557
VER557   DS    0H
         CLC   INS557,HEX557
RT1_TEST587      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE587
         LTORG 
RT1_CCE587      DS 0H
*MEXIT #=  1153 LV= 2 RT1
*MEXIT #=  1152 LV= 1 ZOSOP
*MCALL #=  1154 LV= 1  ZOSOP 'B925','STORE USING REAL ADDRESS (64) ','SX
               TURG','RRE N '
         JAS   R11,VER558
         USING *,R11
INS558   STURG R1,R2
HEX558   DC    X'B9250012'
NUM558   DC    P'558'
*MCALL #=  1155 LV= 2 VER558   RT1   CCE,INS558,HEX558
VER558   DS    0H
         CLC   INS558,HEX558
RT1_TEST588      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE588
         LTORG 
RT1_CCE588      DS 0H
*MEXIT #=  1155 LV= 2 RT1
*MEXIT #=  1154 LV= 1 ZOSOP
*MCALL #=  1156 LV= 1  ZOSOP 'B926','LOAD BYTE','LBR','RRE',Z9
         JAS   R11,VER559
         USING *,R11
INS559   LBR  R1,R2
HEX559   DC    X'B9260012'
NUM559   DC    P'559'
*MCALL #=  1157 LV= 2 VER559   RT1   CCE,INS559,HEX559
VER559   DS    0H
         CLC   INS559,HEX559
RT1_TEST589      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE589
         LTORG 
RT1_CCE589      DS 0H
*MEXIT #=  1157 LV= 2 RT1
*MEXIT #=  1156 LV= 1 ZOSOP
*MCALL #=  1158 LV= 1  ZOSOP 'B927','LOAD HALFWORD','LHR','RRE',Z9
         JAS   R11,VER560
         USING *,R11
INS560   LHR  R1,R2
HEX560   DC    X'B9270012'
NUM560   DC    P'560'
*MCALL #=  1159 LV= 2 VER560   RT1   CCE,INS560,HEX560
VER560   DS    0H
         CLC   INS560,HEX560
RT1_TEST590      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE590
         LTORG 
RT1_CCE590      DS 0H
*MEXIT #=  1159 LV= 2 RT1
*MEXIT #=  1158 LV= 1 ZOSOP
*MCALL #=  1160 LV= 1  ZOSOP 'B928','PERFORM CRYPTOGRAPHIC KEY MGMT. OPX
               ERATIONS','PCKMO','RE4'  RPI-1125 Z196
         JAS   R11,VER561
         USING *,R11
INS561   PCKMO 
HEX561   DC    X'B9280000'
NUM561   DC    P'561'
*MCALL #=  1161 LV= 2 VER561   RT1   CCE,INS561,HEX561
VER561   DS    0H
         CLC   INS561,HEX561
RT1_TEST591      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE591
         LTORG 
RT1_CCE591      DS 0H
*MEXIT #=  1161 LV= 2 RT1
*MEXIT #=  1160 LV= 1 ZOSOP
*MCALL #=  1162 LV= 1  ZOSOP 'B92A','CIPHER MESSAGE WITH CFB','KMF','RRX
               E'  RPI-1125 Z196
         JAS   R11,VER562
         USING *,R11
INS562   KMF  R1,R2
HEX562   DC    X'B92A0012'
NUM562   DC    P'562'
*MCALL #=  1163 LV= 2 VER562   RT1   CCE,INS562,HEX562
VER562   DS    0H
         CLC   INS562,HEX562
RT1_TEST592      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE592
         LTORG 
RT1_CCE592      DS 0H
*MEXIT #=  1163 LV= 2 RT1
*MEXIT #=  1162 LV= 1 ZOSOP
*MCALL #=  1164 LV= 1  ZOSOP 'B92B','CIPHER MESSAGE WITH OFB','KMO','RRX
               E'  RPI-1125 Z196
         JAS   R11,VER563
         USING *,R11
INS563   KMO  R1,R2
HEX563   DC    X'B92B0012'
NUM563   DC    P'563'
*MCALL #=  1165 LV= 2 VER563   RT1   CCE,INS563,HEX563
VER563   DS    0H
         CLC   INS563,HEX563
RT1_TEST593      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE593
         LTORG 
RT1_CCE593      DS 0H
*MEXIT #=  1165 LV= 2 RT1
*MEXIT #=  1164 LV= 1 ZOSOP
*MCALL #=  1166 LV= 1  ZOSOP 'B92C','PERFORM CRYPTOGRAPHIC COMPUTATION'X
               ,'PCC','RE4'  RPI-1125 Z196
         JAS   R11,VER564
         USING *,R11
INS564   PCC 
HEX564   DC    X'B92C0000'
NUM564   DC    P'564'
*MCALL #=  1167 LV= 2 VER564   RT1   CCE,INS564,HEX564
VER564   DS    0H
         CLC   INS564,HEX564
RT1_TEST594      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE594
         LTORG 
RT1_CCE594      DS 0H
*MEXIT #=  1167 LV= 2 RT1
*MEXIT #=  1166 LV= 1 ZOSOP
*MCALL #=  1168 LV= 1  ZOSOP 'B92D','CIPHER MESSAGE WITH COUNTER','KMCTX
               R','RRF2 '  RPI-1125 Z196
         JAS   R11,VER565
         USING *,R11
INS565   KMCTR R1,R3,R2
HEX565   DC    X'B92D3012'
NUM565   DC    P'565'
*MCALL #=  1169 LV= 2 VER565   RT1   CCE,INS565,HEX565
VER565   DS    0H
         CLC   INS565,HEX565
RT1_TEST595      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE595
         LTORG 
RT1_CCE595      DS 0H
*MEXIT #=  1169 LV= 2 RT1
*MEXIT #=  1168 LV= 1 ZOSOP
*MCALL #=  1170 LV= 1  ZOSOP 'B92E','CIPHER MESSAGE ','KM ','RRE C MS'
         JAS   R11,VER566
         USING *,R11
INS566   KM   R1,R2
HEX566   DC    X'B92E0012'
NUM566   DC    P'566'
*MCALL #=  1171 LV= 2 VER566   RT1   CCE,INS566,HEX566
VER566   DS    0H
         CLC   INS566,HEX566
RT1_TEST596      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE596
         LTORG 
RT1_CCE596      DS 0H
*MEXIT #=  1171 LV= 2 RT1
*MEXIT #=  1170 LV= 1 ZOSOP
*MCALL #=  1172 LV= 1  ZOSOP 'B92F','CIPHER MESSAGE WITH CHAINING ','KMX
               C ','RRE C MS'
         JAS   R11,VER567
         USING *,R11
INS567   KMC  R1,R2
HEX567   DC    X'B92F0012'
NUM567   DC    P'567'
*MCALL #=  1173 LV= 2 VER567   RT1   CCE,INS567,HEX567
VER567   DS    0H
         CLC   INS567,HEX567
RT1_TEST597      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE597
         LTORG 
RT1_CCE597      DS 0H
*MEXIT #=  1173 LV= 2 RT1
*MEXIT #=  1172 LV= 1 ZOSOP
*MCALL #=  1174 LV= 1  ZOSOP 'B930','COMPARE (64<32) ','CGFR ','RRE C NX
                '
         JAS   R11,VER568
         USING *,R11
INS568   CGFR  R1,R2
HEX568   DC    X'B9300012'
NUM568   DC    P'568'
*MCALL #=  1175 LV= 2 VER568   RT1   CCE,INS568,HEX568
VER568   DS    0H
         CLC   INS568,HEX568
RT1_TEST598      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE598
         LTORG 
RT1_CCE598      DS 0H
*MEXIT #=  1175 LV= 2 RT1
*MEXIT #=  1174 LV= 1 ZOSOP
*MCALL #=  1176 LV= 1  ZOSOP 'B931','COMPARE LOGICAL (64<32) ','CLGFR',X
               'RRE C N '
         JAS   R11,VER569
         USING *,R11
INS569   CLGFR R1,R2
HEX569   DC    X'B9310012'
NUM569   DC    P'569'
*MCALL #=  1177 LV= 2 VER569   RT1   CCE,INS569,HEX569
VER569   DS    0H
         CLC   INS569,HEX569
RT1_TEST599      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE599
         LTORG 
RT1_CCE599      DS 0H
*MEXIT #=  1177 LV= 2 RT1
*MEXIT #=  1176 LV= 1 ZOSOP
*MCALL #=  1178 LV= 1  ZOSOP 'B93E','COMPUTE INTERMEDIATE MESSAGE DIGESX
               T ','KIMD ','RRE C MS'
         JAS   R11,VER570
         USING *,R11
INS570   KIMD  R1,R2
HEX570   DC    X'B93E0012'
NUM570   DC    P'570'
*MCALL #=  1179 LV= 2 VER570   RT1   CCE,INS570,HEX570
VER570   DS    0H
         CLC   INS570,HEX570
RT1_TEST600      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE600
         LTORG 
RT1_CCE600      DS 0H
*MEXIT #=  1179 LV= 2 RT1
*MEXIT #=  1178 LV= 1 ZOSOP
*MCALL #=  1180 LV= 1  ZOSOP 'B93F','COMPUTE LAST MESSAGE DIGEST ','KLMX
               D ','RRE C MS'
         JAS   R11,VER571
         USING *,R11
INS571   KLMD  R1,R2
HEX571   DC    X'B93F0012'
NUM571   DC    P'571'
*MCALL #=  1181 LV= 2 VER571   RT1   CCE,INS571,HEX571
VER571   DS    0H
         CLC   INS571,HEX571
RT1_TEST601      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE601
         LTORG 
RT1_CCE601      DS 0H
*MEXIT #=  1181 LV= 2 RT1
*MEXIT #=  1180 LV= 1 ZOSOP
*MCALL #=  1182 LV= 1  ZOSOP 'B941','CONVERT TO FIXED (long DFP to 32)'X
               ,'CFDTR','RRF3 '  RPI-1125 Z196
         JAS   R11,VER572
         USING *,R11
INS572   CFDTR R1,R3,R2,M4
HEX572   DC    X'B9413412'
NUM572   DC    P'572'
*MCALL #=  1183 LV= 2 VER572   RT1   CCE,INS572,HEX572
VER572   DS    0H
         CLC   INS572,HEX572
RT1_TEST602      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE602
         LTORG 
RT1_CCE602      DS 0H
*MEXIT #=  1183 LV= 2 RT1
*MEXIT #=  1182 LV= 1 ZOSOP
*MCALL #=  1184 LV= 1  ZOSOP 'B942','CONVERT TO LOGICAL (long DFP to 64X
               )','CLGDTR','RRF3 '  RPI 1125 Z196
         JAS   R11,VER573
         USING *,R11
INS573   CLGDTR R1,R3,R2,M4
HEX573   DC    X'B9423412'
NUM573   DC    P'573'
*MCALL #=  1185 LV= 2 VER573   RT1   CCE,INS573,HEX573
VER573   DS    0H
         CLC   INS573,HEX573
RT1_TEST603      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE603
         LTORG 
RT1_CCE603      DS 0H
*MEXIT #=  1185 LV= 2 RT1
*MEXIT #=  1184 LV= 1 ZOSOP
*MCALL #=  1186 LV= 1  ZOSOP 'B943','CONVERT TO LOGICAL (long DFP to 32X
               )','CLFDTR','RRF3 '  RPI 1125 Z196
         JAS   R11,VER574
         USING *,R11
INS574   CLFDTR R1,R3,R2,M4
HEX574   DC    X'B9433412'
NUM574   DC    P'574'
*MCALL #=  1187 LV= 2 VER574   RT1   CCE,INS574,HEX574
VER574   DS    0H
         CLC   INS574,HEX574
RT1_TEST604      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE604
         LTORG 
RT1_CCE604      DS 0H
*MEXIT #=  1187 LV= 2 RT1
*MEXIT #=  1186 LV= 1 ZOSOP
*MCALL #=  1188 LV= 1  ZOSOP 'B946','BRANCH ON COUNT (64) ','BCTGR','RRX
               E N '
         JAS   R11,VER575
         USING *,R11
INS575   BCTGR R1,R2
HEX575   DC    X'B9460012'
NUM575   DC    P'575'
*MCALL #=  1189 LV= 2 VER575   RT1   CCE,INS575,HEX575
VER575   DS    0H
         CLC   INS575,HEX575
RT1_TEST605      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE605
         LTORG 
RT1_CCE605      DS 0H
*MEXIT #=  1189 LV= 2 RT1
*MEXIT #=  1188 LV= 1 ZOSOP
*MCALL #=  1190 LV= 1  ZOSOP 'B949','CONVERT TO FIXED (extended DFP to X
               32)','CFXTR','RRF3 '  RPI-1125 Z196
         JAS   R11,VER576
         USING *,R11
INS576   CFXTR R1,R3,R2,M4
HEX576   DC    X'B9493412'
NUM576   DC    P'576'
*MCALL #=  1191 LV= 2 VER576   RT1   CCE,INS576,HEX576
VER576   DS    0H
         CLC   INS576,HEX576
RT1_TEST606      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE606
         LTORG 
RT1_CCE606      DS 0H
*MEXIT #=  1191 LV= 2 RT1
*MEXIT #=  1190 LV= 1 ZOSOP
*MCALL #=  1192 LV= 1  ZOSOP 'B94A','CONVERT TO LOGICAL (extended DFP tX
               o 64)','CLGXTR','RRF3 '  RPI-1125 Z196
         JAS   R11,VER577
         USING *,R11
INS577   CLGXTR R1,R3,R2,M4
HEX577   DC    X'B94A3412'
NUM577   DC    P'577'
*MCALL #=  1193 LV= 2 VER577   RT1   CCE,INS577,HEX577
VER577   DS    0H
         CLC   INS577,HEX577
RT1_TEST607      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE607
         LTORG 
RT1_CCE607      DS 0H
*MEXIT #=  1193 LV= 2 RT1
*MEXIT #=  1192 LV= 1 ZOSOP
*MCALL #=  1194 LV= 1  ZOSOP 'B94B','CONVERT TO LOGICAL (extended DFP tX
               o 32)','CLFXTR','RRF3 '  RPI-1125 Z196
         JAS   R11,VER578
         USING *,R11
INS578   CLFXTR R1,R3,R2,M4
HEX578   DC    X'B94B3412'
NUM578   DC    P'578'
*MCALL #=  1195 LV= 2 VER578   RT1   CCE,INS578,HEX578
VER578   DS    0H
         CLC   INS578,HEX578
RT1_TEST608      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE608
         LTORG 
RT1_CCE608      DS 0H
*MEXIT #=  1195 LV= 2 RT1
*MEXIT #=  1194 LV= 1 ZOSOP
*MCALL #=  1196 LV= 1  ZOSOP 'B951','CONVERT FROM FIXED (32 to long DFPX
               )','CDFTR','RRF3' RPI-1125 Z196
         JAS   R11,VER579
         USING *,R11
INS579   CDFTR R1,R3,R2,M4
HEX579   DC    X'B9513412'
NUM579   DC    P'579'
*MCALL #=  1197 LV= 2 VER579   RT1   CCE,INS579,HEX579
VER579   DS    0H
         CLC   INS579,HEX579
RT1_TEST609      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE609
         LTORG 
RT1_CCE609      DS 0H
*MEXIT #=  1197 LV= 2 RT1
*MEXIT #=  1196 LV= 1 ZOSOP
*MCALL #=  1198 LV= 1  ZOSOP 'B952','CONVERT FROM LOGICAL (64 to long DX
               FP)','CDLGTR','RRF3 '  RPI-1125 Z196
         JAS   R11,VER580
         USING *,R11
INS580   CDLGTR R1,R3,R2,M4
HEX580   DC    X'B9523412'
NUM580   DC    P'580'
*MCALL #=  1199 LV= 2 VER580   RT1   CCE,INS580,HEX580
VER580   DS    0H
         CLC   INS580,HEX580
RT1_TEST610      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE610
         LTORG 
RT1_CCE610      DS 0H
*MEXIT #=  1199 LV= 2 RT1
*MEXIT #=  1198 LV= 1 ZOSOP
*MCALL #=  1200 LV= 1  ZOSOP 'B953','CONVERT FROM LOGICAL (32 to long DX
               FP)','CDLFTR','RRF3 '  RPI-1125 Z196
         JAS   R11,VER581
         USING *,R11
INS581   CDLFTR R1,R3,R2,M4
HEX581   DC    X'B9533412'
NUM581   DC    P'581'
*MCALL #=  1201 LV= 2 VER581   RT1   CCE,INS581,HEX581
VER581   DS    0H
         CLC   INS581,HEX581
RT1_TEST611      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE611
         LTORG 
RT1_CCE611      DS 0H
*MEXIT #=  1201 LV= 2 RT1
*MEXIT #=  1200 LV= 1 ZOSOP
*MCALL #=  1202 LV= 1  ZOSOP 'B959','CONVERT FROM FIXED (32 to extendedX
                DFP)','CXFTR','RRF3' RPI-1125 Z196
         JAS   R11,VER582
         USING *,R11
INS582   CXFTR R1,R3,R2,M4
HEX582   DC    X'B9593412'
NUM582   DC    P'582'
*MCALL #=  1203 LV= 2 VER582   RT1   CCE,INS582,HEX582
VER582   DS    0H
         CLC   INS582,HEX582
RT1_TEST612      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE612
         LTORG 
RT1_CCE612      DS 0H
*MEXIT #=  1203 LV= 2 RT1
*MEXIT #=  1202 LV= 1 ZOSOP
*MCALL #=  1204 LV= 1  ZOSOP 'B95A','CONVERT FROM LOGICAL (64 to extendX
               ed DFP)','CXLGTR','RRF3 '  RPI-1125 Z196
         JAS   R11,VER583
         USING *,R11
INS583   CXLGTR R1,R3,R2,M4
HEX583   DC    X'B95A3412'
NUM583   DC    P'583'
*MCALL #=  1205 LV= 2 VER583   RT1   CCE,INS583,HEX583
VER583   DS    0H
         CLC   INS583,HEX583
RT1_TEST613      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE613
         LTORG 
RT1_CCE613      DS 0H
*MEXIT #=  1205 LV= 2 RT1
*MEXIT #=  1204 LV= 1 ZOSOP
*MCALL #=  1206 LV= 1  ZOSOP 'B95B','CONVERT FROM LOGICAL (32 to extendX
               ed DFP)','CXLFTR','RRF3 '  RPI-1125 Z196
         JAS   R11,VER584
         USING *,R11
INS584   CXLFTR R1,R3,R2,M4
HEX584   DC    X'B95B3412'
NUM584   DC    P'584'
*MCALL #=  1207 LV= 2 VER584   RT1   CCE,INS584,HEX584
VER584   DS    0H
         CLC   INS584,HEX584
RT1_TEST614      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE614
         LTORG 
RT1_CCE614      DS 0H
*MEXIT #=  1207 LV= 2 RT1
*MEXIT #=  1206 LV= 1 ZOSOP
*MCALL #=  1208 LV= 1  ZOSOP 'B960','Compare and Trap','CGRT','RRF5'  RX
               PI-817
         JAS   R11,VER585
         USING *,R11
INS585   CGRT R1,R2,M3
HEX585   DC    X'B9603012'
NUM585   DC    P'585'
*MCALL #=  1209 LV= 2 VER585   RT1   CCE,INS585,HEX585
VER585   DS    0H
         CLC   INS585,HEX585
RT1_TEST615      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE615
         LTORG 
RT1_CCE615      DS 0H
*MEXIT #=  1209 LV= 2 RT1
*MEXIT #=  1208 LV= 1 ZOSOP
*MCALL #=  1210 LV= 1  ZOSOP 'B9608','CGRT if Equal','CGRTE','RRF6'  RPX
               I-817
         JAS   R11,VER586
         USING *,R11
INS586   CGRTE R1,R2
HEX586   DC    X'B9608012'
NUM586   DC    P'586'
*MCALL #=  1211 LV= 2 VER586   RT1   CCE,INS586,HEX586
VER586   DS    0H
         CLC   INS586,HEX586
RT1_TEST616      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE616
         LTORG 
RT1_CCE616      DS 0H
*MEXIT #=  1211 LV= 2 RT1
*MEXIT #=  1210 LV= 1 ZOSOP
*MCALL #=  1212 LV= 1  ZOSOP 'B9602','CGRT if High','CGRTH','RRF6'  RPIX
               -817
         JAS   R11,VER587
         USING *,R11
INS587   CGRTH R1,R2
HEX587   DC    X'B9602012'
NUM587   DC    P'587'
*MCALL #=  1213 LV= 2 VER587   RT1   CCE,INS587,HEX587
VER587   DS    0H
         CLC   INS587,HEX587
RT1_TEST617      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE617
         LTORG 
RT1_CCE617      DS 0H
*MEXIT #=  1213 LV= 2 RT1
*MEXIT #=  1212 LV= 1 ZOSOP
*MCALL #=  1214 LV= 1  ZOSOP 'B9604','CGRT if Low','CGRTL','RRF6'  RPI-X
               817
         JAS   R11,VER588
         USING *,R11
INS588   CGRTL R1,R2
HEX588   DC    X'B9604012'
NUM588   DC    P'588'
*MCALL #=  1215 LV= 2 VER588   RT1   CCE,INS588,HEX588
VER588   DS    0H
         CLC   INS588,HEX588
RT1_TEST618      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE618
         LTORG 
RT1_CCE618      DS 0H
*MEXIT #=  1215 LV= 2 RT1
*MEXIT #=  1214 LV= 1 ZOSOP
*MCALL #=  1216 LV= 1  ZOSOP 'B9606','CGRT if Not Equal','CGRTNE','RRF6X
               '  RPI-817
         JAS   R11,VER589
         USING *,R11
INS589   CGRTNE R1,R2
HEX589   DC    X'B9606012'
NUM589   DC    P'589'
*MCALL #=  1217 LV= 2 VER589   RT1   CCE,INS589,HEX589
VER589   DS    0H
         CLC   INS589,HEX589
RT1_TEST619      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE619
         LTORG 
RT1_CCE619      DS 0H
*MEXIT #=  1217 LV= 2 RT1
*MEXIT #=  1216 LV= 1 ZOSOP
*MCALL #=  1218 LV= 1  ZOSOP 'B960C','CGRT if Not High','CGRTNH','RRF6'X
                 RPI-817
         JAS   R11,VER590
         USING *,R11
INS590   CGRTNH R1,R2
HEX590   DC    X'B960C012'
NUM590   DC    P'590'
*MCALL #=  1219 LV= 2 VER590   RT1   CCE,INS590,HEX590
VER590   DS    0H
         CLC   INS590,HEX590
RT1_TEST620      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE620
         LTORG 
RT1_CCE620      DS 0H
*MEXIT #=  1219 LV= 2 RT1
*MEXIT #=  1218 LV= 1 ZOSOP
*MCALL #=  1220 LV= 1  ZOSOP 'B960A','CGRT if Not Low','CGRTNL','RRF6' X
                RPI-817
         JAS   R11,VER591
         USING *,R11
INS591   CGRTNL R1,R2
HEX591   DC    X'B960A012'
NUM591   DC    P'591'
*MCALL #=  1221 LV= 2 VER591   RT1   CCE,INS591,HEX591
VER591   DS    0H
         CLC   INS591,HEX591
RT1_TEST621      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE621
         LTORG 
RT1_CCE621      DS 0H
*MEXIT #=  1221 LV= 2 RT1
*MEXIT #=  1220 LV= 1 ZOSOP
*MCALL #=  1222 LV= 1  ZOSOP 'B961','Compare Logical and Trap','CLGRT',X
               'RRF5'  RPI-817
         JAS   R11,VER592
         USING *,R11
INS592   CLGRT R1,R2,M3
HEX592   DC    X'B9613012'
NUM592   DC    P'592'
*MCALL #=  1223 LV= 2 VER592   RT1   CCE,INS592,HEX592
VER592   DS    0H
         CLC   INS592,HEX592
RT1_TEST622      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE622
         LTORG 
RT1_CCE622      DS 0H
*MEXIT #=  1223 LV= 2 RT1
*MEXIT #=  1222 LV= 1 ZOSOP
*MCALL #=  1224 LV= 1  ZOSOP 'B9618','CLGRT if Equal','CLGRTE','RRF6'  X
               RPI-817
         JAS   R11,VER593
         USING *,R11
INS593   CLGRTE R1,R2
HEX593   DC    X'B9618012'
NUM593   DC    P'593'
*MCALL #=  1225 LV= 2 VER593   RT1   CCE,INS593,HEX593
VER593   DS    0H
         CLC   INS593,HEX593
RT1_TEST623      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE623
         LTORG 
RT1_CCE623      DS 0H
*MEXIT #=  1225 LV= 2 RT1
*MEXIT #=  1224 LV= 1 ZOSOP
*MCALL #=  1226 LV= 1  ZOSOP 'B9612','CLGRT if High','CLGRTH','RRF6'  RX
               PI-817
         JAS   R11,VER594
         USING *,R11
INS594   CLGRTH R1,R2
HEX594   DC    X'B9612012'
NUM594   DC    P'594'
*MCALL #=  1227 LV= 2 VER594   RT1   CCE,INS594,HEX594
VER594   DS    0H
         CLC   INS594,HEX594
RT1_TEST624      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE624
         LTORG 
RT1_CCE624      DS 0H
*MEXIT #=  1227 LV= 2 RT1
*MEXIT #=  1226 LV= 1 ZOSOP
*MCALL #=  1228 LV= 1  ZOSOP 'B9614','CLGRT if Low','CLGRTL','RRF6'  RPX
               I-817
         JAS   R11,VER595
         USING *,R11
INS595   CLGRTL R1,R2
HEX595   DC    X'B9614012'
NUM595   DC    P'595'
*MCALL #=  1229 LV= 2 VER595   RT1   CCE,INS595,HEX595
VER595   DS    0H
         CLC   INS595,HEX595
RT1_TEST625      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE625
         LTORG 
RT1_CCE625      DS 0H
*MEXIT #=  1229 LV= 2 RT1
*MEXIT #=  1228 LV= 1 ZOSOP
*MCALL #=  1230 LV= 1  ZOSOP 'B9616','CLGRT if Not Equal','CLGRTNE','RRX
               F6'  RPI-817
         JAS   R11,VER596
         USING *,R11
INS596   CLGRTNE R1,R2
HEX596   DC    X'B9616012'
NUM596   DC    P'596'
*MCALL #=  1231 LV= 2 VER596   RT1   CCE,INS596,HEX596
VER596   DS    0H
         CLC   INS596,HEX596
RT1_TEST626      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE626
         LTORG 
RT1_CCE626      DS 0H
*MEXIT #=  1231 LV= 2 RT1
*MEXIT #=  1230 LV= 1 ZOSOP
*MCALL #=  1232 LV= 1  ZOSOP 'B961C','CLGRT if Not High','CLGRTNH','RRFX
               6'  RPI-817
         JAS   R11,VER597
         USING *,R11
INS597   CLGRTNH R1,R2
HEX597   DC    X'B961C012'
NUM597   DC    P'597'
*MCALL #=  1233 LV= 2 VER597   RT1   CCE,INS597,HEX597
VER597   DS    0H
         CLC   INS597,HEX597
RT1_TEST627      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE627
         LTORG 
RT1_CCE627      DS 0H
*MEXIT #=  1233 LV= 2 RT1
*MEXIT #=  1232 LV= 1 ZOSOP
*MCALL #=  1234 LV= 1  ZOSOP 'B961A','CLGRT if Not Low','CLGRTNL','RRF6X
               '  RPI-817
         JAS   R11,VER598
         USING *,R11
INS598   CLGRTNL R1,R2
HEX598   DC    X'B961A012'
NUM598   DC    P'598'
*MCALL #=  1235 LV= 2 VER598   RT1   CCE,INS598,HEX598
VER598   DS    0H
         CLC   INS598,HEX598
RT1_TEST628      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE628
         LTORG 
RT1_CCE628      DS 0H
*MEXIT #=  1235 LV= 2 RT1
*MEXIT #=  1234 LV= 1 ZOSOP
*MCALL #=  1236 LV= 1  ZOSOP 'B972','Compare and Trap','CRT','RRF5'  RPX
               I-817
         JAS   R11,VER599
         USING *,R11
INS599   CRT  R1,R2,M3
HEX599   DC    X'B9723012'
NUM599   DC    P'599'
*MCALL #=  1237 LV= 2 VER599   RT1   CCE,INS599,HEX599
VER599   DS    0H
         CLC   INS599,HEX599
RT1_TEST629      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE629
         LTORG 
RT1_CCE629      DS 0H
*MEXIT #=  1237 LV= 2 RT1
*MEXIT #=  1236 LV= 1 ZOSOP
*MCALL #=  1238 LV= 1  ZOSOP 'B9728','CRT if Equal','CRTE','RRF6'  RPI-X
               817
         JAS   R11,VER600
         USING *,R11
INS600   CRTE R1,R2
HEX600   DC    X'B9728012'
NUM600   DC    P'600'
*MCALL #=  1239 LV= 2 VER600   RT1   CCE,INS600,HEX600
VER600   DS    0H
         CLC   INS600,HEX600
RT1_TEST630      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE630
         LTORG 
RT1_CCE630      DS 0H
*MEXIT #=  1239 LV= 2 RT1
*MEXIT #=  1238 LV= 1 ZOSOP
*MCALL #=  1240 LV= 1  ZOSOP 'B9722','CRT if High','CRTH','RRF6'  RPI-8X
               17
         JAS   R11,VER601
         USING *,R11
INS601   CRTH R1,R2
HEX601   DC    X'B9722012'
NUM601   DC    P'601'
*MCALL #=  1241 LV= 2 VER601   RT1   CCE,INS601,HEX601
VER601   DS    0H
         CLC   INS601,HEX601
RT1_TEST631      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE631
         LTORG 
RT1_CCE631      DS 0H
*MEXIT #=  1241 LV= 2 RT1
*MEXIT #=  1240 LV= 1 ZOSOP
*MCALL #=  1242 LV= 1  ZOSOP 'B9724','CRT if Low','CRTL','RRF6'  RPI-81X
               7
         JAS   R11,VER602
         USING *,R11
INS602   CRTL R1,R2
HEX602   DC    X'B9724012'
NUM602   DC    P'602'
*MCALL #=  1243 LV= 2 VER602   RT1   CCE,INS602,HEX602
VER602   DS    0H
         CLC   INS602,HEX602
RT1_TEST632      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE632
         LTORG 
RT1_CCE632      DS 0H
*MEXIT #=  1243 LV= 2 RT1
*MEXIT #=  1242 LV= 1 ZOSOP
*MCALL #=  1244 LV= 1  ZOSOP 'B9726','CRT if Not Equal','CRTNE','RRF6' X
                RPI-817
         JAS   R11,VER603
         USING *,R11
INS603   CRTNE R1,R2
HEX603   DC    X'B9726012'
NUM603   DC    P'603'
*MCALL #=  1245 LV= 2 VER603   RT1   CCE,INS603,HEX603
VER603   DS    0H
         CLC   INS603,HEX603
RT1_TEST633      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE633
         LTORG 
RT1_CCE633      DS 0H
*MEXIT #=  1245 LV= 2 RT1
*MEXIT #=  1244 LV= 1 ZOSOP
*MCALL #=  1246 LV= 1  ZOSOP 'B972C','CRT if Not High','CRTNH','RRF6'  X
               RPI-817
         JAS   R11,VER604
         USING *,R11
INS604   CRTNH R1,R2
HEX604   DC    X'B972C012'
NUM604   DC    P'604'
*MCALL #=  1247 LV= 2 VER604   RT1   CCE,INS604,HEX604
VER604   DS    0H
         CLC   INS604,HEX604
RT1_TEST634      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE634
         LTORG 
RT1_CCE634      DS 0H
*MEXIT #=  1247 LV= 2 RT1
*MEXIT #=  1246 LV= 1 ZOSOP
*MCALL #=  1248 LV= 1  ZOSOP 'B972A','CRT if Not Low','CRTNL','RRF6'  RX
               PI-817
         JAS   R11,VER605
         USING *,R11
INS605   CRTNL R1,R2
HEX605   DC    X'B972A012'
NUM605   DC    P'605'
*MCALL #=  1249 LV= 2 VER605   RT1   CCE,INS605,HEX605
VER605   DS    0H
         CLC   INS605,HEX605
RT1_TEST635      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE635
         LTORG 
RT1_CCE635      DS 0H
*MEXIT #=  1249 LV= 2 RT1
*MEXIT #=  1248 LV= 1 ZOSOP
*MCALL #=  1250 LV= 1  ZOSOP 'B973','Compare Logical and Trap','CLRT','X
               RRF5'  RPI-817
         JAS   R11,VER606
         USING *,R11
INS606   CLRT R1,R2,M3
HEX606   DC    X'B9733012'
NUM606   DC    P'606'
*MCALL #=  1251 LV= 2 VER606   RT1   CCE,INS606,HEX606
VER606   DS    0H
         CLC   INS606,HEX606
RT1_TEST636      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE636
         LTORG 
RT1_CCE636      DS 0H
*MEXIT #=  1251 LV= 2 RT1
*MEXIT #=  1250 LV= 1 ZOSOP
*MCALL #=  1252 LV= 1  ZOSOP 'B9738','CLRT if Equal','CLRTE','RRF6'  RPX
               I-817
         JAS   R11,VER607
         USING *,R11
INS607   CLRTE R1,R2
HEX607   DC    X'B9738012'
NUM607   DC    P'607'
*MCALL #=  1253 LV= 2 VER607   RT1   CCE,INS607,HEX607
VER607   DS    0H
         CLC   INS607,HEX607
RT1_TEST637      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE637
         LTORG 
RT1_CCE637      DS 0H
*MEXIT #=  1253 LV= 2 RT1
*MEXIT #=  1252 LV= 1 ZOSOP
*MCALL #=  1254 LV= 1  ZOSOP 'B9732','CLRT if High','CLRTH','RRF6'  RPIX
               -817
         JAS   R11,VER608
         USING *,R11
INS608   CLRTH R1,R2
HEX608   DC    X'B9732012'
NUM608   DC    P'608'
*MCALL #=  1255 LV= 2 VER608   RT1   CCE,INS608,HEX608
VER608   DS    0H
         CLC   INS608,HEX608
RT1_TEST638      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE638
         LTORG 
RT1_CCE638      DS 0H
*MEXIT #=  1255 LV= 2 RT1
*MEXIT #=  1254 LV= 1 ZOSOP
*MCALL #=  1256 LV= 1  ZOSOP 'B9734','CLRT if Low','CLRTL','RRF6'  RPI-X
               817
         JAS   R11,VER609
         USING *,R11
INS609   CLRTL R1,R2
HEX609   DC    X'B9734012'
NUM609   DC    P'609'
*MCALL #=  1257 LV= 2 VER609   RT1   CCE,INS609,HEX609
VER609   DS    0H
         CLC   INS609,HEX609
RT1_TEST639      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE639
         LTORG 
RT1_CCE639      DS 0H
*MEXIT #=  1257 LV= 2 RT1
*MEXIT #=  1256 LV= 1 ZOSOP
*MCALL #=  1258 LV= 1  ZOSOP 'B9736','CLRT if Not Equal','CLRTNE','RRF6X
               '  RPI-817
         JAS   R11,VER610
         USING *,R11
INS610   CLRTNE R1,R2
HEX610   DC    X'B9736012'
NUM610   DC    P'610'
*MCALL #=  1259 LV= 2 VER610   RT1   CCE,INS610,HEX610
VER610   DS    0H
         CLC   INS610,HEX610
RT1_TEST640      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE640
         LTORG 
RT1_CCE640      DS 0H
*MEXIT #=  1259 LV= 2 RT1
*MEXIT #=  1258 LV= 1 ZOSOP
*MCALL #=  1260 LV= 1  ZOSOP 'B973C','CLRT if Not High','CLRTNH','RRF6'X
                 RPI-817
         JAS   R11,VER611
         USING *,R11
INS611   CLRTNH R1,R2
HEX611   DC    X'B973C012'
NUM611   DC    P'611'
*MCALL #=  1261 LV= 2 VER611   RT1   CCE,INS611,HEX611
VER611   DS    0H
         CLC   INS611,HEX611
RT1_TEST641      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE641
         LTORG 
RT1_CCE641      DS 0H
*MEXIT #=  1261 LV= 2 RT1
*MEXIT #=  1260 LV= 1 ZOSOP
*MCALL #=  1262 LV= 1  ZOSOP 'B973A','CLRT if Not Low','CLRTNL','RRF6' X
                RPI-817
         JAS   R11,VER612
         USING *,R11
INS612   CLRTNL R1,R2
HEX612   DC    X'B973A012'
NUM612   DC    P'612'
*MCALL #=  1263 LV= 2 VER612   RT1   CCE,INS612,HEX612
VER612   DS    0H
         CLC   INS612,HEX612
RT1_TEST642      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE642
         LTORG 
RT1_CCE642      DS 0H
*MEXIT #=  1263 LV= 2 RT1
*MEXIT #=  1262 LV= 1 ZOSOP
*MCALL #=  1264 LV= 1  ZOSOP 'B980','AND (64) ','NGR ','RRE C N '
         JAS   R11,VER613
         USING *,R11
INS613   NGR  R1,R2
HEX613   DC    X'B9800012'
NUM613   DC    P'613'
*MCALL #=  1265 LV= 2 VER613   RT1   CCE,INS613,HEX613
VER613   DS    0H
         CLC   INS613,HEX613
RT1_TEST643      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE643
         LTORG 
RT1_CCE643      DS 0H
*MEXIT #=  1265 LV= 2 RT1
*MEXIT #=  1264 LV= 1 ZOSOP
*MCALL #=  1266 LV= 1  ZOSOP 'B981','OR (64) ','OGR ','RRE C N '
         JAS   R11,VER614
         USING *,R11
INS614   OGR  R1,R2
HEX614   DC    X'B9810012'
NUM614   DC    P'614'
*MCALL #=  1267 LV= 2 VER614   RT1   CCE,INS614,HEX614
VER614   DS    0H
         CLC   INS614,HEX614
RT1_TEST644      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE644
         LTORG 
RT1_CCE644      DS 0H
*MEXIT #=  1267 LV= 2 RT1
*MEXIT #=  1266 LV= 1 ZOSOP
*MCALL #=  1268 LV= 1  ZOSOP 'B982','EXCLUSIVE OR (64) ','XGR ','RRE C X
               N '
         JAS   R11,VER615
         USING *,R11
INS615   XGR  R1,R2
HEX615   DC    X'B9820012'
NUM615   DC    P'615'
*MCALL #=  1269 LV= 2 VER615   RT1   CCE,INS615,HEX615
VER615   DS    0H
         CLC   INS615,HEX615
RT1_TEST645      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE645
         LTORG 
RT1_CCE645      DS 0H
*MEXIT #=  1269 LV= 2 RT1
*MEXIT #=  1268 LV= 1 ZOSOP
*MCALL #=  1270 LV= 1  ZOSOP 'B983','FIND LEFTMOST ONE ','FLOGR','RRE',X
               Z9
         JAS   R11,VER616
         USING *,R11
INS616   FLOGR R1,R2
HEX616   DC    X'B9830012'
NUM616   DC    P'616'
*MCALL #=  1271 LV= 2 VER616   RT1   CCE,INS616,HEX616
VER616   DS    0H
         CLC   INS616,HEX616
RT1_TEST646      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE646
         LTORG 
RT1_CCE646      DS 0H
*MEXIT #=  1271 LV= 2 RT1
*MEXIT #=  1270 LV= 1 ZOSOP
*MCALL #=  1272 LV= 1  ZOSOP 'B984','LOAD LOGICAL CHARACTER','LLGCR','RX
               RE',Z9
         JAS   R11,VER617
         USING *,R11
INS617   LLGCR R1,R2
HEX617   DC    X'B9840012'
NUM617   DC    P'617'
*MCALL #=  1273 LV= 2 VER617   RT1   CCE,INS617,HEX617
VER617   DS    0H
         CLC   INS617,HEX617
RT1_TEST647      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE647
         LTORG 
RT1_CCE647      DS 0H
*MEXIT #=  1273 LV= 2 RT1
*MEXIT #=  1272 LV= 1 ZOSOP
*MCALL #=  1274 LV= 1  ZOSOP 'B985','LOAD LOGICAL HALFWORD','LLGHR','RRX
               E',Z9
         JAS   R11,VER618
         USING *,R11
INS618   LLGHR R1,R2
HEX618   DC    X'B9850012'
NUM618   DC    P'618'
*MCALL #=  1275 LV= 2 VER618   RT1   CCE,INS618,HEX618
VER618   DS    0H
         CLC   INS618,HEX618
RT1_TEST648      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE648
         LTORG 
RT1_CCE648      DS 0H
*MEXIT #=  1275 LV= 2 RT1
*MEXIT #=  1274 LV= 1 ZOSOP
*MCALL #=  1276 LV= 1  ZOSOP 'B986','MULTIPLY LOGICAL (128<64) ','MLGR X
               ','RRE N '
         JAS   R11,VER619
         USING *,R11
INS619   MLGR  R1,R2
HEX619   DC    X'B9860012'
NUM619   DC    P'619'
*MCALL #=  1277 LV= 2 VER619   RT1   CCE,INS619,HEX619
VER619   DS    0H
         CLC   INS619,HEX619
RT1_TEST649      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE649
         LTORG 
RT1_CCE649      DS 0H
*MEXIT #=  1277 LV= 2 RT1
*MEXIT #=  1276 LV= 1 ZOSOP
*MCALL #=  1278 LV= 1  ZOSOP 'B987','DIVIDE LOGICAL (64<128) ','DLGR ',X
               'RRE N '
         JAS   R11,VER620
         USING *,R11
INS620   DLGR  R1,R2
HEX620   DC    X'B9870012'
NUM620   DC    P'620'
*MCALL #=  1279 LV= 2 VER620   RT1   CCE,INS620,HEX620
VER620   DS    0H
         CLC   INS620,HEX620
RT1_TEST650      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE650
         LTORG 
RT1_CCE650      DS 0H
*MEXIT #=  1279 LV= 2 RT1
*MEXIT #=  1278 LV= 1 ZOSOP
*MCALL #=  1280 LV= 1  ZOSOP 'B988','ADD LOGICAL WITH CARRY (64) ','ALCX
               GR','RRE C N '
         JAS   R11,VER621
         USING *,R11
INS621   ALCGR R1,R2
HEX621   DC    X'B9880012'
NUM621   DC    P'621'
*MCALL #=  1281 LV= 2 VER621   RT1   CCE,INS621,HEX621
VER621   DS    0H
         CLC   INS621,HEX621
RT1_TEST651      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE651
         LTORG 
RT1_CCE651      DS 0H
*MEXIT #=  1281 LV= 2 RT1
*MEXIT #=  1280 LV= 1 ZOSOP
*MCALL #=  1282 LV= 1  ZOSOP 'B989','SUBTRACT LOGICAL WITH BORROW (64) X
               ','SLBGR','RRE C N '
         JAS   R11,VER622
         USING *,R11
INS622   SLBGR R1,R2
HEX622   DC    X'B9890012'
NUM622   DC    P'622'
*MCALL #=  1283 LV= 2 VER622   RT1   CCE,INS622,HEX622
VER622   DS    0H
         CLC   INS622,HEX622
RT1_TEST652      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE652
         LTORG 
RT1_CCE652      DS 0H
*MEXIT #=  1283 LV= 2 RT1
*MEXIT #=  1282 LV= 1 ZOSOP
*MCALL #=  1284 LV= 1  ZOSOP 'B98A','COMPARE AND SWAP AND PURGE ','CSPGX
                ','RRE C DE'
         JAS   R11,VER623
         USING *,R11
INS623   CSPG  R1,R2
HEX623   DC    X'B98A0012'
NUM623   DC    P'623'
*MCALL #=  1285 LV= 2 VER623   RT1   CCE,INS623,HEX623
VER623   DS    0H
         CLC   INS623,HEX623
RT1_TEST653      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE653
         LTORG 
RT1_CCE653      DS 0H
*MEXIT #=  1285 LV= 2 RT1
*MEXIT #=  1284 LV= 1 ZOSOP
*MCALL #=  1286 LV= 1  ZOSOP 'B98D','EXTRACT PSW ','EPSW ','RRE N3'
         JAS   R11,VER624
         USING *,R11
INS624   EPSW  R1,R2
HEX624   DC    X'B98D0012'
NUM624   DC    P'624'
*MCALL #=  1287 LV= 2 VER624   RT1   CCE,INS624,HEX624
VER624   DS    0H
         CLC   INS624,HEX624
RT1_TEST654      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE654
         LTORG 
RT1_CCE654      DS 0H
*MEXIT #=  1287 LV= 2 RT1
*MEXIT #=  1286 LV= 1 ZOSOP
*MCALL #=  1288 LV= 1  ZOSOP 'B98E','INVALIDATE DAT TABLE ENTRY ','IDTEX
                ','RRF2 DE'
         JAS   R11,VER625
         USING *,R11
INS625   IDTE  R1,R3,R2
HEX625   DC    X'B98E3012'
NUM625   DC    P'625'
*MCALL #=  1289 LV= 2 VER625   RT1   CCE,INS625,HEX625
VER625   DS    0H
         CLC   INS625,HEX625
RT1_TEST655      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE655
         LTORG 
RT1_CCE655      DS 0H
*MEXIT #=  1289 LV= 2 RT1
*MEXIT #=  1288 LV= 1 ZOSOP
*MCALL #=  1290 LV= 1  ZOSOP 'B990','TRANSLATE TWO TO TWO ','TRTT ','REX
               2 C E2'  RPI-454
         JAS   R11,VER626
         USING *,R11
INS626   TRTT  R1,R2,M4
HEX626   DC    X'B9904012'
NUM626   DC    P'626'
*MCALL #=  1291 LV= 2 VER626   RT1   CCE,INS626,HEX626
VER626   DS    0H
         CLC   INS626,HEX626
RT1_TEST656      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE656
         LTORG 
RT1_CCE656      DS 0H
*MEXIT #=  1291 LV= 2 RT1
*MEXIT #=  1290 LV= 1 ZOSOP
*MCALL #=  1292 LV= 1  ZOSOP 'B991','TRANSLATE TWO TO ONE ','TRTO ','REX
               2 C E2'  RPI-454
         JAS   R11,VER627
         USING *,R11
INS627   TRTO  R1,R2,M4
HEX627   DC    X'B9914012'
NUM627   DC    P'627'
*MCALL #=  1293 LV= 2 VER627   RT1   CCE,INS627,HEX627
VER627   DS    0H
         CLC   INS627,HEX627
RT1_TEST657      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE657
         LTORG 
RT1_CCE657      DS 0H
*MEXIT #=  1293 LV= 2 RT1
*MEXIT #=  1292 LV= 1 ZOSOP
*MCALL #=  1294 LV= 1  ZOSOP 'B992','TRANSLATE ONE TO TWO ','TROT ','REX
               2 C E2'  RPI-454
         JAS   R11,VER628
         USING *,R11
INS628   TROT  R1,R2,M4
HEX628   DC    X'B9924012'
NUM628   DC    P'628'
*MCALL #=  1295 LV= 2 VER628   RT1   CCE,INS628,HEX628
VER628   DS    0H
         CLC   INS628,HEX628
RT1_TEST658      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE658
         LTORG 
RT1_CCE658      DS 0H
*MEXIT #=  1295 LV= 2 RT1
*MEXIT #=  1294 LV= 1 ZOSOP
*MCALL #=  1296 LV= 1  ZOSOP 'B993','TRANSLATE ONE TO ONE ','TROO ','REX
               2 C E2'  RPI-454
         JAS   R11,VER629
         USING *,R11
INS629   TROO  R1,R2,M4
HEX629   DC    X'B9934012'
NUM629   DC    P'629'
*MCALL #=  1297 LV= 2 VER629   RT1   CCE,INS629,HEX629
VER629   DS    0H
         CLC   INS629,HEX629
RT1_TEST659      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE659
         LTORG 
RT1_CCE659      DS 0H
*MEXIT #=  1297 LV= 2 RT1
*MEXIT #=  1296 LV= 1 ZOSOP
*MCALL #=  1298 LV= 1  ZOSOP 'B994','LOAD LOGICAL CHARACTER','LLCR','RRX
               E',Z9
         JAS   R11,VER630
         USING *,R11
INS630   LLCR R1,R2
HEX630   DC    X'B9940012'
NUM630   DC    P'630'
*MCALL #=  1299 LV= 2 VER630   RT1   CCE,INS630,HEX630
VER630   DS    0H
         CLC   INS630,HEX630
RT1_TEST660      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE660
         LTORG 
RT1_CCE660      DS 0H
*MEXIT #=  1299 LV= 2 RT1
*MEXIT #=  1298 LV= 1 ZOSOP
*MCALL #=  1300 LV= 1  ZOSOP 'B995','LOAD LOGICAL HALFWORD','LLHR','RREX
               ',Z9
         JAS   R11,VER631
         USING *,R11
INS631   LLHR R1,R2
HEX631   DC    X'B9950012'
NUM631   DC    P'631'
*MCALL #=  1301 LV= 2 VER631   RT1   CCE,INS631,HEX631
VER631   DS    0H
         CLC   INS631,HEX631
RT1_TEST661      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE661
         LTORG 
RT1_CCE661      DS 0H
*MEXIT #=  1301 LV= 2 RT1
*MEXIT #=  1300 LV= 1 ZOSOP
*MCALL #=  1302 LV= 1  ZOSOP 'B996','MULTIPLY LOGICAL (64<32) ','MLR ',X
               'RRE N3'
         JAS   R11,VER632
         USING *,R11
INS632   MLR  R1,R2
HEX632   DC    X'B9960012'
NUM632   DC    P'632'
*MCALL #=  1303 LV= 2 VER632   RT1   CCE,INS632,HEX632
VER632   DS    0H
         CLC   INS632,HEX632
RT1_TEST662      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE662
         LTORG 
RT1_CCE662      DS 0H
*MEXIT #=  1303 LV= 2 RT1
*MEXIT #=  1302 LV= 1 ZOSOP
*MCALL #=  1304 LV= 1  ZOSOP 'B997','DIVIDE LOGICAL (32<64) ','DLR ','RX
               RE N3'
         JAS   R11,VER633
         USING *,R11
INS633   DLR  R1,R2
HEX633   DC    X'B9970012'
NUM633   DC    P'633'
*MCALL #=  1305 LV= 2 VER633   RT1   CCE,INS633,HEX633
VER633   DS    0H
         CLC   INS633,HEX633
RT1_TEST663      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE663
         LTORG 
RT1_CCE663      DS 0H
*MEXIT #=  1305 LV= 2 RT1
*MEXIT #=  1304 LV= 1 ZOSOP
*MCALL #=  1306 LV= 1  ZOSOP 'B998','ADD LOGICAL WITH CARRY (32) ','ALCX
               R ','RRE C N3'
         JAS   R11,VER634
         USING *,R11
INS634   ALCR  R1,R2
HEX634   DC    X'B9980012'
NUM634   DC    P'634'
*MCALL #=  1307 LV= 2 VER634   RT1   CCE,INS634,HEX634
VER634   DS    0H
         CLC   INS634,HEX634
RT1_TEST664      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE664
         LTORG 
RT1_CCE664      DS 0H
*MEXIT #=  1307 LV= 2 RT1
*MEXIT #=  1306 LV= 1 ZOSOP
*MCALL #=  1308 LV= 1  ZOSOP 'B999','SUBTRACT LOGICAL WITH BORROW (32) X
               ','SLBR ','RRE C N3'
         JAS   R11,VER635
         USING *,R11
INS635   SLBR  R1,R2
HEX635   DC    X'B9990012'
NUM635   DC    P'635'
*MCALL #=  1309 LV= 2 VER635   RT1   CCE,INS635,HEX635
VER635   DS    0H
         CLC   INS635,HEX635
RT1_TEST665      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE665
         LTORG 
RT1_CCE665      DS 0H
*MEXIT #=  1309 LV= 2 RT1
*MEXIT #=  1308 LV= 1 ZOSOP
*MCALL #=  1310 LV= 1  ZOSOP 'B99A','EXTRACT PRIMARY ASN AND INSTANCE 'X
               ,'EPAIR','RRE RA'
         JAS   R11,VER636
         USING *,R11
INS636   EPAIR R1,R2
HEX636   DC    X'B99A0012'
NUM636   DC    P'636'
*MCALL #=  1311 LV= 2 VER636   RT1   CCE,INS636,HEX636
VER636   DS    0H
         CLC   INS636,HEX636
RT1_TEST666      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE666
         LTORG 
RT1_CCE666      DS 0H
*MEXIT #=  1311 LV= 2 RT1
*MEXIT #=  1310 LV= 1 ZOSOP
*MCALL #=  1312 LV= 1  ZOSOP 'B99B','EXTRACT SECONDARY ASN AND INSTANCEX
                ','ESAIR','RRE RA'
         JAS   R11,VER637
         USING *,R11
INS637   ESAIR R1,R2
HEX637   DC    X'B99B0012'
NUM637   DC    P'637'
*MCALL #=  1313 LV= 2 VER637   RT1   CCE,INS637,HEX637
VER637   DS    0H
         CLC   INS637,HEX637
RT1_TEST667      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE667
         LTORG 
RT1_CCE667      DS 0H
*MEXIT #=  1313 LV= 2 RT1
*MEXIT #=  1312 LV= 1 ZOSOP
*MCALL #=  1314 LV= 1  ZOSOP 'B99D','EXTRACT AND SET EXTENDED AUTHORITYX
                ','ESEA ','RRE N '
         JAS   R11,VER638
         USING *,R11
INS638   ESEA  R1,R2
HEX638   DC    X'B99D0012'
NUM638   DC    P'638'
*MCALL #=  1315 LV= 2 VER638   RT1   CCE,INS638,HEX638
VER638   DS    0H
         CLC   INS638,HEX638
RT1_TEST668      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE668
         LTORG 
RT1_CCE668      DS 0H
*MEXIT #=  1315 LV= 2 RT1
*MEXIT #=  1314 LV= 1 ZOSOP
*MCALL #=  1316 LV= 1  ZOSOP 'B99E','PROGRAM TRANSFER WITH INSTANCE ','X
               PTI ','RRE RA'
         JAS   R11,VER639
         USING *,R11
INS639   PTI  R1,R2
HEX639   DC    X'B99E0012'
NUM639   DC    P'639'
*MCALL #=  1317 LV= 2 VER639   RT1   CCE,INS639,HEX639
VER639   DS    0H
         CLC   INS639,HEX639
RT1_TEST669      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE669
         LTORG 
RT1_CCE669      DS 0H
*MEXIT #=  1317 LV= 2 RT1
*MEXIT #=  1316 LV= 1 ZOSOP
*MCALL #=  1318 LV= 1  ZOSOP 'B99F','SET SECONDARY ASN WITH INSTANCE ',X
               'SSAIR','RRE RA'
         JAS   R11,VER640
         USING *,R11
INS640   SSAIR R1,R2
HEX640   DC    X'B99F0012'
NUM640   DC    P'640'
*MCALL #=  1319 LV= 2 VER640   RT1   CCE,INS640,HEX640
VER640   DS    0H
         CLC   INS640,HEX640
RT1_TEST670      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE670
         LTORG 
RT1_CCE670      DS 0H
*MEXIT #=  1319 LV= 2 RT1
*MEXIT #=  1318 LV= 1 ZOSOP
*MCALL #=  1320 LV= 1  ZOSOP 'B9A2','Perform Topology Facility','PTF','X
               RRE',14  RPI-817
         JAS   R11,VER641
         USING *,R11
INS641   PTF  R1,R2
HEX641   DC    X'B9A20012'
NUM641   DC    P'641'
*MCALL #=  1321 LV= 2 VER641   RT1   CCE,INS641,HEX641
VER641   DS    0H
         CLC   INS641,HEX641
RT1_TEST671      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE671
         LTORG 
RT1_CCE671      DS 0H
*MEXIT #=  1321 LV= 2 RT1
*MEXIT #=  1320 LV= 1 ZOSOP
*MCALL #=  1322 LV= 1  ZOSOP 'B9AF','Perform Frame Mgt Function','PFMF'X
               ,'RRF5',39  RPI-817
         JAS   R11,VER642
         USING *,R11
INS642   PFMF R1,R2,M3
HEX642   DC    X'B9AF3012'
NUM642   DC    P'642'
*MCALL #=  1323 LV= 2 VER642   RT1   CCE,INS642,HEX642
VER642   DS    0H
         CLC   INS642,HEX642
RT1_TEST672      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE672
         LTORG 
RT1_CCE672      DS 0H
*MEXIT #=  1323 LV= 2 RT1
*MEXIT #=  1322 LV= 1 ZOSOP
*MCALL #=  1324 LV= 1  ZOSOP 'B9AA','LOAD PAGE TABLE ENTRY ADDRESS','LPX
               TEA','RRE',Z9
         JAS   R11,VER643
         USING *,R11
INS643   LPTEA R1,R2
HEX643   DC    X'B9AA0012'
NUM643   DC    P'643'
*MCALL #=  1325 LV= 2 VER643   RT1   CCE,INS643,HEX643
VER643   DS    0H
         CLC   INS643,HEX643
RT1_TEST673      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE673
         LTORG 
RT1_CCE673      DS 0H
*MEXIT #=  1325 LV= 2 RT1
*MEXIT #=  1324 LV= 1 ZOSOP
*MCALL #=  1326 LV= 1  ZOSOP 'B9AE','RESET REFERENCE BITS MULTIPLE','RRX
               BM','RRE'  RPI-1125 Z196
         JAS   R11,VER644
         USING *,R11
INS644   RRBM R1,R2
HEX644   DC    X'B9AE0012'
NUM644   DC    P'644'
*MCALL #=  1327 LV= 2 VER644   RT1   CCE,INS644,HEX644
VER644   DS    0H
         CLC   INS644,HEX644
RT1_TEST674      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE674
         LTORG 
RT1_CCE674      DS 0H
*MEXIT #=  1327 LV= 2 RT1
*MEXIT #=  1326 LV= 1 ZOSOP
*MCALL #=  1328 LV= 1  ZOSOP 'B9B0','CONVERT UTF-8 TO UTF-32 ','CU14 ',X
               'RRE C E3'
         JAS   R11,VER645
         USING *,R11
INS645   CU14  R1,R2
HEX645   DC    X'B9B00012'
NUM645   DC    P'645'
*MCALL #=  1329 LV= 2 VER645   RT1   CCE,INS645,HEX645
VER645   DS    0H
         CLC   INS645,HEX645
RT1_TEST675      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE675
         LTORG 
RT1_CCE675      DS 0H
*MEXIT #=  1329 LV= 2 RT1
*MEXIT #=  1328 LV= 1 ZOSOP
*MCALL #=  1330 LV= 1  ZOSOP 'B9B1','CONVERT UTF-16 TO UTF-32 ','CU24 'X
               ,'RRE C E3'
         JAS   R11,VER646
         USING *,R11
INS646   CU24  R1,R2
HEX646   DC    X'B9B10012'
NUM646   DC    P'646'
*MCALL #=  1331 LV= 2 VER646   RT1   CCE,INS646,HEX646
VER646   DS    0H
         CLC   INS646,HEX646
RT1_TEST676      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE676
         LTORG 
RT1_CCE676      DS 0H
*MEXIT #=  1331 LV= 2 RT1
*MEXIT #=  1330 LV= 1 ZOSOP
*MCALL #=  1332 LV= 1  ZOSOP 'B9B2','CONVERT UTF-32 TO UTF-8 ','CU41 ',X
               'RRE C E3'
         JAS   R11,VER647
         USING *,R11
INS647   CU41  R1,R2
HEX647   DC    X'B9B20012'
NUM647   DC    P'647'
*MCALL #=  1333 LV= 2 VER647   RT1   CCE,INS647,HEX647
VER647   DS    0H
         CLC   INS647,HEX647
RT1_TEST677      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE677
         LTORG 
RT1_CCE677      DS 0H
*MEXIT #=  1333 LV= 2 RT1
*MEXIT #=  1332 LV= 1 ZOSOP
*MCALL #=  1334 LV= 1  ZOSOP 'B9B3','CONVERT UTF-32 TO UTF-16 ','CU42 'X
               ,'RRE C E3'
         JAS   R11,VER648
         USING *,R11
INS648   CU42  R1,R2
HEX648   DC    X'B9B30012'
NUM648   DC    P'648'
*MCALL #=  1335 LV= 2 VER648   RT1   CCE,INS648,HEX648
VER648   DS    0H
         CLC   INS648,HEX648
RT1_TEST678      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE678
         LTORG 
RT1_CCE678      DS 0H
*MEXIT #=  1335 LV= 2 RT1
*MEXIT #=  1334 LV= 1 ZOSOP
*MCALL #=  1336 LV= 1  ZOSOP 'B9BD','Translate and Test Rev Ext','TRTREX
               ','RRF5',39  RPI-817
         JAS   R11,VER649
         USING *,R11
INS649   TRTRE R1,R2,M3
HEX649   DC    X'B9BD3012'
NUM649   DC    P'649'
*MCALL #=  1337 LV= 2 VER649   RT1   CCE,INS649,HEX649
VER649   DS    0H
         CLC   INS649,HEX649
RT1_TEST679      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE679
         LTORG 
RT1_CCE679      DS 0H
*MEXIT #=  1337 LV= 2 RT1
*MEXIT #=  1336 LV= 1 ZOSOP
*MCALL #=  1338 LV= 1  ZOSOP 'B9BE','SEARCH STRING UNICODE ','SRSTU','RX
               RE C E3'
         JAS   R11,VER650
         USING *,R11
INS650   SRSTU R1,R2
HEX650   DC    X'B9BE0012'
NUM650   DC    P'650'
*MCALL #=  1339 LV= 2 VER650   RT1   CCE,INS650,HEX650
VER650   DS    0H
         CLC   INS650,HEX650
RT1_TEST680      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE680
         LTORG 
RT1_CCE680      DS 0H
*MEXIT #=  1339 LV= 2 RT1
*MEXIT #=  1338 LV= 1 ZOSOP
*MCALL #=  1340 LV= 1  ZOSOP 'B9BF','Translate and Test Ext','TRTE','RRX
               F5',39  RPI-817
         JAS   R11,VER651
         USING *,R11
INS651   TRTE R1,R2,M3
HEX651   DC    X'B9BF3012'
NUM651   DC    P'651'
*MCALL #=  1341 LV= 2 VER651   RT1   CCE,INS651,HEX651
VER651   DS    0H
         CLC   INS651,HEX651
RT1_TEST681      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE681
         LTORG 
RT1_CCE681      DS 0H
*MEXIT #=  1341 LV= 2 RT1
*MEXIT #=  1340 LV= 1 ZOSOP
*MCALL #=  1342 LV= 1  ZOSOP 'B9C8','ADD HIGH (32)','AHHHR','RRF5'  RPIX
               -1125 Z196
         JAS   R11,VER652
         USING *,R11
INS652   AHHHR R1,R2,M3
HEX652   DC    X'B9C83012'
NUM652   DC    P'652'
*MCALL #=  1343 LV= 2 VER652   RT1   CCE,INS652,HEX652
VER652   DS    0H
         CLC   INS652,HEX652
RT1_TEST682      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE682
         LTORG 
RT1_CCE682      DS 0H
*MEXIT #=  1343 LV= 2 RT1
*MEXIT #=  1342 LV= 1 ZOSOP
*MCALL #=  1344 LV= 1  ZOSOP 'B9C9','SUBTRACT HIGH (32)','SHHHR','RRF5'X
                 RPI-1125 Z196
         JAS   R11,VER653
         USING *,R11
INS653   SHHHR R1,R2,M3
HEX653   DC    X'B9C93012'
NUM653   DC    P'653'
*MCALL #=  1345 LV= 2 VER653   RT1   CCE,INS653,HEX653
VER653   DS    0H
         CLC   INS653,HEX653
RT1_TEST683      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE683
         LTORG 
RT1_CCE683      DS 0H
*MEXIT #=  1345 LV= 2 RT1
*MEXIT #=  1344 LV= 1 ZOSOP
*MCALL #=  1346 LV= 1  ZOSOP 'B9CA','ADD LOGICAL HIGH (32)','ALHHHR','RX
               RF5'  RPI-1125 Z196
         JAS   R11,VER654
         USING *,R11
INS654   ALHHHR R1,R2,M3
HEX654   DC    X'B9CA3012'
NUM654   DC    P'654'
*MCALL #=  1347 LV= 2 VER654   RT1   CCE,INS654,HEX654
VER654   DS    0H
         CLC   INS654,HEX654
RT1_TEST684      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE684
         LTORG 
RT1_CCE684      DS 0H
*MEXIT #=  1347 LV= 2 RT1
*MEXIT #=  1346 LV= 1 ZOSOP
*MCALL #=  1348 LV= 1  ZOSOP 'B9CB','SUBTRACT LOGICAL HIGH (32)','SLHHHX
               R','RRF5'   RPI-1125 Z196
         JAS   R11,VER655
         USING *,R11
INS655   SLHHHR R1,R2,M3
HEX655   DC    X'B9CB3012'
NUM655   DC    P'655'
*MCALL #=  1349 LV= 2 VER655   RT1   CCE,INS655,HEX655
VER655   DS    0H
         CLC   INS655,HEX655
RT1_TEST685      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE685
         LTORG 
RT1_CCE685      DS 0H
*MEXIT #=  1349 LV= 2 RT1
*MEXIT #=  1348 LV= 1 ZOSOP
*MCALL #=  1350 LV= 1  ZOSOP 'B9CD','COMPARE HIGH (32)','CHHR','RRE'  RX
               PI-1125 Z196
         JAS   R11,VER656
         USING *,R11
INS656   CHHR R1,R2
HEX656   DC    X'B9CD0012'
NUM656   DC    P'656'
*MCALL #=  1351 LV= 2 VER656   RT1   CCE,INS656,HEX656
VER656   DS    0H
         CLC   INS656,HEX656
RT1_TEST686      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE686
         LTORG 
RT1_CCE686      DS 0H
*MEXIT #=  1351 LV= 2 RT1
*MEXIT #=  1350 LV= 1 ZOSOP
*MCALL #=  1352 LV= 1  ZOSOP 'B9CF','COMPARE LOGICAL HIGH (32)','CLHHR'X
               ,'RRE'  RPI-1125 Z196
         JAS   R11,VER657
         USING *,R11
INS657   CLHHR R1,R2
HEX657   DC    X'B9CF0012'
NUM657   DC    P'657'
*MCALL #=  1353 LV= 2 VER657   RT1   CCE,INS657,HEX657
VER657   DS    0H
         CLC   INS657,HEX657
RT1_TEST687      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE687
         LTORG 
RT1_CCE687      DS 0H
*MEXIT #=  1353 LV= 2 RT1
*MEXIT #=  1352 LV= 1 ZOSOP
*MCALL #=  1354 LV= 1  ZOSOP 'B9D8','ADD HIGH (32)','AHHLR','RRF5 '  RPX
               I-1125 Z196
         JAS   R11,VER658
         USING *,R11
INS658   AHHLR R1,R2,M3
HEX658   DC    X'B9D83012'
NUM658   DC    P'658'
*MCALL #=  1355 LV= 2 VER658   RT1   CCE,INS658,HEX658
VER658   DS    0H
         CLC   INS658,HEX658
RT1_TEST688      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE688
         LTORG 
RT1_CCE688      DS 0H
*MEXIT #=  1355 LV= 2 RT1
*MEXIT #=  1354 LV= 1 ZOSOP
*MCALL #=  1356 LV= 1  ZOSOP 'B9D9','SUBTRACT HIGH (32)','SHHLR','RRF5 X
               '  RPI-1125 Z196
         JAS   R11,VER659
         USING *,R11
INS659   SHHLR R1,R2,M3
HEX659   DC    X'B9D93012'
NUM659   DC    P'659'
*MCALL #=  1357 LV= 2 VER659   RT1   CCE,INS659,HEX659
VER659   DS    0H
         CLC   INS659,HEX659
RT1_TEST689      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE689
         LTORG 
RT1_CCE689      DS 0H
*MEXIT #=  1357 LV= 2 RT1
*MEXIT #=  1356 LV= 1 ZOSOP
*MCALL #=  1358 LV= 1  ZOSOP 'B9DA','ADD LOGICAL HIGH (32)','ALHHLR','RX
               RF5 '  RPI-1125 Z196
         JAS   R11,VER660
         USING *,R11
INS660   ALHHLR R1,R2,M3
HEX660   DC    X'B9DA3012'
NUM660   DC    P'660'
*MCALL #=  1359 LV= 2 VER660   RT1   CCE,INS660,HEX660
VER660   DS    0H
         CLC   INS660,HEX660
RT1_TEST690      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE690
         LTORG 
RT1_CCE690      DS 0H
*MEXIT #=  1359 LV= 2 RT1
*MEXIT #=  1358 LV= 1 ZOSOP
*MCALL #=  1360 LV= 1  ZOSOP 'B9DB','SUBTRACT LOGICAL HIGH (32)','SLHHLX
               R','RRF5 '  RPI-1125 Z196
         JAS   R11,VER661
         USING *,R11
INS661   SLHHLR R1,R2,M3
HEX661   DC    X'B9DB3012'
NUM661   DC    P'661'
*MCALL #=  1361 LV= 2 VER661   RT1   CCE,INS661,HEX661
VER661   DS    0H
         CLC   INS661,HEX661
RT1_TEST691      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE691
         LTORG 
RT1_CCE691      DS 0H
*MEXIT #=  1361 LV= 2 RT1
*MEXIT #=  1360 LV= 1 ZOSOP
*MCALL #=  1362 LV= 1  ZOSOP 'B9DD','COMPARE HIGH (32)','CHLR','RRE'  RX
               PI-1125 Z196
         JAS   R11,VER662
         USING *,R11
INS662   CHLR R1,R2
HEX662   DC    X'B9DD0012'
NUM662   DC    P'662'
*MCALL #=  1363 LV= 2 VER662   RT1   CCE,INS662,HEX662
VER662   DS    0H
         CLC   INS662,HEX662
RT1_TEST692      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE692
         LTORG 
RT1_CCE692      DS 0H
*MEXIT #=  1363 LV= 2 RT1
*MEXIT #=  1362 LV= 1 ZOSOP
*MCALL #=  1364 LV= 1  ZOSOP 'B9DF','COMPARE LOGICAL HIGH (32)','CLHLR'X
               ,'RRE'  RPI-1125 Z196
         JAS   R11,VER663
         USING *,R11
INS663   CLHLR R1,R2
HEX663   DC    X'B9DF0012'
NUM663   DC    P'663'
*MCALL #=  1365 LV= 2 VER663   RT1   CCE,INS663,HEX663
VER663   DS    0H
         CLC   INS663,HEX663
RT1_TEST693      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE693
         LTORG 
RT1_CCE693      DS 0H
*MEXIT #=  1365 LV= 2 RT1
*MEXIT #=  1364 LV= 1 ZOSOP
*MCALL #=  1366 LV= 1  ZOSOP 'B9E1','Population Count','POPCNT','RRE' RX
               PI-1125
         JAS   R11,VER664
         USING *,R11
INS664   POPCNT R1,R2
HEX664   DC    X'B9E10012'
NUM664   DC    P'664'
*MCALL #=  1367 LV= 2 VER664   RT1   CCE,INS664,HEX664
VER664   DS    0H
         CLC   INS664,HEX664
RT1_TEST694      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE694
         LTORG 
RT1_CCE694      DS 0H
*MEXIT #=  1367 LV= 2 RT1
*MEXIT #=  1366 LV= 1 ZOSOP
*MCALL #=  1368 LV= 1  ZOSOP 'B9E2','LOAD ON CONDITION (64)','LOCGR','RX
               RF5'  RPI-1125 Z196
         JAS   R11,VER665
         USING *,R11
INS665   LOCGR R1,R2,M3
HEX665   DC    X'B9E23012'
NUM665   DC    P'665'
*MCALL #=  1369 LV= 2 VER665   RT1   CCE,INS665,HEX665
VER665   DS    0H
         CLC   INS665,HEX665
RT1_TEST695      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE695
         LTORG 
RT1_CCE695      DS 0H
*MEXIT #=  1369 LV= 2 RT1
*MEXIT #=  1368 LV= 1 ZOSOP
*MCALL #=  1370 LV= 1  ZOSOP 'B9E4','AND (64)','NGRK','RRF5'  RPI-1125 X
               Z196
         JAS   R11,VER666
         USING *,R11
INS666   NGRK R1,R2,M3
HEX666   DC    X'B9E43012'
NUM666   DC    P'666'
*MCALL #=  1371 LV= 2 VER666   RT1   CCE,INS666,HEX666
VER666   DS    0H
         CLC   INS666,HEX666
RT1_TEST696      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE696
         LTORG 
RT1_CCE696      DS 0H
*MEXIT #=  1371 LV= 2 RT1
*MEXIT #=  1370 LV= 1 ZOSOP
*MCALL #=  1372 LV= 1  ZOSOP 'B9E6','OR (64)','OGRK','RRF5'  RPI-1125 ZX
               196
         JAS   R11,VER667
         USING *,R11
INS667   OGRK R1,R2,M3
HEX667   DC    X'B9E63012'
NUM667   DC    P'667'
*MCALL #=  1373 LV= 2 VER667   RT1   CCE,INS667,HEX667
VER667   DS    0H
         CLC   INS667,HEX667
RT1_TEST697      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE697
         LTORG 
RT1_CCE697      DS 0H
*MEXIT #=  1373 LV= 2 RT1
*MEXIT #=  1372 LV= 1 ZOSOP
*MCALL #=  1374 LV= 1  ZOSOP 'B9E7','EXCLUSIVE OR (64)','XGRK','RRF5'  X
               RPI-1125 Z196
         JAS   R11,VER668
         USING *,R11
INS668   XGRK R1,R2,M3
HEX668   DC    X'B9E73012'
NUM668   DC    P'668'
*MCALL #=  1375 LV= 2 VER668   RT1   CCE,INS668,HEX668
VER668   DS    0H
         CLC   INS668,HEX668
RT1_TEST698      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE698
         LTORG 
RT1_CCE698      DS 0H
*MEXIT #=  1375 LV= 2 RT1
*MEXIT #=  1374 LV= 1 ZOSOP
*MCALL #=  1376 LV= 1  ZOSOP 'B9E8','ADD (64)','AGRK','RRF5'  RPI-1125 X
               Z196
         JAS   R11,VER669
         USING *,R11
INS669   AGRK R1,R2,M3
HEX669   DC    X'B9E83012'
NUM669   DC    P'669'
*MCALL #=  1377 LV= 2 VER669   RT1   CCE,INS669,HEX669
VER669   DS    0H
         CLC   INS669,HEX669
RT1_TEST699      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE699
         LTORG 
RT1_CCE699      DS 0H
*MEXIT #=  1377 LV= 2 RT1
*MEXIT #=  1376 LV= 1 ZOSOP
*MCALL #=  1378 LV= 1  ZOSOP 'B9E9','SUBTRACT (64)','SGRK','RRF5'  RPI-X
               1125 Z196
         JAS   R11,VER670
         USING *,R11
INS670   SGRK R1,R2,M3
HEX670   DC    X'B9E93012'
NUM670   DC    P'670'
*MCALL #=  1379 LV= 2 VER670   RT1   CCE,INS670,HEX670
VER670   DS    0H
         CLC   INS670,HEX670
RT1_TEST700      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE700
         LTORG 
RT1_CCE700      DS 0H
*MEXIT #=  1379 LV= 2 RT1
*MEXIT #=  1378 LV= 1 ZOSOP
*MCALL #=  1380 LV= 1  ZOSOP 'B9EA','ADD LOGICAL (64)','ALGRK','RRF5'  X
               RPI-1125 Z196
         JAS   R11,VER671
         USING *,R11
INS671   ALGRK R1,R2,M3
HEX671   DC    X'B9EA3012'
NUM671   DC    P'671'
*MCALL #=  1381 LV= 2 VER671   RT1   CCE,INS671,HEX671
VER671   DS    0H
         CLC   INS671,HEX671
RT1_TEST701      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE701
         LTORG 
RT1_CCE701      DS 0H
*MEXIT #=  1381 LV= 2 RT1
*MEXIT #=  1380 LV= 1 ZOSOP
*MCALL #=  1382 LV= 1  ZOSOP 'B9EB','SUBTRACT LOGICAL (64)','SLGRK','RRX
               F5'  RPI-1125 Z196
         JAS   R11,VER672
         USING *,R11
INS672   SLGRK R1,R2,M3
HEX672   DC    X'B9EB3012'
NUM672   DC    P'672'
*MCALL #=  1383 LV= 2 VER672   RT1   CCE,INS672,HEX672
VER672   DS    0H
         CLC   INS672,HEX672
RT1_TEST702      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE702
         LTORG 
RT1_CCE702      DS 0H
*MEXIT #=  1383 LV= 2 RT1
*MEXIT #=  1382 LV= 1 ZOSOP
*MCALL #=  1384 LV= 1  ZOSOP 'B9F2','LOAD ON CONDITION (32)','LOCR','RRX
               F5'  RPI-1125 Z196
         JAS   R11,VER673
         USING *,R11
INS673   LOCR R1,R2,M3
HEX673   DC    X'B9F23012'
NUM673   DC    P'673'
*MCALL #=  1385 LV= 2 VER673   RT1   CCE,INS673,HEX673
VER673   DS    0H
         CLC   INS673,HEX673
RT1_TEST703      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE703
         LTORG 
RT1_CCE703      DS 0H
*MEXIT #=  1385 LV= 2 RT1
*MEXIT #=  1384 LV= 1 ZOSOP
*MCALL #=  1386 LV= 1  ZOSOP 'B9F4','AND (32)','NRK','RRF5'  RPI-1125 ZX
               196
         JAS   R11,VER674
         USING *,R11
INS674   NRK  R1,R2,M3
HEX674   DC    X'B9F43012'
NUM674   DC    P'674'
*MCALL #=  1387 LV= 2 VER674   RT1   CCE,INS674,HEX674
VER674   DS    0H
         CLC   INS674,HEX674
RT1_TEST704      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE704
         LTORG 
RT1_CCE704      DS 0H
*MEXIT #=  1387 LV= 2 RT1
*MEXIT #=  1386 LV= 1 ZOSOP
*MCALL #=  1388 LV= 1  ZOSOP 'B9F6','OR (32)','ORK','RRF5'  RPI-1125 Z1X
               96
         JAS   R11,VER675
         USING *,R11
INS675   ORK  R1,R2,M3
HEX675   DC    X'B9F63012'
NUM675   DC    P'675'
*MCALL #=  1389 LV= 2 VER675   RT1   CCE,INS675,HEX675
VER675   DS    0H
         CLC   INS675,HEX675
RT1_TEST705      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE705
         LTORG 
RT1_CCE705      DS 0H
*MEXIT #=  1389 LV= 2 RT1
*MEXIT #=  1388 LV= 1 ZOSOP
*MCALL #=  1390 LV= 1  ZOSOP 'B9F7','EXCLUSIVE OR (32)','XRK','RRF5'  RX
               PI-1125 Z196
         JAS   R11,VER676
         USING *,R11
INS676   XRK  R1,R2,M3
HEX676   DC    X'B9F73012'
NUM676   DC    P'676'
*MCALL #=  1391 LV= 2 VER676   RT1   CCE,INS676,HEX676
VER676   DS    0H
         CLC   INS676,HEX676
RT1_TEST706      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE706
         LTORG 
RT1_CCE706      DS 0H
*MEXIT #=  1391 LV= 2 RT1
*MEXIT #=  1390 LV= 1 ZOSOP
*MCALL #=  1392 LV= 1  ZOSOP 'B9F8','ADD (32)','ARK','RRF5'  RPI-1125 ZX
               196
         JAS   R11,VER677
         USING *,R11
INS677   ARK  R1,R2,M3
HEX677   DC    X'B9F83012'
NUM677   DC    P'677'
*MCALL #=  1393 LV= 2 VER677   RT1   CCE,INS677,HEX677
VER677   DS    0H
         CLC   INS677,HEX677
RT1_TEST707      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE707
         LTORG 
RT1_CCE707      DS 0H
*MEXIT #=  1393 LV= 2 RT1
*MEXIT #=  1392 LV= 1 ZOSOP
*MCALL #=  1394 LV= 1  ZOSOP 'B9F9','SUBTRACT (32)','SRK','RRF5'  RPI-1X
               125 Z196
         JAS   R11,VER678
         USING *,R11
INS678   SRK  R1,R2,M3
HEX678   DC    X'B9F93012'
NUM678   DC    P'678'
*MCALL #=  1395 LV= 2 VER678   RT1   CCE,INS678,HEX678
VER678   DS    0H
         CLC   INS678,HEX678
RT1_TEST708      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE708
         LTORG 
RT1_CCE708      DS 0H
*MEXIT #=  1395 LV= 2 RT1
*MEXIT #=  1394 LV= 1 ZOSOP
*MCALL #=  1396 LV= 1  ZOSOP 'B9FA','ADD LOGICAL (32)','ALRK','RRF5'  RX
               PI-1125 Z196
         JAS   R11,VER679
         USING *,R11
INS679   ALRK R1,R2,M3
HEX679   DC    X'B9FA3012'
NUM679   DC    P'679'
*MCALL #=  1397 LV= 2 VER679   RT1   CCE,INS679,HEX679
VER679   DS    0H
         CLC   INS679,HEX679
RT1_TEST709      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE709
         LTORG 
RT1_CCE709      DS 0H
*MEXIT #=  1397 LV= 2 RT1
*MEXIT #=  1396 LV= 1 ZOSOP
*MCALL #=  1398 LV= 1  ZOSOP 'B9FB','SUBTRACT LOGICAL (32)','SLRK','RRFX
               5'  RPI-1125 Z196
         JAS   R11,VER680
         USING *,R11
INS680   SLRK R1,R2,M3
HEX680   DC    X'B9FB3012'
NUM680   DC    P'680'
*MCALL #=  1399 LV= 2 VER680   RT1   CCE,INS680,HEX680
VER680   DS    0H
         CLC   INS680,HEX680
RT1_TEST710      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE710
         LTORG 
RT1_CCE710      DS 0H
*MEXIT #=  1399 LV= 2 RT1
*MEXIT #=  1398 LV= 1 ZOSOP
*MCALL #=  1400 LV= 1  ZOSOP 'BA ','COMPARE AND SWAP (32) ','CS ','RS CX
                '
         JAS   R11,VER681
         USING *,R11
INS681   CS   R1,R3,S2
HEX681   DC    X'BA13D002'
NUM681   DC    P'681'
*MCALL #=  1401 LV= 2 VER681   RT1   CCE,INS681,HEX681
VER681   DS    0H
         CLC   INS681,HEX681
RT1_TEST711      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE711
         LTORG 
RT1_CCE711      DS 0H
*MEXIT #=  1401 LV= 2 RT1
*MEXIT #=  1400 LV= 1 ZOSOP
*MCALL #=  1402 LV= 1  ZOSOP 'BB ','COMPARE DOUBLE AND SWAP (32) ','CDSX
                ','RS C '
         JAS   R11,VER682
         USING *,R11
INS682   CDS  R1,R3,S2
HEX682   DC    X'BB13D002'
NUM682   DC    P'682'
*MCALL #=  1403 LV= 2 VER682   RT1   CCE,INS682,HEX682
VER682   DS    0H
         CLC   INS682,HEX682
RT1_TEST712      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE712
         LTORG 
RT1_CCE712      DS 0H
*MEXIT #=  1403 LV= 2 RT1
*MEXIT #=  1402 LV= 1 ZOSOP
*MCALL #=  1404 LV= 1  ZOSOP 'BD ','COMPARE LOGICAL C. UNDER MASK (low)X
                ','CLM ','RS C '
         JAS   R11,VER683
         USING *,R11
INS683   CLM  R1,R3,S2
HEX683   DC    X'BD13D002'
NUM683   DC    P'683'
*MCALL #=  1405 LV= 2 VER683   RT1   CCE,INS683,HEX683
VER683   DS    0H
         CLC   INS683,HEX683
RT1_TEST713      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE713
         LTORG 
RT1_CCE713      DS 0H
*MEXIT #=  1405 LV= 2 RT1
*MEXIT #=  1404 LV= 1 ZOSOP
*MCALL #=  1406 LV= 1  ZOSOP 'BE ','STORE CHARACTERS UNDER MASK (low) 'X
               ,'STCM ','RS '
         JAS   R11,VER684
         USING *,R11
INS684   STCM  R1,R3,S2
HEX684   DC    X'BE13D002'
NUM684   DC    P'684'
*MCALL #=  1407 LV= 2 VER684   RT1   CCE,INS684,HEX684
VER684   DS    0H
         CLC   INS684,HEX684
RT1_TEST714      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE714
         LTORG 
RT1_CCE714      DS 0H
*MEXIT #=  1407 LV= 2 RT1
*MEXIT #=  1406 LV= 1 ZOSOP
*MCALL #=  1408 LV= 1  ZOSOP 'BF ','INSERT CHARACTERS UNDER MASK (low) X
               ','ICM ','RS C '
         JAS   R11,VER685
         USING *,R11
INS685   ICM  R1,R3,S2
HEX685   DC    X'BF13D002'
NUM685   DC    P'685'
*MCALL #=  1409 LV= 2 VER685   RT1   CCE,INS685,HEX685
VER685   DS    0H
         CLC   INS685,HEX685
RT1_TEST715      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE715
         LTORG 
RT1_CCE715      DS 0H
*MEXIT #=  1409 LV= 2 RT1
*MEXIT #=  1408 LV= 1 ZOSOP
*MCALL #=  1410 LV= 1  ZOSOP 'C00 ','LOAD ADDRESS RELATIVE LONG ','LARLX
                ','RIL N3'
         JAS   R11,VER686
         USING *,R11
INS686   LARL  M5,*-2
HEX686   DC    X'C050FFFFFFFF'
NUM686   DC    P'686'
*MCALL #=  1411 LV= 2 VER686   RT1   CCE,INS686,HEX686
VER686   DS    0H
         CLC   INS686,HEX686
RT1_TEST716      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE716
         LTORG 
RT1_CCE716      DS 0H
*MEXIT #=  1411 LV= 2 RT1
*MEXIT #=  1410 LV= 1 ZOSOP
*MCALL #=  1412 LV= 1  ZOSOP 'C01','LOAD IMMEDIATE','LGFI','RIL',Z9
         JAS   R11,VER687
         USING *,R11
INS687   LGFI M5,*-2
HEX687   DC    X'C051FFFFFFFF'
NUM687   DC    P'687'
*MCALL #=  1413 LV= 2 VER687   RT1   CCE,INS687,HEX687
VER687   DS    0H
         CLC   INS687,HEX687
RT1_TEST717      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE717
         LTORG 
RT1_CCE717      DS 0H
*MEXIT #=  1413 LV= 2 RT1
*MEXIT #=  1412 LV= 1 ZOSOP
*MCALL #=  1414 LV= 1  ZOSOP 'C04 ','BRANCH RELATIVE ON CONDITION LONG X
               ','BRCL ','RIL N3'
         JAS   R11,VER688
         USING *,R11
INS688   BRCL  M5,*-2
HEX688   DC    X'C054FFFFFFFF'
NUM688   DC    P'688'
*MCALL #=  1415 LV= 2 VER688   RT1   CCE,INS688,HEX688
VER688   DS    0H
         CLC   INS688,HEX688
RT1_TEST718      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE718
         LTORG 
RT1_CCE718      DS 0H
*MEXIT #=  1415 LV= 2 RT1
*MEXIT #=  1414 LV= 1 ZOSOP
*MCALL #=  1416 LV= 1  ZOSOP 'C004','EXTENDED BRANCH LONG','JLNOP','BLXX
               ' RPI-199
         JAS   R11,VER689
         USING *,R11
INS689   JLNOP *-2
HEX689   DC    X'C004FFFFFFFF'
NUM689   DC    P'689'
*MCALL #=  1417 LV= 2 VER689   RT1   CCE,INS689,HEX689
VER689   DS    0H
         CLC   INS689,HEX689
RT1_TEST719      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE719
         LTORG 
RT1_CCE719      DS 0H
*MEXIT #=  1417 LV= 2 RT1
*MEXIT #=  1416 LV= 1 ZOSOP
*MCALL #=  1418 LV= 1  ZOSOP 'C014','EXTENDED BRANCH LONG','BROL','BLX'
         JAS   R11,VER690
         USING *,R11
INS690   BROL *-2
HEX690   DC    X'C014FFFFFFFF'
NUM690   DC    P'690'
*MCALL #=  1419 LV= 2 VER690   RT1   CCE,INS690,HEX690
VER690   DS    0H
         CLC   INS690,HEX690
RT1_TEST720      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE720
         LTORG 
RT1_CCE720      DS 0H
*MEXIT #=  1419 LV= 2 RT1
*MEXIT #=  1418 LV= 1 ZOSOP
*MCALL #=  1420 LV= 1  ZOSOP 'C014','EXTENDED BRANCH LONG','JLO','BLX'
         JAS   R11,VER691
         USING *,R11
INS691   JLO  *-2
HEX691   DC    X'C014FFFFFFFF'
NUM691   DC    P'691'
*MCALL #=  1421 LV= 2 VER691   RT1   CCE,INS691,HEX691
VER691   DS    0H
         CLC   INS691,HEX691
RT1_TEST721      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE721
         LTORG 
RT1_CCE721      DS 0H
*MEXIT #=  1421 LV= 2 RT1
*MEXIT #=  1420 LV= 1 ZOSOP
*MCALL #=  1422 LV= 1  ZOSOP 'C024','EXTENDED BRANCH LONG','BRHL','BLX'
         JAS   R11,VER692
         USING *,R11
INS692   BRHL *-2
HEX692   DC    X'C024FFFFFFFF'
NUM692   DC    P'692'
*MCALL #=  1423 LV= 2 VER692   RT1   CCE,INS692,HEX692
VER692   DS    0H
         CLC   INS692,HEX692
RT1_TEST722      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE722
         LTORG 
RT1_CCE722      DS 0H
*MEXIT #=  1423 LV= 2 RT1
*MEXIT #=  1422 LV= 1 ZOSOP
*MCALL #=  1424 LV= 1  ZOSOP 'C024','EXTENDED BRANCH LONG','BRPL','BLX'
         JAS   R11,VER693
         USING *,R11
INS693   BRPL *-2
HEX693   DC    X'C024FFFFFFFF'
NUM693   DC    P'693'
*MCALL #=  1425 LV= 2 VER693   RT1   CCE,INS693,HEX693
VER693   DS    0H
         CLC   INS693,HEX693
RT1_TEST723      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE723
         LTORG 
RT1_CCE723      DS 0H
*MEXIT #=  1425 LV= 2 RT1
*MEXIT #=  1424 LV= 1 ZOSOP
*MCALL #=  1426 LV= 1  ZOSOP 'C024','EXTENDED BRANCH LONG','JLH','BLX'
         JAS   R11,VER694
         USING *,R11
INS694   JLH  *-2
HEX694   DC    X'C024FFFFFFFF'
NUM694   DC    P'694'
*MCALL #=  1427 LV= 2 VER694   RT1   CCE,INS694,HEX694
VER694   DS    0H
         CLC   INS694,HEX694
RT1_TEST724      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE724
         LTORG 
RT1_CCE724      DS 0H
*MEXIT #=  1427 LV= 2 RT1
*MEXIT #=  1426 LV= 1 ZOSOP
*MCALL #=  1428 LV= 1  ZOSOP 'C024','EXTENDED BRANCH LONG','JLP','BLX'
         JAS   R11,VER695
         USING *,R11
INS695   JLP  *-2
HEX695   DC    X'C024FFFFFFFF'
NUM695   DC    P'695'
*MCALL #=  1429 LV= 2 VER695   RT1   CCE,INS695,HEX695
VER695   DS    0H
         CLC   INS695,HEX695
RT1_TEST725      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE725
         LTORG 
RT1_CCE725      DS 0H
*MEXIT #=  1429 LV= 2 RT1
*MEXIT #=  1428 LV= 1 ZOSOP
*MCALL #=  1430 LV= 1  ZOSOP 'C044','EXTENDED BRANCH LONG','BRLL','BLX'
         JAS   R11,VER696
         USING *,R11
INS696   BRLL *-2
HEX696   DC    X'C044FFFFFFFF'
NUM696   DC    P'696'
*MCALL #=  1431 LV= 2 VER696   RT1   CCE,INS696,HEX696
VER696   DS    0H
         CLC   INS696,HEX696
RT1_TEST726      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE726
         LTORG 
RT1_CCE726      DS 0H
*MEXIT #=  1431 LV= 2 RT1
*MEXIT #=  1430 LV= 1 ZOSOP
*MCALL #=  1432 LV= 1  ZOSOP 'C044','EXTENDED BRANCH LONG','BRML','BLX'
         JAS   R11,VER697
         USING *,R11
INS697   BRML *-2
HEX697   DC    X'C044FFFFFFFF'
NUM697   DC    P'697'
*MCALL #=  1433 LV= 2 VER697   RT1   CCE,INS697,HEX697
VER697   DS    0H
         CLC   INS697,HEX697
RT1_TEST727      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE727
         LTORG 
RT1_CCE727      DS 0H
*MEXIT #=  1433 LV= 2 RT1
*MEXIT #=  1432 LV= 1 ZOSOP
*MCALL #=  1434 LV= 1  ZOSOP 'C044','EXTENDED BRANCH LONG','JLL','BLX'
         JAS   R11,VER698
         USING *,R11
INS698   JLL  *-2
HEX698   DC    X'C044FFFFFFFF'
NUM698   DC    P'698'
*MCALL #=  1435 LV= 2 VER698   RT1   CCE,INS698,HEX698
VER698   DS    0H
         CLC   INS698,HEX698
RT1_TEST728      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE728
         LTORG 
RT1_CCE728      DS 0H
*MEXIT #=  1435 LV= 2 RT1
*MEXIT #=  1434 LV= 1 ZOSOP
*MCALL #=  1436 LV= 1  ZOSOP 'C044','EXTENDED BRANCH LONG','JLM','BLX'
         JAS   R11,VER699
         USING *,R11
INS699   JLM  *-2
HEX699   DC    X'C044FFFFFFFF'
NUM699   DC    P'699'
*MCALL #=  1437 LV= 2 VER699   RT1   CCE,INS699,HEX699
VER699   DS    0H
         CLC   INS699,HEX699
RT1_TEST729      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE729
         LTORG 
RT1_CCE729      DS 0H
*MEXIT #=  1437 LV= 2 RT1
*MEXIT #=  1436 LV= 1 ZOSOP
*MCALL #=  1438 LV= 1  ZOSOP 'C074','EXTENDED BRANCH LONG','BRNEL','BLXX
               '
         JAS   R11,VER700
         USING *,R11
INS700   BRNEL *-2
HEX700   DC    X'C074FFFFFFFF'
NUM700   DC    P'700'
*MCALL #=  1439 LV= 2 VER700   RT1   CCE,INS700,HEX700
VER700   DS    0H
         CLC   INS700,HEX700
RT1_TEST730      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE730
         LTORG 
RT1_CCE730      DS 0H
*MEXIT #=  1439 LV= 2 RT1
*MEXIT #=  1438 LV= 1 ZOSOP
*MCALL #=  1440 LV= 1  ZOSOP 'C074','EXTENDED BRANCH LONG','BRNZL','BLXX
               '
         JAS   R11,VER701
         USING *,R11
INS701   BRNZL *-2
HEX701   DC    X'C074FFFFFFFF'
NUM701   DC    P'701'
*MCALL #=  1441 LV= 2 VER701   RT1   CCE,INS701,HEX701
VER701   DS    0H
         CLC   INS701,HEX701
RT1_TEST731      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE731
         LTORG 
RT1_CCE731      DS 0H
*MEXIT #=  1441 LV= 2 RT1
*MEXIT #=  1440 LV= 1 ZOSOP
*MCALL #=  1442 LV= 1  ZOSOP 'C074','EXTENDED BRANCH LONG','JLNE','BLX'
         JAS   R11,VER702
         USING *,R11
INS702   JLNE *-2
HEX702   DC    X'C074FFFFFFFF'
NUM702   DC    P'702'
*MCALL #=  1443 LV= 2 VER702   RT1   CCE,INS702,HEX702
VER702   DS    0H
         CLC   INS702,HEX702
RT1_TEST732      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE732
         LTORG 
RT1_CCE732      DS 0H
*MEXIT #=  1443 LV= 2 RT1
*MEXIT #=  1442 LV= 1 ZOSOP
*MCALL #=  1444 LV= 1  ZOSOP 'C074','EXTENDED BRANCH LONG','JLNZ','BLX'
         JAS   R11,VER703
         USING *,R11
INS703   JLNZ *-2
HEX703   DC    X'C074FFFFFFFF'
NUM703   DC    P'703'
*MCALL #=  1445 LV= 2 VER703   RT1   CCE,INS703,HEX703
VER703   DS    0H
         CLC   INS703,HEX703
RT1_TEST733      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE733
         LTORG 
RT1_CCE733      DS 0H
*MEXIT #=  1445 LV= 2 RT1
*MEXIT #=  1444 LV= 1 ZOSOP
*MCALL #=  1446 LV= 1  ZOSOP 'C084','EXTENDED BRANCH LONG','BREL','BLX'
         JAS   R11,VER704
         USING *,R11
INS704   BREL *-2
HEX704   DC    X'C084FFFFFFFF'
NUM704   DC    P'704'
*MCALL #=  1447 LV= 2 VER704   RT1   CCE,INS704,HEX704
VER704   DS    0H
         CLC   INS704,HEX704
RT1_TEST734      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE734
         LTORG 
RT1_CCE734      DS 0H
*MEXIT #=  1447 LV= 2 RT1
*MEXIT #=  1446 LV= 1 ZOSOP
*MCALL #=  1448 LV= 1  ZOSOP 'C084','EXTENDED BRANCH LONG','BRZL','BLX'
         JAS   R11,VER705
         USING *,R11
INS705   BRZL *-2
HEX705   DC    X'C084FFFFFFFF'
NUM705   DC    P'705'
*MCALL #=  1449 LV= 2 VER705   RT1   CCE,INS705,HEX705
VER705   DS    0H
         CLC   INS705,HEX705
RT1_TEST735      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE735
         LTORG 
RT1_CCE735      DS 0H
*MEXIT #=  1449 LV= 2 RT1
*MEXIT #=  1448 LV= 1 ZOSOP
*MCALL #=  1450 LV= 1  ZOSOP 'C084','EXTENDED BRANCH LONG','JLE','BLX'
         JAS   R11,VER706
         USING *,R11
INS706   JLE  *-2
HEX706   DC    X'C084FFFFFFFF'
NUM706   DC    P'706'
*MCALL #=  1451 LV= 2 VER706   RT1   CCE,INS706,HEX706
VER706   DS    0H
         CLC   INS706,HEX706
RT1_TEST736      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE736
         LTORG 
RT1_CCE736      DS 0H
*MEXIT #=  1451 LV= 2 RT1
*MEXIT #=  1450 LV= 1 ZOSOP
*MCALL #=  1452 LV= 1  ZOSOP 'C084','EXTENDED BRANCH LONG','JLZ','BLX'
         JAS   R11,VER707
         USING *,R11
INS707   JLZ  *-2
HEX707   DC    X'C084FFFFFFFF'
NUM707   DC    P'707'
*MCALL #=  1453 LV= 2 VER707   RT1   CCE,INS707,HEX707
VER707   DS    0H
         CLC   INS707,HEX707
RT1_TEST737      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE737
         LTORG 
RT1_CCE737      DS 0H
*MEXIT #=  1453 LV= 2 RT1
*MEXIT #=  1452 LV= 1 ZOSOP
*MCALL #=  1454 LV= 1  ZOSOP 'C0B4','EXTENDED BRANCH LONG','BRNLL','BLXX
               '
         JAS   R11,VER708
         USING *,R11
INS708   BRNLL *-2
HEX708   DC    X'C0B4FFFFFFFF'
NUM708   DC    P'708'
*MCALL #=  1455 LV= 2 VER708   RT1   CCE,INS708,HEX708
VER708   DS    0H
         CLC   INS708,HEX708
RT1_TEST738      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE738
         LTORG 
RT1_CCE738      DS 0H
*MEXIT #=  1455 LV= 2 RT1
*MEXIT #=  1454 LV= 1 ZOSOP
*MCALL #=  1456 LV= 1  ZOSOP 'C0B4','EXTENDED BRANCH LONG','BRNML','BLXX
               '
         JAS   R11,VER709
         USING *,R11
INS709   BRNML *-2
HEX709   DC    X'C0B4FFFFFFFF'
NUM709   DC    P'709'
*MCALL #=  1457 LV= 2 VER709   RT1   CCE,INS709,HEX709
VER709   DS    0H
         CLC   INS709,HEX709
RT1_TEST739      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE739
         LTORG 
RT1_CCE739      DS 0H
*MEXIT #=  1457 LV= 2 RT1
*MEXIT #=  1456 LV= 1 ZOSOP
*MCALL #=  1458 LV= 1  ZOSOP 'C0B4','EXTENDED BRANCH LONG','JLNL','BLX'
         JAS   R11,VER710
         USING *,R11
INS710   JLNL *-2
HEX710   DC    X'C0B4FFFFFFFF'
NUM710   DC    P'710'
*MCALL #=  1459 LV= 2 VER710   RT1   CCE,INS710,HEX710
VER710   DS    0H
         CLC   INS710,HEX710
RT1_TEST740      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE740
         LTORG 
RT1_CCE740      DS 0H
*MEXIT #=  1459 LV= 2 RT1
*MEXIT #=  1458 LV= 1 ZOSOP
*MCALL #=  1460 LV= 1  ZOSOP 'C0B4','EXTENDED BRANCH LONG','JLNM','BLX'
         JAS   R11,VER711
         USING *,R11
INS711   JLNM *-2
HEX711   DC    X'C0B4FFFFFFFF'
NUM711   DC    P'711'
*MCALL #=  1461 LV= 2 VER711   RT1   CCE,INS711,HEX711
VER711   DS    0H
         CLC   INS711,HEX711
RT1_TEST741      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE741
         LTORG 
RT1_CCE741      DS 0H
*MEXIT #=  1461 LV= 2 RT1
*MEXIT #=  1460 LV= 1 ZOSOP
*MCALL #=  1462 LV= 1  ZOSOP 'C0D4','EXTENDED BRANCH LONG','BRNHL','BLXX
               '
         JAS   R11,VER712
         USING *,R11
INS712   BRNHL *-2
HEX712   DC    X'C0D4FFFFFFFF'
NUM712   DC    P'712'
*MCALL #=  1463 LV= 2 VER712   RT1   CCE,INS712,HEX712
VER712   DS    0H
         CLC   INS712,HEX712
RT1_TEST742      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE742
         LTORG 
RT1_CCE742      DS 0H
*MEXIT #=  1463 LV= 2 RT1
*MEXIT #=  1462 LV= 1 ZOSOP
*MCALL #=  1464 LV= 1  ZOSOP 'C0D4','EXTENDED BRANCH LONG','BRNPL','BLXX
               '
         JAS   R11,VER713
         USING *,R11
INS713   BRNPL *-2
HEX713   DC    X'C0D4FFFFFFFF'
NUM713   DC    P'713'
*MCALL #=  1465 LV= 2 VER713   RT1   CCE,INS713,HEX713
VER713   DS    0H
         CLC   INS713,HEX713
RT1_TEST743      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE743
         LTORG 
RT1_CCE743      DS 0H
*MEXIT #=  1465 LV= 2 RT1
*MEXIT #=  1464 LV= 1 ZOSOP
*MCALL #=  1466 LV= 1  ZOSOP 'C0D4','EXTENDED BRANCH LONG','JLNH','BLX'
         JAS   R11,VER714
         USING *,R11
INS714   JLNH *-2
HEX714   DC    X'C0D4FFFFFFFF'
NUM714   DC    P'714'
*MCALL #=  1467 LV= 2 VER714   RT1   CCE,INS714,HEX714
VER714   DS    0H
         CLC   INS714,HEX714
RT1_TEST744      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE744
         LTORG 
RT1_CCE744      DS 0H
*MEXIT #=  1467 LV= 2 RT1
*MEXIT #=  1466 LV= 1 ZOSOP
*MCALL #=  1468 LV= 1  ZOSOP 'C0D4','EXTENDED BRANCH LONG','JLNP','BLX'
         JAS   R11,VER715
         USING *,R11
INS715   JLNP *-2
HEX715   DC    X'C0D4FFFFFFFF'
NUM715   DC    P'715'
*MCALL #=  1469 LV= 2 VER715   RT1   CCE,INS715,HEX715
VER715   DS    0H
         CLC   INS715,HEX715
RT1_TEST745      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE745
         LTORG 
RT1_CCE745      DS 0H
*MEXIT #=  1469 LV= 2 RT1
*MEXIT #=  1468 LV= 1 ZOSOP
*MCALL #=  1470 LV= 1  ZOSOP 'C0E4','EXTENDED BRANCH LONG','BRNOL','BLXX
               '
         JAS   R11,VER716
         USING *,R11
INS716   BRNOL *-2
HEX716   DC    X'C0E4FFFFFFFF'
NUM716   DC    P'716'
*MCALL #=  1471 LV= 2 VER716   RT1   CCE,INS716,HEX716
VER716   DS    0H
         CLC   INS716,HEX716
RT1_TEST746      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE746
         LTORG 
RT1_CCE746      DS 0H
*MEXIT #=  1471 LV= 2 RT1
*MEXIT #=  1470 LV= 1 ZOSOP
*MCALL #=  1472 LV= 1  ZOSOP 'C0E4','EXTENDED BRANCH LONG','JLNO','BLX'
         JAS   R11,VER717
         USING *,R11
INS717   JLNO *-2
HEX717   DC    X'C0E4FFFFFFFF'
NUM717   DC    P'717'
*MCALL #=  1473 LV= 2 VER717   RT1   CCE,INS717,HEX717
VER717   DS    0H
         CLC   INS717,HEX717
RT1_TEST747      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE747
         LTORG 
RT1_CCE747      DS 0H
*MEXIT #=  1473 LV= 2 RT1
*MEXIT #=  1472 LV= 1 ZOSOP
*MCALL #=  1474 LV= 1  ZOSOP 'C0F4','EXTENDED BRANCH LONG','BRUL','BLX'
         JAS   R11,VER718
         USING *,R11
INS718   BRUL *-2
HEX718   DC    X'C0F4FFFFFFFF'
NUM718   DC    P'718'
*MCALL #=  1475 LV= 2 VER718   RT1   CCE,INS718,HEX718
VER718   DS    0H
         CLC   INS718,HEX718
RT1_TEST748      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE748
         LTORG 
RT1_CCE748      DS 0H
*MEXIT #=  1475 LV= 2 RT1
*MEXIT #=  1474 LV= 1 ZOSOP
*MCALL #=  1476 LV= 1  ZOSOP 'C0F4','EXTENDED BRANCH LONG','JLU','BLX'
         JAS   R11,VER719
         USING *,R11
INS719   JLU  *-2
HEX719   DC    X'C0F4FFFFFFFF'
NUM719   DC    P'719'
*MCALL #=  1477 LV= 2 VER719   RT1   CCE,INS719,HEX719
VER719   DS    0H
         CLC   INS719,HEX719
RT1_TEST749      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE749
         LTORG 
RT1_CCE749      DS 0H
*MEXIT #=  1477 LV= 2 RT1
*MEXIT #=  1476 LV= 1 ZOSOP
*MCALL #=  1478 LV= 1  ZOSOP 'C05 ','BRANCH RELATIVE AND SAVE LONG ','BX
               RASL','RIL N3'
         JAS   R11,VER720
         USING *,R11
INS720   BRASL M5,*-2
HEX720   DC    X'C055FFFFFFFF'
NUM720   DC    P'720'
*MCALL #=  1479 LV= 2 VER720   RT1   CCE,INS720,HEX720
VER720   DS    0H
         CLC   INS720,HEX720
RT1_TEST750      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE750
         LTORG 
RT1_CCE750      DS 0H
*MEXIT #=  1479 LV= 2 RT1
*MEXIT #=  1478 LV= 1 ZOSOP
*MCALL #=  1480 LV= 1  ZOSOP 'C05','RELATIVE BRANCH AND SAVE','JASL','RX
               IL'
         JAS   R11,VER721
         USING *,R11
INS721   JASL M5,*-2
HEX721   DC    X'C055FFFFFFFF'
NUM721   DC    P'721'
*MCALL #=  1481 LV= 2 VER721   RT1   CCE,INS721,HEX721
VER721   DS    0H
         CLC   INS721,HEX721
RT1_TEST751      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE751
         LTORG 
RT1_CCE751      DS 0H
*MEXIT #=  1481 LV= 2 RT1
*MEXIT #=  1480 LV= 1 ZOSOP
*MCALL #=  1482 LV= 1  ZOSOP 'C06','EXCLUSIVE OR IMMEDIATE','XIHF','RILX
               ',Z9
         JAS   R11,VER722
         USING *,R11
INS722   XIHF M5,*-2
HEX722   DC    X'C056FFFFFFFF'
NUM722   DC    P'722'
*MCALL #=  1483 LV= 2 VER722   RT1   CCE,INS722,HEX722
VER722   DS    0H
         CLC   INS722,HEX722
RT1_TEST752      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE752
         LTORG 
RT1_CCE752      DS 0H
*MEXIT #=  1483 LV= 2 RT1
*MEXIT #=  1482 LV= 1 ZOSOP
*MCALL #=  1484 LV= 1  ZOSOP 'C07','EXCLUSIVE OR IMMEDIATE','XILF','RILX
               ',Z9
         JAS   R11,VER723
         USING *,R11
INS723   XILF M5,*-2
HEX723   DC    X'C057FFFFFFFF'
NUM723   DC    P'723'
*MCALL #=  1485 LV= 2 VER723   RT1   CCE,INS723,HEX723
VER723   DS    0H
         CLC   INS723,HEX723
RT1_TEST753      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE753
         LTORG 
RT1_CCE753      DS 0H
*MEXIT #=  1485 LV= 2 RT1
*MEXIT #=  1484 LV= 1 ZOSOP
*MCALL #=  1486 LV= 1  ZOSOP 'C08','INSERT IMMEDIATE','IIHF','RIL',Z9
         JAS   R11,VER724
         USING *,R11
INS724   IIHF M5,*-2
HEX724   DC    X'C058FFFFFFFF'
NUM724   DC    P'724'
*MCALL #=  1487 LV= 2 VER724   RT1   CCE,INS724,HEX724
VER724   DS    0H
         CLC   INS724,HEX724
RT1_TEST754      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE754
         LTORG 
RT1_CCE754      DS 0H
*MEXIT #=  1487 LV= 2 RT1
*MEXIT #=  1486 LV= 1 ZOSOP
*MCALL #=  1488 LV= 1  ZOSOP 'C09','INSERT IMMEDIATE','IILF','RIL',Z9
         JAS   R11,VER725
         USING *,R11
INS725   IILF M5,*-2
HEX725   DC    X'C059FFFFFFFF'
NUM725   DC    P'725'
*MCALL #=  1489 LV= 2 VER725   RT1   CCE,INS725,HEX725
VER725   DS    0H
         CLC   INS725,HEX725
RT1_TEST755      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE755
         LTORG 
RT1_CCE755      DS 0H
*MEXIT #=  1489 LV= 2 RT1
*MEXIT #=  1488 LV= 1 ZOSOP
*MCALL #=  1490 LV= 1  ZOSOP 'C0A','AND IMMEDIATE','NIHF','RIL',Z9
         JAS   R11,VER726
         USING *,R11
INS726   NIHF M5,*-2
HEX726   DC    X'C05AFFFFFFFF'
NUM726   DC    P'726'
*MCALL #=  1491 LV= 2 VER726   RT1   CCE,INS726,HEX726
VER726   DS    0H
         CLC   INS726,HEX726
RT1_TEST756      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE756
         LTORG 
RT1_CCE756      DS 0H
*MEXIT #=  1491 LV= 2 RT1
*MEXIT #=  1490 LV= 1 ZOSOP
*MCALL #=  1492 LV= 1  ZOSOP 'C0B','AND IMMEDIATE','NILF','RIL',Z9
         JAS   R11,VER727
         USING *,R11
INS727   NILF M5,*-2
HEX727   DC    X'C05BFFFFFFFF'
NUM727   DC    P'727'
*MCALL #=  1493 LV= 2 VER727   RT1   CCE,INS727,HEX727
VER727   DS    0H
         CLC   INS727,HEX727
RT1_TEST757      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE757
         LTORG 
RT1_CCE757      DS 0H
*MEXIT #=  1493 LV= 2 RT1
*MEXIT #=  1492 LV= 1 ZOSOP
*MCALL #=  1494 LV= 1  ZOSOP 'C0C','OR IMMEDIATE','OIHF','RIL',Z9
         JAS   R11,VER728
         USING *,R11
INS728   OIHF M5,*-2
HEX728   DC    X'C05CFFFFFFFF'
NUM728   DC    P'728'
*MCALL #=  1495 LV= 2 VER728   RT1   CCE,INS728,HEX728
VER728   DS    0H
         CLC   INS728,HEX728
RT1_TEST758      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE758
         LTORG 
RT1_CCE758      DS 0H
*MEXIT #=  1495 LV= 2 RT1
*MEXIT #=  1494 LV= 1 ZOSOP
*MCALL #=  1496 LV= 1  ZOSOP 'C0D','OR IMMEDIATE','OILF','RIL',Z9
         JAS   R11,VER729
         USING *,R11
INS729   OILF M5,*-2
HEX729   DC    X'C05DFFFFFFFF'
NUM729   DC    P'729'
*MCALL #=  1497 LV= 2 VER729   RT1   CCE,INS729,HEX729
VER729   DS    0H
         CLC   INS729,HEX729
RT1_TEST759      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE759
         LTORG 
RT1_CCE759      DS 0H
*MEXIT #=  1497 LV= 2 RT1
*MEXIT #=  1496 LV= 1 ZOSOP
*MCALL #=  1498 LV= 1  ZOSOP 'C0E','LOAD LOGICAL IMMEDIATE','LLIHF','RIX
               L',Z9
         JAS   R11,VER730
         USING *,R11
INS730   LLIHF M5,*-2
HEX730   DC    X'C05EFFFFFFFF'
NUM730   DC    P'730'
*MCALL #=  1499 LV= 2 VER730   RT1   CCE,INS730,HEX730
VER730   DS    0H
         CLC   INS730,HEX730
RT1_TEST760      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE760
         LTORG 
RT1_CCE760      DS 0H
*MEXIT #=  1499 LV= 2 RT1
*MEXIT #=  1498 LV= 1 ZOSOP
*MCALL #=  1500 LV= 1  ZOSOP 'C0F','LOAD LOGICAL IMMEDIATE','LLILF','RIX
               L',Z9
         JAS   R11,VER731
         USING *,R11
INS731   LLILF M5,*-2
HEX731   DC    X'C05FFFFFFFFF'
NUM731   DC    P'731'
*MCALL #=  1501 LV= 2 VER731   RT1   CCE,INS731,HEX731
VER731   DS    0H
         CLC   INS731,HEX731
RT1_TEST761      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE761
         LTORG 
RT1_CCE761      DS 0H
*MEXIT #=  1501 LV= 2 RT1
*MEXIT #=  1500 LV= 1 ZOSOP
*MCALL #=  1502 LV= 1  ZOSOP 'C20','Multiply Single Immediate','MSGFI',X
               'RIL',16  RPI-817
         JAS   R11,VER732
         USING *,R11
INS732   MSGFI M5,*-2
HEX732   DC    X'C250FFFFFFFF'
NUM732   DC    P'732'
*MCALL #=  1503 LV= 2 VER732   RT1   CCE,INS732,HEX732
VER732   DS    0H
         CLC   INS732,HEX732
RT1_TEST762      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE762
         LTORG 
RT1_CCE762      DS 0H
*MEXIT #=  1503 LV= 2 RT1
*MEXIT #=  1502 LV= 1 ZOSOP
*MCALL #=  1504 LV= 1  ZOSOP 'C21','Multiply Single Immediate','MSFI','X
               RIL',16  RPI-817
         JAS   R11,VER733
         USING *,R11
INS733   MSFI M5,*-2
HEX733   DC    X'C251FFFFFFFF'
NUM733   DC    P'733'
*MCALL #=  1505 LV= 2 VER733   RT1   CCE,INS733,HEX733
VER733   DS    0H
         CLC   INS733,HEX733
RT1_TEST763      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE763
         LTORG 
RT1_CCE763      DS 0H
*MEXIT #=  1505 LV= 2 RT1
*MEXIT #=  1504 LV= 1 ZOSOP
*MCALL #=  1506 LV= 1  ZOSOP 'C24','SUBTRACT LOGICAL IMMEDIATE','SLGFI'X
               ,'RIL',Z9
         JAS   R11,VER734
         USING *,R11
INS734   SLGFI M5,*-2
HEX734   DC    X'C254FFFFFFFF'
NUM734   DC    P'734'
*MCALL #=  1507 LV= 2 VER734   RT1   CCE,INS734,HEX734
VER734   DS    0H
         CLC   INS734,HEX734
RT1_TEST764      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE764
         LTORG 
RT1_CCE764      DS 0H
*MEXIT #=  1507 LV= 2 RT1
*MEXIT #=  1506 LV= 1 ZOSOP
*MCALL #=  1508 LV= 1  ZOSOP 'C25','SUBTRACT LOGICAL IMMEDIATE','SLFI',X
               'RIL',Z9
         JAS   R11,VER735
         USING *,R11
INS735   SLFI M5,*-2
HEX735   DC    X'C255FFFFFFFF'
NUM735   DC    P'735'
*MCALL #=  1509 LV= 2 VER735   RT1   CCE,INS735,HEX735
VER735   DS    0H
         CLC   INS735,HEX735
RT1_TEST765      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE765
         LTORG 
RT1_CCE765      DS 0H
*MEXIT #=  1509 LV= 2 RT1
*MEXIT #=  1508 LV= 1 ZOSOP
*MCALL #=  1510 LV= 1  ZOSOP 'C28','ADD IMMEDIATE','AGFI','RIL',Z9
         JAS   R11,VER736
         USING *,R11
INS736   AGFI M5,*-2
HEX736   DC    X'C258FFFFFFFF'
NUM736   DC    P'736'
*MCALL #=  1511 LV= 2 VER736   RT1   CCE,INS736,HEX736
VER736   DS    0H
         CLC   INS736,HEX736
RT1_TEST766      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE766
         LTORG 
RT1_CCE766      DS 0H
*MEXIT #=  1511 LV= 2 RT1
*MEXIT #=  1510 LV= 1 ZOSOP
*MCALL #=  1512 LV= 1  ZOSOP 'C29','ADD IMMEDIATE','AFI','RIL',Z9
         JAS   R11,VER737
         USING *,R11
INS737   AFI  M5,*-2
HEX737   DC    X'C259FFFFFFFF'
NUM737   DC    P'737'
*MCALL #=  1513 LV= 2 VER737   RT1   CCE,INS737,HEX737
VER737   DS    0H
         CLC   INS737,HEX737
RT1_TEST767      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE767
         LTORG 
RT1_CCE767      DS 0H
*MEXIT #=  1513 LV= 2 RT1
*MEXIT #=  1512 LV= 1 ZOSOP
*MCALL #=  1514 LV= 1  ZOSOP 'C2A','ADD LOGICAL IMMEDIATE','ALGFI','RILX
               ',Z9
         JAS   R11,VER738
         USING *,R11
INS738   ALGFI M5,*-2
HEX738   DC    X'C25AFFFFFFFF'
NUM738   DC    P'738'
*MCALL #=  1515 LV= 2 VER738   RT1   CCE,INS738,HEX738
VER738   DS    0H
         CLC   INS738,HEX738
RT1_TEST768      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE768
         LTORG 
RT1_CCE768      DS 0H
*MEXIT #=  1515 LV= 2 RT1
*MEXIT #=  1514 LV= 1 ZOSOP
*MCALL #=  1516 LV= 1  ZOSOP 'C2B','ADD LOGICAL IMMEDIATE','ALFI','RIL'X
               ,Z9
         JAS   R11,VER739
         USING *,R11
INS739   ALFI M5,*-2
HEX739   DC    X'C25BFFFFFFFF'
NUM739   DC    P'739'
*MCALL #=  1517 LV= 2 VER739   RT1   CCE,INS739,HEX739
VER739   DS    0H
         CLC   INS739,HEX739
RT1_TEST769      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE769
         LTORG 
RT1_CCE769      DS 0H
*MEXIT #=  1517 LV= 2 RT1
*MEXIT #=  1516 LV= 1 ZOSOP
*MCALL #=  1518 LV= 1  ZOSOP 'C2C','COMPARE IMMEDIATE','CGFI','RIL',Z9
         JAS   R11,VER740
         USING *,R11
INS740   CGFI M5,*-2
HEX740   DC    X'C25CFFFFFFFF'
NUM740   DC    P'740'
*MCALL #=  1519 LV= 2 VER740   RT1   CCE,INS740,HEX740
VER740   DS    0H
         CLC   INS740,HEX740
RT1_TEST770      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE770
         LTORG 
RT1_CCE770      DS 0H
*MEXIT #=  1519 LV= 2 RT1
*MEXIT #=  1518 LV= 1 ZOSOP
*MCALL #=  1520 LV= 1  ZOSOP 'C2D','COMPARE IMMEDIATE','CFI','RIL',Z9
         JAS   R11,VER741
         USING *,R11
INS741   CFI  M5,*-2
HEX741   DC    X'C25DFFFFFFFF'
NUM741   DC    P'741'
*MCALL #=  1521 LV= 2 VER741   RT1   CCE,INS741,HEX741
VER741   DS    0H
         CLC   INS741,HEX741
RT1_TEST771      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE771
         LTORG 
RT1_CCE771      DS 0H
*MEXIT #=  1521 LV= 2 RT1
*MEXIT #=  1520 LV= 1 ZOSOP
*MCALL #=  1522 LV= 1  ZOSOP 'C2E','COMPARE LOGICAL IMMEDIATE','CLGFI',X
               'RIL',Z9
         JAS   R11,VER742
         USING *,R11
INS742   CLGFI M5,*-2
HEX742   DC    X'C25EFFFFFFFF'
NUM742   DC    P'742'
*MCALL #=  1523 LV= 2 VER742   RT1   CCE,INS742,HEX742
VER742   DS    0H
         CLC   INS742,HEX742
RT1_TEST772      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE772
         LTORG 
RT1_CCE772      DS 0H
*MEXIT #=  1523 LV= 2 RT1
*MEXIT #=  1522 LV= 1 ZOSOP
*MCALL #=  1524 LV= 1  ZOSOP 'C2F','COMPARE LOGICAL IMMEDIATE','CLFI','X
               RIL',Z9
         JAS   R11,VER743
         USING *,R11
INS743   CLFI M5,*-2
HEX743   DC    X'C25FFFFFFFFF'
NUM743   DC    P'743'
*MCALL #=  1525 LV= 2 VER743   RT1   CCE,INS743,HEX743
VER743   DS    0H
         CLC   INS743,HEX743
RT1_TEST773      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE773
         LTORG 
RT1_CCE773      DS 0H
*MEXIT #=  1525 LV= 2 RT1
*MEXIT #=  1524 LV= 1 ZOSOP
*MCALL #=  1526 LV= 1  ZOSOP 'C42','Load Logical Halfword Relative','LLX
               HRL','RIL',16 RPI-817
         JAS   R11,VER744
         USING *,R11
INS744   LLHRL M5,*-2
HEX744   DC    X'C452FFFFFFFF'
NUM744   DC    P'744'
*MCALL #=  1527 LV= 2 VER744   RT1   CCE,INS744,HEX744
VER744   DS    0H
         CLC   INS744,HEX744
RT1_TEST774      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE774
         LTORG 
RT1_CCE774      DS 0H
*MEXIT #=  1527 LV= 2 RT1
*MEXIT #=  1526 LV= 1 ZOSOP
*MCALL #=  1528 LV= 1  ZOSOP 'C44','Load Halfword Relative','LGHRL','RIX
               L',16  RPI-817
         JAS   R11,VER745
         USING *,R11
INS745   LGHRL M5,*-2
HEX745   DC    X'C454FFFFFFFF'
NUM745   DC    P'745'
*MCALL #=  1529 LV= 2 VER745   RT1   CCE,INS745,HEX745
VER745   DS    0H
         CLC   INS745,HEX745
RT1_TEST775      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE775
         LTORG 
RT1_CCE775      DS 0H
*MEXIT #=  1529 LV= 2 RT1
*MEXIT #=  1528 LV= 1 ZOSOP
*MCALL #=  1530 LV= 1  ZOSOP 'C45','Load Halfword Relative','LHRL','RILX
               ',16  RPI-817
         JAS   R11,VER746
         USING *,R11
INS746   LHRL M5,*-2
HEX746   DC    X'C455FFFFFFFF'
NUM746   DC    P'746'
*MCALL #=  1531 LV= 2 VER746   RT1   CCE,INS746,HEX746
VER746   DS    0H
         CLC   INS746,HEX746
RT1_TEST776      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE776
         LTORG 
RT1_CCE776      DS 0H
*MEXIT #=  1531 LV= 2 RT1
*MEXIT #=  1530 LV= 1 ZOSOP
*MCALL #=  1532 LV= 1  ZOSOP 'C46','Load Logical Halfword Rel','LLGHRL'X
               ,'RIL',16  RPI-817
         JAS   R11,VER747
         USING *,R11
INS747   LLGHRL M5,*-2
HEX747   DC    X'C456FFFFFFFF'
NUM747   DC    P'747'
*MCALL #=  1533 LV= 2 VER747   RT1   CCE,INS747,HEX747
VER747   DS    0H
         CLC   INS747,HEX747
RT1_TEST777      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE777
         LTORG 
RT1_CCE777      DS 0H
*MEXIT #=  1533 LV= 2 RT1
*MEXIT #=  1532 LV= 1 ZOSOP
*MCALL #=  1534 LV= 1  ZOSOP 'C47','Store Halfword Relative','STHRL','RX
               IL',16  RPI-817
         JAS   R11,VER748
         USING *,R11
INS748   STHRL M5,*-2
HEX748   DC    X'C457FFFFFFFF'
NUM748   DC    P'748'
*MCALL #=  1535 LV= 2 VER748   RT1   CCE,INS748,HEX748
VER748   DS    0H
         CLC   INS748,HEX748
RT1_TEST778      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE778
         LTORG 
RT1_CCE778      DS 0H
*MEXIT #=  1535 LV= 2 RT1
*MEXIT #=  1534 LV= 1 ZOSOP
*MCALL #=  1536 LV= 1  ZOSOP 'C48','Load Relative','LGRL','RIL',16  RPIX
               -817
         JAS   R11,VER749
         USING *,R11
INS749   LGRL M5,*-2
HEX749   DC    X'C458FFFFFFFF'
NUM749   DC    P'749'
*MCALL #=  1537 LV= 2 VER749   RT1   CCE,INS749,HEX749
VER749   DS    0H
         CLC   INS749,HEX749
RT1_TEST779      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE779
         LTORG 
RT1_CCE779      DS 0H
*MEXIT #=  1537 LV= 2 RT1
*MEXIT #=  1536 LV= 1 ZOSOP
*MCALL #=  1538 LV= 1  ZOSOP 'C4B','Store Relative','STGRL','RIL',16  RX
               PI-817
         JAS   R11,VER750
         USING *,R11
INS750   STGRL M5,*-2
HEX750   DC    X'C45BFFFFFFFF'
NUM750   DC    P'750'
*MCALL #=  1539 LV= 2 VER750   RT1   CCE,INS750,HEX750
VER750   DS    0H
         CLC   INS750,HEX750
RT1_TEST780      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE780
         LTORG 
RT1_CCE780      DS 0H
*MEXIT #=  1539 LV= 2 RT1
*MEXIT #=  1538 LV= 1 ZOSOP
*MCALL #=  1540 LV= 1  ZOSOP 'C4C','Load Relative','LGFRL','RIL',16  RPX
               I-817
         JAS   R11,VER751
         USING *,R11
INS751   LGFRL M5,*-2
HEX751   DC    X'C45CFFFFFFFF'
NUM751   DC    P'751'
*MCALL #=  1541 LV= 2 VER751   RT1   CCE,INS751,HEX751
VER751   DS    0H
         CLC   INS751,HEX751
RT1_TEST781      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE781
         LTORG 
RT1_CCE781      DS 0H
*MEXIT #=  1541 LV= 2 RT1
*MEXIT #=  1540 LV= 1 ZOSOP
*MCALL #=  1542 LV= 1  ZOSOP 'C4D','Load Relative','LRL','RIL',16  RPI-X
               817
         JAS   R11,VER752
         USING *,R11
INS752   LRL  M5,*-2
HEX752   DC    X'C45DFFFFFFFF'
NUM752   DC    P'752'
*MCALL #=  1543 LV= 2 VER752   RT1   CCE,INS752,HEX752
VER752   DS    0H
         CLC   INS752,HEX752
RT1_TEST782      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE782
         LTORG 
RT1_CCE782      DS 0H
*MEXIT #=  1543 LV= 2 RT1
*MEXIT #=  1542 LV= 1 ZOSOP
*MCALL #=  1544 LV= 1  ZOSOP 'C4E','Load Logical Relative','LLGFRL','RIX
               L',16  RPI-817
         JAS   R11,VER753
         USING *,R11
INS753   LLGFRL M5,*-2
HEX753   DC    X'C45EFFFFFFFF'
NUM753   DC    P'753'
*MCALL #=  1545 LV= 2 VER753   RT1   CCE,INS753,HEX753
VER753   DS    0H
         CLC   INS753,HEX753
RT1_TEST783      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE783
         LTORG 
RT1_CCE783      DS 0H
*MEXIT #=  1545 LV= 2 RT1
*MEXIT #=  1544 LV= 1 ZOSOP
*MCALL #=  1546 LV= 1  ZOSOP 'C4F','Store Relative','STRL','RIL',16  RPX
               I-817
         JAS   R11,VER754
         USING *,R11
INS754   STRL M5,*-2
HEX754   DC    X'C45FFFFFFFFF'
NUM754   DC    P'754'
*MCALL #=  1547 LV= 2 VER754   RT1   CCE,INS754,HEX754
VER754   DS    0H
         CLC   INS754,HEX754
RT1_TEST784      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE784
         LTORG 
RT1_CCE784      DS 0H
*MEXIT #=  1547 LV= 2 RT1
*MEXIT #=  1546 LV= 1 ZOSOP
*MCALL #=  1548 LV= 1  ZOSOP 'C60','Execute Relative','EXRL','RIL',16  X
               RPI-817
         JAS   R11,VER755
         USING *,R11
INS755   EXRL M5,*-2
HEX755   DC    X'C650FFFFFFFF'
NUM755   DC    P'755'
*MCALL #=  1549 LV= 2 VER755   RT1   CCE,INS755,HEX755
VER755   DS    0H
         CLC   INS755,HEX755
RT1_TEST785      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE785
         LTORG 
RT1_CCE785      DS 0H
*MEXIT #=  1549 LV= 2 RT1
*MEXIT #=  1548 LV= 1 ZOSOP
*MCALL #=  1550 LV= 1  ZOSOP 'C62','Prefetch Data Relative','PFDRL','RIX
               L',16  RPI-817
         JAS   R11,VER756
         USING *,R11
INS756   PFDRL M5,*-2
HEX756   DC    X'C652FFFFFFFF'
NUM756   DC    P'756'
*MCALL #=  1551 LV= 2 VER756   RT1   CCE,INS756,HEX756
VER756   DS    0H
         CLC   INS756,HEX756
RT1_TEST786      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE786
         LTORG 
RT1_CCE786      DS 0H
*MEXIT #=  1551 LV= 2 RT1
*MEXIT #=  1550 LV= 1 ZOSOP
*MCALL #=  1552 LV= 1  ZOSOP 'C64','Compare Halfword Relative','CGHRL',X
               'RIL',16  RPI-817
         JAS   R11,VER757
         USING *,R11
INS757   CGHRL M5,*-2
HEX757   DC    X'C654FFFFFFFF'
NUM757   DC    P'757'
*MCALL #=  1553 LV= 2 VER757   RT1   CCE,INS757,HEX757
VER757   DS    0H
         CLC   INS757,HEX757
RT1_TEST787      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE787
         LTORG 
RT1_CCE787      DS 0H
*MEXIT #=  1553 LV= 2 RT1
*MEXIT #=  1552 LV= 1 ZOSOP
*MCALL #=  1554 LV= 1  ZOSOP 'C65','Compare Halfword Relative','CHRL','X
               RIL',16  RPI-817
         JAS   R11,VER758
         USING *,R11
INS758   CHRL M5,*-2
HEX758   DC    X'C655FFFFFFFF'
NUM758   DC    P'758'
*MCALL #=  1555 LV= 2 VER758   RT1   CCE,INS758,HEX758
VER758   DS    0H
         CLC   INS758,HEX758
RT1_TEST788      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE788
         LTORG 
RT1_CCE788      DS 0H
*MEXIT #=  1555 LV= 2 RT1
*MEXIT #=  1554 LV= 1 ZOSOP
*MCALL #=  1556 LV= 1  ZOSOP 'C66','Compare Logical Halfword Rel','CLGHX
               RL','RIL',16  RPI-817
         JAS   R11,VER759
         USING *,R11
INS759   CLGHRL M5,*-2
HEX759   DC    X'C656FFFFFFFF'
NUM759   DC    P'759'
*MCALL #=  1557 LV= 2 VER759   RT1   CCE,INS759,HEX759
VER759   DS    0H
         CLC   INS759,HEX759
RT1_TEST789      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE789
         LTORG 
RT1_CCE789      DS 0H
*MEXIT #=  1557 LV= 2 RT1
*MEXIT #=  1556 LV= 1 ZOSOP
*MCALL #=  1558 LV= 1  ZOSOP 'C67','Compare Logical Halfword Rel','CLHRX
               L','RIL',16  RPI-817
         JAS   R11,VER760
         USING *,R11
INS760   CLHRL M5,*-2
HEX760   DC    X'C657FFFFFFFF'
NUM760   DC    P'760'
*MCALL #=  1559 LV= 2 VER760   RT1   CCE,INS760,HEX760
VER760   DS    0H
         CLC   INS760,HEX760
RT1_TEST790      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE790
         LTORG 
RT1_CCE790      DS 0H
*MEXIT #=  1559 LV= 2 RT1
*MEXIT #=  1558 LV= 1 ZOSOP
*MCALL #=  1560 LV= 1  ZOSOP 'C68','Compare Relative','CGRL','RIL',16  X
               RPI-817
         JAS   R11,VER761
         USING *,R11
INS761   CGRL M5,*-2
HEX761   DC    X'C658FFFFFFFF'
NUM761   DC    P'761'
*MCALL #=  1561 LV= 2 VER761   RT1   CCE,INS761,HEX761
VER761   DS    0H
         CLC   INS761,HEX761
RT1_TEST791      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE791
         LTORG 
RT1_CCE791      DS 0H
*MEXIT #=  1561 LV= 2 RT1
*MEXIT #=  1560 LV= 1 ZOSOP
*MCALL #=  1562 LV= 1  ZOSOP 'C6A','Compare Logical Relative','CLGRL','X
               RIL',16  RPI-817
         JAS   R11,VER762
         USING *,R11
INS762   CLGRL M5,*-2
HEX762   DC    X'C65AFFFFFFFF'
NUM762   DC    P'762'
*MCALL #=  1563 LV= 2 VER762   RT1   CCE,INS762,HEX762
VER762   DS    0H
         CLC   INS762,HEX762
RT1_TEST792      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE792
         LTORG 
RT1_CCE792      DS 0H
*MEXIT #=  1563 LV= 2 RT1
*MEXIT #=  1562 LV= 1 ZOSOP
*MCALL #=  1564 LV= 1  ZOSOP 'C6C','Compare Relative','CGFRL','RIL',16 X
                RPI-817
         JAS   R11,VER763
         USING *,R11
INS763   CGFRL M5,*-2
HEX763   DC    X'C65CFFFFFFFF'
NUM763   DC    P'763'
*MCALL #=  1565 LV= 2 VER763   RT1   CCE,INS763,HEX763
VER763   DS    0H
         CLC   INS763,HEX763
RT1_TEST793      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE793
         LTORG 
RT1_CCE793      DS 0H
*MEXIT #=  1565 LV= 2 RT1
*MEXIT #=  1564 LV= 1 ZOSOP
*MCALL #=  1566 LV= 1  ZOSOP 'C6D','Compare Relative','CRL','RIL',16  RX
               PI-817
         JAS   R11,VER764
         USING *,R11
INS764   CRL  M5,*-2
HEX764   DC    X'C65DFFFFFFFF'
NUM764   DC    P'764'
*MCALL #=  1567 LV= 2 VER764   RT1   CCE,INS764,HEX764
VER764   DS    0H
         CLC   INS764,HEX764
RT1_TEST794      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE794
         LTORG 
RT1_CCE794      DS 0H
*MEXIT #=  1567 LV= 2 RT1
*MEXIT #=  1566 LV= 1 ZOSOP
*MCALL #=  1568 LV= 1  ZOSOP 'C6E','Compare Logical Relative','CLGFRL',X
               'RIL',16  RPI-817
         JAS   R11,VER765
         USING *,R11
INS765   CLGFRL M5,*-2
HEX765   DC    X'C65EFFFFFFFF'
NUM765   DC    P'765'
*MCALL #=  1569 LV= 2 VER765   RT1   CCE,INS765,HEX765
VER765   DS    0H
         CLC   INS765,HEX765
RT1_TEST795      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE795
         LTORG 
RT1_CCE795      DS 0H
*MEXIT #=  1569 LV= 2 RT1
*MEXIT #=  1568 LV= 1 ZOSOP
*MCALL #=  1570 LV= 1  ZOSOP 'C6F','Compare Logical Relative','CLRL','RX
               IL',16  RPI-817
         JAS   R11,VER766
         USING *,R11
INS766   CLRL M5,*-2
HEX766   DC    X'C65FFFFFFFFF'
NUM766   DC    P'766'
*MCALL #=  1571 LV= 2 VER766   RT1   CCE,INS766,HEX766
VER766   DS    0H
         CLC   INS766,HEX766
RT1_TEST796      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE796
         LTORG 
RT1_CCE796      DS 0H
*MEXIT #=  1571 LV= 2 RT1
*MEXIT #=  1570 LV= 1 ZOSOP
*MCALL #=  1572 LV= 1  ZOSOP 'C80','MOVE WITH OPTIONAL SPECIFICATIONS',X
               'MVCOS','SSF',Z9
         JAS   R11,VER767
         USING *,R11
INS767   MVCOS S1,S2,R3
HEX767   DC    X'C830D001D002'
NUM767   DC    P'767'
*MCALL #=  1573 LV= 2 VER767   RT1   CCE,INS767,HEX767
VER767   DS    0H
         CLC   INS767,HEX767
RT1_TEST797      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE797
         LTORG 
RT1_CCE797      DS 0H
*MEXIT #=  1573 LV= 2 RT1
*MEXIT #=  1572 LV= 1 ZOSOP
*MCALL #=  1574 LV= 1  ZOSOP 'C81','EXTRACT CPU TIME','ECTG','SSF',Z9  X
                            RPI-1013
         JAS   R11,VER768
         USING *,R11
INS768   ECTG S1,S2,R3
HEX768   DC    X'C831D001D002'
NUM768   DC    P'768'
*MCALL #=  1575 LV= 2 VER768   RT1   CCE,INS768,HEX768
VER768   DS    0H
         CLC   INS768,HEX768
RT1_TEST798      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE798
         LTORG 
RT1_CCE798      DS 0H
*MEXIT #=  1575 LV= 2 RT1
*MEXIT #=  1574 LV= 1 ZOSOP
*MCALL #=  1576 LV= 1  ZOSOP 'C82','COMPARE SWAP AND STORE','CSST','SSFX
               ',Z9         RPI-1013
         JAS   R11,VER769
         USING *,R11
INS769   CSST S1,S2,R3
HEX769   DC    X'C832D001D002'
NUM769   DC    P'769'
*MCALL #=  1577 LV= 2 VER769   RT1   CCE,INS769,HEX769
VER769   DS    0H
         CLC   INS769,HEX769
RT1_TEST799      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE799
         LTORG 
RT1_CCE799      DS 0H
*MEXIT #=  1577 LV= 2 RT1
*MEXIT #=  1576 LV= 1 ZOSOP
*MCALL #=  1578 LV= 1  ZOSOP 'C84','LOAD PAIR DISJOINT (32)','LPD','SSFX
               2'  RPI-1125 Z196
         JAS   R11,VER770
         USING *,R11
INS770   LPD  R3,S1,S2
HEX770   DC    X'C834D001D002'
NUM770   DC    P'770'
*MCALL #=  1579 LV= 2 VER770   RT1   CCE,INS770,HEX770
VER770   DS    0H
         CLC   INS770,HEX770
RT1_TEST800      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE800
         LTORG 
RT1_CCE800      DS 0H
*MEXIT #=  1579 LV= 2 RT1
*MEXIT #=  1578 LV= 1 ZOSOP
*MCALL #=  1580 LV= 1  ZOSOP 'C85','LOAD PAIR DISJOINT (64)','LPDG','SSX
               F2'  RPI-1125 Z196
         JAS   R11,VER771
         USING *,R11
INS771   LPDG R3,S1,S2
HEX771   DC    X'C835D001D002'
NUM771   DC    P'771'
*MCALL #=  1581 LV= 2 VER771   RT1   CCE,INS771,HEX771
VER771   DS    0H
         CLC   INS771,HEX771
RT1_TEST801      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE801
         LTORG 
RT1_CCE801      DS 0H
*MEXIT #=  1581 LV= 2 RT1
*MEXIT #=  1580 LV= 1 ZOSOP
*MCALL #=  1582 LV= 1  ZOSOP  'CC6','BRANCH RELATIVE ON COUNT HIGH (32)X
               ','BRCTH','RIL  '  RPI 1125 Z196
         JAS   R11,VER772
         USING *,R11
INS772   BRCTH M5,*-2
HEX772   DC    X'CC56FFFFFFFF'
NUM772   DC    P'772'
*MCALL #=  1583 LV= 2 VER772   RT1   CCE,INS772,HEX772
VER772   DS    0H
         CLC   INS772,HEX772
RT1_TEST802      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE802
         LTORG 
RT1_CCE802      DS 0H
*MEXIT #=  1583 LV= 2 RT1
*MEXIT #=  1582 LV= 1 ZOSOP
*MCALL #=  1584 LV= 1  ZOSOP  'CC8','ADD IMMEDIATE HIGH (32)','AIH','RIX
               L  '  RPI-1125 Z196
         JAS   R11,VER773
         USING *,R11
INS773   AIH  M5,*-2
HEX773   DC    X'CC58FFFFFFFF'
NUM773   DC    P'773'
*MCALL #=  1585 LV= 2 VER773   RT1   CCE,INS773,HEX773
VER773   DS    0H
         CLC   INS773,HEX773
RT1_TEST803      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE803
         LTORG 
RT1_CCE803      DS 0H
*MEXIT #=  1585 LV= 2 RT1
*MEXIT #=  1584 LV= 1 ZOSOP
*MCALL #=  1586 LV= 1  ZOSOP  'CCA','ADD LOGICAL WITH SIGNED IMMEDIATE X
               HIGH (32)','ALSIH','RIL  '  RPI-1125 Z196
         JAS   R11,VER774
         USING *,R11
INS774   ALSIH M5,*-2
HEX774   DC    X'CC5AFFFFFFFF'
NUM774   DC    P'774'
*MCALL #=  1587 LV= 2 VER774   RT1   CCE,INS774,HEX774
VER774   DS    0H
         CLC   INS774,HEX774
RT1_TEST804      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE804
         LTORG 
RT1_CCE804      DS 0H
*MEXIT #=  1587 LV= 2 RT1
*MEXIT #=  1586 LV= 1 ZOSOP
*MCALL #=  1588 LV= 1  ZOSOP  'CCB','ADD LOGICAL WITH SIGNED IMMEDIATE X
               HIGH (32)','ALSIHN','RIL  '  RPI-1125 Z196
         JAS   R11,VER775
         USING *,R11
INS775   ALSIHN M5,*-2
HEX775   DC    X'CC5BFFFFFFFF'
NUM775   DC    P'775'
*MCALL #=  1589 LV= 2 VER775   RT1   CCE,INS775,HEX775
VER775   DS    0H
         CLC   INS775,HEX775
RT1_TEST805      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE805
         LTORG 
RT1_CCE805      DS 0H
*MEXIT #=  1589 LV= 2 RT1
*MEXIT #=  1588 LV= 1 ZOSOP
*MCALL #=  1590 LV= 1  ZOSOP  'CCD','COMPARE IMMEDIATE HIGH (32)','CIH'X
               ,'RIL  '  RPI-1125 Z196
         JAS   R11,VER776
         USING *,R11
INS776   CIH  M5,*-2
HEX776   DC    X'CC5DFFFFFFFF'
NUM776   DC    P'776'
*MCALL #=  1591 LV= 2 VER776   RT1   CCE,INS776,HEX776
VER776   DS    0H
         CLC   INS776,HEX776
RT1_TEST806      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE806
         LTORG 
RT1_CCE806      DS 0H
*MEXIT #=  1591 LV= 2 RT1
*MEXIT #=  1590 LV= 1 ZOSOP
*MCALL #=  1592 LV= 1  ZOSOP  'CCF','COMPARE LOGICAL IMMEDIATE HIGH (32X
               )','CLIH','RIL  '  RPI 1125 Z196
         JAS   R11,VER777
         USING *,R11
INS777   CLIH M5,*-2
HEX777   DC    X'CC5FFFFFFFFF'
NUM777   DC    P'777'
*MCALL #=  1593 LV= 2 VER777   RT1   CCE,INS777,HEX777
VER777   DS    0H
         CLC   INS777,HEX777
RT1_TEST807      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE807
         LTORG 
RT1_CCE807      DS 0H
*MEXIT #=  1593 LV= 2 RT1
*MEXIT #=  1592 LV= 1 ZOSOP
*MCALL #=  1594 LV= 1  ZOSOP 'D0 ','TRANSLATE AND TEST REVERSED ','TRTRX
                ','SS C E3'
         JAS   R11,VER778
         USING *,R11
INS778   TRTR  S1(LL),S2
HEX778   DC    X'D0FFD001D002'
NUM778   DC    P'778'
*MCALL #=  1595 LV= 2 VER778   RT1   CCE,INS778,HEX778
VER778   DS    0H
         CLC   INS778,HEX778
RT1_TEST808      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE808
         LTORG 
RT1_CCE808      DS 0H
*MEXIT #=  1595 LV= 2 RT1
*MEXIT #=  1594 LV= 1 ZOSOP
*MCALL #=  1596 LV= 1  ZOSOP 'D1 ','MOVE NUMERICS ','MVN ','SS '
         JAS   R11,VER779
         USING *,R11
INS779   MVN  S1(LL),S2
HEX779   DC    X'D1FFD001D002'
NUM779   DC    P'779'
*MCALL #=  1597 LV= 2 VER779   RT1   CCE,INS779,HEX779
VER779   DS    0H
         CLC   INS779,HEX779
RT1_TEST809      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE809
         LTORG 
RT1_CCE809      DS 0H
*MEXIT #=  1597 LV= 2 RT1
*MEXIT #=  1596 LV= 1 ZOSOP
*MCALL #=  1598 LV= 1  ZOSOP 'D2 ','MOVE (character) ','MVC ','SS '
         JAS   R11,VER780
         USING *,R11
INS780   MVC  S1(LL),S2
HEX780   DC    X'D2FFD001D002'
NUM780   DC    P'780'
*MCALL #=  1599 LV= 2 VER780   RT1   CCE,INS780,HEX780
VER780   DS    0H
         CLC   INS780,HEX780
RT1_TEST810      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE810
         LTORG 
RT1_CCE810      DS 0H
*MEXIT #=  1599 LV= 2 RT1
*MEXIT #=  1598 LV= 1 ZOSOP
*MCALL #=  1600 LV= 1  ZOSOP 'D3 ','MOVE ZONES ','MVZ ','SS '
         JAS   R11,VER781
         USING *,R11
INS781   MVZ  S1(LL),S2
HEX781   DC    X'D3FFD001D002'
NUM781   DC    P'781'
*MCALL #=  1601 LV= 2 VER781   RT1   CCE,INS781,HEX781
VER781   DS    0H
         CLC   INS781,HEX781
RT1_TEST811      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE811
         LTORG 
RT1_CCE811      DS 0H
*MEXIT #=  1601 LV= 2 RT1
*MEXIT #=  1600 LV= 1 ZOSOP
*MCALL #=  1602 LV= 1  ZOSOP 'D4 ','AND (character) ','NC ','SS C '
         JAS   R11,VER782
         USING *,R11
INS782   NC   S1(LL),S2
HEX782   DC    X'D4FFD001D002'
NUM782   DC    P'782'
*MCALL #=  1603 LV= 2 VER782   RT1   CCE,INS782,HEX782
VER782   DS    0H
         CLC   INS782,HEX782
RT1_TEST812      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE812
         LTORG 
RT1_CCE812      DS 0H
*MEXIT #=  1603 LV= 2 RT1
*MEXIT #=  1602 LV= 1 ZOSOP
*MCALL #=  1604 LV= 1  ZOSOP 'D5 ','COMPARE LOGICAL (character) ','CLC X
               ','SS C '
         JAS   R11,VER783
         USING *,R11
INS783   CLC  S1(LL),S2
HEX783   DC    X'D5FFD001D002'
NUM783   DC    P'783'
*MCALL #=  1605 LV= 2 VER783   RT1   CCE,INS783,HEX783
VER783   DS    0H
         CLC   INS783,HEX783
RT1_TEST813      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE813
         LTORG 
RT1_CCE813      DS 0H
*MEXIT #=  1605 LV= 2 RT1
*MEXIT #=  1604 LV= 1 ZOSOP
*MCALL #=  1606 LV= 1  ZOSOP 'D6 ','OR (character) ','OC ','SS C '
         JAS   R11,VER784
         USING *,R11
INS784   OC   S1(LL),S2
HEX784   DC    X'D6FFD001D002'
NUM784   DC    P'784'
*MCALL #=  1607 LV= 2 VER784   RT1   CCE,INS784,HEX784
VER784   DS    0H
         CLC   INS784,HEX784
RT1_TEST814      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE814
         LTORG 
RT1_CCE814      DS 0H
*MEXIT #=  1607 LV= 2 RT1
*MEXIT #=  1606 LV= 1 ZOSOP
*MCALL #=  1608 LV= 1  ZOSOP 'D7 ','EXCLUSIVE OR (character) ','XC ','SX
               S C '
         JAS   R11,VER785
         USING *,R11
INS785   XC   S1(LL),S2
HEX785   DC    X'D7FFD001D002'
NUM785   DC    P'785'
*MCALL #=  1609 LV= 2 VER785   RT1   CCE,INS785,HEX785
VER785   DS    0H
         CLC   INS785,HEX785
RT1_TEST815      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE815
         LTORG 
RT1_CCE815      DS 0H
*MEXIT #=  1609 LV= 2 RT1
*MEXIT #=  1608 LV= 1 ZOSOP
*MCALL #=  1610 LV= 1  ZOSOP 'D9 ','MOVE WITH KEY ','MVCK ','SS C '
         JAS   R11,VER786
         USING *,R11
INS786   MVCK  S1(LL),S2
HEX786   DC    X'D9FFD001D002'
NUM786   DC    P'786'
*MCALL #=  1611 LV= 2 VER786   RT1   CCE,INS786,HEX786
VER786   DS    0H
         CLC   INS786,HEX786
RT1_TEST816      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE816
         LTORG 
RT1_CCE816      DS 0H
*MEXIT #=  1611 LV= 2 RT1
*MEXIT #=  1610 LV= 1 ZOSOP
*MCALL #=  1612 LV= 1  ZOSOP 'DA ','MOVE TO PRIMARY ','MVCP ','SS C '
         JAS   R11,VER787
         USING *,R11
INS787   MVCP  S1(LL),S2
HEX787   DC    X'DAFFD001D002'
NUM787   DC    P'787'
*MCALL #=  1613 LV= 2 VER787   RT1   CCE,INS787,HEX787
VER787   DS    0H
         CLC   INS787,HEX787
RT1_TEST817      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE817
         LTORG 
RT1_CCE817      DS 0H
*MEXIT #=  1613 LV= 2 RT1
*MEXIT #=  1612 LV= 1 ZOSOP
*MCALL #=  1614 LV= 1  ZOSOP 'DB ','MOVE TO SECONDARY ','MVCS ','SS C '
         JAS   R11,VER788
         USING *,R11
INS788   MVCS  S1(LL),S2
HEX788   DC    X'DBFFD001D002'
NUM788   DC    P'788'
*MCALL #=  1615 LV= 2 VER788   RT1   CCE,INS788,HEX788
VER788   DS    0H
         CLC   INS788,HEX788
RT1_TEST818      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE818
         LTORG 
RT1_CCE818      DS 0H
*MEXIT #=  1615 LV= 2 RT1
*MEXIT #=  1614 LV= 1 ZOSOP
*MCALL #=  1616 LV= 1  ZOSOP 'DC ','TRANSLATE ','TR ','SS '
         JAS   R11,VER789
         USING *,R11
INS789   TR   S1(LL),S2
HEX789   DC    X'DCFFD001D002'
NUM789   DC    P'789'
*MCALL #=  1617 LV= 2 VER789   RT1   CCE,INS789,HEX789
VER789   DS    0H
         CLC   INS789,HEX789
RT1_TEST819      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE819
         LTORG 
RT1_CCE819      DS 0H
*MEXIT #=  1617 LV= 2 RT1
*MEXIT #=  1616 LV= 1 ZOSOP
*MCALL #=  1618 LV= 1  ZOSOP 'DD ','TRANSLATE AND TEST ','TRT ','SS C '
         JAS   R11,VER790
         USING *,R11
INS790   TRT  S1(LL),S2
HEX790   DC    X'DDFFD001D002'
NUM790   DC    P'790'
*MCALL #=  1619 LV= 2 VER790   RT1   CCE,INS790,HEX790
VER790   DS    0H
         CLC   INS790,HEX790
RT1_TEST820      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE820
         LTORG 
RT1_CCE820      DS 0H
*MEXIT #=  1619 LV= 2 RT1
*MEXIT #=  1618 LV= 1 ZOSOP
*MCALL #=  1620 LV= 1  ZOSOP 'DE ','EDIT ','ED ','SS C '
         JAS   R11,VER791
         USING *,R11
INS791   ED   S1(LL),S2
HEX791   DC    X'DEFFD001D002'
NUM791   DC    P'791'
*MCALL #=  1621 LV= 2 VER791   RT1   CCE,INS791,HEX791
VER791   DS    0H
         CLC   INS791,HEX791
RT1_TEST821      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE821
         LTORG 
RT1_CCE821      DS 0H
*MEXIT #=  1621 LV= 2 RT1
*MEXIT #=  1620 LV= 1 ZOSOP
*MCALL #=  1622 LV= 1  ZOSOP 'DF ','EDIT AND MARK ','EDMK ','SS C '
         JAS   R11,VER792
         USING *,R11
INS792   EDMK  S1(LL),S2
HEX792   DC    X'DFFFD001D002'
NUM792   DC    P'792'
*MCALL #=  1623 LV= 2 VER792   RT1   CCE,INS792,HEX792
VER792   DS    0H
         CLC   INS792,HEX792
RT1_TEST822      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE822
         LTORG 
RT1_CCE822      DS 0H
*MEXIT #=  1623 LV= 2 RT1
*MEXIT #=  1622 LV= 1 ZOSOP
*MCALL #=  1624 LV= 1  ZOSOP 'E00','XREAD DD=XRD ASSIST','XREAD','RXSS'X
                RPI-812 RCD=XBD1(BD2)
         JAS   R11,VER793
         USING *,R11
INS793   XREAD S2(X4),S1
HEX793   DC    X'E004D002D001'
NUM793   DC    P'793'
*MCALL #=  1625 LV= 2 VER793   RT1   CCE,INS793,HEX793
VER793   DS    0H
         CLC   INS793,HEX793
RT1_TEST823      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE823
         LTORG 
RT1_CCE823      DS 0H
*MEXIT #=  1625 LV= 2 RT1
*MEXIT #=  1624 LV= 1 ZOSOP
*MCALL #=  1626 LV= 1  ZOSOP 'E02','XPRNT DD=XPR ASSIST','XPRNT','RXSS'X
                RPI-812 RCD=XBD1(BD2)
         JAS   R11,VER794
         USING *,R11
INS794   XPRNT S2(X4),S1
HEX794   DC    X'E024D002D001'
NUM794   DC    P'794'
*MCALL #=  1627 LV= 2 VER794   RT1   CCE,INS794,HEX794
VER794   DS    0H
         CLC   INS794,HEX794
RT1_TEST824      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE824
         LTORG 
RT1_CCE824      DS 0H
*MEXIT #=  1627 LV= 2 RT1
*MEXIT #=  1626 LV= 1 ZOSOP
*MCALL #=  1628 LV= 1  ZOSOP 'E04','XPNCH DD=XCH ASSIST','XPNCH','RXSS'X
                RPI-812 RCD=XBD1(BD2)
         JAS   R11,VER795
         USING *,R11
INS795   XPNCH S2(X4),S1
HEX795   DC    X'E044D002D001'
NUM795   DC    P'795'
*MCALL #=  1629 LV= 2 VER795   RT1   CCE,INS795,HEX795
VER795   DS    0H
         CLC   INS795,HEX795
RT1_TEST825      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE825
         LTORG 
RT1_CCE825      DS 0H
*MEXIT #=  1629 LV= 2 RT1
*MEXIT #=  1628 LV= 1 ZOSOP
*MCALL #=  1630 LV= 1  ZOSOP 'E06','XDUMP RCD    ASSIST','XDUMP','RXSS'X
                RPI-812 RCD=XBD1(BD2)
         JAS   R11,VER796
         USING *,R11
INS796   XDUMP S2(X4),S1
HEX796   DC    X'E064D002D001'
NUM796   DC    P'796'
*MCALL #=  1631 LV= 2 VER796   RT1   CCE,INS796,HEX796
VER796   DS    0H
         CLC   INS796,HEX796
RT1_TEST826      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE826
         LTORG 
RT1_CCE826      DS 0H
*MEXIT #=  1631 LV= 2 RT1
*MEXIT #=  1630 LV= 1 ZOSOP
*MCALL #=  1632 LV= 1  ZOSOP 'E08','XLIMD LIMIT  ASSIST','XLIMD','RXSS'X
                RPI-812 RCD=XBD1(BD2)
         JAS   R11,VER797
         USING *,R11
INS797   XLIMD S2(X4),S1
HEX797   DC    X'E084D002D001'
NUM797   DC    P'797'
*MCALL #=  1633 LV= 2 VER797   RT1   CCE,INS797,HEX797
VER797   DS    0H
         CLC   INS797,HEX797
RT1_TEST827      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE827
         LTORG 
RT1_CCE827      DS 0H
*MEXIT #=  1633 LV= 2 RT1
*MEXIT #=  1632 LV= 1 ZOSOP
*MCALL #=  1634 LV= 1  ZOSOP 'E0A','XGET  DD=XGT ASSIST','XGET','RXSS' X
                RPI-812 RCD=XBD1(BD2)
         JAS   R11,VER798
         USING *,R11
INS798   XGET S2(X4),S1
HEX798   DC    X'E0A4D002D001'
NUM798   DC    P'798'
*MCALL #=  1635 LV= 2 VER798   RT1   CCE,INS798,HEX798
VER798   DS    0H
         CLC   INS798,HEX798
RT1_TEST828      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE828
         LTORG 
RT1_CCE828      DS 0H
*MEXIT #=  1635 LV= 2 RT1
*MEXIT #=  1634 LV= 1 ZOSOP
*MCALL #=  1636 LV= 1  ZOSOP 'E0C','XPUT  DD=XPT ASSIST','XPUT','RXSS' X
                RPI-812 RCD=XBD1(BD2)
         JAS   R11,VER799
         USING *,R11
INS799   XPUT S2(X4),S1
HEX799   DC    X'E0C4D002D001'
NUM799   DC    P'799'
*MCALL #=  1637 LV= 2 VER799   RT1   CCE,INS799,HEX799
VER799   DS    0H
         CLC   INS799,HEX799
RT1_TEST829      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE829
         LTORG 
RT1_CCE829      DS 0H
*MEXIT #=  1637 LV= 2 RT1
*MEXIT #=  1636 LV= 1 ZOSOP
*MCALL #=  1638 LV= 1  ZOSOP 'E1 ','PACK UNICODE ','PKU ','SS E2'
         JAS   R11,VER800
         USING *,R11
INS800   PKU  S1(LL),S2
HEX800   DC    X'E1FFD001D002'
NUM800   DC    P'800'
*MCALL #=  1639 LV= 2 VER800   RT1   CCE,INS800,HEX800
VER800   DS    0H
         CLC   INS800,HEX800
RT1_TEST830      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE830
         LTORG 
RT1_CCE830      DS 0H
*MEXIT #=  1639 LV= 2 RT1
*MEXIT #=  1638 LV= 1 ZOSOP
*MCALL #=  1640 LV= 1  ZOSOP 'E2 ','UNPACK UNICODE ','UNPKU','SS C E2'
         JAS   R11,VER801
         USING *,R11
INS801   UNPKU S1(LL),S2
HEX801   DC    X'E2FFD001D002'
NUM801   DC    P'801'
*MCALL #=  1641 LV= 2 VER801   RT1   CCE,INS801,HEX801
VER801   DS    0H
         CLC   INS801,HEX801
RT1_TEST831      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE831
         LTORG 
RT1_CCE831      DS 0H
*MEXIT #=  1641 LV= 2 RT1
*MEXIT #=  1640 LV= 1 ZOSOP
*MCALL #=  1642 LV= 1  ZOSOP 'E302','LOAD AND TEST','LTG','RXY',Z9
         JAS   R11,VER802
         USING *,R11
INS802   LTG  R1,S2(X4)
HEX802   DC    X'E314D0020002'
NUM802   DC    P'802'
*MCALL #=  1643 LV= 2 VER802   RT1   CCE,INS802,HEX802
VER802   DS    0H
         CLC   INS802,HEX802
RT1_TEST832      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE832
         LTORG 
RT1_CCE832      DS 0H
*MEXIT #=  1643 LV= 2 RT1
*MEXIT #=  1642 LV= 1 ZOSOP
*MCALL #=  1644 LV= 1  ZOSOP 'E303','LOAD REAL ADDRESS (64) ','LRAG ','X
               RXY C N '
         JAS   R11,VER803
         USING *,R11
INS803   LRAG  R1,S2(X4)
HEX803   DC    X'E314D0020003'
NUM803   DC    P'803'
*MCALL #=  1645 LV= 2 VER803   RT1   CCE,INS803,HEX803
VER803   DS    0H
         CLC   INS803,HEX803
RT1_TEST833      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE833
         LTORG 
RT1_CCE833      DS 0H
*MEXIT #=  1645 LV= 2 RT1
*MEXIT #=  1644 LV= 1 ZOSOP
*MCALL #=  1646 LV= 1  ZOSOP 'E304','LOAD (64) ','LG ','RXY N '
         JAS   R11,VER804
         USING *,R11
INS804   LG   R1,S2(X4)
HEX804   DC    X'E314D0020004'
NUM804   DC    P'804'
*MCALL #=  1647 LV= 2 VER804   RT1   CCE,INS804,HEX804
VER804   DS    0H
         CLC   INS804,HEX804
RT1_TEST834      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE834
         LTORG 
RT1_CCE834      DS 0H
*MEXIT #=  1647 LV= 2 RT1
*MEXIT #=  1646 LV= 1 ZOSOP
*MCALL #=  1648 LV= 1  ZOSOP 'E306','CONVERT TO BINARY (32) ','CVBY ','X
               RXY LD'
         JAS   R11,VER805
         USING *,R11
INS805   CVBY  R1,S2(X4)
HEX805   DC    X'E314D0020006'
NUM805   DC    P'805'
*MCALL #=  1649 LV= 2 VER805   RT1   CCE,INS805,HEX805
VER805   DS    0H
         CLC   INS805,HEX805
RT1_TEST835      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE835
         LTORG 
RT1_CCE835      DS 0H
*MEXIT #=  1649 LV= 2 RT1
*MEXIT #=  1648 LV= 1 ZOSOP
*MCALL #=  1650 LV= 1  ZOSOP 'E308','ADD (64) ','AG ','RXY C N '
         JAS   R11,VER806
         USING *,R11
INS806   AG   R1,S2(X4)
HEX806   DC    X'E314D0020008'
NUM806   DC    P'806'
*MCALL #=  1651 LV= 2 VER806   RT1   CCE,INS806,HEX806
VER806   DS    0H
         CLC   INS806,HEX806
RT1_TEST836      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE836
         LTORG 
RT1_CCE836      DS 0H
*MEXIT #=  1651 LV= 2 RT1
*MEXIT #=  1650 LV= 1 ZOSOP
*MCALL #=  1652 LV= 1  ZOSOP 'E309','SUBTRACT (64) ','SG ','RXY C N '
         JAS   R11,VER807
         USING *,R11
INS807   SG   R1,S2(X4)
HEX807   DC    X'E314D0020009'
NUM807   DC    P'807'
*MCALL #=  1653 LV= 2 VER807   RT1   CCE,INS807,HEX807
VER807   DS    0H
         CLC   INS807,HEX807
RT1_TEST837      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE837
         LTORG 
RT1_CCE837      DS 0H
*MEXIT #=  1653 LV= 2 RT1
*MEXIT #=  1652 LV= 1 ZOSOP
*MCALL #=  1654 LV= 1  ZOSOP 'E30A','ADD LOGICAL (64) ','ALG ','RXY C NX
                '
         JAS   R11,VER808
         USING *,R11
INS808   ALG  R1,S2(X4)
HEX808   DC    X'E314D002000A'
NUM808   DC    P'808'
*MCALL #=  1655 LV= 2 VER808   RT1   CCE,INS808,HEX808
VER808   DS    0H
         CLC   INS808,HEX808
RT1_TEST838      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE838
         LTORG 
RT1_CCE838      DS 0H
*MEXIT #=  1655 LV= 2 RT1
*MEXIT #=  1654 LV= 1 ZOSOP
*MCALL #=  1656 LV= 1  ZOSOP 'E30B','SUBTRACT LOGICAL (64) ','SLG ','RXX
               Y C N '
         JAS   R11,VER809
         USING *,R11
INS809   SLG  R1,S2(X4)
HEX809   DC    X'E314D002000B'
NUM809   DC    P'809'
*MCALL #=  1657 LV= 2 VER809   RT1   CCE,INS809,HEX809
VER809   DS    0H
         CLC   INS809,HEX809
RT1_TEST839      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE839
         LTORG 
RT1_CCE839      DS 0H
*MEXIT #=  1657 LV= 2 RT1
*MEXIT #=  1656 LV= 1 ZOSOP
*MCALL #=  1658 LV= 1  ZOSOP 'E30C','MULTIPLY SINGLE (64) ','MSG ','RXYX
                N '
         JAS   R11,VER810
         USING *,R11
INS810   MSG  R1,S2(X4)
HEX810   DC    X'E314D002000C'
NUM810   DC    P'810'
*MCALL #=  1659 LV= 2 VER810   RT1   CCE,INS810,HEX810
VER810   DS    0H
         CLC   INS810,HEX810
RT1_TEST840      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE840
         LTORG 
RT1_CCE840      DS 0H
*MEXIT #=  1659 LV= 2 RT1
*MEXIT #=  1658 LV= 1 ZOSOP
*MCALL #=  1660 LV= 1  ZOSOP 'E30D','DIVIDE SINGLE (64) ','DSG ','RXY NX
                '
         JAS   R11,VER811
         USING *,R11
INS811   DSG  R1,S2(X4)
HEX811   DC    X'E314D002000D'
NUM811   DC    P'811'
*MCALL #=  1661 LV= 2 VER811   RT1   CCE,INS811,HEX811
VER811   DS    0H
         CLC   INS811,HEX811
RT1_TEST841      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE841
         LTORG 
RT1_CCE841      DS 0H
*MEXIT #=  1661 LV= 2 RT1
*MEXIT #=  1660 LV= 1 ZOSOP
*MCALL #=  1662 LV= 1  ZOSOP 'E30E','CONVERT TO BINARY (64) ','CVBG ','X
               RXY N '
         JAS   R11,VER812
         USING *,R11
INS812   CVBG  R1,S2(X4)
HEX812   DC    X'E314D002000E'
NUM812   DC    P'812'
*MCALL #=  1663 LV= 2 VER812   RT1   CCE,INS812,HEX812
VER812   DS    0H
         CLC   INS812,HEX812
RT1_TEST842      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE842
         LTORG 
RT1_CCE842      DS 0H
*MEXIT #=  1663 LV= 2 RT1
*MEXIT #=  1662 LV= 1 ZOSOP
*MCALL #=  1664 LV= 1  ZOSOP 'E30F','LOAD REVERSED (64) ','LRVG ','RXY X
               N '
         JAS   R11,VER813
         USING *,R11
INS813   LRVG  R1,S2(X4)
HEX813   DC    X'E314D002000F'
NUM813   DC    P'813'
*MCALL #=  1665 LV= 2 VER813   RT1   CCE,INS813,HEX813
VER813   DS    0H
         CLC   INS813,HEX813
RT1_TEST843      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE843
         LTORG 
RT1_CCE843      DS 0H
*MEXIT #=  1665 LV= 2 RT1
*MEXIT #=  1664 LV= 1 ZOSOP
*MCALL #=  1666 LV= 1  ZOSOP 'E312','LOAD AND TEST','LT','RXY',Z9
         JAS   R11,VER814
         USING *,R11
INS814   LT   R1,S2(X4)
HEX814   DC    X'E314D0020012'
NUM814   DC    P'814'
*MCALL #=  1667 LV= 2 VER814   RT1   CCE,INS814,HEX814
VER814   DS    0H
         CLC   INS814,HEX814
RT1_TEST844      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE844
         LTORG 
RT1_CCE844      DS 0H
*MEXIT #=  1667 LV= 2 RT1
*MEXIT #=  1666 LV= 1 ZOSOP
*MCALL #=  1668 LV= 1  ZOSOP 'E313','LOAD REAL ADDRESS (32) ','LRAY ','X
               RXY C LD'
         JAS   R11,VER815
         USING *,R11
INS815   LRAY  R1,S2(X4)
HEX815   DC    X'E314D0020013'
NUM815   DC    P'815'
*MCALL #=  1669 LV= 2 VER815   RT1   CCE,INS815,HEX815
VER815   DS    0H
         CLC   INS815,HEX815
RT1_TEST845      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE845
         LTORG 
RT1_CCE845      DS 0H
*MEXIT #=  1669 LV= 2 RT1
*MEXIT #=  1668 LV= 1 ZOSOP
*MCALL #=  1670 LV= 1  ZOSOP 'E314','LOAD (64<32) ','LGF ','RXY N '
         JAS   R11,VER816
         USING *,R11
INS816   LGF  R1,S2(X4)
HEX816   DC    X'E314D0020014'
NUM816   DC    P'816'
*MCALL #=  1671 LV= 2 VER816   RT1   CCE,INS816,HEX816
VER816   DS    0H
         CLC   INS816,HEX816
RT1_TEST846      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE846
         LTORG 
RT1_CCE846      DS 0H
*MEXIT #=  1671 LV= 2 RT1
*MEXIT #=  1670 LV= 1 ZOSOP
*MCALL #=  1672 LV= 1  ZOSOP 'E315','LOAD HALFWORD (64) ','LGH ','RXY NX
                '
         JAS   R11,VER817
         USING *,R11
INS817   LGH  R1,S2(X4)
HEX817   DC    X'E314D0020015'
NUM817   DC    P'817'
*MCALL #=  1673 LV= 2 VER817   RT1   CCE,INS817,HEX817
VER817   DS    0H
         CLC   INS817,HEX817
RT1_TEST847      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE847
         LTORG 
RT1_CCE847      DS 0H
*MEXIT #=  1673 LV= 2 RT1
*MEXIT #=  1672 LV= 1 ZOSOP
*MCALL #=  1674 LV= 1  ZOSOP 'E316','LOAD LOGICAL (64<32) ','LLGF ','RXX
               Y N '
         JAS   R11,VER818
         USING *,R11
INS818   LLGF  R1,S2(X4)
HEX818   DC    X'E314D0020016'
NUM818   DC    P'818'
*MCALL #=  1675 LV= 2 VER818   RT1   CCE,INS818,HEX818
VER818   DS    0H
         CLC   INS818,HEX818
RT1_TEST848      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE848
         LTORG 
RT1_CCE848      DS 0H
*MEXIT #=  1675 LV= 2 RT1
*MEXIT #=  1674 LV= 1 ZOSOP
*MCALL #=  1676 LV= 1  ZOSOP 'E317','LOAD LOGICAL THIRTY ONE BITS ','LLX
               GT ','RXY N '
         JAS   R11,VER819
         USING *,R11
INS819   LLGT  R1,S2(X4)
HEX819   DC    X'E314D0020017'
NUM819   DC    P'819'
*MCALL #=  1677 LV= 2 VER819   RT1   CCE,INS819,HEX819
VER819   DS    0H
         CLC   INS819,HEX819
RT1_TEST849      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE849
         LTORG 
RT1_CCE849      DS 0H
*MEXIT #=  1677 LV= 2 RT1
*MEXIT #=  1676 LV= 1 ZOSOP
*MCALL #=  1678 LV= 1  ZOSOP 'E318','ADD (64<32) ','AGF ','RXY C N '
         JAS   R11,VER820
         USING *,R11
INS820   AGF  R1,S2(X4)
HEX820   DC    X'E314D0020018'
NUM820   DC    P'820'
*MCALL #=  1679 LV= 2 VER820   RT1   CCE,INS820,HEX820
VER820   DS    0H
         CLC   INS820,HEX820
RT1_TEST850      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE850
         LTORG 
RT1_CCE850      DS 0H
*MEXIT #=  1679 LV= 2 RT1
*MEXIT #=  1678 LV= 1 ZOSOP
*MCALL #=  1680 LV= 1  ZOSOP 'E319','SUBTRACT (64<32) ','SGF ','RXY C NX
                '
         JAS   R11,VER821
         USING *,R11
INS821   SGF  R1,S2(X4)
HEX821   DC    X'E314D0020019'
NUM821   DC    P'821'
*MCALL #=  1681 LV= 2 VER821   RT1   CCE,INS821,HEX821
VER821   DS    0H
         CLC   INS821,HEX821
RT1_TEST851      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE851
         LTORG 
RT1_CCE851      DS 0H
*MEXIT #=  1681 LV= 2 RT1
*MEXIT #=  1680 LV= 1 ZOSOP
*MCALL #=  1682 LV= 1  ZOSOP 'E31A','ADD LOGICAL (64<32) ','ALGF ','RXYX
                C N '
         JAS   R11,VER822
         USING *,R11
INS822   ALGF  R1,S2(X4)
HEX822   DC    X'E314D002001A'
NUM822   DC    P'822'
*MCALL #=  1683 LV= 2 VER822   RT1   CCE,INS822,HEX822
VER822   DS    0H
         CLC   INS822,HEX822
RT1_TEST852      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE852
         LTORG 
RT1_CCE852      DS 0H
*MEXIT #=  1683 LV= 2 RT1
*MEXIT #=  1682 LV= 1 ZOSOP
*MCALL #=  1684 LV= 1  ZOSOP 'E31B','SUBTRACT LOGICAL (64<32) ','SLGF 'X
               ,'RXY C N '
         JAS   R11,VER823
         USING *,R11
INS823   SLGF  R1,S2(X4)
HEX823   DC    X'E314D002001B'
NUM823   DC    P'823'
*MCALL #=  1685 LV= 2 VER823   RT1   CCE,INS823,HEX823
VER823   DS    0H
         CLC   INS823,HEX823
RT1_TEST853      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE853
         LTORG 
RT1_CCE853      DS 0H
*MEXIT #=  1685 LV= 2 RT1
*MEXIT #=  1684 LV= 1 ZOSOP
*MCALL #=  1686 LV= 1  ZOSOP 'E31C','MULTIPLY SINGLE (64<32) ','MSGF ',X
               'RXY N '
         JAS   R11,VER824
         USING *,R11
INS824   MSGF  R1,S2(X4)
HEX824   DC    X'E314D002001C'
NUM824   DC    P'824'
*MCALL #=  1687 LV= 2 VER824   RT1   CCE,INS824,HEX824
VER824   DS    0H
         CLC   INS824,HEX824
RT1_TEST854      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE854
         LTORG 
RT1_CCE854      DS 0H
*MEXIT #=  1687 LV= 2 RT1
*MEXIT #=  1686 LV= 1 ZOSOP
*MCALL #=  1688 LV= 1  ZOSOP 'E31D','DIVIDE SINGLE (64<32) ','DSGF ','RX
               XY N '
         JAS   R11,VER825
         USING *,R11
INS825   DSGF  R1,S2(X4)
HEX825   DC    X'E314D002001D'
NUM825   DC    P'825'
*MCALL #=  1689 LV= 2 VER825   RT1   CCE,INS825,HEX825
VER825   DS    0H
         CLC   INS825,HEX825
RT1_TEST855      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE855
         LTORG 
RT1_CCE855      DS 0H
*MEXIT #=  1689 LV= 2 RT1
*MEXIT #=  1688 LV= 1 ZOSOP
*MCALL #=  1690 LV= 1  ZOSOP 'E31E','LOAD REVERSED (32) ','LRV ','RXY NX
               3'
         JAS   R11,VER826
         USING *,R11
INS826   LRV  R1,S2(X4)
HEX826   DC    X'E314D002001E'
NUM826   DC    P'826'
*MCALL #=  1691 LV= 2 VER826   RT1   CCE,INS826,HEX826
VER826   DS    0H
         CLC   INS826,HEX826
RT1_TEST856      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE856
         LTORG 
RT1_CCE856      DS 0H
*MEXIT #=  1691 LV= 2 RT1
*MEXIT #=  1690 LV= 1 ZOSOP
*MCALL #=  1692 LV= 1  ZOSOP 'E31F','LOAD REVERSED (16) ','LRVH ','RXY X
               N3'
         JAS   R11,VER827
         USING *,R11
INS827   LRVH  R1,S2(X4)
HEX827   DC    X'E314D002001F'
NUM827   DC    P'827'
*MCALL #=  1693 LV= 2 VER827   RT1   CCE,INS827,HEX827
VER827   DS    0H
         CLC   INS827,HEX827
RT1_TEST857      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE857
         LTORG 
RT1_CCE857      DS 0H
*MEXIT #=  1693 LV= 2 RT1
*MEXIT #=  1692 LV= 1 ZOSOP
*MCALL #=  1694 LV= 1  ZOSOP 'E320','COMPARE (64) ','CG ','RXY C N '
         JAS   R11,VER828
         USING *,R11
INS828   CG   R1,S2(X4)
HEX828   DC    X'E314D0020020'
NUM828   DC    P'828'
*MCALL #=  1695 LV= 2 VER828   RT1   CCE,INS828,HEX828
VER828   DS    0H
         CLC   INS828,HEX828
RT1_TEST858      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE858
         LTORG 
RT1_CCE858      DS 0H
*MEXIT #=  1695 LV= 2 RT1
*MEXIT #=  1694 LV= 1 ZOSOP
*MCALL #=  1696 LV= 1  ZOSOP 'E321','COMPARE LOGICAL (64) ','CLG ','RXYX
                C N '
         JAS   R11,VER829
         USING *,R11
INS829   CLG  R1,S2(X4)
HEX829   DC    X'E314D0020021'
NUM829   DC    P'829'
*MCALL #=  1697 LV= 2 VER829   RT1   CCE,INS829,HEX829
VER829   DS    0H
         CLC   INS829,HEX829
RT1_TEST859      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE859
         LTORG 
RT1_CCE859      DS 0H
*MEXIT #=  1697 LV= 2 RT1
*MEXIT #=  1696 LV= 1 ZOSOP
*MCALL #=  1698 LV= 1  ZOSOP 'E324','STORE (64) ','STG ','RXY N '
         JAS   R11,VER830
         USING *,R11
INS830   STG  R1,S2(X4)
HEX830   DC    X'E314D0020024'
NUM830   DC    P'830'
*MCALL #=  1699 LV= 2 VER830   RT1   CCE,INS830,HEX830
VER830   DS    0H
         CLC   INS830,HEX830
RT1_TEST860      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE860
         LTORG 
RT1_CCE860      DS 0H
*MEXIT #=  1699 LV= 2 RT1
*MEXIT #=  1698 LV= 1 ZOSOP
*MCALL #=  1700 LV= 1  ZOSOP 'E326','CONVERT TO DECIMAL (32) ','CVDY ',X
               'RXY LD'
         JAS   R11,VER831
         USING *,R11
INS831   CVDY  R1,S2(X4)
HEX831   DC    X'E314D0020026'
NUM831   DC    P'831'
*MCALL #=  1701 LV= 2 VER831   RT1   CCE,INS831,HEX831
VER831   DS    0H
         CLC   INS831,HEX831
RT1_TEST861      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE861
         LTORG 
RT1_CCE861      DS 0H
*MEXIT #=  1701 LV= 2 RT1
*MEXIT #=  1700 LV= 1 ZOSOP
*MCALL #=  1702 LV= 1  ZOSOP 'E32E','CONVERT TO DECIMAL (64) ','CVDG ',X
               'RXY N '
         JAS   R11,VER832
         USING *,R11
INS832   CVDG  R1,S2(X4)
HEX832   DC    X'E314D002002E'
NUM832   DC    P'832'
*MCALL #=  1703 LV= 2 VER832   RT1   CCE,INS832,HEX832
VER832   DS    0H
         CLC   INS832,HEX832
RT1_TEST862      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE862
         LTORG 
RT1_CCE862      DS 0H
*MEXIT #=  1703 LV= 2 RT1
*MEXIT #=  1702 LV= 1 ZOSOP
*MCALL #=  1704 LV= 1  ZOSOP 'E32F','STORE REVERSED (64) ','STRVG','RXYX
                N '
         JAS   R11,VER833
         USING *,R11
INS833   STRVG R1,S2(X4)
HEX833   DC    X'E314D002002F'
NUM833   DC    P'833'
*MCALL #=  1705 LV= 2 VER833   RT1   CCE,INS833,HEX833
VER833   DS    0H
         CLC   INS833,HEX833
RT1_TEST863      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE863
         LTORG 
RT1_CCE863      DS 0H
*MEXIT #=  1705 LV= 2 RT1
*MEXIT #=  1704 LV= 1 ZOSOP
*MCALL #=  1706 LV= 1  ZOSOP 'E330','COMPARE (64<32) ','CGF ','RXY C N X
               '
         JAS   R11,VER834
         USING *,R11
INS834   CGF  R1,S2(X4)
HEX834   DC    X'E314D0020030'
NUM834   DC    P'834'
*MCALL #=  1707 LV= 2 VER834   RT1   CCE,INS834,HEX834
VER834   DS    0H
         CLC   INS834,HEX834
RT1_TEST864      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE864
         LTORG 
RT1_CCE864      DS 0H
*MEXIT #=  1707 LV= 2 RT1
*MEXIT #=  1706 LV= 1 ZOSOP
*MCALL #=  1708 LV= 1  ZOSOP 'E331','COMPARE LOGICAL (64<32) ','CLGF ',X
               'RXY C N '
         JAS   R11,VER835
         USING *,R11
INS835   CLGF  R1,S2(X4)
HEX835   DC    X'E314D0020031'
NUM835   DC    P'835'
*MCALL #=  1709 LV= 2 VER835   RT1   CCE,INS835,HEX835
VER835   DS    0H
         CLC   INS835,HEX835
RT1_TEST865      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE865
         LTORG 
RT1_CCE865      DS 0H
*MEXIT #=  1709 LV= 2 RT1
*MEXIT #=  1708 LV= 1 ZOSOP
*MCALL #=  1710 LV= 1  ZOSOP 'E332','Load and Test','LTGF','RXY',18  RPX
               I-817
         JAS   R11,VER836
         USING *,R11
INS836   LTGF R1,S2(X4)
HEX836   DC    X'E314D0020032'
NUM836   DC    P'836'
*MCALL #=  1711 LV= 2 VER836   RT1   CCE,INS836,HEX836
VER836   DS    0H
         CLC   INS836,HEX836
RT1_TEST866      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE866
         LTORG 
RT1_CCE866      DS 0H
*MEXIT #=  1711 LV= 2 RT1
*MEXIT #=  1710 LV= 1 ZOSOP
*MCALL #=  1712 LV= 1  ZOSOP 'E334','Compare Halfword','CGH','RXY',18  X
               RPI-817
         JAS   R11,VER837
         USING *,R11
INS837   CGH  R1,S2(X4)
HEX837   DC    X'E314D0020034'
NUM837   DC    P'837'
*MCALL #=  1713 LV= 2 VER837   RT1   CCE,INS837,HEX837
VER837   DS    0H
         CLC   INS837,HEX837
RT1_TEST867      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE867
         LTORG 
RT1_CCE867      DS 0H
*MEXIT #=  1713 LV= 2 RT1
*MEXIT #=  1712 LV= 1 ZOSOP
*MCALL #=  1714 LV= 1  ZOSOP 'E336','Prefetch Data','PFD','RXY',18  RPIX
               -817
         JAS   R11,VER838
         USING *,R11
INS838   PFD  R1,S2(X4)
HEX838   DC    X'E314D0020036'
NUM838   DC    P'838'
*MCALL #=  1715 LV= 2 VER838   RT1   CCE,INS838,HEX838
VER838   DS    0H
         CLC   INS838,HEX838
RT1_TEST868      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE868
         LTORG 
RT1_CCE868      DS 0H
*MEXIT #=  1715 LV= 2 RT1
*MEXIT #=  1714 LV= 1 ZOSOP
*MCALL #=  1716 LV= 1  ZOSOP 'E33E','STORE REVERSED (32) ','STRV ','RXYX
                N3'
         JAS   R11,VER839
         USING *,R11
INS839   STRV  R1,S2(X4)
HEX839   DC    X'E314D002003E'
NUM839   DC    P'839'
*MCALL #=  1717 LV= 2 VER839   RT1   CCE,INS839,HEX839
VER839   DS    0H
         CLC   INS839,HEX839
RT1_TEST869      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE869
         LTORG 
RT1_CCE869      DS 0H
*MEXIT #=  1717 LV= 2 RT1
*MEXIT #=  1716 LV= 1 ZOSOP
*MCALL #=  1718 LV= 1  ZOSOP 'E33F','STORE REVERSED (16) ','STRVH','RXYX
                N3'
         JAS   R11,VER840
         USING *,R11
INS840   STRVH R1,S2(X4)
HEX840   DC    X'E314D002003F'
NUM840   DC    P'840'
*MCALL #=  1719 LV= 2 VER840   RT1   CCE,INS840,HEX840
VER840   DS    0H
         CLC   INS840,HEX840
RT1_TEST870      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE870
         LTORG 
RT1_CCE870      DS 0H
*MEXIT #=  1719 LV= 2 RT1
*MEXIT #=  1718 LV= 1 ZOSOP
*MCALL #=  1720 LV= 1  ZOSOP 'E346','BRANCH ON COUNT (64) ','BCTG ','RXX
               Y N '
         JAS   R11,VER841
         USING *,R11
INS841   BCTG  R1,S2(X4)
HEX841   DC    X'E314D0020046'
NUM841   DC    P'841'
*MCALL #=  1721 LV= 2 VER841   RT1   CCE,INS841,HEX841
VER841   DS    0H
         CLC   INS841,HEX841
RT1_TEST871      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE871
         LTORG 
RT1_CCE871      DS 0H
*MEXIT #=  1721 LV= 2 RT1
*MEXIT #=  1720 LV= 1 ZOSOP
*MCALL #=  1722 LV= 1  ZOSOP 'E350','STORE (32) ','STY ','RXY LD'
         JAS   R11,VER842
         USING *,R11
INS842   STY  R1,S2(X4)
HEX842   DC    X'E314D0020050'
NUM842   DC    P'842'
*MCALL #=  1723 LV= 2 VER842   RT1   CCE,INS842,HEX842
VER842   DS    0H
         CLC   INS842,HEX842
RT1_TEST872      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE872
         LTORG 
RT1_CCE872      DS 0H
*MEXIT #=  1723 LV= 2 RT1
*MEXIT #=  1722 LV= 1 ZOSOP
*MCALL #=  1724 LV= 1  ZOSOP 'E351','MULTIPLY SINGLE (32) ','MSY ','RXYX
                LD'
         JAS   R11,VER843
         USING *,R11
INS843   MSY  R1,S2(X4)
HEX843   DC    X'E314D0020051'
NUM843   DC    P'843'
*MCALL #=  1725 LV= 2 VER843   RT1   CCE,INS843,HEX843
VER843   DS    0H
         CLC   INS843,HEX843
RT1_TEST873      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE873
         LTORG 
RT1_CCE873      DS 0H
*MEXIT #=  1725 LV= 2 RT1
*MEXIT #=  1724 LV= 1 ZOSOP
*MCALL #=  1726 LV= 1  ZOSOP 'E354','AND (32) ','NY ','RXY C LD'
         JAS   R11,VER844
         USING *,R11
INS844   NY   R1,S2(X4)
HEX844   DC    X'E314D0020054'
NUM844   DC    P'844'
*MCALL #=  1727 LV= 2 VER844   RT1   CCE,INS844,HEX844
VER844   DS    0H
         CLC   INS844,HEX844
RT1_TEST874      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE874
         LTORG 
RT1_CCE874      DS 0H
*MEXIT #=  1727 LV= 2 RT1
*MEXIT #=  1726 LV= 1 ZOSOP
*MCALL #=  1728 LV= 1  ZOSOP 'E355','COMPARE LOGICAL (32) ','CLY ','RXYX
                C LD'
         JAS   R11,VER845
         USING *,R11
INS845   CLY  R1,S2(X4)
HEX845   DC    X'E314D0020055'
NUM845   DC    P'845'
*MCALL #=  1729 LV= 2 VER845   RT1   CCE,INS845,HEX845
VER845   DS    0H
         CLC   INS845,HEX845
RT1_TEST875      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE875
         LTORG 
RT1_CCE875      DS 0H
*MEXIT #=  1729 LV= 2 RT1
*MEXIT #=  1728 LV= 1 ZOSOP
*MCALL #=  1730 LV= 1  ZOSOP 'E356','OR (32) ','OY ','RXY C LD'
         JAS   R11,VER846
         USING *,R11
INS846   OY   R1,S2(X4)
HEX846   DC    X'E314D0020056'
NUM846   DC    P'846'
*MCALL #=  1731 LV= 2 VER846   RT1   CCE,INS846,HEX846
VER846   DS    0H
         CLC   INS846,HEX846
RT1_TEST876      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE876
         LTORG 
RT1_CCE876      DS 0H
*MEXIT #=  1731 LV= 2 RT1
*MEXIT #=  1730 LV= 1 ZOSOP
*MCALL #=  1732 LV= 1  ZOSOP 'E357','EXCLUSIVE OR (32) ','XY ','RXY C LX
               D'
         JAS   R11,VER847
         USING *,R11
INS847   XY   R1,S2(X4)
HEX847   DC    X'E314D0020057'
NUM847   DC    P'847'
*MCALL #=  1733 LV= 2 VER847   RT1   CCE,INS847,HEX847
VER847   DS    0H
         CLC   INS847,HEX847
RT1_TEST877      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE877
         LTORG 
RT1_CCE877      DS 0H
*MEXIT #=  1733 LV= 2 RT1
*MEXIT #=  1732 LV= 1 ZOSOP
*MCALL #=  1734 LV= 1  ZOSOP 'E358','LOAD (32) ','LY ','RXY LD'
         JAS   R11,VER848
         USING *,R11
INS848   LY   R1,S2(X4)
HEX848   DC    X'E314D0020058'
NUM848   DC    P'848'
*MCALL #=  1735 LV= 2 VER848   RT1   CCE,INS848,HEX848
VER848   DS    0H
         CLC   INS848,HEX848
RT1_TEST878      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE878
         LTORG 
RT1_CCE878      DS 0H
*MEXIT #=  1735 LV= 2 RT1
*MEXIT #=  1734 LV= 1 ZOSOP
*MCALL #=  1736 LV= 1  ZOSOP 'E359','COMPARE (32) ','CY ','RXY C LD'
         JAS   R11,VER849
         USING *,R11
INS849   CY   R1,S2(X4)
HEX849   DC    X'E314D0020059'
NUM849   DC    P'849'
*MCALL #=  1737 LV= 2 VER849   RT1   CCE,INS849,HEX849
VER849   DS    0H
         CLC   INS849,HEX849
RT1_TEST879      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE879
         LTORG 
RT1_CCE879      DS 0H
*MEXIT #=  1737 LV= 2 RT1
*MEXIT #=  1736 LV= 1 ZOSOP
*MCALL #=  1738 LV= 1  ZOSOP 'E35A','ADD (32) ','AY ','RXY C LD'
         JAS   R11,VER850
         USING *,R11
INS850   AY   R1,S2(X4)
HEX850   DC    X'E314D002005A'
NUM850   DC    P'850'
*MCALL #=  1739 LV= 2 VER850   RT1   CCE,INS850,HEX850
VER850   DS    0H
         CLC   INS850,HEX850
RT1_TEST880      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE880
         LTORG 
RT1_CCE880      DS 0H
*MEXIT #=  1739 LV= 2 RT1
*MEXIT #=  1738 LV= 1 ZOSOP
*MCALL #=  1740 LV= 1  ZOSOP 'E35B','SUBTRACT (32) ','SY ','RXY C LD'
         JAS   R11,VER851
         USING *,R11
INS851   SY   R1,S2(X4)
HEX851   DC    X'E314D002005B'
NUM851   DC    P'851'
*MCALL #=  1741 LV= 2 VER851   RT1   CCE,INS851,HEX851
VER851   DS    0H
         CLC   INS851,HEX851
RT1_TEST881      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE881
         LTORG 
RT1_CCE881      DS 0H
*MEXIT #=  1741 LV= 2 RT1
*MEXIT #=  1740 LV= 1 ZOSOP
*MCALL #=  1742 LV= 1  ZOSOP 'E35C','Multiply','MFY','RXY',18  RPI-817
         JAS   R11,VER852
         USING *,R11
INS852   MFY  R1,S2(X4)
HEX852   DC    X'E314D002005C'
NUM852   DC    P'852'
*MCALL #=  1743 LV= 2 VER852   RT1   CCE,INS852,HEX852
VER852   DS    0H
         CLC   INS852,HEX852
RT1_TEST882      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE882
         LTORG 
RT1_CCE882      DS 0H
*MEXIT #=  1743 LV= 2 RT1
*MEXIT #=  1742 LV= 1 ZOSOP
*MCALL #=  1744 LV= 1  ZOSOP 'E35E','ADD LOGICAL (32) ','ALY ','RXY C LX
               D'
         JAS   R11,VER853
         USING *,R11
INS853   ALY  R1,S2(X4)
HEX853   DC    X'E314D002005E'
NUM853   DC    P'853'
*MCALL #=  1745 LV= 2 VER853   RT1   CCE,INS853,HEX853
VER853   DS    0H
         CLC   INS853,HEX853
RT1_TEST883      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE883
         LTORG 
RT1_CCE883      DS 0H
*MEXIT #=  1745 LV= 2 RT1
*MEXIT #=  1744 LV= 1 ZOSOP
*MCALL #=  1746 LV= 1  ZOSOP 'E35F','SUBTRACT LOGICAL (32) ','SLY ','RXX
               Y C LD'
         JAS   R11,VER854
         USING *,R11
INS854   SLY  R1,S2(X4)
HEX854   DC    X'E314D002005F'
NUM854   DC    P'854'
*MCALL #=  1747 LV= 2 VER854   RT1   CCE,INS854,HEX854
VER854   DS    0H
         CLC   INS854,HEX854
RT1_TEST884      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE884
         LTORG 
RT1_CCE884      DS 0H
*MEXIT #=  1747 LV= 2 RT1
*MEXIT #=  1746 LV= 1 ZOSOP
*MCALL #=  1748 LV= 1  ZOSOP 'E370','STORE HALFWORD ','STHY ','RXY LD'
         JAS   R11,VER855
         USING *,R11
INS855   STHY  R1,S2(X4)
HEX855   DC    X'E314D0020070'
NUM855   DC    P'855'
*MCALL #=  1749 LV= 2 VER855   RT1   CCE,INS855,HEX855
VER855   DS    0H
         CLC   INS855,HEX855
RT1_TEST885      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE885
         LTORG 
RT1_CCE885      DS 0H
*MEXIT #=  1749 LV= 2 RT1
*MEXIT #=  1748 LV= 1 ZOSOP
*MCALL #=  1750 LV= 1  ZOSOP 'E371','LOAD ADDRESS ','LAY ','RXY LD'
         JAS   R11,VER856
         USING *,R11
INS856   LAY  R1,S2(X4)
HEX856   DC    X'E314D0020071'
NUM856   DC    P'856'
*MCALL #=  1751 LV= 2 VER856   RT1   CCE,INS856,HEX856
VER856   DS    0H
         CLC   INS856,HEX856
RT1_TEST886      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE886
         LTORG 
RT1_CCE886      DS 0H
*MEXIT #=  1751 LV= 2 RT1
*MEXIT #=  1750 LV= 1 ZOSOP
*MCALL #=  1752 LV= 1  ZOSOP 'E372','STORE CHARACTER ','STCY ','RXY LD'
         JAS   R11,VER857
         USING *,R11
INS857   STCY  R1,S2(X4)
HEX857   DC    X'E314D0020072'
NUM857   DC    P'857'
*MCALL #=  1753 LV= 2 VER857   RT1   CCE,INS857,HEX857
VER857   DS    0H
         CLC   INS857,HEX857
RT1_TEST887      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE887
         LTORG 
RT1_CCE887      DS 0H
*MEXIT #=  1753 LV= 2 RT1
*MEXIT #=  1752 LV= 1 ZOSOP
*MCALL #=  1754 LV= 1  ZOSOP 'E373','INSERT CHARACTER ','ICY ','RXY LD'
         JAS   R11,VER858
         USING *,R11
INS858   ICY  R1,S2(X4)
HEX858   DC    X'E314D0020073'
NUM858   DC    P'858'
*MCALL #=  1755 LV= 2 VER858   RT1   CCE,INS858,HEX858
VER858   DS    0H
         CLC   INS858,HEX858
RT1_TEST888      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE888
         LTORG 
RT1_CCE888      DS 0H
*MEXIT #=  1755 LV= 2 RT1
*MEXIT #=  1754 LV= 1 ZOSOP
*MCALL #=  1756 LV= 1  ZOSOP 'E376','LOAD BYTE (32) ','LB ','RXY LD'
         JAS   R11,VER859
         USING *,R11
INS859   LB   R1,S2(X4)
HEX859   DC    X'E314D0020076'
NUM859   DC    P'859'
*MCALL #=  1757 LV= 2 VER859   RT1   CCE,INS859,HEX859
VER859   DS    0H
         CLC   INS859,HEX859
RT1_TEST889      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE889
         LTORG 
RT1_CCE889      DS 0H
*MEXIT #=  1757 LV= 2 RT1
*MEXIT #=  1756 LV= 1 ZOSOP
*MCALL #=  1758 LV= 1  ZOSOP 'E375','Load Address Extended','LAEY','RXYX
               ',18  RPI-817
         JAS   R11,VER860
         USING *,R11
INS860   LAEY R1,S2(X4)
HEX860   DC    X'E314D0020075'
NUM860   DC    P'860'
*MCALL #=  1759 LV= 2 VER860   RT1   CCE,INS860,HEX860
VER860   DS    0H
         CLC   INS860,HEX860
RT1_TEST890      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE890
         LTORG 
RT1_CCE890      DS 0H
*MEXIT #=  1759 LV= 2 RT1
*MEXIT #=  1758 LV= 1 ZOSOP
*MCALL #=  1760 LV= 1  ZOSOP 'E377','LOAD BYTE (64) ','LGB ','RXY LD'
         JAS   R11,VER861
         USING *,R11
INS861   LGB  R1,S2(X4)
HEX861   DC    X'E314D0020077'
NUM861   DC    P'861'
*MCALL #=  1761 LV= 2 VER861   RT1   CCE,INS861,HEX861
VER861   DS    0H
         CLC   INS861,HEX861
RT1_TEST891      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE891
         LTORG 
RT1_CCE891      DS 0H
*MEXIT #=  1761 LV= 2 RT1
*MEXIT #=  1760 LV= 1 ZOSOP
*MCALL #=  1762 LV= 1  ZOSOP 'E378','LOAD HALFWORD (32) ','LHY ','RXY LX
               D'
         JAS   R11,VER862
         USING *,R11
INS862   LHY  R1,S2(X4)
HEX862   DC    X'E314D0020078'
NUM862   DC    P'862'
*MCALL #=  1763 LV= 2 VER862   RT1   CCE,INS862,HEX862
VER862   DS    0H
         CLC   INS862,HEX862
RT1_TEST892      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE892
         LTORG 
RT1_CCE892      DS 0H
*MEXIT #=  1763 LV= 2 RT1
*MEXIT #=  1762 LV= 1 ZOSOP
*MCALL #=  1764 LV= 1  ZOSOP 'E379','COMPARE HALFWORD ','CHY ','RXY C LX
               D'
         JAS   R11,VER863
         USING *,R11
INS863   CHY  R1,S2(X4)
HEX863   DC    X'E314D0020079'
NUM863   DC    P'863'
*MCALL #=  1765 LV= 2 VER863   RT1   CCE,INS863,HEX863
VER863   DS    0H
         CLC   INS863,HEX863
RT1_TEST893      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE893
         LTORG 
RT1_CCE893      DS 0H
*MEXIT #=  1765 LV= 2 RT1
*MEXIT #=  1764 LV= 1 ZOSOP
*MCALL #=  1766 LV= 1  ZOSOP 'E37A','ADD HALFWORD ','AHY ','RXY C LD'
         JAS   R11,VER864
         USING *,R11
INS864   AHY  R1,S2(X4)
HEX864   DC    X'E314D002007A'
NUM864   DC    P'864'
*MCALL #=  1767 LV= 2 VER864   RT1   CCE,INS864,HEX864
VER864   DS    0H
         CLC   INS864,HEX864
RT1_TEST894      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE894
         LTORG 
RT1_CCE894      DS 0H
*MEXIT #=  1767 LV= 2 RT1
*MEXIT #=  1766 LV= 1 ZOSOP
*MCALL #=  1768 LV= 1  ZOSOP 'E37B','SUBTRACT HALFWORD ','SHY ','RXY C X
               LD'
         JAS   R11,VER865
         USING *,R11
INS865   SHY  R1,S2(X4)
HEX865   DC    X'E314D002007B'
NUM865   DC    P'865'
*MCALL #=  1769 LV= 2 VER865   RT1   CCE,INS865,HEX865
VER865   DS    0H
         CLC   INS865,HEX865
RT1_TEST895      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE895
         LTORG 
RT1_CCE895      DS 0H
*MEXIT #=  1769 LV= 2 RT1
*MEXIT #=  1768 LV= 1 ZOSOP
*MCALL #=  1770 LV= 1  ZOSOP 'E37C','Multiply Halfword','MHY','RXY',18 X
                RPI-817
         JAS   R11,VER866
         USING *,R11
INS866   MHY  R1,S2(X4)
HEX866   DC    X'E314D002007C'
NUM866   DC    P'866'
*MCALL #=  1771 LV= 2 VER866   RT1   CCE,INS866,HEX866
VER866   DS    0H
         CLC   INS866,HEX866
RT1_TEST896      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE896
         LTORG 
RT1_CCE896      DS 0H
*MEXIT #=  1771 LV= 2 RT1
*MEXIT #=  1770 LV= 1 ZOSOP
*MCALL #=  1772 LV= 1  ZOSOP 'E380','AND (64) ','NG ','RXY C N '
         JAS   R11,VER867
         USING *,R11
INS867   NG   R1,S2(X4)
HEX867   DC    X'E314D0020080'
NUM867   DC    P'867'
*MCALL #=  1773 LV= 2 VER867   RT1   CCE,INS867,HEX867
VER867   DS    0H
         CLC   INS867,HEX867
RT1_TEST897      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE897
         LTORG 
RT1_CCE897      DS 0H
*MEXIT #=  1773 LV= 2 RT1
*MEXIT #=  1772 LV= 1 ZOSOP
*MCALL #=  1774 LV= 1  ZOSOP 'E381','OR (64) ','OG ','RXY C N '
         JAS   R11,VER868
         USING *,R11
INS868   OG   R1,S2(X4)
HEX868   DC    X'E314D0020081'
NUM868   DC    P'868'
*MCALL #=  1775 LV= 2 VER868   RT1   CCE,INS868,HEX868
VER868   DS    0H
         CLC   INS868,HEX868
RT1_TEST898      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE898
         LTORG 
RT1_CCE898      DS 0H
*MEXIT #=  1775 LV= 2 RT1
*MEXIT #=  1774 LV= 1 ZOSOP
*MCALL #=  1776 LV= 1  ZOSOP 'E382','EXCLUSIVE OR (64) ','XG ','RXY C NX
                '
         JAS   R11,VER869
         USING *,R11
INS869   XG   R1,S2(X4)
HEX869   DC    X'E314D0020082'
NUM869   DC    P'869'
*MCALL #=  1777 LV= 2 VER869   RT1   CCE,INS869,HEX869
VER869   DS    0H
         CLC   INS869,HEX869
RT1_TEST899      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE899
         LTORG 
RT1_CCE899      DS 0H
*MEXIT #=  1777 LV= 2 RT1
*MEXIT #=  1776 LV= 1 ZOSOP
*MCALL #=  1778 LV= 1  ZOSOP 'E386','MULTIPLY LOGICAL (128<64) ','MLG 'X
               ,'RXY N '
         JAS   R11,VER870
         USING *,R11
INS870   MLG  R1,S2(X4)
HEX870   DC    X'E314D0020086'
NUM870   DC    P'870'
*MCALL #=  1779 LV= 2 VER870   RT1   CCE,INS870,HEX870
VER870   DS    0H
         CLC   INS870,HEX870
RT1_TEST900      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE900
         LTORG 
RT1_CCE900      DS 0H
*MEXIT #=  1779 LV= 2 RT1
*MEXIT #=  1778 LV= 1 ZOSOP
*MCALL #=  1780 LV= 1  ZOSOP 'E387','DIVIDE LOGICAL (64<128) ','DLG ','X
               RXY N '
         JAS   R11,VER871
         USING *,R11
INS871   DLG  R1,S2(X4)
HEX871   DC    X'E314D0020087'
NUM871   DC    P'871'
*MCALL #=  1781 LV= 2 VER871   RT1   CCE,INS871,HEX871
VER871   DS    0H
         CLC   INS871,HEX871
RT1_TEST901      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE901
         LTORG 
RT1_CCE901      DS 0H
*MEXIT #=  1781 LV= 2 RT1
*MEXIT #=  1780 LV= 1 ZOSOP
*MCALL #=  1782 LV= 1  ZOSOP 'E388','ADD LOGICAL WITH CARRY (64) ','ALCX
               G ','RXY C N '
         JAS   R11,VER872
         USING *,R11
INS872   ALCG  R1,S2(X4)
HEX872   DC    X'E314D0020088'
NUM872   DC    P'872'
*MCALL #=  1783 LV= 2 VER872   RT1   CCE,INS872,HEX872
VER872   DS    0H
         CLC   INS872,HEX872
RT1_TEST902      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE902
         LTORG 
RT1_CCE902      DS 0H
*MEXIT #=  1783 LV= 2 RT1
*MEXIT #=  1782 LV= 1 ZOSOP
*MCALL #=  1784 LV= 1  ZOSOP 'E389','SUBTRACT LOGICAL WITH BORROW (64) X
               ','SLBG ','RXY C N '
         JAS   R11,VER873
         USING *,R11
INS873   SLBG  R1,S2(X4)
HEX873   DC    X'E314D0020089'
NUM873   DC    P'873'
*MCALL #=  1785 LV= 2 VER873   RT1   CCE,INS873,HEX873
VER873   DS    0H
         CLC   INS873,HEX873
RT1_TEST903      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE903
         LTORG 
RT1_CCE903      DS 0H
*MEXIT #=  1785 LV= 2 RT1
*MEXIT #=  1784 LV= 1 ZOSOP
*MCALL #=  1786 LV= 1  ZOSOP 'E38E','STORE PAIR TO QUADWORD ','STPQ ','X
               RXY N '
         JAS   R11,VER874
         USING *,R11
INS874   STPQ  R1,S2(X4)
HEX874   DC    X'E314D002008E'
NUM874   DC    P'874'
*MCALL #=  1787 LV= 2 VER874   RT1   CCE,INS874,HEX874
VER874   DS    0H
         CLC   INS874,HEX874
RT1_TEST904      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE904
         LTORG 
RT1_CCE904      DS 0H
*MEXIT #=  1787 LV= 2 RT1
*MEXIT #=  1786 LV= 1 ZOSOP
*MCALL #=  1788 LV= 1  ZOSOP 'E38F','LOAD PAIR FROM QUADWORD ','LPQ ','X
               RXY N '
         JAS   R11,VER875
         USING *,R11
INS875   LPQ  R1,S2(X4)
HEX875   DC    X'E314D002008F'
NUM875   DC    P'875'
*MCALL #=  1789 LV= 2 VER875   RT1   CCE,INS875,HEX875
VER875   DS    0H
         CLC   INS875,HEX875
RT1_TEST905      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE905
         LTORG 
RT1_CCE905      DS 0H
*MEXIT #=  1789 LV= 2 RT1
*MEXIT #=  1788 LV= 1 ZOSOP
*MCALL #=  1790 LV= 1  ZOSOP 'E390','LOAD LOGICAL CHARACTER ','LLGC ','X
               RXY N '
         JAS   R11,VER876
         USING *,R11
INS876   LLGC  R1,S2(X4)
HEX876   DC    X'E314D0020090'
NUM876   DC    P'876'
*MCALL #=  1791 LV= 2 VER876   RT1   CCE,INS876,HEX876
VER876   DS    0H
         CLC   INS876,HEX876
RT1_TEST906      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE906
         LTORG 
RT1_CCE906      DS 0H
*MEXIT #=  1791 LV= 2 RT1
*MEXIT #=  1790 LV= 1 ZOSOP
*MCALL #=  1792 LV= 1  ZOSOP 'E391','LOAD LOGICAL HALFWORD ','LLGH ','RX
               XY N '
         JAS   R11,VER877
         USING *,R11
INS877   LLGH  R1,S2(X4)
HEX877   DC    X'E314D0020091'
NUM877   DC    P'877'
*MCALL #=  1793 LV= 2 VER877   RT1   CCE,INS877,HEX877
VER877   DS    0H
         CLC   INS877,HEX877
RT1_TEST907      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE907
         LTORG 
RT1_CCE907      DS 0H
*MEXIT #=  1793 LV= 2 RT1
*MEXIT #=  1792 LV= 1 ZOSOP
*MCALL #=  1794 LV= 1  ZOSOP 'E394','LOAD LOGICAL CHARACTER','LLC','RXYX
               ',Z9
         JAS   R11,VER878
         USING *,R11
INS878   LLC  R1,S2(X4)
HEX878   DC    X'E314D0020094'
NUM878   DC    P'878'
*MCALL #=  1795 LV= 2 VER878   RT1   CCE,INS878,HEX878
VER878   DS    0H
         CLC   INS878,HEX878
RT1_TEST908      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE908
         LTORG 
RT1_CCE908      DS 0H
*MEXIT #=  1795 LV= 2 RT1
*MEXIT #=  1794 LV= 1 ZOSOP
*MCALL #=  1796 LV= 1  ZOSOP 'E395','LOAD LOGICAL HALFWORD','LLH','RXY'X
               ,Z9
         JAS   R11,VER879
         USING *,R11
INS879   LLH  R1,S2(X4)
HEX879   DC    X'E314D0020095'
NUM879   DC    P'879'
*MCALL #=  1797 LV= 2 VER879   RT1   CCE,INS879,HEX879
VER879   DS    0H
         CLC   INS879,HEX879
RT1_TEST909      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE909
         LTORG 
RT1_CCE909      DS 0H
*MEXIT #=  1797 LV= 2 RT1
*MEXIT #=  1796 LV= 1 ZOSOP
*MCALL #=  1798 LV= 1  ZOSOP 'E396','MULTIPLY LOGICAL (64<32) ','ML ','X
               RXY N3'
         JAS   R11,VER880
         USING *,R11
INS880   ML   R1,S2(X4)
HEX880   DC    X'E314D0020096'
NUM880   DC    P'880'
*MCALL #=  1799 LV= 2 VER880   RT1   CCE,INS880,HEX880
VER880   DS    0H
         CLC   INS880,HEX880
RT1_TEST910      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE910
         LTORG 
RT1_CCE910      DS 0H
*MEXIT #=  1799 LV= 2 RT1
*MEXIT #=  1798 LV= 1 ZOSOP
*MCALL #=  1800 LV= 1  ZOSOP 'E397','DIVIDE LOGICAL (32<64) ','DL ','RXX
               Y N3'
         JAS   R11,VER881
         USING *,R11
INS881   DL   R1,S2(X4)
HEX881   DC    X'E314D0020097'
NUM881   DC    P'881'
*MCALL #=  1801 LV= 2 VER881   RT1   CCE,INS881,HEX881
VER881   DS    0H
         CLC   INS881,HEX881
RT1_TEST911      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE911
         LTORG 
RT1_CCE911      DS 0H
*MEXIT #=  1801 LV= 2 RT1
*MEXIT #=  1800 LV= 1 ZOSOP
*MCALL #=  1802 LV= 1  ZOSOP 'E398','ADD LOGICAL WITH CARRY (32) ','ALCX
                ','RXY C N3'
         JAS   R11,VER882
         USING *,R11
INS882   ALC  R1,S2(X4)
HEX882   DC    X'E314D0020098'
NUM882   DC    P'882'
*MCALL #=  1803 LV= 2 VER882   RT1   CCE,INS882,HEX882
VER882   DS    0H
         CLC   INS882,HEX882
RT1_TEST912      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE912
         LTORG 
RT1_CCE912      DS 0H
*MEXIT #=  1803 LV= 2 RT1
*MEXIT #=  1802 LV= 1 ZOSOP
*MCALL #=  1804 LV= 1  ZOSOP 'E399','SUBTRACT LOGICAL WITH BORROW (32) X
               ','SLB ','RXY C N3'
         JAS   R11,VER883
         USING *,R11
INS883   SLB  R1,S2(X4)
HEX883   DC    X'E314D0020099'
NUM883   DC    P'883'
*MCALL #=  1805 LV= 2 VER883   RT1   CCE,INS883,HEX883
VER883   DS    0H
         CLC   INS883,HEX883
RT1_TEST913      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE913
         LTORG 
RT1_CCE913      DS 0H
*MEXIT #=  1805 LV= 2 RT1
*MEXIT #=  1804 LV= 1 ZOSOP
*MCALL #=  1806 LV= 1  ZOSOP 'E3C0','LOAD BYTE HIGH (32??8)','LBH','RXYX
               -a'  RPI-1125 Z196
         JAS   R11,VER884
         USING *,R11
INS884   LBH  R1,S2(X4)
HEX884   DC    X'E314D00200C0'
NUM884   DC    P'884'
*MCALL #=  1807 LV= 2 VER884   RT1   CCE,INS884,HEX884
VER884   DS    0H
         CLC   INS884,HEX884
RT1_TEST914      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE914
         LTORG 
RT1_CCE914      DS 0H
*MEXIT #=  1807 LV= 2 RT1
*MEXIT #=  1806 LV= 1 ZOSOP
*MCALL #=  1808 LV= 1  ZOSOP 'E3C2','LOAD LOGICAL CHARACTER HIGH (32??8X
               )','LLCH','RXY-a'  RPI 1125 Z196
         JAS   R11,VER885
         USING *,R11
INS885   LLCH R1,S2(X4)
HEX885   DC    X'E314D00200C2'
NUM885   DC    P'885'
*MCALL #=  1809 LV= 2 VER885   RT1   CCE,INS885,HEX885
VER885   DS    0H
         CLC   INS885,HEX885
RT1_TEST915      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE915
         LTORG 
RT1_CCE915      DS 0H
*MEXIT #=  1809 LV= 2 RT1
*MEXIT #=  1808 LV= 1 ZOSOP
*MCALL #=  1810 LV= 1  ZOSOP 'E3C3','STORE CHARACTER HIGH (8)','STCH','X
               RXY-a'  RPI-1125 Z196
         JAS   R11,VER886
         USING *,R11
INS886   STCH R1,S2(X4)
HEX886   DC    X'E314D00200C3'
NUM886   DC    P'886'
*MCALL #=  1811 LV= 2 VER886   RT1   CCE,INS886,HEX886
VER886   DS    0H
         CLC   INS886,HEX886
RT1_TEST916      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE916
         LTORG 
RT1_CCE916      DS 0H
*MEXIT #=  1811 LV= 2 RT1
*MEXIT #=  1810 LV= 1 ZOSOP
*MCALL #=  1812 LV= 1  ZOSOP 'E3C4','LOAD HALFWORD HIGH (32??16)','LHH'X
               ,'RXY-a'  RPI-1125 Z196
         JAS   R11,VER887
         USING *,R11
INS887   LHH  R1,S2(X4)
HEX887   DC    X'E314D00200C4'
NUM887   DC    P'887'
*MCALL #=  1813 LV= 2 VER887   RT1   CCE,INS887,HEX887
VER887   DS    0H
         CLC   INS887,HEX887
RT1_TEST917      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE917
         LTORG 
RT1_CCE917      DS 0H
*MEXIT #=  1813 LV= 2 RT1
*MEXIT #=  1812 LV= 1 ZOSOP
*MCALL #=  1814 LV= 1  ZOSOP 'E3C6','LOAD LOGICAL HALFWORD HIGH (32??16X
               )','LLHH','RXY-a'  RPI 1125 Z196
         JAS   R11,VER888
         USING *,R11
INS888   LLHH R1,S2(X4)
HEX888   DC    X'E314D00200C6'
NUM888   DC    P'888'
*MCALL #=  1815 LV= 2 VER888   RT1   CCE,INS888,HEX888
VER888   DS    0H
         CLC   INS888,HEX888
RT1_TEST918      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE918
         LTORG 
RT1_CCE918      DS 0H
*MEXIT #=  1815 LV= 2 RT1
*MEXIT #=  1814 LV= 1 ZOSOP
*MCALL #=  1816 LV= 1  ZOSOP 'E3C7','STORE HALFWORD HIGH (16)','STHH','X
               RXY-a'  RPI-1125 Z196
         JAS   R11,VER889
         USING *,R11
INS889   STHH R1,S2(X4)
HEX889   DC    X'E314D00200C7'
NUM889   DC    P'889'
*MCALL #=  1817 LV= 2 VER889   RT1   CCE,INS889,HEX889
VER889   DS    0H
         CLC   INS889,HEX889
RT1_TEST919      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE919
         LTORG 
RT1_CCE919      DS 0H
*MEXIT #=  1817 LV= 2 RT1
*MEXIT #=  1816 LV= 1 ZOSOP
*MCALL #=  1818 LV= 1  ZOSOP 'E3CA','LOAD HIGH (32)','LFH','RXY-a'  RPIX
               -1125 Z196
         JAS   R11,VER890
         USING *,R11
INS890   LFH  R1,S2(X4)
HEX890   DC    X'E314D00200CA'
NUM890   DC    P'890'
*MCALL #=  1819 LV= 2 VER890   RT1   CCE,INS890,HEX890
VER890   DS    0H
         CLC   INS890,HEX890
RT1_TEST920      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE920
         LTORG 
RT1_CCE920      DS 0H
*MEXIT #=  1819 LV= 2 RT1
*MEXIT #=  1818 LV= 1 ZOSOP
*MCALL #=  1820 LV= 1  ZOSOP 'E3CB','STORE HIGH (32)','STFH','RXY-a'  RX
               PI-1125 Z196
         JAS   R11,VER891
         USING *,R11
INS891   STFH R1,S2(X4)
HEX891   DC    X'E314D00200CB'
NUM891   DC    P'891'
*MCALL #=  1821 LV= 2 VER891   RT1   CCE,INS891,HEX891
VER891   DS    0H
         CLC   INS891,HEX891
RT1_TEST921      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE921
         LTORG 
RT1_CCE921      DS 0H
*MEXIT #=  1821 LV= 2 RT1
*MEXIT #=  1820 LV= 1 ZOSOP
*MCALL #=  1822 LV= 1  ZOSOP 'E3CD','COMPARE HIGH (32)','CHF','RXY-a'  X
               RPI-1125 Z196
         JAS   R11,VER892
         USING *,R11
INS892   CHF  R1,S2(X4)
HEX892   DC    X'E314D00200CD'
NUM892   DC    P'892'
*MCALL #=  1823 LV= 2 VER892   RT1   CCE,INS892,HEX892
VER892   DS    0H
         CLC   INS892,HEX892
RT1_TEST922      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE922
         LTORG 
RT1_CCE922      DS 0H
*MEXIT #=  1823 LV= 2 RT1
*MEXIT #=  1822 LV= 1 ZOSOP
*MCALL #=  1824 LV= 1  ZOSOP 'E3CF','COMPARE LOGICAL HIGH (32)','CLHF',X
               'RXY-a'  RPI-1125 Z196
         JAS   R11,VER893
         USING *,R11
INS893   CLHF R1,S2(X4)
HEX893   DC    X'E314D00200CF'
NUM893   DC    P'893'
*MCALL #=  1825 LV= 2 VER893   RT1   CCE,INS893,HEX893
VER893   DS    0H
         CLC   INS893,HEX893
RT1_TEST923      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE923
         LTORG 
RT1_CCE923      DS 0H
*MEXIT #=  1825 LV= 2 RT1
*MEXIT #=  1824 LV= 1 ZOSOP
*MCALL #=  1826 LV= 1  ZOSOP 'E500','LOAD ADDRESS SPACE PARAMETERS ','LX
               ASP ','SSE C '
         JAS   R11,VER894
         USING *,R11
INS894   LASP  S1,S2
HEX894   DC    X'E500D001D002'
NUM894   DC    P'894'
*MCALL #=  1827 LV= 2 VER894   RT1   CCE,INS894,HEX894
VER894   DS    0H
         CLC   INS894,HEX894
RT1_TEST924      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE924
         LTORG 
RT1_CCE924      DS 0H
*MEXIT #=  1827 LV= 2 RT1
*MEXIT #=  1826 LV= 1 ZOSOP
*MCALL #=  1828 LV= 1  ZOSOP 'E501','TEST PROTECTION ','TPROT','SSE C '
         JAS   R11,VER895
         USING *,R11
INS895   TPROT S1,S2
HEX895   DC    X'E501D001D002'
NUM895   DC    P'895'
*MCALL #=  1829 LV= 2 VER895   RT1   CCE,INS895,HEX895
VER895   DS    0H
         CLC   INS895,HEX895
RT1_TEST925      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE925
         LTORG 
RT1_CCE925      DS 0H
*MEXIT #=  1829 LV= 2 RT1
*MEXIT #=  1828 LV= 1 ZOSOP
*MCALL #=  1830 LV= 1  ZOSOP 'E502','STORE REAL ADDRESS ','STRAG','SSE X
               N '
         JAS   R11,VER896
         USING *,R11
INS896   STRAG S1,S2
HEX896   DC    X'E502D001D002'
NUM896   DC    P'896'
*MCALL #=  1831 LV= 2 VER896   RT1   CCE,INS896,HEX896
VER896   DS    0H
         CLC   INS896,HEX896
RT1_TEST926      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE926
         LTORG 
RT1_CCE926      DS 0H
*MEXIT #=  1831 LV= 2 RT1
*MEXIT #=  1830 LV= 1 ZOSOP
*MCALL #=  1832 LV= 1  ZOSOP 'E50E','MOVE WITH SOURCE KEY ','MVCSK','SSX
               E '
         JAS   R11,VER897
         USING *,R11
INS897   MVCSK S1,S2
HEX897   DC    X'E50ED001D002'
NUM897   DC    P'897'
*MCALL #=  1833 LV= 2 VER897   RT1   CCE,INS897,HEX897
VER897   DS    0H
         CLC   INS897,HEX897
RT1_TEST927      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE927
         LTORG 
RT1_CCE927      DS 0H
*MEXIT #=  1833 LV= 2 RT1
*MEXIT #=  1832 LV= 1 ZOSOP
*MCALL #=  1834 LV= 1  ZOSOP 'E50F','MOVE WITH DESTINATION KEY ','MVCDKX
               ','SSE '
         JAS   R11,VER898
         USING *,R11
INS898   MVCDK S1,S2
HEX898   DC    X'E50FD001D002'
NUM898   DC    P'898'
*MCALL #=  1835 LV= 2 VER898   RT1   CCE,INS898,HEX898
VER898   DS    0H
         CLC   INS898,HEX898
RT1_TEST928      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE928
         LTORG 
RT1_CCE928      DS 0H
*MEXIT #=  1835 LV= 2 RT1
*MEXIT #=  1834 LV= 1 ZOSOP
*MCALL #=  1836 LV= 1  ZOSOP 'E544','Move Immediate','MVHHI','SIL',51  X
               RPI-817
         JAS   R11,VER899
         USING *,R11
INS899   MVHHI S1,II
HEX899   DC    X'E544D00100FF'
NUM899   DC    P'899'
*MCALL #=  1837 LV= 2 VER899   RT1   CCE,INS899,HEX899
VER899   DS    0H
         CLC   INS899,HEX899
RT1_TEST929      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE929
         LTORG 
RT1_CCE929      DS 0H
*MEXIT #=  1837 LV= 2 RT1
*MEXIT #=  1836 LV= 1 ZOSOP
*MCALL #=  1838 LV= 1  ZOSOP 'E548','Move Immediate','MVGHI','SIL',51  X
               RPI-817
         JAS   R11,VER900
         USING *,R11
INS900   MVGHI S1,II
HEX900   DC    X'E548D00100FF'
NUM900   DC    P'900'
*MCALL #=  1839 LV= 2 VER900   RT1   CCE,INS900,HEX900
VER900   DS    0H
         CLC   INS900,HEX900
RT1_TEST930      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE930
         LTORG 
RT1_CCE930      DS 0H
*MEXIT #=  1839 LV= 2 RT1
*MEXIT #=  1838 LV= 1 ZOSOP
*MCALL #=  1840 LV= 1  ZOSOP 'E54C','Move Immediate','MVHI','SIL',51  RX
               PI-817
         JAS   R11,VER901
         USING *,R11
INS901   MVHI S1,II
HEX901   DC    X'E54CD00100FF'
NUM901   DC    P'901'
*MCALL #=  1841 LV= 2 VER901   RT1   CCE,INS901,HEX901
VER901   DS    0H
         CLC   INS901,HEX901
RT1_TEST931      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE931
         LTORG 
RT1_CCE931      DS 0H
*MEXIT #=  1841 LV= 2 RT1
*MEXIT #=  1840 LV= 1 ZOSOP
*MCALL #=  1842 LV= 1  ZOSOP 'E554','Compare Halfword Imm','CHHSI','SILX
               ',51  RPI-817
         JAS   R11,VER902
         USING *,R11
INS902   CHHSI S1,II
HEX902   DC    X'E554D00100FF'
NUM902   DC    P'902'
*MCALL #=  1843 LV= 2 VER902   RT1   CCE,INS902,HEX902
VER902   DS    0H
         CLC   INS902,HEX902
RT1_TEST932      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE932
         LTORG 
RT1_CCE932      DS 0H
*MEXIT #=  1843 LV= 2 RT1
*MEXIT #=  1842 LV= 1 ZOSOP
*MCALL #=  1844 LV= 1  ZOSOP 'E555','Compare Logical Halfword Imm','CLHX
               HSI','SIL',51  RPI-817
         JAS   R11,VER903
         USING *,R11
INS903   CLHHSI S1,II
HEX903   DC    X'E555D00100FF'
NUM903   DC    P'903'
*MCALL #=  1845 LV= 2 VER903   RT1   CCE,INS903,HEX903
VER903   DS    0H
         CLC   INS903,HEX903
RT1_TEST933      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE933
         LTORG 
RT1_CCE933      DS 0H
*MEXIT #=  1845 LV= 2 RT1
*MEXIT #=  1844 LV= 1 ZOSOP
*MCALL #=  1846 LV= 1  ZOSOP 'E558','Compare Halfword Immediate','CGHSIX
               ','SIL',51  RPI-817
         JAS   R11,VER904
         USING *,R11
INS904   CGHSI S1,II
HEX904   DC    X'E558D00100FF'
NUM904   DC    P'904'
*MCALL #=  1847 LV= 2 VER904   RT1   CCE,INS904,HEX904
VER904   DS    0H
         CLC   INS904,HEX904
RT1_TEST934      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE934
         LTORG 
RT1_CCE934      DS 0H
*MEXIT #=  1847 LV= 2 RT1
*MEXIT #=  1846 LV= 1 ZOSOP
*MCALL #=  1848 LV= 1  ZOSOP 'E559','Compare Logical Halfword Imm','CLGX
               HSI','SIL',51  RPI-817
         JAS   R11,VER905
         USING *,R11
INS905   CLGHSI S1,II
HEX905   DC    X'E559D00100FF'
NUM905   DC    P'905'
*MCALL #=  1849 LV= 2 VER905   RT1   CCE,INS905,HEX905
VER905   DS    0H
         CLC   INS905,HEX905
RT1_TEST935      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE935
         LTORG 
RT1_CCE935      DS 0H
*MEXIT #=  1849 LV= 2 RT1
*MEXIT #=  1848 LV= 1 ZOSOP
*MCALL #=  1850 LV= 1  ZOSOP 'E55C','Compare Halfword Immediate','CHSI'X
               ,'SIL',51  RPI-817
         JAS   R11,VER906
         USING *,R11
INS906   CHSI S1,II
HEX906   DC    X'E55CD00100FF'
NUM906   DC    P'906'
*MCALL #=  1851 LV= 2 VER906   RT1   CCE,INS906,HEX906
VER906   DS    0H
         CLC   INS906,HEX906
RT1_TEST936      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE936
         LTORG 
RT1_CCE936      DS 0H
*MEXIT #=  1851 LV= 2 RT1
*MEXIT #=  1850 LV= 1 ZOSOP
*MCALL #=  1852 LV= 1  ZOSOP 'E55D','Compare Logical Halfword Imm','CLFX
               HSI','SIL',51  RPI-817
         JAS   R11,VER907
         USING *,R11
INS907   CLFHSI S1,II
HEX907   DC    X'E55DD00100FF'
NUM907   DC    P'907'
*MCALL #=  1853 LV= 2 VER907   RT1   CCE,INS907,HEX907
VER907   DS    0H
         CLC   INS907,HEX907
RT1_TEST937      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE937
         LTORG 
RT1_CCE937      DS 0H
*MEXIT #=  1853 LV= 2 RT1
*MEXIT #=  1852 LV= 1 ZOSOP
*MCALL #=  1854 LV= 1  ZOSOP 'E8 ','MOVE INVERSE ','MVCIN','SS '
         JAS   R11,VER908
         USING *,R11
INS908   MVCIN S1(LL),S2
HEX908   DC    X'E8FFD001D002'
NUM908   DC    P'908'
*MCALL #=  1855 LV= 2 VER908   RT1   CCE,INS908,HEX908
VER908   DS    0H
         CLC   INS908,HEX908
RT1_TEST938      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE938
         LTORG 
RT1_CCE938      DS 0H
*MEXIT #=  1855 LV= 2 RT1
*MEXIT #=  1854 LV= 1 ZOSOP
*MCALL #=  1856 LV= 1  ZOSOP 'E9 ','PACK ASCII ','PKA ','SS6 E2'
         JAS   R11,VER909
         USING *,R11
INS909   PKA  S1,S2(32)
HEX909   DC    X'E91FD001D002'
NUM909   DC    P'909'
*MCALL #=  1857 LV= 2 VER909   RT1   CCE,INS909,HEX909
VER909   DS    0H
         CLC   INS909,HEX909
RT1_TEST939      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE939
         LTORG 
RT1_CCE939      DS 0H
*MEXIT #=  1857 LV= 2 RT1
*MEXIT #=  1856 LV= 1 ZOSOP
*MCALL #=  1858 LV= 1  ZOSOP 'EA ','UNPACK ASCII ','UNPKA','SS C E2'
         JAS   R11,VER910
         USING *,R11
INS910   UNPKA S1(LL),S2
HEX910   DC    X'EAFFD001D002'
NUM910   DC    P'910'
*MCALL #=  1859 LV= 2 VER910   RT1   CCE,INS910,HEX910
VER910   DS    0H
         CLC   INS910,HEX910
RT1_TEST940      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE940
         LTORG 
RT1_CCE940      DS 0H
*MEXIT #=  1859 LV= 2 RT1
*MEXIT #=  1858 LV= 1 ZOSOP
*MCALL #=  1860 LV= 1  ZOSOP 'EB04','LOAD MULTIPLE (64) ','LMG ','RSY NX
                '
         JAS   R11,VER911
         USING *,R11
INS911   LMG  R1,R3,S2
HEX911   DC    X'EB13D0020004'
NUM911   DC    P'911'
*MCALL #=  1861 LV= 2 VER911   RT1   CCE,INS911,HEX911
VER911   DS    0H
         CLC   INS911,HEX911
RT1_TEST941      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE941
         LTORG 
RT1_CCE941      DS 0H
*MEXIT #=  1861 LV= 2 RT1
*MEXIT #=  1860 LV= 1 ZOSOP
*MCALL #=  1862 LV= 1  ZOSOP 'EB0A','SHIFT RIGHT SINGLE (64) ','SRAG ',X
               'RSY C N '
         JAS   R11,VER912
         USING *,R11
INS912   SRAG  R1,R3,S2
HEX912   DC    X'EB13D002000A'
NUM912   DC    P'912'
*MCALL #=  1863 LV= 2 VER912   RT1   CCE,INS912,HEX912
VER912   DS    0H
         CLC   INS912,HEX912
RT1_TEST942      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE942
         LTORG 
RT1_CCE942      DS 0H
*MEXIT #=  1863 LV= 2 RT1
*MEXIT #=  1862 LV= 1 ZOSOP
*MCALL #=  1864 LV= 1  ZOSOP 'EB0B','SHIFT LEFT SINGLE (64) ','SLAG ','X
               RSY C N '
         JAS   R11,VER913
         USING *,R11
INS913   SLAG  R1,R3,S2
HEX913   DC    X'EB13D002000B'
NUM913   DC    P'913'
*MCALL #=  1865 LV= 2 VER913   RT1   CCE,INS913,HEX913
VER913   DS    0H
         CLC   INS913,HEX913
RT1_TEST943      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE943
         LTORG 
RT1_CCE943      DS 0H
*MEXIT #=  1865 LV= 2 RT1
*MEXIT #=  1864 LV= 1 ZOSOP
*MCALL #=  1866 LV= 1  ZOSOP 'EB0C','SHIFT RIGHT SINGLE LOGICAL (64) ',X
               'SRLG ','RSY N '
         JAS   R11,VER914
         USING *,R11
INS914   SRLG  R1,R3,S2
HEX914   DC    X'EB13D002000C'
NUM914   DC    P'914'
*MCALL #=  1867 LV= 2 VER914   RT1   CCE,INS914,HEX914
VER914   DS    0H
         CLC   INS914,HEX914
RT1_TEST944      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE944
         LTORG 
RT1_CCE944      DS 0H
*MEXIT #=  1867 LV= 2 RT1
*MEXIT #=  1866 LV= 1 ZOSOP
*MCALL #=  1868 LV= 1  ZOSOP 'EB0D','SHIFT LEFT SINGLE LOGICAL (64) ','X
               SLLG ','RSY N '
         JAS   R11,VER915
         USING *,R11
INS915   SLLG  R1,R3,S2
HEX915   DC    X'EB13D002000D'
NUM915   DC    P'915'
*MCALL #=  1869 LV= 2 VER915   RT1   CCE,INS915,HEX915
VER915   DS    0H
         CLC   INS915,HEX915
RT1_TEST945      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE945
         LTORG 
RT1_CCE945      DS 0H
*MEXIT #=  1869 LV= 2 RT1
*MEXIT #=  1868 LV= 1 ZOSOP
*MCALL #=  1870 LV= 1  ZOSOP 'EB0F','TRACE (64) ','TRACG','RSY N '
         JAS   R11,VER916
         USING *,R11
INS916   TRACG R1,R3,S2
HEX916   DC    X'EB13D002000F'
NUM916   DC    P'916'
*MCALL #=  1871 LV= 2 VER916   RT1   CCE,INS916,HEX916
VER916   DS    0H
         CLC   INS916,HEX916
RT1_TEST946      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE946
         LTORG 
RT1_CCE946      DS 0H
*MEXIT #=  1871 LV= 2 RT1
*MEXIT #=  1870 LV= 1 ZOSOP
*MCALL #=  1872 LV= 1  ZOSOP 'EB14','COMPARE AND SWAP (32) ','CSY ','RSX
               Y C LD'
         JAS   R11,VER917
         USING *,R11
INS917   CSY  R1,R3,S2
HEX917   DC    X'EB13D0020014'
NUM917   DC    P'917'
*MCALL #=  1873 LV= 2 VER917   RT1   CCE,INS917,HEX917
VER917   DS    0H
         CLC   INS917,HEX917
RT1_TEST947      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE947
         LTORG 
RT1_CCE947      DS 0H
*MEXIT #=  1873 LV= 2 RT1
*MEXIT #=  1872 LV= 1 ZOSOP
*MCALL #=  1874 LV= 1  ZOSOP 'EB1C','ROTATE LEFT SINGLE LOGICAL (64) ',X
               'RLLG ','RSY N '
         JAS   R11,VER918
         USING *,R11
INS918   RLLG  R1,R3,S2
HEX918   DC    X'EB13D002001C'
NUM918   DC    P'918'
*MCALL #=  1875 LV= 2 VER918   RT1   CCE,INS918,HEX918
VER918   DS    0H
         CLC   INS918,HEX918
RT1_TEST948      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE948
         LTORG 
RT1_CCE948      DS 0H
*MEXIT #=  1875 LV= 2 RT1
*MEXIT #=  1874 LV= 1 ZOSOP
*MCALL #=  1876 LV= 1  ZOSOP 'EB1D','ROTATE LEFT SINGLE LOGICAL (32) ',X
               'RLL ','RSY N3'
         JAS   R11,VER919
         USING *,R11
INS919   RLL  R1,R3,S2
HEX919   DC    X'EB13D002001D'
NUM919   DC    P'919'
*MCALL #=  1877 LV= 2 VER919   RT1   CCE,INS919,HEX919
VER919   DS    0H
         CLC   INS919,HEX919
RT1_TEST949      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE949
         LTORG 
RT1_CCE949      DS 0H
*MEXIT #=  1877 LV= 2 RT1
*MEXIT #=  1876 LV= 1 ZOSOP
*MCALL #=  1878 LV= 1  ZOSOP 'EB20','COMPARE LOGICAL C. UNDER MASK (higX
               h)','CLMH ','RSY C N '
         JAS   R11,VER920
         USING *,R11
INS920   CLMH  R1,R3,S2
HEX920   DC    X'EB13D0020020'
NUM920   DC    P'920'
*MCALL #=  1879 LV= 2 VER920   RT1   CCE,INS920,HEX920
VER920   DS    0H
         CLC   INS920,HEX920
RT1_TEST950      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE950
         LTORG 
RT1_CCE950      DS 0H
*MEXIT #=  1879 LV= 2 RT1
*MEXIT #=  1878 LV= 1 ZOSOP
*MCALL #=  1880 LV= 1  ZOSOP 'EB21','COMPARE LOGICAL C. UNDER MASK (lowX
               ) ','CLMY ','RSY C LD'
         JAS   R11,VER921
         USING *,R11
INS921   CLMY  R1,R3,S2
HEX921   DC    X'EB13D0020021'
NUM921   DC    P'921'
*MCALL #=  1881 LV= 2 VER921   RT1   CCE,INS921,HEX921
VER921   DS    0H
         CLC   INS921,HEX921
RT1_TEST951      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE951
         LTORG 
RT1_CCE951      DS 0H
*MEXIT #=  1881 LV= 2 RT1
*MEXIT #=  1880 LV= 1 ZOSOP
*MCALL #=  1882 LV= 1  ZOSOP 'EB24','STORE MULTIPLE (64) ','STMG ','RSYX
                N '
         JAS   R11,VER922
         USING *,R11
INS922   STMG  R1,R3,S2
HEX922   DC    X'EB13D0020024'
NUM922   DC    P'922'
*MCALL #=  1883 LV= 2 VER922   RT1   CCE,INS922,HEX922
VER922   DS    0H
         CLC   INS922,HEX922
RT1_TEST952      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE952
         LTORG 
RT1_CCE952      DS 0H
*MEXIT #=  1883 LV= 2 RT1
*MEXIT #=  1882 LV= 1 ZOSOP
*MCALL #=  1884 LV= 1  ZOSOP 'EB25','STORE CONTROL (64) ','STCTG','RSY X
               N '
         JAS   R11,VER923
         USING *,R11
INS923   STCTG R1,R3,S2
HEX923   DC    X'EB13D0020025'
NUM923   DC    P'923'
*MCALL #=  1885 LV= 2 VER923   RT1   CCE,INS923,HEX923
VER923   DS    0H
         CLC   INS923,HEX923
RT1_TEST953      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE953
         LTORG 
RT1_CCE953      DS 0H
*MEXIT #=  1885 LV= 2 RT1
*MEXIT #=  1884 LV= 1 ZOSOP
*MCALL #=  1886 LV= 1  ZOSOP 'EB26','STORE MULTIPLE HIGH ','STMH ','RSYX
                N '
         JAS   R11,VER924
         USING *,R11
INS924   STMH  R1,R3,S2
HEX924   DC    X'EB13D0020026'
NUM924   DC    P'924'
*MCALL #=  1887 LV= 2 VER924   RT1   CCE,INS924,HEX924
VER924   DS    0H
         CLC   INS924,HEX924
RT1_TEST954      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE954
         LTORG 
RT1_CCE954      DS 0H
*MEXIT #=  1887 LV= 2 RT1
*MEXIT #=  1886 LV= 1 ZOSOP
*MCALL #=  1888 LV= 1  ZOSOP 'EB2C','STORE CHARACTERS UNDER MASK (high)X
                ','STCMH','RSY N '
         JAS   R11,VER925
         USING *,R11
INS925   STCMH R1,R3,S2
HEX925   DC    X'EB13D002002C'
NUM925   DC    P'925'
*MCALL #=  1889 LV= 2 VER925   RT1   CCE,INS925,HEX925
VER925   DS    0H
         CLC   INS925,HEX925
RT1_TEST955      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE955
         LTORG 
RT1_CCE955      DS 0H
*MEXIT #=  1889 LV= 2 RT1
*MEXIT #=  1888 LV= 1 ZOSOP
*MCALL #=  1890 LV= 1  ZOSOP 'EB2D','STORE CHARACTERS UNDER MASK (low) X
               ','STCMY','RSY LD'
         JAS   R11,VER926
         USING *,R11
INS926   STCMY R1,R3,S2
HEX926   DC    X'EB13D002002D'
NUM926   DC    P'926'
*MCALL #=  1891 LV= 2 VER926   RT1   CCE,INS926,HEX926
VER926   DS    0H
         CLC   INS926,HEX926
RT1_TEST956      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE956
         LTORG 
RT1_CCE956      DS 0H
*MEXIT #=  1891 LV= 2 RT1
*MEXIT #=  1890 LV= 1 ZOSOP
*MCALL #=  1892 LV= 1  ZOSOP 'EB2F','LOAD CONTROL (64) ','LCTLG','RSY NX
                '
         JAS   R11,VER927
         USING *,R11
INS927   LCTLG R1,R3,S2
HEX927   DC    X'EB13D002002F'
NUM927   DC    P'927'
*MCALL #=  1893 LV= 2 VER927   RT1   CCE,INS927,HEX927
VER927   DS    0H
         CLC   INS927,HEX927
RT1_TEST957      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE957
         LTORG 
RT1_CCE957      DS 0H
*MEXIT #=  1893 LV= 2 RT1
*MEXIT #=  1892 LV= 1 ZOSOP
*MCALL #=  1894 LV= 1  ZOSOP 'EB30','COMPARE AND SWAP (64) ','CSG ','RSX
               Y C N '
         JAS   R11,VER928
         USING *,R11
INS928   CSG  R1,R3,S2
HEX928   DC    X'EB13D0020030'
NUM928   DC    P'928'
*MCALL #=  1895 LV= 2 VER928   RT1   CCE,INS928,HEX928
VER928   DS    0H
         CLC   INS928,HEX928
RT1_TEST958      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE958
         LTORG 
RT1_CCE958      DS 0H
*MEXIT #=  1895 LV= 2 RT1
*MEXIT #=  1894 LV= 1 ZOSOP
*MCALL #=  1896 LV= 1  ZOSOP 'EB31','COMPARE DOUBLE AND SWAP (32) ','CDX
               SY ','RSY C LD'
         JAS   R11,VER929
         USING *,R11
INS929   CDSY  R1,R3,S2
HEX929   DC    X'EB13D0020031'
NUM929   DC    P'929'
*MCALL #=  1897 LV= 2 VER929   RT1   CCE,INS929,HEX929
VER929   DS    0H
         CLC   INS929,HEX929
RT1_TEST959      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE959
         LTORG 
RT1_CCE959      DS 0H
*MEXIT #=  1897 LV= 2 RT1
*MEXIT #=  1896 LV= 1 ZOSOP
*MCALL #=  1898 LV= 1  ZOSOP 'EB3E','COMPARE DOUBLE AND SWAP (64) ','CDX
               SG ','RSY C N '
         JAS   R11,VER930
         USING *,R11
INS930   CDSG  R1,R3,S2
HEX930   DC    X'EB13D002003E'
NUM930   DC    P'930'
*MCALL #=  1899 LV= 2 VER930   RT1   CCE,INS930,HEX930
VER930   DS    0H
         CLC   INS930,HEX930
RT1_TEST960      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE960
         LTORG 
RT1_CCE960      DS 0H
*MEXIT #=  1899 LV= 2 RT1
*MEXIT #=  1898 LV= 1 ZOSOP
*MCALL #=  1900 LV= 1  ZOSOP 'EB44','BRANCH ON INDEX HIGH (64) ','BXHG X
               ','RSY N '
         JAS   R11,VER931
         USING *,R11
INS931   BXHG  R1,R3,S2
HEX931   DC    X'EB13D0020044'
NUM931   DC    P'931'
*MCALL #=  1901 LV= 2 VER931   RT1   CCE,INS931,HEX931
VER931   DS    0H
         CLC   INS931,HEX931
RT1_TEST961      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE961
         LTORG 
RT1_CCE961      DS 0H
*MEXIT #=  1901 LV= 2 RT1
*MEXIT #=  1900 LV= 1 ZOSOP
*MCALL #=  1902 LV= 1  ZOSOP 'EB45','BRANCH ON INDEX LOW OR EQUAL (64) X
               ','BXLEG','RSY N '
         JAS   R11,VER932
         USING *,R11
INS932   BXLEG R1,R3,S2
HEX932   DC    X'EB13D0020045'
NUM932   DC    P'932'
*MCALL #=  1903 LV= 2 VER932   RT1   CCE,INS932,HEX932
VER932   DS    0H
         CLC   INS932,HEX932
RT1_TEST962      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE962
         LTORG 
RT1_CCE962      DS 0H
*MEXIT #=  1903 LV= 2 RT1
*MEXIT #=  1902 LV= 1 ZOSOP
*MCALL #=  1904 LV= 1  ZOSOP 'EB4C','Extract Cache Attribute','ECAG','RX
               SY',20  RPI-817
         JAS   R11,VER933
         USING *,R11
INS933   ECAG R1,R3,S2
HEX933   DC    X'EB13D002004C'
NUM933   DC    P'933'
*MCALL #=  1905 LV= 2 VER933   RT1   CCE,INS933,HEX933
VER933   DS    0H
         CLC   INS933,HEX933
RT1_TEST963      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE963
         LTORG 
RT1_CCE963      DS 0H
*MEXIT #=  1905 LV= 2 RT1
*MEXIT #=  1904 LV= 1 ZOSOP
*MCALL #=  1906 LV= 1  ZOSOP 'EB51','TEST UNDER MASK ','TMY ','SIY C LDX
               '
         JAS   R11,VER934
         USING *,R11
INS934   TMY  S1,II
HEX934   DC    X'EBFFD0010051'
NUM934   DC    P'934'
*MCALL #=  1907 LV= 2 VER934   RT1   CCE,INS934,HEX934
VER934   DS    0H
         CLC   INS934,HEX934
RT1_TEST964      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE964
         LTORG 
RT1_CCE964      DS 0H
*MEXIT #=  1907 LV= 2 RT1
*MEXIT #=  1906 LV= 1 ZOSOP
*MCALL #=  1908 LV= 1  ZOSOP 'EB52','MOVE (immediate) ','MVIY ','SIY LDX
               '
         JAS   R11,VER935
         USING *,R11
INS935   MVIY  S1,II
HEX935   DC    X'EBFFD0010052'
NUM935   DC    P'935'
*MCALL #=  1909 LV= 2 VER935   RT1   CCE,INS935,HEX935
VER935   DS    0H
         CLC   INS935,HEX935
RT1_TEST965      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE965
         LTORG 
RT1_CCE965      DS 0H
*MEXIT #=  1909 LV= 2 RT1
*MEXIT #=  1908 LV= 1 ZOSOP
*MCALL #=  1910 LV= 1  ZOSOP 'EB54','AND (immediate) ','NIY ','SIY C LDX
               '
         JAS   R11,VER936
         USING *,R11
INS936   NIY  S1,II
HEX936   DC    X'EBFFD0010054'
NUM936   DC    P'936'
*MCALL #=  1911 LV= 2 VER936   RT1   CCE,INS936,HEX936
VER936   DS    0H
         CLC   INS936,HEX936
RT1_TEST966      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE966
         LTORG 
RT1_CCE966      DS 0H
*MEXIT #=  1911 LV= 2 RT1
*MEXIT #=  1910 LV= 1 ZOSOP
*MCALL #=  1912 LV= 1  ZOSOP 'EB55','COMPARE LOGICAL (immediate) ','CLIX
               Y ','SIY C LD'
         JAS   R11,VER937
         USING *,R11
INS937   CLIY  S1,II
HEX937   DC    X'EBFFD0010055'
NUM937   DC    P'937'
*MCALL #=  1913 LV= 2 VER937   RT1   CCE,INS937,HEX937
VER937   DS    0H
         CLC   INS937,HEX937
RT1_TEST967      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE967
         LTORG 
RT1_CCE967      DS 0H
*MEXIT #=  1913 LV= 2 RT1
*MEXIT #=  1912 LV= 1 ZOSOP
*MCALL #=  1914 LV= 1  ZOSOP 'EB56','OR (immediate) ','OIY ','SIY C LD'
         JAS   R11,VER938
         USING *,R11
INS938   OIY  S1,II
HEX938   DC    X'EBFFD0010056'
NUM938   DC    P'938'
*MCALL #=  1915 LV= 2 VER938   RT1   CCE,INS938,HEX938
VER938   DS    0H
         CLC   INS938,HEX938
RT1_TEST968      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE968
         LTORG 
RT1_CCE968      DS 0H
*MEXIT #=  1915 LV= 2 RT1
*MEXIT #=  1914 LV= 1 ZOSOP
*MCALL #=  1916 LV= 1  ZOSOP 'EB57','EXCLUSIVE OR (immediate) ','XIY ',X
               'SIY C LD'
         JAS   R11,VER939
         USING *,R11
INS939   XIY  S1,II
HEX939   DC    X'EBFFD0010057'
NUM939   DC    P'939'
*MCALL #=  1917 LV= 2 VER939   RT1   CCE,INS939,HEX939
VER939   DS    0H
         CLC   INS939,HEX939
RT1_TEST969      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE969
         LTORG 
RT1_CCE969      DS 0H
*MEXIT #=  1917 LV= 2 RT1
*MEXIT #=  1916 LV= 1 ZOSOP
*MCALL #=  1918 LV= 1  ZOSOP 'EB6A','Add Signed Immediate','ASI','SIY',X
               21  RPI-817
         JAS   R11,VER940
         USING *,R11
INS940   ASI  S1,II
HEX940   DC    X'EBFFD001006A'
NUM940   DC    P'940'
*MCALL #=  1919 LV= 2 VER940   RT1   CCE,INS940,HEX940
VER940   DS    0H
         CLC   INS940,HEX940
RT1_TEST970      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE970
         LTORG 
RT1_CCE970      DS 0H
*MEXIT #=  1919 LV= 2 RT1
*MEXIT #=  1918 LV= 1 ZOSOP
*MCALL #=  1920 LV= 1  ZOSOP 'EB6E','Add Logical Signed Immediate','ALSX
               I','SIY',21 RPI-817
         JAS   R11,VER941
         USING *,R11
INS941   ALSI S1,II
HEX941   DC    X'EBFFD001006E'
NUM941   DC    P'941'
*MCALL #=  1921 LV= 2 VER941   RT1   CCE,INS941,HEX941
VER941   DS    0H
         CLC   INS941,HEX941
RT1_TEST971      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE971
         LTORG 
RT1_CCE971      DS 0H
*MEXIT #=  1921 LV= 2 RT1
*MEXIT #=  1920 LV= 1 ZOSOP
*MCALL #=  1922 LV= 1  ZOSOP 'EB7A','Add Signed Immediate','AGSI','SIY'X
               ,21 RPI-817
         JAS   R11,VER942
         USING *,R11
INS942   AGSI S1,II
HEX942   DC    X'EBFFD001007A'
NUM942   DC    P'942'
*MCALL #=  1923 LV= 2 VER942   RT1   CCE,INS942,HEX942
VER942   DS    0H
         CLC   INS942,HEX942
RT1_TEST972      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE972
         LTORG 
RT1_CCE972      DS 0H
*MEXIT #=  1923 LV= 2 RT1
*MEXIT #=  1922 LV= 1 ZOSOP
*MCALL #=  1924 LV= 1  ZOSOP 'EB7E','Add Logical Signed Immediate','ALGX
               SI','SIY',21 RPI-817
         JAS   R11,VER943
         USING *,R11
INS943   ALGSI S1,II
HEX943   DC    X'EBFFD001007E'
NUM943   DC    P'943'
*MCALL #=  1925 LV= 2 VER943   RT1   CCE,INS943,HEX943
VER943   DS    0H
         CLC   INS943,HEX943
RT1_TEST973      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE973
         LTORG 
RT1_CCE973      DS 0H
*MEXIT #=  1925 LV= 2 RT1
*MEXIT #=  1924 LV= 1 ZOSOP
*MCALL #=  1926 LV= 1  ZOSOP 'EB80','INSERT CHARACTERS UNDER MASK (highX
               ) ','ICMH ','RSY C N '
         JAS   R11,VER944
         USING *,R11
INS944   ICMH  R1,R3,S2
HEX944   DC    X'EB13D0020080'
NUM944   DC    P'944'
*MCALL #=  1927 LV= 2 VER944   RT1   CCE,INS944,HEX944
VER944   DS    0H
         CLC   INS944,HEX944
RT1_TEST974      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE974
         LTORG 
RT1_CCE974      DS 0H
*MEXIT #=  1927 LV= 2 RT1
*MEXIT #=  1926 LV= 1 ZOSOP
*MCALL #=  1928 LV= 1  ZOSOP 'EB81','INSERT CHARACTERS UNDER MASK (low)X
                ','ICMY ','RSY C LD'
         JAS   R11,VER945
         USING *,R11
INS945   ICMY  R1,R3,S2
HEX945   DC    X'EB13D0020081'
NUM945   DC    P'945'
*MCALL #=  1929 LV= 2 VER945   RT1   CCE,INS945,HEX945
VER945   DS    0H
         CLC   INS945,HEX945
RT1_TEST975      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE975
         LTORG 
RT1_CCE975      DS 0H
*MEXIT #=  1929 LV= 2 RT1
*MEXIT #=  1928 LV= 1 ZOSOP
*MCALL #=  1930 LV= 1  ZOSOP 'EB8E','MOVE LONG UNICODE ','MVCLU','RSY CX
                E2'
         JAS   R11,VER946
         USING *,R11
INS946   MVCLU R1,R3,S2
HEX946   DC    X'EB13D002008E'
NUM946   DC    P'946'
*MCALL #=  1931 LV= 2 VER946   RT1   CCE,INS946,HEX946
VER946   DS    0H
         CLC   INS946,HEX946
RT1_TEST976      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE976
         LTORG 
RT1_CCE976      DS 0H
*MEXIT #=  1931 LV= 2 RT1
*MEXIT #=  1930 LV= 1 ZOSOP
*MCALL #=  1932 LV= 1  ZOSOP 'EB8F','COMPARE LOGICAL LONG UNICODE ','CLX
               CLU','RSY C E2'
         JAS   R11,VER947
         USING *,R11
INS947   CLCLU R1,R3,S2
HEX947   DC    X'EB13D002008F'
NUM947   DC    P'947'
*MCALL #=  1933 LV= 2 VER947   RT1   CCE,INS947,HEX947
VER947   DS    0H
         CLC   INS947,HEX947
RT1_TEST977      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE977
         LTORG 
RT1_CCE977      DS 0H
*MEXIT #=  1933 LV= 2 RT1
*MEXIT #=  1932 LV= 1 ZOSOP
*MCALL #=  1934 LV= 1  ZOSOP 'EB90','STORE MULTIPLE (32) ','STMY ','RSYX
                LD'
         JAS   R11,VER948
         USING *,R11
INS948   STMY  R1,R3,S2
HEX948   DC    X'EB13D0020090'
NUM948   DC    P'948'
*MCALL #=  1935 LV= 2 VER948   RT1   CCE,INS948,HEX948
VER948   DS    0H
         CLC   INS948,HEX948
RT1_TEST978      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE978
         LTORG 
RT1_CCE978      DS 0H
*MEXIT #=  1935 LV= 2 RT1
*MEXIT #=  1934 LV= 1 ZOSOP
*MCALL #=  1936 LV= 1  ZOSOP 'EB96','LOAD MULTIPLE HIGH ','LMH ','RSY NX
                '
         JAS   R11,VER949
         USING *,R11
INS949   LMH  R1,R3,S2
HEX949   DC    X'EB13D0020096'
NUM949   DC    P'949'
*MCALL #=  1937 LV= 2 VER949   RT1   CCE,INS949,HEX949
VER949   DS    0H
         CLC   INS949,HEX949
RT1_TEST979      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE979
         LTORG 
RT1_CCE979      DS 0H
*MEXIT #=  1937 LV= 2 RT1
*MEXIT #=  1936 LV= 1 ZOSOP
*MCALL #=  1938 LV= 1  ZOSOP 'EB98','LOAD MULTIPLE (32) ','LMY ','RSY LX
               D'
         JAS   R11,VER950
         USING *,R11
INS950   LMY  R1,R3,S2
HEX950   DC    X'EB13D0020098'
NUM950   DC    P'950'
*MCALL #=  1939 LV= 2 VER950   RT1   CCE,INS950,HEX950
VER950   DS    0H
         CLC   INS950,HEX950
RT1_TEST980      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE980
         LTORG 
RT1_CCE980      DS 0H
*MEXIT #=  1939 LV= 2 RT1
*MEXIT #=  1938 LV= 1 ZOSOP
*MCALL #=  1940 LV= 1  ZOSOP 'EB9A','LOAD ACCESS MULTIPLE ','LAMY ','RSX
               Y LD'
         JAS   R11,VER951
         USING *,R11
INS951   LAMY  R1,R3,S2
HEX951   DC    X'EB13D002009A'
NUM951   DC    P'951'
*MCALL #=  1941 LV= 2 VER951   RT1   CCE,INS951,HEX951
VER951   DS    0H
         CLC   INS951,HEX951
RT1_TEST981      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE981
         LTORG 
RT1_CCE981      DS 0H
*MEXIT #=  1941 LV= 2 RT1
*MEXIT #=  1940 LV= 1 ZOSOP
*MCALL #=  1942 LV= 1  ZOSOP 'EB9B','STORE ACCESS MULTIPLE ','STAMY','RX
               SY LD'
         JAS   R11,VER952
         USING *,R11
INS952   STAMY R1,R3,S2
HEX952   DC    X'EB13D002009B'
NUM952   DC    P'952'
*MCALL #=  1943 LV= 2 VER952   RT1   CCE,INS952,HEX952
VER952   DS    0H
         CLC   INS952,HEX952
RT1_TEST982      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE982
         LTORG 
RT1_CCE982      DS 0H
*MEXIT #=  1943 LV= 2 RT1
*MEXIT #=  1942 LV= 1 ZOSOP
*MCALL #=  1944 LV= 1  ZOSOP 'EBC0','TEST DECIMAL ','TP ','RSL C E2'
         JAS   R11,VER953
         USING *,R11
INS953   TP   S2(PL2)
HEX953   DC    X'EB70D00200C0'
NUM953   DC    P'953'
*MCALL #=  1945 LV= 2 VER953   RT1   CCE,INS953,HEX953
VER953   DS    0H
         CLC   INS953,HEX953
RT1_TEST983      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE983
         LTORG 
RT1_CCE983      DS 0H
*MEXIT #=  1945 LV= 2 RT1
*MEXIT #=  1944 LV= 1 ZOSOP
*MCALL #=  1946 LV= 1  ZOSOP 'EBDC','SHIFT RIGHT SINGLE (32)','SRAK','RX
               SY  '  RPI-1125 Z196
         JAS   R11,VER954
         USING *,R11
INS954   SRAK R1,R3,S2
HEX954   DC    X'EB13D00200DC'
NUM954   DC    P'954'
*MCALL #=  1947 LV= 2 VER954   RT1   CCE,INS954,HEX954
VER954   DS    0H
         CLC   INS954,HEX954
RT1_TEST984      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE984
         LTORG 
RT1_CCE984      DS 0H
*MEXIT #=  1947 LV= 2 RT1
*MEXIT #=  1946 LV= 1 ZOSOP
*MCALL #=  1948 LV= 1  ZOSOP 'EBDD','SHIFT LEFT SINGLE (32)','SLAK','RSX
               Y  '  RPI-1125 Z196
         JAS   R11,VER955
         USING *,R11
INS955   SLAK R1,R3,S2
HEX955   DC    X'EB13D00200DD'
NUM955   DC    P'955'
*MCALL #=  1949 LV= 2 VER955   RT1   CCE,INS955,HEX955
VER955   DS    0H
         CLC   INS955,HEX955
RT1_TEST985      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE985
         LTORG 
RT1_CCE985      DS 0H
*MEXIT #=  1949 LV= 2 RT1
*MEXIT #=  1948 LV= 1 ZOSOP
*MCALL #=  1950 LV= 1  ZOSOP 'EBDE','SHIFT RIGHT SINGLE LOGICAL (32)','X
               SRLK','RSY  '  RPI-1125 Z196
         JAS   R11,VER956
         USING *,R11
INS956   SRLK R1,R3,S2
HEX956   DC    X'EB13D00200DE'
NUM956   DC    P'956'
*MCALL #=  1951 LV= 2 VER956   RT1   CCE,INS956,HEX956
VER956   DS    0H
         CLC   INS956,HEX956
RT1_TEST986      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE986
         LTORG 
RT1_CCE986      DS 0H
*MEXIT #=  1951 LV= 2 RT1
*MEXIT #=  1950 LV= 1 ZOSOP
*MCALL #=  1952 LV= 1  ZOSOP 'EBDF','SHIFT LEFT SINGLE LOGICAL (32)','SX
               LLK','RSY  '  RPI-1125 Z196
         JAS   R11,VER957
         USING *,R11
INS957   SLLK R1,R3,S2
HEX957   DC    X'EB13D00200DF'
NUM957   DC    P'957'
*MCALL #=  1953 LV= 2 VER957   RT1   CCE,INS957,HEX957
VER957   DS    0H
         CLC   INS957,HEX957
RT1_TEST987      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE987
         LTORG 
RT1_CCE987      DS 0H
*MEXIT #=  1953 LV= 2 RT1
*MEXIT #=  1952 LV= 1 ZOSOP
*MCALL #=  1954 LV= 1  ZOSOP 'EBE2','LOAD ON CONDITION (64)','LOCG','RSX
               Y2 '  RPI-1125 Z196
         JAS   R11,VER958
         USING *,R11
INS958   LOCG R1,S2,M3
HEX958   DC    X'EB13D00200E2'
NUM958   DC    P'958'
*MCALL #=  1955 LV= 2 VER958   RT1   CCE,INS958,HEX958
VER958   DS    0H
         CLC   INS958,HEX958
RT1_TEST988      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE988
         LTORG 
RT1_CCE988      DS 0H
*MEXIT #=  1955 LV= 2 RT1
*MEXIT #=  1954 LV= 1 ZOSOP
*MCALL #=  1956 LV= 1  ZOSOP 'EBE3','STORE ON CONDITION (64)','STOCG','X
               RSY2 '  RPI-1125 Z196
         JAS   R11,VER959
         USING *,R11
INS959   STOCG R1,S2,M3
HEX959   DC    X'EB13D00200E3'
NUM959   DC    P'959'
*MCALL #=  1957 LV= 2 VER959   RT1   CCE,INS959,HEX959
VER959   DS    0H
         CLC   INS959,HEX959
RT1_TEST989      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE989
         LTORG 
RT1_CCE989      DS 0H
*MEXIT #=  1957 LV= 2 RT1
*MEXIT #=  1956 LV= 1 ZOSOP
*MCALL #=  1958 LV= 1  ZOSOP 'EBE4','LOAD AND AND (64)','LANG','RSY  ' X
                RPI-1125 Z196
         JAS   R11,VER960
         USING *,R11
INS960   LANG R1,R3,S2
HEX960   DC    X'EB13D00200E4'
NUM960   DC    P'960'
*MCALL #=  1959 LV= 2 VER960   RT1   CCE,INS960,HEX960
VER960   DS    0H
         CLC   INS960,HEX960
RT1_TEST990      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE990
         LTORG 
RT1_CCE990      DS 0H
*MEXIT #=  1959 LV= 2 RT1
*MEXIT #=  1958 LV= 1 ZOSOP
*MCALL #=  1960 LV= 1  ZOSOP 'EBE6','LOAD AND OR (64)','LAOG','RSY  '  X
               RPI-1125 Z196
         JAS   R11,VER961
         USING *,R11
INS961   LAOG R1,R3,S2
HEX961   DC    X'EB13D00200E6'
NUM961   DC    P'961'
*MCALL #=  1961 LV= 2 VER961   RT1   CCE,INS961,HEX961
VER961   DS    0H
         CLC   INS961,HEX961
RT1_TEST991      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE991
         LTORG 
RT1_CCE991      DS 0H
*MEXIT #=  1961 LV= 2 RT1
*MEXIT #=  1960 LV= 1 ZOSOP
*MCALL #=  1962 LV= 1  ZOSOP 'EBE7','LOAD AND EXCLUSIVE OR (64)','LAXG'X
               ,'RSY  '  RPI-1125 Z196
         JAS   R11,VER962
         USING *,R11
INS962   LAXG R1,R3,S2
HEX962   DC    X'EB13D00200E7'
NUM962   DC    P'962'
*MCALL #=  1963 LV= 2 VER962   RT1   CCE,INS962,HEX962
VER962   DS    0H
         CLC   INS962,HEX962
RT1_TEST992      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE992
         LTORG 
RT1_CCE992      DS 0H
*MEXIT #=  1963 LV= 2 RT1
*MEXIT #=  1962 LV= 1 ZOSOP
*MCALL #=  1964 LV= 1  ZOSOP 'EBE8','LOAD AND ADD (64)','LAAG','RSY  ' X
                RPI-1125 Z196
         JAS   R11,VER963
         USING *,R11
INS963   LAAG R1,R3,S2
HEX963   DC    X'EB13D00200E8'
NUM963   DC    P'963'
*MCALL #=  1965 LV= 2 VER963   RT1   CCE,INS963,HEX963
VER963   DS    0H
         CLC   INS963,HEX963
RT1_TEST993      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE993
         LTORG 
RT1_CCE993      DS 0H
*MEXIT #=  1965 LV= 2 RT1
*MEXIT #=  1964 LV= 1 ZOSOP
*MCALL #=  1966 LV= 1  ZOSOP 'EBEA','LOAD AND ADD LOGICAL (64)','LAALG'X
               ,'RSY  '  RPI-1125 Z196
         JAS   R11,VER964
         USING *,R11
INS964   LAALG R1,R3,S2
HEX964   DC    X'EB13D00200EA'
NUM964   DC    P'964'
*MCALL #=  1967 LV= 2 VER964   RT1   CCE,INS964,HEX964
VER964   DS    0H
         CLC   INS964,HEX964
RT1_TEST994      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE994
         LTORG 
RT1_CCE994      DS 0H
*MEXIT #=  1967 LV= 2 RT1
*MEXIT #=  1966 LV= 1 ZOSOP
*MCALL #=  1968 LV= 1  ZOSOP 'EBF2','LOAD ON CONDITION (32)','LOC','RSYX
               2 '  RPI-1125 Z196
         JAS   R11,VER965
         USING *,R11
INS965   LOC  R1,S2,M3
HEX965   DC    X'EB13D00200F2'
NUM965   DC    P'965'
*MCALL #=  1969 LV= 2 VER965   RT1   CCE,INS965,HEX965
VER965   DS    0H
         CLC   INS965,HEX965
RT1_TEST995      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE995
         LTORG 
RT1_CCE995      DS 0H
*MEXIT #=  1969 LV= 2 RT1
*MEXIT #=  1968 LV= 1 ZOSOP
*MCALL #=  1970 LV= 1  ZOSOP 'EBF3','STORE ON CONDITION (32)','STOC','RX
               SY2 '  RPI-1125 Z196
         JAS   R11,VER966
         USING *,R11
INS966   STOC R1,S2,M3
HEX966   DC    X'EB13D00200F3'
NUM966   DC    P'966'
*MCALL #=  1971 LV= 2 VER966   RT1   CCE,INS966,HEX966
VER966   DS    0H
         CLC   INS966,HEX966
RT1_TEST996      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE996
         LTORG 
RT1_CCE996      DS 0H
*MEXIT #=  1971 LV= 2 RT1
*MEXIT #=  1970 LV= 1 ZOSOP
*MCALL #=  1972 LV= 1  ZOSOP 'EBF4','LOAD AND AND (32)','LAN','RSY  '  X
               RPI-1125 Z196
         JAS   R11,VER967
         USING *,R11
INS967   LAN  R1,R3,S2
HEX967   DC    X'EB13D00200F4'
NUM967   DC    P'967'
*MCALL #=  1973 LV= 2 VER967   RT1   CCE,INS967,HEX967
VER967   DS    0H
         CLC   INS967,HEX967
RT1_TEST997      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE997
         LTORG 
RT1_CCE997      DS 0H
*MEXIT #=  1973 LV= 2 RT1
*MEXIT #=  1972 LV= 1 ZOSOP
*MCALL #=  1974 LV= 1  ZOSOP 'EBF6','LOAD AND OR (32)','LAO','RSY  '  RX
               PI-1125 Z196
         JAS   R11,VER968
         USING *,R11
INS968   LAO  R1,R3,S2
HEX968   DC    X'EB13D00200F6'
NUM968   DC    P'968'
*MCALL #=  1975 LV= 2 VER968   RT1   CCE,INS968,HEX968
VER968   DS    0H
         CLC   INS968,HEX968
RT1_TEST998      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE998
         LTORG 
RT1_CCE998      DS 0H
*MEXIT #=  1975 LV= 2 RT1
*MEXIT #=  1974 LV= 1 ZOSOP
*MCALL #=  1976 LV= 1  ZOSOP 'EBF7','LOAD AND EXCLUSIVE OR (32)','LAX',X
               'RSY  '  RPI-1125 Z196
         JAS   R11,VER969
         USING *,R11
INS969   LAX  R1,R3,S2
HEX969   DC    X'EB13D00200F7'
NUM969   DC    P'969'
*MCALL #=  1977 LV= 2 VER969   RT1   CCE,INS969,HEX969
VER969   DS    0H
         CLC   INS969,HEX969
RT1_TEST999      BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE999
         LTORG 
RT1_CCE999      DS 0H
*MEXIT #=  1977 LV= 2 RT1
*MEXIT #=  1976 LV= 1 ZOSOP
*MCALL #=  1978 LV= 1  ZOSOP 'EBF8','LOAD AND ADD (32)','LAA','RSY  '  X
               RPI-1125 Z196
         JAS   R11,VER970
         USING *,R11
INS970   LAA  R1,R3,S2
HEX970   DC    X'EB13D00200F8'
NUM970   DC    P'970'
*MCALL #=  1979 LV= 2 VER970   RT1   CCE,INS970,HEX970
VER970   DS    0H
         CLC   INS970,HEX970
RT1_TEST1000     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1000
         LTORG 
RT1_CCE1000     DS 0H
*MEXIT #=  1979 LV= 2 RT1
*MEXIT #=  1978 LV= 1 ZOSOP
*MCALL #=  1980 LV= 1  ZOSOP 'EBFA','LOAD AND ADD LOGICAL (32)','LAAL',X
               'RSY  '  RPI-1125 Z196
         JAS   R11,VER971
         USING *,R11
INS971   LAAL R1,R3,S2
HEX971   DC    X'EB13D00200FA'
NUM971   DC    P'971'
*MCALL #=  1981 LV= 2 VER971   RT1   CCE,INS971,HEX971
VER971   DS    0H
         CLC   INS971,HEX971
RT1_TEST1001     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1001
         LTORG 
RT1_CCE1001     DS 0H
*MEXIT #=  1981 LV= 2 RT1
*MEXIT #=  1980 LV= 1 ZOSOP
*MCALL #=  1982 LV= 1  ZOSOP 'EC44','BRANCH RELATIVE ON INDEX HIGH (64)X
                ','BRXHG','RIE N '
         JAS   R11,VER972
         USING *,R11
INS972   BRXHG R1,R3,*-2
HEX972   DC    X'EC13FFFF0044'
NUM972   DC    P'972'
*MCALL #=  1983 LV= 2 VER972   RT1   CCE,INS972,HEX972
VER972   DS    0H
         CLC   INS972,HEX972
RT1_TEST1002     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1002
         LTORG 
RT1_CCE1002     DS 0H
*MEXIT #=  1983 LV= 2 RT1
*MEXIT #=  1982 LV= 1 ZOSOP
*MCALL #=  1984 LV= 1  ZOSOP 'EC44','RELATIVE BRANCH','JXHG','RIE'
         JAS   R11,VER973
         USING *,R11
INS973   JXHG R1,R3,*-2
HEX973   DC    X'EC13FFFF0044'
NUM973   DC    P'973'
*MCALL #=  1985 LV= 2 VER973   RT1   CCE,INS973,HEX973
VER973   DS    0H
         CLC   INS973,HEX973
RT1_TEST1003     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1003
         LTORG 
RT1_CCE1003     DS 0H
*MEXIT #=  1985 LV= 2 RT1
*MEXIT #=  1984 LV= 1 ZOSOP
*MCALL #=  1986 LV= 1  ZOSOP 'EC45','BRANCH RELATIVE ON INDEX L OR E (6X
               4)','BRXLG','RIE N '
         JAS   R11,VER974
         USING *,R11
INS974   BRXLG R1,R3,*-2
HEX974   DC    X'EC13FFFF0045'
NUM974   DC    P'974'
*MCALL #=  1987 LV= 2 VER974   RT1   CCE,INS974,HEX974
VER974   DS    0H
         CLC   INS974,HEX974
RT1_TEST1004     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1004
         LTORG 
RT1_CCE1004     DS 0H
*MEXIT #=  1987 LV= 2 RT1
*MEXIT #=  1986 LV= 1 ZOSOP
*MCALL #=  1988 LV= 1  ZOSOP 'EC45','RELATIVE BRANCH','JXLEG','RIE'   RX
               PI-199
         JAS   R11,VER975
         USING *,R11
INS975   JXLEG R1,R3,*-2
HEX975   DC    X'EC13FFFF0045'
NUM975   DC    P'975'
*MCALL #=  1989 LV= 2 VER975   RT1   CCE,INS975,HEX975
VER975   DS    0H
         CLC   INS975,HEX975
RT1_TEST1005     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1005
         LTORG 
RT1_CCE1005     DS 0H
*MEXIT #=  1989 LV= 2 RT1
*MEXIT #=  1988 LV= 1 ZOSOP
*MCALL #=  1990 LV= 1  ZOSOP 'EC51','ROTATE THEN INSERT SELECTED BITS LX
               OW','RISBLG','RIE8 '  RPI-1125 Z196
         JAS   R11,VER976
         USING *,R11
INS976   RISBLG R1,R2,I3,I4,I5
HEX976   DC    X'EC1233445551'
NUM976   DC    P'976'
*MCALL #=  1991 LV= 2 VER976   RT1   CCE,INS976,HEX976
VER976   DS    0H
         CLC   INS976,HEX976
RT1_TEST1006     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1006
         LTORG 
RT1_CCE1006     DS 0H
*MEXIT #=  1991 LV= 2 RT1
*MEXIT #=  1990 LV= 1 ZOSOP
*MCALL #=  1992 LV= 1  ZOSOP 'EC51$003132','LOAD (lOW  && HIGH) RISBLGZX
               ','LLHFR','RIE8',52   RPI-1164
         JAS   R11,VER977
         USING *,R11
INS977   LLHFR R1,R2
HEX977   DC    X'EC12009F2051'
NUM977   DC    P'977'
*MCALL #=  1993 LV= 2 VER977   RT1   CCE,INS977,HEX977
VER977   DS    0H
         CLC   INS977,HEX977
RT1_TEST1007     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1007
         LTORG 
RT1_CCE1007     DS 0H
*MEXIT #=  1993 LV= 2 RT1
*MEXIT #=  1992 LV= 1 ZOSOP
*MCALL #=  1994 LV= 1  ZOSOP 'EC51$163132','LOAD LOG HW (lOW  && HIGH) X
               RISBLGZ','LLHLHR','RIE8',52  RPI-1164
         JAS   R11,VER978
         USING *,R11
INS978   LLHLHR R1,R2
HEX978   DC    X'EC12109F2051'
NUM978   DC    P'978'
*MCALL #=  1995 LV= 2 VER978   RT1   CCE,INS978,HEX978
VER978   DS    0H
         CLC   INS978,HEX978
RT1_TEST1008     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1008
         LTORG 
RT1_CCE1008     DS 0H
*MEXIT #=  1995 LV= 2 RT1
*MEXIT #=  1994 LV= 1 ZOSOP
*MCALL #=  1996 LV= 1  ZOSOP 'EC51$243132','LOAD LOG CH (lOW  && HIGH) X
               RISBLGZ','LLCLHR','RIE8',52  RPI-1164
         JAS   R11,VER979
         USING *,R11
INS979   LLCLHR R1,R2
HEX979   DC    X'EC12189F2051'
NUM979   DC    P'979'
*MCALL #=  1997 LV= 2 VER979   RT1   CCE,INS979,HEX979
VER979   DS    0H
         CLC   INS979,HEX979
RT1_TEST1009     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1009
         LTORG 
RT1_CCE1009     DS 0H
*MEXIT #=  1997 LV= 2 RT1
*MEXIT #=  1996 LV= 1 ZOSOP
*MCALL #=  1998 LV= 1  ZOSOP 'EC54','Rotate then And Bits','RNSBG','RIEX
               8',52  RPI-817
         JAS   R11,VER980
         USING *,R11
INS980   RNSBG R1,R2,I3,I4,I5
HEX980   DC    X'EC1233445554'
NUM980   DC    P'980'
*MCALL #=  1999 LV= 2 VER980   RT1   CCE,INS980,HEX980
VER980   DS    0H
         CLC   INS980,HEX980
RT1_TEST1010     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1010
         LTORG 
RT1_CCE1010     DS 0H
*MEXIT #=  1999 LV= 2 RT1
*MEXIT #=  1998 LV= 1 ZOSOP
*MCALL #=  2000 LV= 1  ZOSOP 'EC54$003100','AND HIGH (HIGH && HIGH) RNSX
               BG','NHHR','RIE8',52  RPI-1164
         JAS   R11,VER981
         USING *,R11
INS981   NHHR R1,R2
HEX981   DC    X'EC12001F0054'
NUM981   DC    P'981'
*MCALL #=  2001 LV= 2 VER981   RT1   CCE,INS981,HEX981
VER981   DS    0H
         CLC   INS981,HEX981
RT1_TEST1011     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1011
         LTORG 
RT1_CCE1011     DS 0H
*MEXIT #=  2001 LV= 2 RT1
*MEXIT #=  2000 LV= 1 ZOSOP
*MCALL #=  2002 LV= 1  ZOSOP 'EC54$003132','AND HIGH (HIGH && LOW ) RNSX
               BG','NHLR','RIE8',52  RPI-1164
         JAS   R11,VER982
         USING *,R11
INS982   NHLR R1,R2
HEX982   DC    X'EC12001F2054'
NUM982   DC    P'982'
*MCALL #=  2003 LV= 2 VER982   RT1   CCE,INS982,HEX982
VER982   DS    0H
         CLC   INS982,HEX982
RT1_TEST1012     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1012
         LTORG 
RT1_CCE1012     DS 0H
*MEXIT #=  2003 LV= 2 RT1
*MEXIT #=  2002 LV= 1 ZOSOP
*MCALL #=  2004 LV= 1  ZOSOP 'EC54$326332','AND HIGH (lOW  && HIGH) RNSX
               BG','NLHR','RIE8',52  RPI-1164
         JAS   R11,VER983
         USING *,R11
INS983   NLHR R1,R2
HEX983   DC    X'EC12203F2054'
NUM983   DC    P'983'
*MCALL #=  2005 LV= 2 VER983   RT1   CCE,INS983,HEX983
VER983   DS    0H
         CLC   INS983,HEX983
RT1_TEST1013     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1013
         LTORG 
RT1_CCE1013     DS 0H
*MEXIT #=  2005 LV= 2 RT1
*MEXIT #=  2004 LV= 1 ZOSOP
*MCALL #=  2006 LV= 1  ZOSOP 'EC54T','RNSBG and Test','RNSBGT','RIE8',5X
               2  RPI-817
         JAS   R11,VER984
         USING *,R11
INS984   RNSBGT R1,R2,I3,I4,I5
HEX984   DC    X'EC12B3445554'
NUM984   DC    P'984'
*MCALL #=  2007 LV= 2 VER984   RT1   CCE,INS984,HEX984
VER984   DS    0H
         CLC   INS984,HEX984
RT1_TEST1014     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1014
         LTORG 
RT1_CCE1014     DS 0H
*MEXIT #=  2007 LV= 2 RT1
*MEXIT #=  2006 LV= 1 ZOSOP
*MCALL #=  2008 LV= 1  ZOSOP 'EC55','Rotate then Insert Bits','RISBG','X
               RIE8',52  RPI-817
         JAS   R11,VER985
         USING *,R11
INS985   RISBG R1,R2,I3,I4,I5
HEX985   DC    X'EC1233445555'
NUM985   DC    P'985'
*MCALL #=  2009 LV= 2 VER985   RT1   CCE,INS985,HEX985
VER985   DS    0H
         CLC   INS985,HEX985
RT1_TEST1015     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1015
         LTORG 
RT1_CCE1015     DS 0H
*MEXIT #=  2009 LV= 2 RT1
*MEXIT #=  2008 LV= 1 ZOSOP
*MCALL #=  2010 LV= 1  ZOSOP 'EC55Z','RISBG and Zero','RISBGZ','RIE8',5X
               2  RPI-817
         JAS   R11,VER986
         USING *,R11
INS986   RISBGZ R1,R2,I3,I4,I5
HEX986   DC    X'EC1233C45555'
NUM986   DC    P'986'
*MCALL #=  2011 LV= 2 VER986   RT1   CCE,INS986,HEX986
VER986   DS    0H
         CLC   INS986,HEX986
RT1_TEST1016     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1016
         LTORG 
RT1_CCE1016     DS 0H
*MEXIT #=  2011 LV= 2 RT1
*MEXIT #=  2010 LV= 1 ZOSOP
*MCALL #=  2012 LV= 1  ZOSOP 'EC56','Rotate then Or Bits','ROSBG','RIE8X
               ',52  RPI-817
         JAS   R11,VER987
         USING *,R11
INS987   ROSBG R1,R2,I3,I4,I5
HEX987   DC    X'EC1233445556'
NUM987   DC    P'987'
*MCALL #=  2013 LV= 2 VER987   RT1   CCE,INS987,HEX987
VER987   DS    0H
         CLC   INS987,HEX987
RT1_TEST1017     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1017
         LTORG 
RT1_CCE1017     DS 0H
*MEXIT #=  2013 LV= 2 RT1
*MEXIT #=  2012 LV= 1 ZOSOP
*MCALL #=  2014 LV= 1  ZOSOP 'EC56$003100','OR  HIGH (HIGH && HIGH) ROSX
               BG','OHHR','RIE8',52  RPI-1164
         JAS   R11,VER988
         USING *,R11
INS988   OHHR R1,R2
HEX988   DC    X'EC12001F0056'
NUM988   DC    P'988'
*MCALL #=  2015 LV= 2 VER988   RT1   CCE,INS988,HEX988
VER988   DS    0H
         CLC   INS988,HEX988
RT1_TEST1018     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1018
         LTORG 
RT1_CCE1018     DS 0H
*MEXIT #=  2015 LV= 2 RT1
*MEXIT #=  2014 LV= 1 ZOSOP
*MCALL #=  2016 LV= 1  ZOSOP 'EC56$003132','OR  HIGH (HIGH && LOW ) ROSX
               BG','OHLR','RIE8',52  RPI-1164
         JAS   R11,VER989
         USING *,R11
INS989   OHLR R1,R2
HEX989   DC    X'EC12001F2056'
NUM989   DC    P'989'
*MCALL #=  2017 LV= 2 VER989   RT1   CCE,INS989,HEX989
VER989   DS    0H
         CLC   INS989,HEX989
RT1_TEST1019     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1019
         LTORG 
RT1_CCE1019     DS 0H
*MEXIT #=  2017 LV= 2 RT1
*MEXIT #=  2016 LV= 1 ZOSOP
*MCALL #=  2018 LV= 1  ZOSOP 'EC56$326332','OR  HIGH (lOW  && HIGH) ROSX
               BG','OLHR','RIE8',52  RPI-1164
         JAS   R11,VER990
         USING *,R11
INS990   OLHR R1,R2
HEX990   DC    X'EC12203F2056'
NUM990   DC    P'990'
*MCALL #=  2019 LV= 2 VER990   RT1   CCE,INS990,HEX990
VER990   DS    0H
         CLC   INS990,HEX990
RT1_TEST1020     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1020
         LTORG 
RT1_CCE1020     DS 0H
*MEXIT #=  2019 LV= 2 RT1
*MEXIT #=  2018 LV= 1 ZOSOP
*MCALL #=  2020 LV= 1  ZOSOP 'EC56T','ROSBG and Test','ROSBGT','RIE8',5X
               2  RPI-817
         JAS   R11,VER991
         USING *,R11
INS991   ROSBGT R1,R2,I3,I4,I5
HEX991   DC    X'EC12B3445556'
NUM991   DC    P'991'
*MCALL #=  2021 LV= 2 VER991   RT1   CCE,INS991,HEX991
VER991   DS    0H
         CLC   INS991,HEX991
RT1_TEST1021     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1021
         LTORG 
RT1_CCE1021     DS 0H
*MEXIT #=  2021 LV= 2 RT1
*MEXIT #=  2020 LV= 1 ZOSOP
*MCALL #=  2022 LV= 1  ZOSOP 'EC57','Rotate then Exclusive Or Bits','RXX
               SBG','RIE8',52 RPI-817
         JAS   R11,VER992
         USING *,R11
INS992   RXSBG R1,R2,I3,I4,I5
HEX992   DC    X'EC1233445557'
NUM992   DC    P'992'
*MCALL #=  2023 LV= 2 VER992   RT1   CCE,INS992,HEX992
VER992   DS    0H
         CLC   INS992,HEX992
RT1_TEST1022     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1022
         LTORG 
RT1_CCE1022     DS 0H
*MEXIT #=  2023 LV= 2 RT1
*MEXIT #=  2022 LV= 1 ZOSOP
*MCALL #=  2024 LV= 1  ZOSOP 'EC57$003100','XOR HIGH (HIGH && HIGH) RXSX
               BG','XHHR','RIE8',52  RPI-1164
         JAS   R11,VER993
         USING *,R11
INS993   XHHR R1,R2
HEX993   DC    X'EC12001F0057'
NUM993   DC    P'993'
*MCALL #=  2025 LV= 2 VER993   RT1   CCE,INS993,HEX993
VER993   DS    0H
         CLC   INS993,HEX993
RT1_TEST1023     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1023
         LTORG 
RT1_CCE1023     DS 0H
*MEXIT #=  2025 LV= 2 RT1
*MEXIT #=  2024 LV= 1 ZOSOP
*MCALL #=  2026 LV= 1  ZOSOP 'EC57$003132','XOR HIGH (HIGH && LOW ) RXSX
               BG','XHLR','RIE8',52  RPI-1164
         JAS   R11,VER994
         USING *,R11
INS994   XHLR R1,R2
HEX994   DC    X'EC12001F2057'
NUM994   DC    P'994'
*MCALL #=  2027 LV= 2 VER994   RT1   CCE,INS994,HEX994
VER994   DS    0H
         CLC   INS994,HEX994
RT1_TEST1024     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1024
         LTORG 
RT1_CCE1024     DS 0H
*MEXIT #=  2027 LV= 2 RT1
*MEXIT #=  2026 LV= 1 ZOSOP
*MCALL #=  2028 LV= 1  ZOSOP 'EC57$326332','AOR HIGH (lOW  && HIGH) RXSX
               BG','XLHR','RIE8',52  RPI-1164
         JAS   R11,VER995
         USING *,R11
INS995   XLHR R1,R2
HEX995   DC    X'EC12203F2057'
NUM995   DC    P'995'
*MCALL #=  2029 LV= 2 VER995   RT1   CCE,INS995,HEX995
VER995   DS    0H
         CLC   INS995,HEX995
RT1_TEST1025     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1025
         LTORG 
RT1_CCE1025     DS 0H
*MEXIT #=  2029 LV= 2 RT1
*MEXIT #=  2028 LV= 1 ZOSOP
*MCALL #=  2030 LV= 1  ZOSOP 'EC57T','RXSBG and Test','RXSBGT','RIE8',5X
               2  RPI-817
         JAS   R11,VER996
         USING *,R11
INS996   RXSBGT R1,R2,I3,I4,I5
HEX996   DC    X'EC12B3445557'
NUM996   DC    P'996'
*MCALL #=  2031 LV= 2 VER996   RT1   CCE,INS996,HEX996
VER996   DS    0H
         CLC   INS996,HEX996
RT1_TEST1026     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1026
         LTORG 
RT1_CCE1026     DS 0H
*MEXIT #=  2031 LV= 2 RT1
*MEXIT #=  2030 LV= 1 ZOSOP
*MCALL #=  2032 LV= 1  ZOSOP 'EC5D','ROTATE THEN INSERT SELECTED BITS HX
               IGH','RISBHG','RIE8',5 2  RPI-1125 Z196
         JAS   R11,VER997
         USING *,R11
INS997   RISBHG R1,R2,I3,I4,I5
HEX997   DC    X'EC123344555D'
NUM997   DC    P'997'
*MCALL #=  2033 LV= 2 VER997   RT1   CCE,INS997,HEX997
VER997   DS    0H
         CLC   INS997,HEX997
RT1_TEST1027     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1027
         LTORG 
RT1_CCE1027     DS 0H
*MEXIT #=  2033 LV= 2 RT1
*MEXIT #=  2032 LV= 1 ZOSOP
*MCALL #=  2034 LV= 1  ZOSOP 'EC5D$003100','LOAD (HIGH && HIGH) RISBHGZX
               ','LHHR','RIE8',52    RPI-1164
         JAS   R11,VER998
         USING *,R11
INS998   LHHR R1,R2
HEX998   DC    X'EC12009F005D'
NUM998   DC    P'998'
*MCALL #=  2035 LV= 2 VER998   RT1   CCE,INS998,HEX998
VER998   DS    0H
         CLC   INS998,HEX998
RT1_TEST1028     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1028
         LTORG 
RT1_CCE1028     DS 0H
*MEXIT #=  2035 LV= 2 RT1
*MEXIT #=  2034 LV= 1 ZOSOP
*MCALL #=  2036 LV= 1  ZOSOP 'EC5D$003132','LOAD (HIGH && LOW ) RISBHGZX
               ','LHLR','RIE8',52    RPI-1164
         JAS   R11,VER999
         USING *,R11
INS999   LHLR R1,R2
HEX999   DC    X'EC12009F205D'
NUM999   DC    P'999'
*MCALL #=  2037 LV= 2 VER999   RT1   CCE,INS999,HEX999
VER999   DS    0H
         CLC   INS999,HEX999
RT1_TEST1029     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1029
         LTORG 
RT1_CCE1029     DS 0H
*MEXIT #=  2037 LV= 2 RT1
*MEXIT #=  2036 LV= 1 ZOSOP
*MCALL #=  2038 LV= 1  ZOSOP 'EC5D$163100','LOAD LOG HW (HIGH && HIGH) X
               RISBHGZ','LLHHHR','RIE8',52  RPI-1164
         JAS   R11,VER1000
         USING *,R11
INS1000  LLHHHR R1,R2
HEX1000  DC    X'EC12109F005D'
NUM1000  DC    P'1000'
*MCALL #=  2039 LV= 2 VER1000  RT1   CCE,INS1000,HEX1000
VER1000  DS    0H
         CLC   INS1000,HEX1000
RT1_TEST1030     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1030
         LTORG 
RT1_CCE1030     DS 0H
*MEXIT #=  2039 LV= 2 RT1
*MEXIT #=  2038 LV= 1 ZOSOP
*MCALL #=  2040 LV= 1  ZOSOP 'EC5D$163132','LOAD LOG HW (HIGH && LOW ) X
               RISBHGZ','LLHHLR','RIE8',52  RPI-1164
         JAS   R11,VER1001
         USING *,R11
INS1001  LLHHLR R1,R2
HEX1001  DC    X'EC12109F205D'
NUM1001  DC    P'1001'
*MCALL #=  2041 LV= 2 VER1001  RT1   CCE,INS1001,HEX1001
VER1001  DS    0H
         CLC   INS1001,HEX1001
RT1_TEST1031     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1031
         LTORG 
RT1_CCE1031     DS 0H
*MEXIT #=  2041 LV= 2 RT1
*MEXIT #=  2040 LV= 1 ZOSOP
*MCALL #=  2042 LV= 1  ZOSOP 'EC5D$243100','LOAD LOG CH (HIGH && HIGH) X
               RISBHGZ','LLCHHR','RIE8',52  RPI-1164
         JAS   R11,VER1002
         USING *,R11
INS1002  LLCHHR R1,R2
HEX1002  DC    X'EC12189F005D'
NUM1002  DC    P'1002'
*MCALL #=  2043 LV= 2 VER1002  RT1   CCE,INS1002,HEX1002
VER1002  DS    0H
         CLC   INS1002,HEX1002
RT1_TEST1032     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1032
         LTORG 
RT1_CCE1032     DS 0H
*MEXIT #=  2043 LV= 2 RT1
*MEXIT #=  2042 LV= 1 ZOSOP
*MCALL #=  2044 LV= 1  ZOSOP 'EC5D$243132','LOAD LOG CH (HIGH && LOW ) X
               RISBHGZ','LLCHLR','RIE8',52  RPI-1164
         JAS   R11,VER1003
         USING *,R11
INS1003  LLCHLR R1,R2
HEX1003  DC    X'EC12189F205D'
NUM1003  DC    P'1003'
*MCALL #=  2045 LV= 2 VER1003  RT1   CCE,INS1003,HEX1003
VER1003  DS    0H
         CLC   INS1003,HEX1003
RT1_TEST1033     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1033
         LTORG 
RT1_CCE1033     DS 0H
*MEXIT #=  2045 LV= 2 RT1
*MEXIT #=  2044 LV= 1 ZOSOP
*MCALL #=  2046 LV= 1  ZOSOP 'EC64','Compare and Branch Relative','CGRJX
               ','RIE6'  RPI-817
         JAS   R11,VER1004
         USING *,R11
INS1004  CGRJ R1,R2,M3,*-2
HEX1004  DC    X'EC12FFFF3064'
NUM1004  DC    P'1004'
*MCALL #=  2047 LV= 2 VER1004  RT1   CCE,INS1004,HEX1004
VER1004  DS    0H
         CLC   INS1004,HEX1004
RT1_TEST1034     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1034
         LTORG 
RT1_CCE1034     DS 0H
*MEXIT #=  2047 LV= 2 RT1
*MEXIT #=  2046 LV= 1 ZOSOP
*MCALL #=  2048 LV= 1  ZOSOP 'EC648','CGRJ if Equal','CGRJE','RIE7'  RPX
               I-817
         JAS   R11,VER1005
         USING *,R11
INS1005  CGRJE R1,R2,*-2
HEX1005  DC    X'EC12FFFF8064'
NUM1005  DC    P'1005'
*MCALL #=  2049 LV= 2 VER1005  RT1   CCE,INS1005,HEX1005
VER1005  DS    0H
         CLC   INS1005,HEX1005
RT1_TEST1035     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1035
         LTORG 
RT1_CCE1035     DS 0H
*MEXIT #=  2049 LV= 2 RT1
*MEXIT #=  2048 LV= 1 ZOSOP
*MCALL #=  2050 LV= 1  ZOSOP 'EC642','CGRJ if High','CGRJH','RIE7'  RPIX
               -817
         JAS   R11,VER1006
         USING *,R11
INS1006  CGRJH R1,R2,*-2
HEX1006  DC    X'EC12FFFF2064'
NUM1006  DC    P'1006'
*MCALL #=  2051 LV= 2 VER1006  RT1   CCE,INS1006,HEX1006
VER1006  DS    0H
         CLC   INS1006,HEX1006
RT1_TEST1036     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1036
         LTORG 
RT1_CCE1036     DS 0H
*MEXIT #=  2051 LV= 2 RT1
*MEXIT #=  2050 LV= 1 ZOSOP
*MCALL #=  2052 LV= 1  ZOSOP 'EC644','CGRJ if Low','CGRJL','RIE7'  RPI-X
               817
         JAS   R11,VER1007
         USING *,R11
INS1007  CGRJL R1,R2,*-2
HEX1007  DC    X'EC12FFFF4064'
NUM1007  DC    P'1007'
*MCALL #=  2053 LV= 2 VER1007  RT1   CCE,INS1007,HEX1007
VER1007  DS    0H
         CLC   INS1007,HEX1007
RT1_TEST1037     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1037
         LTORG 
RT1_CCE1037     DS 0H
*MEXIT #=  2053 LV= 2 RT1
*MEXIT #=  2052 LV= 1 ZOSOP
*MCALL #=  2054 LV= 1  ZOSOP 'EC646','CGRJ if Not Equal','CGRJNE','RIE7X
               '  RPI-817
         JAS   R11,VER1008
         USING *,R11
INS1008  CGRJNE R1,R2,*-2
HEX1008  DC    X'EC12FFFF6064'
NUM1008  DC    P'1008'
*MCALL #=  2055 LV= 2 VER1008  RT1   CCE,INS1008,HEX1008
VER1008  DS    0H
         CLC   INS1008,HEX1008
RT1_TEST1038     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1038
         LTORG 
RT1_CCE1038     DS 0H
*MEXIT #=  2055 LV= 2 RT1
*MEXIT #=  2054 LV= 1 ZOSOP
*MCALL #=  2056 LV= 1  ZOSOP 'EC64C','CGRJ if Not High','CGRJNH','RIE7'X
                 RPI-817
         JAS   R11,VER1009
         USING *,R11
INS1009  CGRJNH R1,R2,*-2
HEX1009  DC    X'EC12FFFFC064'
NUM1009  DC    P'1009'
*MCALL #=  2057 LV= 2 VER1009  RT1   CCE,INS1009,HEX1009
VER1009  DS    0H
         CLC   INS1009,HEX1009
RT1_TEST1039     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1039
         LTORG 
RT1_CCE1039     DS 0H
*MEXIT #=  2057 LV= 2 RT1
*MEXIT #=  2056 LV= 1 ZOSOP
*MCALL #=  2058 LV= 1  ZOSOP 'EC64A','CGRJ if Not Low','CGRJNL','RIE7' X
                RPI-817
         JAS   R11,VER1010
         USING *,R11
INS1010  CGRJNL R1,R2,*-2
HEX1010  DC    X'EC12FFFFA064'
NUM1010  DC    P'1010'
*MCALL #=  2059 LV= 2 VER1010  RT1   CCE,INS1010,HEX1010
VER1010  DS    0H
         CLC   INS1010,HEX1010
RT1_TEST1040     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1040
         LTORG 
RT1_CCE1040     DS 0H
*MEXIT #=  2059 LV= 2 RT1
*MEXIT #=  2058 LV= 1 ZOSOP
*MCALL #=  2060 LV= 1  ZOSOP 'EC65','Compare Logical and Branch Rel','CX
               LGRJ','RIE6'  RPI-817
         JAS   R11,VER1011
         USING *,R11
INS1011  CLGRJ R1,R2,M3,*-2
HEX1011  DC    X'EC12FFFF3065'
NUM1011  DC    P'1011'
*MCALL #=  2061 LV= 2 VER1011  RT1   CCE,INS1011,HEX1011
VER1011  DS    0H
         CLC   INS1011,HEX1011
RT1_TEST1041     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1041
         LTORG 
RT1_CCE1041     DS 0H
*MEXIT #=  2061 LV= 2 RT1
*MEXIT #=  2060 LV= 1 ZOSOP
*MCALL #=  2062 LV= 1  ZOSOP 'EC658','CLGRJ if Equal','CLGRJE','RIE7'  X
               RPI-817
         JAS   R11,VER1012
         USING *,R11
INS1012  CLGRJE R1,R2,*-2
HEX1012  DC    X'EC12FFFF8065'
NUM1012  DC    P'1012'
*MCALL #=  2063 LV= 2 VER1012  RT1   CCE,INS1012,HEX1012
VER1012  DS    0H
         CLC   INS1012,HEX1012
RT1_TEST1042     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1042
         LTORG 
RT1_CCE1042     DS 0H
*MEXIT #=  2063 LV= 2 RT1
*MEXIT #=  2062 LV= 1 ZOSOP
*MCALL #=  2064 LV= 1  ZOSOP 'EC652','CLGRJ if High','CLGRJH','RIE7'  RX
               PI-817
         JAS   R11,VER1013
         USING *,R11
INS1013  CLGRJH R1,R2,*-2
HEX1013  DC    X'EC12FFFF2065'
NUM1013  DC    P'1013'
*MCALL #=  2065 LV= 2 VER1013  RT1   CCE,INS1013,HEX1013
VER1013  DS    0H
         CLC   INS1013,HEX1013
RT1_TEST1043     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1043
         LTORG 
RT1_CCE1043     DS 0H
*MEXIT #=  2065 LV= 2 RT1
*MEXIT #=  2064 LV= 1 ZOSOP
*MCALL #=  2066 LV= 1  ZOSOP 'EC654','CLGRJ if Low','CLGRJL','RIE7'  RPX
               I-817
         JAS   R11,VER1014
         USING *,R11
INS1014  CLGRJL R1,R2,*-2
HEX1014  DC    X'EC12FFFF4065'
NUM1014  DC    P'1014'
*MCALL #=  2067 LV= 2 VER1014  RT1   CCE,INS1014,HEX1014
VER1014  DS    0H
         CLC   INS1014,HEX1014
RT1_TEST1044     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1044
         LTORG 
RT1_CCE1044     DS 0H
*MEXIT #=  2067 LV= 2 RT1
*MEXIT #=  2066 LV= 1 ZOSOP
*MCALL #=  2068 LV= 1  ZOSOP 'EC656','CLGRJ if Not Equal','CLGRJNE','RIX
               E7'  RPI-817
         JAS   R11,VER1015
         USING *,R11
INS1015  CLGRJNE R1,R2,*-2
HEX1015  DC    X'EC12FFFF6065'
NUM1015  DC    P'1015'
*MCALL #=  2069 LV= 2 VER1015  RT1   CCE,INS1015,HEX1015
VER1015  DS    0H
         CLC   INS1015,HEX1015
RT1_TEST1045     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1045
         LTORG 
RT1_CCE1045     DS 0H
*MEXIT #=  2069 LV= 2 RT1
*MEXIT #=  2068 LV= 1 ZOSOP
*MCALL #=  2070 LV= 1  ZOSOP 'EC65C','CLGRJ if Not High','CLGRJNH','RIEX
               7'  RPI-817
         JAS   R11,VER1016
         USING *,R11
INS1016  CLGRJNH R1,R2,*-2
HEX1016  DC    X'EC12FFFFC065'
NUM1016  DC    P'1016'
*MCALL #=  2071 LV= 2 VER1016  RT1   CCE,INS1016,HEX1016
VER1016  DS    0H
         CLC   INS1016,HEX1016
RT1_TEST1046     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1046
         LTORG 
RT1_CCE1046     DS 0H
*MEXIT #=  2071 LV= 2 RT1
*MEXIT #=  2070 LV= 1 ZOSOP
*MCALL #=  2072 LV= 1  ZOSOP 'EC65A','CLGRJ if Not Low','CLGRJNL','RIE7X
               '  RPI-817
         JAS   R11,VER1017
         USING *,R11
INS1017  CLGRJNL R1,R2,*-2
HEX1017  DC    X'EC12FFFFA065'
NUM1017  DC    P'1017'
*MCALL #=  2073 LV= 2 VER1017  RT1   CCE,INS1017,HEX1017
VER1017  DS    0H
         CLC   INS1017,HEX1017
RT1_TEST1047     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1047
         LTORG 
RT1_CCE1047     DS 0H
*MEXIT #=  2073 LV= 2 RT1
*MEXIT #=  2072 LV= 1 ZOSOP
*MCALL #=  2074 LV= 1  ZOSOP 'EC70','Compare Immediate and Trap','CGIT'X
               ,'RIE2'  RPI-817
         JAS   R11,VER1018
         USING *,R11
INS1018  CGIT R1,I2,M3
HEX1018  DC    X'EC10FFFF3070'
NUM1018  DC    P'1018'
*MCALL #=  2075 LV= 2 VER1018  RT1   CCE,INS1018,HEX1018
VER1018  DS    0H
         CLC   INS1018,HEX1018
RT1_TEST1048     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1048
         LTORG 
RT1_CCE1048     DS 0H
*MEXIT #=  2075 LV= 2 RT1
*MEXIT #=  2074 LV= 1 ZOSOP
*MCALL #=  2076 LV= 1  ZOSOP 'EC708','CGIT if Equal','CGITE','RIE3'  RPX
               I-817
         JAS   R11,VER1019
         USING *,R11
INS1019  CGITE R1,I2
HEX1019  DC    X'EC10FFFF8070'
NUM1019  DC    P'1019'
*MCALL #=  2077 LV= 2 VER1019  RT1   CCE,INS1019,HEX1019
VER1019  DS    0H
         CLC   INS1019,HEX1019
RT1_TEST1049     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1049
         LTORG 
RT1_CCE1049     DS 0H
*MEXIT #=  2077 LV= 2 RT1
*MEXIT #=  2076 LV= 1 ZOSOP
*MCALL #=  2078 LV= 1  ZOSOP 'EC702','CGIT if High','CGITH','RIE3'  RPIX
               -817
         JAS   R11,VER1020
         USING *,R11
INS1020  CGITH R1,I2
HEX1020  DC    X'EC10FFFF2070'
NUM1020  DC    P'1020'
*MCALL #=  2079 LV= 2 VER1020  RT1   CCE,INS1020,HEX1020
VER1020  DS    0H
         CLC   INS1020,HEX1020
RT1_TEST1050     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1050
         LTORG 
RT1_CCE1050     DS 0H
*MEXIT #=  2079 LV= 2 RT1
*MEXIT #=  2078 LV= 1 ZOSOP
*MCALL #=  2080 LV= 1  ZOSOP 'EC704','CGIT if Low','CGITL','RIE3'  RPI-X
               817
         JAS   R11,VER1021
         USING *,R11
INS1021  CGITL R1,I2
HEX1021  DC    X'EC10FFFF4070'
NUM1021  DC    P'1021'
*MCALL #=  2081 LV= 2 VER1021  RT1   CCE,INS1021,HEX1021
VER1021  DS    0H
         CLC   INS1021,HEX1021
RT1_TEST1051     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1051
         LTORG 
RT1_CCE1051     DS 0H
*MEXIT #=  2081 LV= 2 RT1
*MEXIT #=  2080 LV= 1 ZOSOP
*MCALL #=  2082 LV= 1  ZOSOP 'EC706','CGIT if Not Equal','CGITNE','RIE3X
               '  RPI-817
         JAS   R11,VER1022
         USING *,R11
INS1022  CGITNE R1,I2
HEX1022  DC    X'EC10FFFF6070'
NUM1022  DC    P'1022'
*MCALL #=  2083 LV= 2 VER1022  RT1   CCE,INS1022,HEX1022
VER1022  DS    0H
         CLC   INS1022,HEX1022
RT1_TEST1052     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1052
         LTORG 
RT1_CCE1052     DS 0H
*MEXIT #=  2083 LV= 2 RT1
*MEXIT #=  2082 LV= 1 ZOSOP
*MCALL #=  2084 LV= 1  ZOSOP 'EC70C','CGIT if Not High','CGITNH','RIE3'X
                 RPI-817
         JAS   R11,VER1023
         USING *,R11
INS1023  CGITNH R1,I2
HEX1023  DC    X'EC10FFFFC070'
NUM1023  DC    P'1023'
*MCALL #=  2085 LV= 2 VER1023  RT1   CCE,INS1023,HEX1023
VER1023  DS    0H
         CLC   INS1023,HEX1023
RT1_TEST1053     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1053
         LTORG 
RT1_CCE1053     DS 0H
*MEXIT #=  2085 LV= 2 RT1
*MEXIT #=  2084 LV= 1 ZOSOP
*MCALL #=  2086 LV= 1  ZOSOP 'EC70A','CGIT if Not Low','CGITNL','RIE3' X
                RPI-817
         JAS   R11,VER1024
         USING *,R11
INS1024  CGITNL R1,I2
HEX1024  DC    X'EC10FFFFA070'
NUM1024  DC    P'1024'
*MCALL #=  2087 LV= 2 VER1024  RT1   CCE,INS1024,HEX1024
VER1024  DS    0H
         CLC   INS1024,HEX1024
RT1_TEST1054     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1054
         LTORG 
RT1_CCE1054     DS 0H
*MEXIT #=  2087 LV= 2 RT1
*MEXIT #=  2086 LV= 1 ZOSOP
*MCALL #=  2088 LV= 1  ZOSOP 'EC71','Compare Logical Imm and Trap','CLGX
               IT','RIE2'  RPI-817
         JAS   R11,VER1025
         USING *,R11
INS1025  CLGIT R1,I2,M3
HEX1025  DC    X'EC10FFFF3071'
NUM1025  DC    P'1025'
*MCALL #=  2089 LV= 2 VER1025  RT1   CCE,INS1025,HEX1025
VER1025  DS    0H
         CLC   INS1025,HEX1025
RT1_TEST1055     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1055
         LTORG 
RT1_CCE1055     DS 0H
*MEXIT #=  2089 LV= 2 RT1
*MEXIT #=  2088 LV= 1 ZOSOP
*MCALL #=  2090 LV= 1  ZOSOP 'EC718','CLGIT if Equal','CLGITE','RIE3'  X
               RPI-817
         JAS   R11,VER1026
         USING *,R11
INS1026  CLGITE R1,I2
HEX1026  DC    X'EC10FFFF8071'
NUM1026  DC    P'1026'
*MCALL #=  2091 LV= 2 VER1026  RT1   CCE,INS1026,HEX1026
VER1026  DS    0H
         CLC   INS1026,HEX1026
RT1_TEST1056     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1056
         LTORG 
RT1_CCE1056     DS 0H
*MEXIT #=  2091 LV= 2 RT1
*MEXIT #=  2090 LV= 1 ZOSOP
*MCALL #=  2092 LV= 1  ZOSOP 'EC712','CLGIT if High','CLGITH','RIE3'  RX
               PI-817
         JAS   R11,VER1027
         USING *,R11
INS1027  CLGITH R1,I2
HEX1027  DC    X'EC10FFFF2071'
NUM1027  DC    P'1027'
*MCALL #=  2093 LV= 2 VER1027  RT1   CCE,INS1027,HEX1027
VER1027  DS    0H
         CLC   INS1027,HEX1027
RT1_TEST1057     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1057
         LTORG 
RT1_CCE1057     DS 0H
*MEXIT #=  2093 LV= 2 RT1
*MEXIT #=  2092 LV= 1 ZOSOP
*MCALL #=  2094 LV= 1  ZOSOP 'EC714','CLGIT if Low','CLGITL','RIE3'  RPX
               I-817
         JAS   R11,VER1028
         USING *,R11
INS1028  CLGITL R1,I2
HEX1028  DC    X'EC10FFFF4071'
NUM1028  DC    P'1028'
*MCALL #=  2095 LV= 2 VER1028  RT1   CCE,INS1028,HEX1028
VER1028  DS    0H
         CLC   INS1028,HEX1028
RT1_TEST1058     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1058
         LTORG 
RT1_CCE1058     DS 0H
*MEXIT #=  2095 LV= 2 RT1
*MEXIT #=  2094 LV= 1 ZOSOP
*MCALL #=  2096 LV= 1  ZOSOP 'EC716','CLGIT if Not Equal','CLGITNE','RIX
               E3'  RPI-817
         JAS   R11,VER1029
         USING *,R11
INS1029  CLGITNE R1,I2
HEX1029  DC    X'EC10FFFF6071'
NUM1029  DC    P'1029'
*MCALL #=  2097 LV= 2 VER1029  RT1   CCE,INS1029,HEX1029
VER1029  DS    0H
         CLC   INS1029,HEX1029
RT1_TEST1059     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1059
         LTORG 
RT1_CCE1059     DS 0H
*MEXIT #=  2097 LV= 2 RT1
*MEXIT #=  2096 LV= 1 ZOSOP
*MCALL #=  2098 LV= 1  ZOSOP 'EC71C','CLGIT if Not High','CLGITNH','RIEX
               3'  RPI-817
         JAS   R11,VER1030
         USING *,R11
INS1030  CLGITNH R1,I2
HEX1030  DC    X'EC10FFFFC071'
NUM1030  DC    P'1030'
*MCALL #=  2099 LV= 2 VER1030  RT1   CCE,INS1030,HEX1030
VER1030  DS    0H
         CLC   INS1030,HEX1030
RT1_TEST1060     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1060
         LTORG 
RT1_CCE1060     DS 0H
*MEXIT #=  2099 LV= 2 RT1
*MEXIT #=  2098 LV= 1 ZOSOP
*MCALL #=  2100 LV= 1  ZOSOP 'EC71A','CLGIT if Not Low','CLGITNL','RIE3X
               '  RPI-817
         JAS   R11,VER1031
         USING *,R11
INS1031  CLGITNL R1,I2
HEX1031  DC    X'EC10FFFFA071'
NUM1031  DC    P'1031'
*MCALL #=  2101 LV= 2 VER1031  RT1   CCE,INS1031,HEX1031
VER1031  DS    0H
         CLC   INS1031,HEX1031
RT1_TEST1061     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1061
         LTORG 
RT1_CCE1061     DS 0H
*MEXIT #=  2101 LV= 2 RT1
*MEXIT #=  2100 LV= 1 ZOSOP
*MCALL #=  2102 LV= 1  ZOSOP 'EC72','Compare Immediate and Trap','CIT',X
               'RIE2'  RPI-817
         JAS   R11,VER1032
         USING *,R11
INS1032  CIT  R1,I2,M3
HEX1032  DC    X'EC10FFFF3072'
NUM1032  DC    P'1032'
*MCALL #=  2103 LV= 2 VER1032  RT1   CCE,INS1032,HEX1032
VER1032  DS    0H
         CLC   INS1032,HEX1032
RT1_TEST1062     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1062
         LTORG 
RT1_CCE1062     DS 0H
*MEXIT #=  2103 LV= 2 RT1
*MEXIT #=  2102 LV= 1 ZOSOP
*MCALL #=  2104 LV= 1  ZOSOP 'EC728','CIT if Equal','CITE','RIE3'  RPI-X
               817
         JAS   R11,VER1033
         USING *,R11
INS1033  CITE R1,I2
HEX1033  DC    X'EC10FFFF8072'
NUM1033  DC    P'1033'
*MCALL #=  2105 LV= 2 VER1033  RT1   CCE,INS1033,HEX1033
VER1033  DS    0H
         CLC   INS1033,HEX1033
RT1_TEST1063     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1063
         LTORG 
RT1_CCE1063     DS 0H
*MEXIT #=  2105 LV= 2 RT1
*MEXIT #=  2104 LV= 1 ZOSOP
*MCALL #=  2106 LV= 1  ZOSOP 'EC722','CIT if High','CITH','RIE3'  RPI-8X
               17
         JAS   R11,VER1034
         USING *,R11
INS1034  CITH R1,I2
HEX1034  DC    X'EC10FFFF2072'
NUM1034  DC    P'1034'
*MCALL #=  2107 LV= 2 VER1034  RT1   CCE,INS1034,HEX1034
VER1034  DS    0H
         CLC   INS1034,HEX1034
RT1_TEST1064     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1064
         LTORG 
RT1_CCE1064     DS 0H
*MEXIT #=  2107 LV= 2 RT1
*MEXIT #=  2106 LV= 1 ZOSOP
*MCALL #=  2108 LV= 1  ZOSOP 'EC724','CIT if Low','CITL','RIE3'  RPI-81X
               7
         JAS   R11,VER1035
         USING *,R11
INS1035  CITL R1,I2
HEX1035  DC    X'EC10FFFF4072'
NUM1035  DC    P'1035'
*MCALL #=  2109 LV= 2 VER1035  RT1   CCE,INS1035,HEX1035
VER1035  DS    0H
         CLC   INS1035,HEX1035
RT1_TEST1065     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1065
         LTORG 
RT1_CCE1065     DS 0H
*MEXIT #=  2109 LV= 2 RT1
*MEXIT #=  2108 LV= 1 ZOSOP
*MCALL #=  2110 LV= 1  ZOSOP 'EC726','CIT if Not Equal','CITNE','RIE3' X
                RPI-817
         JAS   R11,VER1036
         USING *,R11
INS1036  CITNE R1,I2
HEX1036  DC    X'EC10FFFF6072'
NUM1036  DC    P'1036'
*MCALL #=  2111 LV= 2 VER1036  RT1   CCE,INS1036,HEX1036
VER1036  DS    0H
         CLC   INS1036,HEX1036
RT1_TEST1066     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1066
         LTORG 
RT1_CCE1066     DS 0H
*MEXIT #=  2111 LV= 2 RT1
*MEXIT #=  2110 LV= 1 ZOSOP
*MCALL #=  2112 LV= 1  ZOSOP 'EC72C','CIT if Not High','CITNH','RIE3'  X
               RPI-817
         JAS   R11,VER1037
         USING *,R11
INS1037  CITNH R1,I2
HEX1037  DC    X'EC10FFFFC072'
NUM1037  DC    P'1037'
*MCALL #=  2113 LV= 2 VER1037  RT1   CCE,INS1037,HEX1037
VER1037  DS    0H
         CLC   INS1037,HEX1037
RT1_TEST1067     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1067
         LTORG 
RT1_CCE1067     DS 0H
*MEXIT #=  2113 LV= 2 RT1
*MEXIT #=  2112 LV= 1 ZOSOP
*MCALL #=  2114 LV= 1  ZOSOP 'EC72A','CIT if Not Low','CITNL','RIE3'  RX
               PI-817
         JAS   R11,VER1038
         USING *,R11
INS1038  CITNL R1,I2
HEX1038  DC    X'EC10FFFFA072'
NUM1038  DC    P'1038'
*MCALL #=  2115 LV= 2 VER1038  RT1   CCE,INS1038,HEX1038
VER1038  DS    0H
         CLC   INS1038,HEX1038
RT1_TEST1068     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1068
         LTORG 
RT1_CCE1068     DS 0H
*MEXIT #=  2115 LV= 2 RT1
*MEXIT #=  2114 LV= 1 ZOSOP
*MCALL #=  2116 LV= 1  ZOSOP 'EC73','Compare Logical Imm and Trap','CLFX
               IT','RIE2'  RPI-817
         JAS   R11,VER1039
         USING *,R11
INS1039  CLFIT R1,I2,M3
HEX1039  DC    X'EC10FFFF3073'
NUM1039  DC    P'1039'
*MCALL #=  2117 LV= 2 VER1039  RT1   CCE,INS1039,HEX1039
VER1039  DS    0H
         CLC   INS1039,HEX1039
RT1_TEST1069     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1069
         LTORG 
RT1_CCE1069     DS 0H
*MEXIT #=  2117 LV= 2 RT1
*MEXIT #=  2116 LV= 1 ZOSOP
*MCALL #=  2118 LV= 1  ZOSOP 'EC738','CLFIT if Equal','CLFITE','RIE3'  X
               RPI-817
         JAS   R11,VER1040
         USING *,R11
INS1040  CLFITE R1,I2
HEX1040  DC    X'EC10FFFF8073'
NUM1040  DC    P'1040'
*MCALL #=  2119 LV= 2 VER1040  RT1   CCE,INS1040,HEX1040
VER1040  DS    0H
         CLC   INS1040,HEX1040
RT1_TEST1070     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1070
         LTORG 
RT1_CCE1070     DS 0H
*MEXIT #=  2119 LV= 2 RT1
*MEXIT #=  2118 LV= 1 ZOSOP
*MCALL #=  2120 LV= 1  ZOSOP 'EC732','CLFIT if High','CLFITH','RIE3'  RX
               PI-817
         JAS   R11,VER1041
         USING *,R11
INS1041  CLFITH R1,I2
HEX1041  DC    X'EC10FFFF2073'
NUM1041  DC    P'1041'
*MCALL #=  2121 LV= 2 VER1041  RT1   CCE,INS1041,HEX1041
VER1041  DS    0H
         CLC   INS1041,HEX1041
RT1_TEST1071     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1071
         LTORG 
RT1_CCE1071     DS 0H
*MEXIT #=  2121 LV= 2 RT1
*MEXIT #=  2120 LV= 1 ZOSOP
*MCALL #=  2122 LV= 1  ZOSOP 'EC734','CLFIT if Low','CLFITL','RIE3'  RPX
               I-817
         JAS   R11,VER1042
         USING *,R11
INS1042  CLFITL R1,I2
HEX1042  DC    X'EC10FFFF4073'
NUM1042  DC    P'1042'
*MCALL #=  2123 LV= 2 VER1042  RT1   CCE,INS1042,HEX1042
VER1042  DS    0H
         CLC   INS1042,HEX1042
RT1_TEST1072     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1072
         LTORG 
RT1_CCE1072     DS 0H
*MEXIT #=  2123 LV= 2 RT1
*MEXIT #=  2122 LV= 1 ZOSOP
*MCALL #=  2124 LV= 1  ZOSOP 'EC736','CLFIT if Not Equal','CLFITNE','RIX
               E3'  RPI-817
         JAS   R11,VER1043
         USING *,R11
INS1043  CLFITNE R1,I2
HEX1043  DC    X'EC10FFFF6073'
NUM1043  DC    P'1043'
*MCALL #=  2125 LV= 2 VER1043  RT1   CCE,INS1043,HEX1043
VER1043  DS    0H
         CLC   INS1043,HEX1043
RT1_TEST1073     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1073
         LTORG 
RT1_CCE1073     DS 0H
*MEXIT #=  2125 LV= 2 RT1
*MEXIT #=  2124 LV= 1 ZOSOP
*MCALL #=  2126 LV= 1  ZOSOP 'EC73C','CLFIT if Not High','CLFITNH','RIEX
               3'  RPI-817
         JAS   R11,VER1044
         USING *,R11
INS1044  CLFITNH R1,I2
HEX1044  DC    X'EC10FFFFC073'
NUM1044  DC    P'1044'
*MCALL #=  2127 LV= 2 VER1044  RT1   CCE,INS1044,HEX1044
VER1044  DS    0H
         CLC   INS1044,HEX1044
RT1_TEST1074     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1074
         LTORG 
RT1_CCE1074     DS 0H
*MEXIT #=  2127 LV= 2 RT1
*MEXIT #=  2126 LV= 1 ZOSOP
*MCALL #=  2128 LV= 1  ZOSOP 'EC73A','CLFIT if Not Low','CLFITNL','RIE3X
               '  RPI-817
         JAS   R11,VER1045
         USING *,R11
INS1045  CLFITNL R1,I2
HEX1045  DC    X'EC10FFFFA073'
NUM1045  DC    P'1045'
*MCALL #=  2129 LV= 2 VER1045  RT1   CCE,INS1045,HEX1045
VER1045  DS    0H
         CLC   INS1045,HEX1045
RT1_TEST1075     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1075
         LTORG 
RT1_CCE1075     DS 0H
*MEXIT #=  2129 LV= 2 RT1
*MEXIT #=  2128 LV= 1 ZOSOP
*MCALL #=  2130 LV= 1  ZOSOP 'EC76','Compare and Branch Relative','CRJ'X
               ,'RIE6'  RPI-817
         JAS   R11,VER1046
         USING *,R11
INS1046  CRJ  R1,R2,M3,*-2
HEX1046  DC    X'EC12FFFF3076'
NUM1046  DC    P'1046'
*MCALL #=  2131 LV= 2 VER1046  RT1   CCE,INS1046,HEX1046
VER1046  DS    0H
         CLC   INS1046,HEX1046
RT1_TEST1076     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1076
         LTORG 
RT1_CCE1076     DS 0H
*MEXIT #=  2131 LV= 2 RT1
*MEXIT #=  2130 LV= 1 ZOSOP
*MCALL #=  2132 LV= 1  ZOSOP 'EC768','CRJ if Equal','CRJE','RIE7'  RPI-X
               817
         JAS   R11,VER1047
         USING *,R11
INS1047  CRJE R1,R2,*-2
HEX1047  DC    X'EC12FFFF8076'
NUM1047  DC    P'1047'
*MCALL #=  2133 LV= 2 VER1047  RT1   CCE,INS1047,HEX1047
VER1047  DS    0H
         CLC   INS1047,HEX1047
RT1_TEST1077     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1077
         LTORG 
RT1_CCE1077     DS 0H
*MEXIT #=  2133 LV= 2 RT1
*MEXIT #=  2132 LV= 1 ZOSOP
*MCALL #=  2134 LV= 1  ZOSOP 'EC762','CRJ if High','CRJH','RIE7'  RPI-8X
               17
         JAS   R11,VER1048
         USING *,R11
INS1048  CRJH R1,R2,*-2
HEX1048  DC    X'EC12FFFF2076'
NUM1048  DC    P'1048'
*MCALL #=  2135 LV= 2 VER1048  RT1   CCE,INS1048,HEX1048
VER1048  DS    0H
         CLC   INS1048,HEX1048
RT1_TEST1078     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1078
         LTORG 
RT1_CCE1078     DS 0H
*MEXIT #=  2135 LV= 2 RT1
*MEXIT #=  2134 LV= 1 ZOSOP
*MCALL #=  2136 LV= 1  ZOSOP 'EC764','CRJ if Low','CRJL','RIE7'  RPI-81X
               7
         JAS   R11,VER1049
         USING *,R11
INS1049  CRJL R1,R2,*-2
HEX1049  DC    X'EC12FFFF4076'
NUM1049  DC    P'1049'
*MCALL #=  2137 LV= 2 VER1049  RT1   CCE,INS1049,HEX1049
VER1049  DS    0H
         CLC   INS1049,HEX1049
RT1_TEST1079     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1079
         LTORG 
RT1_CCE1079     DS 0H
*MEXIT #=  2137 LV= 2 RT1
*MEXIT #=  2136 LV= 1 ZOSOP
*MCALL #=  2138 LV= 1  ZOSOP 'EC766','CRJ if Not Equal','CRJNE','RIE7' X
                RPI-817
         JAS   R11,VER1050
         USING *,R11
INS1050  CRJNE R1,R2,*-2
HEX1050  DC    X'EC12FFFF6076'
NUM1050  DC    P'1050'
*MCALL #=  2139 LV= 2 VER1050  RT1   CCE,INS1050,HEX1050
VER1050  DS    0H
         CLC   INS1050,HEX1050
RT1_TEST1080     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1080
         LTORG 
RT1_CCE1080     DS 0H
*MEXIT #=  2139 LV= 2 RT1
*MEXIT #=  2138 LV= 1 ZOSOP
*MCALL #=  2140 LV= 1  ZOSOP 'EC76C','CRJ if Not High','CRJNH','RIE7'  X
               RPI-817
         JAS   R11,VER1051
         USING *,R11
INS1051  CRJNH R1,R2,*-2
HEX1051  DC    X'EC12FFFFC076'
NUM1051  DC    P'1051'
*MCALL #=  2141 LV= 2 VER1051  RT1   CCE,INS1051,HEX1051
VER1051  DS    0H
         CLC   INS1051,HEX1051
RT1_TEST1081     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1081
         LTORG 
RT1_CCE1081     DS 0H
*MEXIT #=  2141 LV= 2 RT1
*MEXIT #=  2140 LV= 1 ZOSOP
*MCALL #=  2142 LV= 1  ZOSOP 'EC76A','CRJ if Not Low','CRJNL','RIE7'  RX
               PI-817
         JAS   R11,VER1052
         USING *,R11
INS1052  CRJNL R1,R2,*-2
HEX1052  DC    X'EC12FFFFA076'
NUM1052  DC    P'1052'
*MCALL #=  2143 LV= 2 VER1052  RT1   CCE,INS1052,HEX1052
VER1052  DS    0H
         CLC   INS1052,HEX1052
RT1_TEST1082     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1082
         LTORG 
RT1_CCE1082     DS 0H
*MEXIT #=  2143 LV= 2 RT1
*MEXIT #=  2142 LV= 1 ZOSOP
*MCALL #=  2144 LV= 1  ZOSOP 'EC77','Compare Logical and Branch Rel','CX
               LRJ','RIE6'  RPI-817
         JAS   R11,VER1053
         USING *,R11
INS1053  CLRJ R1,R2,M3,*-2
HEX1053  DC    X'EC12FFFF3077'
NUM1053  DC    P'1053'
*MCALL #=  2145 LV= 2 VER1053  RT1   CCE,INS1053,HEX1053
VER1053  DS    0H
         CLC   INS1053,HEX1053
RT1_TEST1083     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1083
         LTORG 
RT1_CCE1083     DS 0H
*MEXIT #=  2145 LV= 2 RT1
*MEXIT #=  2144 LV= 1 ZOSOP
*MCALL #=  2146 LV= 1  ZOSOP 'EC778','CLRJ if Equal','CLRJE','RIE7'  RPX
               I-817
         JAS   R11,VER1054
         USING *,R11
INS1054  CLRJE R1,R2,*-2
HEX1054  DC    X'EC12FFFF8077'
NUM1054  DC    P'1054'
*MCALL #=  2147 LV= 2 VER1054  RT1   CCE,INS1054,HEX1054
VER1054  DS    0H
         CLC   INS1054,HEX1054
RT1_TEST1084     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1084
         LTORG 
RT1_CCE1084     DS 0H
*MEXIT #=  2147 LV= 2 RT1
*MEXIT #=  2146 LV= 1 ZOSOP
*MCALL #=  2148 LV= 1  ZOSOP 'EC772','CLRJ if High','CLRJH','RIE7'  RPIX
               -817
         JAS   R11,VER1055
         USING *,R11
INS1055  CLRJH R1,R2,*-2
HEX1055  DC    X'EC12FFFF2077'
NUM1055  DC    P'1055'
*MCALL #=  2149 LV= 2 VER1055  RT1   CCE,INS1055,HEX1055
VER1055  DS    0H
         CLC   INS1055,HEX1055
RT1_TEST1085     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1085
         LTORG 
RT1_CCE1085     DS 0H
*MEXIT #=  2149 LV= 2 RT1
*MEXIT #=  2148 LV= 1 ZOSOP
*MCALL #=  2150 LV= 1  ZOSOP 'EC774','CLRJ if Low','CLRJL','RIE7'  RPI-X
               817
         JAS   R11,VER1056
         USING *,R11
INS1056  CLRJL R1,R2,*-2
HEX1056  DC    X'EC12FFFF4077'
NUM1056  DC    P'1056'
*MCALL #=  2151 LV= 2 VER1056  RT1   CCE,INS1056,HEX1056
VER1056  DS    0H
         CLC   INS1056,HEX1056
RT1_TEST1086     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1086
         LTORG 
RT1_CCE1086     DS 0H
*MEXIT #=  2151 LV= 2 RT1
*MEXIT #=  2150 LV= 1 ZOSOP
*MCALL #=  2152 LV= 1  ZOSOP 'EC776','CLRJ if Not Equal','CLRJNE','RIE7X
               '  RPI-817
         JAS   R11,VER1057
         USING *,R11
INS1057  CLRJNE R1,R2,*-2
HEX1057  DC    X'EC12FFFF6077'
NUM1057  DC    P'1057'
*MCALL #=  2153 LV= 2 VER1057  RT1   CCE,INS1057,HEX1057
VER1057  DS    0H
         CLC   INS1057,HEX1057
RT1_TEST1087     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1087
         LTORG 
RT1_CCE1087     DS 0H
*MEXIT #=  2153 LV= 2 RT1
*MEXIT #=  2152 LV= 1 ZOSOP
*MCALL #=  2154 LV= 1  ZOSOP 'EC77C','CLRJ if Not High','CLRJNH','RIE7'X
                 RPI-817
         JAS   R11,VER1058
         USING *,R11
INS1058  CLRJNH R1,R2,*-2
HEX1058  DC    X'EC12FFFFC077'
NUM1058  DC    P'1058'
*MCALL #=  2155 LV= 2 VER1058  RT1   CCE,INS1058,HEX1058
VER1058  DS    0H
         CLC   INS1058,HEX1058
RT1_TEST1088     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1088
         LTORG 
RT1_CCE1088     DS 0H
*MEXIT #=  2155 LV= 2 RT1
*MEXIT #=  2154 LV= 1 ZOSOP
*MCALL #=  2156 LV= 1  ZOSOP 'EC77A','CLRJ if Not Low','CLRJNL','RIE7' X
                RPI-817
         JAS   R11,VER1059
         USING *,R11
INS1059  CLRJNL R1,R2,*-2
HEX1059  DC    X'EC12FFFFA077'
NUM1059  DC    P'1059'
*MCALL #=  2157 LV= 2 VER1059  RT1   CCE,INS1059,HEX1059
VER1059  DS    0H
         CLC   INS1059,HEX1059
RT1_TEST1089     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1089
         LTORG 
RT1_CCE1089     DS 0H
*MEXIT #=  2157 LV= 2 RT1
*MEXIT #=  2156 LV= 1 ZOSOP
*MCALL #=  2158 LV= 1  ZOSOP 'EC7C','Compare Imm and Branch Rel','CGIJ'X
               ,'RIE4'  RPI-817
         JAS   R11,VER1060
         USING *,R11
INS1060  CGIJ R1,I2,M3,*-2
HEX1060  DC    X'EC13FFFFFF7C'
NUM1060  DC    P'1060'
*MCALL #=  2159 LV= 2 VER1060  RT1   CCE,INS1060,HEX1060
VER1060  DS    0H
         CLC   INS1060,HEX1060
RT1_TEST1090     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1090
         LTORG 
RT1_CCE1090     DS 0H
*MEXIT #=  2159 LV= 2 RT1
*MEXIT #=  2158 LV= 1 ZOSOP
*MCALL #=  2160 LV= 1  ZOSOP 'EC7C8','CGIJ if Equal','CGIJE','RIE5'  RPX
               I-817
         JAS   R11,VER1061
         USING *,R11
INS1061  CGIJE R1,I2,*-2
HEX1061  DC    X'EC18FFFFFF7C'
NUM1061  DC    P'1061'
*MCALL #=  2161 LV= 2 VER1061  RT1   CCE,INS1061,HEX1061
VER1061  DS    0H
         CLC   INS1061,HEX1061
RT1_TEST1091     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1091
         LTORG 
RT1_CCE1091     DS 0H
*MEXIT #=  2161 LV= 2 RT1
*MEXIT #=  2160 LV= 1 ZOSOP
*MCALL #=  2162 LV= 1  ZOSOP 'EC7C2','CGIJ if High','CGIJH','RIE5'  RPIX
               -817
         JAS   R11,VER1062
         USING *,R11
INS1062  CGIJH R1,I2,*-2
HEX1062  DC    X'EC12FFFFFF7C'
NUM1062  DC    P'1062'
*MCALL #=  2163 LV= 2 VER1062  RT1   CCE,INS1062,HEX1062
VER1062  DS    0H
         CLC   INS1062,HEX1062
RT1_TEST1092     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1092
         LTORG 
RT1_CCE1092     DS 0H
*MEXIT #=  2163 LV= 2 RT1
*MEXIT #=  2162 LV= 1 ZOSOP
*MCALL #=  2164 LV= 1  ZOSOP 'EC7C4','CGIJ if Low','CGIJL','RIE5'  RPI-X
               817
         JAS   R11,VER1063
         USING *,R11
INS1063  CGIJL R1,I2,*-2
HEX1063  DC    X'EC14FFFFFF7C'
NUM1063  DC    P'1063'
*MCALL #=  2165 LV= 2 VER1063  RT1   CCE,INS1063,HEX1063
VER1063  DS    0H
         CLC   INS1063,HEX1063
RT1_TEST1093     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1093
         LTORG 
RT1_CCE1093     DS 0H
*MEXIT #=  2165 LV= 2 RT1
*MEXIT #=  2164 LV= 1 ZOSOP
*MCALL #=  2166 LV= 1  ZOSOP 'EC7C6','CGIJ if Not Equal','CGIJNE','RIE5X
               '  RPI-817
         JAS   R11,VER1064
         USING *,R11
INS1064  CGIJNE R1,I2,*-2
HEX1064  DC    X'EC16FFFFFF7C'
NUM1064  DC    P'1064'
*MCALL #=  2167 LV= 2 VER1064  RT1   CCE,INS1064,HEX1064
VER1064  DS    0H
         CLC   INS1064,HEX1064
RT1_TEST1094     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1094
         LTORG 
RT1_CCE1094     DS 0H
*MEXIT #=  2167 LV= 2 RT1
*MEXIT #=  2166 LV= 1 ZOSOP
*MCALL #=  2168 LV= 1  ZOSOP 'EC7CC','CGIJ if Not High','CGIJNH','RIE5'X
                 RPI-817
         JAS   R11,VER1065
         USING *,R11
INS1065  CGIJNH R1,I2,*-2
HEX1065  DC    X'EC1CFFFFFF7C'
NUM1065  DC    P'1065'
*MCALL #=  2169 LV= 2 VER1065  RT1   CCE,INS1065,HEX1065
VER1065  DS    0H
         CLC   INS1065,HEX1065
RT1_TEST1095     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1095
         LTORG 
RT1_CCE1095     DS 0H
*MEXIT #=  2169 LV= 2 RT1
*MEXIT #=  2168 LV= 1 ZOSOP
*MCALL #=  2170 LV= 1  ZOSOP 'EC7CA','CGIJ if Not Low','CGIJNL','RIE5' X
                RPI-817
         JAS   R11,VER1066
         USING *,R11
INS1066  CGIJNL R1,I2,*-2
HEX1066  DC    X'EC1AFFFFFF7C'
NUM1066  DC    P'1066'
*MCALL #=  2171 LV= 2 VER1066  RT1   CCE,INS1066,HEX1066
VER1066  DS    0H
         CLC   INS1066,HEX1066
RT1_TEST1096     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1096
         LTORG 
RT1_CCE1096     DS 0H
*MEXIT #=  2171 LV= 2 RT1
*MEXIT #=  2170 LV= 1 ZOSOP
*MCALL #=  2172 LV= 1  ZOSOP 'EC7D','Compare Log Imm and Branch Rel','CX
               LGIJ','RIE4'  RPI-817
         JAS   R11,VER1067
         USING *,R11
INS1067  CLGIJ R1,I2,M3,*-2
HEX1067  DC    X'EC13FFFFFF7D'
NUM1067  DC    P'1067'
*MCALL #=  2173 LV= 2 VER1067  RT1   CCE,INS1067,HEX1067
VER1067  DS    0H
         CLC   INS1067,HEX1067
RT1_TEST1097     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1097
         LTORG 
RT1_CCE1097     DS 0H
*MEXIT #=  2173 LV= 2 RT1
*MEXIT #=  2172 LV= 1 ZOSOP
*MCALL #=  2174 LV= 1  ZOSOP 'EC7D8','CLGIJ if Equal','CLGIJE','RIE5'  X
               RPI-817
         JAS   R11,VER1068
         USING *,R11
INS1068  CLGIJE R1,I2,*-2
HEX1068  DC    X'EC18FFFFFF7D'
NUM1068  DC    P'1068'
*MCALL #=  2175 LV= 2 VER1068  RT1   CCE,INS1068,HEX1068
VER1068  DS    0H
         CLC   INS1068,HEX1068
RT1_TEST1098     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1098
         LTORG 
RT1_CCE1098     DS 0H
*MEXIT #=  2175 LV= 2 RT1
*MEXIT #=  2174 LV= 1 ZOSOP
*MCALL #=  2176 LV= 1  ZOSOP 'EC7D2','CLGIJ if High','CLGIJH','RIE5'  RX
               PI-817
         JAS   R11,VER1069
         USING *,R11
INS1069  CLGIJH R1,I2,*-2
HEX1069  DC    X'EC12FFFFFF7D'
NUM1069  DC    P'1069'
*MCALL #=  2177 LV= 2 VER1069  RT1   CCE,INS1069,HEX1069
VER1069  DS    0H
         CLC   INS1069,HEX1069
RT1_TEST1099     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1099
         LTORG 
RT1_CCE1099     DS 0H
*MEXIT #=  2177 LV= 2 RT1
*MEXIT #=  2176 LV= 1 ZOSOP
*MCALL #=  2178 LV= 1  ZOSOP 'EC7D4','CLGIJ if Low','CLGIJL','RIE5'  RPX
               I-817
         JAS   R11,VER1070
         USING *,R11
INS1070  CLGIJL R1,I2,*-2
HEX1070  DC    X'EC14FFFFFF7D'
NUM1070  DC    P'1070'
*MCALL #=  2179 LV= 2 VER1070  RT1   CCE,INS1070,HEX1070
VER1070  DS    0H
         CLC   INS1070,HEX1070
RT1_TEST1100     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1100
         LTORG 
RT1_CCE1100     DS 0H
*MEXIT #=  2179 LV= 2 RT1
*MEXIT #=  2178 LV= 1 ZOSOP
*MCALL #=  2180 LV= 1  ZOSOP 'EC7D6','CLGIJ if Not Equal','CLGIJNE','RIX
               E5'  RPI-817
         JAS   R11,VER1071
         USING *,R11
INS1071  CLGIJNE R1,I2,*-2
HEX1071  DC    X'EC16FFFFFF7D'
NUM1071  DC    P'1071'
*MCALL #=  2181 LV= 2 VER1071  RT1   CCE,INS1071,HEX1071
VER1071  DS    0H
         CLC   INS1071,HEX1071
RT1_TEST1101     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1101
         LTORG 
RT1_CCE1101     DS 0H
*MEXIT #=  2181 LV= 2 RT1
*MEXIT #=  2180 LV= 1 ZOSOP
*MCALL #=  2182 LV= 1  ZOSOP 'EC7DC','CLGIJ if Not High','CLGIJNH','RIEX
               5'  RPI-817
         JAS   R11,VER1072
         USING *,R11
INS1072  CLGIJNH R1,I2,*-2
HEX1072  DC    X'EC1CFFFFFF7D'
NUM1072  DC    P'1072'
*MCALL #=  2183 LV= 2 VER1072  RT1   CCE,INS1072,HEX1072
VER1072  DS    0H
         CLC   INS1072,HEX1072
RT1_TEST1102     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1102
         LTORG 
RT1_CCE1102     DS 0H
*MEXIT #=  2183 LV= 2 RT1
*MEXIT #=  2182 LV= 1 ZOSOP
*MCALL #=  2184 LV= 1  ZOSOP 'EC7DA','CLGIJ if Not Low','CLGIJNL','RIE5X
               '  RPI-817
         JAS   R11,VER1073
         USING *,R11
INS1073  CLGIJNL R1,I2,*-2
HEX1073  DC    X'EC1AFFFFFF7D'
NUM1073  DC    P'1073'
*MCALL #=  2185 LV= 2 VER1073  RT1   CCE,INS1073,HEX1073
VER1073  DS    0H
         CLC   INS1073,HEX1073
RT1_TEST1103     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1103
         LTORG 
RT1_CCE1103     DS 0H
*MEXIT #=  2185 LV= 2 RT1
*MEXIT #=  2184 LV= 1 ZOSOP
*MCALL #=  2186 LV= 1  ZOSOP 'EC7E','Compare Imm and Branch Rel','CIJ',X
               'RIE4'  RPI-817
         JAS   R11,VER1074
         USING *,R11
INS1074  CIJ  R1,I2,M3,*-2
HEX1074  DC    X'EC13FFFFFF7E'
NUM1074  DC    P'1074'
*MCALL #=  2187 LV= 2 VER1074  RT1   CCE,INS1074,HEX1074
VER1074  DS    0H
         CLC   INS1074,HEX1074
RT1_TEST1104     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1104
         LTORG 
RT1_CCE1104     DS 0H
*MEXIT #=  2187 LV= 2 RT1
*MEXIT #=  2186 LV= 1 ZOSOP
*MCALL #=  2188 LV= 1  ZOSOP 'EC7E8','CIJ if Equal','CIJE','RIE5'  RPI-X
               817
         JAS   R11,VER1075
         USING *,R11
INS1075  CIJE R1,I2,*-2
HEX1075  DC    X'EC18FFFFFF7E'
NUM1075  DC    P'1075'
*MCALL #=  2189 LV= 2 VER1075  RT1   CCE,INS1075,HEX1075
VER1075  DS    0H
         CLC   INS1075,HEX1075
RT1_TEST1105     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1105
         LTORG 
RT1_CCE1105     DS 0H
*MEXIT #=  2189 LV= 2 RT1
*MEXIT #=  2188 LV= 1 ZOSOP
*MCALL #=  2190 LV= 1  ZOSOP 'EC7E2','CIJ if High','CIJH','RIE5'  RPI-8X
               17
         JAS   R11,VER1076
         USING *,R11
INS1076  CIJH R1,I2,*-2
HEX1076  DC    X'EC12FFFFFF7E'
NUM1076  DC    P'1076'
*MCALL #=  2191 LV= 2 VER1076  RT1   CCE,INS1076,HEX1076
VER1076  DS    0H
         CLC   INS1076,HEX1076
RT1_TEST1106     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1106
         LTORG 
RT1_CCE1106     DS 0H
*MEXIT #=  2191 LV= 2 RT1
*MEXIT #=  2190 LV= 1 ZOSOP
*MCALL #=  2192 LV= 1  ZOSOP 'EC7E4','CIJ if Low','CIJL','RIE5'  RPI-81X
               7
         JAS   R11,VER1077
         USING *,R11
INS1077  CIJL R1,I2,*-2
HEX1077  DC    X'EC14FFFFFF7E'
NUM1077  DC    P'1077'
*MCALL #=  2193 LV= 2 VER1077  RT1   CCE,INS1077,HEX1077
VER1077  DS    0H
         CLC   INS1077,HEX1077
RT1_TEST1107     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1107
         LTORG 
RT1_CCE1107     DS 0H
*MEXIT #=  2193 LV= 2 RT1
*MEXIT #=  2192 LV= 1 ZOSOP
*MCALL #=  2194 LV= 1  ZOSOP 'EC7E6','CIJ if Not Equal','CIJNE','RIE5' X
                RPI-817
         JAS   R11,VER1078
         USING *,R11
INS1078  CIJNE R1,I2,*-2
HEX1078  DC    X'EC16FFFFFF7E'
NUM1078  DC    P'1078'
*MCALL #=  2195 LV= 2 VER1078  RT1   CCE,INS1078,HEX1078
VER1078  DS    0H
         CLC   INS1078,HEX1078
RT1_TEST1108     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1108
         LTORG 
RT1_CCE1108     DS 0H
*MEXIT #=  2195 LV= 2 RT1
*MEXIT #=  2194 LV= 1 ZOSOP
*MCALL #=  2196 LV= 1  ZOSOP 'EC7EC','CIJ if Not High','CIJNH','RIE5'  X
               RPI-817
         JAS   R11,VER1079
         USING *,R11
INS1079  CIJNH R1,I2,*-2
HEX1079  DC    X'EC1CFFFFFF7E'
NUM1079  DC    P'1079'
*MCALL #=  2197 LV= 2 VER1079  RT1   CCE,INS1079,HEX1079
VER1079  DS    0H
         CLC   INS1079,HEX1079
RT1_TEST1109     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1109
         LTORG 
RT1_CCE1109     DS 0H
*MEXIT #=  2197 LV= 2 RT1
*MEXIT #=  2196 LV= 1 ZOSOP
*MCALL #=  2198 LV= 1  ZOSOP 'EC7EA','CIJ if Not Low','CIJNL','RIE5'  RX
               PI-817
         JAS   R11,VER1080
         USING *,R11
INS1080  CIJNL R1,I2,*-2
HEX1080  DC    X'EC1AFFFFFF7E'
NUM1080  DC    P'1080'
*MCALL #=  2199 LV= 2 VER1080  RT1   CCE,INS1080,HEX1080
VER1080  DS    0H
         CLC   INS1080,HEX1080
RT1_TEST1110     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1110
         LTORG 
RT1_CCE1110     DS 0H
*MEXIT #=  2199 LV= 2 RT1
*MEXIT #=  2198 LV= 1 ZOSOP
*MCALL #=  2200 LV= 1  ZOSOP 'EC7F','Compare Log Imm and Branch Rel','CX
               LIJ','RIE4'  RPI-817
         JAS   R11,VER1081
         USING *,R11
INS1081  CLIJ R1,I2,M3,*-2
HEX1081  DC    X'EC13FFFFFF7F'
NUM1081  DC    P'1081'
*MCALL #=  2201 LV= 2 VER1081  RT1   CCE,INS1081,HEX1081
VER1081  DS    0H
         CLC   INS1081,HEX1081
RT1_TEST1111     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1111
         LTORG 
RT1_CCE1111     DS 0H
*MEXIT #=  2201 LV= 2 RT1
*MEXIT #=  2200 LV= 1 ZOSOP
*MCALL #=  2202 LV= 1  ZOSOP 'EC7F8','CLIJ if Equal','CLIJE','RIE5'  RPX
               I-817
         JAS   R11,VER1082
         USING *,R11
INS1082  CLIJE R1,I2,*-2
HEX1082  DC    X'EC18FFFFFF7F'
NUM1082  DC    P'1082'
*MCALL #=  2203 LV= 2 VER1082  RT1   CCE,INS1082,HEX1082
VER1082  DS    0H
         CLC   INS1082,HEX1082
RT1_TEST1112     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1112
         LTORG 
RT1_CCE1112     DS 0H
*MEXIT #=  2203 LV= 2 RT1
*MEXIT #=  2202 LV= 1 ZOSOP
*MCALL #=  2204 LV= 1  ZOSOP 'EC7F2','CLIJ if High','CLIJH','RIE5'  RPIX
               -817
         JAS   R11,VER1083
         USING *,R11
INS1083  CLIJH R1,I2,*-2
HEX1083  DC    X'EC12FFFFFF7F'
NUM1083  DC    P'1083'
*MCALL #=  2205 LV= 2 VER1083  RT1   CCE,INS1083,HEX1083
VER1083  DS    0H
         CLC   INS1083,HEX1083
RT1_TEST1113     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1113
         LTORG 
RT1_CCE1113     DS 0H
*MEXIT #=  2205 LV= 2 RT1
*MEXIT #=  2204 LV= 1 ZOSOP
*MCALL #=  2206 LV= 1  ZOSOP 'EC7F4','CLIJ if Low','CLIJL','RIE5'  RPI-X
               817
         JAS   R11,VER1084
         USING *,R11
INS1084  CLIJL R1,I2,*-2
HEX1084  DC    X'EC14FFFFFF7F'
NUM1084  DC    P'1084'
*MCALL #=  2207 LV= 2 VER1084  RT1   CCE,INS1084,HEX1084
VER1084  DS    0H
         CLC   INS1084,HEX1084
RT1_TEST1114     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1114
         LTORG 
RT1_CCE1114     DS 0H
*MEXIT #=  2207 LV= 2 RT1
*MEXIT #=  2206 LV= 1 ZOSOP
*MCALL #=  2208 LV= 1  ZOSOP 'EC7F6','CLIJ if Not Equal','CLIJNE','RIE5X
               '  RPI-817
         JAS   R11,VER1085
         USING *,R11
INS1085  CLIJNE R1,I2,*-2
HEX1085  DC    X'EC16FFFFFF7F'
NUM1085  DC    P'1085'
*MCALL #=  2209 LV= 2 VER1085  RT1   CCE,INS1085,HEX1085
VER1085  DS    0H
         CLC   INS1085,HEX1085
RT1_TEST1115     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1115
         LTORG 
RT1_CCE1115     DS 0H
*MEXIT #=  2209 LV= 2 RT1
*MEXIT #=  2208 LV= 1 ZOSOP
*MCALL #=  2210 LV= 1  ZOSOP 'EC7FC','CLIJ if Not High','CLIJNH','RIE5'X
                 RPI-817
         JAS   R11,VER1086
         USING *,R11
INS1086  CLIJNH R1,I2,*-2
HEX1086  DC    X'EC1CFFFFFF7F'
NUM1086  DC    P'1086'
*MCALL #=  2211 LV= 2 VER1086  RT1   CCE,INS1086,HEX1086
VER1086  DS    0H
         CLC   INS1086,HEX1086
RT1_TEST1116     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1116
         LTORG 
RT1_CCE1116     DS 0H
*MEXIT #=  2211 LV= 2 RT1
*MEXIT #=  2210 LV= 1 ZOSOP
*MCALL #=  2212 LV= 1  ZOSOP 'EC7FA','CLIJ if Not Low','CLIJNL','RIE5' X
                RPI-817
         JAS   R11,VER1087
         USING *,R11
INS1087  CLIJNL R1,I2,*-2
HEX1087  DC    X'EC1AFFFFFF7F'
NUM1087  DC    P'1087'
*MCALL #=  2213 LV= 2 VER1087  RT1   CCE,INS1087,HEX1087
VER1087  DS    0H
         CLC   INS1087,HEX1087
RT1_TEST1117     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1117
         LTORG 
RT1_CCE1117     DS 0H
*MEXIT #=  2213 LV= 2 RT1
*MEXIT #=  2212 LV= 1 ZOSOP
*MCALL #=  2214 LV= 1  ZOSOP 'ECD8','ADD IMMEDIATE (32??16)','AHIK','RIX
               E9'  RPI-1125 Z196
         JAS   R11,VER1088
         USING *,R11
INS1088  AHIK R1,R3,I2
HEX1088  DC    X'EC13FFFF00D8'
NUM1088  DC    P'1088'
*MCALL #=  2215 LV= 2 VER1088  RT1   CCE,INS1088,HEX1088
VER1088  DS    0H
         CLC   INS1088,HEX1088
RT1_TEST1118     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1118
         LTORG 
RT1_CCE1118     DS 0H
*MEXIT #=  2215 LV= 2 RT1
*MEXIT #=  2214 LV= 1 ZOSOP
*MCALL #=  2216 LV= 1  ZOSOP 'ECD9','ADD IMMEDIATE (64??16)','AGHIK','RX
               IE9'  RPI-1125 Z196
         JAS   R11,VER1089
         USING *,R11
INS1089  AGHIK R1,R3,I2
HEX1089  DC    X'EC13FFFF00D9'
NUM1089  DC    P'1089'
*MCALL #=  2217 LV= 2 VER1089  RT1   CCE,INS1089,HEX1089
VER1089  DS    0H
         CLC   INS1089,HEX1089
RT1_TEST1119     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1119
         LTORG 
RT1_CCE1119     DS 0H
*MEXIT #=  2217 LV= 2 RT1
*MEXIT #=  2216 LV= 1 ZOSOP
*MCALL #=  2218 LV= 1  ZOSOP 'ECDA','ADD LOGICAL WITH SIGNED IMMEDIATE X
               (32??16)','ALHSIK','RIE9'  RPI-1125 Z196
         JAS   R11,VER1090
         USING *,R11
INS1090  ALHSIK R1,R3,I2
HEX1090  DC    X'EC13FFFF00DA'
NUM1090  DC    P'1090'
*MCALL #=  2219 LV= 2 VER1090  RT1   CCE,INS1090,HEX1090
VER1090  DS    0H
         CLC   INS1090,HEX1090
RT1_TEST1120     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1120
         LTORG 
RT1_CCE1120     DS 0H
*MEXIT #=  2219 LV= 2 RT1
*MEXIT #=  2218 LV= 1 ZOSOP
*MCALL #=  2220 LV= 1  ZOSOP 'ECDB','ADD LOGICAL WITH SIGNED IMMEDIATE X
               (64??16)','ALGHSIK','RIE9'  RPI-1125 Z196
         JAS   R11,VER1091
         USING *,R11
INS1091  ALGHSIK R1,R3,I2
HEX1091  DC    X'EC13FFFF00DB'
NUM1091  DC    P'1091'
*MCALL #=  2221 LV= 2 VER1091  RT1   CCE,INS1091,HEX1091
VER1091  DS    0H
         CLC   INS1091,HEX1091
RT1_TEST1121     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1121
         LTORG 
RT1_CCE1121     DS 0H
*MEXIT #=  2221 LV= 2 RT1
*MEXIT #=  2220 LV= 1 ZOSOP
*MCALL #=  2222 LV= 1  ZOSOP 'ECE4','Compare and Branch','CGRB','RRS1' X
                RPI-817
         JAS   R11,VER1092
         USING *,R11
INS1092  CGRB R1,R2,M3,S4
HEX1092  DC    X'EC12D00430E4'
NUM1092  DC    P'1092'
*MCALL #=  2223 LV= 2 VER1092  RT1   CCE,INS1092,HEX1092
VER1092  DS    0H
         CLC   INS1092,HEX1092
RT1_TEST1122     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1122
         LTORG 
RT1_CCE1122     DS 0H
*MEXIT #=  2223 LV= 2 RT1
*MEXIT #=  2222 LV= 1 ZOSOP
*MCALL #=  2224 LV= 1  ZOSOP 'ECE48','CGRB if Equal','CGRBE','RRS2'  RPX
               I-817
         JAS   R11,VER1093
         USING *,R11
INS1093  CGRBE R1,R2,S4
HEX1093  DC    X'EC12D00480E4'
NUM1093  DC    P'1093'
*MCALL #=  2225 LV= 2 VER1093  RT1   CCE,INS1093,HEX1093
VER1093  DS    0H
         CLC   INS1093,HEX1093
RT1_TEST1123     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1123
         LTORG 
RT1_CCE1123     DS 0H
*MEXIT #=  2225 LV= 2 RT1
*MEXIT #=  2224 LV= 1 ZOSOP
*MCALL #=  2226 LV= 1  ZOSOP 'ECE42','CGRB if High','CGRBH','RRS2'  RPIX
               -817
         JAS   R11,VER1094
         USING *,R11
INS1094  CGRBH R1,R2,S4
HEX1094  DC    X'EC12D00420E4'
NUM1094  DC    P'1094'
*MCALL #=  2227 LV= 2 VER1094  RT1   CCE,INS1094,HEX1094
VER1094  DS    0H
         CLC   INS1094,HEX1094
RT1_TEST1124     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1124
         LTORG 
RT1_CCE1124     DS 0H
*MEXIT #=  2227 LV= 2 RT1
*MEXIT #=  2226 LV= 1 ZOSOP
*MCALL #=  2228 LV= 1  ZOSOP 'ECE44','CGRB if Low','CGRBL','RRS2'  RPI-X
               817
         JAS   R11,VER1095
         USING *,R11
INS1095  CGRBL R1,R2,S4
HEX1095  DC    X'EC12D00440E4'
NUM1095  DC    P'1095'
*MCALL #=  2229 LV= 2 VER1095  RT1   CCE,INS1095,HEX1095
VER1095  DS    0H
         CLC   INS1095,HEX1095
RT1_TEST1125     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1125
         LTORG 
RT1_CCE1125     DS 0H
*MEXIT #=  2229 LV= 2 RT1
*MEXIT #=  2228 LV= 1 ZOSOP
*MCALL #=  2230 LV= 1  ZOSOP 'ECE46','CGRB if Not Equal','CGRBNE','RRS2X
               '  RPI-817
         JAS   R11,VER1096
         USING *,R11
INS1096  CGRBNE R1,R2,S4
HEX1096  DC    X'EC12D00460E4'
NUM1096  DC    P'1096'
*MCALL #=  2231 LV= 2 VER1096  RT1   CCE,INS1096,HEX1096
VER1096  DS    0H
         CLC   INS1096,HEX1096
RT1_TEST1126     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1126
         LTORG 
RT1_CCE1126     DS 0H
*MEXIT #=  2231 LV= 2 RT1
*MEXIT #=  2230 LV= 1 ZOSOP
*MCALL #=  2232 LV= 1  ZOSOP 'ECE4C','CGRB if Not High','CGRBNH','RRS2'X
                 RPI-817
         JAS   R11,VER1097
         USING *,R11
INS1097  CGRBNH R1,R2,S4
HEX1097  DC    X'EC12D004C0E4'
NUM1097  DC    P'1097'
*MCALL #=  2233 LV= 2 VER1097  RT1   CCE,INS1097,HEX1097
VER1097  DS    0H
         CLC   INS1097,HEX1097
RT1_TEST1127     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1127
         LTORG 
RT1_CCE1127     DS 0H
*MEXIT #=  2233 LV= 2 RT1
*MEXIT #=  2232 LV= 1 ZOSOP
*MCALL #=  2234 LV= 1  ZOSOP 'ECE4A','CGRB if Not Low','CGRBNL','RRS2' X
                RPI-817
         JAS   R11,VER1098
         USING *,R11
INS1098  CGRBNL R1,R2,S4
HEX1098  DC    X'EC12D004A0E4'
NUM1098  DC    P'1098'
*MCALL #=  2235 LV= 2 VER1098  RT1   CCE,INS1098,HEX1098
VER1098  DS    0H
         CLC   INS1098,HEX1098
RT1_TEST1128     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1128
         LTORG 
RT1_CCE1128     DS 0H
*MEXIT #=  2235 LV= 2 RT1
*MEXIT #=  2234 LV= 1 ZOSOP
*MCALL #=  2236 LV= 1  ZOSOP 'ECE5','Compare Log and Branch','CLGRB','RX
               RS1'  RPI-817
         JAS   R11,VER1099
         USING *,R11
INS1099  CLGRB R1,R2,M3,S4
HEX1099  DC    X'EC12D00430E5'
NUM1099  DC    P'1099'
*MCALL #=  2237 LV= 2 VER1099  RT1   CCE,INS1099,HEX1099
VER1099  DS    0H
         CLC   INS1099,HEX1099
RT1_TEST1129     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1129
         LTORG 
RT1_CCE1129     DS 0H
*MEXIT #=  2237 LV= 2 RT1
*MEXIT #=  2236 LV= 1 ZOSOP
*MCALL #=  2238 LV= 1  ZOSOP 'ECE58','CLGRB if Equal','CLGRBE','RRS2'  X
               RPI-817
         JAS   R11,VER1100
         USING *,R11
INS1100  CLGRBE R1,R2,S4
HEX1100  DC    X'EC12D00480E5'
NUM1100  DC    P'1100'
*MCALL #=  2239 LV= 2 VER1100  RT1   CCE,INS1100,HEX1100
VER1100  DS    0H
         CLC   INS1100,HEX1100
RT1_TEST1130     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1130
         LTORG 
RT1_CCE1130     DS 0H
*MEXIT #=  2239 LV= 2 RT1
*MEXIT #=  2238 LV= 1 ZOSOP
*MCALL #=  2240 LV= 1  ZOSOP 'ECE52','CLGRB if High','CLGRBH','RRS2'  RX
               PI-817
         JAS   R11,VER1101
         USING *,R11
INS1101  CLGRBH R1,R2,S4
HEX1101  DC    X'EC12D00420E5'
NUM1101  DC    P'1101'
*MCALL #=  2241 LV= 2 VER1101  RT1   CCE,INS1101,HEX1101
VER1101  DS    0H
         CLC   INS1101,HEX1101
RT1_TEST1131     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1131
         LTORG 
RT1_CCE1131     DS 0H
*MEXIT #=  2241 LV= 2 RT1
*MEXIT #=  2240 LV= 1 ZOSOP
*MCALL #=  2242 LV= 1  ZOSOP 'ECE54','CLGRB if Low','CLGRBL','RRS2'  RPX
               I-817
         JAS   R11,VER1102
         USING *,R11
INS1102  CLGRBL R1,R2,S4
HEX1102  DC    X'EC12D00440E5'
NUM1102  DC    P'1102'
*MCALL #=  2243 LV= 2 VER1102  RT1   CCE,INS1102,HEX1102
VER1102  DS    0H
         CLC   INS1102,HEX1102
RT1_TEST1132     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1132
         LTORG 
RT1_CCE1132     DS 0H
*MEXIT #=  2243 LV= 2 RT1
*MEXIT #=  2242 LV= 1 ZOSOP
*MCALL #=  2244 LV= 1  ZOSOP 'ECE56','CLGRB if Not Equal','CLGRBNE','RRX
               S2'  RPI-817
         JAS   R11,VER1103
         USING *,R11
INS1103  CLGRBNE R1,R2,S4
HEX1103  DC    X'EC12D00460E5'
NUM1103  DC    P'1103'
*MCALL #=  2245 LV= 2 VER1103  RT1   CCE,INS1103,HEX1103
VER1103  DS    0H
         CLC   INS1103,HEX1103
RT1_TEST1133     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1133
         LTORG 
RT1_CCE1133     DS 0H
*MEXIT #=  2245 LV= 2 RT1
*MEXIT #=  2244 LV= 1 ZOSOP
*MCALL #=  2246 LV= 1  ZOSOP 'ECE5C','CLGRB if Not High','CLGRBNH','RRSX
               2'  RPI-817
         JAS   R11,VER1104
         USING *,R11
INS1104  CLGRBNH R1,R2,S4
HEX1104  DC    X'EC12D004C0E5'
NUM1104  DC    P'1104'
*MCALL #=  2247 LV= 2 VER1104  RT1   CCE,INS1104,HEX1104
VER1104  DS    0H
         CLC   INS1104,HEX1104
RT1_TEST1134     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1134
         LTORG 
RT1_CCE1134     DS 0H
*MEXIT #=  2247 LV= 2 RT1
*MEXIT #=  2246 LV= 1 ZOSOP
*MCALL #=  2248 LV= 1  ZOSOP 'ECE5A','CLGRB if Not Low','CLGRBNL','RRS2X
               '  RPI-817
         JAS   R11,VER1105
         USING *,R11
INS1105  CLGRBNL R1,R2,S4
HEX1105  DC    X'EC12D004A0E5'
NUM1105  DC    P'1105'
*MCALL #=  2249 LV= 2 VER1105  RT1   CCE,INS1105,HEX1105
VER1105  DS    0H
         CLC   INS1105,HEX1105
RT1_TEST1135     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1135
         LTORG 
RT1_CCE1135     DS 0H
*MEXIT #=  2249 LV= 2 RT1
*MEXIT #=  2248 LV= 1 ZOSOP
*MCALL #=  2250 LV= 1  ZOSOP 'ECF6','Compare and Branch','CRB','RRS1'  X
               RPI-817
         JAS   R11,VER1106
         USING *,R11
INS1106  CRB  R1,R2,M3,S4
HEX1106  DC    X'EC12D00430F6'
NUM1106  DC    P'1106'
*MCALL #=  2251 LV= 2 VER1106  RT1   CCE,INS1106,HEX1106
VER1106  DS    0H
         CLC   INS1106,HEX1106
RT1_TEST1136     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1136
         LTORG 
RT1_CCE1136     DS 0H
*MEXIT #=  2251 LV= 2 RT1
*MEXIT #=  2250 LV= 1 ZOSOP
*MCALL #=  2252 LV= 1  ZOSOP 'ECF68','CRB if Equal','CRBE','RRS2'  RPI-X
               817
         JAS   R11,VER1107
         USING *,R11
INS1107  CRBE R1,R2,S4
HEX1107  DC    X'EC12D00480F6'
NUM1107  DC    P'1107'
*MCALL #=  2253 LV= 2 VER1107  RT1   CCE,INS1107,HEX1107
VER1107  DS    0H
         CLC   INS1107,HEX1107
RT1_TEST1137     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1137
         LTORG 
RT1_CCE1137     DS 0H
*MEXIT #=  2253 LV= 2 RT1
*MEXIT #=  2252 LV= 1 ZOSOP
*MCALL #=  2254 LV= 1  ZOSOP 'ECF62','CRB if High','CRBH','RRS2'  RPI-8X
               17
         JAS   R11,VER1108
         USING *,R11
INS1108  CRBH R1,R2,S4
HEX1108  DC    X'EC12D00420F6'
NUM1108  DC    P'1108'
*MCALL #=  2255 LV= 2 VER1108  RT1   CCE,INS1108,HEX1108
VER1108  DS    0H
         CLC   INS1108,HEX1108
RT1_TEST1138     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1138
         LTORG 
RT1_CCE1138     DS 0H
*MEXIT #=  2255 LV= 2 RT1
*MEXIT #=  2254 LV= 1 ZOSOP
*MCALL #=  2256 LV= 1  ZOSOP 'ECF64','CRB if Low','CRBL','RRS2'  RPI-81X
               7
         JAS   R11,VER1109
         USING *,R11
INS1109  CRBL R1,R2,S4
HEX1109  DC    X'EC12D00440F6'
NUM1109  DC    P'1109'
*MCALL #=  2257 LV= 2 VER1109  RT1   CCE,INS1109,HEX1109
VER1109  DS    0H
         CLC   INS1109,HEX1109
RT1_TEST1139     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1139
         LTORG 
RT1_CCE1139     DS 0H
*MEXIT #=  2257 LV= 2 RT1
*MEXIT #=  2256 LV= 1 ZOSOP
*MCALL #=  2258 LV= 1  ZOSOP 'ECF66','CRB if Not Equal','CRBNE','RRS2' X
                RPI-817
         JAS   R11,VER1110
         USING *,R11
INS1110  CRBNE R1,R2,S4
HEX1110  DC    X'EC12D00460F6'
NUM1110  DC    P'1110'
*MCALL #=  2259 LV= 2 VER1110  RT1   CCE,INS1110,HEX1110
VER1110  DS    0H
         CLC   INS1110,HEX1110
RT1_TEST1140     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1140
         LTORG 
RT1_CCE1140     DS 0H
*MEXIT #=  2259 LV= 2 RT1
*MEXIT #=  2258 LV= 1 ZOSOP
*MCALL #=  2260 LV= 1  ZOSOP 'ECF6C','CRB if Not High','CRBNH','RRS2'  X
               RPI-817
         JAS   R11,VER1111
         USING *,R11
INS1111  CRBNH R1,R2,S4
HEX1111  DC    X'EC12D004C0F6'
NUM1111  DC    P'1111'
*MCALL #=  2261 LV= 2 VER1111  RT1   CCE,INS1111,HEX1111
VER1111  DS    0H
         CLC   INS1111,HEX1111
RT1_TEST1141     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1141
         LTORG 
RT1_CCE1141     DS 0H
*MEXIT #=  2261 LV= 2 RT1
*MEXIT #=  2260 LV= 1 ZOSOP
*MCALL #=  2262 LV= 1  ZOSOP 'ECF6A','CRB if Not Low','CRBNL','RRS2'  RX
               PI-817
         JAS   R11,VER1112
         USING *,R11
INS1112  CRBNL R1,R2,S4
HEX1112  DC    X'EC12D004A0F6'
NUM1112  DC    P'1112'
*MCALL #=  2263 LV= 2 VER1112  RT1   CCE,INS1112,HEX1112
VER1112  DS    0H
         CLC   INS1112,HEX1112
RT1_TEST1142     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1142
         LTORG 
RT1_CCE1142     DS 0H
*MEXIT #=  2263 LV= 2 RT1
*MEXIT #=  2262 LV= 1 ZOSOP
*MCALL #=  2264 LV= 1  ZOSOP 'ECF7','Compare Logical and Branch','CLRB'X
               ,'RRS1'  RPI-817
         JAS   R11,VER1113
         USING *,R11
INS1113  CLRB R1,R2,M3,S4
HEX1113  DC    X'EC12D00430F7'
NUM1113  DC    P'1113'
*MCALL #=  2265 LV= 2 VER1113  RT1   CCE,INS1113,HEX1113
VER1113  DS    0H
         CLC   INS1113,HEX1113
RT1_TEST1143     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1143
         LTORG 
RT1_CCE1143     DS 0H
*MEXIT #=  2265 LV= 2 RT1
*MEXIT #=  2264 LV= 1 ZOSOP
*MCALL #=  2266 LV= 1  ZOSOP 'ECF78','CLRB if Equal','CLRBE','RRS2'  RPX
               I-817
         JAS   R11,VER1114
         USING *,R11
INS1114  CLRBE R1,R2,S4
HEX1114  DC    X'EC12D00480F7'
NUM1114  DC    P'1114'
*MCALL #=  2267 LV= 2 VER1114  RT1   CCE,INS1114,HEX1114
VER1114  DS    0H
         CLC   INS1114,HEX1114
RT1_TEST1144     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1144
         LTORG 
RT1_CCE1144     DS 0H
*MEXIT #=  2267 LV= 2 RT1
*MEXIT #=  2266 LV= 1 ZOSOP
*MCALL #=  2268 LV= 1  ZOSOP 'ECF72','CLRB if High','CLRBH','RRS2'  RPIX
               -817
         JAS   R11,VER1115
         USING *,R11
INS1115  CLRBH R1,R2,S4
HEX1115  DC    X'EC12D00420F7'
NUM1115  DC    P'1115'
*MCALL #=  2269 LV= 2 VER1115  RT1   CCE,INS1115,HEX1115
VER1115  DS    0H
         CLC   INS1115,HEX1115
RT1_TEST1145     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1145
         LTORG 
RT1_CCE1145     DS 0H
*MEXIT #=  2269 LV= 2 RT1
*MEXIT #=  2268 LV= 1 ZOSOP
*MCALL #=  2270 LV= 1  ZOSOP 'ECF74','CLRB if Low','CLRBL','RRS2'  RPI-X
               817
         JAS   R11,VER1116
         USING *,R11
INS1116  CLRBL R1,R2,S4
HEX1116  DC    X'EC12D00440F7'
NUM1116  DC    P'1116'
*MCALL #=  2271 LV= 2 VER1116  RT1   CCE,INS1116,HEX1116
VER1116  DS    0H
         CLC   INS1116,HEX1116
RT1_TEST1146     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1146
         LTORG 
RT1_CCE1146     DS 0H
*MEXIT #=  2271 LV= 2 RT1
*MEXIT #=  2270 LV= 1 ZOSOP
*MCALL #=  2272 LV= 1  ZOSOP 'ECF76','CLRB if Not Equal','CLRBNE','RRS2X
               '  RPI-817
         JAS   R11,VER1117
         USING *,R11
INS1117  CLRBNE R1,R2,S4
HEX1117  DC    X'EC12D00460F7'
NUM1117  DC    P'1117'
*MCALL #=  2273 LV= 2 VER1117  RT1   CCE,INS1117,HEX1117
VER1117  DS    0H
         CLC   INS1117,HEX1117
RT1_TEST1147     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1147
         LTORG 
RT1_CCE1147     DS 0H
*MEXIT #=  2273 LV= 2 RT1
*MEXIT #=  2272 LV= 1 ZOSOP
*MCALL #=  2274 LV= 1  ZOSOP 'ECF7C','CLRB if Not High','CLRBNH','RRS2'X
                 RPI-817
         JAS   R11,VER1118
         USING *,R11
INS1118  CLRBNH R1,R2,S4
HEX1118  DC    X'EC12D004C0F7'
NUM1118  DC    P'1118'
*MCALL #=  2275 LV= 2 VER1118  RT1   CCE,INS1118,HEX1118
VER1118  DS    0H
         CLC   INS1118,HEX1118
RT1_TEST1148     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1148
         LTORG 
RT1_CCE1148     DS 0H
*MEXIT #=  2275 LV= 2 RT1
*MEXIT #=  2274 LV= 1 ZOSOP
*MCALL #=  2276 LV= 1  ZOSOP 'ECF7A','CLRB if Not Low','CLRBNL','RRS2' X
                RPI-817
         JAS   R11,VER1119
         USING *,R11
INS1119  CLRBNL R1,R2,S4
HEX1119  DC    X'EC12D004A0F7'
NUM1119  DC    P'1119'
*MCALL #=  2277 LV= 2 VER1119  RT1   CCE,INS1119,HEX1119
VER1119  DS    0H
         CLC   INS1119,HEX1119
RT1_TEST1149     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1149
         LTORG 
RT1_CCE1149     DS 0H
*MEXIT #=  2277 LV= 2 RT1
*MEXIT #=  2276 LV= 1 ZOSOP
*MCALL #=  2278 LV= 1  ZOSOP 'ECFC','CGIB if Not Low','CGIB','RRS3'  RPX
               I-817
         JAS   R11,VER1120
         USING *,R11
INS1120  CGIB R1,I2,M3,S4
HEX1120  DC    X'EC13D004FFFC'
NUM1120  DC    P'1120'
*MCALL #=  2279 LV= 2 VER1120  RT1   CCE,INS1120,HEX1120
VER1120  DS    0H
         CLC   INS1120,HEX1120
RT1_TEST1150     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1150
         LTORG 
RT1_CCE1150     DS 0H
*MEXIT #=  2279 LV= 2 RT1
*MEXIT #=  2278 LV= 1 ZOSOP
*MCALL #=  2280 LV= 1  ZOSOP 'ECFC8','CGIB if Not Low','CGIBE','RRS4'  X
               RPI-817
         JAS   R11,VER1121
         USING *,R11
INS1121  CGIBE R1,I2,S4
HEX1121  DC    X'EC18D004FFFC'
NUM1121  DC    P'1121'
*MCALL #=  2281 LV= 2 VER1121  RT1   CCE,INS1121,HEX1121
VER1121  DS    0H
         CLC   INS1121,HEX1121
RT1_TEST1151     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1151
         LTORG 
RT1_CCE1151     DS 0H
*MEXIT #=  2281 LV= 2 RT1
*MEXIT #=  2280 LV= 1 ZOSOP
*MCALL #=  2282 LV= 1  ZOSOP 'ECFC2','CGIB if Not Low','CGIBH','RRS4'  X
               RPI-817
         JAS   R11,VER1122
         USING *,R11
INS1122  CGIBH R1,I2,S4
HEX1122  DC    X'EC12D004FFFC'
NUM1122  DC    P'1122'
*MCALL #=  2283 LV= 2 VER1122  RT1   CCE,INS1122,HEX1122
VER1122  DS    0H
         CLC   INS1122,HEX1122
RT1_TEST1152     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1152
         LTORG 
RT1_CCE1152     DS 0H
*MEXIT #=  2283 LV= 2 RT1
*MEXIT #=  2282 LV= 1 ZOSOP
*MCALL #=  2284 LV= 1  ZOSOP 'ECFC4','CGIB if Not Low','CGIBL','RRS4'  X
               RPI-817
         JAS   R11,VER1123
         USING *,R11
INS1123  CGIBL R1,I2,S4
HEX1123  DC    X'EC14D004FFFC'
NUM1123  DC    P'1123'
*MCALL #=  2285 LV= 2 VER1123  RT1   CCE,INS1123,HEX1123
VER1123  DS    0H
         CLC   INS1123,HEX1123
RT1_TEST1153     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1153
         LTORG 
RT1_CCE1153     DS 0H
*MEXIT #=  2285 LV= 2 RT1
*MEXIT #=  2284 LV= 1 ZOSOP
*MCALL #=  2286 LV= 1  ZOSOP 'ECFC6','CGIB if Not Low','CGIBNE','RRS4' X
                RPI-817
         JAS   R11,VER1124
         USING *,R11
INS1124  CGIBNE R1,I2,S4
HEX1124  DC    X'EC16D004FFFC'
NUM1124  DC    P'1124'
*MCALL #=  2287 LV= 2 VER1124  RT1   CCE,INS1124,HEX1124
VER1124  DS    0H
         CLC   INS1124,HEX1124
RT1_TEST1154     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1154
         LTORG 
RT1_CCE1154     DS 0H
*MEXIT #=  2287 LV= 2 RT1
*MEXIT #=  2286 LV= 1 ZOSOP
*MCALL #=  2288 LV= 1  ZOSOP 'ECFCC','CGIB if Not Low','CGIBNH','RRS4' X
                RPI-817
         JAS   R11,VER1125
         USING *,R11
INS1125  CGIBNH R1,I2,S4
HEX1125  DC    X'EC1CD004FFFC'
NUM1125  DC    P'1125'
*MCALL #=  2289 LV= 2 VER1125  RT1   CCE,INS1125,HEX1125
VER1125  DS    0H
         CLC   INS1125,HEX1125
RT1_TEST1155     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1155
         LTORG 
RT1_CCE1155     DS 0H
*MEXIT #=  2289 LV= 2 RT1
*MEXIT #=  2288 LV= 1 ZOSOP
*MCALL #=  2290 LV= 1  ZOSOP 'ECFCA','CGIB if Not Low','CGIBNL','RRS4' X
                RPI-817
         JAS   R11,VER1126
         USING *,R11
INS1126  CGIBNL R1,I2,S4
HEX1126  DC    X'EC1AD004FFFC'
NUM1126  DC    P'1126'
*MCALL #=  2291 LV= 2 VER1126  RT1   CCE,INS1126,HEX1126
VER1126  DS    0H
         CLC   INS1126,HEX1126
RT1_TEST1156     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1156
         LTORG 
RT1_CCE1156     DS 0H
*MEXIT #=  2291 LV= 2 RT1
*MEXIT #=  2290 LV= 1 ZOSOP
*MCALL #=  2292 LV= 1  ZOSOP 'ECFD','Compare Log Imm and Branch','CLGIBX
               ','RRS3'  RPI-817
         JAS   R11,VER1127
         USING *,R11
INS1127  CLGIB R1,I2,M3,S4
HEX1127  DC    X'EC13D004FFFD'
NUM1127  DC    P'1127'
*MCALL #=  2293 LV= 2 VER1127  RT1   CCE,INS1127,HEX1127
VER1127  DS    0H
         CLC   INS1127,HEX1127
RT1_TEST1157     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1157
         LTORG 
RT1_CCE1157     DS 0H
*MEXIT #=  2293 LV= 2 RT1
*MEXIT #=  2292 LV= 1 ZOSOP
*MCALL #=  2294 LV= 1  ZOSOP 'ECFD8','CLGIB if Equal','CLGIBE','RRS4'  X
               RPI-817
         JAS   R11,VER1128
         USING *,R11
INS1128  CLGIBE R1,I2,S4
HEX1128  DC    X'EC18D004FFFD'
NUM1128  DC    P'1128'
*MCALL #=  2295 LV= 2 VER1128  RT1   CCE,INS1128,HEX1128
VER1128  DS    0H
         CLC   INS1128,HEX1128
RT1_TEST1158     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1158
         LTORG 
RT1_CCE1158     DS 0H
*MEXIT #=  2295 LV= 2 RT1
*MEXIT #=  2294 LV= 1 ZOSOP
*MCALL #=  2296 LV= 1  ZOSOP 'ECFD2','CLGIB if Equal','CLGIBH','RRS4'  X
               RPI-817
         JAS   R11,VER1129
         USING *,R11
INS1129  CLGIBH R1,I2,S4
HEX1129  DC    X'EC12D004FFFD'
NUM1129  DC    P'1129'
*MCALL #=  2297 LV= 2 VER1129  RT1   CCE,INS1129,HEX1129
VER1129  DS    0H
         CLC   INS1129,HEX1129
RT1_TEST1159     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1159
         LTORG 
RT1_CCE1159     DS 0H
*MEXIT #=  2297 LV= 2 RT1
*MEXIT #=  2296 LV= 1 ZOSOP
*MCALL #=  2298 LV= 1  ZOSOP 'ECFD4','CLGIB if Low','CLGIBL','RRS4'  RPX
               I-817
         JAS   R11,VER1130
         USING *,R11
INS1130  CLGIBL R1,I2,S4
HEX1130  DC    X'EC14D004FFFD'
NUM1130  DC    P'1130'
*MCALL #=  2299 LV= 2 VER1130  RT1   CCE,INS1130,HEX1130
VER1130  DS    0H
         CLC   INS1130,HEX1130
RT1_TEST1160     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1160
         LTORG 
RT1_CCE1160     DS 0H
*MEXIT #=  2299 LV= 2 RT1
*MEXIT #=  2298 LV= 1 ZOSOP
*MCALL #=  2300 LV= 1  ZOSOP 'ECFD6','CLGIB if Not Equal','CLGIBNE','RRX
               S4'  RPI-817
         JAS   R11,VER1131
         USING *,R11
INS1131  CLGIBNE R1,I2,S4
HEX1131  DC    X'EC16D004FFFD'
NUM1131  DC    P'1131'
*MCALL #=  2301 LV= 2 VER1131  RT1   CCE,INS1131,HEX1131
VER1131  DS    0H
         CLC   INS1131,HEX1131
RT1_TEST1161     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1161
         LTORG 
RT1_CCE1161     DS 0H
*MEXIT #=  2301 LV= 2 RT1
*MEXIT #=  2300 LV= 1 ZOSOP
*MCALL #=  2302 LV= 1  ZOSOP 'ECFDC','CLGIB if Not High','CLGIBNH','RRSX
               4'  RPI-817
         JAS   R11,VER1132
         USING *,R11
INS1132  CLGIBNH R1,I2,S4
HEX1132  DC    X'EC1CD004FFFD'
NUM1132  DC    P'1132'
*MCALL #=  2303 LV= 2 VER1132  RT1   CCE,INS1132,HEX1132
VER1132  DS    0H
         CLC   INS1132,HEX1132
RT1_TEST1162     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1162
         LTORG 
RT1_CCE1162     DS 0H
*MEXIT #=  2303 LV= 2 RT1
*MEXIT #=  2302 LV= 1 ZOSOP
*MCALL #=  2304 LV= 1  ZOSOP 'ECFDA','CLGIB if Not High','CLGIBNL','RRSX
               4'  RPI-817
         JAS   R11,VER1133
         USING *,R11
INS1133  CLGIBNL R1,I2,S4
HEX1133  DC    X'EC1AD004FFFD'
NUM1133  DC    P'1133'
*MCALL #=  2305 LV= 2 VER1133  RT1   CCE,INS1133,HEX1133
VER1133  DS    0H
         CLC   INS1133,HEX1133
RT1_TEST1163     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1163
         LTORG 
RT1_CCE1163     DS 0H
*MEXIT #=  2305 LV= 2 RT1
*MEXIT #=  2304 LV= 1 ZOSOP
*MCALL #=  2306 LV= 1  ZOSOP 'ECFE','Compare Immediate and Branch','CIBX
               ','RRS3'  RPI-817
         JAS   R11,VER1134
         USING *,R11
INS1134  CIB  R1,I2,M3,S4
HEX1134  DC    X'EC13D004FFFE'
NUM1134  DC    P'1134'
*MCALL #=  2307 LV= 2 VER1134  RT1   CCE,INS1134,HEX1134
VER1134  DS    0H
         CLC   INS1134,HEX1134
RT1_TEST1164     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1164
         LTORG 
RT1_CCE1164     DS 0H
*MEXIT #=  2307 LV= 2 RT1
*MEXIT #=  2306 LV= 1 ZOSOP
*MCALL #=  2308 LV= 1  ZOSOP 'ECFE8','CIB if Equal','CIBE','RRS4'  RPI-X
               817
         JAS   R11,VER1135
         USING *,R11
INS1135  CIBE R1,I2,S4
HEX1135  DC    X'EC18D004FFFE'
NUM1135  DC    P'1135'
*MCALL #=  2309 LV= 2 VER1135  RT1   CCE,INS1135,HEX1135
VER1135  DS    0H
         CLC   INS1135,HEX1135
RT1_TEST1165     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1165
         LTORG 
RT1_CCE1165     DS 0H
*MEXIT #=  2309 LV= 2 RT1
*MEXIT #=  2308 LV= 1 ZOSOP
*MCALL #=  2310 LV= 1  ZOSOP 'ECFE2','CIB if High','CIBH','RRS4'  RPI-8X
               17
         JAS   R11,VER1136
         USING *,R11
INS1136  CIBH R1,I2,S4
HEX1136  DC    X'EC12D004FFFE'
NUM1136  DC    P'1136'
*MCALL #=  2311 LV= 2 VER1136  RT1   CCE,INS1136,HEX1136
VER1136  DS    0H
         CLC   INS1136,HEX1136
RT1_TEST1166     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1166
         LTORG 
RT1_CCE1166     DS 0H
*MEXIT #=  2311 LV= 2 RT1
*MEXIT #=  2310 LV= 1 ZOSOP
*MCALL #=  2312 LV= 1  ZOSOP 'ECFE4','CIB if Low','CIBL','RRS4'  RPI-81X
               7
         JAS   R11,VER1137
         USING *,R11
INS1137  CIBL R1,I2,S4
HEX1137  DC    X'EC14D004FFFE'
NUM1137  DC    P'1137'
*MCALL #=  2313 LV= 2 VER1137  RT1   CCE,INS1137,HEX1137
VER1137  DS    0H
         CLC   INS1137,HEX1137
RT1_TEST1167     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1167
         LTORG 
RT1_CCE1167     DS 0H
*MEXIT #=  2313 LV= 2 RT1
*MEXIT #=  2312 LV= 1 ZOSOP
*MCALL #=  2314 LV= 1  ZOSOP 'ECFE6','CIB if Not Equal','CIBNE','RRS4' X
                RPI-817
         JAS   R11,VER1138
         USING *,R11
INS1138  CIBNE R1,I2,S4
HEX1138  DC    X'EC16D004FFFE'
NUM1138  DC    P'1138'
*MCALL #=  2315 LV= 2 VER1138  RT1   CCE,INS1138,HEX1138
VER1138  DS    0H
         CLC   INS1138,HEX1138
RT1_TEST1168     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1168
         LTORG 
RT1_CCE1168     DS 0H
*MEXIT #=  2315 LV= 2 RT1
*MEXIT #=  2314 LV= 1 ZOSOP
*MCALL #=  2316 LV= 1  ZOSOP 'ECFEC','CIB if Not High','CIBNH','RRS4'  X
               RPI-817
         JAS   R11,VER1139
         USING *,R11
INS1139  CIBNH R1,I2,S4
HEX1139  DC    X'EC1CD004FFFE'
NUM1139  DC    P'1139'
*MCALL #=  2317 LV= 2 VER1139  RT1   CCE,INS1139,HEX1139
VER1139  DS    0H
         CLC   INS1139,HEX1139
RT1_TEST1169     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1169
         LTORG 
RT1_CCE1169     DS 0H
*MEXIT #=  2317 LV= 2 RT1
*MEXIT #=  2316 LV= 1 ZOSOP
*MCALL #=  2318 LV= 1  ZOSOP 'ECFEA','CIB if Not Low','CIBNL','RRS4'  RX
               PI-817
         JAS   R11,VER1140
         USING *,R11
INS1140  CIBNL R1,I2,S4
HEX1140  DC    X'EC1AD004FFFE'
NUM1140  DC    P'1140'
*MCALL #=  2319 LV= 2 VER1140  RT1   CCE,INS1140,HEX1140
VER1140  DS    0H
         CLC   INS1140,HEX1140
RT1_TEST1170     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1170
         LTORG 
RT1_CCE1170     DS 0H
*MEXIT #=  2319 LV= 2 RT1
*MEXIT #=  2318 LV= 1 ZOSOP
*MCALL #=  2320 LV= 1  ZOSOP 'ECFF','Compare Logical Imm and Branch','CX
               LIB','RRS3'  RPI-817
         JAS   R11,VER1141
         USING *,R11
INS1141  CLIB R1,I2,M3,S4
HEX1141  DC    X'EC13D004FFFF'
NUM1141  DC    P'1141'
*MCALL #=  2321 LV= 2 VER1141  RT1   CCE,INS1141,HEX1141
VER1141  DS    0H
         CLC   INS1141,HEX1141
RT1_TEST1171     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1171
         LTORG 
RT1_CCE1171     DS 0H
*MEXIT #=  2321 LV= 2 RT1
*MEXIT #=  2320 LV= 1 ZOSOP
*MCALL #=  2322 LV= 1  ZOSOP 'ECFF8','CLIB if Equal','CLIBE','RRS4'  RPX
               I-817
         JAS   R11,VER1142
         USING *,R11
INS1142  CLIBE R1,I2,S4
HEX1142  DC    X'EC18D004FFFF'
NUM1142  DC    P'1142'
*MCALL #=  2323 LV= 2 VER1142  RT1   CCE,INS1142,HEX1142
VER1142  DS    0H
         CLC   INS1142,HEX1142
RT1_TEST1172     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1172
         LTORG 
RT1_CCE1172     DS 0H
*MEXIT #=  2323 LV= 2 RT1
*MEXIT #=  2322 LV= 1 ZOSOP
*MCALL #=  2324 LV= 1  ZOSOP 'ECFF2','CLIB if High','CLIBH','RRS4'  RPIX
               -817
         JAS   R11,VER1143
         USING *,R11
INS1143  CLIBH R1,I2,S4
HEX1143  DC    X'EC12D004FFFF'
NUM1143  DC    P'1143'
*MCALL #=  2325 LV= 2 VER1143  RT1   CCE,INS1143,HEX1143
VER1143  DS    0H
         CLC   INS1143,HEX1143
RT1_TEST1173     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1173
         LTORG 
RT1_CCE1173     DS 0H
*MEXIT #=  2325 LV= 2 RT1
*MEXIT #=  2324 LV= 1 ZOSOP
*MCALL #=  2326 LV= 1  ZOSOP 'ECFF4','CLIB if Low','CLIBL','RRS4'  RPI-X
               817
         JAS   R11,VER1144
         USING *,R11
INS1144  CLIBL R1,I2,S4
HEX1144  DC    X'EC14D004FFFF'
NUM1144  DC    P'1144'
*MCALL #=  2327 LV= 2 VER1144  RT1   CCE,INS1144,HEX1144
VER1144  DS    0H
         CLC   INS1144,HEX1144
RT1_TEST1174     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1174
         LTORG 
RT1_CCE1174     DS 0H
*MEXIT #=  2327 LV= 2 RT1
*MEXIT #=  2326 LV= 1 ZOSOP
*MCALL #=  2328 LV= 1  ZOSOP 'ECFF6','CLIB if Not Equal','CLIBNE','RRS4X
               '  RPI-817
         JAS   R11,VER1145
         USING *,R11
INS1145  CLIBNE R1,I2,S4
HEX1145  DC    X'EC16D004FFFF'
NUM1145  DC    P'1145'
*MCALL #=  2329 LV= 2 VER1145  RT1   CCE,INS1145,HEX1145
VER1145  DS    0H
         CLC   INS1145,HEX1145
RT1_TEST1175     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1175
         LTORG 
RT1_CCE1175     DS 0H
*MEXIT #=  2329 LV= 2 RT1
*MEXIT #=  2328 LV= 1 ZOSOP
*MCALL #=  2330 LV= 1  ZOSOP 'ECFFC','CLIB if Not High','CLIBNH','RRS4'X
                 RPI-817
         JAS   R11,VER1146
         USING *,R11
INS1146  CLIBNH R1,I2,S4
HEX1146  DC    X'EC1CD004FFFF'
NUM1146  DC    P'1146'
*MCALL #=  2331 LV= 2 VER1146  RT1   CCE,INS1146,HEX1146
VER1146  DS    0H
         CLC   INS1146,HEX1146
RT1_TEST1176     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1176
         LTORG 
RT1_CCE1176     DS 0H
*MEXIT #=  2331 LV= 2 RT1
*MEXIT #=  2330 LV= 1 ZOSOP
*MCALL #=  2332 LV= 1  ZOSOP 'ECFFA','CLIB if Not Low','CLIBNL','RRS4' X
                RPI-817
         JAS   R11,VER1147
         USING *,R11
INS1147  CLIBNL R1,I2,S4
HEX1147  DC    X'EC1AD004FFFF'
NUM1147  DC    P'1147'
*MCALL #=  2333 LV= 2 VER1147  RT1   CCE,INS1147,HEX1147
VER1147  DS    0H
         CLC   INS1147,HEX1147
RT1_TEST1177     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1177
         LTORG 
RT1_CCE1177     DS 0H
*MEXIT #=  2333 LV= 2 RT1
*MEXIT #=  2332 LV= 1 ZOSOP
*MCALL #=  2334 LV= 1  ZOSOP 'ED04','LOAD LENGTHENED (short to long BFPX
               ) ','LDEB ','RXE '
         JAS   R11,VER1148
         USING *,R11
INS1148  LDEB  R1,S2(X4)
HEX1148  DC    X'ED14D0020004'
NUM1148  DC    P'1148'
*MCALL #=  2335 LV= 2 VER1148  RT1   CCE,INS1148,HEX1148
VER1148  DS    0H
         CLC   INS1148,HEX1148
RT1_TEST1178     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1178
         LTORG 
RT1_CCE1178     DS 0H
*MEXIT #=  2335 LV= 2 RT1
*MEXIT #=  2334 LV= 1 ZOSOP
*MCALL #=  2336 LV= 1  ZOSOP 'ED05','LOAD LENGTHENED (long to ext. BFP)X
                ','LXDB ','RXE '
         JAS   R11,VER1149
         USING *,R11
INS1149  LXDB  R1,S2(X4)
HEX1149  DC    X'ED14D0020005'
NUM1149  DC    P'1149'
*MCALL #=  2337 LV= 2 VER1149  RT1   CCE,INS1149,HEX1149
VER1149  DS    0H
         CLC   INS1149,HEX1149
RT1_TEST1179     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1179
         LTORG 
RT1_CCE1179     DS 0H
*MEXIT #=  2337 LV= 2 RT1
*MEXIT #=  2336 LV= 1 ZOSOP
*MCALL #=  2338 LV= 1  ZOSOP 'ED06','LOAD LENGTHENED (short to ext. BFPX
               ) ','LXEB ','RXE '
         JAS   R11,VER1150
         USING *,R11
INS1150  LXEB  R1,S2(X4)
HEX1150  DC    X'ED14D0020006'
NUM1150  DC    P'1150'
*MCALL #=  2339 LV= 2 VER1150  RT1   CCE,INS1150,HEX1150
VER1150  DS    0H
         CLC   INS1150,HEX1150
RT1_TEST1180     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1180
         LTORG 
RT1_CCE1180     DS 0H
*MEXIT #=  2339 LV= 2 RT1
*MEXIT #=  2338 LV= 1 ZOSOP
*MCALL #=  2340 LV= 1  ZOSOP 'ED07','MULTIPLY (long to extended BFP) ',X
               'MXDB ','RXE '
         JAS   R11,VER1151
         USING *,R11
INS1151  MXDB  R1,S2(X4)
HEX1151  DC    X'ED14D0020007'
NUM1151  DC    P'1151'
*MCALL #=  2341 LV= 2 VER1151  RT1   CCE,INS1151,HEX1151
VER1151  DS    0H
         CLC   INS1151,HEX1151
RT1_TEST1181     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1181
         LTORG 
RT1_CCE1181     DS 0H
*MEXIT #=  2341 LV= 2 RT1
*MEXIT #=  2340 LV= 1 ZOSOP
*MCALL #=  2342 LV= 1  ZOSOP 'ED08','COMPARE AND SIGNAL (short BFP) ','X
               KEB ','RXE C '
         JAS   R11,VER1152
         USING *,R11
INS1152  KEB  R1,S2(X4)
HEX1152  DC    X'ED14D0020008'
NUM1152  DC    P'1152'
*MCALL #=  2343 LV= 2 VER1152  RT1   CCE,INS1152,HEX1152
VER1152  DS    0H
         CLC   INS1152,HEX1152
RT1_TEST1182     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1182
         LTORG 
RT1_CCE1182     DS 0H
*MEXIT #=  2343 LV= 2 RT1
*MEXIT #=  2342 LV= 1 ZOSOP
*MCALL #=  2344 LV= 1  ZOSOP 'ED09','COMPARE (short BFP) ','CEB ','RXE X
               C '
         JAS   R11,VER1153
         USING *,R11
INS1153  CEB  R1,S2(X4)
HEX1153  DC    X'ED14D0020009'
NUM1153  DC    P'1153'
*MCALL #=  2345 LV= 2 VER1153  RT1   CCE,INS1153,HEX1153
VER1153  DS    0H
         CLC   INS1153,HEX1153
RT1_TEST1183     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1183
         LTORG 
RT1_CCE1183     DS 0H
*MEXIT #=  2345 LV= 2 RT1
*MEXIT #=  2344 LV= 1 ZOSOP
*MCALL #=  2346 LV= 1  ZOSOP 'ED0A','ADD (short BFP) ','AEB ','RXE C '
         JAS   R11,VER1154
         USING *,R11
INS1154  AEB  R1,S2(X4)
HEX1154  DC    X'ED14D002000A'
NUM1154  DC    P'1154'
*MCALL #=  2347 LV= 2 VER1154  RT1   CCE,INS1154,HEX1154
VER1154  DS    0H
         CLC   INS1154,HEX1154
RT1_TEST1184     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1184
         LTORG 
RT1_CCE1184     DS 0H
*MEXIT #=  2347 LV= 2 RT1
*MEXIT #=  2346 LV= 1 ZOSOP
*MCALL #=  2348 LV= 1  ZOSOP 'ED0B','SUBTRACT (short BFP) ','SEB ','RXEX
                C '
         JAS   R11,VER1155
         USING *,R11
INS1155  SEB  R1,S2(X4)
HEX1155  DC    X'ED14D002000B'
NUM1155  DC    P'1155'
*MCALL #=  2349 LV= 2 VER1155  RT1   CCE,INS1155,HEX1155
VER1155  DS    0H
         CLC   INS1155,HEX1155
RT1_TEST1185     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1185
         LTORG 
RT1_CCE1185     DS 0H
*MEXIT #=  2349 LV= 2 RT1
*MEXIT #=  2348 LV= 1 ZOSOP
*MCALL #=  2350 LV= 1  ZOSOP 'ED0C','MULTIPLY (short to long BFP) ','MDX
               EB ','RXE '
         JAS   R11,VER1156
         USING *,R11
INS1156  MDEB  R1,S2(X4)
HEX1156  DC    X'ED14D002000C'
NUM1156  DC    P'1156'
*MCALL #=  2351 LV= 2 VER1156  RT1   CCE,INS1156,HEX1156
VER1156  DS    0H
         CLC   INS1156,HEX1156
RT1_TEST1186     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1186
         LTORG 
RT1_CCE1186     DS 0H
*MEXIT #=  2351 LV= 2 RT1
*MEXIT #=  2350 LV= 1 ZOSOP
*MCALL #=  2352 LV= 1  ZOSOP 'ED0D','DIVIDE (short BFP) ','DEB ','RXE '
         JAS   R11,VER1157
         USING *,R11
INS1157  DEB  R1,S2(X4)
HEX1157  DC    X'ED14D002000D'
NUM1157  DC    P'1157'
*MCALL #=  2353 LV= 2 VER1157  RT1   CCE,INS1157,HEX1157
VER1157  DS    0H
         CLC   INS1157,HEX1157
RT1_TEST1187     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1187
         LTORG 
RT1_CCE1187     DS 0H
*MEXIT #=  2353 LV= 2 RT1
*MEXIT #=  2352 LV= 1 ZOSOP
*MCALL #=  2354 LV= 1  ZOSOP 'ED0E','MULTIPLY AND ADD (short BFP) ','MAX
               EB ','RXF '
         JAS   R11,VER1158
         USING *,R11
INS1158  MAEB  R1,R3,S2(X4)
HEX1158  DC    X'ED34D002100E'
NUM1158  DC    P'1158'
*MCALL #=  2355 LV= 2 VER1158  RT1   CCE,INS1158,HEX1158
VER1158  DS    0H
         CLC   INS1158,HEX1158
RT1_TEST1188     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1188
         LTORG 
RT1_CCE1188     DS 0H
*MEXIT #=  2355 LV= 2 RT1
*MEXIT #=  2354 LV= 1 ZOSOP
*MCALL #=  2356 LV= 1  ZOSOP 'ED0F','MULTIPLY AND SUBTRACT (short BFP) X
               ','MSEB ','RXF '
         JAS   R11,VER1159
         USING *,R11
INS1159  MSEB  R1,R3,S2(X4)
HEX1159  DC    X'ED34D002100F'
NUM1159  DC    P'1159'
*MCALL #=  2357 LV= 2 VER1159  RT1   CCE,INS1159,HEX1159
VER1159  DS    0H
         CLC   INS1159,HEX1159
RT1_TEST1189     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1189
         LTORG 
RT1_CCE1189     DS 0H
*MEXIT #=  2357 LV= 2 RT1
*MEXIT #=  2356 LV= 1 ZOSOP
*MCALL #=  2358 LV= 1  ZOSOP 'ED10','TEST DATA CLASS (short BFP) ','TCEX
               B ','RXE C '
         JAS   R11,VER1160
         USING *,R11
INS1160  TCEB  R1,S2(X4)
HEX1160  DC    X'ED14D0020010'
NUM1160  DC    P'1160'
*MCALL #=  2359 LV= 2 VER1160  RT1   CCE,INS1160,HEX1160
VER1160  DS    0H
         CLC   INS1160,HEX1160
RT1_TEST1190     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1190
         LTORG 
RT1_CCE1190     DS 0H
*MEXIT #=  2359 LV= 2 RT1
*MEXIT #=  2358 LV= 1 ZOSOP
*MCALL #=  2360 LV= 1  ZOSOP 'ED11','TEST DATA CLASS (long BFP) ','TCDBX
                ','RXE C '
         JAS   R11,VER1161
         USING *,R11
INS1161  TCDB  R1,S2(X4)
HEX1161  DC    X'ED14D0020011'
NUM1161  DC    P'1161'
*MCALL #=  2361 LV= 2 VER1161  RT1   CCE,INS1161,HEX1161
VER1161  DS    0H
         CLC   INS1161,HEX1161
RT1_TEST1191     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1191
         LTORG 
RT1_CCE1191     DS 0H
*MEXIT #=  2361 LV= 2 RT1
*MEXIT #=  2360 LV= 1 ZOSOP
*MCALL #=  2362 LV= 1  ZOSOP 'ED12','TEST DATA CLASS (extended BFP) ','X
               TCXB ','RXE C '
         JAS   R11,VER1162
         USING *,R11
INS1162  TCXB  R1,S2(X4)
HEX1162  DC    X'ED14D0020012'
NUM1162  DC    P'1162'
*MCALL #=  2363 LV= 2 VER1162  RT1   CCE,INS1162,HEX1162
VER1162  DS    0H
         CLC   INS1162,HEX1162
RT1_TEST1192     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1192
         LTORG 
RT1_CCE1192     DS 0H
*MEXIT #=  2363 LV= 2 RT1
*MEXIT #=  2362 LV= 1 ZOSOP
*MCALL #=  2364 LV= 1  ZOSOP 'ED14','SQUARE ROOT (short BFP) ','SQEB ',X
               'RXE '
         JAS   R11,VER1163
         USING *,R11
INS1163  SQEB  R1,S2(X4)
HEX1163  DC    X'ED14D0020014'
NUM1163  DC    P'1163'
*MCALL #=  2365 LV= 2 VER1163  RT1   CCE,INS1163,HEX1163
VER1163  DS    0H
         CLC   INS1163,HEX1163
RT1_TEST1193     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1193
         LTORG 
RT1_CCE1193     DS 0H
*MEXIT #=  2365 LV= 2 RT1
*MEXIT #=  2364 LV= 1 ZOSOP
*MCALL #=  2366 LV= 1  ZOSOP 'ED15','SQUARE ROOT (long BFP) ','SQDB ','X
               RXE '
         JAS   R11,VER1164
         USING *,R11
INS1164  SQDB  R1,S2(X4)
HEX1164  DC    X'ED14D0020015'
NUM1164  DC    P'1164'
*MCALL #=  2367 LV= 2 VER1164  RT1   CCE,INS1164,HEX1164
VER1164  DS    0H
         CLC   INS1164,HEX1164
RT1_TEST1194     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1194
         LTORG 
RT1_CCE1194     DS 0H
*MEXIT #=  2367 LV= 2 RT1
*MEXIT #=  2366 LV= 1 ZOSOP
*MCALL #=  2368 LV= 1  ZOSOP 'ED17','MULTIPLY (short BFP) ','MEEB ','RXX
               E '
         JAS   R11,VER1165
         USING *,R11
INS1165  MEEB  R1,S2(X4)
HEX1165  DC    X'ED14D0020017'
NUM1165  DC    P'1165'
*MCALL #=  2369 LV= 2 VER1165  RT1   CCE,INS1165,HEX1165
VER1165  DS    0H
         CLC   INS1165,HEX1165
RT1_TEST1195     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1195
         LTORG 
RT1_CCE1195     DS 0H
*MEXIT #=  2369 LV= 2 RT1
*MEXIT #=  2368 LV= 1 ZOSOP
*MCALL #=  2370 LV= 1  ZOSOP 'ED18','COMPARE AND SIGNAL (long BFP) ','KX
               DB ','RXE C '
         JAS   R11,VER1166
         USING *,R11
INS1166  KDB  R1,S2(X4)
HEX1166  DC    X'ED14D0020018'
NUM1166  DC    P'1166'
*MCALL #=  2371 LV= 2 VER1166  RT1   CCE,INS1166,HEX1166
VER1166  DS    0H
         CLC   INS1166,HEX1166
RT1_TEST1196     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1196
         LTORG 
RT1_CCE1196     DS 0H
*MEXIT #=  2371 LV= 2 RT1
*MEXIT #=  2370 LV= 1 ZOSOP
*MCALL #=  2372 LV= 1  ZOSOP 'ED19','COMPARE (long BFP) ','CDB ','RXE CX
                '
         JAS   R11,VER1167
         USING *,R11
INS1167  CDB  R1,S2(X4)
HEX1167  DC    X'ED14D0020019'
NUM1167  DC    P'1167'
*MCALL #=  2373 LV= 2 VER1167  RT1   CCE,INS1167,HEX1167
VER1167  DS    0H
         CLC   INS1167,HEX1167
RT1_TEST1197     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1197
         LTORG 
RT1_CCE1197     DS 0H
*MEXIT #=  2373 LV= 2 RT1
*MEXIT #=  2372 LV= 1 ZOSOP
*MCALL #=  2374 LV= 1  ZOSOP 'ED1A','ADD (long BFP) ','ADB ','RXE C '
         JAS   R11,VER1168
         USING *,R11
INS1168  ADB  R1,S2(X4)
HEX1168  DC    X'ED14D002001A'
NUM1168  DC    P'1168'
*MCALL #=  2375 LV= 2 VER1168  RT1   CCE,INS1168,HEX1168
VER1168  DS    0H
         CLC   INS1168,HEX1168
RT1_TEST1198     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1198
         LTORG 
RT1_CCE1198     DS 0H
*MEXIT #=  2375 LV= 2 RT1
*MEXIT #=  2374 LV= 1 ZOSOP
*MCALL #=  2376 LV= 1  ZOSOP 'ED1B','SUBTRACT (long BFP) ','SDB ','RXE X
               C '
         JAS   R11,VER1169
         USING *,R11
INS1169  SDB  R1,S2(X4)
HEX1169  DC    X'ED14D002001B'
NUM1169  DC    P'1169'
*MCALL #=  2377 LV= 2 VER1169  RT1   CCE,INS1169,HEX1169
VER1169  DS    0H
         CLC   INS1169,HEX1169
RT1_TEST1199     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1199
         LTORG 
RT1_CCE1199     DS 0H
*MEXIT #=  2377 LV= 2 RT1
*MEXIT #=  2376 LV= 1 ZOSOP
*MCALL #=  2378 LV= 1  ZOSOP 'ED1C','MULTIPLY (long BFP) ','MDB ','RXE X
               '
         JAS   R11,VER1170
         USING *,R11
INS1170  MDB  R1,S2(X4)
HEX1170  DC    X'ED14D002001C'
NUM1170  DC    P'1170'
*MCALL #=  2379 LV= 2 VER1170  RT1   CCE,INS1170,HEX1170
VER1170  DS    0H
         CLC   INS1170,HEX1170
RT1_TEST1200     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1200
         LTORG 
RT1_CCE1200     DS 0H
*MEXIT #=  2379 LV= 2 RT1
*MEXIT #=  2378 LV= 1 ZOSOP
*MCALL #=  2380 LV= 1  ZOSOP 'ED1D','DIVIDE (long BFP) ','DDB ','RXE '
         JAS   R11,VER1171
         USING *,R11
INS1171  DDB  R1,S2(X4)
HEX1171  DC    X'ED14D002001D'
NUM1171  DC    P'1171'
*MCALL #=  2381 LV= 2 VER1171  RT1   CCE,INS1171,HEX1171
VER1171  DS    0H
         CLC   INS1171,HEX1171
RT1_TEST1201     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1201
         LTORG 
RT1_CCE1201     DS 0H
*MEXIT #=  2381 LV= 2 RT1
*MEXIT #=  2380 LV= 1 ZOSOP
*MCALL #=  2382 LV= 1  ZOSOP 'ED1E','MULTIPLY AND ADD (long BFP) ','MADX
               B ','RXF '
         JAS   R11,VER1172
         USING *,R11
INS1172  MADB  R1,R3,S2(X4)
HEX1172  DC    X'ED34D002101E'
NUM1172  DC    P'1172'
*MCALL #=  2383 LV= 2 VER1172  RT1   CCE,INS1172,HEX1172
VER1172  DS    0H
         CLC   INS1172,HEX1172
RT1_TEST1202     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1202
         LTORG 
RT1_CCE1202     DS 0H
*MEXIT #=  2383 LV= 2 RT1
*MEXIT #=  2382 LV= 1 ZOSOP
*MCALL #=  2384 LV= 1  ZOSOP 'ED1F','MULTIPLY AND SUBTRACT (long BFP) 'X
               ,'MSDB ','RXF '
         JAS   R11,VER1173
         USING *,R11
INS1173  MSDB  R1,R3,S2(X4)
HEX1173  DC    X'ED34D002101F'
NUM1173  DC    P'1173'
*MCALL #=  2385 LV= 2 VER1173  RT1   CCE,INS1173,HEX1173
VER1173  DS    0H
         CLC   INS1173,HEX1173
RT1_TEST1203     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1203
         LTORG 
RT1_CCE1203     DS 0H
*MEXIT #=  2385 LV= 2 RT1
*MEXIT #=  2384 LV= 1 ZOSOP
*MCALL #=  2386 LV= 1  ZOSOP 'ED24','LOAD LENGTHENED (short to long HFPX
               ) ','LDE ','RXE '
         JAS   R11,VER1174
         USING *,R11
INS1174  LDE  R1,S2(X4)
HEX1174  DC    X'ED14D0020024'
NUM1174  DC    P'1174'
*MCALL #=  2387 LV= 2 VER1174  RT1   CCE,INS1174,HEX1174
VER1174  DS    0H
         CLC   INS1174,HEX1174
RT1_TEST1204     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1204
         LTORG 
RT1_CCE1204     DS 0H
*MEXIT #=  2387 LV= 2 RT1
*MEXIT #=  2386 LV= 1 ZOSOP
*MCALL #=  2388 LV= 1  ZOSOP 'ED25','LOAD LENGTHENED (long to ext. HFP)X
                ','LXD ','RXE '
         JAS   R11,VER1175
         USING *,R11
INS1175  LXD  R1,S2(X4)
HEX1175  DC    X'ED14D0020025'
NUM1175  DC    P'1175'
*MCALL #=  2389 LV= 2 VER1175  RT1   CCE,INS1175,HEX1175
VER1175  DS    0H
         CLC   INS1175,HEX1175
RT1_TEST1205     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1205
         LTORG 
RT1_CCE1205     DS 0H
*MEXIT #=  2389 LV= 2 RT1
*MEXIT #=  2388 LV= 1 ZOSOP
*MCALL #=  2390 LV= 1  ZOSOP 'ED26','LOAD LENGTHENED (short to ext. HFPX
               ) ','LXE ','RXE '
         JAS   R11,VER1176
         USING *,R11
INS1176  LXE  R1,S2(X4)
HEX1176  DC    X'ED14D0020026'
NUM1176  DC    P'1176'
*MCALL #=  2391 LV= 2 VER1176  RT1   CCE,INS1176,HEX1176
VER1176  DS    0H
         CLC   INS1176,HEX1176
RT1_TEST1206     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1206
         LTORG 
RT1_CCE1206     DS 0H
*MEXIT #=  2391 LV= 2 RT1
*MEXIT #=  2390 LV= 1 ZOSOP
*MCALL #=  2392 LV= 1  ZOSOP 'ED2E','MULTIPLY AND ADD (short HFP) ','MAX
               E ','RXF HM'
         JAS   R11,VER1177
         USING *,R11
INS1177  MAE  R1,R3,S2(X4)
HEX1177  DC    X'ED34D002102E'
NUM1177  DC    P'1177'
*MCALL #=  2393 LV= 2 VER1177  RT1   CCE,INS1177,HEX1177
VER1177  DS    0H
         CLC   INS1177,HEX1177
RT1_TEST1207     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1207
         LTORG 
RT1_CCE1207     DS 0H
*MEXIT #=  2393 LV= 2 RT1
*MEXIT #=  2392 LV= 1 ZOSOP
*MCALL #=  2394 LV= 1  ZOSOP 'ED2F','MULTIPLY AND SUBTRACT (short HFP) X
               ','MSE ','RXF HM'
         JAS   R11,VER1178
         USING *,R11
INS1178  MSE  R1,R3,S2(X4)
HEX1178  DC    X'ED34D002102F'
NUM1178  DC    P'1178'
*MCALL #=  2395 LV= 2 VER1178  RT1   CCE,INS1178,HEX1178
VER1178  DS    0H
         CLC   INS1178,HEX1178
RT1_TEST1208     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1208
         LTORG 
RT1_CCE1208     DS 0H
*MEXIT #=  2395 LV= 2 RT1
*MEXIT #=  2394 LV= 1 ZOSOP
*MCALL #=  2396 LV= 1  ZOSOP 'ED34','SQUARE ROOT (short HFP) ','SQE ','X
               RXE '
         JAS   R11,VER1179
         USING *,R11
INS1179  SQE  R1,S2(X4)
HEX1179  DC    X'ED14D0020034'
NUM1179  DC    P'1179'
*MCALL #=  2397 LV= 2 VER1179  RT1   CCE,INS1179,HEX1179
VER1179  DS    0H
         CLC   INS1179,HEX1179
RT1_TEST1209     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1209
         LTORG 
RT1_CCE1209     DS 0H
*MEXIT #=  2397 LV= 2 RT1
*MEXIT #=  2396 LV= 1 ZOSOP
*MCALL #=  2398 LV= 1  ZOSOP 'ED35','SQUARE ROOT (long HFP) ','SQD ','RX
               XE '
         JAS   R11,VER1180
         USING *,R11
INS1180  SQD  R1,S2(X4)
HEX1180  DC    X'ED14D0020035'
NUM1180  DC    P'1180'
*MCALL #=  2399 LV= 2 VER1180  RT1   CCE,INS1180,HEX1180
VER1180  DS    0H
         CLC   INS1180,HEX1180
RT1_TEST1210     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1210
         LTORG 
RT1_CCE1210     DS 0H
*MEXIT #=  2399 LV= 2 RT1
*MEXIT #=  2398 LV= 1 ZOSOP
*MCALL #=  2400 LV= 1  ZOSOP 'ED37','MULTIPLY (short HFP) ','MEE ','RXEX
                '
         JAS   R11,VER1181
         USING *,R11
INS1181  MEE  R1,S2(X4)
HEX1181  DC    X'ED14D0020037'
NUM1181  DC    P'1181'
*MCALL #=  2401 LV= 2 VER1181  RT1   CCE,INS1181,HEX1181
VER1181  DS    0H
         CLC   INS1181,HEX1181
RT1_TEST1211     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1211
         LTORG 
RT1_CCE1211     DS 0H
*MEXIT #=  2401 LV= 2 RT1
*MEXIT #=  2400 LV= 1 ZOSOP
*MCALL #=  2402 LV= 1  ZOSOP 'ED38','MULTIPLY AND ADD U (L > X low  HFPX
               )','MAYL','RXF',Z9
         JAS   R11,VER1182
         USING *,R11
INS1182  MAYL R1,R3,S2(X4)
HEX1182  DC    X'ED34D0021038'
NUM1182  DC    P'1182'
*MCALL #=  2403 LV= 2 VER1182  RT1   CCE,INS1182,HEX1182
VER1182  DS    0H
         CLC   INS1182,HEX1182
RT1_TEST1212     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1212
         LTORG 
RT1_CCE1212     DS 0H
*MEXIT #=  2403 LV= 2 RT1
*MEXIT #=  2402 LV= 1 ZOSOP
*MCALL #=  2404 LV= 1  ZOSOP 'ED39','MULTIPLY U (L > X low HFP)','MYL',X
               'RXF',Z9
         JAS   R11,VER1183
         USING *,R11
INS1183  MYL  R1,R3,S2(X4)
HEX1183  DC    X'ED34D0021039'
NUM1183  DC    P'1183'
*MCALL #=  2405 LV= 2 VER1183  RT1   CCE,INS1183,HEX1183
VER1183  DS    0H
         CLC   INS1183,HEX1183
RT1_TEST1213     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1213
         LTORG 
RT1_CCE1213     DS 0H
*MEXIT #=  2405 LV= 2 RT1
*MEXIT #=  2404 LV= 1 ZOSOP
*MCALL #=  2406 LV= 1  ZOSOP 'ED3A','MULTIPLY AND ADD U (L > X HFP)','MX
               AY','RXF',Z9
         JAS   R11,VER1184
         USING *,R11
INS1184  MAY  R1,R3,S2(X4)
HEX1184  DC    X'ED34D002103A'
NUM1184  DC    P'1184'
*MCALL #=  2407 LV= 2 VER1184  RT1   CCE,INS1184,HEX1184
VER1184  DS    0H
         CLC   INS1184,HEX1184
RT1_TEST1214     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1214
         LTORG 
RT1_CCE1214     DS 0H
*MEXIT #=  2407 LV= 2 RT1
*MEXIT #=  2406 LV= 1 ZOSOP
*MCALL #=  2408 LV= 1  ZOSOP 'ED3B','MULTIPLY UNNORMALIZED','MY','RXF',X
               Z9
         JAS   R11,VER1185
         USING *,R11
INS1185  MY   R1,R3,S2(X4)
HEX1185  DC    X'ED34D002103B'
NUM1185  DC    P'1185'
*MCALL #=  2409 LV= 2 VER1185  RT1   CCE,INS1185,HEX1185
VER1185  DS    0H
         CLC   INS1185,HEX1185
RT1_TEST1215     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1215
         LTORG 
RT1_CCE1215     DS 0H
*MEXIT #=  2409 LV= 2 RT1
*MEXIT #=  2408 LV= 1 ZOSOP
*MCALL #=  2410 LV= 1  ZOSOP 'ED3C','MULTIPLY AND ADD U (L > X high HFPX
               )','MAYH','RXF',Z9
         JAS   R11,VER1186
         USING *,R11
INS1186  MAYH R1,R3,S2(X4)
HEX1186  DC    X'ED34D002103C'
NUM1186  DC    P'1186'
*MCALL #=  2411 LV= 2 VER1186  RT1   CCE,INS1186,HEX1186
VER1186  DS    0H
         CLC   INS1186,HEX1186
RT1_TEST1216     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1216
         LTORG 
RT1_CCE1216     DS 0H
*MEXIT #=  2411 LV= 2 RT1
*MEXIT #=  2410 LV= 1 ZOSOP
*MCALL #=  2412 LV= 1  ZOSOP 'ED3D','MULTIPLY UNNORMALIZED','MYH','RXF'X
               ,Z9
         JAS   R11,VER1187
         USING *,R11
INS1187  MYH  R1,R3,S2(X4)
HEX1187  DC    X'ED34D002103D'
NUM1187  DC    P'1187'
*MCALL #=  2413 LV= 2 VER1187  RT1   CCE,INS1187,HEX1187
VER1187  DS    0H
         CLC   INS1187,HEX1187
RT1_TEST1217     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1217
         LTORG 
RT1_CCE1217     DS 0H
*MEXIT #=  2413 LV= 2 RT1
*MEXIT #=  2412 LV= 1 ZOSOP
*MCALL #=  2414 LV= 1  ZOSOP 'ED3E','MULTIPLY AND ADD (long HFP) ','MADX
                ','RXF HM'
         JAS   R11,VER1188
         USING *,R11
INS1188  MAD  R1,R3,S2(X4)
HEX1188  DC    X'ED34D002103E'
NUM1188  DC    P'1188'
*MCALL #=  2415 LV= 2 VER1188  RT1   CCE,INS1188,HEX1188
VER1188  DS    0H
         CLC   INS1188,HEX1188
RT1_TEST1218     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1218
         LTORG 
RT1_CCE1218     DS 0H
*MEXIT #=  2415 LV= 2 RT1
*MEXIT #=  2414 LV= 1 ZOSOP
*MCALL #=  2416 LV= 1  ZOSOP 'ED3F','MULTIPLY AND SUBTRACT (long HFP) 'X
               ,'MSD ','RXF HM'
         JAS   R11,VER1189
         USING *,R11
INS1189  MSD  R1,R3,S2(X4)
HEX1189  DC    X'ED34D002103F'
NUM1189  DC    P'1189'
*MCALL #=  2417 LV= 2 VER1189  RT1   CCE,INS1189,HEX1189
VER1189  DS    0H
         CLC   INS1189,HEX1189
RT1_TEST1219     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1219
         LTORG 
RT1_CCE1219     DS 0H
*MEXIT #=  2417 LV= 2 RT1
*MEXIT #=  2416 LV= 1 ZOSOP
*MCALL #=  2418 LV= 1  ZOSOP 'ED40','SHIFT COEFFICIENT LEFT (DDFP)','SLX
               DT','RXF' DFP
         JAS   R11,VER1190
         USING *,R11
INS1190  SLDT R1,R3,S2(X4)
HEX1190  DC    X'ED34D0021040'
NUM1190  DC    P'1190'
*MCALL #=  2419 LV= 2 VER1190  RT1   CCE,INS1190,HEX1190
VER1190  DS    0H
         CLC   INS1190,HEX1190
RT1_TEST1220     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1220
         LTORG 
RT1_CCE1220     DS 0H
*MEXIT #=  2419 LV= 2 RT1
*MEXIT #=  2418 LV= 1 ZOSOP
*MCALL #=  2420 LV= 1  ZOSOP 'ED41','SHIFT COEFFICIENT RIGHT (DDFP)','SX
               RDT','RXF' DFP
         JAS   R11,VER1191
         USING *,R11
INS1191  SRDT R1,R3,S2(X4)
HEX1191  DC    X'ED34D0021041'
NUM1191  DC    P'1191'
*MCALL #=  2421 LV= 2 VER1191  RT1   CCE,INS1191,HEX1191
VER1191  DS    0H
         CLC   INS1191,HEX1191
RT1_TEST1221     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1221
         LTORG 
RT1_CCE1221     DS 0H
*MEXIT #=  2421 LV= 2 RT1
*MEXIT #=  2420 LV= 1 ZOSOP
*MCALL #=  2422 LV= 1  ZOSOP 'ED48','SHIFT COEFFICIENT LEFT (LDFP)','SLX
               XT','RXF' DFP
         JAS   R11,VER1192
         USING *,R11
INS1192  SLXT R1,R3,S2(X4)
HEX1192  DC    X'ED34D0021048'
NUM1192  DC    P'1192'
*MCALL #=  2423 LV= 2 VER1192  RT1   CCE,INS1192,HEX1192
VER1192  DS    0H
         CLC   INS1192,HEX1192
RT1_TEST1222     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1222
         LTORG 
RT1_CCE1222     DS 0H
*MEXIT #=  2423 LV= 2 RT1
*MEXIT #=  2422 LV= 1 ZOSOP
*MCALL #=  2424 LV= 1  ZOSOP 'ED49','SHIFT COEFFICIENT RIGHT (LDFP)','SX
               RXT','RXF' DFP
         JAS   R11,VER1193
         USING *,R11
INS1193  SRXT R1,R3,S2(X4)
HEX1193  DC    X'ED34D0021049'
NUM1193  DC    P'1193'
*MCALL #=  2425 LV= 2 VER1193  RT1   CCE,INS1193,HEX1193
VER1193  DS    0H
         CLC   INS1193,HEX1193
RT1_TEST1223     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1223
         LTORG 
RT1_CCE1223     DS 0H
*MEXIT #=  2425 LV= 2 RT1
*MEXIT #=  2424 LV= 1 ZOSOP
*MCALL #=  2426 LV= 1  ZOSOP 'ED50','TEST DATA CLASS (EDFP)','TDCET','RX
               XE' DFP
         JAS   R11,VER1194
         USING *,R11
INS1194  TDCET R1,S2(X4)
HEX1194  DC    X'ED14D0020050'
NUM1194  DC    P'1194'
*MCALL #=  2427 LV= 2 VER1194  RT1   CCE,INS1194,HEX1194
VER1194  DS    0H
         CLC   INS1194,HEX1194
RT1_TEST1224     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1224
         LTORG 
RT1_CCE1224     DS 0H
*MEXIT #=  2427 LV= 2 RT1
*MEXIT #=  2426 LV= 1 ZOSOP
*MCALL #=  2428 LV= 1  ZOSOP 'ED51','TEST DATA GROUP (EDFP)','TDGET','RX
               XE' DFP
         JAS   R11,VER1195
         USING *,R11
INS1195  TDGET R1,S2(X4)
HEX1195  DC    X'ED14D0020051'
NUM1195  DC    P'1195'
*MCALL #=  2429 LV= 2 VER1195  RT1   CCE,INS1195,HEX1195
VER1195  DS    0H
         CLC   INS1195,HEX1195
RT1_TEST1225     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1225
         LTORG 
RT1_CCE1225     DS 0H
*MEXIT #=  2429 LV= 2 RT1
*MEXIT #=  2428 LV= 1 ZOSOP
*MCALL #=  2430 LV= 1  ZOSOP 'ED54','TEST DATA CLASS (DDFP)','TDCDT','RX
               XE' DFP
         JAS   R11,VER1196
         USING *,R11
INS1196  TDCDT R1,S2(X4)
HEX1196  DC    X'ED14D0020054'
NUM1196  DC    P'1196'
*MCALL #=  2431 LV= 2 VER1196  RT1   CCE,INS1196,HEX1196
VER1196  DS    0H
         CLC   INS1196,HEX1196
RT1_TEST1226     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1226
         LTORG 
RT1_CCE1226     DS 0H
*MEXIT #=  2431 LV= 2 RT1
*MEXIT #=  2430 LV= 1 ZOSOP
*MCALL #=  2432 LV= 1  ZOSOP 'ED55','TEST DATA GROUP (DDFP)','TDGDT','RX
               XE' DFP
         JAS   R11,VER1197
         USING *,R11
INS1197  TDGDT R1,S2(X4)
HEX1197  DC    X'ED14D0020055'
NUM1197  DC    P'1197'
*MCALL #=  2433 LV= 2 VER1197  RT1   CCE,INS1197,HEX1197
VER1197  DS    0H
         CLC   INS1197,HEX1197
RT1_TEST1227     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1227
         LTORG 
RT1_CCE1227     DS 0H
*MEXIT #=  2433 LV= 2 RT1
*MEXIT #=  2432 LV= 1 ZOSOP
*MCALL #=  2434 LV= 1  ZOSOP 'ED58','TEST DATA CLASS (LDFP)','TDCXT','RX
               XE' DFP
         JAS   R11,VER1198
         USING *,R11
INS1198  TDCXT R1,S2(X4)
HEX1198  DC    X'ED14D0020058'
NUM1198  DC    P'1198'
*MCALL #=  2435 LV= 2 VER1198  RT1   CCE,INS1198,HEX1198
VER1198  DS    0H
         CLC   INS1198,HEX1198
RT1_TEST1228     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1228
         LTORG 
RT1_CCE1228     DS 0H
*MEXIT #=  2435 LV= 2 RT1
*MEXIT #=  2434 LV= 1 ZOSOP
*MCALL #=  2436 LV= 1  ZOSOP 'ED59','TEST DATA GROUP (LDFP)','TDGXT','RX
               XE' DFP
         JAS   R11,VER1199
         USING *,R11
INS1199  TDGXT R1,S2(X4)
HEX1199  DC    X'ED14D0020059'
NUM1199  DC    P'1199'
*MCALL #=  2437 LV= 2 VER1199  RT1   CCE,INS1199,HEX1199
VER1199  DS    0H
         CLC   INS1199,HEX1199
RT1_TEST1229     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1229
         LTORG 
RT1_CCE1229     DS 0H
*MEXIT #=  2437 LV= 2 RT1
*MEXIT #=  2436 LV= 1 ZOSOP
*MCALL #=  2438 LV= 1  ZOSOP 'ED64','LOAD (short) ','LEY ','RXY LD'
         JAS   R11,VER1200
         USING *,R11
INS1200  LEY  R1,S2(X4)
HEX1200  DC    X'ED14D0020064'
NUM1200  DC    P'1200'
*MCALL #=  2439 LV= 2 VER1200  RT1   CCE,INS1200,HEX1200
VER1200  DS    0H
         CLC   INS1200,HEX1200
RT1_TEST1230     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1230
         LTORG 
RT1_CCE1230     DS 0H
*MEXIT #=  2439 LV= 2 RT1
*MEXIT #=  2438 LV= 1 ZOSOP
*MCALL #=  2440 LV= 1  ZOSOP 'ED65','LOAD (long) ','LDY ','RXY LD'
         JAS   R11,VER1201
         USING *,R11
INS1201  LDY  R1,S2(X4)
HEX1201  DC    X'ED14D0020065'
NUM1201  DC    P'1201'
*MCALL #=  2441 LV= 2 VER1201  RT1   CCE,INS1201,HEX1201
VER1201  DS    0H
         CLC   INS1201,HEX1201
RT1_TEST1231     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1231
         LTORG 
RT1_CCE1231     DS 0H
*MEXIT #=  2441 LV= 2 RT1
*MEXIT #=  2440 LV= 1 ZOSOP
*MCALL #=  2442 LV= 1  ZOSOP 'ED66','STORE (short) ','STEY ','RXY LD'
         JAS   R11,VER1202
         USING *,R11
INS1202  STEY  R1,S2(X4)
HEX1202  DC    X'ED14D0020066'
NUM1202  DC    P'1202'
*MCALL #=  2443 LV= 2 VER1202  RT1   CCE,INS1202,HEX1202
VER1202  DS    0H
         CLC   INS1202,HEX1202
RT1_TEST1232     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1232
         LTORG 
RT1_CCE1232     DS 0H
*MEXIT #=  2443 LV= 2 RT1
*MEXIT #=  2442 LV= 1 ZOSOP
*MCALL #=  2444 LV= 1  ZOSOP 'ED67','STORE (long) ','STDY ','RXY LD'
         JAS   R11,VER1203
         USING *,R11
INS1203  STDY  R1,S2(X4)
HEX1203  DC    X'ED14D0020067'
NUM1203  DC    P'1203'
*MCALL #=  2445 LV= 2 VER1203  RT1   CCE,INS1203,HEX1203
VER1203  DS    0H
         CLC   INS1203,HEX1203
RT1_TEST1233     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1233
         LTORG 
RT1_CCE1233     DS 0H
*MEXIT #=  2445 LV= 2 RT1
*MEXIT #=  2444 LV= 1 ZOSOP
*MCALL #=  2446 LV= 1  ZOSOP 'EE ','PERFORM LOCKED OPERATION ','PLO ','X
               SS3 C '
         JAS   R11,VER1204
         USING *,R11
INS1204  PLO  R1,S2,R3,S4
HEX1204  DC    X'EE13D002D004'
NUM1204  DC    P'1204'
*MCALL #=  2447 LV= 2 VER1204  RT1   CCE,INS1204,HEX1204
VER1204  DS    0H
         CLC   INS1204,HEX1204
RT1_TEST1234     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1234
         LTORG 
RT1_CCE1234     DS 0H
*MEXIT #=  2447 LV= 2 RT1
*MEXIT #=  2446 LV= 1 ZOSOP
*MCALL #=  2448 LV= 1  ZOSOP 'EF ','LOAD MULTIPLE DISJOINT ','LMD ','SSX
               4 N '
         JAS   R11,VER1205
         USING *,R11
INS1205  LMD  R1,R3,S2,S4
HEX1205  DC    X'EF13D002D004'
NUM1205  DC    P'1205'
*MCALL #=  2449 LV= 2 VER1205  RT1   CCE,INS1205,HEX1205
VER1205  DS    0H
         CLC   INS1205,HEX1205
RT1_TEST1235     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1235
         LTORG 
RT1_CCE1235     DS 0H
*MEXIT #=  2449 LV= 2 RT1
*MEXIT #=  2448 LV= 1 ZOSOP
*MCALL #=  2450 LV= 1  ZOSOP 'F0 ','SHIFT AND ROUND DECIMAL ','SRP ','SX
               S5 C '
         JAS   R11,VER1206
         USING *,R11
INS1206  SRP  S1(PL1),S2,R3
HEX1206  DC    X'F063D001D002'
NUM1206  DC    P'1206'
*MCALL #=  2451 LV= 2 VER1206  RT1   CCE,INS1206,HEX1206
VER1206  DS    0H
         CLC   INS1206,HEX1206
RT1_TEST1236     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1236
         LTORG 
RT1_CCE1236     DS 0H
*MEXIT #=  2451 LV= 2 RT1
*MEXIT #=  2450 LV= 1 ZOSOP
*MCALL #=  2452 LV= 1  ZOSOP 'F1 ','MOVE WITH OFFSET ','MVO ','SS2'
         JAS   R11,VER1207
         USING *,R11
INS1207  MVO  S1(PL1),S2(PL2)
HEX1207  DC    X'F167D001D002'
NUM1207  DC    P'1207'
*MCALL #=  2453 LV= 2 VER1207  RT1   CCE,INS1207,HEX1207
VER1207  DS    0H
         CLC   INS1207,HEX1207
RT1_TEST1237     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1237
         LTORG 
RT1_CCE1237     DS 0H
*MEXIT #=  2453 LV= 2 RT1
*MEXIT #=  2452 LV= 1 ZOSOP
*MCALL #=  2454 LV= 1  ZOSOP 'F2 ','PACK ','PACK ','SS2'
         JAS   R11,VER1208
         USING *,R11
INS1208  PACK  S1(PL1),S2(PL2)
HEX1208  DC    X'F267D001D002'
NUM1208  DC    P'1208'
*MCALL #=  2455 LV= 2 VER1208  RT1   CCE,INS1208,HEX1208
VER1208  DS    0H
         CLC   INS1208,HEX1208
RT1_TEST1238     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1238
         LTORG 
RT1_CCE1238     DS 0H
*MEXIT #=  2455 LV= 2 RT1
*MEXIT #=  2454 LV= 1 ZOSOP
*MCALL #=  2456 LV= 1  ZOSOP 'F3 ','UNPACK ','UNPK ','SS2'
         JAS   R11,VER1209
         USING *,R11
INS1209  UNPK  S1(PL1),S2(PL2)
HEX1209  DC    X'F367D001D002'
NUM1209  DC    P'1209'
*MCALL #=  2457 LV= 2 VER1209  RT1   CCE,INS1209,HEX1209
VER1209  DS    0H
         CLC   INS1209,HEX1209
RT1_TEST1239     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1239
         LTORG 
RT1_CCE1239     DS 0H
*MEXIT #=  2457 LV= 2 RT1
*MEXIT #=  2456 LV= 1 ZOSOP
*MCALL #=  2458 LV= 1  ZOSOP 'F8 ','ZERO AND ADD ','ZAP ','SS2C '
         JAS   R11,VER1210
         USING *,R11
INS1210  ZAP  S1(PL1),S2(PL2)
HEX1210  DC    X'F867D001D002'
NUM1210  DC    P'1210'
*MCALL #=  2459 LV= 2 VER1210  RT1   CCE,INS1210,HEX1210
VER1210  DS    0H
         CLC   INS1210,HEX1210
RT1_TEST1240     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1240
         LTORG 
RT1_CCE1240     DS 0H
*MEXIT #=  2459 LV= 2 RT1
*MEXIT #=  2458 LV= 1 ZOSOP
*MCALL #=  2460 LV= 1  ZOSOP 'F9 ','COMPARE DECIMAL ','CP ','SS2C '
         JAS   R11,VER1211
         USING *,R11
INS1211  CP   S1(PL1),S2(PL2)
HEX1211  DC    X'F967D001D002'
NUM1211  DC    P'1211'
*MCALL #=  2461 LV= 2 VER1211  RT1   CCE,INS1211,HEX1211
VER1211  DS    0H
         CLC   INS1211,HEX1211
RT1_TEST1241     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1241
         LTORG 
RT1_CCE1241     DS 0H
*MEXIT #=  2461 LV= 2 RT1
*MEXIT #=  2460 LV= 1 ZOSOP
*MCALL #=  2462 LV= 1  ZOSOP 'FA ','ADD DECIMAL ','AP ','SS2C '
         JAS   R11,VER1212
         USING *,R11
INS1212  AP   S1(PL1),S2(PL2)
HEX1212  DC    X'FA67D001D002'
NUM1212  DC    P'1212'
*MCALL #=  2463 LV= 2 VER1212  RT1   CCE,INS1212,HEX1212
VER1212  DS    0H
         CLC   INS1212,HEX1212
RT1_TEST1242     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1242
         LTORG 
RT1_CCE1242     DS 0H
*MEXIT #=  2463 LV= 2 RT1
*MEXIT #=  2462 LV= 1 ZOSOP
*MCALL #=  2464 LV= 1  ZOSOP 'FB ','SUBTRACT DECIMAL ','SP ','SS2C '
         JAS   R11,VER1213
         USING *,R11
INS1213  SP   S1(PL1),S2(PL2)
HEX1213  DC    X'FB67D001D002'
NUM1213  DC    P'1213'
*MCALL #=  2465 LV= 2 VER1213  RT1   CCE,INS1213,HEX1213
VER1213  DS    0H
         CLC   INS1213,HEX1213
RT1_TEST1243     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1243
         LTORG 
RT1_CCE1243     DS 0H
*MEXIT #=  2465 LV= 2 RT1
*MEXIT #=  2464 LV= 1 ZOSOP
*MCALL #=  2466 LV= 1  ZOSOP 'FC ','MULTIPLY DECIMAL ','MP ','SS2'
         JAS   R11,VER1214
         USING *,R11
INS1214  MP   S1(PL1),S2(PL2)
HEX1214  DC    X'FC67D001D002'
NUM1214  DC    P'1214'
*MCALL #=  2467 LV= 2 VER1214  RT1   CCE,INS1214,HEX1214
VER1214  DS    0H
         CLC   INS1214,HEX1214
RT1_TEST1244     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1244
         LTORG 
RT1_CCE1244     DS 0H
*MEXIT #=  2467 LV= 2 RT1
*MEXIT #=  2466 LV= 1 ZOSOP
*MCALL #=  2468 LV= 1  ZOSOP 'FD ','DIVIDE DECIMAL ','DP ','SS2'
         JAS   R11,VER1215
         USING *,R11
INS1215  DP   S1(PL1),S2(PL2)
HEX1215  DC    X'FD67D001D002'
NUM1215  DC    P'1215'
*MCALL #=  2469 LV= 2 VER1215  RT1   CCE,INS1215,HEX1215
VER1215  DS    0H
         CLC   INS1215,HEX1215
RT1_TEST1245     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1245
         LTORG 
RT1_CCE1245     DS 0H
*MEXIT #=  2469 LV= 2 RT1
*MEXIT #=  2468 LV= 1 ZOSOP
* TEST RX WITH COMMA FOR MISSING INDEX REG
         SR    3,3              RPI-819 CLEAR F4'S FROM R3 BASE
RX1      L     1,2(,3)
VX1      L     1,2(0,3)
*MCALL #=  2470 LV= 1          RT1   CCE,RX1,VX1,4
         DS    0H
         LA    1,RX1
         LA    2,VX1
         CLC   0(4,1),0(2)
RT1_TEST1246     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1246
         LTORG 
RT1_CCE1246     DS 0H
*MEXIT #=  2470 LV= 1 RT1
RX2      LA    1,2(,3)
VX2      LA    1,2(0,3)
*MCALL #=  2471 LV= 1          RT1   CCE,RX2,VX2,4
         DS    0H
         LA    1,RX2
         LA    2,VX2
         CLC   0(4,1),0(2)
RT1_TEST1247     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1247
         LTORG 
RT1_CCE1247     DS 0H
*MEXIT #=  2471 LV= 1 RT1
RXY2     LAY   1,2(,3)
VXY2     LAY   1,2(0,3)
*MCALL #=  2472 LV= 1          RT1   CCE,RXY2,VXY2,4
         DS    0H
         LA    1,RXY2
         LA    2,VXY2
         CLC   0(4,1),0(2)
RT1_TEST1248     BAS   RT1_LINK,RT1_TEST_CC0
         USING *,RT1_LINK
         B     RT1_CCE1248
         LTORG 
RT1_CCE1248     DS 0H
*MEXIT #=  2472 LV= 1 RT1
*MCALL #=  2473 LV= 1          RT1   END
         B      RT1_END
*MEXIT #=  2473 LV= 1 RT1
         END 
