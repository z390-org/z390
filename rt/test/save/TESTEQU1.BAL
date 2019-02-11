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
* 2005-12-08  DSH         Initial version                           *
* 2005-12-08  DSH RPI-119 Add MZ390 only test for EQUREG options    *
*********************************************************************
*MCALL #=     1 LV= 1          EQUREGS 
R0     EQU 0
R1     EQU 1
R2     EQU 2
R3     EQU 3
R4     EQU 4
R5     EQU 5
R6     EQU 6
R7     EQU 7
R8     EQU 8
R9     EQU 9
R10    EQU 10
R11    EQU 11
R12    EQU 12
R13    EQU 13
R14    EQU 14
R15    EQU 15
*MEXIT #=     1 LV= 1 EQUREGS
*MCALL #=     2 LV= 1          EQUREGS REGS=FPR
F0     EQU 0
F1     EQU 1
F2     EQU 2
F3     EQU 3
F4     EQU 4
F5     EQU 5
F6     EQU 6
F7     EQU 7
F8     EQU 8
F9     EQU 9
F10    EQU 10
F11    EQU 11
F12    EQU 12
F13    EQU 13
F14    EQU 14
F15    EQU 15
*MEXIT #=     2 LV= 1 EQUREGS
*MCALL #=     3 LV= 1          EQUREGS TYPE=HEX
R0             EQU 0
R1             EQU 1
R2             EQU 2
R3             EQU 3
R4             EQU 4
R5             EQU 5
R6             EQU 6
R7             EQU 7
R8             EQU 8
R9             EQU 9
RA             EQU 10
RB             EQU 11
RC             EQU 12
RD             EQU 13
RE             EQU 14
RF             EQU 15
*MEXIT #=     3 LV= 1 EQUREGS
*MCALL #=     4 LV= 1          EQUREGS REGS=FPR,TYPE=HEX
F0             EQU 0
F1             EQU 1
F2             EQU 2
F3             EQU 3
F4             EQU 4
F5             EQU 5
F6             EQU 6
F7             EQU 7
F8             EQU 8
F9             EQU 9
FA             EQU 10
FB             EQU 11
FC             EQU 12
FD             EQU 13
FE             EQU 14
FF             EQU 15
*MEXIT #=     4 LV= 1 EQUREGS
         END 
* MZ390I total mnote warnings = 0
* MZ390I total mnote errors   = 0
* MZ390I max   mnote level    = 0
* MZ390I total mz390 errors   = 0
