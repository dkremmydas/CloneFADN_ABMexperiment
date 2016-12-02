library(reshape2);
library(plyr);
library(ggplot2);
library(scales);

root='../results/RUN.years7-samples200.20161202_01/';
root.sample=paste(root,'sample/',sep="");
root.full=paste(root,'full/',sep="");

rep=12; #number of repetitions



#load all data in land market
d.all.lm=data.frame(rep=numeric(),time=numeric(),type=factor(),variable=factor(),value=numeric());
for(r in c(1:rep)) {
  d.sample = read.table(paste(root.sample,"landMarket.",r,".txt", sep=""),sep="\t",header = T)
  d.full = read.table(paste(root.full,"landMarket.",r,".txt", sep=""),sep="\t",header = T)
  d.sample$type="sample";d.full$type="full";
  d.full$rep=r;d.sample$rep=r;
  d.all.lm=rbind(d.all.lm,d.full,d.sample);
}
d.all.lm.sumf=dcast(d.all.lm,value.var = "value",time+type+rep+variable~value,sum);
ggplot(data=d.all.lm.sumf, #line of land market properties
       aes(x=time,
           y=value)
)+
  geom_line(aes(color=rep,group=rep))+
  facet_grid(type+.~variable);


#load all data in information
d.all.info=data.frame(rep=numeric(),time=numeric(),type=factor(),variable=factor(),value=numeric());
for(r in c(1:rep)) {
  d.sample = read.table(paste(root.sample,"information.",r,".txt", sep=""),sep="\t",header = T)
  d.full = read.table(paste(root.full,"information.",r,".txt", sep=""),sep="\t",header = T)
  d.sample$type="sample";d.full$type="full";
  d.full$rep=r;d.sample$rep=r;
  d.all.info=rbind(d.all.info,d.full,d.sample);
}
prices=dcast(d.all.info,time+rep+type+crop~variable,subset=.(variable=="price"),sum)
prices$type=factor(prices$type);prices$crop=factor(prices$crop);
ggplot(data=prices, #line of how prices are evolving
       aes(x=time,
           y=price)
)+
  geom_line(aes(color=rep,group=rep))+
  facet_grid(type+.~crop);


#load all data in economics
d.all.economics=data.frame(rep=numeric(),time=numeric(),type=factor(),variable=factor(),value=numeric());
for(r in c(1:rep)) {
  d.sample = read.table(paste(root.sample,"economics.",r,".txt", sep=""),sep="\t",header = T)
  d.full = read.table(paste(root.full,"economics.",r,".txt", sep=""),sep="\t",header = T)
  d.sample$type="sample";d.full$type="full";
  d.full$rep=r;d.sample$rep=r;
  d.all.economics=rbind(d.all.economics,d.full,d.sample);
}

#Compare Number of Farms-alive
alive=dcast(d.all.economics,time+rep+type~variable,subset=.(variable=="active"),sum)
alive$type=factor(alive$type);

ggplot(data=alive, #line of how alive farms are evolving
          aes(x=time,
              y=active)
)+
  geom_line(aes(color=rep,group=rep))+
  facet_grid(.~type);




###
#Compare Farm plans over all repetitions
#calculate % deviation of full-sample for each repetition
fp.comp=data.frame(rep=numeric(),time=numeric(),variable=factor(),value=numeric());
for(r in c(1:rep)) {
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

fp.comp.abs=fp.comp; 
fp.comp.abs$value=abs(fp.comp.abs$value);

dcast(fp.comp,formula = time~variable,median) #mean diff ove repetitions for each time
dcast(fp.comp.abs,formula = time+rep~variable,median) #diff for each time-rep

fp.comp.abs[(!is.na(fp.comp.abs$value)) & (fp.comp.abs$value>1),"value"]=1.1;
fp.comp.abs[fp.comp.abs$value=="Inf","value"]=1.1;
g1=ggplot(data=fp.comp.abs[fp.comp.abs$variable %in% c("cp_COT","cp_DW","cp_MZE","cp_SFL","cp_TOB"),], #points diff in log scle
       aes(x=time,
           color=rep,
           y=value)
)+
  geom_point()+
  facet_grid(.~variable);

g1

ggplot(data=fp.comp.abs, #boxplot of diff in log scle
       aes(x=time,
           color=rep,
           y=log(value))
)+
  geom_point()+geom_jitter()+
  facet_grid(.~variable);

ggplot(data=fp.comp.abs, #boxplot of diff
       aes(x=time,
           color=time,
           y=value)
)+
  geom_violin()+
  facet_grid(.~variable+time);


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
