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
*MCALL #=     1 LV= 1 TESTDCB3 SUBENTRY 
TESTDCB3 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTDCB3'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTDCB3+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
*MCALL #=     2 LV= 1          WTO   'TESTDCB3 COPY SYSUT1 FB FILE TO SX
               YSUT2 FB'
         BRAS  1,*+(WTO#0002_EOT-*+1)/2*2
         DC    AL2(WTO#0002_EOT-*,0),C'TESTDCB3 COPY SYSUT1 FB FILE TO X
               SYSUT2 FB'
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
TESTDCB3        CSECT                              RPI 591
*MEXIT #=     5 LV= 3 DCBD
*MEXIT #=     4 LV= 2 ZOPEN
*MEXIT #=     3 LV= 1 OPEN
LOOP     EQU   *
*MCALL #=     6 LV= 1          GET   SYSUT1,RECORD
         LA    1,SYSUT1
         LA    0,RECORD
         SVC  151
*MEXIT #=     6 LV= 1 GET
         AP    PTOT,=P'1'
         MVC   DTOT,=X'40202020'
         ED    DTOT,PTOT
*MCALL #=     7 LV= 1          PUT   SYSOUT,MSG
         LA    1,SYSOUT
         LA    0,MSG
         SVC  152 QSAM PUT R0=REC, R1=DCB
*MEXIT #=     7 LV= 1 PUT
*MCALL #=     8 LV= 1          PUT   SYSUT2,RECORD
         LA    1,SYSUT2
         LA    0,RECORD
         SVC  152 QSAM PUT R0=REC, R1=DCB
*MEXIT #=     8 LV= 1 PUT
         B     LOOP
*MCALL #=     9 LV= 1 EOF      CLOSE (SYSUT1,,SYSUT2,,SYSOUT)
*MCALL #=    10 LV= 2 EOF      ZCLOSE (SYSUT1,,SYSUT2,,SYSOUT),MODE=,MFX
               =I,TYPE=
EOF DS   0H
                       LA     1,SYSUT1
                   SVC   20 CLOSE R1=DCB/ACB
                          LTR   15,15
                          BNZ   Z390_CLOSE_EXIT0010 RPI 668
                       LA     1,SYSUT2
                   SVC   20 CLOSE R1=DCB/ACB
                          LTR   15,15
                          BNZ   Z390_CLOSE_EXIT0010 RPI 668
                       LA     1,SYSOUT
                   SVC   20 CLOSE R1=DCB/ACB
Z390_CLOSE_EXIT0010    EQU *
*MEXIT #=    10 LV= 2 ZCLOSE
*MEXIT #=     9 LV= 1 CLOSE
*MCALL #=    11 LV= 1          WTO   'TESTDCB3 ENDED OK'
         BRAS  1,*+(WTO#0011_EOT-*+1)/2*2
         DC    AL2(WTO#0011_EOT-*,0),C'TESTDCB3 ENDED OK'
WTO#0011_EOT     EQU *
         SVC   35
*MEXIT #=    11 LV= 1 WTO
*MCALL #=    12 LV= 1          SUBEXIT 
         LA    15,0
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=    12 LV= 1 SUBEXIT
ABORT    EQU   *
*MCALL #=    13 LV= 1          WTO   'TESTDCB3 ABORTING DUE TO I/O ERROX
               R NOW'
         BRAS  1,*+(WTO#0013_EOT-*+1)/2*2
         DC    AL2(WTO#0013_EOT-*,0),C'TESTDCB3 ABORTING DUE TO I/O ERRX
               OR NOW'
WTO#0013_EOT     EQU *
         SVC   35
*MEXIT #=    13 LV= 1 WTO
*MCALL #=    14 LV= 1          ABEND X'213',DUMP
         LA   1,X'213'
         OILH 1,X'8000'
         SVC  13 ABEND R1=COMP CODE AND HIGH BIT = DUMP PGM STORAGE
*MEXIT #=    14 LV= 1 ABEND
*MCALL #=    15 LV= 1 SYSUT1   DCB   DDNAME=SYSUT1,EODAD=EOF,MACRF=GM,SX
               YNAD=ABORT,RECFM=FB,LRECL=80,BLKSIZE=8000
SYSUT1   DS    0D             RPI 915
         DC    XL(DCBLEN)'00' RPI 946
         ORG   SYSUT1+DCBID-IHADCB        RPI88
         DC    C'DCBV1001'            RPI88
         ORG   SYSUT1+DCBDSORG-IHADCB
         DC    AL1(DCBDSORG_PS) DCBDSORG
         ORG   SYSUT1+DCBEODAD-IHADCB
         DC    A(EOF) DCBEODAD
         ORG   SYSUT1+DCBRECFM-IHADCB
         DC    AL1(DCBRECFM_FB) DCBRECFM
         ORG   SYSUT1+DCBDDNAM-IHADCB
         DC    CL8'SYSUT1' DCBDDNAM
         ORG   SYSUT1+DCBOFLGS-IHADCB
         DC    AL1(0) DCBOFLGS RPI 668 ZERO (SET AT OPEN)
         ORG   SYSUT1+DCBMACRF-IHADCB
         DC    AL2(DCBMACRF_GM) DCBMACRF
         ORG   SYSUT1+DCBSYNAD-IHADCB
         DC    A(ABORT) DCBSYNAD DCBSYNAD
         ORG   SYSUT1+DCBBLKSIF-IHADCB    RPI 587
         DC    F'8000' DCBBLKSIF  RPI 587
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
*MCALL #=    16 LV= 2          DCBD 
*MEXIT #=    16 LV= 2 DCBD
*MEXIT #=    15 LV= 1 DCB
*MCALL #=    17 LV= 1 SYSUT2   DCB   DDNAME=SYSUT2,MACRF=PM,SYNAD=ABORTX
               ,RECFM=FB,LRECL=80,BLKSIZE=8000
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
         DC    A(ABORT) DCBSYNAD DCBSYNAD
         ORG   SYSUT2+DCBBLKSIF-IHADCB    RPI 587
         DC    F'8000' DCBBLKSIF  RPI 587
         ORG   SYSUT2+DCBLRECLF-IHADCB    RPI 587
         DC    F'80' DCBLRECLF    RPI 587
         ORG   SYSUT2+DCBREC-IHADCB
         DC    A(0) DCBREC
         ORG   SYSUT2+DCBDSNAM-IHADCB
         DC    A(0) DCBDSNAM
         ORG   SYSUT2+DCBDCBE-IHADCB   RPI 281
         DC    A(0) DCBDCBE
         ORG   SYSUT2+DCBIO-IHADCB     RPI 907
         DC    A(0)     DCBIO      RPI 907 TOTAL IO COUNT SINCE OPEN
         ORG   SYSUT2+DCBLEN
*MCALL #=    18 LV= 2          DCBD 
*MEXIT #=    18 LV= 2 DCBD
*MEXIT #=    17 LV= 1 DCB
*MCALL #=    19 LV= 1 SYSOUT   DCB   DDNAME=SYSOUT,RECFM=FT,BLKSIZE=120X
               ,MACRF=PM
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
*MCALL #=    20 LV= 2          DCBD 
*MEXIT #=    20 LV= 2 DCBD
*MEXIT #=    19 LV= 1 DCB
PTOT     DC    PL2'0'
MSG      DS    0CL120
         DC    C'REC#='
DTOT     DC    CL4' ',C' TEXT='
RECORD   DC    CL80' '
         DC    (MSG+120-*)C' '
*MCALL #=    21 LV= 1          DCBD 
*MEXIT #=    21 LV= 1 DCBD
         END 
