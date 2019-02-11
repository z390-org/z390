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
* 2005-11-08 DSH          Initial version                           *
* 2005-11-15 DSH RPI-92   Test non-zero memory addresses            *
* 2006-09-11 DSH RPI-363  Change test to rt\test directory          *
* 2007-02-07 DSH RPI-532  Change path case for Linux                *
* 2007-04-26 DSH RPI-600  Correct duplicate ID= on SNAP             *
* 2007-07-05 DSH RPI-642  Test TEXT=(REG) with NULL term support    *
* 2009-04-18 DSH RPI-1017 Add MF=L/E tests                          *
*********************************************************************
*MCALL #=     1 LV= 1 TESTDMP4 SUBENTRY 
TESTDMP4 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTDMP4'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTDMP4+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
*MCALL #=     2 LV= 1          WTO   'TESTDMP4 TEST SNAP DUMP OPTIONS'
         BRAS  1,*+(WTO#0002_EOT-*+1)/2*2
         DC    AL2(WTO#0002_EOT-*,0),C'TESTDMP4 TEST SNAP DUMP OPTIONS'
WTO#0002_EOT     EQU *
         SVC   35
*MEXIT #=     2 LV= 1 WTO
*MCALL #=     3 LV= 1          SNAP  ID=1,TEXT='DEFAULT ALL CONTROL BLOX
               CKS TO LOG'
         IILL  0,1                  RPI158
         IILH 0,31744               RPI158
         LA    1,=CL60'DEFAULT ALL CONTROL BLOCKS TO LOG'
         SVC   51  SNAP DUMP R0=FLAGS,ID,R1=A(TEXT),R14-15=A(LOW,HIGH)
*MEXIT #=     3 LV= 1 SNAP
*MCALL #=     4 LV= 1          OPEN  (SYSUT1)
*MCALL #=     5 LV= 2          ZOPEN (SYSUT1),MF=I,MODE=31,TYPE=
                       LA     1,SYSUT1
                       LA  0,DCBOFLGS_GM   READ ONLY
                   SVC   19 OPEN R0=TYPE,R1=DCB/ACB
*MCALL #=     6 LV= 3          DCBD 
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
TESTDMP4        CSECT                              RPI 591
*MEXIT #=     6 LV= 3 DCBD
*MEXIT #=     5 LV= 2 ZOPEN
*MEXIT #=     4 LV= 1 OPEN
*MCALL #=     7 LV= 1          SNAP  ID=2,PDATA=(GPR,DCB),TEXT='GPR REGX
               S AND FILES'
         IILL  0,2                  RPI158
         IILH 0,18432               RPI158
         LA    1,=CL60'GPR REGS AND FILES'
         SVC   51  SNAP DUMP R0=FLAGS,ID,R1=A(TEXT),R14-15=A(LOW,HIGH)
*MEXIT #=     7 LV= 1 SNAP
*MCALL #=     8 LV= 1          SNAP  ID=3,PDATA=FPR,TEXT='FPR REGS'
         IILL  0,3                  RPI158
         IILH 0,8192               RPI158
         LA    1,=CL60'FPR REGS'
         SVC   51  SNAP DUMP R0=FLAGS,ID,R1=A(TEXT),R14-15=A(LOW,HIGH)
*MEXIT #=     8 LV= 1 SNAP
*MCALL #=     9 LV= 1          SNAP  ID=4,STORAGE=(DATA1,DATA2),TEXT='LX
               OW MEMORY'
         L     14,=A(DATA1)
         L     15,=A(DATA2)
         IILL  0,4                  RPI158
         IILH 0,64512               RPI158
         LA    1,=CL60'LOW MEMORY'
         SVC   51  SNAP DUMP R0=FLAGS,ID,R1=A(TEXT),R14-15=A(LOW,HIGH)
*MEXIT #=     9 LV= 1 SNAP
         LA    2,TEXT
*MCALL #=    10 LV= 1          SNAP  ID=5,TEXT=(2)
         IILL  0,5                  RPI158
         IILH 0,31744               RPI158
*MCALL #=    11 LV= 2          ZOPTLR 1,2 RPI 642 PTR TO TEXT WITH NULLX
                TERM (MAX 60)
         LR    1,2
*MEXIT #=    11 LV= 2 ZOPTLR
         SVC   51  SNAP DUMP R0=FLAGS,ID,R1=A(TEXT),R14-15=A(LOW,HIGH)
*MEXIT #=    10 LV= 1 SNAP
*MCALL #=    12 LV= 1          WTO   'TESTDMP4 ENDED OK'
         BRAS  1,*+(WTO#0012_EOT-*+1)/2*2
         DC    AL2(WTO#0012_EOT-*,0),C'TESTDMP4 ENDED OK'
WTO#0012_EOT     EQU *
         SVC   35
*MEXIT #=    12 LV= 1 WTO
*MCALL #=    13 LV= 1          SNAP  PDATA=PSW,ID=1,TEXT='TEST STD FORMX
               '
         IILL  0,1                  RPI158
         IILH 0,0               RPI158
         LA    1,=CL60'TEST STD FORM'
         SVC   51  SNAP DUMP R0=FLAGS,ID,R1=A(TEXT),R14-15=A(LOW,HIGH)
*MEXIT #=    13 LV= 1 SNAP
*MCALL #=    14 LV= 1          SNAP  MF=(E,LIST2)
         LM    14,1,LIST2
         IILH  0,31744
         SVC   51  SNAP DUMP R0=FLAGS,ID,R1=A(TEXT),R14-15=A(LOW,HIGH)
*MEXIT #=    14 LV= 1 SNAP
         LA    3,LIST2
*MCALL #=    15 LV= 1          SNAP  MF=(E,(3))
         LM    14,1,0(3)
         IILH  0,31744
         SVC   51  SNAP DUMP R0=FLAGS,ID,R1=A(TEXT),R14-15=A(LOW,HIGH)
*MEXIT #=    15 LV= 1 SNAP
*MCALL #=    16 LV= 1          SNAP  MF=(E,LIST2),PDATA=PSW,ID=3,TEXT='X
               TEST LIST2 OVERRIDES',STORAGE=(LIST2,LIST4)
         LM    14,1,LIST2
         IILH  0,0
         IILL  0,3
         LA    1,=C'TEST LIST2 OVERRIDES'
         LM    14,15,=A(LIST2,LIST4)
         SVC   51  SNAP DUMP R0=FLAGS,ID,R1=A(TEXT),R14-15=A(LOW,HIGH)
*MEXIT #=    16 LV= 1 SNAP
*MCALL #=    17 LV= 1          SNAP  MF=(E,LIST4)
         LM    14,1,LIST4
         IILH  0,31744
         SVC   51  SNAP DUMP R0=FLAGS,ID,R1=A(TEXT),R14-15=A(LOW,HIGH)
*MEXIT #=    17 LV= 1 SNAP
*MCALL #=    18 LV= 1          SUBEXIT 
         LA    15,0
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=    18 LV= 1 SUBEXIT
*MCALL #=    19 LV= 1 LIST2    SNAP  MF=L,PDATA=(PSW,REGS),ID=2,TEXT='LX
               IST2'
LIST2    DS    0F
         DC    A(0,0) R14-R15 STORAGE RANGE
         DC    AL2(24576,2) R0 FLAGS AND ID
         DC    A(*+4)          R1 A(TEXT)
         DC    C'LIST2',X'00'
*MEXIT #=    19 LV= 1 SNAP
*MCALL #=    20 LV= 1 LIST4    SNAP  MF=L,PDATA=ALL,ID=4,STORAGE=(LIST2X
               ,LIST4),TEXT='LIST4'
LIST4    DS    0F
         DC    A(LIST2,LIST4) R14-R15 STORAGE RANGE
         DC    AL2(31744,4) R0 FLAGS AND ID
         DC    A(*+4)          R1 A(TEXT)
         DC    C'LIST4',X'00'
*MEXIT #=    20 LV= 1 SNAP
TEXT     DC    C'TEST TEXT=(2)',X'00' RPI 642
*MCALL #=    21 LV= 1 SYSUT1   DCB   RECFM=FT,BLKSIZE=80,MACRF=GM,DSNAMX
               E=DSN1
SYSUT1   DS    0D             RPI 915
         DC    XL(DCBLEN)'00' RPI 946
         ORG   SYSUT1+DCBID-IHADCB        RPI88
         DC    C'DCBV1001'            RPI88
         ORG   SYSUT1+DCBDSORG-IHADCB
         DC    AL1(DCBDSORG_PS) DCBDSORG
         ORG   SYSUT1+DCBEODAD-IHADCB
         DC    A(0) DCBEODAD
         ORG   SYSUT1+DCBRECFM-IHADCB
         DC    AL1(DCBRECFM_FT) DCBRECFM
         ORG   SYSUT1+DCBDDNAM-IHADCB
         DC    CL8'SYSUT1' DCBDDNAME
         ORG   SYSUT1+DCBOFLGS-IHADCB
         DC    AL1(0) DCBOFLGS RPI 668 ZERO (SET AT OPEN)
         ORG   SYSUT1+DCBMACRF-IHADCB
         DC    AL2(DCBMACRF_GM) DCBMACRF
         ORG   SYSUT1+DCBSYNAD-IHADCB
         DC    A(0) DCBSYNAD DCBSYNAD
         ORG   SYSUT1+DCBBLKSIF-IHADCB    RPI 587
         DC    F'80' DCBBLKSIF  RPI 587
         ORG   SYSUT1+DCBLRECLF-IHADCB    RPI 587
         DC    F'0' DCBLRECLF    RPI 587
         ORG   SYSUT1+DCBREC-IHADCB
         DC    A(0) DCBREC
         ORG   SYSUT1+DCBDSNAM-IHADCB
         DC    A(DSN1) DCBDSNAM
         ORG   SYSUT1+DCBDCBE-IHADCB   RPI 281
         DC    A(0) DCBDCBE
         ORG   SYSUT1+DCBIO-IHADCB     RPI 907
         DC    A(0)     DCBIO      RPI 907 TOTAL IO COUNT SINCE OPEN
         ORG   SYSUT1+DCBLEN
*MCALL #=    22 LV= 2          DCBD 
*MEXIT #=    22 LV= 2 DCBD
*MEXIT #=    21 LV= 1 DCB
DSN1     DC    C'rt\test\TESTDMP4.TF1',X'00'
DATA1    DC    C'MEMORY DUMP AREA'
DATA2    EQU   *
*MCALL #=    23 LV= 1          DCBD 
*MEXIT #=    23 LV= 1 DCBD
         END 
