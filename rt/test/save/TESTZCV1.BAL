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
* 2005-04-23 DSH         Initial version                            *
* 2006-04-23 DSH RPI-286 Dump ZCVT fields starting at X'2000' after *
*                        PSA                                        *
*********************************************************************
         TITLE 'TESTZCV1 - DUMP ZCVT PGM FIELDS'
*MCALL #=     1 LV= 1 TESTZCV1 SUBENTRY 
TESTZCV1 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTZCV1'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTZCV1+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
*MCALL #=     2 LV= 1          WTO   'TESTZCV1 STARTED'
         BRAS  1,*+(WTO#0002_EOT-*+1)/2*2
         DC    AL2(WTO#0002_EOT-*,0),C'TESTZCV1 STARTED'
WTO#0002_EOT     EQU *
         SVC   35
*MEXIT #=     2 LV= 1 WTO
         L     R2,=A(ZCVT)
         USING IHAZCVT,R2
         MVC   DPGM,ZCVTUPGM
         MVC   DIPL,ZCVTIPLP
*MCALL #=     3 LV= 1          WTO   MF=(E,WTOMSG)
         LA    1,WTOMSG
         SVC   35
*MEXIT #=     3 LV= 1 WTO
*MCALL #=     4 LV= 1          WTO   'TESTZCV1 ENDED OK'
         BRAS  1,*+(WTO#0004_EOT-*+1)/2*2
         DC    AL2(WTO#0004_EOT-*,0),C'TESTZCV1 ENDED OK'
WTO#0004_EOT     EQU *
         SVC   35
*MEXIT #=     4 LV= 1 WTO
*MCALL #=     5 LV= 1          SUBEXIT 
         LA    15,0
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=     5 LV= 1 SUBEXIT
*MCALL #=     6 LV= 1          EQUREGS 
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
*MEXIT #=     6 LV= 1 EQUREGS
WTOMSG   DC    AL2(WTOEND-*,0),C' Z390 PGM='
DPGM     DC    CL8' '
         DC    C' IPL='
DIPL     DC    CL8' '
WTOEND   EQU   *
*MCALL #=     7 LV= 1          ZCVTD 
ZCVT     EQU    X'2000'  ABS ADDR ZCVT
IHAZCVT  DSECT 
         ORG    IHAZCVT+X'00'
ZCVTUPGM DS     CL8   390 USER PROGRAM NAME LOADED AT IPL
         ORG    IHAZCVT+X'08'
ZCVTIPLP DS     CL8   390 IPL PROGRAM SPECIFIED IN IPL(PGM) OPTION
         ORG    IHAZCVT+X'10'
ZCVTFQ24 DS     A     ADDRESS OF FIRST FQE FOR 24 BIT MEM AT X'10000'
         ORG    IHAZCVT+X'14'
ZCVTFQ31 DS     A     ADDRESS OF FIRST FQE FOR 31 BIT MEM AT X'1000000'
         ORG    IHAZCVT+X'18'
ZCVTEXIT DS     XL2   SVC 3 EXIT USED AS R14 EXIT AND STIMER EXIT
         ORG    IHAZCVT+X'1C'
ZCVTGECB DS     F     TGET ECB
         ORG    IHAZCVT+X'20'
ZCVTEIBP DS     A     CICS INTERFACE CONTROL BLOCK POINTER > DFHEIBLK
         ORG    IHAZCVT+X'24'
ZCVTCAP  DS     A     CICS COMMON AREA POINTER
         ORG    IHAZCVT+X'100'
ZCVTSAVE DS     18F   SAVE AREA USED TO INIT USER PGM R13
         ORG    IHAZCVT+X'200'
ZCVTSAV2 DS     18F   SAVE AREA FOR STIMER EXIT R13
         ORG    IHAZCVT+X'300'
ZCVTPARMA DS    A     ADDRESS OF ZCVT_PARM TO SET USER R1
ZCVTPARM DS     XL256 PARM AREA
         ORG    IHAZCVT+X'400'
ZCVTEPIE DS     XL256 RESERVED FOR ESPIE EPIE CB (SEE EPIED MACRO)
         ORG    IHAZCVT+X'500'
ZCVTSDWA DS     XL256 RESERVED FOR SDWA PASSED TO ESTAE IN R1 (IHASDWA)
         ORG    IHAZCVT+X'600'
ZCVT_COMRG DS XL1024 RESERVED FOR VSE COMRG AREA (SEE vse\mac\COMRG)
ZCVT_COMRG_JOBDATE DS    CL8            0  8 MM/DD/YY (SET IF TIMING)
ZCVT_COMRG_RESV1   DS    XL4            8  4 RESERVED
ZCVT_COMRG_COMUSCR DS    XL11          12 11 USER AREA (ZERO'D)
ZCVT_COMRG_UPSI    DS    B             23  1 SWITCH BITS
ZCVT_COMRG_COMNAME DS    CL8           24  8 JOBNAME (SET TO PGMNAME)
ZCVT_COMRG_PPEND   DS    A             32  4 ADDR HIGH PGM
ZCVT_COMRG_HTPHAS  DS    A             36  4 ADDR HIGH LAST PH
ZCVT_COMRG_HTPROG  DS    A             40  4 ADDR HIGH MAX  PH ID4
ZCVT_COMRG_LABLEN  DS    H             44  2 LENGTH OF LABEL
ZCVT_COMRG_RESV2   DS    XL2           46  2 RESERVERD LENGTH ?????
ZCVT_COMRG_IJBHPHLA DS   A             48  4 ADDR HIGH MAX  PH ANY
ZCVT_ACCEPT_REPLY   DS    CL256        52 80 ACCEPT REPLY AREA RMODE24
ZCVTEND  ORG    IHAZCVT+(X'A000'-X'2000')  RESERVE UP TO CVT
TESTZCV1 CSECT  
*MEXIT #=     7 LV= 1 ZCVTD
         END 
