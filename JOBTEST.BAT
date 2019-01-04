@ECHO OFF
@SETLOCAL
@IF /I "%1" == "TRON" (
	@SET trace=TRON
	@SHIFT
)

@IF "%trace%" == "TRON" (
	@ECHO.
	@ECHO jobtest - just a simple batch file for testing the JOB command
)

@ECHO.
@ECHO This is just a simple batch file for testing the JOB command...

:end
@SET trace=
@ENDLOCAL
