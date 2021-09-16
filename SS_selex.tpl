// SS_Label_file  #11. **SS_selex.tpl**
// SS_Label_file  #* <u>get_selectivity()</u>  // does length and age selectivity and retention for all fleets
// SS_Label_file  #* <u>make_fish_selex()</u>  // for all fleets in a particular season, does the dot product of length distribution with length selectivity and retention vectors to calculate equivalent mean quantities at age for each platoon

FUNCTION void get_selectivity()
  {
//*******************************************************************
 /*  SS_Label_Function_22 #get_selectivity */
  //  SS_Label_Info_22.01  #define local variables for selectivity
  int fs;  // = f-Nfleet to allow reference of actual fleet when looping to 2*Nfleet for the age selectivity calculations
  int scaling_offset = 0;
  dvariable t1;
  dvariable t2;
  dvariable t3;
  dvariable t4;
  dvariable Apical_Selex;
  dvariable t1min; dvariable t1max; dvariable t1power;
  dvariable t2min; dvariable t2max; dvariable t2power; dvariable final; dvariable sel_maxL;
  dvariable lastsel; dvariable lastSelPoint; dvariable SelPoint; dvariable finalSelPoint;
  dvariable asc;
  dvariable dsc;

  dvar_vector sp(1,199);                 // temporary vector for selex parms

  Ip=0;
  //  SS_Label_Info_22.2 #Loop all fisheries and surveys twice; first for size selectivity, then for age selectivity
  for (f=1;f<=2*Nfleet;f++)
  {
//  	echoinput<<" selex fleet: "<<f<<" type "<<seltype(f);
  	
    fs=f-Nfleet;  //index for saving age selex in the fleet arrays
  //  SS_Label_Info_22.2.1 #recalculate selectivity for any fleets or surveys with time-vary flag set for this year
    if(timevary_sel(y,f)==1 || save_for_report>0)
    {    // recalculate the selex in this year x type
      if(N_selparmvec(f)>0)      // type has parms, so look for adjustments
      {
        for (j=1;j<=N_selparmvec(f);j++)
        {
          if(selparm_timevary(Ip+j)==0)
            {sp(j)=selparm(Ip+j);}
          else  //  time-varying
          {
            sp(j)=parm_timevary(selparm_timevary(Ip+j),y);
            if(parm_adjust_method==1 && (save_for_report>0 || do_once==1))
            {
              if(sp(j)>-999 && (sp(j)<selparm_1(Ip+j,1) || sp(j)>selparm_1(Ip+j,2)))
              {
                N_warn++;
                 warning<<N_warn<<" "<<" adjusted selparm out of base parm bounds (Phase, Iter, Parm#, yr, min, max, base, value) "<<
                current_phase()<<" "<<niter<<" "<<Ip+j<<" "<<y<<" "<<selparm_1(Ip+j,1)<<" "<<selparm_1(Ip+j,2)<<" "<<selparm(Ip+j)<<" "<<sp(j)<<endl;
              }
            }
          }
        }  // end j parm loop
        if(docheckup==1 && f<=Nfleet) echoinput<<" len selex parms for fleet: "<<f<<" "<<endl<<sp(1,N_selparmvec(f))<<endl;
        if(docheckup==1 && f>Nfleet) echoinput<<" age selex parms for fleet: "<<f-Nfleet<<" "<<endl<<sp(1,N_selparmvec(f))<<endl;
        if(save_for_report>0 || do_once==1)
        {for (j=1;j<=N_selparmvec(f);j++) save_sp_len(y,f,j)=sp(j);
        }
      }
      	
      if(f<=Nfleet)  // do size selectivity, retention, discard mort
      {
      for (gg=1;gg<=gender;gg++)
      {
        if(gg==1 || (gg==2 && seltype(f,3)>=3))
        {
  //  SS_Label_Info_22.3 #Switch on size selectivity type
          switch(seltype(f,1))  // select the selectivity pattern
          {
  //  SS_Label_Info_22.3.0 #case 0 constant size selectivity
            case 0:   // ***********   constant
             {sel = 1.;break;}

  //  SS_Label_Info_22.3.1 #case 1 logistic size selectivity
            case 1:
              {
                if(seltype(f,3)<3 || (gg==1 && seltype(f,3)==3) || (gg==2 && seltype(f,3)==4))  //  do the primary gender
                {sel = 1./(1.+mfexp(neglog19*(len_bins_m-sp(1))/sp(2)));}
                else  //  do the offset gender
                {
                  temp=sp(1)+sp(Maleselparm(f));
                  temp1=sp(2)+sp(Maleselparm(f)+1);
                  sel = sp(Maleselparm(f)+2)/(1.+mfexp(neglog19*(len_bins_m-temp)/temp1));
                }
                break;
              }

  //  SS_Label_Info_22.3.2 #case 2 discontinued; use pattern 8 for double logistic
  //  SS_Label_Info_22.3.24 #case 24 size selectivity using double_normal_plateau and lots of bells and whistles
            case 2:
              {
          if(seltype(f,3)<3 || (gg==1 && seltype(f,3)==3) || (gg==2 && seltype(f,3)==4))
            {peak=sp(1); upselex=mfexp(sp(3)); downselex=mfexp(sp(4)); final=sp(6); Apical_Selex=1.;}
            else
            {   // offset male parameters if seltype(f,3)==3, female parameters if seltype(f,3)==4
              peak=sp(1)+sp(Maleselparm(f));
              upselex=mfexp(sp(3)+sp(Maleselparm(f)+1));
              downselex=mfexp(sp(4)+sp(Maleselparm(f)+2));
              if(sp(6)>-999.) final=sp(6)+sp(Maleselparm(f)+3);
              Apical_Selex=sp(Maleselparm(f)+4);
            }

            if(sp(5)<-1000.)
            {
              j1=-1001-int(value(sp(5)));      // selex is nil thru bin j1, so set sp(5) equal to first bin with selex (e.g. -1002 to start selex at bin 2)
              sel(1,j1)=1.0e-06;
            }
            else
            {
              j1=startbin-1;                // start selex at bin equal to min sizecomp databin  (=j1+1)
              if(sp(5)>-999)
              {
                point1=1.0/(1.0+mfexp(-sp(5)));
              t1min=mfexp(-(square(len_bins_m(startbin)-peak)/upselex));  // fxn at first bin
              }
            }
            if(sp(6)<-1000.)
            {
              j2=-1000-int(value(sp(6))); // selex is constant beyond this sizebin, so set sp(6) equal to last bin with estimated selex
            }
            else
            {j2=nlength;}
            peak2=peak+binwidth2+ (0.99*len_bins_m(j2)-peak-binwidth2)/(1.+mfexp(-sp(2)));
            if(sp(6)>-999)
            {
//              point2=1.0/(1.0+mfexp(-final));
              point2=Apical_Selex/(1.0+mfexp(-final));
              t2min=mfexp(-(square(len_bins_m(j2)-peak2)/downselex));  // fxn at last bin
            }
            for (j=j1+1;j<=j2;j++)
            {
              t1=len_bins_m(j)-peak;  t2=len_bins_m(j)-peak2;
              join1=1.0/(1.0+mfexp(-(20.*t1/(1.0+fabs(t1)))));  //  note the logit transform on t1 causes range of mfexp to be over -20 to 20
              join2=1.0/(1.0+mfexp(-(20.*t2/(1.0+fabs(t2)))));
              if(sp(5)>-999)
                {asc=point1+(Apical_Selex-point1)*(mfexp(-square(t1)/upselex)-t1min)/(1.0-t1min);}
              else
                {asc=Apical_Selex*mfexp(-square(t1)/upselex);}
              if(sp(6)>-999)
                {dsc=Apical_Selex+(point2-Apical_Selex)*(mfexp(-square(t2)/downselex)-1.0    )/(t2min-1.0);}
              else
                {dsc=Apical_Selex*mfexp(-square(t2)/downselex);}
              sel(j)=asc*(1.0-join1)+join1*(Apical_Selex*(1.0-join2)+dsc*join2);
            }
            if(startbin>1 && sp(5)>=-1000.)
            {
              for (j=1;j<=startbin-1;j++)
              {
                sel(j)=square(len_bins_m(j)/len_bins_m(startbin))*sel(startbin);
              }
            }

            if(j2<nlength) {sel(j2+1,nlength)=sel(j2);}
            break;
          }


  //  SS_Label_Info_22.3.3 #case 3 discontinued
          case 3:
          {
            N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" "<<" selex pattern 3 discontinued "<<endl; exit(1);
           break;
          }  // end seltype=3

  //  SS_Label_Info_22.3.4 #case 4 discontinued; use pattern 30 to get spawning biomass
          case 4:
            {N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" "<<" selex pattern 4 discontinued; use pattern 30 to get spawning biomass "<<endl; exit(1); break;}                   // do this as a numbers survey because wt is included here

  //  SS_Label_Info_22.3.5 #case 5 mirror another fleets size selectivity for specified bin range
  //  use only the specified bin range using mirror_mask created upon read
  // must refer to a lower numbered type (f)
          case 5:
          {
           sel=elem_prod(mirror_mask(f),sel_l(y,seltype(f,4),1));
           break;
          }

  //  SS_Label_Info_22.3.15 #case 15 mirror another fleets size selectivity for all size bins
          case 15:
          {
           sel=sel_l(y,seltype(f,4),1);
           break;
          }

  //  SS_Label_Info_22.3.6 #case 6 non-parametric size selex pattern
  // #43 non-parametric size selex scaled by average of values at low bin through high bin
          case 43:
            scaling_offset = 2;
          case 6:
          {
          lastsel=-10.0;  // log(selex) for first bin;
          lastSelPoint=len_bins_m(1);    //  first size
          finalSelPoint=value(sp(2+scaling_offset));  // size beyond which selex is constant
          SelPoint=value(sp(1+scaling_offset));   //  first size that will get a parameter.  Value will get incremented by step interval (temp1)
          z=3+scaling_offset;  // parameter counter
          temp1 = (finalSelPoint-SelPoint)/(seltype(f,4)-1.0);  // step interval
          
          for (j=1;j<=nlength;j++)
          {
            if(len_bins_m(j)<SelPoint)
            {
              tempvec_l(j)=lastsel + (len_bins_m(j)-lastSelPoint)/(SelPoint-lastSelPoint) * (sp(z)-lastsel);
            }
            else if(len_bins_m(j)==SelPoint)
            {
              tempvec_l(j)=sp(z);
              lastsel=sp(z);
              lastSelPoint=SelPoint;
              SelPoint+=temp1;
              if(SelPoint<=finalSelPoint)
                {z++;}
              else
                {SelPoint=finalSelPoint;}
            }
            else if(len_bins_m(j)<=finalSelPoint)
            {
              lastsel=sp(z);
              lastSelPoint=SelPoint;
              SelPoint+=temp1;
              if(SelPoint<=finalSelPoint)
                {z++;}
              else
                {SelPoint=finalSelPoint;}
              tempvec_l(j)=lastsel + (len_bins_m(j)-lastSelPoint)/(SelPoint-lastSelPoint) * (sp(z)-lastsel);
            }
            else
            {tempvec_l(j)=sp(z);}
 #ifdef DO_ONCE
            if(do_once==1)  echoinput<<"selex42  "<<j<<" "<<len_bins_m(j)<<" "<<SelPoint<<" "<<tempvec_l(j)<<endl;
 #endif
          }
          if (scaling_offset == 0)
          {
            temp=max(tempvec_l);
          }
          else
          {
            int low_bin  = int(value(sp(1)));
            int high_bin = int(value(sp(2)));
            if (low_bin < 1)
            {
                low_bin = 1;
                N_warn++;  warning<<N_warn<<" "<<" selex pattern 43; value for low bin is less than 1, so set to 1 "<<endl;
            }
            if (high_bin > nlength)
            {
                high_bin = nlength;
                N_warn++;  warning<<N_warn<<" "<<" selex pattern 43; value for high bin is greater than "<<nlength<<", so set to "<<nlength<<" "<<endl;
            }
            if (high_bin < low_bin) high_bin = low_bin;
            if (low_bin > high_bin) low_bin = high_bin;
            sp(1) = low_bin;
            sp(2) = high_bin;
            temp=mean(tempvec_l(low_bin,high_bin));
            scaling_offset = 0;     // reset scaling offset
          }
          sel = mfexp(tempvec_l-temp);
          break;
          }

  //  SS_Label_Info_22.3.7 #case 7 discontinued; use pattern 8 for double logistic
          case 7:                  // *******New double logistic
    // 1=peak, 2=init,  3=infl,  4=slope, 5=final, 6=infl2, 7=slope2 8=binwidth;    Mirror=1===const_above_Linf
          {
            N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" "<<" selex pattern 7 discontinued; use pattern 8 for double logistic "<<endl; exit(1);
 /*
           t1=minL+(1./(1.+mfexp(-sp(3))))*(sp(1)-minL);    // INFL
           t1min=1./(1.+mfexp(-sp(4)*(minL-t1)))*0.9999;  // asc value at minsize
           t1max=1./(1.+mfexp(-sp(4)*(sp(1)-t1)))*1.00001;  // asc value at peak
           t1power=log(0.5)/log((0.5-t1min)/(t1max-t1min));  // so the parameter will actual correspond to 50% point

           if(seltype(f,4)==0) {sel_maxL=maxL;} else {sel_maxL=Ave_Size(styr,3,1,nages);}
           t2=(sp(1)+sp(8))+(1./(1.+mfexp(-sp(6))))*(sel_maxL-(sp(1)+sp(8)));    // INFL
           t2min=1./(1.+mfexp(-sp(7)*(sp(1)+sp(8)-t2)))*0.9999;  // asc value at peak+
           t2max=1./(1.+mfexp(-sp(7)*(sel_maxL-t2)))*1.00001;  // asc value at maxL
           t2power=log(0.5)/log((0.5-t2min)/(t2max-t2min));
           final=1./(1.+mfexp(-sp(5)));

           for (j=1; j<=nlength; j++)  //calculate the value over length bins
           {sel(j) =
             (
             (
             (sp(2) + (1. - sp(2)) * pow((( 1./(1.+mfexp(-sp(4)*(len_bins_m(j)-t1))) -t1min ) / (t1max-t1min) ),t1power))
              /(1.+mfexp(10.*(len_bins_m(j)-sp(1))))   // scale ascending side
              +
              1./(1.+mfexp(-10.*(len_bins_m(j)-sp(1))))   // flattop, with scaling
              )
              /(1.+mfexp( 10.*(len_bins_m(j)-(sp(1)+sp(8)))))    // scale combo of ascending and flattop
              +
              (1. + (final - 1.) * pow(sqrt(square((( 1./(1.+mfexp(-sp(7)*(len_bins_m(j)-t2))) -t2min ) / (t2max-t2min) ))),t2power))
              /(1.+mfexp( -10.*(len_bins_m(j)-(sp(1)+sp(8)))))    // scale descending
              ) / (1.+mfexp(10.*(len_bins_m(j)-sel_maxL)));       // scale combo of ascend, flattop, descending
             sel(j)+=final/(1.+mfexp(-10.*(len_bins_m(j)-sel_maxL)));  // add scaled portion above Linf
           }   // end size bin loop
  */
           break;
          }    // end New double logistic

  //  SS_Label_Info_22.3.8 #case 8 double logistic  with eight parameters
          case 8:                  // *******New double logistic in simpler code
    // 1=peak, 2=init,  3=infl,  4=slope, 5=final, 6=infl2, 7=slope2 8=binwidth;    Mirror=1===const_above_Linf
          {
           t1=minL+(1./(1.+mfexp(-sp(3))))*(sp(1)-minL);    // INFL
           t1min=1./(1.+mfexp(-mfexp(sp(4))*(minL-t1)))*0.9999;  // asc value at minsize
           t1max=1./(1.+mfexp(-mfexp(sp(4))*(sp(1)-t1)))*1.0001;  // asc value at peak
           t1power=log(0.5)/log((0.5-t1min)/(t1max-t1min));  // so the parameter will actual correspond to 50% point

           if(seltype(f,4)==0) {sel_maxL=maxL;} else {sel_maxL=Ave_Size(styr,1,1,nages);}
           t2=(sp(1)+sp(8))+(1./(1.+mfexp(-sp(6))))*(sel_maxL-(sp(1)+sp(8)));    // INFL
           t2min=1./(1.+mfexp(-mfexp(sp(7))*(sp(1)+sp(8)-t2)))*0.9999;  // asc value at peak+
           t2max=1./(1.+mfexp(-mfexp(sp(7))*(sel_maxL-t2)))*1.0001;  // asc value at maxL
           t2power=log(0.5)/log((0.5-t2min)/(t2max-t2min));
           final=1./(1.+mfexp(-sp(5)));
           for (j=1; j<=nlength; j++)  //calculate the value over length bins
           {join1=1./(1.+mfexp(10.*(len_bins_m(j)-sp(1))));
            join2=1./(1.+mfexp(10.*(len_bins_m(j)-(sp(1)+sp(8)))));
            join3=1./(1.+mfexp(10.*(len_bins_m(j)-sel_maxL)));
            upselex=sp(2) + (1. - sp(2)) * pow((( 1./(1.+mfexp(-mfexp(sp(4))*(len_bins_m(j)-t1)))-t1min ) / (t1max-t1min)),t1power);
            downselex=(1. + (final - 1.) * pow(fabs(((( 1./(1.+mfexp(-mfexp(sp(7))*(len_bins_m(j)-t2))) -t2min ) / (t2max-t2min) ))),t2power));
            sel(j) = ((((upselex*join1)+1.0*(1.0-join1))*join2) + downselex*(1-join2))*join3 + final*(1-join3);
           }   // end size bin loop
           break;
          }    // end New double logistic

  //  SS_Label_Info_22.3.9 #case 9 old double logistic with 4 parameters
          case 9:
          {k1=int(value(sp(5)));
           if(k1>1) sel(1,k1-1) = 0.0;
           sel(k1,nlength) =   elem_prod(  (1/(1+mfexp(-sp(2)*(len_bins_m(k1,nlength)-sp(1)) ))),
                                                (1-1/(1+mfexp(-sp(4)*(len_bins_m(k1,nlength)-(sp(1)*sp(6)+sp(3))) ))) );
           sel += 1.0e-6;
           sel /=max(sel);
           break;
            }

  //  SS_Label_Info_22.3.11 #case 11 selex=1.0 within a range of lengths
		  case 11: 
		  {
			sel=mirror_mask(f); // (y,f,1)
			break;
          }
  //  SS_Label_Info_22.3.21 #case 21 non-parametric size selectivity
 /*  N points; where the first N parameters is vector of sizes for the line segment ends
    and second N parameters is selectivity at that size (no transformations) */
          case 21:                 // *******New non-parametric
          {
            j=1;
            z=1;
            k=seltype(f,4);  //  N points
            lastsel=0.0;
            lastSelPoint=0.0;

 #ifdef DO_ONCE
            if(do_once==1)
            {
              if(sp(k)>len_bins(nlength))
              {N_warn++; cout<<" EXIT - see warning "<<endl;  warning<<N_warn<<" "<<"Selex21: cannot have max selpoint > max_pop_lenbin"<<endl;  exit(1);}
              if(sp(k-1)>len_bins(nlength-1))
              {N_warn++;  warning<<N_warn<<" "<<"Selex21: should not have selpoint(n-1) > pop_lenbin(nlength-1)"<<endl;}
            }
 #endif

            while(j<=nlength)
            {
              if(len_bins(j)<=sp(z))
              {
                sel(j) = lastsel + (len_bins(j)-lastSelPoint)/(sp(z)-lastSelPoint) * (sp(z+k)-lastsel);
                j++;
              }
              else if(z<=k)
              {
                lastSelPoint=sp(z);
                lastsel=sp(z+k);
                z++;
              }
              else  //  for sizes beyond last point
              {
                sel(j)=sp(k+k);
                j++;
              }
            }
           break;
          }

  //  SS_Label_Info_22.3.22 #case 22 size selectivity using double_normal_plateau (similar to CASAL)
          case 22:
            {peak2=sp(1)+ (0.99*len_bins(nlength)-sp(1))/(1.+mfexp(-sp(2))); upselex=mfexp(sp(3)); downselex=mfexp(sp(4));
             for (j=1;j<=nlength;j++)
             {
              t1=len_bins_m(j);
              if(t1<sp(1))
                {sel(j)=mfexp(-square(t1-sp(1))/upselex);}
              else if (t1<=peak2)
                {sel(j)=1.0;}
              else
                {sel(j)=mfexp(-square(t1-peak2)/downselex);}
             }
             break;
            }

  //  SS_Label_Info_22.3.23 #case 23 size selectivity double_normal_plateau where final value can be greater than 1.0
 /*  cannot be used with Pope's because can cause selex to be >1.0 */
         case 23:
          {
          if(seltype(f,3)<3 || (gg==1 && seltype(f,3)==3) || (gg==2 && seltype(f,3)==4))
            {peak=sp(1); upselex=mfexp(sp(3)); downselex=mfexp(sp(4)); final=sp(6);}
            else
            {   // offset male parameters if seltype(f,3)==3
              peak=sp(1)+sp(Maleselparm(f));
              upselex=mfexp(sp(3)+sp(Maleselparm(f)+1));
              downselex=mfexp(sp(4)+sp(Maleselparm(f)+2));
              if(sp(6)>-999.) final=sp(6)+sp(Maleselparm(f)+3);
            }

            if(sp(5)<-1000.)
            {
              j1=-1001-int(value(sp(5)));      // selex is nil thru bin j1, so set sp(5) equal to first bin with selex (e.g. -1002 to start selex at bin 2)
              sel(1,j1)=1.0e-06;
            }
            else
            {
              j1=startbin-1;                // start selex at bin equal to min sizecomp databin  (=j1+1)
              if(sp(5)>-999)
              {
                point1=1.0/(1.0+mfexp(-sp(5)));
              t1min=mfexp(-(square(len_bins_m(startbin)-peak)/upselex));  // fxn at first bin
              }
            }
            if(sp(6)<-1000.)
            {
              j2=-1000-int(value(sp(6))); // selex is constant beyond this sizebin, so set sp(6) equal to last bin with estimated selex
            }
            else
            {j2=nlength;}
            peak2=peak+binwidth2+ (0.99*len_bins_m(j2)-peak-binwidth2)/(1.+mfexp(-sp(2)));
            if(sp(6)>-999)
            {
              point2=final;
              t2min=mfexp(-(square(len_bins_m(j2)-peak2)/downselex));  // fxn at last bin
            }
            for (j=j1+1;j<=j2;j++)
            {
              t1=len_bins_m(j)-peak;  t2=len_bins_m(j)-peak2;
              join1=1.0/(1.0+mfexp(-(20.*t1/(1.0+fabs(t1)))));  //  note the logit transform on t1 causes range of mfexp to be over -20 to 20
              join2=1.0/(1.0+mfexp(-(20.*t2/(1.0+fabs(t2)))));
              if(sp(5)>-999)
                {asc=point1+(1.0-point1)*(mfexp(-square(t1)/upselex)-t1min)/(1.0-t1min);}
              else
                {asc=mfexp(-square(t1)/upselex);}
              if(sp(6)>-999)
                {dsc=1.0+(point2-1.0)*(mfexp(-square(t2)/downselex)-1.0    )/(t2min-1.0);}
              else
                {dsc=mfexp(-square(t2)/downselex);}
              sel(j)=asc*(1.0-join1)+join1*(1.0-join2+dsc*join2);
            }
            if(startbin>1 && sp(5)>=-1000.)
            {
              for (j=1;j<=startbin-1;j++)
              {
                sel(j)=square(len_bins_m(j)/len_bins_m(startbin))*sel(startbin);
              }
            }

            if(j2<nlength) {sel(j2+1,nlength)=sel(j2);}
            break;
          }


  //  SS_Label_Info_22.3.24 #case 24 size selectivity using double_normal_plateau and lots of bells and whistles
          case 24:
          {
          if(seltype(f,3)<3 || (gg==1 && seltype(f,3)==3) || (gg==2 && seltype(f,3)==4))
            {peak=sp(1); upselex=mfexp(sp(3)); downselex=mfexp(sp(4)); final=sp(6); Apical_Selex=1.;}
            else
            {   // offset male parameters if seltype(f,3)==3, female parameters if seltype(f,3)==4
              peak=sp(1)+sp(Maleselparm(f));
              upselex=mfexp(sp(3)+sp(Maleselparm(f)+1));
              downselex=mfexp(sp(4)+sp(Maleselparm(f)+2));
              if(sp(6)>-999.) final=sp(6)+sp(Maleselparm(f)+3);
              Apical_Selex=sp(Maleselparm(f)+4);
            }

            if(sp(5)<-1000.)
            {
              j1=-1001-int(value(sp(5)));      // selex is nil thru bin j1, so set sp(5) equal to first bin with selex (e.g. -1002 to start selex at bin 2)
              sel(1,j1)=1.0e-06;
            }
            else
            {
              j1=startbin-1;                // start selex at bin equal to min sizecomp databin  (=j1+1)
              if(sp(5)>-999)
              {
                point1=1.0/(1.0+mfexp(-sp(5)));
              t1min=mfexp(-(square(len_bins_m(startbin)-peak)/upselex));  // fxn at first bin
              }
            }
            if(sp(6)<-1000.)
            {
              j2=-1000-int(value(sp(6))); // selex is constant beyond this sizebin, so set sp(6) equal to last bin with estimated selex
            }
            else
            {j2=nlength;}
            peak2=peak+binwidth2+ (0.99*len_bins_m(j2)-peak-binwidth2)/(1.+mfexp(-sp(2)));
            if(sp(6)>-999)
            {
              point2=1.0/(1.0+mfexp(-final));
              t2min=mfexp(-(square(len_bins_m(j2)-peak2)/downselex));  // fxn at last bin
            }
            for (j=j1+1;j<=j2;j++)
            {
              t1=len_bins_m(j)-peak;  t2=len_bins_m(j)-peak2;
              join1=1.0/(1.0+mfexp(-(20.*t1/(1.0+fabs(t1)))));  //  note the logit transform on t1 causes range of mfexp to be over -20 to 20
              join2=1.0/(1.0+mfexp(-(20.*t2/(1.0+fabs(t2)))));
              if(sp(5)>-999)
                {asc=point1+(Apical_Selex-point1)*(mfexp(-square(t1)/upselex)-t1min)/(1.0-t1min);}
              else
                {asc=Apical_Selex*mfexp(-square(t1)/upselex);}
              if(sp(6)>-999)
                {dsc=Apical_Selex+(point2-Apical_Selex)*(mfexp(-square(t2)/downselex)-1.0    )/(t2min-1.0);}
              else
                {dsc=Apical_Selex*mfexp(-square(t2)/downselex);}
              sel(j)=asc*(1.0-join1)+join1*(Apical_Selex*(1.0-join2)+dsc*join2);
            }
            if(startbin>1 && sp(5)>=-1000.)
            {
              for (j=1;j<=startbin-1;j++)
              {
                sel(j)=square(len_bins_m(j)/len_bins_m(startbin))*sel(startbin);
              }
            }

            if(j2<nlength) {sel(j2+1,nlength)=sel(j2);}
            break;
          }

  //  SS_Label_Info_22.3.25 #case 25 size selectivity using exponential-logistic
          case 25:
          {
            peak = len_bins_m(1) + sp(2)*(len_bins_m(nlength)-len_bins_m(1));
            for (j=1;j<=nlength;j++)
              {sel(j) = mfexp(sp(3)*sp(1)*(peak-len_bins_m(j)))/(1.0-sp(3)*(1.0-mfexp(sp(1)*(peak-len_bins_m(j)))));}
            break;
          }

  //  SS_Label_Info_22.3.27 #case 27 size selectivity using cubic spline
  // #42 size selectivity using cubic spline scaled by average of values at low bin through high bin
 /*  first N parameters are the spline knots; second N parameters are ln(selex) at the knot */
 /*  uses max(raw vector) to achieve scale to 1.0 */
          case 42:
            scaling_offset = 2;
          case 27:
          {
            int j2;
  // define vectors which form the basis for cubic spline selectivity
  // IMPORTANT: these vectors might need to be expanded to fit values for multiple fleets
  dvector splineX(1,200);
  dvar_vector splineY(1,200);
  splineX.initialize();
  splineY.initialize();
            j=1;
            k=seltype(f,4);  // n points to include in cubic spline
            for (i=1;i<=k;i++)
            {
              splineX(i)=value(sp(i+3+scaling_offset)); // "value" required to avoid error, but values should be always fixed anyway
              splineY(i)=sp(i+3+k+scaling_offset);
            }
            z=nlength;
            while(len_bins_m(z)>splineX(k)) {z--;}
            j2=z+1;  //  first size bin beyond last node
            vcubic_spline_function splinefn=vcubic_spline_function(splineX(1,k),splineY(1,k),sp(2+scaling_offset),sp(3+scaling_offset));
            tempvec_l = splinefn(len_bins_m);  // interpolate selectivity at the mid-point of each population size bin
            if (scaling_offset == 0)
            {
                temp=max(tempvec_l(1,j2));
            }
            else
            {
                int low_bin  = int(value(sp(1)));
                int high_bin = int(value(sp(2)));
                if (low_bin < 1)
                {
                    low_bin = 1;
                    N_warn++;  warning<<N_warn<<" "<<" selex pattern 42; value for low bin is less than 1, so set to 1 "<<endl;
                }
                if (high_bin > nlength)
                {
                    high_bin = nlength;
                    N_warn++;  warning<<N_warn<<" "<<" selex pattern 42; value for high bin is greater than "<<nlength<<", so set to "<<nlength<<" "<<endl;
                }
                if (high_bin < low_bin) high_bin = low_bin;
                if (low_bin > high_bin) low_bin = high_bin;
                sp(1) = low_bin;
                sp(2) = high_bin;
                temp=mean(tempvec_l(low_bin,high_bin));
                scaling_offset = 0;     // reset scaling offset
            }
            tempvec_l-=temp;  // rescale to get max of 0.0
            tempvec_l(j2+1,nlength) = tempvec_l(j2);  //  set constant above last node
            sel = mfexp(tempvec_l);
            break;
          }

          default:
          	{
          		sel=1.0;
          		break;
          	}
          }
          sel_l(y,f,gg)=sel;    // Store size-selex in year*type array
        }  // end direct calc of selex from parameters

  //  SS_Label_Info_22.4 #Do male relative to female selex
        if(gg==2)         // males exist and am now in the male loop
        {
         if(seltype(f,1)==4)
           {sel_l(y,f,2)=0.;}  // set males to zero for spawning biomass
         else if(seltype(f,1)==5)    // set males equal to mirrored males
         {
//          i=int(value(sp(1)));  if(i<=0) i=1;
//          j=int(value(sp(2)));  if(j<=0) j=nlength;
          sel_l(y,f,2)=elem_prod(mirror_mask(f),sel_l(y,seltype(f,4),2));
         }
         else if(seltype(f,1)==15)    // set males equal to mirrored males
         {
          sel_l(y,f,2)=sel_l(y,seltype(f,4),2);
         }
         else if(seltype(f,3)==1 || seltype(f,3)==2)   // do gender selex as offset
         {
//           k=seltype_Nparam(seltype(f,1)) + 1;
//           if(seltype(f,2)>0) k+=seltype(f,2)*4;   // first gender offset parm (skip over the retention parameters
//           if(seltype(f,1)==6) k += seltype(f,4);    // for non-parametric in which N parm is stored in special column
           k=Maleselparm(f);
           temp=sp(k);
           temp1=1.;
           switch(seltype(f,3))
           {
             case 1:
             {                            // do males relative to females
               for (j=1;j<=nlength;j++)
               {
                 if(len_bins_m(j)<=temp)
                   {sel(j)*=mfexp(sp(k+1)+(len_bins_m(j)-minL_m)/(temp-minL_m) * (sp(k+2)-sp(k+1)) );}
                 else
                   {sel(j)*=mfexp(sp(k+2)+(len_bins_m(j)-temp) /(maxL-temp)  * (sp(k+3)-sp(k+2)) );}
//                 if(sel(j)>temp1) temp1=sel(j);
               }
               sel_l(y,f,2)=sel;
               tempvec_a(1)=max(sel_l(y,f,1));
               tempvec_a(2)=max(sel_l(y,f,2));
               temp1=max(tempvec_a(1,2));
               sel_l(y,f) /=temp1;
               break;
             }
             case 2:
             {                   //  do females relative to males
               sel_l(y,f,2)=sel;
               for (j=1;j<=nlength;j++)
               {
                 if(len_bins_m(j)<=temp)
                   {sel(j)*=mfexp(sp(k+1)+(len_bins_m(j)-minL_m)/(temp-minL_m) * (sp(k+2)-sp(k+1)) );}
                 else
                   {sel(j)*=mfexp(sp(k+2)+(len_bins_m(j)-temp) /(maxL-temp)  * (sp(k+3)-sp(k+2)) );}
//                 if(sel(j)>temp1) temp1=sel(j);
               }
               sel_l(y,f,1)=sel;
               tempvec_a(1)=max(sel_l(y,f,1));
               tempvec_a(2)=max(sel_l(y,f,2));
               temp1=max(tempvec_a(1,2));
               sel_l(y,f)/=temp1;
               break;
             }
           }  // end switch
         }  // end do gender selex as offset from other gender
  //  SS_Label_Info_22.5 #Calculate size-specific retention and discard mortality
         else if(seltype(f,3)!=3 && seltype(f,3)!=4)  // where the "3" and "4" option do the male offset as direct parameters, rathen than do selex as offset
         {
           sel_l(y,f,2)=sel;
         }
        }  // end doing males
        if(docheckup==1) echoinput<<gg<<"  sel-len"<<sel_l(y,f,gg)<<endl;

      }  // end loop of genders

//  apply 2D_AR adjustment to sex-specific length selectivity
//  TwoD_AR_def: read:  1-fleet, 2-ymin, 3-ymax, 4-amin, 5-amax, 6-sigma_amax, 7-use_rho, 8-age/len, 9-dev_phase; 10-before_yrs, 11=after_yrs, 
//  calc quantities:  12-N_parm_dev, 13-selparm_location

    if(TwoD_AR_use(f)>0)
    {
      j=TwoD_AR_use(f);  //  get index for this fleet's effect
      if(TwoD_AR_def[j](8)==1)  //  age vs length flag
      {
        z=TwoD_AR_def[j](12);  // index of dev vector used
        if(docheckup==1) echoinput<<"2dar for fleet: "<<f<<" 2DAR: "<<j<<" dev: "<<z<<endl;

        if(y==styr && (TwoD_AR_before(j)==3 || TwoD_AR_after(j)==3) )  //  if needed, calculate average dev for each length over the range of years
        {
          TwoD_AR_ave(j).initialize();
          for(int yyy=TwoD_AR_ymin(j); yyy<=TwoD_AR_ymax(j); yyy++)
          {
            k=(yyy-TwoD_AR_ymin(j))*(TwoD_AR_amax(j)-TwoD_AR_amin(j)+1);  //  index of 1st dev in vector created from year and length index
            for(int ll=TwoD_AR_amin(j);ll<=TwoD_AR_amax(j);ll++)
            {
              k++;
              TwoD_AR_ave(j,ll)+=parm_dev(z,k);   //  sum devs for each length
            }
          }
          TwoD_AR_ave(j)/=(TwoD_AR_ymax(j)-TwoD_AR_ymin(j)+1.0);
 #ifdef DO_ONCE
          if(do_once==1) echoinput<<"mean 2D AR dev for fleet: "<<f<<" means: "<<TwoD_AR_ave(j)<<endl;
 #endif
        }

        if(y<TwoD_AR_ymin(j))  //  early years
        {
          if(TwoD_AR_before(j)==0)  //  apply no devs
          {k=-2;}
          else if(TwoD_AR_before(j)==1)   //  use first year devs
          {
//          k=(TwoD_AR_ymin(j)-TwoD_AR_ymin(j))*(TwoD_AR_amax(j)-TwoD_AR_amin(j)+1);  //  index of 1st dev in vector created from year and length index
            k=0;
          }
          else if(TwoD_AR_before(j)==3)   //  use mean length-specific devs
          {k=-1;}
        }
        else if(y<=TwoD_AR_ymax(j))  //  in year range for annual devs
        {
          k=(y-TwoD_AR_ymin(j))*(TwoD_AR_amax(j)-TwoD_AR_amin(j)+1);  //  index of 1st dev in vector created from year and length index
        }
        else  //  later years
        {
          if(TwoD_AR_after(j)==0)  //  apply no devs
          {k=-2;}
          else if(TwoD_AR_after(j)==1)   //  use last year devs
          {k=(TwoD_AR_ymax(j)-TwoD_AR_ymin(j))*(TwoD_AR_amax(j)-TwoD_AR_amin(j)+1);}  //  index of 1st dev in vector created from year and length index
          else if(TwoD_AR_after(j)==3)   //  use mean length-specific devs
          {k=-1;}
        }

        if(docheckup==1) echoinput<<"K value for first dev to use: "<<k<<endl;
        if(k>-2)
        {
          a1=TwoD_AR_def[j](13)-1;  //  parameter number-1  for sigmasel
          dvariable sigmasel;
          for(a=TwoD_AR_amin(j);a<=TwoD_AR_amax(j);a++)  // loop lengths, using "a" as index
          {
            if(a<=TwoD_AR_def[j](6))  // so get sigmasel for this length bin
            {
              a1++;
              sigmasel=selparm(a1);
            }
            if(k>=0)
            {
              k++; 
              if(docheckup==1) echoinput<<a<<"  sigmasel: "<<sigmasel<<endl;
              sel_l(y,f,1,a)*=mfexp(sigmasel*parm_dev(z,k));
              if(gender==2) sel_l(y,f,2,a)*=mfexp(sigmasel*parm_dev(z,k));
            }
            else  //  use mean devs
            {
              sel_l(y,f,1,a)*=mfexp(sigmasel*TwoD_AR_ave(j,a));
              if(gender==2) sel_l(y,f,2,a)*=mfexp(sigmasel*TwoD_AR_ave(j,a));
            }
          }
        }
        if(docheckup==1) echoinput<<"len selex after 2D_AR"<<endl<<sel_l(y,f)<<endl;
      }
    }

  //  SS_Label_Info_22.5.1 #Calculate discmort
  // discmort is the size-specific fraction of discarded fish that die
  //  discmort2 is size-specific fraction that die from being retained or are dead discard
  //   = elem_prod(sel,(retain + (1-retain)*discmort)) */

      if(seltype(f,2)==0)  //  no discard, all retained
      {
        retain(y,f)=1.0;
        sel_l_r(y,f)=sel_l(y,f);
        discmort(y,f)=1.0;
        discmort2(y,f)=sel_l(y,f);
        if(gender==2)
        {
          discmort_M=1.0;
          retain_M=1.0;
        }
      }
      else if(seltype(f,2)==3)  // none retained; all dead
      {
        retain(y,f)=0.0;
        discmort(y,f)=1.0;
        sel_l_r(y,f)=0.0;
        discmort2(y,f)=sel_l(y,f);
        if(gender==2)
        {
          discmort_M=1.0;
          retain_M=0.0;
        }
      }
      else
      {
        if(seltype(f,2)<0)  // mirror
        {
          k=-seltype(f,2);
          retain(y,f)=retain(y,k);
          discmort(y,f)=discmort(y,k);
          if(seltype(k,2)==1)
          {
            discmort2(y,f)=sel_l(y,f);  //  all selected fish are dead;  this statement does both genders implicitly
          }
          else
          {
            discmort2(y,f,1)=elem_prod(sel_l(y,f,1), retain(y,f)(1,nlength) + elem_prod((1.-retain(y,f)(1,nlength)),discmort(y,f)(1,nlength)) );
          }
        }
        else
        {
          k=RetainParm(f);
          if(sp(k+2)==-999.)
            {temp1=0.0;}
          else if (sp(k+2)==999.)
            {temp1=1.0;}
          else
            {temp1=1.0/(1.0+mfexp(-sp(k+2)));}
//  where maleoffset is a vector of 2*nbins with 0 in length bins for females and 1 for male bins
          retain(y,f)=temp1/(1.+mfexp(-(len_bins_m2-(sp(k)+male_offset*sp(k+3)))/sp(k+1)));  // males are at end of vector, so automatically get done
          if(seltype(f,2)==4)
          {
            // allow for dome-shaped retention in 3.30 only
            retain(y,f) = elem_prod(retain(y,f),(1.-(1./(1.+mfexp(-(len_bins_m2-(sp(k+4)+male_offset*sp(k+6)))/sp(k+5))))));
          }
          if(docheckup==1&&y==styr)
          {
            echoinput<<"retention parms start at #: "<<k<<" infl: "<<sp(k)<<" slope: "<<sp(k+1)<<" male_offset "<<sp(k+3)<<" asymptote: "<<temp1;
            if(seltype(f,2)==4)
            {
                // additional dome-shaped retention parameters
                echoinput<<" "<<sp(k+4)<<" "<<sp(k+5)<<" "<<sp(k+6);
            }
            echoinput<<"retention "<<retain(y,f)<<endl;
          }

          if(seltype(f,2)==1)  // all discards are dead
          {
            discmort(y,f)=1.0;
            discmort2(y,f)=sel_l(y,f);  //  all selected fish are dead;  this statement does both genders implicitly
          }
          else
          {
            k+=N_ret_parm(seltype(f,2));  // first discard mortality parm
            temp=1.-sp(k+2);
            temp1=posfun(temp,0.0,CrashPen);
            discmort(y,f)=(1.-temp1/(1+mfexp(-(len_bins_m2-(sp(k)+male_offset*sp(k+3)))/sp(k+1))));  // males are at end of vector, so automatically get done
            if(docheckup==1&&y==styr) echoinput<<"discmort "<<discmort(y,f)<<endl;
            discmort2(y,f,1)=elem_prod(sel_l(y,f,1), retain(y,f)(1,nlength) + elem_prod((1.-retain(y,f)(1,nlength)),discmort(y,f)(1,nlength)) );
          }
        }

        sel_l_r(y,f,1)=elem_prod(sel_l(y,f,1),retain(y,f)(1,nlength));
        if(gender==2)
        {
          discmort_M.shift(nlength1)=discmort(y,f)(nlength1,nlength2);
          retain_M.shift(nlength1)=retain(y,f)(nlength1,nlength2);
          sel_l_r(y,f,2)=elem_prod(sel_l(y,f,2),retain_M.shift(1));
          discmort2(y,f,2)=elem_prod(sel_l(y,f,2), retain_M.shift(1) + elem_prod((1.-retain_M.shift(1)),discmort_M.shift(1)) );  // V3.21f
        }
      }
      if(docheckup==1&&y==styr) echoinput<<"sel-len-r "<<sel_l_r(y,f)<<endl;
      if(docheckup==1&&y==styr) echoinput<<" dead "<<discmort2(y,f)<<endl;

      }  //  end loop of fleets for size selex and retention and discard mortality

  //  SS_Label_Info_22.6 #Do age-selectivity
      else
      {
        for (gg=1;gg<=gender;gg++)
        {
          if(gg==1 || (gg==2 && seltype(f,3)>=3) || (gg==2 && (seltype(f,1)==44 || seltype(f,1)==45)))  //  in age selex
          {
  //  SS_Label_Logic_22.7 #Switch depending on the age-selectivity pattern selected
            switch(seltype(f,1))
            {

  //  SS_Label_Info_22.7.0 #Constant age-specific selex for ages 0 to nages
              case 0:
              {sel_a(y,fs,1)(0,nages)=1.00; break;}

  //  SS_Label_Info_22.7.10 #Constant age-specific selex for ages 1 to nages
              case 10:
              {sel_a(y,fs,1)(1,nages)=1.00; break;}

  //  SS_Label_Info_22.7.11 #Constant age-specific selex for specified age range
              case 11:   // selex=1.0 within a range of ages
              {
//              	echoinput<<f<<" min max "<<sp(1)<<" "<<sp(2)<<endl;
//                a=int(value(sp(2)));
//                if(a>nages) {a=nages;}
//                sel_a(y,fs,1)(int(value(sp(1))),a)=1.;
                sel_a(y,fs,1)=mirror_mask_a(fs);
                break;
              }

  //  SS_Label_Info_22.7.12 #age selectivity - logistic
              case 12:
              {
              	sel_a(y,fs,1).initialize();
              	sel_a(y,fs,1)(Min_selage(fs),nages) = 1./(1.+mfexp(neglog19*(r_ages(Min_selage(fs),nages)-sp(1))/sp(2)));
              	break;}

  //  SS_Label_Info_22.7.13 #age selectivity - double logistic
              case 13:
                                       // 1=peak, 2=init,  3=infl,  4=slope, 5=final, 6=infl2, 7=slope2, 8=plateau
              {
               	sel_a(y,fs,1).initialize();
                t1=0.+(1./(1.+mfexp(-sp(3))))*(sp(1)-0.);    // INFL
                t1min=1./(1.+mfexp(-sp(4)*(0.-t1)))*0.9999999;  // asc value at minage
                t1max=1./(1.+mfexp(-sp(4)*(sp(1)-t1)))*1.00001;  // asc value at peak
                t1power=log(0.5)/log((0.5-t1min)/(t1max-t1min));

                t2=(sp(1)+sp(8))+(1./(1.+mfexp(-sp(6))))*(r_ages(nages)-(sp(1)+sp(8)));    // INFL
                t2min=1./(1.+mfexp(-sp(7)*(sp(1)+sp(8)-t2)))*0.9999;  // asc value at peak+
                t2max=1./(1.+mfexp(-sp(7)*(r_ages(nages)-t2)))*1.00001;  // asc value at maxage
                t2power=log(0.5)/log((0.5-t2min)/(t2max-t2min));
                final=1./(1.+mfexp(-sp(5)));
                k1=int(value(sp(1))); k2=int(value(sp(1)+sp(8)));

                for (a=Min_selage(fs); a<=nages; a++)  //calculate the value over ages
                {
                  if (a < k1) // ascending limb
                  {
                    sel_a(y,fs,1,a) = sp(2) + (1. - sp(2)) *
                    pow((( 1./(1.+mfexp(-sp(4)*(r_ages(a)-t1))) -t1min ) / (t1max-t1min) ),t1power);
                  }
                  else if (a > k2) // descending limb
                  {
                    sel_a(y,fs,1,a) = 1. + (final - 1.) *
                    pow((( 1./(1.+mfexp(-sp(7)*(r_ages(a)-t2))) -t2min ) / (t2max-t2min) ),t2power);
                  }
                  else // at the peak
                  { sel_a(y,fs,1,a) = 1.0;}
                }   // end age loop
                break;
              }    // end double logistic

  //  SS_Label_Info_22.7.14 #age selectivity - separate parm for each age
              case 14:
            {
             temp=9.-max(sp(1,nages+1));  //  this forces at least one age to have selex weight equal to 9
             	sel_a(y,fs,1).initialize();
             for (a=Min_selage(fs);a<=nages;a++)
             {
              if(sp(a+1)>-999)
              {sel_a(y,fs,1,a) = 1./(1.+mfexp(-(sp(a+1)+temp)));}
              else
              {sel_a(y,fs,1,a) = sel_a(y,fs,1,a-1);}
              }
              break;
            }

  //  SS_Label_Info_22.7.15 #age selectivity - mirror selex for lower numbered fleet
   // must refer to a lower numbered type (f)
              case 15:
            {
              sel_a(y,fs)=sel_a(y,seltype(f,4));
              break;
            }

  //  SS_Label_Info_22.7.16 #age selectivity: Coleraine - Gaussian
              case 16:
            {
             t1 = 1/(1+mfexp(-sp(1)))*nages;
             sel_a(y,fs,1).initialize();
             for (a=Min_selage(fs);a<=nages;a++)
             {
              if(a<t1)
              {sel_a(y,fs,1,a) = mfexp(-square(r_ages(a)-t1)/mfexp(sp(2)));}
              else
              {sel_a(y,fs,1,a)=1.0;}
             }
             break;
            }

  //  SS_Label_Info_22.7.17 #age selectivity: each age has parameter as random walk
  // #41 each age has parameter as random walk scaled by average of values at low age through high age
  //    transformation as selex=exp(parm); some special codes */
              case 41:
                scaling_offset = 2;
              case 17:                  //
            {
              lastsel=0.0;  //  value is the change in log(selex);  this is the reference value for age 0
              tempvec_a=-999.;
              tempvec_a(0)=0.0;   //  so do not try to estimate the first value
              int lastage;
              if(seltype(f,4)==0)
              {lastage=nages;}
              else
              {lastage=abs(seltype(f,4));}

              for (a=1;a<=lastage;a++)
              {
                //  with use of -999, lastsel stays constant until changed, so could create a linear change in ln(selex)
                                                      // use of (a+1) is because the first element, sp(1), is for age zero
                if(sp(a+1+scaling_offset)>-999.) {lastsel=sp(a+1+scaling_offset);}
                tempvec_a(a)=tempvec_a(a-1)+lastsel;   // cumulative log(selex)
              }
              if (scaling_offset == 0)
              {
                  temp=max(tempvec_a);   //  find max so at least one age will have selex=1.
              }
              else
              {
                  int low_bin  = int(value(sp(1)));
                  int high_bin = int(value(sp(2)));
                  if (low_bin < 0)
                  {
                      low_bin = 0;
                      N_warn++;  warning<<N_warn<<" "<<" selex pattern 41; value for low bin is less than 0, so set to 0 "<<endl;
                  }
                  if (high_bin > nages)
                  {
                      high_bin = nages;
                      N_warn++;  warning<<N_warn<<" "<<" selex pattern 41; value for high bin is greater than "<<nages<<", so set to "<<nages<<" "<<endl;
                  }
                  if (high_bin < low_bin) high_bin = low_bin;
                  if (low_bin > high_bin) low_bin = high_bin;
                  sp(1) = low_bin;
                  sp(2) = high_bin;
                  temp=mean(tempvec_a(low_bin,high_bin));
              }
              sel_a(y,fs,1)=mfexp(tempvec_a-temp);
              a=0;
              while(sp(a+1+scaling_offset)==-1000)  //  reset range of young ages to selex=0.0
              {
                sel_a(y,fs,1,a)=0.0;
                a++;
              }
              scaling_offset = 0;     // reset scaling offset
              if(lastage<nages)
              {
                for (a=lastage+1;a<=nages;a++)
                {
                  if(seltype(f,4)>0)
                  {sel_a(y,fs,1,a)=sel_a(y,fs,1,a-1);}
                  else
                  {sel_a(y,fs,1,a)=0.0;}
                }
              }
              break;
            }

              case 44:  //  like age selex 17 but with separate parameters for males and with revised controls
            {
              //  sp(1) is first age with non-zero selectivity; can be age 0
              //  seltype(f,4) is number of selectivity change parameters beginning at age=first_age+1
              //  sp(2) is first age for which mean selex=1
              //  sp(3) is last age  for which mean selex=1
              //  sp(4) is male mean selex relative to female mean.
              //  -999 code means to keep the change unchanged from previous age (so keeps same rate of change)
              // -1000 code is only for males and sets the male change to be same as female change
              //  gg is the index for sex, where 1=female, 2=male
              sel_a(y,fs,gg).initialize();
              dvariable seldelta=0.0;  //  value is the change in log(selex)
              tempvec_a.initialize(); //  null value for vector
//              echoinput<<" sp "<<sp(1,N_selparmvec(f))<<endl;
              int first_age=int(value(sp(1)));
              tempvec_a(first_age)=0.0;   //  start value for random walk across ages
              int last_age=first_age+seltype(f,4);  //  because seltype(f,4) contains the number of changes
              if(gg==1) {scaling_offset=2+gender;} else {scaling_offset=2+gender+seltype(f,4);}  // to get male vs female starting point for parameters
//               echoinput<<first_age <<" "<< last_age <<" "<< scaling_offset<<endl;
              j=scaling_offset;
              for (a=first_age+1;a<=last_age;a++)
              {
                j++;
                //  with use of -999, lastsel stays constant until changed, so could create a linear change in ln(selex)
                if(sp(j)>-999.) {seldelta=sp(j);}  // so allows for seldelta to remain unchanged
                else if(gg==2 && sp(j)==-1000.)  //  more options for male selectivity
                  {seldelta=sp(j-seltype(f,4));}  //  use female delta for the male delta at this age
                tempvec_a(a)=tempvec_a(a-1)+seldelta;   // cumulative log(selex)
              }
              int low_bin  = int(value(sp(2)));
              int high_bin = int(value(sp(3)));
 #ifdef DO_ONCE
              if(do_once==1)  //  this should move to readcontrol!
              {
                if (low_bin < 0)
                {
                    low_bin = 0;
                    N_warn++;  warning<<N_warn<<" "<<" selex pattern 44; value for low bin is less than 0, so set to 0 "<<endl;
                }
                if (high_bin > nages)
                {
                    high_bin = nages;
                    N_warn++;  warning<<N_warn<<" "<<" selex pattern 44; value for high bin is greater than "<<nages<<", so set to "<<nages<<" "<<endl;
                }
                if (high_bin < low_bin) high_bin = low_bin;
                if (low_bin > high_bin) low_bin = high_bin;
                sp(2) = low_bin;
                sp(3) = high_bin;
              }
 #endif
              temp=mean(tempvec_a(low_bin,high_bin));
              sel_a(y,fs,gg)(first_age,last_age)=mfexp(tempvec_a(first_age,last_age)-temp);
              if(gg==2) sel_a(y,fs,gg)(first_age,last_age)*=mfexp(sp(4)); //  apply male ratio
              if (last_age<nages) {sel_a(y,fs,gg)(last_age+1,nages)=sel_a(y,fs,gg,last_age);}
              scaling_offset=0;
              break;
            }

              case 45:  //  like age selex 14 but with separate parameters for males and with revised controls
            {
              //  parameter value is logit(selectivity)
              //  peak selex in logit space is penalized towards value of 8.0, which gives selex near 1.0
              //  sp(1) is first age with non-zero selectivity; can be age 0
              //  seltype(f,4) is number of selectivity parameters beginning at age=first_age
              //  sp(2) is first age in mean for peak selex
              //  sp(3) is last age  in mean for peak selex
              //  sp(4) is male mean selex relative to female mean.
              //  -999 code means to keep the selex same as previous age
              // -1000 code is only for males and sets the male selex to be same as female selex
              //  gg is the index for sex, where 1=female, 2=male
              sel_a(y,fs,gg).initialize();
              tempvec_a.initialize(); //  null value for vector
              int first_age=int(value(sp(1)));
              int last_age=first_age+seltype(f,4)-1;  //  because seltype(f,4) contains the number of ages with selex parameter
              if(gg==1) {scaling_offset=2+gender;} else {scaling_offset=2+gender+seltype(f,4);}  // to get male vs female starting point for parameters
              j=scaling_offset;
              for (a=first_age;a<=last_age;a++)
              {
                j++;
                if(sp(j)>-999)
                  {tempvec_a(a) = sp(j);}
                else if(gg==2 && sp(j)==-1000.)  //  set male selectivity raw value same as female
                  {tempvec_a(a)=sp(j-seltype(f,4));}  //  use female parameter for males
                else  //  so value is -999 so set to next younger age
                {tempvec_a(a) = tempvec_a(a-1);}
          //     N_warn++; warning<<N_warn<<" "<<" sex "<<gg<<" a "<<a<<"  j "<<j<<"  sp "<<sp(j)<<" use "<<tempvec_a(a)<<endl;
              }
              int low_bin  = int(value(sp(2)));
              int high_bin = int(value(sp(3)));
 #ifdef DO_ONCE
              if(do_once==1)  //  this should move to readcontrol!
              {
                if (low_bin < 0)
                {
                    low_bin = 0;
                    N_warn++;  warning<<N_warn<<" "<<" selex pattern 44; value for low bin is less than 0, so set to 0 "<<endl;
                }
                if (high_bin > nages)
                {
                    high_bin = nages;
                    N_warn++;  warning<<N_warn<<" "<<" selex pattern 44; value for high bin is greater than "<<nages<<", so set to "<<nages<<" "<<endl;
                }
                if (high_bin < low_bin) high_bin = low_bin;
                if (low_bin > high_bin) low_bin = high_bin;
              }
 #endif
              temp=8.-mean(tempvec_a(low_bin,high_bin));
//              CrashPen+=temp*temp;
              sel_a(y,fs,gg)(first_age,last_age) = 1./(1.+mfexp(-(tempvec_a(first_age,last_age)+temp)));
              if(gg==2) {sel_a(y,fs,gg)(first_age,last_age)*=mfexp(sp(4));} //  apply male ratio
              if (last_age<nages) {sel_a(y,fs,gg)(last_age+1,nages)=sel_a(y,fs,gg,last_age);}
              scaling_offset=0;
              break;
            }

  //  SS_Label_Info_22.7.18 #age selectivity: double logistic with smooth transition
              case 18:                 // *******double logistic with smooth transition
                                       // 1=peak, 2=init,  3=infl,  4=slope, 5=final, 6=infl2, 7=slope2
            {
             sel_a(y,fs,1).initialize();
             t1=0.+(1./(1.+mfexp(-sp(3))))*(sp(1)-0.);    // INFL
             t1min=1./(1.+mfexp(-sp(4)*(0.-t1)))*0.9999;  // asc value at minsize
             t1max=1./(1.+mfexp(-sp(4)*(sp(1)-t1)))*1.00001;  // asc value at peak
             t1power=log(0.5)/log((0.5-t1min)/(t1max-t1min));

             t2=(sp(1)+sp(8))+(1./(1.+mfexp(-sp(6))))*(r_ages(nages)-(sp(1)+sp(8)));    // INFL
             t2min=1./(1.+mfexp(-sp(7)*(sp(1)+sp(8)-t2)))*0.9999;  // asc value at peak+
             t2max=1./(1.+mfexp(-sp(7)*(r_ages(nages)-t2)))*1.00001;  // asc value at maxage
             t2power=log(0.5)/log((0.5-t2min)/(t2max-t2min));
             final=1./(1.+mfexp(-sp(5)));
             for (a=Min_selage(fs); a<=nages; a++)  //calculate the value over ages
             {
              sel_a(y,fs,1,a) =
                (
                (
                (sp(2) + (1.-sp(2)) *
                 pow((( 1./(1.+mfexp(-sp(4)*(r_ages(a)-t1)))-t1min)/ (t1max-t1min)),t1power))
                /(1.0+mfexp(30.*(r_ages(a)-sp(1))))  // scale ascending side
                +
                1./(1.+mfexp(-30.*(r_ages(a)-sp(1))))   // flattop, with scaling
                )
                /(1.+mfexp( 30.*(r_ages(a)-(sp(1)+sp(8)))))    // scale combo of ascending and flattop
                +
                (1. + (final - 1.) *
                 pow(fabs((( 1./(1.+mfexp(-sp(7)*(r_ages(a)-t2))) -t2min ) / (t2max-t2min) )),t2power))
                /(1.+mfexp( -30.*(r_ages(a)-(sp(1)+sp(8)))))    // scale descending
                );
             }   // end age loop
             break;
            }    // end double logistic with smooth transition

  //  SS_Label_Info_22.7.19 #age selectivity: old double logistic
            case 19:
            {
              k1=int(value(sp(5)));
              sel_a(y,fs,1)(k1,nages) =   elem_prod((1./(1.+mfexp(-sp(2)*(r_ages(k1,nages)-sp(1)) ))),
                                                   (1.-1./(1.+mfexp(-sp(4)*(r_ages(k1,nages)-(sp(1)*sp(6)+sp(3))) ))) );
              sel_a(y,fs,1)(k1,nages) /=max(sel_a(y,fs,1)(k1,nages));
              if(k1>0) sel_a(y,fs,1)(0,k1-1)=1.0e-6;
              break;
            }

  //  SS_Label_Info_22.7.20 #age selectivity: double normal with plateau
            case 20:                 // *******double_normal_plateau
            {
              if(seltype(f,3)<3 || (gg==1 && seltype(f,3)==3) || (gg==2 && seltype(f,3)==4))
              {peak=sp(1); upselex=mfexp(sp(3)); downselex=mfexp(sp(4)); final=sp(6); Apical_Selex=1.0;}
              else
              {   // offset male parameters if seltype(f,3)==3
                peak=sp(1)+sp(Maleselparm(f));
                upselex=mfexp(sp(3)+sp(Maleselparm(f)+1));
                downselex=mfexp(sp(4)+sp(Maleselparm(f)+2));
                if(sp(6)>-999.) final=sp(6)+sp(Maleselparm(f)+3);
                Apical_Selex=sp(Maleselparm(f)+4);
              }
              if(sp(5)<-1000.)
              {
                j=-1001-int(value(sp(5)));      // selex is nil thru age j, so set sp(5) equal to first age with selex (e.g. -1002 to start selex at age 2)
                sel_a(y,fs,gg)(0,j)=1.0e-06;
              }
              else
              {
                j=Min_selage(fs)-1;                // start selex at Min_selage
                if(sp(5)>-999)
                {
                  point1=1./(1.+mfexp(-sp(5)));
                  t1min=mfexp(-(square(0.-peak)/upselex));  // fxn at first bin
                }
              }
              if(sp(6)<-1000.)
              {
                j2=-1000-int(value(sp(6))); // selex is constant beyond this age, so set sp(6) equal to last age with estimated selex
                                              //  (e.g. -1008 to be constant beyond age 8)
              }
              else
              {j2=nages;}

              peak2=peak+1.+(0.99*r_ages(j2)-peak-1.)/(1.+mfexp(-sp(2)));        // note, this uses age=j2 as constraint on range of "peak2"
//              peak2=peak+.1+(0.99*r_ages(j2)-peak-.1)/(1.+mfexp(-sp(2)));        // note, this uses age=j2 as constraint on range of "peak2"
              if(sp(6)>-999)
              {
                point2=1./(1.+mfexp(-final));
                t2min=mfexp(-(square(r_ages(nages)-peak2)/downselex));  // fxn at last bin
              }

              for (a=j+1;a<=j2;a++)
              {
                t1=r_ages(a)-peak;  t2=r_ages(a)-peak2;
                join1=1./(1.+mfexp(-(20./(1.+fabs(t1)))*t1));
                join2=1./(1.+mfexp(-(20./(1.+fabs(t2)))*t2));
                if(sp(5)>-999)
                  {asc=point1+(Apical_Selex-point1)*(mfexp(-square(t1)/upselex  )-t1min)/(1.-t1min);}
                else
                  {asc=Apical_Selex*mfexp(-square(t1)/upselex);}
                if(sp(6)>-999)
                  {dsc=Apical_Selex+(point2-Apical_Selex)*(mfexp(-square(t2)/downselex)-1.    )/(t2min-1.);}
                else
                  {dsc=Apical_Selex*mfexp(-square(t2)/downselex);}
                sel_a(y,fs,gg,a)=asc*(1.-join1)+join1*(Apical_Selex*(1.-join2)+dsc*join2);
              }
              if(j2<nages) {sel_a(y,fs,gg)(j2+1,nages)=sel_a(y,fs,gg,j2);}
              break;
            }

  //  SS_Label_Info_22.7.26 #age selectivity: exponential logistic
            case 26:
            {
//              peak = r_ages(0) + sp(2)*(r_ages(nages)-r_ages(0));
              sel_a(y,fs,1).initialize();
              peak = sp(2)*r_ages(nages);
              for (a=Min_selage(fs);a<=nages;a++)
                {sel_a(y,fs,1,a) = mfexp(sp(3)*sp(1)*(peak-r_ages(a)))/(1.0-sp(3)*(1.0-mfexp(sp(1)*(peak-r_ages(a)))));}
              break;
            }

  //  SS_Label_Info_22.7.27 #age selectivity: cubic spline
  // #42 cubic spline scaled by average of values at low age through high age
          case 42:
            scaling_offset = 2;
          case 27:
          {
  // define vectors which form the basis for cubic spline selectivity
  // IMPORTANT: these vectors might need to be expanded to fit values for multiple fleets
  dvector splineX(1,200);
  dvar_vector splineY(1,200);
  splineX.initialize();
  splineY.initialize();
            sel_a(y,fs,1).initialize();
            k=seltype(f,4);  // n points to include in cubic spline
            for (i=1;i<=k;i++)
            {
              splineX(i)=value(sp(i+3+scaling_offset)); // "value" required to avoid error, but values should be always fixed anyway
              splineY(i)=sp(i+3+k+scaling_offset);
            }
            z=nages;
            while(r_ages(z)>splineX(k)) {z--;}
            j2=z+1;  //  first age beyond last node
            vcubic_spline_function splinefn=vcubic_spline_function(splineX(1,k),splineY(1,k),sp(2+scaling_offset),sp(3+scaling_offset));
            tempvec_a= splinefn(r_ages);  // interpolate selectivity at each age
            if (scaling_offset == 0)
            {
                temp=max(tempvec_a(0,j2));
            }
            else
            {
                int low_bin  = int(value(sp(1)));
                int high_bin = int(value(sp(2)));
                if (low_bin < Min_selage(fs))
                {
                    low_bin = Min_selage(fs);
                    N_warn++;  warning<<N_warn<<" "<<" selex pattern 42; value for low bin is less than min_selage, so set to "<<Min_selage(fs)<<endl;
                }
                if (high_bin > nages)
                {
                    high_bin = nages;
                    N_warn++;  warning<<N_warn<<" "<<" selex pattern 42; value for high bin is greater than "<<nages<<", so set to "<<nages<<" "<<endl;
                }
                if (high_bin < low_bin) high_bin = low_bin;
                if (low_bin > high_bin) low_bin = high_bin;
                sp(1) = low_bin;
                sp(2) = high_bin;
                temp=mean(tempvec_a(low_bin,high_bin));
                scaling_offset = 0;     // reset scaling offset
            }
            tempvec_a-=temp;  // rescale to get max of 0.0
            tempvec_a(j2+1,nages) = tempvec_a(j2);  //  set constant above last node
            sel_a(y,fs,1)(Min_selage(fs),nages)=mfexp(tempvec_a)(Min_selage(fs),nages);
            break;
          }

          default:   //  seltype not found.  But really need this check earlier when the N selex parameters are being processed.
          {
            N_warn++; cout<<"Critical error, see warning"<<endl;  warning<<N_warn<<" "<<"Age_selex option not valid "<<seltype(f,1)<<endl; exit(1);
            break;
          }

            }  // end last age selex pattern
          }  // end direct calc of selex from parameters

  //  SS_Label_Info_22.8 #age selectivity: one sex selex as offset from other sex
          if(gg==2)         // males exist
          {
            if(seltype(f,3)==1 || seltype(f,3)==2)   // do gender selex as offset
            {
              k=Maleselparm(f);   // first male parm
              temp=sp(k)-0.00001;
              temp1=1.;
              switch(seltype(f,3))
              {
                case 1:
                {                       // do males relative to females
                  for (a=Min_selage(fs);a<=nages;a++)   //
                  {
                    if(r_ages(a)<=temp)
                    {sel_a(y,fs,2,a)=sel_a(y,fs,1,a)*mfexp(sp(k+1)+(r_ages(a)-0.)   /(temp-0.)   * (sp(k+2)-sp(k+1)) );}
                    else
                    {sel_a(y,fs,2,a)=sel_a(y,fs,1,a)*mfexp(sp(k+2)+(r_ages(a)-temp) /(double(nages)-temp) * (sp(k+3)-sp(k+2)) );}
      //              if(sel_a(y,fs,2,a)>temp1) temp1=sel_a(y,fs,2,a);
                  }
                  tempvec_a(1)=max(sel_a(y,fs,1));
                  tempvec_a(2)=max(sel_a(y,fs,2));
                  temp1=max(tempvec_a(1,2));
                  sel_a(y,fs)/=temp1;
                  break;
                }
                case 2:
                {                   //  do females relative to males
                  sel_a(y,fs,2)=sel_a(y,fs,1);
                  for (a=Min_selage(fs);a<=nages;a++)   //
                  {
                    if(r_ages(a)<=temp)
                      {sel_a(y,fs,1,a)=sel_a(y,fs,2,a)*mfexp(sp(k+1)+(r_ages(a)-0.)   /(temp-0.)   * (sp(k+2)-sp(k+1)) );}
                    else
                      {sel_a(y,fs,1,a)=sel_a(y,fs,2,a)*mfexp(sp(k+2)+(r_ages(a)-temp) /(double(nages)-temp) * (sp(k+3)-sp(k+2)) );}
      //              if(sel_a(y,fs,1,a)>temp1) temp1=sel_a(y,fs,1,a);
                  }
      //            sel_a(y,fs)/=temp1;
                  tempvec_a(1)=max(sel_a(y,fs,1));
                  tempvec_a(2)=max(sel_a(y,fs,2));
                  temp1=max(tempvec_a(1,2));
                  sel_a(y,fs)/=temp1;

                  break;
                }
              }
            }
            else if(seltype(f,3)!=3 && seltype(f,3)!=4 &&seltype(f,1)!=15 && seltype(f,1)!=44 && seltype(f,1)!=45)
            {sel_a(y,fs,2)=sel_a(y,fs,1);}   // set males = females
            if(docheckup==1) echoinput<<" sel-age "<<sel_a(y,fs)<<endl;
          }
        }  //  end gender loop

//  apply 2D_AR adjustment to sex-specific age selectivity
//  TwoD_AR_def: read:  1-fleet, 2-ymin, 3-ymax, 4-amin, 5-amax, 6-sigma_amax, 7-use_rho, 8-age/len, 9-dev_phase; 10-before_yrs, 11=after_yrs, 
//  calc quantities:  12-N_parm_dev, 13-selparm_location

    if(TwoD_AR_use(f)>0)
    {
      j=TwoD_AR_use(f);  //  get index for this fleet's effect
      if(TwoD_AR_def[j](8)==2)  //  age (2) vs length (1) flag
      {
        z=TwoD_AR_def[j](12);  // index of dev vector used
        if(docheckup==1) echoinput<<"age-based 2DAR for fleet: "<<f<<" 2DAR: "<<j<<" using dev_vector: "<<z<<endl;

        if(y==styr && (TwoD_AR_before(j)==3 || TwoD_AR_after(j)==3) )  //  if needed, calculate average dev for each age over the range of years
        {
          TwoD_AR_ave(j).initialize();
          for(int yyy=TwoD_AR_ymin(j); yyy<=TwoD_AR_ymax(j); yyy++)
          {
            k=(yyy-TwoD_AR_ymin(j))*(TwoD_AR_amax(j)-TwoD_AR_amin(j)+1);  //  index of 1st dev in vector created from year and age index
            for(int ll=TwoD_AR_amin(j);ll<=TwoD_AR_amax(j);ll++)
            {
              k++;
              TwoD_AR_ave(j,ll)+=parm_dev(z,k);   //  sum devs for each age
            }
          }
          TwoD_AR_ave(j)/=(TwoD_AR_ymax(j)-TwoD_AR_ymin(j)+1.0);
 #ifdef DO_ONCE
          if(do_once==1) echoinput<<"mean 2D AR dev for fleet: "<<f<<" means: "<<TwoD_AR_ave(j)<<endl;
 #endif
        }

        if(y<TwoD_AR_ymin(j))  //  early years
        {
          if(TwoD_AR_before(j)==0)  //  apply no devs
          {k=-2;}
          else if(TwoD_AR_before(j)==1)   //  use first year devs
          {
//          k=(TwoD_AR_ymin(j)-TwoD_AR_ymin(j))*(TwoD_AR_amax(j)-TwoD_AR_amin(j)+1);  //  index of 1st dev in vector created from year and age index
            k=0;
          }
          else if(TwoD_AR_before(j)==3)   //  use mean age-specific devs
          {k=-1;}
        }
        else if(y<=TwoD_AR_ymax(j))  //  in year range for annual devs
        {
          k=(y-TwoD_AR_ymin(j))*(TwoD_AR_amax(j)-TwoD_AR_amin(j)+1);  //  index of 1st dev in vector created from year and age index
        }
        else  //  later years
        {
          if(TwoD_AR_after(j)==0)  //  apply no devs
          {k=-2;}
          else if(TwoD_AR_after(j)==1)   //  use last year devs
          {k=(TwoD_AR_ymax(j)-TwoD_AR_ymin(j))*(TwoD_AR_amax(j)-TwoD_AR_amin(j)+1);}  //  index of 1st dev in vector created from year and age index
          else if(TwoD_AR_after(j)==3)   //  use mean length-specific devs
          {k=-1;}
        }

        if(docheckup==1) echoinput<<"K value for first dev to use: "<<k<<endl;
        if(k>-2)
        {
          a1=TwoD_AR_def[j](13)-1;  //  parameter number-1  for sigmasel
          dvariable sigmasel;
          for(a=TwoD_AR_amin(j);a<=TwoD_AR_amax(j);a++)  // loop lengths, using "a" as index
          {
            if(a<=TwoD_AR_def[j](6))  // so get sigmasel for this length bin
            {
              a1++;
              sigmasel=selparm(a1);
            }
            if(k>=0)
            {
              k++; 
              if(docheckup==1) echoinput<<a<<"  sigmasel: "<<sigmasel<<endl;
              sel_a(y,fs,1,a)*=mfexp(sigmasel*parm_dev(z,k));
              if(gender==2) sel_a(y,fs,2,a)*=mfexp(sigmasel*parm_dev(z,k));
            }
            else  //  use mean devs
            {
              sel_a(y,fs,1,a)*=mfexp(sigmasel*TwoD_AR_ave(j,a));
              if(gender==2) sel_a(y,fs,2,a)*=mfexp(sigmasel*TwoD_AR_ave(j,a));
            }
          }
        }
        if(docheckup==1) echoinput<<"age selex after 2D_AR"<<endl<<sel_a(y,fs)<<endl;
      }
    }

        {  //  calculation of age retention and discard mortality here
  //  SS_Label_Info_22.5.1 #Calculate age-specific retention and discmort
  // discmort_a is the fraction of discarded fish that die
  //  discmort2_a is fraction that die from being retained or are dead discard
  //   = elem_prod(sel_a,(retain_a + (1-retain_a)*discmort_a)) */
      if(seltype(f,2)==0)  //  no discard, all retained
      {
        retain_a(y,fs)=1.0;
        sel_a_r(y,fs)=sel_a(y,fs);
        discmort_a(y,fs)=1.0;
        discmort2_a(y,fs)=sel_a(y,fs);
      }
      else if(seltype(f,2)==3)  // none retained; all dead
      {
        retain_a(y,fs)=0.0;
        discmort_a(y,fs)=1.0;
        sel_a_r(y,fs)=0.0;
        discmort2_a(y,fs)=sel_a(y,fs);
      }
      else
      {
        if(seltype(f,2)<0)  // mirror
        {
          k=-seltype(f,2);
          retain_a(y,fs)=retain_a(y,k);
          discmort_a(y,fs)=discmort_a(y,k);
          if(seltype(k,2)==1)
          {
            discmort2_a(y,fs)=sel_a(y,fs);  //  all selected fish are dead;  this statement does both genders implicitly
          }
          else
          {
            discmort2_a(y,fs,1)=elem_prod(sel_a(y,fs,1), retain_a(y,fs,1) + elem_prod((1.-retain_a(y,fs,1)),discmort_a(y,fs,1)) );
            if(gender==2) discmort2_a(y,fs,2)=elem_prod(sel_a(y,fs,2), retain_a(y,fs,2) + elem_prod((1.-retain_a(y,fs,2)),discmort_a(y,fs,2)) );
          }
        }
        else
        {
          k=RetainParm(fs);
          if(sp(k+2)==-999.)
            {temp1=0.0;}
          else if (sp(k+2)==999.)
            {temp1=1.0;}
          else
            {temp1=1.0/(1.0+mfexp(-sp(k+2)));}

//          temp=1.-sp(k+2);
//          temp1=1.-posfun(temp,0.0,CrashPen);

          retain_a(y,fs,1)=temp1/(1.+mfexp(-(r_ages-(sp(k)))/sp(k+1)));
          if(seltype(f,2)==4)
          {
            // allow for dome-shaped retention in 3.30 only
            retain_a(y,fs,1)=elem_prod(retain_a(y,fs,1),(1.-(1./(1.+mfexp(-(r_ages-(sp(k+4)))/sp(k+5))))));
          }
          if(gender==2)
          {
            // males
            retain_a(y,fs,2)=temp1/(1.+mfexp(-(r_ages-(sp(k)+sp(k+3)))/sp(k+1)));
            if(seltype(f,2)==4)
            {
                retain_a(y,fs,2)=elem_prod(retain_a(y,fs,2),(1.-(1./(1.+mfexp(-(r_ages-(sp(k+4)+sp(k+6)))/sp(k+5))))));
            }
          }
          if(docheckup==1&&y==styr)
          {
            echoinput<<"age_retention parms: inflec: "<<sp(k)<<" width: "<<sp(k+1)<<" male_offset: "<<sp(k+3)<<" asymptote: "<<temp1;
            if(seltype(f,2)==4)
            {
                echoinput<<" "<<sp(k+4)<<" "<<sp(k+5)<<" "<<sp(k+6);
            }
            echoinput<<endl<<"ages "<<r_ages<<endl;
            echoinput<<"retention "<<retain_a(y,fs)<<endl;
          }

          if(seltype(f,2)==1)  // all discards are dead
          {
            discmort_a(y,fs)=1.0;
            discmort2_a(y,fs)=sel_a(y,fs);  //  all selected fish are dead;
          }
          else
          {
            k+=N_ret_parm(seltype(f,2));  // first discard mortality parm
            temp=1.-sp(k+2);
            temp1=posfun(temp,0.0,CrashPen);
            discmort_a(y,fs,1)=(1.-temp1/(1+mfexp(-(r_ages-(sp(k)))/sp(k+1))));
            if(gender==2)
            {
                // males
                discmort_a(y,fs,2)=(1.-temp1/(1+mfexp(-(r_ages-(sp(k)+sp(k+3)))/sp(k+1))));
            }
            if(docheckup==1&&y==styr) echoinput<<"discmort "<<discmort_a(y,fs)<<endl;
            discmort2_a(y,fs,1)=elem_prod(sel_a(y,fs,1), retain_a(y,fs,1) + elem_prod((1.-retain_a(y,fs,1)),discmort_a(y,fs,1) ));
            if(gender==2) discmort2_a(y,fs,2)=elem_prod(sel_a(y,fs,2), retain_a(y,fs,2) + elem_prod((1.-retain_a(y,fs,2)),discmort_a(y,fs,2) ));
          }
        }

        sel_a_r(y,fs,1)=elem_prod(sel_a(y,fs,1),retain_a(y,fs,1));
        if(gender==2)
        {
          sel_a_r(y,fs,2)=elem_prod(sel_a(y,fs,2),retain_a(y,fs,2));
        }
      }
      if(docheckup==1&&y==styr) echoinput<<"sel-age-ret "<<sel_a_r(y,fs)<<endl;
      if(docheckup==1&&y==styr) echoinput<<" dead "<<discmort2_a(y,fs)<<endl;
//  end age discard
        }
      }  // end calc of age selex
    }  //  end recalc of selex

    else
  //  SS_Label_Info_22.9 #Carryover selex from last year because not time-varying
    {
      if(f<=Nfleet)
      {
        sel_l(y,f)=sel_l(y-1,f);   // this does both genders
        sel_l_r(y,f)=sel_l_r(y-1,f);
        retain(y,f)=retain(y-1,f);
        discmort(y,f)=discmort(y-1,f);
        discmort2(y,f)=discmort2(y-1,f);
      }
      else  // age
      {
        sel_a(y,fs)=sel_a(y-1,fs);  // does both genders
        retain_a(y,fs)=retain_a(y-1,fs);
      }
    }

    Ip+=N_selparmvec(f);

  }  //  end fleet loop for selectivity
  }  //  end selectivity FUNCTION

FUNCTION void Make_FishSelex()
  {
//  Similar to Make_Fecundity, this function does the dot product of length distribution with length selectivity and retention vectors
//  to calculate equivalent mean quantities at age for each platoon (g)
//********************************************************************
 /*  SS_Label_FUNCTION 32 Make_FishSelex */
//  where:
//  4darray fish_body_wt(styr-3*nseas,k,1,gmorph,1,Nfleet,0,nages);  // wt (adjusted for size selex)
//  4darray sel_al_1(1,nseas,1,gmorph,1,Nfleet,0,nages);  // selected * wt
//  4darray sel_al_2(1,nseas,1,gmorph,1,Nfleet,0,nages);  // selected * retained * wt
//  4darray sel_al_3(1,nseas,1,gmorph,1,Nfleet,0,nages);  // selected numbers
//  4darray sel_al_4(1,nseas,1,gmorph,1,Nfleet,0,nages);  // selected * retained numbers
//  4darray deadfish(1,nseas,1,gmorph,1,Nfleet,0,nages);  // sel * (retain + (1-retain)*discmort)
//  4darray deadfish_B(1,nseas,1,gmorph,1,Nfleet,0,nages);  // sel * (retain + (1-retain)*discmort) * wt

    ALK_idx=(s-1)*N_subseas+mid_subseas;  //for midseason
    int ALK_finder=(ALK_idx-1)*gmorph+g;
    dvar_matrix ALK_w=ALK(ALK_idx,g);        //  shallow copy
    ivector ALK_range_lo=ALK_range_g_lo(ALK_finder);
    ivector ALK_range_hi=ALK_range_g_hi(ALK_finder);
    dvar_vector sel_l_r_w(1,nlength);   //  temp vector for retained contribution to weight-at-age
    dvar_vector disc_wt(1,nlength);
    int yf;
    int tz;
    gg=sx(g);
//    if(y>endyr) {yz=endyr; } else {yz=y;}  //  not used
    if(y>endyr+1 && Fcast_Specify_Selex==0) {yf=endyr+1;} else {yf=y;}    //  yf stores in endyr+1 the average selex from a range of years if Fcast_Specify_Selex==0
    tz=styr+(y-styr)*nseas+s-1;  // can use y, not yf, because wtage_emp values are read in and can extend into forecast
    for (f=1;f<=Nfleet;f++)
    {
      if(timevary_sel(yf,f)>0 || timevary_sel(yf,f+Nfleet)>0 || WTage_rd==1 || save_for_report>0)
      {
        makefishsel_yr = yf;
        if (WTage_rd==1 || (seltype(f,1)==0 && seltype(f,2)==0) )  //  empirical wt-at-age or no size-selectivity; so no size-based calculations
        {
          if(WTage_rd==1)
          {
            sel_al_1(s,g,f)=elem_prod(sel_a(yf,f,gg),WTage_emp(tz,GP3(g),f));   // selected wt-at-age
            fish_body_wt(tz,g,f)=WTage_emp(tz,GP3(g),f);
          }
          else
          {
            sel_al_1(s,g,f)=elem_prod(sel_a(yf,f,gg),Wt_Age_mid(s,g));   // selected wt-at-age
            fish_body_wt(tz,g,f)=Wt_Age_mid(s,g);
          }
          sel_al_3(s,g,f)=sel_a(yf,f,gg);  //  selected numbers
          switch(seltype(f+Nfleet,2))  //  age-retention function
          {
            case 0:
            {
              sel_al_2(s,g,f)=sel_al_1(s,g,f);  //  retained wt-at-age
              sel_al_4(s,g,f)=sel_al_3(s,g,f);  //  retained numbers
              deadfish_B(s,g,f)=sel_al_1(s,g,f);  //  dead wt
              deadfish(s,g,f)=sel_al_3(s,g,f);  //  dead numbers
              break;
            }
            case 1:
            {
              sel_al_2(s,g,f)=elem_prod(sel_al_1(s,g,f),retain_a(y,f,gg));  //  retained wt-at-age
              sel_al_4(s,g,f)=elem_prod(sel_al_3(s,g,f),retain_a(y,f,gg));  //  retained numbers
              deadfish_B(s,g,f)=sel_al_2(s,g,f);  //  dead wt
              deadfish(s,g,f)=sel_al_4(s,g,f);  //  dead numbers
              break;
            }
            case 2:
            {
              sel_al_2(s,g,f)=elem_prod(sel_al_1(s,g,f),retain_a(y,f,gg));  //  retained wt-at-age
              sel_al_4(s,g,f)=elem_prod(sel_al_3(s,g,f),retain_a(y,f,gg));  //  retained numbers
              deadfish_B(s,g,f)=elem_prod(sel_al_2(s,g,f),discmort_a(y,f,gg));  //  dead wt
              deadfish(s,g,f)=elem_prod(sel_al_4(s,g,f),discmort_a(y,f,gg));  //  dead numbers
              break;
            }
            case 3:  //  all selected fish are dead
            {
              sel_al_2(s,g,f)=0.0;  //  retained wt-at-age
              sel_al_4(s,g,f)=0.0;  //  retained numbers
              deadfish_B(s,g,f)=sel_al_1(s,g,f);  //  dead wt
              deadfish(s,g,f)=sel_al_3(s,g,f);  //  dead numbers
              break;
            }
          }
        }

        else  //  size_selectivity and possible size retention
        {
          tempvec_l=elem_prod(sel_l(yf,f,gg),wt_len(s,GP(g)));  //  combine size selex and wt_at_len to get selected contribution to weight-at-age
          if(seltype(f,2)!=0) sel_l_r_w=elem_prod(sel_l_r(yf,f,gg),wt_len(s,GP(g)));
          if(seltype(f,2)>=2) disc_wt=elem_prod(discmort2(yf,f,gg),wt_len(s,GP(g)));
          for(a=0;a<=nages;a++)
          {
            int llo=ALK_range_lo(a);
            int lhi=ALK_range_hi(a);
            sel_al_1(s,g,f,a)=sel_a(yf,f,gg,a)*(ALK_w(a)(llo,lhi) * tempvec_l(llo,lhi));
            sel_al_3(s,g,f,a)=sel_a(yf,f,gg,a)*(ALK_w(a)(llo,lhi) * sel_l(yf,f,gg)(llo,lhi));
            fish_body_wt(tz,g,f,a)=(ALK_w(a)(llo,lhi)*tempvec_l(llo,lhi)) / (ALK_w(a)(llo,lhi)*sel_l(yf,f,gg)(llo,lhi));
            if(seltype(f,2)!=0)  //  size discard, so need retention function
            {
              sel_al_2(s,g,f,a)=sel_a(yf,f,gg,a)*(ALK_w(a)(llo,lhi) * sel_l_r_w(llo,lhi) );
              sel_al_4(s,g,f,a)=sel_a(yf,f,gg,a)* (ALK_w(a)(llo,lhi) * sel_l_r(yf,f,gg)(llo,lhi) );
            }
            else if (a==nages)
            {
              sel_al_2(s,g,f)=sel_al_1(s,g,f);
              sel_al_4(s,g,f)=sel_al_3(s,g,f);
            }

            if(seltype(f,2)>=2)  //  calc discard mortality
            {
              deadfish(s,g,f,a)=sel_a(yf,f,gg,a)*(ALK_w(a)(llo,lhi) * discmort2(yf,f,gg)(llo,lhi));  //  selected dead by numbers
              deadfish_B(s,g,f,a)=sel_a(yf,f,gg,a)*(ALK_w(a)(llo,lhi) * disc_wt(llo,lhi)); // selected dead by weight
            }
            else if(a==nages)
            {
              deadfish_B(s,g,f)=sel_al_1(s,g,f);
              deadfish(s,g,f)=sel_al_3(s,g,f);
            }

          }  //  end age loop
        }
        if(write_bodywt>0 && ishadow(GP2(g))==0)
          {
            if(sum(fish_body_wt(tz,g,f))>0.00001)
            {
              bodywtout<<y<<" "<<s<<" "<<gg<<" "<<GP4(g)<<" "<<Bseas(g)
              <<" "<<f<<" "<<fish_body_wt(tz,g,f)<<" #wt_flt_"<<f<<endl;
            }
            else
            {
              bodywtout<<y<<" "<<s<<" "<<gg<<" "<<GP4(g)<<" "<<Bseas(g)
              <<" "<<f<<" "<<Wt_Age_mid(s,g)<<" #wt_flt_"<<f<<endl;
            }

          }
      }  // end need to do it
      save_sel_fec(t,g,f)= sel_al_3(s,g,f);  //  save sel_al_3 in save_fecundity array for output

    }  // end fleet loop for mortality, retention
  }  // end Make_FishSelex
