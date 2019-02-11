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
* 2005-09-30  DSH         Initial version                           *
* 2006-01-27  DSH RPI-192 Test correctly handling of && in strings  *
* 2006-04-06  DSH RPI-259 Add remaining HLASM system variables for  *
*                         compatibility                             *
*********************************************************************
*MCALL #=     1 LV= 1 TESTSYS1 SUBENTRY 
TESTSYS1 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTSYS1'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTSYS1+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
*MCALL #=     2 LV= 1          WTO   'TESTSYS1 STARTED'
         BRAS  1,*+(WTO#0002_EOT-*+1)/2*2
         DC    AL2(WTO#0002_EOT-*,0),C'TESTSYS1 STARTED'
WTO#0002_EOT     EQU *
         SVC   35
*MEXIT #=     2 LV= 1 WTO
         MNOTE '&SYSASM=z390'
         MNOTE '&SYSCLOCK=2005-01-02 22:33:44.567000'
         MNOTE '&SYSDATC=20050102'
         MNOTE '&SYSDATE=01/02/05'
         MNOTE '&SYSPARM=12345'
         MNOTE '&SYSTEM_ID=Windows 10 10.0'
         MNOTE '&SYSTEM_JAVA=Oracle Corporation 11'
         MNOTE '&SYSTIME=22.33'
         MNOTE '&SYSVER=V1.5.07'
         MACRO
         TEST
         MNOTE '&&SYSECT=&SYSECT'
         MNOTE '&&SYSLOC=&SYSLOC'
         MNOTE '&&SYSSTYP=&SYSSTYP'
         MNOTE '&&SYSNDX=&SYSNDX'
         MNOTE '&&SYSNEST=&SYSNEST'
         MEND
*MCALL #=     3 LV= 1          TEST 
         MNOTE '&SYSECT=TESTSYS1'
         MNOTE '&SYSLOC=TESTSYS1'
         MNOTE '&SYSSTYP=CSECT'
         MNOTE '&SYSNDX=0003'
         MNOTE '&SYSNEST=1'
*MEXIT #=     3 LV= 1 TEST
TESTD    DSECT 
*MCALL #=     4 LV= 1          TEST 
         MNOTE '&SYSECT=TESTD'
         MNOTE '&SYSLOC=TESTD'
         MNOTE '&SYSSTYP=DSECT'
         MNOTE '&SYSNDX=0004'
         MNOTE '&SYSNEST=1'
*MEXIT #=     4 LV= 1 TEST
TESTDLOC LOCTR 
*MCALL #=     5 LV= 1          TEST 
         MNOTE '&SYSECT=TESTD'
         MNOTE '&SYSLOC=TESTDLOC'
         MNOTE '&SYSSTYP=DSECT'
         MNOTE '&SYSNDX=0005'
         MNOTE '&SYSNEST=1'
*MEXIT #=     5 LV= 1 TEST
TESTSYS1 CSECT 
*MCALL #=     6 LV= 1          TEST 
         MNOTE '&SYSECT=TESTSYS1'
         MNOTE '&SYSLOC=TESTSYS1'
         MNOTE '&SYSSTYP=CSECT'
         MNOTE '&SYSNDX=0006'
         MNOTE '&SYSNEST=1'
*MEXIT #=     6 LV= 1 TEST
         MNOTE '&SYSCLOCK=2005-01-02 22:33:44.567000'
         MNOTE 'COUNT TO 10000'
         MNOTE '&SYSCLOCK=2005-01-02 22:33:44.567000'
* TEST SYSMAC
         MNOTE '&SYSMAC=OPEN CODE'
         MNOTE '&SYSMAC(0)=OPEN CODE'
         MNOTE '&SYSMAC(1)='
         MNOTE '&SYSMAC(2)='
         MNOTE '&SYSMAC(3)='
         MNOTE '&SYSNEST=0 SYSMAC(SYSNEST)=OPEN CODE'
         MACRO
         TESTA
         MNOTE 'EXECUTING TESTA'
         MNOTE '&&SYSMAC=&SYSMAC'
         MNOTE '&&SYSMAC(0)=&SYSMAC(0)'
         MNOTE '&&SYSMAC(1)=&SYSMAC(1)'
         MNOTE '&&SYSMAC(2)=&SYSMAC(2)'
         MNOTE '&&SYSMAC(3)=&SYSMAC(3)'
         MNOTE '&&SYSNEST=&SYSNEST &&SYSMAC(SYSNEST)=&SYSMAC(&SYSNEST)'
         MEND
         MACRO
         TESTB
         MNOTE 'EXECUTING TESTB'
         TESTA
         MEND
*MCALL #=     7 LV= 1          TESTA 
         MNOTE 'EXECUTING TESTA'
         MNOTE '&SYSMAC=TESTA'
         MNOTE '&SYSMAC(0)=TESTA'
         MNOTE '&SYSMAC(1)=OPEN CODE'
         MNOTE '&SYSMAC(2)='
         MNOTE '&SYSMAC(3)='
         MNOTE '&SYSNEST=1 &SYSMAC(SYSNEST)=OPEN CODE'
*MEXIT #=     7 LV= 1 TESTA
*MCALL #=     8 LV= 1          TESTB 
         MNOTE 'EXECUTING TESTB'
*MCALL #=     9 LV= 2          TESTA 
         MNOTE 'EXECUTING TESTA'
         MNOTE '&SYSMAC=TESTA'
         MNOTE '&SYSMAC(0)=TESTA'
         MNOTE '&SYSMAC(1)=TESTB'
         MNOTE '&SYSMAC(2)=OPEN CODE'
         MNOTE '&SYSMAC(3)='
         MNOTE '&SYSNEST=2 &SYSMAC(SYSNEST)=OPEN CODE'
*MEXIT #=     9 LV= 2 TESTA
*MEXIT #=     8 LV= 1 TESTB
* TEST REMAINING SYSTEM VARIABLES ADDED FOR COMPATIBLITY
         MNOTE '&SYSADATA_DSN=C:\Users\Achim\GitHub\z390\rt\test\TESTSYX
               S1.ADA'
         MNOTE '&SYSADATA_MEMBER=TESTSYS1'
         MNOTE '&SYSADATA_VOLUME=C'
         MNOTE '&SYSIN_DSN=C:\Users\Achim\GitHub\z390\rt\test\TESTSYS1.X
               MLC'
         MNOTE '&SYSIN_MEMBER=TESTSYS1'
         MNOTE '&SYSIN_VOLUME=C'
         MNOTE '&SYSJOB=TESTSYS1'
         MNOTE '&SYSLIB_DSN=C:\Users\Achim\GitHub\z390\rt\test\TESTSYS1X
               .MLC'
         MNOTE '&SYSLIB_MEMBER=TESTSYS1'
         MNOTE '&SYSLIB_VOLUME=C'
         MNOTE '&SYSLIN_DSN=C:\Users\Achim\GitHub\z390\rt\test\TESTSYS1X
               .OBJ'
         MNOTE '&SYSLIN_MEMBER=TESTSYS1'
         MNOTE '&SYSLIN_VOLUME=C'
         MNOTE '&SYSM_HSEV=000'
         MNOTE '&SYSM_SEV=000'
         MNOTE '&SYSOPT_DBCS=0'
         MNOTE '&SYSOPT_OPTABLE=z390'
         MNOTE '&SYSOPT_RENT=0'
         MNOTE '&SYSOPT_XOBJECT=0'
         MNOTE '&SYSPRINT_DSN=C:\Users\Achim\GitHub\z390\rt\test\TESTSYX
               S1.PRN'
         MNOTE '&SYSPRINT_MEMBER=TESTSYS1'
         MNOTE '&SYSPRINT_VOLUME=C'
         MNOTE '&SYSPUNCH_DSN=C:\Users\Achim\GitHub\z390\rt\test\TESTSYX
               S1.PCH'
         MNOTE '&SYSPUNCH_MEMBER=TESTSYS1'
         MNOTE '&SYSPUNCH_VOLUME=C'
         MNOTE '&SYSSEQF='
         MNOTE '&SYSSTEP=TESTSYS1'
         MNOTE '&SYSSTMT=00000158'
         MNOTE '&SYSTERM_DSN=C:\Users\Achim\GitHub\z390\rt\test\TESTSYSX
               1.ERR'
         MNOTE '&SYSTERM_MEMBER=TESTSYS1'
         MNOTE '&SYSTERM_VOLUME=C'
*MCALL #=    10 LV= 1          WTO   'TESTSYS1 ENDED OK'
         BRAS  1,*+(WTO#0010_EOT-*+1)/2*2
         DC    AL2(WTO#0010_EOT-*,0),C'TESTSYS1 ENDED OK'
WTO#0010_EOT     EQU *
         SVC   35
*MEXIT #=    10 LV= 1 WTO
*MCALL #=    11 LV= 1          SUBEXIT 
         LA    15,0
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=    11 LV= 1 SUBEXIT
         END 
