$include data.definitions.gms

$call del ".\data\data.gdx"
$call del ".\data\results.gdx"

*display f;

y("dw")=3.5;y("mze")=9;y("sfl")=5;y("cot")=1.9;y("tob")=2;
rql("dw")=110;rql("mze")=170; rql("sfl")=120; rql("cot")=200; rql("tob")=900;
p("dw")=200;p("mze")=250; p("sfl")=250; p("cot")=1240; p("tob")=700;
*p("dw")=250;p("mze")=300; p("sfl")=300; p("cot")=1540; p("tob")=1000;

wl=5;
consN=3000;

farm_active(f)=1;

***************************************
*Load and Prepare Data

*Prepare data
parameter xlData(f,*,*);
$call "Gdxxrw ./data/data.2000.xlsx output=tmp1 par=xlData Rng=template!A1:L2004 cdim=2 rdim=1" 
$GDXin tmp1.gdx
$load xlData
$GDXIN
*display xlData;
$call del tmp1.gdx

LaO(f)=xlData(f,'farm','land');
age(f)=xlData(f,'farm','age');
Lb(f)=xlData(f,'farm','famL');
vc(c,f)= xlData(f,c,'varc');
Wc(f)= xlData(f,'farm','liquid');
sfp(f)= xlData(f,'farm','subs');
fmembers(f) =  xlData(f,'farm','members');


**********************************
* RANDOM SAMPLING
**********************************
alias(f,ff);
parameters LaO2(f),age2(f),Lb2(f),vc2(c,f),Wc2(f),sfp2(f),fmembers2(f);

set sample(f,ff)  /
$include "./data/sampling.txt"
/;
display sample;
loop((f,ff),
  LaO2(f)$(sample(f,ff))=LaO(ff);
  age2(f)$(sample(f,ff))=age(ff);
  Lb2(f)$(sample(f,ff))= Lb(ff);
  vc2(c,f)$(sample(f,ff))= vc(c,ff);
  Wc2(f)$(sample(f,ff))= Wc(ff) ;
  sfp2(f)$(sample(f,ff))= sfp(ff) ;
  fmembers2(f)$(sample(f,ff))= fmembers(ff) ;
);

LaO(f)=LaO2(f);age(f)=age2(f);Lb(f)=Lb2(f);
vc(c,f)=vc2(c,f);Wc(f)=Wc2(f);sfp(f)=sfp2(f);
fmembers(f) =fmembers2(f);

**********************************

** Output crop types
file prF_i /"./data/crops.txt"/;
put prF_i;
loop(c, put c.tl,put /;);

*Output of init yields, prices
file yields_f /"./data/yields.txt"/;

put yields_f;
loop(c, put c.tl,"%system.tab%",y(c); put /;);
put /;
putclose;

file prices_f /"./data/prices.txt"/;
put prices_f;
loop(c, put c.tl,"%system.tab%",p(c); put /;);
put /;
putclose;

results('initialData','0',f,"LaO")=LaO(f);
results('initialData','0',f,"age")=age(f);
results('initialData','0',f,"Lb")=Lb(f);
results('initialData','0',f,"Wc")=Wc(f);
results('initialData','0',f,"sfp")=sfp(f);
results('initialData','0',f,"fmembers")=fmembers(f);
results('initialData','0',f,"farm_active")=farm_active(f);


execute_unload "./data/data.gdx" rql,vc,sfp,LaO,Lb,Wc,wl,age,consN,fmembers,farm_active;

execute_unload "./data/results.gdx",results;
