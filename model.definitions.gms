$include data.definitions.gms

***************************************
* Model definition

Positive Variables
         xC(c,f) "crop plan (ha)"
         xL(f) "hired foreign labor (hhours)"
;

Variable
         z "objective function value (euro)"
         zF(f) "profit variable of farm f (euro)"
;

Equations
 Obj "the objective function (euro)"
 ObjF(f) "the profit per farm (euro)"
 land_constraint(f) "land constraint (ha)"
 labor_constraint(f) "labor constraint (hhours)"
 wCapital_constraint(f) "capital constraint (euros)"
;

Obj..  sum(f$(farm_active(f) eq 1),zF(f)) =e= z;

ObjF(f)$(farm_active(f) eq 1)..  sum(c, xC(c,f)*(y(c)*p(c)-vc(c,f)))-(wl*xL(f))+sfp(f)*sum(c, xC(c,f)) =e= zF(f);

land_constraint(f)$(farm_active(f) eq 1).. sum(c, xC(c,f)) =l= LaC(f);

labor_constraint(f)$(farm_active(f) eq 1).. sum(c, xC(c,f)*rql(c)) =l= Lb(f)+xL(f);

*wCapital_constraint(f)$(farm_active(f) eq 1)..  sum(c, xC(c,f)*vc(c,f))+(wl*xL(f)) =l= 0.6*(Wc(f)+sfp(f)*sum(c, xC(c,f)));

wCapital_constraint(f)$(farm_active(f) eq 1)..  sum(c, xC(c,f)*vc(c,f))+(wl*xL(f)) =l= 0.9*Wc(f)+(sfp(f)*sum(c, xC(c,f)));


Model Problem /all/;
