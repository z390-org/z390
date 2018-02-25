@ECHO OFF
@ECHO.
@ECHO asml assemble and link to generate load module 390 from mlc
@ECHO.

@SETLOCAL
@IF /I "%1" == "TRON" (
	@SET trace=TRON
	@ECHO Setting ECHO ON...
	@SHIFT
)

@IF "%trace%" == "TRON" (
	@ECHO.
	@ECHO Removing working and temp files...
)

@if exist %1%.bal (
	@IF "%trace%" == "TRON" @ECHO Erasing %1%.bal
	@erase %1%.bal
)
@if exist %1%.prn (
	@IF "%trace%" == "TRON" @ECHO Erasing %1%.prn
	@erase %1%.prn
)
@if exist %1%.obj (
	@IF "%trace%" == "TRON" @ECHO Erasing %1%.obj
	@erase %1%.obj
)
@if exist %1%.lst (
	@IF "%trace%" == "TRON" @ECHO Erasing %1%.lst
	@erase %1%.lst
)
@if exist %1%.390 (
	@IF "%trace%" == "TRON" @ECHO Erasing %1%.390
	@erase %1%.390
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

@IF NOT "%trace%" == "TRON" GOTO doCall_mz390

@ECHO.
@ECHO Calling mz390 batch file...

@ECHO CALL %~dps0mz390
@IF NOT "%1" == "" @ECHO      %1
@ECHO      sysmac^(%~dps0mac+.^)
@ECHO      syscpy^(%~dps0mac+.^)
@IF NOT "%2" == "" @ECHO      %2 %3 %4 %5 %6 %7 %8 %9

:doCall_mz390
@CALL %~dps0mz390 %1  sysmac(%~dps0mac+.) syscpy(%~dps0mac+.) %2 %3 %4 %5 %6 %7 %8 %9
@IF ErrorLevel 5 GOTO mzErr


@IF NOT "%trace%" == "TRON" GOTO doCall_lz390

@ECHO.
@ECHO Calling lz390 batch file...

@ECHO CALL %~dps0lz390
@IF NOT "%1" == "" @ECHO      %1 %2 %3 %4 %5 %6 %7 %8 %9

:doCall_lz390
@CALL %~dps0lz390 %1 %2 %3 %4 %5 %6 %7 %8 %9
@IF ErrorLevel 5 GOTO lzErr
@GOTO end

:mzErr
@PAUSE See errors on mz390 generated bal file and console.
@GOTO end

:lzErr
@PAUSE See errors on lz390 generated lst file and console.
@ID EXIST %1%.390 (
	@IF "%trace%" == "TRON" @ECHO Erasing %1%.390
	@ERASE %1%.390
)

:end
@SET trace=
@ENDLOCAL