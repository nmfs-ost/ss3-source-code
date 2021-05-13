// SS_Label_file  #22. **SS_tagrecap.tpl **
// SS_Label_file  #* <u>Tag_Recapture()</u>  //  calculates expected values for number of tags returned by each fleet(and area), in each time step, for each tag release group
// SS_Label_file  #

FUNCTION void Tag_Recapture()
  {
  //  SS_Label_Info_24.15 #do tag mortality, movement and recapture  revise 7/10/2019
    dvariable TG_init_loss;
    dvariable TG_chron_loss;
    TG_recap_exp.initialize();

//  get reporting rates by fleet that will be used for all Tag Groups
      for (f=1;f<=Nfleet1;f++)
      {
        j=3*N_TG+f;
      if(TG_parm_PH(j)==-1000.)	
      	{TG_report(f)=TG_report(f-1);} //  do nothing keep same value
      else
      {
        if (TG_parm_PH(j)>-1000.)	{k=j;} else {k=-1000-TG_parm_PH(j);}
      	TG_report(f)=mfexp(TG_parm(k))/(1.+mfexp(TG_parm(k)));
      }
        j+=Nfleet1;
      if(TG_parm_PH(j)==-1000.)	
      	{TG_rep_decay(f)=TG_rep_decay(f-1);}//  do nothing keep same value
      else
      {
        if (TG_parm_PH(j)>-1000.)	{k=j;} else {k=-1000-TG_parm_PH(j);}
      	TG_rep_decay(f) = TG_parm(k);
      }
      }

    for (TG=1;TG<=N_TG;TG++)
    {
      firstseas=int(TG_release(TG,4));  // release season
      t=int(TG_release(TG,5));  // release t index calculated in data section from year and season of release
      p=int(TG_release(TG,2));  // release area
      gg=int(TG_release(TG,6));  // gender (1=fem; 2=male; 0=both
      a1=int(TG_release(TG,7));  // age at release

      TG_alive.initialize();
      if(gg==0)
      {
        for (g=1;g<=gmorph;g++) {TG_alive(p,g) = natage(t,p,g,a1);}   //  gets both genders
      }
      else
      {
        for (g=1;g<=gmorph;g++)
        {
          if(sx(g)==gg) {TG_alive(p,g) = natage(t,p,g,a1);}  //  only does the selected gender
        }
      }
      if(TG_parm_PH(TG)==-1000.)	
      	{ }//  do nothing keep same TG_init_loss
      else
      {
        if (TG_parm_PH(TG)>-1000.)	{k=TG;} else {k=-1000-TG_parm_PH(TG);}
      	TG_init_loss=mfexp(TG_parm(k))/(1.+mfexp(TG_parm(k)));
      }
      
//  get chronic loss parameter
      j=TG+N_TG;
      if(TG_parm_PH(j)==-1000.)	
      	{ }//  do nothing keep same value
      else
      {
        if (TG_parm_PH(j)>-1000.)	{k=j;} else {k=-1000-TG_parm_PH(j)+N_TG;}
      	TG_chron_loss=mfexp(TG_parm(k))/(1.+mfexp(TG_parm(k)));
      }
      TG_alive /= sum(TG_alive);     // proportions across morphs at age a1 in release area p at time of release t
      TG_alive *= TG_release(TG,8);   //  number released as distributed across morphs
      TG_alive *= (1.-TG_init_loss);  // initial mortality
      if(save_for_report>0)
      {
        TG_save(TG,1)=value(TG_init_loss);
        TG_save(TG,2)=value(TG_chron_loss);
      }

      TG_t=0;
      for (y=TG_release(TG,3);y<=endyr;y++)
      {
        for (s=firstseas;s<=nseas;s++)
        {
          if(save_for_report>0 && TG_t<=TG_endtime(TG))
          {TG_save(TG,3+TG_t)=value(sum(TG_alive));
          	} //  OK to do simple sum because only selected morphs are populated

          for (p=1;p<=pop;p++)
          {
            for (g=1;g<=gmorph;g++)
            if(TG_use_morph(TG,g)>0)
            {
              for (f=1;f<=Nfleet;f++)
              if (fleet_area(f)==p)
              {
// calculate recaptures by fleet
// NOTE:  Sel_for_tag(t,g,f,a1) = sel_al_4(s,g,f,a1)*Hrate(f,t)
                if(F_Method==1)
                {
                  TG_recap_exp(TG,TG_t,f)+=TG_alive(p,g)  // tags recaptured
                  *mfexp(-(natM(s,GP3(g),a1)+TG_chron_loss)*seasdur_half(s))
                  *Sel_for_tag(t,g,f,a1)
                  *TG_report(f)
                  *mfexp(TG_t*TG_rep_decay(f));
                }
                else   // use for method 2 and 3
                {
                  TG_recap_exp(TG,TG_t,f)+=TG_alive(p,g)
                  *Sel_for_tag(t,g,f,a1)/(Z_rate(t,p,g,a1)+TG_chron_loss)
                  *(1.-mfexp(-seasdur(s)*(Z_rate(t,p,g,a1)+TG_chron_loss)))
                  *TG_report(f)
                  *mfexp(TG_t*TG_rep_decay(f));
                }
                
  if(docheckup==1) echoinput<<" TG_"<<TG<<" y_"<<y<<" s_"<<s<<" area_"<<p<<" g_"<<g<<" GP3_"<<GP3(g)<<" f_"<<f<<" a1_"<<a1<<" Sel_"<<Sel_for_tag(t,g,f,a1)<<" TG_alive_"<<TG_alive(p,g)<<" TG_obs_"<<TG_recap_obs(TG,TG_t,f)<<" TG_exp_"<<TG_recap_exp(TG,TG_t,f)<<endl;
              }  // end fleet loop for recaptures
                TG_alive(p,g)*=mfexp(-seasdur(s)*(Z_rate(t,p,g,a1)+TG_chron_loss));
            }  // end morph loop
          }  // end area loop

          if(Hermaphro_Option!=0)
          {
            if(Hermaphro_seas==-1 || Hermaphro_seas==s)
            {
              k=gmorph/2;
              for (p=1;p<=pop;p++)  //   area
              for (g=1;g<=k;g++)  //  loop females
              if(use_morph(g)>0)
              {
                if(Hermaphro_Option==1)
                {
                  TG_alive(p,g+k) += TG_alive(p,g)*Hermaphro_val(GP4(g),a1); // increment males with females
                  TG_alive(p,g) *= (1.-Hermaphro_val(GP4(g),a1)); // decrement females
                } else
                if(Hermaphro_Option==-1)
                {
                  TG_alive(p,g) += TG_alive(p,g+k)*Hermaphro_val(GP4(g+k),a1); // increment females with males
                  TG_alive(p,g+k) *= (1.-Hermaphro_val(GP4(g+k),a1)); // decrement males
                }
              }
            }
          }

          if(do_migration>0)  //  movement between areas of tags
          {
            TG_alive_temp=TG_alive;
            TG_alive=0.0;
            for (g=1;g<=gmorph;g++)
            if(use_morph(g)>0)
            {
              for (p=1;p<=pop;p++)  //   source population
              for (p2=1;p2<=pop;p2++)  //  destination population
              {
                k=move_pattern(s,GP4(g),p,p2);
                if(k>0) TG_alive(p2,g) += TG_alive_temp(p,g)*migrrate(y,k,a1);
              }
            }
            if(docheckup==1) echoinput<<" Tag_alive after survival and movement "<<endl<<TG_alive<<endl;
          }
          t++;         //  increment seasonal time counter
          if(TG_t<TG_endtime(TG)) TG_t++;
          if(s==nseas && a1<nages) a1++;
        }  // end seasons
        firstseas=1;  // so start with season 1 in year following the tag release
      }  // end years
    }  //  end loop of tag groups
  }  // end having tag groups
  
 /*
 //  SS_Label_Info_25.9 #Fit to tag-recapture
 //  This code fragment resides in SS_objfunc.tpl
    if(Do_TG>0)
    {
      for (TG=1;TG<=N_TG;TG++)
      {
        overdisp=TG_parm(2*N_TG+TG);
        for (TG_t=TG_mixperiod;TG_t<=TG_endtime(TG);TG_t++)
        {
          TG_recap_exp(TG,TG_t)(1,Nfleet)+=1.0e-6;  // add a tiny amount
          TG_recap_exp(TG,TG_t,0) = sum(TG_recap_exp(TG,TG_t)(1,Nfleet));
          TG_recap_exp(TG,TG_t)(1,Nfleet)/=TG_recap_exp(TG,TG_t,0);
          if(Nfleet>1) TG_like1(TG)-=TG_recap_obs(TG,TG_t,0)* (TG_recap_obs(TG,TG_t)(1,Nfleet) * log(TG_recap_exp(TG,TG_t)(1,Nfleet)));
          TG_like2(TG)-=log_negbinomial_density(TG_recap_obs(TG,TG_t,0),TG_recap_exp(TG,TG_t,0),overdisp);
        }
      }
    if(do_once==1) cout<<" did tag obj_fun "<<TG_like1<<endl<<TG_like2<<endl;
    }
 */
