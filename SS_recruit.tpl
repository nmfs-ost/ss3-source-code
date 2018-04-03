//********************************************************************
 /*  SS_Label_FUNCTION 43 Spawner-recruitment function */
//  SPAWN-RECR:   function: to calc R from S
FUNCTION dvariable Spawn_Recr(const prevariable& SSB_virgin_adj, const prevariable& Recr_virgin_adj, const prevariable& SSB_current)
  {
    dvariable NewRecruits;
    dvariable SSB_BH1;
    dvariable recdev_offset;
    dvariable steepness;
    dvariable Shepherd_c;
    dvariable Shepherd_c2;
    dvariable Hupper;
    dvariable steep2;
    dvariable SSB_curr_adj;
    dvariable join;
    dvariable SRZ_0;
    dvariable SRZ_max;
    dvariable SRZ_surv;

//  SS_Label_43.1  add 0.1 to input spawning biomass value to make calculation more rebust
    SSB_curr_adj = SSB_current + 0.100;   // robust

    regime_change=SR_parm_work(N_SRparm2-1);  //  this is a persistent deviation off the S/R curve
   
//  SS_Label_43.3  calculate expected recruitment from the input spawning biomass and the SR curve
// functions below use Recr_virgin_adj,SSB_virgin_adj which could have been adjusted adjusted above from R0,SSB_virgin
    switch(SR_fxn)
    {
      case 1: // previous placement for B-H constrained
      {
        N_warn++; cout<<"Critical error:  see warning"<<endl; warning<<"B-H constrained curve is now Spawn-Recr option #6"<<endl; exit(1);
        break;
      }
//  SS_Label_43.3.2  Ricker
      case 2:  // ricker
      {
        steepness=SR_parm_work(2);
        NewRecruits = Recr_virgin_adj*SSB_curr_adj/SSB_virgin_adj * mfexp(steepness*(1.-SSB_curr_adj/SSB_virgin_adj));
        break;
      }
//  SS_Label_43.3.3  Beverton-Holt
      case 3: // Beverton-Holt
      {
        steepness=SR_parm_work(2);
        alpha = 4.0 * steepness*Recr_virgin / (5.*steepness-1.);
        beta = (SSB_virgin_adj*(1.-steepness)) / (5.*steepness-1.);
        NewRecruits =  (4.*steepness*Recr_virgin_adj*SSB_curr_adj) /
                       (SSB_virgin_adj*(1.-steepness)+(5.*steepness-1.)*SSB_curr_adj);
        break;
      }
//  SS_Label_43.3.4  constant expected recruitment
      case 4:  // none
      {
        NewRecruits=Recr_virgin_adj;
        break;
      }
//  SS_Label_43.3.5  Hockey stick
      case 5:  // hockey stick  where "steepness" is now the fraction of B0 below which recruitment declines linearly
               //  the 3rd parameter allows for a minimum recruitment level
      {
        steepness=SR_parm_work(2);
        temp=SR_parm_work(3)*Recr_virgin_adj + SSB_curr_adj/(steepness*SSB_virgin_adj)*(Recr_virgin_adj-SR_parm_work(3)*Recr_virgin_adj);  //  linear decrease below steepness*SSB_virgin_adj
        NewRecruits=Join_Fxn(0.0*SSB_virgin_adj,SSB_virgin_adj,steepness*SSB_virgin_adj, SSB_curr_adj, temp, Recr_virgin_adj);
        break;
      }

//  SS_Label_43.3.6  Beverton-Holt, with constraint to have constant R about Bzero
      case 6: //Beverton-Holt constrained
      {
        steepness=SR_parm_work(2);
        alpha = 4.0 * steepness*Recr_virgin / (5.*steepness-1.);
        beta = (SSB_virgin_adj*(1.-steepness)) / (5.*steepness-1.);
        if(SSB_curr_adj>SSB_virgin_adj) {SSB_BH1=SSB_virgin_adj;} else {SSB_BH1=SSB_curr_adj;}
        NewRecruits=(4.*steepness*Recr_virgin_adj*SSB_BH1) / (SSB_virgin_adj*(1.-steepness)+(5.*steepness-1.)*SSB_BH1);
        break;
      }

//  SS_Label_43.3.7  survival based
      case 7:  // survival based, so constrained such that recruits cannot exceed fecundity
      {
        // PPR_0=SSB_virgin_adj/Recr_virgin_adj;  //  pups per recruit at virgin
        // Surv_0=1./PPR_0;   //  recruits per pup at virgin
        // Pups_0=SSB_virgin_adj;  //  total population fecundity is the number of pups produced
        // Sfrac=SR_parm(2);
        SRZ_0=log(1.0/(SSB_virgin_adj/Recr_virgin_adj));
        SRZ_max=SRZ_0+SR_parm_work(2)*(0.0-SRZ_0);
        SRZ_surv=mfexp((1.-pow((SSB_curr_adj/SSB_virgin_adj),SR_parm_work(3)) )*(SRZ_max-SRZ_0)+SRZ_0);  //  survival
        NewRecruits=SSB_curr_adj*SRZ_surv;
        exp_rec(y,1)=NewRecruits;   // expected arithmetic mean recruitment
//  SS_Label_43.3.7.1  Do variation in recruitment by adjusting survival
//        if(SR_env_target==1) SRZ_surv*=mfexp(SR_parm(N_SRparm2-2)* env_data(y,SR_env_link));   // environ effect on survival
        if(recdev_cycle>0)
        {
          gg=y - (styr+(int((y-styr)/recdev_cycle))*recdev_cycle)+1;
          SRZ_surv*=mfexp(recdev_cycle_parm(gg));
        }
        exp_rec(y,2)=SSB_curr_adj*SRZ_surv;
        SRZ_surv*=mfexp(-biasadj(y)*half_sigmaRsq);     // bias adjustment
        exp_rec(y,3)=SSB_curr_adj*SRZ_surv;
        if(y <=recdev_end)
        {
          if(recdev_doit(y)>0) SRZ_surv*=mfexp(recdev(y));  //  recruitment deviation
        }
        else if(Do_Forecast>0)
        {
          SRZ_surv *= mfexp(Fcast_recruitments(y));
        }
        join=1./(1.+mfexp(100*(SRZ_surv-1.)));
        SRZ_surv=SRZ_surv*join + (1.-join)*1.0;
        NewRecruits=SSB_curr_adj*SRZ_surv;
        exp_rec(y,4) = NewRecruits;
        break;
      }

//  SS_Label_43.3.8  Shepherd
      case 8:  // Shepherd 3-parameter SRR. per Punt & Cope 2017
      {
        Shepherd_c=SR_parm_work(3);
        Shepherd_c2=pow(0.2,SR_parm_work(3));
        Hupper=1.0/(5.0*Shepherd_c2);
        steepness=0.2+(SR_parm_work(2)-0.2)/(0.8)*(Hupper-0.2);
        temp=(SSB_curr_adj)/(SSB_virgin_adj);
        NewRecruits =  (5.*steepness*Recr_virgin_adj*(1.-Shepherd_c2)*temp) /
        (1.0 - 5.0*steepness*Shepherd_c2 + (5.*steepness-1.)*pow(temp,Shepherd_c));
        break;
      }

//  SS_Label_43.3.8  Ricker-power
      case 9:  // Ricker power 3-parameter SRR.  per Punt & Cope 2017
      {
        steepness = SR_parm_work(2);
        dvariable RkrPower=SR_parm_work(3);
        temp=SSB_curr_adj/SSB_virgin_adj;
        temp2 = posfun(1.0-temp,0.001,temp3);
        temp=1.0-temp2;  //  Rick's new line to stabilize recruitment at R0 if B>B0
        dvariable RkrTop =  log(5.0*steepness) * pow(temp2,RkrPower) / pow(0.8,RkrPower);
        NewRecruits = Recr_virgin_adj * temp * mfexp(RkrTop);
        break;
      }
    }

    if(SR_fxn!=7)
    {
//  SS_Label_43.4  For non-survival based SRR, get recruitment deviations by adjusting recruitment itself
      exp_rec(y,1)=NewRecruits;   // expected arithmetic mean recruitment
//    exp_rec(y,2) is with regime shift or other env effect;
//    exp_rec(y,3) is with bias adjustment
//    exp_rec(y,4) is with dev

      if(recdev_cycle>0)
      {
        gg=y - (styr+(int((y-styr)/recdev_cycle))*recdev_cycle)+1;
        NewRecruits*=mfexp(recdev_cycle_parm(gg));
      }
      NewRecruits*=mfexp(regime_change);  //  adjust for regime which includes env and block effects; and forecast adjustments
      exp_rec(y,2)=NewRecruits;  //  adjusted for env and special forecast conditions
      if(SR_fxn!=4) NewRecruits*=mfexp(-biasadj(y)*half_sigmaRsq);     // bias adjustment
      exp_rec(y,3)=NewRecruits;

      if(y<=recdev_end)
      {
        if(recdev_doit(y)>0) NewRecruits*=mfexp(recdev(y));  //  recruitment deviation
      }

      else if(Do_Forecast>0)
      {
        switch (int(Fcast_Loop_Control(3)))
        {
          case 0:
          {
            NewRecruits=exp_rec(y,2);
            if(SR_fxn!=4) NewRecruits*=mfexp(-biasadj(y)*half_sigmaRsq);     // bias adjustment
            exp_rec(y,3)=NewRecruits;
            break;
          }
          case 1:
          {
            exp_rec(y,2)*=Fcast_Loop_Control(4);  //  apply fcast multiplier to the regime-adjusted expected value
            NewRecruits=exp_rec(y,2);
            if(SR_fxn!=4) NewRecruits*=mfexp(-biasadj(y)*half_sigmaRsq);     // bias adjustment
            exp_rec(y,3)=NewRecruits;
            break;
          }
          case 2:  //  use multiplier of R0
          {
            exp_rec(y,2)=Recr_virgin_adj*Fcast_Loop_Control(4);  //  apply fcast multiplier to the virgin recruitment
            NewRecruits=exp_rec(y,2);
            if(SR_fxn!=4) NewRecruits*=mfexp(-biasadj(y)*half_sigmaRsq);     // bias adjustment
            exp_rec(y,3)=NewRecruits;
            break;
          }
          case 3:  //  use recent mean
          {
//  values going into the mean have already been bias adjusted and had dev applied, so take straight mean
            NewRecruits=0.0;
            for(j=recdev_end-int(Fcast_Loop_Control(4))+1; j<=recdev_end;j++)
            {
              NewRecruits+=exp_rec(j,4);
            }
            NewRecruits/=Fcast_Loop_Control(4);
            exp_rec(y,3)=NewRecruits;  //  store in the bias-adjusted field
            break;
          }
        }
        NewRecruits*=mfexp(Fcast_recruitments(y));  //  recruitment deviation
      }
      exp_rec(y,4)=NewRecruits;
    }
    return NewRecruits;
  }  //  end spawner_recruitment

//********************************************************************
 /*  SS_Label_FUNCTION 44 Equil_Spawn_Recr_Fxn */
//  SPAWN-RECR:   function  Equil_Spawn_Recr_Fxn
FUNCTION dvar_vector Equil_Spawn_Recr_Fxn(const prevariable &SRparm2, const prevariable &SRparm3, 
         const prevariable& SSB_virgin, const prevariable& Recr_virgin, const prevariable& SPR_temp)
  {
    RETURN_ARRAYS_INCREMENT();
    dvar_vector Equil_Spawn_Recr_Calc(1,2);  // values to return 1 is B_equil, 2 is R_equil
    dvariable B_equil;  
    dvariable R_equil;
    dvariable temp;
    dvariable steepness;
    dvariable join;
    dvariable Shepherd_c;
    dvariable Shepherd_c2;
    dvariable SRZ_0;
    dvariable SRZ_max;
    dvariable SRZ_surv;

    steepness=SRparm2;  //  common usage but some different
//  SS_Label_44.1  calc equilibrium SpawnBio and Recruitment from input SPR_temp, which is spawning biomass per recruit at some given F level
    switch(SR_fxn)
    {
      case 1: // previous placement for B-H constrained
      {
        N_warn++; cout<<"Critical error:  see warning"<<endl; warning<<"B-H constrained curve is now Spawn-Recr option #6"<<endl; exit(1);
        break;
      }
//  SS_Label_44.1.1  Beverton-Holt with flattop beyond Bzero
      case 6: //Beverton-Holt
      {
        alpha = 4.0 * steepness*Recr_virgin / (5.*steepness-1.);
        beta = (SSB_virgin*(1.-steepness)) / (5.*steepness-1.);
        B_equil=alpha * SPR_temp - beta;
        B_equil=posfun(B_equil,0.0001,temp);
        R_equil=(4.*steepness*Recr_virgin*B_equil) / (SSB_virgin*(1.-steepness)+(5.*steepness-1.)*B_equil);
        break;
      }
//  SS_Label_44.1.2  Ricker
      case 2: // Ricker
      {
        B_equil=SSB_virgin*(1.+(log(Recr_virgin/SSB_virgin)+log(SPR_temp))/steepness);
        R_equil=Recr_virgin*B_equil/SSB_virgin * mfexp(steepness*(1.-B_equil/SSB_virgin));
        
        break;
      }
//  SS_Label_44.1.3  Beverton-Holt
      case 3:  // same as case 6
      {
        alpha = 4.0 * steepness*Recr_virgin / (5.*steepness-1.);
        beta = (SSB_virgin*(1.-steepness)) / (5.*steepness-1.);
        B_equil=alpha * SPR_temp - beta;
        B_equil=posfun(B_equil,0.0001,temp);
        R_equil=(4.*steepness*Recr_virgin*B_equil) / (SSB_virgin*(1.-steepness)+(5.*steepness-1.)*B_equil); //Beverton-Holt
        break;
      }

//  SS_Label_44.1.4  constant recruitment
      case 4: // constant; no bias correction
      {
        B_equil=SPR_temp*Recr_virgin;  R_equil=Recr_virgin;
        break;
      }
//  SS_Label_44.1.5  Hockey Stick
      case 5: // hockey stick
      {
        alpha=SRparm3*Recr_virgin;  // min recruitment level
//        temp=SSB_virgin/R0*steepness;  // spawners per recruit at inflection
        beta=(Recr_virgin-alpha)/(steepness*SSB_virgin);   //  slope of recruitment on spawners below the inflection
        B_equil=Join_Fxn(0.0*SSB_virgin/Recr_virgin, SSB_virgin/Recr_virgin, SSB_virgin/Recr_virgin*steepness, SPR_temp, alpha/((1./SPR_temp)-beta), SPR_temp*Recr_virgin);
        R_equil=Join_Fxn(0.0*SSB_virgin, SSB_virgin, SSB_virgin*steepness, B_equil, alpha+beta*B_equil, Recr_virgin);
        break;
      }
//  SS_Label_44.1.7  3 parameter survival based
      case 7:  // survival
      {
        SRZ_0=log(1.0/(SSB_virgin/Recr_virgin));
        SRZ_max=SRZ_0+steepness*(0.0-SRZ_0);
        B_equil = SSB_virgin * (1. - (log(1./SPR_temp) - SRZ_0)/pow((SRZ_max - SRZ_0),(1./SRparm3) ));
        SRZ_surv=mfexp((1.-pow((B_equil/SSB_virgin),SRparm3) )*(SRZ_max-SRZ_0)+SRZ_0);  //  survival
        R_equil=B_equil*SRZ_surv;
        break;
      }

//  SS_Label_44.1.8  3 parameter Shepherd
      case 8:  // Shepherd
      {
        dvariable Shep_top;
        dvariable Shep_bot;
        dvariable Hupper;
        dvariable Shep_top2;
//  Andre's FORTRAN
//        TOP = 5*Steep*(1-0.2**POWER)*SPR/SPRF0-(1-5*Steep*0.2**POWER)
//      BOT = (5*Steep-1)
//       REC = (TOP/BOT)**(1.0/POWER)*SPRF0/SPR
// Power = exp(logC);
// Hupper = 1.0/(5.0 * pow(0.2,Power));
        Shepherd_c=SRparm3;
        Shepherd_c2=pow(0.2,SRparm3);
        Hupper=1.0/(5.0*Shepherd_c2);
        steepness=0.2+(SRparm2-0.2)/(0.8)*(Hupper-0.2);
        Shep_top=5.0*steepness*(1.0-Shepherd_c2)*(SPR_temp*Recr_virgin)/SSB_virgin-(1.0-5.0*steepness*Shepherd_c2);
        Shep_bot=5.0*steepness-1.0;
        Shep_top2=posfun(Shep_top,0.001,temp);  
        R_equil=(SSB_virgin/SPR_temp) * pow((Shep_top2/Shep_bot),(1.0/SRparm3));
        B_equil=R_equil*SPR_temp;
        break;
      }

//  SS_Label_43.3.8  Ricker-power
      case 9:  // Ricker power 3-parameter SRR.  per Punt & Cope 2017
      {
        steepness = SRparm2;
        dvariable RkrPower=SRparm3;
        temp=SSB_virgin/(SPR_temp*Recr_virgin);
        dvariable RkrTop =  pow(0.8,RkrPower)*log(temp)/log(5.0*steepness);
        RkrTop = posfun(RkrTop,0.000001,CrashPen);
        R_equil = temp *Recr_virgin * (1.0 - pow(RkrTop,1.0/RkrPower));
        B_equil=R_equil*SPR_temp;
        break;
      }

 /*
      case 19:  // re-parameterized Shepherd
      {
        dvariable Shep_top;
        dvariable Shep_bot;
        dvariable Hupper;
        dvariable Shep_top2;
//  Andre's FORTRAN
//        TOP = 5*Steep*(1-0.2**POWER)*SPR/SPRF0-(1-5*Steep*0.2**POWER)
//      BOT = (5*Steep-1)
//       REC = (TOP/BOT)**(1.0/POWER)*SPRF0/SPR
// Power = exp(logC);
// Hupper = 1.0/(5.0 * pow(0.2,Power));
        Shepherd_c=exp(SRparm3);
        Shepherd_c2=pow(0.2,Shepherd_c);
        Hupper=1.0/(5.0*Shepherd_c2);
        steepness=0.20001+((0.8)/(1.0+exp(-SRparm2))-0.2)/(0.8)*(Hupper-0.2);
//        steep2=0.20001+(steepness-0.2)/(0.8)*(Hupper-0.2);
        Shep_top=5.0*steepness*(1.0-Shepherd_c2)*(SPR_temp*Recr_virgin)/SSB_virgin-(1.0-5.0*steepness*Shepherd_c2);
        Shep_bot=5.0*steepness-1.0;
        Shep_top2=posfun(Shep_top,0.001,temp);  
        R_equil=(SSB_virgin/SPR_temp) * pow((Shep_top2/Shep_bot),(1.0/Shepherd_c));
        B_equil=R_equil*SPR_temp;
        break;
      }

//  SS_Label_43.3.8  Ricker-power
      case 20:  // Ricker power 3-parameter SRR.  per Punt & Cope 2017
      {
//   Hupper = 10.0;
//   Steep = 0.2 + (Hupper - 0.2)/(1+exp(-1*Steep2))+1.0e-5;
//   Top =  pow(0.8,Power)*log(SPRF0/SPR)/log(5.0*Steep);
//   Top = posfun(Top,0.000001,Penal);
//   Recs = (SPRF0/SPR) * (1.0 - pow(Top,1.0/Power));
//   Recs = posfun(Recs,0.0001,Penal);
//   if (Recs < 0) Rec2 = 0; else Rec2 = Recs;
        steepness = 0.2 + (10.0 - 0.2)/(1+exp(-SR_parm_work(2)));
        dvariable RkrPower=exp(SR_parm_work(3));
        temp=SSB_virgin/(SPR_temp*Recr_virgin);
        dvariable RkrTop =  pow(0.8,RkrPower)*log(temp)/log(5.0*steepness);
        RkrTop = posfun(RkrTop,0.000001,CrashPen);
        R_equil = temp *Recr_virgin * (1.0 - pow(RkrTop,1.0/RkrPower));
        B_equil=R_equil*SPR_temp;
        break;
      }
 */
    }
    Equil_Spawn_Recr_Calc(1)=B_equil;
    Equil_Spawn_Recr_Calc(2)=R_equil;
    RETURN_ARRAYS_DECREMENT();
    return Equil_Spawn_Recr_Calc;
  }  //  end Equil_Spawn_Recr_Fxn

