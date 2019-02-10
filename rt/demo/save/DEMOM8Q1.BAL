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
* Notes:                                                            *
* * Compiling this module will generate code only.                  *
*   See resulting ERR and PRN files after assembling.               *
* * The generated OBJ file will have no CSECT and so no 390         *
*   executable file can be built.                                   *
*********************************************************************
* 2005-09-30  DSH Initial version                                   *
*********************************************************************
*
         TITLE 'DEMOM8Q1.MLC - 8 QUEEENS CHESS PROBLEM SOLUTION'
         MACRO
         M8Q
         GBLA  &N,&X(8)
         GBLB  &COL(8),&UP(15),&DOWN(15)
         LCLA  &H
&H       SETA  1
         AIF   (&N GT 0).LOOP
&N       SETA  1
.LOOP    ANOP
         AIF   (&COL(&H) NE 0).NEXT
         AIF   (&UP(&N-&H+8) NE 0).NEXT
         AIF   (&DOWN(&N+&H-1) NE 0).NEXT
&X(&N)        SETA &H
&COL(&H)      SETB 1
&UP(&N-&H+8)   SETB 1
&DOWN(&N+&H-1) SETB 1
&N            SETA &N+1
         AIF   (&N GT 8).PRINT
         M8Q
         AGO  .CONT
.PRINT   ANOP
 MNOTE 'SOLUTION &X(1) &X(2) &X(3) &X(4) &X(5) &X(6) &X(7) &X(8)'
.CONT    ANOP
&N             SETA  &N-1
&DOWN(&N+&H-1) SETB 0
&UP(&N-&H+8)   SETB 0
&COL(&H)       SETB 0
.NEXT    ANOP
&H       SETA  &H+1
         AIF   (&H LE 8).LOOP
         MEND
         MNOTE 'SOLUTION 1 5 8 6 3 7 2 4'
         MNOTE 'SOLUTION 1 6 8 3 7 4 2 5'
         MNOTE 'SOLUTION 1 7 4 6 8 2 5 3'
         MNOTE 'SOLUTION 1 7 5 8 2 4 6 3'
         MNOTE 'SOLUTION 2 4 6 8 3 1 7 5'
         MNOTE 'SOLUTION 2 5 7 1 3 8 6 4'
         MNOTE 'SOLUTION 2 5 7 4 1 8 6 3'
         MNOTE 'SOLUTION 2 6 1 7 4 8 3 5'
         MNOTE 'SOLUTION 2 6 8 3 1 4 7 5'
         MNOTE 'SOLUTION 2 7 3 6 8 5 1 4'
         MNOTE 'SOLUTION 2 7 5 8 1 4 6 3'
         MNOTE 'SOLUTION 2 8 6 1 3 5 7 4'
         MNOTE 'SOLUTION 3 1 7 5 8 2 4 6'
         MNOTE 'SOLUTION 3 5 2 8 1 7 4 6'
         MNOTE 'SOLUTION 3 5 2 8 6 4 7 1'
         MNOTE 'SOLUTION 3 5 7 1 4 2 8 6'
         MNOTE 'SOLUTION 3 5 8 4 1 7 2 6'
         MNOTE 'SOLUTION 3 6 2 5 8 1 7 4'
         MNOTE 'SOLUTION 3 6 2 7 1 4 8 5'
         MNOTE 'SOLUTION 3 6 2 7 5 1 8 4'
         MNOTE 'SOLUTION 3 6 4 1 8 5 7 2'
         MNOTE 'SOLUTION 3 6 4 2 8 5 7 1'
         MNOTE 'SOLUTION 3 6 8 1 4 7 5 2'
         MNOTE 'SOLUTION 3 6 8 1 5 7 2 4'
         MNOTE 'SOLUTION 3 6 8 2 4 1 7 5'
         MNOTE 'SOLUTION 3 7 2 8 5 1 4 6'
         MNOTE 'SOLUTION 3 7 2 8 6 4 1 5'
         MNOTE 'SOLUTION 3 8 4 7 1 6 2 5'
         MNOTE 'SOLUTION 4 1 5 8 2 7 3 6'
         MNOTE 'SOLUTION 4 1 5 8 6 3 7 2'
         MNOTE 'SOLUTION 4 2 5 8 6 1 3 7'
         MNOTE 'SOLUTION 4 2 7 3 6 8 1 5'
         MNOTE 'SOLUTION 4 2 7 3 6 8 5 1'
         MNOTE 'SOLUTION 4 2 7 5 1 8 6 3'
         MNOTE 'SOLUTION 4 2 8 5 7 1 3 6'
         MNOTE 'SOLUTION 4 2 8 6 1 3 5 7'
         MNOTE 'SOLUTION 4 6 1 5 2 8 3 7'
         MNOTE 'SOLUTION 4 6 8 2 7 1 3 5'
         MNOTE 'SOLUTION 4 6 8 3 1 7 5 2'
         MNOTE 'SOLUTION 4 7 1 8 5 2 6 3'
         MNOTE 'SOLUTION 4 7 3 8 2 5 1 6'
         MNOTE 'SOLUTION 4 7 5 2 6 1 3 8'
         MNOTE 'SOLUTION 4 7 5 3 1 6 8 2'
         MNOTE 'SOLUTION 4 8 1 3 6 2 7 5'
         MNOTE 'SOLUTION 4 8 1 5 7 2 6 3'
         MNOTE 'SOLUTION 4 8 5 3 1 7 2 6'
         MNOTE 'SOLUTION 5 1 4 6 8 2 7 3'
         MNOTE 'SOLUTION 5 1 8 4 2 7 3 6'
         MNOTE 'SOLUTION 5 1 8 6 3 7 2 4'
         MNOTE 'SOLUTION 5 2 4 6 8 3 1 7'
         MNOTE 'SOLUTION 5 2 4 7 3 8 6 1'
         MNOTE 'SOLUTION 5 2 6 1 7 4 8 3'
         MNOTE 'SOLUTION 5 2 8 1 4 7 3 6'
         MNOTE 'SOLUTION 5 3 1 6 8 2 4 7'
         MNOTE 'SOLUTION 5 3 1 7 2 8 6 4'
         MNOTE 'SOLUTION 5 3 8 4 7 1 6 2'
         MNOTE 'SOLUTION 5 7 1 3 8 6 4 2'
         MNOTE 'SOLUTION 5 7 1 4 2 8 6 3'
         MNOTE 'SOLUTION 5 7 2 4 8 1 3 6'
         MNOTE 'SOLUTION 5 7 2 6 3 1 4 8'
         MNOTE 'SOLUTION 5 7 2 6 3 1 8 4'
         MNOTE 'SOLUTION 5 7 4 1 3 8 6 2'
         MNOTE 'SOLUTION 5 8 4 1 3 6 2 7'
         MNOTE 'SOLUTION 5 8 4 1 7 2 6 3'
         MNOTE 'SOLUTION 6 1 5 2 8 3 7 4'
         MNOTE 'SOLUTION 6 2 7 1 3 5 8 4'
         MNOTE 'SOLUTION 6 2 7 1 4 8 5 3'
         MNOTE 'SOLUTION 6 3 1 7 5 8 2 4'
         MNOTE 'SOLUTION 6 3 1 8 4 2 7 5'
         MNOTE 'SOLUTION 6 3 1 8 5 2 4 7'
         MNOTE 'SOLUTION 6 3 5 7 1 4 2 8'
         MNOTE 'SOLUTION 6 3 5 8 1 4 2 7'
         MNOTE 'SOLUTION 6 3 7 2 4 8 1 5'
         MNOTE 'SOLUTION 6 3 7 2 8 5 1 4'
         MNOTE 'SOLUTION 6 3 7 4 1 8 2 5'
         MNOTE 'SOLUTION 6 4 1 5 8 2 7 3'
         MNOTE 'SOLUTION 6 4 2 8 5 7 1 3'
         MNOTE 'SOLUTION 6 4 7 1 3 5 2 8'
         MNOTE 'SOLUTION 6 4 7 1 8 2 5 3'
         MNOTE 'SOLUTION 6 8 2 4 1 7 5 3'
         MNOTE 'SOLUTION 7 1 3 8 6 4 2 5'
         MNOTE 'SOLUTION 7 2 4 1 8 5 3 6'
         MNOTE 'SOLUTION 7 2 6 3 1 4 8 5'
         MNOTE 'SOLUTION 7 3 1 6 8 5 2 4'
         MNOTE 'SOLUTION 7 3 8 2 5 1 6 4'
         MNOTE 'SOLUTION 7 4 2 5 8 1 3 6'
         MNOTE 'SOLUTION 7 4 2 8 6 1 3 5'
         MNOTE 'SOLUTION 7 5 3 1 6 8 2 4'
         MNOTE 'SOLUTION 8 2 4 1 7 5 3 6'
         MNOTE 'SOLUTION 8 2 5 3 1 7 4 6'
         MNOTE 'SOLUTION 8 3 1 6 2 5 7 4'
         MNOTE 'SOLUTION 8 4 1 3 6 2 7 5'
         END 
* MZ390I total mnote warnings = 0
* MZ390I total mnote errors   = 0
* MZ390I max   mnote level    = 0
* MZ390I total mz390 errors   = 0
