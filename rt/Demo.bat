@ECHO OFF
SETLOCAL

SET dirWork=demo
SET dirRtWork=.\rt\%dirWork%
SET dirRtSaved=%dirRtWork%\save
SET dirRtDiffs=%dirRtWork%\diff
SET sysTerm=systerm^(%dirWork%\RTDEMO^)
REM SET trace=TRON
REM SET trace=

ECHO.
ECHO RT Demo - Run demo programs in ..\%dirWork% and generate %dirRtDiffs%

ECHO.
ECHO RT Demo - Go one level up to z390 main program directory (step 0 of 19)
PUSHD ..

:demoStep01
ECHO.
ECHO RT Demo - Clearing all working files in working directory %dirWork% (step 1 of 19)
CALL .\rt\ClearDir.bat %dirWork%

:demoStep02
ECHO.
ECHO RT Demo - DEMO.MLC     - WTO 'HELLO WORLD' 4 line macro program (step 2 of 19)
CALL ASMLG %dirWork%\DEMO                notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:demoStep03
ECHO.
ECHO RT Demo - DEMOBMK1.MLC - Benchmark which executes BCT instruction 2 million times for timing purposes (step 3 of 19)
CALL ASMLG %dirWork%\DEMOBMK1            notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:demoStep04
ECHO.
ECHO RT Demo - DEMOBMK2.MLC - Benchmark which executes AXR, BCT 100,000 times for timing purposes (step 4 of 19)
CALL ASMLG %dirWork%\DEMOBMK2            notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:demoStep05
ECHO.
ECHO RT Demo - DEMODFP1.MLC - Show differences in binary floating point and decimal floating point calc. (step 5 of 19)
CALL ASMLG %dirWork%\DEMODFP1            notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:demoStep06
ECHO.
ECHO RT Demo - DEMOM8Q1.MLC - Calculate and display 8 queens chess problem using recursive macro code (step 6 of 19)
CALL MAC   %dirWork%\DEMOM8Q1 nolistcall notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:demoStep07
ECHO.
ECHO RT Demo - DEMOM8Q2.MLC - Calculate and display 8 queens chess problem using recursive macro code (step 7 of 19)
CALL MAC   %dirWork%\DEMOM8Q2 nolistcall notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:demoStep08
ECHO.
ECHO RT Demo - DEMONUM1.MLC - Calculate and display prime numbers to 4000 using conditional macro code (step 8 of 19)
CALL MAC   %dirWork%\DEMONUM1            notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:demoStep09
ECHO.
ECHO RT Demo - DEMONUM2.MLC - Calculate and display prime numbers to 4000 using basic assembler code (step 9 of 19)
CALL ASMLG %dirWork%\DEMONUM2            notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:demoStep10
ECHO.
ECHO RT Demo - DEMOSTR1.MLC - Demo use of structured programming macros (step 10 of 19)
CALL ASMLG %dirWork%\DEMOSTR1            notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:demoStep11
ECHO.
ECHO RT Demo - DEMOWTO1.MLC - WTO 'HELLO WORLD' 4 line macro program (step 11 of 19)
CALL ASMLG %dirWork%\DEMOWTO1            notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:demoStep12
ECHO.
ECHO RT Demo - DEMOWTO2.MLC - Repeat WTO 'HELLO WORLD' 5 times using macro code loop (step 12 of 19)
CALL ASMLG %dirWork%\DEMOWTO2            notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:demoStep13
ECHO.
ECHO RT Demo - SIEVE.MLC    - List primes ending in 999 up to 1,000,000 (step 13 of 19)
CALL ASMLG %dirWork%\SIEVE               notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:demoStep14
ECHO.
ECHO RT Demo - STDDEVLB.MLC - Calculate standard deviation using 128 bit 34 digit BFP floating point instructions (step 14 of 19)
CALL ASMLG %dirWork%\STDDEVLB            notiming stats %%sysTerm%% %1 %2 %3 %4 %5 %6 %7 %8 %9

:demoStep15
ECHO.
ECHO RT Demo - Creating directories %dirRtSaved% and %dirRtDiffs% (if necessary) (step 15 of 19)
IF NOT EXIST %dirRtWork%\nul   MKDIR %dirRtWork%
IF NOT EXIST %dirRtDiffs%\nul  MKDIR %dirRtDiffs%
IF NOT EXIST %dirRtSaved%\nul  MKDIR %dirRtSaved%

:demoStep16
ECHO.
ECHO RT Demo - Cleaning rt diff directory %dirRtDiffs% (step 16 of 19)
ERASE /Q %dirRtDiffs%\*.*

:doCompare
:demoStep17
ECHO.
ECHO RT Demo - Compare %dirWork% files with %dirRtSaved% files and generate %dirRtDiffs% files (step 17 of 19)
ECHO.
java -classpath z390.jar -Xrs %J2SEOPTIONS% DiffRegrTests %dirWork% %dirRtSaved% %dirRtDiffs%

:doListing
:demoStep18
ECHO.
ECHO RT Demo - Displaying ordered listing of %dirRtDiffs% (step 18 of 19)
DIR /OS %dirRtDiffs%

:demoStep19
ECHO.
ECHO RT Demo - Going back to rt working directory (step 19 of 19)
POPD
ENDLOCAL

ECHO RT Demo - Finished!
