*********************************************************************
* Copyright 2008 Automated Software Tools Corporation               *
* Copyright 2013 Cat Herder Software, LLC                           *
* Copyright 2018 Joachim Bartz, Germany                             *
*                                                                   *
* This source code is part of z390 assembler/emulator package.      *
*                                                                   *
* The z390 package is distributed under GNU general public license  *
*                                                                   *
* Author - Don Higgins                                              *
*********************************************************************
* 2008-08-13 DSH         Initial version                            *
* 2008-09-23 DSH RPI-909 New regression test for SPM's              *
*********************************************************************
         TITLE 'TESTSPM1 - TEST ZSTRMAC STRUCTURED ASSEMBLER MACROS'
*MCALL #=     1 LV= 1 TESTSPM1 SUBENTRY 
TESTSPM1 CSECT 
         STM   14,12,12(13)
         BAL   15,104(15)
         DC    18F'0'
         DC    CL8'TESTSPM1'
         DC    CL8'01/02/05'
         DC    CL8'22.33'
         ST    15,8(13)
         ST    13,4(15)
         LR    13,15
         USING TESTSPM1+8,13
*MEXIT #=     1 LV= 1 SUBENTRY
*MCALL #=     2 LV= 1          WTO   'TESTSPM1 STARTED'
         BRAS  1,*+(WTO#0002_EOT-*+1)/2*2
         DC    AL2(WTO#0002_EOT-*,0),C'TESTSPM1 STARTED'
WTO#0002_EOT     EQU *
         SVC   35
*MEXIT #=     2 LV= 1 WTO
*
* TEST IF, ELSEIF, ELSE, ENDIF
*
*MCALL #=     3 LV= 1          IF    (CLC,=C'A',LT,=C'B')
*MCALL #=     4 LV= 2          ZSTREQU 
         PUSH  PRINT,NOPRINT
         PRINT OFF,NOPRINT
H        EQU   2
L        EQU   4
E        EQU   8
NH       EQU   13
NL       EQU   11
NE       EQU   7
O        EQU   1
P        EQU   2
M        EQU   4
Z        EQU   8
NP       EQU   13
NM       EQU   11
NZ       EQU   7
NO       EQU   14
EQ       EQU   8
GT       EQU   2
LT       EQU   4
GE       EQU   11
LE       EQU   13
         POP   PRINT,NOPRINT
*MEXIT #=     4 LV= 2 ZSTREQU
         CLC   =C'A',=C'B'
         BC    15-LT,#@IF_1_2
*MEXIT #=     3 LV= 1 IF
               AP  PTEST,=P'1'
*MCALL #=     5 LV= 1          ENDIF 
*MCALL #=     6 LV= 2          ZSTREQU 
*MEXIT #=     6 LV= 2 ZSTREQU
#@IF_1_2                                                 DS 0H
*MEXIT #=     5 LV= 1 ENDIF
*MCALL #=     7 LV= 1          IF    (CLC,=C'A',LT,=C'B'),AND,(CLC,=C'AX
               ',EQ,=C'A')
*MCALL #=     8 LV= 2          ZSTREQU 
*MEXIT #=     8 LV= 2 ZSTREQU
         CLC   =C'A',=C'B'
         BC    15-LT,#@IF_2_2
         CLC   =C'A',=C'A'
         BC    15-EQ,#@IF_2_2
*MEXIT #=     7 LV= 1 IF
               AP  PTEST,=P'1'
*MCALL #=     9 LV= 1          ENDIF 
*MCALL #=    10 LV= 2          ZSTREQU 
*MEXIT #=    10 LV= 2 ZSTREQU
#@IF_2_2                                                 DS 0H
*MEXIT #=     9 LV= 1 ENDIF
*MCALL #=    11 LV= 1          IF    (CLC,=C'A',GT,=C'B'),OR,(CLC,=C'A'X
               ,EQ,=C'A')
*MCALL #=    12 LV= 2          ZSTREQU 
*MEXIT #=    12 LV= 2 ZSTREQU
         CLC   =C'A',=C'B'
         BC    15-GT,#@IF_3_2
         B     #@IF_3_1
#@IF_3_2                                                 DS 0H
         CLC   =C'A',=C'A'
         BC    15-EQ,#@IF_3_3
#@IF_3_1                                DS 0H
*MEXIT #=    11 LV= 1 IF
               AP  PTEST,=P'1'
*MCALL #=    13 LV= 1          ENDIF 
*MCALL #=    14 LV= 2          ZSTREQU 
*MEXIT #=    14 LV= 2 ZSTREQU
#@IF_3_3                                                 DS 0H
*MEXIT #=    13 LV= 1 ENDIF
*MCALL #=    15 LV= 1          IF    (CLC,=C'B',LT,=C'A')
*MCALL #=    16 LV= 2          ZSTREQU 
*MEXIT #=    16 LV= 2 ZSTREQU
         CLC   =C'B',=C'A'
         BC    15-LT,#@IF_4_2
*MEXIT #=    15 LV= 1 IF
*MCALL #=    17 LV= 1                WTO 'TESTSPM1 ERROR B < A'
         BRAS  1,*+(WTO#0017_EOT-*+1)/2*2
         DC    AL2(WTO#0017_EOT-*,0),C'TESTSPM1 ERROR B < A'
WTO#0017_EOT     EQU *
         SVC   35
*MEXIT #=    17 LV= 1 WTO
*MCALL #=    18 LV= 1                SUBEXIT RC=16
         LA    15,16
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=    18 LV= 1 SUBEXIT
*MCALL #=    19 LV= 1          ELSEIF (CLC,=C'D',LT,=C'C')
*MCALL #=    20 LV= 2          ZSTREQU 
*MEXIT #=    20 LV= 2 ZSTREQU
         B     #@IF_4_E
#@IF_4_2                                                 DS 0H
         CLC   =C'D',=C'C'
         BC    15-LT,#@IF_4_4
*MEXIT #=    19 LV= 1 ELSEIF
*MCALL #=    21 LV= 1                WTO 'TESTSPM1 ERROR B < A'
         BRAS  1,*+(WTO#0021_EOT-*+1)/2*2
         DC    AL2(WTO#0021_EOT-*,0),C'TESTSPM1 ERROR B < A'
WTO#0021_EOT     EQU *
         SVC   35
*MEXIT #=    21 LV= 1 WTO
*MCALL #=    22 LV= 1                SUBEXIT RC=16
         LA    15,16
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=    22 LV= 1 SUBEXIT
*MCALL #=    23 LV= 1          ELSE 
*MCALL #=    24 LV= 2          ZSTREQU 
*MEXIT #=    24 LV= 2 ZSTREQU
        B      #@IF_4_E
#@IF_4_4                                                 DS 0H
*MEXIT #=    23 LV= 1 ELSE
               AP  PTEST,=P'1'
*MCALL #=    25 LV= 1          ENDIF 
*MCALL #=    26 LV= 2          ZSTREQU 
*MEXIT #=    26 LV= 2 ZSTREQU
#@IF_4_E                         DS 0H
*MEXIT #=    25 LV= 1 ENDIF
*MCALL #=    27 LV= 1          IF    (CLC,=C'F',LT,=C'E')
*MCALL #=    28 LV= 2          ZSTREQU 
*MEXIT #=    28 LV= 2 ZSTREQU
         CLC   =C'F',=C'E'
         BC    15-LT,#@IF_5_2
*MEXIT #=    27 LV= 1 IF
*MCALL #=    29 LV= 1                WTO 'TESTSPM1 ERROR B < A'
         BRAS  1,*+(WTO#0029_EOT-*+1)/2*2
         DC    AL2(WTO#0029_EOT-*,0),C'TESTSPM1 ERROR B < A'
WTO#0029_EOT     EQU *
         SVC   35
*MEXIT #=    29 LV= 1 WTO
*MCALL #=    30 LV= 1                SUBEXIT RC=16
         LA    15,16
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=    30 LV= 1 SUBEXIT
*MCALL #=    31 LV= 1          ELSEIF (CLC,=C'A',LT,=C'B'),AND,(CLC,=C'X
               C',LT,=C'D')
*MCALL #=    32 LV= 2          ZSTREQU 
*MEXIT #=    32 LV= 2 ZSTREQU
         B     #@IF_5_E
#@IF_5_2                                                 DS 0H
         CLC   =C'A',=C'B'
         BC    15-LT,#@IF_5_4
         CLC   =C'C',=C'D'
         BC    15-LT,#@IF_5_4
*MEXIT #=    31 LV= 1 ELSEIF
               AP  PTEST,=P'1'
*MCALL #=    33 LV= 1          ELSE 
*MCALL #=    34 LV= 2          ZSTREQU 
*MEXIT #=    34 LV= 2 ZSTREQU
        B      #@IF_5_E
#@IF_5_4                                                 DS 0H
*MEXIT #=    33 LV= 1 ELSE
*MCALL #=    35 LV= 1                WTO 'TESTSPM1 ELSEIF AND TEST FAILX
               ED'
         BRAS  1,*+(WTO#0035_EOT-*+1)/2*2
         DC    AL2(WTO#0035_EOT-*,0),C'TESTSPM1 ELSEIF AND TEST FAILED'
WTO#0035_EOT     EQU *
         SVC   35
*MEXIT #=    35 LV= 1 WTO
*MCALL #=    36 LV= 1                SUBEXIT RC=16
         LA    15,16
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=    36 LV= 1 SUBEXIT
*MCALL #=    37 LV= 1          ENDIF 
*MCALL #=    38 LV= 2          ZSTREQU 
*MEXIT #=    38 LV= 2 ZSTREQU
#@IF_5_E                         DS 0H
*MEXIT #=    37 LV= 1 ENDIF
*MCALL #=    39 LV= 1          IF    (CLC,=C'F',LT,=C'E')
*MCALL #=    40 LV= 2          ZSTREQU 
*MEXIT #=    40 LV= 2 ZSTREQU
         CLC   =C'F',=C'E'
         BC    15-LT,#@IF_6_2
*MEXIT #=    39 LV= 1 IF
*MCALL #=    41 LV= 1                WTO 'TESTSPM1 ERROR B < A'
         BRAS  1,*+(WTO#0041_EOT-*+1)/2*2
         DC    AL2(WTO#0041_EOT-*,0),C'TESTSPM1 ERROR B < A'
WTO#0041_EOT     EQU *
         SVC   35
*MEXIT #=    41 LV= 1 WTO
*MCALL #=    42 LV= 1                SUBEXIT RC=16
         LA    15,16
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=    42 LV= 1 SUBEXIT
*MCALL #=    43 LV= 1          ELSEIF (CLC,=C'A',GT,=C'B'),OR,(CLC,=C'CX
               ',LT,=C'D')
*MCALL #=    44 LV= 2          ZSTREQU 
*MEXIT #=    44 LV= 2 ZSTREQU
         B     #@IF_6_E
#@IF_6_2                                                 DS 0H
         CLC   =C'A',=C'B'
         BC    15-GT,#@IF_6_4
         B     #@IF_6_3
#@IF_6_4                                                 DS 0H
         CLC   =C'C',=C'D'
         BC    15-LT,#@IF_6_5
#@IF_6_3                                DS 0H
*MEXIT #=    43 LV= 1 ELSEIF
               AP  PTEST,=P'1'
*MCALL #=    45 LV= 1          ELSE 
*MCALL #=    46 LV= 2          ZSTREQU 
*MEXIT #=    46 LV= 2 ZSTREQU
        B      #@IF_6_E
#@IF_6_5                                                 DS 0H
*MEXIT #=    45 LV= 1 ELSE
*MCALL #=    47 LV= 1                WTO 'TESTSPM1 ELSEIF AND TEST FAILX
               ED'
         BRAS  1,*+(WTO#0047_EOT-*+1)/2*2
         DC    AL2(WTO#0047_EOT-*,0),C'TESTSPM1 ELSEIF AND TEST FAILED'
WTO#0047_EOT     EQU *
         SVC   35
*MEXIT #=    47 LV= 1 WTO
*MCALL #=    48 LV= 1                SUBEXIT RC=16
         LA    15,16
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=    48 LV= 1 SUBEXIT
*MCALL #=    49 LV= 1          ENDIF 
*MCALL #=    50 LV= 2          ZSTREQU 
*MEXIT #=    50 LV= 2 ZSTREQU
#@IF_6_E                         DS 0H
*MEXIT #=    49 LV= 1 ENDIF
*
* TEST DO WHILE=,ENDDO
*
         LA    1,5
*MCALL #=    51 LV= 1          DO    WHILE=(LTR,1,NZ,1)
*MCALL #=    52 LV= 2          ZSTREQU 
*MEXIT #=    52 LV= 2 ZSTREQU
#@DO_1_T                         DS 0H
*MCALL #=    53 LV= 2          IF LTR,1,NZ,1
*MCALL #=    54 LV= 3          ZSTREQU 
*MEXIT #=    54 LV= 3 ZSTREQU
         LTR   1,1
         BC    15-NZ,#@IF_7_2
*MEXIT #=    53 LV= 2 IF
               B   #@DO_1_1
*MCALL #=    55 LV= 2          ENDIF 
*MCALL #=    56 LV= 3          ZSTREQU 
*MEXIT #=    56 LV= 3 ZSTREQU
#@IF_7_2                                                 DS 0H
*MEXIT #=    55 LV= 2 ENDIF
         B     #@DO_1_E
#@DO_1_1                         DS 0H
*MEXIT #=    51 LV= 1 DO
               AP  PTEST,=P'1'
               BCTR 1,0
*MCALL #=    57 LV= 1          ENDDO 
*MCALL #=    58 LV= 2          DO    END
*MCALL #=    59 LV= 3          ZSTREQU 
*MEXIT #=    59 LV= 3 ZSTREQU
         B     #@DO_1_T
#@DO_1_E                         DS 0H
*MEXIT #=    58 LV= 2 DO
*MEXIT #=    57 LV= 1 ENDDO
         LA    1,5
*MCALL #=    60 LV= 1          DO    WHILE=((CLI,=C'A',EQ,C'B'),OR,(LTRX
               ,1,NZ,1))
*MCALL #=    61 LV= 2          ZSTREQU 
*MEXIT #=    61 LV= 2 ZSTREQU
#@DO_2_T                         DS 0H
*MCALL #=    62 LV= 2          IF (CLI,=C'A',EQ,C'B'),OR,(LTR,1,NZ,1)
*MCALL #=    63 LV= 3          ZSTREQU 
*MEXIT #=    63 LV= 3 ZSTREQU
         CLI   =C'A',C'B'
         BC    15-EQ,#@IF_8_2
         B     #@IF_8_1
#@IF_8_2                                                 DS 0H
         LTR   1,1
         BC    15-NZ,#@IF_8_3
#@IF_8_1                                DS 0H
*MEXIT #=    62 LV= 2 IF
               B   #@DO_2_1
*MCALL #=    64 LV= 2          ENDIF 
*MCALL #=    65 LV= 3          ZSTREQU 
*MEXIT #=    65 LV= 3 ZSTREQU
#@IF_8_3                                                 DS 0H
*MEXIT #=    64 LV= 2 ENDIF
         B     #@DO_2_E
#@DO_2_1                         DS 0H
*MEXIT #=    60 LV= 1 DO
               AP  PTEST,=P'1'
               BCTR 1,0
*MCALL #=    66 LV= 1          ENDDO 
*MCALL #=    67 LV= 2          DO    END
*MCALL #=    68 LV= 3          ZSTREQU 
*MEXIT #=    68 LV= 3 ZSTREQU
         B     #@DO_2_T
#@DO_2_E                         DS 0H
*MEXIT #=    67 LV= 2 DO
*MEXIT #=    66 LV= 1 ENDDO
*
* TEST DO UNTIL=,ENDDO
*
         LA    1,5
*MCALL #=    69 LV= 1          DO    UNTIL=(LTR,1,EQ,1)
*MCALL #=    70 LV= 2          ZSTREQU 
*MEXIT #=    70 LV= 2 ZSTREQU
         B     #@DO_3_1
#@DO_3_T                         DS 0H
*MCALL #=    71 LV= 2          IF    LTR,1,EQ,1
*MCALL #=    72 LV= 3          ZSTREQU 
*MEXIT #=    72 LV= 3 ZSTREQU
         LTR   1,1
         BC    15-EQ,#@IF_9_2
*MEXIT #=    71 LV= 2 IF
               B     #@DO_3_E
*MCALL #=    73 LV= 2          ENDIF 
*MCALL #=    74 LV= 3          ZSTREQU 
*MEXIT #=    74 LV= 3 ZSTREQU
#@IF_9_2                                                 DS 0H
*MEXIT #=    73 LV= 2 ENDIF
#@DO_3_1                         DS 0H
*MEXIT #=    69 LV= 1 DO
               AP  PTEST,=P'1'
               BCTR 1,0
*MCALL #=    75 LV= 1          ENDDO 
*MCALL #=    76 LV= 2          DO    END
*MCALL #=    77 LV= 3          ZSTREQU 
*MEXIT #=    77 LV= 3 ZSTREQU
         B     #@DO_3_T
#@DO_3_E                         DS 0H
*MEXIT #=    76 LV= 2 DO
*MEXIT #=    75 LV= 1 ENDDO
         LA    1,5
*MCALL #=    78 LV= 1          DO    UNTIL=((CLI,=C'A',EQ,C'B'),OR,(LTRX
               ,1,EQ,1))
*MCALL #=    79 LV= 2          ZSTREQU 
*MEXIT #=    79 LV= 2 ZSTREQU
         B     #@DO_4_1
#@DO_4_T                         DS 0H
*MCALL #=    80 LV= 2          IF    (CLI,=C'A',EQ,C'B'),OR,(LTR,1,EQ,1X
               )
*MCALL #=    81 LV= 3          ZSTREQU 
*MEXIT #=    81 LV= 3 ZSTREQU
         CLI   =C'A',C'B'
         BC    15-EQ,#@IF_10_2
         B     #@IF_10_1
#@IF_10_2                                                DS 0H
         LTR   1,1
         BC    15-EQ,#@IF_10_3
#@IF_10_1                               DS 0H
*MEXIT #=    80 LV= 2 IF
               B     #@DO_4_E
*MCALL #=    82 LV= 2          ENDIF 
*MCALL #=    83 LV= 3          ZSTREQU 
*MEXIT #=    83 LV= 3 ZSTREQU
#@IF_10_3                                                DS 0H
*MEXIT #=    82 LV= 2 ENDIF
#@DO_4_1                         DS 0H
*MEXIT #=    78 LV= 1 DO
               AP  PTEST,=P'1'
               BCTR 1,0
*MCALL #=    84 LV= 1          ENDDO 
*MCALL #=    85 LV= 2          DO    END
*MCALL #=    86 LV= 3          ZSTREQU 
*MEXIT #=    86 LV= 3 ZSTREQU
         B     #@DO_4_T
#@DO_4_E                         DS 0H
*MEXIT #=    85 LV= 2 DO
*MEXIT #=    84 LV= 1 ENDDO
*
* TEST SELECT, WHEN, OTHRWISE, ENDSEL
*
         MVI    FLAG,2
*MCALL #=    87 LV= 1          SELECT CLI,FLAG,EQ
*MCALL #=    88 LV= 2          ZSTREQU 
*MEXIT #=    88 LV= 2 ZSTREQU
*MEXIT #=    87 LV= 1 SELECT
*MCALL #=    89 LV= 1          WHEN  1
*MCALL #=    90 LV= 2          ZSTREQU 
*MEXIT #=    90 LV= 2 ZSTREQU
         CLI                     FLAG,1
         BC    15-EQ,#@SEL_1_1
*MEXIT #=    89 LV= 1 WHEN
*MCALL #=    91 LV= 1                WTO 'TESTSPM1 SELECT WHEN 1 ERROR'
         BRAS  1,*+(WTO#0091_EOT-*+1)/2*2
         DC    AL2(WTO#0091_EOT-*,0),C'TESTSPM1 SELECT WHEN 1 ERROR'
WTO#0091_EOT     EQU *
         SVC   35
*MEXIT #=    91 LV= 1 WTO
*MCALL #=    92 LV= 1                SUBEXIT RC=16
         LA    15,16
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=    92 LV= 1 SUBEXIT
*MCALL #=    93 LV= 1          WHEN 2
*MCALL #=    94 LV= 2          ZSTREQU 
*MEXIT #=    94 LV= 2 ZSTREQU
         B     #@SEL_1_E
#@SEL_1_1                                                 DS 0H
         CLI                     FLAG,2
         BC    15-EQ,#@SEL_1_2
*MEXIT #=    93 LV= 1 WHEN
               AP  PTEST,=P'1'
*MCALL #=    95 LV= 1          OTHRWISE 
*MCALL #=    96 LV= 2          ZSTREQU 
*MEXIT #=    96 LV= 2 ZSTREQU
         B     #@SEL_1_E
#@SEL_1_2                                                 DS 0H
*MEXIT #=    95 LV= 1 OTHRWISE
*MCALL #=    97 LV= 1                WTO 'TESTSPM1 SELECT OTHRWISE ERROX
               R'
         BRAS  1,*+(WTO#0097_EOT-*+1)/2*2
         DC    AL2(WTO#0097_EOT-*,0),C'TESTSPM1 SELECT OTHRWISE ERROR'
WTO#0097_EOT     EQU *
         SVC   35
*MEXIT #=    97 LV= 1 WTO
*MCALL #=    98 LV= 1                SUBEXIT RC=16
         LA    15,16
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=    98 LV= 1 SUBEXIT
*MCALL #=    99 LV= 1          ENDSEL 
*MCALL #=   100 LV= 2          ZSTREQU 
*MEXIT #=   100 LV= 2 ZSTREQU
#@SEL_1_E                         DS 0H
*MEXIT #=    99 LV= 1 ENDSEL
         MVI    FLAG,0
*MCALL #=   101 LV= 1          SELECT CLI,FLAG,EQ
*MCALL #=   102 LV= 2          ZSTREQU 
*MEXIT #=   102 LV= 2 ZSTREQU
*MEXIT #=   101 LV= 1 SELECT
*MCALL #=   103 LV= 1          WHEN  1
*MCALL #=   104 LV= 2          ZSTREQU 
*MEXIT #=   104 LV= 2 ZSTREQU
         CLI                     FLAG,1
         BC    15-EQ,#@SEL_2_1
*MEXIT #=   103 LV= 1 WHEN
*MCALL #=   105 LV= 1                WTO 'TESTSPM1 SELECT WHEN 1 ERROR'
         BRAS  1,*+(WTO#0105_EOT-*+1)/2*2
         DC    AL2(WTO#0105_EOT-*,0),C'TESTSPM1 SELECT WHEN 1 ERROR'
WTO#0105_EOT     EQU *
         SVC   35
*MEXIT #=   105 LV= 1 WTO
*MCALL #=   106 LV= 1                SUBEXIT RC=16
         LA    15,16
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=   106 LV= 1 SUBEXIT
*MCALL #=   107 LV= 1          OTHRWISE 
*MCALL #=   108 LV= 2          ZSTREQU 
*MEXIT #=   108 LV= 2 ZSTREQU
         B     #@SEL_2_E
#@SEL_2_1                                                 DS 0H
*MEXIT #=   107 LV= 1 OTHRWISE
               AP  PTEST,=P'1'
*MCALL #=   109 LV= 1          ENDSEL 
*MCALL #=   110 LV= 2          ZSTREQU 
*MEXIT #=   110 LV= 2 ZSTREQU
#@SEL_2_E                         DS 0H
*MEXIT #=   109 LV= 1 ENDSEL
         MVI    FLAG,3
*MCALL #=   111 LV= 1          SELECT CLI,FLAG,EQ
*MCALL #=   112 LV= 2          ZSTREQU 
*MEXIT #=   112 LV= 2 ZSTREQU
*MEXIT #=   111 LV= 1 SELECT
*MCALL #=   113 LV= 1          WHEN  3
*MCALL #=   114 LV= 2          ZSTREQU 
*MEXIT #=   114 LV= 2 ZSTREQU
         CLI                     FLAG,3
         BC    15-EQ,#@SEL_3_1
*MEXIT #=   113 LV= 1 WHEN
               AP  PTEST,=P'1'
*MCALL #=   115 LV= 1          ENDSEL 
*MCALL #=   116 LV= 2          ZSTREQU 
*MEXIT #=   116 LV= 2 ZSTREQU
#@SEL_3_1                                                 DS 0H
*MEXIT #=   115 LV= 1 ENDSEL
         ZAP    DEC,=P'2'
*MCALL #=   117 LV= 1          SELECT CP,DEC,EQ
*MCALL #=   118 LV= 2          ZSTREQU 
*MEXIT #=   118 LV= 2 ZSTREQU
*MEXIT #=   117 LV= 1 SELECT
*MCALL #=   119 LV= 1          WHEN  =P'1'
*MCALL #=   120 LV= 2          ZSTREQU 
*MEXIT #=   120 LV= 2 ZSTREQU
         CP                      DEC,=P'1'
         BC    15-EQ,#@SEL_4_1
*MEXIT #=   119 LV= 1 WHEN
*MCALL #=   121 LV= 1                WTO 'TESTSPM1 SELECT WHEN 1 ERROR'
         BRAS  1,*+(WTO#0121_EOT-*+1)/2*2
         DC    AL2(WTO#0121_EOT-*,0),C'TESTSPM1 SELECT WHEN 1 ERROR'
WTO#0121_EOT     EQU *
         SVC   35
*MEXIT #=   121 LV= 1 WTO
*MCALL #=   122 LV= 1                SUBEXIT RC=16
         LA    15,16
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=   122 LV= 1 SUBEXIT
*MCALL #=   123 LV= 1          WHEN =P'2'
*MCALL #=   124 LV= 2          ZSTREQU 
*MEXIT #=   124 LV= 2 ZSTREQU
         B     #@SEL_4_E
#@SEL_4_1                                                 DS 0H
         CP                      DEC,=P'2'
         BC    15-EQ,#@SEL_4_2
*MEXIT #=   123 LV= 1 WHEN
               AP  PTEST,=P'1'
*MCALL #=   125 LV= 1          ENDSEL 
*MCALL #=   126 LV= 2          ZSTREQU 
*MEXIT #=   126 LV= 2 ZSTREQU
#@SEL_4_2                                                 DS 0H
#@SEL_4_E                         DS 0H
*MEXIT #=   125 LV= 1 ENDSEL
         MVI    FLAG,2
*MCALL #=   127 LV= 1          SELECT 
*MCALL #=   128 LV= 2          ZSTREQU 
*MEXIT #=   128 LV= 2 ZSTREQU
*MEXIT #=   127 LV= 1 SELECT
*MCALL #=   129 LV= 1          WHEN  CLI,FLAG,EQ,1
*MCALL #=   130 LV= 2          ZSTREQU 
*MEXIT #=   130 LV= 2 ZSTREQU
         CLI         FLAG,1
         BC    15-EQ,#@SEL_5_1
*MEXIT #=   129 LV= 1 WHEN
*MCALL #=   131 LV= 1                WTO 'TESTSPM1 SELECT WHEN 1 ERROR'
         BRAS  1,*+(WTO#0131_EOT-*+1)/2*2
         DC    AL2(WTO#0131_EOT-*,0),C'TESTSPM1 SELECT WHEN 1 ERROR'
WTO#0131_EOT     EQU *
         SVC   35
*MEXIT #=   131 LV= 1 WTO
*MCALL #=   132 LV= 1                SUBEXIT RC=16
         LA    15,16
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=   132 LV= 1 SUBEXIT
*MCALL #=   133 LV= 1          WHEN CLI,FLAG,EQ,2
*MCALL #=   134 LV= 2          ZSTREQU 
*MEXIT #=   134 LV= 2 ZSTREQU
         B     #@SEL_5_E
#@SEL_5_1                                                 DS 0H
         CLI         FLAG,2
         BC    15-EQ,#@SEL_5_2
*MEXIT #=   133 LV= 1 WHEN
               AP  PTEST,=P'1'
*MCALL #=   135 LV= 1          OTHRWISE 
*MCALL #=   136 LV= 2          ZSTREQU 
*MEXIT #=   136 LV= 2 ZSTREQU
         B     #@SEL_5_E
#@SEL_5_2                                                 DS 0H
*MEXIT #=   135 LV= 1 OTHRWISE
*MCALL #=   137 LV= 1                WTO 'TESTSPM1 SELECT OTHRWISE ERROX
               R'
         BRAS  1,*+(WTO#0137_EOT-*+1)/2*2
         DC    AL2(WTO#0137_EOT-*,0),C'TESTSPM1 SELECT OTHRWISE ERROR'
WTO#0137_EOT     EQU *
         SVC   35
*MEXIT #=   137 LV= 1 WTO
*MCALL #=   138 LV= 1                SUBEXIT RC=16
         LA    15,16
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=   138 LV= 1 SUBEXIT
*MCALL #=   139 LV= 1          ENDSEL 
*MCALL #=   140 LV= 2          ZSTREQU 
*MEXIT #=   140 LV= 2 ZSTREQU
#@SEL_5_E                         DS 0H
*MEXIT #=   139 LV= 1 ENDSEL
         MVI    FLAG,0
*MCALL #=   141 LV= 1          SELECT 
*MCALL #=   142 LV= 2          ZSTREQU 
*MEXIT #=   142 LV= 2 ZSTREQU
*MEXIT #=   141 LV= 1 SELECT
*MCALL #=   143 LV= 1          WHEN  CLI,FLAG,EQ,1
*MCALL #=   144 LV= 2          ZSTREQU 
*MEXIT #=   144 LV= 2 ZSTREQU
         CLI         FLAG,1
         BC    15-EQ,#@SEL_6_1
*MEXIT #=   143 LV= 1 WHEN
*MCALL #=   145 LV= 1                WTO 'TESTSPM1 SELECT WHEN 1 ERROR'
         BRAS  1,*+(WTO#0145_EOT-*+1)/2*2
         DC    AL2(WTO#0145_EOT-*,0),C'TESTSPM1 SELECT WHEN 1 ERROR'
WTO#0145_EOT     EQU *
         SVC   35
*MEXIT #=   145 LV= 1 WTO
*MCALL #=   146 LV= 1                SUBEXIT RC=16
         LA    15,16
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=   146 LV= 1 SUBEXIT
*MCALL #=   147 LV= 1          OTHRWISE 
*MCALL #=   148 LV= 2          ZSTREQU 
*MEXIT #=   148 LV= 2 ZSTREQU
         B     #@SEL_6_E
#@SEL_6_1                                                 DS 0H
*MEXIT #=   147 LV= 1 OTHRWISE
               AP  PTEST,=P'1'
*MCALL #=   149 LV= 1          ENDSEL 
*MCALL #=   150 LV= 2          ZSTREQU 
*MEXIT #=   150 LV= 2 ZSTREQU
#@SEL_6_E                         DS 0H
*MEXIT #=   149 LV= 1 ENDSEL
         MVI    FLAG,3
*MCALL #=   151 LV= 1          SELECT 
*MCALL #=   152 LV= 2          ZSTREQU 
*MEXIT #=   152 LV= 2 ZSTREQU
*MEXIT #=   151 LV= 1 SELECT
*MCALL #=   153 LV= 1          WHEN  CLI,FLAG,EQ,3
*MCALL #=   154 LV= 2          ZSTREQU 
*MEXIT #=   154 LV= 2 ZSTREQU
         CLI         FLAG,3
         BC    15-EQ,#@SEL_7_1
*MEXIT #=   153 LV= 1 WHEN
               AP  PTEST,=P'1'
*MCALL #=   155 LV= 1          ENDSEL 
*MCALL #=   156 LV= 2          ZSTREQU 
*MEXIT #=   156 LV= 2 ZSTREQU
#@SEL_7_1                                                 DS 0H
*MEXIT #=   155 LV= 1 ENDSEL
         ZAP    DEC,=P'2'
*MCALL #=   157 LV= 1          SELECT 
*MCALL #=   158 LV= 2          ZSTREQU 
*MEXIT #=   158 LV= 2 ZSTREQU
*MEXIT #=   157 LV= 1 SELECT
*MCALL #=   159 LV= 1          WHEN  CP,DEC,EQ,=P'1'
*MCALL #=   160 LV= 2          ZSTREQU 
*MEXIT #=   160 LV= 2 ZSTREQU
         CP          DEC,=P'1'
         BC    15-EQ,#@SEL_8_1
*MEXIT #=   159 LV= 1 WHEN
*MCALL #=   161 LV= 1                WTO 'TESTSPM1 SELECT WHEN 1 ERROR'
         BRAS  1,*+(WTO#0161_EOT-*+1)/2*2
         DC    AL2(WTO#0161_EOT-*,0),C'TESTSPM1 SELECT WHEN 1 ERROR'
WTO#0161_EOT     EQU *
         SVC   35
*MEXIT #=   161 LV= 1 WTO
*MCALL #=   162 LV= 1                SUBEXIT RC=16
         LA    15,16
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=   162 LV= 1 SUBEXIT
*MCALL #=   163 LV= 1          WHEN  CP,DEC,EQ,=P'2'
*MCALL #=   164 LV= 2          ZSTREQU 
*MEXIT #=   164 LV= 2 ZSTREQU
         B     #@SEL_8_E
#@SEL_8_1                                                 DS 0H
         CP          DEC,=P'2'
         BC    15-EQ,#@SEL_8_2
*MEXIT #=   163 LV= 1 WHEN
               AP  PTEST,=P'1'
*MCALL #=   165 LV= 1          ENDSEL 
*MCALL #=   166 LV= 2          ZSTREQU 
*MEXIT #=   166 LV= 2 ZSTREQU
#@SEL_8_2                                                 DS 0H
#@SEL_8_E                         DS 0H
*MEXIT #=   165 LV= 1 ENDSEL
*
* TEST CASENTRY, CASE, ENDCASE
*
         LA    R3,0   FIRST INDEX
*MCALL #=   167 LV= 1          CASENTRY R3
*MCALL #=   168 LV= 2          ZSTREQU 
*MEXIT #=   168 LV= 2 ZSTREQU
#@CAS_1_L                         LOCTR 
#@CAS_1_T                         DS 0A START CASENTRY BRANCH TABLE
TESTSPM1 CSECT 
         B     #@CAS_1_G BRANCH TO CASE CODE
*MEXIT #=   167 LV= 1 CASENTRY
*MCALL #=   169 LV= 1          CASE  0
*MCALL #=   170 LV= 2          ZSTREQU 
*MEXIT #=   170 LV= 2 ZSTREQU
#@CAS_1_0                               DS 0H
#@CAS_1_L                         LOCTR 
         DC    A(#@CAS_1_0)
TESTSPM1 CSECT 
*MEXIT #=   169 LV= 1 CASE
               AP  PTEST,=P'1'
*MCALL #=   171 LV= 1          ENDCASE 
*MCALL #=   172 LV= 2          ZSTREQU 
*MEXIT #=   172 LV= 2 ZSTREQU
         B     #@CAS_1_E
#@CAS_1_A                         DC A(#@CAS_1_T)
#@CAS_1_G                         DS 0H
         CLFI  R3,0
         BH    #@CAS_1_E
         SLA   R3,2
         A     R3,#@CAS_1_A
         LT    R3,0(R3)
         BNZR  R3
#@CAS_1_E                         DS 0H
*MEXIT #=   171 LV= 1 ENDCASE
         LA    R3,4   LAST INDEX
*MCALL #=   173 LV= 1          CASENTRY R3
*MCALL #=   174 LV= 2          ZSTREQU 
*MEXIT #=   174 LV= 2 ZSTREQU
#@CAS_2_L                         LOCTR 
#@CAS_2_T                         DS 0A START CASENTRY BRANCH TABLE
TESTSPM1 CSECT 
         B     #@CAS_2_G BRANCH TO CASE CODE
*MEXIT #=   173 LV= 1 CASENTRY
*MCALL #=   175 LV= 1          CASE  4
*MCALL #=   176 LV= 2          ZSTREQU 
*MEXIT #=   176 LV= 2 ZSTREQU
#@CAS_2_4                               DS 0H
#@CAS_2_L                         LOCTR 
         DC    (4)A(0)
         DC    A(#@CAS_2_4)
TESTSPM1 CSECT 
*MEXIT #=   175 LV= 1 CASE
               AP  PTEST,=P'1'
*MCALL #=   177 LV= 1          ENDCASE 
*MCALL #=   178 LV= 2          ZSTREQU 
*MEXIT #=   178 LV= 2 ZSTREQU
         B     #@CAS_2_E
#@CAS_2_A                         DC A(#@CAS_2_T)
#@CAS_2_G                         DS 0H
         CLFI  R3,4
         BH    #@CAS_2_E
         SLA   R3,2
         A     R3,#@CAS_2_A
         LT    R3,0(R3)
         BNZR  R3
#@CAS_2_E                         DS 0H
*MEXIT #=   177 LV= 1 ENDCASE
         LA    R3,1    INDEX LOW
*MCALL #=   179 LV= 1          CASENTRY R3
*MCALL #=   180 LV= 2          ZSTREQU 
*MEXIT #=   180 LV= 2 ZSTREQU
#@CAS_3_L                         LOCTR 
#@CAS_3_T                         DS 0A START CASENTRY BRANCH TABLE
TESTSPM1 CSECT 
         B     #@CAS_3_G BRANCH TO CASE CODE
*MEXIT #=   179 LV= 1 CASENTRY
*MCALL #=   181 LV= 1          CASE  4
*MCALL #=   182 LV= 2          ZSTREQU 
*MEXIT #=   182 LV= 2 ZSTREQU
#@CAS_3_4                               DS 0H
#@CAS_3_L                         LOCTR 
         DC    (4)A(0)
         DC    A(#@CAS_3_4)
TESTSPM1 CSECT 
*MEXIT #=   181 LV= 1 CASE
*MCALL #=   183 LV= 1                WTO 'TESTSPM1 CASE 4 ERROR'
         BRAS  1,*+(WTO#0183_EOT-*+1)/2*2
         DC    AL2(WTO#0183_EOT-*,0),C'TESTSPM1 CASE 4 ERROR'
WTO#0183_EOT     EQU *
         SVC   35
*MEXIT #=   183 LV= 1 WTO
*MCALL #=   184 LV= 1                SUBEXIT RC=16
         LA    15,16
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=   184 LV= 1 SUBEXIT
*MCALL #=   185 LV= 1          ENDCASE 
*MCALL #=   186 LV= 2          ZSTREQU 
*MEXIT #=   186 LV= 2 ZSTREQU
         B     #@CAS_3_E
#@CAS_3_A                         DC A(#@CAS_3_T)
#@CAS_3_G                         DS 0H
         CLFI  R3,4
         BH    #@CAS_3_E
         SLA   R3,2
         A     R3,#@CAS_3_A
         LT    R3,0(R3)
         BNZR  R3
#@CAS_3_E                         DS 0H
*MEXIT #=   185 LV= 1 ENDCASE
         LA    R3,5   INDEX HIGH
*MCALL #=   187 LV= 1          CASENTRY R3
*MCALL #=   188 LV= 2          ZSTREQU 
*MEXIT #=   188 LV= 2 ZSTREQU
#@CAS_4_L                         LOCTR 
#@CAS_4_T                         DS 0A START CASENTRY BRANCH TABLE
TESTSPM1 CSECT 
         B     #@CAS_4_G BRANCH TO CASE CODE
*MEXIT #=   187 LV= 1 CASENTRY
*MCALL #=   189 LV= 1          CASE  4
*MCALL #=   190 LV= 2          ZSTREQU 
*MEXIT #=   190 LV= 2 ZSTREQU
#@CAS_4_4                               DS 0H
#@CAS_4_L                         LOCTR 
         DC    (4)A(0)
         DC    A(#@CAS_4_4)
TESTSPM1 CSECT 
*MEXIT #=   189 LV= 1 CASE
*MCALL #=   191 LV= 1                WTO 'TESTSPM1 CASE 4 ERROR'
         BRAS  1,*+(WTO#0191_EOT-*+1)/2*2
         DC    AL2(WTO#0191_EOT-*,0),C'TESTSPM1 CASE 4 ERROR'
WTO#0191_EOT     EQU *
         SVC   35
*MEXIT #=   191 LV= 1 WTO
*MCALL #=   192 LV= 1                SUBEXIT RC=16
         LA    15,16
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=   192 LV= 1 SUBEXIT
*MCALL #=   193 LV= 1          ENDCASE 
*MCALL #=   194 LV= 2          ZSTREQU 
*MEXIT #=   194 LV= 2 ZSTREQU
         B     #@CAS_4_E
#@CAS_4_A                         DC A(#@CAS_4_T)
#@CAS_4_G                         DS 0H
         CLFI  R3,4
         BH    #@CAS_4_E
         SLA   R3,2
         A     R3,#@CAS_4_A
         LT    R3,0(R3)
         BNZR  R3
#@CAS_4_E                         DS 0H
*MEXIT #=   193 LV= 1 ENDCASE
*
* DISPLAY AND VERIFY TOTAL TESTS
*
         ED    DTEST,PTEST
*MCALL #=   195 LV= 1          WTO   MF=(E,WTOMSG)
         LA    1,WTOMSG
         SVC   35
*MEXIT #=   195 LV= 1 WTO
*MCALL #=   196 LV= 1          IF    (CP,PTEST,EQ,=P'36')
*MCALL #=   197 LV= 2          ZSTREQU 
*MEXIT #=   197 LV= 2 ZSTREQU
         CP    PTEST,=P'36'
         BC    15-EQ,#@IF_11_2
*MEXIT #=   196 LV= 1 IF
*MCALL #=   198 LV= 1                WTO 'TESTSPM1 ENDED OK'
         BRAS  1,*+(WTO#0198_EOT-*+1)/2*2
         DC    AL2(WTO#0198_EOT-*,0),C'TESTSPM1 ENDED OK'
WTO#0198_EOT     EQU *
         SVC   35
*MEXIT #=   198 LV= 1 WTO
*MCALL #=   199 LV= 1                SUBEXIT RC=0
         LA    15,0
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=   199 LV= 1 SUBEXIT
*MCALL #=   200 LV= 1          ELSE 
*MCALL #=   201 LV= 2          ZSTREQU 
*MEXIT #=   201 LV= 2 ZSTREQU
        B      #@IF_11_E
#@IF_11_2                                                DS 0H
*MEXIT #=   200 LV= 1 ELSE
*MCALL #=   202 LV= 1                WTO 'TESTSPM1 ENDED WITH ERRORS'
         BRAS  1,*+(WTO#0202_EOT-*+1)/2*2
         DC    AL2(WTO#0202_EOT-*,0),C'TESTSPM1 ENDED WITH ERRORS'
WTO#0202_EOT     EQU *
         SVC   35
*MEXIT #=   202 LV= 1 WTO
*MCALL #=   203 LV= 1                SUBEXIT RC=16
         LA    15,16
         L     13,4(,13)
         L     14,12(,13)
         LM    2,12,28(13)
         BR    14
*MEXIT #=   203 LV= 1 SUBEXIT
*MCALL #=   204 LV= 1          ENDIF 
*MCALL #=   205 LV= 2          ZSTREQU 
*MEXIT #=   205 LV= 2 ZSTREQU
#@IF_11_E                        DS 0H
*MEXIT #=   204 LV= 1 ENDIF
PTEST    DC    PL3'0'
WTOMSG   DC    AL2(WTOEND-*,0),C'TESTSPM1 TOTAL TESTS ='
DTEST    DC    X'402020202020'
WTOEND   EQU   *
FLAG     DC    X'00'
DEC      DC    PL2'0'
*MCALL #=   206 LV= 1          EQUREGS 
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
*MEXIT #=   206 LV= 1 EQUREGS
         END 
