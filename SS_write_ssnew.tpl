//********************************************************************
 /*  SS_Label_FUNCTION 38 write_nudata */
FUNCTION void write_nudata()
  {
//  code for multinomial distribution developed by Ian Stewart, Oct 2005

  dvector temp_mult(1,50000);
  dvector temp_probs(1,nlen_bin2);
  int compindex=0;
  dvector temp_probs2(1,n_abins2);
  int Nudat=0;
  int Nsamp_DM=0;
//  create bootstrap data files; except first file just replicates the input and second is the estimate without error
  	if(irand_seed<0) irand_seed=long(time(&start));
  		
  random_number_generator radm(irand_seed);
  for (i=1;i<=1234;i++) 
  {
  	temp = randn(radm);
  }

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
  { 
  report1 << "#_bootstrap file: " << Nudat-2 <<"  irand_seed: "<<irand_seed<<" first rand#: "<<randn(radm)<<endl;}
  report1<<version_info<<endl;
  report1 << styr << " #_StartYr"<<endl;
  report1 << endyr <<" #_EndYr"<< endl;
  report1 << nseas <<" #_Nseas"<< endl;
  report1 << 12.*seasdur<<" #_months/season"<< endl;
  report1 << N_subseas<<" #_Nsubseasons (even number, minimum is 2)"<<endl;
  report1 << spawn_month <<" #_spawn_month"<< endl;
  report1 << gender_rd<<" #_Ngenders: 1, 2, -1  (use -1 for 1 sex setup with SSB multiplied by female_frac parameter)"<< endl;
  report1 << nages<<" #_Nages=accumulator age, first age is always age 0"<< endl;
  report1 << pop<<" #_Nareas"<<endl;
  report1 << Nfleet<<" #_Nfleets (including surveys)"<< endl;
  report1<<"#_fleet_type: 1=catch fleet; 2=bycatch only fleet; 3=survey; 4=ignore "<<endl;
  report1<<"#_sample_timing: -1 for fishing fleet to use season-long catch-at-age for observations, or 1 to use observation month;  (always 1 for surveys)"<<endl;
  report1<<"#_fleet_area:  area the fleet/survey operates in "<<endl;
  report1<<"#_units of catch:  1=bio; 2=num (ignored for surveys; their units read later)"<<endl;
  report1<<"#_catch_mult: 0=no; 1=yes"<<endl;
  report1<<"#_rows are fleets"<<endl<<"#_fleet_type fishery_timing area catch_units need_catch_mult fleetname"<<endl;
  for (f=1;f<=Nfleet;f++)
  {report1<<fleet_setup(f)<<" "<<fleetname(f)<<"  # "<<f<<endl;}
  report1<<"#Bycatch_fleet_input_goes_next"<<endl;
  report1<<"#a:  fleet index"<<endl;
  report1<<"#b:  1=include dead bycatch in total dead catch for F0.1 and MSY optimizations and forecast ABC; 2=omit from total catch for these purposes (but still include the mortality)"<<endl;
  report1<<"#c:  1=Fmult scales with other fleets; 2=bycatch F constant at input value; 3=bycatch F from range of years"<<endl;
  report1<<"#d:  F or first year of range"<<endl;
  report1<<"#e:  last year of range"<<endl;
  report1<<"#f:  not used"<<endl;
  report1<<"# a   b   c   d   e   f "<<endl;
  for (f=1;f<=Nfleet;f++)
  {
    if(fleet_type(f)==2) report1<<bycatch_setup(f)<<"  # "<<fleetname(f)<<endl;
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
  report1<<"#_Units:  0=numbers; 1=biomass; 2=F; 30=spawnbio; 31=recdev; 32=spawnbio*recdev; 33=recruitment; 34=depletion(&see Qsetup); 35=parm_dev(&see Qsetup)"<<endl;
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
  report1<<"# note:  type=1 for mean length; type=2 for mean body weight "<<endl;
  report1<<"#_yr month fleet part type obs stderr"<<endl;
  if(nobs_mnwt>0)
   {
   for (i=1;i<=nobs_mnwt;i++)
    {
     f=abs(mnwtdata(3,i));
     report1 << Show_Time(mnwtdata(1,i),1)<<" "<<mnwtdata(2,i)<<" "<<mnwtdata(3,i)<<" "<<mnwtdata(4,i)<<" "<<mnwtdata(5,i)<<" "<<
     mnwtdata(6,i)<<" "<<mnwtdata(7,i)-var_adjust(3,f)<<" #_ "<<fleetname(f)<<endl;
    }
   }
  if(do_meanbodywt==0) report1<<"# ";
  report1<<" -9999 0 0 0 0 0 0 # terminator for mean body size data "<<endl;

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
  report1<<"#_combM+F: males and females treated as combined gender below this bin number "<<endl;
  report1<<"#_compressbins: accumulate upper tail by this number of bins; acts simultaneous with mintailcomp; set=0 for no forced accumulation"<<endl;
  report1<<"#_Comp_Error:  0=multinomial, 1=dirichlet"<<endl;
  report1<<"#_ParmSelect:  parm number for dirichlet"<<endl;
  report1<<"#_minsamplesize: minimum sample size; set to 1 to match 3.24, minimum value is 0.001"<<endl;
	report1<<"#"<<endl;
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
  report1<<"#_combM+F: males and females treated as combined gender below this bin number "<<endl;
  report1<<"#_compressbins: accumulate upper tail by this number of bins; acts simultaneous with mintailcomp; set=0 for no forced accumulation"<<endl;
  report1<<"#_Comp_Error:  0=multinomial, 1=dirichlet"<<endl;
  report1<<"#_ParmSelect:  parm number for dirichlet"<<endl;
  report1<<"#_minsamplesize: minimum sample size; set to 1 to match 3.24, minimum value is 0.001"<<endl;
	report1<<"#"<<endl;
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
    for (j=1;j<=6+2*n_abins2;j++) report1<<" 0";
    report1<<endl;
  }
  }

    report1<<"#"<<endl << N_envvar<<" #_N_environ_variables"<<endl;
    report1<<"# -2 in yr will subtract mean for that env_var; -1 will subtract mean and divide by stddev (e.g. Z-score)"<<endl;
    report1<<"#Yr Variable Value"<<endl;
    if(N_envvar>0)
      {for(i=0;i<=N_envdata-1;i++) report1<<env_temp[i]<<endl;
       report1<<"-9999 0 0"<<endl;
      }

  report1<<"#"<<endl<<SzFreq_Nmeth<<" # N sizefreq methods to read "<<endl;
  if(SzFreq_Nmeth>0)
  {
    report1<<SzFreq_Nbins<<" #Sizefreq N bins per method"<<endl;
    report1<<SzFreq_units<<" #Sizetfreq units(1=bio/2=num) per method"<<endl;
    report1<<SzFreq_scale<<" #Sizefreq scale(1=kg/2=lbs/3=cm/4=inches) per method"<<endl;
    report1<<SzFreq_mincomp<<" #Sizefreq:  add small constant to comps, per method "<<endl;
    report1<<SzFreq_nobs<<" #Sizefreq N obs per method"<<endl;
    report1<<"#_Sizefreq bins "<<endl<<"#Note: negative value for first bin makes it accumulate all smaller fish vs. truncate small fish"<<endl;
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
      report1<<Morphcomp_nobs_rd<<"  #  Nobs"<<endl;
      report1<<Morphcomp_nmorph<<" # Nmorphs"<<endl;
      report1<<Morphcomp_mincomp<<" # add_to_comp"<<endl;
      report1<<"# yr, month, fleet, null, Nsamp, datavector_by_Nmorphs"<<endl;
      for(i=1;i<=Morphcomp_nobs_rd;i++)
      {report1<<Morphcomp_obs_rd<<endl;}
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
    report1<<"#_Units:  0=numbers; 1=biomass; 2=F; 30=spawnbio; 31=recdev; 32=spawnbio*recdev; 33=recruitment; 34=depletion(&see Qsetup); 35=parm_dev(&see Qsetup)"<<endl;
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
        if(Svy_errtype(f)>=0)  // lognormal
        {
          report1 << mfexp(Svy_est(f,i));
        }
        else if(Svy_errtype(f)==-1)  // normal
        {
          report1<<Svy_est(f,i);
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
        {report1 << exp_disc(f,i);}
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
  report1<<"# note:  type=1 for mean length; type=2 for mean body weight "<<endl;
  report1<<"#_yr month fleet part type obs stderr"<<endl;
  if(nobs_mnwt>0)
   {
   for (i=1;i<=nobs_mnwt;i++)
    {
     f=abs(mnwtdata(3,i));
     report1 << Show_Time(mnwtdata(1,i),1)<<" "<<mnwtdata(2,i)<<" "<<mnwtdata(3,i)<<" "<<mnwtdata(4,i)<<" "<<mnwtdata(5,i)<<" "<<
     exp_mnwt(i)<<" "<<mnwtdata(7,i)-var_adjust(3,f)<<" #_orig_obs: "<<mnwtdata(6,i)<<"  #_ "<<fleetname(f)<<endl;
    }
   }
  if(do_meanbodywt==0) report1<<"# ";
  report1<<" -9999 0 0 0 0 0 0 # terminator for mean body size data "<<endl;

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
  report1<<"#_combM+F: males and females treated as combined gender below this bin number "<<endl;
  report1<<"#_compressbins: accumulate upper tail by this number of bins; acts simultaneous with mintailcomp; set=0 for no forced accumulation"<<endl;
  report1<<"#_Comp_Error:  0=multinomial, 1=dirichlet"<<endl;
  report1<<"#_ParmSelect:  parm number for dirichlet"<<endl;
  report1<<"#_minsamplesize: minimum sample size; set to 1 to match 3.24, minimum value is 0.001"<<endl;
	report1<<"#"<<endl;
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
       k=1000;  if(nsamp_l(f,i)<k) k=nsamp_l(f,i);
       exp_l_temp_dat = nsamp_l(f,i)*value(exp_l(f,i)/sum(exp_l(f,i)));
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
  report1<<"#_combM+F: males and females treated as combined gender below this bin number "<<endl;
  report1<<"#_compressbins: accumulate upper tail by this number of bins; acts simultaneous with mintailcomp; set=0 for no forced accumulation"<<endl;
  report1<<"#_Comp_Error:  0=multinomial, 1=dirichlet"<<endl;
  report1<<"#_ParmSelect:  parm number for dirichlet"<<endl;
  report1<<"#_minsamplesize: minimum sample size; set to 1 to match 3.24, minimum value is 0.001"<<endl;
	report1<<"#"<<endl;
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
      k=1000;  if(nsamp_a(f,i)<k) k=nsamp_a(f,i);  // note that nsamp is adjusted by var_adjust, so var_adjust
                                                   // should be reset to 1.0 in control files that read the nudata.dat files
      exp_a_temp = nsamp_a(f,i)*value(exp_a(f,i)/sum(exp_a(f,i)));
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
  report1<<"# partition codes: 0=combined; 1=discard; 2=retained"<<endl;
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
            temp=exp_ms(f,i,a);
            if(temp<=0.) {temp=0.0001;}
            report1 << temp;
       }
       report1 << endl<< obs_ms_n_read(f,i) << endl;
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
    report1<<"# -2 in yr will subtract mean for that env_var; -1 will subtract mean and divide by stddev (e.g. Z-score)"<<endl;
    report1<<"#Yr Variable Value"<<endl;
    if(N_envvar>0)
      {for(i=0;i<=N_envdata-1;i++) report1<<env_temp[i]<<endl;
       report1<<"-9999 0 0"<<endl;
      }

  report1<<"#"<<endl<<SzFreq_Nmeth<<" # N sizefreq methods to read "<<endl;
  if(SzFreq_Nmeth>0)
  {
    report1<<SzFreq_Nbins<<" #Sizefreq N bins per method"<<endl;
    report1<<SzFreq_units<<" #Sizetfreq units(1=bio/2=num) per method"<<endl;
    report1<<SzFreq_scale<<" #Sizefreq scale(1=kg/2=lbs/3=cm/4=inches) per method"<<endl;
    report1<<SzFreq_mincomp<<" #Sizefreq:  add small constant to comps, per method "<<endl;
    report1<<SzFreq_nobs<<" #Sizefreq N obs per method"<<endl;
    report1<<"#_Sizefreq bins "<<endl<<"#_Note: negative value for first bin makes it accumulate all smaller fish vs. truncate small fish"<<endl;
    for (i=1;i<=SzFreq_Nmeth;i++) {report1<<SzFreq_Omit_Small(i)*SzFreq_bins1(i,1)<<SzFreq_bins1(i)(2,SzFreq_Nbins(i))<<endl;}
    report1<<"#_method yr month fleet sex partition SampleSize <data> "<<endl;
    for (iobs=1;iobs<=SzFreq_totobs;iobs++)
    {
        report1<<SzFreq_obs1(iobs)(1,7)<<" "<<SzFreq_exp(iobs)<<endl;
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
      report1<<Morphcomp_nobs<<"  #  Nobs"<<endl;
      report1<<Morphcomp_nmorph<<" # Nmorphs"<<endl;
      report1<<Morphcomp_mincomp<<" # add_to_comp"<<endl;
      report1<<"# yr, month, fleet, null, Nsamp, datavector_by_Nmorphs"<<endl;
      for(i=1;i<=Morphcomp_nobs;i++)
      {report1<<Morphcomp_obs(i)(1,5)<<" "<<Morphcomp_exp(i)<<endl;}
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
  report1<<"#_Units:  0=numbers; 1=biomass; 2=F; 30=spawnbio; 31=recdev; 32=spawnbio*recdev; 33=recruitment; 34=depletion(&see Qsetup); 35=parm_dev(&see Qsetup)"<<endl;
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
    double newobs=0.0;
    report1 << Show_Time(t,1)<<" "<<Svy_super(f,i)*data_time(ALK_time,f,1)<<" "<<f*Svy_use(f,i)<<" ";
      if(Svy_errtype(f)==-1)  // normal error
      {
        newobs=value(Svy_est(f,i)+randn(radm)*Svy_se_use(f,i));    //  uses Svy_se_use, not Svy_se_rd to include both effect of input var_adjust and extra_sd
      }
      if(Svy_errtype(f)==0)  // lognormal
      {
         newobs=value(mfexp(Svy_est(f,i)+ randn(radm)*Svy_se_use(f,i) ));    //  uses Svy_se_use, not Svy_se_rd to include both effect of input var_adjust and extra_sd
      }
      else if(Svy_errtype(f)>0)   // lognormal T_dist
      {
        temp = sqrt( (Svy_errtype(f)+1.)/Svy_errtype(f));  // where df=Svy_errtype(f)
        newobs=value(mfexp(Svy_est(f,i)+ randn(radm)*Svy_se_use(f,i)*temp ));    //  adjusts the sd by the df sample size
      }
     if(Svy_minval(f)>=0.0 && Svy_errtype(f)!=0) newobs=max(newobs,0.5*Svy_minval(f));
    report1 <<newobs<<" "<<Svy_se_rd(f,i)<<" #_orig_obs: "<<Svy_obs(f,i)<<" "<<fleetname(f)<<endl;
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
       if(disc_minval(f)>=0.0) temp=max(value(temp),0.5*disc_minval(f));

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
  report1<<"# note:  type=1 for mean length; type=2 for mean body weight "<<endl;
  report1<<"#_yr month fleet part type obs stderr"<<endl;
  
  // NOTE, the se stored in mnwtdata(7,i) was adjusted in prelim calc to include the input var_adjustment
  //  so var_adjust is subtracted here when the observation is written
  if(nobs_mnwt>0)
  {
    for (i=1;i<=nobs_mnwt;i++)
    {
      temp=exp_mnwt(i)+randn(radm)*mnwtdata(7,i)*sqrt((DF_bodywt+1.)/DF_bodywt) *exp_mnwt(i);
      if(temp<=0.0) {temp=0.0001;}
      f=abs(mnwtdata(3,i));
      report1 << Show_Time(mnwtdata(1,i),1)<<" "<<mnwtdata(2,i)<<" "<<mnwtdata(3,i)<<" "<<mnwtdata(4,i)<<" "<<mnwtdata(5,i)<<" "<<
      temp<<" "<<mnwtdata(7,i)-var_adjust(3,f)<<" #_orig_obs: "<<mnwtdata(6,i)<<"  #_ "<<fleetname(f)<<endl;    }
  }
  if(do_meanbodywt==0) report1<<"# ";
  report1<<" -9999 0 0 0 0 0 0 # terminator for mean body size data "<<endl;

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
  report1<<"#_combM+F: males and females treated as combined gender below this bin number "<<endl;
  report1<<"#_compressbins: accumulate upper tail by this number of bins; acts simultaneous with mintailcomp; set=0 for no forced accumulation"<<endl;
  report1<<"#_Comp_Error:  0=multinomial, 1=dirichlet"<<endl;
  report1<<"#_ParmSelect:  parm number for dirichlet"<<endl;
  report1<<"#_minsamplesize: minimum sample size; set to 1 to match 3.24, minimum value is 0.001"<<endl;
	report1<<"#"<<endl;
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
       if(Comp_Err_L(f)==0)  //  multinomial
       {
          Nsamp_DM=nsamp_l(f,i);
       }
       else if(Comp_Err_L(f)==1) //  Dirichlet #1
       {
         dirichlet_Parm=mfexp(selparm(Comp_Err_Parm_Start+Comp_Err_L2(f)));  //  Thorson's theta fro eq 10
         // effN_DM = 1/(1+theta) + n*theta/(1+theta)
         Nsamp_DM = value(1./(1.+dirichlet_Parm) + nsamp_l(f,i)*dirichlet_Parm/(1.+dirichlet_Parm));
       }
       else if(Comp_Err_L(f)==2) //  Dirichlet #2
       {
         dirichlet_Parm=mfexp(selparm(Comp_Err_Parm_Start+Comp_Err_L2(f)))*nsamp_l(f,i);  //  Thorson's beta from eq 12
         // effN_DM = (n+n*beta)/(n+beta)      computed in Fit_LenComp
         Nsamp_DM = value((nsamp_l(f,i)+dirichlet_Parm*nsamp_l(f,i))/(dirichlet_Parm+nsamp_l(f,i)));
       }
       Nsamp_DM=min(Nsamp_DM,50000);
       Nsamp_DM=max(Nsamp_DM,1);
       exp_l_temp_dat.initialize();
       temp_probs = value(exp_l(f,i));
       temp_mult.fill_multinomial(radm,temp_probs);  // create multinomial draws with prob = expected values
       for (compindex=1; compindex<=Nsamp_DM; compindex++) // cumulate the multinomial draws by index in the new data
       {exp_l_temp_dat(temp_mult(compindex)) += 1.0;}

       report1 << header_l_rd(f,i)(1,3)<<" "<<gen_l(f,i)<<" "<<mkt_l(f,i)<<" "<<Nsamp_DM<<" "<<exp_l_temp_dat<<endl;
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
  report1<<"#_combM+F: males and females treated as combined gender below this bin number "<<endl;
  report1<<"#_compressbins: accumulate upper tail by this number of bins; acts simultaneous with mintailcomp; set=0 for no forced accumulation"<<endl;
  report1<<"#_Comp_Error:  0=multinomial, 1=dirichlet"<<endl;
  report1<<"#_ParmSelect:  parm number for dirichlet"<<endl;
  report1<<"#_minsamplesize: minimum sample size; set to 1 to match 3.24, minimum value is 0.001"<<endl;
	report1<<"#"<<endl;
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
    if(Nobs_a(f)>0)
    {
     for (i=1;i<=Nobs_a(f);i++)
     {
       if(Comp_Err_A(f)==0)  //  multinomial
       {
          Nsamp_DM=nsamp_a(f,i);
       }
       else if(Comp_Err_A(f)==1) //  Dirichlet #1
       {
         dirichlet_Parm=mfexp(selparm(Comp_Err_Parm_Start+Comp_Err_A2(f)));  //  Thorson's theta from eq 10
         // effN_DM = 1/(1+theta) + n*theta/(1+theta)
         Nsamp_DM = value(1./(1.+dirichlet_Parm) + nsamp_a(f,i)*dirichlet_Parm/(1.+dirichlet_Parm));
       }
       else if(Comp_Err_A(f)==2) //  Dirichlet #2
       {
         dirichlet_Parm=mfexp(selparm(Comp_Err_Parm_Start+Comp_Err_A2(f)))*nsamp_a(f,i);  //  Thorson's beta from eq 12
         // effN_DM = (n+n*beta)/(n+beta)      computed in Fit_LenComp
         Nsamp_DM = value((nsamp_a(f,i)+dirichlet_Parm*nsamp_a(f,i))/(dirichlet_Parm+nsamp_a(f,i)));
       }
       Nsamp_DM=min(Nsamp_DM,50000);
       Nsamp_DM=max(Nsamp_DM,1);
       exp_a_temp.initialize();
       temp_probs2 = value(exp_a(f,i));
       temp_mult.fill_multinomial(radm,temp_probs2);  // create multinomial draws with prob = expected values
       for (compindex=1; compindex<=Nsamp_DM; compindex++) // cumulate the multinomial draws by index in the new data
       {exp_a_temp(temp_mult(compindex)) += 1.0;}

       report1 << header_a(f,i)(1)<<" "<<header_a_rd(f,i)(2,3)<<" "<<header_a(f,i)(4,8)<<" "<<Nsamp_DM<<" "<<exp_a_temp<<endl;
    }}}
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
            temp=exp_ms(f,i,a)+randn(radm)*exp_ms_sq(f,i,a)/obs_ms_n(f,i,a);
            if(temp<=0.) {temp=0.0001;}
            report1 << temp;
         }
         report1 << endl<< obs_ms_n_read(f,i) << endl;
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
    report1<<"# -2 in yr will subtract mean for that env_var; -1 will subtract mean and divide by stddev (e.g. Z-score)"<<endl;
    report1<<"#Yr Variable Value"<<endl;
    if(N_envvar>0)
      {for(i=0;i<=N_envdata-1;i++) report1<<env_temp[i]<<endl;
       report1<<"-9999 0 0"<<endl;
      }

  report1<<"#"<<endl<<SzFreq_Nmeth<<" # N sizefreq methods to read "<<endl;
  if(SzFreq_Nmeth>0)
  {
    report1<<SzFreq_Nbins<<" #Sizefreq N bins per method"<<endl;
    report1<<SzFreq_units<<" #Sizetfreq units(1=bio/2=num) per method"<<endl;
    report1<<SzFreq_scale<<" #Sizefreq scale(1=kg/2=lbs/3=cm/4=inches) per method"<<endl;
    report1<<SzFreq_mincomp<<" #Sizefreq:  add small constant to comps, per method "<<endl;
    report1<<SzFreq_nobs<<" #Sizefreq N obs per method"<<endl;
    report1<<"#_Sizefreq bins "<<endl<<"#Note: negative value for first bin makes it accumulate all smaller fish vs. truncate small fish"<<endl;
    for (i=1;i<=SzFreq_Nmeth;i++) {report1<<SzFreq_Omit_Small(i)*SzFreq_bins1(i,1)<<SzFreq_bins1(i)(2,SzFreq_Nbins(i))<<endl;}
    report1<<"#_method year month fleet sex partition SampleSize <data> "<<endl;
    j=2*max(SzFreq_Nbins);
    dvector temp_probs3(1,j);
    dvector SzFreq_newdat(1,j);
    for (iobs=1;iobs<=SzFreq_totobs;iobs++)
    {
       j=50000;  if(SzFreq_obs1(iobs,7)<j) j=SzFreq_obs1(iobs,7);
       SzFreq_newdat.initialize();
       temp_probs3(1,SzFreq_Setup2(iobs)) = value(SzFreq_exp(iobs));
       temp_mult.fill_multinomial(radm,temp_probs3(1,SzFreq_Setup2(iobs)));  // create multinomial draws with prob = expected values
       for (compindex=1; compindex<=j; compindex++) // cumulate the multinomial draws by index in the new data
       {SzFreq_newdat(temp_mult(compindex)) += 1.0;}

        report1<<SzFreq_obs1(iobs)(1,7)<<" "<<SzFreq_newdat(1,SzFreq_Setup2(iobs))<<endl;
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
      report1<<Morphcomp_nobs<<"  #  Nobs"<<endl;
      report1<<Morphcomp_nmorph<<" # Nmorphs"<<endl;
      report1<<Morphcomp_mincomp<<" # add_to_comp"<<endl;
      report1<<"#  yr, month, fleet, null, Nsamp, datavector_by_Nmorphs  (no error added!!!)"<<endl;
      for(i=1;i<=Morphcomp_nobs;i++)
      {report1<<Morphcomp_obs(i)(1,5)<<" "<<Morphcomp_exp(i)<<endl;}
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
 /*  SS_Label_FUNCTION 39 write_nucontrol  write new control file and starter file */
FUNCTION void write_nucontrol()
  {
  cout<<" Write new starter file "<<endl;
  ofstream NuStart("starter.ss_new");
  NuStart<<version_info<<endl<<version_info2<<endl<<version_info3<<endl;
  if(N_SC>0) NuStart<<Starter_Comments<<endl;
  NuStart<<datfilename<<endl<<ctlfilename<<endl;
  NuStart<<readparfile<<" # 0=use init values in control file; 1=use ss.par"<<endl;
  NuStart<<rundetail<<" # run display detail (0,1,2)"<<endl;
  NuStart<<reportdetail<<" # detailed output (0=minimal for data-limited, 1=high (w/ wtatage.ss_new), 2=brief, 3=custom) "<<endl;
  if(reportdetail==3)
  	{
  		NuStart<<"# custom report options: -100 to start with minimal; -101 to start with all; -number to remove, +number to add, -999 to end"<<endl;
  	  for(unsigned j=0;j<=reportdetail_list.size()-1;j++) {NuStart<<reportdetail_list[j](1)<<endl;}
  	}
  	else
  		{
  		NuStart<<"# custom report options: -100 to start with minimal; -101 to start with all; -number to remove, +number to add, -999 to end"<<endl;
  		}
  
  
  NuStart<<docheckup<<" # write 1st iteration details to echoinput.sso file (0,1) "<<endl;
  NuStart<<Do_ParmTrace<<" # write parm values to ParmTrace.sso (0=no,1=good,active; 2=good,all; 3=every_iter,all_parms; 4=every,active)"<<endl;
  NuStart<<Do_CumReport<<" # write to cumreport.sso (0=no,1=like&timeseries; 2=add survey fits)"<<endl;
  NuStart<<Do_all_priors<<" # Include prior_like for non-estimated parameters (0,1) "<<endl;
  NuStart<<SoftBound<<" # Use Soft Boundaries to aid convergence (0,1) (recommended)"<<endl;
  NuStart<<"#"<<endl<<N_nudata_read<<" # Number of datafiles to produce: 1st is input, 2nd is estimates, 3rd and higher are bootstrap, 0 turns off all *.ss_new output"<<endl;
  NuStart<<Turn_off_phase_rd<<" # Turn off estimation for parameters entering after this phase"<<endl;
  NuStart<<"#"<<endl<<burn_intvl<<" # MCeval burn interval"<<endl;
  NuStart<<thin_intvl<<" # MCeval thin interval"<<endl;
  NuStart<<jitter<<" # jitter initial parm value by this fraction"<<endl;
  NuStart<<STD_Yr_min_rd<<" # min yr for sdreport outputs (-1 for styr); #_"<<STD_Yr_min<<endl;
  NuStart<<STD_Yr_max_rd<<" # max yr for sdreport outputs (-1 for endyr+1; -2 for endyr+Nforecastyrs); #_"<<STD_Yr_max<<endl;
  NuStart<<N_STD_Yr_RD<<" # N individual STD years "<<endl;
  NuStart<<"#vector of year values "<<endl<<STD_Yr_RD<<endl;

  NuStart<<final_conv<<" # final convergence criteria (e.g. 1.0e-04) "<<endl;
  NuStart<<retro_yr-endyr<<" # retrospective year relative to end year (e.g. -4)"<<endl;
  NuStart<<Smry_Age<<" # min age for calc of summary biomass"<<endl;
  NuStart<<depletion_basis_rd<<" # Depletion basis:  denom is: 0=skip; 1=rel X*SPB0; 2=rel SPBmsy; 3=rel X*SPB_styr; 4=rel X*SPB_endyr; values; >=11 invoke N multiyr (up to 9!) with 10's digit; >100 invokes log(ratio)"<<endl;
  NuStart<<depletion_level<<" # Fraction (X) for Depletion denominator (e.g. 0.4)"<<endl;
  NuStart<<SPR_reporting<<" # SPR_report_basis:  0=skip; 1=(1-SPR)/(1-SPR_tgt); 2=(1-SPR)/(1-SPR_MSY); 3=(1-SPR)/(1-SPR_Btarget); 4=rawSPR"<<endl;
  NuStart<<F_reporting<<" # Annual_F_units: 0=skip; 1=exploitation(Bio); 2=exploitation(Num); 3=sum(Apical_F's); 4=true F for range of ages; 5=unweighted avg. F for range of ages"<<endl;
  if(F_reporting==4 || F_reporting==5)
  {NuStart<<F_reporting_ages<<" #_min and max age over which average F will be calculated, with F=Z-M"<<endl;}
  else
  {NuStart<<"#COND 10 15 #_min and max age over which average F will be calculated with F_reporting=4 or 5"<<endl;}
  NuStart<<F_std_basis_rd<<" # F_std_basis: 0=raw_annual_F; 1=F/Fspr; 2=F/Fmsy; 3=F/Fbtgt; where F means annual_F; values >=11 invoke N multiyr (up to 9!) with 10's digit; >100 invokes log(ratio)"<<endl;
  NuStart<<double(mcmc_output_detail)+MCMC_bump<<
  " # MCMC output detail: integer part (0=default; 1=adds obj func components); and decimal part (added to SR_LN(R0) on first call to mcmc)"<<endl;
  NuStart<<ALK_tolerance<<" # ALK tolerance (example 0.0001)"<<endl;
  NuStart<<irand_seed_rd<<" # random number seed for bootstrap data (-1 to use long(time) as seed): # "<< irand_seed<<endl;
  NuStart<<"3.30 # check value for end of file and for version control"<<endl;
  NuStart.close();

  cout<<" Write new forecast file "<<endl;
  ofstream NuFore("forecast.ss_new");
  NuFore<<version_info<<endl;
  if(N_FC>0) NuFore<<Forecast_Comments<<endl;
  NuFore<<"# for all year entries except rebuilder; enter either: actual year, -999 for styr, 0 for endyr, neg number for rel. endyr"<<endl;
  NuFore<<Do_Benchmark<<" # Benchmarks: 0=skip; 1=calc F_spr,F_btgt,F_msy; 2=calc F_spr,F0.1,F_msy "<<endl;
  NuFore<<Do_MSY<<" # MSY: 1= set to F(SPR); 2=calc F(MSY); 3=set to F(Btgt) or F0.1; 4=set to F(endyr) "<<endl;
  NuFore<<SPR_target<<" # SPR target (e.g. 0.40)"<<endl;
  NuFore<<BTGT_target<<" # Biomass target (e.g. 0.40)"<<endl;
  NuFore<<"#_Bmark_years: beg_bio, end_bio, beg_selex, end_selex, beg_relF, end_relF, beg_recr_dist, end_recr_dist, beg_SRparm, end_SRparm (enter actual year, or values of 0 or -integer to be rel. endyr)"<<endl<<Bmark_Yr_rd<<endl<<"# "<<Bmark_Yr<<endl;
  NuFore<<"# value <0 convert to endyr-value; except -999 converts to start_yr; must be >=start_yr and <=endyr"<<endl;
  NuFore<<Bmark_RelF_Basis<<" #Bmark_relF_Basis: 1 = use year range; 2 = set relF same as forecast below"<<endl;
  NuFore<<"#"<<endl<<Do_Forecast_rd<<" # Forecast: -1=none; 0=simple_1yr; 1=F(SPR); 2=F(MSY) 3=F(Btgt) or F0.1; 4=Ave F (uses first-last relF yrs); 5=input annual F scalar"<<endl;
  NuFore<<"# where none and simple require no input after this line; simple sets forecast F same as end year F"<<endl;
  NuFore<<N_Fcast_Yrs<<" # N forecast years "<<endl;
  NuFore<<Fcast_Flevel<<" # Fmult (only used for Do_Forecast==5) such that apical_F(f)=Fmult*relF(f)"<<endl;
  NuFore<<"#_Fcast_years:  beg_selex, end_selex, beg_relF, end_relF, beg_mean recruits, end_recruits  (enter actual year, or values of 0 or -integer to be rel. endyr)"<<endl<<Fcast_yr_rd<<endl<<"# "<<Fcast_yr<<endl;
  NuFore<<Fcast_Specify_Selex<<" # Forecast selectivity (0=fcast selex is mean from year range; 1=fcast selectivity from annual time-vary parms)"<<endl;

  NuFore<<HarvestPolicy<<" # Control rule method (0: none; 1: ramp does catch=f(SSB), buffer on F; 2: ramp does F=f(SSB), buffer on F; 3: ramp does catch=f(SSB), buffer on catch; 4: ramp does F=f(SSB), buffer on catch) "<<endl;
  NuFore<<"# values for top, bottom and buffer exist, but not used when Policy=0"<<endl;
  NuFore<<H4010_top<<" # Control rule Biomass level for constant F (as frac of Bzero, e.g. 0.40); (Must be > the no F level below) "<<endl;
  NuFore<<H4010_bot<<" # Control rule Biomass level for no F (as frac of Bzero, e.g. 0.10) "<<endl;
  NuFore<<H4010_scale_rd<<" # Buffer:  enter Control rule target as fraction of Flimit (e.g. 0.75), negative value invokes list of [year, scalar] with filling from year to YrMax "<<endl;
  if(H4010_scale_rd<0)
  {
    j=H4010_scale_vec_rd.size()-1;
    for (int s=0; s<=j; s++) 
    {
      NuFore<<H4010_scale_vec_rd[s]<<endl;
    }
  }

  NuFore<<Fcast_Loop_Control(1)<<" #_N forecast loops (1=OFL only; 2=ABC; 3=get F from forecast ABC catch with allocations applied)"<<endl;
  NuFore<<Fcast_Loop_Control(2)<<" #_First forecast loop with stochastic recruitment"<<endl;
  NuFore<<Fcast_Loop_Control(3)<<" #_Forecast recruitment:  0= spawn_recr; 1=value*spawn_recr_fxn; 2=value*VirginRecr; 3=recent mean from yr range above (need to set phase to -1 in control to get constant recruitment in MCMC)"<<endl;
  if(Fcast_Loop_Control(3)==0)
    {NuFore<<1.0<<" # value is ignored "<<endl;}
  else if(Fcast_Loop_Control(3)==1)
    {NuFore<<Fcast_Loop_Control(4)<<" # value is multiplier of SRR "<<endl;}
  else if(Fcast_Loop_Control(3)==2)
    {NuFore<<Fcast_Loop_Control(4)<<" # value is multiplier on virgin recr"<<endl;}
  else if(Fcast_Loop_Control(3)==3)
    {NuFore<<Fcast_Loop_Control(4)<<" # not used"<<endl;}
  else
  	{NuFore<<"0 # not used"<<endl;}
  NuFore<<Fcast_Loop_Control(5)<<" #_Forecast loop control #5 (reserved for future bells&whistles) "<<endl;
  NuFore<<Fcast_Cap_FirstYear<<"  #FirstYear for caps and allocations (should be after years with fixed inputs) "<<endl;

  NuFore<<Impl_Error_Std<<" # stddev of log(realized catch/target catch) in forecast (set value>0.0 to cause active impl_error)"<<endl;

  NuFore<<Do_Rebuilder<<" # Do West Coast gfish rebuilder output (0/1) "<<endl;
  NuFore<<Rebuild_Ydecl<<" # Rebuilder:  first year catch could have been set to zero (Ydecl)(-1 to set to 1999)"<<endl;
  NuFore<<Rebuild_Yinit<<" # Rebuilder:  year for current age structure (Yinit) (-1 to set to endyear+1)"<<endl;

  NuFore<<Fcast_RelF_Basis<<" # fleet relative F:  1=use first-last alloc year; 2=read seas, fleet, alloc list below"<<endl;
  NuFore<<"# Note that fleet allocation is used directly as average F if Do_Forecast=4 "<<endl;

  NuFore<<Fcast_Catch_Basis<<" # basis for fcast catch tuning and for fcast catch caps and allocation  (2=deadbio; 3=retainbio; 5=deadnum; 6=retainnum); NOTE: same units for all fleets"<<endl;

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
    if(Fcast_RelF_Basis==1)  NuFore<<"# ";
    NuFore<<"-9999 0 0  # terminator for list of relF"<<endl;
  }

  NuFore<<"# enter list of: fleet number, max annual catch for fleets with a max; terminate with fleet=-9999"<<endl;
  for(f=1;f<=Nfleet;f++)
  {
    if(Fcast_MaxFleetCatch(f)>-1 && fleet_type(f)==1) NuFore<<f<<" "<<Fcast_MaxFleetCatch(f)<<endl;
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
  " # basis for input Fcast catch: -1=read basis with each obs; 2=dead catch; 3=retained catch; 99=input apical_F; NOTE: bio vs num based on fleet's catchunits"<<endl;

  NuFore<<"#enter list of Fcast catches or Fa; terminate with line having year=-9999"<<endl;
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
  report4<<version_info2<<endl<<version_info3<<endl;
  if(N_CC>0) report4<<Control_Comments<<endl;
  report4 << "#_data_and_control_files: "<<datfilename<<" // "<<ctlfilename<<endl;
  report4<<WTage_rd<<"  # 0 means do not read wtatage.ss; 1 means read and use wtatage.ss and also read and use growth parameters"<<endl;
  report4 << N_GP << "  #_N_Growth_Patterns (Growth Patterns, Morphs, Bio Patterns, GP are terms used interchangeably in SS)"<<endl;
  report4 << N_platoon << " #_N_platoons_Within_GrowthPattern "<<endl;
  if(N_platoon==1) report4<<"#_Cond ";
  report4<<sd_ratio<<" #_Platoon_within/between_stdev_ratio (no read if N_platoons=1)"<<endl;
  if(N_platoon==1) report4<<"#_Cond ";
  report4<<platoon_distr(1,N_platoon)<<" #vector_platoon_dist_(-1_in_first_val_gives_normal_approx)"<<endl;
  report4<<"#"<<endl;
  if(finish_starter==999)
    {report4<<2<<" # recr_dist_method for parameters:  2=main effects for GP, Settle timing, Area; 3=each Settle entity; 4=none, only when N_GP*Nsettle*pop==1"<<endl;}
    else
    {report4<<recr_dist_method<<" # recr_dist_method for parameters:  2=main effects for GP, Area, Settle timing; 3=each Settle entity; 4=none (only when N_GP*Nsettle*pop==1)"<<endl;}
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
  report4<<parm_adjust_method<<" #_time-vary parm bound check (1=warn relative to base parm bounds; 3=no bound check); Also see env (3) and dev (5) options to constrain with base bounds"<<endl<<"#"<<endl;
  report4<<"# AUTOGEN"<<endl;
  report4<<autogen_timevary<<" # autogen: 1st element for biology, 2nd for SR, 3rd for Q, 4th reserved, 5th for selex"<<endl;
  report4<<"# where: 0 = autogen time-varying parms of this category; 1 = read each time-varying parm line; 2 = read then autogen if parm min==-12345"<<endl;

  report4<<"#"<<endl<<"#_Available timevary codes"<<endl;
  report4<<"#_Block types: 0: P_block=P_base*exp(TVP); 1: P_block=P_base+TVP; 2: P_block=TVP; 3: P_block=P_block(-1) + TVP"<<endl;
  report4<<"#_Block_trends: -1: trend bounded by base parm min-max and parms in transformed units (beware); -2: endtrend and infl_year direct values; -3: end and infl as fraction of base range"<<endl;
  
  report4<<"#_EnvLinks:  1: P(y)=P_base*exp(TVP*env(y));  2: P(y)=P_base+TVP*env(y);  3: P(y)=f(TVP,env_Zscore) w/ logit to stay in min-max;  4: P(y)=2.0/(1.0+exp(-TVP1*env(y) - TVP2))"<<endl;
  report4<<"#_DevLinks:  1: P(y)*=exp(dev(y)*dev_se;  2: P(y)+=dev(y)*dev_se;  3: random walk;  4: zero-reverting random walk with rho;  5: like 4 with logit transform to stay in base min-max"<<endl
         <<"#_DevLinks(more):  21-25 keep last dev for rest of years"<<endl<<"#"<<endl;
  report4<<"#_Prior_codes:  0=none; 6=normal; 1=symmetric beta; 2=CASAL's beta; 3=lognormal; 4=lognormal with biascorr; 5=gamma"<<endl;
  report4<<"#"<<endl<<"# setup for M, growth, wt-len, maturity, fecundity, (hermaphro), recr_distr, cohort_grow, (movement), (age error), (catch_mult), sex ratio "<<endl;
  report4<<"#_NATMORT"<<endl<<natM_type<<" #_natM_type:_0=1Parm; 1=N_breakpoints;_2=Lorenzen;_3=agespecific;_4=agespec_withseasinterpolate;_5=BETA:_Maunder_link_to_maturity"<<endl;
    if(natM_type==0)
    {report4<<"  #_no additional input for selected M option; read 1P per morph"<<endl;}
    else if(natM_type==1)
    {report4<<N_natMparms<<" #_N_breakpoints"<<endl<<NatM_break<<" # age(real) at M breakpoints"<<endl;}
    else if(natM_type==2)
    {report4<<natM_amin<<" #_reference age for Lorenzen M; read 1P per morph"<<endl;}
    else if(natM_type>=3 && natM_type<5)
    {report4<<" #_Age_natmort_by sex x growthpattern (nest GP in sex)"<<endl<<Age_NatMort<<endl;}
    else
    {report4<<natM_5_opt<<"  #_BETA: Maunder_M suboptions: 1 (4 parm per sex*GP, using age_maturity), 2 (4 parm, same), 3 (6 parm)"<<endl;}
    report4<<"#"<<endl;
    report4<<Grow_type<<" # GrowthModel: 1=vonBert with L1&L2; 2=Richards with L1&L2; 3=age_specific_K_incr; 4=age_specific_K_decr; 5=age_specific_K_each; 6=NA; 7=NA; 8=growth cessation"<<endl;
    if(Grow_type<=5 || Grow_type==8)
    {report4<<AFIX<<" #_Age(post-settlement)_for_L1;linear growth below this"<<endl<<
      AFIX2<<" #_Growth_Age_for_L2 (999 to use as Linf)"<<endl<<
      Linf_decay<<" #_exponential decay for growth above maxage (value should approx initial Z; -999 replicates 3.24; -998 to not allow growth above maxage)"<<endl;
      report4<<"0  #_placeholder for future growth feature"<<endl;
      if(Grow_type>=3 && Grow_type<=5)
      {report4<<Age_K_count<<" # number of K multipliers to read"<<endl<<Age_K_points<<" # ages for K multiplier"<<endl;}
    }
    else
    {report4<<" #_growth type not implemented"<<endl;}
    report4<<"#"<<endl;
    report4<<SD_add_to_LAA<<" #_SD_add_to_LAA (set to 0.1 for SS2 V1.x compatibility)"<<endl;   // constant added to SD length-at-age (set to 0.1 for compatibility with SS2 V1.x
    report4<<CV_depvar<<" #_CV_Growth_Pattern:  0 CV=f(LAA); 1 CV=F(A); 2 SD=F(LAA); 3 SD=F(A); 4 logSD=F(A)"<<endl;
    report4<<"#"<<endl;
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
    if (Hermaphro_Option!=0){
   report4<<Hermaphro_seas_rd<<" # Hermaphro_season.first_age (seas=-1 means all seasons; first_age must be 0 to 9)"<<endl<<Hermaphro_maleSPB<<" # fraction_of_maleSSB_added_to_total_SSB "<<endl;}
   
    report4<<MGparm_def<<" #_parameter_offset_approach for M, G, CV_G:  1- direct, no offset; 2- male=fem_parm*exp(male_parm); 3: male=female*exp(parm) then old=young*exp(parm)"<<endl;
  report4<<"#"<<endl;
  report4<<"#_growth_parms";
  if(N_GP>1) report4<<";  if N_GP>1, then nest GP within sex in parameters below";
  report4<<endl;
  report4<<"#_ LO HI INIT PRIOR PR_SD PR_type PHASE env_var&link dev_link dev_minyr dev_maxyr dev_PH Block Block_Fxn"<<endl;
  NP=0;
  for (gg=1;gg<=gender;gg++)
  {
    for (gp=1;gp<=N_GP;gp++)
    {
      report4<<"# Sex: "<<gg<<"  BioPattern: "<<gp<<"  NatMort"<<endl;
      for (k=1;k<=N_natMparms;k++)
      {
        NP++;
        MGparm_1(NP,3)=value(MGparm(NP));
        report4<<MGparm_1(NP)<<" # "<<ParmLabel(NP)<<endl;
      }
      report4<<"# Sex: "<<gg<<"  BioPattern: "<<gp<<"  Growth"<<endl;
      for (k=1;k<=N_growparms;k++)
      {
        NP++;
        MGparm_1(NP,3)=value(MGparm(NP));
        report4<<MGparm_1(NP)<<" # "<<ParmLabel(NP)<<endl;
      }
      report4<<"# Sex: "<<gg<<"  BioPattern: "<<gp<<"  WtLen"<<endl;
      for (k=1;k<=2;k++)
      {
        NP++;
        MGparm_1(NP,3)=value(MGparm(NP));
        report4<<MGparm_1(NP)<<" # "<<ParmLabel(NP)<<endl;
      }
      if(gg==1)
      {
        report4<<"# Sex: "<<gg<<"  BioPattern: "<<gp<<"  Maturity&Fecundity"<<endl;
        for (k=1;k<=4;k++)
        {
          NP++;
          MGparm_1(NP,3)=value(MGparm(NP));
          report4<<MGparm_1(NP)<<" # "<<ParmLabel(NP)<<endl;
        }
      }
    }
  }
      report4<<"# Hermaphroditism"<<endl;
      if(Hermaphro_Option!=0)
      {
        for (k=1;k<=3;k++)
        {
          NP++;
          MGparm_1(NP,3)=value(MGparm(NP));
          report4<<MGparm_1(NP)<<" # "<<ParmLabel(NP)<<endl;
        }
      }
      
      report4<<"#  Recruitment Distribution  "<<endl;
      j=NP+1;
      if(MGP_CGD>j)
      {
        for (k=j;k<=MGP_CGD-1;k++)
        {
          NP++;
          MGparm_1(NP,3)=value(MGparm(NP));
          report4<<MGparm_1(NP)<<" # "<<ParmLabel(NP)<<endl;
        }
      }
      
      report4<<"#  Cohort growth dev base"<<endl;
      NP++;
      MGparm_1(NP,3)=value(MGparm(NP));
      report4<<MGparm_1(NP)<<" # "<<ParmLabel(NP)<<endl;

      report4<<"#  Movement"<<endl;
      if(do_migration>0)
      {
        for (k=1;k<=2*do_migration;k++)
        {
          NP++;
          MGparm_1(NP,3)=value(MGparm(NP));
          report4<<MGparm_1(NP)<<" # "<<ParmLabel(NP)<<endl;
        }
      }

      report4<<"#  Age Error from parameters"<<endl;
      if(Use_AgeKeyZero>0)
      {
        for (k=1;k<=7;k++)
        {
          NP++;
          MGparm_1(NP,3)=value(MGparm(NP));
          report4<<MGparm_1(NP)<<" # "<<ParmLabel(NP)<<endl;
        }
      }

      report4<<"#  catch multiplier"<<endl;
      if(catch_mult_pointer>0)
      {
        for (k=1;k<=Nfleet;k++)
        if(need_catch_mult(k)==1)
        {
          NP++;
          MGparm_1(NP,3)=value(MGparm(NP));
          report4<<MGparm_1(NP)<<" # "<<ParmLabel(NP)<<endl;
        }
      }

//  for (f=1;f<=N_MGparm;f++)
//  {
//    NP++;
//    MGparm_1(f,3)=value(MGparm(f));
//    report4<<MGparm_1(f)<<" # "<<ParmLabel(NP)<<endl;
//  }
      report4<<"#  fraction female, by GP"<<endl;

  if(frac_female_pointer == -1)  //  3.24 format
  {
    // placeholders to change fracfemale (3.24) to MGparm (3.30)
    for (gp=1;gp<=N_GP;gp++)
    {
        report4 << " 0.000001 0.999999 " << femfrac(gp) << " 0.5  0.5 0 -99 0 0 0 0 0 0 0 " << "# FracFemale_GP_" << gp << endl;
    }
  }
  else
  {
    for (gp=1;gp<=N_GP;gp++)
    {
          NP++;
          MGparm_1(NP,3)=value(MGparm(NP));
          report4<<MGparm_1(NP)<<" # "<<ParmLabel(NP)<<endl;
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
   report4<<SR_fxn<<" #_Spawner-Recruitment; Options: 1=NA; 2=Ricker; 3=std_B-H; 4=SCAA; 5=Hockey; 6=B-H_flattop; 7=survival_3Parm; 8=Shepherd_3Parm; 9=RickerPower_3parm"<<endl;
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
       report4<<"# timevary SR parameters"<<endl;
       for (f=timevary_parm_start_SR;f<=timevary_parm_cnt_SR;f++)
       {
          NP++;
          timevary_parm_rd[f](3)=value(timevary_parm(f));
          report4<<timevary_parm_rd[f]<<" # "<<ParmLabel(NP)<<endl;
       }
       report4.precision(6); report4.unsetf(std::ios_base::fixed); report4.unsetf(std::ios_base::floatfield);
    }
    else
    {
       report4<<"#_no timevary SR parameters"<<endl;
    }

   report4<<do_recdev<<" #do_recdev:  0=none; 1=devvector (R=F(SSB)+dev); 2=deviations (R=F(SSB)+dev); 3=deviations (R=R0*dev; dev2=R-f(SSB)); 4=like 3 with sum(dev2) adding penalty"<<endl;
   report4<<recdev_start<<" # first year of main recr_devs; early devs can preceed this era"<<endl;
   report4<<recdev_end<<" # last year of main recr_devs; forecast devs start in following year"<<endl;
   report4<<recdev_PH_rd<<" #_recdev phase "<<endl;
   report4<<recdev_adv<<" # (0/1) to read 13 advanced options"<<endl;
   if(recdev_adv==0) {onenum="#_Cond ";} else {onenum=" ";}
   report4<<onenum<<recdev_early_start_rd<<" #_recdev_early_start (0=none; neg value makes relative to recdev_start)"<<endl;
   report4<<onenum<<recdev_early_PH_rd<<" #_recdev_early_phase"<<endl;
   report4<<onenum<<Fcast_recr_PH_rd<<" #_forecast_recruitment phase (incl. late recr) (0 value resets to maxphase+1)"<<endl;
   report4<<onenum<<Fcast_recr_lambda<<" #_lambda for Fcast_recr_like occurring before endyr+1"<<endl;
   report4<<onenum<<recdev_adj(1)<<" #_last_yr_nobias_adj_in_MPD; begin of ramp"<<endl;
   report4<<onenum<<recdev_adj(2)<<" #_first_yr_fullbias_adj_in_MPD; begin of plateau"<<endl;
   report4<<onenum<<recdev_adj(3)<<" #_last_yr_fullbias_adj_in_MPD"<<endl;
   report4<<onenum<<recdev_adj(4)<<" #_end_yr_for_ramp_in_MPD (can be in forecast to shape ramp, but SS sets bias_adj to 0.0 for fcast yrs)"<<endl;
   report4<<onenum<<recdev_adj(5)<<" #_max_bias_adj_in_MPD (typical ~0.8; -3 sets all years to 0.0; -2 sets all non-forecast yrs w/ estimated recdevs to 1.0; -1 sets biasadj=1.0 for all yrs w/ recdevs)"<<endl;
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

    if(Do_Forecast>0 && do_recdev>0)
    {
      for (y=recdev_end+1;y<=YrMax;y++)  {NP++;  report4<<" "<<recdev(y);}
      report4<<endl;
      if(Do_Impl_Error>0){
      report4<<"# implementation error by year in forecast: ";
      for (y=endyr+1;y<=YrMax;y++)
      {
        NP++;  report4<<" "<<Fcast_impl_error(y);
      }
      report4<<endl;
      }
    }
  report4<<"#"<<endl;
  report4<<"#Fishing Mortality info "<<endl<<F_ballpark<<" # F ballpark value in units of annual_F"<<endl;
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
   report4<<"#_initial_F_parms; for each fleet x season that has init_catch; nest season in fleet; count = "<<N_init_F2<<endl;
   report4<<"#_for unconstrained init_F, use an arbitrary initial catch and set lambda=0 for its logL"<<endl;
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
   else if(N_init_F2>0)
   {
     for (f=1;f<=N_init_F2;f++)
     {
      NP++;
      init_F_parm_1(f,3)=value(init_F(f));
      report4<<init_F_parm_1(f)<<" # "<<ParmLabel(NP)<<endl;
     }
   }

    report4<<"#"<<endl<<"# F rates by fleet x season"<<endl;
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
   report4<<"#_1:  fleet number"<<endl;
   report4<<"#_2:  link type: (1=simple q, 1 parm; 2=mirror simple q, 1 mirrored parm; 3=q and power, 2 parm; 4=mirror with offset, 2 parm)"<<endl;
   report4<<"#_3:  extra input for link, i.e. mirror fleet# or dev index number"<<endl;
   report4<<"#_4:  0/1 to select extra sd parameter"<<endl;
   report4<<"#_5:  0/1 for biasadj or not"<<endl;
   report4<<"#_6:  0/1 to float"<<endl;
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

   report4<<"#Pattern:_0;  parm=0; selex=1.0 for all sizes"<<endl;
   report4<<"#Pattern:_1;  parm=2; logistic; with 95% width specification"<<endl;
   report4<<"#Pattern:_5;  parm=2; mirror another size selex; PARMS pick the min-max bin to mirror"<<endl;
   report4<<"#Pattern:_11; parm=2; selex=1.0  for specified min-max population length bin range"<<endl;
   report4<<"#Pattern:_15; parm=0; mirror another age or length selex"<<endl;
   report4<<"#Pattern:_6;  parm=2+special; non-parm len selex"<<endl;
   report4<<"#Pattern:_43; parm=2+special+2;  like 6, with 2 additional param for scaling (average over bin range)"<<endl;
   report4<<"#Pattern:_8;  parm=8; double_logistic with smooth transitions and constant above Linf option"<<endl;
   report4<<"#Pattern:_9;  parm=6; simple 4-parm double logistic with starting length; parm 5 is first length; parm 6=1 does desc as offset"<<endl;
   report4<<"#Pattern:_21; parm=2+special; non-parm len selex, read as pairs of size, then selex"<<endl;
   report4<<"#Pattern:_22; parm=4; double_normal as in CASAL"<<endl;
   report4<<"#Pattern:_23; parm=6; double_normal where final value is directly equal to sp(6) so can be >1.0"<<endl;
   report4<<"#Pattern:_24; parm=6; double_normal with sel(minL) and sel(maxL), using joiners"<<endl;
   report4<<"#Pattern:_25; parm=3; exponential-logistic in size"<<endl;
   report4<<"#Pattern:_27; parm=3+special; cubic spline "<<endl;
   report4<<"#Pattern:_42; parm=2+special+3; // like 27, with 2 additional param for scaling (average over bin range)"<<endl;
   
   report4<<"#_discard_options:_0=none;_1=define_retention;_2=retention&mortality;_3=all_discarded_dead;_4=define_dome-shaped_retention"<<endl;
   report4<<"#_Pattern Discard Male Special"<<endl;
   for (f=1;f<=Nfleet;f++) report4<<seltype_rd(f)<<" # "<<f<<" "<<fleetname(f)<<endl;
   report4<<"#"<<endl;
   
   
   report4<<"#_age_selex_patterns"<<endl;
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
   report4<<"#Pattern:_42; parm=2+special+3; // cubic spline; with 2 additional param for scaling (average over bin range)"<<endl;
   report4<<"#Age patterns entered with value >100 create Min_selage from first digit and pattern from remainder"<<endl;
   report4<<"#_Pattern Discard Male Special"<<endl;
   for (f=1;f<=Nfleet;f++) report4<<seltype_rd(f+Nfleet)<<" # "<<f<<" "<<fleetname(f)<<endl;
   report4<<"#"<<endl;

   report4<<"#_          LO            HI          INIT         PRIOR         PR_SD       PR_type      PHASE    env-var    use_dev   dev_mnyr   dev_mxyr     dev_PH      Block    Blk_Fxn  #  parm_name"<<endl;

   // set back to default configuration for output
   report4.unsetf(std::ios_base::fixed); report4.unsetf(std::ios_base::floatfield);

  {
    k=0;
    for(f=1;f<=2*Nfleet;f++)
    {
      if(f>Nfleet) {f1=f-Nfleet; anystring="AgeSelex";} else {f1=f;anystring="LenSelex";}
      report4<<"# "<<f1<<"   "<<fleetname(f1)<<" "<<anystring<<endl;
      for (j=1;j<=N_selparmvec(f);j++)
      {
        NP++;
        k++;
        selparm_1(k)(3)=value(selparm(k));
        for(z=1;z<=6;z++) report4<<setw(14)<<selparm_1(k,z);
        for(z=7;z<=14;z++) report4<<setw(11)<<selparm_1(k,z);
        report4<<"  #  "<<ParmLabel(NP)<<endl;
      }
    }
    if(Comp_Err_ParmCount>0)
    {
      report4<<"#_Dirichlet parameters"<<endl;
      k=Comp_Err_Parm_Start;
      for(f=1;f<=Comp_Err_ParmCount;f++)
      {
          k++; NP++;
          selparm_1(k)(3)=value(selparm(k));
          for(z=1;z<=6;z++) report4<<setw(14)<<selparm_1(k,z);
          for(z=7;z<=14;z++) report4<<setw(11)<<selparm_1(k,z);
          report4<<"  #  "<<ParmLabel(NP)<<endl;
      }
    }
    {
      report4<<"#_No_Dirichlet parameters"<<endl;
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

  report4<<"#"<<endl<<TwoD_AR_do<<"   #  use 2D_AR1 selectivity(0/1)"<<endl;
  if(TwoD_AR_do>0)
  {
    k=timevary_parm_start_sel+N_selparm3-N_selparm-1;  //  starting point in timevary_parm_rd
    report4<<"#_specifications for 2D_AR1 and associated parameters"<<endl;
    report4<<"#_specs:  fleet, ymin, ymax, amin, amax, sigma_amax, use_rho, len1/age2, devphase, before_range, after_range"<<endl;
    report4<<"#_sigma_amax>amin means create sigma parm for each bin from min to sigma_amax; sigma_amax<0 means just one sigma parm is read and used for all bins"<<endl;
    for(j=1; j<=TwoD_AR_cnt; j++)
    {
       ivector tempvec(1,11);  //  fleet, ymin, ymax, amin, amax, sigma_amax, use_rho, len1/age2, devphase
       tempvec(1,11)=TwoD_AR_def[j](1,11);
       tempvec(6)=TwoD_AR_def_rd[j](6);  //  restore the read value in case it got changed
        if(tempvec(8)==1)
        {anystring="LEN";}
        else
        {anystring="AGE";}

       report4<<tempvec<<"  #  2d_AR specs for fleet: "<<fleetname(tempvec(1))<<" "<<anystring<<endl;
       int sigma_amax = tempvec(6);
       int use_rho = tempvec(7);
       int amin = tempvec(4);
       for(a=amin;a<=sigma_amax;a++)
       {
         dvector dtempvec(1,7);  //  Lo, Hi, init, prior, prior_sd, prior_type, phase;
         k++;
         dtempvec=timevary_parm_rd[k](1,7);
         report4<<dtempvec<<"  # sigma_sel for fleet:_"<<tempvec(1)<<"; "<<anystring<<"_"<<a<<endl;
       }
       if(use_rho==1)
       {
         dvector dtempvec(1,7);  //  Lo, Hi, init, prior, prior_sd, prior_type, phase;
         k++;
         dtempvec=timevary_parm_rd[k](1,7);
         report4<<dtempvec<<"  # rho_year for fleet:_"<<tempvec(1)<<endl;
         k++;
         dtempvec=timevary_parm_rd[k](1,7);
         report4<<dtempvec<<"  # rho_"<<anystring<<" for fleet:_"<<tempvec(1)<<endl;
       }
    }
    report4<<"-9999  0 0 0 0 0 0 0 0 0 0 # terminator"<<endl;
  }
  else
  {
    report4<<"#_no 2D_AR1 selex offset used"<<endl;
  }

  report4.unsetf(std::ios_base::fixed); report4.unsetf(std::ios_base::floatfield);
  }

  j=N_selparm;

  report4<<"#"<<endl<<"# Tag loss and Tag reporting parameters go next"<<endl;
  if(Do_TG>0)
  {
    report4<<1<<" # TG_custom:  0=no read and autogen if tag data exist; 1=read"<<endl;
    report4<<"#_Note -  tag parameters cannot be time-varying"<<endl;
    report4<<"#_Note -  phase=-1000 sets parm value to previous parm; phase=-100X sets to parm(X) value"<<endl;
    for (f=1;f<=3*N_TG+2*Nfleet1;f++)
    {
      NP++;
      report4<<TG_parm2(f)(1,2)<<" "<<TG_parm(f)<<" "<<TG_parm2(f)(4,14)<<" # "<<ParmLabel(NP)<<endl;
    }
  }
  else
  {
    report4<<"0  # TG_custom:  0=no read and autogen if tag data exist; 1=read"<<endl
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
   endl<<"# 10=recrdev; 11=parm_prior; 12=parm_dev; 13=CrashPen; 14=Morphcomp; 15=Tag-comp; 16=Tag-negbin; 17=F_ballpark; 18=initEQregime"<<
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
  for (f=1;f<=Nfleet;f++) report4<<"# "<< init_equ_lambda(f)<<" #_init_equ_catch"<<f<<endl;
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

  report4<<Do_More_Std<<" # (0/1/2) read specs for more stddev reporting: 0 = skip, 1 = read specs for reporting stdev for selectivity, size, and numbers, 2 = add options for M,Dyn. Bzero, SmryBio"<<endl;

//3868      Do_Selex_Std=More_Std_Input(1);
//3869      Selex_Std_AL=More_Std_Input(2);
//3870      Selex_Std_Year=More_Std_Input(3);
//3872      Selex_Std_Cnt=More_Std_Input(4);
//3873      Do_Growth_Std=More_Std_Input(5);
//3875      Growth_Std_Cnt=More_Std_Input(6);
//3876      Do_NatAge_Std=More_Std_Input(7);
//3877      NatAge_Std_Year=More_Std_Input(8);
//3879      NatAge_Std_Cnt=More_Std_Input(9);

  if(Do_More_Std==0) // empty/dummy values when extra stddev reporting not used
  {
    report4<<" # 0 2 0 0 # Selectivity: (1) fleet, (2) 1=len/2=age/3=both, (3) year, (4) N selex bins"<<endl;
    report4<<" # 0 0 # Growth: (1) growth pattern, (2) growth ages"<<endl;
    report4<<" # 0 0 0 # Numbers-at-age: (1) area(-1 for all), (2) year, (3) N ages"<<endl;
    report4<<" # -1 # list of bin #'s for selex std (-1 in first bin to self-generate)"<<endl;
    report4<<" # -1 # list of ages for growth std (-1 in first bin to self-generate)"<<endl;
    report4<<" # -1 # list of ages for NatAge std (-1 in first bin to self-generate)"<<endl;
  }
  if(Do_More_Std > 0) // these outputs needed for options 1 and 2
  {
//    report4<<More_Std_Input<<" # selex_fleet, 1=len/2=age/3=both, year, N selex bins, 0 or Growth pattern, N growth ages, 0 or NatAge_area(-1 for sum), NatAge_yr, N Natages"<<endl;
    report4<<More_Std_Input(1,4)<<" # Selectivity: (1) 0 to skip or fleet, (2) 1=len/2=age/3=combined, (3) year, (4) N selex bins; NOTE: combined reports in age bins"<<endl;
    report4<<More_Std_Input(5,6)<<" # Growth: (1) 0 to skip or growth pattern, (2) growth ages; NOTE: does each sex"<<endl;
    report4<<More_Std_Input(7,9)<<" # Numbers-at-age: (1) 0 or area(-1 for all), (2) year, (3) N ages;  NOTE: sums across morphs"<<endl;
  } 
  if(Do_More_Std==2) // additional output when option 2 is selected
  {
    report4<<More_Std_Input(10,11)<<" # Mortality: (1) 0 to skip or growth pattern, (2) N ages for mortality; NOTE: does each sex"<<endl;
    report4<<More_Std_Input(12)<<" # Dyn Bzero: 0 to skip, 1 to include, or 2 to add recr"<<endl;
    report4<<More_Std_Input(13)<<" # SmryBio: 0 to skip, 1 to include"<<endl;
  }
  if(Do_More_Std > 0) // vectors associated with options 1 and 2
  {
    if(Do_Selex_Std>0){
      report4<<Selex_Std_Pick<<" # vector with selex std bins (-1 in first bin to self-generate)"<<endl;
    }else{
      report4<<" # -1 # list of bin #'s for selex std (-1 in first bin to self-generate)"<<endl;
    }
//    if(Do_Growth_Std>0){
    if(More_Std_Input(5)>0){
      report4<<Growth_Std_Pick<<" # vector with growth std ages picks (-1 in first bin to self-generate)"<<endl;
    }else{
      report4<<" # -1 # list of ages for growth std (-1 in first bin to self-generate)"<<endl;
    }
    if(Do_NatAge_Std!=0){
      report4<<NatAge_Std_Pick<<" # vector with NatAge std ages (-1 in first bin to self-generate)"<<endl;
    }else{
      report4<<" # -1 # list of ages for NatAge std (-1 in first bin to self-generate)"<<endl;
    }
    if(Do_More_Std==2) // additional output when option 2 is selected
    {
      if(Do_NatM_Std>0){
        report4<<NatM_Std_Pick<<" # vector with NatM std ages picks (-1 in first bin to self-generate)"<<endl;
      }else{
        report4<<" # -1 # list of ages for NatM std (-1 in first bin to self-generate)"<<endl;
      }
    }
  }
  report4<<fim<<endl<<endl; // end of file indicator
  return;
  }  //  end of write nucontrol
