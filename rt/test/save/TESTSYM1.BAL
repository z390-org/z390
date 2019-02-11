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
* 2005-09-30  DSH         Initial version                           *
* 2006-01-29  DSH RPI-193 Test mz390 symbol length for implicit CPZ *
* 2006-08-29  DSH RPI-415 Test AIF reference to ordinary symbol     *
*                         length                                    *
* 2006-08-30  DSH RPI-419 Test AIF reference to ordinary symbol     *
*                         SETC parameter with labeled using prefix  *
*                         and trailing expression operands          *
* 2006-09-08  DSH RPI-442 Test AIF reference to DSECT sym defined   *
*                         via * loc                                 *
* 2008-01-22  DSH RPI-790 Update tests for I' and S'                *
*********************************************************************
*MCALL #=     1 LV= 1 TESTSYM1 SUBENTRY 
TESTSYM1 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTSYM1'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTSYM1+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
*MCALL #=     2 LV= 1          WTO   'TESTSYM1 - TEST SYMBOL T,L,I,S OPX
               ERATORS'
         BRAS  1,*+(WTO#0002_EOT-*+1)/2*2
         DC    AL2(WTO#0002_EOT-*,0),C'TESTSYM1 - TEST SYMBOL T,L,I,S OX
               PERATORS'
WTO#0002_EOT     EQU *
         SVC   35
*MEXIT #=     2 LV= 1 WTO
* TEST I' AND S'
         MACRO
&N       TESTIS &DC,&I,&S
         B     TESTIS&SYSNDX
&N       DC    &DC
TESTIS&SYSNDX DS 0H
         CLC  =AL1(I'&N),=AL1(&I)
         BNE  ERR2
         CLC  =AL1(S'&N),=AL1(&S)
         BNE  ERR3
         MEND
*MCALL #=     3 LV= 1 PI1S2    TESTIS P'7.50,8.1',1,2
         B     TESTIS0003
PI1S2    DC    P'7.50,8.1'
TESTIS0003    DS 0H
         CLC  =AL1(I'PI1S2),=AL1(1)
         BNE  ERR2
         CLC  =AL1(S'PI1S2),=AL1(2)
         BNE  ERR3
*MEXIT #=     3 LV= 1 TESTIS
*MCALL #=     4 LV= 1 ZI1S2    TESTIS Z'7.50,8.1',1,2
         B     TESTIS0004
ZI1S2    DC    Z'7.50,8.1'
TESTIS0004    DS 0H
         CLC  =AL1(I'ZI1S2),=AL1(1)
         BNE  ERR2
         CLC  =AL1(S'ZI1S2),=AL1(2)
         BNE  ERR3
*MEXIT #=     4 LV= 1 TESTIS
*MCALL #=     5 LV= 1 DDI14S2  TESTIS DD'7.50,8.1',14,2
         B     TESTIS0005
DDI14S2  DC    DD'7.50,8.1'
TESTIS0005    DS 0H
         CLC  =AL1(I'DDI14S2),=AL1(14)
         BNE  ERR2
         CLC  =AL1(S'DDI14S2),=AL1(2)
         BNE  ERR3
*MEXIT #=     5 LV= 1 TESTIS
*MCALL #=     6 LV= 1 EDI5S2   TESTIS ED'7.50,8.1',5,2
         B     TESTIS0006
EDI5S2   DC    ED'7.50,8.1'
TESTIS0006    DS 0H
         CLC  =AL1(I'EDI5S2),=AL1(5)
         BNE  ERR2
         CLC  =AL1(S'EDI5S2),=AL1(2)
         BNE  ERR3
*MEXIT #=     6 LV= 1 TESTIS
*MCALL #=     7 LV= 1 LDI32S2  TESTIS LD'7.50,8.1',32,2
         B     TESTIS0007
LDI32S2  DC    LD'7.50,8.1'
TESTIS0007    DS 0H
         CLC  =AL1(I'LDI32S2),=AL1(32)
         BNE  ERR2
         CLC  =AL1(S'LDI32S2),=AL1(2)
         BNE  ERR3
*MEXIT #=     7 LV= 1 TESTIS
*MCALL #=     8 LV= 1 FI26S5   TESTIS FS5'1',26,5
         B     TESTIS0008
FI26S5   DC    FS5'1'
TESTIS0008    DS 0H
         CLC  =AL1(I'FI26S5),=AL1(26)
         BNE  ERR2
         CLC  =AL1(S'FI26S5),=AL1(5)
         BNE  ERR3
*MEXIT #=     8 LV= 1 TESTIS
*MCALL #=     9 LV= 1 HI10S5   TESTIS HS5'1',10,5
         B     TESTIS0009
HI10S5   DC    HS5'1'
TESTIS0009    DS 0H
         CLC  =AL1(I'HI10S5),=AL1(10)
         BNE  ERR2
         CLC  =AL1(S'HI10S5),=AL1(5)
         BNE  ERR3
*MEXIT #=     9 LV= 1 TESTIS
*MCALL #=    10 LV= 1          WTO    'TESTSYM1 ENDED OK'
         BRAS  1,*+(WTO#0010_EOT-*+1)/2*2
         DC    AL2(WTO#0010_EOT-*,0),C'TESTSYM1 ENDED OK'
WTO#0010_EOT     EQU *
         SVC   35
*MEXIT #=    10 LV= 1 WTO
*MCALL #=    11 LV= 1          SUBEXIT 
         LA    15,0
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=    11 LV= 1 SUBEXIT
*MCALL #=    12 LV= 1 ERR2     WTO   'INVALID I' VALUE'
ERR2     DS    0H
         BRAS  1,*+(WTO#0012_EOT-*+1)/2*2
         DC    AL2(WTO#0012_EOT-*,0),C'INVALID I'
WTO#0012_EOT     EQU *
         SVC   35
*MEXIT #=    12 LV= 1 WTO
*MCALL #=    13 LV= 1          SUBEXIT RC=16
         LA    15,16
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=    13 LV= 1 SUBEXIT
*MCALL #=    14 LV= 1 ERR3     WTO   'INVALID S' VALUE'
ERR3     DS    0H
         BRAS  1,*+(WTO#0014_EOT-*+1)/2*2
         DC    AL2(WTO#0014_EOT-*,0),C'INVALID S'
WTO#0014_EOT     EQU *
         SVC   35
*MEXIT #=    14 LV= 1 WTO
*MCALL #=    15 LV= 1          SUBEXIT RC=16
         LA    15,16
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=    15 LV= 1 SUBEXIT
* TEST DS/DC SYMBOL TYPE AND LENGTH
         MACRO
         TSYM  &SDS,&ST,&SL
&T       SETC  T'&SDS
&L       SETA  L'&SDS
         MNOTE 'DS=&SDS T=&T L=&L'
         AIF   (&T NE &ST).ERR
         AIF   (&L NE &SL).ERR
         MEXIT
.ERR     ANOP
         MNOTE 12,'SYMBOL TYPE OR LENGTH ERROR'
         MEND
*MCALL #=    16 LV= 1          TSYM  SA,A,4
         MNOTE 'DS=SA T=A L=4'
*MEXIT #=    16 LV= 1 TSYM
*MCALL #=    17 LV= 1          TSYM  SAL3,R,3
         MNOTE 'DS=SAL3 T=R L=3'
*MEXIT #=    17 LV= 1 TSYM
*MCALL #=    18 LV= 1          TSYM  S2A,A,4
         MNOTE 'DS=S2A T=A L=4'
*MEXIT #=    18 LV= 1 TSYM
*MCALL #=    19 LV= 1          TSYM  SEAL3,R,3
         MNOTE 'DS=SEAL3 T=R L=3'
*MEXIT #=    19 LV= 1 TSYM
*MCALL #=    20 LV= 1          TSYM  SCL2,C,2
         MNOTE 'DS=SCL2 T=C L=2'
*MEXIT #=    20 LV= 1 TSYM
*MCALL #=    21 LV= 1          TSYM  SF,F,4
         MNOTE 'DS=SF T=F L=4'
*MEXIT #=    21 LV= 1 TSYM
*MCALL #=    22 LV= 1          TSYM  SH,H,2
         MNOTE 'DS=SH T=H L=2'
*MEXIT #=    22 LV= 1 TSYM
*MCALL #=    23 LV= 1          TSYM  SY,Y,2
         MNOTE 'DS=SY T=Y L=2'
*MEXIT #=    23 LV= 1 TSYM
*MCALL #=    24 LV= 1          TSYM  SF1,G,1
         MNOTE 'DS=SF1 T=G L=1'
*MEXIT #=    24 LV= 1 TSYM
*MCALL #=    25 LV= 1          TSYM  SH2,G,2
         MNOTE 'DS=SH2 T=G L=2'
*MEXIT #=    25 LV= 1 TSYM
*MCALL #=    26 LV= 1          TSYM  SY3,R,3
         MNOTE 'DS=SY3 T=R L=3'
*MEXIT #=    26 LV= 1 TSYM
*MCALL #=    27 LV= 1          TSYM  SE,E,4
         MNOTE 'DS=SE T=E L=4'
*MEXIT #=    27 LV= 1 TSYM
*MCALL #=    28 LV= 1          TSYM  SD,D,8
         MNOTE 'DS=SD T=D L=8'
*MEXIT #=    28 LV= 1 TSYM
*MCALL #=    29 LV= 1          TSYM  SL,L,16
         MNOTE 'DS=SL T=L L=16'
*MEXIT #=    29 LV= 1 TSYM
*MCALL #=    30 LV= 1          TSYM  SE1,K,1
         MNOTE 'DS=SE1 T=K L=1'
*MEXIT #=    30 LV= 1 TSYM
*MCALL #=    31 LV= 1          TSYM  SD2,K,2
         MNOTE 'DS=SD2 T=K L=2'
*MEXIT #=    31 LV= 1 TSYM
*MCALL #=    32 LV= 1          TSYM  SL3,K,3
         MNOTE 'DS=SL3 T=K L=3'
*MEXIT #=    32 LV= 1 TSYM
*MCALL #=    33 LV= 1          TSYM  SS,S,2
         MNOTE 'DS=SS T=S L=2'
*MEXIT #=    33 LV= 1 TSYM
*MCALL #=    34 LV= 1          TSYM  SS1,R,1
         MNOTE 'DS=SS1 T=R L=1'
*MEXIT #=    34 LV= 1 TSYM
*MCALL #=    35 LV= 1          TSYM  SP,P,1
         MNOTE 'DS=SP T=P L=1'
*MEXIT #=    35 LV= 1 TSYM
*MCALL #=    36 LV= 1          TSYM  SP2,P,2
         MNOTE 'DS=SP2 T=P L=2'
*MEXIT #=    36 LV= 1 TSYM
*MCALL #=    37 LV= 1          TSYM  SZ,Z,1
         MNOTE 'DS=SZ T=Z L=1'
*MEXIT #=    37 LV= 1 TSYM
*MCALL #=    38 LV= 1          TSYM  SZ2,Z,2
         MNOTE 'DS=SZ2 T=Z L=2'
*MEXIT #=    38 LV= 1 TSYM
*MCALL #=    39 LV= 1          TSYM  TESTSYM1,J,1
         MNOTE 'DS=TESTSYM1 T=J L=1'
*MEXIT #=    39 LV= 1 TSYM
*MCALL #=    40 LV= 1          TSYM  LR,I,2
         MNOTE 'DS=LR T=I L=2'
*MEXIT #=    40 LV= 1 TSYM
*MCALL #=    41 LV= 1          TSYM  ST,I,4
         MNOTE 'DS=ST T=I L=4'
*MEXIT #=    41 LV= 1 TSYM
*MCALL #=    42 LV= 1          TSYM  MVC,I,6
         MNOTE 'DS=MVC T=I L=6'
*MEXIT #=    42 LV= 1 TSYM
*MCALL #=    43 LV= 1          TSYM  SCD2,C,2
         MNOTE 'DS=SCD2 T=C L=2'
*MEXIT #=    43 LV= 1 TSYM
*MCALL #=    44 LV= 1          TSYM  SPD2,P,2
         MNOTE 'DS=SPD2 T=P L=2'
*MEXIT #=    44 LV= 1 TSYM
*MCALL #=    45 LV= 1          TSYM  SZD2,Z,2
         MNOTE 'DS=SZD2 T=Z L=2'
*MEXIT #=    45 LV= 1 TSYM
* TEST NUMERIC AND OMITTED TYPES
         MACRO
         TTYPE &P1,&P2
&TYPE    SETC  T'&P1
         MNOTE 'P1=&P1 T''P1 = &TYPE'
&TYPE    SETC  T'&P2
         MNOTE 'P2=&P2 T''P2 = &TYPE'
         MEND
*MCALL #=    46 LV= 1          TTYPE A
         MNOTE 'P1=A T'P1 = U'
         MNOTE 'P2= T'P2 = O'
*MEXIT #=    46 LV= 1 TTYPE
*MCALL #=    47 LV= 1          TTYPE 
         MNOTE 'P1= T'P1 = O'
         MNOTE 'P2= T'P2 = O'
*MEXIT #=    47 LV= 1 TTYPE
*MCALL #=    48 LV= 1          TTYPE ,B
         MNOTE 'P1= T'P1 = O'
         MNOTE 'P2=B T'P2 = U'
*MEXIT #=    48 LV= 1 TTYPE
*MCALL #=    49 LV= 1          TTYPE 0
         MNOTE 'P1=0 T'P1 = N'
         MNOTE 'P2= T'P2 = O'
*MEXIT #=    49 LV= 1 TTYPE
*MCALL #=    50 LV= 1          TTYPE 9
         MNOTE 'P1=9 T'P1 = N'
         MNOTE 'P2= T'P2 = O'
*MEXIT #=    50 LV= 1 TTYPE
ADUP     EQU   3
SA       DS    A
SAL3     DS    AL3
S2A      DS    2A
SEAL3    DS    (ADUP)AL3
SCL2     DS    CL2
SCD2     DC    C'12'
SF       DS    F
SH       DS    H
SY       DS    Y
SF1      DS    FL1
SH2      DS    HL2
SY3      DS    YL3
SS       DS    S
SS1      DS    SL1
SE       DS    E
SD       DS    D
SL       DS    L
SE1      DS    EL1
SD2      DS    DL2
SL3      DS    LL3
SP       DS    P
SP2      DS    PL2
SPD2     DC    P'123'
SZ       DS    Z
SZ2      DS    ZL2
SZD2     DC    Z'12'
LR       LR    1,1
ST       ST    1,0(1)
MVC      MVC   0(1,1),0(2)
* TEST AIF REF TO ORDINARY SYMBOL LENGTH OF DSECT
D        DSECT 
DF1      DS   XL10
DL       EQU  *-D
         MNOTE 'DL EQ 10 OK'
         MNOTE 'LABEL.DL+2 EQ 10 OK'
* TEST AIF REF TO DSECT SYM DEFINED BY EQU *
CVTFIX   DSECT 
         DS   8X
CVTMAP   EQU  *
CVT      EQU  CVTMAP,,T'CVTMAP
         MNOTE 'LCVT=8'
         END 
