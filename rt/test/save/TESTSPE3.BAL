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
         TITLE 'TESTSPE3 - TEST STRUCTURED PROGRAMMING EXTENSIONS'
* TEST ZSTRMAC2 ACASE EXTENSIONS FOR V1,V2,(V3,V4) V=N,C'?',X'??'
         MNOTE 'AWHEN I=0'
         MNOTE 'AWHEN I=1'
         MNOTE 'AWHEN I=3 (3,(5,7),9'
         MNOTE 'AWHEN I=5 (3,(5,7),9'
         MNOTE 'AWHEN I=6 (3,(5,7),9'
         MNOTE 'AWHEN I=7 (3,(5,7),9'
         MNOTE 'AWHEN I=9 (3,(5,7),9'
         MNOTE 'AWHEN I=193 EBCIDC CHAR A'
         MNOTE 'AWHEN I=241 EBCIDC CHAR 1,(2,4),5'
         MNOTE 'AWHEN I=242 EBCIDC CHAR 1,(2,4),5'
         MNOTE 'AWHEN I=243 EBCIDC CHAR 1,(2,4),5'
         MNOTE 'AWHEN I=244 EBCIDC CHAR 1,(2,4),5'
         MNOTE 'AWHEN I=245 EBCIDC CHAR 1,(2,4),5'
         MNOTE 'AWHEN I=250 EBCIDC HEX FA,(FB,FD),FE'
         MNOTE 'AWHEN I=251 EBCIDC HEX FA,(FB,FD),FE'
         MNOTE 'AWHEN I=252 EBCIDC HEX FA,(FB,FD),FE'
         MNOTE 'AWHEN I=253 EBCIDC HEX FA,(FB,FD),FE'
         MNOTE 'AWHEN I=254 EBCIDC HEX FA,(FB,FD),FE'
         MNOTE 'AWHEN I=255 EBCIDC HEX FF'
TESTSPE3 CSECT 
         SR    15,15
         BR    14
         END 
