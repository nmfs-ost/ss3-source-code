// SS_Label_file  #17. **SS_write.tpl**
// SS_Label_file  # * <u>write_summaryoutput()</u>  //  append writes to *cumreport.sso*
// SS_Label_file  # * <u>write_SS_summary()</u>  //  writes *ss_summary.sso*
// SS_Label_file  # * <u>write_rebuilder_output()</u> // special output
// SS_Label_file  # * <u>write_SIStable()</u>  //  deprecated, see new r4ss routines
// SS_Label_file  # * <u>write_Bzero_output()</u>  //
// SS_Label_file  # * <u>Report_Parm()</u>  //  used by write_big_report in writing *report.sso*
// SS_Label_file  #

 /*  SS_Label_FUNCTION 36 write_summaryoutput; Writes in append mode to cumreport.sso */
FUNCTION void write_summaryoutput()
  {
  random_number_generator radm(long(time(&finish)));
  time(&finish);
  elapsed_time = difftime(finish, start);
  report2 << runnumber << " -logL: " << obj_fun << " SSB(Vir_Start_End): " << SSB_yr(styr - 2) << " " << SSB_yr(styr) << " " << SSB_yr(endyr) << endl;
  report2 << runnumber << " Files: " << datfilename << " " << ctlfilename;
  if (readparfile >= 1)
    report2 << " Start_from_ss.par";
  report2 << endl
          << runnumber << " N_iter: " << niter << " runtime(sec): " << elapsed_time << " starttime: " << ctime(&start);
  report2 << runnumber << version_info(1) << version_info(2) << version_info(3) << endl;
  report2 << runnumber << " F_Method: " << F_Method << " Retro_YR: " << retro_yr << " Forecast_Type: " << Do_Forecast << " MSY_Type: " << Do_MSY << endl;
  if (N_SC > 0)
  {
    for (j = 1; j <= N_SC; j++)
      report2 << runnumber << " Comment S_" << j << " " << Starter_Comments(j) << endl;
  }
  if (N_DC > 0)
  {
    for (j = 1; j <= N_DC; j++)
      report2 << runnumber << " Comment D_" << j << " " << Data_Comments(j) << endl;
  }
  if (N_CC > 0)
  {
    for (j = 1; j <= N_CC; j++)
      report2 << runnumber << " Comment C_" << j << " " << Control_Comments(j) << endl;
  }
  if (N_FC > 0)
  {
    for (j = 1; j <= N_FC; j++)
      report2 << runnumber << " Comment F_" << j << " " << Forecast_Comments(j) << endl;
  }
  k = current_phase();
  if (k > max_lambda_phase)
    k = max_lambda_phase;
  report2 << runnumber << " Like_Emph Total 1 " << endl
          << runnumber << " Like_Value Total " << obj_fun << endl;
  if (Svy_N > 0)
    report2 << runnumber << " Like_Emph Indices All " << column(surv_lambda, k) << endl
            << runnumber << " Like_Value Indices " << surv_like * column(surv_lambda, k) << " " << surv_like << endl;
  if (nobs_disc > 0)
    report2 << runnumber << " Like_Emph Discard All " << column(disc_lambda, k) << endl
            << runnumber << " Like_Value Discard " << disc_like * column(disc_lambda, k) << " " << disc_like << endl;
  if (nobs_mnwt > 0)
    report2 << runnumber << " Like_Emph MeanBodyWt All " << column(mnwt_lambda, k) << endl
            << runnumber << " Like_Value MeanBodyWt " << mnwt_like * column(mnwt_lambda, k) << " " << mnwt_like << endl;
  if (Nobs_l_tot > 0)
    report2 << runnumber << " Like_Emph LenComp All " << column(length_lambda, k) << endl
            << runnumber << " Like_Value LenComp " << length_like_tot * column(length_lambda, k) << " " << length_like_tot << endl;
  if (Nobs_a_tot > 0)
    report2 << runnumber << " Like_Emph AgeComp All " << column(age_lambda, k) << endl
            << runnumber << " Like_Value AgeComp " << age_like_tot * column(age_lambda, k) << " " << age_like_tot << endl;
  if (nobs_ms_tot > 0)
    report2 << runnumber << " Like_Emph MeanLAA All " << column(sizeage_lambda, k) << endl
            << runnumber << " Like_Value MeanLAA " << sizeage_like * column(sizeage_lambda, k) << " " << sizeage_like << endl;

  if (F_Method > 1)
    report2 << runnumber << " Like_Emph Catch All " << column(catch_lambda, k) << endl
            << runnumber << " Like_Value Catch " << catch_like * column(catch_lambda, k) << " " << catch_like << endl;

  report2 << runnumber << " Like_Emph init_equ All " << column(init_equ_lambda, k) << endl
          << runnumber << " Like_Value Init_Equ " << equ_catch_like * column(init_equ_lambda, k) << " " << catch_like << endl;

  if (SzFreq_Nmeth > 0)
    report2 << runnumber << " Like_Emph WeightFreq All " << column(SzFreq_lambda, k) << endl
            << runnumber << " Like_Value WeightFreq " << SzFreq_like * column(SzFreq_lambda, k) << " " << SzFreq_like << endl;
  if (Do_Morphcomp > 0)
    report2 << runnumber << " Like_Emph Morphcomp All " << Morphcomp_lambda(k) << endl
            << runnumber << " Like_Value Morphcomp " << Morphcomp_like * Morphcomp_lambda(k) << " " << Morphcomp_like << endl;
  if (Do_TG > 0)
    report2 << runnumber << " Like_Emph Tag_comp All " << column(TG_lambda1, k) << endl
            << runnumber << " Like_Value Tag_comp " << TG_like1 * column(TG_lambda1, k) << " " << TG_like1 << endl;
  if (Do_TG > 0)
    report2 << runnumber << " Like_Emph Tag_negbin All " << column(TG_lambda2, k) << endl
            << runnumber << " Like_Value Tag_negbin " << TG_like2 * column(TG_lambda2, k) << " " << TG_like2 << endl;

  report2 << runnumber << " Like_Comp Recruits Regime Fcast_Recr Biasadj Priors ParmDevs CrashPen" << endl;
  report2 << runnumber << " Like_Emph " << recrdev_lambda(k) << " " << regime_lambda(k) << " " << Fcast_recr_lambda << " "
          << parm_prior_lambda(k) << " " << parm_dev_lambda(k) << " " << CrashPen_lambda(k) << endl;
  report2 << runnumber << " Like_Value*Emph " << recr_like * recrdev_lambda(k) << " " << regime_like * regime_lambda(k) << " "
          << Fcast_recr_like << " " << parm_like * parm_prior_lambda(k) << " " << sum(parm_dev_like) * parm_dev_lambda(k) << " " << CrashPen * CrashPen_lambda(k) << endl;

  report2 << runnumber << " TimeSeries Yr Vir Equ " << years << " ";
  k = YrMax;
  if (k == endyr)
    k = endyr + 1;
  for (y = endyr + 1; y <= k; y++)
  {
    report2 << y << "F ";
  }
  report2 << endl;
  report2 << runnumber << " Timeseries SpawnBio " << SSB_yr(styr - 2, YrMax) << endl;
  report2 << runnumber << " Timeseries Recruit " << column(exp_rec, 4) << endl;
  report2 << runnumber << " Timeseries TotBio " << column(Smry_Table, 1) << endl;
  report2 << runnumber << " Timeseries SmryBio-" << Smry_Age << " " << column(Smry_Table, 2) << endl;
  report2 << runnumber << " Timeseries TotCatch " << column(Smry_Table, 4) << endl;
  report2 << runnumber << " Timeseries RetCatch " << column(Smry_Table, 5) << endl;
  j = 0;
  if (max(Do_Retain) > 0)
    j = 1;
  if (Do_Benchmark > 0)
    report2 << runnumber << " Mgmt_Quant " << Mgmt_quant(1, 6 + j) << endl;

  report2 << runnumber << " Parm Labels ";
  for (i = 1; i <= ParCount; i++)
  {
    report2 << " " << ParmLabel(i);
  }
  report2 << endl;
  report2 << runnumber << " Parm Values ";
  report2 << " " << MGparm << " ";
  if (N_parm_dev > 0)
  {
    for (j = 1; j <= N_parm_dev; j++)
      report2 << parm_dev(j) << " ";
  }
  report2 << SR_parm << " ";
  if (recdev_cycle > 0)
    report2 << recdev_cycle_parm << " ";
  if (recdev_do_early > 0)
    report2 << recdev_early << " ";
  if (do_recdev == 1)
  {
    report2 << recdev1 << " ";
  }
  if (do_recdev == 2)
  {
    report2 << recdev2 << " ";
  }
  if (Do_Forecast > 0)
    report2 << Fcast_recruitments << " ";
  if (Do_Impl_Error > 0)
    report2 << Fcast_impl_error << " ";
  if (N_init_F > 0)
    report2 << init_F << " ";
  if (N_Fparm > 0)
    report2 << " " << F_rate;
  if (Q_Npar2 > 0)
    report2 << Q_parm << " ";
  if (N_selparm2 > 0)
    report2 << selparm << " ";
  //  if(N_selparm_dev>0) report2<<selparm_dev<<" ";
  if (Do_TG > 0)
    report2 << TG_parm << " ";
  report2 << endl;

  NP = 0; // count of number of parameters
  report2 << runnumber << " MG_parm ";
  for (j = 1; j <= N_MGparm2; j++)
  {
    NP++;
    report2 << " " << ParmLabel(NP);
  }
  report2 << endl
          << runnumber << " MG_parm " << MGparm << endl;

  if (N_parm_dev > 0)
  {
    report2 << runnumber << " MG_parm_dev ";
    for (i = 1; i <= N_parm_dev; i++)
    {
      for (j = parm_dev_minyr(i); j <= parm_dev_maxyr(i); j++)
      {
        NP++;
        report2 << " " << ParmLabel(NP);
      }
      report2 << endl
              << runnumber << " MG_parm_dev " << parm_dev(i) << endl;
    }
  }

  report2 << runnumber << " SR_parm ";
  for (i = 1; i <= N_SRparm3 + recdev_cycle; i++)
  {
    NP++;
    report2 << " " << ParmLabel(NP);
  }
  report2 << endl
          << runnumber << " SR_parm " << SR_parm << " ";
  if (recdev_cycle > 0)
    report2 << recdev_cycle_parm;
  report2 << endl;

  if (recdev_do_early > 0)
  {
    report2 << runnumber << " Recr_early ";
    for (i = recdev_early_start; i <= recdev_early_end; i++)
    {
      NP++;
      report2 << " " << ParmLabel(NP);
    }
    report2 << endl
            << runnumber << " Recr_early ";
    for (i = recdev_early_start; i <= recdev_early_end; i++)
      report2 << " " << recdev(i);
    report2 << endl;
  }

  if (do_recdev > 0)
  {
    report2 << runnumber << " Recr_main ";
    for (i = recdev_start; i <= recdev_end; i++)
    {
      NP++;
      report2 << " " << ParmLabel(NP);
    }
    report2 << endl
            << runnumber << " Recr_main ";
    for (i = recdev_start; i <= recdev_end; i++)
      report2 << " " << recdev(i);
    report2 << endl;
  }

  if (Do_Forecast > 0)
  {
    if (do_recdev > 0)
    {
      report2 << runnumber << " Recr_fore ";
      for (i = recdev_end + 1; i <= YrMax; i++)
      {
        NP++;
        report2 << " " << ParmLabel(NP);
      }
      report2 << endl
              << runnumber << " Recr_fore ";
      for (i = recdev_end + 1; i <= YrMax; i++)
        report2 << " " << recdev(i);
      report2 << endl;
    }
    if (Do_Impl_Error > 0)
    {
      report2 << runnumber << " Impl_err ";
      for (i = endyr + 1; i <= YrMax; i++)
      {
        NP++;
        report2 << " " << ParmLabel(NP);
      }
      report2 << endl
              << runnumber << " Impl_err ";
      for (i = endyr + 1; i <= YrMax; i++)
        report2 << " " << Fcast_impl_error(i);
      report2 << endl;
    }
  }

  report2 << runnumber << " init_F ";
  for (i = 1; i <= N_init_F; i++)
  {
    NP++;
    report2 << " " << ParmLabel(NP);
  }
  report2 << endl
          << runnumber << " init_F ";
  for (i = 1; i <= N_init_F; i++)
    report2 << " " << init_F(i);
  report2 << endl;

  if (N_Fparm > 0)
  {
    report2 << runnumber << " F_rate ";
    for (i = 1; i <= N_Fparm; i++)
    {
      NP++;
      report2 << " " << ParmLabel(NP);
    }
    report2 << endl
            << runnumber << " F_rate ";
    for (i = 1; i <= N_Fparm; i++)
      report2 << " " << F_rate(i);
    report2 << endl;
  }

  if (Q_Npar2 > 0)
  {
    report2 << runnumber << " Q_parm ";
    for (i = 1; i <= Q_Npar2; i++)
    {
      NP++;
      report2 << " " << ParmLabel(NP);
    }
    report2 << endl
            << runnumber << " Q_parm ";
    for (i = 1; i <= Q_Npar2; i++)
      report2 << " " << Q_parm(i);
    report2 << endl;
  }

  if (N_selparm2 > 0)
  {
    report2 << runnumber << " Sel_parm ";
    for (i = 1; i <= N_selparm2; i++)
    {
      NP++;
      report2 << " " << ParmLabel(NP);
    }
    report2 << endl
            << runnumber << " Sel_parm " << selparm << endl;
  }

  if (Do_TG > 0)
  {
    report2 << runnumber << " Tag_parm ";
    for (f = 1; f <= 3 * N_TG + 2 * Nfleet1; f++)
    {
      NP++;
      report2 << " " << ParmLabel(NP);
    }
    report2 << endl
            << runnumber << " Tag_parm " << TG_parm << endl;
  }

  if (Do_CumReport == 2)
  {
    if (Svy_N > 0)
      for (f = 1; f <= Nfleet; f++)
        if (Svy_N_fleet(f) > 0)
        {
          report2 << runnumber << " Index:" << f << " Yr ";
          for (i = 1; i <= Svy_N_fleet(f); i++)
          {
            ALK_time = Svy_ALK_time(f, i);
            report2 << data_time(ALK_time, f, 3) << " ";
          }
          report2 << endl
                  << runnumber << " Index:" << f << " OBS " << Svy_obs(f) << endl;
          if (Svy_errtype(f) >= 0) // lognormal or lognormal T_dist
          {
            report2 << runnumber << " Index:" << f << " EXP " << mfexp(Svy_est(f)) << endl;
          }
          else // normal error
          {
            report2 << runnumber << " Index:" << f << " EXP " << Svy_est(f) << endl;
          }
        }

    data_type = 4;
    for (f = 1; f <= Nfleet; f++)
      if (Nobs_l(f) > 0)
      {
        report2 << runnumber << " Len:" << f << " YR ";
        for (i = 1; i <= Nobs_l(f); i++)
        {
          t = Len_time_t(f, i);
          ALK_time = Len_time_ALK(f, i);
          report2 << data_time(ALK_time, f, 3) << " ";
        }
        report2 << endl
                << runnumber << " Len:" << f << " effN " << neff_l(f) << endl;
      }

    data_type = 5;
    for (f = 1; f <= Nfleet; f++)
      if (Nobs_a(f) > 0)
      {
        report2 << runnumber << " Age:" << f << " YR ";
        for (i = 1; i <= Nobs_a(f); i++)
        {
          t = Age_time_t(f, i);
          ALK_time = Age_time_ALK(f, i);
          report2 << data_time(ALK_time, f, 3) << " ";
        }
        report2 << endl
                << runnumber << " Age:" << f << " effN " << neff_a(f) << endl;
      }
  }
  report2 << endl;
  cout << " finished appending to cumreport.sso " << endl;
  }

FUNCTION void write_SS_summary()
  {
  SS_smry.open(sso_pathname + "ss_summary.sso");
  SS_smry << version_info(1) << version_info(2) << version_info(3) << endl;
  SS_smry << datfilename << " #_DataFile " << endl;
  SS_smry << ctlfilename << " #_Control " << endl;
  SS_smry << "Run_Date: " << ctime(&start);
  SS_smry << "Final_phase: " << current_phase() << "  N_iterations: " << niter << endl;
  k = current_phase();
  if (k > max_lambda_phase)
    k = max_lambda_phase;
  SS_smry << "#_LIKELIHOOD " << endl;
  SS_smry << "Label logL*Lambda" << endl;
  SS_smry << "TOTAL_LogL " << obj_fun << endl;
  if (F_Method > 1)
  {
    SS_smry << "Catch " << catch_like * column(catch_lambda, k) << endl;
  }
  if (N_init_F > 0)
    SS_smry << "Equil_catch " << equ_catch_like * column(init_equ_lambda, k) << endl;
  if (Svy_N > 0)
    SS_smry << "Survey " << surv_like * column(surv_lambda, k) << endl;
  if (nobs_disc > 0)
    SS_smry << "Discard " << disc_like * column(disc_lambda, k) << endl;
  if (nobs_mnwt > 0)
    SS_smry << "Mean_body_wt " << mnwt_like * column(mnwt_lambda, k) << endl;
  if (Nobs_l_tot > 0)
    SS_smry << "Length_comp " << length_like_tot * column(length_lambda, k) << endl;
  if (Nobs_a_tot > 0)
    SS_smry << "Age_comp " << age_like_tot * column(age_lambda, k) << endl;
  if (nobs_ms_tot > 0)
    SS_smry << "Size_at_age " << sizeage_like * column(sizeage_lambda, k) << endl;
  if (SzFreq_Nmeth > 0)
    SS_smry << "Gen_Size_Comp " << SzFreq_like * column(SzFreq_lambda, k) << endl;
  if (Do_Morphcomp > 0)
    SS_smry << "Morphcomp " << Morphcomp_lambda(k) * Morphcomp_like << endl;
  if (Do_TG > 0)
  {
    SS_smry << "Tag_Data_1 " << TG_like1 * column(TG_lambda1, k) << endl;
    SS_smry << "Tag_Data_2 " << TG_like2 * column(TG_lambda2, k) << endl;
  }
  SS_smry << "Recruitment " << recr_like * recrdev_lambda(k) << endl;
  SS_smry << "InitEQ_regime " << regime_like * regime_lambda(k) << endl;
  SS_smry << "Sum_recdevs " << sum_recdev << endl;
  SS_smry << "Forecast_Recruitment " << Fcast_recr_like << endl;
  SS_smry << "Parm_priors " << parm_like * parm_prior_lambda(k) << endl;
  SS_smry << "Parm_softbounds " << SoftBoundPen << endl;
  SS_smry << "Parm_devs " << sum(parm_dev_like) * parm_dev_lambda(k) << endl;
  SS_smry << "F_Ballpark " << F_ballpark_lambda(k) * F_ballpark_like << endl;
  SS_smry << "Crash_Pen " << CrashPen_lambda(k) * CrashPen << endl;

  SS_smry << "#_PARAMETERS" << endl
          << "#label value se active? range" << endl;
  NP = 0; // count of number of parameters
  active_count = 0;
  SS_smry << "#_BIOLOGY" << endl;
  for (j = 1; j <= N_MGparm2; j++)
  {
    NP++;
    SS_smry << ParmLabel(NP) << " " << MGparm(j) << " ";
    if (active(MGparm(j)))
    {
      active_count++;
      SS_smry << CoVar(active_count, 1) << " Act ";
    }
    else
    {
      SS_smry << 0.0 << " Fix ";
    }
    SS_smry << (MGparm(j) - MGparm_LO(j)) / (MGparm_HI(j) - MGparm_LO(j) + 1.0e-6) << endl;
  }
  SS_smry << "#_SPAWN_RECR" << endl;
  for (j = 1; j <= N_SRparm3; j++)
  {
    NP++;
    SS_smry << ParmLabel(NP) << " " << SR_parm(j) << " ";
    if (active(SR_parm(j)))
    {
      active_count++;
      SS_smry << CoVar(active_count, 1) << " Act ";
    }
    else
    {
      SS_smry << 0.0 << " Fix ";
    }
    SS_smry << (SR_parm(j) - SR_parm_LO(j)) / (SR_parm_HI(j) - SR_parm_LO(j) + 1.0e-6) << endl;
  }

  if (recdev_cycle > 0)
  {
    for (j = 1; j <= recdev_cycle; j++)
    {
      NP++;
      SS_smry << ParmLabel(NP) << " " << recdev_cycle_parm(j) << " ";
      if (active(recdev_cycle_parm(j)))
      {
        active_count++;
        SS_smry << CoVar(active_count, 1) << " Act ";
      }
      else
      {
        SS_smry << 0.0 << " Fix ";
      }
      SS_smry << (recdev_cycle_parm(j) - recdev_cycle_LO(j)) / (recdev_cycle_HI(j) - recdev_cycle_LO(j) + 1.0e-6) << endl;
    }
  }

  if (recdev_do_early > 0)
  {
    for (j = recdev_early_start; j <= recdev_early_end; j++)
    {
      NP++;
      SS_smry << ParmLabel(NP) << " " << recdev(j) << " ";
      if (active(recdev_early))
      {
        active_count++;
        SS_smry << CoVar(active_count, 1) << " Act ";
      }
      else
      {
        SS_smry << 0.0 << " Fix ";
      }
      SS_smry << (recdev(j) - recdev_LO) / (recdev_HI - recdev_LO + 1.0e-6) << endl;
    }
  }

  if (do_recdev > 0)
  {
    for (j = recdev_start; j <= recdev_end; j++)
    {
      NP++;
      SS_smry << ParmLabel(NP) << " " << recdev(j) << " ";
      if (active(recdev1) || active(recdev2))
      {
        active_count++;
        SS_smry << CoVar(active_count, 1) << " Act ";
      }
      else
      {
        SS_smry << 0.0 << " Fix ";
      }
      SS_smry << (recdev(j) - recdev_LO) / (recdev_HI - recdev_LO + 1.0e-6) << endl;
    }
  }

  if (Do_Forecast > 0 && do_recdev > 0)
  {
    for (j = recdev_end + 1; j <= YrMax; j++)
    {
      NP++;
      SS_smry << ParmLabel(NP) << " " << Fcast_recruitments(j) << " ";
      if (active(Fcast_recruitments))
      {
        active_count++;
        SS_smry << CoVar(active_count, 1) << " Act ";
      }
      else
      {
        SS_smry << 0.0 << " Fix ";
      }
      SS_smry << (Fcast_recruitments(j) - recdev_LO) / (recdev_HI - recdev_LO + 1.0e-6) << endl;
    }

    if (Do_Impl_Error > 0)
    {
      for (j = endyr + 1; j <= YrMax; j++)
      {
        NP++;
        SS_smry << ParmLabel(NP) << " " << Fcast_impl_error(j) << " ";
        if (active(Fcast_impl_error))
        {
          active_count++;
          SS_smry << CoVar(active_count, 1) << " Act ";
        }
        else
        {
          SS_smry << 0.0 << " Fix ";
        }
        SS_smry << (Fcast_impl_error(j) - (-1.)) / (1.0 - (-1.0) + 1.0e-6) << endl;
      }
    }
  }

  if (N_init_F > 0)
  {
    SS_smry << "#_Init_F" << endl;
    for (j = 1; j <= N_init_F; j++)
    {
      NP++;
      SS_smry << ParmLabel(NP) << " " << init_F(j) << " ";
      if (active(init_F(j)))
      {
        active_count++;
        SS_smry << CoVar(active_count, 1) << " Act ";
      }
      else
      {
        SS_smry << 0.0 << " Fix ";
      }
      SS_smry << (init_F(j) - init_F_LO(j)) / (init_F_HI(j) - init_F_LO(j) + 1.0e-6) << endl;
    }
  }

  if (N_Fparm > 0)
  {
    SS_smry << "#_F" << endl;
    for (j = 1; j <= N_Fparm; j++)
    {
      NP++;
      SS_smry << ParmLabel(NP) << " " << F_rate(j) << " ";
      if (active(F_rate(j)))
      {
        active_count++;
        SS_smry << CoVar(active_count, 1) << " Act ";
      }
      else
      {
        SS_smry << 0.0 << " Fix ";
      }
      SS_smry << (F_rate(j) - 0.) / (max_harvest_rate - 0 + 1.0e-6) << endl;
    }
  }

  if (Q_Npar2 > 0)
  {
    SS_smry << "#_Catchability" << endl;
    for (j = 1; j <= Q_Npar2; j++)
    {
      NP++;
      SS_smry << ParmLabel(NP) << " " << Q_parm(j) << " ";
      if (active(Q_parm(j)))
      {
        active_count++;
        SS_smry << CoVar(active_count, 1) << " Act ";
      }
      else
      {
        SS_smry << 0.0 << " Fix ";
      }
      SS_smry << (Q_parm(j) - Q_parm_LO(j)) / (Q_parm_HI(j) - Q_parm_LO(j) + 1.0e-6) << endl;
    }
  }

  SS_smry << "#_Selectivity" << endl;
  if (N_selparm2 > 0)
    for (j = 1; j <= N_selparm2; j++)
    {
      NP++;
      SS_smry << ParmLabel(NP) << " " << selparm(j) << " ";
      if (active(selparm(j)))
      {
        active_count++;
        SS_smry << CoVar(active_count, 1) << " Act ";
      }
      else
      {
        SS_smry << 0.0 << " Fix ";
      }
      SS_smry << (selparm(j) - selparm_LO(j)) / (selparm_HI(j) - selparm_LO(j) + 1.0e-6) << endl;
    }

  if (Do_TG > 0)
  {
    SS_smry << "#_Tag_Recapture" << endl;
    for (j = 1; j <= 3 * N_TG + 2 * Nfleet1; j++)
    {
      NP++;
      SS_smry << ParmLabel(NP) << " " << TG_parm(j) << " ";
      if (active(TG_parm(j)))
      {
        active_count++;
        SS_smry << CoVar(active_count, 1) << " Act ";
      }
      else
      {
        SS_smry << 0.0 << " Fix ";
      }
      SS_smry << (TG_parm(j) - TG_parm_LO(j)) / (TG_parm_HI(j) - TG_parm_LO(j) + 1.0e-6) << endl;
    }
  }

  if (N_parm_dev > 0)
  {
    SS_smry << "#_Parm_Dev" << endl;
    for (i = 1; i <= N_parm_dev; i++)
      for (j = parm_dev_minyr(i); j <= parm_dev_maxyr(i); j++)
      {
        NP++;
        SS_smry << ParmLabel(NP) << " " << parm_dev(i, j) << " ";
        if (parm_dev_PH(i) > 0)
        {
          active_count++;
          SS_smry << CoVar(active_count, 1) << " ACT ";
        }
        else
        {
          SS_smry << 0.0 << " FIX ";
        }
        SS_smry << (parm_dev(i, j) - (-10.)) / (10. - (-10) + 1.0e-6) << endl;
      }
  }

  SS_smry << "#_Derived_Quantities" << endl;
  SS_smry << "#_Spawn_Bio" << endl;
  for (j = 1; j <= N_STD_Yr; j++)
  {
    NP++;
    active_count++;
    SS_smry << ParmLabel(NP) << " " << SSB_std(j) << " " << CoVar(active_count, 1) << endl;
  }

  SS_smry << "#_Recruitment" << endl;
  for (j = 1; j <= N_STD_Yr; j++)
  {
    NP++;
    active_count++;
    SS_smry << ParmLabel(NP) << " " << recr_std(j) << " " << CoVar(active_count, 1) << endl;
  }

  SS_smry << "#_SPR Basis= " << SPR_report_label << endl;
  for (j = 1; j <= N_STD_Yr_Ofish; j++)
  {
    NP++;
    active_count++;
    SS_smry << ParmLabel(NP) << " " << SPR_std(j) << " " << CoVar(active_count, 1) << endl;
  }

  SS_smry << "#_F Basis= " << F_report_label << endl;
  for (j = 1; j <= N_STD_Yr_F; j++)
  {
    NP++;
    active_count++;
    SS_smry << ParmLabel(NP) << " " << F_std(j) << " " << CoVar(active_count, 1) << endl;
  }

  SS_smry << "#_Depletion Basis= " << depletion_basis_label << endl;
  for (j = 1; j <= N_STD_Yr_Dep; j++)
  {
    NP++;
    active_count++;
    SS_smry << ParmLabel(NP) << " " << depletion(j) << " " << CoVar(active_count, 1) << endl;
  }

  SS_smry << "#_Mgmt_Quantity" << endl;
  for (j = 1; j <= N_STD_Mgmt_Quant; j++)
  {
    NP++;
    active_count++;
    SS_smry << ParmLabel(NP) << " " << Mgmt_quant(j) << " " << CoVar(active_count, 1) << endl;
  }

  SS_smry << "#_Extra_stdev" << endl;
  for (j = 1; j <= Extra_Std_N; j++)
  {
    NP++;
    active_count++;
    SS_smry << ParmLabel(NP) << " " << Extra_Std(j) << " " << CoVar(active_count, 1) << endl;
  }

  if (Do_se_smrybio == 0)
  {
    SS_smry << "SmryBio_Virgin " << Smry_Table(styr - 2, 2) << " 0.0" << endl;
    SS_smry << "SmryBio_Initial " << Smry_Table(styr - 1, 2) << " 0.0" << endl;
    for (y = styr; y <= YrMax; y++)
    {
      SS_smry << "SmryBio_" << y << " " << Smry_Table(y, 2) << " 0.0" << endl;
    }
  }

  SS_smry << "#_survey_stdev " << Svy_N_sdreport << endl;
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
          NP++;
          if (Svy_errtype(f) == -1)
          {
            SS_smry << ParmLabel(NP) << " " << Svy_sdreport_est(k) << " " << CoVar(active_count, 1) << " #: " << Svy_est(f, j) << " q: " << Svy_q(f, j) << endl;
          }
          else
          {
            SS_smry << ParmLabel(NP) << " " << Svy_sdreport_est(k) << " " << CoVar(active_count, 1) << " #exp(): " << mfexp(Svy_est(f, j)) << " q: " << Svy_q(f, j) << endl;
          }
        }
      }
    }
  }

  SS_smry << "#_Biomass" << endl;
  SS_smry << "TotBio_Virgin " << Smry_Table(styr - 2, 1) << " 0.0" << endl;
  SS_smry << "TotBio_Initial " << Smry_Table(styr - 1, 1) << " 0.0" << endl;
  for (y = styr; y <= YrMax; y++)
  {
    SS_smry << "TotBio_" << y << " " << Smry_Table(y, 1) << " 0.0" << endl;
  }

  SS_smry << "TotCatch_Virgin " << Smry_Table(styr - 2, 4) << " 0.0" << endl;
  SS_smry << "TotCatch_Initial " << Smry_Table(styr - 1, 4) << " 0.0" << endl;
  for (y = styr; y <= YrMax; y++)
  {
    SS_smry << "TotCatch_" << y << " " << Smry_Table(y, 4) << " 0.0" << endl;
  }

  //    report2 <<runnumber<<" Timeseries TotBio "<<column(Smry_Table,1)<<endl;
  //  report2 <<runnumber<<" Timeseries SmryBio-"<<Smry_Age<<" "<<column(Smry_Table,2)<<endl;
  //  report2 <<runnumber<<" Timeseries TotCatch "<<column(Smry_Table,4)<<endl;
  //  report2 <<runnumber<<" Timeseries RetCatch "<<column(Smry_Table,5)<<endl;

  SS_smry.close();
  echoinput << "Finished SS_summary.sso" << endl;
  return;
  }

//********************************************************************
 /*  SS_Label_FUNCTION 37 write_rebuilder_output */
FUNCTION void write_rebuilder_output()
  {
  if (rundetail > 0 && mceval_counter == 0)
    cout << " produce output for rebuilding package" << endl;
  rebuilder.open(sso_pathname + "rebuild.sso", ios::app);
  rebuild_dat.open(sso_pathname + "rebuild.dat");

  if (mceval_counter == 0) // writing to rebuild.dat
  {
    rebuild_dat << "#Title, #runnumber: " << runnumber << " " << datfilename << " " << ctlfilename << " " << obj_fun << " " << SSB_yr(styr - 2) << " " << SSB_yr(endyr + 1) << " StartTime: " << ctime(&start);
    rebuild_dat << "SSv3_default_rebuild.dat" << endl;
    rebuild_dat << "# Number of sexes" << endl
                << gender << endl;
    rebuild_dat << "# Age range to consider (minimum age; maximum age)" << endl
                << 0 << " " << nages << endl;
    rebuild_dat << "# Number of fleets" << endl
                << Nfleet1 << endl;
    rebuild_dat << "# First year of projection (Yinit)" << endl
                << Rebuild_Yinit << endl;
    rebuild_dat << "# First Year of rebuilding period (Ydecl)" << endl
                << Rebuild_Ydecl << endl;
    rebuild_dat << "# Number of simulations" << endl
                << 1000 << endl;
    rebuild_dat << "# Maximum number of years" << endl
                << 500 << endl;
    rebuild_dat << "# Conduct projections with multiple starting values (0=No;else yes)" << endl
                << 0 << endl;
    rebuild_dat << "# Number of parameter vectors" << endl
                << 1000 << endl;
    rebuild_dat << "# Is the maximum age a plus-group (1=Yes;2=No)" << endl
                << 1 << endl;
    rebuild_dat << "# Generate future recruitments using historical recruitments (1)  historical recruits/spawner (2)  or a stock-recruitment (3)" << endl
                << 3 << endl;
    rebuild_dat << "# Constant fishing mortality (1) or constant Catch (2) projections" << endl
                << 1 << endl;
    rebuild_dat << "# Fishing mortality based on SPR (1) or actual rate (2)" << endl
                << 1 << endl;
    rebuild_dat << "# Pre-specify the year of recovery (or -1) to ignore" << endl
                << -1 << endl;
    rebuild_dat << "# Fecundity-at-age" << endl;
  }

  // stuff written to both rebuild.dat and rebuild.SSO
  //a. "blank line" with run info
  if (mceval_phase())
    rebuilder << "# mceval phase, cnt=" << mceval_counter << ", StartTime: " << ctime(&start);
  else
    rebuilder << "# in maximization mode, StartTime: " << ctime(&start);

  if (mceval_counter == 0)
    rebuild_dat << "#" << age_vector << " #runnumber: " << runnumber << " " << datfilename << " " << ctlfilename << " " << obj_fun << " " << SSB_yr(styr - 2) << " " << SSB_yr(endyr + 1) << endl;

  //b.  fecundity-at-age
  t = styr + (Rebuild_Yinit - styr) * nseas;
  dvar_vector tempvec2(0, nages);
  dvar_vector tempvec3(0, nages);
  tempvec_a.initialize();
  tempvec2.initialize();
  for (p = 1; p <= pop; p++)
    for (g = 1; g <= gmorph; g++)
      if (sx(g) == 1)
      {
        //  NEED to adjust for spawning timing within season
        tempvec_a += elem_prod(fec(g), natage(t + spawn_seas - 1, p, g));
        tempvec2 += natage(t + spawn_seas - 1, p, g);
      }
  tempvec_a = elem_div(tempvec_a, tempvec2);
  rebuilder << tempvec_a << " #female fecundity; weighted by N in year Y_init across morphs and areas" << endl;
  if (mceval_counter == 0)
  {
    rebuild_dat << tempvec_a << " #female fecundity; weighted by N in year Y_init across morphs and areas" << endl;
    rebuild_dat << "# Age specific selectivity and weight adjusted for discard and discard mortality" << endl;
  }

  //c.  Weight-at-age and selectivity-at-age (ordered by sex and fleet).
  // use the deadfish vectors that account for discard and for mortality of discards
  // average across morphs and areas using N_at_Age in year Yinit and across seasons using Fcast_RelF
  for (gg = 1; gg <= gender; gg++)
    for (f = 1; f <= Nfleet1; f++)
    {
      tempvec_a.initialize();
      tempvec2.initialize();
      tempvec3.initialize();
      j = 0;
      for (s = 1; s <= nseas; s++)
        for (p = 1; p <= pop; p++)
          if (fleet_area(f) == p && Fcast_RelF_Use(s, f) > 0.0) // active fishery in this area in endyr
          {
            j = 1;
            for (g = 1; g <= gmorph; g++)
              if (sx(g) == gg)
              {
                tempvec_a += elem_prod(Wt_Age_t(t, f, g), natage(t + s - 1, p, g) * Fcast_RelF_Use(s, f)); // body wt
                tempvec2 += elem_prod(sel_num(s, f, g), natage(t + s - 1, p, g) * Fcast_RelF_Use(s, f)); //no wt
                tempvec3 += natage(t + s - 1, p, g) * Fcast_RelF_Use(s, f);
              }
          }
      if (j == 1)
      {
        tempvec_a = elem_div(tempvec_a, tempvec3);
        tempvec2 = elem_div(tempvec2, tempvec3);
        rebuilder << tempvec_a << " #bodywt for gender,fleet: " << gg << " / " << f << " " << fleetname(f) << endl;
        rebuilder << tempvec2 << " #selex for gender,fleet: " << gg << " / " << f << " " << fleetname(f) << endl;
        if (mceval_counter == 0)
        {
          rebuild_dat << " #wt and selex for gender,fleet: " << gg << " " << f << " " << fleetname(f) << endl;
          rebuild_dat << tempvec_a << endl
                      << tempvec2 << endl;
        }
      }
    }

  //d.  Natural mortality and numbers-at-age for year Yinit  (females then males).
  if (mceval_counter == 0)
    rebuild_dat << "# M and current age-structure in year Yinit: " << Rebuild_Yinit << endl;

  for (gg = 1; gg <= gender; gg++)
  {
    tempvec_a.initialize();
    tempvec2.initialize();
    tempvec3.initialize();
    for (p = 1; p <= pop; p++)
    {
      for (g = 1; g <= gmorph; g++)
        if (sx(g) == gg && use_morph(g) > 0)
        {
          tempvec_a += elem_prod(natM(t, p, GP3(g)), natage(t, p, g));
          tempvec2 += natage(t, p, g); //  note, uses season 1 only
        }
    }
    tempvec_a = elem_div(tempvec_a, tempvec2);
    rebuilder << tempvec_a << " #mean M for year Yinit: " << Rebuild_Yinit << " sex: " << gg << endl;
    rebuilder << tempvec2 << " #numbers for year Yinit: " << Rebuild_Yinit << " sex: " << gg << endl;
    if (mceval_counter == 0)
      rebuild_dat << " # gender = " << gg << endl
                  << tempvec_a << endl
                  << tempvec2 << endl;
  }

  //e.  Numbers-at-age for year Ydecl  (females then males).
  t = styr + (Rebuild_Ydecl - styr) * nseas;
  if (mceval_counter == 0)
    rebuild_dat << "# Age-structure at Ydeclare= " << Rebuild_Ydecl << endl;
  for (gg = 1; gg <= gender; gg++)
  {
    tempvec_a.initialize();
    tempvec2.initialize();
    tempvec3.initialize();
    for (p = 1; p <= pop; p++)
    {
      for (g = 1; g <= gmorph; g++)
        if (sx(g) == gg && use_morph(g) > 0)
        {
          tempvec2 += natage(t, p, g);
        }
    }
    rebuilder << tempvec2 << " #numbers for year Ydeclare: " << Rebuild_Ydecl << " sex: " << gg << endl;
    if (mceval_counter == 0)
      rebuild_dat << tempvec2 << endl;
  }

  k = endyr;
  if (Rebuild_Yinit > k)
    k = Rebuild_Yinit;

  //f. "blank line" used for header for following lines
  rebuilder << "#R0 " << years << " #years" << endl;

  //g. recruitment
  rebuilder << exp_rec(styr - 2, 4) << " ";
  for (y = styr; y <= k; y++)
  {
    rebuilder << exp_rec(k, 4) << " ";
  }
  rebuilder << " #Recruits" << endl;

  //h. spawnbio
  rebuilder << SSB_yr(styr - 2) << " " << SSB_yr(styr, k) << " #SpawnBio" << endl;

  //i. steepness; SigmaR; rho
  rebuilder << SR_parm(2) << " " << sigmaR << " " << SR_parm(N_SRparm2) << " # spawn-recr steepness, sigmaR, autocorr" << endl;

  if (mceval_counter == 0)
  {
    rebuild_dat << "# Year for Tmin Age-structure (set to Ydecl by SS)" << endl
                << Rebuild_Ydecl << endl;

    rebuild_dat << "#  recruitment and biomass" << endl
                << "# Number of historical assessment years" << endl
                << k - styr + 2 << endl;
    rebuild_dat << "# Historical data" << endl
                << "# year recruitment spawner in B0 in R project in R/S project" << endl;
    rebuild_dat << styr - 1 << " " << years;
    if (Rebuild_Yinit > endyr)
      rebuild_dat << " " << Rebuild_Yinit;
    rebuild_dat << " #years (with first value representing R0)" << endl;
    rebuild_dat << exp_rec(styr - 2, 4) << " ";
    for (y = styr; y <= k; y++)
    {
      rebuild_dat << exp_rec(y, 4) << " ";
    }
    rebuild_dat << " #recruits; first value is R0 (virgin)" << endl;
    rebuild_dat << SSB_yr(styr - 2) << " " << SSB_yr(styr, k) << " #spbio; first value is SSB_virgin (virgin)" << endl;
    rebuild_dat << 1 << " ";
    for (y = styr; y <= k; y++)
      rebuild_dat << 0 << " ";
    rebuild_dat << " # in Bzero" << endl;
    rebuild_dat << 0 << " ";
    for (y = styr; y <= k - 3; y++)
      rebuild_dat << 1 << " ";
    rebuild_dat << " 0 0 0 # in R project" << endl;
    rebuild_dat << 0 << " ";
    for (y = styr; y <= k - 3; y++)
      rebuild_dat << 1 << " ";
    rebuild_dat << " 0 0 0 # in R/S project" << endl;
    rebuild_dat << "# Number of years with pre-specified catches" << endl
                << 0 << endl;
    rebuild_dat << "# catches for years with pre-specified catches go next" << endl;
    //      rebuild_dat<<"# Number of future recruitments to override"<<endl<<0<<endl;
    //      rebuild_dat<<"# Process for overiding (-1 for average otherwise index in data list)"<<endl;

    rebuild_dat << "# Number of future recruitments to override" << endl;
    rebuild_dat << Rebuild_Yinit - Rebuild_Ydecl << endl;
    rebuild_dat << "# Process for overiding (-1 for average otherwise index in data list)" << endl;
    if (Rebuild_Yinit >= Rebuild_Ydecl + 1)
    {
      for (y = Rebuild_Ydecl + 1; y <= Rebuild_Yinit; y++)
        rebuild_dat << y << " " << 1 << " " << y << endl;
    }

    rebuild_dat << "# Which probability to product detailed results for (1=0.5; 2=0.6; etc.)" << endl
                << 3 << endl;
    rebuild_dat << "# Steepness sigma-R Auto-correlation" << endl
                << SR_parm(2) << " " << sigmaR << " " << 0 << endl;
    rebuild_dat << "# Target SPR rate (FMSY Proxy); manually change to SPR_MSY if not using SPR_target" << endl
                << SPR_target << endl;
    rebuild_dat << "# Discount rate (for cumulative catch)" << endl
                << 0.1 << endl;
    rebuild_dat << "# Truncate the series when 0.4B0 is reached (1=Yes)" << endl
                << 0 << endl;
    rebuild_dat << "# Set F to FMSY once 0.4B0 is reached (1=Yes)" << endl
                << 0 << endl;
    rebuild_dat << "# Maximum possible F for projection (-1 to set to FMSY)" << endl
                << -1 << endl;
    rebuild_dat << "# Defintion of recovery (1=now only;2=now or before)" << endl
                << 2 << endl;
    rebuild_dat << "# Projection type" << endl
                << 4 << endl;
    rebuild_dat << "# Definition of the 40-10 rule" << endl
                << 10 << " " << 40 << endl;
    rebuild_dat << "# Sigma Assessment Error (Base, Year1, Slope, MaxSigma)" << endl
                << "1.0 " << endyr + 1 << " 0.075 2.0" << endl;
    rebuild_dat << "# Pstar" << endl
                << 0.45 << endl;
    rebuild_dat << "# Constrain catches by the ABC (1=yes, 2=no)" << endl
                << 2 << endl;
    rebuild_dat << "# Implementation Error (0=no; 1=lognormal; 2=uniform)" << endl
                << 0 << endl;
    rebuild_dat << "#Parameters of Implementaion Error" << endl
                << "1 0.3" << endl;
    rebuild_dat << "# Calculate coefficients of variation (1=Yes)" << endl
                << 0 << endl;
    rebuild_dat << "# Number of replicates to use" << endl
                << 10 << endl;
    rebuild_dat << "# Random number seed" << endl
                << -99004 << endl;
    rebuild_dat << "# File with multiple parameter vectors " << endl
                << "rebuild.SSO" << endl;
    rebuild_dat << "# User-specific projection (1=Yes); Output replaced (1->9)" << endl
                << "0  5" << endl;
    rebuild_dat << "# Catches and Fs (Year; 1/2/3 (F or C or SPR); value); Final row is -1" << endl;
    rebuild_dat << k << " 1 1" << endl
                << "-1 -1 -1" << endl;
    rebuild_dat << "# Fixed catch project (1=Yes); Output replaced (1->9); Approach (-1=Read in else 1-9)" << endl;
    rebuild_dat << "0 2 -1" << endl;
    rebuild_dat << "# (48a) Special catch options (1-Yes) [CUT_OFF, Emsy, distribution, MAXCAT, Add, replace_code]" << endl
                << "0 0.18 1.00 1.00 0 6" << endl;
    rebuild_dat << "# (48b) B1Target" << endl
                << 150000 << endl;
    tempvec_a(1, Nfleet) = colsum(Fcast_RelF_Use);
    rebuild_dat << "# Split of Fs" << endl;
    rebuild_dat << Rebuild_Yinit << " ";
    for (f = 1; f <= Nfleet; f++)
      if (fleet_type(f) <= 2)
      {
        rebuild_dat << " " << tempvec_a(f) << endl;
      }
    rebuild_dat << "-1 ";
    for (f = 1; f <= Nfleet; f++)
      rebuild_dat << " 1";
    rebuild_dat << endl;
    rebuild_dat << "# Yrs to define T_target for projection type 4 (a.k.a. 5 pre-specified inputs)" << endl;
    rebuild_dat << endyr + 6 << " " << endyr + 7 << " " << endyr + 8 << " " << endyr + 9 << " " << endyr + 10 << " " << endl;
    rebuild_dat << "# Year for probability of recovery" << endl;
    rebuild_dat << endyr + 10 << " " << endyr + 11 << " " << endyr + 12 << " " << endyr + 13 << " " << endyr + 14 << " " << endyr + 15 << " " << endyr + 16 << " " << endyr + 17 << endl;
    rebuild_dat << "# Time varying weight-at-age (1=Yes;0=No)" << endl
                << 0 << endl;
    rebuild_dat << "# File with time series of weight-at-age data" << endl
                << "none" << endl;
    rebuild_dat << "# Use bisection (0) or linear interpolation (1)" << endl
                << 1 << endl;
    rebuild_dat << "# Target Depletion" << endl
                << 0.4 << endl;
    rebuild_dat << "# CV of implementation error" << endl
                << 0 << endl;
  }
  } //  end output of rebuilding quantities

FUNCTION void write_SIStable() //Note: deprecated, but add a message for now.
  {
  SIS_table.open(sso_pathname + "SIS_table.sso");
  SIS_table << "Note: SIS_table.sso is deprecated, please use the r4ss function get_SIS_info() instead" << endl;
  }
//********************************************************************
 /*  SS_Label_FUNCTION 41 write_Bzero_output */
FUNCTION void write_Bzero_output()
  {
  //  output annual time series for beginning of year and summing across areas for each GP and gender
  if (SS2out.is_open())
    SS2out.close();
  SS2out.open(report_sso_filename, ios::app);
  for (fishery_on_off = 1; fishery_on_off >= 0; fishery_on_off--)
  {

    /*
   in first pass, fishery is on (1) so just report current values
   in second pass, rerun the time series with no fishery, then do the same reporting
   */
    SS2out << endl
           << pick_report_name(59) << endl;
    SS2out << "Spawning_Biomass_Report";
    if (fishery_on_off == 0)
    {
      SS2out << "_1 No_fishery_for_Z=M_and_dynamic_Bzero";
    }
    else
    {
      SS2out << "_2 With_fishery";
    }
    SS2out << endl
           << "Yr Area: ";
    for (p = 1; p <= pop; p++)
      for (gp = 1; gp <= N_GP; gp++)
      {
        SS2out << p << " ";
      }
    SS2out << endl
           << "xxxx GP: ";
    for (p = 1; p <= pop; p++)
      for (gp = 1; gp <= N_GP; gp++)
      {
        SS2out << gp << " ";
      }
    SS2out << endl;

    if (fishery_on_off == 0)
    {
      setup_recdevs();
      get_initial_conditions();
      get_time_series(); //  in write_big_report

      if (Do_Forecast > 0)
      {
        show_MSY = 0;
        report5 << "#" << endl
                << " FORECAST: in Bzero report with fishery onoff= " << fishery_on_off << endl;
        Get_Forecast();
      }
    }

    for (y = styr - 2; y <= YrMax; y++)
    {
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
      for (p = 1; p <= pop; p++)
        for (gp = 1; gp <= N_GP; gp++)
        {
          SS2out << " " << SSB_pop_gp(y, p, gp);
        }
      SS2out << endl;
    }

    SS2out << endl
           << "NUMBERS_AT_AGE_Annual";
    if (fishery_on_off == 0)
    {
      SS2out << "_1 No_fishery_for_Z=M_and_dynamic_Bzero";
    }
    else
    {
      SS2out << "_2 With_fishery";
    }
    SS2out << endl;
    SS2out << "Bio_Pattern Sex Yr " << age_vector << endl;
    dvector tempvec2(1, nages); // holds summed survivors
    tempvec2.initialize();
    for (gg = 1; gg <= gender; gg++)
      for (gp = 1; gp <= N_GP; gp++)
        for (y = styr; y <= YrMax; y++)
        {
          tempvec_a.initialize();
          t = styr + (y - styr) * nseas; // first season only
          for (p = 1; p <= pop; p++)
            for (g = 1; g <= gmorph; g++)
              if (use_morph(g) > 0 && GP4(g) == gp && sx(g) == gg)
              {
                tempvec_a += value(natage(t, p, g));
                if (nseas > 1)
                {
                  //  add in age 0 fish recruiting in later seasons
                  for (s = 2; s <= nseas; s++)
                    if (Bseas(g) == s)
                      tempvec_a(0) += value(natage(t + s - 1, p, g, 0));
                }
              }
          SS2out << gp << " " << gg << " " << y << " " << tempvec_a << endl;
        }
    SS2out << endl
           << "Z_AT_AGE_Annual";
    if (fishery_on_off == 0)
    {
      SS2out << "_1 No_fishery_for_Z=M_and_dynamic_Bzero";
    }
    else
    {
      SS2out << "_2 With_fishery";
    }
    if (Hermaphro_Option != 0)
      SS2out << ";_hermaphrodites_combined_sex_output";
    if (N_pred > 0 && fishery_on_off == 0)
      SS2out << ";_reported_M_includes_PredM2";
    SS2out << endl;
    SS2out << "Bio_Pattern Sex Yr " << age_vector << endl;
    for (gg = 1; gg <= gender; gg++)
      for (gp = 1; gp <= N_GP; gp++)
      {
        tempvec2.initialize();
        for (y = styr; y <= YrMax; y++)
        {
          tempvec_a.initialize();
          t = styr + (y - styr) * nseas; // first season only
          for (p = 1; p <= pop; p++)
            for (g = 1; g <= gmorph; g++)
              if (use_morph(g) > 0 && GP4(g) == gp && sx(g) == gg)
              {
                tempvec_a += value(natage(t, p, g));
                if (nseas > 1)
                {
                  for (s = 2; s <= nseas; s++)
                    if (Bseas(g) == s)
                    {
                      tempvec_a(0) += value(natage(t + s - 1, p, g, 0));
                    }
                }
              }
          if (y > styr)
          {
            SS2out << gp << " " << gg << " " << y - 1 << " " << log(elem_div(tempvec2(1, nages), tempvec_a(1, nages))) << " _ " << endl;
          }
          for (a = 0; a <= nages - 1; a++)
            tempvec2(a + 1) = value(tempvec_a(a));
          tempvec2(nages) += value(tempvec_a(nages));
        }
      }

    SS2out << endl
           << "Report_Z_by_area_morph_platoon";
    if (fishery_on_off == 0)
    {
      SS2out << "_1 No_fishery_for_Z=M_and_dynamic_Bzero";
    }
    else
    {
      SS2out << "_2 With_fishery";
    }
    SS2out << endl;
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
              SS2out << p << " " << GP4(g) << " " << sx(g) << " " << Bseas(g) << " " << settle_g(g) << " " << GP2(g) << " " << g << " " << y << " " << s << " " << temp << " _ ";
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
              SS2out << Z_rate(t, p, g) << endl;
            }
        }
  }
  SS2out << " Note:  Z calculated as -ln(Nt+1 / Nt)" << endl;
  SS2out << " Note:  Z calculation for maxage not possible, for maxage-1 includes numbers at maxage, so is approximate" << endl;
  if (nseas > 1)
    SS2out << " Z for age zero fish is not correct here if recruitment occurs in season after season 1" << endl;

  fishery_on_off = 1;
  /*
    SS2out<<endl<<"Report_Z_by_area_morph_platoon"<<endl;

    for (fishery_on_off=1;fishery_on_off>=0;fishery_on_off--)
    {
    if(fishery_on_off==0) {SS2out<<"_1 No_fishery_for_Z=M";} else {SS2out<<"_2 With_fishery";}
      save_gparm=0;
        setup_recdevs();
        get_initial_conditions();
        get_time_series();  //  in write_big_report
        if(Do_Forecast>0)
        {
          show_MSY=0;
          report5<<"#"<<endl<<" FORECAST: in M & Z report with fishery onoff= "<<fishery_on_off<<endl;
          Get_Forecast();
        }
    SS2out <<endl<<"Area Bio_Pattern Sex BirthSeas Settlement Platoon Morph Yr Seas Time Beg/Mid Era"<<age_vector <<endl;
    for (p=1;p<=pop;p++)
    for (g=1;g<=gmorph;g++)
    if(use_morph(g)>0)
      {
      for (y=styr-2;y<=YrMax;y++)
      for (s=1;s<=nseas;s++)
      {
       t = styr+(y-styr)*nseas+s-1;
       temp=double(y)+azero_seas(s);
       SS2out <<p<<" "<<GP4(g)<<" "<<sx(g)<<" "<<Bseas(g)<<" "<<settle_g(g)<<" "<<GP2(g)<<" "<<g<<" "<<y<<" "<<s<<" "<<temp<<" _ ";
       if(y==styr-2)
         {SS2out<<" VIRG ";}
       if(y==styr-1)
         {SS2out<<" INIT ";}
       else if (y<=endyr)
         {SS2out<<" TIME ";}
       else
         {SS2out<<" FORE ";}
       SS2out<<Z_rate(t,p,g)<<endl;
      }
      }
    }
  */
  return;
  } //  end write Z report

//********************************************************************
 /*  SS_Label_FUNCTION 28 Report_Parm */
FUNCTION void Report_Parm(const int NParm, const int AC, const int Activ, const prevariable& Pval, const double& Pmin, const double& Pmax, const double& RD, const double& Jitter, const double& PR, const double& CV, const int PR_T, const int PH, const prevariable& Like)
  {
  dvar_vector parm_val(1, 14);
  dvar_vector prior_val(1, 14);
  int i;
  dvariable parmvar, parmgrad;
  parmvar = 0.0;
  parmgrad = 0.0;
  SS2out << NParm << " " << ParmLabel(NParm) << " " << Pval;
  if (Activ > 0)
  {
    parmvar = CoVar(AC, 1);
    parmgrad = parm_gradients(AC);

    SS2out << " " << AC << " " << PH << " " << Pmin << " " << Pmax << " " << RD << " " << Jitter;
    if (Pval == RD)
    {
      SS2out << " NO_MOVE ";
    }
    else
    {
      temp = (Pval - Pmin) / (Pmax - Pmin);
      if (temp == 0.0 || temp == 1.0)
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
      else
      {
        SS2out << " OK ";
      }
    }
    SS2out << " " << parmvar;

    SS2out << " " << parmgrad;
  }
  else
  {
    SS2out << " _ " << PH << " " << Pmin << " " << Pmax << " " << RD << " " << Jitter << " NA _ _ ";
  }
  if (PR_T > 0)
  {
    switch (PR_T)
    {
      case 6:
      {
        SS2out << " Normal ";
        break;
      }
      case 1:
      {
        SS2out << " Sym_Beta ";
        break;
      }
      case 2:
      {
        SS2out << " Full_Beta ";
        break;
      }
      case 3:
      {
        SS2out << " Log_Norm ";
        break;
      }
      case 4:
      {
        SS2out << " Log_Norm_w/biasadj ";
        break;
      }
      case 5:
      {
        SS2out << " Gamma ";
        break;
      }
    }
    SS2out << " " << PR << " " << CV << " " << Like << " ";
    i = 1;
    parm_val(i) = Pval;
    prior_val(i) = Get_Prior(PR_T, Pmin, Pmax, PR, CV, Pval);
    i = 2;
    temp = Pval - 1.96 * parmvar;
    if (temp < Pmin)
      temp = Pmin;
    parm_val(i) = temp;
    prior_val(i) = Get_Prior(PR_T, Pmin, Pmax, PR, CV, temp);

    i = 3;
    temp = Pval + 1.96 * parmvar;
    if (temp > Pmax)
      temp = Pmax;
    parm_val(i) = temp;
    prior_val(i) = Get_Prior(PR_T, Pmin, Pmax, PR, CV, temp);

    i = 4;
    temp = Pmin + 0.01 * (Pmax - Pmin);
    parm_val(i) = temp;
    prior_val(i) = Get_Prior(PR_T, Pmin, Pmax, PR, CV, temp);
    i = 14;
    temp = Pmax - 0.01 * (Pmax - Pmin);
    parm_val(i) = temp;
    prior_val(i) = Get_Prior(PR_T, Pmin, Pmax, PR, CV, temp);

    for (int i = 5; i <= 13; i++)
    {
      temp = Pmin + float(i - 4) / 10.0 * (Pmax - Pmin);
      parm_val(i) = temp;
      prior_val(i) = Get_Prior(PR_T, Pmin, Pmax, PR, CV, temp);
    }
    SS2out << parm_val << " " << prior_val;
  }
  else
  {
    SS2out << " No_prior ";
  }
  SS2out << endl;
  }

