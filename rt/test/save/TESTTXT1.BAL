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
* 2005-09-30  DSH Initial version                                   *
* 2006-05-03  DSH RPI-268 Add option text and DSNAME= extensions    *
*                 for AREAD and PUNCH to support free form text I/O *
* 2006-09-11  DSH RPI-363 Changed TEST to RT\TEST directory         *
*********************************************************************
* TESTTXT1 is a demo of macro code used with option text to         *
* generate two HTML files as follows:                               *
*   rt\test\TESTTXT1A.HTML HELLO WORLD 1                            *
*   rt\test\TESTTXT1B.HTML HELLO WORLD 2                            *
*********************************************************************
         PUNCH '<HTML><HEAD><TITLE>TEST MZ390 OPTION TEXT AND MULTIPLE X
               FILE OUTPUT</TITLE></HEAD><BODY>HELLO FROM RT\TEST\TESTTX
               XT1A.HTML</BODY></HTML>',DSNAME=&FILE
         PUNCH '<HTML><HEAD><TITLE>TEST MZ390 OPTION TEXT AND MULTIPLE X
               FILE OUTPUT</TITLE></HEAD><BODY>HELLO FROM RT\TEST\TESTTX
               XT1B.HTML</BODY></HTML>',DSNAME=&FILE
         END 
* MZ390I total mnote warnings = 0
* MZ390I total mnote errors   = 0
* MZ390I max   mnote level    = 0
* MZ390I total mz390 errors   = 0
