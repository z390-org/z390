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
* 2005-10-28  DSH Initial version                                   *
* 2005-11-13  DSH RPI-88  Add validation for register conflicts     *
* 2005-11-17  DSH RPI-96  Add validation for RX DCB.                *
*                         RECFM/LRECL/BLKSIZE                       *
* 2005-11-20  DSH RPI-102 Add mutually exclusive EP/EPLOC           *
*********************************************************************
         TITLE 'TESTERR3 TEST MZ390 DCB, LOAD, LINK, XCTL, DEL ERRORS'
*MCALL #=     1 LV= 1 TESTERR3 SUBENTRY 
TESTERR3 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTERR3'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
*MCALL #=     2 LV= 2          ZOPTLR 13,13
*MEXIT #=     2 LV= 2 ZOPTLR
         USING TESTERR3+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
* TEST OPEN PARMS
*MCALL #=     3 LV= 1          OPEN  (SYSUT1,(INPUT))        OK
*MCALL #=     4 LV= 2          ZOPEN (SYSUT1,(INPUT)),MF=I,MODE=31,TYPEX
               =
                       LA     1,SYSUT1
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
*MEXIT #=     5 LV= 3 DCBD
*MEXIT #=     4 LV= 2 ZOPEN
*MEXIT #=     3 LV= 1 OPEN
*MCALL #=     6 LV= 1          OPEN  ((R1),(INPUT))          OK
*MCALL #=     7 LV= 2          ZOPEN ((R1),(INPUT)),MF=I,MODE=31,TYPE=
*MCALL #=     8 LV= 3                        ZOPTLR 1,(R1)
*MEXIT #=     8 LV= 3 ZOPTLR
                       LA  0,DCBOFLGS_GM   READ ONLY
                   SVC   19 OPEN R0=TYPE,R1=DCB/ACB
*MCALL #=     9 LV= 3          DCBD 
*MEXIT #=     9 LV= 3 DCBD
*MEXIT #=     7 LV= 2 ZOPEN
*MEXIT #=     6 LV= 1 OPEN
*MCALL #=    10 LV= 1          OPEN  (2)                     RX ERR MISX
               SING ()
*MCALL #=    11 LV= 2          ZOPEN (2),MF=I,MODE=31,TYPE=
                       LA     1,2
                       LA  0,DCBOFLGS_GM   READ ONLY
                   SVC   19 OPEN R0=TYPE,R1=DCB/ACB
*MCALL #=    12 LV= 3          DCBD 
*MEXIT #=    12 LV= 3 DCBD
*MEXIT #=    11 LV= 2 ZOPEN
*MEXIT #=    10 LV= 1 OPEN
*MCALL #=    13 LV= 1          OPEN  (2,(INPUT))             RX ERR MISX
               SING ()
*MCALL #=    14 LV= 2          ZOPEN (2,(INPUT)),MF=I,MODE=31,TYPE=
                       LA     1,2
                       LA  0,DCBOFLGS_GM   READ ONLY
                   SVC   19 OPEN R0=TYPE,R1=DCB/ACB
*MCALL #=    15 LV= 3          DCBD 
*MEXIT #=    15 LV= 3 DCBD
*MEXIT #=    14 LV= 2 ZOPEN
*MEXIT #=    13 LV= 1 OPEN
*MCALL #=    16 LV= 1          GET   SYSUT1,(R1)             R1 ERR REGX
                CONFLICT
         LA    1,SYSUT1
         MNOTE 12,'GET RECORD REG INVALID - R1'
*MEXIT #=    16 LV= 1 GET
*MCALL #=    17 LV= 1          PUT   SYSUT1,(R1)             R1 ERR REGX
                CONFLICT
         LA    1,SYSUT1
         MNOTE 12,'PUT RECORD REG INVALID - R1'
*MEXIT #=    17 LV= 1 PUT
* TEST GET, PUT, READ, WRITE REG CONFLICTS
*MCALL #=    18 LV= 1          READ  (R1),'SF',(R1),AREA     R1 ERR REGX
                CONFLICT
*MCALL #=    19 LV= 2          ZREAD (R1),'SF',(R1),AREA,MF=I
*MCALL #=    20 LV= 3          ZOPTLR 1,R1
*MEXIT #=    20 LV= 3 ZOPTLR
* MZ390E error 190      (10/64)64 Ordinary symbol reference requires ASX
               M option - R1
         ST    R1,DECBDCBA-IHADECB(1)
         LA    0,AREA
         ST    0,DECBAREA-IHADECB(1)
         SVC   153 READ R0=AREA, R1=DECB
*MEXIT #=    19 LV= 2 ZREAD
*MEXIT #=    18 LV= 1 READ
*MCALL #=    21 LV= 1          WRITE (R1),'SF',(R1),AREA     R1 ERR REGX
                CONFLICT
*MCALL #=    22 LV= 2          ZWRITE (R1),'SF',(R1),AREA,MF=I
*MCALL #=    23 LV= 3          ZOPTLR 1,R1
*MEXIT #=    23 LV= 3 ZOPTLR
* MZ390E error 190      (12/65)65 Ordinary symbol reference requires ASX
               M option - R1
         ST    R1,DECBDCBA-IHADECB(1)
         LA    0,AREA
         ST    0,DECBAREA-IHADECB(1)
         SVC   154 WRITE
*MEXIT #=    22 LV= 2 ZWRITE
*MEXIT #=    21 LV= 1 WRITE
*MCALL #=    24 LV= 1          READ  (R1),'SF',SYSUT1,(R1)   R1 ERR REGX
                CONFLICT
*MCALL #=    25 LV= 2          ZREAD (R1),'SF',SYSUT1,(R1),MF=I
*MCALL #=    26 LV= 3          ZOPTLR 1,R1
*MEXIT #=    26 LV= 3 ZOPTLR
         LA    0,SYSUT1
         ST    0,DECBDCBA-IHADECB(1)
* MZ390E error 190      (10/77)77 Ordinary symbol reference requires ASX
               M option - R1
         ST    R1,DECBAREA-IHADECB(1)
         SVC   153 READ R0=AREA, R1=DECB
*MEXIT #=    25 LV= 2 ZREAD
*MEXIT #=    24 LV= 1 READ
*MCALL #=    27 LV= 1          WRITE (R1),'SF',SYSUT1,(R1)   R1 ERR REGX
                CONFLICT
*MCALL #=    28 LV= 2          ZWRITE (R1),'SF',SYSUT1,(R1),MF=I
*MCALL #=    29 LV= 3          ZOPTLR 1,R1
*MEXIT #=    29 LV= 3 ZOPTLR
         LA    0,SYSUT1
         ST    0,DECBDCBA-IHADECB(1)
* MZ390E error 190      (12/78)78 Ordinary symbol reference requires ASX
               M option - R1
         ST    R1,DECBAREA-IHADECB(1)
         SVC   154 WRITE
*MEXIT #=    28 LV= 2 ZWRITE
*MEXIT #=    27 LV= 1 WRITE
*MCALL #=    30 LV= 1 SYSUT1   DCB   DSORG=PS,MACRF=GM,DDNAME=SYSUT1,LRX
               ECL=80
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
*MCALL #=    31 LV= 2          DCBD 
*MEXIT #=    31 LV= 2 DCBD
*MEXIT #=    30 LV= 1 DCB
AREA     DS    X
*MCALL #=    32 LV= 1 SYSUT2   DCB   DSORG=PS,MACRF=GM,DDNAME=SYSUT2,DSX
               NAME==C'"TEST"',LRECL=80                DD/DS ERR DD/DSNX
                CONFLICT
SYSUT2   DS    0D             RPI 915
         DC    XL(DCBLEN)'00' RPI 946
         MNOTE 12,'DSNAME AND DDNAME ARE MUTUALLY EXCLUSIVE'
*MEXIT #=    32 LV= 1 DCB
* TEST LOAD, LINK, XCTL DDNAME/DSNAME CONFLICTS
*MCALL #=    33 LV= 1          LOAD  EP=X,DDNAME=X,DSNAME=Y   ERR DD/DSX
               N CONFLICT
         LA    0,=CL8'X'
         MNOTE 12,'LOAD DSNAME AND DDNAME MUTUALLY EXCLUSIVE'
*MEXIT #=    33 LV= 1 LOAD
*MCALL #=    34 LV= 1          LINK  EP=X,DDNAME=X,DSNAME=Y   ERR DD/DSX
               N CONFLICT
         LA    0,=CL8'X'
         MNOTE 12,'LINK DSNAME AND DDNAME ARE MUTUALLY EXCLUSIVE'
*MEXIT #=    34 LV= 1 LINK
*MCALL #=    35 LV= 1          XCTL  EP=X,DDNAME=X,DSNAME=Y   ERR DD/DSX
               N CONFLICT
         LA    0,=CL8'X'
         MNOTE 12,'DSNAME AND DDNAME ARE MUTUALLY EXCLUSIVE'
         LA    15,Y
         SVC    7 XCTL R0=A(PGM) R1-PARMS R15=DDNAME/DSNAME ADDR OR 0
*MEXIT #=    35 LV= 1 XCTL
*MCALL #=    36 LV= 1          DELETE EP=X,DDNAME=X,DSNAME=Y  ERR DD/DSX
               N CONFLICT
*MCALL #=    37 LV= 2         ZDELETE DE=,EP=X,EPLOC=,DDNAME=X,DSNAME=YX
               ,MF=I,RELATED=
         LA    0,=CL8'X'
         MNOTE 12,'DELETE DSNAME AND DDNAME ARE MUTUALLY EXCLUSIVE'
         LA    15,Y
         SVC   9 DELETE R0=A(NAME) R15=DSNAME/DDNAME ADDR OR 0
*MEXIT #=    37 LV= 2 ZDELETE
*MEXIT #=    36 LV= 1 DELETE
*MCALL #=    38 LV= 1          LOAD  EP=X,EPLOC=X             ERR EP/EPX
               LOC CONFLICT
         LA    0,=CL8'X'
         MNOTE 12,'LOAD  EP AND EPLOC MUTUALLY EXCLUSIVE'
*MEXIT #=    38 LV= 1 LOAD
*MCALL #=    39 LV= 1          LINK  EP=X,EPLOC=X             ERR EP/EPX
               LOC CONFLICT
         LA    0,=CL8'X'
         SR    15,15 USE DEFAULT SYS390 SEARCH
         SVC    6 LINK R0=A(PGM) R1-PARMS R15=DDNAME/DSNAME ADDR OR 0
*MEXIT #=    39 LV= 1 LINK
*MCALL #=    40 LV= 1          XCTL  EP=X,EPLOC=X             ERR EP/EPX
               LOC CONFLICT
         LA    0,=CL8'X'
         SR    15,15 USE DEFAULT SYS390 SEARCH
         SVC    7 XCTL R0=A(PGM) R1-PARMS R15=DDNAME/DSNAME ADDR OR 0
*MEXIT #=    40 LV= 1 XCTL
*MCALL #=    41 LV= 1          DELETE EP=X,EPLOC=X            ERR EP/EPX
               LOC CONFLICT
*MCALL #=    42 LV= 2         ZDELETE DE=,EP=X,EPLOC=X,DDNAME=,DSNAME=,X
               MF=I,RELATED=
         LA    0,=CL8'X'
         MNOTE 12,'DELETE DE EP AND EPLOC ARE MUTUALLY EXCLUSIVE'
*MEXIT #=    42 LV= 2 ZDELETE
*MEXIT #=    41 LV= 1 DELETE
* TEST DCB RECFM/LRECL/BLKSIZE CONFLICTS
* NOTE DCB WILL ACCEPT EITHER LRECL OR BLKSIZE SINCE BLOCKED
*      FILES ARE REALLY NOT TREATED ANY DIFFERENT THAN UNBLOCKED FILES
*      USING RBA FLAT FILE INTERFACE.
*MCALL #=    43 LV= 1 F1       DCB   DSORG=PS,RECFM=F      ERR    LRECLX
               /BLKSIZE
F1       DS    0D             RPI 915
         DC    XL(DCBLEN)'00' RPI 946
         ORG   F1+DCBID-IHADCB        RPI88
         DC    C'DCBV1001'            RPI88
         ORG   F1+DCBDSORG-IHADCB
         DC    AL1(DCBDSORG_PS) DCBDSORG
         ORG   F1+DCBEODAD-IHADCB
         DC    A(0) DCBEODAD
         ORG   F1+DCBRECFM-IHADCB
         DC    AL1(DCBRECFM_F) DCBRECFM
         ORG   F1+DCBDDNAM-IHADCB
         DC    CL8'F1' DCBDDNAME
         ORG   F1+DCBOFLGS-IHADCB
         DC    AL1(0) DCBOFLGS RPI 668 ZERO (SET AT OPEN)
         ORG   F1+DCBMACRF-IHADCB
         DC    AL2(DCBMACRF_GM) DCBMACRF
         ORG   F1+DCBSYNAD-IHADCB
         DC    A(0) DCBSYNAD DCBSYNAD
         ORG   F1+DCBBLKSIF-IHADCB    RPI 587
         DC    F'0' DCBBLKSIF  RPI 587
         ORG   F1+DCBLRECLF-IHADCB    RPI 587
         DC    F'0' DCBLRECLF    RPI 587
         ORG   F1+DCBREC-IHADCB
         DC    A(0) DCBREC
         ORG   F1+DCBDSNAM-IHADCB
         DC    A(0) DCBDSNAM
         ORG   F1+DCBDCBE-IHADCB   RPI 281
         DC    A(0) DCBDCBE
         ORG   F1+DCBIO-IHADCB     RPI 907
         DC    A(0)     DCBIO      RPI 907 TOTAL IO COUNT SINCE OPEN
         ORG   F1+DCBLEN
*MCALL #=    44 LV= 2          DCBD 
*MEXIT #=    44 LV= 2 DCBD
*MEXIT #=    43 LV= 1 DCB
*MCALL #=    45 LV= 1 F2       DCB   DSORG=PS,RECFM=F,LRECL=80,BLKSIZE=X
               80
F2       DS    0D             RPI 915
         DC    XL(DCBLEN)'00' RPI 946
         ORG   F2+DCBID-IHADCB        RPI88
         DC    C'DCBV1001'            RPI88
         ORG   F2+DCBDSORG-IHADCB
         DC    AL1(DCBDSORG_PS) DCBDSORG
         ORG   F2+DCBEODAD-IHADCB
         DC    A(0) DCBEODAD
         ORG   F2+DCBRECFM-IHADCB
         DC    AL1(DCBRECFM_F) DCBRECFM
         ORG   F2+DCBDDNAM-IHADCB
         DC    CL8'F2' DCBDDNAME
         ORG   F2+DCBOFLGS-IHADCB
         DC    AL1(0) DCBOFLGS RPI 668 ZERO (SET AT OPEN)
         ORG   F2+DCBMACRF-IHADCB
         DC    AL2(DCBMACRF_GM) DCBMACRF
         ORG   F2+DCBSYNAD-IHADCB
         DC    A(0) DCBSYNAD DCBSYNAD
         ORG   F2+DCBBLKSIF-IHADCB    RPI 587
         DC    F'80' DCBBLKSIF  RPI 587
         ORG   F2+DCBLRECLF-IHADCB    RPI 587
         DC    F'80' DCBLRECLF    RPI 587
         ORG   F2+DCBREC-IHADCB
         DC    A(0) DCBREC
         ORG   F2+DCBDSNAM-IHADCB
         DC    A(0) DCBDSNAM
         ORG   F2+DCBDCBE-IHADCB   RPI 281
         DC    A(0) DCBDCBE
         ORG   F2+DCBIO-IHADCB     RPI 907
         DC    A(0)     DCBIO      RPI 907 TOTAL IO COUNT SINCE OPEN
         ORG   F2+DCBLEN
*MCALL #=    46 LV= 2          DCBD 
*MEXIT #=    46 LV= 2 DCBD
*MEXIT #=    45 LV= 1 DCB
*MCALL #=    47 LV= 1 F3       DCB   DSORG=PS,RECFM=F,LRECL=80,BLKSIZE=X
               160
F3       DS    0D             RPI 915
         DC    XL(DCBLEN)'00' RPI 946
         MNOTE 12,'DCB INVALID LRECL/BLKSIZE'
*MCALL #=    48 LV= 2          DCBD 
*MEXIT #=    48 LV= 2 DCBD
*MEXIT #=    47 LV= 1 DCB
*MCALL #=    49 LV= 1 FB1      DCB   DSORG=PS,RECFM=FB     ERR    LRECLX
               /BLKSIZE
FB1      DS    0D             RPI 915
         DC    XL(DCBLEN)'00' RPI 946
         ORG   FB1+DCBID-IHADCB        RPI88
         DC    C'DCBV1001'            RPI88
         ORG   FB1+DCBDSORG-IHADCB
         DC    AL1(DCBDSORG_PS) DCBDSORG
         ORG   FB1+DCBEODAD-IHADCB
         DC    A(0) DCBEODAD
         ORG   FB1+DCBRECFM-IHADCB
         DC    AL1(DCBRECFM_FB) DCBRECFM
         ORG   FB1+DCBDDNAM-IHADCB
         DC    CL8'FB1' DCBDDNAME
         ORG   FB1+DCBOFLGS-IHADCB
         DC    AL1(0) DCBOFLGS RPI 668 ZERO (SET AT OPEN)
         ORG   FB1+DCBMACRF-IHADCB
         DC    AL2(DCBMACRF_GM) DCBMACRF
         ORG   FB1+DCBSYNAD-IHADCB
         DC    A(0) DCBSYNAD DCBSYNAD
         ORG   FB1+DCBBLKSIF-IHADCB    RPI 587
         DC    F'0' DCBBLKSIF  RPI 587
         ORG   FB1+DCBLRECLF-IHADCB    RPI 587
         DC    F'0' DCBLRECLF    RPI 587
         ORG   FB1+DCBREC-IHADCB
         DC    A(0) DCBREC
         ORG   FB1+DCBDSNAM-IHADCB
         DC    A(0) DCBDSNAM
         ORG   FB1+DCBDCBE-IHADCB   RPI 281
         DC    A(0) DCBDCBE
         ORG   FB1+DCBIO-IHADCB     RPI 907
         DC    A(0)     DCBIO      RPI 907 TOTAL IO COUNT SINCE OPEN
         ORG   FB1+DCBLEN
*MCALL #=    50 LV= 2          DCBD 
*MEXIT #=    50 LV= 2 DCBD
*MEXIT #=    49 LV= 1 DCB
*MCALL #=    51 LV= 1 FB2      DCB   DSORG=PS,RECFM=FB,LRECL=80,BLKSIZEX
               =160
FB2      DS    0D             RPI 915
         DC    XL(DCBLEN)'00' RPI 946
         ORG   FB2+DCBID-IHADCB        RPI88
         DC    C'DCBV1001'            RPI88
         ORG   FB2+DCBDSORG-IHADCB
         DC    AL1(DCBDSORG_PS) DCBDSORG
         ORG   FB2+DCBEODAD-IHADCB
         DC    A(0) DCBEODAD
         ORG   FB2+DCBRECFM-IHADCB
         DC    AL1(DCBRECFM_FB) DCBRECFM
         ORG   FB2+DCBDDNAM-IHADCB
         DC    CL8'FB2' DCBDDNAME
         ORG   FB2+DCBOFLGS-IHADCB
         DC    AL1(0) DCBOFLGS RPI 668 ZERO (SET AT OPEN)
         ORG   FB2+DCBMACRF-IHADCB
         DC    AL2(DCBMACRF_GM) DCBMACRF
         ORG   FB2+DCBSYNAD-IHADCB
         DC    A(0) DCBSYNAD DCBSYNAD
         ORG   FB2+DCBBLKSIF-IHADCB    RPI 587
         DC    F'160' DCBBLKSIF  RPI 587
         ORG   FB2+DCBLRECLF-IHADCB    RPI 587
         DC    F'80' DCBLRECLF    RPI 587
         ORG   FB2+DCBREC-IHADCB
         DC    A(0) DCBREC
         ORG   FB2+DCBDSNAM-IHADCB
         DC    A(0) DCBDSNAM
         ORG   FB2+DCBDCBE-IHADCB   RPI 281
         DC    A(0) DCBDCBE
         ORG   FB2+DCBIO-IHADCB     RPI 907
         DC    A(0)     DCBIO      RPI 907 TOTAL IO COUNT SINCE OPEN
         ORG   FB2+DCBLEN
*MCALL #=    52 LV= 2          DCBD 
*MEXIT #=    52 LV= 2 DCBD
*MEXIT #=    51 LV= 1 DCB
*MCALL #=    53 LV= 1 FB3      DCB   DSORG=PS,RECFM=FB,LRECL=80,BLKSIZEX
               =150
FB3      DS    0D             RPI 915
         DC    XL(DCBLEN)'00' RPI 946
         MNOTE 12,'DCB INVALID LRECL/BLKSIZE'
*MCALL #=    54 LV= 2          DCBD 
*MEXIT #=    54 LV= 2 DCBD
*MEXIT #=    53 LV= 1 DCB
*MCALL #=    55 LV= 1 V1       DCB   DSORG=PS,RECFM=V      ERR    LRECLX
               /BLKSIZE
V1       DS    0D             RPI 915
         DC    XL(DCBLEN)'00' RPI 946
         ORG   V1+DCBID-IHADCB        RPI88
         DC    C'DCBV1001'            RPI88
         ORG   V1+DCBDSORG-IHADCB
         DC    AL1(DCBDSORG_PS) DCBDSORG
         ORG   V1+DCBEODAD-IHADCB
         DC    A(0) DCBEODAD
         ORG   V1+DCBRECFM-IHADCB
         DC    AL1(DCBRECFM_V) DCBRECFM
         ORG   V1+DCBDDNAM-IHADCB
         DC    CL8'V1' DCBDDNAME
         ORG   V1+DCBOFLGS-IHADCB
         DC    AL1(0) DCBOFLGS RPI 668 ZERO (SET AT OPEN)
         ORG   V1+DCBMACRF-IHADCB
         DC    AL2(DCBMACRF_GM) DCBMACRF
         ORG   V1+DCBSYNAD-IHADCB
         DC    A(0) DCBSYNAD DCBSYNAD
         ORG   V1+DCBBLKSIF-IHADCB    RPI 587
         DC    F'0' DCBBLKSIF  RPI 587
         ORG   V1+DCBLRECLF-IHADCB    RPI 587
         DC    F'0' DCBLRECLF    RPI 587
         ORG   V1+DCBREC-IHADCB
         DC    A(0) DCBREC
         ORG   V1+DCBDSNAM-IHADCB
         DC    A(0) DCBDSNAM
         ORG   V1+DCBDCBE-IHADCB   RPI 281
         DC    A(0) DCBDCBE
         ORG   V1+DCBIO-IHADCB     RPI 907
         DC    A(0)     DCBIO      RPI 907 TOTAL IO COUNT SINCE OPEN
         ORG   V1+DCBLEN
*MCALL #=    56 LV= 2          DCBD 
*MEXIT #=    56 LV= 2 DCBD
*MEXIT #=    55 LV= 1 DCB
*MCALL #=    57 LV= 1 V2       DCB   DSORG=PS,RECFM=V,LRECL=80,BLKSIZE=X
               80
V2       DS    0D             RPI 915
         DC    XL(DCBLEN)'00' RPI 946
         ORG   V2+DCBID-IHADCB        RPI88
         DC    C'DCBV1001'            RPI88
         ORG   V2+DCBDSORG-IHADCB
         DC    AL1(DCBDSORG_PS) DCBDSORG
         ORG   V2+DCBEODAD-IHADCB
         DC    A(0) DCBEODAD
         ORG   V2+DCBRECFM-IHADCB
         DC    AL1(DCBRECFM_V) DCBRECFM
         ORG   V2+DCBDDNAM-IHADCB
         DC    CL8'V2' DCBDDNAME
         ORG   V2+DCBOFLGS-IHADCB
         DC    AL1(0) DCBOFLGS RPI 668 ZERO (SET AT OPEN)
         ORG   V2+DCBMACRF-IHADCB
         DC    AL2(DCBMACRF_GM) DCBMACRF
         ORG   V2+DCBSYNAD-IHADCB
         DC    A(0) DCBSYNAD DCBSYNAD
         ORG   V2+DCBBLKSIF-IHADCB    RPI 587
         DC    F'80' DCBBLKSIF  RPI 587
         ORG   V2+DCBLRECLF-IHADCB    RPI 587
         DC    F'80' DCBLRECLF    RPI 587
         ORG   V2+DCBREC-IHADCB
         DC    A(0) DCBREC
         ORG   V2+DCBDSNAM-IHADCB
         DC    A(0) DCBDSNAM
         ORG   V2+DCBDCBE-IHADCB   RPI 281
         DC    A(0) DCBDCBE
         ORG   V2+DCBIO-IHADCB     RPI 907
         DC    A(0)     DCBIO      RPI 907 TOTAL IO COUNT SINCE OPEN
         ORG   V2+DCBLEN
*MCALL #=    58 LV= 2          DCBD 
*MEXIT #=    58 LV= 2 DCBD
*MEXIT #=    57 LV= 1 DCB
*MCALL #=    59 LV= 1 V3       DCB   DSORG=PS,RECFM=V,LRECL=80,BLKSIZE=X
               84
V3       DS    0D             RPI 915
         DC    XL(DCBLEN)'00' RPI 946
         MNOTE 12,'DCB INVALID LRECL/BLKSIZE'
*MCALL #=    60 LV= 2          DCBD 
*MEXIT #=    60 LV= 2 DCBD
*MEXIT #=    59 LV= 1 DCB
*MCALL #=    61 LV= 1 VB1      DCB   DSORG=PS,RECFM=VB     ERR    LRECLX
               /BLKSIZE
VB1      DS    0D             RPI 915
         DC    XL(DCBLEN)'00' RPI 946
         ORG   VB1+DCBID-IHADCB        RPI88
         DC    C'DCBV1001'            RPI88
         ORG   VB1+DCBDSORG-IHADCB
         DC    AL1(DCBDSORG_PS) DCBDSORG
         ORG   VB1+DCBEODAD-IHADCB
         DC    A(0) DCBEODAD
         ORG   VB1+DCBRECFM-IHADCB
         DC    AL1(DCBRECFM_VB) DCBRECFM
         ORG   VB1+DCBDDNAM-IHADCB
         DC    CL8'VB1' DCBDDNAME
         ORG   VB1+DCBOFLGS-IHADCB
         DC    AL1(0) DCBOFLGS RPI 668 ZERO (SET AT OPEN)
         ORG   VB1+DCBMACRF-IHADCB
         DC    AL2(DCBMACRF_GM) DCBMACRF
         ORG   VB1+DCBSYNAD-IHADCB
         DC    A(0) DCBSYNAD DCBSYNAD
         ORG   VB1+DCBBLKSIF-IHADCB    RPI 587
         DC    F'0' DCBBLKSIF  RPI 587
         ORG   VB1+DCBLRECLF-IHADCB    RPI 587
         DC    F'0' DCBLRECLF    RPI 587
         ORG   VB1+DCBREC-IHADCB
         DC    A(0) DCBREC
         ORG   VB1+DCBDSNAM-IHADCB
         DC    A(0) DCBDSNAM
         ORG   VB1+DCBDCBE-IHADCB   RPI 281
         DC    A(0) DCBDCBE
         ORG   VB1+DCBIO-IHADCB     RPI 907
         DC    A(0)     DCBIO      RPI 907 TOTAL IO COUNT SINCE OPEN
         ORG   VB1+DCBLEN
*MCALL #=    62 LV= 2          DCBD 
*MEXIT #=    62 LV= 2 DCBD
*MEXIT #=    61 LV= 1 DCB
*MCALL #=    63 LV= 1 VB2      DCB   DSORG=PS,RECFM=VB,LRECL=80,BLKSIZEX
               =84
VB2      DS    0D             RPI 915
         DC    XL(DCBLEN)'00' RPI 946
         ORG   VB2+DCBID-IHADCB        RPI88
         DC    C'DCBV1001'            RPI88
         ORG   VB2+DCBDSORG-IHADCB
         DC    AL1(DCBDSORG_PS) DCBDSORG
         ORG   VB2+DCBEODAD-IHADCB
         DC    A(0) DCBEODAD
         ORG   VB2+DCBRECFM-IHADCB
         DC    AL1(DCBRECFM_VB) DCBRECFM
         ORG   VB2+DCBDDNAM-IHADCB
         DC    CL8'VB2' DCBDDNAME
         ORG   VB2+DCBOFLGS-IHADCB
         DC    AL1(0) DCBOFLGS RPI 668 ZERO (SET AT OPEN)
         ORG   VB2+DCBMACRF-IHADCB
         DC    AL2(DCBMACRF_GM) DCBMACRF
         ORG   VB2+DCBSYNAD-IHADCB
         DC    A(0) DCBSYNAD DCBSYNAD
         ORG   VB2+DCBBLKSIF-IHADCB    RPI 587
         DC    F'84' DCBBLKSIF  RPI 587
         ORG   VB2+DCBLRECLF-IHADCB    RPI 587
         DC    F'80' DCBLRECLF    RPI 587
         ORG   VB2+DCBREC-IHADCB
         DC    A(0) DCBREC
         ORG   VB2+DCBDSNAM-IHADCB
         DC    A(0) DCBDSNAM
         ORG   VB2+DCBDCBE-IHADCB   RPI 281
         DC    A(0) DCBDCBE
         ORG   VB2+DCBIO-IHADCB     RPI 907
         DC    A(0)     DCBIO      RPI 907 TOTAL IO COUNT SINCE OPEN
         ORG   VB2+DCBLEN
*MCALL #=    64 LV= 2          DCBD 
*MEXIT #=    64 LV= 2 DCBD
*MEXIT #=    63 LV= 1 DCB
*MCALL #=    65 LV= 1 VB3      DCB   DSORG=PS,RECFM=VB,LRECL=80,BLKSIZEX
               =80
VB3      DS    0D             RPI 915
         DC    XL(DCBLEN)'00' RPI 946
         MNOTE 12,'DCB INVALID LRECL/BLKSIZE'
*MCALL #=    66 LV= 2          DCBD 
*MEXIT #=    66 LV= 2 DCBD
*MEXIT #=    65 LV= 1 DCB
*MCALL #=    67 LV= 1 FT1      DCB   DSORG=PS,RECFM=FT     ERR    LRECLX
               /BLKSIZE
FT1      DS    0D             RPI 915
         DC    XL(DCBLEN)'00' RPI 946
         ORG   FT1+DCBID-IHADCB        RPI88
         DC    C'DCBV1001'            RPI88
         ORG   FT1+DCBDSORG-IHADCB
         DC    AL1(DCBDSORG_PS) DCBDSORG
         ORG   FT1+DCBEODAD-IHADCB
         DC    A(0) DCBEODAD
         ORG   FT1+DCBRECFM-IHADCB
         DC    AL1(DCBRECFM_FT) DCBRECFM
         ORG   FT1+DCBDDNAM-IHADCB
         DC    CL8'FT1' DCBDDNAME
         ORG   FT1+DCBOFLGS-IHADCB
         DC    AL1(0) DCBOFLGS RPI 668 ZERO (SET AT OPEN)
         ORG   FT1+DCBMACRF-IHADCB
         DC    AL2(DCBMACRF_GM) DCBMACRF
         ORG   FT1+DCBSYNAD-IHADCB
         DC    A(0) DCBSYNAD DCBSYNAD
         ORG   FT1+DCBBLKSIF-IHADCB    RPI 587
         DC    F'0' DCBBLKSIF  RPI 587
         ORG   FT1+DCBLRECLF-IHADCB    RPI 587
         DC    F'0' DCBLRECLF    RPI 587
         ORG   FT1+DCBREC-IHADCB
         DC    A(0) DCBREC
         ORG   FT1+DCBDSNAM-IHADCB
         DC    A(0) DCBDSNAM
         ORG   FT1+DCBDCBE-IHADCB   RPI 281
         DC    A(0) DCBDCBE
         ORG   FT1+DCBIO-IHADCB     RPI 907
         DC    A(0)     DCBIO      RPI 907 TOTAL IO COUNT SINCE OPEN
         ORG   FT1+DCBLEN
*MCALL #=    68 LV= 2          DCBD 
*MEXIT #=    68 LV= 2 DCBD
*MEXIT #=    67 LV= 1 DCB
*MCALL #=    69 LV= 1 FT2      DCB   DSORG=PS,RECFM=FT,LRECL=80,BLKSIZEX
               =80
FT2      DS    0D             RPI 915
         DC    XL(DCBLEN)'00' RPI 946
         ORG   FT2+DCBID-IHADCB        RPI88
         DC    C'DCBV1001'            RPI88
         ORG   FT2+DCBDSORG-IHADCB
         DC    AL1(DCBDSORG_PS) DCBDSORG
         ORG   FT2+DCBEODAD-IHADCB
         DC    A(0) DCBEODAD
         ORG   FT2+DCBRECFM-IHADCB
         DC    AL1(DCBRECFM_FT) DCBRECFM
         ORG   FT2+DCBDDNAM-IHADCB
         DC    CL8'FT2' DCBDDNAME
         ORG   FT2+DCBOFLGS-IHADCB
         DC    AL1(0) DCBOFLGS RPI 668 ZERO (SET AT OPEN)
         ORG   FT2+DCBMACRF-IHADCB
         DC    AL2(DCBMACRF_GM) DCBMACRF
         ORG   FT2+DCBSYNAD-IHADCB
         DC    A(0) DCBSYNAD DCBSYNAD
         ORG   FT2+DCBBLKSIF-IHADCB    RPI 587
         DC    F'80' DCBBLKSIF  RPI 587
         ORG   FT2+DCBLRECLF-IHADCB    RPI 587
         DC    F'80' DCBLRECLF    RPI 587
         ORG   FT2+DCBREC-IHADCB
         DC    A(0) DCBREC
         ORG   FT2+DCBDSNAM-IHADCB
         DC    A(0) DCBDSNAM
         ORG   FT2+DCBDCBE-IHADCB   RPI 281
         DC    A(0) DCBDCBE
         ORG   FT2+DCBIO-IHADCB     RPI 907
         DC    A(0)     DCBIO      RPI 907 TOTAL IO COUNT SINCE OPEN
         ORG   FT2+DCBLEN
*MCALL #=    70 LV= 2          DCBD 
*MEXIT #=    70 LV= 2 DCBD
*MEXIT #=    69 LV= 1 DCB
*MCALL #=    71 LV= 1 FT3      DCB   DSORG=PS,RECFM=FT,LRECL=80,BLKSIZEX
               =160
FT3      DS    0D             RPI 915
         DC    XL(DCBLEN)'00' RPI 946
         MNOTE 12,'DCB INVALID LRECL/BLKSIZE'
*MCALL #=    72 LV= 2          DCBD 
*MEXIT #=    72 LV= 2 DCBD
*MEXIT #=    71 LV= 1 DCB
*MCALL #=    73 LV= 1 VT1      DCB   DSORG=PS,RECFM=VT     ERR    LRECLX
               /BLKSIZE
VT1      DS    0D             RPI 915
         DC    XL(DCBLEN)'00' RPI 946
         MNOTE 12,'DCB INVALID LRECL/BLKSIZE'
*MCALL #=    74 LV= 2          DCBD 
*MEXIT #=    74 LV= 2 DCBD
*MEXIT #=    73 LV= 1 DCB
*MCALL #=    75 LV= 1 VT2      DCB   DSORG=PS,RECFM=VT,LRECL=80,BLKSIZEX
               =80
VT2      DS    0D             RPI 915
         DC    XL(DCBLEN)'00' RPI 946
         ORG   VT2+DCBID-IHADCB        RPI88
         DC    C'DCBV1001'            RPI88
         ORG   VT2+DCBDSORG-IHADCB
         DC    AL1(DCBDSORG_PS) DCBDSORG
         ORG   VT2+DCBEODAD-IHADCB
         DC    A(0) DCBEODAD
         ORG   VT2+DCBRECFM-IHADCB
         DC    AL1(DCBRECFM_VT) DCBRECFM
         ORG   VT2+DCBDDNAM-IHADCB
         DC    CL8'VT2' DCBDDNAME
         ORG   VT2+DCBOFLGS-IHADCB
         DC    AL1(0) DCBOFLGS RPI 668 ZERO (SET AT OPEN)
         ORG   VT2+DCBMACRF-IHADCB
         DC    AL2(DCBMACRF_GM) DCBMACRF
         ORG   VT2+DCBSYNAD-IHADCB
         DC    A(0) DCBSYNAD DCBSYNAD
         ORG   VT2+DCBBLKSIF-IHADCB    RPI 587
         DC    F'80' DCBBLKSIF  RPI 587
         ORG   VT2+DCBLRECLF-IHADCB    RPI 587
         DC    F'80' DCBLRECLF    RPI 587
         ORG   VT2+DCBREC-IHADCB
         DC    A(0) DCBREC
         ORG   VT2+DCBDSNAM-IHADCB
         DC    A(0) DCBDSNAM
         ORG   VT2+DCBDCBE-IHADCB   RPI 281
         DC    A(0) DCBDCBE
         ORG   VT2+DCBIO-IHADCB     RPI 907
         DC    A(0)     DCBIO      RPI 907 TOTAL IO COUNT SINCE OPEN
         ORG   VT2+DCBLEN
*MCALL #=    76 LV= 2          DCBD 
*MEXIT #=    76 LV= 2 DCBD
*MEXIT #=    75 LV= 1 DCB
*MCALL #=    77 LV= 1 VT3      DCB   DSORG=PS,RECFM=VT,LRECL=80,BLKSIZEX
               =160
VT3      DS    0D             RPI 915
         DC    XL(DCBLEN)'00' RPI 946
         MNOTE 12,'DCB INVALID LRECL/BLKSIZE'
*MCALL #=    78 LV= 2          DCBD 
*MEXIT #=    78 LV= 2 DCBD
*MEXIT #=    77 LV= 1 DCB
*MCALL #=    79 LV= 1 VBS      DCB   DSORG=PS,RECFM=VBS    ERR    LRECLX
               /BLKSIZE NOT YET
VBS      DS    0D             RPI 915
         DC    XL(DCBLEN)'00' RPI 946
         MNOTE 12,'INVALID RECFM - VBS'
*MEXIT #=    79 LV= 1 DCB
*MCALL #=    80 LV= 1 U        DCB   DSORG=PS,RECFM=U      ERR    LRECLX
               /BLKSIZE NOT YET
U        DS    0D             RPI 915
         DC    XL(DCBLEN)'00' RPI 946
         MNOTE 12,'INVALID RECFM - U'
*MEXIT #=    80 LV= 1 DCB
         END 
* MZ390I total mnote warnings = 0
* MZ390I total mnote errors   = 18
* MZ390I max   mnote level    = 12
* MZ390I total mz390 errors   = 4
