//********************************************************************
 /*  SS_Label_FUNCTION 43 Spawner-recruitment function */
//  SPAWN-RECR:   function: to calc R from S
FUNCTION dvariable Spawn_Recr(const prevariable& SPB_virgin, const prevariable& Recr_virgin, const prevariable& SPB_current)
  {
    dvariable NewRecruits;
    dvariable SPB_BH1;
    dvariable Recr_virgin_adj;
    dvariable SPB_virgin_adj;
    dvariable steepness;
    dvariable Shepard_c;
    dvariable Shepard_c2;
    dvariable Hupper;
    dvariable steep2;
    dvariable SPB_curr_adj;
    dvariable join;
    dvariable SRZ_0;
    dvariable SRZ_max;
    dvariable SRZ_surv;

//  SS_Label_43.1  add 0.1 to input spawning biomass value to make calculation more rebust
    SPB_curr_adj = SPB_current + 0.100;   // robust
    Recr_virgin_adj=Recr_virgin;
    SPB_virgin_adj=SPB_virgin;

//  SS_Label_43.2  adjust for environmental effects on S-R parameters: Rzero or steepness
    if(SR_env_target==2)
    {
      Recr_virgin_adj*=mfexp(SR_parm(N_SRparm2-2)* env_data(y,SR_env_link));
      SPB_virgin_adj*=mfexp(SR_parm(N_SRparm2-2)* env_data(y,SR_env_link));
    }

    if(SR_env_target==3)
    {
      temp=log((SRvec_HI(2)-SRvec_LO(2)+0.0000002)/(SR_parm(2)-SRvec_LO(2)+0.0000001)-1.)/(-2.);
      temp+=SR_parm(N_SRparm2-2)* env_data(y,SR_env_link);
      steepness=SRvec_LO(2)+(SRvec_HI(2)-SRvec_LO(2))/(1.+mfexp(-2.*temp));
    }
    else
    {
      steepness=SR_parm(2);
    }
    
    if(SR_fxn==8)
    {
      Shepard_c=SR_parm(3);
      Shepard_c2=pow(0.2,Shepard_c);
      Hupper=1.0/(5.0*Shepard_c2);
      steep2=0.2+(steepness-0.2)/(0.8)*(Hupper-0.2);
    }
    else if(SR_fxn==6 || SR_fxn==3)
    {
      alpha = 4.0 * steepness*Recr_virgin / (5.*steepness-1.);
      beta = (SPB_virgin*(1.-steepness)) / (5.*steepness-1.);
    }
    
//  SS_Label_43.3  calculate expected recruitment from the input spawning biomass and the SR curve
// functions below use Recr_virgin_adj,SPB_virgin_adj which could have been adjusted adjusted above from R0,SPB_virgin
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
        NewRecruits = Recr_virgin_adj*SPB_curr_adj/SPB_virgin_adj * mfexp(steepness*(1.-SPB_curr_adj/SPB_virgin_adj));
        break;
      }
//  SS_Label_43.3.3  Beverton-Holt
      case 3: // Beverton-Holt
      {
        NewRecruits =  (4.*steepness*Recr_virgin_adj*SPB_curr_adj) / (SPB_virgin_adj*(1.-steepness)+(5.*steepness-1.)*SPB_curr_adj);
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
        temp=SR_parm(3)*Recr_virgin_adj + SPB_curr_adj/(steepness*SPB_virgin_adj)*(Recr_virgin_adj-SR_parm(3)*Recr_virgin_adj);  //  linear decrease below steepness*SPB_virgin_adj
        NewRecruits=Join_Fxn(0.0*SPB_virgin_adj,SPB_virgin_adj,steepness*SPB_virgin_adj, SPB_curr_adj, temp, Recr_virgin_adj);
        break;
      }

//  SS_Label_43.3.6  Beverton-Holt, with constraint to have constant R about Bzero
      case 6: //Beverton-Holt constrained
      {
        if(SPB_curr_adj>SPB_virgin_adj) {SPB_BH1=SPB_virgin_adj;} else {SPB_BH1=SPB_curr_adj;}
        NewRecruits=(4.*steepness*Recr_virgin_adj*SPB_BH1) / (SPB_virgin_adj*(1.-steepness)+(5.*steepness-1.)*SPB_BH1);
        break;
      }

//  SS_Label_43.3.7  survival based
      case 7:  // survival based, so constrained such that recruits cannot exceed fecundity
      {
        // PPR_0=SPB_virgin_adj/Recr_virgin_adj;  //  pups per recruit at virgin
        // Surv_0=1./PPR_0;   //  recruits per pup at virgin
        // Pups_0=SPB_virgin_adj;  //  total population fecundity is the number of pups produced
        // Sfrac=SR_parm(2);
        SRZ_0=log(1.0/(SPB_virgin_adj/Recr_virgin_adj));
        SRZ_max=SRZ_0+SR_parm(2)*(0.0-SRZ_0);
        SRZ_surv=mfexp((1.-pow((SPB_curr_adj/SPB_virgin_adj),SR_parm(3)) )*(SRZ_max-SRZ_0)+SRZ_0);  //  survival
        NewRecruits=SPB_curr_adj*SRZ_surv;
        exp_rec(y,1)=NewRecruits;   // expected arithmetic mean recruitment
//  SS_Label_43.3.7.1  Do variation in recruitment by adjusting survival
        if(SR_env_target==1) SRZ_surv*=mfexp(SR_parm(N_SRparm2-2)* env_data(y,SR_env_link));   // environ effect on survival
        if(recdev_cycle>0)
        {
          gg=y - (styr+(int((y-styr)/recdev_cycle))*recdev_cycle)+1;
          SRZ_surv*=mfexp(recdev_cycle_parm(gg));
        }
        exp_rec(y,2)=SPB_curr_adj*SRZ_surv;
        SRZ_surv*=mfexp(-biasadj(y)*half_sigmaRsq);     // bias adjustment
        exp_rec(y,3)=SPB_curr_adj*SRZ_surv;
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
        NewRecruits=SPB_curr_adj*SRZ_surv;
        exp_rec(y,4) = NewRecruits;
        break;
      }

//  SS_Label_43.3.8  Shepard
      case 8:  // Shepard 3-parameter SRR.  per Punt document at PFMC
      {
        temp=(SPB_curr_adj)/(SPB_virgin_adj);
        NewRecruits =  (5.*steep2*Recr_virgin_adj*(1.-Shepard_c2)*temp) /
        (1.0 - 5.0*steep2*Shepard_c2 + (5.*steep2-1.)*pow(temp,Shepard_c));
        break;
      }
    }

    if(SR_fxn!=7)
    {
//  SS_Label_43.4  For non-survival based SRR, get recruitment deviations by adjusting recruitment itself
      exp_rec(y,1)=NewRecruits;   // expected arithmetic mean recruitment

      if(SR_env_target==1) NewRecruits*=mfexp(SR_parm(N_SRparm2-2)* env_data(y,SR_env_link));   // environ effect on annual recruitment
      if(recdev_cycle>0)
      {
        gg=y - (styr+(int((y-styr)/recdev_cycle))*recdev_cycle)+1;
        NewRecruits*=mfexp(recdev_cycle_parm(gg));
      }
      exp_rec(y,2)=NewRecruits;
      if(SR_fxn!=4) NewRecruits*=mfexp(-biasadj(y)*half_sigmaRsq);     // bias adjustment
      exp_rec(y,3)=NewRecruits;
      if(y <=recdev_end)
      {
        if(recdev_doit(y)>0) NewRecruits*=mfexp(recdev(y));  //  recruitment deviation
      }
      else if(Do_Forecast>0)
      {
        NewRecruits *= mfexp(Fcast_recruitments(y));
      }
      exp_rec(y,4)=NewRecruits;
    }
    return NewRecruits;
  }  //  end spawner_recruitment

//********************************************************************
 /*  SS_Label_FUNCTION 44 Equil_Spawn_Recr_Fxn */
//  SPAWN-RECR:   function  Equil_Spawn_Recr_Fxn
FUNCTION dvar_vector Equil_Spawn_Recr_Fxn(const prevariable &steepness, const prevariable &SRparm3, 
         const prevariable& SPB_virgin, const prevariable& Recr_virgin, const prevariable& SPR_temp)
  {
    RETURN_ARRAYS_INCREMENT();
    dvar_vector Equil_Spawn_Recr_Calc(1,2);  // values to return 1 is B_equil, 2 is R_equil
    dvariable B_equil;  
    dvariable R_equil;
    dvariable temp;
    dvariable join;
    dvariable Shepard_c;
    dvariable Shepard_c2;
    dvariable SRZ_0;
    dvariable SRZ_max;
    dvariable SRZ_surv;

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
        beta = (SPB_virgin*(1.-steepness)) / (5.*steepness-1.);
        B_equil=alpha * SPR_temp - beta;
        B_equil=posfun(B_equil,0.0001,temp);
        R_equil=(4.*steepness*Recr_virgin*B_equil) / (SPB_virgin*(1.-steepness)+(5.*steepness-1.)*B_equil);
        break;
      }
//  SS_Label_44.1.2  Ricker
      case 2: // Ricker
      {
        B_equil=SPB_virgin*(1.+(log(Recr_virgin/SPB_virgin)+log(SPR_temp))/steepness);
        R_equil=Recr_virgin*B_equil/SPB_virgin * mfexp(steepness*(1.-B_equil/SPB_virgin));
        
        break;
      }
//  SS_Label_44.1.3  Beverton-Holt
      case 3:  // same as case 6
      {
        alpha = 4.0 * steepness*Recr_virgin / (5.*steepness-1.);
        beta = (SPB_virgin*(1.-steepness)) / (5.*steepness-1.);
        B_equil=alpha * SPR_temp - beta;
        B_equil=posfun(B_equil,0.0001,temp);
        R_equil=(4.*steepness*Recr_virgin*B_equil) / (SPB_virgin*(1.-steepness)+(5.*steepness-1.)*B_equil); //Beverton-Holt
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
//        temp=SPB_virgin/R0*steepness;  // spawners per recruit at inflection
        beta=(Recr_virgin-alpha)/(steepness*SPB_virgin);   //  slope of recruitment on spawners below the inflection
        B_equil=Join_Fxn(0.0*SPB_virgin/Recr_virgin, SPB_virgin/Recr_virgin, SPB_virgin/Recr_virgin*steepness, SPR_temp, alpha/((1./SPR_temp)-beta), SPR_temp*Recr_virgin);
        R_equil=Join_Fxn(0.0*SPB_virgin, SPB_virgin, SPB_virgin*steepness, B_equil, alpha+beta*B_equil, Recr_virgin);
        break;
      }
//  SS_Label_44.1.7  3 parameter survival based
      case 7:  // survival
      {
        SRZ_0=log(1.0/(SPB_virgin/Recr_virgin));
        SRZ_max=SRZ_0+steepness*(0.0-SRZ_0);
        B_equil = SPB_virgin * (1. - (log(1./SPR_temp) - SRZ_0)/pow((SRZ_max - SRZ_0),(1./SRparm3) ));
        SRZ_surv=mfexp((1.-pow((B_equil/SPB_virgin),SR_parm(3)) )*(SRZ_max-SRZ_0)+SRZ_0);  //  survival
        R_equil=B_equil*SRZ_surv;
        break;
      }

//  SS_Label_44.1.8  3 parameter Shepard
      case 8:  // Shepard
      {
        dvariable Shep_top;
        dvariable Shep_bot;
        dvariable Hupper;
        dvariable steep2;
        dvariable Shep_top2;
//  Andre's FORTRAN
//        TOP = 5*Steep*(1-0.2**POWER)*SPR/SPRF0-(1-5*Steep*0.2**POWER)
//      BOT = (5*Steep-1)
//       REC = (TOP/BOT)**(1.0/POWER)*SPRF0/SPR
// Power = exp(logC);
// Hupper = 1.0/(5.0 * pow(0.2,Power));
        Shepard_c=SRparm3;
        Shepard_c2=pow(0.2,Shepard_c);
        Hupper=1.0/(5.0*Shepard_c2);
        steep2=0.2+(steepness-0.2)/(0.8)*(Hupper-0.2);
        Shep_top=5.0*steep2*(1.0-Shepard_c2)*(SPR_temp*Recr_virgin)/SPB_virgin-(1.0-5.0*steep2*Shepard_c2);
        Shep_bot=5.0*steep2-1.0;
        Shep_top2=posfun(Shep_top,0.001,temp);  
        R_equil=(SPB_virgin/SPR_temp) * pow((Shep_top2/Shep_bot),(1.0/Shepard_c));
        B_equil=R_equil*SPR_temp;
        break;
      }
    }
    Equil_Spawn_Recr_Calc(1)=B_equil;
    Equil_Spawn_Recr_Calc(2)=R_equil;
    RETURN_ARRAYS_DECREMENT();
    return Equil_Spawn_Recr_Calc;
  }  //  end Equil_Spawn_Recr_Fxn

