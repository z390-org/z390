@ECHO OFF
@SETLOCAL
@IF /I "%1" == "TRON" (
	@SET trace=TRON
	@SHIFT
)

@IF "%trace%" == "TRON" (
	@ECHO.
	@ECHO Link to generate 390 load module from one or more obj files.
	@ECHO.
	@ECHO Removing working and temp files...
)

@if exist %1%.390 (
	@IF "%trace%" == "TRON" @ECHO Erasing %1%.390
	@erase %1%.390
)
@if exist %1%.lst (
	@IF "%trace%" == "TRON" @ECHO Erasing %1%.lst
	@erase %1%.lst
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

@IF NOT "%trace%" == "TRON" GOTO doCall_lz390

@ECHO.
@ECHO Calling lz390 batch file...

@ECHO CALL %~dps0lz390
@IF NOT "%1" == "" @ECHO      %1 %2 %3 %4 %5 %6 %7 %8 %9

:doCall_lz390
@CALL %~dps0lz390 %1 %2 %3 %4 %5 %6 %7 %8 %9
@IF ErrorLevel 1 GOTO lzErr
@GOTO end

:lzErr
@PAUSE See errors on lz390 generated lst file and console.

:end
@SET trace=
@ENDLOCAL
