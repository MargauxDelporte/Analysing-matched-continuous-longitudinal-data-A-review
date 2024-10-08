##load packages
library(mvtnorm)
library(xlsx)
setwd('C:/Users/u0118563/OneDrive - KU Leuven/Projecten/Gepaarde data/Submission 2/Data lognormal')

set.seed(123)


#sample the treatment effect at baseline and on the evolution (slope)
treat_bl=rnorm(1)
treat_sl=rnorm(1)

#Specify the number of pairs
n_pairs=200

#Specify the number of time points
n_time=5
rlnorm(n=n_pairs, meanlog = 0, sdlog = 1)
#Simulate 100 datasets
true_pm=data.frame()
i=0
for(i in 0:99){
  #dataset-spefic seed
  set.seed(i)

  #Sample the random effect of the pairs
  effect_pair=rnorm(n_pairs,sd=1)
  #simulate a variance-covariance matrix of the subject specific effects, and simulate the random effects from it
  D=matrix(rWishart(n=1,df=3,Sigma=diag(2)),nrow=2)
  effects_subject=rmvnorm(n_pairs*2,sigma=D)
  #simulate the slope
  control_sl=rnorm(1)
  #simulate the intercept
  control_bl=rnorm(1)
  
  #create the data
  data_cases_t1=treat_bl+control_bl+effect_pair+effects_subject[1:n_pairs,1]+rnorm(n=n_pairs,sd=2)
  data_cases_t2=treat_bl+control_bl+effect_pair+effects_subject[1:n_pairs,1]+(effects_subject[1:n_pairs,2]+treat_sl+control_sl)*1+rlnorm(n=n_pairs, meanlog = 0, sdlog = 1)
  data_cases_t3=treat_bl+control_bl+effect_pair+effects_subject[1:n_pairs,1]+(effects_subject[1:n_pairs,2]+treat_sl+control_sl)*2+rlnorm(n=n_pairs, meanlog = 0, sdlog = 1)
  data_cases_t4=treat_bl+control_bl+effect_pair+effects_subject[1:n_pairs,1]+(effects_subject[1:n_pairs,2]+treat_sl+control_sl)*3+rlnorm(n=n_pairs, meanlog = 0, sdlog = 1)
  data_cases_t5=treat_bl+control_bl+effect_pair+effects_subject[1:n_pairs,1]+(effects_subject[1:n_pairs,2]+treat_sl+control_sl)*4+rlnorm(n=n_pairs, meanlog = 0, sdlog = 1)
  data_cases=cbind(rep(1:n_pairs,n_time),rep(1:n_pairs,n_time),rep(1:n_time,each=n_pairs),rep(1,200),c(data_cases_t1,data_cases_t2,data_cases_t3,data_cases_t4,data_cases_t5))


  data_controls_t1=control_bl+effect_pair+effects_subject[(n_pairs+1):(n_pairs*2),1]+rnorm(n=n_pairs,sd=2)
  data_controls_t2=control_bl+effect_pair+effects_subject[(n_pairs+1):(n_pairs*2),1]+(control_sl+effects_subject[(n_pairs+1):(n_pairs*2),2])*1+rlnorm(n=n_pairs, meanlog = 0, sdlog = 1)
  data_controls_t3=control_bl+effect_pair+effects_subject[(n_pairs+1):(n_pairs*2),1]+(control_sl+effects_subject[(n_pairs+1):(n_pairs*2),2])*2+rlnorm(n=n_pairs, meanlog = 0, sdlog = 1)
  data_controls_t4=control_bl+effect_pair+effects_subject[(n_pairs+1):(n_pairs*2),1]+(control_sl+effects_subject[(n_pairs+1):(n_pairs*2),2])*3+rlnorm(n=n_pairs, meanlog = 0, sdlog = 1)
  data_controls_t5=control_bl+effect_pair+effects_subject[(n_pairs+1):(n_pairs*2),1]+(control_sl+effects_subject[(n_pairs+1):(n_pairs*2),2])*4+rlnorm(n=n_pairs, meanlog = 0, sdlog = 1)
  data_controls=cbind(rep(1:n_pairs,n_time),rep((n_pairs+1):(n_pairs*2),n_time),rep(1:n_time,each=n_pairs),rep(0,200),c(data_controls_t1,data_controls_t2,data_controls_t3,data_controls_t4,data_controls_t5))
  
  #data in the 'long' format
  paired_longitudinal_data=data.frame(rbind(data_cases,data_controls))
  names(paired_longitudinal_data)=c('pair','id','time','treated','response')


  #data in the 'wide' format
  paired_longitudinal_data_pp=data.frame(cbind(data_cases,data_controls))
  paired_longitudinal_data_pp=paired_longitudinal_data_pp[,-c(2,4,6,7,8,9)]
  names(paired_longitudinal_data_pp)=c('pair','time','resp_treated','resp_nontreated')

  #export the data
  new_x <- paste("simulated_data_long",i,".xlsx", sep = "")
  new_x2 <- paste("simulated_data_wide",i,".xlsx", sep = "")
  write.xlsx(paired_longitudinal_data,new_x,row.names=F)
  write.xlsx(paired_longitudinal_data_pp,new_x2,row.names=F)
  #true_pm=rbind(true_pm,cbind(i, treat_bl,treat_sl))
  print(i)
  }

#write.xlsx(true_pm,'true_pm.xlsx',row.names=F)
