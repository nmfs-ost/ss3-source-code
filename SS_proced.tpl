// SS_Label_file  #8. **SS_proced.tpl**
// SS_Label_file  # - <div style="color: #ff0000">PROCEDURE_SECTION</div>
// SS_Label_file  #
// SS_Label_file  #     - do iterations under control of ADMB, in each iteration, call:  <u>setup_recdevs()</u>, <u>get_initial_conditions()</u>, <u>get_time_series()</u>, <u>evaluate_the_objective_function()</u>
// SS_Label_file  #     - writes to *parmtrace.sso*
// SS_Label_file  #     - calls <u>get_posteriors()</u>  //  to write to *posteriors.sso*
// SS_Label_file  #     - upon reaching convergence, or if in mceval, do Dynamic_Bzero by calling those functions again with fishery_on_off=0
// SS_Label_file  #
// SS_Label_file  #  - call <u>setup_Benchmark(), Get_Benchmark(), Get_Forecast()</u>

// ****************************************************************************************************************
//  SS_Label_Section_7.0 #PROCEDURE_SECTION
PROCEDURE_SECTION
  {
  Mgmt_quant.initialize();
  Extra_Std.initialize();
  CrashPen.initialize();
  niter++;
  if (mceval_phase())
    mceval_counter++; // increment the counter

  if (initial_params::mc_phase == 1) //  in MCMC phase
  {
    if (mcmc_counter == 0)
    {
      SR_parm(1) += MCMC_bump;
      cout << mcmc_counter << "   adjusted SR_parm in first mcmc call " << SR_parm(1) << "  by  " << MCMC_bump << endl;
    }

    mcmc_counter++;
  }

  if (mcmcFlag == 1) //  so will do mcmc this run or is in mceval
  {
    if (Do_ParmTrace == 1)
      Do_ParmTrace = 4; // to get all iterations
    if (Do_ParmTrace == 2)
      Do_ParmTrace = 3; // to get all iterations
    if (mcmc_counter > 10 || mceval_counter > 10)
      Do_ParmTrace = 0;
  }

  //  SS_Label_Info_7.3 #get Hrate from the parameter vector F_rate
  //  note that in SS_global  BETWEEN_PHASES is where F_rate, which is the parameter, gets assigned a starting value Hrate from Hrate calculated by hybrid in previous PH
  //  be careful about phases for when this mapping occurs for a whole fleet, versus estimation phase which can be value specific
  if (N_Fparm > 0)
  {
    //      if(current_phase()>=F_parm_PH || (readparfile==1 && current_phase()<=1)) //  set Hrate = Frate parameters on first call if readparfile=1, or for advanced phases
    for (f = 1; f <= Nfleet; f++)
    {
      if(Fparm_loc_st(f)>0)
      for (g = Fparm_loc_st(f); g <= Fparm_loc_end(f); g++)
      {
        t = Fparm_loc[g](2);
        if (F_PH_time(f, t) >= current_phase() && F_PH_time(f,t) < 99)
        {
          if(t==1970)  warning<< " proced "<<t<<" "<<f<<" H_rate: "<<Hrate(f, t) << " parm " << F_rate(g) << endl;
          Hrate(f, t) = F_rate(g);
        }
      }
    }
  }

  //  SS_Label_Info_7.4 #Do the time series calculations
  if (mceval_counter == 0 || (mceval_counter > burn_intvl && ((double(mceval_counter) / double(thin_intvl)) - double((mceval_counter / thin_intvl)) == 0))) // check to see if burn in period is over
  {

    //  create bigsaver to simplfy some condition statements later
    if ((save_for_report > 0) || ((sd_phase() || mceval_phase()) && (initial_params::mc_phase == 0))) // (SAVE || ( (SD || EVAL) && (!MCMC) ) )
    {
      bigsaver = 1;
    }
    else
    {
      bigsaver = 0;
    }
    warning << " begin "<<endl;
    setup_recdevs();
    y = styr;
    //  SS_Label_Info_7.4.1 #Call fxn get_initial_conditions() to get the virgin and initial equilibrium population
    get_initial_conditions();
    if (do_once == 1)
      echoinput << "Finished initial_conditions" << endl;
    //  SS_Label_Info_7.4.2 #Call fxn get_time_series() to do population calculations for each year and get expected values for observations
    warning<<" start time series"<<endl;
    get_time_series(); //  in procedure_section
    if (do_once == 1)
    {
      echoinput << "Finished time_series" << endl;
    }

    //  SS_Label_Info_7.4.3 #Call fxn evaluate_the_objective_function()
    evaluate_the_objective_function();

    //  SS_Label_Info_7.6 #If sdphase or mcevalphase, do benchmarks and forecast and derived quantities
    if ((sd_phase() || mceval_phase()) && (initial_params::mc_phase == 0))
    {

      //  SS_Label_Info_7.6.1 #Call fxn Get_Benchmarks()
      if (Do_Benchmark > 0)
      {
        did_MSY = 0; // so that benchmarks will get calculated here
        setup_Benchmark();
        Get_Benchmarks(show_MSY);
      }
      did_MSY = 1; //  set flag to not calculate the benchmarks again in final section

      if (Do_Dyn_Bzero > 0) //  do dynamic Bzero
      {
        fishery_on_off = 0;
        setup_recdevs();
        y = styr;
        get_initial_conditions();
        get_time_series();
        if (Do_Forecast > 0)
        {
          show_MSY = 0;
          Get_Forecast();
        }
        k = Do_Dyn_Bzero;
        for (j = styr - 2; j <= YrMax; j++)
        {
          Extra_Std(k) = SSB_yr(j);
          k++;
        }
        if (More_Std_Input(12) == 2)
        {
          for (j = styr - 2; j <= YrMax; j++)
          {
            Extra_Std(k) = exp_rec(j, 4);
            k++;
          }
        }
      } //  end dynamic Bzero calculations, will write after big report

      fishery_on_off = 1;
      if (mceval_phase() > 0)
        save_for_report = 1;
      if (mceval_phase() == 0)
      {
        show_MSY = 1;
      } //  so only show details if not in mceval
      if (show_MSY == 1)
      {
        echoinput << "Start benchmark and forecast, if requested" << endl;
      }
      setup_recdevs();
      y = styr;
      get_initial_conditions();
      get_time_series(); //  in write_big_report
      evaluate_the_objective_function();
      if (Do_Benchmark > 0)
      {
        setup_Benchmark();
        Get_Benchmarks(show_MSY);
      }

      //  SS_Label_Info_7.6.2 #Call fxn Get_Forecast()
      if (Do_Forecast > 0)
      {
        if (show_MSY == 1)
          report5 << "THIS FORECAST FOR PURPOSES OF STD REPORTING" << endl; // controls writing to forecast-report.sso
        Get_Forecast();
      }

      //  SS_Label_Info_7.7 #Call fxn Process_STDquant() to move calculated values into sd_containers
      Process_STDquant();
      if (mceval_phase() == 0)
      {
        echoinput << "Finished benchmark, forecast, and sdreporting" << endl;
      }
    } // end of things to do in std_phase

    //  SS_Label_Info_7.9 #Do screen output of procedure results from this iteration
    if (current_phase() <= max_phase + 1)
      phase_output(current_phase()) = value(obj_fun);
    if (rundetail > 1)
    {
      if (Svy_N > 0)
        cout << " CPUE " << surv_like << endl;
      if (nobs_disc > 0)
        cout << " Disc " << disc_like << endl;
      if (nobs_mnwt > 0)
        cout << " MnWt " << mnwt_like << endl;
      if (Nobs_l_tot > 0)
        cout << " Length  " << length_like_tot << endl;
      if (Nobs_a_tot > 0)
        cout << " AGE  " << age_like_tot << endl;
      if (nobs_ms_tot > 0)
        cout << " L-at-A  " << sizeage_like << endl;
      if (SzFreq_Nmeth > 0)
        cout << " sizefreq " << SzFreq_like << endl;
      if (Do_TG > 0)
        cout << " TG-fleetcomp " << TG_like1 << endl
             << " TG-negbin " << TG_like2 << endl;
      cout << " Recr " << recr_like << "  sum_recdev: " << sum_recdev << endl;
      cout << " InitEQ_Regime " << regime_like << endl;
      cout << " Parm_Priors " << parm_like << endl;
      cout << " Parm_devs " << parm_dev_like << endl;
      cout << " SoftBound " << SoftBoundPen << endl;
      cout << " F_ballpark " << F_ballpark_like << endl;
      if (F_Method > 1)
      {
        cout << "Catch " << sum(catch_like) << endl;
      }
      cout << " EQUL_catch " << sum(equ_catch_like) << endl;
      cout << "  crash " << CrashPen << endl;
    }
    if (rundetail > 0)
    {
      temp = norm2(recdev(recdev_start, recdev_end));
      temp = sqrt((temp + 0.0000001) / (double(recdev_end - recdev_start + 1)));
      if (mcmc_counter == 0 && mceval_counter == 0)
      {
        cout << current_phase() << " " << niter << " -log(L): " << obj_fun << "  Spbio: " << value(SSB_yr(styr)) << " " << value(SSB_yr(endyr));
      }
      else if (mcmc_counter > 0)
      {
        cout << " MCMC: " << mcmc_counter << " -log(L): " << obj_fun << "  Spbio: " << value(SSB_yr(styr)) << " " << value(SSB_yr(endyr));
      }
      else if (mceval_counter > 0)
      {
        cout << " MCeval: " << mceval_counter << " -log(L): " << obj_fun << "  Spbio: " << value(SSB_yr(styr)) << " " << value(SSB_yr(endyr));
      }
      if (F_Method > 1 && sum(catch_like) > 0.01)
      {
        cout << " cat " << sum(catch_like);
      }
      else if (CrashPen > 0.01)
      {
        cout << "  crash " << CrashPen;
      }
      cout << endl;
    }
    //  SS_Label_Info_7.10 #Write parameter values to ParmTrace
    if ((Do_ParmTrace == 1 && obj_fun <= last_objfun) || Do_ParmTrace == 4) // only report active parameters
    {
      ParmTrace << current_phase();
      if (sd_phase())
      {
        ParmTrace << "_sd";
        finished_minimize = 3;
      } // so flag is no longer==2
      if (finished_minimize == 2)
        ParmTrace << "_hs"; //  each Hessian calculation takes 4 calls, all will get this flag, so output processor needs to create a 1-4 counter
      if (finished_minimize == 1)
        finished_minimize = 2; //  this prevents _hs flag  for the one iteration that occurs after minimizer ends and before first tweak of Hessian
      if (mceval_phase())
        ParmTrace << "_mc";

      ParmTrace << " " << niter << " ";
      ParmTrace.precision(10);
      ParmTrace << obj_fun << " " << obj_fun - last_objfun << " " << value(SSB_yr(styr)) << " " << value(SSB_yr(endyr));
      ParmTrace.precision(2);
      ParmTrace << " " << biasadj(styr) << " " << max(biasadj) << " " << biasadj(endyr);
      ParmTrace.precision(7);
      for (j = 1; j <= MGparm_PH.indexmax(); j++)
      {
        if (MGparm_PH(j) >= 0)
        {
          ParmTrace << " " << MGparm(j);
        }
      }
      for (j = 1; j <= SR_parm_PH.indexmax(); j++)
      {
        if (SR_parm_PH(j) >= 0)
        {
          ParmTrace << " " << SR_parm(j);
        }
      }
      if (recdev_cycle > 0)
      {
        for (j = 1; j <= recdev_cycle; j++)
        {
          if (recdev_cycle_PH(j) >= 0)
          {
            ParmTrace << " " << recdev_cycle_parm(j);
          }
        }
      }
      if (recdev_early_PH > 0)
      {
        ParmTrace << " " << recdev_early;
      }
      if (recdev_PH > 0)
      {
        if (do_recdev == 1)
        {
          ParmTrace << " " << recdev1;
        }
        if (do_recdev >= 2)
        {
          ParmTrace << " " << recdev2;
        }
      }
      if (Fcast_recr_PH2 > 0 && Do_Forecast > 0)
      {
        ParmTrace << Fcast_recruitments << " ";
        if (Do_Impl_Error > 0)
          ParmTrace << Fcast_impl_error << " ";
      }

      for (f = 1; f <= N_init_F; f++)
      {
        if (init_F_PH(f) > 0)
        {
          ParmTrace << " " << init_F(f);
        }
      }
      if (N_Fparm > 0) // continuous F
      {
        for (k = 1; k <= N_Fparm; k++)
        {
          if (Fparm_PH[k] > 0)
          {
            ParmTrace << " " << F_rate(k);
          }
        }
      }

      for (f = 1; f <= Q_Npar2; f++)
      {
        if (Q_parm_PH(f) > 0)
        {
          ParmTrace << " " << Q_parm(f);
        }
      }
      for (k = 1; k <= selparm_PH.indexmax(); k++)
      {
        if (selparm_PH(k) > 0)
        {
          ParmTrace << " " << selparm(k);
        }
      }
      for (k = 1; k <= TG_parm_PH.indexmax(); k++)
      {
        if (TG_parm_PH(k) > 0)
        {
          ParmTrace << " " << TG_parm(k);
        }
      }
      if (N_parm_dev > 0)
      {
        for (j = 1; j <= N_parm_dev; j++)
        {
          if (parm_dev_PH(j) > 0)
            ParmTrace << parm_dev(j) << " ";
        }
      }
      ParmTrace.precision(10);
      k = min(current_phase(), max_lambda_phase);
      if (F_Method > 1)
        ParmTrace << " Catch " << catch_like * column(catch_lambda, k);
      if (N_init_F > 0)
        ParmTrace << " Equil_catch " << equ_catch_like * column(init_equ_lambda, k);
      if (Svy_N > 0)
        ParmTrace << " Survey " << k << " " << surv_like * column(surv_lambda, k) << " " << elem_prod(surv_like, column(surv_lambda, k));
      if (nobs_disc > 0)
        ParmTrace << " Discard " << disc_like * column(disc_lambda, k) << " " << elem_prod(disc_like, column(disc_lambda, k));
      if (nobs_mnwt > 0)
        ParmTrace << " Mean_body_wt " << mnwt_like * column(mnwt_lambda, k) << " " << elem_prod(mnwt_like, column(mnwt_lambda, k));
      if (Nobs_l_tot > 0)
        ParmTrace << " Length " << length_like_tot * column(length_lambda, k) << " " << elem_prod(length_like_tot, column(length_lambda, k));
      if (Nobs_a_tot > 0)
        ParmTrace << " Age " << age_like_tot * column(age_lambda, k) << " " << elem_prod(age_like_tot, column(age_lambda, k));
      if (nobs_ms_tot > 0)
        ParmTrace << " Size_at_age " << sizeage_like * column(sizeage_lambda, k) << " " << elem_prod(sizeage_like, column(sizeage_lambda, k));
      if (SzFreq_Nmeth > 0)
        ParmTrace << " SizeFreq " << SzFreq_like * column(SzFreq_lambda, k) << " " << elem_prod(SzFreq_like, column(SzFreq_lambda, k));
      if (Do_Morphcomp > 0)
        ParmTrace << " Morph " << Morphcomp_lambda(k) * Morphcomp_like;
      if (Do_TG > 0)
        ParmTrace << " Tag_comp " << TG_like1 * column(TG_lambda1, k) << " " << elem_prod(TG_like1, column(TG_lambda1, k));
      if (Do_TG > 0)
        ParmTrace << " Tag_negbin " << TG_like2 * column(TG_lambda2, k) << " " << elem_prod(TG_like2, column(TG_lambda2, k));
      ParmTrace << " Recr_dev " << recr_like * recrdev_lambda(k);
      ParmTrace << " Regime " << regime_like * regime_lambda(k);
      ParmTrace << " Fore_Recdev " << Fcast_recr_like;
      ParmTrace << " Parm_priors " << parm_like * parm_prior_lambda(k);
      if (SoftBound > 0)
        ParmTrace << " Softbounds " << SoftBoundPen;
      if (N_parm_dev > 0)
        ParmTrace << " Parm_devs " << (sum(parm_dev_like)) * parm_dev_lambda(k);
      if (F_ballpark_yr > 0)
        ParmTrace << " F_Ballpark " << F_ballpark_lambda(k) * F_ballpark_like;
      ParmTrace << endl;
    }
    else if ((Do_ParmTrace == 2 && obj_fun <= last_objfun) || Do_ParmTrace == 3) //  report active and inactive parameters
    {
      ParmTrace << current_phase() << " " << niter << " " << obj_fun << " " << obj_fun - last_objfun
                << " " << value(SSB_yr(styr)) << " " << value(SSB_yr(endyr)) << " " << biasadj(styr) << " " << max(biasadj) << " " << biasadj(endyr);
      ParmTrace << " " << MGparm << " ";
      ParmTrace << SR_parm << " ";
      if (recdev_cycle > 0)
        ParmTrace << recdev_cycle_parm;
      if (recdev_do_early > 0)
        ParmTrace << recdev_early << " ";
      if (do_recdev == 1)
      {
        ParmTrace << recdev1 << " ";
      }
      if (do_recdev >= 2)
      {
        ParmTrace << recdev2 << " ";
      }
      if (Do_Forecast > 0)
        ParmTrace << Fcast_recruitments << " ";
      if (Do_Impl_Error > 0)
        ParmTrace << Fcast_impl_error << " ";
      if (N_init_F > 0)
        ParmTrace << init_F << " ";
      if (N_Fparm > 0)
        ParmTrace << F_rate << " ";
      if (Q_Npar > 0)
        ParmTrace << Q_parm << " ";
      ParmTrace << selparm << " ";
      if (Do_TG > 0)
        ParmTrace << TG_parm << " ";
      if (N_parm_dev > 0)
      {
        for (j = 1; j <= N_parm_dev; j++)
        {
          ParmTrace << parm_dev(j);
        }
      }
      ParmTrace << endl;
    }
    if (obj_fun <= last_objfun)
      last_objfun = obj_fun;
    docheckup = 0; // turn off reporting to checkup.sso
    //  SS_Label_Info_7.11 #Call fxn get_posteriors if in mceval_phase
    if (mceval_phase())
    {
      get_posteriors();

      //SS_Label_Info_7.12 #write report_mce_XXXX.sso and compreport_mce_XXXX.sso for each MCEVAL
      //        warning<<mceval_counter<<" SSB 2021 2022 "<<SSB_std(N_STD_Yr-4)<<" "<<SSB_std(N_STD_Yr-3)<<endl<<endl;
      if (mcmc_output_detail >= 2)
      {
        write_bodywt = 0;
        pick_report_use(54) = 0;
        pick_report_use(55) = 0;
        save_for_report = 1;
        write_bigoutput();
        if (Do_Dyn_Bzero > 0)
          write_Bzero_output();
        save_for_report = 0;
        write_bodywt = 0;
      }
    }
  } //  end doing of the calculations
  if (mceval_phase() || initial_params::mc_phase == 1)
  {
    No_Report = 1; //  flag to skip output reports after MCMC and McEVAL
  }
  }
//  SS_Label_Info_7.13 #End of PROCEDURE_SECTION

