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
* MZ390E error 142       (1/19)19 OPEN CODE AIF macro label not found -X
                .X11 ABORT ON X117
         MNOTE '.T11'
         MNOTE '.T12'
         MNOTE '.T13'
         END 
* MZ390I total mnote warnings = 0
* MZ390I total mnote errors   = 0
* MZ390I max   mnote level    = 0
* MZ390I total mz390 errors   = 1
