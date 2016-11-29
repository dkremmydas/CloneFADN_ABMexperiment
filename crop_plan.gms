$ontext
Crop pland module
A classic MP farm model
$offtext

*data definitions are included there
$include model.definitions.gms


$GDXin "./data/data.gdx"
$load rql,vc,sfp,LaO,Lb,Wc,wl,age,consN,fmembers,farm_active
$GDXIN

$GDXin "./data/results.gdx"
$load results
$GDXIN

*load yields and prices (of previous years)
parameter ly(c) /
$include  "./data/yields.txt"
/;
y(c)=ly(c);

parameter lp(c) /
$include  "./data/prices.txt"
/;
p(c)=lp(c);


*initial state
$if "%t%" == "1"
results('economic_results','1',f,'wc')=Wc(f);


*****************************************
$if "%t%" == "1" $goto initLaC

*read LandOut and update land to cultivate and working capital
$include "./data/landMarket.output.txt";

LaRi(f)=LandMarketOut(f,"rentIn");
LaRo(f)=LandMarketOut(f,"rentOut");

LaC(f)=LaO(f)+LaRi(f)-LaRo(f);
LaC(f)$(LaC(f)<0)=0;
LaC(f)$(farm_active(f) eq 0)=0;

Wc(f) = Wc(f)+LandMarketOut(f,"cash");


results('landMarketResults','%t%',f,"rentIn")=LandMarketOut(f,"rentIn");
results('landMarketResults','%t%',f,"rentOut")=LandMarketOut(f,"rentOut");
results('landMarketResults','%t%',f,"cash")=LandMarketOut(f,"cash");
*****************************************

*****************************************
$if Not "%t%" == "1" $goto runModel
$label initLaC
LaC(f)=LaO(f);
*****************************************

*****************************************
$label runModel

$if Not "%t%" == "1" results('economic_results','%t%',f,'Lac')=LaC(f);
$if "%t%" == "1" results('economic_results','1',f,'Lac')=LaC(f);

** Production Plan decision
  Solve Problem using LP maximizing z;
  results('crop_plans','%t%',f,c)=xC.l(c,f);
  results('foreignLabor','%t%',f,"forLabor")=xL.l(f);
  results('model_attributes','%t%',"crop_plan_","Modelstat")=Problem.Modelstat;
  results('model_attributes','%t%',"crop_plan_","etSolve")=Problem.etSolve;

** update any other info
age(f)=age(f)+1;



execute_unload './data/data.gdx', y,rql,p,vc,sfp,LaO,Lb,Wc,wl,age,consN,fmembers,farm_active,xC.l,xL.l;

execute_unload './data/results.gdx', results;









