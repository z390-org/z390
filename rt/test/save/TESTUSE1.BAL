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
* 2005-09-30  DSH          Initial version                          *
* 2006-03-22  DSH RPI-237  Test drop using with comments, multiple  *
*                          labels                                   *
* 2006-04-06  DSH RPI-274  Support DSECT dependent using            *
* 2007-05-07  DSH RPI-609  Remove label on non-specific dependent   *
*                          using                                    *
* 2007-05-30  DSH RPI-629  Correct drop of previous unlabeled USING *
* 2008-01-14  DSH RPI-776  Correct using to ignore comments with    *
*                          commas                                   *
* 2009-06-17  DSH RPI-1056 Test warning for duplicate ordinary      *
*                          using ranges                             *
*********************************************************************
*MCALL #=     1 LV= 1 TESTUSE1 SUBENTRY 
TESTUSE1 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTUSE1'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTUSE1+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
*MCALL #=     2 LV= 1          WTO   'TESTUSE1 TEST LABELD AND DEPENDANX
               T USING'
         BRAS  1,*+(WTO#0002_EOT-*+1)/2*2
         DC    AL2(WTO#0002_EOT-*,0),C'TESTUSE1 TEST LABELD AND DEPENDAX
               NT USING'
WTO#0002_EOT     EQU *
         SVC   35
*MEXIT #=     2 LV= 1 WTO
*
* TEST S TYPE ADDRESS
*
         DC    X'4110',S(X)
         CL    1,=A(X)
         BNE   ERR
*
* TEST MULT REG USING AND RANGE LIMITS
*
         USING CST2,1,2       RPI 776 A,B,C TEST
         CLC   =S(CST2+4095,CST2+4096),=X'1FFF2000'
         BNE   ERR
         USING (CST2+10,CST2+20),3
         CLC   =S(CST2+10,CST2+21),=X'30001015'
         BNE   ERR
         B     SKPLIT
         LTORG 
         DROP  1,2,3
SKPLIT   DS    0H
*
* TEST UNLABELED DEPENDANT USING
*
         USING IHADCB,SYSUT1
         CLC   DCBDDNAM,=CL8'SYSUT1'
         BNE   ERR
         CLC   DCBLRECL,=H'80'
         BNE   ERR
         USING IHADCB,SYSUT2
         CLC   DCBDDNAM,=CL8'SYSUT2'
         BNE   ERR
         CLC   DCBLRECL,=H'120'
         BNE   ERR
         DROP 
         USING TESTUSE1+8,13
*
* TEST LABELED DEPENDANT USING
*
DCB1     USING IHADCB,SYSUT1
DCB2     USING IHADCB,SYSUT2
         CLC   DCB1.DCBDDNAM,=CL8'SYSUT1'
         BNE   ERR
         CLC   DCB1.DCBLRECL,=H'80'
         BNE   ERR
         CLC   DCB2.DCBDDNAM,=CL8'SYSUT2'
         BNE   ERR
         CLC   DCB2.DCBLRECL,=H'120'
         BNE   ERR
         DROP  DCB1,DCB2 TEST COMMENT FOR RPI 237
* TEST DEPENDENT USING DSECT
         LA    12,PRIVATE             * Point new savearea
         USING SAVEAREA,12            * Address new savearea
CHECK    USING PRIVATE,SAVEAREA        **!! for testing purposes
         LA    1,CHECK.P1
         CLI   0(1),X'EE'
         BNE   ERR
*
* TEST DROPING PREV UNLABELED USING - RPI 629
*
         BALR  10,0
         USING *,10
         BALR  10,0
L10      USING *,10
         BALR  10,0
         USING *,10
         LA    1,*
         LA    10,0(10) CLEAR HIGH BITS
         CLR   1,10    VERIFY USE OF LAST USING VESUS PREV
         BNE   ERR
*
* GENERATE 2 WARNINGS FOR HIGH/LOW DUPLICATE RANGE ORDINARY USINGS
*
         DROP  10
         LR    14,13
         USING TESTUSE1+8,14
         LA    1,WARN
         DROP  14
         LR   11,13
         USING TESTUSE1+8,11
         LA    1,WARN
WARN     EQU   *
*MCALL #=     3 LV= 1          WTO   'TESTUSE1 ENDED OK'
         BRAS  1,*+(WTO#0003_EOT-*+1)/2*2
         DC    AL2(WTO#0003_EOT-*,0),C'TESTUSE1 ENDED OK'
WTO#0003_EOT     EQU *
         SVC   35
*MEXIT #=     3 LV= 1 WTO
*MCALL #=     4 LV= 1          SUBEXIT 
         LA    15,0
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=     4 LV= 1 SUBEXIT
*MCALL #=     5 LV= 1 ERR      WTO   'TESTUSE1 ABORTING WITH ERROR'
ERR      DS    0H
         BRAS  1,*+(WTO#0005_EOT-*+1)/2*2
         DC    AL2(WTO#0005_EOT-*,0),C'TESTUSE1 ABORTING WITH ERROR'
WTO#0005_EOT     EQU *
         SVC   35
*MEXIT #=     5 LV= 1 WTO
*MCALL #=     6 LV= 1          SUBEXIT RC=16
         LA    15,16
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=     6 LV= 1 SUBEXIT
*MCALL #=     7 LV= 1 SYSUT1   DCB   DSORG=PS,RECFM=FB,LRECL=80,MACRF=GX
               M,DDNAME=SYSUT1
SYSUT1   DS    0D             RPI 915
         DC    XL(DCBLEN)'00' RPI 946
         ORG   SYSUT1+DCBID-IHADCB        RPI88
         DC    C'DCBV1001'            RPI88
         ORG   SYSUT1+DCBDSORG-IHADCB
         DC    AL1(DCBDSORG_PS) DCBDSORG
         ORG   SYSUT1+DCBEODAD-IHADCB
         DC    A(0) DCBEODAD
         ORG   SYSUT1+DCBRECFM-IHADCB
         DC    AL1(DCBRECFM_FB) DCBRECFM
         ORG   SYSUT1+DCBDDNAM-IHADCB
         DC    CL8'SYSUT1' DCBDDNAM
         ORG   SYSUT1+DCBOFLGS-IHADCB
         DC    AL1(0) DCBOFLGS RPI 668 ZERO (SET AT OPEN)
         ORG   SYSUT1+DCBMACRF-IHADCB
         DC    AL2(DCBMACRF_GM) DCBMACRF
         ORG   SYSUT1+DCBSYNAD-IHADCB
         DC    A(0) DCBSYNAD DCBSYNAD
         ORG   SYSUT1+DCBBLKSIF-IHADCB    RPI 587
         DC    F'0' DCBBLKSIF  RPI 587
         ORG   SYSUT1+DCBLRECLF-IHADCB    RPI 587
         DC    F'80' DCBLRECLF    RPI 587
         ORG   SYSUT1+DCBREC-IHADCB
         DC    A(0) DCBREC
         ORG   SYSUT1+DCBDSNAM-IHADCB
         DC    A(0) DCBDSNAM
         ORG   SYSUT1+DCBDCBE-IHADCB   RPI 281
         DC    A(0) DCBDCBE
         ORG   SYSUT1+DCBIO-IHADCB     RPI 907
         DC    A(0)     DCBIO      RPI 907 TOTAL IO COUNT SINCE OPEN
         ORG   SYSUT1+DCBLEN
*MCALL #=     8 LV= 2          DCBD 
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
TESTUSE1        CSECT                              RPI 591
*MEXIT #=     8 LV= 2 DCBD
*MEXIT #=     7 LV= 1 DCB
*MCALL #=     9 LV= 1 SYSUT2   DCB   DSORG=PS,RECFM=FB,LRECL=120,MACRF=X
               PM,DDNAME=SYSUT2
SYSUT2   DS    0D             RPI 915
         DC    XL(DCBLEN)'00' RPI 946
         ORG   SYSUT2+DCBID-IHADCB        RPI88
         DC    C'DCBV1001'            RPI88
         ORG   SYSUT2+DCBDSORG-IHADCB
         DC    AL1(DCBDSORG_PS) DCBDSORG
         ORG   SYSUT2+DCBEODAD-IHADCB
         DC    A(0) DCBEODAD
         ORG   SYSUT2+DCBRECFM-IHADCB
         DC    AL1(DCBRECFM_FB) DCBRECFM
         ORG   SYSUT2+DCBDDNAM-IHADCB
         DC    CL8'SYSUT2' DCBDDNAM
         ORG   SYSUT2+DCBOFLGS-IHADCB
         DC    AL1(0) DCBOFLGS RPI 668 ZERO (SET AT OPEN)
         ORG   SYSUT2+DCBMACRF-IHADCB
         DC    AL2(DCBMACRF_PM) DCBMACRF
         ORG   SYSUT2+DCBSYNAD-IHADCB
         DC    A(0) DCBSYNAD DCBSYNAD
         ORG   SYSUT2+DCBBLKSIF-IHADCB    RPI 587
         DC    F'0' DCBBLKSIF  RPI 587
         ORG   SYSUT2+DCBLRECLF-IHADCB    RPI 587
         DC    F'120' DCBLRECLF    RPI 587
         ORG   SYSUT2+DCBREC-IHADCB
         DC    A(0) DCBREC
         ORG   SYSUT2+DCBDSNAM-IHADCB
         DC    A(0) DCBDSNAM
         ORG   SYSUT2+DCBDCBE-IHADCB   RPI 281
         DC    A(0) DCBDCBE
         ORG   SYSUT2+DCBIO-IHADCB     RPI 907
         DC    A(0)     DCBIO      RPI 907 TOTAL IO COUNT SINCE OPEN
         ORG   SYSUT2+DCBLEN
*MCALL #=    10 LV= 2          DCBD 
*MEXIT #=    10 LV= 2 DCBD
*MEXIT #=     9 LV= 1 DCB
X        EQU   *
PRIVATE  DC    X'FF'
P1       DC    X'EE'
SAVEAREA DSECT 
         DS    18F
CST2     CSECT 
         DS    XL8192
*MCALL #=    11 LV= 1          DCBD 
*MEXIT #=    11 LV= 1 DCBD
         END 
