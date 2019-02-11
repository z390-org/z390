* MZ390E error 111       (1/40)40 OPEN CODE duplicate .LAB1 at 38
         MNOTE 4,'Macro OPEN CODE undefined .UNDEFINED1 at    (1/41) '
         MNOTE 4,'Macro OPEN CODE undefined .UNDEFINED2 at    (1/42) '
         MNOTE 4,'Macro OPEN CODE undefined .X11 at    (1/45) '
         MNOTE 4,'Macro OPEN CODE undefined .X12 at    (1/46) '
*********************************************************************
* Copyright 2009 Automated Software Tools Corporation               *
* Copyright 2013 Cat Herder Software, LLC                           *
* Copyright 2018 Joachim Bartz, Germany                             *
*                                                                   *
* This source code is part of z390 assembler/emulator package.      *
*                                                                   *
* The z390 package is distributed under GNU general public license  *
*                                                                   *
* Author - Don Higgins                                              *
*********************************************************************
* 2009-06-15 DSH          Initial version                           *
* 2009-06-15 DSH RPI-1053 Move invalid ASCII test and missing macro *
*                         warn from TESTERR1 and specify ASM and    *
*                         CHKMAC(2).                                *
*********************************************************************
         TITLE 'TESTERRA TEST INVALID ASCII,missing labels CHKMAC(2)'
TESTERR1 CSECT 
         USING *,15
* RPI-744 Test non-ascii character string error
         DC   C'e…'  MULTI-KEY VALUES 101 AND 201
**********************************************************
* ADD DUPLICATE AND MISSING MACRO ERRORS IN OPEN CODE
*
* THIS MUST BE LAST TEST WITH FAILING AGO IN OPEN CODE
*
**********************************************************
         MACRO
         TESTLAB
.LAB1    ANOP
.LAB2    ANOP
.LAB1    ANOP
* MZ390E error 111       (1/34)34 TESTLAB duplicate .LAB1 at 32
         AGO    .UNDEFINED1
         AIF    (1 EQ 1).UNDEFINED2
         MEND
         MNOTE 4,'Macro TESTLAB undefined .UNDEFINED1 at    (1/35) '
         MNOTE 4,'Macro TESTLAB undefined .UNDEFINED2 at    (1/36) '
* MZ390E abort 16 file=1 line=41 OPEN CODE undefined .UNDEFINED1
