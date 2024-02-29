// SS_Label_file  #19. **SS_write_report.tpl**
// SS_Label_file  # * <u>write_bigoutput()</u>  // produces *report.sso* and *compreport.sso*
// SS_Label_file  # * <u>SPR_profile()</u>  //  calls Do_Equil_Calc() and Equil_Spawn_Recr_Fxn() over a range of F to get SPR, YPR, and SSB and catch curves
// SS_Label_file  # * <u>global_MSY()</u>  // similar to SPR_profile but first changes all selectivities to knife edge and profiles on age-at-entry
// SS_Label_file  #

//********************************************************************
 /*  SS_Label_FUNCTION 40 write_bigoutput */
FUNCTION void write_bigoutput()
  {
  if (mceval_counter == 0)
  {
    anystring = sso_pathname + "Report.sso";
    report_sso_filename = anystring;
    if (SS2out.is_open())
      SS2out.close();
    SS2out.open(anystring); // this file was created in globals so accessible to the report_parm function
    anystring = sso_pathname + "CompReport.sso";
    if (SS_compout.is_open())
      SS_compout.close();
    SS_compout.open(anystring);
  }
  else
  {
    anystring = "      ";
    sprintf(anystring, "%d", mceval_counter);
    if (SS2out.is_open())
      SS2out.close();
    if (SS_compout.is_open())
      SS_compout.close();
    anystring2 = sso_pathname + "Report_mce_";
    if (mceval_counter < 10)
    {
      anystring2 += "000";
    }
    else if (mceval_counter < 100)
    {
      anystring2 += "00";
    }
    else if (mceval_counter < 1000)
    {
      anystring2 += "0";
    }
    anystring2 += anystring + ".sso";
    SS2out.open(anystring2);
    report_sso_filename = anystring2; //  save so can be reopened in append mode
    anystring2 = sso_pathname + "CompReport_mce_";
    if (mceval_counter < 10)
    {
      anystring2 += "000";
    }
    else if (mceval_counter < 100)
    {
      anystring2 += "00";
    }
    else if (mceval_counter < 1000)
    {
      anystring2 += "0";
    }
    anystring2 += anystring + ".sso";
    SS_compout.open(anystring2);
  }

  SS2out << version_info(1) << version_info(2) << version_info(3) << endl
         << version_info2 << endl;
  time(&finish);
  SS_compout << version_info(1) << version_info(2) << version_info(3) << endl
             << "StartTime: " << ctime(&start);

  SS2out << "StartTime: " << ctime(&start);
  SS2out << "EndTime: " << ctime(&finish);
  elapsed_time = difftime(finish, start);
  hour = long(elapsed_time) / 3600;
  minute = long(elapsed_time) % 3600 / 60;
  second = (long(elapsed_time) % 3600) % 60;
  SS2out << "This run took: " << hour << " hours, " << minute << " minutes, " << second << " seconds." << endl;
  SS2out << "Data_File: " << datfilename << endl;
  SS2out << "Control_File: " << ctlfilename << endl;
  if (readparfile >= 1)
    SS2out << "Start_parm_values_from_SS.PAR" << endl;
  SS2out << endl
         << "Convergence_Level: " << objective_function_value::pobjfun->gmax << " is_final_gradient" << endl;
  temp = get_ln_det_value();
  if (SDmode == 0)
  {
    SS2out << "Hessian: Not requested." << endl;
  }
  else //  (SDmode == 1)
  {
    if (temp > 0)
    {
      SS2out << "Hessian: " << temp << " is ln(determinant)." << endl;
    }
    if (temp <= 0)
    {
      SS2out << "Hessian: " << temp << " is ln(determinant). Hessian is not positive definite, so don't trust variance estimates." << endl;
    }
  }
  SS2out << "Final_phase: " << current_phase() << endl;
  SS2out << "N_iterations: " << niter << endl;
  SS2out << "total_LogL: " << obj_fun << endl;

  if (N_SC > 0)
  {
    SS2out << endl
           << "Starter_Comments" << endl
           << Starter_Comments << endl;
  }
  if (N_DC > 0)
  {
    SS2out << endl
           << "Data_Comments" << endl
           << Data_Comments << endl;
  }
  if (N_CC > 0)
  {
    SS2out << endl
           << "Control_Comments" << endl
           << Control_Comments << endl;
  }
  if (N_FC > 0)
  {
    SS2out << endl
           << "Forecast_Comments" << endl
           << Forecast_Comments << endl;
  }

  if (N_parm_dev == 0)
    pick_report_use(4) = "N";
  if (SzFreq_Nmeth == 0)
    pick_report_use(12) = "N";
  if (do_migration == 0)
    pick_report_use(13) = "N";
  if (Svy_N == 0)
    pick_report_use(21) = "N";
  if (Svy_N == 0)
    pick_report_use(22) = "N";
  if (Svy_N == 0)
    pick_report_use(23) = "N";
  if (nobs_disc == 0)
    pick_report_use(24) = "N";
  if (nobs_disc == 0)
    pick_report_use(25) = "N";
  if (nobs_mnwt == 0)
    pick_report_use(26) = "N";
  if (Nobs_l_tot == 0)
    pick_report_use(27) = "N";
  if (Nobs_a_tot == 0)
    pick_report_use(28) = "N";
  if (SzFreq_Nmeth == 0)
    pick_report_use(29) = "N";
  if (N_envvar == 0)
    pick_report_use(33) = "N";
  if (Do_TG == 0)
    pick_report_use(34) = "N";
  if (Grow_type < 3 || Grow_type > 6)
    pick_report_use(44) = "N";
  if (MGparm_doseas == 0)
    pick_report_use(46) = "N";
  if (N_ageerr == 0)
    pick_report_use(51) = "N";
  if (use_length_data == 0)
    pick_report_use(46) = "N";

  SS2out << endl
         << "#_KeyWords_of_tables_available_in_report_sso" << endl;
  SS2out << "#NOTE: table_number_is_order_in_which_tables_are_output" << endl;
  SS2out << "#_List_Tables_related_to_basic_input_pre-processing_and_output" << endl;
  k = 1;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // DEFINITIONS"
  k = 6;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // DERIVED_QUANTITIES"
  k = 33;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // ENVIRONMENTAL_DATA"
  k = 3;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // Input_Variance_Adjustment"
  k = 2;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // LIKELIHOOD
  k = 7;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // MGparm_By_Year_after_adjustments
  k = 11;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // MORPH_INDEXING (defines_associations_for_sex_growth_pattern_platoons_settlements)
  k = 30;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // OVERALL_COMPS (average_length_and_age_composition_observed_by_each_fleet)
  k = 5;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // PARAMETERS
  k = 4;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // parmdevs_detail

  SS2out << endl
         << "# List_Tables_related_to_timeseries_output" << endl;
  k = 36;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // BIOMASS_AT_AGE
  k = 38;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // BIOMASS_AT_LENGTH
  k = 15;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // CATCH
  k = 41;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // DISCARD_AT_AGE
  k = 14;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // EXPLOITATION (showing_F_rates_by_fleet)
  k = 40;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // CATCH_AT_AGE
  k = 39;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // F_AT_AGE
  k = 49;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // MEAN_SIZE_TIMESERIES (body length)
  k = 35;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // NUMBERS_AT_AGE
  k = 37;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // NUMBERS_AT_LENGTH
  k = 19;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // SPAWN_RECRUIT
  k = 20;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // SPAWN_RECRUIT_CURVE
  k = 17;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // SPR_series (equilibrium_SPR_and_YPR_calculations_for_each_year)
  k = 16;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // TIME_SERIES

  SS2out << endl
         << "# List_Tables_related_to_fit_to_data" << endl;
  k = 52;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // composition database
  k = 24;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // DISCARD specification
  k = 25;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // DISCARD
  k = 21;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // INDEX, CPUE, effort
  k = 22;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // INDEX, obs
  k = 23;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // INDEX, Q
  k = 27;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // FIT_LEN_COMPS
  k = 28;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // FIT_AGE_COMPS
  k = 29;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // FIT_SIZE_COMPS
  k = 26;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // MEAN_BODY_WT
  k = 34;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // TAG_Recapture

  SS2out << endl
         << "# List_Tables_related_to_selectivity_and_discard" << endl;
  k = 32;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // AGE_SELEX
  k = 31;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // LEN_SELEX
  k = 8;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // selparm(Size)_By_Year_after_adjustments
  k = 9;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // selparm(Age)_By_Year_after_adjustments
  k = 53;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // selex database

  SS2out << endl
         << "#_List_Tables_related_to_biology" << endl;
  k = 51;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // AGE_AGE'_KEY"
  k = 50;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // AGE_LENGTH_KEY
  k = 44;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // Age-Specific k
  k = 42;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // BIOLOGY
  k = 47;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // Biology-at-age
  k = 45;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // Growth_parameters
  k = 48;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // mean body wt time series
  k = 13;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // MOVEMENT (fraction_moving_between_areas)
  k = 43;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // Natural_Mortality
  k = 10;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // RECRUITMENT_DIST (distribution_of_recruits_among_morphs_areas_settlement_time)
  k = 46;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // Seasonal effects
  k = 12;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // SIZEFREQ_TRANSLATION (If_using_generalized_size_comp)

  SS2out << endl
         << "# List_Tables_related_to_equilibrium_reference_points;_also_see_forecast_report.sso" << endl;
  k = 59;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // Dynamic_Bzero
  k = 55;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // GLOBAL_MSY (including_knife-edge_selex_and_slot-age_selex)
  k = 18;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // Kobe_Plot
  k = 54;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // SPR/YPR_PROFILE

  SS2out << endl
         << "# List_Additional_Tables" << endl;
  k = 56;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // ss_summary
  k = 57;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // rebuilder
  k = 58;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // SIS_table
  k = 60;
  SS2out << pick_report_use(k) << " " << pick_report_name(k) << endl; // wt-at-age.ss

  SS2out << endl
         << "# vector_with_report_usage" << endl;
  for (k = 1; k <= 60; k++)
  {
    SS2out << " " << pick_report_use(k);
  }
  SS2out << endl
         << endl;

  // REPORT_KEYWORD 1 DEFINITIONS
  if (pick_report_use(1) == "Y")
  {
    SS2out << endl
           << pick_report_name(1) << endl;
    SS2out << "N_seasons: " << nseas << endl;
    SS2out << "N_sub_seasons: " << N_subseas << endl;
    SS2out << "Sum_of_months_on_read_was:_ " << sumseas << " rescaled_to_sum_to: " << sum(seasdur) << endl;
    SS2out << "Season_Durations: " << seasdur << endl;
    SS2out << "Spawn_month: " << spawn_month << endl
           << "Spawn_seas: " << spawn_seas << endl
           << "Spawn_timing_in_season: " << spawn_time_seas << endl;
    SS2out << "N_areas: " << pop << endl;
    SS2out << "Start_year: " << styr << endl;
    SS2out << "End_year: " << endyr << endl;
    SS2out << "Retro_year: " << retro_yr << endl;
    SS2out << "N_forecast_yrs: " << N_Fcast_Yrs << endl;
    SS2out << "N_areas: " << pop << endl;
    SS2out << "N_sexes: " << gender << endl;
    SS2out << "Max_age: " << nages << endl;
    SS2out << "Empirical_wt_at_age(0,1): " << WTage_rd << endl;
    SS2out << "N_bio_patterns: " << N_GP << endl;
    SS2out << "N_platoons: " << N_platoon << endl;
    SS2out << "NatMort: " << natM_type << " # options:_(0)1Parm;_(1)N_breakpoints;_(2)Lorenzen;_(3)agespecific;_(4)agespec_withseasinterpolate" << endl;
    SS2out << "GrowthModel: " << Grow_type << " # options:_(1)vonBert with L1&L2;_(2)Richards with L1&L2;_(3)age_specific_K_incr;_(4)age_specific_K_decr; (5)age_specific_K_each; (6)not implemented" << endl;
    SS2out << "Maturity: " << Maturity_Option << " # options:_(1)length logistic;_(2)age logistic;_(3)read age-maturity;_(4)read age-fecundity;_(5)disabled;_(6)read length-maturity" << endl;
    SS2out << "Fecundity: " << Fecund_Option << " # options:_(1)eggs=Wt*(a+b*Wt);_(2)eggs=a*L^b;_(3)eggs=a*Wt^b;_(4)eggs=a+b*L;_(5)eggs=a+b*W" << endl;
    SS2out << "Start_from_par(0,1): " << readparfile << endl;
    SS2out << "Do_all_priors(0,1): " << Do_all_priors << endl;
    SS2out << "Use_softbound(0,1): " << SoftBound << endl;
    SS2out << "N_nudata: " << N_nudata << endl;
    SS2out << "Max_phase: " << max_phase << endl;
    SS2out << "Current_phase: " << current_phase() << endl;
    SS2out << "Jitter: " << jitter << endl;
    SS2out << "ALK_tolerance: " << ALK_tolerance << endl;

    if (use_length_data > 0)
    {
      SS2out << "#" << endl << "Length_comp_error_controls" << endl << "Fleet partition mintailcomp addtocomp combM+F CompressBins CompError ParmSelect minsamplesize " << endl;
      for (f = 1; f <= Nfleet; f++)
      if (Nobs_l(f) > 0)
      {
        int parti_lo = 0;
        int parti_hi = 0;
        if (Do_Retain(f) == 1) parti_hi = 2;
        for (int parti = parti_lo; parti <= parti_hi ; parti++)
        {
          SS2out << f << " " << parti << " " << min_tail_L(parti, f) << " " << min_comp_L(parti, f) << " " << CombGender_L(parti, f) << " " << AccumBin_L(parti, f) << " " << Comp_Err_L(parti, f) << " " << Comp_Err_L2(parti, f) << " " << min_sample_size_L(parti, f) << " #_ " << fleetname(f) << endl;
        }
      }
    }

    if (n_abins > 0)
    {
      SS2out << "#" << endl << "Age_comp_error_controls" << endl << "Fleet  mintailcomp addtocomp combM+F CompressBins CompError ParmSelect minsamplesize " << endl;
      for (f = 1; f <= Nfleet; f++)
      if (Nobs_a(f) > 0)
      {
          SS2out << f << " " << min_tail_A(f) << " " << min_comp_A(f) << " " << CombGender_A(f) << " " << AccumBin_A(f) << " " << Comp_Err_A(f) << " " << Comp_Err_A2(f) << " " << min_sample_size_A(f) << " #_ " << fleetname(f) << endl;
      }
    }

    if(SzFreq_Nmeth > 0)
    {
    SS2out << "#" << endl << "Size_comp_error_controls" << endl << "#_Sz_method error_type error_parm_ID " << endl;
    for (f = 1; f <= SzFreq_Nmeth; f++)
    {
        SS2out << f << " " << Comp_Err_Sz(f) << " " << Comp_Err_Sz2(f) << endl;
    }
    }

    SS2out << "#" << endl;
    SS2out << "Fleet fleet_type timing area catch_units catch_mult survey_units survey_error Fleet_name" << endl;
    for (f = 1; f <= Nfleet; f++)
    {
      SS2out << f << " " << fleet_setup(f) << " " << Svy_units(f) << " " << Svy_errtype(f) << " " << fleetname(f) << endl;
    }
  } //  end DEFINITIONS

  // REPORT_KEYWORD 2 LIKELIHOOD
  if (pick_report_use(2) == "Y")
  {
    k = current_phase();
    if (k > max_lambda_phase)
      k = max_lambda_phase;
    SS2out << endl
           << pick_report_name(2) << " " << obj_fun << endl; //SS_Label_310
    SS2out << "Component logL*Lambda Lambda" << endl;
    SS2out << "TOTAL " << obj_fun << " NA" << endl;
    if (F_Method > 1)
      SS2out << "Catch " << catch_like * column(catch_lambda, k) << " NA" << endl;
    SS2out << "Equil_catch " << equ_catch_like * column(init_equ_lambda, k) << " NA" << endl;
    if (Svy_N > 0)
      SS2out << "Survey " << surv_like * column(surv_lambda, k) << " NA" << endl;
    if (nobs_disc > 0)
      SS2out << "Discard " << disc_like * column(disc_lambda, k) << " NA" << endl;
    if (nobs_mnwt > 0)
      SS2out << "Mean_body_wt " << mnwt_like * column(mnwt_lambda, k) << " NA" << endl;
    if (Nobs_l_tot > 0)
      SS2out << "Length_comp " << length_like_tot * column(length_lambda, k) << " NA" << endl;
    if (Nobs_a_tot > 0)
      SS2out << "Age_comp " << age_like_tot * column(age_lambda, k) << " NA" << endl;
    if (nobs_ms_tot > 0)
      SS2out << "Size_at_age " << sizeage_like * column(sizeage_lambda, k) << " NA" << endl;
    if (SzFreq_Nmeth > 0)
      SS2out << "SizeFreq " << SzFreq_like * column(SzFreq_lambda, k) << " NA" << endl;
    if (Do_Morphcomp > 0)
      SS2out << "Morphcomp " << Morphcomp_lambda(k) * Morphcomp_like << " " << Morphcomp_lambda(k) << endl;
    if (Do_TG > 0)
      SS2out << "Tag_comp " << TG_like1 * column(TG_lambda1, k) << " NA" << endl;
    if (Do_TG > 0)
      SS2out << "Tag_negbin " << TG_like2 * column(TG_lambda2, k) << " NA" << endl;
    SS2out << "Recruitment " << recr_like * recrdev_lambda(k) << " " << recrdev_lambda(k) << endl;
    SS2out << "InitEQ_Regime " << regime_like * regime_lambda(k) << " " << regime_lambda(k) << endl;
    SS2out << "Forecast_Recruitment " << Fcast_recr_like << " " << Fcast_recr_lambda << endl;
    SS2out << "Parm_priors " << parm_like * parm_prior_lambda(k) << " " << parm_prior_lambda(k) << endl;
    if (SoftBound > 0)
      SS2out << "Parm_softbounds " << SoftBoundPen << " "
             << " NA" << endl;
    SS2out << "Parm_devs " << (sum(parm_dev_like)) * parm_dev_lambda(k) << " " << parm_dev_lambda(k) << endl;
    if (F_ballpark_yr > 0)
      SS2out << "F_Ballpark " << F_ballpark_lambda(k) * F_ballpark_like << " " << F_ballpark_lambda(k) << endl;
    if (F_ballpark_yr > 0)
      SS2out << "F_Ballpark(info_only)_" << F_ballpark_yr << "_estF_tgtF " << annual_F(F_ballpark_yr, 2) << " " << F_ballpark << endl;
    //  if(F_ballpark_yr>0) SS2out <<"F_Ballpark "<<F_ballpark_lambda(k)*F_ballpark_like<<" "<<F_ballpark_lambda(k)<<"  ##:est&obs: "<<annual_F(F_ballpark_yr,2)<<" "<<F_ballpark<<endl;
    SS2out << "Crash_Pen " << CrashPen_lambda(k) * CrashPen << " " << CrashPen_lambda(k) << endl;
    SS2out << "#_info_for_Laplace_calculations" << endl;
    SS2out << "NoBias_corr_Recruitment(info_only) " << noBias_recr_like * recrdev_lambda(k) << " " << recrdev_lambda(k) << endl;
    SS2out << "Laplace_obj_fun(info_only) " << JT_obj_fun << " NA" << endl;
    SS2out << "#" << endl
           << "Fleet:  ALL ";
    for (f = 1; f <= Nfleet; f++)
      SS2out << f << " ";
    SS2out << endl;
    if (F_Method > 1)
      SS2out << "Catch_lambda: _ " << column(catch_lambda, k) << endl
             << "Catch_like: " << catch_like * column(catch_lambda, k) << " " << catch_like << endl;
    SS2out << "Init_equ_lambda: _ " << column(init_equ_lambda, k) << endl
           << "Init_equ_like: " << equ_catch_like * column(init_equ_lambda, k) << " " << equ_catch_like << endl;
    if (Svy_N > 0)
    {
      SS2out << "Surv_lambda: _ " << column(surv_lambda, k) << endl
             << "Surv_like: " << surv_like * column(surv_lambda, k) << " " << surv_like << endl;
      SS2out << "Surv_N_use: _ " << Svy_N_fleet_use << endl;
      SS2out << "Surv_N_skip: _ " << (Svy_N_fleet - Svy_N_fleet_use) << endl;
    }
    if (nobs_disc > 0)
    {
      SS2out << "Disc_lambda: _ " << column(disc_lambda, k) << endl
             << "Disc_like: " << disc_like * column(disc_lambda, k) << " " << disc_like << endl;
      SS2out << "Disc_N_use: _ " << disc_N_fleet_use << endl;
      SS2out << "Disc_N_skip: _ " << (disc_N_fleet - disc_N_fleet_use) << endl;
    }
    if (nobs_mnwt > 0)
    {
      SS2out << "mnwt_lambda: _ " << column(mnwt_lambda, k) << endl;
      SS2out << "mnwt_like: " << mnwt_like * column(mnwt_lambda, k) << " " << mnwt_like << endl;
      SS2out << "mnwt_N_use: _ " << mnwt_N_fleet_use << endl;
      SS2out << "mnwt_N_skip: _ " << (mnwt_N_fleet - mnwt_N_fleet_use) << endl;
    }
    if (Nobs_l_tot > 0)
    {
      SS2out << "Length_lambda: _ " << column(length_lambda, k) << endl;
      SS2out << "Length_like: " << length_like_tot * column(length_lambda, k) << " " << length_like_tot << endl;
      SS2out << "Length_N_use: _ " << Nobs_l_use << endl;
      SS2out << "Length_N_skip: _ " << (Nobs_l - Nobs_l_use) << endl;
    }
    if (Nobs_a_tot > 0)
    {
      SS2out << "Age_lambda: _ " << column(age_lambda, k) << endl;
      SS2out << "Age_like: " << age_like_tot * column(age_lambda, k) << " " << age_like_tot << endl;
      SS2out << "Age_N_use: _ " << Nobs_a_use << endl;
      SS2out << "Age_N_skip: _ " << (Nobs_a - Nobs_a_use) << endl;
    }
    if (nobs_ms_tot > 0)
    {
      SS2out << "Sizeatage_lambda: _ " << column(sizeage_lambda, k) << endl;
      SS2out << "sizeatage_like: " << sizeage_like * column(sizeage_lambda, k) << " " << sizeage_like << endl;
      SS2out << "sizeatage_N_use: _ " << Nobs_ms_use << endl;
      SS2out << "sizeatage_N_skip: _ " << (Nobs_ms - Nobs_ms_use) << endl;
    }

    // Parm_devs_detail
    // (only reported if there are parameter deviations)
    if (pick_report_use(4) == "Y")
    {
      SS2out << endl
             << pick_report_name(4) << endl;
      SS2out << "Index  Phase  MinYr  MaxYr  N   stddev  Rho  Like_devs  Like_se  mean  rmse  var sqrt(var) est_rho  D-W" << endl;
      for (i = 1; i <= N_parm_dev; i++)
      {
        dvector for_AR1(parm_dev_minyr(i), parm_dev_maxyr(i));
        dvector for_var(parm_dev_minyr(i), parm_dev_maxyr(i));
        int y1 = parm_dev_minyr(i);
        int y2 = parm_dev_maxyr(i);
        double count;
        count = float(y2 - y1 + 1.);
        double mean;
        mean = value(sum(parm_dev(i)) / count);
        for (j = y1 + 1; j <= y2; j++)
        {
          for_AR1(j) = value(parm_dev(i, j - 1)) - mean;
        }
        for_var = value(parm_dev(i)) - mean;
        double cross;
        double Durbin;
        double var;
        var = sumsq(for_var);
        cross = 0.;
        Durbin = 0;
        for (j = y1 + 1; j <= y2; j++)
        {
          cross += for_var(j) * for_AR1(j);
          Durbin += square(for_var(j) - for_AR1(j));
        }
        cross /= (count - 1.);
        Durbin /= (var + 1.0e-09);
        var /= count;
        SS2out << i << " " << parm_dev_PH(i) << " " << y1 << " " << y2 << " " << count << " " << parm_dev_stddev(i) << " " << parm_dev_rho(i) << " " << parm_dev_like(i) << " " << sum(parm_dev(i)) / count << " " << sqrt(1.0e-09 + sumsq(parm_dev(i)) / (count)) << " " << var << " " << sqrt(1.0e-09 + var) << " " << cross / (1.0e-09 + var) << " " << Durbin << " " << endl;
      }
    }
    if (SzFreq_Nmeth > 0)
    {
      for (j = 1; j <= SzFreq_Nmeth; j++)
      {
        SS2out << "SizeFreq_lambda:_" << j << "; ";
        if (j == 1)
        {
          SS2out << "_ ";
        }
        else
        {
          SS2out << "_ ";
        }
        for (f = 1; f <= Nfleet; f++)
        {
          if (SzFreq_LikeComponent(f, j) > 0)
          {
            SS2out << SzFreq_lambda(SzFreq_LikeComponent(f, j), k) << " ";
          }
          else
          {
            SS2out << " NA ";
          }
        }
        SS2out << endl;
        SS2out << "SizeFreq_like:_" << j << "; ";
        if (j == 1)
        {
          SS2out << SzFreq_like * column(SzFreq_lambda, k) << " ";
        }
        else
        {
          SS2out << "_ ";
        }
        for (f = 1; f <= Nfleet; f++)
        {
          if (SzFreq_LikeComponent(f, j) > 0)
          {
            SS2out << SzFreq_like(SzFreq_LikeComponent(f, j)) << " ";
          }
          else
          {
            SS2out << " NA ";
          }
        }
        SS2out << endl;
      }
      //    SS2out<<SzFreq_like<<endl<<offset_Sz_tot<<endl;
    }

    if (Do_TG > 0)
    {
      SS2out << "#" << endl
             << "Tag_Group:  ALL ";
      for (f = 1; f <= N_TG; f++)
        SS2out << f << " ";
      SS2out << endl;
      SS2out << "Tag_comp_Lambda _ " << column(TG_lambda1, k) << endl
             << "Tag_comp_Like " << TG_like1 * column(TG_lambda1, k) << " " << TG_like1 << endl;
      SS2out << "Tag_negbin_Lambda _ " << column(TG_lambda2, k) << endl
             << "Tag_negbin_Like " << TG_like2 * column(TG_lambda2, k) << " " << TG_like2 << endl;
    }
    SS2out << endl;

    SS2out << endl
           << pick_report_name(3) << endl;
    SS2out << "Fleet ";
    for (i = 1; i <= Nfleet; i++)
    {
      SS2out << " " << i;
    }
    SS2out << endl;
    SS2out << "Index_extra_CV " << var_adjust(1) << endl;
    SS2out << "Discard_extra_CV " << var_adjust(2) << endl;
    SS2out << "MeanBodyWt_extra_CV " << var_adjust(3) << endl;
    SS2out << "effN_mult_Lencomp " << var_adjust(4) << endl;
    SS2out << "effN_mult_Agecomp " << var_adjust(5) << endl;
    SS2out << "effN_mult_Len_at_age " << var_adjust(6) << endl;
    SS2out << "effN_mult_generalized_sizecomp " << var_adjust(7) << endl;

    SS2out << "MG_parms_Using_offset_approach_#:_" << MGparm_def << "  (1=none, 2= M, G, CV_G as offset from female_GP1, 3=like SS2 V1.x)" << endl;
  }

  // REPORT_KEYWORD 5 PARAMETERS
  if (pick_report_use(5) == "Y")
  {
    SS2out << endl
           << pick_report_name(5) << endl;
    SS2out << "Num Label Value Active_Cnt  Phase Min Max Init  Used  Status  Parm_StDev Gradient Pr_type Prior Pr_SD Pr_Like Value_again Value-1.96*SD Value+1.96*SD V_1%  V_10% V_20% V_30% V_40% V_50% V_60% V_70% V_80% V_90% V_99% P_val P_lowCI P_hiCI  P_1%  P_10% P_20% P_30% P_40% P_50% P_60% P_70% P_80% P_90% P_99%" << endl;

    NP = 0; // count of number of parameters
    active_count = 0;
    Nparm_on_bound = 0;
    int Activ;
    for (j = 1; j <= N_MGparm2; j++)
    {
      NP++;
      Activ = 0;
      if (active(MGparm(j)))
      {
        active_count++;
        Activ = 1;
      }
      Report_Parm(NP, active_count, Activ, MGparm(j), MGparm_LO(j), MGparm_HI(j), MGparm_RD(j), MGparm_use(j), MGparm_PR(j), MGparm_CV(j), MGparm_PRtype(j), MGparm_PH(j), MGparm_Like(j));
    }

    for (j = 1; j <= N_SRparm3; j++)
    {
      NP++;
      Activ = 0;
      if (active(SR_parm(j)))
      {
        active_count++;
        Activ = 1;
      }
      Report_Parm(NP, active_count, Activ, SR_parm(j), SR_parm_LO(j), SR_parm_HI(j), SR_parm_RD(j), SR_parm_use(j), SR_parm_PR(j), SR_parm_CV(j), SR_parm_PRtype(j), SR_parm_PH(j), SR_parm_Like(j));
    }

    if (recdev_cycle > 0)
    {
      for (j = 1; j <= recdev_cycle; j++)
      {
        NP++;
        Activ = 0;
        if (active(recdev_cycle_parm(j)))
        {
          active_count++;
          Activ = 1;
        }
        Report_Parm(NP, active_count, Activ, recdev_cycle_parm(j), recdev_cycle_parm_RD(j, 1), recdev_cycle_parm_RD(j, 2), recdev_cycle_parm_RD(j, 3), recdev_cycle_use(j), recdev_cycle_parm_RD(j, 4), recdev_cycle_parm_RD(j, 5), recdev_cycle_parm_RD(j, 6), recdev_cycle_parm_RD(j, 7), recdev_cycle_Like(j));
      }
    }

    if (recdev_do_early > 0)
    {
      for (i = recdev_early_start; i <= recdev_early_end; i++)
      {
        NP++;
        SS2out << NP << " " << ParmLabel(NP) << " " << recdev(i);
        if (active(recdev_early))
        {
          active_count++;
          SS2out << " " << active_count << " " << recdev_early_PH << " " << recdev_LO << " " << recdev_HI << " " << recdev_RD(i) << " " << recdev_use(i) << " act " << CoVar(active_count, 1) << " " << parm_gradients(active_count);
        }
        else
        {
          SS2out << " _ _ _ _ _ _ NA _ _ ";
        }
        SS2out << " dev " << endl;
      }
    }

    if (do_recdev > 0)
    {
      for (i = recdev_start; i <= recdev_end; i++)
      {
        NP++;
        SS2out << NP << " " << ParmLabel(NP) << " " << recdev(i);
        if (active(recdev1) || active(recdev2))
        {
          active_count++;
          SS2out << " " << active_count << " " << recdev_PH << " " << recdev_LO << " " << recdev_HI << " " << recdev_RD(i) << " " << recdev_use(i) << " act " << CoVar(active_count, 1) << " " << parm_gradients(active_count);
        }
        else
        {
          SS2out << " _ _ _ _ _ _ NA _ _ ";
        }
        SS2out << " dev " << endl;
      }
    }

    if (Do_Forecast > 0 && do_recdev > 0)
    {
      for (i = recdev_end + 1; i <= YrMax; i++)
      {
        NP++;
        SS2out << NP << " " << ParmLabel(NP) << " " << Fcast_recruitments(i);
        if (active(Fcast_recruitments))
        {
          active_count++;
          SS2out << " " << active_count << " " << Fcast_recr_PH2 << " " << recdev_LO << " " << recdev_HI << " " << recdev_RD(i) << " " << recdev_use(i) << " act " << CoVar(active_count, 1) << " " << parm_gradients(active_count);
        }
        else
        {
          SS2out << "  _ _ _ _ _ _ NA _ _ ";
        }
        SS2out << " dev " << endl;
      }
    }

    if (Do_Impl_Error > 0)
    {
      for (i = endyr + 1; i <= YrMax; i++)
      {
        NP++;
        SS2out << NP << " " << ParmLabel(NP) << " " << Fcast_impl_error(i);
        if (Fcast_recr_PH2 > 0) //  intentionally using recdev phase
        {
          active_count++;
          SS2out << " " << active_count << " " << Fcast_recr_PH2 << " -1 1 0 0 act " << CoVar(active_count, 1) << " " << parm_gradients(active_count);
        }
        else
        {
          SS2out << "  _ _ _ _ _ _ NA _ _ ";
        }
        SS2out << " dev " << endl;
      }
    }
    for (j = 1; j <= N_init_F; j++)
    {
      NP++;
      Activ = 0;
      if (active(init_F(j)))
      {
        active_count++;
        Activ = 1;
      }
      Report_Parm(NP, active_count, Activ, init_F(j), init_F_LO(j), init_F_HI(j), init_F_RD(j), init_F_use(j), init_F_PR(j), init_F_CV(j), init_F_PRtype(j), init_F_PH(j), init_F_Like(j));
    }

    if (N_Fparm > 0)
    {
      for (i = 1; i <= N_Fparm; i++)
      {
        NP++;
        Activ = 0;
        SS2out << NP << " " << ParmLabel(NP) << " " << F_rate(i);
        if (active(F_rate(i)))
        {
          active_count++;
          Activ = 1;
          SS2out << " " << active_count << " " << Fparm_PH[i] << " 0.0 " << max_harvest_rate << " " << F_parm_intval(Fparm_loc[i](1)) << " " << Fparm_use(i) << " act " << CoVar(active_count, 1) << " " << parm_gradients(active_count);
        }
        else
        {
          SS2out << " _ _ _ _ _ _ NA _ _ ";
        }
        SS2out << " F " << endl;
      }
    }

    for (j = 1; j <= Q_Npar2; j++)
    {
      NP++;
      Activ = 0;
      if (active(Q_parm(j)))
      {
        active_count++;
        Activ = 1;
      }
      Report_Parm(NP, active_count, Activ, Q_parm(j), Q_parm_LO(j), Q_parm_HI(j), Q_parm_RD(j), Q_parm_use(j), Q_parm_PR(j), Q_parm_CV(j), Q_parm_PRtype(j), Q_parm_PH(j), Q_parm_Like(j));
    }

    for (j = 1; j <= N_selparm2; j++)
    {
      NP++;
      Activ = 0;
      if (active(selparm(j)))
      {
        active_count++;
        Activ = 1;
      }
      Report_Parm(NP, active_count, Activ, selparm(j), selparm_LO(j), selparm_HI(j), selparm_RD(j), selparm_use(j), selparm_PR(j), selparm_CV(j), selparm_PRtype(j), selparm_PH(j), selparm_Like(j));
    }

    if (Do_TG > 0)
    {
      k = 3 * N_TG + 2 * Nfleet1;
      for (j = 1; j <= k; j++)
      {
        NP++;
        Activ = 0;
        if (active(TG_parm(j)))
        {
          active_count++;
          Activ = 1;
        }
        Report_Parm(NP, active_count, Activ, TG_parm(j), TG_parm_LO(j), TG_parm_HI(j), TG_parm2(j, 3), TG_parm_use(j), TG_parm2(j, 4), TG_parm2(j, 5), TG_parm2(j, 6), TG_parm_PH(j), TG_parm_Like(j));
      }
    }

    if (N_parm_dev > 0)
    {
      for (i = 1; i <= N_parm_dev; i++)
        for (j = parm_dev_minyr(i); j <= parm_dev_maxyr(i); j++)
        {
          NP++;
          SS2out << NP << " " << ParmLabel(NP) << " " << parm_dev(i, j);
          if (parm_dev_PH(i) > 0)
          {
            active_count++;
            SS2out << " " << active_count << " " << parm_dev_PH(i) << " -10 10 " << parm_dev_RD(i, j) << " " << parm_dev_use(i, j);
            temp = (parm_dev(i, j) - (-10)) / (20);
            if (temp <= 0.0 || temp >= 1.0)
            {
              SS2out << " BOUND ";
              Nparm_on_bound++;
            }
            else if (temp < 0.01)
            {
              SS2out << " LO ";
              Nparm_on_bound++;
            }
            else if (temp >= 0.99)
            {
              SS2out << " HI ";
              Nparm_on_bound++;
            }
            else if (parm_dev(i, j) == parm_dev_use(i, j) && parm_dev_PH(i) > 0)
            {
              SS2out << " NO_MOVE ";
            }
            else
            {
              SS2out << " act ";
            }
            SS2out << CoVar(active_count, 1) << " " << parm_gradients(active_count) << " dev " << endl;
          }
          else
          {
            SS2out << " _ _ _ _ _ _ NA _ _ dev" << endl;
          }
        }
    }

    SS2out << "#" << endl
           << "Number_of_parameters: " << NP << endl;
    SS2out << "Active_count: " << active_count << endl;
    SS2out << "Number_of_active_parameters_on_or_within_1%_of_min-max_bound: " << Nparm_on_bound << endl;
  }

  // REPORT_KEYWORD 6 DERIVED_QUANTITIES
  if (pick_report_use(6) == "Y")
  {
    SS2out << endl
           << pick_report_name(6) << endl;
    SS2out << "SPR_report_basis: " << SPR_report_label << endl;
    SS2out << "F_report_basis: " << F_report_label << endl;
    SS2out << "B_ratio_denominator: " << depletion_basis_label << endl;
    NP = deriv_start;
    active_count = deriv_covar_start;
    SS2out << "Label Value  StdDev (Val-1.0)/Stddev  CumNorm" << endl;
    for (j = 1; j <= N_STD_Yr; j++)
    {
      NP++;
      SS2out << ParmLabel(NP) << " " << SSB_std(j);
      active_count++;
      SS2out << " " << CoVar(active_count, 1) << endl;
    }
    for (j = 1; j <= N_STD_Yr; j++)
    {
      NP++;
      SS2out << ParmLabel(NP) << " " << recr_std(j);
      active_count++;
      SS2out << " " << CoVar(active_count, 1) << endl;
    }
    for (j = 1; j <= N_STD_Yr_Ofish; j++)
    {
      NP++;
      SS2out << ParmLabel(NP) << " " << SPR_std(j);
      active_count++;
      SS2out << " " << CoVar(active_count, 1);
      if (CoVar(active_count, 1) > 0.0)
      {
        temp = value((SPR_std(j) - 1.0) / CoVar(active_count, 1));
        SS2out << " " << temp << " " << cumd_norm(temp);
      }
      SS2out << endl;
    }
    post_vecs << runnumber << " 0 " << obj_fun << " F/Fmsy_stdev ";
    for (j = 1; j <= N_STD_Yr_F; j++)
    {
      NP++;
      SS2out << ParmLabel(NP) << " " << F_std(j);
      active_count++;
      SS2out << " " << CoVar(active_count, 1);
      post_vecs << CoVar(active_count, 1) << " ";
      if (CoVar(active_count, 1) > 0.0)
      {
        temp = value((F_std(j) - 1.0) / CoVar(active_count, 1));
        SS2out << " " << temp << " " << cumd_norm(temp);
      }
      SS2out << endl;
    }
    post_vecs << endl;
    post_vecs << runnumber << " 0 " << obj_fun << " B/Bmsy_stdev ";

    for (j = 1; j <= N_STD_Yr_Dep; j++)
    {
      NP++;
      SS2out << ParmLabel(NP) << " " << depletion(j);
      active_count++;
      SS2out << " " << CoVar(active_count, 1);
      post_vecs << CoVar(active_count, 1) << " ";
      if (CoVar(active_count, 1) > 0.0)
      {
        temp = value((depletion(j) - 1.0) / CoVar(active_count, 1));
        SS2out << " " << temp << " " << cumd_norm(temp);
      }
      SS2out << endl;
    }
    post_vecs << endl;
    for (j = 1; j <= N_STD_Mgmt_Quant; j++)
    {
      NP++;
      active_count++;
      SS2out << ParmLabel(NP) << " " << Mgmt_quant(j);

      SS2out << " " << CoVar(active_count, 1) << endl;
    }

    for (j = 1; j <= Extra_Std_N; j++)
    {
      NP++;
      active_count++;
      SS2out << ParmLabel(NP) << " " << Extra_Std(j);
      SS2out << " " << CoVar(active_count, 1) << endl;
    }

    if (Svy_N_sdreport > 0)
    {
      k = 0;
      for (f = 1; f <= Nfleet; ++f)
      {
        if (Svy_sdreport(f) > 0)
        {
          for (j = 1; j <= Svy_N_fleet(f); j++)
          {
            active_count++;
            k++;
            SS2out << fleetname(f) << "_" << Svy_yr(f, j) << " ";
            SS2out << Svy_est(f, j) << " " << CoVar(active_count, 1) << " " << Svy_sdreport_est(k) << endl;
          }
        }
      }
    }
  }

  // REPORT_KEYWORD 7 MGPARM_BY_YEAR
  if (pick_report_use(7) == "Y")
  {
    k1 = YrMax;
    SS2out << endl
           << pick_report_name(7) << endl;
    SS2out << "Yr   Change? ";
    for (i = 1; i <= N_MGparm2; i++)
      SS2out << " " << ParmLabel(i);
    SS2out << endl;
    for (y = styr; y <= k1; y++)
      SS2out << y << " " << timevary_MG(y, 0) << " " << mgp_save(y) << endl;
    SS2out << endl;
  }

  // REPORT_KEYWORD 8 SELPARM_SIZE_BY_YEAR
  if (pick_report_use(8) == "Y")
  {
    k1 = YrMax;
    if (Fcast_timevary_Selex == 0)
    {
      SS2out << "forecast_selectivity_averaged_over_years:_" << Fcast_Sel_yr1 << "_to_" << Fcast_Sel_yr2 << endl;
    }
    else
    {
      SS2out << "forecast_selectivity_from_time-varying_parameters " << endl;
    }
    SS2out << endl
           << pick_report_name(8) << endl;
    SS2out << "Fleet Yr  Change?  Parameters" << endl;
    for (f = 1; f <= Nfleet; f++)
      for (y = styr; y <= k1; y++)
      {
        k = N_selparmvec(f);
        if (k > 0)
          SS2out << f << " " << y << " " << timevary_sel(y, f) << " " << save_sp_len(y, f)(1, k) << endl;
      }
  }

  // REPORT_KEYWORD 9 SELPARM_AGE_BY_YEAR
  if (pick_report_use(9) == "Y")
  {
    k1 = YrMax;
    SS2out << endl
           << pick_report_name(9) << endl;
    SS2out << "Fleet Yr  Change?  Parameters" << endl;
    for (f = Nfleet + 1; f <= 2 * Nfleet; f++)
      for (y = styr; y <= k1; y++)
      {
        k = N_selparmvec(f);
        if (k > 0)
          SS2out << f - Nfleet << " " << y << " " << timevary_sel(y, f) << " " << save_sp_len(y, f)(1, k) << endl;
      }
  }

  // REPORT_KEYWORD 10 RECRUITMENT_DISTRIBUTION
  if (pick_report_use(10) == "Y")
  {
    SS2out << endl
           << pick_report_name(10) << endl;
    SS2out << "Settle# settle_timing# G_pattern Area Settle_Month Seas Age Time_w/in_seas Frac/sex" << endl;
    for (settle = 1; settle <= N_settle_assignments; settle++)
    {
      gp = settlement_pattern_rd(settle, 1); //  growth patterns
      p = settlement_pattern_rd(settle, 3); //  settlement area
      settle_time = settle_assignments_timing(settle);
      SS2out << settle << " " << settle_time << " " << gp << " " << p << " " << Settle_month(settle_time) << " " << Settle_seas(settle_time) << " " << Settle_age(settle_time) << " " << Settle_timing_seas(settle_time) << " " << recr_dist(styr, gp, settle_time, p) << endl;
    }
    SS2out << "#" << endl
           << "RECRUITMENT_DIST_Bmark" << endl
           << "Settle# settle_timing# G_pattern Area Settle_Month Seas Age Time_w/in_seas Frac/sex" << endl;
    for (settle = 1; settle <= N_settle_assignments; settle++)
    {
      gp = settlement_pattern_rd(settle, 1); //  growth patterns
      p = settlement_pattern_rd(settle, 3); //  settlement area
      settle_time = settle_assignments_timing(settle);
      SS2out << settle << " " << settle_time << " " << gp << " " << p << " " << Settle_month(settle_time) << " " << Settle_seas(settle_time) << " " << Settle_age(settle_time) << " " << Settle_timing_seas(settle_time) << " " << recr_dist_unf(gp, settle_time, p) / (Bmark_Yr(8) - Bmark_Yr(7) + 1) << endl;
    }
    SS2out << "#" << endl
           << "RECRUITMENT_DIST_endyr" << endl
           << "Settle# settle_timing# G_pattern Area Settle_Month Seas Age Time_w/in_seas Frac/sex" << endl;
    for (settle = 1; settle <= N_settle_assignments; settle++)
    {
      gp = settlement_pattern_rd(settle, 1); //  growth patterns
      p = settlement_pattern_rd(settle, 3); //  settlement area
      settle_time = settle_assignments_timing(settle);
      SS2out << settle << " " << settle_time << " " << gp << " " << p << " " << Settle_month(settle_time) << " " << Settle_seas(settle_time) << " " << Settle_age(settle_time) << " " << Settle_timing_seas(settle_time) << " " << recr_dist_endyr(gp, settle_time, p) << endl;
    }

    SS2out << "#" << endl;
    SS2out << "RECRUITMENT_DIST_TIMESERIES" << endl
           << "Year settle_assignment" << endl;
    SS2out << "Year ";
    for (settle = 1; settle <= N_settle_assignments; settle++)
      SS2out << settle << " ";
    SS2out << endl;

    for (y = styr; y <= YrMax; y++)
    {
      SS2out << y << " ";
      for (gp = 1; gp <= N_GP; gp++)
        for (settle = 1; settle <= N_settle_timings; settle++)
          for (p = 1; p <= pop; p++)
            if (recr_dist_pattern(gp, settle, p) == 1)
              SS2out << " " << recr_dist(y, gp, settle, p);
      SS2out << endl;
    }
  }

  // REPORT_KEYWORD 11 MORPH_INDEXING
  if (pick_report_use(11) == "Y")
  {
    SS2out << endl
           << pick_report_name(11) << endl;
    SS2out << "Index GP Sex BirthSeas Platoon Platoon_Dist Sex*GP Sex*GP*Settle BirthAge_Rel_Jan1" << endl;
    for (g = 1; g <= gmorph; g++)
    {
      SS2out << g << " " << GP4(g) << " " << sx(g) << " " << Bseas(g) << " " << GP2(g) << " " << platoon_distr(GP2(g)) << " " << GP(g) << " " << GP3(g) << " " << azero_G(g) << endl;
    }
  }

  // REPORT_KEYWORD 12 SIZEFREQ_TRANSLATION
  //  3darray SzFreqTrans(1,SzFreq_Nmeth*nseas,1,nlength2,1,SzFreq_Nbins_seas_g);
  if (pick_report_use(12) == "Y" && SzFreq_Nmeth > 0)
  {
    SS2out << endl
           << pick_report_name(12) << endl;
    SS2out << "#NOTE: rows_are_population_length_bins;_columns_are_recipient_size_bins_according_to_the_specified_method" << endl;
    for (SzFreqMethod = 1; SzFreqMethod <= SzFreq_Nmeth; SzFreqMethod++)
    {
      SS2out << SzFreqMethod << " gp seas len mid-len ";
      if (SzFreq_scale(SzFreqMethod) == 1)
      {
        SS2out << " mid-kg ";
      }
      else if (SzFreq_scale(SzFreqMethod) == 2)
      {
        SS2out << " mid-lbs ";
      }
      else if (SzFreq_scale(SzFreqMethod) == 3)
      {
        SS2out << " mid-cm ";
      }
      else
      {
        SS2out << " mid-inch ";
      }
      SS2out << SzFreq_bins1(SzFreqMethod);
      if (gender == 2)
        SS2out << SzFreq_bins1(SzFreqMethod);
      SS2out << endl
             << SzFreqMethod << " gp seas len mid-len metric " << SzFreq_bins(SzFreqMethod) << endl;
      ;
      for (gp = 1; gp <= N_GP; gp++)
        for (s = 1; s <= nseas; s++)
        {
          SzFreqMethod_seas = nseas * (SzFreqMethod - 1) + s; // index that combines sizefreqmethod and season and used in SzFreqTrans
          for (z = 1; z <= nlength2; z++)
          {
            SS2out << SzFreqMethod << " " << gp << " " << s << " " << len_bins2(z) << " " << len_bins_m2(z) << " ";
            if (SzFreq_scale(SzFreqMethod) == 1)
            {
              SS2out << wt_len2(s, gp, z) << " ";
            }
            else if (SzFreq_scale(SzFreqMethod) == 2)
            {
              SS2out << wt_len2(s, gp, z) / 0.4536 << " ";
            }
            else if (SzFreq_scale(SzFreqMethod) == 3)
            {
              SS2out << len_bins_m2(z) << " ";
            }
            else
            {
              SS2out << len_bins_m2(z) / 2.54 << " ";
            }
            for (j = 1; j <= gender * SzFreq_Nbins(SzFreqMethod); j++)
            {
              SS2out << SzFreqTrans(SzFreqMethod_seas, z, j) << " ";
              if (SzFreqTrans(SzFreqMethod_seas, z, j) < 0.0)
              {
                warnstream << "Bin widths narrower than pop len bins caused negative allocation in sizefreq method:";
                warnstream << " method, season, size, bin: " << SzFreqMethod << " " << s << " " << len_bins2(z) << " " << j;
                write_message (FATAL, 0); // EXIT!
              }
            }
            SS2out << endl;
          }
        }
    }
  }

  // REPORT_KEYWORD 13 MOVEMENT

  if (pick_report_use(13) == "Y" && do_migration > 0)
  {
    SS2out << endl
           << pick_report_name(13) << endl;
    SS2out << " Seas GP Source_area Dest_area minage maxage " << age_vector << endl;
    for (k = 1; k <= do_migr2; k++)
    {
      SS2out << move_def2(k) << " " << migrrate(endyr, k) << endl;
    }
  }

  // REPORT_KEYWORD 14 EXPLOITATION
  if (pick_report_use(14) == "Y")
  {
    SS2out << endl
           << pick_report_name(14) << endl;
    SS2out << "Info: Displays.various.annual.F.statistics.and.displays.apical.F.for.each.fleet.by.season" << endl;
    SS2out << "Info: F_Method:=" << F_Method;
    if (F_Method == 1)
    {
      SS2out << ";.Pope's_approx,.fleet.F.is.mid-season.exploitation.fraction ";
    }
    else
    {
      SS2out << ";.Continuous_F;.fleet.F.will.be.multiplied.by.season.duration.when.it.is.used.and.in.the.F_std.calculation";
    }
    SS2out << endl
           << "Info: Displayed.fleet-specific.F.values.are.the.F.for.ages.with.compound.age-length-sex.selectivity=1.0" << endl;
    SS2out << "Info: F_std_basis:." << F_report_label << endl;
    SS2out << "F_std averaged over N years: " << F_std_multi << endl;
    if (F_reporting >= 4)
    {
      SS2out << "Info: Annual_F.shown.here.is.done.by.the.Z-M.method.for.ages:." << F_reporting_ages(1) << "-" << F_reporting_ages(2) << endl;
    }
    else
    {
      SS2out << "Info: Annual_F.shown.here.is.done.by.the.Z-M.method.for.nages/2=" << nages / 2 << endl;
    }
    SS2out << "#" << endl;
    SS2out << "Yr Seas Seas_dur F_std annual_F annual_M ";
    for (f = 1; f <= Nfleet; f++)
      if (fleet_type(f) <= 2)
      {
        SS2out << " " << fleetname(f);
      }
    SS2out << endl;
    SS2out << "Catchunits: _ _ _ _ _ ";
    for (f = 1; f <= Nfleet; f++)
      if (fleet_type(f) <= 2)
      {
        if (catchunits(f) == 1)
        {
          SS2out << " Bio ";
        }
        else
        {
          SS2out << " Num ";
        }
      }
    SS2out << endl
           << "FleetType: _ _ _ _ _ ";
    for (f = 1; f <= Nfleet; f++)
      if (fleet_type(f) <= 2)
      {
        if (fleet_type(f) == 1)
        {
          SS2out << " Catch ";
        }
        else
        {
          SS2out << " Bycatch ";
        }
      }
    SS2out << endl
           << "FleetArea: _ _ _ _ _ ";
    for (f = 1; f <= Nfleet; f++)
      if (fleet_type(f) <= 2)
      {
        SS2out << " " << fleet_area(f);
      }
    SS2out << endl
           << "FleetID: _ _ _ _ _ ";
    for (f = 1; f <= Nfleet; f++)
      if (fleet_type(f) <= 2)
      {
        SS2out << " " << f;
      }
    SS2out << endl;
    if (N_init_F > 0)
    {
      for (s = 1; s <= nseas; s++)
      {
        SS2out << "INIT " << s << " " << seasdur(s) << " _  _  _ ";
        for (f = 1; f <= Nfleet; f++)
          if (fleet_type(f) <= 2)
          {
            if (init_F_loc(s, f) > 0)
            {
              SS2out << " " << init_F(init_F_loc(s, f));
            }
            else
            {
              SS2out << " _ ";
            }
          }
        SS2out << endl;
      }
    }

    for (y = styr; y <= YrMax; y++)
      for (s = 1; s <= nseas; s++)
      {
        t = styr + (y - styr) * nseas + s - 1;
        SS2out << y << " " << s << " " << seasdur(s);
        if (s == 1 && STD_Yr_Reverse_F(y) > 0)
        {
          SS2out << " " << F_std(STD_Yr_Reverse_F(y));
        }
        else
        {
          SS2out << " _ ";
        }
        SS2out << " " << annual_F(y)(2, 3);
        for (f = 1; f <= Nfleet; f++)
          if (fleet_type(f) <= 2)
          {
            SS2out << " " << Hrate(f, t);
          }
        SS2out << endl;
      }
  }

  // REPORT_KEYWORD 15 CATCH
  if (pick_report_use(15) == "Y")
  {
    SS2out << endl
           << pick_report_name(15) << endl;
    SS2out << "# where vuln_ is mid-season selected bio or numbers; sel_ is selected total catch; dead_ is catch without live discards; ret_ is retained catch" << endl;
    SS2out << "Fleet Fleet_Name Area Yr Seas Time Obs Exp Mult Exp*Mult se F  Like vuln_bio sel_bio dead_bio ret_bio vuln_num sel_num dead_num ret_num" << endl;
    for (f = 1; f <= Nfleet; f++)
    {
      if (fleet_type(f) <= 2)
      {
        for (y = styr - 1; y <= endyr; y++)
          for (s = 1; s <= nseas; s++)
          {
            t = styr + (y - styr) * nseas + s - 1;
            if (catchunits(f) == 1)
            {
              gg = 3;
            } //  biomass
            else
            {
              gg = 6;
            } //  numbers
            temp = float(y) + 0.01 * int(100. * (azero_seas(s) + seasdur_half(s)));
            SS2out << f << " " << fleetname(f) << " " << fleet_area(f) << " ";
            if (y < styr)
            {
              SS2out << "INIT ";
            }
            else
            {
              SS2out << y << " ";
            }
            SS2out << s << " " << temp << " " << catch_ret_obs(f, t) << " " << catch_fleet(t, f, gg) << " " << catch_mult(y, f) << " " << catch_mult(y, f) * catch_fleet(t, f, gg);
            SS2out << " " << catch_se(t, f) << " " << Hrate(f, t) << " ";
            if (fleet_type(f) == 1)
            {
              if (catch_ret_obs(f, t) > 0 && F_Method > 1)
              {
                SS2out << 0.5 * square((log(1.1 * catch_ret_obs(f, t)) - log(catch_fleet(t, f, gg) * catch_mult(y, f) + 0.1 * catch_ret_obs(f, t))) / catch_se(t, f));
              }
              else
              {
                SS2out << " NA";
              }
            }
            else
            {
              SS2out << "BYCATCH";
            }
            SS2out << " " << vuln_bio(t, f) << " " << catch_fleet(t, f)(1,3) << " " << vuln_num(t, f) << " " << catch_fleet(t, f)(4,6) << endl;
          }
      }
    }
  }
  int bio_t;
  dvector Bio_Comp(1, N_GP * gender);
  dvector Num_Comp(1, N_GP * gender);
  // REPORT_KEYWORD 16 TIME_SERIES
  //  Fleet Fleet_Name Area Yr Era Seas Subseas Month Time
  if (pick_report_use(16) == "Y")
  {
    SS2out << endl
           << pick_report_name(16);
    SS2out << "  BioSmry_age:_" << Smry_Age; // SS_Label_320
    if (F_Method == 1)
    {
      SS2out << "  Pope's_approx" << endl;
    }
    else
    {
      SS2out << "  Continuous_F" << endl;
    }
    SS2out << "Area Yr Era Seas Bio_all Bio_smry SpawnBio Recruit_0 ";
    for (gp = 1; gp <= N_GP; gp++)
      SS2out << " SpawnBio_GP:" << gp;
    if (Hermaphro_Option != 0)
    {
      for (gp = 1; gp <= N_GP; gp++)
        SS2out << " MaleSpawnBio_GP:" << gp;
    }
    for (gg = 1; gg <= gender; gg++)
      for (gp = 1; gp <= N_GP; gp++)
      {
        SS2out << " SmryBio_SX:" << gg << "_GP:" << gp;
      }

    for (gg = 1; gg <= gender; gg++)
    {
      for (gp = 1; gp <= N_GP; gp++)
      {
        SS2out << " SmryNum_SX:" << gg << "_GP:" << gp;
      }
    }
    SS2out << " mature_bio mature_num ";

    for (f = 1; f <= Nfleet; f++)
      if (fleet_type(f) <= 2)
      {
        SS2out << " sel(B):_" << f << " dead(B):_" << f << " retain(B):_" << f << " sel(N):_" << f << " dead(N):_" << f << " retain(N):_" << f << " obs_cat:_" << f;
        if (F_Method == 1)
        {
          SS2out << " Hrate:_" << f;
        }
        else
        {
          SS2out << " F:_" << f;
        }
      }

    SS2out << " SSB_vir_LH ABC_buffer" << endl;
    for (p = 1; p <= pop; p++)
    {
      for (y = styr - 2; y <= YrMax; y++)
      {
        if (y <= endyr && p == 1)
        {
          Smry_Table(y)(15, 17).initialize();
        }
        for (s = 1; s <= nseas; s++)
        {
          t = styr + (y - styr) * nseas + s - 1;
          bio_t = t;
          if (y <= styr)
          {
            bio_t = styr - 1 + s;
          }
          Bio_Comp.initialize();
          Num_Comp.initialize();
          totbio.initialize();
          smrybio.initialize();
          smrynum.initialize();
          SSB_vir_LH.initialize();
          smryage.initialize();
          //    Recr(p,y)=0;
          for (g = 1; g <= gmorph; g++)
            if (use_morph(g) > 0)
            {
              //     if(s==Bseas(g)) Recr(p,y)+=natage(t,p,g,0);
              gg = sx(g);
              temp = natage(t, p, g)(Smry_Age, nages) * Wt_Age_t(bio_t, 0, g)(Smry_Age, nages);
              Bio_Comp(GP(g)) += value(temp); //sums to accumulate across platoons and settlements
              Num_Comp(GP(g)) += value(sum(natage(t, p, g)(Smry_Age, nages))); //sums to accumulate across platoons and settlements
              totbio += natage(t, p, g) * Wt_Age_t(bio_t, 0, g);
              smrybio += temp;
              smrynum += sum(natage(t, p, g)(Smry_Age, nages));
              smryage += natage(t, p, g)(Smry_Age, nages) * r_ages(Smry_Age, nages);
              SSB_vir_LH += natage(t, p, g) * virg_fec(g);
              if (y <= endyr)
              {
                for (f = 1; f <= Nfleet; f++)
                {
                  if (fleet_area(f) == p && y >= styr - 1 && fleet_type(f) <= 2)
                  {
                    Smry_Table(y, 16) += sum(catage(t, f, g));
                    Smry_Table(y, 17) += catage(t, f, g) * r_ages;
                  }
                }
              }
            } //close gmorph loop
          if (gender_rd == -1)
            SSB_vir_LH *= femfrac(1);
          SS2out << p << " " << y;
          if (y == styr - 2)
          {
            SS2out << " VIRG ";
          }
          else if (y == styr - 1)
          {
            SS2out << " INIT ";
          }
          else if (y <= endyr)
          {
            SS2out << " TIME ";
          }
          else
          {
            SS2out << " FORE ";
          }

          SS2out << s << " " << totbio << " " << smrybio << " ";
          if (s == spawn_seas)
          {
            temp = sum(SSB_pop_gp(y, p));
            if (Hermaphro_maleSPB > 0)
              temp += Hermaphro_maleSPB * sum(MaleSPB(y, p));
            SS2out << temp;
          }
          else
          {
            SS2out << " _ ";
          }
          SS2out << " " << Recr(p, t) << " ";
          if (s == spawn_seas)
          {
            SS2out << SSB_pop_gp(y, p);
            if (Hermaphro_Option != 0)
              SS2out << MaleSPB(y, p);
          }
          else
          {
            for (gp = 1; gp <= N_GP; gp++)
            {
              SS2out << " _ ";
            }
            if (Hermaphro_Option != 0)
            {
              for (gp = 1; gp <= N_GP; gp++)
              {
                SS2out << " _ ";
              }
            }
          }
          SS2out << " " << Bio_Comp << " " << Num_Comp;
          SS2out << " " << SSB_B_yr(y) << " " << SSB_N_yr(y);
          if (s == 1 && y <= endyr)
          {
            Smry_Table(y, 15) += smryage;
          } // already calculated for the forecast years
          for (f = 1; f <= Nfleet; f++)
            if (fleet_type(f) <= 2)
            {
              if (fleet_area(f) == p && y >= styr - 1)
              {
                SS2out << " " << catch_fleet(t, f) << " ";
                if (y <= endyr)
                {
                  SS2out << catch_ret_obs(f, t) << " " << Hrate(f, t);
                }
                else
                {
                  SS2out << " _ " << Hrate(f, t);
                }
                //        if(y<=endyr) {Smry_Table(y,4)+=catch_fleet(t,f,1); Smry_Table(y,5)+=catch_fleet(t,f,2); Smry_Table(y,6)+=catch_fleet(t,f,3);}
              }
              else
              {
                SS2out << " 0 0 0 0 0 0 0 0 ";
              }
            }
          if (s == spawn_seas)
          {
            SS2out << " " << SSB_vir_LH;
          }
          else
          {
            SS2out << " _";
          }
          if (y <= endyr)
          {
            SS2out << " NA";
          }
          else
          {
            SS2out << " " << ABC_buffer(y);
          }
          SS2out << endl;
        }
      }
    }
  }
  // REPORT_KEYWORD 17 SPR_SERIES
  //  Fleet Fleet_Name Area Yr Era Seas Subseas Month Time
  if (pick_report_use(17) == "Y")
  {
    SS2out << endl
           << pick_report_name(17);
    SS2out << "  uses_R0= " << Recr_virgin << endl
           << "#NOTE: YPR_unit_is_Dead_Biomass" << endl;
    SS2out << "Depletion_basis: " << depletion_basis << " # " << depletion_basis_label << endl;
    SS2out << "F_report_basis: " << F_reporting << " # " << F_report_label << endl;
    SS2out << "SPR_report_basis: " << SPR_reporting << " # " << SPR_report_label << endl;
    // note  GENTIME is mean age of spawners weighted by fec(a)
    SS2out << "Yr Era Bio_all Bio_Smry SSBzero SSBfished SSBfished/R SPR SPR_report YPR GenTime Deplete F_report"
           << " Actual: Bio_all Bio_Smry Num_Smry MnAge_Smry Enc_Catch Dead_Catch Retain_Catch MnAge_Catch SSB Recruits Tot_Exploit"
           << " More_F(by_Morph): ";
    for (g = 1; g <= gmorph; g++)
    {
      SS2out << " aveF_" << g;
    }
    for (g = 1; g <= gmorph; g++)
    {
      SS2out << " maxF_" << g;
    }
    SS2out << " Enc_Catch_B Dead_Catch_B Retain_Catch_B  Enc_Catch_N Dead_Catch_N Retain_Catch_N sum_Apical_F F=Z-M  M";
    SS2out << endl;

    for (y = styr; y <= YrMax; y++)
    {
      if (y <= endyr)
      {
        SS2out << y << " TIME ";
      }
      else
      {
        SS2out << y << " FORE ";
      }
      SS2out << Smry_Table(y)(9, 12) << " " << (Smry_Table(y, 12) / Recr_virgin) << " " << Smry_Table(y, 12) / Smry_Table(y, 11) << " ";
      if (STD_Yr_Reverse_Ofish(y) > 0)
      {
        SS2out << SPR_std(STD_Yr_Reverse_Ofish(y)) << " ";
      }
      else
      {
        SS2out << " _ ";
      }
      SS2out << (Smry_Table(y, 14) / Recr_virgin) << " " << Smry_Table(y, 13) << " ";
      if (STD_Yr_Reverse_Dep(y) > 0)
      {
        SS2out << depletion(STD_Yr_Reverse_Dep(y));
      }
      else
      {
        SS2out << " _ ";
      }
      if (y >= styr && STD_Yr_Reverse_F(y) > 0)
      {
        SS2out << " " << F_std(STD_Yr_Reverse_F(y));
      }
      else
      {
        SS2out << " _ ";
      }
      SS2out << " & " << Smry_Table(y)(1, 3) << " " << Smry_Table(y, 15) / Smry_Table(y, 3) << " " << Smry_Table(y)(4, 6) << " " << Smry_Table(y, 17) / (Smry_Table(y, 16) + 1.0e-06);
      SS2out << " " << SSB_yr(y) << " " << exp_rec(y, 4) << " " << Smry_Table(y, 5) / Smry_Table(y, 2);
      SS2out << " & " << Smry_Table(y)(21, 20 + gmorph) << " " << Smry_Table(y)(21 + gmorph, 20 + 2 * gmorph) << " " << annual_catch(y) << " " << annual_F(y) << endl;
    } // end year loop
    // end SPR time series
    SS2out << "#" << endl
           << "#NOTE: GENTIME_is_fecundity_weighted_mean_age" << endl
           << "#NOTE: MnAgeSmry_is_numbers_weighted_meanage_at_and_above_smryage(not_accounting_for_settlement_offsets)" << endl;
  }

  // REPORT_KEYWORD 18 Kobe_Plot
  if (pick_report_use(18) == "Y")
  {
    SS2out << endl
           << pick_report_name(18) << endl;
    if (F_std_basis != 2)
      SS2out << "F_report_basis_is_not_=2;_so_info_below_is_not_F/Fmsy" << endl;
    SS2out << "MSY_basis:_" << MSY_name << endl;
    SS2out << "Yr  B/Bmsy  F/Fmsy" << endl;
    for (y = styr; y <= YrMax; y++)
    {
      SS2out << y << " " << SSB_yr(y) / Bmsy << " ";
      if (y >= styr && STD_Yr_Reverse_F(y) > 0)
      {
        SS2out << " " << F_std(STD_Yr_Reverse_F(y));
      }
      else
      {
        SS2out << " _ ";
      }
      SS2out << endl;
    }
  }

  // ******************************************************************************
  k = Nfleet;
  if (k < 4)
    k = 4;
  // quantities to store summary statistics
  dvector rmse(1, k); //  used in the SpBio, Index, Lencomp and Agecomp reports
  dvector Hrmse(1, k);
  dvector Rrmse(1, k);
  dvector n_rmse(1, k);
  // following vectors used for index-related quantities
  dvector mean_CV(1, k);

  dvector mean_CV2(1, k);

  dvector mean_CV3(1, k);

  // vectors to store mean sample sizes for comp data
  dvector mean_Nsamp_in(1, k);
  dvector mean_Nsamp_adj(1, k);
  dvector mean_Nsamp_DM(1, k);
  //                                                            SS_Label_330

  // REPORT_KEYWORD 19 SPAWN_RECRUIT
  if (pick_report_use(19) == "Y")
  {

    rmse = 0.0;
    n_rmse = 0.0;
    double cross = 0.0;
    double Durbin = 0.0;
    double var = 0.0;

    for (y = recdev_first; y <= recdev_end; y++)
    {
      temp1 = recdev(y);
      if (y < recdev_start) // so in early period
      {
        rmse(3) += value(square(temp1));
        n_rmse(3) += 1.;
        rmse(4) += biasadj(y);
      }
      else
      {
        var += value(square(temp1));
        if (y > recdev_start) // so not first year
        {
          cross += value(temp1 * recdev(y - 1));
          Durbin += value(square(temp1 - recdev(y - 1)));
        }
        rmse(1) += value(square(temp1));
        n_rmse(1) += 1.;
        rmse(2) += biasadj(y);
      }
    }
    if (n_rmse(1) > 0. && rmse(1) > 0.)
      rmse(1) = sqrt(rmse(1) / n_rmse(1)); // rmse during main period
    if (n_rmse(1) > 0.)
      rmse(2) = rmse(2) / n_rmse(1); // mean biasadj during main period
    if (n_rmse(3) > 0. && rmse(3) > 0.)
      rmse(3) = sqrt(rmse(3) / n_rmse(3)); //rmse during early period
    if (n_rmse(3) > 0.)
      rmse(4) = rmse(4) / n_rmse(3); // mean biasadj during early period
    if (n_rmse(1) >= 2.)
    {
      cross /= (n_rmse(1) - 1.);
    }
    else
    {
      cross = 0.0;
    }
    Durbin /= (var + 1.0e-09);
    var /= (n_rmse(1) + 1.0e-09);

    dvariable steepness = SR_parm(2);
    SS2out << endl
           << pick_report_name(19);
    SS2out << "  Function: " << SR_fxn << "  RecDev_method: " << do_recdev << "   sum_recdev: " << sum_recdev << endl
           << SR_parm(1) << " Ln(R0) " << mfexp(SR_parm(1)) << endl
           << steepness << " steepness" << endl
           << Bmsy / SSB_virgin << " Bmsy/Bzero ";
    if (SR_fxn == 8)
    {
      dvariable Shepherd_c;
      dvariable Shepherd_c2;
      dvariable Hupper;
      Shepherd_c = SR_parm(3);
      Shepherd_c2 = pow(0.2, Shepherd_c);
      Hupper = 1.0 / (5.0 * Shepherd_c2);
      temp = 0.2 + (SR_parm(2) - 0.2) / (0.8) * (Hupper - 0.2);
      SS2out << " Shepherd_c: " << Shepherd_c << " steepness_limit: " << Hupper << " Adjusted_steepness: " << temp;
    }
    else if (SR_fxn == 9)
    {
      SS2out << " Ricker_Power: " << SR_parm(3);
    }

    SS2out << endl;
    SS2out << sigmaR << " sigmaR" << endl;
    SS2out << init_equ_steepness << "  # 0/1 to use steepness in initial equ recruitment calculation" << endl;

    SS2out << SR_parm(N_SRparm2 - 1) << " init_eq:  see below" << endl
           << recdev_start << " " << recdev_end << " main_recdev:start_end" << endl
           << recdev_adj(1) << " " << recdev_adj(2, 5) << " breakpoints_for_bias_adjustment_ramp " << endl;

    temp = sigmaR * sigmaR; //  sigmaR^2
    SS2out << "ERA    N    RMSE  RMSE^2/sigmaR^2  mean_BiasAdj est_rho Durbin-Watson" << endl;
    SS2out << "main  " << n_rmse(1) << " " << rmse(1) << " " << square(rmse(1)) / temp << " " << rmse(2) << " " << cross / var << " " << Durbin;
    if (wrote_bigreport == 0) //  first time writing bigreport
    {
      if (rmse(1) < 0.5 * sigmaR && rmse(2) > (0.01 + 2.0 * square(rmse(1)) / temp))
      {
        warnstream << "Main recdev biasadj is >2 times ratio of rmse to sigmaR";
        SS2out << " # " << warnstream.str() ;
        write_message (WARN, 0);
      }
    }
    SS2out << endl;

    SS2out << "early " << n_rmse(3) << " " << rmse(3) << " " << square(rmse(3)) / temp << " " << rmse(4);
    if (wrote_bigreport == 0) //  first time writing bigreport
    {
      if (rmse(3) < 0.5 * sigmaR && rmse(4) > (0.01 + 2.0 * square(rmse(3)) / temp))
      {
        warnstream << "Early recdev biasadj is >2 times ratio of rmse to sigmaR";
        SS2out << " # " << warnstream.str();
        write_message (WARN, 0);
      }
    }
    SS2out << endl;

    SS2out << "Yr SpawnBio exp_recr with_regime bias_adjusted pred_recr dev biasadjuster era mature_bio mature_num raw_dev" << endl;
    SS2out << "S/Rcurve " << SSB_virgin << " " << Recr_virgin << endl;
    y = styr - 2;
    SS2out << "Virg " << SSB_yr(y) << " " << exp_rec(y) << " - " << 0.0 << " Virg " << SSB_B_yr(y) << " " << SSB_N_yr(y) << " 0.0 " << endl;
    y = styr - 1;
    SS2out << "Init " << SSB_yr(y) << " " << exp_rec(y) << " - " << 0.0 << " Init " << SSB_B_yr(y) << " " << SSB_N_yr(y) << " " << 0.0 << endl;

    if (recdev_first < styr)
    {
      for (y = recdev_first; y <= styr - 1; y++)
      {
        SS2out << y << " " << SSB_yr(styr - 1) << " " << exp_rec(styr - 1, 1) << " " << exp_rec(styr - 1, 2) << " " << exp_rec(styr - 1, 3) * mfexp(-biasadj(y) * half_sigmaRsq) << " " << exp_rec(styr - 1, 3) * mfexp(recdev(y) - biasadj(y) * half_sigmaRsq) << " "
               << recdev(y) << " " << biasadj(y) << " Init_age " << SSB_B_yr(styr - 1) << " " << SSB_N_yr(styr - 1) << " " << recdev(y) << endl; // newdev approach uses devs for initial agecomp directly
      }
    }
    for (y = styr; y <= YrMax; y++)
    {
      SS2out << y << " " << SSB_yr(y) << " " << exp_rec(y) << " ";
      if (recdev_do_early > 0 && y >= recdev_early_start && y <= recdev_early_end)
      {
        SS2out << log(exp_rec(y, 4) / exp_rec(y, 3)) << " " << biasadj(y) << " Early " << SSB_B_yr(y) << " " << SSB_N_yr(y) << " " << recdev(y);
      }
      else if (y >= recdev_start && y <= recdev_end)
      {
        SS2out << log(exp_rec(y, 4) / exp_rec(y, 3)) << " " << biasadj(y) << " Main " << SSB_B_yr(y) << " " << SSB_N_yr(y) << " " << recdev(y);
      }
      else if (Do_Forecast > 0 && y > recdev_end)
      {
        SS2out << log(exp_rec(y, 4) / exp_rec(y, 3)) << " " << biasadj(y);
        if (y <= endyr)
        {
          SS2out << " Late ";
        }
        else
        {
          SS2out << " Fore ";
        }
        SS2out << SSB_B_yr(y) << " " << SSB_N_yr(y) << " ";
        if (do_recdev > 0)
        {
          SS2out << Fcast_recruitments(y);
        }
        else
        {
          SS2out << " 0.0";
        }
      }
      else
      {
        SS2out << " _ _ Fixed";
      }
      SS2out << endl;
    }

    // REPORT_KEYWORD SPAWN_RECR_CURVE
    if (pick_report_use(20) == "Y")
    {
      {
        SS2out << endl
               << pick_report_name(20) << endl;
        SS2out << "SSB/SSB_virgin    SSB    Recruitment" << endl;
        y = styr;
        SR_parm_work = SR_parm_byyr(styr);
        for (f = 1; f <= 120; f++)
        {
          SSB_current = double(f) / 100. * SSB_virgin;
          temp = Spawn_Recr(SSB_virgin, Recr_virgin, SSB_current);
          SS2out << SSB_current / SSB_virgin << " " << SSB_current << " " << temp << endl;
        }
      }
    }

    // REPORT_KEYWORD 22 INDEX_2 Survey Observations by Year
    if (pick_report_use(22) == "Y" && Svy_N > 0)
    {
      SS2out << endl
             << pick_report_name(22) << endl;
      //  where show_time(t) contains:  yr, seas
      //  data_time(ALK,f) has real month; 2nd is timing within season; 3rd is year.fraction
      //  show_time2(ALK) has yr, seas, subseas
      rmse = 0.0;
      n_rmse = 0.0;
      mean_CV = 0.0;
      mean_CV2 = 0.0;
      mean_CV3 = 0.0;
      SS2out << "Fleet Fleet_name Area Yr Seas Subseas Month Time Vuln_bio Obs Exp Calc_Q Eff_Q SE SE_input Dev Like Like+log(s) SuprPer Use" << endl;
      for (f = 1; f <= Nfleet; f++)
      {
        in_superperiod = 0;
        for (i = 1; i <= Svy_N_fleet(f); i++)
        {
          t = Svy_time_t(f, i);
          ALK_time = Svy_ALK_time(f, i);
          SS2out << f << " " << fleetname(f) << " " << fleet_area(f) << " " << Show_Time2(ALK_time) << " " << data_time(ALK_time, f, 1) << " " << data_time(ALK_time, f, 3) << " " << Svy_selec_abund(f, i) << " " << Svy_obs(f, i) << " ";
          if (Svy_errtype(f) >= 0) // lognormal or T-dist
          {
            temp = mfexp(Svy_est(f, i));
            SS2out << temp << " " << Svy_q(f, i) << " " << temp / Svy_selec_abund(f, i) << " " << Svy_se_use(f, i) << " " << Svy_se(f, i);
            if (Svy_use(f, i) > 0)
            {
              SS2out << " " << Svy_obs_log(f, i) - Svy_est(f, i) << " ";
              SS2out << Svy_like_I(f, i) - log(Svy_se_use(f, i)) << " " << Svy_like_I(f,i) << " ";
              rmse(f) += value(square(Svy_obs_log(f, i) - Svy_est(f, i)));
              n_rmse(f) += 1.;
              mean_CV(f) += Svy_se_rd(f, i);
              mean_CV3(f) += Svy_se(f, i);
              mean_CV2(f) += value(Svy_se_use(f, i));
            }
            else
            {
              SS2out << " _ _ _ ";
            }
          }
          else // normal
          {
            SS2out << Svy_est(f, i) << " " << Svy_q(f, i) << " " << Svy_est(f, i) / Svy_selec_abund(f, i) << " " << Svy_se_use(f, i) << " " << Svy_se(f, i);
            if (Svy_use(f, i) > 0)
            {
              SS2out << " " << Svy_obs(f, i) - Svy_est(f, i) << " ";
              SS2out << Svy_like_I(f, i) - log(Svy_se_use(f, i)) << " " << Svy_like_I(f,i) << " ";
              rmse(f) += value(square(Svy_obs(f, i) - Svy_est(f, i)));
              n_rmse(f) += 1.;
              mean_CV(f) += Svy_se_rd(f, i);
              mean_CV3(f) += Svy_se(f, i);
              mean_CV2(f) += value(Svy_se_use(f, i));
            }
            else
            {
              SS2out << " _ _ _ ";
            }
          }
          if (Svy_super(f, i) < 0 && in_superperiod == 0)
          {
            in_superperiod = 1;
            SS2out << " beg_SuprPer ";
          }
          else if (Svy_super(f, i) < 0 && in_superperiod == 1)
          {
            in_superperiod = 0;
            SS2out << " end_SuprPer ";
          }
          else if (in_superperiod == 1)
          {
            SS2out << " in_SuprPer ";
          }
          else
          {
            SS2out << " _ ";
          }
          SS2out << Svy_use(f, i);
          SS2out << endl;
        }
        if (n_rmse(f) > 0)
        {
          rmse(f) = sqrt((rmse(f) + 1.0e-9) / n_rmse(f));
          mean_CV(f) /= n_rmse(f);
          mean_CV3(f) /= n_rmse(f);
          mean_CV2(f) /= n_rmse(f);
        }
      }
    }

    // REPORT_KEYWORD 21 INDEX_1  Survey Fit Summary
    SS2out << endl
           << pick_report_name(21) << endl;
    SS2out << "Fleet Link Link+ ExtraStd BiasAdj Float   Q Num=0/Bio=1 Err_type"
           << " N Npos RMSE logL  mean_input_SE Input+VarAdj Input+VarAdj+extra VarAdj New_VarAdj penalty_mean_Qdev rmse_Qdev fleetname" << endl;
    for (f = 1; f <= Nfleet; f++)
    {
      if (Svy_N_fleet(f) > 0)
      {
        SS2out << f << " " << Q_setup(f) << " " << Svy_q(f, 1) << " " << Svy_units(f) << " " << Svy_errtype(f)
               << " " << Svy_N_fleet(f) << " " << n_rmse(f) << " " << rmse(f)<< " " << surv_like(f) 
               << " " << mean_CV(f) << " " << mean_CV3(f) << " " << mean_CV2(f) << " " << var_adjust(1, f)
               << " " << var_adjust(1, f) + rmse(f) - mean_CV(f)
               << " " << Q_dev_like(f, 1) << " " << Q_dev_like(f, 2) << " " << fleetname(f) << endl;
      }
    }
    if (depletion_fleet > 0) //  special code for depletion, so prepare to adjust phases and lambdas
    {
      f = depletion_fleet;
      SS2out << "#_survey: " << f << " " << fleetname(f) << " is a depletion fleet" << endl;
      if (depletion_type == 0)
        SS2out << "#_Q_setup(f,2)=0; add 1 to phases of all parms; only R0 active in new phase 1" << endl;
      if (depletion_type == 1)
        SS2out << "#_Q_setup(f,2)=1  only R0 active in phase 1; then exit;  useful for data-limited draws of other fixed parameter" << endl;
      if (depletion_type == 2)
        SS2out << "#_Q_setup(f,2)=2  no phase adjustments, can be used when profiling on fixed R0" << endl;
    }

    SS2out << "RMSE_Qdev_not_in_logL" << endl
           << "penalty_mean_Qdev_not_in_logL_in_randwalk_approach" << endl;

    // REPORT_KEYWORD 23 INDEX_3  Survey_Q_setup
    SS2out << endl
           << pick_report_name(23) << endl;
    SS2out << "#" << endl
           << "Fleet  Q_parm_assignments" << endl;
    for (f = 1; f <= Nfleet; f++)
    {
      SS2out << f << " " << Q_setup_parms(f, 1) << " _ " << Q_setup_parms(f, 2) << " _ " << Q_setup_parms(f)(3, 4) << " " << fleetname(f) << endl;
    }
  }

  // REPORT_KEYWORD 24 DISCARD_SPECIFICATION
  if (pick_report_use(24) == "Y" && nobs_disc > 0)
  {
    SS2out << endl
           << pick_report_name(24) << endl;
    SS2out << "Discard_units_options" << endl;
    SS2out << "1:  discard_in_biomass(mt)_or_numbers(1000s)_to_match_catchunits_of_fleet" << endl;
    SS2out << "2:  discard_as_fraction_of_total_catch(based_on_bio_or_num_depending_on_fleet_catchunits)" << endl;
    SS2out << "3:  discard_as_numbers(1000s)_regardless_of_fleet_catchunits" << endl;
    SS2out << "Discard_errtype_options" << endl;
    SS2out << ">1:  log(L)_based_on_T-distribution_with_specified_DF" << endl;
    SS2out << "0:  log(L)_based_on_normal_with_Std_in_as_CV" << endl;
    SS2out << "-1:  log(L)_based_on_normal_with_Std_in_as_stddev" << endl;
    SS2out << "-2:  log(L)_based_on_lognormal_with_Std_in_as_stddev_in_logspace" << endl;
    SS2out << "-3:  log(L)_based_on_trunc_normal_with_Std_in_as_CV" << endl;

    SS2out << "#_Fleet units errtype" << endl;
    if (Ndisc_fleets > 0)
    {
      for (int ff = 1; ff <= N_catchfleets(0); ff++)
      {
        f = fish_fleet_area(0, ff);
        if (disc_units(f) > 0)
          SS2out << f << " " << disc_units(f) << " " << disc_errtype(f) << " # " << fleetname(f) << endl;
      }
    }
    for (int ff = 1; ff <= N_pred; ff++)
    {
      f = predator(ff);
      SS2out << f << " " << disc_units(f) << " " << disc_errtype(f) << " # " << fleetname(f) << " is_M2_fleet" << endl;
    }

    // REPORT_KEYWORD 25 DISCARD_OUTPUT  Discard observations by year
    SS2out << endl
           << pick_report_name(25) << endl;
    SS2out << "Fleet Fleet_Name Area Yr Seas Subseas Month Time Obs Exp Std_in Std_use Dev Like Like+log(s) SuprPer Use Obs_cat Exp_cat catch_mult exp_cat*catch_mult F_rate" << endl;
    data_type = 2;
    if (nobs_disc > 0)
      for (f = 1; f <= Nfleet; f++)
        if (fleet_type(f) <= 2 || fleet_type(f) == 4)
        {
          for (i = 1; i <= disc_N_fleet(f); i++)
          {
            t = disc_time_t(f, i);
            y = Show_Time(t, 1);
            ALK_time = disc_time_ALK(f, i);
            if (catchunits(f) == 1)
            {
              gg = 3;
            } //  biomass
            else
            {
              gg = 6;
            } //  numbers
            SS2out << f << " " << fleetname(f) << " " << fleet_area(f) << " " << Show_Time2(ALK_time) << " " << data_time(ALK_time, f, 1) << " " << data_time(ALK_time, f, 3)
                   << " " << obs_disc(f, i) << " " << exp_disc(f, i) << " "
                   << " " << cv_disc(f, i) << " " << sd_disc(f, i);

            if (yr_disc_use(f, i) >= 0.0)
            {
              if (disc_errtype(f) >= 1) // T -distribution
              {
                temp = 0.5 * (disc_errtype(f) + 1.) * log((1. + square(obs_disc(f, i) - exp_disc(f, i)) / (disc_errtype(f) * square(sd_disc(f, i)))));
                SS2out << " " << obs_disc(f, i) - exp_disc(f, i) << " " << temp << " " << temp + sd_offset * log(sd_disc(f, i));
              }
              else if (disc_errtype(f) == 0) // normal error, with input CV
              {
                temp = 0.5 * square((obs_disc(f, i) - exp_disc(f, i)) / sd_disc(f, i));
                SS2out << " " << obs_disc(f, i) - exp_disc(f, i) << " " << temp << " " << temp + sd_offset * log(sd_disc(f, i));
              }
              else if (disc_errtype(f) == -1) // normal error with input se
              {
                temp = 0.5 * square((obs_disc(f, i) - exp_disc(f, i)) / sd_disc(f, i));
                SS2out << " " << obs_disc(f, i) - exp_disc(f, i) << " " << temp << " " << temp + sd_offset * log(sd_disc(f, i));
              }
              else if (disc_errtype(f) == -2) // lognormal  where input cv_disc must contain se in log space
              {
                temp = 0.5 * square(log(obs_disc(f, i) / exp_disc(f, i)) / sd_disc(f, i));
                SS2out << " " << log(obs_disc(f, i) / exp_disc(f, i)) << " " << temp << " " << temp + sd_offset * log(sd_disc(f, i));
              }
              else if (disc_errtype(f) == -3) // trunc normal error, with input CV
              {
                temp = 0.5 * square((obs_disc(f, i) - exp_disc(f, i)) / sd_disc(f, i)) - log(cumd_norm((1 - exp_disc(f, i)) / sd_disc(f, i)) - cumd_norm((0 - exp_disc(f, i)) / sd_disc(f, i)));
                SS2out << " " << obs_disc(f, i) - exp_disc(f, i) << " " << temp << " " << temp + sd_offset * log(sd_disc(f, i));
              }
            }
            else
            {
              SS2out << "  _  _  _  ";
            }
            if (yr_disc_super(f, i) < 0 && in_superperiod == 0)
            {
              in_superperiod = 1;
              SS2out << " beg_SuprPer ";
            }
            else if (yr_disc_super(f, i) < 0 && in_superperiod == 1)
            {
              in_superperiod = 0;
              SS2out << " end_SuprPer ";
            }
            else if (in_superperiod == 1)
            {
              SS2out << " in_SuprPer ";
            }
            else
            {
              SS2out << " _ ";
            }
            SS2out << yr_disc_use(f, i);
            SS2out << " " << catch_ret_obs(f, t) << " " << catch_fleet(t, f, gg) << " " << catch_mult(y, f) << " " << catch_mult(y, f) * catch_fleet(t, f, gg) << " " << Hrate(f, t);
            SS2out << endl;
          }
        }
  }

  // REPORT_KEYWORD 26 MEAN_BODY_WT_OUTPUT
  if (pick_report_use(26) == "Y" && nobs_mnwt > 0)
  {
    SS2out << endl
           << pick_report_name(26) << endl;
    SS2out << "log(L)_based_on_T_distribution_with_DF=_" << DF_bodywt << endl;
    SS2out << "Fleet Fleet_Name Area Yr  Seas Subseas Month Time Part Type Obs Exp CV Dev NeglogL Neg(logL+log(s)) Use" << endl;
    //  10 items are:  1yr, 2seas, 3fleet, 4part, 5type, 6obs, 7se, then three intermediate variance quantities
    for (i = 1; i <= nobs_mnwt; i++)
    {
      t = mnwtdata(1, i);
      f = abs(mnwtdata(3, i));
      ALK_time = mnwtdata(11, i);
      SS2out << mnwtdata(3, i) << " " << fleetname(f) << " " << fleet_area(f) << " " << Show_Time2(ALK_time) << " " << data_time(ALK_time, f, 1) << " " << data_time(ALK_time, f, 3) << " "
             << mnwtdata(4, i) << " " << mnwtdata(5, i) << " " << mnwtdata(6, i) << " " << exp_mnwt(i) << " " << mnwtdata(7, i);
      if (mnwtdata(3, i) > 0.)
      {
        SS2out << " " << mnwtdata(6, i) - exp_mnwt(i) << " " << 0.5 * (DF_bodywt + 1.) * log(1. + square(mnwtdata(6, i) - exp_mnwt(i)) / mnwtdata(9, i)) << " " << 0.5 * (DF_bodywt + 1.) * log(1. + square(mnwtdata(6, i) - exp_mnwt(i)) / mnwtdata(9, i)) + mnwtdata(10, i) << " " << 1;
      }
      else
      {
        SS2out << " NA NA NA -1";
      }
      SS2out << endl;
    }
  }

  dvar_vector more_comp_info(1, 20);
  dvariable cumdist;
  dvariable cumdist_save;
  double Nsamp_DM; // equals Nsamp_adj when not using Dirichlet-Multinomial or Tweedie likelihood
  double Nsamp_adj; // input sample size after input variance adjustment
  double Nsamp_in; // input sample size
  dvector minsamp(1, Nfleet);
  dvector maxsamp(1, Nfleet);

  // REPORT_KEYWORD 27 FIT_LEN_COMPS
  if (pick_report_use(27) == "Y" && Nobs_l_tot > 0)
  {
    SS2out << endl
           << pick_report_name(27) << endl;
    SS2out << "Fleet Fleet_Name Area Yr Seas Subseas Month Time Sexes Part SuprPer Use Nsamp_in Nsamp_adj Nsamp_DM effN Like Method DM_parm MV_T_parm ";
    SS2out << " All_obs_mean All_exp_mean All_delta All_exp_5% All_exp_95% All_DurWat";
    if (gender == 2)
      SS2out << " F_obs_mean F_exp_mean F_delta F_exp_5% F_exp_95% F_DurWat M_obs_mean M_exp_mean M_delta M_exp_5% M_exp_95% M_DurWat %F_obs %F_exp ";
    SS2out << endl;
    rmse = 0.0;
    n_rmse = 0.0;
    mean_Nsamp_in = 0.0;
    mean_Nsamp_adj = 0.0;
    mean_Nsamp_DM = 0.0;
    Hrmse = 0.0;
    Rrmse = 0.0;
    neff_l.initialize();
    in_superperiod = 0;
    data_type = 4;
    minsamp = 10000.;
    maxsamp = 0.;
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

    for (f = 1; f <= Nfleet; f++)
      for (i = 1; i <= Nobs_l(f); i++)
      {
        t = Len_time_t(f, i);
        ALK_time = Len_time_ALK(f, i);
        more_comp_info.initialize();
        neff_l(f, i) = exp_l(f, i) * (1 - exp_l(f, i)) + 1.0e-06; // constant added for stability
        neff_l(f, i) /= (obs_l(f, i) - exp_l(f, i)) * (obs_l(f, i) - exp_l(f, i)) + 1.0e-06;
        // store sample sizes
        Nsamp_in = nsamp_l_read(f, i);
        Nsamp_adj = nsamp_l(f, i);
        dvector tempvec_l(1, exp_l(f, i).size());
        tempvec_l = value(exp_l(f, i));
        more_comp_info = process_comps(gender, gen_l(f, i), len_bins_dat2, len_bins_dat_m2, tails_l(f, i), obs_l(f, i), tempvec_l);
        Nsamp_DM = Nsamp_adj; // Will remain this if not used
        int parti = mkt_l(f, i);
        dirichlet_Parm = 0.0;  //  default gets reported if using multinomial
        double Tweedie_Parm = 0.0; //  default gets reported if not using MV Tweedie
        if (Comp_Err_L(parti, f) == 1) //  Dirichlet #1
        {
          dirichlet_Parm = mfexp(selparm(Comp_Err_parmloc(Comp_Err_L2(parti, f),1))); //  Thorson's theta from eq 10
          // effN_DM = 1/(1+theta) + n*theta/(1+theta)
          Nsamp_DM = value(1. / (1. + dirichlet_Parm) + nsamp_l(f, i) * dirichlet_Parm / (1. + dirichlet_Parm));
        }
        else if (Comp_Err_L(parti, f) == 2) //  Dirichlet #2
        {
          dirichlet_Parm = mfexp(selparm(Comp_Err_parmloc(Comp_Err_L2(parti, f),1))); //  Thorson's beta from eq 12
          // effN_DM = (n+n*beta)/(n+beta)
          Nsamp_DM = value((nsamp_l(f, i) + dirichlet_Parm * nsamp_l(f, i)) / (dirichlet_Parm + nsamp_l(f, i)));
        }
        else if (Comp_Err_L(parti, f) == 3) //  MV  Tweedie
        {
          // TBD
        }

        if (header_l(f, i, 3) > 0)
        {
          n_rmse(f) += 1.;
          rmse(f) += value(neff_l(f, i));
          mean_Nsamp_in(f) += Nsamp_in;
          mean_Nsamp_adj(f) += Nsamp_adj;
          mean_Nsamp_DM(f) += Nsamp_DM;
          Hrmse(f) += value(1. / neff_l(f, i));
          Rrmse(f) += value(neff_l(f, i) / Nsamp_adj);
          if (Nsamp_adj < minsamp(f))
            minsamp(f) = Nsamp_adj;
          if (Nsamp_adj > maxsamp(f))
            maxsamp(f) = Nsamp_adj;
        }

        //  SS2out<<"Fleet Fleet_Name Area Yr Month Seas Subseas Time Sexes Part SuprPer Use Nsamp_adj Nsamp_in Nsamp_DM effN Like";
        //      temp=abs(header_l_rd(f,i,2));
        //      if(temp>999) temp-=1000;
        SS2out << f << " " << fleetname(f) << " " << fleet_area(f) << " " << Show_Time2(ALK_time) << " " << data_time(ALK_time, f, 1) << " " << data_time(ALK_time, f, 3) << " " << gen_l(f, i) << " " << mkt_l(f, i);
        if (header_l(f, i, 2) < 0 && in_superperiod == 0)
        {
          SS2out << " start ";
          in_superperiod = 1;
        }
        else if (header_l(f, i, 2) < 0 && in_superperiod == 1)
        {
          SS2out << " end ";
          in_superperiod = 0;
        }
        else if (in_superperiod == 1)
        {
          SS2out << " in ";
        }
        else
        {
          SS2out << " _ ";
        }
        if (header_l(f, i, 3) < 0)
        {
          SS2out << " skip ";
        }
        else
        {
          SS2out << " _ ";
        }
        SS2out << Nsamp_in << " " << Nsamp_adj << " " << Nsamp_DM << " " << neff_l(f, i) << " " << length_like(f, i) << " ";
        SS2out << Comp_Err_L(parti, f) << " " << dirichlet_Parm << " " << Tweedie_Parm << " ";
        SS2out << more_comp_info(1, 6);
        if (gender == 2)
          SS2out << " " << more_comp_info(7, 20);
        SS2out << endl;
      } // end loops over observation i and fleet f

    //Fleet N Npos mean_effN mean(inputN*Adj) HarMean(effN) Mean(effN/inputN) MeaneffN/MeaninputN Var_Adj
    //long ago, Ian Stewart had the proto-r4ss add a column called "HarEffN/MeanInputN" which was the ratio of the columns "HarMean(effN)" column and the "mean(inputN*Adj)" and has been used as the multiplier on the adjustment factor in the status-quo NWFSC tuning approach.
    //My suggestion would be to remove the columns "Mean(effN/inputN)" and "MeaneffN/MeaninputN" if those are not recommended values for tuning (I don't get the impression that they are) and have SS3 internally produce the "HarEffN/MeanInputN" column so that it's available to all users.
    //It might also be good to add a keyword to the top of those lower tables which could simplify the logic of parsing them separately from the FIT_..._COMPS tables above them and therefore be more robust to changes in format.

    SS2out << "#" << endl
           << "Length_Comp_Fit_Summary" << endl
           << "Data_type Fleet Recommend_var_adj # N Npos min_Nsamp max_Nsamp mean_Nsamp_in mean_Nsamp_adj mean_Nsamp_DM err_method err_index par1 val1 par2 val2 mean_effN HarMean_effN Curr_Var_Adj Fleet_name" << endl;
    for (f = 1; f <= Nfleet; f++)
    {
      if (n_rmse(f) > 0)
      {
        // calculate summary statistics
        rmse(f) /= n_rmse(f);
        Hrmse(f) = n_rmse(f) / Hrmse(f);
        Rrmse(f) /= n_rmse(f);
        mean_Nsamp_in(f) /= n_rmse(f);
        mean_Nsamp_adj(f) /= n_rmse(f);
        mean_Nsamp_DM(f) /= n_rmse(f);
        // write values to file
        SS2out << "4 " << f << " ";
        if (Comp_Err_L(0, f) == 0)
        { // standard multinomial
          SS2out << Hrmse(f) / mean_Nsamp_adj(f) * var_adjust(4, f);
        }
        else
        { // Dirichlet-multinomial (Recommend_var_adj = 1)
          SS2out << "1";
        }
        SS2out << " # " << Nobs_l(f) << " " << n_rmse(f) << " " << minsamp(f) << " " << maxsamp(f) << " " << mean_Nsamp_in(f) << " " << mean_Nsamp_adj(f);

        switch (Comp_Err_L(0, f))
        {
          case 0:
          { // standard multinomial
            // placeholders for mean_Nsamp_DM and DM_theta (not used)
            SS2out << " NA 0 NA multinomial NA NA NA ";
            break;
          }
          case 1:   // Dirichlet-multinomial
          {
          }
          case 2:   // Dirichlet-multinomial
          {
            // mean_Nsamp_DM and DM_theta
            SS2out << " " << mean_Nsamp_DM(f) << " " << Comp_Err_L(0, f) << " " << Comp_Err_L2(0, f) << " " << ParmLabel(Comp_Err_parmloc(Comp_Err_L2(0, f),2)) << " " << mfexp(selparm(Comp_Err_parmloc(Comp_Err_L2(0, f),1))) << " NA "<< " NA ";
            break;
          }
          case 3:  //  MV Tweedie
          {
            SS2out << " NA 3 NA NA NA NA NA ";
            break;
          }
        }
        SS2out << rmse(f) << " " << Hrmse(f) << " " << var_adjust(4, f) << " " << fleetname(f) << endl;
      }
    }
  }

  // REPORT_KEYWORD 28 FIT_AGE_COMPS
  if (pick_report_use(28) == "Y" && Nobs_a_tot > 0)
  {
    SS2out << endl
           << pick_report_name(28) << endl;
    SS2out << "Fleet Fleet_Name Area Yr Seas Subseas Month Time Sexes Part Ageerr Lbin_lo Lbin_hi SuprPer Use Nsamp_in Nsamp_adj Nsamp_DM effN Like ";
    SS2out << " All_obs_mean All_exp_mean All_delta All_exp_5% All_exp_95% All_DurWat";
    if (gender == 2)
      SS2out << " F_obs_mean F_exp_mean F_delta F_exp_5% F_exp_95% F_DurWat M_obs_mean M_exp_mean M_delta M_exp_5% M_exp_95% M_DurWat %F_obs %F_exp ";
    SS2out << endl;
    rmse = 0.0;
    n_rmse = 0.0;
    mean_Nsamp_in = 0.0;
    mean_Nsamp_adj = 0.0;
    mean_Nsamp_DM = 0.0;
    Hrmse = 0.0;
    Rrmse = 0.0;
    minsamp = 10000.;
    maxsamp = 0.;
    for (f = 1; f <= Nfleet; f++)
      for (i = 1; i <= Nobs_a(f); i++)
      {
        t = Age_time_t(f, i);
        ALK_time = Age_time_ALK(f, i);
        more_comp_info.initialize();
        neff_a(f, i) = exp_a(f, i) * (1 - exp_a(f, i)) + 1.0e-06; // constant added for stability
        neff_a(f, i) /= (obs_a(f, i) - exp_a(f, i)) * (obs_a(f, i) - exp_a(f, i)) + 1.0e-06;
        // store sample sizes
        Nsamp_in = nsamp_a_read(f, i);
        Nsamp_adj = nsamp_a(f, i);
        dvector tempvec_a(1, exp_a(f, i).size());
        tempvec_a = value(exp_a(f, i));
        more_comp_info = process_comps(gender, gen_a(f, i), age_bins, age_bins_mean, tails_a(f, i), obs_a(f, i), tempvec_a);

        Nsamp_DM = Nsamp_adj; // Will stay at this val for multinomial
        if (Comp_Err_A(f) == 1) //  Dirichlet #1
        {
          dirichlet_Parm =mfexp(selparm(Comp_Err_parmloc(Comp_Err_A2(f),1))); //  Thorson's theta from eq 10
          // effN_DM = 1/(1+theta) + n*theta/(1+theta)
          Nsamp_DM = value(1. / (1. + dirichlet_Parm) + nsamp_a(f, i) * dirichlet_Parm / (1. + dirichlet_Parm));
        }
        else if (Comp_Err_A(f) == 2) //  Dirichlet #2
        {
          dirichlet_Parm = mfexp(selparm(Comp_Err_parmloc(Comp_Err_A2(f),1))); //  Thorson's beta from eq 12
          // effN_DM = (n+n*beta)/(n+beta)
          Nsamp_DM = value((nsamp_a(f, i) + dirichlet_Parm * nsamp_a(f, i)) / (dirichlet_Parm + nsamp_a(f, i)));
        }

        if (header_a(f, i, 3) > 0)
        {
          n_rmse(f) += 1.;
          rmse(f) += value(neff_a(f, i));
          mean_Nsamp_in(f) += Nsamp_in;
          mean_Nsamp_adj(f) += Nsamp_adj;
          mean_Nsamp_DM(f) += Nsamp_DM;
          Hrmse(f) += value(1. / neff_a(f, i));
          Rrmse(f) += value(neff_a(f, i) / Nsamp_adj);
          if (Nsamp_adj < minsamp(f))
            minsamp(f) = Nsamp_adj;
          if (Nsamp_adj > maxsamp(f))
            maxsamp(f) = Nsamp_adj;
        }

        //  SS2out<<"Fleet Fleet_Name Area Yr  Seas Subseas Month Time Sexes Part Ageerr Lbin_lo Lbin_hi Nsamp_in Nsamp_adj Nsamp_DM effN Like SuprPer Use";
        temp = abs(header_a_rd(f, i, 2));
        if (temp > 999)
          temp -= 1000;
        SS2out << f << " " << fleetname(f) << " " << fleet_area(f) << Show_Time2(ALK_time) << " " << data_time(ALK_time, f, 1) << " " << data_time(ALK_time, f, 3) << " " << gen_a(f, i) << " " << mkt_a(f, i) << " " << ageerr_type_a(f, i) << " " << len_bins(Lbin_lo(f, i)) << " " << len_bins(Lbin_hi(f, i)) << " ";
        if (header_a(f, i, 2) < 0 && in_superperiod == 0)
        {
          SS2out << " start ";
          in_superperiod = 1;
        }
        else if (header_a(f, i, 2) < 0 && in_superperiod == 1)
        {
          SS2out << " end ";
          in_superperiod = 0;
        }
        else if (in_superperiod == 1)
        {
          SS2out << " in ";
        }
        else
        {
          SS2out << " _ ";
        }
        if (header_a(f, i, 3) < 0 || nsamp_a(f, i) < 0)
        {
          SS2out << " skip ";
        }
        else
        {
          SS2out << " _ ";
        }
        SS2out << Nsamp_in << " " << Nsamp_adj << " " << Nsamp_DM << " "
               << " " << neff_a(f, i) << " " << age_like(f, i) << " " << more_comp_info(1, 6);
        if (gender == 2)
          SS2out << " " << more_comp_info(7, 20);
        SS2out << endl;
      }

    SS2out << "#" << endl
           << "Age_Comp_Fit_Summary" << endl
           << "Data_type Fleet Recommend_var_adj # N Npos min_Nsamp max_Nsamp mean_Nsamp_in mean_Nsamp_adj mean_Nsamp_DM err_method err_index par1 val1 par2 val2 mean_effN HarMean_effN Curr_Var_Adj Fleet_name" << endl;
    for (f = 1; f <= Nfleet; f++)
    {
      if (n_rmse(f) > 0)
      {
        // calculate summary statistics
        rmse(f) /= n_rmse(f);
        Hrmse(f) = n_rmse(f) / Hrmse(f);
        Rrmse(f) /= n_rmse(f);
        mean_Nsamp_in(f) /= n_rmse(f);
        mean_Nsamp_adj(f) /= n_rmse(f);
        mean_Nsamp_DM(f) /= n_rmse(f);
        // write values to file
        SS2out << "5 " << f << " ";
        if (Comp_Err_A(f) == 0)
        { // standard multinomial
          SS2out << Hrmse(f) / mean_Nsamp_adj(f) * var_adjust(5, f);
        }
        else
        { // Dirichlet-multinomial (Recommend_var_adj = 1)
          SS2out << "1";
        }
        SS2out << " # " << Nobs_a(f) << " " << n_rmse(f) << " " << minsamp(f) << " " << maxsamp(f) << " " << mean_Nsamp_in(f) << " " << mean_Nsamp_adj(f);
        switch (Comp_Err_A(f))
        {
          case 0:
          { // standard multinomial
            // placeholders for mean_Nsamp_DM and DM_theta (not used)
            SS2out << " NA 0 NA multinomial NA NA NA ";
            break;
          }
          case 1:   // Dirichlet-multinomial
          {
          }
          case 2:   // Dirichlet-multinomial
          {
            // mean_Nsamp_DM and DM_theta
            SS2out << "  " << mean_Nsamp_DM(f) << " " << Comp_Err_A(f) << " " << Comp_Err_A2(f) << " " << ParmLabel(Comp_Err_parmloc(Comp_Err_A2(f),2)) << " " << mfexp(selparm(Comp_Err_parmloc(Comp_Err_A2(f),1))) << " NA "<< " NA ";
            break;
          }
          case 3:  //  MV Tweedie
          {
            SS2out << " NA 3 NA NA NA NA NA ";
            break;
          }
        }
        SS2out << rmse(f) << " " << Hrmse(f) << " " << var_adjust(5, f) << " " << fleetname(f) << endl;
      }
    }
  }

  // REPORT_KEYWORD 29 FIT_SIZE_COMPS
  if (pick_report_use(29) == "Y" && SzFreq_Nmeth > 0)
  {
    SS2out << endl
           << pick_report_name(29) << endl;

    SzFreq_effN.initialize();
    for (int sz_method = 1; sz_method <= SzFreq_Nmeth; sz_method++)
    {
      SS2out << "#Method: " << sz_method;
      SS2out << "  #Units: " << SzFreq_units_label(SzFreq_units(sz_method));
      SS2out << "  #Scale: " << SzFreq_scale_label(SzFreq_scale(sz_method));
      SS2out << "  #Add_to_comp: " << SzFreq_mincomp(sz_method) << "  #N_bins: " << SzFreq_Nbins(sz_method) << endl;
      SS2out << "Fleet Fleet_Name Area Yr Seas Subseas Month Time Sexes Part SuprPer Use Nsamp_in Nsamp_adj Nsamp_DM effN Like";
      SS2out << " All_obs_mean All_exp_mean All_delta All_exp_5% All_exp_95% All_DurWat";
      if (gender == 2)
        SS2out << " F_obs_mean F_exp_mean F_delta F_exp_5% F_exp_95% F_DurWat M_obs_mean M_exp_mean M_delta M_exp_5% M_exp_95% M_DurWat %F_obs %F_exp ";
      SS2out << endl;
      rmse = 0.0;
      n_rmse = 0.0;
      mean_Nsamp_in = 0.0;
      mean_Nsamp_adj = 0.0;
      mean_Nsamp_DM = 0.0;
      Hrmse = 0.0;
      Rrmse = 0.0;

      dvector sz_tails(1, 4);
      sz_tails(1) = 1;
      sz_tails(2) = SzFreq_Nbins(sz_method);
      sz_tails(3) = SzFreq_Nbins(sz_method) + 1;
      sz_tails(4) = 2 * SzFreq_Nbins(sz_method);
      for (f = 1; f <= Nfleet; f++)
      {
        in_superperiod = 0;
        for (iobs = 1; iobs <= SzFreq_totobs; iobs++)
        {
          more_comp_info.initialize();
          k = SzFreq_obs_hdr(iobs, 6);
          if (k == sz_method && abs(SzFreq_obs_hdr(iobs, 3)) == f)
          {
            if (SzFreq_obs_hdr(iobs, 1) >= styr) // year is positive, so use this obs
            {
              y = SzFreq_obs_hdr(iobs, 1);
              t = SzFreq_time_t(iobs);
              ALK_time = SzFreq_time_ALK(iobs);
              gg = SzFreq_obs_hdr(iobs, 4); // gender
              if (gender == 2 && (gg == 3 || gg == 2))
              {
                sz_tails(3) = SzFreq_Nbins(sz_method) + 1;
                sz_tails(4) = 2 * SzFreq_Nbins(sz_method);
              }
              else
              {
                sz_tails(3) = 1;
                sz_tails(4) = SzFreq_Nbins(sz_method);
              }
              p = SzFreq_obs_hdr(iobs, 5); // partition
              z1 = SzFreq_obs_hdr(iobs, 7);
              z2 = SzFreq_obs_hdr(iobs, 8);
              temp = 0.0;
              temp1 = 0.0;
              for (z = z1; z <= z2; z++)
              {
                SzFreq_effN(iobs) += value(SzFreq_exp(iobs, z) * (1.0 - SzFreq_exp(iobs, z)));
                temp += square(SzFreq_obs(iobs, z) - SzFreq_exp(iobs, z));
                temp1 += SzFreq_obs(iobs, z) * log(SzFreq_obs(iobs, z)) - SzFreq_obs(iobs, z) * log(SzFreq_exp(iobs, z));
              }
              SzFreq_effN(iobs) = (SzFreq_effN(iobs) + 1.0e-06) / value((temp + 1.0e-06));
              temp1 *= SzFreq_sampleN(iobs);
              dvector tempvec_l(1, SzFreq_exp(iobs).size());
              tempvec_l = value(SzFreq_exp(iobs));
              more_comp_info = process_comps(gender, gg, SzFreq_bins(sz_method), SzFreq_means(sz_method), sz_tails, SzFreq_obs(iobs), tempvec_l);
              Nsamp_DM = SzFreq_sampleN(iobs); // Will remain this if not used; there is no "adjusted" sample size for sizwfreq
              if (Comp_Err_Sz(sz_method) == 1) //  Dirichlet #1
              {
                dirichlet_Parm = mfexp(selparm(Comp_Err_parmloc(Comp_Err_Sz2(sz_method),1))); //  Thorson's theta from eq 10
                // effN_DM = 1/(1+theta) + n*theta/(1+theta)
                Nsamp_DM = value(1. / (1. + dirichlet_Parm) + SzFreq_sampleN(iobs) * dirichlet_Parm / (1. + dirichlet_Parm));
              }
              else if (Comp_Err_Sz(sz_method) == 2) //  Dirichlet #2
              {
                dirichlet_Parm = mfexp(selparm(Comp_Err_parmloc(Comp_Err_Sz2(sz_method),1))); //  Thorson's beta from eq 12
                // effN_DM = (n+n*beta)/(n+beta)
                Nsamp_DM = value((SzFreq_sampleN(iobs) + dirichlet_Parm * SzFreq_sampleN(iobs)) / (dirichlet_Parm + SzFreq_sampleN(iobs)));
              }
              if (SzFreq_obs_hdr(iobs, 3) > 0)  //  dheck for -fleet that is an ignored obs
              {
                n_rmse(f) += 1.;
                rmse(f) += SzFreq_effN(iobs);
                mean_Nsamp_in(f) += SzFreq_sampleN(iobs);
                mean_Nsamp_adj(f) += SzFreq_sampleN(iobs);
                if (SzFreq_sampleN(iobs) < minsamp(f))
                  minsamp(f) = SzFreq_sampleN(iobs);
                if (SzFreq_sampleN(iobs) > maxsamp(f))
                  maxsamp(f) = SzFreq_sampleN(iobs);
                Hrmse(f) += 1. / SzFreq_effN(iobs);
                Rrmse(f) += SzFreq_effN(iobs) / SzFreq_sampleN(iobs);
                mean_Nsamp_DM(f) += Nsamp_DM;
              }
              else
              {
                SzFreq_effN(iobs) = 0.;
              }
              temp = SzFreq_obs1(iobs, 3); //  use original input value because
              if (temp > 999)
                temp -= 1000.;
              SS2out << f << " " << fleetname(f) << " " << fleet_area(f) << " " << Show_Time2(ALK_time) << " " << data_time(ALK_time, f, 1) << " " << data_time(ALK_time, f, 3) << " " << gg << " " << p;
              if (SzFreq_obs_hdr(iobs, 2) < 0 && in_superperiod == 0)
              {
                SS2out << " start ";
                in_superperiod = 1;
              }
              else if (SzFreq_obs_hdr(iobs, 2) < 0 && in_superperiod == 1)
              {
                SS2out << " end ";
                in_superperiod = 0;
              }
              else if (in_superperiod == 1)
              {
                SS2out << " in ";
              }
              else
              {
                SS2out << " _ ";
              }
              if (SzFreq_obs_hdr(iobs, 3) < 0)
              {
                SS2out << " skip ";
              }
              else
              {
                SS2out << " _ ";
              }
              SS2out << " " << SzFreq_sampleN(iobs) << "  " << SzFreq_sampleN(iobs) << "  " << Nsamp_DM << " " << SzFreq_effN(iobs) << "  " << SzFreq_eachlike(iobs) << " " << more_comp_info(1, 6);
              if (gender == 2)
                SS2out << " " << more_comp_info(7, 20);
              SS2out << endl;
            } //  end finding observation that is being used
          } //  end observation matching selected method
        } //  end loop of observations
      } //  end fleet loop
      //      SS2out<<"Fleet N Npos mean_effN mean(inputN*Adj) HarMean(effN) Mean(effN/inputN) MeaneffN/MeaninputN Var_Adj"<<endl;
    SS2out << "#" << endl
           << "Size_Comp_Fit_Summary" << endl
           << "Data_type Fleet Recommend_var_adj # N Npos min_Nsamp max_Nsamp mean_Nsamp_in mean_Nsamp_adj mean_Nsamp_DM err_method err_index par1 val1 par2 val2 mean_effN HarMean_effN Curr_Var_Adj Fleet_name" << endl;
    for (f = 1; f <= Nfleet; f++)
    {
      if (n_rmse(f) > 0)
      {
        // calculate summary statistics
        rmse(f) /= n_rmse(f);
        Hrmse(f) = n_rmse(f) / Hrmse(f);
        Rrmse(f) /= n_rmse(f);
        mean_Nsamp_in(f) /= n_rmse(f);
        mean_Nsamp_adj(f) /= n_rmse(f);
        mean_Nsamp_DM(f) /= n_rmse(f);
        // write values to file
        SS2out << "6 " << f << " ";
        if (Comp_Err_Sz(sz_method) == 0)
        { // standard multinomial
          SS2out << Hrmse(f) / mean_Nsamp_adj(f) * var_adjust(6, f);
        }
        else
        { // Dirichlet-multinomial (Recommend_var_adj = 1)
          SS2out << "1";
        }
        SS2out << " # " << n_rmse(f) << " " << n_rmse(f) << " " << minsamp(f) << " " << maxsamp(f) << " " << mean_Nsamp_in(f) << " " << mean_Nsamp_adj(f);

        switch (Comp_Err_Sz(sz_method))
        {
          case 0:
          { // standard multinomial
            // placeholders for mean_Nsamp_DM and DM_theta (not used)
            SS2out << " NA 0 NA multinomial NA NA NA ";
            break;
          }
          case 1:   // Dirichlet-multinomial
          {
          }
          case 2:   // Dirichlet-multinomial
          {
            // mean_Nsamp_DM and DM_theta
            SS2out << " " << mean_Nsamp_DM(f) << " " << Comp_Err_Sz(sz_method) << " " << Comp_Err_Sz2(sz_method) << " " << ParmLabel(Comp_Err_parmloc(Comp_Err_Sz2(sz_method),2)) << " " << mfexp(selparm(Comp_Err_parmloc(Comp_Err_Sz2(sz_method),1))) << " NA "<< " NA ";
            break;
          }
          case 3:  //  MV Tweedie
          {
            SS2out << " NA 3 NA NA NA NA NA ";
            break;
          }
        }
        SS2out << rmse(f) << " " << Hrmse(f) << " " << var_adjust(4, f) << " " << fleetname(f) << endl;
      }
    }
    } //  end loop of methods
  } // end have sizecomp

  // REPORT_KEYWORD 30 OVERALL_COMPS  average composition for all observations
  if (pick_report_use(30) == "Y")
  {
    SS2out << endl
           << pick_report_name(30) << endl;
    SS2out << "area seas Fleet N_obs len_bins " << len_bins_dat << endl;

    for (f = 1; f <= Nfleet; f++)
    {
      for (k = 1; k <= 4; k++)
      {
        dvector templen(1, nlen_bin);
        templen.initialize();
        for (s = 1; s <= nseas; s++)
        {
          templen += obs_l_all(k, s, f);
        }
        obs_l_all(k, 0, f) = templen / (float(nseas));
      }
    }
    int kseas = 1;
    if (nseas > 1)
      kseas = 0;
    for (f = 1; f <= Nfleet; f++)
      for (s = kseas; s <= nseas; s++)
      {
        if (Nobs_l(f) > 0)
        {
          SS2out << fleet_area(f) << " " << s << " " << f << " " << Nobs_l(f) << " freq " << obs_l_all(1, s, f) << endl;
          SS2out << fleet_area(f) << " " << s << " " << f << " " << Nobs_l(f) << " cum  " << obs_l_all(2, s, f) << endl;
          if (gender == 2)
          {
            SS2out << fleet_area(f) << " " << s << " " << f << " " << Nobs_l(f) << " female  " << obs_l_all(2, s, f) << endl;
            SS2out << fleet_area(f) << " " << s << " " << f << " " << Nobs_l(f) << " male  " << obs_l_all(2, s, f) << endl;
          }
        }
      }

    SS2out << "area seas Fleet N_obs age_bins ";
    if (n_abins > 1)
    {
      SS2out << age_bins(1, n_abins) << endl;
      for (f = 1; f <= Nfleet; f++)
        for (s = kseas; s <= nseas; s++)
        {
          if (Nobs_a(f) > 0)
          {
            SS2out << fleet_area(f) << " " << s << " " << f << " " << Nobs_a(f) << " freq " << obs_a_all(1, s, f) << endl;
            SS2out << fleet_area(f) << " " << s << " " << f << " " << Nobs_a(f) << " cum  " << obs_a_all(2, s, f) << endl;
            if (gender == 2)
            {
              SS2out << fleet_area(f) << " " << s << " " << f << " " << Nobs_a(f) << " female  " << obs_a_all(2, s, f) << endl;
              SS2out << fleet_area(f) << " " << s << " " << f << " " << Nobs_a(f) << " male  " << obs_a_all(2, s, f) << endl;
            }
          }
        }
    }
    else
    {
      SS2out << "No_age_bins_defined" << endl;
    }
  }

  // REPORT_KEYWORD 31 LEN_SELEX
  if (pick_report_use(31) == "Y")
  {
    SS2out << endl
           << pick_report_name(31) << endl;
    SS2out << "Lsel_is_length_selectivity" << endl; // SS_Label_370
    SS2out << "RET_is_retention" << endl; // SS_Label_390
    SS2out << "MORT_is_discard_mortality" << endl; // SS_Label_390
    SS2out << "KEEP_is_sel*retain" << endl; // SS_Label_370
    SS2out << "DEAD_is_sel*(retain+(1-retain)*discmort)"; // SS_Label_370
    SS2out << "; Year_styr-3_(" << styr - 3 << ")_stores_average_used_for_benchmark" << endl;
    SS2out << "Factor Fleet Yr Sex Label " << len_bins_m << endl;
    for (f = 1; f <= Nfleet; f++)
    {
      k = styr - 3;
      j = YrMax;
      for (y = k; y <= j; y++)
        for (gg = 1; gg <= gender; gg++)
          if (y == styr - 3 || y == endyr || y == YrMax || (y >= styr && (timevary_sel(y, f) > 0 || timevary_sel(y + 1, f) > 0)))
          {
            SS2out << "Lsel " << f << " " << y << " " << gg << " " << y << "_" << f << "_Lsel";
            for (z = 1; z <= nlength; z++)
            {
              SS2out << " " << sel_l(y, f, gg, z);
            }
            SS2out << endl;
          }
    }

    for (f = 1; f <= Nfleet; f++)
      if (fleet_type(f) <= 2)
        for (y = styr - 3; y <= YrMax; y++)
          for (gg = 1; gg <= gender; gg++)
            if (y == styr - 3 || y == endyr || y == YrMax || (y >= styr && (timevary_sel(y, f) > 0 || timevary_sel(y + 1, f) > 0)))
            {
              //    if(y>=styr && y<=endyr)
              //    {
              SS2out << "Ret " << f << " " << y << " " << gg << " " << y << "_" << f << "_Ret";
              if (gg == 1)
              {
                for (z = 1; z <= nlength; z++)
                {
                  SS2out << " " << retain(y, f, z);
                }
              }
              else
              {
                for (z = nlength1; z <= nlength2; z++)
                {
                  SS2out << " " << retain(y, f, z);
                }
              }
              SS2out << endl;
              SS2out << "Mort " << f << " " << y << " " << gg << " " << y << "_" << f << "_Mort";
              if (gg == 1)
              {
                for (z = 1; z <= nlength; z++)
                {
                  SS2out << " " << discmort(y, f, z);
                }
              }
              else
              {
                for (z = nlength1; z <= nlength2; z++)
                {
                  SS2out << " " << discmort(y, f, z);
                }
              }
              SS2out << endl;
              //    }
              SS2out << "Keep " << f << " " << y << " " << gg << " " << y << "_" << f << "_Keep";
              for (z = 1; z <= nlength; z++)
              {
                SS2out << " " << sel_l_r(y, f, gg, z);
              }
              SS2out << endl;
              SS2out << "Dead " << f << " " << y << " " << gg << " " << y << "_" << f << "_Dead";
              for (z = 1; z <= nlength; z++)
              {
                SS2out << " " << discmort2(y, f, gg, z);
              }
              SS2out << endl;
            }
  }

  // REPORT_KEYWORD 32 AGE_SELEX
  if (pick_report_use(32) == "Y")
  {
    dmatrix selmax(1,Nfleet,1,3);  //  max selectivity for each fleet and year, season
    SS2out << endl
           << pick_report_name(32) << endl;
    SS2out << "Asel_is_age_selectivity_alone" << endl;
    SS2out << "Asel2_is_Asel*(selL*size_at_age(ALK)); Q and F parameters may appear higher than expected because Asel2 may have max < 1.0; " << endl;
    SS2out << "Aret_is_age_retention" << endl;
    SS2out << "COMBINED_ALK*selL*selA*wtlen*ret*discmort_in_makefishsel_yr: " << makefishsel_yr << " With_MeanSel_From: " << Fcast_Sel_yr1 << " - " << Fcast_Sel_yr2; // SS_Label_380
    SS2out << "; Year_styr-3_(" << styr - 3 << ")_stores_average_used_for_benchmark" << endl;

    SS2out << "Factor Fleet Yr Seas Sex Morph Label ";
    for (a = 0; a <= nages; a++)
    {
      SS2out << " " << a;
    }
    SS2out << endl;
    for (f = 1; f <= Nfleet; f++)
    {
      k = styr - 3;
      j = YrMax;
      for (y = k; y <= j; y++)
        for (gg = 1; gg <= gender; gg++)
          if (y == styr - 3 || y == endyr || y == YrMax || (y >= styr && (timevary_sel(y, f + Nfleet) > 0 || timevary_sel(y + 1, f + Nfleet) > 0)))
          {
            SS2out << "Asel " << f << " " << y << " 1 " << gg << " 1 " << y << "_" << f << "Asel " << sel_a(y, f, gg) << endl;
          }
    }
    for (f = 1; f <= Nfleet; f++)
    {
      if (seltype(f + Nfleet, 2) > 0) // using age retention
      {
        for (y = styr - 3; y <= YrMax; y++)
          for (gg = 1; gg <= gender; gg++)
            if (y == styr - 3 || y == endyr || y == YrMax || (y >= styr && (timevary_sel(y, f + Nfleet) > 0 || timevary_sel(y + 1, f + Nfleet) > 0)))
            {
              SS2out << "Aret " << f << " " << y << " 1 " << gg << " 1 " << y << "_" << f << "Aret " << retain_a(y, f, gg) << endl;
              SS2out << "Amort " << f << " " << y << " 1 " << gg << " 1 " << y << "_" << f << "Amort " << discmort_a(y, f, gg) << endl;
            }
      }
    }

    if (Do_Forecast > 0)
    {
      k = YrMax;
    }
    else
    {
      k = endyr;
    }

    selmax = 100.0;  //  set to big number

    for (y = styr - 3; y <= k; y++)
      for (s = 1; s <= nseas; s++)
      {
        t = styr + (y - styr) * nseas + s - 1;
        for (g = 1; g <= gmorph; g++)
          if (use_morph(g) > 0 && (y == styr - 3 || y >= styr))
          {
            if (s == spawn_seas && (sx(g) == 1 || Hermaphro_Option != 0))
              SS2out << "Fecund "
                     << " NA "
                     << " " << y << " " << s << " " << sx(g) << " " << g << " " << y << "_"
                     << "Fecund" << Wt_Age_t(t, -2, g) << endl;
            for (f = 1; f <= Nfleet; f++)
            {
              SS2out << "Asel2 " << f << " " << y << " " << s << " " << sx(g) << " " << g << " " << y << "_" << f << "_Asel2" << save_sel_num(t, f, g) << endl;
              temp = max(save_sel_num(t, f, g));
              if (temp < selmax(f, 3) && y >= styr) 
                {selmax(f, 3) = value(temp); 
                 selmax(f, 1) = float(y);
                 selmax(f, 2) = float(s);}  //  save y.s

              if (fleet_type(f) <= 2)
                SS2out << "F " << f << " " << y << " " << s << " " << sx(g) << " " << g << " " << y << "_" << f << "_F" << Hrate(f, t) * save_sel_num(t, f, g) << endl;
              SS2out << "bodywt " << f << " " << y << " " << s << " " << sx(g) << " " << g << " " << y << "_" << f << "_bodywt" << Wt_Age_t(t, f, g) << endl;
            }
          }
      }
    y = makefishsel_yr;
    for (f = 1; f <= Nfleet; f++)
      if (fleet_type(f) <= 2)
        for (g = 1; g <= gmorph; g++)
          if (use_morph(g) > 0)
            for (s = 1; s <= nseas; s++)
            {
              SS2out << "sel*wt " << f << " " << y << " " << s << " " << sx(g) << " " << g << " " << y << "_" << f << "_sel*wt" << sel_bio(s, f, g) << endl;
              SS2out << "sel*ret*wt " << f << " " << y << " " << s << " " << sx(g) << " " << g << " " << y << "_" << f << "_sel*ret*wt" << sel_ret_bio(s, f, g) << endl;
              SS2out << "sel_nums " << f << " " << y << " " << s << " " << sx(g) << " " << g << " " << y << "_" << f << "_sel_nums" << sel_num(s, f, g) << endl;
              SS2out << "sel*ret_nums " << f << " " << y << " " << s << " " << sx(g) << " " << g << " " << y << "_" << f << "_sel*ret_nums" << sel_ret_num(s, f, g) << endl;
              SS2out << "dead_nums " << f << " " << y << " " << s << " " << sx(g) << " " << g << " " << y << "_" << f << "_dead_nums" << sel_dead_num(s, f, g) << endl;
              SS2out << "dead*wt " << f << " " << y << " " << s << " " << sx(g) << " " << g << " " << y << "_" << f << "_dead*wt" << sel_dead_bio(s, f, g) << endl;
            }
    SS2out << "#" << endl << "maximum_ASEL2" << endl << "Fleet fleet_name year seas max" << endl;
    for (f = 1; f <=Nfleet; f++)
    {SS2out << f << " " << fleetname(f) << selmax(f) << endl;}
  }

  // REPORT_KEYWORD 33 ENVIRONMENTAL_DATA
  if (pick_report_use(33) == "Y" && N_envvar > 0)
  {
    SS2out << endl
           << pick_report_name(33) << endl;
    SS2out << "#_Begins.in.startyr-1.which.for.model.generated.columns.shows.the.base.value.to.which.other.years.are.scaled" << endl;
    SS2out << "#_Ninput.vectors " << N_envvar << endl;
    SS2out << "#_statistics.for.each.inout.env.vector.where.mc.is.to.meancenter.and.Zscore.also.divides.by.stdev" << endl;
    SS2out << "Index N minyr maxyr mean stdev mc Zscore" << endl;
    for (k = 1; k <= N_envvar; k++)
    {
      SS2out << k << " " << env_data_N(k) << " " << env_data_minyr(k) << " " << env_data_maxyr(k) << " " << env_data_mean(k) << " " << env_data_stdev(k) << " " << env_data_do_mean(k) << " " << env_data_do_stdev(k) << endl;
    }

    SS2out << endl
           << "Yr rel_smrynum rel_smrybio exp(recdev) rel_SSB null ";
    for (i = 1; i <= N_envvar; i++)
      SS2out << " env:_" << i;
    SS2out << endl;
    for (y = styr - 1; y <= YrMax; y++)
    {
      SS2out << y << " " << env_data(y) << endl;
    }
    SS2out << endl;
  }

  // REPORT_KEYWORD 34 TAG_Recapture
  if (pick_report_use(34) == "Y" && Do_TG > 0)
  {
    SS2out << endl
           << pick_report_name(34) << endl;
    SS2out << TG_mixperiod << " First period to use recaptures in likelihood" << endl;
    SS2out << TG_maxperiods << " Accumulation period" << endl;

    SS2out << " Tag_release_info" << endl;
    SS2out << "TAG Area Yr Seas Time Sex Age Nrelease Init_Loss Chron_Loss" << endl;
    ;
    for (TG = 1; TG <= N_TG; TG++)
    {
      SS2out << TG << " " << TG_release(TG)(2, 8) << " " << TG_save(TG)(1, 2) << endl;
    }
    SS2out << "Tags_Alive ";
    k = max(TG_endtime);
    for (t = 0; t <= k; t++)
      SS2out << t << " ";
    SS2out << endl;
    for (TG = 1; TG <= N_TG; TG++)
    {
      SS2out << TG << " " << TG_save(TG)(3, 3 + TG_endtime(TG)) << endl;
    }
    SS2out << "Total_recaptures ";
    for (t = 0; t <= k; t++)
      SS2out << t << " ";
    SS2out << endl;
    for (TG = 1; TG <= N_TG; TG++)
    {
      SS2out << TG << " ";
      for (TG_t = 0; TG_t <= TG_endtime(TG); TG_t++)
        SS2out << TG_recap_exp(TG, TG_t, 0) << " ";
      SS2out << endl;
    }

    SS2out << endl
           << "Reporting_Rates_by_Fishery" << endl
           << "Fleet Init_Reporting Report_Decay" << endl;
    for (f = 1; f <= Nfleet; f++)
      SS2out << f << " " << TG_report(f) << " " << TG_rep_decay(f) << endl;
    SS2out << "See_composition_data_output_for_tag_recapture_details" << endl;
  }

  // ************************                     SS_Label_400
  // REPORT_KEYWORD 35 NUMBERS_AT_AGE
  if (pick_report_use(35) == "Y")
  {
    SS2out << endl
           << pick_report_name(35) << endl;
    SS2out << "Area Bio_Pattern Sex BirthSeas Settlement Platoon Morph Yr Seas Time Beg/Mid Era" << age_vector << endl;
    for (p = 1; p <= pop; p++)
      for (g = 1; g <= gmorph; g++)
        if (use_morph(g) > 0)
        {
          for (y = styr - 2; y <= YrMax; y++)
            for (s = 1; s <= nseas; s++)
            {
              t = styr + (y - styr) * nseas + s - 1;
              temp = double(y) + azero_seas(s);
              SS2out << p << " " << GP4(g) << " " << sx(g) << " " << Bseas(g) << " " << settle_g(g) << " " << GP2(g) << " " << g << " " << y << " " << s << " " << temp << " B";
              if (y == styr - 2)
              {
                SS2out << " VIRG ";
              }
              else if (y == styr - 1)
              {
                SS2out << " INIT ";
              }
              else if (y <= endyr)
              {
                SS2out << " TIME ";
              }
              else
              {
                SS2out << " FORE ";
              }
              SS2out << Save_PopAge(t, p, g) << endl;
              temp = double(y) + azero_seas(s) + seasdur_half(s);
              SS2out << p << " " << GP4(g) << " " << sx(g) << " " << Bseas(g) << " " << settle_g(g) << " " << GP2(g) << " " << g << " " << y << " " << s << " " << temp << " M";
              if (y == styr - 2)
              {
                SS2out << " VIRG ";
              }
              else if (y == styr - 1)
              {
                SS2out << " INIT ";
              }
              else if (y <= endyr)
              {
                SS2out << " TIME ";
              }
              else
              {
                SS2out << " FORE ";
              }
              SS2out << Save_PopAge(t, p + pop, g) << endl;
            }
        }
  }

  // REPORT_KEYWORD 36 BIOMASS_AT_AGE
  if (pick_report_use(36) == "Y")
  {
    SS2out << endl
           << pick_report_name(36) << endl;
    SS2out << "Area Bio_Pattern Sex BirthSeas Settlement Platoon Morph Yr Seas Time Beg/Mid Era" << age_vector << endl;
    for (p = 1; p <= pop; p++)
      for (g = 1; g <= gmorph; g++)
        if (use_morph(g) > 0)
        {
          for (y = styr - 2; y <= YrMax; y++)
            for (s = 1; s <= nseas; s++)
            {
              t = styr + (y - styr) * nseas + s - 1;
              temp = double(y) + azero_seas(s);
              SS2out << p << " " << GP4(g) << " " << sx(g) << " " << Bseas(g) << " " << settle_g(g) << " " << GP2(g) << " " << g << " " << y << " " << s << " " << temp << " B";
              if (y == styr - 2)
              {
                SS2out << " VIRG ";
              }
              else if (y == styr - 1)
              {
                SS2out << " INIT ";
              }
              else if (y <= endyr)
              {
                SS2out << " TIME ";
              }
              else
              {
                SS2out << " FORE ";
              }
              SS2out << Save_PopBio(t, p, g) << endl;
              temp = double(y) + azero_seas(s) + seasdur_half(s);
              SS2out << p << " " << GP4(g) << " " << sx(g) << " " << Bseas(g) << " " << settle_g(g) << " " << GP2(g) << " " << g << " " << y << " " << s << " " << temp << " M";
              if (y == styr - 2)
              {
                SS2out << " VIRG ";
              }
              else if (y == styr - 1)
              {
                SS2out << " INIT ";
              }
              else if (y <= endyr)
              {
                SS2out << " TIME ";
              }
              else
              {
                SS2out << " FORE ";
              }
              SS2out << Save_PopBio(t, p + pop, g) << endl;
            }
        }
  }

  // REPORT_KEYWORD 37 NUMBERS_AT_LENGTH
  if (pick_report_use(37) == "Y")
  {
    SS2out << endl
           << pick_report_name(37) << endl;
    SS2out << "Area Bio_Pattern Sex BirthSeas Settlement Platoon Morph Yr Seas Time Beg/Mid Era " << len_bins << endl;
    for (p = 1; p <= pop; p++)
      for (g = 1; g <= gmorph; g++)
        if (use_morph(g) > 0)
        {
          for (y = styr; y <= YrMax; y++)
            for (s = 1; s <= nseas; s++)
            {
              t = styr + (y - styr) * nseas + s - 1;
              temp = double(y) + azero_seas(s);
              SS2out << p << " " << GP4(g) << " " << sx(g) << " " << Bseas(g) << " " << settle_g(g) << " " << GP2(g) << " " << g << " " << y << " " << s << " " << temp << " B ";
              if (y == styr - 2)
              {
                SS2out << " VIRG ";
              }
              else if (y == styr - 1)
              {
                SS2out << " INIT ";
              }
              else if (y <= endyr)
              {
                SS2out << " TIME ";
              }
              else
              {
                SS2out << " FORE ";
              }
              SS2out << Save_PopLen(t, p, g) << endl;
              temp = double(y) + azero_seas(s) + seasdur_half(s);
              SS2out << p << " " << GP4(g) << " " << sx(g) << " " << Bseas(g) << " " << settle_g(g) << " " << GP2(g) << " " << g << " " << y << " " << s << " " << temp << " M ";
              if (y == styr - 2)
              {
                SS2out << " VIRG ";
              }
              else if (y == styr - 1)
              {
                SS2out << " INIT ";
              }
              else if (y <= endyr)
              {
                SS2out << " TIME ";
              }
              else
              {
                SS2out << " FORE ";
              }
              SS2out << Save_PopLen(t, p + pop, g) << endl;
            }
        }
  }

  // REPORT_KEYWORD 38 BIOMASS_AT_LENGTH
  if (pick_report_use(38) == "Y")
  {
    SS2out << endl
           << pick_report_name(38) << endl;
    SS2out << "Area Bio_Pattern Sex BirthSeas Settlement Platoon Morph Yr Seas Time Beg/Mid Era " << len_bins << endl;
    for (p = 1; p <= pop; p++)
      for (g = 1; g <= gmorph; g++)
        if (use_morph(g) > 0)
        {
          for (y = styr; y <= YrMax; y++)
            for (s = 1; s <= nseas; s++)
            {
              t = styr + (y - styr) * nseas + s - 1;
              temp = double(y) + azero_seas(s);
              SS2out << p << " " << GP4(g) << " " << sx(g) << " " << Bseas(g) << " " << settle_g(g) << " " << GP2(g) << " " << g << " " << y << " " << s << " " << temp << " B ";
              if (y == styr - 2)
              {
                SS2out << " VIRG ";
              }
              else if (y == styr - 1)
              {
                SS2out << " INIT ";
              }
              else if (y <= endyr)
              {
                SS2out << " TIME ";
              }
              else
              {
                SS2out << " FORE ";
              }
              SS2out << Save_PopWt(t, p, g) << endl;
              temp = double(y) + azero_seas(s) + seasdur_half(s);
              SS2out << p << " " << GP4(g) << " " << sx(g) << " " << Bseas(g) << " " << settle_g(g) << " " << GP2(g) << " " << g << " " << y << " " << s << " " << temp << " M ";
              if (y == styr - 2)
              {
                SS2out << " VIRG ";
              }
              else if (y == styr - 1)
              {
                SS2out << " INIT ";
              }
              else if (y <= endyr)
              {
                SS2out << " TIME ";
              }
              else
              {
                SS2out << " FORE ";
              }
              SS2out << Save_PopWt(t, p + pop, g) << endl;
            }
        }
  }

  // REPORT_KEYWORD 39 F_AT_AGE
  if (pick_report_use(39) == "Y")
  {
    SS2out << endl
           << pick_report_name(39) << endl;
    SS2out << "Area Fleet Sex Morph Yr Seas Era" << age_vector << endl;
    for (f = 1; f <= Nfleet; f++)
      if (fleet_type(f) <= 2)
        for (g = 1; g <= gmorph; g++)
        {
          if (use_morph(g) > 0)
          {
            for (y = styr - 1; y <= YrMax; y++)
              for (s = 1; s <= nseas; s++)
              {
                t = styr + (y - styr) * nseas + s - 1;
                SS2out << fleet_area(f) << " " << f << " " << sx(g) << " " << g << " " << y << " " << s;
                if (y == styr - 1)
                {
                  SS2out << " INIT ";
                }
                else if (y <= endyr)
                {
                  SS2out << " TIME ";
                }
                else
                {
                  SS2out << " FORE ";
                }
                SS2out << Hrate(f, t) * save_sel_num(t, f, g) << endl;
              }
          }
        }
  }

  // REPORT_KEYWORD 40 CATCH_AT_AGE
  if (pick_report_use(40) == "Y")
  {
    SS2out << endl
           << pick_report_name(40) << endl;
    SS2out << "Area Fleet Sex  XX XX Type Morph Yr Seas XX Era" << age_vector << endl;
    for (f = 1; f <= Nfleet; f++)
      if (fleet_type(f) <= 2 || fleet_type(f) == 4)
        for (g = 1; g <= gmorph; g++)
        {
          if (use_morph(g) > 0)
          {
            for (y = styr - 1; y <= YrMax; y++)
              for (s = 1; s <= nseas; s++)
              {
                t = styr + (y - styr) * nseas + s - 1;
                SS2out << fleet_area(f) << " " << f << " " << sx(g) << " XX XX dead " << g << " " << y << " " << s;
                if (y == styr - 1)
                {
                  SS2out << " XX INIT ";
                }
                else if (y <= endyr)
                {
                  SS2out << " XX TIME ";
                }
                else
                {
                  SS2out << " XX FORE ";
                }
                SS2out << catage(t, f, g) << endl;
              }
          }
        }
  }

  // REPORT_KEYWORD 41 DISCARD_AT_AGE
  if (pick_report_use(41) == "Y")
  {
    SS2out << endl
           << pick_report_name(41) << endl;
    SS2out << "Area Fleet Sex  XX XX Type Morph Yr Seas XX Era" << age_vector << endl;
    for (f = 1; f <= Nfleet; f++)
      //     if((fleet_type(f)<=2 && Do_Retain(f)>0) || fleet_type(f)==4)
      if ((fleet_type(f) <= 2 && Do_Retain(f) > 0))
        for (g = 1; g <= gmorph; g++)
        {
          if (use_morph(g) > 0)
          {
            for (y = styr - 1; y <= YrMax; y++)
              for (s = 1; s <= nseas; s++)
              {
                t = styr + (y - styr) * nseas + s - 1;
                SS2out << fleet_area(f) << " " << f << " " << sx(g) << " XX XX dead " << g << " " << y << " " << s;
                if (y == styr - 1)
                {
                  SS2out << " XX INIT ";
                }
                else if (y <= endyr)
                {
                  SS2out << " XX TIME ";
                }
                else
                {
                  SS2out << " XX FORE ";
                }
                SS2out << catage(t, f, g) << endl;
                SS2out << fleet_area(f) << " " << f << " " << sx(g) << " XX XX sel " << g << " " << y << " " << s;
                if (y == styr - 1)
                {
                  SS2out << " XX INIT ";
                }
                else if (y <= endyr)
                {
                  SS2out << " XX TIME ";
                }
                else
                {
                  SS2out << " XX FORE ";
                }
                SS2out << disc_age(t, disc_fleet_list(f), g) << endl;

                SS2out << fleet_area(f) << " " << f << " " << sx(g) << " XX XX ret " << g << " " << y << " " << s;
                if (y == styr - 1)
                {
                  SS2out << " XX INIT ";
                }
                else if (y <= endyr)
                {
                  SS2out << " XX TIME ";
                }
                else
                {
                  SS2out << " XX FORE ";
                }
                SS2out << disc_age(t, disc_fleet_list(f) + N_retain_fleets, g) << endl;

                SS2out << fleet_area(f) << " " << f << " " << sx(g) << " XX XX disc " << g << " " << y << " " << s;
                if (y == styr - 1)
                {
                  SS2out << " XX INIT ";
                }
                else if (y <= endyr)
                {
                  SS2out << " XX TIME ";
                }
                else
                {
                  SS2out << " XX FORE ";
                }
                SS2out << disc_age(t, disc_fleet_list(f), g) - disc_age(t, disc_fleet_list(f) + N_retain_fleets, g) << endl;
              }
          }
        }
  }

  // REPORT_KEYWORD 42 BIOLOGY
  if (pick_report_use(42) == "Y")
  {
    SS2out << endl
           << pick_report_name(42) << endl;
    SS2out << sum(use_morph) << " " << nlength << " " << nages << " " << nseas << " N_Used_morphs;_lengths;_ages;_season;_by_season_in_endyr" << endl;
    if (gender == 2)
    {
      SS2out << "GP Bin Len_lo Len_mean Wt_F Mat Mat*Fec Wt_M Fec";
    }
    else
    {
      SS2out << "GP Bin Len_lo Len_mean Wt_F Mat Mat*Fec Fec";
    }
    if(Maturity_Option == 4 || Maturity_Option == 5) {
      SS2out << " // [Mat, Mat*Fec, and Fec reported as 0.5 because maturity option directly reads age_fecundity]";
    }
    SS2out << endl;
    for (gp = 1; gp <= N_GP; gp++)
      for (z = 1; z <= nlength; z++)
      {
        SS2out << gp << " " << z << " " << len_bins(z) << " " << len_bins_m(z) << " " << wt_len(1, gp, z) << " " << mat_len(gp, z) << " " << mat_fec_len(gp, z);
        if (gender == 2)
        {
          SS2out << " " << wt_len(1, N_GP + gp, z);
        }
        SS2out << " " << fec_len(gp, z) << endl;
      }
  }

  // REPORT_KEYWORD 43 NATURAL_MORTALITY
  if (pick_report_use(43) == "Y")
  {
    SS2out << endl
           << pick_report_name(43) << endl;
    SS2out << "Method: " << natM_type << endl;
    int hide_M1 = 1;
    if(N_pred > 0)
    {
      SS2out<< "area 0 shows M1 only, numbered areas have M1+M2"<<endl;
      hide_M1 = 0;
    }
    SS2out << "Area Bio_Pattern Sex BirthSeas Settlement Platoon Morph Yr Seas Time Beg/Mid Era" << age_vector << endl;
    for (p = hide_M1; p <= pop; p++)
    for (gp = 1; gp <= N_GP * gender; gp++)
    {
      g = g_Start(gp); //  base platoon
      for (settle = 1; settle <= N_settle_timings; settle++)
      {
        g += N_platoon;
        int gpi = GP3(g); // GP*gender*settlement
        for (y = styr - 3; y <= YrMax; y++)
        for (s = 1; s <= nseas; s++)
            {
              t = styr + (y - styr) * nseas + s - 1;
              temp = double(y) + azero_seas(s);
              SS2out << p << " " << GP4(g) << " " << sx(g) << " " << Bseas(g) << " " << settle_g(g) << " " << GP2(g) << " " << g << " " << y << " " << s << " " << temp << " B";
              if (y == styr - 3)
              {
                SS2out << " BENCH ";
              }
              else if (y == styr - 2)
              {
                SS2out << " VIRG ";
              }
              else if (y == styr - 1)
              {
                SS2out << " INIT ";
              }
              else if (y <= endyr)
              {
                SS2out << " TIME ";
              }
              else
              {
                SS2out << " FORE ";
              }
              SS2out<<natM(t,p,gpi)<<endl;
            }
          }
        }

    if (N_predparms > 0)
    {
      SS2out << endl
             << "Predator_(M2); Values_are_apical_M2; total_M-at-age_(M1+M2)_reported_in_table_No_fishery_for_Z=M " << endl
             << "Yr Era seas ";
      for (f1 = 1; f1 <= N_pred; f1++)
      {
        f = predator(f1);
        SS2out << fleetname(f) << "_M2 comsume_Bio consume_Num";
      }
      SS2out << endl;
      for (y = styr - 2; y <= YrMax; y++)
      {
        for (s = 1; s <= nseas; s++)
        {
          t = styr + (y - styr) * nseas + s - 1;
          SS2out << y;
          if (y == styr - 2)
          {
            SS2out << " VIRG ";
          }
          else if (y == styr - 1)
          {
            SS2out << " INIT ";
          }
          else if (y <= endyr)
          {
            SS2out << " TIME ";
          }
          else
          {
            SS2out << " FORE ";
          }
          SS2out << s << " ";
          for (f1 = 1; f1 <= N_pred; f1++)
          {
            SS2out << pred_M2(f1, t) << " " << catch_fleet(t, predator(f1), 1) << " " << catch_fleet(t, predator(f1), 4) << " ";
          }
          SS2out << endl;
        }
      }
    }
  }
  // REPORT_KEYWORD 44 AGE_SPECIFIC_K
  if (pick_report_use(44) == "Y" && Grow_type >= 3 && Grow_type <= 6)
  {
    SS2out << endl
           << pick_report_name(44) << endl;
    SS2out << "Bio_Pattern Sex " << age_vector << endl;
    g = 0;
    for (gg = 1; gg <= gender; gg++)
      for (gp = 1; gp <= N_GP; gp++)
      {
        g++;
        SS2out << gp << " " << gg << " " << -VBK(g) << endl;
      }
  }

  // REPORT_KEYWORD 45 GROWTH_PARAMETERS_derived
  if (pick_report_use(45) == "Y")
  {
    SS2out << endl
           << pick_report_name(45) << endl;
    SS2out << " Count Yr Sex Platoon A1 A2 L_a_A1 L_a_A2 K A_a_L0 Linf CVmin CVmax natM_amin natM_max M_age0 M_nages"
           << " WtLen1 WtLen2 Mat1 Mat2 Fec1 Fec2" << endl;
    for (g = 1; g <= save_gparm_print; g++)
    {
      SS2out << save_G_parm(g)(1, 2) << " " << sx(save_G_parm(g, 3)) << " " << save_G_parm(g)(3, 22) << endl;
    }
  }
  // REPORT_KEYWORD 46 SEASONAL_BIOLOGY
  if (pick_report_use(46) == "Y" && MGparm_doseas > 0)
  {
    SS2out << endl
           << pick_report_name(46) << endl;
    SS2out << "Seas F_wtlen1 F_wtlen2 F_mat1 F_mat2 F_fec1 F_fec2 M_wtlen1 M_wtlen2 L_a_A1 VBK" << endl;
    for (s = 1; s <= nseas; s++)
    {
      SS2out << s << " " << save_seas_parm(s) << endl;
    }
  }

  //    restore_AgeLength_Key to endyr, otherwise it will have ALK from end of forecast
  //   NOT SURE why this code is here
  if (timevary_MG(endyr, 2) > 0 || timevary_MG(endyr, 3) > 0 || WTage_rd > 0)
  {
    y = endyr;
    t_base = styr + (y - styr) * nseas - 1;
    for (s = 1; s <= nseas; s++)
    {
      t = t_base + s;
      bio_t = styr + (endyr - styr) * nseas + s - 1;
      subseas = 1;
      ALK_idx = (s - 1) * N_subseas + subseas;
      get_growth3(styr, t, s, subseas);
      Make_AgeLength_Key(s, subseas); //  for begin season
      subseas = mid_subseas;
      ALK_idx = (s - 1) * N_subseas + subseas;
      get_growth3(styr, t, s, subseas);
      Make_AgeLength_Key(s, subseas); //  for midseason
      if (s == spawn_seas)
      {
        subseas = spawn_subseas;
        ALK_idx = (s - 1) * N_subseas + subseas;
        if (spawn_subseas != 1 && spawn_subseas != mid_subseas)
        {
          get_growth3(styr, t, s, subseas);
          Make_AgeLength_Key(s, subseas); //  spawn subseas
        }
        get_mat_fec();
      }
    }
  }

  dvariable Herma_Cum;
  // REPORT_KEYWORD 47 Biology_at_age_by_morph
  if (pick_report_use(47) == "Y")
  {
    SS2out << endl
           << pick_report_name(47) << endl;
    SS2out << "in_endyr_with_";
    switch (CV_depvar)
    {
      case 0:
      {
        SS2out << "CV=f(LAA)";
        break;
      }
      case 1:
      {
        SS2out << "CV=F(A)";
        break;
      }
      case 2:
      {
        SS2out << "SD=F(LAA)";
        break;
      }
      case 3:
      {
        SS2out << "SD=F(A)";
        break;
      }
      case 4:
      {
        SS2out << "logSD=f(A)";
        break;
      }
    }

    SS2out << endl;
    SS2out << "Seas Morph Bio_Pattern Sex Settlement Platoon int_Age Real_Age Age_Beg Age_Mid M Len_Beg Len_Mid SD_Beg SD_Mid Wt_Beg Wt_Mid Len_Mat Age_Mat Mat*Fecund Mat_F_wtatage Mat_F_Natage";
    if (Hermaphro_Option != 0)
    {
      SS2out << " Herma_Trans ";
    }
    if (gender == 2)
    {
      for (p = 1; p <=pop; p++)
        SS2out << " sex_ratio_area:_" << p ;
    }
    for (f = 1; f <= Nfleet; f++)
      SS2out << " Len:_" << f << " SelWt:_" << f << " RetWt:_" << f;
    SS2out << endl;
    for (s = 1; s <= nseas; s++)
    {
      t = styr + (endyr - styr) * nseas + s - 1;
      ALK_idx = (s - 1) * N_subseas + 1; // for first subseas of season
      ALK_idx_mid = (s - 1) * N_subseas + mid_subseas; // for midsubseas of the season
      for (g = 1; g <= gmorph; g++)
        if (use_morph(g) > 0)
        {
          for (a = 0; a <= nages; a++)
          {
            SS2out << s << " " << g << " " << GP4(g) << " " << sx(g) << " " << settle_g(g) << " " << GP2(g) << " " << a << " " << real_age(g, ALK_idx, a) << " " << calen_age(g, ALK_idx, a) << " " << calen_age(g, ALK_idx_mid, a);
            SS2out << " " << natM(t, 1, GP3(g), a) << " " << Ave_Size(t, 1, g, a) << " " << Ave_Size(t, mid_subseas, g, a) << " "
                   << Sd_Size_within(ALK_idx, g, a) << " " << Sd_Size_within(ALK_idx_mid, g, a) << " "
                   << Wt_Age_beg(s, g, a) << " " << Wt_Age_mid(s, g, a) << " " << ALK(ALK_idx, g, a) * mat_len(GP4(g)) << " ";
            if (Maturity_Option <= 2)
            {
              SS2out << mat_age(GP4(g), a);
            }
            else if (sx(g) == 1 && Maturity_Option < 5)
            {
              SS2out << Age_Maturity(GP4(g), a);
            }
            else
            {
              SS2out << -1.;
            }
            SS2out << " " << fec(g, a) << " " << make_mature_bio(g, a) << " " << make_mature_numbers(g, a);
            if (Hermaphro_Option == 1)
            {
              if (sx(g) == 1)
              {
                SS2out << " " << Hermaphro_val(GP4(g), a) << " ";
              }
              else
              {
                SS2out << " NA ";
              }
            }
            else if (Hermaphro_Option == -1)
            {
              if (sx(g) == 2)
              {
                SS2out << " " << Hermaphro_val(GP4(g), a) << " ";
              }
              else
              {
                SS2out << " NA ";
              }
            }
            //  write sex ratio in endyr for each area using natage
            //  small constant added to denominator so that morph-area combos with no fish will display a value of 0.0, rather than "nan"
            //  because natage is used, the reported sex ratio values will be responsive to hermaphroditism, and to sex-specific mortality
            if (gender == 2)
            {
              if (sx(g) == 1)
              {
                for (p = 1; p <= pop; p++)
                  SS2out << " " << natage(t, p, g, a) / (natage(t, p, g, a) + natage(t, p, g + gmorph / 2, a) + 1.0e-07) << " ";
              }
              else
              {
                for (p = 1; p <= pop; p++)
                  SS2out << " " << natage(t, p, g, a) / (natage(t, p, g, a) + natage(t, p, g - gmorph / 2, a) + 1.0e-07) << " ";
              }
            }
            if (WTage_rd == 0)
            {
              for (f = 1; f <= Nfleet; f++)
                SS2out << " " << ALK(ALK_idx_mid, g, a) * elem_prod(sel_l(endyr, f, sx(g)), len_bins_m) / (ALK(ALK_idx_mid, g, a) * sel_l(endyr, f, sx(g))) << " " << ALK(ALK_idx_mid, g, a) * elem_prod(sel_l(endyr, f, sx(g)), wt_len(s, GP(g))) / (ALK(ALK_idx_mid, g, a) * sel_l(endyr, f, sx(g))) << " " << ALK(ALK_idx_mid, g, a) * elem_prod(sel_l_r(endyr, f, sx(g)), wt_len(s, GP(g))) / (ALK(ALK_idx_mid, g, a) * sel_l_r(endyr, f, sx(g)));
            }
            else
            {
              for (f = 1; f <= Nfleet; f++)
                SS2out << " " << ALK(ALK_idx_mid, g, a) * elem_prod(sel_l(endyr, f, sx(g)), len_bins_m) / (ALK(ALK_idx_mid, g, a) * sel_l(endyr, f, sx(g))) << " " << Wt_Age_t(t, f, g, a) << " " << Wt_Age_t(t, f, g, a);
            }
            SS2out << endl;
          }
        }
    }
  }

  // REPORT_KEYWORD 48 MEAN_BODY_WT by year
  if (pick_report_use(48) == "Y")
  {
    SS2out << endl
           << pick_report_name(48) << endl;
    if (WTage_rd > 0)
      SS2out << " as read from wtatage.ss";
    SS2out << "#NOTE: yr=_" << styr - 3 << "_stores_values_for_benchmark" << endl;
    SS2out << "Morph Yr Seas" << age_vector << endl;
    for (g = 1; g <= gmorph; g++)
      if (use_morph(g) > 0)
      {
        for (y = styr - 3; y <= YrMax; y++)
        {
          yz = y;
          if (yz > endyr + 2)
            yz = endyr + 2;
          //    if(y==styr-3 || y==styr || timevary_MG(yz,2)>0 || timevary_MG(yz,3)>0 || WTage_rd>0)  // if growth or wtlen parms have changed
          for (s = 1; s <= nseas; s++)
          {
            t = styr + (y - styr) * nseas + s - 1;
            SS2out << g << " " << y << " " << s << " " << Wt_Age_t(t, 0, g) << endl;
          }
        }
      }
  }

  // REPORT_KEYWORD 49 MEAN_SIZE_TIMESERIES  body length
  if (pick_report_use(49) == "Y")
  {
    SS2out << endl
           << pick_report_name(49) << endl;
    SS2out << "Morph Yr Seas SubSeas" << age_vector << endl;
    for (g = 1; g <= gmorph; g++)
      if (use_morph(g) > 0)
      {
        for (y = styr - 3; y <= YrMax; y++)
        {
          yz = y;
          if (yz > endyr + 2)
            yz = endyr + 2;
          //        if(y==styr-3 || y==styr ||  timevary_MG(yz,2)>0)
          {
            for (s = 1; s <= nseas; s++)
            {
              t = styr + (y - styr) * nseas + s - 1;
              for (i = 1; i <= N_subseas; i++)
              {
                SS2out << g << " " << y << " " << s << " " << i << " " << Ave_Size(t, i, g) << endl;
              }
            }
          }
        }
      }
    s = 1;
    for (i = 1; i <= gender; i++)
    {
      SS2out << "#" << endl
             << "mean_size_Jan_1_for_sex: " << i << "#NOTE: combines_all_settlements_areas_GP_and_platoons" << endl;
      SS2out << "Sex Yr Seas Beg " << age_vector << endl;
      for (y = styr; y <= YrMax; y++)
      {
        yz = y;
        if (yz > endyr + 2)
          yz = endyr + 2;
        if (y <= styr || timevary_MG(yz, 2) > 0 || N_platoon > 1)
        {
          t = styr + (y - styr) * nseas + s - 1;
          SS2out << i << " " << y << " " << s << " " << 0;
          for (a = 0; a <= nages; a++)
          {
            temp = 0.0;
            temp1 = 0.0;
            for (g = 1; g <= gmorph; g++)
            {
              if (sx(g) == i && use_morph(g) > 0)
              {
                for (p = 1; p <= pop; p++)
                {
                  temp += natage(t, p, g, a);
                  temp1 += Ave_Size(t, 1, g, a) * natage(t, p, g, a);
                } // end loop of areas
              } //  end need to use this gender/platoon
            } //  end loop of all platoons
            if (temp > 0.0)
            {
              SS2out << " " << temp1 / temp;
            }
            else
            {
              SS2out << " __";
            }
          } //  end loop of ages
          SS2out << endl;
        } // end need to report this year
      } // end year loop
    } // end gender loop
  } //   end do report detail

  // REPORT_KEYWORD 50 AGE_LENGTH_KEY
  if (pick_report_use(50) == "Y")
  {
    SS2out << endl
           << pick_report_name(50) << endl;
    if (Grow_logN == 1)
      SS2out << " #Lognormal ";
    SS2out << "#" << endl; // SS_Label_460
    SS2out << " sdratio " << platoon_sd_ratio << endl;
    SS2out << " sdwithin " << sd_within_platoon << endl;
    SS2out << " sdbetween " << sd_between_platoon << endl;
    for (s = 1; s <= nseas; s++)
      for (subseas = 1; subseas <= N_subseas; subseas++)
        for (g = 1; g <= gmorph; g++)
          if (use_morph(g) > 0)
          {
            t = styr + (endyr - styr) * nseas + s - 1;
            ALK_idx = (s - 1) * N_subseas + subseas;
            SS2out << "#" << endl
                   << " Seas: " << s << " Sub_Seas: " << subseas << "   Morph: " << g << endl;
            SS2out << "Age:";
            for (a = 0; a <= nages; a++)
              SS2out << " " << a;
            SS2out << endl;
            for (z = nlength; z >= 1; z--)
            {
              SS2out << len_bins2(z) << " ";
              for (a = 0; a <= nages; a++)
                SS2out << ALK(ALK_idx, g, a, z) << " ";
              SS2out << endl;
            }
            SS2out << "mean " << Ave_Size(t, subseas, g) << endl;
            SS2out << "sdsize " << Sd_Size_within(ALK_idx, g) << endl;
          }
  }

  // REPORT_KEYWORD 51 AGE_AGE_KEY
  if (pick_report_use(51) == "Y" && N_ageerr > 0)
  {
    SS2out << endl
           << pick_report_name(51) << endl;
    for (k = 1; k <= N_ageerr + store_agekey_add; k++)
    {
      SS2out << "KEY: " << k << endl
             << "mean " << age_err(k, 1) << endl
             << "SD " << age_err(k, 2) << endl;
      for (b = n_abins; b >= 1; b--)
      {
        SS2out << age_bins(b) << " ";
        for (a = 0; a <= nages; a++)
          SS2out << age_age(k, b, a) << " ";
        SS2out << endl;
      }
      if (gender == 2)
      {
        L2 = n_abins;
        A2 = nages + 1;
        for (b = n_abins; b >= 1; b--)
        {
          SS2out << age_bins(b) << " ";
          for (a = 0; a <= nages; a++)
            SS2out << age_age(k, b + L2, a + A2) << " ";
          SS2out << endl;
        }
      }
    }
  }

  // REPORT_KEYWORD 52 COMPOSITION_DATABASE
  /* SS_Label_xxx report the composition database to CompReport.sso */
  int last_t;
  if (pick_report_use(52) == "Y")
  {
    SS_compout << endl
               << "Size_Bins_pop;_(Pop_len_mid_used_for_calc_of_selex_and_bio_quantities)" << endl;
    SS_compout << "Pop_Bin: ";
    for (j = 1; j <= nlength; j++)
      SS_compout << " " << j;
    SS_compout << endl
               << "Length: " << len_bins << endl;
    SS_compout << "Len_mid: " << len_bins_m << endl;
    SS_compout << "Size_Bins_dat;_(Data_len_mid_for_reporting_only)" << endl;
    SS_compout << "Data_Bin: ";
    for (j = 1; j <= nlen_bin; j++)
      SS_compout << " " << j;
    SS_compout << endl
               << "Length: " << len_bins_dat << endl;
    SS_compout << "Len_mid: " << len_bins_dat_m << endl;

    SS_compout << "Combine_males_with_females_thru_sizedata_bin " << CombGender_L << endl;
    //  SS_compout<<"Size:"<<len_bins_dat(CombGender_L)<<endl;
    SS_compout << "Combine_males_with_females_thru_Age_Data_bin: " << CombGender_A << endl;
    //  SS_compout<<"Age: "<<age_bins(CombGender_A)<<endl;
    SS_compout << endl
               << "Method_for_Lbin_definition_for_agecomp_data: " << Lbin_method << endl;

    SS_compout << "For_Sizefreq;_Lbin_Lo_is_units(bio_or_numbers);_Lbin_hi_is_scale(kg,_lb,_cm,_in),_Ageerr_is_method" << endl;
    SS_compout << "For_mean_size_at_age,_the_sign_of_ageerror_indicates_length(positive),_or_weight(negative)" << endl;
    SS_compout << "For_mean_size_at_age,_the_std_dev_of_size_at_age_is_stored_in_LbinLo_ans_LbinHi_is_ignored" << endl;
    SS_compout << "subseas_is_derived_from_month_and_the_number_of_subseasons_per_season,_which_is: " << N_subseas << endl;
    SS_compout << "Time_is_fraction_of_year_based_on_subseas,_not_directly_on_month" << endl;
    SS_compout << "If_observations_with_same_or_different_month_value_are_assigned_to_the_same_subseas,_then_repli(cate)_counter_is_incremented" << endl;
    SS_compout << "For_Tag_output,_Rep_contains_Tag_Group,_Bin_is_fleet_for_TAG1_and_Bin_is_Year.Seas_for_TAG2" << endl;
    SS_compout << "Column_Super?_indicates_super-periods;_column_used_indicates_inclusion_in_logL" << endl;

    SS_compout << endl
               << "Composition_Database" << endl; // SS_Label_480

    SS_compout << "Yr Month Seas Subseas Time Fleet Area Repl. Sexes Kind Part Ageerr Sex Lbin_lo Lbin_hi Bin Obs Exp Pearson Nsamp_adj Nsamp_in effN Like Cum_obs Cum_exp SuprPer Used?" << endl;
    int repli;
    int N_out;
    int z_lo = 1;
    int z_hi = 1;
    int nbins = 0;
    double ocomp = 0.0;
    double ecomp = 0.0;
    N_out = 0;
    double show_logL = 0.0;
    double show_Pearson = 0.0;
    double nsamp = 0.0;

    for (f = 1; f <= Nfleet; f++)
    {

      /* SS_Label_xxx  output lengthcomp to CompReport.sso */
      {
        data_type = 4; // for length comp
        in_superperiod = 0;
        repli = 0;
        last_t = -999;
        for (i = 1; i <= Nobs_l(f); i++) // loop obs in this type/time
        {
          N_out++;
          t = Len_time_t(f, i);
          ALK_time = Len_time_ALK(f, i);
          temp2 = 0.0;
          temp1 = 0.0;
          real_month = abs(header_l_rd(f, i, 2));
          if (real_month > 999)
            real_month -= 1000.;

          if (ALK_time == last_t)
          {
            repli++;
          }
          else
          {
            repli = 1;
            last_t = ALK_time;
          }
          in_superperiod = determine_speriod(in_superperiod, anystring, header_l(f, i, 2), header_l(f, i, 3));

//        count bins
          nbins = 0;
          for (gg = 1; gg <= gender ; gg ++)
          {
            if (gen_l(f, i) != 2 && gg == 1)
            {
              z_lo = tails_l(f, i, 1);
              z_hi = tails_l(f, i, 2);
              nbins += z_hi - z_lo + 1;
            }
            else if (gen_l(f, i) >= 2 && gg == 2) // do males
            {
              z_lo = tails_l(f, i, 3);
              z_hi = tails_l(f, i, 4);
              nbins += z_hi - z_lo + 1;
            }
          }

          int gender2 = gender;
          if (gen_l(f, i) == 0) gender2 = 1;
          for (gg = 1; gg <= gender2 ; gg ++)
          {
            if (gen_l(f, i) != 2 && gg == 1)
            {
              s_off = 1;
              z_lo = tails_l(f, i, 1);
              z_hi = tails_l(f, i, 2);
            }
            else if (gen_l(f, i) >= 2 && gg == 2) // do males
            {
              s_off = 2;
              z_lo = tails_l(f, i, 3);
              z_hi = tails_l(f, i, 4);
            }
            // temp = gammln(dirichlet_Parm) - gammln(nsamp_l(f, i) + dirichlet_Parm);
            nsamp = fabs(nsamp_l(f, i));
            for (z = z_lo; z <= z_hi; z++)
            {
              ocomp = obs_l(f, i, z); 
              ecomp = value( exp_l(f, i, z) ); 
              // Yr Month Seas Subseas Time Fleet Area Repl. Sexes Kind Part Ageerr Sex Lbin_lo Lbin_hi Bin Obs Exp
              SS_compout << header_l(f, i, 1) << " " << real_month << " " << Show_Time2(ALK_time)(2, 3) << " " << data_time(ALK_time, f, 3) << " " << f << " " << fleet_area(f) << " " << repli << " " << gen_l(f, i) << " LEN " << mkt_l(f, i) << " 0 " << s_off << " " << 1 << " " << 1 << " " << len_bins_dat2(z) << " " << ocomp << " " << ecomp << " ";
              // Pearson Nsamp_adj Nsamp_in effN Like
              temp2 += ocomp;
              temp1 += ecomp;
              if (nsamp > 0 && header_l(f, i, 3) > 0 && (ecomp != 0.0 && ecomp != 1.0) && nbins > 0 ) // check for values to include
              {
                  int parti = mkt_l(f, i);
                  if (Comp_Err_L(parti,f) == 0)
                  {
                    show_Pearson = (ocomp - ecomp) / sqrt(ecomp * (1.0 - ecomp) / nsamp ); // Pearson for multinomial
                    show_logL = ocomp * log( (ocomp + 1.0e-12) / ( ecomp + 1.0e-12) ) * nsamp;  //  logL
                  }
                  if (Comp_Err_L(parti, f) == 1 || Comp_Err_L(parti, f) == 2)
                  {
                    dirichlet_Parm = mfexp(selparm(Comp_Err_parmloc(Comp_Err_L2(parti, f),1)));
                    if (Comp_Err_L(parti, f) == 1 )
                      { dirichlet_Parm *= nsamp; }
                    show_Pearson = value((ocomp - ecomp) / sqrt(ecomp * (1.0 - ecomp) / nsamp * (nsamp + dirichlet_Parm) / (1. + dirichlet_Parm))); // Pearson for Dirichlet-multinomial using negative-exponential parameterization
                    show_logL =  -offset_l(f,i) / nbins
                     - value( gammln(nsamp * ocomp + dirichlet_Parm * ecomp) - gammln(dirichlet_Parm * ecomp))
                     - value( ( gammln(dirichlet_Parm) - gammln(nsamp + dirichlet_Parm))) / nbins;
                  }
                  if (Comp_Err_L(parti, f) == 3 )  //  MV Tweedie
                  {
                  }
                  SS_compout << show_Pearson << " " << nsamp << " " << nsamp_l_read(f, i) << " " << neff_l(f, i) << " " << show_logL;
              }
              else // sample size zero or skip
              {
                SS_compout << " NA " << " " << nsamp << " " << nsamp_l_read(f, i) << " NA NA "; // placeholder
              }
              // Cum_obs Cum_exp SuprPer Used?
              SS_compout << " " << temp2 << " " << temp1 << " " << anystring <<endl;
            }
            // single row representing info from previous bin-specific rows
            SS_compout << header_l(f, i, 1) << " " << header_l(f, i, 2) << " " << Show_Time2(ALK_time)(2, 3) << " " << data_time(ALK_time, f, 3) << " " << f << " " << fleet_area(f) << " " << repli << " " << gen_l(f, i) << " LEN "
                       << mkt_l(f, i) << " 0 " << s_off << " " << 1 << " " << 1 << endl;
          }
        }
      }

      /* SS_Label_xxx  output agecomp to CompReport.sso */
      {
        data_type = 5; // for age comp
        in_superperiod = 0;
        repli = 0;
        last_t = -999;
        for (i = 1; i <= Nobs_a(f); i++) // loop obs in this type/time
        {
          N_out++;
          t = Age_time_t(f, i);
          ALK_time = Age_time_ALK(f, i);
          temp2 = 0.0;
          temp1 = 0.0;
          real_month = abs(header_a_rd(f, i, 2));
          if (real_month > 999)
            real_month -= 1000.;

          if (ALK_time == last_t)
          {
            repli++;
          }
          else
          {
            repli = 1;
            last_t = ALK_time;
          }
          in_superperiod = determine_speriod(in_superperiod, anystring, header_a(f, i, 2), header_a(f, i, 3));

//        count bins
          nbins = 0;
          for (gg = 1; gg <= gender ; gg ++)
          {
            if (gen_a(f, i) != 2 && gg == 1)
            {
              z_lo = tails_a(f, i, 1);
              z_hi = tails_a(f, i, 2);
              nbins += z_hi - z_lo + 1;
            }
            else if (gen_a(f, i) >= 2 && gg == 2) // do males
            {
              z_lo = tails_a(f, i, 3);
              z_hi = tails_a(f, i, 4);
              nbins += z_hi - z_lo + 1;
            }
          }

          int gender2 = gender;
          if (gen_a(f, i) == 0) gender2 = 1;
          for (gg = 1; gg <= gender2 ; gg ++)
          {
            if (gen_a(f, i) != 2 && gg == 1)
            {
              s_off = 1;
              z_lo = tails_a(f, i, 1);
              z_hi = tails_a(f, i, 2);
            }
            else if (gen_a(f, i) >= 2 && gg == 2) // do males
            {
              s_off = 2;
              z_lo = tails_a(f, i, 3);
              z_hi = tails_a(f, i, 4);
            }
            // temp = gammln(dirichlet_Parm) - gammln(nsamp_l(f, i) + dirichlet_Parm);
            nsamp = fabs(nsamp_a(f, i));
            for (z = z_lo; z <= z_hi; z++)
            {
              ocomp = obs_a(f, i, z); 
              ecomp = value( exp_a(f, i, z) ); 
              // Yr Month Seas Subseas Time Fleet Area Repl. Sexes Kind Part Ageerr Sex Lbin_lo Lbin_hi Bin Obs Exp
              SS_compout << header_a(f, i, 1) << " " << real_month << " " << Show_Time2(ALK_time)(2, 3) << " " << data_time(ALK_time, f, 3) << " " << f << " " << fleet_area(f) << " " << repli << " " << gen_a(f, i) << " AGE " << mkt_a(f, i) << " " << ageerr_type_a(f, i)
                         << " " << s_off << " " << len_bins(Lbin_lo(f, i)) << " " << len_bins(Lbin_hi(f, i)) << " " << age_bins(z) << " " << ocomp << " " << ecomp << " ";
              // Pearson Nsamp_adj Nsamp_in effN Like
              temp2 += ocomp;
              temp1 += ecomp;

              if (nsamp > 0 && header_a(f, i, 3) > 0 && (ecomp != 0.0 && ecomp != 1.0) && nbins > 0 ) // check for values to include
              {
                if (Comp_Err_A(f) == 0)
                {
                  show_Pearson = (ocomp - ecomp) / sqrt(ecomp * (1.0 - ecomp) / nsamp ); // Pearson for multinomial
                  show_logL = ocomp * log( (ocomp + 1.0e-12) / ( ecomp + 1.0e-12) ) * nsamp;  //  logL
                }
                if (Comp_Err_A(f) == 1 || Comp_Err_A(f) == 2)
                {
                  dirichlet_Parm = mfexp(selparm(Comp_Err_parmloc(Comp_Err_A2(f),1)));
                  if (Comp_Err_A(f) == 1 )
                    { dirichlet_Parm *= nsamp; }
                  show_Pearson = value((ocomp - ecomp) / sqrt(ecomp * (1.0 - ecomp) / nsamp * (nsamp + dirichlet_Parm) / (1. + dirichlet_Parm))); // Pearson for Dirichlet-multinomial using negative-exponential parameterization
                  show_logL =  -offset_a(f,i) / nbins
                   - value( gammln(nsamp * ocomp + dirichlet_Parm * ecomp) - gammln(dirichlet_Parm * ecomp))
                   - value( ( gammln(dirichlet_Parm) - gammln(nsamp + dirichlet_Parm))) / nbins;
                }
                if (Comp_Err_A(f) == 3 )  //  MV Tweedie
                {
                }
                SS_compout << show_Pearson << " " << nsamp << " " << nsamp_a_read(f, i) << " " << neff_a(f, i) << " " << show_logL;
              }
              else // sample size zero or skip
              {
                SS_compout << " NA " << " " << nsamp << " " << nsamp_a_read(f, i) << " NA NA "; // placeholder
              }
              // Cum_obs Cum_exp SuprPer Used?
              SS_compout << " " << temp2 << " " << temp1 << " " << anystring <<endl;
            }
            // single row representing info from previous bin-specific rows
            SS_compout << header_a(f, i, 1) << " " << real_month << " " << Show_Time2(ALK_time)(2, 3) << " " << data_time(ALK_time, f, 3) << " " << f << " " << fleet_area(f) << " " << repli << " " << gen_a(f, i) << " AGE "
                       << mkt_a(f, i) << " " << ageerr_type_a(f, i) << " " << s_off << " " << 1 << " " << nlength << endl;
          }
        }
      } //end have agecomp data

      /* SS_Label_xxx  output size-age to CompReport.sso */
      {
        data_type = 7; // for mean size-at-age
        in_superperiod = 0;
        repli = 0;
        last_t = -999;
        for (i = 1; i <= Nobs_ms(f); i++)
        {
          N_out++;
          t = msz_time_t(f, i);
          ALK_time = msz_time_ALK(f, i);
          temp2 = 0.0;
          temp1 = 0.0;
          real_month = abs(header_ms_rd(f, i, 2));
          if (real_month > 999)
            real_month -= 1000.;
          if (ALK_time == last_t)
          {
            repli++;
          }
          else
          {
            repli = 1;
            last_t = ALK_time;
          }
          in_superperiod = determine_speriod(in_superperiod, anystring, header_ms(f, i, 2), header_ms(f, i, 3));

          for (z = 1; z <= n_abins2; z++)
          {
            if (z <= n_abins)
              s_off = 1;
            else
              s_off = 2;
            t1 = obs_ms_n(f, i, z);
            //  where:  obs_ms_n(f,i,z)=sqrt(var_adjust(6,f)*obs_ms_n(f,i,z));
            if (ageerr_type_ms(f, i) > 0)
            {
              anystring2 = " L@A ";
            }
            else
            {
              anystring2 = " W@A ";
            }
            if (t1 > 0.)
              t1 = square(t1);
            SS_compout << header_ms(f, i, 1) << " " << real_month << " " << Show_Time2(ALK_time)(2, 3) << " " << data_time(ALK_time, f, 3) << " " << f << " " << fleet_area(f) << " " << repli << " " << gen_ms(f, i) << anystring2 << mkt_ms(f, i) << " " << ageerr_type_ms(f, i) << " " << s_off << " " << exp_ms_sq(f, i, z) << " " << nlen_bin << " " << age_bins(z) << " " << obs_ms(f, i, z) << " " << exp_ms(f, i, z) << " ";
            if (obs_ms(f, i, z) > 0. && t1 > 0. && header_ms(f, i, 3) > 0)
            {
              SS_compout << (obs_ms(f, i, z) - exp_ms(f, i, z)) / (exp_ms_sq(f, i, z) / obs_ms_n(f, i, z)) << " "; // Pearson
              SS_compout << t1 << " "; // sample size
              SS_compout << "NA "; // placeholder for input sample size
              //SS_compout<<obs_ms_n_read(f,i)<<" "; // input sample size (was a big vector)
              SS_compout << square(1.0 / ((obs_ms(f, i, z) - exp_ms(f, i, z)) / exp_ms_sq(f, i, z))) << " "; // effective sample size
              SS_compout << 0.5 * square((obs_ms(f, i, z) - exp_ms(f, i, z)) / (exp_ms_sq(f, i, z) / obs_ms_n(f, i, z))) + sd_offset * log(exp_ms_sq(f, i, z) / obs_ms_n(f, i, z)); //  -logL
            }
            else
            {
              SS_compout << " NA " << t1 << " NA NA ";
            }
            SS_compout << " NA NA " << anystring << endl;
            if (z == n_abins || z == n_abins2)
              SS_compout << header_ms(f, i, 1) << " " << real_month << " " << Show_Time2(ALK_time)(2, 3) << " " << data_time(ALK_time, f, 3) << " " << f << " " << fleet_area(f) << " " << repli << " " << gen_ms(f, i) << anystring2 << mkt_ms(f, i) << " " << ageerr_type_ms(f, i) << " " << s_off << " " << 1 << " " << nlen_bin << endl;
          }
        } //end have data
      }
    } // end fleet

    if (SzFreq_Nmeth > 0) //  have some sizefreq data
    {
      repli = 0;
      in_superperiod = 0;
      last_t = -999;
      for (iobs = 1; iobs <= SzFreq_totobs; iobs++)
      {
        y = SzFreq_obs_hdr(iobs, 1);
        if (y >= styr) // flag for obs that are used
        {
          N_out++;
          temp2 = 0.0;
          temp1 = 0.0;
          real_month = abs(SzFreq_obs1(iobs, 3)); //  month
          if (real_month > 999)
            real_month -= 1000.;
          f = abs(SzFreq_obs_hdr(iobs, 3));
          gg = SzFreq_obs_hdr(iobs, 4); // gender
          int Sz_method = SzFreq_obs1(iobs, 1);  //  sizecomp method
          int logL_method = Comp_Err_Sz(Sz_method);

          in_superperiod = determine_speriod(in_superperiod, anystring, SzFreq_obs_hdr(iobs, 2), SzFreq_obs_hdr(iobs, 3));

          p = SzFreq_obs_hdr(iobs, 5); // partition
          z_lo = SzFreq_obs_hdr(iobs, 7);
          z_hi = SzFreq_obs_hdr(iobs, 8);
          nbins = z_hi - z_lo +1;
          t = SzFreq_time_t(iobs);
          ALK_time = SzFreq_time_ALK(iobs);
          nsamp = SzFreq_sampleN(iobs);
          temp2 = 0.0;
          temp1 = 0.0;
          if (ALK_time == last_t)
          {
            repli++;
          }
          else
          {
            repli = 1;
            last_t = ALK_time;
          }
          for (z = z_lo; z <= z_hi; z++)
          {
            ocomp = SzFreq_obs(iobs, z); 
            ecomp = value( SzFreq_exp(iobs, z));
            if (z > SzFreq_Nbins(Sz_method))
            {s_off = 2;}
            else
            {s_off = 1;}
            // Yr Month Seas Subseas Time Fleet Area Repl. Sexes Kind Part Ageerr Sex Lbin_lo Lbin_hi Bin Obs Exp
            SS_compout << SzFreq_obs_hdr(iobs, 1) << " " << real_month << " " << Show_Time2(ALK_time)(2, 3) << " " << data_time(ALK_time, f, 3) << " " << f << " " << fleet_area(f) << " " << repli << " " << gg << " SIZE " << p << " " << Sz_method;
            SS_compout << " " << s_off << " " << SzFreq_units(Sz_method) << " " << SzFreq_scale(Sz_method) << " ";
            if (s_off == 1)
            {
              SS_compout << SzFreq_bins1(Sz_method, z);
            }
            else
            {
              SS_compout << SzFreq_bins1(Sz_method, z - SzFreq_Nbins(Sz_method));
            }
            SS_compout << " " << ocomp << " " << ecomp << " ";
            temp2 += ocomp;
            temp1 += ecomp;

            // Pearson Nsamp_adj Nsamp_in effN Like
            if (nsamp > 0 && SzFreq_obs_hdr(iobs, 3) && (ecomp != 0.0 && ecomp != 1.0) && nbins > 0 ) // check for values to include
            {
                if (logL_method == 0)
                {
                  show_Pearson = (ocomp - ecomp) / sqrt(ecomp * (1.0 - ecomp) / nsamp ); // Pearson for multinomial
                  show_logL = ocomp * log( (ocomp + 1.0e-12) / ( ecomp + 1.0e-12) ) * nsamp;  //  logL
                }
                if (logL_method == 1 || logL_method == 2)
                {
                  dirichlet_Parm = mfexp(selparm(Comp_Err_parmloc(Comp_Err_Sz2(Sz_method),1)));
                  if (logL_method == 1 )
                    { dirichlet_Parm *= nsamp; }
                  show_Pearson = value((ocomp - ecomp) / sqrt(ecomp * (1.0 - ecomp) / nsamp * (nsamp + dirichlet_Parm) / (1. + dirichlet_Parm))); // Pearson for Dirichlet-multinomial using negative-exponential parameterization
                  show_logL =  -SzFreq_each_offset(iobs) / nbins
                   - value( gammln(nsamp * ocomp + dirichlet_Parm * ecomp) - gammln(dirichlet_Parm * ecomp))
                   - value( ( gammln(dirichlet_Parm) - gammln(nsamp + dirichlet_Parm))) / nbins;
                }
                if (logL_method == 3 )  //  MV Tweedie
                {
                }
                SS_compout << show_Pearson << " " << nsamp << " " << SzFreq_sampleN(iobs) << " " << SzFreq_effN(iobs) << " " << show_logL;
            }
            else // sample size zero or skip
            {
              SS_compout << " NA " << " " << nsamp << " " << SzFreq_sampleN(iobs) << " NA NA "; // placeholder
            }
            // Cum_obs Cum_exp SuprPer Used?
            SS_compout << " " << temp2 << " " << temp1 << " " << anystring <<endl;
          }

 /*
          for (z = z1; z <= z2; z++)
          {
            s_off = 1;
            // The following columns printed by the section:
            // Yr Month Seas Subseas Time Fleet Area Repl. Sexes Kind Part
            // Ageerr Sex Lbin_lo Lbin_hi Bin Obs Exp
            SS_compout << SzFreq_obs_hdr(iobs, 1) << " " << real_month << " " << Show_Time2(ALK_time)(2, 3) << " " << data_time(ALK_time, f, 3) << " " << f << " " << fleet_area(f) << " " << repli << " " << gg << " SIZE " << p << " " << k;
            if (z > SzFreq_Nbins(k))
              s_off = 2;
            SS_compout << " " << s_off << " " << SzFreq_units(k) << " " << SzFreq_scale(k) << " ";
            if (s_off == 1)
            {
              SS_compout << SzFreq_bins1(k, z);
            }
            else
            {
              SS_compout << SzFreq_bins1(k, z - SzFreq_Nbins(k));
            }
            SS_compout << " " << SzFreq_obs(iobs, z) << " " << SzFreq_exp(iobs, z) << " ";
            temp2 += SzFreq_obs(iobs, z);
            temp1 += SzFreq_exp(iobs, z);
            // next add Pearson column
            if (SzFreq_obs_hdr(iobs, 3) > 0)
            {
              if (SzFreq_exp(iobs, z) != 0.0 && SzFreq_exp(iobs, z) != 1.0)
              {
                SS_compout << (SzFreq_obs(iobs, z) - SzFreq_exp(iobs, z)) / sqrt(SzFreq_exp(iobs, z) * (1. - SzFreq_exp(iobs, z)) / SzFreq_sampleN(iobs));
              }
              else
              {
                SS_compout << " NA ";
              }
              // next add the following columns:
              // Nsamp_adj, Nsamp_in (temporarily "NA"), effN
              SS_compout << " " << SzFreq_sampleN(iobs) << " NA " << SzFreq_effN(iobs) << " ";
              // next add Like column
              if (SzFreq_obs(iobs, z) != 0.0 && SzFreq_exp(iobs, z) != 0.0)
              {
                SS_compout << " " << SzFreq_obs(iobs, z) * log(SzFreq_obs(iobs, z) / SzFreq_exp(iobs, z)) * SzFreq_sampleN(iobs);
              }
              else
              {
                SS_compout << " NA ";
              }
            }
            else // sample size zero or skip
            {
              SS_compout << " NA "; // placeholder for Pearson
              SS_compout << " " << SzFreq_sampleN(iobs) << " NA"; // Nsamp_adj and Nsamp_in (NA for now)
              SS_compout << " NA NA "; // placeholder for effN and Like
            }
            // next add the following columns:
            // Cum_obs Cum_exp SuprPer Used?
            SS_compout << " " << temp2 << " " << temp1 << " " << anystring << endl;
            // single row representing info from previous bin-specific rows
            if (z == z2 || z == SzFreq_Nbins(k))
              SS_compout << SzFreq_obs_hdr(iobs, 1) << " " << SzFreq_obs_hdr(iobs, 2) << " " << Show_Time2(ALK_time)(2, 3) << " " << data_time(ALK_time, f, 3) << " " << f << " " << fleet_area(f) << " " << repli << " " << gg << " SIZE " << p << " " << k << " " << s_off << " " << 1 << " " << 2 << endl;
          }
  */
        }
      }
    }

    // Yr Month Seas Subseas Time Fleet Area Repl. Sexes Kind Part Ageerr Sex Lbin_lo Lbin_hi Bin Obs Exp Pearson N effN Like Cum_obs Cum_exp SuprPer Used?
    if (Do_Morphcomp > 0)
    {
      for (iobs = 1; iobs <= Morphcomp_nobs; iobs++)
      {
        N_out++;
        y = Morphcomp_obs(iobs, 1);
        real_month = Morphcomp_obs(iobs, 2);
        ALK_time = Morphcomp_obs(iobs, 5 + 1 + Morphcomp_nmorph);
        f = Morphcomp_obs(iobs, 3);
        k = 5 + Morphcomp_nmorph;
        for (z = 6; z <= k; z++)
        {
          SS_compout << y << " " << real_month << " " << Show_Time2(ALK_time)(2, 3) << " " << data_time(ALK_time, f, 3) << " " << f << " " << fleet_area(f) << " 1  1 "
                     << " GP% ";
          SS_compout << " 0 0 0 0 0 " << z - 5 << " " << Morphcomp_obs(iobs, z) << " " << Morphcomp_exp(iobs, z) << " NA " << Morphcomp_obs(iobs, 5) << " NA NA NA NA _ _ " << endl;
        }
      }
    }

    if (Do_TG > 0)
    {
      for (TG = 1; TG <= N_TG; TG++)
      {
        y = TG_release(TG, 3);
        s = TG_release(TG, 4);
        for (TG_t = 0; TG_t <= TG_endtime(TG); TG_t++)
        {
          N_out++;
          t = styr + (y - styr) * nseas + s - 1;
          temp1 = s - 1.;
          //          temp=float(y)+temp1/float(nseas);
          temp = float(y) + 0.01 * int(100. * (azero_seas(s) + seasdur_half(s)));
          // Fill in columns for: Yr Month Seas Subseas Time Fleet Area Repl. Sexes Kind Part Ageerr Sex Lbin_lo Lbin_hi Bin
          SS_compout << y << " NA " << s << " NA " << temp << " NA " << TG_release(TG, 2) << " " << TG << " " << TG_release(TG, 6) << " TAG2 NA NA NA NA NA " <<
              // TAG2 values (total recaptures)
              // Fill in columns for: Obs Exp Pearson Nsamp_adj Nsamp_in effN Like Cum_obs Cum_exp SuprPer Used?
              TG_t << " " << TG_recap_obs(TG, TG_t, 0) << " " << TG_recap_exp(TG, TG_t, 0) << " NA NA NA NA NA NA NA NA ";
          if (TG_t >= TG_mixperiod && TG_use(TG) >= TG_min_recap)
          {
            SS_compout << "_" << endl;
          }
          else
          {
            SS_compout << " skip" << endl;
          }
          // TAG1 values (proportions for each fleet) associated with the above TAG2 output
          if (Nfleet > 1)
            for (f = 1; f <= Nfleet; f++)
            {
              // Fill in columns for: Yr Month Seas Subseas Time Fleet Area Repl. Sexes Kind Part Ageerr Sex Lbin_lo Lbin_hi
              SS_compout << y << " NA " << s << " NA " << temp << " " << f << " " << fleet_area(f) << " " << TG << " " << TG_release(TG, 6) << " TAG1 NA NA NA NA NA " <<
                  // Fill in columns for:: Bin Obs Exp Pearson Nsamp_adj Nsamp_in
                  f << " " << TG_recap_obs(TG, TG_t, f) << " " << TG_recap_exp(TG, TG_t, f) << " NA " << TG_recap_obs(TG, TG_t, 0) << " NA "
                         << " NA NA NA NA NA "; // NA values are for: effN Like Cum_obs Cum_exp SuprPer
              // Fill in Used? column
              if (TG_t >= TG_mixperiod && TG_use(TG) >= TG_min_recap)
              {
                SS_compout << "_" << endl;
              }
              else
              {
                SS_compout << " skip" << endl;
              }
            }
          s++;
          if (s > nseas)
          {
            s = 1;
            y++;
          }
        }
      }
    }

    if (N_out == 0)
      SS_compout << styr << " -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1" << endl;
    SS_compout << styr << " -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1" << endl
               << " End_comp_data" << endl;
  }

  // REPORT_KEYWORD 53 SELEX_database
  if (pick_report_use(53) == "Y")
  {
    SS2out << endl
           << pick_report_name(53) << endl;
    SS2out << "Fleet Yr Kind Sex Bin Selex" << endl;
    for (f = 1; f <= Nfleet; f++)
      for (y = styr - 3; y <= endyr; y++)
      {
        if (y == styr - 3 || y == endyr || (timevary_sel(y, f) > 0 || timevary_sel(y + 1, f) > 0))
        {
          for (gg = 1; gg <= gender; gg++)
          {
            for (z = 1; z <= nlength; z++)
            {
              SS2out << f << " " << y << " L " << gg << " " << len_bins(z) << " " << sel_l(y, f, gg, z) << endl;
            }
            if (seltype(f, 2) != 0)
            {
              if (gg == 1)
              {
                for (z = 1; z <= nlength; z++)
                {
                  SS2out << f << " " << y << " D " << gg << " " << len_bins(z) << " " << retain(y, f, z) << endl;
                }
              }
              else
              {
                for (z = 1; z <= nlength; z++)
                {
                  SS2out << f << " " << y << " D " << gg << " " << len_bins(z) << " " << retain(y, f, z + nlength) << endl;
                }
              }
            }
            if (seltype(f, 2) == 2)
            {
              if (gg == 1)
              {
                for (z = 1; z <= nlength; z++)
                {
                  SS2out << f << " " << y << " DM " << gg << " " << len_bins(z) << " " << discmort(y, f, z) << endl;
                }
              }
              else
              {
                for (z = 1; z <= nlength; z++)
                {
                  SS2out << f << " " << y << " DM " << gg << " " << len_bins(z) << " " << discmort(y, f, z + nlength) << endl;
                }
              }
            }
          }
        }
        if (timevary_sel(y, f + Nfleet) > 0)
        {
          for (gg = 1; gg <= gender; gg++)
            for (a = 0; a <= nages; a++)
            {
              SS2out << f << " " << y << " A " << gg << " " << a << " " << sel_a(y, f, gg, a) << endl;
            }
        }
      }
    SS2out << " end selex output " << endl;
  } // end do report detail
  wrote_bigreport++;
  //  SS2out.close();
  //  SS_compout.close();
  return;
  } //  end write_bigoutput

FUNCTION void SPR_profile()
  {
  // REPORT_KEYWORD 54 SPR/YPR_Profile
  int SPRloop;
  int bio_t_base;
  dvariable Fmult2 = maxpossF;
  dvariable Fcrash = Fmult2;
  dvariable Fmultchanger0 = Fmult2 / 39.;
  dvariable Fmultchanger1;
  dvariable Fmultchanger2;
  dvariable Btgt_prof;
  dvariable Btgt_prof_rec;
  dvariable SPR_last;
  dvariable SPR_trial;
  dvariable YPR_last;

  SS2out << endl
         << pick_report_name(54) << endl;
  y = styr - 3;
  yz = y;
  bio_yr = y;
  eq_yr = y;
  t_base = y + (y - styr) * nseas - 1;
  bio_t_base = styr + (bio_yr - styr) * nseas - 1;

  //  SPAWN-RECR:  call make_fecundity for benchmark bio for SPR loop
  //  this code section that creates fecundity and selectivity seems antiquated; why is it different from the averages used for benchmark?

  for (s = 1; s <= nseas; s++)
  {
    t = styr - 3 * nseas + s - 1;

    if (MG_active(2) > 0 || MG_active(3) > 0 || save_for_report > 0 || WTage_rd > 0)
    {
      subseas = 1;
      ALK_idx = (s - 1) * N_subseas + subseas; //  for midseason
      Make_AgeLength_Key(s, subseas); //  for begin season
      subseas = mid_subseas;
      ALK_idx = (s - 1) * N_subseas + subseas; //  for midseason
      Make_AgeLength_Key(s, subseas); //  for midseason
      if (s == spawn_seas)
      {
        subseas = spawn_subseas;
        if (spawn_subseas != 1 && spawn_subseas != mid_subseas)
        {
          //don't call get_growth3(subseas) because using an average ave_size
          Make_AgeLength_Key(s, subseas); //  spawn subseas
        }
        get_mat_fec();
      }
    }

    for (g = 1; g <= gmorph; g++)
      if (use_morph(g) > 0)
      {
        ALK_idx = (s - 1) * N_subseas + mid_subseas; //  for midseason
        Make_FishSelex();
      }
  }

  SS2out << "SPRloop Iter Bycatch Fmult F_report SPR YPR_dead YPR_dead*Recr YPR_ret*Recr Revenue Cost Profit SSB Recruits SSB/Bzero Tot_Catch ";
  for (f = 1; f <= Nfleet; f++)
  {
    if (fleet_type(f) <= 2)
      SS2out << " " << fleetname(f) << "(" << f << ")Dead";
  }
  for (f = 1; f <= Nfleet; f++)
  {
    if (fleet_type(f) <= 2)
      SS2out << " " << fleetname(f) << "(" << f << ")Ret";
  }
  for (f = 1; f <= Nfleet; f++)
  {
    if (fleet_type(f) <= 2)
      SS2out << " " << fleetname(f) << "(" << f << ")Age";
  }
  for (p = 1; p <= pop; p++)
    for (gp = 1; gp <= N_GP; gp++)
    {
      SS2out << " SSB_Area:" << p << "_GP:" << gp;
    }
  SS2out << endl;
  equ_Recr = 1.0;
  Fishon = 0;
  int SPRloop1_end;
  if (Do_Benchmark == 3)
  {
    SPRloop1_end = 8;
  }
  else
  {
    SPRloop1_end = 7;
  }
  int SPRloops;
  SS2out << "ready for equilcalc "<<endl;
  Do_Equil_Calc(equ_Recr);
  if (N_bycatch == 0)
  {
    k = 0;
  }
  else
  {
    k = 1;
  }
  SS2out << "ready for loops "<<endl;
  for (int with_BYC = 0; with_BYC <= k; with_BYC++)
    for (int SPRloop1 = 0; SPRloop1 <= SPRloop1_end; SPRloop1++)
    {
      Fmultchanger1 = value(pow(0.0001 / Fcrash, 0.025));
      Fmultchanger2 = value(Fcrash / 39.);
      SPRloops = 40;
      switch (SPRloop1)
      {
        case 0:
        {
          Fmult2 = maxpossF;
          break;
        }
        case 1:
        {
          Fmult2 = Fcrash;
          break;
        }
        case 3:
        {
          Fmult2 = 1;
          SPRloops = 1;
          break;
        }
        case 4:
        {
          Fmult2 = SPR_Fmult;
          SPRloops = 1;
          break;
        }
        case 5:
        {
          Fmult2 = Btgt_Fmult;
          SPRloops = 1;
          break;
        }
        case 6:
        {
          Fmult2 = MSY_Fmult;
          SPRloops = 1;
          break;
        }
        case 8:
        {
          Fmult2 = Btgt_Fmult2;
          SPRloops = 1;
          break;
        }
        case 7:
        {
          Fmult2 = MSY_Fmult;
          SPRloops = 40;
          SPR_trial = value(SSB_equil / SSB_virgin);
          SPR_last = SPR_trial * 2.;
          YPR_last = -1.;
          break;
        }
      }
      for (SPRloop = 1; SPRloop <= SPRloops; SPRloop++)
      {
        if (SPRloop1 == 7 && SPRloop > 1)
        {
          if (F_Method > 1)
          {
            Fmult2 *= 1.05;
          }
          else
          {
            Fmult2 = Fmult2 + (1.0 - Fmult2) * 0.05;
          }
          if (SPR_trial <= 0.001)
            SPRloop = 1001;
          SPR_last = SPR_trial;
          YPR_last = YPR_dead;
        }

        for (f = 1; f <= Nfleet; f++)
          for (s = 1; s <= nseas; s++)
          {
            t = bio_t_base + s;
            if (fleet_type(f) == 1 || (fleet_type(f) == 2 && bycatch_setup(f, 3) == 1))
            {
              if (SPRloop1 != 3)
              {
                Hrate(f, t) = Fmult2 * Bmark_RelF_Use(s, f);
              }
              else
              {
                a = styr + (endyr - styr) * nseas + s - 1;
                Hrate(f, t) = Hrate(f, a);
              }
            }
            else if (fleet_type(f) == 2 && bycatch_setup(f, 3) > 1)
            {
              Hrate(f, t) = double(with_BYC) * bycatch_F(f, s);
            }
            else
            {
              Hrate(f, t) = 0.0;
            }
          }
        Fishon = 1;

        Do_Equil_Calc(equ_Recr);
        //  SPAWN-RECR:   calc equil spawn-recr in the SPR loop
        SPR_temp = SSB_equil;
        Equ_SpawnRecr_Result = Equil_Spawn_Recr_Fxn(SR_parm_work(2), SR_parm_work(3), SSB_unf, Recr_unf, SPR_temp); //  returns 2 element vector containing equilibrium biomass and recruitment at this SPR
        Btgt_prof = Equ_SpawnRecr_Result(1);
        Btgt_prof_rec = Equ_SpawnRecr_Result(2);
        if (Btgt_prof < 0.001 || Btgt_prof_rec < 0.001)
        {
          Btgt_prof_rec = 0.0;
          Btgt_prof = 0.;
          if (SPRloop1 == 0)
            Fcrash = Fmult2;
        }
        SS2out << SPRloop1 << " " << SPRloop << " " << with_BYC << " " << Fmult2 << " " << equ_F_std << " " << SSB_equil / (SSB_unf / Recr_unf) << " " << YPR_dead << " "
               << YPR_dead * Btgt_prof_rec << " " << YPR_ret * Btgt_prof_rec << " " << (PricePerF * YPR_val_vec) * Btgt_prof_rec
               << " " << Cost << " " << (PricePerF * YPR_val_vec) * Btgt_prof_rec - Cost << " " << Btgt_prof << " " << Btgt_prof_rec << " " << Btgt_prof / SSB_unf
               << " " << value(sum(equ_catch_fleet(2)) * Btgt_prof_rec);
        for (f = 1; f <= Nfleet; f++)
          if (fleet_type(f) <= 2)
          {
            temp = 0.0;
            for (s = 1; s <= nseas; s++)
            {
              temp += equ_catch_fleet(2, s, f);
            }
            SS2out << " " << temp * Btgt_prof_rec;
          }
        for (f = 1; f <= Nfleet; f++)
          if (fleet_type(f) <= 2)
          {
            temp = 0.0;
            for (s = 1; s <= nseas; s++)
            {
              temp += equ_catch_fleet(3, s, f);
            }
            SS2out << " " << temp * Btgt_prof_rec;
          }
        //  report mean age of CATCH of non-bycatch fleets
        for (f = 1; f <= Nfleet; f++)
          if (fleet_type(f) <= 2)
          {
            temp = 0.0;
            temp2 = 0;
            for (s = 1; s <= nseas; s++)
              for (g = 1; g <= gmorph; g++)
                if (use_morph(g) > 0)
                {
                  temp += equ_catage(s, f, g) * r_ages;
                  temp2 += sum(equ_catage(s, f, g));
                }
            if (temp2 > 0.0)
            {
              SS2out << " " << temp / temp2;
            }
            else
              SS2out << " NA";
          }

        for (p = 1; p <= pop; p++)
          for (gp = 1; gp <= N_GP; gp++)
          {
            SS2out << " " << SSB_equil_pop_gp(p, gp) * Btgt_prof_rec;
          }
        SS2out << endl;
        if (SPRloop1 == 0)
        {
          Fmult2 -= Fmultchanger0;
          if (Fmult2 < 0.0)
            Fmult2 = 1.0e-6;
        }
        else if (SPRloop1 == 1)
        {
          Fmult2 *= Fmultchanger1;
        }
        else if (SPRloop1 == 2)
        {
          Fmult2 += Fmultchanger2;
        }
      }
    }

  SS2out << "Finish SPR/YPR profile" << endl;
  SS2out << "#Profile 0 is descending additively from max possible F:  " << maxpossF << endl;
  SS2out << "#Profile 1 is descending multiplicatively half of max possible F" << endl;
  SS2out << "#Profile 2 is additive back to Fcrash: " << Fcrash << endl;
  SS2out << "#value 3 uses endyr F, which has different fleet allocation than benchmark" << endl;
  SS2out << "#value 4 is Fspr: " << SPR_Fmult << endl;
  SS2out << "#value 5 is Fbtgt: " << Btgt_Fmult << endl;
  SS2out << "#value 6 is Fmsy: " << MSY_Fmult << endl;
  if (Do_Benchmark == 3)
    SS2out << "#value 8 is F_Blimit: " << Btgt_Fmult2 << endl;
  SS2out << "#Profile 7 increases from Fmsy to Fcrash" << endl;
  SS2out << "#NOTE: meanage_of_catch_is_for_total_catch_of_fleet_type==1_or_bycatch_fleets_with_scaled_Hrate" << endl;
  // end SPR/YPR_Profile
  return;
  }

FUNCTION void Global_MSY()
  {
  // REPORT_KEYWORD 55 GLOBAL_MSY
  //  GLOBAL_MSY with knife-edge age selection, then slot-age selection
  SS2out << endl
         << pick_report_name(55) << endl;
  y = styr - 3; //  stores the averaged
  yz = y;
  bio_yr = y;
  eq_yr = y;
  t_base = y + (y - styr) * nseas - 1;

  for (int MSY_loop = 0; MSY_loop <= 2; MSY_loop++)
  {
    if (MSY_loop == 0)
    {
      SS2out << "#" << endl
             << "ACTUAL_SELECTIVITY_MSY with MSY units as: " << MSY_name << endl;
    }
    else if (MSY_loop == 1)
    {
      SS2out << "#" << endl
             << "KNIFE_AGE_SELECTIVITY_MSY " << endl;
    }
    else
    {
      SS2out << "#" << endl
             << "SLOT_AGE_SELECTIVITY_MSY " << endl;
    }
    SS2out << "------  SPR  SPR SPR SPR SPR SPR SPR SPR SPR # BTGT BTGT BTGT BTGT BTGT BTGT BTGT BTGT   BTGT  BTGT # "
           << "   MSY MSY MSY MSY MSY MSY MSY MSY MSY MSY MSY" << endl
           << "Age SPR  Fmult Fstd   Exploit Recruit SSB Y_dead Y_ret VBIO # SPR   B/B0  Fmult Fstd    Exploit Recruit SSB  Y_dead Y_ret VBIO "
           << " # SPR   B/B0  Fmult Fstd  Exploit Recruit SSB  Y_MSY Y_dead Y_ret VBIO " << endl;

    if (MSY_loop > 0)
    {
      for (int SPRloop1 = 1; SPRloop1 <= nages - 1; SPRloop1++)
      {
        sel_bio.initialize();
        sel_ret_bio.initialize();
        sel_num.initialize();
        sel_ret_num.initialize();
        sel_dead_num.initialize();
        sel_dead_bio.initialize();
        SS2out << SPRloop1 << " ";
        for (s = 1; s <= nseas; s++)
        {
          t = styr - 3 * nseas + s - 1;
          for (g = 1; g <= gmorph; g++)
            if (use_morph(g) > 0)
            {
              for (f = 1; f <= Nfleet; f++)
              {
                if (MSY_loop == 1)
                {
                  sel_bio(s, f, g)(SPRloop1, nages) = Wt_Age_mid(s, g)(SPRloop1, nages); // selected * wt
                  sel_ret_bio(s, f, g)(SPRloop1, nages) = Wt_Age_mid(s, g)(SPRloop1, nages); // selected * retained * wt
                  sel_num(s, f, g)(SPRloop1, nages) = 1.00; // selected numbers
                  sel_ret_num(s, f, g)(SPRloop1, nages) = 1.00; // selected * retained numbers
                  sel_dead_num(s, f, g)(SPRloop1, nages) = 1.00; // sel * (retain + (1-retain)*discmort)
                  sel_dead_bio(s, f, g)(SPRloop1, nages) = Wt_Age_mid(s, g)(SPRloop1, nages); // sel * (retain + (1-retain)*discmort) * wt
                }
                else
                {
                  sel_bio(s, f, g, SPRloop1) = Wt_Age_mid(s, g, SPRloop1); // selected * wt
                  sel_ret_bio(s, f, g, SPRloop1) = Wt_Age_mid(s, g, SPRloop1); // selected * retained * wt
                  sel_num(s, f, g, SPRloop1) = 1.00; // selected numbers
                  sel_ret_num(s, f, g, SPRloop1) = 1.00; // selected * retained numbers
                  sel_dead_num(s, f, g, SPRloop1) = 1.00; // sel * (retain + (1-retain)*discmort)
                  sel_dead_bio(s, f, g, SPRloop1) = Wt_Age_mid(s, g, SPRloop1); // sel * (retain + (1-retain)*discmort) * wt
                }
              }
            }
        }
        show_MSY = 2; //  invokes just brief output in benchmark
        did_MSY = 0;
        Get_Benchmarks(show_MSY);
        did_MSY = 0;
      }
    }
    else
    {
      SS2out << "Actual ";
      show_MSY = 2; //  invokes just brief output in benchmark
      did_MSY = 0;
      Get_Benchmarks(show_MSY);
      did_MSY = 0;
    }
  }
  SS2out << endl;
  return;
  }

//  note that FUNCTION write_Bzero_output() is found in file SS_write.tpl
FUNCTION dvector process_comps(const int sexes, const int sex, dvector& bins, dvector& means, const dvector& tails,
    dvector& obs, dvector& exp)
  {
  dvector more_comp_info(1, 20);
  double cumdist;
  double cumdist_save;
  double temp, temp1, temp2;
  int z;
  more_comp_info.initialize();
  //  sexes is 1 or 2 for numbers of sexes in model
  //  sex is 0, 1, 2, 3 for range of sexes used in this sample
  int nbins = bins.indexmax() / sexes; // find number of bins
  // do both sexes  tails(4) has been set to tails(2) if males not in this sample
  if ((sex == 3 && sexes == 2) || sex == 0 || sexes == 1)
  {
    more_comp_info(1) = obs(tails(1), tails(4)) * means(tails(1), tails(4));
    more_comp_info(2) = exp(tails(1), tails(4)) * means(tails(1), tails(4));
    more_comp_info(3) = more_comp_info(1) - more_comp_info(2);
    //  calc tails of distribution and Durbin-Watson for autocorrelation
    temp1 = 0.0;
    temp2 = 0.0;
    cumdist_save = 0.0;
    cumdist = 0.0;
    for (z = 1; z <= nbins; z++)
    {
      cumdist += exp(z);
      if (sexes == 2)
        cumdist += exp(z + nbins); // add males and females
      if (cumdist >= 0.05 && cumdist_save < 0.05) //  found bin for 5%
      {
        if (z == 1)
        {
          more_comp_info(4) = bins(z);
        } //  set to lower edge
        else
        {
          more_comp_info(4) = bins(z) + (bins(min(z + 1, nbins)) - bins(z)) * (0.05 - cumdist_save) / (cumdist - cumdist_save);
        }
      }
      if (cumdist >= 0.95 && cumdist_save < 0.95) //  found bin for 95%
      {
        more_comp_info(5) = bins(z) + (bins(min(z + 1, nbins)) - bins(z)) * (0.95 - cumdist_save) / (cumdist - cumdist_save);
      }
      cumdist_save = cumdist;

      temp = obs(z) - exp(z); //  obs-exp
      if (z > tails(1))
      {
        more_comp_info(6) += square(temp2 - temp);
        temp1 += square(temp);
      }
      temp2 = temp;
    }

    if (sex == 3 && sexes == 2) // do sex ratio
    {
      more_comp_info(19) = sum(obs(tails(1), tails(2))); //  sum obs female fractions =  %female
      more_comp_info(20) = sum(exp(tails(1), tails(2))); //  sum exp female fractions =  %female
      for (z = tails(3); z <= tails(4); z++)
      {
        temp = obs(z) - exp(z); //  obs-exp
        if (z > tails(3))
        {
          more_comp_info(6) += square(temp2 - temp);
          temp1 += square(temp);
        }
        temp2 = temp;
      }
    }
    more_comp_info(6) = (more_comp_info(6) / temp1) - 2.0;
  }

  if (sex == 1 || (sex == 3 && sexes == 2)) //  need females
  {
    //  where means() holds midpoints of the data length bins
    more_comp_info(7) = (obs(tails(1), tails(2)) * means(tails(1), tails(2))) / sum(obs(tails(1), tails(2)));
    more_comp_info(8) = (exp(tails(1), tails(2)) * means(tails(1), tails(2))) / sum(exp(tails(1), tails(2)));
    more_comp_info(9) = more_comp_info(7) - more_comp_info(8);
    //  calc tails of distribution and Durbin-Watson for autocorrelation
    temp1 = 0.0;
    temp2 = 0.0;
    cumdist_save = 0.0;
    cumdist = 0.0;
    for (z = tails(1); z <= tails(2); z++)
    {
      cumdist += exp(z);
      if (cumdist >= 0.05 * more_comp_info(20) && cumdist_save < 0.05 * more_comp_info(20)) //  found bin for 5%
      {
        if (z == 1)
        {
          more_comp_info(10) = bins(z);
        } //  set to lower edge
        else
        {
          more_comp_info(10) = bins(z) + (bins(min(z + 1, nlen_bin)) - bins(z)) * (0.05 * more_comp_info(20) - cumdist_save) / (cumdist - cumdist_save);
        }
      }
      if (cumdist >= 0.95 * more_comp_info(20) && cumdist_save < 0.95 * more_comp_info(20)) //  found bin for 95%
      {
        more_comp_info(11) = bins(z) + (bins(min(z + 1, nlen_bin)) - bins(z)) * (0.95 * more_comp_info(20) - cumdist_save) / (cumdist - cumdist_save);
      }
      cumdist_save = cumdist;

      temp = obs(z) - exp(z); //  obs-exp
      if (z > tails(1))
      {
        more_comp_info(12) += square(temp2 - temp);
        temp1 += square(temp);
      }
      temp2 = temp; //  save current delta
    }
    more_comp_info(12) = (more_comp_info(12) / temp1) - 2.0;
  }
  if (sex >= 2 && sexes == 2) // need males
  {
    more_comp_info(13) = (obs(tails(3), tails(4)) * means(tails(3), tails(4))) / sum(obs(tails(3), tails(4)));
    more_comp_info(14) = (exp(tails(3), tails(4)) * means(tails(3), tails(4))) / sum(exp(tails(3), tails(4)));
    more_comp_info(15) = more_comp_info(13) - more_comp_info(14);
    //  calc tails of distribution and Durbin-Watson for autocorrelation
    temp1 = 0.0;
    temp2 = 0.;
    cumdist_save = 0.0;
    cumdist = 0.0;
    //  where (1-more_comp_info(20)) is the total of male fractions
    for (z = tails(3); z <= tails(4); z++)
    {
      cumdist += exp(z);
      if (cumdist >= 0.05 * (1.0 - more_comp_info(20)) && cumdist_save < 0.05 * (1.0 - more_comp_info(20))) //  found bin for 5%
      {
        if (z == nbins + 1)
        {
          more_comp_info(16) = bins(z);
        } //  set to lower edge
        else
        {
          more_comp_info(16) = bins(z) + (bins(min(z + 1, 2 * nbins)) - bins(z)) * (0.05 * more_comp_info(20) - cumdist_save) / (cumdist - cumdist_save);
        }
      }
      if (cumdist >= 0.95 * (1.0 - more_comp_info(20)) && cumdist_save < 0.95 * (1.0 - more_comp_info(20))) //  found bin for 95%
      {
        more_comp_info(17) = bins(z) + (bins(min(z + 1, 2 * nbins)) - bins(z)) * (0.95 * (1.0 - more_comp_info(20)) - cumdist_save) / (cumdist - cumdist_save);
      }
      cumdist_save = cumdist;

      temp = obs(z) - exp(z); //  obs-exp
      if (z > tails(3))
      {
        more_comp_info(18) += square(temp2 - temp);
        temp1 += square(temp);
      }
      temp2 = temp; //  save current delta
    }
    more_comp_info(18) = (more_comp_info(18) / temp1) - 2.0;
  }

  return more_comp_info;
  }

FUNCTION int determine_speriod(int s_period, adstring a_string, dvariable var2, dvariable var3)
  {
  if (var2 < 0 && s_period == 0)
  {
    s_period = 1;
    a_string = "Sup";
  }
  else if (var2 < 0 && s_period > 0)
  {
    s_period = 0;
    a_string = "Sup";
  }
  else if (s_period > 0)
  {
    s_period++;
    a_string = "Sup";
  }
  else
  {
    a_string = "_";
  }
  if (var3 < 0)
  {
    a_string += " skip";
  }
  else
  {
    a_string += " _";
  }
  return s_period;
  }
