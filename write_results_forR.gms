$ontext
Files shall be easily read by R-reshape package
$offtext

*data definitions are included there
$include model.definitions.gms

$GDXin "./data/results.gdx"
$load results
$GDXIN

SET t /1*%t%/;

*economics results
file ecR /"%RES%economics.%REP%.txt"/;
put ecR;
put "id","%system.tab%","time","%system.tab%","variable","%system.tab%","value";put /;
loop((f,t),
 put f.tl,"%system.tab%",t.tl,"%system.tab%","wc","%system.tab%",results("economic_results",t,f,"wc");put /;
 put f.tl,"%system.tab%",t.tl,"%system.tab%","active","%system.tab%",results("economic_results",t,f,"active");put /;
 put f.tl,"%system.tab%",t.tl,"%system.tab%","LaC","%system.tab%",results("economic_results",t,f,"LaC");put /;
 put f.tl,"%system.tab%",t.tl,"%system.tab%","forL","%system.tab%",results("foreignLabor",t,f,"forLabor");put /;

 put f.tl,"%system.tab%",t.tl,"%system.tab%","cp_DW","%system.tab%",results("crop_plans",t,f,"dw");put /;
 put f.tl,"%system.tab%",t.tl,"%system.tab%","cp_MZE","%system.tab%",results("crop_plans",t,f,"mze");put /;
 put f.tl,"%system.tab%",t.tl,"%system.tab%","cp_SFL","%system.tab%",results("crop_plans",t,f,"sfl");put /;
 put f.tl,"%system.tab%",t.tl,"%system.tab%","cp_COT","%system.tab%",results("crop_plans",t,f,"cot");put /;
 put f.tl,"%system.tab%",t.tl,"%system.tab%","cp_TOB","%system.tab%",results("crop_plans",t,f,"tob");put /;

);
putclose;

*land market
file lmR /"%RES%landMarket.%REP%.txt"/;
put lmR;
put "id","%system.tab%","time","%system.tab%","variable","%system.tab%","value";put /;
loop((f,t),
*LandInput
 put f.tl,"%system.tab%",t.tl,"%system.tab%","wta","%system.tab%",results("landMarketInput",t,f,"wta");put /;
 put f.tl,"%system.tab%",t.tl,"%system.tab%","Ls","%system.tab%",results("landMarketInput",t,f,"Ls");put /;
 put f.tl,"%system.tab%",t.tl,"%system.tab%","Ld","%system.tab%",results("landMarketInput",t,f,"Ld");put /;
 put f.tl,"%system.tab%",t.tl,"%system.tab%","wtp","%system.tab%",results("landMarketInput",t,f,"wtp");put /;
*LandOutput
 put f.tl,"%system.tab%",t.tl,"%system.tab%","rentIn","%system.tab%",results("landMarketResults",t,f,"rentIn");put /;
 put f.tl,"%system.tab%",t.tl,"%system.tab%","rentOut","%system.tab%",results("landMarketResults",t,f,"rentOut");put /;
 put f.tl,"%system.tab%",t.tl,"%system.tab%","cash","%system.tab%",results("landMarketResults",t,f,"cash");put /;

);
putclose;


*information
file iR /"%RES%information.%REP%.txt"/;
put iR;
put "crop","%system.tab%","time","%system.tab%","variable","%system.tab%","value";put /;
loop((c,t),

 put c.tl,"%system.tab%",t.tl,"%system.tab%","price","%system.tab%",results("environment",t,"prices",c);put /;
 put c.tl,"%system.tab%",t.tl,"%system.tab%","yield","%system.tab%",results("environment",t,"yields",c);put /;

);
putclose;
