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
    if(do_once==1) echoinput<<" call make_timevaryparm in year "<<y<<endl;
    //  note:  need to implement the approach that keeps within bounds of base parameter

    int tvary;
    if(timevary_parm_cnt_MG>0)
      {
        j=N_MGparm;
        for(f=1;f<=timevary_parm_cnt_MG;f++)
        {
          j++; timevary_parm(f)=MGparm(j);
        }
      }
    if(timevary_parm_cnt_sel>0)
      {
        j=N_selparm;
        for(f=timevary_parm_cnt_MG+1;f<=timevary_parm_cnt_sel;f++)
        {
          j++; timevary_parm(f)=selparm(j);
        }
      }

    for (tvary=1;tvary<=timevary_cnt;tvary++)
    {
      if(do_once==1) echoinput<<" loop time vary effects "<<tvary<<endl;
      ivector itempvec(1,8);
      itempvec(1,8)=timevary_def[tvary-1](1,8);
      //  what type of parameter is being affected?  get the baseparm and its bounds
      switch(itempvec(1))      //  parameter type
      {
        case 1:  // MG
        {
          baseparm=MGparm(itempvec(2)); //  index of base parm
          baseparm_min=MGparm_LO(itempvec(2));
          baseparm_max=MGparm_HI(itempvec(2));
          break;
        }
        case 2:  // selex
        {
          baseparm=selparm(itempvec(2)); //  index of base parm
          baseparm_min=selparm_LO(itempvec(2));
          baseparm_max=selparm_HI(itempvec(2));
          break;
        }
      }

      timevary_parm_cnt=itempvec(3);  //  first  parameter used to create timevary effect on baseparm
      if(itempvec(4)>0)  //  block
      {
        parm_timevary(tvary)=baseparm;  //  fill timeseries with base parameter
        z=itempvec(4);    // specified block pattern
        g=1;
        temp=baseparm;
        for (a=1;a<=Nblk(z);a++)
        {
          switch(itempvec(5))
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

      else if(itempvec(4)<0)  //  trend
      {
        // timevary_parm(timevary_parm_cnt+0) = offset for the trend at endyr; 3 options available below
        // timevary_parm(timevary_parm_cnt+1) = inflection year; 2 options available
        // timevary_parm(timevary_parm_cnt+2) = stddev of normal at inflection year
        //  calc endyr value,
        if(do_once==1) echoinput<<" doing trend approach:"<<itempvec(4)<<endl;
        if(itempvec(4)==-1)  // use logistic transform to keep with bounds of the base parameter
        {
          endtrend=log((baseparm_max-baseparm_min+0.0000002)/(baseparm-baseparm_min+0.0000001)-1.)/(-2.);   // transform the base parameter
          endtrend+=timevary_parm(timevary_parm_cnt);     //  add the offset  Note that offset value is in the transform space
          endtrend=baseparm_min+(baseparm_max-baseparm_min)/(1.+mfexp(-2.*endtrend));   // backtransform
          infl_year=log(0.5)/(-2.);   // transform the base parameter
          infl_year+=timevary_parm(timevary_parm_cnt+1);     //  add the offset  Note that offset value is in the transform space
          infl_year=r_years(styr)+(r_years(endyr)-r_years(styr))/(1.+mfexp(-2.*infl_year));   // backtransform
         }
        else if(itempvec(4)==-2) // set ending value directly
        {
          endtrend=timevary_parm(timevary_parm_cnt);
          infl_year=timevary_parm(timevary_parm_cnt+1);
        }
        else if(itempvec(4)==-3) // use parm as fraction of way between bounds
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

      if(itempvec(7)>0)   //  env link, but not density-dependent
      {
        if(do_once==1) echoinput<<" doing env effect "<<itempvec(6,7)<<endl<<timevary_parm(timevary_parm_cnt)<<endl;
        switch(int(itempvec(6)))
        {
          case 1:  //  exponential  env link
            {
              for (int y1=styr-1;y1<=YrMax;y1++)
              {
                parm_timevary(tvary,y1)*=mfexp(timevary_parm(timevary_parm_cnt)*(env_data(y1,itempvec(7))));
              }
              timevary_parm_cnt++;
              break;
            }
          case 2:  //  linear  env link
            {
              for (int y1=styr-1;y1<=YrMax;y1++)
              {
                parm_timevary(tvary,y1)+=timevary_parm(timevary_parm_cnt)*env_data(y1,itempvec(7));
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
                parm_timevary(tvary,y1)=2.00000/(1.00000 + mfexp(-timevary_parm(timevary_parm_cnt+1)*(env_data(yz,itempvec(7))-timevary_parm(timevary_parm_cnt))));
              }
              timevary_parm_cnt+=2;
              break;
            }
        }
          if(do_once==1) echoinput<<" parm with env "<<parm_timevary<<endl;
      }
    }
  }
