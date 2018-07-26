// ****************************************************************************************************************
//  SS_Label_Section_7.0 #PROCEDURE_SECTION
PROCEDURE_SECTION
  {

  Mgmt_quant.initialize();
  Extra_Std.initialize();
  CrashPen.initialize();
  niter++;
  if(mceval_phase() ) mceval_counter ++;   // increment the counter
  if(initial_params::mc_phase==1) 
  {
    if(mcmc_counter==0)
      {
        SR_parm(1)+=MCMC_bump;
        cout<<mcmc_counter<<"   adjusted SR_parm in first mcmc call "<<SR_parm(1)<<"  by  "<<MCMC_bump<<endl;
      }
    mcmc_counter++;
  }

  if(mcmcFlag==1)  //  so will do mcmc this run or is in mceval
  {
    if(Do_ParmTrace==1) Do_ParmTrace=4;  // to get all iterations
    if(Do_ParmTrace==2) Do_ParmTrace=3;  // to get all iterations
    if(mcmc_counter>10 || mceval_counter>10) Do_ParmTrace=0;
  }

//  SS_Label_Info_7.3 #Reset Fmethod 2 to Fmethod 3 according to the phase
    if(F_Method==2)
    {
      if(current_phase()>=F_setup(2) || (readparfile==1 && current_phase()<=1)) //  set Hrate = Frate parameters on first call if readparfile=1, or for advanced phases
      {
        for (g=1;g<=N_Fparm;g++)
        {
          f=Fparm_loc(g,1);
          t=Fparm_loc(g,2);
          Hrate(f,t)=F_rate(g);
        }
      }
      F_Method_use=2;
      if(current_phase() < F_setup(2)) F_Method_use=3;  // use hybrid
    }
    else
    {
      F_Method_use=F_Method;
    }

//  SS_Label_Info_7.4 #Do the time series calculations
  if(mceval_counter==0 || (mceval_counter>burn_intvl &&  ((double(mceval_counter)/double(thin_intvl)) - double((mceval_counter/thin_intvl))==0)  )) // check to see if burn in period is over
  {
//  add dynamic Bzero here

    setup_recdevs();
    y=styr;
//  SS_Label_Info_7.4.1 #Call fxn get_initial_conditions() to get the virgin and initial equilibrium population
    get_initial_conditions();
      if(do_once==1) cout<<" OK with initial conditions "<<endl;
//  SS_Label_Info_7.4.2 #Call fxn get_time_series() to do population calculations for each year and get expected values for observations

    get_time_series();  //  in procedure_section
      if(do_once==1) cout<<" OK with time series "<<endl;

//  SS_Label_Info_7.4.3 #Call fxn evaluate_the_objective_function()

    evaluate_the_objective_function();

    if(do_once==1)
    {
      cout<<" OK with obj_func "<<obj_fun<<endl;
    }
 
//  SS_Label_Info_7.6 #If sdphase or mcevalphase, do benchmarks and forecast and derived quantities
    if( (sd_phase() || mceval_phase()) && (initial_params::mc_phase==0))
    {
      setup_Benchmark();
//  SS_Label_Info_7.6.1 #Call fxn Get_Benchmarks()
      if(mceval_phase()==0) {show_MSY=1;}  //  so only show details if not in mceval
      if(show_MSY==1) cout<<"do benchmark and forecast if requested in sdphase"<<endl;
      if(Do_Benchmark>0)
      {
        Get_Benchmarks(show_MSY);
      }
      else
      {Mgmt_quant(1)=SSB_virgin;  warning<<"set to virgin in proced if no benchmark"<<endl;}
      did_MSY=1;   //  set flag to not calculate the benchmarks again in final section

//  SS_Label_Info_7.6.2 #Call fxn Get_Forecast()
      if(Do_Forecast>0)
      {
        if(show_MSY==1) report5<<"THIS FORECAST FOR PURPOSES OF STD REPORTING"<<endl;
        Get_Forecast();
      }

//  SS_Label_Info_7.7 #Call fxn Process_STDquant() to move calculated values into sd_containers
      Process_STDquant();
      if(rundetail>0 && mceval_phase()==0) cout<<"finished benchmark, forecast, and sdreporting"<<endl;
    }  // end of things to do in std_phase

//  SS_Label_Info_7.9 #Do screen output of procedure results from this iteration
    if(current_phase() <= max_phase+1) phase_output(current_phase())=value(obj_fun);
    if(rundetail>1)
      {
       if(Svy_N>0) cout<<" CPUE " <<surv_like<<endl;
       if(nobs_disc>0) cout<<" Disc " <<disc_like<<endl;
       if(nobs_mnwt>0) cout<<" MnWt " <<mnwt_like<<endl;
       if(Nobs_l_tot>0) cout<<" Length  " <<length_like_tot<<endl;
       if(Nobs_a_tot>0) cout<<" AGE  " <<age_like_tot<<endl;
       if(nobs_ms_tot>0) cout<<" L-at-A  " <<sizeage_like<<endl;
       if(SzFreq_Nmeth>0) cout<<" sizefreq "<<SzFreq_like<<endl;
       if(Do_TG>0) cout<<" TG-fleetcomp "<<TG_like1<<endl<<" TG-negbin "<<TG_like2<<endl;
       cout<<" Recr " <<recr_like<<endl;
       cout<<" InitEQ_Regime " <<regime_like<<endl;
       cout<<" Parm_Priors " <<parm_like<<endl;
       cout<<" Parm_devs " <<parm_dev_like<<endl;
       cout<<" SoftBound "<<SoftBoundPen<<endl;
       cout<<" F_ballpark " <<F_ballpark_like<<endl;
       if(F_Method>1) {cout<<"Catch "<<sum(catch_like)<<endl;}
       cout<<" EQUL_catch " <<equ_catch_like<<endl;
       cout<<"  crash "<<CrashPen<<endl;
      }
     if(rundetail>0)
     {
       temp=norm2(recdev(recdev_start,recdev_end));
       temp=sqrt((temp+0.0000001)/(double(recdev_end-recdev_start+1)));
     if(mcmc_counter==0 && mceval_counter==0)
     {cout<<current_phase()<<" "<<niter<<" -log(L): "<<obj_fun<<"  Spbio: "<<value(SSB_yr(styr))<<" "<<value(SSB_yr(endyr));}
     else if (mcmc_counter>0)
     {cout<<" MCMC: "<<mcmc_counter<<" -log(L): "<<obj_fun<<"  Spbio: "<<value(SSB_yr(styr))<<" "<<value(SSB_yr(endyr));}
     else if (mceval_counter>0)
     {cout<<" MCeval: "<<mceval_counter<<" -log(L): "<<obj_fun<<"  Spbio: "<<value(SSB_yr(styr))<<" "<<value(SSB_yr(endyr));}
       if(F_Method>1 && sum(catch_like)>0.01) {cout<<" cat "<<sum(catch_like);}
       else if (CrashPen>0.01) {cout<<"  crash "<<CrashPen;}
       cout<<endl;
     }

//  SS_Label_Info_7.10 #Write parameter values to ParmTrace
      if((Do_ParmTrace==1 && obj_fun<=last_objfun) || Do_ParmTrace==4)
      {
        ParmTrace<<current_phase()<<" "<<niter<<" "<<obj_fun<<" "<<obj_fun-last_objfun
        <<" "<<value(SSB_yr(styr))<<" "<<value(SSB_yr(endyr))<<" "<<biasadj(styr)<<" "<<max(biasadj)<<" "<<biasadj(endyr);
        for (j=1;j<=MGparm_PH.indexmax();j++)
        {
          if(MGparm_PH(j)>=0) {ParmTrace<<" "<<MGparm(j);}
        }
        for (j=1;j<=SR_parm_PH.indexmax();j++)
        {
          if(SR_parm_PH(j)>=0) {ParmTrace<<" "<<SR_parm(j);}
        }
        if(recdev_cycle>0)
        {
          for (j=1;j<=recdev_cycle;j++)
          {
            if(recdev_cycle_PH(j)>=0) {ParmTrace<<" "<<recdev_cycle_parm(j);}
          }
        }
        if(recdev_early_PH>0) {ParmTrace<<" "<<recdev_early;}
        if(recdev_PH>0)
        {
          if(do_recdev==1) {ParmTrace<<" "<<recdev1;}
          if(do_recdev==2) {ParmTrace<<" "<<recdev2;}
        }
        if(Do_Forecast>0) ParmTrace<<Fcast_recruitments<<" ";
        if(Do_Forecast>0 && Do_Impl_Error>0) ParmTrace<<Fcast_impl_error<<" ";
        for (f=1;f<=N_init_F;f++)
        {
          if(init_F_PH(f)>0) {ParmTrace<<" "<<init_F(f);}
        }
        if(F_Method==2)    // continuous F
        {
          for (k=1;k<=N_Fparm;k++)
          {
            if(Fparm_PH(k)>0) {ParmTrace<<" "<<F_rate(k);}
          }
        }
        for (f=1;f<=Q_Npar2;f++)
        {
          if(Q_parm_PH(f)>0) {ParmTrace<<" "<<Q_parm(f);}
        }
        for (k=1;k<=selparm_PH.indexmax();k++)
        {
          if(selparm_PH(k)>0) {ParmTrace<<" "<<selparm(k);}
        }
        for (k=1;k<=TG_parm_PH.indexmax();k++)
        {
          if(TG_parm_PH(k)>0) {ParmTrace<<" "<<TG_parm(k);}
        }
        if(N_parm_dev>0)
        {
          for (j=1;j<=N_parm_dev;j++)
          {
            if(parm_dev_PH(j)>0) ParmTrace<<parm_dev(j)<<" ";
          }
        }
        ParmTrace<<endl;
      }
      else if((Do_ParmTrace==2 && obj_fun<=last_objfun) || Do_ParmTrace==3)
      {
        ParmTrace<<current_phase()<<" "<<niter<<" "<<obj_fun<<" "<<obj_fun-last_objfun
        <<" "<<value(SSB_yr(styr))<<" "<<value(SSB_yr(endyr))<<" "<<biasadj(styr)<<" "<<max(biasadj)<<" "<<biasadj(endyr);
        ParmTrace<<" "<<MGparm<<" ";
        ParmTrace<<SR_parm<<" ";
        if(recdev_cycle>0) ParmTrace<<recdev_cycle_parm;
        if(recdev_do_early>0) ParmTrace<<recdev_early<<" ";
        if(do_recdev==1) {ParmTrace<<recdev1<<" ";}
        if(do_recdev==2) {ParmTrace<<recdev2<<" ";}
        if(Do_Forecast>0) ParmTrace<<Fcast_recruitments<<" "<<Fcast_impl_error<<" ";
        if(N_init_F>0) ParmTrace<<init_F<<" ";
        if(F_Method==2) ParmTrace<<F_rate<<" ";
        if(Q_Npar>0) ParmTrace<<Q_parm<<" ";
        ParmTrace<<selparm<<" ";
        if(Do_TG>0) ParmTrace<<TG_parm<<" ";
        if(N_parm_dev>0)
        {
          for (j=1;j<=N_parm_dev;j++)
          {ParmTrace<<parm_dev(j);}
        }
        ParmTrace<<endl;
      }
      if(obj_fun<=last_objfun) last_objfun=obj_fun;
     docheckup=0;  // turn off reporting to checkup.sso
//  SS_Label_Info_7.11 #Call fxn get_posteriors if in mceval_phase
     if(mceval_phase()) get_posteriors();
  }  //  end doing of the calculations

  if(mceval_phase() || initial_params::mc_phase==1)
  {
    No_Report=1;  //  flag to skip output reports after MCMC and McEVAL
  }
  }
//  SS_Label_Info_7.12 #End of PROCEDURE_SECTION

