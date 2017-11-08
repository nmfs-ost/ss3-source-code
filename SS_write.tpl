
 /*  SS_Label_FUNCTION 36 write_summaryoutput */
FUNCTION void write_summaryoutput()
  {
  random_number_generator radm(long(time(&finish)));
  cout<<"in summary report "<<endl;
  time(&finish);
  elapsed_time = difftime(finish,start);
  report2<<runnumber<<" -logL: "<<obj_fun<<" SSB(Vir_Start_End): "<<SPB_yr(styr-2)<<" "<<SPB_yr(styr)<<" "<<SPB_yr(endyr)<<endl;
  report2<<runnumber<<" Files: "<<datfilename<<" "<<ctlfilename;
  if(readparfile>=1) report2<<" Start_from_ss.par";
  report2<<endl<<runnumber<<" N_iter: "<<niter<<" runtime(sec): "<<elapsed_time<<" starttime: "<<ctime(&start);
  report2<<runnumber<<version_info<<endl;
  report2<<runnumber<<" F_Method: "<<F_Method<<" Retro_YR: "<<retro_yr<<" Forecast_Type: "<<Do_Forecast<<" MSY_Type: "<<Do_MSY<<endl;
  if(N_SC>0)
  {
    for (j=1;j<=N_SC;j++) report2<<runnumber<<" Comment S_"<<j<<" "<<Starter_Comments(j)<<endl;
  }
  if(N_DC>0)
  {
    for (j=1;j<=N_DC;j++) report2<<runnumber<<" Comment D_"<<j<<" "<<Data_Comments(j)<<endl;
  }
  if(N_CC>0)
  {
    for (j=1;j<=N_CC;j++) report2<<runnumber<<" Comment C_"<<j<<" "<<Control_Comments(j)<<endl;
  }
  if(N_FC>0)
  {
    for (j=1;j<=N_FC;j++) report2<<runnumber<<" Comment F_"<<j<<" "<<Forecast_Comments(j)<<endl;
  }
  k=current_phase();
  if(k>max_lambda_phase) k=max_lambda_phase;
  report2<<runnumber<<" Like_Emph Total 1 "<<endl<<runnumber<<" Like_Value Total "<<obj_fun<<endl;
  if(Svy_N>0) report2<<runnumber<<" Like_Emph Indices All "<<column(surv_lambda,k)<<endl<<
  runnumber<<" Like_Value Indices "<<surv_like*column(surv_lambda,k)<<" " <<surv_like<<endl;
  if(nobs_disc>0) report2<<runnumber<<" Like_Emph Discard All "<<column(disc_lambda,k)<<endl<<
  runnumber<<" Like_Value Discard "<<disc_like*column(disc_lambda,k)<<" " <<disc_like<<endl;
  if(nobs_mnwt>0) report2<<runnumber<<" Like_Emph MeanBodyWt All "<<column(mnwt_lambda,k)<<endl<<
  runnumber<<" Like_Value MeanBodyWt "<<mnwt_like*column(mnwt_lambda,k)<<" " <<mnwt_like<<endl;
  if(Nobs_l_tot>0) report2<<runnumber<<" Like_Emph LenComp All "<<column(length_lambda,k)<<endl<<
  runnumber<<" Like_Value LenComp "<<length_like_tot*column(length_lambda,k)<<" " <<length_like_tot<<endl;
  if(Nobs_a_tot>0) report2<<runnumber<<" Like_Emph AgeComp All "<<column(age_lambda,k)<<endl<<
  runnumber<<" Like_Value AgeComp "<<age_like_tot*column(age_lambda,k)<<" " <<age_like_tot<<endl;
  if(nobs_ms_tot>0) report2<<runnumber<<" Like_Emph MeanLAA All "<<column(sizeage_lambda,k)<<endl<<
  runnumber<<" Like_Value MeanLAA "<<sizeage_like*column(sizeage_lambda,k)<<" " <<sizeage_like<<endl;
  if(F_Method>1) report2<<runnumber<<" Like_Emph Catch All "<<column(catch_lambda,k)<<endl<<
  runnumber<<" Like_Value Catch "<<catch_like*column(catch_lambda,k)<<" " <<catch_like<<endl;
  if(SzFreq_Nmeth>0) report2<<runnumber<<" Like_Emph WeightFreq All "<<column(SzFreq_lambda,k)<<endl<<
  runnumber<<" Like_Value WeightFreq "<<SzFreq_like*column(SzFreq_lambda,k)<<" " <<SzFreq_like<<endl;
  if(Do_Morphcomp>0) report2<<runnumber<<" Like_Emph Morphcomp All "<<Morphcomp_lambda(k)<<endl<<
  runnumber<<" Like_Value Morphcomp "<<Morphcomp_like*Morphcomp_lambda(k)<<" " <<Morphcomp_like<<endl;
  if(Do_TG>0) report2<<runnumber<<" Like_Emph Tag_comp All "<<column(TG_lambda1,k)<<endl<<
  runnumber<<" Like_Value Tag_comp "<<TG_like1*column(TG_lambda1,k)<<" " <<TG_like1<<endl;
  if(Do_TG>0) report2<<runnumber<<" Like_Emph Tag_negbin All "<<column(TG_lambda2,k)<<endl<<
  runnumber<<" Like_Value Tag_negbin "<<TG_like2*column(TG_lambda2,k)<<" " <<TG_like2<<endl;

  report2<<runnumber<<" Like_Comp Equ_Catch Recruits Fcast_Recr Biasadj Priors ParmDevs CrashPen"<<endl;
  report2<<runnumber<<" Like_Emph "<<init_equ_lambda(k)<<" "<<recrdev_lambda(k)<<" " <<Fcast_recr_lambda<<" "
         <<parm_prior_lambda(k)<<" " <<parm_dev_lambda(k)<<" " <<CrashPen_lambda(k)<<endl;
  report2<<runnumber<<" Like_Value*Emph "<<equ_catch_like*init_equ_lambda(k)<<" "<<recr_like*recrdev_lambda(k)<<" "
         <<Fcast_recr_like<<" "<<parm_like*parm_prior_lambda(k)<<" "<<
         sum(parm_dev_like)*parm_dev_lambda(k)<<" "<<CrashPen*CrashPen_lambda(k)<<endl;

  report2 <<runnumber<<" TimeSeries Yr Vir Equ "<<years<<" ";
  k=YrMax;
  if(k==endyr) k=endyr+1;
  for (y=endyr+1;y<=k;y++) {report2<<y<<"F ";}
  report2 <<endl;
  report2 <<runnumber<<" Timeseries SpawnBio "<<column(Smry_Table,7)<<endl;
  report2 <<runnumber<<" Timeseries Recruit "<<column(Smry_Table,8)<<endl;
  report2 <<runnumber<<" Timeseries TotBio "<<column(Smry_Table,1)<<endl;
  report2 <<runnumber<<" Timeseries SmryBio-"<<Smry_Age<<" "<<column(Smry_Table,2)<<endl;
  report2 <<runnumber<<" Timeseries TotCatch "<<column(Smry_Table,4)<<endl;
  report2 <<runnumber<<" Timeseries RetCatch "<<column(Smry_Table,5)<<endl;
  j=0;
  if(max(Do_Retain)>0) j=1;
  if(Do_Benchmark>0) report2<<runnumber<<" Mgmt_Quant "<<Mgmt_quant(1,6+j)<<endl;

  report2<<runnumber<<" Parm Labels ";
  for (i=1;i<=ParCount;i++) {report2<<" "<<ParmLabel(i);}
  report2<<endl;
  report2<<runnumber<<" Parm Values ";
  report2<<" "<<MGparm<<" ";
  if(N_parm_dev>0)
    {
      for(j=1;j<=N_parm_dev;j++)  report2<<parm_dev(j)<<" ";
    }
  report2<<SR_parm<<" ";
  if(recdev_cycle>0) report2<<recdev_cycle_parm<<" ";
  if(recdev_do_early>0) report2<<recdev_early<<" ";
  if(do_recdev==1) {report2<<recdev1<<" ";}
  if(do_recdev==2) {report2<<recdev2<<" ";}
  if(Do_Forecast>0) report2<<Fcast_recruitments<<" "<<Fcast_impl_error<<" ";
  if(N_init_F>0) report2<<init_F<<" ";
  if(F_Method==2) report2<<" "<<F_rate;
  if(Q_Npar2>0) report2<<Q_parm<<" ";
  if(N_selparm2>0) report2<<selparm<<" ";
//  if(N_selparm_dev>0) report2<<selparm_dev<<" ";
  if(Do_TG>0) report2<<TG_parm<<" ";
  report2<<endl;

  NP=0;   // count of number of parameters
  report2<<runnumber<<" MG_parm ";
  for (j=1;j<=N_MGparm2;j++)
  {NP++; report2<<" "<<ParmLabel(NP);}
  report2<<endl<<runnumber<<" MG_parm "<<MGparm<<endl;

  if(N_parm_dev>0)
  {
    report2<<runnumber<<" MG_parm_dev ";
    for (i=1;i<=N_parm_dev;i++)
    {
      for (j=parm_dev_minyr(i);j<=parm_dev_maxyr(i);j++)
      {NP++; report2<<" "<<ParmLabel(NP);}
      report2<<endl<<runnumber<<" MG_parm_dev "<<parm_dev(i)<<endl;
    }
  }

    report2<<runnumber<<" SR_parm ";
    for (i=1;i<=N_SRparm3+recdev_cycle;i++)
    {NP++; report2<<" "<<ParmLabel(NP);}
    report2<<endl<<runnumber<<" SR_parm "<<SR_parm<<" ";
    if(recdev_cycle>0) report2<<recdev_cycle_parm;
    report2<<endl;

    if(recdev_do_early>0)
    {
      report2<<runnumber<<" Recr_early ";
      for (i=recdev_early_start;i<=recdev_early_end;i++) {NP++; report2<<" "<<ParmLabel(NP);}
      report2<<endl<<runnumber<<" Recr_early ";
      for (i=recdev_early_start;i<=recdev_early_end;i++)  report2<<" "<<recdev(i);
      report2<<endl;
    }

    if(do_recdev>0)
    {
      report2<<runnumber<<" Recr_main ";
      for (i=recdev_start;i<=recdev_end;i++) {NP++; report2<<" "<<ParmLabel(NP);}
      report2<<endl<<runnumber<<" Recr_main ";
      for (i=recdev_start;i<=recdev_end;i++) report2<<" "<<recdev(i);
      report2<<endl;
    }

    if(Do_Forecast>0)
    {
      report2<<runnumber<<" Recr_fore ";
      for (i=recdev_end+1;i<=YrMax;i++) {NP++; report2<<" "<<ParmLabel(NP);}
      report2<<endl<<runnumber<<" Recr_fore ";
      for (i=recdev_end+1;i<=YrMax;i++) report2<<" "<<recdev(i);
      report2<<endl;
      report2<<runnumber<<" Impl_err ";
      for (i=endyr+1;i<=YrMax;i++) {NP++; report2<<" "<<ParmLabel(NP);}
      report2<<endl<<runnumber<<" Impl_err ";
      for (i=endyr+1;i<=YrMax;i++) report2<<" "<<Fcast_impl_error(i);
      report2<<endl;
    }

    report2<<runnumber<<" init_F ";
    for (i=1;i<=N_init_F;i++) {NP++; report2<<" "<<ParmLabel(NP);}
    report2<<endl<<runnumber<<" init_F ";
    for (i=1;i<=N_init_F;i++) report2<<" "<<init_F(i);
    report2<<endl;

    if(F_Method==2)
    {
      report2<<runnumber<<" F_rate ";
      for (i=1;i<=N_Fparm;i++) {NP++; report2<<" "<<ParmLabel(NP);}
      report2<<endl<<runnumber<<" F_rate ";
      for (i=1;i<=N_Fparm;i++) report2<<" "<<F_rate(i);
      report2<<endl;
    }

    if(Q_Npar2>0)
    {
      report2<<runnumber<<" Q_parm ";
      for (i=1;i<=Q_Npar2;i++) {NP++; report2<<" "<<ParmLabel(NP);}
      report2<<endl<<runnumber<<" Q_parm ";
      for (i=1;i<=Q_Npar2;i++) report2<<" "<<Q_parm(i);
      report2<<endl;
    }

    if(N_selparm2>0)
    {
      report2<<runnumber<<" Sel_parm ";
      for (i=1;i<=N_selparm2;i++) {NP++; report2<<" "<<ParmLabel(NP);}
      report2<<endl<<runnumber<<" Sel_parm "<<selparm<<endl;
    }

    if(Do_TG>0)
    {
      report2<<runnumber<<" Tag_parm ";
      for (f=1;f<=3*N_TG+2*Nfleet1;f++) {NP++; report2<<" "<<ParmLabel(NP);}
      report2<<endl<<runnumber<<" Tag_parm "<<TG_parm<<endl;
    }

    if(Do_CumReport==2)
    {
      if(Svy_N>0)
      for (f=1;f<=Nfleet;f++)
      if(Svy_N_fleet(f)>0)
      {
       report2 <<runnumber<<" Index:"<<f<<" Yr ";
       for (i=1;i<=Svy_N_fleet(f);i++)
       {
         ALK_time=Svy_ALK_time(f,i);
         report2<<data_time(ALK_time,f,3)<<" ";
       }
       report2 <<endl<<runnumber<<" Index:"<<f<<" OBS "<<Svy_obs(f)<<endl;
       if(Svy_errtype(f)>=0)  // lognormal or lognormal T_dist
       {report2 <<runnumber<<" Index:"<<f<<" EXP "<<mfexp(Svy_est(f))<<endl;}
       else  // normal error
       {report2 <<runnumber<<" Index:"<<f<<" EXP "<<Svy_est(f)<<endl;}
      }

      data_type=4;
      for (f=1;f<=Nfleet;f++)
      if(Nobs_l(f)>0)
      {
       report2 <<runnumber<<" Len:"<<f<<" YR ";
       for (i=1;i<=Nobs_l(f);i++)
       {
         t=Len_time_t(f,i);
         ALK_time=Len_time_ALK(f,i);
         report2<<data_time(ALK_time,f,3)<<" ";
       }
       report2 <<endl<<runnumber<<" Len:"<<f<<" effN "<<neff_l(f)<<endl;
      }

      data_type=5;
      for (f=1;f<=Nfleet;f++)
      if(Nobs_a(f)>0)
      {
       report2 <<runnumber<<" Age:"<<f<<" YR ";
       for (i=1;i<=Nobs_a(f);i++)
       {
         t=Age_time_t(f,i);
         ALK_time=Age_time_ALK(f,i);
         report2<<data_time(ALK_time,f,3)<<" ";
       }
       report2 <<endl<<runnumber<<" Age:"<<f<<" effN "<<neff_a(f)<<endl;
      }
    }
    report2<<endl;
    cout<<"ending report to cumreport.sso "<<endl;
  }

FUNCTION void write_SS_summary()
  {
    ofstream SS_smry("ss_summary.sso");
    SS_smry<<version_info<<endl;
    SS_smry<<datfilename<<" #_DataFile "<<endl;
    SS_smry<<ctlfilename<<" #_Control "<<endl;
    SS_smry<<"Run_Date: "<<ctime(&start);

    k=current_phase();
    if(k>max_lambda_phase) k=max_lambda_phase;
    SS_smry<<"#_"<<"LIKELIHOOD "<<endl;
    SS_smry<<"logL*Lambda Label"<<endl;
    SS_smry<<obj_fun<<" TOTAL_LogL"<<endl;
    if(F_Method>1) 
      {SS_smry<<catch_like*column(catch_lambda,k);} 
      else {SS_smry<<0.0;} 
      SS_smry <<" Catch "<<endl;
    SS_smry <<equ_catch_like*init_equ_lambda(k)<<" Equil_catch "<<endl;
      if(Svy_N>0) {SS_smry<<surv_like*column(surv_lambda,k);} 
      else {SS_smry<<0.0;} 
    SS_smry <<" Survey"<<endl;
      if(nobs_disc>0) {SS_smry<<disc_like*column(disc_lambda,k);}
      else {SS_smry<<0.0;} 
    SS_smry <<" Discard "<<endl;
      if(nobs_mnwt>0) {SS_smry<<mnwt_like*column(mnwt_lambda,k);}
      else {SS_smry<<0.0;} 
    SS_smry <<" Mean_body_wt "<<endl;
      if(Nobs_l_tot>0) {SS_smry<<length_like_tot*column(length_lambda,k);}
      else {SS_smry<<0.0;} 
    SS_smry <<" Length_comp "<<endl;
      if(Nobs_a_tot>0) {SS_smry<<age_like_tot*column(age_lambda,k);}
      else {SS_smry<<0.0;} 
    SS_smry <<" Age_comp "<<endl;
      if(nobs_ms_tot>0) {SS_smry<<sizeage_like*column(sizeage_lambda,k);}
      else {SS_smry<<0.0;} 
    SS_smry <<" Size_at_age "<<endl;
      if(SzFreq_Nmeth>0) {SS_smry<<SzFreq_like*column(SzFreq_lambda,k);}
      else {SS_smry<<0.0;} 
    SS_smry <<" SizeFreq "<<endl;
      if(Do_Morphcomp>0) {SS_smry<<Morphcomp_lambda(k)*Morphcomp_like;}
      else {SS_smry<<0.0;} 
    SS_smry <<" Morphcomp "<<endl;
      if(Do_TG>0) {SS_smry<<TG_like1*column(TG_lambda1,k)+TG_like2*column(TG_lambda2,k);}
      else {SS_smry<<0.0;} 
    SS_smry <<" Tag_Data "<<endl;
    SS_smry <<recr_like*recrdev_lambda(k)<<" Recruitment "<<endl;
    SS_smry <<Fcast_recr_like<<" Forecast_Recruitment "<<endl;
    SS_smry <<parm_like*parm_prior_lambda(k)<<" Parm_priors "<<endl;
      if(SoftBound>0) {SS_smry<<SoftBoundPen;}
      else {SS_smry<<0.0;} 
    SS_smry <<" Parm_softbounds "<<endl;
      if(N_parm_dev>0) {SS_smry<<(sum(parm_dev_like))*parm_dev_lambda(k);}
      else {SS_smry<<0.0;} 
    SS_smry <<" Parm_devs"<<endl;
      if(F_ballpark_yr>0) {SS_smry<<F_ballpark_lambda(k)*F_ballpark_like;}
      else {SS_smry<<0.0;} 
    SS_smry <<" F_Ballpark "<<endl;
    SS_smry <<CrashPen_lambda(k)*CrashPen<<" Crash_Pen "<<endl;

  NP=0;   // count of number of parameters
  active_count=0;
  SS_smry<<"#_"<<"BIOLOGY"<<endl;
  SS_smry<<"#_value se label"<<endl;
  for (j=1;j<=N_MGparm2;j++)
  {
    NP++;
    SS_smry<<MGparm(j)<<" ";
    if(active(MGparm(j))) {active_count++;  SS_smry<<CoVar(active_count,1);}  else  SS_smry<<0.0;
    SS_smry<<" "<<ParmLabel(NP)<<endl;
  }
  SS_smry<<"#_"<<"SPAWN_RECR"<<endl;
  SS_smry<<"#_value se label"<<endl;
  for (j=1;j<=N_SRparm3;j++)
  {
    NP++;
    SS_smry<<SR_parm(j)<<" ";
    if(active(SR_parm(j))) {active_count++;  SS_smry<<CoVar(active_count,1);} else  SS_smry<<0.0;
    SS_smry<<" "<<ParmLabel(NP)<<endl;
  }

  if(recdev_cycle>0)
  {
  for (j=1;j<=recdev_cycle;j++)
  {
    NP++;
    SS_smry<<recdev_cycle_parm(j)<<" ";
    if(active(recdev_cycle_parm(j))) {active_count++;  SS_smry<<CoVar(active_count,1);} else  SS_smry<<0.0;
    SS_smry<<" "<<ParmLabel(NP)<<endl;
  }
  }

  if(recdev_do_early>0)
  {
  for (j=recdev_early_start;j<=recdev_early_end;j++)
  {
    NP++;
    SS_smry<<recdev(j)<<" ";
    if(active(recdev_early)) {active_count++;  SS_smry<<CoVar(active_count,1);} else  SS_smry<<0.0;
    SS_smry<<" "<<ParmLabel(NP)<<endl;
  }
  }

  if(do_recdev>0)
  {
  for (j=recdev_start;j<=recdev_end;j++)
  {
    NP++;
    SS_smry<<recdev(j)<<" ";
    if(active(recdev1)||active(recdev2)) {active_count++;  SS_smry<<CoVar(active_count,1);} else  SS_smry<<0.0;
    SS_smry<<" "<<ParmLabel(NP)<<endl;
  }
  }

  if(Do_Forecast>0)
  {
  for (j=recdev_end+1;j<=YrMax;j++)
  {
    NP++;
    SS_smry<<Fcast_recruitments(j)<<" ";
    if(active(Fcast_recruitments)) {active_count++;  SS_smry<<CoVar(active_count,1);} else  SS_smry<<0.0;
    SS_smry<<" "<<ParmLabel(NP)<<endl;
  }

  for (j=endyr+1;j<=YrMax;j++)
  {
    NP++;
    SS_smry<<Fcast_impl_error(j)<<" ";
    if(active(Fcast_impl_error)) {active_count++;  SS_smry<<CoVar(active_count,1);} else  SS_smry<<0.0;
    SS_smry<<" "<<ParmLabel(NP)<<endl;
  }
  }

  SS_smry<<"#_"<<"Fish_Mort"<<endl;
  SS_smry<<"#_value se label"<<endl;
  if(N_init_F>0)
  for (j=1;j<=N_init_F;j++)
  {
    NP++;
    SS_smry<<init_F(j)<<" ";
    if(active(init_F(j))) {active_count++;  SS_smry<<CoVar(active_count,1);} else  SS_smry<<0.0;
    SS_smry<<" "<<ParmLabel(NP)<<endl;
  }

  if(F_Method==2)
  for (j=1;j<=N_Fparm;j++)
  {
    NP++;
    SS_smry<<F_rate(j)<<" ";
    if(active(F_rate(j))) {active_count++;  SS_smry<<CoVar(active_count,1);} else  SS_smry<<0.0;
    SS_smry<<" "<<ParmLabel(NP)<<endl;
  }

  SS_smry<<"#_"<<"Catchability"<<endl;
  SS_smry<<"#_value se label"<<endl;
  if(Q_Npar2>0)
  for (j=1;j<=Q_Npar2;j++)
  {
    NP++;
    SS_smry<<Q_parm(j)<<" ";
    if(active(Q_parm(j))) {active_count++;  SS_smry<<CoVar(active_count,1);} else  SS_smry<<0.0;
    SS_smry<<" "<<ParmLabel(NP)<<endl;
  }

  SS_smry<<"#_"<<"Selectivity"<<endl;
  SS_smry<<"#_value se label"<<endl;
  if(N_selparm2>0)
  for (j=1;j<=N_selparm2;j++)
  {
    NP++;
    SS_smry<<selparm(j)<<" ";
    if(active(selparm(j))) {active_count++;  SS_smry<<CoVar(active_count,1);} else  SS_smry<<0.0;
    SS_smry<<" "<<ParmLabel(NP)<<endl;
  }

  SS_smry<<"#_"<<"Tag_Recapture"<<endl;
  SS_smry<<"#_value se label"<<endl;
  if(Do_TG>0)
  for (j=1;j<=3*N_TG+2*Nfleet1;j++)
  {
    NP++;
    SS_smry<<TG_parm(j)<<" ";
    if(active(TG_parm(j))) {active_count++;  SS_smry<<CoVar(active_count,1);} else  SS_smry<<0.0;
    SS_smry<<" "<<ParmLabel(NP)<<endl;
  }

  SS_smry<<"#_"<<"Parm_Dev"<<endl;
  SS_smry<<"#_value se label"<<endl;
  if(N_parm_dev>0)
  for (i=1;i<=N_parm_dev;i++)
  for (j=parm_dev_minyr(i);j<=parm_dev_maxyr(i);j++)
  {
    NP++;
    SS_smry<<parm_dev(i,j)<<" ";
    if(parm_dev_PH(i)>0) 
      {active_count++;  SS_smry<<CoVar(active_count,1);}
       else
      {SS_smry<<0.0;}
    SS_smry<<" "<<ParmLabel(NP)<<endl;
  }

  SS_smry<<"#_"<<"Derived_Quantities"<<endl;
  SS_smry<<"#_"<<"Spawn_Bio"<<endl;
  SS_smry<<"#_value se label"<<endl;
  for (j=1;j<=N_STD_Yr;j++)
  {
    NP++; active_count++; 
    SS_smry<<SPB_std(j)<<" "<<CoVar(active_count,1)<<" "<<ParmLabel(NP)<<endl;
  }

  SS_smry<<"#_"<<"Recruitment"<<endl;
  SS_smry<<"#_value se label"<<endl;
  for (j=1;j<=N_STD_Yr;j++)
  {
    NP++; active_count++; 
    SS_smry<<recr_std(j)<<" "<<CoVar(active_count,1)<<" "<<ParmLabel(NP)<<endl;
  }

  SS_smry<<"#_"<<"SPR_std"<<endl;
  SS_smry<<"#_value se label"<<endl;
  for (j=1;j<=N_STD_Yr_Ofish;j++)
  {
    NP++; active_count++; 
    SS_smry<<SPR_std(j)<<" "<<CoVar(active_count,1)<<" "<<ParmLabel(NP)<<endl;
  }

  SS_smry<<"#_"<<"F_std"<<endl;
  SS_smry<<"#_value se label"<<endl;
  for (j=1;j<=N_STD_Yr_F;j++)
  {
    NP++; active_count++; 
    SS_smry<<F_std(j)<<" "<<CoVar(active_count,1)<<" "<<ParmLabel(NP)<<endl;
  }

  SS_smry<<"#_"<<"Depletion_std"<<endl;
  SS_smry<<"#_value se label"<<endl;
  for (j=1;j<=N_STD_Yr_Dep;j++)
  {
    NP++; active_count++; 
    SS_smry<<depletion(j)<<" "<<CoVar(active_count,1)<<" "<<ParmLabel(NP)<<endl;
  }

  SS_smry<<"#_"<<"Mgmt_Quantity "<<N_STD_Mgmt_Quant<<endl;
  SS_smry<<"#_value se label"<<endl;
  for (j=1;j<=N_STD_Mgmt_Quant;j++)
  {
    NP++; active_count++; 
    SS_smry<<Mgmt_quant(j)<<" "<<CoVar(active_count,1)<<" "<<ParmLabel(NP)<<endl;
  }

  SS_smry<<"#_"<<"Extra_stdev"<<endl;
  SS_smry<<"#_value se label"<<endl;
  for (j=1;j<=Extra_Std_N;j++)
  {
    NP++; active_count++; 
    SS_smry<<Extra_Std(j)<<" "<<CoVar(active_count,1)<<" "<<ParmLabel(NP)<<endl;
  }

    SS_smry.close();
    cout<<" ending report to SS_summary.sso"<<endl;
    return;
  }

//********************************************************************
 /*  SS_Label_FUNCTION 37 write_rebuilder_output */
FUNCTION void write_rebuilder_output()
  {
    if(rundetail>0 && mceval_counter==0) cout<<" produce output for rebuilding package"<<endl;
    ofstream rebuilder("rebuild.sso",ios::app);
    ofstream rebuild_dat("rebuild.dat");

    if(mceval_counter==0) // writing to rebuild.dat
    {
      rebuild_dat<<"#Title, #runnumber: "<<runnumber<<" "<<datfilename<<" "<<ctlfilename<<
         " "<<obj_fun<<" "<<SPB_yr(styr-2)<<" "<<SPB_yr(endyr+1)<<" StartTime: "<<ctime(&start);
      rebuild_dat<<"SSv3_default_rebuild.dat"<<endl;
      rebuild_dat<<"# Number of sexes"<<endl<<gender<<endl;
      rebuild_dat<<"# Age range to consider (minimum age; maximum age)"<<endl<<0<<" "<<nages<<endl;
      rebuild_dat<<"# Number of fleets"<<endl<<Nfleet1<<endl;
      rebuild_dat<<"# First year of projection (Yinit)"<<endl<<Rebuild_Yinit<<endl;
      rebuild_dat<<"# First Year of rebuilding period (Ydecl)"<<endl<<Rebuild_Ydecl<<endl;
      rebuild_dat<<"# Number of simulations"<<endl<<1000<<endl;
      rebuild_dat<<"# Maximum number of years"<<endl<<500<<endl;
      rebuild_dat<<"# Conduct projections with multiple starting values (0=No;else yes)"<<endl<<0<<endl;
      rebuild_dat<<"# Number of parameter vectors"<<endl<<1000<<endl;
      rebuild_dat<<"# Is the maximum age a plus-group (1=Yes;2=No)"<<endl<<1<<endl;
      rebuild_dat<<"# Generate future recruitments using historical recruitments (1)  historical recruits/spawner (2)  or a stock-recruitment (3)"<<endl<<3<<endl;
      rebuild_dat<<"# Constant fishing mortality (1) or constant Catch (2) projections"<<endl<<1<<endl;
      rebuild_dat<<"# Fishing mortality based on SPR (1) or actual rate (2)"<<endl<<1<<endl;
      rebuild_dat<<"# Pre-specify the year of recovery (or -1) to ignore"<<endl<<-1<<endl;
      rebuild_dat<<"# Fecundity-at-age"<<endl;
    }

    // stuff written to both rebuild.dat and rebuild.SSO
//a. "blank line" with run info
    if( mceval_phase() ) rebuilder<<"# mceval phase, cnt="<<mceval_counter<<", StartTime: "<<ctime(&start);
                    else rebuilder<<"# in maximization mode, StartTime: "<<ctime(&start);

    if(mceval_counter==0) rebuild_dat <<"#"<< age_vector << " #runnumber: "<<runnumber<<" "<<datfilename<<" "<<ctlfilename<<" "<<obj_fun<<
      " "<<SPB_yr(styr-2)<<" "<<SPB_yr(endyr+1)<<endl;

//b.  fecundity-at-age
    t = styr+(Rebuild_Yinit-styr)*nseas;
    dvar_vector tempvec2(0,nages);
    dvar_vector tempvec3(0,nages);
    tempvec_a.initialize(); tempvec2.initialize();
    for (p=1;p<=pop;p++)
    for (g=1;g<=gmorph;g++)
    if(sx(g)==1)
    {
//  NEED to adjust for spawning timing within season
      tempvec_a+=elem_prod(fec(g),natage(t+spawn_seas-1,p,g));
      tempvec2+=natage(t+spawn_seas-1,p,g);
    }
    tempvec_a= elem_div(tempvec_a,tempvec2);
    rebuilder<<tempvec_a<<" #female fecundity; weighted by N in year Y_init across morphs and areas"<<endl;
    if(mceval_counter==0)
    {
      rebuild_dat<<tempvec_a<<" #female fecundity; weighted by N in year Y_init across morphs and areas"<<endl;
      rebuild_dat<<"# Age specific selectivity and weight adjusted for discard and discard mortality"<<endl;
    }

//c.  Weight-at-age and selectivity-at-age (ordered by sex and fleet).
    // use the deadfish vectors that account for discard and for mortality of discards
    // average across morphs and areas using N_at_Age in year Yinit and across seasons using Fcast_RelF
    for (gg=1;gg<=gender;gg++)
    for (f=1;f<=Nfleet1;f++)
    {
      tempvec_a.initialize();tempvec2.initialize();tempvec3.initialize(); j=0;
      for (s=1;s<=nseas;s++)
      for (p=1;p<=pop;p++)
      if (fleet_area(f)==p && Fcast_RelF_Use(s,f)>0.0)   // active fishery in this area in endyr
      {
        j=1;
        for (g=1;g<=gmorph;g++)
        if(sx(g)==gg)
        {
          tempvec_a+=elem_prod(fish_body_wt(t,g,f),natage(t+s-1,p,g)*Fcast_RelF_Use(s,f));  // body wt
          tempvec2+=elem_prod(sel_al_3(s,g,f),natage(t+s-1,p,g)*Fcast_RelF_Use(s,f));  //no wt
          tempvec3+=natage(t+s-1,p,g)*Fcast_RelF_Use(s,f);
        }
      }
      if(j==1)
      {
        tempvec_a= elem_div(tempvec_a,tempvec3);
        tempvec2 = elem_div(tempvec2,tempvec3);
        rebuilder <<tempvec_a<< " #bodywt for gender,fleet: "<<gg<<" / "<<f<<" "<<fleetname(f)<<endl;
        rebuilder <<tempvec2<< " #selex for gender,fleet: "<<gg<<" / "<<f<<" "<<fleetname(f)<<endl;
        if(mceval_counter==0)
        {
          rebuild_dat << " #wt and selex for gender,fleet: "<<gg<<" "<<f<<" "<<fleetname(f)<<endl;
          rebuild_dat <<tempvec_a<<endl<<tempvec2<< endl;
        }
      }
    }

//d.  Natural mortality and numbers-at-age for year Yinit  (females then males).
    if(mceval_counter==0) rebuild_dat<<"# M and current age-structure in year Yinit: "<<Rebuild_Yinit<<endl;

    for (gg=1;gg<=gender;gg++)
    {
      tempvec_a.initialize();tempvec2.initialize();tempvec3.initialize();
      for (p=1;p<=pop;p++)
      {
        for (g=1;g<=gmorph;g++)
        if(sx(g)==gg && use_morph(g)>0)
        {
          tempvec_a+=elem_prod(natM(1,GP3(g)),natage(t,p,g));  tempvec2+=natage(t,p,g);  //  note, uses season 1 only
        }
      }
      tempvec_a=elem_div(tempvec_a,tempvec2);
      rebuilder<<tempvec_a<<" #mean M for year Yinit: "<<Rebuild_Yinit<<" sex: "<<gg<<endl;
      rebuilder<<tempvec2<<" #numbers for year Yinit: "<<Rebuild_Yinit<<" sex: "<<gg<<endl;
      if(mceval_counter==0) rebuild_dat<<" # gender = "<<gg<<endl<< tempvec_a<<endl<<tempvec2<< endl;
    }

//e.  Numbers-at-age for year Ydecl  (females then males).
    t = styr+(Rebuild_Ydecl-styr)*nseas;
    if(mceval_counter==0) rebuild_dat<<"# Age-structure at Ydeclare= "<<Rebuild_Ydecl<<endl;
    for (gg=1;gg<=gender;gg++)
    {
      tempvec_a.initialize();tempvec2.initialize();tempvec3.initialize();
      for (p=1;p<=pop;p++)
      {
        for (g=1;g<=gmorph;g++)
        if(sx(g)==gg && use_morph(g)>0)
        {
          tempvec2+=natage(t,p,g);
        }
      }
      rebuilder <<tempvec2<<" #numbers for year Ydeclare: "<<Rebuild_Ydecl<<" sex: "<<gg<< endl;
      if(mceval_counter==0) rebuild_dat<<tempvec2<< endl;
    }

    k=endyr;
    if(Rebuild_Yinit>k) k=Rebuild_Yinit;

//f. "blank line" used for header for following lines
    rebuilder <<"#R0 "<<years<< " #years"<<endl;

//g. recruitment
    rebuilder << exp_rec(styr-2,4)<<" ";
    for(y=styr;y<=k;y++) {rebuilder<<exp_rec(k,4)<<" "; }
    rebuilder << " #Recruits"<<endl;

//h. spawnbio
    rebuilder << SPB_yr(styr-2)<<" "<<SPB_yr(styr,k) <<" #SpawnBio"<<endl;

//i. steepness; SigmaR; rho
    rebuilder << SR_parm(2) <<" "<< sigmaR <<" "<< SR_parm(N_SRparm2) <<" # spawn-recr steepness, sigmaR, autocorr"<< endl;

    if(mceval_counter==0)
    {
      rebuild_dat<<"# Year for Tmin Age-structure (set to Ydecl by SS)"<<endl<<Rebuild_Ydecl<<endl;

      rebuild_dat<<"#  recruitment and biomass"<<endl<<"# Number of historical assessment years"<<endl<<k-styr+2<<endl;
      rebuild_dat<<"# Historical data"<<endl<<"# year recruitment spawner in B0 in R project in R/S project"<<endl;
      rebuild_dat<<styr-1<<" "<<years;
      if(Rebuild_Yinit>endyr) rebuild_dat<<" "<<Rebuild_Yinit;
      rebuild_dat<<" #years (with first value representing R0)"<<endl;
      rebuild_dat<<exp_rec(styr-2,4)<<" ";
      for(y=styr;y<=k;y++) {rebuild_dat<<exp_rec(y,4)<<" ";}
      rebuild_dat<<" #recruits; first value is R0 (virgin)"<< endl;
      rebuild_dat<<SPB_yr(styr-2)<<" "<<SPB_yr(styr,k) <<" #spbio; first value is SSB_virgin (virgin)"<< endl;
      rebuild_dat<<1<<" ";
      for (y=styr;y<=k;y++) rebuild_dat<<0<<" ";
      rebuild_dat<<" # in Bzero"<<endl;
      rebuild_dat<<0<<" ";
      for (y=styr;y<=k-3;y++) rebuild_dat<<1<<" ";
      rebuild_dat<<" 0 0 0 # in R project"<<endl;
      rebuild_dat<<0<<" ";
      for (y=styr;y<=k-3;y++) rebuild_dat<<1<<" ";
      rebuild_dat<<" 0 0 0 # in R/S project"<<endl;
      rebuild_dat<<"# Number of years with pre-specified catches"<<endl<<0<<endl;
      rebuild_dat<<"# catches for years with pre-specified catches go next"<<endl;
//      rebuild_dat<<"# Number of future recruitments to override"<<endl<<0<<endl;
//      rebuild_dat<<"# Process for overiding (-1 for average otherwise index in data list)"<<endl;

      rebuild_dat<<"# Number of future recruitments to override"<<endl;
      rebuild_dat<<Rebuild_Yinit - Rebuild_Ydecl<<endl;
      rebuild_dat<<"# Process for overiding (-1 for average otherwise index in data list)"<<endl;
      if(Rebuild_Yinit>=Rebuild_Ydecl+1)
      {
        for (y=Rebuild_Ydecl+1;y<=Rebuild_Yinit;y++) rebuild_dat<<y<<" "<<1<<" "<<y<<endl;
      }

      rebuild_dat<<"# Which probability to product detailed results for (1=0.5; 2=0.6; etc.)"<<endl<<3<<endl;
      rebuild_dat<<"# Steepness sigma-R Auto-correlation"<<endl<<SR_parm(2) <<" "<< sigmaR <<" "<< 0 << endl;
      rebuild_dat<<"# Target SPR rate (FMSY Proxy); manually change to SPR_MSY if not using SPR_target"<<endl<<SPR_target<<endl;
      rebuild_dat<<"# Discount rate (for cumulative catch)"<<endl<<0.1<<endl;
      rebuild_dat<<"# Truncate the series when 0.4B0 is reached (1=Yes)"<<endl<<0<<endl;
      rebuild_dat<<"# Set F to FMSY once 0.4B0 is reached (1=Yes)"<<endl<<0<<endl;
      rebuild_dat<<"# Maximum possible F for projection (-1 to set to FMSY)"<<endl<<-1<<endl;
      rebuild_dat<<"# Defintion of recovery (1=now only;2=now or before)"<<endl<<2<<endl;
      rebuild_dat<<"# Projection type"<<endl<<4<<endl;
      rebuild_dat<<"# Definition of the 40-10 rule"<<endl<<10<<" "<<40<<endl;
      rebuild_dat<<"# Calculate coefficients of variation (1=Yes)"<<endl<<0<<endl;
      rebuild_dat<<"# Number of replicates to use"<<endl<<10<<endl;
      rebuild_dat<<"# Random number seed"<<endl<<-99004<<endl;
      rebuild_dat<<"# File with multiple parameter vectors "<<endl<<"rebuild.SSO"<<endl;
      rebuild_dat<<"# User-specific projection (1=Yes); Output replaced (1->9)"<<endl<<"0  5"<<endl;
      rebuild_dat<<"# Catches and Fs (Year; 1/2/3 (F or C or SPR); value); Final row is -1"<<endl;
      rebuild_dat<< k <<" 1 1"<<endl<<"-1 -1 -1"<<endl;
      rebuild_dat<<"# Fixed catch project (1=Yes); Output replaced (1->9); Approach (-1=Read in else 1-9)"<<endl;
      rebuild_dat<<"0 2 -1"<<endl;
      tempvec_a(1,Nfleet)=colsum(Fcast_RelF_Use);
      rebuild_dat<<"# Split of Fs"<<endl;
      rebuild_dat<<Rebuild_Yinit<<" ";
      for(f=1;f<=Nfleet;f++)
      if(fleet_type(f)<=2)
      {rebuild_dat<<" "<<tempvec_a(f)<<endl;}
      rebuild_dat<<"-1 ";
      for (f=1;f<=Nfleet;f++) rebuild_dat<<" 1";
      rebuild_dat<<endl;
      rebuild_dat<<"# Yrs to define T_target for projection type 4 (a.k.a. 5 pre-specified inputs)"<<endl;
      rebuild_dat<<endyr+6<<" "<<endyr+7<<" "<<endyr+8<<" "<<endyr+9<<" "<<endyr+10<<" "<<endl;
      rebuild_dat<<"# Year for probability of recovery"<<endl;
      rebuild_dat<<endyr+10<<" "<<endyr+11<<" "<<endyr+12<<" "<<endyr+13<<" "<<endyr+14<<" "<<endyr+15<<" "<<endyr+16<<" "<<endyr+17<<endl;
      rebuild_dat<<"# Time varying weight-at-age (1=Yes;0=No)"<<endl<<0<<endl;
      rebuild_dat<<"# File with time series of weight-at-age data"<<endl<<"none"<<endl;
      rebuild_dat<<"# Use bisection (0) or linear interpolation (1)"<<endl<<1<<endl;
      rebuild_dat<<"# Target Depletion"<<endl<<0.4<<endl;
      rebuild_dat<<"# CV of implementation error"<<endl<<0<<endl;
    }
  }  //  end output of rebuilding quantities

//********************************************************************
 /*  SS_Label_FUNCTION 38 write_nudata */
FUNCTION void write_nudata()
  {
//  code for multinomial distribution developed by Ian Stewart, Oct 2005
  random_number_generator radm(long(time(&start)));

  dvector temp_mult(1,50000);
  dvector temp_probs(1,nlen_bin2);
  int compindex;
  dvector temp_probs2(1,n_abins2);
  int Nudat;
//  create bootstrap data files; except first file just replicates the input and second is the estimate without error
  for (i=1;i<=1234;i++) temp = randn(radm);
  cout << " N_nudata: " << N_nudata << endl;
  ofstream report1("data.ss_new");
  report1<<version_info<<endl<<version_info2<<endl<<version_info3<<endl<<"#_Start_time: "<<ctime(&start);
  report1  << "#_Number_of_datafiles: " << N_nudata << endl;
  for (Nudat=1;Nudat<=N_nudata;Nudat++)
  {
  if(Nudat==1)
  {
    report1<<Data_Comments<<endl;
    report1 << "#_observed data: "<< endl;
  }
  else if(Nudat==2)
  {report1 << "#_expected values with no error added " << endl;}
  else
  {report1 << "#_bootstrap file: " << Nudat-2 << endl;}
  report1<<version_info<<endl;
  report1 << styr << " #_StartYr"<<endl;
  report1 << endyr <<" #_EndYr"<< endl;
  report1 << nseas <<" #_Nseas"<< endl;
  report1 << 12.*seasdur<<" #_months/season"<< endl;
  report1 << N_subseas<<" #_Nsubseasons (even number, minimum is 2)"<<endl;
  report1 << spawn_month <<" #_spawn_month"<< endl;
  report1 << gender<<" #_Ngenders"<< endl;
  report1 << nages<<" #_Nages=accumulator age"<< endl;
  report1 << pop<<" #_Nareas"<<endl;
  report1 << Nfleet<<" #_Nfleets (including surveys)"<< endl;
  report1<<"#_fleet_type: 1=catch fleet; 2=bycatch only fleet; 3=survey; 4=ignore "<<endl;
  report1<<"#_survey_timing: -1=for use of catch-at-age to override the month value associated with a datum "<<endl;
  report1<<"#_fleet_area:  area the fleet/survey operates in "<<endl;
  report1<<"#_units of catch:  1=bio; 2=num (ignored for surveys; their units read later)"<<endl;
  report1<<"#_catch_mult: 0=no; 1=yes"<<endl;
  report1<<"#_rows are fleets"<<endl<<"#_fleet_type timing area units need_catch_mult fleetname"<<endl;
  for (f=1;f<=Nfleet;f++)
  {report1<<fleet_setup(f)<<" "<<fleetname(f)<<"  # "<<f<<endl;}
  if(N_bycatch>0)
  {
 /*
    report1<<"#Bycatch_fleet_input_goes_next"<<endl;
    report1<<"#a:  1=use retention curve like other fleets; 2=all discarded"<<endl;
    report1<<"#b:  1=deadfish in MSY, ABC and other benchmark and forecast output; 2=omit from MSY and ABC (but still include the mortality)"<<endl;
    report1<<"#c:  1=Fmult scales with other fleets; 2=bycatch F constant at input value; 3=bycatch F form range of years"<<endl;
    report1<<"#d:  F or first year of range"<<endl;
    report1<<"#e:  last year of range"<<endl;
    report1<<"#   a   b   c   d   e"<<endl;
    report1<<bycatch_setup<<endl;
 */
  }

  if(Nudat==1)  // report back the input data
  {

  report1<<"#_Catch data: yr, seas, fleet, catch, catch_se"<<endl;
  report1<<"#_catch_se:  standard error of log(catch)"<<endl;
  report1<<"#_NOTE:  catch data is ignored for survey fleets"<<endl;
  k=0;
  for(f=1;f<=Nfleet;f++)
  {
    if(fleet_type(f)<=2)
    {
      for(y=styr-1;y<=endyr;y++)
      {
        for(s=1;s<=nseas;s++)
        {
          k++;
          t=styr+(y-styr)*nseas+s-1;
          if(y==styr-1) {g=-999;} else {g=y;}
          report1<<g<<" "<<s<<" "<<f<<" "<<catch_ret_obs(f,t)<<" "<<catch_se(t,f)<<endl;
        }
      }
    }
  }
  report1<<"-9999 0 0 0 0"<<endl<<"#"<<endl;

  report1 << " #_CPUE_and_surveyabundance_observations"<< endl;
  report1<<"#_Units:  0=numbers; 1=biomass; 2=F; >=30 for special types"<<endl;
  report1<<"#_Errtype:  -1=normal; 0=lognormal; >0=T"<<endl;
  report1<<"#_SD_Report: 0=no sdreport; 1=enable sdreport"<<endl;
  report1<<"#_Fleet Units Errtype SD_Report"<<endl;
  for (f=1;f<=Nfleet;f++) report1<<f<<" "<<Svy_units(f)<<" "<<Svy_errtype(f)<<" "<<Svy_sdreport(f)<<" # "<<fleetname(f)<<endl;
  report1<<"#_yr month fleet obs stderr"<<endl;

    if(Svy_N>0)
    for (f=1;f<=Nfleet;f++)
    for (i=1;i<=Svy_N_fleet(f);i++)
    {
      t=Svy_time_t(f,i);
      ALK_time=Svy_ALK_time(f,i);
      report1 << Show_Time(t,1)<<" "<<Svy_super(f,i)*data_time(ALK_time,f,1)<<" "<<f*Svy_use(f,i)<<" ";
      report1 << Svy_obs(f,i)<<" "<<Svy_se_rd(f,i)<<" #_ "<<fleetname(f)<<endl;
    }
    report1<<"-9999 1 1 1 1 # terminator for survey observations "<<endl;

  report1<<"#"<<endl<<Ndisc_fleets<<" #_N_fleets_with_discard"<<endl;
  report1<<"#_discard_units (1=same_as_catchunits(bio/num); 2=fraction; 3=numbers)"<< endl;
  report1<<"#_discard_errtype:  >0 for DF of T-dist(read CV below); 0 for normal with CV; -1 for normal with se; -2 for lognormal; -3 for trunc normal with CV"<<endl;
  report1<<"# note, only have units and errtype for fleets with discard "<<endl;
  report1<<"#_Fleet units errtype"<<endl;
  if(Ndisc_fleets>0)
  {
    for (f=1;f<=Nfleet;f++)
    if(disc_units(f)>0) report1<<f<<" "<<disc_units(f)<<" "<<disc_errtype(f)<<" # "<<fleetname(f)<<endl;
    report1<<"#_yr month fleet obs stderr"<<endl;
    for (f=1;f<=Nfleet;f++)
    for (i=1;i<=disc_N_fleet(f);i++)
    {
      ALK_time=disc_time_ALK(f,i);
      report1 << Show_Time(disc_time_t(f,i),1)<<" "<<yr_disc_super(f,i)*data_time(ALK_time,f,1)<<" "<<f*yr_disc_use(f,i)<<" ";
      report1 << obs_disc(f,i)<< " "<< cv_disc(f,i)<<" #_ "<<fleetname(f)<<endl;
    }
  }
  else
  {
    report1<<"# ";
  }
  report1<<"-9999 0 0 0.0 0.0 # terminator for discard data "<<endl;

  report1 <<"#"<<endl<< do_meanbodywt <<" #_use meanbodysize_data (0/1)"<< endl;
  if(nobs_mnwt_rd==0) report1<<"#_COND_";
  report1<<DF_bodywt<<" #_DF_for_meanbodysize_T-distribution_like"<<endl;
  report1<<"# note:  use positive partition value for mean body wt, negative partition for mean body length "<<endl;
  report1<<"#_yr month fleet part obs stderr"<<endl;
  if(nobs_mnwt>0)
   {
   for (i=1;i<=nobs_mnwt;i++)
    {
     f=abs(mnwtdata(3,i));
     report1 << Show_Time(mnwtdata(1,i),1)<<" "<<mnwtdata(2,i)<<" "<<mnwtdata(3,i)<<" "<<mnwtdata(4,i)<<" "<<
     mnwtdata(5,i)<<" "<<mnwtdata(6,i)-var_adjust(3,f)<<" #_ "<<fleetname(f)<<endl;
    }
   }
  if(do_meanbodywt==0) report1<<"# ";
  report1<<" -9999 0 0 0 0 0 # terminator for mean body size data "<<endl;

  report1<<"#"<<endl<<"# set up population length bin structure (note - irrelevant if not using size data and using empirical wtatage"<<endl;
  report1<<LenBin_option<<" # length bin method: 1=use databins; 2=generate from binwidth,min,max below; 3=read vector"<<endl;
  if(LenBin_option==1)
  {report1<<"# no additional input for option 1"<<endl;
    report1<<"# read binwidth, minsize, lastbin size for option 2"<<endl;
    report1<<"# read N poplen bins, then vector of bin lower boundaries, for option 3"<<endl;}
  else if(LenBin_option==2)
  {
    report1<<binwidth2<<" # binwidth for population size comp "<<endl;
    report1<<minLread<<" # minimum size in the population (lower edge of first bin and size at age 0.00) "<<endl;
    report1<<maxLread<<" # maximum size in the population (lower edge of last bin) "<<endl;
  }
  else
  {
    report1<<nlength<<" # number of population size bins "<<endl;
    report1<<len_bins<<endl;
  }

  report1<<use_length_data<<" # use length composition data (0/1)"<<endl;
  if(use_length_data>0)
  {
  report1<<"#_mintailcomp: upper and lower distribution for females and males separately are accumulated until exceeding this level."<<endl;
  report1<<"#_addtocomp:  after accumulation of tails; this value added to all bins"<<endl;
  report1<<"#_males and females treated as combined gender below this bin number "<<endl;
  report1<<"#_compressbins: accumulate upper tail by this number of bins; acts simultaneous with mintailcomp; set=0 for no forced accumulation"<<endl;
  report1<<"#_Comp_Error:  0=multinomial, 1=dirichlet"<<endl;
  report1<<"#_Comp_Error2:  parm number  for dirichlet"<<endl;
  report1<<"#_minsamplesize: minimum sample size; set to 1 to match 3.24, minimum value is 0.001"<<endl;
  report1<<"#_mintailcomp addtocomp combM+F CompressBins CompError ParmSelect minsamplesize"<<endl;
  for (f=1;f<=Nfleet;f++)
  {report1<<min_tail_L(f)<<" "<<min_comp_L(f)<<" "<<CombGender_L(f)<<" "<<AccumBin_L(f)<<" "<<Comp_Err_L(f)<<" "<<Comp_Err_L2(f)<<" "<<min_sample_size_L(f)<<" #_fleet:"<<f<<"_"<<fleetname(f)<<endl;}

  report1<<"# sex codes:  0=combined; 1=use female only; 2=use male only; 3=use both as joint sexxlength distribution"<<endl;
  report1<<"# partition codes:  (0=combined; 1=discard; 2=retained"<<endl;
  report1<<nlen_bin<<" #_N_LengthBins; then enter lower edge of each length bin"<<endl<<len_bins_dat<<endl;
//  report1<<nobsl_rd<<" #_N_Length_obs"<<endl;
  report1<<"#_yr month fleet sex part Nsamp datavector(female-male)"<<endl;
  if(nobsl_rd>0)
  {
    for(i=0;i<=nobsl_rd-1;i++)
    { report1<<lendata[i]<<endl;}
  }
    report1<<-9999.<<" ";
    for(j=2;j<=6+nlen_bin2;j++) report1<<"0 ";
    report1<<endl;
  }
  else
  {
    report1<<"# see manual for format of length composition data "<<endl;
  }

   report1 <<"#"<<endl<<n_abins<<" #_N_age_bins"<<endl;
  if(n_abins>0)
  {
    report1<<age_bins1<<endl;
  }
  else
  {
    report1<<"# ";
  }
  report1 << N_ageerr <<" #_N_ageerror_definitions"<< endl;
  if(N_ageerr>0) report1 << age_err_rd << endl;

  report1<<"#_mintailcomp: upper and lower distribution for females and males separately are accumulated until exceeding this level."<<endl;
  report1<<"#_addtocomp:  after accumulation of tails; this value added to all bins"<<endl;
  report1<<"#_males and females treated as combined gender below this bin number "<<endl;
  report1<<"#_compressbins: accumulate upper tail by this number of bins; acts simultaneous with mintailcomp; set=0 for no forced accumulation"<<endl;
  report1<<"#_Comp_Error:  0=multinomial, 1=dirichlet"<<endl;
  report1<<"#_Comp_Error2:  parm number  for dirichlet"<<endl;
  report1<<"#_minsamplesize: minimum sample size; set to 1 to match 3.24, minimum value is 0.001"<<endl;
  report1<<"#_mintailcomp addtocomp combM+F CompressBins CompError ParmSelect minsamplesize"<<endl;
  for (f=1;f<=Nfleet;f++)
  {
    if (n_abins <= 0) report1<<"# ";
    report1<<min_tail_A(f)<<" "<<min_comp_A(f)<<" "<<CombGender_A(f)<<" "<<AccumBin_A(f)<<" "<<Comp_Err_A(f)<<" "<<Comp_Err_A2(f)<<" "<<min_sample_size_A(f)<<" #_fleet:"<<f<<"_"<<fleetname(f)<<endl;
  }

  if (n_abins <= 0) report1<<"# ";
  report1<<Lbin_method<<" #_Lbin_method_for_Age_Data: 1=poplenbins; 2=datalenbins; 3=lengths"<<endl;
  report1<<"# sex codes:  0=combined; 1=use female only; 2=use male only; 3=use both as joint sexxlength distribution"<<endl;
  report1<<"# partition codes:  (0=combined; 1=discard; 2=retained"<<endl;
  report1<<"#_yr month fleet sex part ageerr Lbin_lo Lbin_hi Nsamp datavector(female-male)"<<endl;
  if(nobsa_rd>0)
  {
    for(i=0;i<=nobsa_rd-1;i++)
    { report1<<Age_Data[i]<<endl;}
  }
  f=exp_a_temp.size()+8;
  if (n_abins <= 0) report1<<"# ";
  report1 << "-9999 ";
  for(i=1;i<=f;i++) report1<<" 0";
  report1<<endl;

  report1<<"#"<<endl<<use_meansizedata<<" #_Use_MeanSize-at-Age_obs (0/1)"<<endl;
  if(use_meansizedata>0)
  {
  report1<<"# sex codes:  0=combined; 1=use female only; 2=use male only; 3=use both as joint sexxlength distribution"<<endl;
  report1<<"# partition codes:  (0=combined; 1=discard; 2=retained"<<endl;
  report1<<"# ageerr codes:  positive means mean length-at-age; negative means mean bodywt_at_age"<<endl;
  report1<<"#_yr month fleet sex part ageerr ignore datavector(female-male)"<<endl;
  report1<<"#                                          samplesize(female-male)"<<endl;
  if(nobs_ms_rd>0)
  {
    if(finish_starter==999)
    {
      for (i=1;i<=nobs_ms_rd;i++)
      {
        report1<<sizeAge_Data[i]<<endl;
      }
    }
    else
    {
      for (i=0;i<=nobs_ms_rd-1;i++)
      {
        report1<<sizeAge_Data[i]<<endl;
      }
    }
    report1<<"-9999 ";
    for (j=1;j<=6+n_abins2;j++) report1<<" 0";
    report1<<endl;
    for (j=1;j<=n_abins2;j++) report1<<" 0";
    report1<<endl;
  }
  }
    report1<<"#"<<endl << N_envvar<<" #_N_environ_variables"<<endl;
    report1<<"#Yr Variable Value"<<endl;
    if(finish_starter==999) 
      {j=1;}
      else
      {j=0;}
    if(N_envvar>0)
      {for(i=j;i<=N_envdata-1+j;i++) report1<<env_temp[i]<<endl;
       report1<<"-9999 0 0"<<endl;
      }

  report1<<"#"<<endl<<SzFreq_Nmeth<<" # N sizefreq methods to read "<<endl;
  if(SzFreq_Nmeth>0)
  {
    report1<<SzFreq_Nbins<<" #Sizefreq N bins per method"<<endl;
    report1<<SzFreq_units<<" #Sizetfreq units(bio/num) per method"<<endl;
    report1<<SzFreq_scale<<" #Sizefreq scale(kg/lbs/cm/inches) per method"<<endl;
    report1<<SzFreq_mincomp<<" #Sizefreq mincomp per method "<<endl;
    report1<<SzFreq_nobs<<" #Sizefreq N obs per method"<<endl;
    report1<<"#_Sizefreq bins "<<endl;
    for (i=1;i<=SzFreq_Nmeth;i++) {report1<<SzFreq_Omit_Small(i)*SzFreq_bins1(i,1)<<SzFreq_bins1(i)(2,SzFreq_Nbins(i))<<endl;}
    report1<<"#_method year month fleet gender partition SampleSize <data> "<<endl<<SzFreq_obs1<<endl;
  }

  // begin tagging data section #1 (observed data)
  report1<<"#"<<endl<<Do_TG<<" # do tags (0/1)"<<endl;
  if(Do_TG>0)
  {
    // info on dimensions of tagging data
    report1<<N_TG<<" # N tag groups"<<endl;
    report1<<N_TG_recap<<" # N recap events"<<endl;
    report1<<TG_mixperiod<<" # mixing latency period: N periods to delay before comparing observed to expected recoveries (0 = release period)"<<endl;
    report1<<TG_maxperiods<<" # max periods (seasons) to track recoveries, after which tags enter accumulator"<<endl;

    // tag releases
    report1<<"# Release data for each tag group.  Tags are considered to be released at the beginning of a season (period)"<<endl;
    report1<<"#<TG> area yr season <tfill> gender age Nrelease  (note that the TG and tfill values are placeholders and are replaced by program generated values)"<<endl;
    report1<<TG_release<<endl;

    // tag recaptures
    report1<<"#_TAG  Yr Season Fleet Nrecap"<<endl;
    for(j=1;j<=N_TG_recap;j++)
    {
      // fill in first 4 columns:
      for(k=1;k<=5;k++) report1<<TG_recap_data(j,k)<<" ";
      report1<<endl;
    }
  }
  // end tagging data section #1 (observed data)

    report1<<"#"<<endl<<Do_Morphcomp<<" #    morphcomp data(0/1) "<<endl;
    if(Do_Morphcomp>0)
    {
      report1<<mc_temp<<"  #  Nobs, Nmorphs, mincomp"<<endl;
      report1<<"# yr, seas, type, partition, Nsamp, datavector_by_Nmorphs"<<endl;
      report1<<Morphcomp_obs<<endl;
    }
    else
    {
      report1<<"#  Nobs, Nmorphs, mincomp"<<endl;
      report1<<"#  yr, seas, type, partition, Nsamp, datavector_by_Nmorphs"<<endl;
    }

   report1<<"#"<<endl<<Do_SelexData<<"  #  Do dataread for selectivity priors(0/1)"<<endl;
   report1<<"# Yr, Seas, Fleet,  Age/Size,  Bin,  selex_prior,  prior_sd"<<endl;
   report1<<"# feature not yet implemented"<<endl;

   report1<<"#"<<endl<<"999" << endl << endl;
  }

  else if(Nudat==2)  // report expected value with no added error
  {

  report1 << "#_catch:_columns_are_year,season,fleet,catch,catch_se"<<endl;
  report1<<"#_Catch data: yr, seas, fleet, catch, catch_se"<<endl;
  k=0;
  for(f=1;f<=Nfleet;f++)
  {
    if(fleet_type(f)<=2)
    {
      for(y=styr-1;y<=endyr;y++)
      {
        for(s=1;s<=nseas;s++)
        {
          k++;
          t=styr+(y-styr)*nseas+s-1;
          if(y==styr-1)
          {
            report1<<-999<<" "<<s<<" "<<f<<" "<<est_equ_catch(s,f)<<" "<<catch_se(t,f)<<endl;
          }
          else
          {
            report1<<y<<" "<<s<<" "<<f<<" ";
            if (fleet_type(f)==2 && catch_ret_obs(f,t)>0.0)
            {
              report1<<0.1<<" "<<catch_se(t,f)<<endl;  //  for bycatch only fleet
            }
            else if(catchunits(f)==1)
            {report1<<catch_fleet(t,f,3)<<" "<<catch_se(t,f)<<endl;}
            else
            {report1<<catch_fleet(t,f,6)<<" "<<catch_se(t,f)<<endl;}
           }
        }
      }
    }
  }
  report1<<"-9999 0 0 0 0"<<endl<<"#"<<endl;

  report1<<"#"<<endl<<" #_CPUE_and_surveyabundance_observations"<< endl;
    report1<<"#_Units:  0=numbers; 1=biomass; 2=F; >=30 for special types"<<endl;
    report1<<"#_Errtype:  -1=normal; 0=lognormal; >0=T"<<endl;
    report1<<"#_SD_Report: 0=no sdreport; 1=enable sdreport"<<endl;
    report1<<"#_Fleet Units Errtype SD_Report"<<endl;
    for (f=1;f<=Nfleet;f++) report1<<f<<" "<<Svy_units(f)<<" "<<Svy_errtype(f)<<" "<<Svy_sdreport(f)<<" # "<<fleetname(f)<<endl;
    report1 << "#_year month index obs err"<<endl;
    if(Svy_N>0)
    for (f=1;f<=Nfleet;f++)
    for (i=1;i<=Svy_N_fleet(f);i++)
    {
      t=Svy_time_t(f,i);
      ALK_time=Svy_ALK_time(f,i);
      report1 << Show_Time(t,1)<<" "<<Svy_super(f,i)*data_time(ALK_time,f,1)<<" "<<f*Svy_use(f,i)<<" ";
      if(Svy_use(f,i)>0)
      {
        if(Svy_errtype(f)>=0)  // lognormal
        {
          report1 << mfexp(Svy_est(f,i));
        }
        else if(Svy_errtype(f)==-1)  // normal
        {
          report1<<Svy_est(f,i);
        }
      }
      else
      {
        report1 << Svy_obs(f,i);
      }
      report1 <<" "<<Svy_se_rd(f,i)<<" #_orig_obs: "<<Svy_obs(f,i)<<" "<<fleetname(f)<<endl;
    }
    report1<<"-9999 1 1 1 1 # terminator for survey observations "<<endl;

  report1<<"#"<<endl<<Ndisc_fleets<<" #_N_fleets_with_discard"<<endl;
  report1<<"#_discard_units (1=same_as_catchunits(bio/num); 2=fraction; 3=numbers)"<< endl;
  report1<<"#_discard_errtype:  >0 for DF of T-dist(read CV below); 0 for normal with CV; -1 for normal with se; -2 for lognormal; -3 for trunc normal with CV"<<endl;
  report1<<"# note, only have units and errtype for fleets with discard "<<endl;
  report1<<"#_Fleet units errtype"<<endl;
  if(Ndisc_fleets>0)
  {
    for (f=1;f<=Nfleet;f++)
    if(disc_units(f)>0) report1<<f<<" "<<disc_units(f)<<" "<<disc_errtype(f)<<" # "<<fleetname(f)<<endl;
    report1<<"#_yr month fleet obs stderr"<<endl;
    for (f=1;f<=Nfleet;f++)
    if(disc_N_fleet(f)>0)
    for (i=1;i<=disc_N_fleet(f);i++)
    {
      ALK_time=disc_time_ALK(f,i);
      report1 << Show_Time(disc_time_t(f,i),1)<<" "<<yr_disc_super(f,i)*data_time(ALK_time,f,1)<<" "<<f*yr_disc_use(f,i)<<" ";
      if(yr_disc_use(f,i) >= 0.0 )
        {report1 << exp_disc(f,i);}
      else
      {report1 << obs_disc(f,i);}
      report1 << " "<< cv_disc(f,i)<<" #_orig_obs: "<<obs_disc(f,i)<<" #_ "<<fleetname(f)<<endl;
    }
  }
  else
  {
    report1<<"# ";
  }
  report1<<"-9999 0 0 0.0 0.0 # terminator for discard data "<<endl;

  report1 <<"#"<<endl<< do_meanbodywt <<" #_use meanbodysize_data (0/1)"<< endl;

  if(nobs_mnwt_rd==0) report1<<"#_COND_";
  report1<<DF_bodywt<<" #_DF_for_meanbodysize_T-distribution_like"<<endl;
  report1<<"# note:  use positive partition value for mean body wt, negative partition for mean body length "<<endl;
  report1<<"#_yr month fleet part obs stderr"<<endl;
  if(nobs_mnwt>0)
   {
   for (i=1;i<=nobs_mnwt;i++)
    {
     f=abs(mnwtdata(3,i));
     report1 << Show_Time(mnwtdata(1,i),1)<<" "<<mnwtdata(2,i)<<" "<<mnwtdata(3,i)<<" "<<mnwtdata(4,i)<<" "<<
     exp_mnwt(i)<<" "<<mnwtdata(6,i)-var_adjust(3,f)<<" #_orig_obs: "<<mnwtdata(5,i)<<"  #_ "<<fleetname(f)<<endl;
    }
   }
  if(do_meanbodywt==0) report1<<"# ";
  report1<<" -9999 0 0 0 0 0 # terminator for mean body size data "<<endl;

  report1<<"#"<<endl<<"# set up population length bin structure (note - irrelevant if not using size data and using empirical wtatage"<<endl;
  report1<<LenBin_option<<" # length bin method: 1=use databins; 2=generate from binwidth,min,max below; 3=read vector"<<endl;
  if(LenBin_option==1)
  {report1<<"# no additional input for option 1"<<endl;
    report1<<"# read binwidth, minsize, lastbin size for option 2"<<endl;
    report1<<"# read N poplen bins, then vector of bin lower boundaries, for option 3"<<endl;}
  else if(LenBin_option==2)
  {
    report1<<binwidth2<<" # binwidth for population size comp "<<endl;
    report1<<minLread<<" # minimum size in the population (lower edge of first bin and size at age 0.00) "<<endl;
    report1<<maxLread<<" # maximum size in the population (lower edge of last bin) "<<endl;
  }
  else
  {
    report1<<nlength<<" # number of population size bins "<<endl;
    report1<<len_bins<<endl;
  }

  report1<<use_length_data<<" # use length composition data (0/1)"<<endl;
  if(use_length_data>0)
  {
  report1<<"#_mintailcomp: upper and lower distribution for females and males separately are accumulated until exceeding this level."<<endl;
  report1<<"#_addtocomp:  after accumulation of tails; this value added to all bins"<<endl;
  report1<<"#_males and females treated as combined gender below this bin number "<<endl;
  report1<<"#_compressbins: accumulate upper tail by this number of bins; acts simultaneous with mintailcomp; set=0 for no forced accumulation"<<endl;
  report1<<"#_Comp_Error:  0=multinomial, 1=dirichlet"<<endl;
  report1<<"#_Comp_Error2:  parm number  for dirichlet"<<endl;
  report1<<"#_minsamplesize: minimum sample size; set to 1 to match 3.24, minimum value is 0.001"<<endl;
  report1<<"#_mintailcomp addtocomp combM+F CompressBins CompError ParmSelect minsamplesize"<<endl;
  for (f=1;f<=Nfleet;f++)
  {report1<<min_tail_L(f)<<" "<<min_comp_L(f)<<" "<<CombGender_L(f)<<" "<<AccumBin_L(f)<<" "<<Comp_Err_L(f)<<" "<<Comp_Err_L2(f)<<" "<<min_sample_size_L(f)<<" #_fleet:"<<f<<"_"<<fleetname(f)<<endl;}
  report1<<"# sex codes:  0=combined; 1=use female only; 2=use male only; 3=use both as joint sexxlength distribution"<<endl;
  report1<<"# partition codes:  (0=combined; 1=discard; 2=retained"<<endl;
  report1<<nlen_bin<<" #_N_LengthBins"<<endl<<len_bins_dat<<endl;
//  report1<<sum(Nobs_l)<<" #_N_Length_obs"<<endl;
  report1<<"#_yr month fleet sex part Nsamp datavector(female-male)"<<endl;
   for (f=1;f<=Nfleet;f++)
    {
    if(Nobs_l(f)>0)
    {
     for (i=1;i<=Nobs_l(f);i++)
     {
      if(header_l(f,i,3)>0) // do only if this was a real observation
      {
       k=1000;  if(nsamp_l(f,i)<k) k=nsamp_l(f,i);
       exp_l_temp_dat = nsamp_l(f,i)*value(exp_l(f,i)/sum(exp_l(f,i)));
      }
      else
      {exp_l_temp_dat = obs_l(f,i);}
     report1 << header_l_rd(f,i)(1,3)<<" "<<gen_l(f,i)<<" "<<mkt_l(f,i)<<" "<<nsamp_l(f,i)<<" "<<exp_l_temp_dat<<endl;
    }}}
    report1<<-9999.<<" ";
    for(j=2;j<=6+nlen_bin2;j++) report1<<"0 ";
    report1<<endl;
  }
  else
  {
    report1<<"# see manual for format of length composition data "<<endl;
  }

   report1<<"#"<<endl<<n_abins<<" #_N_age_bins"<<endl;
  if(n_abins>0)
  {
    report1<<age_bins1<<endl;
  }
  else
  {
    report1<<"# ";
  }
  report1 << N_ageerr <<" #_N_ageerror_definitions"<< endl;
  if(N_ageerr>0) report1 << age_err_rd << endl;

  report1<<"#_mintailcomp: upper and lower distribution for females and males separately are accumulated until exceeding this level."<<endl;
  report1<<"#_addtocomp:  after accumulation of tails; this value added to all bins"<<endl;
  report1<<"#_males and females treated as combined gender below this bin number "<<endl;
  report1<<"#_compressbins: accumulate upper tail by this number of bins; acts simultaneous with mintailcomp; set=0 for no forced accumulation"<<endl;
  report1<<"#_Comp_Error:  0=multinomial, 1=dirichlet"<<endl;
  report1<<"#_Comp_Error2:  parm number  for dirichlet"<<endl;
  report1<<"#_minsamplesize: minimum sample size; set to 1 to match 3.24, minimum value is 0.001"<<endl;
  report1<<"#_mintailcomp addtocomp combM+F CompressBins CompError ParmSelect minsamplesize"<<endl;
  for (f=1;f<=Nfleet;f++)
  {
    if (n_abins <= 0) report1<<"# ";
    report1<<min_tail_A(f)<<" "<<min_comp_A(f)<<" "<<CombGender_A(f)<<" "<<AccumBin_A(f)<<" "<<Comp_Err_A(f)<<" "<<Comp_Err_A2(f)<<" "<<min_sample_size_A(f)<<" #_fleet:"<<f<<"_"<<fleetname(f)<<endl;
  }
  
  if (n_abins <= 0) report1<<"# ";
  report1<<Lbin_method<<" #_Lbin_method_for_Age_Data: 1=poplenbins; 2=datalenbins; 3=lengths"<<endl;
  report1<<"# sex codes:  0=combined; 1=use female only; 2=use male only; 3=use both as joint sexxlength distribution"<<endl;
  report1<<"# partition codes:  (0=combined; 1=discard; 2=retained"<<endl;
  report1<<"#_yr month fleet sex part ageerr Lbin_lo Lbin_hi Nsamp datavector(female-male)"<<endl;
   if(Nobs_a_tot>0)
   for (f=1;f<=Nfleet;f++)
   {
    if(Nobs_a(f)>=1)
    {
     for (i=1;i<=Nobs_a(f);i++)
     {
     if(header_a(f,i,3)>0) // if real observation
     {
      k=1000;  if(nsamp_a(f,i)<k) k=nsamp_a(f,i);  // note that nsamp is adjusted by var_adjust, so var_adjust
                                                   // should be reset to 1.0 in control files that read the nudata.dat files
      exp_a_temp = nsamp_a(f,i)*value(exp_a(f,i)/sum(exp_a(f,i)));
     }
     else
     {exp_a_temp = obs_a(f,i);}
    report1 << header_a(f,i)(1)<<" "<<header_a_rd(f,i)(2,3)<<" "<<header_a(f,i)(4,8)<<" "<<nsamp_a(f,i)<<" "<<exp_a_temp<<endl;
    }
    }
   }
  f=exp_a_temp.size()+8;
  if (n_abins <= 0) report1<<"# ";
  report1 << "-9999 ";
  for(i=1;i<=f;i++) report1<<" 0";
  report1<<endl;

  report1<<"#"<<endl<<use_meansizedata<<" #_Use_MeanSize-at-Age_obs (0/1)"<<endl;
  if(use_meansizedata>0)
  {
  report1<<"# sex codes:  0=combined; 1=use female only; 2=use male only; 3=use both as joint sexxlength distribution"<<endl;
  report1<<"# partition codes:  (0=combined; 1=discard; 2=retained"<<endl;
  report1<<"# ageerr codes:  positive means mean length-at-age; negative means mean bodywt_at_age"<<endl;
  report1<<"#_yr month fleet sex part ageerr ignore datavector(female-male)"<<endl;
  report1<<"#                                          samplesize(female-male)"<<endl;
   for (f=1;f<=Nfleet;f++)
   {
    if(Nobs_ms(f)>0)
    {
     for (i=1;i<=Nobs_ms(f);i++)
     {
       report1 << header_ms(f,i)(1)<<" "<<header_ms_rd(f,i)(2,3)<<" "<<header_ms(f,i)(4,7);
       for (a=1;a<=n_abins2;a++)
       {
         report1 << " " ;
         if(obs_ms_n(f,i,a)>0)
          {
            temp=exp_ms(f,i,a);
            if(temp<=0.) {temp=0.0001;}
            report1 << temp;
          }
         else
             {report1 << obs_ms(f,i,a) ;}
       }
       report1 << endl<< elem_prod(obs_ms_n(f,i),obs_ms_n(f,i)) << endl;
     }
    }
   }
    report1<<"-9999 ";
    for (j=1;j<=6+n_abins2;j++) report1<<" 0";
    report1<<endl;
    for (j=1;j<=n_abins2;j++) report1<<" 0";
    report1<<endl;
  }

    report1<<"#"<<endl << N_envvar<<" #_N_environ_variables"<<endl;
    report1<<"#Yr Variable Value"<<endl;
    if(finish_starter==999) 
      {j=1;}
      else
      {j=0;}
    if(N_envvar>0)
      {for(i=j;i<=N_envdata-1+j;i++) report1<<env_temp[i]<<endl;
       report1<<"-9999 0 0"<<endl;
      }

  report1<<"#"<<endl<<SzFreq_Nmeth<<" # N sizefreq methods to read "<<endl;
  if(SzFreq_Nmeth>0)
  {
    report1<<SzFreq_Nbins<<" #Sizefreq N bins per method"<<endl;
    report1<<SzFreq_units<<" #Sizetfreq units(bio/num) per method"<<endl;
    report1<<SzFreq_scale<<" #Sizefreq scale(kg/lbs/cm/inches) per method"<<endl;
    report1<<SzFreq_mincomp<<" #Sizefreq mincomp per method "<<endl;
    report1<<SzFreq_nobs<<" #Sizefreq N obs per method"<<endl;
    report1<<"#_Sizefreq bins "<<endl;
    for (i=1;i<=SzFreq_Nmeth;i++) {report1<<SzFreq_Omit_Small(i)*SzFreq_bins1(i,1)<<SzFreq_bins1(i)(2,SzFreq_Nbins(i))<<endl;}
    report1<<"#_method yr month fleet sex partition SampleSize <data> "<<endl;
    for (iobs=1;iobs<=SzFreq_totobs;iobs++)
    {
      if(SzFreq_obs_hdr(iobs,3)>0)  // flag for date range in bounds
      {
        report1<<SzFreq_obs1(iobs)(1,7)<<" "<<SzFreq_exp(iobs)<<endl;
      }
      else
      {
        report1<<SzFreq_obs1(iobs)<<endl;
      }
    }
  }

  // begin tagging data section #2 (expected values)
  report1<<"#"<<endl<<Do_TG<<" # do tags (0/1)"<<endl;
  if(Do_TG>0)
  {
    // info on dimensions of tagging data
    report1<<N_TG<<" # N tag groups"<<endl;
    report1<<N_TG_recap<<" # N recap events"<<endl;
    report1<<TG_mixperiod<<" # mixing latency period: N periods to delay before comparing observed to expected recoveries (0 = release period)"<<endl;
    report1<<TG_maxperiods<<" # max periods (seasons) to track recoveries, after which tags enter accumulator"<<endl;

    // tag releases
    report1<<"# Release data for each tag group.  Tags are considered to be released at the beginning of a season (period)"<<endl;
    report1<<"#<TG> area yr season <tfill> sex age Nrelease  (note that the TG and tfill values are placeholders and are replaced by program generated values)"<<endl;
    report1<<TG_release<<endl;

    // tag recaptures
    report1<<"#_Note: Expected values for tag recaptures are reported only for the same combinations of"<<endl;
    report1<<"#       group, year, area, and fleet that had observed recaptures. "<<endl;
    report1<<"#_TAG  Yr Season Fleet Nrecap"<<endl;
    for(j=1;j<=N_TG_recap;j++)
    {
      // fill in first 4 columns:
      for(k=1;k<=4;k++) report1<<TG_recap_data(j,k)<<" ";
      // fill in 5th column with bootstrap values
      TG=TG_recap_data(j,1);
      overdisp=TG_parm(2*N_TG+TG);
      t=styr+int((TG_recap_data(j,2)-styr)*nseas+TG_recap_data(j,3)-1) - TG_release(TG,5); // find elapsed time in terms of number of seasons
      if(t>TG_maxperiods) t=TG_maxperiods;
      report1<<value(TG_recap_exp(TG,t,0))<<" #_overdisp: "<<value(overdisp)<<endl;
    }
  }
  // end tagging data section #2 (expected values)

    report1<<"#"<<endl<<Do_Morphcomp<<" #    morphcomp data(0/1) "<<endl;
    if(Do_Morphcomp>0)
    {
      report1<<"# note that raw data, not bootstrap are reported here "<<endl;
      report1<<mc_temp<<"  #  Nobs, Nmorphs, mincomp"<<endl;
      report1<<"# yr, seas, type, partition, Nsamp, datavector_by_Nmorphs"<<endl;
      report1<<Morphcomp_obs<<endl;
    }
    else
    {
      report1<<"#  Nobs, Nmorphs, mincomp"<<endl;
      report1<<"#  yr, seas, type, partition, Nsamp, datavector_by_Nmorphs"<<endl;
    }

   report1<<"#"<<endl<<Do_SelexData<<"  #  Do dataread for selectivity priors(0/1)"<<endl;
   report1<<"# Yr, Seas, Fleet,  Age/Size,  Bin,  selex_prior,  prior_sd"<<endl;
   report1<<"# feature not yet implemented"<<endl;

    report1<<"#"<< endl << "999" << endl << endl;

  }

  else  //  create bootstrap data
  {

  report1 << "#_catch_biomass(mtons):_columns_are_fisheries,year,season"<<endl;
  report1 << "#_catch:_columns_are_year,season,fleet,catch,catch_se"<<endl;
  report1<<"#_Catch data: yr, seas, fleet, catch, catch_se"<<endl;
  k=0;
  for(f=1;f<=Nfleet;f++)
  {
    if(fleet_type(f)<=2)
    {
      for(y=styr-1;y<=endyr;y++)
      {
        for(s=1;s<=nseas;s++)
        {
          k++;
          t=styr+(y-styr)*nseas+s-1;
          if(y==styr-1)
          {
            report1<<-999<<" "<<s<<" "<<f<<" "
            <<est_equ_catch(s,f)*mfexp(randn(radm)*catch_se(styr-1,f) - 0.5*catch_se(styr-1,f)*catch_se(styr-1,f))
            <<" "<<catch_se(t,f)<<endl;
          }
          else
          {
            report1<<y<<" "<<s<<" "<<f<<" ";
            if (fleet_type(f)==2 && catch_ret_obs(f,t)>0.0)
            {
              report1<<0.1<<" "<<catch_se(t,f)<<endl;  //  for bycatch only fleet
            }
            else if(catchunits(f)==1)
            {report1<<catch_fleet(t,f,3)*mfexp(randn(radm)*catch_se(t,f) - 0.5*catch_se(t,f)*catch_se(t,f))
              <<" "<<catch_se(t,f)<<endl;}
            else
            {report1<<catch_fleet(t,f,6)*mfexp(randn(radm)*catch_se(t,f) - 0.5*catch_se(t,f)*catch_se(t,f))
              <<" "<<catch_se(t,f)<<endl;}
          }
        }
      }
    }
  }
  report1<<"-9999 0 0 0 0"<<endl<<"#"<<endl;

  report1 <<" #_CPUE_and_surveyabundance_observations"<< endl;
  report1<<"#_Units:  0=numbers; 1=biomass; 2=F;  >=30 for special types"<<endl;
  report1<<"#_Errtype:  -1=normal; 0=lognormal; >0=T"<<endl;
  report1<<"#_SD_Report: 0=no sdreport; 1=enable sdreport"<<endl;
  report1<<"#_Fleet Units Errtype SD_Report"<<endl;
  for (f=1;f<=Nfleet;f++) report1<<f<<" "<<Svy_units(f)<<" "<<Svy_errtype(f)<<" "<<Svy_sdreport(f)<<" # "<<fleetname(f)<<endl;
  report1 << "#_year month index obs err"<<endl;
  if(Svy_N>0)
  for (f=1;f<=Nfleet;f++)
  for (i=1;i<=Svy_N_fleet(f);i++)
  {
    t=Svy_time_t(f,i);
    ALK_time=Svy_ALK_time(f,i);
    report1 << Show_Time(t,1)<<" "<<Svy_super(f,i)*data_time(ALK_time,f,1)<<" "<<f*Svy_use(f,i)<<" ";
    if(Svy_use(f,i) > 0)
    {
      if(Svy_errtype(f)==-1)  // normal error
      {
        report1<<Svy_est(f,i)+randn(radm)*Svy_se_use(f,i);    //  uses Svy_se_use, not Svy_se_rd to include both effect of input var_adjust and extra_sd
      }
      if(Svy_errtype(f)==0)  // lognormal
      {
         report1 << mfexp(Svy_est(f,i)+ randn(radm)*Svy_se_use(f,i) );    //  uses Svy_se_use, not Svy_se_rd to include both effect of input var_adjust and extra_sd
      }
      else if(Svy_errtype(f)>0)   // lognormal T_dist
      {
        temp = sqrt( (Svy_errtype(f)+1.)/Svy_errtype(f));  // where df=Svy_errtype(f)
        report1 << mfexp(Svy_est(f,i)+ randn(radm)*Svy_se_use(f,i)*temp );    //  adjusts the sd by the df sample size
      }
    }
    else
    {
      report1 << Svy_obs(f,i);
    }
    report1 <<" "<<Svy_se_rd(f,i)<<" #_orig_obs: "<<Svy_obs(f,i)<<" "<<fleetname(f)<<endl;
  }
  report1<<"-9999 1 1 1 1 # terminator for survey observations "<<endl;

  report1<<"#"<<endl<<Ndisc_fleets<<" #_N_fleets_with_discard"<<endl;
  report1<<"#_discard_units (1=same_as_catchunits(bio/num); 2=fraction; 3=numbers)"<< endl;
  report1<<"#_discard_errtype:  >0 for DF of T-dist(read CV below); 0 for normal with CV; -1 for normal with se; -2 for lognormal; -3 for trunc normal with CV"<<endl;
  report1<<"# note, only have units and errtype for fleets with discard "<<endl;
  report1<<"#_Fleet units errtype"<<endl;
  if(Ndisc_fleets>0)
  {
    for (f=1;f<=Nfleet;f++)
    if(disc_units(f)>0) report1<<f<<" "<<disc_units(f)<<" "<<disc_errtype(f)<<" # "<<fleetname(f)<<endl;
    report1<<"#_yr month fleet obs stderr"<<endl;
    for (f=1;f<=Nfleet;f++)
    for (i=1;i<=disc_N_fleet(f);i++)
    {
      ALK_time=disc_time_ALK(f,i);
      report1 << Show_Time(disc_time_t(f,i),1)<<" "<<yr_disc_super(f,i)*data_time(ALK_time,f,1)<<" "<<f*yr_disc_use(f,i)<<" ";
      if(yr_disc_use(f,i) >= 0.0 )
      {
        if(disc_errtype(f)>=1)
        {temp=exp_disc(f,i) + randn(radm)*sd_disc(f,i)*sqrt((disc_errtype(f)+1.)/disc_errtype(f)) * exp_disc(f,i); if(temp<0.001) temp=0.001;}
        else if(disc_errtype(f)==0)
        {temp=exp_disc(f,i) + randn(radm)*sd_disc(f,i); if(temp<0.001) temp=0.001; }
        else if(disc_errtype(f)==-1)
        {temp=exp_disc(f,i) + randn(radm)*sd_disc(f,i); if(temp<0.001) temp=0.001; }
        else if(disc_errtype(f)==-2)
        {temp=exp_disc(f,i) * mfexp(randn(radm)*sd_disc(f,i));}
        else if(disc_errtype(f)==-3)
        {temp=exp_disc(f,i) + randn(radm)*(sd_disc(f,i) / sqrt(cumd_norm( (1 - exp_disc(f,i)) / sd_disc(f,i) ) - cumd_norm( (0 - exp_disc(f,i)) / sd_disc(f,i) ))); if(temp<0.001) temp=0.001; }
      }
      else
      {temp=obs_disc(f,i);}
      report1 <<" "<<temp<< " "<< cv_disc(f,i)<<" #_orig_obs: "<<obs_disc(f,i)<<" #_ "<<fleetname(f)<<endl;
    }
  }
  else
  {
    report1<<"# ";
  }
  report1<<"-9999 0 0 0.0 0.0 # terminator for discard data "<<endl;

  report1 <<"#"<<endl<< do_meanbodywt <<" #_use meanbodysize_data (0/1)"<< endl;
  if(do_meanbodywt==0) report1<<"#_COND_";
  report1<<DF_bodywt<<" #_DF_for_meanbodysize_T-distribution_like"<<endl;
  report1<<"# note:  use positive partition value for mean body wt, negative partition for mean body length "<<endl;
  report1<<"#_yr month fleet part obs stderr"<<endl;
  if(nobs_mnwt>0)
  {
    for (i=1;i<=nobs_mnwt;i++)
    {
      if(mnwtdata(3,i)>0 && mnwtdata(5,i)>0.)
      {
        temp=exp_mnwt(i)+randn(radm)*mnwtdata(6,i)*sqrt((DF_bodywt+1.)/DF_bodywt) *exp_mnwt(i);
        if(temp<=0.0) {temp=0.0001;}
      }
      else
      {
        temp=mnwtdata(5,i);
      }
      f=abs(mnwtdata(3,i));
      report1 << Show_Time(mnwtdata(1,i),1)<<" "<<mnwtdata(2,i)<<" "<<mnwtdata(3,i)<<" "<<mnwtdata(4,i)<<" "<<
      temp<<" "<<mnwtdata(6,i)-var_adjust(3,f)<<" #_orig_obs: "<<mnwtdata(5,i)<<"  #_ "<<fleetname(f)<<endl;    }
  }
  if(do_meanbodywt==0) report1<<"# ";
  report1<<" -9999 0 0 0 0 0 # terminator for mean body size data "<<endl;

  report1<<"#"<<endl<<"# set up population length bin structure (note - irrelevant if not using size data and using empirical wtatage"<<endl;
  report1<<LenBin_option<<" # length bin method: 1=use databins; 2=generate from binwidth,min,max below; 3=read vector"<<endl;
  if(LenBin_option==1)
  {report1<<"# no additional input for option 1"<<endl;
    report1<<"# read binwidth, minsize, lastbin size for option 2"<<endl;
    report1<<"# read N poplen bins, then vector of bin lower boundaries, for option 3"<<endl;}
  else if(LenBin_option==2)
  {
    report1<<binwidth2<<" # binwidth for population size comp "<<endl;
    report1<<minLread<<" # minimum size in the population (lower edge of first bin and size at age 0.00) "<<endl;
    report1<<maxLread<<" # maximum size in the population (lower edge of last bin) "<<endl;
  }
  else
  {
    report1<<nlength<<" # number of population size bins "<<endl;
    report1<<len_bins<<endl;
  }

  report1<<use_length_data<<" # use length composition data (0/1)"<<endl;
  if(use_length_data>0)
  {
  report1<<"#_mintailcomp: upper and lower distribution for females and males separately are accumulated until exceeding this level."<<endl;
  report1<<"#_addtocomp:  after accumulation of tails; this value added to all bins"<<endl;
  report1<<"#_males and females treated as combined sex below this bin number "<<endl;
  report1<<"#_compressbins: accumulate upper tail by this number of bins; acts simultaneous with mintailcomp; set=0 for no forced accumulation"<<endl;
  report1<<"#_Comp_Error:  0=multinomial, 1=dirichlet"<<endl;
  report1<<"#_Comp_Error2:  parm number  for dirichlet"<<endl;
  report1<<"#_minsamplesize: minimum sample size; set to 1 to match 3.24, minimum value is 0.001"<<endl;
  report1<<"#_mintailcomp addtocomp combM+F CompressBins CompError ParmSelect minsamplesize"<<endl;
  for (f=1;f<=Nfleet;f++)
  {report1<<min_tail_L(f)<<" "<<min_comp_L(f)<<" "<<CombGender_L(f)<<" "<<AccumBin_L(f)<<" "<<Comp_Err_L(f)<<" "<<Comp_Err_L2(f)<<" "<<min_sample_size_L(f)<<" #_fleet:"<<f<<"_"<<fleetname(f)<<endl;}
  report1<<nlen_bin<<" #_N_LengthBins"<<endl<<len_bins_dat<<endl;
//  report1<<sum(Nobs_l)<<" #_N_Length_obs"<<endl;
  report1<<"# sex codes:  0=combined; 1=use female only; 2=use male only; 3=use both as joint sexxlength distribution"<<endl;
  report1<<"# partition codes:  (0=combined; 1=discard; 2=retained"<<endl;
  report1<<"#_yr month fleet sex part Nsamp datavector(female-male)"<<endl;
   for (f=1;f<=Nfleet;f++)
    {
    if(Nobs_l(f)>0)
    {
     for (i=1;i<=Nobs_l(f);i++)
     {
      if(header_l(f,i,3)>0) // do only if this was a real observation
      {
        if(Comp_Err_L(f)==0)  //  multinomial
        {
           k=50000;  if(nsamp_l(f,i)<k) k=nsamp_l(f,i);
           exp_l_temp_dat.initialize();
           temp_probs = value(exp_l(f,i));
           temp_mult.fill_multinomial(radm,temp_probs);  // create multinomial draws with prob = expected values
           for (compindex=1; compindex<=k; compindex++) // cumulate the multinomial draws by index in the new data
           {exp_l_temp_dat(temp_mult(compindex)) += 1.0;}
        }
        else  //  Dirichlet
        {
//  need to replace this with Dirichlet equivalent
           k=50000;  if(nsamp_l(f,i)<k) k=nsamp_l(f,i);
           exp_l_temp_dat.initialize();
           temp_probs = value(exp_l(f,i));
           temp_mult.fill_multinomial(radm,temp_probs);  // create multinomial draws with prob = expected values
           for (compindex=1; compindex<=k; compindex++) // cumulate the multinomial draws by index in the new data
           {exp_l_temp_dat(temp_mult(compindex)) += 1.0;}
        }
      }
      else
      {exp_l_temp_dat = obs_l(f,i);}
     report1 << header_l_rd(f,i)(1,3)<<" "<<gen_l(f,i)<<" "<<mkt_l(f,i)<<" "<<nsamp_l(f,i)<<" "<<exp_l_temp_dat<<endl;
    }}}
    report1<<-9999.<<" ";
    for(j=2;j<=6+nlen_bin2;j++) report1<<"0 ";
    report1<<endl;
  }
  else
  {
    report1<<"# see manual for format of length composition data "<<endl;
  }

   report1<<"#"<<endl<<n_abins<<" #_N_age_bins"<<endl;
  if(n_abins>0)
  {
    report1<<age_bins1<<endl;
  }
  else
  {
    report1<<"# ";
  }
  report1 << N_ageerr <<" #_N_ageerror_definitions"<< endl;
  if(N_ageerr>0) report1 << age_err_rd << endl;

  report1<<"#_mintailcomp: upper and lower distribution for females and males separately are accumulated until exceeding this level."<<endl;
  report1<<"#_addtocomp:  after accumulation of tails; this value added to all bins"<<endl;
  report1<<"#_males and females treated as combined sex below this bin number "<<endl;
  report1<<"#_compressbins: accumulate upper tail by this number of bins; acts simultaneous with mintailcomp; set=0 for no forced accumulation"<<endl;
  report1<<"#_Comp_Error:  0=multinomial, 1=dirichlet"<<endl;
  report1<<"#_Comp_Error2:  parm number  for dirichlet"<<endl;
  report1<<"#_minsamplesize: minimum sample size; set to 1 to match 3.24, minimum value is 0.001"<<endl;
  report1<<"#_mintailcomp addtocomp combM+F CompressBins CompError ParmSelect minsamplesize"<<endl;
  for (f=1;f<=Nfleet;f++)
  {
    if (n_abins <= 0) report1<<"# ";
    report1<<min_tail_A(f)<<" "<<min_comp_A(f)<<" "<<CombGender_A(f)<<" "<<AccumBin_A(f)<<" "<<Comp_Err_A(f)<<" "<<Comp_Err_A2(f)<<" "<<min_sample_size_A(f)<<" #_fleet:"<<f<<"_"<<fleetname(f)<<endl;
  }
  
  if (n_abins <= 0) report1<<"# ";
  report1<<Lbin_method<<" #_Lbin_method_for_Age_Data: 1=poplenbins; 2=datalenbins; 3=lengths"<<endl;
  report1<<"# sex codes:  0=combined; 1=use female only; 2=use male only; 3=use both as joint sexxlength distribution"<<endl;
  report1<<"# partition codes:  (0=combined; 1=discard; 2=retained"<<endl;

  report1<<"#_yr month fleet sex part ageerr Lbin_lo Lbin_hi Nsamp datavector(female-male)"<<endl;
  if(Nobs_a_tot>0)
  for (f=1;f<=Nfleet;f++)
  {
    if(Nobs_a(f)>=1)
    {
       for (i=1;i<=Nobs_a(f);i++)
       {
       if(header_a(f,i,3)>0) // if real observation
       {
        if(Comp_Err_A(f)==0) //  multinomial
        {
          k=50000;  if(nsamp_a(f,i)<k) k=nsamp_a(f,i);  // note that nsamp is adjusted by var_adjust, so var_adjust
                                                       // should be reset to 1.0 in control files that read the nudata.dat files
          exp_a_temp = 0.0;
          temp_probs2 = value(exp_a(f,i));
          temp_mult.fill_multinomial(radm,temp_probs2);
          for (compindex=1; compindex<=k; compindex++) // cumulate the multinomial draws by index in the new data
          {exp_a_temp(temp_mult(compindex)) += 1.0;}
        }
        else  //  Dirichlet
        {
          //  need to replace this with code for dirichlet
          k=50000;  if(nsamp_a(f,i)<k) k=nsamp_a(f,i);  // note that nsamp is adjusted by var_adjust, so var_adjust
                                                       // should be reset to 1.0 in control files that read the nudata.dat files
          exp_a_temp = 0.0;
          temp_probs2 = value(exp_a(f,i));
          temp_mult.fill_multinomial(radm,temp_probs2);
          for (compindex=1; compindex<=k; compindex++) // cumulate the multinomial draws by index in the new data
          {exp_a_temp(temp_mult(compindex)) += 1.0;}
        }

       }
       else
       {exp_a_temp = obs_a(f,i);}
       report1 << header_a(f,i)(1)<<" "<<header_a_rd(f,i)(2,3)<<" "<<header_a(f,i)(4,8)<<" "<<nsamp_a(f,i)<<" "<<exp_a_temp<<endl;
      }
    }
  }
  f=exp_a_temp.size()+8;
  if (n_abins <= 0) report1<<"# ";
  report1 << "-9999 ";
  for(i=1;i<=f;i++) report1<<" 0";
  report1<<endl;


  report1<<"#"<<endl<<use_meansizedata<<" #_Use_MeanSize-at-Age_obs (0/1)"<<endl;
  if(use_meansizedata>0)
  {
    report1<<"# sex codes:  0=combined; 1=use female only; 2=use male only; 3=use both as joint sexxlength distribution"<<endl;
    report1<<"# partition codes:  (0=combined; 1=discard; 2=retained"<<endl;
    report1<<"# ageerr codes:  positive means mean length-at-age; negative means mean bodywt_at_age"<<endl;
    report1<<"#_yr month fleet sex part ageerr ignore datavector(female-male)"<<endl;
    report1<<"#                                          samplesize(female-male)"<<endl;
    for (f=1;f<=Nfleet;f++)
    {
     if(Nobs_ms(f)>0)
     {
       for (i=1;i<=Nobs_ms(f);i++)
       {
       report1 << header_ms(f,i)(1)<<" "<<header_ms_rd(f,i)(2,3)<<" "<<header_ms(f,i)(4,7);
         for (a=1;a<=n_abins2;a++)
         {
          report1<< " " ;
          if(obs_ms_n(f,i,a)>0)
          {
            temp=exp_ms(f,i,a)+randn(radm)*exp_ms_sq(f,i,a)/obs_ms_n(f,i,a);
            if(temp<=0.) {temp=0.0001;}
            report1 << temp;
          }
          else
          {report1 << exp_ms(f,i,a) ;}
         }
         report1 << endl<< elem_prod(obs_ms_n(f,i),obs_ms_n(f,i)) << endl;
       }
     }
    }
    report1<<"-9999 ";
    for (j=1;j<=6+n_abins2;j++) report1<<" 0";
    report1<<endl;
    for (j=1;j<=n_abins2;j++) report1<<" 0";
    report1<<endl;
  }

    report1<<"#"<<endl << N_envvar<<" #_N_environ_variables"<<endl;
    report1<<"#Yr Variable Value"<<endl;
    if(finish_starter==999) 
      {j=1;}
      else
      {j=0;}
    if(N_envvar>0)
      {for(i=j;i<=N_envdata-1+j;i++) report1<<env_temp[i]<<endl;
       report1<<"-9999 0 0"<<endl;
      }

  report1<<"#"<<endl<<SzFreq_Nmeth<<" # N sizefreq methods to read "<<endl;
  if(SzFreq_Nmeth>0)
  {
    report1<<SzFreq_Nbins<<" #Sizefreq N bins per method"<<endl;
    report1<<SzFreq_units<<" #Sizetfreq units(bio/num) per method"<<endl;
    report1<<SzFreq_scale<<" #Sizefreq scale(kg/lbs/cm/inches) per method"<<endl;
    report1<<SzFreq_mincomp<<" #Sizefreq mincomp per method "<<endl;
    report1<<SzFreq_nobs<<" #Sizefreq N obs per method"<<endl;
    report1<<"#_Sizefreq bins "<<endl;
    for (i=1;i<=SzFreq_Nmeth;i++) {report1<<SzFreq_Omit_Small(i)*SzFreq_bins1(i,1)<<SzFreq_bins1(i)(2,SzFreq_Nbins(i))<<endl;}
    report1<<"#_method year month fleet sex partition SampleSize <data> "<<endl;
    j=2*max(SzFreq_Nbins);
    dvector temp_probs3(1,j);
    dvector SzFreq_newdat(1,j);
    for (iobs=1;iobs<=SzFreq_totobs;iobs++)
    {
      if(SzFreq_obs_hdr(iobs,3)>0)  // flag for date range in bounds and used
      {
       j=50000;  if(SzFreq_obs1(iobs,7)<j) j=SzFreq_obs1(iobs,7);
       SzFreq_newdat.initialize();
       temp_probs3(1,SzFreq_Setup2(iobs)) = value(SzFreq_exp(iobs));
       temp_mult.fill_multinomial(radm,temp_probs3(1,SzFreq_Setup2(iobs)));  // create multinomial draws with prob = expected values
       for (compindex=1; compindex<=j; compindex++) // cumulate the multinomial draws by index in the new data
       {SzFreq_newdat(temp_mult(compindex)) += 1.0;}

        report1<<SzFreq_obs1(iobs)(1,7)<<" "<<SzFreq_newdat(1,SzFreq_Setup2(iobs))<<endl;
      }
      else
      {
        report1<<SzFreq_obs1(iobs)<<endl;
      }
    }
  }
  // begin tagging data section #3 (bootstrap data)
 report1<<"#"<<endl<<Do_TG<<" # do tags (0/1)"<<endl;
  if(Do_TG>0)
  {
    dvector temp_negbin(1,50000);

    // changes authored by Gavin Fay in June 2016 in SS 3.24Y
    TG_recap_gen.initialize();
    int N_TG_recap_gen=0;
    for(TG=1;TG<=N_TG;TG++)
    {
      overdisp=TG_parm(2*N_TG+TG);

      dvector TG_fleet_probs(1,Nfleet);
      dvector temp_tags(1,Nfleet);
//  problem:  TG_recap_exp only dimensioned to TG_endtime
      for (t=0;t<=min(TG_maxperiods,TG_endtime(TG));t++) {
        if (value(TG_recap_exp(TG,t,0))>0) {
          temp_negbin.initialize();
          temp_negbin.fill_randnegbinomial(value(TG_recap_exp(TG,t,0)), value(overdisp), radm);
          //cout << TG << " " << t << " " << temp_negbin <<  " " << TG_recap_exp(TG,t,0) << " " << value(overdisp) << endl;
          if (temp_negbin(1)>0) {
            TG_fleet_probs = value(TG_recap_exp(TG,t)(1,Nfleet))/temp_negbin(1);
            temp_tags = 0.0;
            temp_mult.fill_multinomial(radm,TG_fleet_probs);
            for (compindex=1; compindex<=temp_negbin(1); compindex++) // cumulate the multinomial draws by index in the new data
              {temp_tags(temp_mult(compindex)) += 1.0;}
            for (f=1;f<=Nfleet;f++) {
              if (temp_tags(f)>0) {
                N_TG_recap_gen += 1;
                TG_recap_gen(N_TG_recap_gen,1) = TG;
                TG_recap_gen(N_TG_recap_gen,2) = TG_release(TG,3) + int((t+TG_release(TG,4)-1)/nseas);
                int k = TG_release(TG,4);
                TG_recap_gen(N_TG_recap_gen,3) = ((t+k-1) % nseas) + 1;
                TG_recap_gen(N_TG_recap_gen,4) = f;
                TG_recap_gen(N_TG_recap_gen,5) = temp_tags(f);
              }

            }
          }
        }
      }
    }

    // info on dimensions of tagging data
    report1<<N_TG<<" # N tag groups"<<endl;
    // //report1<<N_TG_recap<<" # N recap events"<<endl;
    report1<<N_TG_recap_gen<<" # N recap events"<<endl;
    report1<<TG_mixperiod<<" # mixing latency period: N periods to delay before comparing observed to expected recoveries (0 = release period)"<<endl;
    report1<<TG_maxperiods<<" # max periods (seasons) to track recoveries, after which tags enter accumulator"<<endl;

    // tag releases
    report1<<"# Release data for each tag group.  Tags are considered to be released at the beginning of a season (period)"<<endl;
    report1<<"#<TG> area yr season <tfill> sex age Nrelease  (note that the TG and tfill values are placeholders and are replaced by program generated values)"<<endl;
    report1<<TG_release<<endl;

    // tag recaptures
    report1<<"#_Note: Bootstrap values for tag recaptures are produced only for the same combinations of"<<endl;
    report1<<"#       group, year, area, and fleet that had observed recaptures. "<<endl;
    report1<<"#_TAG  Yr Season Fleet Nrecap"<<endl;
    for(j=1;j<=N_TG_recap_gen;j++)
    {
      report1<<TG_recap_gen(j)<<endl;
    }
  }
  // end tagging data section #3 (bootstrap data)

    report1<<"#"<<endl<<Do_Morphcomp<<" #    morphcomp data(0/1) "<<endl;
    if(Do_Morphcomp>0)
    {
      report1<<"# note that raw data, not bootstrap are reported here "<<endl;
      report1<<mc_temp<<"  #  Nobs, Nmorphs, mincomp"<<endl;
      report1<<"#  yr, seas, type, partition, Nsamp, datavector_by_Nmorphs"<<endl;
      report1<<Morphcomp_obs<<endl;
    }
    else
    {
      report1<<"#  Nobs, Nmorphs, mincomp"<<endl;
      report1<<"#  yr, seas, type, partition, Nsamp, datavector_by_Nmorphs"<<endl;
    }

   report1<<"#"<<endl<<Do_SelexData<<"  #  Do dataread for selectivity priors(0/1)"<<endl;
   report1<<" # Yr, Seas, Fleet,  Age/Size,  Bin,  selex_prior,  prior_sd"<<endl;
   report1<<" # feature not yet implemented"<<endl;

    report1<<"#"<<endl << "999" << endl << endl;
  }
  }

  report1 << "ENDDATA" << endl;
  return;
  }  //  end of write data

//********************************************************************
 /*  SS_Label_FUNCTION 39 write_nucontrol  write new control file */
FUNCTION void write_nucontrol()
  {
  cout<<" Write new starter file "<<endl;
  ofstream NuStart("starter.ss_new");
  NuStart<<version_info<<endl<<version_info2<<endl<<version_info3<<endl;
  if(N_SC>0) NuStart<<Starter_Comments<<endl;
  NuStart<<datfilename<<endl<<ctlfilename<<endl;
  NuStart<<readparfile<<" # 0=use init values in control file; 1=use ss.par"<<endl;
  NuStart<<rundetail<<" # run display detail (0,1,2)"<<endl;
  NuStart<<reportdetail<<" # detailed age-structured reports in REPORT.SSO (0=low,1=high,2=low for data-limited) "<<endl;
  NuStart<<docheckup<<" # write detailed checkup.sso file (0,1) "<<endl;
  NuStart<<Do_ParmTrace<<" # write parm values to ParmTrace.sso (0=no,1=good,active; 2=good,all; 3=every_iter,all_parms; 4=every,active)"<<endl;
  NuStart<<Do_CumReport<<" # write to cumreport.sso (0=no,1=like&timeseries; 2=add survey fits)"<<endl;
  NuStart<<Do_all_priors<<" # Include prior_like for non-estimated parameters (0,1) "<<endl;
  NuStart<<SoftBound<<" # Use Soft Boundaries to aid convergence (0,1) (recommended)"<<endl;
  NuStart<<N_nudata<<" # Number of datafiles to produce: 1st is input, 2nd is estimates, 3rd and higher are bootstrap"<<endl;
  NuStart<<Turn_off_phase<<" # Turn off estimation for parameters entering after this phase"<<endl;
  NuStart<<burn_intvl<<" # MCeval burn interval"<<endl;
  NuStart<<thin_intvl<<" # MCeval thin interval"<<endl;
  NuStart<<jitter<<" # jitter initial parm value by this fraction"<<endl;
  NuStart<<STD_Yr_min<<" # min yr for sdreport outputs (-1 for styr)"<<endl;
  NuStart<<STD_Yr_max<<" # max yr for sdreport outputs (-1 for endyr; -2 for endyr+Nforecastyrs"<<endl;
  NuStart<<N_STD_Yr_RD<<" # N individual STD years "<<endl;
  NuStart<<"#vector of year values "<<endl<<STD_Yr_RD<<endl;

  NuStart<<final_conv<<" # final convergence criteria (e.g. 1.0e-04) "<<endl;
  NuStart<<retro_yr-endyr<<" # retrospective year relative to end year (e.g. -4)"<<endl;
  NuStart<<Smry_Age<<" # min age for calc of summary biomass"<<endl;
  NuStart<<depletion_basis<<" # Depletion basis:  denom is: 0=skip; 1=rel X*B0; 2=rel X*Bmsy; 3=rel X*B_styr"<<endl;
  NuStart<<depletion_level<<" # Fraction (X) for Depletion denominator (e.g. 0.4)"<<endl;
  NuStart<<SPR_reporting<<" # SPR_report_basis:  0=skip; 1=(1-SPR)/(1-SPR_tgt); 2=(1-SPR)/(1-SPR_MSY); 3=(1-SPR)/(1-SPR_Btarget); 4=rawSPR"<<endl;
  NuStart<<F_reporting<<" # F_report_units: 0=skip; 1=exploitation(Bio); 2=exploitation(Num); 3=sum(Frates); 4=true F for range of ages"<<endl;
  if(F_reporting==4)
  {NuStart<<F_reporting_ages<<" #_min and max age over which average F will be calculated"<<endl;}
  else
  {NuStart<<"#COND 10 15 #_min and max age over which average F will be calculated with F_reporting=4"<<endl;}
  NuStart<<F_std_basis<<" # F_report_basis: 0=raw_F_report; 1=F/Fspr; 2=F/Fmsy ; 3=F/Fbtgt"<<endl;
  NuStart<<mcmc_output_detail<<" # MCMC output detail (0=default; 1=obj func components; 2=expanded; 3=make output subdir for each MCMC vector)"<<endl;
  NuStart<<ALK_tolerance<<" # ALK tolerance (example 0.0001)"<<endl;
  NuStart<<"3.30 # check value for end of file and for version control"<<endl;
  NuStart.close();

  cout<<" Write new forecast file "<<endl;
  ofstream NuFore("forecast.ss_new");
  NuFore<<version_info<<endl;
  if(N_FC>0) NuFore<<Forecast_Comments<<endl;
  NuFore<<"# for all year entries except rebuilder; enter either: actual year, -999 for styr, 0 for endyr, neg number for rel. endyr"<<endl;
  NuFore<<Do_Benchmark<<" # Benchmarks: 0=skip; 1=calc F_spr,F_btgt,F_msy "<<endl;
  NuFore<<Do_MSY<<" # MSY: 1= set to F(SPR); 2=calc F(MSY); 3=set to F(Btgt); 4=set to F(endyr) "<<endl;
  NuFore<<SPR_target<<" # SPR target (e.g. 0.40)"<<endl;
  NuFore<<BTGT_target<<" # Biomass target (e.g. 0.40)"<<endl;
  NuFore<<"#_Bmark_years: beg_bio, end_bio, beg_selex, end_selex, beg_relF, end_relF, beg_recr_dist, end_recr_dist, beg_SRparm, end_SRparm (enter actual year, or values of 0 or -integer to be rel. endyr)"<<endl<<Bmark_Yr<<endl;
  NuFore<<Bmark_RelF_Basis<<" #Bmark_relF_Basis: 1 = use year range; 2 = set relF same as forecast below"<<endl;
  NuFore<<"#"<<endl<<Do_Forecast<<" # Forecast: 0=none; 1=F(SPR); 2=F(MSY) 3=F(Btgt); 4=Ave F (uses first-last relF yrs); 5=input annual F scalar"<<endl;
  NuFore<<N_Fcast_Yrs<<" # N forecast years "<<endl;
  NuFore<<Fcast_Flevel<<" # F scalar (only used for Do_Forecast==5)"<<endl;
  NuFore<<"#_Fcast_years:  beg_selex, end_selex, beg_relF, end_relF, beg_recruits, end_recruits  (enter actual year, or values of 0 or -integer to be rel. endyr)"<<endl<<Fcast_yr_rd<<endl;
  NuFore<<Fcast_Specify_Selex<<" # Forecast selectivity (0=fcast selex is mean from year range; 1=fcast selectivity from annual time-vary parms)"<<endl;

  NuFore<<HarvestPolicy<<" # Control rule method (1=catch=f(SSB) west coast; 2=F=f(SSB) ) "<<endl;
  NuFore<<H4010_top<<" # Control rule Biomass level for constant F (as frac of Bzero, e.g. 0.40); (Must be > the no F level below) "<<endl;
  NuFore<<H4010_bot<<" # Control rule Biomass level for no F (as frac of Bzero, e.g. 0.10) "<<endl;
  NuFore<<H4010_scale<<" # Control rule target as fraction of Flimit (e.g. 0.75) "<<endl;

  NuFore<<Fcast_Loop_Control(1)<<" #_N forecast loops (1=OFL only; 2=ABC; 3=get F from forecast ABC catch with allocations applied)"<<endl;
  NuFore<<Fcast_Loop_Control(2)<<" #_First forecast loop with stochastic recruitment"<<endl;
  NuFore<<Fcast_Loop_Control(3)<<" #_Forecast loop control #3 (reserved for future bells&whistles) "<<endl;
  NuFore<<Fcast_Loop_Control(4)<<" #_Forecast loop control #4 (reserved for future bells&whistles) "<<endl;
  NuFore<<Fcast_Loop_Control(5)<<" #_Forecast loop control #5 (reserved for future bells&whistles) "<<endl;
  NuFore<<Fcast_Cap_FirstYear<<"  #FirstYear for caps and allocations (should be after years with fixed inputs) "<<endl;

  NuFore<<Impl_Error_Std<<" # stddev of log(realized catch/target catch) in forecast (set value>0.0 to cause active impl_error)"<<endl;

  NuFore<<Do_Rebuilder<<" # Do West Coast gfish rebuilder output (0/1) "<<endl;
  NuFore<<Rebuild_Ydecl<<" # Rebuilder:  first year catch could have been set to zero (Ydecl)(-1 to set to 1999)"<<endl;
  NuFore<<Rebuild_Yinit<<" # Rebuilder:  year for current age structure (Yinit) (-1 to set to endyear+1)"<<endl;

  NuFore<<Fcast_RelF_Basis<<" # fleet relative F:  1=use first-last alloc year; 2=read seas, fleet, alloc list below"<<endl;
  NuFore<<"# Note that fleet allocation is used directly as average F if Do_Forecast=4 "<<endl;

  NuFore<<Fcast_Catch_Basis<<" # basis for fcast catch tuning and for fcast catch caps and allocation  (2=deadbio; 3=retainbio; 5=deadnum; 6=retainnum)"<<endl;

    NuFore<<"# Conditional input if relative F choice = 2"<<endl;
    NuFore<<"# enter list of:  season,  fleet, relF; if used, terminate with season=-9999"<<endl;
    {
      for (s=1;s<=nseas;s++)
      for(f=1;f<=Nfleet;f++)
      {
        if(Fcast_RelF_Use(s,f)>0.0)
          {
            if(Fcast_RelF_Basis==1)  NuFore<<"# ";
            NuFore<<s<<" "<<f<<" "<<Fcast_RelF_Use(s,f)<<endl;
          }
      }
      if(Fcast_RelF_Basis==2) NuFore<<"-9999 0 0  # terminator for list of relF"<<endl;
    }

  NuFore<<"# enter list of: fleet number, max annual catch for fleets with a max; terminate with fleet=-9999"<<endl;
  for(f=1;f<=Nfleet;f++)
  {
    if(Fcast_MaxFleetCatch(f)>-1) NuFore<<f<<" "<<Fcast_MaxFleetCatch(f)<<endl;
  }
  NuFore<<"-9999 -1"<<endl;

  NuFore<<"# enter list of area ID and max annual catch; terminate with area=-9999"<<endl;
  for(p=1;p<=pop;p++)
  {
    if(Fcast_MaxAreaCatch(p)>-1) NuFore<<p<<" "<<Fcast_MaxAreaCatch(p)<<endl;
  }
  NuFore<<"-9999 -1"<<endl;

  NuFore<<"# enter list of fleet number and allocation group assignment, if any; terminate with fleet=-9999"<<endl;
  for(f=1;f<=Nfleet;f++)
  {
    if(Allocation_Fleet_Assignments(f)>0) NuFore<<f<<" "<<Allocation_Fleet_Assignments(f)<<endl;
  }
  NuFore<<"-9999 -1"<<endl;

  NuFore<<"#_if N allocation groups >0, list year, allocation fraction for each group "<<endl;
  NuFore<<"# list sequentially because read values fill to end of N forecast"<<endl;
  NuFore<<"# terminate with -9999 in year field "<<endl;

  if(Fcast_Catch_Allocation_Groups>0)
    {
      if(finish_starter==999)
      {
        NuFore<<endyr+1<<" "<<Fcast_Catch_Allocation(1)<<endl;
      }
      else
      {
        j=Fcast_Catch_Allocation_list.size()-1;
        for(k=0;k<=j-1;k++)  NuFore<<Fcast_Catch_Allocation_list[k]<<endl;
      }
      NuFore<<" -9999 ";
      for (j=1;j<=Fcast_Catch_Allocation_Groups;j++) {NuFore<<" 1 ";}
      NuFore<<endl;
    }
    else
    {NuFore<<"# no allocation groups"<<endl;}

  NuFore<<Fcast_InputCatch_Basis<<
  " # basis for input Fcast catch: -1=read basis with each obs; 2=dead catch; 3=retained catch; 99=input Hrate(F)"<<endl;

  NuFore<<"#enter list of Fcast catches; terminate with line having year=-9999"<<endl;
  NuFore<<"#_Yr Seas Fleet Catch(or_F)";
  if(Fcast_InputCatch_Basis==-1) NuFore<<" Basis ";
  NuFore<<endl;
  for(j=1;j<=N_Fcast_Input_Catches;j++) {NuFore<<Fcast_InputCatch_rd(j)<<endl;}
  NuFore<<"-9999 1 1 0 ";
  if(Fcast_InputCatch_Basis==-1) NuFore<<" 2 ";
  NuFore<<endl;
  NuFore<<"#"<<endl<<999<<" # verify end of input "<<endl;
  NuFore.close();

//**********************************************************
  cout<<" Write new control file "<<endl;

  ofstream report4("control.ss_new");
  report4<<version_info<<endl;
  if(N_CC>0) report4<<Control_Comments<<endl;
  report4 << "#_data_and_control_files: "<<datfilename<<" // "<<ctlfilename<<endl;
  report4<<version_info<<endl<<version_info2<<endl<<version_info3<<endl;
  report4<<WTage_rd<<"  # 0 means do not read wtatage.ss; 1 means read and use wtatage.ss and also read and use growth parameters"<<endl;
  report4 << N_GP << "  #_N_Growth_Patterns"<<endl;
  report4 << N_platoon << " #_N_platoons_Within_GrowthPattern "<<endl;
  if(N_platoon==1) report4<<"#_Cond ";
  report4<<sd_ratio<<" #_Morph_between/within_stdev_ratio (no read if N_morphs=1)"<<endl;
  if(N_platoon==1) report4<<"#_Cond ";
  report4<<platoon_distr(1,N_platoon)<<" #vector_Morphdist_(-1_in_first_val_gives_normal_approx)"<<endl;
  report4<<"#"<<endl;
  if(finish_starter==999)
    {report4<<2<<" # recr_dist_method for parameters:  2=main effects for GP, Settle timing, Area; 3=each Settle entity; 4=none when N_GP*Nsettle*pop==1"<<endl;}
    else
    {report4<<recr_dist_method<<" # recr_dist_method for parameters:  2=main effects for GP, Area, Settle timing; 3=each Settle entity"<<endl;}
  report4<<recr_dist_area<<" # not yet implemented; Future usage: Spawner-Recruitment: 1=global; 2=by area"<<endl;
  report4<<N_settle_assignments<<" #  number of recruitment settlement assignments "<<endl;
  report4<<0<< " # unused option"<<endl;
  report4<<"#GPattern month  area  age (for each settlement assignment)"<<endl<<settlement_pattern_rd<<endl<<"#"<<endl;
  if(pop==1)
  {report4<<"#_Cond 0 # N_movement_definitions goes here if Nareas > 1"<<endl
    <<"#_Cond 1.0 # first age that moves (real age at begin of season, not integer) also cond on do_migration>0"<<endl
    <<"#_Cond 1 1 1 2 4 10 # example move definition for seas=1, morph=1, source=1 dest=2, age1=4, age2=10"<<endl;}
  else
  {
    report4<<do_migration<<" #_N_movement_definitions"<<endl;
    if(do_migration>0)
    {
      report4<<migr_firstage<<" # first age that moves (real age at begin of season, not integer)"<<endl
      <<"# seas,GP,source_area,dest_area,minage,maxage"<<endl<<move_def<<endl;
    }
    else
    {
    report4<<"#_Cond 1.0 # first age that moves (real age at begin of season, not integer) if do_migration>0"<<endl
    <<"#_Cond 1 1 1 2 4 10 # example move definition for seas=1, GP=1, source=1 dest=2, age1=4, age2=10"<<endl;
    }
  }
  report4<<"#"<<endl;
  report4<<N_Block_Designs<<" #_Nblock_Patterns"<<endl;
  if(N_Block_Designs>0)
  {report4<<Nblk<<" #_blocks_per_pattern "<<endl<<"# begin and end years of blocks"<<endl<<Block_Design<<endl;}
  else
  {report4<<"#_Cond "<<0<<" #_blocks_per_pattern "<<endl<<"# begin and end years of blocks"<<endl;}
  report4<<"#"<<endl;
  report4<<"# controls for all timevary parameters "<<endl;
  report4<<parm_adjust_method<<" #_env/block/dev_adjust_method for all time-vary parms (1=warn relative to base parm bounds; 3=no bound check)"<<endl<<"#  autogen"<<endl;
  if(timevary_cnt>0)
  {
    report4<<"1 1 1 1 1 # autogen: 1st element for biology, 2nd for SR, 3rd for Q, 4th reserved, 5th for selex"<<endl;
  }
  else
  {
    report4<<"0 0 0 0 0 # autogen: 1st element for biology, 2nd for SR, 3rd for Q, 4th reserved, 5th for selex"<<endl;
  }
  report4<<"# where: 0 = autogen all time-varying parms; 1 = read each time-varying parm line; 2 = read then autogen if parm min==-12345"<<endl<<"# "<<endl;

  report4<<"#"<<endl<<"# setup for M, growth, maturity, fecundity, recruitment distibution, movement "<<endl;
  report4<<"#"<<endl<<natM_type<<" #_natM_type:_0=1Parm; 1=N_breakpoints;_2=Lorenzen;_3=agespecific;_4=agespec_withseasinterpolate"<<endl;
    if(natM_type==1)
    {report4<<N_natMparms<<" #_N_breakpoints"<<endl<<NatM_break<<" # age(real) at M breakpoints"<<endl;}
    else if(natM_type==2)
    {report4<<natM_amin<<" #_reference age for Lorenzen M; read 1P per morph"<<endl;}
    else if(natM_type>=3)
    {report4<<" #_Age_natmort_by sex x growthpattern"<<endl<<Age_NatMort<<endl;}
    else
    {report4<<"  #_no additional input for selected M option; read 1P per morph"<<endl;}

    report4<<Grow_type<<" # GrowthModel: 1=vonBert with L1&L2; 2=Richards with L1&L2; 3=age_specific_K; 4=not implemented"<<endl;
    if(Grow_type<=3)
    {report4<<AFIX<<" #_Age(post-settlement)_for_L1;linear growth below this"<<endl<<
      AFIX2<<" #_Growth_Age_for_L2 (999 to use as Linf)"<<endl<<
      Linf_decay<<" #_exponential decay for growth above maxage (fixed at 0.2 in 3.24; value should approx initial Z; -999 replicates 3.24)"<<endl;
      report4<<"0  #_placeholder for future growth feature"<<endl;
      if(Grow_type==3)
      {report4<<Age_K_count<<" # number of K multipliers to read"<<endl<<Age_K_points<<" # ages for K multiplier"<<endl;}
    }
    else
    {report4<<" #_growth type 4 is not implemented"<<endl;}

    report4<<SD_add_to_LAA<<" #_SD_add_to_LAA (set to 0.1 for SS2 V1.x compatibility)"<<endl;   // constant added to SD length-at-age (set to 0.1 for compatibility with SS2 V1.x
    report4<<CV_depvar<<" #_CV_Growth_Pattern:  0 CV=f(LAA); 1 CV=F(A); 2 SD=F(LAA); 3 SD=F(A); 4 logSD=F(A)"<<endl;
    report4<<Maturity_Option<<" #_maturity_option:  1=length logistic; 2=age logistic; 3=read age-maturity matrix by growth_pattern; 4=read age-fecundity; 5=disabled; 6=read length-maturity"<<endl;
    if(Maturity_Option==3)
    {report4<<"#_Age_Maturity by growth pattern"<<endl<<Age_Maturity<<endl;}
    else if(Maturity_Option==4)
    {report4<<"#_Age_Fecundity by growth pattern"<<endl<<Age_Maturity<<endl;}
    else if(Maturity_Option==5)
    {report4<<"#_Age_Fecundity by growth pattern from wt-at-age.ss now invoked by read bodywt flag"<<endl;}
    else if(Maturity_Option==6)
    {report4<<"#_Length_Maturity by growth pattern"<<endl<<Length_Maturity<<endl;}
    report4<<First_Mature_Age<<" #_First_Mature_Age"<<endl;

    report4<<Fecund_Option<<" #_fecundity option:(1)eggs=Wt*(a+b*Wt);(2)eggs=a*L^b;(3)eggs=a*Wt^b; (4)eggs=a+b*L; (5)eggs=a+b*W"<<endl;
    report4<<Hermaphro_Option<<" #_hermaphroditism option:  0=none; 1=female-to-male age-specific fxn; -1=male-to-female age-specific fxn"<<endl;
    if (Hermaphro_Option!=0) report4<<Hermaphro_seas<<" # Hermaphro_season "<<endl<<Hermaphro_maleSPB<<" # Hermaphro_maleSSB "<<endl;
    report4<<MGparm_def<<" #_parameter_offset_approach (1=none, 2= M, G, CV_G as offset from female-GP1, 3=like SS2 V1.x)"<<endl;
  report4<<"#"<<endl;
  report4<<"#_growth_parms"<<endl;
  report4<<"#_ LO HI INIT PRIOR PR_SD PR_type PHASE env_var&link dev_link dev_minyr dev_maxyr dev_PH Block Block_Fxn"<<endl;
  NP=0;
  for (f=1;f<=N_MGparm;f++)
  {
    NP++;
    MGparm_1(f,3)=value(MGparm(f));
    report4<<MGparm_1(f)<<" # "<<ParmLabel(NP)<<endl;
  }
  if(frac_female_pointer == -1)
  {
    // placeholders to change fracfemale (3.24) to MGparm (3.30)
    for (gp=1;gp<=N_GP;gp++)
    {
        report4 << " 0.000001 0.999999 " << femfrac(gp) << " 0.5  0.5 0 -99 0 0 0 0 0 0 0 " << "# FracFemale_GP_" << gp << endl;
    }
  }
  report4<<"#"<<endl;
  j=N_MGparm;
  if(timevary_parm_cnt_MG>0)
  {
    report4<<"# timevary MG parameters "<<endl<<"#_ LO HI INIT PRIOR PR_SD PR_type  PHASE"<<endl;
    for (f=1;f<=timevary_parm_cnt_MG;f++)
    {NP++;
    timevary_parm_rd[f](3)=value(timevary_parm(f));
    report4<<timevary_parm_rd[f]<<" # "<<ParmLabel(NP)<<endl;}
    report4<<"# info on dev vectors created for MGparms are reported with other devs after tag parameter section "<<endl;
  }
  else
  {
    report4<<"#_no timevary MG parameters"<<endl;
  }

  report4<<"#"<<endl;
  report4<<"#_seasonal_effects_on_biology_parms"<<endl<<MGparm_seas_effects<<" #_femwtlen1,femwtlen2,mat1,mat2,fec1,fec2,Malewtlen1,malewtlen2,L1,K"<<endl;
  report4<<"#_ LO HI INIT PRIOR PR_SD PR_type PHASE"<<endl;
  if(MGparm_doseas>0)
  {
    for (f=1;f<=N_MGparm_seas;f++)
    {
      NP++; j++;  MGparm_seas_1(f,3)=value(MGparm(j));
      report4<<MGparm_seas_1(f)<<" # "<<ParmLabel(NP)<<endl;
    }
  }
  else
  {
    report4<<"#_Cond -2 2 0 0 -1 99 -2 #_placeholder when no seasonal MG parameters"<<endl;
  }

  report4<<"#"<<endl;
   report4<<"#_Spawner-Recruitment"<<endl<<SR_fxn<<" #_SR_function: 2=Ricker; 3=std_B-H; 4=SCAA; 5=Hockey; 6=B-H_flattop; 7=survival_3Parm; 8=Shepard_3Parm"<<endl;
   report4<<init_equ_steepness<<"  # 0/1 to use steepness in initial equ recruitment calculation"<<endl;
   report4<<sigmaR_dendep<<"  #  future feature:  0/1 to make realized sigmaR a function of SR curvature"<<endl;
   report4<<"#_          LO            HI          INIT         PRIOR         PR_SD       PR_type      PHASE    env-var    use_dev   dev_mnyr   dev_mxyr     dev_PH      Block    Blk_Fxn #  parm_name"<<endl;
   report4.unsetf(std::ios_base::fixed); report4.unsetf(std::ios_base::floatfield);
   for (f=1;f<=N_SRparm2;f++)
   { NP++;
     SR_parm_1(f,3)=value(SR_parm(f));
      for(j=1;j<=6;j++) report4<<setw(14)<<SR_parm_1(f,j);
      for(j=7;j<=14;j++) report4<<setw(11)<<SR_parm_1(f,j);
      report4<<" # "<<ParmLabel(NP)<<endl;
   }
   report4.unsetf(std::ios_base::fixed); report4.unsetf(std::ios_base::floatfield);
   if(N_SRparm3>N_SRparm2)
    {
       report4<<"#Next are short parm lines for timevary "<<endl;
       for (f=timevary_parm_start_SR;f<=timevary_parm_cnt_SR;f++)
       {
          NP++;
          timevary_parm_rd[f](3)=value(timevary_parm(f));
          report4<<timevary_parm_rd[f]<<" # "<<ParmLabel(NP)<<endl;
       }
       report4.precision(6); report4.unsetf(std::ios_base::fixed); report4.unsetf(std::ios_base::floatfield);
    }

   report4<<do_recdev<<" #do_recdev:  0=none; 1=devvector; 2=simple deviations"<<endl;
   report4<<recdev_start<<" # first year of main recr_devs; early devs can preceed this era"<<endl;
   report4<<recdev_end<<" # last year of main recr_devs; forecast devs start in following year"<<endl;
   report4<<recdev_PH_rd<<" #_recdev phase "<<endl;
   report4<<recdev_adv<<" # (0/1) to read 13 advanced options"<<endl;
   if(recdev_adv==0) {onenum="#_Cond ";} else {onenum=" ";}
   report4<<onenum<<recdev_early_start_rd<<" #_recdev_early_start (0=none; neg value makes relative to recdev_start)"<<endl;
   report4<<onenum<<recdev_early_PH_rd<<" #_recdev_early_phase"<<endl;
   report4<<onenum<<Fcast_recr_PH_rd<<" #_forecast_recruitment phase (incl. late recr) (0 value resets to maxphase+1)"<<endl;
   report4<<onenum<<Fcast_recr_lambda<<" #_lambda for Fcast_recr_like occurring before endyr+1"<<endl;
   report4<<onenum<<recdev_adj(1)<<" #_last_early_yr_nobias_adj_in_MPD"<<endl;
   report4<<onenum<<recdev_adj(2)<<" #_first_yr_fullbias_adj_in_MPD"<<endl;
   report4<<onenum<<recdev_adj(3)<<" #_last_yr_fullbias_adj_in_MPD"<<endl;
   report4<<onenum<<recdev_adj(4)<<" #_first_recent_yr_nobias_adj_in_MPD"<<endl;
   report4<<onenum<<recdev_adj(5)<<" #_max_bias_adj_in_MPD (-1 to override ramp and set biasadj=1.0 for all estimated recdevs)"<<endl;
   report4<<onenum<<recdev_cycle<<" #_period of cycles in recruitment (N parms read below)"<<endl;
   report4<<onenum<<recdev_LO<<" #min rec_dev"<<endl;
   report4<<onenum<<recdev_HI<<" #max rec_dev"<<endl;
   report4<<onenum<<recdev_read<<" #_read_recdevs"<<endl;
   report4<<"#_end of advanced SR options"<<endl;
   report4<<"#"<<endl;
   if(recdev_cycle>0)
   {
     for (y=1;y<=recdev_cycle;y++)
     {
       NP++;
       recdev_cycle_parm_RD(y,3)=value(recdev_cycle_parm(y));
       report4<<recdev_cycle_parm_RD(y)<<" # "<<ParmLabel(NP)<<endl;
     }
   }
   else
   {
     report4<<"#_placeholder for full parameter lines for recruitment cycles"<<endl;
   }
    if(recdev_read>0)
    {
      report4<<"# Specified recr devs to read"<<endl;
      report4<<"#_Yr Input_value # Final_value"<<endl;
      for (j=1;j<=recdev_read;j++)
      {
        y=recdev_input(j,1);
        report4<<recdev_input(j)<<" # ";
        if(y>=recdev_first)
        {report4<<recdev(y)<<endl;}
        else
        {report4<<" not used "<<endl;}
      }
    }
    else
    {
      report4<<"# read specified recr devs"<<endl;
      report4<<"#_Yr Input_value"<<endl;
    }
    report4<<"#"<<endl;
    report4<<"# all recruitment deviations"<<endl<<"# ";
    if(recdev_do_early>0)
    {
      for (y=recdev_early_start;y<=recdev_early_end;y++) {report4<<" "<<y<<"E";}
    }
    if(do_recdev>0)
    {
      for (y=recdev_start;y<=recdev_end;y++) {report4<<" "<<y<<"R";}
    }
    if(Do_Forecast>0)
    {
      for (y=recdev_end+1;y<=YrMax;y++) {report4<<" "<<y<<"F";}
    }
    report4<<endl<<"# ";
  if(recdev_do_early>0)
  {
    for (y=recdev_early_start;y<=recdev_early_end;y++)  {NP++;  report4<<" "<<recdev(y);}
  }

    if(do_recdev>0)
    {
      for (y=recdev_start;y<=recdev_end;y++)  {NP++;  report4<<" "<<recdev(y);}
    }

    if(Do_Forecast>0)
    {
      for (y=recdev_end+1;y<=YrMax;y++)  {NP++;  report4<<" "<<recdev(y);}
      report4<<endl<<"# implementation error by year in forecast: ";
      for (y=endyr+1;y<=YrMax;y++)
      {
        NP++;  report4<<" "<<Fcast_impl_error(y);
      }
    }
  report4<<endl<<"#"<<endl;
  report4<<"#Fishing Mortality info "<<endl<<F_ballpark<<" # F ballpark"<<endl;
  report4<<F_ballpark_yr<<" # F ballpark year (neg value to disable)"<<endl;
  report4<<F_Method<<" # F_Method:  1=Pope; 2=instan. F; 3=hybrid (hybrid is recommended)"<<endl;
  report4<<max_harvest_rate<<" # max F or harvest rate, depends on F_Method"<<endl;
  report4<<"# no additional F input needed for Fmethod 1"<<endl;
  report4<<"# if Fmethod=2; read overall start F value; overall phase; N detailed inputs to read"<<endl;
  report4<<"# if Fmethod=3; read N iterations for tuning for Fmethod 3"<<endl;
 if(F_Method==2)
  {
    report4<<F_setup<<" # overall start F value; overall phase; N detailed inputs to read"<<endl;
    report4<<"#Fleet Yr Seas F_value se phase (for detailed setup of F_Method=2; -Yr to fill remaining years)"<<endl<<F_setup2<<endl;
  }
  else if(F_Method==3)
  {report4<<F_Tune<<"  # N iterations for tuning F in hybrid method (recommend 3 to 7)"<<endl;}

   report4<<"#"<<endl;
   report4<<"#_initial_F_parms; count = "<<N_init_F2<<endl;
   report4<<"#_ LO HI INIT PRIOR PR_SD  PR_type  PHASE"<<endl;
   if(finish_starter==999)
   {
     for (f=1;f<=Nfleet1;f++)
     {
      NP++;
      init_F_parm_1(f,3)=value(init_F(f));
      if(obs_equ_catch(1,f)!=0.) report4<<init_F_parm_1(f)<<" # "<<ParmLabel(NP)<<endl;
     }
   }
   else
   {
     for (f=1;f<=N_init_F2;f++)
     {
      NP++;
      init_F_parm_1(f,3)=value(init_F(f));
      report4<<init_F_parm_1(f)<<" # "<<ParmLabel(NP)<<endl;
     }
   }

    report4<<"#"<<YrMax<<" "<<TimeMax+nseas<<endl<<"# F rates by fleet"<<endl;
    report4<<"# Yr: ";
    for(y=styr;y<=YrMax;y++)
    for(s=1;s<=nseas;s++)
    {report4<<" "<<y;}
    report4<<endl<<"# seas: ";
    for(y=styr;y<=YrMax;y++)
    for(s=1;s<=nseas;s++)
    {report4<<" "<<s;}
    report4<<endl;
    j = styr+(YrMax-styr)*nseas+nseas-1;
    for (f=1;f<=Nfleet;f++)
    if(fleet_type(f)<=2)
    {
      report4<<"# "<<fleetname(f)<<Hrate(f)(styr,j)<<endl;
    }
   NP+=N_Fparm;
   report4<<"#"<<endl;
   report4<<"#_Q_setup for fleets with cpue or survey data"<<endl;
   report4<<"#_1:  link type: (1=simple q, 1 parm; 2=mirror simple q, 1 mirrored parm; 3=q and power, 2 parm)"<<endl;
   report4<<"#_2:  extra input for link, i.e. mirror fleet"<<endl;
   report4<<"#_3:  0/1 to select extra sd parameter"<<endl;
   report4<<"#_4:  0/1 for biasadj or not"<<endl;
   report4<<"#_5:  0/1 to float"<<endl;
    if(depletion_fleet>0)  //  special code for depletion, so prepare to adjust phases and lambdas
      {
        f=depletion_fleet;
        report4<<"#_survey: "<<f<<" "<<fleetname(f)<<" is a depletion fleet"<<endl;
        if(depletion_type==0)
          report4<<"#_Q_setup(f,2)=0; add 1 to phases of all parms; only R0 active in new phase 1"<<endl;
        if(depletion_type==1)
          report4<<"#_Q_setup(f,2)=1  only R0 active in phase 1; then exit;  useful for data-limited draws of other fixed parameter"<<endl;
        if(depletion_type==2)
          report4<<"#_Q_setup(f,2)=2  no phase adjustments, can be used when profiling on fixed R0"<<endl;
      }

   report4<<"#_   fleet      link link_info  extra_se   biasadj     float  #  fleetname"<<endl;
   for (f=1;f<=Nfleet;f++)
   {
     if(Svy_N_fleet(f)>0)
     	{
     		report4<<" "<<setw(9)<<f;
     	  for(j=1;j<=5;j++) report4<<setw(10)<<Q_setup(f,j);
     	  report4<<"  #  "<<fleetname(f)<<endl;
      }
   }
   report4<<"-9999 0 0 0 0 0"<<endl<<"#"<<endl;

   report4<<"#_Q_parms(if_any);Qunits_are_ln(q)"<<endl;
   if(Q_Npar>0)
   {
   report4<<"#_          LO            HI          INIT         PRIOR         PR_SD       PR_type      PHASE    env-var    use_dev   dev_mnyr   dev_mxyr     dev_PH      Block    Blk_Fxn  #  parm_name"<<endl;
   report4.unsetf(std::ios_base::fixed); report4.unsetf(std::ios_base::floatfield);
    for (f=1;f<=Q_Npar;f++)
    {
      NP++;
      Q_parm_1(f,3)=value(Q_parm(f));
      for(j=1;j<=6;j++) report4<<setw(14)<<Q_parm_1(f,j);
      for(j=7;j<=14;j++) report4<<setw(11)<<Q_parm_1(f,j);
      report4<<"  #  "<<ParmLabel(NP)<<endl;
    }
    report4.unsetf(std::ios_base::fixed); report4.unsetf(std::ios_base::floatfield);

      if(timevary_parm_start_Q>0)
      {
        report4<<"# timevary Q parameters "<<endl;
        report4<<"#_          LO            HI          INIT         PRIOR         PR_SD       PR_type     PHASE  #  parm_name"<<endl;
        for (f=timevary_parm_start_Q;f<=timevary_parm_cnt_Q;f++)
        {
          NP++;
            timevary_parm_rd[f](3)=value(timevary_parm(f));
            for(j=1;j<=6;j++) report4<<setw(14)<<timevary_parm_rd[f](j);
          report4<<"      "<<timevary_parm_rd[f](7)<<"  # "<<ParmLabel(NP)<<endl;
        }
        report4<<"# info on dev vectors created for Q parms are reported with other devs after tag parameter section "<<endl;
      }
      else
      {
        report4<<"#_no timevary Q parameters"<<endl;
      }
      report4.unsetf(std::ios_base::fixed); report4.unsetf(std::ios_base::floatfield);
   }
   report4<<"#"<<endl;
   report4<<"#_size_selex_patterns"<<endl;

   report4<<"#Pattern:_0; parm=0; selex=1.0 for all sizes"<<endl;
   report4<<"#Pattern:_1; parm=2; logistic; with 95% width specification"<<endl;
   report4<<"#Pattern:_5; parm=2; mirror another size selex; PARMS pick the min-max bin to mirror"<<endl;
   report4<<"#Pattern:_15; parm=0; mirror another age or length selex"<<endl;
   report4<<"#Pattern:_6; parm=2+special; non-parm len selex"<<endl;
   report4<<"#Pattern:_43; parm=2+special+2;  like 6, with 2 additional param for scaling (average over bin range)"<<endl;
   report4<<"#Pattern:_8; parm=8; New doublelogistic with smooth transitions and constant above Linf option"<<endl;
   report4<<"#Pattern:_9; parm=6; simple 4-parm double logistic with starting length; parm 5 is first length; parm 6=1 does desc as offset"<<endl;
   report4<<"#Pattern:_21; parm=2+special; non-parm len selex, read as pairs of size, then selex"<<endl;
   report4<<"#Pattern:_22; parm=4; double_normal as in CASAL"<<endl;
   report4<<"#Pattern:_23; parm=6; double_normal where final value is directly equal to sp(6) so can be >1.0"<<endl;
   report4<<"#Pattern:_24; parm=6; double_normal with sel(minL) and sel(maxL), using joiners"<<endl;
   report4<<"#Pattern:_25; parm=3; exponential-logistic in size"<<endl;
   report4<<"#Pattern:_27; parm=3+special; cubic spline "<<endl;
   report4<<"#Pattern:_42; parm=2+special+3; // like 27, with 2 additional param for scaling (average over bin range)"<<endl;
   
   report4<<"#_discard_options:_0=none;_1=define_retention;_2=retention&mortality;_3=all_discarded_dead;_4=define_dome-shaped_retention"<<endl;
   report4<<"#_Pattern Discard Male Special"<<endl;
   for (f=1;f<=Nfleet;f++) report4<<seltype(f)<<" # "<<f<<" "<<fleetname(f)<<endl;
   report4<<"#"<<endl;
   
   
   report4<<"#_age_selex_types"<<endl;
   report4<<"#Pattern:_0; parm=0; selex=1.0 for ages 0 to maxage"<<endl;
   report4<<"#Pattern:_10; parm=0; selex=1.0 for ages 1 to maxage"<<endl;
   report4<<"#Pattern:_11; parm=2; selex=1.0  for specified min-max age"<<endl;
   report4<<"#Pattern:_12; parm=2; age logistic"<<endl;
   report4<<"#Pattern:_13; parm=8; age double logistic"<<endl;
   report4<<"#Pattern:_14; parm=nages+1; age empirical"<<endl;
   report4<<"#Pattern:_15; parm=0; mirror another age or length selex"<<endl;
   report4<<"#Pattern:_16; parm=2; Coleraine - Gaussian"<<endl;
   report4<<"#Pattern:_17; parm=nages+1; empirical as random walk  N parameters to read can be overridden by setting special to non-zero"<<endl;
   report4<<"#Pattern:_41; parm=2+nages+1; // like 17, with 2 additional param for scaling (average over bin range)"<<endl;
   report4<<"#Pattern:_18; parm=8; double logistic - smooth transition"<<endl;
   report4<<"#Pattern:_19; parm=6; simple 4-parm double logistic with starting age"<<endl;
   report4<<"#Pattern:_20; parm=6; double_normal,using joiners"<<endl;
   report4<<"#Pattern:_26; parm=3; exponential-logistic in age"<<endl;
   report4<<"#Pattern:_27; parm=3+special; cubic spline in age"<<endl;
   report4<<"#Pattern:_42; parm=2+nages+1; // cubic spline; with 2 additional param for scaling (average over bin range)"<<endl;

   report4<<"#_Pattern Discard Male Special"<<endl;
   for (f=1;f<=Nfleet;f++) report4<<seltype(f+Nfleet)<<" # "<<f<<" "<<fleetname(f)<<endl;
   report4<<"#"<<endl;

   report4<<"#_          LO            HI          INIT         PRIOR         PR_SD       PR_type      PHASE    env-var    use_dev   dev_mnyr   dev_mxyr     dev_PH      Block    Blk_Fxn  #  parm_name"<<endl;

   // set back to default configuration for output
   report4.unsetf(std::ios_base::fixed); report4.unsetf(std::ios_base::floatfield);

//  if(seltype(f,2)==4)
  {
      for (f=1;f<=N_selparm;f++)
      {
        NP++;
        selparm_1(f)(3)=value(selparm(f));
        for(j=1;j<=6;j++) report4<<setw(14)<<selparm_1(f,j);
        for(j=7;j<=14;j++) report4<<setw(11)<<selparm_1(f,j);
        report4<<"  #  "<<ParmLabel(NP)<<endl;
      }
  if(N_selparm3 > N_selparm)
  {
    report4<<"# timevary selex parameters "<<endl;
    report4<<"#_          LO            HI          INIT         PRIOR         PR_SD       PR_type    PHASE  #  parm_name"<<endl;
//    for (f=timevary_parm_start_sel;f<=timevary_parm_cnt_sel;f++)
    for (int f=timevary_parm_start_sel;f<=timevary_parm_start_sel+N_selparm3-N_selparm-1;f++)
    {
      NP++;
      timevary_parm_rd[f](3)=value(timevary_parm(f));
      for(j=1;j<=6;j++) report4<<setw(14)<<timevary_parm_rd[f](j);
      report4<<"      "<<timevary_parm_rd[f](7)<<"  # "<<ParmLabel(NP)<<endl;
    }
    report4<<"# info on dev vectors created for selex parms are reported with other devs after tag parameter section "<<endl;
  }
  else
  {
    report4<<"#_no timevary selex parameters"<<endl;
  }

  report4<<"#"<<endl<<TwoD_AR_do<<"   #  use 2D_AR1 selectivity(0/1):  experimental feature"<<endl;
  if(TwoD_AR_do>0)
  {
    k=timevary_parm_start_sel+N_selparm3-N_selparm-1;  //  starting point in timevary_parm_rd
    report4<<"#_specifications for 2D_AR1 and associated parameters"<<endl;
    report4<<"#_specs:  fleet, ymin, ymax, amin, amax, sigma_amax, use_rho, len1/age2, devphase"<<endl;
    for(j=1; j<=TwoD_AR_cnt; j++)
    {
       ivector tempvec(1,9);  //  fleet, ymin, ymax, amin, amax, sigma_amax, use_rho, len1/age2, devphase
       tempvec(1,9)=TwoD_AR_def[j](1,9);
       report4<<tempvec<<"  #  2d_AR specs for fleet: "<<fleetname(tempvec(1))<<endl;
       int sigma_amax = tempvec(6);
       int use_rho = tempvec(7);
       int amin = tempvec(4);
       for(a=amin;a<=sigma_amax;a++)
       {
         dvector dtempvec(1,7);  //  Lo, Hi, init, prior, prior_sd, prior_type, phase;
         k++;
         dtempvec=timevary_parm_rd[k](1,7);
         report4<<dtempvec<<"  # sigma_sel for fleet, age/size:  "<<tempvec(1)<<" "<<a<<endl;
       }
       if(use_rho==1)
       {
         dvector dtempvec(1,7);  //  Lo, Hi, init, prior, prior_sd, prior_type, phase;
         k++;
         dtempvec=timevary_parm_rd[k](1,7);
         report4<<dtempvec<<"  # rho_year for fleet:  "<<tempvec(1)<<endl;
         k++;
         dtempvec=timevary_parm_rd[k](1,7);
         report4<<dtempvec<<"  # rho_age for fleet:  "<<tempvec(1)<<endl;
       }
    }
    report4<<"-9999  0 0 0 0 0 0 0 0  # terminator"<<endl;
  }
  else
  {
    report4<<"#_no 2D_AR1 selex offset used"<<endl;
  }

  report4.unsetf(std::ios_base::fixed); report4.unsetf(std::ios_base::floatfield);


  }
//  else
//  {
//    // shenanigans for inserting dome-shaped retention parameter placeholders for 3.24 -> 3.30
//      int NsrP=1;   // number of sets of placeholder retention parameters for 3.24
//      int NrP=0;    // number of placeholder retention parameters for 3.24
//      for (f=1;f<=N_selparm;f++)
//      {
//        if(f==retParmLoc(NsrP))
//        {
//            // insert the placeholders
//            NrP++; report4<<"  1 100 100   0   -1  99  -99  0   0   0   0   0   0   0"<<" # "<<retParmLabel(NrP)<<endl;
//            NrP++; report4<<"-10  10   1   0   -1  99  -99  0   0   0   0   0   0   0"<<" # "<<retParmLabel(NrP)<<endl;
//            NrP++; report4<<"-10  10   1   0   -1  99  -99  0   0   0   0   0   0   0"<<" # "<<retParmLabel(NrP)<<endl;

//            NsrP++;
//        }

//        NP++;
//        selparm_1(f,3)=value(selparm(f));
//        report4<<selparm_1(f)<<" # "<<ParmLabel(NP)<<endl;
//      }
//  }

  j=N_selparm;

  report4<<"#"<<endl<<"# Tag loss and Tag reporting parameters go next"<<endl;
  if(Do_TG>0)
  {
    report4<<1<<" # TG_custom:  0=no read; 1=read"<<endl;
    for (f=1;f<=3*N_TG+2*Nfleet1;f++)
    {
      NP++;
      report4<<TG_parm2(f)<<" # "<<ParmLabel(NP)<<endl;
    }
  }
  else
  {
    report4<<"0  # TG_custom:  0=no read; 1=read if tags exist"<<endl
    <<"#_Cond -6 6 1 1 2 0.01 -4 0 0 0 0 0 0 0  #_placeholder if no parameters"<<endl;;
  }
  report4<<"#"<<endl;
  if(timevary_cnt==0)
    {report4<<"# no timevary parameters"<<endl<<"#"<<endl;}
    else
    {
      report4<<"# deviation vectors for timevary parameters"<<endl
      <<"#  base   base first block   block  env  env   dev   dev   dev   dev   dev"<<endl
      <<"#  type  index  parm trend pattern link  var  vectr link _mnyr  mxyr phase  dev_vector"<<endl;

      for(j=1;j<=timevary_cnt;j++)
      {
//        report4.precision(6);
//        report4.unsetf(std::ios_base::fixed);
//        report4.unsetf(std::ios_base::floatfield);
        report4<<setw(2)<<"# ";
        report4<<setw(5)<<timevary_def[j](1,12);
        if(timevary_def[j](8)>0)  //  now show devs
        {
          report4<<setw(6)<<parm_dev(timevary_def[j](8));
        }
        report4<<setw(6)<<endl;
      }
    }

  report4<<"#"<<endl<<"# Input variance adjustments factors: "<<endl;
  report4<<" #_1=add_to_survey_CV"<<endl;
  report4<<" #_2=add_to_discard_stddev"<<endl;
  report4<<" #_3=add_to_bodywt_CV"<<endl;
  report4<<" #_4=mult_by_lencomp_N"<<endl;
  report4<<" #_5=mult_by_agecomp_N"<<endl;
  report4<<" #_6=mult_by_size-at-age_N"<<endl;
  report4<<" #_7=mult_by_generalized_sizecomp"<<endl;
  report4<<"#_Factor  Fleet  Value"<<endl;
  {
    if (var_adjust_data.size() > 0) for(f=1;f<=Do_Var_adjust;f++) report4<<setw(6)<<var_adjust_data[f-1](1,2)<<" "<<setw(9)<<var_adjust_data[f-1](3)<<endl;
  }
  report4<<" -9999   1    0  # terminator"<<endl;

  report4.precision(6); report4.unsetf(std::ios_base::fixed); report4.unsetf(std::ios_base::floatfield);

  report4<<"#"<<endl<<max_lambda_phase<<" #_maxlambdaphase"<<endl;
  report4<<sd_offset<<" #_sd_offset; must be 1 if any growthCV, sigmaR, or survey extraSD is an estimated parameter"<<endl;

  report4<<"# read "<<N_lambda_changes<<" changes to default Lambdas (default value is 1.0)"<<endl;
  report4<<"# Like_comp codes:  1=surv; 2=disc; 3=mnwt; 4=length; 5=age; 6=SizeFreq; 7=sizeage; 8=catch; 9=init_equ_catch; "<<
   endl<<"# 10=recrdev; 11=parm_prior; 12=parm_dev; 13=CrashPen; 14=Morphcomp; 15=Tag-comp; 16=Tag-negbin; 17=F_ballpark"<<
   endl<<"#like_comp fleet  phase  value  sizefreq_method"<<endl;

  if(N_lambda_changes>0) report4<<Lambda_changes<<endl;
  report4<<"-9999  1  1  1  1  #  terminator"<<endl;

  report4<<"#"<<endl<<"# lambdas (for info only; columns are phases)"<<endl;
  if(Svy_N>0) {for (f=1;f<=Nfleet;f++) report4<<"# "<<surv_lambda(f)<<" #_CPUE/survey:_"<<f<<endl;}
  if(nobs_disc>0) {for (f=1;f<=Nfleet;f++) report4<<"# "<< disc_lambda(f)<<" #_discard:_"<<f<<endl;}
  if(nobs_mnwt>0) {for (f=1;f<=Nfleet;f++) report4<<"# "<< mnwt_lambda(f)<<" #_meanbodywt:"<<f<<endl;}
  if(Nobs_l_tot>0) {for (f=1;f<=Nfleet;f++) report4<<"# "<< length_lambda(f)<<" #_lencomp:_"<<f<<endl;}
  if(Nobs_a_tot>0) {for (f=1;f<=Nfleet;f++) report4<<"# "<< age_lambda(f)<<" #_agecomp:_"<<f<<endl;}
  if(SzFreq_Nmeth>0) for (f=1;f<=SzFreq_N_Like;f++) report4<<"# "<<SzFreq_lambda(f)<<" #_sizefreq:_"<<f<<endl;
  if(nobs_ms_tot>0) {for (f=1;f<=Nfleet;f++) report4<<"# "<< sizeage_lambda(f)<<" #_size-age:_"<<f<<endl;}
  report4<<"# "<< init_equ_lambda<<" #_init_equ_catch"<<endl;
  report4<<"# "<< recrdev_lambda<<" #_recruitments"<<endl;
  report4<<"# "<< parm_prior_lambda<<" #_parameter-priors"<<endl;
  report4<<"# "<< parm_dev_lambda<<" #_parameter-dev-vectors"<<endl;
  if(Do_TG>0)
  {
  for (TG=1;TG<=N_TG;TG++) report4<<"# "<<TG_lambda1(TG)<<" #_TG-comp_group:_"<<TG<<endl;
  for (TG=1;TG<=N_TG;TG++) report4<<"# "<<TG_lambda2(TG)<<" #_TG-negbin_group:_"<<TG<<endl;
  }
  report4<<"# "<< CrashPen_lambda<<" #_crashPenLambda"<<endl;
  if(Do_Morphcomp>0) report4<<"# "<< Morphcomp_lambda<<" #_Morphcomplambda"<<endl;
  report4<<"# "<<F_ballpark_lambda<<" # F_ballpark_lambda"<<endl;

  report4<<Do_More_Std<<" # (0/1) read specs for more stddev reporting "<<endl;

  if(Do_More_Std>0)
  {
    report4<<More_Std_Input<<" # selex type, len/age, year, N selex bins, Growth pattern, N growth ages, NatAge_area(-1 for all), NatAge_yr, N Natages"<<endl;
    if(More_Std_Input(4)>0) report4<<Selex_Std_Pick<<" # vector with selex std bin picks (-1 in first bin to self-generate)"<<endl;
    if(More_Std_Input(6)>0) report4<<Growth_Std_Pick<<" # vector with growth std bin picks (-1 in first bin to self-generate)"<<endl;
    if(More_Std_Input(9)>0) report4<<NatAge_Std_Pick<<" # vector with NatAge std bin picks (-1 in first bin to self-generate)"<<endl;
  }
  else
  {
    report4<<" # 0 1 -1 5 1 5 1 -1 5 # placeholder for selex type, len/age, year, N selex bins, Growth pattern, N growth ages, NatAge_area(-1 for all), NatAge_yr, N Natages"<<endl;
    report4<<" # placeholder for vector of selex bins to be reported"<<endl;
    report4<<" # placeholder for vector of growth ages to be reported"<<endl;
    report4<<" # placeholder for vector of NatAges ages to be reported"<<endl;
  }
  report4<<fim<<endl<<endl; // end of file indicator
  return;
  }  //  end of write nucontrol

//********************************************************************
 /*  SS_Label_FUNCTION 40 write_bigoutput */
FUNCTION void write_bigoutput()
  {
  SS2out.open ("Report.sso");   // this file was created in globals so accessible to the report_parm function
  ofstream SS_compout("CompReport.sso");
//  ofstream SS_compout2("CompReport2.sso");
  ofstream SIS_table("SIS_table.sso");

  SS2out<<version_info<<endl<<version_info2<<endl<<version_info3<<endl<<endl;
  time(&finish);
  SS_compout<<version_info<<endl<<"StartTime: "<<ctime(&start);
  SIS_table<<version_info<<endl<<"StartTime: "<<ctime(&start);
  SIS_table<<endl<<"Data_File: "<<datfilename<<endl;
  SIS_table<<"Control_File: "<<ctlfilename<<endl;

  cout<<" writing big output now "<<endl;
  SS2out<<"StartTime: "<<ctime(&start);
  SS2out<<"EndTime: "<<ctime(&finish);
  elapsed_time = difftime(finish,start);
  hour = long(elapsed_time)/3600;
  minute = long(elapsed_time)%3600/60;
  second = (long(elapsed_time)%3600)%60;
  SS2out<<"This run took: "<<hour<<" hours, "<<minute<<" minutes, "<<second<<" seconds."<<endl;
  SS2out<<"Data_File: "<<datfilename<<endl;
  SS2out<<"Control_File: "<<ctlfilename<<endl;
  if(readparfile>=1) SS2out<<"Start_parm_values_from_SS3.PAR"<<endl;
  SS2out<<endl<<"Convergence_Level: "<<objective_function_value::pobjfun->gmax<<" is_final_gradient"<<endl<<"Hessian: "<<endl;
  if(N_SC>0)
  {
    SS2out<<"#"<<endl<<"Starter_Comments"<<endl<<Starter_Comments<<endl;
  }
  if(N_DC>0)
  {
    SS2out<<"#"<<endl<<"Data_Comments"<<endl<<Data_Comments<<endl;
  }
  if(N_CC>0)
  {
    SS2out<<"#"<<endl<<"Control_Comments"<<endl<<Control_Comments<<endl;
  }
  if(N_FC>0)
  {
    SS2out<<"#"<<endl<<"Forecast_Comments"<<endl<<Forecast_Comments<<endl;
  }

  SS2out<<endl<<"KeyWords"<<endl;
  SS2out<<"X DEFINITIONS"<<endl;
  SS2out<<"X LIKELIHOOD"<<endl;
  SS2out<<"X Input_Variance_Adjustment"<<endl;
  SS2out<<"X PARAMETERS"<<endl;
  SS2out<<"X DERIVED_QUANTITIES"<<endl;
//  SS2out<<"X MGParm_Block_Assignments"<<endl;
//  SS2out<<"X Selex_Block_Assignments"<<endl;
  SS2out<<"X MGparm_By_Year_after_adjustments"<<endl;
  SS2out<<"X selparm(Size)_By_Year_after_adjustments"<<endl;
  SS2out<<"X selparm(Age)_By_Year_after_adjustments"<<endl;
  SS2out<<"X RECRUITMENT_DIST"<<endl;
  SS2out<<"X MORPH_INDEXING"<<endl;
  SS2out<<"X SIZEFREQ_TRANSLATION"<<endl;
  SS2out<<"X MOVEMENT"<<endl;
  SS2out<<"X EXPLOITATION"<<endl;
  SS2out<<"X TIME_SERIES"<<endl;
  SS2out<<"X SPR_series"<<endl;
  SS2out<<"X Kobe_Plot"<<endl;
  SS2out<<"X SPAWN_RECRUIT"<<endl;
  SS2out<<"X Spawning_Biomass_Report_1"<<endl;
  SS2out<<"X NUMBERS_AT_AGE_Annual_1"<<endl;
  SS2out<<"X Z_AT_AGE_Annual_1"<<endl;
  SS2out<<"X Spawning_Biomass_Report_2"<<endl;
  SS2out<<"X NUMBERS_AT_AGE_Annual_2"<<endl;
  SS2out<<"X Z_AT_AGE_Annual_2"<<endl;
  SS2out<<"X INDEX_1"<<endl;
  SS2out<<"X INDEX_2"<<endl;
  SS2out<<"X INDEX_3"<<endl;
  SS2out<<"X CATCH"<<endl;
  SS2out<<"X DISCARD_SPECIFICATION"<<endl;
  SS2out<<"X DISCARD_OUTPUT"<<endl;
  SS2out<<"X DISCARD_MORT"<<endl;
  SS2out<<"X MEAN_BODY_WT"<<endl;
  SS2out<<"X FIT_LEN_COMPS"<<endl;
  SS2out<<"X FIT_AGE_COMPS"<<endl;
  SS2out<<"X FIT_SIZE_COMPS"<<endl;
  SS2out<<"X OVERALL_COMPS"<<endl;
  SS2out<<"X LEN_SELEX"<<endl;
  SS2out<<"X RETENTION"<<endl;
  SS2out<<"X KEEPERS"<<endl;
  SS2out<<"X DEADFISH"<<endl;
  SS2out<<"X AGE_SELEX"<<endl;
  SS2out<<"X ENVIRONMENTAL_DATA"<<endl;
  SS2out<<"X TAG_Recapture"<<endl;
  SS2out<<"X NUMBERS_AT_AGE";
  if (reportdetail == 2) SS2out<<" ---";    // indicate not included
  SS2out<<endl;
  SS2out<<"X BIOMASS_AT_AGE";
  if (reportdetail == 2) SS2out<<" ---";    // indicate not included
  SS2out<<endl;
  SS2out<<"X NUMBERS_AT_LENGTH";
  if (reportdetail == 2) SS2out<<" ---";    // indicate not included
  SS2out<<endl;
  SS2out<<"X BIOMASS_AT_LENGTH";
  if (reportdetail == 2) SS2out<<" ---";    // indicate not included
  SS2out<<endl;
  SS2out<<"X CATCH_AT_AGE";
  if (reportdetail == 2) SS2out<<" ---";    // indicate not included
  SS2out<<endl;
  SS2out<<"X BIOLOGY"<<endl;
  SS2out<<"X SPR/YPR_PROFILE"<<endl;
  SS2out<<"X ACTUAL_SELECTIVITY_MSY";
  if (reportdetail == 2) SS2out<<" ---";    // indicate not included
  SS2out<<endl;
  SS2out<<"X KNIFE_AGE_SELECTIVITY_MSY";
  if (reportdetail == 2) SS2out<<" ---";    // indicate not included
  SS2out<<endl;
  SS2out<<"X SLOT_AGE_SELECTIVITY_MSY";
  if (reportdetail == 2) SS2out<<" ---";    // indicate not included
  SS2out<<endl;
  SS2out<<"X Dynamic_Bzero "<<endl;

  SS2out<<endl<<"DEFINITIONS"<<endl;
  SS2out<<"N_seasons "<<nseas<<endl;
  SS2out<<"Sum_of_months_on_read_was:_ "<<sumseas<<" rescaled_to_sum_to: "<<sum(seasdur)<<endl;
  SS2out<<"Season_Durations "<<seasdur<<endl;
  SS2out<<"fleet_ID#: ";
  for (f=1;f<=Nfleet;f++) SS2out<<" "<<f;
  SS2out<<endl<<"fleet_names: ";
  for (f=1;f<=Nfleet;f++) SS2out<<" "<<fleetname(f);
  SS2out<<endl;
  SS2out<<"#_rows are fleets; columns are: fleet_type, timing, area, units, catch_mult, survey_units survey_error "<<endl;
  for (f=1;f<=Nfleet;f++)
  {
    SS2out<<fleet_setup(f)<<" "<<Svy_units(f)<<" "<<Svy_errtype(f)<<" # Fleet:_"<<f<<"_ "<<fleetname(f)<<endl;
  }

  k=current_phase();
  if(k>max_lambda_phase) k=max_lambda_phase;
  SS2out<<endl<<"LIKELIHOOD "<<obj_fun<<endl;                         //SS_Label_310
  SS2out<<"Component logL*Lambda Lambda"<<endl;
  SS2out<<"TOTAL "<<obj_fun<<endl;
  if(F_Method>1) SS2out <<"Catch "<<catch_like*column(catch_lambda,k)<<endl;
  SS2out <<"Equil_catch "<<equ_catch_like*init_equ_lambda(k)<<" "<<init_equ_lambda(k)<<endl;
  if(Svy_N>0) SS2out <<"Survey "<<surv_like*column(surv_lambda,k)<<endl;
  if(nobs_disc>0) SS2out <<"Discard "<<disc_like*column(disc_lambda,k)<<endl;
  if(nobs_mnwt>0) SS2out <<"Mean_body_wt "<<mnwt_like*column(mnwt_lambda,k)<<endl;
  if(Nobs_l_tot>0) SS2out <<"Length_comp "<<length_like_tot*column(length_lambda,k)<<endl;
  if(Nobs_a_tot>0) SS2out <<"Age_comp "<<age_like_tot*column(age_lambda,k)<<endl;
  if(nobs_ms_tot>0) SS2out <<"Size_at_age "<<sizeage_like*column(sizeage_lambda,k)<<endl;
  if(SzFreq_Nmeth>0) SS2out <<"SizeFreq "<<SzFreq_like*column(SzFreq_lambda,k)<<endl;
  if(Do_Morphcomp>0) SS2out <<"Morphcomp "<<Morphcomp_lambda(k)*Morphcomp_like<<" "<<Morphcomp_lambda(k)<<endl;
  if(Do_TG>0) SS2out <<"Tag_comp "<<TG_like1*column(TG_lambda1,k)<<endl;
  if(Do_TG>0) SS2out <<"Tag_negbin "<<TG_like2*column(TG_lambda2,k)<<endl;
  SS2out <<"Recruitment "<<recr_like*recrdev_lambda(k)<<" "<<recrdev_lambda(k)<<endl;
  SS2out <<"Forecast_Recruitment "<<Fcast_recr_like<<" "<<Fcast_recr_lambda<<endl;
  SS2out <<"Parm_priors "<<parm_like*parm_prior_lambda(k)<<" "<<parm_prior_lambda(k)<<endl;
  if(SoftBound>0) SS2out <<"Parm_softbounds "<<SoftBoundPen<<" "<<" NA "<<endl;
  SS2out <<"Parm_devs "<<(sum(parm_dev_like))*parm_dev_lambda(k)<<" "<<parm_dev_lambda(k)<<endl;
  if(F_ballpark_yr>0) SS2out <<"F_Ballpark "<<F_ballpark_lambda(k)*F_ballpark_like<<" "<<F_ballpark_lambda(k)<<"  ##:est&obs: "<<annual_F(F_ballpark_yr,2)<<" "<<F_ballpark<<endl;
  SS2out <<"Crash_Pen "<<CrashPen_lambda(k)*CrashPen<<" "<<CrashPen_lambda(k)<<endl;

  SS2out<<"_"<<endl<<"Fleet:  ALL ";
  for (f=1;f<=Nfleet;f++) SS2out<<f<<" ";
  SS2out<<endl;
  if(F_Method>1) SS2out<<"Catch_lambda: _ "<<column(catch_lambda,k)<<endl<<"Catch_like: "<<catch_like*column(catch_lambda,k) <<" "<<catch_like<<endl;
  if(Svy_N>0) SS2out<<"Surv_lambda: _ "<<column(surv_lambda,k)<<endl<<"Surv_like: "<<surv_like*column(surv_lambda,k)<<" "<<surv_like<<endl;
  if(nobs_disc>0) SS2out<<"Disc_lambda: _ "<<column(disc_lambda,k)<<endl<<"Disc_like: "<<disc_like*column(disc_lambda,k)<<" "<<disc_like<<endl;
  if(nobs_mnwt>0) SS2out<<"mnwt_lambda: _ "<<column(mnwt_lambda,k)<<endl<<"mnwt_like: "<<mnwt_like*column(mnwt_lambda,k)<<" "<<mnwt_like<<endl;
  if(Nobs_l_tot>0) SS2out<<"Length_lambda: _ "<<column(length_lambda,k)<<endl<<"Length_like: "<<length_like_tot*column(length_lambda,k)<<" "<<length_like_tot<<endl;
  if(Nobs_a_tot>0) SS2out<<"Age_lambda: _ "<<column(age_lambda,k)<<endl<<"Age_like: "<<age_like_tot*column(age_lambda,k)<<" "<<age_like_tot<<endl;
  if(nobs_ms_tot>0) SS2out<<"Sizeatage_lambda: _ "<<column(sizeage_lambda,k)<<endl<<"sizeatage_like: "<<sizeage_like*column(sizeage_lambda,k)<<" "<<sizeage_like<<endl;

  if(N_parm_dev>0)
  {
    SS2out<<"Parm_devs_detail"<<endl<<"Index  Phase  MinYr  MaxYr  stddev  Rho  Like_devs  Like_se  mean  rmse"<<endl;
    for(i=1;i<=N_parm_dev;i++)
    {
      SS2out<<i<<" "<<parm_dev_PH(i)<<" "<<parm_dev_minyr(i)<<" "<<parm_dev_maxyr(i)<<" "<<parm_dev_stddev(i)<<" "<<
      parm_dev_rho(i)<<" "<<parm_dev_like(i)<<" "<<
      sum(parm_dev(i))/float(parm_dev_maxyr(i)-parm_dev_minyr(i)+1.)<<" "<<
      sqrt(sumsq(parm_dev(i)+1.0e-9)/float(parm_dev_maxyr(i)-parm_dev_minyr(i)+1.))<<endl;
    }
  }
  if(SzFreq_Nmeth>0)
  {
    for (j=1;j<=SzFreq_Nmeth;j++)
    {
      SS2out<<"SizeFreq_lambda:_"<<j<<"; ";
    if(j==1) {SS2out<<"_ ";} else {SS2out<<"_ ";}
      for (f=1;f<=Nfleet;f++)
      {
        if(SzFreq_LikeComponent(f,j)>0) {SS2out<<SzFreq_lambda(SzFreq_LikeComponent(f,j),k)<<" ";}
        else {SS2out<<" NA ";}
      }
      SS2out<<endl;
      SS2out<<"SizeFreq_like:_"<<j<<"; ";
    if(j==1) {SS2out<<SzFreq_like*column(SzFreq_lambda,k)<<" ";} else {SS2out<<"_ ";}
      for (f=1;f<=Nfleet;f++)
      {
        if(SzFreq_LikeComponent(f,j)>0) {SS2out<<SzFreq_like(SzFreq_LikeComponent(f,j))<<" ";}
        else {SS2out<<" NA ";}
      }
      SS2out<<endl;
    }
    SS2out<<SzFreq_like<<endl<<SzFreq_like_base<<endl;
  }

  if(Do_TG>0)
  {
    SS2out<<endl<<"_"<<endl<<"Tag_Group:  ALL ";
    for (f=1;f<=N_TG;f++) SS2out<<f<<" ";
    SS2out<<endl;
    SS2out<<"Tag_comp_Lambda _ "<<column(TG_lambda1,k)<<endl<<
    "Tag_comp_Like "<<TG_like1*column(TG_lambda1,k)<<" "<<TG_like1<<endl;
    SS2out<<"Tag_negbin_Lambda _ "<<column(TG_lambda2,k)<<endl<<
    "Tag_negbin_Like "<<TG_like2*column(TG_lambda2,k)<<" "<<TG_like2<<endl;
  }
  SS2out<<endl;

  SS2out<<"Input_Variance_Adjustment"<<endl<<"Fleet ";
  for (i=1;i<=Nfleet;i++) {SS2out<<" "<<i;}
  SS2out<<endl;
  SS2out << "Index_extra_CV "<<var_adjust(1)<<endl;
  SS2out << "Discard_extra_CV "<<var_adjust(2)<<endl;
  SS2out << "MeanBodyWt_extra_CV "<<var_adjust(3)<<endl;
  SS2out << "effN_mult_Lencomp "<<var_adjust(4)<<endl;
  SS2out << "effN_mult_Agecomp "<<var_adjust(5)<<endl;
  SS2out << "effN_mult_Len_at_age "<<var_adjust(6)<<endl;
  SS2out << "effN_mult_generalized_sizecomp "<<var_adjust(7)<<endl;

  SS2out<<"MG_parms_Using_offset_approach_#:_"<<MGparm_def<<"  (1=none, 2= M, G, CV_G as offset from female_GP1, 3=like SS2 V1.x)"<<endl;

//  SS2out<<endl<<"PARAMETERS"<<endl<<"Num Label Value Active_Cnt Phase Min Max Init Prior PR_type Pr_SD Prior_Like Parm_StDev Status Pr_atMin Pr_atMax"<<endl;
  SS2out<<endl<<"PARAMETERS"<<endl<<"Num Label Value Active_Cnt  Phase Min Max Init  Used  Status  Parm_StDev Gradient Pr_type Prior Pr_SD Pr_Like Value_again Value-1.96*SD Value+1.96*SD V_1%  V_10% V_20% V_30% V_40% V_50% V_60% V_70% V_80% V_90% V_99% P_val P_lowCI P_hiCI  P_1%  P_10% P_20% P_30% P_40% P_50% P_60% P_70% P_80% P_90% P_99%"<<endl;

  NP=0;   // count of number of parameters
  active_count=0;
  Nparm_on_bound=0;
  int Activ;
  for (j=1;j<=N_MGparm2;j++)
  {
    NP++;
    Activ=0;
    if(active(MGparm(j)))
    {
      active_count++;
      Activ=1;
    }
    Report_Parm(NP, active_count, Activ, MGparm(j), MGparm_LO(j), MGparm_HI(j), MGparm_RD(j), MGparm_use(j), MGparm_PR(j), MGparm_CV(j), MGparm_PRtype(j), MGparm_PH(j), MGparm_Like(j));
  }


  for (j=1;j<=N_SRparm3;j++)
  {
    NP++;
    Activ=0;
    if(active(SR_parm(j)))
    {
      active_count++;
      Activ=1;
    }
    Report_Parm(NP, active_count, Activ, SR_parm(j), SR_parm_LO(j), SR_parm_HI(j), SR_parm_RD(j), SR_parm_use(j), SR_parm_PR(j), SR_parm_CV(j), SR_parm_PRtype(j), SR_parm_PH(j), SR_parm_Like(j));
  }

  if(recdev_cycle>0)
  {
    for (j=1;j<=recdev_cycle;j++)
    {
      NP++;
      Activ=0;
      if(active(recdev_cycle_parm(j)))
      {
        active_count++;
        Activ=1;
      }
      Report_Parm(NP, active_count, Activ, recdev_cycle_parm(j), recdev_cycle_parm_RD(j,1), recdev_cycle_parm_RD(j,2), recdev_cycle_parm_RD(j,3), recdev_cycle_use(j), recdev_cycle_parm_RD(j,4), recdev_cycle_parm_RD(j,5), recdev_cycle_parm_RD(j,6), recdev_cycle_parm_RD(j,7), recdev_cycle_Like(j));
    }
  }

    if(recdev_do_early>0)
      {
        for (i=recdev_early_start;i<=recdev_early_end;i++)
        {NP++;  SS2out<<NP<<" "<<ParmLabel(NP)<<" "<<recdev(i);
        if( active(recdev_early) )
        {
          active_count++;
          SS2out<<" "<<active_count<<" "<<recdev_early_PH<<" "<<recdev_LO<<" "<<recdev_HI<<" "<<recdev_RD(i)<<" "<<recdev_use(i)<<" act "<<CoVar(active_count,1)<<" "<<parm_gradients(active_count);
        }
        else
          {
            SS2out<<" _ _ _ _ _ _ NA _ _ ";
          }
        SS2out <<" dev "<<endl;
          }
      }

    if(do_recdev>0)
      {
        for (i=recdev_start;i<=recdev_end;i++)
        {NP++;  SS2out<<NP<<" "<<ParmLabel(NP)<<" "<<recdev(i);
        if( active(recdev1)||active(recdev2) )
        {
          active_count++;
          SS2out<<" "<<active_count<<" "<<recdev_PH<<" "<<recdev_LO<<" "<<recdev_HI<<" "<<recdev_RD(i)<<" "<<recdev_use(i)<<" act "<<CoVar(active_count,1)<<" "<<parm_gradients(active_count);
        }
        else
          {
            SS2out<<" _ _ _ _ _ _ NA _ _ ";
          }
        SS2out <<" dev "<<endl;
          }
      }

    if(Do_Forecast>0)
    {
      for (i=recdev_end+1;i<=YrMax;i++)
      {
        NP++; SS2out<<NP<<" "<<ParmLabel(NP)<<" "<<Fcast_recruitments(i);
        if(active(Fcast_recruitments))
        {active_count++;
          SS2out<<" "<<active_count<<" "<<Fcast_recr_PH2<<" "<<recdev_LO<<" "<<recdev_HI<<" "<<recdev_RD(i)<<" "<<recdev_use(i)<<" act "<<CoVar(active_count,1)<<" "<<parm_gradients(active_count);
        }
        else
        {SS2out<<"  _ _ _ _ _ _ NA _ _ ";}
        SS2out <<" dev "<<endl;
      }
    }

      if(Do_Forecast>0)
      {
        for (i=endyr+1;i<=YrMax;i++)
        {
          NP++; SS2out<<NP<<" "<<ParmLabel(NP)<<" "<<Fcast_impl_error(i);
          if(active(Fcast_impl_error))
          {active_count++; SS2out<<" "<<active_count<<" "<<Fcast_recr_PH2<<" -1 1 _ _ act "<<CoVar(active_count,1)<<" "<<parm_gradients(active_count);}
          else
          {SS2out<<"  _ _ _ _ _ _ NA _ _ ";}
        SS2out <<" dev "<<endl;
        }
      }

  for (j=1;j<=N_init_F;j++)
  {
    NP++;
    Activ=0;
    if(active(init_F(j)))
    {
      active_count++;
      Activ=1;
    }
    Report_Parm(NP, active_count, Activ, init_F(j), init_F_LO(j), init_F_HI(j), init_F_RD(j), init_F_use(j), init_F_PR(j), init_F_CV(j),  init_F_PRtype(j),init_F_PH(j), init_F_Like(j));
  }

    if(F_Method==2)
    {
      for (i=1;i<=N_Fparm;i++)
      {
        NP++;  SS2out<<NP<<" "<<ParmLabel(NP)<<" "<<F_rate(i);
        if(active(F_rate(i)))
        {
          active_count++;
          SS2out<<" "<<active_count<<" "<<Fparm_PH(i)<<" 0.0  8.0  _ "<<Fparm_use(i)<<" act "<<CoVar(active_count,1);
        }
        else
        {SS2out<<" _ _ _ _ _ _ NA _ _ ";}
        SS2out <<" F "<<endl;
      }
    }

  for (j=1;j<=Q_Npar2;j++)
  {
    NP++;
    Activ=0;
    if(active(Q_parm(j)))
    {
      active_count++;
      Activ=1;
    }
    Report_Parm(NP, active_count, Activ, Q_parm(j), Q_parm_LO(j), Q_parm_HI(j), Q_parm_RD(j), Q_parm_use(j), Q_parm_PR(j), Q_parm_CV(j),  Q_parm_PRtype(j), Q_parm_PH(j), Q_parm_Like(j));
  }

  for (j=1;j<=N_selparm2;j++)
  {
    NP++;
    Activ=0;
    if(active(selparm(j)))
    {
      active_count++;
      Activ=1;
    }
    Report_Parm(NP, active_count, Activ, selparm(j), selparm_LO(j), selparm_HI(j), selparm_RD(j), selparm_use(j), selparm_PR(j), selparm_CV(j), selparm_PRtype(j), selparm_PH(j), selparm_Like(j));
  }


  if(Do_TG>0)
  {
     k=3*N_TG+2*Nfleet1;
    for (j=1;j<=k;j++)
    {
      NP++;
      Activ=0;
      if(active(TG_parm(j)))
      {
        active_count++;
        Activ=1;
      }
      Report_Parm(NP, active_count, Activ, TG_parm(j), TG_parm_LO(j), TG_parm_HI(j), TG_parm2(j,3), TG_parm_use(j), TG_parm2(j,4), TG_parm2(j,5), TG_parm2(j,6), TG_parm_PH(j), TG_parm_Like(j));
    }
  }

  if(N_parm_dev>0)
  {
    for (i=1;i<=N_parm_dev;i++)
    for (j=parm_dev_minyr(i);j<=parm_dev_maxyr(i);j++)
    {
      NP++;  SS2out<<NP<<" "<<ParmLabel(NP)<<" "<<parm_dev(i,j);
      if(parm_dev_PH(i)>0)
      {
        active_count++;
        SS2out<<" "<<active_count<<" "<<parm_dev_PH(i)<<" -10 10 "<<parm_dev_RD(i,j)<<" "<<parm_dev_use(i,j)<<" act "<<CoVar(active_count,1)<<" "<<parm_gradients(active_count);
      }
      else
      {SS2out<<" _ _ _ _ _ _ NA _ _ ";}
      SS2out<<" dev "<<endl;
    }
  }

  SS2out<<endl<<"Number_of_active_parameters_on_or_near_bounds: "<<Nparm_on_bound<<endl;
  SS2out<<"Active_count "<<active_count<<endl<<endl;

  SS2out<<endl<<"DERIVED_QUANTITIES"<<endl;
  SS2out<<"SPR_report_basis: "<<SPR_report_label<<endl;
  SS2out<<"F_report_basis: "<<F_report_label<<endl;
  SS2out<<"B_ratio_denominator: "<<depletion_basis_label<<endl;

  SS2out<<" Label Value  StdDev (Val-1.0)/Stddev  CumNorm"<<endl;
  for (j=1;j<=N_STD_Yr;j++)
  {
    NP++;  SS2out<<" "<<ParmLabel(NP)<<" "<<SPB_std(j);
    active_count++;
    SS2out<<" "<<CoVar(active_count,1)<<endl;
  }
  for (j=1;j<=N_STD_Yr;j++)
  {
    NP++;  SS2out<<" "<<ParmLabel(NP)<<" "<<recr_std(j);
    active_count++;
    SS2out<<" "<<CoVar(active_count,1)<<endl;
  }
  for (j=1;j<=N_STD_Yr_Ofish;j++)
  {
    NP++;  SS2out<<" "<<ParmLabel(NP)<<" "<<SPR_std(j);
    active_count++;
    SS2out<<" "<<CoVar(active_count,1);
    if( CoVar(active_count,1)>0.0)
    {
      temp=value((SPR_std(j)-1.0)/CoVar(active_count,1));
      SS2out<<" "<<temp<<" "<<cumd_norm(temp);

    }
    SS2out<<endl;
  }
  ofstream post_vecs("posterior_vectors.sso",ios::app);
  post_vecs<<runnumber<<" 0 "<<obj_fun<<" F/Fmsy_stdev ";
  for (j=1;j<=N_STD_Yr_F;j++)
  {
    NP++;  SS2out<<" "<<ParmLabel(NP)<<" "<<F_std(j);
    active_count++;
    SS2out<<" "<<CoVar(active_count,1);
    post_vecs<<CoVar(active_count,1)<<" ";
    if( CoVar(active_count,1)>0.0)
    {
      temp=value((F_std(j)-1.0)/CoVar(active_count,1));
      SS2out<<" "<<temp<<" "<<cumd_norm(temp);
    }
    SS2out<<endl;
  }
  post_vecs<<endl;
  post_vecs<<runnumber<<" 0 "<<obj_fun<<" B/Bmsy_stdev ";

  for (j=1;j<=N_STD_Yr_Dep;j++)
  {
    NP++;  SS2out<<" "<<ParmLabel(NP)<<" "<<depletion(j);
    active_count++;
    SS2out<<" "<<CoVar(active_count,1);
    post_vecs<<CoVar(active_count,1)<<" ";
    if( CoVar(active_count,1)>0.0)
    {
      temp=value((depletion(j)-1.0)/CoVar(active_count,1));
      SS2out<<" "<<temp<<" "<<cumd_norm(temp);
    }
    SS2out<<endl;
  }
  post_vecs<<endl;
  for (j=1;j<=N_STD_Mgmt_Quant;j++)
  {
    NP++; active_count++;
    SS2out<<" "<<ParmLabel(NP)<<" "<<Mgmt_quant(j);

    SS2out<<" "<<CoVar(active_count,1)<<endl;
  }

  for (j=1;j<=Extra_Std_N;j++)
  {
    NP++;      active_count++;
    SS2out<<" "<<ParmLabel(NP)<<" "<<Extra_Std(j);
    SS2out<<" "<<CoVar(active_count,1)<<endl;
  }

   if(reportdetail == 1) {k1=YrMax;} else {k1=styr;}
   SS2out<<endl<<"MGparm_By_Year_after_adjustments"<<endl<<"Yr   Change? ";
   for (i=1;i<=N_MGparm;i++) SS2out<<" "<<ParmLabel(i);
   SS2out<<endl;
   for (y=styr;y<=k1;y++)
     SS2out<<y<<" "<<timevary_MG(y,0)<<" "<<mgp_save(y)<<endl;
   SS2out<<endl;

   if(Fcast_Specify_Selex==0)
    {SS2out<<"forecast_selectivity_averaged_over_years:_"<<Fcast_Sel_yr1<<"_to_"<<Fcast_Sel_yr2<<endl;}
    else
    {SS2out<<"forecast_selectivity_from_time-varying_parameters "<<endl;}
      
   SS2out<<endl<<"selparm(Size)_By_Year_after_adjustments"<<endl<<"Fleet Yr  Change?  Parameters"<<endl;
   for (f=1;f<=Nfleet;f++)
   for (y=styr;y<=k1;y++)
     {
     k=N_selparmvec(f);
     if(k>0) SS2out<<f<<" "<<y<<" "<<timevary_sel(y,f)<<" "<<save_sp_len(y,f)(1,k)<<endl;
     }

   SS2out<<endl<<"selparm(Age)_By_Year_after_adjustments"<<endl<<"Fleet Yr  Change?  Parameters"<<endl;
   for (f=Nfleet+1;f<=2*Nfleet;f++)
   for (y=styr;y<=k1;y++)
     {
     k=N_selparmvec(f);
     if(k>0) SS2out<<f-Nfleet<<" "<<y<<" "<<timevary_sel(y,f)<<" "<<save_sp_len(y,f)(1,k)<<endl;
     }

   SS2out<<endl<<"RECRUITMENT_DIST"<<endl<<"Settle# settle_timing# G_pattern Area Settle_Month Seas Age Time_w/in_seas Frac/sex"<<endl;
   for (settle=1;settle<=N_settle_assignments;settle++)
   {
      gp=settlement_pattern_rd(settle,1); //  growth patterns
      p=settlement_pattern_rd(settle,3);  //  settlement area
      settle_time=settle_assignments_timing(settle);
      SS2out<<settle<<" "<<settle_time<<" "<<gp<<" "<<p<<" "<<Settle_month(settle_time)<<" "<<Settle_seas(settle_time)<<" "<<
      Settle_age(settle_time)<<" "<<Settle_timing_seas(settle_time)<<" "<<recr_dist(gp,settle_time,p)<<endl;
   }
   SS2out<<endl<<"RECRUITMENT_DIST_Bmark"<<endl<<"Settle# settle_timing# G_pattern Area Settle_Month Seas Age Time_w/in_seas Frac/sex"<<endl;
   for (settle=1;settle<=N_settle_assignments;settle++)
   {
      gp=settlement_pattern_rd(settle,1); //  growth patterns
      p=settlement_pattern_rd(settle,3);  //  settlement area
      settle_time=settle_assignments_timing(settle);
      SS2out<<settle<<" "<<settle_time<<" "<<gp<<" "<<p<<" "<<Settle_month(settle_time)<<" "<<Settle_seas(settle_time)<<" "<<
      Settle_age(settle_time)<<" "<<Settle_timing_seas(settle_time)<<" "<<recr_dist_Bmark(gp,settle_time,p)/(Bmark_Yr(8)-Bmark_Yr(7)+1)<<endl;
   }
   SS2out<<endl<<"RECRUITMENT_DIST_endyr"<<endl<<"Settle# settle_timing# G_pattern Area Settle_Month Seas Age Time_w/in_seas Frac/sex"<<endl;
   for (settle=1;settle<=N_settle_assignments;settle++)
   {
      gp=settlement_pattern_rd(settle,1); //  growth patterns
      p=settlement_pattern_rd(settle,3);  //  settlement area
      settle_time=settle_assignments_timing(settle);
      SS2out<<settle<<" "<<settle_time<<" "<<gp<<" "<<p<<" "<<Settle_month(settle_time)<<" "<<Settle_seas(settle_time)<<" "<<
      Settle_age(settle_time)<<" "<<Settle_timing_seas(settle_time)<<" "<<recr_dist_endyr(gp,settle_time,p)<<endl;
   }

   SS2out<<endl<<"MORPH_INDEXING"<<endl;
   SS2out<<"Index GP Sex BirthSeason Platoon Platoon_Dist Sex*GP Sex*GP*Settle BirthAge_Rel_Jan1"<<endl;
   for (g=1; g<=gmorph; g++)
   {
     SS2out<<g<<" "<<GP4(g)<<" "<<sx(g)<<" "<<Bseas(g)<<" "<<GP2(g)<<" "<<platoon_distr(GP2(g))<<" "<<GP(g)<<" "<<GP3(g)<<" "<<azero_G(g)<<endl;
   }

//  3darray SzFreqTrans(1,SzFreq_Nmeth*nseas,1,nlength2,1,SzFreq_Nbins_seas_g);
   if(SzFreq_Nmeth>0)
   {
     SS2out<<endl<<"SIZEFREQ_TRANSLATION "<<SzFreq_scale<<endl;
     for (SzFreqMethod=1;SzFreqMethod<=SzFreq_Nmeth;SzFreqMethod++)
     {
       SS2out<<SzFreqMethod<<" seas len mid-len ";
           if(SzFreq_scale(SzFreqMethod)==1)
           {SS2out<<" mid-kg ";}
           else if(SzFreq_scale(SzFreqMethod)==2)
           {SS2out<<" mid-lbs ";}
           else if(SzFreq_scale(SzFreqMethod)==3)
           {SS2out<<" mid-cm ";}
           else
           {SS2out<<" mid-inch ";}
       SS2out<<SzFreq_bins1(SzFreqMethod);
       if(gender==2) SS2out<<SzFreq_bins1(SzFreqMethod);
       SS2out<<endl<<SzFreqMethod<<" gp seas len mid-len metric "<<SzFreq_bins(SzFreqMethod)<<endl;;
       for (gp=1;gp<=N_GP;gp++)
       for (s=1;s<=nseas;s++)
       {
         SzFreqMethod_seas=nseas*(SzFreqMethod-1)+s;     // index that combines sizefreqmethod and season and used in SzFreqTrans
         for (z=1;z<=nlength2;z++)
         {
           SS2out<<SzFreqMethod<<" "<<gp<<" "<<s<<" "<<len_bins2(z)<<" "<<len_bins_m2(z)<<" ";
           if(SzFreq_scale(SzFreqMethod)==1)
           {SS2out<<wt_len2(s,gp,z)<<" ";}
           else if(SzFreq_scale(SzFreqMethod)==2)
           {SS2out<<wt_len2(s,gp,z)/0.4536<<" ";}
           else if(SzFreq_scale(SzFreqMethod)==3)
           {SS2out<<len_bins_m2(z)<<" ";}
           else
           {SS2out<<len_bins_m2(z)/2.54<<" ";}
           for (j=1;j<=gender*SzFreq_Nbins(SzFreqMethod);j++)
           {
             SS2out<<SzFreqTrans(SzFreqMethod_seas,z,j)<<" ";
             if(SzFreqTrans(SzFreqMethod_seas,z,j)<0.0)
             {N_warn++; warning<<" CRITICAL ERROR:  Bin widths narrower than pop len bins caused negative allocation in sizefreq method:"<<
            " method, season, size, bin: "<<SzFreqMethod<<" "<<s<<" "<<len_bins2(z)<<" "<<j<<endl; exit(1);}
           }
           SS2out<<endl;
         }
       }
     }
   }

   SS2out<<"#"<<endl<<"MOVEMENT in endyear"<<endl<<" Seas GP Source_area Dest_area minage maxage "<<age_vector<<endl;
   for (k=1;k<=do_migr2;k++)
   {
     SS2out<<move_def2(k)<<" "<<migrrate(endyr,k)<<endl;
   }

   SS2out<<endl<<"EXPLOITATION"<<endl<<"F_Method: "<<F_Method;
   if(F_Method==1) {SS2out<<"  Pope's_approx ";} else {SS2out<<"  Continuous_F;_(NOTE:_F_report_adjusts_for_seasdur_but_each_fleet_F_is_annual)";}
   SS2out<<endl<<"F_report_units: "<<F_reporting<<F_report_label<<endl<<"_ _ _ ";
   for (f=1;f<=Nfleet;f++)
   if(fleet_type(f)<=2)
   {if(catchunits(f)==1) {SS2out<<" Bio ";} else {SS2out<<" Num ";}}
   SS2out<<endl<<"_ _ _ ";
   for (f=1;f<=Nfleet;f++)
   if(fleet_type(f)<=2)
   {SS2out<<" "<<f;}
   SS2out<<endl<<"Yr Seas F_report";
   for (f=1;f<=Nfleet;f++)
   if(fleet_type(f)<=2)
   {SS2out<<" "<<fleetname(f);}
   SS2out<<endl;
   if(N_init_F>0)
   {
     for (s=1;s<=nseas;s++)
     {
       SS2out<<"init_yr "<<s<<" _ ";
       for (f=1;f<=Nfleet;f++)
       if(fleet_type(f)<=2)
       {
         if(init_F_loc(s,f)>0)
           {SS2out<<" "<<init_F(init_F_loc(s,f));}
          else
          {SS2out<<" _ ";}
       }
       SS2out<<endl;
     }
   }

   for (y=styr;y<=YrMax;y++)
   for (s=1;s<=nseas;s++)
   {
     t=styr+(y-styr)*nseas+s-1;
     SS2out<<y<<" "<<s<<" ";
     if(s==1 && y>=styr && STD_Yr_Reverse_F(y)>0 ) {SS2out<<F_std(STD_Yr_Reverse_F(y));} else {SS2out<<" _ ";}
     SS2out<<" ";
     for(f=1;f<=Nfleet;f++)
     if(fleet_type(f)<=2)
      {SS2out<<" "<<Hrate(f,t);}
     SS2out<<endl;
   }

  SS2out<<endl<<"CATCH "<<endl<<"Fleet Name Yr Seas Yr.frac Obs Exp Mult Exp*Mult se F  Like sel_bio kill_bio ret_bio sel_num kill_num ret_num"<<endl;
  for (f=1;f<=Nfleet;f++)
  {
    if(fleet_type(f)<=2)
    {
      for (y=styr-1;y<=endyr;y++)
      for (s=1;s<=nseas;s++)
      {
        t = styr+(y-styr)*nseas+s-1;
        if(catchunits(f)==1)
        {gg=3;}  //  biomass
        else
        {gg=6;}  //  numbers
        temp = float(y)+0.01*int(100.*(azero_seas(s)+seasdur_half(s)));
        SS2out<<f<<" "<<fleetname(f)<<" ";
        if(y<styr) {SS2out<<"init ";} else {SS2out<<y<<" ";}
        SS2out<<s<<" "<<temp<<" "<<catch_ret_obs(f,t)<<" "<<catch_fleet(t,f,gg)<<" "<<catch_mult(y,f)<<" "<<catch_mult(y,f)*catch_fleet(t,f,gg);
        SS2out<<" "<<catch_se(t,f)<<" "<<Hrate(f,t)<<" ";
        if(fleet_type(f)==1)
          {
            if(catch_ret_obs(f,t)>0)
              {
                SS2out<<0.5*square( (log(1.1*catch_ret_obs(f,t)) -log(catch_fleet(t,f,gg)*catch_mult(y,f)+0.1*catch_ret_obs(f,t))) / catch_se(t,f));
              }
              else
                {
                  SS2out<<" NA";
                }
          }
          else
          {SS2out<<"BYCATCH";}
          SS2out<<catch_fleet(t,f)<<endl;
      }
    }
  }

   int bio_t;

   SS2out<<endl<<"TIME_SERIES    BioSmry_age:_"<<Smry_Age;   // SS_Label_320
   if(F_Method==1) {SS2out<<"  Pope's_approx"<<endl;} else {SS2out<<"  Continuous_F"<<endl;}
  SS2out<<"Area Yr Era Seas Bio_all Bio_smry SpawnBio Recruit_0 ";
  for (gp=1;gp<=N_GP;gp++) SS2out<<" SpawnBio_GP:"<<gp;
  if(Hermaphro_Option!=0)
  {
    for (gp=1;gp<=N_GP;gp++) SS2out<<" MaleSpawnBio_GP:"<<gp;
  }
  for (gg=1;gg<=gender;gg++)
  for (gp=1;gp<=N_GP;gp++)
  {SS2out<<" SmryBio_SX:"<<gg<<"_GP:"<<gp;}
  for (gg=1;gg<=gender;gg++)
  for (gp=1;gp<=N_GP;gp++)
  {SS2out<<" SmryNum_SX:"<<gg<<"_GP:"<<gp;}
  dvector Bio_Comp(1,N_GP*gender);
  dvector Num_Comp(1,N_GP*gender);
  for (f=1;f<=Nfleet;f++)
  if(fleet_type(f)<=2)
  {
    SS2out<<" sel(B):_"<<f<<" dead(B):_"<<f<<" retain(B):_"<<f<<
    " sel(N):_"<<f<<" dead(N):_"<<f<<" retain(N):_"<<f<<
    " obs_cat:_"<<f;
     if(F_Method==1) {SS2out<<" Hrate:_"<<f;} else {SS2out<<" F:_"<<f;}
  }

  SS2out<<" SSB_vir_LH ABC_buffer"<<endl;

  for (p=1;p<=pop;p++)
  {
   for (y=styr-2;y<=YrMax;y++)
   {
    if(y<=endyr && p==1) {Smry_Table(y)(1,8).initialize();  Smry_Table(y)(15,17).initialize();}
    for (s=1;s<=nseas;s++)
    {
    t = styr+(y-styr)*nseas+s-1;
    bio_t=t;
    if(y<=styr) {bio_t=styr-1+s;}
    Bio_Comp.initialize();
    Num_Comp.initialize();
    totbio.initialize(); smrybio.initialize(); smrynum.initialize(); SPB_vir_LH.initialize(); smryage.initialize();
//    Recr(p,y)=0;
    for (g=1;g<=gmorph;g++)
    if(use_morph(g)>0)
    {
//     if(s==Bseas(g)) Recr(p,y)+=natage(t,p,g,0);
     gg=sx(g);
     temp=natage(t,p,g)(Smry_Age,nages)*Save_Wt_Age(bio_t,g)(Smry_Age,nages);
     Bio_Comp(GP(g))+=value(temp);   //sums to accumulate across platoons and settlements
     Num_Comp(GP(g))+=value(sum(natage(t,p,g)(Smry_Age,nages)));   //sums to accumulate across platoons and settlements
     totbio+= natage(t,p,g)*Save_Wt_Age(bio_t,g);
     smrybio+= temp;
     smrynum+=sum(natage(t,p,g)(Smry_Age,nages));
     smryage+=natage(t,p,g)(Smry_Age,nages)*r_ages(Smry_Age,nages);
     SPB_vir_LH += natage(t,p,g)*virg_fec(g);
     if(y<=endyr)
     {
       for (f=1;f<=Nfleet;f++)
       {
         if(fleet_area(f)==p&&y>=styr-1&&fleet_type(f)<=2)
         {
           Smry_Table(y,16)+=sum(catage(t,f,g));
           Smry_Table(y,17)+=catage(t,f,g)*r_ages;
         }
       }
     }


    } //close gmorph loop
    SS2out<<p<<" "<<y;
       if(y==styr-2)
         {SS2out<<" VIRG ";}
       else if (y==styr-1)
         {SS2out<<" INIT ";}
       else if (y<=endyr)
         {SS2out<<" TIME ";}
       else
         {SS2out<<" FORE ";}

    SS2out<<s<<" "<<totbio<<" "<<smrybio<<" ";
    if(s==spawn_seas)
    {
      temp=sum(SPB_pop_gp(y,p));
      if(Hermaphro_maleSPB==1) temp+=sum(MaleSPB(y,p));
      SS2out<<temp;
    }
    else
    {SS2out<<" _ ";}
    SS2out<<" "<<Recr(p,t)<<" ";
    if(s==spawn_seas)
    {
      SS2out<<SPB_pop_gp(y,p);
      if(Hermaphro_Option!=0) SS2out<<MaleSPB(y,p);
    }
    else
    {
    for (gp=1;gp<=N_GP;gp++) {SS2out<<" _ ";}

    }
    SS2out<<" "<<Bio_Comp<<" "<<Num_Comp;
    if(s==1 && y<=endyr) {Smry_Table(y,1)+=totbio; Smry_Table(y,2)+=smrybio;  Smry_Table(y,3)+=smrynum; Smry_Table(y,15)+=smryage;}  // already calculated for the forecast years
    Smry_Table(y,7)=SPB_yr(y);
    Smry_Table(y,8)=exp_rec(y,4);
    for (f=1;f<=Nfleet;f++)
    if(fleet_type(f)<=2)
    {
      if(fleet_area(f)==p&&y>=styr-1)
      {
        SS2out<<" "<<catch_fleet(t,f)<<" ";
        if(y<=endyr) {SS2out<<catch_ret_obs(f,t)<<" "<<Hrate(f,t);} else {SS2out<<" _ "<<Hrate(f,t);}
        if(y<=endyr) {Smry_Table(y,4)+=catch_fleet(t,f,1); Smry_Table(y,5)+=catch_fleet(t,f,2); Smry_Table(y,6)+=catch_fleet(t,f,3);}

      }
      else
      {SS2out<<" 0 0 0 0 0 0 0 0 ";}
    }
    if(s==spawn_seas)
        {SS2out<<" "<<SPB_vir_LH;}
    else
      {SS2out<<" _";}
    if(y<=endyr)
      {SS2out<<" NA";}
      else
      {SS2out<<" "<<ABC_buffer(y);}
    SS2out<<endl;
    }
   }
  }

    // start SPR time series                                  SS_Label_0322
   SS2out<<endl<<"SPR_series_uses_R0= "<<Recr_virgin<<endl<<"###note_YPR_unit_is_Dead_Biomass"<<endl;
   SS2out<<"Depletion_basis: "<<depletion_basis<<" # "<<depletion_basis_label<<endl;
   SS2out<<"F_report_basis: "<<F_reporting<<" # "<<F_report_label<<endl;
   SS2out<<"SPR_report_basis: "<<SPR_reporting<<" # "<<SPR_report_label<<endl;
   // note  GENTIME is mean age of spawners weighted by fec(a)
   SS2out<<"Yr Bio_all Bio_Smry SSBzero SSBfished SSBfished/R SPR SPR_report YPR GenTime Deplete F_report"<<
   " Actual: Bio_all Bio_Smry Num_Smry MnAge_Smry Enc_Catch Dead_Catch Retain_Catch MnAge_Catch SSB Recruits Tot_Exploit"<<
   " More_F(by_Morph): ";
   for (g=1;g<=gmorph;g++) {SS2out<<" aveF_"<<g;}
   for (g=1;g<=gmorph;g++) {SS2out<<" maxF_"<<g;}
   SS2out<<" Enc_Catch_B Dead_Catch_B Retain_Catch_B  Enc_Catch_N Dead_Catch_N Retain_Catch_N sum_Apical_F F=Z-M";
   SS2out<<endl;

   for (y=styr;y<=YrMax;y++)
   {
     SS2out<<y<<" "<<Smry_Table(y)(9,12)<<" "<<(Smry_Table(y,12)/Recr_virgin)<<" "<<Smry_Table(y,12)/Smry_Table(y,11)<<" ";
     if(STD_Yr_Reverse_Ofish(y)>0) {SS2out<<SPR_std(STD_Yr_Reverse_Ofish(y))<<" ";} else {SS2out<<" _ ";}
     SS2out<<(Smry_Table(y,14)/Recr_virgin)<<" "<<Smry_Table(y,13)<<" ";
     if(STD_Yr_Reverse_Dep(y)>0) {SS2out<<depletion(STD_Yr_Reverse_Dep(y));} else {SS2out<<" _ ";}
     if(y>=styr && STD_Yr_Reverse_F(y)>0 ) {SS2out<<" "<<F_std(STD_Yr_Reverse_F(y));} else {SS2out<<" _ ";}
     SS2out<<" & "<<Smry_Table(y)(1,3)<<" "<<Smry_Table(y,15)/Smry_Table(y,3)<<" "<<Smry_Table(y)(4,6)<<" "<<Smry_Table(y,17)/(Smry_Table(y,16)+1.0e-06)<<" "<<Smry_Table(y)(7,8)<<" "<<Smry_Table(y,5)/Smry_Table(y,2);
     SS2out<<" & "<<Smry_Table(y)(21,20+gmorph)<<" "<<Smry_Table(y)(21+gmorph,20+2*gmorph)<<" "<<annual_catch(y)<<" "<<annual_F(y)<<endl;
   } // end year loop

  SIS_table<<"to_come_#"  <<" Best_F"<<endl;
  SIS_table<<"to_come_#"  <<"  F_units"<<endl;
  SIS_table<<endyr<<" F_year"<<endl;
  SIS_table<<"to_come_#"  <<" F_basis"<<endl;
  SIS_table<<"to_come_#"  <<" F_limit"<<endl;
  SIS_table<<"to_come_#"  <<"  F_limit_basis"<<endl;
  SIS_table<<"to_come_#"  <<" F_msy"<<endl;
  SIS_table<<"to_come_#"  <<" F_msy_basis"<<endl;
  SIS_table<<"to_come_#"  <<" F_target"<<endl;
  SIS_table<<"to_come_#"  <<" F_target_basis"<<endl;
  SIS_table<<"to_come_#"  <<" F/F_limit"<<endl;
  SIS_table<<"to_come_#"  <<" F/F_msy"<<endl;
  SIS_table<<"to_come_#"  <<" F/F_target"<<endl;
  SIS_table<<"to_come_#"  <<" Best_Bio"<<endl;
  SIS_table<<"to_come_#"  <<" Bio_units"<<endl;
  SIS_table<<endyr<<" Bio_year"<<endl;
  SIS_table<<"to_come_#"  <<" Bio_basis"<<endl;
  SIS_table<<"to_come_#"  <<" Bio_limit"<<endl;
  SIS_table<<"to_come_#"  <<" Bio_limit_basis"<<endl;
  SIS_table<<"to_come_#"  <<" Bio_MSY"<<endl;
  SIS_table<<"to_come_#"  <<" Bio_MSY_basis"<<endl;
  SIS_table<<"to_come_#"  <<" Bio_MSY"<<endl;
  SIS_table<<"to_come_#"  <<" Bio_above_below"<<endl;
  SIS_table<<"to_come_#"  <<" Bio/Bio_limit"<<endl;
  SIS_table<<"to_come_#"  <<" Bio/Bio_MSY"<<endl<<endl;

 /*
  SIS_table<<"Category Year Abundance Abundance Recruitment Spawners Fmort Fmort Catch Catch"<<endl;
  SIS_table<<"Primary _ N Y Y Y Y Y N N"<<endl;
  SIS_table<<"Type _ Biomass Biomass Age Female_Mature Exploitation ";
  SIS_table<<SPR_report_label<<" Catch Catch"<<endl;
  SIS_table<<"Source _ Model Model Model Model Model Model Model Model"<<endl;
  SIS_table<<"Basis _ Biomass Biomass Numbers Eggs Rate Rate Biomass Biomass"<<endl;
  SIS_table<<"Range _ All Age_"<<Smry_Age<<"+ Age_0 Mature Rate Rate All Retained"<<endl;
  SIS_table<<"Statistic _ Mean Mean Mean Mean Mean Mean Mean Mean"<<endl;
  SIS_table<<"Scalar _ 1 1 1000 1 1 1 1 1"<<endl;

   for (y=styr;y<=YrMax;y++)
   {
     SIS_table<<"_ "<<y<<" "<<Smry_Table(y,1)<<" "<<Smry_Table(y,2)<<" "<<Smry_Table(y,8)<<" "<<Smry_Table(y,7)<<" "<<Smry_Table(y,5)/Smry_Table(y,2)<<" ";
     if(STD_Yr_Reverse_Ofish(y)>0) {SIS_table<<SPR_std(STD_Yr_Reverse_Ofish(y))<<" ";} else {SIS_table<<" _ ";}
     SIS_table<<Smry_Table(y,5)<<" "<<Smry_Table(y,6)<<endl;
   } // end year loop
 */

  SIS_table<<"Category Year Abundance Abundance Recruitment Spawners Catch Catch Catch Catch Catch Catch Fmort Fmort Fmort Fmort Fmort"<<endl;
  SIS_table<<"Primary _ N Y Y Y N Y N N N N N N N Y Y"<<endl;
  SIS_table<<"Type _ Biomass Biomass Age Female_Mature Sel_Bio Kill_Bio Retain_Bio Sel_Numbers Kill_Numbers Retain_Numbers Exploitation SPR_report F_report Sum_Fleet_Apical_Fs F=Z-M"<<endl;
  SIS_table<<"Source _ Model Model Model Model Model Model Model Model Model Model Model Model Model Model Model"<<endl;
  SIS_table<<"Basis _ Biomass Biomass Numbers Eggs Biomass Biomass Biomass Numbers Numbers Numbers Dead_Catch_Bio/Summary_Bio "<<SPR_report_label<<" "<<F_report_label<<"  Sum_Fleet_Apical_Fs F=Z-M"<<endl;
  SIS_table<<"Range _ All Age_"<<Smry_Age<<"+ Age_0 Mature Exploitable_all Exploitable_dead Exploitable_retained  Exploitable_all Exploitable_dead Exploitable_retained ";
  sprintf(onenum, "%d", int(F_reporting_ages(1)));
  anystring=onenum;
  sprintf(onenum, "%d", int(F_reporting_ages(2)));
  anystring+="_"+onenum;
  SIS_table<<" Exploitable_dead Exploitable_all Exploitable_all Exploitable_all "<<anystring<<endl;
  SIS_table<<"Statistic _ Mean Mean Mean Mean Mean Mean Mean Mean Mean Mean Mean Mean Mean Mean Mean"<<endl;
  SIS_table<<"Scalar _ 1 1 1000 1 1 1 1 1000 1000 1000 1 1 1 1 1"<<endl;

   for (y=styr;y<=YrMax;y++)
   {
     SIS_table<<"_ "<<y<<" "<<Smry_Table(y,1)<<" "<<Smry_Table(y,2)<<" "<<Smry_Table(y,8)<<" "<<Smry_Table(y,7)<<" "<<annual_catch(y)<<" "<<annual_catch(y,2)/Smry_Table(y,2)<<" ";
     if(STD_Yr_Reverse_Ofish(y)>0) {SIS_table<<SPR_std(STD_Yr_Reverse_Ofish(y))<<" ";} else {SIS_table<<" _ ";}
     if(STD_Yr_Reverse_F(y)>0) {SIS_table<<F_std(STD_Yr_Reverse_F(y))<<" ";} else {SIS_table<<" _ ";}
     SIS_table<<annual_F(y)<<endl;
   } // end year loop

// end SPR time series
  SS2out<<endl<<"NOTE:_GENTIME_is_fecundity_weighted_mean_age"<<endl<<"NOTE:_MnAgeSmry_is_numbers_weighted_meanage_at_and_above_smryage(not_accounting_for_settlement_offsets)"<<endl;

  SS2out<<endl<<"Kobe_Plot"<<endl;
  if(F_std_basis!=2) SS2out<<"F_report_basis_is_not_=2;_so_info_below_is_not_F/Fmsy"<<endl;
  SS2out<<"MSY_basis:_";
  switch(Do_MSY)
    {
    case 1:  // set Fmsy=Fspr
      {SS2out<<"set_Fmsy=Fspr"<<endl;
      break;}
    case 2:  // calc Fmsy
      {SS2out<<"calculate_FMSY"<<endl;
      break;}
    case 3:  // set Fmsy=Fbtgt
      {SS2out<<"set_Fmsy=Fbtgt"<<endl;
      break;}
    case 4:   //  set fmult for Fmsy to 1
      {SS2out<<"set_Fmsy_using_Fmult=1.0"<<endl;
      break;}
    }
  SS2out<<"Yr  B/Bmsy  F/Fmsy"<<endl;
   for (y=styr;y<=YrMax;y++)
   {
    SS2out<<y<<" "<<SPB_yr(y)/Bmsy<<" ";
     if(y>=styr && STD_Yr_Reverse_F(y)>0 ) {SS2out<<" "<<F_std(STD_Yr_Reverse_F(y));} else {SS2out<<" _ ";}
     SS2out<<endl;
   }

// ******************************************************************************
  k=Nfleet;
  if(k<4) k=4;
  dvector rmse(1,k);    //  used in the SpBio, Index, Lencomp and Agecomp reports
  dvector Hrmse(1,k);
  dvector Rrmse(1,k);
  dvector n_rmse(1,k);
  dvector mean_CV(1,k);
  dvector mean_CV2(1,k);
  dvector mean_CV3(1,k);
//                                                            SS_Label_330
  rmse = 0.0;  n_rmse = 0.0;

   for (y=recdev_first;y<=recdev_end;y++)
   {
     temp1=recdev(y);
     if(y<recdev_start)  // so in early period
     {
       rmse(3)+=value(square(temp1)); n_rmse(3)+=1.; rmse(4)+=value(biasadj(y));
     }
     else
     {
       rmse(1)+=value(square(temp1)); n_rmse(1)+=1.; rmse(2)+=value(biasadj(y));
     }

   }
   if(n_rmse(1)>0. && rmse(1)>0.) rmse(1) = sqrt(rmse(1)/n_rmse(1));  // rmse during main period
   if(n_rmse(1)>0.) rmse(2) = rmse(2)/n_rmse(1);  // mean biasadj during main period
   if(n_rmse(3)>0. && rmse(3)>0.) rmse(3) = sqrt(rmse(3)/n_rmse(3));  //rmse during early period
   if(n_rmse(3)>0.) rmse(4) = rmse(4)/n_rmse(3);  // mean biasadj during early period

    dvariable Shepard_c;
    dvariable Shepard_c2;
    dvariable Hupper;
    if(SR_fxn==8)
    {
      Shepard_c=SR_parm(3);
      Shepard_c2=pow(0.2,Shepard_c);
      Hupper=1.0/(5.0*Shepard_c2);
      temp=0.2+(SR_parm(2)-0.2)/(0.8)*(Hupper-0.2);
    }
//  SPAWN-RECR: output to report.sso
  SS2out<<endl<<"SPAWN_RECRUIT Function: "<<SR_fxn<<" _ _ _ _ _ _"<<endl<<
  SR_parm(1)<<" Ln(R0) "<<mfexp(SR_parm(1))<<endl<<
  SR_parm(2)<<" steep"<<endl<<
  Bmsy/SPB_virgin<<" Bmsy/Bzero ";
  if(SR_fxn==8) SS2out<<Shepard_c<<" Shepard_c "<<Hupper<<" steepness_limit "<<temp<<" Adjusted_steepness";
  SS2out<<endl;
  SS2out<<sigmaR<<" sigmaR"<<endl;
  SS2out<<init_equ_steepness<<"  # 0/1 to use steepness in initial equ recruitment calculation"<<endl;
  /*
  SS2out<<SR_parm(N_SRparm2-2)<<" env_link_";
  if(SR_env_link>0)
    {
    SS2out<<"to_envvar:_"<<SR_env_link<<"_with_affect_on:";
    if(SR_env_target==1)
      {SS2out<<"_Annual_devs";}
    else if(SR_env_target==2)
      {SS2out<<"_Rzero";}
    else if(SR_env_target==3)
      {SS2out<<"_Steepness";}
    }
  */
  SS2out<<SR_parm(N_SRparm2-1)<<" init_eq "<<mfexp(SR_parm(1)+SR_parm(N_SRparm2-1))<<endl<<
  recdev_start<<" "<<recdev_end<<" main_recdev:start_end"<<endl<<
  recdev_adj(1)<<" "<<recdev_adj(2,5)<<" breakpoints_for_bias_adjustment_ramp "<<endl;

   temp=sigmaR*sigmaR;  //  sigmaR^2
   SS2out<<"ERA    N    RMSE  RMSE^2/sigmaR^2  mean_BiasAdj"<<endl;
   SS2out<<"main  "<<n_rmse(1)<<" "<<rmse(1)<<" "<<square(rmse(1))/temp<<" "<<rmse(2);
   if(rmse(1)<0.5*sigmaR && rmse(2)>(0.01+2.0*square(rmse(1))/temp))
   {N_warn++; warning<<" Main recdev biasadj is >2 times ratio of rmse to sigmaR"<<endl; SS2out<<" # Main_recdev_biasadj_is_>2_times_ratio_of_rmse_to_sigmaR"<<endl;}
   else
   {SS2out<<endl;}
   SS2out<<"early "<<n_rmse(3)<<" "<<rmse(3)<<" "<<square(rmse(3))/temp<<" "<<rmse(4);
   if(rmse(3)<0.5*sigmaR && rmse(4)>(0.01+2.0*square(rmse(3))/temp))
   {N_warn++; warning<<" Early recdev biasadj is >2 times ratio of rmse to sigmaR"<<endl; SS2out<<" # Early_recdev_biasadj_is_>2_times_ratio_of_rmse_to_sigmaR"<<endl;}
   else
   {SS2out<<endl;}

  SS2out<<"Yr SpawnBio exp_recr with_regime bias_adjusted pred_recr dev biasadjuster era mature_bio mature_num"<<endl;
  SS2out<<"S/Rcurve "<<SPB_virgin<<" "<<Recr_virgin<<endl;
  y=styr-2;
  SS2out<<"Virg "<<SPB_yr(y)<<" "<<exp_rec(y)<<" - "<<0.0<<" Virg "<<SPB_B_yr(y)<<" "<<SPB_N_yr(y)<<endl;
  y=styr-1;
  SS2out<<"Init "<<SPB_yr(y)<<" "<<exp_rec(y)<<" - "<<0.0<<" Init "<<SPB_B_yr(y)<<" "<<SPB_N_yr(y)<<endl;

  if(recdev_first<styr)
  {
    for (y=recdev_first;y<=styr-1;y++)
    {
      SS2out<<y<<" "<<SPB_yr(styr-1)<<" "<<exp_rec(styr-1,1)<<" "<<exp_rec(styr-1,2)<<" "<<exp_rec(styr-1,3)*mfexp(-biasadj(y)*half_sigmaRsq)<<" "<<
      exp_rec(styr-1,3)*mfexp(recdev(y)-biasadj(y)*half_sigmaRsq)<<" "
      <<recdev(y)<<" "<<biasadj(y)<<" Init_age "<<SPB_B_yr(styr-1)<<" "<<SPB_N_yr(styr-1)<<endl;
    }
  }
   for (y=styr;y<=YrMax;y++)
   {
     SS2out<<y<<" "<<SPB_yr(y)<<" "<<exp_rec(y)<<" ";
     if(recdev_do_early>0 && y>=recdev_early_start && y<=recdev_early_end)
       {SS2out<<recdev(y)<<" "<<biasadj(y)<<" Early "<<SPB_B_yr(y)<<" "<<SPB_N_yr(y);}
     else if(y>=recdev_start && y<=recdev_end)
       {SS2out<<recdev(y)<<" "<<biasadj(y)<<" Main "<<SPB_B_yr(y)<<" "<<SPB_N_yr(y);}
     else if(Do_Forecast>0 && y>recdev_end)
     {
        SS2out<<Fcast_recruitments(y)<<" "<<biasadj(y);
        if(y<=endyr)
        {SS2out<<" Late "<<SPB_B_yr(y)<<" "<<SPB_N_yr(y);}
        else
        {SS2out<<" Forecast "<<SPB_B_yr(y)<<" "<<SPB_N_yr(y);}
      }
     else
       {SS2out<<" _ _ Fixed";}
//       SS2out<<" "<<recdev_cycle_parm(gg);
     SS2out<<endl;
   }

// ******************************************************************************
//                                             SS_Label_340

  SS2out <<endl<< "INDEX_2" << endl;
  rmse = 0.0;  n_rmse = 0.0; mean_CV=0.0; mean_CV2=0.0; mean_CV3=0.0;
  SS2out<<"Fleet Name Yr Seas Yr.frac Vuln_bio Obs Exp Calc_Q Eff_Q SE Dev Like Like+log(s) SuprPer Use"<<endl;
  if(Svy_N>0)
  {
    for (f=1;f<=Nfleet;f++)
    {
      in_superperiod=0;
      for (i=1;i<=Svy_N_fleet(f);i++)
      {
        t=Svy_time_t(f,i);
        ALK_time=Svy_ALK_time(f,i);
          SS2out<<f<<" "<<fleetname(f)<<" "<<Show_Time(t)<<" "<<data_time(ALK_time,f,3)<<" "<<Svy_selec_abund(f,i)<<" "<<Svy_obs(f,i)<<" ";
          if(Svy_errtype(f)>=0)  // lognormal
          {
            temp = mfexp(Svy_est(f,i));
            SS2out<<temp<<" "<<Svy_q(f,i)<<" "<<temp/Svy_selec_abund(f,i)<<" "<<Svy_se_use(f,i);
            if(Svy_use(f,i) > 0)
            {
              SS2out<<" "<<Svy_obs_log(f,i)-Svy_est(f,i)<<" ";
              if(Svy_errtype(f)==0)
              {
                SS2out<<0.5*square( ( Svy_obs_log(f,i)-Svy_est(f,i) ) / Svy_se_use(f,i))<<" "
                <<0.5*square( ( Svy_obs_log(f,i)-Svy_est(f,i) ) / Svy_se_use(f,i))+log(Svy_se_use(f,i));
              }
              else  // student's T
              {
                SS2out<<((Svy_errtype(f)+1.)/2.)*log((1.+square((Svy_obs_log(f,i)-Svy_est(f,i) ))/(Svy_errtype(f)*square(Svy_se_use(f,i))) ))<<" "
                <<((Svy_errtype(f)+1.)/2.)*log((1.+square((Svy_obs_log(f,i)-Svy_est(f,i) ))/(Svy_errtype(f)*square(Svy_se_use(f,i))) ))+log(Svy_se_use(f,i));
              }
              rmse(f)+=value(square(Svy_obs_log(f,i)-Svy_est(f,i))); n_rmse(f)+=1.;
              mean_CV(f)+=Svy_se_rd(f,i); mean_CV3(f)+=Svy_se(f,i); mean_CV2(f)+=value(Svy_se_use(f,i));
            }
            else
            {
              SS2out<<" _ _ _ ";
            }
          }
          else  // normal
          {
//            temp = Svy_est(f,i)*Svy_q(f,i);
            SS2out<<Svy_est(f,i)<<" "<<Svy_q(f,i)<<" "<<Svy_est(f,i)/Svy_selec_abund(f,i)<<" "<<Svy_se_use(f,i);
            if(Svy_use(f,i)>0)
            {
              SS2out<<" "<<Svy_obs(f,i)-Svy_est(f,i)<<" ";
              SS2out<<0.5*square( ( Svy_obs(f,i)-Svy_est(f,i) ) / Svy_se_use(f,i))<<" "
              <<0.5*square( ( Svy_obs(f,i)-Svy_est(f,i) ) / Svy_se_use(f,i))+log(Svy_se_use(f,i));
              rmse(f)+=value(square(Svy_obs(f,i)-Svy_est(f,i))); n_rmse(f)+=1.;
              mean_CV(f)+=Svy_se_rd(f,i); mean_CV3(f)+=Svy_se(f,i); mean_CV2(f)+=value(Svy_se_use(f,i));
            }
            else
            {
              SS2out<<" _ _ _ ";
            }
          }
          if(Svy_super(f,i)<0 &&in_superperiod==0)
          {in_superperiod=1; SS2out<<" beg_SuprPer ";}
          else if(Svy_super(f,i)<0 &&in_superperiod==1)
          {in_superperiod=0; SS2out<<" end_SuprPer ";}
          else if(in_superperiod==1)
          {SS2out<<" in_SuprPer ";}
          else{SS2out<<" _ ";}
          SS2out<<Svy_use(f,i);
          SS2out<<endl;
      }
      if(n_rmse(f)>0) {rmse(f) = sqrt((rmse(f)+1.0e-9)/n_rmse(f)); mean_CV(f) /= n_rmse(f); mean_CV3(f) /= n_rmse(f); mean_CV2(f) /= n_rmse(f);}
    }
  }

  SS2out <<endl<< "INDEX_1" << endl;
  SS2out <<"Fleet Link Link+ ExtraStd BiasAdj Float   Q Num=0/Bio=1 Err_type"<<
    " N Npos RMSE mean_input_SE Input+VarAdj Input+VarAdj+extra VarAdj New_VarAdj penalty_mean_Qdev rmse_Qdev fleetname"<<endl;
  for (f=1;f<=Nfleet;f++)
    {
    	if(Svy_N_fleet(f)>0)
    		{
        SS2out<<f<<" "<<Q_setup(f)<<" "<<Svy_q(f,1)<<" "<<Svy_units(f)<<" "<<Svy_errtype(f)
      <<" "<<Svy_N_fleet(f)<<" "<<n_rmse(f)<<" "<<rmse(f)
      <<" "<<mean_CV(f)<<" "<<mean_CV3(f)<<" "<<mean_CV2(f)<<" "<<var_adjust(1,f)
      <<" "<<var_adjust(1,f)+rmse(f)-mean_CV(f)
      <<" "<<Q_dev_like(f,1)<<" "<<Q_dev_like(f,2)<<" "<<fleetname(f)<<endl;
    }
  }
    if(depletion_fleet>0)  //  special code for depletion, so prepare to adjust phases and lambdas
      {
        f=depletion_fleet;
        SS2out<<"#_survey: "<<f<<" "<<fleetname(f)<<" is a depletion fleet"<<endl;
        if(depletion_type==0)
          SS2out<<"#_Q_setup(f,2)=0; add 1 to phases of all parms; only R0 active in new phase 1"<<endl;
        if(depletion_type==1)
          SS2out<<"#_Q_setup(f,2)=1  only R0 active in phase 1; then exit;  useful for data-limited draws of other fixed parameter"<<endl;
        if(depletion_type==2)
          SS2out<<"#_Q_setup(f,2)=2  no phase adjustments, can be used when profiling on fixed R0"<<endl;
      }

    SS2out<<"RMSE_Qdev_not_in_logL"<<endl<<"penalty_mean_Qdev_not_in_logL_in_randwalk_approach"<<endl;

  SS2out <<"#"<<endl<< "INDEX_3"<<endl<<"Fleet  Q_parm_assignments"<<endl;
  for (f=1;f<=Nfleet;f++)
    {SS2out<<f<<" "<<Q_setup_parms(f,1)<<" _ "<<Q_setup_parms(f,2)<<" _ "<<Q_setup_parms(f)(3,4)<<" "<<fleetname(f)<<endl;}

  SS2out<<endl<<"DISCARD_SPECIFICATION ";
  SS2out<<"Discard_units_options"<<endl;
   SS2out << "1:  discard_in_biomass(mt)_or_numbers(1000s)_to_match_catchunits_of_fleet"<<endl;
   SS2out << "2:  discard_as_fraction_of_total_catch(based_on_bio_or_num_depending_on_fleet_catchunits)"<<endl;
   SS2out << "3:  discard_as_numbers(1000s)_regardless_of_fleet_catchunits"<<endl;
  SS2out<<"Discard_errtype_options"<<endl;
  SS2out << ">1:  log(L)_based_on_T_distribution_with_specified_DF"<< endl;
  SS2out << "0:  log(L)_based_on_normal_with_Std_in_as_CV"<< endl;
  SS2out << "-1:  log(L)_based_on_normal_with_Std_in_as_stddev"<< endl;
  SS2out << "-2:  log(L)_based_on_lognormal_with_Std_in_as_stddev_in_logspace"<< endl;
  SS2out << "-3:  log(L)_based_on_trunc_normal_with_Std_in_as_CV"<< endl;

  SS2out<<"#_Fleet units errtype"<<endl;
  if(Ndisc_fleets>0)
  {
    for (f=1;f<=Nfleet;f++)
    if(fleet_type(f)<=2)
    if(disc_units(f)>0) SS2out<<f<<" "<<disc_units(f)<<" "<<disc_errtype(f)<<" # "<<fleetname(f)<<endl;
  }

  SS2out<<"#"<<endl<<"DISCARD_OUTPUT "<<endl;
  SS2out<<"Fleet Name Yr Seas Yr.S Obs Exp Std_in Std_use Dev Like Like+log(s) SuprPer Use Obs_cat Exp_cat catch_mult exp_cat*catch_mult F_rate"<<endl;
  data_type=2;
  if(nobs_disc>0)
  for (f=1;f<=Nfleet;f++)
  if(fleet_type(f)<=2)
  {
    for (i=1;i<=disc_N_fleet(f);i++)
    {
      t = disc_time_t(f,i);
      y=Show_Time(t,1);
      ALK_time=disc_time_ALK(f,i);
      if(catchunits(f)==1)
      {gg=3;}  //  biomass
      else
      {gg=6;}  //  numbers
      SS2out<<f<<" "<<fleetname(f)<<" "<<Show_Time(t)<<" "<<data_time(ALK_time,f,3)<<" "<<obs_disc(f,i)<<" "
      <<exp_disc(f,i)<<" "<<" "<<cv_disc(f,i)<<" "<<sd_disc(f,i);

      if(yr_disc_use(f,i)>=0.0)
      {
        if(disc_errtype(f)>=1)  // T -distribution
        {
          temp=0.5*(disc_errtype(f)+1.)*log((1.+square(obs_disc(f,i)-exp_disc(f,i))/(disc_errtype(f)*square(sd_disc(f,i))) ));
          SS2out<<" "<<obs_disc(f,i)-exp_disc(f,i)<<" "<<temp<<" "<<temp + sd_offset*log(sd_disc(f,i));
        }
        else if (disc_errtype(f)==0)  // normal error, with input CV
        {
          temp=0.5*square( (obs_disc(f,i)-exp_disc(f,i)) / sd_disc(f,i));
          SS2out<<" "<<obs_disc(f,i)-exp_disc(f,i)<<" "<<temp<<" "<<temp + sd_offset*log(sd_disc(f,i));
        }
        else if (disc_errtype(f)==-1)  // normal error with input se
        {
          temp=0.5*square( (obs_disc(f,i)-exp_disc(f,i)) / sd_disc(f,i));
          SS2out<<" "<<obs_disc(f,i)-exp_disc(f,i)<<" "<<temp<<" "<<temp + sd_offset*log(sd_disc(f,i));
        }
        else if (disc_errtype(f)==-2)  // lognormal  where input cv_disc must contain se in log space
        {
          temp=0.5*square( log(obs_disc(f,i)/exp_disc(f,i)) / sd_disc(f,i));
          SS2out<<" "<<log(obs_disc(f,i)/exp_disc(f,i))<<" "<<temp<<" "<<temp + sd_offset*log(sd_disc(f,i));
        }
        else if (disc_errtype(f)==-3)  // trunc normal error, with input CV
        {
          temp=0.5*square( (obs_disc(f,i)-exp_disc(f,i) ) / sd_disc(f,i)) - log(cumd_norm( (1 - exp_disc(f,i)) / sd_disc(f,i) ) - cumd_norm( (0 - exp_disc(f,i)) / sd_disc(f,i) ));
          SS2out<<" "<<obs_disc(f,i)-exp_disc(f,i)<<" "<<temp<<" "<<temp + sd_offset*log(sd_disc(f,i));
        }
      }
      else
      {
        SS2out<<"  _  _  _  ";
      }
      if(yr_disc_super(f,i)<0 &&in_superperiod==0)
      {in_superperiod=1; SS2out<<" beg_SuprPer ";}
      else if(yr_disc_super(f,i)<0 &&in_superperiod==1)
      {in_superperiod=0; SS2out<<" end_SuprPer ";}
      else if(in_superperiod==1)
      {SS2out<<" in_SuprPer ";}
      else{SS2out<<" _ ";}
      SS2out<<yr_disc_use(f,i);
      SS2out<<" "<<catch_ret_obs(f,t)<<" "<<catch_fleet(t,f,gg)<<" "<<catch_mult(y,f)<<" "<<catch_mult(y,f)*catch_fleet(t,f,gg)<<" "<<Hrate(f,t);
      SS2out<<endl;
    }
  }

  SS2out <<endl<< "MEAN_BODY_WT_OUTPUT"<<endl;
  if(nobs_mnwt>0) SS2out<<"log(L)_based_on_T_distribution_with_DF=_"<<DF_bodywt<< endl;
  SS2out<<"Fleet Name Yr Seas Yr.S Mkt Obs Exp CV Dev NeglogL Neg(logL+log(s)) Use"<<endl;
  if(nobs_mnwt>0)
  for (i=1;i<=nobs_mnwt;i++)
  {
    t=mnwtdata(1,i);
    f=abs(mnwtdata(3,i));
    SS2out << mnwtdata(3,i)<<" "<<fleetname(f)<<" "<<Show_Time(t)<<" NA "
    <<mnwtdata(4,i)<<" "<<mnwtdata(5,i)<<" "<<exp_mnwt(i)<<" "<<mnwtdata(6,i);
    if(mnwtdata(3,i)>0.)
    {
      SS2out<<" "<<mnwtdata(5,i)-exp_mnwt(i)<<" "<<
       0.5*(DF_bodywt+1.)*log(1.+square(mnwtdata(5,i)-exp_mnwt(i))/mnwtdata(8,i))<<" "<<
       0.5*(DF_bodywt+1.)*log(1.+square(mnwtdata(5,i)-exp_mnwt(i))/mnwtdata(8,i))+ mnwtdata(9,i)<<" "<<1;
    }
    else
    {
      SS2out<<" NA NA NA -1";
    }
    SS2out<<endl;
  }

  SS2out <<endl<< "FIT_LEN_COMPS" << endl;                     // SS_Label_350
  SS2out<<"Fleet Yr Month Seas Yr.frac Sex Mkt SuprPer Use Nsamp effN Like";
  SS2out<<" All_obs_mean All_exp_mean All_delta All_exp_5% All_exp_95% All_DurWat";
  if(gender==2) SS2out<<" F_obs_mean F_exp_mean F_delta F_exp_5% F_exp_95% F_DurWat M_obs_mean M_exp_mean M_delta M_exp_5% M_exp_95% M_DurWat %F_obs %F_exp ";
  SS2out<<endl;
  rmse = 0.0;  n_rmse = 0.0; mean_CV=0.0;  Hrmse=0.0; Rrmse=0.0; neff_l.initialize();
  in_superperiod=0;
  data_type=4;
  dvar_vector more_comp_info(1,20);
  dvariable cumdist;
  dvariable cumdist_save;
  //mean_all_obs; 1
  //mean_all_exp; 2
  //mean_all_delta; 3
  //5%_all_exp; 4
  //95%_all_exp; 5
  //Durbin-Watson_all; 6
  //mean_F_obs; 7
  //mean_F_exp; 8
  //mean_F_delta; 9
  //5%_F_exp; 10
  //95%_F_exp; 11
  //Durbin-Watson_F; 12
 //mean_M_obs; 13
  //mean_M_exp; 14
  //mean_M_delta; 15
  //5%_M_exp; 16
  //95%_M_exp; 17
  //Durbin-Watson_M;  18
  //sexratio_obs; 19
  //sexratio_exp; 20

   for (f=1;f<=Nfleet;f++)
   for (i=1;i<=Nobs_l(f);i++)
   {
     t=Len_time_t(f,i);
     ALK_time=Len_time_ALK(f,i);
     if(header_l(f,i,3)>0)
     {
       neff_l(f,i)  = exp_l(f,i)*(1-exp_l(f,i))+1.0e-06;     // constant added for stability
       neff_l(f,i) /= (obs_l(f,i)-exp_l(f,i))*(obs_l(f,i)-exp_l(f,i))+1.0e-06;
       n_rmse(f)+=1.;
       rmse(f)+=value(neff_l(f,i));
       mean_CV(f)+=nsamp_l(f,i);
       Hrmse(f)+=value(1./neff_l(f,i));
       Rrmse(f)+=value(neff_l(f,i)/nsamp_l(f,i));

       more_comp_info.initialize();
       // do both sexes  tails_l(f,i,4) has been set to tails_l(f,i,2) if males not in this sample
       if(gen_l(f,i)==3 || gen_l(f,i)==0)
       {
         more_comp_info(1)=obs_l(f,i)(tails_l(f,i,1),tails_l(f,i,4))*len_bins_dat_m2(tails_l(f,i,1),tails_l(f,i,4));
         more_comp_info(2)=value(exp_l(f,i)(tails_l(f,i,1),tails_l(f,i,4))*len_bins_dat_m2(tails_l(f,i,1),tails_l(f,i,4)));
         more_comp_info(3)=more_comp_info(1)-more_comp_info(2);
         //  calc tails of distribution and Durbin-Watson for autocorrelation
         temp1=0.0;
         z=tails_l(f,i,1);
         cumdist_save=0.0;
         cumdist=0.0;
         for(z=1;z<=nlen_bin;z++)
         {
          cumdist+=exp_l(f,i,z);
          if(gender==2)  cumdist+=exp_l(f,i,z+nlen_bin);  // add males and females
          if(cumdist>=0.05 && cumdist_save<0.05)  //  found bin for 5%
          {
            if(z==1)
            {more_comp_info(4)=len_bins_dat2(z);}  //  set to lower edge
            else
            {more_comp_info(4)=len_bins_dat2(z)+(len_bins_dat2(min(z+1,nlen_bin))-len_bins_dat2(z))*(0.05-cumdist_save)/(cumdist-cumdist_save);}
          }
          if(cumdist>=0.95 && cumdist_save<0.95)  //  found bin for 95%
          {
            more_comp_info(5)=len_bins_dat2(z)+(len_bins_dat2(min(z+1,nlen_bin))-len_bins_dat2(z))*(0.95-cumdist_save)/(cumdist-cumdist_save);
          }
          cumdist_save=cumdist;

          temp=obs_l(f,i,z)-exp_l(f,i,z);  //  obs-exp
          if(z>tails_l(f,i,1))
          {
            more_comp_info(6)+=value(square(temp2-temp));
            temp1+=value(square(temp));
          }
          temp2=temp;
         }
         if(gen_l(f,i)==3 && gender==2)  // do sex ratio
         {
           more_comp_info(19)=sum(obs_l(f,i)(tails_l(f,i,1),tails_l(f,i,2)));  //  sum obs female fractions =  %female
           more_comp_info(20)=value(sum(exp_l(f,i)(tails_l(f,i,1),tails_l(f,i,2)))); //  sum exp female fractions =  %female
           for(z=tails_l(f,i,3);z<=tails_l(f,i,4);z++)
           {
            temp=obs_l(f,i,z)-exp_l(f,i,z);  //  obs-exp
            if(z>tails_l(f,i,1))
            {
              more_comp_info(6)+=value(square(temp2-temp));
              temp1+=value(square(temp));
            }
            temp2=temp;
           }
         }
         more_comp_info(6)=(more_comp_info(6)/temp1) - 2.0;
       }

       if(gen_l(f,i)==1 || gen_l(f,i)==3)  //  need females
       {
         //  where len_bins_dat_m2() holds midpoints of the data length bins
         more_comp_info(7)=(obs_l(f,i)(tails_l(f,i,1),tails_l(f,i,2))*len_bins_dat_m2(tails_l(f,i,1),tails_l(f,i,2)))/sum(obs_l(f,i)(tails_l(f,i,1),tails_l(f,i,2)));
         more_comp_info(8)=value((exp_l(f,i)(tails_l(f,i,1),tails_l(f,i,2))*len_bins_dat_m2(tails_l(f,i,1),tails_l(f,i,2)))/sum(exp_l(f,i)(tails_l(f,i,1),tails_l(f,i,2))));
         more_comp_info(9)=more_comp_info(7)-more_comp_info(8);
         //  calc tails of distribution and Durbin-Watson for autocorrelation
         temp1=0.0;
         z=tails_l(f,i,1);
         cumdist_save=0.0;
         cumdist=0.0;
         for(z=tails_l(f,i,1);z<=tails_l(f,i,2);z++)
         {
          cumdist+=value(exp_l(f,i,z));
          if(cumdist>=0.05*more_comp_info(20) && cumdist_save<0.05*more_comp_info(20))  //  found bin for 5%
          {
            if(z==1)
            {more_comp_info(10)=len_bins_dat2(z);}  //  set to lower edge
            else
            {more_comp_info(10)=len_bins_dat2(z)+(len_bins_dat2(min(z+1,nlen_bin))-len_bins_dat2(z))*(0.05*more_comp_info(20)-cumdist_save)/(cumdist-cumdist_save);}
          }
          if(cumdist>=0.95*more_comp_info(20) && cumdist_save<0.95*more_comp_info(20))  //  found bin for 95%
          {
            more_comp_info(11)=len_bins_dat2(z)+(len_bins_dat2(min(z+1,nlen_bin))-len_bins_dat2(z))*(0.95*more_comp_info(20)-cumdist_save)/(cumdist-cumdist_save);
          }
          cumdist_save=cumdist;

          temp=obs_l(f,i,z)-exp_l(f,i,z);  //  obs-exp
          if(z>tails_l(f,i,1))
          {
            more_comp_info(12)+=value(square(temp2-temp));
            temp1+=value(square(temp));
          }
          temp2=temp; //  save current delta
         }
         more_comp_info(12)=(more_comp_info(12)/temp1) - 2.0;
       }
       if(gen_l(f,i)>=2 && gender==2)  // need males
       {
         more_comp_info(13)=(obs_l(f,i)(tails_l(f,i,3),tails_l(f,i,4))*len_bins_dat_m2(tails_l(f,i,3),tails_l(f,i,4)))/sum(obs_l(f,i)(tails_l(f,i,3),tails_l(f,i,4)));
         more_comp_info(14)=value((exp_l(f,i)(tails_l(f,i,3),tails_l(f,i,4))*len_bins_dat_m2(tails_l(f,i,3),tails_l(f,i,4)))/sum(exp_l(f,i)(tails_l(f,i,3),tails_l(f,i,4))));
         more_comp_info(15)=more_comp_info(13)-more_comp_info(14);
         //  calc tails of distribution and Durbin-Watson for autocorrelation
         temp1=0.0;
         z=tails_l(f,i,3);
         cumdist_save=0.0;
         cumdist=0.0;
         for(z=tails_l(f,i,3);z<=tails_l(f,i,4);z++)
         {
          cumdist+=value(exp_l(f,i,z));
          if(cumdist>=0.05*more_comp_info(20) && cumdist_save<0.05*more_comp_info(20))  //  found bin for 5%
          {
            if(z==nlen_bin+1)
            {more_comp_info(16)=len_bins_dat2(z);}  //  set to lower edge
            else
            {more_comp_info(16)=len_bins_dat2(z)+(len_bins_dat2(min(z+1,nlen_bin2))-len_bins_dat2(z))*(0.05*more_comp_info(20)-cumdist_save)/(cumdist-cumdist_save);}
          }
          if(cumdist>=0.95*more_comp_info(20) && cumdist_save<0.95*more_comp_info(20))  //  found bin for 95%
          {
            more_comp_info(17)=len_bins_dat2(z)+(len_bins_dat2(min(z+1,nlen_bin2))-len_bins_dat2(z))*(0.95*more_comp_info(20)-cumdist_save)/(cumdist-cumdist_save);
          }
          cumdist_save=cumdist;

          temp=obs_l(f,i,z)-exp_l(f,i,z);  //  obs-exp
          if(z>tails_l(f,i,1))
          {
            more_comp_info(18)+=value(square(temp2-temp));
            temp1+=value(square(temp));
          }
          temp2=temp; //  save current delta
         }
         more_comp_info(18)=(more_comp_info(18)/temp1) - 2.0;
       }
     }
     else
     {
       neff_l(f,i)=0.;
     }

      SS2out<<f<<" "<<header_l(f,i,1)<<" "<<abs(header_l(f,i,2))<<" "<<Show_Time2(ALK_time,2)<<" "<<data_time(ALK_time,f,3)<<" "<<gen_l(f,i)<<" "<<mkt_l(f,i);
      if(header_l(f,i,2)<0 && in_superperiod==0)
      {SS2out<<" start "; in_superperiod=1;}
      else if (header_l(f,i,2)<0 && in_superperiod==1)
      {SS2out<<" end "; in_superperiod=0;}
      else if (in_superperiod==1)
      {SS2out<<" in ";}
      else
      {SS2out<<" _ ";}
      if(header_l(f,i,3)<0)
      {SS2out<<" skip ";}
      else
      {SS2out<<" _ ";}
      SS2out<<nsamp_l(f,i)<<" "<<neff_l(f,i)<<" "<<length_like(f,i)<<" ";
      SS2out<<more_comp_info(1,6);
      if(gender==2) SS2out<<" "<<more_comp_info(7,20);
      SS2out<<endl;
    }

//Fleet N Npos mean_effN mean(inputN*Adj) HarMean(effN) Mean(effN/inputN) MeaneffN/MeaninputN Var_Adj
//long ago, Ian Stewart had the proto-r4ss add a column called "HarEffN/MeanInputN" which was the ratio of the columns "HarMean(effN)" column and the "mean(inputN*Adj)" and has been used as the multiplier on the adjustment factor in the status-quo NWFSC tuning approach.
//My suggestion would be to remove the columns "Mean(effN/inputN)" and "MeaneffN/MeaninputN" if those are not recommended values for tuning (I don't get the impression that they are) and have SS internally produce the "HarEffN/MeanInputN" column so that it's available to all users.
//It might also be good to add a keyword to the top of those lower tables which could simplify the logic of parsing them separately from the FIT_..._COMPS tables above them and therefore be more robust to changes in format.

   SS2out<<endl<<"Length_Comp_Fit_Summary"<<endl<<
   "Fleet N Npos min_inputN mean_inputN*Adj mean_effN HarMean Curr_Var_Adj Recommend_Var_Adj FleetName"<<endl;
   for (f=1;f<=Nfleet;f++)
   {
    if(n_rmse(f)>0) {rmse(f)/=n_rmse(f); mean_CV(f)/=n_rmse(f); Hrmse(f)=n_rmse(f)/Hrmse(f);}
    SS2out<<f;
    if(Nobs_l(f)>0)
    {SS2out<<" "<<Nobs_l(f)<<" "<<n_rmse(f)<<" " <<min_sample_size_L(f)<<" "<<mean_CV(f)<<" "<<rmse(f)<<" "<<Hrmse(f)
    <<" "<<var_adjust(4,f)<<" "<<Hrmse(f)/mean_CV(f)*var_adjust(4,f)<<" "<<fleetname(f)<<endl;}
    else
    {SS2out<<" _ _ _ _ _ _ _ _ _ "<<endl;}
   }

  SS2out <<endl<< "FIT_AGE_COMPS" << endl;
  SS2out<<"Fleet Yr Month Seas Yr.frac Sex Mkt Ageerr Lbin_lo Lbin_hi Nsamp effN Like SuprPer Use";
  SS2out<<" All_obs_mean All_exp_mean All_delta All_exp_5% All_exp_95% All_DurWat";
  if(gender==2) SS2out<<" F_obs_mean F_exp_mean F_delta F_exp_5% F_exp_95% F_DurWat M_obs_mean M_exp_mean M_delta M_exp_5% M_exp_95% M_DurWat %F_obs %F_exp ";
  SS2out<<endl;
  rmse = 0.0;  n_rmse = 0.0; mean_CV=0.0;  Hrmse=0.0; Rrmse=0.0;
   if(Nobs_a_tot>0)
   for(f=1;f<=Nfleet;f++)
   for(i=1;i<=Nobs_a(f);i++)
     {
      t=Age_time_t(f,i);
      ALK_time=Age_time_ALK(f,i);

     if(nsamp_a(f,i)>0 && header_a(f,i,3)>0)
     {
       neff_a(f,i)  = exp_a(f,i)*(1-exp_a(f,i))+1.0e-06;     // constant added for stability
       neff_a(f,i) /= (obs_a(f,i)-exp_a(f,i))*(obs_a(f,i)-exp_a(f,i))+1.0e-06;
       n_rmse(f)+=1.;
       rmse(f)+=value(neff_a(f,i));
       mean_CV(f)+=nsamp_a(f,i);
       Hrmse(f)+=value(1./neff_a(f,i));
       Rrmse(f)+=value(neff_a(f,i)/nsamp_a(f,i));
       more_comp_info.initialize();
       // do both sexes  tails_a(f,i,4) has been set to tails_a(f,i,2) if males not in this sample
       if(gen_a(f,i)==3 || gen_a(f,i)==0)
       {
         more_comp_info(1)=obs_a(f,i)(tails_a(f,i,1),tails_a(f,i,4))*age_bins_mean(tails_a(f,i,1),tails_a(f,i,4));
         more_comp_info(2)=value(exp_a(f,i)(tails_a(f,i,1),tails_a(f,i,4))*age_bins_mean(tails_a(f,i,1),tails_a(f,i,4)));
         more_comp_info(3)=more_comp_info(1)-more_comp_info(2);
         //  calc tails of distribution and Durbin-Watson for autocorrelation
         temp1=0.0;
         z=tails_a(f,i,1);
         cumdist_save=0.0;
         cumdist=0.0;
         for(z=1;z<=n_abins;z++)
         {
          cumdist+=exp_a(f,i,z);
          if(gender==2)  cumdist+=exp_a(f,i,z+n_abins);  // add males and females
          if(cumdist>=0.05 && cumdist_save<0.05)  //  found bin for 5%
          {
            if(z==1)
            {more_comp_info(4)=age_bins(z);}  //  set to lower edge
            else
            {more_comp_info(4)=age_bins(z)+(age_bins(min(z+1,n_abins))-age_bins(z))*(0.05-cumdist_save)/(cumdist-cumdist_save);}
          }
          if(cumdist>=0.95 && cumdist_save<0.95)  //  found bin for 95%
          {
            more_comp_info(5)=age_bins(z)+(age_bins(min(z+1,n_abins))-age_bins(z))*(0.95-cumdist_save)/(cumdist-cumdist_save);
          }
          cumdist_save=cumdist;

          temp=obs_a(f,i,z)-exp_a(f,i,z);  //  obs-exp
          if(z>tails_a(f,i,1))
          {
            more_comp_info(6)+=value(square(temp2-temp));
            temp1+=value(square(temp));
          }
          temp2=temp;
         }
         if(gen_a(f,i)==3 && gender==2)  // do sex ratio
         {
           more_comp_info(19)=sum(obs_a(f,i)(tails_a(f,i,1),tails_a(f,i,2)));  //  sum obs female fractions =  %female
           more_comp_info(20)=value(sum(exp_a(f,i)(tails_a(f,i,1),tails_a(f,i,2)))); //  sum exp female fractions =  %female
           for(z=tails_a(f,i,3);z<=tails_a(f,i,4);z++)
           {
            temp=obs_a(f,i,z)-exp_a(f,i,z);  //  obs-exp
            if(z>tails_a(f,i,1))
            {
              more_comp_info(6)+=value(square(temp2-temp));
              temp1+=value(square(temp));
            }
            temp2=temp;
           }
         }
         more_comp_info(6)=(more_comp_info(6)/temp1) - 2.0;
       }

       if(gen_a(f,i)==1 || gen_a(f,i)==3)  //  need females
       {
         //  where len_bins_dat_m2() holds midpoints of the data length bins
         more_comp_info(7)=(obs_a(f,i)(tails_a(f,i,1),tails_a(f,i,2))*age_bins_mean(tails_a(f,i,1),tails_a(f,i,2)))/sum(obs_a(f,i)(tails_a(f,i,1),tails_a(f,i,2)));
         more_comp_info(8)=value((exp_a(f,i)(tails_a(f,i,1),tails_a(f,i,2))*age_bins_mean(tails_a(f,i,1),tails_a(f,i,2)))/sum(exp_a(f,i)(tails_a(f,i,1),tails_a(f,i,2))));
         more_comp_info(9)=more_comp_info(7)-more_comp_info(8);
         //  calc tails of distribution and Durbin-Watson for autocorrelation
         temp1=0.0;
         z=tails_a(f,i,1);
         cumdist_save=0.0;
         cumdist=0.0;
         for(z=tails_a(f,i,1);z<=tails_a(f,i,2);z++)
         {
          cumdist+=value(exp_a(f,i,z));
          if(cumdist>=0.05*more_comp_info(20) && cumdist_save<0.05*more_comp_info(20))  //  found bin for 5%
          {
            if(z==1)
            {more_comp_info(10)=age_bins(z);}  //  set to lower edge
            else
            {more_comp_info(10)=age_bins(z)+(age_bins(min(z+1,n_abins))-age_bins(z))*(0.05*more_comp_info(20)-cumdist_save)/(cumdist-cumdist_save);}
          }
          if(cumdist>=0.95*more_comp_info(20) && cumdist_save<0.95*more_comp_info(20))  //  found bin for 95%
          {
            more_comp_info(11)=age_bins(z)+(age_bins(min(z+1,n_abins))-age_bins(z))*(0.95*more_comp_info(20)-cumdist_save)/(cumdist-cumdist_save);
          }
          cumdist_save=cumdist;

          temp=obs_a(f,i,z)-exp_a(f,i,z);  //  obs-exp
          if(z>tails_a(f,i,1))
          {
            more_comp_info(12)+=value(square(temp2-temp));
            temp1+=value(square(temp));
          }
          temp2=temp; //  save current delta
         }
         more_comp_info(12)=(more_comp_info(12)/temp1) - 2.0;
       }
       if(gen_a(f,i)>=2 && gender==2)  // need males
       {
         more_comp_info(13)=(obs_a(f,i)(tails_a(f,i,3),tails_a(f,i,4))*age_bins_mean(tails_a(f,i,3),tails_a(f,i,4)))/sum(obs_a(f,i)(tails_a(f,i,3),tails_a(f,i,4)));
         more_comp_info(14)=value((exp_a(f,i)(tails_a(f,i,3),tails_a(f,i,4))*age_bins_mean(tails_a(f,i,3),tails_a(f,i,4)))/sum(exp_a(f,i)(tails_a(f,i,3),tails_a(f,i,4))));
         more_comp_info(15)=more_comp_info(13)-more_comp_info(14);
         //  calc tails of distribution and Durbin-Watson for autocorrelation
         temp1=0.0;
         z=tails_a(f,i,3);
         cumdist_save=0.0;
         cumdist=0.0;
         for(z=tails_a(f,i,3);z<=tails_a(f,i,4);z++)
         {
          cumdist+=value(exp_a(f,i,z));
          if(cumdist>=0.05*more_comp_info(20) && cumdist_save<0.05*more_comp_info(20))  //  found bin for 5%
          {
            if(z==n_abins+1)
            {more_comp_info(16)=age_bins(z);}  //  set to lower edge
            else
            {more_comp_info(16)=age_bins(z)+(age_bins(min(z+1,n_abins2))-age_bins(z))*(0.05*more_comp_info(20)-cumdist_save)/(cumdist-cumdist_save);}
          }
          if(cumdist>=0.95*more_comp_info(20) && cumdist_save<0.95*more_comp_info(20))  //  found bin for 95%
          {
            more_comp_info(17)=age_bins(z)+(age_bins(min(z+1,n_abins2))-age_bins(z))*(0.95*more_comp_info(20)-cumdist_save)/(cumdist-cumdist_save);
          }
          cumdist_save=cumdist;

          temp=obs_a(f,i,z)-exp_a(f,i,z);  //  obs-exp
          if(z>tails_a(f,i,1))
          {
            more_comp_info(18)+=value(square(temp2-temp));
            temp1+=value(square(temp));
          }
          temp2=temp; //  save current delta
         }
         more_comp_info(18)=(more_comp_info(18)/temp1) - 2.0;
       }
     }
     else
     {
        neff_a(f,i)=0.;
     }
     SS2out<<f<<" "<<header_a(f,i,1)<<" "<<abs(header_a(f,i,2))<<" "<<Show_Time2(ALK_time,2)<<" "<<data_time(ALK_time,f,3)<<" "<<gen_a(f,i)<<" "<<mkt_a(f,i)<<" "<<ageerr_type_a(f,i)<<" "<<Lbin_lo(f,i)<<" "<<Lbin_hi(f,i)<<" "<<nsamp_a(f,i)<<" "<<neff_a(f,i)<<" "<<
     age_like(f,i)<<" ";
     if(header_a(f,i,2)<0 && in_superperiod==0)
      {SS2out<<" start "; in_superperiod=1;}
      else if (header_a(f,i,2)<0 && in_superperiod==1)
      {SS2out<<" end "; in_superperiod=0;}
      else if (in_superperiod==1)
      {SS2out<<" in ";}
      else
      {SS2out<<" _ ";}
      if(header_a(f,i,3)<0 || nsamp_a(f,i)<0)
      {SS2out<<" skip ";}
      else
      {SS2out<<" _ ";}
      SS2out<<more_comp_info(1,6);
      if(gender==2) SS2out<<" "<<more_comp_info(7,20);
      SS2out<<endl;
     
    }

   SS2out<<endl<<"Age_Comp_Fit_Summary"<<endl;
   SS2out<<endl<<"Fleet N Npos min_inputN mean_effN mean(inputN*Adj) HarMean(effN) Mean(effN/inputN) MeaneffN/MeaninputN Var_Adj"<<endl;
   for(f=1;f<=Nfleet;f++)
   {
    if(n_rmse(f)>0) {rmse(f)/=n_rmse(f); mean_CV(f)/=n_rmse(f); Hrmse(f)=n_rmse(f)/Hrmse(f); Rrmse(f)/=n_rmse(f); }
    SS2out<<f;
    if(Nobs_a(f)>0)
    {SS2out<<" "<<Nobs_a(f)<<" "<<n_rmse(f)<<" "<<min_sample_size_A(f)<<" "<<rmse(f)<<" "<<mean_CV(f)<<" "<<Hrmse(f)<<" "<<Rrmse(f)<<" "<<rmse(f)/mean_CV(f)
    <<" "<<var_adjust(5,f)<<" "<<fleetname(f)<<endl;}
    else
    {SS2out<<" _ _ _ _ _ _ _ _ _ "<<endl;}
   }

  SS2out <<endl<< "FIT_SIZE_COMPS" << endl;                     // SS_Label_350
  rmse = 0.0;  n_rmse = 0.0; mean_CV=0.0;  Hrmse=0.0; Rrmse=0.0;
    if(SzFreq_Nmeth>0)       //  have some sizefreq data
    {
      SzFreq_effN.initialize();
      SzFreq_eachlike.initialize();
      SS2out<<"Fleet Yr Seas Method Sex Mkt Nsamp effN Like"<<endl;
      for (iobs=1;iobs<=SzFreq_totobs;iobs++)
      {
        y=SzFreq_obs_hdr(iobs,1);
        s=SzFreq_obs_hdr(iobs,2);
        f=abs(SzFreq_obs_hdr(iobs,3));
        gg=SzFreq_obs_hdr(iobs,4);  // gender
        k=SzFreq_obs_hdr(iobs,6);
        if(SzFreq_obs_hdr(iobs,3)>0)  // flag for date range in bounds
        {
          p=SzFreq_obs_hdr(iobs,5);  // partition
          z1=SzFreq_obs_hdr(iobs,7);
          z2=SzFreq_obs_hdr(iobs,8);
          if(SzFreq_obs_hdr(iobs,3)>0)
          {
          temp=0.0;
          temp1=0.0;
          for (z=z1;z<=z2;z++)
          {
            SzFreq_effN(iobs)+= value(SzFreq_exp(iobs,z)*(1.0-SzFreq_exp(iobs,z)));
            temp += square(SzFreq_obs(iobs,z)-SzFreq_exp(iobs,z));
            temp1 += SzFreq_obs(iobs,z)*log(SzFreq_obs(iobs,z))-SzFreq_obs(iobs,z)*log(SzFreq_exp(iobs,z));
          }
          SzFreq_effN(iobs) =(SzFreq_effN(iobs)+1.0e-06)/value((temp+1.0e-06));
          temp1*=SzFreq_sampleN(iobs);
          SzFreq_eachlike(iobs)=value(temp1);
            n_rmse(f)+=1.;
            rmse(f)+=SzFreq_effN(iobs);
            mean_CV(f)+=SzFreq_sampleN(iobs);
            Hrmse(f)+=1./SzFreq_effN(iobs);
            Rrmse(f)+=SzFreq_effN(iobs)/SzFreq_sampleN(iobs);
          }
          else
          {
            SzFreq_effN(iobs)=0.;
            SzFreq_eachlike(iobs)=0.;
          }
          SS2out<<f<<" "<<y<<" "<<s<<" "<<k<<" "<<gg<<" "<<p<<" "<<SzFreq_sampleN(iobs)<<" "<<SzFreq_effN(iobs)<<" "<<SzFreq_eachlike(iobs)<<endl;
        }
      }
      SS2out<<endl<<"Size_Comp_Fit_Summary"<<endl;
      SS2out<<endl<<"Fleet N Npos mean_effN mean(inputN*Adj) HarMean(effN) Mean(effN/inputN) MeaneffN/MeaninputN Var_Adj"<<endl;
      for (f=1;f<=Nfleet;f++)
      {
        if(n_rmse(f)>0)
        {
          rmse(f)/=n_rmse(f); mean_CV(f)/=n_rmse(f); Hrmse(f)=n_rmse(f)/Hrmse(f); Rrmse(f)/=n_rmse(f);
          SS2out<<f<<" "<<"NA"<<" "<<n_rmse(f)<<" "<<rmse(f)<<" "<<mean_CV(f)<<" "<<Hrmse(f)<<" "<<Rrmse(f)<<" "<<rmse(f)/mean_CV(f)
          <<" "<<var_adjust(4,f)<<" "<<fleetname(f)<<endl;
        }
      }
    }
    else
    {SS2out<<"#_none"<<endl;}

  SS2out<<"#"<<endl<<"OVERALL_COMPS"<<endl;
  SS2out<<"Fleet N_obs len_bins "<<len_bins_dat<<endl;
  for (f=1;f<=Nfleet;f++)
  {
    if(Nobs_l(f)>0)
    {
      SS2out<<f<<" "<<Nobs_l(f)<<" freq "<<obs_l_all(1,f)<<endl;
      SS2out<<f<<" "<<Nobs_l(f)<<" cum  "<<obs_l_all(2,f)<<endl;
    }
  }

  SS2out<<"Fleet N_obs age_bins ";
  if(n_abins>1)
  {
    SS2out<<age_bins(1,n_abins)<<endl;
    for (f=1;f<=Nfleet;f++)
    {
      if(Nobs_a(f)>0)
      {
        SS2out<<f<<" "<<Nobs_a(f)<<" freq "<<obs_a_all(1,f)<<endl;
        SS2out<<f<<" "<<Nobs_a(f)<<" cum  "<<obs_a_all(2,f)<<endl;
      }
    }
  }
  else
  {SS2out<<"No_age_bins_defined"<<endl;}

  SS2out <<"#"<<endl<<"LEN_SELEX"<<endl;
  SS2out << "Lsel_is_length_selectivity" << endl;     // SS_Label_370
  SS2out << "RET_is_retention" << endl;            // SS_Label_390
  SS2out << "MORT_is_discard_mortality" << endl;            // SS_Label_390
  SS2out << "KEEP_is_sel*retain" << endl;     // SS_Label_370
  SS2out << "DEAD_is_sel*(retain+(1-retain)*discmort)";     // SS_Label_370
  SS2out<<"; Year_styr-3_("<<styr-3<<")_stores_average_used_for_benchmark"<<endl;
  SS2out<<"Factor Fleet Yr Sex Label "<<len_bins_m<<endl;
  for (f=1;f<=Nfleet;f++)
  {
    k=styr-3; j=YrMax;
    for (y=k;y<=j;y++)
    for (gg=1;gg<=gender;gg++)
    if(y==styr-3 || y==endyr || y==YrMax || (y>=styr && (timevary_sel(y,f)>0 || timevary_sel(y+1,f)>0)))
    {
      SS2out<<"Lsel "<<f<<" "<<y<<" "<<gg<<" "<<y<<"_"<<f<<"_Lsel";
      for (z=1;z<=nlength;z++) {SS2out<<" "<<sel_l(y,f,gg,z);}
      SS2out<<endl;
    }
  }

  for (f=1;f<=Nfleet;f++)
  if(fleet_type(f)<=2)
  for (y=styr-3;y<=YrMax;y++)
  for (gg=1;gg<=gender;gg++)
  if(y==styr-3 || y==endyr || y==YrMax || (y>=styr && (timevary_sel(y,f)>0 || timevary_sel(y+1,f)>0)))
  {
    if(y>=styr && y<=endyr)
    {
      SS2out<<"Ret "<<f<<" "<<y<<" "<<gg<<" "<<y<<"_"<<f<<"_Ret";
      if(gg==1) {for (z=1;z<=nlength;z++) {SS2out<<" "<<retain(y,f,z);}}
      else
      {for (z=nlength1;z<=nlength2;z++) {SS2out<<" "<<retain(y,f,z);}}
      SS2out<<endl;
      SS2out<<"Mort "<<f<<" "<<y<<" "<<gg<<" "<<y<<"_"<<f<<"_Mort";
      if(gg==1) {for (z=1;z<=nlength;z++) {SS2out<<" "<<discmort(y,f,z);}}
      else
      {for (z=nlength1;z<=nlength2;z++) {SS2out<<" "<<discmort(y,f,z);}}
      SS2out<<endl;
    }
    SS2out<<"Keep "<<f<<" "<<y<<" "<<gg<<" "<<y<<"_"<<f<<"_Keep";
    for (z=1;z<=nlength;z++) {SS2out<<" "<<sel_l_r(y,f,gg,z);}
    SS2out<<endl;
    SS2out<<"Dead "<<f<<" "<<y<<" "<<gg<<" "<<y<<"_"<<f<<"_Dead";
    for (z=1;z<=nlength;z++) {SS2out<<" "<<discmort2(y,f,gg,z);}
    SS2out<<endl;
  }

  SS2out <<endl<< "AGE_SELEX" << endl;
  SS2out<<"Asel_is_age_selectivity_alone"<<endl;
  SS2out<<"Asel2_is_sizesel*size_at_age(ALK)"<<endl;
  SS2out<<"COMBINED_ALK*selL*selA*wtlen*ret*discmort_in_makefishsel_yr: "<<makefishsel_yr<<" With_MeanSel_From: "<<Fcast_Sel_yr1<<" - "<<Fcast_Sel_yr2;     // SS_Label_380
  SS2out<<"; Year_styr-3_("<<styr-3<<")_stores_average_used_for_benchmark"<<endl;

  SS2out<<"Factor Fleet Yr Seas Sex Morph Label ";
  for (a=0;a<=nages;a++) {SS2out<<" "<<a;}
  SS2out<<endl;
  for (f=1;f<=Nfleet;f++)
  {
    k=styr-3; j=YrMax;
    for (y=k;y<=j;y++)
    for (gg=1;gg<=gender;gg++)
    if(y==styr-3 || y==endyr || y==YrMax || (y>=styr && (timevary_sel(y,f+Nfleet)>0 || timevary_sel(y+1,f+Nfleet)>0)))
    {
      SS2out<<"Asel "<<f<<" "<<y<<" 1 "<<gg<<" 1 "<<y<<"_"<<f<<"Asel";
      for (a=0;a<=nages;a++) {SS2out<<" "<<sel_a(y,f,gg,a);}
      SS2out<<endl;
    }
  }

  if(reportdetail == 1)
  {
    if(Do_Forecast>0)
    {k=YrMax;}
    else
    {k=endyr;}
    for (y=styr-3;y<=k;y++)
    for (s=1;s<=nseas;s++)
    {
      t=styr+(y-styr)*nseas+s-1;
      for (g=1;g<=gmorph;g++)
      if(use_morph(g)>0 && (y==styr-3 || y>=styr))
      {
        if(s==spawn_seas && (sx(g)==1 || Hermaphro_Option!=0) ) SS2out<<"Fecund "<<" NA "<<" "<<y<<" "<<s<<" "<<sx(g)<<" "<<g<<" "<<y<<"_"<<"Fecund"<<save_sel_fec(t,g,0)<<endl;
        for (f=1;f<=Nfleet;f++)
        {
          SS2out<<"Asel2 "<<f<<" "<<y<<" "<<s<<" "<<sx(g)<<" "<<g<<" "<<y<<"_"<<f<<"_Asel2"<<save_sel_fec(t,g,f)<<endl;
          SS2out<<"bodywt "<<f<<" "<<y<<" "<<s<<" "<<sx(g)<<" "<<g<<" "<<y<<"_"<<f<<"_bodywt"<<fish_body_wt(t,g,f)<<endl;
        }
      }
    }
      y=makefishsel_yr;
      for (f=1;f<=Nfleet;f++)
      if(fleet_type(f)<=2)
       for (g=1;g<=gmorph;g++)
       if(use_morph(g)>0)
       for (s=1;s<=nseas;s++)
        {
        SS2out<<"sel*wt "<<f<<" "<<y<<" "<<s<<" "<<sx(g)<<" "<<g<<" "<<y<<"_"<<f<<"_sel*wt"<<sel_al_1(s,g,f)<<endl;
        SS2out<<"sel*ret*wt "<<f<<" "<<y<<" "<<s<<" "<<sx(g)<<" "<<g<<" "<<y<<"_"<<f<<"_sel*ret*wt"<<sel_al_2(s,g,f)<<endl;
        SS2out<<"sel_nums "<<f<<" "<<y<<" "<<s<<" "<<sx(g)<<" "<<g<<" "<<y<<"_"<<f<<"_sel_nums"<<sel_al_3(s,g,f)<<endl;
        SS2out<<"sel*ret_nums "<<f<<" "<<y<<" "<<s<<" "<<sx(g)<<" "<<g<<" "<<y<<"_"<<f<<"_sel*ret_nums"<<sel_al_4(s,g,f)<<endl;
        SS2out<<"dead_nums "<<f<<" "<<y<<" "<<s<<" "<<sx(g)<<" "<<g<<" "<<y<<"_"<<f<<"_dead_nums"<<deadfish(s,g,f)<<endl;
        SS2out<<"dead*wt "<<f<<" "<<y<<" "<<s<<" "<<sx(g)<<" "<<g<<" "<<y<<"_"<<f<<"_dead*wt"<<deadfish_B(s,g,f)<<endl;
        }
    }

   if(N_envvar>0)
   {
   SS2out << endl<<"ENVIRONMENTAL_DATA Begins_in_startyr-1, which shows the base value to which other years are scaled"<<endl;         // SS_Label_397
   SS2out<<"Yr rel_smrynum rel_smrybio exp(recdev) rel_SSB null "; for (i=1;i<=N_envvar;i++) SS2out<<" env:_"<<i;
   SS2out<<endl;
    for (y=styr-1;y<=YrMax;y++)
    {
     SS2out<<y<<" "<<env_data(y)<<endl;
    }
    SS2out<<endl;
   }

 if(Do_TG>0)
  {
     SS2out<<endl<<"TAG_Recapture"<<endl;
     SS2out<<TG_mixperiod<<" First period to use recaptures in likelihood"<<endl;
     SS2out<<TG_maxperiods<<" Accumulation period"<<endl;

     SS2out<<" Tag_release_info"<<endl;
    SS2out<<"TAG Area Yr Seas Time Sex Age Nrelease Init_Loss Chron_Loss"<<endl;;
    for (TG=1;TG<=N_TG;TG++)
    {
      SS2out<<TG<<" "<<TG_release(TG)(2,8)<<" "<<TG_save(TG)(1,2)<<endl;
    }
    SS2out<<"Tags_Alive ";
    k=max(TG_endtime);
    for (t=0;t<=k;t++) SS2out<<t<<" ";
    SS2out<<endl;
    for (TG=1;TG<=N_TG;TG++)
    {
      SS2out<<TG<<" "<<TG_save(TG)(3,3+TG_endtime(TG))<<endl;
    }
    SS2out<<"Total_recaptures ";
    for (t=0;t<=k;t++) SS2out<<t<<" ";
    SS2out<<endl;
    for (TG=1;TG<=N_TG;TG++)
    {
      SS2out<<TG<<" ";
      for (TG_t=0;TG_t<=TG_endtime(TG);TG_t++) SS2out<<TG_recap_exp(TG,TG_t,0)<<" ";
      SS2out<<endl;
    }

    SS2out<<endl<<"Reporting_Rates_by_Fishery"<<endl<<"Fleet Init_Reporting Report_Decay"<<endl;
    for (f=1;f<=Nfleet;f++) SS2out<<f<<" "<<TG_report(f)<<" "<<TG_rep_decay(f)<<endl;
    SS2out<<"See_composition_data_output_for_tag_recapture_details"<<endl;
  }


// ************************                     SS_Label_400
    SS2out << endl << "NUMBERS_AT_AGE" << endl;       // SS_Label_410
    SS2out << "Area Bio_Pattern Sex BirthSeason Settlement Platoon Morph Yr Seas Time Beg/Mid Era"<<age_vector <<endl;
  if(reportdetail == 1)
  {
    for (p=1;p<=pop;p++)
    for (g=1;g<=gmorph;g++)
    if(use_morph(g)>0)
      {
      for (y=styr-2;y<=YrMax;y++)
      for (s=1;s<=nseas;s++)
       {
       t = styr+(y-styr)*nseas+s-1;
       temp=double(y)+azero_seas(s);
       SS2out <<p<<" "<<GP4(g)<<" "<<sx(g)<<" "<<Bseas(g)<<" "<<settle_g(g)<<" "<<GP2(g)<<" "<<g<<" "<<y<<" "<<s<<" "<<temp<<" B";
       if(y==styr-2)
         {SS2out<<" VIRG ";}
       else if (y==styr-1)
         {SS2out<<" INIT ";}
       else if (y<=endyr)
         {SS2out<<" TIME ";}
       else
         {SS2out<<" FORE ";}
       SS2out<<natage(t,p,g)<<endl;
       temp=double(y)+azero_seas(s)+seasdur_half(s);
       SS2out <<p<<" "<<GP4(g)<<" "<<sx(g)<<" "<<Bseas(g)<<" "<<settle_g(g)<<" "<<GP2(g)<<" "<<g<<" "<<y<<" "<<s<<" "<<temp<<" M";
       if(y==styr-2)
         {SS2out<<" VIRG ";}
       else if (y==styr-1)
         {SS2out<<" INIT ";}
       else if (y<=endyr)
         {SS2out<<" TIME ";}
       else
         {SS2out<<" FORE ";}
       SS2out<<Save_PopAge(t,p+pop,g)<<endl;
       }
      }

    SS2out << endl << "BIOMASS_AT_AGE" << endl;       // SS_Label_410
    SS2out << "Area Bio_Pattern Sex BirthSeason Settlement Platoon Morph Yr Seas Time Beg/Mid Era"<<age_vector <<endl;
    for (p=1;p<=pop;p++)
    for (g=1;g<=gmorph;g++)
    if(use_morph(g)>0)
      {
      for (y=styr-2;y<=YrMax;y++)
      for (s=1;s<=nseas;s++)
       {
       t = styr+(y-styr)*nseas+s-1;
       temp=double(y)+azero_seas(s);
       SS2out <<p<<" "<<GP4(g)<<" "<<sx(g)<<" "<<Bseas(g)<<" "<<settle_g(g)<<" "<<GP2(g)<<" "<<g<<" "<<y<<" "<<s<<" "<<temp<<" B";
       if(y==styr-2)
         {SS2out<<" VIRG ";}
       else if (y==styr-1)
         {SS2out<<" INIT ";}
       else if (y<=endyr)
         {SS2out<<" TIME ";}
       else
         {SS2out<<" FORE ";}
       SS2out<<Save_PopBio(t,p,g)<<endl;
       temp=double(y)+azero_seas(s)+seasdur_half(s);
       SS2out <<p<<" "<<GP4(g)<<" "<<sx(g)<<" "<<Bseas(g)<<" "<<settle_g(g)<<" "<<GP2(g)<<" "<<g<<" "<<y<<" "<<s<<" "<<temp<<" M";
       if(y==styr-2)
         {SS2out<<" VIRG ";}
       else if (y==styr-1)
         {SS2out<<" INIT ";}
       else if (y<=endyr)
         {SS2out<<" TIME ";}
       else
         {SS2out<<" FORE ";}
       SS2out<<Save_PopBio(t,p+pop,g)<<endl;
       }
      }

    SS2out << endl << "NUMBERS_AT_LENGTH" << endl;
    SS2out << "Area Bio_Pattern Sex BirthSeason Settlement Platoon Morph Yr Seas Time Beg/Mid Era "<<len_bins <<endl;
    for (p=1;p<=pop;p++)
    for (g=1;g<=gmorph;g++)
    if(use_morph(g)>0)
      {
      for (y=styr;y<=YrMax;y++)
      for (s=1;s<=nseas;s++)
       {
       t = styr+(y-styr)*nseas+s-1;
       temp=double(y)+azero_seas(s);
       SS2out <<p<<" "<<GP4(g)<<" "<<sx(g)<<" "<<Bseas(g)<<" "<<settle_g(g)<<" "<<GP2(g)<<" "<<g<<" "<<y<<" "<<s<<" "<<temp<<" B ";
       if(y==styr-2)
         {SS2out<<" VIRG ";}
       else if (y==styr-1)
         {SS2out<<" INIT ";}
       else if (y<=endyr)
         {SS2out<<" TIME ";}
       else
         {SS2out<<" FORE ";}
       SS2out<< Save_PopLen(t,p,g) << endl;
       temp=double(y)+azero_seas(s)+seasdur_half(s);
       SS2out <<p<<" "<<GP4(g)<<" "<<sx(g)<<" "<<Bseas(g)<<" "<<settle_g(g)<<" "<<GP2(g)<<" "<<g<<" "<<y<<" "<<s<<" "<<temp<<" M ";
       if(y==styr-2)
         {SS2out<<" VIRG ";}
       else if (y==styr-1)
         {SS2out<<" INIT ";}
       else if (y<=endyr)
         {SS2out<<" TIME ";}
       else
         {SS2out<<" FORE ";}
       SS2out<< Save_PopLen(t,p+pop,g) << endl;
       }
      }

    SS2out << endl << "BIOMASS_AT_LENGTH" << endl;
    SS2out << "Area Bio_Pattern Sex BirthSeason Settlement Platoon Morph Yr Seas Time Beg/Mid Era "<<len_bins <<endl;
    for (p=1;p<=pop;p++)
    for (g=1;g<=gmorph;g++)
    if(use_morph(g)>0)
      {
      for (y=styr;y<=YrMax;y++)
      for (s=1;s<=nseas;s++)
       {
       t = styr+(y-styr)*nseas+s-1;
       temp=double(y)+azero_seas(s);
       SS2out <<p<<" "<<GP4(g)<<" "<<sx(g)<<" "<<Bseas(g)<<" "<<settle_g(g)<<" "<<GP2(g)<<" "<<g<<" "<<y<<" "<<s<<" "<<temp<<" B ";
       if(y==styr-2)
         {SS2out<<" VIRG ";}
       else if (y==styr-1)
         {SS2out<<" INIT ";}
       else if (y<=endyr)
         {SS2out<<" TIME ";}
       else
         {SS2out<<" FORE ";}
       SS2out<< Save_PopWt(t,p,g) << endl;
       temp=double(y)+azero_seas(s)+seasdur_half(s);
       SS2out <<p<<" "<<GP4(g)<<" "<<sx(g)<<" "<<Bseas(g)<<" "<<settle_g(g)<<" "<<GP2(g)<<" "<<g<<" "<<y<<" "<<s<<" "<<temp<<" M ";
       if(y==styr-2)
         {SS2out<<" VIRG ";}
       else if (y==styr-1)
         {SS2out<<" INIT ";}
       else if (y<=endyr)
         {SS2out<<" TIME ";}
       else
         {SS2out<<" FORE ";}
       SS2out<< Save_PopWt(t,p+pop,g) << endl;
       }
      }

     SS2out <<endl<< "CATCH_AT_AGE" << endl;              // SS_Label_420
     SS2out << "Area Fleet Sex  XX XX Morph Yr Seas XX Era"<<age_vector <<endl;
     for (f=1;f<=Nfleet;f++)
     if(fleet_type(f)<=2)
     for (g=1;g<=gmorph;g++)
     {
     if(use_morph(g)>0)
     {
       for (y=styr-1;y<=YrMax;y++)
       for (s=1;s<=nseas;s++)
       {
         t = styr+(y-styr)*nseas+s-1;
         SS2out <<fleet_area(f)<<" "<<f<<" "<<sx(g)<<" XX XX "<<g<<" "<<y<<" "<<s;
         if(y==styr-1)
           {SS2out<<" XX INIT ";}
         else if (y<=endyr)
           {SS2out<<" XX TIME ";}
         else
           {SS2out<<" XX FORE ";}
         SS2out<<catage(t,f,g)<< endl;
       }
     }
    }
  }

  SS2out <<endl<< "BIOLOGY "<<sum(use_morph)<<" "<<nlength<<" "<<nages<<" "<<nseas<<" N_Used_morphs;_lengths;_ages;_season;_by_season_in_endyr" << endl;
   SS2out<<"GP Bin Low Mean_Size Wt_len_F Mat_len Spawn Wt_len_M Fecundity"<<endl;
   for(gp=1;gp<=N_GP;gp++)
   for (z=1;z<=nlength;z++)
     {
      SS2out<<gp<<" "<<z<<" "<<len_bins(z)<<" "<<len_bins_m(z)<<" "<<wt_len(1,gp,z)<<" "<<mat_len(gp,z)<<" "<<mat_fec_len(gp,z);
      if(gender==2) {SS2out<<" "<<wt_len(1,N_GP+gp,z);}
      SS2out<<" "<<fec_len(gp,z)<<endl;
     }

    SS2out<<endl<<"Natural_Mortality Method:_"<<natM_type<<endl<<"Bio_Pattern Sex Settlement Seas "<<age_vector<<endl;
      g=0;
      for (gg=1;gg<=gender;gg++)
      for (gp=1;gp<=N_GP;gp++)
      for (settle=1;settle<=N_settle_timings;settle++)
      {
        g++;
        if(use_morph(g)>0)
        {for (s=1;s<=nseas;s++) SS2out<<gp<<" "<<gg<<" "<<settle<<" "<<s<<" "<<natM(s,g)<<endl;}
      }

    SS2out<<endl<<"Natural_Mortality_Bmark"<<endl<<"Bio_Pattern Sex Settlement Seas "<<age_vector<<endl;
      g=0;
      for (gg=1;gg<=gender;gg++)
      for (gp=1;gp<=N_GP;gp++)
      for (settle=1;settle<=N_settle_timings;settle++)
      {
        g++;
        if(use_morph(g)>0)
        {for (s=1;s<=nseas;s++) SS2out<<gp<<" "<<gg<<" "<<settle<<" "<<s<<" "<<natM_Bmark(s,g)/(Bmark_Yr(2)-Bmark_Yr(1)+1)<<endl;}
      }

    SS2out<<endl<<"Natural_Mortality_endyr"<<endl<<"Bio_Pattern Sex Settlement Seas "<<age_vector<<endl;
      g=0;
      for (gg=1;gg<=gender;gg++)
      for (gp=1;gp<=N_GP;gp++)
      for (settle=1;settle<=N_settle_timings;settle++)
      {
        g++;
        if(use_morph(g)>0)
        {for (s=1;s<=nseas;s++) SS2out<<gp<<" "<<gg<<" "<<settle<<" "<<s<<" "<<natM_endyr(s,g)<<endl;}
      }

    if(Grow_type==3)  //  age-specific K
    {
    SS2out<<endl<<"Age_Specific_K"<<endl<<"Bio_Pattern Sex "<<age_vector<<endl;
      g=0;
      for (gg=1;gg<=gender;gg++)
      for (gp=1;gp<=N_GP;gp++)
      {
        g++;
        SS2out<<gp<<" "<<gg<<" "<<-VBK(g)<<endl;
      }
    }

   SS2out<<endl<<"Growth_Parameters"<<endl<<" Count Yr Sex Platoon A1 A2 L_a_A1 L_a_A2 K A_a_L0 Linf CVmin CVmax natM_amin natM_max M_age0 M_nages"
   <<" WtLen1 WtLen2 Mat1 Mat2 Fec1 Fec2"<<endl;
   for (g=1;g<=save_gparm_print;g++) {SS2out<<save_G_parm(g)(1,2)<<" "<<sx(save_G_parm(g,3))<<" "<<save_G_parm(g)(3,22)<<endl;}

   if(MGparm_doseas>0)
    {
   SS2out<<endl<<"Seas_Effects"<<endl<<"Seas F_wtlen1 F_wtlen2 F_mat1 F_mat2 F_fec1 F_fec2 M_wtlen1 M_wtlen2 L_a_A1 VBK"<<endl;
      for (s=1;s<=nseas;s++)
      {
        SS2out<<s<<" "<<save_seas_parm(s)<<endl;
      }
    }
    dvariable Herma_Cum;

//    restore_AgeLength_Key to endyr, otherwise it will have ALK from end of forecast
      if(timevary_MG(endyr,2)>0 || timevary_MG(endyr,3)>0 || WTage_rd>0)
      {
        y=endyr;
        t_base=styr+(y-styr)*nseas-1;
        for (s=1;s<=nseas;s++)
        {
          t = t_base+s;
          bio_t=styr+(endyr-styr)*nseas+s-1;
          subseas=1;
          ALK_idx=(s-1)*N_subseas+subseas;
          get_growth3(s, subseas);
          Make_AgeLength_Key(s, subseas);  //  for begin season
          subseas=mid_subseas;
          ALK_idx=(s-1)*N_subseas+subseas;
          get_growth3(s, subseas);
          Make_AgeLength_Key(s, subseas);  //  for midseason
          if(s==spawn_seas)
          {
            subseas=spawn_subseas;
            ALK_idx=(s-1)*N_subseas+subseas;
            if(spawn_subseas!=1 && spawn_subseas!=mid_subseas)
            {
              get_growth3(s, subseas);
              Make_AgeLength_Key(s, subseas);  //  spawn subseas
            }
            Make_Fecundity();
          }
        }
      }

   SS2out<<endl<<"Biology_at_age_in_endyr_with_";
   switch(CV_depvar)
   {
   case 0:
   {SS2out<<"CV=f(LAA)"; break;}
   case 1:
   {SS2out<<"CV=F(A)"; break;}
   case 2:
   {SS2out<<"SD=F(LAA)"; break;}
   case 3:
   {SS2out<<"SD=F(A)"; break;}
   case 4:
   {SS2out<<"logSD=f(A)"; break;}
  }

   SS2out<<endl;
   SS2out<<"Seas Morph Bio_Pattern Sex Settlement Platoon int_Age Real_Age Age_Beg Age_Mid M Len_Beg Len_Mid SD_Beg SD_Mid Wt_Beg Wt_Mid Len_Mat Age_Mat Mat*Fecund Mat_F_wtatage Mat_F_Natage";
   if(Hermaphro_Option!=0) SS2out<<" Herma_Trans Herma_Cum ";
   for (f=1;f<=Nfleet;f++) SS2out<<" Len:_"<<f<<" SelWt:_"<<f<<" RetWt:_"<<f;
   SS2out<<endl;
   for (s=1;s<=nseas;s++)
   {
      t = styr+(endyr-styr)*nseas+s-1;
      ALK_idx=(s-1)*N_subseas+1;  // for first subseas of season
      ALK_idx_mid=(s-1)*N_subseas+mid_subseas;  // for midsubseas of the season
     for (g=1;g<=gmorph;g++)
     if(use_morph(g)>0)
     {
     Herma_Cum=femfrac(GP(g));
     for (a=0;a<=nages;a++)
     {

      SS2out<<s<<" "<<g<<" "<<GP4(g)<<" "<<sx(g)<<" "<<settle_g(g)<<" "<<GP2(g)<<" "<<a<<" "<<real_age(g,ALK_idx,a)<<" "<<calen_age(g,ALK_idx,a)<<" "<<calen_age(g,ALK_idx_mid,a);
      SS2out<<" "<<natM(s,GP3(g),a)<<" "<<Ave_Size(t,1,g,a)<<" "<<Ave_Size(t,mid_subseas,g,a)<<" "
        <<Sd_Size_within(ALK_idx,g,a)<<" "<<Sd_Size_within(ALK_idx_mid,g,a)<<" "
      <<Wt_Age_beg(s,g,a)<<" "<<Wt_Age_mid(s,g,a)<<" "<<ALK(ALK_idx,g,a)*mat_len(GP4(g))<<" ";
      if(Maturity_Option<=2)
        {SS2out<<mat_age(GP4(g),a);}
      else if(sx(g)==1 && Maturity_Option<5)
        {SS2out<<Age_Maturity(GP4(g),a);}
      else
        {SS2out<<-1.;}
      SS2out<<" "<<fec(g,a)<<" "<<make_mature_bio(g,a)<<" "<<make_mature_numbers(g,a);
      if(Hermaphro_Option!=0)
      {
        if(a>1) Herma_Cum*=(1.0-Hermaphro_val(GP4(g),a-1));
        SS2out<<" "<<Hermaphro_val(GP4(g),a)<<" "<<Herma_Cum;
      }
      if(WTage_rd==0)
      {
        for (f=1;f<=Nfleet;f++) SS2out<<
        " "<<ALK(ALK_idx_mid,g,a)*elem_prod(sel_l(endyr,f,sx(g)),len_bins_m)/(ALK(ALK_idx_mid,g,a)*sel_l(endyr,f,sx(g)))<<
        " "<<ALK(ALK_idx_mid,g,a)*elem_prod(sel_l(endyr,f,sx(g)),wt_len(s,GP(g)))/(ALK(ALK_idx_mid,g,a)*sel_l(endyr,f,sx(g)))<<
        " "<<ALK(ALK_idx_mid,g,a)*elem_prod(sel_l_r(endyr,f,sx(g)),wt_len(s,GP(g)))/(ALK(ALK_idx_mid,g,a)*sel_l_r(endyr,f,sx(g)));
      }
      else
      {
        for (f=1;f<=Nfleet;f++) SS2out<<
        " "<<ALK(ALK_idx_mid,g,a)*elem_prod(sel_l(endyr,f,sx(g)),len_bins_m)/(ALK(ALK_idx_mid,g,a)*sel_l(endyr,f,sx(g)))<<
        " "<<WTage_emp(t,GP3(g),f,a)<<" "<<WTage_emp(t,GP3(g),f,a);
      }
      SS2out<<endl;
      }}}


  SS2out <<endl<< "MEAN_BODY_WT(begin)";
  if(WTage_rd>0) SS2out<<" as read from wtatage.ss";
  SS2out<<" #NOTE_yr=_"<<styr-3<<"_stores_values_for_benchmark"<<endl;
  SS2out <<"Morph Yr Seas"<<age_vector<<endl;
  if(reportdetail == 1)
  {

    for (g=1;g<=gmorph;g++)
    if(use_morph(g)>0)
    {
    for (y=styr-3;y<=YrMax;y++)
    {
      yz=y;   if(yz>endyr+2) yz=endyr+2;
//    if(y==styr-3 || y==styr || timevary_MG(yz,2)>0 || timevary_MG(yz,3)>0 || WTage_rd>0)  // if growth or wtlen parms have changed
    for (s=1;s<=nseas;s++)
     {
      t = styr+(y-styr)*nseas+s-1;
       SS2out<<g<<" "<<y<<" "<<s<<" "<<Save_Wt_Age(t,g)<<endl;
     }
    }
  }
  }

  SS2out <<endl<< "MEAN_SIZE_TIMESERIES" << endl;           // SS_Label_450
  SS2out <<"Morph Yr Seas SubSeas"<<age_vector<<endl;
  if(reportdetail == 1)
  {
    for (g=1;g<=gmorph;g++)
    if(use_morph(g)>0)
    {
      for (y=styr-3;y<=YrMax;y++)
      {
        yz=y;   if(yz>endyr+2) yz=endyr+2;
//        if(y==styr-3 || y==styr ||  timevary_MG(yz,2)>0)
        {
          for (s=1;s<=nseas;s++)
          {
            t = styr+(y-styr)*nseas+s-1;
            for (i=1;i<=N_subseas;i++)
            {
               SS2out<<g<<" "<<y<<" "<<s<<" "<<i<<" "<< Ave_Size(t,i,g)<<endl;
            }
           }
        }
      }
    }
    s=1;
    for (i=1;i<=gender;i++)
    {
      SS2out<<endl<<"mean_size_Jan_1_for_sex: "<<i<<" NOTE:_combines_all_settlements_areas_GP_and_platoons"<<endl;
      SS2out <<"Sex Yr Seas Beg "<<age_vector<<endl;
      for (y=styr;y<=YrMax;y++)
      {
        yz=y;   if(yz>endyr+2) yz=endyr+2;
        if(y<=styr || timevary_MG(yz,2)>0 || N_platoon>1)
        {
          t = styr+(y-styr)*nseas+s-1;
          SS2out<<i<<" "<<y<<" "<<s<<" "<<0;
          for (a=0;a<=nages;a++)
          {
            temp=0.0;
            temp1=0.0;
            for (g=1;g<=gmorph;g++)
            {
              if(sx(g)==i && use_morph(g)>0)
              {
                for (p=1;p<=pop;p++)
                {
                  temp+=natage(t,p,g,a);
                  temp1+=Ave_Size(t,1,g,a)*natage(t,p,g,a);
                }  // end loop of areas
              }  //  end need to use this gender/platoon
            }  //  end loop of all platoons
            if(temp>0.0) {SS2out <<" "<< temp1/temp;} else {SS2out<<" __";}
          }  //  end loop of ages
          SS2out<<endl;
        }  // end need to report this year
      }  // end year loop
    }  // end gender loop
  }  //   end do report detail

  SS2out <<endl<< "AGE_LENGTH_KEY"<<" #sub_season";
  if(reportdetail == 1)
  {
  if(Grow_logN==1) SS2out<<" #Lognormal ";
  SS2out<<endl;               // SS_Label_460
  SS2out<<" sdratio "<<sd_ratio<<endl;
  SS2out<<" sdwithin "<<sd_within_platoon<<endl;
  SS2out<<" sdbetween "<<sd_between_platoon<<endl;
   for (s=1;s<=nseas;s++)
   for (subseas=1;subseas<=N_subseas;subseas++)
   for (g=1;g<=gmorph;g++)
   if(use_morph(g)>0)
   {
    t = styr+(endyr-styr)*nseas+s-1;
    ALK_idx=(s-1)*N_subseas+subseas;
    SS2out <<endl<<" Seas: "<<s<<" Sub_Seas: "<<subseas<<"   Morph: "<<g<<endl;
    SS2out <<"Age:";
    for (a=0;a<=nages;a++) SS2out << " "<<a;
    SS2out<<endl;
    for (z=nlength;z>=1;z--)
     {
      SS2out << len_bins2(z) << " ";
      for (a=0;a<=nages;a++)
        SS2out << ALK(ALK_idx,g,a,z) << " " ;
      SS2out<<endl;
     }
      SS2out<<"mean " << Ave_Size(t,subseas,g) << endl;
      SS2out<<"sdsize " << Sd_Size_within(ALK_idx,g) << endl;
       }
  }

    SS2out <<endl<< "AGE_AGE_KEY"<<endl;              // SS_Label_470
  if(reportdetail == 1)
  {
    if(N_ageerr>0)
    {
      for (k=1;k<=N_ageerr;k++)
      {
      SS2out << "KEY: "<<k<<endl<< "mean " << age_err(k,1) << endl<< "SD " << age_err(k,2) << endl;
      for (b=n_abins;b>=1;b--)
       {
        SS2out << age_bins(b) << " ";
        for (a=0;a<=nages;a++)
          SS2out << age_age(k,b,a) << " " ;
        SS2out<<endl;
         }
       if(gender==2)
       {
       L2=n_abins;
       A2=nages+1;
      for (b=n_abins;b>=1;b--)
       {
        SS2out << age_bins(b) << " ";
        for (a=0;a<=nages;a++)
          SS2out << age_age(k,b+L2,a+A2) << " " ;
        SS2out<<endl;
         }
       }
      }
    }
    else
    {
      SS2out<<"no_age_error_key_used"<<endl;
    }
  }

 /* SS_Label_xxx report the composition database to CompReport.sso */
  int last_t;
  SS_compout<<endl<<"Size_Bins_pop;_(Pop_len_mid_used_for_calc_of_selex_and_bio_quantities)"<<endl;
  SS_compout<<"Pop_Bin: ";
  for (j=1;j<=nlength;j++) SS_compout<<" "<<j;
  SS_compout<<endl<<"Length: "<<len_bins<<endl;
  SS_compout<<"Len_mid: "<<len_bins_m<<endl;
  SS_compout<<"Size_Bins_dat;_(Data_len_mid_for_reporting_only)"<<endl;
  SS_compout<<"Data_Bin: ";
  for (j=1;j<=nlen_bin;j++) SS_compout<<" "<<j;
  SS_compout<<endl<<"Length: "<<len_bins_dat<<endl;
  SS_compout<<"Len_mid: "<<len_bins_dat_m<<endl;

  SS_compout<<"Combine_males_with_females_thru_sizedata_bin "<<CombGender_L<<endl;
//  SS_compout<<"Size:"<<len_bins_dat(CombGender_L)<<endl;
  SS_compout<<"Combine_males_with_females_thru_Age_Data_bin: "<<CombGender_A<<endl;
//  SS_compout<<"Age: "<<age_bins(CombGender_A)<<endl;
  SS_compout<<endl<<"Method_for_Lbin_definition_for_agecomp_data: "<<Lbin_method<<endl;

  SS_compout<<"For_Sizefreq,_Lbin_Lo_is_units(bio_or_numbers);_Lbin_hi_is_scale(kg,_lb,_cm,_in),_Ageerr_is_method"<<endl;
  SS_compout<<"Yr.frac_is_fraction_of_year_based_on_subseas"<<endl;
  SS_compout<<"For_Tag_output,_Rep_contains_Tag_Group,_Bin_is_fleet_for_TAG1_and_Bin_is_Year.Seas_for_TAG2"<<endl;
  SS_compout<<"Column_Super?_indicates_super-periods;_column_used_indicates_inclusion_in_logL"<<endl;

  SS_compout <<endl<< "Composition_Database" << endl;           // SS_Label_480
  SS_compout<<"Yr Seas Yr.frac Fleet Rep Pick_sex Kind Part Ageerr Sex Lbin_lo Lbin_hi Bin Obs Exp Pearson N effN Like Cum_obs Cum_exp SuprPer Used?"<<endl;
  int lasttime;
  int lastfleet;
  int repli;
  int N_out;
  N_out=0;
  lasttime=0;
  lastfleet=0;

  for (f=1;f<=Nfleet;f++)
  {

 /* SS_Label_xxx  output lengthcomp to CompReport.sso */
    {
    data_type=4;  // for size comp
    in_superperiod=0;
    repli=0;
    last_t=-999;
    for (i=1;i<=Nobs_l(f);i++)                          // loop obs in this type/time
    {
      N_out++;
      t=Len_time_t(f,i);
      ALK_time=Len_time_ALK(f,i);
      temp2=0.0;
      temp1=0.0;
      if(t==last_t)
      {repli++;}
      else
      {repli=1;last_t=t;}
      if(header_l(f,i,2)<0 && in_superperiod==0)
      {in_superperiod=1; anystring="Sup";}
      else if (header_l(f,i,2)<0 && in_superperiod>0)
      {anystring="Sup"; in_superperiod=0;}
      else if (in_superperiod>0)
      {in_superperiod++; anystring="Sup";}
      else
      {anystring="_";}
      if(header_l(f,i,3)<0)
      {anystring+=" skip";}
      else
      {anystring+=" _";}
      if(gen_l(f,i)!=2)
      {
        s_off=1;
        for (z=tails_l(f,i,1);z<=tails_l(f,i,2);z++)
        {
            SS_compout<<Show_Time(t,1)<<" "<<Show_Time(t,2)<<" "<<data_time(ALK_time,f,3)<<" "<<f<<" "<<repli<<" "<<gen_l(f,i)<<" LEN "<<mkt_l(f,i)<<" 0 "<<s_off<<" "<<
            1<<" "<<1<<" "<<len_bins_dat2(z)<<" "<<obs_l(f,i,z)<<" "<<exp_l(f,i,z)<<" ";
            temp2+=obs_l(f,i,z);
            temp1+=exp_l(f,i,z);
            if(nsamp_l(f,i)>0 && header_l(f,i,3)>0)
            {
              if(exp_l(f,i,z)!=0.0 && exp_l(f,i,z)!=1.0)
              {
                if(Comp_Err_L(f)==0) SS_compout<<value((obs_l(f,i,z)-exp_l(f,i,z))/sqrt( exp_l(f,i,z) * (1.0-exp_l(f,i,z)) / sfabs(nsamp_l(f,i)))); // Pearson for multinomial
                if(Comp_Err_L(f)==1){
                  dirichlet_Parm=mfexp(selparm(Comp_Err_Parm_Start+Comp_Err_L2(f)))*nsamp_l(f,i);
                  SS_compout<<value( (obs_l(f,i,z)-exp_l(f,i,z))/sqrt( exp_l(f,i,z) * (1.0-exp_l(f,i,z)) / sfabs(nsamp_l(f,i)) * (sfabs(nsamp_l(f,i))+dirichlet_Parm)/(1.+dirichlet_Parm) ) );  // Pearson for Dirichlet-multinomial using negative-exponential parameterization
                }
                if(Comp_Err_L(f)==2){
                  dirichlet_Parm=mfexp(selparm(Comp_Err_Parm_Start+Comp_Err_L2(f)));
                  SS_compout<<value( (obs_l(f,i,z)-exp_l(f,i,z))/sqrt( exp_l(f,i,z) * (1.0-exp_l(f,i,z)) / sfabs(nsamp_l(f,i)) * (sfabs(nsamp_a(f,i))+dirichlet_Parm)/(1.+dirichlet_Parm) ) ); // Pearson for Dirichlet-multinomial using harmonic sum parameterization
                }
              }
              else
              {SS_compout<<" NA ";}
              SS_compout<<" "<<nsamp_l(f,i)<<" "<<neff_l(f,i)<<" ";
              if(obs_l(f,i,z)!=0.0 && exp_l(f,i,z)!=0.0)
              {SS_compout<<" "<<value(obs_l(f,i,z)*log(obs_l(f,i,z)/exp_l(f,i,z))*nsamp_l(f,i));}
              else
              {SS_compout<<" NA ";}
            }
            else
            {SS_compout<<" NA NA NA NA ";}
         SS_compout<<" "<<temp2<<" "<<temp1<<" "<<anystring<<endl;
        }

        SS_compout<<Show_Time(t,1)<<" "<<Show_Time(t,2)<<" "<<data_time(ALK_time,f,3)<<" "<<f<<" "<<repli<<" "<<gen_l(f,i)<<" LEN "
        <<mkt_l(f,i)<<" 0 "<<s_off<<" "<<1<<" "<<1<<endl;
      }
      if(gen_l(f,i)>=2 && gender==2)  // do males
      {
        s_off=2;
        for (z=tails_l(f,i,3);z<=tails_l(f,i,4);z++)
        {
           SS_compout<<Show_Time(t,1)<<" "<<Show_Time(t,2)<<" "<<data_time(ALK_time,f,3)<<" "<<f<<" "<<repli<<" "<<gen_l(f,i)<<" LEN "<<mkt_l(f,i)<<" 0 "<<s_off<<" "<<
           1<<" "<<nlength<<" "<<len_bins_dat2(z)<<" "<<obs_l(f,i,z)<<" "<<exp_l(f,i,z)<<" ";
           temp2+=obs_l(f,i,z);
           temp1+=exp_l(f,i,z);
           if(nsamp_l(f,i)>0 && header_l(f,i,3)>0)
           {
            if(exp_l(f,i,z)!=0.0 && exp_l(f,i,z)!=1.0)
            {
              if(Comp_Err_L(f)==0) SS_compout<<value((obs_l(f,i,z)-exp_l(f,i,z))/sqrt( exp_l(f,i,z) * (1.0-exp_l(f,i,z)) / sfabs(nsamp_l(f,i)))); // Pearson for multinomial
              if(Comp_Err_L(f)==1){
                dirichlet_Parm=mfexp(selparm(Comp_Err_Parm_Start+Comp_Err_L2(f)))*nsamp_l(f,i);
                SS_compout<<value( (obs_l(f,i,z)-exp_l(f,i,z))/sqrt( exp_l(f,i,z) * (1.0-exp_l(f,i,z)) / sfabs(nsamp_l(f,i)) * (sfabs(nsamp_l(f,i))+dirichlet_Parm)/(1.+dirichlet_Parm) ) );  // Pearson for Dirichlet-multinomial using negative-exponential parameterization
              }
              if(Comp_Err_L(f)==2){
                dirichlet_Parm=mfexp(selparm(Comp_Err_Parm_Start+Comp_Err_L2(f)));
                SS_compout<<value( (obs_l(f,i,z)-exp_l(f,i,z))/sqrt( exp_l(f,i,z) * (1.0-exp_l(f,i,z)) / sfabs(nsamp_l(f,i)) * (sfabs(nsamp_a(f,i))+dirichlet_Parm)/(1.+dirichlet_Parm) ) ); // Pearson for Dirichlet-multinomial using harmonic sum parameterization
              }
            }
          else
          {SS_compout<<" NA ";}
          SS_compout<<" "<<nsamp_l(f,i)<<" "<<neff_l(f,i)<<" ";
          if(obs_l(f,i,z)!=0.0 && exp_l(f,i,z)!=0.0)
          {SS_compout<<" "<<value(obs_l(f,i,z)*log(obs_l(f,i,z)/exp_l(f,i,z))*nsamp_l(f,i));}
          else
          {SS_compout<<" NA ";}
           }
           else
           {SS_compout<<" NA NA NA NA ";}
           SS_compout<<" "<<temp2<<" "<<temp1<<" "<<anystring<<endl;
        }
        SS_compout<<Show_Time(t,1)<<" "<<Show_Time(t,2)<<" "<<data_time(ALK_time,f,3)<<" "<<f<<" "<<repli<<" "<<gen_l(f,i)<<" LEN "
        <<mkt_l(f,i)<<" 0 "<<s_off<<" "<<1<<" "<<1<<endl;
      }
    }
    }

 /* SS_Label_xxx  output agecomp to CompReport.sso */
      {
        data_type=5;  // for age comp
        in_superperiod=0;
        repli=0;
        last_t=-999;
       for (i=1;i<=Nobs_a(f);i++)                          // loop all obs in this type
       {
        N_out++;
      t=Age_time_t(f,i);
      ALK_time=Age_time_ALK(f,i);
      temp2=0.0;
      temp1=0.0;
      if(t==last_t)
      {repli++;}
      else
      {repli=1;last_t=t;}
      if(header_a(f,i,2)<0 && in_superperiod==0)
      {in_superperiod=1; anystring="Sup";}
      else if (header_a(f,i,2)<0 && in_superperiod>0)
      {anystring="Sup"; in_superperiod=0;}
      else if (in_superperiod>0)
      {in_superperiod++; anystring="Sup";}
      else
      {anystring="_";}
      if(header_a(f,i,3)<0)
      {anystring+=" skip";}
      else
      {anystring+=" _";}

        if(gen_a(f,i)!=2)
         {s_off=1;
         for (z=tails_a(f,i,1);z<=tails_a(f,i,2);z++)
          {SS_compout<<Show_Time(t,1)<<" "<<Show_Time(t,2)<<" "<<data_time(ALK_time,f,3)<<" "<<f<<" "<<repli<<" "<<gen_a(f,i)<<" AGE "<<mkt_a(f,i)<<" "<<ageerr_type_a(f,i)
         <<" "<<s_off<<" "<<len_bins(Lbin_lo(f,i))<<" "<<len_bins(Lbin_hi(f,i))<<" "<<age_bins(z)<<" "<<obs_a(f,i,z)<<" " <<exp_a(f,i,z)<<" ";
           temp2+=obs_a(f,i,z);
           temp1+=exp_a(f,i,z);
          if(header_a(f,i,3)>0)
          {
            if(exp_a(f,i,z)!=0.0 && exp_a(f,i,z)!=1.0)
            {
              if(Comp_Err_A(f)==0) SS_compout<<value((obs_a(f,i,z)-exp_a(f,i,z))/sqrt( exp_a(f,i,z) * (1.0-exp_a(f,i,z)) / sfabs(nsamp_a(f,i)))); // Pearson for multinomial
              if(Comp_Err_A(f)==1){
                dirichlet_Parm=mfexp(selparm(Comp_Err_Parm_Start+Comp_Err_A2(f)))*nsamp_a(f,i);
                SS_compout<<value( (obs_a(f,i,z)-exp_a(f,i,z))/sqrt( exp_a(f,i,z) * (1.0-exp_a(f,i,z)) / sfabs(nsamp_a(f,i)) * (sfabs(nsamp_a(f,i))+dirichlet_Parm)/(1.+dirichlet_Parm) ) );  // Pearson for Dirichlet-multinomial using negative-exponential parameterization
              }
              if(Comp_Err_A(f)==2){
                dirichlet_Parm=mfexp(selparm(Comp_Err_Parm_Start+Comp_Err_A2(f)));
                SS_compout<<value( (obs_a(f,i,z)-exp_a(f,i,z))/sqrt( exp_a(f,i,z) * (1.0-exp_a(f,i,z)) / sfabs(nsamp_a(f,i)) * (sfabs(nsamp_a(f,i))+dirichlet_Parm)/(1.+dirichlet_Parm) ) ); // Pearson for Dirichlet-multinomial using harmonic sum parameterization
              }
            }
            else
            {SS_compout<<" NA ";}
            SS_compout<<" "<<nsamp_a(f,i)<<" "<<neff_a(f,i)<<" ";
            if(obs_a(f,i,z)!=0.0 && exp_a(f,i,z)!=0.0)
            {SS_compout<<" "<<value(obs_a(f,i,z)*log(obs_a(f,i,z)/exp_a(f,i,z))*nsamp_a(f,i));}
            else
            {SS_compout<<" NA ";}
          }
          else
          {SS_compout<<" NA NA NA NA ";}
         SS_compout<<" "<<temp2<<" "<<temp1<<" "<<anystring<<endl;
        }

        SS_compout<<Show_Time(t,1)<<" "<<Show_Time(t,2)<<" "<<data_time(ALK_time,f,3)<<" "<<f<<" "<<repli<<" "<<gen_a(f,i)<<" AGE "
         <<mkt_a(f,i)<<" "<<ageerr_type_a(f,i)<<" "<<s_off<<" "<<1<<" "<<nlength<<endl;}

        if(gen_a(f,i)>=2 && gender==2)  // do males
         {s_off=2;
         for (z=tails_a(f,i,3);z<=tails_a(f,i,4);z++)
          {SS_compout<<Show_Time(t,1)<<" "<<Show_Time(t,2)<<" "<<data_time(ALK_time,f,3)<<" "<<f<<" "<<repli<<" "<<gen_a(f,i)<<" AGE "<<mkt_a(f,i)<<" "<<ageerr_type_a(f,i)<<" "<<s_off
         <<" "<<len_bins(Lbin_lo(f,i))<<" "<<len_bins(Lbin_hi(f,i))<<" "<<age_bins(z)<<" "<<obs_a(f,i,z)<<" "<<exp_a(f,i,z)<<" ";
           temp2+=obs_a(f,i,z);
           temp1+=exp_a(f,i,z);
          if(header_a(f,i,3)>0)
          {
          if(exp_a(f,i,z)!=0.0 && exp_a(f,i,z)!=1.0)
          {
              if(Comp_Err_A(f)==0) SS_compout<<value((obs_a(f,i,z)-exp_a(f,i,z))/sqrt( exp_a(f,i,z) * (1.0-exp_a(f,i,z)) / sfabs(nsamp_a(f,i)))); // Pearson for multinomial
              if(Comp_Err_A(f)==1){
                dirichlet_Parm=mfexp(selparm(Comp_Err_Parm_Start+Comp_Err_A2(f)))*nsamp_a(f,i);
                SS_compout<<value( (obs_a(f,i,z)-exp_a(f,i,z))/sqrt( exp_a(f,i,z) * (1.0-exp_a(f,i,z)) / sfabs(nsamp_a(f,i)) * (sfabs(nsamp_a(f,i))+dirichlet_Parm)/(1.+dirichlet_Parm) ) );  // Pearson for Dirichlet-multinomial using negative-exponential parameterization
              }
              if(Comp_Err_A(f)==2){
                dirichlet_Parm=mfexp(selparm(Comp_Err_Parm_Start+Comp_Err_A2(f)));
                SS_compout<<value( (obs_a(f,i,z)-exp_a(f,i,z))/sqrt( exp_a(f,i,z) * (1.0-exp_a(f,i,z)) / sfabs(nsamp_a(f,i)) * (sfabs(nsamp_a(f,i))+dirichlet_Parm)/(1.+dirichlet_Parm) ) ); // Pearson for Dirichlet-multinomial using harmonic sum parameterization
              }
          }
          else
          {SS_compout<<" NA ";}
          SS_compout<<" "<<nsamp_a(f,i)<<" "<<neff_a(f,i)<<" ";
          if(obs_a(f,i,z)!=0.0 && exp_a(f,i,z)!=0.0)
          {SS_compout<<" "<<value(obs_a(f,i,z)*log(obs_a(f,i,z)/exp_a(f,i,z))*nsamp_a(f,i));}
          else
          {SS_compout<<" NA ";}
        }
        else
        {SS_compout<<" NA NA NA NA ";}
         SS_compout<<" "<<temp2<<" "<<temp1<<" "<<anystring<<endl;
        }
        SS_compout<<Show_Time(t,1)<<" "<<Show_Time(t,2)<<" "<<data_time(ALK_time,f,3)<<" "<<f<<" "<<repli<<" "<<gen_a(f,i)<<" AGE "
         <<mkt_a(f,i)<<" "<<ageerr_type_a(f,i)<<" "<<s_off<<" "<<1<<" "<<nlength<<endl;}
       }
      }  //end have agecomp data

 /* SS_Label_xxx  output size-age to CompReport.sso */
      {
        data_type=7;  // for mean size-at-age
        in_superperiod=0;
        repli=0;
        last_t=-999;
       for (i=1;i<=Nobs_ms(f);i++)
       {
        N_out++;
      t=msz_time_t(f,i);
      ALK_time=msz_time_ALK(f,i);
      temp2=0.0;
      temp1=0.0;
      if(t==last_t)
      {repli++;}
      else
      {repli=1;last_t=t;}
      if(header_ms(f,i,2)<0 && in_superperiod==0)
      {in_superperiod=1; anystring="Sup";}
      else if (header_ms(f,i,2)<0 && in_superperiod>0)
      {anystring="Sup"; in_superperiod=0;}
      else if (in_superperiod>0)
      {in_superperiod++; anystring="Sup";}
      else
      {anystring="_";}
      if(header_ms(f,i,3)<0)
      {anystring+=" skip";}
      else
      {anystring+=" _";}

       for (z=1;z<=n_abins2;z++)
       {
        if(z<=n_abins) s_off=1; else s_off=2;
        t1=obs_ms_n(f,i,z);
        //  whre:  obs_ms_n(f,i,z)=sqrt(var_adjust(6,f)*obs_ms_n(f,i,z));
        if(ageerr_type_ms(f,i)>0) {anystring2=" L@A ";} else {anystring2=" W@A ";}
        if(t1>0.) t1=square(t1);
        SS_compout<<Show_Time(t,1)<<" "<<Show_Time(t,2)<<" "<<data_time(ALK_time,f,3)<<" "<<f<<" "<<repli<<" "<<gen_ms(f,i)<<anystring2<<mkt_ms(f,i)<<" "<<
         ageerr_type_ms(f,i)<<" "<<s_off<<" "<<exp_ms_sq(f,i,z)<<" "<<nlen_bin<<" "<<age_bins(z)<<" "<<
         obs_ms(f,i,z)<<" "<<exp_ms(f,i,z)<<" ";
        if(obs_ms(f,i,z)>0. && t1>0. && header_ms(f,i,3)>0)
        {
          SS_compout<<(obs_ms(f,i,z) -exp_ms(f,i,z)) / (exp_ms_sq(f,i,z)/obs_ms_n(f,i,z))<<" ";  // Pearson
          SS_compout<<t1<<" ";  // sample size
          SS_compout<<square(1.0/((obs_ms(f,i,z) -exp_ms(f,i,z)) / exp_ms_sq(f,i,z)))<<" "; // effectiove sample size
          SS_compout<<0.5*square((obs_ms(f,i,z) -exp_ms(f,i,z)) / (exp_ms_sq(f,i,z)/obs_ms_n(f,i,z))) + sd_offset*log(exp_ms_sq(f,i,z)/obs_ms_n(f,i,z)); //  -logL
        }
        else
        {
          SS_compout<<" NA "<<t1<<" NA NA ";
        }
        SS_compout<<" NA NA "<<anystring<<endl;
        if(z==n_abins || z==n_abins2) SS_compout<<Show_Time(t,1)<<" "<<Show_Time(t,2)<<" "<<data_time(ALK_time,f,3)<<" "<<f<<" "<<repli<<" "<<gen_ms(f,i)<<
         anystring2<<mkt_ms(f,i)<<" "<<ageerr_type_ms(f,i)<<" "<<s_off<<" "<<1<<" "<<nlen_bin<<endl;
       }
      }  //end have data
      }
  }  // end fleet

    if(SzFreq_Nmeth>0)       //  have some sizefreq data
    {
      in_superperiod=0;
      last_t=-999;
      for (iobs=1;iobs<=SzFreq_totobs;iobs++)
      {
        y=SzFreq_obs_hdr(iobs,1);
        if(y>=styr && y<=retro_yr)  // flag for obs that are used
        {
          N_out++;
          temp2=0.0;
          temp1=0.0;
          s=abs(SzFreq_obs_hdr(iobs,2));
//          temp=float(y)+float(abs(s)-1.)/float(nseas);
          f=abs(SzFreq_obs_hdr(iobs,3));
          gg=SzFreq_obs_hdr(iobs,4);  // gender
          k=SzFreq_obs_hdr(iobs,6);
          if(SzFreq_obs_hdr(iobs,2)<0 && in_superperiod==0)
          {in_superperiod=1; anystring="Sup";}
          else if (SzFreq_obs_hdr(iobs,2)<0 && in_superperiod>0)
          {anystring="Sup"; in_superperiod=0;}
          else if (in_superperiod>0)
          {in_superperiod++; anystring="Sup";}
          else
          {anystring="_";}
          if(SzFreq_obs_hdr(iobs,3)<0)
          {anystring+=" skip";}
          else
          {anystring+=" _";}
          p=SzFreq_obs_hdr(iobs,5);  // partition
          z1=SzFreq_obs_hdr(iobs,7);
          z2=SzFreq_obs_hdr(iobs,8);
          t=SzFreq_time_t(iobs);
          ALK_time=SzFreq_time_ALK(iobs);
          temp2=0.0;
          temp1=0.0;
          if(t==last_t)
          {repli++;}
          else
          {repli=1;last_t=t;}
          for (z=z1;z<=z2;z++)
          {
            s_off=1;
            SS_compout<<Show_Time(t,1)<<" "<<Show_Time(t,2)<<" "<<data_time(ALK_time,f,3)<<" "<<f<<" "<<repli<<" "<<gg<<" SIZE "<<p<<" "<<k;
            if(z>SzFreq_Nbins(k)) s_off=2;
            SS_compout<<" "<<s_off<<" "<<SzFreq_units(k)<<" "<<SzFreq_scale(k)<<" ";
            if(s_off==1) {SS_compout<<SzFreq_bins1(k,z);} else {SS_compout<<SzFreq_bins1(k,z-SzFreq_Nbins(k));}
            SS_compout<<" "<<SzFreq_obs(iobs,z)<<" " <<SzFreq_exp(iobs,z)<<" ";
            temp2+=SzFreq_obs(iobs,z);
            temp1+=SzFreq_exp(iobs,z);
            if(SzFreq_obs_hdr(iobs,3)>0)
            {
              if(SzFreq_exp(iobs,z)!=0.0 && SzFreq_exp(iobs,z)!=1.0)
                {SS_compout<<(SzFreq_obs(iobs,z)-SzFreq_exp(iobs,z))/sqrt( SzFreq_exp(iobs,z) * (1.-SzFreq_exp(iobs,z)) / SzFreq_sampleN(iobs));}
              else
                {SS_compout<<" NA ";}
              SS_compout<<" "<<SzFreq_sampleN(iobs)<<" "<<SzFreq_effN(iobs)<<" ";
              if(SzFreq_obs(iobs,z)!=0.0 && SzFreq_exp(iobs,z)!=0.0)
                {SS_compout<<" "<<SzFreq_obs(iobs,z)*log(SzFreq_obs(iobs,z)/SzFreq_exp(iobs,z))*SzFreq_sampleN(iobs);}
              else
                {SS_compout<<" NA ";}
            }
            else
            {SS_compout<<" NA NA NA NA ";}
            SS_compout<<" "<<temp2<<" "<<temp1<<" "<<anystring<<endl;
            if(z==z2 || z==SzFreq_Nbins(k))
            SS_compout<<y<<" "<<s<<" "<<temp<<" "<<f<<" "<<repli<<" "<<gg<<" SIZE "<<p<<" "<<k<<" "<<s_off<<" "<<1<<" "<<2<<endl;
          }
        }
      }
    }
    if(Do_Morphcomp>0)
    {
      for (iobs=1;iobs<=Morphcomp_nobs;iobs++)
      {
        N_out++;
        y=Morphcomp_obs(iobs,1); s=Morphcomp_obs(iobs,2);
        temp1=s-1.;
        temp2=y;
        temp = float(y)+0.01*int(100.*(azero_seas(s)+seasdur_half(s)));
//        temp=temp2+temp1/nseas;
        f=Morphcomp_obs(iobs,3);
        k=5+Morphcomp_nmorph;
        for (z=6;z<=k;z++)
        {
          SS_compout<<y<<" "<<s<<" "<<temp<<" "<<1<<" "<<1<<" GP% "<<0<<" "<<Morphcomp_obs(iobs,5);
         SS_compout<<" "<<0<<" "<<0<<" "<<0<<" "<<z-5<<" "<<Morphcomp_obs(iobs,z)<<" " <<Morphcomp_exp(iobs,z)<<" "<<endl;
        }
      }
    }


    if(Do_TG>0)
    {
      for (TG=1;TG<=N_TG;TG++)
      {
        y=TG_release(TG,3); s=TG_release(TG,4);
        for (TG_t=0;TG_t<=TG_endtime(TG);TG_t++)
        {
          N_out++;
          t = styr+(y-styr)*nseas+s-1;
          temp1=s-1.;
//          temp=float(y)+temp1/float(nseas);
          temp = float(y)+0.01*int(100.*(azero_seas(s)+seasdur_half(s)));
          SS_compout<<y<<" "<<s<<" "<<temp<<" "<<0<<" "<<TG<<" "<<TG_release(TG,6)<<" TAG2 NA NA NA NA NA "<<
          temp<<" "<<TG_recap_obs(TG,TG_t,0)<<" "<<TG_recap_exp(TG,TG_t,0)<<" NA NA NA NA NA NA NA ";
          if(TG_t>=TG_mixperiod) {SS_compout<<"_"<<endl;} else {SS_compout<<" skip"<<endl;}
          if(Nfleet>1)
          for (f=1;f<=Nfleet;f++)
          {
            SS_compout<<y<<" "<<s<<" "<<temp<<" "<<f<<" "<<TG<<" "<<TG_release(TG,6)<<" TAG1 NA NA NA NA NA "<<
            f<<" "<<TG_recap_obs(TG,TG_t,f)<<" "<<TG_recap_exp(TG,TG_t,f)<<" NA "<<TG_recap_obs(TG,TG_t,0)
            <<" NA NA NA NA NA ";
          if(TG_t>=TG_mixperiod) {SS_compout<<"_"<<endl;} else {SS_compout<<" skip"<<endl;}
          }
          s++; if(s>nseas) {s=1; y++;}
        }
      }
    }

  if(N_out==0) SS_compout<<styr<<" -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1"<<endl;
  SS_compout<<"-1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1"<<endl<<"End_comp_data"<<endl;
  SS_compout<<"end "<<endl;

  SS2out <<endl<< "SELEX_database" << endl;
  SS2out<<"Fleet Yr Kind Sex Bin Selex"<<endl;

  if(reportdetail != 1)
  {
    SS2out<<"1 1990 L 1 30 .5"<<endl;
  }
  else
  {
  for (f=1;f<=Nfleet;f++)
  for (y=styr-3;y<=endyr;y++)
  {
   if(y==styr-3 || y==endyr || (timevary_sel(y,f)>0 || timevary_sel(y+1,f)>0))
   {
    for (gg=1;gg<=gender;gg++)
    {
     for (z=1;z<=nlength;z++) {SS2out<<f<<" "<<y<<" L "<<gg<<" "<<len_bins(z)<<" "<<sel_l(y,f,gg,z)<<endl;}
     if(seltype(f,2)!=0)
     {
      if(gg==1) {for (z=1;z<=nlength;z++) {SS2out<<f<<" "<<y<<" D "<<gg<<" "<<len_bins(z)<<" "<<retain(y,f,z)<<endl;}}
      else
      {for (z=1;z<=nlength;z++) {SS2out<<f<<" "<<y<<" D "<<gg<<" "<<len_bins(z)<<" "<<retain(y,f,z+nlength)<<endl;}}
     }
     if(seltype(f,2)==2)
     {
      if(gg==1) {for (z=1;z<=nlength;z++) {SS2out<<f<<" "<<y<<" DM "<<gg<<" "<<len_bins(z)<<" "<<discmort(y,f,z)<<endl;}}
      else
      {for (z=1;z<=nlength;z++) {SS2out<<f<<" "<<y<<" DM "<<gg<<" "<<len_bins(z)<<" "<<discmort(y,f,z+nlength)<<endl;}}
     }
    }
   }
   if(timevary_sel(y,f+Nfleet)>0)
   {
    for (gg=1;gg<=gender;gg++)
    for (a=0;a<=nages;a++) {SS2out<<f<<" "<<y<<" A "<<gg<<" "<<a<<" "<<sel_a(y,f,gg,a)<<endl;}
   }
  }
  }  // end do report detail
  SS2out<<" end selex output "<<endl;

// ******************************************************
//  Do Ypr/Spr profile
        int SPRloop;
        int bio_t_base;
        dvariable Fmult2=maxpossF;
        dvariable Fcrash=Fmult2;
        dvariable Fmultchanger0=value(Fmult2/39.);
        dvariable Fmultchanger1;
        dvariable Fmultchanger2;
        dvariable Btgt_prof;
        dvariable Btgt_prof_rec;
        dvariable SPR_last;
        dvariable SPR_trial;

  if(Do_Benchmark>0 && wrote_bigreport==1)
  {
        SS2out<<endl<<"SPR/YPR_Profile "<<endl<<"SPRloop Iter Fmult F_report SPR YPR YPR*Recr SSB Recruits SSB/Bzero Tot_Catch ";
        for (f=1;f<=Nfleet;f++) {if(fleet_type(f)<=2) SS2out<<" "<<fleetname(f)<<"("<<f<<")";}
        for (f=1;f<=Nfleet;f++) {if(fleet_type(f)<=2) SS2out<<" "<<fleetname(f)<<"("<<f<<")";}
        for (p=1;p<=pop;p++)
        for (gp=1;gp<=N_GP;gp++)
        {SS2out<<" Area:"<<p<<"_GP:"<<gp;}
        SS2out<<endl;
    y=styr-3;
    yz=y;
    bio_yr=y;
    eq_yr=y;
    t_base=y+(y-styr)*nseas-1;
    bio_t_base=styr+(bio_yr-styr)*nseas-1;

//  SPAWN-RECR:  call make_fecundity for benchmark bio for SPR loop
    for (s=1;s<=nseas;s++)
    {
      t = styr-3*nseas+s-1;
      if(MG_active(2)>0 || MG_active(3)>0 || save_for_report>0 || WTage_rd>0)
      {
        subseas=1;
        ALK_idx=(s-1)*N_subseas+subseas;  //  for midseason
        Make_AgeLength_Key(s, subseas);  //  for begin season
        subseas=mid_subseas;
        ALK_idx=(s-1)*N_subseas+subseas;  //  for midseason
        Make_AgeLength_Key(s, subseas);  //  for midseason
        if(s==spawn_seas)
        {
          subseas=spawn_subseas;
          if(spawn_subseas!=1 && spawn_subseas!=mid_subseas)
          {
        //don't call get_growth3(subseas) because using an average ave_size
            Make_AgeLength_Key(s, subseas);  //  spawn subseas
          }
          Make_Fecundity();
        }
      }
      for (g=1;g<=gmorph;g++)
      if(use_morph(g)>0)
      {
        ALK_idx=(s-1)*N_subseas+mid_subseas;  //  for midseason
        Make_FishSelex();
      }
    }

    equ_Recr=1.0;
    Fishon=0;
    int SPRloops;
    Do_Equil_Calc(equ_Recr);
    SPR_unf=SPB_equil;
        for (int SPRloop1=0; SPRloop1<=6; SPRloop1++)
        {
          Fmultchanger1=value(pow(0.0001/Fcrash,0.025));
          Fmultchanger2=value(Fcrash/39.);
          SPRloops=40;
          switch(SPRloop1)
          {
            case 1:
            {
              Fmult2=Fcrash;
              break;
            }
            case 3:
            {
              Fmult2=1;
              SPRloops=1;
              break;
            }
            case 4:
            {
              Fmult2=SPR_Fmult;
              SPRloops=1;
              break;
            }
            case 5:
            {
              Fmult2=Btgt_Fmult;
              SPRloops=1;
              break;
            }
            case 6:
            {
              Fmult2=MSY_Fmult;
              SPRloops=1;
              break;
            }
          }
          for (SPRloop=1; SPRloop<=SPRloops; SPRloop++)
          {
            for (f=1;f<=Nfleet;f++)
            for (s=1;s<=nseas;s++)
            if(fleet_type(f)<=2)
            {
              t=bio_t_base+s;
              if(SPRloop1!=3)
              {
                Hrate(f,t)=Fmult2*Bmark_RelF_Use(s,f);
              }
              else
              {
                a=styr+(endyr-styr)*nseas+s-1;
                Hrate(f,t)=Hrate(f,a);
              }
            }
            Fishon=1;
            Do_Equil_Calc(equ_Recr);
//  SPAWN-RECR:   calc equil spawn-recr in the SPR loop
            SPR_temp=SPB_equil;
            Equ_SpawnRecr_Result = Equil_Spawn_Recr_Fxn(SR_parm(2), SR_parm(3), SPB_virgin, Recr_virgin, SPR_temp);  //  returns 2 element vector containing equilibrium biomass and recruitment at this SPR
            Btgt_prof=Equ_SpawnRecr_Result(1);
            Btgt_prof_rec=Equ_SpawnRecr_Result(2);
            if(SPRloop1==0)
            {
              if(Btgt_prof<0.001 && Btgt_prof_rec<0.001)
              {Fcrash=Fmult2;}
            }
            SS2out<<SPRloop1<<" "<<SPRloop<<" "<<Fmult2<<" "<<equ_F_std<<" "<<value(SPB_equil/SPR_unf)<<" "<<value(YPR_dead)<<" "
            <<value(YPR_dead*Btgt_prof_rec)<<" "<<Btgt_prof<<" "<<Btgt_prof_rec<<" "<<value(Btgt_prof/SPB_virgin)
            <<" "<<value(sum(equ_catch_fleet(2))*Btgt_prof_rec);
            for(f=1;f<=Nfleet;f++)
            if(fleet_type(f)<=2)
            {
              temp=0.0;
              for(s=1;s<=nseas;s++) {temp+=equ_catch_fleet(2,s,f);}
              SS2out<<" "<<temp*Btgt_prof_rec;
            }
//  report mean age of CATCH
            for(f=1;f<=Nfleet;f++)
            if(fleet_type(f)<=2)
            {
              temp=0.0; temp2=0;
              for(s=1;s<=nseas;s++) 
              for(g=1;g<=gmorph;g++)
              if(use_morph(g)>0)
              {
                temp+=equ_catage(s,f,g)*r_ages;
                temp2+=sum(equ_catage(s,f,g));
              }
              SS2out<<" "<<temp/temp2;
            }
            
            for (p=1;p<=pop;p++)
            for (gp=1;gp<=N_GP;gp++)
            {SS2out<<" "<<SPB_equil_pop_gp(p,gp)*Btgt_prof_rec;}
            SS2out<<endl;
            if(SPRloop1==0)
              {Fmult2-=Fmultchanger0;}
            else if(SPRloop1==1)
              {Fmult2*=Fmultchanger1;}
            else if(SPRloop1==2)
              {Fmult2+=Fmultchanger2;}
          }
        }  // end Fmult profile

        SPR_trial=value(SPB_equil/SPR_unf);
        SPR_last=SPR_trial*2.;
        SPRloop=0;
        dvariable YPR_last;
        YPR_last=-1.;
        while (SPR_trial>0.001 && SPR_last>1.00001*SPR_trial && YPR_last<YPR_dead && SPRloop<1000)
        {
          if(F_Method>1)
          {Fmult2*=1.05;}
          else
          {Fmult2=Fmult2+(1.0-Fmult2)*0.05;}
          SPR_last=SPR_trial;
          YPR_last=YPR_dead;
          for (f=1;f<=Nfleet;f++)
          for (s=1;s<=nseas;s++)
          if(fleet_type(f)<=2)
          {
            t=bio_t_base+s;
            Hrate(f,t)=Fmult2*Bmark_RelF_Use(s,f);
          }
          SPRloop+=1;
          Fishon=1;
          Do_Equil_Calc(equ_Recr);
          SPR_temp=SPB_equil;
          Equ_SpawnRecr_Result = Equil_Spawn_Recr_Fxn(SR_parm(2), SR_parm(3), SPB_virgin, Recr_virgin, SPR_temp);  //  returns 2 element vector containing equilibrium biomass and recruitment at this SPR
          Btgt_prof=Equ_SpawnRecr_Result(1);
          Btgt_prof_rec=Equ_SpawnRecr_Result(2);
          SPR_trial=value(SPB_equil/SPR_unf);
            SS2out<<"7 "<<SPRloop<<" "<<Fmult2<<" "<<equ_F_std<<" "<<value(SPB_equil/SPR_unf)<<" "<<value(YPR_dead)<<" "
            <<value(YPR_dead*Btgt_prof_rec)<<" "<<Btgt_prof<<" "<<Btgt_prof_rec<<" "<<value(Btgt_prof/SPB_virgin)
            <<" "<<value(sum(equ_catch_fleet(2))*Btgt_prof_rec);
            for(f=1;f<=Nfleet;f++)
            if(fleet_type(f)<=2)
            {
              temp=0.0;
              for(s=1;s<=nseas;s++) {temp+=equ_catch_fleet(2,s,f);}
              SS2out<<" "<<temp*Btgt_prof_rec;
            }
//  report mean age of CATCH
            for(f=1;f<=Nfleet;f++)
            if(fleet_type(f)<=2)
            {
              temp=0.0; temp2=0;
              for(s=1;s<=nseas;s++) 
              for(g=1;g<=gmorph;g++)
              if(use_morph(g)>0)
              {
                temp+=equ_catage(s,f,g)*r_ages;
                temp2+=sum(equ_catage(s,f,g));
              }
              SS2out<<" "<<temp/temp2;
            }
            for (p=1;p<=pop;p++)
            for (gp=1;gp<=N_GP;gp++)
            {SS2out<<" "<<SPB_equil_pop_gp(p,gp)*Btgt_prof_rec;}
            SS2out<<endl;        }
        // end Btarget profile
        SS2out<<"Finish SPR/YPR profile"<<endl;
        SS2out<<"#Profile 0 is descending additively from max possible F:  "<<maxpossF<<endl;
        SS2out<<"#Profile 1 is descending multiplicatively back to nil F"<<endl;
        SS2out<<"#Profile 2 is additive back to Fcrash: "<<Fcrash<<endl;
        SS2out<<"#value 3 uses endyr F, which has different fleet allocation than benchmark"<<endl;
        SS2out<<"#value 4 is Fspr: "<<SPR_Fmult<<endl;
        SS2out<<"#value 5 is Fbtgt: "<<Btgt_Fmult<<endl;
        SS2out<<"#value 6 is Fmsy: "<<MSY_Fmult<<endl;
        SS2out<<"#Profile 7 increases from Fmsy to Fcrash"<<endl;
        
  }

// ******************************************************
//  GLOBAL_MSY with knife-edge age selection, then slot-age selection
  if(Do_Benchmark>0 && wrote_bigreport==1 && reportdetail != 2)
  {
    y=styr-3;  //  stores the averaged
    yz=y;
    bio_yr=y;
    eq_yr=y;
    t_base=y+(y-styr)*nseas-1;
    bio_t_base=styr+(bio_yr-styr)*nseas-1;

    for (int MSY_loop=0;MSY_loop<=2;MSY_loop++)
    {
      if(MSY_loop==0)
      {SS2out<<endl<<"ACTUAL_SELECTIVITY_MSY "<<endl;}
      else if(MSY_loop==1)
      {SS2out<<endl<<"KNIFE_AGE_SELECTIVITY_MSY "<<endl;}
      else
      {SS2out<<endl<<"SLOT_AGE_SELECTIVITY_MSY "<<endl;}
      SS2out<<"------  SPR  SPR SPR SPR SPR SPR SPR SPR SPR # BTGT BTGT BTGT BTGT BTGT BTGT BTGT BTGT   BTGT  BTGT # "<<
       "   MSY MSY MSY MSY MSY MSY MSY MSY MSY MSY MSY"<<endl<<
      "Age SPR  Fmult Fstd   Exploit Recruit SSB Y_dead Y_ret VBIO # SPR   B/B0  Fmult Fstd    Exploit Recruit SSB  Y_dead Y_ret VBIO "<<
        " # SPR   B/B0  Fmult Fstd  Exploit Recruit SSB  Y_MSY Y_dead Y_ret VBIO "<<endl;

      if(MSY_loop>0)
      {
        for (int SPRloop1=1;SPRloop1<=nages-1;SPRloop1++)
        {
          sel_al_1.initialize();
          sel_al_2.initialize();
          sel_al_3.initialize();
          sel_al_4.initialize();
          deadfish.initialize();
          deadfish_B.initialize();
          SS2out<<SPRloop1<<" ";
          for (s=1;s<=nseas;s++)
          {
            t = styr-3*nseas+s-1;
            for (g=1;g<=gmorph;g++)
            if(use_morph(g)>0)
            {
              for(f=1;f<=Nfleet;f++)
              {
              if(MSY_loop==1)
              {
                sel_al_1(s,g,f)(SPRloop1,nages)=Wt_Age_mid(s,g)(SPRloop1,nages);  // selected * wt
                sel_al_2(s,g,f)(SPRloop1,nages)=Wt_Age_mid(s,g)(SPRloop1,nages);  // selected * retained * wt
                sel_al_3(s,g,f)(SPRloop1,nages)=1.00;  // selected numbers
                sel_al_4(s,g,f)(SPRloop1,nages)=1.00;  // selected * retained numbers
                deadfish(s,g,f)(SPRloop1,nages)=1.00;  // sel * (retain + (1-retain)*discmort)
                deadfish_B(s,g,f)(SPRloop1,nages)=Wt_Age_mid(s,g)(SPRloop1,nages);  // sel * (retain + (1-retain)*discmort) * wt
              }
               else
              {
                sel_al_1(s,g,f,SPRloop1)=Wt_Age_mid(s,g,SPRloop1);  // selected * wt
                sel_al_2(s,g,f,SPRloop1)=Wt_Age_mid(s,g,SPRloop1);  // selected * retained * wt
                sel_al_3(s,g,f,SPRloop1)=1.00;  // selected numbers
                sel_al_4(s,g,f,SPRloop1)=1.00;  // selected * retained numbers
                deadfish(s,g,f,SPRloop1)=1.00;  // sel * (retain + (1-retain)*discmort)
                deadfish_B(s,g,f,SPRloop1)=Wt_Age_mid(s,g,SPRloop1);  // sel * (retain + (1-retain)*discmort) * wt
              }
              }
            }
          }
          show_MSY=2;  //  invokes just brief output in benchmark
          did_MSY=0;
          Get_Benchmarks(show_MSY);
          did_MSY=0;
        }
      }
      else
      {
        SS2out<<"Actual ";
        show_MSY=2;  //  invokes just brief output in benchmark
        did_MSY=0;
        Get_Benchmarks(show_MSY);
        did_MSY=0;
      }
    }
  }
  SS2out<<"#"<<endl;
  wrote_bigreport=1;  // flag so that second call to writebigreport will do extra output
  return;
  }  //  end writebigreport

//********************************************************************
 /*  SS_Label_FUNCTION 41 write_Bzero_output */
FUNCTION void write_Bzero_output()
  {
//  output annual time series for beginning of year and summing across areas for each GP and gender
    for (fishery_on_off=1;fishery_on_off>=0;fishery_on_off--)
    {
    SS2out<<endl<<"Dynamic_Bzero"<<endl;
    SS2out<<"Spawning_Biomass_Report";
    if(fishery_on_off==0) {SS2out<<"_1 No_fishery_for_Z=M_and_dynamic_Bzero";} else {SS2out<<"_2 With_fishery";}
    SS2out<<endl<<"Yr Area: ";
    for (p=1;p<=pop;p++)
    for (gp=1;gp<=N_GP;gp++)
    {SS2out<<p<<" ";}
    SS2out<<endl<<"xxxx GP: ";
    for (p=1;p<=pop;p++)
    for (gp=1;gp<=N_GP;gp++)
    {SS2out<<gp<<" ";}
    SS2out<<endl;

      save_gparm=0;
      if(fishery_on_off==0)
      {
        get_initial_conditions();
        get_time_series();  //  in write_big_report

        if(Do_Forecast>0)
        {
          show_MSY=0;
        report5<<"#"<<endl<<" FORECAST: in Bzero report with fishery onoff= "<<fishery_on_off<<endl;
          Get_Forecast();
        }
      }

    for (y=styr-2;y<=YrMax;y++)
    {
      SS2out<<y;
       if(y==styr-2)
         {SS2out<<" VIRG ";}
       else if (y==styr-1)
         {SS2out<<" INIT ";}
       else if (y<=endyr)
         {SS2out<<" TIME ";}
       else
         {SS2out<<" FORE ";}
      for (p=1;p<=pop;p++)
      for (gp=1;gp<=N_GP;gp++)
      {SS2out<<" "<<SPB_pop_gp(y,p,gp);}
      SS2out<<endl;
    }

    SS2out << endl << "NUMBERS_AT_AGE_Annual";
    if(fishery_on_off==0) {SS2out<<"_1 No_fishery_for_Z=M_and_dynamic_Bzero";} else {SS2out<<"_2 With_fishery";}
    SS2out << endl;
    SS2out << "Bio_Pattern Sex Yr "<<age_vector <<endl;
    dvector tempvec2(1,nages);
    for (gg=1;gg<=gender;gg++)
    for (gp=1;gp<=N_GP;gp++)
    for (y=styr;y<=YrMax;y++)
    {
      tempvec_a.initialize();
      t = styr+(y-styr)*nseas;  // first season only
      for (p=1;p<=pop;p++)
      for (g=1;g<=gmorph;g++)
      if(use_morph(g)>0)
      {
        if(GP4(g)==gp && sx(g)==gg) tempvec_a+= value(natage(t,p,g));
      }
      if(nseas>1)
      {
        tempvec_a(0)=0.;
        for (s=1;s<=nseas;s++)
        for (p=1;p<=pop;p++)
        for (g=1;g<=gmorph;g++)
        if(use_morph(g)>0 && Bseas(g)==s)
        {
          if(GP4(g)==gp && sx(g)==gg) tempvec_a(0) += value(natage(t,p,g,0));
        }
      }
      SS2out <<gp<<" "<<gg<<" "<<y<<" "<<tempvec_a<<endl;
    }

    SS2out << endl << "Z_AT_AGE_Annual";
    if(fishery_on_off==0) {SS2out<<"_1 No_fishery_for_Z=M_and_dynamic_Bzero";} else {SS2out<<"_2 With_fishery";}
    if(Hermaphro_Option!=0) SS2out<<"_hermaphrodites_combined_sex_output";
    SS2out << endl;
    SS2out << "Bio_Pattern Sex Yr "<<age_vector <<endl;
    if(Hermaphro_Option!=0)
    {k=1;}
    else
    {k=gender;}
    for (gg=1;gg<=k;gg++)
    for (gp=1;gp<=N_GP;gp++)
    for (y=styr;y<=YrMax;y++)
    {
      tempvec_a.initialize();
      t = styr+(y-styr)*nseas;  // first season only
      for (p=1;p<=pop;p++)
      for (g=1;g<=gmorph;g++)
      if(use_morph(g)>0)
      {
        if(GP4(g)==gp && (sx(g)==gg || Hermaphro_Option!=0)) tempvec_a+= value(natage(t,p,g));
      }
      if(nseas>1)
      {
        tempvec_a(0)=0.;
        for (s=1;s<=nseas;s++)
        for (p=1;p<=pop;p++)
        for (g=1;g<=gmorph;g++)
        if(use_morph(g)>0 && Bseas(g)==s)
        {
          if(GP4(g)==gp && (sx(g)==gg || Hermaphro_Option!=0)) tempvec_a(0) += value(natage(t,p,g,0));
        }
      }
      if(y>styr)
      {
      SS2out <<gp<<" "<<gg<<" "<<y-1<<" "<<log(elem_div(tempvec2(1,nages),tempvec_a(1,nages)))<<" _ "<<endl;
      }
      for (a=0;a<=nages-1;a++) tempvec2(a+1)=value(tempvec_a(a));
      tempvec2(nages)+=value(tempvec_a(nages));
    }
    }
    SS2out<<" Note:  Z calculated as -ln(Nt+1 / Nt)"<<endl;
    SS2out<<" Note:  Z calculation for maxage-1 includes numbers at maxage, so is approximate"<<endl;
    if(nseas>1) SS2out<<" Age zero fish summed across settlements, but Z calc is as if all born in season 1"<<endl;
    fishery_on_off=1;
    return;
  }  //  end write bzero

//********************************************************************
 /*  SS_Label_FUNCTION 28 Report_Parm */
FUNCTION void Report_Parm(const int NParm, const int AC, const int Activ, const prevariable& Pval, const double& Pmin, const double& Pmax, const double& RD, const double& Jitter, const double& PR, const double& CV, const int PR_T, const int PH, const prevariable& Like)
  {
    dvar_vector parm_val(1,14);
    dvar_vector prior_val(1,14);
    int i;
    dvariable parmvar, parmgrad;
    parmvar=0.0;
    parmgrad=0.0;
    SS2out<<NParm<<" "<<ParmLabel(NParm)<<" "<<Pval;
    if(Activ>0)
    {
      parmvar=CoVar(AC,1);
      parmgrad=parm_gradients(AC);

      SS2out<<" "<<AC<<" "<<PH<<" "<<Pmin<<" "<<Pmax<<" "<<RD<<" "<<Jitter;
      if (Pval==RD)
      {
        SS2out<<" NO_MOVE ";
      }
      else
      {
        temp=(Pval-Pmin)/(Pmax-Pmin);
        if(temp==0.0 || temp==1.0)
          {SS2out<<" BOUND "; Nparm_on_bound++;}
        else if(temp<0.01)
          {SS2out<<" LO "; Nparm_on_bound++;}
        else if(temp>=0.99)
          {SS2out<<" HI "; Nparm_on_bound++;}
        else
          {SS2out<<" OK ";}
      }
      SS2out<<" "<<parmvar;

      SS2out<<" "<<parmgrad;
    }
    else
    {
      SS2out<<" _ "<<PH<<" "<<Pmin<<" "<<Pmax<<" "<<RD<<" "<<Jitter<<" NA _ _ ";
    }
    if(PR_T>0)
    {
      switch (PR_T)
      {
        case 6:
        {SS2out<<" Normal "; break;}
        case 1:
        {SS2out<<" Sym_Beta "; break;}
        case 2:
        {SS2out<<" Full_Beta "; break;}
        case 3:
        {SS2out<<" Log_Norm "; break;}
        case 4:
        {SS2out<<" Log_Norm_w/biasadj "; break;}
        case 5:
        {SS2out<<" Gamma "; break;}
      }
      SS2out<<" "<<PR<<" "<<CV<<" "<<Like<<" ";
      i=1;
      parm_val(i)=Pval;
      prior_val(i)=Get_Prior(PR_T, Pmin, Pmax, PR, CV, Pval);
      i=2;
      temp=Pval-1.96*parmvar;
      if(temp<Pmin) temp=Pmin;
      parm_val(i)=temp;
      prior_val(i)=Get_Prior(PR_T, Pmin, Pmax, PR, CV, temp);

      i=3;
      temp=Pval+1.96*parmvar;
      if(temp>Pmax) temp=Pmax;
      parm_val(i)=temp;
      prior_val(i)=Get_Prior(PR_T, Pmin, Pmax, PR, CV, temp);

      i=4;
      temp=Pmin+0.01*(Pmax-Pmin);
      parm_val(i)=temp;
      prior_val(i)=Get_Prior(PR_T, Pmin, Pmax, PR, CV, temp);
      i=14;
      temp=Pmax-0.01*(Pmax-Pmin);
      parm_val(i)=temp;
      prior_val(i)=Get_Prior(PR_T, Pmin, Pmax, PR, CV, temp);

      for (int i=5;i<=13;i++)
      {
        temp=Pmin+float(i-4)/10.0*(Pmax-Pmin);
        parm_val(i)=temp;
        prior_val(i)=Get_Prior(PR_T, Pmin, Pmax, PR, CV, temp);
      }
      SS2out<<parm_val<<" "<<prior_val;
    }
    else
    {SS2out<<" No_prior ";}
    SS2out<<endl;
  }

