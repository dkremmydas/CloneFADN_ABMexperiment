::@ECHO OFF

::------------------------
:: configuration
call configuration.bat


::------------------------
::create PRNG (pseudo numbers) for prices
%Rscript% -e "setwd('%ccd%');r=rnorm(%randomNumbersPerRepetition_Prices%*%repetitions%,0,.1);chunks <- split(r, ceiling(seq_along(r)/%randomNumbersPerRepetition_Prices%));for(n in names(chunks)) {write(chunks[[n]],file=paste('data/rnd/',n,'.prices.txt',sep=''),ncolumns = 1);write(c(1),file=paste('data/rnd/',n,'.prices.pointer.txt',sep=''),ncolumns = 1)}"

::create PRNG (pseudo numbers) for Lm
%Rscript% -e "setwd('%ccd%');r=rlnorm(%randomNumbersPerRepetition_LandMarket%*%repetitions%,0,.5);chunks <- split(r, ceiling(seq_along(r)/%randomNumbersPerRepetition_LandMarket%));for(n in names(chunks)) {write(chunks[[n]],file=paste('data/rnd/',n,'.lm.txt',sep=''),ncolumns = 1);write(c(1),file=paste('data/rnd/',n,'.lm.pointer.txt',sep=''),ncolumns = 1)}"



::------------------------
::run 50 simulations full
for /l %%t in (1, 1, %repetitions%) do (

	runSimulation.full.bat %%t 
	
	::reset rng cur position
	%Rscript% -e "setwd('%ccd%');write(c(1),file=paste('data/rnd/%%t.pointer.txt',sep=''),ncolumns = 1);}"

	runSimulation.sampled.bat %%t 
	
)