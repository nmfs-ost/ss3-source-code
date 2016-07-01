//*********************************************************************
 /*  SS_Label_Function_14 #make_timevaryparm():  create trend and block time series */
FUNCTION void make_timevaryparm()
  {

    dvariable baseparm;
    double baseparm_min;
    double baseparm_max;
    dvariable endtrend;
    dvariable infl_year;
    dvariable slope;
    dvariable norm_styr;
    if(do_once==1) echoinput<<" called make_timevaryparm "<<endl;
    //  note:  need to implement the approach that keeps within bounds of base parameter

    int timevary_parm_cnt_all;
    timevary_parm_cnt_all=0;
    
    for (int tvary=1;tvary<=timevary_cnt;tvary++)
    {
      if(do_once==1) echoinput<<" loop time vary effect #: "<<tvary<<endl;
      ivector timevary_setup(1,12);
      timevary_setup(1,12)=timevary_def[tvary-1](1,12);
      echoinput<<timevary_setup<<endl<<MGparm<<endl;
      //  what type of parameter is being affected?  get the baseparm and its bounds
      switch(timevary_setup(1))      //  parameter type
      {
        case 1:  // MG
        {
          baseparm=MGparm(timevary_setup(2)); //  index of base parm
          baseparm_min=MGparm_LO(timevary_setup(2));
          baseparm_max=MGparm_HI(timevary_setup(2));
          echoinput<<"base: "<<baseparm<<" "<<baseparm_min<<" "<<baseparm_max<<endl;
          echoinput<<tvary<<" loop end "<<timevary_def[tvary](3)<<endl;
          for(j=timevary_setup(3);j<timevary_def[tvary](3);j++)
          {
            timevary_parm_cnt_all++;
            timevary_parm(timevary_parm_cnt_all)=MGparm(N_MGparm+j);
            echoinput<<j<<" "<<timevary_parm_cnt_all<<" "<<timevary_parm(timevary_parm_cnt_all)<<endl;
          }
          break;
        }
        case 2:  // selex
        {
          baseparm=selparm(timevary_setup(2)); //  index of base parm
          baseparm_min=selparm_LO(timevary_setup(2));
          baseparm_max=selparm_HI(timevary_setup(2));
          for(j=timevary_setup(3);j<=timevary_def[tvary](3);j++)
          {
            timevary_parm_cnt_all++;
            timevary_parm(timevary_parm_cnt_all)=selparm(N_selparm+j);
          }
          break;
        }
      }

      timevary_parm_cnt=timevary_setup(3);  //  first  parameter used to create timevary effect on baseparm
      echoinput<<" setup again "<<timevary_setup<<endl;
      if(timevary_setup(4)>0)  //  block
      {
        parm_timevary(tvary)=baseparm;  //  fill timeseries with base parameter, just in case
        
        z=timevary_setup(4);    // specified block pattern
        g=1;
        temp=baseparm;
        for (a=1;a<=Nblk(z);a++)
        {
          switch(timevary_setup(5))
          {
            case 0:
            {
              temp=baseparm * mfexp(timevary_parm(timevary_parm_cnt));
              timevary_parm_cnt++;
              break;
            }
            case 1:
            {
              temp=baseparm + mfexp(timevary_parm(timevary_parm_cnt));
              timevary_parm_cnt++;
              break;
            }
            case 2:
            {
              temp=timevary_parm(timevary_parm_cnt);  //  direct assignment of block value
              timevary_parm_cnt++;
              break;
            }
            case 3:
            {
              temp+=timevary_parm(timevary_parm_cnt);  //  block as offset from previous block
              timevary_parm_cnt++;
              break;
            }
          }

          for (int y1=Block_Design(z,g);y1<=Block_Design(z,g+1);y1++)  // loop years for this block
          {
            parm_timevary(tvary,y1)=temp;
          }
          g+=2;
          if(do_once==1) echoinput<<" parm with blocks "<<parm_timevary<<endl;
        }
//        timevary_parm_cnt--;    // back out last increment
      }  // end uses blocks

      else if(timevary_setup(4)<0)  //  trend
      {
        echoinput<<" doing trend "<<endl;
        // timevary_parm(timevary_parm_cnt+0) = offset for the trend at endyr; 3 options available below
        // timevary_parm(timevary_parm_cnt+1) = inflection year; 2 options available
        // timevary_parm(timevary_parm_cnt+2) = stddev of normal at inflection year
        //  calc endyr value,
        if(do_once==1) echoinput<<" doing trend approach:"<<timevary_setup(4)<<endl;
        if(timevary_setup(4)==-1)  // use logistic transform to keep with bounds of the base parameter
        {
          endtrend=log((baseparm_max-baseparm_min+0.0000002)/(baseparm-baseparm_min+0.0000001)-1.)/(-2.);   // transform the base parameter
          endtrend+=timevary_parm(timevary_parm_cnt);     //  add the offset  Note that offset value is in the transform space
          endtrend=baseparm_min+(baseparm_max-baseparm_min)/(1.+mfexp(-2.*endtrend));   // backtransform
          infl_year=log(0.5)/(-2.);   // transform the base parameter
          infl_year+=timevary_parm(timevary_parm_cnt+1);     //  add the offset  Note that offset value is in the transform space
          infl_year=r_years(styr)+(r_years(endyr)-r_years(styr))/(1.+mfexp(-2.*infl_year));   // backtransform
         }
        else if(timevary_setup(4)==-2) // set ending value directly
        {
          endtrend=timevary_parm(timevary_parm_cnt);
          infl_year=timevary_parm(timevary_parm_cnt+1);
        }
        else if(timevary_setup(4)==-3) // use parm as fraction of way between bounds
        {
          endtrend=baseparm_min+(baseparm_max-baseparm_min)*timevary_parm(timevary_parm_cnt);
          infl_year=r_years(styr)+(r_years(endyr)-r_years(styr))*timevary_parm(timevary_parm_cnt+1);
        }
        slope=timevary_parm(timevary_parm_cnt+2);
        if(do_once==1) echoinput<<" endtrend "<<endtrend<<endl;
        endtrend+=2.0;
        if(do_once==1) echoinput<<" infl_year, slope "<<infl_year<<" "<<slope<<endl;
        timevary_parm_cnt+=3;

        norm_styr=cumd_norm((r_years(styr) -infl_year)/slope);
        temp=(endtrend-baseparm) / (cumd_norm((r_years(endyr)-infl_year)/slope)-norm_styr);   //  delta in cum_norm between styr and endyr
        
        for (int y1=styr;y1<=YrMax;y1++)
        {
          if(y1<=endyr)
          {parm_timevary(tvary,y1)=baseparm + temp * (cumd_norm((r_years(y1)-infl_year)/slope )-norm_styr);}
          else
          {parm_timevary(tvary,y1)=parm_timevary(tvary,endyr);}
        }
        parm_timevary(tvary,styr-1)=baseparm;
         if(do_once==1)  echoinput<<" parm with trend "<<parm_timevary(tvary)<<endl;
      }

      if(timevary_setup(7)>0)   //  env link, but not density-dependent
      {
        if(do_once==1) echoinput<<" doing env effect "<<timevary_setup(6,7)<<endl<<timevary_parm(timevary_parm_cnt)<<endl;
        switch(int(timevary_setup(6)))
        {
          case 1:  //  exponential  env link
            {
              for (int y1=styr-1;y1<=YrMax;y1++)
              {
                parm_timevary(tvary,y1)*=mfexp(timevary_parm(timevary_parm_cnt)*(env_data(y1,timevary_setup(7))));
              }
              timevary_parm_cnt++;
              break;
            }
          case 2:  //  linear  env link
            {
              for (int y1=styr-1;y1<=YrMax;y1++)
              {
                parm_timevary(tvary,y1)+=timevary_parm(timevary_parm_cnt)*env_data(y1,timevary_setup(7));
              }
              timevary_parm_cnt++;
              break;
            }
          case 3:
          	{
          		//  not implemented
          	}
          case 4:  //  logistic MGparm env link
            {
            	// first parm is offset ; second is slope
              for (int y1=styr;y1<=YrMax;y1++)
              {
                parm_timevary(tvary,y1)=2.00000/(1.00000 + mfexp(-timevary_parm(timevary_parm_cnt+1)*(env_data(yz,timevary_setup(7))-timevary_parm(timevary_parm_cnt))));
              }
              timevary_parm_cnt+=2;
              break;
            }
        }
          if(do_once==1) echoinput<<" parm with env "<<parm_timevary<<endl;
      }

  //  SS_Label_Info_14.3 #Create MGparm dev randwalks if needed
      if(timevary_setup(8)>0)   //  devs
      {
//            if(MGparm_dev_type(k)==1)  // multiplicative
//            {mgp_adj(f) *= mfexp(MGparm_dev(k,yz));}
//            else if(MGparm_dev_type(k)==2)  // additive
//            {mgp_adj(f) += MGparm_dev(k,yz);}
//            else if(MGparm_dev_type(k)>=3)  // additive rwalk or mean-reverting rwalk
//            {mgp_adj(f) += MGparm_dev_rwalk(k,yz);}
  //  SS_Label_Info_7.3.5 #Set up the MGparm stderr and rho parameters for the dev vectors

        k=timevary_setup(8);   //  dev used
        MGparm_dev_stddev(k)=timevary_parm(timevary_parm_cnt);
        MGparm_dev_rho(k)=timevary_parm(timevary_parm_cnt+1);
//        echoinput<<k<<" devs:  se and rho "<<MGparm_dev_stddev(k)<<" "<<MGparm_dev_rho(k)<<" link "<<timevary_setup(9)<<endl;
        switch(timevary_setup(9))
        {
          case 1:
          {
            for (j=timevary_setup(10);j<=timevary_setup(11);j++)
            {
              parm_timevary(tvary,j)*=mfexp(MGparm_dev(k,j));
            }
            break;
          }
          case 2:
          {
            for (j=timevary_setup(10);j<=timevary_setup(11);j++)
            {
              parm_timevary(tvary,j)+=MGparm_dev(k,j);
            }
            break;
          }
          case 3:
          {
            MGparm_dev_rwalk(k,timevary_setup(10))=MGparm_dev(k,timevary_setup(10));
            parm_timevary(tvary,timevary_setup(10))+=MGparm_dev_rwalk(k,timevary_setup(10));
            for (j=timevary_setup(10)+1;j<=timevary_setup(11);j++)
            {
              MGparm_dev_rwalk(k,j)=MGparm_dev_rwalk(k,j-1)+MGparm_dev(k,j);
              parm_timevary(tvary,j)+=MGparm_dev_rwalk(k,j);
            }
            break;
          }
          case 4:  // mean reverting random walk
          {
            MGparm_dev_rwalk(k,timevary_setup(10))=MGparm_dev(k,timevary_setup(10));
            parm_timevary(tvary,timevary_setup(10))+=MGparm_dev_rwalk(k,timevary_setup(10));
            for (j=timevary_setup(10)+1;j<=timevary_setup(11);j++)
            {
              //    =(1-rho)*mean + rho*prevval + dev   //  where mean = 0.0
              MGparm_dev_rwalk(k,j)=MGparm_dev_rho(k)*MGparm_dev_rwalk(k,j-1)+MGparm_dev(k,j);
              parm_timevary(tvary,j)+=MGparm_dev_rwalk(k,j);
            }
            break;
          }
        }
      }
    }
  }
