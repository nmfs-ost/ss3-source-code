// SS_Label_file  #10. **SS_miscfxn.tpl**
// SS_Label_file  # * <u>Join_Fxn()</u>    //  joins line segments in differentiable way
// SS_Label_file  # * <u>get_age_age()</u>  //  for ageing error
// SS_Label_file  # * <u>get_catch_mult()</u>
// SS_Label_file  #

//********************************************************************
 /*  SS_Label_FUNCTION 42 Join_Fxn  */
FUNCTION dvariable Join_Fxn(const prevariable& MinPoss, const prevariable& MaxPoss, const prevariable& Inflec, const prevariable& Xvar, const prevariable& Y1, const prevariable& Y2)
  {
  RETURN_ARRAYS_INCREMENT();
  dvariable Yresult;
  dvariable join;
  join = 1.000 / (1.000 + mfexp(1000.0 * (Xvar - Inflec) / (MaxPoss - MinPoss))); //  steep joiner at the inflection
  Yresult = Y1 * (join) + Y2 * (1.000 - join);
  RETURN_ARRAYS_DECREMENT();
  return Yresult;
  }

//********************************************************************
 /*  SS_Label_FUNCTION 45 get_age_age */
FUNCTION void get_age_age(const int Keynum, const int AgeKey_StartAge, const int AgeKey_Linear1, const int AgeKey_Linear2)
  {
  //  FUTURE: calculate adjustment to oldest age based on continued ageing of old fish
  age_age(Keynum).initialize();
  dvariable age;
  dvar_vector age_err_parm(1, 7);
  dvariable temp;

  if (Keynum == Use_AgeKeyZero)
  {
    //  SS_Label_45.1 set age_err_parm to mgp_adj, so can be time-varying according to MGparm options
    for (a = 1; a <= 7; a++)
    {
      age_err_parm(a) = mgp_adj(AgeKeyParm - 1 + a);
    }
    age_err(Use_AgeKeyZero, 1)(0, AgeKey_StartAge) = r_ages(0, AgeKey_StartAge) + 0.5;
    age_err(Use_AgeKeyZero, 2)(0, AgeKey_StartAge) = age_err_parm(5) * (r_ages(0, AgeKey_StartAge) + 0.5) / (age_err_parm(1) + 0.5);
    //  SS_Label_45.3 calc ageing bias
    if (AgeKey_Linear1 == 0)
    {
      age_err(Use_AgeKeyZero, 1)(AgeKey_StartAge, nages) = 0.5 + r_ages(AgeKey_StartAge, nages) + age_err_parm(2) + (age_err_parm(3) - age_err_parm(2)) * (1.0 - mfexp(-age_err_parm(4) * (r_ages(AgeKey_StartAge, nages) - age_err_parm(1)))) / (1.0 - mfexp(-age_err_parm(4) * (r_ages(nages) - age_err_parm(1))));
    }
    else
    {
      age_err(Use_AgeKeyZero, 1)(AgeKey_StartAge, nages) = 0.5 + r_ages(AgeKey_StartAge, nages) + age_err_parm(2) + (age_err_parm(3) - age_err_parm(2)) * (r_ages(AgeKey_StartAge, nages) - age_err_parm(1)) / (r_ages(nages) - age_err_parm(1));
    }
    //  SS_Label_45.4 calc ageing variance
    if (AgeKey_Linear2 == 0)
    {
      age_err(Use_AgeKeyZero, 2)(AgeKey_StartAge, nages) = age_err_parm(5) + (age_err_parm(6) - age_err_parm(5)) * (1.0 - mfexp(-age_err_parm(7) * (r_ages(AgeKey_StartAge, nages) - age_err_parm(1)))) / (1.0 - mfexp(-age_err_parm(7) * (r_ages(nages) - age_err_parm(1))));
    }
    else
    {
      age_err(Use_AgeKeyZero, 2)(AgeKey_StartAge, nages) = age_err_parm(5) + (age_err_parm(6) - age_err_parm(5)) * (r_ages(AgeKey_StartAge, nages) - age_err_parm(1)) / (r_ages(nages) - age_err_parm(1));
    }
  }

  //  SS_Label_45.5 calc distribution of age' for each age
  for (a = 0; a <= nages; a++)
  {
    if (age_err(Keynum, 1, a) <= -1)
    {
      age_err(Keynum, 1, a) = r_ages(a) + 0.5;
    }
    age = age_err(Keynum, 1, a);

    for (b = 2; b <= n_abins; b++) //  so the lower tail is accumulated into the first age' bin
      age_age(Keynum, b, a) = cumd_norm((age_bins(b) - age) / age_err(Keynum, 2, a));

    for (b = 1; b <= n_abins - 1; b++)
      age_age(Keynum, b, a) = age_age(Keynum, b + 1, a) - age_age(Keynum, b, a);

    age_age(Keynum, n_abins, a) = 1. - age_age(Keynum, n_abins, a); // so remainder is accumulated into the last age' bin
  }

  if (gender == 2) //  copy ageing error matrix into male location also
  {
    L2 = n_abins;
    A2 = nages + 1;
    for (b = 1; b <= n_abins; b++)
      for (a = 0; a <= nages; a++)
      {
        age_age(Keynum, b + L2, a + A2) = age_age(Keynum, b, a);
      }
  }
  return;
  } //  end age_age key

FUNCTION void get_catch_mult(int y, int catch_mult_pointer)
  {
  /*  SS_Label_FUNCTION 47  catch_multiplier */
  int j;
  j = 0;
  for (f = 1; f <= Nfleet; f++)
  {
    if (need_catch_mult(f) == 1)
    {
      catch_mult(y, f) = mgp_adj(catch_mult_pointer + j);
      j++;
    }
  }
  return;
  }

//********************************************************************
 /*  SS_Label_FUNCTION 4XX Comp_logL  */
FUNCTION dvariable Comp_logL_multinomial(const double& Nsamp, const dvector& obs_comp, const dvar_vector& exp_comp)
  {
    dvariable logL;
//    logL = - Nsamp * obs_comp(tail_L, tail_H) * log(exp_comp(tail_L, tail_H));
//    the call to this function does the subsetting to tail_L and tail_H, so this function can operate cleanly on the entirety of the passed vector
    logL = - Nsamp * obs_comp * log(exp_comp);
    return (logL);
  }

FUNCTION dvariable Comp_logL_Dirichlet(const double& Nsamp, const dvariable& dirichlet_Parm, const dvector& obs_comp, const dvar_vector& exp_comp)
  {
    dvariable logL;
    logL = sum(gammln(Nsamp * obs_comp + dirichlet_Parm * exp_comp)) - sum(gammln(dirichlet_Parm * exp_comp));
    return (logL);
  }

  
FUNCTION dvar_vector rebin(const dvector& src_edges, const dvar_vector& src_counts, const dvar_vector& dest_edges)
  {
    /*
    This implementation takes two vectors representing the boundaries (edges) of the source
    and destination bins, and one vector for the source counts.

    Rebins frequency data from one set of boundaries to another.
    @param src_edges Boundaries of the original bins (size N+1).
    @param src_counts Frequency/counts in original bins (size N).
    @param dest_edges Boundaries of the new bins (size M+1).
    @return Vector of rebinned frequency data (size M).
    src_counts need not be counts; works for real number of fish, or for biomass of fish.
    However, if src_counts are in biomass units, this rebin method does not account for fact that fish in lower portion of a src bin
       will weigh less than fish in upper portion.
    the original code searched all source bins for each destination bins.
    Here the ordered characteristic of the bins allows for the search for bin (i+1) to continue from search for bin(i).
    */

    dvar_vector dest_counts(1, dest_edges.size() - 1);  // size to leave off the topbin bounary
    dest_counts.initialize();
    int j_start = 1;
    for (int i = 1; i <= dest_counts.size(); i++) {
        dvariable d_low = dest_edges[i];
        dvariable d_high = dest_edges[i + 1];

        // Advance j_start if the source bin is entirely below the current destination bin.
        // Because d_low increases with 'i', j_start only ever moves forward.
        while (j_start <= src_counts.size() && src_edges[j_start + 1] <= d_low) {
            j_start++;
        }

        // Iterate through source bins starting from j_start, but stop as soon 
        // as the source bin is completely above the current destination bin.
        for (int j = j_start; j <= src_counts.size() && src_edges[j] < d_high; j++) {
            dvariable s_low = src_edges[j];
            dvariable s_high = src_edges[j + 1];
            // Calculate the overlap bounds
            dvariable overlap_low = d_low;
            if (s_low > d_low) overlap_low = s_low;
            
            dvariable overlap_high = d_high;
            if (s_high < d_high) overlap_high = s_high;
//            echoinput<<"rebin: dest: "<<i<<" "<<dest_edges[i]<<" src: "<<j<<" "<<src_edges[j]<<" overlap_lo "<<overlap_low <<" overlap_hi "<<overlap_high <<  endl;

            // If there is valid overlap, distribute the counts
            if (overlap_low < overlap_high) {
                dvariable overlap_width = overlap_high - overlap_low;
                dvariable src_bin_width = s_high - s_low;
                dest_counts[i] += src_counts[j] * (overlap_width / src_bin_width);
//                echoinput<<"add src to dest: "<<dest_edges[i]<<" "<<src_edges[j]<<" result: "<<(overlap_width / src_bin_width)<<endl;
            }
        }
      }
    return (dest_counts);
  }

FUNCTION dvar_vector rebin_bio(const dvector& src_edges, const dvar_vector& src_counts, const dvar_vector& dest_edges, const dvar_vector& src_edges_wt, const dvar_vector& dest_edges_wt )
  {
    /*
    This modification of rebin is used when biomass is accumulated into the bins
    for example, with catch weight composition
    it takes into account the fact that fish in the lower portion of a length bin have less body weight than fish in the opper portion of the length bin
    NOTE:  need to undo the conversion of numbers to biomass in SS_expval.  It needs to occur here.
    legacy szfreq method used this approach:
      temp = (wt_len_low(s, 1, z + 1) - topbin) / wt_len_fd(s, 1, z); // frac in pop bin above (data bin +1)
      temp1 = wt_len_low(s, 1, z) + (1. - temp * 0.5) * wt_len_fd(s, 1, z); // approx body wt for these fish
      temp2 = wt_len_low(s, 1, z) + (1. - temp) * 0.5 * wt_len_fd(s, 1, z); // approx body wt for  fish below
      SzFreqTrans(SzFreqMethod_seas, z, ibinsave + 1) = temp * temp1;
      SzFreqTrans(SzFreqMethod_seas, z, ibinsave) = (1. - temp) * temp2;
    new approach has access to the body wt at boundaries of size range of fish getting rebinned, so will use that to get more exact body weights
    */
    dvar_vector dest_counts(1, dest_edges.size() - 1);  // sized to leave off the topbin boundary
    dest_counts.initialize();
    int j_start = 1;
    for (int i = 1; i <= dest_counts.size(); i++) {  // loop the destination bins
        dvariable d_low = dest_edges[i];
        dvariable d_high = dest_edges[i + 1];
        // Advance j_start if the source bin is entirely below the current destination bin.
        // Because d_low increases with 'i', j_start only ever moves forward.
        while (j_start <= src_counts.size() && src_edges[j_start + 1] <= d_low) {
            j_start++;
        }
        // Iterate through source bins starting from j_start, but stop as soon 
        // as the source bin is completely above the current destination bin.
        for (int j = j_start; j <= src_counts.size() && src_edges[j] < d_high; j++) {
          dvariable s_low = src_edges[j];
          dvariable s_high = src_edges[j + 1];
          // Calculate the overlap bounds
          dvariable overlap_low = d_low;
          if (s_low > d_low) overlap_low = s_low;
          
          dvariable overlap_high = d_high;
          if (s_high < d_high) overlap_high = s_high;

          // If there is valid overlap, distribute the counts
          if (overlap_low < overlap_high) {
            dvariable overlap_width = overlap_high - overlap_low;
            dvariable src_bin_width = s_high - s_low;

            // get mean weight of fish in range of src being assigned to dest
            // d_low and d_high are the original weight bin boundaries (assumes the weight comp data always uses weight bin boundaries)
            // s_low and s_high have weights stored in wt_len_low(s,GPat)
            //  src_edges_wt, dest_edges_wt
            dvariable mean_szwt;  // body weight of fish to be allocated from src to dest
            if (s_low >= d_low)
            {
              if (s_high <= d_high)  // src entirely in dest range range
                {mean_szwt = (src_edges_wt[j] + src_edges_wt[j+1]) * 0.5;}
              else //  s_high > d_high; calc mean size from s_low and d_high
                {mean_szwt = (src_edges_wt[j] + dest_edges_wt[i+1]) * 0.5;}
            }
            else if (s_high <= d_high )  // overlap with s_low < d_low; calc the mean size from d_low and s_high 
              {mean_szwt = (dest_edges_wt[i] + src_edges_wt[j+1]) * 0.5;}
            else  // s_high > d_high, so dest bin is internal to src_bin
              {mean_szwt = (dest_edges_wt[i] + dest_edges_wt[i+1]) * 0.5;}

              dest_counts[i] += src_counts[j] * mean_szwt * (overlap_width / src_bin_width);  // add overlap fraction of biomass to dest
            //  echoinput<<" src: "<<j<<" lo_hi "<<s_low << " "<<s_high<<" dest: "<<i<<" lo_hi "<<d_low<<" "<<d_high<<" overlap: "<<overlap_low <<" "<<overlap_high
            //  <<" fraction: "<<(overlap_width / src_bin_width)<<" mean: "<<mean_szwt<<endl;
          }  // end having overlap to be allocated
        }  // end j loop of source bins
      }
    return (dest_counts);
  }