@ECHO OFF

::------------------------
:: configuration
::set LMiterations=1000  -> SET at configuration.bat
::set YEARS=%2 -> SET at configuration.bat
::set GAMS="%GAMS_ROOT%\gams.exe" -> SET at configuration.bat
::SET GAMS_ROOT=C:\GAMS\win64\24.0 -> SET at configuration.bat

set RESULTS_FOLDER=".\results\full\"

cls

echo ------------------------------------------------------------
echo Initializing Data
echo ------------------------------------------------------------

:: Run init data
%GAMS% initData.gms o=".\lst\initData.lst"

:: Loop simulation years
for /l %%t in (1, 1, %YEARS%) do (

	echo.
	echo ------------------------------------------------------------
	echo Round %%t
	echo ------------------------------------------------------------

   echo.
   echo ----------------------Crop Plan Phase
   %GAMS% crop_plan.gms --t=%%t o=".\lst\crop_plan.%%t.lst" Lf=".\log\crop_plan.%%t.log"
   
   echo.
   echo ----------------------Production Realization Phase
   java -jar "%cd%/productionRealization.jar" "./data/crops.txt" "./data/yields.txt" "./data/prices.txt" "./data/rnd/%1.txt" "./data/rnd/%1.pointer.txt"
   
   echo.
   echo ----------------------Update Accounts Phase
   %GAMS% update_accounts.gms --t=%%t o=".\lst\update_accounts.%%t.lst" Lf=".\log\update_accounts.%%t.log"
   
   echo.
   echo ----------------------LandMarket Phase
   java -jar "%cd%/landMarket.jar" "./data/LandMarket.input.txt" "./data/landMarket.output.txt" %LMiterations% "./lst/landMarket.%%t.txt"
   
)

echo.
echo ------------------------------------------------------------
echo Transforming Results
echo ------------------------------------------------------------

 %GAMS% write_results_forR.gms --t=%YEARS% --RES=%RESULTS_FOLDER% --REP=%1