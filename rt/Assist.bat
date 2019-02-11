@ECHO OFF
SETLOCAL

SET dirWork=assist
SET dirRtWork=rt\%dirWork%
SET dirRtSaved=%dirRtWork%\save
SET dirRtDiffs=%dirRtWork%\diff
SET sysTerm=systerm^(%dirWork%\RTASSIST^)
REM SET trace=TRON
REM SET trace=

ECHO.
ECHO RT Assist - Run %dirWork% programs in ..\%dirWork% and generate %dirRtDiffs%

ECHO.
ECHO RT Assist - Go one level up to z390 main program directory
PUSHD ..

ECHO.
ECHO RT Assist - Clearing all working files in working directory %dirWork%
CALL .\rt\ClearDir.bat %dirWork%

ECHO.
ECHO RT Assist - Running %dirWork% programs...
CALL ASSIST %dirWork%\DEMOAST1 notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL ASSIST %dirWork%\TESTAST1 notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9
CALL ASSIST %dirWork%\SOLP06   notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

ECHO.
ECHO RT Assist - Creating rt-diff and rt-save directories (if necessary).
IF NOT EXIST %dirRtWork%\nul   MKDIR %dirRtWork%
IF NOT EXIST %dirRtDiffs%\nul  MKDIR %dirRtDiffs%
IF NOT EXIST %dirRtSaved%\nul  MKDIR %dirRtSaved%

ECHO.
ECHO RT Assist - Erasing previous diff files in %dirRtDiffs%
ERASE /Q %dirRtDiffs%\*.*

:doCompare
ECHO.
ECHO RT Assist - Compare %dirWork% files with %dirRtSaved% files and generate %dirRtDiffs% files
ECHO.
java -classpath z390.jar -Xrs %J2SEOPTIONS% DiffRegrTests %dirWork% %dirRtSaved% %dirRtDiffs%

:doListing
ECHO.
ECHO RT Assist - Displaying ordered list of %dirRtDiffs%
DIR /OS /P %dirRtDiffs%

ECHO.
ECHO RT Assist - Going back to rt working directory
POPD
ENDLOCAL

ECHO RT Assist - Finished!
