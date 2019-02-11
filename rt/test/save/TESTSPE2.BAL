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
* 2008-08-13 DSH         Initial version                            *
* 2008-09-17 DSH RPI-911 Change ASELECT to ACASE and APM to ACALL   *
* 2008-09-23 DSH RPI-911 New regression test for SPM's              *
*********************************************************************
         TITLE 'TESTSPE2 - TEST STRUCTURED PROGRAMMING EXTENSIONS'
* TEST ZSTRMAC SPE'S IN LOWER CASE
         MNOTE 'AIF TRUE I=1'
         MNOTE 'AELSEIF TRUE I=2'
         MNOTE 'AUNTIL 1-5 I=1'
         MNOTE 'AUNTIL 1-5 I=2'
         MNOTE 'AUNTIL 1-5 I=3'
         MNOTE 'EXITING AUNTIL IF I=3'
         MNOTE 'AWHILE 1-5 I=1'
         MNOTE 'AWHILE 1-5 I=2'
         MNOTE 'AWHILE 1-5 I=3'
         MNOTE 'AWHILE 1-5 I=4'
         MNOTE 'AWHILE 1-5 I=5'
         MNOTE 'COUNT=1'
         MNOTE 'COUNT=2'
         MNOTE 'AELSE I=0'
         MNOTE 'AWHEN I=1'
         MNOTE 'AWHEN I=2'
         MNOTE 'AELSE J=0'
         MNOTE 'AWHEN J=1'
         MNOTE 'AWHEN J=2'
         MNOTE 'AWHEN J=3'
         MNOTE 'AELSE J=4'
         MNOTE 'AWHEN I=3'
         MNOTE 'AELSE I=4'
* PERFORMED ROUTINES
* ASM PGM
TESTSPE2 CSECT 
         SR    15,15
         BR    14
         END 
