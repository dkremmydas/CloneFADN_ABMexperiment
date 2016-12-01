@ECHO OFF


SET Rscript="C:\Program Files\R\R-3.3.1\bin\Rscript.exe"

::acer laptop
SET GAMS_ROOT=C:\GAMS\win64\24.0
::pc@aua work -------------------------
::SET GAMS_ROOT=D:\gams24.0

set GAMS="%GAMS_ROOT%\gams.exe"



SET repetitions=12
SET YEARS=6
set FARM_NUM=2000
set SAMPLES=200

SET randomNumbersPerRepetition_Prices=200

SET randomNumbersPerRepetition_LandMarket=400
set LMiterations=1000 