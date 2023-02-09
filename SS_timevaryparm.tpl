// SS_Label_file  #21. **SS_timevaryparm.tpl**
// SS_Label_file  # * <u>make_timevaryparm()</u>  // makes parameters a function of input environmental data time series
// SS_Label_file  # * <u>make_densitydependent_parm()</u>  // for the current year, changes a parameter value as a function of summary bio or recruitment at beginning of this year
// SS_Label_file  #

//*********************************************************************
 /*  SS_Label_Function_14 #make_timevaryparm():  create trend and block time series */
FUNCTION void make_timevaryparm()
  {
  dvariable baseparm;
  baseparm_min = -999.;  //  fill array with default
  baseparm_max = 999;  //  fill array with default
  dvariable endtrend;
  dvariable infl_year;
  dvariable slope;
  dvariable norm_styr;
  //  note:  need to implement the approach that keeps within bounds of base parameter

  int timevary_parm_cnt_all;
  timevary_parm_cnt_all = 0;
  if (do_once == 1)
    echoinput << endl
              << "**********************" << endl
              << "number of parameters with timevary:  " << timevary_cnt << endl;

  for (int tvary = 1; tvary <= timevary_cnt; tvary++)
  {
    ivector timevary_setup(1, 14);
    timevary_setup(1, 14) = timevary_def[tvary](1, 14);
    if (do_once == 1)
      echoinput << "timevary #: " << tvary << endl
                << "setup:  " << timevary_setup << endl;
    //  what type of parameter is being affected?  get the baseparm and its bounds
    switch (timevary_setup(1)) //  parameter type
    {
      case 1: // MG
      {
        baseparm = MGparm(timevary_setup(2)); //  index of base parm
        baseparm_min(tvary) = MGparm_LO(timevary_setup(2));
        baseparm_max(tvary) = MGparm_HI(timevary_setup(2));
        if (do_once == 1)
          echoinput << "base MGparm " << baseparm << endl;
        for (j = timevary_setup(3); j < timevary_def[tvary + 1](3); j++)
        {
          timevary_parm_cnt_all++;
          timevary_parm(timevary_parm_cnt_all) = MGparm(N_MGparm + j);
          if (do_once == 1)
            echoinput << j << " timevary_parm: " << timevary_parm(timevary_parm_cnt_all) << endl;
        }
        parm_timevary(tvary) = baseparm; //  fill timeseries with base parameter, just in case
        break;
      }
      case 2: // SR
      {
        baseparm = SR_parm(timevary_setup(2)); //  index of base parm
        baseparm_min(tvary) = SR_parm_LO(timevary_setup(2));
        baseparm_max(tvary) = SR_parm_HI(timevary_setup(2));
        if (do_once == 1)
          echoinput << "base SR_parm " << baseparm << endl;
        for (j = timevary_setup(3); j < timevary_def[tvary + 1](3); j++)
        {
          timevary_parm_cnt_all++;
          timevary_parm(timevary_parm_cnt_all) = SR_parm(N_SRparm(SR_fxn) + 3 + j - timevary_parm_start_SR + 1);
          if (do_once == 1)
            echoinput << j << " timevary_parm: " << timevary_parm(timevary_parm_cnt_all) << endl;
        }
        parm_timevary(tvary) = baseparm; //  fill timeseries with base parameter, just in case
        break;
      }
      case 3: // Q
      {
        baseparm = Q_parm(timevary_setup(2)); //  index of base parm
        baseparm_min(tvary) = Q_parm_LO(timevary_setup(2));
        baseparm_max(tvary) = Q_parm_HI(timevary_setup(2));
        if (do_once == 1)
          echoinput << "base Qparm " << baseparm << endl;
        for (j = timevary_setup(3); j < timevary_def[tvary + 1](3); j++)
        {
          timevary_parm_cnt_all++;
          timevary_parm(timevary_parm_cnt_all) = Q_parm(Q_Npar + j - timevary_parm_start_Q + 1);
          if (do_once == 1)
            echoinput << j << " timevary_parm: " << timevary_parm(timevary_parm_cnt_all) << endl;
        }
        parm_timevary(tvary) = baseparm; //  fill timeseries with base parameter, just in case
        break;
      }
      case 5: // selex
      {
        baseparm = selparm(timevary_setup(2)); //  index of base parm
        baseparm_min(tvary) = selparm_LO(timevary_setup(2));
        baseparm_max(tvary) = selparm_HI(timevary_setup(2));
        if (do_once == 1)
          echoinput << "base selparm " << baseparm << endl;
        for (j = timevary_setup(3); j < timevary_def[tvary + 1](3); j++)
        {
          timevary_parm_cnt_all++;
          timevary_parm(timevary_parm_cnt_all) = selparm(N_selparm + j - timevary_parm_start_sel + 1);
          if (do_once == 1)
            echoinput << j << " timevary_parm: " << timevary_parm(timevary_parm_cnt_all) << endl;
        }
        parm_timevary(tvary) = baseparm; //  fill timeseries with base parameter, just in case
        break;
      }
    }

    timevary_parm_cnt = timevary_setup(3); //  first  parameter used to create timevary effect on baseparm
    if (timevary_setup(4) > 0) //  block
    {
      if (do_once == 1)
        echoinput << "block pattern " << z << endl;
      z = timevary_setup(4); // specified block pattern
      g = 1;
      temp = baseparm;
      for (a = 1; a <= Nblk(z); a++)
      {
        switch (timevary_setup(5))
        {
          case 0:
          {
            temp = baseparm * mfexp(timevary_parm(timevary_parm_cnt));
            timevary_parm_cnt++;
            break;
          }
          case 1:
          {
            temp = baseparm + timevary_parm(timevary_parm_cnt);
            timevary_parm_cnt++;
            break;
          }
          case 2:
          {
            temp = timevary_parm(timevary_parm_cnt); //  direct assignment of block value
            timevary_parm_cnt++;
            break;
          }
          case 3:
          {
            temp += timevary_parm(timevary_parm_cnt); //  block as offset from previous block
            timevary_parm_cnt++;
            break;
          }
        }

        for (int y1 = Block_Design(z, g); y1 <= Block_Design(z, g + 1); y1++) // loop years for this block
        {
          parm_timevary(tvary, y1) = temp;
        }
        g += 2;
      }
      //        timevary_parm_cnt--;    // back out last increment
    } // end uses blocks

    else if (timevary_setup(4) < 0) //  trend
    {
      // timevary_parm(timevary_parm_cnt+0) = offset for the trend at endyr; 3 options available below
      // timevary_parm(timevary_parm_cnt+1) = inflection year; 2 options available
      // timevary_parm(timevary_parm_cnt+2) = stddev of normal at inflection year
      //  calc endyr value,
      if (do_once == 1)
        echoinput << "logistic trend over time " << endl;
      if (timevary_setup(4) == -1) // use logistic transform to keep with bounds of the base parameter
      {
        endtrend = log((baseparm_max(tvary) - baseparm_min(tvary) + 0.0000002) / (baseparm - baseparm_min(tvary) + 0.0000001) - 1.) / (-2.); // transform the base parameter
        endtrend += timevary_parm(timevary_parm_cnt); //  add the offset  Note that offset value is in the transform space
        endtrend = baseparm_min(tvary) + (baseparm_max(tvary) - baseparm_min(tvary)) / (1. + mfexp(-2. * endtrend)); // backtransform
        infl_year = log(0.5) / (-2.); // transform the base parameter
        infl_year += timevary_parm(timevary_parm_cnt + 1); //  add the offset  Note that offset value is in the transform space
        infl_year = r_years(styr) + (r_years(endyr) - r_years(styr)) / (1. + mfexp(-2. * infl_year)); // backtransform
      }
      else if (timevary_setup(4) == -2) // set ending value directly
      {
        endtrend = timevary_parm(timevary_parm_cnt);
        infl_year = timevary_parm(timevary_parm_cnt + 1);
      }
      else if (timevary_setup(4) == -3) // use parm as fraction of way between bounds
      {
        endtrend = baseparm_min(tvary) + (baseparm_max(tvary) - baseparm_min(tvary)) * timevary_parm(timevary_parm_cnt);
        infl_year = r_years(styr) + (r_years(endyr) - r_years(styr)) * timevary_parm(timevary_parm_cnt + 1);
      }
      slope = timevary_parm(timevary_parm_cnt + 2);
      timevary_parm_cnt += 3;

      norm_styr = cumd_norm((r_years(styr) - infl_year) / slope);
      temp = (endtrend - baseparm) / (cumd_norm((r_years(endyr) - infl_year) / slope) - norm_styr); //  delta in cum_norm between styr and endyr

      for (int y1 = styr; y1 <= YrMax; y1++)
      {
        if (y1 <= endyr)
        {
          parm_timevary(tvary, y1) = baseparm + temp * (cumd_norm((r_years(y1) - infl_year) / slope) - norm_styr);
        }
        else
        {
          parm_timevary(tvary, y1) = parm_timevary(tvary, endyr);
        }
      }
      parm_timevary(tvary, styr - 1) = baseparm;
    }

    if (timevary_setup(7) > 0) //  env link (negative value indicates density-dependence which is calculated year-by-year in different function)
    {
      if (do_once == 1)
        echoinput << "env_link to env_variable: " << timevary_setup(7) << "  using link_type " << timevary_setup(6) << endl;
      switch (int(timevary_setup(6)))
      {
        case 1: //  exponential  env link
        {
          for (int y1 = styr - 1; y1 <= YrMax; y1++)
          {
            parm_timevary(tvary, y1) *= mfexp(timevary_parm(timevary_parm_cnt) * (env_data(y1, timevary_setup(7))));
          }
          timevary_parm_cnt++;
          break;
        }
        case 2: //  linear  env link
        {
          for (int y1 = styr - 1; y1 <= YrMax; y1++)
          {
            parm_timevary(tvary, y1) += timevary_parm(timevary_parm_cnt) * env_data(y1, timevary_setup(7));
          }
          timevary_parm_cnt++;
          break;
        }
        case 3: //  result constrained by baseparm_min-max; input values are unit normal
        {
          dvariable temp;
          double p_range = baseparm_max(tvary) - baseparm_min(tvary);

          for (int y1 = env_data_minyr(timevary_setup(7)); y1 <= env_data_maxyr(timevary_setup(7)); y1++)
          {
            temp = log((parm_timevary(tvary, y1) - baseparm_min(tvary) + 1.0e-7) / (baseparm_max(tvary) - parm_timevary(tvary, y1) + 1.0e-7));
            temp += timevary_parm(timevary_parm_cnt) * env_data(y1, timevary_setup(7));
            parm_timevary(tvary, y1) = baseparm_min(tvary) + p_range / (1.0 + exp(-temp));
          }
          timevary_parm_cnt++;
          break;
        }
        case 4: //  logistic env link
        {
          // first parm is offset; second is slope
          for (int y1 = styr - 1; y1 <= YrMax; y1++)
          {
            parm_timevary(tvary, y1) *= 2.00000 / (1.00000 + mfexp(-timevary_parm(timevary_parm_cnt + 1) * (env_data(y1, timevary_setup(7)) - timevary_parm(timevary_parm_cnt))));
          }
          timevary_parm_cnt += 2;
          break;
        }
      }
    }
    //  SS_Label_Info_14.3 #Create parm dev randwalks if needed
    if (timevary_setup(8) > 0) //  devs
    {
      k = timevary_setup(8); //  dev used
      if (do_once == 1)
        echoinput << "dev vector #: " << k << endl;
      parm_dev_stddev(k) = timevary_parm(timevary_parm_cnt);
      parm_dev_rho(k) = timevary_parm(timevary_parm_cnt + 1);
      int picker = timevary_setup(9);  //  selects the method for creating time-vary parameter from dev vector

      switch (picker)
      {
        case 1:
        {
          for (j = timevary_setup(10); j <= timevary_setup(11); j++)
          {
            parm_timevary(tvary, j) *= mfexp(parm_dev(k, j) * parm_dev_stddev(k));
          }
          break;
        }
        case 2:
        {
          for (j = timevary_setup(10); j <= timevary_setup(11); j++)
          {
            parm_timevary(tvary, j) += parm_dev(k, j) * parm_dev_stddev(k);
          }
          break;
        }
        case 3:
        {
          parm_dev_rwalk(k, timevary_setup(10)) = parm_dev(k, timevary_setup(10)) * parm_dev_stddev(k);
          parm_timevary(tvary, timevary_setup(10)) += parm_dev_rwalk(k, timevary_setup(10));
          for (j = timevary_setup(10) + 1; j <= timevary_setup(11); j++)
          {
            parm_dev_rwalk(k, j) = parm_dev_rwalk(k, j - 1) + parm_dev(k, j) * parm_dev_stddev(k);
            parm_timevary(tvary, j) += parm_dev_rwalk(k, j);
          }
          break;
        }
        case 4: // mean reverting random walk
        {
          parm_dev_rwalk(k, timevary_setup(10)) = parm_dev(k, timevary_setup(10)) * parm_dev_stddev(k); //  1st yr dev
          parm_timevary(tvary, timevary_setup(10)) += parm_dev_rwalk(k, timevary_setup(10)); //  add dev to current value
          for (j = timevary_setup(10) + 1; j <= timevary_setup(11); j++)
          {
            //    =(1-rho)*mean + rho*prevval + dev   //  where mean = 0.0
            parm_dev_rwalk(k, j) = parm_dev_rho(k) * parm_dev_rwalk(k, j - 1) + parm_dev(k, j) * parm_dev_stddev(k); //  update MRRW using annual dev
            parm_timevary(tvary, j) += parm_dev_rwalk(k, j); //  add dev to current value of annual parameter, which may previously be adjusted by block or env
          }
          break;
        }
        case 6: // mean reverting random walk with penalty to keep rmse near 1.0
        {
          parm_dev_rwalk(k, timevary_setup(10)) = parm_dev(k, timevary_setup(10)) * parm_dev_stddev(k); //  1st yr dev
          parm_timevary(tvary, timevary_setup(10)) += parm_dev_rwalk(k, timevary_setup(10)); //  add dev to current value
          for (j = timevary_setup(10) + 1; j <= timevary_setup(11); j++)
          {
            //    =(1-rho)*mean + rho*prevval + dev   //  where mean = 0.0
            parm_dev_rwalk(k, j) = parm_dev_rho(k) * parm_dev_rwalk(k, j - 1) + parm_dev(k, j) * parm_dev_stddev(k); //  update MRRW using annual dev
            parm_timevary(tvary, j) += parm_dev_rwalk(k, j); //  add dev to current value of annual parameter, which may previously be adjusted by block or env
          }
          break;
        }
        case 5: // mean reverting random walk constrained by base parameter's min-max:
        {
          //          NOTE:  if the stddev parameter is greater than 1.8, the distribution of adjusted parameters will become U-shaped
          dvariable temp;
          double p_range = baseparm_max(tvary) - baseparm_min(tvary);
          int j = timevary_setup(10);
          parm_dev_rwalk(k, j) = parm_dev(k, j) * parm_dev_stddev(k); //  1st yr dev
          //            p_base=(parm_timevary(tvary,j)-baseparm_min(tvary))/(baseparm_max(tvary)-baseparm_min(tvary));  //  convert parm to (0,1) scale
          //            temp=log(p_base/(1.-p_base)) + parm_dev_rwalk(k,j);  //  convert to logit and add dev; so dev must be in units of the logit
          temp = log((parm_timevary(tvary, j) - baseparm_min(tvary) + 1.0e-7) / (baseparm_max(tvary) - parm_timevary(tvary, j) + 1.0e-7));
          parm_timevary(tvary, j) = baseparm_min(tvary) + p_range / (1.0 + exp(-temp - parm_dev_rwalk(k, j)));
          for (j = timevary_setup(10) + 1; j <= timevary_setup(11); j++)
          {
            //    =(1-rho)*mean + rho*prevval + dev   //  where mean = 0.0
            parm_dev_rwalk(k, j) = parm_dev_rho(k) * parm_dev_rwalk(k, j - 1) + parm_dev(k, j) * parm_dev_stddev(k); //  update MRRW using annual dev
            temp = log((parm_timevary(tvary, j) - baseparm_min(tvary) + 1.0e-7) / (baseparm_max(tvary) - parm_timevary(tvary, j) + 1.0e-7));
            parm_timevary(tvary, j) = baseparm_min(tvary) + p_range / (1.0 + exp(-temp - parm_dev_rwalk(k, j)));
          }
          break;
        }
      }
      if (timevary_setup(14) == 1) //  continue_last
      {
        for (j = timevary_setup(11) + 1; j <= YrMax; j++)
          parm_timevary(tvary, j) = parm_timevary(tvary, timevary_setup(11));
      }
    }
    if (do_once == 1)
      echoinput << "result by year: " << parm_timevary(tvary) << endl;
  }
  } //  end timevary_parm setup for all years

FUNCTION void make_densitydependent_parm(int const y1)
  {

  for (int tvary = 1; tvary <= timevary_cnt; tvary++)
  {
    ivector timevary_setup(1, 13);
    timevary_setup(1, 13) = timevary_def[tvary](1, 13);
    if (timevary_setup(7) < 0) //  density-dependent
    {
      int env_var = timevary_setup(7);
      timevary_parm_cnt = timevary_setup(3); //  link parameter index
      if (do_once == 1)
        echoinput << y1 << "  density-dependent to env_variable: " << env_var << "  using link_type "
         << timevary_setup(6) << "  env: " << env_data(y1, env_var) << "  parm: " << timevary_parm(timevary_parm_cnt) << endl;
      switch (int(timevary_setup(6)))
      {
        case 1: //  exponential  env link
        {
          parm_timevary(tvary, y1) *= mfexp(timevary_parm(timevary_parm_cnt) * env_data(y1, env_var));
          break;
        }
        case 2: //  linear  env link
        {
          parm_timevary(tvary, y1) += timevary_parm(timevary_parm_cnt) * env_data(y1, env_var);
          break;
        }
        case 3: //  result constrained by baseparm_min-max; input values are unit normal
        {
          dvariable temp;
          double p_range = baseparm_max(tvary) - baseparm_min(tvary);
          temp = log((parm_timevary(tvary, y1) - baseparm_min(tvary) + 1.0e-7) / (baseparm_max(tvary) - parm_timevary(tvary, y1) + 1.0e-7));
          temp += timevary_parm(timevary_parm_cnt) * env_data(y1, env_var);
          parm_timevary(tvary, y1) = baseparm_min(tvary) + p_range / (1.0 + exp(-temp));
          break;
        }
        case 4: //  logistic env link
        {
          // first parm is offset ; second is slope
          parm_timevary(tvary, y1) = 2.00000 / (1.00000 + mfexp(-timevary_parm(timevary_parm_cnt + 1) * (env_data(y1, env_var) - timevary_parm(timevary_parm_cnt))));
          break;
        }
      }
    }
  }
  }

