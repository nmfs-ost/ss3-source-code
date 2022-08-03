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
