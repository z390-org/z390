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
*********************************************************************
* 2006-08-08  DSH          Initial version                          *
* 2006-08-09  DSH RPI-404  Test B2A C2A D2A DCLEN SLA SLL SRA SRL   *
*                          X2A
* 2006-08-09  DSH RPI-405  Test O'OPCODE                            *
* 2006-08-27  DSH RPI-415  Correct ATTRA to valid code GR32         *
* 2006-08-29  DSH RPI-421  Test duplication operator after .        *
* 2006-10-22  DSH RPI-467  Test duplication operator after .        *
* 2007-07-05  DSH RPI-646  Add test for index and find old/new      *
*                          formats                                  *
* 2008-04-19  DSH RPI-833  Add string quotes for HLASM compatibility*
* 2008-07-30  DSH RPI-886  Correct function name DCEQUO to DEQUOTE  *
* 2008-11-07  DSH RPI-938  Correct missing ending quote on MNOTE    *
* 2008-11-09  DSH RPI-943  Use signed function to display negative  *
*                          values                                   *
* 2009-09-21  DSH RPI-1080 Correct test for DCLEN and DCVAL         *
* 2010-01-10  DSH RPI-1101 Correct C2X length = 2 * CHAR            *
* 2010-01-14  DSH RPI-1105 A2B > 32 CHAR 0/1'S                      *
* 2011-01-25  DSH RPI-1139 Add quotes for UPPER/LOWER for NOALLOW   *
*********************************************************************
*MCALL #=     1 LV= 1 TESTOPR1 SUBENTRY 
TESTOPR1 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTOPR1'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTOPR1+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
*MCALL #=     2 LV= 1          WTO   'TESTOPR1 TEST OPERATORS UPPER, LOX
               WER, ETC.'
         BRAS  1,*+(WTO#0002_EOT-*+1)/2*2
         DC    AL2(WTO#0002_EOT-*,0),C'TESTOPR1 TEST OPERATORS UPPER, LX
               OWER, ETC.'
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
SYM      EQU   1,2,C'3',C'PGMA',gr32
         MNOTE 'TESTOPR1 PASS 1'
         MNOTE 'TESTING UPPER AND LOWER'
         MNOTE 'TESTING ?2? PREFIX OPERATORS'
         MNOTE 'A2B(4)=00000000000000000000000000000100'               X
                           RPI-1105
         MNOTE 'A2C(241)=...1'
         MNOTE 'A2D(241)=+241'
         MNOTE 'A2D(-241)=-241'
         MNOTE 'A2X(241)=000000F1'
         MNOTE 'B2A('100')=4'
         MNOTE 'B2C('11110001')=...1'
         MNOTE 'B2D('100')=4'
         MNOTE 'B2X('11110001')=000000F1'
         MNOTE 'C2A('1')=241'
         MNOTE 'C2B('1')=11110001'
         MNOTE 'C2D('1')=241'
         MNOTE 'C2X('1')=F1'
         MNOTE 'D2A('-1')=-1'
         MNOTE 'D2B('1')=11110001'
         MNOTE 'D2C('1')=...1'
         MNOTE 'D2X('241')=000000F1'
         MNOTE 'X2A('F1')=241'
         MNOTE 'X2B('1F')=00011111'
         MNOTE 'X2C('F1')=...1'
         MNOTE 'X2D('F1')=241'
         MNOTE 'TESTING DCLEN, DCVAL, DEQUOTE'
         MNOTE 'DCLEN(''''&&&&1'''')=7'
         MNOTE 'DCVAL(''&&1'')='&1''
         MNOTE 'DEQUOTE('ABC')=ABC'
         MNOTE 'TESTING ISBIN, ISDEC, ISHEX, ISSYM'
         MNOTE 'ISBIN('100')=1'
         MNOTE 'ISBIN('123')=0'
         MNOTE 'ISDEC('123')=1'
         MNOTE 'ISDEC('F1')=0'
         MNOTE 'ISHEX('F1')=1'
         MNOTE 'ISHEX('FG')=0'
         MNOTE 'ISSYM('AZ09@#$_')=1'
         MNOTE 'ISSYM('AZ09@#$_**')=0'
         MNOTE 'TESTING SIGNED, SYSATTRA, SYSATTRP'
         MNOTE 'SIGNED(-241)=-241'
         MNOTE 'SYSATTRP(SYM)=PGMA'
         MNOTE 'SYSATTRA(SYM)=GR32'
         MNOTE 'TESTING SLA, SLL, SRA, SRL'
         MNOTE '1 SLA 2 = 4'
         MNOTE 'X'7FFFFFFF' SLA 1 = 2147483646'
         MNOTE '1 SLL 2 = 4'
         MNOTE 'X'7FFFFFFF' SLL 1 = -2'
         MNOTE '4 SLA 2 = 1'
         MNOTE 'X'FFFFFFFF' SRA 1 = -1'
         MNOTE '4 SRL 2 = 1'
         MNOTE 'X'7FFFFFFF' SRL 1 = 2147483647'
         MNOTE 'TESTING OPERATOR TYPES A,E,M,O,S,U'
         MNOTE 'TESTING STRING DUPLICATION IN EXPRESSION'
         MNOTE 'TEST FIND'
         MNOTE 'TEST INDEX'
         MNOTE 'TESTOPR1 PASS 2'
         MNOTE 'TESTING UPPER AND LOWER'
         MNOTE 'TESTING ?2? PREFIX OPERATORS'
         MNOTE 'A2B(4)=00000000000000000000000000000100'               X
                           RPI-1105
         MNOTE 'A2C(241)=...1'
         MNOTE 'A2D(241)=+241'
         MNOTE 'A2D(-241)=-241'
         MNOTE 'A2X(241)=000000F1'
         MNOTE 'B2A('100')=4'
         MNOTE 'B2C('11110001')=...1'
         MNOTE 'B2D('100')=4'
         MNOTE 'B2X('11110001')=000000F1'
         MNOTE 'C2A('1')=241'
         MNOTE 'C2B('1')=11110001'
         MNOTE 'C2D('1')=241'
         MNOTE 'C2X('1')=F1'
         MNOTE 'D2A('-1')=-1'
         MNOTE 'D2B('1')=11110001'
         MNOTE 'D2C('1')=...1'
         MNOTE 'D2X('241')=000000F1'
         MNOTE 'X2A('F1')=241'
         MNOTE 'X2B('1F')=00011111'
         MNOTE 'X2C('F1')=...1'
         MNOTE 'X2D('F1')=241'
         MNOTE 'TESTING DCLEN, DCVAL, DEQUOTE'
         MNOTE 'DCLEN(''''&&&&1'''')=7'
         MNOTE 'DCVAL(''&&1'')='&1''
         MNOTE 'DEQUOTE('ABC')=ABC'
         MNOTE 'TESTING ISBIN, ISDEC, ISHEX, ISSYM'
         MNOTE 'ISBIN('100')=1'
         MNOTE 'ISBIN('123')=0'
         MNOTE 'ISDEC('123')=1'
         MNOTE 'ISDEC('F1')=0'
         MNOTE 'ISHEX('F1')=1'
         MNOTE 'ISHEX('FG')=0'
         MNOTE 'ISSYM('AZ09@#$_')=1'
         MNOTE 'ISSYM('AZ09@#$_**')=0'
         MNOTE 'TESTING SIGNED, SYSATTRA, SYSATTRP'
         MNOTE 'SIGNED(-241)=-241'
         MNOTE 'SYSATTRP(SYM)=PGMA'
         MNOTE 'SYSATTRA(SYM)=GR32'
         MNOTE 'TESTING SLA, SLL, SRA, SRL'
         MNOTE '1 SLA 2 = 4'
         MNOTE 'X'7FFFFFFF' SLA 1 = 2147483646'
         MNOTE '1 SLL 2 = 4'
         MNOTE 'X'7FFFFFFF' SLL 1 = -2'
         MNOTE '4 SLA 2 = 1'
         MNOTE 'X'FFFFFFFF' SRA 1 = -1'
         MNOTE '4 SRL 2 = 1'
         MNOTE 'X'7FFFFFFF' SRL 1 = 2147483647'
         MNOTE 'TESTING OPERATOR TYPES A,E,M,O,S,U'
         MNOTE 'TESTING STRING DUPLICATION IN EXPRESSION'
         MNOTE 'TEST FIND'
         MNOTE 'TEST INDEX'
         MNOTE 'TESTOPR1 ENDED OK'
         END 
