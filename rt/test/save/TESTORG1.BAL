*********************************************************************
* Copyright 2010 Automated Software Tools Corporation               *
* Copyright 2013 Cat Herder Software, LLC                           *
* Copyright 2018 Joachim Bartz, Germany                             *
*                                                                   *
* This source code is part of z390 assembler/emulator package.      *
*                                                                   *
* The z390 package is distributed under GNU general public license  *
*                                                                   *
* Author - Don Higgins                                              *
*********************************************************************
* 2008-11-10  DSH Initial version                                   *
*********************************************************************
CHSERROR TITLE 'Error Message handling'
         MACRO
&MSG#    #ERROR &TEXT,&MSGLVL=0,&SEV=0
         GBLB  &MSGDEF(10000)
         LCLA  &#
         LCLC  &#C,&TEMP
         AIF   ('&TEXT' EQ 'HEADER').HEADER
         AIF   ('&TEXT' EQ 'DSECT').DSECT
&TEMP    SETC  '&MSG#'(2,K'&MSG#-1)
&T       SETC  T'&TEMP
         AIF   (T'&TEMP EQ 'N').GOOD#
         MNOTE 12,'&TEMP NOT NUMERIC'
         MEXIT
.GOOD#   ANOP  ,
&#       SETA  &TEMP
         AIF   (NOT &MSGDEF(1+&#)).NOTADUP
         MNOTE 12,'MSG NUMBER &TEMP ALREADY DEFINED!'
         MEXIT
.NOTADUP ANOP  ,
&#C      SETC  '000&TEMP'(K'&TEMP,4)
&LAB#    SETC  'MSG&#C'
&MSGDEF(1+&#) SETB 1
         ORG   MESSAGES+(4*&#)
         DC    A(&LAB#)
         ORG   ,
&LAB#    DS    0C
         DC    AL2(&MSGLVL),AL2(&SEV),AL2(L'&LAB#.T)
&LAB#.T  DC    C&TEXT
         MEXIT
.HEADER  ANOP  ,
         DC    10000A(0)
         MEXIT
.DSECT   ANOP  ,
ERRENT   DSECT ,

         MEND
CHSERROR RSECT 
*MCALL #=     1 LV= 1          SAVE  (14,12)
         STM   14,12,12+4*(14-14)(13)
*MEXIT #=     1 LV= 1 SAVE
* CODE TO TEST DC A(MSGS) AFTER RPI 632
         USING CHSERROR,15
*MCALL #=     2 LV= 1          SNAP  ID=1
         IILL  0,1                  RPI158
         IILH 0,31744               RPI158
         LA    1,0
         SVC   51  SNAP DUMP R0=FLAGS,ID,R1=A(TEXT),R14-15=A(LOW,HIGH)
*MEXIT #=     2 LV= 1 SNAP
         LA    2,0(15)    R2=A(CHSERROR)
         AFI   2,X'9C90'  R2=A(MESSAGES+X'9C90') ADDR MSG0000 FROM PRN
         CL    2,=A(MSG0000)  VERIFY ADCON
         BNE   1
         LA    2,0(15)    R2=A(CHSERROR)
         AFI   2,X'9CA0'  R2=A(MESSAGES+X'9CA0') ADDR MSG9999 FROM PRN
         CL    2,=A(MSG9999)
         BNE   1
         SR    15,15
*MCALL #=     3 LV= 1          RETURN (14,12),RC=(15)
*MCALL #=     4 LV= 2         ZRETURN (14,12),,MF=I,RC=(15)
*MCALL #=     5 LV= 3          RESTORE (14,12),RC=(15)
         L     14,12(13)
         LM    0,12,20(13)
*MEXIT #=     5 LV= 3 RESTORE
         BR    14
*MEXIT #=     4 LV= 2 ZRETURN
*MEXIT #=     3 LV= 1 RETURN
CONSTANT LOCTR ,
WORK     DSECT ,
         DS    18F
WORKLEN  EQU   *-WORK
WORK24   DSECT ,
         DS    F
WORK24LEN EQU  *-WORK24
MESSAGES RSECT ,
*MCALL #=     6 LV= 1          #ERROR HEADER
         DC    10000A(0)
*MEXIT #=     6 LV= 1 #ERROR
*MCALL #=     7 LV= 1 M0        #ERROR '%1 started'
         ORG   MESSAGES+(4*0)
         DC    A(MSG0000)
         ORG   ,
MSG0000  DS    0C
         DC    AL2(0),AL2(0),AL2(L'MSG0000T)
MSG0000T DC    C'%1 started'
*MEXIT #=     7 LV= 1 #ERROR
*MCALL #=     8 LV= 1 M9999     #ERROR '%1 ended'
         ORG   MESSAGES+(4*9999)
         DC    A(MSG9999)
         ORG   ,
MSG9999  DS    0C
         DC    AL2(0),AL2(0),AL2(L'MSG9999T)
MSG9999T DC    C'%1 ended'
*MEXIT #=     8 LV= 1 #ERROR
*MCALL #=     9 LV= 1          #ERROR DSECT
ERRENT   DSECT ,
*MEXIT #=     9 LV= 1 #ERROR
         END 
