@ECHO OFF
SETLOCAL

SET dirWork=assist
SET dirRtWork=rt\%dirWork%
SET dirRtSaved=%dirRtWork%\save
SET dirRtDiffs=%dirRtWork%\diff

ECHO.
ECHO RT Save Assist - Clean %dirRtDiffs% and save rt-work files to %dirRtSaved%

ECHO.
ECHO RT Save Assist - Go one level up to z390 main program directory
PUSHD ..

ECHO.
ECHO RT Save Assist - Creating rt diff and rt save directories (if necessary).
IF NOT EXIST %dirRtWork%\nul   MKDIR %dirRtWork%
IF NOT EXIST %dirRtDiffs%\nul  MKDIR %dirRtDiffs%
IF NOT EXIST %dirRtSaved%\nul  MKDIR %dirRtSaved%

ECHO.
ECHO RT Save Assist - Erasing previous rt-diff files in %dirRtDiffs%
ERASE /Q %dirRtDiffs%\*.*

ECHO.
ECHO RT Save Assist - Erasing previous rt-save files in %dirRtSaved%
ERASE /Q %dirRtSaved%\*.*

ECHO.
ECHO RT Save Assist - Copying working files to rt-save in %dirRtSaved%
COPY %dirWork%\*.* %dirRtSaved%

ECHO.
ECHO RT Save Assist - Cleaing working directory %dirWork%
CALL .\rt\ClearDir.bat %dirWork%

ECHO.
ECHO RT Save Assist - Going back to rt working directory
POPD
ENDLOCAL

ECHO.
ECHO RT Save Assist - Finished!
