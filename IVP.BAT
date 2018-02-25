@ECHO OFF
@SETLOCAL
@IF /I "%1" == "TRON" (
	@SET trace=TRON
	@SHIFT
)

@IF "%trace%" == "TRON" (
	@ECHO.
	@ECHO ivp - run z390 installation verification program iz390.class
)

java -classpath z390.jar -Xrs iz390 %1 %2 %3 %4 %5 %6 %7 %8 %9

:end
@ENDLOCAL
