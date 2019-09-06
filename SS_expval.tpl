//********************************************************************
 /*  SS_Label_FUNCTION 46  Get_expected_values:  check for data */
FUNCTION void Get_expected_values();
  {
    dvariable temp1;
    dvar_vector age_exp(0,nages2);
  for (subseas=1;subseas<=N_subseas;subseas++)
  {
//  make age-length key if needed
    ALK_idx=(s-1)*N_subseas+subseas;
    ALK_time=(y-styr)*nseas*N_subseas+(s-1)*N_subseas+subseas;
    if(ALK_subseas_update(ALK_idx)==1 || have_data(ALK_time,0,0,0)>0)  //  need ALK update for growth reasons or for data reasons
    {
      get_growth3(s, subseas);
      Make_AgeLength_Key(s, subseas);
    }
    for (f=1;f<=Nfleet;f++)
    {
      if(have_data(ALK_time,f,0,0)>0)
      {
        p=fleet_area(f);
        timing=data_time(ALK_time,f,2)*seasdur(s);  // within season elapsed time  same for all datatypes of this fleet x time
//  make selected age-length sample for this fleet and with this timing
        {
          exp_AL.initialize();
          exp_AL_ret.initialize();
          for (g=1;g<=gmorph;g++)
          if(use_morph(g)>0)
          {
            int ALK_finder=(ALK_idx-1)*gmorph+g;
            ivector ALK_range_lo=ALK_range_g_lo(ALK_finder);
            ivector ALK_range_hi=ALK_range_g_hi(ALK_finder);

            gg=sx(g);
            if(gg==2)
            { L1=nlength1; L2= nlength2; A2=nages+1;}    //  move over on length dimension to store males
            else
            { L1=1; L2=nlength; A2=0;}

 /*
            if(F_Method==1 && surveytime(f)<0.0) //  Pope's approximation
            {tempvec_a=elem_prod(Nmid(g),sel_a(y,f,gg));}  //  CHECK   Nmid may not exist correctly unless still within the area loop
            else if(surveytime(f)<0.0) // mimic fishery catch, but without Hrate so gets available numbers
            {tempvec_a=elem_prod(natage(t,p,g),elem_prod(Zrate2(p,g),sel_a(y,f,gg)));}
            else  //  explicit timing
            {tempvec_a=elem_prod(natage(t,p,g),elem_prod(mfexp(-Z_rate(t,p,g)*timing),sel_a(y,f,gg)));}
 */
            if(timing>=0.0) 
            {tempvec_a=elem_prod(natage(t,p,g),elem_prod(mfexp(-Z_rate(t,p,g)*timing),sel_a(y,f,gg)));}  //  explicit timing
            else
            {
              if(F_Method>1) // mimic fishery catch,  so gets mean available numbers
              {tempvec_a=elem_prod(natage(t,p,g),elem_prod(Zrate2(p,g),sel_a(y,f,gg)));}
              else    //  Pope's approximation
              {
                Nmid(g) = elem_prod(natage(t,p,g),surv1(s,GP3(g)));      //   numbers-at-age(g,a) surviving to middle of time period
                tempvec_a=elem_prod(Nmid(g),sel_a(y,f,gg));
              }
            }
            tempvec_a=elem_prod(tempvec_a,keep_age(g,ALK_idx));
            
            int retflag;
            retflag=0;
            if(Do_Retain(f)==0)
            {
              if(dolen(f)==1)
              {
                for (a=0;a<=nages;a++)
                {
                  temp=tempvec_a(a);
                  for(z=ALK_range_lo(a);z<=ALK_range_hi(a);z++)
                  {
                    exp_AL(a+A2,L1-1+z)+=temp*ALK(ALK_idx,g,a,z)*sel_l(y,f,gg,z);;  //  note that A2 and L1 depend on what sex g is
                  }
                }
              }
              else
              {
                for (a=0;a<=nages;a++)
                {
                  temp=tempvec_a(a);
                  for(z=ALK_range_lo(a);z<=ALK_range_hi(a);z++)
                  {
                    exp_AL(a+A2,L1-1+z)+=temp*ALK(ALK_idx,g,a,z);
                  }
                }
              }
              exp_AL_ret=exp_AL;  //  in case user has retain code 2 rather than 0
            }
            else  //  need retain matrix
            {
              if(dolen(f)==1)  //  need retention and length
              {
                for (a=0;a<=nages;a++)
                {
                  temp=tempvec_a(a);
                  temp1=tempvec_a(a)*retain_a(y,f,gg,a);
                  for(z=ALK_range_lo(a);z<=ALK_range_hi(a);z++)
                  {
                    exp_AL(a+A2,L1-1+z)+=temp*ALK(ALK_idx,g,a,z)*sel_l(y,f,gg,z);  //  note that A2 and L1 depend on what sex g is
                    exp_AL_ret(a+A2,L1-1+z)+=temp1*ALK(ALK_idx,g,a,z)*sel_l(y,f,gg,z)*retain(y,f,L1-1+z);  //  note that A2 and L1 depend on what sex g is
                  }
                }
              }
              else  //  need retention, but no length selex
              {
                for (a=0;a<=nages;a++)
                {
                  temp=tempvec_a(a);
                  temp1=tempvec_a(a)*retain_a(y,f,gg,a);
                  for(z=ALK_range_lo(a);z<=ALK_range_hi(a);z++)
                  {
                    exp_AL(a+A2,L1-1+z)+=temp*ALK(ALK_idx,g,a,z);
                    exp_AL_ret(a+A2,L1-1+z)+=temp1*ALK(ALK_idx,g,a,z)*retain(y,f,L1-1+z);
                  }
                }
              }
            }

//  code below once erroneously built up catch by morph from exp_AL
//  that approach is incorrect, because exp_AL already accumulates the morphs!!!!!
//  putting a morph accumulation into the code above would slow computations for everyone in order to have this rarely used feature
//  so instead, replicate the above to store directly into morphcomp_exp, rather than into the exp_AL matrix
//  note that partition is read with morphcomp data, but it is not used
//  fleets with no defined retention function base morphcomp off total catch
//  fleets with retention defined, use retained catch
            if(have_data(ALK_time,f,8,0)>0)  //  morphcomp observation
              {
              	int j=have_data(ALK_time,f,8,1);  //  observation number
//             	{Morphcomp_exp(j,5+GP4(g))+=sum(exp_AL);

                if(Do_Retain(f)==0)
                {
                  if(dolen(f)==1)  //  uses length selectivity
                  {
                    for (a=0;a<=nages;a++)
                    {
                      temp=tempvec_a(a);
                      for(z=ALK_range_lo(a);z<=ALK_range_hi(a);z++)
                      {
                        Morphcomp_exp(j,5+GP4(g))+=temp*ALK(ALK_idx,g,a,z)*sel_l(y,f,gg,z);;  //  note that A2 and L1 depend on what sex g is
                      }
                    }
                  }
                  else
                  {
                    for (a=0;a<=nages;a++)
                    {
                      temp=tempvec_a(a);
                      for(z=ALK_range_lo(a);z<=ALK_range_hi(a);z++)
                      {
                        Morphcomp_exp(j,5+GP4(g))+=temp*ALK(ALK_idx,g,a,z);
                      }
                    }
                  }
                }
                else  //  must base sample on retained catch from a fleet that has retention defined
                {
                  if(dolen(f)==1)  //  need retention and length
                  {
                    for (a=0;a<=nages;a++)
                    {
                      temp=tempvec_a(a);
                      temp1=tempvec_a(a)*retain_a(y,f,gg,a);
                      for(z=ALK_range_lo(a);z<=ALK_range_hi(a);z++)
                      {
                        Morphcomp_exp(j,5+GP4(g)) +=temp1*ALK(ALK_idx,g,a,z)*sel_l(y,f,gg,z)*retain(y,f,L1-1+z);  //  note that A2 and L1 depend on what sex g is
                      }
                    }
                  }
                  else  //  need retention, but no length selex
                  {
                    for (a=0;a<=nages;a++)
                    {
                      temp=tempvec_a(a);
                      temp1=tempvec_a(a)*retain_a(y,f,gg,a);
                      for(z=ALK_range_lo(a);z<=ALK_range_hi(a);z++)
                      {
                        Morphcomp_exp(j,5+GP4(g))+=temp1*ALK(ALK_idx,g,a,z)*retain(y,f,L1-1+z);
                      }
                    }
                  }
                }
                if(g==gmorph) 
               	{
                  k=5+Morphcomp_nmorph;
                  Morphcomp_exp(j)(6,k) /= sum(Morphcomp_exp(j)(6,k));
                  Morphcomp_exp(j)(6,k) += Morphcomp_mincomp;
                  Morphcomp_exp(j)(6,k) /= 1.+Morphcomp_mincomp*Morphcomp_nmorph;
               	}
              }
          } //close gmorph loop

          exp_l_temp=colsum(exp_AL);  //  total size composition
          agetemp=rowsum(exp_AL);  //  total age composition
 #ifdef DO_ONCE
          if(do_once==1) echoinput<<"yr "<<y<<", seas: "<<s<<", fleet:"<<f<<endl<<
            " sampled  size "<<exp_l_temp<<endl<<
            " sampled  age  "<<agetemp<<endl;
 #endif
          if(Do_Retain(f)>0)
          {
            exp_l_temp_ret=colsum(exp_AL_ret);
            exp_truea_ret=rowsum(exp_AL_ret);
 #ifdef DO_ONCE
            if(do_once==1) echoinput<<" retained size "<<exp_l_temp_ret<<endl<<" retained age "<<exp_truea_ret<<endl;;
 #endif
          }
          else
          {
            exp_truea_ret=agetemp;  //  covers cases where retention not used, but observations have partition=2
            exp_l_temp_ret=exp_l_temp;
          }

//          end creation of selected A-L
        }

        if(sum(exp_l_temp)<1.0e-8)
          {
            if(do_once==1) {N_warn++; warning<<"warn just once for:  Observation exists, but nil selected fish for year, seas, fleet "<<y<<" "<<s<<" "<<f<<endl;}
            exp_l_temp+=1.0e-05;
          }

        for (data_type=1;data_type<=9;data_type++)
        {
          switch(data_type)
          {
            case(1):  //  surveyindex
            {
   /* SS_Label_46.1 expected abundance index */
  // NOTE that the Q scaler is factored in later on
              j=have_data(ALK_time,f,data_type,0);  //  number of observations for this time,f,type
              if(j>0)
              {
                j=have_data(ALK_time,f,data_type,1);  //  for now, only one observations is allowed for surveys
                switch(Svy_units(f))
                {
                  case 1:  //  biomass
                  {
                    if(WTage_rd==1)  //  using empirical wt-at-age;  note that this cannot use GP specific bodyweights
                    {
                      vbio=0.0;
                      if(Do_Retain(f)==0)  //  all retained
                      {
                       for (a=0;a<=nages;a++) vbio+=WTage_emp(y,1,f,a)*agetemp(a);
                       if(gender==2)
                       {
                        for (a=0;a<=nages;a++) vbio+=WTage_emp(y,2,f,a)*agetemp(a+nages+1);
                       }
                      }
                      else
                      {
                       for (a=0;a<=nages;a++) vbio+=WTage_emp(y,1,f,a)*exp_truea_ret(a);
                       if(gender==2)
                       {
                        for (a=0;a<=nages;a++) vbio+=WTage_emp(y,2,f,a)*exp_truea_ret(a+nages+1);
                       }
                      }
                    }
                    else
                    {
                     if(Do_Retain(f)==0)
                     {
                       vbio=exp_l_temp*wt_len2(s,1);// biomass  TEMPORARY CODE.  Using gp=1 wt at length
                     }
                     else
                     {
                       vbio=exp_l_temp_ret*wt_len2(s,1);
                     }
                    }
                    break;
                  }
                  case 0:  //  numbers
                  {
                    if(Do_Retain(f)==0)
                    {
                      vbio=sum(exp_l_temp);
                    }
                    else
                    {
                      vbio=sum(exp_l_temp_ret);
                    }
                    break;
                  }
                  case 2:   //  F rate
                  {
                   vbio=Hrate(f,t);
                   break;
                  }
                  case 30:  // spawning biomass  #30
                  {
                    if(pop==1 || fleet_area(f)==0)
                    {
                      vbio=SSB_current;
                     }
                     else
                     {
                       vbio=sum(SSB_pop_gp(y,fleet_area(f)));
                     }
                    break;
                  }
                  case 31:  // recruitment deviation  #31
                  {
                   if(y>=recdev_start && y<=recdev_end)
                   {vbio=mfexp(recdev(y));}
                   else
                   {vbio=1.0;}
                   break;
                  }
                  case 32:  // recruitment without density-dependence (for pre-recruit survey) #32
                  {
                   if(y>=recdev_start && y<=recdev_end)
                   {vbio=SSB_current*mfexp(recdev(y));}
                   else
                   {vbio=SSB_current;}
                   break;
                  }
                  case 33:  // recruitment  #33
                  {vbio=Recruits; break;}

                  case 34:  // spawning biomass depletion
                  {
                    if(pop==1 || fleet_area(f)==0)
                    {
                      vbio=(SSB_current+1.0e-06)/(SSB_virgin+1.0e-06);
                     }
                     else
                     {
                       vbio=(sum(SSB_pop_gp(y,fleet_area(f)))+1.0e-06)/(SSB_virgin+1.0e-06);
                     }
                    break;
                  }
                  case 35:  // parm deviation  #35
                  {
                     k=Q_setup(f,2);  //  specify which parameter's time-vary vector will be compared to this survey

                     if(y>=parm_dev_minyr(k) && y<=parm_dev_maxyr(k))
                     {
                       vbio=parm_dev(k,y);
                     //  can the mean dev for years with surveys be calculated here?
                     }
                     else
                     {vbio=0.0;}
                     break;
                  }
                }
                Svy_selec_abund(f,j)=value(vbio);

     //  get catchability
               if(Q_setup(f,1)==2)        // mirror Q from lower numbered survey
               {
                 Svy_log_q(f,j) = Svy_log_q(Q_setup(f,2),1);
                 Q_parm(Q_setup_parms(f,1))=Svy_log_q(f,1);    // base Q  So this sets parameter equal to the scaling coefficient and can then have a prior
               }
               else if(Q_setup(f,1)==4)
               {
                 Svy_log_q(f,j) = Svy_log_q(Q_setup(f,2),1)+Q_parm(Q_setup_parms(f,1)+1);
                 Q_parm(Q_setup_parms(f,1))=Svy_log_q(f,1);    // base Q  So this sets parameter equal to the scaling coefficient and can then have a prior
               }

               else   //  Q from parameter
               {
                 if(Qparm_timevary(Q_setup_parms(f,1))==0) //  not time-varying
                 {
                   Svy_log_q(f,j)=Q_parm(Q_setup_parms(f,1));  //  set to base parameter value
                 }
                 else
                 {
                   y=Svy_yr(f,j);
                   Svy_log_q(f,j)=parm_timevary(Qparm_timevary(Q_setup_parms(f,1)),y);
                 }
               }

     // SS_Label_Info_25.1.3 #log or not
               if(Svy_errtype(f)==-1)  // normal
               {
                 Svy_q(f) = Svy_log_q(f);        //  q already in  arithmetic space
               }
               else  //  lognormal, or t-distribution in lognormal
               {
                 Svy_q(f) = mfexp(Svy_log_q(f));        // get q in arithmetic space
               }

     // SS_Label_Info_46.1.1 #note order of operations,  vbio raised to a power, then constant is added, then later multiplied by Q.  Needs work
               switch (Q_setup(f,1))
               {
                 case 2:
                 {
                   //  no break, so do same as case 1
                 }
                 case 4:
                 {
                   //  no break, so do same as case 1
                 }
                 case 1:
                 {
                   if(Q_setup(f,5)==1)  // float  Q calculated and applied in objfun section
                   {
                     if(Svy_errtype(f)>=0)  //  lognormal or T-distribution
                     {Svy_est(f,j)=log(vbio+0.000001);}
                     else
                     {Svy_est(f,j)=vbio;}
                   }
                   else
                   {
                     if(Svy_errtype(f)>=0)  //  lognormal or T-distribution
                     {Svy_est(f,j)=log(vbio+0.000001)+Svy_log_q(f,j);}
                     else
                     {Svy_est(f,j)=vbio*Svy_q(f,j);}
                   }
                   break;
                 }
                 case 3:  //  link is power function
                 {
                   vbio=pow(vbio,1.0+Q_parm(Q_setup_parms(f,1)+1));  //  raise vbio to a power
                   if(Svy_errtype(f)>=0)  //  lognormal or T-distribution
                   {Svy_est(f,j)=log(vbio+0.000001)+Svy_log_q(f,j);}
                   else
                   {Svy_est(f,j)=vbio*Svy_q(f,j);}
                   break;
                 }
               }
              }
              break;
            }  //  end survey index

            case(2):  //  DISCARD_OUTPUT
   /* SS_Label_46.2 expected discard amount */
            {
              j=have_data(ALK_time,f,data_type,0);  //  number of observations
            if(j>0)
            {
              j=have_data(ALK_time,f,data_type,1);  //  only getting first observation for now
              if(catch_ret_obs(f,t)>0.0 || y>endyr)
              {
                if(disc_units(f)==3)  // numbers regardless of catchunits for retained catch
                {
                  exp_disc(f,j)=catch_fleet(t,f,4)-catch_fleet(t,f,6);
                }
                else if(catchunits(f)==1)  // biomass units for retained and discarded catch
                {
                  exp_disc(f,j)=catch_fleet(t,f,1)-catch_fleet(t,f,3);  // discard in biomass
                  if(disc_units(f)==2) exp_disc(f,j) /= (catch_fleet(t,f,1) + 0.0000001);
                }
                else   // numbers for retained and discarded catch
                {
                  exp_disc(f,j)=catch_fleet(t,f,4)-catch_fleet(t,f,6);   // discard in numbers
                  if(disc_units(f)==2) exp_disc(f,j) /= (catch_fleet(t,f,4) + 0.0000001);
                }
                if(exp_disc(f,j)<0.0) warning<<f<<" "<<j<<" "<<exp_disc(f,j)<<" catches "<<catch_fleet(t,f)<<endl;
              }
              else
              {
                exp_disc(f,j)=-1.;
              }
            }
            break;
            }  //  end discard

            case(3):  // mean body weight
   /* SS_Label_46.3 expected mean body weight */
            {
              if(have_data(ALK_time,f,data_type,0)>0)  //  number of observations
              {
                for (int reps=1;reps<=have_data(ALK_time,f,data_type,0);reps++)
                {
                  j=have_data(ALK_time,f,data_type,reps);  //  observation number in overall list
                  z=mnwtdata(5,j);  //  type 1=length, 2=weight
                  int parti = mnwtdata(4,j);  //  parrtition:  0=all, 1=discard, 2=retained
                  switch (parti)
                  {
                    case 0:
                      {
                        if(z==2) {exp_mnwt(j) = (exp_l_temp*wt_len2(s,1)) / sum(exp_l_temp);}  // total sample
                        else
                        {exp_mnwt(j) = (exp_l_temp*len_bins_m2) / sum(exp_l_temp);}
                        break;
                      }
                    case 1:
                      {
                        if(z==2) exp_mnwt(j) = (exp_l_temp-exp_l_temp_ret)*wt_len2(s,1) / (sum(exp_l_temp)-sum(exp_l_temp_ret));  // discard sample
                        else
                        {exp_mnwt(j) = (exp_l_temp-exp_l_temp_ret)*len_bins_m2 / (sum(exp_l_temp)-sum(exp_l_temp_ret));}
                        break;
                      }
                    case 2:
                      {
                        if(z==2) exp_mnwt(j) = (exp_l_temp_ret*wt_len2(s,1)) / sum(exp_l_temp_ret);    // retained only
                        else
                        {exp_mnwt(j) = (exp_l_temp_ret*len_bins_m2) / sum(exp_l_temp_ret);}
                        break;
                      }
                  }
                }
              }
            break;
            }

            case(4):  //  length composition
   /* SS_Label_46.4  length composition */
            {
          if(have_data(ALK_time,f,data_type,0)>0)
            {
           for (j=1;j<=have_data(ALK_time,f,data_type,0);j++)                          // loop all obs of this type
           {
            i=have_data(ALK_time,f,data_type,j);
            if(LenBin_option>1)
            {
            if(mkt_l(f,i)==0) {exp_l(f,i) = make_len_bin*exp_l_temp;}           // expected size comp  MAtrix * vector = vector
            else if(mkt_l(f,i)==1) {exp_l(f,i) = make_len_bin*(exp_l_temp-exp_l_temp_ret);}  // discard sample
            else {exp_l(f,i) = make_len_bin*exp_l_temp_ret;}    // retained only
            }
            else  //  using data_bins same as pop_bins
            {
            if(mkt_l(f,i)==0) {exp_l(f,i) = exp_l_temp;}           // expected size comp  MAtrix * vector = vector
            else if(mkt_l(f,i)==1) {exp_l(f,i) = (exp_l_temp-exp_l_temp_ret);}  // discard sample
            else {exp_l(f,i) = exp_l_temp_ret;}    // retained only
            }
            if(docheckup==1) echoinput<<" len obs "<<mkt_l(f,i)<<" "<<tails_l(f,i)<<endl<<obs_l(f,i)<<endl<<exp_l(f,i)<<endl;
           //  code for tail compression, etc in the likelihood section to allow for superyear combinations                                                                      // mkt=0 Do nothing
           }  // end lengthcomp loop
            }
           break;
            }  // end  length composition

            case(5):  //  age composition
   /* SS_Label_46.5  age composition */
            {
            if(have_data(ALK_time,f,data_type,0)>0)
              {
             for (j=1;j<=have_data(ALK_time,f,data_type,0);j++)                          // loop all obs of this type
             {
              i=have_data(ALK_time,f,data_type,j);
              k=ageerr_type_a(f,i);                           //  age-err type
              if(use_Lbin_filter(f,i)==0)
              {                                              // sum across all length bins
               if(mkt_a(f,i)==0) age_exp = agetemp;
               if(mkt_a(f,i)==1) age_exp = agetemp-exp_truea_ret;  // discard sample
               if(mkt_a(f,i)==2) age_exp = exp_truea_ret;    // retained only
              }
              else
              {            // only use ages from specified range of size bins
                            // Lbin_filter is a vector with 0 for unselected size bins and 1 for selected bins
                if(mkt_a(f,i)==0) age_exp = exp_AL * Lbin_filter(f,i);
                if(mkt_a(f,i)==1) age_exp = (exp_AL-exp_AL_ret) * Lbin_filter(f,i);  // discard sample
                if(mkt_a(f,i)==2) age_exp = exp_AL_ret * Lbin_filter(f,i);    // retained only
              }
              exp_a(f,i) = age_age(k) * age_exp;
              if(docheckup==1) echoinput<<"Lbin "<<Lbin_filter(f,i)<<endl<<" obs "<<obs_a(f,i)<<endl<<"expected "<<age_exp<<endl<<"exp with ageerr "<<exp_a(f,i)<<endl;
              //  add code here to store exp_a_true(f,i)=age_exp
              //  then in data generation the sample can be from true age before ageing error is applied

//              if(docheckup==1) echoinput<<" real age "<<age_exp<<endl<<"Lbin "<<Lbin_filter(f,i)<<endl<<" obs "<<obs_a(f,i)<<endl<<" exp with ageerr "<<exp_a(f,i)<<endl;

             }  // end agecomp loop within fleet/time
            }
             break;
            }  // end age composition

            case(6):  //  weight composition (generalized size composition)
   /* SS_Label_46.6  weight composition (generalized size composition) */
            {
            if(SzFreq_Nmeth>0)       //  have some sizefreq data
            {

              if(have_data(ALK_time,f,data_type,0)>0)
              {
                for (j=1;j<=have_data(ALK_time,f,data_type,0);j++)                          // loop all obs of this type
                {
                  iobs=have_data(ALK_time,f,data_type,j);  //  observation index
                  SzFreqMethod=SzFreq_obs_hdr(iobs,6);
                  SzFreqMethod_seas=nseas*(SzFreqMethod-1)+s;     // index that combines sizefreqmethod and season and used in SzFreqTrans
                  if(SzFreq_obs_hdr(iobs,9)>0)  // first occurrence of this method at this time is with fleet = f
                  {
                    if(do_once==1 || (MG_active(3)>0 && (timevary_MG(y,3)>0 )))  // calc  matrix because wtlen parameters have changed
                    {
                      for (gg=1;gg<=gender;gg++)
                      {
                        if(gg==1)
                        {z1=1;z2=nlength;ibin=0; ibinsave=0;}  // female
                        else
                        {z1=nlength1; z2=nlength2; ibin=0; ibinsave=SzFreq_Nbins(SzFreqMethod);}   // male
                        topbin=0.;
                        botbin=0.;

        //  NOTE:  wt_len_low is  calculated separately for each growth pattern (GPat)
        //  but the code below still just uses GPat=1 for calculation of the sizefreq transition matrix

                        switch(SzFreq_units(SzFreqMethod))    // biomass vs. numbers are accumulated in the bins
                        {
                          case(1):  // units are biomass, so accumulate body weight into the bins;  Assume that bin demarcations are also in biomass
                          {
                            if(SzFreq_Omit_Small(SzFreqMethod)==1)
                            {
                              while(wt_len_low(s,1,z1+1)<SzFreq_bins(SzFreqMethod,1) && z1<z2)
                              {z1++;}
                            }      // ignore tiny fish
                            if(z1+1>=z2)
                            {
                              N_warn++; cout<<" EXIT - see warning "<<endl;
                              warning<<" error:  max population size "<<wt_len_low(s,1,z1)<<" is less than first data bin "<<
                              SzFreq_bins(SzFreqMethod,1)<<" for SzFreqMethod "<<SzFreqMethod<<endl;
                              exit(1);
                            }

                            if( wt_len_low(s,1,nlength2) < SzFreq_bins(SzFreqMethod,SzFreq_Nbins(SzFreqMethod)))
                            {
                              N_warn++; cout<<" EXIT - see warning "<<endl;
                              warning<<" error:  max population size "<<wt_len_low(s,1,nlength2)<<" is less than max data bin "<<
                              SzFreq_bins(SzFreqMethod,SzFreq_Nbins(SzFreqMethod))<<
                              " for SzFreqMethod "<<SzFreqMethod<<endl;
                              exit(1);
                            }

                            for (z=z1;z<=z2;z++)
                            {
                              if(ibin==SzFreq_Nbins(SzFreqMethod))
                              {
                                SzFreqTrans(SzFreqMethod_seas,z,ibinsave)=wt_len2(s,1,z);
                              }
                              else
                              {
                                if(wt_len_low(s,1,z)>=topbin)
                                {
                                  ibin++; ibinsave++;
                                }
                                if(ibin>1)  {botbin=SzFreq_bins2(SzFreqMethod,ibin);}
                                if(ibin==SzFreq_Nbins(SzFreqMethod))
                                {
                                  SzFreqTrans(SzFreqMethod_seas,z,ibinsave)=wt_len2(s,1,z);
                                  topbin=99999.;
                                }
                                else
                                {
                                  topbin=SzFreq_bins2(SzFreqMethod,ibin+1);
                                  if(wt_len_low(s,1,z)>=botbin && wt_len_low(s,1,z+1)<=topbin )
                                  {
                                    SzFreqTrans(SzFreqMethod_seas,z,ibinsave)=wt_len2(s,1,z);
                                  }
                                  else
                                  {
                                    temp=(wt_len_low(s,1,z+1)-topbin)/wt_len_fd(s,1,z);  // frac in pop bin above (data bin +1)
                                    temp1=wt_len_low(s,1,z)+(1.-temp*0.5)*wt_len_fd(s,1,z);  // approx body wt for these fish
                                    temp2=wt_len_low(s,1,z)+(1.-temp)*0.5*wt_len_fd(s,1,z);  // approx body wt for  fish below
                                    SzFreqTrans(SzFreqMethod_seas,z,ibinsave+1)=temp*temp1;
                                    SzFreqTrans(SzFreqMethod_seas,z,ibinsave)=(1.-temp)*temp2;
                                  }
                                }
                              }
                            }
                            if(SzFreq_scale(SzFreqMethod)==2 && gg==gender)  // convert to pounds
                            {
                              SzFreqTrans(SzFreqMethod_seas)/=0.4536;
                            }
                            break;
                          }  //  end of units in biomass
                          // NOTE: even though  the transition matrix is currently in units of biomass distribution, there is no need to
                          // normalize to sum to 1.0 here because the normalization will occur after it gets used to create SzFreq_exp

                          case(2):   // units are numbers
                          {
                            if(SzFreq_scale(SzFreqMethod)<=2)   //  bin demarcations are in weight units (1=kg, 2=lbs), so uses wt_len to compare to bins
                            {
                              if(SzFreq_Omit_Small(SzFreqMethod)==1)
                              {
                                while(wt_len_low(s,1,z1+1)<SzFreq_bins(SzFreqMethod,1) && z1<z2)
                                {z1++;}
                              }      // ignore tiny fish
                              if(z1+1>=z2)
                              {
                                N_warn++; cout<<" EXIT - see warning "<<endl;
                                warning<<" error:  max population size "<<wt_len_low(s,1,z1)<<" is less than first data bin "<<
                                SzFreq_bins(SzFreqMethod,1)<<" for SzFreqMethod "<<SzFreqMethod<<endl;
                                exit(1);
                              }
                              if( wt_len_low(s,1,nlength2) < SzFreq_bins(SzFreqMethod,SzFreq_Nbins(SzFreqMethod)))
                              {
                                N_warn++; cout<<" EXIT - see warning "<<endl;
                                warning<<" error:  max population size "<<wt_len_low(s,1,nlength2)<<" is less than max data bin "<<
                                SzFreq_bins(SzFreqMethod,SzFreq_Nbins(SzFreqMethod))<<
                                " for SzFreqMethod "<<SzFreqMethod<<endl;
                                exit(1);
                              }

                              for (z=z1;z<=z2;z++)
                              {
                                if(ibin==SzFreq_Nbins(SzFreqMethod))
                                {SzFreqTrans(SzFreqMethod_seas,z,ibinsave)=1.;}  //checkup<<" got to last ibin, so put rest of popbins here"<<endl;
                                else
                                {
                                  if(wt_len_low(s,1,z)>=topbin) {ibin++; ibinsave++;}  //checkup<<" incr ibin "<<z<<" "<<ibin<<" "<<len_bins(z)<<" "<<len_bins_dat(ibin);
                                  if(ibin>1)  {botbin=SzFreq_bins2(SzFreqMethod,ibin);}
                                  if(ibin==SzFreq_Nbins(SzFreqMethod))  // checkup<<" got to last ibin, so put rest of popbins here"<<endl;
                                  {
                                    SzFreqTrans(SzFreqMethod_seas,z,ibinsave)=1.;
                                    topbin=99999.;
                                  }
                                  else
                                  {
                                    topbin=SzFreq_bins2(SzFreqMethod,ibin+1);
                                    if(wt_len_low(s,1,z)>=botbin && wt_len_low(s,1,z+1)<=topbin )  //checkup<<" pop inside dat, put here"<<endl;
                                    {SzFreqTrans(SzFreqMethod_seas,z,ibinsave)=1.;}
                                    else       // checkup<<" overlap"<<endl;
                                    {
                                      SzFreqTrans(SzFreqMethod_seas,z,ibinsave+1)=(wt_len_low(s,1,z+1)-topbin)/wt_len_fd(s,1,z);
                                      SzFreqTrans(SzFreqMethod_seas,z,ibinsave)=1.-SzFreqTrans(SzFreqMethod_seas,z,ibinsave+1);
                                    }
                                  }
                                }
                              }
                            }

                            else       //  bin demarcations are in length unit (3=cm, 4=inch) so uses population len_bins to compare to data bins
                            {
                              if(SzFreq_Omit_Small(SzFreqMethod)==1)
                              {while(len_bins2(z1+1)<SzFreq_bins(SzFreqMethod,1)) {z1++;}
                                //  echoinput<<"accumulate starting at bin: "<<z1<<endl;
                              }      // ignore tiny fish
                              for (z=z1;z<=z2;z++)
                              {
                                if(ibin==SzFreq_Nbins(SzFreqMethod))
                                {SzFreqTrans(SzFreqMethod_seas,z,ibinsave)=1.;} //checkup<<" got to last ibin, so put rest of popbins here"<<endl;
                                else
                                {
                                  if(len_bins2(z)>=topbin) {ibin++; ibinsave++;}  //checkup<<" incr ibin "<<z<<" "<<ibin<<" "<<len_bins(z)<<" "<<len_bins_dat(ibin);
                                  if(ibin>1)  {botbin=SzFreq_bins2(SzFreqMethod,ibin);}
                                  if(ibin==SzFreq_Nbins(SzFreqMethod))  // checkup<<" got to last ibin, so put rest of popbins here"<<endl;
                                  {
                                    SzFreqTrans(SzFreqMethod_seas,z,ibinsave)=1.;
                                    topbin=99999.;
                                  }
                                  else
                                  {
                                    topbin=SzFreq_bins2(SzFreqMethod,ibin+1);
                                    if(len_bins2(z)>=botbin && len_bins2(z+1)<=topbin )  //checkup<<" pop inside dat, put here"<<endl;
                                    {SzFreqTrans(SzFreqMethod_seas,z,ibinsave)=1.;}
                                    else       // checkup<<" overlap"<<endl;
                                    {
                                      SzFreqTrans(SzFreqMethod_seas,z,ibinsave+1)=(len_bins2(z+1)-topbin)/(len_bins2(z+1)-len_bins2(z));
                                      SzFreqTrans(SzFreqMethod_seas,z,ibinsave)=1.-SzFreqTrans(SzFreqMethod_seas,z,ibinsave+1);
                                    }
                                  }
                                }
                              }
                            }
                            break;
                          }  //  end of units in numbers
                        }
                        if(docheckup==1 && gg==gender) echoinput<<" sizefreq trans_matrix: method/season "<<SzFreqMethod<<" / "<<s<<endl
                        <<trans(SzFreqTrans(SzFreqMethod_seas))<<endl;
                      }  // end gender loop
                    }  //  end needing to calc the matrix because it may have changed
                  }  // done calculating the SzFreqTransition matrix for this method

                  switch(SzFreq_obs_hdr(iobs,5))   // discard/retained partition
                  {
                    case(0):
                    {
                      SzFreq_exp(iobs)=trans(SzFreqTrans(SzFreqMethod_seas))*exp_l_temp;
                      break;
                    }
                    case(1):
                    {
                      SzFreq_exp(iobs)=trans(SzFreqTrans(SzFreqMethod_seas))*(exp_l_temp-exp_l_temp_ret);
                      break;
                    }
                    case(2):
                    {
                      SzFreq_exp(iobs)=trans(SzFreqTrans(SzFreqMethod_seas))*exp_l_temp_ret;
                      break;
                    }
                  }
 #ifdef DO_ONCE
                  if(do_once==1) echoinput<<y<<" "<<f<<" szfreq_exp_initial  "<<SzFreq_exp(iobs)<<endl;
 #endif

                  if(gender==2)
                  {
                    k=SzFreq_obs_hdr(iobs,8);  // max bins for this method
                    switch(SzFreq_obs_hdr(iobs,4))   //  combine, select or each gender
                    {
                      case(0):                    // combine genders
                      {
                        for (ibin=1;ibin<=k;ibin++) SzFreq_exp(iobs,ibin)+=SzFreq_exp(iobs,k+ibin);
                        SzFreq_exp(iobs)(k+1,2*k)=0.0;
                        SzFreq_exp(iobs)(1,k)/=sum(SzFreq_exp(iobs)(1,k));
                        if(SzFreq_mincomp(SzFreqMethod)>0.0)
                        {
                          SzFreq_exp(iobs)(1,k)+=SzFreq_mincomp(SzFreqMethod);
                          SzFreq_exp(iobs)(1,k)/=sum(SzFreq_exp(iobs)(1,k));
                        }
                        break;
                      }
                      case(1):     // female only
                      {
                        SzFreq_exp(iobs)(k+1,2*k)=0.0;  //  zero out the males so will not interfere with data generation
                        SzFreq_exp(iobs)(1,k)/=sum(SzFreq_exp(iobs)(1,k));
                        if(SzFreq_mincomp(SzFreqMethod)>0.0)
                        {
                          SzFreq_exp(iobs)(1,k)+=SzFreq_mincomp(SzFreqMethod);
                          SzFreq_exp(iobs)(1,k)/=sum(SzFreq_exp(iobs)(1,k));
                        }
                        break;
                      }
                      case(2):            //   male only
                      {
                        ibin=SzFreq_obs_hdr(iobs,7);
                        SzFreq_exp(iobs)(1,ibin-1)=0.0;  //  zero out the females so will not interfere with data generation
                        SzFreq_exp(iobs)(ibin,k)/=sum(SzFreq_exp(iobs)(ibin,k));
                        if(SzFreq_mincomp(SzFreqMethod)>0.0)
                        {
                          SzFreq_exp(iobs)(ibin,k)+=SzFreq_mincomp(SzFreqMethod);
                          SzFreq_exp(iobs)(ibin,k)/=sum(SzFreq_exp(iobs)(ibin,k));
                        }
                        break;
                      }
                      case(3):           //  each gender
                      {
                        SzFreq_exp(iobs)/=sum(SzFreq_exp(iobs));
                        if(SzFreq_mincomp(SzFreqMethod)>0.0)
                        {
                          SzFreq_exp(iobs)+=SzFreq_mincomp(SzFreqMethod);
                          SzFreq_exp(iobs)/=sum(SzFreq_exp(iobs));
                        }
                        break;
                      }
                    }  //  end gender switch
                  }  // end have 2 genders
                  else
                  {
                    k=SzFreq_obs_hdr(iobs,8);  // max bins for this method
                    SzFreq_exp(iobs)(1,k)/=sum(SzFreq_exp(iobs)(1,k));
                    if(SzFreq_mincomp(SzFreqMethod)>0.0)
                    {
                      SzFreq_exp(iobs)(1,k)+=SzFreq_mincomp(SzFreqMethod);
                      SzFreq_exp(iobs)(1,k)/=sum(SzFreq_exp(iobs)(1,k));
                    }
                  }
 #ifdef DO_ONCE
                  if(do_once==1) echoinput<<y<<" "<<f<<" szfreq_exp_final  "<<SzFreq_exp(iobs)<<endl;
 #endif
                }  // end loop of obs for fleet = f
              }   //  end having some obs for this method in this fleet
            }    //  end use of generalized size freq data
            break;
            }  //  end generalized size composition

            case(7):  //  mean size-at-age
   /* SS_Label_46.7  mean size at age */
            {
          if(have_data(ALK_time,f,data_type,0)>0)
            {
           for (j=1;j<=have_data(ALK_time,f,data_type,0);j++)                          // loop all obs of this type
           {
            i=have_data(ALK_time,f,data_type,j);
             k=abs(ageerr_type_ms(f,i));                           //  age-err type  where the sign selects length vs. weight
             if(ageerr_type_ms(f,i)>0)  // values are length at age
             {
               if(mkt_ms(f,i)==0)  //  total catch
               {
                 exp_a_temp = age_age(k) * agetemp;             //  numbers at binned age
                 exp_ms(f,i) = age_age(k) * (exp_AL * len_bins_m2);  // numbers * length
                 exp_ms_sq(f,i) = age_age(k) * (exp_AL * len_bins_sq);  // numbers * length^2
               }
               if(mkt_ms(f,i)==1) //  discard
               {
//                 exp_a_temp = age_age(k) * (exp_AL * (1-retain(y,f)));             //  numbers at binned age = age_age(bins,age) * sum(age)
//                 exp_ms(f,i) = age_age(k) * (exp_AL * elem_prod((1-retain(y,f)),len_bins_m2));  // numbers * length
//                 exp_ms_sq(f,i) = age_age(k) * (exp_AL * elem_prod((1-retain(y,f)),len_bins_sq));  // numbers * length^2
                 exp_a_temp = age_age(k) * (agetemp-exp_truea_ret);
                 exp_ms(f,i) = age_age(k) * ((exp_AL-exp_AL_ret) * len_bins_m2);  // numbers * length
                 exp_ms_sq(f,i) = age_age(k) * ((exp_AL-exp_AL_ret) * len_bins_sq);  // numbers * length^2
               }
               if(mkt_ms(f,i)==2)  //  retained
               {
                 exp_a_temp = age_age(k) * exp_truea_ret;             //  numbers at binned age = age_age(bins,age) * sum(age)
                 exp_ms(f,i) = age_age(k) * (exp_AL_ret * len_bins_m2);  // numbers * length
                 exp_ms_sq(f,i) = age_age(k) * (exp_AL_ret * len_bins_sq);  // numbers * length^2
               }
             }
             else  // values are weight at age
             {
               if(mkt_ms(f,i)==0)
               {
                 exp_a_temp = age_age(k) * agetemp;             //  numbers at binned age = age_age(bins,age) * sum(age)
                 exp_ms(f,i) = age_age(k) * (exp_AL * wt_len2(s,1));  // numbers * bodywt
                 exp_ms_sq(f,i) = age_age(k) * (exp_AL * wt_len2_sq(s,1));  // numbers * bodywt^2
               }
               if(mkt_ms(f,i)==1)
               {
                 exp_a_temp = age_age(k) * (agetemp-exp_truea_ret);            //  numbers at binned age = age_age(bins,age) * sum(age)
                 exp_ms(f,i) = age_age(k) * ((exp_AL-exp_AL_ret) * wt_len2(s,1));  // numbers * bodywt
                 exp_ms_sq(f,i) = age_age(k) * ((exp_AL-exp_AL_ret) * wt_len2_sq(s,1));  // numbers * bodywt^2
               }
               if(mkt_ms(f,i)==2)
               {
                 exp_a_temp = age_age(k) * exp_truea_ret;             //  numbers at binned age = age_age(bins,age) * sum(age)
                 exp_ms(f,i) = age_age(k) * (exp_AL_ret* wt_len2(s,1));  // numbers * bodywt
                 exp_ms_sq(f,i) = age_age(k) * (exp_AL_ret * wt_len2_sq(s,1));  // numbers * bodywt^2
               }
             }
             exp_ms(f,i)+=1.0e-6;
             exp_a_temp+=1.0e-6;
             exp_ms_sq(f,i)+=1.0e-6;
             exp_ms_sq(f,i) = sqrt(
                                   elem_div(
                                            (exp_ms_sq(f,i) - elem_div(elem_prod(exp_ms(f,i),exp_ms(f,i)), exp_a_temp)),
                                            exp_a_temp
                                           )
                                  )
                                  + 0.000001;    //std.err. of size at binned age = sqrt( (P2-P1*P1/P0) / P0 )
             exp_ms(f,i) = elem_div(exp_ms(f,i), exp_a_temp);   //  mean size at binned age
           }
         }   // endl size-at-age
           break;
            }  //  end mean size-at-age

          }  // end switch(data_type)
        }  //  end loop for types of data
      }
    }  //  end loop of fleets
  }  //  end loop of subseasons
  return;
  }  //  end function

