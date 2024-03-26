libname ofto 'C:\Users\u0118563\OneDrive - KU Leuven\Projecten\Gepaarde data\Dataset oftomologie en analyse\Data Tables - Text files';

data wide;
set ofto.singles2;
run;
proc sort data=wide;
by PtId time;
run;

/*wide to long data*/
data longdata;
set wide;
ETDS=Etdrs_study;
IOP=IOP_study;
eye='study';
output;
ETDS=Etdrs_comp;
IOP=IOP_comp;
eye='comp';
output;
run;

/*paired t-test*/
PROC TTEST DATA=wide ALPHA=.05;
    PAIRED Etdrs_study*Etdrs_comp;
by visit;
where visit='Baseline' or visit='4 week' or visit='8 week' or visit='12 week' or visit='16 week';
run;

/*unpaired t-test*/
proc sort data=longdata;by visit;run;
PROC TTEST DATA=longdata ALPHA=.05;
VAR  ETDS;
CLASS eye;
by visit;
where visit='Baseline' or visit='4 week' or visit='8 week' or visit='12 week' or visit='16 week';
RUN;

/*comparison of slopes*/
proc sort data=longdata;by ptid;run;
PROC reg DATA=longdata ALPHA=.05;
model ETDS=time;
where eye='comp';
by ptid;
ods output ParameterEstimates=slopes_nonaff;
RUN;

PROC reg DATA=longdata ALPHA=.05;
model ETDS=time;
where eye='study';
by ptid;
ods output ParameterEstimates=slopes_DME;
RUN;

data slopes_nonaff2;
set slopes_nonaff;
slope_nonaff=estimate;
where variable='time';
keep ptid slope_nonaff;
run;

data slopes_DME2;
set slopes_DME;
slope_DME=estimate;
where variable='time';
keep ptid slope_DME;
run;

proc sort data=slopes_nonaff2; by ptid;run;
proc sort data=slopes_DME2; by ptid;run;

data slopes;
merge slopes_nonaff2 slopes_DME2;
by ptid;
run;

PROC TTEST DATA=slopes ALPHA=.05;
    PAIRED slope_DME*slope_nonaff;
RUN;


/*MANOVA*/
proc sort data=longdata;by ptid visit eye;run;

data longdata;
set longdata;
length time2 $25;
if visit='4 week' then time2='4w';
else if visit='8 week' then time2='8w';
else if visit='12 week' then time2='12w';
else if visit='16 week' then time2='16w';
else time2=visit;
run;
proc sort data=longdata;by ptid time2 eye;run;
proc transpose data=longdata out=manova;
by ptid time2 eye;
var etds;
run;
data manova;
set manova;
where time2='Baseline' or time2='4w' or time2='8w' or time2='12w' or time2='16w';
run;

proc sort data=manova; by ptid eye;run;
proc transpose data=manova out=manova_wide delimiter = _;
by ptid eye;
id  _NAME_ time2;
var col1;
run;

data manova_wide;
set manova_wide;
if eye='comp' then group=0;
if eye='study' then group=1;
run;
proc freq data=manova_wide;
tables eye*group;
run;

proc glm data =manova_wide;
model etds_baseline etds_4w etds_8w etds_12w etds_16w= group/solution;
manova h=_all_;
repeated dose 5 polynomial / summary printm;
run;

*LMM with random effect of the subject*;
data longdata;
set longdata;
if eye='study' then DME=1;else DME=0;
run;
proc mixed data=longdata;
model ETDS=time DME time*DME/solution residual outp=predresid;
random intercept /subject=ptid type=un;
run;

*robust sandwich estimator*;
proc mixed data=longdata EMPIRICAL;
class ptid;
model ETDS=time DME time*DME/solution residual outp=predresid;
random intercept time/subject=ptid type=un;
run;

*nested random effects*;
data longdata;
set longdata;
pair_eye=cats(ptid,DME);
run;

proc mixed data=longdata;
class ptid pair_eye;
model ETDS=time DME time*DME/solution residual outp=predresid;
random intercept / subject=ptid;
random intercept / subject=pair_eye(ptid);
run;

*conditional linear mixed model;
data wide;
set wide;
difference=etdrs_study-etdrs_comp;
run;

proc mixed data=wide;
class ptid;
model difference=time/solution residual outp=predresid;
random intercept/subject=ptid;
run;