//********************************************************************
 /*  SS_Label_FUNCTION 42 Join_Fxn  */
FUNCTION dvariable Join_Fxn(const prevariable& MinPoss, const prevariable& MaxPoss, const prevariable& Inflec, const prevariable& Xvar, const prevariable& Y1, const prevariable& Y2)
  {
    RETURN_ARRAYS_INCREMENT();
  dvariable Yresult;
  dvariable join;
  join=1.000/(1.000+mfexp(1000.0*(Xvar-Inflec)/(MaxPoss-MinPoss)));  //  steep joiner at the inflection
  Yresult=Y1*(join)+Y2*(1.000-join);
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
    dvar_vector AgeKey_parm(1,7);
    dvariable temp;

  if(Keynum==Use_AgeKeyParm)
  {
//  SS_Label_45.1 set AgeKey_parm to mgp_adj, so can be time-varying according to MGparm options
    for (a=1;a<=7;a++)
    {AgeKey_parm(a)=mgp_adj(AgeKeyParm-1+a);}
      AgeKey(Use_AgeKeyParm,1)(0,AgeKey_StartAge)=r_ages(0,AgeKey_StartAge)+0.5;
      AgeKey(Use_AgeKeyParm,2)(0,AgeKey_StartAge)=AgeKey_parm(5)*(r_ages(0,AgeKey_StartAge)+0.5)/(AgeKey_parm(1)+0.5);
//  SS_Label_45.3 calc ageing bias
      if(AgeKey_Linear1==0)
      {
        AgeKey(Use_AgeKeyParm,1)(AgeKey_StartAge,nages)=0.5 + r_ages(AgeKey_StartAge,nages) + AgeKey_parm(2)+(AgeKey_parm(3)-AgeKey_parm(2))*
        (1.0-mfexp(-AgeKey_parm(4)*(r_ages(AgeKey_StartAge,nages)-AgeKey_parm(1)))) / (1.0-mfexp(-AgeKey_parm(4)*(r_ages(nages)-AgeKey_parm(1))));
      }
      else
      {
        AgeKey(Use_AgeKeyParm,1)(AgeKey_StartAge,nages)=0.5 + r_ages(AgeKey_StartAge,nages) + AgeKey_parm(2)+(AgeKey_parm(3)-AgeKey_parm(2))*
        (r_ages(AgeKey_StartAge,nages)-AgeKey_parm(1))/(r_ages(nages)-AgeKey_parm(1));
      }
//  SS_Label_45.4 calc ageing variance
      if(AgeKey_Linear2==0)
      {
        AgeKey(Use_AgeKeyParm,2)(AgeKey_StartAge,nages)=AgeKey_parm(5)+(AgeKey_parm(6)-AgeKey_parm(5))*
        (1.0-mfexp(-AgeKey_parm(7)*(r_ages(AgeKey_StartAge,nages)-AgeKey_parm(1)))) / (1.0-mfexp(-AgeKey_parm(7)*(r_ages(nages)-AgeKey_parm(1))));
      }
      else
      {
        AgeKey(Use_AgeKeyParm,2)(AgeKey_StartAge,nages)=AgeKey_parm(5)+(AgeKey_parm(6)-AgeKey_parm(5))*
        (r_ages(AgeKey_StartAge,nages)-AgeKey_parm(1))/(r_ages(nages)-AgeKey_parm(1));
      }
  }

//  SS_Label_45.5 calc distribution of age' for each age
   for (a=0; a<=nages;a++)
    {
     if(AgeKey(Keynum,1,a)<=-1)
       {AgeKey(Keynum,1,a)=r_ages(a)+0.5;}
     age=AgeKey(Keynum,1,a);

     for (b=2;b<=n_abins;b++)     //  so the lower tail is accumulated into the first age' bin
     age_age(Keynum,b,a)= cumd_norm((age_bins(b)-age)/AgeKey(Keynum,2,a));

     for (b=1;b<=n_abins-1;b++)
       age_age(Keynum,b,a) = age_age(Keynum,b+1,a)-age_age(Keynum,b,a);

     age_age(Keynum,n_abins,a) = 1.-age_age(Keynum,n_abins,a) ;     // so remainder is accumulated into the last age' bin

    }

     if(gender == 2)                     //  copy ageing error matrix into male location also
     {
      L2=n_abins;
      A2=nages+1;
      for (b=1;b<=n_abins;b++)
      for (a=0;a<=nages;a++)
       {age_age(Keynum,b+L2,a+A2)=age_age(Keynum,b,a);}
     }
    return;
  }  //  end age_age key

//********************************************************************
 /*  SS_Label_FUNCTION 45 get_age_age advanced version*/
FUNCTION void get_age_age2(const int Keynum, const int AgeKey_StartAge, const int AgeKey_Linear1, const int AgeKey_Linear2)
  {
   //  FUTURE: calculate adjustment to oldest age based on continued ageing of old fish
    age_age(Keynum).initialize();
    dvariable age;
    dvar_vector AgeKey_parm(1,7);
    dvariable temp;

  if(Keynum==Use_AgeKeyParm)
  {
//  SS_Label_45.1 set AgeKey_parm to mgp_adj, so can be time-varying according to MGparm options
    for (a=1;a<=7;a++)
    {AgeKey_parm(a)=mgp_adj(AgeKeyParm-1+a);}
      AgeKey(Use_AgeKeyParm,1)(0,AgeKey_StartAge)=r_ages(0,AgeKey_StartAge)+0.5;
      AgeKey(Use_AgeKeyParm,2)(0,AgeKey_StartAge)=AgeKey_parm(5)*(r_ages(0,AgeKey_StartAge)+0.5)/(AgeKey_parm(1)+0.5);
//  SS_Label_45.3 calc ageing bias
      if(AgeKey_Linear1==0)
      {
        AgeKey(Use_AgeKeyParm,1)(AgeKey_StartAge,nages)=0.5 + r_ages(AgeKey_StartAge,nages) + AgeKey_parm(2)+(AgeKey_parm(3)-AgeKey_parm(2))*
        (1.0-mfexp(-AgeKey_parm(4)*(r_ages(AgeKey_StartAge,nages)-AgeKey_parm(1)))) / (1.0-mfexp(-AgeKey_parm(4)*(r_ages(nages)-AgeKey_parm(1))));
      }
      else
      {
        AgeKey(Use_AgeKeyParm,1)(AgeKey_StartAge,nages)=0.5 + r_ages(AgeKey_StartAge,nages) + AgeKey_parm(2)+(AgeKey_parm(3)-AgeKey_parm(2))*
        (r_ages(AgeKey_StartAge,nages)-AgeKey_parm(1))/(r_ages(nages)-AgeKey_parm(1));
      }
//  SS_Label_45.4 calc ageing variance
      if(AgeKey_Linear2==0)
      {
        AgeKey(Use_AgeKeyParm,2)(AgeKey_StartAge,nages)=AgeKey_parm(5)+(AgeKey_parm(6)-AgeKey_parm(5))*
        (1.0-mfexp(-AgeKey_parm(7)*(r_ages(AgeKey_StartAge,nages)-AgeKey_parm(1)))) / (1.0-mfexp(-AgeKey_parm(7)*(r_ages(nages)-AgeKey_parm(1))));
      }
      else
      {
        AgeKey(Use_AgeKeyParm,2)(AgeKey_StartAge,nages)=AgeKey_parm(5)+(AgeKey_parm(6)-AgeKey_parm(5))*
        (r_ages(AgeKey_StartAge,nages)-AgeKey_parm(1))/(r_ages(nages)-AgeKey_parm(1));
      }
  }

//  SS_Label_45.5 calc distribution of age' for each age
   for (a=0; a<=nages;a++)
    {
     if(AgeKey(Keynum,1,a)<=-1)
       {AgeKey(Keynum,1,a)=r_ages(a)+0.5;}
     age=AgeKey(Keynum,1,a);

     for (b=2;b<=n_abins;b++)     //  so the lower tail is accumulated into the first age' bin
     age_age(Keynum,b,a)= cumd_norm((age_bins(b)-age)/AgeKey(Keynum,2,a));

     for (b=1;b<=n_abins-1;b++)
       age_age(Keynum,b,a) = age_age(Keynum,b+1,a)-age_age(Keynum,b,a);

     age_age(Keynum,n_abins,a) = 1.-age_age(Keynum,n_abins,a) ;     // so remainder is accumulated into the last age' bin

    }

     if(gender == 2)                     //  copy ageing error matrix into male location also
     {
      L2=n_abins;
      A2=nages+1;
      for (b=1;b<=n_abins;b++)
      for (a=0;a<=nages;a++)
       {age_age(Keynum,b+L2,a+A2)=age_age(Keynum,b,a);}
     }
    return;
  }  //  end age_age key

FUNCTION void get_catch_mult(int y, int catch_mult_pointer)
  {
 /*  SS_Label_FUNCTION 47  catch_multiplier */
    int j;
    j=0;
    for(f=1;f<=Nfleet;f++)
    {
      if(need_catch_mult(f)==1)
        {
          catch_mult(y,f)=mgp_adj(catch_mult_pointer+j);
          j++;
        }
    }
    return;
  }
