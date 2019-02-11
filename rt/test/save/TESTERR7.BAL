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
* 2006-07-20 DSH         Initial version                            *
* 2006-07-20 DSH RPI-377 Test missing DDNAME and no SYNAD causing   *
*                        recursion                                  *
*********************************************************************
*MCALL #=     1 LV= 1 TESTERR5 SUBENTRY 
TESTERR5 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTERR5'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTERR5+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
*MCALL #=     2 LV= 1          WTO   'TESTERR7 TEST MISSING DDNAME AND X
               NO SYNAD ERROR'
         BRAS  1,*+(WTO#0002_EOT-*+1)/2*2
         DC    AL2(WTO#0002_EOT-*,0),C'TESTERR7 TEST MISSING DDNAME ANDX
                NO SYNAD ERROR'
WTO#0002_EOT     EQU *
         SVC   35
*MEXIT #=     2 LV= 1 WTO
*MCALL #=     3 LV= 1          OPEN  (TESTERR7,(INPUT))
*MCALL #=     4 LV= 2          ZOPEN (TESTERR7,(INPUT)),MF=I,MODE=31,TYX
               PE=
                       LA     1,TESTERR7
                       LA  0,DCBOFLGS_GM   READ ONLY
                   SVC   19 OPEN R0=TYPE,R1=DCB/ACB
*MCALL #=     5 LV= 3          DCBD 
IHADCB   DSECT 
         ORG   IHADCB+X'00'
DCBID    DS    CL4            DCB ID RPI88
         ORG   IHADCB+X'1A'
DCBDSORG DS    X              DATA SET ORGANIZATION
DCBDSORG_PS EQU X'40'           PHYSICAL SEQUENTIAL
DCBDSORG_DA EQU X'20'           DIRECT ACCESS
         ORG   IHADCB+X'1C'
DCBIOBAD DS    A              INPUT/OUTPUT BLOCK (TIOT TABLE INDEX)
         ORG   IHADCB+X'20'
DCBEODA  DS    0A ADDRESS OF END OF FILE EXIT 31 BIT VS 24 RPI 989
DCBEODAD DS    A ADDRESS OF END OF FILE EXIT  31 BIT VS 24
         ORG   IHADCB+X'24'
DCBRECFM DS    X              RECORD FORMAT
DCBRECF      EQU X'80'           FIXED  RPI 989
DCBRECFM_F   EQU X'80'           FIXED
DCBRECFM_FA  EQU X'80'           FIXED
DCBRECFM_FM  EQU X'80'           FIXED
DCBRECFM_V   EQU X'40'           VARIABLE
DCBRECFM_VA  EQU X'40'           VARIABLE
DCBRECFM_VM  EQU X'40'           VARIABLE
DCBRECFM_FB  EQU X'90'           FIXED BLOCKED
DCBRECBR     EQU X'10'           BLOCKED RECORDS RPI 989
DCBRECFM_FBA EQU X'90'           FIXED BLOCKED
DCBRECFM_FBM EQU X'90'           FIXED BLOCKED
DCBRECFM_VB  EQU X'50'           VARIABLE BLOCKED
DCBRECFM_VBA EQU X'50'           VARIABLE BLOCKED
DCBRECFM_VBM EQU X'50'           VARIABLE BLOCKED
DCBRECFM_FT  EQU X'A0'           FIXED ASCII TEXT
DCBRECFM_VT  EQU X'60'           VARIABLE ASCII TEXT
DCBRECU      EQU X'C0'           UNDEFINED RCDS NOT SUPPORTED RPI 989
         ORG   IHADCB+X'28'
DCBDDNAM DS    CL8            DDNAME > ENV VAR > FILE NAME
         ORG   IHADCB+X'30'
DCBOFLGS DS    X              OPEN FLAGS
DCBOFLGS_OPEN EQU X'10'          FILE OPEN (X'80' > X'10' RPI 906)_
DCBOFOPN      EQU X'10'          FILE OPEN RPI 906
DCBOFLGS_GM   EQU X'40'          READ  ALLOWED
DCBOFLGS_PM   EQU X'20'          WRITE ALLOWED
DCBOFLGS_GL   EQU X'40'          READ  ALLOWED
DCBOFLGS_PL   EQU X'20'          WRITE ALLOWED
DCBOFLGS_R    EQU X'40'          READ  ALLOWED
DCBOFLGS_W    EQU X'20'          WRITE ALLOWED
DCBOFLGS_RW   EQU X'60'          READ AND WRITE ALLOWED
         ORG   IHADCB+X'32'
DCBMACRF DS    H              MACRO REFERENCE ACCESS TYPE
DCBMACRF_GM EQU X'5000'         GET MOVE   QSAM
DCBMACRF_PM EQU X'0050'         PUT MOVE   QSAM
DCBMACRF_GL EQU X'4800'         GET LOCATE QSAM    RPI 764
DCBMACRF_PL EQU X'0048'         PUT LOCATE QSAM    RPI 764
DCBMACRF_R  EQU X'2000'         READ  RANDOM BDAM
DCBMACRF_W  EQU X'0020'         WRITE RANDOM BDAM
DCBMACRF_RW EQU X'2020'         READ/WRITE RANDOM BDAM
         ORG   IHADCB+X'38'
DCBSYNAD DS    A              ERROR EXIT
         ORG   IHADCB+X'3C'
DCBBLKSIF DS   F              BLOCK SIZE    RPI 587 32 BIT BLOCK SIZE
         ORG   IHADCB+X'3E'
DCBBLKSI DS    H              BLOCK SIZE    (ALSO UNBLOCKED MAX RECORD)
         ORG   IHADCB+X'50'
DCBLRECLF DS   F              RECORD LENGTH RPI 587 32 BIT RECORD LEN
         ORG   IHADCB+X'52'
DCBLRECL DS    H              RECORD LENGTH (MAY BE ZERO FOR UNBLOCKED)
         ORG   IHADCB+X'58'
DCBREC   DS    A      X'58'   ADDRESS OF USER SUPPLIED RECORD AREA
DCBDSNAM DS    A      X'5C'   ADDRESS OF USER SUPPLIED DSN FILE SPEC
DCBDCBE  DS    A      X'60'   ADDRESS OF DCBE EODAD/SYNAD  RPI 281
DCBIO    DS    F      X'64'   TOTAL DCB IO OPERATIONS SINCE OPEN
DCBLEN   EQU   *-IHADCB
TESTERR5        CSECT                              RPI 591
*MEXIT #=     5 LV= 3 DCBD
*MEXIT #=     4 LV= 2 ZOPEN
*MEXIT #=     3 LV= 1 OPEN
*MCALL #=     6 LV= 1          SUBEXIT 
         LA    15,0
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=     6 LV= 1 SUBEXIT
*MCALL #=     7 LV= 1 TESTERR7 DCB   RECFM=FT,LRECL=80,MACRF=GM,RECORD=X
               RECORD,DDNAME=TESTERR7
TESTERR7 DS    0D             RPI 915
         DC    XL(DCBLEN)'00' RPI 946
         ORG   TESTERR7+DCBID-IHADCB        RPI88
         DC    C'DCBV1001'            RPI88
         ORG   TESTERR7+DCBDSORG-IHADCB
         DC    AL1(DCBDSORG_PS) DCBDSORG
         ORG   TESTERR7+DCBEODAD-IHADCB
         DC    A(0) DCBEODAD
         ORG   TESTERR7+DCBRECFM-IHADCB
         DC    AL1(DCBRECFM_FT) DCBRECFM
         ORG   TESTERR7+DCBDDNAM-IHADCB
         DC    CL8'TESTERR7' DCBDDNAM
         ORG   TESTERR7+DCBOFLGS-IHADCB
         DC    AL1(0) DCBOFLGS RPI 668 ZERO (SET AT OPEN)
         ORG   TESTERR7+DCBMACRF-IHADCB
         DC    AL2(DCBMACRF_GM) DCBMACRF
         ORG   TESTERR7+DCBSYNAD-IHADCB
         DC    A(0) DCBSYNAD DCBSYNAD
         ORG   TESTERR7+DCBBLKSIF-IHADCB    RPI 587
         DC    F'0' DCBBLKSIF  RPI 587
         ORG   TESTERR7+DCBLRECLF-IHADCB    RPI 587
         DC    F'80' DCBLRECLF    RPI 587
         ORG   TESTERR7+DCBREC-IHADCB
         DC    A(RECORD) DCBREC
         ORG   TESTERR7+DCBDSNAM-IHADCB
         DC    A(0) DCBDSNAM
         ORG   TESTERR7+DCBDCBE-IHADCB   RPI 281
         DC    A(0) DCBDCBE
         ORG   TESTERR7+DCBIO-IHADCB     RPI 907
         DC    A(0)     DCBIO      RPI 907 TOTAL IO COUNT SINCE OPEN
         ORG   TESTERR7+DCBLEN
*MCALL #=     8 LV= 2          DCBD 
*MEXIT #=     8 LV= 2 DCBD
*MEXIT #=     7 LV= 1 DCB
RECORD   DC    CL80' '
*MCALL #=     9 LV= 1          DCBD 
*MEXIT #=     9 LV= 1 DCBD
         END 
