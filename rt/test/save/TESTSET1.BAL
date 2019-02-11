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
* 2005-12-08  DSH RPI-119  Add tests for multiple value sets        *
* 2006-03-20  DSH RPI-242  Add test for LCLC and GBLC init error    *
* 2006-08-07  DSH RPI-401  Test expansion via multiple store values *
* 2006-09-08  DSH RPI-435  Test dynamic alloc of local arrays       *
* 2006-09-21  DSH RPI-445  Test dynamic array expansion copy and    *
*                          extend                                   *
* 2006-09-21  DSH RPI-446  Test NOT D'SYMBOL                        *
* 2006-09-21  DSH RPI-456  Test duplication operator within         *
*                          expression                               *
* 2007-02-15  DSH RPI-559  Test &VAR(N'&VAR)                        *
* 2008-04-22  DSH RPI-833  Add string quotes for HLASM compatibility*
* 2008-04-24  DSH RPI-839  Test skipping elements in mult SET STORE *
* 2008-11-08  DSH RPI-938  Remove single quote from MNOTE text      *
* 2010-01-14  DSH RPI-1105 SETB returns 0 or 1 vs 0-255             *
* 2011-04-08  DSH RPI-1139 Fix dup GBL/LCL                          *
*********************************************************************
*MCALL #=     1 LV= 1 TESTSET1 SUBENTRY 
TESTSET1 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTSET1'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTSET1+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
*MCALL #=     2 LV= 1          WTO   'TESTSET1 - TEST SUBSCRIPTED VARIAX
               BLES'
         BRAS  1,*+(WTO#0002_EOT-*+1)/2*2
         DC    AL2(WTO#0002_EOT-*,0),C'TESTSET1 - TEST SUBSCRIPTED VARIX
               ABLES'
WTO#0002_EOT     EQU *
         SVC   35
*MEXIT #=     2 LV= 1 WTO
*
* TEST SETA
*
         MNOTE 'A(1)=1 A(2)=2'
         MNOTE 'B(1)=1 B(2)=2'
*
* TEST SETB
*
         MNOTE 'C(1)=0 C(2)=1'
         MNOTE 'D(1)=0 D(2)=1'
*
* TEST SETC
*
         MNOTE 'T1(1)=A T2(2)=AB'
         MNOTE 'TEXT=ZXABCZ'
*
* test upper and lower case ordinary symbols
*
         B     ok2
*MCALL #=     3 LV= 1          WTO   'LC label error'
         BRAS  1,*+(WTO#0003_EOT-*+1)/2*2
         DC    AL2(WTO#0003_EOT-*,0),C'LC label error'
WTO#0003_EOT     EQU *
         SVC   35
*MEXIT #=     3 LV= 1 WTO
OK2      EQU   *
         B     OK3
*MCALL #=     4 LV= 1          WTO   'LC label error'
         BRAS  1,*+(WTO#0004_EOT-*+1)/2*2
         DC    AL2(WTO#0004_EOT-*,0),C'LC label error'
WTO#0004_EOT     EQU *
         SVC   35
*MEXIT #=     4 LV= 1 WTO
ok3      EQU   *
*
* TEST MULT VALUE SETS
*
* TEST UNARY +- IN PARENS
* TEST LCLC AND GBLC INIT ERROR
* TEST EXPANSION VIA MULT. STORE
* TEST ALLOC OF SUBSCRIPTED ARRAY WITHOUT DECLARATION
         MNOTE 'DX(3)=1 DX(8)=0 OK'
* TEST EXPANSION COPY AND EXTEND RPI 445
         MNOTE 'DY(3)=3 DY(800)=800 OK'
* TEST SUBSTRING * AND NOT D' OPERATION RPI 446
         MNOTE 'YL6=234567'
         MNOTE 'TESTSET1 DEFINED OK'
* TEST DUPLICATION OPERATOR WITHIN EXPRESSION RPI 456
         MNOTE '2X2Y=XXYY'
* TEXT &VAR(N'&VAR)
         MNOTE 'VAR(3)=3=3'
* TEST SKIPPING ELEMENTS AND PC CODE RPI 839
         MNOTE 'MA(1)=1'
         MNOTE 'MA(2)=0'
         MNOTE 'MA(3)=3'
         MNOTE 'MA(4)=4'
         MNOTE 'MA(5)=5'
         MNOTE 'MA(6)=6'
         MNOTE 'MB(1)=1'
         MNOTE 'MB(2)=0'
         MNOTE 'MB(3)=1'
         MNOTE 'MB(4)=1'
         MNOTE 'MB(5)=1'
         MNOTE 'MB(6)=1'
         MNOTE 'MC(1)=1'
         MNOTE 'MC(2)='
         MNOTE 'MC(3)=3'
         MNOTE 'MC(4)=4'
         MNOTE 'MC(5)=5'
         MNOTE 'MC(6)=6'
         MNOTE 'MA(1)=1'
         MNOTE 'MA(2)=0'
         MNOTE 'MA(3)=3'
         MNOTE 'MA(4)=4'
         MNOTE 'MA(5)=5'
         MNOTE 'MA(6)=6'
         MNOTE 'MB(1)=1'
         MNOTE 'MB(2)=0'
         MNOTE 'MB(3)=1'
         MNOTE 'MB(4)=1'
         MNOTE 'MB(5)=1'
         MNOTE 'MB(6)=1'
         MNOTE 'MC(1)=1'
         MNOTE 'MC(2)='
         MNOTE 'MC(3)=3'
         MNOTE 'MC(4)=4'
         MNOTE 'MC(5)=5'
         MNOTE 'MC(6)=6'
*
* END OF TESTS
*
*MCALL #=     5 LV= 1          WTO   'TESTSET1 ENDED OK'
         BRAS  1,*+(WTO#0005_EOT-*+1)/2*2
         DC    AL2(WTO#0005_EOT-*,0),C'TESTSET1 ENDED OK'
WTO#0005_EOT     EQU *
         SVC   35
*MEXIT #=     5 LV= 1 WTO
*MCALL #=     6 LV= 1          SUBEXIT 
         LA    15,0
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=     6 LV= 1 SUBEXIT
         END 
