@REM Execute ez390 runtime with java runtime options:
@REM -classpath  path to jar file
@REM -verbose:gc trace garbage collection to detect memory leaks
@REM -XmsnK      set initial memory allocation to nK
@REM -XmxnK      set max     memory allocation to nK
@REM -Xrs        allow control break interruption of java tasks

@IF NOT "%trace%" == "TRON" GOTO doJava_ez390

@ECHO.
@ECHO java -classpath %~dps0z390.jar
@ECHO      -Xrs
@IF NOT "%J2SEOPTIONS%" == "" @ECHO      %J2SEOPTIONS%
@ECHO      ez390 %1
@IF NOT "%2" == "" @ECHO      %2
@IF NOT "%3" == "" @ECHO      %3
@IF NOT "%4" == "" @ECHO      %4
@IF NOT "%5" == "" @ECHO      %5
@IF NOT "%6" == "" @ECHO      %6
@IF NOT "%7" == "" @ECHO      %7
@IF NOT "%8" == "" @ECHO      %8
@IF NOT "%9" == "" @ECHO      %9

:doJava_ez390
@java -classpath %~dps0z390.jar -Xrs %J2SEOPTIONS% ez390 %1 %2 %3 %4 %5 %6 %7 %8 %9
