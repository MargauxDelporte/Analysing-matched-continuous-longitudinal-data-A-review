libname sim 'C:\Users\u0118563\OneDrive - KU Leuven\Projecten\Gepaarde data\Submission 2\results by ana';

/*import macro*/
%macro import_xlsx(filename);
filename xlsx "C:\Users\u0118563\OneDrive - KU Leuven\Projecten\Gepaarde data\Submission 2\Data/&filename..xlsx" termstr=LF;
proc import
  datafile=xlsx
  out=work.&filename.
  dbms=xlsx
  replace
;
run;
%mend;

/*import a list with the names of files to import*/
proc import datafile = 'C:\Users\u0118563\OneDrive - KU Leuven\Projecten\Gepaarde data\Submission 2\Data\list.txt'
 out = files
 dbms = dlm
 replace;
run;
proc import datafile = 'C:\Users\u0118563\OneDrive - KU Leuven\Projecten\Gepaarde data\Submission 2\Data\list_l.txt'
 out = files_l
 dbms = dlm
 replace;
run;
proc import datafile = 'C:\Users\u0118563\OneDrive - KU Leuven\Projecten\Gepaarde data\Submission 2\Data\list_w.txt'
 out = files_w
 dbms = dlm
 replace;
run;

/*import files*/
data _null_;
set files;
call execute('%import_xlsx('!!trim(filename)!!');');
run;

/*
data filename;
set simulated_data_long0;
run;

proc sort data=filename; by treated;run;
data filename;
set filename;
call streaminit(123); 
if(treated=0)then 
missingvalue=rand("Bernoulli", 0.05);
if(treated=1)then 
missingvalue=rand("Bernoulli", 0.25);
run;
proc means data=filename;
var missingvalue;
by treated;
run;*/
/*adapt data: missingness, time score and difference score*/
%macro adapt_MAR(filename);
data &filename._MAR_l;
set &filename;
call streaminit(123); 
time2=time-1;
t=time2;
if(treated=0)then 
missingvalue=rand("Bernoulli", 0.05);
if(treated=1)then 
missingvalue=rand("Bernoulli", 0.25);
run;
data &filename._MAR_l;
set &filename._MAR_l;
where missingvalue=0;
run;
proc sort data=&filename._MAR_l; by pair time;run;
proc transpose data=&filename._MAR_l out=&filename._MAR_w prefix=resp;
by pair time;
id treated;
var response;
run;
data &filename._MAR_w;
set &filename._MAR_w;
resp_treated=resp1;
time2=time-1;
t=time2;
resp_nontreated=resp0;
difference=resp_treated-resp_nontreated;
drop drop _name_ _label_ resp1 resp0;
run;
%mend;
data _null_;
set files_l;
call execute('%adapt_MAR('!!trim(filename)!!');');
run;

/*calculate the amount of missingness*/
Data Stack;
Set WORK.SIMULATED_DATA_LONG0_MAR_L
WORK.SIMULATED_DATA_LONG1_MAR_L
WORK.SIMULATED_DATA_LONG2_MAR_L
WORK.SIMULATED_DATA_LONG3_MAR_L
WORK.SIMULATED_DATA_LONG4_MAR_L
WORK.SIMULATED_DATA_LONG5_MAR_L
WORK.SIMULATED_DATA_LONG6_MAR_L
WORK.SIMULATED_DATA_LONG7_MAR_L
WORK.SIMULATED_DATA_LONG8_MAR_L
WORK.SIMULATED_DATA_LONG9_MAR_L
WORK.SIMULATED_DATA_LONG10_MAR_L
WORK.SIMULATED_DATA_LONG11_MAR_L
WORK.SIMULATED_DATA_LONG12_MAR_L
WORK.SIMULATED_DATA_LONG13_MAR_L
WORK.SIMULATED_DATA_LONG14_MAR_L
WORK.SIMULATED_DATA_LONG15_MAR_L
WORK.SIMULATED_DATA_LONG16_MAR_L
WORK.SIMULATED_DATA_LONG17_MAR_L
WORK.SIMULATED_DATA_LONG18_MAR_L
WORK.SIMULATED_DATA_LONG19_MAR_L
WORK.SIMULATED_DATA_LONG20_MAR_L
WORK.SIMULATED_DATA_LONG21_MAR_L
WORK.SIMULATED_DATA_LONG22_MAR_L
WORK.SIMULATED_DATA_LONG23_MAR_L
WORK.SIMULATED_DATA_LONG24_MAR_L
WORK.SIMULATED_DATA_LONG25_MAR_L
WORK.SIMULATED_DATA_LONG26_MAR_L
WORK.SIMULATED_DATA_LONG27_MAR_L
WORK.SIMULATED_DATA_LONG28_MAR_L
WORK.SIMULATED_DATA_LONG29_MAR_L
WORK.SIMULATED_DATA_LONG30_MAR_L
WORK.SIMULATED_DATA_LONG31_MAR_L
WORK.SIMULATED_DATA_LONG32_MAR_L
WORK.SIMULATED_DATA_LONG33_MAR_L
WORK.SIMULATED_DATA_LONG34_MAR_L
WORK.SIMULATED_DATA_LONG35_MAR_L
WORK.SIMULATED_DATA_LONG36_MAR_L
WORK.SIMULATED_DATA_LONG37_MAR_L
WORK.SIMULATED_DATA_LONG38_MAR_L
WORK.SIMULATED_DATA_LONG39_MAR_L
WORK.SIMULATED_DATA_LONG40_MAR_L
WORK.SIMULATED_DATA_LONG41_MAR_L
WORK.SIMULATED_DATA_LONG42_MAR_L
WORK.SIMULATED_DATA_LONG43_MAR_L
WORK.SIMULATED_DATA_LONG44_MAR_L
WORK.SIMULATED_DATA_LONG45_MAR_L
WORK.SIMULATED_DATA_LONG46_MAR_L
WORK.SIMULATED_DATA_LONG47_MAR_L
WORK.SIMULATED_DATA_LONG48_MAR_L
WORK.SIMULATED_DATA_LONG49_MAR_L
WORK.SIMULATED_DATA_LONG50_MAR_L
WORK.SIMULATED_DATA_LONG51_MAR_L
WORK.SIMULATED_DATA_LONG52_MAR_L
WORK.SIMULATED_DATA_LONG53_MAR_L
WORK.SIMULATED_DATA_LONG54_MAR_L
WORK.SIMULATED_DATA_LONG55_MAR_L
WORK.SIMULATED_DATA_LONG56_MAR_L
WORK.SIMULATED_DATA_LONG57_MAR_L
WORK.SIMULATED_DATA_LONG58_MAR_L
WORK.SIMULATED_DATA_LONG59_MAR_L
WORK.SIMULATED_DATA_LONG60_MAR_L
WORK.SIMULATED_DATA_LONG61_MAR_L
WORK.SIMULATED_DATA_LONG62_MAR_L
WORK.SIMULATED_DATA_LONG63_MAR_L
WORK.SIMULATED_DATA_LONG64_MAR_L
WORK.SIMULATED_DATA_LONG65_MAR_L
WORK.SIMULATED_DATA_LONG66_MAR_L
WORK.SIMULATED_DATA_LONG67_MAR_L
WORK.SIMULATED_DATA_LONG68_MAR_L
WORK.SIMULATED_DATA_LONG69_MAR_L
WORK.SIMULATED_DATA_LONG70_MAR_L
WORK.SIMULATED_DATA_LONG71_MAR_L
WORK.SIMULATED_DATA_LONG72_MAR_L
WORK.SIMULATED_DATA_LONG73_MAR_L
WORK.SIMULATED_DATA_LONG74_MAR_L
WORK.SIMULATED_DATA_LONG75_MAR_L
WORK.SIMULATED_DATA_LONG76_MAR_L
WORK.SIMULATED_DATA_LONG77_MAR_L
WORK.SIMULATED_DATA_LONG78_MAR_L
WORK.SIMULATED_DATA_LONG79_MAR_L
WORK.SIMULATED_DATA_LONG80_MAR_L
WORK.SIMULATED_DATA_LONG81_MAR_L
WORK.SIMULATED_DATA_LONG82_MAR_L
WORK.SIMULATED_DATA_LONG83_MAR_L
WORK.SIMULATED_DATA_LONG84_MAR_L
WORK.SIMULATED_DATA_LONG85_MAR_L
WORK.SIMULATED_DATA_LONG86_MAR_L
WORK.SIMULATED_DATA_LONG87_MAR_L
WORK.SIMULATED_DATA_LONG88_MAR_L
WORK.SIMULATED_DATA_LONG89_MAR_L
WORK.SIMULATED_DATA_LONG90_MAR_L
WORK.SIMULATED_DATA_LONG91_MAR_L
WORK.SIMULATED_DATA_LONG92_MAR_L
WORK.SIMULATED_DATA_LONG93_MAR_L
WORK.SIMULATED_DATA_LONG94_MAR_L
WORK.SIMULATED_DATA_LONG95_MAR_L
WORK.SIMULATED_DATA_LONG96_MAR_L
WORK.SIMULATED_DATA_LONG97_MAR_L
WORK.SIMULATED_DATA_LONG98_MAR_L
WORK.SIMULATED_DATA_LONG99_MAR_L
;
Run;

proc means data=stack;
var missingvalue;run;
************************************************;
*analysis:loop over all the datasets and combine the estimates first for each analysis**;
************************************************;

%macro analyse_results(input);
   data &input;
   set &input;
   if effect='treated' then true_pm=-0.5604756;
   if effect='time2*treated' then true_pm=-0.2301775;
   where effect ne '';
   run;
   PROC SORT DATA= &input;
   BY EFFECT;
   run;

data efficiency;
set  &input;
d=(estimate-true_pm)*(estimate-true_pm);
under=estimate-1.96*stderr;
upper=estimate+1.96*stderr;
if (true_pm>under AND  true_pm<upper) then covered=1;
else covered=0;
if (probt<0.05) then significant=1;
else significant=0;
run;

proc sort data=efficiency;by effect;run;
proc sort data=&input;by effect;run;
proc means data=&input mean stddev maxdec=3;
var estimate StdErr;
by effect;
run;
proc means data=efficiency maxdec=3;
var estimate d covered significant;
by effect;
run;
%mend;
****NAIEVE LMM***;

libname nlmm 'C:\Users\u0118563\OneDrive - KU Leuven\Projecten\Gepaarde data\Submission 2\results by ana\naieve lmm\MAR';
%macro naive(filename);
proc mixed data=work.&filename._MAR_l;
CLASS id;
model response=time2 treated time2*treated/solution ;
random intercept/subject=id TYPE=uN;
ods output SolutionF=parmsn2;
run;
data parmsn2;
set parmsn2;
length STR $ 22;
where effect='treated' or effect='time2*treated';
STR=%tslit(&filename);
run;
data nlmm.parmsn;
set nlmm.parmsn parmsn2;
run;
%mend;
data nlmm.parmsn;run;
proc print data=nlmm.parmsn; run;
data _null_;
set files_l;
call execute('%naive('!!trim(filename)!!');');
run;
%analyse_results(nlmm.parmsn);

*robust sandwich estimator*;
libname Rlmm 'C:\Users\u0118563\OneDrive - KU Leuven\Projecten\Gepaarde data\Submission 2\results by ana\Robust lmm\MAR';

%macro sand(filename);
proc mixed data=work.&filename._MAR_l EMPIRICAL;
CLASS id;
model response=time2 treated time2*treated/solution ;
random intercept time2/subject=id TYPE=uN;
ods output SolutionF=parmsn2;
run;
data parmsn2;
set parmsn2;
length STR $ 22;
where effect='treated' or effect='time2*treated';
STR=%tslit(&filename);
run;
data Rlmm.parmsn;
set Rlmm.parmsn parmsn2;
run;
%mend;
data Rlmm.parmsn;run;
data _null_;
set files_l;
call execute('%sand('!!trim(filename)!!');');
run;
%analyse_results(rlmm.parmsn);

*unstructured residual matrix;
libname mlmm 'C:\Users\u0118563\OneDrive - KU Leuven\Projecten\Gepaarde data\Submission 2\results by ana\marg lmm\MAR';
%macro MARg(filename);
proc mixed data=work.&filename._MAR_l;
class pair id t;
model response=time2 treated time2*treated/solution ;
repeated t/subject=id type=un r rcorr;
ods output SolutionF=parmsn2;
run;
data parmsn2;
set parmsn2;
length STR $ 22;
where effect='treated' or effect='time2*treated';
STR=%tslit(&filename);
run;
data mlmm.parmsn;
set mlmm.parmsn parmsn2;
run;
%mend;
data mlmm.parmsn;run;
data _null_;
set files_l;
call execute('%MARg('!!trim(filename)!!');');
run;
%analyse_results(mlmm.parmsn);


*nested random effects*;
libname nlmm 'C:\Users\u0118563\OneDrive - KU Leuven\Projecten\Gepaarde data\Submission 2\results by ana\nest lmm\MAR';
%macro nest(filename);
proc mixed data=work.&filename._MAR_l;
class id pair;
model response=time2 treated time2*treated/solution ;
random intercept / subject=pair;
random intercept time2 / subject=id(pair) type=un;
ods output SolutionF=parmsn2;
run;
data parmsn2;
set parmsn2;
length STR $ 22;
where effect='treated' or effect='time2*treated';
STR=%tslit(&filename);
run;
data nlmm.parmsn;
set nlmm.parmsn parmsn2;
run;
%mend;
data nlmm.parmsn;run;
data _null_;
set files_l;
call execute('%nest('!!trim(filename)!!');');
run;
%analyse_results(nlmm.parmsn);

**autocorr subject level;
libname a 'C:\Users\u0118563\OneDrive - KU Leuven\Projecten\Gepaarde data\Submission 2\results by ana\autocorr\MAR';

%macro combi(filename);
proc mixed data=work.&filename._MAR_l;
class pair id t;
model response=time2 treated time2*treated/solution ;
random intercept/subject=pair;
repeated t/subject=id type=arh(1) r rcorr;
where missingvalue=0;
ods output SolutionF=parmsn2;
run;
data parmsn2;
set parmsn2;
length STR $ 22;
where effect='treated' or effect='time2*treated';
STR=%tslit(&filename);
run;
data a.parmsn;
set a.parmsn parmsn2;
run;
%mend;
data a.parmsn;run;
data _null_;
set files_l;
call execute('%combi('!!trim(filename)!!');');
run;
%analyse_results(a.parmsn);

*conditional linear mixed model;

libname clmm 'C:\Users\u0118563\OneDrive - KU Leuven\Projecten\Gepaarde data\Submission 2\results by ana\cond lmm\MAR';

%macro cond(filename);
proc mixed data=work.&filename._MAR_w;
class pair;
model difference=time2/solution ;
random intercept time2/subject=pair type=un;
ods output SolutionF=parmsn2;
run;
data parmsn2;
set parmsn2;
length STR $ 22;
STR=%tslit(&filename);
run;
data clmm.parmsn;
set clmm.parmsn parmsn2;
run;
%mend;
data clmm.parmsn;run;
data _null_;
set files_l;
call execute('%cond('!!trim(filename)!!');');
run;
proc print data=clmm.parmsn;run;
data clmm.parmsn2;
set  clmm.parmsn;
length N $ 3;
   SUB = 'simulated_data_wide';
   STR_LEN = length(STR);
   SUB_LEN = length(SUB);
   POS = find(STR,SUB,-STR_LEN);
   N = kupdate(STR,POS,SUB_LEN);  
   drop sub str_len sub_len pos str;
   where effect ne '';
   run;

   data clmm.parmsn2;
   set clmm.parmsn2;
   if effect='Intercept' then true_pm=-0.5604756;
   if effect='time2' then true_pm=-0.2301775;
   run;

data efficiency;
set clmm.parmsn2;
d=(estimate-true_pm)*(estimate-true_pm);
under=estimate-1.96*stderr;
upper=estimate+1.96*stderr;
if (true_pm>under AND  true_pm<upper) then covered=1;
else covered=0;
if (probt<0.05) then significant=1;
else significant=0;
run;
proc sort data=efficiency;by effect;run;
proc sort data=clmm.parmsn2;by effect;run;
proc means data=clmm.parmsn2 mean stddev maxdec=3;
var estimate StdErr;
by effect;
run;
proc means data=efficiency maxdec=3;
var estimate d covered significant;
by effect;
run;
