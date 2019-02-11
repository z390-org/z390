@ECHO OFF
ECHO.
ECHO RT ClearDir - Remove all generated files by extension from directory %1

IF "%1" == "" (
	@ECHO.
	@ECHO RT ClearDir - Missing directory parameter!
	GOTO clrEnd
)

IF NOT EXIST %1\nul (
	@ECHO.
	@ECHO RT ClearDir - Cannot find given directory!
	GOTO clrEnd
)

IF EXIST %1\*.BAK @erase %1\*.BAK
IF EXIST %1\*.BAL @erase %1\*.BAL
IF EXIST %1\*.ERR @erase %1\*.ERR
IF EXIST %1\*.PCH @erase %1\*.PCH
IF EXIST %1\*.PRN @erase %1\*.PRN
IF EXIST %1\*.OBJ @erase %1\*.OBJ
IF EXIST %1\*.LST @erase %1\*.LST
IF EXIST %1\*.390 @erase %1\*.390
IF EXIST %1\*.LOG @erase %1\*.LOG
IF EXIST %1\*.STA @erase %1\*.STA
IF EXIST %1\*.TR? @erase %1\*.TR?
IF EXIST %1\*.XPR @erase %1\*.XPR
IF EXIST %1\*.TPH @erase %1\*.TPH
IF EXIST %1\*.XPT @erase %1\*.XPT

ECHO.
ECHO RT ClearDir - Done.

:clrEnd
