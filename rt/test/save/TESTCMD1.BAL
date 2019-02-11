*********************************************************************
* Copyright 2006 Automated Software Tools Corporation               *
* Copyright 2013 Cat Herder Software, LLC                           *
* Copyright 2018 Joachim Bartz, Germany                             *
*                                                                   *
* This source code is part of z390 assembler/emulator package.      *
*                                                                   *
* The z390 package is distributed under GNU general public license  *
*                                                                   *
* Author - Don Higgins                                              *
*********************************************************************
* 2006-09-11 DSH         Initial version                            *
* 2006-09-11 DSH RPI-363 Change from test to rt\test directory      *
* 2007-02-02 DSH RPI-532 Remove Windows prompt and fix path case    *
*                        for Linux                                  *
* 2007-10-30 DSH RPI-731 Add CMDLOG=NO to allow parent task to read *
*                        output                                     *
*********************************************************************
         TITLE 'TESTCMD1 TEST USE OF SVC 34 COMMAND PROCESSOR'
*MCALL #=     1 LV= 1 TESTCMD1 SUBENTRY 
TESTCMD1 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTCMD1'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTCMD1+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
         COPY  ASMMSP
         COPY ZSTRMAC  Z390 STRUCTURED PROGRAMMING MACROS
*MCALL #=     2 LV= 1          WTO   'TESTCMD1 TEST USE OF SVC 34 COMMAX
               ND PROCESSOR'
         BRAS  1,*+(WTO#0002_EOT-*+1)/2*2
         DC    AL2(WTO#0002_EOT-*,0),C'TESTCMD1 TEST USE OF SVC 34 COMMX
               AND PROCESSOR'
WTO#0002_EOT     EQU *
         SVC   35
*MEXIT #=     2 LV= 1 WTO
*MCALL #=     3 LV= 1          CMDPROC START,CMDLOG=NO  RPI-731
         LA    0,0 ASSUME START WITH NO CMDLOG
         SVC   34 R0=(BYTE3=ID,BYTE4=OP),R1=A(REC),R2=LREC,R3=MILS WAIT
*MEXIT #=     3 LV= 1 CMDPROC
*MCALL #=     4 LV= 1          CMDPROC WRITE,=C'"rt\test\TESTCMD1.BAT"'X
                 RPI-532
         LA    0,2  WRITE CMD TO PROCESS
         LA    1,=C'"rt\test\TESTCMD1.BAT"' EBCDIC NULL TERM OR DQOUTES
         SVC   34 R0=(BYTE3=ID,BYTE4=OP),R1=A(REC),R2=LREC,R3=MILS WAIT
*MEXIT #=     4 LV= 1 CMDPROC
         LA    R4,50
CMDLOOP  EQU   *
         AHI   R4,-1
         BZ    ERROR
*MCALL #=     5 LV= 1          CMDPROC READ,MSG
         LA    0,3 READ CMD OUTPUT LINE
         LA    1,MSG
         LA    2,L'MSG
         LA    3,500
         SVC   34 R0=(BYTE3=ID,BYTE4=OP),R1=A(REC),R2=LREC,R3=MILS WAIT
*MEXIT #=     5 LV= 1 CMDPROC
         CHI   R15,4
         BE    CMDLOOP
         CHI   R15,8
         BE    CMDEND
*MCALL #=     6 LV= 1          WTO   MF=(E,WTOCMD)
         LA    1,WTOCMD
         SVC   35
*MEXIT #=     6 LV= 1 WTO
         LA    R1,MSG
         LA    R2,MSG+70
*MCALL #=     7 LV= 1          DO    UNTIL=(CR,R1,GE,R2)
*MCALL #=     8 LV= 2          ZSTREQU 
         PUSH  PRINT,NOPRINT
         PRINT OFF,NOPRINT
H        EQU   2
L        EQU   4
E        EQU   8
NH       EQU   13
NL       EQU   11
NE       EQU   7
O        EQU   1
P        EQU   2
M        EQU   4
Z        EQU   8
NP       EQU   13
NM       EQU   11
NZ       EQU   7
NO       EQU   14
EQ       EQU   8
GT       EQU   2
LT       EQU   4
GE       EQU   11
LE       EQU   13
         POP   PRINT,NOPRINT
*MEXIT #=     8 LV= 2 ZSTREQU
         B     #@DO_1_1
#@DO_1_T                         DS 0H
*MCALL #=     9 LV= 2          IF    CR,R1,GE,R2
*MCALL #=    10 LV= 3          ZSTREQU 
*MEXIT #=    10 LV= 3 ZSTREQU
         CR    R1,R2
         BC    15-GE,#@IF_1_2
*MEXIT #=     9 LV= 2 IF
               B     #@DO_1_E
*MCALL #=    11 LV= 2          ENDIF 
*MCALL #=    12 LV= 3          ZSTREQU 
*MEXIT #=    12 LV= 3 ZSTREQU
#@IF_1_2                                                 DS 0H
*MEXIT #=    11 LV= 2 ENDIF
#@DO_1_1                         DS 0H
*MEXIT #=     7 LV= 1 DO
*MCALL #=    13 LV= 1                IF (CLC,0(7,R1),EQ,=C'REM END')
*MCALL #=    14 LV= 2          ZSTREQU 
*MEXIT #=    14 LV= 2 ZSTREQU
         CLC   0(7,R1),=C'REM END'
         BC    15-EQ,#@IF_2_2
*MEXIT #=    13 LV= 1 IF
                  B CMDEND
*MCALL #=    15 LV= 1                ENDIF 
*MCALL #=    16 LV= 2          ZSTREQU 
*MEXIT #=    16 LV= 2 ZSTREQU
#@IF_2_2                                                 DS 0H
*MEXIT #=    15 LV= 1 ENDIF
               AHI R1,1
*MCALL #=    17 LV= 1          ENDDO 
*MCALL #=    18 LV= 2          DO    END
*MCALL #=    19 LV= 3          ZSTREQU 
*MEXIT #=    19 LV= 3 ZSTREQU
         B     #@DO_1_T
#@DO_1_E                         DS 0H
*MEXIT #=    18 LV= 2 DO
*MEXIT #=    17 LV= 1 ENDDO
         B     CMDLOOP
CMDEND   EQU   *
*MCALL #=    20 LV= 1          CMDPROC STOP
         LA    0,1  STOP COMMAND PROCESSOR
         SVC   34 R0=(BYTE3=ID,BYTE4=OP),R1=A(REC),R2=LREC,R3=MILS WAIT
*MEXIT #=    20 LV= 1 CMDPROC
*MCALL #=    21 LV= 1          WTO   'TESTSVC1 ENDING OK'
         BRAS  1,*+(WTO#0021_EOT-*+1)/2*2
         DC    AL2(WTO#0021_EOT-*,0),C'TESTSVC1 ENDING OK'
WTO#0021_EOT     EQU *
         SVC   35
*MEXIT #=    21 LV= 1 WTO
*MCALL #=    22 LV= 1          SUBEXIT 
         LA    15,0
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=    22 LV= 1 SUBEXIT
*MCALL #=    23 LV= 1 ERROR    WTO   'TESTCMD1 COMMAND ERROR'
ERROR    DS    0H
         BRAS  1,*+(WTO#0023_EOT-*+1)/2*2
         DC    AL2(WTO#0023_EOT-*,0),C'TESTCMD1 COMMAND ERROR'
WTO#0023_EOT     EQU *
         SVC   35
*MEXIT #=    23 LV= 1 WTO
*MCALL #=    24 LV= 1          SUBEXIT RC=16
         LA    15,16
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=    24 LV= 1 SUBEXIT
WTOCMD   DC    AL2(WTOEND-*,0)
         DC    C'MSG FROM CMD='
MSG      DC    CL80' '
WTOEND   EQU   *
*MCALL #=    25 LV= 1          EQUREGS 
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
*MEXIT #=    25 LV= 1 EQUREGS
         END 
