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
* 2005-11-18 DSH RPI 101 Correct open bug causing EOF error         *
* 2005-11-19 DSH         See TESTDCBE for same program run in ASCII *
*                        mode                                       *
* 2006-01-07 DSH         Change PDATE=TIOT to PDATA=DCB             *
* 2006-09-11 DSH RPI-363 Change test to rt\test directory           *
* 2007-02-07 DSH RPI-532 Correct path case for Linux                *
*********************************************************************
* Test for RECFM=FT and VT create and read contributed by MM        *
*********************************************************************
*MCALL #=     1 LV= 1 TESTDCBD SUBENTRY 
TESTDCBD CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTDCBD'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTDCBD+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
*MCALL #=     2 LV= 1          OPEN (PUTFT,OUTPUT,PUTVT,OUTPUT)
*MCALL #=     3 LV= 2          ZOPEN (PUTFT,OUTPUT,PUTVT,OUTPUT),MF=I,MX
               ODE=31,TYPE=
                       LA     1,PUTFT
                       LA  0,DCBOFLGS_PM   WRITE ONLY
                   SVC   19 OPEN R0=TYPE,R1=DCB/ACB
                         LTR   15,15
                         BNZ   Z390_OPEN_EXIT0003 RPI 668
                       LA     1,PUTVT
                       LA  0,DCBOFLGS_PM   WRITE ONLY
                   SVC   19 OPEN R0=TYPE,R1=DCB/ACB
                         LTR   15,15
                         BNZ   Z390_OPEN_EXIT0003 RPI 668
Z390_OPEN_EXIT0003    EQU *
*MCALL #=     4 LV= 3          DCBD 
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
TESTDCBD        CSECT                              RPI 591
*MEXIT #=     4 LV= 3 DCBD
*MEXIT #=     3 LV= 2 ZOPEN
*MEXIT #=     2 LV= 1 OPEN
*MCALL #=     5 LV= 1          PUT  PUTFT
         LA    1,PUTFT
         L     0,DCBREC-IHADCB(1)
         SVC  152 QSAM PUT R0=REC, R1=DCB
*MEXIT #=     5 LV= 1 PUT
*MCALL #=     6 LV= 1          PUT  PUTVT
         LA    1,PUTVT
         L     0,DCBREC-IHADCB(1)
         SVC  152 QSAM PUT R0=REC, R1=DCB
*MEXIT #=     6 LV= 1 PUT
*MCALL #=     7 LV= 1          CLOSE (PUTFT,,PUTVT)
*MCALL #=     8 LV= 2          ZCLOSE (PUTFT,,PUTVT),MODE=,MF=I,TYPE=
                       LA     1,PUTFT
                   SVC   20 CLOSE R1=DCB/ACB
                          LTR   15,15
                          BNZ   Z390_CLOSE_EXIT0008 RPI 668
                       LA     1,PUTVT
                   SVC   20 CLOSE R1=DCB/ACB
Z390_CLOSE_EXIT0008    EQU *
*MEXIT #=     8 LV= 2 ZCLOSE
*MEXIT #=     7 LV= 1 CLOSE
*MCALL #=     9 LV= 1          OPEN (GETFT,INPUT,GETVT,INPUT)
*MCALL #=    10 LV= 2          ZOPEN (GETFT,INPUT,GETVT,INPUT),MF=I,MODX
               E=31,TYPE=
                       LA     1,GETFT
                       LA  0,DCBOFLGS_GM   READ ONLY
                   SVC   19 OPEN R0=TYPE,R1=DCB/ACB
                         LTR   15,15
                         BNZ   Z390_OPEN_EXIT0010 RPI 668
                       LA     1,GETVT
                       LA  0,DCBOFLGS_GM   READ ONLY
                   SVC   19 OPEN R0=TYPE,R1=DCB/ACB
                         LTR   15,15
                         BNZ   Z390_OPEN_EXIT0010 RPI 668
Z390_OPEN_EXIT0010    EQU *
*MCALL #=    11 LV= 3          DCBD 
*MEXIT #=    11 LV= 3 DCBD
*MEXIT #=    10 LV= 2 ZOPEN
*MEXIT #=     9 LV= 1 OPEN
*MCALL #=    12 LV= 1          GET  GETFT
         LA    1,GETFT
         L     0,DCBREC-IHADCB(1)
         SVC  151
*MEXIT #=    12 LV= 1 GET
*MCALL #=    13 LV= 1          GET  GETVT
         LA    1,GETVT
         L     0,DCBREC-IHADCB(1)
         SVC  151
*MEXIT #=    13 LV= 1 GET
*MCALL #=    14 LV= 1          SNAP ID=1,TEXT='FILES OPEN',PDATA=DCB
         IILL  0,1                  RPI158
         IILH 0,2048               RPI158
         LA    1,=CL60'FILES OPEN'
         SVC   51  SNAP DUMP R0=FLAGS,ID,R1=A(TEXT),R14-15=A(LOW,HIGH)
*MEXIT #=    14 LV= 1 SNAP
*MCALL #=    15 LV= 1          CLOSE (GETFT,,GETVT)
*MCALL #=    16 LV= 2          ZCLOSE (GETFT,,GETVT),MODE=,MF=I,TYPE=
                       LA     1,GETFT
                   SVC   20 CLOSE R1=DCB/ACB
                          LTR   15,15
                          BNZ   Z390_CLOSE_EXIT0016 RPI 668
                       LA     1,GETVT
                   SVC   20 CLOSE R1=DCB/ACB
Z390_CLOSE_EXIT0016    EQU *
*MEXIT #=    16 LV= 2 ZCLOSE
*MEXIT #=    15 LV= 1 CLOSE
*MCALL #=    17 LV= 1          SNAP ID=2,TEXT='FILES CLOSED',PDATA=DCB
         IILL  0,2                  RPI158
         IILH 0,2048               RPI158
         LA    1,=CL60'FILES CLOSED'
         SVC   51  SNAP DUMP R0=FLAGS,ID,R1=A(TEXT),R14-15=A(LOW,HIGH)
*MEXIT #=    17 LV= 1 SNAP
*MCALL #=    18 LV= 1          SNAP STORAGE=(RECORD1,ENDIT),ID=3,TEXT='X
               RECORD AREAS',PDATA=
         L     14,=A(RECORD1)
         L     15,=A(ENDIT)
         IILL  0,3                  RPI158
         IILH 0,32768               RPI158
         LA    1,=CL60'RECORD AREAS'
         SVC   51  SNAP DUMP R0=FLAGS,ID,R1=A(TEXT),R14-15=A(LOW,HIGH)
*MEXIT #=    18 LV= 1 SNAP
*MCALL #=    19 LV= 1          SUBEXIT 
         LA    15,0
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=    19 LV= 1 SUBEXIT
*MCALL #=    20 LV= 1 PUTFT    DCB   RECFM=FT,LRECL=80,MACRF=PM,RECORD=X
               RECORD1,DSNAME=DSN1
PUTFT    DS    0D             RPI 915
         DC    XL(DCBLEN)'00' RPI 946
         ORG   PUTFT+DCBID-IHADCB        RPI88
         DC    C'DCBV1001'            RPI88
         ORG   PUTFT+DCBDSORG-IHADCB
         DC    AL1(DCBDSORG_PS) DCBDSORG
         ORG   PUTFT+DCBEODAD-IHADCB
         DC    A(0) DCBEODAD
         ORG   PUTFT+DCBRECFM-IHADCB
         DC    AL1(DCBRECFM_FT) DCBRECFM
         ORG   PUTFT+DCBDDNAM-IHADCB
         DC    CL8'PUTFT' DCBDDNAME
         ORG   PUTFT+DCBOFLGS-IHADCB
         DC    AL1(0) DCBOFLGS RPI 668 ZERO (SET AT OPEN)
         ORG   PUTFT+DCBMACRF-IHADCB
         DC    AL2(DCBMACRF_PM) DCBMACRF
         ORG   PUTFT+DCBSYNAD-IHADCB
         DC    A(0) DCBSYNAD DCBSYNAD
         ORG   PUTFT+DCBBLKSIF-IHADCB    RPI 587
         DC    F'0' DCBBLKSIF  RPI 587
         ORG   PUTFT+DCBLRECLF-IHADCB    RPI 587
         DC    F'80' DCBLRECLF    RPI 587
         ORG   PUTFT+DCBREC-IHADCB
         DC    A(RECORD1) DCBREC
         ORG   PUTFT+DCBDSNAM-IHADCB
         DC    A(DSN1) DCBDSNAM
         ORG   PUTFT+DCBDCBE-IHADCB   RPI 281
         DC    A(0) DCBDCBE
         ORG   PUTFT+DCBIO-IHADCB     RPI 907
         DC    A(0)     DCBIO      RPI 907 TOTAL IO COUNT SINCE OPEN
         ORG   PUTFT+DCBLEN
*MCALL #=    21 LV= 2          DCBD 
*MEXIT #=    21 LV= 2 DCBD
*MEXIT #=    20 LV= 1 DCB
*MCALL #=    22 LV= 1 PUTVT    DCB   RECFM=VT,LRECL=10,MACRF=PM,RECORD=X
               RECORD2,DSNAME=DSN2
PUTVT    DS    0D             RPI 915
         DC    XL(DCBLEN)'00' RPI 946
         ORG   PUTVT+DCBID-IHADCB        RPI88
         DC    C'DCBV1001'            RPI88
         ORG   PUTVT+DCBDSORG-IHADCB
         DC    AL1(DCBDSORG_PS) DCBDSORG
         ORG   PUTVT+DCBEODAD-IHADCB
         DC    A(0) DCBEODAD
         ORG   PUTVT+DCBRECFM-IHADCB
         DC    AL1(DCBRECFM_VT) DCBRECFM
         ORG   PUTVT+DCBDDNAM-IHADCB
         DC    CL8'PUTVT' DCBDDNAME
         ORG   PUTVT+DCBOFLGS-IHADCB
         DC    AL1(0) DCBOFLGS RPI 668 ZERO (SET AT OPEN)
         ORG   PUTVT+DCBMACRF-IHADCB
         DC    AL2(DCBMACRF_PM) DCBMACRF
         ORG   PUTVT+DCBSYNAD-IHADCB
         DC    A(0) DCBSYNAD DCBSYNAD
         ORG   PUTVT+DCBBLKSIF-IHADCB    RPI 587
         DC    F'0' DCBBLKSIF  RPI 587
         ORG   PUTVT+DCBLRECLF-IHADCB    RPI 587
         DC    F'10' DCBLRECLF    RPI 587
         ORG   PUTVT+DCBREC-IHADCB
         DC    A(RECORD2) DCBREC
         ORG   PUTVT+DCBDSNAM-IHADCB
         DC    A(DSN2) DCBDSNAM
         ORG   PUTVT+DCBDCBE-IHADCB   RPI 281
         DC    A(0) DCBDCBE
         ORG   PUTVT+DCBIO-IHADCB     RPI 907
         DC    A(0)     DCBIO      RPI 907 TOTAL IO COUNT SINCE OPEN
         ORG   PUTVT+DCBLEN
*MCALL #=    23 LV= 2          DCBD 
*MEXIT #=    23 LV= 2 DCBD
*MEXIT #=    22 LV= 1 DCB
*MCALL #=    24 LV= 1 GETFT    DCB   RECFM=FT,LRECL=80,MACRF=GM,RECORD=X
               RECORD3,DSNAME=DSN1
GETFT    DS    0D             RPI 915
         DC    XL(DCBLEN)'00' RPI 946
         ORG   GETFT+DCBID-IHADCB        RPI88
         DC    C'DCBV1001'            RPI88
         ORG   GETFT+DCBDSORG-IHADCB
         DC    AL1(DCBDSORG_PS) DCBDSORG
         ORG   GETFT+DCBEODAD-IHADCB
         DC    A(0) DCBEODAD
         ORG   GETFT+DCBRECFM-IHADCB
         DC    AL1(DCBRECFM_FT) DCBRECFM
         ORG   GETFT+DCBDDNAM-IHADCB
         DC    CL8'GETFT' DCBDDNAME
         ORG   GETFT+DCBOFLGS-IHADCB
         DC    AL1(0) DCBOFLGS RPI 668 ZERO (SET AT OPEN)
         ORG   GETFT+DCBMACRF-IHADCB
         DC    AL2(DCBMACRF_GM) DCBMACRF
         ORG   GETFT+DCBSYNAD-IHADCB
         DC    A(0) DCBSYNAD DCBSYNAD
         ORG   GETFT+DCBBLKSIF-IHADCB    RPI 587
         DC    F'0' DCBBLKSIF  RPI 587
         ORG   GETFT+DCBLRECLF-IHADCB    RPI 587
         DC    F'80' DCBLRECLF    RPI 587
         ORG   GETFT+DCBREC-IHADCB
         DC    A(RECORD3) DCBREC
         ORG   GETFT+DCBDSNAM-IHADCB
         DC    A(DSN1) DCBDSNAM
         ORG   GETFT+DCBDCBE-IHADCB   RPI 281
         DC    A(0) DCBDCBE
         ORG   GETFT+DCBIO-IHADCB     RPI 907
         DC    A(0)     DCBIO      RPI 907 TOTAL IO COUNT SINCE OPEN
         ORG   GETFT+DCBLEN
*MCALL #=    25 LV= 2          DCBD 
*MEXIT #=    25 LV= 2 DCBD
*MEXIT #=    24 LV= 1 DCB
*MCALL #=    26 LV= 1 GETVT    DCB   RECFM=VT,LRECL=10,MACRF=GM,RECORD=X
               RECORD4,DSNAME=DSN2
GETVT    DS    0D             RPI 915
         DC    XL(DCBLEN)'00' RPI 946
         ORG   GETVT+DCBID-IHADCB        RPI88
         DC    C'DCBV1001'            RPI88
         ORG   GETVT+DCBDSORG-IHADCB
         DC    AL1(DCBDSORG_PS) DCBDSORG
         ORG   GETVT+DCBEODAD-IHADCB
         DC    A(0) DCBEODAD
         ORG   GETVT+DCBRECFM-IHADCB
         DC    AL1(DCBRECFM_VT) DCBRECFM
         ORG   GETVT+DCBDDNAM-IHADCB
         DC    CL8'GETVT' DCBDDNAME
         ORG   GETVT+DCBOFLGS-IHADCB
         DC    AL1(0) DCBOFLGS RPI 668 ZERO (SET AT OPEN)
         ORG   GETVT+DCBMACRF-IHADCB
         DC    AL2(DCBMACRF_GM) DCBMACRF
         ORG   GETVT+DCBSYNAD-IHADCB
         DC    A(0) DCBSYNAD DCBSYNAD
         ORG   GETVT+DCBBLKSIF-IHADCB    RPI 587
         DC    F'0' DCBBLKSIF  RPI 587
         ORG   GETVT+DCBLRECLF-IHADCB    RPI 587
         DC    F'10' DCBLRECLF    RPI 587
         ORG   GETVT+DCBREC-IHADCB
         DC    A(RECORD4) DCBREC
         ORG   GETVT+DCBDSNAM-IHADCB
         DC    A(DSN2) DCBDSNAM
         ORG   GETVT+DCBDCBE-IHADCB   RPI 281
         DC    A(0) DCBDCBE
         ORG   GETVT+DCBIO-IHADCB     RPI 907
         DC    A(0)     DCBIO      RPI 907 TOTAL IO COUNT SINCE OPEN
         ORG   GETVT+DCBLEN
*MCALL #=    27 LV= 2          DCBD 
*MEXIT #=    27 LV= 2 DCBD
*MEXIT #=    26 LV= 1 DCB
DSN1     DC    C'rt\test\TESTDCBD.TF2',X'00'
DSN2     DC    C'rt\test\TESTDCBD.TF3',X'00'
RECORD1  DC    X'C1C2C3414243',CL74' '
RECORD2  DC    H'10',H'0'
         DC    X'C1C2C3414243'
RECORD3  DC    CL80' '
RECORD4  DC    CL10' '
ENDIT    EQU   *
*MCALL #=    28 LV= 1          DCBD 
*MEXIT #=    28 LV= 1 DCBD
*MCALL #=    29 LV= 1          EQUREGS 
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
*MEXIT #=    29 LV= 1 EQUREGS
         END 
