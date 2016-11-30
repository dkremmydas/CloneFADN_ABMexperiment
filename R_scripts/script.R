#Load FADN 2012 data to get some real dat

library(fadnUtils);
data(package="fadnUtils","ELL_2012");

add.suffix=function(x,suffix) {
  r=x;
  for(n in 1:length(x)) {
    r[n]=paste(r[n],suffix,sep="");
  }
  return(r)
}

add.prefix=function(x,prefix) {
  r=x;
  for(n in 1:length(x)) {
    r[n]=paste(prefix,r[n],sep="");
  }
  return(r)
}

d=ELL_2012;
t=data.frame(FID=d$tableA$FID,
             NOMOS=d$tableA$NOMOS,
             fadnREGION=d$tableA$fadnREGION,
             TOP=d$tableA$TYPE_OF_FARM_real,
             EC_SIZE=d$tableA$ECONOMIC_SIZE_real,
             WEIGHT=d$tableA$V20,
             LOCATION=d$tableA$LOCATION,
             HEIGHT=d$tableA$ALTITUDE,
             RENTED_UAA=d$tableB$RENTED_UAA,
             TOTAL_UAA=with(d$tableB,RENTED_UAA+OWNED_UAA),
             BIRTH_OWNER=d$tableC$V52,
             OWNER_HOURS=d$tableC$V54,
             FAMILY_HOURS=d$tableC$V73+d$tableC$V76,
             FOREIGN_HOURS=with(d$tableC,V72+V80+V82+V83),
             LABOR_WAGES=d$tableF$V259,
             MACHINE_WAGES=d$tableF$V260,
             OWNED_MACHINE_COSTS=with(d$tableF,V261+V262+V263),
             CROP_COSTS=with(d$tableF,V272+V273+V274+V275+V276+V277),
             SEED_COSTS=with(d$tableF,V272+V273),
             FERTLZR_COSTS=with(d$tableF,V274),
             PROTECT_COSTS=with(d$tableF,V275),
             GEN_COSTS=with(d$tableF,V278+V279+V280+V281+V282+V283+V284),
             RENT=d$tableF$V286,
             INTEREST_PAID=d$tableF$V292
);

k=d$tableK;
k_120=k[k$PRODUCT==120,]; #common wheat=120 (cw)
k_121=k[k$PRODUCT==121,]; #durum wheat=121 (dw)
k_123=k[k$PRODUCT==123,]; #barley=123 (bar)
k_126=k[k$PRODUCT==126,]; #grain maize=126 (mze)
k_127=k[k$PRODUCT==127,]; #rice=127 (rce)
k_129=k[k$PRODUCT==129,]; #protein crops=129 (prc)
k_146=k[k$PRODUCT==146,]; #set aside=146 (sas)
k_332=k[k$PRODUCT==332,]; #sunflower=332 (sfl)
k_331=k[k$PRODUCT==331,]; #rape=331 (rpe)
k_347=k[k$PRODUCT==347,]; #cotton=347 (cot)
k_134=k[k$PRODUCT==134,]; #tobacco=134 (tob)

k_120$YIELD=k_120$PRODUCTION/k_120$AREA;k_120$PRICE=k_120$SALES/k_120$PRODUCTION;
k_121$YIELD=k_121$PRODUCTION/k_121$AREA;k_121$PRICE=k_121$SALES/k_121$PRODUCTION;
k_123$YIELD=k_123$PRODUCTION/k_123$AREA;k_123$PRICE=k_123$SALES/k_123$PRODUCTION;
k_126$YIELD=k_126$PRODUCTION/k_126$AREA;k_126$PRICE=k_126$SALES/k_126$PRODUCTION;
k_127$YIELD=k_127$PRODUCTION/k_127$AREA;k_127$PRICE=k_127$SALES/k_127$PRODUCTION;
k_129$YIELD=k_129$PRODUCTION/k_129$AREA;k_129$PRICE=k_129$SALES/k_129$PRODUCTION;
k_146$YIELD=k_146$PRODUCTION/k_146$AREA;k_146$PRICE=k_146$SALES/k_146$PRODUCTION;
k_331$YIELD=k_331$PRODUCTION/k_331$AREA;k_331$PRICE=k_331$SALES/k_331$PRODUCTION;
k_332$YIELD=k_332$PRODUCTION/k_332$AREA;k_332$PRICE=k_332$SALES/k_332$PRODUCTION;
k_347$YIELD=k_347$PRODUCTION/k_347$AREA;k_347$PRICE=k_347$SALES/k_347$PRODUCTION;
k_134$YIELD=k_134$PRODUCTION/k_134$AREA;k_134$PRICE=k_134$SALES/k_134$PRODUCTION;

names(k_120)[2:13]=add.prefix(names(k_120)[2:13],"cw.");
names(k_121)[2:13]=add.prefix(names(k_121)[2:13],"dw.");
names(k_123)[2:13]=add.prefix(names(k_123)[2:13],"bar.");
names(k_126)[2:13]=add.prefix(names(k_126)[2:13],"mze.");
names(k_127)[2:13]=add.prefix(names(k_127)[2:13],"rce.");
names(k_129)[2:13]=add.prefix(names(k_129)[2:13],"prc.");
names(k_146)[2:13]=add.prefix(names(k_146)[2:13],"sas.");
names(k_331)[2:13]=add.prefix(names(k_331)[2:13],"rpe.")
names(k_332)[2:13]=add.prefix(names(k_332)[2:13],"sfl.")
names(k_347)[2:13]=add.prefix(names(k_347)[2:13],"cot.")
names(k_134)[2:13]=add.prefix(names(k_134)[2:13],"tob.")

t=merge(x=t,y=k_120,by="FID",all.x = T);
t=merge(x=t,y=k_121,by="FID",all.x = T);
t=merge(x=t,y=k_123,by="FID",all.x = T);
t=merge(x=t,y=k_126,by="FID",all.x = T);
t=merge(x=t,y=k_127,by="FID",all.x = T);
t=merge(x=t,y=k_129,by="FID",all.x = T);
t=merge(x=t,y=k_146,by="FID",all.x = T)
t=merge(x=t,y=k_331,by="FID",all.x = T);
t=merge(x=t,y=k_332,by="FID",all.x = T);
t=merge(x=t,y=k_347,by="FID",all.x = T);
t=merge(x=t,y=k_134,by="FID",all.x = T)

t$TOP=as.factor(t$TOP);
t$fadnREGION = as.factor(t$fadnREGION)
t$NOMOS = as.factor(t$NOMOS);
t$EC_SIZE = as.factor(t$EC_SIZE);
t$LOCATION = as.factor(t$LOCATION);
t$HEIGHT = as.factor(t$HEIGHT);
t$FID = as.factor(t$FID);

t$cereals.AREA=rowSums(cbind(t$cw.AREA,t$dw.AREA,t$bar.AREA,
                             t$mze.AREA,t$rce.AREA,t$prc.AREA,
                             t$sas.AREA,t$rpe.AREA,t$sfl.AREA,
                             t$cot.AREA,t$tob.AREA), 
                       na.rm=TRUE)



############################################333
# Case study #2
# keep only Makedoni-Thraki, durum wheat and maize


t=t[t$fadnREGION=="Mak.-Thraki" & (t$TOP %in% c("151","152","153","161","162","163","164","165","166")),]; #select only makedonia thraki

k_accepted=k$FID %in% t$FID;

t_accepted = ((t$cereals.AREA/t$TOTAL_UAA)>.9);
sum(t_accepted) #count number of farms

t=t[t_accepted,];

#extract family labor
write.table(t$OWNER_HOURS+t$FAMILY_HOURS,"clipboard-65000",sep="\t")


#regress find var costs to yields
vcRegress=data.frame(t$FID,t$CROP_COSTS,t$MACHINE_WAGES,t$LABOR_WAGES,t$OWNED_MACHINE_COSTS,
                     t$cw.YIELD,t$dw.YIELD,t$bar.YIELD,t$mze.YIELD,t$rce.YIELD,t$prc.YIELD,
                     t$sas.AREA,t$rpe.AREA,t$sfl.YIELD,t$cot.YIELD,t$tob.YIELD)

reg=lm(data=vcRegress,formula=t.CROP_COSTS~t.cw.YIELD+t.dw.YIELD+t.bar.YIELD+t.mze.YIELD+
         t.rce.YIELD+t.prc.YIELD+t.sas.YIELD+t.rpe.YIELD+t.sfl.YIELD+t.cot.YIELD+t.tob.YIELD);


#check crop co-existence
coex=data.frame(cw=t$cw.AREA>0,dw=t$dw.AREA>0,bar=t$bar.AREA>0,mze=t$mze.AREA>0,rce=t$rce.AREA>0,prc=t$prc.AREA>0,
                sas=t$sas.AREA>0,rpe=t$rpe.AREA>0,sfl=t$sfl.AREA>0,cot=t$cot.AREA>0,tob=t$tob.AREA>0);
coex[is.na(coex)]=FALSE; coex=coex*1;
coex=as.data.frame(lapply(coex,as.factor));

findJointProbability<-function(fir,sec,cr,data,prob=T) {
  #example findJointProbability("dw",c("sw","bar"),coex)
  ind2=(data[,fir]=="1");
  if(sum(ind2)==0) {return(NA);}
  d=data[ind2,];
  dem=nrow(d);
  nom=0;
  for(i in cr[cr!=fir]) {
    if(i %in% sec) {ind=(d[,i]=="1");}
    else {ind=(d[,i]=="0");}
    if(sum(ind)==0) {nom=0;break;}
    d=d[ind,];
    nom=nrow(d);
  }
  if(prob) {return(nom/dem);} else {return(nom);}
}

#calculate all joint probabilities
cr1=c("cw","dw","bar","mze","rce","prc","sas","rpe","sfl","cot","tob");

sz=10230;
crd=data.frame("cw"=numeric(sz),
               "dw"=numeric(sz),
               "bar"=numeric(sz),
               "mze"=numeric(sz),
               "rce"=numeric(sz),
               "prc"=numeric(sz),
               "sas"=numeric(sz),
               "rpe"=numeric(sz),
               "sfl"=numeric(sz),
               "cot"=numeric(sz),
               "tob"=numeric(sz),
               "conP"=numeric(sz)
          );

#construct all combinations for conditional probabilities
tpp=list();
for (c1 in cr1){
  tpp[[c1]]=list();
  cr2=cr1[cr1!=c1];
  tp=list();
  for(c2 in 1:length(cr2)) {
    tp=c(tp,combn(cr2,c2,simplify = F));
  }
  tpp[[c1]]=tp;
}
print(tpp);

#now loop combinations and fill crd
i=1;
for(c1 in names(tpp)) {
  print(c1);
  for(c2 in tpp[[c1]]) {
    for(c3 in c2) {crd[i,c3]=1;}
    crd[i,c1]=2;
    crd[i,"conP"]=findJointProbability(c1,c2,cr1,coex,F);
    i=i+1;
  }
}

write.table(crd,"clipboard-65000",sep="\t");
  


#count non zero
plot(t[,grep(c("YIELD"), names(t))])
cor(t[,grep(c("YIELD"), names(t))],
    use="pairwise.complete.obs")

print(hist(t$mze.PRICE,c(0,12,13:25,90)))
print(hist(t$sfl.PRICE,c(20,35:60,130)))

############################################333
# Case study #1

t=t[t$fadnREGION=="Mak.-Thraki",]; #select only makedonia thraki

#calculate whether farm has dw-only(1),mze-only(2),dw+mze(3),none(0)
t$dwMze=NA;
for(row in 1:nrow(t) ) {
  if((is.na(t[row,"YIELD.dw"]) & (is.na(t[row,"YIELD.mze"])))) {
     t[row,"dwMze"]=0;}
  else if((is.na(t[row,"YIELD.dw"]) & (!is.na(t[row,"YIELD.mze"])))) {
     t[row,"dwMze"]=2;}
  else if((!is.na(t[row,"YIELD.dw"]) & (is.na(t[row,"YIELD.mze"])))) {
    t[row,"dwMze"]=1;}
  else {
    t[row,"dwMze"]=3;}
}
t$dwMze=as.factor(t$dwMze);
table(t$dwMze)
plot(t[t$dwMze=="3",c("YIELD.dw","YIELD.mze")])

t=t[t$dwMze=="1" | t$dwMze=="2",]
t$AREA=NA;
t[t$dwMze=="1","AREA"]=t[t$dwMze=="1","AREA.dw"];t[t$dwMze=="2","AREA"]=t[t$dwMze=="2","AREA.mze"];
t$AREA_effec=t$AREA/t$TOTAL_UAA;
write.table(t,"clipboard-65000",sep="\t",row.names = F)

############################################333
# Example from https://www.r-bloggers.com/modelling-dependence-with-copulas-in-r/
library(MASS)
set.seed(100)

m <- 3
n <- 2000
sigma <- matrix(c(1, 0.4, 0.2,
                  0.4, 1, -0.8,
                  0.2, -0.8, 1), 
                nrow=3)
z <- mvrnorm(n,mu=rep(0, m),Sigma=sigma,empirical=T) #create multivariate distribution

library(psych)
cor(z,method='spearman')
pairs.panels(z)

u <- pnorm(z) #pnorm: returns the cumulative density function
pairs.panels(u)
