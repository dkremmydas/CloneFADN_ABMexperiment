@ECHO OFF

::------------------------
:: configuration
call configuration.bat


::------------------------
::create current directory with double backslash
SET ccd=%cd:\=\\%



::------------------------
::create initial R data
%Rscript% -e "setwd('%ccd%');data.full=data.frame(t=seq(1,%YEARS%));save(data.full,file='results/data.full');"
%Rscript% -e "setwd('%ccd%');data.sample=data.frame(t=seq(1,%YEARS%));save(data.sample,file='results/data.sample');"

::create PRNG (pseudo numbers) for prices
%Rscript% -e "setwd('%ccd%');r=rnorm(%randomNumbersPerRepetition_Prices%*%repetitions%,0,.1);chunks <- split(r, ceiling(seq_along(r)/%randomNumbersPerRepetition%));for(n in names(chunks)) {write(chunks[[n]],file=paste('data/rnd/',n,'.prices.txt',sep=''),ncolumns = 1);write(c(1),file=paste('data/rnd/',n,'.prices.pointer.txt',sep=''),ncolumns = 1)}"

::create PRNG (pseudo numbers) for Lm
%Rscript% -e "setwd('%ccd%');r=rlnorm(%randomNumbersPerRepetition_LandMarket%*%repetitions%,0,.5);chunks <- split(r, ceiling(seq_along(r)/%randomNumbersPerRepetition%));for(n in names(chunks)) {write(chunks[[n]],file=paste('data/rnd/',n,'.prices.txt',sep=''),ncolumns = 1);write(c(1),file=paste('data/rnd/',n,'.prices.pointer.txt',sep=''),ncolumns = 1)}"


::------------------------
::run 50 simulations full
for /l %%t in (1, 1, %repetitions%) do (

	runSimulation.full.bat %%t %YEARS%
	%Rscript% -e "library(reshape2);library(plyr);library(ggplot2);library(scales);root='./results/full/';setwd('%ccd%');d = read.table(paste(root,'economics.txt', sep=''),sep='\t',header = T);falive=dcast(d, time~variable,subset = .(variable=='active' & value==1));load('results/data.full');data.full$rep%%t=falive$active;save(data.full,file='results/data.full');"
	
	::reset rng cur position
	%Rscript% -e "setwd('%ccd%');write(c(1),file=paste('data/rnd/%%t.pointer.txt',sep=''),ncolumns = 1);}"

	runSimulation.sampled.bat %%t %YEARS% %SAMPLES%
	%Rscript% -e "library(reshape2);library(plyr);library(ggplot2);library(scales);root='./results/sample/';setwd('%ccd%');d = read.table(paste(root,'economics.txt', sep=''),sep='\t',header = T);falive=dcast(d, time~variable,subset = .(variable=='active' & value==1));load('results/data.sample');data.sample$rep%%t=falive$active;save(data.sample,file='results/data.sample');"
)
