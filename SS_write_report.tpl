//********************************************************************
 /*  SS_Label_FUNCTION 40 write_bigoutput */
FUNCTION void write_bigoutput()
  {
  SS2out.open ("Report.sso");   // this file was created in globals so accessible to the report_parm function
  ofstream SS_compout("CompReport.sso");

  SS2out<<version_info<<endl<<version_info2<<endl<<version_info3<<endl<<endl;
  time(&finish);
  SS_compout<<version_info<<endl<<"StartTime: "<<ctime(&start);

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

  SS2out<<endl<<"KeyWords (Of_Tables_Available_In_report.sso)"<<endl;
  SS2out<<endl<<"X List_Tables_related_to_basic_input_pre-processing_and_output"<<endl;
  SS2out<<"X AGE_AGE'_KEY"<<endl;
  SS2out<<"X AGE_LENGTH_KEY"<<endl;
  SS2out<<"X BIOLOGY"<<endl;
  SS2out<<"X DEFINITIONS"<<endl;
  SS2out<<"X DERIVED_QUANTITIES"<<endl;
  SS2out<<"X ENVIRONMENTAL_DATA"<<endl;
  SS2out<<"X Input_Variance_Adjustment"<<endl;
  SS2out<<"X LIKELIHOOD"<<endl;
  SS2out<<"X MGparm_By_Year_after_adjustments"<<endl;
  SS2out<<"X MORPH_INDEXING (defines_associations_for_sex_growth_pattern_platoons_settlements)"<<endl;
  SS2out<<"X MOVEMENT (fraction_moving_between_areas)"<<endl;
  SS2out<<"X OVERALL_COMPS (average_length_and_age_composition_observed_by_each_fleet)"<<endl;
  SS2out<<"X PARAMETERS"<<endl;
  SS2out<<"X RECRUITMENT_DIST (distribution_of_recruits_among_morphs_areas_settlement_time)"<<endl;
  SS2out<<"X SIZEFREQ_TRANSLATION (If_using_generalized_size_comp)"<<endl;
  
  SS2out<<endl<<"X List_Tables_related_to_timeseries_output"<<endl;
  SS2out<<"X BIOMASS_AT_AGE";
  if (reportdetail == 2) SS2out<<" ---";    // indicate not included
  SS2out<<endl;
  SS2out<<"X BIOMASS_AT_LENGTH";
  if (reportdetail == 2) SS2out<<" ---";    // indicate not included
  SS2out<<endl;
  SS2out<<"X CATCH_AT_AGE";
  if (reportdetail == 2) SS2out<<" ---";    // indicate not included
  SS2out<<endl;
  SS2out<<"X F_AT_AGE";
  if (reportdetail == 2) SS2out<<" ---";    // indicate not included
  SS2out<<endl;
  SS2out<<"X CATCH"<<endl;
  SS2out<<"X EXPLOITATION (showing_F_rates_by_fleet)"<<endl;
  SS2out<<"X MEAN_SIZE_TIMESERIES (body length)"<<endl;
  SS2out<<"X NUMBERS_AT_AGE";
  if (reportdetail == 2) SS2out<<" ---";    // indicate not included
  SS2out<<endl;
  SS2out<<"X NUMBERS_AT_LENGTH";
  if (reportdetail == 2) SS2out<<" ---";    // indicate not included
  SS2out<<endl;
  SS2out<<"X SPAWN_RECRUIT"<<endl;
  SS2out<<"X SPR_series (equilibrium_SPR_and_YPR_calculations_for_each_year)"<<endl;
  SS2out<<"X TIME_SERIES"<<endl;

  SS2out<<endl<<"X List_Tables_related_to_fit_to_data"<<endl;
  SS2out<<"X DISCARD_SPECIFICATION"<<endl;
  SS2out<<"X DISCARD_OUTPUT"<<endl;
  SS2out<<"X INDEX_1 (Survey_Fit_Summary)"<<endl;
  SS2out<<"X INDEX_2 (Survey_Observations_By_Year)"<<endl;
  SS2out<<"X INDEX_3 (Survey_Q)"<<endl;
  SS2out<<"X FIT_LEN_COMPS"<<endl;
  SS2out<<"X FIT_AGE_COMPS"<<endl;
  SS2out<<"X FIT_SIZE_COMPS"<<endl;
  SS2out<<"X MEAN_BODY_WT"<<endl;
  SS2out<<"X TAG_Recapture"<<endl;

  SS2out<<endl<<"X List_Tables_related_to_selectivity_and_discard"<<endl;
  SS2out<<"X AGE_SELEX"<<endl;
  SS2out<<"X DEADFISH (fraction_of_catch_retained_or_dead_discard)"<<endl;
  SS2out<<"X DISCARD_MORT"<<endl;
  SS2out<<"X KEEPERS (fraction_of_catch_retained)"<<endl;
  SS2out<<"X LEN_SELEX"<<endl;
  SS2out<<"X RETENTION"<<endl;
  SS2out<<"X selparm(Size)_By_Year_after_adjustments"<<endl;
  SS2out<<"X selparm(Age)_By_Year_after_adjustments"<<endl;

  SS2out<<endl<<"X List_Tables_related_to_equilibrium_reference_points"<<endl;
  SS2out<<"X also_see_forecast_report.sso"<<endl;
  SS2out<<"X Dynamic_Bzero "<<endl;
  SS2out<<"X GLOBAL_MSY (including_knife-edge_selex_and_slot-age_selex)"<<endl;
  SS2out<<"X Kobe_Plot"<<endl;
  SS2out<<"X SPR/YPR_PROFILE"<<endl;
  SS2out<<"X Z_AT_AGE_Annual_1 (with_fishing)"<<endl;
  SS2out<<"X Z_AT_AGE_Annual_2 (with_F=zero)"<<endl;
  if (reportdetail == 2) SS2out<<" ---";    // indicate not included
  SS2out<<endl;

// REPORT_KEYWORD DEFINITIONS
  SS2out<<endl<<"DEFINITIONS"<<endl;
  SS2out<<"N_seasons: "<<nseas<<endl;
  SS2out<<"N_sub_seasons: "<<N_subseas<<endl;
  SS2out<<"Sum_of_months_on_read_was:_ "<<sumseas<<" rescaled_to_sum_to: "<<sum(seasdur)<<endl;
  SS2out<<"Season_Durations: "<<seasdur<<endl;
  SS2out<<"Spawn_month: "<<spawn_month<<endl<<"Spawn_seas: "<<spawn_seas<<endl<<"Spawn_timing_in_season: "<<spawn_time_seas<<endl;
  SS2out<<"N_areas: "<<pop<<endl;
  SS2out<<"Start_year: "<<styr<<endl;
  SS2out<<"End_year: "<<endyr<<endl;
  SS2out<<"Retro_year: "<<retro_yr<<endl;
  SS2out<<"N_forecast_yrs: "<<N_Fcast_Yrs<<endl;
  SS2out<<"N_areas: "<<pop<<endl;
  SS2out<<"N_sexes: "<<gender<<endl;
  SS2out<<"Max_age: "<<nages<<endl;
  SS2out<<"Empirical_wt_at_age(0,1): "<<WTage_rd<<endl;
  SS2out<<"N_bio_patterns: "<<N_GP<<endl;
  SS2out<<"N_platoons: "<<N_platoon<<endl;
  SS2out<<"NatMort: "<<natM_type<<" # options:_(0)1Parm;_(1)N_breakpoints;_(2)Lorenzen;_(3)agespecific;_(4)agespec_withseasinterpolate"<<endl;
  SS2out<<"GrowthModel: "<<Grow_type<<" # options:_(1)vonBert with L1&L2;_(2)Richards with L1&L2;_(3)age_specific_K_incr;_(4)age_specific_K_decr; (5)age_specific_K_each; (6)not implemented"<<endl;
  SS2out<<"Maturity: "<<Maturity_Option<<" # options:_(1)length logistic;_(2)age logistic;_(3)read age-maturity;_(4)read age-fecundity;_(5)disabled;_(6)read length-maturity"<<endl;
  SS2out<<"Fecundity: "<<Fecund_Option<<" # options:_(1)eggs=Wt*(a+b*Wt);_(2)eggs=a*L^b;_(3)eggs=a*Wt^b;_(4)eggs=a+b*L;_(5)eggs=a+b*W"<<endl;
  SS2out<<"Start_from_par(0,1): "<<readparfile<<endl;
  SS2out<<"Do_all_priors(0,1): "<<Do_all_priors<<endl;
  SS2out<<"Use_softbound(0,1): "<<SoftBound<<endl;
  SS2out<<"N_nudata: "<<N_nudata<<endl;
  SS2out<<"Max_phase: "<<max_phase<<endl;
  SS2out<<"Current_phase: "<<current_phase()<<endl;
  SS2out<<"Jitter: "<<jitter<<endl;
  SS2out<<"ALK_tolerance: "<<ALK_tolerance<<endl;
  SS2out<<"Fleet_name: "; for(f=1;f<=Nfleet;f++) {SS2out<<" "<<fleetname(f);}
  SS2out<<endl<<"Fleet_type: "<<fleet_type<<endl;
  SS2out<<"Fleet_area: "<<fleet_area<<endl;
  SS2out<<"Lencomp_error_type: "<<Comp_Err_L<<endl;
  SS2out<<"Lencomp_error_parms: "<<Comp_Err_L2<<endl;
  SS2out<<"Agecomp_error_type: "<<Comp_Err_A<<endl;
  SS2out<<"Agecomp_error_parms: "<<Comp_Err_A2<<endl;
  SS2out<<"#"<<endl;
  SS2out<<"Fleet fleet_type timing area catch_units catch_mult survey_units survey_error Fleet_name"<<endl;
  for (f=1;f<=Nfleet;f++)
  {
    SS2out<<f<<" "<<fleet_setup(f)<<" "<<Svy_units(f)<<" "<<Svy_errtype(f)<<" "<<fleetname(f)<<endl;
  }

// REPORT_KEYWORD LIKELIHOOD
  k=current_phase();
  if(k>max_lambda_phase) k=max_lambda_phase;
  SS2out<<endl<<"LIKELIHOOD "<<obj_fun<<endl;                         //SS_Label_310
  SS2out<<"Component logL*Lambda Lambda"<<endl;
  SS2out<<"TOTAL "<<obj_fun<<" NA"<<endl;
  if(F_Method>1) SS2out <<"Catch "<<catch_like*column(catch_lambda,k)<<" NA"<<endl;
  SS2out <<"Equil_catch "<<equ_catch_like*init_equ_lambda(k)<<" "<<init_equ_lambda(k)<<endl;
  if(Svy_N>0) SS2out <<"Survey "<<surv_like*column(surv_lambda,k)<<" NA"<<endl;
  if(nobs_disc>0) SS2out <<"Discard "<<disc_like*column(disc_lambda,k)<<" NA"<<endl;
  if(nobs_mnwt>0) SS2out <<"Mean_body_wt "<<mnwt_like*column(mnwt_lambda,k)<<" NA"<<endl;
  if(Nobs_l_tot>0) SS2out <<"Length_comp "<<length_like_tot*column(length_lambda,k)<<" NA"<<endl;
  if(Nobs_a_tot>0) SS2out <<"Age_comp "<<age_like_tot*column(age_lambda,k)<<" NA"<<endl;
  if(nobs_ms_tot>0) SS2out <<"Size_at_age "<<sizeage_like*column(sizeage_lambda,k)<<" NA"<<endl;
  if(SzFreq_Nmeth>0) SS2out <<"SizeFreq "<<SzFreq_like*column(SzFreq_lambda,k)<<" NA"<<endl;
  if(Do_Morphcomp>0) SS2out <<"Morphcomp "<<Morphcomp_lambda(k)*Morphcomp_like<<" "<<Morphcomp_lambda(k)<<endl;
  if(Do_TG>0) SS2out <<"Tag_comp "<<TG_like1*column(TG_lambda1,k)<<" NA"<<endl;
  if(Do_TG>0) SS2out <<"Tag_negbin "<<TG_like2*column(TG_lambda2,k)<<" NA"<<endl;
  SS2out <<"Recruitment "<<recr_like*recrdev_lambda(k)<<" "<<recrdev_lambda(k)<<endl;
  SS2out <<"InitEQ_Regime "<<regime_like*regime_lambda(k)<<" "<<regime_lambda(k)<<endl;
  SS2out <<"Forecast_Recruitment "<<Fcast_recr_like<<" "<<Fcast_recr_lambda<<endl;
  SS2out <<"Parm_priors "<<parm_like*parm_prior_lambda(k)<<" "<<parm_prior_lambda(k)<<endl;
  if(SoftBound>0) SS2out <<"Parm_softbounds "<<SoftBoundPen<<" "<<" NA"<<endl;
  SS2out <<"Parm_devs "<<(sum(parm_dev_like))*parm_dev_lambda(k)<<" "<<parm_dev_lambda(k)<<endl;
  if(F_ballpark_yr>0) SS2out <<"F_Ballpark "<<F_ballpark_lambda(k)*F_ballpark_like<<" "<<F_ballpark_lambda(k)<<endl;
  if(F_ballpark_yr>0) SS2out <<"F_Ballpark(info_only)_"<<F_ballpark_yr<<"_estF_tgtF "<<annual_F(F_ballpark_yr,2)<<" "<<F_ballpark<<endl;
//  if(F_ballpark_yr>0) SS2out <<"F_Ballpark "<<F_ballpark_lambda(k)*F_ballpark_like<<" "<<F_ballpark_lambda(k)<<"  ##:est&obs: "<<annual_F(F_ballpark_yr,2)<<" "<<F_ballpark<<endl;
  SS2out <<"Crash_Pen "<<CrashPen_lambda(k)*CrashPen<<" "<<CrashPen_lambda(k)<<endl;
  SS2out<<"#_info_for_Laplace_calculations"<<endl;
  SS2out<<"NoBias_corr_Recruitment(info_only) "<<noBias_recr_like*recrdev_lambda(k)<<" "<<recrdev_lambda(k)<<endl;
  SS2out<<"Laplace_obj_fun(info_only) "<<JT_obj_fun<<" NA"<<endl;

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

// REPORT_KEYWORD PARAMETERS
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

// REPORT_KEYWORD DERIVED_QUANTITIES
  SS2out<<endl<<"DERIVED_QUANTITIES"<<endl;
  SS2out<<"SPR_report_basis: "<<SPR_report_label<<endl;
  SS2out<<"F_report_basis: "<<F_report_label<<endl;
  SS2out<<"B_ratio_denominator: "<<depletion_basis_label<<endl;

  SS2out<<" Label Value  StdDev (Val-1.0)/Stddev  CumNorm"<<endl;
  for (j=1;j<=N_STD_Yr;j++)
  {
    NP++;  SS2out<<" "<<ParmLabel(NP)<<" "<<SSB_std(j);
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

  if(Svy_N_sdreport>0)
  {
    k=0;
    for (f = 1; f <= Nfleet; ++f)
    {
      if (Svy_sdreport(f) > 0)
      {
        for (j=1;j<=Svy_N_fleet(f);j++)
        {
          active_count++; k++;
          SS2out<<fleetname(f)<<"_"<<Svy_yr(f,j)<<" ";
          SS2out<<Svy_est(f,j)<<" "<<CoVar(active_count,1)<<" "<<Svy_sdreport_est(k)<<endl;
        }
      }
    }
  }

// REPORT_KEYWORD MGPARM_BY_YEAR
   if(reportdetail == 1) {k1=YrMax;} else {k1=styr;}
   SS2out<<endl<<"MGparm_By_Year_after_adjustments"<<endl<<"Yr   Change? ";
   for (i=1;i<=N_MGparm;i++) SS2out<<" "<<ParmLabel(i);
   SS2out<<endl;
   for (y=styr;y<=k1;y++)
     SS2out<<y<<" "<<timevary_MG(y,0)<<" "<<mgp_save(y)<<endl;
   SS2out<<endl;

// REPORT_KEYWORD SELPARM_SIZE_BY_YEAR
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

// REPORT_KEYWORD SELPARM_AGE_BY_YEAR
   SS2out<<endl<<"selparm(Age)_By_Year_after_adjustments"<<endl<<"Fleet Yr  Change?  Parameters"<<endl;
   for (f=Nfleet+1;f<=2*Nfleet;f++)
   for (y=styr;y<=k1;y++)
     {
     k=N_selparmvec(f);
     if(k>0) SS2out<<f-Nfleet<<" "<<y<<" "<<timevary_sel(y,f)<<" "<<save_sp_len(y,f)(1,k)<<endl;
     }

// REPORT_KEYWORD RECRUITMENT_DISTRIBUTION
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
      Settle_age(settle_time)<<" "<<Settle_timing_seas(settle_time)<<" "<<recr_dist_unf(gp,settle_time,p)/(Bmark_Yr(8)-Bmark_Yr(7)+1)<<endl;
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

// REPORT_KEYWORD MORPH_INDEXING
   SS2out<<endl<<"MORPH_INDEXING"<<endl;
   SS2out<<"Index GP Sex BirthSeas Platoon Platoon_Dist Sex*GP Sex*GP*Settle BirthAge_Rel_Jan1"<<endl;
   for (g=1; g<=gmorph; g++)
   {
     SS2out<<g<<" "<<GP4(g)<<" "<<sx(g)<<" "<<Bseas(g)<<" "<<GP2(g)<<" "<<platoon_distr(GP2(g))<<" "<<GP(g)<<" "<<GP3(g)<<" "<<azero_G(g)<<endl;
   }

// REPORT_KEYWORD SIZEFREQ_TRANSLATION
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

// REPORT_KEYWORD MOVEMENT
   SS2out<<"#"<<endl<<"MOVEMENT in endyear"<<endl<<" Seas GP Source_area Dest_area minage maxage "<<age_vector<<endl;
   for (k=1;k<=do_migr2;k++)
   {
     SS2out<<move_def2(k)<<" "<<migrrate(endyr,k)<<endl;
   }

// REPORT_KEYWORD EXPLOITATION
   SS2out<<endl<<"EXPLOITATION"<<endl;
   SS2out<<"Info: Displays.various.annual.F.statistics.and.displays.apical.F.for.each.fleet.by.season"<<endl;
   SS2out<<"Info: F_Method:="<<F_Method;
   if(F_Method==1) {SS2out<<";.Pope's_approx,.fleet.F.is.mid-season.exploitation.fraction ";} else {SS2out<<";.Continuous_F;.fleet.F.will.be.multiplied.by.season.duration.when.it.is.used.and.in.the.F_std.calculation";}
   SS2out<<endl<<"Info: Displayed.fleet-specific.F.values.are.the.F.for.ages.with.compound.age-length-sex.selectivity=1.0"<<endl;
   SS2out<<"Info: F_std_basis:."<<F_report_label<<endl;
   if(F_reporting>=4)
   {SS2out<<"Info: Annual_F.shown.here.is.done.by.the.Z-M.method.for.ages:."<<F_reporting_ages(1)<<"-"<<F_reporting_ages(2)<<endl;}
   else
   {SS2out<<"Info: Annual_F.shown.here.is.done.by.the.Z-M.method.for.nages/2="<<nages/2<<endl;}
   SS2out<<"#"<<endl;
   SS2out<<"Yr Seas Seas_dur F_std annual_F annual_M ";
   for (f=1;f<=Nfleet;f++)
   if(fleet_type(f)<=2)
   {SS2out<<" "<<fleetname(f);}
   SS2out<<endl;
   SS2out<<"Catchunits: _ _ _ _ _ ";
   for (f=1;f<=Nfleet;f++)
   if(fleet_type(f)<=2)
   {if(catchunits(f)==1) {SS2out<<" Bio ";} else {SS2out<<" Num ";}}
   SS2out<<endl<<"FleetType: _ _ _ _ _ ";
   for (f=1;f<=Nfleet;f++)
   if(fleet_type(f)<=2)
   {if(fleet_type(f)==1) {SS2out<<" Catch ";} else {SS2out<<" Bycatch ";}}
   SS2out<<endl<<"FleetArea: _ _ _ _ _ ";
   for (f=1;f<=Nfleet;f++)
   if(fleet_type(f)<=2)
   {SS2out<<" "<<fleet_area(f);}
      SS2out<<endl<<"FleetID: _ _ _ _ _ ";
   for (f=1;f<=Nfleet;f++)
   if(fleet_type(f)<=2)
   {SS2out<<" "<<f;}
   SS2out<<endl;
   if(N_init_F>0)
   {
     for (s=1;s<=nseas;s++)
     {
       SS2out<<"INIT "<<s<<" "<<seasdur(s)<<" _  _  _ ";
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
     SS2out<<y<<" "<<s<<" "<<seasdur(s);
     if(s==1 && STD_Yr_Reverse_F(y)>0 ) {SS2out<<" "<<F_std(STD_Yr_Reverse_F(y))<<" "<<annual_F(y)(2,3);} else {SS2out<<" _ _ _ ";}
     for(f=1;f<=Nfleet;f++)
     if(fleet_type(f)<=2)
      {SS2out<<" "<<Hrate(f,t);}
     SS2out<<endl;
   }

 /*  old code from 3.30.12 below for EXPLOITATION
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
 */
 
// REPORT_KEYWORD CATCH
//  Fleet Fleet_Name Area Yr Era Seas Subseas Month Time
  SS2out<<endl<<"CATCH "<<endl<<"Fleet Fleet_Name Area Yr Seas Time Obs Exp Mult Exp*Mult se F  Like sel_bio kill_bio ret_bio sel_num kill_num ret_num"<<endl;
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
        SS2out<<f<<" "<<fleetname(f)<<" "<<fleet_area(f)<<" ";
        if(y<styr) {SS2out<<"INIT ";} else {SS2out<<y<<" ";}
        SS2out<<s<<" "<<temp<<" "<<catch_ret_obs(f,t)<<" "<<catch_fleet(t,f,gg)<<" "<<catch_mult(y,f)<<" "<<catch_mult(y,f)*catch_fleet(t,f,gg);
        SS2out<<" "<<catch_se(t,f)<<" "<<Hrate(f,t)<<" ";
        if(fleet_type(f)==1)
          {
            if(catch_ret_obs(f,t)>0 && F_Method>1)
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
// REPORT_KEYWORD TIME_SERIES
//  Fleet Fleet_Name Area Yr Era Seas Subseas Month Time
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
    if(y<=endyr && p==1) {Smry_Table(y,1)=0.; Smry_Table(y)(15,17).initialize();}
    for (s=1;s<=nseas;s++)
    {
    t = styr+(y-styr)*nseas+s-1;
    bio_t=t;
    if(y<=styr) {bio_t=styr-1+s;}
    Bio_Comp.initialize();
    Num_Comp.initialize();
    totbio.initialize(); smrybio.initialize(); smrynum.initialize(); SSB_vir_LH.initialize(); smryage.initialize();
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
     SSB_vir_LH += natage(t,p,g)*virg_fec(g);
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
    if(gender_rd==-1) SSB_vir_LH*=femfrac(1);
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
      temp=sum(SSB_pop_gp(y,p));
      if(Hermaphro_maleSPB==1) temp+=sum(MaleSPB(y,p));
      SS2out<<temp;
    }
    else
    {SS2out<<" _ ";}
    SS2out<<" "<<Recr(p,t)<<" ";
    if(s==spawn_seas)
    {
      SS2out<<SSB_pop_gp(y,p);
      if(Hermaphro_Option!=0) SS2out<<MaleSPB(y,p);
    }
    else
    {
    for (gp=1;gp<=N_GP;gp++) {SS2out<<" _ ";}

    }
    SS2out<<" "<<Bio_Comp<<" "<<Num_Comp;
    if(s==1 && y<=endyr) {Smry_Table(y,1)+=totbio; Smry_Table(y,15)+=smryage;}  // already calculated for the forecast years
    for (f=1;f<=Nfleet;f++)
    if(fleet_type(f)<=2)
    {
      if(fleet_area(f)==p&&y>=styr-1)
      {
        SS2out<<" "<<catch_fleet(t,f)<<" ";
        if(y<=endyr) {SS2out<<catch_ret_obs(f,t)<<" "<<Hrate(f,t);} else {SS2out<<" _ "<<Hrate(f,t);}
//        if(y<=endyr) {Smry_Table(y,4)+=catch_fleet(t,f,1); Smry_Table(y,5)+=catch_fleet(t,f,2); Smry_Table(y,6)+=catch_fleet(t,f,3);}
      }
      else
      {SS2out<<" 0 0 0 0 0 0 0 0 ";}
    }
    if(s==spawn_seas)
        {SS2out<<" "<<SSB_vir_LH;}
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

// REPORT_KEYWORD SPR_SERIES
//  Fleet Fleet_Name Area Yr Era Seas Subseas Month Time
   SS2out<<endl<<"SPR_series_uses_R0= "<<Recr_virgin<<endl<<"###note_YPR_unit_is_Dead_Biomass"<<endl;
   SS2out<<"Depletion_basis: "<<depletion_basis<<" # "<<depletion_basis_label<<endl;
   SS2out<<"F_report_basis: "<<F_reporting<<" # "<<F_report_label<<endl;
   SS2out<<"SPR_report_basis: "<<SPR_reporting<<" # "<<SPR_report_label<<endl;
   // note  GENTIME is mean age of spawners weighted by fec(a)
   SS2out<<"Yr Era Bio_all Bio_Smry SSBzero SSBfished SSBfished/R SPR SPR_report YPR GenTime Deplete F_report"<<
   " Actual: Bio_all Bio_Smry Num_Smry MnAge_Smry Enc_Catch Dead_Catch Retain_Catch MnAge_Catch SSB Recruits Tot_Exploit"<<
   " More_F(by_Morph): ";
   for (g=1;g<=gmorph;g++) {SS2out<<" aveF_"<<g;}
   for (g=1;g<=gmorph;g++) {SS2out<<" maxF_"<<g;}
   SS2out<<" Enc_Catch_B Dead_Catch_B Retain_Catch_B  Enc_Catch_N Dead_Catch_N Retain_Catch_N sum_Apical_F F=Z-M  M";
   SS2out<<endl;

   for (y=styr;y<=YrMax;y++)
   {
     if(y<=endyr) {SS2out<<y<<" TIME ";}
      else  {SS2out<<y<<" FORE ";}
     SS2out<<Smry_Table(y)(9,12)<<" "<<(Smry_Table(y,12)/Recr_virgin)<<" "<<Smry_Table(y,12)/Smry_Table(y,11)<<" ";
     if(STD_Yr_Reverse_Ofish(y)>0) {SS2out<<SPR_std(STD_Yr_Reverse_Ofish(y))<<" ";} else {SS2out<<" _ ";}
     SS2out<<(Smry_Table(y,14)/Recr_virgin)<<" "<<Smry_Table(y,13)<<" ";
     if(STD_Yr_Reverse_Dep(y)>0) {SS2out<<depletion(STD_Yr_Reverse_Dep(y));} else {SS2out<<" _ ";}
     if(y>=styr && STD_Yr_Reverse_F(y)>0 ) {SS2out<<" "<<F_std(STD_Yr_Reverse_F(y));} else {SS2out<<" _ ";}
     SS2out<<" & "<<Smry_Table(y)(1,3)<<" "<<Smry_Table(y,15)/Smry_Table(y,3)<<" "<<Smry_Table(y)(4,6)<<" "<<Smry_Table(y,17)/(Smry_Table(y,16)+1.0e-06);
     SS2out<<" "<<SSB_yr(y)<<" "<<exp_rec(y,4)<<" "<<Smry_Table(y,5)/Smry_Table(y,2);
     SS2out<<" & "<<Smry_Table(y)(21,20+gmorph)<<" "<<Smry_Table(y)(21+gmorph,20+2*gmorph)<<" "<<annual_catch(y)<<" "<<annual_F(y)<<endl;
   } // end year loop
// end SPR time series
  SS2out<<endl<<"NOTE:_GENTIME_is_fecundity_weighted_mean_age"<<endl<<"NOTE:_MnAgeSmry_is_numbers_weighted_meanage_at_and_above_smryage(not_accounting_for_settlement_offsets)"<<endl;

// REPORT_KEYWORD Kobe_Plot
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
    SS2out<<y<<" "<<SSB_yr(y)/Bmsy<<" ";
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
       rmse(3)+=value(square(temp1)); n_rmse(3)+=1.; rmse(4)+=biasadj(y);
     }
     else
     {
       rmse(1)+=value(square(temp1)); n_rmse(1)+=1.; rmse(2)+=biasadj(y);
     }
   }
   if(n_rmse(1)>0. && rmse(1)>0.) rmse(1) = sqrt(rmse(1)/n_rmse(1));  // rmse during main period
   if(n_rmse(1)>0.) rmse(2) = rmse(2)/n_rmse(1);  // mean biasadj during main period
   if(n_rmse(3)>0. && rmse(3)>0.) rmse(3) = sqrt(rmse(3)/n_rmse(3));  //rmse during early period
   if(n_rmse(3)>0.) rmse(4) = rmse(4)/n_rmse(3);  // mean biasadj during early period

// REPORT_KEYWORD SPAWN_RECRUIT

  dvariable steepness=SR_parm(2);
  SS2out<<endl<<"SPAWN_RECRUIT Function: "<<SR_fxn<<"  RecDev_method: "<<do_recdev<<"   sum_recdev: "<<sum_recdev<<endl<<
  SR_parm(1)<<" Ln(R0) "<<mfexp(SR_parm(1))<<endl<<
  steepness<<" steepness"<<endl<<
  Bmsy/SSB_virgin<<" Bmsy/Bzero ";
  if(SR_fxn==8)
  {
    dvariable Shepherd_c;
    dvariable Shepherd_c2;
    dvariable Hupper;
    Shepherd_c=SR_parm(3);
    Shepherd_c2=pow(0.2,Shepherd_c);
    Hupper=1.0/(5.0*Shepherd_c2);
    temp=0.2+(SR_parm(2)-0.2)/(0.8)*(Hupper-0.2);
    SS2out<<" Shepherd_c: "<<Shepherd_c<<" steepness_limit: "<<Hupper<<" Adjusted_steepness: "<<temp;
  }
  else if(SR_fxn==9)
  {
    SS2out<<" Ricker_Power: "<<SR_parm(3);
  }
  
  SS2out<<endl;
  SS2out<<sigmaR<<" sigmaR"<<endl;
  SS2out<<init_equ_steepness<<"  # 0/1 to use steepness in initial equ recruitment calculation"<<endl;

  SS2out<<SR_parm(N_SRparm2-1)<<" init_eq:  see below"<<endl<<
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

  SS2out<<"Yr SpawnBio exp_recr with_regime bias_adjusted pred_recr dev biasadjuster era mature_bio mature_num raw_dev"<<endl;
  SS2out<<"S/Rcurve "<<SSB_virgin<<" "<<Recr_virgin<<endl;
  y=styr-2;
  SS2out<<"Virg "<<SSB_yr(y)<<" "<<exp_rec(y)<<" - "<<0.0<<" Virg "<<SSB_B_yr(y)<<" "<<SSB_N_yr(y)<<" 0.0 "<<endl;
  y=styr-1;
  SS2out<<"Init "<<SSB_yr(y)<<" "<<exp_rec(y)<<" - "<<0.0<<" Init "<<SSB_B_yr(y)<<" "<<SSB_N_yr(y)<<" "<<0.0<<endl;

  if(recdev_first<styr)
  {
    for (y=recdev_first;y<=styr-1;y++)
    {
      SS2out<<y<<" "<<SSB_yr(styr-1)<<" "<<exp_rec(styr-1,1)<<" "<<exp_rec(styr-1,2)<<" "<<exp_rec(styr-1,3)*mfexp(-biasadj(y)*half_sigmaRsq)<<" "<<
      exp_rec(styr-1,3)*mfexp(recdev(y)-biasadj(y)*half_sigmaRsq)<<" "
      <<recdev(y)<<" "<<biasadj(y)<<" Init_age "<<SSB_B_yr(styr-1)<<" "<<SSB_N_yr(styr-1)<<" "<<recdev(y)<<endl;   // newdev approach uses devs for initial agecomp directly
    }
  }
   for (y=styr;y<=YrMax;y++)
   {
     SS2out<<y<<" "<<SSB_yr(y)<<" "<<exp_rec(y)<<" ";
     if(recdev_do_early>0 && y>=recdev_early_start && y<=recdev_early_end)
       {SS2out<<log(exp_rec(y,4)/exp_rec(y,3))<<" "<<biasadj(y)<<" Early "<<SSB_B_yr(y)<<" "<<SSB_N_yr(y)<<" "<<recdev(y);}
     else if(y>=recdev_start && y<=recdev_end)
       {SS2out<<log(exp_rec(y,4)/exp_rec(y,3))<<" "<<biasadj(y)<<" Main "<<SSB_B_yr(y)<<" "<<SSB_N_yr(y)<<" "<<recdev(y);}
     else if(Do_Forecast>0 && y>recdev_end)
     {
        SS2out<<log(exp_rec(y,4)/exp_rec(y,3))<<" "<<biasadj(y);
        if(y<=endyr)
        {SS2out<<" Late "<<SSB_B_yr(y)<<" "<<SSB_N_yr(y)<<" "<<Fcast_recruitments(y);}
        else
        {SS2out<<" Fore "<<SSB_B_yr(y)<<" "<<SSB_N_yr(y)<<" "<<Fcast_recruitments(y);}
      }
     else
       {SS2out<<" _ _ Fixed";}
//       SS2out<<" "<<recdev_cycle_parm(gg);
     SS2out<<endl;
   }

// REPORT_KEYWORD SPAWN_RECR_CURVE
   {
    SS2out<<endl<<"#"<<endl<<"Full_Spawn_Recr_Curve"<<endl<<"SSB/SSB_virgin    SSB    Recruitment"<<endl;
    y=styr;
    SR_parm_work = SR_parm_byyr(styr);
    for(f=1;f<=120;f++)
    {
      SSB_current=double(f)/100.*SSB_virgin;
      temp=Spawn_Recr(SSB_virgin,Recr_virgin,SSB_current);
      SS2out<<SSB_current/SSB_virgin<<" "<<SSB_current<<" "<<exp_rec(y,1)<<endl;
    }
   }
// ******************************************************************************
//                                             SS_Label_340

// REPORT_KEYWORD INDEX_2 Survey Observations by Year
//  where show_time(t) contains:  yr, seas
//  data_time(ALK,f) has real month; 2nd is timing within season; 3rd is year.fraction
//  show_time2(ALK) has yr, seas, subseas
  SS2out <<endl<< "INDEX_2" << endl;
  rmse = 0.0;  n_rmse = 0.0; mean_CV=0.0; mean_CV2=0.0; mean_CV3=0.0;
  SS2out<<"Fleet Fleet_name Area Yr Seas Subseas Month Time Vuln_bio Obs Exp Calc_Q Eff_Q SE Dev Like Like+log(s) SuprPer Use"<<endl;
  if(Svy_N>0)
  {
    for (f=1;f<=Nfleet;f++)
    {
      in_superperiod=0;
      for (i=1;i<=Svy_N_fleet(f);i++)
      {
        t=Svy_time_t(f,i);
        ALK_time=Svy_ALK_time(f,i);
          SS2out<<f<<" "<<fleetname(f)<<" "<<fleet_area(f)<<" "<<Show_Time2(ALK_time)<<" "<<data_time(ALK_time,f,1)<<" "<<data_time(ALK_time,f,3)<<" "<<Svy_selec_abund(f,i)<<" "<<Svy_obs(f,i)<<" ";
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

// REPORT_KEYWORD INDEX_1  Survey Fit Summary
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

// REPORT_KEYWORD INDEX_3  Survey_Q_setup
  SS2out <<"#"<<endl<< "INDEX_3"<<endl<<"Fleet  Q_parm_assignments"<<endl;
  for (f=1;f<=Nfleet;f++)
    {SS2out<<f<<" "<<Q_setup_parms(f,1)<<" _ "<<Q_setup_parms(f,2)<<" _ "<<Q_setup_parms(f)(3,4)<<" "<<fleetname(f)<<endl;}

// REPORT_KEYWORD DISCARD_SPECIFICATION
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

// REPORT_KEYWORD DISCARD_OUTPUT  Discard observations by year
  SS2out<<"#"<<endl<<"DISCARD_OUTPUT "<<endl;
  SS2out<<"Fleet Fleet_Name Area Yr Seas Subseas Month Time Obs Exp Std_in Std_use Dev Like Like+log(s) SuprPer Use Obs_cat Exp_cat catch_mult exp_cat*catch_mult F_rate"<<endl;
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
      SS2out<<f<<" "<<fleetname(f)<<" "<<fleet_area(f)<<" "<<Show_Time2(ALK_time)<<" "<<data_time(ALK_time,f,1)<<" "<<data_time(ALK_time,f,3)
      <<" "<<obs_disc(f,i)<<" "<<exp_disc(f,i)<<" "<<" "<<cv_disc(f,i)<<" "<<sd_disc(f,i);

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

// REPORT_KEYWORD MEAN_BODY_WT_OUTPUT
  SS2out <<endl<< "MEAN_BODY_WT_OUTPUT"<<endl;
  if(nobs_mnwt>0) SS2out<<"log(L)_based_on_T_distribution_with_DF=_"<<DF_bodywt<< endl;
  SS2out<<"Fleet Fleet_Name Area Yr  Seas Subseas Month Time Part Type Obs Exp CV Dev NeglogL Neg(logL+log(s)) Use"<<endl;
//  10 items are:  1yr, 2seas, 3fleet, 4part, 5type, 6obs, 7se, then three intermediate variance quantities
  if(nobs_mnwt>0)
  for (i=1;i<=nobs_mnwt;i++)
  {
    t=mnwtdata(1,i);
    f=abs(mnwtdata(3,i));
    ALK_time=mnwtdata(11,i);
    SS2out << mnwtdata(3,i)<<" "<<fleetname(f)<<" "<<fleet_area(f)<<" "<<Show_Time2(ALK_time)<<" "<<data_time(ALK_time,f,1)<<" "<<data_time(ALK_time,f,3)<<" "
    <<mnwtdata(4,i)<<" "<<mnwtdata(5,i)<<" "<<mnwtdata(6,i)<<" "<<exp_mnwt(i)<<" "<<mnwtdata(7,i);
    if(mnwtdata(3,i)>0.)
    {
      SS2out<<" "<<mnwtdata(6,i)-exp_mnwt(i)<<" "<<
       0.5*(DF_bodywt+1.)*log(1.+square(mnwtdata(6,i)-exp_mnwt(i))/mnwtdata(9,i))<<" "<<
       0.5*(DF_bodywt+1.)*log(1.+square(mnwtdata(6,i)-exp_mnwt(i))/mnwtdata(9,i))+ mnwtdata(10,i)<<" "<<1;
    }
    else
    {
      SS2out<<" NA NA NA -1";
    }
    SS2out<<endl;
  }

// REPORT_KEYWORD FIT_LEN_COMPS
  SS2out <<endl<< "FIT_LEN_COMPS" << endl;                     // SS_Label_350
  SS2out<<"Fleet Fleet_Name Area Yr Seas Subseas Month Time Sexes Part SuprPer Use Nsamp effN Like";
  SS2out<<" All_obs_mean All_exp_mean All_delta All_exp_5% All_exp_95% All_DurWat";
  if(gender==2) SS2out<<" F_obs_mean F_exp_mean F_delta F_exp_5% F_exp_95% F_DurWat M_obs_mean M_exp_mean M_delta M_exp_5% M_exp_95% M_DurWat %F_obs %F_exp ";
  SS2out<<endl;
  rmse = 0.0;  n_rmse = 0.0; mean_CV=0.0;  Hrmse=0.0; Rrmse=0.0; neff_l.initialize();
  in_superperiod=0;
  data_type=4;
  dvar_vector more_comp_info(1,20);
  dvariable cumdist;
  dvariable cumdist_save;
  dvector minsamp(1,Nfleet);
  dvector maxsamp(1,Nfleet);
  minsamp=10000.;
  maxsamp=0.;
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
     more_comp_info.initialize();
       neff_l(f,i)  = exp_l(f,i)*(1-exp_l(f,i))+1.0e-06;     // constant added for stability
       neff_l(f,i) /= (obs_l(f,i)-exp_l(f,i))*(obs_l(f,i)-exp_l(f,i))+1.0e-06;
   dvector tempvec_l(1,exp_l(f,i).size());
       tempvec_l = value(exp_l(f,i));
       more_comp_info=process_comps(gender,gen_l(f,i),len_bins_dat2,len_bins_dat_m2,tails_l(f,i),obs_l(f,i),tempvec_l);
     if(header_l(f,i,3)>0)
     {
       n_rmse(f)+=1.;
       rmse(f)+=value(neff_l(f,i));
       mean_CV(f)+=nsamp_l(f,i);
       Hrmse(f)+=value(1./neff_l(f,i));
       Rrmse(f)+=value(neff_l(f,i)/nsamp_l(f,i));
       if(nsamp_l(f,i)<minsamp(f)) minsamp(f)=nsamp_l(f,i);
       if(nsamp_l(f,i)>maxsamp(f)) maxsamp(f)=nsamp_l(f,i);
     }
    
     
//  SS2out<<"Fleet Fleet_Name Area Yr Month Seas Subseas Time Sexes Part SuprPer Use Nsamp effN Like";
//      temp=abs(header_l_rd(f,i,2));
//      if(temp>999) temp-=1000;
      SS2out<<f<<" "<<fleetname(f)<<" "<<fleet_area(f)<<" "<<Show_Time2(ALK_time)<<" "<<data_time(ALK_time,f,1)<<" "<<data_time(ALK_time,f,3)<<" "<<gen_l(f,i)<<" "<<mkt_l(f,i);
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
   "Factor Fleet Recommend_var_adj # N Npos min_inputN max_inputN mean_adj_inputN mean_effN HarMean Curr_Var_Adj Fleet_name"<<endl;
   for (f=1;f<=Nfleet;f++)
   {
    if(n_rmse(f)>0) 
    {
      rmse(f)/=n_rmse(f); mean_CV(f)/=n_rmse(f); Hrmse(f)=n_rmse(f)/Hrmse(f); Rrmse(f)/=n_rmse(f);
      SS2out<<"4 "<<f<<" "<<Hrmse(f)/mean_CV(f)*var_adjust(4,f)<<" # "<<Nobs_l(f)<<" "<<n_rmse(f)<<" " <<
      minsamp(f)<<" "<<maxsamp(f)<<" "<<mean_CV(f)<<" "<<rmse(f)<<" "<<Hrmse(f)<<" "<<var_adjust(4,f)<<" "<<fleetname(f)<<endl;
   }
   }

// REPORT_KEYWORD FIT_AGE_COMPS
  SS2out <<endl<< "FIT_AGE_COMPS" << endl;
  SS2out<<"Fleet Fleet_Name Area Yr Seas Subseas Month Time Sexes Part Ageerr Lbin_lo Lbin_hi SuprPer Use Nsamp effN Like ";
  SS2out<<" All_obs_mean All_exp_mean All_delta All_exp_5% All_exp_95% All_DurWat";
  if(gender==2) SS2out<<" F_obs_mean F_exp_mean F_delta F_exp_5% F_exp_95% F_DurWat M_obs_mean M_exp_mean M_delta M_exp_5% M_exp_95% M_DurWat %F_obs %F_exp ";
  SS2out<<endl;
  rmse = 0.0;  n_rmse = 0.0; mean_CV=0.0;  Hrmse=0.0; Rrmse=0.0;  minsamp=10000.; maxsamp=0.;
   if(Nobs_a_tot>0)
   for(f=1;f<=Nfleet;f++)
   for(i=1;i<=Nobs_a(f);i++)
    {
      t=Age_time_t(f,i);
      ALK_time=Age_time_ALK(f,i);
      more_comp_info.initialize();
       neff_a(f,i)  = exp_a(f,i)*(1-exp_a(f,i))+1.0e-06;     // constant added for stability
       neff_a(f,i) /= (obs_a(f,i)-exp_a(f,i))*(obs_a(f,i)-exp_a(f,i))+1.0e-06;
       dvector tempvec_a(1,exp_a(f,i).size());
       tempvec_a = value(exp_a(f,i));
       more_comp_info=process_comps(gender,gen_a(f,i),age_bins,age_bins_mean,tails_a(f,i),obs_a(f,i), tempvec_a);
     if(nsamp_a(f,i)>0 && header_a(f,i,3)>0)
     {
       n_rmse(f)+=1.;
       rmse(f)+=value(neff_a(f,i));
       mean_CV(f)+=nsamp_a(f,i);
       Hrmse(f)+=value(1./neff_a(f,i));
       Rrmse(f)+=value(neff_a(f,i)/nsamp_a(f,i));
       if(nsamp_a(f,i)<minsamp(f)) minsamp(f)=nsamp_a(f,i);
       if(nsamp_a(f,i)>maxsamp(f)) maxsamp(f)=nsamp_a(f,i);
     }

//  SS2out<<"Fleet Fleet_Name Area Yr  Seas Subseas Month Time Sexes Part Ageerr Lbin_lo Lbin_hi Nsamp effN Like SuprPer Use";
      temp=abs(header_a_rd(f,i,2));
      if(temp>999) temp-=1000;
     SS2out<<f<<" "<<fleetname(f)<<" "<<fleet_area(f)<<Show_Time2(ALK_time)<<" "<<data_time(ALK_time,f,1)<<" "<<data_time(ALK_time,f,3)<<" "<<gen_a(f,i)<<" "<<mkt_a(f,i)<<" "<<ageerr_type_a(f,i)<<" "<<Lbin_lo(f,i)<<" "<<Lbin_hi(f,i)<<" ";
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
      SS2out<<nsamp_a(f,i)<<" "<<neff_a(f,i)<<" "<<age_like(f,i)<<" "<<more_comp_info(1,6);
      if(gender==2) SS2out<<" "<<more_comp_info(7,20);
      SS2out<<endl;
    }

   SS2out<<endl<<"Age_Comp_Fit_Summary"<<endl<<
   "Factor Fleet Recommend_var_adj # N Npos min_inputN max_inputN mean_adj_inputN mean_effN HarMean Curr_Var_Adj Fleet_name"<<endl;
   for(f=1;f<=Nfleet;f++)
   {
    if(n_rmse(f)>0)
    {
      rmse(f)/=n_rmse(f); mean_CV(f)/=n_rmse(f); Hrmse(f)=n_rmse(f)/Hrmse(f); Rrmse(f)/=n_rmse(f);
      SS2out<<"5 "<<f<<" "<<Hrmse(f)/mean_CV(f)*var_adjust(5,f)<<" # "<<Nobs_a(f)<<" "<<n_rmse(f)<<" "<<
      minsamp(f)<<" "<<maxsamp(f)<<" "<<mean_CV(f)<<" "<<rmse(f)<<" "<<Hrmse(f)<<" "<<var_adjust(5,f)<<" "<<fleetname(f)<<endl;
    }
   }

// REPORT_KEYWORD FIT_SIZE_COMPS
  SS2out <<endl<< "FIT_SIZE_COMPS" << endl;                     // SS_Label_350
    
    if(SzFreq_Nmeth>0)       //  have some sizefreq data
    {
      SzFreq_effN.initialize();
      SzFreq_eachlike.initialize();
      for(int sz_method=1; sz_method<=SzFreq_Nmeth; sz_method++)
      {
        SS2out<<"#Method: "<<sz_method;
        SS2out<<"  #Units: "<<SzFreq_units_label(SzFreq_units(sz_method));
        SS2out<<"  #Scale: "<<SzFreq_scale_label(SzFreq_scale(sz_method));
        SS2out<<"  #Add_to_comp: "<<SzFreq_mincomp(sz_method)<<"  #N_bins: "<<SzFreq_Nbins(sz_method)<<endl;
        SS2out<<"Fleet Fleet_Name Area Yr  Seas Subseas Month Time Sexes Part SuprPer Use Nsamp effN Like";
        SS2out<<" All_obs_mean All_exp_mean All_delta All_exp_5% All_exp_95% All_DurWat"<<endl;
        rmse = 0.0;  n_rmse = 0.0; mean_CV=0.0;  Hrmse=0.0; Rrmse=0.0;
        minsamp=10000.;
        maxsamp=0.;
       
        dvector sz_tails(1,4);
        sz_tails(1)=1;
        sz_tails(2)=SzFreq_Nbins(sz_method);
        sz_tails(3)=SzFreq_Nbins(sz_method)+1;
        sz_tails(4)=2*SzFreq_Nbins(sz_method);
        for(f=1;f<=Nfleet;f++)
        {
          in_superperiod=0;
          for (iobs=1;iobs<=SzFreq_totobs;iobs++)
          {
            more_comp_info.initialize();
            k=SzFreq_obs_hdr(iobs,6);
            if(k==sz_method && abs(SzFreq_obs_hdr(iobs,3))==f)
            {
              if(SzFreq_obs_hdr(iobs,1)>=styr)  // year is positive, so use this obs
              {
                y=SzFreq_obs_hdr(iobs,1);
                t=SzFreq_time_t(iobs);
                ALK_time=SzFreq_time_ALK(iobs);
                gg=SzFreq_obs_hdr(iobs,4);  // gender
                p=SzFreq_obs_hdr(iobs,5);  // partition
                z1=SzFreq_obs_hdr(iobs,7);
                z2=SzFreq_obs_hdr(iobs,8);
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
                  dvector tempvec_l (1,SzFreq_exp(iobs).size());
                  tempvec_l=value(SzFreq_exp(iobs));
                  more_comp_info=process_comps(gender,gg,SzFreq_bins(sz_method),SzFreq_means(sz_method),sz_tails,SzFreq_obs(iobs),tempvec_l);
                if(SzFreq_obs_hdr(iobs,3)>0)
                {
                  n_rmse(f)+=1.;
                  rmse(f)+=SzFreq_effN(iobs);
                  mean_CV(f)+=SzFreq_sampleN(iobs);
                  if(SzFreq_sampleN(iobs)<minsamp(f)) minsamp(f)=SzFreq_sampleN(iobs);
                  if(SzFreq_sampleN(iobs)>maxsamp(f)) maxsamp(f)=SzFreq_sampleN(iobs);
                  Hrmse(f)+=1./SzFreq_effN(iobs);
                  Rrmse(f)+=SzFreq_effN(iobs)/SzFreq_sampleN(iobs);
                }
                else
                {
                  SzFreq_effN(iobs)=0.;
                  SzFreq_eachlike(iobs)=0.;
                }
                temp= SzFreq_obs1(iobs,3);  //  use original input value because 
                if(temp>999) temp-=1000.;
                SS2out<<f<<" "<<fleetname(f)<<" "<<fleet_area(f)<<" "<<Show_Time2(ALK_time)<<" "<<data_time(ALK_time,f,1)<<" "<<data_time(ALK_time,f,3)<<" "<<gg<<" "<<p;
     if(SzFreq_obs_hdr(iobs,2)<0 && in_superperiod==0)
      {SS2out<<" start "; in_superperiod=1;}
      else if (SzFreq_obs_hdr(iobs,2)<0 && in_superperiod==1)
      {SS2out<<" end "; in_superperiod=0;}
      else if (in_superperiod==1)
      {SS2out<<" in ";}
      else
      {SS2out<<" _ ";}
      if(SzFreq_obs_hdr(iobs,3)<0)
      {SS2out<<" skip ";}
      else
      {SS2out<<" _ ";}                
                SS2out<<" "<<SzFreq_sampleN(iobs)<<"  "<<SzFreq_effN(iobs)<<"  "<<SzFreq_eachlike(iobs)<<" "<<more_comp_info(1,6);
                if(gender==2) SS2out<<" "<<more_comp_info(7,20);
                SS2out<<endl;
              }  //  end finding observation that is being used
            }  //  end observation matching selected method
          }  //  end loop of observations
        }  //  end fleet loop
  //      SS2out<<"Fleet N Npos mean_effN mean(inputN*Adj) HarMean(effN) Mean(effN/inputN) MeaneffN/MeaninputN Var_Adj"<<endl;
        SS2out<<"Factor Fleet Recommend_Var_Adj # N Npos min_inputN max_inputN mean_adj_inputN mean_effN HarMean Curr_Var_Adj Fleet_name"<<endl;
        for(f=1;f<=Nfleet;f++)
        {
          if(n_rmse(f)>0)
          {
            rmse(f)/=n_rmse(f); mean_CV(f)/=n_rmse(f); Hrmse(f)=n_rmse(f)/Hrmse(f); Rrmse(f)/=n_rmse(f);
            SS2out<<"7 "<<f<<" "<<Hrmse(f)/mean_CV(f)*var_adjust(7,f)<<" #  NA "<<n_rmse(f)<<" "<<minsamp(f)<<" "
            <<maxsamp(f)<<" "<<mean_CV(f)<<" "<<rmse(f)<<" "<<Hrmse(f)
            <<" "<<var_adjust(7,f)<<" "<<fleetname(f)<<endl;
          }
        }
      }  //  end loop of methods
    }  // end have sizecomp
    else
    {SS2out<<"#_none"<<endl;}

// REPORT_KEYWORD OVERALL_COMPS  average composition for all observations
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

// REPORT_KEYWORD LEN_SELEX
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
//    if(y>=styr && y<=endyr)
//    {
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
//    }
    SS2out<<"Keep "<<f<<" "<<y<<" "<<gg<<" "<<y<<"_"<<f<<"_Keep";
    for (z=1;z<=nlength;z++) {SS2out<<" "<<sel_l_r(y,f,gg,z);}
    SS2out<<endl;
    SS2out<<"Dead "<<f<<" "<<y<<" "<<gg<<" "<<y<<"_"<<f<<"_Dead";
    for (z=1;z<=nlength;z++) {SS2out<<" "<<discmort2(y,f,gg,z);}
    SS2out<<endl;
  }

// REPORT_KEYWORD AGE_SELEX
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
          if(fleet_type(f)<=2) SS2out<<"F "<<f<<" "<<y<<" "<<s<<" "<<sx(g)<<" "<<g<<" "<<y<<"_"<<f<<"_F"<<Hrate(f,t)*save_sel_fec(t,g,f)<<endl;
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

// REPORT_KEYWORD ENVIRONMENTAL_DATA
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

// REPORT_KEYWORD TAG_Recapture
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
// REPORT_KEYWORD NUMBERS_AT_AGE
    SS2out << endl << "NUMBERS_AT_AGE" << endl;       // SS_Label_410
    SS2out << "Area Bio_Pattern Sex BirthSeas Settlement Platoon Morph Yr Seas Time Beg/Mid Era"<<age_vector <<endl;
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

// REPORT_KEYWORD BIOMASS_AT_AGE
    SS2out << endl << "BIOMASS_AT_AGE" << endl;       // SS_Label_410
    SS2out << "Area Bio_Pattern Sex BirthSeas Settlement Platoon Morph Yr Seas Time Beg/Mid Era"<<age_vector <<endl;
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

// REPORT_KEYWORD NUMBERS_AT_LENGTH
    SS2out << endl << "NUMBERS_AT_LENGTH" << endl;
    SS2out << "Area Bio_Pattern Sex BirthSeas Settlement Platoon Morph Yr Seas Time Beg/Mid Era "<<len_bins <<endl;
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

// REPORT_KEYWORD BIOMASS_AT_LENGTH
    SS2out << endl << "BIOMASS_AT_LENGTH" << endl;
    SS2out << "Area Bio_Pattern Sex BirthSeas Settlement Platoon Morph Yr Seas Time Beg/Mid Era "<<len_bins <<endl;
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

// REPORT_KEYWORD F_AT_AGE
     SS2out <<endl<< "F_AT_AGE" << endl;              // SS_Label_420
     SS2out << "Area Fleet Sex Morph Yr Seas Era"<<age_vector <<endl;
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
         SS2out <<fleet_area(f)<<" "<<f<<" "<<sx(g)<<" "<<g<<" "<<y<<" "<<s;
         if(y==styr-1)
           {SS2out<<" INIT ";}
         else if (y<=endyr)
           {SS2out<<" TIME ";}
         else
           {SS2out<<" FORE ";}
         SS2out<<Hrate(f,t)*save_sel_fec(t,g,f)<< endl;
       }
     }
     }

// REPORT_KEYWORD CATCH_AT_AGE
     SS2out <<endl<< "CATCH_AT_AGE" << endl;              // SS_Label_420
     SS2out << "Area Fleet Sex  XX XX Type Morph Yr Seas XX Era"<<age_vector <<endl;
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
         SS2out <<fleet_area(f)<<" "<<f<<" "<<sx(g)<<" XX XX dead "<<g<<" "<<y<<" "<<s;
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

// REPORT_KEYWORD DISCARD_AT_AGE
     SS2out <<endl<< "DISCARD_AT_AGE" << endl;              // SS_Label_420
     SS2out << "Area Fleet Sex  XX XX Type Morph Yr Seas XX Era"<<age_vector <<endl;
     for (f=1;f<=Nfleet;f++)
     if(fleet_type(f)<=2 && Do_Retain(f)>0)
     for (g=1;g<=gmorph;g++)
     {
     if(use_morph(g)>0)
     {
       for (y=styr-1;y<=YrMax;y++)
       for (s=1;s<=nseas;s++)
       {
         t = styr+(y-styr)*nseas+s-1;
         SS2out <<fleet_area(f)<<" "<<f<<" "<<sx(g)<<" XX XX dead "<<g<<" "<<y<<" "<<s;
         if(y==styr-1)
           {SS2out<<" XX INIT ";}
         else if (y<=endyr)
           {SS2out<<" XX TIME ";}
         else
           {SS2out<<" XX FORE ";}
         SS2out<<catage(t,f,g)<< endl;
         SS2out <<fleet_area(f)<<" "<<f<<" "<<sx(g)<<" XX XX sel "<<g<<" "<<y<<" "<<s;
         if(y==styr-1)
           {SS2out<<" XX INIT ";}
         else if (y<=endyr)
           {SS2out<<" XX TIME ";}
         else
           {SS2out<<" XX FORE ";}
         SS2out<<disc_age(t,disc_fleet_list(f),g)<< endl;

         SS2out <<fleet_area(f)<<" "<<f<<" "<<sx(g)<<" XX XX ret "<<g<<" "<<y<<" "<<s;
         if(y==styr-1)
           {SS2out<<" XX INIT ";}
         else if (y<=endyr)
           {SS2out<<" XX TIME ";}
         else
           {SS2out<<" XX FORE ";}
         SS2out<<disc_age(t,disc_fleet_list(f)+N_retain_fleets,g)<< endl;

         SS2out <<fleet_area(f)<<" "<<f<<" "<<sx(g)<<" XX XX disc "<<g<<" "<<y<<" "<<s;
         if(y==styr-1)
           {SS2out<<" XX INIT ";}
         else if (y<=endyr)
           {SS2out<<" XX TIME ";}
         else
           {SS2out<<" XX FORE ";}
         SS2out<<disc_age(t,disc_fleet_list(f),g)-disc_age(t,disc_fleet_list(f)+N_retain_fleets,g)<< endl;
         }
     }
     }
  }

// REPORT_KEYWORD BIOLOGY
  SS2out <<endl<< "BIOLOGY "<<sum(use_morph)<<" "<<nlength<<" "<<nages<<" "<<nseas<<" N_Used_morphs;_lengths;_ages;_season;_by_season_in_endyr" << endl;
   SS2out<<"GP Bin Low Mean_Size Wt_len_F Mat_len Spawn Wt_len_M Fecundity"<<endl;
   for(gp=1;gp<=N_GP;gp++)
   for (z=1;z<=nlength;z++)
     {
      SS2out<<gp<<" "<<z<<" "<<len_bins(z)<<" "<<len_bins_m(z)<<" "<<wt_len(1,gp,z)<<" "<<mat_len(gp,z)<<" "<<mat_fec_len(gp,z);
      if(gender==2) {SS2out<<" "<<wt_len(1,N_GP+gp,z);}
      SS2out<<" "<<fec_len(gp,z)<<endl;
     }

// REPORT_KEYWORD NATURAL_MORTALITY
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
        {for (s=1;s<=nseas;s++) SS2out<<gp<<" "<<gg<<" "<<settle<<" "<<s<<" "<<natM_unf(s,g)/(Bmark_Yr(2)-Bmark_Yr(1)+1)<<endl;}
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

// REPORT_KEYWORD AGE_SPECIFIC_K
    if(Grow_type==3 || Grow_type==4)  //  age-specific K
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

// REPORT_KEYWORD GROWTH_PARAMETERS_derived
   SS2out<<endl<<"Growth_Parameters"<<endl<<" Count Yr Sex Platoon A1 A2 L_a_A1 L_a_A2 K A_a_L0 Linf CVmin CVmax natM_amin natM_max M_age0 M_nages"
   <<" WtLen1 WtLen2 Mat1 Mat2 Fec1 Fec2"<<endl;
   for (g=1;g<=save_gparm_print;g++) {SS2out<<save_G_parm(g)(1,2)<<" "<<sx(save_G_parm(g,3))<<" "<<save_G_parm(g)(3,22)<<endl;}

// REPORT_KEYWORD SEASONAL_BIOLOGY
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

// REPORT_KEYWORD Biology_at_age_by_morph
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

// REPORT_KEYWORD MEAN_BODY_WT by year
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

// REPORT_KEYWORD MEAN_SIZE_TIMESERIES  body length
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

// REPORT_KEYWORD AGE_LENGTH_KEY
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

// REPORT_KEYWORD AGE_AGE_KEY
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

// REPORT_KEYWORD COMPOSITION_DATABASE
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
  SS_compout<<"subseas is derived from month and the number of subseasons per season, which is: "<<N_subseas<<endl;
  SS_compout<<"Time_is_fraction_of_year_based_on_subseas, not directly on month"<<endl;
  SS_compout<<"If observations with same or different month value are assigned to the same subseas, then repli(cate) counter is incremented"<<endl;
  SS_compout<<"For_Tag_output,_Rep_contains_Tag_Group,_Bin_is_fleet_for_TAG1_and_Bin_is_Year.Seas_for_TAG2"<<endl;
  SS_compout<<"Column_Super?_indicates_super-periods;_column_used_indicates_inclusion_in_logL"<<endl;

  SS_compout <<endl<< "Composition_Database" << endl;           // SS_Label_480

  SS_compout<<"Yr Month Seas Subseas Time Fleet Area Repl. Sexes Kind Part Ageerr Sex Lbin_lo Lbin_hi Bin Obs Exp Pearson N effN Like Cum_obs Cum_exp SuprPer Used?"<<endl;
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
    data_type=4;  // for length comp
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
      real_month=abs(header_l_rd(f,i,2));
      if(real_month>999) real_month-=1000.;
      
      if(ALK_time==last_t)
      {repli++;}
      else
      {repli=1;last_t=ALK_time;}
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
            SS_compout<<header_l(f,i,1)<<" "<<real_month<<" "<<Show_Time2(ALK_time)(2,3)<<" "<<data_time(ALK_time,f,3)<<" "<<f<<" "<<fleet_area(f)<<" "<<repli<<" "<<gen_l(f,i)<<" LEN "<<mkt_l(f,i)<<" 0 "<<s_off<<" "<<
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

        SS_compout<<header_l(f,i,1)<<" "<<header_l(f,i,2)<<" "<<Show_Time2(ALK_time)(2,3)<<" "<<data_time(ALK_time,f,3)<<" "<<f<<" "<<fleet_area(f)<<" "<<repli<<" "<<gen_l(f,i)<<" LEN "
        <<mkt_l(f,i)<<" 0 "<<s_off<<" "<<1<<" "<<1<<endl;
      }
      if(gen_l(f,i)>=2 && gender==2)  // do males
      {
        s_off=2;
        for (z=tails_l(f,i,3);z<=tails_l(f,i,4);z++)
        {
           SS_compout<<header_l(f,i,1)<<" "<<real_month<<" "<<Show_Time2(ALK_time)(2,3)<<" "<<data_time(ALK_time,f,3)<<" "<<f<<" "<<fleet_area(f)<<" "<<repli<<" "<<gen_l(f,i)<<" LEN "<<mkt_l(f,i)<<" 0 "<<s_off<<" "<<
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
        SS_compout<<header_l(f,i,1)<<" "<<real_month<<" "<<Show_Time2(ALK_time)(2,3)<<" "<<data_time(ALK_time,f,3)<<" "<<f<<" "<<fleet_area(f)<<" "<<repli<<" "<<gen_l(f,i)<<" LEN "
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
      real_month=abs(header_a_rd(f,i,2));
      if(real_month>999) real_month-=1000.;
      if(ALK_time==last_t)
      {repli++;}
      else
      {repli=1;last_t=ALK_time;}
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
          {SS_compout<<header_a(f,i,1)<<" "<<real_month<<" "<<Show_Time2(ALK_time)(2,3)<<" "<<data_time(ALK_time,f,3)<<" "<<f<<" "<<fleet_area(f)<<" "<<repli<<" "<<gen_a(f,i)<<" AGE "<<mkt_a(f,i)<<" "<<ageerr_type_a(f,i)
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

        SS_compout<<header_a(f,i,1)<<" "<<real_month<<" "<<Show_Time2(ALK_time)(2,3)<<" "<<data_time(ALK_time,f,3)<<" "<<f<<" "<<fleet_area(f)<<" "<<repli<<" "<<gen_a(f,i)<<" AGE "
         <<mkt_a(f,i)<<" "<<ageerr_type_a(f,i)<<" "<<s_off<<" "<<1<<" "<<nlength<<endl;}

        if(gen_a(f,i)>=2 && gender==2)  // do males
         {s_off=2;
         for (z=tails_a(f,i,3);z<=tails_a(f,i,4);z++)
          {SS_compout<<header_a(f,i,1)<<" "<<header_a(f,i,2)<<" "<<Show_Time2(ALK_time)(2,3)<<" "<<data_time(ALK_time,f,3)<<" "<<f<<" "<<fleet_area(f)<<" "<<repli<<" "<<gen_a(f,i)<<" AGE "<<mkt_a(f,i)<<" "<<ageerr_type_a(f,i)<<" "<<s_off
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
        SS_compout<<header_a(f,i,1)<<" "<<real_month<<" "<<Show_Time2(ALK_time)(2,3)<<" "<<data_time(ALK_time,f,3)<<" "<<f<<" "<<fleet_area(f)<<" "<<repli<<" "<<gen_a(f,i)<<" AGE "
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
      real_month=abs(header_ms_rd(f,i,2));
      if(real_month>999) real_month-=1000.;
      if(ALK_time==last_t)
      {repli++;}
      else
      {repli=1;last_t=ALK_time;}
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
        SS_compout<<header_ms(f,i,1)<<" "<<real_month<<" "<<Show_Time2(ALK_time)(2,3)<<" "<<data_time(ALK_time,f,3)<<" "<<f<<" "<<fleet_area(f)<<" "<<repli<<" "<<gen_ms(f,i)<<anystring2<<mkt_ms(f,i)<<" "<<
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
        if(z==n_abins || z==n_abins2) SS_compout<<header_ms(f,i,1)<<" "<<real_month<<" "<<Show_Time2(ALK_time)(2,3)<<" "<<data_time(ALK_time,f,3)<<" "<<f<<" "<<fleet_area(f)<<" "<<repli<<" "<<gen_ms(f,i)<<
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
          real_month=abs(SzFreq_obs1(iobs,3));  //  month
          if(real_month>999) real_month-=1000.;
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
      if(ALK_time==last_t)
      {repli++;}
      else
      {repli=1;last_t=ALK_time;}
         for (z=z1;z<=z2;z++)
          {
            s_off=1;
            SS_compout<<SzFreq_obs_hdr(iobs,1)<<" "<<real_month<<" "<<Show_Time2(ALK_time)(2,3)<<" "<<data_time(ALK_time,f,3)<<" "<<f<<" "<<fleet_area(f)<<" "<<repli<<" "<<gg<<" SIZE "<<p<<" "<<k;
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
            SS_compout<<SzFreq_obs_hdr(iobs,1)<<" "<<SzFreq_obs_hdr(iobs,2)<<" "<<Show_Time2(ALK_time)(2,3)<<" "<<data_time(ALK_time,f,3)<<" "<<f<<" "<<fleet_area(f)<<" "<<repli<<" "<<gg<<" SIZE "<<p<<" "<<k<<" "<<s_off<<" "<<1<<" "<<2<<endl;
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
//  SS_compout<<"Yr Month Seas Subseas Time Fleet Area Repl. Sexes Kind Part Ageerr Sex Lbin_lo Lbin_hi Bin Obs Exp Pearson N effN Like Cum_obs Cum_exp SuprPer Used?"<<endl;
          SS_compout<<y<<" NA "<<s<<" NA "<<temp<<" NA "<<TG_release(TG,2)<<" "<<TG<<" "<<TG_release(TG,6)<<" TAG2 NA NA NA NA NA "<<
          temp<<" "<<TG_recap_obs(TG,TG_t,0)<<" "<<TG_recap_exp(TG,TG_t,0)<<" NA NA NA NA NA NA NA ";
          if(TG_t>=TG_mixperiod) {SS_compout<<"_"<<endl;} else {SS_compout<<" skip"<<endl;}
          if(Nfleet>1)
          for (f=1;f<=Nfleet;f++)
          {
            SS_compout<<y<<" NA "<<s<<" NA "<<temp<<" "<<f<<" "<<fleet_area(f)<<" "<<TG<<" "<<TG_release(TG,6)<<" TAG1 NA NA NA NA NA "<<
            f<<" "<<TG_recap_obs(TG,TG_t,f)<<" "<<TG_recap_exp(TG,TG_t,f)<<" NA "<<TG_recap_obs(TG,TG_t,0)
            <<" NA NA NA NA NA ";
          if(TG_t>=TG_mixperiod) {SS_compout<<"_"<<endl;} else {SS_compout<<" skip"<<endl;}
          }
          s++; if(s>nseas) {s=1; y++;}
        }
      }
    }

  if(N_out==0) SS_compout<<styr<<" -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1"<<endl;
  SS_compout<<styr<<" -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1"<<endl<<" End_comp_data"<<endl;

// REPORT_KEYWORD  SELEX_database
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

// REPORT_KEYWORD SPR/YPR_Profile
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
  dvariable YPR_last;

  if(Do_Benchmark>0 && wrote_bigreport==1)
  {
    SS2out<<endl<<"SPR/YPR_Profile "<<endl<<"SPRloop Iter Bycatch Fmult F_report SPR YPR YPR*Recr SSB Recruits SSB/Bzero Tot_Catch ";
    for (f=1;f<=Nfleet;f++) {if(fleet_type(f)<=2) SS2out<<" "<<fleetname(f)<<"("<<f<<")Dead";}
    for (f=1;f<=Nfleet;f++) {if(fleet_type(f)<=2) SS2out<<" "<<fleetname(f)<<"("<<f<<")Ret";}
    for (f=1;f<=Nfleet;f++) {if(fleet_type(f)<=2) SS2out<<" "<<fleetname(f)<<"("<<f<<")Age";}
    for (p=1;p<=pop;p++)
    for (gp=1;gp<=N_GP;gp++)
    {SS2out<<" SSB_Area:"<<p<<"_GP:"<<gp;}
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
    if(N_bycatch==0) {k=0;} else {k=1;}
    for (int with_BYC=0; with_BYC<=k;with_BYC++)
    for (int SPRloop1=0; SPRloop1<=7; SPRloop1++)
    {
      Fmultchanger1=value(pow(0.0001/Fcrash,0.025));
      Fmultchanger2=value(Fcrash/39.);
      SPRloops=40;
      switch(SPRloop1)
      {
        case 0:
        {
          Fmult2=maxpossF;
          break;
        }
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
        case 7:
        {
          Fmult2=MSY_Fmult;
          SPRloops=40;
          SPR_trial=value(SSB_equil/SSB_virgin);
          SPR_last=SPR_trial*2.;
          YPR_last=-1.;
          break;
        }
      }
      for (SPRloop=1; SPRloop<=SPRloops; SPRloop++)
      {
        if(SPRloop1==7 && SPRloop>1)
        {
          if(F_Method>1)
          {Fmult2*=1.05;}
          else
          {Fmult2=Fmult2+(1.0-Fmult2)*0.05;}
          if (SPR_trial<=0.001) SPRloop=1001;
          SPR_last=SPR_trial;
          YPR_last=YPR_dead;
        }

        for (f=1;f<=Nfleet;f++)
        for (s=1;s<=nseas;s++)
        {
          t=bio_t_base+s;
          if(fleet_type(f)==1 || (fleet_type(f)==2 && bycatch_setup(f,3)==1))
          {
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
          else if (fleet_type(f)==2 && bycatch_setup(f,3)>1)
          {Hrate(f,t)=double(with_BYC)*bycatch_F(f,s);}
          else
          {Hrate(f,t)=0.0;}
        }
        Fishon=1;

        Do_Equil_Calc(equ_Recr);
//  SPAWN-RECR:   calc equil spawn-recr in the SPR loop
        SPR_temp=SSB_equil;
//        Equ_SpawnRecr_Result = Equil_Spawn_Recr_Fxn(SR_parm(2), SR_parm(3), SSB_virgin, Recr_virgin, SPR_temp);  //  returns 2 element vector containing equilibrium biomass and recruitment at this SPR
        Equ_SpawnRecr_Result = Equil_Spawn_Recr_Fxn(SR_parm_work(2), SR_parm_work(3), SSB_unf, Recr_unf, SPR_temp);  //  returns 2 element vector containing equilibrium biomass and recruitment at this SPR
        Btgt_prof=Equ_SpawnRecr_Result(1);
        Btgt_prof_rec=Equ_SpawnRecr_Result(2);
        
        if(Btgt_prof<0.001 || Btgt_prof_rec<0.001)
        {
          Btgt_prof_rec=0.0; Btgt_prof=0.;
          if(SPRloop1==0) Fcrash=Fmult2;
        }
        SS2out<<SPRloop1<<" "<<SPRloop<<" "<<with_BYC<<" "<<Fmult2<<" "<<equ_F_std<<" "<<SSB_equil/(SSB_unf/Recr_unf)<<" "<<YPR_dead<<" "
        <<YPR_dead*Btgt_prof_rec<<" "<<Btgt_prof<<" "<<Btgt_prof_rec<<" "<<Btgt_prof/SSB_unf
        <<" "<<value(sum(equ_catch_fleet(2))*Btgt_prof_rec);
        for(f=1;f<=Nfleet;f++)
          if(fleet_type(f)<=2)
        {
          temp=0.0;
          for(s=1;s<=nseas;s++) {temp+=equ_catch_fleet(2,s,f);}
          SS2out<<" "<<temp*Btgt_prof_rec;
        }
        for(f=1;f<=Nfleet;f++)
          if(fleet_type(f)<=2)
        {
          temp=0.0;
          for(s=1;s<=nseas;s++) {temp+=equ_catch_fleet(3,s,f);}
          SS2out<<" "<<temp*Btgt_prof_rec;
        }
//  report mean age of CATCH of non-bycatch fleets
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
          if(temp2>0.0) {SS2out<<" "<<temp/temp2;} else SS2out<<" NA";
        }
        
        for (p=1;p<=pop;p++)
        for (gp=1;gp<=N_GP;gp++)
        {SS2out<<" "<<SSB_equil_pop_gp(p,gp)*Btgt_prof_rec;}
        SS2out<<endl;
        if(SPRloop1==0)
          {Fmult2-=Fmultchanger0;
           if(Fmult2<0.0) Fmult2=1.0e-6;}
        else if(SPRloop1==1)
          {Fmult2*=Fmultchanger1;}
        else if(SPRloop1==2)
          {Fmult2+=Fmultchanger2;}
      }
    }

    SS2out<<"Finish SPR/YPR profile"<<endl;
    SS2out<<"#Profile 0 is descending additively from max possible F:  "<<maxpossF<<endl;
    SS2out<<"#Profile 1 is descending multiplicatively half of max possible F"<<endl;
    SS2out<<"#Profile 2 is additive back to Fcrash: "<<Fcrash<<endl;
    SS2out<<"#value 3 uses endyr F, which has different fleet allocation than benchmark"<<endl;
    SS2out<<"#value 4 is Fspr: "<<SPR_Fmult<<endl;
    SS2out<<"#value 5 is Fbtgt: "<<Btgt_Fmult<<endl;
    SS2out<<"#value 6 is Fmsy: "<<MSY_Fmult<<endl;
    SS2out<<"#Profile 7 increases from Fmsy to Fcrash"<<endl;
    SS2out<<"#NOTE: meanage of catch is for total catch of fleet_type==1 or bycatch fleets with scaled Hrate"<<endl;
        
  }

//  GLOBAL_MSY with knife-edge age selection, then slot-age selection
// REPORT_KEYWORD GLOBAL_MSY
  if(Do_Benchmark>0 && wrote_bigreport==1 && reportdetail ==1)
  {
    SS2out<<"GLOBAL_MSY"<<endl;
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
  
FUNCTION dvector process_comps(const int sexes, const int sex, dvector &bins,  dvector &means, const dvector &tails, 
          dvector& obs,  dvector& exp)
  {
    dvector more_comp_info(1,20);
    double cumdist;
    double cumdist_save;
    double temp, temp1, temp2;
    int z;
    more_comp_info.initialize();
    //  sexes is 1 or 2 for numbers of sexes in model
    //  sex is 0, 1, 2, 3 for range of sexes used in this sample
    int nbins = bins.indexmax()/sexes; // find number of bins
     // do both sexes  tails(4) has been set to tails(2) if males not in this sample
     if(sex==3 || sex==0)
     {
       more_comp_info(1)=obs(tails(1),tails(4))*means(tails(1),tails(4));
       more_comp_info(2)=exp(tails(1),tails(4))*means(tails(1),tails(4));
       more_comp_info(3)=more_comp_info(1)-more_comp_info(2);
//  calc tails of distribution and Durbin-Watson for autocorrelation
       temp1=0.0; temp2=0.0;
       cumdist_save=0.0;
       cumdist=0.0;
       for(z=1;z<=nbins;z++)
       {
        cumdist+=exp(z);
        if(sexes==2)  cumdist+=exp(z+nbins);  // add males and females
        if(cumdist>=0.05 && cumdist_save<0.05)  //  found bin for 5%
        {
          if(z==1)
          {more_comp_info(4)=bins(z);}  //  set to lower edge
          else
          {more_comp_info(4)=bins(z)+(bins(min(z+1,nbins))-bins(z))*(0.05-cumdist_save)/(cumdist-cumdist_save);}
        }
        if(cumdist>=0.95 && cumdist_save<0.95)  //  found bin for 95%
        {
          more_comp_info(5)=bins(z)+(bins(min(z+1,nbins))-bins(z))*(0.95-cumdist_save)/(cumdist-cumdist_save);
        }
        cumdist_save=cumdist;

        temp=obs(z)-exp(z);  //  obs-exp
        if(z>tails(1))
        {
          more_comp_info(6)+=square(temp2-temp);
          temp1+=square(temp);
        }
        temp2=temp;
       }

       if(sex==3 && sexes==2)  // do sex ratio
       {
         more_comp_info(19)=sum(obs(tails(1),tails(2)));  //  sum obs female fractions =  %female
         more_comp_info(20)=sum(exp(tails(1),tails(2))); //  sum exp female fractions =  %female
         for(z=tails(3);z<=tails(4);z++)
         {
          temp=obs(z)-exp(z);  //  obs-exp
          if(z>tails(3))
          {
            more_comp_info(6)+=square(temp2-temp);
            temp1+=square(temp);
          }
          temp2=temp;
         }
       }
       more_comp_info(6)=(more_comp_info(6)/temp1) - 2.0;
     }

    
     if(sex==1 || sex==3)  //  need females
     {
       //  where means() holds midpoints of the data length bins
       more_comp_info(7)=(obs(tails(1),tails(2))*means(tails(1),tails(2)))/sum(obs(tails(1),tails(2)));
       more_comp_info(8)=(exp(tails(1),tails(2))*means(tails(1),tails(2)))/sum(exp(tails(1),tails(2)));
       more_comp_info(9)=more_comp_info(7)-more_comp_info(8);
       //  calc tails of distribution and Durbin-Watson for autocorrelation
       temp1=0.0;
       cumdist_save=0.0;
       cumdist=0.0;
       for(z=tails(1);z<=tails(2);z++)
       {
        cumdist+=exp(z);
        if(cumdist>=0.05*more_comp_info(20) && cumdist_save<0.05*more_comp_info(20))  //  found bin for 5%
        {
          if(z==1)
          {more_comp_info(10)=bins(z);}  //  set to lower edge
          else
          {more_comp_info(10)=bins(z)+(bins(min(z+1,nlen_bin))-bins(z))*(0.05*more_comp_info(20)-cumdist_save)/(cumdist-cumdist_save);}
        }
        if(cumdist>=0.95*more_comp_info(20) && cumdist_save<0.95*more_comp_info(20))  //  found bin for 95%
        {
          more_comp_info(11)=bins(z)+(bins(min(z+1,nlen_bin))-bins(z))*(0.95*more_comp_info(20)-cumdist_save)/(cumdist-cumdist_save);
        }
        cumdist_save=cumdist;

        temp=obs(z)-exp(z);  //  obs-exp
        if(z>tails(1))
        {
          more_comp_info(12)+=square(temp2-temp);
          temp1+=square(temp);
        }
        temp2=temp; //  save current delta
       }
       more_comp_info(12)=(more_comp_info(12)/temp1) - 2.0;
     }
     if(sex>=2 && sexes==2)  // need males
     {
       more_comp_info(13)=(obs(tails(3),tails(4))*means(tails(3),tails(4)))/sum(obs(tails(3),tails(4)));
       more_comp_info(14)=(exp(tails(3),tails(4))*means(tails(3),tails(4)))/sum(exp(tails(3),tails(4)));
       more_comp_info(15)=more_comp_info(13)-more_comp_info(14);
       //  calc tails of distribution and Durbin-Watson for autocorrelation
       temp1=0.0;
       cumdist_save=0.0;
       cumdist=0.0;
       //  where (1-more_comp_info(20)) is the total of male fractions
       for(z=tails(3);z<=tails(4);z++)
       {
        cumdist+=exp(z);
        if(cumdist>=0.05*(1.0-more_comp_info(20)) && cumdist_save<0.05*(1.0-more_comp_info(20)))  //  found bin for 5%
        {
          if(z==nbins+1)
          {more_comp_info(16)=bins(z);}  //  set to lower edge
          else
          {more_comp_info(16)=bins(z)+(bins(min(z+1,2*nbins))-bins(z))*(0.05*more_comp_info(20)-cumdist_save)/(cumdist-cumdist_save);}
        }
        if(cumdist>=0.95*(1.0-more_comp_info(20)) && cumdist_save<0.95*(1.0-more_comp_info(20)))  //  found bin for 95%
        {
          more_comp_info(17)=bins(z)+(bins(min(z+1,2*nbins))-bins(z))*(0.95*(1.0-more_comp_info(20))-cumdist_save)/(cumdist-cumdist_save);
        }
        cumdist_save=cumdist;

        temp=obs(z)-exp(z);  //  obs-exp
        if(z>tails(3))
        {
          more_comp_info(18)+=square(temp2-temp);
          temp1+=square(temp);
        }
        temp2=temp; //  save current delta
       }
       more_comp_info(18)=(more_comp_info(18)/temp1) - 2.0;
     }
     
    return more_comp_info;
  }
