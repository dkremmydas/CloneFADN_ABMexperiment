library(reshape2);
library(plyr);
library(ggplot2);
library(scales);

root.sample='../results.SAMPLE20.REP12/sample/';
root.full='../results.SAMPLE20.REP12/full/';
root=root.full;

rep=1;

#############################
#FARM ECONOMICS
#############################
d = read.table(paste(root,"economics.",rep,".txt", sep=""),sep="\t",header = T)
ecMean=dcast(d, time~variable, mean)
falive=dcast(d, time~variable,subset = .(variable=="active" & value==1)) #number of active farms
plot(falive)
cpt=dcast(d, time~variable,sum,subset = .(variable %in% c("cp_COT","cp_DW","cp_MZE","cp_SFL","cp_TOB"))) #crop plans

#############################
#LAND
#############################
d2 = read.table(paste(root,"landMarket.",rep,".txt", sep=""),sep="\t",header = T)
dcast(d2, time~variable, sum, subset = .(variable %in% c("Ld","Ls","rentIn","rentOut")))

#############################
#INFORMATION
#############################
d3 = read.table(paste(root,"information.",rep,".txt", sep=""),sep="\t",header = T)
levels(d3$crop)<-trimws(levels(d3$crop))
pt=dcast(d3, time~crop+variable,subset=.(variable=="price"))


#############################
#PROCESS RESULTS FROM exp_compare_alive_Farms.bat
#############################

#Compare Number of Farms-alive
load("../results/data.sample");load("../results/data.full");
cbind(data.full,data.sample)

mean.sd.sample50=data.frame(full.mean=apply(data.full,1,mean),full.sd=apply(data.full,1,sd),
                sample.mean=apply(data.sample,1,mean),sample.sd=apply(data.sample,1,sd)
               );
mean.sd.sample50
save(mean.sd.sample50,file="mean.sd.sample50");

comp.sample50=data.frame(t=data.full$t);
for(i in c(1:10)) {s=paste("rep",i,sep="");comp.sample50[,s]=data.full[,s]-data.sample[,s];}
comp.sample50
save(comp.sample50,file="comp.sample50");

###
#Compare Farm plans over all repetitions
#calculate % deviation of full-sample for each repetition
fp.comp=data.frame(rep=numeric(),time=numeric(),variable=factor(),value=numeric());
for(r in c(1:12)) {
  rep=r;
  d.sample = read.table(paste(root.sample,"economics.",rep,".txt", sep=""),sep="\t",header = T)
  d.full = read.table(paste(root.full,"economics.",rep,".txt", sep=""),sep="\t",header = T)
  ecMean.sample=dcast(d.sample, time~variable, sum)
  ecMean.full=dcast(d.full, time~variable, sum)
  t=ecMean.full$time;
  rr=(ecMean.full-ecMean.sample)/ecMean.full;
  rr$time=t;
  rr.melted=melt(rr,id.vars = c('time'));
  rr.melted$rep=rep;
  fp.comp=rbind(fp.comp,rr.melted);
}
write.table(fp.comp,file="clipboard-65000",sep="\t",row.names = F)


#############################
#PLOT CROP PLAN TIME SERIES
#############################

############### 
#Price
ggplot(data=d3[d3$variable=="price",],
       aes(x=time,
           color=crop,
           y=value)
)+
  geom_line()+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))+
  ylab("PRICE");

############### 
#plot crop plan aggregates (line)
ggplot(data=melt(cpt,id.vars = "time"),
       aes(x=time,
           color=variable,
           y=value)
)+
  geom_line()+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))+
  ylab("Production in Tonnes");

###############
#plot crop plan aggregates (stacked bar)
ggplot(data=melt(cpt,id.vars = "time"),
       aes(x=time,
           fill=variable,
           y=value)
)+
  geom_bar(position = "fill",stat = "identity") + 
  scale_y_continuous(labels = percent_format())+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))+
  ylab("Production in Tonnes");

###############
#plot crop plan aggregates (stacked bar) + prices
ggplot()+
  geom_bar(data=melt(cpt,id.vars = "time"),aes(x=time,fill=variable,y=value),position = "fill",stat = "identity")+
  geom_line(data=d3[d3$variable=="price",],aes(x=time,color=crop,y=value))+ 
  scale_y_continuous(labels = percent_format())+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))+
  ylab("Production in Tonnes");
