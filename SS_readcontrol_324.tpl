
 LOCAL_CALCS
//********CONTROLS********************************
//  SS_Label_Info_4.0 #Begin Reading from Control File
// /*  SS_Label_Flow  begin reading from control file */
  ad_comm::change_datafile_name(ctlfilename);
  echoinput<<endl<<" Begin reading control file "<<endl;
  cout<<" reading from control  file"<<endl;
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

!!//  SS_Label_Info_4.2 #Read info for growth patterns, gender, settlement events, platoons
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
  if(N_GP>1)
  {
    N_warn++;
    warning<<"the converter cannot handle N growth patterns > 1;  revise input file before proceeding; SS will exit "<<endl;
    warning<<"all parameter lines associated with the additonal GP's will need to be commented out before re-running"<<endl;
    warning<<"also revise references to GP>1 in the recruitment distribution setup"<<endl;
    exit(1);
  }
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
     {N_warn++; cout<<" EXIT - see warning "<<endl; warning<<" illegal N platoons, must be 1, 3 or 5 "<<N_platoon<<endl; cout<<" exit - see warning "<<endl; exit(1);}

 END_CALCS

!!//  SS_Label_Info_4.2.2  #Define distribution of recruitment(settlement) among growth patterns, areas, months

  int recr_dist_method  //  1=like 3.24; 2=main effects for GP, Settle timing, Area; 3=each Settle entity
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
  {
    recr_dist_method=1;  //  hardwire for 3.24 method
    recr_dist_area=1;
  }
  recr_dist_area=1;  //hardwire for testing
  N_settle_assignments_rd=0;
  N_settle_assignments=1;  // default

  if(N_GP*pop*nseas>1)
  {
    *(ad_comm::global_datafile) >> N_settle_assignments_rd;
    *(ad_comm::global_datafile) >> recr_dist_inx;
    N_settle_assignments=N_settle_assignments_rd;
  }
  else
  {
     recr_dist_inx=0;
  }

  echoinput<<N_settle_assignments<<" Number of GP/area/settle_timing events to read (>=0) "<<endl;
  echoinput<<recr_dist_inx<<" read interaction parameters for GP x area X timing (0/1)"<<endl;
  if(recr_dist_inx>0) {N_warn++; warning<<" recruitment distribution interaction approach not implemented in SS3.30; use option 3 instead in 3.30"<<endl;}
 END_CALCS

  int birthseas;  //  is this still needed??

  matrix settlement_pattern_rd(1,N_settle_assignments,1,4);   //  for each settlement event:  GPat, birthseason, area, age
  ivector settle_assignments_timing(1,N_settle_assignments);  //  stores the settle_timing index for each assignment
  vector settle_timings_tempvec(1,N_settle_assignments)  //  temporary storage for real_month of each settlement_timing
                                                        //  dimensioned by assignments, but only uses N_settle_timings of these
 LOCAL_CALCS
  settlement_pattern_rd.initialize();
  if(recr_dist_method==1 && N_settle_assignments_rd==0)
    {
      {settlement_pattern_rd(1).fill("{1,1,1,0}");}
      echoinput<<" settlement pattern auto-filled "<<endl<<"GPat  Birthseas  Area Age"<<endl<<settlement_pattern_rd<<endl;
    }
    else
    {
      for(j=1;j<=N_settle_assignments_rd;j++)
      {
      *(ad_comm::global_datafile) >> settlement_pattern_rd(j)(1,3);
      }
      echoinput<<" settlement pattern as read "<<endl<<"GPat  Birthseas  Area Age"<<endl<<settlement_pattern_rd<<endl;
    }
    echoinput<<"Now calculate the number of unique settle timings, which will dictate the number of recr_dist_timing parameters "<<endl;
      N_settle_timings=0;
      settle_timings_tempvec.initialize();
      if(N_settle_assignments==0)
      {
        N_settle_timings=1;
        settle_timings_tempvec(1)=1.0;
      }
      else
      {
        for (settle=1;settle<=N_settle_assignments;settle++)
        {
          real_month=1.0 + azero_seas(settlement_pattern_rd(settle,2))*12.;  //  converts birthseason to month
          settlement_pattern_rd(settle,2)=real_month;
          if(N_settle_timings==0)
          {
            N_settle_timings++;
            settle_timings_tempvec(N_settle_timings)=real_month;
            settle_assignments_timing(settle)=N_settle_timings;
          }
          else
          {
            k=0;
            for(j=1;j<=N_settle_timings;j++)
            {
              if(settle_timings_tempvec(j)==real_month) // found matching settle_time
              {
                settle_assignments_timing(settle)=j;
                k=1;
              }
            }
            if(k==0)
            {
              N_settle_timings++;
              settle_timings_tempvec(N_settle_timings)=real_month;
              settle_assignments_timing(settle)=N_settle_timings;
            }
          }
        }
      }
    echoinput<<"N settle timings: "<<N_settle_timings<<endl<<" settle_month: "<<settle_timings_tempvec(1,N_settle_timings)<<endl;
    echoinput<<"settle_assignments_timing: "<<settle_assignments_timing<<endl;
//  SS_Label_Info_4.2.3 #Set-up arrays and indexing for growth patterns, gender, settlements, platoons
 END_CALCS
   int g3i;
//  SPAWN-RECR:   define settlement timings
  ivector Settle_seas(1,N_settle_timings)  //  calculated season in which settlement occurs
  ivector Settle_seas_offset(1,N_settle_timings)  //  calculated number of seasons between spawning and the season in which settlement occurs
  vector  Settle_timing_seas(1,N_settle_timings)  //  calculated elapsed time (frac of year) between settlement and the begin of season in which it occurs
  vector  Settle_month(1,N_settle_timings)  //  month (real)in which settlement occurs
  ivector Settle_age(1,N_settle_timings)  //  calculated age at which settlement occurs, with age 0 being the year in which spawning occurs
  3darray recr_dist_pattern(1,N_GP,1,N_settle_timings,0,pop);  //  has flag to indicate each settlement events
//  NOTE:  in 3.24, recr_dis is by birthseason, so this is dimensioned by nseas; in 3.30, it is dimensioned by number of settle_timings
 LOCAL_CALCS
  Settle_seas_offset.initialize();
  Settle_timing_seas.initialize();
  Settle_age.initialize();
  Settle_seas.initialize();
  recr_dist_pattern.initialize();

  echoinput<<"Calculated assignments in which settlement occurs "<<endl<<"Settle_timing  / Month / seas / seas_from_spawn / time_from_seas_start / age_at_settle"<<endl;
  if(N_settle_assignments>0)
  {
    for (settle=1;settle<=N_settle_assignments;settle++)
    {
      gp=settlement_pattern_rd(settle,1); //  growth patterns
      p=settlement_pattern_rd(settle,3);  //  settlement area
      settle_time=settle_assignments_timing(settle);
      recr_dist_pattern(gp,settle_time,p)=1;  //  indicates that settlement will occur here
      recr_dist_pattern(gp,settle_time,0)=1;  //  for growth updating
      Settle_month(settle_time)=settle_timings_tempvec(settle_time);
    }
    for (settle_time=1;settle_time<=N_settle_timings;settle_time++)
    {
      if(spawn_month>Settle_month(settle_time))
      {
        k=1; Settle_age(settle_time)++;
      }
      else
      {
        k=spawn_seas;  //  earliest possible season for settlement
      }
      temp=azero_seas(k); //  annual elapsed time fraction at begin of this season
      Settle_timing_seas(settle_time)=(Settle_month(settle_time)-1.0)/12.;  //  fraction of year at settlement month
      while((temp+seasdur(k))<=Settle_timing_seas(settle_time))
      {
        temp+=seasdur(k);
        if(k==nseas)
        {k=1; Settle_age(settle_time)++;}
        else
        {k++;}
      }
      if(Settle_age(settle_time)>0)
        {
          N_warn++; warning<<"age at settlement calculated to be: "<<Settle_age(settle_time)<<
          "  for settle_time "<<settle_time<<".  Will be reset to 0 to match 3.24 protocol"<<endl;
        }
      Settle_seas(settle_time)=k;
      Settle_seas_offset(settle_time)=Settle_seas(settle_time)-spawn_seas+Settle_age(settle_time)*nseas;  //  number of seasons between spawning and the season in which settlement occurs
      Settle_age(settle_time)=0;  // set to 0 to match 3.24, but use calculated value in code line above
      Settle_timing_seas(settle_time)-=temp;  //  timing from beginning of this season; needed for mortality calculation
      echoinput<<settle_time<<" / "<<Settle_month(settle_time);
      echoinput<<"  /  "<<Settle_seas(settle_time)<<" / "<<Settle_seas_offset(settle_time)<<" / "
      <<Settle_timing_seas(settle_time)<<"  / "<<Settle_age(settle_time)<<endl;
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
  int ALK_count;
  vector azero_G(1,gmorph);  //  time since Jan 1 at beginning of settlement in which "g" was born
  3darray real_age(1,gmorph,1,nseas*N_subseas,0,nages);  // real age since settlement
  3darray keep_age(1,gmorph,1,nseas*N_subseas,0,nages);  // set to 0.0 if real_age<0.  this allows omitting virtual young fish to be excluded from expected values
  3darray calen_age(1,gmorph,1,nseas*N_subseas,0,nages);  // real age since Jan 1 of birth year

  3darray lin_grow(1,gmorph,1,nseas*N_subseas,0,nages)  //  during linear phase has fraction of Size at Afix
  ivector settle_g(1,gmorph)   //  settlement pattern for each platoon

 LOCAL_CALCS
  ALK_count=0;
  ALK_range_g_lo = 1;
  ALK_range_g_hi = nlength;

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
         GP3(g)=g3i;  // track counter for main morphs (gender x pattern x bseas)
         Bseas(g)=Settle_seas(settle);
         sx(g)=gg;
         GP(g)=gp+(gg-1)*N_GP;   // counter for pattern x gender so gp is nested inside gender
         GP2(g)=gp2; //   reverse pointer to platoon counter
         GP4(g)=gp;  //  counter for growth pattern
         settle_g(g)=settle;  //  to find the settlement timing for this platoon
         azero_G(g)=(Settle_month(settle)-1.0)/12.  ; //  settlement month converted to fraction of year; could be > one year
         for (p=1;p<=pop;p++)
         {
           if(recr_dist_pattern(gp,settle,p)>0.)
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

   echoinput<<"g_start "<<g_Start<<endl;
   echoinput<<"g_finder "<<g_finder<<endl;
   echoinput<<" g  s  subseas  ALK_idx real_age&calen_age"<<endl;
   for (g=1;g<=gmorph;g++)
   for (s=1;s<=nseas;s++)
   for (subseas=1;subseas<=N_subseas;subseas++)
   {
     ALK_idx=(s-1)*N_subseas+subseas;
     real_age(g,ALK_idx)=r_ages+azero_seas(s)-azero_G(g)+double(subseas-1)/double(N_subseas)*seasdur(s);
     calen_age(g,ALK_idx)=real_age(g,ALK_idx)+azero_G(g);
     if(azero_G(g)>=azero_seas(s))
     {
       a=0;
       while(real_age(g,ALK_idx,a)<0.0)
       {keep_age(g,ALK_idx,a)=0.0; real_age(g,ALK_idx,a)=0.0; a++;}
     }
     a=0;
     echoinput<<g<<" "<<s<<" "<<subseas<<" "<<ALK_idx<<" real_age: "<<real_age(g,ALK_idx)<<endl;
     echoinput<<g<<" "<<s<<" "<<subseas<<" "<<ALK_idx<<" cal_age : "<<calen_age(g,ALK_idx)<<endl;
   }
   echoinput<<"done with ALK_idx"<<endl;

    if(N_TG>0)
    {
      for (TG=1;TG<=N_TG;TG++)
      {
        for (g=1;g<=gmorph;g++)
        {
          if(TG_release(TG,6)>2) {N_warn++; warning<<" gender for tag groups must be 0, 1 or 2 "<<endl;}
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
   init_matrix move_def(1,do_migration,1,6)   // seas morph source dest minage maxge
   4darray move_pattern(1,nseas,1,N_GP,1,pop,1,pop)
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
  init_int N_Block_Designs                      // read N block designs
  !!echoinput<<N_Block_Designs<<" N_Block_Designs"<<endl;
  !!echoinput<<"will add one block for year=initial equil yr to replace the R1 offset "<<endl;
  ivector Nblk(1,N_Block_Designs+1)    // N blocks in each design
  ivector Nblk2(1,N_Block_Designs+1)   //  vector to create ragged array of dimensions for block matrix
 LOCAL_CALCS
  if(N_Block_Designs>0)
    {
      for(i=1;i<=N_Block_Designs;i++)  {*(ad_comm::global_datafile) >> Nblk(i);}
    }

    // for the initial equil year
    N_Block_Designs=N_Block_Designs+1;
    Nblk(N_Block_Designs)=1;
    echoinput<<Nblk<<" N_Blocks_per design"<<endl;

    Nblk2=Nblk + Nblk;
 END_CALCS

  imatrix Block_Design(1,N_Block_Designs,1,Nblk2)  // read the begin-end year for each block

 LOCAL_CALCS
  for(i=1;i<=N_Block_Designs-1;i++)
  for(j=1;j<=Nblk2(i);j++)
  {*(ad_comm::global_datafile) >> Block_Design(i,j);}
  Block_Design(N_Block_Designs,1)=styr-1;
  Block_Design(N_Block_Designs,2)=styr-1;

  if(N_Block_Designs>0)
  {
    echoinput<<" read block info "<<endl<<Block_Design<<endl;
    for (j=1;j<=N_Block_Designs;j++)
    {
      a=-1;
      for (k=1;k<=Nblk2(j)/2;k++)
      {
        a+=2;
        if(Block_Design(j,a+1)<Block_Design(j,a)) {N_warn++; cout<<" EXIT - see warning "<<endl; warning<<"Block:"<<j<<" "<<k<<" ends before it starts; fatal error"<<endl; exit(1);}
        if(Block_Design(j,a)<styr-1) {N_warn++; warning<<"Block:"<<j<<" "<<k<<" starts before styr; resetting"<<endl; Block_Design(j,a)=styr;}
        if(Block_Design(j,a+1)<styr-1) {N_warn++; cout<<" EXIT - see warning "<<endl; warning<<"Block:"<<j<<" "<<k<<" ends before styr; fatal error"<<endl; exit(1);}
        if(Block_Design(j,a)>retro_yr+1) {N_warn++; cout<<" EXIT - see warning "<<endl; warning<<"Block:"<<j<<" "<<k<<" starts after retroyr+1; fatal error"<<endl; exit(1);}
        if(Block_Design(j,a+1)>retro_yr+1) {N_warn++; warning<<"Block:"<<j<<" "<<k<<" ends after retroyr+1; resetting"<<endl; Block_Design(j,a+1)=retro_yr+1;}

      }
    }
  }
 END_CALCS

   ivector varparm_estimated(1,5)  // flag to show what types of variance parameters are estimated
   // (1) for growth
   // (2)  for recruitment sigmaR
   // (3)  for survey extraSD
!!  varparm_estimated.initialize();

!!//  SS_Label_Info_4.5 #Read setup and parameters for natmort, growth, biology, recruitment distribution, and migration
// read setup for natmort parameters:  LO, HI, INIT, PRIOR, PR_type, CV, PHASE, use_env, use_dev, dev_minyr, dev_maxyr, dev_stddev, Block, Block_type
  int N_MGparm
  int N_natMparms
  int N_growparms
  int N_M_Grow_parms
  int recr_dist_parms
  imatrix MGparm_point(1,gender,1,N_GP)
  number natM_amin;
  number natM_amax;
  init_number fracfemale;
  number fracfemale_mult;
  !!fracfemale_mult=1.0;  //  multiplier used in female SSB calc
  !!echoinput<<fracfemale<<" fracfemale"<<endl;
  !!if(fracfemale>=1.0) fracfemale=0.999999;
  !!if(fracfemale<=0.0) fracfemale=0.000001;

// read natmort setup
  init_int natM_type;  //  0=1Parm; 1=segmented; 2=Lorenzen; 3=agespecific; 4=agespec with seas interpolate
  !!echoinput<<natM_type<<" natM_type"<<endl;
  !! if(natM_type==1 || natM_type==2) {k=1;} else {k=0;}
  init_vector tempvec4(1,k)
 LOCAL_CALCS
  k=0; k1=0;
  if(natM_type==0)
  {N_natMparms=1;}
  else if(natM_type==1)
  {
    N_natMparms=tempvec4(1);  k=N_natMparms;
    echoinput<<N_natMparms<<" N_natMparms for segmented approach"<<endl;
  }
  else if(natM_type==2)
  {
    natM_amin=tempvec4(1);  N_natMparms=1;
    echoinput<<natM_amin<<" natM_A for Lorenzen"<<endl;
  }
  else
  {
    N_natMparms=0;
    if(natM_type>=3) {k1=N_GP*gender;}  // for reading age_natmort
  }
 END_CALCS

  init_vector NatM_break(1,k);  // these breakpoints only get read for natM_type=1
  !!if(k>0) echoinput<<NatM_break<<" NatM_breakages "<<endl;
  init_matrix Age_NatMort(1,k1,0,nages)
  !!if(k1>0) echoinput<<" Age_NatMort "<<Age_NatMort<<endl;

// read growth setup
  init_int Grow_type  // 1=vonbert; 2=Richards; 3=age-specific K;  4=read vector(not implemented)
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
  !! if(Grow_type<=2) {k=2; do_ageK=0;}  //  AFIX and AFIX2
  !! if (Grow_type==3) {k=3; do_ageK=1;}  //  min and max age for age-specific K
  init_vector tempvec5(1,k)
  int Age_K_count;

 LOCAL_CALCS
  Age_K_count=0;
  if(k>0) echoinput<<tempvec5<<" growth specifications"<<endl;
  k1=0;
  AFIX=0.;
  AFIX2=999.;  // this value invokes setting Linf equal to the L2 parameter
  Linf_decay=-999.;  //  will do 0.2 to match 3.24
  if(Grow_type==1)
  {
    N_growparms=5;
    AFIX=tempvec5(1);
    AFIX2=tempvec5(2);
  }
  else if(Grow_type==2)
  {
    N_growparms=6;
    AFIX=tempvec5(1);
    AFIX2=tempvec5(2);
  }
  else if(Grow_type==3)
  {
    AFIX=tempvec5(1);
    AFIX2=tempvec5(2);
    Age_K_count=tempvec5(3);
    N_growparms=5+Age_K_count;;
  }
  else if(Grow_type==4)
  {
    N_growparms=2;  // for the two CV parameters
    k1=N_GP*gender;  // for reading age_natmort
  }
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
        if(a==0 && s<Bseas(g))
          {lin_grow(g,ALK_idx,a)=0.0;}  //  so fish are not yet born so will get zero length
        else if(real_age(g,ALK_idx,a)<AFIX)
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

        if(lin_grow(g,ALK_idx,a)>-2.0) echoinput<<g<<" "<<a<<" "<<s<<" "<<subseas<<" "<<ALK_idx<<" "<<real_age(g,ALK_idx,a)
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
//   if(CV_depvar==0 || CV_depvar==2)
//     {CV_depvar_a=0;}
//   else
//     {CV_depvar_a=1;}
//   if(CV_depvar<=1)
//     {CV_depvar_b=0;}
//   else
//     {CV_depvar_b=1;}

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
                                  // 4= read age-fecundity by growth_pattern 5=read all from separate wtatage.ss file
                                  //  6=read length-maturity
 int WTage_rd

 LOCAL_CALCS
  WTage_rd=0;
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
    WTage_rd=1;
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
  !! if(Fecund_Option>5) {N_warn++; cout<<" EXIT - see warning "<<endl; warning<<"Illegal fecundity option:  "<<Fecund_Option<<endl; exit(1);}
  init_int Hermaphro_Option
  int MGparm_Hermaphro  // pointer to start of these parameters
  !! echoinput<<Hermaphro_Option<<"  Hermaphro_Option "<<endl;
  !! MGparm_Hermaphro=0;
  !! k=0;
  !! if(Hermaphro_Option!=0) k=2;
  init_ivector Hermaphro_more(1,k);
  int Hermaphro_seas;
  int Hermaphro_maleSPB;
 LOCAL_CALCS
  Hermaphro_seas=0;
  Hermaphro_maleSPB=0;
  if (k>0)
  {
    Hermaphro_seas=Hermaphro_more(1);
    Hermaphro_maleSPB=Hermaphro_more(2);
    echoinput<<Hermaphro_seas<<"  Hermaphro_season "<<endl;
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
   init_int parm_adjust_method   //  1=do V1.xx approach to adjustment by env, block or dev; 2=use new logistic approach
   !! echoinput<<parm_adjust_method<<"  timevarying parameter constraint method"<<endl;
   ivector autogen_timevary(1,5);  //  0 means to autogenerate all time-vary parameters; 1 means to read
  int do_once;
  int doit;

  int MGP_CGD
  int CGD_onoff;  //  switch for cohort growth dev
  int ParCount2
  int  parm_adjust_method_rd
 LOCAL_CALCS
  autogen_timevary=0;
  parm_adjust_method_rd=parm_adjust_method;
    if(parm_adjust_method==2)
    {
      N_warn++;
      warning<<" Only parm_adjust_method 1 and 3 implemented in SS3.30; resetting value to 1 "<<endl;
      parm_adjust_method=1;
    }

  ParCount=0;
  retParCount=0;    // for 3.24 -> 3.30 dome-shaped retention

//  SS_Label_Info_4.5.3 #Set up indexing and parameter names for MG parameters
  for (gg=1;gg<=gender;gg++)
  {
    for (gp=1;gp<=N_GP;gp++)
    {
      MGparm_point(gg,gp)=ParCount+1;  //  starting pointer
      for (k=1;k<=N_natMparms;k++)
      {
        ParCount++;
        onenum="    ";
        sprintf(onenum, "%d", k);
        ParmLabel+="NatM_p_"+onenum+"_"+GenderLbl(gg)+"_GP_"+NumLbl(gp);
      }
      switch (Grow_type)
      {
        case 1:
        {
          ParmLabel+="L_at_Amin_"+GenderLbl(gg)+"_GP_"+NumLbl(gp);
          ParmLabel+="L_at_Amax_"+GenderLbl(gg)+"_GP_"+NumLbl(gp);
          ParmLabel+="VonBert_K_"+GenderLbl(gg)+"_GP_"+NumLbl(gp);
          ParCount+=3;
          break;
        }
        case 2:
        {
          ParmLabel+="L_at_Amin_"+GenderLbl(gg)+"_GP_"+NumLbl(gp);
          ParmLabel+="L_at_Amax_"+GenderLbl(gg)+"_GP_"+NumLbl(gp);
          ParmLabel+="VonBert_K_"+GenderLbl(gg)+"_GP_"+NumLbl(gp);
          ParmLabel+="Richards_"+GenderLbl(gg)+"_GP_"+NumLbl(gp);
          ParCount+=4;
          break;
        }
        case 3:
        {
          ParmLabel+="L_at_Amin_"+GenderLbl(gg)+"_GP_"+NumLbl(gp);
          ParmLabel+="L_at_Amax_"+GenderLbl(gg)+"_GP_"+NumLbl(gp);
          ParmLabel+="VonBert_K_"+GenderLbl(gg)+"_GP_"+NumLbl(gp);
          ParCount+=3;
          for (a=1;a<=Age_K_count;a++)
          {
            ParmLabel+="Age_K_"+GenderLbl(gg)+"_GP_"+NumLbl(gp)+"_a_"+NumLbl(Age_K_points(a));
            ParCount++;
          }
          break;
        }
      }
      ParmLabel+="CV_young_"+GenderLbl(gg)+"_GP_"+NumLbl(gp);
      ParmLabel+="CV_old_"+GenderLbl(gg)+"_GP_"+NumLbl(gp);
      ParCount+=2;
      ParmLabel+="Wtlen_1_"+GenderLbl(gg);
      ParmLabel+="Wtlen_2_"+GenderLbl(gg);
      ParCount+=2;
      if(gg==1)  //  add parms for maturity and fecundity for females only
      {
        ParmLabel+="Mat50%_"+GenderLbl(1);
        ParmLabel+="Mat_slope_"+GenderLbl(1);
        ParCount+=2;
        if(Fecund_Option==1)
        {
          ParmLabel+="Eggs/kg_inter_"+GenderLbl(1);
          ParmLabel+="Eggs/kg_slope_wt_"+GenderLbl(1);
          ParCount+=2;
        }
        else if(Fecund_Option==2)
        {
          ParmLabel+="Eggs_scalar_"+GenderLbl(1);
          ParmLabel+="Eggs_exp_len_"+GenderLbl(1);
          ParCount+=2;
        }
        else if(Fecund_Option==3)
        {
          ParmLabel+="Eggs_scalar_"+GenderLbl(1);
          ParmLabel+="Eggs_exp_wt_"+GenderLbl(1);
          ParCount+=2;
        }
        else if(Fecund_Option==4)
        {
          ParmLabel+="Eggs_intercept_"+GenderLbl(1);
          ParmLabel+="Eggs_slope_len_"+GenderLbl(1);
          ParCount+=2;
        }
        else if(Fecund_Option==5)
        {
          ParmLabel+="Eggs_intercept_"+GenderLbl(1);
          ParmLabel+="Eggs_slope_Wt_"+GenderLbl(1);
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
  ParCount2=ParCount;
  for (k=1;k<=N_GP;k++) {ParCount++; ParCount2++; ParmLabel+="RecrDist_GP_"+NumLbl(k);}
  for (k=1;k<=pop;k++)  {ParCount++; ParCount2++; ParmLabel+="RecrDist_Area_"+NumLbl(k);}
  for (k=1;k<=nseas;k++)
  {
    ParCount++;
    if(k<=N_settle_timings)
    {
      ParCount2++; ParmLabel+="RecrDist_timing_"+NumLbl(k);
    }
  }

  if(recr_dist_inx==1) // add for the morph assignments within each area
  {
    for (gp=1;gp<=N_GP;gp++)
    for (p=1;p<=pop;p++)
    for (s=1;s<=nseas;s++)
    {
      ParCount++;
      if(k<=N_settle_timings)
      {
        ParCount2++; ParmLabel+="RecrDist_interaction_GP_"+NumLbl(gp)+"_area_"+NumLbl(p)+"_settle_"+NumLbl(s);
      }
    }
  }

  MGP_CGD=ParCount2+1;  // pointer to cohort growth deviation base parameter
  ParCount++; ParCount2++;
  ParmLabel+="CohortGrowDev";

  if(do_migration>0)
  {
   for (k=1;k<=do_migration;k++)
     {
     s=move_def(k,1); gp=move_def(k,2); p=move_def(k,3); p2=move_def(k,4);
     ParCount++; ParCount2++; ParmLabel+="MoveParm_A_seas_"+NumLbl(s)+"_GP_"+NumLbl(gp)+"from_"+NumLbl(p)+"to_"+NumLbl(p2);
     ParCount++; ParCount2++; ParmLabel+="MoveParm_B_seas_"+NumLbl(s)+"_GP_"+NumLbl(gp)+"from_"+NumLbl(p)+"to_"+NumLbl(p2);
    }
  }

  if(Use_AgeKeyZero>0)
  {
    AgeKeyParm=ParCount2+1;
    for (k=1;k<=7;k++)
    {
       ParCount++; ParCount2++; ParmLabel+="AgeKeyParm"+NumLbl(k);
    }
  }

  catch_mult_pointer=-1;
  j=sum(need_catch_mult);  //  number of fleets needing a catch multiplier parameter
  if(j>0) {catch_mult_pointer=ParCount+1;}
  for(j=1;j<=Nfleet;j++)
  {
    if(need_catch_mult(j)==1)
    {
      ParCount++; ParCount2++; ParmLabel+="Catch_Mult:_"+NumLbl(j)+"_"+fleetname(j);
    }
  }
  N_MGparm=ParCount2;

  frac_female_pointer=-1;   // indicates 3.24 version

 END_CALCS

  init_matrix MGparm_rd(1,ParCount,1,14)   // matrix with natmort and growth parms controls
  ivector MGparm_offset(1,N_MGparm)
  ivector mgp_type(1,N_MGparm)  //  contains category to parameter (1=natmort; 2=growth; 3=wtlen & fec; 4=recr_dist; 5=movement)
  matrix MGparm_1(1,N_MGparm,1,14)  // reduced size matrix after switch from bseas to N_settlement_timings
  matrix MGparm_2(1,N_MGparm,1,14)  //  re-ordered matrix in 3.30 parm order

 LOCAL_CALCS
  echoinput<<"MGparm as read: "<<endl<<MGparm_rd<<endl<<endl;
//  remove the bseas lines
  for(ParCount=1;ParCount<=recr_dist_parms-1;ParCount++)
  {MGparm_1(ParCount)=MGparm_rd(ParCount);}
  ParCount2=recr_dist_parms-1;  ParCount=recr_dist_parms-1;
  for (k=1;k<=N_GP;k++) {ParCount++; ParCount2++; MGparm_1(ParCount2)=MGparm_rd(ParCount);}
  for (k=1;k<=pop;k++)  {ParCount++; ParCount2++; MGparm_1(ParCount2)=MGparm_rd(ParCount);}
  for (k=1;k<=nseas;k++)
  {
    ParCount++;
    if(k<=N_settle_timings)
    {
       ParCount2++; MGparm_1(ParCount2)=MGparm_rd(ParCount);
    }
  }

  if(recr_dist_inx==1) // add for the morph assignments within each area
  {
    for (gp=1;gp<=N_GP;gp++)
    for (p=1;p<=pop;p++)
    for (s=1;s<=nseas;s++)
    {
      ParCount++;
      if(k<=N_settle_timings)
      {
         ParCount2++; MGparm_1(ParCount2)=MGparm_rd(ParCount);
      }
    }
  }

//  MGP_CGD=ParCount2+1;  // pointer to cohort growth deviation base parameter
  ParCount++; ParCount2++;
  MGparm_1(ParCount2)=MGparm_rd(ParCount);  //  for cohort growth dev

  if(do_migration>0)
  {
   for (k=1;k<=do_migration;k++)
     {
     ParCount++;  ParCount2++; MGparm_1(ParCount2)=MGparm_rd(ParCount);
     ParCount++;  ParCount2++; MGparm_1(ParCount2)=MGparm_rd(ParCount);
    }
  }

  if(Use_AgeKeyZero>0)
  {
//    AgeKeyParm=ParCount2+1;
    for (k=1;k<=7;k++)
    {
       ParCount++;  ParCount2++; MGparm_1(ParCount2)=MGparm_rd(ParCount);
    }
  }
  echoinput<<ParCount<<" "<<ParCount2<<endl;
  echoinput<<MGparm_rd(MGP_CGD)<<endl;
  ParCount=ParCount2;

  echoinput<<"MGparm after bseas to settletime conversion: "<<endl<<MGparm_1<<endl<<endl;

  {
  //set base parm for cohort growth dev to permissable values
  if(MGparm_1(MGP_CGD,3)==0 || (MGparm_1(MGP_CGD,1)==MGparm_1(MGP_CGD,2)))
    {
      MGparm_1(MGP_CGD,1)=0.1;  //min
      MGparm_1(MGP_CGD,2)=10.;  //max
      MGparm_1(MGP_CGD,3)=1.;  //init
      MGparm_1(MGP_CGD,4)=1.;  //prior
      MGparm_1(MGP_CGD,6)=1.;  //  prior_sd
      MGparm_1(MGP_CGD,5)=0.;  //  prior type
      MGparm_1(MGP_CGD,7)=-1.;  // phase
    }

  MGparm_2=MGparm_1;
  j=0;  //  pointer to matrix as read
  for(gg=1;gg<=gender;gg++)
  for(gp=1;gp<=N_GP;gp++)
  for(f=1;f<=N_natMparms+N_growparms;f++)
  {
    j++;
     echoinput<<f<<" to: "<<MGparm_point(gg,gp)+f-1<<" from: "<<j<<endl;
    MGparm_2(MGparm_point(gg,gp)+f-1)=MGparm_1(j);
  }
  //  j now pointing to wtlen for females
  gg=1;
  for(gp=1;gp<=N_GP;gp++)
  {
    for(f=1;f<=6;f++)
    {echoinput<<f<<" to: "<<MGparm_point(gg,gp)+N_natMparms+N_growparms+f-1<<" from: "<<j+f<<endl;
      MGparm_2(MGparm_point(gg,gp)+N_natMparms+N_growparms+f-1)=MGparm_1(j+f);}
  }
  if(gender==2)
    {
      for(gp=1;gp<=N_GP;gp++)
      {
        for(f=1;f<=2;f++)
        echoinput<<f<<" to: "<<MGparm_point(2,gp)+N_natMparms+N_growparms+f-1<<" from: "<<j+6+f<<endl;
        MGparm_2(MGparm_point(2,gp)+N_natMparms+N_growparms+f-1)=MGparm_1(j+6+f);
      }
    }

  MGparm_1=MGparm_2;
  }

  echoinput<<" Biology parameter setup"<<endl;
  for (i=1;i<=N_MGparm;i++)
  {
    echoinput<<i<<" # "<<MGparm_1(i)<<" "<<ParmLabel(i)<<endl;
  }

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

   int timevary_Nread
  int N_MGparm_blk                            // number of MGparms that use blocks
  int N_MGparm_env                          // number of MGparms that use blocks
  int customblocksetup_MG  //  0=read one setup and apply to all; 1=read each
  int customMGenvsetup  //  0=read one setup and apply to all; 1=read each

 LOCAL_CALCS
   customMGenvsetup=0;
   customblocksetup_MG=0;
   CGD_onoff=0;
   gp=0;
   for(gg=1;gg<=gender;gg++)
   for(GPat=1;GPat<=N_GP;GPat++)
   {
     gp++;
     Ip=MGparm_point(gg,GPat);
     mgp_type(Ip,Ip+N_natMparms-1)=1; // natmort parms
     Ip+=N_natMparms;
     mgp_type(Ip,Ip+N_growparms-1)=2;  // growth parms
     Ip=Ip+N_growparms;
     mgp_type(Ip,Ip+1)=3;   // wtlen
     Ip+=2;
     if(gg==1) {mgp_type(Ip,Ip+3)=3;  Ip+=4;}  // maturity and fecundity
   }
   if(Hermaphro_Option!=0) {mgp_type(MGparm_Hermaphro,MGparm_Hermaphro+2)=3;}  //   herma parameters done with wtlen and fecundity
   mgp_type(Ip,MGP_CGD-1)=4;   // recruit apportionments
   mgp_type(MGP_CGD)=2;   // cohort growth dev
   if(do_migration>0)  mgp_type(MGP_CGD+1,N_MGparm)=5;  // note that it fills until end of MGparm list, but some get overwritten
   if(Use_AgeKeyZero>0) mgp_type(AgeKeyParm,N_MGparm)=6;
   if(catch_mult_pointer>0) mgp_type(catch_mult_pointer,N_MGparm)=7;
   if(frac_female_pointer>0) for(f=frac_female_pointer; f<=frac_female_pointer+N_GP-1;f++) mgp_type(f)=3;
   echoinput<<"mgparm_type for each parm: 1=M; 2=growth; 3=wtlen,mat,fec,hermo,sexratio; 4=recr; 5=migr; 6=ageerror; 7=catchmult "<<endl<<mgp_type<<endl;
   echoinput<<"Now read env, block/trend, seasonal, and dev adjustments to MGparms "<<endl;

//   MGparm_env.initialize();   //  will store the index of environ fxns here
//   MGparm_envtype.initialize();
   N_MGparm_env=0;
   for (f=1;f<=N_MGparm;f++)
   {
    if(MGparm_1(f,8)!=0)
    {
     N_MGparm_env ++;
     if(f==MGP_CGD) CGD_onoff=1;    // cohort growth dev is a fxn of environ, so turn on CGD calculation
    }
   }
  if(N_MGparm_env>0)
  {
    *(ad_comm::global_datafile) >> customMGenvsetup;
    if(customMGenvsetup==0) {k1=1;} else {k1=N_MGparm_env;}
   echoinput<<customMGenvsetup<<" customMGenvsetup"<<endl;
  }
  else
  {
    customMGenvsetup=0; k1=0;
    echoinput<<" no mgparm env links, so don't read customMGenvsetup"<<endl;
  }
 END_CALCS

  init_matrix MGparm_env_1(1,k1,1,7)
  !!if(N_MGparm_env>0) echoinput<<" MGparm-env setup "<<endl<<MGparm_env_1<<endl;

 LOCAL_CALCS
   N_MGparm_blk=0;
   for (j=1;j<=N_MGparm;j++)  //  find parms needing block or trend
   {
     z=MGparm_1(j,13);    // specified block or trend definition
     if(z==0)    //  no blocks or trends
     {}
     else
     {
  /*
       timevary_cnt++;
       MGparm_timevary(j)=timevary_cnt;  //  base parameter will use this timevary
       itempvec(1)=1; //  indicates a MG parm
       itempvec(2)=j; //  index of base parm
       itempvec(3)=timevary_parm_cnt+1;  //  first parameter
       itempvec(4)=z; //  block or trend type
       itempvec(5)=MGparm_1(j,14); //  block pattern or trend inflection type
  */
       if (z>0)  //  blocks with z as the block pattern
       {
         if(z>N_Block_Designs) {N_warn++; warning<<"parm: "<<j<<" ERROR, Block > N Blocks "<<z<<" "<<N_Block_Designs<<endl; exit(1);}

         N_MGparm_blk+=Nblk(z);  //  N parameters
         if(j==MGP_CGD) CGD_onoff=1;
       }
       else if (z<0)  //  (z<0) so invoke a trend
       {
         if(z==-1 || z==-2)
          {
            N_MGparm_blk+=3;  //  N parameters
          }
          else
            {
              N_MGparm_blk+=Ncycle;
            }
       }
//       timevary_def.push_back (itempvec(1,5));
     }
   }
  if(N_MGparm_blk>0)
  {
    *(ad_comm::global_datafile) >> customblocksetup_MG;
    if(customblocksetup_MG==0)
    {k1=1;}
    else
    {k1=N_MGparm_blk;}
    echoinput<<customblocksetup_MG<<" customblocksetup_MG"<<endl;
  }
  else
  {
    customblocksetup_MG=0;
    k1=0;
    echoinput<<" no mgparm blocks, so don't read customblocksetup_MG"<<endl;
  }
 END_CALCS
  init_matrix MGparm_blk_1(1,k1,1,7)  // read matrix that defines the block parms
  !!if(N_MGparm_blk>0) echoinput<<" MGparm-blk setup "<<endl<<MGparm_blk_1<<endl;

!!//  SS_Label_Info_4.5.7 #Set up seasonal effects for MG parms
  init_ivector MGparm_seas_effects(1,10)  // femwtlen1, femwtlen2, mat1, mat2, fec1 fec2 Malewtlen1, malewtlen2 L1 K
  int MGparm_doseas
  int N_MGparm_seas                            // number of MGparms that use seasonal effects
 LOCAL_CALCS
  {

  MGparm_doseas=sum(MGparm_seas_effects);
  N_MGparm_seas=0;  // counter for assigned parms
  if(MGparm_doseas>0)
  {
    for (j=1;j<=10;j++)
    {
      if(MGparm_seas_effects(j)>0)
      {
        for (s=1;s<=nseas;s++)
        {
          N_MGparm_seas++;
//          wait to label after getting all the timevary parameters created
//          ParCount++; ParmLabel+=MGseasLbl(j)+"_seas_"+NumLbl(s);
        }
      }
    }
  }
  }
 END_CALCS
  init_matrix MGparm_seas_1(1,N_MGparm_seas,1,7)  // read matrix that defines the seasonal parms
  !!if(N_MGparm_seas>0) echoinput<<" MGparm_seas"<<endl<<MGparm_seas_1<<endl;

!!//  SS_Label_Info_4.5.8 #Set up MG dev standard errors
  int N_MGparm_dev                            //  number of MGparms that use annual deviations
  int MGparm_dev_PH

 LOCAL_CALCS
    N_MGparm_dev=0;
    for(j=1;j<=N_MGparm;j++)
    {
    if(MGparm_1(j,9)>0)  {N_MGparm_dev++;}
    }
    echoinput<<"# Number of MGparms with devs: "<<N_MGparm_dev<<endl;
    MGparm_dev_PH=0;
    if(N_MGparm_dev > 0)
    {
      *(ad_comm::global_datafile) >> MGparm_dev_PH;
      echoinput<<MGparm_dev_PH<<" MGparm_dev_PH"<<endl;
      if(MGparm_dev_PH==0) MGparm_dev_PH=6;
      if(parm_adjust_method_rd==2)
      {N_warn++; warning<<"3.24 had parm adjust method=2, so the se of the dev vectors will need to be re-estimated"<<endl;}
    }

 END_CALCS

!!//  SS_Label_Info_4.5.9 #Create vectors (e.g. MGparm_PH) to be used to define the actual estimated parameter array
!!// SS_Label_Info_4... //  quantities used to track all time-varying parameters
  int timevary_cnt   //  cumulative count of baseparms that request timevarying  across MG, SRR, Q, Selex, Tag
                     //  it counts the number of times timevary_setup(1,13) is created
                     //  by the function  "create_timevary"
                     //  and is pushed to the vector_vector  timevary_def
                     //  the timevary parameters themselves will be pushed to time_vary_parm_rd
  int N_parm_dev     //  number of  all parms that use annual deviations
  ivector timevary_pass(styr-3,YrMax+1)    //  extracted column
  vector env_data_pass(styr-1,YrMax)
  int  do_densitydependent;

!!//  SS_Label_Info_4.5.4 #Set up time-varying parameters for MG parms
  int timevary_parm_cnt_MG;
  int timevary_parm_start_MG;
  ivector MG_active(0,7)  // 0=all, 1=M, 2=growth 3=wtlen, 4=recr_dist, 5=migration, 6=ageerror, 7=catchmult
  ivector MGparm_timevary(1,N_MGparm)  //  holds index in timevary_def used by this base parameter
  imatrix timevary_MG(styr-3,YrMax+1,0,7)  // goes to yrmax+1 to allow referencing in forecast, but only endyr+1 is checked
  int tvparm;
  int MGenvcnt;
  int MGblkcnt;

 LOCAL_CALCS
   do_densitydependent=0;
   timevary_cnt=0;
   N_parm_dev=0;
   timevary_parm_cnt=0;
   MGenvcnt=0;
   MGblkcnt=0;

//  push once so 0'th row is not used
   ivector timevary_setup(1,13);
   timevary_setup.initialize();
   timevary_def.push_back (timevary_setup(1,13));
   dvector tempvec(1,7);  //  temporary vector for a time-vary parameter  LO HI INIT PRIOR PR_type SD PHASE
   timevary_parm_rd.push_back (tempvec);

   echoinput<<"Now read env, block/trend, and dev adjustments to MGparms "<<endl;
   timevary_MG.initialize();    // stores years to calc non-constant MG parms (1=natmort; 2=growth; 3=wtlen & fec; 4=recr_dist; 5=movement)
   MG_active.initialize();
   CGD_onoff=0;

   timevary_parm_start_MG=0;
   timevary_parm_cnt_MG=0;
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
       ivector timevary_setup(1,13);  //  temporary vector for timevary specs
       timevary_setup.initialize();
//  1=baseparm type; 2=baseparm index; 3=first timevary parm
//  4=block or trend type; 5=block pattern; 6= env link type; 7=env variable;
//  8=dev vector used; 9=dev link type; 10=dev min year; 11=dev maxyear; 12=dev phase; 13=all parm index of baseparm
       timevary_parm_start_MG=1;  //  at least one MG parm is time varying
       echoinput<<endl<<" timevary for MG parameter: "<<j<<endl;
       timevary_cnt++;  //  count parameters with time-vary effect
       MGparm_timevary(j)=timevary_cnt;  //  base parameter will use this timevary specification
       timevary_setup(1)=1; //  indicates a MG parm
       timevary_setup(2)=j; //  index of base parm within that type of parameter
       timevary_setup(13)=j;  //  index of base parm relative to ParCount which is continuous across all types of parameters
       timevary_setup(3)=timevary_parm_cnt+1;  //  first parameter within total list of all timevary parms
       z=MGparm_1(j,13);    // specified block or trend definition

      if(MGparm_1(j,8)>0)
      {
        timevary_setup(6)=1; timevary_setup(7)=MGparm_1(j,8);
      }
      else if(MGparm_1(j,8)==-999)
       {timevary_setup(6)=3;  timevary_setup(7)=-1;}
      else
       {timevary_setup(6)=2; timevary_setup(7)=-MGparm_1(j,8);}

       if(MGparm_1(j,8)!=0)
        {
          MGparm_1(j,8)=100.*timevary_setup(6)+timevary_setup(7);
          echoinput<<" convert env to 330 format "<<MGparm_1(j,8)<<endl;
        }
       if(timevary_setup(7)>0)
       {
         k=timevary_setup(7);
         for(y=styr-1;y<=YrMax;y++) env_data_pass(y)=env_data_RD(y,k);
       }
       else
       {k=0; env_data_pass.initialize();}
       if(z>0)  //  doing blocks
       {
         create_timevary(MGparm_1(j),timevary_setup, timevary_pass, autogen_timevary(timevary_setup(1)), mgp_type(j), Block_Design(z), parm_adjust_method, env_data_pass, N_parm_dev, finish_starter);
       }
       else
       {
         create_timevary(MGparm_1(j),timevary_setup, timevary_pass, autogen_timevary(timevary_setup(1)), mgp_type(j), block_design_null, parm_adjust_method, env_data_pass, N_parm_dev, finish_starter);
       }
       if(MGparm_1(j,12)>0) MGparm_1(j,12)=MGparm_dev_PH;
  /*
   where:
   MGparm_1(j):           vector with the base parameter which has some type of timevary characteristic
   timevary_setup:        vector which contains specs of all types of timevary  for this base parameter
                          will be pushed to timevary_def cumulative across all types of base parameters
   timevary_pass:        vector containing column(timevary_MG,mgp_type(j)), will be modified in create_timevary
   autogen_timevary:      switch to autogenerate or not
   mgp_type(j):           integer with type of MGparm being worked on; analogous to 2*fleet in the selectivity section
   block_design(z):       block design, if any, being used
   parm_adjust_method:    switch to determine if adjusted parameter will stay in bounds; used to create warnings in create_timevary
   env_data_RD:           matrix containing entire set of environmental data as read
   N_parm_dev:            integer that is incremented in create_timevary as dev vectors are created; cumulative across all types of parameters
  */

       tvparm=timevary_setup(3)-1;  //  index of first timevay parameter used here
       if(timevary_setup(5)>0 && customblocksetup_MG==1)  //  move block info from 3.24 inputs
       {
          echoinput<<" copy MGblock info from 3.24 "<<endl;
          z=MGparm_1(j,13);    // specified block or trend definition
          if (z>0)  //  blocks with z as the block pattern
          {
            for (a=1;a<=Nblk(z);a++)  //  loop blocks for block pattern z
            {
              tvparm++;
              MGblkcnt++;
              echoinput<<"move MG blk info from 3.24 index "<<MGblkcnt<<"  to 3.30 index  "<<tvparm<<endl;
              timevary_parm_rd[tvparm](1,7)=MGparm_blk_1(MGblkcnt)(1,7);
              temp=timevary_parm_rd[tvparm](5);
              timevary_parm_rd[tvparm](5)=timevary_parm_rd[tvparm](6);
              timevary_parm_rd[tvparm](6)=temp;
              echoinput<<timevary_parm_rd[tvparm]<<endl;
            }
          }
          else //  (z<0) so invoke a trend
          {
            for (a=1;a<=3;a++)  //  loop blocks for block pattern z
            {
              tvparm++;
              MGblkcnt++;
              echoinput<<"move MG trend info from 3.24 index "<<MGblkcnt<<"  to 3.30 index  "<<tvparm<<endl;
              timevary_parm_rd[tvparm](1,7)=MGparm_blk_1(MGblkcnt)(1,7);
              temp=timevary_parm_rd[tvparm](5);
              timevary_parm_rd[tvparm](5)=timevary_parm_rd[tvparm](6);
              timevary_parm_rd[tvparm](6)=temp;
              echoinput<<timevary_parm_rd[tvparm]<<endl;
            }
          }
       }

       if(customMGenvsetup==1)
       {
         tvparm++;
         MGenvcnt++;
         echoinput<<"move MG env  info from 3.24 index "<<MGenvcnt<<"  to 3.30 index  "<<tvparm<<endl;
         timevary_parm_rd[tvparm](1,7)=MGparm_env_1(MGenvcnt)(1,7);
              temp=timevary_parm_rd[tvparm](5);
              timevary_parm_rd[tvparm](5)=timevary_parm_rd[tvparm](6);
              timevary_parm_rd[tvparm](6)=temp;
              echoinput<<timevary_parm_rd[tvparm]<<endl;
       }

       if(timevary_setup(8)!=0) timevary_setup(12)=MGparm_dev_PH;
       timevary_def.push_back (timevary_setup(1,13));
       for(y=styr-3;y<=YrMax+1;y++) {timevary_MG(y,mgp_type(j))=timevary_pass(y);}  // year vector for this category of MGparm
       if(j==MGP_CGD) CGD_onoff=1;
     }
   }

   timevary_parm_cnt_MG=timevary_parm_cnt;
   echoinput<<" timevary_parm_cnt "<<timevary_parm_cnt<<endl;

  {
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
          N_MGparm_seas++;
          ParCount++; ParmLabel+=MGseasLbl(j)+"_seas_"+NumLbl(s);
        }
      }
    }
  }
  }
 END_CALCS

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
   for (f=1;f<=N_MGparm;f++)
   {
    MGparm_LO(f)=MGparm_1(f,1);
    MGparm_HI(f)=MGparm_1(f,2);
    MGparm_RD(f)=MGparm_1(f,3);
    MGparm_PR(f)=MGparm_1(f,4);

    temp=MGparm_1(f,5);  //  will be reversed with _CV in 3.30
    if(temp==0) {temp=6;}  //  recode for normal distribution
    if(temp<0) {temp=0;}
    MGparm_1(f,5)=MGparm_1(f,6);
    MGparm_1(f,6)=temp;
    MGparm_PRtype(f)=temp;
    MGparm_CV(f)=MGparm_1(f,5);
    MGparm_PH(f)=MGparm_1(f,7);
    if(MGparm_PH(f)>0)
    {MG_active(mgp_type(f))=1;}
   }
   if(natM_type==2 && MG_active(2)>0) MG_active(1)=1;  // lorenzen M depends on growth

  //  SS_Label_Info_4.5.95 #Populate time_bio_category array defining when biology changes
     k=YrMax+1;
    timevary_MG(styr)(1,7)=MG_active(1,7);
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
    }
    MG_active(0)=sum(MG_active(1,7));
    echoinput<<"MG_active "<<MG_active<<endl<<"timevary_MG"<<endl<<timevary_MG<<endl;
   j=N_MGparm;

   if(timevary_parm_cnt_MG>0)
   for (f=1;f<=timevary_parm_cnt_MG;f++)
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
    temp=MGparm_seas_1(f,5);
    if(temp==0) temp=6.;
    if(temp<0) temp=0;
    MGparm_seas_1(f,5)=MGparm_seas_1(f,6);
    MGparm_seas_1(f,6)=temp;
    MGparm_PRtype(j)=temp;
    MGparm_CV(j)=MGparm_seas_1(f,6);
    MGparm_PH(j)=MGparm_seas_1(f,7);
   }
   echoinput<<ParmLabel<<endl;
 END_CALCS

!!//  SS_Label_Info_4.6 #Read setup for Spawner-Recruitment parameters
//  SPAWN-RECR: read setup for SR parameters:  LO, HI, INIT, PRIOR, PRtype, CV, PHASE
  init_int SR_fxn
  ivector N_SRparm(1,10)
  !!N_SRparm.fill("{0,2,2,2,3,2,3,3,0,0}");
  int N_SRparm2
  int N_SRparm3
  int init_equ_steepness
  int sigmaR_dendep  //    future feature:  0/1 to make realized sigmaR a function of SR curvature"<<endl;
  !!echoinput<<SR_fxn<<" #_SR_function: 1=null; 2=Ricker; 3=std_B-H; 4=SCAA; 5=Hockey; 6=B-H_flattop; 7=Survival_3Parm; 8=Shepherd "<<endl;
  !!N_SRparm2=N_SRparm(SR_fxn)+3;

  matrix SR_parm_1(1,N_SRparm2,1,14)
 LOCAL_CALCS
   N_SRparm3=N_SRparm2;
   SR_parm_1.initialize();
   for(f=1;f<=N_SRparm(SR_fxn);f++)
   {
     *(ad_comm::global_datafile) >> SR_parm_1(f)(1,7);
   }
   f=N_SRparm(SR_fxn)+1;  *(ad_comm::global_datafile) >> SR_parm_1(f)(1,7);  //  read sigmaR
   f++;                   *(ad_comm::global_datafile) >> SR_parm_1(f)(1,7);  //  read sr_envlink
         *(ad_comm::global_datafile) >> SR_parm_1(f)(1,7);  //  read sr_r1offset and overwrite envlink
   f++;                   *(ad_comm::global_datafile) >> SR_parm_1(f)(1,7);  //  read autocorr
  echoinput<<" SR parms "<<endl<<SR_parm_1<<endl;

  if(SR_parm_1(N_SRparm2-1,5)>-999)  //  using the PR_type as a flag for applying steepness in the initial equilibrium calc
    {init_equ_steepness=0;}
    else
    {init_equ_steepness=1;}

  if(SR_parm_1(N_SRparm2-1,7)>=0 || SR_parm_1(N_SRparm2-1,3)!=0.0)
    {
      N_warn++;warning<<"The R1_offset parameter is now the regime parameter and it must not be estimated and should have value of 0.0"<<endl<<
      "Instead, time-varying offsets to the regime parameter can be estimated; and a block for doing this has been created"<<endl<<
      "you will need to manually create the parameter line for that block or turn autogen value to 0 for SR_parms"<<endl;
      SR_parm_1(N_SRparm2-1,7)=-1;
      SR_parm_1(N_SRparm2-1,3)=0.0;
      SR_parm_1(N_SRparm2-1,13)=N_Block_Designs;
      SR_parm_1(N_SRparm2-1,14)=1;
    }

 END_CALCS

  init_int SR_env_link
  !!echoinput<<SR_env_link<<" SR_env_link "<<endl;
  init_int SR_env_target_RD   // 0=none; 1=devs; 2=R0; 3=steepness
  !!echoinput<<SR_env_target_RD<<" SR_env_target_RD "<<endl;
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

//  adjust for revision to envlink approach
  if(SR_env_link>0)
    {
      echoinput<<"SR_envlink has been read but will not converted; please re-create in 3.30 approach"<<endl;
      N_warn++; warning<<"SR_envlink has been read but will not converted; please re-create in 3.30 approach"<<endl;
      SR_env_link=0;
    }
 END_CALCS
  vector SR_parm_LO(1,N_SRparm3)
  vector SR_parm_HI(1,N_SRparm3)
  vector SR_parm_RD(1,N_SRparm3)
  vector SR_parm_PR(1,N_SRparm3)
  ivector SR_parm_PRtype(1,N_SRparm3)
  vector SR_parm_CV(1,N_SRparm3)
  ivector SR_parm_PH(1,N_SRparm3)

 LOCAL_CALCS
//  SS_Label_Info_4.6.1 #Create S-R parameter labels
  for(f=1;f<=N_SRparm2;f++)
  {
   SR_parm_LO(f)=SR_parm_1(f,1);
   SR_parm_HI(f)=SR_parm_1(f,2);
   SR_parm_PH(f)=int(SR_parm_1(f,7));
   SR_parm_RD(f)=SR_parm_1(f,3);
   SR_parm_PR(f)=SR_parm_1(f,4);

   temp=SR_parm_1(f,5);  //  PR_type in 3.24
   if(temp==0) temp=6;
   if(temp<0) temp=0;
   SR_parm_1(f,5)=SR_parm_1(f,6);  //  move CV
   SR_parm_1(f,6)=temp;
   SR_parm_CV(f)=SR_parm_1(f,5);
   SR_parm_PRtype(f)=SR_parm_1(f,6);
  }
  /*
   if(SR_env_link>N_envvar)
   {
     N_warn++;
     warning<<" ERROR:  SR_env_link ( "<<SR_env_link<<" ) was set greater than the highest numbered environmental index ( "<<N_envvar<<" )"<<endl;
     cout<<" EXIT - see warning "<<endl; exit(1);
   }
   SR_env_target=SR_env_target_RD;
   if(SR_env_link==0) SR_env_target=0;
   if(SR_env_link==0 && SR_env_target_RD>0)
   {N_warn++; warning<<" WARNING:  SR_env_target was set, but no SR_env_link selected, SR_env_target set to 0"<<endl;}
  */
//#_SR_function: 1=null; 2=Ricker; 3=std_B-H; 4=SCAA; 5=Hockey; 6=B-H_flattop; 7=Survival_3Parm "<<endl;
  ParmLabel+="SR_LN(R0)";
  switch(SR_fxn)
  {
    case 1: // previous placement for B-H constrained
    {
      N_warn++; cout<<"Critical error:  see warning"<<endl; warning<<"B-H constrained curve is now Spawn-Recr option #6"<<endl; exit(1);
      break;
    }
    case 2:  // Ricker
    {
      ParmLabel+="SR_Ricker";
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
  }
  ParmLabel+="SR_sigmaR";
  ParmLabel+="SR_regime";
  ParmLabel+="SR_autocorr";
  ParCount+=N_SRparm2;
 END_CALCS

  init_int do_recdev  //  0=none; 1=devvector; 2=simple deviations
  !!echoinput<<do_recdev<<" do_recdev"<<endl;
  init_int recdev_start;
  !!echoinput<<recdev_start<<" recdev_start"<<endl;
  init_int recdev_end;
  !!echoinput<<recdev_end<<" recdev_end"<<endl;
  init_int recdev_PH_rd;
  !!echoinput<<recdev_PH_rd<<" recdev_PH"<<endl;
  init_int recdev_adv
  !!echoinput<<recdev_adv<<" recdev_adv"<<endl;

  init_vector recdev_options_rd(1,13*recdev_adv)
  vector recdev_options(1,13)
  int recdev_PH;
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
  recdev_PH=recdev_PH_rd;
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
    recdev_early_PH_rd=0;
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
  if(recdev_adv>0)
  {echoinput<<"#_start of advanced SR options"<<endl;}
  else
  {echoinput<<"# advanced options not read;  defaults displayed below"<<endl;}

    echoinput<<recdev_early_start_rd<<" #_recdev_early_start (0=none; neg value makes relative to recdev_start)"<<endl;
    echoinput<<recdev_early_PH_rd<<" #_recdev_early_phase"<<endl;
    echoinput<<Fcast_recr_PH_rd<<" #_forecast_recruitment phase (incl. late recr) (0 value resets to maxphase+1)"<<endl;
    echoinput<<Fcast_recr_lambda<<" #_lambda for Fcast_recr_like occurring before endyr+1"<<endl;
    echoinput<<recdev_adj(1)<<" #_last_early_yr_nobias_adj_in_MPD"<<endl;
    echoinput<<recdev_adj(2)<<" #_first_yr_fullbias_adj_in_MPD"<<endl;
    echoinput<<recdev_adj(3)<<" #_last_yr_fullbias_adj_in_MPD"<<endl;
    echoinput<<recdev_adj(4)<<" #_first_recent_yr_nobias_adj_in_MPD"<<endl;
    if(recdev_adj(4)>endyr && do_recdev>0)
      {N_warn++; warning<<"bias adjustment ramp extends into forecast; biasadj set to 0.0 internally for forecast years"<<endl;}
    echoinput<<recdev_adj(5)<<" #_max_bias_adj_in_MPD"<<endl;
    echoinput<<recdev_cycle<<" # period of cycle in recruitment "<<endl;
    echoinput<<recdev_LO<<" #min rec_dev"<<endl;
    echoinput<<recdev_HI<<" #max rec_dev"<<endl;
    echoinput<<recdev_read<<" #_read_recdevs"<<endl;
    echoinput<<"#_end of advanced SR options"<<endl;

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
    echoinput<<"#_recruitment bias adjustment"<<endl<<biasadj_full<<endl;;

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
  echoinput<<" ParCount after recdev_cycle  "<<ParCount<<endl;
//  SS_Label_Info_4.6.4 #Setup recruitment deviations and create parm labels for each year
  if(recdev_end>retro_yr) recdev_end=retro_yr;
  if(recdev_start<(styr-nages)) {recdev_start=styr-nages; N_warn++; warning<<" adjusting recdev_start to: "<<recdev_start<<endl;}
  recdev_first=recdev_start;   // stores first recdev, whether from the early period or the standard dev period

  if(recdev_early_start>=recdev_start)
  {
    N_warn++; cout<<" EXIT - see warning "<<endl; warning<<" error, cannot set recdev_early_start after main recdev start"<<endl;
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
      {recdev_early_start=styr-nages; N_warn++; warning<<" adjusting recdev_early to: "<<recdev_early_start<<endl;}
    if(recdev_start-recdev_early_start<6)
    {N_warn++; warning<<" Are you sure you want so few early recrdevs? "<<recdev_start-recdev_early_start<<endl;}

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
    for (y=recdev_end+1;y<=YrMax;y++)
    {
      sprintf(onenum, "%d", y);
      ParCount++;
      if(y>endyr)
      {ParmLabel+="ForeRecr_"+onenum+CRLF(1);}
      else
      {ParmLabel+="Late_RecrDev_"+onenum+CRLF(1);}
    }

    for (y=endyr+1;y<=YrMax;y++)
    {
      sprintf(onenum, "%d", y);
      ParCount++;
      ParmLabel+="Impl_err_"+onenum+CRLF(1);
    }
  }
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
  !! echoinput<<F_ballpark<<" F ballpark is annual F for fleet 1 for specified year"<<endl;
  init_int F_ballpark_yr
  !! echoinput<<F_ballpark_yr<<" F_ballpark_yr (<0 to ignore)  "<<endl;
  init_int F_Method;           // 1=Pope's; 2=continuouos F; 3=hybrid
  int F_Method_use
  !! echoinput<<F_Method<<" F_Method "<<endl;
  init_number max_harvest_rate
  number Equ_F_joiner
  int y1;
  
 LOCAL_CALCS
    echoinput<<max_harvest_rate<<" max_harvest_rate "<<endl;
  if(F_Method<1 || F_Method>3)
    {
      N_warn++;
    warning<<" ERROR:  F_Method must be 1 or 2 or 3, value is: "<<F_Method<<endl;
    cout<<" EXIT - see warning "<<endl;
    exit(1);
    }
   if(F_Method==1)
   {
     k=-1;
     j=-1;
     Equ_F_joiner=(log(1./max_harvest_rate -1.))/(max_harvest_rate-0.2);  //  used to spline the harvest rate
     if(max_harvest_rate>0.999)
     {N_warn++; cout<<" EXIT - see warning "<<endl; warning<<" max harvest rate must  be <1.0 for F_method 1 "<<max_harvest_rate<<endl; exit(1);}
     if(max_harvest_rate<=0.30)
     {N_warn++; warning<<" unexpectedly small value for max harvest rate for F_method 1:  "<<max_harvest_rate<<endl;}
   }
   else
   {
     if(max_harvest_rate<1.0)
     {N_warn++; warning<<" max harvest rate should be >1.0 for F_method 2 or 3 "<<max_harvest_rate<<endl;}
     if(F_Method==2)
     {
       k=3;
       j=Nfleet*(TimeMax-styr+1);
     }
     else
     {
       k=1;
       j=-1;
     }
   }
 END_CALCS

  init_vector F_setup(1,k)
//  vector F_rate_max(1,j)
// setup for F_rate with F_Method=2
// F_setup(1) = overall initial value
// F_setup(2) = overall phase
// F_setup(3) = number of specific initial values and phases to read
  int F_detail
  int F_Tune
 LOCAL_CALCS
  F_detail=-1;
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

//  no seasons in 3.24
  {
    for (f=1;f<=Nfleet1;f++)
    {
      init_F_loc(1,f)=f;
      if(obs_equ_catch(1,f)!=0.0) N_init_F2++;  //  number of fleets with catch, so number to be written in data.ss_new
    }
    N_init_F=Nfleet1;
  }
 END_CALCS
  !! echoinput<<" ready to read init_F setup for: "<<N_init_F<<" fleet x season with initial equilibrium catch"<<endl;
  !! echoinput<<"Number of init_F parameters to be retained for non-zero catch = "<<N_init_F2<<endl;
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
   for(f=1;f<=N_init_F;f++)
   {
     temp=init_F_parm_1(f,5);
     if(temp==0) {temp=6;}  //  recode for normal distribution
     if(temp<0)  {temp=0;}
     init_F_parm_1(f,5)=init_F_parm_1(f,6);
     init_F_parm_1(f,6)=temp;
     init_F_PRtype(f)=temp;
   }

   init_F_CV=column(init_F_parm_1,6);
   init_F_PH=ivector(column(init_F_parm_1,7));

//  no seasons in 3.24
  k=1;

   for (s=1;s<=k;s++)
   for (f=1;f<=Nfleet1;f++)
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
           warning<<f<<" catch: "<<obs_equ_catch(s,f)<<" initF: "<<init_F_RD(j)<<" initF is reset to be 0.0"<<endl;
         }
         init_F_RD(j)=0.0; init_F_PH(j)=-1;
       }
       if(obs_equ_catch(s,f)>0.0 && init_F_RD(j)<=0.0)
       {
         N_warn++; cout<<" EXIT - see warning "<<endl;
         warning<<f<<" catch: "<<obs_equ_catch(s,f)<<" initF: "<<init_F_RD(j)<<" initF must be >0"<<endl; exit(1);
       }
     }
   }
  }
 END_CALCS

 LOCAL_CALCS
//  SS_Label_Info_4.7.2 #Create parameter labels for F parameters if F_method==2
  if(F_Method==2)
  {
    Fparm_start = ParCount;
    N_Fparm=0;
    do_Fparm.initialize();
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

 LOCAL_CALCS
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
          t=styr+(y-styr)*nseas+s-1;
          j=do_Fparm(f,t);
          if(F_setup2(k,6)!=-999) Fparm_PH(j)=F_setup2(k,6);    //   used to setup the phase for F_rate
          if(F_setup2(k,5)!=-999) catch_se(t,f)=F_setup2(k,5);    //    reset the se for this observation
          //  setup of F_rate values occurs later in the parameter section
        }
      }
  }

//  SS_Label_Info_4.8 #Read catchability (Q) setup
 END_CALCS

  imatrix Q_setup_324(1,Nfleet,1,4)  // do power
                                     // env-var
                                     // extra sd
                                     // Qtype(<0=mirror, 0=float_nobiasadj 1=float_biasadj, 2=parm_nobiasadj, 3=rand, 4=randwalk)
  imatrix Q_setup_parms_324(1,Nfleet,1,4)  //  location in 3.24 parm list of first parm for each type

//  arrays for 330 format
  imatrix Q_setup(1,Nfleet,1,5)
//Q_setup for 3.30
// 1:  link type
// 2:  extra input for link, i.e. mirror fleet
// 3:  0/1 to select extra sd parameter
// 4:  0/1 for biasadj or not
// 5:  0/1 to float

//  Link types
//  1  simple q, 1 parm
//  2  mirror simple q, 1 mirrored parameter
//  3  q and power, 2 parm

  int parm330_cnt
  int Q_Npar2
  int Q_Npar
  int ask_detail
  int Q_parm_detail

  imatrix Q_setup_parms(1,Nfleet,1,5)  //
//  index of first parameter for:  1=base q with link;  2=extrastd; 3=env; 4=block/trend; 5=dev;
  int depletion_fleet;  //  stores fleet(survey) number for the fleet that is defined as "depletion" by survey type=34
  int depletion_type;  //  entered by Q_setup(f,2) and stores additional controls for depletion fleet

 LOCAL_CALCS
  Q_setup_324.initialize();
  Q_setup_parms_324.initialize();
  Q_setup.initialize();
  Q_setup_parms.initialize();
  depletion_type=0;
  depletion_fleet=0;

 	*(ad_comm::global_datafile) >> Q_setup_324;
  echoinput<<" Q setup from 324 "<<endl<<Q_setup_324<<endl;

  Q_Npar=0;  //  counter for parameters in 3.24 format
  parm330_cnt=0;
  ask_detail=0;

//  SS_Label_Info_4.8.1 #Create index to the catchability parameters
  for (f=1;f<=Nfleet;f++)
  {
    Q_setup(f,1)=1;  //  set default Q function to be q as a simple multiplier
    if(Q_setup_324(f,1)>0)  //  power
    {
      Q_Npar++; Q_setup_parms_324(f,1)=Q_Npar;
     	parm330_cnt++;  Q_setup(f,1)=3;  //  set  link function to be same as 3.24 power
    }
  }
  echoinput<<" Q_Npar "<<Q_Npar<<endl;
  for (f=1;f<=Nfleet;f++)
  {
    if(Q_setup_324(f,2)!=0)  //  env link
    {
      Q_Npar++; Q_setup_parms_324(f,2)=Q_Npar;
      Q_setup(f,2)=1;
    }
  }
  echoinput<<" Q_Npar "<<Q_Npar<<endl;

  for (f=1;f<=Nfleet;f++)
  {
    if(Q_setup_324(f,3)>0)  //  extra se
    {
      Q_Npar++; Q_setup_parms_324(f,3)=Q_Npar;
     	parm330_cnt++;
   		Q_setup(f,3)=1;  // do extra sd
    }
  }
  echoinput<<" Q_Npar "<<Q_Npar<<endl;

  for (f=1;f<=Nfleet;f++)
  {
    if(Svy_N_fleet(f)>0 || Q_setup_324(f,4)>=2)  //  add base Q parameter
    {
    	parm330_cnt++;  //  counter for base Q parameter needed in 330 format
    }
    if(Q_setup_324(f,4)<0)   //  mirror
  	{
      Q_setup(f,1)=2;  //  set  link function to mirror
  		Q_setup(f,2)=abs(Q_setup_324(f,4));
  	}
    if(Q_setup_324(f,4)==0 || Q_setup_324(f,4)==1 || Q_setup_324(f,4)==5 ) Q_setup(f,5)=1;   //  float Q
    if(Q_setup_324(f,4)==0 || Q_setup_324(f,4)==2) {Q_setup(f,4)=0;} else {Q_setup(f,4)=1;}  //  biasadj or not
  }

//  now prepare to read the catchability deviation parameters in 3.24 format
//  SS_Label_Info_4.8.2 #Create Q parm and time-varying catchability as needed
  Q_Npar2=Q_Npar;
  for (f=1;f<=Nfleet;f++)
  {
    if(Q_setup_324(f,4)>=2)
    {
//      Q_Npar++; Q_Npar2++; Q_setup_parms_324(f,4)=Q_Npar;
      Q_Npar++; Q_Npar2++; Q_setup_parms_324(f,4)=Q_Npar2;
      if(Q_setup_324(f,4)==3)
      {
        ask_detail=1;
        Q_Npar2++;
        Q_Npar+=Svy_N_fleet(f);
      }
      if(Q_setup_324(f,4)==4)
      {
        ask_detail=1;
        Q_Npar2++;
        Q_Npar+=Svy_N_fleet(f)-1;
      }
    }
    else if(Svy_errtype(f)==-1)
    {N_warn++; cout<<" EXIT - see warning "<<endl; warning<<" Error, cannot use scaling approach to Q if error type is normal "<<endl; exit(1);}

//  error checking
    if(Svy_units(f)==2)  // effort deviations
    {
      if(Svy_errtype(f)>=0)  //  lognormal
      {
        N_warn++;
        warning<<" Lognormal error selected for effort deviations for fleet "<<f<<"; normal error recommended"<<endl;
      }
      if(Q_setup_324(f,1)>0)  //  density-dependence
      {
        N_warn++;
        warning<<" Do not use Density-dependence for effort deviations (fleet "<<f<<"); "<<endl;
      }
    }

  }

  if(ask_detail>0)  //  using deviations
  {
    *(ad_comm::global_datafile) >> Q_parm_detail;
    echoinput<<Q_parm_detail<<" Q_parm detail for time-varying parameters "<<endl;
  }
  else
  {
    Q_parm_detail=0;
    echoinput<<" # No time-varying Q parms, so no q_parm_detail input needed "<<endl;
  }
  if(Q_parm_detail==1) {j=Q_Npar;} else {j=Q_Npar2;}
  Q_Npar=parm330_cnt;  //  reuse this as the number of base Q parms
 END_CALCS

//  SS_Label_Info_4.8.3 #Read catchability parameters if 3.24 format
  init_matrix Q_parm_2(1,j,1,7)

  matrix Q_parm_1(1,parm330_cnt,1,14)  //  Q parameters in 3.30 format
  int firstQparm;

 LOCAL_CALCS
  echoinput<<" Catchability parameters in 3.24"<<endl<<Q_parm_2<<endl;

// Now  convert to 3.30 format where parameters are in fleet order, not fleet within parameter type
  parm330_cnt=0;  //  restart the index
  firstQparm=ParCount;  //  base index before adding Q parms
  Q_parm_1.initialize();
  echoinput<<endl<<"transfer Q setup from 324 to 330 and create base Q parms"<<endl;
  for (f=1;f<=Nfleet;f++)
  if(Svy_N_fleet(f)>0)
  {
//  do base Q and any needed parms for links (like Qpower)
  	parm330_cnt++;
  	ParCount++;
    Q_setup_parms(f,1)=parm330_cnt;  //  first parameter index for this fleet that has obs so needs a Q
  	if(Q_setup_324(f,4)>=2)  //  so a base Q exists in 3.24
    {
    	Q_parm_1(parm330_cnt)(1,7)=Q_parm_2(Q_setup_parms_324(f,4))(1,7);
    }
    else
    {
    	Q_parm_1(parm330_cnt).fill("{-25, 25, 0, 0,-1, 1, 1, 0, 0, 0, 0, 0, 0, 0}");
    }
    if(Q_setup(f,1)<0)  //  mirror
    {
    	Q_parm_1(parm330_cnt).fill("{-25,25,0,0,-1,1,-1, 0, 0, 0, 0, 0, 0, 0}");
      // because Q is a vector for each time series of observations, the mirror is to the first observation's Q
      // so time-varying property cannot be mirrored
      //  need to trap for this when reading
    }
    if(Q_setup(f,5)==1)  //  float Q_setup, so cannot be active
      {Q_parm_1(parm330_cnt,7)=-1;}

    if(Svy_errtype(f)==-1)
    {
      ParmLabel+="Q_base_"+fleetname(f)+"("+NumLbl(f)+")";
    }
    else
    {
      ParmLabel+="LnQ_base_"+fleetname(f)+"("+NumLbl(f)+")";
    }
    echoinput<<f<<" "<<parm330_cnt<<" "<<ParCount<<" "<<ParmLabel.indexmax()<<endl;
    echoinput<<"base parameter for fleet "<<f<<" Qparmcount: "<<parm330_cnt<<" "<<ParmLabel(ParCount)<<endl;
  	if( Q_setup_324(f,2)>0)
  	{
  	  Q_parm_1(parm330_cnt,8) = Q_setup_324(f,2);  //  envlink transfer from 3.24
     //  needed timevary parameters will be created later
      echoinput<<" create info for env link for Qparmcount: "<<parm330_cnt<<endl;
   	}

  	if(Q_setup_324(f,4)==3 || Q_setup_324(f,4)==4) //  deviations will be used
  	  {
  	     Q_parm_1(parm330_cnt,9) =1;  //  dev link
  	     Q_parm_1(parm330_cnt,10)=Svy_styr(f); //  dev min year
  	     Q_parm_1(parm330_cnt,11)=Svy_endyr(f); //  dev maxyear
  	     Q_parm_1(parm330_cnt,12)=Q_parm_2(Q_setup_parms_324(f,4)+1)(6);//  dev se from 3.24, will get overwritten with the phase later
  	  }

    if(Q_setup_324(f,1)>0)  //  do_power  provided for compatibility, but will be replaced by density-dependent link function
    {
     	parm330_cnt++;
  	  ParCount++;
      ParmLabel+="Q_power_"+fleetname(f)+"("+NumLbl(f)+")";
    	Q_parm_1(parm330_cnt)(1,7)=Q_parm_2(Q_setup_parms_324(f,1))(1,7);
      echoinput<<" create Qpower parameter "<<parm330_cnt<<endl;
    }

//  do extra sd
  	if(Q_setup_324(f,3)>0)  //  so extra sd  exists in 3.24
    {
    	parm330_cnt++;
      ParCount++;
      Q_setup_parms(f,2)=parm330_cnt;
    	Q_parm_1(parm330_cnt)(1,7)=Q_parm_2(Q_setup_parms_324(f,3))(1,7);
      ParmLabel+="Q_extraSD_"+fleetname(f)+"("+NumLbl(f)+")";
      echoinput<<" create extraSD parameter "<<parm330_cnt<<endl;
    }
    echoinput<<"Fleet: "<<f<<"  base parm index: "<<Q_setup_parms(f,1)<<"   base q parameter line in 3.30 format "<<Q_parm_1(Q_setup_parms(f,1))<<endl;
  }
 	Q_Npar=parm330_cnt;
 	echoinput<<" number of base Q parms "<<Q_Npar<<endl;
 END_CALCS

//  SS_Label_Info_4.5.4 #Set up time-varying parameters for each fleet's base Q parm in 330 format
//  other Q link, extrastd, etc. parameters cannot be time-varying
  int timevary_parm_cnt_Q;
  int timevary_parm_start_Q;
  ivector Qparm_timevary(1,parm330_cnt)  //  holds index in timevary_def used by each base parameter
                                         //  dimensioned to hold the extra_sd parms, but these cannot be time-varying
  imatrix timevary_Qparm(styr-3,YrMax+1,0,Nfleet)  // goes to yrmax+1 to allow referencing in forecast, but only endyr+1 is checked
                                                     // stores years to calc non-constant sel parms by fleet
 LOCAL_CALCS
  Qparm_timevary.initialize();
  timevary_Qparm.initialize();
  timevary_parm_start_Q=0;
  timevary_parm_cnt_Q=0;

  for(f=1;f<=Nfleet;f++)
  if(Svy_N_fleet(f)>0)
  {
    // if(Q_setup_324(f,2)!=0 || Q_setup_324(f,1)>0 ||  Q_setup_324(f,4)==3 || Q_setup_324(f,4)==4)  //  some kind of time-vary
    if(Q_setup_324(f,2)!=0 || Q_setup_324(f,4)==3 || Q_setup_324(f,4)==4)  //  some kind of time-vary
    {
       ivector timevary_setup(1,13);  //  temporary vector for timevary specs
       timevary_setup.initialize();
//  1=baseparm type; 2=baseparm index; 3=first timevary parm
//  4=block or trend type; 5=block pattern; 6= env link type; 7=env variable;
//  8=dev vector used; 9=dev link type; 10=dev min year; 11=dev maxyear; 12=dev phase; 13=all parm index of baseparm
       if(timevary_parm_start_Q==0) timevary_parm_start_Q=timevary_parm_cnt+1;
       timevary_cnt++;  //  count parameters with time-vary effect
       Qparm_timevary(Q_setup_parms(f,1))=timevary_cnt;  //  base Q parameter will use this timevary specification
       timevary_setup(1)=3; //  indicates a Q parm
       parm330_cnt=Q_setup_parms(f,1);
       timevary_setup(2)=parm330_cnt; //  index of base parm within that type of parameter
       timevary_setup(13)=firstQparm+parm330_cnt;  //  index of base parm relative to ParCount which is continuous across all types of parameters
       timevary_setup(3)=timevary_parm_cnt+1;  //  first parameter within total list of all timevary parms
       timevary_pass=column(timevary_Qparm,f);  // year vector for this fleet
//  set up env link info
//   where abs(selparm1(j,8) is the environmental variable used;  store this in timevary_setup(7)
//   and the sign indicates the link;  store this in timevary_setup(6)
      if(Q_parm_1(parm330_cnt,8)>0)  //  multiplicative link
      {
        timevary_setup(6)=1; timevary_setup(7)=Q_parm_1(parm330_cnt,8);
      }
      else if(Q_parm_1(parm330_cnt,8)==-999)  //  density-dependence
      {
        timevary_setup(6)=3;  timevary_setup(7)=-1;
      }
      else if(Q_parm_1(parm330_cnt,8)<0)          //  additive link
      {
        timevary_setup(6)=2; timevary_setup(7)=-Q_parm_1(parm330_cnt,8);
      }

       if(Q_parm_1(parm330_cnt,8)!=0)
        {
          Q_parm_1(parm330_cnt,8)=100.*timevary_setup(6)+timevary_setup(7);
          echoinput<<" convert env to 330 format "<<Q_parm_1(parm330_cnt,8)<<endl;
        }

       if(timevary_setup(7)>0)
       {
         k=timevary_setup(7);
         for(y=styr-1;y<=YrMax;y++) env_data_pass(y)=env_data_RD(y,k);
       }
       else
       {k=0; env_data_pass.initialize();}
       z=0;   //  no blocks in 3.24
       if(z>0)  //  doing blocks
       {
         create_timevary(Q_parm_1(parm330_cnt),timevary_setup, timevary_pass, autogen_timevary(timevary_setup(1)), f, Block_Design(z), parm_adjust_method, env_data_pass, N_parm_dev, finish_starter);
       }
       else
       {
         create_timevary(Q_parm_1(parm330_cnt),timevary_setup, timevary_pass, autogen_timevary(timevary_setup(1)), f, block_design_null, parm_adjust_method, env_data_pass, N_parm_dev, finish_starter);
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
       if(timevary_setup(8)!=0) timevary_setup(12)=5;
       timevary_def.push_back (timevary_setup(1,13));
       for(y=styr-3;y<=YrMax+1;y++) {timevary_Qparm(y,f)=timevary_pass(y);}  // year vector for this category og MGparm
     }
  }

   Q_Npar2 = Q_Npar;
   if(timevary_parm_start_Q>0)
   {
     timevary_parm_cnt_Q=timevary_parm_cnt;
     Q_Npar2+=(timevary_parm_cnt_Q-timevary_parm_start_Q+1);
     echoinput<<"Q  uses timevary parms:  "<<Qparm_timevary<<endl;
     echoinput<<" Q  timevary_parm_cnt start and end "<<timevary_parm_start_Q<<" "<<timevary_parm_cnt_Q<<endl;
   }
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

      temp=Q_parm_1(i,5);
      if(temp==0) {temp=6;}  //  recode for normal distribution
      if(temp<0)  {temp=0;}
      Q_parm_1(i,5)=Q_parm_1(i,6);
      Q_parm_1(i,6)=temp;
      Q_parm_PRtype(i)=temp;
      Q_parm_CV(i)=Q_parm_1(i,5);
      Q_parm_PH(i)=Q_parm_1(i,7);
    }
    if(timevary_parm_start_Q>0)
    {
      j=Q_Npar;
    for (f=timevary_parm_start_Q;f<=timevary_parm_cnt_Q;f++)
     {
      j++;
      Q_parm_LO(j)=timevary_parm_rd[f](1);
      Q_parm_HI(j)=timevary_parm_rd[f](2);
      Q_parm_RD(j)=timevary_parm_rd[f](3);
      Q_parm_PR(j)=timevary_parm_rd[f](4);
      Q_parm_PRtype(j)=timevary_parm_rd[f](5);
      if(Q_parm_PRtype(j)==0)  Q_parm_PRtype(j)=6;
      if(Q_parm_PRtype(j)<0)  Q_parm_PRtype(j)=0;
      Q_parm_CV(j)=timevary_parm_rd[f](6);
      Q_parm_PH(j)=timevary_parm_rd[f](7);
     }
 	  }
 	}
 	echoinput<<"initial values for all Q_parm: "<<Q_parm_RD<<endl<<"phase: "<<Q_parm_PH<<endl;;
 END_CALCS

!!//  SS_Label_Info_4.9 #Define Selectivity patterns and N parameters needed per pattern
  ivector seltype_Nparam(0,35)
 LOCAL_CALCS
   seltype_Nparam(0)=0;   // selex=1.0 for all sizes
   seltype_Nparam(1)=2;   // logistic; with 95% width specification
   seltype_Nparam(2)=8;   // double logistic, with defined peak
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
   seltype_Nparam(30)=0;   //   spawning biomass
   seltype_Nparam(31)=0;   //   recruitment dev
   seltype_Nparam(32)=0;   //   pre-recruitment (spawnbio * recrdev)
   seltype_Nparam(33)=0;   //   recruitment
   seltype_Nparam(34)=0;   //   spawning biomass depletion
   seltype_Nparam(35)=0;   //   survey of a dev vector

 END_CALCS

!!//  SS_Label_Info_4.9.1 #Read selectivity definitions
//  do 2*Nfleet to create options for size-selex (first), then age-selex
  init_imatrix seltype_rd(1,2*Nfleet,1,4)    // read selex type for each fleet/survey, Do_retention, Do_male
  imatrix seltype(1,2*Nfleet,1,4)
  !! echoinput<<endl<<"*******************"<<endl<<" selex types "<<endl<<seltype_rd<<endl;
  int N_selparm   // figure out the Total number of selex parameters
  int N_selparm2                 // N selparms plus env links and blocks
  int N_selparm3                 // need for 2D_AR
  ivector N_selparmvec(1,2*Nfleet)  //  N selparms by type, including extra parms for male selex, retention, etc.
  ivector Maleselparm(1,2*Nfleet)
  ivector RetainParm(1,2*Nfleet)
  ivector dolen(1,Nfleet)
  int blkparm
  int firstselparm
  ivector N_ret_parm(0,6)  //  6 possible retention functions allowed
  ivector N_disc_mort_parm(0,6)  //  6 possible discard mortality functions allowed
  ivector Do_Retain(1,Nfleet)  // indicates 0=none, 1=length based, 2=age based

 LOCAL_CALCS
//  define number of parameters for each retention type
  RetainParm.initialize();
  seltype.initialize();
  for(f=1;f<=2*Nfleet;f++)
  {seltype(f)(1,4)=seltype_rd(f)(1,4);}
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
  int depletion_fleet;  //  stores fleet(survey) number for the fleet that is defined as "depletion"
  int depletion_type;  //  entered by Q_setup(f,2) and stores additional controls for depletion fleet
  depletion_fleet=0;
  depletion_type=0;
   firstselparm=ParCount;
   N_selparm=0;
   Do_Retain.initialize();
   for (f=1;f<=Nfleet;f++)
   {
     if(WTage_rd>0 && seltype(f,1)>0)
     {
      N_warn++; warning<<" Use of size selectivity not advised when reading empirical wt-at-age "<<endl;
     }
     N_selparmvec(f)=seltype_Nparam(seltype(f,1));   // N Length selex parms
     if(seltype(f,1)==6) N_selparmvec(f) +=seltype(f,4);  // special setup of N parms
     if(seltype(f,1)==21) N_selparmvec(f) +=2*(seltype(f,4)-1);  // special setup of N parms
     if(seltype(f,1)==27) N_selparmvec(f) +=2*seltype(f,4);  // special setup of N parms for cubic spline
     if(seltype(f,1)>=30) {Svy_units(f)=seltype(f,1); seltype(f,1)=0;}  //  special expected values, no size selectivity
     if(seltype(f,1)>0 && Svy_units(f)<30) {dolen(f)=1;} else {dolen(f)=0;}

     if(seltype(f,1)==27)
     {
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
     else
     {
       for (j=1;j<=N_selparmvec(f);j++)
       {
         ParCount++; ParmLabel+="SizeSel_P"+NumLbl(j)+"_"+fleetname(f)+"("+NumLbl(f)+")";
       }
     }

     if(Svy_units(f)==34)  //  special code for depletion, so adjust phases and lambdas
      {
        depletion_fleet=f;
      }

     if(seltype(f,2)>=1)
     {
       if(WTage_rd>0)
       {
        N_warn++; warning<<" BEWARE: Retention functions not implemented fully when reading empirical wt-at-age "<<endl;
       }
       Do_Retain(f)=1;
       if(seltype(f,2)==3)
       {RetainParm(f)=0;}  //  no parameters needed
       else
       {
         RetainParm(f)=N_selparmvec(f)+1;
       for (j=1;j<=N_ret_parm(seltype(f,2));j++)
       {
         ParCount++; N_selparmvec(f)++; ParmLabel+="Retain_P"+NumLbl(j)+"_"+fleetname(f)+"("+NumLbl(f)+")";
       }

       if(seltype(f,2)==2 || seltype(f,2)==4)
       {
         for (j=1;j<=N_disc_mort_parm(seltype(f,2));j++)
         {
           ParCount++; N_selparmvec(f)++; ParmLabel+="DiscMort_P"+NumLbl(j)+"_"+fleetname(f)+"("+NumLbl(f)+")";
         }
       }
      }
     }
     if(seltype(f,3)>=1)
      {
        if(gender==1) {N_warn++; cout<<"Critical error"<<endl; warning<<" Male selex cannot be used in one sex model; fleet: "<<f<<endl; exit(1);}
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
          else if(seltype(f,1)==24)
          {
            N_selparmvec(f)++; ParCount++; ParmLabel+="SzSel_"+anystring+"Peak_"+fleetname(f)+"("+NumLbl(f)+")";
            N_selparmvec(f)++; ParCount++; ParmLabel+="SzSel_"+anystring+"Ascend_"+fleetname(f)+"("+NumLbl(f)+")";
            N_selparmvec(f)++; ParCount++; ParmLabel+="SzSel_"+anystring+"Descend_"+fleetname(f)+"("+NumLbl(f)+")";
            N_selparmvec(f)++; ParCount++; ParmLabel+="SzSel_"+anystring+"Final_"+fleetname(f)+"("+NumLbl(f)+")";
            N_selparmvec(f)++; ParCount++; ParmLabel+="SzSel_"+anystring+"Scale_"+fleetname(f)+"("+NumLbl(f)+")";
          }
          else
          {
            N_warn++; cout<<" EXIT - see warning "<<endl; warning<<"Illegal male selex option selected for fleet "<<f<<endl;  exit(1);
          }
        }
      }

     if(seltype(f,1)==7) {N_warn++; warning<<"ERROR:  selectivity pattern #7 is no longer supported "<<endl;}
     if(seltype(f,1)==23 && F_Method==1) {N_warn++; warning<<"Do not use F_Method = Pope's with selex pattern #23 "<<endl;}
     N_selparm += N_selparmvec(f);
   }
   for (f=Nfleet+1;f<=2*Nfleet;f++)
   {
     int f1=f-Nfleet;  // actual fleet number
     if(seltype(f,1)==15) // mirror
     {
       if(seltype(f,4)==0 || seltype(f,4)>=f-Nfleet)
       {
         N_warn++; cout<<" EXIT - see warning "<<endl; warning<<" illegal mirror for age selex fleet "<<f-Nfleet<<endl; exit(1);
       }
       N_selparmvec(f)=0;   // Nunber of Age selex parms
     }
     else if(seltype(f,1)!=17)
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

     if(seltype(f,1)==27)
     {
       N_selparmvec(f) +=2*seltype(f,4);  // special setup of N parms for cubic spline
       ParCount++; ParmLabel+="AgeSpline_Code_"+fleetname(f-Nfleet)+"_"+NumLbl(f-Nfleet);
       ParCount++; ParmLabel+="AgeSpline_GradLo_"+fleetname(f-Nfleet)+"_"+NumLbl(f-Nfleet);
       ParCount++; ParmLabel+="AgeSpline_GradHi_"+fleetname(f-Nfleet)+"_"+NumLbl(f-Nfleet);
       for (s=1;s<=seltype(f,4);s++)
       {
         ParCount++; ParmLabel+="AgeSpline_Knot_"+NumLbl(s)+"_"+fleetname(f-Nfleet)+"_"+NumLbl(f-Nfleet);
       }
       for (s=1;s<=seltype(f,4);s++)
       {
         ParCount++; ParmLabel+="AgeSpline_Val_"+NumLbl(s)+"_"+fleetname(f-Nfleet)+"_"+NumLbl(f-Nfleet);
       }
     }
     else
     {
       for (j=1;j<=N_selparmvec(f);j++)
       {
         ParCount++; ParmLabel+="AgeSel_P"+NumLbl(j)+"_"+fleetname(f-Nfleet)+"("+NumLbl(f-Nfleet)+")";
       }
     }

//  age-specific retention function
     if(seltype(f,2)>=1)
     {
     	 Do_Retain(f1)=2;
       if(WTage_rd>0)
       {
        N_warn++; warning<<" BEWARE: Retention functions not implemented fully when reading empirical wt-at-age "<<endl;
       }
       if(seltype(f1,2)>0)
        {
          N_warn++; cout<<" EXIT - see warning "<<endl; warning<<" ERROR:  cannot have both age and size retention functions "<<f<<"  but retention parms not setup "<<endl; exit(1);
        }
       if(seltype(f,2)==3)
       {RetainParm(f)=0;}  //  no parameters needed
       else
       {
         RetainParm(f)=N_selparmvec(f)+1;
         for (j=1;j<=N_ret_parm(seltype(f,2));j++)
         {
           ParCount++; N_selparmvec(f)++; ParmLabel+="Retain_age_P"+NumLbl(j)+"_"+fleetname(f1)+"("+NumLbl(f1)+")";
         }
         if(seltype(f,2)==2 || seltype(f,2)==4)
         {
           for (j=1;j<=N_disc_mort_parm(seltype(f,2));j++)
           {
             ParCount++; N_selparmvec(f)++; ParmLabel+="DiscMort_age_P"+NumLbl(j)+"_"+fleetname(f1)+"("+NumLbl(f1)+")";
           }
         }
       }
     }

     if(seltype(f,3)>=1)
      {
        if(gender==1) {N_warn++; cout<<"Critical error"<<endl; warning<<" Male selex cannot be used in one sex model; fleet: "<<f<<endl; exit(1);}
        Maleselparm(f)=N_selparmvec(f)+1;
        if(seltype(f,3)==1 || seltype(f,3)==2)
        {
          N_selparmvec(f)++; ParCount++; ParmLabel+="AgeSel_"+NumLbl(f-Nfleet)+"MaleDogleg_"+fleetname(f-Nfleet);
          N_selparmvec(f)++; ParCount++; ParmLabel+="AgeSel_"+NumLbl(f-Nfleet)+"MaleatZero_"+fleetname(f-Nfleet);
          N_selparmvec(f)++; ParCount++; ParmLabel+="AgeSel_"+NumLbl(f-Nfleet)+"MaleatDogleg_"+fleetname(f-Nfleet);
          N_selparmvec(f)++; ParCount++; ParmLabel+="AgeSel_"+NumLbl(f-Nfleet)+"MaleatMaxage_"+fleetname(f-Nfleet);
        }
        else if(seltype(f,3)>=3 && seltype(f,1)==20)
        {
          if(seltype(f,3)==3) {anystring="Male_";} else {anystring="Fem_";}
          N_selparmvec(f)++; ParCount++; ParmLabel+="AgeSel_"+NumLbl(f-Nfleet)+anystring+"Peak_"+fleetname(f-Nfleet);
          N_selparmvec(f)++; ParCount++; ParmLabel+="AgeSel_"+NumLbl(f-Nfleet)+anystring+"Ascend_"+fleetname(f-Nfleet);
          N_selparmvec(f)++; ParCount++; ParmLabel+="AgeSel_"+NumLbl(f-Nfleet)+anystring+"Descend_"+fleetname(f-Nfleet);
          N_selparmvec(f)++; ParCount++; ParmLabel+="AgeSel_"+NumLbl(f-Nfleet)+anystring+"Final_"+fleetname(f-Nfleet);
          N_selparmvec(f)++; ParCount++; ParmLabel+="AgeSel_"+NumLbl(f-Nfleet)+anystring+"Scale_"+fleetname(f-Nfleet);
        }
        else
        {
          N_warn++; cout<<" EXIT - see warning "<<endl; warning<<"Illegal male selex option selected for fleet "<<f<<endl;  exit(1);
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
   for (f=1;f<=Nfleet;f++)
   {
   if(disc_N_fleet(f)>0 && seltype(f,2)==0)
     {N_warn++; cout<<" EXIT - see warning "<<endl; warning<<" ERROR:  discard data exist for fleet "<<f<<"  but retention parms not setup "<<endl; exit(1);}
   else if (disc_N_fleet(f)==0 && seltype(f,2)>0)
     {N_warn++; warning<<" WARNING:  no discard amount data for fleet "<<f<<"  but retention parms have been defined "<<endl;}
   }
 END_CALCS

!!//  SS_Label_Info_4.9.3 #Read selex parameters
  init_matrix selparm_1(1,N_selparm,1,14)
  ivector selparm_fleet(1,N_selparm) // holds the fleet ID for each selparm
                                  //  equivalent to the mgp_type() for MGparms
  number new_upper_bound;
  number new_lower_bound;

 LOCAL_CALCS
  new_lower_bound=0;
  new_upper_bound=1;
  echoinput<<" selex base parameters "<<endl;
  for (g=1;g<=N_selparm;g++)
  {
    echoinput<<g<<" ## "<<selparm_1(g)<<" ## "<<ParmLabel(ParCount-N_selparm+g)<<endl;
  }
  //  now identify the fleet associated with each parameter
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
//  check on conversion of retention parameter
  int parmcount;
  parmcount=0;
  for(f=1;f<=2*Nfleet;f++)
  {
    if(RetainParm(f)>0)
    {
      k=parmcount+RetainParm(f)+2;
      if(selparm_1(k,1) >=0.0)
        {
          N_warn++; warning<<"convert asymptotic retention to 1/(1+e(-x)) format for fleet: "<<f<<" parm: "<<k<<endl;
          warning<<"old min, max, init, prior: "<<selparm_1(k)(1,4)<<endl;

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

          warning<<"new min, max, init, prior: "<<selparm_1(k)(1,4)<<endl;
          warning<<"if timevarying, you will need to do conversion manually"<<endl;
        }
    }
    parmcount+=N_selparmvec(f);
  }
  echoinput<<"end conversion of retention "<<endl;
 END_CALCS

  imatrix timevary_makefishsel(styr-3,YrMax,1,Nfleet)
  int makefishsel_yr
!!//  SS_Label_Info_4.9.4 #Create and label environmental linkages for selectivity parameters
!!//  SS_Label_Info_4.9.5 #Create and label block patterns for selectivity parameters
  int N_selparm_blk                            // number of selparms that use blocks
  int customblocksetup  //  0=read one setup and apply to all; 1=read each
  int N_selparm_trend     //   number of selex parameters using trend
  int N_selparm_env                            // number of selparms that use env linkage
  int custom_selenv_setup  //  0=read one setup and apply to all; 1=read each
//  ivector selparm_env(1,N_selparm)             //  pointer to parameter with env link for each selparm
//  ivector selparm_envuse(1,N_selparm)   // contains the environment data number
//  ivector selparm_envtype(1,N_selparm)  // 1=multiplicative; 2= additive
  imatrix Block_Defs_Sel(1,N_selparm,styr,YrMax)

 LOCAL_CALCS
  custom_selenv_setup=0;
  customblocksetup=0;
  timevary_makefishsel.initialize();
  Block_Defs_Sel.initialize();

  N_selparm_env=0;
  for (j=1;j<=N_selparm;j++)
  {
    if(selparm_1(j,8)!=0)
    {
      N_selparm_env++;
  /*
      selparm_env(j)=N_selparm+N_selparm_env;
      if(selparm_1(j,8)>0)
      {
        ParCount++; ParmLabel+=ParmLabel(j+firstselparm)+"_ENV_mult"; selparm_envtype(j)=1; selparm_envuse(j)=selparm_1(j,8);
      }
       else if(selparm_1(j,8)==-999)
       {ParCount++; ParmLabel+=ParmLabel(j+firstselparm)+"_ENV_densdep"; selparm_envtype(j)=3;  selparm_envuse(j)=-1;}
       else
       {ParCount++; ParmLabel+=ParmLabel(j+firstselparm)+"_ENV_add"; selparm_envtype(j)=2; selparm_envuse(j)=-selparm_1(j,8);}
  */
    }
  }

  if(N_selparm_env>0)
  {
    *(ad_comm::global_datafile) >> custom_selenv_setup;
    if(custom_selenv_setup==0) {k1=1;} else {k1=N_selparm_env;}
    echoinput<<custom_selenv_setup<<" custom_selenv_setup"<<endl;
  }
  else
  {
    custom_selenv_setup=0; k1=0;
    echoinput<<" no envlinks; so don't read custom_selenv_setup"<<endl;
  }
 END_CALCS

  init_matrix selparm_env_1(1,k1,1,7)  // read matrix that sets up the env linkage parms
 LOCAL_CALCS
  if(k1>0)
  {
    echoinput<<" selex-env parameters "<<endl<<selparm_env_1<<endl;
    for (g=1;g<=k1;g++)
    {
      echoinput<<g<<" ## "<<selparm_env_1(g)<<" ## "<<ParmLabel(ParCount-k1+g)<<endl;
    }
  }
   echoinput<<"check for sel blocks "<<endl;
   N_selparm_blk=0;  // counter for assigned parms
   for (j=1;j<=N_selparm;j++)
   {
//   	 j1=firstselparm+j;
     z=selparm_1(j,13);    // specified block or trend definition
     if(z==0)    //  no blocks or trends
     {}
     else if (z>0)  //  blocks with z as the block pattern
       {
         if(z>N_Block_Designs) {N_warn++; warning<<" ERROR, Block > N Blocks "<<z<<" "<<N_Block_Designs<<endl; exit(1);}
         N_selparm_blk+=Nblk(z);  //  N parameters
  /*
         g=1;  //  index to list in block design
         timevary_Nread=Nblk(z);
         for (a=1;a<=Nblk(z);a++)
         {
          timevary_parm_cnt++;
          N_selparm_blk++;
          y=Block_Design(z,g);
          sprintf(onenum, "%d", y);
          ParCount++;
          k=int(selparm_1(j,14));
          switch(k)
          {
            case 0:
            {ParmLabel+=ParmLabel(j1)+"_BLK"+NumLbl(z)+"mult_"+onenum+CRLF(1);  break;}
            case 1:
            {ParmLabel+=ParmLabel(j1)+"_BLK"+NumLbl(z)+"add_"+onenum+CRLF(1);  break;}
            case 2:
            {ParmLabel+=ParmLabel(j1)+"_BLK"+NumLbl(z)+"repl_"+onenum+CRLF(1);  break;}
            case 3:
            {ParmLabel+=ParmLabel(j1)+"_BLK"+NumLbl(z)+"delta_"+onenum+CRLF(1);  break;}
          }
          y=Block_Design(z,g+1)+1;  // first year after block
          if(y>endyr+1) y=endyr+1;  //  need to revise to deal with interaction of retrospective and blocks
          for (y=Block_Design(z,g);y<=Block_Design(z,g+1);y++)  // loop years for this block
          {
           if(y<=endyr) Block_Defs_Sel(j,y)=N_selparm+N_selparm_env+N_selparm_blk;
          }
          g+=2;
         }
  */
       }
       else if (z<0)  //  (z<0) so invoke a trend
       {
         if(z==-1 || z==-2)
          {
            N_selparm_blk+=3;  //  N parameters
          }
          else
            {
              N_selparm_blk+=Ncycle;
            }
  /*
         timevary_Nread=3;
         N_selparm_trend++;
          if(selparm_1(j,13)==-1)
          {
            ParCount++; ParmLabel+=ParmLabel(j1)+"_TrendFinal_Offset"+CRLF(1);
            ParCount++; ParmLabel+=ParmLabel(j1)+"_TrendInfl_"+CRLF(1);
            ParCount++; ParmLabel+=ParmLabel(j1)+"_TrendWidth_"+CRLF(1);
            timevary_parm_cnt+=timevary_Nread;  //  for the 3 trend parameters
          }
          else if(selparm_1(j,13)==-2)
          {
            ParCount++; ParmLabel+=ParmLabel(j1)+"_TrendFinal_"+CRLF(1);
            ParCount++; ParmLabel+=ParmLabel(j1)+"_TrendInfl_"+CRLF(1);
            ParCount++; ParmLabel+=ParmLabel(j1)+"_TrendWidth_"+CRLF(1);
            timevary_parm_cnt+=timevary_Nread;  //  for the 3 trend parameters
          }
          else
          {
            timevary_Nread=Ncycle;
            timevary_parm_cnt+=Ncycle;
            for (icycle=1;icycle<=Ncycle;icycle++)
            {
              ParCount++; ParmLabel+=ParmLabel(j1)+"_Cycle_"+NumLbl(icycle)+CRLF(1);
            }
          }
  */
       }
//       timevary_def.push_back (itempvec(1,13));
   }

   if(N_selparm_blk>0)
   {
     *(ad_comm::global_datafile) >> customblocksetup;
     echoinput<<customblocksetup<<" customblocksetup"<<endl;
     if(customblocksetup==0)
     {
       k1=1;
     }
     else
     {k1=N_selparm_blk;}
   }
 END_CALCS

!!//  SS_Label_Info_4.9.5 #Create and label block patterns for selectivity parameters

  init_matrix selparm_blk_1(1,k1,1,7);  // double check this matrix that defines the block parms and trend parms

  !!//  SS_Label_Info_4.9.7 #Create and label selectivity parameter annual devs
  int N_selparm_dev   // number of selparms that use random deviations
  int selparm_dev_PH
 LOCAL_CALCS
   echoinput<<"check for sel devs "<<endl;
  N_selparm_dev=0;
  for (j=1;j<=N_selparm;j++)
  {
    if(selparm_1(j,9)>0)
    {
      N_selparm_dev++;
    }
  }
  selparm_dev_PH=0;
  if(N_selparm_dev > 0)
  {
    *(ad_comm::global_datafile) >> selparm_dev_PH;
     echoinput<<selparm_dev_PH<<" selparm_dev_PH"<<endl;
    if(depletion_fleet>0 && selparm_dev_PH>0) selparm_dev_PH++;
    if(selparm_dev_PH > Turn_off_phase) selparm_dev_PH =-1;
    if(selparm_dev_PH > max_phase) max_phase=selparm_dev_PH;
  }

  if(N_selparm_env+N_selparm_blk+N_selparm_dev > 0)
  {
    *(ad_comm::global_datafile) >> temp;
     echoinput<<temp<<" dummy read of parm_adjust_method"<<endl;
     if(temp!=parm_adjust_method)
      {N_warn++; warning<<"3.24 had selex with parmadjust= "<<temp<<"; will use in 3.30 the same as MGparm: "<<parm_adjust_method<<endl;}
  }
  N_selparm2=N_selparm+N_selparm_env+N_selparm_blk+2*N_selparm_dev;
  N_selparm3=N_selparm2;
  echoinput<<"N selparm "<<N_selparm<<" "<<N_selparm2<<endl;
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

!!//  SS_Label_Info_4.5.4 #Set up time-varying parameters for sel parms
  int timevary_parm_cnt_sel;
  int timevary_parm_start_sel;
  ivector selparm_timevary(1,N_selparm)  //  holds index in timevary_def used by this base parameter
  imatrix timevary_sel(styr-3,YrMax+1,0,2*Nfleet)  // goes to yrmax+1 to allow referencing in forecast, but only endyr+1 is checked
  int TwoD_AR_do;
  int TwoD_AR_cnt
  ivector TwoD_AR_use(1,2*Nfleet);
  ivector TwoD_AR_before(1,TwoD_AR_cnt) //  what to do in years before the year range
  ivector TwoD_AR_after(1,TwoD_AR_cnt)  //  what to do in years after the year range

 LOCAL_CALCS
   timevary_sel.initialize();    // stores years to calc non-constant sel parms by fleet
   timevary_parm_start_sel=0;
   timevary_parm_cnt_sel=0;
   selparm_timevary.initialize();
   TwoD_AR_use.initialize();
   int selblkcnt;
   int selenvcnt;
   selblkcnt=0;
   selenvcnt=0;

   for (j=1;j<=N_selparm;j++)
   {
     k=selparm_fleet(j);
     timevary_pass=column(timevary_sel,k);  // year vector for this fleet

     if(selparm_1(j,13)==0 && selparm_1(j,8)==0 && selparm_1(j,9)==0)
     {
      //  no time-vary parameter effects
     }
     else
     {
       echoinput<<endl<<" create timevary for sel parameter: "<<j<<endl;
       ivector timevary_setup(1,13);  //  temporary vector for timevary specs
       timevary_setup.initialize();
//  1=baseparm type; 2=baseparm index; 3=first timevary parm
//  4=block or trend type; 5=block pattern; 6= env link type; 7=env variable;
//  8=dev vector used; 9=dev link type; 10=dev min year; 11=dev maxyear; 12=dev phase; 13=all parm index of baseparm
       if(timevary_parm_start_sel==0) timevary_parm_start_sel=timevary_parm_cnt+1;
       timevary_cnt++;  //  count parameters with time-vary effect
       selparm_timevary(j)=timevary_cnt;  //  base parameter will use this timevary specification
       timevary_setup(1)=5; //  indicates a sel parm
       timevary_setup(2)=j; //  index of base parm within that type of parameter
       timevary_setup(13)=firstselparm+j;  //  index of base parm relative to ParCount which is continuous across all types of parameters
       timevary_setup(3)=timevary_parm_cnt+1;  //  first parameter within total list of all timevary parms

//  set up env link info
//   where abs(selparm1(j,8) is the environmental variable used;  store this in timevary_setup(7)
//   and the sign indicates the link;  store this in timevary_setup(6)
      if(selparm_1(j,8)>0)  //  multiplicative link
      {
        timevary_setup(6)=1; timevary_setup(7)=selparm_1(j,8);
      }
      else if(selparm_1(j,8)==-999)  //  density-dependence
      {timevary_setup(6)=3;  timevary_setup(7)=-1;}
       else            //  additive link
       {timevary_setup(6)=2; timevary_setup(7)=-selparm_1(j,8);}

       if(selparm_1(j,8)!=0)
        {
          selparm_1(j,8)=100.*timevary_setup(6)+timevary_setup(7);
          echoinput<<" convert env to 330 format "<<selparm_1(j,8)<<endl;
         k=timevary_setup(7);
         for(y=styr-1;y<=YrMax;y++) env_data_pass(y)=env_data_RD(y,k);
        }
       else
       {env_data_pass.initialize();}

       z=selparm_1(j,13);    // specified block or trend definition
       if(z>0)  //  doing blocks
       {
         create_timevary(selparm_1(j),timevary_setup, timevary_pass, autogen_timevary(timevary_setup(1)), selparm_fleet(j), Block_Design(z), parm_adjust_method, env_data_pass, N_parm_dev,finish_starter);
       }
       else
       {
         create_timevary(selparm_1(j),timevary_setup, timevary_pass, autogen_timevary(timevary_setup(1)), selparm_fleet(j), block_design_null, parm_adjust_method, env_data_pass, N_parm_dev,finish_starter);
       }
       if(selparm_1(j,9)>0) selparm_1(j,12) = selparm_dev_PH;
  /*
   where:
   selparm_1(j):           vector with the base parameter which has some type of timevary characteristic
   timevary_setup:        vector which contains specs of all types of timevary  for this base parameter
                          will be pushed to timevary_def cumulative across all types of base parameters
   timevary_pass:        vector containing column(timevary_sel,selparm_fleet(j)), will be modified in create_timevary
   autogen_timevary:      switch to autogenerate or not
   selparm_fleet(j):           integer with type of selparm being worked on; analogous to 2*fleet in the selectivity section
   block_design(z):       block design, if any, being used
   parm_adjust_method:    switch to determine if adjusted parameter will stay in bounds; used to create warnings in create_timevary
   env_data_RD:           matrix containing entire set of environmental data as read
   N_parm_dev:            integer that is incremented in create_timevary as dev vectors are created; cumulative across all types of parameters
  */
       tvparm=timevary_setup(3)-1;  //  index of first timevay parameter used here
       if(timevary_setup(5)>0 && customblocksetup==1)  //  move block info from 3.24 inputs
       {
          echoinput<<" copy selblock info from 3.24 "<<endl;
          z=selparm_1(j,13);    // specified block or trend definition
          if (z>0)  //  blocks with z as the block pattern
          {
            for (a=1;a<=Nblk(z);a++)  //  loop blocks for block pattern z
            {
              tvparm++;
              selblkcnt++;
              echoinput<<"move sel blk info from 3.24 index "<<selblkcnt<<"  to 3.30 index  "<<tvparm<<endl;
              timevary_parm_rd[tvparm](1,7)=selparm_blk_1(selblkcnt)(1,7);
              temp=timevary_parm_rd[tvparm](5);
              timevary_parm_rd[tvparm](5)=timevary_parm_rd[tvparm](6);
              timevary_parm_rd[tvparm](6)=temp;
              echoinput<<timevary_parm_rd[tvparm]<<endl;
            }
          }
          else //  (z<0) so invoke a trend
          {
            for (a=1;a<=3;a++)  //  loop blocks for block pattern z
            {
              tvparm++;
              selblkcnt++;
              echoinput<<"move sel trend info from 3.24 index "<<selblkcnt<<"  to 3.30 index  "<<tvparm<<endl;
              timevary_parm_rd[tvparm](1,7)=selparm_blk_1(selblkcnt)(1,7);
              temp=timevary_parm_rd[tvparm](5);
              timevary_parm_rd[tvparm](5)=timevary_parm_rd[tvparm](6);
              timevary_parm_rd[tvparm](6)=temp;
              echoinput<<timevary_parm_rd[tvparm]<<endl;
            }
          }
       }

       if(custom_selenv_setup==1)  // selex
       {
         tvparm++;
         selenvcnt++;
         echoinput<<"move sel env  info from 3.24 index "<<selenvcnt<<"  to 3.30 index  "<<tvparm<<endl;
         timevary_parm_rd[tvparm](1,7)=selparm_env_1(selenvcnt)(1,7);
         temp=timevary_parm_rd[tvparm](5);
         timevary_parm_rd[tvparm](5)=timevary_parm_rd[tvparm](6);
         timevary_parm_rd[tvparm](6)=temp;
         echoinput<<timevary_parm_rd[tvparm]<<endl;
       }

       if(timevary_setup(8)!=0) timevary_setup(12)=selparm_dev_PH;
       timevary_def.push_back (timevary_setup(1,13));
       for(y=styr-3;y<=YrMax+1;y++) {timevary_sel(y,selparm_fleet(j))=timevary_pass(y);}  // year vector for this category og selparm
     }
   }

   if (timevary_parm_start_sel > 0)
   {
     timevary_parm_cnt_sel=timevary_parm_cnt;
     echoinput<<" timevary_selparm_cnt start "<<timevary_parm_start_sel<<" and end "<<timevary_parm_cnt_sel<<endl;
   }
   timevary_setup.initialize();
   timevary_setup(3)=timevary_parm_cnt+1;
   timevary_def.push_back (timevary_setup(1,13));  //  one past last one used

//  SS_Label_Info_4.9.12 #Create vectors, e.g. selparm_PH(), that will be used to create actual array of estimted parameters
  {
   for (f=1;f<=N_selparm;f++)
   {
    selparm_LO(f)=selparm_1(f,1);
    selparm_HI(f)=selparm_1(f,2);
    selparm_RD(f)=selparm_1(f,3);
    selparm_PR(f)=selparm_1(f,4);
    temp=selparm_1(f,5);
    if(temp==0) temp=6.;
    if(temp<0) temp=0;
    selparm_1(f,5)=selparm_1(f,6);
    selparm_1(f,6)=temp;
    selparm_CV(f)=selparm_1(f,5);
    selparm_PRtype(f)=selparm_1(f,6);
    selparm_PH(f)=selparm_1(f,7);
   }
   j=N_selparm;

   if(timevary_parm_start_sel>0)
   for (f=timevary_parm_start_sel;f<=timevary_parm_cnt_sel;f++)
   {
    j++;
    selparm_LO(j)=timevary_parm_rd[f](1);
    selparm_HI(j)=timevary_parm_rd[f](2);
    selparm_RD(j)=timevary_parm_rd[f](3);
    selparm_PR(j)=timevary_parm_rd[f](4);
    temp=timevary_parm_rd[f](6);
    if(temp==0) temp=6.;
    if(temp<0) temp=0;
    timevary_parm_rd[f](6)=temp;
    selparm_PRtype(j)=timevary_parm_rd[f](6);
    selparm_CV(j)=timevary_parm_rd[f](5);
    selparm_PH(j)=timevary_parm_rd[f](7);
   }
  }

//  SS_Label_Info_4.9.10 #Special bound checking for size selex parameters
    z=0;  // parameter counter within this section
    for (f=1;f<=Nfleet;f++)
    {
      if(seltype(f,1)==8 || seltype(f,1)==22 || seltype(f,1)==23 || seltype(f,1)==24)
      {
        if(selparm_1(z+1,1)<len_bins_m(2))
        {N_warn++;
          warning<<"Fleet:_"<<f<<" min bound on parameter for size at peak is "<<selparm_1(z+1,1)<<"; should be >= midsize bin 2 ("<<len_bins_m(2)<<")"<<endl;}
        if(selparm_1(z+1,1)<len_bins_dat(1) && seltype(f,1)==24)
        {N_warn++;
          warning<<"Fleet:_"<<f<<" min bound on parameter for size at peak is "<<selparm_1(z+1,1)<<"; which is < min databin ("<<len_bins_dat(1)<<"), so illogical."<<endl;}
        if(selparm_1(z+1,2)>len_bins_m(nlength-1))
        {N_warn++;
          warning<<"Fleet:_"<<f<<" max bound on parameter for size at peak is "<<selparm_1(z+1,2)<<"; should be <= midsize bin N-1 ("<<len_bins_m(nlength-1)<<")"<<endl;}
      }
      z+=N_selparmvec(f);
    }
// end special bound checking

//  SS_Label_Info_4.9.11  #Create time/fleet array indicating when changes in selex occcur
  timevary_makefishsel.initialize();
  timevary_sel(styr)=1;
//  if(Do_Forecast>0) timevary_sel(endyr+1)=1;
  timevary_sel(endyr+1)=1;
  timevary_makefishsel(styr)=1;
  timevary_makefishsel(styr-3)=1;
//  if(Do_Forecast>0) timevary_makefishsel(endyr+1)=1;
  timevary_makefishsel(endyr+1)=1;
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
      else
      {
  /*
        if(seltype_Nparam(seltype(f,1))>0 || (seltype(f,2)==1) || (seltype(f,2)==2))      // type has parms, so look for adjustments
        {
          for (j=1;j<=N_selparmvec(f);j++)
          {
            z++;
            if(selparm_envuse(z)!=0)          // env linkage
            {
             if((env_data_RD(y,selparm_envuse(z))!=env_data_RD(y-1,selparm_envuse(z)) || selparm_envtype(z)==3 )) timevary_sel(y,f)=1;
            }
            if(selparm_1(z,9)>=1)  // dev vector
            {
              s=selparm_1(z,11)+1;
              if(s>endyr) s=endyr;
              if(y>=selparm_1(z,10) && y<=s) timevary_sel(y,f)=1;
            }

            if(selparm_1(z,13)>0) //   blocks
            {
              if(Block_Defs_Sel(z,y)!=Block_Defs_Sel(z,y-1) ) timevary_sel(y,f)=1;
            }

            if(selparm_1(z,13)<0) //   trend
            {
              timevary_sel(y,f)=1;
            }
          }
        }
  */
      }
      if(f<=Nfleet && seltype(f,2)<0)  //  retention is being mirrored
      {
        k=-seltype(f,2);
        if(timevary_sel(y,k)>0) timevary_sel(y,f)=1;
      }
    }  // end type

//    timevary_makefishsel(y)(1,Nfleet)=timevary_sel(y)(1,Nfleet);  //  error, this will only do size selex
    for (f=1;f<=Nfleet;f++)
    {
      if(timevary_sel(y,f)>0 || timevary_sel(y,f+Nfleet)>0) timevary_makefishsel(y,f)=1;
    }

    if(timevary_MG(y,2)>0 || timevary_MG(y,3)>0 || WTage_rd>0)  //  check to see if growth changes
    {
      timevary_makefishsel(y)=1;
    }
  } // end years

 END_CALCS   //  end of selectivity section

!!//  SS_Label_Info_4.10 #Read tag recapture parameter setup
// if Tags are used, the read parameters for initial tag loss, chronic tag loss, andd
// fleet-specific tag reporting.  Of these, only reporting rate will be allowed to be time-varying
  init_int TG_custom;  // 1=read; 0=create default parameters
  !! echoinput<<endl<<"*******************"<<endl<<TG_custom<<" TG_custom (need to read even if no tag data )"<<endl;
  !! k=TG_custom*Do_TG*(3*N_TG+2*Nfleet1);
  init_matrix TG_parm1(1,k,1,14);  // read initial values
  !! if(k>0) echoinput<<" Tag parameters as read "<<endl<<TG_parm1<<endl;
  !! k=Do_TG*(3*N_TG+2*Nfleet1);
  matrix TG_parm2(1,k,1,14);
  !!if(Do_TG>0) {k1=k;} else {k1=1;}
  vector TG_parm_LO(1,k1);
  vector TG_parm_HI(1,k1);
  ivector TG_parm_PH(1,k1);
 LOCAL_CALCS   //  begin of tagging section
  if(Do_TG>0)
  {
    if(TG_custom==1)
    {
      TG_parm2=TG_parm1;  // assign to the read values
      for(j=1;j<=k;j++)
      {
        temp=TG_parm2(j,5);
        if(temp==0) temp=6;
        if(temp<0) temp=0;
        TG_parm2(j,5)=TG_parm2(j,6);
        TG_parm2(j,6)=temp;
      }
    }
    else
    {
      TG_parm2.initialize();
      onenum="    ";
      for (j=1;j<=N_TG;j++)
      {
        TG_parm2(j,1)=-10;  // min
        TG_parm2(j,2)=10;   // max
        TG_parm2(j,3)=-9.;   // init
        TG_parm2(j,4)=-9.;   // prior
        TG_parm2(j,5)=1.;   // default prior type is symmetric beta
        TG_parm2(j,6)=0.001;  //  prior is quite diffuse
        TG_parm2(j,7)=-4;  // phase
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
        TG_parm2(j+2*N_TG,5)=1.;   // default prior type is symmetric beta
        TG_parm2(j+2*N_TG,6)=0.001;  //  prior is quite diffuse
        TG_parm2(j+2*N_TG,7)=-4;  // phase
      }
      for (j=1;j<=Nfleet1;j++)
      {
        TG_parm2(j+3*N_TG)=TG_parm2(1);  // set tag reporting equal to near 1.0, as is the tag retention parameters
      }
      // set tag reporting decay to nil decay rate
      for (j=1;j<=Nfleet1;j++)
      {
        k=j+3*N_TG+Nfleet1;
        TG_parm2(k,1)=-4.;
        TG_parm2(k,2)=0.;
        TG_parm2(k,3)=0.;
        TG_parm2(k,4)=0.;    // prior of zero
        TG_parm2(k,5)=6.;  // default prior is normal  squared dev
        TG_parm2(k,6)=2.;  // sd dev of prior
        TG_parm2(k,7)=-4.;
      }
    }

//  SS_Label_Info_4.10.1 #Create parameter count and parameter names for tag parameters
       onenum="    ";
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
       for (j=1;j<=Nfleet1;j++)
      {
       sprintf(onenum, "%d", j);
       ParCount++; ParmLabel+="TG_report_fleet:_"+onenum+CRLF(1);
      }
       for (j=1;j<=Nfleet1;j++)
      {
       sprintf(onenum, "%d", j);
       ParCount++; ParmLabel+="TG_rpt_decay_fleet:_"+onenum+CRLF(1);
      }

    TG_parm_LO=column(TG_parm2,1);
    TG_parm_HI=column(TG_parm2,2);
    k=3*N_TG+2*Nfleet1;
    for (j=1;j<=k;j++)
    {
      TG_parm_PH(j)=TG_parm2(j,7);  // write it out due to no typecast available
    }
    echoinput<<" Processed/generated Tag parameters "<<endl<<TG_parm2<<endl;

  }
  else
  {
    TG_parm_LO.initialize();
    TG_parm_HI.initialize();
    TG_parm_PH.initialize();
  }
 END_CALCS

//  now create the dev vectors and their labels
   ivector parm_dev_minyr(1,N_parm_dev);
   ivector parm_dev_maxyr(1,N_parm_dev);
   ivector parm_dev_PH(1,N_parm_dev);
   ivector parm_dev_type(1,N_parm_dev);  //  distinguish parameter dev vectors from 2DAR devs
   ivector parm_dev_info(1,N_parm_dev);  //  pointer from list of devvectorsto 2DAR list
   ivector TwoD_AR_ymin(1,1)
   ivector TwoD_AR_ymax(1,1)
   ivector TwoD_AR_amin(1,1)
   ivector TwoD_AR_amax(1,1)
   ivector TwoD_AR_degfree(1,TwoD_AR_cnt)  //  N years with observations * nages in the 2D_AR range
   ivector TwoD_AR_cor_dim(1,1)

 LOCAL_CALCS

   TwoD_AR_ymin.initialize();
   TwoD_AR_ymax.initialize();
   TwoD_AR_amin.initialize();
   TwoD_AR_amax.initialize();
   TwoD_AR_cor_dim.initialize();
   TwoD_AR_degfree.initialize();
//  1=baseparm type; 2=baseparm index; 3=first timevary parm
//  4=block or trend type; 5=block pattern; 6= env link type; 7=env variable;
//  8=dev vector used; 9=dev link type; 10=dev min year; 11=dev maxyear; 12=dev phase; 13=all parm index of baseparm
   if(timevary_cnt>0)
   {
     echoinput<<endl<<"final processing of timevary setup to create dev vectors as needed "<<endl;
     for (j=1;j<=timevary_cnt;j++)  //  loop set up timevary
     {
       ivector timevary_setup(1,13);
       timevary_setup(1,13)=timevary_def[j](1,13);
       echoinput<<"setup: "<<timevary_setup<<endl;

       if(timevary_setup(8)>0)  //  create dev approach and then move from 3.24 inputs
       {
         k=timevary_setup(8);  //  dev vector used
         parm_dev_minyr(k)=timevary_setup(10);  //  used for dimensioning the dev vectors in SS_param
         parm_dev_maxyr(k)=timevary_setup(11);
         parm_dev_PH(k)=timevary_setup(12);
         parm_dev_type(k)=1;
         if(depletion_fleet>0 && parm_dev_PH(k)>0) parm_dev_PH(k)++;//  add 1 to phase if using depletion fleet
         if(parm_dev_PH(k)>Turn_off_phase) parm_dev_PH(k) =-1;
         if(parm_dev_PH(k)>max_phase) max_phase=parm_dev_PH(k);
         f=timevary_setup(13);
         echoinput<<" index of base parm for dev "<<f<<" "<<ParmLabel(f)<<" create devlink: "<<timevary_setup(9)<<endl; //  index of base parameter
         echoinput<<" use dev vector "<<k<<" with min-max yr "<<parm_dev_minyr(k)<<" "<<parm_dev_maxyr(k)<<endl;
         for(y=parm_dev_minyr(k);y<=parm_dev_maxyr(k);y++)
         {
           sprintf(onenum, "%d", y);
           ParCount++;
           if(timevary_setup(9)==1)
           {ParmLabel+=ParmLabel(f)+"_DEVmult_"+onenum+CRLF(1);}
           else if(timevary_setup(9)==2)
           {ParmLabel+=ParmLabel(f)+"_DEVadd_"+onenum+CRLF(1);}
           else if(timevary_setup(9)==3)
           {ParmLabel+=ParmLabel(f)+"_DEVrwalk_"+onenum+CRLF(1);}
           else if(timevary_setup(9)==4)
           {ParmLabel+=ParmLabel(f)+"_DEV_MR_rwalk_"+onenum+CRLF(1);}
           else
           {N_warn++; cout<<" EXIT - see warning "<<endl; warning<<" illegal parmdevtype for parm "<<f<<endl; exit(1);}
         }
         echoinput<<"made dev labels OK "<<endl;
       }
     }
   }
 END_CALCS

!!//  SS_Label_Info_4.11 #Read variance adjustment and various variance related inputs
  init_int Do_Var_adjust
  init_matrix var_adjust1(1,6*Do_Var_adjust,1,Nfleet)
  matrix var_adjust(1,7,1,Nfleet)
 LOCAL_CALCS
  echoinput<<Do_Var_adjust<<" Do_Var_adjust "<<endl;
  if(Do_Var_adjust>0)
  {
    for(j=1;j<=6;j++) var_adjust(j)=var_adjust1(j);
    var_adjust(7)=1.0;  // generalized size comp
    echoinput<<" Variance adjustments as read "<<endl<<var_adjust1<<endl;
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
//  convert to list format for version 3.30
  k=0;
  for(f=1;f<=Nfleet;f++)
  {
    for(j=1;j<=3;j++)
    {
      if(var_adjust(j,f)!=0.0) {k++;}
    }
    for(j=4;j<=6;j++)
    {
      if(var_adjust(j,f)!=1.0) k++;
    }
  }
  Do_Var_adjust=k;
 END_CALCS
  matrix var_adjust_list(1,Do_Var_adjust,1,3)

 LOCAL_CALCS
  if(Do_Var_adjust>0)
  {
    k=0;
    for(f=1;f<=Nfleet;f++)
    {
    for(j=1;j<=3;j++)
    {if(var_adjust(j,f)!=0.0) {k++; var_adjust_list(k,1)=j; var_adjust_list(k,2)=f; var_adjust_list(k,3)=var_adjust(j,f);}  }
    for(j=4;j<=7;j++)
    {if(var_adjust(j,f)!=1.0) {k++; var_adjust_list(k,1)=j; var_adjust_list(k,2)=f; var_adjust_list(k,3)=var_adjust(j,f);}  }
    }
    echoinput<<"Variance adjustments as list; per 3.30 format "<<endl<<var_adjust_list<<endl;
    for (i=1; i <= Do_Var_adjust; i++) var_adjust_data.push_back(var_adjust_list(i));
  }
 END_CALCS

  init_number max_lambda_phase
  init_number sd_offset

 LOCAL_CALCS
  echoinput<<max_lambda_phase<<" max_lambda_phase "<<endl;
  echoinput<<sd_offset<<" sd_offset (adds log(s)) "<<endl;
  if(sd_offset==0)
  {
    N_warn++; warning<<" With sd_offset set to 0, be sure you are not estimating any variance parameters "<<endl;
  }
  if(depletion_fleet>0 && max_lambda_phase<2)
    {
      max_lambda_phase=2;
      N_warn++; warning<<"Increase max_lambda_phase to 2 because depletion fleet is being used"<<endl;
    }
 END_CALCS

!!//  SS_Label_Info_4.11.1 #Define type_phase arrays for lambdas
  matrix surv_lambda(1,Nfleet,1,max_lambda_phase)
  matrix disc_lambda(1,Nfleet,1,max_lambda_phase)
  matrix mnwt_lambda(1,Nfleet,1,max_lambda_phase)
  matrix length_lambda(1,Nfleet,1,max_lambda_phase)
  matrix age_lambda(1,Nfleet,1,max_lambda_phase)
  matrix sizeage_lambda(1,Nfleet,1,max_lambda_phase)
  vector init_equ_lambda(1,max_lambda_phase)
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
  init_int N_lambda_changes
  init_matrix Lambda_changes(1,N_lambda_changes,1,5)
  int N_changed_lambdas
 LOCAL_CALCS
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
   regime_lambda=1.; // 18

    if(depletion_fleet>0)
    {
      for (f=1;f<=Nfleet;f++)
      {
        surv_lambda(f,1)=0.0;
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
      init_equ_lambda(1)=0.0;
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
          warning<<" illegal fleet/survey for lambda change at row: "<<j<<" fleet: "<<f<<" > Nfleet"<<endl;
        }
      }
      else if(k<=16)  // tag data
      {
        if(f>N_TG2)
        {
          k=0;
          N_warn++;
          warning<<" illegal tag group for lambda change at row: "<<j<<" Tag: "<<f<<" > N_taggroups"<<endl;
        }
      }
      else if(k>17)
      {
        k=0;
        N_warn++;
        warning<<" illegal lambda_type for lambda change at row: "<<j<<" Method: "<<k<<" > 17"<<endl;
      }
      if(s>max_lambda_phase)
      {k=0; N_warn++;  warning<<" illegal request for lambda change at row: "<<j<<" phase: "<<s<<" > max_lam_phase: "<<max_lambda_phase<<endl;}
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
          if(z>SzFreq_Nmeth) {N_warn++; cout<<" EXIT - see warning "<<endl; warning<<" reading sizefreq lambda change for method > Nmeth "<<Lambda_changes(j,5)<<endl; exit(1);}
          SzFreq_lambda(SzFreq_LikeComponent(f,z))(s,max_lambda_phase) = temp;
          break;
        }
        case 7:  // size-at-age
          {sizeage_lambda(f)(s,max_lambda_phase)=temp; break;}
        case 8:  // catch
          {catch_lambda(f)(s,max_lambda_phase)=temp; break;}
        case 9:  // init_equ_catch
          {init_equ_lambda(s,max_lambda_phase)=temp; break;}
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
  init_int Do_More_Std
  init_ivector More_Std_Input(1,Do_More_Std*9)
 LOCAL_CALCS
  echoinput<<Do_More_Std<<" # (0/1) read specs for more stddev reporting "<<endl;
  if(Do_More_Std>0)
  {echoinput<<More_Std_Input<<" # vector with selex type, len/age, year, N selex bins, Growth pattern, N growth ages, N_at_age_Area, NatAge_yr, Natage_ages"<<endl;}
  else
  {echoinput<<" # placeholder vector with selex type, len/age, year, N selex bins, Growth pattern, N growth ages"<<endl;}
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
  int Extra_Std_N;   //  dimension for the sdreport vector Selex_Std which also contains the Growth_Std

 LOCAL_CALCS
   if(Do_More_Std==1)
   {
     Do_Selex_Std=More_Std_Input(1);
     Selex_Std_AL=More_Std_Input(2);
     Selex_Std_Year=More_Std_Input(3);
     if(Selex_Std_Year<0) Selex_Std_Year=endyr;
     Selex_Std_Cnt=More_Std_Input(4);
     Do_Growth_Std=More_Std_Input(5);
     if(MG_active(2)==0) Do_Growth_Std=0;
     Growth_Std_Cnt=More_Std_Input(6);
     Do_NatAge_Std=More_Std_Input(7);
     NatAge_Std_Year=More_Std_Input(8);
     if(NatAge_Std_Year<0) NatAge_Std_Year=endyr+1;
     NatAge_Std_Cnt=More_Std_Input(9);
   }
   else
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
   }
 END_CALCS

  init_ivector Selex_Std_Pick(1,Selex_Std_Cnt);
  init_ivector Growth_Std_Pick(1,Growth_Std_Cnt);
  init_ivector NatAge_Std_Pick(1,NatAge_Std_Cnt);

 LOCAL_CALCS
  if(Selex_Std_Cnt>0) echoinput<<Selex_Std_Pick<<" # vector with selex std bin picks (-1 in first bin to self-generate)"<<endl;
  if(Growth_Std_Cnt>0) echoinput<<Growth_Std_Pick<<" # vector with growth std bin picks (-1 in first bin to self-generate)"<<endl;
  if(NatAge_Std_Cnt>0) echoinput<<NatAge_Std_Pick<<" # vector with NatAge std bin picks (-1 in first bin to self-generate)"<<endl;

// reset the counter here after using it to dimension the input statement above
  if(Do_Selex_Std<=0) Selex_Std_Cnt=0;
  if(Do_Growth_Std<=0) Growth_Std_Cnt=0;
  if(Do_NatAge_Std<=0) NatAge_Std_Cnt=0;

  Extra_Std_N=0;
  if(Do_Selex_Std>0)
  {
    if(Selex_Std_Pick(1)<=0)  //  then self-generate even bin selection
    {
      if(Selex_Std_AL==1)
      {
        j=nlength/(Selex_Std_Cnt-1);
        Selex_Std_Pick(1)=j/2;
        for (i=2;i<=Selex_Std_Cnt-1;i++) Selex_Std_Pick(i)=Selex_Std_Pick(i-1)+j;
        Selex_Std_Pick(Selex_Std_Cnt)=nlength;
      }
      else
      {
        j=nages/(Selex_Std_Cnt-1);
        Selex_Std_Pick(1)=j/2;
        for (i=2;i<=Selex_Std_Cnt-1;i++) Selex_Std_Pick(i)=Selex_Std_Pick(i-1)+j;
        Selex_Std_Pick(Selex_Std_Cnt)=nages;
      }
    }
    Extra_Std_N=gender*Selex_Std_Cnt;
  }

  if(Do_Growth_Std>0)
  {
    if(Growth_Std_Pick(1)<=0)
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
  }
  Extra_Std_N+=gender*Growth_Std_Cnt;

  if(Do_NatAge_Std!=0)
  {
    if(NatAge_Std_Pick(1)<=0)
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
  }
  Extra_Std_N+=gender*NatAge_Std_Cnt;
  Extra_Std_N+=3;

  if(Selex_Std_Cnt>0) echoinput<<Selex_Std_Pick<<" # vector with selex std bin picks (-1 in first bin to self-generate)"<<endl;
  if(Growth_Std_Cnt>0) echoinput<<Growth_Std_Pick<<" # vector with growth std bin picks (-1 in first bin to self-generate)"<<endl;
  if(NatAge_Std_Cnt>0) echoinput<<NatAge_Std_Pick<<" # vector with NatAge std bin picks (-1 in first bin to self-generate)"<<endl;

 END_CALCS

!!//  SS_Label_Info_4.13 #End of reading from control file
  init_int fim // end of file indicator

 LOCAL_CALCS
  cout<<"If you see 999, we got to the end of the control file successfully! "<<fim<<endl;
  echoinput<<fim<<"  If you see 999, we got to the end of the control file successfully! "<<endl;
  if(fim!=999) abort();
 END_CALCS

!!//  SS_Label_Info_4.14 #Create count of active parameters and derived quantities
  int CoVar_Count;
  int active_count;    // count the active parameters
  int active_parms;    // count the active parameters
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
  k=ParCount+2*N_STD_Yr+N_STD_Yr_Dep+N_STD_Yr_Ofish+N_STD_Yr_F+N_STD_Mgmt_Quant+Extra_Std_N;
  echoinput<<"N parameters: "<<ParCount<<endl<<"Parameters plus derived quant: "<<k<<endl;
 END_CALCS
  ivector active_parm(1,k)  //  pointer from active list to the element of the full parameter list to get label later

//***********************************************
!!//  SS_Label_Info_4.14.1 #Adjust the phases to negative if beyond turn_off_phase and find resultant max_phase
  int max_phase;

 LOCAL_CALCS
  echoinput<<"Adjust the phases and count the number of active parameters"<<endl;
  max_phase=1;
  active_count=0;
  active_parm(1,ParCount)=0;
  ParCount=0;

  j=MGparm_PH.indexmax();

  for (k=1;k<=j;k++)
  {
    ParCount++;
    if(MGparm_PH(k)==-9999) {MGparm_RD(k)=prof_var(prof_var_cnt); prof_var_cnt+=1;}
    if(depletion_fleet>0 && MGparm_PH(k)>0) MGparm_PH(k)++;  //  add 1 to phase if using depletion fleet
    if(MGparm_PH(k) > Turn_off_phase) MGparm_PH(k) =-1;
    if(MGparm_PH(k) > max_phase) max_phase=MGparm_PH(k);
    if(MGparm_PH(k)>=0)
    {
      active_count++; active_parm(active_count)=ParCount;
    }
  }

  for (j=1;j<=SR_parm_PH.indexmax();j++)
  {
    ParCount++;
    if(SR_parm_PH(j)==-9999) {SR_parm_1(j,3)=prof_var(prof_var_cnt); prof_var_cnt+=1;}
    if(depletion_fleet>0 && SR_parm_PH(j)>0) SR_parm_PH(j)++;  //  add 1 to phase if using depletion fleet
    if(depletion_fleet>0 && j==1) SR_parm_PH(1)=1;  //
    if(SR_parm_PH(j) > Turn_off_phase) SR_parm_PH(j) =-1;
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
      temp=recdev_cycle_parm_RD(y,5);  //  PRtype in 3.24
      if(temp==0) temp=6;
      if(temp<0) temp=0;
      recdev_cycle_parm_RD(y,5)=recdev_cycle_parm_RD(y,6);
      recdev_cycle_parm_RD(y,6)=temp;
      recdev_cycle_PH(y)=recdev_cycle_parm_RD(y,7);
      if(depletion_fleet>0 && recdev_cycle_PH(y)>0) recdev_cycle_PH(y)++;  //  add 1 to phase if using depletion fleet
      if(recdev_cycle_PH(y) > Turn_off_phase) recdev_cycle_PH(y) =-1;
      if(recdev_cycle_PH(y) > max_phase) max_phase=recdev_cycle_PH(y);
      if(recdev_cycle_PH(y)>=0) {active_count++; active_parm(active_count)=ParCount;}
    }
  }

  if(depletion_fleet>0 && recdev_early_PH_rd>0) recdev_early_PH_rd++;  //  add 1 to phase if using depletion fleet
  if(recdev_early_PH_rd > Turn_off_phase)
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

  if(depletion_fleet>0 && recdev_PH>0) recdev_PH++;  //  add 1 to phase if using depletion fleet
  if(recdev_PH > Turn_off_phase) recdev_PH =-1;
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
        if(depletion_fleet>0 && Fcast_recr_PH2>0) Fcast_recr_PH2++;
        if(Fcast_recr_PH2 > Turn_off_phase) Fcast_recr_PH2 =-1;
        if(Fcast_recr_PH2 > max_phase) max_phase=Fcast_recr_PH2;
      }
      for (y=recdev_end+1;y<=YrMax;y++)
      {
        ParCount++;
        if(Fcast_recr_PH2>-1) {active_count++; active_parm(active_count)=ParCount;}
      }
    }
    else
      {
        Fcast_recr_PH2=-1;
      }

    for (y=endyr+1;y<=YrMax;y++)
    {
      ParCount++;
      if(Do_Impl_Error>0 && Fcast_recr_PH2>-1)
      {active_count++; active_parm(active_count)=ParCount;}
    }
  }
  else
  {Fcast_recr_PH2=-1;}

  for (s=1;s<=nseas;s++)
  for (f=1;f<=Nfleet;f++)
  {
    if(init_F_loc(s,f)>0)
    {
      j=init_F_loc(s,f);
      ParCount++;
      if(init_F_PH(j)==-9999) {init_F_parm_1(j,3)=prof_var(prof_var_cnt); init_F_RD(j)=init_F_parm_1(j,3);  prof_var_cnt++;}
      if(depletion_fleet>0 && init_F_PH(j)>0) init_F_PH(j)++;
      if(init_F_PH(j) > Turn_off_phase) init_F_PH(j) =-1;
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
      if(depletion_fleet>0 && Fparm_PH(g)>0) Fparm_PH(g)++;  //  increase phase by 1
      if(Fparm_PH(g) > Turn_off_phase) Fparm_PH(g) =-1;
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
    if(Q_parm_PH(f)==-9999) {Q_parm_1(f,3)=prof_var(prof_var_cnt); prof_var_cnt++;}
    if(depletion_fleet>0 && Q_parm_PH(f)>0) Q_parm_PH(f)++;
    if(Q_parm_PH(f) > Turn_off_phase) Q_parm_PH(f) =-1;
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
    if(seltype(f,1)==27)  //  reset the cubic spline knots for size or age comp
    {
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
          N_warn++; cout<<" EXIT - see warning "<<endl; warning<<"must have at least 3 knots in spline "<<endl;  exit(1);
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
        echoinput<<"Do complete setup of lo, hi, prior, etc. for fleet: "<<f<<endl;
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
          selparm_PRtype(p)=1;  // SYMMETRIC BETA
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
          echoinput<<"saving adjusted cubic spline setup"<<endl;
          for (z=Ip+1;z<=Ip+3+2*N_knots;z++)
          {
            selparm_1(z,1)=selparm_LO(z);
            selparm_1(z,2)=selparm_HI(z);
            selparm_1(z,3)=selparm_RD(z);
            selparm_1(z,4)=selparm_PR(z);
            selparm_1(z,5)=selparm_CV(z);
            selparm_1(z,6)=selparm_PRtype(z);
            selparm_1(z,7)=selparm_PH(z);
            echoinput<<z<<" selparm "<<selparm_1(z)(1,7)<<endl;
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
     if(selparm_PH(k)==-9999) {selparm_RD(k)=prof_var(prof_var_cnt); prof_var_cnt++;}
     if(depletion_fleet>0 && selparm_PH(k)>0) selparm_PH(k)++;
     if(selparm_PH(k) > Turn_off_phase) selparm_PH(k) =-1;
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
      if(depletion_fleet>0 && TG_parm_PH(k)>0) TG_parm_PH(k)++;
      if(TG_parm_PH(k) > Turn_off_phase) TG_parm_PH(k) =-1;
      if(TG_parm_PH(k) > max_phase) max_phase=TG_parm_PH(k);
      if(TG_parm_PH(k)>=0)
      {
      active_count++; active_parm(active_count)=ParCount;
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

  echoinput<<"ParCount "<<ParCount<<"   Active parameters: "<<active_count<<endl<<"Turn_off_phase "<<Turn_off_phase<<endl<<" max_phase "<<max_phase<<endl;
  echoinput<<active_parm.indexmax()<<endl;

  if(Do_Forecast>0 && Turn_off_phase>0)
  {
    if(Fcast_recr_PH==0)  // read value for forecast_PH.  This code is repeats earlier code in case other parameters have changed maxphase
    {
      Fcast_recr_PH2=max_phase+1;
    }
  }

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

//  create labels for Mgmt_Quant
  if(Do_Benchmark>0)
    {
      ParmLabel+="SSB_Unfished"+CRLF(1); CoVar_Count++; j++; active_parm(CoVar_Count)=j;
      ParmLabel+="TotBio_Unfished"+CRLF(1); CoVar_Count++; j++; active_parm(CoVar_Count)=j;
      ParmLabel+="SmryBio_Unfished"+CRLF(1); CoVar_Count++; j++; active_parm(CoVar_Count)=j;
      ParmLabel+="Recr_Unfished"+CRLF(1); CoVar_Count++; j++; active_parm(CoVar_Count)=j;
      ParmLabel+="SSB_Btgt"+CRLF(1); CoVar_Count++; j++; active_parm(CoVar_Count)=j;
      ParmLabel+="SPR_Btgt"+CRLF(1); CoVar_Count++; j++; active_parm(CoVar_Count)=j;
      ParmLabel+="Fstd_Btgt"+CRLF(1); CoVar_Count++; j++; active_parm(CoVar_Count)=j;
      ParmLabel+="Dead_Catch_Btgt"+CRLF(1); CoVar_Count++; j++; active_parm(CoVar_Count)=j;
      ParmLabel+="SSB_SPRtgt"+CRLF(1); CoVar_Count++; j++; active_parm(CoVar_Count)=j;
      ParmLabel+="Fstd_SPRtgt"+CRLF(1); CoVar_Count++; j++; active_parm(CoVar_Count)=j;
      ParmLabel+="Dead_Catch_SPRtgt"+CRLF(1); CoVar_Count++; j++; active_parm(CoVar_Count)=j;
      ParmLabel+="SSB_MSY"+CRLF(1); CoVar_Count++; j++; active_parm(CoVar_Count)=j;
      ParmLabel+="SPR_MSY"+CRLF(1); CoVar_Count++; j++; active_parm(CoVar_Count)=j;
      ParmLabel+="Fstd_MSY"+CRLF(1); CoVar_Count++; j++; active_parm(CoVar_Count)=j;
      ParmLabel+="Dead_Catch_MSY"+CRLF(1); CoVar_Count++; j++; active_parm(CoVar_Count)=j;
      ParmLabel+="Retain_Catch_MSY"+CRLF(1); CoVar_Count++; j++; active_parm(CoVar_Count)=j;
      ParmLabel+="B_MSY/SSB_unfished"+CRLF(1); CoVar_Count++; j++; active_parm(CoVar_Count)=j;
    }
    else
    {
      ParmLabel+="Bzero_again"+CRLF(1); CoVar_Count++; j++; active_parm(CoVar_Count)=j;
    }

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

// do labels for Selex_Std
    if(Do_Selex_Std>0)
    {
      for (g=1;g<=gender;g++)
      for (i=1;i<=Selex_Std_Cnt;i++)
      {
        CoVar_Count++; j++; active_parm(CoVar_Count)=j;
        if(Selex_Std_AL==1)
        {
          if(Selex_Std_Pick(i)>nlength)
          {
            N_warn++; cout<<" EXIT - see warning "<<endl; warning<<" cannot select stdev for length bin greater than nlength "<<Selex_Std_Pick(i)<<" > "<<nlength<<endl; exit(1);
          }
          ParmLabel+="Selex_std_"+NumLbl(Do_Selex_Std)+"_"+GenderLbl(g)+"_L_"+NumLbl(len_bins(Selex_Std_Pick(i)))+CRLF(1);
        }
        else
        {
          if(Selex_Std_Pick(i)>nages)
          {
            N_warn++; cout<<" EXIT - see warning "<<endl; warning<<" cannot select stdev for age bin greater than maxage "<<Selex_Std_Pick(i)<<" > "<<nages<<endl; exit(1);
          }
          ParmLabel+="Selex_std_"+NumLbl(Do_Selex_Std)+"_"+GenderLbl(g)+"_A_"+NumLbl(age_vector(Selex_Std_Pick(i)))+CRLF(1);
        }
      }
    }
    if(Do_Growth_Std>0)
    {
      for (g=1;g<=gender;g++)
      for (i=1;i<=Growth_Std_Cnt;i++)
      {
        CoVar_Count++; j++; active_parm(CoVar_Count)=j;
        ParmLabel+="Grow_std_"+NumLbl(Do_Growth_Std)+"_"+GenderLbl(g)+"_A_"+NumLbl(age_vector(Growth_Std_Pick(i)))+CRLF(1);
      }
    }
  echoinput<<CoVar_Count<<endl;
    if(Do_NatAge_Std!=0)
    {
      for (g=1;g<=gender;g++)
      for (i=1;i<=NatAge_Std_Cnt;i++)
      {
        CoVar_Count++; j++; active_parm(CoVar_Count)=j;
        if(Do_NatAge_Std>0)
        {ParmLabel+="NatAge_std_"+NumLbl(Do_NatAge_Std)+"_"+GenderLbl(g)+"_A_"+NumLbl(age_vector(NatAge_Std_Pick(i)))+CRLF(1);}
        else
        {ParmLabel+="NatAge_std_All_"+GenderLbl(g)+"_A_"+NumLbl(age_vector(NatAge_Std_Pick(i)))+CRLF(1);}
      }
    }

//  output ln(Spbio) for selected years
    CoVar_Count++; j++; active_parm(CoVar_Count)=j;
    sprintf(onenum, "%d", styr);
    ParmLabel+="ln(SPB)_"+onenum+CRLF(1);
    CoVar_Count++; j++; active_parm(CoVar_Count)=j;
    sprintf(onenum, "%d", int((endyr+styr)/2));
    ParmLabel+="ln(SPB)_"+onenum+CRLF(1);
    CoVar_Count++; j++; active_parm(CoVar_Count)=j;
    sprintf(onenum, "%d", endyr);
    ParmLabel+="ln(SPB)_"+onenum+CRLF(1);

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
  echoinput<<"Active parameters plus derived quantities:  "<<CoVar_Count<<endl;
 END_CALCS

//  containers for parameter values after jitter
    vector MGparm_use(1,N_MGparm2)
    vector SR_parm_use(1,N_SRparm2);
    vector recdev_cycle_use(1,recdev_cycle);
    vector recdev_use(recdev_first,YrMax);
    vector recdev_RD(recdev_first,YrMax);
    vector impl_error_use(endyr+1,YrMax);
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
 LOCAL_CALCS
   if(WTage_rd>0)
   {
     ad_comm::change_datafile_name("wtatage.ss");
     k1=2;
   }
   else
   {
    k1=0;
    N_WTage_rd=0;
    N_WTage_maxage=0;
   }
 END_CALCS

  init_vector junkvec(1,k1)
 LOCAL_CALCS
  if(k1>0)
  {
    echoinput<<"WT-at-age input"<<junkvec<<endl;
    N_WTage_rd=junkvec(1);
    N_WTage_maxage=junkvec(2);
    k2=TimeMax_Fcast_std+1;
  }
  else
  {
    k2=styr;
    N_WTage_maxage=nages;
  }

 END_CALCS
  init_matrix WTage_in(1,N_WTage_rd,1,7+N_WTage_maxage)
  vector junkvec2(0,nages)
  4darray WTage_emp(styr-3*nseas,k2,1,gender*N_GP*nseas,-2,Nfleet,0,nages)  //  set to begin period for pop (type=0), or mid period for fleet/survey
// read:  yr, seas, gender, morph, settlement, fleet, <age vec> where first value is for age 0!
// if yr=-yr, then fill remaining years for that seas, growpattern, gender, fleet
// fleet 0 contains begin season pop WT
// fleet -1 contains mid season pop WT
// fleet -2 contains maturity*fecundity

 LOCAL_CALCS
  if(k1>0)
  {
    echoinput<<"Wt_age input"<<endl<<WTage_in<<endl<<"end"<<endl;
    WTage_emp.initialize();
    if(N_WTage_maxage>nages) N_WTage_maxage=nages;  //  so extra ages being read will be ignored
    for (i=1;i<=N_WTage_rd;i++)
    {
      y=abs(WTage_in(i,1));
      if(y<styr) y=styr;
      if(WTage_in(i,1)<0) {y2=YrMax;} else {y2=y;}
      s=WTage_in(i,2);
      gg=WTage_in(i,3);
      gp=WTage_in(i,4);
      birthseas=WTage_in(i,5);
      g=(gg-1)*N_GP*nseas + (gp-1)*nseas + birthseas;
      f=WTage_in(i,6);
      if(s<=nseas && gg<=gender && gp<=N_GP && birthseas<=nseas && f<=Nfleet)
      {
        for (j=y;j<=y2;j++)  // loop years
        {
          t=styr+(j-styr)*nseas+s-1;
          for (a=0;a<=N_WTage_maxage;a++) WTage_emp(t,g,f,a)=WTage_in(i,7+a);
          for (a=N_WTage_maxage;a<=nages;a++) WTage_emp(t,g,f,a)=WTage_emp(t,g,f,N_WTage_maxage);  //  fills out remaining ages, if any
          if(j==y) echoinput<<y<<" s "<<s<<" sex "<<gg<<" gp "<<gp<<" bs "<<birthseas<<" morph "<<g<<" pop/fleet "<<f<<" "<<WTage_emp(t,g,f)(0,min(6,nages))<<endl;
        }
      }
      temp=float(Bmark_Yr(2)-Bmark_Yr(1)+1.);  //  get denominator
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
    }
  }

  if (N_nudata < 1) N_nudata=1; // output the new version of the DAT file

 END_CALCS
