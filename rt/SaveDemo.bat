@ECHO OFF
SETLOCAL

SET dirWork=demo
SET dirRtWork=rt\%dirWork%
SET dirRtSaved=%dirRtWork%\save
SET dirRtDiffs=%dirRtWork%\diff

ECHO.
ECHO RT Save Demo - Clean %dirRtDiffs% and save rt-work files to %dirRtSaved%

ECHO.
ECHO RT Save Demo - Go one level up to z390 main program directory
PUSHD ..

ECHO.
ECHO RT Save Demo - Creating rt-diff and rt-save directories (if necessary).
IF NOT EXIST %dirRtWork%\nul   MKDIR %dirRtWork%
IF NOT EXIST %dirRtDiffs%\nul  MKDIR %dirRtDiffs%
IF NOT EXIST %dirRtSaved%\nul  MKDIR %dirRtSaved%

ECHO.
ECHO RT Save Demo - Erasing previous rt-diff files in %dirRtDiffs%
ERASE /Q %dirRtDiffs%\*.*

ECHO.
ECHO RT Save Demo - Erasing previous rt-save files in %dirRtSaved%
ERASE /Q %dirRtSaved%\*.*

ECHO.
ECHO RT Save Demo - Copying working files to rt-save in %dirRtSaved%
COPY %dirWork%\*.* %dirRtSaved%

ECHO.
ECHO RT Save Demo - Cleaing working directory %dirWork%
CALL .\rt\ClearDir.bat %dirWork%

ECHO.
ECHO RT Save Demo - Going back to rt working directory
POPD
ENDLOCAL

ECHO.
ECHO RT Save Demo - Finished!
