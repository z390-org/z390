@ECHO OFF
SETLOCAL

SET dirWork=test
SET dirRtWork=rt\%dirWork%
SET dirRtSaved=%dirRtWork%\save
SET dirRtDiffs=%dirRtWork%\diff
SET sysTerm=systerm^(%dirRtWork%\RTTEST^)

REM SET trace=TRON
REM SET trace=

SET numTestSteps=170

ECHO.
ECHO RT Test - Run %dirWork% programs in %dirRtWork% and generate diffs in %dirRtDiffs%

ECHO.
ECHO RT Test - Go one level up to our z390 main program directory (step 0 of %numTestSteps%)
PUSHD ..

goto testStep170

:testStep01
ECHO.
ECHO RT Test - Clearing all working files in target directory (%dirRtWork%) (step 1 of %numTestSteps%)
CALL .\rt\ClearDir.bat %dirRtWork%

:testStep02
ECHO.
ECHO RT Test - Check if linklib.src/REPRO.390 exists (step 2 of %numTestSteps%)
SET cleanReproWorkFiles=False
IF NOT EXIST linklib.src\REPRO.390 (
	ECHO.
	ECHO RT Test - REPRO.MLC    - VSAM utility to load or unload VSAM file from/to QSAM or another VSAM file (step 2 of %numTestSteps%)
	CALL ASML linklib.src\REPRO notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
	SET cleanReproWorkFiles=True
	IF EXIST linklib.src\REPRO.BAL  ERASE linklib.src\REPRO.BAL
	IF EXIST linklib.src\REPRO.ERR  ERASE linklib.src\REPRO.ERR
	IF EXIST linklib.src\REPRO.LST  ERASE linklib.src\REPRO.LST
	IF EXIST linklib.src\REPRO.OBJ  ERASE linklib.src\REPRO.OBJ
	IF EXIST linklib.src\REPRO.PRN  ERASE linklib.src\REPRO.PRN
	IF EXIST linklib.src\REPRO.STA  ERASE linklib.src\REPRO.STA
)

:testStep03
ECHO.
ECHO RT Test - Check if demo/DEMO.390 exists (step 3 of %numTestSteps%)
SET cleanDemoWorkFiles=False
IF NOT EXIST demo\DEMO.390 (
	ECHO.
	ECHO RT Test - DEMO.MLC     - WTO 'HELLO WORLD' 4 line macro program (step 3 of %numTestSteps%)
	CALL ASML demo\DEMO notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
	SET cleanDemoWorkFiles=True
)

ECHO.
ECHO RT Test - Dynamic linked subroutines used in testlnk1

:testStep04
ECHO.
ECHO RT Test - TESTSUB1.MLC - Subroutine with three CSECT WTO routes and ENTRY
ECHO RT Test - TESTSUB1.MLC - for use in static and dynamic tests (step 4 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTSUB1 @rt\Options.opt         %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep05
ECHO.
ECHO RT Test - TESTSUB4.MLC - Subroutine with one CSECT WTO for use in dynamic
ECHO RT Test - TESTSUB4.MLC - LINK and LOAD tests (step 5 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTSUB4 @rt\Options.opt amode24 %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

ECHO.
ECHO RT Test - Test the mz390 macro processor

:testStep06
ECHO.
ECHO RT Test - TESTSYS1.MLC - mz390 test of global and local system variables (step 6 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTSYS1 @rt\Options.opt sysparm(12345) %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep07
ECHO.
ECHO RT Test - TESTSYS2.MLC - BS2000 compatibility macro system variables (step 7 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTSYS2 @rt\Options.opt bs2000         %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep08
ECHO.
ECHO RT Test - TESTSYS3.MLC - Test RPI-1213 fixes for SYSECT, SYSLOC, SYSSTYP (step 8 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTSYS3 @rt\Options.opt                %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep09
ECHO.
ECHO RT Test - TESTSYN1.MLC - mz390 OPSYN redefine tests (step 9 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTSYN1 @rt\Options.opt                         %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep10
ECHO.
ECHO RT Test - TESTSYN2.MLC - mz390 OPSYN used before and after last restore (step 10 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTSYN2 @rt\Options.opt sysmac(mac+%dirRtWork%) %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep11
ECHO.
ECHO RT Test - TESTPRM1.MLC - positional and keyword parameters (step 11 of %numTestSteps%)
ECHO RT Test - TESTPRM1.MAC
CALL ASMLG %dirRtWork%\TESTPRM1 @rt\Options.opt sysmac(mac+%dirRtWork%) %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep12
ECHO.
ECHO RT Test - TESTPRM2.MLC - positional and keyword parameters (step 12 of %numTestSteps%)
ECHO RT Test - TESTPRM2.MAC
CALL ASMLG %dirRtWork%\TESTPRM2 @rt\Options.opt sysmac(mac+%dirRtWork%) %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep13
ECHO.
ECHO RT Test - TESTPRM3.MLC - Test mz390 sublists parameters, N' and K'
ECHO RT Test - TESTPRM3.MLC - operators (step 13 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTPRM3 @rt\Options.opt                         %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep14
ECHO.
ECHO RT Test - TESTMAC1.MLC - mz390 substring operations and DOUBLE (step 14 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTMAC1 @rt\Options.opt                                             %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep15
ECHO.
ECHO RT Test - TESTMAC2.MLC - mz390 conditional compares (step 15 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTMAC2 @rt\Options.opt tracep                                      %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep16
ECHO.
ECHO RT Test - TESTMAC3.MLC - mz390 redefine instruction using inline macro,
ECHO RT Test - TESTMAC3.MLC - redefine global as local, expand array, test
ECHO RT Test - TESTMAC3.MLC - tab vs space delimiter before comments (step 16 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTMAC3 @rt\Options.opt                                             %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep17
ECHO.
ECHO RT Test - TESTMAC4.MLC - mz390 test macro labels on MEND statements both
ECHO RT Test - TESTMAC4.MLC - upper and lower case (step 17 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTMAC4 @rt\Options.opt                                             %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep18
ECHO.
ECHO RT Test - TESTMAC5.MLC - mz390 test multiply in sub-string expression
ECHO RT Test - TESTMAC5.MLC - subscript and no concatenation . after substring
ECHO RT Test - TESTMAC5.MLC - (step 18 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTMAC5 @rt\Options.opt                                             %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep19
ECHO.
ECHO RT Test - TESTMAC6.MLC - mz390 test complex keyword parameter parsing such
ECHO RT Test - TESTMAC6.MLC - as OPTION=(A,B,C) (step 19 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTMAC6 @rt\Options.opt                                             %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep20
ECHO.
ECHO RT Test - TESTMAC7.MLC - mz370 test tab versus space before comments using
ECHO RT Test - TESTMAC7.MLC - notepad editor (step 20 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTMAC7 @rt\Options.opt                                             %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep21
ECHO.
ECHO RT Test - TESTMAC8.MLC - Test inline macros in open code and macro files with
ECHO RT Test - TESTMAC8.MLC - nested duplicate labels and labels on MEND (step 21 of %numTestSteps%)
ECHO RT Test - TESTMAC8.MLC - Uses TESTMAC8.MAC.
CALL ASMLG %dirRtWork%\TESTMAC8 @rt\Options.opt sysmac(%dirRtWork%+mac)                     %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep22
ECHO.
ECHO RT Test - TESTMAC9.MLC - mz390 COPY support for macro files (step 22 of %numTestSteps%)
ECHO RT Test - TESTMAC9.MLC - Uses TESTMAC9.MAC.
ECHO RT Test - TESTMAC9.MLC - Uses TESTMAC9.CPY.
CALL ASMLG %dirRtWork%\TESTMAC9 @rt\Options.opt sysmac(%dirRtWork%+mac) syscpy(%dirRtWork%) %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep23
ECHO.
ECHO RT Test - TESTPRO1.MLC - mz390 test PROFILE(TESTPRO1) copy file included
ECHO RT Test - TESTPRO1.MLC - preceding MLC source which executes macro
ECHO RT Test - TESTPRO1.MLC - TESTPROS.MAC and redefines END opcode to execute
ECHO RT Test - TESTPRO1.MLC - TESTPROT.MAC at termination (step 23 of %numTestSteps%)
ECHO RT Test - TESTPRO1.MLC - Uses TESTPRO1.OPT
ECHO RT Test - TESTPRO1.MLC - Uses TESTPROS.MAC
ECHO RT Test - TESTPRO1.MLC - Uses TESTPROT.MAC
ECHO RT Test - TESTPRO1.MLC - Uses TESTPRO1.CPY
CALL ASMLG %dirRtWork%\TESTPRO1 @rt\Options.opt @%dirRtWork%\TESTPRO1.OPT %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep24
ECHO.
ECHO RT Test - TESTOPR1.MLC - mz390 operators UPPER, LOWER (step 24 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTOPR1 @rt\Options.opt tracep                    %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep25
ECHO.
ECHO RT Test - TESTOPT1.MLC - Test nested @FILE options (step 25 of %numTestSteps%)
ECHO RT Test - TESTOPT1.MLC - Uses TESTOPT1.OPT
ECHO RT Test - TESTOPT1.MLC - Uses TESTOPTA.OPT
ECHO RT Test - TESTOPT1.MLC - Uses TESTOPTB.OPT
ECHO RT Test - TESTOPT1.MLC - Uses TESTOPTC.OPT
ECHO RT Test - TESTOPT1.MLC - Uses TESTOPTX.OPT
ECHO RT Test - TESTOPT1.MLC - Uses TESTOPTY.OPT
CALL ASMLG %dirRtWork%\TESTOPT1 @rt\Options.opt @%dirRtWork%\TESTOPT1.OPT %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep26
ECHO.
ECHO RT Test - TESTORG1.MLC - ORG test using multiple CSECT, RSET, LOCTR, and DSECT's (step 26 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTORG1 @rt\Options.opt trace %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep27
ECHO.
ECHO RT Test - TESTSET1.MLC - mz390 subscripted local and global set variables (step 27 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTSET1 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep28
ECHO.
ECHO RT Test - TESTSET2.MLC - mz390 create local set variables (step 28 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTSET2 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep29
ECHO.
ECHO RT Test - TESTSET3.MLC - mz390 created global set variables (step 29 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTSET3 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep30
ECHO.
ECHO RT Test - TESTACT1.MLC - macro ACTR limit (step 30 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTACT1 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep31
ECHO.
ECHO RT Test - TESTCPY1.MLC - Nested copy statement support (step 31 of %numTestSteps%)
ECHO RT Test - TESTCPY1.MLC - Uses TESTCP11.CPY
ECHO RT Test - TESTCPY1.MLC - Uses TESTCP12.CPY
ECHO RT Test - TESTCPY1.MLC - Uses TESTCP21.CPY
ECHO RT Test - TESTCPY1.MLC - Uses TESTCP22.CPY
CALL ASMLG %dirRtWork%\TESTCPY1 @rt\Options.opt bal syscpy(mac+%dirRtWork%) %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep32
ECHO.
ECHO RT Test - TESTCPY2.MLC - Comments after name on COPY statement (step 32 of %numTestSteps%)
ECHO RT Test - TESTCPY2.MLC - Uses TESTCP11.CPY
ECHO RT Test - TESTCPY2.MLC - Uses TESTCP12.CPY
ECHO RT Test - TESTCPY2.MLC - Uses TESTCP21.CPY
ECHO RT Test - TESTCPY2.MLC - Uses TESTCP22.CPY
CALL ASMLG %dirRtWork%\TESTCPY2 @rt\Options.opt bal syscpy(mac+%dirRtWork%) %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep33
ECHO.
ECHO RT Test - TESTSQL1.MLC - mz390 EXEC SQL INCLUDE test to copy specified file
ECHO RT Test - TESTSQL1.MLC - (step 33 of %numTestSteps%)
ECHO RT Test - TESTSQL1.MLC - Uses TESTSQL1.MAC
CALL ASMLG %dirRtWork%\TESTSQL1 @rt\Options.opt sysmac(%dirRtWork%+mac) syscpy(%dirRtWork%) %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep34
ECHO.
ECHO RT Test - TESTEQU1.MLC - Test EQUREGS TYPE=FPR and TYPE=HEX (step 34 of %numTestSteps%)
CALL MZ390 %dirRtWork%\TESTEQU1 noasm bal notiming sysmac(mac) syscpy(mac) stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep35
ECHO.
ECHO RT Test - TESTERR1.MLC - mz390 macro errors (step 35 of %numTestSteps%)
ECHO RT Test - TESTERR1.MLC - Uses TESTERR1.CPY
CALL MZ390 %dirRtWork%\TESTERR1 noasm bal notiming sysmac(mac) syscpy(mac) stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep36
ECHO.
ECHO RT Test - TESTERR3.MLC - mz390 DCB macro errors (step 36 of %numTestSteps%)
CALL MZ390 %dirRtWork%\TESTERR3 noasm bal notiming sysmac(mac) syscpy(mac) stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep37
ECHO.
ECHO RT Test - TESTERR8.MLC - Add compound AIF and computed AGO missing label (step 37 of %numTestSteps%)
CALL MZ390 %dirRtWork%\TESTERR8 noasm bal notiming sysmac(mac) syscpy(mac) stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep38
ECHO.
ECHO RT Test - TESTERR9.MLC - Add compound AIF and computed AGO missing label (step 38 of %numTestSteps%)
CALL MZ390 %dirRtWork%\TESTERR9 noasm bal notiming sysmac(mac) syscpy(mac) stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep39
ECHO.
ECHO RT Test - TESTPCH1.MLC - Inline AREAD and PUNCH using default PCH file (step 39 of %numTestSteps%)
ECHO RT Test - TESTPCH1.MLC - Uses TESTPCH1.TF1
ECHO RT Test - TESTPCH1.MLC - Uses TESTPCH1.TF2
ECHO RT Test - TESTPCH1.MLC - Uses TESTPCH1.TF3
SETLOCAL
SET SYSUT1=%dirRtWork%\TESTPCH1.TF1
SET SYSUT2=%dirRtWork%\TESTPCH1.TF2
SET SYSOUT=%dirRtWork%\TESTPCH1.TF3
CALL ASMLG %dirRtWork%\TESTPCH1 bal notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
ENDLOCAL

:testStep40
ECHO.
ECHO RT Test - TESTPCH2.MLC - AREAD and PUNCH with explicit input and output file extensions (step 40 of %numTestSteps%)
ECHO RT Test - TESTPCH2.MLC - Uses TESTPCH2.TF1
ECHO RT Test - TESTPCH2.MLC - Uses TESTPCH2.TF2
ECHO RT Test - TESTPCH2.MLC - Creates TESTPCH2.TF3
SETLOCAL
SET SYSUT1=%dirRtWork%\TESTPCH2.TF1
SET SYSUT2=%dirRtWork%\TESTPCH2.TF2
SET SYSOUT=%dirRtWork%\TESTPCH2.TF3
CALL ASMLG %dirRtWork%\TESTPCH2 bal notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
ENDLOCAL

:testStep41
ECHO.
ECHO RT Test - TESTPCH3.MLC - Copy two AREAD text files and also merge the two
ECHO RT Test - TESTPCH3.MLC - into third text file (step 41 of %numTestSteps%)
ECHO RT Test - TESTPCH3.MLC - Uses TESTPCH3.IN1
ECHO RT Test - TESTPCH3.MLC - Uses TESTPCH3.IN2
ECHO RT Test - TESTPCH3.MLC - Creates TESTPCH3.OT1
ECHO RT Test - TESTPCH3.MLC - Creates TESTPCH3.OT2
ECHO RT Test - TESTPCH3.MLC - Creates TESTPCH3.OT3
ECHO RT Test - TESTPCH3.MLC - Uses TESTPCH3.TF1
ECHO RT Test - TESTPCH3.MLC - Uses TESTPCH3.TF2
ECHO RT Test - TESTPCH3.MLC - Creates TESTPCH3.TF3
SETLOCAL
SET IN1=%dirRtWork%\TESTPCH3.IN1
SET IN2=%dirRtWork%\TESTPCH3.IN2
SET OT1=%dirRtWork%\TESTPCH3.OT1
SET OT2=%dirRtWork%\TESTPCH3.OT2
SET OT3=%dirRtWork%\TESTPCH3.OT3
IF EXIST %OT1% ERASE %OT1%
IF EXIST %OT2% ERASE %OT2%
IF EXIST %OT3% ERASE %OT3%
SET SYSUT1=%dirRtWork%\TESTPCH3.TF1
SET SYSUT2=%dirRtWork%\TESTPCH3.TF2
SET SYSOUT=%dirRtWork%\TESTPCH3.TF3
CALL ASMLG %dirRtWork%\TESTPCH3 bal notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
ENDLOCAL

ECHO.
ECHO RT Test - Test the mz390 macro processor

:testStep42
ECHO.
ECHO RT Test - TESTMCR1.ASM - mz390 test user specified file type for main program
ECHO RT Test - TESTMCR1.ASM - (ASM) and macros (MCR) (step 42 of %numTestSteps%)
ECHO RT Test - TESTMCR1.MLC - Uses mac/SUBENTRY.MAC
ECHO RT Test - TESTMCR1.MLC - Uses mac/SUBEXIT.MAC
ECHO RT Test - TESTMCR1.MLC - Uses mac/WTO.MAC
IF NOT EXIST %dirRtWork%\SUBENTRY.MCR  COPY  mac\SUBENTRY.MAC %dirRtWork%\SUBENTRY.MCR
IF NOT EXIST %dirRtWork%\SUBEXIT.MCR   COPY  mac\SUBEXIT.MAC  %dirRtWork%\SUBEXIT.MCR
IF NOT EXIST %dirRtWork%\WTO.MCR       COPY  mac\WTO.MAC      %dirRtWork%\WTO.MCR
@REM Note: *.ASM necessary, otherwise MAC searches for *.MLC
CALL MAC %dirRtWork%\TESTMCR1.ASM @%dirRtWork%\TESTMCR1.OPT sysmac(%dirRtWork%\*.MCR) %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
@REM IF EXIST %dirRtWork%\SUBENTRY.MCR  ERASE %dirRtWork%\SUBENTRY.MCR
@REM IF EXIST %dirRtWork%\SUBEXIT.MCR   ERASE %dirRtWork%\SUBEXIT.MCR
@REM IF EXIST %dirRtWork%\WTO.MCR       ERASE %dirRtWork%\WTO.MCR

:testStep43
ECHO.
ECHO RT Test - TESTTXT1.MLC - Macro processor multiple text file processing option
ECHO RT Test - TESTTXT1.MLC - to generate HTML text files (step 43 of %numTestSteps%)
ECHO RT Test - TESTTXT1.MLC - Creates TESTTXT1A.HTML
ECHO RT Test - TESTTXT1.MLC - Creates TESTTXT1B.HTML
CALL MZ390 %dirRtWork%\TESTTXT1 noasm bal notiming sysmac(mac) syscpy(mac) stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep44
ECHO.
ECHO RT Test - TESTPC1.MLC - Macro pseudo code ok if undefined AIF branch not taken (step 44 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTPC1  @rt\Options.opt tracep               %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep45
ECHO.
ECHO RT Test - TESTAIN1.MLC - Test for AINSERT for AREAD/SOURCE (step 45 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTAIN1 @rt\Options.opt                      %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep46
ECHO.
ECHO RT Test - TESTAIN2.MLC - Test AINSERT copy front and back (step 46 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTAIN2 @rt\Options.opt syscpy(+%dirRtWork%) %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep47
ECHO.
ECHO RT Test - TESTAIN3.MLC - Test AINSERT complex macro and copy sequence (step 47 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTAIN3 @rt\Options.opt syscpy(+%dirRtWork%) %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep48
ECHO.
ECHO RT Test - TESTCDE1.MLC - List CDE's to test user interface (step 48 of %numTestSteps%)
ECHO RT Test - TESTCDE1.MLC - Uses linklib.src/REPRO.390 at runtime!
IF NOT EXIST linklib.src\REPRO.390 (
	ECHO RT Test - TESTCDE1.MLC - Missing compiled file linklib.src\REPRO.390.
	ECHO RT Test - TESTCDE1.MLC - Test will fail.
	PAUSE
)
CALL ASMLG %dirRtWork%\TESTCDE1 @rt\Options.opt syscpy(+%dirRtWork%) sys390(+linklib.src) %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

ECHO.
ECHO RT Test - Test the az390 assembler

:testStep49
ECHO.
ECHO RT Test - TESTINS1.MLC - Verify assembly of all instruction formats (1085) including z9, z10, and ASSIST (step 49 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTINS1 @rt\Options.opt assist %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep50
ECHO.
ECHO RT Test - TESTASC5.BAL - ASCII mode, verify assembly of all instruction
ECHO RT Test - TESTASC5.BAL -             formats (1085) including z9, z10,
ECHO RT Test - TESTASC5.BAL -             and ASSIST (step 50 of %numTestSteps%)
IF EXIST %dirRtWork%\TESTASC5.BAL  ERASE                      %dirRtWork%\TESTASC5.BAL
IF EXIST %dirRtWork%\TESTASC5.PRN  ERASE                      %dirRtWork%\TESTASC5.PRN
IF EXIST %dirRtWork%\TESTASC5.OBJ  ERASE                      %dirRtWork%\TESTASC5.OBJ
IF EXIST %dirRtWork%\TESTASC5.ERR  ERASE                      %dirRtWork%\TESTASC5.ERR
IF EXIST %dirRtWork%\TESTASC5.STA  ERASE                      %dirRtWork%\TESTASC5.STA
IF EXIST %dirRtWork%\TESTASC5.TR*  ERASE                      %dirRtWork%\TESTASC5.TR*
IF EXIST %dirRtWork%\TESTINS1.BAL  COPY  %dirRtWork%\TESTINS1.BAL %dirRtWork%\TESTASC5.BAL
CALL AZ390 %dirRtWork%\TESTASC5 assist notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep51
ECHO.
ECHO RT Test - TESTDST1.MLC - CSECT and DSECT support (step 51 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTDST1 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep52
ECHO.
ECHO RT Test - TESTLCT1.MLC - LOCTR sections (step 52 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTLCT1 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep53
ECHO.
ECHO RT Test - TESTSYM1.MLC - mz390 symbol T' and L' operator tests (step 53 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTSYM1 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep54
ECHO.
ECHO RT Test - TESTUSE1.MLC - USING and labeled USING (step 54 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTUSE1 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep55
ECHO.
ECHO RT Test - TESTUSE2.MLC - PUSH and POP USING (step 55 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTUSE2 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep56
ECHO.
ECHO RT Test - TESTPRT1.MLC - PRINT ON/OFF, GEN/NOGEN, DATA/NODATA and PUSH/POP PRINT (step 56 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTPRT1 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep57
ECHO.
ECHO RT Test - TESTDC1.MLC  - DC constants (step 57 of %numTestSteps%)
ECHO RT Test - TESTDC1.MLC  - Uses TESTUSE1.OBJ from test far above!
CALL ASMLG %dirRtWork%\TESTDC1 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep58
ECHO.
ECHO RT Test - TESTASC1.MLC - ASCII mode, DC constants (step 58 of %numTestSteps%)
ECHO RT Test - TESTASC1.MLC - Uses TESTUSE1.OBJ from test far above!
ECHO RT Test - TESTASC1.MLC - Uses file linklib/CVTTOHEX.OBJ
IF EXIST %dirRtWork%\TESTASC1.MLC  ERASE                        %dirRtWork%\TESTASC1.MLC
IF EXIST %dirRtWork%\TESTDC1.MLC   COPY %dirRtWork%\TESTDC1.MLC %dirRtWork%\TESTASC1.MLC
IF NOT EXIST .\linklib\CVTTOHEX.OBJ (
	ECHO RT Test - TESTASC1.MLC - Missing compiled file .\linklib\CVTTOHEX.OBJ.
	ECHO RT Test - TESTASC1.MLC - Test will fail.
	PAUSE
)
CALL ASMLG %dirRtWork%\TESTASC1 @rt\Options.opt ascii %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep59
ECHO.
ECHO RT Test - TESTDC2.MLC  - DC bit length constants (step 59 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTDC2  @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep60
ECHO.
ECHO RT Test - TESTLOC1.MLC - az390 multiple LOCTR's for CSECT and DSECT (step 60 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTLOC1 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep61
ECHO.
ECHO RT Test - TESTSDT1.MLC - Self defining terms B, C, and X (step 61 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTSDT1 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep62
ECHO.
ECHO RT Test - TESTASC2.MLC - ASCII mode, Self defining terms B, C, and X (step 62 of %numTestSteps%)
IF EXIST %dirRtWork%\TESTASC2.MLC  ERASE                         %dirRtWork%\TESTASC2.MLC
IF EXIST %dirRtWork%\TESTSDT1.MLC  COPY %dirRtWork%\TESTSDT1.MLC %dirRtWork%\TESTASC2.MLC
CALL ASMLG %dirRtWork%\TESTASC2 @rt\Options.opt ascii %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep63
ECHO.
ECHO RT Test - TESTASM1.MLC - az390 tests - CNOP, L' operator,  symbol tests, START,
ECHO RT Test - TESTASM1.MLC - COM, and RSECT test, CVTDCB flags test (step 63 of %numTestSteps%)
ECHO RT Test - TESTASM1.MLC - Uses TESTASM1.MAC
CALL ASMLG %dirRtWork%\TESTASM1 @rt\Options.opt mcall sysmac(%dirRtWork%+.\mac) %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep64
ECHO.
ECHO RT Test - TESTASM2.MLC - az390 test tab delimiter versus space before
ECHO RT Test - TESTASM2.MLC -  comments using notepad editor (step 64 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTASM2 @rt\Options.opt                                 %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep65
ECHO.
ECHO RT Test - TESTENV1.MLC - GETENV macro to get environment string value (step 65 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTENV1 @rt\Options.opt TRACE %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep66
ECHO.
ECHO RT Test - TESTERR2.MLC - az390 assembly errors (step 66 of %numTestSteps%)
IF EXIST %dirRtWork%\TESTERR2.BAL ERASE %dirRtWork%\TESTERR2.BAL
IF EXIST %dirRtWork%\TESTERR2.PRN ERASE %dirRtWork%\TESTERR2.PRN
IF EXIST %dirRtWork%\TESTERR2.OBJ ERASE %dirRtWork%\TESTERR2.OBJ
IF EXIST %dirRtWork%\TESTERR2.ERR ERASE %dirRtWork%\TESTERR2.ERR
IF EXIST %dirRtWork%\TESTERR2.STA ERASE %dirRtWork%\TESTERR2.STA
IF EXIST %dirRtWork%\TESTERR2.TR? ERASE %dirRtWork%\TESTERR2.TR?
CALL MZ390 %dirRtWork%\TESTERR2 bal notiming sysmac(mac) syscpy(mac) stats err(0) %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep67
ECHO.
ECHO RT Test - TESTERRA.MLC - Test non-ASCII character string error (step 67 of %numTestSteps%)
IF EXIST %dirRtWork%\TESTERRA.BAL ERASE %dirRtWork%\TESTERRA.BAL
IF EXIST %dirRtWork%\TESTERRA.PRN ERASE %dirRtWork%\TESTERRA.PRN
IF EXIST %dirRtWork%\TESTERRA.OBJ ERASE %dirRtWork%\TESTERRA.OBJ
IF EXIST %dirRtWork%\TESTERRA.ERR ERASE %dirRtWork%\TESTERRA.ERR
IF EXIST %dirRtWork%\TESTERRA.STA ERASE %dirRtWork%\TESTERRA.STA
IF EXIST %dirRtWork%\TESTERRA.TR? ERASE %dirRtWork%\TESTERRA.TR?
CALL MZ390 %dirRtWork%\TESTERRA bal notiming sysmac(mac) syscpy(mac) stats chkmac(2) %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep68
ECHO.
ECHO RT Test - TESTLAB1.MLC - Generated statement label and operator field errors for HLASM compatibility (step 68 of %numTestSteps%)
IF EXIST %dirRtWork%\TESTLAB1.BAL ERASE %dirRtWork%\TESTLAB1.BAL
IF EXIST %dirRtWork%\TESTLAB1.PRN ERASE %dirRtWork%\TESTLAB1.PRN
IF EXIST %dirRtWork%\TESTLAB1.OBJ ERASE %dirRtWork%\TESTLAB1.OBJ
IF EXIST %dirRtWork%\TESTLAB1.ERR ERASE %dirRtWork%\TESTLAB1.ERR
IF EXIST %dirRtWork%\TESTLAB1.STA ERASE %dirRtWork%\TESTLAB1.STA
IF EXIST %dirRtWork%\TESTLAB1.TR? ERASE %dirRtWork%\TESTLAB1.TR?
CALL MZ390 %dirRtWork%\TESTLAB1 bal notiming sysmac(mac) syscpy(mac) stats err(0) %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

ECHO.
ECHO RT Test - Test the lz390 linker

:testStep69
ECHO.
ECHO RT Test - TESTRLD1.MLC - Relocation constants (step 69 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTRLD1 @rt\Options.opt                  %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep70
ECHO.
ECHO RT Test - TESTRLD2.MLC - Relocation constants (step 70 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTRLD2 @rt\Options.opt NOLOADHIGH TRACE %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep71
ECHO.
ECHO RT Test - TESTENT1.MLC - Symbol defined as both ENTRY and CSECT (step 71 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTENT1 @rt\Options.opt                  %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep72
ECHO.
ECHO RT Test - TESTEXT1.MLC - EXTRN static link (step 72 of %numTestSteps%)
ECHO RT Test - TESTEXT1.MLC - Uses TESTSUB1.OBJ from test far above!
CALL ASMLG %dirRtWork%\TESTEXT1 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep73
ECHO.
ECHO RT Test - TESTEXT2.MLC - VCON and ENTRY static link (step 73 of %numTestSteps%)
ECHO RT Test - TESTEXT2.MLC - Uses TESTSUB1.OBJ from test far above!
CALL ASMLG %dirRtWork%\TESTEXT2 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep74
ECHO.
ECHO RT Test - TESTWXT1.MLC - Test weak external references WXTRN with no RLD
ECHO RT Test - TESTWXT1.MLC - and no error if not included (step 74 of %numTestSteps%)
ECHO RT Test - TESTWXT1.MLC - Uses TESTSUB1.OBJ from test far above!
CALL ASMLG %dirRtWork%\TESTWXT1 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep75
ECHO.
ECHO RT Test - TESTOBJ1.MLC - All OBJ record types ESD (SD, ER, WX, LD), TXT, RLD, and END (step 75 of %numTestSteps%)
ECHO RT Test - TESTOBJ1.MLC - Uses TESTSUB1.OBJ from test far above!
CALL ASMLG %dirRtWork%\TESTOBJ1 @rt\Options.opt objhex %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9


:testStep76
ECHO.
ECHO RT Test - TESTOBJ2.MLC - 32 MB single CSECT using OBJHEX option (OBJ binary
ECHO RT Test - TESTOBJ2.MLC - limited to 24 bit length) (step 76 of %numTestSteps%)
ECHO RT Test - TESTOBJ2.MLC - Uses TESTSUB1.OBJ from test far above!
CALL ASMLG %dirRtWork%\TESTOBJ2 @rt\Options.opt @TESTOBJ2.OPT %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
ECHO RT Test - TESTOBJ2.390 - Removing 32 MB file to save space and avoid comparison
IF EXIST %dirRtWork%\TESTOBJ2.390 ERASE %dirRtWork%\TESTOBJ2.390

:testStep77
ECHO.
ECHO RT Test - TESTPRM4.MLC - mz390 test double quotes around SYSPARM with commas
ECHO RT Test - TESTPRM4.MLC - SYSPARM('A,B') (step 77 of %numTestSteps%)
ECHO RT Test - TESTPRM4.MLC - Uses TESTPRM4.OPT
CALL ASMLG %dirRtWork%\TESTPRM4 @rt\Options.opt @TESTPRM4.OPT %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

ECHO.
ECHO RT Test - Test the ez390 emulator

:testStep78
ECHO.
ECHO RT Test - TESTERR4.MLC - ez390 invalid DCB DSNAME causing S013 abend (step 78 of %numTestSteps%)
CALL ASML  %dirRtWork%\TESTERR4 bal notiming   %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL EZ390 %dirRtWork%\TESTERR4 notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep79
ECHO.
ECHO RT Test - TESTERR5.MLC - ez390 invalid DCB DSNAME with SYNAD exit (step 79 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTERR5 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep80
ECHO.
ECHO RT Test - TESTERR6.MLC - ez390 invalid DCB error (step 80 of %numTestSteps%)
CALL ASML  %dirRtWork%\TESTERR6 bal notiming   %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL EZ390 %dirRtWork%\TESTERR6 notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep81
ECHO.
ECHO RT Test - TESTERR7.MLC - ez390 missing DDNAME and no SYNAD (step 81 of %numTestSteps%)
CALL ASML  %dirRtWork%\TESTERR7 bal notiming   %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL EZ390 %dirRtWork%\TESTERR7 notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep82
ECHO.
ECHO RT Test - TESTINS2.MLC - Verify problem state instruction execution (400+)
ECHO RT Test - TESTINS2.MLC - including z9 opcodes (step 82 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTINS2 @rt\Options.opt trace %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep83
ECHO.
ECHO RT Test - TESTASC3.MLC - ASCII mode execution of TESTINS2.MLC z390
ECHO RT Test - TESTASC3.MLC - instruction execution tests (step 83 of %numTestSteps%)
IF EXIST %dirRtWork%\TESTASC3.MLC  ERASE                         %dirRtWork%\TESTASC3.MLC
IF EXIST %dirRtWork%\TESTINS2.MLC  COPY %dirRtWork%\TESTINS2.MLC %dirRtWork%\TESTASC3.MLC
CALL ASMLG %dirRtWork%\TESTASC3 @rt\Options.opt ascii trace %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep84
ECHO.
ECHO RT Test - TESTINS3.MLC - Verify problem stat instruction execution (226) for
ECHO RT Test - TESTINS3.MLC - new z10 opcodes (step 84 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTINS3 @rt\Options.opt trace %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep85
ECHO.
ECHO RT Test - TESTINS4.MLC - Verify problem stat instruction execution (226) for
ECHO RT Test - TESTINS4.MLC - z196 instructions (step 85 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTINS4 @rt\Options.opt trace %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep86
ECHO.
ECHO RT Test - TESTFP1.MLC  - Floating point BFP and HFP instructions (step 86 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTFP1  @rt\Options.opt trace %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep87
ECHO.
ECHO RT Test - TESTFP2.MLC  - Test PFPO conversion between any two FP types (step 87 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTFP2  @rt\Options.opt trace %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep88
ECHO.
ECHO RT Test - TESTDFP1.MLC - Test Decimal Floating Point (DFP) support (step 88 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTDFP1 @rt\Options.opt trace %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep89
ECHO.
ECHO RT Test - TESTDFP2.MLC - Test DFP (Decimal Floating Point) constants (step 89 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTDFP2 @rt\Options.opt trace %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep90
ECHO.
ECHO RT Test - TESTCAL1.MLC - Test local static linked CALL (step 90 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTCAL1 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep91
ECHO.
ECHO RT Test - TESTCAL2.MLC - Test static linked CALL with EXTRN and ENTRY (step 91 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTCAL2 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9


:testStep92
ECHO.
ECHO RT Test - TESTLNK1.MLC - LINK, LOAD, and DELETE macro and svcs (step 92 of %numTestSteps%)
SET DDTODEMO=demo\DEMO.390
ECHO RT Test - TESTLNK1.MLC - Uses %DDTODEMO% from test far above!
ECHO RT Test - TESTLNK1.MLC - Uses %dirRtWork%\TESTSUB1.390 from test far above!
ECHO RT Test - TESTLNK1.MLC - Uses %dirRtWork%\TESTSUB4.390 from test far above!
IF NOT EXIST %DDTODEMO% (
	ECHO RT Test - TESTLNK1.MLC - Missing compiled file %DDTODEMO%.
	ECHO RT Test - TESTLNK1.MLC - Test will fail.
	PAUSE
)
IF NOT EXIST %dirRtWork%\TESTSUB1.390 (
	ECHO RT Test - TESTLNK1.MLC - Missing compiled file %dirRtWork%\TESTSUB1.390.
	ECHO RT Test - TESTLNK1.MLC - Test will fail.
	PAUSE
)
IF NOT EXIST %dirRtWork%\TESTSUB4.390 (
	ECHO RT Test - TESTLNK1.MLC - Missing compiled file %dirRtWork%\TESTSUB4.390.
	ECHO RT Test - TESTLNK1.MLC - Test will fail.
	PAUSE
)
CALL ASMLG %dirRtWork%\TESTLNK1 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9


:testStep93
ECHO.
ECHO RT Test - TESTLNK2.MLC - Test use of TESTLNK2.LNK to build TESTLNK2 (step 93 of %numTestSteps%)
ECHO RT Test - TESTLNK3.MLC - CSECT and ENTRY point for TESTLNK2.390     (step 93 of %numTestSteps%)
ECHO RT Test - TESTLNK1.MLC - Uses %dirRtWork%\TESTLNK2.LKD!
CALL ASM   %dirRtWork%\TESTLNK2 notiming stats  %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL ASM   %dirRtWork%\TESTLNK3 notiming stats  %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
SET  MYLIB=%dirRtWork%
CALL LINK  %dirRtWork%\TESTLNK2  notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL EXEC  %dirRtWork%\TESTLNK3  notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
SET  MYLIB=

:testStep94
ECHO.
ECHO RT Test - TESTLNK4.MLC - Test ENTRY at TEST3 via END TEST3 (step 94 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTLNK4 @rt\Options.opt notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep95
ECHO.
ECHO RT Test - TESTLNK5.MLC - Test ENTRY TEST2 via TESTLNK5.LKD ENTRY TEST2 (step 95 of %numTestSteps%)
SET  MYLIB=%dirRtWork%
CALL ASMLG %dirRtWork%\TESTLNK5 @rt\Options.opt notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
SET  MYLIB=

:testStep96
ECHO.
ECHO RT Test - TESTLOD1.MLC - Test LOAD DDNAME and DSNAME options (step 96 of %numTestSteps%)
ECHO RT Test - TESTLOD1.MLC - Uses demo\DEMO.390            from test far above!
ECHO RT Test - TESTLOD1.MLC - Uses %dirRtWork%\TESTSUB1.390 from test far above!
REM Note: Uses following files demo\DEMO.390 and %dirRtWork%\TESTSUB1.390 from tests far above!
IF NOT EXIST demo\DEMO.390 (
	ECHO RT Test - TESTLOD1.MLC - Missing compiled file demo\DEMO.390.
	ECHO RT Test - TESTLOD1.MLC - Test will fail.
	PAUSE
)
IF NOT EXIST %dirRtWork%\TESTSUB1.390 (
	ECHO RT Test - TESTLOD1.MLC - Missing compiled file %dirRtWork%\TESTSUB1.390.
	ECHO RT Test - TESTLOD1.MLC - Test will fail.
	PAUSE
)
CALL ASMLG %dirRtWork%\TESTLOD1 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
@REM See  SET DDTODEMO=demo\DEMO.390  in step 92
SET DDTODEMO=

:testStep97
ECHO.
ECHO RT Test - TESTLOD2.LOD - Test LOAD DDNAME and DSNAME options (step 97 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTLOD2 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9


:testStep98
ECHO.
ECHO RT Test - TESTXCL4.MLC - XCTL subroutine which snaps CDE and exits (step 98 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTXCL4 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep99
ECHO.
ECHO RT Test - TESTXCL3.MLC - XCTL subroutine which snaps CDE entries and
ECHO RT Test - TESTXCL3.MLC - issues XCTL to TESTXCL4 (step 99 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTXCL3 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep100
ECHO.
ECHO RT Test - TESTXCL2.MLC - XCTL subroutine which snaps CDE entries and
ECHO RT Test - TESTXCL2.MLC - issues XCTL to TESTXCL3 (step 100 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTXCL2 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep101
ECHO.
ECHO RT Test - TESTXCL1.MLC - XCTL main program links to TESTXCL2 then XCTL
ECHO RT Test - TESTXCL1.MLC - to TEXTXCL3 (step 101 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTXCL1 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9


:testStep102
ECHO.
ECHO RT Test - TESTDCB1.MLC - Copy RECFM=FT ASCII file to RECFM=FT ASCII
ECHO RT Test - TESTDCB1.MLC - file (step 102 of %numTestSteps%)
SETLOCAL
SET SYSUT1=%dirRtWork%\TESTDCB1.TF1
ECHO RT Test - TESTDCB1.MLC - Uses existing file %SYSUT1%!
SET SYSUT2=%dirRtWork%\TESTDCB1.TF2
ECHO RT Test - TESTDCB1.MLC - Creates new file   %SYSUT2%.
SET SYSOUT=%dirRtWork%\TESTDCB1.TF3
ECHO RT Test - TESTDCB1.MLC - Creates new file   %SYSOUT%.
IF EXIST %SYSUT2%  ERASE %SYSUT2%
IF EXIST %SYSOUT%  ERASE %SYSOUT%
CALL ASMLG %dirRtWork%\TESTDCB1 bal notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
ENDLOCAL

:testStep103
ECHO.
ECHO RT Test - TESTDCB2.MLC - Copy RECFM=FT ASCII file to RECFM=F EBCDIC
ECHO RT Test - TESTDCB2.MLC - file (step 103 of %numTestSteps%)
SETLOCAL
SET SYSUT1=%dirRtWork%\TESTDCB2.TF1
ECHO RT Test - TESTDCB2.MLC - Uses existing file %SYSUT1%.
SET SYSUT2=%dirRtWork%\TESTDCB2.TF2
ECHO RT Test - TESTDCB2.MLC - Creates new file   %SYSUT2%.
SET SYSOUT=%dirRtWork%\TESTDCB2.TF3
ECHO RT Test - TESTDCB2.MLC - Creates new file   %SYSOUT%.
IF EXIST %SYSUT2%  ERASE %SYSUT2%
IF EXIST %SYSOUT%  ERASE %SYSOUT%
CALL ASMLG %dirRtWork%\TESTDCB2 bal notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
ENDLOCAL

:testStep104
ECHO.
ECHO RT Test - TESTDCB3.MLC - Copy RECFM=FB EBCDIC file to RECFM=FB EBCDIC
ECHO RT Test - TESTDCB3.MLC - file (step 104 of %numTestSteps%)
SETLOCAL
SET SYSUT1=%dirRtWork%\TESTDCB3.TF1
ECHO RT Test - TESTDCB3.MLC - Uses existing file %SYSUT1%.
SET SYSUT2=%dirRtWork%\TESTDCB3.TF2
ECHO RT Test - TESTDCB3.MLC - Creates new file   %SYSUT2%.
SET SYSOUT=%dirRtWork%\TESTDCB3.TF3
ECHO RT Test - TESTDCB3.MLC - Creates new file   %SYSOUT%.
IF EXIST %SYSUT2%  ERASE %SYSUT2%
IF EXIST %SYSOUT%  ERASE %SYSOUT%
CALL ASMLG %dirRtWork%\TESTDCB3 bal notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
ENDLOCAL

:testStep105
ECHO.
ECHO RT Test - TESTDCB4.MLC - Copy RECFM=VT ASCII file to RECFM=VT ASCII
ECHO RT Test - TESTDCB4.MLC - file (step 105 of %numTestSteps%)
SETLOCAL
SET SYSUT1=%dirRtWork%\TESTDCB4.TF1
ECHO RT Test - TESTDCB4.MLC - Uses existing file %SYSUT1%.
SET SYSUT2=%dirRtWork%\TESTDCB4.TF2
ECHO RT Test - TESTDCB4.MLC - Creates new file   %SYSUT2%.
SET SYSOUT=%dirRtWork%\TESTDCB4.TF3
ECHO RT Test - TESTDCB4.MLC - Creates new file   %SYSOUT%.
IF EXIST %SYSUT2%  ERASE %SYSUT2%
IF EXIST %SYSOUT%  ERASE %SYSOUT%
CALL ASMLG %dirRtWork%\TESTDCB4 bal notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
ENDLOCAL

:testStep106
ECHO.
ECHO RT Test - TESTDCB5.MLC - Copy RECFM=VT ASCII file to RECFM=V EBCDIC
ECHO RT Test - TESTDCB5.MLC - file (step 106 of %numTestSteps%)
SETLOCAL
SET SYSUT1=%dirRtWork%\TESTDCB5.TF1
ECHO RT Test - TESTDCB5.MLC - Uses existing file %SYSUT1%.
SET SYSUT2=%dirRtWork%\TESTDCB5.TF2
ECHO RT Test - TESTDCB5.MLC - Creates new file   %SYSUT2%.
SET SYSOUT=%dirRtWork%\TESTDCB5.TF3
ECHO RT Test - TESTDCB5.MLC - Creates new file   %SYSOUT%.
IF EXIST %SYSUT2%  ERASE %SYSUT2%
IF EXIST %SYSOUT%  ERASE %SYSOUT%
CALL ASMLG %dirRtWork%\TESTDCB5 bal notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
ENDLOCAL

:testStep107
ECHO.
ECHO RT Test - TESTDCB6.MLC - Copy RECFM=VT ASCII file to RECFM=VB EBCDIC
ECHO RT Test - TESTDCB6.MLC - file (step 107 of %numTestSteps%)
SETLOCAL
SET SYSUT1=%dirRtWork%\TESTDCB6.TF1
ECHO RT Test - TESTDCB6.MLC - Uses existing file %SYSUT1%.
SET SYSUT2=%dirRtWork%\TESTDCB6.TF2
ECHO RT Test - TESTDCB6.MLC - Creates new file   %SYSUT2%.
SET SYSOUT=%dirRtWork%\TESTDCB6.TF3
ECHO RT Test - TESTDCB6.MLC - Creates new file   %SYSOUT%.
IF EXIST %SYSUT2%  ERASE %SYSUT2%
IF EXIST %SYSOUT%  ERASE %SYSOUT%
CALL ASMLG %dirRtWork%\TESTDCB6 bal notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
ENDLOCAL

:testStep108
ECHO.
ECHO RT Test - TESTDCB7.MLC - Copy RECFM= VB EBCDIC file to RECFM=FT ASCII
ECHO RT Test - TESTDCB7.MLC - file (step 108 of %numTestSteps%)
SETLOCAL
SET SYSUT1=%dirRtWork%\TESTDCB7.TF1
ECHO RT Test - TESTDCB7.MLC - Uses existing file %SYSUT1%.
SET SYSUT2=%dirRtWork%\TESTDCB7.TF2
ECHO RT Test - TESTDCB7.MLC - Creates new file   %SYSUT2%.
SET SYSOUT=%dirRtWork%\TESTDCB7.TF3
ECHO RT Test - TESTDCB7.MLC - Creates new file   %SYSOUT%.
IF EXIST %SYSUT2%  ERASE %SYSUT2%
IF EXIST %SYSOUT%  ERASE %SYSOUT%
CALL ASMLG %dirRtWork%\TESTDCB7 bal notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
ENDLOCAL

:testStep109
ECHO.
ECHO RT Test - TESTDCB8.MLC - Copy RECFM=F using sequential READ and WRITE (step 109 of %numTestSteps%)
SETLOCAL
SET SYSUT1=%dirRtWork%\TESTDCB8.TF1
ECHO RT Test - TESTDCB8.MLC - Uses existing file %SYSUT1%.
SET SYSUT2=%dirRtWork%\TESTDCB8.TF2
ECHO RT Test - TESTDCB8.MLC - Creates new file   %SYSUT2%.
SET SYSOUT=%dirRtWork%\TESTDCB8.TF3
ECHO RT Test - TESTDCB8.MLC - Creates new file   %SYSOUT%.
IF EXIST %SYSUT2%  ERASE %SYSUT2%
IF EXIST %SYSOUT%  ERASE %SYSOUT%
CALL ASMLG %dirRtWork%\TESTDCB8 bal notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
ENDLOCAL

:testStep110
ECHO.
ECHO RT Test - TESTDCB9.MLC - Copy RECFM=F file in reverse order using random
ECHO RT Test - TESTDCB9.MLC - READ and WRITE (step 110 of %numTestSteps%)
SETLOCAL
SET SYSUT1=%dirRtWork%\TESTDCB9.TF1
ECHO RT Test - TESTDCB9.MLC - Uses existing file %SYSUT1%.
SET SYSUT2=%dirRtWork%\TESTDCB9.TF2
ECHO RT Test - TESTDCB9.MLC - Creates new file   %SYSUT2%.
SET SYSOUT=%dirRtWork%\TESTDCB9.TF3
ECHO RT Test - TESTDCB9.MLC - Creates new file   %SYSOUT%.
IF EXIST %SYSUT2%  ERASE %SYSUT2%
IF EXIST %SYSOUT%  ERASE %SYSOUT%
CALL ASMLG %dirRtWork%\TESTDCB9 bal notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
ENDLOCAL

:testStep111
ECHO.
ECHO RT Test - TESTDCBA.MLC - Copy RECFM=FT file in ASCII mode with DCB RECORD=
ECHO RT Test - TESTDCBA.MLC - and DSNAME= and new file (step 111 of %numTestSteps%)
ECHO RT Test - TESTDCBA.MLC - Uses existing file %dirRtWork%\TESTDCBA.TF1.
IF EXIST %dirRtWork%\TESTDCBA.TF2  ERASE %dirRtWork%\TESTDCBA.TF2
ECHO RT Test - TESTDCBA.MLC - Creates new file   %dirRtWork%\TESTDCBA.TF2.
IF EXIST %dirRtWork%\TESTDCBA.TF3  ERASE %dirRtWork%\TESTDCBA.TF3
ECHO RT Test - TESTDCBA.MLC - Creates new file   %dirRtWork%\TESTDCBA.TF3.
CALL ASMLG %dirRtWork%\TESTDCBA @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep112
ECHO.
ECHO RT Test - TESTDCBB.MLC - Copy RECFM=F EBCDIC file to RECFM=F EBCDIC file
ECHO RT Test - TESTDCBB.MLC - using DCB RECORD= and READ, WRITE, CHECK (step 112 of %numTestSteps%)
SETLOCAL
SET SYSUT1=%dirRtWork%\TESTDCBB.TF1
ECHO RT Test - TESTDCBB.MLC - Uses existing file %SYSUT1%.
SET SYSUT2=%dirRtWork%\TESTDCBB.TF2
ECHO RT Test - TESTDCBB.MLC - Creates new file   %SYSUT2%.
SET SYSOUT=%dirRtWork%\TESTDCBB.TF3
ECHO RT Test - TESTDCBB.MLC - Creates new file   %SYSOUT%.
IF EXIST %SYSUT2%  ERASE %SYSUT2%
IF EXIST %SYSOUT%  ERASE %SYSOUT%
CALL ASMLG %dirRtWork%\TESTDCBB bal notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
ENDLOCAL

:testStep113
ECHO.
ECHO RT Test - TESTDCBC.MLC - Copy RECFM=FT ASCII file to RECFM=FT ASCII file
ECHO RT Test - TESTDCBC.MLC - in ASCII mode with DCB RECORD= and DSNAME=
ECHO RT Test - TESTDCBC.MLC - and new file (step 113 of %numTestSteps%)
SETLOCAL
SET SYSUT1=%dirRtWork%\TESTDCBC.TF1
ECHO RT Test - TESTDCBC.MLC - Uses existing file %SYSUT1%.
SET SYSUT2=%dirRtWork%\TESTDCBC.TF2
ECHO RT Test - TESTDCBC.MLC - Creates new file   %SYSUT2%.
SET SYSOUT=%dirRtWork%\TESTDCBC.TF3
ECHO RT Test - TESTDCBC.MLC - Creates new file   %SYSOUT%.
IF EXIST %SYSUT2%  ERASE %SYSUT2%
IF EXIST %SYSOUT%  ERASE %SYSOUT%
CALL ASMLG %dirRtWork%\TESTDCBC bal notiming stats ascii %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
ENDLOCAL

:testStep114
ECHO.
ECHO RT Test - TESTDCBD.MLC - Copy RECFM=FT to RECFM=VT (step 114 of %numTestSteps%)
SETLOCAL
SET SYSUT1=%dirRtWork%\TESTDCBD.TF1
ECHO RT Test - TESTDCBD.MLC - Uses existing file %SYSUT1%.
SET SYSUT2=%dirRtWork%\TESTDCBD.TF2
ECHO RT Test - TESTDCBD.MLC - Creates new file   %SYSUT2%.
SET SYSOUT=%dirRtWork%\TESTDCBD.TF3
ECHO RT Test - TESTDCBD.MLC - Creates new file   %SYSOUT%.
IF EXIST %SYSUT2%  ERASE %SYSUT2%
IF EXIST %SYSOUT%  ERASE %SYSOUT%
CALL ASMLG %dirRtWork%\TESTDCBD bal notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
ENDLOCAL

:testStep115
ECHO.
ECHO RT Test - TESTDCBE.MLC - Test for RECFM=FT and VT create and read (step 115 of %numTestSteps%)
SETLOCAL
REM SET SYSUT1=%dirRtWork%\TESTDCBE.TF1
REM ECHO RT Test - TESTDCBE.MLC - Uses existing file %SYSUT1%.
SET SYSUT2=%dirRtWork%\TESTDCBE.TF2
ECHO RT Test - TESTDCBE.MLC - Creates new file   %SYSUT2%.
SET SYSOUT=%dirRtWork%\TESTDCBE.TF3
ECHO RT Test - TESTDCBE.MLC - Creates new file   %SYSOUT%.
IF EXIST %SYSUT2%  ERASE %SYSUT2%
IF EXIST %SYSOUT%  ERASE %SYSOUT%
CALL ASMLG %dirRtWork%\TESTDCBE bal notiming stats ascii %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
ENDLOCAL

:testStep116
ECHO.
ECHO RT Test - TESTDCBF.MLC - Copy SYSUT1 FB file to SYSUT2 FB using GL/PL (step 116 of %numTestSteps%)
SETLOCAL
SET SYSUT1=%dirRtWork%\TESTDCBF.TF1
ECHO RT Test - TESTDCBF.MLC - Uses existing file %SYSUT1%.
SET SYSUT2=%dirRtWork%\TESTDCBF.TF2
ECHO RT Test - TESTDCBF.MLC - Creates new file   %SYSUT2%.
SET SYSOUT=%dirRtWork%\TESTDCBF.TF3
ECHO RT Test - TESTDCBF.MLC - Creates new file   %SYSOUT%.
IF EXIST %SYSUT2%  ERASE %SYSUT2%
IF EXIST %SYSOUT%  ERASE %SYSOUT%
CALL ASMLG %dirRtWork%\TESTDCBF bal notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
ENDLOCAL

:testStep117
ECHO.
ECHO RT Test - TESTEOF1.MLC - End of ASCII file with X'1A' end of file code (step 117 of %numTestSteps%)
SETLOCAL
SET SYSUT1=%dirRtWork%\TESTEOF1.TF1
ECHO RT Test - TESTEOF1.MLC - Uses existing file %SYSUT1%.
SET SYSUT2=%dirRtWork%\TESTEOF1.TF2
ECHO RT Test - TESTEOF1.MLC - Creates new file   %SYSUT2%.
SET SYSOUT=%dirRtWork%\TESTEOF1.TF3
ECHO RT Test - TESTEOF1.MLC - Creates new file   %SYSOUT%.
IF EXIST %SYSUT2%  ERASE %SYSUT2%
IF EXIST %SYSOUT%  ERASE %SYSOUT%
CALL ASMLG %dirRtWork%\TESTEOF1 bal notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
ENDLOCAL


:testStep118
ECHO.
ECHO RT Test - TESTTIM1.MLC - TIME macro svc 11 with numerious date and time formats (step 118 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTTIM1 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep119
ECHO.
ECHO RT Test - TESTTIM2.MLC - STIMER WAIT test to verify approximately 3 seconds elapsed wait (step 119 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTTIM2 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9


:testStep120
ECHO.
ECHO RT Test - TESTECB1.MLC - WAIT ECBLIST= test multiple ECB wait (step 120 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTECB1 @rt\Options.opt trace %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9


:testStep121
ECHO.
ECHO RT Test - TESTMEM1.MLC - GETMAIN and FREEMAIN (step 121 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTMEM1 @rt\Options.opt mem(32) %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep122
ECHO.
ECHO RT Test - TESTMEM2.MLC - GETMAIN extensions for LV=nnnK and LV=nnnM (step 122 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTMEM2 @rt\Options.opt mem(2)  %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep123
ECHO.
ECHO RT Test - TESTMEM3.MLC - STORAGE macro OBTAIN and RELEASE test (step 123 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTMEM3 @rt\Options.opt mem(32) %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep124
ECHO.
ECHO RT Test - TESTMEM4.MLC - GETMAIN and FREEMAIN test previously causing
ECHO RT Test - TESTMEM4.MLC - corruption on merge (step 124 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTMEM4 @rt\Options.opt mem(2)  %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9


:testStep125
ECHO.
ECHO RT Test - TESTTST1.MLC - Batch execution test of the interactive test
ECHO RT Test - TESTTST1.MLC - sub-commands (step 125 of %numTestSteps%)
SETLOCAL
SET SYSUT1=%dirRtWork%\TESTTST1.TF1
ECHO RT Test - TESTTST1.MLC - Uses existing file %SYSUT1%.
SET SYSUT2=%dirRtWork%\TESTTST1.TF2
ECHO RT Test - TESTTST1.MLC - Uses existing file %SYSUT2%.
SET SYSOUT=%dirRtWork%\TESTTST1.TF3
ECHO RT Test - TESTTST1.MLC - Uses existing file %SYSOUT%.
CALL ASMLG %dirRtWork%\TESTTST1 bal notiming stats test(SYSUT1) %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
ENDLOCAL

:testStep126
ECHO.
ECHO RT Test - TESTASC4.MLC - ASCII mode run TEST memory changes in batch mode
ECHO RT Test - TESTASC4.MLC - and verify (step 126 of %numTestSteps%)
SETLOCAL
IF EXIST %dirRtWork%\TESTASC4.MLC  ERASE %dirRtWork%\TESTASC4.MLC
IF EXIST %dirRtWork%\TESTASC4.TF1  ERASE %dirRtWork%\TESTASC4.TF1
COPY %dirRtWork%\TESTTST1.MLC %dirRtWork%\TESTASC4.MLC
COPY %dirRtWork%\TESTTST1.TF1 %dirRtWork%\TESTASC4.TF1
SET SYSUT1=%dirRtWork%\TESTASC4.TF1
ECHO RT Test - TESTASC4.MLC - Uses existing file %SYSUT1%.
@REM SYSUT2=%dirRtWork%\TESTASC4.TF2
@REM SYSOUT=%dirRtWork%\TESTASC4.TF3
CALL ASMLG %dirRtWork%\TESTASC4 bal notiming stats test(SYSUT1) ascii %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
ENDLOCAL

:testStep127
ECHO.
ECHO RT Test - TESTCMD1.MLC - Single Windows command process (step 127 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTCMD1 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep128
ECHO.
ECHO RT Test - TESTCMD2.MLC - Two Windows command processes reading separate
ECHO RT Test - TESTCMD2.MLC - linked list output queues in sequence (step 128 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTCMD2 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9


:testStep129
ECHO.
ECHO RT Test - TESTCIC1.MLC - Test of DFTRESP CICS error code literal substitution (step 129 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTCIC1 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep130
ECHO.
ECHO RT Test - TESTCIC2.MLC - Test assembly only of EXEC CICS SEND/RECEIVE with quoted literals (step 130 of %numTestSteps%)
CALL ASM   %dirRtWork%\TESTCIC2 cics notiming  sysmac(cics+mac) syscpy(cics+mac) stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9


:testStep131
ECHO.
ECHO RT Test - TESTDMP1.MLC - S0C1 abend with default indicative dump (step 1xx of %numTestSteps%)
CALL ASML  %dirRtWork%\TESTDMP1 bal notiming   %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
:testStep132
ECHO.
ECHO RT Test - TESTDMP1.390 - S0C1 abend with default indicative dump (step 131 of %numTestSteps%)
CALL EZ390 %dirRtWork%\TESTDMP1 notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep133
ECHO.
ECHO RT Test - TESTDMP2.MLC - S0C1 abend with DUMP option for full dump (step 133 of %numTestSteps%)
CALL ASML  %dirRtWork%\TESTDMP2 bal notiming   dump %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
:testStep134
ECHO.
ECHO RT Test - TESTDMP2.390 - S0C1 abend with DUMP option for full dump (step 134 of %numTestSteps%)
CALL EZ390 %dirRtWork%\TESTDMP2 notiming stats dump %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep135
ECHO.
ECHO RT Test - TESTDMP3.MLC - User requested ABEND 111 with DUMP requested (step 135 of %numTestSteps%)
CALL ASML  %dirRtWork%\TESTDMP3 bal notiming   %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
:testStep136
ECHO.
ECHO RT Test - TESTDMP3.390 - User requested ABEND 111 with DUMP requested (step 136 of %numTestSteps%)
CALL EZ390 %dirRtWork%\TESTDMP3 notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep137
ECHO.
ECHO RT Test - TESTDMP4.MLC - SNAP dump with open file information, program
ECHO RT Test - TESTDMP4.MLC - information, and memory area dump (step 137 of %numTestSteps%)
IF NOT EXIST %dirRtWork%\TESTDMP4.TF1 (
	ECHO RT Test - TESTDMP4.MLC - Missing helper file %dirRtWork%\TESTDMP4.TF1.
	ECHO RT Test - TESTDMP4.MLC - Test will fail.
	PAUSE
)
CALL ASML  %dirRtWork%\TESTDMP4 bal notiming   %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
:testStep138
ECHO.
ECHO RT Test - TESTDMP4.390 - SNAP dump with open file information, program
ECHO RT Test - TESTDMP4.390 - information, and memory area dump (step 138 of %numTestSteps%)
CALL EZ390 %dirRtWork%\TESTDMP4 notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9


:testStep139
ECHO.
ECHO RT Test - TESTDMP5.MLC - Test abend dump with forced 0C1 abend (step 139 of %numTestSteps%)
CALL ASML  %dirRtWork%\TESTDMP5 bal notiming   dump ascii %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
:testStep140
ECHO.
ECHO RT Test - TESTDMP5.390 - Test abend dump with forced 0C1 abend (step 140 of %numTestSteps%)
CALL EZ390 %dirRtWork%\TESTDMP5 notiming stats dump ascii %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9


:testStep141
ECHO.
ECHO RT Test - TESTXLT1.MLC - XLATE EBCDIC and ASCII translation macro (step 141 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTXLT1 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep142
ECHO.
ECHO RT Test - TESTBLD1.MLC - Test BLDL search for 390 load modules in
ECHO RT Test - TESTBLD1.MLC - CDE memory and SYS390 dirs (step 142 of %numTestSteps%)
IF NOT EXIST demo\DEMO.390 (
	ECHO RT Test - TESTBLD1.MLC - Missing helper file demo\DEMO.390.
	ECHO RT Test - TESTBLD1.MLC - Test will fail.
	PAUSE
)
IF NOT EXIST %dirRtWork%\TESTSUB1.390 (
	ECHO RT Test - TESTBLD1.MLC - Missing helper file %dirRtWork%\TESTSUB1.390.
	ECHO RT Test - TESTBLD1.MLC - Test will fail.
	PAUSE
)
CALL ASMLG %dirRtWork%\TESTBLD1 @rt\Options.opt sys390(%dirRtWork%+demo) %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9


:testStep143
ECHO.
ECHO RT Test - TESTSVC1.MLC - Test user defined SVC handler facilty to redefine
ECHO RT Test - TESTSVC1.MLC - svc 201 as WTO svc 35 (step 143 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTSVC1 @rt\Options.opt trace noprotect %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9


:testStep144
ECHO.
ECHO RT Test - TESTIPL1.MLC - ez390 IPL program to initialize CVTDATE for use
ECHO RT Test - TESTIPL1.MLC - by TESTIPL2 (step 144 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTIPL1 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
IF NOT EXIST %dirRtWork%\TESTIPL1.390 (
	ECHO RT Test - TESTIPL1.MLC - Missing helper file %dirRtWork%\TESTIPL1.390.
	ECHO RT Test - TESTIPL1.MLC - Test TESTIPL2 will fail.
	PAUSE
)
:testStep145
ECHO.
ECHO RT Test - TESTIPL2.MLC - ez390 test option IPL(TESTIPL1) which executes
ECHO RT Test - TESTIPL2.MLC - TESTIPL1 before TESTIPL2 which then fetches
ECHO RT Test - TESTIPL2.MLC - CVTDATE and displays its current value which is
ECHO RT Test - TESTIPL2.MLC - 0 if TESTIPL1 is not run first to initialize it. (step 145 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTIPL2 @rt\Options.opt ipl(TESTIPL1) sys390(%dirRtWork%) %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep146
ECHO.
ECHO RT Test - TESTZCV1.MLC - Use ZCVT to access and display current PGM and
ECHO RT Test - TESTZCV1.MLC - IPL fields (step 146 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTZCV1 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9


:testStep147
ECHO.
ECHO RT Test - TESTSPI1.MLC - Test ESPIE (step 147 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTSPI1 @rt\Options.opt trace %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9


:testStep148
ECHO.
ECHO RT Test - TESTSTA1.MLC - ESTAE restart (step 148 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTSTA1 @rt\Options.opt trace %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep149
ECHO.
ECHO RT Test - TESTSTA3.MLC - ESTAE restart and percolate lower level (step 149 of %numTestSteps%)
CALL ASML  %dirRtWork%\TESTSTA3 notiming stats        %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep150
ECHO.
ECHO RT Test - TESTSTA2.MLC - ESTAE restart and percolate higher level (step 150 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTSTA2 @rt\Options.opt trace %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9


:testStep150
ECHO.
ECHO RT Test - TESTCTD1.MLC - CTD convert to decimal conversion macro (step 150 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTCTD1 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep151
ECHO.
ECHO RT Test - TESTCFD1.MLC - CTD convert from decimal conversion macro (step 151 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTCFD1 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9


:testStep152
ECHO.
ECHO RT Test - TESTCVB1.MLC - CVB 32 bit convert to binary (step 152 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTCVB1 @rt\Options.opt trace %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:testStep153
ECHO.
ECHO RT Test - TESTCVBG.MLC - CVBG 64 bit convert to binary (step 153 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTCVBG @rt\Options.opt trace %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9


:testStep154
ECHO.
ECHO RT Test - TESTSPE1.ZSM - Test structured programming extensions (step 154 of %numTestSteps%)
SETLOCAL
ECHO RT Test
ECHO RT Test - Test zstrmac basic structures using bootstrap version 1
ECHO RT Test - mz390 zstrmac1.mlc in:testspe1.zsm  out:testspe1.mlc
ECHO RT Test
SET sysut1=%dirRtWork%\TESTSPE1.ZSM
SET sysut2=%dirRtWork%\TESTSPE1.MLC
IF EXIST %sysut2%  ERASE %sysut2%
CALL MZ390 %dirRtWork%\ZSTRMAC1 noasm stats notiming %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
IF ErrorLevel 1 (
	ECHO RT Test - TESTSPE1.ZSM - ZSTRMAC1 ended with Error Level 1.
	ECHO RT Test - TESTSPE1.ZSM - Test will fail.
	PAUSE
)
IF NOT EXIST %sysut2% (
	ECHO RT Test - TESTSPE1.ZSM - Missing generated file %sysut2%.
	ECHO RT Test - TESTSPE1.ZSM - Test will fail.
	PAUSE
)
:testStep155
ECHO.
ECHO RT Test - TESTSPE1.MLC - Test structured programming extensions (step 155 of %numTestSteps%)
CALL ASMLG %sysut2% @rt\Options.opt stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
ENDLOCAL


:testStep156
ECHO.
ECHO RT Test - TESTSPE2.ZSM - Test structured programming extensions (step 156 of %numTestSteps%)
ECHO RT Test -              - Translate structured version 2 using bootstrap version 1
ECHO RT Test -              - mz390 zstrmac1.mlc in:testspe2.zsm  out:testspe2.mlc
SETLOCAL
SET sysut1=%dirRtWork%\TESTSPE2.ZSM
SET sysut2=%dirRtWork%\TESTSPE2.MLC
IF EXIST %sysut2%  ERASE %sysut2%
CALL MZ390 %dirRtWork%\ZSTRMAC1 noasm stats notiming %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
IF ErrorLevel 1 (
	ECHO RT Test - TESTSPE2.ZSM - ZSTRMAC1 ended with Error Level 1.
	ECHO RT Test - TESTSPE2.ZSM - Test will fail.
	PAUSE
)
IF NOT EXIST %sysut2% (
	ECHO RT Test - TESTSPE2.ZSM - Missing generated file %sysut2%.
	ECHO RT Test - TESTSPE2.ZSM - Test will fail.
	PAUSE
)
:testStep157
ECHO.
ECHO RT Test - TESTSPE2.MLC - Test structured programming extensions (step 157 of %numTestSteps%)
CALL ASMLG %sysut2% @rt\Options.opt stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
ENDLOCAL


:testStep158
ECHO.
ECHO RT Test - ZSTRMAC1.MLC - Translate structured version 2 using bootstrap version 1
ECHO RT Test - ZSTRMAC1.MLC - mz390 zstrmac1.mlc in:zstrmac2.zsm  out:zstrmac2.mlc
ECHO RT Test - ZSTRMAC1.MLC - (bootstrap) (step 158 of %numTestSteps%)
SETLOCAL
SET sysut1=%dirRtWork%\ZSTRMAC2.ZSM
SET sysut2=%dirRtWork%\ZSTRMAC2.MLC
IF EXIST %sysut2%  ERASE %sysut2%
CALL MZ390 %dirRtWork%\ZSTRMAC1 noasm stats notiming %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
IF ErrorLevel 1 (
	ECHO RT Test - ZSTRMAC1.MLC - ZSTRMAC1 ended with Error Level 1.
	ECHO RT Test - ZSTRMAC1.MLC - Test will fail.
	PAUSE
)
IF NOT EXIST %sysut2% (
	ECHO RT Test - ZSTRMAC1.MLC - Missing generated file %sysut2%.
	ECHO RT Test - ZSTRMAC1.MLC - Test failed!
	PAUSE
)
ENDLOCAL

:testStep159
ECHO.
ECHO RT Test - ZSTRMAC2.MLC - Verify TESTZSM1.ZSM translation using zstrmac2 matches zstrmac1
ECHO RT Test   ZSTRMAC2.MLC - mz390 zstrmac2.mlc in:testspe1.zsm  out:testspe1.txt (step 159 of %numTestSteps%)
SET sysut1=%dirRtWork%\TESTSPE1.ZSM
SET sysut2=%dirRtWork%\TESTSPE1.TXT
IF EXIST %sysut2%  ERASE %sysut2%
CALL MZ390 %dirRtWork%\ZSTRMAC2 noasm stats notiming %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
IF ErrorLevel 1 (
	ECHO RT Test - ZSTRMAC2.MLC - ZSTRMAC2 ended with Error Level 1.
	ECHO RT Test - ZSTRMAC2.MLC - Test will fail.
	PAUSE
)
IF NOT EXIST %sysut2% (
	ECHO RT Test - ZSTRMAC2.MLC - Missing generated file %sysut2%.
	ECHO RT Test - ZSTRMAC2.MLC - Test failed!
	PAUSE
)
ENDLOCAL


:testStep160
ECHO.
ECHO RT Test - ZSTRMAC2.ZSM - Re-generate ZSTRMAC2 using mz390 support to ver zstrmac2.txt = mlc
ECHO RT Test - ZSTRMAC2.ZSM - mz390 zstrmac2.zsm in:zstrmac2.zsm  out:zstrmac2.txt
ECHO RT Test - ZSTRMAC2.ZSM - (regen) (step 160 of %numTestSteps%)
SETLOCAL
SET sysut1=%dirRtWork%\ZSTRMAC2.ZSM
SET sysut2=%dirRtWork%\ZSTRMAC2.TXT
IF EXIST %sysut2%  ERASE %sysut2%
CALL MZ390 %sysut1% noasm stats notiming %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
IF ErrorLevel 1 (
	ECHO RT Test - ZSTRMAC2.ZSM - ZSTRMAC2 ended with Error Level 1.
	ECHO RT Test - ZSTRMAC2.ZSM - Test will fail.
	PAUSE
)
IF NOT EXIST %sysut2% (
	ECHO RT Test - ZSTRMAC2.ZSM - Missing generated file %sysut2%.
	ECHO RT Test - ZSTRMAC2.ZSM - Test failed!
	PAUSE
)
ENDLOCAL


:testStep161
ECHO.
ECHO RT Test - TESTSPE3.ZSM - Test extensions to ACASE added in zstrmac2 C,X,(v1,v2)
ECHO RT Test - TESTSPE3.ZSM - mz390 zstrmac2.zsm in:testspe3.zsm  out:testspe3.mlc (step 161 of %numTestSteps%)
SETLOCAL
SET sysut1=%dirRtWork%\TESTSPE3.ZSM
SET sysut2=%dirRtWork%\TESTSPE3.MLC
CALL MZ390 %dirRtWork%\ZSTRMAC2.ZSM noasm stats notiming %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
IF ErrorLevel 1 (
	ECHO RT Test - TESTSPE3.ZSM - ZSTRMAC2 ended with Error Level 1.
	ECHO RT Test - TESTSPE3.ZSM - Test will fail.
	PAUSE
)
IF NOT EXIST %sysut2% (
	ECHO RT Test - TESTSPE3.ZSM - Missing generated file %sysut2%.
	ECHO RT Test - TESTSPE3.ZSM - Test failed!
	PAUSE
)
:testStep162
ECHO.
ECHO RT Test - TESTSPE3.MLC - Test Structured Programming Extensions (step 162 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTSPE3 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
ENDLOCAL


:testStep163
ECHO.
ECHO RT Test - TESTSPE4.ZSM - Test zstrmac error messages (step 163 of %numTestSteps%)
ECHO RT Test - TESTSPE4.ZSM - mz390 zstrmac2.zsm in:testspe4.zsm  out:testspe4.mlc
SETLOCAL
SET sysut1=%dirRtWork%\TESTSPE4.ZSM
SET sysut2=%dirRtWork%\TESTSPE4.MLC
CALL MZ390 %dirRtWork%\ZSTRMAC2.ZSM noasm stats notiming %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
IF ErrorLevel 9 (
	ECHO RT Test - TESTSPE4.ZSM - ZSTRMAC2 ended with Error Level 1.
	ECHO RT Test - TESTSPE4.ZSM - Test will fail.
	PAUSE
)
ENDLOCAL


:testStep164
ECHO.
ECHO RT Test - TESTSPM1.ZSM - Test ZSTRMAC Structured Assembler Macros (step 164 of %numTestSteps%)
CALL ASMLG %dirRtWork%\TESTSPM1 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9


:testStep165
ECHO.
ECHO RT Test - Creating directories %dirRtSaved% and %dirRtDiffs% (if necessary) (step 165 of %numTestSteps%).
IF NOT EXIST %dirRtWork%\nul   @MKDIR %dirRtWork%
IF NOT EXIST %dirRtDiffs%\nul  @MKDIR %dirRtDiffs%
IF NOT EXIST %dirRtSaved%\nul  @MKDIR %dirRtSaved%

:testStep166
ECHO.
ECHO RT Test - Cleaning rt diff directory %dirRtDiffs% (step 166 of %numTestSteps%)
ERASE /Q %dirRtDiffs%\*.*

:testStep167
ECHO.
ECHO RT Test - Cleaning demo\DEMO.* work files (step 167 of %numTestSteps%)
IF "%cleanDemoWorkFiles%" == "True" (
	IF EXIST demo\DEMO.BAL  ERASE demo\DEMO.BAL
	IF EXIST demo\DEMO.ERR  ERASE demo\DEMO.ERR
	IF EXIST demo\DEMO.LST  ERASE demo\DEMO.LST
	IF EXIST demo\DEMO.OBJ  ERASE demo\DEMO.OBJ
	IF EXIST demo\DEMO.PRN  ERASE demo\DEMO.PRN
	IF EXIST demo\DEMO.STA  ERASE demo\DEMO.STA
	IF EXIST demo\DEMO.390  ERASE demo\DEMO.390
)
SET cleanDemoWorkFiles=

:testStep168
ECHO.
ECHO RT Test - Erasing linklib.src\REPRO.390 (step 168 of %numTestSteps%)
IF "%cleanReproWorkFiles%" == "True" (
	IF EXIST linklib.src\REPRO.390  ERASE linklib.src\REPRO.390
)
SET cleanReproWorkFiles=

:doCompare
:testStep169
ECHO.
ECHO RT Test - Compare %dirRtWork% test files with %dirRtSaved% save files
ECHO RT Test - and generate %dirRtDiffs% diff files (step 169 of %numTestSteps%)
ECHO.
@java -classpath z390.jar -Xrs %J2SEOPTIONS% DiffRegrTests %dirRtWork% %dirRtSaved% %dirRtDiffs%

:doListing
:testStep170
ECHO.
ECHO RT Test - Display size ordered list of %dirRtDiffs% (step 170 of %numTestSteps%)
@DIR /OS /P %dirRtDiffs%

ECHO.
ECHO RT Test - Finished!
ECHO.

:ende
@POPD
ENDLOCAL
