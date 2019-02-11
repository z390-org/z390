*********************************************************************
* Copyright 2009 Automated Software Tools Corporation               *
* Copyright 2013 Cat Herder Software, LLC                           *
* Copyright 2018 Joachim Bartz, Germany                             *
*                                                                   *
* This source code is part of z390 assembler/emulator package.      *
*                                                                   *
* The z390 package is distributed under GNU general public license  *
*                                                                   *
* Author - Don Higgins                                              *
*********************************************************************
* 2009-09-16  DSH          Initial version                          *
* 2009-09-19  DSH RPI-1063 List CDE's to test user interface        *
*********************************************************************
* MAINTENANCE
*********************************************************************
*MCALL #=     1 LV= 1 TESTCDE1 SUBENTRY 
TESTCDE1 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTCDE1'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTCDE1+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
*MCALL #=     2 LV= 1          WTO   'TESTCDE1 - LIST CURRENT CDE ENTRIX
               ES'
         BRAS  1,*+(WTO#0002_EOT-*+1)/2*2
         DC    AL2(WTO#0002_EOT-*,0),C'TESTCDE1 - LIST CURRENT CDE ENTRX
               IES'
WTO#0002_EOT     EQU *
         SVC   35
*MEXIT #=     2 LV= 1 WTO
*MCALL #=     3 LV= 1          LOAD  EP=TESTCDE1 CHANGE USE COUNT FROM X
               1 TO 2
         LA    0,=CL8'TESTCDE1'
         SR    15,15 USE DEFAULT SYS390 SEARCH
         SVC   8 LOAD R0=A(NAME) R15=DDNAME/DSNAME ADDR OR 0
*MEXIT #=     3 LV= 1 LOAD
*MCALL #=     4 LV= 1          LOAD  EP=REPRO    JUST TO TEST MULT LOADX
               S
         LA    0,=CL8'REPRO'
         SR    15,15 USE DEFAULT SYS390 SEARCH
         SVC   8 LOAD R0=A(NAME) R15=DDNAME/DSNAME ADDR OR 0
*MEXIT #=     4 LV= 1 LOAD
         L     R2,16
         USING IHACVT,R2
         L     R3,CVTCDE
         USING IHACDE,R3
         LA    R5,0                   SNAP ID
*MCALL #=     5 LV= 1          DO    WHILE=(LTR,R3,NZ,R3)
*MCALL #=     6 LV= 2          ZSTREQU 
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
*MEXIT #=     6 LV= 2 ZSTREQU
#@DO_1_T                         DS 0H
*MCALL #=     7 LV= 2          IF LTR,R3,NZ,R3
*MCALL #=     8 LV= 3          ZSTREQU 
*MEXIT #=     8 LV= 3 ZSTREQU
         LTR   R3,R3
         BC    15-NZ,#@IF_1_2
*MEXIT #=     7 LV= 2 IF
               B   #@DO_1_1
*MCALL #=     9 LV= 2          ENDIF 
*MCALL #=    10 LV= 3          ZSTREQU 
*MEXIT #=    10 LV= 3 ZSTREQU
#@IF_1_2                                                 DS 0H
*MEXIT #=     9 LV= 2 ENDIF
         B     #@DO_1_E
#@DO_1_1                         DS 0H
*MEXIT #=     5 LV= 1 DO
               LA   R4,CDELEN(R3)     END OF CDE ADDR
               AHI  R5,1
*MCALL #=    11 LV= 1                SNAP ID=(R5),STORAGE=((R3),(R4))
*MCALL #=    12 LV= 2          ZOPTLR 14,R3
         LR    14,R3
*MEXIT #=    12 LV= 2 ZOPTLR
*MCALL #=    13 LV= 2          ZOPTLR 15,R4
         LR    15,R4
*MEXIT #=    13 LV= 2 ZOPTLR
*MCALL #=    14 LV= 2          ZOPTLR 0,R5                      RPI 623
         LR    0,R5
*MEXIT #=    14 LV= 2 ZOPTLR
         IILH 0,64512               RPI158
         LA    1,0
         SVC   51  SNAP DUMP R0=FLAGS,ID,R1=A(TEXT),R14-15=A(LOW,HIGH)
*MEXIT #=    11 LV= 1 SNAP
               L    R3,CDCHAIN
*MCALL #=    15 LV= 1          ENDDO 
*MCALL #=    16 LV= 2          DO    END
*MCALL #=    17 LV= 3          ZSTREQU 
*MEXIT #=    17 LV= 3 ZSTREQU
         B     #@DO_1_T
#@DO_1_E                         DS 0H
*MEXIT #=    16 LV= 2 DO
*MEXIT #=    15 LV= 1 ENDDO
*MCALL #=    18 LV= 1          WTO   'TESTCDE1 ENDED'
         BRAS  1,*+(WTO#0018_EOT-*+1)/2*2
         DC    AL2(WTO#0018_EOT-*,0),C'TESTCDE1 ENDED'
WTO#0018_EOT     EQU *
         SVC   35
*MEXIT #=    18 LV= 1 WTO
*MCALL #=    19 LV= 1          SUBEXIT 
         LA    15,0
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=    19 LV= 1 SUBEXIT
*MCALL #=    20 LV= 1          EQUREGS 
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
*MEXIT #=    20 LV= 1 EQUREGS
*MCALL #=    21 LV= 1          CVTD 
IHACVT   DSECT 
         ORG    IHACVT+X'38'
CVTDATE  DS     PL4   IPL DATE SET BY IPL(TESTIPL1)
         ORG    IHACVT+X'74'
CVTDCB   DS     X     OS FLAGS X'80' = 31 BITS, X'13' = MVS+
         ORG    IHACVT+200
CVTABEND DS     A     SECONDARY CVT  (ZERO FOR NOW)
CVTUSER  DS     A     USER POINTER
CVTCDE   DS     A     ADDRESS FIRST CDE FOR Z390 RPI 1063
*MEXIT #=    21 LV= 1 CVTD
*MCALL #=    22 LV= 1          CDED 
IHACDE   DSECT 
CDENTRY  DS    0X
CDCHAIN  DS    A   ADDRESS OF NEXT CDE ENTRY OR 0
         DS    XL4 RESERVED
CDNAME   DS    CL8 PROGRAM NAME OF LOADED MODULE
CDENTPT  DS    A   ADDRESS OF RELOCATED ENTRY POINT
         DS    XL4 RESERVED
CDUSE    DS    H   USE COUNT
         DS    XL6
CDLOADPT DS    A   LOAD ADDRESS (MAY BE DIFFERENT FROM ENTRY) Z390 EXT
CDMODLEN DS    A   LOAD MODULE LENGTH                         Z390 EXT
CDELEN   EQU   *-IHACDE
*MEXIT #=    22 LV= 1 CDED
         END 
