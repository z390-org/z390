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
.* USE OPTION PROFILE(TESTPRO1) TO PERFORM THE FOLLOWING FUNCTIONS:  *
.*   1.  EXECUTE MACRO TESTPROS.MAC AT MZ390 STARTUP                 *
.*   2.  EXECUTE MACRO TESTPROT.MAC AT MZ390 TERMINATION             *
.*********************************************************************
         TESTPROS
         MACRO
         END
         TESTPROT
         MEND