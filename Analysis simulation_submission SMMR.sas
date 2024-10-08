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


/*adapt data: time score and difference score*/
%macro adapt_data(filename);
data &filename;
set &filename;
time2=time-1;
t=time2;
difference=resp_treated-resp_nontreated;
run;
%mend;
data _null_;
set files;
call execute('%adapt_data('!!trim(filename)!!');');
run;

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

libname nlmm 'C:\Users\u0118563\OneDrive - KU Leuven\Projecten\Gepaarde data\Submission 2\results by ana\naieve lmm';
%macro naive(filename);
proc mixed data=work.&filename;
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
libname Rlmm 'C:\Users\u0118563\OneDrive - KU Leuven\Projecten\Gepaarde data\Submission 2\results by ana\Robust lmm';

%macro sand(filename);
proc mixed data=work.&filename EMPIRICAL;
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
libname mlmm 'C:\Users\u0118563\OneDrive - KU Leuven\Projecten\Gepaarde data\Submission 2\results by ana\marg lmm';
%macro marg(filename);
proc mixed data=work.&filename;
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
call execute('%marg('!!trim(filename)!!');');
run;
%analyse_results(mlmm.parmsn);


*nested random effects*;
libname nlmm 'C:\Users\u0118563\OneDrive - KU Leuven\Projecten\Gepaarde data\Submission 2\results by ana\nest lmm';
%macro nest(filename);
proc mixed data=work.&filename;
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
libname a 'C:\Users\u0118563\OneDrive - KU Leuven\Projecten\Gepaarde data\Submission 2\results by ana\autocorr';

%macro combi(filename);
proc mixed data=work.&filename;
class pair id t;
model response=time2 treated time2*treated/solution ;
random intercept/subject=pair;
repeated t/subject=id type=arh(1) r rcorr;
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

libname clmm 'C:\Users\u0118563\OneDrive - KU Leuven\Projecten\Gepaarde data\Submission 2\results by ana\cond lmm';

%macro cond(filename);
proc mixed data=work.&filename;
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
set files_w;
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
