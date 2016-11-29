*data definitions are included there
$include model.definitions.gms


$GDXin "./data/data.gdx"
$load rql,vc,sfp,LaO,Lb,Wc,wl,age,consN,fmembers,farm_active,xC,xL
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


*Compute real profit and incorporate into working capital
loop(c,
    Wc(f)$(farm_active(f) eq 1) =  Wc(f) + xC.l(c,f)*(y(c)*p(c)-vc(c,f)+sfp(f));
);
Wc(f)$(farm_active(f) eq 1) = Wc(f) - xL.l(f)*wl ;

parameter OpProfit(f) "Wc before consuming";
OpProfit(f)$(farm_active(f) eq 1)=Wc(f);

*substract consuming needs
Wc(f) = Wc(f) - consN*fmembers(F);

*Farms that cannot farm are set to farm_active=0
farm_active(f)$(Wc(f)<10) = 0;

results('economic_results','%t%',f,'WCbeforeCons')=OpProfit(f);
results('economic_results','%t%',f,'wc')=Wc(f);
results('economic_results','%t%',f,'active')=farm_active(f);
results('environment','%t%','yields',c)=y(c);
results('environment','%t%','prices',c)=p(c);


execute_unload './data/data.gdx', rql,vc,sfp,LaO,Lb,Wc,wl,age,consN,fmembers,farm_active;


*Calculate shadow prices for land (with real prices and yields)
LaC(f)=LaO(f);
Solve Problem using LP maximizing z;


LandMarketIn(f,"Ls")=LaO(f);

LandMarketIn(f,"wta")=0;
LandMarketIn(f,"wta")$(farm_active(f) eq 1)=1.3*land_constraint.m(f);

LandMarketIn(f,"wtp")=0;
LandMarketIn(f,"wtp")$(farm_active(f) eq 1)=land_constraint.m(f);

LandMarketIn(f,"Ld")=0;
LandMarketIn(f,"Ld")$(LandMarketIn(f,"wtp")>0)=0.3*Wc(f)/LandMarketIn(f,"wtp");




file lmF_i /"./data/LandMarket.input.txt"/;
put lmF_i;
 loop(f,
  put f.tl,"%system.tab%",LandMarketIn(f,"Ls"),"%system.tab%",LandMarketIn(f,"wta"),"%system.tab%",LandMarketIn(f,"Ld"),"%system.tab%",LandMarketIn(f,"wtp"); put /;
 );
putclose;

results('landMarketInput','%t%',f,"Ls")=LandMarketIn(f,"Ls");
results('landMarketInput','%t%',f,"wta")=LandMarketIn(f,"wta");
results('landMarketInput','%t%',f,"Ld")=LandMarketIn(f,"Ld");
results('landMarketInput','%t%',f,"wtp")=LandMarketIn(f,"wtp");


execute_unload './data/results.gdx', results;
