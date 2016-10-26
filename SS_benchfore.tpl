FUNCTION void Get_Benchmarks(const int show_MSY)
  {
//********************************************************************
 /*  SS_Label_FUNCTION 34 Get_Benchmarks(Find Fspr, MSY) */
  int jj;  int Nloops;
  int bio_t;
  int bio_t_base;
  dvariable last_F1;  dvariable Closer;
  dvariable Vbio1_unfished;
  dvariable Vbio_MSY;
  dvariable Vbio1_MSY;
  dvariable SPR_at_target;
  dvariable junk; dvariable Nmid_c;

  dvariable df;
  dvariable BestYield;
  dvariable BestF1;
  dvar_vector F1(1,3);
  dvariable FF;
  dvar_vector yld1(1,3);
  dvariable dyld;
  dvariable dyldp;
  dvariable Fmax;
  dvariable bestF1;
  dvariable bestF2;

   if(show_MSY==1)
   {
     report5<<version_info_short<<endl;
     report5<<version_info<<endl<<ctime(&start);
     report5<<"Bmark_relF(by_fleet_&seas)"<<endl<<Bmark_RelF_Use<<endl<<"#"<<endl;
     report5<<"NOTE:_SPR_is_spawner_potential_ratio=(fishedSSB/R)/(unfishedSSB/R))"<<endl;
   }
    y=styr-3;  //  the average biology from specified benchmark years is stored here
    yz=y;
    bio_yr=y;
    eq_yr=y;
    t_base=y+(y-styr)*nseas-1;
    bio_t_base=styr+(bio_yr-styr)*nseas-1;
    if(show_MSY==2)
    {
      //  do not recal the age-specific vectors
    }
    else
    {
      for (s=1;s<=nseas;s++)
      {
        t = styr-3*nseas+s-1;

        subseas=1;  //   for begin of season   ALK_idx calculated within Make_AgeLength_Key
        ALK_idx=(s-1)*N_subseas+subseas;
        Make_AgeLength_Key(s, subseas);  //  begin season

        subseas=mid_subseas;
        ALK_idx=(s-1)*N_subseas+subseas;
        Make_AgeLength_Key(s, subseas);

  //  SPAWN-RECR:   call make_fecundity for benchmarks
        if(s==spawn_seas)
        {
          subseas=spawn_subseas;
          ALK_idx=(s-1)*N_subseas+subseas;
          if(spawn_subseas!=1 && spawn_subseas!=mid_subseas)
          {
            Make_AgeLength_Key(s, subseas);  //  spawn subseas
          }
          Make_Fecundity();
        }
      }

//  following uses the values of sel_l, sel_a, etc. stored in yr=styr-3
      for (s=1;s<=nseas;s++)
      for (g=1;g<=gmorph;g++)
      if(use_morph(g)>0)
      {
        ALK_idx=(s-1)*N_subseas+mid_subseas;;  //  for midseason
        Make_FishSelex();
      }
    }

      maxpossF.initialize();
      for(g=1;g<=gmorph;g++)
        for(s=1;s<=nseas;s++)
        {
          tempvec_a.initialize();
          for(f=1;f<=Nfleet;f++) {tempvec_a+=Bmark_RelF_Use(s,f)*deadfish(s,g,f);}
          temp=max(tempvec_a);
          if(temp>maxpossF) maxpossF=temp;
        }
        maxpossF =max_harvest_rate/maxpossF;    //  applies to any F_method

//  SPAWN-RECR:   notes regarding virgin vs. benchmark biology usage in spawn-recr
//  the spawner-recruitment function has Bzero based on virgin biology, not benchmark biology
//  need to deal with possibility that with time-varying biology, the SPB_virgin calculated from virgin conditions will differ from the SPB_virgin used for benchmark conditions

    recr_dist=recr_dist_Bmark/(Bmark_Yr(8)-Bmark_Yr(7)+1);

    natM=natM_Bmark/(Bmark_Yr(2)-Bmark_Yr(1)+1);
    surv1=surv1_Bmark/(Bmark_Yr(2)-Bmark_Yr(1)+1);
    surv2=surv2_Bmark/(Bmark_Yr(2)-Bmark_Yr(1)+1);
    
    for(j=1;j<=N_SRparm2;j++)        
    {
      if(SR_parm_timevary(j)==0)
      {SR_parm_work(j)=SR_parm(j);}
      else
      {
        temp=0.;
        for(int y=Bmark_Yr(9);y<=Bmark_Yr(10);y++)
        {temp+=SR_parm_byyr(y,j);}
        SR_parm_work(j)=temp/(Bmark_Yr(10)-Bmark_Yr(9)+1.);
      }
    }
    if(show_MSY==1) report5<<"SR_parm for benchmark: "<<SR_parm_work<<endl<<"for years: "<<Bmark_Yr(9)<<" "<<Bmark_Yr(10)<<endl;
    Fishon=0;
    Recr_Bmark=mfexp(SR_parm_work(1));
    Do_Equil_Calc(Recr_Bmark);
    SPB_Bmark=SPB_equil;
    
// find Fspr             SS_Label_710
    if(show_MSY==1)
    {
    report5<<"& & & & & find_target_SPR"<<endl;
    report5<<"Iter Fmult F_std SPR tot_catch";
    for (p=1;p<=pop;p++)
    for (gp=1;gp<=N_GP;gp++)
    {report5<<" SSB_Area:"<<p<<"_GP:"<<gp;}
    report5<<endl;
    }
    Fmult=0.; Nloops=18; Closer=1.;
    F1(1)=log(1.0e-3); last_calc=0.; Fchange=-4.0;

    equ_Recr=1.0;

    Fishon=0;
    Do_Equil_Calc(equ_Recr);
    SPR_unf=SPB_equil;  //  this corresponds to the biology for benchmark average years, not the virgin SPB_virgin
    Vbio1_unfished=smrybio;       // gets value from equil_calc
          if(show_MSY==1)
          {
          report5<<"0 0 0 1 0";
          for (p=1;p<=pop;p++)
          for (gp=1;gp<=N_GP;gp++)
          {report5<<" "<<SPB_equil_pop_gp(p,gp);}
          report5<<endl;
          }

    df=1.e-5;
    Fishon=1;
    for (j=1;j<=Nloops;j++)   // loop find Fspr
    {
      if(fabs(Fchange)<=0.25)
        {
          jj=3;
          F1(2) = F1(1) + df*.5;
          F1(3) = F1(2) - df;
        }
      else
        {jj=1;}

      for (int ii=jj;ii>=1;ii--)
        {
          Fmult=40.00/(1+mfexp(-F1(ii)));

          for (f=1;f<=Nfleet;f++)
          for (s=1;s<=nseas;s++)
            {t=bio_t_base+s; Hrate(f,t)=Fmult*Bmark_RelF_Use(s,f);}

          Fishon=1;
          Do_Equil_Calc(equ_Recr);
          yld1(ii)=SPB_equil/SPR_unf;
        }
        SPR_actual=yld1(1);

          if(jj==3)
            {
            Closer*=0.5;
              dyld=(yld1(2) - yld1(3))/df;   // First derivative (to find the root of this)
              if(dyld!=0.)
                {last_F1=F1(1); F1(1) += (SPR_target-SPR_actual)/(dyld+0.001);
                 F1(1)=(1.-Closer)*F1(1)+Closer*last_F1;
                }        // averages with last good value to keep from changing too fast
              else
                {F1(1)=(F1(1)+last_F1)*0.5;}    // go halfway back towards previous value
            }
          else
            {
//              if((last_calc-SPR_target)*(SPR_actual-SPR_target)<0.0) {Fchange*=-0.5;}   // changed sign, so reverse search direction
              temp=(last_calc-SPR_target)*(SPR_actual-SPR_target)/(sfabs(last_calc-SPR_target)*sfabs(SPR_actual-SPR_target));  // values of -1 or 1
              temp1=temp-1.;  // values of -2 or 0
              Fchange*=exp(temp1/4.)*temp;
              F1(1)+=Fchange;  last_calc=SPR_actual;
            }

          if(show_MSY==1)
          {
            report5<<j<<" "<<Fmult<<" "<<equ_F_std<<" "<<SPR_actual<<" "<<sum(equ_catch_fleet(2));
            for (p=1;p<=pop;p++)
            for (gp=1;gp<=N_GP;gp++)
            {report5<<" "<<SPB_equil_pop_gp(p,gp);}
            report5<<endl;
          }
    }   // end search loop

    if(show_MSY==1)
    {
      if(fabs(SPR_actual-SPR_target)>=0.001)
      {N_warn++; warning<<" warning: poor convergence in Fspr search "<<SPR_target<<" "<<SPR_actual<<endl;}
      if(SPR_actual/SPR_target>=1.01)
      {N_warn++; warning<<" warning: high Fmult for Fspr: "<<Fmult<<" needed to come close to low SPR "<<SPR_target<<" "<<SPR_actual<<endl;}
      report5<<"seas fleet encB deadB retB encN deadN retN): "<<endl;
      for (s=1;s<=nseas;s++)
      for (f=1;f<=Nfleet;f++)
      if(fleet_type(f)<=2)
      {
        report5<<s<<" "<<f;
        for (g=1;g<=6;g++) {report5<<" "<<equ_catch_fleet(g,s,f);}
        report5<<endl;
      }
    }

//  SPAWN-RECR:   calc equil spawn-recr in YPR; need to make this area-specific
    SPR_temp=SPR_actual*SPR_unf;
    Equ_SpawnRecr_Result = Equil_Spawn_Recr_Fxn(SR_parm_work(2), SR_parm_work(3), SPB_Bmark, Recr_Bmark, SPR_temp);  //  returns 2 element vector containing equilibrium biomass and recruitment at this SPR

    Bspr=Equ_SpawnRecr_Result(1);
    Bspr_rec=Equ_SpawnRecr_Result(2);
    YPR_tgt_enc  = YPR_enc;         //  total encountered yield per recruit
    YPR_tgt_dead = YPR_dead;           // total dead yield per recruit
    YPR_tgt_N_dead = YPR_N_dead;
    YPR_tgt_ret = YPR_ret;
    SPR_Fmult=Fmult;
    if(rundetail>0 && mceval_counter==0 && show_MSY==1) cout<<" got Fspr "<<SPR_Fmult<<" "<<SPR_actual<<endl;
    YPR_spr=YPR_tgt_dead; Vbio_spr=totbio; Vbio1_spr=smrybio;
    Mgmt_quant(10)=equ_F_std;
    Mgmt_quant(9)=Equ_SpawnRecr_Result(1);
    Mgmt_quant(11)=YPR_dead*Equ_SpawnRecr_Result(2);

    SPR_at_target=SPR_actual;
//   end finding Fspr


// ******************************************************
//  find F giving Btarget      SS_Label_720
    if(show_MSY==1)
    {
      report5<<"+ + + + + + + + + find_target_SSB/Bzero; where Bzero is for Bmark years, not Virgin"<<endl<<"Iter Fmult F_std SPR Catch SSB Recruits SSB/Bzero Tot_catch";
      for (p=1;p<=pop;p++)
      for (gp=1;gp<=N_GP;gp++)
      {report5<<" SSB_Area:"<<p<<"_GP:"<<gp;}
      report5<<endl;
    }

    F1(1)=log(1.0e-3); last_calc=0.; Fchange=-4.0; df=1.e-5; Closer=1.;
    dvariable Closer2;
    if(SR_fxn==5) {Closer2=0.001; Nloops=40;} else {Closer2=0.10; Nloops=28;}

//    Btgttgt=BTGT_target*SPB_virgin;   //  this is relative to virgin, not to the average biology from benchmark years
    Btgttgt=BTGT_target*SPB_Bmark;   //  now relative to Bmark

    for (j=0;j<=Nloops;j++)   // loop find Btarget
      {
      if(fabs(Fchange)<=Closer2)
        {
        jj=3;
        F1(2) = F1(1) + df*.5;
        F1(3) = F1(2) - df;
        }
      else
        {jj=1;}
      for (int ii=jj;ii>=1;ii--)
      {
        if(j==0) {Fmult=0.0;} else {Fmult=40.00/(1.00+mfexp(-F1(ii)));}
        for (f=1;f<=Nfleet;f++)
        for (s=1;s<=nseas;s++)
        {
          t=bio_t_base+s; Hrate(f,t)=Fmult*Bmark_RelF_Use(s,f);
        }
        Do_Equil_Calc(equ_Recr);
        SPR_Btgt = SPB_equil/SPR_unf;
//  SPAWN-RECR:   calc equil spawn-recr for Btarget calcs;  need to make area-specific
        SPR_temp=SPB_equil;
        Equ_SpawnRecr_Result = Equil_Spawn_Recr_Fxn(SR_parm_work(2), SR_parm_work(3), SPB_Bmark, Recr_Bmark, SPR_temp);  //  returns 2 element vector containing equilibrium biomass and recruitment at this SPR
        yld1(ii)=Equ_SpawnRecr_Result(1);
      }

      Btgt=Equ_SpawnRecr_Result(1);  //  so uses benchmark average years

      if(jj==3)
        {
        Closer *=0.5;
        dyld=(yld1(2) - yld1(3))/df;                      // First derivative
        if(dyld!=0.)
          {last_F1=F1(1); F1(1) -= (Btgt-Btgttgt)/(dyld+0.001);
           F1(1)=(1.-Closer)*F1(1)+(Closer)*last_F1;
          }        // weighted average with last good value to keep from changing too fast
        else
          {F1(1)=(F1(1)+last_F1)*0.5;}    // go halfway back towards previous value
        }
      else
        {
          temp=(last_calc-Btgttgt)*(Btgt-Btgttgt)/(sfabs(last_calc-Btgttgt)*sfabs(Btgt-Btgttgt));  // values of -1 or 1
          temp1=temp-1.;  // values of -2 or 0
          Fchange*=exp(temp1/4.)*temp;
          F1(1)+=Fchange;  last_calc=Btgt;
        }

      if(show_MSY==1)
      {
        report5<<j<<" "<<Fmult<<" "<<equ_F_std<<" "<<(Btgt/Equ_SpawnRecr_Result(2))/SPR_unf<<" "<<YPR_dead*Equ_SpawnRecr_Result(2)<<" "<<Btgt<<" "<<Equ_SpawnRecr_Result(2)
        <<" "<<Btgt/SPB_Bmark<<" "<<sum(equ_catch_fleet(2))*Equ_SpawnRecr_Result(2);
        for (p=1;p<=pop;p++)
        for (gp=1;gp<=N_GP;gp++)
        {report5<<" "<<SPB_equil_pop_gp(p,gp)*Equ_SpawnRecr_Result(2);}
        report5<<endl;
      }

      }   // end search loop

    Btgt_Rec=Equ_SpawnRecr_Result(2);

    if(show_MSY==1)
    {
      if(fabs(log(Btgt/Btgttgt))>=0.001)
      {N_warn++; warning<<" warning: poor convergence in Btarget search "<<Btgttgt<<" "<<Btgt<<endl;}
      report5<<"seas fleet encB deadB retB encN deadN retN): "<<endl;
      for (s=1;s<=nseas;s++)
      for (f=1;f<=Nfleet;f++)
      if(fleet_type(f)<=2)
      {
        report5<<s<<" "<<f;
        for (g=1;g<=6;g++) {report5<<" "<<Btgt_Rec*equ_catch_fleet(g,s,f);}
        report5<<endl;
      }
    }

    Btgt_Fmult=Fmult;
    if(rundetail>0 && mceval_counter==0 && show_MSY==1) cout<<" got_Btgt "<<Btgt_Fmult<<" "<<Btgt/SPB_Bmark<<endl;
    YPR_Btgt_enc  = YPR_enc;         //  total encountered yield per recruit
    YPR_Btgt_dead = YPR_dead;           // total dead yield per recruit
    YPR_Btgt_N_dead = YPR_N_dead;           // total dead yield per recruit
    YPR_Btgt_ret = YPR_ret;
    Vbio_Btgt=totbio; Vbio1_Btgt=smrybio;
    Mgmt_quant(7)=equ_F_std;
    Mgmt_quant(5)=Btgt;
    Mgmt_quant(6)=SPR_Btgt;
    Mgmt_quant(8)=YPR_dead*Btgt_Rec;

//  end finding F for Btarget


// ******************************************************
//  start finding Fmsy     SS_Label_730
    if(Do_MSY==0)
      {
       Fmax=1.; MSY=-1; Bmsy=-1; Recr_msy=-1; MSY_SPR=-1; Yield=-1; totbio=1; smrybio=1.; MSY_Fmult=-1.;   //  use these values if MSY is not calculated
       Mgmt_quant(1)=SPB_Bmark;  // this may be redundant
       if(show_MSY==1) report5<<"MSY_not_calculated;_ignore_values"<<endl;
      }
    else
    {
      if(F_Method>=2) {Fmax=3.00*Btgt_Fmult;}

      switch(Do_MSY)
        {
        case 1:  // set Fmsy=Fspr
          {Fmult=SPR_Fmult;
           if(F_Method==1) {Fmax=SPR_Fmult*1.1;}
           F1(1)=-log(Fmax/SPR_Fmult-1.); last_calc=0.; Fchange=1.0; Closer=1.; Nloops=0;
           break;}
        case 2:  // calc Fmsy
          {last_calc=0.; Fchange=0.51; Closer=1.0;
           if(SR_fxn==5) {Nloops=40;} else {Nloops=19;}
          if(F_Method==1) {Fmax=(Btgt_Fmult+SPR_Fmult)*0.5*SR_parm_work(2)/0.05;}    //  previously /0.18
           F1(1)=-log(Fmax/Btgt_Fmult-1.);
          break;}
        case 3:  // set Fmsy=Fbtgt
          {Fmult=Btgt_Fmult;
           if(F_Method==1) {Fmax=Btgt_Fmult*1.1;}
            F1(1)=-log(Fmax/Btgt_Fmult-1.); last_calc=0.; Fchange=1.0; Closer=1.0; Nloops=0;
          break;}
        case 4:   //  set fmult for Fmsy to 1
          {Fmult=1; Fmax=1.1; F1(1)=-log(Fmax/Fmult-1.); last_calc=0.; Fchange=1.0; Closer=1.0; Nloops=0;
          break;}
        }

      if(show_MSY==1)
      {
        report5<<"+ + + + + + + + + find_MSY_catch"<<endl<<"Iter Fmult F_std SPR Catch SSB Recruits SSB/Bzero Gradient Curvature Tot_Catch";
        for (p=1;p<=pop;p++)
        for (gp=1;gp<=N_GP;gp++)
        {report5<<" Area:"<<p<<"_GP:"<<gp;}
        report5<<endl;
      }

        bestF1.initialize(); bestF2.initialize();

      df=0.050;
      jj=3;
      Fishon=1;
      for (j=0;j<=Nloops;j++)   // loop to find Fmsy
        {
         df*=.95;
        Closer*=0.8;
          F1(2) = F1(1) + df*.5;
          F1(3) = F1(2) - df;
        for (int ii=jj;ii>=1;ii--)
          {
          Fmult=Fmax/(1.00+mfexp(-F1(ii)));
          for (f=1;f<=Nfleet;f++)
          for (s=1;s<=nseas;s++)
            {t=bio_t_base+s; Hrate(f,t)=Fmult*Bmark_RelF_Use(s,f);}

          Do_Equil_Calc(equ_Recr);
//  SPAWN-RECR:   calc spawn-recr for MSY calcs;  need to make area-specific
          MSY_SPR = SPB_equil/SPR_unf;
          SPR_temp=SPB_equil;
          Equ_SpawnRecr_Result = Equil_Spawn_Recr_Fxn(SR_parm_work(2), SR_parm_work(3), SPB_Bmark, Recr_Bmark, SPR_temp);  //  returns 2 element vector containing equilibrium biomass and recruitment at this SPR
          Bmsy=Equ_SpawnRecr_Result(1);
          Recr_msy=Equ_SpawnRecr_Result(2);
          yld1(ii)=YPR_dead*Recr_msy;   //  *mfexp(-Equ_penalty);
          Yield=YPR_dead*Recr_msy;
          bestF1+=F1(ii)*(pow(mfexp(Yield/1.0e08),5)-1.);
          bestF2+=pow(mfexp(Yield/1.0e08),5)-1.;
          }   //  end gradient calc

        dyld   = (yld1(2) - yld1(3))/df;                      // First derivative (to find the root of this)
        temp  = (yld1(2) + yld1(3) - 2.*yld1(1))/(.25*df*df);   // Second derivative (for Newton Raphson)
        dyldp = -sqrt(temp*temp+1.);   //  add 1 to keep curvature reasonably large
        last_F1=F1(1);
        temp = F1(1)-dyld*(1.-Closer)/(dyldp);
        if(show_MSY==1)
        {
          report5<<j<<" "<<Fmult<<" "<<equ_F_std<<" "<<MSY_SPR<<" "<<yld1(1)<<" "<<Bmsy<<" "<<Recr_msy<<" "<<Bmsy/SPB_Bmark<<" "
          <<dyld <<" "<<dyldp<<" "<<value(sum(equ_catch_fleet(2))*Recr_msy);
          for (p=1;p<=pop;p++)
          for (gp=1;gp<=N_GP;gp++)
          {report5<<" "<<SPB_equil_pop_gp(p,gp)*Recr_msy;}
          report5<<endl;
        }

        if(j<=9)
          {F1(1)=(1.-Closer)*temp+Closer*(bestF1/bestF2);}        // averages with best value to keep from changing too fast
        else
          {F1(1)=temp;}
        }   // end search loop

      YPR_msy_enc = YPR_enc;
      YPR_msy_dead = YPR_dead;           // total dead yieldt
      YPR_msy_N_dead = YPR_N_dead;           // total dead yield
      YPR_msy_ret = YPR_ret;           // total retained yield
      MSY=Yield;
      MSY_Fmult=Fmult;
      Mgmt_quant(15)=Yield;
      Mgmt_quant(12)=Bmsy;
      Mgmt_quant(13)=MSY_SPR;
      Mgmt_quant(14)=equ_F_std;
      Mgmt_quant(16)=YPR_ret*Recr_msy;
      Vbio1_MSY=smrybio;
      Vbio_MSY=totbio;

      if(show_MSY==1)
      {
      if(Do_MSY==2 && fabs(dyld/dyldp)>=0.001)
      {N_warn++; warning<<" warning: poor convergence in Fmsy, final dy/dy2= "<<dyld/dyldp<<endl;}
      report5<<"seas fleet encB deadB retB encN deadN retN): "<<endl;
      for (s=1;s<=nseas;s++)
      for (f=1;f<=Nfleet;f++)
      if(fleet_type(f)<=2)
      {
        report5<<s<<" "<<f;
        for (g=1;g<=6;g++) {report5<<" "<<Recr_msy*equ_catch_fleet(g,s,f);}
        report5<<endl;
      }

    report5<<"Equil_N_at_age_at_MSY_each"<<endl<<"Seas Area GP Sex subM"<<age_vector<<endl;
     for (s=1;s<=nseas;s++)
     for (p=1;p<=pop;p++)
     for (g=1;g<=gmorph;g++)
     {if(use_morph(g)>0) report5<<s<<" "<<p<<" "<<GP4(g)<<" "<<sx(g)<<" "<<GP2(g)<<" "<<Recr_msy*equ_numbers(s,p,g)(0,nages)<<endl;}

    report5<<"Equil_N_at_age_at_MSY_sum"<<endl<<"GP Sex N/Z"<<age_vector<<endl;
    for (gg=1;gg<=gender;gg++)
    for (gp=1;gp<=N_GP;gp++)
    {
      tempvec_a.initialize();
      for (p=1;p<=pop;p++)
      for (g=1;g<=gmorph;g++)
      if(use_morph(g)>0)
      {
        if(GP4(g)==gp && sx(g)==gg) tempvec_a+= value(Recr_msy*equ_numbers(1,p,g)(0,nages));
      }
      if(nseas>1)
      {
        tempvec_a(0)=0.;
        for (s=1;s<=nseas;s++)
        for (p=1;p<=pop;p++)
        for (g=1;g<=gmorph;g++)
        if(use_morph(g)>0 && Bseas(g)==s)
        {
          if(GP4(g)==gp && sx(g)==gg) tempvec_a(0) += value(Recr_msy*equ_numbers(1,p,g,0));
        }
      }
      report5 <<gp<<" "<<gg<<" N "<<tempvec_a<<endl;
      report5 <<gp<<" "<<gg<<" Z ";
      for (a=0;a<=nages-2;a++)
      {report5<<-log(tempvec_a(a+1)/tempvec_a(a))<<" ";}
      report5<<" NA NA"<<endl;
    }

     Fishon=0;
     Do_Equil_Calc(equ_Recr);
    report5<<"Equil_N_at_age_M_only_Recr_MSY"<<endl<<"Seas Area GP Sex subM"<<age_vector<<endl;
     for (s=1;s<=nseas;s++)
     for (p=1;p<=pop;p++)
     for (g=1;g<=gmorph;g++)
     {if(use_morph(g)>0) report5<<s<<" "<<p<<" "<<GP4(g)<<" "<<sx(g)<<" "<<GP2(g)<<" "<<Recr_msy*equ_numbers(s,p,g)(0,nages)<<endl;}

    report5<<"Equil_N_at_age_M_only_sum"<<endl<<"GP Sex N/Z "<<age_vector<<endl;
    for (gg=1;gg<=gender;gg++)
    for (gp=1;gp<=N_GP;gp++)
    {
      tempvec_a.initialize();
      for (p=1;p<=pop;p++)
      for (g=1;g<=gmorph;g++)
      if(use_morph(g)>0)
      {
        if(GP4(g)==gp && sx(g)==gg) tempvec_a+= value(Recr_msy*equ_numbers(1,p,g)(0,nages));
      }
      if(nseas>1)
      {
        tempvec_a(0)=0.;
        for (s=1;s<=nseas;s++)
        for (p=1;p<=pop;p++)
        for (g=1;g<=gmorph;g++)
        if(use_morph(g)>0 && Bseas(g)==s)
        {
          if(GP4(g)==gp && sx(g)==gg) tempvec_a(0) += value(Recr_msy*equ_numbers(1,p,g,0));
        }
      }
      report5 <<gp<<" "<<gg<<" N "<<tempvec_a<<endl;
      report5 <<gp<<" "<<gg<<" Z ";
      for (a=0;a<=nages-2;a++)
      {report5<<-log(tempvec_a(a+1)/tempvec_a(a))<<" ";
        }
      report5<<" NA NA"<<endl;
    }

     Fishon=1;

    if(Fmult*3.0 <= SPR_Fmult) {N_warn++; warning<<" Fmsy is <1/3 of Fspr are you sure?  check for convergence "<<endl;}
    if(Fmult/3.0 >= SPR_Fmult) {N_warn++; warning<<" Fmsy is >3x of Fspr are you sure?  check for convergence "<<endl;}
    if(Fmult/0.98 >= Fmax) {N_warn++; warning<<" Fmsy is close to max allowed; check for convergence "<<endl;}
      }
    }

    if(rundetail>0 && mceval_counter==0 && show_MSY==1) cout<<" got Fmsy "<<MSY_Fmult<<" "<<MSY<<endl;

// ***************** show management report   SS_Label_740
    if(show_MSY==1)
    {
  report5<<"+ + + + +"<<endl<<"Management_report"<<endl;
  report5<<"Steepness_Recr_SPB_virgin "<<SR_parm(2)<<" "<<Recr_virgin<<" "<<SPB_virgin<<endl;
  report5<<"Steepness_Recr_SPB_benchmark "<<SR_parm_work(2)<<" "<<Recr_Bmark<<" "<<SPB_Bmark<<endl;
  report5<<"+"<<endl<<"Element Value Bio/Recr Bio/R0 Numbers N/R0 (B_in_mT;_N_in_thousands)"<<endl;
  report5<<"Recr_unfished(R0) "<<Recr_Bmark<<" -- -- "<<endl;
  report5<<"SPB_unfished(B0) "<<SPB_Bmark<<" -- -- "<<endl;
  report5<<"BIO_Smry_unfished "<<Vbio1_unfished*Recr_Bmark<<" "<<Vbio1_unfished<<" "<<Vbio1_unfished<<endl<<"+ + + + +"<<endl;

  report5<<"SPR_target "<<SPR_target<<endl;
  report5<<"SPR_calc "<<SPR_actual<<endl;
  report5<<"Fmult "<<SPR_Fmult<<endl;
  report5<<"F_std "<<Mgmt_quant(10)<<endl;
  report5<<"Exploit(Y/Bsmry) "<<YPR_spr/Vbio1_spr<<endl;
  report5<<"Recruits@Fspr "<<Bspr_rec<<" -- -- "<<Bspr_rec<<" "<<Bspr_rec/Recr_Bmark<<" "<<endl;
  report5<<"SPBio "<<SPR_at_target*Bspr_rec*SPR_unf<<" "<<SPR_at_target*SPR_unf<<" -- "<<endl;
  report5<<"YPR_encountered "<<YPR_tgt_enc*Bspr_rec<<" "<<YPR_tgt_enc<<" -- "<<endl;
  report5<<"YPR_dead "<<YPR_tgt_dead*Bspr_rec<<" "<<YPR_tgt_dead<<" -- "<<" "<<YPR_tgt_N_dead*Bspr_rec<<endl;
  report5<<"YPR_retain "<<YPR_tgt_ret*Bspr_rec<<" "<<YPR_tgt_ret<<" -- "<<endl;
  report5<<"Biomass_Smry "<<Vbio1_spr*Bspr_rec<<" "<<Vbio1_spr<<" -- "<<endl<<"+ + + + +"<<endl;

  report5<<"Btarget  "<<BTGT_target<<endl;
  report5<<"Btgt_calc_rel_SPB_Bmark "<<Btgt/SPB_Bmark<<endl;
  report5<<"SPR_for_Btgt "<<SPR_Btgt<<endl;
  report5<<"Fmult "<<Btgt_Fmult<<endl;
  report5<<"F_std "<<Mgmt_quant(7)<<endl;
  report5<<"Exploit(Y/Bsmry) "<<YPR_Btgt_dead/Vbio1_Btgt<<endl;
  report5<<"Recruits@Btgt "<<Btgt_Rec<<" -- -- "<<Btgt_Rec<<" "<<Btgt_Rec/Recr_Bmark<<endl;
  report5<<"SPBio "<<Btgt<<" "<<Btgt/Btgt_Rec<<" -- "<<endl;
  report5<<"YPR_encountered "<<YPR_Btgt_enc*Btgt_Rec<<" "<<YPR_Btgt_enc<<" -- "<<endl;
  report5<<"YPR_dead "<<YPR_Btgt_dead*Btgt_Rec<<" "<<YPR_Btgt_dead<<" -- "<<YPR_Btgt_N_dead*Btgt_Rec<<endl;
  report5<<"YPR_retain "<<YPR_Btgt_ret*Btgt_Rec<<" "<<YPR_Btgt_ret<<" -- "<<endl;
  report5<<"Biomass_Smry "<<Vbio1_Btgt*Btgt_Rec<<" "<<Vbio1_Btgt<<" -- "<<endl<<"+ + + + +"<<endl;

      switch(Do_MSY)
        {
        case 1:  // set Fmsy=Fspr
          {report5<<"set_Fmsy=Fspr"<<endl;
          break;}
        case 2:  // calc Fmsy
          {report5<<"calculate_FMSY"<<endl;
          break;}
        case 3:  // set Fmsy=Fbtgt
          {report5<<"set_Fmsy=Fbtgt"<<endl;
          break;}
        case 4:   //  set fmult for Fmsy to 1
          {report5<<"set_Fmsy_using_Fmult=1.0"<<endl;
          break;}
        }
  report5<<"SPR "<<MSY_SPR<<endl;
  report5<<"Fmult "<<MSY_Fmult<<endl;
  report5<<"F_std "<<Mgmt_quant(14)<<endl;
  report5<<"Exploit(Y/Bsmry) "<<MSY/(Vbio1_MSY*Recr_msy)<<endl;
  report5<<"Recruits@MSY "<<Recr_msy<<" -- -- "<<Recr_msy<<" "<<Recr_msy/Recr_Bmark<<endl;
  report5<<"SPBio "<<Bmsy<<" "<<Bmsy/Recr_msy<<" -- "<<endl;
  report5<<"SPBmsy/SPBzero(using_SPB_Bmark) "<<Bmsy/SPB_Bmark<<" -- --"<<endl;  // new version
  report5<<"SPBmsy/SPBzero(using_BenchmarkYr_biology) "<<Bmsy/(Recr_Bmark*SPR_unf)<<" -- --"<<endl;
  report5<<"MSY_for_optimize "<<MSY<<" "<<MSY/Recr_msy<<" -- "<<endl;
  report5<<"MSY_encountered "<<YPR_msy_enc*Recr_msy<<" "<<YPR_msy_enc<<" -- "<<endl;
  report5<<"MSY_dead "<<YPR_msy_dead*Recr_msy<<" "<<YPR_msy_dead<<" -- "<<YPR_msy_N_dead*Recr_msy<<endl;
  report5<<"MSY_retain "<<YPR_msy_ret*Recr_msy<<" "<<YPR_msy_ret<<" -- "<<endl;
  report5<<"Biomass_Smry "<<Vbio1_MSY*Recr_msy<<" "<<Vbio1_MSY<<" -- "<<endl<<"+"<<endl;
  report5<<"Summary_age: "<<Smry_Age<<endl<<"#"<<endl;
  report5<<"#_SPR outputs use biology averaged over years: "<<Bmark_Yr(1)<<" "<<Bmark_Yr(2)<<endl;
  report5<<"#_MSY and Bmsy use Bmark years biology"<<endl<<"#"<<endl;
  if(F_Method==1)
  {
    report5<<"F_reported_below_is_Pope's_midseason_exploitation_rate=MSY_Fmult*Alloc"<<endl;
    report5<<"seas seas_dur "; for (f=1;f<=Nfleet;f++) {report5<<" fleet:"<<f;}
    report5<<endl;
    for (s=1;s<=nseas;s++) {report5<<s<<" "<<seasdur(s)<<" "<<MSY_Fmult*Bmark_RelF_Use(s)<<endl;}
  }
  else
  {
    report5<<"F_reported_here_is_Seasonal_apicalF=MSY_Fmult*Alloc*seas_dur_(can_be>F_std_because_of_selex)"<<endl;
    report5<<"seas seas_dur "; for (f=1;f<=Nfleet;f++) {report5<<" fleet:"<<f;}
    report5<<endl;
    for (s=1;s<=nseas;s++) {report5<<s<<" "<<seasdur(s)<<" "<<MSY_Fmult*Bmark_RelF_Use(s)*seasdur(s)<<endl;}
  }
  report5<<"#"<<endl;
    }
    else if(show_MSY==2)  //  do brief output
    {
      SS2out<<SPR_actual<<" "<<SPR_Fmult<<" "<<Mgmt_quant(10)<<" "<<YPR_spr/Vbio1_spr<<" "<<Bspr_rec<<" "
      <<SPR_at_target*Bspr_rec*SPR_unf<<" "<<YPR_tgt_dead*Bspr_rec<<" "<<YPR_tgt_ret*Bspr_rec
      <<" "<<Vbio1_spr*Bspr_rec<<" # ";

      SS2out<<SPR_Btgt<<" "<<Btgt/SPB_Bmark<<" "<<Btgt_Fmult<<" "<<Mgmt_quant(7)<<" "<<YPR_Btgt_dead/Vbio1_Btgt<<" "<<Btgt_Rec<<" "
      <<Btgt<<" "<<YPR_Btgt_dead*Btgt_Rec<<" "<<YPR_Btgt_ret*Btgt_Rec
      <<" "<<Vbio1_Btgt*Btgt_Rec<<" # ";

      SS2out<<MSY_SPR<<" "<<Bmsy/SPB_Bmark<<" "<<MSY_Fmult<<" "<<Mgmt_quant(14)<<" "<<MSY/(Vbio1_MSY*Recr_msy)<<" "<<Recr_msy<<" "
      <<Bmsy<<" "<<MSY<<" "<<YPR_msy_dead*Recr_msy<<" "<<YPR_msy_ret*Recr_msy
      <<" "<<Vbio1_MSY*Recr_msy<<" # "<<endl;
    }
  }   //  end benchmarks

FUNCTION void Get_Forecast()
  {
//********************************************************************
 /*  SS_Label_FUNCTION 35 Get_Forecast */
  t_base=styr+(endyr-styr)*nseas-1;
  int Do_4010;
  int bio_t;
  int adv_age;
  dvariable OFL_catch;
  dvariable Fcast_Crash;
  dvariable totcatch;
  dvariable R0_use;
  dvariable SPB_use;
  dvar_matrix catage_w(1,gmorph,0,nages);
  dvar_vector tempcatch(1,Nfleet);
  dvar_vector ABC_buffer(endyr+1,YrMax);
  imatrix Do_F_tune(t_base,TimeMax_Fcast_std,1,Nfleet);  //  flag for doing F from catch
  dvar_matrix Fcast_Catch_Store(t_base,TimeMax_Fcast_std,1,Nfleet);
  dvar_vector Fcast_Catch_Calc_Annual(1,Nfleet);
  dvar_vector Fcast_Catch_Allocation_Group(1,Fcast_Catch_Allocation_Groups);
  dvar_vector Fcast_Catch_ByArea(1,pop);

    dvar_vector  H_temp(1,Nfleet);
    dvar_vector  C_temp(1,Nfleet);
    dvar_vector  H_old(1,Nfleet);
    dvar_vector  C_old(1,Nfleet);

  int Tune_F;
  int Tune_F_loops;

  int ABC_Loop_start;
  int ABC_Loop_end;

  Do_F_tune.initialize();

   if(fishery_on_off==1)
   {
    switch(Do_Forecast)
    {
      case 1:
        {Fcast_Fmult=SPR_Fmult; if(show_MSY==1) report5<<"1:  Forecast_using_Fspr"<<endl; break;}
      case 2:
        {Fcast_Fmult=MSY_Fmult; if(show_MSY==1) report5<<"2:  Forecast_using_Fmsy"<<endl; break;}
      case 3:
        {Fcast_Fmult=Btgt_Fmult; if(show_MSY==1) report5<<"3:  Forecast_using_F(Btarget)"<<endl; break;}
      case 4:
      {
        Fcast_Fmult=0.0;
        for (y=Fcast_RelF_yr1;y<=Fcast_RelF_yr2;y++)
        for (f=1;f<=Nfleet;f++)
        for (s=1;s<=nseas;s++)
        {
         if(fleet_type(f)<=2)
         {
           t=styr+(y-styr)*nseas+s-1;
           Fcast_Fmult+=Hrate(f,t);
         }
        }
        Fcast_Fmult/=float(Fcast_RelF_yr2-Fcast_RelF_yr1+1);
        Fcurr_Fmult=Fcast_Fmult;
        if(show_MSY==1) report5<<"4:  Forecast_using_ave_F_from:_"<<Fcast_RelF_yr1<<"_"<<Fcast_RelF_yr2<<endl; break;
      }
      case 5:
      {Fcast_Fmult=Fcast_Flevel; if(show_MSY==1) report5<<"5:  Forecast_using_input_F "<<endl; break;}
    }
   }
   else
   {
     Fcast_Fmult=0.0;
   }

  if(show_MSY==1)  //  write more headers
  {
    report5<<"Annual_Forecast_Fmult: "<<Fcast_Fmult<<endl;
    report5<<"Fmultiplier_during_selected_relF_years_was: "<<Fcurr_Fmult<<endl;
    report5<<"Selectivity_averaged_over_yrs:_"<<Fcast_Sel_yr1<<"_to_"<<Fcast_Sel_yr2<<endl;
    report5<<"Recruitment_averaged_over_yrs:_"<<Fcast_Rec_yr1<<"_to_"<<Fcast_Rec_yr2<<endl;
    report5<<"Cap_totalcatch_by_fleet "<<endl<<Fcast_MaxFleetCatch<<endl;
    report5<<"Cap_totalcatch_by_area "<<endl<<Fcast_MaxAreaCatch<<endl;
    report5<<"Assign_fleets_to_allocation_groups_(0_means_not_in_a_group) "<<endl<<Allocation_Fleet_Assignments<<endl;
    report5<<"Calculated_number_of_allocation_groups "<<Fcast_Catch_Allocation_Groups<<endl;
    if(Fcast_Catch_Allocation_Groups>0)
    {
      report5<<"Year ";
      for (f=1;f<=Fcast_Catch_Allocation_Groups;f++) report5<<" group_"<<f;
      report5<<endl;
      for(y=endyr+1;y<=YrMax;y++)
      {
        report5<<y<<" "<<Fcast_Catch_Allocation(y-endyr)<<endl;
      }
     }
    if(Fcast_Catch_Basis==2)
    {report5<<"2:_Caps_&_Alloc_use_dead_catchbio"<<endl;}
    else if(Fcast_Catch_Basis==3)
    {report5<<"3:_Caps_&_Alloc_use_retained_catchbio"<<endl;}
    else if(Fcast_Catch_Basis==5)
    {report5<<"5:_Caps_&_Alloc_use_dead_catchnum"<<endl;}
    else if(Fcast_Catch_Basis==6)
    {report5<<"6:_Caps_&_Alloc_use_retained_catchnum"<<endl;}
    if(N_Fcast_Input_Catches>0)
    {
      report5<<"-1 #Input_fixed_catches_or_F_with_fleet/time_specific_values (3 for retained catch; 2 for dead catch; 99 for F)"<<endl;
    }
    report5<<"#_Relative_F_among_fleets"<<endl;
    if(Fcast_RelF_Basis==1)
    {
      report5<<"based_on_years:_"<<Fcast_RelF_yr1<<"_to_"<<Fcast_RelF_yr2<<endl;
    }
    else
    {
      report5<<"read_from_input_file"<<endl;
    }
    if(F_Method==1)
    {
      report5<<"Pope's_midseason_exploitation_rate=Fmult*Alloc"<<endl;
      report5<<"seas seas_dur ";
      for (f=1;f<=Nfleet;f++)
      if(fleet_type(f)<=2)
      {report5<<" fleet:"<<f;}
      report5<<endl;
      for (s=1;s<=nseas;s++)
      {
        report5<<s<<" "<<seasdur(s);
        for(f=1;f<=Nfleet;f++)
        if(fleet_type(f)<=2)
        {report5<<" "<<Fcast_Fmult*Fcast_RelF_Use(s)<<endl;}
      }
    }
    else
    {
      report5<<"Seasonal_apicalF=Fmult*Alloc*seas_dur_(can_be>F_std_because_of_selex)"<<endl;
      report5<<"seas seas_dur "; for (f=1;f<=Nfleet;f++) {report5<<" fleet:"<<f;}
      report5<<endl;
      for (s=1;s<=nseas;s++) {report5<<s<<" "<<seasdur(s)<<" "<<Fcast_Fmult*Fcast_RelF_Use(s)*seasdur(s)<<endl;}
    }
    report5<<"#"<<endl;
    report5<<"N_forecast_yrs: "<<N_Fcast_Yrs<<endl;
    report5<<"OY_Control_Rule "<<" Inflection: "<<H4010_top<<" Intercept: "<<H4010_bot<<" Scale: "<<H4010_scale;
    if(HarvestPolicy==1) {report5<<" adjust_catch_below_Inflection(west_coast)"<<endl;} else {report5<<" adjust_F_below_Inflection"<<endl;}
    report5<<"#"<<endl;
  }
  
  int jloop;
  if(fishery_on_off==1)
  {jloop=Fcast_Loop_Control(1);}
  else
  {jloop=1;}
  for (int Fcast_Loop1=1; Fcast_Loop1<=jloop;Fcast_Loop1++)  //   for different forecast conditions
  {
    switch(Fcast_Loop1)  //  select which ABC_loops to use
    {
      case 1:  // do OFL only
      {
        ABC_Loop_start=1;
        ABC_Loop_end=1;
        if(show_MSY==1) report5<<"FORECAST:_With_Constant_F=Fofl;_No_Input_Catches_or_Adjustments;_Equil_Recr;_No_inpl_error"<<endl;
        break;
      }
      case 2:  //  for each year:  do 3 calculations:  (1) OFL, (2) calc ABC and apply caps and allocations, (3) get F from catch _impl
      {
        ABC_Loop_start=1;
        ABC_Loop_end=3;
        if(show_MSY==1) report5<<"FORECAST:_With_F=Fabc;_With_Input_Catches_and_Catch_Adjustments;_Equil_Recr;_No_inpl_error"<<endl;
        break;
      }
      case 3:  //  just need to get F from stored adjusted catch (after modifying stored catch by implementation error).
      {
        ABC_Loop_start=3;
        ABC_Loop_end=3;
        if(show_MSY==1) report5<<"FORECAST:_With_F_to_match_adjusted_catch;_With_Input_Catches_and_Catch_Adjustments;_Stochastic_Recr;_With_inpl_error"<<endl;
        break;
      }
    }
    if(show_MSY==1)
    {
    report5<<"pop year ABC_Loop season Ctrl_Rule bio-all bio-Smry SpawnBio Depletion recruit-0 ";
    for (f=1;f<=Nfleet;f++)
    if(fleet_type(f)<=2)
    {report5<<" sel(B):_"<<f<<" dead(B):_"<<f<<" retain(B):_"<<f<<
    " sel(N):_"<<f<<" dead(N):_"<<f<<" retain(N):_"<<f<<" F:_"<<f<<" R/C";}
    report5<<" Catch_Cap Total_Catch F_Std"<<endl;
    }

    //  note that spawnbio and Recruits need to retain their value from calculation in endyr,
    //  so can be used to distribute recruitment in year endyr+1 if recruitment distribution occurs before spawning season
    //  would be better to back up to last mainrecrdev and start with begin of forecast
    SPB_current=SPB_yr(endyr);
    Recruits=exp_rec(endyr,4);
    //  need to distribute these recruits forward into endyr+1

//  refresh quantities that might have changed in benchmark.
//  some of these might be change within forecast also
    recr_dist=recr_dist_endyr;
    natM=natM_endyr;
    surv1=surv1_endyr;
    surv2=surv2_endyr;
        
    for (y=endyr+1;y<=YrMax;y++)
    {
      t_base=styr+(y-styr)*nseas-1;
     	env_data(y,-1)=SPB_current/SPB_yr(styr-1);  //  store most recent value for density-dependent effects, NOTE - off by a year if recalc'ed at beginning of season 1
      env_data(y,-2)=mfexp(recdev(y));  //  store for density-dependent effects
        if(timevary_MG(y,2)>0 || timevary_MG(y,3)>0 || save_for_report==1 || WTage_rd>0)
        {
          s=1;
          subseas=1;  //  begin season  note that ALK_idx re-calculated inside get_growth3
          ALK_idx=(s-1)*N_subseas+subseas;  //  redundant with calc inside get_growth3 ????
  //      get_growth3(s, subseas);  //  not needed because size-at-age already has been propagated to seas 1 subseas 1
          Make_AgeLength_Key(s, subseas);  //  this will give wt_age_beg before any time-varying parameter changes for this year
        }

        smrybio=0.0;
        smrynum=0.0;
        s=1;
        t=t_base+1;
        for (g=1;g<=gmorph;g++)
        if(use_morph(g)>0)
        {
          for (p=1;p<=pop;p++)
          {
            smrybio+=natage(t,p,g)(Smry_Age,nages)*Wt_Age_beg(s,g)(Smry_Age,nages);
            smrynum+=sum(natage(t,p,g)(Smry_Age,nages));   //sums to accumulate across platoons and settlements
          }
        }
        env_data(y,-3)=smrybio/env_data(styr-1,-3);
        env_data(y,-4)=smrynum/env_data(styr-1,-4);


      Smry_Table(y).initialize();

      if(Fcast_Loop1==3 && Do_Impl_Error>0)  //  apply implementation error, which is a random variable, so adds variance to forecast
                                             //  in future, could do this a fleet-specific implementation error
      {
        for (s=1;s<=nseas;s++)
        {
          t=t_base+s;
          for (f=1;f<=Nfleet;f++)
          {
            if(fleet_type(f)<=2)
          {Fcast_Catch_Store(t,f)*=mfexp(Fcast_impl_error(y));}  //  should this be bias adjusted?
          }
        }
      }

//  do biology for this year
      yz=endyr+1;  //  biology year for parameters
      if(timevary_MG(endyr+1,2)>0 || save_for_report>0)  //  so uses endyr+1 timevary setting for duration of forecast
      {
        get_MGsetup();
        ALK_subseas_update=1;  //  vector to indicate if ALK needs recalculating
        if(Grow_type!=2)
        {get_growth2();}
        else
        {get_growth2_Richards();}
      }
      if(timevary_MG(endyr+1,1)>0) get_natmort();
      if(timevary_MG(endyr+1,3)>0) get_wtlen();
      if(timevary_MG(endyr+1,4)>0) get_recr_distribution();
      if(timevary_MG(endyr+1,5)>0) get_migration();
      if(timevary_MG(endyr+1,7)>0)  get_catch_mult(y, catch_mult_pointer);

      if(save_for_report>0 && Fcast_Loop1==Fcast_Loop_Control(1))
      {
        if(timevary_MG(endyr+1,1)>0 || timevary_MG(endyr+1,2)>0 || timevary_MG(endyr+1,3)>0)
        {
          get_saveGparm();
        }
      }
  //  SS_Label_Info_24.1.2  #Call selectivity, which does its own internal check for time-varying changes
      get_selectivity();

      // ABC_loop:  1=get OFL; 2=get_ABC, use input catches; 3=recalc with caps and allocations
      for (int ABC_Loop=ABC_Loop_start; ABC_Loop<=ABC_Loop_end;ABC_Loop++)
      {
        totcatch=0.;
        if(ABC_Loop==1) Mgmt_quant(Fcast_catch_start+N_Fcast_Yrs+y-endyr)=0.0;   // for OFL
        Mgmt_quant(Fcast_catch_start+y-endyr)=0.0;  //  for ABC
        if(max(Do_Retain)>0) Mgmt_quant(Fcast_catch_start+2*N_Fcast_Yrs+y-endyr)=0.0;  // for retained ABC
        if(STD_Yr_Reverse_F(y)>0) F_std(STD_Yr_Reverse_F(y))=0.0;

        for (s=1;s<=nseas;s++)
        {
          t = t_base+s;
          if(WTage_rd>0)
          {
            for (g=1;g<=gmorph;g++)
            if(use_morph(g)>0)
            {
            Wt_Age_beg(s,g)=WTage_emp(t,GP3(g),0);
            Wt_Age_mid(s,g)=WTage_emp(t,GP3(g),-1);
            }
          }
          Save_Wt_Age(t)=Wt_Age_beg(s);

          bio_t=styr+(endyr-styr)*nseas+s-1;

          if(ABC_Loop==ABC_Loop_start)  // do seasonal ALK and fishery selex
          {
            if(timevary_MG(endyr+1,2)>0 || timevary_MG(endyr+1,3)>0 || WTage_rd>0)
            {
              subseas=1;  //   for begin of season   ALK_idx calculated within Make_AgeLength_Key
              ALK_idx=(s-1)*N_subseas+subseas;
              get_growth3(s, subseas);
              Make_AgeLength_Key(s, subseas);  //  begin season

              subseas=mid_subseas;
              ALK_idx=(s-1)*N_subseas+subseas;
              get_growth3(s, subseas);
              Make_AgeLength_Key(s, subseas);  //  for middle of season (begin of 3rd quarter)

//  SPAWN-RECR:   call Make_Fecundity in forecast
              if(s==spawn_seas)
              {
                subseas=spawn_subseas;
                ALK_idx=(s-1)*N_subseas+subseas;
                if(spawn_subseas!=1 && spawn_subseas!=mid_subseas)
                {
                  get_growth3(s, subseas);
                  Make_AgeLength_Key(s, subseas);  //  spawn subseas
                }
                Make_Fecundity();
              }
            }
            else
            {
              Ave_Size(t)=Ave_Size(t-nseas);
              Save_Wt_Age(t)=Wt_Age_beg(s);
            }

            for (g=1;g<=gmorph;g++)
            if(use_morph(g)>0)
            {
              Make_FishSelex();   // calcs fishery selex by current season, all fleets, current gmorph
            }
          }  //  end of seasonal biology

          if(s==nseas) {adv_age=1;} else {adv_age=0;}   //      advance age or not when doing survivorship

//  SPAWN-RECR:   calc area-specific spawning biomass in forecast
          if(s==spawn_seas && spawn_time_seas<0.0001)    //  get spawnbio in a forecast year
          {
            SPB_pop_gp(y).initialize();
            for (p=1;p<=pop;p++)
            {
              for (g=1;g<=gmorph;g++)
              if(sx(g)==1 && use_morph(g)>0)     //  female
              {
//                SPB_pop_gp(y,p,GP4(g)) += fec(g)*elem_prod(natage(t,p,g),mfexp(-Z_rate(t,p,g)*spawn_time_seas));   // accumulates SSB by area and by growthpattern
//                SPB_B_yr(y) += make_mature_bio(GP4(g))*elem_prod(natage(t,p,g),mfexp(-Z_rate(t,p,g)*spawn_time_seas));
//                SPB_N_yr(y) += make_mature_numbers(GP4(g))*elem_prod(natage(t,p,g),mfexp(-Z_rate(t,p,g)*spawn_time_seas));
                SPB_pop_gp(y,p,GP4(g)) += fec(g)*natage(t,p,g);   // accumulates SSB by area and by growthpattern
                SPB_B_yr(y) += make_mature_bio(GP4(g))*natage(t,p,g);
                SPB_N_yr(y) += make_mature_numbers(GP4(g))*natage(t,p,g);
              }
            }
            SPB_current=sum(SPB_pop_gp(y));
            SPB_yr(y)=SPB_current;

            if(Hermaphro_Option!=0)  // get male biomass
            {
              MaleSPB(y).initialize();
              for (p=1;p<=pop;p++)
              {
                for (g=1;g<=gmorph;g++)
                if(sx(g)==2 && use_morph(g)>0)     //  male; all assumed to be mature
                {
                  MaleSPB(y,p,GP4(g)) += Save_Wt_Age(t,g)*natage(t,p,g);   // accumulates SSB by area and by growthpattern
                }
              }
              if(Hermaphro_maleSPB==1)  // add MaleSPB to female SSB
              {
                SPB_current+=sum(MaleSPB(y));
                SPB_yr(y)=SPB_current;
              }
            }
//  SPAWN-RECR:   get recruitment in forecast;  needs to be area-specific
      if(SR_parm_timevary(1)==0)  //  R0 is not time-varying
      {R0_use=Recr_virgin; SPB_use=SPB_virgin;}
      else
      {
        R0_use=mfexp(SR_parm_work(1));
        equ_Recr=R0_use;
        Fishon=0;
        eq_yr=y;
        bio_yr=y;
        Do_Equil_Calc(R0_use);                      //  call function to do equilibrium calculation
        if(fishery_on_off==1) {Fishon=1;} else {Fishon=0;}
        SPB_use=SPB_equil;
      }

        Recruits=Spawn_Recr(SPB_use,R0_use,SPB_current);  // calls to function Spawn_Recr

            if(Fcast_Loop1<Fcast_Loop_Control(2))    //  use expected recruitment  this should include environ effect - CHECK THIS
            {
              Recruits=exp_rec(y,2);
              exp_rec(y,4)=exp_rec(y,2);  // within the spawn_recr function this has value with recrdev, so need to reset here
            }

//  SPAWN-RECR: distribute Recruitment of age 0 fish among the current and future settlements; and among areas and morphs
              for (g=1;g<=gmorph;g++)
              if(use_morph(g)>0)
              {
                settle=settle_g(g);  //  get settlement event
                for (p=1;p<=pop;p++)
                {
                  if(y==endyr+1) natage(t+Settle_seas_offset(settle),p,g,Settle_age(settle))=0.0;  //  to negate the additive code
                  natage(t+Settle_seas_offset(settle),p,g,Settle_age(settle)) = Recruits*recr_dist(GP(g),settle,p)*platoon_distr(GP2(g))*
                   mfexp(natM(s,GP3(g),Settle_age(settle))*Settle_timing_seas(settle));
                   //  the adjustment for mortality increases recruit value for elapsed time since begin of season because M will then be applied from beginning of season
                }
              }

          }  //  end of spawner-recruitment calculations

//  SPAWN-RECR:  total spawn bio used in F policy.  Make this area-specific too?
          if(ABC_Loop==1)  //  doing OFL this loop
          {
            ABC_buffer(y)=1.0;
          }
          else if(ABC_Loop==2 && s==1)  // Calc the buffer in season 1, will use last year's spawnbio if multiseas and spawnseas !=1
          {
            temp=SPB_Bmark;
            join1=1./(1.+mfexp(10.*(SPB_current-H4010_bot*temp)));
            join2=1./(1.+mfexp(10.*(SPB_current-H4010_top*temp)));

            if(HarvestPolicy==1)  // west coast
            {
              ABC_buffer(y) = H4010_scale*
              (
              (0.0001*SPB_current/(H4010_bot*temp) ) *(join1)   // low
              +(0.0001+(1.0-0.0001)*(H4010_top*temp/SPB_current)*(SPB_current-H4010_bot*temp)/(H4010_top*temp-H4010_bot*temp)) * (1.0-join1) // curve
              )
              *(join2)   // scale combo
              +
              (H4010_scale) * (1.0-join2);    // scale right side
            }
            else if(HarvestPolicy==2)  // Alaska
            {
              ABC_buffer(y) = H4010_scale*
              (
              (0.0001*SPB_current/(H4010_bot*temp) ) *(join1)   // low
              +(0.0001+(1.0-0.0001)*(SPB_current-H4010_bot*temp)/(H4010_top*temp-H4010_bot*temp)) * (1.0-join1)   // curve
              )
              *(join2)   // scale combo
              +
              (H4010_scale) * (1.0-join2);    // scale right side
            }
            else
            {
              ABC_buffer(y)=H4010_scale;
            }
          }  // end calc of ABC buffer
          else
          {  //  ABC buffer remains at previously calculated value
          }
          for (p=1;p<=pop;p++)  //  loop areas
          {
            totbio.initialize();smrybio.initialize(); smrynum.initialize();
            for (g=1;g<=gmorph;g++)
            if(use_morph(g)>0)
            {
              gg=sx(g);

              totbio+=natage(t,p,g)*Wt_Age_beg(s,g);
              temp=natage(t,p,g)(Smry_Age,nages)*Wt_Age_beg(s,g)(Smry_Age,nages);
              smrybio+=temp;
              smrynum+=sum(natage(t,p,g)(Smry_Age,nages));
              if(save_for_report==1)
              {
                Save_PopLen(t,p,g)=0.0;
                Save_PopLen(t,p+pop,g)=0.0;  // later put midseason here
                Save_PopWt(t,p,g)=0.0;
                Save_PopWt(t,p+pop,g)=0.0;  // later put midseason here
                Save_PopAge(t,p,g)=value(natage(t,p,g));
                for (a=0;a<=nages;a++)
                {
                  Save_PopLen(t,p,g)+=value(natage(t,p,g,a))*value(ALK(ALK_idx,g,a));
                  Save_PopWt(t,p,g)+= value(natage(t,p,g,a))*value(elem_prod(ALK(ALK_idx,g,a),wt_len(s,GP(g))));
                  Save_PopBio(t,p,g,a)=value(natage(t,p,g,a))*value(Wt_Age_beg(s,g,a));
                } // close age loop
              }
            }
            Tune_F_loops=1;
            for (f=1;f<=Nfleet;f++)
            if(fleet_type(f)<=2)
            {
              switch (ABC_Loop)
              {
                case 1:
                {
                  Hrate(f,t)=Fcast_Fmult*Fcast_RelF_Use(s,f);
                  break;  // no action, keep Hrate
                }
                case 2:
                {
                  Hrate(f,t)=ABC_buffer(y)*Fcast_Fmult*Fcast_RelF_Use(s,f);
                  if(N_Fcast_Input_Catches>0)
                  if(Fcast_InputCatch(t,f,1)>-1.0)  //  have an input
                  {
                    if(Fcast_InputCatch(t,f,2)<=3)  //  input is catch
                      {
                        if(Fcast_InputCatch(t,f,1)==0.0)
                        {
                          Hrate(f,t)=0.0;
                          Do_F_tune(t,f)=0;
                        }
                        else
                        {
                          Tune_F_loops=8;
                          Do_F_tune(t,f)=1;
                        }
                      }
                    else
                      {Hrate(f,t)=Fcast_InputCatch(t,f,1);}  // input is as Hrate (F), but do not need tuning
                  }
                  break;
                }
                case 3:  //  always get F to match catch when in ABC_Loop==3
                {
                  Tune_F_loops=8;
                  Do_F_tune(t,f)=1;
                  break;
                }
              }
            }
            if(F_Method==1)  //  Pope's
            {
              for (g=1;g<=gmorph;g++)
              if(use_morph(g)>0)
              {
                Nmid(g) = elem_prod(natage(t,p,g),surv1(s,GP3(g)));
              }

              for (Tune_F=1;Tune_F<=Tune_F_loops;Tune_F++)
              {
                for (f=1;f<=Nfleet;f++)   // get calculated catch
                if (fleet_area(f)==p && Fcast_RelF_Use(s,f)>0.0 && fleet_type(f)<=2)
                {
                  temp=0.0;
                  if(Do_F_tune(t,f)==1)  // have an input catch, so get expected catch from F and Z
                  {
                    if(ABC_Loop==2 && N_Fcast_Input_Catches>0)  //  tune to input catch
                    {
                      for (g=1;g<=gmorph;g++)
                      if(use_morph(g)>0)
                      {
                        if(catchunits(f)==1)  //  catch in weight
                        {
                          if(Fcast_InputCatch(t,f,2)==2)
                            {temp+=Nmid(g)*deadfish_B(s,g,f);}      // dead catch bio
                          else if(Fcast_InputCatch(t,f,2)==3)
                            {temp+=Nmid(g)*sel_al_2(s,g,f);}      // retained catch bio
                        }
                        else   //  catch in numbers
                        {
                          if(Fcast_InputCatch(t,f,2)==2)
                          {temp+=Nmid(g)*deadfish(s,g,f);}      // deadfish catch numbers
                          else if(Fcast_InputCatch(t,f,2)==3)
                          {temp+=Nmid(g)*sel_al_4(s,g,f);}      // retained catch numbers
                        }
                      }  //close gmorph loop
                      temp=max_harvest_rate-Fcast_InputCatch(t,f,1)/(temp+NilNumbers);
                      Hrate(f,t)=max_harvest_rate-posfun(temp,0.0001,Fcast_Crash);
                    }
                    else if (fishery_on_off==1) //  tune to adjusted catch calculated from ABC_Loop=2 (note different basis for catch)
                    {
                      for (g=1;g<=gmorph;g++)
                      if(use_morph(g)>0)
                      {
                        if(Fcast_Catch_Basis==2)
                        {temp+=Nmid(g)*deadfish_B(s,g,f);}      // dead catch bio
                        else if(Fcast_Catch_Basis==3)
                        {temp+=Nmid(g)*sel_al_2(s,g,f);}      // retained catch bio
                        else if(Fcast_Catch_Basis==5)
                        {temp+=Nmid(g)*deadfish(s,g,f);}      // deadfish catch numbers
                        else if(Fcast_Catch_Basis==6)
                        {temp+=Nmid(g)*sel_al_4(s,g,f);}      // retained catch numbers
                      }  //close gmorph loop
                      temp=max_harvest_rate-Fcast_Catch_Store(t,f)/(temp+NilNumbers);
                      Hrate(f,t)=max_harvest_rate-posfun(temp,0.0001,Fcast_Crash);
                    }
                  }  // end have fixed catch to be matched
                }  // end fishery loop
              }  //  end finding the Hrates
//  now get catch details and survivorship
              Nsurv=Nmid;  //  initialize the number of survivors
              for (f=1;f<=Nfleet;f++)       //loop over fishing fleets       SS_Label_105
              if (fleet_area(f)==p && fleet_type(f)<=2)
              {
                catch_fleet(t,f).initialize();
                temp=Hrate(f,t);
                for (g=1;g<=gmorph;g++)
                if(use_morph(g)>0)
                {
//                  Nmid(g) = elem_prod(natage(t,p,g),surv1(s,GP3(g)));
                  catch_fleet(t,f,1)+=Nmid(g)*sel_al_1(s,g,f);      // encountered catch bio
                  catch_fleet(t,f,2)+=Nmid(g)*deadfish_B(s,g,f);      // dead catch bio
                  catch_fleet(t,f,3)+=Nmid(g)*sel_al_2(s,g,f);      // retained catch bio
                  catch_fleet(t,f,4)+=Nmid(g)*sel_al_3(s,g,f);      // encountered catch numbers
                  catch_fleet(t,f,5)+=Nmid(g)*deadfish(s,g,f);      // deadfish catch numbers
                  catch_fleet(t,f,6)+=Nmid(g)*sel_al_4(s,g,f);      // retained catch numbers
                  catage_w(g)= temp*elem_prod(Nmid(g),deadfish(s,g,f));
                  Nsurv(g)-=catage_w(g);
                }  //close gmorph loop
                catch_fleet(t,f)*=temp;
              }  // close fishery
              for (g=1;g<=gmorph;g++)
              if(use_morph(g)>0)
              {
                j=Settle_age(settle);
                if(s<nseas && Settle_seas(settle)<=s) natage(t+1,p,g,j) = Nsurv(g,j)*surv1(s,GP3(g),j);  // advance age zero within year
                for (a=j+1;a<nages;a++)
                {
                  natage(t+1,p,g,a) = Nsurv(g,a-adv_age)*surv1(s,GP3(g),a-adv_age);
                  Z_rate(t,p,g,a)=-log(natage(t+1,p,g,a)/natage(t,p,g,a-adv_age))/seasdur(s);
                }
                natage(t+1,p,g,nages) = Nsurv(g,nages)*surv1(s,GP3(g),nages);   // plus group
                if(s==nseas) natage(t+1,p,g,nages) += Nsurv(g,nages-1)*surv1(s,GP3(g),nages-1);
                if(save_for_report==1)
                {
                  j=p+pop;
                  for (a=0;a<=nages;a++)
                  {
                    Save_PopLen(t,j,g)+=value(0.5*(Nmid(g,a)+Nsurv(g,a)))*value(ALK(ALK_idx,g,a));
                    Save_PopWt(t,j,g)+= value(0.5*(Nmid(g,a)+Nsurv(g,a)))*value(elem_prod(ALK(ALK_idx,g,a),wt_len(s,GP(g))));
                    Save_PopAge(t,j,g,a)=value(0.5*(Nmid(g,a)+Nsurv(g,a)));
                    Save_PopBio(t,j,g,a)=value(0.5*(Nmid(g,a)+Nsurv(g,a)))*value(Wt_Age_beg(s,g,a));
                  } // close age loop
                }
              }
            }  //  end Fmethod=1 pope

            else  //  continuous F
            {
              for (Tune_F=1;Tune_F<=Tune_F_loops;Tune_F++)  //  tune F to match catch
              {
                for (g=1;g<=gmorph;g++)
                if(use_morph(g)>0)
                {
                  Z_rate(t,p,g)=natM(s,GP3(g));
                  for (f=1;f<=Nfleet;f++)       //loop over fishing fleets to get Z
                  if (fleet_area(f)==p && Fcast_RelF_Use(s,f)>0.0 && fleet_type(f)<=2)
                  {
                    Z_rate(t,p,g)+=deadfish(s,g,f)*Hrate(f,t);
                  }
                  Zrate2(p,g)=elem_div( (1.-mfexp(-seasdur(s)*Z_rate(t,p,g))), Z_rate(t,p,g));
                }  //  end morph

                for (f=1;f<=Nfleet;f++)   // get calculated catch
                if (fleet_area(f)==p && Fcast_RelF_Use(s,f)>0.0 && fleet_type(f)<=2)
                {
                  temp=0.0;
                  if(Do_F_tune(t,f)==1)  // have an input catch, so get expected catch from F and Z
                  {
                    if(ABC_Loop==2 && N_Fcast_Input_Catches>0)  //  tune to input catch
                    {
                      for (g=1;g<=gmorph;g++)
                      if(use_morph(g)>0)
                      {
                        if(catchunits(f)==1)  //  catch in weight
                        {
                          if(Fcast_InputCatch(t,f,2)==2)
                            {temp+=elem_prod(natage(t,p,g),deadfish_B(s,g,f))*Zrate2(p,g);}      // dead catch bio
                          else if(Fcast_InputCatch(t,f,2)==3)
                            {temp+=elem_prod(natage(t,p,g),sel_al_2(s,g,f))*Zrate2(p,g);}      // retained catch bio
                        }
                        else   //  catch in numbers
                        {
                          if(Fcast_InputCatch(t,f,2)==2)
                          {temp+=elem_prod(natage(t,p,g),deadfish(s,g,f))*Zrate2(p,g);}      // deadfish catch numbers
                          else if(Fcast_InputCatch(t,f,2)==3)
                          {temp+=elem_prod(natage(t,p,g),sel_al_4(s,g,f))*Zrate2(p,g);}      // retained catch numbers
                        }
                      }  //close gmorph loop
                      temp*=Hrate(f,t);
                      H_temp(f)=Hrate(f,t);
                      C_temp(f)=temp;
                      if(Tune_F<3)
                      {
                        C_old(f)=C_temp(f);
                        H_old(f)=H_temp(f);
                        Hrate(f,t)*=(Fcast_InputCatch(t,f,1)+1.0)/(temp+1.0);  //  apply adjustment
                      }
                      else
                      {
                        Hrate(f,t)=H_old(f)+(H_temp(f)-H_old(f))/(C_temp(f)-C_old(f)+1.0e-6) * (Fcast_InputCatch(t,f,1)-C_old(f));
                        C_old(f)=C_temp(f);
                        H_old(f)=H_temp(f);
                      }
                    }
                    else if (fishery_on_off==1) //  tune to adjusted catch calculated in ABC_Loop=2 (note different basis for catch)
                    {
                      for (g=1;g<=gmorph;g++)
                      if(use_morph(g)>0)
                      {
                        if(Fcast_Catch_Basis==2)
                        {temp+=elem_prod(natage(t,p,g),deadfish_B(s,g,f))*Zrate2(p,g);}      // dead catch bio
                        else if(Fcast_Catch_Basis==3)
                        {temp+=elem_prod(natage(t,p,g),sel_al_2(s,g,f))*Zrate2(p,g);}      // retained catch bio
                        else if(Fcast_Catch_Basis==5)
                        {temp+=elem_prod(natage(t,p,g),deadfish(s,g,f))*Zrate2(p,g);}      // deadfish catch numbers
                        else if(Fcast_Catch_Basis==6)
                        {temp+=elem_prod(natage(t,p,g),sel_al_4(s,g,f))*Zrate2(p,g);}      // retained catch numbers
                      }  //close gmorph loop
                      temp*=Hrate(f,t);
//                      Hrate(f,t)*=(Fcast_Catch_Store(t,f)+1.0)/(temp+1.0);  //  apply adjustment
                      H_temp(f)=Hrate(f,t);
                      C_temp(f)=temp;
                      if(Tune_F<3)
                      {
                        C_old(f)=C_temp(f);
                        H_old(f)=H_temp(f);
                        Hrate(f,t)*=(Fcast_Catch_Store(t,f)+1.0)/(temp+1.0);  //  apply adjustment
                      }
                      else
                      {
                        if(Tune_F<7)
                        {Hrate(f,t)=(H_old(f)+(H_temp(f)-H_old(f))/(C_temp(f)-C_old(f)+1.0e-6) * (Fcast_Catch_Store(t,f)-C_old(f)));}
                        else if(Tune_F==7)
                        {Hrate(f,t)=(H_old(f)+(H_temp(f)-H_old(f))/(C_temp(f)-C_old(f)+1.0e-6) * (Fcast_Catch_Store(t,f)-C_old(f)));}
                        C_old(f)=C_temp(f);
                        H_old(f)=H_temp(f);
                      }
                    }
                  }  // end have fixed catch to be matched
                }  // end fishery loop
//                    if(y==endyr+2) report5<<"Tune "<<Fcast_Loop1<<" "<<ABC_Loop<<" "<<Tune_F<<" "<<Fcast_Catch_Store(t,2)<<" "<<temp<<" "<<Hrate(2,t)<<endl;
              }  //  done tuning F
              for (f=1;f<=Nfleet;f++)       //loop over fishing fleets       SS_Label_105
              if (fleet_area(f)==p && fleet_type(f)<=2)
              {
                catch_fleet(t,f).initialize();
                for (g=1;g<=gmorph;g++)
                if(use_morph(g)>0)
                {
                  tempvec_a=Hrate(f,t)*Zrate2(p,g);
                  catch_fleet(t,f,1)+=tempvec_a*elem_prod(natage(t,p,g),sel_al_1(s,g,f));      // encountered catch bio
                  catch_fleet(t,f,2)+=tempvec_a*elem_prod(natage(t,p,g),deadfish_B(s,g,f));      // dead catch bio
                  catch_fleet(t,f,3)+=tempvec_a*elem_prod(natage(t,p,g),sel_al_2(s,g,f));      // retained catch bio
                  catch_fleet(t,f,4)+=tempvec_a*elem_prod(natage(t,p,g),sel_al_3(s,g,f));      // encountered catch numbers
                  catch_fleet(t,f,5)+=tempvec_a*elem_prod(natage(t,p,g),deadfish(s,g,f));      // deadfish catch numbers
                  catch_fleet(t,f,6)+=tempvec_a*elem_prod(natage(t,p,g),sel_al_4(s,g,f));      // retained catch numbers
                }  //close gmorph loop

              }  // close fishery

              for (g=1;g<=gmorph;g++)
              if(use_morph(g)>0)
              {
                if(s<nseas) natage(t+1,p,g,0) = natage(t,p,g,0)*mfexp(-Z_rate(t,p,g,0)*seasdur(s));  // advance age zero within year
                for (a=1;a<nages;a++) {natage(t+1,p,g,a) = natage(t,p,g,a-adv_age)*mfexp(-Z_rate(t,p,g,a-adv_age)*seasdur(s));}
                natage(t+1,p,g,nages) = natage(t,p,g,nages)*mfexp(-Z_rate(t,p,g,nages)*seasdur(s));   // plus group
                if(s==nseas) natage(t+1,p,g,nages) += natage(t,p,g,nages-1)*mfexp(-Z_rate(t,p,g,nages-1)*seasdur(s));
                if(save_for_report==1)
                {
                  j=p+pop;
                  for (a=0;a<=nages;a++)
                  {
                    Save_PopLen(t,j,g)+=value(natage(t,p,g,a)*mfexp(-Z_rate(t,p,g,a)*0.5*seasdur(s)))*value(ALK(ALK_idx,g,a));
                    Save_PopWt(t,j,g)+= value(natage(t,p,g,a)*mfexp(-Z_rate(t,p,g,a)*0.5*seasdur(s)))*value(elem_prod(ALK(ALK_idx,g,a),wt_len(s,GP(g))));
                    Save_PopAge(t,j,g,a)=value(natage(t,p,g,a)*mfexp(-Z_rate(t,p,g,a)*0.5*seasdur(s)));
                    Save_PopBio(t,j,g,a)=value(natage(t,p,g,a)*mfexp(-Z_rate(t,p,g,a)*0.5*seasdur(s)))*value(Wt_Age_mid(s,g,a));
                  } // close age loop
                }
              }  // end morph loop
            }  // end continuous F


  //  SS_Label_Info_24.3.4 #Compute spawning biomass if occurs after start of current season
//  SPAWN-RECR:   calc spawn biomass in time series if after beginning of the season
      if(s==spawn_seas && spawn_time_seas>=0.0001)    //  compute spawning biomass
      {
        SPB_pop_gp(y).initialize();
        for (p=1;p<=pop;p++)
        {
          for (g=1;g<=gmorph;g++)
          if(sx(g)==1 && use_morph(g)>0)     //  female
          {
            SPB_pop_gp(y,p,GP4(g)) += fec(g)*elem_prod(natage(t,p,g),mfexp(-Z_rate(t,p,g)*spawn_time_seas));   // accumulates SSB by area and by growthpattern
            SPB_B_yr(y) += make_mature_bio(GP4(g))*elem_prod(natage(t,p,g),mfexp(-Z_rate(t,p,g)*spawn_time_seas));
            SPB_N_yr(y) += make_mature_numbers(GP4(g))*elem_prod(natage(t,p,g),mfexp(-Z_rate(t,p,g)*spawn_time_seas));
          }
        }
        SPB_current=sum(SPB_pop_gp(y));
        SPB_yr(y)=SPB_current;

        if(Hermaphro_Option!=0)  // get male biomass
        {
          MaleSPB(y).initialize();
          for (p=1;p<=pop;p++)
          {
            for (g=1;g<=gmorph;g++)
            if(sx(g)==2 && use_morph(g)>0)     //  male; all assumed to be mature
            {
              MaleSPB(y,p,GP4(g)) += Save_Wt_Age(t,g)*elem_prod(natage(t,p,g),mfexp(-Z_rate(t,p,g)*spawn_time_seas));   // accumulates SSB by area and by growthpattern
            }
          }
          if(Hermaphro_maleSPB==1) // add MaleSPB to female SSB
          {
            SPB_current+=sum(MaleSPB(y));
            SPB_yr(y)=SPB_current;
          }
        }
  //  SS_Label_Info_24.3.4.1 #Get recruitment from this spawning biomass
//  SPAWN-RECR:   calc recruitment in time series; need to make this area-specififc
      if(SR_parm_timevary(1)==0)  //  R0 is not time-varying
      {R0_use=Recr_virgin; SPB_use=SPB_virgin;}
      else
      {
        R0_use=mfexp(SR_parm_work(1));
        equ_Recr=R0_use;
        Fishon=0;
        eq_yr=y;
        bio_yr=y;
        Do_Equil_Calc(equ_Recr);                      //  call function to do equilibrium calculation
        if(fishery_on_off==1) {Fishon=1;} else {Fishon=0;}
        SPB_use=SPB_equil;
      }

        Recruits=Spawn_Recr(SPB_use,R0_use,SPB_current);  // calls to function Spawn_Recr
// distribute Recruitment of age 0 fish among the current and future settlements; and among areas and morphs
//  note that because SPB_current is calculated at end of season to take into account Z,
//  this means that recruitment cannot occur until a subsequent season
//  SPAWN-RECR:   distribute recruits among areas, settlements, morphs
          for (g=1;g<=gmorph;g++)
          if(use_morph(g)>0)
          {
            settle=settle_g(g);
            for (p=1;p<=pop;p++)
            {
              if(y==styr) natage(t+Settle_seas_offset(settle),p,g,Settle_age(settle))=0.0;  //  to negate the additive code

              natage(t+Settle_seas_offset(settle),p,g,Settle_age(settle)) += Recruits*recr_dist(GP(g),settle,p)*platoon_distr(GP2(g))*
               mfexp(natM(s,GP3(g),Settle_age(settle))*Settle_timing_seas(settle));
            }
          }
      }

//  SS_Label_106  call to Get_expected_values
//            Get_expected_values();

            if(Hermaphro_Option!=0)  //hermaphroditism
            {
              if(Hermaphro_seas==-1 || Hermaphro_seas==s)
              {
                k=gmorph/2;
                for (g=1;g<=k;g++)  //  loop females
                if(use_morph(g)>0)
                {
                  if(Hermaphro_Option==1)
                  {
                    for (a=1;a<nages;a++)
                    {
                      natage(t+1,p,g+k,a) += natage(t+1,p,g,a)*Hermaphro_val(GP4(g),a-1); // increment males with females
                      natage(t+1,p,g,a) *= (1.-Hermaphro_val(GP4(g),a-1)); // decrement females
                    }
                  } else
                  if(Hermaphro_Option==-1)
                  {
                    for (a=1;a<nages;a++)
                    {
                      natage(t+1,p,g,a) += natage(t+1,p,g+k,a)*Hermaphro_val(GP4(g+k),a-1); // increment females with males
                      natage(t+1,p,g+k,a) *= (1.-Hermaphro_val(GP4(g+k),a-1)); // decrement males
                    }
                  }
                }
              }
            }

           if(show_MSY==1)
           {
            report5<<p<<" "<<y<<" "<<ABC_Loop<<" "<<s<<" "<<ABC_buffer(y)<<" "<<totbio<<" "<<smrybio<<" ";
            if(s==spawn_seas)
            {
              report5<<SPB_current<<" ";
              report5<<SPB_current/SPB_Bmark<<" "<<Recruits;
            }
            else
            {report5<<0<<" "<<0<<" "<<0;}
            for (f=1;f<=Nfleet;f++)
            {
              if(fleet_type(f)<=2)
              {
            if(fleet_area(f)==p)
            {
              if(F_Method==1)
              {report5<<" "<<catch_fleet(t,f)(1,6)<<" "<<Hrate(f,t);}
              else
              {report5<<" "<<catch_fleet(t,f)(1,6)<<" "<<Hrate(f,t)*seasdur(s);}
            }
            else
            {report5<<" - - - - - - - ";}

            if(N_Fcast_Input_Catches==0)
              {
                report5<<" R ";
              }
            else
              {
                if(Fcast_InputCatch(t,f,1)<0.0) {report5<<" R ";} else {report5<<" C ";}}
             }
            }
            if(s==nseas&&Fcast_MaxAreaCatch(p)>0.) {report5<<" "<<Fcast_MaxAreaCatch(p);} else {report5<<" NA ";} //  a max catch has been set for this area
           }
           if(p<pop && show_MSY==1) report5<<endl;
           if(s==1&&Fcast_Loop1==Fcast_Loop_Control(1))
           {
             Smry_Table(y,1)+=totbio;
             Smry_Table(y,2)+=smrybio;  // in forecast
             Smry_Table(y,3)+=smrynum;   //sums to accumulate across platoons and settlements
           }
          }  //  end loop of areas

          if(do_migration>0)  // movement between areas in forecast
          {
            natage_temp=natage(t+1);
            natage(t+1).initialize();
            for (p=1;p<=pop;p++)  //   source population
            for (p2=1;p2<=pop;p2++)  //  destination population
            for (g=1;g<=gmorph;g++)
            if(use_morph(g)>0)
              {
            	 k=move_pattern(s,GP4(g),p,p2);
              if(k>0) natage(t+1,p2,g) += elem_prod(natage_temp(p,g),migrrate(bio_yr,k));
              }
          }

          if( (save_for_report>0) || ((sd_phase() || mceval_phase()) && (initial_params::mc_phase==0)) )
          {

            if(Fcast_Loop1==2 && ABC_Loop==1)  // get variance in OFL
            {
              for (f=1;f<=Nfleet;f++)
              {
                if(fleet_type(f)<=2)
              {Mgmt_quant(Fcast_catch_start+N_Fcast_Yrs+y-endyr)+=catch_fleet(t,f,2);}
              }
            }

            if(Fcast_Loop1==Fcast_Loop_Control(1) && ABC_Loop==3)  //  in final loop, so do variance quantities
            {
              if(STD_Yr_Reverse_F(y)>0)
              {
                if(F_reporting<=1)
                {
                  for (f=1;f<=Nfleet;f++)
                  {
                    if(fleet_type(f)<=2)
                    {F_std(STD_Yr_Reverse_F(y))+=catch_fleet(t,f,2);}   // add up dead catch biomass
                  }
                  if(s==nseas) F_std(STD_Yr_Reverse_F(y))/=Smry_Table(y,2);
                }
                else if(F_reporting==2)
                {
                  for (f=1;f<=Nfleet;f++)
                  {
                    if(fleet_type(f)<=2)
                    {F_std(STD_Yr_Reverse_F(y))+=catch_fleet(t,f,5);}   // add up dead catch numbers
                  }
                  if(s==nseas) F_std(STD_Yr_Reverse_F(y))/=Smry_Table(y,3);
                }
                else if(F_reporting==3)
                {
                  if(F_Method==1)
                  {
                    for (f=1;f<=Nfleet;f++)
                    {
                      if(fleet_type(f)<=2)
                      {F_std(STD_Yr_Reverse_F(y))+=Hrate(f,t);}
                    }
                  }
                  else
                  {
                    for (f=1;f<=Nfleet;f++)
                    {
                      if(fleet_type(f)<=2)
                      {F_std(STD_Yr_Reverse_F(y))+=Hrate(f,t)*seasdur(s);}
                    }
                  }
                }
                else if(F_reporting==4 && s==nseas)
                {
        //  sum across p and g the number of survivors to end of the year
        //  also project from the initial numbers and M, the number of survivors without F
        //  then F = ln(n+1/n)(M+F) - ln(n+1/n)(M only), but ln(n) cancels out, so only need the ln of the ratio of the two ending quantities
                  temp1=0.0;
                  temp2=0.0;
                  for (g=1;g<=gmorph;g++)
                  if(use_morph(g)>0)
                  {
                    for (p=1;p<=pop;p++)
                    {
                      for (a=F_reporting_ages(1);a<=F_reporting_ages(2);a++)   //  should not let a go higher than nages-2 because of accumulator
                      {
                        if(nseas==1)
                        {
                          temp1+=natage(t+1,p,g,a+1);
                          temp2+=natage(t,p,g,a)*mfexp(-seasdur(s)*natM(s,GP3(g),a));
                        }
                        else
                        {
                          temp1+=natage(t+1,p,g,a+1);
                          temp3=natage(t-nseas+1,p,g,a);  //  numbers at begin of year
                          for (j=1;j<=nseas;j++) {temp3*=mfexp(-seasdur(j)*natM(j,GP3(g),a));}
                          temp2+=temp3;
                        }
                      }
                    }
                  }
                  F_std(STD_Yr_Reverse_F(y)) = log(temp2)-log(temp1);
                }
              }
              for (f=1;f<=Nfleet;f++)
              {
                if(fleet_type(f)<=2)
                {
                  Mgmt_quant(Fcast_catch_start+y-endyr)+=catch_fleet(t,f,2);
                  if(max(Do_Retain)>0) Mgmt_quant(Fcast_catch_start+2*N_Fcast_Yrs+y-endyr)+=catch_fleet(t,f,3);
                }
              }
            }
          }

          //  store catches to allow calc of adjusted F to match this catch when doing ABC_loop=3, and then when doing Fcast_loop1=3
          for (f=1;f<=Nfleet;f++)
          {
            if(fleet_type(f)<=2)
            {
              Fcast_Catch_Store(t,f)=catch_fleet(t,f,Fcast_Catch_Basis);
              totcatch+=Fcast_Catch_Store(t,f);
            }
          }

          if(show_MSY==1)
          {
            if(s==nseas) {report5<<" "<<totcatch<<" ";} else {report5<<" NA ";}
            if(s==nseas && STD_Yr_Reverse_F(y)>0) {report5<<F_std(STD_Yr_Reverse_F(y));} else {report5<<" NA ";}
            report5<<endl;
          }
        }  //  end loop of seasons

        if(ABC_Loop==2)
        {
          // calculate annual catch for each fleet
          Fcast_Catch_Calc_Annual.initialize();
          for (f=1;f<=Nfleet;f++)
          for (s=1;s<=nseas;s++)
          {
            if(fleet_type(f)<=2)
              {
              t=t_base+s;
              Fcast_Catch_Calc_Annual(f)+=catch_fleet(t,f,Fcast_Catch_Basis); //  accumulate annual catch according to catch basis (2=deadbio, 3=ret bio, 5=dead num, 6=ret num)
              }
          }
          if(Fcast_Do_Fleet_Cap>0 && y>=Fcast_Cap_FirstYear)
          {
            for (f=1;f<=Nfleet;f++)   //  adjust ABC catch to fleet caps
            {
              if(Fcast_MaxFleetCatch(f)>0. && fleet_type(f)<=2)
              {
                temp = Fcast_Catch_Calc_Annual(f)/Fcast_MaxFleetCatch(f);
                join1=1./(1.+mfexp(1000.*(temp-1.0)));  // steep logistic joiner at adjustment of 1.0
                temp1=join1*1.0 + (1.-join1)*temp;
                Fcast_Catch_Calc_Annual(f)/=temp1;
                for (s=1;s<=nseas;s++)
                {Fcast_Catch_Store(t_base+s,f)/=temp1;}
              }
            }
          }
          if(Fcast_Do_Area_Cap>0  && y>=Fcast_Cap_FirstYear)  // scale down if Totcatch exceeds Fcast_MaxAreaCatch (in this area)
          {
            if(pop==1)  // one area
            {
              Fcast_Catch_ByArea(1)=sum(Fcast_Catch_Calc_Annual(1,Nfleet));
            }
            else
            {
              Fcast_Catch_ByArea=0.0;
              for (f=1;f<=Nfleet;f++)
              {
                if(fleet_type(f)<=2)
                {
                  Fcast_Catch_ByArea(fleet_area(f))+=Fcast_Catch_Calc_Annual(f);
                }
              }
            }
            for (p=1;p<=pop;p++)
            if(Fcast_MaxAreaCatch(p)>0.0)
            {
              temp = Fcast_Catch_ByArea(p)/Fcast_MaxAreaCatch(p);
              join1=1./(1.+mfexp(1000.*(temp-1.0)));  // steep logistic joiner at adjustment of 1.0
              temp1=join1*1.0 + (1.-join1)*temp;
              for (f=1;f<=Nfleet;f++)
              if (fleet_area(f)==p && fleet_type(f)<=2)
              {
                Fcast_Catch_Calc_Annual(f)/=temp1;  // adjusts total for the year
                for (s=1;s<=nseas;s++)
                {Fcast_Catch_Store(t_base+s,f)/=temp1;}
              }
            }
//            report5<<Tune_F<<" tune_area"<<Fcast_Catch_Calc_Annual<<endl;
          }
          if(Fcast_Catch_Allocation_Groups>0  && y>=Fcast_Cap_FirstYear)  // adjust to get a specific fleet allocation
          {
            Fcast_Catch_Allocation_Group.initialize();
            for (g=1;g<=Fcast_Catch_Allocation_Groups;g++)
            for (f=1;f<=Nfleet;f++)
            if (Allocation_Fleet_Assignments(f)==g && fleet_type(f)<=2)
            {
               Fcast_Catch_Allocation_Group(g)+=Fcast_Catch_Calc_Annual(f);
            }
            temp=sum(Fcast_Catch_Allocation_Group);  // total catch for all fleets that are part of the allocation scheme
            temp1=sum(Fcast_Catch_Allocation(y-endyr));  // total of all allocation fractions for all fleets that are part of the allocation scheme
            for (g=1;g<=Fcast_Catch_Allocation_Groups;g++)
            {
              temp2=(Fcast_Catch_Allocation(y-endyr,g)/temp1) / (Fcast_Catch_Allocation_Group(g)/temp);
              for (f=1;f<=Nfleet;f++)
              if (Allocation_Fleet_Assignments(f)==g && fleet_type(f)<=2)
              {
                Fcast_Catch_Calc_Annual(f)*=temp2;
                for (s=1;s<=nseas;s++)
                {
                  Fcast_Catch_Store(t_base+s,f)*=temp2;
                }
              }
            }
          }  //  end allocation among groups
        }
      }  //  end ABC_Loop

      if( (Fcast_Loop1==Fcast_Loop_Control(1) && (save_for_report>0)) || ((sd_phase() || mceval_phase()) && (initial_params::mc_phase==0)) )
      {
        eq_yr=y; equ_Recr=Recr_Bmark; bio_yr=endyr;
        Fishon=0;
        Do_Equil_Calc(equ_Recr);                      //  call function to do equilibrium calculation

        SPR_unf=SPB_equil;
        Smry_Table(y,11)=SPR_unf;
        Smry_Table(y,13)=GenTime;
        Fishon=1;
        Do_Equil_Calc(equ_Recr);                      //  call function to do equilibrium calculation
        SPR_trial=SPB_equil;
        if(STD_Yr_Reverse_Ofish(y)>0) SPR_std(STD_Yr_Reverse_Ofish(y))=SPR_trial/SPR_unf;
        Smry_Table(y,9)=totbio;
        Smry_Table(y,10)=smrybio;
        Smry_Table(y,12)=SPR_trial;
        Smry_Table(y,14)=YPR_dead;
        for (g=1;g<=gmorph;g++)
        {
          Smry_Table(y,20+g)=(cumF(g));
          Smry_Table(y,20+gmorph+g)=(maxF(g));
        }
      }

    }  //  end year loop
    if(save_for_report==2) save_for_report=1;
  }  //  end Fcast_Loop1  for the different stages of the forecast

  }
//  end forecast function

