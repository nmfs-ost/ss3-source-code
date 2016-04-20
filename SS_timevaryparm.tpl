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

    //  note:  need to implement the approach that keeps within bouns of base parameter

    int trnd;
    if(timevary_parm_cnt_MG>0)
      {
        j=N_MGparm+N_MGparm_env;
        for(f=1;f<=timevary_parm_cnt_MG;f++)
        {
          j++; timevary_parm(f)=MGparm(j);
          echoinput<<" map MGparm for blksel "<<timevary_parm(f)<<endl;
        }
      }
    if(timevary_parm_cnt_sel>0)
      {
        j=N_selparm+N_selparm_env;
        for(f=timevary_parm_cnt_MG+1;f<=timevary_parm_cnt;f++)
        {
          j++; timevary_parm(f)=selparm(j);
          echoinput<<" map selparm for blksel "<<timevary_parm(f)<<endl;
        }
      }
    for (trnd=1;trnd<=timevary_cnt;trnd++)
    {
      ivector itempvec(1,5);
      itempvec(1,5)=timevary_parm1[trnd-1];
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

      timevary_parm_cnt=itempvec(3);  //  first timevary parameter

      if(itempvec(4)>0)  //  block
      {
        parm_timevary(trnd)=baseparm;  //  fill timeseries with base parameter
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
              break;
            }
            case 1:
            {
              temp=baseparm + mfexp(timevary_parm(timevary_parm_cnt));
              break;
            }
            case 2:
            {
              temp=timevary_parm(timevary_parm_cnt);  //  direct assingment of block value
              break;
            }
            case 3:
            {
              temp+=timevary_parm(timevary_parm_cnt);  //  block as offset from previous block
              break;
            }
          }

          for (int y1=Block_Design(z,g);y1<=Block_Design(z,g+1);y1++)  // loop years for this block
          {
            parm_timevary(trnd,y1)=temp;
          }
          g+=2;
          timevary_parm_cnt++;
        }
        timevary_parm_cnt--;    // back out last increment
      }  // end uses blocks

      else if(itempvec(4)<0)  //  trend
      {
        // timevary_parm(timevary_parm_cnt+0) = offset for the trend at endyr; 3 options available below
        // timevary_parm(timevary_parm_cnt+1) = inflection year; 2 options available
        // timevary_parm(timevary_parm_cnt+2) = stddev of normal at inflection year
        //  calc endyr value,
        if(itempvec(4)==-1)  // use logistic transform to keep with bounds of the base parameter
        {
          endtrend=log((baseparm_max-baseparm_min+0.0000002)/(baseparm-baseparm_min+0.0000001)-1.)/(-2.);   // transform the base parameter
          endtrend+=timevary_parm(timevary_parm_cnt);     //  add the offset  Note that offset value is in the transform space
          endtrend=baseparm_min+(baseparm_max-baseparm_min)/(1.+mfexp(-2.*endtrend));   // backtransform
        }
        else if(itempvec(4)==-2) // set ending value directly
        {
          endtrend=timevary_parm(timevary_parm_cnt);
        }
        else if(itempvec(4)==-3) // use parm as fraction of way between bounds
        {
          endtrend=baseparm_min+(baseparm_max-baseparm_min)*timevary_parm(timevary_parm_cnt);
        }

        if(itempvec(5)==0)  // switch for direct estimation of inflection year, or as frac of timeseries
          // previousyly used the upper bound on this parameter as the switch
        {infl_year=r_years(styr)+timevary_parm(timevary_parm_cnt+1)*(r_years(endyr)-r_years(styr));}  // infl year
        else
        {infl_year=timevary_parm(timevary_parm_cnt+1);}
        norm_styr=cumd_norm((r_years(styr) -infl_year)/timevary_parm(timevary_parm_cnt+2));
        slope=(endtrend-baseparm) /
              (cumd_norm((r_years(endyr)-infl_year)/timevary_parm(timevary_parm_cnt+2))-
                norm_styr);   //  delta in cum_norm between styr and endyr
        for (int y1=styr;y1<=YrMax;y1++)
        {
          if(y1<=endyr)
          {parm_timevary(trnd,y1)=baseparm + slope * (cumd_norm((r_years(y1)-infl_year)/timevary_parm(timevary_parm_cnt+2) )-norm_styr);}
          else
          {parm_timevary(trnd,y1)=parm_timevary(trnd,endyr);}
        }
        parm_timevary(trnd,styr-1)=baseparm;
      }
    }
  }
