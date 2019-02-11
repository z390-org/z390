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
* 2006-05-01 DSH         Initial version                            *
* 2006-05-01 DSH RPI-305 Test ESPIE exit with parameter and RESTART *
* 2008-06-20 DSH RPI-845 Change EPIED to IHAEPIE                    *
*********************************************************************
         TITLE 'TESTSPI1 - TEST ESPIE'
*MCALL #=     1 LV= 1 TESTSPI1 SUBENTRY 
TESTSPI1 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTSPI1'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTSPI1+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
*MCALL #=     2 LV= 1          WTO   'TESTSPI1 TEST ESPIE STARTED'
         BRAS  1,*+(WTO#0002_EOT-*+1)/2*2
         DC    AL2(WTO#0002_EOT-*,0),C'TESTSPI1 TEST ESPIE STARTED'
WTO#0002_EOT     EQU *
         SVC   35
*MEXIT #=     2 LV= 1 WTO
*MCALL #=     3 LV= 1          ESPIE SET,EXIT,1,PARAM=RESTART
        LA     15,RESTART
        IPM    0  GET CURRENT PGM MASK
        SPM    0 TURN ON ANY MASKS REQUIRED
        L      0,=B'01000000000000000000000000000000'
        LA     1,EXIT
        SVC    X'6D' ESPIE R0=INT BITS R1=EXIT R15=PARAM
*MEXIT #=     3 LV= 1 ESPIE
         DC    X'0000' CAUSE 0C1
*MCALL #=     4 LV= 1 RESTART  WTO   'TESTSPI1 RESTART SUCCESSFUL'
RESTART  DS    0H
         BRAS  1,*+(WTO#0004_EOT-*+1)/2*2
         DC    AL2(WTO#0004_EOT-*,0),C'TESTSPI1 RESTART SUCCESSFUL'
WTO#0004_EOT     EQU *
         SVC   35
*MEXIT #=     4 LV= 1 WTO
*MCALL #=     5 LV= 1          WTO   'TESTSPI1 ENDED OK'
         BRAS  1,*+(WTO#0005_EOT-*+1)/2*2
         DC    AL2(WTO#0005_EOT-*,0),C'TESTSPI1 ENDED OK'
WTO#0005_EOT     EQU *
         SVC   35
*MEXIT #=     5 LV= 1 WTO
*MCALL #=     6 LV= 1          SUBEXIT 
         LA    15,0
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=     6 LV= 1 SUBEXIT
         DROP 
EXIT     DS    0H
         USING *,15
         USING EPIE,1
         L     0,EPIEPARM
         ST    0,EPIEPSW+4
         BR    14
*MCALL #=     7 LV= 1          IHAEPIE 
EPIE     DSECT 
EPIEEPIE DS    CL4   C'EPIE'
EPIEPARM DS    A     A(PARAM PASSED AT ESPIE OR 0)
         DS    16F   32 bit regs not used by z390 (see EPIEG64)
EPIEPSW  DS    0XL8  (OLD PSW  (EC 24/31 BIT ONLY)
EPIEEMK1 DS    X     PSW MASK
EPIEMWP1 DS    X     PSW KEY AND MWP
EPIECCPM DS    X     PSW CONDITION CODE AND PGM MASK
         DS    X     RESERVED
EPIENXT1 DS    0F    PSW 31 BIT ADDR NEXT INSTRUCTION
EPIEAMF1 DS    X     PSW ADDRESS HIGH BYTE WITH AMODE BIT
EPIEMOD1 EQU   X'80' PSW 31 BIT AMODE BIT
EPIEADD1 DS    XL3   PSW 24 BIT ADDRESSS OF NEXT INSTRUCTION
EPIEINT  DS    0XL4  PROGRAM INTERRUPTION INFO
EPIEIRSV DS    XL1   RESERVED
EPIEILC1 DS    B     INSTRUCTION LENGTH BYTE
EPIEIL1  EQU   X'06' INSTRUCTION LENGTH MASK (2, 4, 6 LENGTH)
EPIEINC1 DS    0CL2  INTERRUPTION CODE
         ORG   EPIE+X'99'
EPIEFLGS DS    XL1   EPIE OPTION FLAGS
EPIEUP64 EQU   X'40' USE 64 BIT REGS INSTEAD OF 32 BIT
         DS    XL6   RESERVED
EPIEG64   DS   0D
EPIEG6400 DS   D
EPIEG6401 DS   D
EPIEG6402 DS   D
EPIEG6403 DS   D
EPIEG6404 DS   D
EPIEG6405 DS   D
EPIEG6406 DS   D
EPIEG6407 DS   D
EPIEG6408 DS   D
EPIEG6409 DS   D
EPIEG6410 DS   D
EPIEG6411 DS   D
EPIEG6412 DS   D
EPIEG6413 DS   D
EPIEG6414 DS   D
EPIEG6415 DS   D
EPIELEN  EQU   *-EPIE
*MEXIT #=     7 LV= 1 IHAEPIE
         END 
