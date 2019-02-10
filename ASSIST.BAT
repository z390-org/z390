@ECHO OFF
@SETLOCAL

@IF /I "%1" == "TRON" (
	@SET trace=TRON
	@SHIFT
)

@IF "%trace%" == "TRON" (
	@ECHO.
	@ECHO assist - assemble, link, and execute ASSIST program %1.MLC
)

@IF "%1" == "" (
	@ECHO.
	@ECHO Missing program parameter MLC file. Aborting.
	@GOTO astEnd
)

@SET XREAD=%1.XRD
@SET XPRNT=%1.XPR
@SET XPNCH=%1.XPH
@SET XGET=%1.XGT
@SET XPUT=%1.XPT

@CALL ASMLG %trace% %1 assist %2 %3 %4 %5 %6 %7 %8 %9

:astEnd:
@ENDLOCAL