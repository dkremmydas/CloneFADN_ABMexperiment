
SET Rscript="C:\Program Files\R\R-3.3.1\bin\Rscript.exe"

::acer laptop
SET GAMS_ROOT=C:\GAMS\win64\24.0
::pc@aua work -------------------------
::SET GAMS_ROOT=D:\gams24.0

set GAMS="%GAMS_ROOT%\gams.exe"

::create current directory with double backslash
SET ccd=%cd:\=\\%
SET LOGDIR=log



SET repetitions=15
SET YEARS=10
set FARM_NUM=2000
set SAMPLES=20

SET randomNumbersPerRepetition_Prices=200

SET randomNumbersPerRepetition_LandMarket=90000
set LMiterations=1000 