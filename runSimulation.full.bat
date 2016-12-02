@ECHO OFF

::------------------------
:: configuration
::set LMiterations=1000  -> SET at configuration.bat
::set YEARS=%2 -> SET at configuration.bat
::set GAMS="%GAMS_ROOT%\gams.exe" -> SET at configuration.bat
::SET GAMS_ROOT=C:\GAMS\win64\24.0 -> SET at configuration.bat

set RESULTS_FOLDER=".\results\full\"
set ROUND=%1


echo ------------------------------------------------------------
echo SIMULATION WITH ALL FARMS
echo Initializing Data
echo ------------------------------------------------------------

:: Run init data
%GAMS% initData.full.gms o=".\%LOGDIR%\initData.full.%ROUND%.lst" --log=%LOGDIR% Lf=".\%LOGDIR%\initData.full.%ROUND% .log" Lo=2

:: Loop simulation years
for /l %%t in (1, 1, %YEARS%) do (

	echo.
	echo ------------------------------------------------------------
	echo Round %%t
	echo ------------------------------------------------------------

   echo.
   echo ----------------------Crop Plan Phase
   %GAMS% crop_plan.gms --t=%%t o=".\%LOGDIR%\crop_plan.%%t.lst" Lf=".\%LOGDIR%\crop_plan.full.%%t.log" Lo=2
   
   echo.
   echo ----------------------Production Realization Phase
   java -jar "%cd%/productionRealization.jar" "./data/crops.txt" "./data/yields.txt" "./data/prices.txt" "./data/rnd/%ROUND%.prices.txt" "./data/rnd/%ROUND%.prices.pointer.txt"
   
   echo.
   echo ----------------------Update Accounts Phase
   %GAMS% update_accounts.gms --t=%%t o=".\%LOGDIR%\update_accounts.%%t.lst" Lf=".\%LOGDIR%\update_accounts.full.%%t.log" Lo=2
   
   echo.
   echo ----------------------LandMarket Phase
   java -jar "%cd%/landMarket.jar" "./data/LandMarket.input.txt" "./data/landMarket.output.txt" %LMiterations% "./%LOGDIR%/landMarket.%%t.txt" "./data/rnd/%ROUND%.lm.txt" "./data/rnd/%ROUND%.lm.pointer.txt"
   
)

echo.
echo ------------------------------------------------------------
echo Transforming Results
echo ------------------------------------------------------------

 %GAMS% write_results_forR.gms o=".\%LOGDIR%\write_results_forR.full.%ROUND%.lst" --t=%YEARS% --RES=%RESULTS_FOLDER% --REP=%ROUND%