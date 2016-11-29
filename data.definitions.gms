Sets
c "crops" /dw,mze,sfl,cot,tob/
f "farms" /f1*f2000/
;


Parameters
y(c) "Yield of crop c on farm f (tn/ha)"
rql(c) "Required human labor for crop c (hours/ha)"
p(c) "the price of crop c (euro/tn)"

vc(c,f) "Variable cost of farm f (euro/ha)"
sfp(f) "SFP per ha (euro/ha)"
LaO(f) "owned land of farm f (ha)"
Lb(f) "available family labor (hhours)"
Wc(f) "available capital (euros)"

age(f) "the age of the farmer (years)"
fmembers(f) "number of family members (number of humans)"

farm_active(f) "Is the farm active? (boolean)"
;

*Land Market
Parameters
 LaRi(f) "Land rented In (ha)"
 LaRo(f) "Land rented Out (ha)"
 LaC(f) "Land cultivated (ha)"
 LandMarketIn(f,*) "Table to save LandMarketIn"
 LandMarketOut(f,*) "Table to read LandMarketOut"
;


Scalar wl "foreign labor wage per hour (euro/hhours)";

Scalar consN "Consuming needs per family member for one year (euro/human)";

PARAMETER results(*,*,*,*);
