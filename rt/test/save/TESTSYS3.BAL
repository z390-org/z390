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
* 2012-05-06  DSH Initial version                                   *
*********************************************************************
         TITLE 'TEST RPI-1213 FIXES FOR SYSECT, SYSLOC, SYSSTYP'
         MACRO
         SECTTEST &LOC,&BASE,&TYPE
         MNOTE 'SYSLOC=&SYSLOC SYSECT=&SYSECT SYSSTYP=&SYSSTYP'
 AIF (NOT('&SYSLOC' NE '&LOC')).AIF_1_1
             MNOTE 12,'SYSLOC ERROR'
.AIF_1_1 ANOP
 AIF (NOT('&SYSECT' NE '&BASE')).AIF_2_1
             MNOTE 12,'SYSECT ERROR'
.AIF_2_1 ANOP
 AIF (NOT('&SYSSTYP' NE '&TYPE')).AIF_3_1
             MONTE 12,'SYSSTYP ERROR'
.AIF_3_1 ANOP
         MEND
*MCALL #=     1 LV= 1          SECTTEST 
         MNOTE 'SYSLOC= SYSECT= SYSSTYP='
*MEXIT #=     1 LV= 1 SECTTEST
REGS     DSECT 
*MCALL #=     2 LV= 1          SECTTEST REGS,REGS,DSECT
         MNOTE 'SYSLOC=REGS SYSECT=REGS SYSSTYP=DSECT'
*MEXIT #=     2 LV= 1 SECTTEST
REGS2L   LOCTR 
*MCALL #=     3 LV= 1          SECTTEST REGS2L,REGS,DSECT
         MNOTE 'SYSLOC=REGS2L SYSECT=REGS SYSSTYP=DSECT'
*MEXIT #=     3 LV= 1 SECTTEST
TEST     START 
         SR   15,15
         BR   14
*MCALL #=     4 LV= 1          SECTTEST TEST,TEST,CSECT
         MNOTE 'SYSLOC=TEST SYSECT=TEST SYSSTYP=CSECT'
*MEXIT #=     4 LV= 1 SECTTEST
TEST2    CSECT 
         DC   CL8'TEST2'
*MCALL #=     5 LV= 1          SECTTEST TEST2,TEST2,CSECT
         MNOTE 'SYSLOC=TEST2 SYSECT=TEST2 SYSSTYP=CSECT'
*MEXIT #=     5 LV= 1 SECTTEST
TEST2L   LOCTR 
         DC   CL8'TEST2L'
*MCALL #=     6 LV= 1          SECTTEST TEST2L,TEST2,CSECT
         MNOTE 'SYSLOC=TEST2L SYSECT=TEST2 SYSSTYP=CSECT'
*MEXIT #=     6 LV= 1 SECTTEST
TEST3    RSECT 
         DC   CL8'TEST3'
*MCALL #=     7 LV= 1          SECTTEST TEST3,TEST3,RSECT
         MNOTE 'SYSLOC=TEST3 SYSECT=TEST3 SYSSTYP=RSECT'
*MEXIT #=     7 LV= 1 SECTTEST
         END 
