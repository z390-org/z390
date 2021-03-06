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
* 2005 09-30 DSH         Initial version                            *
*********************************************************************
*MCALL #=     1 LV= 1 TESTDCBB SUBENTRY 
TESTDCBB CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTDCBB'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTDCBB+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
*MCALL #=     2 LV= 1          WTO   'TESTDCBB TEST USE OF DCBREC WITH X
               READ/WRITE'
         BRAS  1,*+(WTO#0002_EOT-*+1)/2*2
         DC    AL2(WTO#0002_EOT-*,0),C'TESTDCBB TEST USE OF DCBREC WITHX
                READ/WRITE'
WTO#0002_EOT     EQU *
         SVC   35
*MEXIT #=     2 LV= 1 WTO
*MCALL #=     3 LV= 1          OPEN  (SYSUT1,(INPUT),SYSUT2,(OUTPUT),SYX
               SOUT,(OUTPUT))
*MCALL #=     4 LV= 2          ZOPEN (SYSUT1,(INPUT),SYSUT2,(OUTPUT),SYX
               SOUT,(OUTPUT)),MF=I,MODE=31,TYPE=
                       LA     1,SYSUT1
                       LA  0,DCBOFLGS_GM   READ ONLY
                   SVC   19 OPEN R0=TYPE,R1=DCB/ACB
                         LTR   15,15
                         BNZ   Z390_OPEN_EXIT0004 RPI 668
                       LA     1,SYSUT2
                       LA  0,DCBOFLGS_PM   WRITE ONLY
                   SVC   19 OPEN R0=TYPE,R1=DCB/ACB
                         LTR   15,15
                         BNZ   Z390_OPEN_EXIT0004 RPI 668
                       LA     1,SYSOUT
                       LA  0,DCBOFLGS_PM   WRITE ONLY
                   SVC   19 OPEN R0=TYPE,R1=DCB/ACB
                         LTR   15,15
                         BNZ   Z390_OPEN_EXIT0004 RPI 668
Z390_OPEN_EXIT0004    EQU *
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
TESTDCBB        CSECT                              RPI 591
*MEXIT #=     5 LV= 3 DCBD
*MEXIT #=     4 LV= 2 ZOPEN
*MEXIT #=     3 LV= 1 OPEN
LOOP     EQU   *
*MCALL #=     6 LV= 1          READ  DECB1,SF,SYSUT1
*MCALL #=     7 LV= 2          ZREAD DECB1,SF,SYSUT1,,MF=I
         CNOP  0,4
         BAL   1,DECB1+DECBL
DECB1    DC    F'0' DECBECB  (X'40' OK, X'41' I/O ERROR, X'42' EOF)
         DC    H'0' DECBTYPE
         DC    AL2(DECBL)
         DC    A(0) DECBDCBA OPEN DCB WITH MACRF R OR RW
         DC    A(0) DECBAREA AREA FOR BLOCK MUST BE >= DCBBLKSI
         ORG   DECB1+DECBL
         LA    0,SYSUT1
         ST    0,DECBDCBA-IHADECB(1)
         L     15,DECBDCBA-IHADECB(1)
         MVC   DECBAREA-IHADECB(4,1),DCBREC-IHADCB(15)
         SVC   153 READ R0=AREA, R1=DECB
*MEXIT #=     7 LV= 2 ZREAD
*MEXIT #=     6 LV= 1 READ
*MCALL #=     8 LV= 1          CHECK DECB1
         LA    1,DECB1
         SVC   155 CHECK R1=DECB
*MEXIT #=     8 LV= 1 CHECK
         AP    PTOT,=P'1'
         MVC   DTOT,=X'40202020'
         ED    DTOT,PTOT
*MCALL #=     9 LV= 1          PUT   SYSOUT,MSG
         LA    1,SYSOUT
         LA    0,MSG
         SVC  152 QSAM PUT R0=REC, R1=DCB
*MEXIT #=     9 LV= 1 PUT
*MCALL #=    10 LV= 1          WRITE DECB2,SF,SYSUT2
*MCALL #=    11 LV= 2          ZWRITE DECB2,SF,SYSUT2,,MF=I
         CNOP  0,4
         BAL   1,DECB2+DECBL
DECB2    DC    F'0' DECBECB  (X'40' OK, X'41' I/O ERROR, X'42' EOF)
         DC    H'0' DECBTYPE
         DC    AL2(DECBL)
         DC    A(0) DECBDCBA OPEN DCB WITH MACRF R OR RW
         DC    A(0) DECBAREA AREA FOR BLOCK MUST BE >= DCBBLKSI
         ORG   DECB2+DECBL
         LA    0,SYSUT2
         ST    0,DECBDCBA-IHADECB(1)
         L     15,DECBDCBA-IHADECB(1)
         MVC   DECBAREA-IHADECB(4,1),DCBREC-IHADCB(15)
         SVC   154 WRITE
*MEXIT #=    11 LV= 2 ZWRITE
*MEXIT #=    10 LV= 1 WRITE
*MCALL #=    12 LV= 1          CHECK DECB2
         LA    1,DECB2
         SVC   155 CHECK R1=DECB
*MEXIT #=    12 LV= 1 CHECK
         B     LOOP
*MCALL #=    13 LV= 1 EOF      CLOSE (SYSUT1,,SYSUT2,,SYSOUT)
*MCALL #=    14 LV= 2 EOF      ZCLOSE (SYSUT1,,SYSUT2,,SYSOUT),MODE=,MFX
               =I,TYPE=
EOF DS   0H
                       LA     1,SYSUT1
                   SVC   20 CLOSE R1=DCB/ACB
                          LTR   15,15
                          BNZ   Z390_CLOSE_EXIT0014 RPI 668
                       LA     1,SYSUT2
                   SVC   20 CLOSE R1=DCB/ACB
                          LTR   15,15
                          BNZ   Z390_CLOSE_EXIT0014 RPI 668
                       LA     1,SYSOUT
                   SVC   20 CLOSE R1=DCB/ACB
Z390_CLOSE_EXIT0014    EQU *
*MEXIT #=    14 LV= 2 ZCLOSE
*MEXIT #=    13 LV= 1 CLOSE
*MCALL #=    15 LV= 1          WTO   'TESTDCBB ENDED OK'
         BRAS  1,*+(WTO#0015_EOT-*+1)/2*2
         DC    AL2(WTO#0015_EOT-*,0),C'TESTDCBB ENDED OK'
WTO#0015_EOT     EQU *
         SVC   35
*MEXIT #=    15 LV= 1 WTO
*MCALL #=    16 LV= 1          SUBEXIT 
         LA    15,0
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=    16 LV= 1 SUBEXIT
*MCALL #=    17 LV= 1 SYSUT1   DCB   DSORG=PS,DDNAME=SYSUT1,EODAD=EOF,MX
               ACRF=R,RECFM=F,BLKSIZE=80,RECORD=RECORD
SYSUT1   DS    0D             RPI 915
         DC    XL(DCBLEN)'00' RPI 946
         ORG   SYSUT1+DCBID-IHADCB        RPI88
         DC    C'DCBV1001'            RPI88
         ORG   SYSUT1+DCBDSORG-IHADCB
         DC    AL1(DCBDSORG_PS) DCBDSORG
         ORG   SYSUT1+DCBEODAD-IHADCB
         DC    A(EOF) DCBEODAD
         ORG   SYSUT1+DCBRECFM-IHADCB
         DC    AL1(DCBRECFM_F) DCBRECFM
         ORG   SYSUT1+DCBDDNAM-IHADCB
         DC    CL8'SYSUT1' DCBDDNAM
         ORG   SYSUT1+DCBOFLGS-IHADCB
         DC    AL1(0) DCBOFLGS RPI 668 ZERO (SET AT OPEN)
         ORG   SYSUT1+DCBMACRF-IHADCB
         DC    AL2(DCBMACRF_R) DCBMACRF
         ORG   SYSUT1+DCBSYNAD-IHADCB
         DC    A(0) DCBSYNAD DCBSYNAD
         ORG   SYSUT1+DCBBLKSIF-IHADCB    RPI 587
         DC    F'80' DCBBLKSIF  RPI 587
         ORG   SYSUT1+DCBLRECLF-IHADCB    RPI 587
         DC    F'0' DCBLRECLF    RPI 587
         ORG   SYSUT1+DCBREC-IHADCB
         DC    A(RECORD) DCBREC
         ORG   SYSUT1+DCBDSNAM-IHADCB
         DC    A(0) DCBDSNAM
         ORG   SYSUT1+DCBDCBE-IHADCB   RPI 281
         DC    A(0) DCBDCBE
         ORG   SYSUT1+DCBIO-IHADCB     RPI 907
         DC    A(0)     DCBIO      RPI 907 TOTAL IO COUNT SINCE OPEN
         ORG   SYSUT1+DCBLEN
*MCALL #=    18 LV= 2          DCBD 
*MEXIT #=    18 LV= 2 DCBD
*MEXIT #=    17 LV= 1 DCB
*MCALL #=    19 LV= 1 SYSUT2   DCB   DSORG=PS,DDNAME=SYSUT2,MACRF=W,RECX
               FM=F,BLKSIZE=80,RECORD=RECORD
SYSUT2   DS    0D             RPI 915
         DC    XL(DCBLEN)'00' RPI 946
         ORG   SYSUT2+DCBID-IHADCB        RPI88
         DC    C'DCBV1001'            RPI88
         ORG   SYSUT2+DCBDSORG-IHADCB
         DC    AL1(DCBDSORG_PS) DCBDSORG
         ORG   SYSUT2+DCBEODAD-IHADCB
         DC    A(0) DCBEODAD
         ORG   SYSUT2+DCBRECFM-IHADCB
         DC    AL1(DCBRECFM_F) DCBRECFM
         ORG   SYSUT2+DCBDDNAM-IHADCB
         DC    CL8'SYSUT2' DCBDDNAM
         ORG   SYSUT2+DCBOFLGS-IHADCB
         DC    AL1(0) DCBOFLGS RPI 668 ZERO (SET AT OPEN)
         ORG   SYSUT2+DCBMACRF-IHADCB
         DC    AL2(DCBMACRF_W) DCBMACRF
         ORG   SYSUT2+DCBSYNAD-IHADCB
         DC    A(0) DCBSYNAD DCBSYNAD
         ORG   SYSUT2+DCBBLKSIF-IHADCB    RPI 587
         DC    F'80' DCBBLKSIF  RPI 587
         ORG   SYSUT2+DCBLRECLF-IHADCB    RPI 587
         DC    F'0' DCBLRECLF    RPI 587
         ORG   SYSUT2+DCBREC-IHADCB
         DC    A(RECORD) DCBREC
         ORG   SYSUT2+DCBDSNAM-IHADCB
         DC    A(0) DCBDSNAM
         ORG   SYSUT2+DCBDCBE-IHADCB   RPI 281
         DC    A(0) DCBDCBE
         ORG   SYSUT2+DCBIO-IHADCB     RPI 907
         DC    A(0)     DCBIO      RPI 907 TOTAL IO COUNT SINCE OPEN
         ORG   SYSUT2+DCBLEN
*MCALL #=    20 LV= 2          DCBD 
*MEXIT #=    20 LV= 2 DCBD
*MEXIT #=    19 LV= 1 DCB
*MCALL #=    21 LV= 1 SYSOUT   DCB   DSORG=PS,DDNAME=SYSOUT,RECFM=FT,BLX
               KSIZE=120,MACRF=PM
SYSOUT   DS    0D             RPI 915
         DC    XL(DCBLEN)'00' RPI 946
         ORG   SYSOUT+DCBID-IHADCB        RPI88
         DC    C'DCBV1001'            RPI88
         ORG   SYSOUT+DCBDSORG-IHADCB
         DC    AL1(DCBDSORG_PS) DCBDSORG
         ORG   SYSOUT+DCBEODAD-IHADCB
         DC    A(0) DCBEODAD
         ORG   SYSOUT+DCBRECFM-IHADCB
         DC    AL1(DCBRECFM_FT) DCBRECFM
         ORG   SYSOUT+DCBDDNAM-IHADCB
         DC    CL8'SYSOUT' DCBDDNAM
         ORG   SYSOUT+DCBOFLGS-IHADCB
         DC    AL1(0) DCBOFLGS RPI 668 ZERO (SET AT OPEN)
         ORG   SYSOUT+DCBMACRF-IHADCB
         DC    AL2(DCBMACRF_PM) DCBMACRF
         ORG   SYSOUT+DCBSYNAD-IHADCB
         DC    A(0) DCBSYNAD DCBSYNAD
         ORG   SYSOUT+DCBBLKSIF-IHADCB    RPI 587
         DC    F'120' DCBBLKSIF  RPI 587
         ORG   SYSOUT+DCBLRECLF-IHADCB    RPI 587
         DC    F'0' DCBLRECLF    RPI 587
         ORG   SYSOUT+DCBREC-IHADCB
         DC    A(0) DCBREC
         ORG   SYSOUT+DCBDSNAM-IHADCB
         DC    A(0) DCBDSNAM
         ORG   SYSOUT+DCBDCBE-IHADCB   RPI 281
         DC    A(0) DCBDCBE
         ORG   SYSOUT+DCBIO-IHADCB     RPI 907
         DC    A(0)     DCBIO      RPI 907 TOTAL IO COUNT SINCE OPEN
         ORG   SYSOUT+DCBLEN
*MCALL #=    22 LV= 2          DCBD 
*MEXIT #=    22 LV= 2 DCBD
*MEXIT #=    21 LV= 1 DCB
PTOT     DC    PL2'0'
MSG      DS    0CL120
         DC    C'REC#='
DTOT     DC    CL4' ',C' TEXT='
RECORD   DC    CL80' '
         DC    (MSG+120-*)C' '
*MCALL #=    23 LV= 1          DCBD 
*MEXIT #=    23 LV= 1 DCBD
*MCALL #=    24 LV= 1          DECBD 
IHADECB  DSECT 
DECBECB  DS    F
DECBTYPE DS    XL2
DECBLEN  DS    XL2
DECBDCBA DS    A
DECBAREA DS    A
DECBL    EQU   *-IHADECB
*MEXIT #=    24 LV= 1 DECBD
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
