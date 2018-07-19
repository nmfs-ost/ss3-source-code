//  SS_Label_Section_8 #RUNTIME_SECTION (not used in SS)
RUNTIME_SECTION
//  {
//  maximum_function_evaluations 200, 200, 200, 200, 200, 200, 200, 2000;
//  convergence_criteria 100, 10, 1, 0.1, 1e-4, 1e-4, 1e-4, 1e-4;
//  }

//  SS_Label_Section_9 #TOP_OF_MAIN_SECTION
TOP_OF_MAIN_SECTION
//  {
//  SS_Label_Info_9.1 #Set array and gradient structure space
  arrmblsize = 200000000; // 2e8 = about 0.2 GB.
//  gradient_structure::set_GRADSTACK_BUFFER_SIZE(672647168);
  gradient_structure::set_GRADSTACK_BUFFER_SIZE(20000000); // 2e7 gets multiplied by the gradstack size (usually 48), to reach about 0.9 GB.
  //  gradstack is not allocated unless needed by the model, but arrmblsize and cmpdif are allocated immediately
//  gradient_structure::set_CMPDIF_BUFFER_SIZE(500000000);
  gradient_structure::set_CMPDIF_BUFFER_SIZE(200000000); // 2e8 = about 0.2GB
  gradient_structure::set_MAX_NVAR_OFFSET(5000);
  gradient_structure::set_NUM_DEPENDENT_VARIABLES(10000);
  gradient_structure::set_MAX_DLINKS(10000000);

//  SS_Label_Info_9.2 #Set clock start time
  time(&start); //this is to see how long it takes to run
//  }

//  SS_Label_Section_10. #GLOBALS_SECTION
GLOBALS_SECTION
//  {
  #include <admodel.h>
  #include <time.h>
  #include <fvar.hpp>
  #include <vector>
  #include <iostream>
  time_t start,finish;
  long hour,minute,second;
  double elapsed_time;

//  SS_Label_Info_10.1 #Open output files using ofstream
  ofstream warning("warning.sso");
  ofstream echoinput("echoinput.sso");
  ofstream ParmTrace("ParmTrace.sso");
  ofstream report5("Forecast-report.sso");
  ofstream report2("CumReport.sso",ios::app);
  ofstream bodywtout("wtatage.ss_new");
  ofstream SS2out;   // this is just a create

//  SS_Label_Info_10.2 #Define some adstring variables
  adstring_array ParmLabel;  // extendable array to hold the parameter labels
  adstring_array Parm_info;  // extendable array to hold the parameter labels
  adstring_array SzFreq_units_label;
  adstring_array SzFreq_scale_label;
  adstring_array fleetname;
  adstring fleetnameread;
  adstring depletion_basis_label;
  adstring F_report_label;
  adstring SPR_report_label;
  adstring onenum(4);
  adstring anystring;
  adstring anystring2;
  adstring_array version_info;
  adstring version_info2;
  adstring version_info3;
  adstring version_info_short;
  adstring_array Starter_Comments;
  adstring_array Data_Comments;
  adstring_array Control_Comments;
  adstring_array Forecast_Comments;
  adstring_array NumLbl;
  adstring_array GenderLbl;   // gender label
  adstring_array GP_Lbl;   // gender label
  adstring_array CRLF;   // blank to terminate lines

//  declare some entities that need global access
  int ParCount; int timevary_parm_cnt; int N_warn;
  int styr; int endyr; int YrMax; int nseas; int Ncycle;

//  SS_Label_Info_10.3  #start random number generator with seed based on time
  random_number_generator radm(long(time(&start)));

  std::vector<int> Parm_minmax;
  std::vector<dvector> catch_read;
  std::vector<dvector> Svy_data;
  std::vector<dvector> discdata;
  std::vector<dvector> mnwtdata1;
  std::vector<dvector> lendata;
  std::vector<dvector> Age_Data;
  std::vector<dvector> sizeAge_Data;
  std::vector<dvector> Fcast_InputCatch_list;
  std::vector<dvector> Fcast_Catch_Allocation_list;
  std::vector<dvector> env_temp;
  std::vector<dvector> WTage_in;
  std::vector<dvector> var_adjust_data;
  std::vector<dvector> lambda_change_data;
  std::vector<dvector> timevary_parm_rd;
  std::vector<ivector> timevary_def;
  std::vector<ivector> TwoD_AR_def;

//  function in GLOBALS to do the timing setup in the data section
  void get_data_timing(const dvector& to_process, const ivector& timing_constants, ivector i_result, dvector r_result, const dvector& seasdur, const dvector& subseasdur_delta, const dvector& azero_seas, const dvector& surveytime)
  {

    // r_result(1,3) will contain: real_month, data_timing_seas, data_timing_yr,
    // i_result(1,6) will contain y, t, s, f, ALK_time, use_midseas
    int f,s,subseas,y;
    double temp, temp1, month, data_timing_seas, data_timing_yr;
//  timing_constants(1)=read_seas_mo;
//  timing_constants(2)=nseas;
//  timing_constants(3)=N_subseas;
//  timing_constants(4)=mid_subseas;
//  timing_constants(5)=styr;
//  timing_constants(6)-endyr;

    y=int(to_process(1));
    month=abs(to_process(2));
    f=abs(int(to_process(3)));

    if(timing_constants(1)==1)  // reading season
    {
      s=int(month);
      subseas=timing_constants(4);  //  mid subseas
      if(surveytime(f)>=0.)
      {  //  fraction of season
        data_timing_seas=surveytime(f);
        i_result(6)=1;
      }
      else
      {  //  for fishing fleets;  use midseason and fishery catch
        data_timing_seas=0.5;
        i_result(6)=-1;  //  flag to use season-long fishery catch as the sample
      }
      month=1.0 + azero_seas(s)*12. + 12.*data_timing_seas*seasdur(s);
    }
    else  //  reading month.fraction
    {
      if(surveytime(f)<0)  //  so a fishing fleet
      {
        if(month>999)
        {  // override to allow a fishing fleet to have explicit timing
          month-=1000.;
          i_result(6)=1;
        }
        else
        {
          i_result(6)=-1;  //  flag to use season-long fishery catch as the sample
        }
      }
      else
      {
        i_result(6)=1;  //  explicit timing for all survey fleet obs
        if(month>999)
        {  // override to allow a fishing fleet to have explicit timing
          month-=1000.;
        }
      }
      temp1=max(0.00001,(month-1.0)/12.);  //  month as fraction of year
      s=1;  // earlist possible seas;
      subseas=1;  //  earliest possible subseas in seas
      temp=subseasdur_delta(s);  //  starting value
      while(temp<=temp1+1.0e-9)
      {
        if(subseas==timing_constants(3))
        {s++; subseas=1;}
        else
        {subseas++;}
        temp+=subseasdur_delta(s);
      }
      data_timing_seas=(temp1-azero_seas(s))/seasdur(s);  //  remainder converted to fraction of season (and multiplied by seasdur when used)
    }

    // i_result(1,6) will contain y, t, s, f, ALK_time, use_midseas
//    t=styr+(y-styr)*nseas+s-1;
//    ALK_time=(yr-styr)*nseas*N_subseas+(s-1)*N_subseas+subseas;
    i_result(1)=y;
    i_result(2)=timing_constants(5)+(y-timing_constants(5))*timing_constants(2)+s-1;  //  t
    i_result(3)=s;
    i_result(4)=f;
    
    if(i_result(6)>=0)
    {
      i_result(5)=(y-timing_constants(5))*timing_constants(2)*timing_constants(3)+(s-1)*timing_constants(3)+subseas;  //  ALK_time
      // r_result(1,3) : real_month, data_timing_seas, data_timing_yr,
      r_result(1)=month;
      r_result(2)=data_timing_seas*i_result(6);
      r_result(3)=float(y)+(month-1.)/12.;  //  year.fraction
    }
    else  //  assign to midseason
    {
      i_result(5)=(y-timing_constants(5))*timing_constants(2)*timing_constants(3)+(s-1)*timing_constants(3)+timing_constants(4);  //  ALK_time
      data_timing_seas=0.5;
      month=1.0 + azero_seas(s)*12. + 12.*data_timing_seas*seasdur(s);
      r_result(1)=month;
      r_result(2)=data_timing_seas*i_result(6);
      r_result(3)=float(y)+(month-1.)/12.;  //  year.fraction
    }
    return;
  }

//  global routine to count the number of records before reaching an end condition
  int count_records(int N_fields)  //  function definition
  {
    int N_records;
    dvector tempvec(1,N_fields);  //  vector used for temporary reads
    echoinput<<" read list until -9999"<<endl;
    N_records=0;
    tempvec.initialize();
    do {
      N_records++;
      *(ad_comm::global_datafile) >> tempvec;
        echoinput<<N_records<<" A "<<tempvec<<endl;
    } while(tempvec(1)!=-9999.);
    echoinput<<" number of records = "<<N_records<<endl;
    return N_records;
  }

//  global function to create timevary parameters
  void create_timevary(dvector &baseparm_list, ivector &timevary_setup,
                       ivector &timevary_byyear, const int &autogen_timevary, const int &targettype,
                       const ivector &block_design_pass, const int &parm_adjust_method,
                       const dvector &env_data_pass, int &N_parm_dev, const double& finish_starter)
  {
//  where timevary_byyear is a selected column of a year x type matrix (e.g. timevary_MG) in read_control
    echoinput<<"baseparm: "<<baseparm_list<<endl;
    int j; int g; int y; int a; int f;
    int k;
    int z;
    int Nblocks;
    j=timevary_setup(13);  //  index of base in all parameters to get correct baseparm label
    if(baseparm_list(13)!=0)    //  blocks or trends
    {
      z=baseparm_list(13);    // specified block or trend definition
      timevary_setup(4)=z; //  block or trend type
      timevary_setup(5)=baseparm_list(14); //  block pattern
      if (z>0)  //  blocks with z as the block pattern
      {
        Nblocks=0.5*(block_design_pass.size());
//        if(z>N_Block_Designs) {N_warn++; warning<<"parm: "<<j<<" ERROR, Block > N Blocks "<<z<<" "<<N_Block_Designs<<endl; exit(1);}
        k=int(baseparm_list(14));  //  block method
        echoinput<<"block pattern: "<<z<<" method "<<k<<" Nblocks: "<<Nblocks<<endl;

        g=1;  //  index to list of years in block design; will increment by 2 for begin-end of block
        for (a=1;a<=Nblocks;a++)  //  loop blocks for block pattern z
        {
         timevary_parm_cnt++;
         ParCount++;
         echoinput<<" create parm for block "<<a<<endl;
         y=block_design_pass(g);
         timevary_byyear(y)=1;
         sprintf(onenum, "%d", y);

         switch(k)
         {
           case 0:
           {ParmLabel+=ParmLabel(j)+"_BLK"+NumLbl(z)+"mult_"+onenum+CRLF(1);
            dvector tempvec(1,7);  //  temporary vector for a time-vary parameter  LO HI INIT PRIOR PR_type SD PHASE
            tempvec.initialize();
            if(autogen_timevary>=1)  //  read
            {*(ad_comm::global_datafile) >> tempvec(1,7);}
            if(autogen_timevary==0 || autogen_timevary==2 || (autogen_timevary==3 && tempvec(1)==-12345))  //  create or overwrite
            {
              tempvec.fill("{0,0,0.,0.,0,6,4}");
              if(baseparm_list(1)<=0.0) 
              {N_warn++; warning<<" cannot use multiplicative blocks for parameter with a negative lower bound;  exit "<<endl<<
            baseparm_list(1)<<" "<<baseparm_list(2)<<" "<<baseparm_list(3)<<endl;  cout<<"exit, see warning"<<endl; exit(1);}
              tempvec(1)=log(baseparm_list(1)/baseparm_list(3));  //  max negative change
              tempvec(2)=log(baseparm_list(2)/baseparm_list(3));   //  max positive change
              tempvec(5)=0.5*fmin(abs(tempvec(1)),tempvec(2));   //  sd of normal prior
            }
            timevary_parm_rd.push_back (tempvec);
            break;}
           case 1:
           {ParmLabel+=ParmLabel(j)+"_BLK"+NumLbl(z)+"add_"+onenum+CRLF(1);
            dvector tempvec(1,7);  //  temporary vector for a time-vary parameter  LO HI INIT PRIOR PR_type SD PHASE
            tempvec.initialize();
            if(autogen_timevary>=1)  //  read
            {*(ad_comm::global_datafile) >> tempvec(1,7);}
            if(autogen_timevary==0 || autogen_timevary==2 || (autogen_timevary==3 && tempvec(1)==-12345))  //  create or overwrite
            {
              tempvec.fill("{0,0,0.,0.,0,6,4}");
              tempvec(1)=baseparm_list(1)-baseparm_list(3);  //  max negative change
              tempvec(2)=baseparm_list(2)-baseparm_list(3);   //  max positive change
              tempvec(5)=0.5*fmin(abs(tempvec(1)),tempvec(2));   //  sd of normal prior
            }
            timevary_parm_rd.push_back (tempvec);
             break;}
           case 2:
           {ParmLabel+=ParmLabel(j)+"_BLK"+NumLbl(z)+"repl_"+onenum+CRLF(1);
            dvector tempvec(1,7);  //  temporary vector for a time-vary parameter  LO HI INIT PRIOR PR_type SD PHASE
            tempvec.initialize();
            if(autogen_timevary>=1)  //  read
            {*(ad_comm::global_datafile) >> tempvec(1,7);}
            if(autogen_timevary==0 || autogen_timevary==2 || (autogen_timevary==3 && tempvec(1)==-12345))  //  create or overwrite
            {
              for(int s=1;s<=7;s++) tempvec(s)=baseparm_list(s);
              if(finish_starter==999)
              {
                double temp;
                temp=tempvec(5);
                tempvec(5)=tempvec(6);
                tempvec(6)=temp;
              }
            }
            timevary_parm_rd.push_back (tempvec);
             break;}
           case 3:
           {ParmLabel+=ParmLabel(j)+"_BLK"+NumLbl(z)+"delta_"+onenum+CRLF(1);
            dvector tempvec(1,7);  //  temporary vector for a time-vary parameter  LO HI INIT PRIOR PR_type SD PHASE
            tempvec.initialize();
            if(autogen_timevary>=1)  //  read
            {*(ad_comm::global_datafile) >> tempvec(1,7);}
            if(autogen_timevary==0 || autogen_timevary==2 || (autogen_timevary==3 && tempvec(1)==-12345))  //  create or overwrite
            {
              tempvec.fill("{0,0,0.,0.,0,6,4}");
              tempvec(1)=baseparm_list(1)-baseparm_list(3);  //  max negative change
              tempvec(2)=baseparm_list(2)-baseparm_list(3);   //  max positive change
              tempvec(5)=0.5*fmin(abs(tempvec(1)),tempvec(2));   //  sd of normal prior
            }
            timevary_parm_rd.push_back (tempvec);
             break;}
         }
         y=block_design_pass(g+1)+1;  // first year after block
         if(y>endyr+1) y=endyr+1;  //  should change this to YrMax
         timevary_byyear(y)=1;
         if(targettype==7 && timevary_setup(1)==1)  //  so doing catch_mult which needs annual values calculated for each year of the block
         {
           for(k=block_design_pass(g);k<=y;k++)  //  where y has end year of block + 1
           {
             timevary_byyear(k)=1;
           }
         }
         g+=2;
        }
      }
      else //  (z<0) so invoke a trend
      {
        echoinput<<"trend "<<endl;
         if(baseparm_list(13)==-1)
         {
           ParCount++; ParmLabel+=ParmLabel(j)+"_TrendFinal_LogstOffset"+CRLF(1);
           ParCount++; ParmLabel+=ParmLabel(j)+"_TrendInfl_LogstOffset"+CRLF(1);
           ParCount++; ParmLabel+=ParmLabel(j)+"_TrendWidth_yrs_"+CRLF(1);
           for(k=1;k<=3;k++)  //  for the 3 trend parameters
           {
            timevary_parm_cnt++;
            dvector tempvec(1,7);  //  temporary vector for a time-vary parameter  LO HI INIT PRIOR PR_type SD PHASE
            tempvec.initialize();
            if(autogen_timevary>=1)  //  read
            {*(ad_comm::global_datafile) >> tempvec(1,7);}
            if(autogen_timevary==0 || autogen_timevary==2 || (autogen_timevary==3 && tempvec(1)==-12345))  //  create or overwrite
            {
             if(k==1) {tempvec.fill("{-4.0,4.0,0.,0.,0.5,6,4}");}
             if(k==2) {tempvec.fill("{-4.0,4.0,0.,0.,0.5,6,4}");}
             if(k==3) {tempvec.fill("{1.0,20.0,3.,3.,3.0,6,4}");}
            }
            timevary_parm_rd.push_back (tempvec);
           }
         }
         else if(baseparm_list(13)==-2)
         {
           ParCount++; ParmLabel+=ParmLabel(j)+"_TrendFinal_direct_"+CRLF(1);
           ParCount++; ParmLabel+=ParmLabel(j)+"_TrendInfl_yr_"+CRLF(1);
           ParCount++; ParmLabel+=ParmLabel(j)+"_TrendWidth_yr_"+CRLF(1);
           for(k=1;k<=3;k++)  //  for the 3 trend parameters
           {
            timevary_parm_cnt++;
            dvector tempvec(1,7);  //  temporary vector for a time-vary parameter  LO HI INIT PRIOR PR_type SD PHASE
            tempvec.initialize();
            if(autogen_timevary>=1)  //  read
            {*(ad_comm::global_datafile) >> tempvec(1,7);}
            if(autogen_timevary==0 || autogen_timevary==2 || (autogen_timevary==3 && tempvec(1)==-12345))  //  create or overwrite
            {
             if(k==1) {for(a=1;a<=7;a++) tempvec(a)=baseparm_list(a);}
             if(k==2) {tempvec.fill("{-2.0,2.0,0.,0.,0.5,6,4}");
             tempvec(1)=styr; tempvec(2)=endyr; tempvec(3)= (styr+endyr)*0.5; tempvec(4)=tempvec(3);}
             if(k==3) {tempvec.fill("{1.0,20.0,3.,3.,3.0,6,4}");}
            }
            timevary_parm_rd.push_back (tempvec);
           }
         }
         else if(baseparm_list(13)==-3)
         {
           ParCount++; ParmLabel+=ParmLabel(j)+"_TrendFinal_frac_"+CRLF(1);
           ParCount++; ParmLabel+=ParmLabel(j)+"_TrendInfl_frac_"+CRLF(1);
           ParCount++; ParmLabel+=ParmLabel(j)+"_TrendWidth_yr_"+CRLF(1);
           for(k=1;k<=3;k++)  //  for the 3 trend parameters
           {
            timevary_parm_cnt++;
            dvector tempvec(1,7);  //  temporary vector for a time-vary parameter  LO HI INIT PRIOR PR_type SD PHASE
            tempvec.initialize();
            if(autogen_timevary>=1)  //  read
            {*(ad_comm::global_datafile) >> tempvec(1,7);}
            if(autogen_timevary==0 || autogen_timevary==2 || (autogen_timevary==3 && tempvec(1)==-12345))  //  create or overwrite
            {
             if(k==1) {tempvec.fill("{0.0001,0.999,0.,0.,0.5,6,4}");
              tempvec(3)=(baseparm_list(3)-baseparm_list(1))/(baseparm_list(2)-baseparm_list(1)); tempvec(4)=tempvec(3);}
             if(k==2) {tempvec.fill("{0.0001,0.999,0.5,0.5,0.5,6,4}");}
             if(k==3) {tempvec.fill("{1.0,20.0,3.,3.,3.,6,4}");}
            }
            timevary_parm_rd.push_back (tempvec);
           }
         }
         else
         {
           for (int icycle=1;icycle<=Ncycle;icycle++)
           {
             ParCount++; ParmLabel+=ParmLabel(j)+"_Cycle_"+NumLbl(icycle)+CRLF(1);
             timevary_parm_cnt+=1;  //  count the cycle parameters
           }
         }
         for(y=styr-1; y<=YrMax; y++) {timevary_byyear(y)=1;}  //  all years need calculation for trends
      }
    }

    if(baseparm_list(8)!=0)  //  env effect is used
    {
      k=timevary_setup(6);
      if(timevary_setup(7)==99) timevary_setup(7)=-1;  //  for linking to rel_spawn biomass
      if(timevary_setup(7)==98) timevary_setup(7)=-2;  //  for linking to exp(recdev)
      if(timevary_setup(7)==97) timevary_setup(7)=-3;  //  for linking to rel_smrybio
      if(timevary_setup(7)==96) timevary_setup(7)=-4;  //  for linking to rel_smry_num
      echoinput<<"env link_type: "<<k<<" env_var: "<<timevary_setup(7)<<endl;
      switch (k)
      {
        case 1:  //  multiplicative
         {
          echoinput<<" do env mult for parm: "<<j<<" "<<ParmLabel(j)<<endl;
           ParCount++; ParmLabel+=ParmLabel(j)+"_ENV_mult";
           timevary_parm_cnt++;
           dvector tempvec(1,7);
            tempvec.initialize();
            if(autogen_timevary>=1)  //  read
           {*(ad_comm::global_datafile) >> tempvec(1,7);}
            if(autogen_timevary==0 || autogen_timevary==2 || (autogen_timevary==3 && tempvec(1)==-12345))  //  create or overwrite
           {tempvec.fill("{-10.,10.0,1.0,1.0,0.5,6,4}");}
           timevary_parm_rd.push_back (tempvec(1,7));
           break;
         }
        case 2:  //  additive
         {
          echoinput<<" do env additive "<<endl;
           ParCount++; ParmLabel+=ParmLabel(j)+"_ENV_add";
           timevary_parm_cnt++;
           dvector tempvec(1,7);
            tempvec.initialize();
            if(autogen_timevary>=1)  //  read
           {*(ad_comm::global_datafile) >> tempvec(1,7);}
            if(autogen_timevary==0 || autogen_timevary==2 || (autogen_timevary==3 && tempvec(1)==-12345))  //  create or overwrite
           {tempvec.fill("{-10.,10.0,1.0,1.0,0.5,6,4}");}
           timevary_parm_rd.push_back (tempvec(1,7));
           break;
         }
        case 4:  //  logistic with offset
         {
           ParCount++; ParmLabel+=ParmLabel(j)+"_ENV_offset";
           timevary_parm_cnt++;
           dvector tempvec(1,7);
            tempvec.initialize();
            if(autogen_timevary>=1)  //  read
           {*(ad_comm::global_datafile) >> tempvec(1,7);}
            if(autogen_timevary==0 || autogen_timevary==2 || (autogen_timevary==3 && tempvec(1)==-12345))  //  create or overwrite
           {tempvec.fill("{-0.9,0.9,0.0,0.0,0.5,6,4}");}
           timevary_parm_rd.push_back (tempvec(1,7));
           ParCount++; ParmLabel+=ParmLabel(j)+"_ENV_lgst_slope";
           timevary_parm_cnt++;
            tempvec.initialize();
            if(autogen_timevary>=1)  //  read
           {*(ad_comm::global_datafile) >> tempvec(1,7);}
            if(autogen_timevary==0 || autogen_timevary==2 || (autogen_timevary==3 && tempvec(1)==-12345))  //  create or overwrite
           {tempvec.fill("{-0.9,0.9,0.0,0.0,0.5,6,4}");}
           timevary_parm_rd.push_back (tempvec(1,7));
           break;
         }
      }
      for (y=env_data_pass.indexmin();y<=env_data_pass.indexmax()-1;y++)
      {
       if(timevary_setup(7)>0 )
       {
         if(env_data_pass(y)!=0.0) {timevary_byyear(y)=1; timevary_byyear(y+1)=1; }
       }
       else if (timevary_setup(7)<0 )  //  density-dependence being used
       {timevary_byyear(y)=1; }
      }
    }

    if(baseparm_list(9)>0)  //  devs are used
    {
      N_parm_dev++;  //  count of dev vectors that are used
      timevary_setup(8)=N_parm_dev;  //    specifies which dev vector will be used by a parameter
      timevary_setup(9)=baseparm_list(9);  //   code for dev link type
      y=baseparm_list(10);
      if(y<styr)
      {
        N_warn++; warning<<" reset parm_dev start year to styr for parm: "<<j<<" "<<y<<endl;
        y=styr;
      }
      timevary_setup(10)=y;

      y=baseparm_list(11);
      if(y>YrMax)
      {
        N_warn++; warning<<" reset parm_dev end year to YrMax for parm: "<<j<<" "<<y<<endl;
        y=endyr;
      }
      timevary_setup(11)=y;
      for (y=timevary_setup(10);y<=timevary_setup(11)+1;y++)
      {
       timevary_byyear(y)=1;
      }

      ParCount++;
      ParmLabel+=ParmLabel(j)+"_dev_se"+CRLF(1);
      timevary_parm_cnt++;
      dvector tempvec(1,7);
            tempvec.initialize();
            if(autogen_timevary>=1)  //  read
      {
        *(ad_comm::global_datafile) >> tempvec(1,7);
        timevary_setup(12)=baseparm_list(12); //  dev phase
      }
            if(autogen_timevary==0 || autogen_timevary==2 || (autogen_timevary==3 && tempvec(1)==-12345))  //  create or overwrite
      {
       tempvec.fill("{0.0001,2.0,0.5,0.5,0.5,6,-5}");
       if(finish_starter==999)
       {
         tempvec(3)=baseparm_list(12);  //  set init to value on the 3.24 format base parameter line
         tempvec(4)=baseparm_list(12);  //  set prior
       }
//       timevary_setup(12)=-5;  //  set reasonable phase for devs;
//       baseparm_list(12)=-5;
//       N_warn++; warning<<"A parameter dev vector has been created with phase set to negative.  Edit phase as needed "<<endl;
      }
      timevary_parm_rd.push_back (dvector(tempvec(1,7)));

      ParCount++;
      ParmLabel+=ParmLabel(j)+"_dev_autocorr"+CRLF(1);
      timevary_parm_cnt++;
      dvector tempvec2(1,7);
            tempvec2.initialize();
            if(autogen_timevary>=1)  //  read
      {*(ad_comm::global_datafile) >> tempvec2(1,7);}
            if(autogen_timevary==0 || autogen_timevary==2 || (autogen_timevary==3 && tempvec(1)==-12345))  //  create or overwrite
      {tempvec2.fill("{-0.99,0.99,0.0,0.0,0.5,6,-6}");}
      timevary_parm_rd.push_back (dvector(tempvec2(1,7)));
      echoinput<<"dev vec: "<<timevary_setup(8)<<" with link: "<<timevary_setup(9)<<" min, max year "<<timevary_setup(10,11)<<endl;
    }
    echoinput<<"timevary_setup"<<timevary_setup<<endl;
    return;
  }
//  }  //  end GLOBALS_SECTION

//  SS_Label_Section_11. #BETWEEN_PHASES_SECTION
BETWEEN_PHASES_SECTION
  {
  int j_phase=current_phase();  // this is the phase to come
  cout<<current_phase()-1<<" "<<niter<<" -log(L): "<<obj_fun<<"  between "<<endl;

//  SS_Label_Info_11.1 #Save last value of objective function
  if(j_phase>1)
  {
    last_objfun=obj_fun;
  }

//  SS_Label_Info_11.2 #For Fmethod=2, set parameter values (F_rate) equal to Hrate array fromcalculated using hybrid method in previous phase
    if(F_Method==2)
    {
      if(F_setup(2)>1 && j_phase==F_setup(2) && readparfile==0)  //  so now start doing F as paameters
      {
        for (f=1;f<=Nfleet;f++)
        for (t=styr;t<=TimeMax;t++)
        {
          g=do_Fparm(f,t);
          if(g>0) {F_rate(g)=Hrate(f,t);}
        }
      }
    }
  }  //  end BETWEEN_PHASES_SECTION

//  SS_Label_Section_12. #FINAL_SECTION
FINAL_SECTION
  {
  int jj;
//  SS_Label_Info_12.1 #Get run ending time
  time(&finish);
  elapsed_time = difftime(finish,start);
  hour = long(elapsed_time)/3600;
  minute = long(elapsed_time)%3600/60;
  second = (long(elapsed_time)%3600)%60;
  cout<<endl<<"In final section "<<endl;
  cout<<"Finish time: "<<ctime(&finish);
  cout<<"Elapsed time: ";
  cout<<hour<<" hours, "<<minute<<" minutes, "<<second<<" seconds."<<endl;

  if(No_Report==1)
  {
    cout<<"MCMC finished; note: .sso and .ss_new files not produced after MCMC "<<endl;
  }

  else
  {
    cout<<"Final gradient: "<<objective_function_value::pobjfun->gmax << endl<<endl;
    if(objective_function_value::pobjfun->gmax >final_conv)
    {N_warn++; warning<<"Final gradient: "<<objective_function_value::pobjfun->gmax <<" is larger than final_conv: "<<final_conv<<endl;}

//  SS_Label_Info_12.2 #Output the covariance matrix to covar.sso
    ofstream covarout("covar.sso");
    covarout<<version_info<<endl;
    covarout<<"start_time: "<<ctime(&start)<<endl;
    covarout<<active_parms<<" "<<CoVar_Count<<endl;
    covarout<<"active-i active-j all-i all-j Par?-i Par?-j label-i label-j corr"<<endl;
    if(CoVar(1,1)==0.00 && CoVar(2,2)==0.0)
    {covarout<<"Variances are 0.0 for first two elements, so do not write "<<endl;}
    else
    {
      for (i=1;i<=CoVar_Count;i++)
      {
        covarout<<i<<" "<<0<<" "<<active_parm(i)<<" "<<active_parm(i);
        if(i<=active_parms) {covarout<<" Par ";} else {covarout<<" Der ";}
        covarout<<" Std "<<ParmLabel(active_parm(i))<<"   _   "<<CoVar(i,1)<<endl;
        for (j=2;j<=i;j++)
        {
          covarout<<i<<" "<<j-1<<" "<<active_parm(i)<<" "<<active_parm(j-1);
          if(i<=active_parms) {covarout<<" Par ";} else {covarout<<" Der ";}
          if((j-1)<=active_parms) {covarout<<" Par ";} else {covarout<<" Der ";}
          covarout<<ParmLabel(active_parm(i))<<" "<<ParmLabel(active_parm(j-1))<<" "<<CoVar(i,j)<<endl;
        }
      }
      if(mceval_phase()==0) cout<<" finished COVAR.SSO"<<endl;
    }

//  SS_Label_Info_12.3 #Go thru time series calculations again to get extra output quantities
//  SS_Label_Info_12.3.2 #Set save_for_report=1 then call initial_conditions and time_series to get other output quantities
    save_for_report=1;
    save_gparm=0;
    y=styr;
    setup_recdevs();
    get_initial_conditions();
    get_time_series();  //  in final_section with save_for_report on
    evaluate_the_objective_function();
//  SS_Label_Info_12.3.3 #Do benchmarks and forecast and stdquantities with save_for_report=1
    if(mceval_phase()==0) {show_MSY=1;} else {show_MSY=0;}  //  turn on reporting in not in mceval
    if(Do_Benchmark>0)
    {
      setup_Benchmark();
      if(did_MSY==0) 
      {
        Get_Benchmarks(show_MSY);
        if(mceval_phase()==0) cout<<" finished benchmark for reporting"<<endl;
      }
    }
    else
    {Mgmt_quant(1)=SSB_virgin;}
    if(Do_Forecast>0)
    {
      report5<<"THIS FORECAST FOR PURPOSES OF GETTING DISPLAY QUANTITIES"<<endl;
      Get_Forecast();
      if(mceval_phase()==0) cout<<" finished forecast for reporting"<<endl;
    }

//  SS_Label_Info_12.3.4  #call fxn STDquant()
     Process_STDquant();
     if(mceval_phase()==0) cout<<" finished STD quantities for reporting"<<endl;
     get_posteriors();
     if(mceval_phase()==0) cout<<" finished posteriors reporting"<<endl;

//  SS_Label_Info_12.4.2 #Call fxn write_summaryoutput()
    if(Do_CumReport>0) write_summaryoutput();

    write_SS_summary();

//  SS_Label_Info_12.4.3 #Call fxn write_rebuilder_output to produce rebuilder.sso
    if(reportdetail>0)
    {
    if(Do_Rebuilder>0 && mceval_counter<=1) write_rebuilder_output();
    cout<<" finished rebuilder.sso "<<endl;

    write_SIStable();
    cout<<" finished SIStable.sso "<<endl;
    
//  SS_Label_Info_12.4 #Do Outputs
//  SS_Label_Info_12.4.1 #Call fxn write_bigoutput()
    write_bigoutput();
    cout<<" finished report.sso"<<endl;
    }

//  SS_Label_Info_12.4.4 #Call fxn write_nudata() to create bootstrap data in data.ss_new
    if(reportdetail>0)
    {
    write_nudata();
    if(show_MSY==1) cout<<" finished data.ss_new with N replicates: "<<N_nudata<<endl;

//  SS_Label_Info_12.4.5 #Call fxn write_nucontrol() to produce control.ss_new
    write_nucontrol();
    if(show_MSY==1) cout<<" finished control.ss_new "<<endl;
    }

//  SS_Label_Info_12.4.6 #Call fxn write_Bzero_output()  appended to report.sso
    if (reportdetail ==1)
    {
        write_Bzero_output();
        if(show_MSY==1) cout<<" finished Bzero and global MSY "<<endl;
    }

//  SS_Label_Info_12.3.1 #Write out body weights to wtatage.ss_new.  Occurs while doing procedure with save_for_report=2
    if(reportdetail==1)
    {
    save_for_report=2;
//    bodywtout<<1<<"  #_user_must_replace_this_value_with_number_of_lines_with_wtatage_below"<<endl;
    bodywtout<<nages<<" # maxage"<<endl;
    bodywtout<<"# if Yr is negative, then fill remaining years for that Seas, growpattern, Bio_Pattern, Fleet"<<endl;
    bodywtout<<"# if season is negative, then fill remaining fleets for that Seas, Bio_Pattern, Sex, Fleet"<<endl;
    bodywtout<<"# will fill through forecast years, so be careful"<<endl;
    bodywtout<<"# fleet 0 contains begin season pop WT"<<endl;
    bodywtout<<"# fleet -1 contains mid season pop WT"<<endl;
    bodywtout<<"# fleet -2 contains maturity*fecundity"<<endl;
    bodywtout<<"#Yr Seas Sex Bio_Pattern BirthSeas Fleet "<<age_vector<<endl;
    save_gparm=0;
    y=styr;
    fishery_on_off=1;
    setup_recdevs();
    get_initial_conditions();
    get_time_series();  //  in final_section
    Get_Forecast();
    bodywtout<<-9999<<" "<<1<<" "<<1<<" "<<1<<" "<<1<<" "<<0<<" "<<Wt_Age_mid(1,1)<<" #terminator "<<endl;
    bodywtout.close();
    if(show_MSY==1) cout<<" write wtatage.ss_new "<<endl;
    }

    warning<<" N warnings: "<<N_warn<<endl;
    if(parm_adjust_method==3) warning<<"time-vary parms not bound checked"<<endl;
    cout<<endl<<"!!  Run has completed  !!            ";

//  SS_Label_Info_12.4.7 #Finish up with final writes to warning.sso
    if(N_changed_lambdas>0)
      {N_warn++; warning<<"Reminder: Number of lamdas !=0.0 and !=1.0:  "<<N_changed_lambdas<<endl; }
    warning<<"Number_of_active_parameters_on_or_near_bounds: "<<Nparm_on_bound<<endl;
    if(Nparm_on_bound>0) N_warn++;
    if(N_warn>0)
    {cout<<"See warning.sso for N warnings: "<<N_warn<<endl;}
    else
    {cout<<"No warnings :)"<<endl;}
  }
  }  //  end final section

//  SS_Label_Section_13. #REPORT_SECTION  produces SS3.rep,which is less extensive than report.sso produced in final section
REPORT_SECTION
  {
    save_gradients(gradients);
    for (int i = 1; i <= gradients.size(); i++) parm_gradients(i) = gradients(i);

//  SS_Label_Info_13.1 #Write limited output to SS.rep
  if(reportdetail>0)
  {
  if(Svy_N>0) report<<" CPUE " <<surv_like<<endl;
  if(nobs_disc>0) report<<" Disc " <<disc_like<<endl;
  if(nobs_mnwt>0) report<<" MnWt " <<mnwt_like<<endl;
  if(Nobs_l_tot>0)report<<" LEN  "<<length_like_tot<<endl;
  if(Nobs_a_tot>0)report<<" AGE  "<<age_like_tot<<endl;
  if(nobs_ms_tot>0) report<<" L-at-A  " <<sizeage_like<<endl;
  report<<" EQUL " <<equ_catch_like<<endl;
  report<<" Recr " <<recr_like<<endl;
  report<<" Parm " <<parm_like<<endl;
  report<<" F_ballpark " <<F_ballpark_like<<endl;
  if(F_Method>1) {report<<"Catch "<<catch_like<<endl;} else {report<<"  crash "<<CrashPen<<endl;}
  if(SzFreq_Nmeth>0) report<<" sizefreq "<<SzFreq_like<<endl;
  if(Do_TG>0) report<<" TG-fleetcomp "<<TG_like1<<endl<<" TG-negbin "<<TG_like2<<endl;
  report<<" -log(L): "<<obj_fun<<"  Spbio: "<<value(SSB_yr(styr))<<
  " "<<value(SSB_yr(endyr))<<endl;

  report<<endl<<"Year Spbio Recruitment"<<endl;
  report<<"Virg "<<SSB_yr(styr-2)<<" "<<exp_rec(styr-2,4)<<endl;
  report<<"Init "<<SSB_yr(styr-1)<<" "<<exp_rec(styr-1,4)<<endl;
  for(y=styr;y<=endyr;y++) report<<y<<" "<<SSB_yr(y)<<" "<<exp_rec(y,4)<<endl;

  report<<endl<<"EXPLOITATION F_Method: ";
  if(F_Method==1) {report<<" Pope's_approx ";} else {report<<" instantaneous_annual_F ";}
  report<<endl<<"X Catch_Units ";
  for (f=1;f<=Nfleet;f++) if(catchunits(f)==1) {report<<" Bio ";} else {report<<" Num ";}
  report<<endl<<"Yr Seas"; for (f=1;f<=Nfleet;f++) report<<" "<<f;
  report<<endl<<"init_yr 1 ";
  for (s=1;s<=nseas;s++)
  for (f=1;f<=Nfleet;f++)
  {
    if(init_F_loc(s,f)>0)
      {report<<" "<<init_F(init_F_loc(s,f));}
      else
      {report<<" NA ";}
  }
  report<<endl;
  for (y=styr;y<=endyr;y++)
  for (s=1;s<=nseas;s++)
  {
    t=styr+(y-styr)*nseas+s-1;
    report<<y<<" "<<s<<" "<<column(Hrate,t)<<endl;
  }

  report<<endl<< "LEN_SELEX" << endl;
  report<<"Fleet Sex "<<len_bins_m<<endl;
  for (f=1;f<=Nfleet;f++)
  {
    if(seltype(f,1)>0)
    {
      for (gg=1;gg<=gender;gg++) report<<f<<"-"<<fleetname(f)<<gg<<" "<<sel_l(endyr,f,gg)<<endl;
    }
  }

  report<<endl<< "AGE_SELEX" << endl;
  report<<"Fleet Sex "<<age_vector<<endl;
  for (f=1;f<=Nfleet;f++)
  {
    if(seltype(f+Nfleet,1)>10)
    {
      for (gg=1;gg<=gender;gg++) report<<f<<"-"<<fleetname(f)<<" "<<gg<<" "<<sel_a(endyr,f,gg)<<endl;
    }
  }
  }

//  SS_Label_Info_13.2 #Call fxn write_bigoutput() as last_phase finishes and before doing Hessian
    if(last_phase()>0)
    {
    save_for_report=1;
    save_gparm=0;
    y=styr;
    setup_recdevs();
    get_initial_conditions();
    get_time_series();  //  in ADMB's report_section
    evaluate_the_objective_function();
    wrote_bigreport=0;
    if(reportdetail>0)
    {
    write_bigoutput();
    cout<<" finished writing bigoutput for last_phase in report section and before hessian "<<endl;
    }
    save_for_report=0;
    SS2out.close();
    }
  }  //  end standard report section
