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
 
  int gstart=0;
   ALK_idx=(s-1)*N_subseas+subseas;
   dvar_vector use_Ave_Size_W(0,nages);
   dvar_vector use_SD_Size(0,nages);
   imatrix ALK_range_use(0,nages,1,2);
   if(ALK_subseas_update(ALK_idx)==1) //  so need to calculate
   {
   ALK_subseas_update(ALK_idx)=0;  //  reset to 0 to indicate update has been done
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
          
//  update the sd_within and sb_between here.  Used to be in growth2 function
//  SS_Label_Info_16.5.2  #do calculations related to std.dev. of size-at-age
//  SS_Label_Info_16.5.3 #if (y=styr), calc CV_G(gp,s,a) by interpolation on age or LAA
//  doing this just at y=styr prevents the CV from changing as time-vary growth updates over time
        g=gstart;
        if(CV_const(gp)>0 && y==styr)
        {
          for (a=0;a<=nages;a++)
          {
            if(real_age(g,ALK_idx,a)<AFIX)
            {CV_G(gp,ALK_idx,a)=CVLmin(gp);}
            else if(real_age(g,ALK_idx,a)>=AFIX2_forCV)
            {CV_G(gp,ALK_idx,a)=CVLmax(gp);}
            else if(CV_depvar_a==0)
            {CV_G(gp,ALK_idx,a)=CVLmin(gp) + (Ave_Size(t,subseas,g,a)-Lmin(gp))*CV_delta(gp);}
            else
            {CV_G(gp,ALK_idx,a)=CVLmin(gp) + (real_age(g,ALK_idx,a)-AFIX)*CV_delta(gp);}
          }   // end age loop
        }
        else
        {
          //  already set constant to CVLmi
        }
//  SS_Label_Info_16.5.4  #calc stddev of size-at-age from CV_G(gp,s,a) and Ave_Size(t,g,a)
        if(CV_depvar_b==0)
        {
          Sd_Size_within(ALK_idx,g)=SD_add_to_LAA+elem_prod(CV_G(gp,ALK_idx),Ave_Size(t,subseas,g));
        }
        else
        {
          Sd_Size_within(ALK_idx,g)=SD_add_to_LAA+CV_G(gp,ALK_idx);
        }
//  SS_Label_Info_16.3.5  #if platoons being used, calc the stddev between platoons
        if(N_platoon>1)
        {
          Sd_Size_between(ALK_idx,g)=Sd_Size_within(ALK_idx,g)*sd_between_platoon;
          Sd_Size_within(ALK_idx,g)*=sd_within_platoon;
        }

        if(docheckup==1)
        {
          echoinput<<"with lingrow; subseas: "<<subseas<<" sex: "<<sx(g)<<" gp: "<<GP4(g)<<" g: "<<g<<endl;
          echoinput<<"size "<<Ave_Size(t,subseas,g)(0,min(6,nages))<<" @nages "<<Ave_Size(t,subseas,g,nages)<<endl;
          if(CV_depvar_b==0) echoinput<<"CV   "<<CV_G(gp,ALK_idx)(0,min(6,nages))<<" @nages "<<CV_G(gp,ALK_idx,nages)<<endl;
          echoinput<<"sd   "<<Sd_Size_within(ALK_idx,g)(0,min(6,nages))<<" @nages "<<Sd_Size_within(ALK_idx,g,nages)<<endl;
        }

//  end sd_within updating          

          for (gp2=1;gp2<=N_platoon;gp2++)      // loop the platoons
          {
            g=gstart+ishadow(gp2);

            use_Ave_Size_W=Ave_Size(t,subseas,gstart);
            use_SD_Size=Sd_Size_within(ALK_idx,gstart);
            if(N_platoon>1) 
            	{
            		use_Ave_Size_W += shadow(gp2)*Sd_Size_between(ALK_idx,gstart);
            		Ave_Size(t,subseas,g)=use_Ave_Size_W;  // only needed for reporting because use_Ave_Size_W used for calcs
            		Sd_Size_within(ALK_idx,g)=use_SD_Size; //  ditto; also same sd is used for all platoons
            	}

            int ALK_phase=0;
            if(Grow_logN==0)
            {
              int ALK_finder=(ALK_idx-1)*gmorph+g;
              if( (do_once==1 || (current_phase()>ALK_phase)) && !last_phase() )
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
  int a, z=0;  // declare indices
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
//  ALK_count++;
  ALK_w.initialize();
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
    ALK_w(a,1)+=AL(1);  //  because first bin is from cumulative calc
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

