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
* 2008-08-18  DSH RPI-901 Move test of OPEN code UNDEF AGO tests to *
*                         TESTERR8.MLC/TESTERR9.MLC                 *
*********************************************************************
* Add compound AIF and computed AGO missing labels
* MZ390E abort 16 file=1 line=20 OPEN CODE undefined .X12,.T13 ABORT ONX
                X12
* MZ390I total mnote warnings = 0
* MZ390I total mnote errors   = 0
* MZ390I max   mnote level    = 0
* MZ390I total mz390 errors   = 1
