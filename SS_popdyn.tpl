// SS_Label_file  #12. **SS_popdyn.tpl**
// SS_Label_file  #* <u>setup_recdevs()</u>
// SS_Label_file  #* <u>get_initial_conditions()</u> // does virgin and initial year by calling <u>Do_Equil_Calc()</u> with F=0, then F=init_F
// SS_Label_file  #* <u>get_time_series()</u>  //  loops the years, calling biology, selectivity and spawn-recr functions as needed
// SS_Label_file  #* <u>Do_Equil_Calc()</u>  // does per-recruit calculations and returns SSB/R and Y/R

FUNCTION void setup_recdevs()
  {
  //  SS_Label_Info_7.1 #Set up recruitment bias_adjustment vector
    sigmaR=SR_parm(N_SRparm(SR_fxn)+1);
    two_sigmaRsq=2.0*sigmaR*sigmaR;
    half_sigmaRsq=0.5*sigmaR*sigmaR;

    biasadj.initialize();

    if(SR_fxn==4 || do_recdev==0)
    {
      // keep all at 0.0 if not using SR fxn
    }
//    else if (mceval_phase() || initial_params::mc_phase==1 || recdev_adj(5)<0.0)
    else if (mceval_phase() || initial_params::mc_phase==1)
    {
//      biasadj=1.0;
      biasadj=recdev_doit;  //  sets to 1.0 for the years or initial ages with estimated recruitments
    }
    else
    {
      if(recdev_do_early>0 && recdev_options(2)>=0 )    //  do logic on basis of recdev_options(2), which is read, not recdev_PH which can be reset to a neg. value
      {
        for (i=recdev_early_start;i<=recdev_early_end;i++)
        {if(i>=styr-nages) biasadj(i)=biasadj_full(i);}
      }
      if(do_recdev>0 && recdev_PH_rd>=0 )
      {
        for (i=recdev_start;i<=recdev_end;i++)
        {if(i>=styr-nages) biasadj(i)=biasadj_full(i);}
      }
      if(Do_Forecast>0 && recdev_options(3)>=0 )
      {
        for (i=recdev_end+1;i<=YrMax;i++)
        {biasadj(i)=biasadj_full(i);}
      }
      if(recdev_read>0)
      {
        for (j=1;j<=recdev_read;j++)
        {
          y=recdev_input(j,1);
          if(y>=recdev_first && y<=YrMax) biasadj(y)=biasadj_full(y);
        }
      }
    }
    sd_offset_rec=sum(biasadj)*sd_offset;
  //  SS_Label_Info_7.2 #Copy recdev parm vectors into full time series vector
    if(recdev_do_early>0) {recdev(recdev_early_start,recdev_early_end)=recdev_early(recdev_early_start,recdev_early_end);}
    if(do_recdev==1)
      {recdev(recdev_start,recdev_end)=recdev1(recdev_start,recdev_end);}
    else if(do_recdev>=2)
      {recdev(recdev_start,recdev_end)=recdev2(recdev_start,recdev_end);}
    if(Do_Forecast>0 && do_recdev>0) recdev(recdev_end+1,YrMax)=Fcast_recruitments(recdev_end+1,YrMax);  // only needed here for reporting
//      if(mcmc_counter>0)  warning<<N_warn<<" "<<mcmc_counter<<" MGparm "<<MGparm<<" SRparm "<<SR_parm<<" recdev "<<recdev2<<" fore_rec "<<Fcast_recruitments<<" selparm "<<selparm<<" q: "<<Q_parm<<endl;
  }  //  end setup for recdevs

FUNCTION void get_initial_conditions()
  {
  //*********************************************************************
  /*  SS_Label_Function_23 #get_initial_conditions */
  natage.initialize();
  catch_fleet.initialize();
  annual_catch.initialize();
  annual_F.initialize();
  Recr.initialize();

  if(SzFreq_Nmeth>0) SzFreq_exp.initialize();

  //  SS_Label_Info_23.1 #call biology and selectivity functions for the initial year
  //  SS_Label_Info_23.1.1 #These rate are calculated once in PRELIMINARY_CALCS_SECTION, so only recalculate if active according to MG_active
  y=styr;
  yz=styr;
  t_base=styr-1;
  recr_dist_unf.initialize();
  natM_unf.initialize();
  surv1_unf.initialize();
  surv2_unf.initialize();

//  Create time varying parameters
//  following call is to routine that does this for all timevary parameters
//  that are then copied over to replace the base parameter for MG, SRR, Q, Selex, or Tag as needed
  make_timevaryparm();  //  this fills array parm_timevary for all years;   densitydependence must be done year-by-year later
  if(MG_active(0)>0 || save_for_report>0)
    {
      get_MGsetup(y);
    }
 #ifdef DO_ONCE
  if(do_once==1) cout<<" MG setup OK "<<endl;
 #endif
  if(MG_active(2)>0) get_growth1();   // seasonal effects and CV
 #ifdef DO_ONCE
  if(do_once==1) cout<<" growth1 OK"<<endl;
 #endif
  if(MG_active(2)>0 || do_once==1)
  {
    ALK_subseas_update=1;  //  to indicate that all ALKs need calculation
    get_growth2(y);
    t=styr-1;
    for (s=1;s<=nseas;s++)
    {
      t++;
      for(subseas=1;subseas<=N_subseas;subseas++)  //  do all subseasons in first year
      {
        get_growth3(y,t,s, subseas);  //  in case needed for Lorenzen M
        Make_AgeLength_Key(s, subseas);
      }
    }

//  SS_Label_Info_16.2.4.3  #propagate Ave_Size from early years forward until first year that has time-vary growth
      k=styr+1;
      do {
        for (s=1;s<=nseas;s++)
        {
          t=styr+(k-styr)*nseas+s-1;
          Ave_Size(t,1)=Ave_Size(t-nseas,1);
        }  // end season loop
        k++;
      } while(timevary_MG(k,2)==0 && k<=YrMax);
      if(k<=YrMax)
      {
        t=styr+(k-styr)*nseas;
        Ave_Size(t,1)=Ave_Size(t-nseas,1);  // prep for time-vary next yr
      }
  }
  if(MG_active(3)>0) get_wtlen();  // stores values for all seasons
  get_mat_fec();  //  does just spawn season and subseason using ALK calculated just above
  if(Hermaphro_Option!=0) get_Hermaphro();

  if(MG_active(1)>0) get_natmort();
 #ifdef DO_ONCE
  if(do_once==1) cout<<" natmort OK"<<endl;
 #endif
  if(y>=Bmark_Yr(1)&&y<=Bmark_Yr(2))
  {
    for (s=1;s<=nseas;s++)
    for (gp=1;gp<=N_GP*gender*N_settle_timings;gp++)
    {
      natM_unf(s,gp)+=natM(s,gp);   //  need nseas to capture differences due to settlement
      surv1_unf(s,gp)+=surv1(s,gp);   //  need nseas to capture differences due to settlement
      surv2_unf(s,gp)+=surv2(s,gp);   //  need nseas to capture differences due to settlement
    }
  }

  if(MG_active(4)>0) get_recr_distribution();
  if(y>=Bmark_Yr(7)&&y<=Bmark_Yr(8))
  {
    for (gp=1;gp<=N_GP;gp++)
    for (p=1;p<=pop;p++)
    for (settle=1;settle<=N_settle_timings;settle++)
    if(recr_dist_pattern(gp,settle,p)>0)
    {
      recr_dist_unf(gp,settle,p)+=recr_dist(y,gp,settle,p);
      if(gender==2) recr_dist_unf(gp+N_GP,settle,p)+=recr_dist(y,gp+N_GP,settle,p);
    }
  }

  if(MG_active(5)>0) get_migration();
 #ifdef DO_ONCE
  if(do_once==1) cout<<" migr OK"<<endl;
 #endif
  if(MG_active(7)>0)
  {
    get_catch_mult(y, catch_mult_pointer);
    for(j=styr+1;j<=YrMax;j++)
    {
      catch_mult(j)=catch_mult(y);
    }
  }

  if(Use_AgeKeyZero>0)
  {
    if(MG_active(6)>0) get_age_age(Use_AgeKeyZero,AgeKey_StartAge,AgeKey_Linear1,AgeKey_Linear2); //  call function to get the age_age key
    if(save_for_report==1 && store_agekey_add>0)
      {
        save_agekey_count=N_ageerr+1;  //  first blank key after the used keys
        age_age(save_agekey_count)=age_age(Use_AgeKeyZero);
        age_err(save_agekey_count)=age_err(Use_AgeKeyZero);
      }
 #ifdef DO_ONCE
    if(do_once==1)
      {
        cout<<" ageerr_key OK"<<endl;
        echoinput<<" ageerr_key recalc in "<<y<<endl;
      }
 #endif
  }

  if(save_for_report>0)
    {get_saveGparm();}

  //  SS_Label_Info_23.2 #Calculate selectivity in the initial year
  get_selectivity();
 #ifdef DO_ONCE
  if(do_once==1) cout<<" selex OK, ready to call ALK and fishselex "<<endl;
 #endif

  //  SS_Label_Info_23.3 #Loop seasons and subseasons
  t=styr-1;
  for (s=1;s<=nseas;s++)
  {
    t++;

    if(WTage_rd>0)
    {
      for (g=1;g<=gmorph;g++)
      if(use_morph(g)>0)
      {
        Wt_Age_beg(s,g)=WTage_emp(t,GP3(g),0);
        Wt_Age_mid(s,g)=WTage_emp(t,GP3(g),-1);
        if(s==spawn_seas) fec(g)=WTage_emp(t,GP3(g),-2);
      }
    }
      else if(MG_active(2)>0 || MG_active(3)>0 || save_for_report>0 || do_once==1)
    {
//       Make_Fecundity();
       if(s==spawn_seas && spawn_seas==1) get_mat_fec();
//       if(do_once==1) echoinput<<"Save_fec in initial year: "<<t<<" %% "<<save_sel_fec(t,1,0)<<endl;
       for (g=1;g<=gmorph;g++)
       if(use_morph(g)>0)
       {
         subseas=1;
         ALK_idx=(s-1)*N_subseas+subseas;
         Wt_Age_beg(s,g)=(ALK(ALK_idx,g)*wt_len(s,GP(g)));  // wt-at-age at beginning of period
         subseas=mid_subseas;
         ALK_idx=(s-1)*N_subseas+subseas;
         Wt_Age_mid(s,g)=ALK(ALK_idx,g)*wt_len(s,GP(g));  // use for fisheries with no size selectivity
      }
    }

    Save_Wt_Age(t)=Wt_Age_beg(s);

    for (g=1;g<=gmorph;g++)
    if(use_morph(g)>0)
    {
  //  SS_Label_Info_23.3.3 #for each platoon, combine size_at_age distribution with length selectivity and weight-at-length to get combined selectivity vectors
      Make_FishSelex();
    }
  }

 #ifdef DO_ONCE
  if(do_once==1) cout<<" ready for virgin age struc "<<endl;
 #endif
  //  SS_Label_Info_23.4 #calculate unfished (virgin) numbers-at-age
  eq_yr=styr-2;
  bio_yr=styr;
  Fishon=0;
  virg_fec = fec;
  Recr.initialize();  //  will store recruitment by area
  for(int i=1;i<=N_SRparm2;i++) {SR_parm_byyr(eq_yr,i)=SR_parm(i);  SR_parm_virg(i)=SR_parm(i);  SR_parm_work(i)=SR_parm(i);}

//  SPAWN-RECR:   get expected recruitment globally or by area
  if(recr_dist_area==1 || pop==1)  //  do global spawn_recruitment calculations
  {
    Recr_virgin=mfexp(SR_parm(1));
    equ_Recr=Recr_virgin;
    exp_rec(eq_yr,1)=Recr_virgin;  //  expected Recr from s-r parms
    exp_rec(eq_yr,2)=Recr_virgin;
    exp_rec(eq_yr,3)=Recr_virgin;
    exp_rec(eq_yr,4)=Recr_virgin;
    Do_Equil_Calc(equ_Recr);                      //  call function to do equilibrium calculation
    SSB_virgin=SSB_equil;
    SPR_virgin=SSB_equil/Recr_virgin;  //  spawners per recruit

//  unnecessary because these are now done in benchmark itself
//    if(Do_Benchmark==0)
//    {
//      Mgmt_quant(1)=SSB_virgin;
//      SSB_unf=SSB_virgin;
//      Recr_unf=Recr_virgin;
//      Mgmt_quant(2)=totbio;  //  from equil calcs
//      Mgmt_quant(3)=smrybio;  //  from equil calcs
//      Mgmt_quant(4)=Recr_virgin;
//    }

    Smry_Table(styr-2,1)=totbio;  //  from equil calcs
    Smry_Table(styr-2,2)=smrybio;  //  from equil calcs
    Smry_Table(styr-2,3)=smrynum;  //  from equil calcs
    SSB_pop_gp(eq_yr)=SSB_equil_pop_gp;   // dimensions of pop x N_GP
    if(Hermaphro_Option!=0) MaleSPB(eq_yr)=MaleSSB_equil_pop_gp;
    SSB_yr(eq_yr)=SSB_equil;
    SR_parm_byyr(eq_yr,N_SRparm2+1)=SSB_equil;
    SR_parm_virg(N_SRparm2+1)=SSB_equil;
    SR_parm_work(N_SRparm2+1)=SSB_equil;
    t=styr-2*nseas-1;
    for (s=1;s<=nseas;s++)
    for (p=1;p<=pop;p++)
    {
      for (g=1;g<=gmorph;g++)
      {
        if(use_morph(g)>0)
        {
        natage(t+s,p,g)(0,nages)=equ_numbers(s,p,g)(0,nages);
        Z_rate(t+s,p,g)(0,nages)=equ_Z(s,p,g)(0,nages);
        }
      }
    }
    if(save_for_report>0)
    {
      SSB_B_yr(eq_yr).initialize();
      SSB_N_yr(eq_yr).initialize();
      for (s=1;s<=nseas;s++)
      for (p=1;p<=pop;p++)
      for (g=1;g<=gmorph;g++)
      if(use_morph(g)>0)
      {
        if(s==spawn_seas && sx(g)==1)
        {
           SSB_B_yr(eq_yr) += make_mature_bio(GP4(g))*natage(t+s,p,g);
           SSB_N_yr(eq_yr) += make_mature_numbers(GP4(g))*natage(t+s,p,g);
        }
        Save_PopAge(t+s,p,g)=natage(t+s,p,g);
        Save_PopAge(t+s,p+pop,g)=elem_prod(natage(t+s,p,g),mfexp(-Z_rate(t+s,p,g)*0.5*seasdur(s)));
        Recr(p,t+1+Settle_seas_offset(settle_g(g)))+=equ_Recr*recr_dist(y,GP(g),settle_g(g),p)*platoon_distr(GP2(g));
        Save_PopBio(t+s,p,g)=elem_prod(natage(t+s,p,g),Wt_Age_beg(s,g));
        Save_PopBio(t+s,p+pop,g)=elem_prod(Save_PopAge(t+s,p+pop,g),Wt_Age_mid(s,g));
      }
    }
  }
  else  //  area-specific spawn-recruitment
  {

  }

  //  SS_Label_Info_23.5  #Calculate equilibrium using initial F
 #ifdef DO_ONCE
  if(do_once==1) cout<<" ready for initial age struc "<<endl;
 #endif
   eq_yr=styr-1;
   bio_yr=styr;
   if(fishery_on_off==1) {Fishon=1;} else {Fishon=0;}

   for(f=1;f<=N_SRparm2;f++)
   {
      if(SR_parm_timevary(f)==0)
      {
          //  no change to SR_parm_work
      }
      else
      {
        SR_parm_work(f)=parm_timevary(SR_parm_timevary(f),eq_yr);
      }
      SR_parm_byyr(eq_yr,f)=SR_parm_work(f);
   }

   for (s=1;s<=nseas;s++)
   {
     t=styr-nseas-1+s;
     for (f=1;f<=Nfleet;f++)
     {
       if(init_F_loc(s,f)>0) {Hrate(f,t) = init_F(init_F_loc(s,f));}
     }
   }

//  for the initial equilibrium, R0 and steepness will remain same as for virgin, but a regime shift is allowed
//  change with 3.30.12 to allow R0 to change according to a timevary effect
//  exp_rec(eq_yr,1)=Recr_virgin;
//  R1_exp=Recr_virgin;
    R1_exp=mfexp(SR_parm_work(1));
    exp_rec(eq_yr,1)=R1_exp;
//  SS_Label_Info_23.5.1  #Apply adjustments to the recruitment level
//  SPAWN-RECR:   adjust recruitment for the initial equilibrium
  regime_change=1.0;
  if(SR_parm_timevary(N_SRparm2-1)>0)  //  timevary regime exists
  {
    regime_change=mfexp(SR_parm_work(N_SRparm2-1));
  }

  if(init_equ_steepness==0) // Adjustments do not include spawner-recruitment steepness
  {
//   R1=Recr_virgin*regime_change;
   R1=R1_exp*regime_change;
   exp_rec(eq_yr,2)=R1;
   exp_rec(eq_yr,3)=R1;
   exp_rec(eq_yr,4)=R1;
   equ_Recr=R1;  //  equ_Recr is used inside of Do_Equil_Calc
   Do_Equil_Calc(equ_Recr);
   CrashPen += Equ_penalty;
  }
  else
  {
    //  SS_Label_Info_23.5.1.2  #Adjustments  include spawner-recruitment function
    //  do initial equilibrium with R1 based on offset from spawner-recruitment curve, using same approach as the benchmark calculations
    //  first get SPR for this init_F
//  SPAWN-RECR:   calc initial equilibrium pop, SPB, Recruitment
//    equ_Recr=Recr_virgin;
    equ_Recr=R1_exp*regime_change;

    Do_Equil_Calc(equ_Recr);
    CrashPen += Equ_penalty;
    SPR_temp=SSB_equil/equ_Recr;  //  spawners per recruit at initial F
  //  get equilibrium SSB and recruitment from SPR_temp, Recr_virgin and virgin steepness
    Equ_SpawnRecr_Result = Equil_Spawn_Recr_Fxn(SR_parm(2), SR_parm(3), SSB_virgin, Recr_virgin, SPR_temp);  //  returns 2 element vector containing equilibrium biomass and recruitment at this SPR

    R1_exp=Equ_SpawnRecr_Result(2);     //  set the expected recruitment equal to this equilibrium
    exp_rec(eq_yr,1)=R1_exp;

    equ_Recr=R1_exp*regime_change;
    exp_rec(eq_yr,2)=equ_Recr;
    exp_rec(eq_yr,3)=equ_Recr;
    exp_rec(eq_yr,4)=equ_Recr;
    R1=equ_Recr;

    Do_Equil_Calc(equ_Recr);  // calculated SSB_equil
    CrashPen += Equ_penalty;
  }
    Smry_Table(styr-1,1)=totbio;  //  from equil calcs
    Smry_Table(styr-1,2)=smrybio;  //  from equil calcs
    Smry_Table(styr-1,3)=smrynum;  //  from equil calcs

   SSB_pop_gp(eq_yr)=SSB_equil_pop_gp;   // dimensions of pop x N_GP
   if(Hermaphro_Option!=0) MaleSPB(eq_yr)=MaleSSB_equil_pop_gp;
   SSB_yr(eq_yr)=SSB_equil;
    SR_parm_byyr(eq_yr,N_SRparm2+1)=SSB_equil;
    SR_parm_work(N_SRparm2+1)=SSB_equil;
   SSB_yr(styr)=SSB_equil;
   env_data(styr-1,-1)=0.0;
   env_data(styr-1,-2)=0.0;
   env_data(styr-1,-3)=0.0;
   env_data(styr-1,-4)=0.0;

   for (s=1;s<=nseas;s++)
   for (f=1;f<=Nfleet;f++)
   {
     if(catchunits(f)==1)
     {
      est_equ_catch(s,f)=equ_catch_fleet(2,s,f);
    }
    else
     {
      est_equ_catch(s,f)=equ_catch_fleet(5,s,f);
     }
   }
   if(save_for_report>0)
   {
     for (s=1;s<=nseas;s++)
     {
       t=styr-nseas-1+s;
       for (f=1;f<=Nfleet;f++)
       {
         for (g=1;g<=6;g++)
         {catch_fleet(t,f,g)=equ_catch_fleet(g,s,f);
          annual_catch(styr-1,g)+=equ_catch_fleet(g,s,f);
         }
         for (g=1;g<=gmorph;g++)
         {catage(t,f,g)=equ_catage(s,f,g); }
       }
     }
     for(k=1;k<=3;k++) {Smry_Table(styr-1,k+3)=annual_catch(styr-1,k);}
   }


   for (s=1;s<=nseas;s++)
   {
     t=styr-nseas-1+s;
     a=styr-1+s;
     for (p=1;p<=pop;p++)
     for (g=1;g<=gmorph;g++)
     {
       natage(t,p,g)(0,nages)=equ_numbers(s,p,g)(0,nages);
       natage(a,p,g)(0,nages)=equ_numbers(s,p,g)(0,nages);
       Z_rate(t,p,g)=equ_Z(s,p,g);
     }
   }
    if(save_for_report>0)
    {
      t=styr-nseas-1;
      SSB_B_yr(eq_yr).initialize();
      SSB_N_yr(eq_yr).initialize();
      for (s=1;s<=nseas;s++)
      for (p=1;p<=pop;p++)
      for (g=1;g<=gmorph;g++)
      if(use_morph(g)>0)
      {
        if(s==spawn_seas && sx(g)==1)
        {
           SSB_B_yr(eq_yr) += make_mature_bio(GP4(g))*natage(t+s,p,g);
           SSB_N_yr(eq_yr) += make_mature_numbers(GP4(g))*natage(t+s,p,g);
        }
        Save_PopAge(t+s,p,g)=natage(t+s,p,g);
        Save_PopAge(t+s,p+pop,g)=elem_prod(natage(t+s,p,g),mfexp(-Z_rate(t+s,p,g)*0.5*seasdur(s)));
        Save_PopBio(t+s,p,g)=elem_prod(natage(t+s,p,g),Wt_Age_beg(s,g));
        Save_PopBio(t+s,p+pop,g)=elem_prod(Save_PopAge(t+s,p+pop,g),Wt_Age_mid(s,g));

//         warning<<N_warn<<" "<<s<<" init  "<<t+Settle_seas_offset(settle_g(g))<<endl;
        Recr(p,t+1+Settle_seas_offset(settle_g(g)))+=equ_Recr*recr_dist(y,GP(g),settle_g(g),p)*platoon_distr(GP2(g));
      }
    }


   if(docheckup==1) echoinput<<" init equil age comp for styr "<<styr<<endl<<natage(styr)<<endl<<endl;

   // if recrdevs start before styr, then use them to adjust the initial agecomp
   //  apply a fraction of the bias adjustment, so bias adjustment gets less linearly as proceed back in time
   if(recdev_first<styr)
   {
    if(do_recdev<=2 && SR_fxn!=4)
    {
     for (p=1;p<=pop;p++)
     for (g=1;g<=gmorph;g++)
     for (a=styr-recdev_first; a>=1; a--)
     {
       j=styr-a;
       natage(styr,p,g,a) *=mfexp(recdev(j)-biasadj(j)*half_sigmaRsq);
     }
    }
    else
    {
     for (p=1;p<=pop;p++)
     for (g=1;g<=gmorph;g++)
     for (a=styr-recdev_first; a>=1; a--)
     {
       j=styr-a;
       natage(styr,p,g,a) *=mfexp(recdev(j));
     }
    }

   }
   SSB_pop_gp(styr)=SSB_pop_gp(styr-1);  //  placeholder in case not calculated early in styr

   //  note:  the above keeps SSB_pop_gp(styr) = SSB_equil.  It does not adjust for initial agecomp, but probably should
  }  //  end initial_conditions

  //*********************************************************************
FUNCTION void get_time_series()
  {
  /*  SS_Label_Function_24 get_time_series */
  dvariable crashtemp; dvariable crashtemp1;
  dvariable interim_tot_catch;
  dvariable Z_adjuster;
  dvariable R0_use;
  dvariable SSB_use;
  if(Do_Morphcomp>0) Morphcomp_exp.initialize();

  //  SS_Label_Info_24.0 #Retrieve spawning biomass and recruitment from the initial equilibrium
//  SPAWN-RECR:   begin of time series, retrieve last spbio and recruitment
  SSB_current = SSB_yr(styr);  //  need these initial assignments in case recruitment distribution occurs before spawnbio&recruits
  if(recdev_doit(styr-1)>0)
  { Recruits = R1 * mfexp(recdev(styr-1)-biasadj(styr-1)*half_sigmaRsq); }
  else
  { Recruits = R1;}

  //  SS_Label_Info_24.1 #Loop the years
  for (y=styr;y<=endyr;y++)
  {
    yz=y;
    if(STD_Yr_Reverse_F(y)>0) F_std(STD_Yr_Reverse_F(y))=0.0;
    t_base=styr+(y-styr)*nseas-1;


   for(f=1;f<=N_SRparm2;f++)
   {
      if(SR_parm_timevary(f)==0)
      {
          //  no change to SR_parm_work
      }
      else
      {
        SR_parm_work(f)=parm_timevary(SR_parm_timevary(f),y);
      }
      SR_parm_byyr(y,f)=SR_parm_work(f);
   }

//  store most recent value for density-dependent effects, NOTE - off by a year if recalc'ed at beginning of season 1
      {
        env_data(y,-1)=log(SSB_current/SSB_yr(styr-1));
        if(recdev_doit(y)>0)
          {env_data(y,-2)=recdev(y);} //  store so can do density-dependence
          else
          {  //  should be 0.0
          }
//           warning<<N_warn<<" "<<y<<" "<<SSB_current<<" "<<SSB_yr(styr-1)<<" "<<recdev(y)<<" env: "<<env_data(y)<<endl;
        t=t_base+1;  // first season
        s=1;
      if(WTage_rd>0)
      {
        for (g=1;g<=gmorph;g++)
        if(use_morph(g)>0)
        {
          Wt_Age_beg(s,g)=WTage_emp(t,GP3(g),0);
          Wt_Age_mid(s,g)=WTage_emp(t,GP3(g),-1);
        }
      }
      else if(timevary_MG(y,2)>0 || timevary_MG(y,3)>0 || save_for_report==1)
        {
          get_growth3(y,t,1,1);  //  before season loop, used for summary biomass
          ALK_subseas_update(1)=1;  // do 1st subseas of 1st season;  ADD THIS LINE for 3.30.17
          Make_AgeLength_Key(s, 1);  //  this will give wt_age_beg before any time-varying parameter changes for this year
          ALK_idx=(s-1)*N_subseas+1;
          for (g=1;g<=gmorph;g++)
          if(use_morph(g)>0) {
          Wt_Age_beg(s,g)=(ALK(ALK_idx,g)*wt_len(s,GP(g)));  // wt-at-age at beginning of period
         }
        }
        smrybio=0.0;
        smrynum=0.0;
//  do not do totbio here because new recruits have not yet occurred
        for (g=1;g<=gmorph;g++)
        if(use_morph(g)>0)
        {
          for (p=1;p<=pop;p++)
          {
            smrybio+=natage(t,p,g)(Smry_Age,nages)*Wt_Age_beg(1,g)(Smry_Age,nages);  // calc before recruitment and time-vary biology applied
            smrynum+=sum(natage(t,p,g)(Smry_Age,nages));   //sums to accumulate across platoons and settlements
          }
        }
        env_data(y,-3)=log(smrybio/Smry_Table(styr-1,2));
        env_data(y,-4)=log(smrynum/Smry_Table(styr-1,3));

        Smry_Table(y,2)=smrybio;  //  gets used as demoninator for some F_std options
        Smry_Table(y,3)=smrynum;
      }
    if(y>styr)
    {

    if(do_densitydependent==1)  make_densitydependent_parm(y);  //  call to adjust for density dependence

  //  SS_Label_Info_24.1.1 #Update the time varying biology factors if necessary
      if(timevary_MG(y,0)>0 || save_for_report>0) get_MGsetup(y);
      if(timevary_MG(y,2)>0)
        {
          ALK_subseas_update=1;  // indicate that all ALKs will need re-estimation
          get_growth2(y);  //  propagates growth to each season this year and to begin next year
          get_growth3(y,t,1,1);  //  cleans up the linear growth range for begin of this year
        }
      if(timevary_MG(y,3)>0){
        get_wtlen();  //  stores values for all seasons
        //  note that get_mat_fec() will get called in the season loop because it may need the ALK for a later season
        // but Maunder's M in get_natmort() may use the fecundity vector, so would be using the most recently calculated  Problem??
        if(Hermaphro_Option!=0) get_Hermaphro();
      }
      if(timevary_MG(y,1)>0) get_natmort();
      if(y>=Bmark_Yr(1)&&y<=Bmark_Yr(2))
      {
        for (s=1;s<=nseas;s++)
        for (gp=1;gp<=N_GP*gender*N_settle_timings;gp++)
        {
          natM_unf(s,gp)+=natM(s,gp);
          surv1_unf(s,gp)+=surv1(s,gp);
          surv2_unf(s,gp)+=surv2(s,gp);
        }
      }
      if(timevary_MG(y,4)>0) get_recr_distribution();
      if(y>=Bmark_Yr(7)&&y<=Bmark_Yr(8))
      {
        for (gp=1;gp<=N_GP;gp++)
        for (p=1;p<=pop;p++)
        for (settle=1;settle<=N_settle_timings;settle++)
        if(recr_dist_pattern(gp,settle,p)>0)
        {
          recr_dist_unf(gp,settle,p)+=recr_dist(y,gp,settle,p);
          if(gender==2) recr_dist_unf(gp+N_GP,settle,p)+=recr_dist(y,gp+N_GP,settle,p);
        }
      }
      if(timevary_MG(y,5)>0) get_migration();
      if(timevary_MG(y,7)>0)
      {
        get_catch_mult(y, catch_mult_pointer);
      }

      if(Use_AgeKeyZero>0)
      {
        if(timevary_MG(y,6)>0)
        {
          get_age_age(Use_AgeKeyZero,AgeKey_StartAge,AgeKey_Linear1,AgeKey_Linear2); //  call function to get the age_age key
          if(save_for_report==1 && store_agekey_add>0)
          {
            save_agekey_count++;  //  next blank key after the used keys
            age_age(save_agekey_count)=age_age(Use_AgeKeyZero);
            age_err(save_agekey_count)=age_err(Use_AgeKeyZero);
          }

 #ifdef DO_ONCE
          if(do_once==1) echoinput<<" ageerr_key recalc in "<<y<<endl;
 #endif
        }
      }

      if(save_for_report>0)
      {
        if(timevary_MG(y,1)>0 || timevary_MG(y,2)>0 || timevary_MG(y,3)>0)
        {
          get_saveGparm();
        }
      }
    }

  //  SS_Label_Info_24.2  #Loop the seasons
    for (s=1;s<=nseas;s++)
    {
      if (docheckup==1) echoinput<<endl<<"************************************"<<endl<<" year, seas "<<y<<" "<<s<<endl;
  //  SS_Label_Info_24.1.2  #Call selectivity, which does its own internal check for time-varying changes
  //  note that Make_Fish_selex is called later after the ALK's have been updated
      if(s==1 && y>styr) get_selectivity();
      t = t_base+s;

  //  SS_Label_Info_24.2.1 #Update the age-length key and the fishery selectivity for this season

//      if(timevary_MG(y,2)>0 || timevary_MG(y,3)>0 || save_for_report==1 || WTage_rd>0)
      if(timevary_MG(y,2)>0 || save_for_report==1)
      {
        get_growth3(y,t,s, 1);  // first subseas of season=s
        Make_AgeLength_Key(s, 1);

        get_growth3(y,t,s, mid_subseas); //  for midseason
        Make_AgeLength_Key(s, mid_subseas);
//  SPAWN-RECR:   call Make_Fecundity in time series
        if(s==spawn_seas)
        {
          if(spawn_subseas!=1 && spawn_subseas!=mid_subseas)
          {
            subseas=spawn_subseas;
            get_growth3(y,t,s, subseas);
            Make_AgeLength_Key(s, subseas);  //  spawn subseas
          }
        }
      }
      if(WTage_rd>0)
      {
        for (g=1;g<=gmorph;g++)
        if(use_morph(g)>0)
        {
          Wt_Age_beg(s,g)=WTage_emp(t,GP3(g),0);
          Wt_Age_mid(s,g)=WTage_emp(t,GP3(g),-1);
          if(s==spawn_seas)
            {
              fec(g)=WTage_emp(t,GP3(g),-2);
              save_sel_fec(t,g,0)= fec(g);
//              if(y==endyr) save_sel_fec(t+nseas,g,0)=fec(g);
              }
        }
      }
      else if(timevary_MG(y,2)>0 || timevary_MG(y,3)>0 || save_for_report>0 || do_once==1)
      {
         if(s==spawn_seas) get_mat_fec();
//         Make_Fecundity();
         ALK_idx=(s-1)*N_subseas+1;  //  subseas=1
         int ALK_idx2=(s-1)*N_subseas+mid_subseas;
         for (g=1;g<=gmorph;g++)
         if(use_morph(g)>0)
         {
           Wt_Age_beg(s,g)=(ALK(ALK_idx,g)*wt_len(s,GP(g)));  // wt-at-age at beginning of period
           Wt_Age_mid(s,g)=ALK(ALK_idx2,g)*wt_len(s,GP(g));  // use for fisheries with no size selectivity
        }
      }

      Save_Wt_Age(t)=Wt_Age_beg(s);

      if(y>styr)    // because styr is done as part of initial conditions
      {
        for (g=1;g<=gmorph;g++)
        if(use_morph(g)>0)
        {Make_FishSelex();}
      }

//  SS_Label_Info_24.2.2 #Compute spawning biomass if this is spawning season so recruits could occur later this season
//  SPAWN-RECR:   calc SPB in time series if spawning is at beginning of the season
      if(s==spawn_seas && spawn_time_seas<0.0001)    //  compute spawning biomass if spawning at beginning of season so recruits could occur later this season
      {
        SSB_pop_gp(y).initialize();
        SSB_B_yr(y).initialize();
        SSB_N_yr(y).initialize();
        for (p=1;p<=pop;p++)
        {
          for (g=1;g<=gmorph;g++)
          if(sx(g)==1 && use_morph(g)>0)     //  female
          {
            SSB_pop_gp(y,p,GP4(g)) += fracfemale_mult*fec(g)*natage(t,p,g);   // accumulates SSB by area and by growthpattern
            SSB_B_yr(y) += fracfemale_mult*make_mature_bio(GP4(g))*natage(t,p,g);
            SSB_N_yr(y) += fracfemale_mult*make_mature_numbers(GP4(g))*natage(t,p,g);
//            SSB_pop_gp(y,p,GP4(g)) += fec(g)*natage(t,p,g);   // accumulates SSB by area and by growthpattern
//            SSB_B_yr(y) += make_mature_bio(GP4(g))*natage(t,p,g);
//            SSB_N_yr(y) += make_mature_numbers(GP4(g))*natage(t,p,g);
          }
        }
        SSB_current=sum(SSB_pop_gp(y));
        SSB_yr(y)=SSB_current;

        if(Hermaphro_Option!=0)  // get male biomass
        {
          MaleSPB(y).initialize();
          for (p=1;p<=pop;p++)
          {
            for (g=1;g<=gmorph;g++)
            if(sx(g)==2 && use_morph(g)>0)     //  male; all assumed to be mature
            {
              MaleSPB(y,p,GP4(g)) += Save_Wt_Age(t,g)*natage(t,p,g);   // accumulates SSB by area and by growthpattern
            }
          }
          if(Hermaphro_maleSPB>0.0)  // add MaleSPB to female SSB
          {
            SSB_current+=Hermaphro_maleSPB*sum(MaleSPB(y));
            SSB_yr(y)=SSB_current;
          }
        }

  //  SS_Label_Info_24.2.3 #Get the total recruitment produced by this spawning biomass
//  SPAWN-RECR:   calc recruitment in time series; need to make this area-specific
      if(SR_parm_timevary(1)==0)  //  R0 is not time-varying
      {R0_use=Recr_virgin; SSB_use=SSB_virgin;}
      else
      {
        R0_use=mfexp(SR_parm_work(1));
        equ_Recr=R0_use;
        Fishon=0;
        eq_yr=y;
        bio_yr=y;
        Do_Equil_Calc(R0_use);                      //  call function to do equilibrium calculation
        if(fishery_on_off==1) {Fishon=1;} else {Fishon=0;}
        SSB_use=SSB_equil;
      }

        Recruits=Spawn_Recr(SSB_use,R0_use,SSB_current);  // calls to function Spawn_Recr
        apply_recdev(Recruits, R0_use);  //  apply recruitment deviation
// distribute Recruitment of age 0 fish among the current and future settlements; and among areas and morphs
            //  use t offset for each birth event:  Settlement_offset(settle)
            //  so the total number of Recruits will be relative to their numbers at the time of the set of settlement_events.
            //  so need the integer elapsed time (in season count) stored in Birth_offset()
            //  and need the real elapsed time (in fraction of a year) from the beginning of the season to settlement
            //  use NatM to calculate the virtual numbers that would have existed at the beginning of the season of the settlement
            //  need to use natM(t) because natM(t+offset) is not yet known
            //  also need to store the integer age at settlement
            //  NOTE: the settlement is added to natage at the beginning of the season in which the settlement occurs,
            //  so it will be fished and sampled even before its settlement time
            //  this is a shortcoming that might be dealt with in future.
            //   For now, users will need to create finer season structure
            //  NOTE:  the distributed recruits are added into natage because more than one settlement can occur in same season
            //  but each settlement has a unique "g", so maybe additive is not necessary
          for (g=1;g<=gmorph;g++)
          if(use_morph(g)>0)
          {
            settle=settle_g(g);
            for (p=1;p<=pop;p++)
            {
              if(y==styr) natage(t+Settle_seas_offset(settle),p,g,Settle_age(settle))=0.0;  //  to negate the additive code
              natage(t+Settle_seas_offset(settle),p,g,Settle_age(settle)) +=
               Recruits*recr_dist(y,GP(g),settle,p)*platoon_distr(GP2(g))*
               mfexp(natM(s,GP3(g),Settle_age(settle))*Settle_timing_seas(settle));
               Recr(p,t+Settle_seas_offset(settle))+=Recruits*recr_dist(y,GP(g),settle,p)*platoon_distr(GP2(g));
               //  the adjustment for mortality increases recruit value for elapsed time since begin of season because M will then be applied from beginning of season
               if(docheckup==1) echoinput<<y<<" Recruits, dist, surv, result"<<Recruits<<" "<<recr_dist(y,GP(g),settle,p)<<" "<<mfexp(natM(s,GP3(g),Settle_age(settle))*Settle_timing_seas(settle))<<" "<<natage(t+Settle_seas_offset(settle),p,g,Settle_age(settle))<<endl;
            }
          }
      }

      else
      {
        //  spawning biomass and total recruits will be calculated later so they can use Z
      }

  //  SS_Label_Info_24.3 #Loop the areas
      totbio=0.;
      smrybio=0.;  //  reset to zero happens every season, but accumulation and storage only in season=1; after area loop
      smrynum=0.;
      for (p=1;p<=pop;p++)
      {
        for (g=1;g<=gmorph;g++)
        if(use_morph(g)>0)
        {
  //  SS_Label_Info_24.3.1 #Get middle of season numbers-at-age from M only;
          Nmid(g) = elem_prod(natage(t,p,g),surv1(s,GP3(g)));      //  get numbers-at-age(g,a) surviving to middle of time period
          if(docheckup==1) echoinput<<p<<" "<<g<<" "<<GP3(g)<<" area & morph "<<endl<<"N-at-age "<<natage(t,p,g)(0,min(6,nages))<<endl
           <<"survival "<<surv1(s,GP3(g))(0,min(6,nages))<<endl;
          if(save_for_report==1)
          {
  //  SS_Label_Info_24.3.2 #Store some beginning of season quantities
            Save_PopLen(t,p,g)=0.0;
            Save_PopLen(t,p+pop,g)=0.0;  // later put midseason here
            Save_PopWt(t,p,g)=0.0;
            Save_PopWt(t,p+pop,g)=0.0;  // later put midseason here
            Save_PopAge(t,p,g)=0.0;
            Save_PopAge(t,p+pop,g)=0.0;  // later put midseason here
            Save_PopBio(t,p,g)=0.0;
            Save_PopBio(t,p+pop,g)=0.0;  // later put midseason here
            ALK_idx=(s-1)*N_subseas+1;
            for (a=0;a<=nages;a++)
            {
              Save_PopLen(t,p,g)+=value(natage(t,p,g,a))*value(ALK(ALK_idx,g,a));
              Save_PopWt(t,p,g)+=value(natage(t,p,g,a))*value(elem_prod(ALK(ALK_idx,g,a),wt_len(s,GP(g))));
              Save_PopAge(t,p,g,a)=value(natage(t,p,g,a));
              Save_PopBio(t,p,g,a)=value(natage(t,p,g,a))*value(Wt_Age_beg(s,g,a));
            } // close age loop
              if(s==1){
            totbio+=natage(t,p,g)(0,nages)*Wt_Age_beg(s,g)(0,nages);
            smrybio+=natage(t,p,g)(Smry_Age,nages)*Wt_Age_beg(s,g)(Smry_Age,nages);
            smrynum+=sum(natage(t,p,g)(Smry_Age,nages));   //sums to accumulate across platoons and settlements
            }
          }
        }

  //  SS_Label_Info_24.3.3 #Do fishing mortality
        catage_tot.initialize();

        if(catch_seas_area(t,p,0)==1 && fishery_on_off==1)
        {
          if(F_Method>1)  //  not Pope's
          {
//  SS_Label_Info_24.3.3.3 #use the hybrid F method by selected fleets
// hybrid F_method
            {
  //  SS_Label_Info_24.3.3.3.1 #Start by doing a Pope's approximation
              for (f=1;f<=Nfleet;f++)
              if(F_Method_byPH(f,current_phase())==3 && catch_seas_area(t,p,f)==1) // do hybrid F for this fleet
              {
                {
                  vbio.initialize();
                  for (g=1;g<=gmorph;g++)
                  if(use_morph(g)>0)
                  {
                    if(catchunits(f)==1)
                      {vbio+=Nmid(g)*sel_al_2(s,g,f);}    // retained catch bio
                    else
                      {vbio+=Nmid(g)*sel_al_4(s,g,f);}  // retained catch numbers
                  }  //close gmorph loop
    //  SS_Label_Info_24.3.3.3.2 #Apply constraint so that no fleet's initial calculation of harvest rate would exceed 95%
                  temp = catch_ret_obs(f,t)/(vbio+0.1*catch_ret_obs(f,t));  //  Pope's rate  robust
                  join1=1./(1.+mfexp(30.*(temp-0.95)));  // steep logistic joiner at harvest rate of 0.95
                  temp1=join1*temp + (1.-join1)*0.95;
    //  SS_Label_Info_24.3.3.3.3 #Convert the harvest rate to a starting value for F
                  Hrate(f,t)=-log(1.-temp1)/seasdur(s);  // initial estimate of F (even though labelled as Hrate)
//     if(y==1990)  warning<<"Pope "<<Hrate(f,t)<<" obs_cat "<<catch_ret_obs(1,t)<<endl;
                }
              }

  //  SS_Label_Info_24.3.3.3.4 #Do a specified number of loops to tune up these F values to more closely match the observed catch
              for (int tune_F=1;tune_F<=F_Tune-1;tune_F++)
              {
  //  SS_Label_Info_24.3.3.3.5 #add F+M to get Z
                for (g=1;g<=gmorph;g++)
                if(use_morph(g)>0)
                {
                  Z_rate(t,p,g)=natM(s,GP3(g));
                  for (f=1;f<=Nfleet;f++)       //loop over fishing fleets to get Z
                  if (catch_seas_area(t,p,f)!=0)
                  {
                    Z_rate(t,p,g)+=deadfish(s,g,f)*Hrate(f,t);
                  }
                  Zrate2(p,g)=elem_div( (1.-mfexp(-seasdur(s)*Z_rate(t,p,g))), Z_rate(t,p,g));
                }
//     if(y==1990)  warning<<tune_F<<" Z_6 "<<Z_rate(t,1,1,6)<<endl;

  //  SS_Label_Info_24.3.3.3.6 #Now calc adjustment to Z based on changes to be made to Hrate
                {
                  interim_tot_catch=0.0;   // this is the expected total catch that would occur with the current Hrates and Z
                  // totcatch_byarea(t,p) is now recalculated here just for the fleets doing hybrid in this phase
                  double target_catch = 0.0;
                  for (f=1;f<=Nfleet;f++)
                  {
                    if(F_Method_byPH(f,current_phase()) && catch_seas_area(t,p,f)==1)    //  skips bycatch fleets
                    {
                      for (g=1;g<=gmorph;g++)
                      if(use_morph(g)>0)
                      {
                        if(catchunits(f)==1)
                        {
                          interim_tot_catch+=catch_mult(y,f)*Hrate(f,t)*elem_prod(natage(t,p,g),sel_al_2(s,g,f))*Zrate2(p,g);  // biomass basis
                        }
                        else
                        {
                          interim_tot_catch+=catch_mult(y,f)*Hrate(f,t)*elem_prod(natage(t,p,g),sel_al_4(s,g,f))*Zrate2(p,g);  //  numbers basis
                        }
                      }  //close gmorph loop
                      target_catch+=catch_ret_obs(f,t);
                    }
                  }  // close fishery
                  Z_adjuster = target_catch/(interim_tot_catch+0.0001);
                  for (g=1;g<=gmorph;g++)
                  if(use_morph(g)>0)
                  {
                    Z_rate(t,p,g)=natM(s,GP3(g)) + Z_adjuster*(Z_rate(t,p,g)-natM(s,GP3(g)));  // find adjusted Z
                    Zrate2(p,g)=elem_div( (1.-mfexp(-seasdur(s)*Z_rate(t,p,g))), Z_rate(t,p,g));
                  }

                  for (f=1;f<=Nfleet;f++)       //loop over fishing  fleets with input catch
                  if(fleet_type(f)==1)
                  {
                    if(catch_seas_area(t,p,f)==1)
                    {
                      vbio=0.;  // now use this to calc the selected vulnerable biomass (numbers) to each fishery with the adjusted Zrate2
                      //  since catch = N * F*sel * (1-e(-Z))/Z
                      //  so F = catch / (N*sel * (1-e(-Z)) /Z )
                      for (g=1;g<=gmorph;g++)
                      if(use_morph(g)>0)
                      {
                        if(catchunits(f)==1)
                        {
                          vbio+=elem_prod(natage(t,p,g),sel_al_2(s,g,f)) *Zrate2(p,g);
                        }
                        else
                        {
                          vbio+=elem_prod(natage(t,p,g),sel_al_4(s,g,f)) *Zrate2(p,g);
                        }
                      }  //close gmorph loop
                      temp=catch_ret_obs(f,t)/(catch_mult(y,f)*vbio+0.0001);  //  prototype new F
                      join1=1./(1.+mfexp(30.*(temp-0.95*max_harvest_rate)));
                      Hrate(f,t)=join1*temp + (1.-join1)*max_harvest_rate;  //  new F value for this fleet
                    }  // close fishery
                  }
                }
//     if(y==1990)  warning<<tune_F<<" new_Hrate "<<Hrate(1,t)<<" ratio  "<<temp<<" join  "<<join1<<endl;
              }
            }   //  end hybrid F_Method

  //  SS_Label_Info_24.3.3.2 #Use a parameter for continuoous F
// continuous F_method
            {
  //  SS_Label_Info_24.3.3.2.1 #For each platoon, loop fleets to calculate Z = M+sum(F)
              for (g=1;g<=gmorph;g++)
              if(use_morph(g)>0)
              {
                Z_rate(t,p,g)=natM(s,GP3(g));
                for (f=1;f<=Nfleet;f++)
                if (catch_seas_area(t,p,f)==1)
                {
                  Z_rate(t,p,g)+=deadfish(s,g,f)*Hrate(f,t);
                }
                Zrate2(p,g)=elem_div( (1.-mfexp(-seasdur(s)*Z_rate(t,p,g))), Z_rate(t,p,g));
              }

  //  SS_Label_Info_24.3.3.2.2 #For each fleet, loop platoons and accumulate catch
              for (f=1;f<=Nfleet;f++)
              if (catch_seas_area(t,p,f)==1)
              {
                for (g=1;g<=gmorph;g++)
                if(use_morph(g)>0)
                {
                  catch_fleet(t,f,1)+=Hrate(f,t)*elem_prod(natage(t,p,g),sel_al_1(s,g,f))*Zrate2(p,g);
                  catch_fleet(t,f,2)+=Hrate(f,t)*elem_prod(natage(t,p,g),deadfish_B(s,g,f))*Zrate2(p,g);
                  catch_fleet(t,f,3)+=Hrate(f,t)*elem_prod(natage(t,p,g),sel_al_2(s,g,f))*Zrate2(p,g); // retained bio
                  catch_fleet(t,f,4)+=Hrate(f,t)*elem_prod(natage(t,p,g),sel_al_3(s,g,f))*Zrate2(p,g);
                  catch_fleet(t,f,5)+=Hrate(f,t)*elem_prod(natage(t,p,g),deadfish(s,g,f))*Zrate2(p,g);
                  catch_fleet(t,f,6)+=Hrate(f,t)*elem_prod(natage(t,p,g),sel_al_4(s,g,f))*Zrate2(p,g);  // retained numbers
                  catage(t,f,g)=Hrate(f,t)*elem_prod(elem_prod(natage(t,p,g),deadfish(s,g,f)),Zrate2(p,g));
                  if(Do_Retain(f)>0)
                    {
                    disc_age(t,disc_fleet_list(f),g)=Hrate(f,t)*elem_prod(elem_prod(natage(t,p,g),sel_al_3(s,g,f)),Zrate2(p,g)); //  selected numbers
                    disc_age(t,disc_fleet_list(f)+N_retain_fleets,g)=Hrate(f,t)*elem_prod(elem_prod(natage(t,p,g),sel_al_4(s,g,f)),Zrate2(p,g)); //  selected numbers
                    }
                }  //close gmorph loop
              }  // close fishery
            }   //  end continuous F method

          }
          else
// F_Method is Pope's approximation
          {
//  SS_Label_Info_24.3.3.1 #Use F_Method=1 for Pope's approximation
//  SS_Label_Info_24.3.3.1.1 #loop over fleets
            for (f=1;f<=Nfleet;f++)
            if (catch_seas_area(t,p,f)==1)
            {
              dvar_matrix catage_w=catage(t,f);      // do shallow copy

//  SS_Label_Info_24.3.3.1.2 #loop over platoons and calculate the vulnerable biomass for each fleet
              vbio.initialize();
              for (g=1;g<=gmorph;g++)
              if(use_morph(g)>0)
              {
                // use sel_l to get total catch and use sel_l_r to get retained vbio
                // note that vbio in numbers can be used for both survey abund and fishery available "biomass"
                // vbio is for retained catch only;  harvest rate = retainedcatch/vbio;
                // then harvestrate*catage_w = total kill by this fishery for this morph

                if(catchunits(f)==1)
                { vbio+=Nmid(g)*sel_al_2(s,g,f);}    // retained catch bio
                else
                { vbio+=Nmid(g)*sel_al_4(s,g,f);}  // retained catch numbers

              }  //close gmorph loop
              if(docheckup==1) echoinput<<"fleet vbio obs_catch catch_mult vbio*catchmult"<<f<<" "<<vbio<<" "<<catch_ret_obs(f,t)<<" "<<catch_mult(y,f)<<" "<<catch_mult(y,f)*vbio<<endl;
//  SS_Label_Info_24.3.3.1.3 #Calculate harvest rate for each fleet from catch/vulnerable biomass
              crashtemp1=0.;
              crashtemp=max_harvest_rate-catch_ret_obs(f,t)/(catch_mult(y,f)*vbio+NilNumbers);
              crashtemp1=posfun(crashtemp,0.000001,CrashPen);
              harvest_rate=max_harvest_rate-crashtemp1;
              if(crashtemp<0.&&rundetail>=2) {cout<<y<<" "<<f<<" crash vbio*catchmult "<<catch_ret_obs(f,t)/(catch_mult(y,f)*(vbio+NilNumbers))<<" "<<crashtemp<<
               " "<<crashtemp1<<" "<<CrashPen<<" "<<harvest_rate<<endl;}
              Hrate(f,t) = harvest_rate;

//  SS_Label_Info_24.3.3.1.4 #Store various catch quantities in catch_fleet
              for (g=1;g<=gmorph;g++)
              if(use_morph(g)>0)
              {
                catage_w(g)=harvest_rate*elem_prod(Nmid(g),deadfish(s,g,f));     // total kill numbers at age
                if(docheckup==1) echoinput<<"killrate "<<deadfish(s,g,f)(0,min(6,nages))<<endl;
                catage_tot(g) += catage_w(g); //catch at age for all fleets
                catch_fleet(t,f,2)+=Hrate(f,t)*Nmid(g)*deadfish_B(s,g,f);      // total fishery kill in biomass
                catch_fleet(t,f,5)+=Hrate(f,t)*Nmid(g)*deadfish(s,g,f);     // total fishery kill in numbers
                catch_fleet(t,f,1)+=Hrate(f,t)*Nmid(g)*sel_al_1(s,g,f);      //  total fishery encounter in biomass
                catch_fleet(t,f,3)+=Hrate(f,t)*Nmid(g)*sel_al_2(s,g,f);      // retained fishery kill in biomass
                catch_fleet(t,f,4)+=Hrate(f,t)*Nmid(g)*sel_al_3(s,g,f);      // encountered numbers
                catch_fleet(t,f,6)+=Hrate(f,t)*Nmid(g)*sel_al_4(s,g,f);      // retained fishery kill in numbers
              }  // end g loop
            }  // close fishery

//  SS_Label_Info_24.3.3.1.5 #Check for catch_total across fleets being greater than population numbers
            for (g=1;g<=gmorph;g++)
            if(use_morph(g)>0)
            {
              for (a=0;a<=nages;a++)    //  check for negative abundance, starting at age 1
              {
                if(natage(t,p,g,a)>0.0)
                {
                crashtemp=max_harvest_rate-catage_tot(g,a)/(Nmid(g,a)+0.0000001);
                crashtemp1=posfun(crashtemp,0.000001,CrashPen);
                if(crashtemp<0.&&rundetail>=2) {cout<<" crash age "<<catage_tot(g,a)/(Nmid(g,a)+0.0000001)<<" "<<crashtemp<<
                  " "<<crashtemp1<<" "<<CrashPen<<" "<<(max_harvest_rate-crashtemp1)*Nmid(g,a)<<endl; }
                if(crashtemp<0.&&docheckup==1) {echoinput<<" crash age "<<catage_tot(g,a)/(Nmid(g,a)+0.0000001)<<" "<<crashtemp<<
                  " "<<crashtemp1<<" "<<CrashPen<<" "<<(max_harvest_rate-crashtemp1)*Nmid(g,a)<<endl; }
                catage_tot(g,a)=(max_harvest_rate-crashtemp1)*Nmid(g,a);

                temp = natage(t,p,g,a)*surv2(s,GP3(g),a) -catage_tot(g,a)*surv1(s,GP3(g),a);
                Z_rate(t,p,g,a)=-log(temp/natage(t,p,g,a))/seasdur(s);
                }
                else
                {
                  Z_rate(t,p,g,a)=-log(surv2(s,GP3(g),a))/seasdur(s);
                }
              }
              if(docheckup==1) echoinput<<y<<" "<<s<<"total catch-at-age for morph "<<g<<" "<<catage_tot(g)(0,min(6,nages))<<" Z: "<<Z_rate(t,p,g)(0,min(6,nages))<<endl;
            }
          }   //  end Pope's approx
        }  //  end have some catch in this seas x area
        else
        {
  //  SS_Label_Info_24.3.3.4 #No catch or fishery turned off, so set Z=M
          for (g=1;g<=gmorph;g++)
          if(use_morph(g)>0)
          {Z_rate(t,p,g)=natM(s,GP3(g));}
        }
      } //close area loop
      if(s==1 && save_for_report==1){
        Smry_Table(y,1)=totbio;
        Smry_Table(y,2)=smrybio;
        Smry_Table(y,3)=smrynum;
      }
  //  SS_Label_Info_24.3.4 #Compute spawning biomass if occurs after start of current season
//  SPAWN-RECR:   calc spawn biomass in time series if after beginning of the season
      if(s==spawn_seas && spawn_time_seas>=0.0001)    //  compute spawning biomass
      {
        SSB_pop_gp(y).initialize();
        SSB_B_yr(y).initialize();
        SSB_N_yr(y).initialize();
        for (p=1;p<=pop;p++)
        {
          for (g=1;g<=gmorph;g++)
          if(sx(g)==1 && use_morph(g)>0)     //  female
          {
            SSB_pop_gp(y,p,GP4(g)) += fracfemale_mult*fec(g)*elem_prod(natage(t,p,g),mfexp(-Z_rate(t,p,g)*spawn_time_seas));   // accumulates SSB by area and by growthpattern
            SSB_B_yr(y) += fracfemale_mult*make_mature_bio(GP4(g))*elem_prod(natage(t,p,g),mfexp(-Z_rate(t,p,g)*spawn_time_seas));
            SSB_N_yr(y) += fracfemale_mult*make_mature_numbers(GP4(g))*elem_prod(natage(t,p,g),mfexp(-Z_rate(t,p,g)*spawn_time_seas));
          }
        }
        SSB_current=sum(SSB_pop_gp(y));
        SSB_yr(y)=SSB_current;

        if(Hermaphro_Option!=0)  // get male biomass
        {
          MaleSPB(y).initialize();
          for (p=1;p<=pop;p++)
          {
            for (g=1;g<=gmorph;g++)
            if(sx(g)==2 && use_morph(g)>0)     //  male; all assumed to be mature
            {
              MaleSPB(y,p,GP4(g)) += Save_Wt_Age(t,g)*elem_prod(natage(t,p,g),mfexp(-Z_rate(t,p,g)*spawn_time_seas));   // accumulates SSB by area and by growthpattern
            }
          }
          if(Hermaphro_maleSPB>0.0)  // add MaleSPB to female SSB
          {
            SSB_current+=Hermaphro_maleSPB*sum(MaleSPB(y));
            SSB_yr(y)=SSB_current;
          }
        }
  //  SS_Label_Info_24.3.4.1 #Get recruitment from this spawning biomass
//  SPAWN-RECR:   calc recruitment in time series; need to make this area-specific
      if(SR_parm_timevary(1)==0)  //  R0 is not time-varying
      {R0_use=Recr_virgin; SSB_use=SSB_virgin;}
      else
      {
        R0_use=mfexp(SR_parm_work(1));
        equ_Recr=R0_use;
        Fishon=0;
        eq_yr=y;
        bio_yr=y;
        Do_Equil_Calc(R0_use);                      //  call function to do equilibrium calculation
        if(fishery_on_off==1) {Fishon=1;} else {Fishon=0;}
        SSB_use=SSB_equil;
      }

        Recruits=Spawn_Recr(SSB_use,R0_use,SSB_current);  // calls to function Spawn_Recr
        apply_recdev(Recruits, R0_use);  //  apply recruitment deviation

// distribute Recruitment among settlements, areas and morphs
//  note that because SSB_current is calculated at end of season to take into account Z,
//  this means that recruitment cannot occur until a subsequent season
          for (g=1;g<=gmorph;g++)
          if(use_morph(g)>0)
          {
            settle=settle_g(g);
            for (p=1;p<=pop;p++)
            {
              if(y==styr) natage(t+Settle_seas_offset(settle),p,g,Settle_age(settle))=0.0;  //  to negate the additive code

              natage(t+Settle_seas_offset(settle),p,g,Settle_age(settle)) += Recruits*recr_dist(y,GP(g),settle,p)*platoon_distr(GP2(g))*
               mfexp(natM(s,GP3(g),Settle_age(settle))*Settle_timing_seas(settle));
               Recr(p,t+Settle_seas_offset(settle))+=Recruits*recr_dist(y,GP(g),settle,p)*platoon_distr(GP2(g));
               if(docheckup==1) echoinput<<y<<" Recruits, dist, surv, result"<<Recruits<<" "<<recr_dist(y,GP(g),settle,p)<<" "<<mfexp(natM(s,GP3(g),Settle_age(settle))*Settle_timing_seas(settle))<<" "<<natage(t+Settle_seas_offset(settle),p,g,Settle_age(settle))<<endl;
            }
          }
      }

  //  SS_Label_Info_24.6 #Survival to next season and saving midseason numbers and biomass
      for (p=1;p<=pop;p++)
      {
            if(s==nseas) {k=1;} else {k=0;}   //      advance age or not
            for (g=1;g<=gmorph;g++)
            if(use_morph(g)>0)
            {
                settle=settle_g(g);

              {
                j=Settle_age(settle);
                if(s<nseas && Settle_seas(settle)<=s)
                  {
                    natage(t+1,p,g,j) = natage(t,p,g,j)*mfexp(-Z_rate(t,p,g,j)*seasdur(s));  // advance new recruits within year
                  }
                for (a=j+1;a<nages;a++) {
                  natage(t+1,p,g,a) = natage(t,p,g,a-k)*mfexp(-Z_rate(t,p,g,a-k)*seasdur(s));
                  }
                natage(t+1,p,g,nages) = natage(t,p,g,nages)*mfexp(-Z_rate(t,p,g,nages)*seasdur(s));   // plus group
                if(s==nseas) natage(t+1,p,g,nages) += natage(t,p,g,nages-1)*mfexp(-Z_rate(t,p,g,nages-1)*seasdur(s));
                  if(save_for_report==1)
                  {
                    j=p+pop;
                    ALK_idx=(s-1)*N_subseas+mid_subseas;
                    for (a=0;a<=nages;a++)
                    {
                      Save_PopLen(t,j,g)+=value(natage(t,p,g,a)*mfexp(-Z_rate(t,p,g,a)*0.5*seasdur(s)))*value(ALK(ALK_idx,g,a));
                      Save_PopWt(t,j,g)+= value(natage(t,p,g,a)*mfexp(-Z_rate(t,p,g,a)*0.5*seasdur(s)))*value(elem_prod(ALK(ALK_idx,g,a),wt_len(s,GP(g))));
                      Save_PopAge(t,j,g,a)=value(natage(t,p,g,a)*mfexp(-Z_rate(t,p,g,a)*0.5*seasdur(s)));
                      Save_PopBio(t,j,g,a)=value(natage(t,p,g,a)*mfexp(-Z_rate(t,p,g,a)*0.5*seasdur(s)))*value(Wt_Age_mid(s,g,a));
                    } // close age loop
                  }
              }
              if(docheckup==1)
              {
                echoinput<<g<<" natM:   "<<natM(s,GP3(g))(0,min(6,nages))<<endl;
                echoinput<<g<<" Z:      "<<Z_rate(t,p,g)(0,min(6,nages))<<endl;
                echoinput<<g<<" N_surv: "<<natage(t+1,p,g)(0,min(6,nages))<<endl;
              }
            } // close gmorph loop
      }

  //  SS_Label_Info_24.7  #call to Get_expected_values
    Get_expected_values(y,t);
  //  SS_Label_Info_24.8  #hermaphroditism
      if(Hermaphro_Option!=0)
      {
        if(Hermaphro_seas==-1 || Hermaphro_seas==s)
        {
          k=gmorph/2;  //  because first half of the "g" are females
          for (p=1;p<=pop;p++)  //   area
          for (g=1;g<=k;g++)  //  loop females
          if(use_morph(g)>0)
          {
            if(Hermaphro_Option==1)
            {
              for (a=1;a<nages;a++)
              {
                natage(t+1,p,g+k,a) += natage(t+1,p,g,a)*Hermaphro_val(GP4(g),a-1); // increment males with females
                natage(t+1,p,g,a) *= (1.-Hermaphro_val(GP4(g),a-1)); // decrement females
              }
            } else
            if(Hermaphro_Option==-1)
            {
              for (a=1;a<nages;a++)
              {
                natage(t+1,p,g,a) += natage(t+1,p,g+k,a)*Hermaphro_val(GP4(g+k),a-1); // increment females with males
                natage(t+1,p,g+k,a) *= (1.-Hermaphro_val(GP4(g+k),a-1)); // decrement males
              }
            }
          }
        }
      }

  //  SS_Label_Info_24.9  #migration
//do migration between populations, for each gmorph and age  PROBLEM  need new container so future recruits not wiped out!
      if(do_migration>0)  // movement between areas in time series
      {
        natage_temp=natage(t+1);
        natage(t+1)=0.0;
        for (p=1;p<=pop;p++)  //   source population
        for (p2=1;p2<=pop;p2++)  //  destination population
        for (g=1;g<=gmorph;g++)
        if(use_morph(g)>0)
        {
          k=move_pattern(s,GP4(g),p,p2);
          if(k>0) natage(t+1,p2,g) += elem_prod(natage_temp(p,g),migrrate(y,k));}
      }  //  end migration

  //  SS_Label_Info_24.10  #save selectivity*Hrate for tag-recapture
      if(Do_TG>0 && t>=TG_timestart)
      {
        for (g=1;g<=gmorph;g++)
        for (f=1;f<=Nfleet;f++)
        {
          Sel_for_tag(t,g,f) = sel_al_4(s,g,f)*Hrate(f,t);
        }
      }

  //  SS_Label_Info_24.11  #calc annual F quantities
      double countN;
      dvariable tempbase;
      dvariable tempM;
      dvariable tempZ;
      if( fishery_on_off==1 && (bigsaver==1 || (F_ballpark_yr>=styr)))
      {
        for (f=1;f<=Nfleet;f++)
        if(fleet_type(f)<=2)
        {
          for (k=1;k<=6;k++)
          {
            annual_catch(y,k)+=catch_fleet(t,f,k);
            if(k<=3) Smry_Table(y,k+3)=annual_catch(y,k);
          }
          if(F_Method==1)
          {
            annual_F(y,1)+=Hrate(f,t);
          }
          else
          {
            annual_F(y,1)+=Hrate(f,t)*seasdur(s);
          }
        }

        if(s==nseas)
        {
  //  sum across p and g the number of survivors to end of the year
  //  also project from the initial numbers and M, the number of survivors without F
  //  then F = ln(n+1/n)(M+F) - ln(n+1/n)(M only), but ln(n) cancels out, so only need the ln of the ratio of the two ending quantities

          // calculated average F weighted by numbers (option 5 is unweighted)
          if(F_reporting!=5)
          {
            tempbase=0.0;
            tempM=0.0;
            tempZ=0.0;
            annual_F(y,2)=0.;
            annual_F(y,3)=0.;
            //  accumulate numbers across ages, morphs, sexes, areas
            for (a=F_reporting_ages(1);a<=F_reporting_ages(2);a++)   //  should not let a go higher than nages-2 because of accumulator
            {
              for (g=1;g<=gmorph;g++)
              if(use_morph(g)>0)
              {
                for (p=1;p<=pop;p++)
                {
                   tempbase+=natage(t-nseas+1,p,g,a);  // sum of numbers at beginning of year
                   tempZ+=natage(t+1,p,g,a+1);  // numbers at beginning of next year
                   temp3=natage(t-nseas+1,p,g,a);  //  numbers at begin of year
                   for (j=1;j<=nseas;j++) {temp3*=mfexp(-seasdur(j)*natM(j,GP3(g),a));}
                   tempM+=temp3;  //  survivors if just M operating
                }
              }
            }
            if(y==21 || y==220)  warning<<endl<<y<<" "<<tempbase<<" "<<tempM<<" "<<tempZ;
            annual_F(y,2) = log(tempM)-log(tempZ);  // F=Z-M
            annual_F(y,3) = log(tempbase)-log(tempM);  // M
            if(y==21 || y==220)  warning<<annual_F(y,2)<<" "<<annual_F(y,3)<<endl;
          } // end if F_reporting!=5

          else
          {    // F_reporting==5 (ICES-style arithmetic mean across ages)
               //  like option 4 above, but F is calculated 1 age at a time to get a
               //  unweighted average across ages within each year
            countN=0.0;  // used for count of Fs included in average
            for (a=F_reporting_ages(1);a<=F_reporting_ages(2);a++)   //  should not let a go higher than nages-2 because of accumulator
            {
              tempbase=0.0;
              tempM=0.0;
              tempZ=0.0;
//  accumulate numbers across all morphs, sexes, and areas
              for (g=1;g<=gmorph;g++)
              if(use_morph(g)>0)
              {
                 for (p=1;p<=pop;p++)
                 {
                   tempbase+=natage(t-nseas+1,p,g,a);  // sum of numbers at beginning of year
                   tempZ+=natage(t+1,p,g,a+1);  // numbers at beginning of next year
                   temp3=natage(t-nseas+1,p,g,a);  //  numbers at begin of year
                   for (j=1;j<=nseas;j++) {temp3*=mfexp(-seasdur(j)*natM(j,GP3(g),a));}
                   tempM+=temp3;  //  survivors if just M operating
                }
              }
//  calc F and M for this age and add to the total
              countN += 1; // increment count of values included in average
              annual_F(y,2) += log(tempM)-log(tempZ);  // F=Z-M
              annual_F(y,3) += log(tempbase)-log(tempM);  // M
//              if(save_for_report==1)  warning<<N_warn<<" "<<y<<"  age: "<<a<<" count: "<<countN<<" Z: "<<log(tempbase)-log(tempZ)<<" M: "<<log(tempbase)-log(tempM)<<" F: "<<log(tempM)-log(tempZ)<<" "<<annual_F(y)(2,3)<<endl;
            }
            annual_F(y,3) /= countN;  // M
            annual_F(y,2) /= countN;   // F
          } // end F_reporting==5

          if(STD_Yr_Reverse_F(y)>0)  //  save selected std quantity
          {
            if(F_reporting<=1)
            {
              F_std(STD_Yr_Reverse_F(y))=annual_catch(y,2)/Smry_Table(y,2);  // dead catch biomass/summary biomass
                                                                             //  does not exactly correspond to F, which is for total catch
            }
            else if(F_reporting==2)
            {
              F_std(STD_Yr_Reverse_F(y))=annual_catch(y,5)/Smry_Table(y,3);  // dead catch numbers/summary numbers
            }
            else if(F_reporting==3)
            {
              F_std(STD_Yr_Reverse_F(y))=annual_F(y,1);
            }
            else if(F_reporting==4 || F_reporting==5)
            {
              F_std(STD_Yr_Reverse_F(y))=annual_F(y,2);
            }
          }
        }  //  end s==nseas
      }
        if(write_bodywt>0)
        {
          for(g=1;g<=gmorph;g++)
          {
            gg=sx(g);

            if(ishadow(GP2(g))==0)
              {
                if(s==spawn_seas) bodywtout<<y<<" "<<s<<" "<<gg<<" "<<GP4(g)<<" "<<Bseas(g)<<" "<<-2<<" "<<fec(g)<<" #fecundity "<<endl;
                bodywtout<<y<<" "<<s<<" "<<gg<<" "<<GP4(g)<<" "<<Bseas(g)<<" "<<0<<" "<<Wt_Age_beg(s,g)<<" #popwt_beg "<<endl;
                bodywtout<<y<<" "<<s<<" "<<gg<<" "<<GP4(g)<<" "<<Bseas(g)<<" "<<-1<<" "<<Wt_Age_mid(s,g)<<" #popwt_mid "<<endl;
              }
          }
        }
    } //close season loop
  //  SS_Label_Info_24.12 #End loop of seasons

  //  SS_Label_Info_24.13 #Use current F intensity to calculate the equilibrium SPR for this year
//    if( (save_for_report>0) || ((sd_phase() || mceval_phase()) && (initial_params::mc_phase==0)) )
   if(bigsaver==1)
    {
      eq_yr=y; equ_Recr=Recr_virgin; bio_yr=y;
      Fishon=0;
      Do_Equil_Calc(equ_Recr);                      //  call function to do equilibrium calculation with current year's biology
      Smry_Table(y,11)=SSB_equil;
      Smry_Table(y,13)=GenTime;
      Fishon=1;
      Do_Equil_Calc(equ_Recr);                      //  call function to do equilibrium calculation with current year's biology and F
      if(STD_Yr_Reverse_Ofish(y)>0)
      {
        SPR_std(STD_Yr_Reverse_Ofish(y))=SSB_equil/Smry_Table(y,11);
      }
      Smry_Table(y,9)=(totbio);
      Smry_Table(y,10)=(smrybio);
      Smry_Table(y,12)=(SSB_equil);
      Smry_Table(y,14)=(YPR_dead);
      for (g=1;g<=gmorph;g++)
      {
        Smry_Table(y,20+g)=(cumF(g));
        Smry_Table(y,20+gmorph+g)=(maxF(g));
      }
    }
  } //close year loop

//  Save end year quantities to refresh for forecast after benchmark is called
  recr_dist_endyr=recr_dist(endyr);
  natM_endyr=natM;
  surv1_endyr=surv1;
  surv2_endyr=surv2;

//  average quantities accumulated during the time series
  if(Do_Benchmark>0)
 {
  recr_dist(styr-3)=recr_dist_unf/float(Bmark_Yr(8)-Bmark_Yr(7)+1);
  natM_unf/=float(Bmark_Yr(2)-Bmark_Yr(1)+1);
  surv1_unf/=float(Bmark_Yr(2)-Bmark_Yr(1)+1);
  surv2_unf/float(Bmark_Yr(2)-Bmark_Yr(1)+1);
 }

  if(Do_TG>0) Tag_Recapture();

  }  //  end time_series
 #ifdef DO_ONCE
          if(do_once==1) echoinput<<" finished time series "<<endl;
 #endif

  //  SS_Label_Info_24.16  # end of time series function

//********************************************************************
 /*  SS_Label_FUNCTION 30 Do_Equil_Calc */
FUNCTION void Do_Equil_Calc(const prevariable& equ_Recr)
  {
  int t_base;
  int t;
  int s;
  dvariable N_mid;
  dvariable N_beg;
  dvariable tempM, countN, tempZ, tempbase, temp3;
  dvariable Fishery_Survival;
  dvariable crashtemp;
  dvariable crashtemp1;
  dvar_matrix Survivors(1,pop,1,gmorph);
  dvar_matrix Survivors2(1,pop,1,gmorph);

   t_base=styr+(eq_yr-styr)*nseas-1;
   GenTime.initialize(); Equ_penalty.initialize();
   cumF.initialize(); maxF.initialize();
   SSB_equil_pop_gp.initialize();
   if(Hermaphro_Option!=0) MaleSSB_equil_pop_gp.initialize();
   equ_mat_bio=0.0;
   equ_mat_num=0.0;
   equ_catch_fleet.initialize();
   equ_numbers.initialize();
   equ_catage.initialize();
   equ_F_std=0.0;
   equ_M_std=0.0;
   totbio=0.0;
   smrybio=0.0;
   smryage=0.0;
   smrynum=0.0;

// first seed the recruits; seems redundant
      for (g=1;g<=gmorph;g++)
      {
        if(use_morph(g)>0)
        {
          settle=settle_g(g);

          for (p=1;p<=pop;p++)
          {
            equ_numbers(Settle_seas(settle),p,g,Settle_age(settle)) = equ_Recr*recr_dist(y,GP(g),settle,p)*platoon_distr(GP2(g))*
             mfexp(natM(Settle_seas(settle),GP3(g),Settle_age(settle))*Settle_timing_seas(settle));
          }
        }
      }

     for (a=0;a<=3*nages;a++)     // go to 3x nages to approximate the infinite tail, then add the infinite tail
     {
       if(a<=nages) {a1=a;} else {a1=nages;}    // because selex and biology max out at nages

       for (s=1;s<=nseas;s++)
       {
         t=t_base+s;

         for (g=1;g<=gmorph;g++)  //  need to loop g inside of a because of hermaphroditism
         if(use_morph(g)>0)
         {
           gg=sx(g);    // gender
           settle=settle_g(g);

           for (p=1;p<=pop;p++)
           {
             if(s==Settle_seas(settle) && a==Settle_age(settle))
              {
                equ_numbers(Settle_seas(settle),p,g,Settle_age(settle)) = equ_Recr*recr_dist(y,GP(g),settle,p)*platoon_distr(GP2(g))*
                mfexp(natM(Settle_seas(settle),GP3(g),Settle_age(settle))*Settle_timing_seas(settle));
              }

           if(equ_numbers(s,p,g,a)>0.0)  //  will only be zero if not yet settled
           {
             N_beg=equ_numbers(s,p,g,a);
             if(F_Method==1)   // Pope's approx
             {
                 N_mid = N_beg*surv1(s,GP3(g),a1);     // numbers at middle of season
                 Nsurvive=N_mid;                            // initial number of fishery survivors
                 if(Fishon==1)
                 {                       //  remove catch this round
                   // check to see if total harves would exceed max_harvest_rate
                   crashtemp=0.;  harvest_rate=1.0;
                   for (f=1;f<=Nfleet;f++)
                   if (fleet_area(f)==p && Hrate(f,t)>0.)
                   {
                     crashtemp+=Hrate(f,t)*deadfish(s,g,f,a1);
                   }

                   if(crashtemp>0.20)                  // only worry about this if the exploit rate is at all high
                   {
                     join1=1./(1.+mfexp(40.0*(crashtemp-max_harvest_rate)));  // steep joiner logistic curve at limit
                     upselex=1./(1.+mfexp(Equ_F_joiner*(crashtemp-0.2)));          //  value of a shallow logistic curve that goes through the limit
                     harvest_rate = join1 + (1.-join1)*upselex/(crashtemp);      // ratio by which all Hrates will be adjusted
                   }

                   for (f=1;f<=Nfleet;f++)
                   if (fleet_area(f)==p && Hrate(f,t)>0. && fleet_type(f)<=2)
                   {
                     temp=N_mid*Hrate(f,t)*harvest_rate;     // numbers that would be caught if fully selected
                     Nsurvive-=temp*deadfish(s,g,f,a1);       //  survival from fishery kill
                     equ_catch_fleet(2,s,f) += temp*deadfish_B(s,g,f,a1);
                     equ_catch_fleet(5,s,f) += temp*deadfish(s,g,f,a1);
                     equ_catch_fleet(3,s,f) += temp*sel_al_2(s,g,f,a1);      // retained fishery kill in biomass

                       equ_catch_fleet(1,s,f)+=temp*sel_al_1(s,g,f,a1);      //  total fishery encounter in biomass
                       equ_catch_fleet(4,s,f)+=temp*sel_al_3(s,g,f,a1);    // total fishery encounter in numbers
                       equ_catch_fleet(6,s,f)+=temp*sel_al_4(s,g,f,a1);      // retained fishery kill in numbers
                       equ_catage(s,f,g,a1)+=temp*deadfish(s,g,f,a1);      //  dead catch numbers per recruit  (later accumulate N in a1)
                   }
                 }   // end removing catch

                 Nsurvive *= surv1(s,GP3(g),a1);  // decay to end of season

                 if(a<=a1)
                 {
                   equ_Z(s,p,g,a1) = -(log((Nsurvive+1.0e-13)/(N_beg+1.0e-10)))/seasdur(s);
                   Fishery_Survival = equ_Z(s,p,g,a1)-natM(s,GP3(g),a1);
                   if(a>=Smry_Age)
                   {
                     cumF(g)+=Fishery_Survival*seasdur(s);
                     if(Fishery_Survival>maxF(g)) maxF(g)=Fishery_Survival;
                   }
                 }

             }   // end Pope's approx

             else          // Continuous F for method 2 or 3
             {
               equ_Z(s,p,g,a1)=natM(s,GP3(g),a1);
                 if(Fishon==1)
                 {
                   if(a1<=nages)
                   {
                     for (f=1;f<=Nfleet;f++)       //loop over fishing fleets to get Z
                     if (fleet_area(f)==p && Hrate(f,t)>0.0 && fleet_type(f)<=2)
                     {
                       equ_Z(s,p,g,a1)+=deadfish(s,g,f,a1)*Hrate(f,t);
                     }
                     if(save_for_report>0)
                     {
                       temp=equ_Z(s,p,g,a1)-natM(s,GP3(g),a1);
                       if(a>=Smry_Age && a<=nages) cumF(g)+=temp*seasdur(s);
                       if(temp>maxF(g)) maxF(g)=temp;
                     }
                   }
                 }
                 Nsurvive=N_beg*mfexp(-seasdur(s)*equ_Z(s,p,g,a1));

             }  //  end F method
             Survivors(p,g)=Nsurvive;
           }
           else
            {
               equ_Z(s,p,g,a1)=natM(s,GP3(g),a1);
            }
           }  // end pop
         }  // end morph

         if(Hermaphro_Option!=0)
         {
           if(Hermaphro_seas==-1 || Hermaphro_seas==s)
           {
             for (p=1;p<=pop;p++)
             {
               k=gmorph/2;
               for (g=1;g<=k;g++)
               if(use_morph(g)>0)
               {
                 if(Hermaphro_Option==1)
                 {
                   Survivors(p,g+k) += Survivors(p,g)*Hermaphro_val(GP4(g),a1); // increment males with females
                   Survivors(p,g) *= (1.-Hermaphro_val(GP4(g),a1)); // decrement females
                 } else
                 if(Hermaphro_Option==-1)
                 {
                   Survivors(p,g) += Survivors(p,g+k)*Hermaphro_val(GP4(g+k),a1); // increment females with males
                   Survivors(p,g+k) *= (1.-Hermaphro_val(GP4(g+k),a1)); // decrement males
                 }
               }
             }
           }
         }
          if(do_migration>0)  // movement between areas in equil calcs
          {
            Survivors2.initialize();
            for (g=1;g<=gmorph;g++)
            if(use_morph(g)>0)
            {
              for (p=1;p<=pop;p++)
              for (p2=1;p2<=pop;p2++)
              {
                k=move_pattern(s,GP4(g),p,p2);
                if(k>0) Survivors2(p2,g) += Survivors(p,g)*migrrate(bio_yr,k,a1);
              }  // end destination pop
            }
            Survivors=Survivors2;
          }  // end do migration

          for (g=1;g<=gmorph;g++)
          if(use_morph(g)>0)
          {
            for (p=1;p<=pop;p++)
            {
              if(s==nseas)  // into next age at season 1
              {
                if(a==3*nages)
                {
                  // end of the cohort
                }
                else if(a==(3*nages-1))           // do infinite tail; note that it uses Z from nseas as if it applies annually
                {
                  if(F_Method==1)
                  {
                    equ_numbers(1,p,g,a+1) = Survivors(p,g)/(1.-exp(-equ_Z(nseas,p,g,nages)));
                  }
                  else
                  {
                    equ_numbers(1,p,g,a+1) = Survivors(p,g)/(1.-exp(-equ_Z(nseas,p,g,nages)));
                  }
                }
                else
                {
                  equ_numbers(1,p,g,a+1) = Survivors(p,g);
                }
              }
              else
              {
                equ_numbers(s+1,p,g,a) = Survivors(p,g);  // same age, next season
              }

            }
          }
        }  // end season
     }  // end age

// now calc contribution to catch and ssb
       for (g=1;g<=gmorph;g++)
       if(use_morph(g)>0)
       {
         gg=sx(g);
         for (s=1;s<=nseas;s++)
         for (p=1;p<=pop;p++)
         {
           t=t_base+s;
           equ_numbers(s,p,g,nages)+=sum(equ_numbers(s,p,g)(nages+1,3*nages));
           if(Fishon==1)
           {
             if(F_Method>=2)
             {
               Zrate2(p,g)=elem_div( (1.-mfexp(-seasdur(s)*equ_Z(s,p,g))), equ_Z(s,p,g));
               if(s<Bseas(g)) Zrate2(p,g,0)=0.0;
               for (f=1;f<=Nfleet;f++)
               if (fleet_area(f)==p && fleet_type(f)<=2)
               if(Hrate(f,t)>0.0)
               {
                 equ_catch_fleet(2,s,f)+=Hrate(f,t)*elem_prod(equ_numbers(s,p,g)(0,nages),deadfish_B(s,g,f))*Zrate2(p,g);      // dead catch bio
                 equ_catch_fleet(5,s,f)+=Hrate(f,t)*elem_prod(equ_numbers(s,p,g)(0,nages),deadfish(s,g,f))*Zrate2(p,g);      // deadfish catch numbers
                 equ_catch_fleet(3,s,f)+=Hrate(f,t)*elem_prod(equ_numbers(s,p,g)(0,nages),sel_al_2(s,g,f))*Zrate2(p,g);      // retained catch bio
                   equ_catage(s,f,g)=elem_prod(elem_prod(equ_numbers(s,p,g)(0,nages),deadfish(s,g,f)) , Zrate2(p,g));
                   equ_catch_fleet(1,s,f)+=Hrate(f,t)*elem_prod(equ_numbers(s,p,g)(0,nages),sel_al_1(s,g,f))*Zrate2(p,g);      // encountered catch bio
                   equ_catch_fleet(4,s,f)+=Hrate(f,t)*elem_prod(equ_numbers(s,p,g)(0,nages),sel_al_3(s,g,f))*Zrate2(p,g);      // encountered catch bio
                   equ_catch_fleet(6,s,f)+=Hrate(f,t)*elem_prod(equ_numbers(s,p,g)(0,nages),sel_al_4(s,g,f))*Zrate2(p,g);      // retained catch numbers
               }
             }
             else  // F_method=1
             {
               // already done in the age loop
             }
           }

           if(s==1)
           {
             totbio += equ_numbers(s,p,g)(0,nages)*Wt_Age_beg(s,g)(0,nages);
             smrybio += equ_numbers(s,p,g)(Smry_Age,nages)*Wt_Age_beg(s,g)(Smry_Age,nages);
             smrynum += sum(equ_numbers(s,p,g)(Smry_Age,nages));
             smryage += equ_numbers(s,p,g)(Smry_Age,nages) * r_ages(Smry_Age,nages);
           }
//  SPAWN-RECR:   calc generation time, etc.
           if(s==spawn_seas)
           {
             if(gg==1)  // compute equilibrium spawning biomass for females
             {
              tempvec_a=elem_prod(equ_numbers(s,p,g)(0,nages),mfexp(-spawn_time_seas*equ_Z(s,p,g)(0,nages)));
               SSB_equil_pop_gp(p,GP4(g))+=fracfemale_mult*tempvec_a*fec(g);
               equ_mat_bio+=fracfemale_mult*elem_prod(equ_numbers(s,p,g)(0,nages),mfexp(-spawn_time_seas*equ_Z(s,p,g)(0,nages)))*make_mature_bio(GP4(g));
               equ_mat_num+=fracfemale_mult*elem_prod(equ_numbers(s,p,g)(0,nages),mfexp(-spawn_time_seas*equ_Z(s,p,g)(0,nages)))*make_mature_numbers(GP4(g));
               GenTime+=fracfemale_mult*tempvec_a*elem_prod(fec(g),r_ages);
//               SSB_equil_pop_gp(p,GP4(g))+=tempvec_a*fec(g);
//              equ_mat_bio+=elem_prod(equ_numbers(s,p,g)(0,nages),mfexp(-spawn_time_seas*equ_Z(s,p,g)(0,nages)))*make_mature_bio(GP4(g));
//               equ_mat_num+=elem_prod(equ_numbers(s,p,g)(0,nages),mfexp(-spawn_time_seas*equ_Z(s,p,g)(0,nages)))*make_mature_numbers(GP4(g));
//               GenTime+=tempvec_a*elem_prod(fec(g),r_ages);
             }
             else if(Hermaphro_Option!=0 && gg==2)
             {
               tempvec_a=elem_prod(equ_numbers(s,p,g)(0,nages),mfexp(-spawn_time_seas*equ_Z(s,p,g)(0,nages)));
               MaleSSB_equil_pop_gp(p,GP4(g))+=tempvec_a*Wt_Age_beg(s,g)(0,nages);
             }
           }
         }
       }

     YPR_dead =   sum(equ_catch_fleet(2));    // dead yield per recruit
     if(N_bycatch==0)
     {YPR_opt=YPR_dead;}
     else
     {
       YPR_opt = 0.0;
       for(f=1;f<=Nfleet;f++)
       {
        if(YPR_mask(f)>0)
         {
          for (s=1;s<=nseas;s++) {YPR_opt+=equ_catch_fleet(2,s,f);}
         }
       }
     }
     YPR_N_dead = sum(equ_catch_fleet(5));    // dead numbers per recruit
     YPR_enc =    sum(equ_catch_fleet(1));    //  encountered yield per recruit
     YPR_ret =    sum(equ_catch_fleet(3));    // retained yield per recruit

   if(Fishon==1)
   {
     if(F_reporting<=1)
     {
       equ_F_std=YPR_dead/smrybio;
       equ_M_std=natM(1,1,int(nages/2));
     }
     else if(F_reporting==2)
     {
       equ_F_std=YPR_N_dead/smrynum;
       equ_M_std=natM(1,1,int(nages/2));
     }
     else if(F_reporting==3)
     {
       equ_M_std=natM(1,1,int(nages/2));
       if(F_Method==1)
       {
         for (s=1;s<=nseas;s++)
         {
           t=t_base+s;
           for (f=1;f<=Nfleet;f++)
           {
             equ_F_std+=Hrate(f,t);
           }
         }
       }
       else
       {
         for (s=1;s<=nseas;s++)
         {
           t=t_base+s;
           for (f=1;f<=Nfleet;f++)
           {
             equ_F_std+=Hrate(f,t)*seasdur(s);
           }
         }
       }
     }
     else if(F_reporting==4)
     {
        tempbase=0.0;
        tempM=0.0;
        tempZ=0.0;
        //  accumulate numbers across ages, morphs, sexes, areas
        for (a=F_reporting_ages(1);a<=F_reporting_ages(2);a++)   //  should not let a go higher than nages-2 because of accumulator
        {
          for (g=1;g<=gmorph;g++)
          if(use_morph(g)>0)
          {
            for (p=1;p<=pop;p++)
            {
               tempbase+=equ_numbers(1,p,g,a);  // sum of numbers at beginning of year
               tempZ+=equ_numbers(1,p,g,a+1);  // numbers at beginning of next year
               temp3=equ_numbers(1,p,g,a);  //  numbers at begin of year
               for (int kkk=1;kkk<=nseas;kkk++) {temp3*=mfexp(-seasdur(kkk)*natM(kkk,GP3(g),a));}
               tempM+=temp3;  //  survivors if just M operating
            }
          }
        }
        equ_F_std = log(tempM)-log(tempZ);  // F=Z-M
        equ_M_std = log(tempbase)-log(tempM);  // M
     }
      else if(F_reporting==5)
      {
    //  F_reporting==5 (ICES-style arithmetic mean across ages)
    //  like option 4 above, but F is calculated 1 age at a time to get a
    //  unweighted average across ages within each year
    //  Need to put area loop within age loop
        countN=0.0;  // used for count of Fs included in average
        for (a=F_reporting_ages(1);a<=F_reporting_ages(2);a++)   //  should not let a go higher than nages-2 because of accumulator
        {
          tempbase=0.0;
          tempM=0.0;
          tempZ=0.0;
//  accumulate numbers across all morphs, sexes, and areas
          for (g=1;g<=gmorph;g++)
          if(use_morph(g)>0)
          {
             for (p=1;p<=pop;p++)
             {
               tempbase+=equ_numbers(1,p,g,a);  // sum of numbers at beginning of year
               tempZ+=equ_numbers(1,p,g,a+1);  // numbers at beginning of next year
               temp3=equ_numbers(1,p,g,a);  //  numbers at begin of year
               for (int kkk=1;kkk<=nseas;kkk++) {temp3*=mfexp(-seasdur(kkk)*natM(kkk,GP3(g),a));}
               tempM+=temp3;  //  survivors if just M operating
             }
          }
        // add F-at-age to tally
          countN += 1.; // increment count of values included in average
          equ_F_std += log(tempM)-log(tempZ);  // F=Z-M
          equ_M_std += log(tempbase)-log(tempM);  // M
        }
        equ_F_std /= countN;
        equ_M_std /= countN;
      } // end F_reporting==5
   }
   SSB_equil=sum(SSB_equil_pop_gp);
   GenTime/=SSB_equil;
   smryage /= smrynum;
   cumF/=(r_ages(nages)-r_ages(Smry_Age)+1.);
   if(Hermaphro_maleSPB>0.0)  // add MaleSPB to female SSB
              {SSB_equil+=Hermaphro_maleSPB*sum(MaleSSB_equil_pop_gp);}

  }  //  end equil calcs

