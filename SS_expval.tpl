//********************************************************************
 /*  SS_Label_FUNCTION 46  Get_expected_values:  check for data */
FUNCTION void Get_expected_values();
  {
  dvar_vector pre_AL(1,nlength);

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
          exp_l_temp.initialize();
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

            if(F_Method==1 && surveytime(f)<0.0) //  Pope's approximation
            {tempvec_a=elem_prod(Nmid(g),sel_a(y,f,gg));}  //  CHECK   Nmid may not exist correctly unless still within the area loop
            else if(surveytime(f)<0.0) // mimic fishery catch, but without Hrate so gets available numbers
            {tempvec_a=elem_prod(natage(t,p,g),elem_prod(Zrate2(p,g),sel_a(y,f,gg)));}
            else  //  explicit timing
            {tempvec_a=elem_prod(natage(t,p,g),elem_prod(mfexp(-Z_rate(t,p,g)*timing),sel_a(y,f,gg)));}

            pre_AL.initialize();
            for (a=0;a<=nages;a++)
            {
//              if(dolen(f)==1)
//              {
//                pre_AL.shift(1)=tempvec_a(a)*elem_prod(ALK(ALK_idx,g,a),sel_l(y,f,gg));
//              }
//              else
//              {pre_AL.shift(1)=tempvec_a(a)*ALK(ALK_idx,g,a);}
//              exp_AL(a+A2)(L1,L2) += pre_AL.shift(L1);  // shifted to store males in right place and accumulated across morphs

              if(dolen(f)==1)
              {
                for(z=ALK_range_lo(a);z<=ALK_range_hi(a);z++)
                {
                  temp=tempvec_a(a)*ALK(ALK_idx,g,a,z)*sel_l(y,f,gg,z);
                  exp_AL(a+A2,L1-1+z)+=temp;
                  exp_l_temp(L1-1+z)+=temp;
                }
              }
              else
              {
                for(z=ALK_range_lo(a);z<=ALK_range_hi(a);z++)
                {
                  temp=tempvec_a(a)*ALK(ALK_idx,g,a,z);
                  exp_AL(a+A2,L1-1+z)+=temp;
                  exp_l_temp(L1-1+z)+=temp;
                }
              }
            }

            if(Do_Morphcomp)
            {
              if(Morphcomp_havedata(f,t,0)>0)
              {
                Morphcomp_exp(Morphcomp_havedata(f,t,0),5+GP4(g))+=sum(exp_AL);     // total catch of this GP in this season x area
              }
            }
          } //close gmorph loop

//          exp_l_temp=colsum(exp_AL);
          if(docheckup==1) echoinput<<"exp_l: "<<exp_l_temp<<endl;
          if(seltype(f,2)!=0)
          {exp_l_temp_ret=elem_prod(exp_l_temp,retain(y,f));}
           else
          {exp_l_temp_ret=exp_l_temp;}
//          end creation of selected A-L
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
               if(seltype(f,2)>=1)
               {
                 agetemp = exp_AL * retain(y,f);    // retained only
               }
               else
               {
                 agetemp=rowsum(exp_AL);
               }
               vbio=0.0;
               for (a=0;a<=nages;a++) vbio+=WTage_emp(y,1,f,a)*agetemp(a);
               if(gender==2)
               {
                 for (a=0;a<=nages;a++) vbio+=WTage_emp(y,2,f,a)*agetemp(a+nages+1);
               }
             }
             else
             {vbio=exp_l_temp_ret*wt_len2(s,1);}   // biomass  TEMPORARY CODE.  Using gp=1 wt at length
             break;
             }
             case 0:  //  numbers
             {
              vbio=sum(exp_l_temp_ret);
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
                 vbio=SPB_current;
                }
                else
                {
                  vbio=sum(SPB_pop_gp(y,fleet_area(f)));
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
              {vbio=SPB_current*mfexp(recdev(y));}
              else
              {vbio=SPB_current;}
              break;
             }
             case 33:  // recruitment  #33
             {vbio=Recruits; break;}

             case 34:  // spawning biomass depletion
             {
               if(pop==1 || fleet_area(f)==0)
               {
                 vbio=(SPB_current+1.0e-06)/(SPB_virgin+1.0e-06);
                }
                else
                {
                  vbio=(sum(SPB_pop_gp(y,fleet_area(f)))+1.0e-06)/(SPB_virgin+1.0e-06);
                }
               break;
             }
           case 35:  // MGparm deviation  #35
           {
              k=seltype(f,4);  //  specify which dev vector will be compared to this survey
                               //  note that later the value in seltype(f,3) will specify the link function
              //  should there be an explicit zero-centering of the devs here, or just rely on general tendency for the devs to get zero-centererd?
              if(y>=MGparm_dev_minyr(k) && y<=MGparm_dev_maxyr(k)) 
              {
                vbio=MGparm_dev(k,y);
                //  can the mean dev for years with surveys be calculated here?
              }
              else
              {vbio=0.0;}
              break;
           }
           case 36:  //  selparm deviation  #36
            {
              //  need code here
              break;
            }
           case 37:  //  Q deviation  #37
            {
              //  need code here
              break;
            }
           }

           Svy_selec_abund(f,j)=value(vbio);
// SS_Label_Info_46.1.1 #note order of operations,  vbio raised to a power, then constant is added, then later multiplied by Q.  Needs work   
           if(Q_setup(f,1)>0) vbio=pow(vbio,1.0+Q_parm(Q_setup_parms(f,1)));  //  raise vbio to a power

           if(Q_setup(f,5)>0) vbio+=Q_parm(Q_setup_parms(f,5));  //  add a constant;
           if(Svy_errtype(f)>=0)  //  lognormal
           {Svy_est(f,j)=log(vbio+0.000001);}
           else
           {Svy_est(f,j)=vbio;}
           //  Note:  Svy_est() is multiplied by Q in the likelihood section
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
              if(catch_ret_obs(f,t)>0.0)
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
            j=yr_mnwt2(f,t,0); //   sample from total catch
            if(j>0) {exp_mnwt(j) = (exp_l_temp*wt_len2(s,1)) / sum(exp_l_temp);}  // total sample
            else if(j<0)
            {exp_mnwt(-j) = (exp_l_temp*len_bins_m2) / sum(exp_l_temp);}

            j=yr_mnwt2(f,t,1);   // sample from discard
            if(j>0) exp_mnwt(j) = (exp_l_temp-exp_l_temp_ret)*wt_len2(s,1) / (sum(exp_l_temp)-sum(exp_l_temp_ret));  // discard sample
            else if(j<0)
            {exp_mnwt(-j) = (exp_l_temp-exp_l_temp_ret)*len_bins_m2 / (sum(exp_l_temp)-sum(exp_l_temp_ret));}

            j=yr_mnwt2(f,t,2);  // sample from retained catch
            if(j>0) exp_mnwt(j) = (exp_l_temp_ret*wt_len2(s,1)) / sum(exp_l_temp_ret);    // retained only
            else if(j<0)
            {exp_mnwt(-j) = (exp_l_temp_ret*len_bins_m2) / sum(exp_l_temp_ret);}
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
            if(mkt_a(f,i)==0) agetemp = rowsum(exp_AL);             //  numbers at binned age = age_age(bins,age) * sum(age)
            if(mkt_a(f,i)==1) agetemp = exp_AL * (1.-retain(y,f));  // discard sample
            if(mkt_a(f,i)==2) agetemp = exp_AL * retain(y,f);    // retained only
             }
            else
             {            // only use ages from specified range of size bins
                          // Lbin_filter is a vector with 0 for unselected size bins and 1 for selected bins
            if(mkt_a(f,i)==0) agetemp = exp_AL * Lbin_filter(f,i);             //  numbers at binned age = age_age(bins,age) * sum(age)
            if(mkt_a(f,i)==1) agetemp = exp_AL * elem_prod(Lbin_filter(f,i),(1.-retain(y,f)));  // discard sample
            if(mkt_a(f,i)==2) agetemp = exp_AL * elem_prod(Lbin_filter(f,i),retain(y,f));    // retained only
             }
            exp_a(f,i) = age_age(k) * agetemp;
  
            if(docheckup==1) echoinput<<" real age "<<agetemp<<endl<<" obs "<<obs_a(f,i)<<endl<<" exp "<<exp_a(f,i)<<endl;
  
           }  // end agecomp loop within fleet/time
          }
           break;
          }  // end age composition
  
            case(6):  //  weight composition (generalized size composition)
   /* SS_Label_46.6  weight composition (generalized size composition) */
            {
      if(SzFreq_Nmeth>0)       //  have some sizefreq data
      {
  //     create the transition matrices to convert population length bins to weight freq
        for (SzFreqMethod=1;SzFreqMethod<=SzFreq_Nmeth;SzFreqMethod++)
        {
          SzFreqMethod_seas=nseas*(SzFreqMethod-1)+s;     // index that combines sizefreqmethod and season and used in SzFreqTrans
          if(SzFreq_HaveObs2(SzFreqMethod,t)==f)  // first occurrence of this method at this time is with fleet = f
          {
            if(do_once==1 || (MG_active(3)>0 && (time_vary_MG(y,3)>0 )))  // calc the matrix because it may have changed
            {
              for (gg=1;gg<=gender;gg++)
              {
                if(gg==1)
                {z1=1;z2=nlength;ibin=0; ibinsave=0;}  // female
                else
                {z1=nlength1; z2=nlength2; ibin=0; ibinsave=SzFreq_Nbins(SzFreqMethod);}   // male
                topbin=0.;
                botbin=0.;
  
                switch(SzFreq_units(SzFreqMethod))    // biomass vs. numbers
                {
                  case(1):  // units are biomass, so accumulate body weight into the bins;  Assume that bin demarcations are also in biomass
                  {
                    if(SzFreq_Omit_Small(SzFreqMethod)==1)
                    {while(wt_len_low(s,1,z1+1)<SzFreq_bins(SzFreqMethod,1)) {z1++;}}      // ignore tiny fish
  
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
                      {while(wt_len_low(s,1,z1+1)<SzFreq_bins(SzFreqMethod,1)) {z1++;}}      // ignore tiny fish
  
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
                      {while(len_bins2(z1+1)<SzFreq_bins(SzFreqMethod,1)) {z1++;}}      // ignore tiny fish
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
  
          if(SzFreq_HaveObs(f,SzFreqMethod,t,1)>0)
          {
            for (iobs=SzFreq_HaveObs(f,SzFreqMethod,t,1);iobs<=SzFreq_HaveObs(f,SzFreqMethod,t,2);iobs++)
            {
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
            }  // end loop of obs for fleet = f
          }   //  end having some obs for this method in this fleet
        }  // end loop of sizefreqmethods
      }    //  end use of wt freq data
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
               if(mkt_ms(f,i)==0)
               {
                 exp_a_temp = age_age(k) * rowsum(exp_AL);             //  numbers at binned age = age_age(bins,age) * sum(age)
                 exp_ms(f,i) = age_age(k) * (exp_AL * len_bins_m2);  // numbers * length
                 exp_ms_sq(f,i) = age_age(k) * (exp_AL * len_bins_sq);  // numbers * length^2
               }
               if(mkt_ms(f,i)==1)
               {
                 exp_a_temp = age_age(k) * (exp_AL * (1-retain(y,f)));             //  numbers at binned age = age_age(bins,age) * sum(age)
                 exp_ms(f,i) = age_age(k) * (exp_AL * elem_prod((1-retain(y,f)),len_bins_m2));  // numbers * length
                 exp_ms_sq(f,i) = age_age(k) * (exp_AL * elem_prod((1-retain(y,f)),len_bins_sq));  // numbers * length^2
               }
               if(mkt_ms(f,i)==2)
               {
                 exp_a_temp = age_age(k) * (exp_AL * retain(y,f) );             //  numbers at binned age = age_age(bins,age) * sum(age)
                 exp_ms(f,i) = age_age(k) * (exp_AL * elem_prod((retain(y,f)),len_bins_m2));  // numbers * length
                 exp_ms_sq(f,i) = age_age(k) * (exp_AL * elem_prod((retain(y,f)),len_bins_sq));  // numbers * length^2
               }
             }
             else  // values are weight at age
             {
               if(mkt_ms(f,i)==0)
               {
                 exp_a_temp = age_age(k) * rowsum(exp_AL);             //  numbers at binned age = age_age(bins,age) * sum(age)
                 exp_ms(f,i) = age_age(k) * (exp_AL * wt_len2(s,1));  // numbers * bodywt
                 exp_ms_sq(f,i) = age_age(k) * (exp_AL * wt_len2_sq(s,1));  // numbers * bodywt^2
               }
               if(mkt_ms(f,i)==1)
               {
                 exp_a_temp = age_age(k) * (exp_AL * (1-retain(y,f)));             //  numbers at binned age = age_age(bins,age) * sum(age)
                 exp_ms(f,i) = age_age(k) * (exp_AL * elem_prod((1-retain(y,f)),wt_len2(s,1)));  // numbers * bodywt
                 exp_ms_sq(f,i) = age_age(k) * (exp_AL * elem_prod((1-retain(y,f)),wt_len2_sq(s,1)));  // numbers * bodywt^2
               }
               if(mkt_ms(f,i)==2)
               {
                 exp_a_temp = age_age(k) * (exp_AL * retain(y,f) );             //  numbers at binned age = age_age(bins,age) * sum(age)
                 exp_ms(f,i) = age_age(k) * (exp_AL * elem_prod((retain(y,f)),wt_len2(s,1)));  // numbers * bodywt
                 exp_ms_sq(f,i) = age_age(k) * (exp_AL * elem_prod((retain(y,f)),wt_len2_sq(s,1)));  // numbers * bodywt^2
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

