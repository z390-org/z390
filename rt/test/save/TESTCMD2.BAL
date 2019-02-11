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
         TITLE 'TESTCMD2 TEST USE OF SVC 34 COMMAND PROCESSOR'
*MCALL #=     1 LV= 1 TESTCMD2 SUBENTRY 
TESTCMD2 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTCMD2'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTCMD2+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
         COPY  ASMMSP
         COPY ZSTRMAC  Z390 STRUCTURED PROGRAMMING MACROS
*MCALL #=     2 LV= 1          WTO   'TESTCMD2 TEST SVC 34 CMDPROC MULTX
                TASK SUPPORT'
         BRAS  1,*+(WTO#0002_EOT-*+1)/2*2
         DC    AL2(WTO#0002_EOT-*,0),C'TESTCMD2 TEST SVC 34 CMDPROC MULX
               T TASK SUPPORT'
WTO#0002_EOT     EQU *
         SVC   35
*MEXIT #=     2 LV= 1 WTO
*MCALL #=     3 LV= 1          CMDPROC START,ID=0,CMDLOG=NO  RPI 731
         LA    0,0 ASSUME START WITH NO CMDLOG
         SVC   34 R0=(BYTE3=ID,BYTE4=OP),R1=A(REC),R2=LREC,R3=MILS WAIT
*MEXIT #=     3 LV= 1 CMDPROC
*MCALL #=     4 LV= 1          CMDPROC WRITE,=C'"rt\test\TESTCMDA.BAT"'X
               ,ID=0
         LA    0,2  WRITE CMD TO PROCESS
         LA    1,=C'"rt\test\TESTCMDA.BAT"' EBCDIC NULL TERM OR DQOUTES
         SVC   34 R0=(BYTE3=ID,BYTE4=OP),R1=A(REC),R2=LREC,R3=MILS WAIT
*MEXIT #=     4 LV= 1 CMDPROC
*MCALL #=     5 LV= 1          CMDPROC START,ID=1,CMDLOG=NO  RPI 731
         LA    0,0 ASSUME START WITH NO CMDLOG
         ICM   0,2,=AL1(1)
         SVC   34 R0=(BYTE3=ID,BYTE4=OP),R1=A(REC),R2=LREC,R3=MILS WAIT
*MEXIT #=     5 LV= 1 CMDPROC
*MCALL #=     6 LV= 1          CMDPROC WRITE,=C'"rt\test\TESTCMDB.BAT"'X
               ,ID=1
         LA    0,2  WRITE CMD TO PROCESS
         LA    1,=C'"rt\test\TESTCMDB.BAT"' EBCDIC NULL TERM OR DQOUTES
         ICM   0,2,=AL1(1)
         SVC   34 R0=(BYTE3=ID,BYTE4=OP),R1=A(REC),R2=LREC,R3=MILS WAIT
*MEXIT #=     6 LV= 1 CMDPROC
         LA    R4,50
CMDLOOP  EQU   *
CMDREAD1 EQU   *
         AHI   R4,-1
         BZ    ERROR1
*MCALL #=     7 LV= 1          CMDPROC READ,MSG,ID=0
         LA    0,3 READ CMD OUTPUT LINE
         LA    1,MSG
         LA    2,L'MSG
         LA    3,500
         SVC   34 R0=(BYTE3=ID,BYTE4=OP),R1=A(REC),R2=LREC,R3=MILS WAIT
*MEXIT #=     7 LV= 1 CMDPROC
         CHI   R15,4
         BE    CMDREAD1
         CHI   R15,8
         BE    ERROR1
         MVI   WTOCMD_ID,C'0'
*MCALL #=     8 LV= 1          WTO   MF=(E,WTOCMD)
         LA    1,WTOCMD
         SVC   35
*MEXIT #=     8 LV= 1 WTO
         LA    R1,MSG
         LA    R2,MSG+70
*MCALL #=     9 LV= 1          DO    WHILE=(CR,R1,LT,R2)
*MCALL #=    10 LV= 2          ZSTREQU 
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
*MEXIT #=    10 LV= 2 ZSTREQU
#@DO_1_T                         DS 0H
*MCALL #=    11 LV= 2          IF CR,R1,LT,R2
*MCALL #=    12 LV= 3          ZSTREQU 
*MEXIT #=    12 LV= 3 ZSTREQU
         CR    R1,R2
         BC    15-LT,#@IF_1_2
*MEXIT #=    11 LV= 2 IF
               B   #@DO_1_1
*MCALL #=    13 LV= 2          ENDIF 
*MCALL #=    14 LV= 3          ZSTREQU 
*MEXIT #=    14 LV= 3 ZSTREQU
#@IF_1_2                                                 DS 0H
*MEXIT #=    13 LV= 2 ENDIF
         B     #@DO_1_E
#@DO_1_1                         DS 0H
*MEXIT #=     9 LV= 1 DO
*MCALL #=    15 LV= 1                IF (CLC,0(7,R1),EQ,=C'REM END')
*MCALL #=    16 LV= 2          ZSTREQU 
*MEXIT #=    16 LV= 2 ZSTREQU
         CLC   0(7,R1),=C'REM END'
         BC    15-EQ,#@IF_2_2
*MEXIT #=    15 LV= 1 IF
*MCALL #=    17 LV= 1                   IF (CLI,EOF2,EQ,C'T')
*MCALL #=    18 LV= 2          ZSTREQU 
*MEXIT #=    18 LV= 2 ZSTREQU
         CLI   EOF2,C'T'
         BC    15-EQ,#@IF_3_2
*MEXIT #=    17 LV= 1 IF
                     B  CMDEND
*MCALL #=    19 LV= 1                   ELSE 
*MCALL #=    20 LV= 2          ZSTREQU 
*MEXIT #=    20 LV= 2 ZSTREQU
        B      #@IF_3_E
#@IF_3_2                                                 DS 0H
*MEXIT #=    19 LV= 1 ELSE
                     MVI EOF1,C'T'
*MCALL #=    21 LV= 1                   ENDIF 
*MCALL #=    22 LV= 2          ZSTREQU 
*MEXIT #=    22 LV= 2 ZSTREQU
#@IF_3_E                         DS 0H
*MEXIT #=    21 LV= 1 ENDIF
*MCALL #=    23 LV= 1                ENDIF 
*MCALL #=    24 LV= 2          ZSTREQU 
*MEXIT #=    24 LV= 2 ZSTREQU
#@IF_2_2                                                 DS 0H
*MEXIT #=    23 LV= 1 ENDIF
               AHI  R1,1
*MCALL #=    25 LV= 1          ENDDO 
*MCALL #=    26 LV= 2          DO    END
*MCALL #=    27 LV= 3          ZSTREQU 
*MEXIT #=    27 LV= 3 ZSTREQU
         B     #@DO_1_T
#@DO_1_E                         DS 0H
*MEXIT #=    26 LV= 2 DO
*MEXIT #=    25 LV= 1 ENDDO
CMDREAD2 EQU   *
         AHI   4,-1
         BZ    ERROR2
*MCALL #=    28 LV= 1          CMDPROC READ,MSG,ID=1
         LA    0,3 READ CMD OUTPUT LINE
         LA    1,MSG
         LA    2,L'MSG
         LA    3,500
         ICM   0,2,=AL1(1)
         SVC   34 R0=(BYTE3=ID,BYTE4=OP),R1=A(REC),R2=LREC,R3=MILS WAIT
*MEXIT #=    28 LV= 1 CMDPROC
         CHI   15,4
         BE    CMDREAD2
         CHI   15,8
         BE    ERROR2
         MVI   WTOCMD_ID,C'1'
*MCALL #=    29 LV= 1          WTO   MF=(E,WTOCMD)
         LA    1,WTOCMD
         SVC   35
*MEXIT #=    29 LV= 1 WTO
         LA    R1,MSG
         LA    R2,MSG+70
*MCALL #=    30 LV= 1          DO    WHILE=(CR,R1,LT,R2)
*MCALL #=    31 LV= 2          ZSTREQU 
*MEXIT #=    31 LV= 2 ZSTREQU
#@DO_2_T                         DS 0H
*MCALL #=    32 LV= 2          IF CR,R1,LT,R2
*MCALL #=    33 LV= 3          ZSTREQU 
*MEXIT #=    33 LV= 3 ZSTREQU
         CR    R1,R2
         BC    15-LT,#@IF_4_2
*MEXIT #=    32 LV= 2 IF
               B   #@DO_2_1
*MCALL #=    34 LV= 2          ENDIF 
*MCALL #=    35 LV= 3          ZSTREQU 
*MEXIT #=    35 LV= 3 ZSTREQU
#@IF_4_2                                                 DS 0H
*MEXIT #=    34 LV= 2 ENDIF
         B     #@DO_2_E
#@DO_2_1                         DS 0H
*MEXIT #=    30 LV= 1 DO
*MCALL #=    36 LV= 1                IF (CLC,0(7,R1),EQ,=C'REM END')
*MCALL #=    37 LV= 2          ZSTREQU 
*MEXIT #=    37 LV= 2 ZSTREQU
         CLC   0(7,R1),=C'REM END'
         BC    15-EQ,#@IF_5_2
*MEXIT #=    36 LV= 1 IF
*MCALL #=    38 LV= 1                   IF (CLI,EOF1,EQ,C'T')
*MCALL #=    39 LV= 2          ZSTREQU 
*MEXIT #=    39 LV= 2 ZSTREQU
         CLI   EOF1,C'T'
         BC    15-EQ,#@IF_6_2
*MEXIT #=    38 LV= 1 IF
                     B  CMDEND
*MCALL #=    40 LV= 1                   ELSE 
*MCALL #=    41 LV= 2          ZSTREQU 
*MEXIT #=    41 LV= 2 ZSTREQU
        B      #@IF_6_E
#@IF_6_2                                                 DS 0H
*MEXIT #=    40 LV= 1 ELSE
                     MVI EOF2,C'T'
*MCALL #=    42 LV= 1                   ENDIF 
*MCALL #=    43 LV= 2          ZSTREQU 
*MEXIT #=    43 LV= 2 ZSTREQU
#@IF_6_E                         DS 0H
*MEXIT #=    42 LV= 1 ENDIF
*MCALL #=    44 LV= 1                ENDIF 
*MCALL #=    45 LV= 2          ZSTREQU 
*MEXIT #=    45 LV= 2 ZSTREQU
#@IF_5_2                                                 DS 0H
*MEXIT #=    44 LV= 1 ENDIF
               AHI  R1,1
*MCALL #=    46 LV= 1          ENDDO 
*MCALL #=    47 LV= 2          DO    END
*MCALL #=    48 LV= 3          ZSTREQU 
*MEXIT #=    48 LV= 3 ZSTREQU
         B     #@DO_2_T
#@DO_2_E                         DS 0H
*MEXIT #=    47 LV= 2 DO
*MEXIT #=    46 LV= 1 ENDDO
         B     CMDLOOP
CMDEND   EQU   *
*MCALL #=    49 LV= 1          CMDPROC STOP,ID=0
         LA    0,1  STOP COMMAND PROCESSOR
         SVC   34 R0=(BYTE3=ID,BYTE4=OP),R1=A(REC),R2=LREC,R3=MILS WAIT
*MEXIT #=    49 LV= 1 CMDPROC
*MCALL #=    50 LV= 1          CMDPROC STOP,ID=1
         LA    0,1  STOP COMMAND PROCESSOR
         ICM   0,2,=AL1(1)
         SVC   34 R0=(BYTE3=ID,BYTE4=OP),R1=A(REC),R2=LREC,R3=MILS WAIT
*MEXIT #=    50 LV= 1 CMDPROC
*MCALL #=    51 LV= 1          WTO   'TESTSVC1 ENDING OK'
         BRAS  1,*+(WTO#0051_EOT-*+1)/2*2
         DC    AL2(WTO#0051_EOT-*,0),C'TESTSVC1 ENDING OK'
WTO#0051_EOT     EQU *
         SVC   35
*MEXIT #=    51 LV= 1 WTO
*MCALL #=    52 LV= 1          SUBEXIT 
         LA    15,0
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=    52 LV= 1 SUBEXIT
*MCALL #=    53 LV= 1 ERROR1   WTO   'TESTCMD2 CMD READ1 ERROR'
ERROR1   DS    0H
         BRAS  1,*+(WTO#0053_EOT-*+1)/2*2
         DC    AL2(WTO#0053_EOT-*,0),C'TESTCMD2 CMD READ1 ERROR'
WTO#0053_EOT     EQU *
         SVC   35
*MEXIT #=    53 LV= 1 WTO
*MCALL #=    54 LV= 1          SUBEXIT RC=16
         LA    15,16
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=    54 LV= 1 SUBEXIT
*MCALL #=    55 LV= 1 ERROR2   WTO   'TESTCMD2 CMD READ2 ERROR'
ERROR2   DS    0H
         BRAS  1,*+(WTO#0055_EOT-*+1)/2*2
         DC    AL2(WTO#0055_EOT-*,0),C'TESTCMD2 CMD READ2 ERROR'
WTO#0055_EOT     EQU *
         SVC   35
*MEXIT #=    55 LV= 1 WTO
*MCALL #=    56 LV= 1          SUBEXIT RC=16
         LA    15,16
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=    56 LV= 1 SUBEXIT
WTOCMD   DC    AL2(WTOEND-*,0)
         DC    C'MSG FROM CMD'
WTOCMD_ID DC   C' ='
MSG      DC    CL80' '
WTOEND   EQU   *
EOF1     DC    C'F'
EOF2     DC    C'F'
*MCALL #=    57 LV= 1          EQUREGS 
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
*MEXIT #=    57 LV= 1 EQUREGS
         END 
