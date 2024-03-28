/*import macro*/
%macro import_xlsx(filename);
filename xlsx "C:\Users\u0118563\OneDrive - KU Leuven\Projecten\Gepaarde data\Grote simulatie\Datasets/check/&filename..xlsx" termstr=LF;
proc import
  datafile=xlsx
  out=work.&filename.
  dbms=xlsx
  replace
;
run;
%mend;

/*import a list with the names of files to import*/
proc import datafile = 'C:\Users\u0118563\OneDrive - KU Leuven\Projecten\Gepaarde data\Grote simulatie\Datasets\list.txt'
 out = files
 dbms = dlm
 replace;
run;
proc import datafile = 'C:\Users\u0118563\OneDrive - KU Leuven\Projecten\Gepaarde data\Grote simulatie\Datasets\list_l.txt'
 out = files_l
 dbms = dlm
 replace;
run;
proc import datafile = 'C:\Users\u0118563\OneDrive - KU Leuven\Projecten\Gepaarde data\Grote simulatie\Datasets\list_w.txt'
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

*general macro to aggregate the results*;
%macro aggregate;
data parmsn;
set parmsn;
where effect='treated' or effect='time2*treated';
run;
proc sort data=parmsn;
by effect;
run;
proc means data=parmsn mean n std MAXDEC=4;
var estimate StdErr;
by effect;
run;
%mend;

****NAIEVE LMM***;
%macro naive(filename);
proc mixed data=work.&filename;
CLASS id;
model response=time2 treated time2*treated/solution ;
random intercept/subject=id TYPE=uN;
ods output SolutionF=parmsn2;
run;
data parmsn;
set parmsn parmsn2;
run;
%mend;
data parmsn;run;
data _null_;
set files_l;
call execute('%naive('!!trim(filename)!!');');
run;
%aggregate


*robust sandwich estimator*;
%macro sand(filename);
proc mixed data=work.&filename EMPIRICAL;
CLASS id;
model response=time2 treated time2*treated/solution ;
random intercept time2/subject=id TYPE=uN;
ods output SolutionF=parmsn2;
run;
data parmsn;
set parmsn parmsn2;
run;
%mend;
data parmsn;run;
data _null_;
set files_l;
call execute('%sand('!!trim(filename)!!');');
run;
%aggregate

*unstructured residual matrix;
%macro marg(filename);
proc mixed data=work.&filename;
class pair id t;
model response=time2 treated time2*treated/solution ;
repeated t/subject=id type=un r rcorr;
ods output SolutionF=parmsn2;
run;
data parmsn;
set parmsn parmsn2;
run;
%mend;
data parmsn;run;
data _null_;
set files_l;
call execute('%marg('!!trim(filename)!!');');
run;
%aggregate


*nested random effects*;
%macro nest(filename);
proc mixed data=work.&filename;
class id pair;
model response=time2 treated time2*treated/solution ;
random intercept / subject=pair;
random intercept time2 / subject=id(pair) type=un;
ods output SolutionF=parmsn2;
run;
data parmsn;
set parmsn parmsn2;
run;
%mend;
data parmsn;run;
data _null_;
set files_l;
call execute('%nest('!!trim(filename)!!');');
run;
%aggregate

**autocorr subject level;
%macro combi(filename);
proc mixed data=work.&filename;
class pair id t;
model response=time2 treated time2*treated/solution ;
random intercept/subject=pair;
repeated t/subject=id type=arh(1) r rcorr;
ods output SolutionF=parmsn2;
run;
data parmsn;
set parmsn parmsn2;
run;
%mend;
data parmsn;run;
data _null_;
set files_l;
call execute('%combi('!!trim(filename)!!');');
run;
%aggregate
data parmsn_autocorr;
set parmsn;
run;

*conditional linear mixed model;
%macro cond(filename);
proc mixed data=work.&filename;
class pair;
model difference=time2/solution ;
random intercept time2/subject=pair type=un;
ods output SolutionF=parmsn2;
run;
data parmsn;
set parmsn parmsn2;
run;
%mend;
data parmsn;run;
data _null_;
set files_w;
call execute('%cond('!!trim(filename)!!');');
run;
data parmsn22;
set parmsn;
where effect='Intercept' or effect='time2';
run;
proc sort data=parmsn22;
by effect;
run;
proc means data=parmsn22 mean n std ;
var estimate StdErr;
by effect;
run;

