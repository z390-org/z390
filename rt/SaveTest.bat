@ECHO OFF
SETLOCAL

SET dirWork=test
SET dirRtWork=rt\%dirWork%
SET dirRtSaved=%dirRtWork%\save
SET dirRtDiffs=%dirRtWork%\diff

ECHO.
ECHO RT Save Test - Clean %dirRtDiffs% and save rt-work files to %dirRtSaved%

ECHO.
ECHO RT Save Test - Go one level up to z390 main program directory
PUSHD ..

ECHO.
ECHO RT Save Test - Creating rt-diff and rt-save directories (if necessary).
IF NOT EXIST %dirRtWork%\nul  MKDIR %dirRtWork%
IF NOT EXIST %dirRtDiffs%\nul MKDIR %dirRtDiffs%
IF NOT EXIST %dirRtSaved%\nul MKDIR %dirRtSaved%

ECHO.
ECHO RT Save Test - Erasing previous rt-diff files in %dirRtDiffs%
ERASE /Q %dirRtDiffs%\*.*

ECHO.
ECHO RT Save Test - Erasing previous rt-save files in %dirRtSaved%
ERASE /Q %dirRtSaved%\*.*

ECHO.
ECHO RT Save Test - Copying working files to rt-save in %dirRtSaved%
COPY %dirRtWork%\*.* %dirRtSaved%

ECHO.
ECHO RT Save Test - Cleaing working directory %dirWork%
CALL .\rt\ClearDir.bat %dirRtWork%

ECHO.
ECHO RT Save Test - Going back to rt working directory
POPD
ENDLOCAL

ECHO.
ECHO RT Save Test - Finished!
