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
* 2006-03-21  DSH RPI-253  Add test for macro labels starting       *
*                          with ._                                  *
* 2006-03-21  DSH RPI-257  Add test for * as second operand         *
* 2006-04-07  DSH RPI-274  Add test for 'c''...''' sdt within       *
*                          strings                                  *
* 2006-07-03  DSH RPI-336  Add test for D' operator                 *
* 2006-07-03  DSH RPI-338  Add test for 'c''...''' sdt within       *
*                          strings                                  *
* 2006-07-03  DSH RPI-340  Test T' for EQU with 3rd operand plus    *
*                          mult. types                              *
* 2006-07-03  DSH RPI-353  Test prefix operator followed by (...)   *
* 2006-07-08  DSH RPI-359  Test keyword parm with mixed case        *
* 2006-08-30  DSH RPI-422  Test padded setc compare with high low   *
*                          chars                                    *
* 2006-09-21  DSH RPI-447  Test N'&PARM(&VAR)                       *
* 2007-06-10  DSH RPI-633  Test macro label parameters              *
* 2007-08-22  DSH RPI-673  Test &var in macro inline prototype name *
*                          field                                    *
* 2008-11-07  DSH RPI-938  Double quotes in MNOTE text to avoid     *
*                          syntax errors                            *
* 2001-01-25  DSH RPI-1139 Add quotes for DOUBLE for NOALLOW        *
*********************************************************************
*MCALL #=     1 LV= 1 TESTMAC1 SUBENTRY 
TESTMAC1 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTMAC1'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTMAC1+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
*MCALL #=     2 LV= 1          WTO   'TESTMAC1 TEST SUBSTRINGS, '''' (DX
               OUBLE QUOTES), AND &&'
         BRAS  1,*+(WTO#0002_EOT-*+1)/2*2
         DC    AL2(WTO#0002_EOT-*,0),C'TESTMAC1 TEST SUBSTRINGS, '''' (X
               DOUBLE QUOTES), AND &&'
WTO#0002_EOT     EQU *
         SVC   35
*MEXIT #=     2 LV= 1 WTO
*MCALL #=     3 LV= 1          SUBEXIT 
         LA    15,0
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=     3 LV= 1 SUBEXIT
         DC    C'ABC=ABC'
         DC    C'A=A'
         DC    C'BC=BC'
         MNOTE '&TWOAMP=&&'
         DC    C'TWOAMP=&&'
         MNOTE '&DQ='''
         DC    C'DQ='''
         DC     C'A',C'B',CL2'ABC',(2)C'1' TEST COMMENT, MULT FLD,
         DC     c'A',c'B',cl2'ABC',(2)c'1' EXPLICIT LEN, DUP FIELD, LC
         MACRO
         TESTF  &A,&B
&I       SETA  ('&A' FIND '&B')   RPI-1139
&DA      SETC  (DOUBLE '&A')      RPI-1139
&DB      SETC  (DOUBLE '&B')      RPI-1139
         MNOTE '&A FIND &B = &I'
         MEND
*MCALL #=     4 LV= 1          TESTF ABC,A
         MNOTE 'ABC FIND A = 1'
*MEXIT #=     4 LV= 1 TESTF
*MCALL #=     5 LV= 1          TESTF ABC,B
         MNOTE 'ABC FIND B = 2'
*MEXIT #=     5 LV= 1 TESTF
*MCALL #=     6 LV= 1          TESTF ABC,C
         MNOTE 'ABC FIND C = 3'
*MEXIT #=     6 LV= 1 TESTF
*MCALL #=     7 LV= 1          TESTF ABC,DCB
         MNOTE 'ABC FIND DCB = 2'
*MEXIT #=     7 LV= 1 TESTF
*MCALL #=     8 LV= 1          TESTF ABC,X
         MNOTE 'ABC FIND X = 0'
*MEXIT #=     8 LV= 1 TESTF
*MCALL #=     9 LV= 1          TESTF X,
         MNOTE 'X FIND  = 0'
*MEXIT #=     9 LV= 1 TESTF
*MCALL #=    10 LV= 1          TESTF ,X
         MNOTE ' FIND X = 0'
*MEXIT #=    10 LV= 1 TESTF
         MACRO
         TESTI  &A,&B
&I       SETA  ('&A' INDEX '&B') RPI-1139
&DA      SETC  (DOUBLE '&A')     RPI-1139
&DB      SETC  (DOUBLE '&B')     RPI-1139
         MNOTE '&A INDEX &B = &I'
         MEND
*MCALL #=    11 LV= 1          TESTI ABC,ABC
         MNOTE 'ABC INDEX ABC = 1'
*MEXIT #=    11 LV= 1 TESTI
*MCALL #=    12 LV= 1          TESTI ABC,AB
         MNOTE 'ABC INDEX AB = 1'
*MEXIT #=    12 LV= 1 TESTI
*MCALL #=    13 LV= 1          TESTI ABC,BC
         MNOTE 'ABC INDEX BC = 2'
*MEXIT #=    13 LV= 1 TESTI
*MCALL #=    14 LV= 1          TESTI ABC,ABCD
         MNOTE 'ABC INDEX ABCD = 0'
*MEXIT #=    14 LV= 1 TESTI
*MCALL #=    15 LV= 1          TESTI ABC,
         MNOTE 'ABC INDEX  = 0'
*MEXIT #=    15 LV= 1 TESTI
*MCALL #=    16 LV= 1          TESTI ,ABC
         MNOTE ' INDEX ABC = 0'
*MEXIT #=    16 LV= 1 TESTI
* TEST MACRO LABELS STARTING WITH ._
         MNOTE 'BRANCH TO ._OK IS OK'
* TEST * AS SECOND OPERAND
         MNOTE 'BC=BC'
* TEST SDT WITHIN STRING
         MNOTE 'SDT=C''X'''
* TEST DUPLICATION OF STRING OPERATOR (...)'...'
         MNOTE 'LBL=XXXX'
* TEST D' OPERATOR
         MNOTE 'X NOT DEFINED OK'
X        EQU   1
         MNOTE 'X DEFINED OK'
* TEST T' FOR EQU WITH THIRD OPERAND
X2       EQU   X'80',X'80',C'b'
         MNOTE 'TX2=b'
         MACRO
         TESTTM
         MEND
*MCALL #=    17 LV= 1 TM       TESTTM 
*MEXIT #=    17 LV= 1 TESTTM
         MNOTE 'TTM=M'
X3       EQU    1,2,C'X'
Y3       EQU    X3
         MNOTE 'T'Y3=U'
* TEST PREFIX OPERATOR FOLLOWED BY (..)
         DC    C'ABC'
* TEST MACRO WITH MIXED CASE KEYWORD
         MACRO
         TESTMC &ARmode=X
         MNOTE 'TESTMC ARmode=&ARMODE'
         MEND
*MCALL #=    18 LV= 1          TESTMC 
         MNOTE 'TESTMC ARmode=X'
*MEXIT #=    18 LV= 1 TESTMC
*MCALL #=    19 LV= 1          TESTMC ARMODE=Y
         MNOTE 'TESTMC ARmode=Y'
*MEXIT #=    19 LV= 1 TESTMC
* TEST PADDED SETC COMPARE WITH HIGH LOC CHARS
         MNOTE 'A LT A1 AND A1 GT A OK'
* TEST N'&PARM(&VAR)
         MACRO
         TESTNPV &P1,&P2,&P3
&NPV     SETA    N'&P2(&P3)
         AIF     (&P1 NE &NPV).NPVERR
         MNOTE   'NPV &P1 EQ &NPV OK'
         MEXIT
.NPVERR  MNOTE   'NPV ERROR &P1 VS &NPV'
         MEND
*MCALL #=    20 LV= 1          TESTNPV 1,A,1
         MNOTE 'NPV 1 EQ 1 OK'
*MEXIT #=    20 LV= 1 TESTNPV
*MCALL #=    21 LV= 1          TESTNPV 3,(A,(B,C,D)),2
         MNOTE 'NPV 3 EQ 3 OK'
*MEXIT #=    21 LV= 1 TESTNPV
* TEST MACRO LABEL PARAMETERS FOR RPI-633
         MACRO
&N       TESTL
&DN      SETC  (DOUBLE '&N')    RPI-938 RPI-1139
&TN      SETC  T'&N
         MNOTE 'N=&DN TN=&TN'
         MEND
*MCALL #=    22 LV= 1 A+B      TESTL 
         MNOTE 'N=A+B TN=U'
*MEXIT #=    22 LV= 1 TESTL
*MCALL #=    23 LV= 1 A        TESTL 
         MNOTE 'N=A TN=M'
*MEXIT #=    23 LV= 1 TESTL
*MCALL #=    24 LV= 1 1        TESTL 
         MNOTE 'N=1 TN=N'
*MEXIT #=    24 LV= 1 TESTL
*MCALL #=    25 LV= 1 1(2)     TESTL 
         MNOTE 'N=1(2) TN=U'
*MEXIT #=    25 LV= 1 TESTL
*MCALL #=    26 LV= 1 'A'      TESTL 
         MNOTE 'N=''A'' TN=M'
*MEXIT #=    26 LV= 1 TESTL
*MCALL #=    27 LV= 1 TESTPC1  TESTL 
         MNOTE 'N=TESTPC1 TN=M'
*MEXIT #=    27 LV= 1 TESTL
* TEST VAR NAME FIELD IN INLINE MACRO PROTOTYPE
      MACRO
&N    &NAME &TEXT
&DQTEXT SETC '&TEXT'(2,K'&TEXT-2)
&N    MNOTE '&DQTEXT'
      MEND
*MCALL #=    28 LV= 1 A     TESTN 'TEST NAME SUBSTITUTION'
         MNOTE 'TEST NAME SUBSTITUTION'
*MEXIT #=    28 LV= 1 TESTN
      END 
