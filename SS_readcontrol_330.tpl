
 LOCAL_CALCS
//********CONTROLS********************************
//  SS_Label_Info_4.0 #Begin Reading from Control File
// /*  SS_Label_Flow  begin reading from control file */
  ad_comm::change_datafile_name(ctlfilename);
  echoinput<<endl<<" Begin reading control file "<<endl;
  cout<<" reading from control file"<<endl;
  ifstream Control_Stream(ctlfilename);   //  even if the global_datafile name is used, there still is a different logical device created

//  SS_Label_Info_4.1 #Read and store comments at top of control file
  k=0;
  N_CC=0;
  while(k==0)
  {
    Control_Stream >>  readline;          // reads the line from input stream
    if(length(readline)>2)
    {
      checkchar=readline(1);
      k=strcmp(checkchar,"#");
      checkchar=readline(1,2);
      j=strcmp(checkchar,"#C");
      if(j==0) {N_CC++; Control_Comments+=readline;}
    }
  }
 END_CALCS

//  when a parameter is defined and its label (hence usage) is created,
//  the value of its min, max, init, prior have not yet been read
//  so when it gets created, need to pushback a code to indicate what special conditions affect it
//  also may want to save indicator of whether the parameter is multiplier, logit, etc.
//  so pushback a code to the ivector Parm_minmax
//  and add a string to the adstring_array Parm_info
  ivector minmax_types(1,10)  //  set of canned min-max types
 
!!//  SS_Label_Info_4.2 #Read info for growth patterns, gender, settlement events, platoons
  init_int WTage_rd  // 0 means do not read wtatage.ss; 1 means read and use wtatage.ss and also read and use growth parameters
                     //  future option 2 will suppress reading and use of growth
  !!echoinput<<WTage_rd<<" wtatage switch "<<endl;
  init_int N_GP  // number of growth patterns (morphs)
  !!echoinput<<N_GP<<" N growth patterns "<<endl;
  init_int N_platoon  //  number of platoons  1, 3, 5 are best values to use
  !!echoinput<<N_platoon<<"  N platoons (1, 3 or 5)"<<endl;
  number sd_ratio;  // ratio of stddev within platoon to between morphs
  number sd_within_platoon
  number sd_between_platoon
  ivector ishadow(1,N_platoon)
  vector shadow(1,N_platoon)
  vector platoon_distr(1,N_platoon);
 LOCAL_CALCS
  if(WTage_rd>0 && nobs_mnwt>0)
    {N_warn++;
     warning<<N_warn<<" "<<"incompatible option:  empirical bodywt-at-age is used, but meanbody_wt obs fit using growth curve"<<endl;}

  if(N_platoon>1)
  {
    *(ad_comm::global_datafile) >> sd_ratio;
    *(ad_comm::global_datafile) >> platoon_distr;
  echoinput<<sd_ratio<<"  sd_ratio"<<endl;
  echoinput<<platoon_distr<<"  platoon_distr"<<endl;
  }
  else
  {
    sd_ratio=1.;
    platoon_distr(1)=1.;
    echoinput<<"  do not read sd_ratio or platoon_distr"<<endl;
  }
//  SS_Label_Info_4.2.1 #Assign distribution among growth platoons if needed
  if(platoon_distr(1)<0.)
  {
    if(N_platoon==1)
      {platoon_distr(1)=1.;}
    else if (N_platoon==3)
      {platoon_distr.fill("{0.15,0.70,0.15}");}
    else if (N_platoon==5)
      {platoon_distr.fill("{0.031, 0.237, 0.464, 0.237, 0.031}");}
  }
  platoon_distr/=sum(platoon_distr);

  if(N_platoon>1)
  {
    sd_within_platoon = sd_ratio * sqrt(1. / (1. + sd_ratio*sd_ratio));
    sd_between_platoon = sqrt(1. / (1. + sd_ratio*sd_ratio));
  }
  else
  {sd_within_platoon=1; sd_between_platoon=0.000001;}

   if(N_platoon==1)
     {ishadow(1)=0; shadow(1)=0.;}
   else if (N_platoon==3)
     {ishadow.fill_seqadd(-1,1); shadow.fill_seqadd(-1.,1.);}
   else if (N_platoon==5)
     {ishadow.fill_seqadd(-2,1); shadow.fill_seqadd(-2.,1.);}
   else
     {N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" "<<" illegal N platoons, must be 1, 3 or 5 "<<N_platoon<<endl; exit(1);}

 END_CALCS

!!//  SS_Label_Info_4.2.2  #Define distribution of recruitment(settlement) among growth patterns, areas, months

  int recr_dist_method  //  1=like 3.24 (not used); 2=main effects for GP, Settle timing, Area; 3=each Settle entity; 4=no parms (only if GPXsettleXarea=1)
  int recr_dist_area  //  1=global SRR; 2=area-specific SRR
  int N_settle_assignments  //  number of assigned settlements for GP, Settle_month, Area (>=0)
  int N_settle_assignments_rd  //  number read, needed to distinguish between ss3.24 and SS3.30 setup
  int N_settle_timings  //  number of recruitment settlement timings per spawning (>=1) - important for number of morphs calculation
                         //  will be calculated from the number of unique settle_months among the settle_assignments
  int settle  //  index to settle_assignments
  int settle_time  //  index to setting timings
  int Comp_Err_Parm_Start
  int recr_dist_inx
 LOCAL_CALCS
    *(ad_comm::global_datafile) >> recr_dist_method;
    echoinput<<recr_dist_method<<"  # Recruitment distribution method; where: 2=parms for main effects for GP, Area, Settle timing; 3=one parm for each Settle event"<<endl;
    *(ad_comm::global_datafile) >> recr_dist_area;
    echoinput<<recr_dist_area<<"  # future option for recr_dist_area: 1 is hardwired to do global SRR; 2 in future will do area-specific SRR"<<endl;
  recr_dist_area=1;  //hardwire for testing
  N_settle_assignments_rd=0;
  N_settle_assignments=1;  // default

  switch (recr_dist_method)
  {
    case 1:
      {
        *(ad_comm::global_datafile) >> N_settle_assignments_rd;
        *(ad_comm::global_datafile) >> recr_dist_inx;
        N_settle_assignments=N_settle_assignments_rd;
        break;
      }
    case 2:
      {
        *(ad_comm::global_datafile) >> N_settle_assignments;
        *(ad_comm::global_datafile) >> recr_dist_inx;
        break;
      }
    case 3:
      {
        *(ad_comm::global_datafile) >> N_settle_assignments;
        *(ad_comm::global_datafile) >> recr_dist_inx;
        break;
      }
    case 4:
      {
        *(ad_comm::global_datafile) >> N_settle_assignments;
        *(ad_comm::global_datafile) >> recr_dist_inx;
        break;
      }
  }
  echoinput<<N_settle_assignments<<" Number of settlement events: GP/area/month to read (>=0) "<<endl;
  if(recr_dist_method==1)
    {N_warn++;cout<<" EXIT - see warning "<<endl;   warning<<N_warn<<" "<<"fatal error:  recr_dist_method cannot be 1 in SS3.30 "<<endl; exit(1);}
  else if(N_settle_assignments==1 && recr_dist_method!=4)
    {N_warn++;  warning<<N_warn<<" "<<"This model has just one settlement event; recommend changing to recr_dist_method 4 which takes no recr_dist parameters"<<endl;}
  else if(recr_dist_method==2)
    {N_warn++;  warning<<N_warn<<" "<<"Note that recr_dist_method 3 is simpler and takes 1 parm for each settlement"<<endl;}
  echoinput<<recr_dist_inx<<"  # unused option "<<endl;
 END_CALCS

  int birthseas;  //  is this still needed??

  matrix settlement_pattern_rd(1,N_settle_assignments,1,4);   //  for each settlement event:  GPat, Month, area, age
  ivector settle_assignments_timing(1,N_settle_assignments);  //  stores the settle_timing index for each assignment
  matrix settle_timings_tempvec(1,N_settle_assignments,1,2)  //  temporary storage for real_month and age of each settlement_timing
                                                        //  dimensioned by assignments, but only uses N_settle_timings of these
 LOCAL_CALCS
   *(ad_comm::global_datafile) >> settlement_pattern_rd;
   echoinput<<" settlement pattern as read "<<endl<<"GPat  Month  Area Age"<<endl<<"*"<<settlement_pattern_rd<<"*"<<endl;
   echoinput<<"Now calculate the number of unique settle timings, which will dictate the number of recr_dist_timing parameters "<<endl;
      N_settle_timings=0;
      settle_timings_tempvec.initialize();
      if(N_settle_assignments==0)
      {
        N_settle_timings=1;
        settle_timings_tempvec(1,1)=1.0;
        settle_timings_tempvec(1,2)=0;
      }
      else
      {
        for (settle=1;settle<=N_settle_assignments;settle++)
        {
          real_month=settlement_pattern_rd(settle,2);
          int settle_age_here=settlement_pattern_rd(settle,4);
          if(N_settle_timings==0)
          {
            N_settle_timings++;
            settle_timings_tempvec(N_settle_timings,1)=real_month;
            settle_timings_tempvec(N_settle_timings,2)=settle_age_here;
            settle_assignments_timing(settle)=N_settle_timings;
          }
          else
          {
            k=0;
            for(j=1;j<=N_settle_timings;j++)
            {
              if(settle_timings_tempvec(j,1)==real_month && settle_timings_tempvec(j,2)==settle_age_here)  // found matching settle_time
              {
                settle_assignments_timing(settle)=j;
                k=1;
              }
            }
            if(k==0)
            {
              N_settle_timings++;
              settle_timings_tempvec(N_settle_timings,1)=real_month;
              settle_timings_tempvec(N_settle_timings,2)=settle_age_here;
              settle_assignments_timing(settle)=N_settle_timings;
            }
          }
        }
      }
    echoinput<<"N settle timings: "<<N_settle_timings<<endl<<" unique_settle_times: "<<endl<<settle_timings_tempvec<<endl;
    echoinput<<"settle events use these settle_times: "<<settle_assignments_timing<<endl;

    if(recr_dist_method==2)
      {echoinput<<" Need to read N_GP * Narea * N_settletimings="<<N_GP*pop*N_settle_timings<<"  recruitment distribution parameters "<<endl;}
    else if(recr_dist_method==3)
      {echoinput<<" Need to read N_settle_assignments="<<N_settle_assignments<<"  recruitment distribution parameters "<<endl;}

//  SS_Label_Info_4.2.3 #Set-up arrays and indexing for growth patterns, gender, settlements, platoons
 END_CALCS
   int g3i;
//  SPAWN-RECR:   define settlement timings
  ivector Settle_seas(1,N_settle_timings)  //  calculated season in which settlement occurs
  ivector Settle_seas_offset(1,N_settle_timings)  //  calculated number of seasons between spawning and the season in which settlement occurs
  vector  Settle_timing_seas(1,N_settle_timings)  //  calculated elapsed time (frac of year) between settlement and the begin of season in which it occurs
  vector  Settle_month(1,N_settle_timings)  //  month (real)in which settlement occurs
  ivector Settle_age(1,N_settle_timings)  //  calculated age at which settlement occurs, with age 0 being the year in which spawning occurs
  3iarray recr_dist_pattern(1,N_GP,1,N_settle_timings,0,pop);  //  has flag to indicate each settlement events

 LOCAL_CALCS
  Settle_seas_offset.initialize();
  Settle_timing_seas.initialize();
  Settle_age.initialize();
  Settle_seas.initialize();
  recr_dist_pattern.initialize();

  echoinput<<"Calculated assignments in which settlement occurs "<<endl<<"Settle_event / Month / Seas / Seas_from_spawn / time_from_seas_start / age_at_settle"<<endl;
  if(N_settle_assignments>0)
  {
    for (settle=1;settle<=N_settle_assignments;settle++)
    {
      gp=settlement_pattern_rd(settle,1); //  growth patterns
      p=settlement_pattern_rd(settle,3);  //  settlement area
      settle_time=settle_assignments_timing(settle);
      Settle_age(settle_time)=settlement_pattern_rd(settle,4);  //  settlement age as read
      recr_dist_pattern(gp,settle_time,p)=1;  //  indicates that settlement will occur here
      recr_dist_pattern(gp,settle_time,0)=1;  //  for growth updating
      Settle_month(settle_time)=settle_timings_tempvec(settle_time,1);
    }
    for (settle_time=1;settle_time<=N_settle_timings;settle_time++)
    {
      j=0;  //  temp value for calculated settlement age
      if(spawn_month>Settle_month(settle_time))
      {
        k=1; j++;  //  so sets season 1 as earliest possible settlement at age 1
      }
      else
      {
        k=spawn_seas;  //  earliest possible season for settlement at age 0
      }
      temp=azero_seas(k); //  annual elapsed time fraction at begin of this season
      Settle_timing_seas(settle_time)=(Settle_month(settle_time)-1.0)/sumseas;  //  fraction of year at settlement month

      while((temp+seasdur(k))<=Settle_timing_seas(settle_time))
      {
        temp+=seasdur(k);
        if(k==nseas)
        {k=1; j++;}
        else
        {k++;}
      }
      if(j!=Settle_age(settle_time))
      {
        N_warn++;  warning<<N_warn<<" "<<"settle_month is less than spawn_month, so logical age at settlement calculated to be: "<<j<<
        "  for settle_time "<<settle_time<<".  Does not match read value of "
        <<Settle_age(settle_time)<<" are you sure? "<<endl;
      }
      Settle_seas(settle_time)=k;
      Settle_seas_offset(settle_time)=Settle_seas(settle_time)-spawn_seas+j*nseas;  //  number of seasons between spawning and the season in which settlement occurs
      Settle_timing_seas(settle_time)-=temp;  //  timing from beginning of this season; needed for mortality calculation
      echoinput<<settle_time<<" / "<<Settle_month(settle_time);
      echoinput<<"  /  "<<Settle_seas(settle_time)<<" / "<<Settle_seas_offset(settle_time)<<" / "
      <<Settle_timing_seas(settle_time)<<"  / "<<Settle_age(settle_time)<<endl;
      if(Settle_seas_offset(settle_time)==0 && spawn_time_seas>0.0)
        {N_warn++; cout<<"see warning for fatal input issue"<<endl;  warning<<N_warn<<" "<<"Cannot have spawn_time_seas after beginning of a season and settlements in the same season"<<endl<<
          "put spawning at beginning of the season, or move settlements to next season"<<endl; exit(1);}
    }
  }
  else
  {
    recr_dist_pattern(1,1,1)=1;
    recr_dist_pattern(1,1,0)=1;
    Settle_month(1)=1.;
    Settle_timing_seas(1)=0.0;
    Settle_seas(1)=1;
    Settle_seas_offset(1)=0;
    Settle_age(1)=0;
  }

  gmorph = gender*N_GP*N_settle_timings*N_platoon;  //  total potential number of biological entities, some may not get used so see use_morph(g)
 END_CALCS

!!//  SS_Label_Info_4.2.1.1 #Define indexing vectors to keep track of characteristics of each morph
  ivector sx(1,gmorph) //  define sex for each growth morph
  ivector GP4(1,gmorph)   // index to GPat
  ivector GP(1,gmorph)    //  index for gender*GPat;  note that gp is nested inside gender
  ivector GP3(1,gmorph)   // index for main gender*GPat*settlement
  ivector GP2(1,gmorph)  // reverse pointer for platoon
  imatrix g_finder(1,N_GP,1,gender)  //  reverse pointer to middle "g" for each main morph (used only with Growth_Std
  ivector g_Start(1,N_GP*gender)  //  base "g" for this growth pattern
  ivector Bseas(1,gmorph)  // birth season
//  following two containers are used to track which morphs are being used
  ivector use_morph(1,gmorph)
  imatrix TG_use_morph(1,N_TG2,1,gmorph)
  imatrix ALK_range_g_lo(1,N_subseas*nseas*gmorph,0,nages)
  imatrix ALK_range_g_hi(1,N_subseas*nseas*gmorph,0,nages)

  vector azero_G(1,gmorph);  //  time since Jan 1 at beginning of settlement in which "g" was born
  3darray real_age(1,gmorph,1,nseas*N_subseas,0,nages);  // real age since settlement
  3darray keep_age(1,gmorph,1,nseas*N_subseas,0,nages);  // set to 0.0 if real_age<0.  this allows omitting virtual young fish to be excluded from expected values
  3darray calen_age(1,gmorph,1,nseas*N_subseas,0,nages);  // real age since Jan 1 of spawn year

  3darray lin_grow(1,gmorph,1,nseas*N_subseas,0,nages)  //  during linear phase has fraction of Size at Afix
  ivector settle_g(1,gmorph)   //  settlement pattern for each platoon
  int ALK_count;
  
 LOCAL_CALCS
  ALK_count=0;
  ALK_range_g_lo=1;
  ALK_range_g_hi=nlength;

  use_morph.initialize();
  TG_use_morph.initialize();
  keep_age.initialize();
  keep_age=1.0;

   for (gp=1;gp<=N_GP*gender;gp++)
   {
      g_Start(gp)=(gp-1)*N_settle_timings*N_platoon+int(N_platoon/2)+1-N_platoon;  // find the mid-morph being processed
   }

   g=0;
   g3i=0;
   echoinput<<endl<<"MORPH_INDEXING"<<endl;
   echoinput<<"g Sex GP Settlement Season Platoon Platoon% Sex*GP Sex*GP*settle_time Used(0/1) SettleTime_frac_yr"<<endl;
   for (gg=1;gg<=gender;gg++)
   for (gp=1;gp<=N_GP;gp++)
   for (settle=1;settle<=N_settle_timings;settle++)
   {
     g3i++;
      {
       for (gp2=1;gp2<=N_platoon;gp2++)
       {
         g++;
         GP3(g)=g3i;  // track counter for main morphs (gender x pattern x settlement)
         Bseas(g)=Settle_seas(settle);
         sx(g)=gg;
         GP(g)=gp+(gg-1)*N_GP;   // counter for pattern x gender so gp is nested inside gender
         GP2(g)=gp2; //   reverse pointer to platoon counter
         GP4(g)=gp;  //  counter for growth pattern
         settle_g(g)=settle;  //  to find the settlement timing for this platoon
         azero_G(g)=(Settle_month(settle)-1.0)/sumseas; //  settlement month converted to fraction of year; could be > one year
         for (p=1;p<=pop;p++)
         {
           if(recr_dist_pattern(gp,settle,p)==1)
           {
             use_morph(g)=1;
           }
         }
         if(use_morph(g)==1)
         {
           if( (N_platoon==1) || (N_platoon==3 && gp2==2) || (N_platoon==5 && gp2==3) ) g_finder(gp,gg)=g;  // finds g for a given GP and gender and last birstseason
         }
     echoinput<<g<<"   "<<sx(g)<<"  "<<GP4(g)<<"       "<<settle<<"       "<<Bseas(g)<<"       "
     <<GP2(g)<<"       "<<100.*platoon_distr(GP2(g))<<"       "<<GP(g)<<"        "<<GP3(g)<<
     "               "<<use_morph(g)<<"       "<<azero_G(g)<<endl;
       }
      }
   }
   echoinput<<"calen_age is elapsed years since beginning of year in which spawning occurred"<<endl;
   echoinput<<"real_age is elapsed years since settlement"<<endl;
   echoinput<<"g  s  subseas  ALK_idx settle_time age@settle age real_age calen_age"<<endl;
   calen_age.initialize();
   real_age.initialize();
   keep_age.initialize();
   for (g=1;g<=gmorph;g++)
   if(use_morph(g)==1)
   for (s=1;s<=nseas;s++)
   for (subseas=1;subseas<=N_subseas;subseas++)
   {
     ALK_idx=(s-1)*N_subseas+subseas;
     settle_time=settle_g(g);
//   real_age is real age since settlement and is used in growth calculations
//   calen_age is real age since the beginning of the year in which spawning occurred
     for(a=0;a<=nages;a++)
     {
       calen_age(g,ALK_idx,a)=r_ages(a)+azero_seas(s)+double(subseas-1)/double(N_subseas)*seasdur(s);
       if(a<Settle_age(settle_time))
       {
         real_age(g,ALK_idx,a)=0.;
         keep_age(g,ALK_idx,a)=0.;
       }
       else if (a==Settle_age(settle_time))
       {
         if(calen_age(g,ALK_idx,a)>=(azero_G(g)+Settle_age(settle_time)))
         {
           real_age(g,ALK_idx,a)=calen_age(g,ALK_idx,a)-azero_G(g)-Settle_age(settle_time);
           keep_age(g,ALK_idx,a)=1.;
         }
         else
         {
           real_age(g,ALK_idx,a)=0.;
           keep_age(g,ALK_idx,a)=0.;
         }
       }
       else
       {
         real_age(g,ALK_idx,a)=calen_age(g,ALK_idx,a)-azero_G(g)-Settle_age(settle_time);
         keep_age(g,ALK_idx,a)=1.;
       }
        if(a<4) echoinput<<g<<" "<<s<<" "<<subseas<<" "<<ALK_idx<<" "<<settle_time<<" "<<Settle_age(settle_time)
          <<" "<<a<<" "<<real_age(g,ALK_idx,a)<<" "<<calen_age(g,ALK_idx,a)<<endl;
     }
   }

    if(N_TG>0)
    {
      for (TG=1;TG<=N_TG;TG++)
      {
        for (g=1;g<=gmorph;g++)
        {
          if(TG_release(TG,6)>2) {N_warn++;  warning<<N_warn<<" "<<" gender for tag groups must be 0, 1 or 2 "<<endl;}
          if(use_morph(g)>0 && (TG_release(TG,6)==0 || TG_release(TG,6)==sx(g))) TG_use_morph(TG,g)=1;
        }
      }
    }
 END_CALCS

!!//  SS_Label_Info_4.3  #Define movement between areas
   int do_migration  //  number of explicit movements to define
   number migr_firstage
   matrix migr_start(1,nseas,1,N_GP)
 LOCAL_CALCS
   migr_firstage=0.0;
   do_migration=0;
   if (pop>1)
   {
      *(ad_comm::global_datafile) >> do_migration;
      echoinput<<do_migration<<" N_migration definitions to read"<<endl;
      if(do_migration>0)
      {
        *(ad_comm::global_datafile) >> migr_firstage;
        echoinput<<migr_firstage<<" migr_firstage"<<endl;
      }
    }
    else
    {
      echoinput<<" only 1 area, so no read of do_migration or migr_firstage "<<endl;
    }
 END_CALCS
   init_matrix move_def(1,do_migration,1,6)   // seas morph source dest minage maxage
//  ivector GP3(1,gmorph)   // index for main gender*GPat*settlement in that order
//  plan to revise such that movement is by GP3, not GP
   4iarray move_pattern(1,nseas,1,N_GP,1,pop,1,pop)
   int do_migr2
   ivector firstBseas(1,N_GP)

 LOCAL_CALCS
    move_pattern.initialize();
    do_migr2=0;
    if(do_migration>0)
    {
      echoinput<<" migration setup "<<endl<<move_def<<endl;
      for (k=1;k<=do_migration;k++)
      {
        s=move_def(k,1); gp=move_def(k,2); p=move_def(k,3); p2=move_def(k,4);
        move_pattern(s,gp,p,p2)=k;   // save index for definition of this pattern to find the right parameters
      }
      k=do_migration;
      for (s=1;s<=nseas;s++)
      for (gp=1;gp<=N_GP;gp++)
      for (p=1;p<=pop;p++)
      {
        if(move_pattern(s,gp,p,p)==0) {k++; move_pattern(s,gp,p,p)=k;} //  no explicit migration for staying in this area, so create implicit
      }

      do_migr2=k;  //  number of explicit plus implicit movement rates
      migr_start.initialize();
      // need to modify so it only does the calc for the first settlement used for each GP???
      for (gp=1;gp<=N_GP;gp++)
      {
        //  use firstBseas so that the start age of migration is calculated only for the first birthseason used for each GP
        firstBseas(gp)=0;
        for (g=1;g<=gmorph;g++)
        if(use_morph(g)>0)
        {
          if(GP4(g)==gp && firstBseas(gp)==0) firstBseas(gp)=Bseas(g);
        }
      }
      for (g=1;g<=gmorph;g++)
      if(use_morph(g)>0 && firstBseas(GP4(g))==Bseas(g))
      {
        for (s=1;s<=nseas;s++)
        for (subseas=1;subseas<=N_subseas;subseas++)
        {
          a=0;
          ALK_idx=(s-1)*N_subseas+subseas;
          while(real_age(g,ALK_idx,a)<migr_firstage) {a++;}
          migr_start(s,GP4(g))=a;
        }
      }
    }
 END_CALCS
   matrix move_def2(1,do_migr2,1,6)    //  movement definitions.  First Do_Migration of these are explicit; rest are implicit

 LOCAL_CALCS
    if(do_migration>0)
    {
      for (k=1;k<=do_migration;k++) {move_def2(k)=move_def(k);}
      k=do_migration;
      for (s=1;s<=nseas;s++)
      for (gp=1;gp<=N_GP;gp++)
      for (p=1;p<=pop;p++)
      {
        if(move_pattern(s,gp,p,p)>do_migration)
        {
          k++;
          move_def2(k,1)=s; move_def2(k,2)=gp; move_def2(k,3)=p; move_def2(k,4)=p; move_def2(k,5)=0; move_def2(k,6)=nages;
        }
      }
      echoinput<<"move_def "<<endl<<move_def2<<endl;
    }
 END_CALCS


!!//  SS_Label_Info_4.4 #Define the time blocks for time-varying parameters
  int N_Block_Designs                      // read N block designs
  ivector Nblk(1,1)
  imatrix Block_Design(1,1,1,1)
 LOCAL_CALCS
  *(ad_comm::global_datafile) >> N_Block_Designs;
  echoinput<<N_Block_Designs<<" N_Block_Designs"<<endl;
  if(N_Block_Designs>0)
  {
    Nblk.deallocate();
    Nblk.allocate(1,N_Block_Designs);
    *(ad_comm::global_datafile) >>Nblk(1,N_Block_Designs);
    echoinput<<Nblk<<" N_Blocks_per design"<<endl;

    ivector Nblk2;   //  temporary vector to create ragged array of dimensions for block matrix
    Nblk2.allocate(1,N_Block_Designs);
    Nblk2=Nblk + Nblk;
    Block_Design.deallocate();
    Block_Design.allocate(1,N_Block_Designs,1,Nblk2);
    for(j=1;j<=N_Block_Designs;j++)
    {
      *(ad_comm::global_datafile) >> Block_Design(j)(1,Nblk2(j));
      echoinput<<" block design #: "<<j<<"  read year pairs: "<<Block_Design(j)<<endl;
      a=-1;
      for (k=1;k<=Nblk(j);k++)
      {
        a+=2;
        if(Block_Design(j,a+1)<Block_Design(j,a)) {N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" "<<"Block:"<<j<<" "<<k<<" ends before it starts; fatal error"<<endl; exit(1);}
        if(Block_Design(j,a)<styr-1) {N_warn++;  warning<<N_warn<<" "<<"Block:"<<j<<" "<<k<<" starts before styr; resetting"<<endl; Block_Design(j,a)=styr;}
        if(Block_Design(j,a+1)<styr-1) {N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" "<<"Block:"<<j<<" "<<k<<" ends before styr; fatal error"<<endl; exit(1);}
        if(Block_Design(j,a)>retro_yr+1) {N_warn++;  warning<<N_warn<<" "<<"Block:"<<j<<" "<<k<<" starts after retroyr+1; should not estimate "<<endl;}
        if(Block_Design(j,a+1)>retro_yr+1) {N_warn++;  warning<<N_warn<<" "<<"Block:"<<j<<" "<<k<<" ends in: "<<Block_Design(j,a+1)<<" after retroyr+1:  "<<retro_yr+1<<endl;}
        if(Block_Design(j,a)>YrMax) {N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" "<<"Block:"<<j<<" "<<k<<" starts in: "<<Block_Design(j,a+1)<<" which is > YrMax:  "<<YrMax<<" fatal error"<<endl;exit(1);}
        if(Block_Design(j,a+1)>YrMax) {N_warn++;  warning<<N_warn<<" "<<"Block:"<<j<<" "<<k<<" ends in: "<<Block_Design(j,a+1)<<" reset to YrMax:  "<<YrMax<<endl;Block_Design(j,a+1)=YrMax;}
      }
    }
  }
  else
  {
    Nblk.allocate(1,1);
    Block_Design.allocate(1,1,1,1);
  }
 END_CALCS

   init_int parm_adjust_method
   !! echoinput<<parm_adjust_method<<"  timevarying parameter constraint method"<<endl;
   init_ivector autogen_timevary(1,5);  //  0 means to autogenerate time-vary parameters; 1 means to read; (2) read then autogen if parm min==-12345
                                       //  first element for biology, 2nd for SRR; 3rd for Q; 4th for tag; 5th for selex
   !! echoinput<<autogen_timevary<<"  timevarying parameter autogenerate (0) or read (1) for each parm type or (2) read then autogen if parm min==-12345"<<endl;
   ivector varparm_estimated(1,5)  // flag to show what types of variance parameters are estimated
   // (1) for growth
   // (2)  for recruitment sigmaR
   // (3)  for survey extraSD
!!  varparm_estimated.initialize();
   
!!//  SS_Label_Info_4.5 #Read setup and parameters for natmort, growth, biology, recruitment distribution, and migration
// read setup for natmort parameters:  LO, HI, INIT, PRIOR, PR_type, CV, PHASE, use_env, use_dev, dev_minyr, dev_maxyr, dev_phase, Block, Block_type
  int N_MGparm
  int N_natMparms
  int N_growparms
  int N_M_Grow_parms
  int recr_dist_parms
  int natM_type
  int natM_5_opt  //  option selection for Maunder approach
  imatrix MGparm_point(1,gender,1,N_GP)
  vector NatM_break(1,1);
  matrix Age_NatMort(1,1,1,1);
  number natM_amin;
  number natM_amax;
  number fracfemale;
  !!fracfemale=1.00;
  number fracfemale_mult;
  !!fracfemale_mult=1.0;  //  multiplier used in female SSB calc; gets changed to femfrac(1) if gender_rd==-1

// read natmort setup
 LOCAL_CALCS
   N_natMparms=0;
   natM_5_opt=0;
   MGparm_point.initialize();
//  0=1Parm; 1=segmented; 2=Lorenzen; 3=agespecific; 4=agespec with seas interpolate; 5=Maunder_M
  *(ad_comm::global_datafile) >> natM_type;
  echoinput<<natM_type<<" natM_type"<<endl;
  switch(natM_type)
  {
  	case 0:
  		{
  			N_natMparms=1;
  			break;
  		}
  	case 1:
  {
       *(ad_comm::global_datafile) >> N_natMparms;
       echoinput<<N_natMparms<<" N breakpoints "<<endl;
   	   NatM_break.deallocate();
       NatM_break.allocate(1,N_natMparms);
       *(ad_comm::global_datafile) >> NatM_break(1,N_natMparms);
       echoinput<<NatM_break<<" NatM_age_segment_breaks "<<endl;
  		 break;
  }
  	case 2:
  {
  			N_natMparms=1;
       *(ad_comm::global_datafile) >> natM_amin;
    echoinput<<natM_amin<<" natM_A for Lorenzen"<<endl;
  			break;
  }
  	case 3:
  		{
  			//  same as 4
  		}
  	case 4:
  {
    N_natMparms=0;
      	Age_NatMort.deallocate();
      	Age_NatMort.allocate(1,N_GP*gender,0,nages);
      	for(gp=1;gp<=N_GP*gender;gp++)
      	{
          *(ad_comm::global_datafile) >> Age_NatMort(gp)(0,nages);
      	}
        echoinput<<" Age_NatMort empirical input: "<<endl<<Age_NatMort<<endl;
  			break;
  		}
  	case 5:
  		{
  //  Maunder et al. age and sex specific M
  // A) read in an integer for the method to do maturity Maunder_MatType = 1,2,3
       *(ad_comm::global_datafile) >> natM_5_opt;
        echoinput<<" Maunder_NatMort option: "<<natM_5_opt<<endl;
  			N_natMparms=4;
        if(natM_5_opt==3) N_natMparms=6;
//            Maunder_Mjuv = natMparms(1,gp);
//            Maunder_lambda = natMparms(2,gp);
//            Maunder_lmat = natMparms(3,gp);
//            Maunder_Mmat = natMparms(4,gp);
//            if(natM_5_opt==3){	//use two parameters  mat50% and mat_slope.
//        		Maunder_L50  = natMparms(5,gp);
//		        Maunder_beta = natMparms(6,gp); 
  			break;
  		}
  }
 END_CALCS

// read growth setup
  init_int Grow_type  // 1=vonbert; 2=Richards; 3=age-specific K ascend;  4=age-specific K descend; 5=age-specific K; 6=read vector(not implemented); 8=growth cessation
  !!echoinput<<Grow_type<<" growth model "<<endl;
!!//  SS_Label_Info_4.5.1 #Create time constants for growth
  number AFIX;
  number AFIX2;
  number AFIX2_forCV;
  number AFIX_delta;
  number AFIX_plus;
  number Linf_decay;  //  decay factor to calculate mean L at maxage from Linf and the decaying abundance above maxage
                      //  forced equal to 0.20 in 3.24 (which also assumed linear, not VBK, growth)
  int do_ageK;
  ivector first_grow_age(1,gmorph);
  !! first_grow_age.initialize();
  !! k=0;
  !! do_ageK=0;
  !! if(Grow_type<=2 || Grow_type==8) {k=4;}  //  AFIX and AFIX2
  !! if (Grow_type>=3 && Grow_type<=5) {do_ageK=1; k=5;}  //  number of ages for age-specific K
  init_vector tempvec5(1,k)
  int Age_K_count;

 LOCAL_CALCS
  Age_K_count=0;
  if(k>0) echoinput<<tempvec5<<" # growth specifications: AFIX1 AFIX2 LINF_decay placeholder  age-specific_K_ages"<<endl;
  k1=0;
  AFIX=0.;
  AFIX2=999.;  // this value invokes setting Linf equal to the L2 parameter
  Linf_decay=0.0;  //  initialize
  if(Grow_type==1)
  {
    N_growparms=5;
    AFIX=tempvec5(1);
    AFIX2=tempvec5(2);
    Linf_decay=tempvec5(3);
    //  tempvec(4) is a placeholder
  }
  else if(Grow_type==2 || Grow_type==8)
  {
    N_growparms=6;
    AFIX=tempvec5(1);
    AFIX2=tempvec5(2);
    Linf_decay=tempvec5(3);
    if(Grow_type==8 && AFIX2 !=999)
      {
        N_warn++;  warning<<N_warn<<" "<<"AFIX2 set to 999 for grow_type==8 because only Linfinity allowed for growth cessation "<<endl;
        AFIX2=999.;
      }
    if(Grow_type==8 && AFIX !=0.0)
      {
        N_warn++;  warning<<N_warn<<" "<<"AFIX set to 0.0 for grow_type==8;  growth cessation "<<endl;
        AFIX2=0.0;
      }
    //  tempvec(4) is a placeholder
  }
  else if(do_ageK==1)
  {
    AFIX=tempvec5(1);
    AFIX2=tempvec5(2);
    Linf_decay=tempvec5(3);
    //  tempvec(4) is a placeholder
    Age_K_count=tempvec5(5);
    echoinput<<" read this number of ages for age-specific K "<<Age_K_count<<endl;
    N_growparms=5+Age_K_count;
  }
  else if(Grow_type==6)  //  not implemented
  {
    N_growparms=2;  // for the two CV parameters
    k1=N_GP*gender;  // for reading empirical length_at_age
  }
  
  echoinput<<" N_growparms  "<<N_growparms<<endl;
  AFIX2_forCV=AFIX2;
  if(AFIX2_forCV>nages) AFIX2_forCV=nages;

  AFIX_delta=AFIX2-AFIX;
  if(AFIX!=0.0)
  {AFIX_plus=AFIX;}
   else
   {AFIX_plus=1.0e-06;}
  N_M_Grow_parms=N_natMparms+N_growparms;
  lin_grow.initialize();

  echoinput<<"g a seas subseas ALK_idx real_age calen_age lin_grow first_grow_age"<<endl;
  for (g=1;g<=gmorph;g++)
  if(use_morph(g)>0)
  {
    for (a=0;a<=nages;a++)
    {
      for (s=1;s<=nseas;s++)
      for (subseas=1;subseas<=N_subseas;subseas++)
      {
        ALK_idx=(s-1)*N_subseas+subseas;
//        if(a==0 && s<Bseas(g))
//          {lin_grow(g,ALK_idx,a)=0.0;}  //  so fish are not yet born so will get zero length
        if(real_age(g,ALK_idx,a)<AFIX)
          {lin_grow(g,ALK_idx,a)=real_age(g,ALK_idx,a)/AFIX_plus;}  //  on linear portion of the growth
        else if(real_age(g,ALK_idx,a)==AFIX)
          {
            lin_grow(g,ALK_idx,a)=1.0;  //  at the transition from linear to VBK growth
          }
        else if (first_grow_age(g)==0)
          {
            lin_grow(g,ALK_idx,a)=-1.0;  //  flag for first age on growth curve beyond AFIX
            if(subseas==N_subseas) {first_grow_age(g)=a;}  //  so that lingrow will be -1 for rest of this season
          }
        else
          {lin_grow(g,ALK_idx,a)=-2.0;}  //  flag for being in growth curve

        if(a<4) echoinput<<g<<" "<<a<<" "<<s<<" "<<subseas<<" "<<ALK_idx<<" "<<real_age(g,ALK_idx,a)
          <<" "<<calen_age(g,ALK_idx,a)<<" "<<lin_grow(g,ALK_idx,a)<<" "<<first_grow_age(g)<<endl;
      }
    }
  }

 END_CALCS
  init_ivector Age_K_points(1,Age_K_count);  //  points at which age-specific multipliers to K will be applied
  !!if(Age_K_count>0) echoinput<<"Age-specific_K_points"<<Age_K_points<<endl;

  init_matrix Len_At_Age_rd(1,k1,0,nages)
  !!if(k1>0) echoinput<<"  Len_At_Age_rd"<<Len_At_Age_rd<<endl;

  init_number SD_add_to_LAA   // constant added to SD length-at-age (set to 0.1 for compatibility with SS2 V1.x
  !!echoinput<<SD_add_to_LAA<<"  SD_add_to_LAA"<<endl;
  init_int CV_depvar     //  select CV_growth pattern; 0 CV=f(LAA); 1 CV=F(A); 2 SD=F(LAA); 3 SD=F(A); 4 logSD=f(A)   SS2 V1.x ony had CV=F(LAA)
  !!echoinput<<CV_depvar<<"  CV_depvar"<<endl;
  int CV_depvar_a;
  int CV_depvar_b;
  int Grow_logN
 LOCAL_CALCS

   if(Age_K_count>1)
   {
    if(Grow_type==3)
    {
      for(j=2;j<=Age_K_count;j++)
      {
        if(Age_K_points(j)<=Age_K_points(j-1))
        {N_warn++;cout<<" EXIT - see warning "<<endl;   warning<<N_warn<<" "<<"EXIT:  age K points must be unique and ascending order "<<endl;exit(1);}
      }
    }
    else if(Grow_type==4 || Grow_type==5)
    {
      for(j=2;j<=Age_K_count;j++)
      {
        if(Age_K_points(j)>=Age_K_points(j-1))
        {N_warn++;cout<<" EXIT - see warning "<<endl;   warning<<N_warn<<" "<<"EXIT:  age K points must be unique and decending order "<<endl;exit(1);}
      }
    }
     
   }
   Grow_logN=0;
   switch (CV_depvar)
   {
     case 0:
     {
       CV_depvar_a=0;
       CV_depvar_b=0;
       break;
     }
     case 1:
     {
       CV_depvar_a=1;
       CV_depvar_b=0;
       break;
     }
     case 2:
     {
       CV_depvar_a=0;
       CV_depvar_b=1;
       break;
     }
     case 3:
     {
       CV_depvar_a=1;
       CV_depvar_b=1;
       break;
     }
     case 4:
     {
       CV_depvar_a=1;
       CV_depvar_b=1;
       Grow_logN=1;
       break;
     }
   }
 END_CALCS

!!//  SS_Label_Info_4.5.2 #Process biology
   init_int Maturity_Option       // 1=length logistic; 2=age logistic; 3=read age-maturity
                                  //  4=read age-fecundity;  6=read length-maturity
 LOCAL_CALCS
  echoinput<<Maturity_Option<<"  Maturity_Option"<<endl;
  if(Maturity_Option==3 || Maturity_Option==4)
    {k1=N_GP;}
  else
    {k1=0;}
  if(Maturity_Option==6)
    {k2=N_GP;}
  else
    {k2=0;}

  if(Maturity_Option==5)
  {
    echoinput<<" fecundity and weight at age to be read from file:  wtatage.ss"<<endl;
    if(WTage_rd==0)
      {
        N_warn++;cout<<" EXIT - see warning "<<endl;   warning<<N_warn<<" "<<"Must set WTage_rd to 1 to use wtatage.ss"<<endl;
        exit(1);
      }
  }
 END_CALCS
  init_matrix Age_Maturity(1,k1,0,nages) // for maturity option 3 or 4
  init_matrix Length_Maturity(1,k2,1,nlength)  //  for maturity option 6
  !!if(k1>0) echoinput<<"  read Age_Maturity for each GP"<<Age_Maturity<<endl;
  !!if(k2>0) echoinput<<"  read Length_Maturity for each GP"<<Length_Maturity<<endl;

  init_int First_Mature_Age     // first age with non-zero maturity
  !! echoinput<<First_Mature_Age<<"  First_Mature_Age"<<endl;

  init_int Fecund_Option
//   Value=1 means interpret the 2 egg parameters as linear eggs/kg on body weight (current SS default),
//   so eggs = wt * (a+b*wt), so value of a=1, b=0 causes eggs to be equiv to spawning biomass
//   Value=2 sets eggs=a*L^b   so cannot make equal to biomass
//   Value=3 sets eggs=a*W^b, so values of a=1, b=1 causes eggs to be equiv to spawning biomass
//   Value=4 sets eggs=a+b*L
//   Value=5 sets eggs=a+b*W
  !! echoinput<<Fecund_Option<<"  Fecundity option"<<endl;
  !! if(Fecund_Option>5) {N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" "<<"Illegal fecundity option:  "<<Fecund_Option<<endl; exit(1);}

  int Hermaphro_Option;
  int MGparm_Hermaphro;
  int Hermaphro_seas;
  int Hermaphro_firstage;
  number Hermaphro_seas_rd;
  number Hermaphro_maleSPB;
 LOCAL_CALCS
  Hermaphro_seas=0;
  Hermaphro_maleSPB=0.0;
  Hermaphro_firstage=0;
  MGparm_Hermaphro=0;
  
  *(ad_comm::global_datafile) >> Hermaphro_Option;
  echoinput<<Hermaphro_Option<<"  Hermaphro_Option: 0 means No; 1 for F to M; -1 for M to F"<<endl;
  if (Hermaphro_Option!=0)
  {
  	*(ad_comm::global_datafile) >> Hermaphro_seas_rd;  //  -1 for all seasons, or integer for particular season <=nseas
  		echoinput<<Hermaphro_seas_rd<<endl;
  	Hermaphro_seas=int(Hermaphro_seas_rd);
                                       // fractional part of Hermaphro_seas will be converted to the first age that switches
    if(temp>0) {
    Hermaphro_firstage=int((Hermaphro_seas_rd-Hermaphro_seas)*10.0+1.0e-6);}
    else {
    Hermaphro_firstage=int((abs(Hermaphro_seas_rd)-1)*10.0+1.0e-6);}
                                           //  so  2.3 will do switch in season 2 beginning with age 3.
    echoinput<<Hermaphro_seas<<"  Hermaphro_season (-1 means all seasons)"<<endl;
    echoinput<<Hermaphro_firstage<<"  Hermaphro_firstage (from decimal part of seas input"<<endl;
    *(ad_comm::global_datafile) >> Hermaphro_maleSPB;  // read as a fraction (0.0 to 1.0) of the male SSB added into the total SSB
    echoinput<<Hermaphro_maleSPB<<"  Hermaphro_maleSPB "<<endl;
  }
 END_CALCS
// if Hermaphro_Option=1, then read 3 parameters for switch from female to male by age
// if Hermaphro_Option=-1, then read 3 parameters for switch from male to female by age
// FUTURE if Hermaphro_Option=2, then read 3 parameters for switch from female to male by age for each GrowPattern
// FUTURE if Hermaphro_Option=3, then read 3 parameters for switch from female to male by length
// FUTURE if Hermaphro_Option=4, then read 3 parameters for switch from female to male by length for each GrowPattern

   init_int MGparm_def       //  offset approach (1=none, 2= M, G, CV_G as offset from female-GP1, 3=like SS2 V1.x)
   !! echoinput<<MGparm_def<<"  MGparm_def"<<endl;

  int do_once;
  int doit;

  int MGP_CGD
  int CGD_onoff;  //  switch for cohort growth dev

 LOCAL_CALCS
    if(parm_adjust_method<1 || parm_adjust_method>3)
    {
      N_warn++; cout<<" EXIT - see warning "<<endl;
       warning<<N_warn<<" "<<" illegal parm_adjust_method; must be 1 or 2 or 3 "<<endl;  exit(1);
    }

  ParCount=0;
  Parm_minmax.push_back (0);  // to start real info at index "1" to align with ParCount
  
//  retParCount=-1;   // for 3.24 -> 3.30 dome-shaped retention  replace with ivector N_retparm()

//  SS_Label_Info_4.5.3 #Set up indexing and parameter names for MG parameters
  for (gg=1;gg<=gender;gg++)
  {
    for (gp=1;gp<=N_GP;gp++)
    {
      MGparm_point(gg,gp)=ParCount+1;  //  starting pointer
      switch (natM_type)
      {
        case 0:
        {
          ParCount++;
          ParmLabel+="NatM_uniform_"+GenderLbl(gg)+GP_Lbl(gp);
          Parm_info+="val";
          Parm_minmax.push_back (3);
        	break;
        }
        case 1:
        {
      for (k=1;k<=N_natMparms;k++)
      {
        ParCount++;
        onenum="    ";
        sprintf(onenum, "%d", k);
            ParmLabel+="NatM_break_"+onenum+"_"+GenderLbl(gg)+GP_Lbl(gp);
        Parm_info+="val";
        Parm_minmax.push_back (3);
      }
        	break;
        }
        case 2:
        {
          ParCount++;
          ParmLabel+="NatM_Lorenzen_"+GenderLbl(gg)+GP_Lbl(gp);
          Parm_info+="val";
          Parm_minmax.push_back (3);
        	break;
        }
        case 5:  //  new age and maturity specific by Mark Maunder
        {
          ParCount++;
          ParmLabel+="NatM_juv_"+GenderLbl(gg)+GP_Lbl(gp);
          Parm_info+="val";
          Parm_minmax.push_back (3);
          ParCount++;
          ParmLabel+="NatM_power_"+GenderLbl(gg)+GP_Lbl(gp);
          Parm_info+="val";
          Parm_minmax.push_back (3);
          ParCount++;
          ParmLabel+="NatM_infl_"+GenderLbl(gg)+GP_Lbl(gp);
          Parm_info+="val";
          Parm_minmax.push_back (3);
          ParCount++;
          ParmLabel+="NatM_mature_"+GenderLbl(gg)+GP_Lbl(gp);
          Parm_info+="val";
          Parm_minmax.push_back (3);
          if(natM_5_opt==3)
          {
          ParCount++;
          ParmLabel+="NatM_L50_"+GenderLbl(gg)+GP_Lbl(gp);
          Parm_info+="val";
          Parm_minmax.push_back (3);
          ParCount++;
          ParmLabel+="NatM_slope_"+GenderLbl(gg)+GP_Lbl(gp);
          Parm_info+="val";
          Parm_minmax.push_back (3);
         }
        	break;
        }
        default:
        {
        	break;
        }
      }
      switch (Grow_type)
      {
        case 1:
        {
          ParmLabel+="L_at_Amin_"+GenderLbl(gg)+GP_Lbl(gp);
          Parm_info+="val";
          Parm_minmax.push_back (3);
          ParmLabel+="L_at_Amax_"+GenderLbl(gg)+GP_Lbl(gp);
          Parm_info+="val";
          Parm_minmax.push_back (2);
          ParmLabel+="VonBert_K_"+GenderLbl(gg)+GP_Lbl(gp);
          Parm_info+="val";
          Parm_minmax.push_back (1);
          ParCount+=3;
          break;
        }
        case 2:
        {
          ParmLabel+="L_at_Amin_"+GenderLbl(gg)+GP_Lbl(gp);
          ParmLabel+="L_at_Amax_"+GenderLbl(gg)+GP_Lbl(gp);
          ParmLabel+="VonBert_K_"+GenderLbl(gg)+GP_Lbl(gp);
          ParmLabel+="Richards_"+GenderLbl(gg)+GP_Lbl(gp);
          ParCount+=4;
          break;
        }
        case 3:
        {
          ParmLabel+="L_at_Amin_"+GenderLbl(gg)+GP_Lbl(gp);
          ParmLabel+="L_at_Amax_"+GenderLbl(gg)+GP_Lbl(gp);
          ParmLabel+="VonBert_K_young_"+GenderLbl(gg)+GP_Lbl(gp);
          ParCount+=3;
          for (a=1;a<=Age_K_count;a++)
          {
            ParmLabel+="Age_K_mult_"+GenderLbl(gg)+GP_Lbl(gp)+"_a_"+NumLbl0(Age_K_points(a)+1);
            ParCount++;
          }
          break;
        }
        case 4:
        {
          ParmLabel+="L_at_Amin_"+GenderLbl(gg)+GP_Lbl(gp);
          ParmLabel+="L_at_Amax_"+GenderLbl(gg)+GP_Lbl(gp);
          ParmLabel+="VonBert_K_old_"+GenderLbl(gg)+GP_Lbl(gp);
          ParCount+=3;
          for (a=1;a<=Age_K_count;a++)
          {
            ParmLabel+="Age_K_mult_"+GenderLbl(gg)+GP_Lbl(gp)+"_a_"+NumLbl0(Age_K_points(a)+1);
            ParCount++;
          }
          break;
        }
        case 5:
        {
          ParmLabel+="L_at_Amin_"+GenderLbl(gg)+GP_Lbl(gp);
          ParmLabel+="L_at_Amax_"+GenderLbl(gg)+GP_Lbl(gp);
          ParmLabel+="VonBert_K_old_"+GenderLbl(gg)+GP_Lbl(gp);
          ParCount+=3;
          for (a=1;a<=Age_K_count;a++)
          {
            ParmLabel+="Age_K_each_"+GenderLbl(gg)+GP_Lbl(gp)+"_a_"+NumLbl0(Age_K_points(a)+1);
            ParCount++;
          }
          break;
        }
        case 8:
        {
          ParmLabel+="L_at_Amin_"+GenderLbl(gg)+GP_Lbl(gp);
          ParmLabel+="Linf_"+GenderLbl(gg)+GP_Lbl(gp);
          ParmLabel+="VonBert_K_"+GenderLbl(gg)+GP_Lbl(gp);
          ParmLabel+="Cessation_"+GenderLbl(gg)+GP_Lbl(gp);
          ParCount+=4;
          break;
        }
      }
//  init_int CV_depvar     //  select CV_growth pattern; 0 CV=f(LAA); 1 CV=F(A); 2 SD=F(LAA); 3 SD=F(A); 4 logSD=f(A) 
      if(CV_depvar<=1)
      {ParmLabel+="CV_young_"+GenderLbl(gg)+GP_Lbl(gp);
      ParmLabel+="CV_old_"+GenderLbl(gg)+GP_Lbl(gp);}
      else if(CV_depvar<=3)
      {ParmLabel+="SD_young_"+GenderLbl(gg)+GP_Lbl(gp);
      ParmLabel+="SD_old_"+GenderLbl(gg)+GP_Lbl(gp);}
      else
      {ParmLabel+="lnSD_young_"+GenderLbl(gg)+GP_Lbl(gp);
      ParmLabel+="LnSD_old_"+GenderLbl(gg)+GP_Lbl(gp);}
        
      ParCount+=2;
      ParmLabel+="Wtlen_1_"+GenderLbl(gg)+GP_Lbl(gp);
      ParmLabel+="Wtlen_2_"+GenderLbl(gg)+GP_Lbl(gp);
      ParCount+=2;
      if(gg==1)  //  add parms for maturity and fecundity for females only
      {
        ParmLabel+="Mat50%_"+GenderLbl(1)+GP_Lbl(gp);
        ParmLabel+="Mat_slope_"+GenderLbl(1)+GP_Lbl(gp);
        ParCount+=2;
        if(Fecund_Option==1)
        {
          ParmLabel+="Eggs/kg_inter_"+GenderLbl(1)+GP_Lbl(gp);
          ParmLabel+="Eggs/kg_slope_wt_"+GenderLbl(1)+GP_Lbl(gp);
          ParCount+=2;
        }
        else if(Fecund_Option==2)
        {
          ParmLabel+="Eggs_scalar_"+GenderLbl(1)+GP_Lbl(gp);
          ParmLabel+="Eggs_exp_len_"+GenderLbl(1)+GP_Lbl(gp);
          ParCount+=2;
        }
        else if(Fecund_Option==3)
        {
          ParmLabel+="Eggs_scalar_"+GenderLbl(1)+GP_Lbl(gp);
          ParmLabel+="Eggs_exp_wt_"+GenderLbl(1)+GP_Lbl(gp);
          ParCount+=2;
        }
        else if(Fecund_Option==4)
        {
          ParmLabel+="Eggs_intercept_"+GenderLbl(1)+GP_Lbl(gp);
          ParmLabel+="Eggs_slope_len_"+GenderLbl(1)+GP_Lbl(gp);
          ParCount+=2;
        }
        else if(Fecund_Option==5)
        {
          ParmLabel+="Eggs_intercept_"+GenderLbl(1)+GP_Lbl(gp);
          ParmLabel+="Eggs_slope_Wt_"+GenderLbl(1)+GP_Lbl(gp);
          ParCount+=2;
        }
      }
    }
  }
  
  if(Hermaphro_Option==1 || Hermaphro_Option==-1)
  {
     MGparm_Hermaphro=ParCount+1;  // pointer to first hermaphroditism parameter
     ParmLabel+="Herm_Infl_age";
     ParmLabel+="Herm_stdev";
     ParmLabel+="Herm_asymptote";
     ParCount+=3;
  }
  recr_dist_parms = ParCount+1;  // pointer to first recruitment distribution  parameter
  switch (recr_dist_method)
  {
    case 2:  //  new method with main effects only
    {
      for (k=1;k<=N_GP;k++) {ParCount++; ParmLabel+="RecrDist_GP_"+NumLbl(k);}
      for (k=1;k<=pop;k++)  {ParCount++; ParmLabel+="RecrDist_Area_"+NumLbl(k);}
      for (k=1;k<=N_settle_timings;k++){ParCount++; ParmLabel+="RecrDist_month_"+NumLbl(Settle_month(k));}
      break;
    }
    case 3:  //  new method with parm for each settlement
    {
      for (s=1;s<=N_settle_assignments;s++)
      {ParCount++;
        gp=settlement_pattern_rd(s,1); //  growth patterns
        p=settlement_pattern_rd(s,3);  //  settlement area
        settle_time=settle_assignments_timing(s);
        ParmLabel+="RecrDist_GP_"+NumLbl(gp)+"_area_"+NumLbl(p)+"_month_"+NumLbl(Settle_month(settle_time));}
      break;
    }
    case 4:   //  no distribution of recruitments
    {
      break;
    }
  }

  MGP_CGD=ParCount+1;  // pointer to cohort growth deviation base parameter
  ParCount++;
  ParmLabel+="CohortGrowDev";

  if(do_migration>0)
  {
   for (k=1;k<=do_migration;k++)
     {
     s=move_def(k,1); gp=move_def(k,2); p=move_def(k,3); p2=move_def(k,4);
     ParCount++; ParmLabel+="MoveParm_A_seas_"+NumLbl(s)+GP_Lbl(gp)+"from_"+NumLbl(p)+"to_"+NumLbl(p2);
     ParCount++; ParmLabel+="MoveParm_B_seas_"+NumLbl(s)+GP_Lbl(gp)+"from_"+NumLbl(p)+"to_"+NumLbl(p2);
    }
  }

  if(Use_AgeKeyZero>0)
  {
    AgeKeyParm=ParCount+1;
    for (k=1;k<=7;k++)
    {
       ParCount++; ParmLabel+="AgeKeyParm"+NumLbl(k);
    }
  }

  catch_mult_pointer=-1;
  j=sum(need_catch_mult);  //  number of fleets needing a catch multiplier parameter
  if(j>0) {catch_mult_pointer=ParCount+1;}
  for(j=1;j<=Nfleet;j++)
  {
    if(need_catch_mult(j)==1)
    {
      ParCount++; ParmLabel+="Catch_Mult:_"+NumLbl(j)+"_"+fleetname(j);
    }
  }

  frac_female_pointer=ParCount+1;
  for(gp=1;gp<=N_GP;gp++)
  {
    ParCount++; ParmLabel+="FracFemale_GP_"+NumLbl(gp);
  }
  N_MGparm=ParCount;

 END_CALCS

  init_matrix MGparm_1(1,N_MGparm,1,14)   // matrix with natmort and growth parms controls
  ivector MGparm_offset(1,N_MGparm)

 LOCAL_CALCS
  //set base parm for cohort growth dev to permissable values
  if(MGparm_1(MGP_CGD,3)==0 || (MGparm_1(MGP_CGD,1)==MGparm_1(MGP_CGD,2)))
    {
      MGparm_1(MGP_CGD,1)=0.1;  //min
      MGparm_1(MGP_CGD,2)=10.;  //max
      MGparm_1(MGP_CGD,3)=1.;  //init
      MGparm_1(MGP_CGD,4)=1.;  //prior
      MGparm_1(MGP_CGD,5)=1.;  //  prior_sd
      MGparm_1(MGP_CGD,6)=0.;  //  prior type
      MGparm_1(MGP_CGD,7)=-1.;  // phase
    }

  echoinput<<" Biology base parameter setup "<<N_MGparm<<endl;
  for (i=1;i<=N_MGparm;i++)
  echoinput<<i<<" "<<MGparm_1(i)<<" "<<ParmLabel(ParCount-N_MGparm+i)<<endl;

//  find MGparms for which the male parameter value is set equal to the female value
//  only applies for MGparm_def==1 which is direct estimation (no offsets)
//  only for the natmort and growth parameters (not wtlen, fecundity, movement, recr distribution)
  MGparm_offset.initialize();
  if(MGparm_def==1 && gender==2)
  {
    gg=2;  // males
    for (gp=1;gp<=N_GP;gp++)
    {
      Ip=MGparm_point(gg,gp)-1;
        for (j=1;j<=N_M_Grow_parms;j++)
        {
          if(MGparm_1(Ip+j,3)==0.0 && MGparm_1(Ip+j,7)<0) MGparm_offset(Ip+j)=MGparm_point(1,gp)-1+j;  // save reference to female parm if male value is zero and not estimated
        }
    }
  }
 END_CALCS

  ivector mgp_type(1,N_MGparm)  //  contains category to parameter (1=natmort; 2=growth; 3=wtlen & fec; 4=recr_dist&femfrac; 5=movement; 6=ageerrorkey; 7=catchmult)
 LOCAL_CALCS
   gp=0;
   for(gg=1;gg<=gender;gg++)
   for(GPat=1;GPat<=N_GP;GPat++)
   {
     gp++;
     Ip=MGparm_point(gg,GPat);
     mgp_type(Ip,Ip+N_natMparms-1)=1; // natmort parms
     Ip+=N_natMparms;
     mgp_type(Ip,Ip+N_growparms-1)=2;  // growth parms
     
//  check on estimation of variance parameters for CV_young and CV_old
     for(int kk=Ip+N_growparms-2;kk<=Ip+N_growparms-1;kk++)
     {
       if(MGparm_1(kk,7)>0) varparm_estimated(1)=1;
       if(MGparm_1(kk,8)!=0 || MGparm_1(kk,9)!=0 || MGparm_1(kk,13)!=0)
        {N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" "<<"CV of growth parameters cannot be time-varying"<<endl; exit(1);
        }
     }
//     if(MGparm_1(Ip+N_growparms-2,7)>0) varparm_estimated(1)=1;  //  for CV_young
//     if(MGparm_1(Ip+N_growparms-1,7)>0) varparm_estimated(1)=1;  //  for CV_old

     Ip=Ip+N_growparms;
     mgp_type(Ip,Ip+1)=3;   // wtlen
     Ip+=2;
     if(gg==1) {mgp_type(Ip,Ip+3)=3;  Ip+=4;}  // maturity and fecundity
   }
   if(Hermaphro_Option!=0) {mgp_type(MGparm_Hermaphro,MGparm_Hermaphro+2)=3;}  //   herma parameters done with wtlen and fecundity
   if(recr_dist_method<4) mgp_type(Ip,MGP_CGD-1)=4;   // recruit apportionments
   mgp_type(MGP_CGD)=2;   // cohort growth dev
   if(do_migration>0)  mgp_type(MGP_CGD+1,N_MGparm)=5;  // note that it fills until end of MGparm list, but some get overwritten
   if(Use_AgeKeyZero>0) mgp_type(AgeKeyParm,N_MGparm)=6;
   if(catch_mult_pointer>0) mgp_type(catch_mult_pointer,N_MGparm)=7;
   for(f=frac_female_pointer; f<=frac_female_pointer+N_GP-1;f++) mgp_type(f)=4;
   echoinput<<"mgparm_type for each parm: 1=M; 2=growth; 3=wtlen,mat,fec,hermo; 4=recr&femfrac; 5=migr; 6=ageerror; 7=catchmult"<<endl<<mgp_type<<endl;
 END_CALCS

!!// SS_Label_Info_4... //  quantities used to track all time-varying parameters
  int timevary_cnt   //  cumulative count of timevarying parameters across MG, SRR, Q, Selex, Tag
                     //  it counts the number of times timevary_setup is created
                     //  by the function  "create_timevary"
                     //  and is pushed to the vector_vector  timevary_def
  int N_parm_dev     //  number of  all parms that use annual deviations

!!//  SS_Label_Info_4.5.4 #Set up time-varying parameters for MG parms
  int timevary_used;
  int timevary_parm_cnt_MG;
  int timevary_parm_start_MG;

  ivector MGparm_timevary(1,N_MGparm)  //  holds index in timevary_def used by this base parameter
  imatrix timevary_MG(styr-3,YrMax+1,0,7)  // goes to yrmax+1 to allow referencing in forecast, but only endyr+1 is checked
                                            // stores years to calc non-constant MG parms (1=natmort; 2=growth; 3=wtlen & fec; 4=recr_dist&femfrac; 5=movement; 6=ageerrorkey; 7=catchmult)
  ivector timevary_pass(styr-3,YrMax+1)    //  extracted column
  ivector MG_active(0,7)  // 0=all, 1=M, 2=growth 3=wtlen, 4=recr_dist&femfrac, 5=migration, 6=ageerror, 7=catchmult
  vector env_data_pass(1,2)  //  holds min-max year with env data  
  int  do_densitydependent;

//  timevary_setup(1)=baseparm type;
//  timevary_setup(2)=baseparm index;
//  timevary_setup(3)=first timevary parm
//  timevary_setup(4)=block or trend type
//  timevary_setup(5)=block pattern
//  timevary_setup(6)=env link type
//  timevary_setup(7)=env variable
//  timevary_setup(8)=dev vector used
//  timevary_setup(9)=dev link type
//  timevary_setup(10)=dev min year
//  timevary_setup(11)=dev maxyear
//  timevary_setup(12)=dev phase
//  timevary_setup(13)=all parm index of baseparm
//  timevary_setup(14)=continue_last dev
  
 LOCAL_CALCS
   do_densitydependent=0;
   timevary_cnt=0;
   N_parm_dev=0;
   timevary_parm_cnt=0;

//  push once so 0'th row is not used
   ivector timevary_setup(1,14);
   timevary_setup.initialize();
   timevary_def.push_back (timevary_setup(1,14));
   dvector tempvec(1,7);  //  temporary vector for a time-vary parameter  LO HI INIT PRIOR PR_type SD PHASE
   timevary_parm_rd.push_back (tempvec);

   echoinput<<"Now read env, block/trend, and dev adjustments to MGparms "<<endl;
   timevary_MG.initialize();    // stores years to calc non-constant MG parms (1=natmort; 2=growth; 3=wtlen & fec; 4=recr_dist; 5=movement)
   MG_active.initialize();
   CGD_onoff=0;

   timevary_parm_start_MG=0;
   timevary_parm_cnt_MG=0;
   timevary_used=0;
   MGparm_timevary.initialize();
   ivector block_design_null(1,1);
   block_design_null.initialize();

   for (j=1;j<=N_MGparm;j++)
   {
     k=mgp_type(j);
     timevary_pass=column(timevary_MG,k);  // year vector for this type of MGparm

     if(MGparm_1(j,13)==0 && MGparm_1(j,8)==0 && MGparm_1(j,9)==0)
     {
      //  no time-vary parameter effects
     }
     else
     {
       ivector timevary_setup(1,14);  //  temporary vector for timevary specs
       timevary_setup.initialize();
       timevary_parm_start_MG=1;  //  at least one MG parm is time varying
       timevary_used=1;
       echoinput<<endl<<" timevary for MG parameter: "<<j<<endl;
       timevary_cnt++;  //  count parameters with time-vary effect
       MGparm_timevary(j)=timevary_cnt;  //  base parameter will use this timevary specification
       timevary_setup(1)=1; //  indicates a MG parm
       timevary_setup(2)=j; //  index of base parm within that type of parameter
       timevary_setup(13)=j;  //  index of base parm relative to ParCount which is continuous across all types of parameters
       timevary_setup(3)=timevary_parm_cnt+1;  //  first parameter within total list of all timevary parms
       z=MGparm_1(j,13);    // specified block or trend definition

       k=int(abs(MGparm_1(j,8))/100);  //  find the env link code
       timevary_setup(6)=k;  //  link code for env
       if(MGparm_1(j,8)>0)  //  env variable used
       {
         timevary_setup(7)=int(abs(MGparm_1(j,8)))-k*100;
         k=timevary_setup(7);
//         for(y=styr-1;y<=YrMax;y++) env_data_pass(y)=env_data_RD(y,k);
         env_data_pass(1)=env_data_minyr(k);
         env_data_pass(2)=env_data_maxyr(k);
       }
       else  //  density-dependence
       {
         timevary_setup(7)=-int(abs(MGparm_1(j,8))-k*100);
         do_densitydependent=1;
         k=0; env_data_pass.initialize();
       }

       if(z>0)  //  doing blocks
       {
         if(z>N_Block_Designs)
          {N_warn++; cout<<"Fatal_input_error, see warning"<<endl;  warning<<N_warn<<" "<<"MG block request exceeds N_block patterns"<<endl;  exit(1);}
         create_timevary(MGparm_1(j),timevary_setup, timevary_pass, autogen_timevary(timevary_setup(1)), mgp_type(j), Block_Design(z), parm_adjust_method, env_data_pass, N_parm_dev,finish_starter);
       }
       else
       {
         create_timevary(MGparm_1(j),timevary_setup, timevary_pass, autogen_timevary(timevary_setup(1)), mgp_type(j), block_design_null, parm_adjust_method, env_data_pass, N_parm_dev,finish_starter);
       }
  /*
   where:
   MGparm_1(j):           vector with the base parameter which has some type of timevary characteristic
   timevary_setup:        vector which contains specs of all types of timevary  for this base parameter
                          will be pushed to timevary_def cumulative across all types of base parameters
   timevary_pass:        vector containing column(timevary_MG,mgp_type(j)), will be modified in create_timevary
   autogen_timevary:      switch to autogenerate or not
   mgp_type(j):           integer with type of MGparm being worked on; analogous to 2*fleet in the selectivity section
   Block_Design(z):       block design, if any, being used
   parm_adjust_method:    switch to determine if adjusted parameter will stay in bounds; used to create warnings in create_timevary
   env_data_RD:           matrix containing entire set of environmental data as read
   N_parm_dev:            integer that is incremented in create_timevary as dev vectors are created; cumulative across all types of parameters
  */
       timevary_def.push_back (timevary_setup(1,14));
       for(y=styr-3;y<=YrMax+1;y++) {timevary_MG(y,mgp_type(j))=timevary_pass(y);}  // year vector for this category of MGparm
       if(j==MGP_CGD) CGD_onoff=1;
       if(mgp_type(j)==6)  //  doing time-vary age-age' key;  can only use blocks
       	{
       		store_agekey_add=Nblk(z)+2;  //  additional storage space for block-based Age error keys
       	}
     }
   }
   if(timevary_used==1) autogen_timevary(1)=1;  //  indicate that some parameter is time-varying
   timevary_parm_cnt_MG=timevary_parm_cnt;

  //  SS_Label_Info_4.5.9 #Set up random deviations for MG parms
  //  NOTE:  the parms for the se of the devs are part of the MGparm2 list above, not the dev list below

  //  SS_Label_Info_4.5.95 #Populate time_bio_category array defining when biology changes
     k=YrMax+1;
     echoinput<<"Display timevary_MG flag"<<endl;
    for (y=styr+1;y<=YrMax;y++)
    {
      if(timevary_MG(y,2)>0 && y<k)  k=y;
    }
    if(k<YrMax+1)
    {
      for (y=k;y<=YrMax+1;y++)
      {
        timevary_MG(y,2)=1;
      }
    }
    for (y=styr-1;y<=YrMax;y++)
    {
      for (f=1;f<=7;f++)
      {
        if(timevary_MG(y,f)>0)
        {
          MG_active(f)=1;
          timevary_MG(y,0)=1;  // tracks active status for all MG types
        }
      }
      echoinput<<y<<" timevary_MG: "<<timevary_MG(y)<<endl;
    }
 END_CALCS

!!//  SS_Label_Info_4.5.7 #Set up seasonal effects for MG parms
  init_ivector MGparm_seas_effects(1,10)  // femwtlen1, femwtlen2, mat1, mat2, fec1 fec2 Malewtlen1, malewtlen2 L1 K
  int MGparm_doseas
  int N_MGparm_seas                            // number of MGparms that use seasonal effects
 LOCAL_CALCS
  adstring_array MGseasLbl;
  MGseasLbl+="F-WL1"+CRLF(1);
  MGseasLbl+="F-WL2"+CRLF(1);
  MGseasLbl+="F-Mat1"+CRLF(1);
  MGseasLbl+="F-Mat1"+CRLF(1);
  MGseasLbl+="F-Fec1"+CRLF(1);
  MGseasLbl+="F-Fec1"+CRLF(1);
  MGseasLbl+="M-WL1"+CRLF(1);
  MGseasLbl+="M-WL2"+CRLF(1);
  MGseasLbl+="L1"+CRLF(1);
  MGseasLbl+="VBK"+CRLF(1);
  MGparm_doseas=sum(MGparm_seas_effects);
  N_MGparm_seas=0;  // counter for assigned parms
  if(MGparm_doseas>0)
  {
    for (j=1;j<=10;j++)
    {
      if(MGparm_seas_effects(j)>0)
      {
        MGparm_seas_effects(j)=N_MGparm+timevary_parm_cnt_MG+N_MGparm_seas;  // store base parameter count
        for (s=1;s<=nseas;s++)
        {
          N_MGparm_seas++; ParCount++; ParmLabel+=MGseasLbl(j)+"_seas_"+NumLbl(s);
        }
      }
    }
   echoinput<<MGparm_seas_effects<<" MGparm_seas_effects"<<endl;
  }
 END_CALCS
  init_matrix MGparm_seas_1(1,N_MGparm_seas,1,7)  // read matrix that defines the seasonal parms
  !!if(N_MGparm_seas>0) echoinput<<" MGparm_seas"<<endl<<MGparm_seas_1<<endl;

  !!//  SS_Label_Info_4.5.9 #Create vectors (e.g. MGparm_PH) to be used to define the actual estimated parameter array
  int N_MGparm2
  !! N_MGparm2=N_MGparm+timevary_parm_cnt_MG+N_MGparm_seas;
  vector MGparm_LO(1,N_MGparm2)
  vector MGparm_HI(1,N_MGparm2)
  vector MGparm_RD(1,N_MGparm2)
  vector MGparm_PR(1,N_MGparm2)
  ivector MGparm_PRtype(1,N_MGparm2)
  vector MGparm_CV(1,N_MGparm2)
  ivector MGparm_PH(1,N_MGparm2)

 LOCAL_CALCS
   for (f=1;f<=N_MGparm;f++)  //  loop mgparm and map setup to _LO , _HI etc.
   {
    MGparm_LO(f)=MGparm_1(f,1);
    MGparm_HI(f)=MGparm_1(f,2);
    MGparm_RD(f)=MGparm_1(f,3);
    MGparm_PR(f)=MGparm_1(f,4);
    MGparm_CV(f)=MGparm_1(f,5);
    MGparm_PRtype(f)=MGparm_1(f,6);
    MGparm_PH(f)=MGparm_1(f,7);
    if(MGparm_PH(f)>0)
    {MG_active(mgp_type(f))=1;}
   }
   if(natM_type==2 && MG_active(2)>0) MG_active(1)=1;  // lorenzen M depends on growth

   j=N_MGparm;
   if(timevary_parm_cnt_MG>0)
   for (f=timevary_parm_start_MG;f<=timevary_parm_cnt_MG;f++)
   {
    j++;
    MGparm_LO(j)=timevary_parm_rd[f](1);
    MGparm_HI(j)=timevary_parm_rd[f](2);
    MGparm_RD(j)=timevary_parm_rd[f](3);
    MGparm_PR(j)=timevary_parm_rd[f](4);
    MGparm_CV(j)=timevary_parm_rd[f](5);
    MGparm_PRtype(j)=timevary_parm_rd[f](6);
    MGparm_PH(j)=timevary_parm_rd[f](7);
   }

   if(N_MGparm_seas>0)
   for (f=1;f<=N_MGparm_seas;f++)
   {
    j++;
    MGparm_LO(j)=MGparm_seas_1(f,1);
    MGparm_HI(j)=MGparm_seas_1(f,2);
    MGparm_RD(j)=MGparm_seas_1(f,3);
    MGparm_PR(j)=MGparm_seas_1(f,4);
    MGparm_CV(j)=MGparm_seas_1(f,5);
    MGparm_PRtype(j)=MGparm_seas_1(f,6);
    MGparm_PH(j)=MGparm_seas_1(f,7);
   }
   MG_active(0)=sum(MG_active(1,7));
   echoinput<<"MG_active "<<MG_active<<endl;

 END_CALCS

  !!//  SS_Label_Info_4.6 #Read setup for Spawner-Recruitment parameters
  //  SPAWN-RECR: read setup for SR parameters:  LO, HI, INIT, PRIOR, PRtype, CV, PHASE
  init_int SR_fxn
  !!echoinput<<SR_fxn<<" #_SR_function: 1=NA; 2=Ricker(2 parms); 3=BevHolt(2); 4=SCAA(2); 5=Hockey(3); 6=B-H_flattop(2); 7=Survival(3); 8=Shepherd(3); 9=Ricker_Power(3) "<<endl;
  init_int init_equ_steepness;
  !!echoinput<<init_equ_steepness<<"  # 0/1 to use steepness in initial equ recruitment calculation"<<endl;
  init_int sigmaR_dendep;
  !! echoinput<<sigmaR_dendep<<"  #  future feature:  0/1 to make realized sigmaR a function of SR curvature"<<endl;
  ivector N_SRparm(1,10)
  !!N_SRparm.fill("{0,2,2,2,3,2,3,3,3,3}");
  int N_SRparm2
  int N_SRparm3  //  with timevary links included
  !!N_SRparm2=N_SRparm(SR_fxn)+3;
  init_matrix SR_parm_1(1,N_SRparm2,1,14)
  !!echoinput<<" SR parms "<<endl<<SR_parm_1<<endl;
   int SR_env_link
//  !!echoinput<<SR_env_link<<" SR_env_link "<<endl;
    int SR_env_target_RD   // 0=none; 1=devs; 2=R0; 3=steepness
//  !!echoinput<<SR_env_target_RD<<" SR_env_target_RD "<<endl;
  int SR_env_target
  int SR_autocorr;  // will be calculated later

  int timevary_parm_start_SR;
  int firstSRparm;
  int timevary_parm_cnt_SR;
  ivector timevary_SRparm(styr-3,YrMax+1);
  ivector SR_parm_timevary(1,N_SRparm2);

 LOCAL_CALCS
//  SS_Label_Info_4.6.1 #Create S-R parameter labels
   firstSRparm=ParCount;
   timevary_parm_cnt_SR=0;
   timevary_parm_start_SR=0;
   timevary_SRparm.initialize();
   SR_parm_timevary.initialize();
   SR_env_link=0;
   SR_env_target=0;
//#_SR_function: 1=null; 2=Ricker; 3=std_B-H; 4=SCAA; 5=Hockey; 6=B-H_flattop; 7=Survival_3Parm "<<endl;
  ParmLabel+="SR_LN(R0)";
  switch(SR_fxn)
  {
    case 1: // previous placement for B-H constrained
    {
      N_warn++; cout<<"Critical error:  see warning"<<endl;  warning<<N_warn<<" "<<"B-H constrained curve is now Spawn-Recr option #6"<<endl; exit(1);
      break;
    }
    case 2:  // Ricker
    {
      ParmLabel+="SR_Ricker_beta";
      break;
    }
    case 3:  // Bev-Holt
    {
      ParmLabel+="SR_BH_steep";
      break;
    }
    case 4:  // SCAA
    {
      ParmLabel+="SR_SCAA_null";
      break;
    }
    case 5:  // Hockey
    {
      ParmLabel+="SR_hockey_infl";
      ParmLabel+="SR_hockey_min_R";
      break;
    }
    case 6:  // Bev-Holt flattop
    {
      ParmLabel+="SR_BH_flat_steep";
      break;
    }
    case 7:  // survival
    {
      ParmLabel+="SR_surv_zfrac";
      ParmLabel+="SR_surv_Beta";
      break;
    }
    case 8:  // Shepherd
    {
      ParmLabel+="SR_steepness";
      ParmLabel+="SR_Shepherd_c";
      break;
    }
    case 9:  //  Ricker Power parameters
    {
      ParmLabel+="SR_RkrPower_steep";
      ParmLabel+="SR_RkrPower_gamma";
      break;
    }
  }
  ParmLabel+="SR_sigmaR";
  ParmLabel+="SR_regime";
  ParmLabel+="SR_autocorr";
  ParCount+=N_SRparm2;

  if(SR_parm_1(N_SRparm2-2,7) > 0) varparm_estimated(2)=1;  //  sigmaR is estimated so need sd_offset=1

  if(SR_parm_1(N_SRparm2,3)!=0.0 || SR_parm_1(N_SRparm2,7)>0)
    {SR_autocorr=1;}
  else
    {SR_autocorr=0;}
  // flag for recruitment autocorrelation
  echoinput<<" Do recruitment_autocorr: "<<SR_autocorr<<endl;
   timevary_used=0;
   for (j=1;j<=N_SRparm(SR_fxn)+2;j++)
   if(j!=N_SRparm(SR_fxn)+1)  //  because sigmaR and autocorr cannot be time-varying
   {
     if(SR_parm_1(j,13)==0 && SR_parm_1(j,8)==0 && SR_parm_1(j,9)==0)
     {
      //  no time-vary parameter effects
     }
     else  //  set up a timevary parameter definition
     {
       ivector timevary_setup(1,14);  //  temporary vector for timevary specs
       timevary_setup.initialize();
       if(timevary_parm_start_SR==0) timevary_parm_start_SR=timevary_parm_cnt+1;
       echoinput<<" timevary for SR parm: "<<j<<endl;
       timevary_used=1;
       timevary_cnt++;  //  count parameters with time-vary effect
       SR_parm_timevary(j)=timevary_cnt;  //  base SR parameter will use this timevary specification
       timevary_setup(1)=2; //  indicates a SR parm
       if(autogen_timevary(2)==0)
        {echoinput<<" timevary SR parms will be autogenerated "<<endl;}
        else
        {echoinput<<" timevary SR parms will be read, not autogenerated "<<endl;}
       timevary_setup(2)=j; //  index of base parm within that type of parameter
       timevary_setup(13)=firstSRparm+j;  //  index of base parm relative to ParCount which is continuous across all types of parameters
       timevary_setup(3)=timevary_parm_cnt+1;  //  first parameter within total list of all timevary parms
       timevary_pass=1;  // placeholder; not used for SR parms
//  set up env link info
       echoinput<<" check for env "<<SR_parm_1(j,8)<<endl;
       k=int(abs(SR_parm_1(j,8))/100);  //  find the env link code
       timevary_setup(6)=k;  //  link code for env
       if(SR_parm_1(j,8)>0)  //  env variable used
       {
         timevary_setup(7)=int(abs(SR_parm_1(j,8)))-k*100;
         k=timevary_setup(7);
//         for(y=styr-1;y<=YrMax;y++) env_data_pass(y)=env_data_RD(y,k);
         env_data_pass(1)=env_data_minyr(k);
         env_data_pass(2)=env_data_maxyr(k);
       }
       else  //  density-dependence
       {
         timevary_setup(7)=-int(abs(SR_parm_1(j,8))-k*100);
         do_densitydependent=1;
         k=0; env_data_pass.initialize();
       }

       if(SR_parm_1(j,13)>0)  //  doing blocks
       {
         if(SR_parm_1(j,13)>N_Block_Designs)
          {N_warn++; cout<<"Fatal_input_error, see warning"<<endl;  warning<<N_warn<<" "<<"SR block request exceeds N_block patterns"<<endl;  exit(1);}
         create_timevary(SR_parm_1(j),timevary_setup, timevary_pass, autogen_timevary(timevary_setup(1)), f, Block_Design(SR_parm_1(j,13)), parm_adjust_method, env_data_pass, N_parm_dev,finish_starter);
       }
       else
       {
         create_timevary(SR_parm_1(j),timevary_setup, timevary_pass, autogen_timevary(timevary_setup(1)), f, block_design_null, parm_adjust_method, env_data_pass, N_parm_dev,finish_starter);
       }
  /*
   where:
   SR_parm_1(j):           vector with the base parameter which has some type of timevary characteristic
   timevary_setup:        vector which contains specs of all types of timevary  for this base parameter
                          will be pushed to timevary_def cumulative across all types of base parameters
   timevary_pass:        vector containing column(timevary_MG,mgp_type(j)), will be modified in create_timevary
   autogen_timevary:      switch to autogenerate or not
   block_design(z):       block design, if any, being used
   parm_adjust_method:    switch to determine if adjusted parameter will stay in bounds; used to create warnings in create_timevary
   env_data_RD:           matrix containing entire set of environmental data as read
   N_parm_dev:            integer that is incremented in create_timevary as dev vectors are created; cumulative across all types of parameters
  */
       timevary_def.push_back (timevary_setup(1,14));
       for(y=styr-3;y<=YrMax+1;y++) {timevary_SRparm(y)=timevary_pass(y);}  // year vector for this category og MGparm
     }
   }
   N_SRparm3=N_SRparm2;
   if(timevary_parm_start_SR>0)
   {
     timevary_parm_cnt_SR=timevary_parm_cnt;
     if(timevary_used==1) autogen_timevary(2)=1;  //  indicate that some parameter is time-varying
     N_SRparm3+=(timevary_parm_cnt_SR-timevary_parm_start_SR+1);
     echoinput<<" SR timevary_parm_cnt start and end "<<timevary_parm_start_SR<<" "<<timevary_parm_cnt_SR<<endl;
     echoinput<<"link to timevary parms:  "<<SR_parm_timevary<<endl;
   }
   echoinput<<"SR_Npar and N_SRparm2 and N_SRparm3:  "<<N_SRparm(SR_fxn)<<" "<<N_SRparm2<<" "<<N_SRparm3<<endl;
 END_CALCS

  vector SR_parm_LO(1,N_SRparm3)
  vector SR_parm_HI(1,N_SRparm3)
  vector SR_parm_RD(1,N_SRparm3)
  vector SR_parm_PR(1,N_SRparm3)
  ivector SR_parm_PRtype(1,N_SRparm3)
  vector SR_parm_CV(1,N_SRparm3)
  ivector SR_parm_PH(1,N_SRparm3)

 LOCAL_CALCS
 		for(i=1;i<=N_SRparm2;i++)
 		{
      SR_parm_LO(i)=SR_parm_1(i,1);
      SR_parm_HI(i)=SR_parm_1(i,2);
      SR_parm_RD(i)=SR_parm_1(i,3);
      SR_parm_PR(i)=SR_parm_1(i,4);
      SR_parm_CV(i)=SR_parm_1(i,5);
      SR_parm_PRtype(i)=SR_parm_1(i,6);
      SR_parm_PH(i)=SR_parm_1(i,7);
    }
    if(timevary_parm_start_SR>0)
    {
      j=N_SRparm2;
    for (f=timevary_parm_start_SR;f<=timevary_parm_cnt_SR;f++)
     {
      j++;
      echoinput<<f<<" "<<j<<" "<<timevary_parm_rd[f]<<endl;
      SR_parm_LO(j)=timevary_parm_rd[f](1);
      SR_parm_HI(j)=timevary_parm_rd[f](2);
      SR_parm_RD(j)=timevary_parm_rd[f](3);
      SR_parm_PR(j)=timevary_parm_rd[f](4);
      SR_parm_PRtype(j)=timevary_parm_rd[f](6);
      SR_parm_CV(j)=timevary_parm_rd[f](5);
      SR_parm_PH(j)=timevary_parm_rd[f](7);
     }
 	  }
 	echoinput<<"SR_parm_RD: "<<SR_parm_RD<<endl;
 END_CALCS

  init_int do_recdev  //  0=none; 1=devvector; 2=simple deviations; 3=dev from R0
  !!echoinput<<do_recdev<<" do_recdev"<<endl;
  init_int recdev_start;
  !!echoinput<<recdev_start<<" recdev_start"<<endl;
  init_int recdev_end;
  !!echoinput<<recdev_end<<" recdev_end"<<endl;
  init_int recdev_PH_rd;
  !!echoinput<<recdev_PH_rd<<" recdev_PH"<<endl;
  int recdev_PH;
  !! recdev_PH=recdev_PH_rd;
  init_int recdev_adv
  !!echoinput<<recdev_adv<<" recdev_adv"<<endl;

  init_vector recdev_options_rd(1,13*recdev_adv)
  vector recdev_options(1,13)
  int recdev_early_start_rd
  int recdev_early_start
  int recdev_early_end
  int recdev_first
  int recdev_early_PH_rd
  int Fcast_recr_PH_rd
  int recdev_early_PH
  int Fcast_recr_PH
  int Fcast_recr_PH2
  number Fcast_recr_lambda
  vector recdev_adj(1,5)
  int recdev_cycle
  int recdev_do_early
  int recdev_read
  number recdev_LO;
  number recdev_HI;
  ivector recdev_doit(styr-nages,YrMax)
  vector biasadj(styr-nages,YrMax)  // biasadj as used; depends on whether a recdev is estimated or not
  vector biasadj_full(styr-nages,YrMax)  //  full time series of biasadj values, only used in defined conditions

 LOCAL_CALCS
//  SS_Label_Info_4.6.2 #Setup advanced recruitment options
  recdev_doit=0;
  if(recdev_adv>0)
  {
    recdev_options(1,13)=recdev_options_rd(1,13);
    recdev_early_start_rd=recdev_options(1);
    recdev_early_PH_rd=recdev_options(2);
    Fcast_recr_PH_rd=recdev_options(3);
    Fcast_recr_lambda=recdev_options(4);
    recdev_adj(1)=recdev_options(5);
    recdev_adj(2)=recdev_options(6);
    recdev_adj(3)=recdev_options(7);
    recdev_adj(4)=recdev_options(8);
    if(recdev_adj(4)>endyr+1 && do_recdev>0)
      {N_warn++;  warning<<N_warn<<" "<<"bias adjustment ramp extends into forecast; biasadj set to 0.0 internally for forecast years"<<endl;}
    recdev_adj(5)=recdev_options(9);  // maxbias adj

    recdev_cycle=recdev_options(10);
    recdev_LO=recdev_options(11);
    recdev_HI=recdev_options(12);
    recdev_read=recdev_options(13);
  }
  else
  {
    recdev_early_start_rd=0;   // 0 means no early
    recdev_early_end=-1;
    recdev_early_PH_rd=-4;
    recdev_options(2)=recdev_early_PH_rd;
    Fcast_recr_PH_rd=0;  // so will be reset to maxphase+1
    recdev_options(3)=Fcast_recr_PH_rd;
    Fcast_recr_lambda=1.;
    recdev_adj(1)=double(styr)-1000.;
    recdev_adj(2)=styr-nages;
    recdev_adj(3)=recdev_end;
    recdev_adj(4)=double(endyr)+1.;
    recdev_adj(5)=1.0;
    recdev_cycle=0;
    recdev_LO=-5;
    recdev_HI=5;
    recdev_read=0;
  }

  recdev_early_start=recdev_early_start_rd;
  
  if(do_recdev==0)
    {
      recdev_PH_rd=-3;
      recdev_early_PH_rd=-4;
      Fcast_recr_PH_rd=-4;
    }
  if(recdev_adv>0)
  {echoinput<<"#_start of advanced SR options"<<endl;}
  else
  {echoinput<<"# advanced options not read;  defaults displayed below"<<endl;}

    echoinput<<recdev_early_start_rd<<" #_recdev_early_start (0=none; neg value makes relative to recdev_start)"<<endl;
    echoinput<<recdev_early_PH_rd<<" #_recdev_early_phase"<<endl;
    echoinput<<Fcast_recr_PH_rd<<" #_forecast_recruitment phase (incl. late recr) (0 value resets to maxphase+1)"<<endl;
    echoinput<<Fcast_recr_lambda<<" #_lambda for Fcast_recr_like occurring before endyr+1"<<endl;
    if(Fcast_Loop_Control(3)==3 && Fcast_recr_PH_rd>=0)
    	{N_warn++; warning<<N_warn<<" mean recruitment for forecast is incompatible with pos. phase for forecast rec_devs; set phase to neg. unless using late rec_devs"<<endl;}
    if(Do_Impl_Error>0 && Fcast_recr_PH_rd<0)
    	{N_warn++; warning<<N_warn<<" Implementation error incompatible with neg. phase for forecast rec_devs; SS will run without active impl error"<<endl;}
    echoinput<<recdev_adj(1)<<" #_last_early_yr_nobias_adj_in_MPD"<<endl;
    echoinput<<recdev_adj(2)<<" #_first_yr_fullbias_adj_in_MPD"<<endl;
    echoinput<<recdev_adj(3)<<" #_last_yr_fullbias_adj_in_MPD"<<endl;
    echoinput<<recdev_adj(4)<<" #_first_recent_yr_nobias_adj_in_MPD"<<endl;
    echoinput<<recdev_adj(5)<<" #_max_bias_adj_in_MPD"<<endl;
    echoinput<<" #_NOTE: biasadjustment forced to 0.0 after year recdev_end"<<endl;
    echoinput<<recdev_cycle<<" # period of cycle in recruitment "<<endl;
    echoinput<<recdev_LO<<" #min rec_dev"<<endl;
    echoinput<<recdev_HI<<" #max rec_dev"<<endl;
    echoinput<<recdev_read<<" #_read_recdevs"<<endl;
    echoinput<<"#_end of advanced SR options"<<endl;


//  SS_Label_Info_4.6.3 #Create parm labels for recruitment cycle parameters
  if(recdev_cycle>0)
  {
    for (y=1;y<=recdev_cycle;y++)
    {
      ParCount++;
      sprintf(onenum, "%d", y);
      ParmLabel+="RecrDev_Cycle_"+onenum+CRLF(1);
    }
  }

//  SS_Label_Info_4.6.4 #Setup recruitment deviations and create parm labels for each year
  if(recdev_end>retro_yr) recdev_end=retro_yr;
  if(recdev_start<(styr-nages)) {N_warn++;  warning<<N_warn<<" "<<" recdev_start: "<<recdev_start<<" <styr-nages: "<<styr-nages<<" reset "<<endl; recdev_start=styr-nages; }
  recdev_first=recdev_start;   // stores first recdev, whether from the early period or the standard dev period

  if(recdev_early_start>=recdev_start)
  {
    N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" "<<"Cannot set recdev_early_start: "<<recdev_early_start<<" after main recdev start: "<<recdev_start<<endl;
    exit(1);
  }
  else if(recdev_early_start==0)  // do not do early rec devs
  {
    recdev_do_early=0;
    recdev_early_end=-1;
    if(recdev_early_PH_rd>0) recdev_early_PH_rd=-recdev_early_PH_rd;
  }
  else
  {
    if(recdev_early_start<0) recdev_early_start+=recdev_start;  // do relative to start of recdevs
    recdev_do_early=1;
    if(recdev_early_start<(styr-nages))
      {recdev_early_start=styr-nages; N_warn++;  warning<<N_warn<<" "<<" adjusting recdev_early to: "<<recdev_early_start<<endl;}
    if(recdev_start-recdev_early_start<6)
    {N_warn++;  warning<<N_warn<<" "<<" Are you sure you want so few early recrdevs? Better to include in range of main recdevs "<<recdev_start-recdev_early_start<<endl;}

    recdev_first=recdev_early_start;  // because this is before recdev_start
    recdev_early_end=recdev_start-1;
    for (y=recdev_early_start;y<=recdev_early_end;y++)
    {
      ParCount++;
      recdev_doit(y)=1;
      if(y>=styr)
      {
        sprintf(onenum, "%d", y);
        ParmLabel+="Early_RecrDev_"+onenum+CRLF(1);
      }
      else
      {
        onenum="    ";
        sprintf(onenum, "%d", styr-y);
        ParmLabel+="Early_InitAge_"+onenum+CRLF(1);
      }
    }
  }

  if(do_recdev>0)
  {
    for (y=recdev_start;y<=recdev_end;y++)
    {
      ParCount++;
      recdev_doit(y)=1;

        if(y>=styr)
        {
        sprintf(onenum, "%d", y);
        ParmLabel+="Main_RecrDev_"+onenum+CRLF(1);
      }
      else
        {
          onenum="    ";
        sprintf(onenum, "%d", styr-y);
        ParmLabel+="Main_InitAge_"+onenum+CRLF(1);
      }
    }
  }

  if(Do_Forecast>0)
  {
    if(do_recdev!=0){
    for (y=recdev_end+1;y<=YrMax;y++)
    {
      recdev_doit(y)=1;
      sprintf(onenum, "%d", y);
      ParCount++;
      if(y>endyr)
      {ParmLabel+="ForeRecr_"+onenum+CRLF(1);}
      else
      {ParmLabel+="Late_RecrDev_"+onenum+CRLF(1);}
    }
    }

    if(Do_Impl_Error>0){
    	for (y=endyr+1;y<=YrMax;y++)
    {
      sprintf(onenum, "%d", y);
      ParCount++;
      ParmLabel+="Impl_err_"+onenum+CRLF(1);
    }
   }
  }

      biasadj_full.initialize();
      if(recdev_adj(5)==-1)  //  all years with estimated recruitments
      	{biasadj_full=recdev_doit;}
      else if(recdev_adj(5)==-2)  //  no ramp
      	{biasadj_full(recdev_first,endyr)=recdev_doit(recdev_first,endyr);}
      else if(recdev_adj(5)==-3)  //  all to 0.0
      	{biasadj_full=0.0;}
      else {    //  do ramp
        for (y=styr-nages; y<=YrMax; y++)
        {
          if(y<recdev_first)  // before start of recrdevs
            {biasadj_full(y)=0.;}
          else if(y<=recdev_adj(1))
            {biasadj_full(y)=0.;}
          else if (y<=recdev_adj(2))
            {biasadj_full(y)=(y-recdev_adj(1)) / (recdev_adj(2)-recdev_adj(1))*recdev_adj(5);}
          else if (y<=recdev_adj(3))
            {biasadj_full(y)=recdev_adj(5);}   // max bias adjustment
          else if (y<=recdev_adj(4))
            {biasadj_full(y)=recdev_adj(5)-(y-recdev_adj(3)) / (recdev_adj(4)-recdev_adj(3))*recdev_adj(5);}
          else
            {biasadj_full(y)=0.;}
          if(y>endyr) {biasadj_full(y)=0.0;}
        }
      }
    echoinput<<"#_recruitment bias adjustment"<<endl<<biasadj_full<<endl;;

 END_CALCS

!!//  SS_Label_Info_4.6.5 #Read recdev_cycle parameters and input recruitment deviations if needed
  init_matrix recdev_cycle_parm_RD(1,recdev_cycle,1,14);
  !!k=1;
  !!if(recdev_cycle>0) k=recdev_cycle;
  vector recdev_cycle_LO(1,k);
  vector recdev_cycle_HI(1,k);
  ivector recdev_cycle_PH(1,k);
  !!if(recdev_cycle>0) echoinput<<"recruitment cycle input "<<endl<<recdev_cycle_parm_RD<<endl;

  init_matrix recdev_input(1,recdev_read,1,2);
  !!if(recdev_read>0) echoinput<<"recruitment deviation input "<<endl<<recdev_input<<endl;

!!//  SS_Label_Info_4.7 #Input F_method setup
  init_number F_ballpark
  !! echoinput<<F_ballpark<<" F ballpark is annual F, as specified in F_reporting, for a specified year"<<endl;
  init_int F_ballpark_yr
  !! echoinput<<F_ballpark_yr<<" F_ballpark_yr (<0 to ignore)  "<<endl;
  init_int F_Method;           // 1=Pope's; 2=continuouos F; 3=hybrid
  int F_Method_use
  !! echoinput<<F_Method<<" F_Method "<<endl;
  init_number max_harvest_rate
  number Equ_F_joiner

 LOCAL_CALCS
    echoinput<<max_harvest_rate<<" max_harvest_rate "<<endl;
  if(F_Method<1 || F_Method>4)
    {
      N_warn++;
     warning<<N_warn<<" "<<" ERROR:  F_Method must be 1 or 2 or 3 or 4, value is: "<<F_Method<<endl;
    cout<<" EXIT - see warning "<<endl;
    exit(1);
    }
   if(F_Method==1)
   {
     k=-1;
     Equ_F_joiner=(log(1./max_harvest_rate -1.))/(max_harvest_rate-0.2);  //  used to spline the harvest rate
     if(max_harvest_rate>0.999)
     {N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" "<<" max harvest rate must  be <1.0 for F_method 1 "<<max_harvest_rate<<endl; exit(1);}
     if(max_harvest_rate<=0.30)
     {N_warn++;  warning<<N_warn<<" "<<" unexpectedly small value for max harvest rate for F_method 1:  "<<max_harvest_rate<<endl;}
   }
   else
   {
     if(max_harvest_rate<1.0)
     {N_warn++;  warning<<N_warn<<" "<<" max harvest rate should be >1.0 for F_method 2, 3 or 4 "<<max_harvest_rate<<endl;}
     if(F_Method==2)  //  all fleets start with same info and use parameters
     {
       k=3;
     }
     else if(F_Method==3)  //  hybrid
     {
       k=1;
     }
     else  //  parameters, with fleet-specific setup
    {
      k=1;
    }
   }
 END_CALCS

  init_vector F_setup(1,k)
// setup for F_rate with F_Method=2
// F_setup(1) = overall initial value
// F_setup(2) = overall phase
// F_setup(3) = number of specific initial values and phases to read
  int F_detail;
  int F_Tune;
 LOCAL_CALCS
  F_detail=-1;
  F_Tune=0;
  if(F_Method>1)
  {
    if(F_Method==2)
    {
      echoinput<<F_setup<<" initial F value, F phase, N_detailed Fsetups to read "<<endl;
      F_detail=F_setup(3);
      F_Tune=4;
//      F_rate_max=max_harvest_rate;  // used to set upper bound on F_rate parameter
    }
    else if(F_Method==3)
    {
      F_Tune=F_setup(1);
      echoinput<<F_Tune<<" N iterations for tuning hybrid F "<<endl;
    }
  }
 END_CALCS

  init_matrix F_setup2(1,F_detail,1,6)  // fleet, yr, seas, Fvalue, se, phase
  !!echoinput<<" detailed F_setups "<<endl<<F_setup2<<endl;

!!//  SS_Label_Info_4.7.1 #Read setup for init_F parameters and create init_F parameter labels
//  NEW  only read for catch fleets with positive initial equ catch
  imatrix init_F_loc(1,nseas,1,Nfleet);  // pointer to init_F parameter for each fleet
  int N_init_F;
  int N_init_F2;  //  for conversion of 3.24 to 3.30
 LOCAL_CALCS
  init_F_loc.initialize();
  N_init_F=0;
  N_init_F2=0;

  {
    for (s=1;s<=nseas;s++)
    for (f=1;f<=Nfleet;f++)
    {
      if(fleet_type(f)<=2)
      {
        if(obs_equ_catch(s,f)!=0.0)
        {
          N_init_F++;
          init_F_loc(s,f)=N_init_F;
        }
      }
      N_init_F2=N_init_F;
    }
  }
 END_CALCS
  !! echoinput<<" ready to read init_F setup for: "<<N_init_F<<" fleet x season with initial equilibrium catch"<<endl;
  init_matrix init_F_parm_1(1,N_init_F,1,7)
  !! echoinput<<" initial equil F parameter setup"<<endl<<init_F_parm_1<<endl;
  vector init_F_LO(1,N_init_F)
  vector init_F_HI(1,N_init_F)
  vector init_F_RD(1,N_init_F)
  vector init_F_PR(1,N_init_F)
  vector init_F_PRtype(1,N_init_F)
  vector init_F_CV(1,N_init_F)
  ivector init_F_PH(1,N_init_F)
    int N_Fparm
    int Fparm_start


 LOCAL_CALCS

  if(N_init_F>0)
  {
   init_F_LO=column(init_F_parm_1,1);
   init_F_HI=column(init_F_parm_1,2);
   init_F_RD=column(init_F_parm_1,3);
   init_F_PR=column(init_F_parm_1,4);
   init_F_CV=column(init_F_parm_1,5);
   init_F_PRtype=column(init_F_parm_1,6);
   init_F_PH=ivector(column(init_F_parm_1,7));

   k=nseas;

   for (s=1;s<=k;s++)
   for (f=1;f<=Nfleet;f++)
   {
     if(init_F_loc(s,f)>0)
     {
       ParCount++; ParmLabel+="InitF_seas_"+NumLbl(s)+"_flt_"+NumLbl(f)+fleetname(f);
       j=init_F_loc(s,f);
       if(obs_equ_catch(s,f)<=0.0)
       {
         if(init_F_RD(j)>0.0)
         {
           N_warn++;
            warning<<N_warn<<" "<<f<<" catch: "<<obs_equ_catch(s,f)<<" initF: "<<init_F_RD(j)<<" initF is reset to be 0.0"<<endl;
         }
         init_F_RD(j)=0.0; init_F_PH(j)=-1;
       }
       if(obs_equ_catch(s,f)>0.0 && init_F_RD(j)<=0.0)
       {
         N_warn++; cout<<" EXIT - see warning "<<endl;
          warning<<N_warn<<" "<<f<<" catch: "<<obs_equ_catch(s,f)<<" initF: "<<init_F_RD(j)<<" initF must be >0"<<endl; exit(1);
       }
     }
   }
  }
 END_CALCS

 LOCAL_CALCS
//  SS_Label_Info_4.7.2 #Create parameter labels for F parameters if F_method==2
  N_Fparm=0;
  do_Fparm.initialize();
  Fparm_start = ParCount;
  if(F_Method==2)
  {
    for (f=1;f<=Nfleet;f++)
    for (y=styr;y<=endyr;y++)
    for (s=1;s<=nseas;s++)
    {
      t=styr+(y-styr)*nseas+s-1;
      if(catch_ret_obs(f,t)>0. && fleet_type(f)<=2)
      {
        N_Fparm++;
        sprintf(onenum, "%d", y);
        ParCount++;
        do_Fparm(f,t)=N_Fparm;
        ParmLabel+="F_fleet_"+NumLbl(f)+"_YR_"+onenum+"_s_"+NumLbl(s)+CRLF(1);
      }
    }
    echoinput<<" N F parameters "<<N_Fparm<<endl;
  }
 END_CALCS
  ivector Fparm_PH(1,N_Fparm);
  imatrix Fparm_loc(1,N_Fparm,1,2);  //  stores f,t
  vector Fparm_max(1,N_Fparm);
  int y1;
  
 LOCAL_CALCS
  Fparm_max.initialize();
  Fparm_PH.initialize();
  if(F_Method==2)
  {
    Fparm_max=max_harvest_rate;  //  populate vector with input value
    Fparm_PH=F_setup(2);
    g=0;
    for (f=1;f<=Nfleet;f++)
    for (y=styr;y<=endyr;y++)
    for (s=1;s<=nseas;s++)
    {
      t=styr+(y-styr)*nseas+s-1;
      if(catch_ret_obs(f,t)>0. && fleet_type(f)<=2)
      {
        g++;
        Fparm_loc(g,1)=f; Fparm_loc(g,2)=t;
      }
    }

      if(F_detail>0)
      {
        for (k=1;k<=F_detail;k++)
        {
          f=F_setup2(k,1); y=F_setup2(k,2); s=F_setup2(k,3);
          if(y>0)
          {y1=y; y2=y;}
          else
          {y1=-y; y2=endyr;}
          for(y=y1; y<=y2; y++)
          {
            t=styr+(y-styr)*nseas+s-1;
            j=do_Fparm(f,t);
            if(j>0 && F_setup2(k,6)!=-999) Fparm_PH(j)=F_setup2(k,6);    //   used to setup the phase for F_rate
            if(j>0 && F_setup2(k,5)!=-999) catch_se(t,f)=F_setup2(k,5);    //    reset the se for this observation
          }
          //  setup of F_rate values occurs later in the parameter section
        }
      }
  }

 END_CALCS

//  SS_Label_Info_4.8 #Read catchability (Q) setup
  imatrix Q_setup(1,Nfleet,1,5)
  ivector Q_setup_check(1,Nfleet)
  imatrix Q_setup_parms(1,Nfleet,1,5)  //  index of first parameter for:  1=base q with link;  2=extrastd; 3=env; 4=block/trend; 5=dev;
  int parm330_cnt
  int Q_Npar2
  int Q_Npar
  int firstQparm;
  int timevary_parm_cnt_Q;
  int timevary_parm_start_Q;
  ivector Q_link(1,10);
  int depletion_fleet;  //  stores fleet(survey) number for the fleet that is defined as "depletion" by survey type=34
  int depletion_type;  //  entered by Q_setup(f,2) and stores additional controls for depletion fleet

 LOCAL_CALCS
  firstQparm=0;
  timevary_parm_cnt_Q=0;
  timevary_parm_start_Q=0;
  Q_link.initialize();
  Q_link(1)=1;  //  simple q, 1 parm
  Q_link(2)=1;  //  mirror simple q, 1 mirrored parameter
  Q_link(3)=2;  //  q and power, 2 parm
  depletion_fleet=0;
  depletion_type=0;

//Q_setup for 3.30
// 1:  link type
// 2:  extra input for link, i.e. mirror fleet or dev_vector index associated with survey
// 3:  0/1 to select extra sd parameter
// 4:  0/1 for biasadj or not
// 5:  0/1 to float

//  read setup and get the parameter count
  echoinput<<"# read Q setup only for fleets with survey/CPUE/effort observations, end with fleet_ID<0 "<<
  "#  fleet_ID link_type link_info  extra_se(0/1)   biasadj(0/1)  float(0/1)"<<endl;
  firstQparm=ParCount;  //  base index before adding Q parms
  Q_setup.initialize();
  Q_setup_parms.initialize();
  Q_Npar=0;
  Q_setup_check.initialize();
  j=1;
  do
  {
    *(ad_comm::global_datafile) >>j;
    if(j>0)
   {*(ad_comm::global_datafile) >>Q_setup(j);
    Q_setup_check(j)=1;}
    else
   {*(ad_comm::global_datafile) >>tempvec(1,5);}
  } while(j>0);
   echoinput<<"q setup "<<endl<<Q_setup<<endl;

//  get base parameter count
  for(f=1;f<=Nfleet;f++)
  {
  if(Svy_N_fleet(f)>0)
  {
    if(Q_setup_check(f)==0)
    {
      N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" "<<f<<" fatal Qsetup error;  survey obs exist but no Q setup was read "<<endl; exit(1);
    }
      Q_Npar++;  ParCount++;
      Q_setup_parms(f,1)=Q_Npar;  //  first parameter index for this fleet that has obs so needs a Q
      if(Svy_errtype(f)==-1)
      {
        ParmLabel+="Q_base_"+fleetname(f)+"("+NumLbl(f)+")";
      }
      else
      {
        ParmLabel+="LnQ_base_"+fleetname(f)+"("+NumLbl(f)+")";
      }
      if(Svy_units(f)==35)
      {
        echoinput<<"fleet: "<<f<<"  is a survey of dev vector:  "<<Q_setup(f,2)<<endl;
        if(Q_setup(f,2)==0)  {N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" "<<"fatal Qsetup error:  must enter index of dev_vector surveyed by fleet:  "<<f<<endl;  exit(1);}
      }
   	  switch (Q_setup(f,1))
      {
        case 1:  //  simple Q
        {
          break;
        }
        case 2:  //  mirror
        {
          int fmirror;
          fmirror=Q_setup(f,2);
          if(fmirror==0 || fmirror>=f)
          {
            N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" "<<" illegal mirror for q for fleet: "<<f<<" trying to mirror fleet: "<<Q_setup(f,2)<<endl; exit(1);
          }
          if(Q_setup(fmirror,5)==1)
          {
            N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" "<<" fleet: "<<f<<"  cannot mirror fleet that has float q: "<<fmirror<<endl; 
            exit(1);
          }
          break;
        }
        case 3:  //  add power
        {
          Q_Npar++;  ParCount++;
          ParmLabel+="Q_power_"+fleetname(f)+"("+NumLbl(f)+")";
          break;
        }
        case 4:  //  mirror with offset, where offset typically is ln(area_base/area_dependent)  ln(Q2) = ln(Q1) + ln (area1 / area2)
        {
          if(Q_setup(f,2)==0 || Q_setup(f,2)>=f)
          {
            N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" "<<" illegal mirror for q for fleet: "<<f<<" trying to mirror fleet: "<<Q_setup(f,2)<<endl; exit(1);
          }
          Q_Npar++;  ParCount++;
          ParmLabel+="Q_mirror_offset_"+fleetname(f)+"("+NumLbl(f)+")";
          break;
        }
      }
    if(Q_setup(f,3)>0)
    {
       Q_Npar++;  ParCount++;
       Q_setup_parms(f,2)=Q_Npar;
      ParmLabel+="Q_extraSD_"+fleetname(f)+"("+NumLbl(f)+")";
    }
    if(Svy_units(f)==34)  //  special code for depletion, so prepare to adjust phases and lambdas
      {
        echoinput<<"# survey: "<<f<<" "<<fleetname(f)<<" is a depletion fleet"<<endl;
        depletion_fleet=f;
        depletion_type=Q_setup(f,2);
        if(depletion_type==0)
          echoinput<<"link_info=0; add 1 to phases of all parms; only R0 active in new phase 1 (same as 3.24 logic)"<<endl;
        if(depletion_type==1)
          echoinput<<"link_info=1  only R0 active in phase 1; then exit;  useful for data-limited draws of other fixed parameter"<<endl;
        if(depletion_type==2)
          echoinput<<"link_info=2  no phase adjustments, can be used when profiling on fixed R0"<<endl;
        if(Q_setup(f,5)==1)
        	{N_warn++; 
        		 warning<<N_warn<<" "<<"change to no_float for depletion fleet # "<<f<<endl
        		<<"++ and you must set phase to negative so not estimated"<<endl; Q_setup(f,5)=0;
        	}
      }
    }
  else
  {
    if(Q_setup_check(f)>0)
    {
      N_warn++; cout<<"exit see warning "<<endl;  warning<<N_warn<<" "<<f<<" Q setup error; no survey obs but Q setup was read "<<endl;  exit(1);
    }
  }
  }

  echoinput<<"q setup "<<endl<<Q_setup<<endl;
  echoinput<<"q setup parms "<<endl<<Q_setup_parms<<endl;

 END_CALCS

  init_matrix Q_parm_1(1,Q_Npar,1,14)
  ivector Qparm_timevary(1,Q_Npar)  //  holds index in timevary_def used by each base parameter
                                         //  dimensioned to hold the extra_sd parms, but these cannot be time-varying
  imatrix timevary_Qparm(styr-3,YrMax+1,0,Nfleet)  // goes to yrmax+1 to allow referencing in forecast, but only endyr+1 is checked
                                                     // stores years to calc non-constant sel parms by fleet

 LOCAL_CALCS
//  now create time_vary parameters
  parm330_cnt=0;  //  restart the index
  Qparm_timevary.initialize();
  timevary_Qparm.initialize();
  timevary_parm_start_Q=0;
  timevary_parm_cnt_Q=0;
  timevary_used=0;
  for(f=1;f<=Nfleet;f++)
  if(Svy_N_fleet(f)>0)
  {
     j=Q_setup_parms(f,1);
     echoinput<<"fleet "<<f<<" base index "<<j<<endl;
     if(Q_setup(f,5)==1)  //  float
      {if(Q_parm_1(j,7)>=0)  {N_warn++;   warning<<N_warn<<" "<<"fleet: "<<f<<"  SS changed Q to not estimate because it is set to float"<<endl;  Q_parm_1(j,7)=-1; }
      }

//  depletion fleet check
    if(Svy_units(f)==34)  //  special code for depletion
    	{if(Q_parm_1(j,7)>=0)  {N_warn++;   warning<<N_warn<<" "<<"fleet: "<<f<<" SS changed Q to not estimate because it is depletion fleet"<<endl;  Q_parm_1(j,7)=-1; }
    	}

      
     //  check for extraSD estimation
     if(Q_setup(f,3)>0)
      {
        if(Q_parm_1(Q_setup_parms(f,2),7)>0) varparm_estimated(3)=1; // extraSD is estimated, so need sd_offset=1
      }

     if(Q_parm_1(j,13)==0 && Q_parm_1(j,8)==0 && Q_parm_1(j,9)==0)
     {
      //  no time-vary parameter effects
     }
     else  //  set up a timevary parameter definition
     {
     	 timevary_used=1;
       ivector timevary_setup(1,14);  //  temporary vector for timevary specs
       timevary_setup.initialize();
       if(timevary_parm_start_Q==0) timevary_parm_start_Q=timevary_parm_cnt+1;
       echoinput<<endl<<" timevary Q for fleet: "<<f<<endl;
       timevary_cnt++;  //  count parameters with time-vary effect
       Qparm_timevary(j)=timevary_cnt;  //  base Q parameter will use this timevary specification
       timevary_setup(1)=3; //  indicates a Q parm
       timevary_setup(2)=j; //  index of base parm within that type of parameter
       timevary_setup(13)=firstQparm+j;  //  index of base parm relative to ParCount which is continuous across all types of parameters
       timevary_setup(3)=timevary_parm_cnt+1;  //  first parameter within total list of all timevary parms
       timevary_pass=column(timevary_Qparm,f);  // year vector for this fleet
//  set up env link info
      echoinput<<" check for env "<<Q_parm_1(j,8)<<endl;

       k=int(abs(Q_parm_1(j,8))/100);  //  find the env link code
       timevary_setup(6)=k;  //  link code for env
       if(Q_parm_1(j,8)>0)  //  env variable used
       {
         timevary_setup(7)=int(abs(Q_parm_1(j,8)))-k*100;
         k=timevary_setup(7);
//         for(y=styr-1;y<=YrMax;y++) env_data_pass(y)=env_data_RD(y,k);
         env_data_pass(1)=env_data_minyr(k);
         env_data_pass(2)=env_data_maxyr(k);
       }
       else  //  density-dependence
       {
         timevary_setup(7)=-int(abs(Q_parm_1(j,8))-k*100);
         do_densitydependent=1;
         k=0; env_data_pass.initialize();
       }

       if(Q_parm_1(j,13)>0)  //  doing blocks
       {
         if(Q_parm_1(j,13)>N_Block_Designs)
          {N_warn++; cout<<"Fatal_input_error, see warning"<<endl;  warning<<N_warn<<" "<<" Error: Q block request exceeds N_block patterns"<<endl;  exit(1);}
         create_timevary(Q_parm_1(j),timevary_setup, timevary_pass, autogen_timevary(timevary_setup(1)), f, Block_Design(Q_parm_1(j,13)), parm_adjust_method, env_data_pass, N_parm_dev,finish_starter);
       }
       else
       {
         create_timevary(Q_parm_1(j),timevary_setup, timevary_pass, autogen_timevary(timevary_setup(1)), f, block_design_null, parm_adjust_method, env_data_pass, N_parm_dev,finish_starter);
       }
  /*
   where:
   Q_parm_1(j):           vector with the base parameter which has some type of timevary characteristic
   timevary_setup:        vector which contains specs of all types of timevary  for this base parameter
                          will be pushed to timevary_def cumulative across all types of base parameters
   timevary_pass:        vector containing column(timevary_MG,mgp_type(j)), will be modified in create_timevary
   autogen_timevary:      switch to autogenerate or not
   f:           integer with type of MGparm being worked on; analogous to 2*fleet in the selectivity section
   block_design(z):       block design, if any, being used
   parm_adjust_method:    switch to determine if adjusted parameter will stay in bounds; used to create warnings in create_timevary
   env_data_RD:           matrix containing entire set of environmental data as read
   N_parm_dev:            integer that is incremented in create_timevary as dev vectors are created; cumulative across all types of parameters
  */

       timevary_def.push_back (timevary_setup(1,14));
       for(y=styr-3;y<=YrMax+1;y++) {timevary_Qparm(y,f)=timevary_pass(y);}  // year vector for this category og MGparm
     }
  }

   Q_Npar2 = Q_Npar;
   if(timevary_parm_start_Q>0)
   {
     if(timevary_used==1) autogen_timevary(3)=1;  //  indicate that some parameter is time-varying
     timevary_parm_cnt_Q=timevary_parm_cnt;
     Q_Npar2+=(timevary_parm_cnt_Q-timevary_parm_start_Q+1);
     echoinput<<"Q  uses timevary parms:  "<<Qparm_timevary<<endl;
     echoinput<<" Q  timevary_parm_cnt start and end "<<timevary_parm_start_Q<<" "<<timevary_parm_cnt_Q<<endl;
   }
   echoinput<<"Q_Npar and Q_Npar2:  "<<Q_Npar<<" "<<Q_Npar2<<endl;

 END_CALCS

  vector Q_parm_LO(1,Q_Npar2)
  vector Q_parm_HI(1,Q_Npar2)
  vector Q_parm_RD(1,Q_Npar2)
  vector Q_parm_PR(1,Q_Npar2)
  ivector Q_parm_PRtype(1,Q_Npar2)
  vector Q_parm_CV(1,Q_Npar2)
  ivector Q_parm_PH(1,Q_Npar2)

 LOCAL_CALCS
  if(Q_Npar2==0)
  {Q_parm_LO=-1.; Q_parm_HI=1.; Q_parm_PH=-4;}
  else
 	{
 		for(i=1;i<=Q_Npar;i++)
 		{
      Q_parm_LO(i)=Q_parm_1(i,1);
      Q_parm_HI(i)=Q_parm_1(i,2);
      Q_parm_RD(i)=Q_parm_1(i,3);
      Q_parm_PR(i)=Q_parm_1(i,4);
      Q_parm_CV(i)=Q_parm_1(i,5);
      Q_parm_PRtype(i)=Q_parm_1(i,6);
      Q_parm_PH(i)=Q_parm_1(i,7);
    }
    if(timevary_parm_start_Q>0)
    {
      j=Q_Npar;
    for (f=timevary_parm_start_Q;f<=timevary_parm_cnt_Q;f++)
     {
      j++;
      echoinput<<f<<" "<<j<<" "<<timevary_parm_rd[f]<<endl;
      Q_parm_LO(j)=timevary_parm_rd[f](1);
      Q_parm_HI(j)=timevary_parm_rd[f](2);
      Q_parm_RD(j)=timevary_parm_rd[f](3);
      Q_parm_PR(j)=timevary_parm_rd[f](4);
      Q_parm_PRtype(j)=timevary_parm_rd[f](6);
      Q_parm_CV(j)=timevary_parm_rd[f](5);
      Q_parm_PH(j)=timevary_parm_rd[f](7);
     }
 	  }
 	}
 	echoinput<<"Q_parm_RD: "<<endl;
 	for(z=1;z<=Q_Npar2;z++)
 	echoinput<<z<<" "<<Q_parm_RD(z)<<" "<<ParmLabel(ParCount-Q_Npar2+z)<<endl;
  echoinput<<"#"<<endl;
 END_CALCS

!!//  SS_Label_Info_4.9 #Define Selectivity patterns and N parameters needed per pattern
  ivector seltype_Nparam(0,50)
 LOCAL_CALCS
   seltype_Nparam(0)=0;   // selex=1.0 for all sizes
   seltype_Nparam(1)=2;   // logistic; with 95% width specification
   seltype_Nparam(2)=6;   // test version of double normal (24)
   seltype_Nparam(3)=6;   // flat middle, power up, power down
   seltype_Nparam(4)=0;   // set size selex=female maturity
   seltype_Nparam(5)=2;   // mirror another selex; PARMS pick the min-max bin to mirror
   seltype_Nparam(6)=2;   // non-parm len selex, additional parm count is in seltype(f,4)
   seltype_Nparam(7)=8;   // New doublelogistic with smooth transitions and constant above Linf option
   seltype_Nparam(8)=8;   // New doublelogistic with smooth transitions and constant above Linf option
   seltype_Nparam(9)=6;   // simple 4-parm double logistic with starting length; parm 5 is first length; parm 6=1 does desc as offset

   seltype_Nparam(10)=0;   //  First age-selex  selex=1.0 for all ages
   seltype_Nparam(11)=2;   //  pick min-max age
   seltype_Nparam(12)=2;   //   logistic
   seltype_Nparam(13)=8;   //   double logistic
   seltype_Nparam(14)=nages+1;   //   empirical
   seltype_Nparam(15)=0;   //   mirror another selex
   seltype_Nparam(16)=2;   //   Coleraine - Gaussian
   seltype_Nparam(17)=nages+1;   //   empirical as random walk  N parameters to read can be overridden by setting special to non-zero
   seltype_Nparam(18)=8;   //   double logistic - smooth transition
   seltype_Nparam(19)=6;   //   simple 4-parm double logistic with starting age
   seltype_Nparam(20)=6;   //   double_normal,using joiners

   seltype_Nparam(21)=2;   // non-parm len selex, additional parm count is in seltype(f,4), read as pairs of size, then selex
   seltype_Nparam(22)=4;   //   double_normal as in CASAL
   seltype_Nparam(23)=6;   //   double_normal where final value is directly equal to sp(6) so can be >1.0
   seltype_Nparam(24)=6;   //   double_normal with sel(minL) and sel(maxL), using joiners
   seltype_Nparam(25)=3;   //   exponential-logistic in size
   seltype_Nparam(26)=3;   //   exponential-logistic in age
   seltype_Nparam(27)=3;   // cubic spline for selex at length, additional parm count is in seltype(f,4)
//   seltype_Nparam(28)=3;   // cubic spline for selex at age, additional parm count is in seltype(f,4)
   seltype_Nparam(29)=0;   //   undefined

   seltype_Nparam(41)=2+seltype_Nparam(17); // like 17, with 2 additional parameters for scaling (average over bin range)
   seltype_Nparam(42)=2+seltype_Nparam(27); // like 27, with 2 additional parameters for scaling (average over bin range)
   seltype_Nparam(43)=seltype_Nparam(6);  // like 6, with 2 additional parameters for scaling (average over bin range)
   seltype_Nparam(44)=4;  // like 17 for two sexes with male selectivity as separate parameters
   seltype_Nparam(45)=4;  // like 14 for two sexes with male selectivity as separate parameters

 END_CALCS

!!//  SS_Label_Info_4.9.1 #Read selectivity definitions
//  do 2*Nfleet to create options for size-selex (first), then age-selex
  init_imatrix seltype_rd(1,2*Nfleet,1,4)    // read selex type for each fleet/survey, retention option, male_offset_option, special
  imatrix seltype(1,2*Nfleet,1,4)    // read selex type for each fleet/survey, retention option, male_offset_option, special

  int N_selparm   // figure out the Total number of selex parameters
  int N_selparm3                 // N selparms plus timevary parms
  int N_selparm2                 // N selparms plus timevary parms and 2D_AR1 parms
  ivector N_selparmvec(1,2*Nfleet)  //  N selparms by type, including extra parms for male selex, retention, etc.
  ivector Maleselparm(1,2*Nfleet)
  ivector RetainParm(1,Nfleet)  //  can only have length or age retention, not both for a fleet
  ivector dolen(1,Nfleet)
  int blkparm
  int firstselparm
  ivector N_ret_parm(0,6)  //  6 possible retention functions allowed
  ivector N_disc_mort_parm(0,6)  //  6 possible discard mortality functions allowed
  ivector Do_Retain(1,Nfleet)  // indicates 0=none, 1=length based, 2=age based
  ivector Min_selage(1,Nfleet) //  minimum selected age
 LOCAL_CALCS
  echoinput<<" selex types "<<endl<<seltype_rd<<endl;
  
  //  identify fleets with adjusted first_selected age
  seltype=seltype_rd;  //  set matrices to be same
  Min_selage.initialize();
  for(f=1;f<=2*Nfleet;f++)
  {
  	echoinput<<f<<" "<<seltype_rd(f,1)<<endl;
  	if(seltype_rd(f,1)>=100)
		{
			if(f<=Nfleet)
			{
				N_warn++;  warning<<N_warn<<" "<<"fleet: "<<f<<"  cannot use >100 code for length selectivity; SS will correct"<<endl;
				j=int(seltype(f,1)/100);
				k=seltype(f,1)-100*j;
				seltype_rd(f,1)=k;  //  change input value so will be written correctly in ss_new
	  		seltype(f,1)=seltype_rd(f,1);
			}
			else
			{
				Min_selage(f-Nfleet)=int(seltype(f,1)/100);
				k=seltype(f,1)-100*Min_selage(f-Nfleet);
				echoinput<<seltype(f,1)<<" "<<k<<" "<<Min_selage(f-Nfleet)<<endl;
				if(k==12 || k==13 || k==14 || k==16 || k==18 || k==26 || k==27)
				{echoinput<<"OK to use min_selage for selex pattern: "<<k<<" for fleet: "<<f-Nfleet<<endl;}
				else if (k==17 || k==44 || k==45)
			  {N_warn++;  warning<<N_warn<<" "<<"Don't use min_selage for age selectivity: "<<k<<" for fleet: "<<f-Nfleet<<
			  " because separate control exists; SS will correct"<<endl; seltype_rd(f,1)=k;} //  change input value so will be written correctly in ss_new
				else if (k==19)
			  {N_warn++;  warning<<N_warn<<" "<<"can't use min_selage for age selectivity: "<<k<<" for fleet: "<<f-Nfleet<<
			  	" because separate control sets sel = 1.0e-06 below a specified age SS will correct"<<endl;seltype_rd(f,1)=k;}
				else if (k==20)
			  {N_warn++;  warning<<N_warn<<" "<<"OK to use min_selage for age selectivity: "<<k<<" for fleet: "<<f-Nfleet<<
			  	" but be aware that a separate control for parm 5 can set sel = 1.0e-06 below a specified age"<<endl;}
			  else
			  {echoinput<<"Min_selage not implemented and not relevant for selex pattern: "<<k<<" for fleet: "<<f-Nfleet<<endl;seltype_rd(f,1)=k;}
			  seltype(f,1)=k;
			}
		}
  }
  
  RetainParm.initialize();
//  define number of parameters for each retention type
  N_ret_parm(0)= 0;
  N_ret_parm(1)= 4; // for asymptotic retention
  N_ret_parm(2)= 4; // for asymptotic retention and 4 param discard mort
  N_ret_parm(3)= 0; // all dead
  N_ret_parm(4)= 7; // for dome-shaped retention and 4 param discard mort

//  define number of discard mortality parameters for each retention type
  N_disc_mort_parm(0)= 0;
  N_disc_mort_parm(1)= 0;   // for asymptotic retention
  N_disc_mort_parm(2)= 4;   // for asymptotic retention and 4 param discard mort
  N_disc_mort_parm(3)= 0;   // all dead
  N_disc_mort_parm(4)= 4;   // for dome-shaped retention and 4 param discard mort

//  SS_Label_Info_4.9.2 #Process selectivity parameter count and create parameter labels
   firstselparm=ParCount;
   N_selparm=0;
//   N_ret_parm=7;    // to allow for dome-shaped retention
   Do_Retain.initialize();
   for (f=1;f<=Nfleet;f++)
   {
     if(WTage_rd>0 && seltype(f,1)>0)
     {
      N_warn++;  warning<<N_warn<<" "<<" Use of size selectivity not advised when reading empirical wt-at-age "<<endl;
     }
     N_selparmvec(f)=seltype_Nparam(seltype(f,1));   // N Length selex parms
     if(seltype(f,1)==6 || seltype(f,1)==43) N_selparmvec(f) +=seltype(f,4);  // special setup of N parms
     if(seltype(f,1)==21) N_selparmvec(f) +=2*(seltype(f,4)-1);  // special setup of N parms
     if(seltype(f,1)==27) N_selparmvec(f) +=2*seltype(f,4);  // special setup of N parms for cubic spline
     if(seltype(f,1)==42) N_selparmvec(f) +=2*seltype(f,4);  // special setup of N parms for cubic spline
     if(seltype(f,1)>0 && Svy_units(f)<30) {dolen(f)=1;} else {dolen(f)=0;}
     if(seltype(f,1)==15 || seltype(f,1)==5) // mirror
     {
       if(seltype(f,4)==0 || seltype(f,4)>=f)
       {
         N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" "<<" illegal mirror for len selex fleet "<<f<<"trying to mirror fleet: "<<seltype(f,4)<<endl; exit(1);
       }
     }
     if(seltype(f,1)==43)
     {
         ParCount++; ParmLabel+="SizeSel_ScaleBinLo_"+fleetname(f)+"("+NumLbl(f)+")";
         ParCount++; ParmLabel+="SizeSel_ScaleBinHi_"+fleetname(f)+"("+NumLbl(f)+")";
         echoinput<<"N parm "<<N_selparmvec(f)<<endl;
     }

     if(seltype(f,1)==27 || seltype(f,1)==42)
     {
         if(seltype(f,1)==42)
         {
             ParCount++; ParmLabel+="SizeSpline_ScaleBinLo_"+fleetname(f)+"("+NumLbl(f)+")";
             ParCount++; ParmLabel+="SizeSpline_ScaleBinHi_"+fleetname(f)+"("+NumLbl(f)+")";
         }
         ParCount++; ParmLabel+="SizeSpline_Code_"+fleetname(f)+"("+NumLbl(f)+")";
         ParCount++; ParmLabel+="SizeSpline_GradLo_"+fleetname(f)+"("+NumLbl(f)+")";
         ParCount++; ParmLabel+="SizeSpline_GradHi_"+fleetname(f)+"("+NumLbl(f)+")";
         for (s=1;s<=seltype(f,4);s++)
         {
           ParCount++; ParmLabel+="SizeSpline_Knot_"+NumLbl(s)+"_"+fleetname(f)+"("+NumLbl(f)+")";
         }
         for (s=1;s<=seltype(f,4);s++)
         {
           ParCount++; ParmLabel+="SizeSpline_Val_"+NumLbl(s)+"_"+fleetname(f)+"("+NumLbl(f)+")";
         }
     }
     else if (seltype(f,1)==24 || seltype(f,1)==2)  //  double_normal
     {
       ParCount++; ParmLabel+="Size_DblN_peak_"+fleetname(f)+"("+NumLbl(f)+")";
       ParCount++; ParmLabel+="Size_DblN_top_logit_"+fleetname(f)+"("+NumLbl(f)+")";
       ParCount++; ParmLabel+="Size_DblN_ascend_se_"+fleetname(f)+"("+NumLbl(f)+")";
       ParCount++; ParmLabel+="Size_DblN_descend_se_"+fleetname(f)+"("+NumLbl(f)+")";
       ParCount++; ParmLabel+="Size_DblN_start_logit_"+fleetname(f)+"("+NumLbl(f)+")";
       ParCount++; ParmLabel+="Size_DblN_end_logit_"+fleetname(f)+"("+NumLbl(f)+")";
     }
     else if (seltype(f,1)==1)  //  logistic
     {
       ParCount++; ParmLabel+="Size_inflection_"+fleetname(f)+"("+NumLbl(f)+")";
       ParCount++; ParmLabel+="Size_95%width_"+fleetname(f)+"("+NumLbl(f)+")";
     }
     else if (seltype(f,1)==11)
     {
       ParCount++; ParmLabel+="SizeSel=1_BinLo_"+fleetname(f)+"("+NumLbl(f)+")";
       ParCount++; ParmLabel+="SizeSel=1_BinHi_"+fleetname(f)+"("+NumLbl(f)+")";
     }
     
     else
     {
       for (j=1;j<=N_selparmvec(f);j++)
       {
         ParCount++; ParmLabel+="SizeSel_P"+NumLbl(j)+"_"+fleetname(f)+"("+NumLbl(f)+")";
       }
     }

     // account for the low and high bin parameters
     if(seltype(f,1) == 43) N_selparmvec(f)+=2;

     if(seltype(f,2)>=1)
     {
       if(WTage_rd>0)
       {
        N_warn++;  warning<<N_warn<<" "<<" BEWARE: Retention functions not implemented fully when reading empirical wt-at-age "<<endl;
       }
       Do_Retain(f)=1;
       if(fleet_type(f)==2 && seltype(f,2)!=3)
       {N_warn++;  warning<<N_warn<<" "<<" fleet: "<<f<<" is a bycatch fleet, so consider using retention option =3 so no parameters needed"<<endl;}
       if(seltype(f,2)==3)
       {RetainParm(f)=0;}  //  no parameters needed
       else
       {
         RetainParm(f)=N_selparmvec(f)+1;
//       N_selparmvec(f) +=N_ret_parm*seltype(f,2);          // N retention parms first [N_ret_parm] for retention; next [N_ret_parm] for discard mortality
         if(N_ret_parm(seltype(f,2))>0)
         {
           ParCount++; N_selparmvec(f)++;ParmLabel+="Retain_L_infl_"+fleetname(f)+"("+NumLbl(f)+")";
           ParCount++; N_selparmvec(f)++;ParmLabel+="Retain_L_width_"+fleetname(f)+"("+NumLbl(f)+")";
           ParCount++; N_selparmvec(f)++;ParmLabel+="Retain_L_asymptote_logit_"+fleetname(f)+"("+NumLbl(f)+")";
           ParCount++; N_selparmvec(f)++;ParmLabel+="Retain_L_maleoffset_"+fleetname(f)+"("+NumLbl(f)+")";
           if(N_ret_parm(seltype(f,2))==7)  //  doing dome
           {
             ParCount++; N_selparmvec(f)++;ParmLabel+="Retain_L_dome_infl_"+fleetname(f)+"("+NumLbl(f)+")";
             ParCount++; N_selparmvec(f)++;ParmLabel+="Retain_L_dome_width_"+fleetname(f)+"("+NumLbl(f)+")";
             ParCount++; N_selparmvec(f)++;ParmLabel+="Retain_L_dome_maleoffset_"+fleetname(f)+"("+NumLbl(f)+")";
           }
         }
         if(seltype(f,2)==2 || seltype(f,2)==4)
         {
           ParCount++; N_selparmvec(f)++; ParmLabel+="DiscMort_L_infl_"+fleetname(f)+"("+NumLbl(f)+")";
           ParCount++; N_selparmvec(f)++; ParmLabel+="DiscMort_L_width_"+fleetname(f)+"("+NumLbl(f)+")";
           ParCount++; N_selparmvec(f)++; ParmLabel+="DiscMort_L_level_old_"+fleetname(f)+"("+NumLbl(f)+")";
           ParCount++; N_selparmvec(f)++; ParmLabel+="DiscMort_L_male_offset_"+fleetname(f)+"("+NumLbl(f)+")";
         }
       }
     }
     else if (seltype(f,2)<0) //  mirror retention
     {
       Do_Retain(f)=1;
       RetainParm(f)=0;
     }
     if(seltype(f,3)>=1)
      {
        if(gender==1) {N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" "<<" Male selex cannot be used in one sex model; fleet: "<<f<<endl; exit(1);}
        Maleselparm(f)=N_selparmvec(f)+1;
        if(seltype(f,3)==1 || seltype(f,3)==2)
        {
          N_selparmvec(f)+=4;  // add male parms
          ParCount+=4;
          ParmLabel+="SzSel_MaleDogleg_"+fleetname(f)+"("+NumLbl(f)+")";
          ParmLabel+="SzSel_MaleatZero_"+fleetname(f)+"("+NumLbl(f)+")";
          ParmLabel+="SzSel_MaleatDogleg_"+fleetname(f)+"("+NumLbl(f)+")";
          ParmLabel+="SzSel_MaleatMaxage_"+fleetname(f)+"("+NumLbl(f)+")";
        }
        else if(seltype(f,3)>=3)
        {
          if(seltype(f,3)==3) {anystring="Male_";} else {anystring="Fem_";}
          if(seltype(f,1)==1)
          {
            N_selparmvec(f)++; ParCount++; ParmLabel+="SzSel_"+anystring+"Infl_"+fleetname(f)+"("+NumLbl(f)+")";
            N_selparmvec(f)++; ParCount++; ParmLabel+="SzSel_"+anystring+"Slope_"+fleetname(f)+"("+NumLbl(f)+")";
            N_selparmvec(f)++; ParCount++; ParmLabel+="SzSel_"+anystring+"Scale_"+fleetname(f)+"("+NumLbl(f)+")";
          }
          else if(seltype(f,1)==24 || seltype(f,1)==2)
          {
            N_selparmvec(f)++; ParCount++; ParmLabel+="SzSel_"+anystring+"Peak_"+fleetname(f)+"("+NumLbl(f)+")";
            N_selparmvec(f)++; ParCount++; ParmLabel+="SzSel_"+anystring+"Ascend_"+fleetname(f)+"("+NumLbl(f)+")";
            N_selparmvec(f)++; ParCount++; ParmLabel+="SzSel_"+anystring+"Descend_"+fleetname(f)+"("+NumLbl(f)+")";
            N_selparmvec(f)++; ParCount++; ParmLabel+="SzSel_"+anystring+"Final_"+fleetname(f)+"("+NumLbl(f)+")";
            N_selparmvec(f)++; ParCount++; ParmLabel+="SzSel_"+anystring+"Scale_"+fleetname(f)+"("+NumLbl(f)+")";
          }
          else
          {
            N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" "<<"Illegal male selex option selected for fleet "<<f<<endl;  exit(1);
          }
        }
      }

     if(seltype(f,1)==7) {N_warn++;  warning<<N_warn<<" "<<"ERROR:  selectivity pattern #7 is no longer supported "<<endl;}
     if(seltype(f,1)==23 && F_Method==1) {N_warn++;  warning<<N_warn<<" "<<"Do not use F_Method = Pope's with selex pattern #23 "<<endl;}
     N_selparm += N_selparmvec(f);
   }
   for (f=Nfleet+1;f<=2*Nfleet;f++)
   {
     int f1=f-Nfleet;  // actual fleet number
     if(seltype(f,1)==15) // mirror
     {
       if(seltype(f,4)==0 || seltype(f,4)>=f1)
       {
         N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" "<<" illegal mirror for age selex fleet "<<f-Nfleet<<endl; exit(1);
       }
       N_selparmvec(f)=0;   // Nunber of Age selex parms
     }
     else if(seltype(f,1)!=17 && seltype(f,1)!=41)
     {
       N_selparmvec(f)=seltype_Nparam(seltype(f,1));   // Nunber of Age selex parms
     }
     else if(seltype(f,4)==0)
     {
       N_selparmvec(f)=seltype_Nparam(seltype(f,1));   // this is nages+1
     }
     else
     {
       N_selparmvec(f)=abs(seltype(f,4))+1;   // so reads value for age 0 through this age
     }

     if(seltype(f,1)==41)
     {
         ParCount++; ParmLabel+="AgeSel_ScaleAgeLo_"+fleetname(f1)+"("+NumLbl(f1)+")";
         ParCount++; ParmLabel+="AgeSel_ScaleAgeHi_"+fleetname(f1)+"("+NumLbl(f1)+")";
     }

     if(seltype(f,1)==27 || seltype(f,1)==42)
     {
       if(seltype(f,1)==42)
       {
         ParCount++; ParmLabel+="AgeSpline_ScaleAgeLo_"+fleetname(f1)+"("+NumLbl(f1)+")";
         ParCount++; ParmLabel+="AgeSpline_ScaleAgeHi_"+fleetname(f1)+"("+NumLbl(f1)+")";
       }
       N_selparmvec(f)+=2*seltype(f,4);  // special setup of N parms for cubic spline
       ParCount++; ParmLabel+="AgeSpline_Code_"+fleetname(f1)+"_"+NumLbl(f1);
       ParCount++; ParmLabel+="AgeSpline_GradLo_"+fleetname(f1)+"_"+NumLbl(f1);
       ParCount++; ParmLabel+="AgeSpline_GradHi_"+fleetname(f1)+"_"+NumLbl(f1);
       for (s=1;s<=seltype(f,4);s++)
       {
         ParCount++; ParmLabel+="AgeSpline_Knot_"+NumLbl(s)+"_"+fleetname(f1)+"_"+NumLbl(f1);
       }
       for (s=1;s<=seltype(f,4);s++)
       {
         ParCount++; ParmLabel+="AgeSpline_Val_"+NumLbl(s)+"_"+fleetname(f1)+"_"+NumLbl(f1);
       }
     }
     else if(seltype(f,1)==44)
     {
       N_selparmvec(f)=2+gender+gender*seltype(f,4);
       ParCount++; ParmLabel+="first_selage_"+fleetname(f1)+"("+NumLbl(f1)+")";
       ParCount++; ParmLabel+="first_age_mean_"+fleetname(f1)+"("+NumLbl(f1)+")";
       ParCount++; ParmLabel+="last_age_mean_"+fleetname(f1)+"("+NumLbl(f1)+")";
       if(gender==2) 
       {
        ParCount++; ParmLabel+="Male_ln(ratio)_"+fleetname(f1)+"("+NumLbl(f1)+")";
        for(int gg=1;gg<=seltype(f,4);gg++)
        {ParCount++; ParmLabel+="female_ln(selchange)_"+NumLbl(gg)+"_"+fleetname(f1)+"("+NumLbl(f1)+")";}
        for(int gg=1;gg<=seltype(f,4);gg++)
        {ParCount++; ParmLabel+="male_ln(selchange)_"+NumLbl(gg)+"_"+fleetname(f1)+"("+NumLbl(f1)+")";}
      }
      else
      {
        for(int gg=1;gg<=seltype(f,4);gg++)
        {ParCount++; ParmLabel+="ln(selchange)_"+NumLbl(gg)+"_"+fleetname(f1)+"("+NumLbl(f1)+")";}
      }
     }
     else if(seltype(f,1)==45)
     {
       N_selparmvec(f)=2+gender+gender*seltype(f,4);
       ParCount++; ParmLabel+="first_selage_"+fleetname(f1)+"("+NumLbl(f1)+")";
       ParCount++; ParmLabel+="first_age_mean_"+fleetname(f1)+"("+NumLbl(f1)+")";
       ParCount++; ParmLabel+="last_age_mean_"+fleetname(f1)+"("+NumLbl(f1)+")";
       if(gender==2) 
       {
        ParCount++; ParmLabel+="Male_ln(ratio)_"+fleetname(f1)+"("+NumLbl(f1)+")";
        for(int gg=1;gg<=seltype(f,4);gg++)
        {ParCount++; ParmLabel+="female_sel_logit_"+NumLbl(gg)+"_"+fleetname(f1)+"("+NumLbl(f1)+")";}
        for(int gg=1;gg<=seltype(f,4);gg++)
        {ParCount++; ParmLabel+="male_sel_logit_"+NumLbl(gg)+"_"+fleetname(f1)+"("+NumLbl(f1)+")";}
      }
      else
      {
        for(int gg=1;gg<=seltype(f,4);gg++)
        {ParCount++; ParmLabel+="ln(selchange)_"+NumLbl(gg)+"_"+fleetname(f1)+"("+NumLbl(f1)+")";}
      }
     }

     else if (seltype(f,1)==20)
     {
       ParCount++; ParmLabel+="Age_DblN_peak_"+fleetname(f1)+"("+NumLbl(f1)+")";
       ParCount++; ParmLabel+="Age_DblN_top_logit_"+fleetname(f1)+"("+NumLbl(f1)+")";
       ParCount++; ParmLabel+="Age_DblN_ascend_se_"+fleetname(f1)+"("+NumLbl(f1)+")";
       ParCount++; ParmLabel+="Age_DblN_descend_se_"+fleetname(f1)+"("+NumLbl(f1)+")";
       ParCount++; ParmLabel+="Age_DblN_start_logit_"+fleetname(f1)+"("+NumLbl(f1)+")";
       ParCount++; ParmLabel+="Age_DblN_end_logit_"+fleetname(f1)+"("+NumLbl(f1)+")";
     }
     else if (seltype(f,1)==12)
     {
       ParCount++; ParmLabel+="Age_inflection_"+fleetname(f1)+"("+NumLbl(f1)+")";
       ParCount++; ParmLabel+="Age_95%width_"+fleetname(f1)+"("+NumLbl(f1)+")";
     }
     else if (seltype(f,1)==11)
     {
       ParCount++; ParmLabel+="minage@sel=1_"+fleetname(f1)+"("+NumLbl(f1)+")";
       ParCount++; ParmLabel+="maxage@sel=1_"+fleetname(f1)+"("+NumLbl(f1)+")";
     }
     else
     {
       for (j=1;j<=N_selparmvec(f);j++)
       {
         ParCount++; ParmLabel+="AgeSel_P"+NumLbl(j)+"_"+fleetname(f1)+"("+NumLbl(f1)+")";
       }
     }

//  age-specific retention function
     if(seltype(f,2)>=1)
     {
       Do_Retain(f1)=2;
       if(WTage_rd>0)
       {
        N_warn++;  warning<<N_warn<<" "<<" BEWARE: Retention functions not implemented fully when reading empirical wt-at-age "<<endl;
       }
       if(seltype(f1,2)>0)
        {
          N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" "<<" ERROR:  cannot have both age and size retention functions "<<f<<"  but retention parms not setup "<<endl; exit(1);
        }
       if(seltype(f,2)==3)
       {RetainParm(f1)=0;}  //  no parameters needed
       else
       {
         RetainParm(f1)=N_selparmvec(f)+1;
//         N_selparmvec(f) +=N_ret_parm*seltype(f,2);          // N retention parms first [N_ret_parm] for retention; next [N_ret_parm] for discard mortality
//         for (j=1;j<=N_ret_parm(seltype(f,2));j++)
//         {
//           ParCount++; N_selparmvec(f)++; ParmLabel+="Retain_age_P"+NumLbl(j)+"_"+fleetname(f1)+"("+NumLbl(f1)+")";
//         }
       if(N_ret_parm(seltype(f,2))>0)
       {
         ParCount++; N_selparmvec(f)++;ParmLabel+="Retain_A_infl_"+fleetname(f1)+"("+NumLbl(f1)+")";
         ParCount++; N_selparmvec(f)++;ParmLabel+="Retain_A_width_"+fleetname(f1)+"("+NumLbl(f1)+")";
         ParCount++; N_selparmvec(f)++;ParmLabel+="Retain_A_asymptote_logit_"+fleetname(f1)+"("+NumLbl(f1)+")";
         ParCount++; N_selparmvec(f)++;ParmLabel+="Retain_A_maleoffset_"+fleetname(f1)+"("+NumLbl(f1)+")";
         if(N_ret_parm(seltype(f,2))==7)  //  doing dome
         {
           ParCount++; N_selparmvec(f)++;ParmLabel+="Retain_A_dome_infl_"+fleetname(f1)+"("+NumLbl(f1)+")";
           ParCount++; N_selparmvec(f)++;ParmLabel+="Retain_A_dome_width_"+fleetname(f1)+"("+NumLbl(f1)+")";
           ParCount++; N_selparmvec(f)++;ParmLabel+="Retain_A_dome_maleoffset_"+fleetname(f1)+"("+NumLbl(f1)+")";
         }
       }

         if(seltype(f,2)==2 || seltype(f,2)==4)
         {
           ParCount++; N_selparmvec(f)++; ParmLabel+="DiscMort_A_infl_"+fleetname(f1)+"("+NumLbl(f1)+")";
           ParCount++; N_selparmvec(f)++; ParmLabel+="DiscMort_A_width_"+fleetname(f1)+"("+NumLbl(f1)+")";
           ParCount++; N_selparmvec(f)++; ParmLabel+="DiscMort_A_level_old_"+fleetname(f1)+"("+NumLbl(f1)+")";
           ParCount++; N_selparmvec(f)++; ParmLabel+="DiscMort_A_male_offset_"+fleetname(f1)+"("+NumLbl(f1)+")";
         }
       }
     }
     else if (seltype(f,2)<0) //  mirror retention
     {
       Do_Retain(f1)=2;
       RetainParm(f1)=0;
     }

     if(seltype(f,3)>=1)
      {
        if(gender==1) {N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" "<<" Male selex cannot be used in one sex model; fleet: "<<f<<endl; exit(1);}
        Maleselparm(f)=N_selparmvec(f)+1;
        if(seltype(f,3)==1 || seltype(f,3)==2)
        {
          N_selparmvec(f)++; ParCount++; ParmLabel+="AgeSel_"+NumLbl(f1)+"MaleDogleg_"+fleetname(f1);
          N_selparmvec(f)++; ParCount++; ParmLabel+="AgeSel_"+NumLbl(f1)+"MaleatZero_"+fleetname(f1);
          N_selparmvec(f)++; ParCount++; ParmLabel+="AgeSel_"+NumLbl(f1)+"MaleatDogleg_"+fleetname(f1);
          N_selparmvec(f)++; ParCount++; ParmLabel+="AgeSel_"+NumLbl(f1)+"MaleatMaxage_"+fleetname(f1);
        }
        else if(seltype(f,3)>=3 && seltype(f,1)==20)
        {
          if(seltype(f,3)==3) {anystring="Male_";} else {anystring="Fem_";}
          N_selparmvec(f)++; ParCount++; ParmLabel+="AgeSel_"+NumLbl(f1)+anystring+"Peak_"+fleetname(f1);
          N_selparmvec(f)++; ParCount++; ParmLabel+="AgeSel_"+NumLbl(f1)+anystring+"Ascend_"+fleetname(f1);
          N_selparmvec(f)++; ParCount++; ParmLabel+="AgeSel_"+NumLbl(f1)+anystring+"Descend_"+fleetname(f1);
          N_selparmvec(f)++; ParCount++; ParmLabel+="AgeSel_"+NumLbl(f1)+anystring+"Final_"+fleetname(f1);
          N_selparmvec(f)++; ParCount++; ParmLabel+="AgeSel_"+NumLbl(f1)+anystring+"Scale_"+fleetname(f1);
        }
        else
        {
          N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" "<<"Illegal male selex option selected for fleet "<<f<<endl;  exit(1);
        }
      }
     N_selparm += N_selparmvec(f);
   }
   
//  create index to fleets with discard
  disc_fleet_list.initialize();
  N_retain_fleets=0;
  for(f=1;f<=Nfleet;f++)
  {
    if(Do_Retain(f)>0)
      {
        N_retain_fleets++;
        disc_fleet_list(f)=N_retain_fleets;  //  for compact storage of disc_age(t,f,g)
      } 
  }
  
//  SS_Label_Info_4.097 #Read parameters needed for estimating variance of composition data
  {
    echoinput<<"#Now count parameters for variance of composition data; CANNOT be time-varying"<<endl;
    if(Comp_Err_ParmCount>0)
    {
      echoinput<<Comp_Err_ParmCount<<"  #_parameters are needed"<<endl;
      Comp_Err_Parm_Start=N_selparm;
      for(f=1;f<=Comp_Err_ParmCount;f++)
        {N_selparm++; ParCount++; ParmLabel+="ln(DM_theta)_"+NumLbl(f);}
    }
  }

   for (f=1;f<=Nfleet;f++)
     {
     if(disc_N_fleet(f)>0 && seltype(f,2)==0 && seltype(f+Nfleet,2)==0)
       {N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" "<<" ERROR:  discard data exist for fleet "<<f<<"  but retention parms not setup "<<endl; exit(1);}
     else if (disc_N_fleet(f)==0 && seltype(f,2)>0)
       {N_warn++;  warning<<N_warn<<" "<<" WARNING:  no discard amount data for fleet "<<f<<"  but retention parms have been defined "<<endl;}
     }
 END_CALCS

!!//  SS_Label_Info_4.9.3 #Read selex parameters
  init_matrix selparm_1(1,N_selparm,1,14)
  ivector selparm_fleet(1,N_selparm) // holds the fleet ID for each selparm
                                  //  equivalent to the mgp_type() for MGparms
  matrix mirror_mask(1,Nfleet,1,nlength)
  matrix mirror_mask_a(1,Nfleet,0,nages)
 LOCAL_CALCS
  mirror_mask.initialize();
  mirror_mask_a.initialize();
  echoinput<<" selex and composition base parameters "<<endl;
  for (g=1;g<=N_selparm;g++)
  {
    echoinput<<g<<" ## "<<selparm_1(g)<<" ## "<<ParmLabel(ParCount-N_selparm+g)<<endl;
  }

  //  now identify the fleet associated with each parameter
  echoinput<<"identify the fleet associated with each parameter"<<endl;
  j=0;
  for(f=1;f<=2*Nfleet;f++)
  {
    if(N_selparmvec(f)>0)
    {
      for(g=1;g<=N_selparmvec(f);g++)
      {
        j++; selparm_fleet(j)=f;
      }
    }
  }
  if(Comp_Err_ParmCount>0)
  {
  	echoinput<<"comp_error parameters"<<endl<<"L_type: "<<Comp_Err_L<<endl<<"L_parm: "<<Comp_Err_L2<<endl<<"A_type: "<<Comp_Err_A<<endl<<"A_parm: "<<Comp_Err_A2<<endl;
   for (f = 1; f <= Nfleet; f++)
   {
      // if Dirichlet was indicated, set fleet for this parameter
      if (Comp_Err_L(f) >0 && Comp_Err_L2(f) > 0)
      {
        j = Comp_Err_Parm_Start + Comp_Err_L2(f);
        selparm_fleet(j)=f;
      }

      if (Comp_Err_A(f) >0 && Comp_Err_A2(f) > 0)
      {
        j = Comp_Err_Parm_Start + Comp_Err_A2(f);
        selparm_fleet(j)=f;
      }
   }
  }

//  check on conversion of retention parameter
  echoinput<<"check on conversion of retention parameter"<<endl;
  int parmcount;
  int new_lower_bound;
  int new_upper_bound;
  parmcount=0;
  for(f=1;f<=Nfleet;f++)
  {
    if(RetainParm(f)>0)  //  could point to length or age retention
    {
      k=parmcount+RetainParm(f)+2;
      if(selparm_1(k,1) >=0.0)  // check to see if user has bounds relevant for 3.24 format
        {
          N_warn++; 
           warning<<N_warn<<" "<<"converting asymptotic retention parameter to 1/(1+e(-x)) format for fleet: "<<f<<" parm: "<<k<<endl;
           warning<<N_warn<<" "<<"old min, max, init, prior: "<<selparm_1(k)(1,4)<<endl;
          echoinput<<"converting asymptotic retention parameter to 1/(1+e(-x)) format for fleet: "<<f<<" parm: "<<k<<endl;
          echoinput<<"because parm min was >=0.0"<<endl;
          new_lower_bound=-10.;
          new_upper_bound=10.;

          // check initial value against lower and upper bounds first
          if (selparm_1(k,3) <= selparm_1(k,1))
          {
            selparm_1(k,3) = new_lower_bound;
          }
          else if (selparm_1(k,3) >= selparm_1(k,2))
          {
            selparm_1(k,3) = new_upper_bound;
          }
          else if(selparm_1(k,3)>0.)
          {
            if(selparm_1(k,3)<1.0)
            {selparm_1(k,3)=-log(1.0/selparm_1(k,3)-1.0);}
            else
            {selparm_1(k,3)=999.;}  //  hardwire to force to be 1.0
          }
          else
          {selparm_1(k,3)=-999.;}  //  hardwire to force to 0.0

          // check prior value against lower and upper bounds first
          if (selparm_1(k,4) <= selparm_1(k,1))
          {
            selparm_1(k,4) = new_lower_bound;
          }
          else if (selparm_1(k,4) >= selparm_1(k,2))
          {
            selparm_1(k,4) = new_upper_bound;
          }
          else if(selparm_1(k,4)>0.)
          {
            if(selparm_1(k,4)<1.0)
            {selparm_1(k,4)=-log(1.0/selparm_1(k,4)-1.0);}
            else
            {selparm_1(k,4)=999.;}  //  hardwire to force to be 1.0
          }
          else
          {selparm_1(k,4)=-999.;}  //  hardwire to force to 0.0

          selparm_1(k,1)=new_lower_bound;
          selparm_1(k,2)=new_upper_bound;

           warning<<N_warn<<" "<<"new min, max, init, prior: "<<selparm_1(k)(1,4)<<endl;
//          if (selparm_1(k,8) !=0 || selparm_1(k,9)!=0 || selparm_1(k,13)!=0)  warning<<N_warn<<" "<<"Timevarying, so you must do timevary parm conversion manually"<<endl;
        }
    }
    parmcount+=N_selparmvec(f);
  }

//  check on mirror bounds
  parmcount=0;
  for(f=1;f<=Nfleet;f++)
  { 
  	if(seltype(f,1)==5)  //  uses mirror
  		{
        i=int(selparm_1(parmcount+1,3));
        j=int(selparm_1(parmcount+2,3));
        echoinput<<"check on size selex mirror bounds for fleet: "<<f<<" "<<endl;
        if(i<=-1) {i=1;} // legit input, use to set mirror_mask
        else if(i==0) {echoinput<<" size selex mirror, length range min bin read is ("<<i<<") reset to 1 for fleet: "<<f<<endl;selparm_1(parmcount+1,3)=1;i=1;}
        if(j<=-1) {j=nlength;}// legit input, use to set mirror_mask
        else if(j==0) {echoinput<<" size selex mirror, length range max bin read is ("<<j<<") reset to nlength for fleet: "<<f<<endl;selparm_1(parmcount+2,3)=-1;j=nlength;}
        if(j>nlength) {N_warn++;  warning<<N_warn<<" "<<" size selex mirror length is > nlength for fleet: "<<f<<" reset to nlength"<<endl;selparm_1(parmcount+2,3)=-1;j=nlength;}
        if(i>j) {N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" "<<" Critical error, size selex mirror length range min ("<<i<<") greater than max ("<<j<<") for fleet: "<<f<<endl; exit(1);}
        if(j>nlength) {N_warn++;  warning<<N_warn<<" "<<" size selex mirror length is > nlength for fleet: "<<f<<" reset to nlength"<<endl;selparm_1(parmcount+2,3)=nlength;j=nlength;}
        if(i>j) {N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" "<<" Critical error, size selex mirror length range min ("<<i<<") greater than max ("<<j<<") for fleet: "<<f<<endl; exit(1);}
        mirror_mask(f)=1.0e-10;
        mirror_mask(f)(i,j)=1.;
        echoinput<<"fleet: "<<f<<"  set mirror for bins: "<<i<<" through "<<j<<endl;
        echoinput<<"set to no prior and not estimated, just in case "<<endl;
        selparm_1(parmcount+1,6)=0;
        selparm_1(parmcount+2,6)=0;
        selparm_1(parmcount+1,7)=-99;
        selparm_1(parmcount+2,7)=-99;
		echoinput<<"end check on mirror mask:  "<<endl;
  		}
    else if(seltype(f,1)==11) // setting min-max len range
		{
        echoinput<<"check on size selex min-max for fleet: "<<f<<" "<<selparm_1(parmcount+1,3)<<" "<<selparm_1(parmcount+2,3)<<" nsize bins: "<<nlength<<endl;
        i=int(selparm_1(parmcount+1,3));
        j=int(selparm_1(parmcount+2,3));
        if((selparm_1(parmcount+1,3)-i)>0.)
        	{
        		N_warn++; warning<<N_warn<<" "<<"fleet: "<<f<<" size selex range min read is: "<<selparm_1(parmcount+1,3)<<"; SS expected an integer and will convert "<<endl; selparm_1(parmcount+1,3)=i;
        	}
        if((selparm_1(parmcount+2,3)-j)>0.)
        	{
        		N_warn++; warning<<N_warn<<" "<<"fleet: "<<f<<" size selex range max read is: "<<selparm_1(parmcount+2,3)<<"; SS expected an integer and will convert "<<endl; selparm_1(parmcount+2,3)=j;
        	}
        if(selparm_1(parmcount+2,3)>nlength)
        	{
        		N_warn++; warning<<N_warn<<" "<<"fleet: "<<f<<" size selex range max read is: "<<selparm_1(parmcount+2,3)<<"; is >nsizes; SS will convert "<<endl; selparm_1(parmcount+2,3)=nlength;
        	}
       	echoinput<<" accepted range: "<<selparm_1(parmcount+1,3)<<" "<<selparm_1(parmcount+2,3)<<endl;
        echoinput<<"set to no prior and not estimated, just in case "<<endl;
        selparm_1(parmcount+1,6)=0;
        selparm_1(parmcount+2,6)=0;
        selparm_1(parmcount+1,7)=-99;
        selparm_1(parmcount+2,7)=-99;
        mirror_mask(f)=1.0e-10;
        mirror_mask(f)(selparm_1(parmcount+1,3),selparm_1(parmcount+2,3))=1.0;
       	echoinput<<"create mirror_mask: "<<mirror_mask(f)<<endl;
			echoinput<<"end check on min-max ranges for size selex=11"<<endl;
  		}
		
    parmcount+=N_selparmvec(f);
  }
  for(f=1;f<=Nfleet;f++)
  { 
  	if(seltype(f+Nfleet,1)==11)  //  setting min-max age range
  		{
        echoinput<<"check on age selex min-max for fleet: "<<f<<" "<<selparm_1(parmcount+1,3)<<" "<<selparm_1(parmcount+2,3)<<" nages: "<<nages<<endl;
        i=int(selparm_1(parmcount+1,3));
        j=int(selparm_1(parmcount+2,3));
        echoinput<<"set to no prior and not estimated, just in case "<<endl;
        selparm_1(parmcount+1,6)=0;
        selparm_1(parmcount+2,6)=0;
        selparm_1(parmcount+1,7)=-99;
        selparm_1(parmcount+2,7)=-99;
        if((selparm_1(parmcount+1,3)-i)>0.)
        	{
        		N_warn++; warning<<N_warn<<" "<<"fleet: "<<f<<" age selex range min read is: "<<selparm_1(parmcount+1,3)<<"; SS expected an integer and will convert "<<endl; selparm_1(parmcount+1,3)=i;
        	}
        if((selparm_1(parmcount+2,3)-j)>0.)
        	{
        		N_warn++; warning<<N_warn<<" "<<"fleet: "<<f<<" age selex range max read is: "<<selparm_1(parmcount+2,3)<<"; SS expected an integer and will convert "<<endl; selparm_1(parmcount+2,3)=j;
        	}
        if(selparm_1(parmcount+2,3)>nages)
        	{
        		N_warn++; warning<<N_warn<<" "<<"fleet: "<<f<<" age selex range max read is: "<<selparm_1(parmcount+2,3)<<"; is >nages; SS will convert "<<endl; selparm_1(parmcount+2,3)=nages;
        	}
        	echoinput<<" accepted range: "<<selparm_1(parmcount+1,3)<<" "<<selparm_1(parmcount+2,3)<<endl;
			mirror_mask_a(f)=0;
        	mirror_mask_a(f)(selparm_1(parmcount+1,3),selparm_1(parmcount+2,3))=1.0;
        	echoinput<<"create mirror_mask: "<<mirror_mask_a(f)<<endl;
			echoinput<<"end check on min-max ranges for age selex=11"<<endl;
  		}
    parmcount+=N_selparmvec(f+Nfleet);
  }

 END_CALCS

  int timevary_parm_cnt_sel;
  int timevary_parm_start_sel;
  ivector selparm_timevary(1,N_selparm)  //  holds index of timevary used by this base parameter
  imatrix timevary_sel(styr-3,YrMax+1,1,2*Nfleet)
  int TwoD_AR_do;
  int TwoD_AR_cnt
  int makefishsel_yr
  ivector TwoD_AR_use(1,2*Nfleet);

 LOCAL_CALCS
  timevary_parm_start_sel=0;
  timevary_parm_cnt_sel=0;
  timevary_sel.initialize();
  selparm_timevary.initialize();
  TwoD_AR_use.initialize();
  timevary_used=0;
  for (j=1;j<=N_selparm;j++)
  {
  	echoinput<<j<<" sel "<<selparm_1(j)<<endl;
     k=selparm_fleet(j);
     timevary_pass=column(timevary_sel,k);  // year vector for this category of selparm
     if(selparm_1(j,13)==0 && selparm_1(j,8)==0 && selparm_1(j,9)==0)
     {
      //  no time-vary parameter effects
     }
     else if (k==0)
     {
       N_warn++;  warning<<N_warn<<" "<<"Comp_err parameters cannot have timevary effects "<<endl;
     }
     else  //  set up a timevary parameter defintion
     {
     	 timevary_used=1;
       ivector timevary_setup(1,14);  //  temporary vector for timevary specs
       timevary_setup.initialize();
       if(timevary_parm_start_sel==0) timevary_parm_start_sel=timevary_parm_cnt+1;
       echoinput<<endl<<" timevary for sel parameter: "<<j<<endl;
       timevary_cnt++;  //  count parameters with time-vary effect
       selparm_timevary(j)=timevary_cnt;  //  base parameter will use this timevary specification
       timevary_setup(1)=5; //  indicates a sel parm
       timevary_setup(2)=j; //  index of base parm within that type of parameter
       timevary_setup(13)=firstselparm+j;  //  index of base parm relative to ParCount which is continuous across all types of parameters
       timevary_setup(3)=timevary_parm_cnt+1;  //  first TV parameter within total list of all timevary parms
       z=selparm_1(j,13);    // specified block or trend definition

       k=int(abs(selparm_1(j,8))/100);  //  find the env link code
       timevary_setup(6)=k;  //  link code for env
       if(selparm_1(j,8)>0)  //  env variable used
       {
         timevary_setup(7)=int(abs(selparm_1(j,8)))-k*100;
         k=timevary_setup(7);
//         for(y=styr-1;y<=YrMax;y++) env_data_pass(y)=env_data_RD(y,k);
         env_data_pass(1)=env_data_minyr(k);
         env_data_pass(2)=env_data_maxyr(k);
       }
       else  //  density-dependence
       {
         timevary_setup(7)=-int(abs(selparm_1(j,8))-k*100);
         do_densitydependent=1;
         k=0; env_data_pass.initialize();
       }
       if(z>0)  //  doing blocks
       {
         if(z>N_Block_Designs)
          {N_warn++; cout<<"Fatal_input_error, see warning"<<endl;  warning<<N_warn<<" "<<" error: selex block request exceeds N_block patterns"<<endl;  exit(1);}
         create_timevary(selparm_1(j),timevary_setup, timevary_pass, autogen_timevary(timevary_setup(1)), selparm_fleet(j), Block_Design(z), parm_adjust_method, env_data_pass, N_parm_dev,finish_starter);
       }
       else
       {
         create_timevary(selparm_1(j),timevary_setup, timevary_pass, autogen_timevary(timevary_setup(1)), selparm_fleet(j), block_design_null, parm_adjust_method, env_data_pass, N_parm_dev,finish_starter);
       }
  /*
   where:
   selparm_1(j):           vector with the base parameter which has some type of timevary characteristic
   timevary_setup:        vector which contains specs of all types of timevary  for this base parameter
                          will be pushed to timevary_def cumulative across all types of base parameters
   timevary_pass:        vector containing column(timevary_MG,mgp_type(j)), will be modified in create_timevary
   autogen_timevary:      switch to autogenerate or not
   selparm_fleet(j):           integer with type of MGparm being worked on; analogous to 2*fleet in the selectivity section
   block_design(z):       block design, if any, being used
   parm_adjust_method:    switch to determine if adjusted parameter will stay in bounds; used to create warnings in create_timevary
   env_data_RD:           matrix containing entire set of environmental data as read
   N_parm_dev:            integer that is incremented in create_timevary as dev vectors are created; cumulative across all types of parameters
  */
       timevary_def.push_back (timevary_setup(1,14));
       for(y=styr-3;y<=YrMax+1;y++) {timevary_sel(y,selparm_fleet(j))=timevary_pass(y);}  // year vector for this category
     }
  }

   timevary_setup.initialize();
   timevary_setup(3)=timevary_parm_cnt+1;  //  one past last one used
   timevary_def.push_back (timevary_setup(1,14));

   N_selparm3=N_selparm;
   if(timevary_parm_start_sel>0)
   {
     if(timevary_used==1) autogen_timevary(5)=1;  //  indicate that some parameter is time-varying
     timevary_parm_cnt_sel=timevary_parm_cnt;  //  last timevary_selparm
     N_selparm3=N_selparm+timevary_parm_cnt_sel-timevary_parm_start_sel+1;
   }
   N_selparm2=N_selparm3;  //  for distinguishing the 2D_AR parms

//  now add parameters for the 2D_AR1 approach
//  Input in first parameter line several setup factors:  rho_y, rho_a, ymin, ymax, amin, amax, use_rho, sigma_amax, null9, null10, null11, null12, null13,null14
//  then one to several parameter lines containing age-specific sigma for ages amin to sigma_amax
//  note that parm_dev_minyr and parm_dev_maxyr need to map onto the matrix defined by  ymin, ymax, amin, amax,
  TwoD_AR_cnt=0;
  echoinput<<" now read 0/1 for 2D_AR"<<endl;
  *(ad_comm::global_datafile) >> TwoD_AR_do;
  echoinput<<TwoD_AR_do<<"  #_ 0/1 to request experimental 2D_AR selectivity smoother options  "<<endl;
  

  if(TwoD_AR_do>0)
  {
    N_warn++;  warning<<N_warn<<" "<<"The experimental 2D_AR selectivity smoother option is selected!"<<endl;
    ivector tempvec(1,13);  //  fleet, ymin, ymax, amin, amax, sigma_amax, use_rho, age/len
    tempvec.initialize();
    TwoD_AR_def.push_back (tempvec);  //  bypass that pesky zeroth row
    TwoD_AR_def_rd.push_back (tempvec);  //  bypass that pesky zeroth row
    echoinput<<"read specification for first 2D_AR1:  fleet, ymin, ymax, amin, amax, sigma_amax, use_rho, len1/age2"<<endl;

    ender=0;
    do
    {
      ivector tempvec(1,13);
      ivector tempvec2(1,13);
      //  1-fleet, 2-ymin, 3-ymax, 4-amin, 5-amax, 6-sigma_amax, 7-use_rho, 8-age/len, 9-dev_phase
      //  10-before yr range, 11=after yr range, 12-N_parm_dev,  13-selparm_location
      tempvec.initialize();
      tempvec2.initialize();
      *(ad_comm::global_datafile) >> tempvec(1,11);
      tempvec2=tempvec;
      echoinput<<tempvec(1,11)<<endl;
      f=tempvec(1);
      if(f<0)
        {ender=1;}
        else
        {
        N_parm_dev++;
        TwoD_AR_cnt++;
        if(tempvec(8)==1)
        {anystring="LEN"; fs=f; TwoD_AR_use(fs)=TwoD_AR_cnt;}
        else
        {anystring="AGE"; fs=f+Nfleet; TwoD_AR_use(fs)=TwoD_AR_cnt;}

//         save_sigmaval=tempvec(6);  //  to restore into TwoD_AR_def_rd later
         if(tempvec(6)<tempvec(4)) tempvec(6)=tempvec(4);
         if(tempvec(6)>tempvec(5)) tempvec(6)=tempvec(5);
         int sigma_amax = tempvec(6);
         int use_rho = tempvec(7);
         int amin = tempvec(4);

         TwoD_AR_def_rd.push_back (tempvec2);  //  saves the values as read for writing to control.ss_new

         tempvec(12)=N_parm_dev;
//         apply two lines below later when the timevary_setup is created
//         tempvec(10)=1;  //  used for dimensioning the dev vectors in SS_param   parm_dev_minyr(k)
//         tempvec(11)=(tempvec(3)-tempvec(2)+1)*(tempvec(5)-amin+1);   //parm_dev_maxyr(k)
         tempvec(13)=N_selparm2+1;
         z=f;
         if(tempvec(8)==2) z=f+Nfleet;
         for(y=tempvec(2);y<=tempvec(3)+1;y++)  {timevary_sel(y,z)=1;}
         TwoD_AR_def.push_back (tempvec);
         
         for(j=amin;j<=sigma_amax;j++)
         {
           dvector dtempvec(1,7);  //  Lo, Hi, init, prior, prior_sd, prior_type, phase;
           dtempvec.initialize();
           *(ad_comm::global_datafile) >> dtempvec(1,7);
           timevary_parm_rd.push_back (dtempvec);
           echoinput<<" sigmasel for "<<anystring<<" "<<j<<" "<<dtempvec(3)<<endl;
           if(timevary_parm_start_sel==0) {timevary_parm_start_sel=timevary_parm_cnt+1; timevary_parm_cnt_sel=timevary_parm_cnt;}
           ParCount++; timevary_parm_cnt++; timevary_parm_cnt_sel++; N_selparm2++;
           ParmLabel+="sigmasel_"+fleetname(f)+"("+NumLbl(f)+")_"+anystring+"("+NumLbl(max(1,j))+")";
         }
         if(use_rho==1)
         {
           {
           dvector dtempvec(1,7);  //  Lo, Hi, init, prior, prior_sd, prior_type, phase;
           dtempvec.initialize();
           *(ad_comm::global_datafile) >> dtempvec(1,7);
           timevary_parm_rd.push_back (dtempvec);
           echoinput<<" rho year: "<<dtempvec(3)<<endl;
           ParCount++; timevary_parm_cnt++; timevary_parm_cnt_sel++; N_selparm2++; 
           ParmLabel+="rho_yr_"+fleetname(f)+"("+NumLbl(f)+")_"+anystring;
           }
           {
           dvector dtempvec(1,7);  //  Lo, Hi, init, prior, prior_sd, prior_type, phase;
           dtempvec.initialize();
           *(ad_comm::global_datafile) >> dtempvec(1,7);
           timevary_parm_rd.push_back (dtempvec);
           echoinput<<" rho "<<anystring<<": "<<dtempvec(3)<<endl;
           ParCount++; timevary_parm_cnt++; timevary_parm_cnt_sel++; N_selparm2++; 
           ParmLabel+="rho_"+fleetname(f)+"("+NumLbl(f)+")"+anystring;
          }
         }
        }
    } while(ender==0);
  }
   echoinput<<"N_selparm: "<<N_selparm<<" with timevary: "<<N_selparm3<<" with TV and 2D_AR: "<<
   N_selparm2<<" timevary parm range for sel: "<<timevary_parm_start_sel<<" "<<timevary_parm_cnt_sel<<" "<<timevary_parm_cnt<<endl;

   if(timevary_parm_cnt>0)
   {
     echoinput<<"list all parms used for timevary implementation"<<endl;
     for(y=1;y<=timevary_parm_cnt;y++)
     {
     echoinput<<y<<" parm "<<timevary_parm_rd[y](1,7)<<endl;}
   }
 END_CALCS

!!//  SS_Label_Info_4.9.9 #Create arrays for the total set of selex parameters
  vector selparm_LO(1,N_selparm2)
  vector selparm_HI(1,N_selparm2)
  vector selparm_RD(1,N_selparm2)
  vector selparm_PR(1,N_selparm2)
  vector selparm_PRtype(1,N_selparm2)
  vector selparm_CV(1,N_selparm2)
  ivector selparm_PH(1,N_selparm2)
  ivector selparm_PH_soft(1,N_selparm2)

 LOCAL_CALCS
//  SS_Label_Info_4.9.12 #Create vectors, e.g. selparm_PH(), that will be used to create actual array of estimted parameters
   for (f=1;f<=N_selparm;f++)
   {
    selparm_LO(f)=selparm_1(f,1);
    selparm_HI(f)=selparm_1(f,2);
    selparm_RD(f)=selparm_1(f,3);
    selparm_PR(f)=selparm_1(f,4);
    selparm_PRtype(f)=selparm_1(f,6);
    selparm_CV(f)=selparm_1(f,5);
    selparm_PH(f)=selparm_1(f,7);
   }
   j=N_selparm;
   if(timevary_parm_start_sel>0)
   {
     for (f=timevary_parm_start_sel;f<=timevary_parm_cnt_sel;f++)
     {
      j++;
      selparm_LO(j)=timevary_parm_rd[f](1);
      selparm_HI(j)=timevary_parm_rd[f](2);
      selparm_RD(j)=timevary_parm_rd[f](3);
      selparm_PR(j)=timevary_parm_rd[f](4);
      selparm_PRtype(j)=timevary_parm_rd[f](6);
      selparm_CV(j)=timevary_parm_rd[f](5);
      selparm_PH(j)=timevary_parm_rd[f](7);
     }
   }

//  SS_Label_Info_4.9.10 #Special bound checking for size selex parameters
    z=0;  // parameter counter within this section
    for (f=1;f<=Nfleet;f++)
    {
      if(seltype(f,1)==8 || seltype(f,1)==22 || seltype(f,1)==23 || seltype(f,1)==24 || seltype(f,1)==2)
      {
        if(selparm_1(z+1,1)<len_bins_m(2))
        {N_warn++;
           warning<<N_warn<<" "<<"Fleet:_"<<f<<" min bound on parameter for size at peak is "<<selparm_1(z+1,1)<<"; should be >= midsize bin 2 ("<<len_bins_m(2)<<")"<<endl;}
        if(selparm_1(z+1,1)<len_bins_dat(1) && (seltype(f,1)==24 || seltype(f,1)==2))
        {N_warn++;
           warning<<N_warn<<" "<<"Fleet:_"<<f<<" min bound on parameter for size at peak is "<<selparm_1(z+1,1)<<"; which is < min databin ("<<len_bins_dat(1)<<"), so illogical."<<endl;}
        if(selparm_1(z+1,2)>len_bins_m(nlength-1))
        {N_warn++;
           warning<<N_warn<<" "<<"Fleet:_"<<f<<" max bound on parameter for size at peak is "<<selparm_1(z+1,2)<<"; should be <= midsize bin N-1 ("<<len_bins_m(nlength-1)<<")"<<endl;}
      }
      z+=N_selparmvec(f);
    }
// end special bound checking

//  SS_Label_Info_4.9.11  #Create time/fleet array indicating when changes in selex occcur
  timevary_sel(styr-3)=1;
  timevary_sel(styr)=1;
  timevary_sel(endyr+1)=1;

  for (y=styr+1;y<=endyr;y++)
  {
    z=0;  // parameter counter within this section
    for (f=1;f<=2*Nfleet;f++)
    {
      if(seltype(f,1)==5 || seltype(f,1)==15)   // mirror
      {
        if(f<=Nfleet) {timevary_sel(y,f)=timevary_sel(y,seltype(f,4));} else {timevary_sel(y,f)=timevary_sel(y,seltype(f,4)+Nfleet);}
        z+=seltype_Nparam(seltype(f,1));
      }
      if(f<=Nfleet && seltype(f,2)<0)  //  retention is being mirrored
      {
        k=-seltype(f,2);
        if(timevary_sel(y,k)>0) timevary_sel(y,f)=1;
      }
      if(f<=Nfleet)
      {
//  CHECK:  why is below needed for WTage_rd>0
        if(timevary_MG(y,2)>0 || timevary_MG(y,3)>0 || WTage_rd>0)
        {
          timevary_sel(y,f)=1;
        }
      }
    }  // end type

  } // end years
  echoinput<<"Recalc_flag_for_length_selex_recalc_by_year"<<endl;
  for (f=1;f<=Nfleet;f++)
  {
  	echoinput<<f<<" "<<fleetname(f)<<" "<<column(timevary_sel,f)<<endl;
  }
  echoinput<<"Recalc_flag_for_age_selex_recalc_by_year"<<endl;
  for (f=1;f<=Nfleet;f++)
  {
  	int f2=f+Nfleet;
  	echoinput<<f<<" "<<fleetname(f)<<" "<<column(timevary_sel,f2)<<endl;
  }

 END_CALCS

!!//  SS_Label_Info_4.10 #Read tag recapture parameter setup
// if Tags are used, the read parameters for initial tag loss, chronic tag loss, andd
// fleet-specific tag reporting.  Of these, only reporting rate will be allowed to be time-varying
  init_int TG_custom;  // 1=read; 0=create default parameters
  !! echoinput<<TG_custom<<" TG_custom (need to read even if no tag data ); tag_data?: "<<Do_TG<<" N_Fleet: "<<Nfleet1<<endl;
  !! k=TG_custom*Do_TG*(3*N_TG+2*Nfleet1);
  !! 
  init_matrix TG_parm1(1,k,1,14);  // read initial values
  !! if(k>0) echoinput<<" Tag parameters as read "<<endl<<TG_parm1<<endl;
  !! k=Do_TG*(3*N_TG+2*Nfleet1);
  matrix TG_parm2(1,k,1,14);
  !!if(Do_TG>0) {k1=k;} else {k1=1;}
  vector TG_parm_LO(1,k1);
  vector TG_parm_HI(1,k1);
  ivector TG_parm_PH(1,k1);
  int firsttagparm;
 LOCAL_CALCS
  if(Do_TG>0)
  {
    if(TG_custom==1)
    {
      TG_parm2=TG_parm1;  // assign to the read values
    }
    else
    {
      TG_parm2.initialize();
      onenum="    ";
      for (j=1;j<=N_TG;j++)
      {
        TG_parm2(j,1)=-10;  // min
        TG_parm2(j,2)=10;   // max
        TG_parm2(j,3)=-7.;   // init
        TG_parm2(j,4)=-7.;   // prior
        TG_parm2(j,5)=0.001;  //  prior is quite diffuse
        TG_parm2(j,6)=1.;   // default prior type is symmetric beta
        if(j==1)
        {TG_parm2(j,7)=-4; } // phase
        	else
        {TG_parm2(j,7)=-1000; } // phase
      }

      for (j=1;j<=N_TG;j++)
      {
        TG_parm2(j+N_TG)=TG_parm2(1);  // set chronic tag retention equal to initial tag_retention
      }
      for (j=1;j<=N_TG;j++)  // set overdispersion
      {
        TG_parm2(j+2*N_TG,1)=1;  // min
        TG_parm2(j+2*N_TG,2)=10;   // max
        TG_parm2(j+2*N_TG,3)=2.;   // init
        TG_parm2(j+2*N_TG,4)=2.;   // prior
        TG_parm2(j+2*N_TG,5)=0.001;  //  prior is quite diffuse
        TG_parm2(j+2*N_TG,6)=1.;   // default prior type is symmetric beta
        if(j==1)
        {TG_parm2(j+2*N_TG,7)=-4; } // phase
        	else
        {TG_parm2(j+2*N_TG,7)=-1000; } // phase
      }
      for (j=1;j<=Nfleet1;j++)
      {
        TG_parm2(j+3*N_TG,1)=-10;  // min
        TG_parm2(j+3*N_TG,2)=10;   // max
        TG_parm2(j+3*N_TG,3)=7.;   // init
        TG_parm2(j+3*N_TG,4)=7.;   // prior
        TG_parm2(j+3*N_TG,5)=0.001;  //  prior is quite diffuse
        TG_parm2(j+3*N_TG,6)=1.;   // default prior type is symmetric beta
        if(j==1)
        {TG_parm2(j+3*N_TG,7)=-4; } // phase
        	else
        {TG_parm2(j+3*N_TG,7)=-1000; } // phase
      }
      // set tag reporting decay to nil decay rate
      for (j=1;j<=Nfleet1;j++)
      {
        k=j+3*N_TG+Nfleet1;
        TG_parm2(k,1)=-4.;
        TG_parm2(k,2)=0.;
        TG_parm2(k,3)=0.;
        TG_parm2(k,4)=0.;    // prior of zero
        TG_parm2(k,5)=2.;  // sd dev of prior
        TG_parm2(k,6)=6.;  // default prior type is squared dev
        if(j==1)
        {TG_parm2(k,7)=-4; } // phase
        	else
        {TG_parm2(k,7)=-1000; } // phase
      }
    }
    echoinput<<"create tag labels  "<<endl;
//  SS_Label_Info_4.10.1 #Create parameter count and parameter names for tag parameters
       onenum="    ";
       firsttagparm=ParCount;
       for (j=1;j<=N_TG;j++)
       {
       sprintf(onenum, "%d", j);
       ParCount++; ParmLabel+="TG_loss_init_"+onenum+CRLF(1);
      }
       for (j=1;j<=N_TG;j++)
      {
       sprintf(onenum, "%d", j);
       ParCount++; ParmLabel+="TG_loss_chronic_"+onenum+CRLF(1);
      }
       for (j=1;j<=N_TG;j++)
      {
       sprintf(onenum, "%d", j);
       ParCount++; ParmLabel+="TG_overdispersion_"+onenum+CRLF(1);
      }
       for (j=1;j<=Nfleet;j++)
      {
       if(fleet_type(j)<=2)
       {
         sprintf(onenum, "%d", j);
         ParCount++; ParmLabel+="TG_report_fleet:_"+onenum+CRLF(1);
       }
      }
       for (j=1;j<=Nfleet;j++)
      {
       if(fleet_type(j)<=2)
       {
         sprintf(onenum, "%d", j);
         ParCount++; ParmLabel+="TG_rpt_decay_fleet:_"+onenum+CRLF(1);
       }
      }

    TG_parm_LO=column(TG_parm2,1);
    TG_parm_HI=column(TG_parm2,2);
    k=3*N_TG+2*Nfleet1;
    for (j=1;j<=k;j++) TG_parm_PH(j)=TG_parm2(j,7);  // write it out due to no typecast available
    echoinput<<" Processed/generated Tag parameters "<<endl<<TG_parm2<<endl;

  }
  else
  {
    TG_parm_LO.initialize();
    TG_parm_HI.initialize();
    TG_parm_PH.initialize();
  }
 END_CALCS

   ivector parm_dev_minyr(1,N_parm_dev);
   ivector parm_dev_maxyr(1,N_parm_dev);
   ivector parm_dev_PH(1,N_parm_dev);
   int Do_Var_adjust

   ivector parm_dev_type(1,N_parm_dev);  //  distinguish parameter dev vectors from 2DAR devs
   ivector parm_dev_use_rho(1,N_parm_dev);  //  uses rho parameter, or not
   ivector parm_dev_info(1,N_parm_dev);  //  pointer from list of devvectorsto 2DAR list
   ivector TwoD_AR_ymin(1,TwoD_AR_cnt)
   ivector TwoD_AR_ymax(1,TwoD_AR_cnt)
   ivector TwoD_AR_amin(1,TwoD_AR_cnt)
   ivector TwoD_AR_amax(1,TwoD_AR_cnt)
   ivector TwoD_AR_before(1,TwoD_AR_cnt) //  what to do in years before the year range
   ivector TwoD_AR_after(1,TwoD_AR_cnt)  //  what to do in years after the year range
   ivector TwoD_AR_degfree(1,TwoD_AR_cnt)  //  N years with observations * nages in the 2D_AR range
   ivector TwoD_AR_cor_dim(1,TwoD_AR_cnt)

 LOCAL_CALCS
   parm_dev_use_rho.initialize();
   if(timevary_cnt>0)
   {
     for (j=1;j<=timevary_cnt;j++)  //  loop all timevary to set up devs; note that 2D_AR1 is counted in N_parm_dev, but not in timevary_cnt
     {
       ivector timevary_setup(1,14);
       timevary_setup(1,14)=timevary_def[j](1,14);
       if(timevary_setup(8)>0)
       {
         k=timevary_setup(8);  //  dev vector used
         parm_dev_minyr(k)=timevary_setup(10);  //  used for dimensioning the dev vectors in SS_param
         parm_dev_maxyr(k)=timevary_setup(11);
         parm_dev_PH(k)=timevary_setup(12);
         echoinput<<" dev vector #:  "<<k<<" setup: "<<timevary_setup<<" phase: "<<parm_dev_PH(k)<<endl;
         f=timevary_setup(13);  //  index of base parameter
           int picker=timevary_setup(9);
           parm_dev_type(k)=1;  //  so P'=P+dev*se with objfun using  -log(1)
           if(picker>20)
           {
            picker-=20;
            timevary_setup(14)=1;  //  flag to continue last dev through to YrMax
           timevary_def[j](14)=1;  //  save in array also
            echoinput<<j<<" setting flag to continue last dev "<<Fcast_Specify_Selex<<" "<<firstselparm<<" "<<f<<" "<<firstselparm+N_selparm<<" "<<endl;
           if(Fcast_Specify_Selex==0 && f>=firstselparm && f<=(firstselparm+N_selparm))
           	{N_warn++;  warning<<N_warn<<" "<<"for selectivity parmdevs, must change Fcast_Specify_Selex to 1 when using continue last dev"<<endl;
           	 echoinput<<"for selectivity parmdevs, must change Fcast_Specify_Selex to 1 when using continue last dev"<<endl;}
            }
           if(picker>10) 
           {
             parm_dev_type(k)=3;  // use objfun using -log(se) to match 3.30.12 and earlier
             picker-=10;
           }
           if(picker==6) parm_dev_type(k)=4;  //  add penalty to keep rmse near 1. Needs to estimate stddev factor
           	                                  //  this works, but slow final convergence because getting stddev exactly to 1.0 causes high correlation among devs
           timevary_setup(9)=picker;   //  set to its core function because parm_dev_type has been setup
           timevary_def[j](9)=picker;  //  save in array also

           parm_dev_use_rho(k)=0;
           if(picker==4 || picker==5 || picker==6) parm_dev_use_rho(k)=1;
         for(y=parm_dev_minyr(k);y<=parm_dev_maxyr(k);y++)
         {
           sprintf(onenum, "%d", y);
           ParCount++;
           if(picker==1)
           {ParmLabel+=ParmLabel(f)+"_DEVmult_"+onenum+CRLF(1);}
           else if(picker==2)
           {ParmLabel+=ParmLabel(f)+"_DEVadd_"+onenum+CRLF(1);}
           else if(picker==3)
           {ParmLabel+=ParmLabel(f)+"_DEVrwalk_"+onenum+CRLF(1);}
           else if(picker==4)
           {ParmLabel+=ParmLabel(f)+"_DEV_MR_rwalk_"+onenum+CRLF(1);}
           else if(picker==5)
           {ParmLabel+=ParmLabel(f)+"_DEV_MR_rwalk_bnd_"+onenum+CRLF(1);}  //  for bounding result on base parm min-max
           else if(picker==6)
           {ParmLabel+=ParmLabel(f)+"_DEV_MR_rwalk_pen_"+onenum+CRLF(1);}  //  like 3.24
           else
           {N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" "<<" illegal parmdevtype for parm "<<f<<endl; exit(1);}
         }
       }
     }
   }

//  now add dev vectors for the 2D_AR1
     TwoD_AR_degfree.initialize();
     for (f=1;f<=TwoD_AR_cnt;f++)
     {
       ivector TwoD_AR_setup(1,13);
    //  1-fleet, 2-ymin, 3-ymax, 4-amin, 5-amax, 6-sigma_amax, 7-use_rho, 8-age/len, 9-dev_phase
    //  10-mindimension, 11=maxdim, 12-N_parm_dev, 13-selparm_location
    //  note that elements 10 and 11 have different usages when used for time-varying parameters
       TwoD_AR_setup(1,13)=TwoD_AR_def[f](1,13);
       echoinput<<f<<" 2D_AR1 setup "<<TwoD_AR_setup<<endl;
         k=TwoD_AR_setup(12);  //  dev vector used
         parm_dev_minyr(k)=1;  //  used for dimensioning the dev vectors in SS_param   parm_dev_minyr(k)
         parm_dev_maxyr(k)=(TwoD_AR_setup(3)-TwoD_AR_setup(2)+1)*(TwoD_AR_setup(5)-TwoD_AR_setup(4)+1);   //parm_dev_maxyr(k)
         parm_dev_PH(k)=TwoD_AR_setup(9);
         parm_dev_type(k)=2;  //  distinguish 2D_AR devs from parameter devs
         parm_dev_use_rho(k)=0;  //  need to update when implemented
         parm_dev_info(k)=f;  //  pointer from parmdev list to the 2D_AR list
         TwoD_AR_ymin(f)=TwoD_AR_setup(2);
         TwoD_AR_ymax(f)=TwoD_AR_setup(3);
         TwoD_AR_amin(f)=TwoD_AR_setup(4);
         TwoD_AR_amax(f)=TwoD_AR_setup(5);
         TwoD_AR_before(f)=TwoD_AR_setup(10);
         TwoD_AR_after(f)=TwoD_AR_setup(11);
         TwoD_AR_cor_dim(f)=(TwoD_AR_ymax(f)-TwoD_AR_ymin(f)+1)*(TwoD_AR_amax(f)-TwoD_AR_amin(f)+1);
         for(y=TwoD_AR_ymin(f);y<=TwoD_AR_ymax(f);y++)
         {
           TwoD_AR_degfree(f)+=have_data_yr(y,timevary_setup(1));
           for(a=TwoD_AR_amin(f);a<=TwoD_AR_amax(f);a++)
           {
             sprintf(onenum, "%d", y);
             sprintf(anystring, "%d", a);
             ParCount++;
             if(TwoD_AR_setup(8)==1)
             {ParmLabel+=fleetname(TwoD_AR_setup(1))+"_ARDEV_y"+onenum+"_Lbin"+anystring+CRLF(1);}
             else
             {ParmLabel+=fleetname(TwoD_AR_setup(1))+"_ARDEV_y"+onenum+"_A"+anystring+CRLF(1);}
           }
         }
         echoinput<<" total years, and with data  "<<TwoD_AR_ymax(f)-TwoD_AR_ymin(f)+1<<" "<<TwoD_AR_degfree(f)<<"  times nages: ";
         TwoD_AR_degfree(f)*=(TwoD_AR_amax(f)-TwoD_AR_amin(f)+1);
         echoinput<<TwoD_AR_degfree(f)<<endl;
     }

    echoinput<<" read var_adjust list until -9999"<<endl;
    ender=0;
    do
    {
      dvector tempvec(1,3);
      *(ad_comm::global_datafile) >> tempvec(1,3);
        echoinput<<tempvec<<endl;
      if(tempvec(1)==-9999.) ender=1;
      var_adjust_data.push_back(tempvec(1,3));
    } while(ender==0);
    Do_Var_adjust=var_adjust_data.size()-1;
    echoinput<<" number of variance adjustment records = "<<Do_Var_adjust<<endl;
 END_CALCS
  matrix var_adjust(1,7,1,Nfleet)
  // init_matrix var_adjust_list(1,Do_Var_adjust+1,1,3)

 LOCAL_CALCS
  var_adjust.initialize();
  for(j=4;j<=7;j++)
  {
    var_adjust(j)=1.0;  //  null value
  }
  if(Do_Var_adjust>0)
  {
    for(j=1;j<=Do_Var_adjust;j++)
    {
      var_adjust(var_adjust_data[j-1](1),var_adjust_data[j-1](2)) = var_adjust_data[j-1](3);
    }
   echoinput<<" Var_adjustments as read "<<endl<<var_adjust<<endl;
  }
  else
  {
    var_adjust(1)=0.;
    var_adjust(2)=0.;
    var_adjust(3)=0.;
    var_adjust(4)=1.;
    var_adjust(5)=1.;
    var_adjust(6)=1.;
    var_adjust(7)=1.;
  }
 END_CALCS

  init_int max_lambda_phase
  init_number sd_offset

 LOCAL_CALCS
  echoinput<<max_lambda_phase<<" max_lambda_phase "<<endl;
  if(max_lambda_phase<1) max_lambda_phase=1;
  echoinput<<sd_offset<<" sd_offset (adds log(s)); needed if variance parameters are estimated "<<endl;
  if(sd_offset==0)
  {
    if(varparm_estimated(1)==1)
    {
      N_warn++; cout<<"exit with warning"<<endl; 
       warning<<N_warn<<" "<<" growth variance is estimated parameter, so change sd_offset to 1"<<endl; exit(1);
    }
    if(varparm_estimated(2)==1)
    {N_warn++; cout<<" EXIT - see warning "<<endl; 
       warning<<N_warn<<" "<<" recruitment sigmaR is estimated parameter, so change sd_offset to 1"<<endl; exit(1);}
    if(varparm_estimated(3)==1)
    {N_warn++; cout<<" EXIT - see warning "<<endl; 
       warning<<N_warn<<" "<<" survey extraSD is estimated parameter, so change sd_offset to 1"<<endl; exit(1);}
  }
  if(depletion_fleet>0  && depletion_type<2 && max_lambda_phase<2)
    {
      max_lambda_phase=2;
      N_warn++;  warning<<N_warn<<" "<<"Increase max_lambda_phase to 2 because depletion fleet is being used"<<endl;
    }
 END_CALCS

!!//  SS_Label_Info_4.11.1 #Define type_phase arrays for lambdas
  matrix surv_lambda(1,Nfleet,1,max_lambda_phase)
  matrix disc_lambda(1,Nfleet,1,max_lambda_phase)
  matrix mnwt_lambda(1,Nfleet,1,max_lambda_phase)
  matrix length_lambda(1,Nfleet,1,max_lambda_phase)
  matrix age_lambda(1,Nfleet,1,max_lambda_phase)
  matrix sizeage_lambda(1,Nfleet,1,max_lambda_phase)
  matrix init_equ_lambda(1,Nfleet,1,max_lambda_phase)
  matrix catch_lambda(1,Nfleet,1,max_lambda_phase)
  vector recrdev_lambda(1,max_lambda_phase)
  vector regime_lambda(1,max_lambda_phase)
  vector parm_prior_lambda(1,max_lambda_phase)
  vector parm_dev_lambda(1,max_lambda_phase)
  vector CrashPen_lambda(1,max_lambda_phase)
  vector Morphcomp_lambda(1,max_lambda_phase)
  matrix SzFreq_lambda(1,SzFreq_N_Like,1,max_lambda_phase)
  matrix TG_lambda1(1,N_TG2,1,max_lambda_phase)
  matrix TG_lambda2(1,N_TG2,1,max_lambda_phase)
  vector F_ballpark_lambda(1,max_lambda_phase)

!!//  SS_Label_Info_4.11.2 #Read and process any lambda adjustments
  int N_lambda_changes
  int N_changed_lambdas
 LOCAL_CALCS
   echoinput<<" read lambda changes list until -9999"<<endl;
   ender=0;
   do
   {
     dvector tempvec(1,5);
     *(ad_comm::global_datafile) >> tempvec(1,5);
     if(tempvec(1)==-9999.) ender=1;
     lambda_change_data.push_back(tempvec(1,5));
   } while(ender==0);
   N_lambda_changes=lambda_change_data.size()-1;
   echoinput<<" number of lambda change records = "<<N_lambda_changes<<endl;
 END_CALCS

  matrix Lambda_changes(1,N_lambda_changes,1,5)
 LOCAL_CALCS
   for(f=1;f<=N_lambda_changes;f++) Lambda_changes(f)=lambda_change_data[f-1];
   // *(ad_comm::global_datafile) >> tempvec(1,5);  //  read 5 numerics from line
   echoinput<<N_lambda_changes<<" N lambda changes "<<endl;
   if(N_lambda_changes>0) echoinput<<" lambda changes "<<endl<<Lambda_changes<<endl;
   surv_lambda=1.;  // 1
   disc_lambda=1.;  // 2
   mnwt_lambda=1.;  // 3
   length_lambda=1.; // 4
   age_lambda=1.;  // 5
   SzFreq_lambda=1.;  // 6
   sizeage_lambda=1.; // 7
   catch_lambda=1.; // 8
   init_equ_lambda=1.; // 9
   recrdev_lambda=1.; // 10
   parm_prior_lambda=1.; // 11
   parm_dev_lambda=1.; // 12
   CrashPen_lambda=1.; // 13
   Morphcomp_lambda=1.; // 14
   TG_lambda1=1.; // 15
   TG_lambda2=1.;  //16
   F_ballpark_lambda=1.;  // 17
   regime_lambda=1.;  //  18

    if(depletion_fleet>0  && depletion_type<2)
    {
      for (f=1;f<=Nfleet;f++)
      {
        surv_lambda(f,1)=0.0;
        init_equ_lambda(f,1)=0.0;
        disc_lambda(f,1)=0.0;
        mnwt_lambda(f,1)=0.0;
        length_lambda(f,1)=0.0;
        age_lambda(f,1)=0.0;
        sizeage_lambda(f,1)=0.0;
//        catch_lambda(f,1)=0.0;  //  keep this positive to prevent crashes from bad fit to catch
      }
      if(SzFreq_Nmeth>0)
      {
        for (z=1;z<=SzFreq_N_Like;z++)
        {SzFreq_lambda(z,1)=0.0;}
      }
      if(N_TG2>0)
      {
        for (z=1;z<=N_TG2;z++)
        {
          TG_lambda1(z,1)=0.0;
          TG_lambda2(z,1)=0.0;
        }
      }
      recrdev_lambda(1)=0.0;
      Morphcomp_lambda(1)=0.0;
      F_ballpark_lambda(1)=0.0;

      surv_lambda(depletion_fleet,1)=1.0;
    }

    N_changed_lambdas=0;
    for (j=1;j<=N_lambda_changes;j++)
    {
      k=Lambda_changes(j,1);  // like component
      f=Lambda_changes(j,2);  // fleet
      s=Lambda_changes(j,3);  // phase
      if(k<=14)
      {
        if(f>Nfleet)
        {
          k=0;
          N_warn++;
           warning<<N_warn<<" "<<" illegal fleet/survey for lambda change at row: "<<j<<" fleet: "<<f<<" > Nfleet"<<endl;
        }
      }
      else if(k<=16)  // tag data
      {
        if(f>N_TG2)
        {
          k=0;
          N_warn++;
           warning<<N_warn<<" "<<" illegal tag group for lambda change at row: "<<j<<" Tag: "<<f<<" > N_taggroups"<<endl;
        }
      }
      else if(k>18)
      {
        k=0;
        N_warn++;
         warning<<N_warn<<" "<<" illegal lambda_type for lambda change at row: "<<j<<" Method: "<<k<<" > 17"<<endl;
      }
      if(s>max_lambda_phase)
      {k=0; N_warn++;   warning<<N_warn<<" "<<" illegal request for lambda change at row: "<<j<<" phase: "<<s<<" > max_lam_phase: "<<max_lambda_phase<<endl;}
//      if(s>Turn_off_phase) s=max(1,Turn_off_phase);
      temp=Lambda_changes(j,4);  // value
      if(temp!=0.0 && temp!=1.0) N_changed_lambdas++;
      z=Lambda_changes(j,5);   // special for sizefreq
      switch(k)
      {
        case 0:  // do nothing
        {break;}
        case 1:  // survey
          {surv_lambda(f)(s,max_lambda_phase)=temp;  break;}
        case 2:  // discard
          {disc_lambda(f)(s,max_lambda_phase)=temp;  break;}
        case 3:  // meanbodywt
          {mnwt_lambda(f)(s,max_lambda_phase)=temp; break;}
        case 4:  // lengthcomp
          {length_lambda(f)(s,max_lambda_phase)=temp; break;}
        case 5:  // agecomp
        {age_lambda(f)(s,max_lambda_phase)=temp; break;}
        case 6:  // sizefreq comp
        {
          z=Lambda_changes(j,5);  //  sizefreq method
          if(z>SzFreq_Nmeth) {N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" "<<" reading sizefreq lambda change for method > Nmeth "<<Lambda_changes(j,5)<<endl; exit(1);}
          SzFreq_lambda(SzFreq_LikeComponent(f,z))(s,max_lambda_phase) = temp;
          break;
        }
        case 7:  // size-at-age
          {sizeage_lambda(f)(s,max_lambda_phase)=temp; break;}
        case 8:  // catch
          {catch_lambda(f)(s,max_lambda_phase)=temp; break;}
        case 9:  // init_equ_catch
          {init_equ_lambda(f)(s,max_lambda_phase)=temp; break;}
        case 10:  // recr_dev
          {recrdev_lambda(s,max_lambda_phase)=temp; break;}
        case 11:  // parm_prior
          {parm_prior_lambda(s,max_lambda_phase)=temp; break;}
        case 12:  // parm_dev
          {parm_dev_lambda(s,max_lambda_phase)=temp; break;}
        case 13:  // crash_penalty
          {CrashPen_lambda(s,max_lambda_phase)=temp; break;}
        case 14:  // morphcomp
          {Morphcomp_lambda(s,max_lambda_phase)=temp; break;}
        case 15:  // Tag - multinomial by fleet  where f is now tag group
          {TG_lambda1(f)(s,max_lambda_phase)=temp; break;}
        case 16:  // Tag - total by time where f is now tag group
          {TG_lambda2(f)(s,max_lambda_phase)=temp; break;}
        case 17:  // F ballpark
          {F_ballpark_lambda(s,max_lambda_phase)=temp; break;}
        case 18:  // regime lambda - only for initial equilibrium
          {regime_lambda(s,max_lambda_phase)=temp; break;}
      }
    }
    for (f=1;f<=Nfleet;f++)
    {
      if(Svy_N_fleet(f)==0) surv_lambda(f)=0.;
      if(disc_N_fleet(f)==0) disc_lambda(f)=0.;
      if(Nobs_l(f)==0) length_lambda(f)=0.;
      if(Nobs_a(f)==0) age_lambda(f)=0.;
      if(Nobs_ms(f)==0) sizeage_lambda(f)=0.;
    }
    if(nobs_mnwt==0) mnwt_lambda=0.;  //  more complicated to turn off for each fleet
 END_CALCS

!!//  SS_Label_Info_4.12 #Read setup for more derived quantities to include in the STD report
  init_int Do_More_Std   // option (currently 0, 1, or 2)
  int More_Std_N_Inputs; // count of inputs (depends on option above)
 LOCAL_CALCS
  More_Std_N_Inputs=0;
  if(Do_More_Std==1){
    More_Std_N_Inputs=9;
  }
  if(Do_More_Std==2){
    More_Std_N_Inputs=13;
  }
 END_CALCS
  ivector More_Std_Input(1,13); // read dimensions
  init_ivector temp_std_input(1,More_Std_N_Inputs)
 LOCAL_CALCS
  echoinput<<Do_More_Std<<" # extra stdev reporting: 0 = skip, 1 = read specs for reporting stdev for selectivity, size, and numbers, 2 = add option for M and dyn. Bzero "<<endl;
  More_Std_Input.initialize();
  if(Do_More_Std>0)
  {
    More_Std_Input(1,More_Std_N_Inputs) = temp_std_input(1,More_Std_N_Inputs);
    echoinput<<More_Std_Input(1,4)<<" # Selectivity: (1) 0 to skip or fleet, (2) 1=len/2=age/3=combined, (3) year, (4) N selex bins; NOTE: combined reports in age bins"<<endl;
    echoinput<<More_Std_Input(5,6)<<" # Growth: (1) 0 to skip or growth pattern, (2) growth ages; NOTE: does each sex"<<endl;
    echoinput<<More_Std_Input(7,9)<<" # Numbers-at-age: (1) 0 to skip or area(-1 for all), (2) year, (3) N ages;  NOTE: sums across morphs"<<endl;
  }
  if(Do_More_Std>=2)
  {
    echoinput<<More_Std_Input(10,11)<<" # Mortality: (1) 0 to skip or growth pattern, (2) N ages for mortality; NOTE: does each sex"<<endl;
    echoinput<<More_Std_Input(12,13)<<" # Dyn_Bzero: (1) 0 to skip, 1 to do, 2 w/ recr (2) reserved for future use"<<endl;
  }
 END_CALCS

  int Do_Selex_Std;
  int Selex_Std_AL;
  int Selex_Std_Year;
  int Selex_Std_Cnt;
  int Do_Growth_Std;
  int Growth_Std_Cnt;
  int Do_NatAge_Std;
  int NatAge_Std_Year;
  int NatAge_Std_Cnt;
  int Do_NatM_Std;
  int NatM_Std_Cnt;
  int Do_Dyn_Bzero;
  int Extra_Std_N;   //  dimension for the sdreport vector Selex_Std which also contains the Growth_Std

 LOCAL_CALCS
   Extra_Std_N=0;

   // don't read any extra std inputs
   if(Do_More_Std==0)
   {
     Do_Selex_Std=0;
     Selex_Std_AL=1;
     Selex_Std_Year=endyr;
     Selex_Std_Cnt=0;
     Do_Growth_Std=0;
     Growth_Std_Cnt=0;
     Do_NatAge_Std=0;
     NatAge_Std_Cnt=0;
     NatAge_Std_Year=endyr;
     Do_NatM_Std=0;
     NatM_Std_Cnt=0;
     Do_Dyn_Bzero=0;
   }

   // read standard extra std inputs (only option prior to 3.30.15)
   if(Do_More_Std>0)
   {
     Do_Selex_Std=More_Std_Input(1);
     Selex_Std_AL=More_Std_Input(2);
     Selex_Std_Year=More_Std_Input(3);
     if(Selex_Std_Year<0) Selex_Std_Year=endyr;
     Selex_Std_Cnt=More_Std_Input(4);
     Do_Growth_Std=More_Std_Input(5);
     Growth_Std_Cnt=More_Std_Input(6);
     Do_NatAge_Std=More_Std_Input(7);
     NatAge_Std_Year=More_Std_Input(8);
     if(NatAge_Std_Year<0) NatAge_Std_Year=endyr+1;
     NatAge_Std_Cnt=More_Std_Input(9);
     if(Do_Selex_Std<=0) Selex_Std_Cnt=0;
     if(Do_Growth_Std<=0) Growth_Std_Cnt=0;
     if(Do_NatAge_Std==0) NatAge_Std_Cnt=0;
     Do_NatM_Std=0;  // value replaced below if Do_More_Std==2
     NatM_Std_Cnt=0; // value replaced below if Do_More_Std==2
   }

   // read additional extra std inputs for NatM (added in 3.30.15)
   if(Do_More_Std==2)
   {
     Do_NatM_Std=More_Std_Input(10);
     NatM_Std_Cnt=More_Std_Input(11);
     if(Do_NatM_Std<=0){
       NatM_Std_Cnt=0;
     }
     Do_Dyn_Bzero=More_Std_Input(12);
   }
 END_CALCS

  // get vector of length bins or ages for selex std (either input or autogenerate)
  init_ivector Selex_Std_Pick(1,Selex_Std_Cnt);
 LOCAL_CALCS
  if(Do_Selex_Std>0)
  {
    echoinput<<Selex_Std_Pick<<" # vector with selex std bins (-1 in first bin to self-generate)"<<endl;
    if(Selex_Std_Pick(1)<0)  //  then self-generate even bin selection
    {
      if(Selex_Std_AL==1) // length-based selex
      {
        if(Selex_Std_Cnt==1)
          {Selex_Std_Pick(1)=nlength/2;}
        else if(Selex_Std_Cnt==2)
          {Selex_Std_Pick(1)=nlength/2; Selex_Std_Pick(2)=nlength;}
        else
        { j=nlength/(Selex_Std_Cnt-1);
          Selex_Std_Pick(1)=j/2;
          for (i=2;i<=Selex_Std_Cnt-1;i++) Selex_Std_Pick(i)=Selex_Std_Pick(i-1)+j;
          Selex_Std_Pick(Selex_Std_Cnt)=nlength;
        }
        echoinput<<"generate length selex std for fleet: "<<Do_Selex_Std<<" in year: "<<Selex_Std_Year<<" at bins: "<<Selex_Std_Pick<<endl;
      }
      else  // age-based or age-length-combined selex
      {
        if(Selex_Std_Cnt==1)
          {Selex_Std_Pick(1)=nages/2;}
        else if(Selex_Std_Cnt==2)
          {Selex_Std_Pick(1)=nages/2; Selex_Std_Pick(2)=nages;}
        else
        {         
          j=nages/(Selex_Std_Cnt-1);
          Selex_Std_Pick(1)=j/2;
          for (i=2;i<=Selex_Std_Cnt-1;i++) Selex_Std_Pick(i)=Selex_Std_Pick(i-1)+j;
          Selex_Std_Pick(Selex_Std_Cnt)=nages;
        }
        echoinput<<"generate age selex std for fleet: "<<Do_Selex_Std<<" in year: "<<Selex_Std_Year<<" at ages: "<<Selex_Std_Pick<<endl;
      }
    }
    // adjust values to keep in range
    for(i=1;i<=Selex_Std_Cnt;i++)
    {
      if(Selex_Std_AL==1) // length-based selex
      {
        if(Selex_Std_Pick(i)<=0) Selex_Std_Pick(i)=1;
        if(Selex_Std_Pick(i)>nlength) Selex_Std_Pick(i)=nlength;
      }
      else // age-based or age-length-combined selex
      {
        if(Selex_Std_Pick(i)<0) Selex_Std_Pick(i)=0;
        if(Selex_Std_Pick(i)>nages) Selex_Std_Pick(i)=nages;
      }
    }
    // increment count
    Extra_Std_N=gender*Selex_Std_Cnt;
  }
 END_CALCS

  // get vector of bins for growth std (either input or autogenerate)
  init_ivector Growth_Std_Pick(1,Growth_Std_Cnt);
 LOCAL_CALCS
  if(Do_Growth_Std>0)
  {
    echoinput<<Growth_Std_Pick<<" # vector with growth std ages (-1 in first bin to self-generate)"<<endl;
		// turn off growth extra stderr for growth if no estimated growth parameters
    if(MG_active(2)==0)
    {
      N_warn++;
  		 warning<<N_warn<<" "<<"warning; growth output stderr requested but no growth parameters are estimated, changing growth stddev reporting specifications to 0"<<endl;
  		Do_Growth_Std=0;
//  		More_Std_Input(5)=0;
//  		More_Std_Input(6)=0;
			Growth_Std_Cnt=0;
    }else{
		  // there are active growth parameters so proceed with processing stderr
      if(Growth_Std_Pick(1)<0)
      {
        Growth_Std_Pick(1)=AFIX;
        Growth_Std_Pick(Growth_Std_Cnt)=nages;
        if(Growth_Std_Cnt>2)
        {
          k=Growth_Std_Cnt/2;
          for (i=2;i<=k;i++) Growth_Std_Pick(i)=Growth_Std_Pick(i-1)+1;
          j=(nages-Growth_Std_Pick(k))/(Growth_Std_Cnt-k);
          for (i=k+1;i<=Growth_Std_Cnt-1;i++) Growth_Std_Pick(i)=Growth_Std_Pick(i-1)+j;
        }
      }
      for(i=1;i<=Growth_Std_Cnt;i++)
      {
        if(Growth_Std_Pick(i)<0) Growth_Std_Pick(i)=0;
        if(Growth_Std_Pick(i)>nages) Growth_Std_Pick(i)=nages;
      }
  	}
    Extra_Std_N+=gender*Growth_Std_Cnt;
  }
 END_CALCS

  // get vector of bins for N-at-age std (either input or autogenerate)
  init_ivector NatAge_Std_Pick(1,NatAge_Std_Cnt);
 LOCAL_CALCS
  if(Do_NatAge_Std!=0)
  {
    echoinput<<NatAge_Std_Pick<<" # vector with NatAge std bins (-1 in first bin to self-generate)"<<endl;
    if(NatAge_Std_Pick(1)<0)
    {
      NatAge_Std_Pick(1)=1;
      NatAge_Std_Pick(NatAge_Std_Cnt)=nages;
      if(NatAge_Std_Cnt>2)
      {
        k=NatAge_Std_Cnt/2;
        for (i=2;i<=k;i++) NatAge_Std_Pick(i)=NatAge_Std_Pick(i-1)+1;
        j=(nages-NatAge_Std_Pick(k))/(NatAge_Std_Cnt-k);
        for (i=k+1;i<=NatAge_Std_Cnt-1;i++) NatAge_Std_Pick(i)=NatAge_Std_Pick(i-1)+j;
      }
    }
    for(i=1;i<=NatAge_Std_Cnt;i++)
    {
      if(NatAge_Std_Pick(i)<=0) NatAge_Std_Pick(i)=0;
      if(NatAge_Std_Pick(i)>nages) NatAge_Std_Pick(i)=nages;
    }
    Extra_Std_N+=gender*NatAge_Std_Cnt;
  }

 END_CALCS

  // get vector of bins for NatM std (either input or autogenerate)
  init_ivector NatM_Std_Pick(1,NatM_Std_Cnt);
 LOCAL_CALCS
  if(Do_NatM_Std>0)
  {
    echoinput<<NatM_Std_Pick<<" # vector with NatM std ages (-1 in first bin to self-generate)"<<endl;
    // autogenerate the ages
    if(NatM_Std_Pick(1)<0)
    {
      // set first and last to reference ages
      NatM_Std_Pick(1)=AFIX;
      NatM_Std_Pick(NatM_Std_Cnt)=nages;
      // if there is more than 2, fill in the middle
      if(NatM_Std_Cnt>2)
      {
        // first half of values increment by 1
        k=NatM_Std_Cnt/2;
        for (i=2;i<=k;i++){
          NatM_Std_Pick(i)=NatM_Std_Pick(i-1)+1;
        }
        // remainder are evently distributed across range
        j=(nages-NatM_Std_Pick(k))/(NatM_Std_Cnt-k);
        for (i=k+1;i<=NatM_Std_Cnt-1;i++){
          NatM_Std_Pick(i)=NatM_Std_Pick(i-1)+j;
        }
      }
    }
    // shift any negative values to 0 and any that are too large down to nages
    for(i=1;i<=NatM_Std_Cnt;i++)
    {
      if(NatM_Std_Pick(i)<0) NatM_Std_Pick(i)=0;
      if(NatM_Std_Pick(i)>nages) NatM_Std_Pick(i)=nages;
    }
    // increment counter
    Extra_Std_N+=gender*NatM_Std_Cnt;
  }

  if(Do_Dyn_Bzero>0)
  {
  	Do_Dyn_Bzero=Extra_Std_N+1;  //  start spot for Dynamic Bzero
  	Extra_Std_N+=YrMax-(styr-2)+1;
  	if(More_Std_Input(12)==2) Extra_Std_N+=YrMax-(styr-2)+1;  //  for recruitment
  }
  // add 3 values for ln(Spbio)
  // (years are automatically generated as startyr, mid-point, and endyr)
  Extra_Std_N+=3;  

 END_CALCS

!!//  SS_Label_Info_4.13 #End of reading from control file
  init_int fim // end of file indicator

 LOCAL_CALCS
  if(fim==999)
  {
  cout<<"End of control file successful! "<<fim<<endl;
  echoinput<<"End of control file successful! "<<fim<<endl;
  }
  else
  {
  cout<<" Unsuccessful end of control file, SS will abort. check echoinput for clues.  Last read is: "<<fim<<endl;
  abort();
  }
 END_CALCS

!!//  SS_Label_Info_4.14 #Create count of active parameters and derived quantities
  int CoVar_Count;
  int active_count;    // count the active parameters
  int active_parms;    // count the active parameters
  int deriv_start;  //  start index for derived quantities
  int deriv_covar_start
  
 LOCAL_CALCS
  if(Do_Benchmark>0)
  {
    N_STD_Mgmt_Quant=17;
  }
  else
  {N_STD_Mgmt_Quant=4;}
  Fcast_catch_start=N_STD_Mgmt_Quant;
  if(max(Do_Retain)>0) {j=1;} else {j=0;}
  if(Do_Forecast>0) {N_STD_Mgmt_Quant+=N_Fcast_Yrs*(1+j)+N_Fcast_Yrs;}
  k=ParCount+2*N_STD_Yr+N_STD_Yr_Dep+N_STD_Yr_Ofish+N_STD_Yr_F+N_STD_Mgmt_Quant+gender*Selex_Std_Cnt+gender*Growth_Std_Cnt+gender*NatAge_Std_Cnt+gender*NatM_Std_Cnt;
  if(Do_More_Std>=2)
  {
    k+=Do_Dyn_Bzero*(YrMax-(styr-2)-1);
    if(More_Std_Input(12)==2) k+=(YrMax-(styr-2)-1);  //  for recruits
  }
  k+=3+Svy_N_sdreport;
  echoinput<<"N parameters: "<<ParCount<<endl<<"Parameters plus derived quant: "<<k<<endl;
 END_CALCS
  ivector active_parm(1,k)  //  pointer from active list to the element of the full parameter list to get label later

//***********************************************
!!//  SS_Label_Info_4.14.1 #Adjust the phases to negative if beyond turn_off_phase and find resultant max_phase
  int max_phase;
  int Turn_off_phase2

 LOCAL_CALCS
  echoinput<<"Adjust the phases "<<endl;
  Turn_off_phase2=Turn_off_phase;
  echoinput<<" requested turn_off phase: "<<Turn_off_phase<<endl;
  if(depletion_fleet>0 && depletion_type==1) 
    {
      Turn_off_phase2=1;
      echoinput<<"depletion fleet and type are: "<<depletion_fleet<<" "<<depletion_type<<" so set turn-off to phase 1 "<<endl;
    }
  max_phase=1;
  active_count=0;
  active_parm(1,ParCount)=0;
  ParCount=0;

  j=MGparm_PH.indexmax();

  for (k=1;k<=j;k++)
  {
    ParCount++;
    if(MGparm_PH(k)==-9999) {MGparm_RD(k)=prof_var(prof_var_cnt); prof_var_cnt+=1;}
    if(depletion_fleet>0  && depletion_type<2 && MGparm_PH(k)>0) MGparm_PH(k)++;  //  add 1 to phase if using depletion fleet
    if(MGparm_PH(k) > Turn_off_phase2) MGparm_PH(k) =-1;
    if(MGparm_PH(k) > max_phase) max_phase=MGparm_PH(k);
    if(MGparm_PH(k)>=0)
    {
      active_count++; active_parm(active_count)=ParCount;
    }
  }

  for (j=1;j<=SR_parm_PH.indexmax();j++)
  {
    ParCount++;
    if(SR_parm_PH(j)==-9999) {SR_parm_1(j,3)=prof_var(prof_var_cnt); SR_parm_RD(j,3)=SR_parm_1(j,3); prof_var_cnt+=1;}
    if(depletion_fleet>0 && depletion_type<2 && SR_parm_PH(j)>0) SR_parm_PH(j)++;  //  add 1 to phase if using depletion fleet
    if(depletion_fleet>0  && depletion_type<2 && j==1) SR_parm_PH(1)=1;  //  R0 active in phase 1, unless type==2
    if(SR_parm_PH(j) > Turn_off_phase2) SR_parm_PH(j) =-1;
    if(SR_parm_PH(j) > max_phase) max_phase=SR_parm_PH(j);
    if(SR_parm_PH(j)>=0)
    {
      active_count++; active_parm(active_count)=ParCount;
    }
  }

  if(recdev_cycle>0)
  {
    for (y=1;y<=recdev_cycle;y++)
    {
      ParCount++;
      recdev_cycle_LO(y)=recdev_cycle_parm_RD(y,1);
      recdev_cycle_HI(y)=recdev_cycle_parm_RD(y,2);
      recdev_cycle_PH(y)=recdev_cycle_parm_RD(y,7);
      if(depletion_fleet>0  && depletion_type<2 && recdev_cycle_PH(y)>0) recdev_cycle_PH(y)++;  //  add 1 to phase if using depletion fleet
      if(recdev_cycle_PH(y) > Turn_off_phase2) recdev_cycle_PH(y) =-1;
      if(recdev_cycle_PH(y) > max_phase) max_phase=recdev_cycle_PH(y);
      if(recdev_cycle_PH(y)>=0) {active_count++; active_parm(active_count)=ParCount;}
    }
  }

  if(depletion_fleet>0  && depletion_type<2 && recdev_early_PH_rd>0) recdev_early_PH_rd++;  //  add 1 to phase if using depletion fleet
  if(recdev_early_PH_rd > Turn_off_phase2)
    {recdev_early_PH =-1;}
    else
    {recdev_early_PH =recdev_early_PH_rd;}

  if(recdev_early_PH > max_phase) max_phase=recdev_early_PH;

  if(recdev_do_early>0)
  {
  for (y=recdev_early_start;y<=recdev_early_end;y++)
  {
    ParCount++;
    if(recdev_early_PH>=0) {active_count++; active_parm(active_count)=ParCount;}
  }
  }

  if(depletion_fleet>0  && depletion_type<2 && recdev_PH>0) recdev_PH++;  //  add 1 to phase if using depletion fleet
  if(recdev_PH > Turn_off_phase2) recdev_PH =-1;
  if(recdev_PH > max_phase) max_phase=recdev_PH;
  if(do_recdev>0)
  {
  for (y=recdev_start;y<=recdev_end;y++)
  {
    ParCount++;
    if(recdev_PH>=0) {active_count++; active_parm(active_count)=ParCount;}
  }
  }

  Fcast_recr_PH2=max_phase+1;
  Fcast_recr_PH=Fcast_recr_PH_rd;
  if(Do_Forecast>0)
  {
    if(Turn_off_phase>0)
    {
      if(Fcast_recr_PH_rd!=0)  // read value for forecast_PH
      {
        Fcast_recr_PH2=Fcast_recr_PH;
        if(depletion_fleet>0  && depletion_type<2 && Fcast_recr_PH2>0) Fcast_recr_PH2++;
        if(Fcast_recr_PH2 > Turn_off_phase2) Fcast_recr_PH2 =-1;
        if(Fcast_recr_PH2 > max_phase) max_phase=Fcast_recr_PH2;
      }
      if(depletion_fleet>0  && depletion_type==1)
        {max_phase=1; Fcast_recr_PH2=-1;}
    }
    else
      {
        Fcast_recr_PH2=-1;
      }

      if(do_recdev!=0){
      	for (y=recdev_end+1;y<=YrMax;y++)
        {
          ParCount++;
          if(Fcast_recr_PH2>-1) {active_count++; active_parm(active_count)=ParCount;}
        }
      }
      if(Do_Impl_Error>0){
	    for (y=endyr+1;y<=YrMax;y++)
      {
      ParCount++;
      if(Fcast_recr_PH2>-1)
      {active_count++; active_parm(active_count)=ParCount;}
    }
    }
  }
  else
  {Fcast_recr_PH2=-1;}
  
  echoinput<<"Fcast_dev_phase (read and adjusted): "<<Fcast_recr_PH_rd<<" "<<Fcast_recr_PH2<<endl;
  
  for (s=1;s<=nseas;s++)
  for (f=1;f<=Nfleet;f++)
  {
    if(init_F_loc(s,f)>0)
    {
      j=init_F_loc(s,f);
      ParCount++;
      if(init_F_PH(j)==-9999) {init_F_parm_1(j,3)=prof_var(prof_var_cnt); init_F_RD(j)=init_F_parm_1(j,3);  prof_var_cnt++;}
      if(depletion_fleet>0  && depletion_type<2 && init_F_PH(j)>0) init_F_PH(j)++;
      if(init_F_PH(j) > Turn_off_phase2) init_F_PH(j) =-1;
      if(init_F_PH(j) > max_phase) max_phase=init_F_PH(j);
      if(init_F_PH(j)>=0)
      {
        active_count++; active_parm(active_count)=ParCount;
      }
    }
  }

  if(F_Method==2)
  {
    for (g=1;g<=N_Fparm;g++)
    {
      ParCount++;
      if(depletion_fleet>0  && depletion_type<2 && Fparm_PH(g)>0) Fparm_PH(g)++;  //  increase phase by 1
      if(Fparm_PH(g) > Turn_off_phase2) Fparm_PH(g) =-1;
      if(Fparm_PH(g) > max_phase) max_phase=Fparm_PH(g);
      if(Fparm_PH(g)>0)
      {
        active_count++; active_parm(active_count)=ParCount;
      }
    }
  }

  for (f=1;f<=Q_Npar2;f++)
  {
    ParCount++;
    if(Q_parm_PH(f)==-9999) {Q_parm_1(f,3)=prof_var(prof_var_cnt); Q_parm_RD(f,3)=prof_var(prof_var_cnt); prof_var_cnt++;}
    if(depletion_fleet>0  && depletion_type<2 && Q_parm_PH(f)>0) Q_parm_PH(f)++;
    if(Q_parm_PH(f) > Turn_off_phase2) Q_parm_PH(f) =-1;
    if(Q_parm_PH(f) > max_phase) max_phase=Q_parm_PH(f);
    if(Q_parm_PH(f)>=0)
    {
      active_count++; active_parm(active_count)=ParCount;
    }
  }

  //  SS_Label_Info_4.14.2 #Auto-generate cubic spline setup while inside this parameter counting loop
  Ip=0;
  int N_knots;
  for (f=1;f<=2*Nfleet;f++)   //  check for cubic spline setup
  {
    if(f<=Nfleet)
    {fs=f;}
    else
    {fs=f-Nfleet;}
    if(seltype(f,1)==27 || seltype(f,1)==42)  //  reset the cubic spline knots for size or age comp
    {
      // TODO - may need adjustments below for selex pattern 42

      k=int(selparm_RD(Ip+1));  // setup method
      N_knots=seltype(f,4);  //  number of knots

      if(k==0)
      {}  //  do nothing
      else if(k==1 || k==2)  //  get new knots according to cumulative distribution of data
      {
        echoinput<<"Adjust the cubic_spline setup for fleet: "<<f<<endl;
        s=4;  // counter for which knot is being set
        z=1;  //  counter for  bins in cumulative distribution
        if(N_knots>=3)
        {
          temp=0.025;
          temp1=0.950/float(N_knots-1);  //  increment
        }
        else
        {
          N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" "<<"must have at least 3 knots in spline "<<endl;  exit(1);
        }
        if(f<=Nfleet)  // doing size Selex
        {
          while(temp<=0.975001)
          {
            while(obs_l_all(2,f,z)<temp)
            {
              z++;
            }
            //  intermediate knots are calculated from data_length_bins
            if(z>1)
            {selparm_RD(Ip+s)=len_bins_dat(z-1)+(temp-obs_l_all(2,f,z-1))/(obs_l_all(2,f,z)-obs_l_all(2,f,z-1))*(len_bins_dat(z)-len_bins_dat(z-1));}
            else
            {selparm_RD(Ip+s)=len_bins_dat(z);}
            s++;
            temp+=temp1;
          }
          echoinput<<"len_bins_dat: "<<len_bins_dat<<endl<<"Cum_comp: "<<obs_l_all(2,fs)(1,nlen_bin)<<endl<<"Knots: "<<selparm_RD(Ip+3+1,Ip+3+N_knots)<<endl;
        }
        else  //  age selex
        {
          while(temp<=0.975001)
          {
            while(obs_a_all(2,fs,z)<temp)
            {
              z++;
            }
            //  intermediate knots are calculated from data_length_bins
            if(z>1)
            {selparm_RD(Ip+s)=age_bins(z-1)+(temp-obs_a_all(2,fs,z-1))/(obs_a_all(2,fs,z)-obs_a_all(2,fs,z-1))*(age_bins(z)-age_bins(z-1));}
            else
            {selparm_RD(Ip+s)=age_bins(z);}
            s++;
            temp+=temp1;
          }
          echoinput<<"age_bins: "<<age_bins<<endl<<"Cum_comp: "<<obs_a_all(2,fs)(1,n_abins)<<endl<<"Knots: "<<selparm_RD(Ip+3+1,Ip+3+N_knots)<<endl;
        }
        if(k==2)  //  create default bounds, priors, etc.
        {
        echoinput<<"Do complete setup of lo, hi, prior, etc."<<endl;
          for (z=Ip+4;z<=Ip+3+N_knots;z++)
          {
            if(f<=Nfleet)
            {selparm_LO(z)=len_bins_dat(1);
              selparm_HI(z)=len_bins_dat(nlen_bin);}
            else
            {selparm_LO(z)=age_bins(1);
             selparm_HI(z)=age_bins(n_abins);}
            selparm_PR(z)=int((selparm_LO(z)+selparm_HI(z))/2.);
            selparm_PRtype(z)=0;
            selparm_CV(z)=1.0;
            selparm_PH(z)=-99;
          }

          if(N_knots==3)
          {p=8;}
          else if (N_knots==4)
          {p=10;}
          else
          {p=3+N_knots+1+0.5*N_knots;}

          for (z=N_knots+1+3;z<=3+2*N_knots;z++)
          {
            a=Ip+z;
            if(z<=p)
            {selparm_RD(a)=-5. + float(z-(N_knots+4))/float(p-(N_knots+4))*4.;}
            else
            {selparm_RD(a)=0.0;}
            selparm_LO(a)=-9.;
            selparm_HI(a)=7.;
            selparm_PR(a)=0.;
            selparm_PRtype(a)=1;  //  symmetric beta
            selparm_CV(a)=0.001;
            selparm_PH(a)=2;
          }
          selparm_PH(Ip+p)=-99;
          selparm_PRtype(Ip+p)=0;
          selparm_CV(Ip+p)=1.0;

          p=Ip+1;
          selparm_LO(p)=0.;
          selparm_HI(p)=2.;
          selparm_PR(p)=0.;
          selparm_PRtype(p)=0;
          selparm_CV(p)=1.0;
          selparm_PH(p)=-99;
          p++;
          selparm_LO(p)=-0.001;
          selparm_HI(p)=1.;
          selparm_RD(p)=0.1;  // moderate positive gradient at bottom
          selparm_PR(p)=0.;
          selparm_PRtype(p)=1;  // SYMMETRIC BETA
          selparm_CV(p)=0.001;
          selparm_PH(p)=3;
          p++;
          selparm_LO(p)=-1.;
          selparm_HI(p)=0.001;
          if(N_knots>=3)
          {
          selparm_RD(p)=-0.001;  // small negative gradient at top
          selparm_PR(p)=0.;
          selparm_PRtype(p)=1;
          selparm_CV(p)=0.001;
          selparm_PH(p)=3;
          }
          else
          {
          selparm_RD(p)=0.00;
          selparm_PR(p)=0.;
          selparm_PRtype(p)=0;
          selparm_CV(p)=1.0;
          selparm_PH(p)=-99;
          }

          for (z=Ip+1;z<=Ip+3+2*N_knots;z++)
          {
            selparm_1(z,1)=selparm_LO(z);
            selparm_1(z,2)=selparm_HI(z);
            selparm_1(z,3)=selparm_RD(z);
            selparm_1(z,4)=selparm_PR(z);
            selparm_1(z,6)=selparm_PRtype(z);
            selparm_1(z,5)=selparm_CV(z);
            selparm_1(z,7)=selparm_PH(z);
          }
        }
      }
    }
    Ip+=N_selparmvec(f);
  }
   selparm_PH_soft=selparm_PH;
   for (k=1;k<=selparm_PH.indexmax();k++)
   {
     ParCount++;
     if(selparm_PH(k)==-9999) {selparm_RD(k)=prof_var(prof_var_cnt); selparm_1(k)=prof_var(prof_var_cnt); prof_var_cnt++;}
     if(depletion_fleet>0  && depletion_type<2 && selparm_PH(k)>0) selparm_PH(k)++;
     if(selparm_PH(k) > Turn_off_phase2) selparm_PH(k) =-1;
     if(selparm_PH(k) > max_phase) max_phase=selparm_PH(k);
     if(selparm_PH(k)>=0)
    {
      active_count++; active_parm(active_count)=ParCount;
    }
   }

  if(Do_TG>0)
  {
    for (k=1;k<=3*N_TG+2*Nfleet1;k++)
    {
      ParCount++;
      if(depletion_fleet>0  && depletion_type<2 && TG_parm_PH(k)>0) TG_parm_PH(k)++;
      if(TG_parm_PH(k) > Turn_off_phase2) TG_parm_PH(k) =-1;
      if(TG_parm_PH(k) > max_phase) max_phase=TG_parm_PH(k);
      if(TG_parm_PH(k)>=0)
      {
      active_count++; active_parm(active_count)=ParCount;
      }
    }
  }
  
   if(timevary_cnt>0)
   {
     for (j=1;j<=timevary_cnt;j++)  //  loop all timevary to set up devs; note that 2D_AR1 is counted in N_parm_dev, but not in timevary_cnt
     {
       ivector timevary_setup(1,14);
       timevary_setup(1,14)=timevary_def[j](1,14);
       if(timevary_setup(8)>0)
       {
         k=timevary_setup(8);  //  dev vector used
         if(depletion_fleet>0 && depletion_type<2 && parm_dev_PH(k)>0) parm_dev_PH(k)++;//  add 1 to phase if using depletion fleet
         if(parm_dev_PH(k)>Turn_off_phase2) parm_dev_PH(k) =-1;
         if(parm_dev_PH(k)>max_phase) max_phase=parm_dev_PH(k);
       }
     }
   }

   if(TwoD_AR_cnt>0)
   {
     for (j=1;j<=TwoD_AR_cnt;j++)  //  loop all timevary to set up devs; note that 2D_AR1 is counted in N_parm_dev, but not in timevary_cnt
     {
       ivector TwoD_AR_setup(1,13);
       TwoD_AR_setup(1,13)=TwoD_AR_def[j](1,13);
       if(TwoD_AR_setup(12)>0)
       {
         k=TwoD_AR_setup(12);  //  dev vector used
         if(depletion_fleet>0 && depletion_type<2 && parm_dev_PH(k)>0) parm_dev_PH(k)++;//  add 1 to phase if using depletion fleet
         if(parm_dev_PH(k)>Turn_off_phase2) parm_dev_PH(k) =-1;
         if(parm_dev_PH(k)>max_phase) max_phase=parm_dev_PH(k);
       }
     }
   }

  if(N_parm_dev>0)
  {
    for(k=1;k<=N_parm_dev;k++)
    {
      for(y=parm_dev_minyr(k);y<=parm_dev_maxyr(k);y++)
      {
        ParCount++;
        if(parm_dev_PH(k)>=0)
        {
         active_count++; active_parm(active_count)=ParCount;
        }
      }
    }
  }

  if(Do_Forecast>0 && Turn_off_phase>0)
  {
    if(Fcast_recr_PH==0)  // read value for forecast_PH.  This code is repeats earlier code in case other parameters have changed maxphase
    {
      if(depletion_fleet>0 && depletion_type==1)
        {}
        else
        {Fcast_recr_PH2=max_phase+1;}
    }
  }

  echoinput<<"ParCount "<<ParCount<<"   Active parameters: "<<active_count<<endl<<"Turn_off_phase "<<Turn_off_phase<<endl<<" max_phase "<<max_phase<<endl;
  echoinput<<active_parm.indexmax()<<endl;

  if(Turn_off_phase<=0)
  {func_eval(1)=1;}
  else
  {
     func_conv(max_phase)=final_conv;  func_eval(max_phase)=10000;
     func_conv(max_phase+1)=final_conv;  func_eval(max_phase+1)=10000;
  }

  //  SS_Label_Info_4.14.3 #Add count of derived quantities and create labels for these quantities
    j=ParCount;
    active_parms=active_count;
    CoVar_Count=active_count;
    deriv_start=ParCount;
    deriv_covar_start=active_count;
  echoinput<<"parm "<<j<<" covar "<<CoVar_Count<<endl;
  echoinput<<"deriv_start "<<deriv_start<<" "<<deriv_covar_start<<endl;
  onenum="    ";
  for (y=styr-2;y<=YrMax;y++)
  {
    if(STD_Yr_Reverse(y)>0)
    {
    CoVar_Count++; j++; active_parm(CoVar_Count)=j;
    if(y==styr-2)
    {ParmLabel+="SSB_Virgin";}
    else if(y==styr-1)
    {ParmLabel+="SSB_Initial";}
    else
    {
//      _itoa(y,onenum,10);
      sprintf(onenum, "%d", y);
      ParmLabel+="SSB_"+onenum+CRLF(1);
    }
    }
  }

  echoinput<<"parm "<<j<<" covar "<<CoVar_Count<<endl;
  for (y=styr-2;y<=YrMax;y++)
  {
    if(STD_Yr_Reverse(y)>0)
    {
    CoVar_Count++; j++; active_parm(CoVar_Count)=j;
    if(y==styr-2)
    {ParmLabel+="Recr_Virgin";
      }
    else if(y==styr-1)
    {ParmLabel+="Recr_Initial";
      }
    else
    {
//      _itoa(y,onenum,10);
     sprintf(onenum, "%d", y);
      ParmLabel+="Recr_"+onenum+CRLF(1);
    }
  }
  }

  echoinput<<"parm "<<j<<" covar "<<CoVar_Count<<endl;
  for (y=styr;y<=YrMax;y++)
  {
    if(STD_Yr_Reverse_Ofish(y)>0)
    {
      CoVar_Count++; j++; active_parm(CoVar_Count)=j;
//      _itoa(y,onenum,10);
      sprintf(onenum, "%d", y);
      ParmLabel+="SPRratio_"+onenum+CRLF(1);
    }
  }

  //F_std
  echoinput<<"parm "<<j<<" covar "<<CoVar_Count<<endl;
  for (y=styr;y<=YrMax;y++)
  {
    if(STD_Yr_Reverse_F(y)>0)
    {
      CoVar_Count++; j++; active_parm(CoVar_Count)=j;
//      _itoa(y,onenum,10);
      sprintf(onenum, "%d", y);
      ParmLabel+="F_"+onenum+CRLF(1);
    }
  }

  echoinput<<"parm "<<j<<" covar "<<CoVar_Count<<endl;
  for (y=styr;y<=YrMax;y++)
  {
    if(STD_Yr_Reverse_Dep(y)>0)
    {
      CoVar_Count++; j++; active_parm(CoVar_Count)=j;
//      _itoa(y,onenum,10);
    sprintf(onenum, "%d", y);
    ParmLabel+="Bratio_"+onenum+CRLF(1);
    }
  }
  echoinput<<"parm "<<j<<" covar "<<CoVar_Count<<endl;
//  create labels for Mgmt_Quant
  if(Do_Benchmark>0)
    {
      ParmLabel+="SSB_unfished"+CRLF(1); CoVar_Count++; j++; active_parm(CoVar_Count)=j;
      ParmLabel+="Totbio_unfished"+CRLF(1); CoVar_Count++; j++; active_parm(CoVar_Count)=j;
      ParmLabel+="SmryBio_unfished"+CRLF(1); CoVar_Count++; j++; active_parm(CoVar_Count)=j;
      ParmLabel+="Recr_unfished"+CRLF(1); CoVar_Count++; j++; active_parm(CoVar_Count)=j;
      if(Do_Benchmark==1)
      {
        ParmLabel+="SSB_Btgt"+CRLF(1); CoVar_Count++; j++; active_parm(CoVar_Count)=j;
        ParmLabel+="SPR_Btgt"+CRLF(1); CoVar_Count++; j++; active_parm(CoVar_Count)=j;
        ParmLabel+="annF_Btgt"+CRLF(1); CoVar_Count++; j++; active_parm(CoVar_Count)=j;
        ParmLabel+="Dead_Catch_Btgt"+CRLF(1); CoVar_Count++; j++; active_parm(CoVar_Count)=j;
      }
      else if(Do_Benchmark==2)
      {
        ParmLabel+="SSB_F01"+CRLF(1); CoVar_Count++; j++; active_parm(CoVar_Count)=j;
        ParmLabel+="SPR_F01"+CRLF(1); CoVar_Count++; j++; active_parm(CoVar_Count)=j;
        ParmLabel+="annF_F01"+CRLF(1); CoVar_Count++; j++; active_parm(CoVar_Count)=j;
        ParmLabel+="Dead_Catch_F01"+CRLF(1); CoVar_Count++; j++; active_parm(CoVar_Count)=j;
      }
      ParmLabel+="SSB_SPR"+CRLF(1); CoVar_Count++; j++; active_parm(CoVar_Count)=j;
      ParmLabel+="annF_SPR"+CRLF(1); CoVar_Count++; j++; active_parm(CoVar_Count)=j;
      ParmLabel+="Dead_Catch_SPR"+CRLF(1); CoVar_Count++; j++; active_parm(CoVar_Count)=j;
      ParmLabel+="SSB_MSY"+CRLF(1); CoVar_Count++; j++; active_parm(CoVar_Count)=j;
      ParmLabel+="SPR_MSY"+CRLF(1); CoVar_Count++; j++; active_parm(CoVar_Count)=j;
      ParmLabel+="annF_MSY"+CRLF(1); CoVar_Count++; j++; active_parm(CoVar_Count)=j;
      ParmLabel+="Dead_Catch_MSY"+CRLF(1); CoVar_Count++; j++; active_parm(CoVar_Count)=j;
      ParmLabel+="Ret_Catch_MSY"+CRLF(1); CoVar_Count++; j++; active_parm(CoVar_Count)=j;
      ParmLabel+="B_MSY/SSB_unfished"+CRLF(1); CoVar_Count++; j++; active_parm(CoVar_Count)=j;
    }
    else
    {
      ParmLabel+="Bzero_again"+CRLF(1); CoVar_Count++; j++; active_parm(CoVar_Count)=j;
      ParmLabel+="Totbio_unfished"+CRLF(1); CoVar_Count++; j++; active_parm(CoVar_Count)=j;
      ParmLabel+="SmryBio_unfished"+CRLF(1); CoVar_Count++; j++; active_parm(CoVar_Count)=j;
      ParmLabel+="Recr_unfished"+CRLF(1); CoVar_Count++; j++; active_parm(CoVar_Count)=j;
    }

  echoinput<<"parm "<<j<<" covar "<<CoVar_Count<<"  after benchmark "<<endl;
    if(Do_Forecast>0)
    {
      for (y=endyr+1;y<=YrMax;y++)
      {
        CoVar_Count++; j++; active_parm(CoVar_Count)=j;
        sprintf(onenum, "%d", y);
        ParmLabel+="ForeCatch_"+onenum+CRLF(1);
      }
      for (y=endyr+1;y<=YrMax;y++)
      {
        CoVar_Count++; j++; active_parm(CoVar_Count)=j;
        sprintf(onenum, "%d", y);
        ParmLabel+="OFLCatch_"+onenum+CRLF(1);
      }
      if(max(Do_Retain)>0)
      {
        for (y=endyr+1;y<=YrMax;y++)
        {
          CoVar_Count++; j++; active_parm(CoVar_Count)=j;
          sprintf(onenum, "%d", y);
          ParmLabel+="ForeCatchret_"+onenum+CRLF(1);
        }
      }
    }
  echoinput<<"parm "<<j<<" covar "<<CoVar_Count<<"  after forecast "<<endl;

// do labels for Selex_Std
    if(Do_Selex_Std>0)
    {
      echoinput<<" do selex std labels "<<Selex_Std_Cnt<<" "<<Selex_Std_AL<<endl;
      for (g=1;g<=gender;g++)
      for (i=1;i<=Selex_Std_Cnt;i++)
      {
        CoVar_Count++; j++; active_parm(CoVar_Count)=j;
        if(Selex_Std_AL==1)
        {
          if(Selex_Std_Pick(i)>nlength)
          {
            N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" "<<" cannot select stdev for length bin greater than nlength "<<Selex_Std_Pick(i)<<" > "<<nlength<<endl; exit(1);
          }
          ParmLabel+="LenSelex_std_"+NumLbl(Do_Selex_Std)+"_"+GenderLbl(g)+"_L_"+NumLbl(len_bins(Selex_Std_Pick(i)))+CRLF(1);
        }
        else if(Selex_Std_AL==2)
        {
          if(Selex_Std_Pick(i)>nages)
          {
            N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" "<<" cannot select stdev for age bin greater than maxage "<<Selex_Std_Pick(i)<<" > "<<nages<<endl; exit(1);
          }
          ParmLabel+="AgeSelex_std_"+NumLbl(Do_Selex_Std)+"_"+GenderLbl(g)+"_A_"+NumLbl0(age_vector(Selex_Std_Pick(i))+1)+CRLF(1);
        }
        else if(Selex_Std_AL==3)
        {
          if(Selex_Std_Pick(i)>nages)
          {
            N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" "<<" cannot select stdev for age bin greater than maxage "<<Selex_Std_Pick(i)<<" > "<<nages<<endl; exit(1);
          }
          ParmLabel+="AgeLenSelex_std_"+NumLbl(Do_Selex_Std)+"_"+GenderLbl(g)+"_A_"+NumLbl0(age_vector(Selex_Std_Pick(i))+1)+CRLF(1);
        }
      }
    }
    if(Do_Growth_Std>0)
    {
      echoinput<<" do growth std labels "<<Growth_Std_Cnt<<endl;
      for (g=1;g<=gender;g++)
      for (i=1;i<=Growth_Std_Cnt;i++)
      {
        CoVar_Count++; j++; active_parm(CoVar_Count)=j;
        ParmLabel+="Grow_std_GP:_"+NumLbl(Do_Growth_Std)+"_"+GenderLbl(g)+"_A_"+NumLbl0(age_vector(Growth_Std_Pick(i))+1)+CRLF(1);
      }
    }

    if(Do_NatAge_Std!=0)
    {
      echoinput<<" do natage std labels "<<NatAge_Std_Cnt<<endl;
      for (g=1;g<=gender;g++)
      for (i=1;i<=NatAge_Std_Cnt;i++)
      {
        CoVar_Count++; j++; active_parm(CoVar_Count)=j;
        if(Do_NatAge_Std>0)
        {ParmLabel+="NatAge_std_"+NumLbl(Do_NatAge_Std)+"_"+GenderLbl(g)+"_A_"+NumLbl0(age_vector(NatAge_Std_Pick(i))+1)+CRLF(1);}
        else
        {ParmLabel+="NatAge_std_All_"+GenderLbl(g)+"_A_"+NumLbl0(age_vector(NatAge_Std_Pick(i))+1)+CRLF(1);}
      }
    }

    if(Do_NatM_Std>0)
    {
      echoinput<<" do NatM std labels "<<NatM_Std_Cnt<<endl;
      for (g=1;g<=gender;g++)
      for (i=1;i<=NatM_Std_Cnt;i++)
      {
        CoVar_Count++; j++; active_parm(CoVar_Count)=j;
        // cout<<"i: "<<i<<endl;
        // cout<<"NatM_Std_Pick(i): "<<NatM_Std_Pick(i)<<endl;
        // cout<<"age_vector(NatM_Std_Pick(i)): "<<age_vector(NatM_Std_Pick(i))<<endl;
        // cout<<"NumLbl0(age_vector(NatM_Std_Pick(i))+1): "<<NumLbl0(age_vector(NatM_Std_Pick(i))+1)<<endl;
        ParmLabel+="NatM_std_GP:_"+NumLbl(Do_NatM_Std)+"_"+GenderLbl(g)+"_A_"+NumLbl0(age_vector(NatM_Std_Pick(i))+1)+CRLF(1);
      }
    }

    if(Do_Dyn_Bzero>0)
    {
      echoinput<<" do Dyn Bzero std labels "<<endl;
        CoVar_Count++; j++; active_parm(CoVar_Count)=j;
        ParmLabel+="Dyn_Bzero_Virg"+CRLF(1);
        CoVar_Count++; j++; active_parm(CoVar_Count)=j;
        ParmLabel+="Dyn_Bzero_InitEq"+CRLF(1);
      for (y=styr;y<=YrMax;y++)
      {
        CoVar_Count++; j++; active_parm(CoVar_Count)=j;
        sprintf(onenum, "%d", y);
        ParmLabel+="Dyn_Bzero_"+onenum+CRLF(1);
      }
    }
    if(More_Std_Input(12)==2)
    {
      echoinput<<" do Dyn Bzero Recruits std labels "<<endl;
        CoVar_Count++; j++; active_parm(CoVar_Count)=j;
        ParmLabel+="Dyn_Recr_Virg"+CRLF(1);
        CoVar_Count++; j++; active_parm(CoVar_Count)=j;
        ParmLabel+="Dyn_Recr_InitEq"+CRLF(1);
      for (y=styr;y<=YrMax;y++)
      {
        CoVar_Count++; j++; active_parm(CoVar_Count)=j;
        sprintf(onenum, "%d", y);
        ParmLabel+="Dyn_Recr_"+onenum+CRLF(1);
      }
    }

    //  output ln(SPB) std for selected years
    echoinput<<" do ln(SPB) std labels for 3 years"<<endl;
    CoVar_Count++; j++; active_parm(CoVar_Count)=j;
    sprintf(onenum, "%d", styr);
    ParmLabel+="ln(SPB)_"+onenum+CRLF(1);
    CoVar_Count++; j++; active_parm(CoVar_Count)=j;
    sprintf(onenum, "%d", int((endyr+styr)/2));
    ParmLabel+="ln(SPB)_"+onenum+CRLF(1);
    CoVar_Count++; j++; active_parm(CoVar_Count)=j;
    sprintf(onenum, "%d", endyr);
    ParmLabel+="ln(SPB)_"+onenum+CRLF(1);

  //  output Svy_sdreport value std for selected years
  echoinput<<" do Svy_sdreport labels "<<Svy_N_sdreport<<endl;
  if(Svy_N_sdreport>0)
  {
    k=0;
    for (f = 1; f <= Nfleet; ++f)
    {
      if (Svy_sdreport(f) > 0)
      {
        for (i=1;i<=Svy_N_fleet(f);i++)
        {
          CoVar_Count++; j++; active_parm(CoVar_Count)=j;
          sprintf(onenum, "%d", Svy_yr(f,i));
          ParmLabel+=fleetname(f)+"_"+onenum+CRLF(1);
        }
      }
    }
  }

  // additional labels
  echoinput<<"parm "<<j<<" covar "<<CoVar_Count<<"  after all derived quantities "<<endl;
   sprintf(onenum, "%d", int(100*depletion_level));
   switch(depletion_basis)
    {
      case 0:
      {
        depletion_basis_label+="no_depletion_basis";
        break;
      }
      case 1:
      {
        depletion_basis_label+=" "+onenum+"%*Virgin_Biomass";
        break;
      }
      case 2:
      {
        depletion_basis_label+=" "+onenum+"%*B_MSY";
        break;
      }
      case 3:
      {
        depletion_basis_label+=" "+onenum+"%*StartYr_Biomass";
        break;
      }
      case 4:
      {
        depletion_basis_label+=" "+onenum+"%*EndYr_Biomass";
        break;
      }
    }
    if(depletion_log==1) depletion_basis_label+=";log";
    if(depletion_multi>1) 
    	{
    	sprintf(onenum, "%d", depletion_multi);
    	depletion_basis_label+=";multi:"+onenum;
    	}
    	
   switch (SPR_reporting)
  {
    case 0:      // keep as raw value
    {
      SPR_report_label+=" raw_SPR";
      break;
    }
    case 1:  // compare to SPR
    {
      sprintf(onenum, "%d", int(100.*SPR_target));
      SPR_report_label+=" (1-SPR)/(1-SPR_"+onenum+"%)";
      break;
    }
    case 2:  // compare to SPR_MSY
    {
      SPR_report_label+=" (1-SPR)/(1-SPR_MSY)";
      break;
    }
    case 3:  // compare to SPR_Btarget
    {
      sprintf(onenum, "%d", int(100.*BTGT_target));
      SPR_report_label+=" (1-SPR)/(1-SPR_at_B"+onenum+"%)";
      break;
    }
    case 4:
    {
      SPR_report_label+=" 1-SPR";
      break;
    }
  }

  switch (F_std_basis)
  {
    case 0:  // raw
    {
      F_report_label="_abs_F";
      break;
    }
    case 1:
    {
      sprintf(onenum, "%d", int(100.*SPR_target));
      F_report_label="(F)/(F"+onenum+"%SPR)";
      break;
    }
    case 2:
    {
      F_report_label="(F)/(Fmsy)";
      break;
    }
    case 3:
    {
      sprintf(onenum, "%d", int(100.*BTGT_target));
      F_report_label="(F)/(F_at_B"+onenum+"%)";
      break;
    }
  }

   switch (F_reporting)
  {
    case 0:      // keep as raw value
    {
      F_report_label+=";_no_F_report";
      break;
    }
    case 1:      // exploitation rate in biomass
    {
      F_report_label+=";_with_F=Exploit(bio)";
      break;
    }
    case 2:      // exploitation rate in numbers
    {
      F_report_label+=";_with_F=Exploit(num)";
      break;
    }
    case 3:      // sum of F mults
    {
      F_report_label+=";_with_F=sum(full_Fs)";
      break;
    }
    case 4:      // F=Z-M for specified ages
    {
      F_report_label+=";_with_F=Z-M;_for_ages_";
      sprintf(onenum, "%d", int(F_reporting_ages(1)));
      F_report_label+=onenum;
      sprintf(onenum, "%d", int(F_reporting_ages(2)));
      F_report_label+="_"+onenum;
      break;
    }
    case 5:      // F=Z-M for specified ages (unweighted)
    {
      F_report_label+=";_with_F=Z-M;_for_ages_unweighted_";
      sprintf(onenum, "%d", int(F_reporting_ages(1)));
      F_report_label+=onenum;
      sprintf(onenum, "%d", int(F_reporting_ages(2)));
      F_report_label+="_"+onenum;
      break;
    }    
  }
    if(F_std_log==1) F_report_label+=";log";
    if(F_std_multi>1) 
    	{
    	sprintf(onenum, "%d", F_std_multi);
    	F_report_label+=";multi:"+onenum;
    	}

  echoinput<<"Active parameters plus derived quantities:  "<<CoVar_Count<<endl;
 END_CALCS

//  containers for parameter values after jitter
    vector MGparm_use(1,N_MGparm2)
    vector SR_parm_use(1,N_SRparm3);
    vector recdev_cycle_use(1,recdev_cycle);
    vector recdev_use(recdev_first,YrMax);
    vector recdev_RD(recdev_first,YrMax);
    vector Q_parm_use(1,Q_Npar2);
    vector init_F_use(1,N_init_F);
    vector Fparm_use(1,N_Fparm);
    vector selparm_use(1,N_selparm2);
   !!k=Do_TG*(3*N_TG+2*Nfleet1);
    vector TG_parm_use(1,k);
    matrix parm_dev_RD(1,N_parm_dev,parm_dev_minyr,parm_dev_maxyr);
    matrix parm_dev_use(1,N_parm_dev,parm_dev_minyr,parm_dev_maxyr);

  !!k=gmorph*(YrMax-styr+1);
!!//  SS_Label_Info_4.14.4 #Create matrix CoVar and set it to receive the covariance output
  matrix save_G_parm(1,k,1,22);
  matrix save_seas_parm(1,nseas,1,10);
  matrix CoVar(1,CoVar_Count,1,CoVar_Count+1);
  !!save_G_parm.initialize();
  !!CoVar.initialize();
  !!set_covariance_matrix(CoVar);

  //  SS_Label_Info_4.15 #Read empirical wt-at-age
  int N_WTage_rd
  int N_WTage_maxage
  int y2
  ivector last_yr_read(-2,Nfleet)
  ivector filled_once(-2,Nfleet)
  
 LOCAL_CALCS
   last_yr_read.initialize();
   filled_once.initialize();
   if(WTage_rd>0)
   {
     ad_comm::change_datafile_name("wtatage.ss");
     *(ad_comm::global_datafile) >>N_WTage_maxage;
     k=7+N_WTage_maxage;
   echoinput<<" N_WTage_max "<<N_WTage_maxage<<endl;
     ender=0;
     do
     {
      dvector tempvec(1,k);
      *(ad_comm::global_datafile) >> tempvec(1,k);
      if(tempvec(1)==-9999.) ender=1;
        echoinput<<tempvec(1,k)<<endl;
        y=abs(tempvec(1));
        f=tempvec(6);
        if(y<9999) last_yr_read(f)=max(y,last_yr_read(f));
        if(y<9999 && tempvec(1)<0) filled_once(f)=y;  //  record latest fill event for this input category
      WTage_in.push_back (tempvec(1,k));
     } while (ender==0);
     N_WTage_rd=WTage_in.size()-1;
     k2=TimeMax_Fcast_std+1;
   }
   else
   {
     N_WTage_rd=0;
     N_WTage_maxage=nages;
     k2=styr;
   }
   echoinput<<" N_WTage_rd "<<N_WTage_rd<<endl;
   echoinput<<" last year read for -2 through Nfleet:  "<<last_yr_read<<endl;
   echoinput<<" latest fill year for -2 through Nfleet:  "<<filled_once<<endl;
 END_CALCS
  vector junkvec2(0,nages)
  4darray WTage_emp(styr-3*nseas,k2,1,gender*N_GP*nseas,-2,Nfleet,0,nages)  //  set to begin period for pop (type=0), or mid period for fleet/survey
// read:  yr, seas, gender, morph, settlement, fleet, <age vec> where first value is for age 0!
// if yr=-yr, then fill remaining years for that seas, growpattern, gender, fleet
// fleet 0 contains begin season pop WT
// fleet -1 contains mid season pop WT
// fleet -2 contains maturity*fecundity
  int f2
 LOCAL_CALCS
  if(WTage_rd>0)
  {
    for(f=-2;f<=Nfleet;f++)
    for(t=styr;t<=k2;t++)
    for(g=1;g<=gmorph;g++)
    for(a=0;a<=nages;a++)
    {WTage_emp(t,g,f,a)=-9999.;}
    if(N_WTage_maxage>nages) N_WTage_maxage=nages;  //  so extra ages being read will be ignored
    dvector tempvec(1,7+N_WTage_maxage);
    for (i=0;i<=N_WTage_rd-1;i++)
    {
//      for(j=1;j<=7+N_WTage_maxage;j++)
//      {
        tempvec(1,7+N_WTage_maxage)=WTage_in[i](1,7+N_WTage_maxage);
//      }
      y=abs(tempvec(1));
      f=tempvec(6);
      if(y<styr) y=styr;
      if(tempvec(1)<0 || (y==last_yr_read(f)&&filled_once(f)==0)) {y2=max(YrMax,endyr+50);} else {y2=y;}  //  allows filling to end of time series
      s=abs(tempvec(2));
      if(tempvec(2)<0) {f2=Nfleet;} else {f2=f;}  //  allows filling all fleets
      gg=tempvec(3);
      gp=tempvec(4);
      birthseas=tempvec(5);
      g=(gg-1)*N_GP*nseas + (gp-1)*nseas + birthseas;
      if(s<=nseas && gg<=gender && gp<=N_GP && birthseas<=nseas && f<=Nfleet)
      {
        for (j=y;j<=y2;j++)  // loop years
        {
          for(k=f;k<=f2;k++)
          {
          t=styr+(j-styr)*nseas+s-1;
          for (a=0;a<=N_WTage_maxage;a++) WTage_emp(t,g,k,a)=tempvec(7+a);
          for (a=N_WTage_maxage;a<=nages;a++) WTage_emp(t,g,f,a)=WTage_emp(t,g,f,N_WTage_maxage);  //  fills out remaining ages, if any
          if(j==y && k==f) echoinput<<"year "<<y<<" s "<<s<<" sex "<<gg<<" gp "<<gp<<" bs "<<birthseas<<" morph "<<g<<" pop/fleet "<<f<<" "<<WTage_emp(t,g,f)(0,min(6,nages))<<endl;
          }
        }
      }
    }
    for(f=-2;f<=Nfleet;f++)
    for(t=styr;t<=k2-1;t++)
    for(g=1;g<=gmorph;g++)
    for(a=0;a<=nages;a++)
    if(WTage_emp(t,g,f,a)==-9999.)
      {N_warn++;  warning<<N_warn<<" "<<"wtatage not assigned for: time, morph, fleet, age: "<<t<<" "<<g<<" "<<f<<" "<<a<<endl;}
      temp=float(Bmark_Yr(2)-Bmark_Yr(1)+1.);  //  get denominator
      echoinput<<" fill benchmark years with mean "<<endl;
      for (f=-2;f<=Nfleet;f++)
      for (g=1;g<=gmorph;g++)
      if(use_morph(g)>0)
      {
        for (s=0;s<=nseas-1;s++)
        {
          junkvec2.initialize();
          for (t=Bmark_t(1);t<=Bmark_t(2);t+=nseas) {junkvec2+=WTage_emp(t+s,GP3(g),f);}
          WTage_emp(styr-3*nseas+s,GP3(g),f)=junkvec2/temp;
        }
      }
    echoinput<<"finished reading empirical wt-at-age.ss"<<endl;
  }
 END_CALCS

