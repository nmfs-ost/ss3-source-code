FUNCTION void Make_AgeLength_Key(const int s, const int subseas)
  {
//********************************************************************
 /*  SS_Label_FUNCTION 31 Make_AgeLength_Key */
 //  this is called for each subseason of each year
 //  checks to see if a re-calc of the ALK is needed for that time step
 //  if it is, then it loops through all possible biological entities "g" (sex, growth pattern, settlement event, platoon)
 //  then it retrieves the previously calculated and stored mean size-at-age from Ave_Size(t,subseas,gstart)
 //  moves these mean sizes into a _W working vector 
 //  then it calls calc_ALK to make and store the age-length key for that subseason for each biological entity
 
  int gstart;
   ALK_idx=(s-1)*N_subseas+subseas;
   dvar_vector use_Ave_Size_W(0,nages);
   dvar_vector use_SD_Size(0,nages);
   imatrix ALK_range_use(0,nages,1,2);
   if(ALK_subseas_update(ALK_idx)==1) //  so need to calculate
   {

   ALK_subseas_update(ALK_idx)=0;  //  reset to 0 to indicate update not needed
   gp=0;
    for (int sex=1;sex<=gender;sex++)
    for (GPat=1;GPat<=N_GP;GPat++)
    {
      gp=gp+1;
      gstart=g_Start(gp);  //  base platoon
      for (settle=1;settle<=N_settle_timings;settle++)
      {
        gstart+=N_platoon;
        if(recr_dist_pattern(GPat,settle,0)>0)
        {
          for (gp2=1;gp2<=N_platoon;gp2++)      // loop the platoons
          {
            g=gstart+ishadow(gp2);

            use_Ave_Size_W=Ave_Size(t,subseas,gstart);
            use_SD_Size=Sd_Size_within(ALK_idx,gstart);
            if(N_platoon>1) use_Ave_Size_W += shadow(gp2)*Sd_Size_between(ALK_idx,gstart);

            int ALK_phase;
            if(Grow_logN==0)
            {
              int ALK_finder=(ALK_idx-1)*gmorph+g;
              if((do_once==1 || (current_phase()>ALK_phase) && !last_phase()))
              {
                ALK_phase=current_phase();
                ALK_range_use=calc_ALK_range(len_bins,use_Ave_Size_W,use_SD_Size,ALK_tolerance);  //  later need to offset according to g
                ALK_range_g_lo(ALK_finder)=column(ALK_range_use,1);
                ALK_range_g_hi(ALK_finder)=column(ALK_range_use,2);
              }
              ALK(ALK_idx,g)=calc_ALK(len_bins,ALK_range_g_lo(ALK_finder),ALK_range_g_hi(ALK_finder),use_Ave_Size_W,use_SD_Size);
            }
            else
            {
              ALK(ALK_idx,g)=calc_ALK_log(log_len_bins,use_Ave_Size_W,use_SD_Size);
            }
            if(subseas==1)
            {
              if(WTage_rd==0)
              {Wt_Age_beg(s,g)=(ALK(ALK_idx,g)*wt_len(s,GP(g)));}   // wt-at-age at beginning of period
              else
              {Wt_Age_beg(s,g)=WTage_emp(t,GP3(g),0);}
              if(save_for_report==2 && ishadow(GP2(g))==0) bodywtout<<-y<<" "<<s<<" "<<gg<<" "<<GP4(g)<<" "<<Bseas(g)<<" "<<0<<" "<<Wt_Age_beg(s,g)<<endl;
            }

            if(subseas==mid_subseas)
            {
              if(WTage_rd==0)
              {Wt_Age_mid(s,g)=ALK(ALK_idx,g)*wt_len(s,GP(g));}  // use for fisheries with no size selectivity
              else
              {Wt_Age_mid(s,g)=WTage_emp(t,GP3(g),-1);}
              if(save_for_report==2 && ishadow(GP2(g))==0) bodywtout<<-y<<" "<<s<<" "<<gg<<" "<<GP4(g)<<" "<<Bseas(g)<<" "<<-1<<" "<<Wt_Age_mid(s,g)<<endl;
            }
          }  // end platoon loop
        }
      }   // end settle loop
    }  // end growth pattern&gender loop
   }
  }  //  end Make_AgeLength_Key

FUNCTION imatrix calc_ALK_range(const dvector &len_bins, const dvar_vector &mean_len_at_age, const dvar_vector &sd_len_at_age,
                 const double ALK_tolerance)
  {
 //SS_Label_FUNCTION_31.2 # calc_ALK_range finds the range for the distribution of length for each age
  int a, z;  // declare indices
  int nlength = len_bins.indexmax(); // find number of lengths
  int nages = mean_len_at_age.indexmax(); // find number of ages
  imatrix ALK_range(0,nages,1,2); // stores minimum and maximum
  dvariable len_dev;
  double ALK_tolerance_2;
  ALK_tolerance_2=1.0-ALK_tolerance;
  for (a = 0; a <= nages; a++)
  {
    if(ALK_tolerance==0.00)
      {
        ALK_range(a,1)=1;
        ALK_range(a,2)=nlength;
      }
      else
        {
    z=1;
    temp=0.0;
    while(temp<ALK_tolerance && z<nlength)
    { 
      len_dev = (len_bins(z) - mean_len_at_age(a)) / (sd_len_at_age(a));
      temp = cumd_norm (len_dev);
      z++;
    }
    ALK_range(a,1)=z;
    temp=0.0;
    while(temp<ALK_tolerance_2 && z<nlength)
    {
      len_dev = (len_bins(z) - mean_len_at_age(a)) / (sd_len_at_age(a));
      temp = cumd_norm (len_dev);
      z++;
    } // end length loop
    ALK_range(a,2)=min(z,nlength);
    }
  }   // end age loop
  return (ALK_range);
  }

//  the function calc_ALK is called by Make_AgeLength_Key to calculate the distribution of length for each age
FUNCTION dvar_matrix calc_ALK(const dvector &len_bins, const ivector &ALK_range_lo, const ivector &ALK_range_hi, const dvar_vector &mean_len_at_age, const dvar_vector &sd_len_at_age)
  {
//  the function calc_ALK is called by Make_AgeLength_Key to calculate the distribution of length for each age
   RETURN_ARRAYS_INCREMENT();
 //SS_Label_FUNCTION_31.2 #Calculate the ALK
  int a, z;  // declare indices
  int nlength = len_bins.indexmax(); // find number of lengths
  int nages = mean_len_at_age.indexmax(); // find number of ages
  dvar_matrix ALK_w(0,nages, 1,nlength); // create matrix to return with length vectors for each age
  dvar_vector AL(1,nlength+1); // create temporary vector
  dvariable len_dev;
  for (a = 0; a <= nages; a++)
  {
    AL.initialize();
    for (z = ALK_range_lo(a); z <= ALK_range_hi(a); z++) 
    { 
      len_dev = (len_bins(z) - mean_len_at_age(a)) / (sd_len_at_age(a));
      AL(z) = cumd_norm (len_dev);
    }
    AL(ALK_range_hi(a)+1,nlength+1)=1.0;
    ALK_w(a)=first_difference(AL);
  }   // end age loop
  RETURN_ARRAYS_DECREMENT();
  return (ALK_w);
  }


FUNCTION dvar_matrix calc_ALK_log(const dvector &len_bins, const dvar_vector &mean_len_at_age, const dvar_vector &sd_len_at_age)
  {
   RETURN_ARRAYS_INCREMENT();
 //SS_Label_FUNCTION_31.3 #Calculate the ALK with lognormal error, called when Grow_logN==1
  int a, z;  // declare indices
  int nlength = len_bins.indexmax(); // find number of lengths
  int nages = mean_len_at_age.indexmax(); // find number of ages
  dvar_matrix ALK_w(0,nages, 1,nlength); // create matrix to return with length vectors for each age
  dvar_vector AL(1,nlength+1); // create temporary vector
  dvariable len_dev;
  dvariable temp;

  AL(1)=0.0; AL(nlength+1)=1.0;  //  terminal values that are not recalculated

  for (a = 0; a <= nages; a++)
  {
    temp=log(mean_len_at_age(a))-0.5*sd_len_at_age(a)*sd_len_at_age(a);
    for (z = 2; z <= nlength; z++) 
    { 
      len_dev = (len_bins(z) - temp) / (sd_len_at_age(a));
      AL(z) = cumd_norm(len_dev);
    } // end length loop
    ALK_w(a) = first_difference(AL);
  }   // end age loop
  RETURN_ARRAYS_DECREMENT();
  return (ALK_w);
  }

