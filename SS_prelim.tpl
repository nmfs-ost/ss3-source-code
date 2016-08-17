//******************************************************************************************
//  SS_Label_Section_6.0 #PRELIMINARY_CALCS_SECTION
PRELIMINARY_CALCS_SECTION
  {
//  SS_Label_Info_6.1 #Some initial housekeeping
//  SS_Label_Info_6.1.1 #Create and initialize random number generator
  random_number_generator radm(long(time(&start)));
  if(F_ballpark_yr>retro_yr) F_ballpark_yr=retro_yr;
  if(F_ballpark_yr<styr) {F_ballpark_lambda=0.;}
  sel_l.initialize();
  sel_a.initialize();
  offset_l.initialize();
  offset_a.initialize();
  save_sp_len.initialize();
  save_sel_fec.initialize();
  catch_mult=1.0;

//  SS_Label_Info_6.1.2 #Initialize the dummy parameter as needed
  if(Turn_off_phase<=0) {dummy_parm=0.5;} else {dummy_parm=1.0;}

  Cohort_Growth=1.0;    // adjustment for cohort growth deviations

//  SS_Label_Info_6.2 #Apply input variance adjustments to each data type
//  SS_Label_Info_6.2.1 #Do variance adjustment for surveys

  echoinput<<" do variance adjustment for surveys "<<endl;
  for (f=1; f<=Nfleet; f++)
  if(Svy_N_fleet(f)>0)
  {
    for (i=1; i<=Svy_N_fleet(f); i++)
    {
      if(Svy_use(f,i)>0)
      {
        if(Svy_errtype(f)>=0)  // lognormal or lognormal T_dist
        {
          if(Svy_obs(f,i)<=0.0)
          {N_warn++; cout<<" EXIT - see warning "<<endl; warning<<"Survey obs must be positive for lognormal error"<<endl; exit(1);}
          Svy_obs_log(f,i)=log(Svy_obs(f,i));
          Svy_se_rd(f,i)+=var_adjust(1,f);
          if(Svy_se_rd(f,i)<=0.0) Svy_se_rd(f,i)=0.001;
        }
        else  // normal distribution
        {
          Svy_se_rd(f,i)+=var_adjust(1,f);
          if(Svy_se_rd(f,i)<=0.0) Svy_se_rd(f,i)=0.001;
        }
      }
    }
  }
  echoinput<<" survey stderr has been set-up "<<endl;

//  SS_Label_Info_6.2.2 #Set up variance for discard observations
  for (f=1; f<=Nfleet; f++)
  if(disc_N_fleet(f)>0)
  {
    for (i=1; i<=disc_N_fleet(f); i++)
    {
      if(yr_disc_use(f,i)>=0.)
      {
        if(cv_disc(f,i)<=0.0) cv_disc(f,i)=0.001;
        if(disc_errtype(f)>=0)
        {sd_disc(f,i)=cv_disc(f,i)*obs_disc(f,i);}
        else
        {sd_disc(f,i)=cv_disc(f,i);}

        sd_disc(f,i)+=var_adjust(2,f);   // note that adjustment is to the sd, not the CV
        if(sd_disc(f,i)<0.001) sd_disc(f,i)=0.001;
      }
    }
  }
  echoinput<<" discard stderr has been set-up "<<endl;

//  SS_Label_Info_6.2.3 #Set up variance for mean body wt data, note different reference to array that was read
  for (i=1;i<=nobs_mnwt;i++)
  {
    if(mnwtdata(5,i)>0. && mnwtdata(3,i)>0.)  //  used observation
    {
      mnwtdata(6,i)+=var_adjust(3,mnwtdata(3,i));
      if(mnwtdata(6,i)<=0.0) mnwtdata(6,i)=0.001;
      mnwtdata(7,i)=mnwtdata(5,i)*mnwtdata(6,i);
      mnwtdata(8,i)=DF_bodywt*square(mnwtdata(7,i));
      mnwtdata(9,i)=sd_offset*log(mnwtdata(7,i));
    }
  }
  echoinput<<" mean bodywt stderr has been set-up "<<endl;

//  SS_Label_Info_6.2.4 #Do variance adjustment and compute OFFSET for length comp
  if(Nobs_l_tot>0)
  for (f=1; f <= Nfleet; f++)
  for (i=1; i <= Nobs_l(f); i++)
  if(header_l(f,i,3)>0)
  {
    nsamp_l(f,i)*=var_adjust(4,f);  {if(nsamp_l(f,i)<=1.0) nsamp_l(f,i)=1.;}                              //  adjust sample size
    if(gen_l(f,i) !=2) offset_l(f,i) -= nsamp_l(f,i) *
    obs_l(f,i)(tails_l(f,i,1),tails_l(f,i,2))*log(obs_l(f,i)(tails_l(f,i,1),tails_l(f,i,2)));
    if(gen_l(f,i) >=2 && gender==2) offset_l(f,i) -= nsamp_l(f,i) *
    obs_l(f,i)(tails_l(f,i,3),tails_l(f,i,4))*log(obs_l(f,i)(tails_l(f,i,3),tails_l(f,i,4)));
  }
//  echoinput<<" length_comp offset: "<<offset_l<<endl;
  echoinput<<" length comp var adjust has been set-up "<<endl;

//  SS_Label_Info_6.2.4.1 #Get sample weights for the super-period components in length comp
//  the combined obs will have a logL sample size equal to the sample size input for the accumulator observation
//  the accumulator observation is assigned a weight of 1.0 (because there is no place to read this from)
//  the obs to be combined with the accumulator get a weight equal to value input in the nsamp_l element
//  so, nsamp_l can no longer have negative observations
  for (f=1; f<=Nfleet; f++)
  {
    if(Svy_super_N(f)>0)
    {
      echoinput<<"Create superperiod sample weights for survey obs"<<endl<<"Fleet Super Obs SE_input samp_wt"<<endl;
      for (j=1;j<=Svy_super_N(f);j++)                  // do each super period
      {
        temp=1.0;  //  relative sample weight for time period the accumulator observation
        k=0;  // count of samples with real information
        for (i=Svy_super_start(f,j);i<=Svy_super_end(f,j);i++)  //  loop obs of this super period
        {
          if(Svy_use(f,i)<0)  //  so one of the obs to be combined
          {temp+=Svy_se_rd(f,i);}  //  add in its weight relative to 1.0 for the observation with real info
          else
          {k++;}
        }
        if(k!=1) {N_warn++; cout<<"EXIT - see warning.sso"; warning<<" must have only 1 sample with real info in survey superperiod "<<j<<endl; exit(1);}
        for (i=Svy_super_start(f,j);i<=Svy_super_end(f,j);i++)
        {
          if(Svy_use(f,i)<0)  //  so one of the obs to be combined
          {Svy_super_weight(f,i)=Svy_se_rd(f,i)/value(temp);}
          else
          {Svy_super_weight(f,i)=1.0/value(temp);}
          echoinput<<f<<" "<<j<<" "<<i<<" "<<Svy_use(f,i)<<" "<<Svy_se_rd(f,i)<<" "<<Svy_super_weight(f,i)<<endl;
        }
      }
    }

    if(N_suprper_disc(f)>0)
    {
      echoinput<<"Create superperiod sample weights for discard obs"<<endl<<"fleet Super Obs SE_input samp_wt"<<endl;
      for (j=1;j<=N_suprper_disc(f);j++)                  // do each super period
      {
        temp=1.0;  //  relative sample weight for time period the accumulator observation
        k=0;  // count of samples with real information
        for (i=suprper_disc1(f,j);i<=suprper_disc2(f,j);i++)  //  loop obs of this super period
        {
          if(yr_disc_use(f,i)<0)  //  so one of the obs to be combined
          {temp+=cv_disc(f,i);}  //  add in its weight relative to 1.0 for the observation with real info
          else
          {k++;}
        }
        if(k!=1) {N_warn++; cout<<"EXIT - see warning.sso"; warning<<" must have only 1 sample with real info in survey superperiod "<<j<<endl; exit(1);}
        for (i=suprper_disc1(f,j);i<=suprper_disc2(f,j);i++)
        {
          if(yr_disc_use(f,i)<0)  //  so one of the obs to be combined
          {suprper_disc_sampwt(f,i)=cv_disc(f,i)/value(temp);}
          else
          {suprper_disc_sampwt(f,i)=1.0/value(temp);}
          echoinput<<f<<" "<<j<<" "<<i<<" "<<yr_disc_use(f,i)<<" "<<cv_disc(f,i)<<" "<<suprper_disc_sampwt(f,i)<<endl;
        }
      }
    }

    if(N_suprper_l(f)>0)
    {
      echoinput<<"Create superperiod sample weights for length obs"<<endl<<"Super Obs effN_input samp_wt"<<endl;
      for (j=1;j<=N_suprper_l(f);j++)                  // do each super period
      {
        temp=1.0;  //  relative sample weight for time period the accumulator observation
        k=0;  // count of samples with real information
        for (i=suprper_l1(f,j);i<=suprper_l2(f,j);i++)  //  loop obs of this super period
        {
          if(header_l(f,i,3)<0)  //  so one of the obs to be combined
          {temp+=nsamp_l(f,i);}
          else
          {k++;}
        }
        if(k!=1) {N_warn++; cout<<"error in length data"; warning<<" must have only 1 sample with real info in length superperiod "<<j<<endl; exit(1);}
        for (i=suprper_l1(f,j);i<=suprper_l2(f,j);i++)
        {
          if(header_l(f,i,3)<0)  //  so one of the obs to be combined
          {suprper_l_sampwt(f,i)=nsamp_l(f,i)/value(temp);}
          else
          {suprper_l_sampwt(f,i)=1.0/value(temp);}
          echoinput<<f<<" "<<j<<" "<<i<<" "<<header_l(f,i,3)<<" "<<nsamp_l(f,i)<<" "<<suprper_l_sampwt(f,i)<<endl;
        }
      }
    }

    if(N_suprper_a(f)>0)
    {
      echoinput<<"Create superperiod sample weights for age obs"<<endl<<"Super Obs effN_input samp_wt"<<endl;
      for (j=1;j<=N_suprper_a(f);j++)                  // do each super period
      {
        temp=1.0;  //  relative sample weight for time period the accumulator observation
        k=0;  // count of samples with real information
        for (i=suprper_a1(f,j);i<=suprper_a2(f,j);i++)  //  loop obs of this super period
        {
          if(header_a(f,i,3)<0)  //  so one of the obs to be combined
          {temp+=nsamp_a(f,i);}
          else
          {k++;}
        }
        if(k!=1) {N_warn++; cout<<"error in age data"; warning<<" must have only 1 sample with real info in age superperiod "<<j<<endl; exit(1);}
        for (i=suprper_a1(f,j);i<=suprper_a2(f,j);i++)
        {
          if(header_a(f,i,3)<0)  //  so one of the obs to be combined
          {suprper_a_sampwt(f,i)=nsamp_a(f,i)/value(temp);}
          else
          {suprper_a_sampwt(f,i)=1.0/value(temp);}  //  for the element holding the combined observation
          echoinput<<f<<" "<<j<<" "<<i<<" "<<header_a(f,i,3)<<" "<<nsamp_a(f,i)<<" "<<suprper_a_sampwt(f,i)<<endl;
        }
      }
    }
    if(N_suprper_ms(f)>0)
    {
      echoinput<<"Create superperiod sample weights for meansize obs"<<endl<<"Super Obs effN_input samp_wt"<<endl;
      for (j=1;j<=N_suprper_ms(f);j++)                  // do each super period
      {
        temp=1.0;  //  relative sample weight for time period the accumulator observation
        k=0;  // count of samples with real information
        for (i=suprper_ms1(f,j);i<=suprper_ms2(f,j);i++)  //  loop obs of this super period
        {
          if(header_ms(f,i,3)<0)  //  so one of the obs to be combined
          {temp+=header_ms(f,i,7);}
          else
          {k++;}
        }
        if(k!=1) {N_warn++; cout<<"error in meansize data"; warning<<" must have only 1 sample with real info in meansize superperiod "<<j<<endl; exit(1);}
        for (i=suprper_ms1(f,j);i<=suprper_ms2(f,j);i++)
        {
          if(header_ms(f,i,3)<0)  //  so one of the obs to be combined
          {suprper_ms_sampwt(f,i)=header_ms(f,i,7)/value(temp);}
          else
          {suprper_ms_sampwt(f,i)=1.0/value(temp);}  //  for the element holding the combined observation
          echoinput<<f<<" "<<j<<" "<<i<<" "<<header_ms(f,i,3)<<" "<<header_ms(f,i,7)<<" "<<suprper_ms_sampwt(f,i)<<endl;
        }
      }
    }
  }

//  SS_Label_Info_6.2.5 #Do variance adjustment and compute OFFSET for age comp
  if(Nobs_a_tot>0)
  for (f=1; f <= Nfleet; f++)
  for (i=1; i <= Nobs_a(f); i++)
  if(header_a(f,i,3)>0)
  {
    nsamp_a(f,i)*=var_adjust(5,f);
    {if(nsamp_a(f,i)<=1.0) nsamp_a(f,i)=1.;}                                //  adjust sample size
  if(gen_a(f,i) !=2) offset_a(f,i) -= nsamp_a(f,i) *
    obs_a(f,i)(tails_a(f,i,1),tails_a(f,i,2))*log(obs_a(f,i)(tails_a(f,i,1),tails_a(f,i,2)));
  if(gen_a(f,i) >=2 && gender==2) offset_a(f,i) -= nsamp_a(f,i) *
    obs_a(f,i)(tails_a(f,i,3),tails_a(f,i,4))*log(obs_a(f,i)(tails_a(f,i,3),tails_a(f,i,4)));
  }
//   echoinput<<" agecomp offset "<<offset_a<<endl;
  echoinput<<" age comp var adjust has been set-up "<<endl;

//  SS_Label_Info_6.2.6 #Do variance adjustment for mean size-at-age data
  if(nobs_ms_tot>0)
  {for (f=1; f <= Nfleet; f++)
  for (i=1; i <= Nobs_ms(f); i++)
  for (b=1;b<=n_abins2;b++)
  {
    if(obs_ms_n(f,i,b)>0)
    {
      obs_ms_n(f,i,b)=sqrt(var_adjust(6,f)*obs_ms_n(f,i,b));
      if(obs_ms_n(f,i,b)<=1.0) obs_ms_n(f,i,b)=1.;
    }
  }
  }
  echoinput<<" setup stderr for mean size-at-age: "<<endl;

//  SS_Label_Info_6.2.7 #Input variance adjustment for generalized size comp
  if(SzFreq_Nmeth>0)
  {
    N_suprper_SzFreq=0;  // redo this counter so can use the counter

    for (iobs=1; iobs <= SzFreq_totobs; iobs++)
    {
        in_superperiod=0;

        if (var_adjust(7,SzFreq_obs1(iobs,4)) != 1.0)
        {
            SzFreq_sampleN(iobs)*=var_adjust(7,SzFreq_obs1(iobs,4));
            if (SzFreq_sampleN(iobs) < 1.0) SzFreq_sampleN(iobs) = 1.;
        }

        k=SzFreq_obs_hdr(iobs,6);  //  get the method
        f=abs(SzFreq_obs_hdr(iobs,3));
        s=SzFreq_obs_hdr(iobs,2);  // sign used to indicate start/stop of super period
        if(SzFreq_obs_hdr(iobs,3)>0)  // negative for out of range or skip
        {
            z1=SzFreq_obs_hdr(iobs,7);
            z2=SzFreq_obs_hdr(iobs,8);
            g=SzFreq_LikeComponent(f,k);
            SzFreq_like_base(g)-=SzFreq_sampleN(iobs)*SzFreq_obs(iobs)(z1,z2)*log(SzFreq_obs(iobs)(z1,z2));
        }

// identify super-period starts and stops
        if(s<0) // start/stop a super-period  ALL observations must be continguous in the file
        {
            if(in_superperiod==0)
            {
                N_suprper_SzFreq++;
                suprper_SzFreq_start(N_suprper_SzFreq)=iobs;
                in_superperiod=1;
            }
            else if(in_superperiod==1)  // end a super-period
            {
                suprper_SzFreq_end(N_suprper_SzFreq)=iobs;
                in_superperiod=0;
            }
        }
    }

    echoinput<<" gen size comp var adjust has been set-up "<<endl;

    if(N_suprper_SzFreq>0)
    {
        echoinput<<"sizefreq superperiod start obs: "<<suprper_SzFreq_start<<endl<<"sizefreq superperiod end obs:   "<<suprper_SzFreq_end<<endl;

        echoinput<<"Create superperiod sample weights for sizecomp obs "<<endl<<"Fleet Super OBS Super fleet Sample_N_read samp_wt"<<endl;
        for (j=1;j<=N_suprper_SzFreq;j++)                  // do each super period
        {
          temp=1.0;  //  relative sample weight for time period the accumulator observation
          k=0;  // count of samples with real information
          for (iobs=suprper_SzFreq_start(j);iobs<=suprper_SzFreq_end(j);iobs++)  //  loop obs of this super period
          {
            if(SzFreq_obs_hdr(iobs,3)<0)  //  so one of the obs to be combined
            {temp+=SzFreq_sampleN(iobs);}
            else
            {k++;}  //  so counts the obs that are not just placeholders
          }
          if(k!=1) {N_warn++; cout<<"error in sizecomp data"; warning<<" must have only 1 sample with real info in sizecomp superperiod "<<j<<endl; exit(1);}
          for (iobs=suprper_SzFreq_start(j);iobs<=suprper_SzFreq_end(j);iobs++)
          {
            if(SzFreq_obs_hdr(iobs,3)<0)  //  so one of the obs to be combined
            {suprper_SzFreq_sampwt(iobs)=SzFreq_sampleN(iobs)/value(temp);}
            else
            {suprper_SzFreq_sampwt(iobs)=1.0/value(temp);}  //  for the element holding the combined observation
            echoinput<<SzFreq_obs_hdr(iobs,3)<<" "<<j<<" "<<iobs<<" "<<SzFreq_sampleN(iobs)<<" "<<suprper_SzFreq_sampwt(iobs)<<endl;
          }
        }
    }
  }

//  SS_Label_Info_6.4 #Conditionally copy the initial parameter values read from the "CTL" file into the parameter arrays
//   skip this assignment if the parameters are being read from a "SS2.PAR" file

  if(readparfile==0)
  {
    echoinput<< " set parms to init values in CTL file "<<endl;
    for (i=1;i<=N_MGparm2;i++)
    {MGparm(i) = MGparm_RD(i);}  //  set vector of initial natmort and growth parms
    echoinput<< " MGparms read from ctl "<<MGparm<<endl;

    for (i=1;i<=N_SRparm2;i++)
    {SR_parm(i)=SR_parm_1(i,3);}
    echoinput<< " SRR_parms read from ctl "<<SR_parm<<endl;

    if(recdev_cycle>0)
    {
      for (y=1;y<=recdev_cycle;y++)
      {
        recdev_cycle_parm(y)=recdev_cycle_parm_RD(y,3);
      }
    }

    if(recdev_do_early>0) recdev_early.initialize();
    if(Do_Forecast>0) Fcast_recruitments.initialize();
    if(Do_Forecast>0) Fcast_impl_error.initialize();

    if(do_recdev==1)
    {recdev1.initialize();}                // set devs to zero
    else if(do_recdev==2)
    {recdev2.initialize();}                // set devs to zero

    if(recdev_read>0)
    {
      for (j=1;j<=recdev_read;j++)
      {
        y=recdev_input(j,1);
        if(y>=recdev_first && y<=YrMax)
        {
          if(y<recdev_start)
          {
            recdev_early(y)=recdev_input(j,2);
          }
          else if (y<=recdev_end)
          {
            if(do_recdev==1)
            {recdev1(y)=recdev_input(j,2);}
            else if(do_recdev==2)
            {recdev2(y)=recdev_input(j,2);}
          }
          else
          {
            Fcast_recruitments(y)=recdev_input(j,2);
          }
        }
        else
        {
          N_warn++; warning<<" Trying to specify a recdev out of allowable range of years "<<y<<endl;
        }
      }
    }
    echoinput<< " rec_devs read from ctl ";
    if(do_recdev==1) echoinput<<recdev1<<endl;
    if(do_recdev==2) echoinput<<recdev2<<endl;

// **************************************************
    for (i=1;i<=Q_Npar2;i++)
    {Q_parm(i) = Q_parm_RD(i);}    //  set vector of initial index Q parms
    if(Q_Npar>0) echoinput<< " Q_parms read from ctl "<<Q_parm<<endl;

    for (i=1;i<=N_init_F;i++)
    init_F(i) = init_F_RD(i);    //  set vector of initial parms
    echoinput<< " initF_parms read from ctl "<<init_F<<endl;

    if(F_Method==2)
    {
      if(readparfile==0)
      {
      for (g=1;g<=N_Fparm;g++)
      {
          F_rate(g)=F_setup(1);
          f=Fparm_loc(g,1);
          t=Fparm_loc(g,2);
          Hrate(f,t)=F_setup(1);
      }
      if(F_detail>0)
      {
        for (k=1;k<=F_detail;k++)
        {
          f=F_setup2(k,1); y=F_setup2(k,2); s=F_setup2(k,3);
          t=styr+(y-styr)*nseas+s-1;
          g=do_Fparm(f,t);
          if(F_setup2(k,4)!=-999)
            {F_rate(g)=F_setup2(k,4); Hrate(f,t)=F_setup2(k,4);}
        }
      }
       echoinput<< " Fmort_parms have been reset "<<endl;
      }
      else
      {
      echoinput<< " Fmort_parms obtained from ss.par "<<endl;
      }
    }

    for (i=1;i<=N_selparm2;i++)
    selparm(i) = selparm_RD(i);    //  set vector of initial selex parms
    echoinput<< " selex_parms read from ctl "<<selparm<<endl;

    if(Do_TG>0)
    {
      k=Do_TG*(3*N_TG+2*Nfleet);
      for (i=1;i<=k;i++)
      {
        TG_parm(i)=TG_parm2(i,3);
      }
          echoinput<< " Tag_parms read from ctl "<<TG_parm<<endl;
    }
  }

//  SS_Label_Info_6.5 #Check parameter bounds and do jitter
    echoinput<<endl<<" now check bounds and do jitter if requested "<<endl;
    for (i=1;i<=N_MGparm2;i++)
    if(MGparm_PH(i)>0)
    {MGparm(i)=Check_Parm(MGparm_LO(i),MGparm_HI(i), jitter, MGparm(i));}
    echoinput<< " MG_parms after check "<<MGparm<<endl;

    for (i=1;i<=N_SRparm2;i++)
    if(SRvec_PH(i)>0)
    {SR_parm(i) = Check_Parm(SRvec_LO(i),SRvec_HI(i), jitter, SR_parm(i));}
    echoinput<< " SRR_parms after check "<<SR_parm<<endl;

    if(recdev_do_early>0 && recdev_early_PH>0)
    {
    for (y=recdev_early_start;y<=recdev_early_end;y++)
      {recdev_early(y) = Check_Parm(recdev_LO, recdev_HI, jitter, recdev_early(y));}
//      recdev_early -=sum(recdev_early)/(recdev_early_end-recdev_early_start+1);
    }

    if(recdev_PH>0 && do_recdev>0)
    {
      if(do_recdev==1)
      {
        for (i=recdev_start;i<=recdev_end;i++)
        {recdev1(i) = Check_Parm(recdev_LO, recdev_HI, jitter, recdev1(i));}
        recdev1 -=sum(recdev1)/(recdev_end-recdev_start+1);
      }
      else
      {
        for (i=recdev_start;i<=recdev_end;i++)
        {recdev2(i) = Check_Parm(recdev_LO, recdev_HI, jitter, recdev2(i));}
//        recdev2 -=sum(recdev2)/(recdev_end-recdev_start+1);
      }
    }
    echoinput<< " rec_devs after check ";
    if(do_recdev==1) echoinput<<recdev1<<endl;
    if(do_recdev==2) echoinput<<recdev2<<endl;

    if(Q_Npar2>0)
    {
      for (i=1;i<=Q_Npar2;i++)
      if(Q_parm_PH(i)>0)
      {Q_parm(i) = Check_Parm(Q_parm_LO(i),Q_parm_HI(i), jitter, Q_parm(i));}
      echoinput<< " Q_parms after check "<<Q_parm<<endl;
    }

    for (i=1;i<=N_init_F;i++)
      {
      if(init_F_PH(i)>0)
        {init_F(i) = Check_Parm(init_F_LO(i),init_F_HI(i), jitter, init_F(i));}
        echoinput<< " initF_parms after check "<<init_F<<endl;
      }

    for (i=1;i<=N_selparm2;i++)
    if(selparm_PH(i)>0)
    {selparm(i)=Check_Parm(selparm_LO(i),selparm_HI(i), jitter, selparm(i));}
    echoinput<< " selex_parms after check  "<<selparm<<endl;
    if(Do_TG>0)
    {
      k=Do_TG*(3*N_TG+2*Nfleet);
      for (i=1;i<=k;i++)
      {
      if(TG_parm_PH(i)>0)
        {TG_parm(i)=Check_Parm(TG_parm_LO(i),TG_parm_HI(i), jitter, TG_parm(i));}
      }
      echoinput<< " Tag_parms after check  "<<TG_parm<<endl;
    }
//  end bound check and jitter

//  SS_Label_Info_6.6 #Copy the environmental data as read into the dmatrix environmental data array
//  this will allow dynamic derived quantities like biomass and recruitment to be mapped into this same dmatrix
    env_data.initialize();
    if(N_envvar>=1)
      {
      for (y=styr-1;y<=(YrMax);y++)
        for (j=1;j<=N_envvar;j++)
          {env_data(y,j)=env_data_RD(y,j);}
      }

//  SS_Label_Info_6.7 #Initialize several rebuilding items
    if(Rebuild_Ydecl==-1) Rebuild_Ydecl=1999;
    if(Rebuild_Yinit==-1) Rebuild_Yinit=endyr+1;

    if(Rebuild_Ydecl>YrMax) Rebuild_Ydecl=YrMax;
    if(Rebuild_Yinit>YrMax) Rebuild_Yinit=YrMax;

    migrrate.initialize();
    depletion.initialize();
    natage.initialize();
    sel_l.initialize(); sel_a.initialize(); retain.initialize();  discmort.initialize(); discmort2.initialize();

    for (f=1;f<=Nfleet;f++)
    for (y=styr;y<=endyr+1;y++)
    for (gg=1;gg<=gender;gg++)
    {
      discmort2(y,f,gg)=1.0;
      if(y<=endyr+1)
      {
        discmort(y,f)=1.0;
        retain(y,f)=1.0;
      }
    }
    Richards=1.0;

//  SS_Label_Info_6.8 #Go thru biological calculations once, with do_once flag=1 to produce extra output to echoinput.sso
    echoinput<< " ready to evaluate once "<<endl;
    ALK_subseas_update=1;  //  vector to indicate if ALK needs recalculating
    do_once=1;
    niter=0;
    y=styr;
    yz=styr;
    t_base=styr+(y-styr)*nseas-1;

    make_timevaryparm();

//  SS_Label_Info_6.8.1 #Call fxn get_MGsetup() to copy MGparms to working array and applies time-varying factors
    get_MGsetup();
    echoinput<<" did MG setup"<<endl;

//  SS_Label_Info_6.8.2 #Call fxn get_growth1() to calculate quantities that are not time-varying
    get_growth1();
    echoinput<<" did growth1"<<endl;
    VBK_seas=value(VBK_seas);
    wtlen_seas=value(wtlen_seas);
    CVLmin=value(CVLmin);
    CVLmax=value(CVLmax);

//  SS_Label_Info_6.8.3 #Call fxn get_growth2() to calculate size-at-age
    if(Grow_type!=2)
    {get_growth2();} //   in preliminary calcs
    else
    {get_growth2_Richards();} //   in preliminary calcs
    echoinput<<" did growth2 in prelim calcs"<<endl<<Ave_Size(styr,1,1)<<endl;
    if(minL>10.0) {N_warn++; warning<<" Minimum size bin is:_"<<minL<<"; which is >10cm, which is large for use as size-at-age 0.0 recruitment"<<endl;}
    temp=Ave_Size(styr,1,1,nages);
    if(temp>0.95*len_bins(nlength)) {N_warn++; warning<<" Maximum size at age: "<<temp
    <<"; is within 5% of the largest size bin: "<<len_bins(nlength)<<"; Add more bins"<<endl;}

//  SS_Label_Info_6.8.4 #Call fxn get_natmort()
    echoinput<<"ready to do natmort "<<endl;
    get_natmort();
    natM = value(natM);
    surv1 = value(surv1);
    surv2 = value(surv2);
    echoinput<<" did natmort "<<endl;

//  SS_Label_Info_6.8.5 #Call fxn get_wtlen()  calculate weight-at-length and maturity vectors
    get_wtlen();
    wt_len=value(wt_len);
    wt_len2=value(wt_len2);
    wt_len_fd=value(wt_len_fd);
    mat_len=value(mat_len);
    mat_fec_len=value(mat_fec_len);
    mat_age=value(mat_age);

    for (s=1;s<=nseas;s++)
    {
    	echoinput<<" prelim:  growth3 for seas: "<<s<<endl;
      t = styr+s-1;
      for(subseas=1;subseas<=N_subseas;subseas++)
      {
        ALK_idx=(s-1)*N_subseas+subseas;
        get_growth3(s, subseas);  //  this will calculate the cv of growth for all subseasons of first year
        Make_AgeLength_Key(s,subseas);   //  ALK_idx calculated within Make_AgeLength_Key
        ALK(ALK_idx) = value(ALK(ALK_idx));
        echoinput<<" ok  subseas "<<subseas<<endl;
      }
//  SPAWN-RECR:   calc fecundity in preliminary_calcs
      if(s==spawn_seas)
      {
      	echoinput<<" spawn "<<endl;
        subseas=spawn_subseas;
        ALK_idx=(s-1)*N_subseas+subseas;
        // get_growth3 already done for all subseasons
        Make_Fecundity();
        echoinput<<" fecundity ok "<<endl;
      }
    }

//  SS_Label_Info_6.8.6 #Call fxn get_recr_distribution() for distribution of recruitment among areas and seasons, which can be time-varying
      echoinput<<"do recrdist: "<<endl;
    get_recr_distribution();
    recr_dist = value(recr_dist);    //  so the just calculated constant values will be used unless its parms are active

//  SS_Label_Info_6.8.7 #Call fxn get_migration()
    if(do_migration>0)   // set up migration rates
    {
      get_migration();
      migrrate=value(migrrate);
    }

//  SS_Label_Info_6.8.8 #Call fxn get_age_age()  transition matrix from real age to observed age'
    if(N_ageerr>0)
    {
      AgeKey_StartAge=0;
      AgeKey_Linear1=1;
      AgeKey_Linear2=1;
      for (j=1;j<=N_ageerr;j++)
      {
        if(j!=Use_AgeKeyZero)
        {
          age_err(j)=age_err_rd(j);  //  this is an age err definition that has been read
        }
        else
        {
          AgeKey_StartAge=int(value(mgp_adj(AgeKeyParm)));
          if(mgp_adj(AgeKeyParm+3)==0.0000) {AgeKey_Linear1=1;} else {AgeKey_Linear1=0;}
          if(mgp_adj(AgeKeyParm+6)==0.0000) {AgeKey_Linear2=1;} else {AgeKey_Linear2=0;}
        }
        get_age_age(j,AgeKey_StartAge,AgeKey_Linear1,AgeKey_Linear2);  //  call function to get the age_age key
      }
      age_age=value(age_age);  //   because these are not based on parameters
    }
    echoinput<<" made the age_age' key "<<endl;

    if (catch_mult_pointer>0)
    {
      get_catch_mult(y, catch_mult_pointer);
      for(j=styr;j<=YrMax;j++)  //  so get this value for all years, but can be overwritten by time-varying
      {
        catch_mult(j)=catch_mult(y);
      }
    }

//  SS_Label_Info_6.8.9 #Calculated values have been set equal to value() to remove derivative info and save space if their parameters are held constant

//  SS_Label_Info_6.9 #Set up headers for ParmTrace
    if(Do_ParmTrace>0) ParmTrace<<"Phase Iter ObjFun Change SPB_start SPB_end BiasAdj_st BiasAdj_max BiasAdj_end ";
    if(Do_ParmTrace==1 || Do_ParmTrace==4)
    {
      for (i=1;i<=active_count;i++) {ParmTrace<<" "<<ParmLabel(active_parm(i));}
    }
    else if(Do_ParmTrace>=2)
    {
      for (i=1;i<=ParCount;i++) {ParmTrace<<" "<<ParmLabel(i);}
    }
    ParmTrace<<endl;

//  SS_Label_Info_6.10 #Preliminary calcs done; Ready for estimation
    if(Turn_off_phase<0)
      {
        cout<<" Requested exit after read when turn_off_phase < 0 "<<endl;
        write_nudata();
        cout<<" finished nudata report "<<endl;
        write_nucontrol();
        cout<<" finished nucontrol report "<<endl;
        exit(1);
      }
    cout<<endl<<endl<<"Estimating...please wait..."<<endl;
    last_objfun=1.0e30;
  }  // end PRELIMINARY_CALCS_SECTION

