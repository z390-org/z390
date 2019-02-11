*********************************************************************
* Copyright 2007 Automated Software Tools Corporation               *
* Copyright 2013 Cat Herder Software, LLC                           *
* Copyright 2018 Joachim Bartz, Germany                             *
*                                                                   *
* This source code is part of z390 assembler/emulator package.      *
*                                                                   *
* The z390 package is distributed under GNU general public license  *
*                                                                   *
* Author - Don Higgins                                              *
*********************************************************************
* 2007-07-20 DSH          Initial version                           *
*********************************************************************
EMPTY    AMODE ANY
EMPTY    RMODE ANY
*MCALL #=     1 LV= 1          YREGS ,
R0       EQU   0
R1       EQU   1
R2       EQU   2
R3       EQU   3
R4       EQU   4
R5       EQU   5
R6       EQU   6
R7       EQU   7
R8       EQU   8
R9       EQU   9
R10      EQU   10
R11      EQU   11
R12      EQU   12
R13      EQU   13
R14      EQU   14
R15      EQU   15
*MEXIT #=     1 LV= 1 YREGS
*
* Try a normal label
*
A1       LR    R2,R3
A2       LR    R2,R3
A3       2     R2,R3
A4       2     R2,R3
A4       2     R2,R3
*
* Try a comment line
*
*        LR    R2,R3
*        LR    R2,R3
*        2     R2,R3
*        2     R2,R3
*
* Try a macro comment line
*
* MZ390E error 218       (1/42)42 Invalid character in variable label -X
                .*
         LR    R2,R3
* MZ390E error 218       (1/43)43 Invalid character in variable label -X
                .*
         2     R2,R3
* MZ390E error 218       (1/44)44 Invalid character in variable label -X
                .*
* MZ390E abort 84 file=1 line=44 Internal system exception - java.lang.X
               StringIndexOutOfBoundsException: begin 0, end 8, length X
               5
