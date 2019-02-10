@ECHO OFF
@SETLOCAL

@SET dirWork=demo
@SET dirRtWork=.\rt\%dirWork%
@SET dirRtSaved=%dirRtWork%\save
@SET dirRtDiffs=%dirRtWork%\diff
@SET sysTerm=systerm(%dirWork%\RTDEMO)

@ECHO.
@ECHO RT Demo - Run demo programs in ..\%dirWork% and generate %dirRtDiffs%

@ECHO.
@ECHO RT Demo - Go one level up to z390 main program directory
@PUSHD ..

@ECHO.
@ECHO RT Demo - Clearing all working files in working directory %dirWork%
@CALL .\rt\ClearDir.bat %dirWork%

@CALL ASMLG %dirWork%\DEMO                notiming stats %sysTerm% %1 %2 %3 %4 %5 %6 %7 %8 %9
@CALL ASMLG %dirWork%\DEMOBMK1            notiming stats %sysTerm% %1 %2 %3 %4 %5 %6 %7 %8 %9
@CALL ASMLG %dirWork%\DEMOBMK2            notiming stats %sysTerm% %1 %2 %3 %4 %5 %6 %7 %8 %9
@CALL ASMLG %dirWork%\DEMODFP1            notiming stats %sysTerm% %1 %2 %3 %4 %5 %6 %7 %8 %9
@CALL MAC   %dirWork%\DEMOM8Q1 nolistcall notiming stats %sysTerm% %1 %2 %3 %4 %5 %6 %7 %8 %9
@CALL MAC   %dirWork%\DEMOM8Q2 nolistcall notiming stats %sysTerm% %1 %2 %3 %4 %5 %6 %7 %8 %9
@CALL MAC   %dirWork%\DEMONUM1            notiming stats %sysTerm% %1 %2 %3 %4 %5 %6 %7 %8 %9
@CALL ASMLG %dirWork%\DEMONUM2            notiming stats %sysTerm% %1 %2 %3 %4 %5 %6 %7 %8 %9
@CALL ASMLG %dirWork%\DEMOSTR1            notiming stats %sysTerm% %1 %2 %3 %4 %5 %6 %7 %8 %9
@CALL ASMLG %dirWork%\DEMOWTO1            notiming stats %sysTerm% %1 %2 %3 %4 %5 %6 %7 %8 %9
@CALL ASMLG %dirWork%\DEMOWTO2            notiming stats %sysTerm% %1 %2 %3 %4 %5 %6 %7 %8 %9
@CALL ASMLG %dirWork%\SIEVE               notiming stats %sysTerm% %1 %2 %3 %4 %5 %6 %7 %8 %9
@CALL ASMLG %dirWork%\STDDEVLB            notiming stats %sysTerm% %1 %2 %3 %4 %5 %6 %7 %8 %9

@ECHO.
@ECHO RT Demo - Creating directories %dirRtSaved% and %dirRtDiffs% (if necessary).
@IF NOT EXIST %dirRtWork%\nul   @MKDIR %dirRtWork%
@IF NOT EXIST %dirRtDiffs%\nul  @MKDIR %dirRtDiffs%
@IF NOT EXIST %dirRtSaved%\nul  @MKDIR %dirRtSaved%

@ECHO.
@ECHO RT Demo - Cleaning rt diff directory %dirRtDiffs%
@ERASE /Q %dirRtDiffs%\*.*

:doCompare
@ECHO.
@ECHO RT Demo - Compare %dirWork% files with %dirRtSaved% files and generate %dirRtDiffs% files
@ECHO.
@java -classpath z390.jar -Xrs %J2SEOPTIONS% DiffRegrTests %dirWork% %dirRtSaved% %dirRtDiffs%

:doListing
@ECHO.
@ECHO RT Demo - Displaying ordered listing of %dirRtDiffs%
@DIR /OS %dirRtDiffs%

@ECHO.
@ECHO RT Demo - Going back to rt working directory
@POPD
@ENDLOCAL

@ECHO RT Demo - Finished!
