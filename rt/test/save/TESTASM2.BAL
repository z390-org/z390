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
* 2005-09-30 DSH         Initial version                            *
* 2006-03-17 DSH RPI-239 Test tab vs. spaces before comments        *
*********************************************************************
*                                                                   *
* Note: This source must be edited by Notepad to keep TAB after X.  *
*                                                                   *
*********************************************************************
TESTASM2 CSECT 
         USING *,15
         MVI   X,C'X'
         CLI   X,C'X'
         BNE   1
         SR    15,15
         BR    14
X DS C	TEST TAB BEFORE THIS COMMENT ********
         END 
