@ECHO OFF

::------------------------
:: configuration
::set LMiterations=1000  -> SET at configuration.bat
::set YEARS=%2  -> SET at configuration.bat
::set SAMPLES=%3 -> SET at configuration.bat
::set FARM_NUM=2000 -> SET at configuration.bat
::set GAMS="%GAMS_ROOT%\gams.exe" -> SET at configuration.bat
::SET GAMS_ROOT=C:\GAMS\win64\24.0 -> SET at configuration.bat

set RESULTS_FOLDER=".\results\sample\"
set ROUND=%1

cls

echo ------------------------------------------------------------
echo SIMULATION WITH SAMPLE FARMS
echo Initializing Data
echo ------------------------------------------------------------

:: Run init data
java -jar "%cd%/samplingFarms.jar" %FARM_NUM% %SAMPLES% "./data/sampling.txt"
%GAMS% initData.sampling.gms o=".\%LOGDIR%\initData.sample.%ROUND%.lst" --log=%LOGDIR% Lf=".\%LOGDIR%\initData.sample.%ROUND%.log" Lo=2

:: Loop simulation years
for /l %%t in (1, 1, %YEARS%) do (

	echo.
	echo ------------------------------------------------------------
	echo Round %%t
	echo ------------------------------------------------------------

   echo.
   echo ----------------------Crop Plan Phase
   %GAMS% crop_plan.gms --t=%%t o=".\%LOGDIR%\crop_plan.%%t.lst" Lf=".\%LOGDIR%\crop_plan.sample.%%t.log" Lo=2
   
   echo.
   echo ----------------------Production Realization Phase
   java -jar "%cd%/productionRealization.jar" "./data/crops.txt" "./data/yields.txt" "./data/prices.txt" "./data/rnd/%ROUND%.prices.txt" "./data/rnd/%ROUND%.prices.pointer.txt"
   
   echo.
   echo ----------------------Update Accounts Phase
   %GAMS% update_accounts.gms --t=%%t o=".\%LOGDIR%\update_accounts.%%t.lst" Lf=".\%LOGDIR%\update_accounts.sample.%%t.log" Lo=2
   
   echo.
   echo ----------------------LandMarket Phase
   java -jar "%cd%/landMarket.jar" "./data/LandMarket.input.txt" "./data/landMarket.output.txt" %LMiterations% "./%LOGDIR%/landMarket.%%t.txt" "./data/rnd/%ROUND%.lm.txt" "./data/rnd/%ROUND%.lm.pointer.txt"
   
)

echo.
echo ------------------------------------------------------------
echo Transforming Results
echo ------------------------------------------------------------

 %GAMS% write_results_forR.gms o=".\%LOGDIR%\write_results_forR.sample.%ROUND%.lst" --t=%YEARS% --RES=%RESULTS_FOLDER% --REP=%ROUND% 