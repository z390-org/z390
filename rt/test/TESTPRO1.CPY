.*********************************************************************
.* Copyright 2006 Automated Software Tools Corporation               *
.* Copyright 2013 Cat Herder Software, LLC                           *
.* Copyright 2018 Joachim Bartz, Germany                             *
.*                                                                   *
.* This source code is part of z390 assembler/emulator package.      *
.*                                                                   *
.* The z390 package is distributed under GNU general public license  *
.*                                                                   *
.* Author - Don Higgins                                              *
.*********************************************************************
.* 2006-04-09  DSH         Initial version                           *
.* 2006-04-09  DSH RPI-276 Test MZ390 option PROFILE(TESTPRO1.CPY)   *
.*********************************************************************

.*********************************************************************
.* Use OPTION PROFILE(TESTPRO1) to perform the following functions:  *
.*   1.  Execute macro TESTPROS.MAC at MZ390 startup                 *
.*   2.  Execute macro TESTPROT.MAC at MZ390 termination             *
.*********************************************************************
         TESTPROS
         MACRO
         END
         TESTPROT
         MEND