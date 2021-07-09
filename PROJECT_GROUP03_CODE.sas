/*time series data preparation*/
ods noproctitle;

proc timedata data=WORK.APPLE out=WORK.GROUP03;
	var Date / transform=none setmissing=missing;
	var Price / transform=none setmissing=missing;
run;

data work.tsPrep(rename=());
	set WORK.GROUP03;
run;




/* exploration */

ods graphics / imagemap=on;
TITLE "DATA EXPLORATION";
proc timeseries data=WORK.GROUP03 plots=(series histogram cycles corr acf pacf) 
		crossplots=(series ccf);
	var Price / transform=none dif=0;
	crossvar Date / transform=none dif=0;
	ods exclude ACFNORMPlot;
	ods exclude PACFNORMPlot;
	ods exclude CCFNORMPlot;
run;

/* random walk model */

ods noproctitle;
ods graphics / imagemap=on;
title "Random walk forecasting";
proc sort data=WORK.GROUP03 out=Work.preProcessedData;
	by TIME;
run;

proc arima data=Work.preProcessedData plots
     (only)=(series(corr crosscorr) residual(corr normal) 
		forecast(forecast) );
	identify var=Price (1 1 7);
	estimate noint method=CLS;
	forecast lead=12 back=0 alpha=0.05 id=TIME interval=day;
	outlier;
	run;
quit;

proc delete data=Work.preProcessedData;
run;

/* MOVING AVERAGE MODEL */
ods noproctitle;
ods graphics / imagemap=on;
title "moving average forecasting";
proc sort data=WORK.GROUP03 out=Work.preProcessedData;
	by TIME;
run;

proc arima data=Work.preProcessedData plots
     (only)=(series(corr crosscorr) residual(corr normal) 
		forecast(forecast) );
	identify var=Price;
	estimate q=(1 2 3 4) ma=(0.25 0.25 0.25 0.25) noint method=CLS;
	forecast lead=12 back=0 alpha=0.05 id=TIME interval=day;
	outlier;
	run;
quit;

proc delete data=Work.preProcessedData;
run;

/* EXPONENTIAL SMOOTHING */

ods noproctitle;
ods graphics / imagemap=on;
title "HOLT exponential smoothing";
proc sort data=WORK.GROUP03 out=Work.preProcessedData;
	by TIME;
run;

proc esm data=Work.preProcessedData back=0 lead=12 plot=(corr errors 
		modelforecasts);
	id TIME interval=day;
	forecast Price / alpha=0.05 model=linear transform=none;
run;

proc delete data=Work.preProcessedData;
run;

ods noproctitle;
ods graphics / imagemap=on;
title "winters addictive smoothing";
proc sort data=WORK.GROUP03 out=Work.preProcessedData;
	by TIME;
run;

proc esm data=Work.preProcessedData back=0 lead=12 seasonality=7 plot=(corr 
		errors modelforecasts);
	id TIME interval=day;
	forecast Price / alpha=0.05 model=addwinters transform=none;
run;

proc delete data=Work.preProcessedData;
run;

/* DECOMPOSITION */

ods noproctitle;
ods graphics / imagemap=on;
title "PARTIAL DECOMPOSITION FOR APPLE STOCK PRICE PREDICTION";
proc sort data=WORK.GROUP03 out=Work.preProcessedData;
	by TIME;
run;

proc esm data=Work.preProcessedData back=0 lead=12 seasonality=7 plot=(seasons 
		trends acf corr errors pacf modelforecasts);
	id TIME interval=day;
	forecast Price / alpha=0.05 model=multseasonal transform=log;
run;

proc delete data=Work.preProcessedData;
run;

/* ARIMA METHOD */

ods noproctitle;
ods graphics / imagemap=on;
title "ARIMA FORECASTING";
proc sort data=WORK.GROUP03 out=Work.preProcessedData;
	by TIME;
run;

proc arima data=Work.preProcessedData plots
     (only)=(series(corr crosscorr) residual(corr normal) 
		forecast(forecast forecastonly) );
	identify var=Price(1);
	estimate p=(1) method=ML;
	forecast lead=12 back=0 alpha=0.05 id=TIME interval=day;
	outlier;
	run;
quit;

proc delete data=Work.preProcessedData;
run;

/* BOX-JENKINS MODEL */

ods noproctitle;
ods graphics / imagemap=on;
title "BOX-JENKINS FORECASTING MODEL FOR APPLE STOCK PRICE PREDICTION";
proc sort data=WORK.GROUP03 out=Work.preProcessedData;
	by TIME;
run;

proc arima data=Work.preProcessedData plots
     (only)=(series(corr crosscorr) residual(corr hist normal pacf) 
		forecast(forecast forecastonly) ) out=work.out;
	identify var=Price(1) outcov=work.outcov0001;
	estimate method=ML outest=work.outest0001 outstat=work.outstat0001 
		outmodel=work.outmodel0001;
	forecast lead=12 back=0 alpha=0.05 id=TIME interval=day;
	outlier;
	run;
quit;

proc delete data=Work.preProcessedData;
run;