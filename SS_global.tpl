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
  time_t start,finish;
  long hour,minute,second;
  double elapsed_time;

//  SS_Label_Info_10.1 #Open output files using ofstream
  ofstream warning("warning.sso");
  ofstream checkup("checkup.sso");
  ofstream echoinput("echoinput.sso");
  ofstream ParmTrace("ParmTrace.sso");
  ofstream report5("Forecast-report.sso");
  ofstream report2("CumReport.sso",ios::app);
  ofstream bodywtout("wtatage.ss_new");
  ofstream SS2out;   // this is just a create

//  SS_Label_Info_10.2 #Define some adstring variables
  adstring_array ParmLabel;  // extendable array to hold the parameter labels
  adstring_array fleetname;
  adstring fleetnameread;
  adstring depletion_basis_label;
  adstring F_report_label;
  adstring SPR_report_label;
  adstring onenum(4);
  adstring anystring;
  adstring anystring2;
  adstring version_info;
  adstring version_info_short;
  adstring_array Starter_Comments;
  adstring_array Data_Comments;
  adstring_array Control_Comments;
  adstring_array Forecast_Comments;
  
//  SS_Label_Info_10.3  #start random number generator with seed based on time
  random_number_generator radm(long(time(&start)));

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

//  example function in GLOBALS to do the timing setup in the data section
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
        i_result(6)=0;
      }  
      else
      {  //  use midseason and Nmid abundance
        data_timing_seas=0.5;
        i_result(6)=1;
      }
      month=1.0 + azero_seas(s)*12. + 12.*data_timing_seas*seasdur(s);
    }
    else  //  reading month.fraction
    {
      if(month>999)
        {  // this observation uses mean abundance during the season
          month-=1000;
          i_result(6)=1.;
        }
        else
        {
          i_result(6)=0.;
        }

      temp1=(month-1.0)/12.;  //  month as fraction of year
      s=1;  // earlist possible seas;
      subseas=1;  //  earliest possible subseas in seas
      temp=subseasdur_delta(s);  //  starting value
      while(temp<=temp1)
      {
        if(subseas==timing_constants(3))
        {s++; subseas=1;}
        else
        {subseas++;}
        temp+=subseasdur_delta(s);
      }
      data_timing_seas=(temp1-azero_seas(s))/seasdur(s);  //  remainder converted to fraction of season (and multiplied by seasdur when used)
    }

//    t=styr+(y-styr)*nseas+s-1;
//    ALK_time=(yr-styr)*nseas*N_subseas+(s-1)*N_subseas+subseas;
    i_result(1)=y;
    i_result(2)=timing_constants(5)+(y-timing_constants(5))*timing_constants(2)+s-1;  //  t
    i_result(3)=s;
    i_result(4)=f;
    i_result(5)=(y-timing_constants(5))*timing_constants(2)*timing_constants(3)+(s-1)*timing_constants(3)+subseas;  //  ALK_time

    r_result(1)=month;
    r_result(2)=data_timing_seas;
    r_result(3)=float(y)+(month-1.)/12.;  //  year.fraction

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

//  }  //  end GLOBALS_SECTION

//  SS_Label_Section_11. #BETWEEN_PHASES_SECTION
BETWEEN_PHASES_SECTION
  {
  int j_phase=current_phase();  // this is the phase to come

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
  cout<<endl<<"Finish time: "<<ctime(&finish);
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
    covarout<<version_info_short<<endl;
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
    }
    cout<<"Finished writing COVAR.SSO"<<endl;

    get_posteriors();
    
//  SS_Label_Info_12.3 #Go thru time series calculations again to get extra output quantities

//  SS_Label_Info_12.3.1 #Write out body weights to wtatage.ss_new.  Occurs while doing procedure with save_for_report=2 
    save_for_report=2;
    bodywtout<<1<<"  #_user_must_replace_this_value_with_number_of_lines_with_wtatage_below"<<endl;
    bodywtout<<N_WTage_maxage<<" # maxage"<<endl;
    bodywtout<<"# if yr=-yr, then fill remaining years for that seas, growpattern, gender, fleet"<<endl;
    bodywtout<<"# fleet 0 contains begin season pop WT"<<endl;
    bodywtout<<"# fleet -1 contains mid season pop WT"<<endl;
    bodywtout<<"# fleet -2 contains maturity*fecundity"<<endl;
    bodywtout<<"#yr seas gender growpattern birthseas fleet "<<age_vector<<endl;
    save_gparm=0;
    y=styr;
   get_initial_conditions();
    get_time_series();  //  in final_section
    bodywtout.close();

//  SS_Label_Info_12.3.2 #Set save_for_report=1 then call initial_conditions and time_series to get other output quantities
    save_for_report=1;
    save_gparm=0;
    y=styr;
    get_initial_conditions();
    get_time_series();  //  in final_section with save_for_report on
    evaluate_the_objective_function();

//  SS_Label_Info_12.3.3 #Do benchmarks and forecast and stdquantities with save_for_report=1
    if(mceval_phase()==0) {show_MSY=1;} else {show_MSY=0;}
    if(Do_Benchmark>0)
    {
      report5<<"show MSY before call in global "<<show_MSY<<endl;
      if(did_MSY==0) Get_Benchmarks(show_MSY);
    }
    else
    {Mgmt_quant(1)=SPB_virgin;}
     cout<<"finished benchmark"<<endl;
    if(Do_Forecast>0)
    {
      report5<<"THIS FORECAST FOR PURPOSES OF GETTING DISPLAY QUANTITIES"<<endl;
      Get_Forecast();
    }
    cout<<" finished forecast "<<endl;

//  SS_Label_Info_12.3.4  #call fxn STDquant()
    Process_STDquant();
    cout<<" finished STD quantities "<<endl;

//  SS_Label_Info_12.4 #Do Outputs
//  SS_Label_Info_12.4.1 #Call fxn write_bigoutput()
    write_bigoutput();
    cout<<" finished big report in final_section"<<endl;

//  SS_Label_Info_12.4.2 #Call fxn write_summaryoutput() to produce report.sso and compreport.sso
    if(Do_CumReport>0) write_summaryoutput();
    cout<<" finished summary report "<<endl;

//  SS_Label_Info_12.4.3 #Call fxn write_rebuilder_output to produce rebuilder.sso
    if(Do_Rebuilder>0 && mceval_counter<=1) write_rebuilder_output();
    cout<<" finished rebuilder report "<<endl;

//  SS_Label_Info_12.4.4 #Call fxn write_nudata() to create bootstrap data in data.ss_new
    write_nudata();
    cout<<" finished nudata report "<<endl;

//  SS_Label_Info_12.4.5 #Call fxn write_nucontrol() to produce control.ss_new
    write_nucontrol();
    cout<<" finished nucontrol report "<<endl;

//  SS_Label_Info_12.4.6 #Call fxn write_Bzero_output()  appended to report.sso
    write_Bzero_output();
    warning<<" N warnings: "<<N_warn<<endl;
    if(MG_adjust_method==3) warning<<"time-vary MGparms not bound checked"<<endl;
    if(selparm_adjust_method==3) warning<<"time-vary selparms not bound checked"<<endl;
    cout<<endl<<"!!  Run has completed  !!            ";
    
//  SS_Label_Info_12.4.7 #Finish up with final writes to warning.sso
    if(N_changed_lambdas>0)
      {N_warn++; warning<<"Reminder: Number of lamdas !=0.0 and !=1.0:  "<<N_changed_lambdas<<endl; }
    warning<<"Number_of_active_parameters_on_or_near_bounds: "<<Nparm_on_bound<<endl;
    if(Nparm_on_bound>0) N_warn++;
    if(N_warn>0)
    {cout<<"See warning.sso for N warnings: "<<N_warn<<endl;}
    else
    {cout<<"No warnings"<<endl;}
  }
  }  //  end final section

//  SS_Label_Section_13. #REPORT_SECTION  produces SS3.rep,which is less extensive than report.sso produced in final section
REPORT_SECTION
  {
//  SS_Label_Info_13.1 #Write limited output to SS3.rep
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
  report<<" -log(L): "<<obj_fun<<"  Spbio: "<<value(SPB_yr(styr))<<
  " "<<value(SPB_yr(endyr))<<endl;

  report<<endl<<"Year Spbio Recruitment"<<endl;
  report<<"Virg "<<SPB_yr(styr-2)<<" "<<exp_rec(styr-2,4)<<endl;
  report<<"Init "<<SPB_yr(styr-1)<<" "<<exp_rec(styr-1,4)<<endl;
  for(y=styr;y<=endyr;y++) report<<y<<" "<<SPB_yr(y)<<" "<<exp_rec(y,4)<<endl;

  report<<endl<<"EXPLOITATION F_Method: ";
  if(F_Method==1) {report<<" Pope's_approx ";} else {report<<" instantaneous_annual_F ";}
  report<<endl<<"X Catch_Units ";
  for (f=1;f<=Nfleet;f++) if(catchunits(f)==1) {report<<" Bio ";} else {report<<" Num ";}
  report<<endl<<"yr seas"; for (f=1;f<=Nfleet;f++) report<<" "<<f;
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
  report<<"Fleet gender "<<len_bins_m<<endl;
  for (f=1;f<=Nfleet;f++)
  {
    if(seltype(f,1)>0)
    {
      for (gg=1;gg<=gender;gg++) report<<f<<"-"<<fleetname(f)<<gg<<" "<<sel_l(endyr,f,gg)<<endl;
    }
  }

  report<<endl<< "AGE_SELEX" << endl;
  report<<"Fleet gender "<<age_vector<<endl;
  for (f=1;f<=Nfleet;f++)
  {
    if(seltype(f+Nfleet,1)>10)
    {
      for (gg=1;gg<=gender;gg++) report<<f<<"-"<<fleetname(f)<<" "<<gg<<" "<<sel_a(endyr,f,gg)<<endl;
    }
  }

//  SS_Label_Info_13.2 #Call fxn write_bigoutput() as last_phase finishes and before doing Hessian
    if(last_phase()>0)
    {
    save_for_report=1;
    save_gparm=0;
    y=styr;
    get_initial_conditions();
    get_time_series();  //  in ADMB's report_section
    evaluate_the_objective_function();
    wrote_bigreport=0;
    write_bigoutput();
    cout<<" finished writing bigoutput for last_phase in report section and before hessian "<<endl;
    save_for_report=0;
    SS2out.close();
    }
  }  //  end standard report section
