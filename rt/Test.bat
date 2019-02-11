@ECHO OFF
SETLOCAL

SET dirWork=test
SET dirRtWork=rt\%dirWork%
SET dirRtSaved=%dirRtWork%\save
SET dirRtDiffs=%dirRtWork%\diff
SET sysTerm=systerm^(%dirRtWork%\RTTEST^)
REM SET trace=TRON
REM SET trace=

ECHO.
ECHO RT Test - Run %dirWork% programs in %dirRtWork% and generate %dirRtDiffs%

ECHO.
ECHO RT Test - Go one level up to our z390 main program directory
PUSHD ..

ECHO.
ECHO RT Test - Clearing all working files in target directory (%dirRtWork%)
CALL .\rt\ClearDir.bat %dirRtWork%

SET cleanReproWorkFiles=False
IF NOT EXIST linklib.src\REPRO.390 (
	CALL ASML linklib.src\REPRO notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
	SET cleanReproWorkFiles=True
	IF EXIST linklib.src\REPRO.BAL  ERASE linklib.src\REPRO.BAL
	IF EXIST linklib.src\REPRO.ERR  ERASE linklib.src\REPRO.ERR
	IF EXIST linklib.src\REPRO.LST  ERASE linklib.src\REPRO.LST
	IF EXIST linklib.src\REPRO.OBJ  ERASE linklib.src\REPRO.OBJ
	IF EXIST linklib.src\REPRO.PRN  ERASE linklib.src\REPRO.PRN
	IF EXIST linklib.src\REPRO.STA  ERASE linklib.src\REPRO.STA
)

SET cleanDemoWorkFiles=False
IF NOT EXIST demo\DEMO.390 (
	CALL ASML demo\DEMO notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
	SET cleanDemoWorkFiles=True
)

ECHO.
ECHO RT Test - Dynamic linked subroutines used in testlnk1

@REM Test and verify compile, link, execute, mlc (no pch or data files)
@REM using option file .\rt\Options.opt "bal notiming stats"

CALL ASMLG %dirRtWork%\TESTSUB1 @rt\Options.opt         %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL ASMLG %dirRtWork%\TESTSUB4 @rt\Options.opt amode24 %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

ECHO.
ECHO RT Test - Test the mz390 macro processor

CALL ASMLG %dirRtWork%\TESTSYS1 @rt\Options.opt sysparm(12345) %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL ASMLG %dirRtWork%\TESTSYS2 @rt\Options.opt bs2000         %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL ASMLG %dirRtWork%\TESTSYS3 @rt\Options.opt                %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

CALL ASMLG %dirRtWork%\TESTSYN1 @rt\Options.opt                         %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL ASMLG %dirRtWork%\TESTSYN2 @rt\Options.opt sysmac(mac+%dirRtWork%) %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

CALL ASMLG %dirRtWork%\TESTPRM1 @rt\Options.opt sysmac(mac+%dirRtWork%) %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL ASMLG %dirRtWork%\TESTPRM2 @rt\Options.opt sysmac(mac+%dirRtWork%) %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL ASMLG %dirRtWork%\TESTPRM3 @rt\Options.opt                         %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

CALL ASMLG %dirRtWork%\TESTMAC1 @rt\Options.opt                                             %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL ASMLG %dirRtWork%\TESTMAC2 @rt\Options.opt tracep                                      %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL ASMLG %dirRtWork%\TESTMAC3 @rt\Options.opt                                             %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL ASMLG %dirRtWork%\TESTMAC4 @rt\Options.opt                                             %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL ASMLG %dirRtWork%\TESTMAC5 @rt\Options.opt                                             %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL ASMLG %dirRtWork%\TESTMAC6 @rt\Options.opt                                             %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL ASMLG %dirRtWork%\TESTMAC7 @rt\Options.opt                                             %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL ASMLG %dirRtWork%\TESTMAC8 @rt\Options.opt sysmac(%dirRtWork%+mac)                     %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL ASMLG %dirRtWork%\TESTMAC9 @rt\Options.opt sysmac(%dirRtWork%+mac) syscpy(%dirRtWork%) %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

CALL ASMLG %dirRtWork%\TESTPRO1 @rt\Options.opt @%dirRtWork%\TESTPRO1.OPT %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL ASMLG %dirRtWork%\TESTOPR1 @rt\Options.opt tracep                    %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL ASMLG %dirRtWork%\TESTOPT1 @rt\Options.opt @%dirRtWork%\TESTOPT1.OPT %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

CALL ASMLG %dirRtWork%\TESTORG1 @rt\Options.opt trace %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

CALL ASMLG %dirRtWork%\TESTSET1 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL ASMLG %dirRtWork%\TESTSET2 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL ASMLG %dirRtWork%\TESTSET3 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

CALL ASMLG %dirRtWork%\TESTACT1 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

CALL ASMLG %dirRtWork%\TESTCPY1 @rt\Options.opt bal syscpy(mac+%dirRtWork%) %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL ASMLG %dirRtWork%\TESTCPY2 @rt\Options.opt bal syscpy(mac+%dirRtWork%) %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

CALL ASMLG %dirRtWork%\TESTSQL1 @rt\Options.opt sysmac(%dirRtWork%+mac) syscpy(%dirRtWork%) %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

CALL MZ390 %dirRtWork%\TESTEQU1 noasm bal notiming sysmac(mac) syscpy(mac) stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL MZ390 %dirRtWork%\TESTERR1 noasm bal notiming sysmac(mac) syscpy(mac) stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL MZ390 %dirRtWork%\TESTERR3 noasm bal notiming sysmac(mac) syscpy(mac) stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL MZ390 %dirRtWork%\TESTERR8 noasm bal notiming sysmac(mac) syscpy(mac) stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL MZ390 %dirRtWork%\TESTERR9 noasm bal notiming sysmac(mac) syscpy(mac) stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

SETLOCAL
SET SYSUT1=%dirRtWork%\TESTPCH1.TF1
SET SYSUT2=%dirRtWork%\TESTPCH1.TF2
SET SYSOUT=%dirRtWork%\TESTPCH1.TF3
CALL ASMLG %dirRtWork%\TESTPCH1 bal notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
ENDLOCAL

SETLOCAL
SET SYSUT1=%dirRtWork%\TESTPCH2.TF1
SET SYSUT2=%dirRtWork%\TESTPCH2.TF2
SET SYSOUT=%dirRtWork%\TESTPCH2.TF3
CALL ASMLG %dirRtWork%\TESTPCH2 bal notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
ENDLOCAL

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

IF NOT EXIST %dirRtWork%\SUBENTRY.MCR  COPY  mac\SUBENTRY.MAC %dirRtWork%\SUBENTRY.MCR
IF NOT EXIST %dirRtWork%\SUBEXIT.MCR   COPY  mac\SUBEXIT.MAC  %dirRtWork%\SUBEXIT.MCR
IF NOT EXIST %dirRtWork%\WTO.MCR       COPY  mac\WTO.MAC      %dirRtWork%\WTO.MCR
@REM Note: *.ASM necessary, otherwise MAC searches for *.MLC
CALL MAC %dirRtWork%\TESTMCR1.ASM @%dirRtWork%\TESTMCR1.OPT sysmac(%dirRtWork%\*.MCR) %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
@REM IF EXIST %dirRtWork%\SUBENTRY.MCR  ERASE %dirRtWork%\SUBENTRY.MCR
@REM IF EXIST %dirRtWork%\SUBEXIT.MCR   ERASE %dirRtWork%\SUBEXIT.MCR
@REM IF EXIST %dirRtWork%\WTO.MCR       ERASE %dirRtWork%\WTO.MCR

CALL MZ390 %dirRtWork%\TESTTXT1 noasm bal notiming sysmac(mac) syscpy(mac) stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

CALL ASMLG %dirRtWork%\TESTPC1  @rt\Options.opt tracep               %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL ASMLG %dirRtWork%\TESTAIN1 @rt\Options.opt                      %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL ASMLG %dirRtWork%\TESTAIN2 @rt\Options.opt syscpy(+%dirRtWork%) %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL ASMLG %dirRtWork%\TESTAIN3 @rt\Options.opt syscpy(+%dirRtWork%) %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

REM TESTCDE1 uses linklib.src\REPRO.390 at runtime!
IF NOT EXIST linklib.src\REPRO.390 (
	ECHO RT Test - Missing compiled file linklib.src\REPRO.390.
	ECHO RT Test - Test TESTCDE1 will fail.
	PAUSE
)
CALL ASMLG %dirRtWork%\TESTCDE1 @rt\Options.opt syscpy(+%dirRtWork%) sys390(+linklib.src) %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

ECHO.
ECHO RT Test - Test the az390 assembler

CALL ASMLG %dirRtWork%\TESTINS1 @rt\Options.opt assist %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

IF EXIST %dirRtWork%\TESTASC5.BAL  ERASE                      %dirRtWork%\TESTASC5.BAL
IF EXIST %dirRtWork%\TESTASC5.PRN  ERASE                      %dirRtWork%\TESTASC5.PRN
IF EXIST %dirRtWork%\TESTASC5.OBJ  ERASE                      %dirRtWork%\TESTASC5.OBJ
IF EXIST %dirRtWork%\TESTASC5.ERR  ERASE                      %dirRtWork%\TESTASC5.ERR
IF EXIST %dirRtWork%\TESTASC5.STA  ERASE                      %dirRtWork%\TESTASC5.STA
IF EXIST %dirRtWork%\TESTASC5.TR*  ERASE                      %dirRtWork%\TESTASC5.TR*
IF EXIST %dirRtWork%\TESTINS1.BAL  COPY  %dirRtWork%\TESTINS1.BAL %dirRtWork%\TESTASC5.BAL
CALL AZ390 %dirRtWork%\TESTASC5 assist notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

CALL ASMLG %dirRtWork%\TESTDST1 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL ASMLG %dirRtWork%\TESTLCT1 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL ASMLG %dirRtWork%\TESTSYM1 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

CALL ASMLG %dirRtWork%\TESTUSE1 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL ASMLG %dirRtWork%\TESTUSE2 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL ASMLG %dirRtWork%\TESTPRT1 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

@REM Note: Uses file TESTUSE1.OBJ from test far above!
CALL ASMLG %dirRtWork%\TESTDC1 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

IF EXIST %dirRtWork%\TESTASC1.MLC  ERASE                        %dirRtWork%\TESTASC1.MLC
IF EXIST %dirRtWork%\TESTDC1.MLC   COPY %dirRtWork%\TESTDC1.MLC %dirRtWork%\TESTASC1.MLC
@REM Note: Uses file .\linklib\CVTTOHEX.OBJ
IF NOT EXIST .\linklib\CVTTOHEX.OBJ (
	ECHO RT Test - Missing compiled file .\linklib\CVTTOHEX.OBJ.
	ECHO RT Test - Test TESTASC1 will fail.
	PAUSE
)
CALL ASMLG %dirRtWork%\TESTASC1 @rt\Options.opt ascii %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

CALL ASMLG %dirRtWork%\TESTDC2  @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

CALL ASMLG %dirRtWork%\TESTLOC1 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

CALL ASMLG %dirRtWork%\TESTSDT1 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
IF EXIST %dirRtWork%\TESTASC2.MLC  ERASE                         %dirRtWork%\TESTASC2.MLC
IF EXIST %dirRtWork%\TESTSDT1.MLC  COPY %dirRtWork%\TESTSDT1.MLC %dirRtWork%\TESTASC2.MLC
CALL ASMLG %dirRtWork%\TESTASC2 @rt\Options.opt ascii %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

CALL ASMLG %dirRtWork%\TESTASM1 @rt\Options.opt mcall sysmac(%dirRtWork%+.\mac) %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL ASMLG %dirRtWork%\TESTASM2 @rt\Options.opt                                 %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

CALL ASMLG %dirRtWork%\TESTENV1 @rt\Options.opt TRACE %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

@REM RT4
IF EXIST %dirRtWork%\TESTERR2.BAL ERASE %dirRtWork%\TESTERR2.BAL
IF EXIST %dirRtWork%\TESTERR2.PRN ERASE %dirRtWork%\TESTERR2.PRN
IF EXIST %dirRtWork%\TESTERR2.OBJ ERASE %dirRtWork%\TESTERR2.OBJ
IF EXIST %dirRtWork%\TESTERR2.ERR ERASE %dirRtWork%\TESTERR2.ERR
IF EXIST %dirRtWork%\TESTERR2.STA ERASE %dirRtWork%\TESTERR2.STA
IF EXIST %dirRtWork%\TESTERR2.TR? ERASE %dirRtWork%\TESTERR2.TR?
CALL MZ390 %dirRtWork%\TESTERR2 bal notiming sysmac(mac) syscpy(mac) stats err(0) %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

@REM RT4
IF EXIST %dirRtWork%\TESTERRA.BAL ERASE %dirRtWork%\TESTERRA.BAL
IF EXIST %dirRtWork%\TESTERRA.PRN ERASE %dirRtWork%\TESTERRA.PRN
IF EXIST %dirRtWork%\TESTERRA.OBJ ERASE %dirRtWork%\TESTERRA.OBJ
IF EXIST %dirRtWork%\TESTERRA.ERR ERASE %dirRtWork%\TESTERRA.ERR
IF EXIST %dirRtWork%\TESTERRA.STA ERASE %dirRtWork%\TESTERRA.STA
IF EXIST %dirRtWork%\TESTERRA.TR? ERASE %dirRtWork%\TESTERRA.TR?
CALL MZ390 %dirRtWork%\TESTERRA bal notiming sysmac(mac) syscpy(mac) stats chkmac(2) %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

@REM RT4
IF EXIST %dirRtWork%\TESTLAB1.BAL ERASE %dirRtWork%\TESTLAB1.BAL
IF EXIST %dirRtWork%\TESTLAB1.PRN ERASE %dirRtWork%\TESTLAB1.PRN
IF EXIST %dirRtWork%\TESTLAB1.OBJ ERASE %dirRtWork%\TESTLAB1.OBJ
IF EXIST %dirRtWork%\TESTLAB1.ERR ERASE %dirRtWork%\TESTLAB1.ERR
IF EXIST %dirRtWork%\TESTLAB1.STA ERASE %dirRtWork%\TESTLAB1.STA
IF EXIST %dirRtWork%\TESTLAB1.TR? ERASE %dirRtWork%\TESTLAB1.TR?
CALL MZ390 %dirRtWork%\TESTLAB1 bal notiming sysmac(mac) syscpy(mac) stats err(0) %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

ECHO RT Test - Test the lz390 linker

CALL ASMLG %dirRtWork%\TESTRLD1 @rt\Options.opt                  %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL ASMLG %dirRtWork%\TESTRLD2 @rt\Options.opt NOLOADHIGH TRACE %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL ASMLG %dirRtWork%\TESTENT1 @rt\Options.opt                  %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

@REM Note: Uses file TESTSUB1.OBJ from test far above!
CALL ASMLG %dirRtWork%\TESTEXT1 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

@REM Note: Uses file TESTSUB1.OBJ from test far above!
CALL ASMLG %dirRtWork%\TESTEXT2 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

@REM Note: Uses file TESTSUB1.OBJ from test far above!
CALL ASMLG %dirRtWork%\TESTWXT1 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

@REM Note: Uses file TESTSUB1.OBJ from test far above!
CALL ASMLG %dirRtWork%\TESTOBJ1 @rt\Options.opt objhex %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

@REM Note: Uses file TESTSUB1.OBJ from test far above!
CALL ASMLG %dirRtWork%\TESTOBJ2 @rt\Options.opt @TESTOBJ2.OPT %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
@REM Note: Remove 32 MB file to save space and avoid compare
IF EXIST %dirRtWork%\TESTOBJ2.390 ERASE %dirRtWork%\TESTOBJ2.390

CALL ASMLG %dirRtWork%\TESTPRM4 @rt\Options.opt @TESTPRM4.OPT %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

ECHO RT Test - Test the ez390 emulator

CALL ASML  %dirRtWork%\TESTERR4 bal notiming   %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL EZ390 %dirRtWork%\TESTERR4 notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

CALL ASMLG %dirRtWork%\TESTERR5 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

CALL ASML  %dirRtWork%\TESTERR6 bal notiming   %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL EZ390 %dirRtWork%\TESTERR6 notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

CALL ASML  %dirRtWork%\TESTERR7 bal notiming   %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL EZ390 %dirRtWork%\TESTERR7 notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

CALL ASMLG %dirRtWork%\TESTINS2 @rt\Options.opt trace %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

IF EXIST %dirRtWork%\TESTASC3.MLC  ERASE                         %dirRtWork%\TESTASC3.MLC
IF EXIST %dirRtWork%\TESTINS2.MLC  COPY %dirRtWork%\TESTINS2.MLC %dirRtWork%\TESTASC3.MLC
CALL ASMLG %dirRtWork%\TESTASC3 @rt\Options.opt ascii trace %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

CALL ASMLG %dirRtWork%\TESTINS3 @rt\Options.opt trace %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL ASMLG %dirRtWork%\TESTINS4 @rt\Options.opt trace %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

CALL ASMLG %dirRtWork%\TESTFP1  @rt\Options.opt trace %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL ASMLG %dirRtWork%\TESTFP2  @rt\Options.opt trace %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

CALL ASMLG %dirRtWork%\TESTDFP1 @rt\Options.opt trace %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL ASMLG %dirRtWork%\TESTDFP2 @rt\Options.opt trace %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

CALL ASMLG %dirRtWork%\TESTCAL1 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL ASMLG %dirRtWork%\TESTCAL2 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

SET DDTODEMO=demo\DEMO.390
REM Note: Uses following files %DDTODEMO%, %dirRtWork%\TESTSUB1.390, and %dirRtWork%\TESTSUB4.390 from tests far above!
IF NOT EXIST %DDTODEMO% (
	ECHO RT Test - Missing compiled file %DDTODEMO%.
	ECHO RT Test - Test TESTLNK2 will fail.
	PAUSE
)
IF NOT EXIST %dirRtWork%\TESTSUB1.390 (
	ECHO RT Test - Missing compiled file %dirRtWork%\TESTSUB1.390.
	ECHO RT Test - Test TESTLNK2 will fail.
	PAUSE
)
IF NOT EXIST %dirRtWork%\TESTSUB4.390 (
	ECHO RT Test - Missing compiled file %dirRtWork%\TESTSUB4.390.
	ECHO RT Test - Test TESTLNK2 will fail.
	PAUSE
)
CALL ASMLG %dirRtWork%\TESTLNK1 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

REM Note: Uses %dirRtWork%\TESTLNK2.LKD.
CALL ASM   %dirRtWork%\TESTLNK2 notiming stats  %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL ASM   %dirRtWork%\TESTLNK3 notiming stats  %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
SET  MYLIB=%dirRtWork%
CALL LINK  %dirRtWork%\TESTLNK2  notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL EXEC  %dirRtWork%\TESTLNK3  notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
SET  MYLIB=

CALL ASMLG %dirRtWork%\TESTLNK4 @rt\Options.opt notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

SET  MYLIB=%dirRtWork%
CALL ASMLG %dirRtWork%\TESTLNK5 @rt\Options.opt notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
SET  MYLIB=

REM Note: Uses following files demo\DEMO.390 and %dirRtWork%\TESTSUB1.390 from tests far above!
IF NOT EXIST demo\DEMO.390 (
	ECHO RT Test - Missing compiled file demo\DEMO.390.
	ECHO RT Test - Test TESTLOD1 will fail.
	PAUSE
)
IF NOT EXIST %dirRtWork%\TESTSUB1.390 (
	ECHO RT Test - Missing compiled file %dirRtWork%\TESTSUB1.390.
	ECHO RT Test - Test TESTLOD1 will fail.
	PAUSE
)
CALL ASMLG %dirRtWork%\TESTLOD1 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
SET DDTODEMO=

CALL ASMLG %dirRtWork%\TESTLOD2 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9


CALL ASMLG %dirRtWork%\TESTXCL4 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL ASMLG %dirRtWork%\TESTXCL3 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL ASMLG %dirRtWork%\TESTXCL2 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL ASMLG %dirRtWork%\TESTXCL1 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

SETLOCAL
SET SYSUT1=%dirRtWork%\TESTDCB1.TF1
SET SYSUT2=%dirRtWork%\TESTDCB1.TF2
SET SYSOUT=%dirRtWork%\TESTDCB1.TF3
IF EXIST %SYSUT2%  ERASE %SYSUT2%
IF EXIST %SYSOUT%  ERASE %SYSOUT%
CALL ASMLG %dirRtWork%\TESTDCB1 bal notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
ENDLOCAL

SETLOCAL
SET SYSUT1=%dirRtWork%\TESTDCB2.TF1
SET SYSUT2=%dirRtWork%\TESTDCB2.TF2
SET SYSOUT=%dirRtWork%\TESTDCB2.TF3
IF EXIST %SYSUT2%  ERASE %SYSUT2%
IF EXIST %SYSOUT%  ERASE %SYSOUT%
CALL ASMLG %dirRtWork%\TESTDCB2 bal notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
ENDLOCAL

SETLOCAL
SET SYSUT1=%dirRtWork%\TESTDCB3.TF1
SET SYSUT2=%dirRtWork%\TESTDCB3.TF2
SET SYSOUT=%dirRtWork%\TESTDCB3.TF3
IF EXIST %SYSUT2%  ERASE %SYSUT2%
IF EXIST %SYSOUT%  ERASE %SYSOUT%
CALL ASMLG %dirRtWork%\TESTDCB3 bal notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
ENDLOCAL

SETLOCAL
SET SYSUT1=%dirRtWork%\TESTDCB4.TF1
SET SYSUT2=%dirRtWork%\TESTDCB4.TF2
SET SYSOUT=%dirRtWork%\TESTDCB4.TF3
IF EXIST %SYSUT2%  ERASE %SYSUT2%
IF EXIST %SYSOUT%  ERASE %SYSOUT%
CALL ASMLG %dirRtWork%\TESTDCB4 bal notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
ENDLOCAL

SETLOCAL
SET SYSUT1=%dirRtWork%\TESTDCB5.TF1
SET SYSUT2=%dirRtWork%\TESTDCB5.TF2
SET SYSOUT=%dirRtWork%\TESTDCB5.TF3
IF EXIST %SYSUT2%  ERASE %SYSUT2%
IF EXIST %SYSOUT%  ERASE %SYSOUT%
CALL ASMLG %dirRtWork%\TESTDCB5 bal notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
ENDLOCAL

SETLOCAL
SET SYSUT1=%dirRtWork%\TESTDCB6.TF1
SET SYSUT2=%dirRtWork%\TESTDCB6.TF2
SET SYSOUT=%dirRtWork%\TESTDCB6.TF3
IF EXIST %SYSUT2%  ERASE %SYSUT2%
IF EXIST %SYSOUT%  ERASE %SYSOUT%
CALL ASMLG %dirRtWork%\TESTDCB6 bal notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
ENDLOCAL

SETLOCAL
SET SYSUT1=%dirRtWork%\TESTDCB7.TF1
SET SYSUT2=%dirRtWork%\TESTDCB7.TF2
SET SYSOUT=%dirRtWork%\TESTDCB7.TF3
IF EXIST %SYSUT2%  ERASE %SYSUT2%
IF EXIST %SYSOUT%  ERASE %SYSOUT%
CALL ASMLG %dirRtWork%\TESTDCB7 bal notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
ENDLOCAL

SETLOCAL
SET SYSUT1=%dirRtWork%\TESTDCB8.TF1
SET SYSUT2=%dirRtWork%\TESTDCB8.TF2
SET SYSOUT=%dirRtWork%\TESTDCB8.TF3
IF EXIST %SYSUT2%  ERASE %SYSUT2%
IF EXIST %SYSOUT%  ERASE %SYSOUT%
CALL ASMLG %dirRtWork%\TESTDCB8 bal notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
ENDLOCAL

SETLOCAL
SET SYSUT1=%dirRtWork%\TESTDCB9.TF1
SET SYSUT2=%dirRtWork%\TESTDCB9.TF2
SET SYSOUT=%dirRtWork%\TESTDCB9.TF3
IF EXIST %SYSUT2%  ERASE %SYSUT2%
IF EXIST %SYSOUT%  ERASE %SYSOUT%
CALL ASMLG %dirRtWork%\TESTDCB9 bal notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
ENDLOCAL

IF EXIST %dirRtWork%\TESTDCBA.TF2  ERASE %dirRtWork%\TESTDCBA.TF2
IF EXIST %dirRtWork%\TESTDCBA.TF3  ERASE %dirRtWork%\TESTDCBA.TF3
CALL ASMLG %dirRtWork%\TESTDCBA @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

SETLOCAL
SET SYSUT1=%dirRtWork%\TESTDCBB.TF1
SET SYSUT2=%dirRtWork%\TESTDCBB.TF2
SET SYSOUT=%dirRtWork%\TESTDCBB.TF3
IF EXIST %SYSUT2%  ERASE %SYSUT2%
IF EXIST %SYSOUT%  ERASE %SYSOUT%
CALL ASMLG %dirRtWork%\TESTDCBB bal notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
ENDLOCAL

SETLOCAL
SET SYSUT1=%dirRtWork%\TESTDCBC.TF1
SET SYSUT2=%dirRtWork%\TESTDCBC.TF2
SET SYSOUT=%dirRtWork%\TESTDCBC.TF3
IF EXIST %SYSUT2%  ERASE %SYSUT2%
IF EXIST %SYSOUT%  ERASE %SYSOUT%
CALL ASMLG %dirRtWork%\TESTDCBC bal notiming stats ascii %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
ENDLOCAL

SETLOCAL
SET SYSUT1=%dirRtWork%\TESTDCBD.TF1
SET SYSUT2=%dirRtWork%\TESTDCBD.TF2
SET SYSOUT=%dirRtWork%\TESTDCBD.TF3
IF EXIST %SYSUT2%  ERASE %SYSUT2%
IF EXIST %SYSOUT%  ERASE %SYSOUT%
CALL ASMLG %dirRtWork%\TESTDCBD bal notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
ENDLOCAL

SETLOCAL
SET SYSUT1=%dirRtWork%\TESTDCBE.TF1
SET SYSUT2=%dirRtWork%\TESTDCBE.TF2
SET SYSOUT=%dirRtWork%\TESTDCBE.TF3
IF EXIST %SYSUT2%  ERASE %SYSUT2%
IF EXIST %SYSOUT%  ERASE %SYSOUT%
CALL ASMLG %dirRtWork%\TESTDCBE bal notiming stats ascii %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
ENDLOCAL

SETLOCAL
SET SYSUT1=%dirRtWork%\TESTDCBF.TF1
SET SYSUT2=%dirRtWork%\TESTDCBF.TF2
SET SYSOUT=%dirRtWork%\TESTDCBF.TF3
IF EXIST %SYSUT2%  ERASE %SYSUT2%
IF EXIST %SYSOUT%  ERASE %SYSOUT%
CALL ASMLG %dirRtWork%\TESTDCBF bal notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
ENDLOCAL

SETLOCAL
SET SYSUT1=%dirRtWork%\TESTEOF1.TF1
SET SYSUT2=%dirRtWork%\TESTEOF1.TF2
SET SYSOUT=%dirRtWork%\TESTEOF1.TF3
IF EXIST %SYSUT2%  ERASE %SYSUT2%
IF EXIST %SYSOUT%  ERASE %SYSOUT%
CALL ASMLG %dirRtWork%\TESTEOF1 bal notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
ENDLOCAL

CALL ASMLG %dirRtWork%\TESTTIM1 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL ASMLG %dirRtWork%\TESTTIM2 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

CALL ASMLG %dirRtWork%\TESTECB1 @rt\Options.opt trace %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

CALL ASMLG %dirRtWork%\TESTMEM1 @rt\Options.opt mem(32) %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL ASMLG %dirRtWork%\TESTMEM2 @rt\Options.opt mem(2)  %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL ASMLG %dirRtWork%\TESTMEM3 @rt\Options.opt mem(32) %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL ASMLG %dirRtWork%\TESTMEM4 @rt\Options.opt mem(2)  %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

SETLOCAL
SET SYSUT1=%dirRtWork%\TESTTST1.TF1
SET SYSUT2=%dirRtWork%\TESTTST1.TF2
SET SYSOUT=%dirRtWork%\TESTTST1.TF3
CALL ASMLG %dirRtWork%\TESTTST1 bal notiming stats test(SYSUT1) %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
ENDLOCAL

SETLOCAL
IF EXIST %dirRtWork%\TESTASC4.MLC  ERASE %dirRtWork%\TESTASC4.MLC
IF EXIST %dirRtWork%\TESTASC4.TF1  ERASE %dirRtWork%\TESTASC4.TF1
COPY %dirRtWork%\TESTTST1.MLC %dirRtWork%\TESTASC4.MLC
COPY %dirRtWork%\TESTTST1.TF1 %dirRtWork%\TESTASC4.TF1
SET SYSUT1=%dirRtWork%\TESTASC4.TF1
@REM SYSUT2=%dirRtWork%\TESTASC4.TF2
@REM SYSOUT=%dirRtWork%\TESTASC4.TF3
CALL ASMLG %dirRtWork%\TESTASC4 bal notiming stats test(SYSUT1) ascii %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
ENDLOCAL

CALL ASMLG %dirRtWork%\TESTCMD1 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL ASMLG %dirRtWork%\TESTCMD2 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

CALL ASMLG %dirRtWork%\TESTCIC1 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL ASM   %dirRtWork%\TESTCIC2 cics notiming  sysmac(cics+mac) syscpy(cics+mac) stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

CALL ASML  %dirRtWork%\TESTDMP1 bal notiming   %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL EZ390 %dirRtWork%\TESTDMP1 notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

CALL ASML  %dirRtWork%\TESTDMP2 bal notiming   dump %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL EZ390 %dirRtWork%\TESTDMP2 notiming stats dump %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

CALL ASML  %dirRtWork%\TESTDMP3 bal notiming   %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL EZ390 %dirRtWork%\TESTDMP3 notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

IF NOT EXIST %dirRtWork%\TESTDMP4.TF1 (
	ECHO RT Test - Missing helper file %dirRtWork%\TESTDMP4.TF1.
	ECHO RT Test - Test TESTDMP4 will fail.
	PAUSE
)
CALL ASML  %dirRtWork%\TESTDMP4 bal notiming   %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL EZ390 %dirRtWork%\TESTDMP4 notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

CALL ASML  %dirRtWork%\TESTDMP5 bal notiming   dump ascii %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL EZ390 %dirRtWork%\TESTDMP5 notiming stats dump ascii %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

CALL ASMLG %dirRtWork%\TESTXLT1 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

@REM  Uses files demo\DEMO.390 and %dirRtWork%\TESTSUB1.390
IF NOT EXIST demo\DEMO.390 (
	ECHO RT Test - Missing helper file demo\DEMO.390.
	ECHO RT Test - Test TESTBLD1 will fail.
	PAUSE
)
IF NOT EXIST %dirRtWork%\TESTSUB1.390 (
	ECHO RT Test - Missing helper file %dirRtWork%\TESTSUB1.390.
	ECHO RT Test - Test TESTBLD1 will fail.
	PAUSE
)
CALL ASMLG %dirRtWork%\TESTBLD1 @rt\Options.opt sys390(%dirRtWork%+demo) %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

CALL ASMLG %dirRtWork%\TESTSVC1 @rt\Options.opt trace noprotect %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

CALL ASMLG %dirRtWork%\TESTIPL1 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
IF NOT EXIST %dirRtWork%\TESTIPL1.390 (
	ECHO RT Test - Missing helper file %dirRtWork%\TESTIPL1.390.
	ECHO RT Test - Test TESTIPL2 will fail.
	PAUSE
)
CALL ASMLG %dirRtWork%\TESTIPL2 @rt\Options.opt ipl(TESTIPL1) sys390(%dirRtWork%) %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

CALL ASMLG %dirRtWork%\TESTZCV1 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

CALL ASMLG %dirRtWork%\TESTSPI1 @rt\Options.opt trace %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

CALL ASMLG %dirRtWork%\TESTSTA1 @rt\Options.opt trace %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL ASML  %dirRtWork%\TESTSTA3 notiming stats        %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL ASMLG %dirRtWork%\TESTSTA2 @rt\Options.opt trace %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

CALL ASMLG %dirRtWork%\TESTCTD1 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL ASMLG %dirRtWork%\TESTCFD1 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

CALL ASMLG %dirRtWork%\TESTCVB1 @rt\Options.opt trace %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL ASMLG %dirRtWork%\TESTCVBG @rt\Options.opt trace %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9


SETLOCAL
ECHO RT Test
ECHO RT Test - Test zstrmac basic structures using bootstrap version 1
ECHO RT Test - mz390 zstrmac1.mlc in:testspe1.zsm  out:testspe1.mlc
ECHO RT Test
SET sysut1=%dirRtWork%\TESTSPE1.ZSM
SET sysut2=%dirRtWork%\TESTSPE1.MLC
IF EXIST %sysut2%  ERASE %sysut2%
CALL MZ390 %dirRtWork%\ZSTRMAC1 noasm stats notiming %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
IF ErrorLevel 1        @PAUSE
IF NOT EXIST %sysut2%  @PAUSE
CALL ASMLG %sysut2% @rt\Options.opt stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
ENDLOCAL


SETLOCAL
ECHO RT Test
ECHO RT Test - Translate structured version 2 using bootstrap version 1
ECHO RT Test - mz390 zstrmac1.mlc in:testspe2.zsm  out:testspe2.mlc
ECHO RT Test
SET sysut1=%dirRtWork%\TESTSPE2.ZSM
SET sysut2=%dirRtWork%\TESTSPE2.MLC
IF EXIST %sysut2%  ERASE %sysut2%
CALL MZ390 %dirRtWork%\ZSTRMAC1 noasm stats notiming %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
IF ErrorLevel 1        @PAUSE
IF NOT EXIST %sysut2%  @PAUSE
CALL ASMLG %sysut2% @rt\Options.opt stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
ENDLOCAL


SETLOCAL
ECHO RT Test
ECHO RT Test - Translate structured version 2 using bootstrap version 1
ECHO RT Test - mz390 zstrmac1.mlc in:zstrmac2.zsm  out:zstrmac2.mlc (bootstrap)
ECHO RT Test
SET sysut1=%dirRtWork%\ZSTRMAC2.ZSM
SET sysut2=%dirRtWork%\ZSTRMAC2.MLC
IF EXIST %sysut2%  ERASE %sysut2%
CALL MZ390 %dirRtWork%\ZSTRMAC1 noasm stats notiming %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
IF ErrorLevel 1        @PAUSE
IF NOT EXIST %sysut2%  @PAUSE
ENDLOCAL


SETLOCAL
ECHO RT Test
ECHO RT Test - Verify TESTZSM1.ZSM translation using zstrmac2 matches zstrmac1
ECHO RT Test - mz390 zstrmac2.mlc in:testspe1.zsm  out:testspe1.txt
ECHO RT Test
SET sysut1=%dirRtWork%\TESTSPE1.ZSM
SET sysut2=%dirRtWork%\TESTSPE1.TXT
IF EXIST %sysut2%  ERASE %sysut2%
CALL MZ390 %dirRtWork%\ZSTRMAC2 noasm stats notiming %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
IF ErrorLevel 1        @PAUSE
IF NOT EXIST %sysut2%  @PAUSE
ENDLOCAL


SETLOCAL
ECHO RT Test
ECHO RT Test - Re-generate ZSTRMAC2 using mz390 support to ver zstrmac2.txt = mlc
ECHO RT Test - mz390 zstrmac2.zsm in:zstrmac2.zsm  out:zstrmac2.txt (regen)
ECHO RT Test
SET sysut1=%dirRtWork%\ZSTRMAC2.ZSM
SET sysut2=%dirRtWork%\ZSTRMAC2.TXT
IF EXIST %sysut2%  ERASE %sysut2%
CALL MZ390 %sysut1% noasm stats notiming %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
IF ErrorLevel 1        @PAUSE
IF NOT EXIST %sysut2%  @PAUSE
ENDLOCAL


SETLOCAL
ECHO RT Test
ECHO RT Test - Test extensions to ACASE added in zstrmac2 C,X,(v1,v2)
ECHO RT Test - mz390 zstrmac2.zsm in:testspe3.zsm  out:testspe3.mlc
ECHO RT Test
SET sysut1=%dirRtWork%\TESTSPE3.ZSM
SET sysut2=%dirRtWork%\TESTSPE3.MLC
CALL MZ390 %dirRtWork%\ZSTRMAC2.ZSM noasm stats notiming %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
IF ErrorLevel 1        @PAUSE
IF NOT EXIST %sysut2%  @PAUSE
CALL ASMLG %dirRtWork%\TESTSPE3 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
ENDLOCAL


SETLOCAL
ECHO RT Test
ECHO RT Test - Test zstrmac error messages
ECHO RT Test - mz390 zstrmac2.zsm in:testspe4.zsm  out:testspe4.mlc
ECHO RT Test
SET sysut1=%dirRtWork%\TESTSPE4.ZSM
SET sysut2=%dirRtWork%\TESTSPE4.MLC
CALL MZ390 %dirRtWork%\ZSTRMAC2.ZSM noasm stats notiming %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
IF ErrorLevel 9        @PAUSE
CALL ASMLG %dirRtWork%\TESTSPM1 @rt\Options.opt %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
ENDLOCAL

ECHO.
ECHO RT Test - Creating directories %dirRtSaved% and %dirRtDiffs% (if necessary).
IF NOT EXIST %dirRtWork%\nul   @MKDIR %dirRtWork%
IF NOT EXIST %dirRtDiffs%\nul  @MKDIR %dirRtDiffs%
IF NOT EXIST %dirRtSaved%\nul  @MKDIR %dirRtSaved%

ECHO.
ECHO RT Test - Cleaning rt diff directory %dirRtDiffs%
ERASE /Q %dirRtDiffs%\*.*

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

IF "%cleanReproWorkFiles%" == "True" (
	IF EXIST linklib.src\REPRO.390  ERASE linklib.src\REPRO.390
)
SET cleanReproWorkFiles=

:doCompare
ECHO.
ECHO RT Test - Compare %dirRtWork% test files with %dirRtSaved% save files and generate %dirRtDiffs% diff files
ECHO.
@java -classpath z390.jar -Xrs %J2SEOPTIONS% DiffRegrTests %dirRtWork% %dirRtSaved% %dirRtDiffs%

:doListing
ECHO.
ECHO RT Test - Displaying ordered list of %dirRtDiffs%
@DIR /OS /P %dirRtDiffs%

ECHO.
ECHO RT Test - Finished!
ECHO.

:ende
ENDLOCAL
@POPD
