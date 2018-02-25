@ECHO OFF
@ECHO.
@ECHO exec execute 390 load module
@ECHO.

@SETLOCAL
@IF /I "%1" == "TRON" (
	@SET trace=TRON
	@ECHO Setting ECHO ON...
	@SHIFT
)

@if exist %1%.log (
	@IF "%trace%" == "TRON" @ECHO Erasing %1%.log
	@erase %1%.log
)
@if exist %1%.err (
	@IF "%trace%" == "TRON" @ECHO Erasing %1%.err
	@erase %1%.err
)
@if exist %1%.sta (
	@IF "%trace%" == "TRON" @ECHO Erasing %1%.sta
	@erase %1%.sta
)
@if exist %1%.tr* (
	@IF "%trace%" == "TRON" @ECHO Erasing %1%.tr*
	@erase %1%.tr*
)

@IF NOT "%trace%" == "TRON" GOTO doCall_ez390

@ECHO.
@ECHO Calling ez390 batch file...
@ECHO CALL %~dps0ez390 %1 %2 %3 %4 %5 %6 %7 %8 %9

:doCall_ez390
@CALL %~dps0ez390 %1 %2 %3 %4 %5 %6 %7 %8 %9
@IF errorlevel 5 GOTO ezErr
@GOTO end

:ezErr
@ECHO.
@PAUSE See errors on ez390 generated log file and console.

:end
@SET trace=
@ENDLOCAL
